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

public class Lottanzb.MockStatisticsHub : Object, StatisticsHub {

	public DataSize history_total_size { get; protected set; }
	public DataSize history_month_size { get; protected set; }
	public DataSize history_week_size { get; protected set; }
	public DataSize? total_download_folder_space { get; protected set; }
	public DataSize? total_temp_folder_space { get; protected set; }
	public DataSize? free_download_folder_space { get; protected set; }
	public DataSize? free_temp_folder_space { get; protected set; }

	public MockStatisticsHub () {
		history_total_size = DataSize(0);
		history_month_size = DataSize(0);
		history_week_size = DataSize(0);
	}

}
