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

public class Lottanzb.AboutDialog : AbstractAboutDialog {

	public void run (Gtk.Window? window = null) {
		if (window != null) {
			widgets.about_dialog.set_transient_for (window);
		}
		widgets.about_dialog.set_version (LottanzbConfig.VERSION);
		try {
			var resource = LottanzbResource.get_resource ();
			var logo_stream = resource.open_stream ("/org/lottanzb/gui/logo.png", ResourceLookupFlags.NONE);
			var logo = new Gdk.Pixbuf.from_stream (logo_stream);
			widgets.about_dialog.set_logo (logo);
		} catch (Error e) {
			warning ("Could not load application logo: %s", e.message);
		}
		widgets.about_dialog.show_all ();
		widgets.about_dialog.run ();
		widgets.about_dialog.destroy ();
	}

}
