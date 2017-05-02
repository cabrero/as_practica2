-module(cliente_props).

-include_lib("proper/include/proper.hrl").
-compile(export_all).

%% Módulo de implementación que imos probar
-define(TEST_MODULE, cliente).


% Xeradores de datos
nprocs() ->
    integer(1, inf). % xerar números > 0 -> probas positivas
nodos() ->
    oneof([b@cristobal]).

%% Propiedade xeral
prop_cliente(Bal) ->
    ?FORALL({Nodos}, {Bal},
            begin
                Tracer = start_tracing(),
                ok = ?TEST_MODULE:calcular(Nodos),
                timer:sleep(10), % agardamos algo de tempo para que o anel transmita as mensaxes
                                                  % e rematar de recoller as trazas
                Trazas = stop_tracing(Tracer),
                ?WHENFAIL(io:format("Trazas: ~p~n", [Trazas]),
                          conjunction([{envio_de_mensaxes,        envio(Trazas)},
                                       {recepcion_de_mensaxes,    recepcion(Trazas)}]))
            end).


%% Sub-propiedades
% (1) Comprobamos que se crean tantos procesos como se indica
%creacion(NProcs, Trazas) ->
 %   ParentsAndChildren = [{Parent, Child} || {trace, Parent, spawn, Child, _Fun} <- Trazas],
  %  length(ParentsAndChildren) == NProcs.

% (2) Comprobamos que se envía a mensaxe o número de veces axeitado
envio(Trazas) ->
    SendersAndReceivers = [{From, To} || {trace, From, send, {peticion, _}, To} <- Trazas],
    length(SendersAndReceivers) == 1.
    % io:format("SendersAndReceivers ~tp ~n", [length(SendersAndReceivers)]), true.

% (3) Comprobamos que se recibe a mensaxe o número de veces axeitado
recepcion(Trazas) ->
    Receivers = [{Who, What} || {trace, Who, 'receive', {respuesta, What}} <- Trazas],
    length(Receivers) == 1.
    % io:format("Receivers ~tp ~n", [length(Receivers)]), true.


% (4) Comprobamos que se destrúen os procesos
%destruccion(NProcs, Trazas) ->
 %   Stoppers = [{From, To} || {trace, From, send, stop, To} <- Trazas] ++
  %             [{From, To} || {trace, From, send_to_non_existing_process, stop, To} <- Trazas],
   % Stopped =  [Who || {trace, Who, 'receive', stop} <- Trazas],
    %Exited =  [Who || {trace, Who, exit, normal} <- Trazas],
    %(((length(Stoppers) == (NProcs+1)) orelse (length(Stoppers) == NProcs)) andalso
     %((length(Stopped) == (NProcs-1)) orelse (length(Stopped) == 1))        andalso
      %(length(Exited) == NProcs)).

% Outras posibles sub-propiedades:
% (5) as parellas envío-recepción son correctas (circulares)
% ...


%% Funcionalidades internas
start_tracing() ->
    Tracer = spawn(fun tracer/0),
    erlang:trace(all, true, [procs, send, 'receive', {tracer, Tracer}]),
    Tracer.

stop_tracing(Tracer) ->
    erlang:trace(all, false, [all]), % desabilitamos as trazas
    Tracer ! {collect, self()}, % recollemos as trazas do proceso Tracer
    receive {Trazas, Tracer} -> Trazas end.


tracer() ->
    tracer([]).

tracer(TraceList) ->
    receive
        {collect, From} ->
            From ! {lists:reverse(TraceList), self()};
        Other -> 
            tracer([Other|TraceList])
    end.
