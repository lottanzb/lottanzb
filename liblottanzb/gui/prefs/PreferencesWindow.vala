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

public class Lottanzb.PreferencesWindow : AbstractPreferencesWindow {

	private BetterSettings lottanzb_settings;
	private SabnzbdSettings sabnzbd_settings;
	private GeneralPreferencesTab general_tab;

	public PreferencesWindow (Backend backend, BetterSettings lottanzb_settings, SabnzbdSettings sabnzbd_settings) {
		base ();
		this.lottanzb_settings = lottanzb_settings;
		this.sabnzbd_settings = sabnzbd_settings;
		this.general_tab = new GeneralPreferencesTab (
			backend, lottanzb_settings, sabnzbd_settings);
		add_tab (general_tab);
	}

	public Gtk.Dialog dialog { get { return widgets.prefs_window; } }

	private void add_tab (PreferencesTab tab) {
		var event_box = new Gtk.EventBox ();
		var label = new Gtk.Label (tab.label);
		var count = widgets.notebook.get_n_pages ();
		widgets.notebook.insert_page (event_box, label, count);
		event_box.add (tab.widget);
		event_box.show ();
	}

	[CCode (instance_pos = -1)]
	public void on_response (Gtk.Dialog dialog, Gtk.ResponseType response) {
		if (response == Gtk.ResponseType.CLOSE) {
			dialog.hide ();
		}
	}

}
