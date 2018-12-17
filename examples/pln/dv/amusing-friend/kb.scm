;; Kownledge base for the amusing friend demo.
;;
;; We are dodging a lot of representational issues here. In particular
;; everything related to spatio-temporal reasoning. To be reified as
;; desired.

;;;;;;;;;;;;;
;; Honesty ;;
;;;;;;;;;;;;;

;; Probability of being honest
;;(Predicate "is-honest" (stv 0.8 0.9))
(define key (Predicate "CDV"))
(define p_honest (Predicate "is-honest"))
(define dv_p_honest (cog-new-dv-simple 0.8 0.9))
(cog-set-value! p_honest key dv_p_honest)

;; Probability that two things are honest
;;
;; This should be inferred since we don't have the rules to infer that
;; we put it in the kb for now.
(define two_honest
  (Lambda
   (VariableList
      (TypedVariable
         (Variable "$X")
         (Type "ConceptNode"))
      (TypedVariable
         (Variable "$Y")
         (Type "ConceptNode")))
   (And
      (Evaluation
         (Predicate "is-honest")
         (Variable "$X"))
      (Evaluation
         (Predicate "is-honest")
         (Variable "$Y")))))
(define dv_two_honest (cog-new-dv-simple 0.64 0.9))
(cog-set-value! two_honest key dv_two_honest)

;; Probability of telling the truth to someone. The probability if
;; very low cause the probability of telling something to someone is
;; already very low.
;;(Predicate "told-the-truth" (stv 0.00001 0.7))
(define p_ttt (Predicate "told-the-truth"))
(define dv_p_ttt (cog-new-dv-simple 0.00001 0.7))
(cog-set-value! p_ttt key dv_p_ttt)

;; We need also the following. It should normally be wrapped in a
;; Lambda, but because instantiation. And ultimately this should be
;; inferred.
(define ttta (Evaluation
   (Predicate "told-the-truth-about")
   (List
      (Variable "$X")
      (Variable "$Y")
      (Variable "$Z"))))
(define dv_ttta (cog-new-dv-simple 0.00001 0.7))
(cog-set-value! ttta key dv_ttta)

(define (with-cdv atom conds dvs) (cog-set-value! atom key (cog-new-cdv conds dvs)))

