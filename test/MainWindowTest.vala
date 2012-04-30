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

using Lottanzb;

public void test_main_window_view_settings () {
	var config_provider = new ConfigProviderImpl.with_memory_backend ();
	var main_window = new MainWindow (config_provider);
	assert (main_window.widgets.infobar.visible);
	assert (main_window.widgets.show_infobar.active);
	assert (main_window.window_settings.get_boolean (MainWindow.SETTINGS_SHOW_INFOBAR));
	main_window.window_settings.set_boolean (MainWindow.SETTINGS_SHOW_INFOBAR, false);
	assert (!main_window.widgets.infobar.visible);
	assert (!main_window.widgets.show_infobar.active);
	main_window.widgets.show_infobar.active = true;
	assert (main_window.widgets.infobar.visible);
	assert (main_window.window_settings.get_boolean (MainWindow.SETTINGS_SHOW_INFOBAR));
}
