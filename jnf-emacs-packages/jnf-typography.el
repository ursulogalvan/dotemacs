;;; -*- lexical-binding: t; -*-
;;; jnf-typography.el --- Summary
;;
;;; Commentary:
;;
;;  This package serves the purpose of assisting with adding
;;  characters that are not readily available on an ANSI keyboard.
;;
;;; Code:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; BEGIN Typography Menu
;;
;;  The purpose of the typography menu is to provide easier access to
;;  typographic characters that I use; It also provides a bit of a
;;  mnemonic device (e.g. "C-x 8 RET" searches for a character to insert).
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar jnf/typography--title
  (with-octicon "pencil" "Typography (C-x 8 RET for Search)" 1 -0.05)
  "The menu title for typography")
(pretty-hydra-define jnf/typography--menu (:foreign-keys warn :title jnf/typography--title :quit-key "q" :exit t)
  ("Characters" (
                 ("d d" (insert "-") "- dash")
                 ("d m" (insert "—") "— em dash")
                 ("d n" (insert "–") "– en dash")
                 (". e" (insert "…") "… ellipsis")
                 (". d" (insert "·") "º degree")
                 (". m" (insert "·") "· middot")
                 ("t d" (insert "†") "† dagger")
                 ("t 2" (insert "‡") "‡ double dagger")
                 ("t s" (insert "§") "§ section")
                 ("t p" (insert "¶") "¶ paragraph")
                 ("? !" (insert "‽") "‽ Interobang")
                 )
   "Math" (
           ("a x" (insert "×") "× Multiplication Sign")
           ("a d" (insert "÷") "÷ Division Sign")
           ("a m" (insert "−") "− Minus Sign")
           ("a p" (insert "±") "± Plus or Minus Sign")
           ("m n" (insert "¬") "¬ Negation")
           ;; Included as a reminder as I use these for menu structures
           ("f h" (insert "─") "─ Forms light horizontal")
           ("f D l" (insert "┐") "┐ Forms light down and left")
           ("f v" (insert "│") "  │ Forms light vertical")
           ("f V r" (insert "├") "├ Forms light vertical and right")
           ("f U r" (insert "└") "└ Forms light up and right")
           )
   "Quotes" (
             ("\" o" (insert "“") "“ Double quote open")
             ("\" c" (insert "”") "” Doule quote close")
             ("\" O" (insert "«") "« Guillemet open")
             ("\" C" (insert "»") "» Guillemet close")
             ("' o" (insert "‘") "‘ Single quote open")
             ("' c" (insert "’") "’ Single quote close")
             ("' O" (insert "‹") "‹ Single guillemet open")
             ("' C" (insert "›") "› Single guillemet close")
             ("p 1" (insert "′") "′ Single Prime (feet, arcminutes)")
             ("p 2" (insert "″") "″ Double Prime (inches, arcseconds)")
             ("p 3" (insert "‴") "‴ Triple Prime"))
   ))

(global-set-key (kbd "C-s-8") 'jnf/typography--menu/body)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; END Typography Menu
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; BEGIN Typopunct
;;
;; This package comes
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package typopunct
  :straight t
  :config
  (add-hook 'org-mode-hook 'jnf/typopunct-init)
  (defun jnf/typopunct-init ()
    (require 'typopunct)
    (typopunct-change-language 'english)
    (typopunct-mode 1))
  (setq typopunct-buffer-language 'english)

  ;; To insert a typographical ellipsis sign (…) on three consecutive
  ;; dots, or a middle dot (·) on ‘^.’
  (defconst typopunct-ellipsis (decode-char 'ucs #x2026))
  (defconst typopunct-middot   (decode-char 'ucs #xB7)) ; or 2219
  (defun typopunct-insert-ellipsis-or-middot (arg)
    "Change three consecutive dots to a typographical ellipsis mark."
    (interactive "p")
    (cond
     ((and (= 1 arg)
           (eq (char-before) ?^))
      (delete-char -1)
      (insert typopunct-middot))
     ((and (= 1 arg)
           (eq this-command last-command)
           (looking-back "\\.\\." 1))
      (replace-match "")
      (insert typopunct-ellipsis))
     (t
      (self-insert-command arg))))
  (define-key typopunct-map "." 'typopunct-insert-ellipsis-or-middot)


  (defconst typopunct-prime  (decode-char 'ucs #x2032)) ; feet, arcminutes, derivatives
  (defconst typopunct-dprime (decode-char 'ucs #x2033)) ; inches, arcseconds, double derivatives
  (defconst typopunct-tprime (decode-char 'ucs #x2034))

  ;; The minus sign (−) is separate from the hyphen (-), en dash (–) and
  ;; em dash (—). To build upon the clever behavior of the ‘-’ key
  (defconst typopunct-minus (decode-char 'ucs #x2212))
  (defconst typopunct-pm    (decode-char 'ucs #xB1))
  (defconst typopunct-mp    (decode-char 'ucs #x2213))
  (defadvice typopunct-insert-typographical-dashes
      (around minus-or-pm activate)
    (cond
     ((or (eq (char-before) typopunct-em-dash)
          (looking-back "\\([[:blank:]]\\|^\\)\\^" 2))
      (delete-char -1)
      (insert typopunct-minus))
     ((looking-back "[^[:blank:]]\\^" 1)
      (insert typopunct-minus))
     ((looking-back "+/" 1)
      (progn (replace-match "")
             (insert typopunct-pm)))
     (t ad-do-it)))
  (defun typopunct-insert-mp (arg)
    (interactive "p")
    (if (and (= 1 arg) (looking-back "-/" 2))
        (progn (replace-match "")
               (insert typopunct-mp))
      (self-insert-command arg)))
  (define-key typopunct-map "+" 'typopunct-insert-mp)
  (defconst typopunct-times (decode-char 'ucs #xD7))
  (defun typopunct-insert-times (arg)
    "Insert multiplication sign at ARG."
    (interactive "p")
    (if (and (= 1 arg) (looking-back "\\([[:blank:]]\\|^\\)\\^"))
        (progn (delete-char -1)
               (insert typopunct-times))
      (self-insert-command arg)))
  (define-key typopunct-map "x" 'typopunct-insert-times)

  (defadvice typopunct-insert-quotation-mark (around wrap-region activate)
    (let* ((lang (or (get-text-property (point) 'typopunct-language)
                     typopunct-buffer-language))
           (omark (if single
                      (typopunct-opening-single-quotation-mark lang)
                    (typopunct-opening-quotation-mark lang)))
           (qmark (if single
                      (typopunct-closing-single-quotation-mark lang)
                    (typopunct-closing-quotation-mark lang))))
      (cond
       (mark-active
        (let ((skeleton-end-newline nil)
              (singleo (typopunct-opening-single-quotation-mark lang))
              (singleq (typopunct-closing-single-quotation-mark lang)))
          (if (> (point) (mark))
              (exchange-point-and-mark))
          (save-excursion
            (while (re-search-forward (regexp-quote (string omark)) (mark) t)
              (replace-match (regexp-quote (string singleo)) nil nil)))
          (save-excursion
            (while (re-search-forward (regexp-quote (string qmark)) (mark) t)
              (replace-match (regexp-quote (string singleq)) nil nil)))
          (skeleton-insert (list nil omark '_ qmark) -1)))
       ((looking-at (regexp-opt (list (string omark) (string qmark))))
        (forward-char 1))
       (t ad-do-it)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; END typopunct
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(provide 'jnf-typography.el)
;;; jnf-typography.el ends here
