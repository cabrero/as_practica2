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
  register (balanceador, spawn (?MODULE, loop , [[{Node, on} || Node <- NodeList]])), ok.

addServer(Bal, Node) ->
   {balanceador, Bal} ! {Node,nodo_nuevo}.

activeNode(NodeList)->
  case NodeList of
    [] ->
      [];
    [{Nombre,off}|T]->
      [{Nombre,on}|T];
    [{N,on}|T]->
      lists:append([{N,on}],activeNode(T))
  end.

inactiveNode(NodeList)->
  case NodeList of
    [] ->
      [];
    [{Nombre,on}|T]->
      [{Nombre,off}|T];
    [{N,off}|T]->
      lists:append([{N,off}],inactiveNode(T))
  end.

addServerInactive(Bal) ->
  {balanceador, Bal} ! {inactive}.

addServerActive(Bal) ->
  {balanceador, Bal} ! {active}.

loop(NodeList) ->
  receive
    {peticion, Cliente} ->
      select_server([{Nodes, on} || {Nodes, on} <- NodeList], Cliente),
      loop(NodeList);
    {Node,nodo_nuevo} ->
      io:format("ENTRO"),
      NodeList2=NodeList++[{Node,off}],
      io:format("NodeList ~tp ~n", [NodeList2]),
      loop(NodeList2);
    {active} ->
      Lista = [{Nodes, off} || {Nodes, off} <- NodeList],
      Lista2 = [{Nodes, on} || {Nodes, on} <- NodeList],
      NodeList2=activeNode(Lista),
      NodeList3=NodeList2++Lista2,
      io:format("~tp~n",[NodeList3]),
      loop(NodeList3);
    {inactive} ->
      Lista = [{Nodes, on} || {Nodes, on} <- NodeList],
      Lista2 = [{Nodes, off} || {Nodes, off} <- NodeList],
      case length(Lista) of
        0 -> io:format("No hay ningun servidor activo"),
             NodeList2 = Lista;
        1 -> io:format("Solo hay un servidor activo"),
             NodeList2 = Lista;
        _ -> NodeList2=inactiveNode(NodeList)
      end,
      NodeList3=NodeList2++Lista2,
      io:format("~tp~n",[NodeList3]),
      loop(NodeList3);

    _ -> fail
  end.