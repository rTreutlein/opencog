;; =====================================================================
;; ImplicationImplicantConjunctionRule
;;
;; ImplicationLink <TV1>
;;    A
;;    C
;; ImplicationLink <TV2>
;;    B
;;    C
;; |-
;; ImplicationLink <TV>
;;    ProductLink
;;       A
;;       B
;;    C
;;----------------------------------------------------------------------

(use-modules (opencog distvalue))

(define implication-implicant-conjunction-variables
  (VariableList
     (TypedVariable
        (Variable "$A")
        (TypeChoice
           (Type "PredicateNode")
           (Type "LambdaLink")))
     (TypedVariable
        (Variable "$B")
        (TypeChoice
           (Type "PredicateNode")
           (Type "LambdaLink")))
     (TypedVariable
        (Variable "$C")
        (TypeChoice
           (Type "PredicateNode")
           (Type "LambdaLink")))))

(define implication-implicant-conjunction-body
  (AndLink
     (ImplicationLink
        (VariableNode "$A")
        (VariableNode "$C"))
     (ImplicationLink
        (VariableNode "$B")
        (VariableNode "$C"))
     (NotLink (EqualLink (VariableNode "$A") (VariableNode "$B")))))

(define implication-implicant-conjunction-precond
	(AndLink
		(Evaluation
			(GroundedPredicate "scm: has-dv")
				(ImplicationLink
			      (VariableNode "$A")
			      (VariableNode "$C"))
		)
        (Evaluation
			(GroundedPredicate "scm: has-dv")
				(ImplicationLink
			      (VariableNode "$B")
			      (VariableNode "$C"))
		)
    )
)

(define implication-implicant-conjunction-rewrite
  (ExecutionOutput
     (GroundedSchema "scm: implication-implicant-conjunction-formula")
     (List
        (ImplicationLink
           (Product
              (Variable "$A")
              (Variable "$B"))
           (Variable "$C"))
        (ImplicationLink
           (VariableNode "$A")
           (VariableNode "$C"))
        (ImplicationLink
           (VariableNode "$B")
           (VariableNode "$C")))))

(define implication-implicant-conjunction-rule
  (Bind
     implication-implicant-conjunction-variables
     implication-implicant-conjunction-body
     implication-implicant-conjunction-rewrite))

(define (implication-implicant-conjunction-formula ABC AC BC)
  (let*
      ((key (PredicateNode "CDV"))
       (dvAC (cog-value AC key))
	   (dvBC (cog-value BC key))
	   (dvABC (cog-cdv-merge dvAC dvBC))
	  )
      (cog-set-value! ABC key dvABC)
  )
)

; Name the rule
(define implication-implicant-conjunction-rule-name
  (DefinedSchemaNode "implication-implicant-conjunction-rule"))
(DefineLink implication-implicant-conjunction-rule-name
  implication-implicant-conjunction-rule)
