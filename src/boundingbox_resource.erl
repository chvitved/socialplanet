%% @author author <author@example.com>
%% @copyright YYYY author.
%% @doc Example webmachine_resource.

-module(boundingbox_resource).
-export([init/1, 
		malformed_request/2,
		allowed_methods/2,
		to_html/2
		]
	).

-include_lib("webmachine/include/webmachine.hrl").
-include_lib("records.hrl").

init([]) -> {ok, undefined}.

malformed_request(ReqData, Context) ->
	Bounding_box_params_list = string:tokens(wrq:path_info(box_params,ReqData), ","),
	case Bounding_box_params_list of
		[NorthLat, SouthLat, EastLong, WestLong] -> 
			Bounding_box = #boundingbox{northLat=NorthLat, southLat=SouthLat, eastLong=EastLong, westLong=WestLong},
			{false, ReqData, #context{boundingbox=Bounding_box}};
		_ -> {true, ReqData, Context}
	end.

allowed_methods(ReqData, Context) ->
	{['GET'], ReqData, Context}.

to_html(ReqData, State) ->
	{"", ReqData, State}.

		

