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

public interface Lottanzb.QueryNotifier<T> : Object {

	public signal void query_started (T query);
	
	public signal void query_completed (T query);

}

public class Lottanzb.FilteringQueryNotifier<T> : Object, QueryNotifier<T> {

	private Type requested_query_type;

	public FilteringQueryNotifier (QueryNotifier query_notifier) {
		requested_query_type = typeof (T);
		query_notifier.query_started.connect (on_query_started);
		query_notifier.query_completed.connect (on_query_completed);
	}
	
	private void on_query_started (QueryNotifier query_notifier, T query) {
		Type query_type = Type.from_instance (query);
		if (query_type.is_a (requested_query_type)) {
			query_started (query);
		}
	}
	
	private void on_query_completed (QueryNotifier query_notifier, T query) {
		Type query_type = Type.from_instance (query);
		if (query_type.is_a (requested_query_type)) {
			query_completed (query);
		}
	}

}
