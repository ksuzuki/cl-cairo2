(defpackage #:cl-cairo2-asd
  (:use :cl :asdf))

(in-package #:cl-cairo2-asd)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defparameter *cairo-base-surfaces* '((:file "package")
										(:file "cairo" :depends-on ("package"))
										(:file "my-double" :depends-on ("package"))
										(:file "cl-cairo2-swig" :depends-on ("cairo" "my-double"))
										(:file "tables" :depends-on ("cl-cairo2-swig"))
										(:file "surface" :depends-on ("cairo" "tables" "cl-cairo2-swig"))
										(:file "context" :depends-on ("surface" "tables" "cl-cairo2-swig"))
										(:file "path" :depends-on ("context"))
										(:file "text" :depends-on ("context"))
										(:file "transformations" :depends-on ("context"))
										(:file "pattern" :depends-on ("context" "surface" "tables" "transformations" "cl-cairo2-swig"))))

  (defparameter *cairo-win32-surface* '((:file "package-win32" :depends-on ("package"))
										(:file "cl-cairo2-win32-swig" :depends-on ("cl-cairo2-swig"))
										(:file "win32" :depends-on ("cl-cairo2-win32-swig"))))

  (defparameter *cairo-xlib-surface* '((:file "package-xlib" :depends-on ("package"))
									   (:file "cl-cairo2-xlib-swig" :depends-on ("cl-cairo2-swig"))
									   (:file "libraries-x11" :depends-on ("cl-cairo2-xlib-swig"))
									   (:file "xlib" :depends-on ("libraries-x11"))
									   (:file "xlib-image-context" :depends-on ("xlib"))))

  (defparameter *cairo-quartz-surface* '((:file "package-quartz" :depends-on ("package"))
										 (:file "cl-cairo2-quartz-swig" :depends-on ("cl-cairo2-swig"))))

  ;; Where did these gdk stuff come from??
  (defparameter *cairo-gdk-surface* '((:file "libraries-gdk" :depends-on ("libraries-xlib"))
									  (:file "gtk-context" :depends-on ("libraries-gdk"))))

  ;; feature-component map
  (defparameter *fc-map* (list (cons :cairo-base-surfaces *cairo-base-surfaces*)
							   (cons :cairo-xlib-surface *cairo-xlib-surface*)
							   #+(or windows windows-target)
							   (cons :cairo-win32-surface *cairo-win32-surface*)
							   #+(and (or darwin darwin-target) cairo-quartz-surface-available)
							   (cons :cairo-quartz-surface *cairo-quartz-surface*)
							   #+cairo-gdk-surface-available
							   (cons :cairo-gdk-surface *cairo-gdk-surface*)))

  (defmacro defsystem-cl-cairo2 (components)
	`(defsystem cl-cairo2
	   :description "Cairo 1.6 bindings"
	   :version "0.5"
	   :author "Tamas K Papp"
	   :license "GPL"
	   :components ,components
	   :depends-on (:cffi :cl-colors :cl-utilities :trivial-garbage :trivial-features)))

  (defun configure-cl-cairo2-components ()
	(let ((components (reduce #'(lambda (cs fc) (if (member (car fc) *features*)
													(append cs (cdr fc))
													cs))
										*fc-map* :initial-value nil))
		  (features (reduce #'(lambda (fs fc) (if (member (car fc) *features*)
												  (cons (car fc) fs)
												  fs))
							*fc-map* :initial-value nil)))
	  (values
	   (if (member :cairo-base-surfaces-only *features*)
		   *cairo-base-surfaces*
		   (if components
			   (append *cairo-base-surfaces*
					   (if (and (member :cairo-gdk-surface features) (not (member :cairo-xlib-surface features)))
						   (append *cairo-xlib-surface* components)
						   components))
			   (reduce #'(lambda (cs fc) (append cs (cdr fc))) *fc-map* :initial-value nil)))
	   (if (member :cairo-base-surfaces-only *features*)
		   '(:cairo-base-surfaces-only)
		   (if features
			   (append '(:cairo-base-surfaces)
					   (if (and (member :cairo-gdk-surface features) (not (member :cairo-xlib-surface features)))
						   (append '(:cairo-xlib-surface) features)
						   features))
			   (reduce #'(lambda (fs fc) (cons (car fc) fs)) *fc-map* :initial-value nil))))))

  (defmacro define-cl-cairo2-system ()
	(multiple-value-bind (components features) (configure-cl-cairo2-components)
	  `(progn
		 (defsystem-cl-cairo2 ,components)
		 (dolist (f ',features)
		   (pushnew f *features*)))))

  (define-cl-cairo2-system))
