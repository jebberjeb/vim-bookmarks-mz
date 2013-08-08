(require (prefix-in vim- 'vimext))
(require racket/stream)
(require racket/match)

(define wins (make-hash))

; Get your current (win, buf, line)
(define (get-place)
  (list (vim-get-win-num (vim-curr-win))
        (vim-get-buff-num (vim-curr-buff))
        (car (vim-get-cursor (vim-curr-win)))))

; Set a numbered bookmark.
(define (set-bookmark- bookmark num)
  (let ((win-num (list-ref bookmark 0))
        (win-map (hash-ref wins (list-ref bookmark 0) null)))
    (if (null? win-map) (hash-set! wins win-num (make-hash)) null)
    (hash-set! (hash-ref wins win-num) num bookmark)))

(define (set-bookmark! num)
  (set-bookmark- (get-place) num))

; Execute vim command :b num
(define (goto-buffer! num) (vim-command (string-append
                                          "b "
                                          (number->string num))))
; Execute vim command :num
(define (goto-line! num) (vim-command (number->string num)))

; Goto a bookmark, by number.
(define (goto-bookmark! num)
  (let* ((win-num  (list-ref (get-place) 0))
         (bookmark (hash-ref (hash-ref wins win-num) num)))
    (match-let ([(list win-num buf-num line-num) bookmark])
               (goto-buffer! buf-num)
               (goto-line! line-num))))

; Build vim key bindings.
(define (->add-bm-cmd num)
  (string-append "nnoremap <leader>bm"
                 (number->string num)
                 " :mz (set-bookmark! "
                 (number->string num)
                 ")<cr>"))

(define (->goto-bm-cmd num)
  (string-append "nnoremap <leader><leader>bm"
                 (number->string num)
                 " :mz (goto-bookmark! "
                 (number->string num)
                 ")<cr>"))

(for-each vim-command (map ->add-bm-cmd (stream->list (in-range 10))))
(for-each vim-command (map ->goto-bm-cmd (stream->list (in-range 10))))

