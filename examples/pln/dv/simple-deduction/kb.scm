(define A (ConceptNode "A"))
(define B (ConceptNode "B"))
(define C (ConceptNode "C"))
(define AB (InheritanceLink A B))
(define BC (InheritanceLink B C))
(define AC (InheritanceLink A C))

(define zo (list (list '(0 0.5)) (list '(0.5 1))))
(define z1 (list (list '(0.5 1))))


(define z2 (list (list '(0.1 0.5)) (list '(0.5 0.9))))

(define z3 (list (list '(0.5 0.9))))

(define key (PredicateNode "CDV"))

(define dvAB2 (cog-new-dv z3 '(100)))

(define dvBC2 (cog-new-dv zo '(10 90)))

(define dvAB (cog-new-cdv z1 (list dvAB2)))
(define dvBC (cog-new-cdv z1 (list dvBC2)))

(cog-set-value! AB key dvAB)
(cog-set-value! BC key dvBC)

(load "pln-config.scm")

(cog-execute! deduction-inheritance-rule)

(cog-value AC key)
