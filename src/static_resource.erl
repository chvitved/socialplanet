% taken from
% https://github.com/tsloughter/eCloudEdit/blob/master/lib/ece_web/src/ece_resource_static.erl

-module(static_resource).

-export([init/1,
         allowed_methods/2,
         resource_exists/2,
         content_types_provided/2,
         provide_content/2]).

-include_lib("webmachine/include/webmachine.hrl").
-include_lib("kernel/include/file.hrl").

-record(context, {docroot,fullpath,fileinfo,response_body}).

init([]) ->
    {ok, App}= application:get_application(),
    WWWDir = code:priv_dir(App) ++ "/www",
    {ok, #context{docroot=WWWDir}}.

allowed_methods(ReqData, Context) ->
    {['HEAD', 'GET'], ReqData, Context}.

resource_exists(ReqData, Ctx) ->
	{Exists, _} = file_exists(Ctx, wrq:disp_path(ReqData)),
	{Exists, ReqData, Ctx}.    

content_types_provided(ReqData, Ctx) ->
    Path = get_full_path(Ctx, wrq:disp_path(ReqData)),
    {[{webmachine_util:guess_mime(Path), provide_content}], ReqData, Ctx}.

provide_content(ReqData, Context) ->
    case maybe_fetch_object(Context, wrq:disp_path(ReqData)) of
        {true, NewContext} ->
            Body = NewContext#context.response_body,
            {Body, ReqData, Context};
        {false, NewContext} ->
            {error, ReqData, NewContext}
    end.

maybe_fetch_object(Context, Path) ->
    % if returns {true, NewContext} then NewContext has response_body
    case Context#context.response_body of
        undefined ->
            case file_exists(Context, Path) of
                {true, FullPath} ->
                    {ok, Value} = file:read_file(FullPath),
                    {true, Context#context{response_body=Value}};
                {false, _} ->
                    {false, Context}
            end;
        _Body ->
            {true, Context}
    end.

file_exists(Context, Path) ->
    FPath = get_full_path(Context, Path),
    Exists =  filelib:is_regular(filename:absname(FPath)),
    {Exists, FPath}.

get_full_path(Context, Path) ->
    Root = Context#context.docroot,
    case mochiweb_util:safe_relative_path(Path) of
        undefined -> undefined;
        RelPath ->
            FullPath = filename:join([Root, RelPath]),
            case filelib:is_dir(FullPath) of
                true ->
                    filename:join([FullPath, "index.html"]);
                false ->
                    FullPath
            end
    end.