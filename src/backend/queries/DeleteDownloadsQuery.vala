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

public interface Lottanzb.DeleteDownloadsQuery : Query<Object> {

	public abstract Gee.List<string> download_ids { get; construct set; }

}

public class Lottanzb.DeleteDownloadsQueryImpl : DeleteDownloadsQuery, SimpleQuery {

	public DeleteDownloadsQueryImpl (Gee.List<string> download_ids) {
		var arguments = new Gee.HashMap<string, string> ();
		arguments["name"] = "delete";
		arguments["value"] = string.joinv (",", download_ids.to_array ());
		base.with_arguments ("queue", arguments);
		this.download_ids = download_ids;
	}

	public Gee.List<string> download_ids { get; construct set; }

}
