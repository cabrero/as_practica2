#! /bin/bash

erlc balanceador.erl cliente.erl servidor.erl
 xterm erl -s servidor start -sname s
 xterm erl -s servidor start -sname s2
 xterm erl -s servidor start -sname s3
 xterm erl -s balanceador start -sname b [s@MBP, s2@MBP, s3@MBP]
 xterm erl -s cliente calcular -sname c [b@MBP]
