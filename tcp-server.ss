(load-shared-object "./tcp.so")

;;; Requires from C library:
;;;   close, dup, execl, fork, kill, listen, tmpnam, unlink
(case (machine-type)
  [(i3le ti3le) (load-shared-object "libc.so.6")]
  [(i3osx ti3osx) (load-shared-object "libc.dylib")]
  [else (load-shared-object "libc.dylib")])

(display "loaded tcp.so")

;;; basic C-library stuff
(define listen
  (foreign-procedure "listen" (integer-32 integer-32)
                     integer-32))

;;; routines defined in csocket.c

(define accept
  (foreign-procedure "do_accept" (integer-32)
                     integer-32))

(define socket
  (foreign-procedure "do_socket" ()
                     integer-32))

(define bind
  (foreign-procedure "do_bind" (integer-32 integer-32)
                     integer-32))

(define listen
  (foreign-procedure "listen" (integer-32 integer-32)
                     integer-32))

(define read
  (foreign-procedure "read" (integer-32 string integer-32)
                     integer-32))

(define write
  (foreign-procedure "write" (integer-32 string integer-32)
                     integer-32))

(define close
  (foreign-procedure "close" (integer-32)
                     integer-32))

#;
(define create-tcp-server
  (foreign-procedure "create_tcp_server" (integer-32)
                     integer-32))

(define create-tcp-server
  (lambda (portno)
    (let ([sockfd (socket)])
      (bind sockfd portno)
      (listen sockfd 5)
      (let loop ()
        (let ([new-sockfd (accept sockfd)])
          (let ([buffer (make-string 1024)])
            (read new-sockfd buffer 255)
            (display buffer))
          (write new-sockfd "I got your message ..." 25)
          (close new-sockfd))
        (loop)))))

(create-tcp-server 6000)
