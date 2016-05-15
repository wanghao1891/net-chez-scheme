(load-shared-object "./tcp.so")

(display "loaded tcp.so")

(define create-tcp-server
  (foreign-procedure "create_tcp_server" (integer-32)
    integer-32))

(create-tcp-server 6000)
