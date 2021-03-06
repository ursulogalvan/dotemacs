;;; jnf-company.el --- Summary
;;
;;; Commentary:
;;
;;  Extracting company usage
;;
;;; Code:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package company
  :straight t
  :commands (company company-global-mode company-mode)
  :diminish
  :bind ((:map company-active-map (("<tab>" . 'company-complete-selection ))))
  :hook (prog-mode . company-mode)
        (org-mode . company-mode)
  :custom
  (company-dabbrev-downcase nil "Don't downcase returned candidates.")
  (company-show-numbers t)
  (company-tooltip-limit 10)
  (company-minimum-prefix-length 3)
  ;; Slow down the tooltip pop-up.  At 0.2 seconds it's really bad in
  ;; a large Ruby project.
  (company-tooltip-idle-delay 0.5)
  (company-async-timeout 20 "Some requests can take a long time. That's fine.")
  :config

  (add-to-list 'company-backends 'company-capf)
  ;; Use the numbers 0-9 to select company completion candidates
  (let ((map company-active-map))
    (mapc (lambda (x) (define-key map (format "%d" x)
                        `(lambda () (interactive) (company-complete-number ,x))))
          (number-sequence 0 9)))
  )

;; In auto-complete, display any associated help with the completion options.
(use-package company-quickhelp
  :straight t
  :bind (:map company-active-map ("C-c h" . 'company-quickhelp-manual-begin))
  :config (company-quickhelp-mode))

(provide 'jnf-company.el)
;;; jnf-company.el ends here
