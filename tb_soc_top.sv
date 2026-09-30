// =============================================================
// tb_soc_top.sv
// Directed, self-checking testbench.
//
// Flow:
//   1. Reset everything.
//   2. While the core is still held in reset, program the page table
//      over AXI4-Lite: map VPN 0 -> PPN 3. Leave VPN 4 unmapped.
//   3. Load the test program into instruction memory.
//   4. Release the core, let it run.
//   5. Detect completion (core parked at its own self-loop, addr 40).
//   6. Check: register values, physical memory contents, TLB hit/miss
//      counts (read back over AXI), and the sticky fault flag.
// =============================================================
`timescale 1ns/1ps

module tb_soc_top;

  logic clk = 0;
  always #5 clk = ~clk; // 100 MHz

  logic rst_n = 0;
  logic core_rst_n = 0;

  // ---- AXI4-Lite driver signals -------------------------------------------
  logic [7:0]  axi_awaddr;
  logic        axi_awvalid;
  logic        axi_awready;
  logic [31:0] axi_wdata;
  logic        axi_wvalid;
  logic        axi_wready;
  logic [1:0]  axi_bresp;
  logic        axi_bvalid;
  logic        axi_bready;
  logic [7:0]  axi_araddr;
  logic        axi_arvalid;
  logic        axi_arready;
  logic [31:0] axi_rdata;
  logic [1:0]  axi_rresp;
  logic        axi_rvalid;
  logic        axi_rready;

  logic led_fault, led_hit, led_miss;
  logic uart_txd;

  int errors = 0;

  soc_top dut (
    .clk           (clk),
    .rst_n         (rst_n),
    .core_rst_n    (core_rst_n),
    .s_axi_awaddr  (axi_awaddr),
    .s_axi_awvalid (axi_awvalid),
    .s_axi_awready (axi_awready),
    .s_axi_wdata   (axi_wdata),
    .s_axi_wvalid  (axi_wvalid),
    .s_axi_wready  (axi_wready),
    .s_axi_bresp   (axi_bresp),
    .s_axi_bvalid  (axi_bvalid),
    .s_axi_bready  (axi_bready),
    .s_axi_araddr  (axi_araddr),
    .s_axi_arvalid (axi_arvalid),
    .s_axi_arready (axi_arready),
    .s_axi_rdata   (axi_rdata),
    .s_axi_rresp   (axi_rresp),
    .s_axi_rvalid  (axi_rvalid),
    .s_axi_rready  (axi_rready),
    .led_fault     (led_fault),
    .led_hit       (led_hit),
    .led_miss      (led_miss),
    .uart_txd      (uart_txd)
  );

  // ---- simple AXI4-Lite write task (single beat, blocking) ---------------
  task automatic axi_write(input logic [7:0] addr, input logic [31:0] data);
    begin
      @(posedge clk);
      axi_awaddr  <= addr;
      axi_awvalid <= 1'b1;
      axi_wdata   <= data;
      axi_wvalid  <= 1'b1;
      axi_bready  <= 1'b1;
      @(posedge clk);
      while (!(axi_awready && axi_wready)) @(posedge clk);
      axi_awvalid <= 1'b0;
      axi_wvalid  <= 1'b0;
      while (!axi_bvalid) @(posedge clk);
      @(posedge clk);
      axi_bready <= 1'b0;
    end
  endtask

  task automatic axi_read(input logic [7:0] addr, output logic [31:0] data);
    begin
      @(posedge clk);
      axi_araddr  <= addr;
      axi_arvalid <= 1'b1;
      axi_rready  <= 1'b1;
      @(posedge clk);
      while (!axi_arready) @(posedge clk);
      axi_arvalid <= 1'b0;
      while (!axi_rvalid) @(posedge clk);
      data = axi_rdata;
      @(posedge clk);
      axi_rready <= 1'b0;
    end
  endtask

  task automatic check(input string name, input logic [31:0] got, input logic [31:0] exp);
    begin
      if (got !== exp) begin
        $display("[FAIL] %-28s got=0x%08x expected=0x%08x", name, got, exp);
        errors++;
      end else begin
        $display("[PASS] %-28s = 0x%08x", name, got);
      end
    end
  endtask

  logic [31:0] rd;

  initial begin
    axi_awaddr = 0; axi_awvalid = 0; axi_wdata = 0; axi_wvalid = 0; axi_bready = 0;
    axi_araddr = 0; axi_arvalid = 0; axi_rready = 0;

    // ---- 1. reset -------------------------------------------------------
    rst_n = 0; core_rst_n = 0;
    repeat (5) @(posedge clk);
    rst_n = 1;
    repeat (3) @(posedge clk);

    // ---- 2. load the test program into instruction memory ----------------
    $readmemh("tb/test_prog.hex", dut.u_imem.mem, 0, 10); // 11 instructions, indices 0..10

    // ---- 3. program the page table: VPN0 -> PPN3, valid=1 ----------------
    // bits: [9:5]=vpn [4:1]=ppn [0]=valid  =>  vpn=0, ppn=3, valid=1 => 0x7
    axi_write(8'h00, 32'h0000_0007);
    $display("[INFO] Programmed page table: VPN0 -> PPN3 (valid)");
    $display("[INFO] VPN4 intentionally left unmapped (expect page fault there)");

    // ---- 4. release the core ----------------------------------------------
    repeat (2) @(posedge clk);
    core_rst_n = 1;
    $display("[INFO] Core released, running test program...");

    // ---- 5. wait until the core parks at its self-loop (PC == 40) --------
    // give it a generous cycle budget (accounts for TLB-miss extra cycles)
    fork
      begin : wait_done
        wait (dut.u_core.pc == 32'd40 && dut.u_core.state == 3'd0); // S_FETCH at addr 40
        repeat (10) @(posedge clk); // let it settle in the loop
      end
      begin : timeout
        repeat (2000) @(posedge clk);
        $display("[FAIL] Timeout waiting for program completion");
        errors++;
      end
    join_any
    disable fork;

    // ---- 6. self-check ----------------------------------------------------
    $display("\n===== Register file checks =====");
    check("x2  (LW hit, expect 100)",  dut.u_core.regfile[2], 32'd100);
    check("x4  (LW hit, expect 55)",   dut.u_core.regfile[4], 32'd55);
    check("x8  (LW fault pattern)",    dut.u_core.regfile[8], 32'hDEAD_DEAD);

    $display("\n===== Physical memory checks (PPN3 = phys 0x300) =====");
    check("dmem[word 192] (VA0  data)", dut.u_dmem.mem[192], 32'd100);
    check("dmem[word 193] (VA4  data)", dut.u_dmem.mem[193], 32'd55);

    $display("\n===== MMU / AXI status checks =====");
    axi_read(8'h04, rd);
    check("FAULT_STATUS (sticky)", rd, 32'h1);
    check("led_fault", {31'h0, led_fault}, 32'h1);

    axi_read(8'h0C, rd);
    $display("[INFO] hit_count  = %0d", rd);
    if (rd < 3) begin $display("[FAIL] expected >=3 TLB hits"); errors++; end
    else        $display("[PASS] hit_count >= 3");

    axi_read(8'h10, rd);
    $display("[INFO] miss_count = %0d", rd);
    if (rd < 3) begin $display("[FAIL] expected >=3 TLB misses"); errors++; end
    else        $display("[PASS] miss_count >= 3");

    // clear the fault and confirm it clears
    axi_write(8'h04, 32'h0);
    axi_read(8'h04, rd);
    check("FAULT_STATUS after clear", rd, 32'h0);

    $display("\n=====================================");
    if (errors == 0) $display("RESULT: ALL CHECKS PASSED");
    else              $display("RESULT: %0d CHECK(S) FAILED", errors);
    $display("=====================================\n");

    $finish;
  end

  // waveform dump for debugging
  initial begin
    $dumpfile("sim.vcd");
    $dumpvars(0, tb_soc_top);
  end

endmodule
