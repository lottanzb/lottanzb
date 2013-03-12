/* Auto-generated by gen-vala-gtk-widget-bindings.xslt */

public abstract class Lottanzb.AbstractPreferencesWindow : Object {

	public class WindowWidgets : Object {

		public Gtk.Dialog prefs_window { get; protected set; }
		public Gtk.Box dialog1_vbox { get; protected set; }
		public Gtk.ButtonBox dialog1_action_area { get; protected set; }
		public Gtk.Button close { get; protected set; }
		public Gtk.Button help { get; protected set; }
		public Gtk.Notebook notebook { get; protected set; }

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
	
	private static const string ui_file_name = "prefs_window.ui";

}