# 02203 Assignment 1 – Greatest Common Divisor (SystemVerilog)

This repository contains a **SystemVerilog implementation** of **Assignment 1** in *02203 Design of Digital Systems (Fall 2026)* at DTU.  

The goal of this assignment is to design, simulate, and implement a digital circuit that computes the **Greatest Common Divisor (GCD)** of two positive integers using **Euclid’s algorithm**.  

The design flow follows a **top-down, simulation-based methodology** and targets the **Xilinx Nexys 4 DDR / Nexys A7 FPGA board**.


Otto Westy Rasmussen, S203838, S203838@dtu.dk


## Repository Structure

``` bash
├── README.md                 # This file
├── task1/                    # Executable specification and testbench
│   ├── gcd_tb.sv
│   └── gcd_top.sv
├── task2/                    # FSMD-style implementation
│   ├── debounce.sv
│   ├── gcd.sv
│   ├── gcd_tb.sv
│   ├── gcd_top.sv
│   └── Nexys4DDR_gcd.xdc
└── task4/                    # Optional structural implementation
    └── comp.sv
```

## Simulation and Tools

- **Simulation FPGA Synthesis and Testing:**  
  - Tool: [Xilinx Vivado](https://www.xilinx.com/products/design-tools/vivado.html)  
  - Target board: Nexys 4 DDR or Nexys A7  
  - Use `Nexys4DDR_gcd.xdc` for FPGA pin constraints  

- **(Optional) Simulation:**  
  - Use [Verilator](https://www.veripool.org/verilator/)  
  - Testbenches are included (`task1/gcd_tb.sv`, `task2/gcd_tb.sv`)  


## Notes
- This repo provides a **SystemVerilog** version of the assignment (original was in VHDL).  
