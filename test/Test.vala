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

private static int main (string[] args) {
	Environment.set_variable ("GSETTINGS_BACKEND", "memory", true);
	Gtk.init_check (ref args);
	Test.init (ref args);
	TestSuite.get_root ().add_suite (new BackendTest ());
	TestSuite.get_root ().add_suite (new GeneralPreferencesTabTest ().get_suite ());
	TestSuite.get_root ().add_suite (new SpeedLimitMenuTest ().get_suite ());
	return Test.run ();
}
