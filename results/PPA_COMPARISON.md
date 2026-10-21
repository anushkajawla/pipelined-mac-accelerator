# Pipelined MAC Accelerator — PPA Comparison

## Design
- Baseline MAC: combinational multiplier feeding the accumulator register.
- Pipelined MAC: product register separates multiplication from accumulation.
- Platform: Nangate45 standard-cell library.
- Target clock period: 5.00 ns.
- Flow: OpenROAD-flow-scripts (RTL-to-GDSII).

## Results

| Metric | Baseline MAC | Pipelined MAC |
|---|---:|---:|
| Synthesis area (library area units) | 2700.432 | 2940.630 |
| Critical path delay | 2.4442 ns | 2.4053 ns |
| Critical-path slack | +2.5983 ns | +2.6484 ns |
| Estimated total power | 5.83 mW | 3.33 mW |
| Setup/hold violations | 0 / 0 | 0 / 0 |
| Final GDS generated | Yes | Yes |

## Interpretation
- The pipelined design has approximately 8.9% higher synthesis area.
- The overall worst-path delay improves only slightly in this run.
- The reported total power estimate is lower for the pipelined design.
- Power is an estimate and depends on the activity assumptions and analysis settings.
- Synthesis area is not the same as final placed-and-routed cell area.
- Both designs completed the physical-design flow and generated final GDS files.

## Verification
Both designs passed their respective Icarus Verilog testbenches, including signed arithmetic checks and reset behavior. The pipelined testbench also checks pipeline latency and back-to-back operations.

## Limitations
These are results from a standard-cell reference platform and a particular set of flow constraints. They are not measured silicon results. The designs have different cycle-level latency, so comparisons should account for that architectural difference.
