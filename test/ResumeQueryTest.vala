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

public class Lottanzb.ResumeQueryTest : Lottanzb.TestSuiteBuilder {

	public ResumeQueryTest () {
		base ("resume_query");
		add_test ("simple", test_simple);
	}

	public void test_simple () {
		var query = new SimpleQuery ("resume");
		try {
			query.set_raw_response ("{\"status\":true}");
			assert (query.has_succeeded);
		} catch (QueryError e) {
			assert_not_reached ();
		}
	}

}
