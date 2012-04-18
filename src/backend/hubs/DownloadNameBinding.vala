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

public class Lottanzb.DownloadNameBinding : DownloadPropertyBinding {

	public DownloadNameBinding (DownloadListStore download_list_store, QueryProcessor query_processor) {
		base (download_list_store, query_processor, "name");
		this.query_processor.get_query_notifier<RenameDownloadQuery> ()
			.query_started.connect (on_download_rename_query_started); 
	}
	
	public override void handle_download_property_change (Download download) {
		base.handle_download_property_change (download);
		var new_name = download.name;
		query_processor.rename_download (download.id, new_name);
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
