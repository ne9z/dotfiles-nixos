(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(LaTeX-mode-hook
   '(preview-mode-setup auto-fill-mode TeX-source-correlate-mode))
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
 '(mml-secure-openpgp-sign-with-sender t)
 '(notmuch-saved-searches
   '((:name "inbox" :query "tag:inbox not tag:flagged not tag:passed" :key "i")
     (:name "unread" :query "tag:unread" :key "u")
     (:name "passed" :query "tag:passed" :key "p")
     (:name "flagged" :query "tag:flagged" :key "f")
     (:name "sent" :query "tag:sent" :key "t")
     (:name "drafts" :query "tag:draft" :key "d")
     (:name "all mail" :query "*" :key "a")))
 '(org-format-latex-header
   "\\documentclass{article}\12\\usepackage[usenames]{color}\12[DEFAULT-PACKAGES]\12[PACKAGES]\12\\pagestyle{empty}             % do not remove\12% The settings below are copied from fullpage.sty\12\\setlength{\\textwidth}{\\paperwidth}\12\\addtolength{\\textwidth}{-3cm}\12\\setlength{\\oddsidemargin}{1.5cm}\12\\addtolength{\\oddsidemargin}{-2.54cm}\12\\setlength{\\evensidemargin}{\\oddsidemargin}\12\\setlength{\\textheight}{\\paperheight}\12\\addtolength{\\textheight}{-\\headheight}\12\\addtolength{\\textheight}{-\\headsep}\12\\addtolength{\\textheight}{-\\footskip}\12\\addtolength{\\textheight}{-3cm}\12\\setlength{\\topmargin}{1.5cm}\12\\addtolength{\\topmargin}{-2.54cm}\12\\linespread{1.3}")
 '(org-format-latex-options
   '(:foreground default :background default :scale 2.0 :html-foreground "Black" :html-background "Transparent" :html-scale 1.0 :matchers
		 ("begin" "$1" "$" "$$" "\\(" "\\[")))
 '(org-latex-classes
   '(("article" "\\documentclass[a4paper,12pt]{article}"
      ("\\section{%s}" . "\\section*{%s}")
      ("\\subsection{%s}" . "\\subsection*{%s}")
      ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
      ("\\paragraph{%s}" . "\\paragraph*{%s}")
      ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))
     ("report" "\\documentclass[11pt]{report}"
      ("\\part{%s}" . "\\part*{%s}")
      ("\\chapter{%s}" . "\\chapter*{%s}")
      ("\\section{%s}" . "\\section*{%s}")
      ("\\subsection{%s}" . "\\subsection*{%s}")
      ("\\subsubsection{%s}" . "\\subsubsection*{%s}"))
     ("book" "\\documentclass[11pt]{book}"
      ("\\part{%s}" . "\\part*{%s}")
      ("\\chapter{%s}" . "\\chapter*{%s}")
      ("\\section{%s}" . "\\section*{%s}")
      ("\\subsection{%s}" . "\\subsection*{%s}")
      ("\\subsubsection{%s}" . "\\subsubsection*{%s}"))))
 '(org-latex-packages-alist
   '(("AUTO" "babel" nil)
     ("margin=1.7cm" "geometry" nil)
     "\\let\\circledS\\undefined\\usepackage[bitstream-charter]{mathdesign}"
     ("" "amsthm" nil)))
 '(org-preview-latex-default-process 'dvipng)
 '(read-buffer-completion-ignore-case t)
 '(read-file-name-completion-ignore-case t)
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
  (define-key org-mode-map (kbd "M-p") #'org-previous-link)
  (define-key org-cdlatex-mode-map (kbd "^") nil)
  (define-key org-cdlatex-mode-map (kbd "_") nil)
  (add-to-list 'ispell-skip-region-alist '("#\\+begin_src". "#\\+end_src")))

(add-hook 'org-mode-hook 'turn-on-auto-fill)
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'TeX-after-compilation-finished-functions
           #'TeX-revert-document-buffer)
(add-hook 'message-setup-hook 'mml-secure-message-sign)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:height 203)))))


(defun dired-open-file ()
  "In dired, open the file named on this line."
  (interactive)
  (let* ((file (dired-get-filename nil t)))
    (call-process "xdg-open" nil 0 nil file)))

(eval-after-load "dired" '(progn
  (define-key dired-mode-map (kbd "C-o") 'dired-open-file)))

(use-package cdlatex
  :config
  (add-hook 'LaTeX-mode-hook #'turn-on-cdlatex)
  (add-hook 'latex-mode-hook #'turn-on-cdlatex)
  (add-hook 'org-mode-hook #'turn-on-org-cdlatex))

(use-package pyim-basedict
  :init
  (pyim-basedict-enable))

(use-package pyim)

(use-package notmuch
  :config
  (setq notmuch-always-prompt-for-sender nil)
  (setq notmuch-fcc-dirs "apvc.uk/Sent/")
  (define-key notmuch-search-mode-map "d"
	      (lambda (&optional beg end)
		"mark message as passed"
		(interactive (notmuch-interactive-region))
		(notmuch-search-tag (list "+passed") beg end)
		(notmuch-search-next-thread)))
  (define-key notmuch-search-mode-map "f"
	      (lambda (&optional beg end)
		"mark message as flagged"
		(interactive (notmuch-interactive-region))
		(notmuch-search-tag (list "+flagged") beg end)
		(notmuch-search-next-thread))))

(use-package magit)

(add-hook 'LaTeX-mode-hook 'turn-on-reftex)
(add-hook 'latex-mode-hook 'turn-on-reftex)

(use-package preview-latex)
(use-package smartparens
  :config
  (smartparens-global-mode t)
  (eval-after-load 'cc-mode '(require 'smartparens-c))
  (eval-after-load 'org     '(require 'smartparens-org))
  (eval-after-load 'latex   '(require 'smartparens-latex))
  ;; see https://github.com/Fuco1/smartparens/issues/1043
  (sp-local-pair 'org-mode "_" nil :actions nil)
  ;; latex inline math mode
  (sp-local-pair 'org-mode "$" "$"))

(use-package ace-window
  :config
  (global-set-key (kbd "C-M-y") 'ace-window)
  (setq aw-keys '(?a ?r ?n ?t ?g ?e ?l ?o ?c ?b ?z ?y ?p))
  (setq aw-scope 'frame)
  (setq aw-ignore-current t))
