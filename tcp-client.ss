(load-shared-object "./tcp.so")

(display "loaded tcp.so")

(define create-tcp-client
  (foreign-procedure "create_tcp_client" (string integer-32)
    integer-32))

(create-tcp-client "127.0.0.1" 6000)
