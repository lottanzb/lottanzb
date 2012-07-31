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

public enum Lottanzb.DefaultServerPort {

	WITHOUT_SSL = 119,
	WITH_SSL = 563;

	public bool to_ssl () {
		switch (this) {
			case WITHOUT_SSL:
				return false;
			case WITH_SSL:
				return true;
			default:
				assert_not_reached ();
		}
	}

	public static DefaultServerPort from_ssl (bool ssl) {
		if (ssl) {
			return DefaultServerPort.WITH_SSL;
		} else {
			return DefaultServerPort.WITHOUT_SSL;
		}
	}

	public static bool is_default_port (int port, bool ssl) {
		return
			is_in_default_ports (port) &&
			((DefaultServerPort) port).to_ssl () == ssl;
	}

	public static bool is_in_default_ports (int port) {
		return port == WITHOUT_SSL || port == WITH_SSL;
	}

}

public class Lottanzb.Server : BetterSettings {

	public Server (string schema_id) {
		Object (schema_id: schema_id);
	}

	public Server.with_backend (string schema_id, SettingsBackend backend) {
		Object (schema_id: schema_id, backend: backend);
	}

	public Server.with_backend_and_path (string schema_id, SettingsBackend backend, string path) {
		Object (schema_id: schema_id, backend: backend, path: path);
	}

	public bool requires_authentication {
		get {
			return get_string ("username").length > 0 && get_string ("password").length > 0;
		}
	}

	public new Server get_copy () {
		var server = new Server.with_backend_and_path (schema_id, backend, path);
		return server;
	}

}
