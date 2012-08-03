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

public interface Lottanzb.SetConfigQuery : Query<Object> {

	public abstract Gee.List<string> path { get; construct set; }
	public abstract Gee.Map<string, string> entries { get; construct set; }

}

public class Lottanzb.SetConfigQueryImpl : SetConfigQuery, SimpleQuery {

	public Gee.List<string> path { get; construct set; }
	public Gee.Map<string, string> entries { get; construct set; }

	public SetConfigQueryImpl (Gee.List<string> path, Gee.Map<string, string> entries) {
		// TODO: Making these values static fields yields a segmentation fault
		// at run-time, possibly because they are initialized too late.
		var SECTION_ARGUMENT = "section";
		var KEY_ARGUMENT = "keyword";
		var VALUE_ARGUMENT = "value";
		var arguments = new Gee.HashMap<string, string> ();
		switch (path.size) {
			case 1:
				var section = path[0];
				var key = entries.keys.to_array ()[0];
				var value = entries[key];
				arguments[SECTION_ARGUMENT] = section;
				arguments[KEY_ARGUMENT] = key;
				arguments[VALUE_ARGUMENT] = value;
				break;
			case 2:
				var section = path[0];
				var key = path[1];
				arguments[SECTION_ARGUMENT] = section;
				arguments[KEY_ARGUMENT] = key;
				arguments.set_all (entries);
				foreach (var some_key in entries.keys) {
					assert (some_key != SECTION_ARGUMENT && some_key != KEY_ARGUMENT);
				}
				break;
			default:
				assert_not_reached ();
		}
		base.with_arguments ("set_config", arguments);
	}

}
