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
	var misc_settings = config_hub.root.get_child_for_same_backend_cached ("misc");
	assert (misc_settings.get_boolean ("quick-check"));
	assert (misc_settings.get_int ("https-port") == 9090);
	assert (misc_settings.get_int ("folder-max-length") == 256);
	assert (misc_settings.get_string ("complete-dir") == "Downloads/complete");
}
