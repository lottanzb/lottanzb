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

public string get_fixture (string path) {
	var resource = LottanzbTestResource.get_resource ();
	var absolute_path = "/org/lottanzb/test/fixtures/" + path;
	var bytes = resource.lookup_data (absolute_path, ResourceLookupFlags.NONE);
	return (string) LottanzbResource.bytes_get_data (bytes);
}

public void test_queue_query () {
	var queue_query = new GetQueueQueryImpl ();
	var raw_response = get_fixture ("get_queue_query_response.json");
	queue_query.set_raw_response (raw_response);
	var response = queue_query.get_response ();
	assert (!response.is_paused);
	assert (response.time_left.seconds == 0);
	assert (response.size_left.bytes == 0);
	assert (response.speed.bytes_per_second == 0);
	assert (response.downloads.size == 1);
	var download = response.downloads[0];
	assert (download.id == "SABnzbd_nzo_PXK5Ja");
	assert (download.status == DownloadStatus.PAUSED);
	assert (download.priority == DownloadPriority.NORMAL);
	assert (download.file_name == "foo");
	assert (download.name == "foo");
	assert (download.average_age.days == 62.0);
	assert (download.time_left == null);
	assert (download.size.megabytes == 671.98);
	assert (download.size_left.megabytes == 564.69);
	assert (download.eta == null);
	assert (download.percentage == 15);
	assert (download.script == "None");
	assert (download.category == "*");
	assert (download.post_processing == DownloadPostProcessing.DELETE);
	assert (download.message_id == 0);
	assert (download.post_processing_time == null);
	assert (download.download_time == null);
	assert (download.completed == null);
	assert (download.storage_path == null);
	assert (download.error_message == "");
	assert (download.verification_percentage == 0);
	assert (download.repair_percentage == 0);
	assert (download.unpack_percentage == 0);
	assert (download.recovery_block_count == 0);
}
