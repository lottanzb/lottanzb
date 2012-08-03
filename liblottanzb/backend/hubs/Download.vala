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

[Flags]
public enum Lottanzb.DownloadStatus {

	GRABBING,
	QUEUED,
	DOWNLOADING,
	PAUSED,
	QUICKCHECK,
	DOWNLOADING_RECOVERY_DATA,
	VERIFYING,
	REPAIRING,
	EXTRACTING,
	JOINING,
	MOVING,
	SCRIPT,
	FAILED,
	SUCCEEDED;

	public string to_string () {
		switch (this) {
			case GRABBING:
				return _("Downloading NZB file");
			case QUEUED:
				return _("Queued");
			case DOWNLOADING:
				return _("Downloading");
			case PAUSED:
				return _("Paused");
			case QUICKCHECK:
				return _("Quick check");
			case DOWNLOADING_RECOVERY_DATA:
				return _("Downloading recovery data");
			case VERIFYING:
				return _("Verifying");
			case REPAIRING:
				return _("Repairing");
			case EXTRACTING:
				return _("Extracting");
			case JOINING:
				return _("Joining");
			case MOVING:
				return _("Moving to download folder");
			case SCRIPT:
				return _("Executing script");
			case FAILED:
				return _("Failed");
			case SUCCEEDED:
				return _("Completed");
			default:
				assert_not_reached();
		}
	}

	public bool is_in_group (int status_group) {
		return (status_group & this) > 0;
	}

	public static DownloadStatus[] all () {
		return {
			GRABBING,
			QUEUED,
			DOWNLOADING,
			PAUSED,
			QUICKCHECK,
			DOWNLOADING_RECOVERY_DATA,
			VERIFYING,
			REPAIRING,
			EXTRACTING,
			JOINING,
			MOVING,
			SCRIPT,
			FAILED,
			SUCCEEDED
		};
	}

}

public enum Lottanzb.DownloadStatusGroup {

	NOT_FULLY_LOADED =
		DownloadStatus.GRABBING |
		DownloadStatus.QUEUED |
		DownloadStatus.DOWNLOADING |
		DownloadStatus.PAUSED |
		DownloadStatus.DOWNLOADING_RECOVERY_DATA,

	PROCESSING =
		DownloadStatus.QUICKCHECK |
		DownloadStatus.VERIFYING |
		DownloadStatus.REPAIRING |
		DownloadStatus.EXTRACTING |
		DownloadStatus.JOINING |
		DownloadStatus.MOVING |
		DownloadStatus.SCRIPT,

	MOVABLE =
		DownloadStatus.QUEUED |
		DownloadStatus.DOWNLOADING |
		DownloadStatus.PAUSED,

	COMPLETE =
		DownloadStatus.SUCCEEDED |
		DownloadStatus.FAILED,

	INCOMPLETE = NOT_FULLY_LOADED | PROCESSING,

	FULLY_LOADED = PROCESSING | COMPLETE,

	ANY_STATUS = NOT_FULLY_LOADED | FULLY_LOADED;

}

public enum Lottanzb.DownloadPriority {

	FORCE = 2,
	HIGH = 1,
	NORMAL = 0,
	LOW = -1;

	public string to_string () {
		switch (this) {
			case FORCE:
				return _("Force");
			case HIGH:
				return _("High");
			case NORMAL:
				return _("Normal");
			case LOW:
				return _("Low");
			default:
				assert_not_reached();
		}
	}

	public int to_index () {
		var priorities = all ();
		for (var index = 0; index < priorities.length; index++) {
			if (priorities[index] == this) {
				return index;
			}
		}
		assert_not_reached ();
	}

	public static DownloadPriority[] all () {
		return {
			FORCE,
			HIGH,
			NORMAL,
			LOW
		};
	}

	public static DownloadPriority from_index (int index) {
		var priority = all ()[index];
		return priority;
	}

}

public enum Lottanzb.DownloadPostProcessing {

	NOTHING,
	REPAIR,
	UNPACK,
	DELETE;

	public static DownloadPostProcessing[] all () {
		return {
			NOTHING,
			REPAIR,
			UNPACK,
			DELETE
		};
	}

}

public interface Lottanzb.Download : Object {

	public abstract string id { get; internal set; }
	public abstract DownloadStatus status { get; internal set; }
	public abstract DownloadPriority priority { get; internal set; }
	public abstract string file_name { get; internal set; }
	public abstract string name { get; set; }
	public abstract TimeDelta? average_age { get; internal set; }
	public abstract TimeDelta? time_left { get; internal set; }
	public abstract DataSize? size { get; internal set; }
	public abstract DataSize? size_left { get; internal set; }
	public abstract DateTime? eta { get; internal set; }
	public abstract int percentage { get; internal set; }
	public abstract string script { get; internal set; }
	public abstract string category { get; internal set; }
	public abstract DownloadPostProcessing post_processing { get; internal set; }
	public abstract int message_id { get; internal set; }
	public abstract TimeDelta? post_processing_time { get; internal set; }
	public abstract TimeDelta? download_time { get; internal set; }
	public abstract DateTime? completed { get; internal set; }
	public abstract string? storage_path { get; internal set; }
	public abstract string error_message { get; internal set; }
	public abstract int verification_percentage { get; internal set; }
	public abstract int repair_percentage { get; internal set; }
	public abstract int unpack_percentage { get; internal set; }
	public abstract int recovery_block_count { get; internal set; }

