-module(search_place).

-export([search/3]).

-include("records.hrl").

search(Search_string, Client_message_coordinator_pid, Msg_id) ->
	search_process:search(Search_string),
	recieve_search_results(Client_message_coordinator_pid, Msg_id).

recieve_search_results(Client_message_coordinator_pid, Msg_id) ->
	receive
		{ok, Results} -> 
 			Search_results_json = [record_to_json:to_json(Search_result) ||Search_result <- Results],
			Client_message_coordinator_pid ! {data, Msg_id, Search_results_json},
			recieve_search_results(Client_message_coordinator_pid, Msg_id);
		done -> void %Client_message_coordinator_pid ! {done, Msg_id}
	end.
