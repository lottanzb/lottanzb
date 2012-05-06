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


public class Lottanzb.ConfigHub : Object {

	private SettingsBackend settings_backend;

	public QueryProcessor query_processor { get; construct set; }
	public SabnzbdRootSettings root { get; construct set; }
	
	public DataSpeed speed_limit {
		get {
			return DataSpeed (root.get_misc ().get_int ("bandwidth-limit"));
		}
		set {
			root.get_misc ().set_int ("bandwidth-limit", (int) value.bytes_per_second);
		}
	}

	public string download_folder {
		owned get {
			var result = root.get_misc ().get_string ("complete-dir");
			var is_local = query_processor.connection_info.is_local;
			if (is_local) {
				var result_file = File.new_for_path (result);
				if (!result_file.query_exists ()) {
					var home_folder_path = Environment.get_home_dir ();
					var home_folder = File.new_for_path (home_folder_path);
					result_file = home_folder.get_child (result);
					result = result_file.get_path ();
				}
			}
			return result;
		}
		set {
			root.get_misc ().set_string ("complete-dir", value);
		}
	}

	public ConfigHub (QueryProcessor query_processor) {
		this.query_processor = query_processor;
		settings_backend = BetterSettings.build_memory_settings_backend ();
		root = new SabnzbdRootSettings (settings_backend);
		var query = query_processor.get_config ();
		root.set_recursively_from_json_object (query.get_response ());
		root.get_misc ().changed.connect ((settings, key) => {
			var path = new Gee.LinkedList<string> ();
			path.add ("misc");
			var entries = new Gee.HashMap<string, string> ();
			var variant = settings.get_value (key);
			entries[key.replace ("_", "-")] = get_string_from_variant (variant);
			query_processor.set_config (path, entries);
		});
	}

	private string get_string_from_variant (Variant variant) {
		var variant_type = variant.get_type ();
		if (variant_type.equal (VariantType.STRING)) {
			return variant.get_string ();
		} else if (variant_type.equal (VariantType.INT32)) {
			return variant.get_int32 ().to_string ();
		} else if (variant_type.equal (VariantType.BOOLEAN)) {
			var value = variant.get_boolean ();
			if (value) {
				return "1";
			} else {
				return "0";
			}
		}
		assert_not_reached ();
	}

}
