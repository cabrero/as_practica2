-module(server).
-export([start/2, loop/1, server/1]).

start(Num,LPort) ->
    case gen_tcp:listen(LPort,[{active, true},{packet,2}]) of
        {ok, ListenSock} ->
            start_servers(Num,ListenSock),
            {ok, Port} = inet:port(ListenSock),
            Port;
        {error,Reason} ->
            {error,Reason}
    end.

start_servers(0,_) ->
    ok;
start_servers(Num,LS) ->
    spawn(?MODULE,server,[LS]),
    start_servers(Num-1,LS).

server(LS) ->
    case gen_tcp:accept(LS) of
        {ok,S} ->
            loop(S),
            server(LS);
        Other ->
            io:format("accept returned ~w - goodbye!~n",[Other]),
            ok
    end.
process(Data) ->
    timer:sleep(5000),
    Data.

loop(S) ->
    inet:setopts(S,[{active,true}]),
    receive
        {tcp,S,Data} ->
            Answer = process(Data), % Not implemented in this example
            io:format("Mensaje recibido del cliente: ~s ~n", [Answer]),
            gen_tcp:send(S, Answer),
            loop(S);
        {tcp_closed,S} ->
            io:format("Socket ~w closed [~w]~n",[S,self()]),
            ok
    end.