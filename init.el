;; elpaca package manager

(defvar elpaca-installer-version 0.5)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil
                              :files (:defaults (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                 ((zerop (call-process "git" nil buffer t "clone"
                                       (plist-get order :repo) repo)))
                 ((zerop (call-process "git" nil buffer t "checkout"
                                       (or (plist-get order :ref) "--"))))
                 (emacs (concat invocation-directory invocation-name))
                 ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                       "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                 ((require 'elpaca))
                 ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;;;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
  (setq elpaca-use-package-by-default t))
(elpaca-wait)

;; enable recent files
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(setq recentf-max-saved-items 25)
(add-to-list 'recentf-exclude "treemacs-persist")
;; Packages

;;;; Theme
(use-package zenburn-theme
:config
(load-theme 'zenburn t))


;;;; evil mode
(use-package evil
	     :demand t
	     :init
	     (setq evil-want-keybinding nil)
	     (setq evil-vsplit-window-right t)
             (setq evil-split-window-below t)
             (evil-mode 1))

;; (use-package evil-collection
;; 	     :config
;; 	     (evil-collection-init)
;; 	     )

;; tweak for evil to highlite copy/paste
(use-package evil-goggles
  :ensure t
  :config
  (evil-goggles-mode)

  ;; optionally use diff-mode's faces; as a result, deleted text
  ;; will be highlighed with `diff-removed` face which is typically
  ;; some red color (as defined by the color theme)
  ;; other faces such as `diff-added` will be used for other actions
  (evil-goggles-use-diff-faces))

;;;; which-key
(use-package which-key
  :init
  (which-key-mode 1)
  :config
  (setq which-key-side-window-location 'bottom
	  which-key-sort-order #'which-key-key-order-alpha
	  which-key-sort-uppercase-first nil
	  which-key-add-column-padding 1
	  which-key-max-display-columns nil
	  which-key-min-display-lines 6
	  which-key-side-window-slot -10
	  which-key-side-window-max-height 0.25
	  which-key-idle-delay 0.8
	  which-key-max-description-length 25
	  which-key-allow-imprecise-window-fit t
	  which-key-separator " → " ))

;;;; consult
(use-package consult)

;;;; projectile
(use-package projectile
             :init
	     (projectile-mode 1)
	     )

;;;; marginalia
(use-package marginalia 
             :config (marginalia-mode 1)
	     )

;;;; vertico
(use-package vertico
	     :init
	     (vertico-mode 1))
;;(use-package vertico-quick :elpaca nil :after vertico :ensure t
;;	     :load-path "elpaca/repos/vertico/extensions/")
;;(use-package vertico-grid :elpaca nil :after vertico :ensure t
;;	     :load-path "elpaca/repos/vertico/extensions/")
;;

;;;; embark
(use-package embark
  :ensure t
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  
  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)
  ;; Show the Embark target at point via Eldoc.  You may adjust the Eldoc
  ;; strategy, if you want to see the documentation from multiple providers.
  (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :ensure t ; only need to install it, embark loads it after consult if found
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;;;; orderless
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;;;; icon pack
(use-package all-the-icons
  :if (display-graphic-p))

;;;; treemacs
(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   'simple
          treemacs-file-event-delay                2000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-find-workspace-method           'find-for-file-or-pick-first
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-header-scroll-indicators        '(nil . "^^^^^^")
          treemacs-hide-dot-git-directory          t
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil
          treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
          treemacs-project-follow-into-home        nil
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-asc
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           nil
          treemacs-user-header-line-format         nil
          treemacs-wide-toggle-width               70
          treemacs-width                           35
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (when treemacs-python-executable
      (treemacs-git-commit-diff-mode t))

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil))
)

(use-package treemacs-evil
  :after (treemacs evil)
  :ensure t)

(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)

(use-package treemacs-icons-dired
  :hook (dired-mode . treemacs-icons-dired-enable-once)
  :ensure t)


;;(use-package treemacs-magit
;;  :after (treemacs magit)
;;  :ensure t)
;;

;;;; company
(use-package company
	     :config	
	     (global-company-mode t)
	     (global-set-key (kbd "C-<tab>") 'company-complete)
	     )
;;;; minions
(use-package minions
	:config
	(minions-mode t)
	     )


;; alterantive mode line

;;;; Language server
(use-package lsp-mode
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  (setq lsp-headerline-breadcrumb-enable-diagnostics nil)
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         (python-ts-mode . lsp)
         (python-mode . lsp)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)
(use-package lsp-ui :commands lsp-ui-mode
:config
(setq lsp-ui-sideline-show-code-actions t)
(setq lsp-ui-sideline-show-diagnostics nil)
	     )
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)
(use-package dap-mode)
(use-package lsp-pyright
  :ensure t
  :hook (python-ts-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp))
))  ; or lsp-deferred

;;;; flycheck
(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode)
  )
