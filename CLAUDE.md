# . — CLAUDE.md

## Identity
- **Name**: todoke (届け — "to deliver / to reach the destination")
- **DID**: `did:web:etzhayyim.com:actor:todoke`
- **ADR**: ADR-2606042300 (R0 scaffold)
- **Status**: R0 — cells raise RuntimeError on `.solve()`; `route_sequencing` + `handoff_proof` fully coded; `todoke-route` Rust crate green
- **Tier**: Tier-B religious-corp actor
- **Siblings**: wadachi 轍 (inter-site ground autonomy) · okaimono 御買物 (no-gig fulfilment) · haraedo 祓戸 (dispatch/VRP) · tazuna 手綱 (remote-robotics teleop)
- **Consumes**: kami-autodrive GNC (ADR-2606010600) · sarutahiko LoaderRobot pattern (ADR-2606013100)

## Architecture

5 Pregel cells, linear:

```
parcel_intake → route_sequencing → autonomous_run → handoff_proof → telemetry_log
```

The two constitutionally-load-bearing cells are **fully coded + tested** at R0:
- `route_sequencing` enforces the **G7 safety envelope** (speed/zone/SAE-level refusal).
- `handoff_proof` enforces **G8 privacy-by-construction** + **G12 no-server-key** + **G13 consent**.

## Rust core — `route/` (`todoke-route`)

Pure, zero-dep, deterministic. The repo has **no root Cargo workspace**, so this is a standalone
leaf crate: `cd route && cargo test` (7 tests). It owns ONLY the last-mile-specific math:
stop sequencing (NN + 2-opt) and the SAE-L4 sidewalk ODD safety envelope. Everything else
(perception/planning/control) delegates to kami-autodrive. `src/todoke/methods/last_mile.cljc` is the
parity-tested Python mirror — keep the two in lockstep (per-zone caps, NN/2-opt order, refusals).

## Constitutional invariants (encoded in 3 places: schema + lexicon `const` + code)

| Invariant | Gate | Where enforced |
|---|---|---|
| `armed = false` | G14/N1 | `deliveryJob` const, `:job/armed` |
| `gig = false` | G5/N4 | `deliveryJob` const, `:job/gig` |
| `saeWithinCeiling = true` (≤4) | N2 | `lastMileRoute` const + `todoke-route` `SaeLevelTooHigh` refusal |
| `onDeviceOnly = true` | G8 | `handoffProof` const + `transition_to_proof_captured` (forbidden kinds raise) |
| `serverSigned = false` | G12 | `handoffProof` const + `transition_to_proof_sealed` (server-sign raises) |

## Lexicon Namespace

`com.etzhayyim.todoke` — records: `deliveryJob`, `lastMileRoute`, `handoffProof`,
`missionCompleteRecord`, `safetyAlert`.

## Testing (R0)

```bash
cd ./route   && cargo test                                              # 7
cd ./methods && PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 python3 -m pytest -q   # 7
cd ./cells   && PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 python3 -m pytest -q   # 12
```

The `PYTEST_DISABLE_PLUGIN_AUTOLOAD=1` is needed only to dodge an unrelated broken
langsmith/pydantic in the host env; todoke code has no such dependency.

## Do Not
- Do not let `route_sequencing` clamp an out-of-envelope speed — it must **refuse** (return the
  violation), matching the Rust `Err`. Silent clamping would hide a G7 breach.
- Do not add a cloud/biometric proof kind to `handoff_proof` (G8/N5) — proof stays on-device.
- Do not wire live actuation without the G9 gate (Council Lv6+ + operator) + Transparent-Force
  Datom logging. R0–R1 is design + sim only.
- Do not let todoke become the buyer/payer — settlement is member-signed (G12), USDC + TitheRouter (G15).
