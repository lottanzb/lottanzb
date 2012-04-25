/* Auto-generated by gen-vala-gtk-widget-bindings.xslt */

public abstract class Lottanzb.AbstractServerEditorPane : Object {

	protected class WindowWidgets : Object {

		public Gtk.Adjustment connection_adjustment { get; set; }
		public Gtk.Adjustment port_adjustment { get; set; }
		public Gtk.Window window { get; set; }
		public Gtk.Box server_editor_pane { get; set; }
		public Gtk.Box box1 { get; set; }
		public Gtk.Label header_label { get; set; }
		public Gtk.Switch enable { get; set; }
		public Gtk.Alignment alignment1 { get; set; }
		public Gtk.Table table1 { get; set; }
		public Gtk.Label label2 { get; set; }
		public Gtk.Entry host { get; set; }
		public Gtk.Label label4 { get; set; }
		public Gtk.Entry username { get; set; }
		public Gtk.Label label5 { get; set; }
		public Gtk.Entry password { get; set; }
		public Gtk.Label label8 { get; set; }
		public Gtk.Label ssl_label { get; set; }
		public Gtk.Box box2 { get; set; }
		public Gtk.Switch ssl { get; set; }
		public Gtk.Alignment alignment2 { get; set; }
		public Gtk.Label label1 { get; set; }
		public Gtk.Label connections_label { get; set; }
		public Gtk.Box box3 { get; set; }
		public Gtk.SpinButton port { get; set; }
		public Gtk.Box box4 { get; set; }
		public Gtk.SpinButton connections { get; set; }
		public Gtk.SizeGroup sizegroup1 { get; set; }

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
	
	private static const string ui_file_name = "server_editor_pane.ui";

}
