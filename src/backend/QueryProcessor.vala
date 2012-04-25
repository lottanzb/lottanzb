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

	public abstract void run_query (T query);

	public abstract SetConfigQuery make_set_config_query (Gee.List<string> path, Gee.Map<string, string> entries);
	
	public SetConfigQuery set_config (Gee.List<string> path, Gee.Map<string, string> entries) {
		var query = make_set_config_query (path, entries);
		run_query (query);
		return query;
	}

	public abstract GetConfigQuery make_get_config_query ();
	
	public GetConfigQuery get_config () {
		var query = make_get_config_query ();
		run_query (query);
		return query;
	}
	
	public abstract DeleteConfigQuery make_delete_config_query (Gee.List<string> path, string key);

	public DeleteConfigQuery delete_config (Gee.List<string> path, string key) {
		var query = make_delete_config_query (path, key);
		run_query (query);
		return query;
	}
	
	/* public abstract Query get_status ();
	
	public abstract Query get_capabilities ();
	
	public abstract Query set_completion_action (CompletionAction completion_action); */
	
	public abstract GetQueueQuery make_get_queue_query ();

	public GetQueueQuery get_queue () {
		var query = make_get_queue_query ();
		run_query (query);
		return query;
	}

	/* public abstract Query sort_queue (QueueSortField field, QueueSortDirection direction); */
	
	public abstract DeleteDownloadsQuery make_delete_downloads_query (Gee.List<string> download_ids);
	
	public DeleteDownloadsQuery delete_downloads (Gee.List<string> download_ids) {
		var query = make_delete_downloads_query (download_ids);
		run_query (query);
		return query;
	}

	/* public abstract Query delete_all_downloads ();
	
	public abstract Query delete_file (string download_id, string file_id); */

	public abstract RenameDownloadQuery make_rename_download_query (string download_id, string new_name);
	
	public RenameDownloadQuery rename_download (string download_id, string new_name) {
		var query = make_rename_download_query (download_id, new_name);
		run_query (query);
		return query;
	}

	/* public abstract Query purge_queue (); */
	
	public abstract PauseDownloadsQuery make_pause_downloads_query (Gee.List<string> download_ids);
	
	public PauseDownloadsQuery pause_downloads (Gee.List<string> download_ids) {
		var query = make_pause_downloads_query (download_ids);
		run_query (query);
		return query;
	}

	public abstract ResumeDownloadsQuery make_resume_downloads_query (Gee.List<string> download_ids);
	
	public ResumeDownloadsQuery resume_downloads (Gee.List<string> download_ids) {
		var query = make_resume_downloads_query (download_ids);
		run_query (query);
		return query;
	}

	/* public abstract Query retry (string file_name, string download_id); */
	
	public abstract SwitchDownloadsQuery make_switch_downloads_query (string first_download_id, string second_download_id);

	public SwitchDownloadsQuery switch_downloads (string first_download_id, string second_download_id) {
		var query = make_switch_downloads_query (first_download_id, second_download_id);
		run_query (query);
		return query;
	}

	public abstract SetDownloadPriorityQuery make_set_download_priority_query (Gee.List<string> download_ids, DownloadPriority new_priority);
	
	public SetDownloadPriorityQuery set_download_priority (Gee.List<string> download_ids, DownloadPriority new_priority) {
		var query = make_set_download_priority_query (download_ids, new_priority);
		run_query (query);
		return query;
	}

	public SetDownloadPriorityQuery set_single_download_priority (string download_id, DownloadPriority new_priority) {
		var download_ids = new Gee.ArrayList<string> ();
		download_ids.add (download_id);
		var query = set_download_priority (download_ids, new_priority);
		return query;
	}

	/* public abstract Query set_download_category (string category, string download_ids, ...);
	
	public abstract Query set_download_script (string script, string download_ids, ...);

	public abstract Query set_download_post_processing (string post_processing, string download_ids, ...);

	public abstract Query add_download_by_file (string file_name);
	
	public abstract Query add_download_by_url (string url);
	
	public abstract Query add_download_by_id (string id);
	
	public abstract Query get_files (string download_id); */
	
	public abstract GetHistoryQuery make_get_history_query ();
	
	public GetHistoryQuery get_history () {
		var query = make_get_history_query ();
		run_query (query);
		return query;
	}

	/* public abstract Query delete_history (string download_ids, ...);
	
	public abstract Query purge_history (); */
	
	public abstract PauseQuery make_pause_query ();

	public PauseQuery pause () {
		var query = make_pause_query ();
		run_query (query);
		return query;
	}

	public abstract ResumeQuery make_resume_query ();
	
	public ResumeQuery resume () {
		var query = make_resume_query ();
		run_query (query);
		return query;
	}

	/* public abstract Query shutdown ();
	
	public abstract Query restart ();
	
	public abstract Query restart_repair ();
	
	public abstract Query rescan (); */
	
	public abstract GetWarningsQuery make_get_warnings_query ();
	
	public GetWarningsQuery get_warnings () {
		var query = make_get_warnings_query ();
		run_query (query);
		return query;
	}

	/* public abstract Query clear_warnings ();
	
	public abstract Query get_scripts (); */
	
	public abstract GetVersionQuery make_get_version_query ();
	
	public GetVersionQuery get_version () {
		var query = make_get_version_query ();
		run_query (query);
		return query;
	}

	/* public abstract Query get_speed_limit ();
	
	public abstract Query set_speed_limit ();
	
	public abstract Query get_newzbin_bookmarks (); */
	
	public abstract GetAuthenticationTypeQuery make_get_authentication_type_query ();

	public GetAuthenticationTypeQuery get_authentication_type () {
		var query = make_get_authentication_type_query ();
		run_query (query);
		return query;
	}

}
		
