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

	private static bool debug = false;
	private static bool show_version = false;

	private static const OptionEntry[] option_entries = {
		{ "debug", 'd', 0, OptionArg.NONE, ref debug, "Show debug messages", null },
		{ "version", 0, 0, OptionArg.NONE, ref show_version, "Show the version of the program", null },
		{ null }
	};

	public static int main (string[] args) {
		var option_context = new OptionContext ("- usenet client");
		option_context.set_help_enabled (true);
		option_context.add_main_entries (option_entries, null);
		try {
			option_context.parse (ref args);
		} catch (OptionError error) {
			stderr.printf ("option parsing failed: %s\n", error.message);
			return 1;
		}

		if (show_version) {
			stdout.printf ("LottaNZB %s\n", LottanzbConfig.VERSION);
			return 0;
		}
		if (debug) {
			Environment.set_variable ("G_MESSAGES_DEBUG", "all", true);
		}

		Gtk.init(ref args);
		var app = new Unique.App (LottanzbConfig.DBUS_NAME, null);
		if (app.is_running) {
			critical ("LottaNZB is already running.");
			return 1;
		}

		var config_provider = new ConfigProviderImpl ();
		var session_provider = new SessionProviderImpl (config_provider);
		var backend = new Backend (config_provider, session_provider);
		var main_window = new MainWindow(config_provider);
		main_window.backend = backend;

		Gtk.main ();
		return 0;
	}
	
}
