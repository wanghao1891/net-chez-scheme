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
  (foreign-procedure "read" (integer-32 u8* integer-32)
                     integer-32))

(define read-string
  (foreign-procedure "do_read" (integer-32 integer-32)
                       string))

(define write
  (foreign-procedure "write" (integer-32 string integer-32)
                     integer-32))

(define write-string
  (lambda (socket message)
    (write socket message (string-length message))))

(define close
  (foreign-procedure "close" (integer-32)
                     integer-32))

(define connect
  (foreign-procedure "do_connect" (integer-32 string integer-32)
                     integer-32))

(define c-error
  (foreign-procedure "get_error" ()
                     string))

(define check
  ;; signal an error if status x is negative, using c-error to
  ;; obtain the operating-system's error message
  (lambda (who x)
    (if (< x 0)
        (error who (c-error))
        x)))

(define create-tcp-server
  (lambda (portno)
    (let ([sockfd (check 'socket (socket))])
      (check 'bind (bind sockfd portno))
      (check 'listen (listen sockfd 5))
      (let loop ()
        (let ([new-sockfd (check 'accept (accept sockfd))])
          (let loop ()
            (define buffer (read-string new-sockfd 1024))
            (if (eof-object? buffer)
                (check 'close (close new-sockfd))
                (begin (let ([message (string-append
                                       "I got your message: "
                                       buffer)])
                         (display message)
                         (write-string new-sockfd message))
                       (loop)))))
        (loop))
      (check 'close (close sockfd)))))

;;(create-tcp-server 6000)

(define create-tcp-client
  (lambda (host port)
    (let ([sockfd (socket)])
      (connect sockfd host port)
      (let loop ()
        (printf "Please enter the message: ")
        (let ([message (string (read-char))])
          (display (string-append "client send: " message))
          (newline) ;; this is very important, otherwise can't show the received messages
          (write sockfd message (string-length message))
          ;;(read sockfd 255)
          (display (string-append "client receive: " (read sockfd 255)))
          )
        (read-char)
        (loop))
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

(define create-tcp-client
  (lambda (host port)
    (let ([sockfd (socket)])
      (check 'connect (connect sockfd host port))
      (let ([message "world\n"])
        (display (string-append "client send: " message))
        (write sockfd message (string-length message)))
      (read sockfd 255)
      sockfd
      ;;(check 'close (close sockfd))
      #;
      (let loop ()
        (display (string-append "client receive: " (read sockfd 255)))
        (loop)))))
#;
(define create-tcp-client
  (lambda (host port)
    (define sockfd (socket))
    (connect sockfd host port)
    (write sockfd "world" (string-length "world"))
    (do ([msg (read sockfd 255) (read sockfd 255)])
        ((eof-object? msg) (display "Done!\n"))
      (display msg))
    (close sockfd)
    #;
    (let loop ()
      (display (read sockfd 255))
      (loop))))
