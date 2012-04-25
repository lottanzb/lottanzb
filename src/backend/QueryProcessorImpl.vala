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

public class Lottanzb.QueryProcessorImpl : Object, QueryNotifier<Query>, QueryProcessor<QueryImpl> {

	private Gee.Map<Type, FilteringQueryNotifier> filtering_query_notifiers;
	public ConnectionInfo connection_info { get; construct set; }
	
	public QueryProcessorImpl (ConnectionInfo connection_info) {
		this.connection_info = connection_info;
		this.filtering_query_notifiers = new Gee.HashMap<Type, FilteringQueryNotifier> ();
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
	
	public void run_query (QueryImpl query) {
		query_started (query);
		var url = build_url (query);
		var session = new Soup.SessionSync ();
		var message = new Soup.Message ("GET", url);
		session.send_message (message);
		try {
			var raw_response = (string) message.response_body.flatten ().data;
			query.set_raw_response (raw_response);
		} catch (Error e) {
			stderr.printf ("Query failed: %s", e.message);
		}
		query_completed (query);
	}
	
	private string build_url (QueryImpl query) {
		var api_url = connection_info.api_url;
		var arguments = new HashTable<string, string> (str_hash, str_equal);
		foreach (var entry in query.arguments.entries) {
			arguments.set (entry.key, entry.value);
		}
		if (connection_info.requires_authentication) {
			arguments.set ("ma_username", connection_info.username);
			arguments.set ("ma_password", connection_info.password);
		}
		if (connection_info.api_key != null) {
			arguments.set ("apikey", connection_info.api_key);
		}
		var url = api_url + "?" + Soup.Form.encode_hash (arguments);
		return url;
	}

	public SetConfigQuery make_set_config_query (Gee.List<string> path, Gee.Map<string, string> entries) {
		var query = new SetConfigQueryImpl (path, entries);
		return query;
	}

	public GetConfigQuery make_get_config_query () {
		var query = new GetConfigQueryImpl ();
		return query;
	}
	
	/* public Query delete_config (string section, string key) {
		var query = new QueryImpl("del_config");
		return query;
	}
	
	public Query get_status () {
		var query = new QueryImpl("qstatus");
		return query;
	}
	
	public Query get_capabilities () {
		var query = new QueryImpl("options");
		return query;
	}
	
	public Query set_completion_action (CompletionAction completion_action) {
		var query = new QueryImpl("queue");
		return query;
	}
	*/
	
	public GetQueueQuery make_get_queue_query () {
		var query = new GetQueueQueryImpl ();
		return query;
	}
	
	/*
	public Query sort_queue (QueueSortField field, QueueSortDirection direction) {
		var query = new QueryImpl("queue");
		return query;
	} */
	
	public DeleteDownloadsQuery make_delete_downloads_query (Gee.List<string> download_ids) {
		var query = new DeleteDownloadsQueryImpl (download_ids);
		return query;
	}
	
	/* public Query delete_all_downloads () {
		var query = new QueryImpl("queue");
		return query;
	}
	
	public Query delete_file (string download_id, string file_id) {
		var query = new QueryImpl("queue");
		return query;
	} */

	public RenameDownloadQuery make_rename_download_query (string download_id, string new_name) {
		var query = new RenameDownloadQueryImpl (download_id, new_name);
		return query;
	}

	/* public Query purge_queue () {
		var query = new QueryImpl("queue");
		return query;
	} */
	
	public PauseDownloadsQuery make_pause_downloads_query (Gee.List<string> download_ids) {
		var query = new PauseDownloadsQueryImpl (download_ids);
		return query;
	}
	
	public ResumeDownloadsQuery make_resume_downloads_query (Gee.List<string> download_ids) {
		var query = new ResumeDownloadsQueryImpl (download_ids);
		return query;
	}
	
	/* public Query retry (string file_name, string download_id) {
		var query = new QueryImpl("retry");
		return query;
	} */
	
	public SwitchDownloadsQuery make_switch_downloads_query (string first_download_id, string second_download_id) {
		var query = new SwitchDownloadsQueryImpl (first_download_id, second_download_id);
		return query;
	}

	public SetDownloadPriorityQuery make_set_download_priority_query (Gee.List<string> download_ids, DownloadPriority new_priority) {
		var query = new SetDownloadPriorityQueryImpl (download_ids, new_priority);
		return query;
	}
	
	/* public Query set_download_category (string category, string download_ids, ...) {
		var query = new QueryImpl("change_cat");
		return query;
	}
	
	public Query set_download_script (string script, string download_ids, ...) {
		var query = new QueryImpl("change_script");
		return query;
	}

	public Query set_download_post_processing (string post_processing, string download_ids, ...) {
		var query = new QueryImpl("change_opts");
		return query;
	}

	public Query add_download_by_file (string file_name) {
		var query = new QueryImpl("");
		return query;
	}
	
	public Query add_download_by_url (string url) {
		var query = new QueryImpl("addurl");
		return query;
	}
	
	public Query add_download_by_id (string id) {
		var query = new QueryImpl("addid");
		return query;
	}
	
	public Query get_files (string download_id) {
		var query = new QueryImpl("get_files");
		return query;
	} */
	
	public GetHistoryQuery make_get_history_query () {
		var query = new GetHistoryQueryImpl();
		return query;
	}
	
	/* public Query delete_history (string download_ids, ...) {
		var query = new QueryImpl("history");
		return query;
	}
	
	public Query purge_history () {
		var query = new QueryImpl("history");
		return query;
	} */

	public PauseQuery make_pause_query () {
		var query = new PauseQueryImpl ();
		return query;
	}
	
	public ResumeQuery make_resume_query () {
		var query = new ResumeQueryImpl ();
		return query;
	}
	
	/* public Query restart () {
		var query = new QueryImpl("restart");
		return query;
	}
	
	public Query restart_repair () {
		var query = new QueryImpl("restart-repair");
		return query;
	}
	
	public Query rescan () {
		var query = new QueryImpl("rescan");
		return query;
	} */
	
	public GetWarningsQuery make_get_warnings_query () {
		var query = new GetWarningsQueryImpl ();
		return query;
	}
	
	/* public Query clear_warnings () {
		var query = new QueryImpl("warnings");
		return query;
	}
	
	public Query get_scripts () {
		var query = new QueryImpl("get_scrips");
		return query;
	} */
	
	public GetVersionQuery make_get_version_query () {
		var query = new GetVersionQueryImpl ();
		return query;
	}
	
	/* public Query get_speed_limit () {
		var query = new QueryImpl("config");
		return query;
	}
	
	public Query set_speed_limit () {
		var query = new QueryImpl("config");
		return query;
	}
	
	public Query get_newzbin_bookmarks () {
		var query = new QueryImpl("newzbin");
		return query;
	} */
	
	public GetAuthenticationTypeQuery make_get_authentication_type_query () {
		var query = new GetAuthenticationTypeQueryImpl ();
		return query;
	}

}
