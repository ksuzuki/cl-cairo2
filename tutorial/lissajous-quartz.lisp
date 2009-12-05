;;;; -*- Mode: Lisp; Package: lissajous-quartz -*-
;;;; lissajous-quartz.lisp 
;;;;
;;;; This sample code is to demonstrate rendering on Quartz surface of Cairo
;;;; from cl-cairo2.
;;;;
;;;; Based on an example called 'tiny.lisp' of Clozure CL, it is modifed
;;;; shamelessly to work on Clozure CL with Cairo and cl-cairo2.
;;;;
;;;; >>> Start the original comments of tiny.lisp >>>
;;;;
;;;; A fairly direct translation into Lisp of the Tiny application (Chapter 4) 
;;;; from "Building Cocoa Applications" by Garfinkel and Mahoney 
;;;;
;;;; The original Tiny example was meant to illustrate the programmatic use of
;;;; Cocoa without Interface Builder.  Its purpose here is to illustrate the
;;;; programmatic use of the Cocoa bridge. 
;;;;
;;;; Copyright (c) 2003 Randall D. Beer
;;;; 
;;;; This software is licensed under the terms of the Lisp Lesser GNU Public
;;;; License , known as the LLGPL.  The LLGPL consists of a preamble and 
;;;; the LGPL. Where these conflict, the preamble takes precedence.  The 
;;;; LLGPL is available online at http://opensource.franz.com/preamble.html.
;;;;
;;;; Please send comments and bug reports to <beer@eecs.cwru.edu>
;;;;
;;;; <<< End the original comments of tiny.lisp <<<

(defpackage :lissajous-quartz
  (:use :cl :cl-cairo2 :ccl))

(in-package :lissajous-quartz)

(require :cocoa)

(defclass lissajous-view (ns:ns-view)
  ()
  (:metaclass ns:+ns-object))

(defparameter x 80)
(defparameter y 16)
(defparameter size 500)
(defparameter margin 20)
(defparameter a 9)
(defparameter b 8)
(defparameter delta (/ pi 2))
(defparameter density 2000)

(defun show-text-aligned (text x y &optional (x-align 0.5) (y-align 0.5))
  "Show text aligned relative to (x,y)."
  (multiple-value-bind (x-bearing y-bearing width height)
	  (text-extents text)
	(move-to (- x (* width x-align) x-bearing)
			 (- y (* height y-align) y-bearing))
	(show-text text)))

(objc:defmethod (#/drawRect: :void) ((self lissajous-view) (rect :<NSR>ect))
  (declare (ignorable rect))
  (let* ((cg-context-ref (#/graphicsPort (#/currentContext ns:ns-graphics-context)))
		 (bounds (#/bounds self))
		 (double-width (ns:ns-rect-width bounds))
		 (double-height (ns:ns-rect-height bounds))
		 (width (#/unsignedIntValue (make-instance 'ns:ns-number :init-with-double double-width)))
		 (height (#/unsignedIntValue (make-instance 'ns:ns-number :init-with-double double-height))))
	;; Flip the coordinate from the Quartz coordinate to the Cairo coordinate.
	(#_CGContextTranslateCTM cg-context-ref 0.0D0 double-height)
	(#_CGContextScaleCTM cg-context-ref 1.0D0 -1.0D0)
	;; Preparation for using the CGFont Helvetica-Bold.
	(with-cstrs ((helvetica-bold "Helvetica-Bold"))
	  (let* ((cfstr-ref (#_CFStringCreateWithCString +null-ptr+ helvetica-bold #$kCFStringEncodingUTF8))
			 (cgfont-ref (#_CGFontCreateWithFontName cfstr-ref)))
		;;
		;; Draw lissajous using the cl-cairo2 rendering calls.
		;;
		(with-quartz-cg-context (cg-context-ref width height)
		  (let ((size (if (< width height) width height)))
			;; pastel blue background
			(rectangle 0 0 width height)
			(set-source-rgb 0.9 0.9 1)
			(fill-path)
			;; Lissajous curves, blue
			(labels ((stretch (x) (+ (* (1+ x) (- (/ size 2) margin)) margin)))
			  (move-to (stretch (sin delta)) (stretch 0))
			  (dotimes (i density)
				(let* ((v (/ (* i pi 2) density))
					   (x (sin (+ (* a v) delta)))
					   (y (sin (* b v))))
				  (line-to (stretch x) (stretch y)))))
			(close-path)
			(set-line-width .5)
			(set-source-rgb 0 0 1)
			(stroke)
			;; Write 'cl-cairo2' in the center.
			(with-quartz-cg-font (cgfont-ref)
			  (set-font-size 100)
			  (set-source-rgba 1 0.75 0 0.5) ; orange
			  (show-text-aligned "cl-cairo2" (/ size 2) (/ size 2)))))
		;;
		;; You are responsible for this.
		(#_CGFontRelease cgfont-ref)))))

(defun run ()
  (ccl::with-autorelease-pool
    (let* ((r (ns:make-ns-rect 110 110 600 600))
           (w (make-instance 
			   'ns:ns-window
			   :init-with-content-rect r
			   :style-mask (logior #$NSTitledWindowMask 
								   #$NSClosableWindowMask 
								   #$NSMiniaturizableWindowMask
								   #$NSResizableWindowMask)
			   :backing #$NSBackingStoreBuffered
			   :defer t)))
      (#/setTitle: w #@"lissajous")
      (let ((my-view (make-instance 'lissajous-view :with-frame r)))
        (#/setContentView: w my-view)
        (#/setDelegate: w my-view))
      (#/performSelectorOnMainThread:withObject:waitUntilDone:
       w (objc:@selector "makeKeyAndOrderFront:") nil nil)
      w)))
