(define parse-html-header
  (lambda (header)
    ))

(define string-split
  (lambda (source separator)
    (let loop ([i 0] [length (string-length source)])
      (if (< i length)
          (begin (display (string-ref source i))
                 (loop (+ i 1) length))))))

(string-split "abcdef" "cd")

(define substring
  (lambda (source start end)
    (display (list->string (let loop ([s start])
                             (cond
                              [(= (- end s) 0)
                               '()]
                              [else (cons (string-ref source s) (loop (+ s 1)))]))))))

(substring "abcdef" 2 5)

;; (error 'string-ref "aaa" (string-ref "hello" 4))
