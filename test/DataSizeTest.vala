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

using Lottanzb;

public class Lottanzb.DataSizeTest : Lottanzb.TestSuiteBuilder {

	public DataSizeTest () {
		base ("data_size");
		add_test ("constructors", test_constructors);
		add_test ("getters", test_getters);
		add_test ("string_conversion", test_string_conversion);
		add_test ("unit", test_unit);
	}

	public void test_constructors () {
		DataSize data_size;
		data_size = DataSize (1000);
		assert (data_size.bytes == 1000);
		data_size = DataSize.with_unit (2.0, DataSizeUnit.BYTES);
		assert (data_size.bytes == 2);
		data_size = DataSize.with_unit (2.0, DataSizeUnit.KILOBYTES);
		assert (data_size.bytes == 2000);
		data_size = DataSize.parse ("0MB");
		assert (data_size.bytes == 0);
		data_size = DataSize.parse ("3 KB");
		assert (data_size.bytes == 3000);
		data_size = DataSize.parse ("10B");
		assert (data_size.bytes == 10);
		data_size = DataSize.parse ("2.25 GB");
		assert (data_size.bytes == 2250l * 1000l * 1000l );
		data_size = DataSize.parse ("2.0 B");
		assert (data_size.bytes == 2);
		data_size = DataSize.parse ("");
		assert (data_size.bytes == 0);
	}

	public void test_getters () {
		DataSize data_size;
		data_size = DataSize (500);
		assert (data_size.bytes == 500);
		assert (data_size.kilobytes == 0.5);
		assert (data_size.major_unit == DataSizeUnit.BYTES);
		data_size = DataSize (500000);
		assert (data_size.kilobytes == 500.0);
		assert (data_size.major_unit == DataSizeUnit.KILOBYTES);
		data_size = DataSize.with_unit (1.0, DataSizeUnit.MEGABYTES);
		assert (data_size.major_unit == DataSizeUnit.MEGABYTES);
		assert (data_size.megabytes == 1.0);
		data_size = DataSize.with_unit (1.0, DataSizeUnit.GIGABYTES);
		assert (data_size.major_unit == DataSizeUnit.GIGABYTES);
		assert (data_size.gigabytes == 1.0);
		data_size = DataSize.with_unit (1.0, DataSizeUnit.TERABYTES);
		assert (data_size.major_unit == DataSizeUnit.TERABYTES);
		assert (data_size.terabytes == 1.0);
	}

	public void test_string_conversion () {
		DataSize data_size;
		data_size = DataSize (0);
		assert (data_size.to_string () == "0 bytes");
		data_size = DataSize (1);
		assert (data_size.to_string () == "1 byte");
		data_size = DataSize (2);
		assert (data_size.to_string () == "2 bytes");
		data_size = DataSize (999);
		assert (data_size.to_string () == "999 bytes");
		data_size = DataSize (1000);
		assert (data_size.to_string () == "1.0 kB");
		data_size = DataSize (999000);
		assert (data_size.to_string () == "999.0 kB");
		data_size = DataSize.with_unit (1, DataSizeUnit.MEGABYTES);
		assert (data_size.to_string () == "1.0 MB");
		data_size = DataSize.with_unit (1, DataSizeUnit.GIGABYTES);
		assert (data_size.to_string () == "1.0 GB");
		data_size = DataSize.with_unit (1, DataSizeUnit.TERABYTES);
		assert (data_size.to_string () == "1.0 TB");
	}

	public void test_unit () {
		assert (DataSizeUnit.BYTES.to_string () == "bytes");
	}

}

public class Lottanzb.DataSpeedTest : Lottanzb.TestSuiteBuilder {

	public DataSpeedTest () {
		base ("data_speed");
		add_test ("constructors", test_constructors);
		add_test ("getters", test_getters);
		add_test ("string_conversion", test_string_conversion);
	}

	public void test_constructors () {
		DataSpeed data_speed;
		data_speed = DataSpeed (10);
		assert (data_speed.bytes_per_second == 10);
		data_speed = DataSpeed.with_unit (10, DataSizeUnit.BYTES);
		assert (data_speed.bytes_per_second == 10);
		data_speed = DataSpeed.with_unit (10, DataSizeUnit.KILOBYTES);
		assert (data_speed.bytes_per_second == 10 * 1000l);
		data_speed = DataSpeed.with_unit (10, DataSizeUnit.MEGABYTES);
		assert (data_speed.bytes_per_second == 10 * 1000l * 1000l);
		data_speed = DataSpeed.with_unit (10, DataSizeUnit.GIGABYTES);
		assert (data_speed.bytes_per_second == 10 * 1000l * 1000l * 1000l);
		data_speed = DataSpeed.with_unit (10, DataSizeUnit.TERABYTES);
		assert (data_speed.bytes_per_second == 10 * 1000l * 1000l * 1000l * 1000l);
		data_speed = DataSpeed.parse ("10 TB");
		assert (data_speed.bytes_per_second == 10 * 1000l * 1000l * 1000l * 1000l);
	}

	public void test_getters () {
		DataSpeed data_speed;
		data_speed = DataSpeed.with_unit (1.0, DataSizeUnit.KILOBYTES);
		assert (data_speed.kilobytes_per_second == 1.0);
		data_speed = DataSpeed.with_unit (1.0, DataSizeUnit.MEGABYTES);
		assert (data_speed.megabytes_per_second == 1.0);
		data_speed = DataSpeed.with_unit (1.0, DataSizeUnit.GIGABYTES);
		assert (data_speed.gigabytes_per_second == 1.0);
		data_speed = DataSpeed.with_unit (1.0, DataSizeUnit.TERABYTES);
		assert (data_speed.terabytes_per_second == 1.0);
	}

	public void test_string_conversion () {
		DataSpeed data_speed;
		data_speed = DataSpeed (0);
		assert (data_speed.to_string () == "0 bytes/s");
		data_speed = DataSpeed (1);
		assert (data_speed.to_string () == "1 byte/s");
		data_speed = DataSpeed (2);
		assert (data_speed.to_string () == "2 bytes/s");
		data_speed = DataSpeed (999);
		assert (data_speed.to_string () == "999 bytes/s");
		data_speed = DataSpeed (1000);
		assert (data_speed.to_string () == "1.0 kB/s");
		data_speed = DataSpeed (999000);
		assert (data_speed.to_string () == "999.0 kB/s");
		data_speed = DataSpeed.with_unit (1, DataSizeUnit.MEGABYTES);
		assert (data_speed.to_string () == "1.0 MB/s");
		data_speed = DataSpeed.with_unit (1, DataSizeUnit.GIGABYTES);
		assert (data_speed.to_string () == "1.0 GB/s");
		data_speed = DataSpeed.with_unit (1, DataSizeUnit.TERABYTES);
		assert (data_speed.to_string () == "1.0 TB/s");
	}

}

