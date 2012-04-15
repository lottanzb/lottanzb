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


public class Lottanzb.MockQuery<R> : Object, Query<R> {
	
	private R _response;
	
	public MockQuery (R response) {
		this._response = response;
		this.has_completed = true;
		this.has_succeeded = true;
	}
	
	public R get_response () {
		return _response;
	}

	public bool has_completed { get; set; }
	public bool has_succeeded { get; set; }

}

public class Lottanzb.SimpleMockQuery : MockQuery<Object> {

	public SimpleMockQuery () {
		base (new Object ());
	}

}

public class Lottanzb.MockGetConfigQuery : GetConfigQuery, MockQuery<Json.Object> {

	public MockGetConfigQuery (Json.Object response) {
		base (response);
	}
	
}

public class Lottanzb.MockGetQueueQuery : GetQueueQuery, MockQuery<GetQueueQueryResponse> {

	public MockGetQueueQuery (GetQueueQueryResponse response) {
		base (response);
	}

}

public class Lottanzb.MockDeleteDownloadsQuery : DeleteDownloadsQuery, SimpleMockQuery {

	public Gee.List<string> download_ids { get; construct set; }

	public MockDeleteDownloadsQuery (Gee.List<string> download_ids) {
		base ();
		this.download_ids = download_ids;
	}

}

public class Lottanzb.MockRenameDownloadQuery : RenameDownloadQuery, SimpleMockQuery {

	public string download_id { get; construct set; }
	public string new_name { get; construct set; }

	public MockRenameDownloadQuery (string download_id, string new_name) {
		base ();
		this.download_id = download_id;
		this.new_name = new_name;
	}

}

public class Lottanzb.MockPauseDownloadsQuery : PauseDownloadsQuery, SimpleMockQuery {

	public Gee.List<string> download_ids { get; construct set; }

	public MockPauseDownloadsQuery (Gee.List<string> download_ids) {
		base ();
		this.download_ids = download_ids;
	}

}

public class Lottanzb.MockResumeDownloadsQuery : ResumeDownloadsQuery, SimpleMockQuery {

	public Gee.List<string> download_ids { get; construct set; }

	public MockResumeDownloadsQuery (Gee.List<string> download_ids) {
		base ();
		this.download_ids = download_ids;
	}

}

public class Lottanzb.MockSwitchDownloadsQuery : SwitchDownloadsQuery, SimpleMockQuery {

	public string first_download_id { get; construct set; }
	public string second_download_id { get; construct set; }

	public MockSwitchDownloadsQuery (string first_download_id, string second_download_id) {
		base ();
		this.first_download_id = first_download_id;
		this.second_download_id = second_download_id;
	}

}

public class Lottanzb.MockSetDownloadPriorityQuery : SetDownloadPriorityQuery, SimpleMockQuery {

	public Gee.List<string> download_ids { get; construct set; }
	public DownloadPriority new_priority { get; construct set; }

	public MockSetDownloadPriorityQuery (Gee.List<string> download_ids, DownloadPriority new_priority) {
		base ();
		this.download_ids = download_ids;
		this.new_priority = new_priority;
	}

}

public class Lottanzb.MockGetHistoryQuery : GetHistoryQuery, MockQuery<GetHistoryQueryResponse> {

	public MockGetHistoryQuery (GetHistoryQueryResponse response) {
		base (response);
	}

}

public class Lottanzb.MockPauseQuery : PauseQuery, SimpleMockQuery {

}

public class Lottanzb.MockResumeQuery : ResumeQuery, SimpleMockQuery {

}

public class Lottanzb.MockGetWarningsQuery : GetWarningsQuery, MockQuery<Gee.List<LogMessage>> {

	public MockGetWarningsQuery (Gee.List<LogMessage> response) {
		base (response);
	}

}

public class Lottanzb.MockGetVersionQuery : GetVersionQuery, MockQuery<string> {

	public MockGetVersionQuery (string response) {
		base (response);
	}

}

public class Lottanzb.MockGetAuthenticationTypeQuery : GetAuthenticationTypeQuery, Query<AuthenticationType>, Object {

	public AuthenticationType response { get; construct set; }
	public bool has_completed { get; set; }
	public bool has_succeeded { get; set; }

	public MockGetAuthenticationTypeQuery (AuthenticationType response) {
		this.response = response;
		this.has_completed = true;
		this.has_succeeded = true;
	}
	
	public AuthenticationType get_response () {
		return response;
	}

}