(use-package flycheck-posframe
  :ensure t
  :after flycheck
  :config 
  (flycheck-posframe-configure-pretty-defaults)
  (setq flycheck-posframe-border-use-error-face t)
  (setq flycheck-posframe-border-width 1)
  (set-face-attribute 'flycheck-posframe-background-face nil :background "#272936")
  (add-hook 'flycheck-mode-hook #'flycheck-posframe-mode))

;;;; easymotion
(use-package avy
:config
(setq avy-keys '(?a ?r ?s ?t ?d ?h ?n ?e ?i ?o ?w ?f ?p ?l ?u ?y ?v ?k ?m ?c))
(setq avy-background t)
(setq avy-highlight-first t)
	     )

;;;; dashboard
(use-package dashboard
  :ensure t
  :init
  (setq dashboard-projects-backend 'projectile)
  (setq dashboard-items '((recents  . 5)
                        (bookmarks . 5)
                        (projects . 5)
                        (agenda . 5)
                        (registers . 5)))
  (setq dashboard-startup-banner 'logo)
  (setq dashboard-set-file-icons t)
  (setq dashboard-set-footer nil)
  (setq dashboard-banner-logo-title "")
  :config
  (dashboard-setup-startup-hook)
  (dashboard-open))

;;;; Terminal emulator
(use-package vterm :ensure t)

;;;; Resize mode
(use-package windresize :ensure t)

;;;; Nerd icons for modeline
(use-package nerd-icons)

;;;; fancy modeline
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

;; GUI tweaks
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode 1)
(setq evil-normal-state-cursor '(box "light blue")
      evil-insert-state-cursor '(bar "medium sea green")
      evil-visual-state-cursor '(hollow "orange"))


;; Plugins themes
(load "~/.config/emacs/treemacs-theme")

;; Key bindings
(use-package general
  :config
  (general-evil-setup)

  ;; set up 'SPC' as the global leader key
  (general-create-definer my/leader-keys
    :states '(normal visual emacs treemacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    ;;:global-prefix "C-M"
    )
  (my/leader-keys
  ":" '(execute-extended-command :wk "Execute command (M-x)") 
  ) 
  (my/leader-keys
    "qq" '(evil-quit :wk "Quit emacs")
  )
  (my/leader-keys
    "SPC" '(consult-project-buffer :wk "Switch buffer in project")
    "b" '(:ignore t :wk "buffer")
    "bb" '(mode-line-other-buffer :wk "Other buffer (cycle buffers)")
    "ba" '(consult-buffer :wk "List all buffers")
    "bi" '(projectile-ibuffer :wk "List of buffers in ibuffer")
    "bk" '(kill-this-buffer :wk "Kill this buffer")
    "bn" '(projectile-next-project-buffer :wk "Next buffer")


    "bp" '(projectile-previous-project-buffer :wk "Previous buffer")
    ;;"br" '(revert-buffer :wk "Reload buffer"))
  )
  
  (my/leader-keys
    "." '(consult-find :wk "Find file in project")
    "/" '(consult-ripgrep :wk "Search text in project")
    "s" '(:ignore t :wk "search")
    "sf" '(find-file :wk "Find file in file tree")
    "sp" '(consult-ripgrep :wk "Ripgrep in project")
    "sl" '(consult-line :wk "Search line in buffer")
    "ss" '(isearch-forward :wk "ISearch")
    )
  
  (my/leader-keys
    "p" '(:ignore t :wk "project")
    "pa" '(projectile-add-known-project :wk "Add known project")
    "pr" '(projectile-remove-known-project :wk "Remove known project")
    "pp" '(projectile-switch-project :wk "Switch/open project")
  )
  (my/leader-keys
    "a" '(:ignore t :wk "Applications")
    "at" '(vterm :wk "V-temrm")
  )
  (my/leader-keys
    "t" '(:ignore t :wk "Toggles")
    "tn" '(global-display-line-numbers-mode :wk "Line numbers")
    "td" '(lsp-ui-doc-toggle :wk "Toggle LSP doc")
    "tt" '(treemacs :wk "File explorer")
    "tf" '(global-flycheck-mode :wk "Flycheck (global)")
    "tF" '(flycheck-mode :wk "Flycheck (buffer)")
    "ts" '(lsp-treemacs-symbols :wk "Symbols tree")
  )
  (my/leader-keys
    "f" '(:ignore t :wk "Files")
    "fr" '(consult-recent-file :wk "Recent files")
  )
  (my/leader-keys
    "w" '(:ignore t :wk "Windows")
    "ww" '(other-window :wk "Other window (cycle windows)")
    "wq" '(quit-window :wk "Close window and kill it's buffer")
    "wc" '(delete-window :wk "Close window")
    "w <down>" '(evil-window-down :wk "Switch to down window")
    "w <right>" '(evil-window-right :wk "Switch to right window")
    "w <left>" '(evil-window-left :wk "Switch to left window")
    "w <up>" '(evil-window-up :wk "Switch to up window")
    "ws"  '(split-window-vertically :wk "Split window vertically")
    "wv"  '(split-window-horizontally :wk "Split window horizontally")
  )
  (my/leader-keys
    "e" '(:ignore t :wk "Errors")
    "en" '(flycheck-next-error :wk "Next error")
    "ep" '(flycheck-previous-error :wk "Previous error")
    "el" '(lsp-ui-flycheck-list :wk "Buffer errors")
    "eL" '(lsp-treemacs-errors-list :wk "All errors")
    "ef" '(flycheck-first-error :wk "First error")
  )
  (my/leader-keys
    "c" '(:ignore t :wk "Code")
    "cd" '(lsp-ui-doc-glance :wk "Show unit documentation")
    "cr" '(lsp-find-references :wk "Find references")
    "cR" '(lsp-treemacs-references :wk "Find references tree")
    "cp" '(lsp-ui-peek-find-references :wk "Quick find references")

  )

  (my/leader-keys
    "m" '(:ignore t :wk "Jump (easymotion)")
    "ml" '(avy-goto-line :wk "Jump to line")
    "mc" '(avy-goto-char-2 :wk "Jump to 2 chars")
    "mt" '(avy-goto-char-timer :wk "Jump to 2 chars")
    "mw" '(avy-goto-word-1 :wk "Jump to word")
  )
  (my/leader-keys
   "z" '(windresize :wk "Resize window")
    )
)

;; Treesitter support
(setq major-mode-remap-alist
 '((python-mode . python-ts-mode)))

;; Settings
(custom-set-variables
 '(lsp-ui-doc-position 'at-point)
 '(package-selected-packages '(vertico-grid vertico-quick))
)

(custom-set-faces)

(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))


;;(with-eval-after-load 'quick-peek
;;(set-face-attribute 'quick-peek-background-face nil
;;  :background "#272936"
;;  )
;;(set-face-attribute 'quick-peek-padding-face nil
;;  :background "#f59b42"
;;  :height 3
;;  )
;;(set-face-attribute 'quick-peek-border-face nil
;;  :background "Yellow"
;;  :height 3
;;  )
;;)

;;(with-eval-after-load 'quick-peek
;;  (defun my--quick-peek--insert-spacer (pos str-before str-after)
;;    "Insert a thin horizontal line at POS."
;;    (save-excursion
;;      (goto-char pos)
;;      (goto-char pos)
;;      (insert (propertize str-before 'face `(:background "yellow" :height 1 :inherit quick-peek-padding-face)))
;;      (let* ((color (or (face-attribute 'highlight :background) "red")))
;;        (insert (propertize "\n" 'face `(:background "white" :height 2 :inherit quick-peek-border-face))))
;;      (insert (propertize str-after 'face `(:background "green" :height 1 :inherit quick-peek-padding-face)))))
;;  (advice-add #'quick-peek--insert-spacer :override #'my--quick-peek--insert-spacer)
;;
;;  )
