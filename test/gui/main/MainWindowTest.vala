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

public class Lottanzb.MainWindowTest : Lottanzb.TestSuiteBuilder {

	public MainWindowTest () {
		base ("main_window");
		add_test ("construction", test_construction);
	}

	public void test_construction () {
		var config_provider = new ConfigProviderImpl.with_memory_backend ();
		var backend = new MockBackend ();
		var main_window = new MainWindow (config_provider);
		main_window.backend = backend;
	}

}
