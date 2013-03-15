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

public interface Lottanzb.GetQueueQuery : Query<GetQueueQueryResponse> {

}

public class Lottanzb.GetQueueQueryImpl : QueryImpl<GetQueueQueryResponse>, GetQueueQuery {

	public GetQueueQueryImpl() {
		base("queue");
	}

	public override GetQueueQueryResponse get_response_from_json_object (
			Json.Object json_object) throws QueryError {
		var object = json_object.get_object_member("queue");
		GetQueueQueryResponse response = new GetQueueQueryResponseImpl (object);
		return response;
	}

}

public interface Lottanzb.GetQueueQueryResponse : Object {

	public abstract Gee.List<Download> downloads { get; }
	public abstract bool is_paused { get; }
	public abstract TimeDelta time_left { get; }
	public abstract DataSize size_left { get; }
	public abstract DataSpeed speed { get; }

}

public class Lottanzb.GetQueueQueryResponseImpl : Object, GetQueueQueryResponse {

	private Json.Object _object;
	private Gee.List<Download>? _downloads;

	public GetQueueQueryResponseImpl (Json.Object object) {
		_object = object;
	}

	public Gee.List<Download> downloads {
		get {
			if (_downloads == null) {
				_downloads = new Gee.ArrayList<Download> ();
				var slots = _object.get_array_member("slots");
				for (int index = 0; index < slots.get_length(); index++) {
					var slot = slots.get_object_element (index);
					var download = new DynamicDownload(slot, is_paused);
					_downloads.add(download);
				}
			}
			return _downloads;
		}
	}

	public bool is_paused {
		get {
			return _object.get_boolean_member("paused_all");
		}
	}

	public TimeDelta time_left {
		get {
			if (_object.has_member ("timeleft")) {
				var time_left_string = _object.get_string_member ("timeleft");
				return TimeDelta.parse (time_left_string);
			}
			return TimeDelta.UNKNOWN;
		}
	}

	public DataSize size_left {
		get {
			var megabytes_left = double.parse (_object.get_string_member ("mbleft"));
			return DataSize.with_unit (megabytes_left, DataSizeUnit.MEGABYTES);
		}
	}

	public DataSpeed speed {
		get {
			var speed_string = _object.get_string_member ("speed");
			return DataSpeed.parse (speed_string);
		}	
	}
}

public class Lottanzb.DynamicDownload : Object, Download {

	private static Regex PERCENTAGE_PATTERN = null;
	private static Regex PIECES_PROGRESS_PATTERN = null;
	private static Regex RECOVERY_BLOCKS_PATTERN = null;
	private static Regex URL_PATTERN = null;
	private static Regex HTML_LINK_PATTERN = null;

	static construct {
		try {
			PERCENTAGE_PATTERN = new Regex("(\\d{1,2})%");
			PIECES_PROGRESS_PATTERN = new Regex("(\\d+)/(\\d+)");
			RECOVERY_BLOCKS_PATTERN = new Regex("(\\d+)");
			URL_PATTERN = new Regex("https?\\://[a-zA-Z0-9\\-\\.]+\\.[a-zA-Z]{2,3}(:[a-zA-Z0-9]*)?/?([a-zA-Z0-9\\-\\._\\?\\,\\'/\\\\\\+&amp;%\\$#\\=~])*");
			HTML_LINK_PATTERN = new Regex("<a .*>.*</a>");
		} catch (RegexError e) {
			warning ("%s", e.message);
		}
	}

	private Json.Object _slot;
	private DownloadStatus? _status;
	private DateTime? _eta;
	private string? _script;
	private DateTime? _completed;
	private bool _is_paused;

	public DynamicDownload (Json.Object slot, bool is_paused) {
		_slot = slot;
		_status = null;
		_is_paused = is_paused;
		_eta = null;
		_script = null;
		_completed = null;
	}

	public string id { 
		get {
			if (_slot.has_member("nzo_id")) {
				return _slot.get_string_member("nzo_id");
			}
			return "";
		}
		internal set { assert_not_reached (); }
	}

