;; =====================================================================
;; Predicate lambda evaluation rule
;;
;; Lambda
;;    <variables>
;;    Evaluation
;;       Predicate <TV>
;;       List
;;          <variables>
;; |-
;; Lambda <TV>
;;    <variables>
;;    Evaluation
;;       Predicate <TV>
;;       List
;;          <variables>
;;
;; Evaluate the TV of Lambda around an evaluation of a predicate.
;; ----------------------------------------------------------------------

(define predicate-lambda-evaluation-vardecl
  (VariableList
     (TypedVariable
        (Variable "$V")
        (TypeChoice
           (Type "TypedVariableLink")
           (Type "VariableList")
           (Type "VariableNode")))
     (Variable "$P")
     (Variable "$Args")))

(define predicate-lambda-evaluation-clause
  (Quote (Lambda
    (Unquote (VariableNode "$V"))
    (Unquote (EvaluationLink
      (Variable "$P")
      (Variable "$Args"))))))

(define predicate-lambda-evaluation-precondition
  (Evaluation
    (GroundedPredicate "scm: has-dv")
    (Variable "$P")))

(define predicate-lambda-evaluation-pattern
  (And
    predicate-lambda-evaluation-clause
    predicate-lambda-evaluation-precondition))

(define predicate-lambda-evaluation-rewrite
  (ExecutionOutputLink
     (GroundedSchemaNode "scm: predicate-lambda-evaluation-formula")
     (ListLink
       predicate-lambda-evaluation-clause
       (Variable "$P"))))

(define predicate-lambda-evaluation-rule
  (BindLink
     predicate-lambda-evaluation-vardecl
     predicate-lambda-evaluation-pattern
     predicate-lambda-evaluation-rewrite))

(define (predicate-lambda-evaluation-formula lamb pred)
  (let ((key (Predicate "CDV"))
        (pred-dv (cog-value pred key))
       )
	   ; FIXME higher conf merge? or precond lamb no dv
	   (cog-set-value! lamb key pred-dv)
  )
)

;; Name the rule
(define predicate-lambda-evaluation-rule-name
  (DefinedSchemaNode "predicate-lambda-evaluation-rule"))
(DefineLink predicate-lambda-evaluation-rule-name
  predicate-lambda-evaluation-rule)