(define (with-simple-cdv atom dv)
  (cog-set-value! atom key (cog-new-cdv (list (list '(1))) (list dv))))

;; People who told the truth about something are honest
(define people-telling-the-truth-are-honest
(ImplicationScope
   (VariableList
      (TypedVariable
         (Variable "$X")
         (Type "ConceptNode"))
      (TypedVariable
         (Variable "$Y")
         (Type "ConceptNode"))
      (TypedVariable
         (Variable "$Z")
         (Type "ConceptNode")))
   (Evaluation
      (Predicate "told-the-truth-about")
      (List
         (Variable "$X")
         (Variable "$Y")
         (Variable "$Z")))
   (Evaluation
      (Predicate "is-honest")
      (Variable "$X"))))
(define dv_ptttah (cog-new-dv-simple 0.95 0.9))
(with-simple-cdv people-telling-the-truth-are-honest dv_ptttah)

;;;;;;;;;;;;;;
;; Humanity ;;
;;;;;;;;;;;;;;

;; Probability of two human acquaintances
(define two_acquaintances
(Lambda
   (VariableList
      (TypedVariable
         (Variable "$X")
         (Type "ConceptNode"))
      (TypedVariable
         (Variable "$Y")
         (Type "ConceptNode")))
   (And
      (Inheritance
         (Variable "$X")
         (Concept "human"))
      (Inheritance
         (Variable "$Y")
         (Concept "human"))
      (Evaluation
         (Predicate "acquainted")
         (List
            (Variable "$X")
            (Variable "$Y"))))))
(define dv_two_aquaintances (cog-new-dv-simple 0.0002 0.9))
(cog-set-value! two_acquaintances key dv_two_aquaintances)

;;;;;;;;;
;; Bob ;;
;;;;;;;;;

;; Bob is a human
(define bob_is_human
(Inheritance
   (Concept "Bob")
   (Concept "human")))
(define dv_bob_is_human (cog-new-dv-simple 1 1))
(cog-set-value! bob_is_human key dv_bob_is_human)

;;;;;;;;;;
;; Self ;;
;;;;;;;;;;

;; I am a human
(define i_is_human
(Inheritance
   (Concept "Self")
   (Concept "human")))
(define dv_i_is_human (cog-new-dv-simple 1 1))
(cog-set-value! i_is_human key dv_i_is_human)

;; I am honest
(define i_is_honest
(Evaluation
   (Predicate "is-honest")
   (Concept "Self")))
(define dv_i_is_honest (cog-new-dv-simple 0.9 0.9))
(cog-set-value! i_is_honest key dv_i_is_honest)

;; I know Bob
(define i_know_bob
(Evaluation
   (Predicate "acquainted")
   (List
      (Concept "Self")
      (Concept "Bob"))))
(define dv_i_know_bob (cog-new-dv-simple 1 1))
(cog-set-value! i_know_bob key dv_i_know_bob)

;;;;;;;;;;;;;;;;
;; Friendship ;;
;;;;;;;;;;;;;;;;

;; The probability of random things (typically humans) being friends
(define will_be_friends (Predicate "will-be-friends"))
(define dv_will_be_friends (cog-new-dv-simple 0.0001 0.9))
(cog-set-value! will_be_friends key dv_will_be_friends)

;; Because we have no way to specify the type signature of predicate
;; "will-be-friends" (will need a better type system) we specify it
;; indirectly by wrapping it in a lambda. The TV on the lambda can be
;; evaluated by inference but the structure cannot.
(define lwillbefriends
(Lambda
  (VariableList
    (TypedVariable
      (Variable "$X")
      (Type "ConceptNode"))
    (TypedVariable
      (Variable "$Y")
     (Type "ConceptNode")))
  (Evaluation
    (Predicate "will-be-friends")
    (List
      (Variable "$X")
      (Variable "$Y")))))

;; Friendship is symmetric
(define friend_sym
(ImplicationScope
   (VariableList
      (TypedVariable
         (Variable "$X")
         (Type "ConceptNode"))
      (TypedVariable
         (Variable "$Y")
         (Type "ConceptNode")))
   (Evaluation
      (Predicate "will-be-friends")
      (List
         (Variable "$X")
         (Variable "$Y")))
   (Evaluation
      (Predicate "will-be-friends")
      (List
         (Variable "$Y")
         (Variable "$X")))))
(define dv_friend_sym (cog-new-dv-simple 1 1))
(with-simple-cdv friend_sym dv_friend_sym)

;; I'm disabling that to simplify the inference. Ultimately the only
;; reason we use will-be-friends rather than are-friends is so the
;; first person perspective makes a bit of sense (cause someone is
;; supposed to know who are her friends). With a third person
;; perspective, such as "Find Sylvia's friends", then we can just use
;; "are-friends", cause we're not supposed to know all of Sylvia's
;; friends.
;;
;; ;; Friends will remain friends.
;; ;;
;; ;; This could simply be expressed as
;; ;;
;; ;; (Implication (stv 0.9 0.9)
;; ;;    (Predicate "are-friends")
;; ;;    (Predicate "will-be-friends"))
;; ;;
;; ;; but due to some current limitation in the type system, specifically
;; ;; that a Predicate cannot be declared with a certain type, we need to
;; ;; express that in a more convoluted way.
;; (ImplicationScope (stv 0.9 0.9)
;;    (VariableList
;;       (TypedVariable
;;          (Variable "$X")
;;          (Type "ConceptNode"))
;;       (TypedVariable
;;          (Variable "$Y")
;;          (Type "ConceptNode")))
;;    (Evaluation
;;       (Predicate "are-friends")
;;       (List
;;          (Variable "$X")
;;          (Variable "$Y")))
;;    (Evaluation
;;       (Predicate "will-be-friends")
;;       (List
;;          (Variable "$X")
;;          (Variable "$Y"))))

;; The probablity of turning acquaintance into friendship between
;; humans is 0.1.
(define human-acquainted-tend-to-become-friends
(ImplicationScope
   (VariableList
      (TypedVariable
         (Variable "$X")
         (Type "ConceptNode"))
      (TypedVariable
         (Variable "$Y")
         (Type "ConceptNode")))
   (And
      (Inheritance
         (Variable "$X")
         (Concept "human"))
      (Inheritance
         (Variable "$Y")
         (Concept "human"))
      (Evaluation
         (Predicate "acquainted")
         (List
            (Variable "$X")
            (Variable "$Y"))))
   (Evaluation
      (Predicate "will-be-friends")
      (List
         (Variable "$X")
         (Variable "$Y")))))
(define dv_hattbf (cog-new-dv-simple 0.1 0.5))
(with-simple-cdv human-acquainted-tend-to-become-friends dv_hattbf)

;; Friends tend to be honest
(define friends-tend-to-be-honest
(ImplicationScope
   (VariableList
      (TypedVariable
         (Variable "$X")
         (Type "ConceptNode"))
      (TypedVariable
         (Variable "$Y")
         (Type "ConceptNode")))
   (Evaluation
      (Predicate "will-be-friends")
      (List
         (Variable "$X")
         (Variable "$Y")))
   (And
      (Evaluation
         (Predicate "is-honest")
         (Variable "$X"))
      (Evaluation
         (Predicate "is-honest")
         (Variable "$Y")))))
(define dv_friends_honest (cog-new-dv-simple 0.85 0.5))
(with-simple-cdv friends-tend-to-be-honest dv_friends_honest)

;;;;;;;;;;;;;;;;;
;; Being Funny ;;
;;;;;;;;;;;;;;;;;

;; Probability of telling a joke to someone. The probability is
;; extremely low because the probability of telling anything to
;; someone is already very low.
(define (dvPred n m c)
  (let ((pred (PredicateNode n))
        (dv   (cog-new-dv-simple m c)))
       (cog-set-value! pred key dv)
  )
)

(define (with-dv n m c)
  (let ((dv   (cog-new-dv-simple m c)))
       (cog-set-value! n key dv)
  )
)

(dvPred "told-a-joke-at"  0.000001 0.6)

;; The following should be wrapped in a Lambda and ultimately
;; inferred.
(define told_a_joke_at
(Evaluation
   (Predicate "told-a-joke-at")
      (List
         (Variable "$X")
         (Variable "$Y")
         (Variable "$Z"))))
(with-dv told_a_joke_at 0.000001 0.6)

;; Probability of being funny
(dvPred "is-funny" 0.69 0.7)

;; Same remark as for Predicate "told-a-joke-at"
(define is_funny
(Evaluation
   (Predicate "is-funny")
   (Variable "$X")))
(with-dv is_funny 0.69 0.7)

;; People who told a joke to someone, somewhere, are funny
(define people-telling-jokes-are-funny
(ImplicationScope
   (VariableList
      (TypedVariable
         (Variable "$X")
         (Type "ConceptNode"))
      (TypedVariable
         (Variable "$Y")
         (Type "ConceptNode"))
      (TypedVariable
         (Variable "$Z")
         (Type "ConceptNode")))
   (Evaluation
      (Predicate "told-a-joke-at")
      (List
         (Variable "$X")
         (Variable "$Y")
         (Variable "$Z")))
   (Evaluation
      (Predicate "is-funny")
      (Variable "$X"))))
(with-simple-cdv people-telling-jokes-are-funny (cog-new-dv-simple 0.8 0.9))

;; Being funny is loosely equivalent to being amusing
;;
;; This could simply be expressed as
;;
;; (Equivalence (stv 0.7 0.9)
;;    (Predicate "is-funny")
;;    (Predicate "is-amusing"))
;;
;; but due to some current limitation in the type system, specifically
;; that a Predicate cannot be declared with a certain type, we need to
;; express that in a more convoluted way.
(define funny-is-loosely-equivalent-to-amusing
(Equivalence
   (TypedVariable
      (Variable "$X")
      (Type "ConceptNode"))
   (Evaluation
      (Predicate "is-funny")
      (Variable "$X"))
   (Evaluation
      (Predicate "is-amusing")
      (Variable "$X"))))
(with-dv funny-is-loosely-equivalent-to-amusing 0.7 0.9)

;;;;;;;;;;;;;;;
;; The Party ;;
;;;;;;;;;;;;;;;

;; Bob told Jill the truth about the party
(define btjttatp
(Evaluation
   (Predicate "told-the-truth-about")
   (List
      (Concept "Bob")
      (Concept "Jill")
      (Concept "Party"))))
(with-dv btjttatp 1 1)

;; Bob told Jim a joke at the party.
(define btjajap
(Evaluation (stv 1 1)
   (Predicate "told-a-joke-at")
      (List
         (Concept "Bob")
         (Concept "Jim")
         (Concept "Party"))))
(with-dv btjajap 1 1)

;;;;;;;;;;
;; Hack ;;
;;;;;;;;;;

;; Due to the fact the evaluator does not support fuzzy TV semantic we
;; put the evaluation of a to-be-used instantiated precondition
;; here. Alternatively we could add PLN rules to evaluate.
(define hack (And
   (Evaluation
      (Predicate "is-honest")
      (Concept "Self")
   )
   (Evaluation
      (Predicate "is-honest")
      (Concept "Bob")
   )
   (Inheritance
      (Concept "Self")
      (Concept "human")
   )
   (Inheritance
      (Concept "Bob")
      (Concept "human")
   )
   (Evaluation
      (Predicate "acquainted")
      (List
         (Concept "Self")
         (Concept "Bob")
      )
   )
)
)
(with-dv hack 1 0.9)

;; Because implication-instantiation occurs on the sugar syntax, the
;; predicate (which should be wrapped in a Lambda) is not given. Also
;; of course that predicate should still be evaluated. Here we provide
;; the adequate TV value of that predicate on the scope-free form.
(define ahhxhhya
(And
   (Evaluation
      (Predicate "is-honest")
      (Variable "$X")
   )
   (Evaluation
      (Predicate "is-honest")
      (Variable "$Y")
   )
   (Inheritance
      (Variable "$X")
      (Concept "human")
   )
   (Inheritance
      (Variable "$Y")
      (Concept "human")
   )
   (Evaluation
      (Predicate "acquainted")
      (List
         (Variable "$X")
         (Variable "$Y")
      )
   )
))
(with-dv ahhxhhya 0.000128 0.89999998)

;; Because we have no way to infer the type signature of the term
;; above we wrap it in a lambda
(Lambda
  (VariableList
    (TypedVariable
      (Variable "$X")
      (Type "ConceptNode")
    )
    (TypedVariable
      (Variable "$Y")
      (Type "ConceptNode")
    )
  )
  (And
    (Evaluation
      (Predicate "is-honest")
      (Variable "$X")
    )
    (Evaluation
      (Predicate "is-honest")
      (Variable "$Y")
    )
    (Inheritance
      (Variable "$X")
      (Concept "human")
    )
    (Inheritance
      (Variable "$Y")
      (Concept "human")
    )
    (Evaluation
      (Predicate "acquainted")
      (List
        (Variable "$X")
        (Variable "$Y")
      )
    )
  )
)


(define (my-print set)
    (let*
      ((oset (cog-outgoing-set set))
       (dvs (map (lambda (x) (cog-value x key)) oset))
      )
      (begin
        (display set)
        (display dvs)
      )
    )
)


