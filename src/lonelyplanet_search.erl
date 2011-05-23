-module(lonelyplanet_search).
-export([search/1]).

-include_lib("records.hrl").

search(Search_string) ->
	{ok, {{Version, 200, ReasonPhrase}, Headers, Body}} = httpc:request(get, {"http://api.lonelyplanet.com/api/places?name=" ++ edoc_lib:escape_uri(Search_string), 
			[{"Authorization", "Basic " ++  binary_to_list(base64:encode("86TXO25BGUhAvlh9L1eVg:hmUwGpKd6GAZ11KoWb6wRJfYeHDSRjfp1j8pECFps"))}]}, 
			[], []),
	{ok, {undefined, undefined, Results}, []} = xmerl_sax_parser:stream(Body, [{event_fun, fun event/3}]),
	Results.

event({startElement,_,"places",_, _}, _Location, _State) ->
	{undefined, undefined, []};

event({startElement,_,"place",_, _}, _, _State={_, _, Result_list})->
	{undefined, #search_result{source=lonelyplanet},Result_list};

event({startElement,_,Element_name,_, _}, _, _State={_, Current_record, Result_list})->
	{Element_name, Current_record, Result_list};
	
event({characters, Chars}, _location, _State = {Element_name, Current_record, Result_list}) ->
	New_record = case Element_name of
		"full-name" -> 
			Name_list = string:tokens(Chars, " -> "),
			NameStr = lists:foldl(fun(Elem, Sum) -> Elem ++ ", " ++ Sum end, "", Name_list),
			Name = string:sub_string(NameStr, 1, length(NameStr) - 2),
			Current_record#search_result{name=list_to_binary(Name)};
		"north-latitude" ->
			Boundingbox = #boundingbox{northLat=list_to_float(Chars)},
			Current_record#search_result{boundingbox=Boundingbox};
		"south-latitude" ->
			Current_record#search_result{boundingbox=add_boundingbox_element(Current_record#search_result.boundingbox, list_to_float(Chars), southLat)};
		"east-longitude" ->
			Current_record#search_result{boundingbox=add_boundingbox_element(Current_record#search_result.boundingbox, list_to_float(Chars), eastLong)};
		"west-longitude" ->
			Current_record#search_result{boundingbox=add_boundingbox_element(Current_record#search_result.boundingbox, list_to_float(Chars), westLong)};
		_ -> Current_record
				 
	end,
	{Element_name, New_record, Result_list};
	
event({endElement,_,"place",_}, _, _State={_, Current_record, Result_list}) ->
	{undefined, undefined, [Current_record | Result_list]};

event(Event, _Location, State) ->
	State.

add_boundingbox_element(Bounding_box_record, Value, Record_field_name) ->
	Fields = record_info(fields, boundingbox),
	Index = find_index_in_list(Record_field_name, Fields, 1),
	setelement(Index, Bounding_box_record, Value).
	
find_index_in_list(Field, [Head | Tail], Index) ->
	case (Field =:= Head) of 
		true -> Index + 1;
		false -> find_index_in_list(Field, Tail, Index +1)
	end;

find_index_in_list(_, [], _) -> -1.