# MAC Accelerator — Synthesis and Physical-Design Results

## 1. Objective

Compare a baseline multiply-accumulate (MAC) design with a
pipelined MAC design using generic synthesis statistics and an
RTL-to-GDSII physical-design flow.

## 2. Tools and Platform

- RTL: Verilog
- Functional simulation: Icarus Verilog
- Generic synthesis: Yosys
- Physical-design flow: OpenROAD-flow-scripts
- Standard-cell platform: Nangate45
- Target clock period: 5.0 ns
- Core utilization target: 40%

## 3. Generic Synthesis Results

These statistics come from generic Yosys synthesis and are
not technology-mapped physical area measurements.

| Metric | Baseline | Pipelined |
|---|---:|---:|
| Wires | 2269 | 2058 |
| Wire bits | 2377 | 2228 |
| Generic logic cells | 2342 | 2193 |
| D flip-flops | 40 | 73 |
| MUX cells | 40 | 72 |

The pipelined design uses additional registers to store the
product and its validity. Generic cell counts alone do not
determine final physical area, delay, or power.

## 4. Physical-Design PPA Results

| Metric | Baseline | Pipelined |
|---|---:|---:|
| Synthesis area (library area units) | 2700.432 | 2940.630 |
| Critical-path delay | 2.4442 ns | 2.4053 ns |
| Critical-path slack | +2.5983 ns | +2.6484 ns |
| Estimated total power | 5.83 mW | 3.33 mW |
| Setup violations | 0 | 0 |
| Hold violations | 0 | 0 |
| Final GDS generated | Yes | Yes |

The pipelined design has approximately 8.9% higher synthesis
area. Its overall critical-path delay improves modestly in
this run, while the reported total power estimate is lower.

The overall critical path still includes the multiplier.
The designs have different cycle-level latency, so their
performance must be interpreted in the context of the
architectural difference.

## 5. Timing Constraints

- Clock period: 5.0 ns
- Input and output delay assumptions: 20% of the clock period
- Both final reports show positive critical-path slack.
- Both final reports show zero setup and hold violations.
- Maximum slew, fanout, and capacitance violation counts are
  zero in both final reports.

## 6. Power and Area Interpretation

Power values are estimates from the flow, not measurements
from fabricated silicon. They depend on the power-analysis
settings and switching-activity assumptions.

The synthesis area values are library-area units and should
not be described as the final placed-and-routed cell area.

## 7. Physical-Design Artifacts

Final implementation files and reports are saved under
`results/`:

- `results/gds/mac_baseline_final.gds`
- `results/gds/mac_pipelined_final.gds`
- `results/reports/mac_baseline_finish.rpt`
- `results/reports/mac_pipelined_finish.rpt`
- `results/synthesis/mac_baseline_synth_stat.txt`
- `results/synthesis/mac_pipelined_synth_stat.txt`
- `results/PPA_COMPARISON.md`

## 8. Limitations

These results apply to the Nangate45 reference platform and
the constraints used in this flow. They are not measured
silicon results. The modest overall delay improvement does
not demonstrate a dramatic speedup from pipelining. Further
experiments could explore multiplier architecture, pipeline
boundaries, constraints, and switching-activity assumptions.
