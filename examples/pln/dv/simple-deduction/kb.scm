(define A (ConceptNode "A"))
(define B (ConceptNode "B"))
(define C (ConceptNode "C"))
(define AB (InheritanceLink A B))
(define BC (InheritanceLink B C))
(define AC (InheritanceLink A C))

(define zo (list (FloatValue 0) (FloatValue 1)))

(define z2 (list (FloatValue 0.1) (FloatValue 0.9)))

(define key (PredicateNode "CDV"))

(define (with-cdv atom dvs) (cog-set-value! atom key (cog-new-cdv zo dvs)))

(define dvAB1 (cog-new-dv zo '(0 0)))
(define dvAB2 (cog-new-dv z2 '(0 100)))

(define dvBC1 (cog-new-dv zo '(0 0)))
(define dvBC2 (cog-new-dv zo '(10 90)))

(with-cdv AB (list dvAB1 dvAB2))
(with-cdv BC (list dvBC1 dvBC2))

AB
BC

(load "pln-config.scm")

(cog-execute! deduction-inheritance-rule)

(cog-value AC key)
