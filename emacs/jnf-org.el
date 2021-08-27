;;; jnf-org.el --- Summary
;;; -*- lexical-binding: t; -*-
;;
;;; Commentary:
;;
;;  This package provides configuration for org-roam
;;
;;; Code:
;; ;; Consider https://github.com/jkitchin/org-ref as well

(cl-defun jnf/org-agenda-files (&key paths basenames)
  "Return the list of filenames where BASENAMES exists in PATHS."
  (setq returning-list '())
  (dolist (path paths)
    (dolist (basename basenames)
      (if (f-exists-p (f-join path basename))
          (add-to-list 'returning-list (f-join path basename)))))
  returning-list)

(use-package org
  :straight t
  :config (setq
           org-directory "~/git/org"
           org-agenda-files (jnf/org-agenda-files
                             :paths jnf/data-directories
                             :basenames '("agenda.org" "todo.org"))
           org-default-notes-file (concat org-directory "/captured-notes.org")
           org-todo-keywords
           '((sequence "TODO" "WAITING" "|" "DONE")
             (sequence "MEETING" "AGENDA" "|" "MINUTES")
             (sequence "UNFILED" "|" "FILED")
             (sequence "TO-READ" "READING" "|" "READ")))
  (setq org-capture-templates
        '(
          ("e" "Emacs Config Todo" entry (file "~/git/jnf-emacs-config/todo.org")
           "* TODO %?" :empty-lines-before 1)
          ("h" "Hesburgh Libraries Todo" entry (file "~/git/org/hesburgh-libraries/todo.org")
           "* TODO %?" :empty-lines-before 1)
          ("t" "Thel Sector Todo" entry (file "~/git/org/personal/thel-sector/todo.org")
           "* TODO %?" :empty-lines-before 1)
          ("p" "Personal Todo" entry (file "~/git/org/personal/todo.org")
           "* TODO %?" :empty-lines-before 1)
          ("u" "Public Todo" entry (file "~/git/org/public/todo.org")
           "* TODO %?" :empty-lines-before 1)
          ))
  (defun my-org-confirm-babel-evaluate (lang body) t)

  (defun org-files-names-in-project-list ()
  "Return a list of filenames in the current files directory."
  (split-string-and-unquote
   (shell-command-to-string
    (concat
     "ls " (file-name-directory buffer-file-name)))))

  (setq org-confirm-babel-evaluate #'my-org-confirm-babel-evaluate)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (plantuml . t)
     (ruby . t)))
  :bind (
         ("C-c l" . org-store-link)
         ("C-c a" . org-agenda)
         ("C-c c" . org-capture)
         ("C-s-t" . org-toggle-link-display)))

(use-package org-sidebar
  :straight (org-sidebar :type git
                         :host github
                         :repo "alphapapa/org-sidebar"))

;; Uncomment to always launch org mode with a sidebar tree
;; (add-hook 'org-mode-hook #'org-sidebar-tree)


;; To make Org mode take care of versioning of attachments for you,
;; add the following to your Emacs config:
;;
(require 'org-attach-git)

;; https://github.com/alphapapa/unpackaged.el#download-and-attach-remote-files
;;;###autoload
(defun unpackaged/org-attach-download (url)
  "Download file at URL and attach with `org-attach'.
Interactively, look for URL at point, in X clipboard, and in
`kill-ring', prompting if not found.  With prefix, prompt for URL."
  (interactive (list (if current-prefix-arg
                         (read-string "URL: ")
                       (or (org-element-property :raw-link (org-element-context))
                           (org-web-tools--get-first-url)
                           (read-string "URL: ")))))
  (when (yes-or-no-p (concat "Attach file at URL: " url))
    (let* ((temp-dir (make-temp-file "org-attach-download-" 'dir))
           (basename (file-name-nondirectory (directory-file-name url)))
           (local-path (expand-file-name basename temp-dir))
           size)
      (unwind-protect
          (progn
            (url-copy-file url local-path 'ok-if-exists 'keep-time)
            (setq size (file-size-human-readable
                        (file-attribute-size
                         (file-attributes local-path))))
            (org-attach-attach local-path nil 'mv)
            (message "Attached %s (%s)" url size))
        (delete-directory temp-dir)))))

;; https://github.com/alphapapa/unpackaged.el#ensure-blank-lines-between-headings-and-before-contents
;;;###autoload
(defun unpackaged/org-fix-blank-lines (&optional prefix)
  "Ensure blank lines exist between headings and content.

With PREFIX, operate on whole buffer.  Ensures that blank lines
exist after each headings's drawers."
  (interactive "P")
  (org-map-entries (lambda ()
                     (org-with-wide-buffer
                      ;; `org-map-entries' narrows the buffer, which prevents us from seeing
                      ;; newlines before the current heading, so we do this part widened.
                      (while (not (looking-back "\n\n" nil))
                        ;; Insert blank lines before heading.
                        (insert "\n")))
                     (let ((end (org-entry-end-position)))
                       ;; Insert blank lines before entry content
                       (forward-line)
                       (while (and (org-at-planning-p)
                                   (< (point) (point-max)))
                         ;; Skip planning lines
                         (forward-line))
                       (while (re-search-forward org-drawer-regexp end t)
                         ;; Skip drawers. You might think that `org-at-drawer-p' would suffice, but
                         ;; for some reason it doesn't work correctly when operating on hidden text.
                         ;; This works, taken from `org-agenda-get-some-entry-text'.
                         (re-search-forward "^[ \t]*:END:.*\n?" end t)
                         (goto-char (match-end 0)))
                       (unless (or (= (point) (point-max))
                                   (org-at-heading-p)
                                   (looking-at-p "\n"))
                         (insert "\n"))))
                   t (if prefix
                         nil
                       'tree)))

(use-package org-superstar
  :straight t
  :hook ((org-mode . org-superstar-mode)
         (org-mode . turn-on-visual-line-mode)))

;; See
;; https://www.reddit.com/r/orgmode/comments/i6hl8b/image_preview_size_in_org_mode/
;; for further discussion
;;
;; One consideration is that the below setq should be called as part
;; of the `org-toggle-inline-images`.  <2020-11-14 Sat 12:09>: I
;; commented out the lines below as it created a very small image
;; (about the size of one character).  (setq org-image-actual-width
;; (truncate (* (window-pixel-width) 0.8)))


;; I'd prefer to use the executable, but that doe not appear to be the
;; implementation of org-babel.
(setq org-plantuml-jar-path (concat (string-trim (shell-command-to-string "brew-path plantuml")) "/libexec/plantuml.jar"))

;; Insert immediate timestamp at point.
(defun jnf/org-insert-immediate-active-timestamp ()
  "Insert an active timestamp for the current time."
  (interactive)
  (org-insert-time-stamp nil t nil))
(global-set-key (kbd "<f2>") 'jnf/org-insert-immediate-active-timestamp)
(global-set-key (kbd "s-2") 'jnf/org-insert-immediate-active-timestamp)

;; For some reason, when I load emacs in daemon mode, the daemon
;; process is the process now renders the GET prompts for the
;; mini-buffer.  When I load the file interactively, I don't
;; experience the same problem.  So, until this resolves, I'll need to
;; load roam via an interactive command.
;; (global-set-key (kbd "<f10>") `(lambda ()
;;                                 (interactive)
;;                                 (require 'jnf-org-roam.el)
;;                                 ))

(require 'jnf-org-roam-v2.el)

(use-package org-bookmark-heading
  :straight t)

;; A package to assist in handling annotations; I wish that DocView
;; better rendered the PDF.  It's a little too pixelated.
(use-package org-noter
  :straight t
  ;; Favor two-thirds of the screen for the PDF and one-third for the
  ;; org notes.
  :init (setq org-noter-doc-split-fraction '(0.7 . 0.3))
  :bind (
         :map org-noter-notes-mode-map ("C-c o" . 'org-noter-sync-current-note)))

(provide 'jnf-org.el)
;;; jnf-org.el ends here
