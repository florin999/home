; The GIMP -- an img manipulation program
; Copyright (C) 1995 Spencer Kimball and Peter Mattis
; -----------------------------------------------------------------------
; The GIMP script-fu  Soft-Focus.scm  for GIMP2.2
; Copyright (C) 2005 Tamagoro <tamagoro_1@excite.co.jp>
; -----------------------------------------------------------------------
;                                                                      
;                                                                             
;                                                                            
;                                                                            
; 640  480   10   1024  768   15                         
;                                                                                                  
; ************************************************************************

(define (script-fu-softfocus image drawable blur contrast new-layer)

(let* ((img (car (gimp-image-duplicate image)))
 	   (select (car (gimp-selection-is-empty image))) 
       (base) (copy-layer) (copy-layer2) (edge-layer)
       (color-layer) (blur-layer) (blur-layer1) (mask)
       (blur-layer2) (merge-layer) (base) (contrast-layer) 
       (backup-layer) (old-selection) (floating-sel)
)


 	(gimp-image-undo-group-start image)

 	(if (= select FALSE) 
 	    (begin 
          (set! backup-layer (car (gimp-layer-copy base 1)))
          (set! old-selection (car (gimp-selection-save img)))
 	      (gimp-selection-none img) ))

 	(set! base (car (gimp-image-get-active-layer img)))
 	(gimp-drawable-set-visible base TRUE)
 	(gimp-layer-set-opacity base 100)
 	(set! copy-layer (car (gimp-layer-copy base 1)))
 	(set! copy-layer2 (car (gimp-layer-copy base 1)))
 	(set! edge-layer (car (gimp-layer-copy base 1)))
 	(set! color-layer (car (gimp-layer-copy base 1))) 

 	(gimp-image-add-layer img copy-layer -1)
 	(plug-in-gauss-iir2 1 img copy-layer blur blur)
 	(set! blur-layer (car (gimp-layer-copy copy-layer 1)))
 	(gimp-layer-set-mode copy-layer SCREEN)

 	(set! blur-layer1 (car (gimp-layer-copy blur-layer 1)))
 	(gimp-image-add-layer img blur-layer1 -1)
 	(gimp-layer-set-mode blur-layer1 MULTIPLY)
 	(set! mask (car (gimp-layer-create-mask blur-layer1 5)))
 	(gimp-image-add-layer-mask img blur-layer1 mask)
 	(gimp-layer-remove-mask blur-layer1 0)

 	(set! blur-layer2 (car (gimp-layer-copy blur-layer1 1)))
 	(gimp-image-add-layer img blur-layer2 -1)
 	(gimp-layer-set-mode blur-layer2 OVERLAY)

 	(gimp-image-merge-down img copy-layer 0)
 	(gimp-image-merge-down img blur-layer1 0)
 	(gimp-image-merge-down img blur-layer2 0)

 	(gimp-image-add-layer img blur-layer -1)
 	(gimp-image-add-layer img copy-layer2 -1)
 	(gimp-layer-set-mode copy-layer2 OVERLAY)
 	(set! merge-layer (car (gimp-image-merge-down img copy-layer2 0)))
 	(gimp-layer-set-opacity merge-layer 10)
 	(gimp-image-merge-down img merge-layer 0)

 	(gimp-image-add-layer img edge-layer -1)
 	(set! mask (car (gimp-layer-create-mask edge-layer 5)))
 	(gimp-image-add-layer-mask img edge-layer mask)
 	(plug-in-edge 1 img mask 1.0 1 4)
  	(plug-in-blur 1 img mask)
  	(gimp-levels-auto mask)
 	(gimp-layer-remove-mask edge-layer 0)
 	(gimp-layer-set-opacity edge-layer 50)
 	(set! base (car (gimp-image-merge-down img edge-layer 0)))

 	(set! contrast-layer (car (gimp-layer-copy base 1)))
 	(gimp-image-add-layer img contrast-layer -1)
 	(gimp-layer-set-mode contrast-layer 18)
 	(gimp-layer-set-opacity contrast-layer contrast)
 	(gimp-image-merge-down img contrast-layer 0)

 	(gimp-image-add-layer img color-layer -1)
 	(gimp-layer-set-mode color-layer COLOR)
 	(gimp-layer-set-opacity color-layer (/ contrast 3))
 	(set! base (car (gimp-image-merge-down img color-layer 0)))

 	(if (= select FALSE)
 	    (begin 
 	      (if (equal? new-layer TRUE)
 	          (begin
 	            (gimp-selection-load old-selection)
 	            (gimp-selection-invert img)
 	            (gimp-edit-clear base)
 	            (gimp-selection-none img) )
 	          (begin
 	            (gimp-image-add-layer img backup-layer -1)
 	            (gimp-selection-load old-selection)
 	            (gimp-edit-clear backup-layer)
  	            (set! base (car (gimp-image-merge-down img backup-layer 0)))
 	            (gimp-selection-none img) )) ))

 	(gimp-edit-copy base) 

 	(if (equal? new-layer TRUE)
 	    (begin 
 	      (set! floating-sel (car (gimp-edit-paste drawable TRUE)))
  	      (gimp-drawable-set-name floating-sel "Soft Focus"))
 	    (gimp-floating-sel-anchor (car (gimp-edit-paste drawable TRUE))) )

 	(gimp-image-delete img) 
 	(gimp-image-undo-group-end image)
 	(gimp-displays-flush) ))


(script-fu-register "script-fu-softfocus"
 	"Soft Focus..."
"                                                "
 	"         "
 	"Tamagoro <tamagoro_1@excite.co.jp>"
 	"2005/01"
 	"RGB*, GRAY*"
 	SF-IMAGE      "Image"     0
 	SF-DRAWABLE   "Drawable"  0
 	SF-ADJUSTMENT "               "   '(10 5 30 1 10 0 0) 
 	SF-ADJUSTMENT "                  " '(30 0 100 1 10 0 0) 
 	SF-TOGGLE     "                  "  FALSE 
)

(script-fu-menu-register "script-fu-softfocus"
 	"<Image>/Script-Fu/Photo") 
