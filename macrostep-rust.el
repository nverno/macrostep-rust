;;; macrostep-rust.el --- Expand rust macros interactively -*- lexical-binding: t; -*-

;; Author: Noah Peart <noah.v.peart@gmail.com>
;; URL: https://github.com/nverno/macrostep-rust
;; Version: 0.0.1
;; Package-Requires: ((emacs "27.3") (lsp-mode "8") (rust-mode "1"))
;; Created: 27 March 2024
;; Keywords: languages, rust, macro, debugging

;; This file is not part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; Expand rust macros interactively using the macrostep interface with
;; lsp-rust's `lsp-rust-analyzer-expand-macro'.
;;
;; This package implements the `macrostep' interface to expand rust macros
;; inline in the source buffer.
;;
;; To use:
;; 
;; Add `macrostep-rust-hook' to your rust mode hook, eg.
;;
;;     (add-hook 'rust-mode-hook #'macrostep-rust-hook)
;;
;; and call `macrostep-expand' in a macro.
;;
;;; Code:

(require 'macrostep)
(require 'rust-mode)                    ; `rust-in-macro'

(declare-function lsp-rust-analyzer-expand-macro "lsp-rust")
(defvar lsp-rust-analyzer-macro-expansion-method)

(put 'macrostep-rust-non-macro 'error-conditions
     '(macrostep-rust-non-macro error))
(put 'macrostep-rust-non-macro 'error-message
     "Text around point is not a macro call.")

(put 'macrostep-rust-not-found 'error-conditions
     '(macrostep-rust-not-found error))
(put 'macrostep-rust-not-found 'error-message
     "Macro value not found for: ")

(defun macrostep-rust-sexp-bounds ()
  "Return the bounds of the macro at point."
  (save-excursion
    (let (beg cur)
      (while (setq cur (rust-in-macro))
        (setq beg cur)
        (goto-char beg))
      (unless (looking-at-p "\\<[a-zA-Z_0-9]+!")
        (backward-sexp))
      (and (looking-at-p "[a-zA-Z_0-9]+!")
           (setq beg (point)))
      (if (and beg (not (save-excursion
                          (beginning-of-line)
                          (looking-at-p "macro_rules!"))))
          (let ((end (progn (forward-list) (point))))
            (cons beg end))
        (signal 'macrostep-rust-non-macro nil)))))

(defun macrostep-rust-sexp-at-point (start end)
  "Function for `macrostep-expand-1-function' return START END of sexp."
  (cons start end))

(defun macrostep-rust-expand-1 (_region _ignore)
  "Return the macroexpansion for REGION.
Function for `macrostep-rust-expand-1'."
  (let ((lsp-rust-analyzer-macro-expansion-method
         (lambda (expansion) (string-trim expansion))))
    (lsp-rust-analyzer-expand-macro)))

(defun macrostep-rust-print (sexp _env)
  "Insert expansion for SEXP and propertize any nested macros."
  ;; (let* ((beg (point))
  ;;        (end (progn (insert sexp)
  ;;                    (point))))
  ;;   (goto-char beg)
  ;;   ;; (put-text-property (match-beginning 1) (1+ (match-beginning 1))
  ;;   ;;                    'macrostep-macro-start t)
  ;;   (goto-char end))
  (insert sexp))

;;;###autoload
(defun macrostep-rust-hook ()
  "Main hook to set variables for `macrostep' to function."
  (setq macrostep-sexp-bounds-function          #'macrostep-rust-sexp-bounds)
  (setq macrostep-sexp-at-point-function        #'macrostep-rust-sexp-at-point)
  (setq macrostep-environment-at-point-function #'ignore)
  (setq macrostep-expand-1-function             #'macrostep-rust-expand-1)
  (setq macrostep-print-function                #'macrostep-rust-print))

;; ;;;###autoload
;; (add-hook 'rust-mode-hook #'macrostep-rust-hook)

(provide 'macrostep-rust)
;; Local Variables:
;; coding: utf-8
;; indent-tabs-mode: nil
;; End:
;;; macrostep-rust.el ends here
