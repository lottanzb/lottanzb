/* Auto-generated by gen-vala-gtk-widget-bindings.xslt */

public abstract class Lottanzb.AbstractGeneralPreferencesTab : Object {

	public class WindowWidgets : Object {

		public Gtk.Adjustment speed { get; protected set; }
		public Gtk.Window prefs_tab_general { get; protected set; }
		public Gtk.VBox vbox1 { get; protected set; }
		public Gtk.VBox vbox2 { get; protected set; }
		public Gtk.Label download_label { get; protected set; }
		public Gtk.Alignment alignment2 { get; protected set; }
		public Gtk.Table table2 { get; protected set; }
		public Gtk.HBox hbox2 { get; protected set; }
		public Gtk.FileChooserButton watched_folder_button { get; protected set; }
		public Gtk.Entry watched_folder_entry { get; protected set; }
		public Gtk.CheckButton use_bandwidth_limit { get; protected set; }
		public Gtk.CheckButton watched_folder_checkbutton { get; protected set; }
		public Gtk.HBox hbox1 { get; protected set; }
		public Gtk.SpinButton bandwidth_limit { get; protected set; }
		public Gtk.Label bandwidth_limit_scale { get; protected set; }
		public Gtk.VBox vbox5 { get; protected set; }
		public Gtk.Label download_label1 { get; protected set; }
		public Gtk.Alignment alignment1 { get; protected set; }
		public Gtk.VBox vbox3 { get; protected set; }
		public Gtk.EventBox eventbox1 { get; protected set; }
		public Gtk.ComboBox post_processing { get; protected set; }
		public Gtk.HBox hbox4 { get; protected set; }
		public Gtk.Label download_dir_label { get; protected set; }
		public Gtk.HBox hbox3 { get; protected set; }
		public Gtk.FileChooserButton download_folder_button { get; protected set; }
		public Gtk.Entry download_folder_entry { get; protected set; }
		public Gtk.SizeGroup sizegroup { get; protected set; }

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
	
	private static const string ui_file_name = "prefs_tab_general.ui";

}