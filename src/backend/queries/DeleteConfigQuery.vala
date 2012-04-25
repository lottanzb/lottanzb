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

public interface Lottanzb.DeleteConfigQuery : Object, Query<Object> {

	public abstract Gee.List<string> path { get; construct set; }
	public abstract string key { get; construct set; }

}

public class Lottanzb.DeleteConfigQueryImpl : DeleteConfigQuery, SimpleQuery {

	public Gee.List<string> path { get; construct set; }
	public string key { get; construct set; }

	public DeleteConfigQueryImpl (Gee.List<string> path, string key) {
		assert (path.size == 1);
		var section = path[0];
		var arguments = new Gee.HashMap<string, string> ();
		arguments["section"] = section;
		arguments["key"] = key;
		base.with_arguments ("del_config", arguments);
	}

}
