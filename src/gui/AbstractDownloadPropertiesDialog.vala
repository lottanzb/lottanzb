/* Auto-generated by gen-vala-gtk-widget-bindings.xslt */

public abstract class Lottanzb.AbstractDownloadPropertiesDialog : Object {

	protected class WindowWidgets : Object {

		public Gtk.Action open_download_folder { get; set; }
		public Gtk.Dialog properties_dialog { get; set; }
		public Gtk.Box dialog_vbox1 { get; set; }
		public Gtk.VBox vbox4 { get; set; }
		public Gtk.Grid settings_grid { get; set; }
		public Gtk.Label name_label { get; set; }
		public Gtk.Entry name { get; set; }
		public Gtk.Label priority_label { get; set; }
		public Gtk.ComboBox priority { get; set; }
		public Gtk.CellRendererText cellrenderertext2 { get; set; }
		public Gtk.Grid activity_grid { get; set; }
		public Gtk.ButtonBox dialog_action_area1 { get; set; }
		public Gtk.VBox vbox1 { get; set; }
		public Gtk.Button open_button { get; set; }
		public Gtk.Button button2 { get; set; }
		public Gtk.SizeGroup label_size_group { get; set; }
		public Gtk.ListStore priority_store { get; set; }
		public Gtk.SizeGroup sizegroup { get; set; }

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
	
	private static const string ui_file_name = "download_properties_dialog.ui";

}
