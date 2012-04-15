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


public errordomain QueryError {
    INVALID_RESPONSE
}

public interface Lottanzb.Query<R> : Object {

	// TODO: Do not use GObject property because of problems that arise when
	// an enum is chosen as R.
	// See https://bugzilla.gnome.org/show_bug.cgi?id=672099.
	public abstract R get_response();

	public abstract bool has_completed { get; set; }
	public abstract bool has_succeeded { get; set; }
	
}
