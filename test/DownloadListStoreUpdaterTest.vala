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

public class Lottanzb.DownloadListStoreUpdaterTest : Lottanzb.TestSuiteBuilder {

	public DownloadListStoreUpdaterTest () {
		base ("download_list_store_updater");
		add_test ("initial_update", test_initial_update);
		add_test ("idempotence", test_idempotence);
		add_test ("simple_reordering", test_simple_reordering);
		add_test ("empty_update", test_empty_update);
	}

	public void test_initial_update () {
		var list_store = new DownloadListStore ();
		var updater = new DownloadListStoreUpdater (list_store, DownloadStatusGroup.NOT_FULLY_LOADED);
		var ids = new string[] { "a", "b", "c" };
		var remote_downloads = make_downloads (ids);
		updater.update (remote_downloads);
		assert_download_list_store_download_order (list_store, ids);
	}

	public void test_idempotence () {
		var list_store = new DownloadListStore ();
		var updater = new DownloadListStoreUpdater (list_store, DownloadStatusGroup.NOT_FULLY_LOADED);
		var ids = new string[] { "a", "b", "c" };
		var remote_downloads = make_downloads (ids);
		updater.update (remote_downloads);
		updater.update (remote_downloads);
		assert_download_list_store_download_order (list_store, ids);
	}

	public void test_simple_reordering () {
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

	public void test_empty_update () {
		var list_store = new DownloadListStore ();
		var updater = new DownloadListStoreUpdater (list_store, DownloadStatusGroup.NOT_FULLY_LOADED);
		var remote_downloads = new Gee.ArrayList<Download> ();
		updater.update (remote_downloads);
		assert_download_list_store_download_order (list_store, new string[] {});
	}

}
