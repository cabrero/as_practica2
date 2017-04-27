-module(cliente).

%-export([start/0, start/1, calculate/1]).
-compile(export_all).
-define(TIMEOUT, 3000).

calcular(Nodos,T) ->
  {Results, _BadNodes} = rpc:multicall(Nodos, balanceador, is_process_alive, [], ?TIMEOUT),
  {Nodo, _, _} = lists:nth(1, Results),
  calcular_aux(Nodo,T).

calcular_aux(Nodo,T) ->
  io:format("Enviada peticion...~n"),
  timer:sleep(T*1000),
  {balanceador, Nodo} ! {peticion, self()},
  io:format("Esperando respuesta...~n"),
  receive
    {respuesta, Resp} ->
    io:format("Respuesta recibida: ~s ~n",[Resp]);
    _ ->
      error
  end.
