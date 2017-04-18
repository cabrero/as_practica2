-module(balanceador).

%-export([load/0, show/1, pick/1]).
-compile(export_all).

-define(TIMEOUT, 3000).

% Return node() system load.
load() -> %1.
    load_result(cpu_sup:avg1()). %int con la ultima carga(minuto) o  {error, reason} y 0 si no disponible

load_result(0) ->
    cpu_sup:start(), {load, node(), cpu_sup:avg1()};
    %node() -> devuelve el nombre del nodo local

load_result(N) ->
    {load, node(), N}.



select_server(NodeList, Cliente) ->
  {Results, BadNodes} = rpc:multicall(NodeList, erlang, is_process_alive, [], ?TIMEOUT),
  N = random:uniform(length(Results)), %escogemos un nodo aleatorio que va de 1 a N (long de la lista)
  io:format("Numero de nodo aleatorio: ~tp ~n",[N]),
  Node = lists:nth(N, Results),
  {servidor, Node} ! {peticion,Cliente}. %sacamos el nodo de la posicion aleatoria N

start(NodeList) ->
    register (balanceador, spawn (?MODULE, loop , [NodeList])), ok.

loop(NodeList) ->
  receive
    {peticion, Cliente} -> 
      select_server(NodeList, Cliente), 
      loop(NodeList);
    _ -> fail
  end.
