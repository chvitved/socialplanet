
-module(event_resource).
-export([init/1, 
		content_types_accepted/2,
		post_is_create/2,	
		allowed_methods/2,
		from_json/2
		]
	).

-include_lib("webmachine/include/webmachine.hrl").

init([]) -> %%{ok, undefined}.
	{{trace, "/tmp"}, undefined}.
	
allowed_methods(ReqData, Context) ->
	{['POST'], ReqData, Context}.

content_types_accepted(RD, Ctx) ->
	io:format("handling~n", []),
	{[{"application/json", from_json}], RD, Ctx}.

post_is_create(RD, Ctx) ->
	io:format("post_is_create~n", []),
	false.

%%process_post(RD, Ctx) ->
%%	io:format("handling~n", []),
%%	{true, "{\"value\":\"hello\"}", Ctx}.

from_json(RD, Ctx) ->
    Body = wrq:req_body(RD),
	handle_incomming_messages(Body),
    {true, wrq:append_to_response_body(Body, RD), Ctx}.


handle_incomming_messages(Body) ->
	io:format("handling body ~p~n", [Body]),
	Json = mochijson2:decode(Body),
	Start_id = json_utils:take(Json, [startId]),
	Msgs = json_utils:take(Json, [messages]),
	Id_list = lists:seq(Start_id, Start_id + length(Msgs)),
	Messages_with_ids = lists:zip(Id_list, Msgs),
	[dispatch_message(Id, Msg) || {Id,Msg} <- Messages_with_ids].

dispatch_message(Id, Msg) -> 
	io:format("recived message with id ~p~n~p", [Id, Msg]).