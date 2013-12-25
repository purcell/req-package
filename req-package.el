(require 'use-package)
(require 'cl)

(defvar req-package-targets nil
  "list of packages to load")

(defvar req-package-eval-list nil
  "preprocessed list of forms to eval")

(defun req-package-wrap-reqs (reqs)
  (if (atom reqs) (list reqs) reqs))

(defmacro req-package (name &rest args)
  `(let* ((NAME ',name)
          (ARGS ',args)
          (ERRMES "invalid arguments list")
          (HASREQ (and (not (null ARGS))
                       (eq (car ARGS) :require)
                       (if (null (cdr ARGS)) (error ERRMES) t)))
          (USEPACKARGS (if HASREQ (cddr ARGS) ARGS))
          (REQS (if HASREQ (req-package-wrap-reqs (cadr ARGS)) nil))
          (TARGET (list NAME REQS (apply 'list 'use-package NAME USEPACKARGS))))

     (add-to-list 'req-package-targets TARGET)))

(defun req-package-form-eval-list (targets)
  (mapcar (lambda (target) (add-to-list 'req-package-eval-list (caddr target)))
          targets))

(defun req-package-eval ()
  (mapcar (lambda (target) (eval target))
          req-package-eval-list))

(defun req-package-finish ()
  (progn (req-package-form-eval-list req-package-targets)
         (req-package-eval)))

(provide 'req-package)