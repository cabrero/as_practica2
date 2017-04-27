-module(servidor).
%-export([start/0, loop/0]).
-compile(export_all).

start() ->
    register (servidor, spawn ( fun loop/0 )).

loop() ->
    receive
        {peticion, Origen} ->
            io:format("Peticion de ~p~n", [Origen]),
            Origen ! {respuesta, hola},
            loop();
        terminar ->
            io:format("terminar");
        Otracosa ->
            io:format("Peticion incorrecta: ~p~n", [Otracosa]),
            loop()
    end.
