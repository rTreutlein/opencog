; =====================================================================
; Joint to conditonal rule
;
; Product
;   A
;   B
; A
; |-
; InheritanceLink
;    A
;    B
;----------------------------------------------------------------------

(use-modules (opencog logger))

(define (gen-joint-to-conditional-rule link-type var-type)
  (BindLink
     (VariableList
        (TypedVariable
			(VariableNode "$A")
			var-type)
        (TypedVariable
			(VariableNode "$B")
			var-type)
     )
     (AndLink
        ;; Preconditions
        (Evaluation
            (GroundedPredicate "scm: has-dv")
            (VariableNode "$A")
        )
        (Evaluation
            (GroundedPredicate "scm: has-dv")
            (ProductLink
                (VariableNode "$A")
                (VariableNode "$B"))
        )
        (NotLink
           (EqualLink
              (VariableNode "$A")
              (VariableNode "$B")))
        ;; Pattern clauses
        (VariableNode "$A")
        (ProductLink
            (VariableNode "$A")
            (VariableNode "$B"))
     )
     (ExecutionOutputLink
        (GroundedSchemaNode "scm: joint-to-conditional-formula")
        (ListLink
           (VariableNode "$A")
           (ProductLink
               (VariableNode "$A")
               (VariableNode "$B"))
           (link-type
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
        (cog-set-value! BinhA key (cog-dv-divide dvAandB dvA 1))
    )
)

(define joint-to-inheritance-rule
  (let ((var-type (TypeChoice
                    (TypeNode "ConceptNode")
                    (TypeNode "AndLink")
                    (TypeNode "OrLink")
                    (TypeNode "NotLink"))))
    (gen-joint-to-conditional-rule InheritanceLink var-type)))

(define joint-to-implication-rule
  (let ((var-type (TypeChoice
                    (TypeNode "PredicateNode")
                    (TypeNode "LambdaLink")
                    (TypeNode "AndLink")
                    (TypeNode "OrLink")
                    (TypeNode "NotLink"))))
    (gen-joint-to-conditional-rule ImplicationLink var-type)))


; Name the rules
(define joint-to-inheritance-rule-name
  (DefinedSchemaNode "joint-to-inheritance-rule"))
(DefineLink
   joint-to-inheritance-rule-name
   joint-to-inheritance-rule)

(define joint-to-implication-rule-name
  (DefinedSchemaNode "joint-to-implication-rule"))
(DefineLink
   joint-to-implication-rule-name
   joint-to-implication-rule)
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

(define (gen-joint-to-conditional-second-rule link-type var-type)
  (BindLink
     (VariableList
        (TypedVariable
			(VariableNode "$A")
			var-type)
        (TypedVariable
			(VariableNode "$B")
			var-type)
     )
     (AndLink
        ;; Preconditions
        (Evaluation
            (GroundedPredicate "scm: has-dv")
            (VariableNode "$B")
        )
        (Evaluation
            (GroundedPredicate "scm: has-dv")
            (ProductLink
                (VariableNode "$A")
                (VariableNode "$B"))
        )
        (NotLink
           (EqualLink
              (VariableNode "$A")
              (VariableNode "$B")))
        ;; Pattern clauses
        (VariableNode "$B")
        (ProductLink
            (VariableNode "$A")
            (VariableNode "$B"))
     )
     (ExecutionOutputLink
        (GroundedSchemaNode "scm: joint-to-conditional-second-formula")
        (ListLink
           (VariableNode "$B")
           (ProductLink
               (VariableNode "$A")
               (VariableNode "$B"))
           (link-type
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

(define joint-to-inheritance-second-rule
  (let ((var-type (TypeChoice
                    (TypeNode "ConceptNode")
                    (TypeNode "AndLink")
                    (TypeNode "OrLink")
                    (TypeNode "NotLink"))))
    (gen-joint-to-conditional-second-rule InheritanceLink var-type)))

(define joint-to-implication-second-rule
  (let ((var-type (TypeChoice
                    (TypeNode "PredicateNode")
                    (TypeNode "LambdaLink")
                    (TypeNode "AndLink")
                    (TypeNode "OrLink")
                    (TypeNode "NotLink"))))
    (gen-joint-to-conditional-second-rule ImplicationLink var-type)))


; Name the rules
(define joint-to-inheritance-second-rule-name
  (DefinedSchemaNode "joint-to-inheritance-second-rule"))
(DefineLink
   joint-to-inheritance-second-rule-name
   joint-to-inheritance-second-rule)

(define joint-to-implication-second-rule-name
  (DefinedSchemaNode "joint-to-implication-second-rule"))
(DefineLink
   joint-to-implication-second-rule-name
   joint-to-implication-second-rule)
