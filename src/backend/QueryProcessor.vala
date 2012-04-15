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

public interface Lottanzb.QueryProcessor : Object, QueryNotifier<Query> {

	public abstract ConnectionInfo connection_info { get; construct set; }
	
	public abstract QueryNotifier<T> get_query_notifier<T> ();

	// public abstract Query set_config (string section, string key, string value);
	
	public abstract GetConfigQuery get_config ();
	
	/* public abstract Query delete_config (string section, string key);
	
	public abstract Query get_status ();
	
	public abstract Query get_capabilities ();
	
	public abstract Query set_completion_action (CompletionAction completion_action); */
	
	public abstract GetQueueQuery get_queue ();
	
	/* public abstract Query sort_queue (QueueSortField field, QueueSortDirection direction); */
	
	public abstract DeleteDownloadsQuery delete_downloads (Gee.List<string> download_ids);
	
	/* public abstract Query delete_all_downloads ();
	
	public abstract Query delete_file (string download_id, string file_id); */

	public abstract RenameDownloadQuery rename_download (string download_id, string new_name);
	
	/* public abstract Query purge_queue (); */
	
	public abstract PauseDownloadsQuery pause_downloads (Gee.List<string> download_ids);
	
	public abstract ResumeDownloadsQuery resume_downloads (Gee.List<string> download_ids);
	
	/* public abstract Query retry (string file_name, string download_id); */
	
	public abstract SwitchDownloadsQuery switch_downloads (string first_download_id, string second_download_id);

	public abstract SetDownloadPriorityQuery set_download_priority (Gee.List<string> download_ids, DownloadPriority new_priority);
	
	/* public abstract Query set_download_category (string category, string download_ids, ...);
	
	public abstract Query set_download_script (string script, string download_ids, ...);

	public abstract Query set_download_post_processing (string post_processing, string download_ids, ...);

	public abstract Query add_download_by_file (string file_name);
	
	public abstract Query add_download_by_url (string url);
	
	public abstract Query add_download_by_id (string id);
	
	public abstract Query get_files (string download_id); */
	
	public abstract GetHistoryQuery get_history ();
	
	/* public abstract Query delete_history (string download_ids, ...);
	
	public abstract Query purge_history (); */
	
	public abstract PauseQuery pause ();

	public abstract ResumeQuery resume ();
	
	/* public abstract Query shutdown ();
	
	public abstract Query restart ();
	
	public abstract Query restart_repair ();
	
	public abstract Query rescan (); */
	
	public abstract GetWarningsQuery get_warnings ();
	
	/* public abstract Query clear_warnings ();
	
	public abstract Query get_scripts (); */
	
	public abstract GetVersionQuery get_version ();
	
	/* public abstract Query get_speed_limit ();
	
	public abstract Query set_speed_limit ();
	
	public abstract Query get_newzbin_bookmarks (); */
	
	public abstract GetAuthenticationTypeQuery get_authentication_type ();

}
		
