# UVM Verification Testing Guide

## Complete Testing Methodology

### Test Architecture

```
Test Suite (riscv_regression_test)
├── GPIO Pass-Through Test
│   ├── Setup phase
│   ├── Run phase
│   │   ├── Generate GPIO stimuli
│   │   ├── Drive GPIO inputs
│   │   ├── Monitor GPIO outputs
│   │   ├── Compare with expected
│   │   └── Record pass/fail
│   └── Report phase (40 tests total)
│
├── UART Echo Test
│   ├── Generate UART stimuli
│   ├── Drive RX line
│   ├── Verify TX echoes RX
│   └── Report results (20 tests total)
│
├── AXI Write Test
│   ├── Generate write addresses
│   ├── Drive write data
│   ├── Verify ready/valid handshakes
│   └── Report results (25 tests total)
│
├── AXI Read Test
│   ├── Generate read addresses
│   ├── Drive read requests
│   ├── Verify read responses
│   └── Report results (25 tests total)
│
└── Interrupt Test
    ├── Generate interrupt pulse
    ├── Drive ext_interrupt
    ├── Monitor timing
    └── Report results (10 tests total)
```

## Running Individual Tests

### 1. GPIO Pass-Through Test Only

**Linux/Mac:**
```bash
vsim -batch -do "vsim -f filelist.txt tb_riscv_uvm +UVM_TESTNAME=gpio_passthrough_test" -l gpio_test.log
```

**Windows (using batch with modification):**
Edit `run_uvm_tests.bat` to comment out other tests, then run

**Expected Output:**
```
GPIO_SB_PASS: PASS: IN=0x01 OUT=0x01
GPIO_SB_PASS: PASS: IN=0x02 OUT=0x02
GPIO_SB_PASS: PASS: IN=0x04 OUT=0x04
...
GPIO_SB_REPORT: GPIO Results - PASS: 40 FAIL: 0
```

### 2. UART Echo Test Only

```bash
vsim -batch -do "vsim -f filelist.txt tb_riscv_uvm +UVM_TESTNAME=uart_echo_test" -l uart_test.log
```

**Expected Output:**
```
UART_SB_PASS: PASS: RX=0 TX=0
UART_SB_PASS: PASS: RX=1 TX=1
...
UART_SB_REPORT: UART Results - PASS: 20 FAIL: 0
```

### 3. AXI Write Test Only

```bash
vsim -batch -do "vsim -f filelist.txt tb_riscv_uvm +UVM_TESTNAME=axi_write_test" -l axi_write_test.log
```

**Expected Output:**
```
AXI_SB_PASS: PASS: ADDR=0x80000100 DATA=0xABCD1234 RESP=00
AXI_SB_PASS: PASS: ADDR=0x80000104 DATA=0xDEADBEEF RESP=00
...
AXI_SB_REPORT: AXI Results - PASS: 25 FAIL: 0
```

### 4. AXI Read Test Only

```bash
vsim -batch -do "vsim -f filelist.txt tb_riscv_uvm +UVM_TESTNAME=axi_read_test" -l axi_read_test.log
```

**Expected Output:**
```
AXI_SB_PASS: PASS: ADDR=0x00000000 DATA=0x00000000 RESP=00
AXI_SB_PASS: PASS: ADDR=0x00000004 DATA=0xDEADBEEF RESP=00
...
AXI_SB_REPORT: AXI Results - PASS: 25 FAIL: 0
```

### 5. Interrupt Test Only

```bash
vsim -batch -do "vsim -f filelist.txt tb_riscv_uvm +UVM_TESTNAME=interrupt_test" -l interrupt_test.log
```

## Creating Custom Tests

### Example: Add Memory Burst Test

**Step 1: Create new sequence in `uvm_riscv_sequences.sv`:**

