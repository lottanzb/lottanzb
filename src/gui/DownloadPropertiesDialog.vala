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

using Gtk;

public class Lottanzb.DownloadPropertiesDialog : AbstractDownloadPropertiesDialog {

	protected Download _download;
	protected ActivityField[] _activity_fields;
	protected ulong _download_status_changed_signal_id;
	protected Binding? download_name_binding;
	protected ulong _priority_change_signal_id;
	
	public DownloadPropertiesDialog (GeneralHub general_hub, Download download) {
		base ();
		foreach (DownloadPriority priority in DownloadPriority.all ()) {
			widgets.priority_store.insert_with_values (null, int.MAX,
				0, priority.to_string ());
		}
		this.general_hub = general_hub;
		this.download = download;
	}

	public GeneralHub general_hub { get; construct set; }

	public Gtk.Dialog dialog {
		get {
			return widgets.properties_dialog;
		}
	}

	public Download download {
		get {
			return _download;
		}
		set {
			if (_download != null) {
				download_name_binding = null;
				widgets.priority.disconnect (_priority_change_signal_id);
				_download.disconnect (_download_status_changed_signal_id);	
			}
			_download = value;
			
			// Instantiate new activity fields, bound to the active download
			activity_fields = {
				new StatusField (download),
				new DownloadedField (download),
				new SizeField (download),
				new TimeLeftField (download),
				new ETAField (download),
				new AgeField (download),
				new DownloadTimeField (download),
				new PostProcessingField (download),
				new CompletedField (download),
				new ErrorMessageField(download)
			};

			// Change the download name seamlessly
			// TODO: Only set when non-empty (could add check to Download)
			download.bind_property ("name", widgets.name, "text",
				BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL, null, null);
			
			// Change the download priority seamlessly
			var priorities = DownloadPriority.all ();
			for (var index = 0; index < priorities.length; index++) {
				if (priorities[index] == download.priority) {
					widgets.priority.set_active (index);
					break;
				}
			}
			_priority_change_signal_id = widgets.priority.changed.connect ((widget) => {
				var index = (DownloadPriority) widgets.priority.get_active ();
				var new_priority = DownloadPriority.all ()[index];
				general_hub.set_download_priority (download, new_priority);
			});

			_download_status_changed_signal_id = download.notify["status"].connect ((download, prop) => {
				on_download_status_changed ();		
			});
			on_download_status_changed ();
		}
	}

	private ActivityField[] activity_fields {
		get {
			return _activity_fields;
		}
		set {
			if (_activity_fields != null) {
				// Remove all existing activity fields
				foreach (ActivityField activity_field in _activity_fields) {
					widgets.activity_grid.remove (activity_field.label);
					widgets.activity_grid.remove (activity_field.content);
					widgets.label_size_group.remove_widget (activity_field.label);
				}
			}
			_activity_fields = value;
			
			// Add all activity fields to the activity table
			for (int index = 0; index < _activity_fields.length; index++) {
				var activity_field = _activity_fields [index];
				widgets.activity_grid.attach (activity_field.label, 0, index, 1, 1);
				widgets.activity_grid.attach (activity_field.content, 1, index, 1, 1);
				widgets.label_size_group.add_widget (activity_field.label);
			}
		}
	}

	public void on_download_status_changed () {
		var connection_info = general_hub.query_processor.connection_info;
		var is_local = connection_info.is_local;
		var is_fully_loaded = download.status.is_in_group (DownloadStatusGroup.FULLY_LOADED);
		widgets.open_download_folder.visible = is_local && is_fully_loaded;
		widgets.name.sensitive = !is_fully_loaded;
		widgets.priority.sensitive = !is_fully_loaded;
	}

	public void show (Gtk.Window? parent_window = null) {
		if (parent_window != null) {
			dialog.set_transient_for (parent_window);
		}
		dialog.present ();
	}

	[CCode (instance_pos = -1)]
	public void on_open_download_folder_activate (Gtk.Action action) {
		if (download != null && download.storage_path != null) {
			try {
				Gtk.show_uri (null, "file://" + download.storage_path, Gdk.CURRENT_TIME);
			} catch (Error e) {
				var title = _("Could not open download folder");
				var message_dialog = new Gtk.MessageDialog (dialog,
					Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR,
					Gtk.ButtonsType.OK, title);
				message_dialog.secondary_text = e.message;
				message_dialog.run ();
				message_dialog.destroy ();
			}
		}
	}

