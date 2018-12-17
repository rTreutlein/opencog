;; =======================================================================
;; Implication Instantiation rule
;; (TODO add wiki page)
;;
;; ImplicationScopeLink
;;    V
;;    P
;;    Q
;; T
;; |-
;; Q[V->T]
;;
;; where V is a variable or a list of variables, P is a condition, Q
;; is the implicand, T is an atom (or a list of atoms) to substitute
;; and Q[V->T] is Q where V has been substituted by T.
;;
;; As currently implemented T is not explicitely in the
;; premises. Instead it is queried directly by the rule's formula.
;; -----------------------------------------------------------------------

(use-modules (srfi srfi-1))

(use-modules (opencog exec))
(use-modules (opencog logger))
(use-modules (opencog distvalue))


(load "instantiation.scm")

;;;;;;;;;;;;;;;;;;;;;;;
;; Helper definition ;;
;;;;;;;;;;;;;;;;;;;;;;;

(define implication-full-instantiation-variables
  (VariableList
     (TypedVariableLink
        (VariableNode "$TyVs")
        (TypeChoice
           (TypeNode "TypedVariableLink")
           (TypeNode "VariableList")))
     (VariableNode "$P")
     (VariableNode "$Q")))

(define implication-instantiation-body
	(QuoteLink (ImplicationScopeLink
		(UnquoteLink (VariableNode "$TyVs"))
		(UnquoteLink (VariableNode "$P"))
		(UnquoteLink (VariableNode "$Q")))
    )
)


