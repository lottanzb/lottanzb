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

public class Lottanzb.ServersDialog : AbstractServersDialog {

	private ConfigHub config_hub;
	private SabnzbdServersSettings servers;
	private ServersTreeModel model;
	private ServerEditorPane? server_editor_pane;

	public ServersDialog (ConfigHub config_hub) {
		base ();
		
		this.config_hub = config_hub;
		this.servers = config_hub.root.get_servers ().get_copy ();
		this.servers.delay_recursively ();
		this.model = new ServersTreeModel (servers);
		widgets.tree_view.set_model (model);
		widgets.tree_view.append_column (new ServerColumn ());
		widgets.tree_view.get_selection ().set_mode (Gtk.SelectionMode.BROWSE);
		widgets.tree_view.get_selection ().changed.connect ((selection) => {
			update_server_editor_pane ();
		});

		update_server_editor_pane ();

		// Join the add/remove toolbar to the treeview
		Gtk.StyleContext context;
		context = widgets.scrolled_window.get_style_context ();
		context.set_junction_sides (Gtk.JunctionSides.BOTTOM);
		context = widgets.add_remove_toolbar.get_style_context ();
		context.set_junction_sides (Gtk.JunctionSides.TOP);
		context.add_class ("inline-toolbar");
	}

	public Gtk.Dialog dialog {
		get {
			return widgets.servers_dialog;
		}
	}

	public void run (Gtk.Window? window = null) {
		if (window != null) {
			widgets.servers_dialog.set_transient_for (window);
		}
		widgets.servers_dialog.show_all ();
		widgets.servers_dialog.run ();
		widgets.servers_dialog.destroy ();
	}

	private void update_server_editor_pane () {
		if (server_editor_pane != null) {
			widgets.server_editor_pane_container.remove (server_editor_pane.widget);
			server_editor_pane = null;
		}

		var selected_server = get_selected_server ();
		if (selected_server != null) {
			server_editor_pane = new ServerEditorPane (selected_server);
			widgets.server_editor_pane_container.child = server_editor_pane.widget;
		}	
	}

	private BetterSettings? get_selected_server () {
		var selection = widgets.tree_view.get_selection ();
		if (selection != null) {
			Gtk.TreeIter? iter;
			bool has_selected_server = selection.get_selected (null, out iter);
			if (has_selected_server) {
				return model.get_server (iter);
			}
		}
		return null;
	}

	[CCode (instance_pos = -1)]
	public void on_response (Gtk.Dialog dialog, Gtk.ResponseType response) {
		switch (response) {
			case Gtk.ResponseType.APPLY:
				servers.apply_recursively ();
				break;
			case Gtk.ResponseType.HELP:
				break;
			default:
				break;
		}
	}
 
}
