; multi-burst-to-anim.scm   version 1.0   2009/10/30
;
; Copyright (C) 2009 Camilo Vejarano A. <mo-no-e@gmail.com>
;
; Takes a multi-burst photograph and generates an animated gif file.
;

(define (cli-multi-burst-to-anim pattern 
                              rows 
                              cols 
                              delayMsec
                              loop4ever 
                              rotate
                              )
  (let* ((filelist (cadr (file-glob pattern 1))))
    (while (not (null? filelist))
      (let* ( 
          (cic-col 0)
          (cic-row 0)
          (filename (car filelist))
          (img (car (gimp-file-load RUN-NONINTERACTIVE filename filename)))
          (drawable (car (gimp-image-get-active-layer img)))
          (width   (/ (car (gimp-image-width  img)) cols)) 
          (height  (/ (car (gimp-image-height img)) rows))
          (image (car (gimp-image-new width height RGB))) 
          (newlayer (car (gimp-layer-new image width height 0 "Layer 1" 100 NORMAL-MODE))))
  
      ; (gimp-image-undo-disable image)
      (while(< cic-row rows)
        
        (set! cic-col 0)
        
        (while (< cic-col cols)

          (gimp-selection-none img)  ; Clears selection.
          (gimp-rect-select img (* cic-col width) (* cic-row height) width height CHANNEL-OP-ADD FALSE 0)
          (gimp-edit-copy-visible img)

          (set! newlayer (car (gimp-layer-new image width height 0 (string-append "Frame " (number->string (+ cic-col (* rows cic-row)))) 100 NORMAL-MODE)))

          (gimp-image-add-layer image newlayer 0)
          (gimp-floating-sel-anchor (car (gimp-edit-paste newlayer TRUE)))

          (set! cic-col (+ cic-col 1))
        ) ;while
        
        (set! cic-row (+ cic-row 1))
      ) ;while
     
      (if (= rotate 1) (gimp-image-rotate image 0))
      (if (= rotate 2) (gimp-image-rotate image 2))

      (gimp-image-convert-indexed image 3 0 255 FALSE FALSE "0")
      (file-gif-save RUN-NONINTERACTIVE image (car (gimp-image-get-active-drawable image)) (string-append (car (gimp-image-get-filename img)) "-anim.gif")   (string-append (car (gimp-image-get-filename img)) "-anim.gif")   0 loop4ever delayMsec 0)

      ; (gimp-image-undo-enable image)
      )
    )
  )
)