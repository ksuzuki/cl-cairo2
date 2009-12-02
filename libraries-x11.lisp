(in-package :cl-cairo2)

;;;; Loading X11 and GDK libraries - you are supposed to set them up on the
;;;; path where the system loader looks up.

(define-foreign-library :libX11
  (:darwin "libX11.dylib")
  (:unix "libX11.so"))

(load-foreign-library :libX11)

(define-foreign-library :gdk
  ;; 'darwin' comes before 'unix' because Mac OS X defines them both.
  (:darwin "libgdk-x11-2.0.dylib")
  (:unix (:or "libgdk-x11-2.0.so" "libgdk-x11-2.0.so.0"))
  (:windows "libgdk-win32-2.0-0.dll"))

(load-foreign-library :gdk)
