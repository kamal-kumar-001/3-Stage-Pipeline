# RISC-V 3-Stage Pipelined Processor (RV32I Core)

A complete hardware implementation of a **3-Stage Pipelined RISC-V (RV32I) Processor Core** written in Verilog HDL for simulation and FPGA deployment (Xilinx Nexys A7). Designed as part of the CS2202L Computer Architecture Laboratory coursework.

---

## 🚀 Key Features

* **3-Stage Pipeline Architecture**:
  1. **Stage 1 (IF/ID)**: Instruction Fetch, Instruction Decoding, Register File Read, and Immediate Generation.
  2. **Stage 2 (EX)**: ALU Computations, Dual 33-bit Subtraction Comparisons, Branch/Jump Target Address Resolution, and Execute Result Multiplexing.
  3. **Stage 3 (MEM/WB)**: Data Memory Read/Write, Byte/Halfword/Word Alignment (`LB`, `LH`, `LW`, `SB`, `SH`, `SW`), Register File Writeback, and Branch Hazard Suppression.
* **RV32I Base Integer ISA Support**:
  * **R-Type / I-Type Arithmetic & Logic**: `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND`.
  * **Upper Immediate**: `LUI` (Load Upper Immediate).
  * **Control Flow & Jumps**: `JAL` (PC-relative jump) and `JALR` (Register-relative jump).
  * **Conditional Branches**: `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU` using 33-bit signed/unsigned subtraction sign/borrow bits.
  * **Memory Operations**: Byte/Halfword/Word loads and stores (`LB`, `LH`, `LW`, `LBU`, `LHU`, `SB`, `SH`, `SW`).
* **Hazard & Stall Unit**:
  * **Branch Hazard Suppression (`branch_stall`)**: 2-cycle stall handling (`wb_branch_i || wb_branch_nxt_i`) that suppresses invalid branch resolution to prevent spurious flushes.
  * **Register File Forwarding**: Read-After-Write (RAW) data hazard resolution directly from Writeback to Decode.
  * **Data Memory Byte-Level Forwarding**: RAW byte-level forwarding for same-cycle read-after-write operations.

---

## 📁 Repository Structure

```
3-Stage-Pipeline/
├── IF_ID_Stage/                  # Stage 1: Instruction Fetch & Decode
│   ├── IF_ID.v                   # Module implementation & Immediate Generator
│   ├── tb_IF_ID.v                # Stage 1 Testbench
│   ├── top_fpga.v                # FPGA Top Wrapper
│   ├── IF_ID_block_diagram.svg   # Hardware Block Diagram
│   └── bug.txt                   # Bug fixes and TODO log
│
├── execute/                      # Stage 2: Execute Unit & EX/MEM Pipeline Register
│   ├── execute.v                 # Module implementation, ALU Core & ex_mem_wb_reg
│   ├── tb_execute.v              # Stage 2 Testbench
│   ├── top_fpga_ex.v             # FPGA Top Wrapper
│   ├── execute_block_diagram.html# Interactive CAD Schematic Viewer (with pipeline.svg tab)
│   ├── execute_block_diagram.svg # Low-Level Gate & Wire Hardware Schematic
│   ├── pipeline.svg              # Full Pipeline Reference Diagram
│   ├── prepare.md                # Study Guide & 15 High-Yield Viva Q&As
│   └── bug.txt                   # Bug fixes and TODO log
│
├── memory/                       # Stage 3A: Instruction & Data Memory Modules
│   ├── memory.v                  # 4 KB Instruction Memory (IMEM) & Data Memory (DMEM)
│   ├── tb_mem.v                  # Memory Stage Testbench
│   ├── top_module.v              # FPGA Memory Top Wrapper
│   └── bug.txt                   # Bug fixes and TODO log
│
├── writeback/                    # Stage 3B: Writeback Stage & Byte Alignment
│   ├── wb.v                      # Module implementation & Load/Store Byte Aligners
│   ├── tb_wb.v                   # Writeback Stage Testbench
│   ├── top_fpga.v                # FPGA Writeback Top Wrapper
│   └── bug.txt                   # Bug fixes and TODO log
│
├── full_pipeline/                # Integrated Pipeline Core & FPGA Synthesis
│   ├── pipeline.v                # Top Pipeline Processor Module (pipe)
│   ├── tb_pipeline.v             # Full Pipeline Integration Testbench
│   ├── top_fpga.v                # FPGA Full Processor Top Wrapper
│   ├── constraint.xdc            # Xilinx Vivado Pin Constraints (Nexys A7)
│   ├── pipeline.svg              # Full Pipeline Hardware Schematic
│   └── bug.txt                   # Integrated Pipeline Bug & TODO log
│
└── Pipeline_via_terminal/        # Terminal Compilation & C Program Memory Generator
    ├── mem_generator/            # C Assembly Source Programs & RISC-V Toolchain Scripts
    ├── modules/                  # Modular Verilog source files
    └── simulation/               # Makefile simulation environment
```

---

## 🛠️ Simulation & Verification

### 1. Simulating Individual Pipeline Stages
Each stage includes a trace-driven Verilog testbench:
```bash
# Stage 1: IF/ID
cd IF_ID_Stage
iverilog -o sim_if_id IF_ID.v tb_IF_ID.v
vvp sim_if_id

# Stage 2: Execute
cd ../execute
iverilog -o sim_execute execute.v tb_execute.v
vvp sim_execute

# Stage 3A: Memory
cd ../memory
iverilog -o sim_memory memory.v tb_mem.v
vvp sim_memory

# Stage 3B: Writeback
cd ../writeback
iverilog -o sim_wb wb.v tb_wb.v
vvp sim_wb
```

### 2. Simulating the Integrated Full Pipeline CPU
```bash
cd full_pipeline
iverilog -o sim_pipeline pipeline.v tb_pipeline.v IF_ID.v execute.v wb.v memory.v
vvp sim_pipeline
```

### 3. Terminal Makefile Environment
```bash
cd Pipeline_via_terminal/simulation
make
```

---

## 💻 FPGA Synthesis & Vivado Deployment

1. Target FPGA Board: **Xilinx Nexys A7-100T** (Artix-7 XC7A100T-1CSG324C).
2. Constraints File: [`full_pipeline/constraint.xdc`](file:///Users/kamal/Desktop/CS2202L/3-Stage-Pipeline/full_pipeline/constraint.xdc).
3. Clocking: 100 MHz board oscillator divided to 1 Hz / user pulse clock using [`clock_divider`](file:///Users/kamal/Desktop/CS2202L/3-Stage-Pipeline/full_pipeline/top_fpga.v).
4. On-Board LED Output: Displays the lower 16 bits of the current Program Counter (`fetch_pc`) or destination register data.

---

## 📜 Documentation & Study Guides

* **Execute Stage Study Guide**: See [`execute/prepare.md`](file:///Users/kamal/Desktop/CS2202L/3-Stage-Pipeline/execute/prepare.md) for an in-depth breakdown of 33-bit subtractions, ALU operation decoding, shift masking, jump/branch target resolution, and 15 Viva Questions with answers.
* **Stage Bug Logs**: Check `bug.txt` inside each stage directory (`IF_ID_Stage/bug.txt`, `execute/bug.txt`, `memory/bug.txt`, `writeback/bug.txt`, `full_pipeline/bug.txt`).