```systemverilog
class axi_burst_sequence extends uvm_sequence #(axi_transaction);
  `uvm_object_utils(axi_burst_sequence)
  
  function new(string name = "axi_burst_sequence");
    super.new(name);
  endfunction
  
  task body();
    axi_transaction trans;
    logic [31:0] base_addr = 32'h80000000;
    
    `uvm_info("AXI_BURST_SEQ", "Starting burst sequence", UVM_MEDIUM)
    
    // Write burst of 16 transactions
    repeat(16) begin
      trans = axi_transaction::type_id::create("trans");
      assert(trans.randomize() with {
        trans_type == AXI_WRITE;
        addr == base_addr + (local::$counter << 2);
        data != '0;
      }) else `uvm_error("AXI_BURST_SEQ", "Randomization failed")
      start_item(trans);
      finish_item(trans);
      @(posedge m_sequencer.vif.clk);
    end
    
    `uvm_info("AXI_BURST_SEQ", "Burst sequence completed", UVM_MEDIUM)
  endtask
  
endclass
```

**Step 2: Create test class in `uvm_riscv_test.sv`:**

```systemverilog
class axi_burst_test extends riscv_uvm_base_test;
  `uvm_component_utils(axi_burst_test)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    axi_burst_sequence seq;
    
    phase.raise_objection(this);
    
    `uvm_info("AXI_BURST_TEST", "AXI Burst Test Starting", UVM_LOW)
    
    seq = axi_burst_sequence::type_id::create("seq");
    seq.start(env.axi_agt.sequencer);
    
    repeat(100) @(posedge vif.clk);
    
    `uvm_info("AXI_BURST_TEST", "AXI Burst Test Completed", UVM_LOW)
    
    phase.drop_objection(this);
  endtask
  
endclass
```

**Step 3: Run with the new test:**

```bash
vsim -batch -do "vsim -f filelist.txt tb_riscv_uvm +UVM_TESTNAME=axi_burst_test" -l burst_test.log
```

## Coverage Analysis

### View Coverage After Test

```bash
# Extract coverage information from simulation
grep "Coverage = " reports/uvm_simulation.log
```

**Expected Coverage Output:**
```
GPIO Coverage = 85.50%
UART Coverage = 100.00%
AXI Coverage = 72.30%
```

### Improve Coverage

**1. Add more stimulus patterns:**

```systemverilog
// In sequences
repeat(100) begin  // Increase from 10 to 100
  trans = gpio_transaction::type_id::create("trans");
  assert(trans.randomize()) else `uvm_error("", "Randomization failed")
  start_item(trans);
  finish_item(trans);
  @(posedge m_sequencer.vif.clk);
end
```

**2. Target specific patterns:**

```systemverilog
// Cover all combinations
for(int i = 0; i < 256; i++) begin
  trans = gpio_transaction::type_id::create("trans");
  trans.gpio_in = i[7:0];
  trans.gpio_expected = i[7:0];
  start_item(trans);
  finish_item(trans);
  @(posedge m_sequencer.vif.clk);
end
```

## Debugging Failed Tests

### Step 1: Check Log for Error

```bash
grep -A 5 "ERROR\|FAIL" reports/uvm_simulation.log
```

### Step 2: Find Failing Transaction

```bash
grep "GPIO_SB_FAIL" reports/uvm_simulation.log
```

**Example failure:**
```
GPIO_SB_FAIL: FAIL: IN=0x55 OUT=0xAA EXP=0x55
```

This means: GPIO input was 0x55, but output was 0xAA instead of expected 0x55

### Step 3: Examine Waveform

```bash
gtkwave reports/riscv_uvm.vcd
```

Look for:
- gpio_in and gpio_out signals
- Check timing relationships
- Verify handshake signals

### Step 4: Modify Test to Isolate Issue

```systemverilog
// Debug version - single specific pattern
trans = gpio_transaction::type_id::create("trans");
trans.gpio_in = 8'h55;  // Specific failing pattern
trans.gpio_expected = 8'h55;
start_item(trans);
finish_item(trans);
repeat(10) @(posedge m_sequencer.vif.clk);  // Hold longer
```

