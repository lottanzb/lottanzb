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

public interface Lottanzb.RenameDownloadQuery : Query<Object> {

	public abstract string download_id { get; construct set; }
	public abstract string new_name { get; construct set; }

}

public class Lottanzb.RenameDownloadQueryImpl : RenameDownloadQuery, SimpleQuery {

	public RenameDownloadQueryImpl (string download_id, string new_name) {
		var arguments = new Gee.HashMap<string, string> ();
		arguments["name"] = "rename";
		arguments["value"] = download_id;
		arguments["value2"] = new_name;
		base.with_arguments ("queue", arguments);
		this.download_id = download_id;
		this.new_name = new_name;
	}

	public string download_id { get; construct set; }
	public string new_name { get; construct set; }

}
