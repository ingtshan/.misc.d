;;; lib/misc/doom-init-lsp-bridge.el -*- lexical-binding: t; -*-

(use-package! lsp-mode
  :commands lsp-mode
  :custom (lsp-completion-provider :none) ;; we use Corfu!
  :init (setq lsp-completion-enable t)
  (defun custom/lsp-mode-setup-completion ()
    (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
          '(orderless))
    (setq-local completion-at-point-functions (list  (cape-super-capf #'lsp-completion-at-point #'cape-dict #'cape-file))))
  (add-hook 'lsp-completion-mode  #'custom/lsp-mode-setup-completion))

(use-package! lsp-bridge
  :commands lsp-bridge-mode
  :init
  (setq acm-enable-quick-access t)
  (setq acm-quick-access-modifier 'super)
  (setq acm-quick-access-keys '("j" "l" "f" "s" "." "g" "d" "b" "x" ","))
  (setq acm-enable-tabnine nil)
  (setq acm-enable-yas nil)
  (setq acm-candidate-match-function 'orderless-flex)
  (setq acm-enable-dabbrev nil)
  (setq lsp-bridge-python-lsp-server "pyright-background-analysis")
  (setq lsp-bridge-disable-backup nil)
  (setq lsp-bridge-symbols-enable-which-func t)
  (setq lsp-bridge-enable-mode-line nil)
  (setq lsp-bridge-enable-signature-help nil)
  (setq lsp-bridge-org-babel-lang-list '("clojure" "latex" "python"))
  (setq lsp-bridge-python-ruff-lsp-server "pyright-background-analysis_ruff")
  (setq lsp-bridge-enable-org-babel t)

  :config
  (add-to-list 'evil-emacs-state-modes 'lsp-bridge-ref-mode)

  (add-hook 'lsp-bridge-mode-hook #'(lambda ()
                                      (delete `(lsp-bridge-mode (" [" lsp-bridge--mode-line-format "] ")) mode-line-misc-info)))

  ;; (remove-hook 'python-mode-local-vars-hook #'lsp!) ;; disable lsp
  (remove-hook 'python-mode-local-vars-hook #'+python-init-anaconda-mode-maybe-h)
  (remove-hook 'python-mode-hook #'+python-use-correct-flycheck-executables-h)

  (defvar lsp-bridge-running-window nil)
  (defvar lsp-bridge-running-eob-timer nil)

  (defun lsp-bridge-restart-process-try-eob ()
    (message "wait eob...")
    (if (and (window-live-p lsp-bridge-running-window)
             (equal (buffer-name (window-buffer lsp-bridge-running-window)) "*lsp-bridge*"))
        (when (> (with-current-buffer "*lsp-bridge*" (point-max))  100)
          (let ((sw (selected-window)))
            (select-window lsp-bridge-running-window)
            (recenter (- (max 1 scroll-margin)))
            (select-window sw))
          (acm-cancel-timer lsp-bridge-running-eob-timer))
      (acm-cancel-timer lsp-bridge-running-eob-timer)))

  (defun lsp-bridge-restart-process-after (&rest _)
    (when (window-live-p lsp-bridge-running-window)
      (set-window-buffer lsp-bridge-running-window (get-buffer "*lsp-bridge*"))
      (setq lsp-bridge-running-eob-timer
            (run-at-time 1 t #'lsp-bridge-restart-process-try-eob)))
    (delete-frame acm-menu-frame)
    (delete-frame acm-doc-frame))

  (advice-add #'lsp-bridge-restart-process
              :after #'lsp-bridge-restart-process-after)

  (advice-add #'lsp-bridge-restart-process
              :before #'(lambda (&rest _)
                          (setq lsp-bridge-running-window nil)
                          (dolist (window (window-list))
                            (when (equal (buffer-name (window-buffer window)) "*lsp-bridge*")
                              (setq lsp-bridge-running-window window)))))

  (use-package! acm
    :after lsp-bridge
    :config
    ;; bindings
    (define-key acm-mode-map (kbd "TAB") 'acm-select-next)
    (define-key acm-mode-map (kbd "S-TAB") 'acm-select-prev)
    (define-key acm-mode-map (kbd "C-n") 'acm-select-next)
    (define-key acm-mode-map (kbd "C-p") 'acm-select-prev)
    ;; fix: evil C-n C-p
    (define-key acm-mode-map [remap evil-complete-next] #'acm-select-next)
    (define-key acm-mode-map [remap evil-complete-previous] #'acm-select-prev)

    ;; beginning-of-defun in this function slow down the lsp-bridge
    (fset 'r-acm-in-string-p (symbol-function 'acm-in-string-p))
    (fset 'r-acm-in-comment-p (symbol-function 'acm-in-comment-p))
    (defun acm-in-string-p (&optional state)
      (if (eq major-mode 'python-mode)
          nil
        (r-acm-in-string-p)))
    (defun acm-in-comment-p (&optional state)
      (if (eq major-mode 'python-mode)
          nil
        (r-acm-in-comment-p))))

  (after! lookup
    ;; fix rtags find defination
    ;; (point-marker) cannot work with different buffer
    (defun +lookup--run-handlers (handler identifier origin)
      (doom-log "Looking up '%s' with '%s'" identifier handler)
      (condition-case-unless-debug e
          (let ((wconf (current-window-configuration))
                (window (selected-window))
                (result (condition-case-unless-debug e
                            (+lookup--run-handler handler identifier)
                          (error
                           (doom-log "Lookup handler %S threw an error: %s" handler e)
                           'fail))))
            (cond ((eq result 'fail)
                   (set-window-configuration wconf)
                   nil)
                  ((or (get handler '+lookup-async)
                       (eq result 'deferred)))
                  ((or result
                       (null origin)
                       (/= (point-marker) origin))
                   (prog1 (with-current-buffer (window-buffer window) (point-marker))
                     (set-window-configuration wconf)))))
        ((error user-error)
         (message "Lookup handler %S: %s" handler e)
         nil))))
  (map!
   (:leader
    :desc "workspace symbol"
    :n "s n" #'lsp-bridge-list-workspace-symbols)))

;; A few more useful configurations...
(after! emacs
  :init
  ;; TAB cycle if there are only few candidates
  (setq completion-cycle-threshold 3)
  (setq +lsp-company-backends nil)

  ;; Emacs 28: Hide commands in M-x which do not apply to the current mode.
  ;; Corfu commands are hidden, since they are not supposed to be used via M-x.
  ;; (setq read-extended-command-predicate
  ;;       #'command-completion-default-include-p)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (setq tab-always-indent 'complete))

;;; key binding

;;; enable in major mode below
;; (add-hook 'org-mode-hook
;;           #'(lambda()
              ;; (setq-local corfu-auto nil)
              ;;(setq-local acm-enable-english-helper t)
              ;;(setq lsp-bridge-enable-org-babe t)
              ;; (company-mode -1)
              ;; (lsp-bridge-mode)
              ;;(setq-local completion-at-point-functions (list  (cape-super-capf  #'cape-dict #'cape-dabbrev)))
              ;;(setq-local +lsp-company-backends '(company-capf company-dabbrev-code company-ispell :separate))
              ;; ))

(add-hook 'tex-mode-hook
          #'(lambda()
              (setq-local corfu-auto t)
              ;;(setq-local acm-enable-english-helper t)
              ;;(lsp-bridge-mode)
              (setq-local corfu-auto-delay 0.1)
              (setq-local completion-at-point-functions (list (cape-super-capf #'cape-dabbrev #'cape-tex #'cape-dict #'cape-file)))
              ;; (setq-local +lsp-company-backends '(company-capf company-dabbrev-code company-ispell :separate))
              ))

(add-hook 'emacs-lisp-mode-hook
          #'(lambda()
              (setq-local corfu-auto nil)

              (unless (string-match "\*org-src-fontification:" (buffer-name))
                (company-mode -1)
                (lsp-bridge-mode))))

(add-hook 'python-mode-hook
          #'(lambda()
              ;; remove lsp-bridge modeline
              (setq-local corfu-auto nil)
              (flycheck-mode -1)
              (setq-local lsp-bridge-enable-hover-diagnostic t)

              ;; highlight symbol
              (highlight-symbol-mode 1)

              (unless (string-match "\*org-src-fontification:" (buffer-name))
                (company-mode -1)
                (lsp-bridge-mode))
              (setq-local +lookup-definition-functions '(lsp-bridge-find-def t)
                          +lookup-implementations-functions '(lsp-bridge-find-impl t)
                          +lookup-references-functions '(lsp-bridge-find-references t))))

(add-hook 'c-mode-hook
          #'(lambda()
              (unless (string-match "\*org-src-fontification:" (buffer-name))
                (company-mode -1)
                (lsp-bridge-mode))
              (setq-local +lookup-definition-functions '(lsp-bridge-find-def t)
                          +lookup-implementations-functions '(lsp-bridge-find-impl t)
                          +lookup-references-functions '(lsp-bridge-find-references t))))

(add-hook 'ruby-mode-hook
          #'(lambda()
              (unless (string-match "\*org-src-fontification:" (buffer-name))
                (company-mode -1)
                (lsp-bridge-mode))
              (setq-local +lookup-definition-functions '(lsp-bridge-find-def t)
                          +lookup-implementations-functions '(lsp-bridge-find-impl t)
                          +lookup-references-functions '(lsp-bridge-find-references t))))

(provide 'init-lsp-bridge)
