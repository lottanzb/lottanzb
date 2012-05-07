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

private class ConfigHubTestMockQueryProcessor : MockQueryProcessor {

	public override GetConfigQuery make_get_config_query () {
		var get_config_query = new GetConfigQueryImpl ();
		var raw_response = get_fixture ("get_config_query_response.json");
		get_config_query.set_raw_response (raw_response);
		return get_config_query;
	}

}

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
