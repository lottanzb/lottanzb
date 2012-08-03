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
	public SabnzbdSettingsUpdater settings_updater { get; construct set; }

	public DataSpeed speed_limit {
		get {
			return DataSpeed (root.get_misc ().get_int ("bandwidth-limit"));
		}
		set {
			root.get_misc ().set_int ("bandwidth-limit", (int) value.bytes_per_second);
		}
	}

	public ConfigHub (QueryProcessor query_processor) {
		this.query_processor = query_processor;
		this.settings_backend = BetterSettings.build_memory_settings_backend ();
		this.root = new SabnzbdRootSettings (settings_backend);
		this.settings_updater = new SabnzbdSettingsUpdater (root);

		var is_local = query_processor.connection_info.is_local;
		if (is_local) {
			var download_folder_transformation = new LocalFolderAbsolutePathTransformation (
					root.get_misc ().path, "complete-dir");
			settings_updater.add_transformation (download_folder_transformation);
		}

		var query = query_processor.get_config ();
		settings_updater.update (query.get_response ());
		connect_to_changed_signal (root);
	}

	private void connect_to_changed_signal (BetterSettings settings) {
		settings.changed.connect ((settings, key) => {
			on_settings_changed (settings as BetterSettings, key);
		});
		foreach (var child_name in settings.list_children ()) {
			var child_settings = settings.get_child (child_name);
			connect_to_changed_signal (child_settings);
		}
	}

	private void on_settings_changed (BetterSettings settings, string key) {
		// Do not write-back settings that are internal to LottaNZB
		if (settings.is_internal (key)) {
			return;
		}
		var root_path = root.path;
		var path = settings.path;
		var relative_path = path.substring (root_path.length);
		var path_elements = new Gee.LinkedList<string> ();
		foreach (var path_element in relative_path.split ("/")) {
			if (path_element.length > 0) {
				path_elements.add (path_element);
			}
		}
		var entries = new Gee.HashMap<string, string> ();
		var variant = settings.get_value (key);
		entries[key.replace ("-", "_")] = get_string_from_variant (variant);
		query_processor.set_config (path_elements, entries);
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

public class Lottanzb.LocalFolderAbsolutePathTransformation : Object, SabnzbdSettingsTransformation {

	public string target_path { get; construct set; }
	public string target_key { get; construct set; }

	public LocalFolderAbsolutePathTransformation (string target_path, string target_key) {
		this.target_path = target_path;
		this.target_key = target_key;
	}

	public void transform (BetterSettings active, string key,
			Variant variant, out Variant transformed_variant) {
		if (target_key == key && active.path == target_path) {
			var relative_path = variant.get_string ();
			var absolute_path = get_absolute_local_folder (relative_path);
			transformed_variant = new Variant.string (absolute_path);
		} else {
			transformed_variant = variant;
		}
	}

	private string get_absolute_local_folder (string relative_folder) {
		var result = relative_folder;
		var file = File.new_for_path (result);
		if (!file.query_exists ()) {
			var home_folder_path = Environment.get_home_dir ();
			var home_folder = File.new_for_path (home_folder_path);
			file = home_folder.get_child (result);
			result = file.get_path ();
		}
		return result;
	}

}