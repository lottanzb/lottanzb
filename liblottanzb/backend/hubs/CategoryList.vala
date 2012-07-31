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

public class Lottanzb.CategoryList : SettingsList, Copyable<CategoryList> {

	public static string ANY_CATEGORY_NAME = "*";

	public CategoryList (string schema_id) {
		Object (schema_id: schema_id);
	}

	public CategoryList.with_backend (string schema_id, SettingsBackend backend) {
		Object (schema_id: schema_id, backend: backend);
	}

	public CategoryList.with_backend_and_path (string schema_id, SettingsBackend backend, string path) {
		Object (schema_id: schema_id, backend: backend, path: path);
	}

	protected override string get_child_identifier (BetterSettings category) {
		return category.get_string ("name");
	}

	protected override string index_to_key (int index) {
		return @"category$(index)";
	}

	public new CategoryList get_copy () {
		var categories = new CategoryList.with_backend_and_path (schema_id, backend, path);
		return categories;
	}

	public BetterSettings get_any_category () {
		return get_child_by_identifier (ANY_CATEGORY_NAME);
	}

}
