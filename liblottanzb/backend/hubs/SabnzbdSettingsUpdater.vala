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

public class Lottanzb.SabnzbdSettingsUpdater : Object {

	public SabnzbdRootSettings root { get; construct set; }
	public BetterSettings active { get; private set; }
	public Gee.List<SabnzbdSettingsTransformation> transformations { get; construct set; }

	public SabnzbdSettingsUpdater (SabnzbdRootSettings root) {
		this.root = root;
		this.active = root;
		this.transformations = new Gee.ArrayList<SabnzbdSettingsTransformation> ();
	}

	public void update (Json.Object object)
		requires (root == active)
		ensures (root == active) {
		visit_json_object (object);
	}

	private void visit_json_node (Json.Node node) {
		if (node.get_node_type () == Json.NodeType.OBJECT) {
			visit_json_object (node.get_object ());
		} else if (node.get_node_type () == Json.NodeType.ARRAY) {
			visit_json_array (node.get_array ());
		} else {
			warning ("cannot use json node of type %s for '%s'",
				node.get_node_type ().to_string (), active.path);
		}
	}

	private void visit_json_object (Json.Object object) {
		set_all_from_json_object (object);
		var parent_settings = active;
		foreach (var child_name in parent_settings.list_children ()) {
			active = parent_settings.get_child (child_name);
			var json_key = child_name_to_json_key (child_name);
			if (object.has_member (json_key)) {
				var child_node = object.get_member (json_key);
				visit_json_node (child_node);
			} else {
				warning ("no json object for '%s'", active.path);
			}
		}
		active = parent_settings;
	}

	private void visit_json_array (Json.Array array) {
		var active_list = active as SettingsList;
		if (active_list == null) {
			warning ("cannot use json array for '%s'", active.path);
		} else {
			active_list.size = (int) array.get_length ();
			for (var index = 0; index < active_list.size; index++) {
				active = active_list.get_child_by_index (index);
				if (index < array.get_length ()) {
					var object = array.get_object_element (index);
					set_all_from_json_object (object);
				}
			}
			active = active_list;
		}
	}

	private void set_all_from_json_object (Json.Object object) {
		foreach (var key in active.list_keys ()) {
			var json_key = key_to_json_key (key);
			if (object.has_member (json_key)) {
				var child_node = object.get_member (json_key);
				set_from_json_node (key, child_node);
			} else {
				warning ("no json member for key '%s' in '%s'", key, active.path);
			}
		}
	}

	private void set_from_json_node (string key, Json.Node node) {
		Variant variant;
		VariantType variant_type = active.get_value (key).get_type();
		var is_valid = json_node_to_variant (node, variant_type, out variant);
		if (is_valid) {
			foreach (var transformation in transformations) {
				transformation.transform (active, key, variant, out variant);
			}
			active.set_value (key, variant);
		} else {
			warning ("invalid json value for key '%s' in '%s'", key, active.path);
		}
	}

	private string key_to_json_key (string key) {
		var json_key = key.replace ("-", "_");
		return json_key;
	}

	private string child_name_to_json_key (string child_name) {
		var json_key = child_name.replace ("-", "_");
		return json_key;
	}

	private bool json_node_to_variant (Json.Node source_node,
			VariantType target_type, out Variant target_variant) {
		target_variant = null;
		var source_node_type = source_node.get_node_type ();
		var is_valid = false;
		switch (source_node_type) {
			case Json.NodeType.VALUE:
				is_valid = json_value_node_to_variant (source_node,
						target_type, out target_variant);
				break;
			case Json.NodeType.ARRAY:
				is_valid = json_array_node_to_variant (source_node,
						target_type, out target_variant);
				break;
			default:
				break;
		}
		return is_valid;
	}

	private bool json_value_node_to_variant (Json.Node source_node,
			VariantType target_type, out Variant target_variant)
		requires (source_node.get_node_type () == Json.NodeType.VALUE) {
		target_variant = null;
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

	private bool json_array_node_to_variant (Json.Node source_node,
			VariantType target_type, out Variant target_variant)
		requires (source_node.get_node_type () == Json.NodeType.ARRAY) {
		target_variant = null;
		var is_valid = true;
		var is_string_array = target_type.is_array () &&
			target_type.element ().equal (VariantType.STRING);
		if (is_string_array) {
			var source_array = source_node.get_array ();
			var target_value = new string [source_array.get_length ()];
			for (var index = 0; index < source_array.get_length (); index++) {
				var source_element_node = source_array.get_element (index);
				Variant target_element_variant;
				var is_valid_element = json_node_to_variant (source_element_node,
					VariantType.STRING,	out target_element_variant);
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

}

public interface Lottanzb.SabnzbdSettingsTransformation : Object {

	public abstract void transform (BetterSettings active, string key,
			Variant variant, out Variant transformed_variant);

}
