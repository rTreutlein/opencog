;; =============================================================================
;; DeductionRule
;;
;; <LinkType>
;;   A
;;   B
;; <LinkType>
;;   B
;;   C
;; |-
;; <LinkType>
;;   A
;;   C
;;
;; Due to type system limitations, the rule has been divided into 3:
;;       deduction-inheritance-rule
;;       deduction-implication-rule
;;       deduction-subset-rule
;;
;; This deduction rule makes assumptions to avoid having too many
;; premises. Another more precise rule should be created as well.
;;
;; -----------------------------------------------------------------------------

(use-modules (opencog logger))

;; Generate the corresponding deduction rule given its link-type and
;; the type for each variable (the same for all 3).
(define (gen-deduction-rule link-type var-type)
  (let* ((A (Variable "$A"))
         (B (Variable "$B"))
         (C (Variable "$C"))
         (AB (link-type A B))
         (BC (link-type B C))
         (AC (link-type A C)))
    (Bind
      (VariableList
        (TypedVariable A var-type)
        (TypedVariable B var-type)
        (TypedVariable C var-type))
      (And
        (Evaluation
          (GroundedPredicate "scm: has-dv")
          AB)
        (Evaluation
          (GroundedPredicate "scm: has-dv")
          BC)
        AB
        BC
        (Not (Identical A C)))
      (ExecutionOutput
        (GroundedSchema "scm: deduction-formula")
        (List
          ;; Conclusion
          AC
          ;; Premises
          AB
          BC)))))

(define deduction-inheritance-rule
  (let ((var-type (TypeChoice
                    (TypeNode "ConceptNode")
                    (TypeNode "AndLink")
                    (TypeNode "OrLink")
                    (TypeNode "NotLink"))))
    (gen-deduction-rule InheritanceLink var-type)))

(define deduction-implication-rule
  (let ((var-type (TypeChoice
                    (TypeNode "PredicateNode")
                    (TypeNode "LambdaLink")
                    (TypeNode "AndLink")
                    (TypeNode "OrLink")
                    (TypeNode "NotLink"))))
    (gen-deduction-rule ImplicationLink var-type)))

(define deduction-subset-rule
  (let ((var-type (TypeChoice
                    (TypeNode "ConceptNode")
                    (TypeNode "AndLink")
                    (TypeNode "OrLink")
                    (TypeNode "NotLink"))))
    (gen-deduction-rule SubsetLink var-type)))

(define curry2 (lambda (f) (lambda (arg1) (lambda (arg2) (f arg1 arg2)))))

(define (deduction-formula AC AB BC)
    (let*
        ((key (PredicateNode "CDV"))
         (dvAB (cog-value AB key))
         (dvBC (cog-value BC key))
         (conds (cog-cdv-get-conditions dvAB))
         (unconds (cog-cdv-get-unconditionals dvAB))
         (x (map ((curry2 cog-cdv-get-unconditional-no-match) dvBC) unconds))
         (cdv (cog-new-cdv conds x))
		 ;(ab (cog-set-value! (ConceptNode "dvAB") key dvAB))
         ;(bc (cog-set-value! (ConceptNode "dvBC") key dvBC))
         ;(cdv (cog-set-value! (ConceptNode "cdv") key cdv))
        )
		;(Set ab bc)
        (cog-set-value! AC key cdv)
    )
)

;; Name the rules
(define deduction-inheritance-rule-name
  (DefinedSchemaNode "deduction-inheritance-rule"))

(define deduction-implication-rule-name
  (DefinedSchemaNode "deduction-implication-rule"))
(DefineLink deduction-implication-rule-name
  deduction-implication-rule)

(define deduction-subset-rule-name
  (DefinedSchemaNode "deduction-subset-rule"))
(DefineLink deduction-subset-rule-name
  deduction-subset-rule)
