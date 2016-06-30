(load "tcp.ss")
(load "base64.ss")

(define sockfd (check 'socket (socket)))

(define create-websocket-server
  (lambda (port)
    (check 'bind (bind sockfd port))
    (check 'listen (listen sockfd 5))
    (let ([kq (check 'kqueue (kqueue))])
      (check 'update-kqueue (update-kqueue sockfd kq 5))
      (let loop ()
        (define event-number (wait-events kq))
        (display (string-append "event-number is " (number->string event-number)))
        (newline)
        (let loop-1 ([n 0])
          (if (< n event-number)
              (begin
                (let ([event-type (get-event-type n sockfd)])
                  (display (string-append "event-type is "
                                          event-type))
                  (newline)
                  (cond
                   [(string=? event-type "accept")
                    (let ([new-sockfd (check 'accept (accept sockfd))])
                      (update-kqueue new-sockfd kq 0))]
                   [(string=? event-type "read")
                    (handle-message (get-event-ident n))]
                   [(string=? event-type "disconnect")
                    (check 'close (close (get-event-ident n)))]
                   [else (display "other event")]))
                (loop-1 (+ n 1)))))
        (loop)))))

(define close-websocket-server
  (lambda ()
    (check 'close (close sockfd))))

(define handle-message
  (lambda (socket)
    (display (read-string socket))
    (let [(response-data "HTTP/1.1 101 Web Socket Protocol Handshake\r\nAccess-Control-Allow-Credentials: true\r\nAccess-Control-Allow-Headers: content-type\r\nAccess-Control-Allow-Headers: authorization\r\nAccess-Control-Allow-Headers: x-websocket-extensions\r\nAccess-Control-Allow-Headers: x-websocket-version\r\nAccess-Control-Allow-Headers: x-websocket-protocol\r\nAccess-Control-Allow-Origin: https://www.websocket.org\r\nConnection: Upgrade\r\nDate: Wed, 08 Jun 2016 14:15:44 GMT\r\nSec-WebSocket-Accept: tmpHZWtv6raspXQTTbcwpkfE924=\r\nServer: Kaazing Gateway\r\nUpgrade: websocket\r\n\r\n")]
      (display response-data)
      (write-string socket response-data))
    ))
