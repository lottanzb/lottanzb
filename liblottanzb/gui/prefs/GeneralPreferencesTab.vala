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

	private BetterSettings lottanzb_settings;
	private SabnzbdRootSettings sabnzbd_settings;
	private TogglableFolderSettingController watched_folder_controller;
	private FolderSettingController download_folder_controller;
	private PostProcessingController post_processing_controller;
	private BandwidthLimitController bandwidth_limit_controller;

	public GeneralPreferencesTab (Backend backend, BetterSettings lottanzb_settings, SabnzbdRootSettings sabnzbd_settings) {
		base ();

		this.lottanzb_settings = lottanzb_settings;
		this.sabnzbd_settings = sabnzbd_settings;

		var misc_settings = sabnzbd_settings.get_misc ();
		var any_category = sabnzbd_settings.get_categories ().get_any_category ();
		var is_local = backend.query_processor.connection_info.is_local;

		watched_folder_controller = new TogglableFolderSettingController (
				misc_settings, "dirscan-dir", is_local,
				widgets.watched_folder_button, widgets.watched_folder_entry, widgets.dirscan);
		download_folder_controller = new FolderSettingController (
				misc_settings, "complete-dir", is_local,
				widgets.download_folder_button, widgets.download_folder_entry);
		post_processing_controller = new PostProcessingController (
				any_category, widgets.post_processing);
		bandwidth_limit_controller = new BandwidthLimitController (
				misc_settings, "bandwidth-limit",
				widgets.enforce_max_rate, widgets.max_rate, widgets.max_rate_scale);

		widgets.prefs_tab_general.remove (widgets.prefs_tab_general.get_child ());
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

public class Lottanzb.PostProcessingController : Object {

	private BetterSettings category;
	private Gtk.ComboBox combo_box;
	private PostProcessingModel model;

	public PostProcessingController (BetterSettings category, Gtk.ComboBox combo_box) {
		this.category = category;
		this.combo_box = combo_box;
		this.model = new PostProcessingModel ();

		var cell_renderer = new Gtk.CellRendererText ();
		combo_box.set_model (model);
		combo_box.pack_start (cell_renderer, true);
		combo_box.add_attribute (cell_renderer, "markup",
			PostProcessingModel.Column.DESCRIPTION);

		LottanzbResource.bind_with_mapping (
			category, "pp",
			combo_box, "active",
			SettingsBindFlags.DEFAULT,
			(value, variant, user_data) => {
				var _model = (PostProcessingModel) user_data;
				var post_processing = (DownloadPostProcessing) variant.get_int32 ();
				var index = _model.index_of (post_processing);
				value.set_int (index);
				return true;
			},
			(value, expected_type, user_data) => {
				var _model = (PostProcessingModel) user_data;
				var index = value.get_int ();
				var post_processing = _model.get_download_post_processing (index);
				var variant = new Variant.int32 (post_processing);
				return variant;
			},
			model,
			unref
		);
	}

}

public class Lottanzb.PostProcessingModel : Gtk.ListStore, IterableTreeModel {

	public enum Column {

		ID,
		DESCRIPTION

	}

	public PostProcessingModel () {
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

	public DownloadPostProcessing get_download_post_processing (int index) {
		Gtk.TreeIter iter;
		get_iter (out iter, new Gtk.TreePath.from_indices (index));
		DownloadPostProcessing post_processing;
		get (iter, PostProcessingModel.Column.ID, out post_processing);
		return post_processing;
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

public class Lottanzb.FolderSettingController : Object {

	protected BetterSettings settings;
	protected string key;
	protected bool is_local;
	protected Gtk.FileChooserButton file_chooser_button;
	protected Gtk.Entry entry;

	public FolderSettingController (BetterSettings settings, string key, bool is_local,
			Gtk.FileChooserButton file_chooser_button, Gtk.Entry entry) {
		this.settings = settings;
		this.key = key;
		this.is_local = is_local;
		this.file_chooser_button = file_chooser_button;
		this.entry = entry;

		this.file_chooser_button.visible = is_local;
		this.entry.visible = !is_local;

		settings.changed[key].connect ((settings, key) => { on_settings_changed (); });
		file_chooser_button.selection_changed.connect ((file_chooser_button) => { on_selection_changed (); });
		settings.bind (key, entry, "text", SettingsBindFlags.DEFAULT);
		on_settings_changed ();
	}

	private void on_settings_changed () {
		var new_folder = settings.get_string (key);
		var current_folder = file_chooser_button.get_current_folder ();
		if (current_folder != new_folder) {
			file_chooser_button.set_current_folder (new_folder);
		}
	}

	private void on_selection_changed () {
		var new_folder = file_chooser_button.get_uri ().replace ("file://", "");
		var current_folder = settings.get_string (key);
		if (current_folder != new_folder) {
			settings.set_string (key, new_folder);
		}
	}

}

public class Lottanzb.TogglableFolderSettingController : FolderSettingController {

	public TogglableFolderSettingController (BetterSettings settings, string key, bool is_local,
			Gtk.FileChooserButton file_chooser_button, Gtk.Entry entry, Gtk.ToggleButton toggle_button) {
		base (settings, key, is_local, file_chooser_button, entry);
		LottanzbResource.bind_with_mapping (
			settings, key,
			toggle_button, "active",
			SettingsBindFlags.DEFAULT,
			(value, variant, user_data) => {
				var has_folder = variant.get_string ().length > 0;
				value.set_boolean (has_folder);
				return true;
			},
			(value, expected_type, user_data) => {
				var has_folder = value.get_boolean ();
				var folder = (has_folder) ? "Downloads" : "";
				var variant = new Variant.string (folder);
				return variant;
			},
			null,
			unref
		);
		settings.changed [key].connect ((settings, key) => { update_sensitivity (); });
		update_sensitivity ();
	}

	private void update_sensitivity () {
		var folder = settings.get_string (key);
		var has_folder = folder.length > 0;
		file_chooser_button.sensitive = has_folder;
		entry.sensitive = has_folder;
	}

}

public class Lottanzb.BandwidthLimitController : Object {

	protected BetterSettings settings;
	protected string key;
	protected Gtk.CheckButton check_button;
	protected Gtk.SpinButton spin_button;
	protected Gtk.Label scale_label;

	public BandwidthLimitController (BetterSettings settings, string key,
			Gtk.CheckButton check_button, Gtk.SpinButton spin_button,
			Gtk.Label scale_label) {
		this.settings = settings;
		this.key = key;
		this.check_button = check_button;
		this.spin_button = spin_button;
		this.scale_label = scale_label;

		LottanzbResource.bind_with_mapping (
			settings, key,
			check_button, "active",
			SettingsBindFlags.DEFAULT,
			(value, variant, user_data) => {
				var bandwidth_limit = variant.get_int32 ();
				var has_bandwidth_limit = bandwidth_limit != 0;
				value.set_boolean (has_bandwidth_limit);
				return true;
			},
			(value, expected_type, user_data) => {
				var has_bandwidth_limit = value.get_boolean ();
				var bandwidth_limit = (has_bandwidth_limit) ? 1000 : 0;
				var variant = new Variant.int32 (bandwidth_limit);
				return variant;
			},
			null,
			unref
		);
		settings.bind (key, spin_button, "value", SettingsBindFlags.DEFAULT);
		settings.changed.connect ((settings, key) => { update_sensitivity (); });
		update_sensitivity ();
	}

	private void update_sensitivity () {
		var bandwidth_limit = settings.get_int (key);
		var has_bandwidth_limit = bandwidth_limit != 0;
		spin_button.sensitive = has_bandwidth_limit;
		scale_label.sensitive = has_bandwidth_limit;
	}

}
