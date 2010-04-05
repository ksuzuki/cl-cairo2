;;; This file was automatically generated by SWIG (http://www.swig.org).
;;; Version 1.3.40
;;;
;;; Do not make changes to this file unless you know what you are doing--modify
;;; the SWIG interface file instead.

(in-package :cl-cairo2)



(cl:defconstant CL_CAIRO2_USING_QUARTZ 1)

(cl:defconstant CAIRO_HAS_QUARTZ_SURFACE 1)

(cl:defconstant CAIRO_HAS_QUARTZ_FONT 1)

(cl:defconstant __LP64__ 1)

(cffi:defcenum cairo_format_t
	:CAIRO_FORMAT_ARGB32
	:CAIRO_FORMAT_RGB24
	:CAIRO_FORMAT_A8
	:CAIRO_FORMAT_A1)

(cffi:defcfun ("cairo_quartz_surface_create" cairo_quartz_surface_create) :pointer
  (format cairo_format_t)
  (width :unsigned-int)
  (height :unsigned-int))

(cffi:defcfun ("cairo_quartz_surface_create_for_cg_context" cairo_quartz_surface_create_for_cg_context) :pointer
  (cgContext :pointer)
  (width :unsigned-int)
  (height :unsigned-int))

(cffi:defcfun ("cairo_quartz_surface_get_cg_context" cairo_quartz_surface_get_cg_context) :pointer
  (surface :pointer))

(cffi:defcfun ("cairo_quartz_font_face_create_for_cgfont" cairo_quartz_font_face_create_for_cgfont) :pointer
  (font :pointer))


