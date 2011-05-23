-module(record_to_json).

-export([to_json/1]).

-include("records.hrl").

to_json(Record) ->
	Json_proplist_struct = to_json_proplist_struct(Record),
	io:format("proplist: ~p~n", [Json_proplist_struct]),
	Json = iolist_to_binary(mochijson2:encode(Json_proplist_struct)),
	io:format("json:~n ~p~n", [Json]),
	Json.

to_json_proplist_struct({Key, Value}) when is_tuple(Value) ->
	{Key, to_json_proplist_struct(Value)};

to_json_proplist_struct({Key, Value}) ->
	{Key, Value};

to_json_proplist_struct(Record) when is_tuple(Record)->
	Record_name = element(1, Record),
	FieldsAsBinaries = [ atom_to_binary(Field, latin1) || Field <- get_fields(Record_name)],			 
	Values= tl(tuple_to_list(Record)), %% remove first element in tuple - name of the record
	Key_values = lists:zip(FieldsAsBinaries, Values),
	
	%% run through each eleent and convert it to a json structure
	Proplist = [to_json_proplist_struct({Key, Value}) || {Key, Value} <- Key_values],
	{struct, Proplist}.
	


get_fields(point) ->
	record_info(fields, point);
get_fields(boundingbox) ->
	record_info(fields, boundingbox);
get_fields(context) ->
	record_info(fields, context);
get_fields(search_result) ->
	record_info(fields, search_result);
get_fields(Name) ->
	undefined.

	
	