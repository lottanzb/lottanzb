/* Auto-generated by gen-vala-gtk-widget-bindings.xslt */

public abstract class Lottanzb.AbstractServersDialog : Object {

	protected class WindowWidgets : Object {

		public Gtk.Dialog servers_dialog { get; set; }
		public Gtk.Box dialog1_vbox { get; set; }
		public Gtk.ButtonBox dialog1_action_area { get; set; }
		public Gtk.Button close { get; set; }
		public Gtk.Button help { get; set; }
		public Gtk.Box box1 { get; set; }
		public Gtk.Box box2 { get; set; }
		public Gtk.ScrolledWindow scrolled_window { get; set; }
		public Gtk.TreeView tree_view { get; set; }
		public Gtk.TreeSelection tree_selection { get; set; }
		public Gtk.Toolbar add_remove_toolbar { get; set; }
		public Gtk.ToolButton button_add { get; set; }
		public Gtk.ToolButton button_remove { get; set; }

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
	
	private static const string ui_file_name = "servers_dialog.ui";

}
