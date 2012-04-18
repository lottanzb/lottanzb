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

private class CustomMockQueryProcessor : MockQueryProcessor {

	public override GetQueueQuery make_get_queue_query () {
		var queue_query = new GetQueueQueryImpl ();
		var raw_response = get_fixture ("get_queue_query_response.json");
		queue_query.set_raw_response (raw_response);
		return queue_query;
	}

}

public void test_general_hub_download_name_binding () {
	var query_processor = new CustomMockQueryProcessor ();
	var general_hub = new GeneralHub (query_processor);
	var list_store = general_hub.download_list_store;
	Gtk.TreeIter iter;
	list_store.get_iter_first (out iter);
	var download = list_store.get_download (iter);
	assert (download.name == "foo");
	bool has_row_changed = false;
	list_store.row_changed.connect ((model, path, iter) => {
		has_row_changed = true;
	});
	download.name = "bar";
	var rename_download_queries = query_processor.get_queries<RenameDownloadQuery> ();
	assert (rename_download_queries.size == 1);
	var rename_download_query = rename_download_queries[0];
	assert (rename_download_query.new_name == "bar");
	assert (has_row_changed);
	has_row_changed = false;
	query_processor.rename_download (download.id, "baz");
	assert (has_row_changed);
	assert (download.name == "baz");
}

public void test_general_hub_download_priority_binding () {
	var query_processor = new CustomMockQueryProcessor ();
	var general_hub = new GeneralHub (query_processor);
	var list_store = general_hub.download_list_store;
	Gtk.TreeIter iter;
	list_store.get_iter_first (out iter);
	var download = list_store.get_download (iter);
	assert (download.priority == DownloadPriority.NORMAL); 
	bool has_row_changed = false;
	list_store.row_changed.connect ((model, path, iter) => {
		has_row_changed = true;
	});
	download.priority = DownloadPriority.FORCE;
	var set_download_priority_queries = query_processor.get_queries<SetDownloadPriorityQuery> ();
	assert (set_download_priority_queries.size == 1);
	var set_download_priority_query = set_download_priority_queries[0];
	assert (set_download_priority_query.new_priority == DownloadPriority.FORCE);
	assert (has_row_changed);
	has_row_changed = false;
	query_processor.set_single_download_priority (download.id, DownloadPriority.HIGH);
	assert (has_row_changed);
	assert (download.priority == DownloadPriority.HIGH);
}
