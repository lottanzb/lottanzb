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
using Pango;

public class Lottanzb.DownloadList : AbstractDownloadList {

	private GeneralHub general_hub;
	private Window? parent_window;
	private DownloadPropertiesDialog? download_properties_dialog;
	
	private enum DnDTargets {
		DOWNLOAD,
		URL
	}

	public DownloadList (GeneralHub general_hub, Window? parent_window = null) {
		this.general_hub = general_hub;
		this.parent_window = parent_window;
		this.download_properties_dialog = null;
		
		widgets.window1.remove(widget);
		widgets.treeview.append_column (new DownloadListColumn ());
		widgets.treeview.set_search_equal_func (search_equal_func);
		widgets.treeview.set_model (general_hub.download_list_store);
		widgets.treeview.get_selection ().set_mode (SelectionMode.BROWSE);
		widgets.treeview.get_selection ().changed.connect ((selection) => {
			update_action_sensitivity ();
		});
		
		general_hub.download_list_store.rows_reordered.connect ((model, iter, path, new_order) => {
			update_action_sensitivity ();		
		});

		update_action_sensitivity ();

		const TargetEntry[] drag_targets = {
			{ "DOWNLOAD", TargetFlags.SAME_WIDGET, DnDTargets.DOWNLOAD }
		};
		const TargetEntry[] drop_targets = {
			{ "DOWNLOAD", TargetFlags.SAME_WIDGET, DnDTargets.DOWNLOAD },
			{ "text/plain", 0, 1 }
		};
		widgets.treeview.enable_model_drag_source (Gdk.ModifierType.BUTTON1_MASK,
			drag_targets, Gdk.DragAction.MOVE);
		widgets.treeview.enable_model_drag_dest (drop_targets, Gdk.DragAction.MOVE);
	}
	
	public Widget widget {
		get {
			return widgets.download_list;
		}
	}

	public Toolbar reordering_pane {
		get {
			return widgets.reordering_pane;
		}
	}
	
	public Gtk.ActionGroup important_action_group {
		get {
			return widgets.important_action_group;
		}
	}
	
	private bool search_equal_func (TreeModel tree_model, int column,
		string key, TreeIter iter) {
		var download_list_store = (DownloadListStore) tree_model;
		var download = download_list_store.get_download (iter);
		if (download == null) {
			return false;
		} else {
			return key.down () in download.name.down ();
		}
	}
	
	private void update_action_sensitivity () {
		var download = get_selected_download ();
		if (download == null) {
			foreach (var action_group in widgets.ui_manager.get_action_groups()) {
				foreach (var action in action_group.list_actions()) {
					action.sensitive = false;
				}
			}
		} else {
			var is_complete = download.status.is_in_group(DownloadStatusGroup.COMPLETE);
			var is_movable = download.status.is_in_group(DownloadStatusGroup.MOVABLE);
			var queue = general_hub.download_list_store.get_filter_movable ();
			widgets.remove.sensitive = is_movable;
			widgets.move_up.sensitive = is_movable;
			widgets.move_up_to_top.sensitive = is_movable;
			widgets.move_down.sensitive = is_movable;
			widgets.move_down_to_bottom.sensitive = is_movable;
			widgets.pause.sensitive = is_movable;
			widgets.open_folder.sensitive = is_complete;
			widgets.show_properties_dialog.sensitive = true;
			if (is_movable) {
				var queue_length = queue.iter_n_children (null);
				TreeIter first_iter, last_iter;
				Value first_value, last_value;
				queue.get_iter (out first_iter, new TreePath.first ());
				queue.get_iter (out last_iter, new TreePath.from_indices (queue_length - 1));
				queue.get_value (first_iter, DownloadListStore.COLUMN, out first_value);
				queue.get_value (last_iter, DownloadListStore.COLUMN, out last_value);
				Download first_download = (Download) first_value;
				Download last_download = (Download) last_value;
				if (first_download == download) {
					widgets.move_up.sensitive = false;
					widgets.move_up_to_top.sensitive = false;
				}
				if (last_download == download) {
					widgets.move_down.sensitive = false;
					widgets.move_down_to_bottom.sensitive = false;
				}
			}
		}
	}
	
