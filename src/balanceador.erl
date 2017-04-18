-module(balanceador).

%-export([load/0, show/1, pick/1]).
-compile(export_all).

-define(TIMEOUT, 3000).

is_process_alive() ->
  {node(), self(), erlang:is_process_alive(self())}.

imprimir(L) -> io:format("Lista de nodos vivos: ~tp ~n",[L]).

select_server(NodeList, Cliente) ->
  {Results, _BadNodes} = rpc:multicall(NodeList, balanceador, is_process_alive, [], ?TIMEOUT),
  imprimir(Results),
  N = rand:uniform(length(Results)), %escogemos un nodo aleatorio que va de 1 a N (long de la lista)
  io:format("Numero de nodo aleatorio: ~tp ~n",[N]),
  {Node, _, _} = lists:nth(N, Results),
  io:format("Nodo elegido: ~tp ~n",[Node]),
  {servidor, Node} ! {peticion, Cliente}. %sacamos el nodo de la posicion aleatoria N

start(NodeList) ->
    register (balanceador, spawn (?MODULE, loop , [NodeList])), ok.

loop(NodeList) ->
  receive
    {peticion, Cliente} ->
      select_server(NodeList, Cliente),
      loop(NodeList);
    _ -> fail
  end.
