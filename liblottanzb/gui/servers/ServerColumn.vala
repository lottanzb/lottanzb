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

public class Lottanzb.ServerColumn : Gtk.TreeViewColumn {

	private Gtk.CellRendererText cell_renderer;

	public ServerColumn () {
		cell_renderer = new Gtk.CellRendererText ();
		pack_start (cell_renderer, true);
		set_cell_data_func (cell_renderer, cell_data_func);
		set_title ("");
		set_expand (true);
	}

	private void cell_data_func (Gtk.CellLayout cell_layout, Gtk.CellRenderer cell,
		Gtk.TreeModel model, Gtk.TreeIter iter) {
		ServerTreeModel server_tree_model = (ServerTreeModel) model;
		Server server = server_tree_model.get_server (iter);
		if (server != null) {
			var host = server.get_string ("host");
			var username = server.get_string ("username");
			var fillserver = server.get_boolean ("fillserver");
			var enable = server.get_boolean ("enable");
			var first_line = host;
			if (first_line.length == 0) {
				first_line = "<i>%s</i>".printf (_("New Server"));
			}
			cell_renderer.markup = first_line;
			var secondary_line = "";
			if (server.requires_authentication) {
				secondary_line = username;
			} else {
				secondary_line = _("No authentication required");
				secondary_line = @"<i>$(secondary_line)</i>";
			}
			if (fillserver) {
				first_line = _(@"$(first_line) (Backup server)");
			}
			var text = @"<b>$(first_line)</b>\n<small>$(secondary_line)</small>";
			cell_renderer.markup = text;
			cell_renderer.sensitive = enable;
		}
	}

}
