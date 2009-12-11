(defpackage #:cl-cairo2-asd
  (:use :cl :asdf))

(in-package #:cl-cairo2-asd)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defparameter *base* '((:file "package")
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

  (defparameter *xlib* '((:file "package-xlib" :depends-on ("package"))
						 (:file "cl-cairo2-xlib-swig" :depends-on ("cl-cairo2-swig"))
						 (:file "libraries-x11" :depends-on ("cl-cairo2-xlib-swig"))
						 (:file "xlib" :depends-on ("libraries-x11"))
						 #-cl-cairo2-use-xlib-context
						 (:file "xlib-image-context" :depends-on ("xlib"))
						 #+cl-cairo2-use-xlib-context
						 (:file "xlib-context" :depends-on ("xlib"))))

  (defparameter *quartz* '((:file "package-quartz" :depends-on ("package"))
						   (:file "cl-cairo2-quartz-swig" :depends-on ("cl-cairo2-swig"))
						   (:file "quartz" :depends-on ("text" "cl-cairo2-quartz-swig"))))

  (defparameter *win32* '((:file "package-win32" :depends-on ("package"))
						  (:file "cl-cairo2-win32-swig" :depends-on ("cl-cairo2-swig"))
						  (:file "win32" :depends-on ("text" "cl-cairo2-win32-swig"))))

  (defparameter *gdk* '((:file "libraries-gdk" :depends-on ("libraries-xlib"))
						(:file "gtk-context" :depends-on ("libraries-gdk"))))

  ;; feature-component map
  (defparameter *fc-map* (list (cons :cl-cairo2-base *base*)
							   #-(and (or windows windows-target) (not cl-cairo2-use-xlib))
							   (cons :cl-cairo2-xlib *xlib*)
							   #+(or darwin darwin-target)
							   (cons :cl-cairo2-quartz *quartz*)
							   #+(or windows windows-target)
							   (cons :cl-cairo2-win32 *win32*)
							   #+cl-cairo2-use-gdk
							   (cons :cl-cairo2-gdk *gdk*)))

  (defmacro defsystem-cl-cairo2 (components)
	`(defsystem cl-cairo2
	   :description "Cairo 1.6 bindings"
	   :version "0.6"
	   :author "Tamas K Papp (contributors: Kei Suzuki)"
	   :license "GPL"
	   :components ,components
	   :depends-on (:cffi :cl-colors :cl-utilities :trivial-garbage :trivial-features)))

  (defun configure-components ()
	(if (member :cl-cairo2-use-base-only *features*)
		(values '(:cl-cairo2-base)
				*base*)
		(let ((features (reduce #'(lambda (fs fc) (if (member (car fc) *features*)
													  (cons (car fc) fs)
													  fs))
								*fc-map* :initial-value nil))
			  (components (reduce #'(lambda (cs fc) (if (member (car fc) *features*)
														(append cs (cdr fc))
														cs))
								  *fc-map* :initial-value nil)))
		  (if features
			  (let ((base (if (member :cl-cairo2-base features)
							  nil
							  *base*)))
				(if (and (member :cl-cairo2-gdk features) (not (member :cl-cairo2-xlib features)))
					(values (append '(:cl-cairo2-base :cl-cairo2-xlib) features)
							(append base *xlib* components))
					(values (append '(:cl-cairo2-base) features)
							(append base components))))
			  (values (reduce #'(lambda (fs fc) (cons (car fc) fs)) *fc-map* :initial-value nil)
					  (reduce #'(lambda (cs fc) (append cs (cdr fc))) *fc-map* :initial-value nil))))))

  (defmacro define-cl-cairo2-system ()
	(multiple-value-bind (features components) (configure-components)
	  `(progn
		 (dolist (f ',features) (pushnew f *features*))
		 (defsystem-cl-cairo2 ,components))))

  (define-cl-cairo2-system))
