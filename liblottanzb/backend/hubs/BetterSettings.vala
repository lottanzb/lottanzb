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

public interface Lottanzb.Copyable<T> {

	public abstract T get_copy ();

}

public class Lottanzb.BetterSettings : Settings, Copyable<BetterSettings> {

	private Gee.Map<string, BetterSettings> children = new Gee.HashMap<string, BetterSettings> ();

	public BetterSettings (string schema_id) {
		Object (schema_id: schema_id);
	}

	public BetterSettings.with_backend (string schema_id, SettingsBackend backend) {
		Object (schema_id: schema_id, backend: backend);
	}

	public BetterSettings.with_backend_and_path (string schema_id, SettingsBackend backend, string path) {
		Object (schema_id: schema_id, backend: backend, path: path);
	}

	public new virtual BetterSettings get_child (string name) {
		var child = children [name];
		if (child == null) {
			string child_schema_id, child_path;
			get_child_schema_id_and_path (name, out child_schema_id, out child_path);
			child = make_child (name, child_schema_id, child_path);
			children [name] = child;
		}
		return child;
	}

	protected virtual BetterSettings make_child (string name, string child_schema_id, string child_path) {
		var child = new BetterSettings.with_backend_and_path (child_schema_id, backend, child_path);
		return child;
	}

	public void set_child (string name, BetterSettings child_settings)
		requires (!(children.has_key (name)) && is_valid_child_settings (name, child_settings))
		ensures (children.has_key (name) && children[name] == child_settings) {
		children[name] = child_settings;
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

	public BetterSettings get_copy () {
		return new BetterSettings.with_backend_and_path (schema_id, backend, path);
	}

	public void reset_all () {
		foreach (var key in list_keys ()) {
			reset (key);
		}
	}

	public void apply_recursively () {
		apply ();
		foreach (var child_name in list_children ()) {
			var child_settings = get_child (child_name);
			child_settings.apply_recursively ();
		}
	}

	public void delay_recursively () {
		foreach (var child_name in list_children ()) {
			var child_settings = get_child (child_name);
			child_settings.delay_recursively ();
		}
		delay ();
	}

	public bool get_has_unapplied_recursively () {
		if (get_has_unapplied ()) {
			return true;
		}
		foreach (var child_name in list_children ()) {
			var child_settings = get_child (child_name);
			if (child_settings.get_has_unapplied_recursively ()) {
				return true;
			}
		}
		return false;
	}

	public void revert_recursively () {
		foreach (var child_name in list_children ()) {
			var child_settings = get_child (child_name);
			child_settings.revert ();
		}
		revert ();
	}

	public static SettingsBackend build_memory_settings_backend () {
		// Ensure that the Gio modules extension points have been registered,
		// such that the memory settings backend can be instantiated.
		g_settings_backend_get_default ();
		var settings_backend = g_memory_settings_backend_new ();
		return settings_backend;
	}

}
