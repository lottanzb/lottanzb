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

public abstract class Lottanzb.SettingsList : BetterSettings, Copyable<SettingsList> {

	public static string SIZE_KEY = "size";

	public int max_size { get; private construct set; default = 20; }

	public SettingsList (string schema_id) {
		Object (schema_id: schema_id);
		changed [SIZE_KEY].connect (on_size_changed);
	}

	public SettingsList.with_backend (string schema_id, SettingsBackend backend) {
		Object (schema_id: schema_id, backend: backend);
		changed [SIZE_KEY].connect (on_size_changed);
	}

	public SettingsList.with_backend_and_path (string schema_id, SettingsBackend backend, string path) {
		Object (schema_id: schema_id, backend: backend, path: path);
		changed [SIZE_KEY].connect (on_size_changed);
	}

	public int size {
		get {
			return get_int (SIZE_KEY);
		}
		set {
			set_int (SIZE_KEY, value);
		}
	}

	private void on_size_changed (Settings settings, string key) {
		var size = get_int (SIZE_KEY);
		if (max_size < size) {
			warning ("support for at most %d children", max_size);
			size = max_size;
		} else {
			for (var invalid_index = size; invalid_index < max_size; invalid_index++) {
				var invalid_child = get_child_by_index (invalid_index);
				invalid_child.reset_all ();
			}
		}
	}

	public virtual BetterSettings get_child_by_index (int index) {
		var child = get_child (index_to_key (index));
		return child;
	}

	public bool is_full {
		get {
			return size == max_size;
		}
	}

	public BetterSettings get_child_by_identifier (string identifier) {
		for (var index = 0; index < size; index++) {
			var child = get_child_by_index (index);
			var child_identifier = get_child_identifier (child);
			if (identifier == child_identifier) {
				return child;
			}
		}
		assert_not_reached ();
	}

	public void remove_child (int index)
		requires (0 <= index && index < size) {
		for (; index < size - 1; index++) {
			var target_child = get_child_by_index (index);
			var source_child = get_child_by_index (index + 1);
			foreach (var key in target_child.list_keys ()) {
				var source_value = source_child.get_value (key);
				target_child.set_value (key, source_value);
			}
		}
		var last_child = get_child_by_index (size - 1);
		last_child.reset_all ();
		size--;
	}


	public void remove_empty_children () {
		for (var index = 0; index < size; index++) {
			var child = get_child_by_index (index);
			var child_identifier = get_child_identifier (child);
			if (child_identifier.length == 0) {
				remove_child (index);
			}
		}
	}

	public void add_child ()
		requires (!is_full) {
		size++;
	}

	/**
	 * Whether a particular setting only exists in the context of LottaNZB.
	 * @return true in the case of the 'size' key
	*/
	public override bool is_internal (string key) {
		return key == SIZE_KEY;
	}

	protected abstract string get_child_identifier (BetterSettings child);

	protected abstract string index_to_key (int index);

}
