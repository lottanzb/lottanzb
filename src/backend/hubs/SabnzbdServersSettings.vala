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

public class Lottanzb.SabnzbdServersSettings : BetterSettings {
	
	public static const int MAX_SERVER_COUNT = 10;

	public int size { get; private set; }

	public SabnzbdServersSettings (string schema_id) {
		Object (schema_id: schema_id);
		initialize_size_computation ();
	}

	public SabnzbdServersSettings.with_backend (string schema_id, SettingsBackend backend) {
		Object (schema_id: schema_id, backend: backend);
		initialize_size_computation ();
	}

	public SabnzbdServersSettings.with_backend_and_path (string schema_id, SettingsBackend backend, string path) {
		Object (schema_id: schema_id, backend: backend, path: path);
		initialize_size_computation ();
	}

	private void initialize_size_computation () {
		size = compute_size ();
		for (var index = 0; index < MAX_SERVER_COUNT; index++) {
			var shared_server = get_shared_server (index);
			shared_server.changed.connect ((key) => {
				if (key == "host") {
					size = compute_size ();
				}	
			});
		}
	}

	public BetterSettings get_server (int index) {
		var server = get_child (index_to_key (index));
		return server;
	}

	public BetterSettings get_shared_server (int index) {
		var server = get_shared_child (index_to_key (index));
		return server;
	}

	public new BetterSettings get (int index) {
		return get_shared_server (index);
	}

	public override void set_recursively_from_json_array (Json.Array array) {
		for (var index = 0; index < array.get_length (); index++) {
			if (index < MAX_SERVER_COUNT) {
				var object = array.get_object_element (index);
				var server = get_shared_server (index);
				server.set_all_from_json_object (object);
			}
		}
	}

	private string index_to_key (int index) {
		return @"server$(index)";
	}

	private int compute_size () {
		var size = 0;
		for (var index = 0; index < MAX_SERVER_COUNT; index++) {
			var server = get_shared_server (index);
			if (is_valid_server (server)) {
				size++;
			}
		}
		return size;
	}

	private bool is_valid_server (BetterSettings server) {
		return server.get_string ("host") != null && server.get_string ("host").length > 0;
	}

}
