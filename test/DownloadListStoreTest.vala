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

public void test_download_list_store_basic () {
	var store = new DownloadListStore ();
	var first_download = make_download ("a");
	var second_download = make_download ("b");
	Gtk.TreeIter iter;
	store.insert_with_values (out iter, 0, DownloadListStore.COLUMN,
		first_download);
	store.insert_with_values (out iter, 1, DownloadListStore.COLUMN,
		second_download);
	assert (store.get_download (store.index (1)) == second_download);
	assert (store.get_download (iter) == second_download);
	assert (store.get_download_by_id ("a") == first_download);
	assert (store.get_download_by_id ("b") == second_download);
	assert (store.get_download_by_id ("c") == null);
}

public void test_download_list_store_filtering () {
	var store = new DownloadListStore ();
	var queued_download = make_download ("a", DownloadStatus.QUEUED);
	var active_download = make_download ("b", DownloadStatus.DOWNLOADING);
	var processing_download = make_download ("c", DownloadStatus.EXTRACTING);
	var recovering_download = make_download ("d", DownloadStatus.DOWNLOADING_RECOVERY_DATA);
	var succeeded_download = make_download ("e", DownloadStatus.SUCCEEDED);
	store.insert_with_values (null, 0, DownloadListStore.COLUMN,
		queued_download);
	store.insert_with_values (null, 1, DownloadListStore.COLUMN,
		active_download);
	store.insert_with_values (null, 2, DownloadListStore.COLUMN,
		processing_download);
	store.insert_with_values (null, 3, DownloadListStore.COLUMN,
		recovering_download);
	store.insert_with_values (null, 4, DownloadListStore.COLUMN,
		succeeded_download);
	assert (store.get_filter_complete ().iter_n_children (null) == 1);
	assert (store.get_filter_incomplete ().iter_n_children (null) == 4);
	assert (store.get_filter_processing ().iter_n_children (null) == 1);
	assert (store.get_filter_not_fully_loaded ().iter_n_children (null) == 3);
	assert (store.get_filter_movable ().iter_n_children (null) == 2);
	assert (store.get_filter_by_status (DownloadStatus.DOWNLOADING_RECOVERY_DATA).iter_n_children (null) == 1);
}

