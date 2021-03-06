/* Auto-generated by gen-vala-gtk-widget-bindings.xslt */

public abstract class Lottanzb.AbstractServersDialog : Object {

	public class WindowWidgets : Object {

		public Gtk.Action add_server { get; protected set; }
		public Gtk.Action remove_server { get; protected set; }
		public Gtk.Dialog servers_dialog { get; protected set; }
		public Gtk.Box dialog1_vbox { get; protected set; }
		public Gtk.ButtonBox dialog1_action_area { get; protected set; }
		public Gtk.Button close { get; protected set; }
		public Gtk.Button help { get; protected set; }
		public Gtk.Button apply { get; protected set; }
		public Gtk.Box box1 { get; protected set; }
		public Gtk.Box box2 { get; protected set; }
		public Gtk.ScrolledWindow scrolled_window { get; protected set; }
		public Gtk.TreeView tree_view { get; protected set; }
		public Gtk.TreeSelection tree_selection { get; protected set; }
		public Gtk.Toolbar add_remove_toolbar { get; protected set; }
		public Gtk.ToolButton button_add { get; protected set; }
		public Gtk.ToolButton button_remove { get; protected set; }
		public Gtk.EventBox server_editor_pane_container { get; protected set; }

	}

	protected Gtk.Builder builder;
	public WindowWidgets widgets;

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