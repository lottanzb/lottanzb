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

// modules: glib-2.0 gio-2.0 gtk+-3.0 gmodule-2.0 

using Gtk;
using Pango;

public class Lottanzb.InfoBar : AbstractInfoBar {

	private MenuButton _speed_button;
	private GeneralHub _general_hub;
	private StatisticsHub _statistics_hub;

	public InfoBar (Backend backend) {
		_general_hub = backend.general_hub;
		_statistics_hub = backend.statistics_hub;

		var speed_icon = new Image.from_stock(Stock.GO_DOWN, IconSize.MENU);
		var speed_limit_menu_provider = new SpeedLimitMenuProvider (backend);
		_speed_button = new MenuButton(speed_limit_menu_provider);
		_speed_button.image = speed_icon;
		_speed_button.relief = ReliefStyle.NONE;
		_speed_button.tooltip_text = _("Limit the download speed");
		_speed_button.show();
		widgets.speed_container.pack_start(_speed_button, false);

		_general_hub.notify["speed"].connect((o, p) => {
			on_remaining_changed ();
		});
		_general_hub.notify["size-left"].connect((o, p) => {
			on_remaining_changed ();
		});
		_general_hub.notify["time-left"].connect((o, p) => {
			on_free_space_changed ();
		});

		_statistics_hub.notify["free-download-folder-space"].connect(on_free_space_changed);
		_statistics_hub.notify["free-temp-folder-space"].connect(on_free_space_changed);

		on_speed_changed();
		on_remaining_changed();
		on_free_space_changed();
		widgets.window.remove(widget);
	}

	public Widget widget {
		get {
			return widgets.info_bar;
		}
	}

	private void on_speed_changed () {
		var new_label = _general_hub.speed.to_string();
		if (widgets.speed.label != new_label) {
			widgets.speed.label = new_label;
		}
	}

	private void on_remaining_changed () {
		string new_label;
		if (_general_hub.time_left.seconds == 0) {
			new_label = @"$(_general_hub.size_left) left";
		} else {
			new_label = @"$(_general_hub.size_left) left ($(_general_hub.time_left))"; 
		}
		if (widgets.total_remaining.label != new_label) {
			widgets.total_remaining.label = new_label;
		}
	}

	private void on_free_space_changed () {
		var free_download_space = _statistics_hub.free_download_folder_space;
		var free_temp_space = _statistics_hub.free_temp_folder_space;
		if (free_download_space == null || free_temp_space == null) {
			return;
		}
		var new_label = _(@"$(free_download_space) free");
		var size_left = _general_hub.size_left;

		// Use red color to indicate that the size of the queue exceeds the
		// available space in the download folder
		if (free_download_space.bytes < size_left.bytes) {
			new_label = @"<span color=\"red\">$(new_label)</span>";
		}

		// Only show the free space in the temporary folder if it is on a
		// different partition.
		// TODO: Could also use red color to indicate potential problems.
		if (free_download_space.bytes != free_temp_space.bytes) {
			new_label += "\n" + _(@"$(free_temp_space) free (temp)");
			new_label += @"<span size=\"7200\">$(new_label)</span>";
		}

		widgets.free_space_container.show();
		if (widgets.free_space.label != new_label) {
			widgets.free_space.label = new_label;
		}
	}

}
