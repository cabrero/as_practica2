-module(cliente).

-export([start/0, start/3, ping/3]).

start() ->
    start(node(), 3, 3).

start(Nodo) ->
    F = fun(I) ->
                Ping = spawn(cliente, ping, ["PING" ++ [47+I], Max, Nodo]),
                Ping ! iniciar
        end,
    lists:foreach ( F, lists:seq(1, NumPing) ).

calculate() ->


ping(Nombre, Max, Nodo) ->
    receive
        iniciar ->
            io:format("~s (~p/~p) ~n", [Nombre, 1, Max]),
            {pong_server, Nodo} ! {ping, self(), Nombre, 1, Max},
            ping(Nombre, Max, Nodo);
        {pong, Indice} when Indice < Max ->
            io:format("~s (~p/~p) ~n", [Nombre, Indice+1, Max]),
            {pong_server, Nodo} ! {ping, self(), Nombre, Indice+1, Max},
            ping(Nombre, Max, Nodo);
        _ ->
            io:format("Ping Terminar ~s~n", [Nombre])
    end.
