# MAC Accelerator — Verification Report

## 1. Objective

Verify the baseline and pipelined MAC designs using Icarus Verilog simulation.

## 2. Baseline MAC Verification

**Testbench:** `tb/tb_mac_baseline.v`

**Result:** PASS — all tests passed.

| Test case | Expected result | Status |
|---|---:|---|
| Reset clears accumulator | 0 | PASS |
| Multiply 3 × 4 | 12 | PASS |
| Repeated accumulation | 24 | PASS |
| Enable low | Accumulator holds | PASS |
| Negative multiplication | 12 | PASS |
| Reset clears accumulated result | 0 | PASS |
| Back-to-back operations | 10, then 28 | PASS |
| Multiple disabled cycles | Accumulator holds at 28 | PASS |
| Reset during activity | 0 | PASS |
| Signed 40-bit overflow | 1,006,568,449 | PASS |

## 3. Pipelined MAC Verification

**Testbench:** `tb/tb_mac_pipelined.v`

**Result:** PASS — all tests passed.

| Test case | Expected result | Status |
|---|---|---|
| Reset clears accumulator | 0 | PASS |
| First product captured | Accumulator remains 0 | PASS |
| First product accumulated | 12 | PASS |
| Back-to-back operations | 22, then 40 | PASS |
| Disabled cycles | Accumulator holds at 40 | PASS |
| Negative multiplication | 28 after accumulation | PASS |
| Reset with pending product | 0 | PASS |
| No stale product after reset | 0 | PASS |
| Signed 40-bit overflow | 1,006,568,449 | PASS |

## 4. Pipeline Latency

The pipelined design registers the multiplication result in `product_reg` and uses `valid_reg` to indicate a valid product.

The accumulator consumes the registered product on a subsequent rising clock edge. Therefore, the product is accumulated one clock cycle after it is accepted.

## 5. Reset and Enable Behavior

- Reset is synchronous and active-high.
- Reset clears the accumulator, product register, and valid flag.
- When `en` is low, no new product is accepted.
- A previously accepted valid product can still be accumulated after `en` goes low.

## 6. Arithmetic Verification

Both designs were tested with positive and negative operands. The 40-bit accumulator overflow test verified two's-complement wraparound for repeated accumulation of 32767 × 32767.

## 7. Final Result

Both baseline and pipelined MAC simulations completed with `ALL TESTS PASSED`.

Functional simulation verifies the tested arithmetic, reset, enable, pipeline-latency, and wraparound behavior. Simulation results alone do not establish physical timing or power.

## 8. Physical-Design Validation

Both designs completed the OpenROAD-flow-scripts RTL-to-GDSII flow on the Nangate45 reference platform.

| Metric | Baseline | Pipelined |
|---|---:|---:|
| Target clock period | 5.0 ns | 5.0 ns |
| Critical-path delay | 2.4442 ns | 2.4053 ns |
| Critical-path slack | +2.5983 ns | +2.6484 ns |
| Setup violations | 0 | 0 |
| Hold violations | 0 | 0 |
| Estimated total power | 5.83 mW | 3.33 mW |

Final GDS layouts and implementation reports are saved under `results/`.

Power figures are tool estimates, not measurements from fabricated silicon. The overall critical-path delay improvement is modest, and the designs have different cycle-level latency.

See `docs/synthesis_results.md` and `results/PPA_COMPARISON.md` for further details and limitations.
