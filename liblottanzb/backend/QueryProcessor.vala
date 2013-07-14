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


public enum Lottanzb.QueueSortField {
	INDEX,
	NAME,
	SIZE,
	AGE
}

public enum Lottanzb.QueueSortDirection {
	ASCENDING,
	DESCENDING
}

public enum Lottanzb.CompletionAction {
	SHUTDOWN_COMPUTER,
	HIBERNATE_COMPUTER,
	STANDBY_COMPUTER,
	SHUTDOWN_PROGRAM
}

public enum Lottanzb.AuthenticationType {
	NOTHING,
	USERNAME_AND_PASSWORD,
	API_KEY
}

public interface Lottanzb.QueryProcessor<T> : Object, QueryNotifier<Query> {

	public abstract ConnectionInfo connection_info { get; construct set; }
	
	public abstract QueryNotifier<T> get_query_notifier<T> ();

	public abstract async void run_query (T query) throws QueryError;

	/**
	 * Performs two initial queries to the SABnzbd instance in order to check
	 * if the connection can be established.
	 *
	 * Also check if SABnzbd version is supported and whether the username,
	 * password as well as the API key are valid.
	 *
	 * May throw a `QueryError`
	 */
	public async void handshake () throws QueryError {
		var version_query = yield get_version ();
		var version = version_query.get_response ();
		debug (@"SABnzbd has supported version $version.");

		yield authenticate ();
		debug (@"SABnzbd credentials verified.");
	}

	public abstract SetConfigQuery make_set_config_query (Gee.List<string> path, Gee.Map<string, string> entries);
	
	public async SetConfigQuery set_config (Gee.List<string> path, Gee.Map<string, string> entries) throws QueryError {
		var query = make_set_config_query (path, entries);
		yield run_query (query);
		return query;
	}

	public abstract GetConfigQuery make_get_config_query ();
	
	public async GetConfigQuery get_config () throws QueryError {
		var query = make_get_config_query ();
		yield run_query (query);
		return query;
	}
	
	public abstract DeleteConfigQuery make_delete_config_query (Gee.List<string> path, string key);

	public async DeleteConfigQuery delete_config (Gee.List<string> path, string key) throws QueryError {
		var query = make_delete_config_query (path, key);
		yield run_query (query);
		return query;
	}
	
	/* public abstract Query get_status ();
	
	public abstract Query get_capabilities ();
	
	public abstract Query set_completion_action (CompletionAction completion_action); */
	
	public abstract GetQueueQuery make_get_queue_query ();

	public async GetQueueQuery get_queue () throws QueryError {
		var query = make_get_queue_query ();
		yield run_query (query);
		return query;
	}

	/* public abstract Query sort_queue (QueueSortField field, QueueSortDirection direction); */
	
	public abstract DeleteDownloadsQuery make_delete_downloads_query (Gee.List<string> download_ids);
	
	public async DeleteDownloadsQuery delete_downloads (Gee.List<string> download_ids) throws QueryError {
		var query = make_delete_downloads_query (download_ids);
		yield run_query (query);
		return query;
	}

	/* public abstract Query delete_all_downloads ();
	
	public abstract Query delete_file (string download_id, string file_id); */

	public abstract RenameDownloadQuery make_rename_download_query (string download_id, string new_name);
	
	public async RenameDownloadQuery rename_download (string download_id, string new_name) throws QueryError {
		var query = make_rename_download_query (download_id, new_name);
		yield run_query (query);
		return query;
	}

	/* public abstract Query purge_queue (); */
	
	public abstract PauseDownloadsQuery make_pause_downloads_query (Gee.List<string> download_ids);
	
	public async PauseDownloadsQuery pause_downloads (Gee.List<string> download_ids) throws QueryError {
		var query = make_pause_downloads_query (download_ids);
		yield run_query (query);
		return query;
	}

	public async PauseDownloadsQuery pause_download (string download_id) throws QueryError {
		var download_ids = new Gee.ArrayList<string> ();
		download_ids.add (download_id);
		var query = yield pause_downloads (download_ids);
		return query;
	}

	public abstract ResumeDownloadsQuery make_resume_downloads_query (Gee.List<string> download_ids);
	
