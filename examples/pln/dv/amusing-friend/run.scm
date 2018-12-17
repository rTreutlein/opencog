(load "kb.scm")

(load "pln-config.scm")

(my-print (cog-execute! implication-full-instantiation-rule))
(my-print (cog-execute! implication-scope-to-implication-rule))

(my-print (cog-execute! predicate-lambda-evaluation-rule))

(define wbf (LambdaLink
          (VariableList
             (TypedVariableLink
                (VariableNode "$X")
                (TypeNode "ConceptNode")
             )
             (TypedVariableLink
                (VariableNode "$Y")
                (TypeNode "ConceptNode")
             )
          )
          (EvaluationLink
             (PredicateNode "will-be-friends")
             (ListLink
                (VariableNode "$X")
                (VariableNode "$Y")
             )
          )
       )
)
(define wbf_dv (cog-value wbf key))

(define fth (ImplicationLink
          (LambdaLink
          (VariableList
             (TypedVariableLink
                (VariableNode "$X")
                (TypeNode "ConceptNode")
             )
             (TypedVariableLink
                (VariableNode "$Y")
                (TypeNode "ConceptNode")
             )
          )
          (EvaluationLink
             (PredicateNode "will-be-friends")
             (ListLink
                (VariableNode "$X")
                (VariableNode "$Y")
             )
          )
       )
       (LambdaLink
          (VariableList
             (TypedVariableLink
                (VariableNode "$X")
                (TypeNode "ConceptNode")
             )
             (TypedVariableLink
                (VariableNode "$Y")
                (TypeNode "ConceptNode")
             )
          )
          (AndLink
             (EvaluationLink
                (PredicateNode "is-honest")
                (VariableNode "$X")
             )
             (EvaluationLink
                (PredicateNode "is-honest")
                (VariableNode "$Y")
             )
          )
       )
    )
)
(define fth_dv (cog-value fth key))

(define th_dv (cog-value two_honest key))

(define prod (cog-cdv-get-joint fth_dv wbf_dv))

(my-print (cog-execute! joint-implication-introduction-rule))
(my-print (cog-execute! joint-to-implication-second-rule))

#!
(cog-execute! implication-implicant-conjunction-rule-name)

(cog-execute! and-lambda-factorization-double-implication-rule-name)

;;This doesn't seem to produce the correct result
;;Might just have missed it though
(cog-execute! deduction-implication-rule)

(cog-execute! implication-to-implication-scope-rule)

(cog-execute! implication-full-instantiation-rule)

(cog-execute! equivalence-scope-distribution-rule)

(cog-execute! equivalence-to-double-implication-forward-rule)

#!
(define BC
(ImplicationLink
   (ProductLink
      (LambdaLink
         (VariableList
            (TypedVariableLink
               (VariableNode "$X")
               (TypeNode "ConceptNode")
            )
            (TypedVariableLink
               (VariableNode "$Y")
               (TypeNode "ConceptNode")
            )
         )
         (AndLink
            (EvaluationLink
               (PredicateNode "is-honest")
               (VariableNode "$X")
            )
            (EvaluationLink
               (PredicateNode "is-honest")
               (VariableNode "$Y")
            )
         )
      )
      (LambdaLink
         (VariableList
            (TypedVariableLink
               (VariableNode "$X")
               (TypeNode "ConceptNode")
            )
            (TypedVariableLink
               (VariableNode "$Y")
               (TypeNode "ConceptNode")
            )
         )
         (AndLink
            (InheritanceLink
               (VariableNode "$X")
               (ConceptNode "human")
            )
            (InheritanceLink
               (VariableNode "$Y")
               (ConceptNode "human")
            )
            (EvaluationLink
               (PredicateNode "acquainted")
               (ListLink
                  (VariableNode "$X")
                  (VariableNode "$Y")
               )
            )
         )
      )
   )
   (LambdaLink
      (VariableList
         (TypedVariableLink
            (VariableNode "$X")
            (TypeNode "ConceptNode")
         )
         (TypedVariableLink
            (VariableNode "$Y")
            (TypeNode "ConceptNode")
         )
      )
      (EvaluationLink
         (PredicateNode "will-be-friends" (stv 9.9999997e-05 0.89999998))
         (ListLink
            (VariableNode "$X")
            (VariableNode "$Y")
         )
      )
   )
)
)


(define AB
(ImplicationLink
   (LambdaLink
      (VariableList
         (TypedVariableLink
            (VariableNode "$X")
            (TypeNode "ConceptNode")
         )
         (TypedVariableLink
            (VariableNode "$Y")
            (TypeNode "ConceptNode")
         )
      )
      (ProductLink
   	 (AndLink
         (EvaluationLink
            (PredicateNode "is-honest")
            (VariableNode "$X")
         )
         (EvaluationLink
            (PredicateNode "is-honest")
            (VariableNode "$Y")
         )
   	  )
   	 (AndLink
   	  (EvaluationLink
            (PredicateNode "acquainted")
            (ListLink
               (VariableNode "$X")
               (VariableNode "$Y")
            )
         )
         (InheritanceLink
            (VariableNode "$Y")
            (ConceptNode "human")
         )
         (InheritanceLink
            (VariableNode "$X")
            (ConceptNode "human")
         )
   	  )
      )
   )
   (ProductLink
      (LambdaLink
         (VariableList
            (TypedVariableLink
               (VariableNode "$X")
               (TypeNode "ConceptNode")
            )
            (TypedVariableLink
               (VariableNode "$Y")
               (TypeNode "ConceptNode")
            )
         )
         (AndLink
            (EvaluationLink
               (PredicateNode "is-honest")
               (VariableNode "$X")
            )
            (EvaluationLink
               (PredicateNode "is-honest")
               (VariableNode "$Y")
            )
         )
      )
      (LambdaLink
         (VariableList
            (TypedVariableLink
               (VariableNode "$X")
               (TypeNode "ConceptNode")
            )
            (TypedVariableLink
               (VariableNode "$Y")
               (TypeNode "ConceptNode")
            )
         )
         (AndLink
            (InheritanceLink
               (VariableNode "$X")
               (ConceptNode "human")
            )
            (InheritanceLink
               (VariableNode "$Y")
               (ConceptNode "human")
            )
            (EvaluationLink
               (PredicateNode "acquainted")
               (ListLink
                  (VariableNode "$X")
                  (VariableNode "$Y")
               )
            )
         )
      )
   )
)
)
!#
