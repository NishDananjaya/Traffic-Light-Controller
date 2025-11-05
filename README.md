# Smart Traffic Light Controller  
### *Adaptive 2-Way Traffic Management with Sensor-Driven Flow*  
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![SystemVerilog](https://img.shields.io/badge/Language-SystemVerilog-blue)](https://ieeexplore.ieee.org/document/7558047) [![FPGA Ready](https://img.shields.io/badge/FPGA-Ready-green)](#)


## Project Overview

This project implements a **smart, adaptive two-way traffic light controller** that:
- Prioritizes **main road (A)** by default.
- Grants **side road (B)** access **only when traffic is detected** (`traffic_B = 1`).
- Uses a **dynamic amber phase (3.5 seconds)** before switching.
- Is fully **synthesizable**, **resettable**, and **FPGA-ready**.

Perfect for **IoT edge devices**, **smart city prototypes**, or **digital systems labs**.

---

## Key Features

| Feature | Description |
|--------|-----------|
| **4-State FSM** | Clean, readable `enum` logic: `F0 → F1 → F2 → F3` |
| **Dynamic Amber Timer** | 3.5 sec = `70 × 50ms` + `5 × 10ms` using **parameterized down-counters** |
| **Sensor Input** | `traffic_B` triggers side road access |
| **Safe Transitions** | Amber phase **always** precedes red-to-green switch |
| **Reset Recovery** | Returns to safe default (A green, B red) on `rstn` |
| **Modular Design** | Separated `controll_logic`, `amber_timer`, and reusable `down_counter` |

---

## System Architecture

```
[top_module]
    ├── controll_logic (FSM + output decoder)
    └── amber_timer
         ├── down_counter #(.N(70))  → seconds
         └── down_counter #(.N(5))   → fine timing
```

---

## State Machine Diagram

```text
          traffic_B=1
       ┌───────◄───────┐
       │               │
F0 → F1 → F2 → F3 → F0
│    ▲     │     │
│    └─────┘     │ timer_done
│                │
└────────────────┘
   timer_done
```

| State | Road A | Road B | Amber Timer |
|-------|--------|--------|-------------|
| `F0`  | Green  | Red    | Off         |
| `F1`  | Amber  | Red    | On (3.5s)   |
| `F2`  | Red    | Green  | Off         |
| `F3`  | Red    | Amber  | On (3.5s)   |

---

## Module Breakdown

### `controll_logic`
- **Inputs**: `clk`, `rstn`, `traffic_B`, `timer_done`
- **Outputs**: All 6 traffic lights + `amber_timer_en`
- **FSM**: `enum {F0, F1, F2, F3}` with `always_comb` next-state logic

### `amber_timer`
- Chains two **parameterized down-counters**:
  - `N=70` → counts 50ms ticks → ~3.5 sec
  - `N=5` → fine-grained control
- Outputs: `timer_done`, `sec_counter_val`, `mili_sec_counter_val`

### `down_counter #(parameter N)`
- Generic, reusable **count-down timer**
- Auto-reloads to `N` when disabled
- Asserts `done` when count reaches 0

---

## Ports (Top-Level)

| Port | Type | Description |
|------|------|-----------|
| `clk` | input | System clock |
| `rstn` | input | Active-low reset |
| `traffic_B` | input | Sensor from Road B |
| `red/amber/green_light_A/B` | output | 3 lights per road |
| `sec_counter_val[7:0]` | output | Debug: seconds timer |
| `mili_sec_counter_val[3:0]` | output | Debug: fine timer |

---

## Simulation & Verification

- **Testbench**: `top_module_tb.sv`
- **Clock**: 100 MHz (`#5`)
- **Scenarios**:
  1. Normal flow with `traffic_B` toggling
  2. Extended traffic on Road B
  3. Mid-operation reset recovery
- **Waveforms**: Generate with `$dumpfile("waves.vcd")`

```systemverilog
$display("Time: %0t | State: %s | A: %b%b%b | B: %b%b%b",
         $time, dut.controll_logic.state.name(),
         dut.green_light_A, dut.amber_light_A, dut.red_light_A,
         dut.green_light_B, dut.amber_light_B, dut.red_light_B);
```

---

## FPGA Implementation (Suggested)

| Resource | Estimated |
|--------|----------|
| LUTs | ~120 |
| FFs  | ~40  |
| Clock | 100 MHz+ |

> Tested in **Xilinx Vivado**, **Intel Quartus**, **Lattice iCEcube2**

---

## File Structure

```
├── top_module.sv           → Top-level integration
├── controll_logic.sv       → FSM + light control
├── amber_timer.sv          → Timer chain
├── down_counter.sv         → Parameterized counter
├── top_module_tb.sv        → Comprehensive testbench
└── waves.vcd               → (generated) waveform
```

---

## How to Run

```bash
# Using Vivado
xelab top_module_tb -sv -R

# Using Verilator
verilator -Wall --cc top_module.sv --exe top_module_tb.sv
make -j -C obj_dir -f Vtop_module.mk Vtop_module
./obj_dir/Vtop_module
```

---

## Author

**[Nishan Dananjaya]** – Digital Systems | Embedded Logic | FPGA Enthusiast

---

## License

```
MIT License © 2025
```

See [`LICENSE`](LICENSE) for full details.

---

> **"From blinking LEDs to thinking intersections — one FSM at a time."**  
> **Star this repo if you're into smart embedded systems!**

---

### Suggested GitHub Repo Name:
```
smart-traffic-light-sv
```

Let me know your **GitHub username**, and I’ll generate a **ready-to-push version** with live links!