	private void remove_selected_download () {
		var download = get_selected_download ();
		if (download != null &&
			download.status.is_in_group (DownloadStatusGroup.MOVABLE)) {
			var title = _("Remove download?");
			var message = _("This cannot be undone.");
			var dialog = new MessageDialog (parent_window, DialogFlags.MODAL,
				MessageType.WARNING, ButtonsType.OK_CANCEL, title);
			dialog.secondary_text = message;
			var response = dialog.run ();
			dialog.destroy ();
			if (response == ResponseType.OK) {
				general_hub.delete_download (download);
			}
		}
	}
	
	private void show_properties_of_selected_download () {
		var download = get_selected_download ();
		if (download != null) {
			if (download_properties_dialog == null) {
				download_properties_dialog = new DownloadPropertiesDialog (
					general_hub, download);
				download_properties_dialog.dialog.destroy.connect ((dialog) => {
					download_properties_dialog = null;
				});
			} else {
				download_properties_dialog.download = download;
			}
			download_properties_dialog.show (parent_window);
		}
	}

	private Download? get_selected_download () {
		var selection = widgets.treeview.get_selection ();
		if (selection != null) {
			TreeModel tree_model;
			TreeIter? iter;
			bool has_selected_download = selection.get_selected (out tree_model, out iter);
			if (has_selected_download) {
				DownloadListStore download_list_store = (DownloadListStore) tree_model;
				return download_list_store.get_download(iter);
			}
		}
		return null;
	}

	[CCode (instance_pos = -1)]
	public void on_remove_activate (Gtk.Window window) {
		remove_selected_download();
	}

	[CCode (instance_pos = -1)]
	public void on_move_up_to_top_activate (Gtk.Window window) {
		var download = get_selected_download ();
		if (download != null) {
			general_hub.force_download (download);
		}	
	}

	[CCode (instance_pos = -1)]
	public void on_move_up_activate (Gtk.Window window) {
		var download = get_selected_download ();
		if (download != null) {
			general_hub.move_download_up (download);
		}
	}
	
	[CCode (instance_pos = -1)]
	public void on_move_down_activate (Gtk.Window window) {
		var download = get_selected_download ();
		if (download != null) {
			general_hub.move_download_down (download);
		}
	}
	
	[CCode (instance_pos = -1)]
	public void on_move_down_to_bottom_activate (Gtk.Window window) {
		var download = get_selected_download ();
		if (download != null) {
			general_hub.move_download_down_to_bottom (download);
		}
	}
	
	[CCode (instance_pos = -1)]
	public void on_show_properties_dialog_activate (Gtk.Window window) {
		show_properties_of_selected_download();
	}
	
	[CCode (instance_pos = -1)]
	public void on_pause_toggled (Gtk.Window window) {
		
	}
	
	[CCode (instance_pos = -1)]
	public void on_open_folder_activate (Gtk.Window window2) {
		var download = get_selected_download ();
		if (download != null) {
			try {
				Gtk.show_uri (null, "file://" + download.storage_path, Gdk.CURRENT_TIME);
			} catch (Error e) {
				var window = widget.get_toplevel () as Gtk.Window;
				var title = _("Could not open download folder");
				var dialog = new Gtk.MessageDialog (window,
					Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR,
					Gtk.ButtonsType.OK, title);
				dialog.secondary_text = e.message;
				dialog.run ();
				dialog.destroy ();
			}
			
		}	
	}
	
	[CCode (instance_pos = -1)]
	public bool on_treeview_button_press_event (TreeView treeview, Gdk.EventButton event) {
		if (event.type == Gdk.EventType.BUTTON_PRESS && event.button == 3) {
			widgets.context_menu.popup(null, null, null, event.button, event.time);
		}
		return false;
	}
	
	[CCode (instance_pos = -1)]
	public bool on_treeview_key_press_event (TreeView treeview, Gdk.EventKey event) {
		if (event.keyval == 65535) {
			remove_selected_download ();
		}
		return false;
	}
	
