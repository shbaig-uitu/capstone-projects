# UVM Results Interpretation Guide

## Understanding Test Results

### Typical Successful Test Report

```
============================================================================
VERIFICATION SUMMARY
============================================================================
GPIO Tests:      PASS=40  FAIL=0
UART Tests:      PASS=20  FAIL=0
AXI Tests:       PASS=50  FAIL=0
-----------
TOTAL:           PASS=110 FAIL=0
============================================================================
>>> ALL TESTS PASSED <<<
============================================================================
```

## Result File Locations

| File | Location | Purpose |
|------|----------|---------|
| Simulation Log | `reports/uvm_simulation.log` | Detailed test execution log |
| Verification Report | `reports/uvm_verification_report.txt` | Test summary and results |
| Quick Summary | `reports/UVM_SUMMARY.txt` | Quick reference (Windows) |
| Waveform | `reports/riscv_uvm.vcd` | GTKWave visualization |

## Reading the Simulation Log

### Log File Structure

```
[Line   1-50] Compilation messages
[Line  51-100] Elaboration messages
[Line 101-200] Reset sequence and initialization
[Line 201-300] GPIO test transactions
[Line 301-400] UART test transactions
[Line 401-600] AXI test transactions
[Line 601-650] Interrupt test transactions
[Line 651-700] Coverage report
[Line 701-750] Final scoreboard report
[Line 751-end] Simulation conclusion
```

### Key Log Entries

#### Test Start
```
REGRESSION_TEST: >>> Running GPIO Test
GPIO_PASS_SEQ: Starting GPIO pass-through sequence
```

#### Individual Transaction
```
GPIO_DRV: Driving GPIO_TRANS: IN=0x01, OUT=0x01, EXP=0x01
GPIO_MON: Monitored GPIO_TRANS: IN=0x01, OUT=0x01, EXP=0x01
GPIO_SB_PASS: PASS: IN=0x01 OUT=0x01
```

#### Test End
```
GPIO_PASS_SEQ: GPIO pass-through sequence completed
GPIO_SB_REPORT: GPIO Results - PASS: 40 FAIL: 0
```

## Interpreting Different Outcomes

### ✅ All Tests Passed (Expected)

```
>>> ALL TESTS PASSED <<<
```

**Interpretation:** RTL design is functioning correctly for all verified aspects.

**Check:** Confirm all test counts are as expected:
- GPIO: 40 tests
- UART: 20 tests
- AXI: 50 tests
- Total: 110 tests

### ❌ Test Failed

```
>>> 5 TESTS FAILED <<<
AXI Results - PASS: 45 FAIL: 5
```

**Interpretation:** 5 AXI transactions failed out of 50. Some RTL issue detected.

**Action:**
1. Find failing transactions in log:
   ```bash
   grep "AXI_SB_FAIL" reports/uvm_simulation.log
   ```

2. Example failure:
   ```
   AXI_SB_FAIL: FAIL: ADDR=0x80000100 DATA=0x12345678 RESP=10 (non-OKAY response)
   ```

3. Analyze what went wrong:
   - RESP=10 means "EXOKAY" (exclusive response)
   - Expected RESP=00 (OKAY)
   - Check if interface handling responses correctly

### ⚠️ Compilation Error

```
** Error: vlog -sv ../rtl/include/riscv_types.sv
** Error: (vlog-13069) ../rtl/include/riscv_types.sv(25): near "typedef": syntax error
```

**Interpretation:** RTL file has syntax error.

**Action:**
1. Check line 25 of `riscv_types.sv`
2. Look for:
   - Missing semicolons
   - Invalid SystemVerilog syntax for Yosys
   - Undefined types/parameters

### ⚠️ Simulation Stopped Early

```
Simulation timeout reached
```

**Interpretation:** Test ran too long without completing.

**Action:**
1. Check for infinite loops in test sequences
2. Increase timeout in `tb_riscv_uvm.sv`:
   ```systemverilog
   #10000000;  // Increase to 20000000 (20ms)
   ```
3. Check DUT for hang conditions

## Test Coverage Analysis

### Coverage Report Entry

```
GPIO Coverage = 85.50%
UART Coverage = 100.00%
AXI Coverage = 72.30%
```

### Interpretation Table

