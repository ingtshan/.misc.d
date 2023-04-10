;;; doom/init-deadgrep.el -*- lexical-binding: t; -*-

(require 'cl)

(defvar custom/deadgrep--last-buffer nil
  "Last buffer of deadgrep")

(defun cutom/deadgrep-record-last-buffer ()
  (setq custom/deadgrep--last-buffer (current-buffer)))

(defun custom/jump-backward-respect-deadgrep ()
  (interactive)
  (if (buffer-live-p custom/deadgrep--last-buffer)
      (let ((buf (current-buffer))
            (switch-method (if (get-buffer-window custom/deadgrep--last-buffer)
                               #'switch-to-buffer-other-window
                             #'switch-to-buffer)))
        (funcall switch-method custom/deadgrep--last-buffer)
        (setq custom/deadgrep--last-buffer buf))
    (funcall-interactively #'better-jumper-jump-backward)))

(defun custom/deadgrep-or-finish-editing ()
  (interactive)
  (if (string-match-p "^*deadgrep " (buffer-name)) (deadgrep-mode)
    (call-interactively #'custom/deadgrep)))

(use-package! deadgrep
  :config
  (advice-add #'deadgrep-visit-result :before #'cutom/deadgrep-record-last-buffer)
  (advice-add #'deadgrep-visit-result-other-window :before #'cutom/deadgrep-record-last-buffer)

  ;; use completing-read instead of reading-from-minibuffer
  (fset 'original-read-from-minibuffer (symbol-function 'read-from-minibuffer))
  (defun custom/deadgrep (search-term &optional directory)
    (interactive (list
                  (flet ((read-from-minibuffer
                          (prompt &optional a b c history sym-name d)
                          (flet ((read-from-minibuffer ; prevent looping
                                  (prompt &optional a b c history sym-name d)
                                  (original-read-from-minibuffer
                                   prompt a b c history sym-name d)))
                                (completing-read prompt (eval history) nil nil sym-name))))
                        (deadgrep--read-search-term))))
    (funcall-interactively #'deadgrep search-term directory)))

;; (evil-set-initial-state 'deadgrep-mode 'emacs)
(provide 'init-deadgrep)
