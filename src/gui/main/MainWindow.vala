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

public class Lottanzb.MainWindow : AbstractMainWindow {

	public static string SETTINGS_KEY = "main";
	public static string SETTINGS_SIZE_KEY = "size";
	public static string SETTINGS_POSITION_KEY = "position";
	public static string SETTINGS_STATE_KEY = "state";
	public static string SETTINGS_SHOW_INFOBAR = "show-infobar";
	public static string SETTINGS_SHOW_REORDERING_PANE = "show-reordering-pane";
	public static string SETTINGS_SHOW_TOOLBAR = "show-toolbar";
	
	private static string LAUNCHPAD_ITEMS_PATH = "/menu_bar/help/launchpad_items";
	private static string DOWNLOAD_LIST_ITEMS_PATH = "/toolbar/download_list_actions";
	
	public BetterSettings settings { get; construct set; }
	public BetterSettings gui_settings { get; construct set; }
	public BetterSettings window_settings { get; construct set; }
	
	private Backend? _backend;
	private Gdk.WindowState window_state;
	private DownloadList? _download_list;
	private InfoBar? _info_bar;
	private uint ui_manager_merge_id;
	private Binding? _pause_general_hub_action_binding;

	public DownloadList? download_list {
		get {
			return _download_list;
		}
		private set {
			if (_download_list != null) {
				widgets.download_list.remove(_download_list.widget);
				var action_group = _download_list.important_action_group;
				widgets.ui_manager.remove_ui (ui_manager_merge_id);
				ui_manager_merge_id = 0;
				widgets.ui_manager.remove_action_group (action_group);
			}
			_download_list = value;
			if (_download_list != null) {
				widgets.download_list.add(_download_list.widget);
				var action_group = _download_list.important_action_group;
				widgets.ui_manager.insert_action_group (action_group, -1);
				ui_manager_merge_id = widgets.ui_manager.new_merge_id ();
				foreach (var action in action_group.list_actions()) {
					widgets.ui_manager.add_ui (ui_manager_merge_id,
						DOWNLOAD_LIST_ITEMS_PATH, action.name, action.name,
						Gtk.UIManagerItemType.AUTO, false);
				}
				window_settings.bind (SETTINGS_SHOW_REORDERING_PANE,
					_download_list.reordering_pane, "visible", SettingsBindFlags.GET);
			}
		}
	}

	public InfoBar? info_bar {
		get {
			return _info_bar;
		}
		private set {
			if (_info_bar != null) {
				widgets.infobar.remove(_info_bar.widget);
			}
			_info_bar = value;
			if (_info_bar != null) {
				widgets.infobar.add(_info_bar.widget);
			}
		}
	}