	public DownloadStatus status { 
		get {
			if (_status == null) {
				_status = DownloadStatus.QUEUED;
				if (_slot.has_member("status")) {
					var status_string = _slot.get_string_member("status");
					_status = get_download_status_from_string(status_string);

					// TODO: Not sure whether downloads in the post-processing
					// queue in general have the status 'Queued' or whether only
					// downloads requiring further transmissions are affected.
					if (_status == DownloadStatus.QUEUED && is_loaded) {
						_status = DownloadStatus.DOWNLOADING_RECOVERY_DATA;
					}

					// Check whether this download represents the download
					// of an NZB file given an URL. Unfortunately,
					// SABnzbd doesn't seem to assign such downloads a separate
					// status, so LottaNZB needs to make an educated guess.
					// Also, the name and file name of the download is replaced
					// with the URL which the NZB file is being downloaded from.
					if (_status == DownloadStatus.DOWNLOADING) {
						if (size.bytes <= 0 && size_left.bytes == 0 && percentage == 0) {
							MatchInfo match_info;
							var match = URL_PATTERN.match(name, 0, out match_info);
							if (match) {
								_status = DownloadStatus.GRABBING;
								// TODO:
								// self.name = match.group()
								// self.file_name = match.group()
							}
						} else if (_is_paused) {
							_status = DownloadStatus.QUEUED;
						}
					}
				}
			}
			return _status;
		}
		internal set { assert_not_reached (); }
	}

	public DownloadPriority priority {
		get {
			if (_slot.has_member("priority")) {
				var priority_string = _slot.get_string_member("priority");
				switch (priority_string) {
					case "Force":
						return DownloadPriority.FORCE;
					case "High":
						return DownloadPriority.HIGH;
					case "Low":
						return DownloadPriority.LOW;
					case "Normal":
						return DownloadPriority.NORMAL;
				}
			}
			return DownloadPriority.NORMAL;
		}
		internal set { assert_not_reached (); }
	}

	public string file_name {
		get {
			if (_slot.has_member("filename")) { // GetQueueQuery
				return _slot.get_string_member("filename");
			} else if (_slot.has_member("nzb_name")) { // GetHistoryQuery
				return _slot.get_string_member("nzb_name");
			}
			return "";
		}
		internal set { assert_not_reached (); }
	}

	public string name {
		get {
			if (_slot.has_member("name")) {
				return _slot.get_string_member("name");
			} else {
				return file_name;
			}
		}
		set { assert_not_reached (); }
	}

	public TimeDelta average_age { 
		get {
			if (_slot.has_member("avg_age")) {
				var average_age_string = _slot.get_string_member("avg_age");
				return TimeDelta.parse(average_age_string);
			}
			return TimeDelta.UNKNOWN;
		}
		internal set { assert_not_reached (); }
	}

	public TimeDelta time_left { 
		get {
			if (_slot.has_member("timeleft") && !is_eta_unknown) {
				var time_left_string = _slot.get_string_member("timeleft");
				return TimeDelta.parse(time_left_string);
			}
			return TimeDelta.UNKNOWN;
		}
		internal set { assert_not_reached (); }
	}

	public DataSize size { 
		get {
			if (_slot.has_member("mb")) {
				var size_string = _slot.get_string_member ("mb");
				var size = double.parse (size_string);
				return DataSize.with_unit (size, DataSizeUnit.MEGABYTES);
			} else if (_slot.has_member ("bytes")) {
				var bytes = _slot.get_int_member ("bytes");
				return (int) bytes;
			}
			return DataSize.UNKNOWN;
		}
		internal set { assert_not_reached (); }
	}

	public DataSize size_left { 
		get {
			if (_slot.has_member("mbleft")) {
				var size_left_string = _slot.get_string_member("mbleft");
				var size_left = double.parse(size_left_string);
				return DataSize.with_unit(size_left, DataSizeUnit.MEGABYTES);
			}
			return DataSize.UNKNOWN;
		}
		internal set { assert_not_reached (); }
	}

	public DateTime? eta { 
		get {
			if (_eta == null && !is_eta_unknown && time_left.is_known()) {
				var now = new DateTime.now_local ();
				_eta = now.add_seconds (time_left.seconds);
			}
			return _eta;
		}
		internal set { assert_not_reached (); }
	}

