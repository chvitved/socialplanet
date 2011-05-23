
-module(search_resource).
-export([init/1, 
		malformed_request/2,
		allowed_methods/2,
		to_json/2
		]
	).

-include_lib("webmachine/include/webmachine.hrl").

init([]) -> {ok, undefined}.

malformed_request(ReqData, Context) ->
	Query_string = wrq:get_qs_value("q",ReqData),
	case Query_string of
		undefined -> {true, ReqData, Context};
		_ -> Length = string:len(Query_string),
			 {Length =:= 0, ReqData, Context}
	end.
	
allowed_methods(ReqData, Context) ->
	{['GET'], ReqData, Context}.

content_types_provided(RD, Ctx) ->
    {[{"application/json", to_json}], RD, Ctx}.

to_json(ReqData, State) ->
	Char = [random:uniform(25) + 65],
	NewState = [Char | State],
	{"{\"result\":\"" ++ NewState ++ "\"}", ReqData, NewState}.