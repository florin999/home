(define (apply-strflash-effect img logo-layer bcolor npix scolor ecolor numframe)
  (let* (	
  	(width (car (gimp-drawable-width logo-layer)))
	 	(height (car (gimp-drawable-height logo-layer)))
	 	(tmpLayer)
	 	(txtLayer)
	 	(newLayer)
	 	(nframe)
	 	(cnt)
	 	(sr)
		(sg)
		(sb)
		(er)
		(eg)
		(eb)
		(incr)
		(incg)
		(incb)
		(cc)
	 	)

    	(gimp-context-push)

		(script-fu-util-image-resize-from-layer img logo-layer)
		(gimp-selection-layer-alpha logo-layer)
		(gimp-selection-grow img npix)
		(set! tmpLayer (car (gimp-layer-copy logo-layer FALSE)))
		(gimp-image-add-layer img tmpLayer 0)
		(gimp-context-set-foreground bcolor)
    	(gimp-edit-fill tmpLayer FOREGROUND-FILL)
    	(gimp-selection-layer-alpha logo-layer)
    	(set! txtLayer (car (gimp-image-merge-visible-layers img 0)))
    	
    	(gimp-context-set-foreground scolor)
    	(gimp-edit-fill txtLayer FOREGROUND-FILL)
    	
    	(set! nframe (- numframe 1))
    	(if (> nframe 0)
    	(begin
		(set! cnt 0)
		(set! sr (car scolor))
		(set! sg (car (cdr scolor)))
		(set! sb (caddr scolor))
		(set! er (car ecolor))
		(set! eg (car (cdr ecolor)))
		(set! eb (caddr ecolor))
		(set! incr (/ (- er sr) nframe))
		(set! incg (/ (- eg sg) nframe))
		(set! incb (/ (- eb sb) nframe))
		(while (< cnt nframe)
    		(set! newLayer (car (gimp-layer-copy txtLayer FALSE)))
			(gimp-image-add-layer img newLayer 0)
			(set! sr (+ sr incr))
			(if (< sr 0) (set! sr (+ sr 255)))
			(if (> sr 255) (set! sr (- sr 255)))
			(set! sg (+ sg incg))
			(if (< sg 0) (set! sg (+ sg 255)))
			(if (> sg 255) (set! sg (- sg 255)))
			(set! sb (+ sb incb))
			(if (< sb 0) (set! sb (+ sb 255)))
			(if (> sb 255) (set! sb (- sb 255)))
			(set! cc (list sr sg sb))
			(gimp-context-set-foreground cc)
    		(gimp-edit-fill newLayer FOREGROUND-FILL)
		
			(set! cnt (+ cnt 1))
		)
		))
     
    	(gimp-selection-none img)
    	(gimp-context-set-foreground '(255 255 255))

    	(gimp-context-pop)
  )
)

(define (script-fu-strflash text size font anti bcolor npix scolor ecolor numframe)
  (let* (
		(img (car (gimp-image-new 256 256 RGB)))
	 	(text-layer (car (gimp-text-fontname img -1 0 0 text 10 anti size PIXELS font)))
		)

		(gimp-image-undo-disable img)
		(gimp-drawable-set-name text-layer "      ")
		
		(apply-strflash-effect img text-layer bcolor npix scolor ecolor numframe)
		
		(gimp-image-undo-enable img)
		(gimp-display-new img)
  )
)

(script-fu-register "script-fu-strflash"
		    _"_       ..."
		    "                           "
		    "JamesH"
		    "JamesH"
		    "05/04/2006"
		    ""
		    SF-TEXT       _"Text"                "The Gimp"
		    SF-ADJUSTMENT _"Font size (pixels)" '(32 2 1000 1 10 0 1)
		    SF-FONT       _"Font"               "Becker"
		    SF-TOGGLE     "      "              TRUE
		    SF-COLOR      _"            "         '(252 252 252)
		    SF-ADJUSTMENT "            "          '(1 1 16 1 8 0 0)
		    SF-COLOR      _"            "         '(228 60 200)
		    SF-COLOR      _"            "         '(28 180 28)
			SF-ADJUSTMENT "         "            '(2 1 32 1 8 0 0))
			
(script-fu-menu-register "script-fu-strflash"
			 _"<Toolbox>/Xtns/Script-Fu/Logos")
