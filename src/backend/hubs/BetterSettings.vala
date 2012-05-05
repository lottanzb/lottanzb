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
extern SettingsBackend g_settings_backend_get_default ();

public class Lottanzb.BetterSettings : Settings {

	private Gee.Map<string, BetterSettings> shared_children = new Gee.HashMap<string, BetterSettings> ();

	public BetterSettings (string schema_id) {
		Object (schema_id: schema_id);
	}

	public BetterSettings.with_backend (string schema_id, SettingsBackend backend) {
		Object (schema_id: schema_id, backend: backend);
	}

	public BetterSettings.with_backend_and_path (string schema_id, SettingsBackend backend, string path) {
		Object (schema_id: schema_id, backend: backend, path: path);
	}

	public new BetterSettings get_child (string name) {
		string child_schema_id, child_path;
		get_child_schema_id_and_path (name, out child_schema_id, out child_path);
		var child = new BetterSettings.with_backend_and_path (child_schema_id, backend, child_path);
		return child;
	}

	public BetterSettings get_shared_child (string name) {
		var child = shared_children [name];
		if (child == null) {
			child = get_child (name);
			shared_children[name] = child;
		}
		return child;
	}

	public void set_shared_child (string name, BetterSettings child_settings)
		requires (!(shared_children.has_key (name)) && is_valid_child_settings (name, child_settings))
		ensures (shared_children.has_key (name) && shared_children[name] == child_settings) {
		shared_children[name] = child_settings;	
	}

	protected void get_child_schema_id_and_path (string name, out string child_schema_id, out string child_path) {
		var child_for_default_backend = ((Settings) this).get_child (name);
		child_schema_id = child_for_default_backend.schema_id;
		child_path = child_for_default_backend.path;
	}

	protected bool is_valid_child_settings (string name, BetterSettings child_settings) {
		string child_schema_id, child_path;
		get_child_schema_id_and_path (name, out child_schema_id, out child_path);
		var result =
			child_settings.schema_id == child_schema_id &&
			child_settings.path == child_path &&
			child_settings.backend == backend;
		return result;	
	}

	public virtual void set_recursively_from_json_node (Json.Node node) {
		if (node.get_node_type () == Json.NodeType.OBJECT) {
			var object = node.get_object ();
			set_recursively_from_json_object (object);
		} else if (node.get_node_type () == Json.NodeType.ARRAY) {
			var array = node.get_array ();
			set_recursively_from_json_array (array);
		} else {
			stdout.printf (get_type ().name () + "\n");
			warning ("cannot use json node of type %s for '%s'",
				node.get_node_type ().to_string (), path);
		}
	}

	public void set_recursively_from_json_object (Json.Object object) {
		set_all_from_json_object (object);	
		foreach (var child_name in list_children ()) {
			var child_settings = get_shared_child (child_name);
			var json_key = child_name_to_json_key (child_name);
			if (object.has_member (json_key)) {
				var child_node = object.get_member (json_key); 
				child_settings.set_recursively_from_json_node (child_node);
			} else {
				warning ("no json object for '%s'", child_settings.path);
			}
		}
	}
	
	public virtual void set_recursively_from_json_array (Json.Array array) {
		warning ("cannot use json array for '%s'", path);	
	}

	public void set_all_from_json_node (Json.Node node) {
		if (node.get_node_type () == Json.NodeType.OBJECT) {
			var object = node.get_object ();
			set_all_from_json_object (object);
		} else {
			warning ("json node for '%s' is of type %s rather than %s", path,
				node.get_node_type ().to_string (), Json.NodeType.OBJECT.to_string ());
		}
	}

	public void set_all_from_json_object (Json.Object object) {
		foreach (var key in list_keys ()) {
			var json_key = key_to_json_key (key);
			if (object.has_member (json_key)) {
				var child_node = object.get_member (json_key);
				set_from_json_node (key, child_node);
			} else {
				warning ("no json member for key '%s' in '%s'", key, path);
			}
		}
	}

	public void set_from_json_node (string key, Json.Node node) {
		Variant variant;
		VariantType variant_type = get_value (key).get_type();
		var is_valid = json_node_to_variant (node, variant_type, out variant);
		if (is_valid) {
			set_value (key, variant);
		} else {
			warning ("invalid json value for key '%s' in '%s'", key, path);
		}
	}

