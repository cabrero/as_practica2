-module(cliente).

%-export([start/0, start/1, calculate/1]).
-compile(export_all).


calcular(Nodo) ->
  io:format("Enviada peticion...~n"),
  {balanceado, Nodo} ! {peticion, self()},
  waitResponse().


waitResponse() ->
  io:format("Esperando respuesta...~n"),
  receive
    {respuesta, Resp} ->
    io:format("Respuesta recibida: ~s ~n",[Resp]);
    _ ->
      error
  end.
