#lang racket

(require "utils.rkt")
(require "vector.rkt")

; UNUSED

(define (r:translate dx dy body)
  (lambda (dc)
    (let ((orig-transformation (send dc get-transformation)))
      (send dc translate dx dy)
      (body dc)
      (send dc set-transformation orig-transformation))))
(define (r:rotate radians body)
  (lambda (dc)
    (let ((orig-transformation (send dc get-transformation)))
      (send dc rotate radians)
      (body dc)
      (send dc set-transformation orig-transformation))))
(define (r:marker x y [radius 8])
  (r:all
   (r:line (- x radius) (- y radius) (+ x radius) (+ y radius))
   (r:line (- x radius) (+ y radius) (+ x radius) (- y radius))))
(define (r:marker-for-handle handle)
  (r:marker (v-x handle) (v-y handle)))

; USED

(define-provide (r:pen color width style . bodies)
  (lambda (dc)
    (let ((orig-pen (send dc get-pen)))
      (send dc set-pen color width style)
      (for ((body bodies))
        (body dc))
      (send dc set-pen orig-pen))))
(define-provide (r:brush color style . bodies)
  (lambda (dc)
    (let ((orig-brush (send dc get-brush)))
      (send dc set-brush color style)
      (for ((body bodies))
        (body dc))
      (send dc set-brush orig-brush))))
(define-provide (r:style pen-color pen-width pen-style brush-color brush-style . bodies)
  (r:pen pen-color pen-width pen-style
         (r:brush brush-color brush-style
                  (apply r:all bodies))))
(provide r:define-style)
(define-syntax-rule (r:define-style name pen-color pen-width pen-style brush-color brush-style)
  (define (name . bodies)
    (r:style pen-color pen-width pen-style brush-color brush-style
             (apply r:all bodies))))

(define-provide (r:line v1 v2)
  (lambda (dc)
    (send dc draw-line (v-x v1) (v-y v1) (v-x v2) (v-y v2))))
(define-provide (r:circle center rad)
  (lambda (dc)
    (send dc draw-ellipse (- (v-x center) rad) (- (v-y center) rad) (* rad 2) (* rad 2))))

(define-provide (r:all . bodies)
  (lambda (dc)
    (for ((body bodies))
      (body dc))))

(define-provide (r:render-to rf dc)
  (let ((orig-brush (send dc get-brush))
        (orig-pen (send dc get-pen))
        (orig-smoothing (send dc get-smoothing))
        (orig-transform (send dc get-transformation)))
    (send dc set-brush "green" 'solid)
    (send dc set-pen "black" 1 'solid)
    (send dc set-rotation 0)
    (send dc set-scale 1 1)
    (send dc set-smoothing 'aligned)
    (rf dc)
    (send dc set-brush orig-brush)
    (send dc set-pen orig-pen)
    (send dc set-smoothing orig-smoothing)
    (send dc set-transformation orig-transform)))