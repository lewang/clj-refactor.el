(require 'cl)

(Given "^I open file \"\\(.+\\)\"$"
       (lambda (filename)
         (setq default-directory clj-refactor-root-path)
         (find-file filename)))

(Given "^I have a project \"\\([^\"]+\\)\" in \"\\([^\"]+\\)\"$"
       (lambda (project-name dir-name)
         (setq default-directory clj-refactor-root-path)

         ;; delete old directory
         (when (file-exists-p dir-name)
           (delete-directory dir-name t))

         ;; create directory structure
         (mkdir (expand-file-name project-name (expand-file-name "src" dir-name)) t)
         (mkdir (expand-file-name project-name (expand-file-name "test" dir-name)) t)

         ;; add project.clj
         (with-temp-file (expand-file-name "project.clj" dir-name)
           (insert "(defproject " project-name " \"0.1.0-SNAPSHOT\")"))))

(Given "^I have a clojure-file \"\\([^\"]+\\)\"$"
       (lambda (file-name)
         (setq default-directory clj-refactor-root-path)
         (find-file file-name)
         (save-buffer)
         (kill-buffer)))

(Given "^I switch project-clean-prompt off$"
       (lambda ()
         (setq cljr-project-clean-prompt nil)))

(Given "^I switch auto-sort off$"
       (lambda ()
         (setq cljr-auto-sort-ns nil)))

(Given "^I switch auto-sort on$"
       (lambda ()
         (setq cljr-auto-sort-ns t)))

(Given "^I set sort comparator to string length$"
       (lambda ()
         (setq cljr-sort-comparator 'cljr--string-length-comparator)))

(Given "^I set sort comparator to semantic$"
       (lambda ()
         (setq cljr-sort-comparator 'cljr--semantic-comparator)))

(Given "^I set sort comparator to string natural$"
       (lambda ()
         (setq cljr-sort-comparator 'cljr--string-natural-comparator)))

(Given "^I exit multiple-cursors-mode"
       (lambda ()
         (multiple-cursors-mode 0)))

(Given "^I call the rename callback directly with mock data for foo->baz"
       (lambda ()
         (cljr--rename-occurrences "example.two"
                                   '((:line-beg 3 :line-end 4 :col-beg 7 :col-end 9
                                                :name "foo"
                                                :file "tmp/src/example/two.clj"
                                                :match "")
                                     (:line-beg 5 :line-end 5 :col-beg 15
                                                :col-end 23 :name "foo"
                                                :file "tmp/src/example/one.clj"
                                                :match ""))
                                   "baz")))

(Given "^I call the rename callback directly with mock data for star->asterisk"
       (lambda ()
         (cljr--rename-occurrences "example.two"
                                   '((:line-beg 6 :line-end 7 :col-beg 7
                                                :col-end 10 :name "star*"
                                                :file "tmp/src/example/two.clj"
                                                :match "")
                                     (:line-beg 8 :line-end 8 :col-beg 17
                                                :col-end 27 :name "star*"
                                                :file "tmp/src/example/one.clj"
                                                :match ""))
                                   "asterisk*")))

(Given "^I call the add-missing-libspec callback directly with mock data to import"
       (lambda ()
         (cljr--add-missing-libspec "Date" '((java.util.Date :class)))))

(Given "^I call the add-missing-libspec callback directly with mock data to refer split"
       (lambda ()
         (cljr--add-missing-libspec "split" '((clojure.string  :ns)))))

(Given "^I call the add-missing-libspec callback directly with mock data to alias clojure.string"
       (lambda ()
         (cljr--add-missing-libspec "str/split" '((clojure.string :ns)))))

(Given "^I call the add-missing-libspec callback directly with mock data to require WebrequestHandler"
       (lambda ()
         (cljr--add-missing-libspec "WebrequestHandler" '((modular.ring.WebrequestHandler :type)))))

(Then "^the file should be named \"\\([^\"]+\\)\"$"
      (lambda (file-name-postfix)
        (assert (s-ends-with? file-name-postfix (buffer-file-name)) nil "Expected %S to end with %S" (buffer-file-name) file-name-postfix)))

(And "^the cursor is inside the first defn form$"
     (lambda ()
       (goto-char (point-min))
       (re-search-forward "defn")))

(Given "^I call the add-stubs function directly with mock data from the middleware"
       (lambda ()
         (cljr--insert-function-stubs (edn-read "(
{:parameter-list \"[^int arg]\", :name \"remove\"}
{:parameter-list \"[^int arg0 ^Object arg1]\", :name \"add\"}
{:parameter-list \"[^java.util.function.UnaryOperator arg]\", :name \"replaceAll\"}
{:parameter-list \"[^java.util.Collection arg]\", :name \"containsAll\"}
{:parameter-list \"[^java.util.Collection arg]\", :name \"removeAll\"}
{:parameter-list \"[]\", :name \"listIterator\"}
{:parameter-list \"[^int arg0 ^int arg1]\", :name \"subList\"}
{:parameter-list \"[]\", :name \"iterator\"}
{:parameter-list \"[^Object arg]\", :name \"lastIndexOf\"}
{:parameter-list \"[^int arg]\", :name \"listIterator\"}
{:parameter-list \"[^int arg0 ^java.util.Collection arg1]\", :name \"addAll\"}
{:parameter-list \"[^Object arg]\", :name \"add\"}
{:parameter-list \"[^int arg]\", :name \"get\"}
{:parameter-list \"[]\", :name \"toArray\"}
{:parameter-list \"[]\", :name \"clear\"}
{:parameter-list \"[^int arg0 ^Object arg1]\", :name \"set\"}
{:parameter-list \"[^java.util.Collection arg]\", :name \"retainAll\"}
{:parameter-list \"[]\", :name \"isEmpty\"}
{:parameter-list \"[^java.util.Collection arg]\", :name \"addAll\"}
{:parameter-list \"[]\", :name \"spliterator\"}
{:parameter-list \"[^Object arg]\", :name \"indexOf\"}
{:parameter-list \"[^Object... arg]\", :name \"toArray\"}
{:parameter-list \"[^java.util.Comparator arg]\", :name \"sort\"}
{:parameter-list \"[]\", :name \"size\"}
{:parameter-list \"[^Object arg]\", :name \"equals\"}
{:parameter-list \"[^Object arg]\", :name \"remove\"}
{:parameter-list \"[]\", :name \"hashCode\"}
{:parameter-list \"[^Object arg]\", :name \"contains\"})"))))

(Given "I call the cljr--inline-symbol function directly with mockdata to inline my-constant"
       (lambda ()
         (let ((response (edn-read "{:occurrences ({:match \"(println my-constant my-constant another-val)))\"
:file \"core.clj\"
:name \"refactor-nrepl.test/my-constant\"
:col-end 26
:col-beg 14
:line-end 5
:line-beg 5} {:match \"(println my-constant my-constant another-val)))\"
:file \"core.clj\"
:name \"refactor-nrepl.test/my-constant\"
:col-end 38
:col-beg 26
:line-end 5
:line-beg 5})
:definition {:line-beg 1
:line-end 1
:col-beg 1
:col-end 22
:name \"refactor-nrepl.test/my-constant\"
:file \"core.clj\"
:match \"(def my-constant 123)\"
:definition \"123\"}}")))
           (cljr--inline-symbol "fake-ns" (gethash :definition response)
                                (gethash :occurrences response)))))

(Given "I call the cljr--inline-symbol function directly with mockdata to inline another-val"
       (lambda ()
         (let ((response (edn-read "{:definition {:line-beg 4
:line-end 4
:col-beg 9
:col-end 21
:name \"another-val\"
:file \"core.clj\"
:match \"(let [another-val 321]\"
:definition \"321\"}
:occurrences ({:match \"(println my-constant my-constant another-val)))\"
:file \"core.clj\"
:name \"another-val\"
:col-end 50
:col-beg 38
:line-end 5
:line-beg 5})}")))
           (cljr--inline-symbol "fake-ns" (gethash :definition response)
                                (gethash :occurrences response)))))

(Given "I call the cljr--inline-symbol function directly with mockdata to inline some-val"
       (lambda ()
         (let ((response (edn-read "{:definition {:line-beg 5
:line-end 5
:col-beg 9
:col-end 17
:name \"some-val\"
:file \"core.clj\"
:match \"some-val 110]\"
:definition \"110\"}
:occurrences ()}")))
           (cljr--inline-symbol "fake-ns" (gethash :definition response)
                                (gethash :occurrences response)))))

(Given "I call the cljr--inline-symbol function directly with mockdata to inline my-inc"
       (lambda ()
         (let ((response (edn-read "{:definition {:definition \"(fn [n]\\n  (+ 1 n))\"
:line-beg 1
:line-end 2
:col-beg 1
:col-end 11
:name \"refactor-nrepl.foo/my-inc\"
:file \"core.clj\"
:match \"(defn my-inc [n]\\n  (+ 1 n))\"}
:occurrences ({:line-beg 4
:line-end 4
:col-beg 5
:col-end 12
:name \"refactor-nrepl.foo/my-inc\"
:file \"core.clj\"
:match \"(+ (my-inc (- 17 4) 55))\"} {:line-beg 6
:line-end 6
:col-beg 6
:col-end 13
:name \"refactor-nrepl.foo/my-inc\"
:file \"core.clj\"
:match \"(map my-inc (range 10))\"})}")))
           (cljr--inline-symbol "fake-ns" (gethash :definition response)
                                (gethash :occurrences response)))))

(defun cljr--make-signature-change
    (old-index new-index old-name &optional new-name)
  (let ((h (make-hash-table)))
    (puthash :old-index old-index h)
    (puthash :new-index new-index h)
    (puthash :old-name old-name h)
    (if new-name
        (puthash :new-name new-name h)
      (puthash :new-name old-name h))
    h))

(setq cljr--test-occurrences
      '((:line-beg 4
                   :line-end 4
                   :col-beg 4
                   :col-end 7
                   :name "core/tt"
                   :file "core.clj"
                   :match "(tt 1 2 3))")
        (:line-beg 3
                   :line-end 3
                   :col-beg 1
                   :col-end 25
                   :name "core/tt"
                   :file "core.clj"
                   :match "(defn tt [foo bar baz]\n  (println foo bar baz))")
        (:line-beg 4
                   :line-end 4
                   :col-beg 8
                   :col-end 11
                   :name "core/tt"
                   :file "core.clj"
                   :match "(map tt [1] [2] [3]))")
        (:line-beg 4
                   :line-end 4
                   :col-beg 17
                   :col-end 20
                   :name "core/tt"
                   :file "core.clj"
                   :match "(map (partial tt [1]) [2] [3]))")
        (:line-beg 5
                   :line-end 5
                   :col-beg 12
                   :col-end 15
                   :name "core/tt"
                   :file "core.clj"
                   :match "(apply tt [1] [2] args)))"))
      cljr--foo-bar-swapped (list (cljr--make-signature-change 0 1 "foo")
                                  (cljr--make-signature-change 1 0 "bar")
                                  (cljr--make-signature-change 2 2 "baz"))
      cljr--bar-baz-swapped (list (cljr--make-signature-change 0 0 "foo")
                                  (cljr--make-signature-change 1 2 "bar")
                                  (cljr--make-signature-change 2 1 "baz"))
      cljr--baz-renamed-to-qux (list (cljr--make-signature-change 0 0 "foo")
                                     (cljr--make-signature-change 1 1 "bar")
                                     (cljr--make-signature-change 2 2 "baz" "qux")))



(Given "I call the cljr--change-function-signature function directly with mockdata to swap foo and bar in a regular call-site"
       (lambda ()
         (cljr--change-function-signature (list (cl-first cljr--test-occurrences))
                                          cljr--foo-bar-swapped)))

(Given "I call the cljr--change-function-signature function directly with mockdata to swap foo and bar in function definition"
       (lambda ()
         (cljr--change-function-signature (list (cl-second cljr--test-occurrences))
                                          cljr--foo-bar-swapped)))

(Given "I call the cljr--change-function-signature function directly with mockdata to swap foo and bar in a higher-order call-site"
       (lambda ()
         (cljr--change-function-signature (list (cl-third cljr--test-occurrences))
                                          cljr--foo-bar-swapped)))

(Given "I call the cljr--change-function-signature function directly with mockdata to swap foo and bar in a partial call-site"
       (lambda ()
         (cljr--change-function-signature (list (cl-fourth cljr--test-occurrences))
                                          cljr--foo-bar-swapped)))

(Given "I call the cljr--change-function-signature function directly with mockdata to swap foo and bar in a call-site with apply"
       (lambda ()
         (cljr--change-function-signature (list (cl-fifth cljr--test-occurrences))
                                          cljr--foo-bar-swapped)))

(Given "I call the cljr--change-function-signature function directly with mockdata to swap bar and baz in a call-site with apply"
       (lambda ()
         (cljr--change-function-signature (list (cl-fifth cljr--test-occurrences))
                                          cljr--bar-baz-swapped)))

(Given "I call the cljr--change-function-signature function directly with mockdata to rename baz to qux"
       (lambda ()
         (cl-letf (((symbol-function 'cljr-rename-symbol)
                    (lambda (new-name)
                      (backward-char)
                      (replace-regexp "baz" new-name nil (point)
                                      (cljr--point-after '(paredit-forward-up 2))))))
           (cljr--change-function-signature (list (cl-second cljr--test-occurrences))
                                            cljr--baz-renamed-to-qux))))

(When "I kill the \"\\(.+\\)\" buffer"
      (lambda (buffer)
        (kill-buffer buffer)))
