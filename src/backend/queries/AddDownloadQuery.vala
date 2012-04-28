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

public class Lottanzb.AddDownloadQueryOptionalArguments : Object {

	public DownloadPostProcessing? post_processing { get; construct set; }
	public DownloadPriority? priority { get; construct set; }
	public string? script { get; construct set; }
	public string? category { get; construct set; }
	public string? name { get; construct set; }

}

public interface Lottanzb.AddDownloadQuery : Query<Object> {

	public abstract string uri { get; construct set; }
	public abstract AddDownloadQueryOptionalArguments optional_arguments { get; construct set; }

}

public class Lottanzb.AddDownloadQueryImpl : AddDownloadQuery, SimpleQuery {

	public string uri { get; construct set; }
	public AddDownloadQueryOptionalArguments optional_arguments { get; construct set; }

	public AddDownloadQueryImpl (string uri,
		AddDownloadQueryOptionalArguments optional_arguments) {
		var method = "addurl";
		var arguments = new Gee.HashMap<string, string> ();
		arguments["name"] = uri;
		var is_file_uri = is_file_uri (uri);
		if (is_file_uri) {
			method = "addfile";
		}
		if (optional_arguments.post_processing != null) {
			arguments["pp"] = ((int) optional_arguments.post_processing).to_string ();
		}
		if (optional_arguments.priority != null) {
			arguments["priority"] = ((int) optional_arguments.priority).to_string ();
		}
		if (optional_arguments.script != null) {
			arguments["script"] = optional_arguments.script;
		}
		if (optional_arguments.category != null) {
			arguments["cat"] = optional_arguments.category;
		}
		if (optional_arguments.name != null) {
			arguments["nzbname"] = optional_arguments.name;
		}
		base.with_arguments (method, arguments);
		this.uri = uri;
		this.optional_arguments = optional_arguments;
	}

	public override Soup.Message build_message (ConnectionInfo connection_info) {
		Soup.Message message;
		if (is_file_uri (uri)) {
			var url = build_url (connection_info);
			var file = File.new_for_uri (uri);
			var file_contents = read_file_contents (file);
			var buffer = new Soup.Buffer.take (file_contents.data);
			var mime_type = "application/octet-stream";
			var multipart = new Soup.Multipart (mime_type);
			multipart.append_form_file ("nzbfile", file.get_basename (), mime_type, buffer);
			message = Soup.Form.request_new_from_multipart (url, multipart);
			HashTable<string, string> content_type_params;
			string content_type = message.request_headers.get_content_type (out content_type_params);
			message.request_headers.set_content_type ("multipart/form-data", content_type_params);
		} else {
			message = base.build_message (connection_info);
		}
		return message;
	}

	private static bool is_file_uri (string uri) {
		return uri.has_prefix ("file://");
	}

	private static string read_file_contents (File file) {
		try {
			if (file.query_exists()) {
				var data_input_stream = new DataInputStream (file.read ());
				var string_builder = new StringBuilder ();
				string line;
				// Read lines until end of file (null) is reached
				while ((line = data_input_stream.read_line (null)) != null) {
					string_builder.append (line);
				}
				return string_builder.str;
			}
		} catch (Error e) {
			error ("could not read contents of file %s", file.get_path ());
		}
		return "";
	}

}
