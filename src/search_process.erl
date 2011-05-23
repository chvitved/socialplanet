-module(search_process).

-export([init/0, search/1]).

-include_lib("records.hrl").

init() -> inets:start().

doSearch(SearchFunction, CollectorProcessPid) ->
	spawn(fun() ->
			Results = SearchFunction(),
			CollectorProcessPid ! {ok, Results}
	end).

collectorLoop(0, ReceiverPid) -> ReceiverPid ! done;
collectorLoop(OutStandingResponses, ReceiverPid) ->
	receive
		{ok, Results} -> 
			ReceiverPid !{ok, Results},
			collectorLoop(OutStandingResponses - 1, ReceiverPid)
	end.


search(SearchBinary) when is_binary(SearchBinary) ->
	search(binary_to_list(SearchBinary));

search(SearchString) when is_list(SearchString) ->
	SearchServices = [fun() -> lonelyplanet_search:search(SearchString) end, fun() -> google_search:search(SearchString) end, fun() -> yahoo_search:search(SearchString) end],
	MyPid = self(),
	CollectorPid = spawn(fun() -> collectorLoop(length(SearchServices), MyPid) end),
	[doSearch(Service, CollectorPid) || Service <- SearchServices],
	void.
	
	
	
	
	

