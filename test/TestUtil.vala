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

public Resource TEST_RESOURCE = null;

public string get_fixture (string path) {
	// Calling LottanzbTestResource.get_resource () more than two times causes
	// segmentation faults for unknown reasons.
	if (TEST_RESOURCE == null) {
		TEST_RESOURCE = LottanzbTestResource.get_resource ();
	}
	var absolute_path = "/org/lottanzb/test/fixtures/" + path;
	var bytes = TEST_RESOURCE.lookup_data (absolute_path, ResourceLookupFlags.NONE);
	return (string) bytes.get_data();
}