	[CCode (instance_pos = -1)]
	public void on_dialog_response (Dialog dialog, int response) {
		if (response == Gtk.ResponseType.CLOSE) {
			dialog.destroy ();
		}
	}
	
}

/**
 * A certain entry in the 'Activity' section of the dialog.
 *
 * It's bound to a certain download and only exists as long as that particular
 * download is being displayed in the dialog. The activity field will take care
 * of updating its information when the download information changes.
 * 
 * It will be visible iff the download has the status passed as the
 * `visibility' argument.
*/
public abstract class Lottanzb.ActivityField : Object {

	public Download download { get; private set; }
	public Label label { get; private set; }
	public Widget content { get; private set; }
	public int visibility_status_group { get; private set; }
	public string[] required_download_properties { get; private set; }
	
	public ActivityField (Download download, string label_text, Widget content,
		string[] required_download_properties,
		int visibility_status_group = DownloadStatusGroup.ANY_STATUS) {
		this.download = download;
		this.label = new Label (@"$(label_text):");
		this.label.set_alignment (0.0f, 0.0f);
		this.content = content;
		this.required_download_properties = required_download_properties;
		this.visibility_status_group = visibility_status_group;
		download.notify ["status"].connect ((o, p) => { update_visibility (); });
		update_visibility ();

		foreach (string property in required_download_properties) {
			download.notify [property].connect ((object, param) => {
				update(); // TODO: Beware of '-' vs '_'
			});
		}
		update();
	}
	
	private void update_visibility () {
		bool is_visible = download.status.is_in_group (visibility_status_group);
		label.visible = is_visible;
		content.visible = is_visible;
	}

	/**
	 * Fill `content' with information provided by the download.
	 * To be implemented by subclasses.
	*/
	protected abstract void update ();
	
}

/**
 * Abstract activity field whose content is a simple `gtk.Label'.
 * 
 * It features a facility for automatically observing certain properties of
 * the download for changes. After such a change `update' is called, which
 * is meant to be implemented by subclasses.
*/
public abstract class Lottanzb.SimpleActivityField : ActivityField {
	
	
	public SimpleActivityField (Download download, string label_text,
		string[] required_download_properties,
		int visibility_status_group = DownloadStatusGroup.ANY_STATUS) {
		var content = new Label ("");
		content.set_alignment (0.0f, 0.0f);
		content.set_line_wrap (true);
		
		base (download, label_text, content, required_download_properties,
			visibility_status_group);
	}
		
}

/**
 * Activity field whose content is generated using a format string on
 * which the download is applied. The download will thereby be the first
 * and only formatting argument.
 * 
 * Example: "<b>{0.error_message}</b>"
 * 
 * All properties referenced in the content will automatically be observed
 * for changes.
*/
public abstract class Lottanzb.FormattedActivityField : SimpleActivityField {

	protected static string LABEL_TEXT_UNKNOWN_VALUE = _("Unknown");

	public FormattedActivityField (Download download, string label_text,
		string[] required_download_properties,
		int visibility_status_group = DownloadStatusGroup.ANY_STATUS) {
		base (download, label_text, required_download_properties,
			visibility_status_group);
		update();
	}
	
	protected override void update () {
		var text = get_text ();
		(content as Label).set_text(text);
	}

	protected abstract string get_text ();
	
}

public class Lottanzb.StatusField : SimpleActivityField {

	public StatusField (Download download) {
		string[] required_download_properties = { "status",
			"verification_percentage", "repair_percentage", "unpack_percentage" };
		base (download, _("Status"), required_download_properties);
	}
	
	protected override void update () {
		double percentage = -1.0;
		if (download.status == DownloadStatus.VERIFYING) {
			percentage = download.verification_percentage;
		} else if (download.status == DownloadStatus.REPAIRING) {
			percentage = download.repair_percentage;
		} else if (download.status == DownloadStatus.EXTRACTING) {
			percentage = download.unpack_percentage;
		}
		if (percentage >= 1.0) {
			(content as Label).set_text (@"$(download.status) ($(percentage)%)");
		} else {
			(content as Label).set_text (@"$(download.status)");
		}
	}
	
}

