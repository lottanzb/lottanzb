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

public class Lottanzb.DownloadListStoreUpdater : Object {

	public int[] STATUS_GROUP_ORDER = {
		DownloadStatusGroup.COMPLETE,
		DownloadStatusGroup.PROCESSING,
		DownloadStatusGroup.NOT_FULLY_LOADED
	};

	public DownloadListStore list_store { get; construct set; }
	private DownloadListStoreFilter list_store_filter;
	private int _status_group;
	public int status_group {
		get { return _status_group; }
		construct set {
			foreach (var some_status_group in STATUS_GROUP_ORDER) {
				bool has_intersection = (some_status_group & value) != 0;
				bool is_fully_contained = (some_status_group & value) == some_status_group;
				assert (!has_intersection || is_fully_contained);
			}
			_status_group = value;
		}
	}

	public DownloadListStoreUpdater (DownloadListStore list_store, int status_group) {
		this.list_store = list_store;
		this.status_group = status_group;
		this.list_store_filter = list_store.get_filter_by_status (status_group);
	}

	public void update (Gee.List<Download> remote_downloads) {
		assert (!list_store.is_updating);
		list_store.is_updating = true;
		update_content (remote_downloads);
		update_order (remote_downloads);
		list_store.is_updating = false;
	}

	private void update_content (Gee.List<Download> remote_downloads) {
		var remote_ids = get_downloads_ids (remote_downloads);
		var updated_downloads = new Gee.HashSet<Download> ();
		foreach (var iter in list_store_filter) {
			Gtk.TreeIter child_iter;
			list_store_filter.convert_iter_to_child_iter (out child_iter, iter);
			var download = list_store.get_download (child_iter);
			if (!(download.id in remote_ids)) {
				handle_disappeared_download (child_iter);
			}
		}

		foreach (var remote_download in remote_downloads) {
			var download_id = remote_download.id;
			// TODO: Only if not in cache and cached download not stale.
			var download = list_store.get_download_by_id (download_id);
			if (download == null) {
				download = new DownloadImpl ();
				download.update (remote_download);
				var download_count = list_store.iter_n_children (null);
				list_store.insert_with_values (null, download_count,
					DownloadListStore.COLUMN, download);
			} else {
				download.update (remote_download);
			}
			updated_downloads.add (download);
		}
		foreach (var iter in list_store) {
			var download = list_store.get_download (iter);
			if (download in updated_downloads) {
				list_store.row_changed (list_store.get_path (iter), iter);
			}
		}
	}

	private void update_order (Gee.List<Download> remote_downloads) {
		var remote_ids = get_downloads_ids (remote_downloads);
		var new_order = new Gee.ArrayList<int> ();
		foreach (var some_status_group in STATUS_GROUP_ORDER) {
			var model_filter = list_store.get_filter_by_status (some_status_group);
			if ((status_group & some_status_group) == some_status_group) {
				var old_positions = new Gee.HashMap<string, int> ();
				var disappeared_order = new Gee.ArrayList<int> ();
				var received_order = new Gee.ArrayList<int> ();
				foreach (var iter in model_filter) {
					Gtk.TreeIter child_iter;
					model_filter.convert_iter_to_child_iter (out child_iter, iter);
					var child_path = list_store.get_path (child_iter);
					var download = list_store.get_download (child_iter);
					var position = child_path.get_indices ()[0];
					old_positions[download.id] = position;
				}
				foreach (var remote_id in remote_ids) {
					var download = list_store.get_download_by_id (remote_id);
					if (download.status.is_in_group (some_status_group)) {
						int position;
						old_positions.unset (remote_id, out position);
						received_order.add (position);
					}
				}
				disappeared_order.add_all (old_positions.values);
				disappeared_order.sort (null);
				new_order.add_all (disappeared_order);
				new_order.add_all (received_order);
			} else {
				foreach (var iter in model_filter) {
					Gtk.TreeIter child_iter;
					model_filter.convert_iter_to_child_iter (out child_iter, iter);
					var child_path = list_store.get_path (child_iter);
					var position = child_path.get_indices ()[0];
					new_order.add (position);
				}
			}
		}
		var new_order_array = new_order.to_array ();
		// When an empty array is passed to 'reorder', GTK throws an exception
		// claiming that the 'new_order' argument is null.
		// Thus, avoid such a call without changing this method's semantics.
		if (new_order.size > 0) {
			LottanzbResource.reorder (list_store, new_order_array);
		}
	}

	private Gee.List<string> get_downloads_ids (Gee.List<Download> downloads) {
		var download_ids = new Gee.ArrayList<string> ();
		foreach (var download in downloads) {
			download_ids.add (download.id);
		}
		return download_ids;
	}

	protected virtual void handle_disappeared_download (Gtk.TreeIter iter) {
		list_store.remove (iter);
	}

}

/**
 * Removes a disappeared download from the model only if the download is
 * likely to have been deleted by the user through the SABnzbd web interface.
 * Otherwise, such a download might just have been completed and will thus
 * show up in the response to the next 'history' query.
 *
 * Also, downloads with the status GRABBING will be replaced by
 * another one as soon as SABNzbd is done downloading the NZB file.
 * Thus, in this case, the temporary download entry should always be removed
 * from LottaNZB's download list.
*/
public class Lottanzb.DownloadListStoreQueueUpdater : DownloadListStoreUpdater {

	public DownloadListStoreQueueUpdater (DownloadListStore list_store) {
		base (list_store, DownloadStatusGroup.NOT_FULLY_LOADED);
	}

	protected override void handle_disappeared_download (Gtk.TreeIter iter) {
		var download = list_store.get_download (iter);
		var deleted = false;
		if (download.status.is_in_group (DownloadStatusGroup.NOT_FULLY_LOADED)) {
			deleted =
				download.status == DownloadStatus.GRABBING ||
				download.status == DownloadStatus.PAUSED ||
				!is_download_nearly_finished (download);
		}
		if (deleted) {
			base.handle_disappeared_download (iter);
		}
	}

	private bool is_download_nearly_finished (Download download) {
		return download.time_left.is_known () && download.time_left.seconds <= 5;
	}

}

