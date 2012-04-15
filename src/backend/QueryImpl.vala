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

	public QueryImpl (string method, ...) {
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

	public R get_response () {
		return _response;
	}

	public string get_raw_response () {
		return _raw_response;
	}

	public void set_raw_response (string raw_response) throws QueryError, Error {
		try {
			_raw_response = raw_response;
			var parser = new Json.Parser ();
			parser.load_from_data (raw_response, -1);
			var root_object = parser.get_root ().get_object ();
			_response = get_response_from_json_object (root_object);
			has_succeeded = get_status_from_json_object (root_object);	
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
		return @"Query<$(method)>";
	}
	
	public abstract R get_response_from_json_object(Json.Object json_object)
		throws QueryError;

	public bool get_status_from_json_object (Json.Object json_object) {
		if (json_object.has_member("status")) {
			return json_object.get_boolean_member("status");
		} else {
			return true;
		}
	}

}