	public int percentage { 
		get {
			if (_slot.has_member("percentage")) {
				var percentage_string = _slot.get_string_member("percentage");
				return int.parse(percentage_string);
			} else if (status.is_in_group(DownloadStatusGroup.FULLY_LOADED)) {
				return 100;
			}
			return 0;
		}
		internal set { assert_not_reached (); }
	}

	public string script { 
		get {
			if (_script == null) {
				if (_slot.has_member("script")) {
					_script = _slot.get_string_member("script");
					if (_script == "None") {
						_script = "";
					}
				} else {
					_script = "";
				}
			}
			return _script;
		}
		internal set { assert_not_reached (); }
	}

	public string category { 
		get {
			if (_slot.has_member("cat")) { // GetQueueQuery
				return _slot.get_string_member("cat");
			} else if (_slot.has_member ("category")) { // GetHistoryQuery
				return _slot.get_string_member("category");
			}
			return "";
		}
		internal set { assert_not_reached (); }
	}

	public DownloadPostProcessing post_processing { 
		get {
			if (_slot.has_member("unpackopts")) { // GetQueueQuery
				var unpackopts_string = _slot.get_string_member("unpackopts");
				var unpackopts = int.parse(unpackopts_string);
				switch (unpackopts) {
					case 0:
						return DownloadPostProcessing.NOTHING;
					case 1:
						return DownloadPostProcessing.REPAIR;
					case 2:
						return DownloadPostProcessing.UNPACK;
					case 3:
						return DownloadPostProcessing.DELETE;
					default:
						warning ("cannot handle value '%d' for member 'unpackopts'", unpackopts);
						break;
				}
			} else if (_slot.has_member ("pp")) { // GetHistoryQuery
				var pp_string = _slot.get_string_member("pp");
				switch (pp_string) {
					case "":
						return DownloadPostProcessing.NOTHING;
					case "R":
						return DownloadPostProcessing.REPAIR;
					case "U":
						return DownloadPostProcessing.UNPACK;
					case "D":
						return DownloadPostProcessing.DELETE;
					default:
						warning ("cannot handle value '%s' for member 'pp'", pp_string);
						break;
				}
			}
			return DownloadPostProcessing.NOTHING;
		}
		internal set { assert_not_reached (); }
	}

	public int message_id { 
		get {
			if (_slot.has_member("msgid")) {
				var message_id_string = _slot.get_string_member("msgid");
				if (message_id_string.length > 0) {
					return int.parse(message_id_string);
				}
			}
			return 0;
		}
		internal set { assert_not_reached (); }
	}

	public TimeDelta post_processing_time { 
		get {
			if (_slot.has_member("postproc_time")) {
				return (TimeDelta) _slot.get_int_member("postproc_time");
			}
			return TimeDelta.UNKNOWN;
		}
		internal set { assert_not_reached (); }
	}

	public TimeDelta download_time { 
		get {
			if (_slot.has_member("download_time")) {
				return (TimeDelta) _slot.get_int_member ("download_time");
			}
			return TimeDelta.UNKNOWN;
		}
		internal set { assert_not_reached (); }
	}

	public DateTime? completed { 
		get {
			if (_completed == null) {
				if (_slot.has_member("completed")) {
					var completed_timestamp = _slot.get_int_member("completed");
					_completed = new DateTime.from_unix_local (completed_timestamp);
				}
			}
			return _completed;
		}
		internal set { assert_not_reached (); }
	}

	public string? storage_path { 
		get {
			if (_slot.has_member("storage")) {
				return _slot.get_string_member("storage");
			}
			return null;
		}
		internal set { assert_not_reached (); }
	}

	public string error_message { 
		get {
			if (_slot.has_member("fail_message")) {
				return _slot.get_string_member("fail_message");
				// Some error messages contain a HTML link allowing the user
				// to retry the download.
				// TODO:
				// error_message = HTML_LINK_PATTERN.replace (error_message, -1, 0, "");
				// TODO: Strip whitespace and ','
			}
			return "";
		}
		internal set { assert_not_reached (); }
	}

