
%%% This code is copied from yaws

-module(urlencode).

-export([encode/1]).

encode([H|T]) ->
    if
        H >= $a, $z >= H ->
            [H|encode(T)];
        H >= $A, $Z >= H ->
            [H|encode(T)];
        H >= $0, $9 >= H ->
            [H|encode(T)];
        H == $_; H == $.; H == $-; H == $/; H == $: -> % FIXME: more..
            [H|encode(T)];
        true ->
            case integer_to_hex(H) of
                [X, Y] ->
                    [$%, X, Y | encode(T)];
                [X] ->
                    [$%, $0, X | encode(T)]
            end
     end;

encode([]) ->
    [].


integer_to_hex(I) ->
	    case catch erlang:integer_to_list(I, 16) of
	        {'EXIT', _} ->
	            old_integer_to_hex(I);
	        Int ->
	            Int
	    end.
	
	
	old_integer_to_hex(I) when I<10 ->
	    integer_to_list(I);
	old_integer_to_hex(I) when I<16 ->
	    [I-10+$A];
	old_integer_to_hex(I) when I>=16 ->
	    N = trunc(I/16),
	    old_integer_to_hex(N) ++ old_integer_to_hex(I rem 16).