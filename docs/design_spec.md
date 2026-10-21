# Pipelined MAC Accelerator — Design Specification

## Objective
Implement and compare baseline and pipelined signed
multiply-accumulate architectures.

## Arithmetic
ACC_next = ACC_current + (A * B)

## Parameters
- Input A: 16-bit signed
- Input B: 16-bit signed
- Product: 32-bit signed
- Accumulator: 40-bit signed
- Reset: synchronous, active-high
- Accumulator update: controlled by enable
- Overflow: 40-bit two's-complement wraparound

## Architectures
1. Baseline non-pipelined MAC
2. Pipelined MAC

## Verification
Self-checking Verilog testbench comparing expected
results against simulated outputs.

## Evaluation
- Functional correctness
- Timing
- Cell area
- Available power estimates
- Physical implementation results
