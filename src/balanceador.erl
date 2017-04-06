-module(balanceador).

-export([load/0, show/1, pick/1]).

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
    show([node()]);
show(L) ->
    {Results, _} = rpc:multicall(L, balancer, load, [], ?TIMEOUT),
    [{Node, Load} || {load, Node, Load} <- Results].
    %multicall -> recoge informacion de los servidores

% Pick a node with lowest system load from list L.
pick([]) ->
    [N] = show([node()]),
    N;
pick(L) ->
    case show(L) of
        [] ->
            pick([]);
        [H|T] ->
            N = select(H, T),
            N
    end.

select(N, []) ->
    N;

select(N, L) ->
    [H|T] = L,
    {_,Load} = N,
    {_,Load1} = H,
    case Load1 < Load of
	true ->
	    N1 = H;
	false ->
	    N1 = N
    end,
select(N1, T).