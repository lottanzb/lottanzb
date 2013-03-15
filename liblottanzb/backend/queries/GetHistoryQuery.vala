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

public interface Lottanzb.GetHistoryQuery : Query<GetHistoryQueryResponse> {

}

public class Lottanzb.GetHistoryQueryImpl : QueryImpl<GetHistoryQueryResponse>, GetHistoryQuery {

	public GetHistoryQueryImpl () {
		base ("history");
	}

	public override GetHistoryQueryResponse get_response_from_json_object(Json.Object json_object) {
		var object = json_object.get_object_member("history");
		GetHistoryQueryResponse response = new GetHistoryQueryResponseImpl (object);
		return response;
	}

}

public interface Lottanzb.GetHistoryQueryResponse : Object {

	public abstract Gee.List<Download> downloads { get; }
	public abstract DataSize history_total_size { get; }
	public abstract DataSize history_month_size { get; }
	public abstract DataSize history_week_size { get; }

}

public class Lottanzb.GetHistoryQueryResponseImpl : GetHistoryQueryResponse, Object {

	private Json.Object _object;
	private Gee.List<Download>? _downloads;

	public GetHistoryQueryResponseImpl (Json.Object object) {
		_object = object;
	}

	public Gee.List<Download> downloads {
		get {
			if (_downloads == null) {
				_downloads = new Gee.ArrayList<Download>();
				var slots = _object.get_array_member("slots");
				for (int index = 0; index < slots.get_length(); index++) {
					var slot = slots.get_object_element (index);
					var download = new DynamicDownload (slot, false);
					_downloads.add(download);
				}
			}
			return _downloads;
		}
	}

	public DataSize history_total_size {
		get {
			if (_object.has_member ("total_size")) {
				var size = _object.get_string_member ("total_size");
				return DataSize.parse (size);
			}
			return DataSize.UNKNOWN;
		}
	}

	public DataSize history_month_size {
		get {
			if (_object.has_member ("month_size")) {
				var size = _object.get_string_member ("month_size");
				return DataSize.parse (size);
			}
			return DataSize.UNKNOWN;
		}
	}

	public DataSize history_week_size {
		get {
			if (_object.has_member ("week_size")) {
				var size = _object.get_string_member ("week_size");
				return DataSize.parse (size);
			}
			return DataSize.UNKNOWN;
		}
	}

}
