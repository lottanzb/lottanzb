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


public class Lottanzb.RemoteSession : Object, Session {

	private static string SETTINGS_KEY = "remote";
	private static string SETTINGS_HOST_KEY = "host";
	private static string SETTINGS_PORT_KEY = "port";
	private static string SETTINGS_USERNAME_KEY = "username";
	private static string SETTINGS_PASSWORD_KEY = "password";
	private static string SETTINGS_API_KEY_KEY = "api-key";
	private static string SETTINGS_HTTPS_KEY = "https";

	public QueryProcessor _query_processor;
	
	public QueryProcessor query_processor {
		get { return _query_processor; }
	}
	
	public RemoteSession (ConfigProvider config_provider) {
		var settings = config_provider.lottanzb_config;
		var backend_settings = settings.get_child (Backend.SETTINGS_KEY);
		var session_settings = backend_settings.get_child (SETTINGS_KEY);
		var host = session_settings.get_string (SETTINGS_HOST_KEY);
		var port = session_settings.get_int (SETTINGS_PORT_KEY);
		var username = session_settings.get_string (SETTINGS_USERNAME_KEY);
		var password = session_settings.get_string (SETTINGS_PASSWORD_KEY);
		var api_key = session_settings.get_string (SETTINGS_API_KEY_KEY);
		var https = session_settings.get_boolean (SETTINGS_HTTPS_KEY);
		var connection_info = new ConnectionInfo (host, port, username, password, api_key, https);
		_query_processor = new QueryProcessorImpl (connection_info);
	}

}
