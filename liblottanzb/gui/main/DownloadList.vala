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
		widgets.treeview.append_column (new DownloadPrimaryColumn());
		widgets.treeview.append_column (new DownloadSizeColumn());
		widgets.treeview.append_column (new DownloadProgressColumn());
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

public class Lottanzb.DownloadListColumn : TreeViewColumn {

	// The download statuses that will represented by a higher row in the
	// download list, having a second line with additional status information.
	public static int EXPANDED_STATUS_GROUP =
		DownloadStatusGroup.PROCESSING |
		DownloadStatus.FAILED |
		DownloadStatus.DOWNLOADING |
		DownloadStatus.GRABBING |
		DownloadStatus.DOWNLOADING_RECOVERY_DATA;

	public Download? get_download (TreeModel tree_model, TreeIter iter) {
		Value? model_value;
		tree_model.get_value(iter, DownloadListStore.COLUMN, out model_value);
		Download download = (Download) model_value;
		return download;
	}

}


public class Lottanzb.DownloadPrimaryColumn : DownloadListColumn {

	private CellRendererText _cell_renderer;

	public DownloadPrimaryColumn () {
		base();
		_cell_renderer = new CellRendererText();
		_cell_renderer.ellipsize = EllipsizeMode.MIDDLE;
		pack_start (_cell_renderer, true);
		set_cell_data_func (_cell_renderer, cell_data_func);
		set_title ("");
		set_expand (true);
	}
	
	private void cell_data_func (CellLayout cell_layout, CellRenderer cell,
		TreeModel tree_model, TreeIter iter) {
		DownloadListStore download_list_store = (DownloadListStore) tree_model;
		Download? download = download_list_store.get_download(iter);
		if (download != null) {
			var is_expanded = download.status.is_in_group(EXPANDED_STATUS_GROUP);
			var is_paused = download.status != DownloadStatus.PAUSED;
			var content = @"<b>$(html_escape(download.name))</b>";
			if (is_expanded) {
				var status_string = get_status_string (download, iter);
				content += "\n" + status_string;
			}
			_cell_renderer.markup = content;
			_cell_renderer.sensitive = is_paused;
		}
	}
	
	private string get_status_string (Download download, Gtk.TreeIter iter) {
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
				if (download.error_message != null) {
					error_message = html_escape (download.error_message);
				}
				// Only use red color when the download is not selected.
				// Otherwise, depending on the selection color,
				// the message may be hard to read.
				var is_download_selected = is_iter_selected (iter);
				if (!is_download_selected) {
					error_message = @"<span foreground='red'>$(error_message)</span>";
				}
				return error_message;
			case DownloadStatus.DOWNLOADING:
				if (download.time_left.is_known ()) {
					return _(@"Downloading - $(download.time_left) left");
				} else {
					return _("Downloading - Remaining time unknown");
				}
			case DownloadStatus.GRABBING:
				return _("Downloading NZB file...");
			default:
				break;
		}
		return "";
	}

	private bool is_iter_selected (Gtk.TreeIter iter) {
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
	}
	
	private string html_escape (string unescaped) {
		return unescaped
			.replace ("\"", "&quot;")
			.replace ("<", "&lt;")
			.replace (">", "&gt;");
	}

}


public class Lottanzb.DownloadSizeColumn : DownloadListColumn {

	private CellRendererText _cell_renderer;

	public DownloadSizeColumn () {
		_cell_renderer = new CellRendererText();
		_cell_renderer.xalign = 1.0f;
		pack_start(_cell_renderer, true);
		set_cell_data_func(_cell_renderer, cell_data_func);
	}
	
	private void cell_data_func (CellLayout cell_layout, CellRenderer cell,
		TreeModel tree_model, TreeIter iter) {
		Download? download = get_download(tree_model, iter);
		if (download != null) {
			var is_paused = download.status != DownloadStatus.PAUSED;
			var size_string = "";
			if (download.size.is_known && download.size > 0) {
				size_string = download.size.to_string();
			}
			_cell_renderer.text = size_string;
			_cell_renderer.sensitive = is_paused;
		}
	}

}


public class Lottanzb.DownloadProgressColumn : DownloadListColumn {

	private CellRendererProgress _cell_renderer;

	public DownloadProgressColumn () {
		_cell_renderer = new CellRendererProgress();
		pack_start(_cell_renderer, true);
		set_cell_data_func(_cell_renderer, cell_data_func);
		set_min_width(150);
	}
	
	private void cell_data_func (CellLayout cell_layout, CellRenderer cell,
		TreeModel tree_model, TreeIter iter) {
		Download? download = get_download(tree_model, iter);
		if (download != null) {
			var is_expanded = download.status.is_in_group(EXPANDED_STATUS_GROUP);
			var is_paused = download.status != DownloadStatus.PAUSED;
			_cell_renderer.ypad = (is_expanded) ? 8 : 0;
			_cell_renderer.value = download.percentage;
			_cell_renderer.sensitive = is_paused;
		}
	}

}
