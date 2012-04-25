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

public interface Lottanzb.AddDownloadQuery : Query<Object>, Object {

	public abstract string uri { get; construct set; }
	public abstract AddDownloadQueryOptionalArguments optional_arguments { get; construct set; }

}

public class Lottanzb.AddDownloadQueryImpl : AddDownloadQuery, SimpleQuery {

	public string uri { get; construct set; }
	public AddDownloadQueryOptionalArguments optional_arguments { get; construct set; }

	public AddDownloadQueryImpl (string uri,
		AddDownloadQueryOptionalArguments optional_arguments) {
		var method = "addurl";
		var is_file_uri = is_file_uri (uri);
		if (is_file_uri) {
			method = "addfile";
		}
		var arguments = new Gee.HashMap<string, string> ();
		arguments["name"] = uri;
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

	private static bool is_file_uri (string uri) {
		return uri.has_prefix ("file://");
	}

}
