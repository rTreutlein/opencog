;; =============================================================================
;; InversionRule
;;
;; <LinkType>
;;   A
;;   B
;; |-
;; <LinkType>
;;   B
;;   A
;;
;; This rule just a combination of the joint-introduction and joint-to-conditional rules
;;
;; Due to type system limitations, the rule has been divided into 3:
;;       inversion-inheritance-rule
;;       inversion-implication-rule
;;       inversion-subset-rule
;;
;; -----------------------------------------------------------------------------

(use-modules (opencog distvalue))

;; Generate the corresponding inversion rule given its link-type.
(define (gen-inversion-rule link-type)
  (BindLink
    (VariableList
      (VariableNode "$A")
      (VariableNode "$B"))
    (link-type
      (VariableNode "$A")
      (VariableNode "$B"))
    (ExecutionOutputLink
      (GroundedSchemaNode "scm: inversion-formula")
      (ListLink
        (link-type
          (VariableNode "$B")
          (VariableNode "$A"))
        (VariableNode "$A")
        (VariableNode "$B")
        (link-type
          (VariableNode "$A")
          (VariableNode "$B"))))))

(define inversion-inheritance-rule
    (gen-inversion-rule InheritanceLink))

(define inversion-implication-rule
    (gen-inversion-rule ImplicationLink))

(define inversion-subset-rule
    (gen-inversion-rule SubsetLink))

(define (inversion-formula BA A B AB)
    (let*
      ((key (PredicateNode "CDV"))
	   (dvA (cog-value A key))
	   (dvB (cog-value B key))
	   (cdvAB (cog-value AB key))
	   (dvJ (cog-cdv-get-joint cdvAB dvA))
	   (cdvBA (cog-dv-divide dvJ dvB 0))
	  )
	  (cog-set-value! BA key cdvBA)
	)
)

;; Name the rules
(define inversion-inheritance-rule-name
  (DefinedSchemaNode "inversion-inheritance-rule"))
(DefineLink inversion-inheritance-rule-name
  inversion-inheritance-rule)

(define inversion-implication-rule-name
  (DefinedSchemaNode "inversion-implication-rule"))
(DefineLink inversion-implication-rule-name
  inversion-implication-rule)

(define inversion-subset-rule-name
  (DefinedSchemaNode "inversion-subset-rule"))
(DefineLink inversion-subset-rule-name
  inversion-subset-rule)