## Performance Testing

### Measure Simulation Speed

```bash
# Before test
echo "Start: $(date +%s%N)" > perf.log

# Run test
vsim -batch -do compile_and_run_uvm.do >> perf.log

# After test
echo "End: $(date +%s%N)" >> perf.log
```

### Typical Performance

| Phase | Duration |
|-------|----------|
| Compilation | 20-30 seconds |
| Elaboration | 2-5 seconds |
| Simulation | 10-20 seconds |
| **Total** | **32-55 seconds** |

## Stress Testing

### Run Extended Test (10x more transactions)

Create `extended_regression_test`:

```systemverilog
class extended_regression_test extends riscv_uvm_base_test;
  task run_phase(uvm_phase phase);
    gpio_passthrough_sequence gpio_seq;
    uart_echo_sequence uart_seq;
    
    phase.raise_objection(this);
    
    // Run each test 10 times
    repeat(10) begin
      gpio_seq = gpio_passthrough_sequence::type_id::create("gpio_seq");
      gpio_seq.start(env.gpio_agt.sequencer);
      
      uart_seq = uart_echo_sequence::type_id::create("uart_seq");
      uart_seq.start(env.uart_agt.sequencer);
    end
    
    repeat(100) @(posedge vif.clk);
    
    phase.drop_objection(this);
  endtask
  
endclass
```

## Randomization Testing

### Enable Full Randomization

In sequences, replace fixed patterns with random:

```systemverilog
// Before: Fixed pattern
trans.gpio_in = 8'hAA;

// After: Random pattern
assert(trans.randomize()) else `uvm_error("", "Randomization failed")
```

### Set Randomization Seed for Reproducibility

```bash
vsim -batch -do "seed 12345; run_test();"
```

## Parallel Test Execution

Run multiple test variations simultaneously:

```bash
# Test 1 (seed 1)
vsim -batch -do "seed 1; run -all" -l test_seed_1.log &

# Test 2 (seed 2)
vsim -batch -do "seed 2; run -all" -l test_seed_2.log &

# Wait for all
wait
```

## Regression Testing

### Create Test List

Create `test_list.txt`:
```
gpio_passthrough_test
uart_echo_test
axi_write_test
axi_read_test
interrupt_test
riscv_regression_test
```

### Run All Tests

```bash
for test in $(cat test_list.txt); do
  echo "Running $test..."
  vsim -batch -do "vsim -f filelist.txt tb_riscv_uvm +UVM_TESTNAME=$test" -l ${test}.log
  grep "PASS\|FAIL" ${test}.log
done
```

## Report Generation

### Generate HTML Report

Questa can generate HTML coverage reports:

```bash
# In simulation
coverage save -testname gpio_test coverage_gpio.ucdb
coverage report -html coverage_gpio.ucdb -output coverage_report.html
```

### View Report

```bash
firefox coverage_report.html  # Linux
open coverage_report.html     # Mac
start coverage_report.html    # Windows
```

## Best Practices

1. **Always use assertions** - Enable them for debugging:
   ```bash
   vsim +assert+on
   ```

2. **Enable info messages** - Set verbosity:
   ```bash
   vsim +UVM_VERBOSITY=UVM_HIGH
   ```

3. **Save waveforms** - For post-mortem debugging:
   ```bash
   vsim -do "run -all; dump all; exit"
   ```

4. **Use unique names** - For easy tracking:
   ```systemverilog
   trans = gpio_transaction::type_id::create($sformatf("gpio_trans_%0d", i));
   ```

5. **Document test intent** - In info messages:
   ```systemverilog
   `uvm_info("GPIO_PASS_SEQ", "Testing GPIO pass-through with pattern 0xAA", UVM_MEDIUM)
   ```

---

**Ready to start testing!** Try running a single test first, then move to regression testing.

