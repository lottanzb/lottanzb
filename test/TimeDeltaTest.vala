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

public class Lottanzb.TimeDeltaTest : Lottanzb.TestSuiteBuilder {

	public TimeDeltaTest () {
		base ("time_delta");
		add_test ("constructors", test_constructors);
		add_test ("string_conversion", test_string_conversion);
	}

	public void test_constructors () {
		TimeDelta delta;
		delta = TimeDelta (1000);
		assert (delta.total_seconds == 1000);
		delta = TimeDelta.with_unit (2, TimeDeltaUnit.DAYS);
		assert (delta.total_seconds == 2 * 24 * 60 * 60);
		delta = TimeDelta.with_units (10, TimeDeltaUnit.HOURS, 5, TimeDeltaUnit.MINUTES);
		assert (delta.total_seconds == 10 * 60 * 60 + 5 * 60);
		delta = TimeDelta.with_parts (1, 2, 3, 4);
		assert (delta.total_seconds == 1 * 24 * 60 * 60 + 2 * 60 * 60 + 3 * 60 + 4);
	}

	public void test_string_conversion () {
		TimeDelta delta;
		delta = TimeDelta (46);
		assert (delta.to_string() == "46 seconds");
		delta = TimeDelta.with_units (2, TimeDeltaUnit.MINUTES, 3, TimeDeltaUnit.SECONDS);
		assert (delta.to_string() == "2 minutes");
		delta = TimeDelta.with_units (2, TimeDeltaUnit.MINUTES, 33, TimeDeltaUnit.SECONDS);
		assert (delta.to_string() == "2 minutes");
		delta = TimeDelta.with_units (2, TimeDeltaUnit.HOURS, 3, TimeDeltaUnit.MINUTES);
		assert (delta.to_string() == "2 hours");
		delta = TimeDelta.with_units (2, TimeDeltaUnit.HOURS, 33, TimeDeltaUnit.MINUTES);
		assert (delta.to_string() == "2 hours and 30 minutes");
		delta = TimeDelta.with_units (2, TimeDeltaUnit.DAYS, 57, TimeDeltaUnit.MINUTES);
		assert (delta.to_string() == "2 days");
		delta = TimeDelta.with_units (2, TimeDeltaUnit.DAYS, 18, TimeDeltaUnit.HOURS);
		assert (delta.to_string() == "2 days and 18 hours");
	}

}
