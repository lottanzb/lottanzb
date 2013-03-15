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

[CCode (type_id = "G_TYPE_INT")]
[IntegerType (rank = 6)]
public struct Lottanzb.TimeDelta : int {

	public static const TimeDelta UNKNOWN = -1;

	public static TimeDelta with_unit (int time_value, TimeDeltaUnit unit) {
		return unit.get_seconds() * time_value;
	}
	
	public static TimeDelta with_units (int first_time_value, TimeDeltaUnit first_unit,
		int second_time_value, TimeDeltaUnit second_unit) {
		var first_seconds = first_time_value * first_unit.get_seconds();
		var second_seconds = second_time_value * second_unit.get_seconds();
		return first_seconds + second_seconds;
	}
	
	public static TimeDelta with_parts (int days, int hours, int minutes, int seconds) {
		return seconds + 60 * (minutes + 60 * (hours + 24 * days));
	}
	
	public static new TimeDelta parse (string time_delta_string) {
		try {
			Regex PATTERN = new Regex("^(?P<hours>\\d+):(?P<minutes>\\d{2}):(?P<seconds>\\d{2})$");
			Regex PATTERN_2 = new Regex("^(?P<time_delta>\\d+)(?P<unit>[mhd])$");
			MatchInfo match_info;
			bool match = PATTERN.match(time_delta_string, 0, out match_info);
			if (match) {
				var hours_string = (!) match_info.fetch_named("hours");
				var minutes_string = (!) match_info.fetch_named("minutes");
				var seconds_string = (!) match_info.fetch_named("seconds");
				var hours = int.parse(hours_string);
				var minutes = int.parse(minutes_string);
				var seconds = int.parse(seconds_string);
				return seconds + 60 * (minutes + 60 * hours);
			} else {
				match = PATTERN_2.match(time_delta_string, 0, out match_info);
				if (match) {
					var time_delta = int.parse(match_info.fetch_named("time_delta"));
					var time_delta_unit_char = match_info.fetch_named("unit")[0];
					TimeDeltaUnit time_delta_unit = TimeDeltaUnit.from_char(time_delta_unit_char);
					return with_unit(time_delta, time_delta_unit);
				} else {
					if (time_delta_string.length > 0) {
						warning ("could not parse time delta: %s", time_delta_string);
					}
					return UNKNOWN;
				}
			}
		} catch (RegexError e) {
			warning ("%s", e.message);
		}
		return UNKNOWN;
	}

	public int total_seconds {
		get {
			return this;
		}
	}
	
	public int seconds {
		get {
			return (int) (total_seconds % 60);
		}
	}
	
	public int total_minutes {
		get {
			return (int) (total_seconds / 60);
		}
	}
	
	public int minutes {
		get {
			return total_minutes % 60;
		}
	}
	
	public int total_hours {
		get {
			return (int) (total_seconds / (60 * 60));
		}
	}
	
	public int hours {
		get {
			return total_hours % 24;
		}
	}
	
	public int total_days {
		get {
			return (int) (total_seconds / (60 * 60 * 24));
		}
	}
	
	public int days {
		get {
			return (int) (total_seconds / (60 * 60 * 24));
		}
	}
	
	/*
		Extract the integer number of seconds, minutes, hours or days calculated
		using modulo 24 or 60, respectively.

		As an example, if `TimeDelta` represents a duration of 2 hours,
		32 minutes and 10 seconds, this method will do the following:

		>>> time_delta[TimeDeltaUnit.DAYS]
		0
		>>> time_delta[TimeDeltaUnit.HOURS]
		2
		>>> time_delta[TimeDeltaUnit.MINUTES]
		32
		>>> time_delta[TimeDeltaUnit.SECONDS]
		10
	*/
	public int get(TimeDeltaUnit unit) {
		switch (unit) {
			case TimeDeltaUnit.DAYS:
				return days;
			case TimeDeltaUnit.HOURS:
				return hours;
			case TimeDeltaUnit.MINUTES:
				return minutes;
			case TimeDeltaUnit.SECONDS:
				return seconds;
			default:
				assert_not_reached();
		}
	}
	
	/*
		Return a string representation of the `TimeDelta` for a certain time
		scale.

		As an example, if `TimeDelta` represents a duration of 2 hours,
		32 minutes and 10 seconds, this method will do the following:

		>>> time_delta.to_simple_string(TimeDeltaUnit.DAYS)
		"0 days"
		>>> time_delta.to_simple_string(TimeDeltaUnit.HOURS)
		"2 hours"
		>>> time_delta.to_simple_string(TimeDeltaUnit.MINUTES)
		"32 minutes"
		>>> time_delta.to_simple_string(TimeDeltaUnit.SECONDS)
		"10 seconds"
	*/
	public string to_simple_string (TimeDeltaUnit unit) {
		var time_value = get(unit);
		string string_format;
		switch (unit) {
			case TimeDeltaUnit.DAYS:
				string_format = ngettext("%i day", "%i days", time_value);
				break;
			case TimeDeltaUnit.HOURS:
				string_format = ngettext("%i hour", "%i hours", time_value);
				break;
			case TimeDeltaUnit.MINUTES:
				string_format = ngettext("%i minute", "%i minutes", time_value);
				break;
			case TimeDeltaUnit.SECONDS:
				string_format = ngettext("%i second", "%i seconds", time_value);
				break;
			default:
				assert_not_reached();
		}
		return string_format.printf(time_value);
	}
	
