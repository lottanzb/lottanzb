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

public interface Lottanzb.GetVersionQuery : Query<string> {

}

public class Lottanzb.GetVersionQueryImpl : QueryImpl<string>, GetVersionQuery {

	public GetVersionQueryImpl () {
		base("version");
	}
	
	public override string get_response_from_json_object(Json.Object json_object) throws QueryError {
		var version = json_object.get_string_member ("version");
		return version;
	}

}
