(define A (ConceptNode "A"))
(define B (ConceptNode "B"))
(define AB (AndLink A B))

(define key (PredicateNode "CDV"))

(define af (list (FloatValue 0) (FloatValue 0.5) (FloatValue 1)))
(define dvA (cog-new-dv af '(100 50 50)))

(define bf (list (FloatValue 0.25) (FloatValue 0.75)))
(define dvB (cog-new-dv bf '(100 100)))

(define cf (list (FloatValue 0) (FloatValue 1)))
(define dvC (cog-new-dv cf '(100 100)))

(define cf (list (FloatValue 0) (FloatValue 1)))
(define dvCC (cog-new-dv cf '(100 100)))

(define df (list (FloatValue 0.5)))
(define dvD (cog-new-dv df '(200)))


(cog-set-value! A key dvA)
(cog-set-value! B key dvB)

(load "pln-config.scm")

(cog-execute! and-introduction-rule)

(cog-value AB key)
