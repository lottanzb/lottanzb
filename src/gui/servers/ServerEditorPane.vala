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
	}

	public Gtk.Widget widget {
		get {
			return widgets.server_editor_pane;
		}
	}

	[CCode (instance_pos = -1)]
	public void on_ssl_toggled (Gtk.ToggleButton widget) {
		if (widget.active && server.get_int ("port") == 119) {
			server.set_int ("port", 563);
		}
		if (!widget.active && server.get_int ("port") == 563) {
			server.set_int ("port", 119);
		}
	}

}
