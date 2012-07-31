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

public class Lottanzb.ServerList : SettingsList, Copyable<ServerList> {

	public ServerList (string schema_id) {
		Object (schema_id: schema_id);
	}

	public ServerList.with_backend (string schema_id, SettingsBackend backend) {
		Object (schema_id: schema_id, backend: backend);
	}

	public ServerList.with_backend_and_path (string schema_id, SettingsBackend backend, string path) {
		Object (schema_id: schema_id, backend: backend, path: path);
	}

	protected override BetterSettings make_child (string name, string child_schema_id, string child_path) {
		var child = new Server.with_backend_and_path (child_schema_id, backend, child_path);
		return child;
	}

	protected override string get_child_identifier (BetterSettings server) {
		return server.get_string ("host");
	}

	protected override string index_to_key (int index) {
		return @"server$(index)";
	}

	public new ServerList get_copy () {
		var servers = new ServerList.with_backend_and_path (schema_id, backend, path);
		return servers;
	}

}
