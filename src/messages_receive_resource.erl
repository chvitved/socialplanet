-module(messages_receive_resource).

-export([init/1, 
		process_post/2,
		allowed_methods/2		
		]
	).

-include_lib("webmachine/include/webmachine.hrl").
-include("records.hrl").

init([]) -> %%{ok, undefined}.
	{{trace, "/tmp"}, undefined}.
	
allowed_methods(ReqData, Context) ->
	{['POST'], ReqData, Context}.

%%content_types_accepted(RD, Ctx) ->
%%	io:format("handling~n", []),
%%	{[{"application/json", from_json}], RD, Ctx}.

process_post(RD, Ctx) ->
	spawn(fun() -> handle_incomming_messages(wrq:req_body(RD)) end),
	{true, RD, Ctx}.

handle_incomming_messages(Body) ->
	io:format("handling body ~p~n", [Body]),
	Json = mochijson2:decode(Body),
	Client_id = json_utils:take(Json, [clientId]),
	Client_message_coordinator_pid = message_coordinator:get_message_coordinator(Client_id),
	Start_id = json_utils:take(Json, [startMessageId]),
	case json_utils:take(Json, [messages]) of
		Msgs when is_list(Msgs), length(Msgs) > 0 ->
			Message_id_list = lists:seq(Start_id, Start_id + length(Msgs) - 1),
			Messages_with_ids = lists:zip(Message_id_list, Msgs),
			[spawn(fun() -> dispatch_message(Msg, Client_message_coordinator_pid, Message_id) end) || {Message_id,Msg} <- Messages_with_ids];
		_ -> void
	end.		

dispatch_message(Msg, Client_message_coordinator_pid, Message_id) -> 
	io:format("recived message with message_id ~p~n~p~n", [Message_id, Msg]),
	handle_search(Msg, Client_message_coordinator_pid, Message_id).

handle_search(Json_msg, Client_message_coordinator_pid, Msg_id) ->
	Search_string = json_utils:take(Json_msg, [search]), 
	if 
		is_list(Search_string)  orelse is_binary(Search_string) ->
			search_place:search(Search_string, Client_message_coordinator_pid, Msg_id);
		true -> undefined		 
	end.