	[CCode (instance_pos = -1)]
	public void on_treeview_drag_data_get (TreeView treeview, Gdk.DragContext context,
		SelectionData selection_data, uint info, uint time) {
		var download = get_selected_download ();
		if (download != null) {
			selection_data.set (Gdk.Atom.intern_static_string ("DOWNLOAD"), 8, download.id.data);
		}
	}
	
	[CCode (instance_pos = -1)]
	public void on_treeview_drag_data_received (TreeView treeview, Gdk.DragContext context, 
		int x, int y, SelectionData selection_data, uint info, uint time)  {
		TreePath path;
		TreeViewDropPosition drop_position;
		treeview.get_dest_row_at_pos(x, y, out path, out drop_position);
		if (selection_data != null) {
			switch (info) {
				case DnDTargets.DOWNLOAD:
					/* handle_download_move (selection_data.get_text (), path,
						drop_position); */
					break;
				case DnDTargets.URL:
					/* for a_file in selection.data.replace("file://", "").split():
						if a_file.lower().endswith(".nzb"):
							self.general_hub.add_file(urllib.unquote(a_file).strip()) */
					break;
				default:
					break;
			}
		}
	}
	
	[CCode (instance_pos = -1)]
	public void on_treeview_row_activated (TreeView treeview, TreePath path,
		TreeViewColumn column)  {
		show_properties_of_selected_download();
	}
	
	public void handle_download_move (string download_id, TreePath path,
		TreeViewDropPosition drop_position) {
		// TODO: Is this the right place for this piece of code?
		var download_list_store = general_hub.download_list_store;
		var download = download_list_store.get_download_by_id (download_id);
		var filter_movable = download_list_store.get_filter_movable ();
		var not_movable_count = 
			download_list_store.get_filter_processing ().iter_n_children (null) +
			download_list_store.get_filter_complete ().iter_n_children (null);
		var source_index = 0;
		var target_index = 0;
		
		filter_movable.foreach ((tree_model, path, iter) => {
			Value movable_value;
			filter_movable.get_value (iter, DownloadListStore.COLUMN, out movable_value);
			Download movable_download = (Download) movable_value;
			if (movable_download == download) {
				var source_path = filter_movable.get_path (iter);
				source_index = source_path.get_indices ()[0];
				return false;
			}
			return true;
		});
		
		target_index = path.get_indices ()[0] - not_movable_count;
		var is_drop_before = drop_position == TreeViewDropPosition.BEFORE;
		var is_drop_after = drop_position == TreeViewDropPosition.AFTER;
		if (target_index - source_index == 1 && is_drop_before) {
			target_index--;
		} else if (source_index - target_index == 1 && is_drop_after) {
			target_index++;
		} else if (source_index < target_index && is_drop_before) {
			target_index--;
		} else if (source_index > target_index && is_drop_after) {
			target_index++;
		}
		
		if (target_index < 0) {
			target_index = 0;
		}
		
		general_hub.move_download (download, target_index);
	}

}

public class Lottanzb.DownloadListColumn : Gtk.TreeViewColumn {

	public DownloadListColumn () {
		title = _("Download");
		resizable = true;
		sizing = Gtk.TreeViewColumnSizing.FIXED;
		var renderer = new DownloadCellRenderer ();
		pack_start (renderer, false);
		add_attribute (renderer, "download", DownloadListStore.COLUMN);
	}

}

public enum Lottanzb.GuiPadding {

	SMALL = 3,
	NORMAL = 6,
	LARGE = 12

}

public class Lottanzb.DownloadCellRenderer : Gtk.CellRenderer {

	// The download statuses that will represented by a higher row in the
	// download list, having a second line with additional status information.
	public static int EXPANDED_STATUS_GROUP =
		DownloadStatusGroup.PROCESSING |
		DownloadStatus.FAILED |
		DownloadStatus.DOWNLOADING |
		DownloadStatus.GRABBING |
		DownloadStatus.DOWNLOADING_RECOVERY_DATA |
		DownloadStatus.PAUSED;

