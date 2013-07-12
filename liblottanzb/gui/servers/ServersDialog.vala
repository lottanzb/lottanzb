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

	private ServerList servers;
	private ServerTreeModel model;
	private ServerEditorPane? server_editor_pane;

	public ServersDialog (ServerList servers) {
		base ();

		this.servers = servers.get_copy ();
		this.servers.delay_recursively ();
		this.model = new ServerTreeModel (servers);
		widgets.tree_view.set_model (model);
		widgets.tree_view.append_column (new ServerColumn ());
		widgets.tree_view.get_selection ().set_mode (Gtk.SelectionMode.BROWSE);
		widgets.tree_view.get_selection ().changed.connect ((selection) => {
			debug ("Server selection has changed");
			update_server_editor_pane ();
		});

		update_server_editor_pane ();

		this.model.row_inserted.connect ((model, iter, path) => {
			update_add_server_sensitivity ();
		});
		this.model.row_deleted.connect ((model, path) => {
			update_add_server_sensitivity ();
		});
		update_add_server_sensitivity ();

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

	private void update_server_editor_pane () {
		if (server_editor_pane != null) {
			widgets.server_editor_pane_container.remove (server_editor_pane.widget);
			server_editor_pane = null;
			debug ("Old server editor pane destroyed");
		}

		var selected_server = get_selected_server ();
		if (selected_server != null) {
			server_editor_pane = new ServerEditorPane (selected_server);
			widgets.server_editor_pane_container.child = server_editor_pane.widget;
			debug ("New server editor pane created");
		}

		debug ("Server editor pane updated");
	}

	private BetterSettings? get_selected_server () {
		var index = get_selected_server_index ();
		if (index >= 0) {
			return servers.get_child_by_index (index);
		}
		return null;
	}

	private int get_selected_server_index () {
		var selection = widgets.tree_view.get_selection ();
		if (selection != null) {
			Gtk.TreeIter? iter;
			bool has_selected_server = selection.get_selected (null, out iter);
			if (has_selected_server) {
				var path = model.get_path (iter);
				var index = path.get_indices ()[0];
				return index;
			}
		}
		return -1;
	}

	private void set_selected_server_index (int index) {
		var selection = widgets.tree_view.get_selection ();
		if (selection != null) {
			debug ("Selecting server %d...", index);
			var path = new Gtk.TreePath.from_indices (index);
			selection.select_path (path);
		}
	}

	[CCode (instance_pos = -1)]
	public void on_response (Gtk.Dialog dialog, Gtk.ResponseType response) {
		switch (response) {
			case Gtk.ResponseType.APPLY:
				servers.remove_empty_children ();
				servers.apply_recursively ();
				break;
			case Gtk.ResponseType.CLOSE:
				servers.revert_recursively ();
				dialog.hide ();
				break;
			case Gtk.ResponseType.HELP:
				break;
			default:
				break;
		}
	}

	[CCode (instance_pos = -1)]
	public void on_add_server_activate (Gtk.Action action) {
		servers.add_child ();
		set_selected_server_index (servers.size - 1);
		server_editor_pane.widgets.host.grab_focus ();
	}

	[CCode (instance_pos = -1)]
	public void on_remove_server_activate (Gtk.Action action) {
		var index = get_selected_server_index ();
		if (index >= 0) {
			servers.remove_child (index);
			var new_selected_server_index = int.min (servers.size - 1, index);
			if (0 <= new_selected_server_index) {
				set_selected_server_index (new_selected_server_index);
			}
		}
	}

	[CCode (instance_pos = -1)]
	public void on_tree_selection_changed (Gtk.TreeSelection selection) {
		var has_selected_server = 0 <= get_selected_server_index ();
		widgets.remove_server.sensitive = has_selected_server;
	}

	public void update_add_server_sensitivity () {
		widgets.add_server.sensitive = !servers.is_full;
	}

}

