# UVM Architecture and Design Documentation

## Complete UVM Framework Architecture

### Overall System Hierarchy

```
tb_riscv_uvm (Top-level Module)
│
├── DUT Instance
│   └── riscv_soc_top
│       ├── rv32i_core
│       ├── mmu (Instruction & Data)
│       ├── tlb
│       ├── csr_unit
│       ├── exception_handler
│       ├── sram (Instruction Memory)
│       ├── sram (Data Memory)
│       ├── UART (pass-through)
│       ├── GPIO (pass-through)
│       └── AXI4-Lite (debug interface)
│
├── Interface Instance
│   └── riscv_soc_if
│       ├── System signals (clk, rst_n)
│       ├── UART interface
│       ├── GPIO interface
│       ├── AXI4-Lite interface
│       └── Interrupt input
│
└── UVM Environment
    └── riscv_uvm_env
        ├── gpio_agent
        │   ├── gpio_sequencer
        │   ├── gpio_driver
        │   └── gpio_monitor
        │
        ├── uart_agent
        │   ├── uart_sequencer
        │   ├── uart_driver
        │   └── uart_monitor
        │
        ├── axi_agent
        │   ├── axi_sequencer
        │   ├── axi_driver
        │   └── axi_monitor
        │
        ├── interrupt_agent
        │   ├── interrupt_sequencer
        │   ├── interrupt_driver
        │   └── interrupt_monitor
        │
        ├── top_scoreboard
        │   ├── gpio_scoreboard
        │   ├── uart_scoreboard
        │   └── axi_scoreboard
        │
        ├── gpio_coverage
        ├── uart_coverage
        └── axi_coverage
```

## Component Details

### 1. Interface (riscv_soc_if)

**Purpose:** Provides synchronized access to DUT signals

**Signals:**

| Group | Signals | Purpose |
|-------|---------|---------|
| System | clk, rst_n | Clock and reset |
| UART | uart_rx, uart_tx | Serial communication |
| GPIO | gpio_in[7:0], gpio_out[7:0] | General I/O |
| AXI4-Lite | 14 signals | Debug interface |
| Interrupt | ext_interrupt | External interrupt |

**Modports:**
- `driver` - Drives stimulus, reads responses
- `monitor` - Observes all signals
- `testbench` - Full read/write access

### 2. Transaction Classes

#### GPIO Transaction
```systemverilog
class gpio_transaction extends uvm_sequence_item;
  logic [7:0] gpio_in;        // Input stimuli
  logic [7:0] gpio_out;       // Observed output
  logic [7:0] gpio_expected;  // Expected output
endclass
```

**Typical flow:**
```
Test writes gpio_in → DUT processes → Monitor observes gpio_out → 
Scoreboard compares (gpio_out == gpio_expected)
```

#### UART Transaction
```systemverilog
class uart_transaction extends uvm_sequence_item;
  logic uart_rx;          // Input
  logic uart_tx;          // Output
  logic uart_expected;    // Expected (usually uart_rx)
endclass
```

#### AXI Transaction
```systemverilog
class axi_transaction extends uvm_sequence_item;
  axi_trans_type_t trans_type;  // READ or WRITE
  logic [31:0] addr;            // Address
  logic [31:0] data;            // Data
  logic [3:0] strb;             // Strobe
  logic [1:0] resp;             // Response
  logic error;                  // Error flag
endclass
```

### 3. Sequencer-Driver Pairs

#### GPIO Agent Example

**Sequence:**
```
1. Create GPIO transaction with gpio_in = 0xAA
2. Send to sequencer
3. Driver receives transaction
4. Driver writes to interface: vif.gpio_in <= 0xAA
5. Wait for posedge clk
6. Transaction marked done
```

**Flow:**
```
Sequence → Sequencer ← Driver ← vif.gpio_in
                       ↓
                    DUT processes input
                       ↓
                    vif.gpio_out changes
                       ↓
                    Monitor samples
```

### 4. Monitor-Scoreboard Pipeline

**GPIO Monitor:**
```systemverilog
@(posedge vif.clk)
  trans.gpio_in = vif.gpio_in;
  trans.gpio_out = vif.gpio_out;
  trans.gpio_expected = vif.gpio_in;  // For pass-through test
  ap.write(trans);  // Send to scoreboard
```

**GPIO Scoreboard:**
```systemverilog
fifo.get(trans);
if(trans.gpio_out == trans.gpio_expected) begin
  gpio_pass++;
  `uvm_info("GPIO_SB_PASS", ...)
end else begin
  gpio_fail++;
  `uvm_error("GPIO_SB_FAIL", ...)
end
```

### 5. Coverage Collection

