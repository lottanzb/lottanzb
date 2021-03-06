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


public errordomain Lottanzb.QueryError {
	CONNECTION,
	UNKNOWN_HOST,
	CONNECTION_REFUSED,
	HTTP,
	UNSUPPORTED_API_VERSION,
	INVALID_RESPONSE,
	AUTHENTICATION,
	API_KEY,
	USERNAME_PASSWORD,
	CONNECTION_TIMEOUT,
	RESTART_TIMEOUT,
	ARGUMENTS,
	NOT_IMPLEMENTED
}

public interface Lottanzb.Query<R> : Object {

	// Do not use a GObject property because of problems that arise
	// when an enum is chosen as R.
	// See https://bugzilla.gnome.org/show_bug.cgi?id=672099.
	public abstract R get_response();

	public abstract string to_string ();

	public abstract bool has_completed { get; set; }
	public abstract bool has_succeeded { get; set; }

}
