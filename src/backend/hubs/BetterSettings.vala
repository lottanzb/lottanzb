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

}

public class Lottanzb.SABnzbdRootSettings : BetterSettings {

	private static const string SCHEMA_ID = "apps.lottanzb.backend.sabnzbdplus";
	private static const string PATH = "/apps/lottanzb/backend/sabnzbdplus";

	public SABnzbdRootSettings (SettingsBackend backend) {
		base.with_backend_and_path (SCHEMA_ID, backend, PATH);	
	}

}
