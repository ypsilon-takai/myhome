;; emacsserver
(require 'server)
(unless (server-running-p)
  (server-start))

;; bobcat setting for >22
(load-library "term/bobcat")
(terminal-init-bobcat)

;; default
(menu-bar-mode 1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; theme path
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")

;; load path
(add-to-list 'load-path "~/.emacs.d/local")

;; package tool
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/"))
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))
(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))
 

;; auto install packages if they don't
(defvar my-packages '(clojure-mode
                      auto-complete
                      paredit
                      cider
		      ac-cider
		      magit
                      markdown-mode
                      markdown-mode+
                      python-mode
                      web-mode
		      smex
		      expand-region
		      multiple-cursors
		      smartrep
                      ))

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

;; from new startar kit
(ido-mode t)
(setq ido-enable-flex-matching t)

(setq ido-everywhere t)

(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

(require 'saveplace)
(setq-default save-place t)

(global-set-key (kbd "M-/") 'hippie-expand)
(global-set-key (kbd "C-x C-b") 'ibuffer)

(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "C-r") 'isearch-backward-regexp)
(global-set-key (kbd "C-M-s") 'isearch-forward)
(global-set-key (kbd "C-M-r") 'isearch-backward)

(show-paren-mode t)

(setq x-select-enable-clipboard t
      x-select-enable-primary t
      save-interprogram-paste-before-kill t
      apropos-do-all t
      mouse-yank-at-point t
      save-place-file (concat user-emacs-directory "places")
      backup-directory-alist `(("." . ,(concat user-emacs-directory
					       "backups"))))

(smex-initialize)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)

(electric-indent-mode 1)

;; clojur-mode
(add-hook 'clojure-mode-hook 'paredit-mode)
(add-hook 'emacs-lisp-mode 'paredit-mode)

(defun my-pretty-fn ()
  (font-lock-add-keywords nil `(("(\\(\\<fn\\>\\)"
				 (0 (progn (compose-region (match-beginning 1)
							   (match-end 1)
							   "\u0192"
							   'decompose-region)))))))
(defun my-pretty-lambda ()
  (font-lock-add-keywords nil `(("(\\(\\<fn\\>\\)"
				 (0 (progn (compose-region (match-beginning 1)
							   (match-end 1)
							   "\u03bb"
							   'decompose-region)))))))
(add-hook 'clojure-mode-hook 'my-pretty-lambda)
(add-hook 'clojurescript-mode-hook 'my-pretty-fn)


;; cider : clojure developping environment
(require 'cider)

(defun remove-dos-eol ()
  "Do not show ^M in files containing mixed UNIX and DOS line endings."
  (interactive)
  (setq buffer-display-table (make-display-table))
  (aset buffer-display-table ?\^M []))

;;(add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode)
(add-hook 'cider-mode-hook 'remove-dos-eol)

(add-hook 'cider-repl-mode-hook 'enable-paredit-mode)

(setq nrepl-hide-special-buffers t)
(setq cider-repl-print-length 100)
(setq cider-repl-result-prefix ";;=> ")

;;(require 'cljdoc)

;; auto complete
(require 'auto-complete-config)
(ac-config-default)
(setq ac-use-menu-map t)
(define-key ac-completing-map "\M-/" 'ac-stop) ; use M-/ to stop completion

;; ac-cider
(require 'ac-cider)
(add-hook 'cider-mode-hook 'ac-flyspell-workaround)
(add-hook 'cider-mode-hook 'ac-cider-setup)
(add-hook 'cider-repl-mode-hook 'ac-cider-setup)
(eval-after-load "auto-complete"
  '(add-to-list 'ac-modes 'cider-mode))


(defun nrepl-eldoc-space (n)
  "Inserts a space and calls nrepl-eldoc to print arglists"
  (interactive "p")
  (self-insert-command n)
  (when (nrepl-current-session)
    (nrepl-eldoc)))


(setq markdown-command
      "perl d:/userdata/q3197c/Data/msysgit/bin/markdown.pl")

;; magit
(set-variable 'magit-emacsclient-executable
              "C:/tools/emacs-24.3/bin/emacsclientw.exe")

;; eliminate ^M at dos lines.


;; eshell
;; change prompt
(setq eshell-prompt-function
      (lambda()
        (concat ((lambda (p-lst)
                   (if (> (length p-lst) 2)
                       (concat
                        (mapconcat (lambda (elm) (substring elm 0 1))
                                   (butlast p-lst 2)
                                   "/")
                        "/"
                        (mapconcat (lambda (elm) elm)
                                   (last p-lst 2)
                                   "/"))
                     (mapconcat (lambda (elm) elm)
                                p-lst
                                "/")))
                 (split-string (eshell/pwd) "/"))
                (if (= (user-uid) 0) " # " " $ "))))

(setq line-spacing 0)
(defun toggle-line-spacing ()
  "Toggle line spacing between no extra space to extra half line height."
  (interactive)
  (if (eq line-spacing nil)
      (setq-default line-spacing 0.2) ; add 0.1 height between lines
    (setq-default line-spacing nil)   ; no extra heigh between lines
    )
  (redraw-display))

;; cperl mode
(defalias 'perl-mode 'cperl-mode)

(add-hook 'cperl-mode-hook
          '(lambda ()
             (cperl-set-style "PerlStyle")))


;; python mode
(setq auto-mode-alist (cons '("\\.py$" . python-mode) auto-mode-alist))
(setq interpreter-mode-alist (cons '("python" . python-mode)
				   interpreter-mode-alist))
(autoload 'python-mode "python-mode" "Python editing mode." t)

(add-hook 'python-mode-hook
          (function (lambda ()
		      (setq py-indent-offset 4)
                      (setq indent-tabs-mode nil))))

;; prolog mode
(autoload 'run-prolog "prolog" "Start a Prolog sub-process." t)
(autoload 'prolog-mode "prolog" "Major mode for editing Prolog programs." t)
(autoload 'mercury-mode "prolog" "Major mode for editing Mercury programs." t)
(setq prolog-system 'swi)
(setq auto-mode-alist (append '(("\\.pro$" . prolog-mode)
                                ("\\.m$" . mercury-mode))
                               auto-mode-alist))


;; mouse control
(setq mouse-wheel-scroll-amount '(1 ((shift) . 3) ((control) . nil)))
(setq mouse-wheel-progressive-speed nil)
;; focus follows mouse
(setq mouse-autoselect-window t)

;;;;;;;;
;; tools
(defun find-pid (proc-name)
  (interactive "sProcName: ")
  (process-id (get-process proc-name)))

;; from http://www.emacswiki.org/emacs/AutoIndentation
(dolist (command '(yank yank-pop))
   (eval `(defadvice ,command (after indent-region activate)
            (and (not current-prefix-arg)
                 (member major-mode '(emacs-lisp-mode lisp-mode
                                      clojure-mode    scheme-mode
                                      haskell-mode    ruby-mode
                                      rspec-mode      python-mode
                                      c-mode          c++-mode
                                      objc-mode       latex-mode
                                      plain-tex-mode))
                 (let ((mark-even-if-inactive transient-mark-mode))
                   (indent-region (region-beginning) (region-end) nil))))))




(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(custom-safe-themes (quote ("bb5ac59e63d13acfc03e1abdcac18d850396f72f590acdf8d8691b1c96121c43" "e9c458828e4261bf0d3925a9998e4bba1338b1b6a72eaf08ef6d32af83e686ad" "76f21bb8bdd25a6b002d0ffba05da6e8f2d40abd8a2b35c3d0675fc79912580d" "4378846f8e6bf4b705fcc44379b4b8cd15be96e07a001338cd2e3e2c6db4b670" "5ab29722239a8dab3480f17a5aa232f350dff78c0aab098ca5e19ec8c0ccabce" "aa7419efd76774470afee5084c1adcf660b53990a61ce416e9d7d21ad8380630" "bf3891489e90b2eb599187cc26b8056630a8cd3f8bc296b66c702f3ffbf7f9e6" "910d2e5ee401a9cb3973ee006f656a5ccd508b9a7a2bd17474a2645e2a208cb5" default)))
 '(ibuffer-saved-filter-groups (quote (("clojure-dev" ("directory" (used-mode . dired-mode)) ("clojure" (used-mode . clojure-mode))))))
 '(ibuffer-saved-filters (quote (("gnus" ((or (mode . message-mode) (mode . mail-mode) (mode . gnus-group-mode) (mode . gnus-summary-mode) (mode . gnus-article-mode)))) ("programming" ((or (mode . emacs-lisp-mode) (mode . cperl-mode) (mode . c-mode) (mode . java-mode) (mode . idl-mode) (mode . lisp-mode)))))))
 '(prolog-program-name (quote (((getenv "EPROLOG") (eval (getenv "EPROLOG"))) (eclipse "eclipse") (mercury nil) (sicstus "sicstus") (swi "C:/Program Files/swipl/bin/swipl.exe") (gnu "gprolog") (t "prolog"))))
 '(show-paren-mode t)
 '(skk-henkan-show-candidates-keys (quote (97 111 101 117 105 100 104 116 110 115 39 44 46 112 103 99 114 108 109 119 118)))
 '(tool-bar-mode nil)
 '(url-proxy-services nil))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "Gray20" :foreground "Gray90" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 120 :width normal :foundry "outline" :family "Migu 2M")))))
