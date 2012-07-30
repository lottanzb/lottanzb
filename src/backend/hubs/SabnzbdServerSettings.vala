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

public class Lottanzb.SabnzbdServerSettings : BetterSettings {

	public SabnzbdServerSettings (string schema_id) {
		Object (schema_id: schema_id);
	}

	public SabnzbdServerSettings.with_backend (string schema_id, SettingsBackend backend) {
		Object (schema_id: schema_id, backend: backend);
	}

	public SabnzbdServerSettings.with_backend_and_path (string schema_id, SettingsBackend backend, string path) {
		Object (schema_id: schema_id, backend: backend, path: path);
	}

	public bool requires_authentication {
		get {
			return get_string ("username").length > 0 && get_string ("password").length > 0;
		}
	}
	
	public new SabnzbdServerSettings get_copy () {
		var server = new SabnzbdServerSettings.with_backend_and_path (schema_id, backend, path);
		return server;
	}

}