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

public class Lottanzb.Main {

	public static int main (string[] args) {
		Gtk.init(ref args);

		var config_provider = new ConfigProviderImpl ();
		var session_provider = new SessionProviderImpl (config_provider);
		var backend = new Backend (config_provider, session_provider);
		backend.query_processor.get_warnings ();		
		var main_window = new MainWindow(config_provider);
		main_window.backend = backend;

		Gtk.main ();
		return 0;
	}
	
}
