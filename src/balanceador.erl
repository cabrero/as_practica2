-module(balanceador).

%-export([load/0, show/1, pick/1]).
-compile(export_all).

-define(TIMEOUT, 3000).

% Return node() system load.
load() -> 1.
    %load_result(cpu_sup:avg1()). %int con la ultima carga(minuto) o  {error, reason} y 0 si no disponible

load_result(0) ->
    cpu_sup:start(), {load, node(), cpu_sup:avg1()};
    %node() -> devuelve el nombre del nodo local

load_result(N) ->
    {load, node(), N}.

% Show load of all nodes
show([]) ->
    show([nodes()]);
show(NodeList) ->
    {Results, BadNodes} = rpc:multicall(NodeList, balanceador, load, [], ?TIMEOUT),
      {Results, BadNodes}.

select_server(NodeList, Client) ->
  {Results, BadNodes} = rpc:multicall(NodeList, balanceador, load, [], ?TIMEOUT),

start(NodeList) ->
    register (balanceador, spawn ( fun loop/0 )), ok.

loop(NodeList) ->
  receive
    {request, Client} ->
      io:format("Peticion nueva de  ~p~n",[Client]),
      select_server(NodeList, Client), loop(NodeList);
    _ -> fail
  end.
