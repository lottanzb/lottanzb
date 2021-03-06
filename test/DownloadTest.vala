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

public class Lottanzb.DownloadTest : Lottanzb.TestSuiteBuilder {

	public DownloadTest () {
		base ("download");
		add_test ("status", test_status);
		add_test ("priority", test_priority);
	}

	public void test_status () {
		foreach (var status in DownloadStatus.all ()) {
			var status_string = status.to_string ();
			assert (status_string.length > 0);
		}
	}

	public void test_priority () {
		var priorities = DownloadPriority.all ();
		for (int i = 0; i < priorities.length; i++) {
			var priority = priorities[i];
			var priority_string = priority.to_string ();
			assert (priority_string.length > 0);
			assert (priority.to_index () == i);
			assert (DownloadPriority.from_index (i) == priority);
		}
	}

}
