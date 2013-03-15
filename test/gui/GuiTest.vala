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

public class Lottanzb.GuiTest : TestSuite {

	public GuiTest () {
		base ("gui");
		add_suite (new GeneralPreferencesTabTest ().get_suite ());
		add_suite (new SpeedLimitMenuTest ().get_suite ());
		add_suite (new InfoBarTest ().get_suite ());
		add_suite (new DownloadListTest ().get_suite ());
		add_suite (new DownloadPropertiesDialogTest ().get_suite ());
	}

}