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

public class Lottanzb.BackendTest : TestSuite {

	public BackendTest () {
		base ("backend");
		add_suite (new DataSizeTest ().get_suite ());
		add_suite (new DataSpeedTest ().get_suite ());
		add_suite (new TimeDeltaTest ().get_suite ());
		add_suite (new ConnectionInfoTest ().get_suite ());
		add_suite (new DownloadListStoreTest ().get_suite ());
		add_suite (new QueriesTest ());
		add_suite (new GeneralHubTest ().get_suite ());
		add_suite (new ConfigHubTest ().get_suite ());
	}

}