	public TimeDeltaUnit major_unit {
		get {
			if (TimeDeltaUnit.DAYS.get_seconds() <= total_seconds) {
				return TimeDeltaUnit.DAYS;
			} else if (TimeDeltaUnit.HOURS.get_seconds() <= total_seconds) {
				return TimeDeltaUnit.HOURS;
			} else if (TimeDeltaUnit.MINUTES.get_seconds() <= total_seconds) {
				return TimeDeltaUnit.MINUTES;
			}
			return TimeDeltaUnit.SECONDS;
		}
	}
	
	/*
		Return a pretty, localized string representation of the `TimeDelta` like
		"12 hours" or "1 second".

		Because a string like "1 hour" is not precise enough, it must also
		include information about the value of the next smaller time scale, in
		this case minutes.

		Because such values will often be imprecise (especially if they"re
		estimations), the value of the next smaller time scale will be rounded
		down.

		This means that instead of "1 hour and 43 minutes", the returned string
		will be "1 hour and 40 minutes". For estimations that are likely to
		change over time, this causes the return values to be changed less
		frequently.

		Consider the following example return values:

		>>> TimeDelta(seconds=46).short
		"46 seconds"
		>>> TimeDelta(minutes=2, seconds=3).short
		"2 minutes"
		>>> TimeDelta(minutes=2, seconds=33).short
		"2 minutes".
		>>> TimeDelta(hours=2, minutes=3).short
		"2 hours"
		>>> TimeDelta(hours=2, minutes=33).short
		"2 hours and 30 minutes".
		>>> TimeDelta(days=2, minutes=57)
		"2 days"
		>>> TimeDelta(days=1, hours=18)
		"1 day and 18 hours"
	*/
	public new string to_string () {
		var major_unit = major_unit;
		var major_unit_value = get(major_unit);
		if (major_unit == TimeDeltaUnit.SECONDS ||
			major_unit == TimeDeltaUnit.MINUTES) {
			return to_simple_string(major_unit);
		} else if (major_unit_value >= 10) {
			return to_simple_string(major_unit);
		} else {
			var minor_unit = major_unit.get_next_smaller_unit();
			var minor_unit_value = get(minor_unit);
			if (minor_unit == TimeDeltaUnit.MINUTES ||
				minor_unit == TimeDeltaUnit.SECONDS) {
				// Only round minutes and seconds.
				minor_unit_value = (minor_unit_value / 10) * 10;
			}
			if (minor_unit_value == 0) {
				// Don't return something like '1 minute and 0 seconds', but
				// simply '1 minute'.
				return to_simple_string(major_unit);
			} else {
				TimeDelta rounded_time_delta = TimeDelta.with_units(
					major_unit_value, major_unit, minor_unit_value, minor_unit);
				var major_unit_string = rounded_time_delta.to_simple_string (major_unit);
				var minor_unit_string = rounded_time_delta.to_simple_string (minor_unit);
				return _(@"$(major_unit_string) and $(minor_unit_string)");
			}
		}
	}

	public TimeDelta dup () {
		return this;
	}

	public void free () {
	}

	public bool is_known {
		get {
			return this != UNKNOWN;
		}
	}
	
}

public enum Lottanzb.TimeDeltaUnit {

	DAYS,
	HOURS,
	MINUTES,
	SECONDS;
	
	public int get_seconds () {
		switch (this) {
			case DAYS:
				return 60 * 60 * 24;
			case HOURS:
				return 60 * 60;
			case MINUTES:
				return 60;
			case SECONDS:
				return 1;
			default:
				assert_not_reached();
		}
	}
	
	public TimeDeltaUnit get_next_smaller_unit () {
		switch (this) {
			case DAYS:
				return HOURS;
			case HOURS:
				return MINUTES;
			case MINUTES:
				return SECONDS;
			default:
				assert_not_reached();
		}
	}
	
	public static TimeDeltaUnit[] all() {
		return { DAYS, HOURS, MINUTES, SECONDS };
	}
	
	public static TimeDeltaUnit from_char (char character) {
		switch (character) {
			case 'd':
				return TimeDeltaUnit.DAYS;
			case 'h':
				return TimeDeltaUnit.HOURS;
			case 'm':
				return TimeDeltaUnit.MINUTES;
			case 's':
				return TimeDeltaUnit.SECONDS;
			default:
				assert_not_reached();
		}
	}

}
