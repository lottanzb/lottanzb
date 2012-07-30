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

private static int main (string[] args) {
	Environment.set_variable ("GSETTINGS_BACKEND", "memory", true);
	Gtk.init_check (ref args);
	Test.init (ref args);
	Test.add_data_func ("/lottanzb/backend/datasize/constructors",
		test_data_size_constructors);
	Test.add_data_func ("/lottanzb/backend/datasize/getters", 
		test_data_size_getters);
	Test.add_data_func ("/lottanzb/backend/datasize/string_conversion",
		test_data_size_string_conversion);
	Test.add_data_func ("/lottanzb/backend/dataspeed/constructors",
		test_data_speed_constructors);
	Test.add_data_func ("/lottanzb/backend/dataspeed/getters", 
		test_data_speed_getters);
	Test.add_data_func ("/lottanzb/backend/dataspeed/string_conversion",
		test_data_speed_string_conversion);
	Test.add_data_func ("/lottanzb/backend/datasizeunit",
		test_data_size_unit);
	Test.add_data_func ("/lottanzb/backend/connection_info",
		test_connection_info);
	Test.add_data_func ("/lottanzb/backend/download_list_store/basic",
		test_download_list_store_basic);
	Test.add_data_func ("/lottanzb/backend/download_list_store/filtering",
		test_download_list_store_filtering);
	Test.add_data_func ("/lottanzb/backend/queries/get_authentication_type_query",
		test_get_authentication_type_query);
	Test.add_data_func ("/lottanzb/backend/queries/get_warnings_query",
		test_get_warnings_query);
	Test.add_data_func ("/lottanzb/backend/queries/pause_query",
		test_pause_query);
	Test.add_data_func ("/lottanzb/backend/queries/resume_query",
		test_resume_query);
	Test.add_data_func ("/lottanzb/backend/hubs/config",
		test_config_hub);
	Test.add_data_func ("/lottanzb/backend/hubs/config/servers_settings",
		test_config_hub_servers_settings);
	Test.add_data_func ("/lottanzb/backend/hubs/config/servers_settings/delayed_application",
		test_config_hub_servers_settings_delay_application);
	Test.add_data_func ("/lottanzb/backend/hubs/config/servers_tree_model",
		test_servers_tree_model);
	Test.add_data_func ("/lottanzb/backend/hubs/general/moving_downloads",
		test_general_hub_moving_downloads);
	Test.add_data_func ("/lottanzb/backend/hubs/general/download_name_binding",
		test_general_hub_download_name_binding);
	Test.add_data_func ("/lottanzb/backend/hubs/general/download_priority_binding",
		test_general_hub_download_priority_binding);
	Test.add_data_func ("/lottanzb/backend/hubs/general/download/status",
		test_download_status);
	Test.add_data_func ("/lottanzb/backend/hubs/general/download/priority",
		test_download_priority);
	Test.add_data_func ("/lottanzb/backend/hubs/general/updater/initial_update",
		test_download_list_store_updater_initial_update);
	Test.add_data_func ("/lottanzb/backend/hubs/general/updater/idempotence",
		test_download_list_store_updater_idempotence);
	Test.add_data_func ("/lottanzb/backend/hubs/general/updater/simple_reordering",
		test_download_list_store_updater_simple_reordering);
	Test.add_data_func ("/lottanzb/backend/queries/get_queue_query",
		test_queue_query);
	Test.add_data_func ("/lottanzb/backend/queries/get_history_query",
		test_get_history_query);

	return Test.run ();
}
