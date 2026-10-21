# Pipelined MAC Accelerator — RTL-to-GDSII and PPA Analysis

A digital VLSI design project comparing a baseline Multiply-Accumulate (MAC) unit with a pipelined implementation using Verilog RTL and an open-source RTL-to-GDSII physical design flow.

The project explores how pipelining affects timing, area, and estimated power, from RTL simulation and synthesis through physical implementation and final GDSII generation.

## Project Overview

A Multiply-Accumulate (MAC) unit performs multiplication and addition:

\[
ACC_{next} = ACC_{current} + (A \times B)
\]

MAC units are widely used in digital signal processing, image processing, machine learning, and other computationally intensive applications.

This project implements and compares two architectures:

- **Baseline MAC:** Multiplies the input operands and adds the product to the accumulator without an intermediate product pipeline register.
- **Pipelined MAC:** Introduces a product register between multiplication and accumulation to separate the computation across clock cycles.

The objective is to study the trade-offs introduced by pipelining and evaluate both implementations using simulation, synthesis, static timing analysis, and physical design reports.

## Design Specifications

| Parameter | Specification |
|---|---|
| Hardware description language | Verilog |
| Input operands | Signed 16-bit values |
| Product width | 32 bits |
| Accumulator width | 40 bits |
| Clock target | 5.00 ns |
| Standard-cell library | Nangate45 |
| Simulation | Icarus Verilog |
| Waveform analysis | GTKWave |
| Synthesis | Yosys |
| Physical design | OpenROAD-flow-scripts |
| Final layout format | GDSII |

## Architecture

### 1. Baseline MAC

The baseline implementation performs multiplication and accumulation in the same computation path.

**Data path:**

`Inputs → Multiplier → Accumulation Logic → Accumulator Register`

The multiplication and accumulation logic contribute to the combinational path leading to the accumulator register.

### 2. Pipelined MAC

The pipelined implementation introduces an intermediate register to store the multiplication result.

**Data path:**

`Inputs → Multiplier → Product Register → Accumulation Logic → Accumulator Register`

The added pipeline stage separates multiplication from accumulation. This can reduce the delay of an individual register-to-register path, at the cost of additional registers, area, and pipeline latency.

The pipelined implementation must be evaluated with its different cycle-level behavior in mind; the two architectures should not be assumed to produce results at identical clock cycles.

## Verification

Both designs have dedicated Verilog testbenches and were simulated using Icarus Verilog.

Verification scenarios include:

- Reset behavior and accumulator initialization
- Signed multiplication and accumulation
- Consecutive accumulation operations
- Enable control and state retention
- Pipeline latency and back-to-back operations for the pipelined design

The simulations completed successfully, with the testbenches reporting passing test cases.

### Viewing Waveforms

The generated VCD files can be inspected using GTKWave.

```bash
cd ~/mac_accelerator

gtkwave sim/mac_baseline.vcd
```

To inspect the pipelined design:

```bash
gtkwave sim/mac_pipelined.vcd
```

Useful signals include the clock, reset, enable, input operands, product, accumulator, and internal pipeline registers.

## RTL-to-GDSII Flow

The project follows an open-source digital implementation flow:

1. **RTL design:** Implement the baseline and pipelined MAC architectures in Verilog.
2. **Functional verification:** Simulate the RTL using Icarus Verilog and inspect waveforms using GTKWave.
3. **Logic synthesis:** Use Yosys to synthesize the designs into gate-level netlists.
4. **Floorplanning and placement:** Prepare the physical design and place standard cells.
5. **Clock-tree synthesis:** Build the clock distribution network.
6. **Routing:** Implement signal interconnections.
7. **Timing and physical analysis:** Inspect timing, area, and power reports.
8. **GDSII generation:** Generate final layout files for both implementations.

The physical implementation uses the Nangate45 standard-cell platform with a 5.00 ns target clock period.

## Repository Structure

```text
pipelined-mac-accelerator/
├── docs/
│   ├── design_spec.md
│   ├── synthesis_results.md
│   └── verification.md
├── physical_design/
├── results/
│   ├── PPA_COMPARISON.md
│   ├── gds/
│   │   ├── mac_baseline_final.gds
│   │   └── mac_pipelined_final.gds
│   ├── reports/
│   └── synthesis/
├── rtl/
│   ├── mac_baseline.v
│   └── mac_pipelined.v
├── scripts/
│   ├── synth_mac.ys
│   └── synth_mac_pipelined.ys
├── sim/
│   ├── mac_baseline.vcd
│   └── mac_pipelined.vcd
├── synthesis/
│   ├── mac_baseline_netlist.v
│   └── mac_pipelined_netlist.v
├── tb/
│   ├── tb_mac_baseline.v
│   └── tb_mac_pipelined.v
├── .gitignore
└── README.md
```

## PPA Comparison

The following values are taken from the collected physical-design reports.

| Metric | Baseline MAC | Pipelined MAC |
|---|---:|---:|
| Reported design area (µm²) | 2700.432 | 2940.630 |
| Critical-path delay (ns) | 2.4442 | 2.4053 |
| Reported slack (ns) | +2.5983 | +2.6484 |
| Estimated power (mW) | 5.83 | 3.33 |
| Setup violations | 0 | 0 |
| Hold violations | 0 | 0 |
| Final GDSII generated | Yes | Yes |

### Results and Observations

- **Area:** The pipelined implementation has approximately 8.9% higher reported area, reflecting the cost of the additional pipeline register and associated logic.
- **Critical-path delay:** The reported delay decreases from 2.4442 ns to 2.4053 ns, an improvement of approximately 1.6%.
- **Timing slack:** Both implementations report positive slack under the configured timing constraints.
- **Estimated power:** The collected reports show a reduction from 5.83 mW to 3.33 mW. These are tool estimates, not measured silicon power; the comparison depends on the flow's activity and power-estimation assumptions.
- **Physical implementation:** Final GDSII files were generated for both designs, and the collected reports show zero setup and hold violations.

The results demonstrate that pipelining involves trade-offs rather than automatically improving every PPA metric. In this implementation, the reported timing improvement is modest and comes with increased area.

## Key Learnings

- Designing and verifying parameterized-width arithmetic datapaths in Verilog
- Understanding signed multiplication, accumulation, reset, and enable behavior
- Comparing combinational and pipelined architectures
- Running RTL simulation and interpreting VCD waveforms
- Synthesizing RTL into standard-cell netlists
- Reading static timing analysis reports and understanding critical paths and slack
- Evaluating area and estimated power trade-offs
- Following an open-source RTL-to-GDSII implementation flow
- Managing design artifacts and version control using Git and GitHub

## Tools Used

- Verilog
- Icarus Verilog
- GTKWave
- Yosys
- OpenROAD-flow-scripts
- Nangate45 standard-cell library
- Linux / Ubuntu
- Git and GitHub

## Limitations and Future Improvements

Potential extensions include:

- Improving the pipelined architecture and investigating the critical path in greater detail
- Comparing multiple pipeline configurations
- Running controlled power estimation with documented switching activity
- Adding automated regression tests and reproducible result-generation scripts
- Capturing floorplan, placement, clock-tree, routing, and final layout screenshots
- Investigating setup and hold timing across different clock constraints

## Disclaimer

This is an educational VLSI design and physical implementation project. Reported results are specific to the RTL, constraints, standard-cell library, and open-source tool flow used. Generated GDSII layouts and tool reports do not imply fabrication, silicon validation, or sign-off for a production chip.

## Author

**Anushka Jawla**

ECE Graduate, 2026

[GitHub Repository](https://github.com/anushkajawla/pipelined-mac-accelerator)
