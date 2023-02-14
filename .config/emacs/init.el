(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(LaTeX-mode-hook
   '(preview-mode-setup auto-fill-mode TeX-source-correlate-mode) t)
 '(TeX-auto-save t)
 '(TeX-source-correlate-mode t)
 '(TeX-source-correlate-start-server t)
 '(TeX-view-program-selection '((output-pdf "Zathura")))
 '(custom-enabled-themes nil)
 '(default-input-method "german-postfix")
 '(elpy-rpc-virtualenv-path 'system)
 '(fill-column 56)
 '(inhibit-startup-screen t)
 '(mail-envelope-from 'header)
 '(mail-specify-envelope-from t)
 '(menu-bar-mode nil)
 '(message-kill-buffer-on-exit t)
 '(message-send-mail-function 'message-send-mail-with-sendmail)
 '(message-sendmail-envelope-from 'header)
 '(notmuch-crypto-process-mime nil)
 '(notmuch-saved-searches
   '((:name "inbox" :query "tag:inbox not tag:flagged not tag:passed" :key "i")
     (:name "unread" :query "tag:unread" :key "u")
     (:name "passed" :query "tag:passed" :key "p")
     (:name "flagged" :query "tag:flagged" :key "f")
     (:name "sent" :query "tag:sent" :key "t")
     (:name "drafts" :query "tag:draft" :key "d")
     (:name "all mail" :query "*" :key "a")))
 '(org-latex-compiler "lualatex")
 '(reftex-plug-into-AUCTeX t)
 '(send-mail-function 'sendmail-send-it)
 '(sendmail-program "msmtp")
 '(shr-cookie-policy nil)
 '(shr-inhibit-images t)
 '(shr-use-colors nil)
 '(tool-bar-mode nil))

(define-key key-translation-map [?\C-h] [?\C-?])
(define-key key-translation-map [?\C-?] [?\C-h])
(define-key key-translation-map [?\M-h] [?\M-\d])
(define-key key-translation-map [?\M-\d] [?\M-h])

(global-set-key (kbd "C-c l") #'org-store-link) 
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "M-n") #'org-next-link)
  (define-key org-mode-map (kbd "M-p") #'org-previous-link))

(add-hook 'org-mode-hook 'turn-on-auto-fill)
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'TeX-after-compilation-finished-functions
           #'TeX-revert-document-buffer)

;; credit: yorickvP on Github
(setq wl-copy-process nil)
(defun wl-copy (text)
  (setq wl-copy-process
       (make-process
        :name "wl-copy"
         :buffer nil
         :command '("wl-copy" "-f" "-n")
         :connection-type 'pipe))
  (process-send-string wl-copy-process text)
  (process-send-eof wl-copy-process))
(defun wl-paste ()
  (if (and
       wl-copy-process
       (process-live-p wl-copy-process))
      nil ; should return nil if we're the current paste owner
    (shell-command-to-string "wl-paste -n | tr -d \r")))
(setq interprogram-cut-function 'wl-copy)
(setq interprogram-paste-function 'wl-paste)

(defun dired-open-file ()
  "In dired, open the file named on this line."
  (interactive)
  (let* ((file (dired-get-filename nil t)))
    (call-process "xdg-open" nil 0 nil file)))

(eval-after-load "dired" '(progn
  (define-key dired-mode-map (kbd "C-o") 'dired-open-file)))

(use-package notmuch
  :config
  (setq notmuch-always-prompt-for-sender t))

(use-package magit)

(use-package cdlatex
  :config
  (add-hook 'LaTeX-mode-hook #'turn-on-cdlatex)
  (add-hook 'latex-mode-hook #'turn-on-cdlatex))

(use-package ace-window
  :config
  (setq aw-ignore-current t)
  (setq aw-scope 'frame)
  (global-set-key (kbd "C-M-y") 'ace-window))

(use-package pyim-basedict
  :init
  (pyim-basedict-enable))

(use-package pyim)

(use-package swiper
  :config
  (ivy-mode)
  (avy-setup-default)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  (global-set-key (kbd "C-s") 'swiper)
  (global-set-key (kbd "C-r") 'swiper-backward)
  (global-set-key (kbd "<f6>") 'ivy-resume))

(use-package smartparens)
