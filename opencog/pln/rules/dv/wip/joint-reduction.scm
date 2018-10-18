; =====================================================================
; Joint Reduction Rule
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

(define joint-reduction-rule
  (BindLink
     (VariableList
        (GlobNode "$A")
        (VariableNode "$B")
        (GlobNode "$C")
     )
     (AndLink
        ;; Preconditions
        (Evaluation
            (GroundedPredicate "scm: has-dv")
            (ProductLink
                (GlobNode "$A")
                (VariableNode "$B")
                (GlobNode "$C"))
        )
        (Evaluation
            (GroundedPredicate "scm: has-dv")
            (VariableNode "$B")
        )
        ;; Pattern clauses
        (VariableNode "$B")
        (ProductLink
            (GlobNode "$A")
            (VariableNode "$B")
            (GlobNode "$C"))
     )
     (ExecutionOutputLink
        (GroundedSchemaNode "scm: joint-reduction-formula")
        (ListLink
           (GlobNode "$A")
           (VariableNode "$B")
           (GlobNode "$C")
           (ProductLink
               (GlobNode "$A")
               (VariableNode "$B")
               (GlobNode "$C")
           )
        )
    )
  )
)

(define (joint-reduction-formula As B Cs AsBCs)
    (let*
        ((key (PredicateNode "CDV"))
         (dvAsBCs (cog-value AsBCs key))
         (dvB (cog-value B key))
         (lAs (if (cog-link? As)
                  (cog-outgoing-set As)
                  (list As)
              ))
         (lCs (if (cog-link? As)
                  (cog-outgoing-set Cs)
                  (list Cs)
              ))
         (lACs (append lAs lCs))
         (i (length lAs))
        )
        (cog-set-value! (ProductLink lACs) key (cog-dv-sum-joint dvAsBCs dvB i))
    )
)

; Name the rule
(define joint-reduction-rule-name
  (DefinedSchemaNode "joint-reduction-rule"))
(DefineLink
   joint-reduction-rule-name
   joint-reduction-rule)
