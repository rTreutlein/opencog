;; =======================================================================
;; AndLink Lambda Factorization Rule
;;
;; WARNING: Not BC compatible.
;;
;; TODO: Replace this by higher order fact
;;
;; AndLink
;;    LambdaLink
;;       V
;;       A1
;;    ...
;;    LambdaLink
;;       V
;;       An
;; |-
;; LambdaLink
;;    V
;;    AndLink
;;       A1
;;       ...
;;       An
;;
;; where V is a variable or a list of variables, A1 to An are bodies
;; using containing variable(s) V.
;;
;; Also, the consequent will actually be the doudble implication
;;
;; ImplicationLink <1 1>
;;    AndLink
;;       LambdaLink
;;          V
;;          A1
;;       ...
;;       LambdaLink
;;          V
;;          An
;;    LambdaLink
;;       V
;;       AndLink
;;          A1
;;          ...
;;          An
;;
;; ImplicationLink <1 1>
;;    LambdaLink
;;       V
;;       AndLink
;;          A1
;;          ...
;;          An
;;    AndLink
;;       LambdaLink
;;          V
;;          A1
;;       ...
;;       LambdaLink
;;          V
;;          An
;;
;; Because it is much easier to chain later on. This will be replaced
;; by higher order facts later.
;; -----------------------------------------------------------------------

(use-modules (opencog distvalue))

(define and-lambda-factorization-double-implication-variables
  (VariableList
    (TypedVariableLink
      (VariableNode "$TyVs")
      (TypeChoice
        (TypeNode "TypedVariableLink")
        (TypeNode "VariableNode")
        (TypeNode "VariableList")))
    (VariableNode "$A1")
    (VariableNode "$A2")))

(define and-lambda-factorization-double-implication-body
    (ProductLink
      (LocalQuoteLink (LambdaLink
        (VariableNode "$TyVs")
        (VariableNode "$A1")))
      (LocalQuoteLink (LambdaLink
        (VariableNode "$TyVs")
        (VariableNode "$A2")))
	)
)


(define and-lambda-factorization-double-implication-rewrite
  (ExecutionOutputLink
     (GroundedSchemaNode "scm: and-lambda-factorization-double-implication-formula")
     (ListLink
        (VariableNode "$TyVs")
        (VariableNode "$A1")
        (VariableNode "$A2"))))

(define and-lambda-factorization-double-implication-rule
  (BindLink
     and-lambda-factorization-double-implication-variables
     and-lambda-factorization-double-implication-body
     and-lambda-factorization-double-implication-rewrite))

(define (and-lambda-factorization-double-implication-formula var a1 a2)
  (let* ((and-lamb (ProductLink (LambdaLink var a1) (LambdaLink var a2)))
         (lamb (LambdaLink var (ProductLink a1 a2)))
         (key (PredicateNode "CDV"))
		)
		;;FIXME merge instead of set.
        (cog-set-value! lamb key (cog-value and-lamb key))
        (List
         (cog-set-value! (ImplicationLink and-lamb lamb) key truecdv)
         (cog-set-value! (ImplicationLink lamb and-lamb) key truecdv)
        )
  )
)

(define truecdv
  (let*
      ((z1 (list (list '(0) '(0))))
	   (z2 (list (list '(1) '(1))))
       (dv1 (cog-new-dv z1 '(800)))
       (dv2 (cog-new-dv z2 '(800)))
      )
      (cog-new-cdv (append z1 z2) (list dv1 dv2))
  )
)

;; Name the rule
(define and-lambda-factorization-double-implication-rule-name
  (DefinedSchemaNode "and-lambda-factorization-double-implication-rule"))
(DefineLink and-lambda-factorization-double-implication-rule-name
  and-lambda-factorization-double-implication-rule)
