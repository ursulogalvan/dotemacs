;;; jnf-in-buffer.el --- Summary
;;
;;; Commentary:
;;
;;  Packages that greatly assist with in-buffer editing:
;;
;;  * navigation
;;  * case manipulation
;;  * region highlighting (or compression)
;;
;;  As I've spent time thinking about this, it's hard to separate.
;;  But there's some kind of logic.  Namely, I'm operating only on
;;  this buffer.  Not navigating between buffers.
;;
;;; Code:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;******************************************************************************
;;
;;; BEGIN Use External Packages
;;
;;******************************************************************************
;; Write "kill" command inputs to disk
(use-package savekill
  :straight t)

;; That letter is the beginning of a word. Narrow results from there.
(use-package avy
  :bind (("C-j" . avy-goto-char-timer))
  :bind (:map enh-ruby-mode-map ("C-j" . avy-goto-char-timer))
  :bind (:map org-mode-map ("C-j" . avy-goto-char-timer))
  :straight t)

(use-package link-hint
  :straight t
  :bind
  ("C-c l o" . link-hint-open-link)
  ("C-c l c" . link-hint-copy-link))

;; https://github.com/shankar2k/math-at-point
(use-package math-at-point
  :straight (math-at-point :type git :host github :repo "shankar2k/math-at-point")
  :bind ("C-c =" . math-at-point))

(use-package which-key
  :config (which-key-mode)
  :diminish 'which-key-mode
  :straight t)

(use-package writeroom-mode
  :straight t)

(use-package vi-tilde-fringe
  :straight t
  :hook ((fundamental-mode) . vi-tilde-fringe-mode))

;; I don't use a lot of folding, this allows me to type C-RET and fold
;; the current block.  There's more it can do but for now that's
;; enough
(use-package yafolding
  :straight t
  :hook (prog-mode . yafolding-mode))

;; Using Hippie expand, I toggle through words already referenced.
(use-package hippie-exp
  :straight t
  :config
  (setq hippie-expand-try-functions-list '(try-expand-dabbrev-visible
                                           try-expand-dabbrev
                                           try-expand-list
                                           try-expand-all-abbrevs
                                           try-expand-dabbrev-all-buffers
                                           try-expand-dabbrev-from-kill
                                           try-complete-file-name-partially
                                           try-complete-file-name
                                           try-complete-lisp-symbol-partially
                                           try-complete-lisp-symbol
                                           ))
  :bind (("M-SPC" . hippie-expand)))

;; Expand or contract point/region to next logical element.
;;
;; NOTE: I use this all the time.
(use-package expand-region
  :straight t
  :bind (("C-=" . er/expand-region)
         ("C-+" . er/contract-region)))

;; This package allows me to toggle between different string cases.
;;
;; - HELLO WORLD
;; - HelloWorld
;; - helloWorld
;; - hello-world
;; - Hello_World
;; - hellow_world
;; - HELLO_WORLD
(use-package string-inflection
  :bind (("C-M-s-i" . string-inflection-all-cycle))
  :straight (string-inflection :type git
                               :host github
                               :repo "akicho8/string-inflection"))

;; Allow to work with multipe cursors
;; https://melpa.org/#/multiple-cursors Aside from the
;; set-rectangular-region-anchor, there are several additional
;; features to practice
(use-package multiple-cursors
  :bind (("C-M-SPC" . set-rectangular-region-anchor)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-s-<mouse-1>" . mc/add-cursor-on-click)
         ("C-c C->" . mc/mark-all-like-this)
         ("C-c C-SPC" . mc/edit-lines)) ;; CTRL+CMD+c
  :straight t)

;; C-; to select current symbol and all matches; Then edit at multiple points.
(use-package iedit
  :straight t)

