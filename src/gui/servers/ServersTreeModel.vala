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

public class Lottanzb.ServersTreeModel : Gtk.TreeModel, Object {

	private SabnzbdServersSettings servers;

	public ServersTreeModel (SabnzbdServersSettings servers) {
		this.servers = servers;
		for (var index = 0; index < servers.size; index++) {
			var server = servers.get_shared_server (index);
			connect_to_change (server, index);
		}
	}

	private void connect_to_change (BetterSettings server, int index) {
		server.change_event.connect ((server, keys) => {
			var path = new Gtk.TreePath.from_indices (index);
			Gtk.TreeIter iter;
			bool is_valid_iter = get_iter (out iter, path);
			assert (is_valid_iter);
			row_changed	(path, iter);
			return false;
		});
	}

	public Type get_column_type (int index) {
		return typeof (BetterSettings);
	}

	public Gtk.TreeModelFlags get_flags () {
		return Gtk.TreeModelFlags.ITERS_PERSIST | Gtk.TreeModelFlags.LIST_ONLY;
	}

	public bool get_iter (out Gtk.TreeIter iter, Gtk.TreePath path) {
		iter = Gtk.TreeIter ();
		var index = path.get_indices ()[0];
		if (0 <= index && index < servers.size) {
			iter.user_data = (void *) index;
			return true;
		} else {
			return false;
		}
	}

	public int get_n_columns () {
		return 1;
	}

	public Gtk.TreePath? get_path (Gtk.TreeIter iter) {
		var index = (int) iter.user_data;
		if (0 <= index && index < servers.size) {
			var path = new Gtk.TreePath.from_indices (index);
			return path;
		} else {
			return null;
		}
	}

	public void get_value (Gtk.TreeIter iter, int column, out Value value) {
		value = Value (typeof (BetterSettings));
		if (column == 0) {
			var index = (int) iter.user_data;
			if (0 <= index && index < servers.size) {
				var server = servers [index];
				value.set_object (server);
			}
		}
	}

	public bool iter_children (out Gtk.TreeIter iter, Gtk.TreeIter? parent) {
		iter = Gtk.TreeIter ();
		if (parent == null) {
			iter.user_data = (void *) 0;
			return true;
		} else {
			return false;
		}
	}

	public bool iter_has_child (Gtk.TreeIter iter) {
		return false;
	}

	public int iter_n_children (Gtk.TreeIter? iter) {
		if (iter == null) {
			return servers.size;
		} else {
			return 0;
		}
	}

	public bool iter_next (ref Gtk.TreeIter iter) {
		var index = (int) iter.user_data;
		if (index < servers.size - 1) {
			iter.user_data = (void *) (((int) iter.user_data) + 1);
			return true;
		} else {
			return false;
		}
	}

	public bool iter_nth_child (out Gtk.TreeIter iter, Gtk.TreeIter? parent, int index) {
		iter = Gtk.TreeIter ();
		if (parent == null && 0 <= index && index < servers.size) {
			iter.user_data = (void *) index;
			return true;
		} else {
			return false;
		}
	}

	public bool iter_parent (out Gtk.TreeIter iter, Gtk.TreeIter child) {
		iter = Gtk.TreeIter ();
		return false;
	}

	public BetterSettings? get_server (Gtk.TreeIter iter) {
		BetterSettings? server = null;
		get (iter, 0, out server);
		return server;
	}

}
