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

public class Lottanzb.RenameDownloadBinding : Object {

	public Download download { get; construct set; }
	public QueryProcessor query_processor { get; construct set; }
	public DownloadListStore download_list_store { get; construct set; }

	public RenameDownloadBinding (Download download, QueryProcessor query_processor,
		DownloadListStore download_list_store) {
		this.download = download;
		this.query_processor = query_processor;
		this.download_list_store = download_list_store;

		this.download.notify["name"].connect (on_download_name_changed);
		this.query_processor.get_query_notifier<RenameDownloadQuery> ()
			.query_started.connect (on_download_rename_query_started); 
	}

	public void on_download_name_changed (Object object, ParamSpec param) {
		
	}

	public void on_download_rename_query_started (QueryNotifier query_notifier,
		RenameDownloadQuery rename_download_query) {
		var download_id = rename_download_query.download_id;
		var new_name = rename_download_query.new_name;
		if (download.id == download_id && download.name != new_name) {
			download.name = new_name;
			download_list_store.register_download_change (download);
		}
	}

}
