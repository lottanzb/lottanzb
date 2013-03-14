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

using Gtk;

public class Lottanzb.GeneralHub : Object {

	public QueryProcessor query_processor { get; construct set; }
	public DownloadListStore download_list_store { get; construct set; }

	private bool _paused;
	private GetQueueQueryResponse? last_queue_query_response;

	public DataSpeed speed { get; private set; }
	public TimeDelta time_left { get; private set; }
	public DataSize size_left { get; private set; }
	public DateTime eta { get; private set; }

	private DownloadNameBinding download_name_binding;
	private DownloadPriorityBinding download_priority_binding;
	private DownloadListStoreUpdater queue_updater;
	private DownloadListStoreUpdater history_updater;

	public GeneralHub (QueryProcessor query_processor) {
		this.query_processor = query_processor;
		this.download_list_store = new DownloadListStore();
		this.query_processor.get_query_notifier<GetQueueQuery> ()
			.query_completed.connect ((query_processor, queue_query) => {
			// Update the download list store in the main thread
			Idle.add(() => {
				handle_queue_query (queue_query);
				return false;
			});
		});
		this.query_processor.get_query_notifier<GetHistoryQuery> ()
			.query_completed.connect ((query_processor, history_query) => {
			// Update the download list store in the main thread
			Idle.add(() => {
				handle_history_query (history_query);
				return false;
			});
		});

		this.download_name_binding = new DownloadNameBinding (download_list_store, query_processor);
		this.download_priority_binding = new DownloadPriorityBinding (download_list_store, query_processor);
		this.queue_updater = new DownloadListStoreUpdater (download_list_store,
			DownloadStatusGroup.INCOMPLETE);
		this.history_updater = new DownloadListStoreUpdater (download_list_store,
			DownloadStatusGroup.COMPLETE | DownloadStatusGroup.PROCESSING);
		this.query_processor.get_queue ();
		this.query_processor.get_history ();
	}

	private void handle_queue_query (GetQueueQuery query) {
		last_queue_query_response = query.get_response ();
		queue_updater.update (query.get_response ().downloads);
		paused = query.get_response ().is_paused;
		time_left = query.get_response ().time_left;
		size_left = query.get_response ().size_left;
		speed = query.get_response ().speed;
	}

	private void handle_history_query (GetHistoryQuery query) {
		history_updater.update (query.get_response ().downloads);	
	}

	public bool paused {
		get {
			return _paused;
		}
		set {
			var old_paused = _paused;
			_paused = value;
			if (old_paused != value) {
				var is_query_required = last_queue_query_response == null ||
					last_queue_query_response.is_paused != value;
				if (is_query_required) {
					if (value) {
						query_processor.pause ();
					} else {
						query_processor.resume ();
					}
					last_queue_query_response = null;
					foreach (var iter in download_list_store) {
						var download = download_list_store.get_download (iter);
						if (download.status == DownloadStatus.DOWNLOADING) {
							download.status = DownloadStatus.QUEUED;
							var path = download_list_store.get_path (iter);
							download_list_store.row_changed (path, iter);
						}
					}
				}	
			}

		}
	}

	public void pause_downloads (Gee.List<Download> downloads) {
		var download_ids = new Gee.ArrayList<string> ();
		foreach (var download in downloads) {
			download_ids.add (download.id);
		}
		query_processor.pause_downloads (download_ids);
	}

	public void resume_downloads (Gee.List<Download> downloads) {
		var download_ids = new Gee.ArrayList<string> ();
		foreach (var download in downloads) {
			download_ids.add (download.id);
		}
		query_processor.resume_downloads (download_ids);
	}

	public void move_download (Download download, int index)
		requires (download.status.is_in_group (DownloadStatusGroup.MOVABLE)) {
		var filter = download_list_store.get_filter_not_fully_loaded ();
		var filter_path = new Gtk.TreePath.from_indices (index);
		Gtk.TreeIter filter_iter, target_iter;
		bool is_valid_iter = filter.get_iter (out filter_iter, filter_path);
		assert (is_valid_iter);
		filter.convert_iter_to_child_iter (out target_iter, filter_iter);
		var target_download = download_list_store.get_download (target_iter);
		if (download == target_download) {
			// The download is already at the correct index
			return;
		}
		Gtk.TreeIter? source_iter = null;
		foreach (Gtk.TreeIter iter in download_list_store) {
			var some_download = download_list_store.get_download (iter);
			if (some_download.id == download.id) {
				source_iter = iter;
				break;
			}
		}
		var target_position = download_list_store.get_path (target_iter).get_indices ()[0];
		var source_position = download_list_store.get_path (source_iter).get_indices ()[0];
		if (target_position < source_position) {
			LottanzbResource.move_before (download_list_store, source_iter, target_iter);
		} else {
			LottanzbResource.move_after (download_list_store, source_iter, target_iter);
		}
		query_processor.switch_downloads (download.id, target_download.id);
	}

	public void move_download_relative (Download download, int shift) {
		if (shift == 0) {
			// The download is already at the correct index
			return;
		}
		var filter = download_list_store.get_filter_not_fully_loaded ();
		var index = -1;
		foreach (var iter in filter) {
			TreeIter child_iter;
			filter.convert_iter_to_child_iter (out child_iter, iter);
			var other_download = download_list_store.get_download (child_iter);
			if (download == other_download) {
				index = filter.get_path (iter).get_indices ()[0];
			}
		}
		assert (index != -1);
		move_download (download, index + shift);
	}

	public void force_download (Download download) {
		move_download (download, 0);
		if (download.status == DownloadStatus.PAUSED) {
			Gee.List<Download> downloads = new Gee.ArrayList<Download> ();
			downloads.add (download);
			resume_downloads (downloads);
		}
	}

	public void move_download_up (Download download, int shift = 1) {
		assert (shift >= 1);
		move_download_relative (download, -shift);	
	}

	public void move_download_down (Download download, int shift = 1) {
		assert (shift >= 1);
		move_download_relative (download, shift);
	}

	public void move_download_down_to_bottom (Download download) {
		var filter = download_list_store.get_filter_not_fully_loaded ();
		var count = filter.iter_n_children (null);
		move_download (download, count - 1);
	}

	public void rename_download (Download download, string new_name) {
		query_processor.rename_download (download.id, new_name);
	}

	public void set_download_priority (Download download, DownloadPriority new_priority) {
		var download_ids = new Gee.ArrayList<string> ();
		download_ids.add (download.id);
		query_processor.set_download_priority (download_ids, new_priority);
	}

	public void delete_download (Download download) {
		var download_ids = new Gee.ArrayList<string> ();
		download_ids.add (download.id);
		query_processor.delete_downloads (download_ids);
	}
}
