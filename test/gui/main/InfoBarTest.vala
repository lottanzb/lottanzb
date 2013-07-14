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

public class Lottanzb.InfoBarTest : Lottanzb.TestSuiteBuilder {

	public InfoBarTest () {
		base ("info_bar");
		add_test ("updates", test_updates);
	}

	public void test_updates () {
		var backend = new MockBackend ();
		new InfoBar (backend);
	}

}
