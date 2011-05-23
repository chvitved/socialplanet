-module(json_utils).

-export([take/2]).

take({struct, PropList}, [Key |Rest]) ->
	take( proplists:get_value(as_binary(Key), PropList), Rest);
take(Val, []) -> Val;
take(List, [Key |Rest]) when is_integer(Key) ->
	take( lists:nth(Key, List), Rest).

as_binary(V) when is_atom(V) -> atom_to_binary(V, latin1);
as_binary(V) when is_binary(V) -> V;
as_binary(V) when is_list(V) -> list_to_binary(V).



