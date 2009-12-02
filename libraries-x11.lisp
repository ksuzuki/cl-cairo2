(in-package :cl-cairo2)

;;;; Loading X11 libraries - you are supposed to set them up on the path where
;;;; the system loader looks up.

(define-foreign-library :libX11
  (:darwin "libX11.dylib")
  (:unix "libX11.so")
  #|(:windows "libX11.dll")|#)

(load-foreign-library :libX11)
