-module(pongserver).
-export([start/0, loop/0]).

start() ->
    register (pong_server, spawn ( fun loop/0 )).

loop() ->
    receive
        {ping, Origen, Nombre, I, Max} ->
            io:format("Pong a ~s (~p/~p) - ~p ~n", [Nombre, I, Max, Origen]),
            Origen ! {pong, I},
            loop();
        terminar ->
            io:format("terminar");
        Otracosa ->
            io:format("Peticion incorrecta: ~p~n", [Otracosa]),
            loop()
    end.
