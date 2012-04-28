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


public class Lottanzb.AddFileDialog : AbstractAddFileDialog {
	
	private static string SETTINGS_KEY = "add-file";
	private static string SETTINGS_LAST_FOLDER_URI = "last-folder-uri";
	
	private QueryProcessor query_processor;
	private BetterSettings add_file_settings;

	public AddFileDialog (QueryProcessor query_processor, BetterSettings gui_settings) {
		this.query_processor = query_processor;
		this.add_file_settings = gui_settings.get_child_for_same_backend_cached (SETTINGS_KEY);
		var last_folder_uri = add_file_settings.get_string (SETTINGS_LAST_FOLDER_URI);
		widgets.add_file_dialog.set_current_folder (last_folder_uri);
	}
	
	public void run (Gtk.Window? window = null) {
		if (window != null) {
			widgets.add_file_dialog.set_transient_for (window);
		}
		widgets.add_file_dialog.run();
		widgets.add_file_dialog.destroy();
	}
	
	[CCode (instance_pos = -1)]
	public void on_current_folder_changed (Gtk.FileChooserDialog dialog) {
		add_file_settings.set_string (SETTINGS_LAST_FOLDER_URI, dialog.get_current_folder ());
	}

	[CCode (instance_pos = -1)]
	public void on_response (Gtk.FileChooserDialog dialog, int response_id) {
		if (response_id == Gtk.ResponseType.OK) {
			query_processor.add_download ("file://" + get_selected_filename (),
				new AddDownloadQueryOptionalArguments ());	
		} else if (response_id == Gtk.ResponseType.HELP) {

		}
	}

	private string get_selected_filename () {
		return widgets.add_file_dialog.get_filename ();
	}
	
}
