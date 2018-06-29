;;; packages.el --- ztlevi layer packages file for Spacemacs. -*- lexical-binding: t -*-
;;
;; Copyright (c) 2016-2018 ztlevi
;;
;; Author: ztlevi <zhouting@umich.edu>
;; URL: https://github.com/ztlevi/spacemacs-config
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(defconst ztlevi-prog-packages
  '(
    company
    counsel-etags
    (cc-mode :location built-in)
    google-c-style
    cquery
    cmake-font-lock
    cmake-mode
    lsp-intellij
    js2-mode
    rjsx-mode
    vue-mode
    lsp-ui
    (lsp-imenu :location built-in)
    lsp-vue
    js2-refactor
    js-doc
    import-js
    web-mode
    (stylus-mode :location (recipe :fetcher github :repo "vladh/stylus-mode"))
    json-mode
    ;; format-all
    prettier-js
    ;; racket-mode
    flycheck
    ;; lua-mode
    (python :location built-in)
    (emacs-lisp :location built-in)
    lispy
    ;; graphviz-dot-mode
    ;; cider
    robe
    )
  )

(defun ztlevi-prog/init-format-all ()
  (use-package format-all
    :defer t
    :commands format-all-buffer
    :init (add-hook 'before-save-hook #'format-all-buffer)))

;; configuration scheme
;; https://prettier.io/docs/en/configuration.html#configuration-schema
(defun ztlevi-prog/init-prettier-js ()
  (use-package prettier-js
    :defer t
    :init
    ;; prettier js
    (spacemacs/add-to-hooks 'prettier-js-mode '(js2-mode-hook
                                                typescript-mode-hook
                                                typescript-tsx-mode-hook
                                                rjsx-mode-hook
                                                json-mode-hook
                                                css-mode-hook
                                                markdown-mode-hook
                                                gfm-mode-hook))
    :config
    (progn
      (setq prettier-js-show-errors (quote echo))

      (spacemacs|diminish prettier-js-mode " Ⓟ" " P")

      ;; bind key
      (spacemacs/set-leader-keys-for-major-mode 'js2-mode "=" 'prettier-js)
      (spacemacs/set-leader-keys-for-major-mode 'typescript-mode "=" 'prettier-js)
      (spacemacs/set-leader-keys-for-major-mode 'typescript-tsx-mode "=" 'prettier-js)
      (spacemacs/set-leader-keys-for-major-mode 'rjsx-mode "=" 'prettier-js)
      (spacemacs/set-leader-keys-for-major-mode 'json-mode "=" 'prettier-js)
      (spacemacs/set-leader-keys-for-major-mode 'css-mode "=" 'prettier-js)
      (spacemacs/set-leader-keys-for-major-mode 'markdown-mode "=" 'prettier-js)
      (spacemacs/set-leader-keys-for-major-mode 'gfm-mode "=" 'prettier-js))))

