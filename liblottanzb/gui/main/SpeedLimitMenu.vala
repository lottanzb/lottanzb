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

public class Lottanzb.SpeedLimitMenuProvider : MenuProvider, Object {

	public static DataSpeed[] DEFAULT_SPEED_LIMITS = {
		DataSpeed.with_unit (2000, DataSizeUnit.KILOBYTES),
		DataSpeed.with_unit (1000, DataSizeUnit.KILOBYTES),
		DataSpeed.with_unit (500, DataSizeUnit.KILOBYTES),
		DataSpeed.with_unit (250, DataSizeUnit.KILOBYTES),
		DataSpeed.with_unit (100, DataSizeUnit.KILOBYTES),
		DataSpeed.with_unit (50, DataSizeUnit.KILOBYTES)
	};
	
	private ConfigHub config_hub;

	public SpeedLimitMenuProvider (ConfigHub config_hub) {
		this.config_hub = config_hub;
	}

	public Gtk.Menu make_menu () {
		var speed_limit = config_hub.speed_limit;
		var menu = new SpeedLimitMenu (speed_limit);
		var is_default_speed_limit = speed_limit in DEFAULT_SPEED_LIMITS;
		menu.add_speed_limit (ConfigHub.UNLIMITED_SPEED);
		if (speed_limit != ConfigHub.UNLIMITED_SPEED && !is_default_speed_limit) {
			menu.add_speed_limit (speed_limit);
		}
		menu.add_separator ();
		menu.add_speed_limits (DEFAULT_SPEED_LIMITS);
		menu.speed_limit_changed.connect ((menu, new_speed_limit) => {
			config_hub.speed_limit = new_speed_limit;	
		});
		return menu;
	}

}

public class Lottanzb.SpeedLimitMenu : Gtk.Menu {
	
	private DataSpeed active_speed_limit;

	public signal void speed_limit_changed (DataSpeed new_speed_limit);

	public SpeedLimitMenu (DataSpeed speed_limit) {
		active_speed_limit = speed_limit;	
	}

	public void add_speed_limit (DataSpeed speed_limit) {
		List<weak Widget> children = get_children ();
		unowned SList<RadioMenuItem> group = null;
		var menu_item_count = children.length ();
		var label = speed_limit_string (speed_limit);
		if (menu_item_count > 0) {
			group = ((RadioMenuItem) children.nth_data (0)).get_group ();
		}
		var menu_item = new RadioMenuItem.with_label (group, label);
		if (active_speed_limit == speed_limit) {
			menu_item.active = true;
		}
		menu_item.toggled.connect ((menu_item) => {
			if (menu_item.active) {
				speed_limit_changed (speed_limit);
			}
		});
		menu_item.show ();
		append (menu_item);	
	}

	public void add_speed_limits (DataSpeed[] speed_limits) {
		foreach (DataSpeed speed_limit in speed_limits) {
			add_speed_limit (speed_limit);
		}
	}

	public void add_separator () {
		var menu_item = new SeparatorMenuItem ();
		menu_item.show ();
		append (menu_item);	
	}

	private string speed_limit_string (DataSpeed data_speed) {
		if (data_speed == ConfigHub.UNLIMITED_SPEED) {
			return _("Unlimited");
		} else {
			return data_speed.to_string ();
		}
	}

} 