(define implication-instantiation-precond
	(Evaluation
        (GroundedPredicate "scm: has-dv")
        implication-instantiation-body
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Implication full instantiation rule ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define implication-full-instantiation-rewrite
  (ExecutionOutputLink
     (GroundedSchemaNode "scm: implication-full-instantiation-formula")
     (ListLink
        implication-instantiation-body)))

;; Only try to match an ImplicationScopeLink with a type restricted
;; variable in the ImplicationScopeLink variable definition. The choice of
;; the substitution term is done randomly in
;; implication-full-instantiation-formula. All scoped variables are
;; instantiated.
(define implication-full-instantiation-rule
  (BindLink
     implication-full-instantiation-variables
     (And
		implication-instantiation-body
		implication-instantiation-precond)
     implication-full-instantiation-rewrite))

(define (implication-full-instantiation-formulaa Impl)
  (QuoteLink Impl)
  )

(define (implication-full-instantiation-formula Impl)
  (let* ((key (PredicateNode "CDV"))
         (Impl-cdv (cog-value Impl key))
         ;; Need to turn cdv to dv
         ;;(Impl-c (cog-dv-get-confidence Impl-dv))
		 (Impl-outgoings (cog-outgoing-set Impl))
         (TyVs (car Impl-outgoings))
         (P (cadr Impl-outgoings))
         (Q (caddr Impl-outgoings))
         ;(terms (if (= 0 Impl-c) ; don't try to instantiate zero
         ;                        ; knowledge implication
         ;           #f
         (terms (select-conditioned-substitution-terms TyVs P))
        )
    (if terms
        ;; Substitute the variables by the terms in P and Q. In P to
        ;; get its TV, in Q cause it's the rule output.
        (let* (
               (Pput (PutLink (LambdaLink TyVs P) terms))
               (Pinst (cog-execute! Pput))
               (Pinst-dv (cog-value Pinst key))
              )
			  (if (not (equal? Pinst-dv '()))
			    (let*
				   ((Qput (PutLink (LambdaLink TyVs Q) terms))
				   (Qinst (cog-execute! Qput))
				   (Qinst-dv (cog-cdv-get-unconditional Impl-cdv Pinst-dv))
				   (Qinst-c (cog-dv-get-confidence Qinst-dv)))

				;; Remove the PutLinks to not pollute the atomspace
				;; TODO: replace this by something more sensible
				;; (extract-hypergraph Pput)
				;; (extract-hypergraph Qput)
				(if (< 0 Qinst-c) ; avoid creating informationless knowledge
				     (cog-set-value! Qinst key Qinst-dv)
				)
			   )
			 )
        )
    )
  )
)

;; Name the rule
(define implication-full-instantiation-rule-name
  (DefinedSchemaNode "implication-full-instantiation-rule"))
(DefineLink implication-full-instantiation-rule-name
  implication-full-instantiation-rule)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Implication partial instantiation rule ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define implication-partial-instantiation-variables
  (VariableList
     (TypedVariableLink
        (VariableNode "$TyVs")
        (TypeNode "VariableList"))
     (VariableNode "$P")
     (VariableNode "$Q")))

(define implication-partial-instantiation-rewrite
  (ExecutionOutputLink
     (GroundedSchemaNode "scm: implication-partial-instantiation-formula")
     (ListLink
        implication-instantiation-body)))

;; Like implication-full-instantiation-rule but only instantiate one
;; variable amonst a variable list (if there is just one variable in
;; the implication scope, then this rule will not be invoked).
(define implication-partial-instantiation-rule
  (BindLink
     implication-partial-instantiation-variables
     implication-instantiation-body
     implication-partial-instantiation-rewrite))

;; This function
;;
;; 1. randomly selects a substitution term that partially meets the
;;    implication's condition (the implicant),
;;
;; 2. performs the substitution,
;;
;; 3. calculates its TV (just the TV on the implication link for now,
;; in principle there might better ways)
;;
;; TODO: To make this function better a form of partial pattern
;; matching should be supported. Probably enabling self grounding in
;; the pattern matcher would do the trick (see
;; PatternMatchEngine::self_compare)
(define (implication-partial-instantiation-formula Impl)
  (let* (
         (Impl-outgoings (cog-outgoing-set Impl))
         (TyVs (car Impl-outgoings))
         (P (cadr Impl-outgoings))
         (Q (caddr Impl-outgoings))
         (TyVs-outgoings (cog-outgoing-set TyVs))
         (TyVs-outgoings-len (length TyVs-outgoings))
                                        ; Select all potential
                                        ; substitution terms
         (terms (select-conditioned-substitution-terms TyVs P))
                                        ; Choose the index of the
                                        ; variable to substitute
         (rnd-index (random TyVs-outgoings-len))
                                        ; Take it's corresponding
                                        ; variable
         (TyV (list-ref TyVs-outgoings rnd-index))
                                        ; Build a VariableList of the
                                        ; remaining variables
         (TyVs-remain-list (rm-list-ref TyVs-outgoings rnd-index))
         (TyVs-remain-len (length TyVs-remain-list))
         (TyVs-remain (apply cog-new-link 'VariableList TyVs-remain-list)))
    (if terms
        (cog-set-tv!
         (let* (
                                        ; Take the corresponding term
                (term (list-ref (cog-outgoing-set terms) rnd-index))
                                        ; Substitute the variable by
                                        ; the term in the P and Q bodies
                (P-put (PutLink (LambdaLink TyV P) term))
                (Q-put (PutLink (LambdaLink TyV Q) term))
                (P-inst (cog-execute! P-put))
                (Q-inst (cog-execute! Q-put))
                                        ; If there is only one
                                        ; variable left, discard the
                                        ; VariableLink
                (TyVs-remain (if (= TyVs-remain-len 1)
                                 (gar TyVs-remain)
                                 TyVs-remain)))
           ;; Remove the put links to not populate the atomspace
           (extract-hypergraph P-put)
           (extract-hypergraph Q-put)
           (if (> TyVs-remain-len 0)
                                        ; If there are some variables
                                        ; left, rebuild the
                                        ; ImplicationLink with the
                                        ; remaining variables
               (ImplicationScopeLink TyVs-remain P-inst Q-inst)
                                        ; Otherwise just return the
                                        ; Q instance
               Q-inst))
         (cog-tv Impl)))))

;; Name the rule
(define implication-partial-instantiation-rule-name
  (DefinedSchemaNode "implication-partial-instantiation-rule"))
(DefineLink implication-partial-instantiation-rule-name
  implication-partial-instantiation-rule)
