-module(cliente).

%-export([start/0, start/1, calculate/1]).
-compile(export_all).
-define(TIMEOUT, 3000).

calcular(Nodos) ->
  {Results, _BadNodes} = rpc:multicall(Nodos, balanceador, is_process_alive, [], ?TIMEOUT),
  {Nodo, _, _} = lists:nth(1, Results),
  calcular_aux(Nodo).

calcular_aux(Nodo) ->
  io:format("Enviada peticion...~n"),
  {balanceador, Nodo} ! {peticion, self()},
  io:format("Esperando respuesta...~n"),
  receive
    {respuesta, Resp} ->
    io:format("Tiempo de cálculo: ~tp ms ~n",[Resp]);
    _ ->
      error
  end.
