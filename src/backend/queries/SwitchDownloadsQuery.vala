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

public interface Lottanzb.SwitchDownloadsQuery : Query<Object> {

	public abstract string first_download_id { get; construct set; }
	public abstract string second_download_id { get; construct set; }

}

public class Lottanzb.SwitchDownloadsQueryImpl : SimpleQuery, SwitchDownloadsQuery {

	public SwitchDownloadsQueryImpl (string first_download_id, string second_download_id) {
		var arguments = new Gee.HashMap<string, string> ();
		arguments.set ("value", first_download_id);
		arguments.set ("value2", second_download_id);
		base.with_arguments ("switch", arguments);
		this.first_download_id = first_download_id;
		this.second_download_id = second_download_id;
	}

	public string first_download_id { get; construct set; }
	public string second_download_id { get; construct set; }

}