	private Gtk.CellRendererText name_renderer;
	private Gtk.CellRendererText size_renderer;
	private Gtk.CellRendererText status_renderer;
	private Gtk.CellRendererProgress progress_renderer;

	public Download? download { get; set; }
	public uint progress_bar_height { get; set; default = 12; }

	public DownloadCellRenderer () {
		name_renderer = new Gtk.CellRendererText ();
		name_renderer.weight = Pango.Weight.BOLD;
		name_renderer.ellipsize = Pango.EllipsizeMode.MIDDLE;

		size_renderer = new Gtk.CellRendererText ();
		size_renderer.scale = 0.9;
		size_renderer.yalign = 1.0f;
		size_renderer.xalign = 1.0f;
		status_renderer = new Gtk.CellRendererText ();
		status_renderer.scale = 0.9;
		progress_renderer = new Gtk.CellRendererProgress ();
		progress_renderer.text = "";

		xpad = GuiPadding.SMALL;
		ypad = GuiPadding.SMALL;
	}

	public override void get_size (Gtk.Widget widget, Gdk.Rectangle? cell_area,
								   out int x_offset, out int y_offset,
								   out int width, out int height) {
		Gtk.Requisition name_req;
		Gtk.Requisition size_req;

		name_renderer.text = get_name_string (); 
		name_renderer.get_preferred_size (widget, null, out name_req);
		size_renderer.text = get_size_string ();
		size_renderer.get_preferred_size (widget, null, out size_req);

		width = (int) (2 * xpad + name_req.width
				+ GuiPadding.NORMAL + size_req.width);
		height = (int) (2 * ypad + name_req.height);

		if (has_progress_bar) {
			height += (int) (GuiPadding.SMALL + progress_bar_height);
		}

		if (has_status) {
			Gtk.Requisition status_req;
			status_renderer.text = get_status_string ();
			status_renderer.get_preferred_size (widget, null, out status_req);
			height += (int) (status_req.height);
		}

		if (cell_area == null) {
			x_offset = 0;
			y_offset = 0;
		} else {
			x_offset = cell_area.x;
			y_offset = cell_area.height - (int) ((ypad * 2 + height) / 2.0);
		}
	}

	public override void render (Cairo.Context ctx, Gtk.Widget widget,
								 Gdk.Rectangle background_area,
								 Gdk.Rectangle cell_area,
								 Gtk.CellRendererState flags) {
		if (download == null) {
			return;
		}

		Gtk.Requisition size = { 0, 0 };
		Gdk.Rectangle fill_area = { 0, 0 };
		Gdk.Rectangle name_area = { 0, 0 };
		Gdk.Rectangle size_area = { 0, 0 };
		Gdk.Rectangle bar_area = { 0, 0 };
		Gdk.Rectangle status_area = { 0, 0 };

		name_renderer.text = get_name_string ();
		name_renderer.get_preferred_size (widget, null, out size);
		name_area.width = size.width;
		name_area.height = size.height;

		size_renderer.text = get_size_string ();
		size_renderer.get_preferred_size (widget, null, out size);
		size_area.width = size.width;
		size_area.height = size.height;

		if (has_status) { 
			status_renderer.text = get_status_string ();
			status_renderer.get_preferred_size (widget, null, out size);
			status_area.width = size.width;
			status_area.height = size.height;
		}

		fill_area = background_area;
		fill_area.x += (int) xpad;
		fill_area.y += (int) ypad;
		fill_area.width -= (int) xpad * 2;
		fill_area.height -= (int) ypad * 2;

		size_area.x = fill_area.x + fill_area.width - size_area.width;
		size_area.y = fill_area.y;
		size_area.height = name_area.height;

		name_area.x = fill_area.x;
		name_area.y = fill_area.y;
		name_area.width = size_area.x - fill_area.x - GuiPadding.NORMAL;

		bar_area.x = fill_area.x;
		bar_area.y = fill_area.y + name_area.height + GuiPadding.SMALL;
		bar_area.width = fill_area.width;
		bar_area.height = (int) progress_bar_height;

		if (has_status) {
			status_area.x = fill_area.x;
			if (has_progress_bar) {
				status_area.y = bar_area.y + bar_area.height;
			} else {
				status_area.y = name_area.y + name_area.height;
			}
			status_area.width = fill_area.width;
		}

		name_renderer.text = get_name_string ();
		name_renderer.render (ctx, widget, background_area, name_area, flags);

		size_renderer.text = get_size_string ();
		size_renderer.render (ctx, widget, background_area, size_area, flags);

		if (has_progress_bar) {
			progress_renderer.value = download.percentage;
			progress_renderer.render (ctx, widget, background_area, bar_area, flags);
		}

		if (has_status) {
			status_renderer.text = get_status_string ();
			status_renderer.render (ctx, widget, background_area, status_area, flags);
		}
	}

