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


public class Lottanzb.LogMessage : Object {

	private DateTime _date_time;
	private LogLevelFlags _log_level;
	private string _content;
	
	public DateTime date_time { get { return _date_time; } }
	public LogLevelFlags log_level { get { return _log_level; } }
	public string content { get { return _content; } }
	
	public LogMessage (DateTime date_time, LogLevelFlags log_level,
			string content) {
		_date_time = date_time;
		_log_level = log_level;
		_content = content;
	}

}
