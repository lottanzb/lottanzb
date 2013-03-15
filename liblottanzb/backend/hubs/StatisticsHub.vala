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

public interface Lottanzb.StatisticsHub : Object {

	public abstract DataSize history_total_size { get; protected set; }
	public abstract DataSize history_month_size { get; protected set; }
	public abstract DataSize history_week_size { get; protected set; }
	public abstract DataSize history_day_size { get; protected set; }
	public abstract DataSize total_download_folder_space { get; protected set; }
	public abstract DataSize total_temp_folder_space { get; protected set; }
	public abstract DataSize free_download_folder_space { get; protected set; }
	public abstract DataSize free_temp_folder_space { get; protected set; }

}

public class Lottanzb.StatisticsHubImpl : Object, StatisticsHub {

	private QueryProcessor query_processor;

	public DataSize history_total_size { get; protected set; }
	public DataSize history_month_size { get; protected set; }
	public DataSize history_week_size { get; protected set; }
	public DataSize history_day_size { get; protected set; }
	public DataSize total_download_folder_space { get; protected set; }
	public DataSize total_temp_folder_space { get; protected set; }
	public DataSize free_download_folder_space { get; protected set; }
	public DataSize free_temp_folder_space { get; protected set; }

	public StatisticsHubImpl (QueryProcessor query_processor) {
		this.query_processor = query_processor;
		this.query_processor.get_query_notifier<GetQueueQuery> ()
			.query_completed.connect ((query_processor, queue_query) => {
			handle_queue_query (queue_query);
		});
		this.query_processor.get_query_notifier<GetHistoryQuery> ()
			.query_completed.connect ((query_processor, history_query) => {
			handle_history_query (history_query);
		});
		history_total_size = DataSize.UNKNOWN;
		history_month_size = DataSize.UNKNOWN;
		history_week_size = DataSize.UNKNOWN;
		history_day_size = DataSize.UNKNOWN;
		total_download_folder_space = DataSize.UNKNOWN;
		total_temp_folder_space = DataSize.UNKNOWN;
		free_download_folder_space = DataSize.UNKNOWN;
		free_temp_folder_space = DataSize.UNKNOWN;
	}

	private void handle_queue_query (GetQueueQuery query) {
		total_download_folder_space = query.get_response ().total_download_folder_space;
		total_temp_folder_space = query.get_response ().total_temp_folder_space;
		free_download_folder_space = query.get_response ().free_download_folder_space;
		free_temp_folder_space = query.get_response ().free_temp_folder_space;
	}

	private void handle_history_query (GetHistoryQuery query) {
		history_total_size = query.get_response ().history_total_size;
		history_month_size = query.get_response ().history_month_size;
		history_week_size = query.get_response ().history_week_size;
		history_day_size = query.get_response ().history_day_size;
	}

}