	private string get_name_string () {
		return html_escape (download.name);
	}

	private string get_size_string () {
		if (download.size.is_known && download.size > 0) {
			return download.size.to_string ();
		}
		return "";
	}

	private string get_status_string () {
		switch (download.status) {
			case DownloadStatus.DOWNLOADING_RECOVERY_DATA:
				var recovery_block_count = download.recovery_block_count;
				return ngettext(
					@"Downloading $(recovery_block_count) recovery block...",
					@"Downloading $(recovery_block_count) recovery blocks...",
					recovery_block_count);
			case DownloadStatus.VERIFYING:
				return _(@"Verifying... ($(download.verification_percentage))");
			case DownloadStatus.REPAIRING:
				return _(@"Repairing... ($(download.repair_percentage))");
			case DownloadStatus.EXTRACTING:
				return _(@"Extracting... ($(download.unpack_percentage))");
			case DownloadStatus.JOINING:
				return _("Joining...");
			case DownloadStatus.MOVING:
				return _("Moving to download folder...");
			case DownloadStatus.SCRIPT:
				return _("Executing user script...");
			case DownloadStatus.FAILED:
				var error_message = _("Unknown error");
				// TODO:
				/* if (download.error_message != null) {
					error_message = html_escape (download.error_message);
				} */
				// Only use red color when the download is not selected.
				// Otherwise, depending on the selection color,
				// the message may be hard to read.
				// TODO: 
				// var is_download_selected = is_iter_selected (iter);
				var is_download_selected = false;
				if (!is_download_selected) {
					error_message = @"<span foreground='red'>$(error_message)</span>";
				}
				return error_message;
			case DownloadStatus.DOWNLOADING:
				if (download.time_left.is_known) {
					return _(@"Downloading - $(download.time_left) left");
				} else {
					return _("Downloading - Remaining time unknown");
				}
			case DownloadStatus.GRABBING:
				return _("Downloading NZB file...");
			case DownloadStatus.PAUSED:
				return _("Paused");
			default:
				break;
		}
		return "";
	}

	private bool has_progress_bar {
		get {
			return download.status.is_in_group (DownloadStatusGroup.INCOMPLETE);
		}
	}

	private bool has_status {
		get {
			return download.status.is_in_group (EXPANDED_STATUS_GROUP);
		}
	}

	private string html_escape (string unescaped) {
		return unescaped
			.replace ("\"", "&quot;")
			.replace ("<", "&lt;")
			.replace (">", "&gt;");
	}

	// TODO:
	/* private bool is_iter_selected (Gtk.TreeIter iter) {
		var tree_view = (Gtk.TreeView) get_tree_view ();
		var selection = tree_view.get_selection ();
		if (selection == null) {
			return false;
		}
		TreeModel tree_model;
		TreeIter? selected_iter;
		bool has_selection = selection.get_selected (out tree_model, out selected_iter);
		if (has_selection) {
			Gtk.TreePath selected_path = tree_model.get_path (selected_iter);
			Gtk.TreePath path = tree_model.get_path (iter);
			return selected_path.compare (path) == 0;
		}
		return false;
	} */

}
