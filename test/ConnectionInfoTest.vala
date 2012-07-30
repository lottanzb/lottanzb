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

public class Lottanzb.ConnectionInfoTest : Lottanzb.TestSuiteBuilder {

	public ConnectionInfoTest () {
		base ("connection_info");
		add_test ("constructor", test_constructor);
	}

	public void test_constructor () {
		ConnectionInfo connection_info;
		connection_info = new ConnectionInfo ("localhost", 8080, "username", "secret", "0123456789abcdef", false);
		assert (connection_info.host == "localhost");
		assert (connection_info.port == 8080);
		assert (connection_info.username == "username");
		assert (connection_info.password == "secret");
		assert (connection_info.api_key == "0123456789abcdef");
		assert (!connection_info.https);
		assert (connection_info.requires_authentication);
		assert (connection_info.schema == "http");
		assert (connection_info.is_local);
		assert (!connection_info.is_remote);
		assert (connection_info.host_and_port == "localhost:8080");
		assert (connection_info.url == "http://localhost:8080/");
		assert (connection_info.api_url == "http://localhost:8080/api");
		connection_info = new ConnectionInfo ("192.168.1.33", 9090, "", "", "0123456789abcdef", true);
		assert (!connection_info.is_local);
		assert (connection_info.is_remote);
		assert (connection_info.https);
		assert (!connection_info.requires_authentication);
	}

}