| Coverage | Status | Action |
|----------|--------|--------|
| > 90% | ✅ Excellent | No action needed |
| 75-90% | ✅ Good | Consider additional tests |
| 50-75% | ⚠️ Fair | Add more stimulus patterns |
| < 50% | ❌ Poor | Significant testing gaps |

### Improving Coverage

#### GPIO Coverage Low?

Add more patterns:
```systemverilog
// In gpio_passthrough_sequence
for(int i = 0; i < 256; i++) begin
  trans = gpio_transaction::type_id::create("trans");
  trans.gpio_in = i[7:0];
  trans.gpio_expected = i[7:0];
  start_item(trans);
  finish_item(trans);
  @(posedge m_sequencer.vif.clk);
end
```

#### UART Coverage Low?

Add more state transitions:
```systemverilog
// In uart_echo_sequence
repeat(100) begin  // Increase from 10
  trans = uart_transaction::type_id::create("trans");
  assert(trans.randomize()) else `uvm_error("", "Randomization failed")
  start_item(trans);
  finish_item(trans);
  @(posedge m_sequencer.vif.clk);
end
```

#### AXI Coverage Low?

Add address range coverage:
```systemverilog
// Cover multiple address ranges
assert(trans.randomize() with {
  addr inside {[32'h00000000:32'h0000FFFF],   // Instruction memory
               [32'h00010000:32'h0001FFFF],   // Data memory
               [32'h80000000:32'h800000FF]};  // Peripherals
})
```

## Scoreboard Analysis

### GPIO Scoreboard

**What it checks:**
- GPIO input is correctly passed to output
- No bit swapping
- No timing errors

**Typical pass log:**
```
GPIO_SB_PASS: PASS: IN=0xAA OUT=0xAA
GPIO_SB_PASS: PASS: IN=0x55 OUT=0x55
```

**Failure example:**
```
GPIO_SB_FAIL: FAIL: IN=0xFF OUT=0x00 EXP=0xFF
```
→ GPIO output is inverted or disconnected

### UART Scoreboard

**What it checks:**
- UART RX correctly echoed to TX
- No bit corruption
- Handshaking valid

**Typical pass log:**
```
UART_SB_PASS: PASS: RX=1 TX=1
UART_SB_PASS: PASS: RX=0 TX=0
```

**Failure example:**
```
UART_SB_FAIL: FAIL: RX=1 TX=0 EXP=1
```
→ UART TX not properly connected to RX

### AXI Scoreboard

**What it checks:**
- Write transactions complete with OKAY response
- Read transactions return correct data
- Handshake protocol followed

**Typical pass log:**
```
AXI_SB_PASS: PASS: ADDR=0x80000000 DATA=0x12345678 RESP=00
AXI_SB_PASS: PASS: ADDR=0x00000000 DATA=0x00000000 RESP=00
```

**Failure example:**
```
AXI_SB_FAIL: FAIL: ADDR=0x80000100 DATA=0xXXXXXXXX RESP=10 (non-OKAY response)
```
→ AXI interface returning error response

## Debugging Failed Tests Using Waveform

### Open Waveform

```bash
gtkwave reports/riscv_uvm.vcd &
```

### What to Look For

#### GPIO Failure
1. Open `gpio_in` and `gpio_out` signals
2. Look for timing misalignment
3. Check if signals change on clock edge
4. Verify no signal inversion

#### UART Failure
1. Open `uart_rx` and `uart_tx` signals
2. Check if TX follows RX
3. Look for clock cycle alignment
4. Verify no bit shifting

#### AXI Failure
1. Open `axi_awvalid`, `axi_awready`
2. Check `axi_wvalid`, `axi_wready`
3. Verify `axi_bvalid`, `axi_bresp`
4. Look for protocol violations

## Interpreting Specific Error Messages

### Error: "Virtual interface not found"
```
** Error: Virtual interface not found
```
**Cause:** Interface not set in `uvm_config_db`
**Fix:** Check `tb_riscv_uvm.sv` line 95:
```systemverilog
uvm_config_db #(virtual riscv_soc_if)::set(null, "*", "vif", dut_if);
```

### Error: "Cast failed"
```
** Error: Cast failed
```
**Cause:** Wrong transaction type passed to sequencer
**Fix:** Check sequence starts on correct sequencer:
```systemverilog
seq.start(env.gpio_agt.sequencer);  // Correct
// NOT: seq.start(env.uart_agt.sequencer);  // Wrong!
```

### Error: "Randomization failed"
```
** Error: Randomization failed
```
**Cause:** Constraints too restrictive
**Fix:** Review randomization constraints:
```systemverilog
// Before: Too restrictive
assert(trans.randomize() with {addr == 32'h80000000; data == 32'hDEADBEEF;})

