(define A (ConceptNode "A"))
(define B (ConceptNode "B"))
(define C (ConceptNode "C"))
(define AB (InheritanceLink A B))
(define BC (InheritanceLink B C))
(define AC (InheritanceLink A C))

(define zo (list (NumberNode 0) (NumberNode 1)))

(define key (PredicateNode "CDV"))

(define (with-cdv atom dvs) (cog-set-value! atom key (cog-new-cdv zo dvs)))

(define dvAB1 (cog-new-dv zo '(0 0)))
(define dvAB2 (cog-new-dv zo '(0.5 0.5)))

(define dvBC1 (cog-new-dv zo '(0 0)))
(define dvBC2 (cog-new-dv zo '(0.5 0.5)))

(with-cdv AB (list dvAB1 dvAB2))
(with-cdv BC (list dvBC1 dvBC2))

(cog-execute! deduction-inheritance-rule)