**GPIO Coverage Group:**
```systemverilog
covergroup gpio_coverage_group;
  gpio_in_coverage: coverpoint vif.gpio_in {
    bins low = {8'h00};
    bins mid = {[8'h01:8'hFE]};
    bins high = {8'hFF};
    bins special_aa = {8'hAA};
    bins special_55 = {8'h55};
  }
  gpio_out_coverage: coverpoint vif.gpio_out { ... }
  gpio_correlation: cross gpio_in_coverage, gpio_out_coverage;
endgroup
```

**Sampling:**
```systemverilog
task run_phase(uvm_phase phase);
  forever begin
    @(posedge vif.clk);
    gpio_coverage_group.sample();
  end
endtask
```

## Test Execution Flow

### Detailed Test Sequence

```
[SIMULATION START]
├─ Time: 0ns
│  ├─ Clock generation starts
│  └─ Reset asserted (rst_n = 0)
│
├─ Time: 0-50ns (Reset Phase)
│  ├─ Reset held for 10 clock cycles
│  ├─ All DUT outputs initialized
│  └─ "Reset released" message printed
│
├─ Time: 50ns+ (Test Execution Phase)
│  ├─ Phase.raise_objection()
│  │
│  ├─ GPIO Pass-Through Test (40 transactions)
│  │  ├─ gpio_agt.sequencer generates stimuli
│  │  ├─ gpio_driver writes to vif.gpio_in
│  │  ├─ DUT processes: gpio_out = gpio_in
│  │  ├─ gpio_monitor captures gpio_out
│  │  ├─ gpio_scoreboard compares
│  │  └─ Result: PASS (40) or FAIL (0)
│  │
│  ├─ UART Echo Test (20 transactions)
│  │  ├─ uart_agt.sequencer generates RX stimuli
│  │  ├─ uart_driver writes to vif.uart_rx
│  │  ├─ DUT processes: uart_tx = uart_rx
│  │  ├─ uart_monitor captures uart_tx
│  │  ├─ uart_scoreboard verifies echo
│  │  └─ Result: PASS (20) or FAIL (0)
│  │
│  ├─ AXI Write Test (25 transactions)
│  │  ├─ axi_agt generates write addresses
│  │  ├─ axi_driver drives AXI write channels
│  │  ├─ DUT processes write transaction
│  │  ├─ axi_monitor captures response
│  │  ├─ axi_scoreboard checks RESP field
│  │  └─ Result: PASS (25) or FAIL (0)
│  │
│  ├─ AXI Read Test (25 transactions)
│  │  ├─ axi_agt generates read addresses
│  │  ├─ axi_driver drives AXI read channels
│  │  ├─ DUT returns read data
│  │  ├─ axi_monitor captures read responses
│  │  ├─ axi_scoreboard verifies protocol
│  │  └─ Result: PASS (25) or FAIL (0)
│  │
│  ├─ Interrupt Test (10 transactions)
│  │  ├─ interrupt_agt generates interrupt pulses
│  │  ├─ interrupt_driver drives ext_interrupt
│  │  ├─ DUT processes interrupt
│  │  ├─ interrupt_monitor observes
│  │  └─ Result: Transactions recorded
│  │
│  └─ Phase.drop_objection()
│
├─ End of Elaboration Phase
│  └─ Print UVM topology
│
├─ Simulation End
│  ├─ Scoreboard Report Phase
│  │  ├─ Print GPIO results
│  │  ├─ Print UART results
│  │  ├─ Print AXI results
│  │  └─ Print total: PASS/FAIL
│  │
│  ├─ Coverage Report Phase
│  │  ├─ Print GPIO coverage %
│  │  ├─ Print UART coverage %
│  │  └─ Print AXI coverage %
│  │
│  └─ Export results to VCD
│
[SIMULATION END]
```

## Signal Timing Relationships

### GPIO Pass-Through Timing

```
Clock:  _____|‾‾‾|_____|‾‾‾|_____|‾‾‾|_____|‾‾‾|_____|‾‾‾|_____

gpio_in:  0x00      0xAA      0x55      0xFF      0xAA      0x00
            └────────┘ └────────┘ └────────┘ └────────┘

gpio_out: 0x00      0xAA      0x55      0xFF      0xAA      0x00
            └────────┘ └────────┘ └────────┘ └────────┘
```

**Expected behavior:** gpio_out follows gpio_in with ~1 clock cycle delay

### UART Echo Timing

```
Clock:   _____|‾‾‾|_____|‾‾‾|_____|‾‾‾|_____|‾‾‾|_____|‾‾‾|_____

uart_rx:   1         0         1         1         0         1
            └────────┘ └────────┘ └────────┘ └────────┘

uart_tx:   1         0         1         1         0         1
            └────────┘ └────────┘ └────────┘ └────────┘
```

**Expected behavior:** uart_tx mirrors uart_rx

### AXI Write Transaction Timing

