#!/usr/bin/env bash
# todoke — clj/bb test suite (ADR-2606160842 py->clj port wave); ALL test namespaces, fleet green-check.
set -euo pipefail
cd "$(dirname "$0")"
exec bb -e '(load-file "src/todoke/methods/last_mile.cljc")
            (load-file "cells/handoff_proof/state_machine.cljc")
            (load-file "cells/route_sequencing/state_machine.cljc")
            (load-file "cells/handoff_proof/test_state_machine.cljc")
            (load-file "cells/route_sequencing/test_state_machine.cljc")
            (load-file "methods/test_charter_gates.cljc")
            (load-file "methods/test_last_mile.cljc")
            (let [r (apply clojure.test/run-tests
                           (quote [todoke.cells.handoff-proof.test-state-machine
                                   todoke.cells.route-sequencing.test-state-machine
                                   todoke.methods.test-charter-gates
                                   todoke.methods.test-last-mile]))]
              (System/exit (if (zero? (+ (:fail r) (:error r))) 0 1)))'