;; Not quite sexp navigation, but something alternative.  For vertical
;; movement, it looks at an empty line and moves there.  For
;; horizontal movement, moves between two spaces.
(use-package spatial-navigate
  :straight (spatial-navigate :type git
                              :host gitlab
                              :repo "ideasman42/emacs-spatial-navigate")
  :bind (("<M-s-up>" . #'spatial-navigate-backward-vertical-bar)
         ("<M-s-down>" . #'spatial-navigate-forward-vertical-bar)
         ("<M-s-left>" . #'spatial-navigate-backward-horizontal-bar)
         ("<M-s-right>" . #'spatial-navigate-forward-horizontal-bar)))

;; C-a goes to the first non-whitepsace character on the line. Type it
;; again, and go to the beginning of the line.

(use-package crux
  :straight t
  :config
  (defun jnf/duplicate-current-line-or-lines-of-region (arg)
  "Duplicate ARG times current line or the lines of the current region."
  (interactive "p")
  (if (use-region-p)
      (progn
        (when (> (point) (mark))
          (exchange-point-and-mark))
        (beginning-of-line)
        (exchange-point-and-mark)
        (end-of-line)
        (goto-char (+ (point) 1))
        (exchange-point-and-mark)
        (let* ((end (mark))
               (beg (point))
               (region
                (buffer-substring-no-properties beg end)))
          (dotimes (_i arg)
            (goto-char end)
            (insert region)
            (setq end (point)))))
    (crux-duplicate-current-line-or-region arg)))

  (cl-defun jnf/create-org-scratch-buffer (&key (mode 'org-mode))
    "Quickly open a scratch buffer and enable the given MODE."
    (interactive)
    (crux-create-scratch-buffer)
    (rename-buffer (concat "*scratch* at " (format-time-string "%Y-%m-%d %H:%M")))
    (funcall mode))
  :bind (("C-a" . crux-move-beginning-of-line)
         ("<C-s-return>" . crux-smart-open-line-above)
         ("C-s-k" . crux-kill-line-backwards)
         ("<s-backspace>" . crux-kill-line-backwards)
         ("C-M-d" . jnf/duplicate-current-line-or-lines-of-region)
         ("C-c d" . jnf/duplicate-current-line-or-lines-of-region)
         ("<f9>" . crux-kill-other-buffers)
         ("<f12>" . jnf/create-org-scratch-buffer)))

;; Whitespace hygene package.  The author's documentation and
;; commentary echoes my sentiments
(use-package ethan-wspace
  :straight t
  :hook (before-save . delete-trailing-whitespace)
  :init (setq-default mode-require-final-newline nil)
  :config (global-ethan-wspace-mode 1))

;; A package that is a bit of the inverse of 'fill-paragraph
;; (e.g. M-q).
(use-package unfill
  :bind ("M-q" . unfill-toggle)
  :straight t)

;; Provides a UI for undo trees.  I'm not certain what I want to do
;; with this.
(use-package undo-tree
  :diminish
  :bind (("C-z" . undo)
         ("C-S-z" . undo-tree-redo))
  :config
  (global-undo-tree-mode +1)
  (unbind-key "M-_" undo-tree-map))

;; Delete multiple spaces in one delete stroke
(use-package hungry-delete
  :straight t
  :diminish 'hungry-delete-mode
  :config (global-hungry-delete-mode))

;; Adding ability to move lines up and down
(use-package move-text
  :straight t
  :bind (([C-s-down] . move-text-down)
         ([C-s-up] . move-text-up)))

;; A quick and useful visual queue for paranthesis
(use-package rainbow-delimiters
  :straight t
  :hook ((prog-mode text-mode org-mode) . rainbow-delimiters-mode))

(use-package emojify
  :straight t
  :config
  (defun --set-emoji-font (frame)
    "Adjust the font settings of FRAME so Emacs can display emoji properly."
    (if (eq system-type 'darwin)
        ;; For NS/Cocoa
        (set-fontset-font t 'symbol (font-spec :family "Apple Color Emoji") frame 'prepend)
      ;; For Linux
      (set-fontset-font t 'symbol (font-spec :family "Symbola") frame 'prepend)))

  ;; For when Emacs is started in GUI mode:
  (--set-emoji-font nil)
  ;; Hook for when a frame is created with emacsclient
  ;; see https://www.gnu.org/software/emacs/manual/html_node/elisp/Creating-Frames.html
  (add-hook 'after-make-frame-functions '--set-emoji-font))

(use-package unicode-fonts
  :straight t
  :ensure t
  :config (unicode-fonts-setup))

;; A rather convenient snippet manager.  When you create a snippet, it
;; understands the mode you're in and puts the snippet in the right
;; place.
(use-package yasnippet
  :straight t
  :diminish yas-mode
  :init (setq yas-snippet-dirs '("~/git/dotemacs/snippets"))
  (yas-global-mode 1))

;; I kind of like this little bit of visual feedback
(use-package goggles
  :straight t
  :hook ((prog-mode text-mode) . goggles-mode)
  :diminish 'goggles-mode
  :config
  (setq-default goggles-pulse t)) ;; set to nil to disable pulsing

(use-package whole-line-or-region
  :straight t
  :diminish 'whole-line-or-region-local-mode
  :config (whole-line-or-region-global-mode))

(use-package smartparens
  :straight t)
;;******************************************************************************
;;
;;; END Use External Packages
;;
;;******************************************************************************

;;******************************************************************************
;;
;;; BEGIN Custom "in-buffer" functions
;;
;;******************************************************************************
(global-set-key (kbd "C-w") 'jnf/kill-region-or-backward-word)
(global-set-key (kbd "M-DEL") 'jnf/kill-region-or-backward-word)
(global-set-key (kbd "<C-M-backspace>") 'backward-kill-paragraph)
(defun jnf/kill-region-or-backward-word (&optional arg)
  "Kill selected region otherwise kill backwards the ARG number of words."
  (interactive "p")
  (if (region-active-p)
      (kill-region (region-beginning) (region-end))
    (backward-kill-word arg)))

(global-set-key (kbd "C-k") 'jnf/kill-line-or-region)
(defun jnf/kill-line-or-region (&optional ARG)
  "Kill the selected region otherwise kill the ARG number of lines."
  (interactive "P")
  (if (use-region-p)
      (kill-region (region-beginning) (region-end))
    (kill-line ARG)))

(global-set-key (kbd "C-c n") 'jnf/nab-file-name-to-clipboard)
(defun jnf/nab-file-name-to-clipboard ()
  "Nab, I mean copy, the current buffer file name to the clipboard.

If you provide universal prefix (e.g. C-u), return the base
filename.  Otherwise, use the full filename path."
  ;; https://blog.sumtypeofway.com/posts/emacs-config.html
  (interactive)
  (let* ((raw-filename
          (if (equal major-mode 'dired-mode) default-directory (buffer-file-name)))
         (filename
          (if (equal current-prefix-arg nil) raw-filename (file-name-nondirectory raw-filename))))
    (when filename
      (kill-new filename)
      (message "Copied buffer file name '%s' to the clipboard." filename))))

(defun jnf/sort-unique-lines (reverse beg end &optional adjacent keep-blanks interactive)
  "Sort lines and delete duplicates.
By default the sort is lexigraphically ascending.  To sort as
descending set REVERSE to non-nil.  Specify BEG and END for the
bounds of sorting.  By default, this is the selected region.

I've included ADJACENT, KEEP-BLANKS, and INTERACTIVE so I can
echo the method signature of `'delete-duplicate-lines`"
;; This is a common function that I've used in other text editors.
;; It's a simple stitch together of sort-lines and
;; delete-duplicate-lines.
  (interactive "P\nr")
  (sort-lines reverse beg end)
  (delete-duplicate-lines beg end reverse adjacent keep-blanks interactive))

(global-set-key (kbd "<f5>") 'eval-region)
(global-set-key (kbd "s-q") 'save-buffers-kill-terminal)
(global-set-key (kbd "s-w") 'kill-current-buffer)

;; Treat dashes and underscores as part of words for navigation
;; (global-superword-mode t)

(global-set-key (kbd "C-s-\\") 'jnf/display-buffer-in-side-window)
(cl-defun jnf/display-buffer-in-side-window (&optional (buffer (current-buffer)))
  "Display BUFFER in dedicated side window."
  (interactive)
  (let ((display-buffer-mark-dedicated t))
    (display-buffer-in-side-window buffer
                                   '((side . right)
                                     (window-parameters
                                      (no-delete-other-windows . t))))))

(global-set-key (kbd "C-s--") 'jnf/display-buffer-in-bottom-window)
(cl-defun jnf/display-buffer-in-bottom-window (&optional (buffer (current-buffer)))
  "Display BUFFER in dedicated side window."
  (interactive)
  (let ((display-buffer-mark-dedicated t))
    (display-buffer-in-side-window buffer
                                   '((side . bottom)
                                     (window-parameters
                                      (no-delete-other-windows . t))))))

;; I'm a little uncertain how to handle this.
;; https://depp.brause.cc/shackle/
(use-package shackle
  :straight t
  :custom
  (shackle-rules '((compilation-mode :noselect t))
                 shackle-default-rule '(:select t)))

;;******************************************************************************
;;
;;; END Custom "in-buffer" functions
;;
;;******************************************************************************


(provide 'jnf-in-buffer.el)
;;; jnf-in-buffer.el ends here
