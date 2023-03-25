;;; lisp/emacs/custom-consult-notes.el -*- lexical-binding: t; -*-

(require 'consult)
(require 'consult-notes)

(defvar custom/consult-notes--selected-file-path nil)
(defvar custom/consult-notes--preview-candidate t)

;;;###autoload
(defun custom/consult-notes--file-dir-source (name char dir)
  "Generate the notes source for each directory of files in `consult-notes-dir-sources'.

 Return a notes source list suitable for `consult--multi'.
NAME is the source name, CHAR is the narrowing character,
and DIR is the directory to find notes."
  `(:name     ,(propertize name 'face 'consult-notes-sep)
    :narrow   ,char
    :category ,consult-notes-category
    :face     consult-file
    :annotate ,(apply-partially consult-notes-file-dir-annotate-function name dir)
    :items    ,(lambda ()
                 (let* ((files (directory-files dir nil consult-notes-file-match)))
                   files))
    :state    ,(lambda ()
                 (let ((open (consult--temporary-files))
                       (state (consult--file-state)))
                   (lambda (action cand)
                     (if cand
                         (let ((file (and cand (concat (file-name-as-directory dir) cand))))
                           (and custom/consult-notes--preview-candidate (funcall state action file))
                           (setq custom/consult-notes--selected-file-path file))
                       (setq custom/consult-notes--selected-file-path nil)))))))

(defun custom/consult-notes--predicate (regex cand)
  (string-match-p regex cand))

;;;###autoload
(defun custom/consult-notes--selecting-file (&optional regex)
  "Selection a file in a notes directory with consult-multi, or from SOURCES.

Return a list contein file-path and user-input"
  (let ((buf (current-buffer))
        (sources (mapcar (lambda (s) (apply #'custom/consult-notes--file-dir-source s))
                         consult-notes-file-dir-sources))
        (file-dir-sources nil))
    (dolist (i sources) (add-to-list 'file-dir-sources i))
    (let* ((sources (consult--multi-enabled-sources file-dir-sources))
           (candidates (consult--with-increased-gc
                        (consult--multi-candidates file-dir-sources)))
           (selected (apply #'consult--read
                            candidates

                            (list
                             :prompt "Notes: "
                             :require-match (confirm-nonexistent-file-or-buffer)
                             :category    'multi-category
                             :predicate   (if regex (apply-partially #'custom/consult-notes--predicate regex)
                                            (apply-partially #'consult--multi-predicate sources))
                             :annotate    (apply-partially #'consult--multi-annotate sources)
                             :group       (apply-partially #'consult--multi-group sources)
                             :lookup      (apply-partially #'consult--multi-lookup sources)
                             :preview-key (consult--multi-preview-key sources)
                             :narrow      (consult--multi-narrow sources)
                             :state       (consult--multi-state sources)))))
      (consult--buffer-action buf)
      (list custom/consult-notes--selected-file-path (car selected)))))

(provide 'custom-consult-notes)
