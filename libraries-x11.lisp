(in-package :cl-cairo2)

;;;; Loading X11 library - you are supposed to set it up on the path where
;;;; the system's library loader looks up.
;;;; Also, the library search order should look like below because on Mac both
;;;; 'darwin' and 'unix' are defined in *feature* and we want to load .dylib
;;;; version of library.

(define-foreign-library :libX11
  (:darwin "libX11.dylib")
  (:unix "libX11.so")
  #|(:windows "libX11.dll")|#)

(load-foreign-library :libX11)
