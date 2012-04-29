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

public void test_get_warnings_query () {
	var raw_response = get_fixture ("get_warnings_query_response.json");
	var query = new GetWarningsQueryImpl ();
	query.set_raw_response (raw_response);
	var warnings = query.get_response ();
	assert (warnings.size == 2);
	assert (query.method == "warnings");
	var warning = warnings[0];
	var expected_date_time = new DateTime.local (2012, 3, 14, 20, 44, 52.122);
	assert (warning.date_time.equal (expected_date_time));
	assert (warning.log_level == LogLevelFlags.LEVEL_ERROR);
	assert (warning.content == "Failed login for server example.com:563");
}
