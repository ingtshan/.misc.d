;;; lib/misc/lisp/custom/custom-functions.el -*- lexical-binding: t; -*-

;; chek my font
;; (font-info "Hack Nerd Font")

;;;###autoload
(defun custom/borg-assimilate (host repo)
  "use borg install package"
  (let* ((package-name (file-name-base
                        (and (string-match "/\\(.+\\)$" repo)
                             (match-string 1 repo))))
         (url (format (pcase host
                        ;; add support here
                        ("github"  "git@github.com:%s.git")
                        ) repo)))
    (borg-assimilate package-name url)))

;;;###autoload
(defun custom/save-all-buffers ()
  (interactive)
  (message "save all buffers")
  (save-some-buffers 0))

;;;###autoload
(defun custom/translate-shell-brief (word)
  "Show the explanation of WORD in the echo area."
  (interactive
   (list (translate-shell--read-string)))
  (let ((word-sym (intern word)))
    (if (assq word-sym translate-shell-brief-cache)
        (message (assoc-default word-sym translate-shell-brief-cache))
      (let* ((output
              (shell-command-to-string
               (format translate-shell-brief-command (shell-quote-argument word))))
             (result (replace-regexp-in-string "\n" "; " output)))
        (message result)
        (add-to-list 'translate-shell-brief-cache (cons word-sym result))))))

;; (defun custom/toggle-frame-maximized-or-fullframe ()
;;   (interactive)
;;   (let ((bias (if (equal (shell-command-to-string "m1ddc display list") "")
;;                   37 0)))
;;     (set-frame-position (selected-frame) 0 bias)
;;     (if (equal (display-pixel-width) 4000)
;;         ;; for DELL U2720Q
;;         ;; don't know why `(display-pixel-width)' return 400 for it
;;         (set-frame-size (selected-frame) (- 2560 20) 1440 t)
;;       (set-frame-size (selected-frame)
;;                       (- (display-pixel-width) 20)
;;                       (- (display-pixel-height) bias) t))))


(provide 'custom-functions)
