;; =============================================================================
;; Contraposition rule
;;
;; <implication-type-link>
;;   A
;;   B
;; |-
;; <implication-type-link>
;;   Not B
;;   Not A
;;
;; where <implication-type-link> can be
;;
;; ImplicationLink
;; InheritanceLink
;; etc
;;
;; This rule just a combination of the joint-introduction, joint-to-conditional rules
;; and negation
;;
;; ReAdd Scoped link type , tvs have a crips version
;;
;; TODO: maybe we want shortcut rules such as
;;
;; <implication-type-link>
;;   Not A
;;   B
;; |-
;; <implication-type-link>
;;   Not B
;;   A
;;
;; to avoid having to introduce negations in order to match the rule
;; conclusion, as the backward chainer would.
;; -----------------------------------------------------------------------------

;; Generate the corresponding contraposition rule given its unscope
;; link-type.
(define (gen-contraposition-rule link-type)
  (let* ((A (Variable "$A"))
         (B (Variable "$B"))
         (AB (link-type A B))
         (NBNA (link-type (Not B) (Not A)))
         (vardecl (VariableList A B))
         (clause AB)
         (precondition (AndLink
						 (Evaluation
							(GroundedSchema "scm: has-dv")
							 AB)
						 (Evaluation
							(GroundedSchema "scm: has-dv")
							 A)
						 (Evaluation
							(GroundedSchema "scm: has-dv")
							 B))
         (rewrite (ExecutionOutput
                    (GroundedSchema "scm: contraposition-formula")
                    (List
                      NBNA
                      AB
                      A
                      B))))
    (Bind
      vardecl
      (And
        clause
        precondition)
      rewrite)))

(define (contraposition-formula NBNA AB A B)
	(let*
        ((key (PredicateNode "CDV"))
		 (cdvAB (cog-value AB key))
         (dvA (cog-value A key))
         (dvB (cog-value B key))
		 (dvJ (cog-cdv-get-joint cdvAB dvA))
		 (dvNJ (cog-negate dvJ))
		 (dvNB (cog-negate dvB))
		 (dvNBNA (cog-dv-divide dvNJ dvNB 0))
		)
		(cog-set-value! NBNA key dvNBNA)
	)
)

(define contraposition-implication-rule
  (gen-contraposition-rule ImplicationLink))
(define contraposition-implication-rule-name
  (DefinedSchemaNode "contraposition-implication-rule"))
(DefineLink contraposition-implication-rule-name
  contraposition-implication-rule)

(define contraposition-inheritance-rule
  (gen-contraposition-rule InheritanceLink))
(define contraposition-inheritance-rule-name
  (DefinedSchemaNode "contraposition-inheritance-rule"))
(DefineLink contraposition-inheritance-rule-name
  contraposition-inheritance-rule)
