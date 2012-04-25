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

public class Lottanzb.BetterSettings : Settings {

	private Gee.Map<string, BetterSettings> children;

	public BetterSettings (string schema_id) {
		Object (schema_id: schema_id);
		this.children = new Gee.HashMap<string, BetterSettings> ();
	}

	public BetterSettings.with_backend_and_path (string schema_id, SettingsBackend backend, string path) {
		Object (schema_id: schema_id, backend: backend, path: path);
		this.children = new Gee.HashMap<string, BetterSettings> ();
	}

	public BetterSettings get_child_for_same_backend (string name) {
		var child_for_default_backend = get_child (name);
		var child_schema_id = child_for_default_backend.schema_id;
		var child_path = child_for_default_backend.path;
		var child = new BetterSettings.with_backend_and_path (child_schema_id, backend, child_path);
		return child;
	}

	public BetterSettings get_child_for_same_backend_cached (string name) {
		var child = children [name];
		if (child == null) {
			child = get_child_for_same_backend (name);
			children[name] = child;
		}
		return child;
	}
	
	public void set_from_json_object (Json.Object source_object) {
		foreach (var target_key in list_keys ()) {
			var source_key = target_key.replace ("-", "_");
			if (!source_object.has_member (source_key)) {
				stdout.printf (@"source object has no member with key $(source_key)\n");
				continue;
			}
			var source_member = source_object.get_member (source_key);
			if (source_member.get_node_type () != Json.NodeType.VALUE) {
				stdout.printf (@"source member with key $(source_key) is not a value\n");
				continue;
			}
			var target_type = get_value (target_key).get_type ();
			if (target_type.equal (VariantType.STRING)) {
				var source_value = source_member.get_string ();
				set_string (target_key, source_value);
			} else if (target_type.equal (VariantType.INT32)) {
				var source_type = source_member.get_value_type ();
				if (source_type.is_a (typeof (string))) {
					var source_string_value = source_member.get_string ();
					var source_int_value = int.parse (source_string_value);
					set_int (target_key, source_int_value);
				} else if (source_type.is_a (typeof (int64))) {
					var source_value = (int) source_member.get_int ();
					set_int (target_key, source_value);
				} else {
					assert_not_reached ();
				}
			} else if (target_type.equal (VariantType.BOOLEAN)) {
				var source_type = source_member.get_value_type ();
				if (source_type.is_a (typeof (int64))) {
					var source_bool_value = source_member.get_int () != 0;
					set_boolean (target_key, source_bool_value);
				} else {
					assert_not_reached ();
				}
			}	
		}
	}
	
	public void apply_recursively () {
		apply ();
		foreach (var key in list_keys ()) {
			var child_settings = get_child_for_same_backend_cached (key);
			child_settings.apply_recursively ();
		}
	}

	public void delay_recursively () {
		delay ();
		foreach (var key in list_keys ()) {
			var child_settings = get_child_for_same_backend_cached (key);
			child_settings.delay_recursively ();
		}
	}

	public bool get_has_unapplied_recursively () {
		if (get_has_unapplied ()) {
			return true;
		}
		foreach (var key in list_keys ()) {
			var child_settings = get_child_for_same_backend_cached (key);
			if (child_settings.get_has_unapplied_recursively ()) {
				return true;
			}
		}
		return false;
	}

}

public class Lottanzb.SABnzbdRootSettings : BetterSettings {

	private static const string SCHEMA_ID = "apps.lottanzb.backend.sabnzbdplus";
	private static const string PATH = "/apps/lottanzb/backend/sabnzbdplus";

	public SABnzbdRootSettings (SettingsBackend backend) {
		base.with_backend_and_path (SCHEMA_ID, backend, PATH);	
	}

}
