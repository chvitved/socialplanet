
-module(socialplanet_app).

-behaviour(application).
-export([start/2,stop/1]).


%% @spec start(_Type, _StartArgs) -> ServerRet
%% @doc application start callback for socialplanet.
start(_Type, _StartArgs) ->
    socialplanet_sup:start_link().

%% @spec stop(_State) -> ServerRet
%% @doc application stop callback for socialplanet.
stop(_State) ->
    ok.
