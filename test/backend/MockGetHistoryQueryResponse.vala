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


public class Lottanzb.MockGetHistoryQueryResponse : GetHistoryQueryResponse, Object {

	private Gee.List<Download> _downloads;

	public MockGetHistoryQueryResponse (Gee.List<Download> downloads) {
		_downloads = downloads;
	}

	public MockGetHistoryQueryResponse.empty () {
		_downloads = new Gee.ArrayList<Download> ();
	}

	public Gee.List<Download> downloads {
		get { return _downloads; }
	}

	public DataSize history_total_size { get { return DataSize.UNKNOWN; } }
	public DataSize history_month_size { get { return DataSize.UNKNOWN; } }
	public DataSize history_week_size { get { return DataSize.UNKNOWN; } }
	public DataSize history_day_size { get { return DataSize.UNKNOWN; } }
}
