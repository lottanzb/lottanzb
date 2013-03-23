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

public abstract class Lottanzb.DownloadPropertyBinding<T> : Object {

	public QueryProcessor query_processor { get; construct set; }
	public DownloadListStore download_list_store { get; construct set; }
	public string property { get; construct set; }

	protected bool ignore_property_changes { get; set; }

	public DownloadPropertyBinding (DownloadListStore download_list_store, QueryProcessor query_processor, string property) {
		this.query_processor = query_processor;
		this.download_list_store = download_list_store;
		this.property = property;
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
		download.notify[property].connect ((object, param) => {
			if (!ignore_property_changes && !download_list_store.is_updating) {
				handle_download_property_change (download);
			}
		});
	}

	/**
	 * Set the property of a given download to a new value, but do not call
	 * handle_download_property_change in the process. Use this method
	 * to avoid infinite loops, e.g., because handle_download_property_change
	 * would eventually cause this method to be called again.
	 *
	 * Also make sure that the value is actually different from the current
	 * one to avoid unnecessary work.
	 */
	protected void set_property_silently (Download download, T value) {
		ignore_property_changes = true;
		download[property] = value;
		ignore_property_changes = false;
		download_list_store.register_download_change (download);
	}

	protected virtual void handle_download_property_change (Download download) {
		download_list_store.register_download_change (download);
	}

}
