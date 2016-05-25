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

;; Example: (bytevector-slice #vu8(1 2 3 4 5) 3 2) => #vu8(4 5)
(define bytevector-slice
  (lambda (v start n)
    (let ([slice (make-bytevector n)])
      (bytevector-copy! v start slice 0 n)
      slice)))

(define read-string
  (lambda (socket . options)
    (define length 1024)
    (if (not (null? options))
        (set! length (car options)))
    (let* ([buffer-size length]
           [buf (make-bytevector buffer-size)]
           [n (check 'read (read socket buf buffer-size))])
      (if (not (= n 0))
          (bytevector->string (bytevector-slice buf 0 n)
                              (current-transcoder))
          (eof-object)))))

#;;
(define do-read
  (foreign-procedure "do_read" (integer-32 integer-32)
                     string))

;; first version, length is optional, use (socket . length), length is a list
#;;
(define read-string
  (lambda (socket . length)
    (if (null? length)
        (set! length 1024)
        (set! length (car length)))
    (do-read socket length)))

;; second version, length is optional, use case-lambda
#;;
(define read-string
  (case-lambda
   [(socket) (do-read socket 1024)]
   [(socket length) (do-read socket length)]))

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

(define kqueue
  (foreign-procedure "kqueue" ()
                     integer-32))

(define update-kqueue
  (foreign-procedure "update_kqueue" (integer-32 integer-32)
                     integer-32))

(define wait-events
  (foreign-procedure "wait_events" (integer-32)
                     integer-32))

(define get-event-ident
  (foreign-procedure "get_event_ident" (integer-32)
                     integer-32))

(define get-event-type
  (foreign-procedure "get_event_type" (integer-32 integer-32)
                     string))

;; (define sockfd (socket))
;; (bind sockfd 6000)
;; (listen sockfd 5)
;; (define kq (kqueue))
;; (update-kqueue sockfd kq)
;; (wait-events kq)
;; (get-event-type 0 sockfd)
;; (define new-sockfd (accept sockfd))
;; (update-kqueue new-sockfd kq)
;; (wait-events kq)
;; (define new-sockfd-1 (get-event-ident 0))
;; (read-string new-sockfd-1)
;; (write-string new-sockfd-1 "welcome\n")

(define set-key
  (foreign-procedure "set_key" (string string)
                     integer-32))

(define get-key
  (foreign-procedure "get_key" (string)
                     string))

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
          (display "client connected\n")
          (let loop ()
            (define buffer (read-string new-sockfd))
            (if (eof-object? buffer)
                (begin (check 'close (close new-sockfd))
                       (display "client disconnected\n"))
                (begin (let ([message (string-append
                                       "I got your message: "
                                       buffer)])
                         (display message)
                         (newline) ;; this line is important, otherwise can't show the new message that client send by (write-string "yes"), actually i don't know why
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
        (write-string sockfd message))
      (display (read-string sockfd))
      sockfd)))

;;(define socket (create-tcp-client "127.0.0.1" 6000))
;;(write-string socket "yes")
;;(read-string socket)
