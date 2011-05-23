-module(comet_resource).

-export([init/1, 
		allowed_methods/2,
		content_types_provided/2,
		to_json/2
		]
	).

-include_lib("webmachine/include/webmachine.hrl").

init([]) -> {ok, undefined}.
	
allowed_methods(ReqData, Context) ->
	{['GET'], ReqData, Context}.

content_types_provided(RD, Ctx) ->
    {[{"application/json", to_json}], RD, Ctx}.

to_json(ReqData, State) ->
	%%{"{\"status\":\"ok\"}", ReqData, State}.
	{{stream, mystream(0)}, ReqData, State}.

mystream(Number) ->
	case Number of
		5 -> {"DONE", done};
		_ ->
			timer:sleep(1000),
			Char = [random:uniform(25) + 65],
			io:format("~p", [Char]),
			Data = "{\"result\":\"" ++ Char ++ "\"}\n",
			{Data, fun() -> mystream(Number + 1) end}
	end.

