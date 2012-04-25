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

public ConnectionInfo make_mock_connection_info () {
	var connection_info = new ConnectionInfo ("localhost", 119, "", "", "", false);
	return connection_info;

}

public class Lottanzb.MockQueryProcessor : Object, QueryNotifier<Query>, QueryProcessor<Query> {

	private Gee.Map<Type, FilteringQueryNotifier> filtering_query_notifiers;
	private Gee.Map<Type, Gee.List<Query>> queries_by_type;
	public ConnectionInfo connection_info { get; construct set; }
	
	public MockQueryProcessor.with_connection_info (ConnectionInfo connection_info) {
		this.connection_info = connection_info;
		this.filtering_query_notifiers = new Gee.HashMap<Type, FilteringQueryNotifier> ();
		this.queries_by_type = new Gee.HashMap<Type, Gee.List<Query>> ();
	}

	public MockQueryProcessor () {
		this.with_connection_info (make_mock_connection_info ());
	}
	
	public QueryNotifier<T> get_query_notifier<T> () {
		Type query_type = typeof (T);
		FilteringQueryNotifier<T>? result = filtering_query_notifiers [query_type];
		if (result == null) {
			result = new FilteringQueryNotifier<T> (this);
			filtering_query_notifiers [query_type] = result;
		}
		return result;
	}

	public Gee.List<T> get_queries<T> () {
		Type query_type = typeof (T);
		Gee.List<T> result = new Gee.ArrayList<T> ();
		foreach (var type in queries_by_type.keys) {
			if (type.is_a (query_type)) {
				result.add_all (queries_by_type [type]);
			}
		}
		return result;
	}

	public bool has_queries<T> () {
		Type query_type = typeof (T);
		foreach (var type in queries_by_type.keys) {
			if (type.is_a (query_type)) {
				return true;
			}
		}
		return false;
	}

	public void run_query (Query query) {
		Type query_type = Type.from_instance (query); 
		Gee.List<Query>? queries_of_same_type = queries_by_type [query_type];
		if (queries_of_same_type == null) {
			queries_of_same_type = new Gee.ArrayList<Query> ();
			queries_by_type [query_type] = queries_of_same_type;
		}
		queries_of_same_type.add (query);
		query_started (query);
		query_completed (query);
	}

	public SetConfigQuery make_set_config_query (Gee.List<string> path, Gee.Map<string, string> entries) {
		var query = new MockSetConfigQuery (path, entries);
		return query;
	}

	public GetConfigQuery make_get_config_query () {
		var response = new Json.Object ();
		var query = new MockGetConfigQuery (response);
		return query;
	}
	
	public DeleteConfigQuery make_delete_config_query (Gee.List<string> path, string key) {
		var query = new MockDeleteConfigQuery (path, key);
		return query;
	}

	public virtual GetQueueQuery make_get_queue_query () {
		var response = new MockGetQueueQueryResponse ();
		var query = new MockGetQueueQuery (response);
		return query;
	}

	public DeleteDownloadsQuery make_delete_downloads_query (Gee.List<string> download_ids) {
		var query = new MockDeleteDownloadsQuery (download_ids);
		return query;
	}

	public RenameDownloadQuery make_rename_download_query (string download_id, string new_name) {
		var query = new MockRenameDownloadQuery (download_id, new_name);
		return query;
	}

	public PauseDownloadsQuery make_pause_downloads_query (Gee.List<string> download_ids) {
		var query = new MockPauseDownloadsQuery (download_ids);
		return query;
	}
	
	public ResumeDownloadsQuery make_resume_downloads_query (Gee.List<string> download_ids) {
		var query = new MockResumeDownloadsQuery (download_ids);
		return query;
	}

	public SwitchDownloadsQuery make_switch_downloads_query (string first_download_id, string second_download_id) {
		var query = new MockSwitchDownloadsQuery (first_download_id, second_download_id);
		return query;
	}

	public SetDownloadPriorityQuery make_set_download_priority_query (Gee.List<string> download_ids, DownloadPriority new_priority) {
		var query = new MockSetDownloadPriorityQuery (download_ids, new_priority);
		return query;
	}

	public AddDownloadQuery make_add_download_query (string uri,
		AddDownloadQueryOptionalArguments optional_arguments) {
		var query = new MockAddDownloadQuery (uri, optional_arguments);
		return query;
	}
	
	public virtual GetHistoryQuery make_get_history_query () {
		var response = new MockGetHistoryQueryResponse.empty ();
		var query = new MockGetHistoryQuery (response);
		return query;
	}

	public PauseQuery make_pause_query () {
		var query = new MockPauseQuery ();
		return query;
	}
	
	public ResumeQuery make_resume_query () {
		var query = new MockResumeQuery ();
		return query;
	}

	public GetWarningsQuery make_get_warnings_query () {
		var log_messages = new Gee.ArrayList<LogMessage> ();
		var query = new MockGetWarningsQuery (log_messages);
		return query;
	}
	
	public GetVersionQuery make_get_version_query () {
		var response = "0.6.0";
		var query = new MockGetVersionQuery (response);
		return query;
	}
	
	public GetAuthenticationTypeQuery make_get_authentication_type_query () {
		var response = AuthenticationType.NOTHING;
	   	var query = new MockGetAuthenticationTypeQuery (response);
		return query;	
	}

}
