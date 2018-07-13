;; To be replaced by conjunction-introduction.scm

; =====================================================================
; And introduction rule
;
; For now A and B can be predicates or concepts. Note that the rule
; will not try to prevent mixing predicates and concepts (we need a
; better type system for that). Also it assumes that A and B are
; independant. The rule should account for relationships between A and
; B (like inheritance, etc) to correct that assumption.
;
; A
; InheritanceLink
;   A
;   B
; |-
; AndLink
;    A
;    B
;----------------------------------------------------------------------

(use-modules (opencog logger))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Old rule. We keep for now for backward compatibility ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define and-inheritance-introduction-rule
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
            (InheritanceLink
                (VariableNode "$A")
                (VariableNode "$B"))
        )
        (NotLink
           (EqualLink
              (VariableNode "$A")
              (VariableNode "$B")))
      ;; Pattern clauses
        (VariableNode "$A")
        (InheritanceLink
            (VariableNode "$A")
            (VariableNode "$B"))
     )
     (ExecutionOutputLink
        (GroundedSchemaNode "scm: and-inheritance-introduction-formula")
        (ListLink
           (VariableNode "$A")
           (VariableNode "$B")
           (InheritanceLink
               (VariableNode "$A")
               (VariableNode "$B"))
        )
    )
  )
)

(define (and-inheritance-introduction-formula A B AB)
    (let*
        ((key (PredicateNode "CDV"))
         (dvA  (cog-value A  key))
         (dvAB (cog-value AB key))
         (As (flatten A))
         (Bs (flatten B))
         (ABs (append As Bs))
         ;;FIXME: Add untility for flattening nested links
        )
        (cog-set-value! (Associative ABs) key (cog-cdv-get-joint dvAB dvA))
    )
)

(define (flatten A)
    (if (cog-link? A)
        (cog-outgoing-set A)
        (list A)
    )
)

; Name the rule
(define and-inheritance-introduction-rule-name
  (DefinedSchemaNode "and-inheritance-introduction-rule"))
(DefineLink
   and-inheritance-introduction-rule-name
   and-inheritance-introduction-rule)
