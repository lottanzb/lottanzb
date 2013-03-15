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

public class Lottanzb.MockGeneralHub : Object, GeneralHub {

	public QueryProcessor query_processor { get; construct set; }
	public DownloadListStore download_list_store { get; construct set; }

	public DataSpeed speed { get; protected set; default = DataSpeed.UNKNOWN; }
	public TimeDelta time_left { get; protected set; default = TimeDelta.UNKNOWN; }
	public DataSize size_left { get; protected set; default = DataSize.UNKNOWN; }
	public DateTime eta { get; protected set; }

	public MockGeneralHub () {
		query_processor = new MockQueryProcessor ();
		download_list_store = new DownloadListStore ();
		speed = 500;
		time_left = 42;
		size_left = DataSize.with_unit (2, DataSizeUnit.MEGABYTES);
		eta = new DateTime.now_local ();
	}

	public void pause_downloads (Gee.List<Download> downloads) { }
	public void resume_downloads (Gee.List<Download> downloads) { }
	public void move_download (Download download, int index) { }
	public void move_download_relative (Download download, int shift) { }
	public void force_download (Download download) { }
	public void move_download_up (Download download, int shift = 1) { }
	public void move_download_down (Download download, int shift = 1) { }
	public void move_download_down_to_bottom (Download download) { }
	public void rename_download (Download download, string new_name) { }
	public void set_download_priority (Download download, DownloadPriority new_priority) { }
	public void delete_download (Download download) { }

}
