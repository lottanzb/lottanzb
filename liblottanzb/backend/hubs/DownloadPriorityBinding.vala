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

public class Lottanzb.DownloadPriorityBinding : DownloadPropertyBinding {

	public DownloadPriorityBinding (DownloadListStore download_list_store, QueryProcessor query_processor) {
		base (download_list_store, query_processor, "priority");
		this.query_processor.get_query_notifier<SetDownloadPriorityQuery> ()
			.query_started.connect (on_set_download_priority_query_started); 
	}

	public override void handle_download_property_change (Download download) {
		if (!download_list_store.is_updating) {
			base.handle_download_property_change (download);
			var new_priority = download.priority;
			query_processor.set_single_download_priority (download.id, new_priority);
		}
	}

	public void on_set_download_priority_query_started (QueryNotifier query_notifier,
			SetDownloadPriorityQuery query) {
		foreach (var download_id in query.download_ids) {
			var new_priority = query.new_priority;
			var download = download_list_store.get_download_by_id (download_id);
			if (download != null && download.priority != new_priority) {
				ignore_property_changes = true;
				download.priority = new_priority;
				ignore_property_changes = false;
				download_list_store.register_download_change (download);
			}
		}
	}

}