	public Backend? backend {
		get { return _backend; }
		set {
			_backend = value;
			if (_backend != null) {
				var general_hub = _backend.general_hub;
				download_list = new DownloadList(general_hub, widgets.main_window);
				info_bar = new InfoBar(_backend);
				widgets.backend_action_group.sensitive = true;
				_pause_general_hub_action_binding = general_hub.bind_property (
					"paused", widgets.paused, "active",
					BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
			} else {
				download_list = null;
				info_bar = null;
				widgets.backend_action_group.sensitive = false;
				_pause_general_hub_action_binding = null;
			}	
		}
	}

	public MainWindow (ConfigProvider config_provider) {
		settings = config_provider.lottanzb_config;
		gui_settings = settings.get_child_for_same_backend_cached ("gui");
		window_settings = gui_settings.get_child_for_same_backend_cached (SETTINGS_KEY);
		window_settings.bind (SETTINGS_SHOW_INFOBAR,
			widgets.show_infobar, "active", SettingsBindFlags.DEFAULT);
		window_settings.bind (SETTINGS_SHOW_REORDERING_PANE,
			widgets.show_reordering_pane, "active", SettingsBindFlags.DEFAULT);
		window_settings.bind (SETTINGS_SHOW_TOOLBAR,
			widgets.show_toolbar, "active", SettingsBindFlags.DEFAULT);
		window_settings.bind (SETTINGS_SHOW_TOOLBAR,
			widgets.toolbar, "visible", SettingsBindFlags.GET);
		window_settings.bind (SETTINGS_SHOW_INFOBAR,
			widgets.infobar, "visible", SettingsBindFlags.GET);

		restore_window_settings ();
		
		LaunchpadIntegration.set_sourcepackagename("lottanzb");
		LaunchpadIntegration.add_ui(widgets.ui_manager, LAUNCHPAD_ITEMS_PATH);

		widgets.backend_action_group.set_sensitive(false);
		widgets.main_window.show ();
	}
	
	public void save_window_settings () {
		window_settings.set_int (SETTINGS_STATE_KEY, window_state);
		if ((window_state & Gdk.WindowState.MAXIMIZED) == 0) {
			var size = new int[2];
			widgets.main_window.get_size (out size[0], out size[1]);
			window_settings.set (SETTINGS_SIZE_KEY, "(ii)", size[0], size[1]);
			var position = new int[2];
			widgets.main_window.get_position (out position[0], out position[1]);
			window_settings.set (SETTINGS_POSITION_KEY, "(ii)", position[0], position[1]);
		}
	}
	
	public void restore_window_settings () {
		var size = new int[2];
		window_settings.get (SETTINGS_SIZE_KEY, "(ii)", out size[0], out size[1]);
		widgets.main_window.resize (size[0], size[1]);
		var position = new int[2];
		window_settings.get (SETTINGS_POSITION_KEY, "(ii)", out position[0], out position[1]);
		widgets.main_window.move (position[0], position[1]);
		
		var window_state = window_settings.get_int (SETTINGS_STATE_KEY);
		if ((window_state & Gdk.WindowState.MAXIMIZED) != 0) {
			widgets.main_window.maximize ();
		} else {
			widgets.main_window.unmaximize ();
		}
		if ((window_state & Gdk.WindowState.STICKY) != 0) {
			widgets.main_window.stick ();
		} else {
			widgets.main_window.unstick ();
		}
	}
	
	[CCode (instance_pos = -1)]
	public void on_add_activate (Gtk.Window window) {
		var dialog = new AddFileDialog (backend.query_processor, gui_settings);
		dialog.run (widgets.main_window);
	}
	
	[CCode (instance_pos = -1)]
	public void on_add_url_activate (Gtk.Window window) {
		var dialog = new AddURLDialog ();
		dialog.run (widgets.main_window);
	}
	
	[CCode (instance_pos = -1)]
	public void on_clear_activate (Gtk.Window window) {
		if (backend != null) {
			// backend.general_hub.delete_all_history ();
		}	
	}
	
	[CCode (instance_pos = -1)]
	public void on_manage_servers_activate (Gtk.Window window) {
		if (backend != null) {
			var dialog = new ServersDialog (backend.config_hub);
			dialog.run (widgets.main_window);
		}
	} 
	
	[CCode (instance_pos = -1)]
	public void on_edit_preferences_activate (Gtk.Window window) {
		if (backend != null) {
			var sabnzbd_settings = backend.config_hub.root;
			new PreferencesWindow (backend, settings, sabnzbd_settings);
		}	
	}

	[CCode (instance_pos = -1)]
	public void on_open_download_folder_activate (Gtk.Window window) {
		if (backend != null) {
			try {
				var download_folder = backend.config_hub.download_folder;
				Gtk.show_uri (null, "file://" + download_folder, Gdk.CURRENT_TIME);
			} catch (Error e) {
				var title = _("Could not open download folder");
				var dialog = new Gtk.MessageDialog (widgets.main_window,
					Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR,
					Gtk.ButtonsType.OK, title);
				dialog.secondary_text = e.message;
				dialog.run ();
				dialog.destroy ();
			}
		}
	}

	[CCode (instance_pos = -1)]
	public void on_open_web_interface_activate (Gtk.Window window) {
		var url = backend.query_processor.connection_info.url;	
		try {
			Gtk.show_uri (null, url, Gdk.CURRENT_TIME);
		} catch (Error e) {
			var title = _("Could not open web interface");
			var dialog = new Gtk.MessageDialog (widgets.main_window,
				Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR,
				Gtk.ButtonsType.OK, title);
			dialog.secondary_text = e.message;
			dialog.run ();
			dialog.destroy ();
		}
	}

	[CCode (instance_pos = -1)]
	public void on_quit_activate (Gtk.Window window) {
		Gtk.main_quit();
	}
	
	[CCode (instance_pos = -1)]
	public void on_select_local_session_activate (Gtk.Window window) {
		
	}
	
	[CCode (instance_pos = -1)]
	public void on_select_remote_session_activate (Gtk.Window window) {
		
	}
	
	[CCode (instance_pos = -1)]
	public void on_show_about_dialog_activate (Gtk.Window window) {
		var about_dialog = new AboutDialog();
		about_dialog.run (widgets.main_window);
	}

	[CCode (instance_pos = -1)]
	public void on_show_help_content_activate (Gtk.Window window) {
		
	}
	
	[CCode (instance_pos = -1)]
	public void on_show_message_log_activate (Gtk.Window window) {
		
	}

	[CCode (instance_pos = -1)]
	public void on_destroy (Gtk.Window window) {
		save_window_settings ();
	}
	
	[CCode (instance_pos = -1)]
	public bool on_window_state_event (Gtk.Window window, Gdk.EventWindowState event) {
		window_state = event.new_window_state;
		return false;
	}
	
	[CCode (instance_pos = -1)]
	public bool on_delete_event (Gtk.Window window, Gdk.EventAny event) {
		Gtk.main_quit ();
		return false;
	}

}
