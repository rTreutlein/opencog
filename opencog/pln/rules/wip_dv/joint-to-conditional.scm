; =====================================================================
; Joint to conditonal rule
;
; And
;   A
;   B
; A
; |-
; InheritanceLink
;    A
;    B
;----------------------------------------------------------------------

(use-modules (opencog logger))

(define joint-to-conditional-rule
  (BindLink
     (VariableList
        (VariableNode "$A")
        (VariableNode "$B")
     )
     (AndLink
        ;; Preconditions
        (Evaluation
            (GroundedPredicate "scm: has-dv")
            (VariableNode "$A")
        )
        (Evaluation
            (GroundedPredicate "scm: has-dv")
            (ListLink
                (VariableNode "$A")
                (VariableNode "$B"))
        )
        (NotLink
           (EqualLink
              (VariableNode "$A")
              (VariableNode "$B")))
        ;; Pattern clauses
        (VariableNode "$A")
        (ListLink
            (VariableNode "$A")
            (VariableNode "$B"))
     )
     (ExecutionOutputLink
        (GroundedSchemaNode "scm: joint-to-conditional-formula")
        (ListLink
           (VariableNode "$A")
           (ListLink
               (VariableNode "$A")
               (VariableNode "$B"))
           (InheritanceLink
               (VariableNode "$A")
               (VariableNode "$B"))
        )
    )
  )
)

(define (joint-to-conditional-formula A AandB BinhA)
    (let
        ((key (PredicateNode "CDV"))
         (dvA  (cog-value A  key))
         (dvAandB (cog-value AandB key))
        )
        (cog-set-value! BinhA key (cog-dv-divide dvAandB dvA 0))
    )
)

; Name the rule
(define joint-to-conditional-rule-name
  (DefinedSchemaNode "joint-to-conditional-rule"))
(DefineLink
   joint-to-conditional-rule-name
   joint-to-conditional-rule)


; =====================================================================
; Joint to conditonal rule
;
; And
;   A
;   B
; B
; |-
; InheritanceLink
;    B
;    A
;----------------------------------------------------------------------

(use-modules (opencog logger))

(define joint-to-conditional-second-rule
  (BindLink
     (VariableList
        (VariableNode "$A")
        (VariableNode "$B")
     )
     (AndLink
        ;; Preconditions
        (Evaluation
            (GroundedPredicate "scm: has-dv")
            (VariableNode "$B")
        )
        (Evaluation
            (GroundedPredicate "scm: has-dv")
            (Associative
                (VariableNode "$A")
                (VariableNode "$B"))
        )
        (NotLink
           (EqualLink
              (VariableNode "$A")
              (VariableNode "$B")))
        ;; Pattern clauses
        (VariableNode "$B")
        (Associative
            (VariableNode "$A")
            (VariableNode "$B"))
     )
     (ExecutionOutputLink
        (GroundedSchemaNode "scm: joint-to-conditional-second-formula")
        (ListLink
           (VariableNode "$B")
           (Associative
               (VariableNode "$A")
               (VariableNode "$B"))
           (InheritanceLink
               (VariableNode "$B")
               (VariableNode "$A"))
        )
    )
  )
)

(define (joint-to-conditional-second-formula B AandB AinhB)
    (let
        ((key (PredicateNode "CDV"))
         (dvB  (cog-value B  key))
         (dvAandB (cog-value AandB key))
        )
        (cog-set-value! AinhB key (cog-dv-divide dvAandB dvB 1))
    )
)

; Name the rule
(define joint-to-conditional-second-rule-name
  (DefinedSchemaNode "joint-to-conditional-second-rule"))
(DefineLink
   joint-to-conditional-second-rule-name
   joint-to-conditional-second-rule)