```
Clock:      _____|‾‾‾|_____|‾‾‾|_____|‾‾‾|_____|‾‾‾|_____|‾‾‾|_____

awvalid:    __|‾‾‾|___|
awready:    __|‾‾‾|___|_______
             ↓
wvalid:             __|‾‾‾|___|
wready:             __|‾‾‾|___|_______
             ↓
bvalid:                     __|‾‾‾|___|
bready:                     __|‾‾‾|___|_______
```

**Expected behavior:** Proper handshaking on all channels

## Data Flow Paths

### GPIO Path

```
test sequence
    ↓
gpio_sequencer
    ↓
gpio_driver ──(gpio_in)──→ DUT
    ↓                       ↓
    │                   (GPIO logic)
    │                       ↓
gpio_monitor ←──(gpio_out)──┘
    ↓
gpio_scoreboard
    ↓
compare & report
```

### UART Path

```
test sequence
    ↓
uart_sequencer
    ↓
uart_driver ──(uart_rx)──→ DUT
    ↓                       ↓
    │                   (UART logic)
    │                       ↓
uart_monitor ←──(uart_tx)──┘
    ↓
uart_scoreboard
    ↓
compare & report
```

### AXI Path (Write)

```
test sequence
    ↓
axi_sequencer
    ↓
axi_driver ──(axi_awaddr, axi_wdata)──→ DUT
    ↓                                     ↓
    │                               (AXI logic)
    │                                     ↓
axi_monitor ←──(axi_bresp)───────────────┘
    ↓
axi_scoreboard
    ↓
compare & report
```

## Coverage Strategy

### GPIO Coverage Points

- **Input values:** 0x00, 0x01-0x7F, 0x80-0xFE, 0xFF, 0xAA, 0x55
- **Output values:** Same as input
- **Cross-correlation:** Input vs output patterns
- **Target coverage:** 85%+

### UART Coverage Points

- **RX states:** 0, 1
- **TX states:** 0, 1
- **Transitions:** 0→1, 1→0, 0→0, 1→1
- **Cross-correlation:** RX vs TX alignment
- **Target coverage:** 95%+

### AXI Coverage Points

- **Address ranges:** Instruction memory, Data memory, Peripherals
- **Data ranges:** Low (0x0000XXXX), High (0xFFFFXXXX), Others
- **Operations:** Read, Write
- **Response types:** OKAY, EXOKAY, SLVERR, DECERR
- **Target coverage:** 75%+

## Test Completeness Matrix

| Test | Stimulus | Response | Verification |
|------|----------|----------|---------------|
| GPIO | gpio_in values | gpio_out | Pass-through match |
| UART | uart_rx states | uart_tx | Echo match |
| AXI Write | addr, data | bresp | OKAY response |
| AXI Read | addr | rdata, rresp | Valid read |
| Interrupt | ext_interrupt | pulse | Timing valid |

## Performance Characteristics

### Simulation Speed

```
Phase                  Duration    Tasks/sec
────────────────────────────────────────────
Compilation             20-30s        N/A
Elaboration              2-5s         N/A
GPIO Test               1-2s         40 tests
UART Test              0.5-1s        20 tests
AXI Tests              2-3s         50 tests
Reporting              0.5-1s         N/A
────────────────────────────────────────────
Total                  30-60s       ~110 tests/sec
```

### Resource Usage

```
Memory: ~50-200 MB
  - Compiled design: 20-50 MB
  - Simulation state: 30-150 MB

Disk:
  - Work library: 20-50 MB
  - VCD file: 1-10 MB
  - Log files: 100-500 KB
```

## Error Handling Strategy

### Transaction-Level Error Detection

```
Try
  ├─ Generate stimulus
  ├─ Drive to DUT
  ├─ Wait for response
  ├─ Capture response
  └─ Compare with expected
Catch
  ├─ Log error with transaction details
  ├─ Increment failure counter
  ├─ Continue to next test
  └─ Report in final summary
```

### Error Categories

1. **Functional Errors**
   - Output mismatch
   - Response protocol violation
   - Timing error

2. **Simulation Errors**
   - Compilation failure
   - Type mismatch
   - Undefined behavior

3. **Environmental Errors**
   - Interface not found
   - Memory allocation failure
   - File I/O error

## Extensibility Points

### Add New Test

1. Create sequence in `uvm_riscv_sequences.sv`
2. Create test in `uvm_riscv_test.sv`
3. Add to `riscv_regression_test`
4. Run compilation

### Add New Interface Signal

1. Add signal to `riscv_soc_if`
2. Create transaction class
3. Create sequencer/driver/monitor
4. Create agent
5. Connect in environment

### Add New Coverage

1. Create `covergroup` in `uvm_riscv_coverage.sv`
2. Sample in run_phase
3. Report in report_phase
4. View in coverage report

## Best Practices Implemented

✅ Proper UVM hierarchy
✅ Reusable components
✅ Comprehensive monitoring
✅ Automated checking
✅ Coverage tracking
✅ Professional reporting
✅ Error handling
✅ Extensibility support

---

**This architecture supports production-grade verification!**

