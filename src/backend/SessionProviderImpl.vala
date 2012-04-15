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


public class Lottanzb.SessionProviderImpl : Object, SessionProvider {

	private ConfigProvider config_provider;
	private Settings backend_settings;
	
	public SessionProviderImpl (ConfigProvider config_provider) {
		this.config_provider = config_provider;
		this.backend_settings = config_provider.lottanzb_config.get_child (Backend.SETTINGS_KEY);
	}

	public Session? build_session () {
		var active_session_name = backend_settings.get_string ("active-session");
		switch (active_session_name) {
			case "local":
				return new LocalSession (config_provider);
			case "remote":
				return new RemoteSession (config_provider);
			default:
				assert_not_reached ();
		}
	}
	
}