	internal abstract void update (Download download);

	public DataSize? size_downloaded {
		get {
			if (size != null && size_left != null) {
				return DataSize (size.bytes - size_left.bytes);
			}
			return null;
		}
	}

}

public class Lottanzb.DownloadImpl : Object, Download {

	private string _id;
	private DownloadStatus _status = DownloadStatus.QUEUED;
	private DownloadPriority _priority = DownloadPriority.NORMAL;
	private string _file_name;
	private string _name;
	private TimeDelta? _average_age;
	private TimeDelta? _time_left;
	private DataSize? _size;
	private DataSize? _size_left;
	private DateTime? _eta;
	private int _percentage;
	private string _script;
	private string _category;
	private DownloadPostProcessing _post_processing = DownloadPostProcessing.DELETE;
	private int _message_id;
	private TimeDelta? _post_processing_time;
	private TimeDelta? _download_time;
	private DateTime? _completed;
	private string? _storage_path;
	private string _error_message;
	private int _verification_percentage;
	private int _repair_percentage;
	private int _unpack_percentage;
	private int _recovery_block_count;

	public string id {
		get { return _id; }
		internal set { _id = value; }
	}
	public DownloadStatus status {
		get { return _status; }
		internal set { _status = value; }
	}
	public DownloadPriority priority {
		get { return _priority; }
		internal set { _priority = value; }
	}
	public string file_name {
		get { return _file_name; }
		internal set { _file_name = value; }
	}
	public string name {
		get { return _name; }
		set { _name = value; }
	}
	public TimeDelta? average_age {
		get { return _average_age; }
		internal set { _average_age = value; }
	}
	public TimeDelta? time_left {
		get { return _time_left; }
		internal set { _time_left = value; }
	}
	public DataSize? size {
		get { return _size; }
		internal set { _size = value; }
	}
	public DataSize? size_left {
		get { return _size_left; }
		internal set { _size_left = value; }
	}
	public DateTime? eta {
		get { return _eta; }
		internal set { _eta = value; }
	}
	public int percentage {
		get { return _percentage; }
		internal set {
			assert (0 <= value);
			assert (value <= 100);
			_percentage = value;
		}
	}
	public string script {
		get { return _script; }
		internal set { _script = value; }
	}
	public string category {
		get { return _category; }
		internal set { _category = value; }
	}
	public DownloadPostProcessing post_processing {
		get { return _post_processing; }
		internal set { _post_processing = value; }
	}
	public int message_id {
		get { return _message_id; }
		internal set { _message_id = value; }
	}
	public TimeDelta? post_processing_time {
		get { return _post_processing_time; }
		internal set { _post_processing_time = value; }
	}
	public TimeDelta? download_time {
		get { return _download_time; }
		internal set { _download_time = value; }
	}
	public DateTime? completed {
		get { return _completed; }
		internal set { _completed = value; }
	}
	public string? storage_path {
		get { return _storage_path; }
		internal set { _storage_path = value; }
	}
	public string error_message {
		get { return _error_message; }
		internal set { _error_message = value; }
	}
	public int verification_percentage {
		get { return _verification_percentage; }
		internal set {
			assert (0 <= value);
			assert (value <= 100);
			_verification_percentage = value;
		}
	}
	public int repair_percentage {
		get { return _repair_percentage; }
		internal set {
			assert (0 <= value);
			assert (value <= 100);
			_repair_percentage = value;
		}
	}
	public int unpack_percentage {
		get { return _unpack_percentage; }
		internal set {
		   	assert (0 <= value);
			assert (value <= 100);
			_unpack_percentage = value;
		}
	}
	public int recovery_block_count {
		get { return _recovery_block_count; }
		internal set {
			assert (0 <= value);
			_recovery_block_count = value;
		}
	}

	public void update (Download download) {
		id = download.id;
		status = download.status;
		priority = download.priority;
		file_name = download.file_name;
		name = download.name;
		average_age = download.average_age;
		time_left = download.time_left;
		size = download.size;
		size_left = download.size_left;
		eta = download.eta;
		percentage = download.percentage;
		script = download.script;
		category = download.category;
		post_processing = download.post_processing;
		message_id = download.message_id;
		post_processing_time = download.post_processing_time;
		download_time = download.download_time;
		completed = download.completed;
		storage_path = download.storage_path;
		error_message = download.error_message;
		verification_percentage = download.verification_percentage;
		repair_percentage = download.repair_percentage;
		unpack_percentage = download.unpack_percentage;
		recovery_block_count = download.recovery_block_count;
	}

}
