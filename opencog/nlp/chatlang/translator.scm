;; ChatLang DSL for chat authoring rules
;;
;; A partial implementation of the top level translator that produces
;; PSI rules.
(use-modules (opencog)
             (opencog nlp)
             (opencog exec)
             (opencog openpsi)
             (opencog eva-behavior)
             (srfi srfi-1)
             (rnrs io ports)
             (ice-9 popen)
             (ice-9 optargs))

(define-public (chatlang-prefix STR) (string-append "Chatlang: " STR))
(define chatlang-anchor (Anchor (chatlang-prefix "Currently Processing")))
(define chatlang-no-constant (Node (chatlang-prefix "No constant terms")))
(define chatlang-word-seq (Predicate (chatlang-prefix "Word Sequence")))
(define chatlang-lemma-seq (Predicate (chatlang-prefix "Lemma Sequence")))
(define chatlang-grd-words (Anchor (chatlang-prefix "Grounded Words")))
(define chatlang-grd-lemmas (Anchor (chatlang-prefix "Grounded Lemmas")))

;; Shared variables for all terms
(define atomese-variable-template (list (TypedVariable (Variable "$S")
                                                       (Type "SentenceNode"))
                                        (TypedVariable (Variable "$P")
                                                       (Type "ParseNode"))))

;; Shared conditions for all terms
(define atomese-condition-template (list (Parse (Variable "$P")
                                                (Variable "$S"))
                                         (State chatlang-anchor
                                                (Variable "$S"))))

