;; =============================================================================
;; My Rule
;;
;;And
;;   A
;;   B
;; A
;; B
;; CTX
;;   B
;; |-
;; CTX
;;   A
;;
;; -----------------------------------------------------------------------------

;; Generate the corresponding abduction rule given its link-type.
(define myrule
    (BindLink
        (VariableList
            (VariableNode "$A")
            (VariableNode "$B")
        )
        (AndLink
            (AndLink
                (VariableNode "$A")
                (VariableNode "$B"))
            (ContextLink
                (VariableNode "$B"))
            (VariableNode "$A")
            (VariableNode "$B"))
        (ExecutionOutputLink
            (GroundedSchemaNode "scm: abduction-formula")
            (ListLink
                (ContextLink
                    (VariableNode "$A"))
                (AndLink
                    (VariableNode "$A")
                    (VariableNode "$B"))
                (ContextLink
                    (VariableNode "$B"))
                (VariableNode "$A")
                (VariableNode "$B")
            )
        )
    )
)

(define (myrule-formul CtxA AandB CtxB A B)
    (let*
        ((key (PredicateNode "CDV"))
         (dvA (cog-value key A))
         (dvB (cog-value key B))
         (dvCtxB (cog-value key CtxB))
         (dvAandB (cog-value key AandB))
         (dvCtxA (cog-dv-divide dvAandB dvB))
        )
        (cog-set-value! CtxA key dvCtxA)
    )
)

;; Name the rules
(define myrule-name
  (DefinedSchemaNode "myrule"))
(DefineLink myrule-name myrule)
