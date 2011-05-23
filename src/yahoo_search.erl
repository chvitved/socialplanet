-module(yahoo_search).

-export([search/1]).

-include_lib("records.hrl").

search(SearchString) ->
	{ok, {{Version, 200, ReasonPhrase}, Headers, Body}} = 
		httpc:request(get, {"http://where.yahooapis.com/v1/places.q(" ++ edoc_lib:escape_uri(SearchString) ++ ");count=5?appid=sl8e.YXV34G5nM.BqVkmjXairaV38K68NJLonqKG9eKqIcvo.VL0hWp5qUZzbFg-", 
		[{"Accept", "application/json"}]}, [], []),
	Json = mochijson2:decode(Body),
	PlaceList = json_utils:take(Json, [places, place]),
	[toSearchResult(Place) || Place <- PlaceList].


toSearchResult(Place) ->
	Region = json_utils:take(Place, [admin1]),
	Country = json_utils:take(Place, [country]),
	ShortName = json_utils:take(Place, [name]),
	Name = <<ShortName/binary, " ", Region/binary, " ", Country/binary>>,	
	Bbox = json_utils:take(Place, [boundingBox]),
	BoundingBox = #boundingbox{
					   northLat=json_utils:take(Bbox, [northEast, latitude]),
					   southLat=json_utils:take(Bbox, [southWest, latitude]),
					   eastLong=json_utils:take(Bbox, [northEast, longitude]),
					   westLong=json_utils:take(Bbox, [southWest, longitude])
					},
	Centroid = json_utils:take(Place, [centroid]),
	Center = #point{latitude=json_utils:take(Centroid, [latitude]), longitude=json_utils:take(Centroid, [longitude])},
	#search_result{name=Name, boundingbox=BoundingBox, center=Center, source=yahoo}.
