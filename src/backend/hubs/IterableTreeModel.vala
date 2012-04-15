/**
 * Copyright (c) 2012 Severin Heiniger <severinheiniger@gmail.com>
 * Copyright (C) 2010 Nate Stedman <natesm@gmail.com>
 
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

public interface Lottanzb.IterableTreeModel : Gtk.TreeModel {

	public Iterator iterator() {
		return new Iterator(this);
	}

	public Gtk.TreeIter index(int index) {
		Gtk.TreeIter iter;
		iter_nth_child(out iter, null, index);
		return iter;
	}

	public class Iterator {
	
		private Gtk.TreeIter iter;
		private IterableTreeModel model;
		private bool has_next;

		public Iterator(IterableTreeModel self) {
			has_next = self.get_iter_first(out iter);
			model = self;
		}

		public bool next() {
			return has_next;
		}

		public Gtk.TreeIter get() {
			var ret = iter;
			has_next = model.iter_next(ref iter);
			return ret;
		}
	}

}

