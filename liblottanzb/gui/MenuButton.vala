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

using Gtk;
using Pango;

public class Lottanzb.MenuButton : ToggleButton {

	private MenuProvider menu_provider;
	private ulong active_menu_deactivate_id = -1;
	private Gtk.Menu? active_menu;

	public MenuButton (MenuProvider provider) {
		menu_provider = provider;
		use_underline = true;
		state_changed.connect((widget, state) => {
			if (!sensitive && active_menu != null) {
				active_menu.deactivate();
			}
		});
		toggled.connect((widget) => {
			if (active) {
				popup_menu_under_button(null);
				active_menu.select_first(false);
			}
		});
	}

	private void popup_menu_under_button (Gdk.EventButton? event_button) {
		if (active_menu != null) {
			if (active_menu.visible) {
				active_menu.deactivate ();
			}
			active_menu.disconnect (active_menu_deactivate_id);
		}
		active_menu = menu_provider.make_menu ();
		if (active_menu != null) {
			active_menu_deactivate_id = active_menu.deactivate.connect ((menu) => {
				active = false;
			});
			uint button = 0;
			uint time = get_current_event_time();
			if (event_button != null) {
				button = event_button.button;
				time = event_button.time;
			}
			active_menu.popup(null, null, (button, out x, out y, push_in) => {
				get_window().get_origin (out x, out y);
				Allocation allocation;
				get_allocation(out allocation);
				x += allocation.x;
				y += allocation.y + allocation.height;
				push_in = true;
			}, button, time);
			sensitive = true;
		} else {
			sensitive = false;	
		}
	}
}
