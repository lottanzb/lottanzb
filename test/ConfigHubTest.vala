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

private class Lottanzb.ConfigHubTestMockQueryProcessor : MockQueryProcessor {

	public override GetConfigQuery make_get_config_query () {
		var get_config_query = new GetConfigQueryImpl ();
		var raw_response = get_fixture ("get_config_query_response.json");
		get_config_query.set_raw_response (raw_response);
		return get_config_query;
	}

}

// TODO: Recording signal emissions using lambda expressions is not possible in functions,
// which is why the auxiliary ConfigHubTest class is used.
public class Lottanzb.ConfigHubTest : Object {

	private int row_changed_count = 0;
	private int last_row_changed_index = -1;
	private int row_inserted_count = 0;
	private int last_row_inserted_index = -1;
	private int row_deleted_count = 0;
	private int last_row_deleted_index = -1;

	public void test_config_hub () {
		var query_processor = new ConfigHubTestMockQueryProcessor ();
		var config_hub = new ConfigHub (query_processor);
		var misc_settings = config_hub.root.get_misc ();
		assert (misc_settings.get_boolean ("quick-check"));
		assert (misc_settings.get_int ("https-port") == 9090);
		assert (misc_settings.get_int ("folder-max-length") == 256);
		assert (misc_settings.get_string ("complete-dir") == "Downloads/complete");
	}

	public void assert_first_fixture_server (BetterSettings server) {
		assert (server.get_string ("username") == "me@example.com");
		assert (server.get_boolean ("enable"));
		assert (server.get_string ("name") == "news.example.com");
		assert (!server.get_boolean ("fillserver"));
		assert (server.get_int ("connections") == 12);
		assert (!server.get_boolean ("ssl"));
		assert (server.get_string ("host") == "news.example.com");
		assert (server.get_int ("timeout") == 30);
		assert (server.get_string ("password") == "********");
		assert (!server.get_boolean ("optional"));
		assert (server.get_int ("port") == 119);
		assert (server.get_int ("retention") == 0);
	}

	public void assert_second_fixture_server (BetterSettings server) {
		assert (server.get_string ("username") == "me");
		assert (!server.get_boolean ("enable"));
		assert (server.get_string ("name") == "ssl.example.com");
		assert (!server.get_boolean ("fillserver"));
		assert (server.get_int ("connections") == 6);
		assert (server.get_boolean ("ssl"));
		assert (server.get_string ("host") == "ssl.example.com");
		assert (server.get_int ("timeout") == 120);
		assert (server.get_string ("password") == "********");
		assert (!server.get_boolean ("optional"));
		assert (server.get_int ("port") == 563);
		assert (server.get_int ("retention") == 0);
	}

	public void test_config_hub_servers_settings () {
		var query_processor = new ConfigHubTestMockQueryProcessor ();
		var config_hub = new ConfigHub (query_processor);
		var servers_settings = config_hub.root.get_servers ();
		assert (servers_settings.size == 2);
		assert_first_fixture_server (servers_settings.get_server (0));
		assert_second_fixture_server (servers_settings.get_server (1));
		assert (!servers_settings.has_reached_max_server_count);

		servers_settings.add_server ();
		assert (servers_settings.size == 3);
		var new_server = servers_settings.get_server (2);
		assert (new_server.get_string ("host") == "");
		new_server.set_string ("host", "example.com");
		servers_settings.remove_server (2);
		assert (servers_settings.size == 2);
		assert (new_server.get_string ("host") == "");

		servers_settings.remove_server (0);
		assert_second_fixture_server (servers_settings.get_server (0));
	}

	public void test_servers_tree_model () {
		var query_processor = new ConfigHubTestMockQueryProcessor ();
		var config_hub = new ConfigHub (query_processor);
		var servers_settings = config_hub.root.get_servers ();
		var servers_tree_model = new ServersTreeModel (servers_settings);
		assert (servers_tree_model.get_column_type (0) == typeof (BetterSettings));
		assert (servers_tree_model.get_n_columns () == 1);
		servers_tree_model.row_changed.connect (on_servers_tree_model_row_changed);
		servers_tree_model.row_inserted.connect (on_servers_tree_model_row_inserted);
		servers_tree_model.row_deleted.connect (on_servers_tree_model_row_deleted);
		var first_server = servers_settings.get_server (0);
		var second_server = servers_settings.get_server (1);
		second_server.set_boolean ("fillserver", true);
		assert (row_changed_count == 1);
		assert (last_row_changed_index == 1);
		assert (servers_tree_model.iter_n_children (null) == 2);
		servers_settings.add_server ();
		assert (row_changed_count == 1);
		assert (row_inserted_count == 1);
		assert (last_row_inserted_index == 2);
		assert (row_deleted_count == 0);
		assert (servers_tree_model.iter_n_children (null) == 3);
		servers_settings.add_server ();
		assert (row_changed_count == 1);
		assert (row_inserted_count == 2);
		assert (last_row_inserted_index == 3);
		assert (row_deleted_count == 0);
		assert (servers_tree_model.iter_n_children (null) == 4);
		servers_settings.add_server ();
		servers_settings.remove_server (2);
		assert (row_changed_count > 2);
		assert (row_inserted_count == 3);
		assert (last_row_inserted_index == 4);
		assert (row_deleted_count == 1);
		assert (last_row_deleted_index == 4);
		assert (servers_tree_model.iter_n_children (null) == 4);
	}

	private void on_servers_tree_model_row_changed (Gtk.TreeModel model, Gtk.TreePath path, Gtk.TreeIter iter) {
		row_changed_count++;
		last_row_changed_index = path.get_indices ()[0];
	}

	private void on_servers_tree_model_row_inserted (Gtk.TreeModel model, Gtk.TreePath path, Gtk.TreeIter iter) {
		row_inserted_count++;		
		last_row_inserted_index = path.get_indices ()[0];
	}

	private void on_servers_tree_model_row_deleted (Gtk.TreeModel model, Gtk.TreePath path) {
		row_deleted_count++;
		last_row_deleted_index = path.get_indices ()[0];
	}

}

public void test_config_hub () {
	var config_hub_test = new ConfigHubTest ();
	config_hub_test.test_config_hub ();
}

public void test_config_hub_servers_settings () {
	var config_hub_test = new ConfigHubTest ();
	config_hub_test.test_config_hub_servers_settings ();
}

public void test_servers_tree_model () {
	var config_hub_test = new ConfigHubTest ();
	config_hub_test.test_servers_tree_model ();
}
