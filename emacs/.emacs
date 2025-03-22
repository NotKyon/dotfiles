;; Setup packages
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                            ;;
;;  ************************************************************************  ;;
;;  **                                                                    **  ;;
;;  ** NATIVE EMACS CONFIGURATION HERE (NO PACKAGES/DEPENDENCIES!)        **  ;;
;;  **                                                                    **  ;;
;;  ************************************************************************  ;;
;;                                                                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;; GUI customization
; GUI BS
(setq inhibit-splash-screen t)
(customize-set-variable 'menu-bar-mode nil)
(customize-set-variable 'tool-bar-mode nil)
(menu-bar-mode -1)      ; Disable the menu bar outright
(tool-bar-mode -1)      ; Disable the tool bar outright


; Text editor stylization
(column-number-mode 1)  ; Show the column too
(show-paren-mode    1)  ; Highlight matching parentheses
(visual-line-mode   1)  ; C-a, C-e goes to the start/end of visual line

; Display line numbers in the margin and highlight the current line
(global-display-line-numbers-mode 1)
(global-hl-line-mode)

; Fix annoying scroll behavior.
(setq scroll-error-top-bottom t)
(setq ring-bell-function 'ignore)

; Encode files in UTF-8
(prefer-coding-system 'utf-8)



;; Tabs
(defun disable-tabs () (setq indent-tabs-mode nil))
(defun enable-tabs  ()
  (local-set-key (kbd "TAB") 'tab-to-tab-stop)
  (setq indent-tabs-mode t)
  (setq tab-width 4))

(setq-default indent-tabs-mode t)
(setq-default tab-width 4)
(setq-default backward-delete-char-untabify-method nil)

(setq indent-tabs-mode t)
(setq tab-width 4)
(setq backward-delete-char-untabify-method nil)

(setq-default electric-indent-inhibit t)
(global-set-key (kbd "C->") 'indent-rigidly-right-to-tab-stop)
(global-set-key (kbd "C-<") 'indent-rigidly-left-to-tab-stop)

(defvaralias 'c-basic-offset 'tab-width)
(setq ruby-indent-tabs-mode t)
(defvaralias 'ruby-indent-level 'tab-width)
(defvaralias 'sgml-basic-offset 'tab-width)

(setq whitespace-style '(face tabs tab-mark trailing))

(use-package whitespace
  :ensure nil
  :defer
  :hook (before-save . whitespace-cleanup))

(setq whitespace-display-mappings
  '((tab-mark 9 [124 9] [92 9])))
(global-whitespace-mode)

(add-hook 'prog-mode-hook       'enable-tabs)
(add-hook 'lisp-mode-hook       'disable-tabs)
(add-hook 'emacs-lisp-mode-hook 'disable-tabs)

(whitespace-mode 1)
(add-to-list 'write-file-functions 'delete-trailing-whitespace)

; built-in package?
(use-package battery
  :ensure nil
  :hook (after-init . display-battery-mode))

; parentheses
(use-package paren
  :ensure nil
  :hook (after-init . show-paren-mode)
  :custom
  (show-paren-style 'mixed)
  (show-paren-context-when-offscreen t))




;; Run current file
(defun notkyon/run-buffer ()
  (interactive)
  (when (string-match-p ".odin\\'" (buffer-file-name))
    (async-shell-command (concat "odin run " buffer-file-name " -strict-style -vet -collection:pkg=d:/Repository/NotKyon/pkg -file"))))
(global-set-key (kbd "<f7>") 'notkyon/run-buffer)




;; If window is too big, center buffer within it
(setq notkyon/frame-width 120)
(defun notkyon/resize-margins ()
  (when (> (frame-width) notkyon/frame-width)
    (let ((margin-size (/ (- (frame-width) notkyon/frame-width) 2)))
      (set-window-margins nil margin-size margin-size))))

(add-hook 'window-configuration-change-hook #'notkyon/resize-margins)
(notkyon/resize-margins)




;; xahlee.info emacs stuff (key bindings)
(defun xah-beginning-of-line-or-block ()
  "Move cursor to beginning of indent or line, end of previous block, in that order.

If `visual-line-mode' is on, beginning of line means visual line.

URL `http://xahlee.info/emacs/emacs/emacs_move_by_paragraph.html'
Created: 2018-06-04
Version: 2024-10-30"
  (interactive)
  (let ((xp (point)))
    (if (or (eq (point) (line-beginning-position))
            (eq last-command this-command))
        (when (re-search-backward "\n[\t\n ]*\n+" nil :move)
          (skip-chars-backward "\n\t ")
          ;; (forward-char)
          )
      (if visual-line-mode
          (beginning-of-visual-line)
        (if (eq major-mode 'eshell-mode)
            (progn
              (declare-function eshell-bol "esh-mode.el" ())
              (eshell-bol))
          (back-to-indentation)
          (when (eq xp (point))
            (beginning-of-line)))))))

(defun xah-end-of-line-or-block ()
  "Move cursor to end of line or next block.

• When called first time, move cursor to end of line.
• When called again, move cursor forward by jumping over any sequence of whitespaces containing 2 blank lines.
• if `visual-line-mode' is on, end of line means visual line.

URL `http://xahlee.info/emacs/emacs/emacs_move_by_paragraph.html'
Created: 2018-06-04
Version: 2024-10-30"
  (interactive)
  (if (or (eq (point) (line-end-position))
          (eq last-command this-command))
      (re-search-forward "\n[\t\n ]*\n+" nil :move)
    (if visual-line-mode
        (end-of-visual-line)
      (end-of-line))))

(defvar xah-brackets '("“”" "()" "[]" "{}" "<>" "＜＞" "（）" "［］" "｛｝" "⦅⦆" "〚〛" "⦃⦄" "‹›" "«»" "「」" "〈〉" "《》" "【】" "〔〕" "⦗⦘" "『』" "〖〗" "〘〙" "｢｣" "⟦⟧" "⟨⟩" "⟪⟫" "⟮⟯" "⟬⟭" "⌈⌉" "⌊⌋" "⦇⦈" "⦉⦊" "❛❜" "❝❞" "❨❩" "❪❫" "❴❵" "❬❭" "❮❯" "❰❱" "❲❳" "〈〉" "⦑⦒" "⧼⧽" "﹙﹚" "﹛﹜" "﹝﹞" "⁽⁾" "₍₎" "⦋⦌" "⦍⦎" "⦏⦐" "⁅⁆" "⸢⸣" "⸤⸥" "⟅⟆" "⦓⦔" "⦕⦖" "⸦⸧" "⸨⸩" "｟｠")
 "A list of strings, each element is a string of 2 chars, the left bracket and a matching right bracket.
Used by `xah-select-text-in-quote' and others.")

(defconst xah-left-brackets
  (mapcar (lambda (x) (substring x 0 1)) xah-brackets)
  "List of left bracket chars. Each element is a string.")

(defconst xah-right-brackets
  (mapcar (lambda (x) (substring x 1 2)) xah-brackets)
  "List of right bracket chars. Each element is a string.")

(defun xah-backward-left-bracket ()
  "Move cursor to the previous occurrence of left bracket.
The list of brackets to jump to is defined by `xah-left-brackets'.

URL `http://xahlee.info/emacs/emacs/emacs_navigating_keys_for_brackets.html'
Version: 2015-10-01"
  (interactive)
  (re-search-backward (regexp-opt xah-left-brackets) nil t))

(defun xah-forward-right-bracket ()
  "Move cursor to the next occurrence of right bracket.
The list of brackets to jump to is defined by `xah-right-brackets'.

URL `http://xahlee.info/emacs/emacs/emacs_navigating_keys_for_brackets.html'
Version: 2015-10-01"
  (interactive)
  (re-search-forward (regexp-opt xah-right-brackets) nil t))

(global-set-key (kbd "<prior>") 'xah-beginning-of-line-or-block) ; page up key
(global-set-key (kbd "<next>") 'xah-end-of-line-or-block) ; page down key

(global-set-key (kbd "<home>") 'xah-backward-left-bracket)
(global-set-key (kbd "<end>") 'xah-forward-right-bracket)




;; macOS Keybindings and other settings
(when (eq system-type 'darwin)
  (progn
    (setq mac-option-key-is-meta nil
          mac-command-key-is-meta t
          mac-command-modifier 'meta
          mac-option-modifier 'none)
    (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
    (add-to-list 'default-frame-alist '(ns-appearance . dark))
    )
  )

;; Windows settings
(defun w32/maximize-frame (&optional frame)
   "Maximizes the active frame in Windows"
   (interactive)
   ;; Send a `WM_SYSCOMMAND' message to the active frame with the
   ;; `SC_MAXIMIZE' parameter.
   (when (eq system-type 'windows-nt)
     (w32-send-sys-command 61488)))


(when (eq system-type 'windows-nt)
  (progn
    (global-set-key [M-f4] 'save-buffers-kill-emacs)
    (add-hook 'window-setup-hook 'w32/maximize-frame t)
    (add-hook 'after-make-frame-functions 'w32/maximize-frame)
    ))

(global-set-key [C-tab] 'other-frame)




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                            ;;
;;  ************************************************************************  ;;
;;  **                                                                    **  ;;
;;  ** PACKAGES AND DEPENDENCY CONFIGURATION HERE!                        **  ;;
;;  **                                                                    **  ;;
;;  ************************************************************************  ;;
;;                                                                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;; **** From Tsoding's Dotfiles **** ;;
(defvar rc/package-contents-refreshed nil)

(defun rc/package-refresh-contents-once ()
  (when (not rc/package-contents-refreshed)
    (setq rc/package-contents-refreshed t)
    (package-refresh-contents)))

(defun rc/require-one-package (package)
  (when (not (package-installed-p package))
    (rc/package-refresh-contents-once)
    (package-install package)))

(defun rc/require (&rest packages)
  (dolist (package packages)
    (rc/require-one-package package)))

(defun rc/require-theme (theme)
  (let ((theme-package (->> theme
                            (symbol-name)
                            (funcall (-flip #'concat) "-theme")
                            (intern))))
    (rc/require theme-package)
    (load-theme theme t)))

(rc/require 'dash)
(require 'dash)
(rc/require 'dash-functional)
(require 'dash-functional)




;; Window management
(rc/require 'win-switch)
(win-switch-setup-keys-arrow-ctrl)

;; Window numbering mode
;;
;; Puts a number on the mode-line bar
;; Switch with C-x w [N]
(rc/require 'winum)
(winum-mode)

;; Move text
(rc/require 'move-text)
(global-set-key (kbd "M-p") 'move-text-up)
(global-set-key (kbd "M-n") 'move-text-down)

;; Theme
(setq catppuccin-flavor 'mocha) ; or 'latte, 'macchiato, or 'mocha
(rc/require-theme 'catppuccin)

(setq custom-file "~/.emacs-custom.el")
(load-file (custom-file))

(custom-set-faces
 '(whitespace-tab ((t (:foreground "#636363")))))

(set-frame-font "Iosevka 12" nil t)




;; Buffer cycling (like ctrl+{shift+}tab)
(use-package cycbuf)
(add-hook 'after-init-hook 'cycbuf-init)




;; project stuff
(use-package projectile
  :config
  (progn
    (projectile-global-mode)
  ))




;; Mini buffer improvements
; Vertico: Put completions in a browsable vertical list in the minibuffer
(rc/require 'vertico)
(use-package vertico
  :ensure t
  :config
  (progn
	(setq vertico-cycle  t)
	(setq vertico-resize nil)
    (vertico-mode 1)
  ))
; Marginalia: See extra information in the mini buffer
; e.g., completions show command descriptions, switching buffers shows size,
;       language, etc
(rc/require 'marginalia)
(use-package marginalia
  :ensure t
  :config
  (progn
    (marginalia-mode 1)
  ))
; Consult: Calls outside programs to do stuff
(rc/require 'consult)
(use-package consult
  :ensure t
)
; Orderless: Typing a space into minibuffer commands (e.g., M-x, or consult-grep)
; will let the search be a sequence of regular expressions matching in any order
(rc/require 'orderless)
(use-package orderless
  :ensure t
)




;; File Explorerer
(rc/require 'treemacs)
(use-package treemacs
  :ensure t
  :bind ("<f5>" . treemacs)
  :custom
    (treemacs-is-never-other-window t)
  :hook
    (treemacs-mode . treemacs-project-follow-mode)
)




;; Distinguish between file-backed buffers and virtual buffers (e.g., terminals)
(rc/require 'solaire-mode)
(use-package solaire-mode
  :ensure t
  :hook
    (after-init . solaire-global-mode)
  :config
    (progn
      (push '(treemacs-window-background-face . solaire-default-face) solaire-mode-remap-alist)
      (push '(treemacs-hi-line-face . solaire-hi-line-face) solaire-mode-remap-alist)
    )
)




;; Automatic golden ratio for splitting
; NOTE: `golden-ratio-toggle-widescreen` can be used if the gaps/splits are too wide
(rc/require 'golden-ratio)
(use-package golden-ratio
  :ensure t
  :hook (after-init . golden-ratio-mode)
  :custom
    (golden-ratio-exclude-modes '(occur-mode)))




;; Center M-x menu in the window like modern editor prompts
(rc/require 'vertico-posframe)
(use-package vertico-posframe
  :ensure t
  :hook (after-init . vertico-posframe-mode)
  :custom
  (vertico-posframe-parameters
   '((left-fringe . 8)
     (right-fringe . 8)))
)




;; All the icons
(rc/require 'all-the-icons
            'all-the-icons-completion
            'all-the-icons-dired)
(use-package all-the-icons
  :ensure t
  :if (display-graphic-p))
(use-package all-the-icons-dired
  :ensure t)
(use-package all-the-icons-completion
  :ensure t
  :defer
  :hook (marginalia-mode . #'all-the-icons-completion-marginalia-setup)
  :init
  (all-the-icons-completion-mode))

(rc/require 'nerd-icons
            'treemacs-nerd-icons)




;; Neat modeline
(rc/require 'doom-modeline)
; NOTE: Need to run M-x all-the-icons-install-fonts
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config (column-number-mode 1)
  :custom
  (doom-modeline-height 30)
  (doom-modeline-window-width-limit nil)
  (doom-modeline-buffer-file-name-style 'truncate-with-project)
  (doom-modeline-minor-modes nil)
  (doom-modeline-enable-word-count t)
  (doom-modeline-buffer-encoding nil)
  (doom-modeline-buffer-modification-icon t)
  (doom-modeline-env-python-executable "python")
  (display-time-mode 1)
  (doom-modeline-time t) ; requires display-time-mode of 1
  (doom-modeline-vcs-max-length 50)
)




;; Add padding around windows and frames
(rc/require 'spacious-padding)
(use-package spacious-padding
  :ensure t
  :hook (after-init . spacious-padding-mode)
)




;; Dashboard (Startup Screen)
(rc/require 'dashboard)
(use-package dashboard
  :ensure t
  :custom
  (dashboard-startup-banner    'logo)
  (dashboard-center-content    t)
  (dashboard-show-shortcuts    nil)
  (dashboard-set-heading-icons t)
  (dashboard-icon-type         'all-the-icons)
  (dashboard-set-file-icons    t)
  (dashboard-projects-backend  'projectile)
  (dashboard-items '(
;                     (vocabulary)
                     (recents . 5)
                     (bookmarks . 5)
                     ))
  (dashboard-item-generators '(
;                              (vocabulary . gopar/dashboard-insert-vocabulary)
                              (recents . dashboard-insert-recents)
                              (bookmarks . dashboard-insert-bookmarks)
                              ))
  :init
  (defun gopar/dashboard-insert-vocabulary (list-size)
    (dashboard-insert-heading "Word of the Day:"
                              nil
                              (all-the-icons-faicon "newspaper-o"
                                                    :height 1.2
                                                    :v-adjust 0.0
                                                    :face 'dashboard-heading))
    (insert "\n")
    (let ((random-line nil)
          (lines nil))
      (with-temp-buffer
        (insert-file-contents (concat user-emacs-directory "words"))
        (goto-char (point-min))
        (setq lines (split-string (buffer-string) "\n" t))
        (setq random-line (nth (random (length lines)) lines))
        (setq random-line (string-join (split-string random-line) " ")))
      (insert "    " random-line)))
  :config
  (dashboard-setup-startup-hook))




;; Terminal
(unless (eq system-type 'windows-nt)
  (rc/require 'vterm)
  (use-package vterm
    :ensure t
    :custom
      (vterm-max-scrollback 100000)
  ))




;; **** MODES **** ;;
(load-file "~/.emacs.d/odin-mode.el")
(load-file "~/.emacs.d/hlsl-mode.el")

(rc/require 'nginx-mode
			'php-mode
			'powershell
			'wgsl-mode
			'd-mode
			'go-mode
			'markdown-mode
			'glsl-mode
			'typescript-mode)




;;; Slang config (Uses HLSL)
(add-to-list 'auto-mode-alist '("\\.slang\\'" . hlsl-mode))




;;; Powershell config
(add-to-list 'auto-mode-alist '("\\.ps1\\'" . powershell-mode))
(add-to-list 'auto-mode-alist '("\\.psm1\\'" . powershell-mode))




;; Support Magit
(rc/require 'cl-lib)
(rc/require 'magit)

(setq magit-auto-revert-mode nil)

(global-set-key (kbd "C-c m s") 'magit-status)
(global-set-key (kbd "C-c m l") 'magit-log)




;; ido (command completion)
;(rc/require 'ido-at-point)
;(ido-mode 1)
;(ido-everywhere 1)
