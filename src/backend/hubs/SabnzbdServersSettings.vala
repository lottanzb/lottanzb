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
	
	public static const int MAX_SERVER_COUNT = 10;

	private int _size = 0;
	public int size {
		get {
			return _size;
		}
		set {
			assert (0 <= value && value <= MAX_SERVER_COUNT);
			_size = value;
			for (var invalid_index = _size; invalid_index < MAX_SERVER_COUNT; invalid_index++) {
				var invalid_server = get_server (invalid_index);
				invalid_server.reset_all ();
			}
		}
	}

	public SabnzbdServersSettings (string schema_id) {
		Object (schema_id: schema_id);
	}

	public SabnzbdServersSettings.with_backend (string schema_id, SettingsBackend backend) {
		Object (schema_id: schema_id, backend: backend);
	}

	public SabnzbdServersSettings.with_backend_and_path (string schema_id, SettingsBackend backend, string path) {
		Object (schema_id: schema_id, backend: backend, path: path);
	}

	public BetterSettings get_server (int index) {
		var server = get_child (index_to_key (index));
		return server;
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
	}

	private string index_to_key (int index) {
		return @"server$(index)";
	}

	public new SabnzbdServersSettings get_copy () {
		var servers = new SabnzbdServersSettings.with_backend_and_path (schema_id, backend, path);
		servers._size = _size;
		return servers;
	}

}
