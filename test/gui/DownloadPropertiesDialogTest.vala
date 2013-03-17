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

public class Lottanzb.DownloadPropertiesDialogTest : Lottanzb.TestSuiteBuilder {

	public DownloadPropertiesDialogTest () {
		base ("download_properties_dialog");
		add_test ("construction", test_construction);
	}

	public void test_construction () {
		var general_hub = new MockGeneralHub ();
		var download = new DownloadImpl ();
		download.name = "foo";
		var dialog = new DownloadPropertiesDialog (general_hub, download);

		// Switching the dialog to a new download should not alter the
		// previous download in any way.
		var other_download = new DownloadImpl ();
		other_download.name = "bar";
		dialog.download = other_download;		
		assert (download.name == "foo");
		assert (other_download.name == "bar");
	}

}

