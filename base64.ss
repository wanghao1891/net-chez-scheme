;; the encoder and decoder for base64

(define encode-base64
  (lambda (src)
    (let [(binary-string (char-string->binary-string src))]
      (list->string
       (let loop [(i 0) (binary-string-length (string-length binary-string))]
         (cond
          ((= (- binary-string-length i) 0)
           '())
          ((< (- binary-string-length i) 6)
           (cons (substring-binary binary-string i binary-string-length) '()))
          (else (cons (substring-binary binary-string i (+ i 6))
                      (loop (+ i 6) binary-string-length)))))))))

(define substring-binary
  (lambda (src start end)
    (integer->char
     (+ 65
        (string->number
         (substring src start end)
         2))
     )))

(define char-string->binary-string
  (lambda (src)
    (let [(src-u8 (string->utf8 src))]
      (let loop [(i 0) (src-u8-length (bytevector-length src-u8))]
        (let [(binary-string (decimal->binary-string (bytevector-u8-ref src-u8 i)))]
          (if (= src-u8-length (+ i 1))
              binary-string
              (string-append binary-string (loop (+ i 1) src-u8-length))))))))

(define decimal->binary-string
  (lambda (src)
    (let [(binary-string (number->string src 2))]
      (let [(binary-string-length (string-length binary-string))]
        (let loop [(i binary-string-length) (dest binary-string)]
          ;;(display i) (display dest) (newline)
          (if (= i 8)
              dest
              (loop (+ i 1) (string-append "0" dest))))))))

;; (decimal->binary-string 7)
;; (char-string->binary-string "Man")
(encode-base64 "Man")
