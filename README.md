# Verification of an Asynchronous FIFO using SystemVerilog

A class-based SystemVerilog verification environment and SVA checker for a
32-bit, 16-deep asynchronous FIFO with independent write and read clocks.
Simulated with QuestaSim.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Design Under Test](#2-design-under-test)
3. [Verification Environment](#3-verification-environment)
4. [Assertions (SVA)](#4-assertions-sva)
5. [Test Scenarios](#5-test-scenarios)
6. [Coverage](#6-coverage)
7. [Project Structure](#7-project-structure)
8. [How to Run](#8-how-to-run)
9. [Viewing Assertion Results](#9-viewing-assertion-results)
10. [Results](#10-results)
11. [Observations and Known Limitations](#11-observations-and-known-limitations)
12. [Tools](#12-tools)

---

## 1. Overview

The goal of this project is to verify that an asynchronous FIFO correctly
transfers data between two unrelated clock domains and that its status flags
(`full_o`, `empty_o`, `overflow_o`, `underflow_o`) behave correctly in every
situation, including boundary and error cases.

Verification is done with three complementary techniques:

| Technique | Purpose |
|---|---|
| Layered testbench with scoreboard | Checks that data read out matches data written in, in order |
| Functional and code coverage | Shows that all important scenarios were actually exercised |
| SystemVerilog Assertions (SVA) | Continuously checks flag and pointer behaviour during simulation |

---

## 2. Design Under Test

**File:** `async_fifo.v`

### Configuration

The design is configured with three macros, which must be defined before
compilation:

| Macro | Value used | Meaning |
|---|---|---|
| `` `DATA_WIDTH `` | 32 | Width of a data word |
| `` `DEPTH `` | 16 | Number of words stored |
| `` `PTR_WIDTH `` | 4 | Width of the read and write pointers |

### Ports

| Port | Direction | Clock domain | Description |
|---|---|---|---|
| `wr_clk_i` | input | - | Write clock |
| `rd_clk_i` | input | - | Read clock |
| `rst_i` | input | async | Active-low reset, shared by both domains |
| `wr_en_i` | input | write | Write request |
| `rd_en_i` | input | read | Read request |
| `wdata_i` | input | write | Write data |
| `rdata_o` | output | read | Read data (registered) |
| `full_o` | output | write | FIFO is full |
| `empty_o` | output | read | FIFO is empty |
| `overflow_o` | output | write | One-cycle pulse: write attempted while full |
| `underflow_o` | output | read | One-cycle pulse: read attempted while empty |

### How it works

- **Storage:** a 16-entry memory `fifo[0:DEPTH-1]`.
- **Pointers:** each side has a binary pointer (`wr_pntr`, `rd_pntr`) that
  counts from 0 to `DEPTH-1` and wraps back to 0.
- **Toggle bits:** `wr_toggle` and `rd_toggle` flip every time their pointer
  wraps. They tell "pointers equal because empty" apart from "pointers equal
  because full".
- **Synchronization:** each pointer and toggle bit is copied into the other
  clock domain with one flip-flop (`rd_pntr_wr_clk`, `rd_toggle_wr_clk`,
  `wr_pntr_rd_clk`, `wr_toggle_rd_clk`).
- **Flags:**
  - `full_o`  = (`wr_pntr == rd_pntr_wr_clk`) and (`wr_toggle != rd_toggle_wr_clk`)
  - `empty_o` = (`wr_pntr_rd_clk == rd_pntr`) and (`wr_toggle_rd_clk == rd_toggle`)
- **Rejected accesses:** a write while full, or a read while empty, is ignored
  (no pointer movement, no data change) and raises `overflow_o` or
  `underflow_o` for one cycle.

Because each side sees the other side's pointer a little late, a flag can
clear late but must never fail to set. This is the core safety idea behind the
full and empty checks.

---

## 3. Verification Environment

A layered, class-based SystemVerilog testbench in the style of UVM:

```
                +-----------+
                |   Test    |
                +-----+-----+
                      |
                +-----v-----+
                |Environment|
                +-----+-----+
     +----------+-----+-----+------------+
     |          |           |            |
+----v----+ +---v---+  +----v----+  +----v------+
|Generator| |  BFM  |  | Monitor |  | Scoreboard|
+---------+ +---+---+  +----+----+  +-----------+
                |           |
            +---v-----------v---+
            |     Interface     |  (clocking blocks)
            +---------+---------+
                      |
                +-----v-----+       +-----------------+
                |  async_   |<------|   SVA checker   |
                |   fifo    | bind  | (fifo_checks)   |
                +-----------+       +-----------------+
```

| Component | Role |
|---|---|
| Generator | Creates the write and read stimulus |
| BFM (driver) | Drives the stimulus onto the DUT interface |
| Monitor | Observes DUT inputs and outputs and passes them on |
| Scoreboard | Compares data read out against the expected data written in |
| Coverage | Separate write-domain and read-domain covergroups |
| Interface | Groups the DUT signals and uses clocking blocks to avoid races between the BFM, the monitor and the DUT |
| SVA checker | Bound to the DUT to check flags and pointers |

A race condition between the BFM and the monitor was fixed by adding a
clocking block to the interface, which stabilised scoreboard synchronisation.

---

## 4. Assertions (SVA)

**File:** `fifo_checks.sv`

The assertions live in a separate checker module that is attached to the DUT
with `bind`. This lets them see the DUT's internal pointer and toggle
registers without changing the RTL.

```systemverilog
bind async_fifo fifo_checks u_fifo_checks ( /* port connections */ );
```

All checks are disabled during reset with `disable iff (!rst_i)`, except the
checks on the reset behaviour itself.

| Label | Clock | Rule |
|---|---|---|
| `a_full` | `wr_clk_i` | If `wr_pntr == rd_pntr_wr_clk` and the toggle bits differ, then `full_o` must be 1 |
| `a_overflow` | `wr_clk_i` | A write while `full_o` is 1 must raise `overflow_o` on the next cycle |
| `a_empty` | `rd_clk_i` | If `rd_pntr == wr_pntr_rd_clk` and the toggle bits are equal, then `empty_o` must be 1 |
| `a_underflow` | `rd_clk_i` | A read while `empty_o` is 1 must raise `underflow_o` on the next cycle |
| `wr_en_a` | `wr_clk_i` | `wr_en_i` must be low while `rst_i` is low |
| `rd_en_a` | `rd_clk_i` | `rd_en_i` must be low while `rst_i` is low |
| `wdata_a` | `wr_clk_i` | `wdata_i` must not contain X or Z when `wr_en_i` is high |
| `rdata_a` | `rd_clk_i` | `rdata_o` must not contain X or Z on the cycle after `rd_en_i` is high |

### Notes on how assertions behave

- **One-cycle shift.** Assertions read signals as they were just before the
  clock edge, so a check can appear one edge after the signal change in the
  waveform. Checks written with `|=>` add one more cycle by design.
- **Passing is not the same as tested.** With `A |-> B`, an assertion passes
  without checking anything when `A` never happens. Always look at the pass
  count in the Assertions window to see that each check was exercised.

---

## 5. Test Scenarios

| Scenario | What it checks |
|---|---|
| Reset | All pointers, flags and outputs return to their reset values |
| Write until FULL | `full_o` is set at the right moment |
| Read until EMPTY | `empty_o` is set at the right moment |
| OVERFLOW | A write while full is ignored and `overflow_o` pulses |
| UNDERFLOW | A read while empty is ignored and `underflow_o` pulses |
| Concurrent read and write | Both sides active at the same time with data integrity |
| Pointer wrap-around | Pointers and toggle bits wrap correctly past `DEPTH-1` |
| Different clock ratios | Behaviour when the write and read clocks run at different speeds |

> Adjust this table to match the test list in your testbench.

---

## 6. Coverage

- **Functional coverage:** separate covergroups for the write domain and the
  read domain.
- **Code coverage:** statement, branch, condition, expression, FSM and toggle,
  enabled with `+cover=fcbest`.
- **Assertion coverage:** pass and fail counts per assertion, enabled with
  `-assertdebug`.

The coverage database is saved on exit to `UNDERFLOW.ucdb` (see the run
script). Reported result: 100% functional and 100% code coverage.

---

## 7. Project Structure

> This is a suggested layout. Rename the entries to match your actual files.

```
async_fifo_verification/
|-- rtl/
|   `-- async_fifo.v          # Design under test
|-- tb/
|   |-- interface             # Interface with clocking blocks
|   |-- generator             # Stimulus generation
|   |-- bfm                   # Driver
|   |-- monitor               # Monitor
|   |-- scoreboard            # Data checking
|   |-- coverage              # Covergroups
|   |-- environment           # Environment and test classes
|   `-- top                   # Top module: clocks, reset, DUT instance
|-- sva/
|   `-- fifo_checks.sv        # Assertions and bind
|-- sim/
|   |-- list.svh              # File list for compilation
|   |-- wave.do               # Waveform setup
|   `-- run.do                # Simulation script
`-- README.md
```

---

## 8. How to Run

### Prerequisites

- QuestaSim (or ModelSim with SystemVerilog and assertion support)
- `` `DATA_WIDTH ``, `` `DEPTH `` and `` `PTR_WIDTH `` defined before the DUT is compiled
- `fifo_checks.sv` included in `list.svh`

### Steps

```tcl
vlog -f list.svh
vopt +acc +cover=fcbest top -o UNDERFLOW
vsim -coverage -assertdebug UNDERFLOW -l fifo.log
coverage save -onexit UNDERFLOW.ucdb

do wave.do

add wave /top/dut/u_fifo_checks/a_full
add wave /top/dut/u_fifo_checks/a_overflow
add wave /top/dut/u_fifo_checks/a_empty
add wave /top/dut/u_fifo_checks/a_underflow
add wave /top/dut/u_fifo_checks/wr_en_a
add wave /top/dut/u_fifo_checks/rd_en_a
add wave /top/dut/u_fifo_checks/wdata_a
add wave /top/dut/u_fifo_checks/rdata_a

run -all
```

Points that matter:

1. `+acc` goes on `vopt`. Without it, internal signals and assertions can be
   optimised away.
2. The `add wave` commands must come **before** `run -all`, otherwise the
   waveform has no history.
3. If an `add wave` path fails, find the real path with
   `find instances -r /top/*u_fifo_checks*`.

### Running a regression

Run each test with its own database name, then merge them:

```tcl
vcover merge merged.ucdb test1.ucdb test2.ucdb
vcover report -details merged.ucdb
```

---

## 9. Viewing Assertion Results

- **Waveform:** assertions appear as rows. Markers show where each check
  started and passed or failed. Hover over a marker to see its meaning in your
  version of Questa.
- **Assertions window:** *View > Coverage > Assertions* shows the failure
  count, pass count and active count of each assertion.
- **Log file:** failures also print in `fifo.log` with the assertion name and
  time.

Typical sign-off practice: the **summary and log** decide pass or fail, and the
**waveform** is used only to debug a failure.

---

## 10. Results

From the Assertions window of the recorded run:

| Assertion | Failures | Passes |
|---|---|---|
| `a_full` | 0 | 3 |
| `a_overflow` | 0 | 0 |
| `a_empty` | 0 | 446 |
| `a_underflow` | 0 | 1 |
| `wr_en_a` | 0 | 2 |
| `rd_en_a` | 0 | 1 |
| `wdata_a` | 0 | 16 |
| `rdata_a` | 0 | 17 |

- No assertion failed in this run.
- `a_overflow` has **0 passes**, so the overflow case was not exercised in
  this run. A test that keeps writing after `full_o` goes high is needed.
- `a_full`, `a_underflow` and the reset checks have low pass counts. Longer
  runs with repeated fill and drain would give more confidence.

> Update this table after each new run.

---

## 11. Observations and Known Limitations

### Design observations

1. **Binary pointers cross clock domains through a single flip-flop.** In real
   hardware several bits can change at the same time, so the other domain may
   capture a wrong value. Zero-delay simulation will not show this, and these
   assertions will not catch it. The usual fix is Gray-coded pointers with a
   two-flop synchronizer, followed by a CDC analysis tool.
2. **One reset for both domains, with an unsynchronized release.** Reset
   release should be synchronized into each clock domain separately.
3. **`full_o` and `empty_o` are combinational** (`always @(*)`) and use
   nonblocking assignments. This works in simulation but is unusual style.

### Verification limitations

- Assertions compare the flags against the **synchronized** pointers, so they
  validate the flag logic, not the clock-domain crossing itself.
- Simulation does not model metastability.
- Cross-domain checks can show delta-cycle races if both clocks have
  coincident edges. Use clocking blocks to avoid false failures.

### Possible future work

- Add the overflow stimulus and re-run until every assertion has a non-zero
  pass count.
- Add `cover property` statements for full, empty, wrap-around and back-to-back
  full and empty.
- Add a data-integrity scoreboard check inside the SVA module.
- Convert the pointers to Gray code and re-verify.
- Port the environment to full UVM.

---

## 12. Tools

| Tool | Use |
|---|---|
| QuestaSim | Compilation, simulation, coverage, assertion debug |
| Verilog | RTL design |
| SystemVerilog | Testbench, coverage and assertions |

---

## Author

Navyashree Ramprasad
Design Verification Engineer
[linkedin.com/in/navyashreeramprasad](https://www.linkedin.com/in/navyashreeramprasad/) | [github.com/NavyashreeRamprasad](https://github.com/NavyashreeRamprasad)
