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


public class Lottanzb.MockGetQueueQueryResponse : GetQueueQueryResponse, Object {

	private Gee.List<Download> _downloads; 
	private bool _is_paused;
	private TimeDelta _time_left;
	private DataSize _size_left;
	private DataSpeed _speed;

	public MockGetQueueQueryResponse.empty () {
		_downloads = new Gee.ArrayList<Download> ();
		_is_paused = false;
		_time_left = 0;
		_size_left = DataSize.UNKNOWN;
		_speed = DataSpeed.UNKNOWN;
	}

	public Gee.List<Download> downloads { get { return _downloads; } } 
	public bool is_paused { get { return _is_paused; } }
	public TimeDelta time_left { get { return _time_left; } }
	public DataSize size_left { get { return _size_left; } }
	public DataSpeed speed { get { return _speed; } }

}
