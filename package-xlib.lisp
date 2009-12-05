(in-package :cl-cairo2)

(export '(#-cl-cairo2-use-xlib-context create-xlib-image-context
		  #-cl-cairo2-use-xlib-context xlib-image-context
		  #+cl-cairo2-use-xlib-context create-xlib-context
		  #+cl-cairo2-use-xlib-context xlib-context))
