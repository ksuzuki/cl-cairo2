;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(defpackage #:cl-cairo2-quartz-asd
  (:use :cl :asdf :cl-cairo2))

(in-package #:cl-cairo2-quartz-asd)

(defsystem cl-cairo2-quartz
  :description "Cairo 1.8 bindings, Quartz plus xlib surfaces and GTK extension"
  :version "0.1"
  :author "Tamas K Papp, Kei Suzuki"
  :license "GPL"
  :serial t
  :components
  ((:module
    "quartz surface"
    :pathname #P"src/quartz/"
    :serial t
    :components
    ((:file "cl-cairo2-quartz-swig")
     (:file "quartz")))
   (:module
    "xlib surface"
    :pathname #P"src/xlib/"
    :serial t
    :components
    ((:file "load-libraries-x11")
     (:file "xlib")
     (:file "xlib-image-context")
     (:file "gtk-context"))))
  :depends-on (:cl-cairo2))
