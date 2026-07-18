(require '[clojure.test :as test])
(def test-namespaces
  '[todoke.cells.handoff-proof.test-state-machine
    todoke.cells.route-sequencing.test-state-machine
    todoke.methods.test-charter-gates todoke.methods.test-last-mile
    todoke.methods.test-last-mile-parity todoke.murakumo-test
    todoke.repository-contract-test])
(doseq [namespace test-namespaces] (require namespace))
(let [result (apply test/run-tests test-namespaces)]
  (println "==> todoke:" (select-keys result [:test :pass :fail :error]))
  (when (pos? (+ (:fail result) (:error result))) (System/exit 1)))
