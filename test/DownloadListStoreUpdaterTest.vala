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

public Gee.List<Download> make_downloads (string[] ids, DownloadStatus status = DownloadStatus.QUEUED) {
	var downloads = new Gee.ArrayList<Download> ();
	foreach (var id in ids) {
		var download = make_download (id, status);
		downloads.add (download);
	}
	return downloads;
}

public void assert_download_list_store_download_order (DownloadListStore list_store, string[] ids) {
	Gtk.TreeIter iter;
	assert (list_store.iter_n_children (null) == ids.length);
	list_store.get_iter_first (out iter);
	foreach (var id in ids) {
		var download = list_store.get_download (iter);
		assert (download.id == id);
		list_store.iter_next (ref iter);
	}
}

public void test_download_list_store_updater_initial_update () {
	var list_store = new DownloadListStore ();
	var updater = new DownloadListStoreUpdater (list_store, DownloadStatusGroup.NOT_FULLY_LOADED);
	var ids = new string[] { "a", "b", "c" };
	var remote_downloads = make_downloads (ids);
	updater.update (remote_downloads);
	assert_download_list_store_download_order (list_store, ids);
}

public void test_download_list_store_updater_idempotence () {
	var list_store = new DownloadListStore ();
	var updater = new DownloadListStoreUpdater (list_store, DownloadStatusGroup.NOT_FULLY_LOADED);
	var ids = new string[] { "a", "b", "c" };
	var remote_downloads = make_downloads (ids);
	updater.update (remote_downloads);
	updater.update (remote_downloads);
	assert_download_list_store_download_order (list_store, ids);
}

public void test_download_list_store_updater_simple_reordering () {
	var list_store = new DownloadListStore ();
	var updater = new DownloadListStoreUpdater (list_store, DownloadStatusGroup.NOT_FULLY_LOADED);
	var old_ids = new string[] { "a", "b", "c" };
	var old_remote_downloads = make_downloads (old_ids);
	updater.update (old_remote_downloads);
	var new_ids = new string[] { "b", "c", "a" };
	var new_remote_downloads = make_downloads (new_ids);
	updater.update (new_remote_downloads);
	assert_download_list_store_download_order (list_store, new_ids);
}

