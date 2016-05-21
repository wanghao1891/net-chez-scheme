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

#;
(define read
  (foreign-procedure "read" (integer-32 string integer-32)
                     integer-32))

  (define read
    (foreign-procedure "do_read" (integer-32 integer-32)
                       string))

(define write
  (foreign-procedure "write" (integer-32 string integer-32)
                     integer-32))

(define close
  (foreign-procedure "close" (integer-32)
                     integer-32))

(define connect
  (foreign-procedure "do_connect" (integer-32 string integer-32)
                     integer-32))

(define fgets
  (foreign-procedure "do_fgets" (string integer-32)
                     void))

(define check
  ;; signal an error if status x is negative, using c-error to
  ;; obtain the operating-system's error message
  (lambda (who x)
    (if (< x 0)
        (error who (c-get-error x))
        x)))

#;
(define create-tcp-server
  (foreign-procedure "create_tcp_server" (integer-32)
                     integer-32))

(define create-tcp-server
  (lambda (portno)
    (let ([sockfd (socket)])
      (bind sockfd portno)
      (listen sockfd 5)
      (let ([new-sockfd (accept sockfd)])
        (let loop ()
          (let ([message (string-append
                          "I got your message: "
                          (read new-sockfd 255))])
            (display message)
            (newline)
            (write new-sockfd message (string-length message)))
          ;;(close new-sockfd)
          (loop))))))

;;(create-tcp-server 6000)

(define create-tcp-client
  (lambda (host port)
    (let ([sockfd (socket)])
      (connect sockfd host port)
      (printf "Please enter the message: ")
      (let ([message (string (read-char))])
        (display (string-append "client send: " message))
        (newline) ;; this is very important, otherwise can't show the received messages
        (write sockfd message (string-length message))
        (read sockfd 255)
        ;;(display (string-append "client receive: " (read sockfd 255)))
        )
      #;
      (let loop ()

        (let ([buffer (string
                       (integer->char
                        (get-u8 (standard-input-port))))])
          (newline)
          (display (string-append "client write: " buffer))
          (newline)
          (write sockfd buffer (string-length buffer)))
        (display (string-append "client read: " (read sockfd 255)))
        ;;(loop)
        )
      ;;(close sockfd)
      )))
