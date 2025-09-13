# 4-Stage-Pipelined-SIMD-Multimedia-Unit
## Objective
This project is designed as a learning experience for working with **VHDL/Verilog hardware description languages**. The goal is to implement a **four-stage pipelined multimedia unit** with a reduced set of multimedia instructions, using both structural and behavioral design principles.  

The design includes:
- An **assembler** that converts human-readable instructions into binary form.  
- **Buffers** for data transport between each pipeline stage.  
- A **register file** for housing 32 registers (128 bits wide each).  
- A **multimedia ALU** for executing instructions.  
- A **write-back stage** that updates the register file with results.  
- A **data forwarding unit** to improve pipeline efficiency and resolve hazards.  

The accompanying testbench scans input instruction files, executes them, and verifies the register outputs against expected results.

---

## Key Highlights
- Engineered a **4-stage pipelined processor** in VHDL with IF, ID, EXE, and WB stages, capable of executing up to **4 instructions per cycle with 0 stalls** using a custom-designed forwarding unit.  
- Implemented a **32×128-bit register file** with **3 read / 1 write operations per cycle**, integrated with a **Multimedia ALU** supporting **3-input, 128-bit instruction execution** using behavioral modeling.  
- Developed a **Python-based assembler** and custom testbench, achieving **100% functional verification** of a 64-instruction buffer and full pipeline operation with automated results logging.  

---

## Pipelined Multimedia ALU – Hierarchical RTL View

The unit comprises the following components:

- **Instruction Buffer** – preload instructions  
- **Program Counter (PC)** – track instruction addresses  
- **Pipeline Registers:** IF/ID, ID/EX, EX/WB  
- **Register File** – 32 registers, 128 bits wide  
- **SIMD ALU** – multimedia operations  
- **Forwarding Unit** – hazard resolution  
- **Output Register** – monitor the final pipeline output  

---

## Features
- Four-stage pipelined multimedia execution  
- Structural + behavioral RTL design  
- Data hazard resolution through forwarding  
- Testbench with automatic verification  
- Python assembler for instruction generation  
