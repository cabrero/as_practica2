-module(client).
-export([send/2]).
send(PortNo,Message) ->
    {ok,Sock} = gen_tcp:connect("localhost",PortNo,[{active,false},
                                                    {packet,2}]),
    gen_tcp:send(Sock,Message),
    A = gen_tcp:recv(Sock,0),
    gen_tcp:close(Sock),
    A.
%     {ok,Sock} = gen_tcp:connect("localhost", PortNo,
%                             [{active,false},
%                              {send_timeout, 1000},
%                              {packet,2}]),
%                 loop(Sock). % See below
% loop(Sock) ->
%     receive
%         {Client, send_data, Binary} ->
%         	io:format("Mensaje enviado"),
%             case gen_tcp:send(Sock,Binary) of
%                 {error, timeout} ->
%                     io:format("Send timeout, closing!~n",
%                               []),
%                     %handle_send_timeout(), % Not implemented here
%                     Client ! {self(),{error_sending, timeout}},
%                     %% Usually, it's a good idea to give up in case of a 
%                     %% send timeout, as you never know how much actually 
%                     %% reached the server, maybe only a packet header?!
%                     gen_tcp:close(Sock);
%                 {error, OtherSendError} ->
%                     io:format("Some other error on socket (~p), closing",
%                               [OtherSendError]),
%                     Client ! {self(),{error_sending, OtherSendError}},
%                     gen_tcp:close(Sock);
%                 ok ->
%                 	io:format("Mensaje enviado"),
%                     Client ! {self(), data_sent},
%                     loop(Sock)
%             end
%     end.