(defun ztlevi-prog/post-init-rjsx-mode ()
  ;; comment jsx region
  (add-hook 'rjsx-mode-hook (lambda ()
                              (with-eval-after-load 'evil-surround
                                (push '(?/ . ("{/*" . "*/}")) evil-surround-pairs-alist)))))

(defun ztlevi-prog/init-stylus-mode ()
  (use-package stylus-mode
    :defer t))

(defun ztlevi-prog/post-init-lsp-intellij ()
  (spacemacs|define-jump-handlers java-mode)
  (spacemacs//setup-lsp-jump-handler 'java-mode))

(defun ztlevi-prog/post-init-robe ()
  (progn
    (add-hook 'inf-ruby-mode-hook 'spacemacs/toggle-auto-completion-on)
    (defun ztlevi/ruby-send-current-line (&optional print)
      "Send the current line to the inferior Ruby process."
      (interactive "P")
      (ruby-send-region
       (line-beginning-position)
       (line-end-position))
      (when print (ruby-print-result)))

    (defun ztlevi/ruby-send-current-line-and-go ()
      (interactive)
      (ztlevi/ruby-send-current-line)
      (ruby-switch-to-inf t))

    (defun ztlevi/start-inf-ruby-and-robe ()
      (interactive)
      (when (not (get-buffer "*ruby*"))
        (inf-ruby))
      (robe-start))

    (dolist (mode '(ruby-mode enh-ruby-mode))
      (spacemacs/set-leader-keys-for-major-mode mode
        "sb" 'ruby-send-block
        "sB" 'ruby-send-buffer
        "sl" 'ztlevi/ruby-send-current-line
        "sL" 'ztlevi/ruby-send-current-line-and-go
        "sI" 'ztlevi/start-inf-ruby-and-robe))))

(defun ztlevi-prog/post-init-cider ()
  (setq cider-cljs-lein-repl
        "(do (require 'figwheel-sidecar.repl-api)
           (figwheel-sidecar.repl-api/start-figwheel!)
           (figwheel-sidecar.repl-api/cljs-repl))")

  (defun ztlevi/cider-figwheel-repl ()
    (interactive)
    (save-some-buffers)
    (with-current-buffer (cider-current-repl-buffer)
      (goto-char (point-max))
      (insert "(require 'figwheel-sidecar.repl-api)
             (figwheel-sidecar.repl-api/start-figwheel!) ; idempotent
             (figwheel-sidecar.repl-api/cljs-repl)")
      (cider-repl-return)))

  (bind-key* "C-c C-f" #'ztlevi/cider-figwheel-repl))

(defun ztlevi-prog/post-init-graphviz-dot-mode ()
  (with-eval-after-load 'graphviz-dot-mode
    (require 'company-keywords)
    (push '(graphviz-dot-mode  "digraph" "node" "shape" "subgraph" "label" "edge" "bgcolor" "style" "record") company-keywords-alist)))

(defun ztlevi-prog/post-init-emacs-lisp ()
  (remove-hook 'emacs-lisp-mode-hook 'auto-compile-mode))

(defun ztlevi-prog/post-init-python ()
  (add-hook 'python-mode-hook #'(lambda () (modify-syntax-entry ?_ "w")))

  ;; set python interpreters
  (setq importmagic-python-interpreter "python3")
  (setq pippel-python-command "python3")

  ;; if you use pyton2, then you could comment the following 3 lines
  ;; (setq python-shell-interpreter "python2")
  ;; (setq python-shell-interpreter-args "-i")
  ;; (setq flycheck-python-pylint-executable "/usr/local/bin/pylint")
  )

(defun ztlevi-prog/init-import-js ()
  (use-package import-js
    :init
    (progn
      (run-import-js)
      (spacemacs/set-leader-keys-for-major-mode 'js2-mode "i" 'import-js-import)
      (spacemacs/set-leader-keys-for-major-mode 'js2-mode "f" 'import-js-fix)
      (spacemacs/set-leader-keys-for-major-mode 'rjsx-mode "i" 'import-js-import)
      (spacemacs/set-leader-keys-for-major-mode 'rjsx-mode "f" 'import-js-fix))
    :defer t))

(defun ztlevi-prog/post-init-js-doc ()
  (setq js-doc-mail-address "zhouting@umich.edu"
        js-doc-author (format "Ting Zhou <%s>" js-doc-mail-address)
        js-doc-url "http://ztlevi.github.io"
        js-doc-license "MIT"))

(defun ztlevi-prog/post-init-web-mode ()
  (with-eval-after-load 'web-mode
    ;; for react mode html indentation
    (add-to-list 'web-mode-indentation-params '("lineup-args" . nil))
    (add-to-list 'web-mode-indentation-params '("lineup-concats" . nil))
    (add-to-list 'web-mode-indentation-params '("lineup-calls" . nil))

    (web-mode-toggle-current-element-highlight)
    (web-mode-dom-errors-show)

    ;; live server
    (spacemacs/set-leader-keys-for-major-mode 'web-mode "l" 'live-server-preview)))

(defun ztlevi-prog/post-init-racket-mode ()
  (progn
    (eval-after-load 'racket-repl-mode
      '(progn
         (define-key racket-repl-mode-map (kbd "]") nil)
         (define-key racket-repl-mode-map (kbd "[") nil)))

    (add-hook 'racket-mode-hook #'(lambda () (lispy-mode 1)))
    (add-hook 'racket-repl-mode-hook #'(lambda () (lispy-mode t)))
    ))

(defun ztlevi-prog/post-init-json-mode ()
  ;; set indent for json mode
  (setq js-indent-level 2)
  ;; set indent for json-reformat-region
  (setq json-reformat:indent-width 2)
  (add-to-list 'auto-mode-alist '("\\.tern-project\\'" . json-mode))
  (add-to-list 'auto-mode-alist '("\\.fire\\'" . json-mode))
  (add-to-list 'auto-mode-alist '("\\.fire.meta\\'" . json-mode)))

(defun ztlevi-prog/init-lispy ()
  (use-package lispy
    :defer t
    :init
    (spacemacs/add-to-hooks (lambda () (lispy-mode)) '(emacs-lisp-mode-hook
                                                       ielm-mode-hook
                                                       inferior-emacs-lisp-mode-hook
                                                       clojure-mode-hook
                                                       scheme-mode-hook
                                                       cider-repl-mode-hook))
    :config
    (progn
      (define-key lispy-mode-map (kbd "C-a") 'mwim-beginning-of-code-or-line)

      (push '(cider-repl-mode . ("[`'~@]+" "#" "#\\?@?")) lispy-parens-preceding-syntax-alist)

      (spacemacs|hide-lighter lispy-mode)

      (with-eval-after-load 'cider-repl
        (define-key cider-repl-mode-map (kbd "C-s-j") 'cider-repl-newline-and-indent))

      (add-hook
       'minibuffer-setup-hook
       'conditionally-enable-lispy))))

(defun ztlevi-prog/post-init-google-c-style ()
  (progn
    (when c-c++-enable-google-style
      (remove-hook 'c-mode-common-hook 'google-set-c-style)
      (add-hook 'c-c++-modes-hook 'google-set-c-style))
    (when c-c++-enable-google-newline
      (remove-hook 'c-mode-common-hook 'google-make-newline-indent)
      (add-hook 'c-c++-modes-hook 'google-make-newline-indent))))

(defun ztlevi-prog/init-cmake-font-lock ()
  (use-package cmake-font-lock
    :defer t))

(defun ztlevi-prog/post-init-cmake-mode ()
  (progn
    (spacemacs/declare-prefix-for-mode 'cmake-mode
      "mh" "docs")
    (spacemacs/set-leader-keys-for-major-mode 'cmake-mode
      "hd" 'cmake-help)
    (add-hook 'cmake-mode-hook (function cmake-rename-buffer))))

(defun ztlevi-prog/post-init-flycheck ()
  (progn
    (with-eval-after-load 'flycheck
      ;; disable jshint since we prefer eslint checking
      ;; disable json-jsonlist checking for json files
      (setq-default flycheck-disabled-checkers
                    (append flycheck-disabled-checkers
                            '(javascript-jshint
                              json-jsonlist)))

      ;; customize flycheck temp file prefix
      (setq-default flycheck-temp-prefix ".flycheck"))))

(defun ztlevi-prog/post-init-js2-refactor ()
  (progn
    (spacemacs/set-leader-keys-for-major-mode 'js2-mode
      "r>" 'js2r-forward-slurp
      "r<" 'js2r-forward-barf)))

(defun ztlevi-prog/post-init-lsp-ui ()
  ;; temporary fix for flycheck
  (setq lsp-ui-flycheck-enable nil)

  ;; disable sideline
  (setq lsp-ui-sideline-enable nil)

  ;; set lsp-ui-doc position
  (setq lsp-ui-doc-position 'at-point)

  ;; set spacemacs-jump-handlers-%S (gd)
  (spacemacs//setup-lsp-jump-handler 'c++-mode)
  (spacemacs//setup-lsp-jump-handler 'c-mode)

  (define-key evil-normal-state-map (kbd "gr") #'lsp-ui-peek-find-references)

  (with-eval-after-load 'lsp-ui
    (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
    (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references))
  )

(defun ztlevi-prog/init-vue-mode ()
  (use-package vue-mode
    :defer t))

(defun ztlevi-prog/init-lsp-vue ()
  (use-package lsp-vue
    :commands lsp-vue-mmm-enable
    :init
    (add-hook 'vue-mode-hook #'lsp-vue-mmm-enable)
    :defer t))

(defun ztlevi-prog/init-lsp-imenu ()
  (use-package lsp-imenu
    :init
    (spacemacs/set-leader-keys "bl" 'lsp-ui-imenu)
    (add-hook 'lsp-after-open-hook 'lsp-enable-imenu)
    :defer t))

(defun ztlevi-prog/post-init-js2-mode ()
  ;; js default variables
  ;; https://github.com/redguardtoo/emacs.d/blob/master/lisp/init-javascript.el
  (setq-default js2-strict-inconsistent-return-warning nil ; return <=> return null
                js2-skip-preprocessor-directives t
                js2-bounce-indent-p t
                ;; Let flycheck handle parse errors
                js2-strict-trailing-comma-warning nil
                js2-mode-show-parse-errors nil
                js2-mode-show-strict-warnings nil
                js2-highlight-external-variables t)

  (evilified-state-evilify js2-error-buffer-mode js2-error-buffer-mode-map))

(defun ztlevi-prog/post-init-lua-mode ()
  (progn
    (add-hook 'lua-mode-hook 'evil-matchit-mode)
    (setq lua-indent-level 2)

    ;; add lua language, basic, string and table keywords.
    ;; (with-eval-after-load 'lua-mode
    ;;   (require 'company-keywords)
    ;;   (push '(lua-mode  "setmetatable" "local" "function" "and" "break" "do" "else" "elseif" "self" "resume" "yield"
    ;;                     "end" "false" "for" "function" "goto" "if" "nil" "not" "or" "repeat" "return" "then" "true"
    ;;                     "until" "while" "__index" "dofile" "getmetatable" "ipairs" "pairs" "print" "rawget" "status"
    ;;                     "rawset" "select" "_G" "assert" "collectgarbage" "error" "pcall" "coroutine"
    ;;                     "rawequal" "require" "load" "tostring" "tonumber" "xpcall" "gmatch" "gsub"
    ;;                     "rep" "reverse" "sub" "upper" "concat" "pack" "insert" "remove" "unpack" "sort"
    ;;                     "lower") company-keywords-alist))

    ))

(defun ztlevi-prog/init-cquery ()
  (use-package cquery
    :defer t
    :commands lsp-cquery-enable
    :init
    (progn
      (defun cquery//enable ()
        (condition-case nil
            (lsp-cquery-enable)
          (user-error nil)))
      (add-hook 'c-c++-modes-hook #'cquery//enable))
    ))

(defun ztlevi-prog/post-init-cc-mode ()
  ;; http://stackoverflow.com/questions/23553881/emacs-indenting-of-c11-lambda-functions-cc-mode
  (defadvice c-lineup-arglist (around my activate)
    "Improve indentation of continued C++11 lambda function opened as argument."
    (setq ad-return-value
          (if (and (equal major-mode 'c++-mode)
                   (ignore-errors
                     (save-excursion
                       (goto-char (c-langelem-pos langelem))
                       ;; Detect "[...](" or "[...]{". preceded by "," or "(",
                       ;;   and with unclosed brace.
                       (looking-at ".*[(,][ \t]*\\[[^]]*\\][ \t]*[({][^}]*$"))))
              0                       ; no additional indent
            ad-do-it)))               ; default behavior

  (setq c-default-style "linux") ;; set style to "linux"
  (setq c-basic-offset 4)
  (c-set-offset 'substatement-open 0))

(defun ztlevi-prog/init-counsel-etags ()
  (use-package counsel-etags
    :defer t
    :config
    ;; Don't ask before rereading the TAGS files if they have changed
    (setq tags-revert-without-query t)
    ;; Don't warn when TAGS files are large
    (setq large-file-warning-threshold nil)
    ;; Setup auto update now
    (add-hook 'prog-mode-hook
              (lambda ()
                (add-hook 'after-save-hook
                          'counsel-etags-virtual-update-tags 'append 'local)))))

(defun ztlevi-prog/post-init-company ()
  (progn
    (spacemacs|add-company-backends :backends company-lsp :modes c-c++-modes)

    ;; set the company minimum prefix length and idle delay
    (defvar ztlevi/company-minimum-prefix-length 1
      "my own variable for company-minimum-prefix-length")
    (add-hook 'company-mode-hook #'ztlevi/company-init)

    (when (configuration-layer/package-usedp 'company)
      (spacemacs|add-company-backends :modes shell-script-mode makefile-bsdmake-mode sh-mode lua-mode nxml-mode conf-unix-mode json-mode graphviz-dot-mode))

    ;; define company-mode keybindings
    (with-eval-after-load 'company
      (progn
        (bb/define-key company-active-map (kbd "C-f") nil)
        (bb/define-key company-active-map (kbd "C-w") 'evil-delete-backward-word)
        (bb/define-key company-active-map (kbd "C-j") 'company-show-location)))
    ))

(defun ztlevi-prog/post-init-company-c-headers ()
  (progn
    (setq company-c-headers-path-system
          (quote
           ("/usr/include/" "/usr/local/include/" "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include/c++/v1")))
    (setq company-c-headers-path-user
          (quote
           ("/Users/guanghui/cocos2d-x/cocos/platform" "/Users/guanghui/cocos2d-x/cocos" "." "/Users/guanghui/cocos2d-x/cocos/audio/include/")))))