public class Lottanzb.DownloadedField : FormattedActivityField {

	public DownloadedField (Download download) {
		base (download, _("Downloaded"), { "size-downloaded", "size", "percent" },
			DownloadStatusGroup.NOT_FULLY_LOADED);
	}

	protected override string get_text () {
		if (download.size_downloaded != null && download.size != null) {
			return @"$(download.size_downloaded) / $(download.size) ($(download.percentage)%)";
		}
		return LABEL_TEXT_UNKNOWN_VALUE;
	}

}

public class Lottanzb.SizeField : FormattedActivityField {

	public SizeField (Download download) {
		base (download, _("Size"), { "size" },
			DownloadStatusGroup.NOT_FULLY_LOADED);
	}

	protected override string get_text () {
		if (download.size != null) {
			return download.size.to_string ();
		}
		return LABEL_TEXT_UNKNOWN_VALUE;
	}

}

public class Lottanzb.TimeLeftField : FormattedActivityField {

	public TimeLeftField (Download download) {
		base (download, _("Time left"), { "time-left" },
			DownloadStatus.DOWNLOADING);
	}

	protected override string get_text () {
		if (download.time_left != null) {
			return download.time_left.to_string ();
		}
		return LABEL_TEXT_UNKNOWN_VALUE;
	}

}

public class Lottanzb.ETAField : FormattedActivityField {

	public ETAField (Download download) {
		base (download, _("ETA"), { "eta" },
			DownloadStatus.DOWNLOADING);
	}

	protected override string get_text () {
		if (download.eta != null) {
			return download.eta.to_string ();
		}
		return LABEL_TEXT_UNKNOWN_VALUE;
	}

}

public class Lottanzb.AgeField : FormattedActivityField {

	public AgeField (Download download) {
		base (download, _("Age"), { "average-age" },
			DownloadStatusGroup.NOT_FULLY_LOADED);
	}

	protected override string get_text () {
		if (download.average_age != null) {
			return download.average_age.to_string ();
		}
		return LABEL_TEXT_UNKNOWN_VALUE;
	}

}

public class Lottanzb.DownloadTimeField : FormattedActivityField {

	public DownloadTimeField (Download download) {
		base (download, _("Download time"), { "download-time" },
			DownloadStatusGroup.FULLY_LOADED);
	}

	protected override string get_text () {
		if (download.download_time != null) {
			return download.download_time.to_string ();
		}
		return LABEL_TEXT_UNKNOWN_VALUE;
	}

}

public class Lottanzb.PostProcessingField : FormattedActivityField {

	public PostProcessingField (Download download) {
		base (download, _("Post-processing"), { "post-porocessing-time" },
			DownloadStatusGroup.FULLY_LOADED);
	}

	protected override string get_text () {
		if (download.post_processing_time != null) {
			return download.post_processing_time.to_string ();
		}
		return LABEL_TEXT_UNKNOWN_VALUE;
	}

}

public class Lottanzb.CompletedField : FormattedActivityField {

	public CompletedField (Download download) {
		base (download, _("Completed"), { "completed" },
			DownloadStatusGroup.FULLY_LOADED);
	}

	protected override string get_text () {
		if (download.completed != null) {
			return download.completed.to_string ();
		}
		return LABEL_TEXT_UNKNOWN_VALUE;
	}

}

public class Lottanzb.ErrorMessageField : ActivityField {

	private Gtk.TextBuffer text_buffer;

	public ErrorMessageField (Download download) {
		var text_view = new Gtk.TextView ();
		text_view.wrap_mode = Gtk.WrapMode.WORD;
		text_view.editable = false;
		var content = new Gtk.ScrolledWindow (null, null);
		content.add (text_view);
		content.hscrollbar_policy = Gtk.PolicyType.NEVER;
		content.vscrollbar_policy = Gtk.PolicyType.NEVER;
		content.shadow_type = Gtk.ShadowType.ETCHED_IN;

		base (download, _("Error"), content, { "error-message" }, DownloadStatus.FAILED);
		text_buffer = text_view.buffer;
	}

	protected override void update () {
		if (text_buffer != null) {
			text_buffer.text = download.error_message;
		}
	}

}