	public int verification_percentage { 
		get {
			if (status == DownloadStatus.VERIFYING) {
				if (_slot.has_member("action_line")) {
					var action_line = _slot.get_string_member("action_line");
					MatchInfo match_info;
					var match = PIECES_PROGRESS_PATTERN.match(action_line, 0, out match_info);
					if (match) {
						var verified_pieces = int.parse(match_info.fetch(1));
						var total_pieces = int.parse(match_info.fetch(2));
						return verified_pieces / total_pieces * 100;
					}
				}
			} else if (DownloadPostProcessing.NOTHING < post_processing &&
				(DownloadStatus.VERIFYING < status && DownloadStatus.FAILED != status)) {
				return 100;
			}
			return 0;
		}
		internal set { assert_not_reached (); }
	}

	public int repair_percentage { 
		get {
			if (status == DownloadStatus.REPAIRING) {
				if (_slot.has_member("action_line")) {
					var action_line = _slot.get_string_member("action_line");
					MatchInfo match_info;
					var match = PERCENTAGE_PATTERN.match(action_line, 0, out match_info);
					if (match) {
						return int.parse(match_info.fetch(1));
					}
				}
			} else if (DownloadPostProcessing.REPAIR <= post_processing &&
				DownloadStatus.REPAIRING < status && DownloadStatus.FAILED != status) {
				return 100;
			}
			return 0;
		}
		internal set { assert_not_reached (); }
	}

	public int unpack_percentage { 
		get {
			if (status == DownloadStatus.EXTRACTING) {
				if (_slot.has_member("action_line")) {
					var action_line = _slot.get_string_member("action_line");
					MatchInfo match_info;
					var match = PIECES_PROGRESS_PATTERN.match(action_line, 0, out match_info);
					if (match) {
						var extracted_pieces = int.parse(match_info.fetch(1));
						var total_pieces = int.parse(match_info.fetch(2));
						return extracted_pieces / total_pieces * 100;
					}
				}
			} else if (DownloadPostProcessing.UNPACK <= post_processing &&
				DownloadStatus.EXTRACTING < status && DownloadStatus.FAILED != status) {
				return 100;
			}
			return 0;
		}
		internal set { assert_not_reached (); }
	}

	public int recovery_block_count { 
		get {
			if (status == DownloadStatus.EXTRACTING) {
				if (_slot.has_member("action_line")) {
					var action_line = _slot.get_string_member("action_line");
					MatchInfo match_info;
					var match = RECOVERY_BLOCKS_PATTERN.match(action_line, 0, out match_info);
					if (match) {
						return int.parse(match_info.fetch(1));
					}
				}
			}
			return 0;
		}
		internal set { assert_not_reached (); }
	}

	internal void update (Download download) {
		assert (false);
	}

	private bool is_loaded {
		get {
			if (_slot.has_member("loaded")) {
				return _slot.get_boolean_member("loaded");
			}
			return false;
		}
	}

	private bool is_eta_unknown {
		get {
			// If a download is active, but the download speed is 0 Bytes/s
			// (e.g. because the internet connection is not available),
			// 'timeleft' will be '0:00:00', which is of course not correct.
			return _is_paused || (_slot.has_member("eta")
					&& _slot.get_string_member("eta") == "unknown");
		}
	}

	private DownloadStatus? get_download_status_from_string (string status_string) {
		switch (status_string) {
			case "Grabbing":
				return DownloadStatus.GRABBING;
			case "Queued":
				return DownloadStatus.QUEUED;
			case "Downloading":
				return DownloadStatus.DOWNLOADING;
			case "Paused":
				return DownloadStatus.PAUSED;
			case "QuickCheck":
				return DownloadStatus.QUICKCHECK;
			case "Fetching":
				return DownloadStatus.DOWNLOADING_RECOVERY_DATA;
			case "Verifying":
				return DownloadStatus.VERIFYING;
			case "Repairing":
				return DownloadStatus.REPAIRING;
			case "Extracting":
				return DownloadStatus.EXTRACTING;
			case "Moving":
				return DownloadStatus.MOVING;
			case "Running":
				return DownloadStatus.SCRIPT;
			case "Failed":
				return DownloadStatus.FAILED;
			case "Completed":
				return DownloadStatus.SUCCEEDED;
		}
		return null;
	}

}
