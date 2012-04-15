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

public interface Lottanzb.GetWarningsQuery : Query<Gee.List<LogMessage>> {

}

public class Lottanzb.GetWarningsQueryImpl : QueryImpl<Gee.List<LogMessage>>, GetWarningsQuery {

	public GetWarningsQueryImpl() {
		base("warnings");
	}

	public override Gee.List<LogMessage> get_response_from_json_object(
			Json.Object json_object) throws QueryError {
		var json_warning_array = json_object.get_array_member("warnings");
		var log_message_list = new Gee.ArrayList<LogMessage>();
		for (int index = 0; index < json_warning_array.get_length(); index++) {
			var json_warning = json_warning_array.get_string_element (index);
			var json_warning_parts = json_warning.split("\n", 3);
			var date_time_string = json_warning_parts[0];
			var date_time = get_date_from_string(date_time_string);
			var log_level_string = json_warning_parts[1];
			LogLevelFlags log_level = LogLevelFlags.LEVEL_WARNING;
			if (log_level_string == "ERROR") {
				log_level = LogLevelFlags.LEVEL_ERROR;
			}
			var content = json_warning_parts[2];
			var log_message = new LogMessage(date_time, log_level, content);
			log_message_list.add(log_message);
		}
		return log_message_list.read_only_view;
	}

	private DateTime get_date_from_string(string date_time_string) throws QueryError {
		var fixed_date_time_string = date_time_string.replace(" ", "T");
		var time_val = TimeVal();
		bool success = time_val.from_iso8601(fixed_date_time_string);
		if (!success) {
			throw new QueryError.INVALID_RESPONSE ("invalid date time string: "
					+ date_time_string);
		}
		return new DateTime.from_timeval_local(time_val);
	}

}
