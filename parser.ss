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

;; (error 'string-ref "aaa" (string-ref "hello" 4))
