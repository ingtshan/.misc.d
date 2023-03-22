;;; lisp/emacs/custom-borg.el -*- lexical-binding: t; -*-

;;;###autoload
(defun custom-borg-straight-worktree (package-repo-name)
  "Return load-path of package installed by straight or straight build path.

Since straight in doom build out all the package in .local/stragith/build-XXX/package-name
But complier can't find it when we beyte-compile file"
  (let* ((straight-build-path (file-name-concat
                              (file-name-directory (directory-file-name user-emacs-directory))
                              (format "straight/build-%s" emacs-version)))
         (worktree (file-name-concat straight-build-path package-repo-name)))
    (unless (file-directory-p straight-build-path)
      (error (concat "Can't find straight build in " straight-build-path)))
    (unless (file-directory-p worktree)
      (error (concat "Can't find worktre of " worktree)))
    worktree))

(provide 'custom-borg)
