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

[CCode (cprefix = "", lower_case_cprefix = "", cheader_filename = "data/lottanzb.gresource.h")]
namespace LottanzbResource {

	[CCode (cname = "lottanzb_get_resource")]
	public static GLib.Resource get_resource ();
	
	[CCode (cname = "gtk_list_store_reorder")]
	public void reorder (Gtk.ListStore list_store,
		[CCode (array_length = false)] int[] new_order);

	[CCode (cname = "gtk_list_store_move_before")]
	public void move_before (Gtk.ListStore list_store, Gtk.TreeIter iter, Gtk.TreeIter? position);

	[CCode (cname = "gtk_list_store_move_after")]
	public void move_after (Gtk.ListStore list_store, Gtk.TreeIter iter, Gtk.TreeIter? position);

}

