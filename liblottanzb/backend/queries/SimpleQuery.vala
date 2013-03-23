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

public class Lottanzb.SimpleQuery : QueryImpl<Object> {

	public static Object NULL = new Object ();
	
	public SimpleQuery (string method) {
		base (method);
	}

	public SimpleQuery.with_argument (string method, string key, string value) {
		base.with_argument (method, key, value);	
	}

	public SimpleQuery.with_arguments (string method, Gee.Map<string, string> arguments) {
		base.with_arguments (method, arguments);
	}

	public override Object get_response_from_json_object(Json.Object json_object) {
		return NULL;
	}

}

public interface Lottanzb.PauseDownloadsQuery : Query<Object> {

}

public class Lottanzb.PauseDownloadsQueryImpl : PauseDownloadsQuery, SimpleQuery {

	public PauseDownloadsQueryImpl (Gee.List<string> download_ids) {
		base.with_argument ("queue", "name", "pause");
		arguments["value"] = string.joinv (",", download_ids.to_array ());
	}

}

public interface Lottanzb.ResumeDownloadsQuery : Query<Object> {

}

public class Lottanzb.ResumeDownloadsQueryImpl : ResumeDownloadsQuery, SimpleQuery {

	public ResumeDownloadsQueryImpl (Gee.List<string> download_ids) {
		base.with_argument ("queue", "name", "resume");
		arguments["value"] = string.joinv (",", download_ids.to_array ());
	}

}


public interface Lottanzb.PauseQuery : Query<Object> {

}

public class Lottanzb.PauseQueryImpl : PauseQuery, SimpleQuery {

	public PauseQueryImpl () {
		base ("pause");
	}

}

public interface Lottanzb.ResumeQuery : Query<Object> {

}

public class Lottanzb.ResumeQueryImpl : ResumeQuery, SimpleQuery {

	public ResumeQueryImpl () {
		base ("resume");
	}

}