	protected string key_to_json_key (string key) {
		var json_key = key.replace ("-", "_");	
		return json_key;
	}

	protected string child_name_to_json_key (string child_name) {
		var json_key = child_name.replace ("-", "_");	
		return json_key;
	}

	private bool json_node_to_variant (Json.Node source_node, VariantType target_type, out Variant target_variant) {
		var source_node_type = source_node.get_node_type ();
		var is_valid = false;
		switch (source_node_type) {
			case Json.NodeType.VALUE:
				is_valid = json_value_node_to_variant (source_node, target_type, out target_variant);
				break;
			case Json.NodeType.ARRAY:
				is_valid = json_array_node_to_variant (source_node, target_type, out target_variant);
				break;
			default:
				break;
		}
		return is_valid;
	}

	private bool json_value_node_to_variant (Json.Node source_node, VariantType target_type, out Variant target_variant)
		requires (source_node.get_node_type () == Json.NodeType.VALUE) {
		var source_value_type = source_node.get_value_type ();
		var is_valid = false;
		if (target_type.equal (VariantType.STRING)) {
			var source_value = source_node.get_string ();
			target_variant = new Variant.string (source_value);
			is_valid = true;
		} else if (target_type.equal (VariantType.INT32)) {
			if (source_value_type.is_a (typeof (string))) {
				var source_string_value = source_node.get_string ();
				var source_value = int.parse (source_string_value);
				target_variant = new Variant.int32 (source_value);
				is_valid = true;
			} else if (source_value_type.is_a (typeof (int64))) {
				var source_value = (int) source_node.get_int ();
				target_variant = new Variant.int32 (source_value);
				is_valid = true;
			}
		} else if (target_type.equal (VariantType.BOOLEAN)) {
			if (source_value_type.is_a (typeof (int64))) {
				var source_value = source_node.get_int () != 0;
				target_variant = new Variant.boolean (source_value);
				is_valid = true;
			}
		}
		return is_valid;
	}

	private bool json_array_node_to_variant (Json.Node source_node, VariantType target_type, out Variant target_variant)
		requires (source_node.get_node_type () == Json.NodeType.ARRAY) {
		var is_valid = true;
		if (target_type.is_array () && target_type.element ().equal (VariantType.STRING)) {
			var source_array = source_node.get_array ();
			var target_value = new string [source_array.get_length ()];
			for (var index = 0; index < source_array.get_length (); index++) {
				var source_element_node = source_array.get_element (index);
				Variant target_element_variant;
				var is_valid_element = json_node_to_variant (source_element_node, VariantType.STRING,
					out target_element_variant);
				if (is_valid_element) {
					target_value[index] = target_element_variant.get_string ();
				} else {
					is_valid = false;
				}
			}
			target_variant = new Variant.strv (target_value);
		} else {
			is_valid = false;
		}
		return is_valid;
	}

	public void apply_recursively () {
		apply ();
		foreach (var child_name in list_children ()) {
			var child_settings = get_shared_child (child_name);
			child_settings.apply_recursively ();
		}
	}

	public void delay_recursively () {
		delay ();
		foreach (var child_name in list_children ()) {
			var child_settings = get_shared_child (child_name);
			child_settings.delay_recursively ();
		}
	}

	public bool get_has_unapplied_recursively () {
		if (get_has_unapplied ()) {
			return true;
		}
		foreach (var child_name in list_children ()) {
			var child_settings = get_shared_child (child_name);
			if (child_settings.get_has_unapplied_recursively ()) {
				return true;
			}
		}
		return false;
	}

	public void revert_recursively () {
		revert ();
		foreach (var child_name in list_children ()) {
			var child_settings = get_shared_child (child_name);
			child_settings.revert ();
		}
	}

	public static SettingsBackend build_memory_settings_backend () {
		// Ensure that the Gio modules extension points have been registered,
		// such that the memory settings backend can be instantiated.
		g_settings_backend_get_default ();
		var settings_backend = g_memory_settings_backend_new ();
		return settings_backend;
	}

}
