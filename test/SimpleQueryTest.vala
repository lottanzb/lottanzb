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

public class Lottanzb.SimpleQueryTest : Lottanzb.TestSuiteBuilder {

	public SimpleQueryTest () {
		base ("simple_query");
		add_test ("construction", test_construction);
		add_test ("message_building", test_message_building);
		add_test ("resume_downloads_query", test_resume_downloads_query);
		add_test ("pause_downloads_query", test_pause_downloads_query);
	}

	public void test_construction () {
		SimpleQuery query;
		query = new SimpleQuery ("foo"); 
		assert (query.method == "foo");
		query = new SimpleQuery.with_argument ("bar", "key", "value");
		assert (query.method == "bar");
		assert (query.arguments["key"] == "value");
		var arguments = new Gee.HashMap<string, string> ();
		arguments["key1"] = "value1";
		arguments["key2"] = "value2";
		query = new SimpleQuery.with_arguments ("baz", arguments);
		assert (query.method == "baz");
		assert (query.arguments["key1"] == "value1");
		assert (query.arguments["key2"] == "value2");
	}

	public void test_message_building () {
		var arguments = new Gee.HashMap<string, string> ();
		arguments["key1"] = "value1";
		arguments["key2"] = "value2";
		var query = new SimpleQuery.with_arguments ("baz", arguments);

		var info = new ConnectionInfo ("localhost", 8080, "username", "secret", "0123456789abcdef", false);
		var message = query.build_message (info);	
		assert (message.method == "GET");
		assert (message.uri.host == "localhost");
		assert (message.uri.port == 8080);
		assert (message.uri.scheme == "http");
		assert (message.uri.path == "/api");
	}

	public void test_resume_downloads_query () {
		var download_ids = new Gee.ArrayList<string> ();
		download_ids.add ("foo");
		download_ids.add ("bar");
		var query = new ResumeDownloadsQueryImpl (download_ids);
		assert (query.method == "queue");
		assert (query.arguments["name"] == "resume");
		assert (query.arguments["value"] == "foo,bar");
	}

	public void test_pause_downloads_query () {
		var download_ids = new Gee.ArrayList<string> ();
		download_ids.add ("foo");
		download_ids.add ("bar");
		var query = new PauseDownloadsQueryImpl (download_ids);
		assert (query.method == "queue");
		assert (query.arguments["name"] == "pause");
		assert (query.arguments["value"] == "foo,bar");
	}

}
