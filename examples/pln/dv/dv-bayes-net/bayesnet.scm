


(define R (ConceptNode "Rain"))
(define S (ConceptNode "Sprinkler"))
(define W (ConceptNode "Grass Wet"))
(define SR (InheritanceLink R S))
;(define RS (InheritanceLink S R))
(define RandS (ProductLink R S))
(define WRS (InheritanceLink (ProductLink R S) W))

;(define CS (ConceptNode "Sprinkler"))

(define key (PredicateNode "CDV"))
(define zo (list (FloatValue 0) (FloatValue 1)))

(define (with-cdv atom conds dvs) (cog-set-value! atom key (cog-new-cdv conds dvs)))


(cog-set-value! R key (cog-new-dv zo '(80000 20000)))

;(cog-set-value! CS key (cog-new-dv zo '(0 1)))

(define dvSR0 (cog-new-dv zo '(48000 32000)))
(define dvSR1 (cog-new-dv zo '(19800 200)))
(with-cdv SR zo (list dvSR0 dvSR1))

(define conds (list (ProductLink (NumberNode 0) (NumberNode 0))
                    (ProductLink (NumberNode 0) (NumberNode 1))
                    (ProductLink (NumberNode 1) (NumberNode 0))
                    (ProductLink (NumberNode 1) (NumberNode 1))
              )
)

(define dvWRS00 (cog-new-dv zo '(48000 0)))
(define dvWRS01 (cog-new-dv zo '(3200 28800)))
(define dvWRS10 (cog-new-dv zo '(3960 15840)))
(define dvWRS11 (cog-new-dv zo '(2 198)))

(with-cdv WRS conds (list dvWRS00 dvWRS01 dvWRS10 dvWRS11))

(define dvR (cog-value R key))
(define dvSR (cog-value SR key))
;(define dvCS (cog-value CS key))
(define dvWRS (cog-value WRS key))
(define dvRandS (cog-cdv-get-joint dvSR dvR))
;(define dvS (cog-cdv-get-unconditional dvSR dvR))
;
;(define dvRS (cog-dv-divide dvRandS dvS 0))
;
;(define dvCR (cog-cdv-get-unconditional dvRS dvCS))

(load "pln-config.scm")

;Run Inference manually
(cog-execute! modus-ponens-inheritance-rule)
;(display (cog-value S key))
(cog-execute! joint-inheritance-introduction-rule)
;(cog-cdv-get-joint dvWRS dvRandS)
;(display (cog-value S key))
(cog-execute! joint-reduction-rule)
;(display (cog-value S key))
(cog-execute! modus-ponens-inheritance-rule)
;(display (cog-value S key))
(cog-execute! joint-to-inheritance-second-rule)
(cog-value (Inheritance W R) key)
