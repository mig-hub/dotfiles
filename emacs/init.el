;; Define the init file
;; This is where emacs will write automatically
;; Meaning init.el will stay untouched
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;; Define and initialise package repositories
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; use-package to simplify the config file
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure 't)

;;Settings
(setq inhibit-startup-message t)
(defalias 'yes-or-no-p 'y-or-n-p)
(menu-bar-mode -1)
(global-display-line-numbers-mode)
(set-face-attribute 'default nil :height 180)

;; disable auto-save and auto-backup
(setq auto-save-default nil)
(setq make-backup-files nil)

;; Theme
(use-package atom-one-dark-theme
  :config (load-theme 'atom-one-dark t))
