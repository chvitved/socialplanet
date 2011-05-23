-module(test).
-export([run/0]).

-include("records.hrl").

run() ->
	Point = #point{latitude=1, longitude=2},
	record_to_json:to_json(Point).
	
	