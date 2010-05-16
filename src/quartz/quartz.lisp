(in-package :cl-cairo2)

;;;;
;;;; quartz surface and fonts
;;;;

(defun quartz-font-face-create-for-cgfont (cgfont-ref)
  (cairo_quartz_font_face_create_for_cgfont cgfont-ref))

#-x86-64
(defun quartz-font-face-create-for-atsu-font-id (atsu-font-id)
  (cairo_quartz_font_face_create_for_atsu_font_id atsu-font-id))

(defun quartz-surface-create (format width height)
  (let ((surface (make-instance 'surface :width width :height height :pixel-based-p t)))
	(setf (slot-value surface 'pointer) (cairo_quartz_surface_create (lookup-enum format table-format) width height))
	surface))

(defun quartz-surface-create-for-cg-context (cg-context-ref width height)
  (let ((surface (make-instance 'surface :width width :height height :pixel-based-p t)))
	(setf (slot-value surface 'pointer) (cairo_quartz_surface_create_for_cg_context cg-context-ref width height))
	surface))

(defun quartz-surface-get-cg-context (surface)
  (let ((cg-context (cairo_quartz_surface_get_cg_context (slot-value surface 'pointer))))
	(if (null-pointer-p cg-context)
		nil
		cg-context)))

(defmacro with-quartz-cg-context ((cg-context-ref width height &optional (surface-name (gensym)))
								  &body body)
  `(let* ((,surface-name (quartz-surface-create-for-cg-context ,cg-context-ref ,width ,height))
		  (*context* (create-context ,surface-name)))
	 (unwind-protect (progn ,@body)
	   (progn
		 (destroy *context*)
		 (destroy ,surface-name)))))

#-x86-64
(defmacro with-quartz-atsu-font ((atsu-font-id &optional (context '*context*))
								 &body body)
  (let ((cfft (gensym)))
	`(let ((,cfft (quartz-font-face-create-for-atsu-font-id ,atsu-font-id)))
	   (with-cairo-font (,cfft ,context) ,@body))))

(defmacro with-quartz-cg-font ((cgfont-ref &optional (context '*context*))
							   &body body)
  (let ((cfft (gensym)))
	`(let ((,cfft (quartz-font-face-create-for-cgfont ,cgfont-ref)))
	   (with-cairo-font (,cfft ,context) ,@body))))

(defmacro with-quartz-context ((format width height &optional (surface-name (gensym)))
							   &body body)
  `(let* ((,surface-name (quartz-surface-create (lookup-enum ,format table-format) ,width ,height))
		  (*context* (create-context ,surface-name)))
	 (unwind-protect (progn ,@body)
	   (progn
		 (destroy *context*)
		 (destroy ,surface-name)))))

(export '(quartz-font-face-create-for-cgfont
		  #-x86-64 quartz-font-face-create-for-atsu-font-id
          quartz-surface-create
		  quartz-surface-create-for-cg-context
		  quartz-surface-get-cg-context
		  #-x86-64 with-quartz-atsu-font
		  with-quartz-cg-font
		  with-quartz-cg-context
		  with-quartz-context))
