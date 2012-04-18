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

public class Lottanzb.DownloadNameBinding : Object {

	public QueryProcessor query_processor { get; construct set; }
	public DownloadListStore download_list_store { get; construct set; }

	public DownloadNameBinding (DownloadListStore download_list_store, QueryProcessor query_processor) {
		this.query_processor = query_processor;
		this.query_processor.get_query_notifier<RenameDownloadQuery> ()
			.query_started.connect (on_download_rename_query_started); 
		this.download_list_store = download_list_store;
		foreach (var iter in this.download_list_store) {
			var download = this.download_list_store.get_download (iter);
			if (download != null) {
				handle_download_insertion (download);
			}
		}
		this.download_list_store.row_inserted.connect ((model, path, iter) => {
			var download = download_list_store.get_download (iter);
			if (download != null) {
				handle_download_insertion (download);
			}
		});
	}

	private void handle_download_insertion (Download download) {
		download.notify["name"].connect (on_download_name_changed);
	}

	public void on_download_name_changed (Object object, ParamSpec param) {
		var download = (Download) object;
		var new_name = download.name;
		query_processor.rename_download (download.id, new_name);
		download_list_store.register_download_change (download);
	}

	public void on_download_rename_query_started (QueryNotifier query_notifier,
		RenameDownloadQuery rename_download_query) {
		var download_id = rename_download_query.download_id;
		var new_name = rename_download_query.new_name;
		var download = download_list_store.get_download_by_id (download_id);
		if (download != null && download.name != new_name) {
			download.name = new_name;
			download_list_store.register_download_change (download);
		}
	}

}
