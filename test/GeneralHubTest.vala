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

private class GeneralHubTestMockQueryProcessor : MockQueryProcessor {

	public override GetQueueQuery make_get_queue_query () {
		var get_queue_query = new GetQueueQueryImpl ();
		var raw_response = get_fixture ("get_queue_query_response.json");
		get_queue_query.set_raw_response (raw_response);
		return get_queue_query;
	}

	public override GetHistoryQuery make_get_history_query () {
		var get_history_query = new GetHistoryQueryImpl ();
		var raw_response = get_fixture ("get_history_query_response.json");
		get_history_query.set_raw_response (raw_response);
		return get_history_query;
	}

}

public class Lottanzb.GeneralHubTest : Lottanzb.TestSuiteBuilder {

	// Provide direct references for convenient access
	private GeneralHub general_hub;
	private MockQueryProcessor query_processor;
	private DownloadListStore list_store;
	private bool has_row_changed;

	public GeneralHubTest () {
		base ("general_hub");
		add_test_suite (new DownloadTest ().get_suite ());
		add_test_suite (new DownloadListStoreUpdaterTest ().get_suite ());
		add_test ("moving_downloads", test_moving_downloads);
		add_test ("download_name_binding", test_download_name_binding);
		add_test ("download_priority_binding", test_download_priority_binding);
		add_test ("download_status_binding", test_download_status_binding);
	}

	public override void set_up () {
		query_processor = new GeneralHubTestMockQueryProcessor ();
		general_hub = new GeneralHubImpl (query_processor);
		list_store = general_hub.download_list_store;
		has_row_changed = false;
		list_store.row_changed.connect ((model, path, iter) => {
			has_row_changed = true;
		});
	}

	public override void tear_down () {
		general_hub = null;
		query_processor = null;
		list_store = null;
	}

	private void assert_order (DownloadListStoreMixin download_list_store, string[] order) {
		assert_download_list_store_download_order (download_list_store, order);
	}

	private void assert_last_switch_download_query_arguments (string first_download_id, string second_download_id) {
		var switch_download_queries = query_processor.get_queries<SwitchDownloadsQuery> ();
		assert (switch_download_queries.size > 0);
		var last_query = switch_download_queries[switch_download_queries.size - 1];
		assert (last_query.first_download_id == first_download_id);
		assert (last_query.second_download_id == second_download_id);
	}

	private void assert_query_count<T> (int count) {
		assert (query_processor.get_query_count<T> () == count);
	}

	private void assert_has_row_changed_and_reset () {
		assert (has_row_changed);
		has_row_changed = false;
	}

	public void test_moving_downloads () {
		var queue = list_store.get_filter_not_fully_loaded ();
		assert_order (list_store, new string[] { "spam", "ham", "foo", "bar", "baz" });
		assert_order (queue, new string[] { "foo", "bar", "baz" });
		general_hub.force_download (list_store.get_download_by_id ("baz"));
		assert_last_switch_download_query_arguments ("baz", "foo");
		assert_order (queue, new string[] { "baz", "foo", "bar" });
		general_hub.force_download (list_store.get_download_by_id ("baz"));
		assert_query_count<SwitchDownloadsQuery> (1);
		assert_order (queue, new string[] { "baz", "foo", "bar" });
		general_hub.move_download_up (list_store.get_download_by_id ("bar"));
		assert_last_switch_download_query_arguments ("bar", "foo");
		assert_order (queue, new string[] { "baz", "bar", "foo" });
		general_hub.move_download_down (list_store.get_download_by_id ("bar"));
		assert_last_switch_download_query_arguments ("bar", "foo");
		assert_order (queue, new string[] { "baz", "foo", "bar" });
		general_hub.move_download_down_to_bottom (list_store.get_download_by_id ("baz"));
		assert_last_switch_download_query_arguments ("baz", "bar");
		assert_order (queue, new string[] { "foo", "bar", "baz" });

		// TODO: Check invalid operations
		// TODO: Check side-effects
	}

	public void test_download_name_binding () {
		var download = list_store.get_download_by_id ("foo");
		assert (download.name == "foo");
		// Assert that changing the name of a Download triggers a RenameDownloadQuery
		// and emits the 'row-changed' signal of the DownloadListStore.
		download.name = "bar";
		var query = query_processor.get_first_query<RenameDownloadQuery> ();
		assert (query.new_name == "bar");
		assert_has_row_changed_and_reset ();
		query_processor.rename_download.begin (download.id, "baz");
		// Assert that running a RenameDownloadQuery changes the download name,
		// but does not trigger a subsequent (useless) RenameDownloadQuery.
		assert_query_count<RenameDownloadQuery> (2);
		assert_has_row_changed_and_reset ();
		assert (download.name == "baz");
		// Assert that during a subsequent DownloadListStore update using remote data,
		// no accidental RenameDownloadQueries are run.
		query_processor.get_queue.begin ();
		query_processor.get_history.begin ();
		assert_query_count<RenameDownloadQuery> (2);
	}

	public void test_download_priority_binding () {
		var download = list_store.get_download_by_id ("foo");
		assert (download.priority == DownloadPriority.NORMAL);
		// Assert that changing the priority of a Download triggers a
		// SetDownloadPriorityQuery and emits the 'row-changed' signal of the
		// DownloadListStore.
		download.priority = DownloadPriority.FORCE;
		var query = query_processor.get_first_query<SetDownloadPriorityQuery> ();
		assert (query.new_priority == DownloadPriority.FORCE);
		assert_has_row_changed_and_reset ();
		query_processor.set_single_download_priority.begin (download.id, DownloadPriority.HIGH);
		// Assert that running a SetDownloadPriorityQuery changes the download name,
		// but does not trigger a subsequent (useless) SetDownloadPriorityQuery.
		assert_query_count<SetDownloadPriorityQuery> (2);
		assert_has_row_changed_and_reset ();
		assert (download.priority == DownloadPriority.HIGH);
		// Assert that during a subsequent DownloadListStore update using remote data,
		// no accidental SetDownloadPriorityQueries are run.
		query_processor.get_queue.begin ();
		query_processor.get_history.begin ();
		assert_query_count<SetDownloadPriorityQuery> (2);
	}

	public void test_download_status_binding () {
		var download = list_store.get_download_by_id ("foo");
		assert (download.status == DownloadStatus.DOWNLOADING);
		// Assert that changing the status of a Download triggers a PauseDownloadsQuery
		// and emits the 'row-changed' signal of the DownloadListStore.
		download.status = DownloadStatus.PAUSED;
		assert_query_count<PauseDownloadsQuery> (1);
		assert_has_row_changed_and_reset ();

		// Assert that changing the status of a Download triggers a ResumeDownloadsQuery
		// and emits the 'row-changed' signal of the DownloadListStore.
		download.status = DownloadStatus.QUEUED;
		assert_query_count<ResumeDownloadsQuery> (1);
		assert_has_row_changed_and_reset ();
	}

}


