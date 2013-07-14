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
 * along with this program.  If not, see <http:www.gnu.org/licenses/>.
 */

using Lottanzb;

public class Lottanzb.GetAuthenticationTypeQueryTest : Lottanzb.TestSuiteBuilder {

	public GetAuthenticationTypeQueryTest () {
		base ("get_authentication_type_query");
		add_test ("simple", test_simple);
	}

	public void test_simple () {
		assert_response (AuthenticationType.API_KEY, "apikey");
		assert_response (AuthenticationType.USERNAME_AND_PASSWORD, "login");
		assert_response (AuthenticationType.NOTHING, "None");
	}

	private void assert_response (AuthenticationType expected_type, string raw_type) {
		try {
			var query = new GetAuthenticationTypeQueryImpl ();
			assert (query.method == "auth");
			query.set_raw_response ("{\"auth\":\"" + raw_type + "\"}");
			assert (query.get_response () == expected_type);
		} catch (QueryError e) {
			assert_not_reached ();
		}
	}

}
