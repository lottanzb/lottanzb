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

[CCode (cprefix = "", lower_case_cprefix = "", cheader_filename = "data/lottanzb.gresource.h")]
namespace LottanzbResource {

	[CCode (cname = "lottanzb_get_resource")]
	public static GLib.Resource get_resource ();
	
	[CCode (cname = "g_settings_bind_with_mapping")]
	public void bind_with_mapping (GLib.Settings settings, string key,
		void* object, string property, GLib.SettingsBindFlags flags,
		SettingsBindGetMapping get_mapping,
		SettingsBindSetMapping set_mapping,
		void* user_data, GLib.DestroyNotify destroy);

	[CCode (cname = "GSettingsBindGetMapping", has_target = false)]
	public delegate bool SettingsBindGetMapping (GLib.Value value,
		GLib.Variant variant, void* user_data);

	[CCode (cname = "GSettingsBindSetMapping", has_target = false)]
	public delegate GLib.Variant SettingsBindSetMapping (
		GLib.Value value, GLib.VariantType expected_type, void* user_data);

	[CCode (cname = "gtk_list_store_reorder")]
	public void reorder (Gtk.ListStore list_store,
		[CCode (array_length = false)] int[] new_order);
	
	// Prevent C compiler warning
	// 'assignment discards ‘const’ qualifier from pointer target type'
	// by ensuring that the return value is a constant.
	[CCode (cname = "g_bytes_get_data", type = "const guint8*", array_length_type = "gsize")]
	public unowned uint8[] bytes_get_data (GLib.Bytes bytes);

}

