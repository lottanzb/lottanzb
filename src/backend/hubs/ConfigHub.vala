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


extern SettingsBackend g_memory_settings_backend_new ();

public class Lottanzb.ConfigHub : Object {

	public static const int MAX_SERVER_COUNT = 10;

	private SettingsBackend settings_backend;

	public QueryProcessor query_processor { get; construct set; }
	public BetterSettings root { get; construct set; }
	public BetterSettings misc { get; construct set; }
	public BetterSettings servers { get; construct set; }
	public BetterSettings internal_root { get; construct set; }
	
	public DataSpeed speed_limit {
		get {
			return DataSpeed (misc.get_int ("bandwidth-limit"));
		}
		set {
			misc.set_int ("bandwidth-limit", (int) value.bytes_per_second);
		}
	}

	public string download_folder {
		owned get {
			var download_folder_path = misc.get_string ("complete-dir");
			var is_local = query_processor.connection_info.is_local;
			if (is_local) {
				var download_folder = File.new_for_path (download_folder_path);
				if (!download_folder.query_exists (null)) {
					var home_folder_path = Environment.get_home_dir ();
					var home_folder = File.new_for_path (home_folder_path);
					download_folder = home_folder.get_child (download_folder_path);
					download_folder_path = download_folder.get_path ();
				}
			}
			return download_folder;
		}
		set {
			misc.set_string ("complete-dir", value);
		}
	}

	public ConfigHub (QueryProcessor query_processor) {
		this.query_processor = query_processor;
		settings_backend = g_memory_settings_backend_new ();
		root = new SABnzbdRootSettings (settings_backend);
		misc = root.get_child_for_same_backend_cached ("misc");
		servers = root.get_child_for_same_backend_cached ("servers");
		internal_root = new SABnzbdRootSettings (settings_backend);
		var internal_misc = internal_root.get_child_for_same_backend_cached ("misc");
		var query = query_processor.get_config ();
		var misc_member = query.get_response ().get_object_member ("misc");
		set_settings_from_json_object (misc_member, internal_misc);
		var internal_servers = internal_root.get_child_for_same_backend_cached ("servers");
		var servers_member = query.get_response ().get_array_member ("servers");
		for (var index = 0; index < servers_member.get_length (); index++) {
			var server_member = servers_member.get_object_element (index);
			var server_key = @"server$(index)";
			var internal_server = internal_servers.get_child_for_same_backend_cached (server_key);
			set_settings_from_json_object (server_member, internal_server);
		}
	}

	private void set_settings_from_json_object (Json.Object source_object, BetterSettings target_settings) {
		var target_keys = target_settings.list_keys ();
		foreach (var target_key in target_keys) {
			var source_key = target_key.replace ("-", "_");
			if (source_object.has_member (source_key)) {
				var source_member = source_object.get_member (source_key);
				if (source_member.get_node_type () == Json.NodeType.VALUE) {
					var target_type = target_settings.get_value (target_key).get_type ();
					if (target_type.equal (VariantType.STRING)) {
						var source_value = source_member.get_string ();
						target_settings.set_string (target_key, source_value);
					} else if (target_type.equal (VariantType.INT32)) {
						var source_type = source_member.get_value_type ();
						if (source_type.is_a (typeof (string))) {
							var source_string_value = source_member.get_string ();
							var source_int_value = int.parse (source_string_value);
							target_settings.set_int (target_key, source_int_value);
						} else if (source_type.is_a (typeof (int64))) {
							var source_value = (int) source_member.get_int ();
							target_settings.set_int (target_key, source_value);
						} else {
							assert_not_reached ();
						}
					} else if (target_type.equal (VariantType.BOOLEAN)) {
						var source_type = source_member.get_value_type ();
						if (source_type.is_a (typeof (int64))) {
							var source_bool_value = source_member.get_int () != 0;
							target_settings.set_boolean (target_key, source_bool_value);
						} else {
							assert_not_reached ();
						}
					}	
				} else {
					stdout.printf (@"source member with key $(source_key) is not a value\n");
				}
			} else {
				stdout.printf (@"source object has no member with key $(source_key)\n");
			}
		}
	}
	
}
