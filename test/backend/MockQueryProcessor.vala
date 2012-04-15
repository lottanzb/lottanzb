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


public class Lottanzb.MockQueryProcessor : Object, QueryProcessor, QueryNotifier<Query> {

	public ConnectionInfo connection_info { get; construct set; }
	
	public MockQueryProcessor (ConnectionInfo connection_info) {
		this.connection_info = connection_info;
	}

	public QueryNotifier<T> get_query_notifier<T> () {
		var result = new FilteringQueryNotifier<T> (this);
		return result;
	}
	
	public GetConfigQuery get_config () {
		var response = new Json.Object ();
		var query = new MockGetConfigQuery (response);
		return query;
	}
	
	public GetQueueQuery get_queue () {
		var response = new MockGetQueueQueryResponse ();
		var query = new MockGetQueueQuery (response);
		return query;
	}

	public DeleteDownloadsQuery delete_downloads (Gee.List<string> download_ids) {
		var query = new MockDeleteDownloadsQuery (download_ids);
		return query;
	}

	public RenameDownloadQuery rename_download (string download_id, string new_name) {
		var query = new MockRenameDownloadQuery (download_id, new_name);
		return query;
	}

	public PauseDownloadsQuery pause_downloads (Gee.List<string> download_ids) {
		var query = new MockPauseDownloadsQuery (download_ids);
		return query;
	}
	
	public ResumeDownloadsQuery resume_downloads (Gee.List<string> download_ids) {
		var query = new MockResumeDownloadsQuery (download_ids);
		return query;
	}

	public SwitchDownloadsQuery switch_downloads (string first_download_id, string second_download_id) {
		var query = new MockSwitchDownloadsQuery (first_download_id, second_download_id);
		return query;
	}

	public SetDownloadPriorityQuery set_download_priority (Gee.List<string> download_ids, DownloadPriority new_priority) {
		var query = new MockSetDownloadPriorityQuery (download_ids, new_priority);
		return query;
	}
	
	public GetHistoryQuery get_history () {
		var response = new MockGetHistoryQueryResponse.empty ();
		var query = new MockGetHistoryQuery (response);
		return query;
	}

	public PauseQuery pause () {
		var query = new MockPauseQuery ();
		return query;
	}
	
	public ResumeQuery resume () {
		var query = new MockResumeQuery ();
		return query;
	}

	public GetWarningsQuery get_warnings () {
		var log_messages = new Gee.ArrayList<LogMessage> ();
		var query = new MockGetWarningsQuery (log_messages);
		return query;
	}
	
	public GetVersionQuery get_version () {
		var response = "0.6.0";
		var query = new MockGetVersionQuery (response);
		return query;
	}
	
	public GetAuthenticationTypeQuery get_authentication_type () {
		var response = AuthenticationType.NOTHING;
	   	var query = new MockGetAuthenticationTypeQuery (response);
		return query;	
	}

}
