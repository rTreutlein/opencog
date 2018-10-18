;; =======================================================================
;; Implication Scope to Implication Rule
;; (TODO add wiki page)
;;
;; ImplicationLink
;;    LambdaLink
;;       V
;;       P
;;    LambdaLink
;;       V
;;       Q
;; |-
;; ImplicationScopeLink
;;    V
;;    P
;;    Q
;;
;; where V is a variable or a list of variables, P and Q are the
;; implicant and implicand bodies.
;; -----------------------------------------------------------------------

(define implication-to-implication-scope-variables
  (VariableList
     (TypedVariableLink
        (VariableNode "$TyVs")
        (TypeChoice
           (TypeNode "TypedVariableLink")
           (TypeNode "VariableList")))
     (VariableNode "$P")
     (VariableNode "$Q")))

(define implication-to-implication-scope-body
  (ImplicationLink
     (LocalQuoteLink (LambdaLink
        (VariableNode "$TyVs")
        (VariableNode "$P")))
     (LocalQuoteLink (LambdaLink
        (VariableNode "$TyVs")
        (VariableNode "$Q")))))

(define implication-to-implication-scope-rewrite
  (ExecutionOutputLink
     (GroundedSchemaNode "scm: implication-to-implication-scope-formula")
     (ListLink
        implication-to-implication-scope-body
        (LocalQuoteLink (ImplicationScopeLink
           (VariableNode "$TyVs")
           (VariableNode "$P")
           (VariableNode "$Q"))))))

(define implication-to-implication-scope-rule
  (BindLink
     implication-to-implication-scope-variables
     implication-to-implication-scope-body
     implication-to-implication-scope-rewrite))

(define (implication-to-implication-scope-formula lamb-Impl Impl)
  (let* ((key (PredicateNode "CDV"))
         (lamb-Impl-dv (cog-value lamb-Impl key))
		)
        (cog-set-value! Impl key lamb-Impl-dv)
  )
)

;; Name the rule
(define implication-to-implication-scope-rule-name
  (DefinedSchemaNode "implication-to-implication-scope-rule"))
(DefineLink implication-to-implication-scope-rule-name
  implication-to-implication-scope-rule)