// After: More flexible
assert(trans.randomize() with {addr inside {[32'h80000000:32'h800000FF]};})
```

## Performance Metrics

### Simulation Speed

```
Total runtime: 50 seconds
- Compilation: 25 seconds
- Simulation: 25 seconds
```

**Expected:** 30-60 seconds total

**If slower:** Check system load, disable waveform dumping

**If faster:** Simulation may have stopped early

### Test Throughput

```
Total tests: 110
Simulation time: 25 seconds
Tests per second: 4.4
```

## Creating Summary Reports

### Extract Pass/Fail Summary

```bash
grep "SB_REPORT" reports/uvm_simulation.log
```

### Count By Test Type

```bash
# GPIO tests
grep "GPIO_SB" reports/uvm_simulation.log | grep -c "PASS"

# UART tests
grep "UART_SB" reports/uvm_simulation.log | grep -c "PASS"

# AXI tests
grep "AXI_SB" reports/uvm_simulation.log | grep -c "PASS"
```

### Generate Custom Report

```bash
#!/bin/bash
echo "Test Results Summary"
echo "===================="
echo ""
echo "GPIO Tests:"
grep "GPIO_SB_REPORT" reports/uvm_simulation.log
echo ""
echo "UART Tests:"
grep "UART_SB_REPORT" reports/uvm_simulation.log
echo ""
echo "AXI Tests:"
grep "AXI_SB_REPORT" reports/uvm_simulation.log
echo ""
echo "Coverage:"
grep "Coverage = " reports/uvm_simulation.log
echo ""
echo "Overall Result:"
grep "ALL TESTS\|TESTS FAILED" reports/uvm_simulation.log
```

## Troubleshooting Guide

### Problem: All tests show FAIL but no error messages

**Diagnosis:**
```bash
grep -E "ERROR|FATAL" reports/uvm_simulation.log
```

**Likely causes:**
1. Interface signals not properly connected
2. DUT not instantiated correctly
3. Clock not running

**Fix:**
1. Check `tb_riscv_uvm.sv` instantiation
2. Verify port connections
3. Check clock generation

### Problem: Some tests pass, others fail randomly

**Likely cause:** Randomization seed not set

**Fix:**
```bash
vsim -batch -do "seed 12345; run -all;"
```

### Problem: Coverage reports show 0% for all tests

**Likely cause:** Coverage not being sampled

**Fix:** In monitor or driver, add:
```systemverilog
@(posedge vif.clk);
gpio_coverage_group.sample();
```

## Baseline Results

### Expected Results for Correct RTL

```
============================================================================
VERIFICATION SUMMARY
============================================================================
GPIO Tests:      PASS=40  FAIL=0   ✅
UART Tests:      PASS=20  FAIL=0   ✅
AXI Tests:       PASS=50  FAIL=0   ✅
-----------
TOTAL:           PASS=110 FAIL=0   ✅ ALL PASS
============================================================================

Coverage Targets:
GPIO Coverage = 85-95%  ✅
UART Coverage = 95-100% ✅
AXI Coverage = 70-85%   ✅

Simulation Performance:
Total time: 30-60 seconds ✅
No hangs or timeouts ✅
All tests complete successfully ✅
```

## Next Steps After Successful Test

1. **Increase test complexity**
   - Add stress tests
   - Run randomized tests
   - Test edge cases

2. **Improve coverage**
   - Target uncovered scenarios
   - Add boundary tests
   - Increase stimulus patterns

3. **Run regression**
   - Run full test suite daily
   - Track results over time
   - Identify trends

4. **Deployment**
   - If all tests pass, ready for synthesis
   - If some fail, fix RTL and re-test
   - Document any known issues

---

**Now you're ready to interpret UVM test results like a pro!** 🎓

