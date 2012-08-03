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

public class Lottanzb.GeneralPreferencesTabTest : TestSuiteBuilder {

	public GeneralPreferencesTabTest () {
		base ("general_preferences_tab");
		add_test ("post_processing_model", test_post_processing_model);
	}

	public void test_post_processing_model () {
		var model = new PostProcessingModel ();
		foreach (var post_processing in DownloadPostProcessing.all ()) {
			var index = model.index_of (post_processing);
			assert (post_processing == model.get_download_post_processing (index));
		}
	}

}
