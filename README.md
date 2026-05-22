# AXI4-Lite Slave Interface using Verilog HDL

## Project Overview
This project presents the design and verification of an AXI4-Lite Slave Interface using Verilog HDL. The design supports AXI4-Lite read and write transactions, interrupt generation, invalid address handling, and WSTRB-based byte-enable functionality.

The project was developed and verified using:
- Verilog HDL
- Icarus Verilog
- GTKWave
- Visual Studio Code

---

## Features
- AXI4-Lite Read Transactions
- AXI4-Lite Write Transactions
- FSM-Based Control Logic
- Interrupt Generation
- WSTRB Byte Enable Support
- Invalid Address Handling
- Directed Testbench Verification

---

## Tools Used
| Tool | Purpose |
|------|----------|
| Verilog HDL | RTL Design |
| Icarus Verilog | Simulation |
| GTKWave | Waveform Analysis |
| VS Code | Development Environment |

---

## Project Structure

```text
rtl/
   axi_lite_slave.v

tb/
   tb_axi_lite_slave.v

sim/
   axi_lite.vcd

docs/
   Project_Report.pdf
   Presentation.pptx
```

---

## Verification Results
The following tests were verified successfully:

- Write Transaction Test
- Read Transaction Test
- Invalid Address Test
- Interrupt Test
- WSTRB Functionality Test

Simulation Output:

```text
TEST PASSED
INVALID ADDRESS TEST PASSED
INTERRUPT ASSERT TEST PASSED
WSTRB TEST PASSED
```

---

## Waveform Verification
Waveform analysis was performed using GTKWave to verify:
- Clock and reset operation
- AXI handshaking
- Read/write timing
- Register updates
- Interrupt generation
- WSTRB functionality

---

## Applications
- FPGA Peripheral Interfaces
- SoC Communication
- Embedded Systems
- Register-Mapped Hardware Design

---

## Author
M. Sathvika

Department of Electronics and Communication Engineering

CMR Technical Campus
