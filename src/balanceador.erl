-module(balanceador).

%-export([load/0, show/1, pick/1]).
-compile(export_all).

-define(TIMEOUT, 3000).

% Return node() system load.
load() ->
    load_result(cpu_sup:avg1()). %int con la ultima carga(minuto) o  {error, reason} y 0 si no disponible

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
    %[{Node, Load} || {load, Node, Load} <- Results].
    %lists:map(fun(X) -> X ! {balanceador, self()}, NodeList).
    %multicall -> recoge informacion de los servidores

select_server(NodeList) ->
  lok.%ists:map(fun(X) -> X ! {balanceador, self()}, NodeList).


start(NodeList) ->
  receive
    {request, From} ->
      io:format("Peticion nueva de  ~p~n",[From]),
      select_server(NodeList), start(NodeList);
    {carga, Carga} -> {carga, Carga}, start(NodeList);
    _ -> fail
  end.
