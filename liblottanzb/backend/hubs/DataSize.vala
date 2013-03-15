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

[CCode (type_id = "G_TYPE_LONG")]
[LongType (rank = 6)]
public struct Lottanzb.DataSize : long {

	public static const DataSize UNKNOWN = -1;

	public static DataSize with_unit (double size, DataSizeUnit unit) {
		return (long) (size * unit.get_bytes());
	}
	
	public static new DataSize parse (string data_size_string) {
		try {
			Regex pattern = new Regex ("^(?P<size>-?[0-9]+(\\.[0-9]+)?)\\s*(?P<unit>[KMGTP]?B?)$");
			MatchInfo match_info;
			bool match = pattern.match(data_size_string, 0, out match_info);
			if (match) {
				string unit_string = match_info.fetch_named("unit");
				var unit_char = 'B';
				if (unit_string.length > 0) {
					unit_char = unit_string[0];
				}
				DataSizeUnit unit = DataSizeUnit.from_char(unit_char);
				var size = double.parse(match_info.fetch_named("size"));
				return with_unit (size, unit);
			} else {
				if (data_size_string.length > 0) {
					warning ("could not parse data size: %s", data_size_string);
				}
				return UNKNOWN;
			}
		} catch (RegexError e) {
			warning ("%s", e.message);
		}
		return UNKNOWN;
	}

	public long bytes {
		get {
			return this;
		}
	}
	
	public double kilobytes {
		get {
			return bytes / (double) DataSizeUnit.KILOBYTES.get_bytes();
		}
	}
	
	public double megabytes {
		get {
			return bytes / (double) DataSizeUnit.MEGABYTES.get_bytes();
		}
	}
	
	public double gigabytes {
		get {
			return bytes / (double) DataSizeUnit.GIGABYTES.get_bytes();
		}
	}
	
	public double terabytes {
		get {
			return bytes / (double) DataSizeUnit.TERABYTES.get_bytes();
		}
	}
	
	public double get (DataSizeUnit unit) {
		switch (unit) {
			case DataSizeUnit.BYTES:
				return bytes;
			case DataSizeUnit.KILOBYTES:
				return kilobytes;
			case DataSizeUnit.MEGABYTES:
				return megabytes;
			case DataSizeUnit.GIGABYTES:
				return gigabytes;
			case DataSizeUnit.TERABYTES:
				return terabytes;
			default:
				assert_not_reached();
		}
	}
	
	public DataSizeUnit major_unit {
		get {
			if (bytes < DataSizeUnit.KILOBYTES.get_bytes()) {
				return DataSizeUnit.BYTES;
			} else if (bytes < DataSizeUnit.MEGABYTES.get_bytes()) {
				return DataSizeUnit.KILOBYTES;
			} else if (bytes < DataSizeUnit.GIGABYTES.get_bytes()) {
				return DataSizeUnit.MEGABYTES;
			} else if (bytes < DataSizeUnit.TERABYTES.get_bytes()) {
				return DataSizeUnit.GIGABYTES;
			}
			return DataSizeUnit.TERABYTES;
		}
	}
	
	public new string to_string () {
		var unit = major_unit;
		var size = get(major_unit);
		if (unit == DataSizeUnit.BYTES) {
			var unit_string = ngettext("byte", "bytes", (long) size);
			// Do not show any decimal places when displaying a number of bytes.
			return "%.0f %s".printf(size, unit_string);
		} else {
			var unit_string = unit.to_string();
			return "%.1f %s".printf(size, unit_string);
		}
	}

	public DataSize dup () {
		return this;
	}

	public void free () {
	}

	public bool is_known {
		get {
			return (long) this != UNKNOWN;
		}
	}

}

[CCode (type_id = "G_TYPE_LONG")]
[LongType (rank = 6)]
public struct Lottanzb.DataSpeed : long {

	public static const DataSpeed UNKNOWN = -1;

	public static DataSpeed with_unit (double speed, DataSizeUnit unit) {
		return DataSize.with_unit (speed, unit);
	}

	public new static DataSpeed parse (string data_size_string) {
		return DataSize.parse (data_size_string);
	}

	public long bytes_per_second {
		get {
			return this;
		}
	}

	public double kilobytes_per_second {
		get {
			return ((DataSize) this).kilobytes;
		}
	}

	public double megabytes_per_second {
		get {
			return ((DataSize) this).megabytes;
		}
	}

	public double gigabytes_per_second {
		get {
			return ((DataSize) this).gigabytes;
		}
	}

	public double terabytes_per_second {
		get {
			return ((DataSize) this).terabytes;
		}
	}

	public new string to_string () {
		return ((DataSize) this).to_string() + "/s";
	} 

	public DataSpeed dup () {
		return this;
	}

	public void free () {
	}

	public bool is_known {
		get {
			return (long) this != UNKNOWN;
		}
	}

}

public enum Lottanzb.DataSizeUnit {

	BYTES,
	KILOBYTES,
	MEGABYTES,
	GIGABYTES,
	TERABYTES;
	
	public string to_string () {
		switch (this) {
			case BYTES:
				return "bytes";
			case KILOBYTES:
				return "kB";
			case MEGABYTES:
				return "MB";
			case GIGABYTES:
				return "GB";
			case TERABYTES:
				return "TB";
			default:
				assert_not_reached();
		}
	}
	
	public long get_bytes () {
		switch (this) {
			case BYTES:
				return 1;
			case KILOBYTES:
				return 1000l;
			case MEGABYTES:
				return 1000l * 1000l;
			case GIGABYTES:
				return 1000l * 1000l * 1000l;
			case TERABYTES:
				return 1000l * 1000l * 1000l * 1000l;
			default:
				assert_not_reached();
		}
	}
	
	public static DataSizeUnit from_char (char character) {
		switch (character) {
			case 'B':
				return BYTES;
			case 'K':
				return KILOBYTES;
			case 'M':
				return MEGABYTES;
			case 'G':
				return GIGABYTES;
			case 'T':
				return TERABYTES;
			default:
				assert_not_reached();
		}
	}
	
}
