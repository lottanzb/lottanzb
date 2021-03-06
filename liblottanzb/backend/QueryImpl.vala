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

public abstract class Lottanzb.QueryImpl<R> : Object, Query<R> {

	private static string OUTPUT_FORMAT = "json";

	private string _method;
	private Gee.Map<string, string> _arguments;
	private R _response;
	private string _raw_response;
	private bool _has_completed;
	private bool _has_succeeded;

	public QueryImpl (string method) {
		_method = method;
		_arguments = new Gee.HashMap<string, string> ();
		_arguments.set ("output", OUTPUT_FORMAT);
		_arguments.set ("mode", method);
	}

	public QueryImpl.with_argument (string method, string key, string value) {
		this (method);
		_arguments.set (key, value);
	}

	public QueryImpl.with_arguments (string method, Gee.Map<string, string> arguments) {
		this (method);
		_arguments.set_all (arguments);
	}
	
	public string method {
		get { return _method; }
	}

	public Gee.Map<string, string> arguments {
		get { return _arguments; }
	}

	public virtual Soup.Message build_message (ConnectionInfo connection_info) {
		var uri = build_uri (connection_info);
		var message = new Soup.Message.from_uri ("GET", uri);
		return message;
	}
	
	public virtual Soup.URI build_uri (ConnectionInfo connection_info) {
		var uri = connection_info.build_api_uri ();
		var arguments = build_arguments (connection_info);
		var real_arguments = new HashTable<string, string> (str_hash, str_equal);
		foreach (Gee.Map.Entry<string, string> entry in arguments.entries) {
			real_arguments.set (entry.key, entry.value);
		}
		uri.set_query_from_form (real_arguments);
		return uri;
	}

	public Gee.Map<string, string> build_arguments (ConnectionInfo connection_info) {
		var arguments = new Gee.HashMap<string, string> ();
		arguments.set_all (this.arguments);
		if (connection_info.requires_authentication) {
			arguments["ma_username"] = connection_info.username;
			arguments["ma_password"] = connection_info.password;
		}
		if (connection_info.api_key != null) {
			arguments["apikey"] = connection_info.api_key;
		}
		return arguments;
	}

	public R get_response () {
		return _response;
	}

	public string get_raw_response () {
		return _raw_response;
	}

	public void set_raw_response (string raw_response) throws QueryError {
		try {
			_raw_response = raw_response;
			var parser = new Json.Parser ();
			parser.load_from_data (raw_response, -1);
			var root_object = parser.get_root ().get_object ();
			check_response_json_object (root_object);
			_response = get_response_from_json_object (root_object);
			has_succeeded = true;
		} catch (QueryError e) {
			has_succeeded = false;
			throw e;
		} catch (Error e) {
			has_succeeded = false;
			throw new QueryError.INVALID_RESPONSE (e.message);
		} finally {
			has_completed = true;	
		}
	}

	public bool has_completed {
		get { return _has_completed; }
		set { _has_completed = value; }
	}
	
	public bool has_succeeded {
		get { return _has_succeeded; }
		set { _has_succeeded = value; }
	}

	public string to_string () {
		string[] arguments_strings = {};
		foreach (var entry in arguments.entries) {
			arguments_strings += @"$(entry.key)=$(entry.value)";
		}
		var query_type_name = get_type ().name ();
		var arguments_string = string.joinv (", ", arguments_strings);
		return @"$(query_type_name) ($(arguments_string))";
	}
	
	public abstract R get_response_from_json_object(Json.Object json_object)
		throws QueryError;

	public virtual void check_response_json_object (Json.Object json_object)
		throws QueryError {
		var status = true;
		if (json_object.has_member ("status")) {
			status = json_object.get_boolean_member ("status");
		}

		if (!status && json_object.has_member ("error")) {
			var error = json_object.get_string_member ("error");
			error = error.down ();
			if (error == "missing authentication") {
				throw new QueryError.USERNAME_PASSWORD ("");
			} else if (error == "api key required") {
				throw new QueryError.API_KEY ("API key required");
			} else if (error == "api key incorrect") {
				throw new QueryError.API_KEY ("API key incorrect");
			} else if (error == "not implemented") {
				throw new QueryError.NOT_IMPLEMENTED ("method not implemented");
			} else {
				throw new QueryError.INVALID_RESPONSE (error);
			}
		}
	}

}
