/**
 * Copyright (c) 2012 Severin Heiniger <severinheiniger@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

public class Lottanzb.SabnzbdServersSettings : BetterSettings, Copyable<SabnzbdServersSettings> {
	
	public static const int MAX_SERVER_COUNT = 20;

	public SabnzbdServersSettings (string schema_id) {
		Object (schema_id: schema_id);
	}

	public SabnzbdServersSettings.with_backend (string schema_id, SettingsBackend backend) {
		Object (schema_id: schema_id, backend: backend);
	}

	public SabnzbdServersSettings.with_backend_and_path (string schema_id, SettingsBackend backend, string path) {
		Object (schema_id: schema_id, backend: backend, path: path);
	}

	public int size {
		get {
			return get_int ("size");
		}
		set {
			set_int ("size", value);
		}
	}

	public SabnzbdServerSettings get_server (int index) {
		var server = get_child (index_to_key (index)) as SabnzbdServerSettings;
		return server;
	}

	protected override BetterSettings make_child (string name, string child_schema_id, string child_path) {
		var child = new SabnzbdServerSettings.with_backend_and_path (child_schema_id, backend, child_path);
		return child;
	}

	public bool has_reached_max_server_count {
		get {
			return size == MAX_SERVER_COUNT;
		}
	}

	public override void set_recursively_from_json_array (Json.Array array) {
		size = int.min (MAX_SERVER_COUNT, (int) array.get_length ());
		if (MAX_SERVER_COUNT < array.get_length ()) {
			warning ("support for at most %d servers", MAX_SERVER_COUNT);
		}
		for (var index = 0; index < size; index++) {
			var server = get_server (index);
			if (index < array.get_length ()) {
				var object = array.get_object_element (index);
				server.set_all_from_json_object (object);
			}
		}
		for (var invalid_index = size; invalid_index < MAX_SERVER_COUNT; invalid_index++) {
			var invalid_server = get_server (invalid_index);
			invalid_server.reset_all ();
		}
	}

	public void remove_server (int index)
		requires (0 <= index && index < size) {
		for (; index < size - 1; index++) {
			var target_server = get_server (index);
			var source_server = get_server (index + 1);
			foreach (var key in target_server.list_keys ()) {
				var source_value = source_server.get_value (key);
				target_server.set_value (key, source_value);
			}
		}
		var last_server = get_server (size - 1);
		last_server.reset_all ();
		size--;
	}

	public void remove_empty_servers () {
		for (var index = 0; index < size; index++) {
			var server = get_server (index);
			if (server.get_string ("host").length == 0) {
				remove_server (index);
			}
		}
	}

	public void add_server ()
		requires (!has_reached_max_server_count) {
		size++;
	}

	private string index_to_key (int index) {
		return @"server$(index)";
	}

	public new SabnzbdServersSettings get_copy () {
		var servers = new SabnzbdServersSettings.with_backend_and_path (schema_id, backend, path);
		return servers;
	}

}