(define (order-terms TERMS)
  "Order the terms in the intended order, and insert wildcards into
   appropriate positions of the sequence."
  (let* ((as (cons 'anchor-start "<"))
         (ae (cons 'anchor-end ">"))
         (wc (cons 'wildcard (cons 0 -1)))
         (start-anchor? (any (lambda (t) (equal? as t)) TERMS))
         (end-anchor? (any (lambda (t) (equal? ae t)) TERMS))
         (start (if start-anchor? (cdr (member as TERMS)) (list wc)))
         (end (if end-anchor?
                  (take-while (lambda (t) (not (equal? ae t))) TERMS)
                  (list wc))))
        (cond ((and start-anchor? end-anchor?)
               (if (equal? start-anchor? end-anchor?)
                   ; If they are equal, we are not expecting
                   ; anything else, either one of them is
                   ; the whole sequence
                   (drop-right start 1)
                   ; If they are not equal, put a wildcard
                   ; in between them
                   (append start (list wc) end)))
               ; If there is only a start-anchor, append it and
               ; a wildcard with the main-seq, follow by another
               ; wildcard at the end
              (start-anchor?
               (append start (list wc)
                       (take-while (lambda (t) (not (equal? as t))) TERMS)
                       end))
              ; If there is only an end-anchor, the main-seq should start
              ; with a wildcard, follow by another wildcard and finally
              ; the end-seq
              (end-anchor?
               (let ((after-anchor-end (cdr (member ae TERMS))))
                    (if (null? after-anchor-end)
                        (append start end)
                        ; In case there are still terms after anchor-end,
                        ; get it and add an extra wildcard
                        (append start after-anchor-end (list wc) end))))
              ; If there is no anchor, the main-seq should start and
              ; end with a wildcard
              (else (append (list wc) TERMS (list wc))))))

(define (process-pattern-terms TERMS)
  "Generate the atomese (i.e. the variable declaration and the pattern)
   for each of the TERMS."
  (define vars '())
  (define globs '())
  (define conds '())
  (define term-seq '())
  (for-each (lambda (t)
    (cond ((equal? 'lemma (car t))
           (let ((l (lemma (cdr t))))
                (set! vars (append vars (car l)))
                (set! conds (append conds (cdr l)))
                (set! term-seq
                  (append term-seq (list (Word (get-lemma (cdr t))))))))
          ((equal? 'word (car t))
           (let ((w (word (cdr t))))
                (set! vars (append vars (car w)))
                (set! conds (append conds (cdr w)))
                (set! term-seq
                  (append term-seq (list (Word (get-lemma (cdr t))))))))
          ((equal? 'phrase (car t))
           (let ((p (phrase (cdr t))))
                (set! vars (append vars (car p)))
                (set! conds (append conds (cdr p)))
                (set! term-seq (append term-seq
                  (map Word (map get-lemma (string-split (cdr t) #\sp)))))))
          ((equal? 'concept (car t))
           (let* ((v (choose-var-name))
                  (c (concept (cdr t) v)))
                 (set! globs (append globs (car c)))
                 (set! conds (append conds (cdr c)))
                 (set! term-seq (append term-seq (list (Glob v))))))
          ((equal? 'choices (car t))
           (let* ((v (choose-var-name))
                  (c (choices (cdr t) v)))
                 (set! globs (append globs (car c)))
                 (set! conds (append conds (cdr c)))
                 (set! term-seq (append term-seq (list (Glob v))))))
          ((equal? 'unordered-matching (car t))
           (let* ((v (choose-var-name))
                  (u (unordered-matching (cdr t) v)))
                 (set! vars (append vars
                   (filter (lambda (x) (equal? 'VariableNode (cog-type (gar x))))
                           (car u))))
                 (set! globs (append globs
                   (filter (lambda (x) (equal? 'GlobNode (cog-type (gar x))))
                           (car u))))
                 (set! conds (append conds (cdr u)))
                 (set! term-seq (append term-seq (list (Glob v))))))
          ((equal? 'negation (car t))
           (set! conds (append conds (cdr (negation (cdr t))))))
          ((equal? 'wildcard (car t))
           (let* ((v (choose-var-name))
                  (w (wildcard (cadr t) (cddr t) v)))
                 (set! globs (append globs (car w)))
                 (set! term-seq (append term-seq (list (Glob v))))))))
    TERMS)
  ; DualLink couldn't match patterns with no constant terms in it
  ; Mark the rules with no constant terms so that they can be found
  ; easily during the matching process
  (if (equal? (length term-seq)
              (length (filter (lambda (x) (equal? 'GlobNode (cog-type x)))
                              term-seq)))
    (MemberLink (List term-seq) chatlang-no-constant))
  (list vars globs conds term-seq))

(define-public (say TXT)
  "Say the text and clear the state."
  ; TODO: Something simplier?
  (And (True (Put (DefinedPredicate "Say") (Node TXT)))
       (True (Put (State chatlang-anchor (Variable "$x"))
                  (Concept "Default State")))))

(define (process-action ACTION)
  "Process a single action -- converting it into atomese."
  (cond ((equal? 'say (car ACTION))
         (say (cdr ACTION)))))

(define-public (store-groundings SENT GRD)
  "Store the groundings, both original words and lemmas,
   for each of the GlobNode in the pattern, by using StateLinks.
   They will be referenced in the stage of evaluating the context
   of the psi-rules, or executing the action of the psi-rules."
  (let ((sent-word-seq (cog-outgoing-set (car (sent-get-word-seqs SENT))))
        (cnt 0))
       (for-each (lambda (g)
         (if (equal? 'ListLink (cog-type g))
             (if (equal? (gar g) (gadr g))
                 ; If the grounded value is the GlobNode itself,
                 ; that means the GlobNode is grounded to nothing
                 (begin
                   (State (Set (gar g) chatlang-grd-words) (List))
                   (State (Set (gar g) chatlang-grd-lemmas) (List)))
                 ; Store the GlobNode and the groundings
                 (begin
                   (State (Set (gar g) chatlang-grd-words)
                          (List (take (drop sent-word-seq cnt)
                                      (length (cog-outgoing-set (gdr g))))))
                   (State (Set (gar g) chatlang-grd-lemmas) (gdr g))
                   (set! cnt (+ cnt (length (cog-outgoing-set (gdr g)))))))
             ; Move on if it's not a GlobNode
             (set! cnt (+ cnt 1))))
         (cog-outgoing-set GRD)))
  (True))

(define (generate-bind GLOB-DECL TERM-SEQ)
  "Generate a BindLink that contains the TERM-SEQ and the
   restrictions on the GlobNode in the TERM-SEQ, if any."
  (Bind (VariableList GLOB-DECL
                      (TypedVariable (Variable "$S")
                                     (Type "SentenceNode")))
        (And TERM-SEQ
             (State chatlang-anchor (Variable "$S")))
        (ExecutionOutput (GroundedSchema "scm: store-groundings")
                         (List (Variable "$S")
                               (List (map (lambda (x)
                                 (if (equal? 'GlobNode (cog-type x))
                                     (List (Quote x) (List x))
                                     x))
                                 (cog-outgoing-set (gddr TERM-SEQ))))))))

(define* (chat-rule PATTERN ACTION #:optional (TOPIC default-topic) NAME)
  "Top level translation function. Pattern is a quoted list of terms,
   and action is a quoted list of actions or a single action."
  (let* ((ordered-terms (order-terms PATTERN))
         (proc-terms (process-pattern-terms ordered-terms))
         (vars (append atomese-variable-template (list-ref proc-terms 0)))
         (globs (list-ref proc-terms 1))
         (conds (append atomese-condition-template (list-ref proc-terms 2)))
         (term-seq (Evaluation chatlang-lemma-seq
                     (List (Variable "$S") (List (list-ref proc-terms 3)))))
         (action (process-action ACTION))
         (bindlink (generate-bind globs term-seq))
         (psi-rule (psi-rule-nocheck
                     (list (Satisfaction (VariableList vars) (And conds)))
                     action
                     (True)
                     (stv .9 .9)
                     TOPIC
                     NAME)))
        (cog-logger-debug "ordered-terms: ~a" ordered-terms)
        (cog-logger-debug "BindLink: ~a" bindlink)
        (cog-logger-debug "psi-rule: ~a" psi-rule)
        ; Link both the newly generated BindLink and psi-rule together
        (Reference bindlink psi-rule)))

(define (sent-get-word-seqs SENT)
  "Get the words (original and lemma) associate with SENT.
   It also creates an EvaluationLink linking the
   SENT with the word-list and lemma-list."
  (define (get-seq TYPE)
    (List (append-map
      (lambda (w)
        ; Ignore LEFT-WALL and punctuations
        (if (or (string-prefix? "LEFT-WALL" (cog-name w))
                (word-inst-match-pos? w "punctuation")
                (null? (cog-chase-link TYPE 'WordNode w)))
            '()
            ; For proper names, e.g. Jessica Henwick,
            ; RelEx converts them into a single WordNode, e.g.
            ; (WordNode "Jessica_Henwick"). Codes below try to
            ; split it into two WordNodes, "Jessica" and "Henwick",
            ; so that the matcher will be able to find the rules
            (let* ((wn (car (cog-chase-link TYPE 'WordNode w)))
                   (name (cog-name wn)))
              (if (integer? (string-index name #\_))
                  (map Word (string-split name  #\_))
                  (list wn)))))
      (car (sent-get-words-in-order SENT)))))
  (let ((word-seq (get-seq 'ReferenceLink))
        (lemma-seq (get-seq 'LemmaLink)))
       ; These EvaluationLinks will be used in the matching process
       (Evaluation chatlang-word-seq (List SENT word-seq))
       (Evaluation chatlang-lemma-seq (List SENT lemma-seq))
       (cons word-seq lemma-seq)))

(define (get-lemma WORD)
  "A hacky way to quickly find the lemma of a word using WordNet."
  (let* ((cmd-string (string-append "wn " WORD " | grep \"Information available for .\\+\""))
         (port (open-input-pipe cmd-string))
         (lemma ""))
    (do ((line (get-line port) (get-line port)))
        ((eof-object? line))
      (let ((l (car (last-pair (string-split line #\ )))))
        (if (not (equal? (string-downcase WORD) l))
          (set! lemma l))))
    (close-pipe port)
    (if (string-null? lemma) WORD lemma)))

(define (is-lemma? WORD)
  "Check if WORD is a lemma."
  (equal? WORD (get-lemma WORD)))

(define (get-members CONCEPT)
  "Get the members of a concept. VariableNodes will be ignored, and
   recursive calls will be made in case there are nested concepts."
  (append-map
    (lambda (g)
      (cond ((eq? 'ConceptNode (cog-type g)) (get-members g))
            ((eq? 'VariableNode (cog-type g)) '())
            (else (list g))))
    (cog-outgoing-set
      (cog-execute! (Get (Reference (Variable "$x") CONCEPT))))))

(define (is-member? GLOB LST)
  "Check if GLOB is a member of LST, where LST may contain
   WordNodes, LemmaNodes, and PhraseNodes."
  ; TODO: GLOB is grounded to lemmas but not the original
  ; words in the input, this somehow needs to be fixed...
  (let* ((glob-txt-lst (map cog-name GLOB))
         (raw-txt (string-join glob-txt-lst))
         (lemma-txt (string-join (map get-lemma glob-txt-lst))))
    (any (lambda (t)
           (or (and (eq? 'WordNode (cog-type t))
                    (equal? raw-txt (cog-name t)))
               (and (eq? 'LemmaNode (cog-type t))
                    (equal? lemma-txt (cog-name t)))
               (and (eq? 'PhraseNode (cog-type t))
                    (equal? raw-txt (cog-name t)))))
         LST)))

(define-public (chatlang-concept? CONCEPT . GLOB)
  "Check if the value grounded for the GlobNode is actually a member
   of the concept."
  (cog-logger-debug "In chatlang-concept? GLOB: ~a" GLOB)
  (if (is-member? GLOB (get-members CONCEPT))
      (stv 1 1)
      (stv 0 1)))

(define-public (chatlang-choices? CHOICES . GLOB)
  "Check if the value grounded for the GlobNode is actually a member
   of the list of choices."
  (cog-logger-debug "In chatlang-choices? GLOB: ~a" GLOB)
  (let* ((chs (cog-outgoing-set CHOICES))
         (cpts (append-map get-members (cog-filter 'ConceptNode chs))))
        (if (is-member? GLOB (append chs cpts))
            (stv 1 1)
            (stv 0 1))))

(define (text-contains? RTXT LTXT TERM)
  "Check if either RTXT (raw) or LTXT (lemma) contains TERM."
  (define (contains? txt term)
    (not (equal? #f (regexp-exec
      (make-regexp (string-append "\\b" term "\\b") regexp/icase) txt))))
  (cond ((equal? 'WordNode (cog-type TERM))
         (contains? RTXT (cog-name TERM)))
        ((equal? 'LemmaNode (cog-type TERM))
         (contains? LTXT (cog-name TERM)))
        ((equal? 'PhraseNode (cog-type TERM))
         (contains? RTXT (cog-name TERM)))
        ((equal? 'ConceptNode (cog-type TERM))
         (any (lambda (t) (text-contains? RTXT LTXT t))
              (get-members TERM)))))

(define-public (chatlang-negation? . TERMS)
  "Check if the input sentence has none of the terms specified."
  (let* ; Get the raw text input
        ((sent (car (cog-chase-link 'StateLink 'SentenceNode chatlang-anchor)))
         (rtxt (cog-name (car (cog-chase-link 'ListLink 'Node sent))))
         (ltxt (string-join (map get-lemma (string-split rtxt #\sp)))))
        (if (any (lambda (t) (text-contains? rtxt ltxt t)) TERMS)
            (stv 0 1)
            (stv 1 1))))
