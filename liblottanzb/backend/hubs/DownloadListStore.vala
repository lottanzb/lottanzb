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

public class Lottanzb.DownloadListStore : Gtk.ListStore, IterableTreeModel, DownloadListStoreMixin {

	public static int COLUMN = 0;
	
	private Gee.HashMap<int, DownloadListStoreFilter> filters;

	// Updating as well as accessing this variable must only happen
	// from the main thread.
	public bool is_updating { get; set; }

	public DownloadListStore () {
		set_column_types(new Type[] { typeof(Download) });
		this.filters = new Gee.HashMap<int, DownloadListStoreFilter>();
	}
	
	public DownloadListStoreFilter get_filter_by_status (int download_status) {
		DownloadListStoreFilter filter = this.filters[download_status];
		if (filter == null) {
			filter = new DownloadListStoreFilter (this, null);
			filter.set_visible_func ((model, iter) => {
				var download = get_download (iter);
				return download != null && download.status.is_in_group (download_status);
			});
			this.filters[download_status] = filter;
		}
		return filter;
	}

	public DownloadListStoreFilter get_filter_complete () {
		return get_filter_by_status (DownloadStatusGroup.COMPLETE);
	}
	
	public DownloadListStoreFilter get_filter_incomplete () {
		return get_filter_by_status (DownloadStatusGroup.INCOMPLETE);
	}
	
	public DownloadListStoreFilter get_filter_processing () {
		return get_filter_by_status (DownloadStatusGroup.PROCESSING);
	}
	
	public DownloadListStoreFilter get_filter_not_fully_loaded () {
		return get_filter_by_status (DownloadStatusGroup.NOT_FULLY_LOADED);
	}
	
	public DownloadListStoreFilter get_filter_movable () {
		return get_filter_by_status (DownloadStatusGroup.MOVABLE);
	}
	
	public Download? get_download_by_id (string download_id) {
		foreach (var iter in this) {
			var download = get_download (iter);
			if (download != null && download.id == download_id) {
				return download;
			}
		}
		return null;
	}

	public void register_download_change (Download download) {
		foreach (var iter in this) {
			var some_download = get_download (iter);
			if (some_download != null && some_download.id == download.id) {
				var path = get_path (iter);
				row_changed (path, iter);
			}
		}
	}

	/**
	 * Switches all downloads with a given status to a different status.
	 *
	 * @param old_status the old status to look for
	 * @param status the new status to replace it with
	*/
	public void switch_download_status (DownloadStatus old_status, DownloadStatus status) {
		foreach (var iter in this) {
			var download = get_download (iter);
			if (download.status == old_status) {
				download.status = status;
				var path = get_path (iter);
				row_changed (path, iter);
			}
		}	
	
	}

}
