/* Auto-generated by gen-vala-gtk-widget-bindings.xslt */

public abstract class Lottanzb.AbstractMainWindow : Object {

	protected class WindowWidgets : Object {

		public Gtk.UIManager ui_manager { get; set; }
		public Gtk.ActionGroup action_group { get; set; }
		public Gtk.Action file { get; set; }
		public Gtk.Action edit { get; set; }
		public Gtk.Action view { get; set; }
		public Gtk.Action help { get; set; }
		public Gtk.Action quit { get; set; }
		public Gtk.ToggleAction show_toolbar { get; set; }
		public Gtk.ToggleAction show_infobar { get; set; }
		public Gtk.ToggleAction show_reordering_pane { get; set; }
		public Gtk.Action show_help_content { get; set; }
		public Gtk.Action show_message_log { get; set; }
		public Gtk.Action show_about_dialog { get; set; }
		public Gtk.ActionGroup backend_action_group { get; set; }
		public Gtk.Action add { get; set; }
		public Gtk.Action add_url { get; set; }
		public Gtk.Action select_local_session { get; set; }
		public Gtk.Action select_remote_session { get; set; }
		public Gtk.Action clear { get; set; }
		public Gtk.Action open_web_interface { get; set; }
		public Gtk.Action open_download_folder { get; set; }
		public Gtk.ToggleAction paused { get; set; }
		public Gtk.Action manage_servers { get; set; }
		public Gtk.Action edit_preferences { get; set; }
		public Gtk.Window main_window { get; set; }
		public Gtk.VBox container { get; set; }
		public Gtk.MenuBar menu_bar { get; set; }
		public Gtk.Toolbar toolbar { get; set; }
		public Gtk.EventBox download_list { get; set; }
		public Gtk.EventBox message { get; set; }
		public Gtk.EventBox infobar { get; set; }

	}

	protected Gtk.Builder builder;
	protected WindowWidgets widgets;

	construct {
		builder = new Gtk.Builder ();
		try {
			builder.add_from_resource ("/org/lottanzb/gui/" + ui_file_name);
		} catch (Error e) {
			error ("could not load UI file: %s", e.message);
			exit (-1);
		}
		widgets = new WindowWidgets ();
		SList<unowned Object> objects = builder.get_objects ();
		foreach (Object object in objects) {
			if (object is Gtk.Buildable) {
				widgets.set ((object as Gtk.Buildable).get_name (), object);
			}
		}
		builder.connect_signals (this);
	}
	
	private static const string ui_file_name = "main_window.ui";

}
