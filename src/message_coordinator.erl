-module(message_coordinator).

-export([get_message_coordinator/1, get_messages/1]).

get_message_coordinator(Binary_client_id) when is_binary(Binary_client_id) ->
	get_message_coordinator(binary_to_list(Binary_client_id));

get_message_coordinator(Client_id) ->
	Client_id_atom = list_to_atom(Client_id),
	case whereis(Client_id_atom) of 
		undefined -> 
			Pid = spawn(fun() -> message_coordinator_loop([], undefined) end),
			register(Client_id_atom, Pid),
			Pid;
		Pid -> Pid
	end.


get_messages(Client_message_coordinator_pid) ->
	Client_message_coordinator_pid ! {get_data, self()},
	receive
		Msgs -> Msgs
	end.

message_coordinator_loop(Msgs, Listener_pid) ->
	receive
		{data, Msg_id, Data} ->
			io:format("got data for msg id ~p : ~p~n", [Msg_id, Data]),
			New_messages = 
				case Data of
					Data_list when is_list(Data_list) -> 
						Data_list_with_id = [{Msg_id, Data}|| Data <- Data_list], 
						lists:append(Data_list_with_id, Msgs);
					_ -> [{Msg_id, Data} | Msgs]
				end,
			case Listener_pid of
				undefined -> message_coordinator_loop(New_messages, undefined);
				_ -> send_back_messages(Listener_pid, New_messages)
			end;
		{get_data, Reciever_pid} ->
			io:format("get data called...having these msgs ~p~n", [Msgs]),
			case Msgs of
				[] -> message_coordinator_loop(Msgs, Reciever_pid); %% let the receiver wait till we get a msg
				_ -> send_back_messages(Reciever_pid, Msgs)
			end
	end.

send_back_messages(Pid, Msgs) ->
	Pid ! Msgs,
	message_coordinator_loop([], undefined).
	
	

