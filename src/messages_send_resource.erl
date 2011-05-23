-module(messages_send_resource).

-export([init/1, 
		process_post/2,
		allowed_methods/2		
		]
	).

-include_lib("webmachine/include/webmachine.hrl").
-include("records.hrl").

init([]) -> {ok, undefined}.
	%%{{trace, "/tmp"}, undefined}.
	
allowed_methods(ReqData, Context) ->
	{['POST'], ReqData, Context}.

%%content_types_accepted(RD, Ctx) ->
%%	io:format("handling~n", []),
%%	{[{"application/json", from_json}], RD, Ctx}.

process_post(RD, Ctx) ->
	Json = mochijson2:decode(wrq:req_body(RD)),	
	Client_id = json_utils:take(Json, [clientId]),
	Client_message_coordinator_pid = message_coordinator:get_message_coordinator(Client_id),
	Outgoing_messages = getOutGoingMessages(Client_message_coordinator_pid),

	RD1 = wrq:set_resp_header("Content-Type", "application/json; charset=UTF-8", RD), 
	{true, wrq:append_to_response_body(Outgoing_messages, RD1), Ctx}.
    

getOutGoingMessages(Client_message_coordinator_pid) ->
	Outgoing_messages = message_coordinator:get_messages(Client_message_coordinator_pid),
	case Outgoing_messages of
		[] -> "";
		_ ->
			io:format("got the following outgoing messages: ~p~n", [Outgoing_messages]),
			Data_dictionary_by_msg_id = lists:foldl(fun({Msg_id, Data}, Dictionary) -> dict:update(Msg_id, fun(Existing_value) -> [Data|Existing_value] end, [Data], Dictionary) end, dict:new(), Outgoing_messages),
			Messages_list = dict:fold(
	  			fun(Msg_id, Data_list, Result_string) ->
					io:format("called wth ~p~n~p~n~p~n", [Msg_id,Data_list, Result_string]),
					Array_str = lists:foldl(fun(Element, Result) -> Result ++  binary_to_list(Element) ++ ","  end, "", Data_list),
					Array_str1 = string:sub_string(Array_str, 1, length(Array_str) - 1),
	  				Result_string ++ "{\"msgId\":" ++ integer_to_list(Msg_id) ++ ",\n\"messages\": [" ++ Array_str1 ++ "]},"
	  			end,
		  	"", Data_dictionary_by_msg_id),
			Messages_list1 = string:sub_string(Messages_list, 1, length(Messages_list) - 1),
			"{\"messages\": [" ++ Messages_list1 ++ "]}"
	end.
	
	
	
	%%Messages_string = lists:foldl(fun(Element, Result_string) -> Result_string ++  Element ++ ",\n"  end, "", Outgoing_data),
	%%Messages_list = case Messages_string of 
	%%	[] -> "[]";
	%%	_ -> "[" ++ string:sub_string(Messages_string, 1, length(Messages_string) - 2) ++ "]"
	%%end,
	 