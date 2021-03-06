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

public class Lottanzb.DownloadStatusBinding : DownloadPropertyBinding<DownloadStatus> {

	public DownloadStatusBinding (DownloadListStore download_list_store,
			QueryProcessor query_processor) {
		base (download_list_store, query_processor, "status");
	}
	
	public override void handle_download_property_change (Download download) {
		base.handle_download_property_change (download);
		var new_status = download.status;
		if (new_status == DownloadStatus.PAUSED) {
			query_processor.pause_download.begin (download.id);
		} else {
			query_processor.resume_download.begin (download.id);
		}
	}

}
