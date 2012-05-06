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

public class Lottanzb.SabnzbdRootSettings : BetterSettings, Copyable<SabnzbdRootSettings> {

	private static const string SCHEMA_ID = "apps.lottanzb.backend.sabnzbdplus";
	private static const string PATH = "/apps/lottanzb/backend/sabnzbdplus/";
	private static const string MISC_CHILD_NAME = "misc";
	private static const string SERVERS_CHILD_NAME = "servers";

	public SabnzbdRootSettings (SettingsBackend backend) {
		base.with_backend_and_path (SCHEMA_ID, backend, PATH);
		string child_schema_id, child_path;
		get_child_schema_id_and_path (SERVERS_CHILD_NAME, out child_schema_id, out child_path);
		var servers = new SabnzbdServersSettings.with_backend_and_path (child_schema_id, backend, child_path);
		set_child (SERVERS_CHILD_NAME, servers);
	}
	
	public BetterSettings get_misc () {
		return get_child (MISC_CHILD_NAME);
	}

	public SabnzbdServersSettings get_servers () {
		return get_child (SERVERS_CHILD_NAME) as SabnzbdServersSettings;
	}

	public new SabnzbdRootSettings get_copy () {
		return new SabnzbdRootSettings (backend);
	}

}
