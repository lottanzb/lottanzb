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


public class Lottanzb.ConfigProviderImpl : Object, ConfigProvider {
	
	private static string SCHEMA_ID = "apps.lottanzb";

	public BetterSettings lottanzb_config { get; construct set; }
	
	public ConfigProviderImpl () {
		lottanzb_config = new BetterSettings (SCHEMA_ID);
	}

	public ConfigProviderImpl.with_memory_backend () {
		var settings_backend = BetterSettings.build_memory_settings_backend ();
		lottanzb_config = new BetterSettings.with_backend (SCHEMA_ID, settings_backend);
	}
	
}
