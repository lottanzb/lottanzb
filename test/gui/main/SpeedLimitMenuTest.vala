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

using Lottanzb;

public class Lottanzb.SpeedLimitMenuTest : Lottanzb.TestSuiteBuilder {

	public SpeedLimitMenuTest () {
		base ("speed_limit_menu");
		add_test("provider", test_provider);
	}

	public void test_provider () {
		var config_hub = new MockConfigHub ();
		config_hub.speed_limit =  ConfigHub.UNLIMITED_SPEED;
		var menu_provider = new SpeedLimitMenuProvider (config_hub);
		var menu = (SpeedLimitMenu) menu_provider.make_menu ();
		var new_speed_limit = 42;
		menu.speed_limit_changed (new_speed_limit);
		assert (config_hub.speed_limit == new_speed_limit);
	}

}
