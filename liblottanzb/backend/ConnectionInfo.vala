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


public class Lottanzb.ConnectionInfo : Object {
	
	private static string[] local_hosts = { "localhost", "127.0.0.1", "::1" };
	
	public string host { get; construct; default = "localhost"; }
	public int port { get; construct; }
	public string username { get; construct; }
	public string password { get; construct; }
	public string api_key { get; construct; }
	public bool https { get; construct; }
	
	public ConnectionInfo (string host, int port, string username, string password, string api_key, bool https) {
		Object (host: host, port: port, username: username, password: password, api_key: api_key, https: https);
	}
	
	public bool requires_authentication {
		get { return username.length > 0 && password.length > 0; }
	}
	
	public string scheme {
		get { return (https) ? "https" : "http"; }
	}
	
	public bool is_local {
		get {
			foreach (string local_host in local_hosts) {
				if (host == local_host) {
					return true;
				}
			}
			return false;
		}
	}
	
	public bool is_remote {
		get { return !is_local; }
	}
	
	public string host_and_port {
		owned get { return @"$(host):$(port)"; }
	}
	
	public Soup.URI build_uri () {
		var uri = new Soup.URI (null);
		uri.set_scheme (scheme);
		uri.set_host (host);
		uri.set_port (port);
		uri.set_path ("/");
		return uri;
	}
	
	public Soup.URI build_api_uri () {
		var uri = build_uri ();
		uri.set_path ("/api");
		return uri;
	}

}
