# net-chez-scheme

# how to use?
## compile
make

;; tcp.so will be created.

## websocket server
$ scheme
> (load "websocket.ss")
> (create-websocket-server 8124)

## tcp client
$ scheme
> (load "tcp-client.ss")
> (create-tcp-client "127.0.0.1" 8124)
Please enter the message: hello

## websocket client in web browser
open websocket.html
enter the address: ws://127.0.0.1:8124/
then click connect
