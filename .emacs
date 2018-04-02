;; add melpa packages
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/"))
(package-initialize)

;; exwm
(require 'exwm)
(require 'exwm-config)
(setq exwm-workspace-number 4)
;; make class name the buffer name
(add-hook 'exwm-update-class-hook
	  (lambda ()
	    (exwm-workspace-rename-buffer exwm-class-name)))
;; switch workspace
;; start from s-1 as s-0 is uncomfortable to reach
(dotimes (i 5)
  (exwm-input-set-key (kbd (format "s-%d" (+ i 1)))
		      `(lambda ()
			(interactive)
			(exwm-workspace-switch-create, i))))
;; launch program
(exwm-input-set-key (kbd "s-s")
		    (lambda (command)
		      (interactive (list (read-shell-command "> ")))
		      (start-process-shell-command command nil command)))
(exwm-input-set-key (kbd "s-r") 'exwm-reset)
;; lock screen
(exwm-input-set-key (kbd "s-<f1>")
		    (lambda () (interactive) (start-process "" nil "slimlock")))
(exwm-enable)
(exwm-config-ido)
(exwm-config-misc)

;; GENERAL SETTINGS
;; disable gui elements
(menu-bar-mode -1)
(toggle-scroll-bar -1)
(tool-bar-mode -1)

;; disable alarm bell sound
(setq ring-bell-function 'ignore)

;; make copy/paste work across applications
(setq select-enable-clipboard t)

;; don't show startup screen;; open scratch buffer instead
(setq inhibit-startup-screen t)

;; set mode line
(setq-default mode-line-format '(" %b [%m] [%l:%c] %*"))

;; disable emacs from creating "#file#" and "file~" files
(setq make-backup-files nil)

;; load theme
(set-frame-font "Roboto Mono-12" nil t)
(add-to-list 'custom-theme-load-path "~/.emacs.d")
(require 'doom-themes)
(setq doom-themes-enable-bold t
      doom-themes-enable-italic t)
(load-theme 'doom-peacock t)

;; PLUGINS
;; ido
(require 'ido)
(setq ido-enable-flex-matching t)
(ido-mode t)
(define-key global-map (kbd "s-f") 'ido-find-file)
(define-key global-map (kbd "s-m") 'ido-switch-buffer)
(define-key global-map (kbd "s-D") 'ido-dired)

;; evil
(add-to-list 'load-path "~/.emacs.d/evil")
(require 'evil)
(evil-mode t)

;; org
(add-to-list 'load-path "~/.emacs.d/org-mode")
(add-to-list 'load-path "~/.emacs.d/org-mode/contrib/lisp")
(require 'org)

(setq org-todo-keywords '((sequence "IDEA" "NEXT" "TODO" "STARTED" "|" "DONE" "CANCELLED")))
(setq org-agenda-files '("~/org/agenda.org"))
(exwm-input-set-key (kbd "s-<f2>")
		    (lambda () (interactive) (org-agenda "" "t")))

;; odt export
(require 'ox-odt)
(setq org-odt-preferred-output-format "docx")

;; evil org bindings
(add-to-list 'load-path "~/.emacs.d/plugins/evil-org")
(require 'evil-org)
(add-hook 'org-mode-hook 'evil-org-mode)
(evil-org-set-key-theme '(navigation insert textobjects additional calendar shift todo heading))
(require 'evil-org-agenda)
(evil-org-agenda-set-keys)

;; cc-mode
(setq c-default-style "linux"
      c-basic-offset 4)
;; indent when return is pressed (C-m is carriage return)
(defun CR-indent ()
  (define-key c-mode-base-map (kbd "C-m") 'c-context-line-break))
(add-hook 'c-initialization-hook 'CR-indent)

;; nlinum-relative
(require 'nlinum-relative)
(nlinum-relative-setup-evil)
;; show relative line numbers
(add-hook 'prog-mode-hook 'nlinum-relative-mode)
(add-hook 'org-mode-hook 'nlinum-relative-mode)
(add-hook 'c-initialization-hook 'nlinum-relative-mode)
;; delay before redrawing lines
(setq nlinum-relative-redisplay-delay 0.2)
;; symbol for current line
(setq nlinum-relative-current-symbol ">")
(setq nlinum-relative-offset 0)
;; widen gap between line numbers and text
(fringe-mode 5)

;; magit
(require 'magit)
(define-key global-map (kbd "s-g") 'magit-status)
(define-key magit-mode-map (kbd "s-<tab>") nil)
(add-hook 'git-commit-mode 'evil-mode)

;; evil-nerd-commenter
(define-key evil-normal-state-map ";ci" 'evilnc-comment-or-uncomment-lines)

;; column-enforce-mode
(require 'column-enforce-mode)
(setq column-enforce-column 90)
(add-hook 'prog-mode-hook 'column-enforce-mode)
(add-hook 'org-mode-hook 'column-enforce-mode)

;; flycheck
(global-flycheck-mode)
(setq flycheck-indication-mode nil)

;; counsel
(require 'counsel)
(exwm-input-set-key (kbd "C-h f") 'counsel-describe-function)
(exwm-input-set-key (kbd "C-h v") 'counsel-describe-variable)
(exwm-input-set-key (kbd "M-x") 'counsel-M-x)
(exwm-input-set-key (kbd "M-i") 'counsel-package)

;; yasnippet
(require 'yasnippet)
(yas-global-mode 1)

;; GENERAL KEYBINDINGS
(define-key evil-normal-state-map ";w" 'save-buffer)
(define-key evil-normal-state-map ";y" 'clipboard-yank)
(define-key evil-motion-state-map (kbd "<backspace>") 'evil-scroll-up)
(define-key evil-motion-state-map (kbd "SPC") 'evil-scroll-down)
(define-key dired-mode-map (kbd "RET") 'dired-find-alternate-file)
(exwm-input-set-key (kbd "s-h") 'evil-prev-buffer)
(exwm-input-set-key (kbd "s-l") 'evil-next-buffer)
(exwm-input-set-key (kbd "s-=") 'delete-other-windows)
(exwm-input-set-key (kbd "s--") 'delete-window)
(exwm-input-set-key (kbd "s-<tab>") 'other-window)
(exwm-input-set-key (kbd "s-d") 'kill-this-buffer)
(exwm-input-set-key (kbd "s-e") 'eval-defun)
(exwm-input-set-key (kbd "s-q") 'exwm-input-send-next-key)
(exwm-input-set-key (kbd "s-.") 'yas/new-snippet)

(start-process-shell-command "" nil "python3 ~/bin/lemonbar_status.py")

(defun bash ()
  "Launch bash in a terminal."
  (interactive)
  (ansi-term "/bin/bash"))
(define-key global-map (kbd "s-t") 'bash)

(defun sensible-split ()
  "Split horizontally if width of current window > height.
Otherwise split vertically."
  (interactive)
  (if (> (window-width) (* 2 (window-height)))
      (split-window-right)
    (split-window-below)))
(exwm-input-set-key (kbd "s-p") 'sensible-split)

(defun volume-down ()
  "Turn the volume up 10%."
  (interactive)
  (shell-command "amixer --quiet -c 1 sset Master 10%-"))
(exwm-input-set-key (kbd "s-<f11>") 'volume-down)

(defun volume-up ()
  "Turn the volume down 10%."
  (interactive)
  (shell-command "amixer --quiet -c 1 sset Master 10%+"))
(exwm-input-set-key (kbd "s-<f12>") 'volume-up)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("ba48e0e4498e865df8dfc19fa5a0572b9f931cbc034273b75e5b30bab66bffcd" default)))
 '(org-agenda-files nil)
 '(package-selected-packages
   (quote
    (yasnippet-snippets doom-themes pdf-tools ereader company counsel ivy racket-mode csharp-mode evil-org use-package yasnippet flycheck rainbow-mode dash ## "magit" magit evil-nerd-commenter column-enforce-mode exwm sml-mode nlinum-relative))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(font-lock-preprocessor-face ((t (:inherit bold :foreground "goldenrod"))))
 '(font-lock-type-face ((t (:foreground "tomato"))))
 '(linum ((t (:inherit default :foreground "dark gray" :strike-through nil :underline nil :slant normal :weight normal))))
 '(mode-line ((t (:background "#2b2a2c" :box nil))))
 '(mu4e-unread-face ((t (:inherit font-lock-keyword-face :background "#000000" :foreground "#dddddd" :weight normal)))))
(put 'dired-find-alternate-file 'disabled nil)
