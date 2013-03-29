/**
 * Copyright (c) 2013 Severin Heiniger <severinheiniger@gmail.com>
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

public class Lottanzb.DownloadListTest : Lottanzb.TestSuiteBuilder {

	private MockGeneralHub general_hub;
	private DownloadList download_list;
	private DownloadListStore list_store;

	public DownloadListTest () {
		base ("download_list");
		add_test ("selection", test_selection);
	}

	public override void set_up () {
		general_hub = new MockGeneralHub ();
		general_hub.add_mock_download ("foo");
		general_hub.add_mock_download ("bar");
		list_store = general_hub.download_list_store;
		download_list = new DownloadList (general_hub);
	}

	public void test_selection () {
		var selection = download_list.tree_view.get_selection ();
		Gtk.TreeIter iter;
		list_store.get_iter_first (out iter);
		selection.select_iter (iter);
		selection.unselect_all ();
	}

}
