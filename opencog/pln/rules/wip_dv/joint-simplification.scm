; =====================================================================
; Joint Simplification Rule
;
; And
;   A*
;   B
;   C*
; B
; |-
; And
;    A*
;    B*
;----------------------------------------------------------------------

(use-modules (opencog logger))

(define joint-simplification-rule
  (BindLink
     (VariableList
        (GlobNode "$A")
        (GlobNode "$B")
        (GlobNode "$C")
     )
     (AndLink
        ;; Preconditions
        (Evaluation
            (GroundedPredicate "scm: has-dv")
            (Associative
                (GlobNode "$A")
                (Associative
                    (GlobNode "$B"))
                (GlobNode "$C"))
        )
        ;; Pattern clauses
        (Associative
            (GlobNode "$A")
            (Associative
                (GlobNode "$B"))
            (GlobNode "$C"))
     )
     (ExecutionOutputLink
        (GroundedSchemaNode "scm: joint-simplification-formula")
        (ListLink
           (GlobNode "$A")
           (GlobNode "$B")
           (GlobNode "$C")
           (Associative
               (GlobNode "$A")
               (Associative
                   (GlobNode "$B"))
               (GlobNode "$C")
           )
        )
    )
  )
)

(define (joint-simplification-formula A B C ABC)
    (let
        ((key (PredicateNode "CDV"))
         (dvAsBCs (cog-value AsBCs key))
         (dvB (cog-value B key))
         (i (length (cog-outgoing-set As)))
        )
        (cog-set-value! (Associate As Cs) key (cog-dv-sum-joint dvAsBCs dvB i))
    )
)

; Name the rule
(define joint-simplification-rule-name
  (DefinedSchemaNode "joint-simplification-rule"))
(DefineLink
   joint-simplification-rule-name
   joint-simplification-rule)
