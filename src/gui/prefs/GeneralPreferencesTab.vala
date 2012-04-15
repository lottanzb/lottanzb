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

public class Lottanzb.GeneralPreferencesTab : AbstractGeneralPreferencesTab, PreferencesTab {

	public GeneralPreferencesTab (Backend backend, Settings lottanzb_settings, Settings sabnzbd_settings) {
		base ();
		widgets.prefs_tab_general.remove (widgets.prefs_tab_general.get_child ());

		var post_processing_combox_box_model = new PostProcessingComboBoxModel ();
		var cell_renderer = new Gtk.CellRendererText ();
		widgets.post_processing.set_model (post_processing_combox_box_model);
		widgets.post_processing.pack_start (cell_renderer, true);
		widgets.post_processing.add_attribute (cell_renderer, "markup",
			PostProcessingComboBoxModel.Column.DESCRIPTION);

		var misc_settings = sabnzbd_settings.get_child ("misc");
		LottanzbResource.bind_with_mapping (
			misc_settings, "dirscan-opts",
			widgets.post_processing, "active",
			SettingsBindFlags.DEFAULT,
			(value, variant, user_data) => {
				var model = (PostProcessingComboBoxModel) user_data;
				var post_processing = (DownloadPostProcessing) variant.get_int32 ();
				var index = model.index_of (post_processing);
				value.set_int (index);
				return true;
			},
			(value, expected_type, user_data) => {
				var model = (PostProcessingComboBoxModel) user_data;
				var index = value.get_int ();
				Gtk.TreeIter iter;
				model.get_iter (out iter, new Gtk.TreePath.from_indices (index));
				DownloadPostProcessing post_processing;
				model.get (iter, PostProcessingComboBoxModel.Column.ID, out post_processing);
				var variant = new Variant.int32 (post_processing);
				return variant;
			},
			post_processing_combox_box_model,
			unref
		);

		var is_local = backend.query_processor.connection_info.is_local;
		widgets.download_folder_button.visible = is_local;
		widgets.download_folder_entry.visible = !is_local;

		widgets.observed_folder_button.visible = is_local;
		widgets.observed_folder_entry.visible = !is_local;
		/* LottanzbResource.bind_with_mapping (
			misc_settings, "complete-dir",
			widgets.download_folder_button, 
		); */
	}

	public string label {
		get {
			return _("General");
		}
	}

	public Gtk.Widget widget {
		get {
			return widgets.vbox1;
		}
	}

}

public class Lottanzb.PostProcessingComboBoxModel : Gtk.ListStore, IterableTreeModel {

	public enum Column {
	
		ID,
		DESCRIPTION

	}

	public PostProcessingComboBoxModel () {
		set_column_types (new Type[] { typeof (DownloadPostProcessing), typeof (string) });
		insert_with_values (null, 0,
			Column.ID, DownloadPostProcessing.NOTHING,
			Column.DESCRIPTION, _("<i>Do nothing</i>"));
		insert_with_values (null, 1,
			Column.ID, DownloadPostProcessing.REPAIR,
			Column.DESCRIPTION, _("Repair downloaded archives if necessary"));
		insert_with_values (null, 2,
			Column.ID, DownloadPostProcessing.UNPACK,
			Column.DESCRIPTION, _("Repair and extract downloaded archives"));
		insert_with_values (null, 3,
			Column.ID, DownloadPostProcessing.DELETE,
			Column.DESCRIPTION, _("Repair, extract and delete downloaded archives"));
	}

	public int index_of (DownloadPostProcessing post_processing) {
		foreach (var iter in this) {
			DownloadPostProcessing some_post_processing;
			get (iter, Column.ID, out some_post_processing);
			if (some_post_processing == post_processing) {
				var path = get_path (iter);
				var index = path.get_indices ()[0];
				return index;
			}
		}
		return -1;
	}



}
