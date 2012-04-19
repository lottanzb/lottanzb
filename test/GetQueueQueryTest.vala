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

using Lottanzb;

public void test_queue_query () {
	var queue_query = new GetQueueQueryImpl ();
	var raw_response = get_fixture ("get_queue_query_response.json");
	queue_query.set_raw_response (raw_response);
	var response = queue_query.get_response ();
	assert (!response.is_paused);
	assert (response.time_left.seconds == 0);
	assert (response.size_left.bytes == 0);
	assert (response.speed.bytes_per_second == 0);
	assert (response.downloads.size == 2);
	var active_download = response.downloads[0];
	assert (active_download.id == "SABnzbd_nzo_pRIZDA");
	assert (active_download.status == DownloadStatus.DOWNLOADING);
	assert (active_download.priority == DownloadPriority.NORMAL);
	assert (active_download.file_name == "foo");
	assert (active_download.name == "foo");
	assert (active_download.average_age.days == 699.0);
	assert (active_download.time_left.total_seconds == 669439l);
	assert (active_download.size.megabytes == 21055.69);
	assert (active_download.size_left.megabytes == 6806.19);
	assert (active_download.eta != null);
	assert (active_download.percentage == 67);
	assert (active_download.script == "");
	assert (active_download.category == "*");
	assert (active_download.post_processing == DownloadPostProcessing.REPAIR);
	assert (active_download.message_id == 0);
	assert (active_download.post_processing_time == null);
	assert (active_download.download_time == null);
	assert (active_download.completed == null);
	assert (active_download.storage_path == null);
	assert (active_download.error_message == "");
	assert (active_download.verification_percentage == 0);
	assert (active_download.repair_percentage == 0);
	assert (active_download.unpack_percentage == 0);
	assert (active_download.recovery_block_count == 0);

	var paused_download = response.downloads[1];
	assert (paused_download.id == "SABnzbd_nzo_PXK5Ja");
	assert (paused_download.status == DownloadStatus.PAUSED);
	assert (paused_download.priority == DownloadPriority.NORMAL);
	assert (paused_download.file_name == "bar");
	assert (paused_download.name == "bar");
	assert (paused_download.average_age.days == 62.0);
	assert (paused_download.time_left == null);
	assert (paused_download.size.megabytes == 671.98);
	assert (paused_download.size_left.megabytes == 564.69);
	assert (paused_download.eta == null);
	assert (paused_download.percentage == 15);
	assert (paused_download.script == "");
	assert (paused_download.category == "*");
	assert (paused_download.post_processing == DownloadPostProcessing.DELETE);
	assert (paused_download.message_id == 0);
	assert (paused_download.post_processing_time == null);
	assert (paused_download.download_time == null);
	assert (paused_download.completed == null);
	assert (paused_download.storage_path == null);
	assert (paused_download.error_message == "");
	assert (paused_download.verification_percentage == 0);
	assert (paused_download.repair_percentage == 0);
	assert (paused_download.unpack_percentage == 0);
	assert (paused_download.recovery_block_count == 0);
}
