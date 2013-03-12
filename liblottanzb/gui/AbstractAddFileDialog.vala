/* Auto-generated by gen-vala-gtk-widget-bindings.xslt */

public abstract class Lottanzb.AbstractAddFileDialog : Object {

	public class WindowWidgets : Object {

		public Gtk.FileFilter file_filter { get; protected set; }
		public Gtk.FileChooserDialog add_file_dialog { get; protected set; }
		public Gtk.Box vbox { get; protected set; }
		public Gtk.ButtonBox action_area { get; protected set; }
		public Gtk.Button cancel { get; protected set; }
		public Gtk.Button add { get; protected set; }
		public Gtk.Button help { get; protected set; }

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
	
	private static const string ui_file_name = "add_file_dialog.ui";

}