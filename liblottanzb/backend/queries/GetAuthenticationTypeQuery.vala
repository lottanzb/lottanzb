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

public interface Lottanzb.GetAuthenticationTypeQuery : Query<AuthenticationType> {

}

public class Lottanzb.GetAuthenticationTypeQueryImpl : QueryImpl<AuthenticationType>, GetAuthenticationTypeQuery {

	public GetAuthenticationTypeQueryImpl() {
		base("auth");
	}
	
	public override AuthenticationType get_response_from_json_object(
			Json.Object json_object) throws QueryError {
		var authentication_type_string = json_object.get_string_member("auth");
		if (authentication_type_string == "apikey") {
			return AuthenticationType.API_KEY;
		} else if (authentication_type_string == "login") {
			return AuthenticationType.USERNAME_AND_PASSWORD;
		} else if (authentication_type_string == "None") {
			return AuthenticationType.NOTHING;
		}
		throw new QueryError.INVALID_RESPONSE("unknown authentication type");
	}

}
