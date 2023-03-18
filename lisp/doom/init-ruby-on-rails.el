;;; lib/misc/lisp/doom/init-ruby-on-rails.el -*- lexical-binding: t; -*-

;; <quickleader>: SPC v  ; shortut for useful commands
(after! projectile-rails
  ;; bug I don't know
  ;; (map! :map projectile-rails-mode-map
  ;;       "SPC r" #'projectile-rails-command-map))
  (general-define-key :states '(normal visual emacs) ; '(normal visual insert emacs)
                      :keymaps 'projectile-rails-mode-map
                      "SPC v" #'projectile-rails-command-map)
  ;;; improve
  ;;
  (defun custom/doom-emacs-on-rails-add-custom-projectile-finder (name folder file-pattern pattern map key)
    (fset (intern (concat "projectile-rails-custom-find-" name))
          (eval `
           (lambda ()
             (interactive)
             (projectile-rails-find-resource
              (concat ,name ": ")
              '((,folder ,file-pattern))
              ,pattern))))
    (define-key map (kbd key) (intern (concat "projectile-rails-custom-find-" name))))

  (defvar custom/projectile-rails-mode-search-file-map
    (let ((map (make-sparse-keymap)))
      ;; add more here
      (define-key map (kbd "c") 'projectile-rails-find-stylesheet)
      map)
    "A goto map for `projectile-rails-mode'.")
  (fset 'custom/projectile-rails-mode-search-file-map custom/projectile-rails-mode-search-file-map)

  ;; add more custom here
  (custom/doom-emacs-on-rails-add-custom-projectile-finder
   "services" "app/services/"  "\\(.+\\)\\.rb$" "app/services/${filename}.rb"
   custom/projectile-rails-mode-search-file-map "s")

  (define-key projectile-rails-command-map (kbd "s") 'custom/projectile-rails-mode-search-file-map))

(after! slim-mode (add-hook 'slim-mode-hook #'projectile-rails-mode 'append))
(after! rjsx-mode (add-hook 'rjsx-mode-hook #'projectile-rails-mode 'append))
;; I make mistake here (after! scss-mode (`neve execute because of css-mode instead of scss-mode') )
(after! css-mode (add-hook 'scss-mode-hook #'projectile-rails-mode 'append))

;; (dolist (mode '("slim-mode" "rjsx-mode" "scss-mode"))
;;   (after! (intern mode) (add-hook (intern (concat "slim-mode" "-hook")) #'projectile-rails-mode)))

;; (defvar projectile-rails-command-map
;;   (let ((map (make-sparse-keymap)))
;;     (define-key map (kbd "m") 'projectile-rails-find-model)
;;     (define-key map (kbd "M") 'projectile-rails-find-current-model)

;;     (define-key map (kbd "c") 'projectile-rails-find-controller)
;;     (define-key map (kbd "C") 'projectile-rails-find-current-controller)

;;     (define-key map (kbd "v") 'projectile-rails-find-view)
;;     (define-key map (kbd "V") 'projectile-rails-find-current-view)

;;     (define-key map (kbd "j") 'projectile-rails-find-javascript)
;;     (define-key map (kbd "J") 'projectile-rails-find-current-javascript)

;;     (define-key map (kbd "s") 'projectile-rails-find-stylesheet)
;;     (define-key map (kbd "S") 'projectile-rails-find-current-stylesheet)

;;     (define-key map (kbd "h") 'projectile-rails-find-helper)
;;     (define-key map (kbd "H") 'projectile-rails-find-current-helper)

;;     (define-key map (kbd "p") 'projectile-rails-find-spec)
;;     (define-key map (kbd "P") 'projectile-rails-find-current-spec)

;;     (define-key map (kbd "t") 'projectile-rails-find-test)
;;     (define-key map (kbd "T") 'projectile-rails-find-current-test)

;;     (define-key map (kbd "n") 'projectile-rails-find-migration)
;;     (define-key map (kbd "N") 'projectile-rails-find-current-migration)

;;     (define-key map (kbd "r") 'projectile-rails-console)
;;     (define-key map (kbd "R") 'projectile-rails-server)

;;     (define-key map (kbd "u") 'projectile-rails-find-fixture)
;;     (define-key map (kbd "U") 'projectile-rails-find-current-fixture)

;;     (define-key map (kbd "w") 'projectile-rails-find-component)

;;     (define-key map (kbd "l") 'projectile-rails-find-lib)
;;     (define-key map (kbd "f") 'projectile-rails-find-feature)
;;     (define-key map (kbd "i") 'projectile-rails-find-initializer)
;;     (define-key map (kbd "o") 'projectile-rails-find-log)
;;     (define-key map (kbd "e") 'projectile-rails-find-environment)
;;     (define-key map (kbd "W") 'projectile-rails-find-webpack)
;;     (define-key map (kbd "a") 'projectile-rails-find-locale)
;;     (define-key map (kbd "@") 'projectile-rails-find-mailer)
;;     (define-key map (kbd "!") 'projectile-rails-find-validator)
;;     (define-key map (kbd "y") 'projectile-rails-find-layout)
;;     (define-key map (kbd "k") 'projectile-rails-find-rake-task)
;;     (define-key map (kbd "b") 'projectile-rails-find-job)

;;     (define-key map (kbd "z") 'projectile-rails-find-serializer)
;;     (define-key map (kbd "Z") 'projectile-rails-find-current-serializer)
;;     ;; (define-key map (kbd "?") 'projectile-rails-find-validator)

;;     (define-key map (kbd "x") 'projectile-rails-extract-region)
;;     (define-key map (kbd "RET") 'projectile-rails-goto-file-at-point)

;;     (define-key map (kbd "g") 'projectile-rails-mode-goto-map)
;;     (define-key map (kbd "!") 'projectile-rails-mode-run-map)
;;     map)
;;   "Keymap after `projectile-rails-keymap-prefix'.")
;; (fset 'projectile-rails-command-map projectile-rails-command-map)

(provide 'init-ruby-on-rails)
