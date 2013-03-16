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

public interface Lottanzb.Backend : Object {
	
	public static string SETTINGS_KEY { get { return "backend"; } }
	
	public abstract QueryProcessor query_processor { get; protected set; }
	public abstract GeneralHub general_hub { get; protected set; }
	public abstract StatisticsHub statistics_hub { get; protected set; }
	public abstract ConfigHub config_hub { get; protected set; }

}

public class Lottanzb.BackendImpl : Object, Backend {
	
	public Session session { get; protected set; }
	public QueryProcessor query_processor { get; protected set; }
	public GeneralHub general_hub { get; protected set; }
	public StatisticsHub statistics_hub { get; protected set; }
	public ConfigHub config_hub { get; protected set; }
	
	public BackendImpl (ConfigProvider config_provider, SessionProvider session_provider) {
		session = session_provider.build_session ();
		query_processor = session.query_processor;
		general_hub = new GeneralHubImpl (query_processor);
		statistics_hub = new StatisticsHubImpl (query_processor);
		config_hub = new ConfigHubImpl (query_processor);

		Timeout.add_seconds (1, () => {
			query_processor.get_queue.begin ();
			query_processor.get_history.begin ();
			return true;
		});
	}

}
