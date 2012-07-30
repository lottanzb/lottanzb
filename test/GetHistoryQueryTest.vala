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

public class Lottanzb.GetHistoryQueryTest : Lottanzb.TestSuiteBuilder {

	public GetHistoryQueryTest () {
		base ("get_history_query");
		add_test ("set_raw_response", test_set_raw_response);
	}

	public void test_set_raw_response () {
		var query = new GetHistoryQueryImpl ();
		var raw_response = get_fixture ("get_history_query_response.json");
		query.set_raw_response (raw_response);
		var downloads = query.get_response ().downloads;
		assert (downloads.size == 2);
		Download succeeded_download = downloads[0];
		assert (succeeded_download.id == "spam");
		assert (succeeded_download.status == DownloadStatus.SUCCEEDED);
		assert (succeeded_download.file_name == "spam.nzb");
		assert (succeeded_download.name == "spam");
		assert (succeeded_download.average_age == null);
		assert (succeeded_download.time_left == null);
		assert (succeeded_download.size.bytes == 603355611);
		assert (succeeded_download.size_left == null);
		// TODO: Should be size_left.bytes == 0
		assert (succeeded_download.eta == null);
		assert (succeeded_download.percentage == 100);
		assert (succeeded_download.script == "");
		assert (succeeded_download.category == "*");
		assert (succeeded_download.post_processing == DownloadPostProcessing.DELETE);
		assert (succeeded_download.message_id == 0);
		assert (succeeded_download.post_processing_time.total_seconds == 26);
		assert (succeeded_download.download_time.total_seconds == 516);
		assert (succeeded_download.completed.to_unix () == 1334572608);
		assert (succeeded_download.storage_path == "/home/me/Downloads/spam");
		assert (succeeded_download.error_message == "");
		assert (succeeded_download.verification_percentage == 100);
		assert (succeeded_download.repair_percentage == 100);
		assert (succeeded_download.unpack_percentage == 100);
		assert (succeeded_download.recovery_block_count == 0);

		Download failed_download = downloads[1];
		assert (failed_download.id == "ham");
		assert (failed_download.status == DownloadStatus.FAILED);
		assert (failed_download.file_name == "ham.nzb");
		assert (failed_download.name == "ham");
		assert (failed_download.average_age == null);
		// TODO: Should be size_left.bytes == 0
		assert (failed_download.time_left == null);
		assert (failed_download.size.bytes == 109325686);
		assert (failed_download.size_left == null);
		assert (failed_download.eta == null);
		assert (failed_download.percentage == 100);
		assert (failed_download.script == "");
		assert (failed_download.category == "*");
		assert (failed_download.post_processing == DownloadPostProcessing.UNPACK);
		assert (failed_download.message_id == 0);
		assert (failed_download.post_processing_time.total_seconds == 2);
		assert (failed_download.download_time.total_seconds == 123);
		assert (failed_download.completed.to_unix () == 1332688445);
		assert (failed_download.storage_path == "/home/me/Downloads/incomplete/ham");
		assert (failed_download.error_message == "Repair failed, not enough repair blocks (10 short)");
		// TODO: GetHistoryQuery currently does not determine what post-processing
		// phases could be completed successfully. In this case, verification has
		// been completed successfully, but repairing has not.
		assert (failed_download.verification_percentage == 0);
		assert (failed_download.repair_percentage == 0);
		assert (failed_download.unpack_percentage == 0);
		assert (failed_download.recovery_block_count == 0);

	}

}