	public async ResumeDownloadsQuery resume_downloads (Gee.List<string> download_ids) throws QueryError {
		var query = make_resume_downloads_query (download_ids);
		yield run_query (query);
		return query;
	}

	public async ResumeDownloadsQuery resume_download (string download_id) throws QueryError {
		var download_ids = new Gee.ArrayList<string> ();
		download_ids.add (download_id);
		var query = yield resume_downloads (download_ids);
		return query;
	}

	/* public abstract Query retry (string file_name, string download_id); */
	
	public abstract SwitchDownloadsQuery make_switch_downloads_query (string first_download_id, string second_download_id);

	public async SwitchDownloadsQuery switch_downloads (string first_download_id, string second_download_id) throws QueryError {
		var query = make_switch_downloads_query (first_download_id, second_download_id);
		yield run_query (query);
		return query;
	}

	public abstract SetDownloadPriorityQuery make_set_download_priority_query (Gee.List<string> download_ids, DownloadPriority new_priority);
	
	public async SetDownloadPriorityQuery set_download_priority (Gee.List<string> download_ids, DownloadPriority new_priority) throws QueryError {
		var query = make_set_download_priority_query (download_ids, new_priority);
		yield run_query (query);
		return query;
	}

	public async SetDownloadPriorityQuery set_single_download_priority (string download_id, DownloadPriority new_priority) throws QueryError {
		var download_ids = new Gee.ArrayList<string> ();
		download_ids.add (download_id);
		var query = yield set_download_priority (download_ids, new_priority);
		return query;
	}

	/* public abstract Query set_download_category (string category, string download_ids, ...);
	
	public abstract Query set_download_script (string script, string download_ids, ...);

	public abstract Query set_download_post_processing (string post_processing, string download_ids, ...); */

	public abstract AddDownloadQuery make_add_download_query (string uri,
		AddDownloadQueryOptionalArguments optional_arguments);

	public async AddDownloadQuery add_download (string uri,
		AddDownloadQueryOptionalArguments optional_arguments) throws QueryError {
		var query = make_add_download_query (uri, optional_arguments);
		yield run_query (query);
		return query;
	}
	
	/* public abstract Query add_download_by_id (string id);
	
	public abstract Query get_files (string download_id); */
	
	public abstract GetHistoryQuery make_get_history_query ();
	
	public async GetHistoryQuery get_history () throws QueryError {
		var query = make_get_history_query ();
		yield run_query (query);
		return query;
	}

	/* public abstract Query delete_history (string download_ids, ...);
	
	public abstract Query purge_history (); */
	
	public abstract PauseQuery make_pause_query ();

	public async PauseQuery pause () throws QueryError {
		var query = make_pause_query ();
		yield run_query (query);
		return query;
	}

	public abstract ResumeQuery make_resume_query ();
	
	public async ResumeQuery resume () throws QueryError {
		var query = make_resume_query ();
		yield run_query (query);
		return query;
	}

	/* public abstract Query shutdown ();
	
	public abstract Query restart ();
	
	public abstract Query restart_repair ();
	
	public abstract Query rescan (); */
	
	public abstract GetWarningsQuery make_get_warnings_query ();
	
	public async GetWarningsQuery get_warnings () throws QueryError {
		var query = make_get_warnings_query ();
		yield run_query (query);
		return query;
	}

	/* public abstract Query clear_warnings ();
	
	public abstract Query get_scripts (); */
	
	public abstract GetVersionQuery make_get_version_query ();
	
	public async GetVersionQuery get_version () throws QueryError {
		var query = make_get_version_query ();
		yield run_query (query);
		return query;
	}

	/* public abstract Query get_speed_limit ();
	
	public abstract Query set_speed_limit ();
	
	public abstract Query get_newzbin_bookmarks (); */
	
	public abstract AuthenticateQuery make_authenticate_query ();

	public async AuthenticateQuery authenticate () throws QueryError {
		var query = make_authenticate_query ();
		yield run_query (query);
		return query;
	}

	public abstract GetAuthenticationTypeQuery make_get_authentication_type_query ();

	public async GetAuthenticationTypeQuery get_authentication_type () throws QueryError {
		var query = make_get_authentication_type_query ();
		yield run_query (query);
		return query;
	}

}
		
