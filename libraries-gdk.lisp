(in-package :cl-cairo2)

;;;; Loading GDK library - you are supposed to set it up on the path where
;;;; the system's library loader looks up.
;;;; Also, the library search order should look like below because on Mac both
;;;; 'darwin' and 'unix' are defined in *feature* and we want to load .dylib
;;;; version of library.

(define-foreign-library :gdk
  ;; 'darwin' comes before 'unix' because Mac OS X defines them both.
  (:darwin "libgdk-x11-2.0.dylib")
  (:unix (:or "libgdk-x11-2.0.so" "libgdk-x11-2.0.so.0"))
  (:windows "libgdk-win32-2.0-0.dll"))

(load-foreign-library :gdk)
