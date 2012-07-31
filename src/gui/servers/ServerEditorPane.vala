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

public class Lottanzb.ServerEditorPane : AbstractServerEditorPane {

	public BetterSettings server { get; construct set; }

	public ServerEditorPane (BetterSettings server) {
		base ();
		this.server = server;
		widgets.window.remove (widget);
		widgets.enable.notify["active"].connect ((widget, prop) => {
			widgets.table1.sensitive = widgets.enable.active;
		});

		var bind_flags = SettingsBindFlags.GET | SettingsBindFlags.SET;
		server.bind ("host", widgets.host, "text", bind_flags);
		server.bind ("port", widgets.port, "value", bind_flags);
		server.bind ("password", widgets.password, "text", bind_flags);
		server.bind ("username", widgets.username, "text", bind_flags);
		server.bind ("ssl", widgets.ssl, "active", bind_flags);
		server.bind ("connections", widgets.connections, "value", bind_flags);
		server.bind ("enable", widgets.enable, "active", bind_flags);
		
		widgets.port.bind_property ("value", widgets.ssl, "active", BindingFlags.BIDIRECTIONAL,
			(binding, source_value, ref target_value) => {
				// When the port changes
				var port = (int) source_value.get_double ();
				var is_default_port = DefaultServerPort.is_in_default_ports (port);
				if (is_default_port) {
					var ssl = ((DefaultServerPort) port).to_ssl ();
					target_value.set_boolean (ssl);
					return true;
				} else {
					return false;
				}
			},
			(binding, source_value, ref target_value) => {
				// When the SSL switch changes
				var ssl = source_value.get_boolean ();
				var old_port = (int) widgets.port.get_value ();
				var is_old_port_default = DefaultServerPort.is_default_port (old_port, !ssl);
				if (is_old_port_default) {
					var new_port = DefaultServerPort.from_ssl (ssl);
					target_value.set_double ((double) new_port);
					return true;
				} else {
					return false;
				}
			}
		);
	}

	public Gtk.Widget widget {
		get {
			return widgets.server_editor_pane;
		}
	}

}
