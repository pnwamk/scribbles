#lang typed/racket
(require "vector.rkt")
(require "geometry.rkt")
(require "functional-graphics.rkt")
(require "skeleton.rkt")
(require "pattern-base.rkt")

(provide new-box-figure)

(define skel (new-skeleton-def 100))
(define body-style (r:wrap-style "black" 6 'solid (r:color 0 128 0) 'solid))
(define pat (new-pattern-def skel (r:wrap-style "black" 6 'solid "white" 'solid)))

(define neck (attach-joint! skel 0 -50))
(define head (attach-joint-rel! skel 0 -100 neck))
(define pelvis (dynamic-joint scale (head neck)
                              (v+ neck (vscale (v- neck head) scale))))
(define left-shoulder (dynamic-joint scale (head neck)
                                     (v+ neck (vscale (vrotate-origin-deg (v- head neck) -90)
                                                      (* scale 0.5)))))
(define right-shoulder (dynamic-joint scale (head neck)
                                      (v+ neck (vscale (vrotate-origin-deg (v- head neck) 90)
                                                       (* scale 0.5)))))
(define left-hip (dynamic-joint scale (neck pelvis)
                                (v+ pelvis (vscale (vrotate-origin-deg (v- neck pelvis) -90)
                                                   (* scale 0.5)))))
(define right-hip (dynamic-joint scale (neck pelvis)
                                 (v+ pelvis (vscale (vrotate-origin-deg (v- neck pelvis) 90)
                                                   (* scale 0.5)))))
(define left-hand (attach-joint-rel! skel -150 150 neck))
(define left-elbow (dynamic-joint scale (left-shoulder left-hand)
                                  (hypot-known-legs left-shoulder left-hand (* scale -0.4))))
(define right-hand (attach-joint-rel! skel 150 150 neck))
(define right-elbow (dynamic-joint scale (right-shoulder right-hand)
                                   (hypot-known-legs right-shoulder right-hand (* scale 0.4))))
(define left-foot (attach-joint-rel! skel -50 300 neck))
(define right-foot (attach-joint-rel! skel 50 300 neck))

(attach-fixed-bone! skel head neck 0.5)

(attach-limited-bone! skel left-hand left-shoulder 0.8)
(attach-limited-bone! skel right-hand right-shoulder 0.8)

(attach-fixed-bone! skel left-foot left-hip 0.8)
(attach-fixed-bone! skel right-foot right-hip 0.8)

(attach-poly! pat (list left-shoulder left-hip right-hip right-shoulder) body-style)

(attach-circle! pat head 0.7)

(attach-line! pat (cons left-foot left-hip) body-style)
(attach-line! pat (cons right-foot right-hip) body-style)
(attach-line! pat (cons left-hand left-elbow) body-style)
(attach-line! pat (cons left-elbow left-shoulder) body-style)
(attach-line! pat (cons right-hand right-elbow) body-style)
(attach-line! pat (cons right-elbow right-shoulder) body-style)

(lock-pattern! pat 'box-figure-basic)

(define new-box-figure (pattern-constructor pat))