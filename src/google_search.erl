-module(google_search).

-export([search/1]).

-include_lib("records.hrl").

search(SearchString) ->
	{ok, {{Version, 200, ReasonPhrase}, Headers, Body}} = httpc:request(get, {"http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=" ++ edoc_lib:escape_uri(SearchString), []}, [], []),
	Json = mochijson2:decode(Body),
	<<"OK">> = json_utils:take(Json, [status]),
	Results = json_utils:take(Json, [results]),
	[toSearchResult(Result) || Result <- Results].


toSearchResult(JsonResult) ->
	Name = json_utils:take(JsonResult, [formatted_address]),
	Geometry = json_utils:take(JsonResult, [geometry]),
	ViewPort = json_utils:take(Geometry, [viewport]),
	BoundingBox = #boundingbox{
					   northLat=json_utils:take(ViewPort, [northeast, lat]),
					   southLat=json_utils:take(ViewPort, [southwest, lat]),
					   eastLong=json_utils:take(ViewPort, [northeast, lng]),
					   westLong=json_utils:take(ViewPort, [southwest, lng])
					},
	Center = #point{latitude=json_utils:take(Geometry, [location, lat]), longitude=json_utils:take(Geometry, [location, lng])},
	#search_result{name=Name, boundingbox=BoundingBox, center=Center, source=google}.