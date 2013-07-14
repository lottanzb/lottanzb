/**
 * Copyright (c) 2013 Severin Heiniger <severinheiniger@gmail.com>
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

public class Lottanzb.ServersDialogTest : Lottanzb.TestSuiteBuilder {

	// private ServersDialog dialog;
	// private ServerList servers;

	public ServersDialogTest () {
		base ("servers_dialog");
		add_test ("selection", test_selection);
	}

	public override void set_up () {
		// Create a single (skeleton) server
		/* var settings = new SabnzbdSettings.with_memory_backend ();
		
		servers = settings.get_servers ();
		servers.add_child ();

		dialog = new ServersDialog (servers);

		while (Gtk.events_pending ()) {
			Gtk.main_iteration ();
		} */
	}

	public void test_selection () {
		// Simulate a click on the 'Add' button
		// dialog.widgets.add_server.activate ();
		// Ensure that the new server is selected
		/* assert (dialog.get_selected_server_index() == 1);

		// Simulate a click on the 'Remove' button
		dialog.on_remove_server_activate (dialog.widgets.remove_server);
		// Ensure that the remaining server is selected
		assert (dialog.get_selected_server_index() == 0);

		// Simulate a click on the 'Remove' button
		dialog.on_remove_server_activate (dialog.widgets.remove_server);
		// Ensure that the no server is selected
		assert (dialog.get_selected_server_index() == -1);

		dialog.on_response (dialog.dialog, Gtk.ResponseType.CLOSE);
		// Ensure that the reverted server is selected
		assert (dialog.get_selected_server_index() == 0); */
	}

}