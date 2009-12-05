(in-package :cl-cairo2)

;;;;
;;;; quartz surface and fonts
;;;;

(defun create-quartz-font-face-for-cgfont (cgfont-ref)
  (cairo_quartz_font_face_create_for_cgfont cgfont-ref))

(defun create-quartz-surface (format width height)
  (let ((surface (make-instance 'surface :width width :height height :pixel-based-p t)))
	(setf (slot-value surface 'pointer) (cairo_quartz_surface_create (lookup-enum format table-format) width height))
	surface))

(defun create-quartz-surface-for-cg-context (cg-context-ref width height)
  (let ((surface (make-instance 'surface :width width :height height :pixel-based-p t)))
	(setf (slot-value surface 'pointer) (cairo_quartz_surface_create_for_cg_context cg-context-ref width height))
	surface))

#-x86-64
(defun create-quartz-font-face-for-atsu-font-id (atsu-font-id)
  (cairo_quartz_font_face_create_for_atsu_font_id atsu-font-id))

(defun get-quartz-surface-cg-context (surface)
  (let ((cg-context (cairo_quartz_surface_get_cg_context (slot-value surface 'pointer))))
	(if (null-pointer-p cg-context)
		nil
		cg-context)))

(defmacro with-quartz-cg-context ((cg-context-ref width height &optional (surface-name (gensym)))
								  &body body)
  `(let* ((,surface-name (create-quartz-surface-for-cg-context ,cg-context-ref ,width ,height))
		  (*context* (create-context ,surface-name)))
	   (unwind-protect (progn ,@body)
		 (progn
		   (destroy *context*)
		   (destroy ,surface-name)))))

#-x86-64
(defmacro with-quartz-atsu-font ((atsu-font-id &optional (context '*context*))
								 &body body)
  (let ((cfft (gensym)))
	`(let ((,cfft (create-quartz-font-face-for-atsu-font-id ,atsu-font-id)))
	   (with-cairo-font (,cfft ,context) ,@body))))

(defmacro with-quartz-cg-font ((cgfont-ref &optional (context '*context*))
								 &body body)
  (let ((cfft (gensym)))
	`(let ((,cfft (create-quartz-font-face-for-cgfont ,cgfont-ref)))
	   (with-cairo-font (,cfft ,context) ,@body))))

(defmacro with-quartz-context ((format width height &optional (surface-name (gensym)))
							   &body body)
  `(let* ((,surface-name (create-quartz-surface (lookup-enum ,format table-format) ,width ,height))
		  (*context* (create-context ,surface-name)))
	   (unwind-protect (progn ,@body)
		 (progn
		   (destroy *context*)
		   (destroy ,surface-name)))))
