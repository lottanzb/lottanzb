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
		GetAuthenticationTypeQueryImpl query;
		query = new GetAuthenticationTypeQueryImpl ();
		assert (query.method == "auth");
		query.set_raw_response ("{\"auth\":\"apikey\"}");
		assert (query.get_response () == AuthenticationType.API_KEY);
		query = new GetAuthenticationTypeQueryImpl ();
		query.set_raw_response ("{\"auth\":\"login\"}");
		assert (query.get_response () == AuthenticationType.USERNAME_AND_PASSWORD);
		query = new GetAuthenticationTypeQueryImpl ();
		query.set_raw_response ("{\"auth\":\"None\"}");
		assert (query.get_response () == AuthenticationType.NOTHING);
	}

}
