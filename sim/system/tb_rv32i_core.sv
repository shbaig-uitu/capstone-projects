`timescale 1ns/1ps
module tb_rv32i_core;
  logic clk=0, resetn=0;
  wire trap, mem_valid, mem_instr, mem_ready;
  wire [31:0] mem_addr, mem_wdata, mem_rdata;
  wire [3:0] mem_wstrb;
  wire [31:0] dbg_pc;
  reg [31:0] mem [0:255];
  integer errors=0;
  integer i;

  rv32i_core dut(.clk(clk),.resetn(resetn),.trap(trap),.mem_valid(mem_valid),.mem_instr(mem_instr),.mem_ready(mem_ready),
                  .mem_addr(mem_addr),.mem_wdata(mem_wdata),.mem_wstrb(mem_wstrb),.mem_rdata(mem_rdata),.dbg_pc(dbg_pc));
  always #10 clk=~clk;

  // Zero-wait-state memory model for core-only verification.
  assign mem_ready = mem_valid;
  assign mem_rdata = mem[mem_addr[9:2]];
  always @(posedge clk) begin
    if (mem_valid && !mem_instr && |mem_wstrb) begin
      if (mem_wstrb[0]) mem[mem_addr[9:2]][7:0] <= mem_wdata[7:0];
      if (mem_wstrb[1]) mem[mem_addr[9:2]][15:8] <= mem_wdata[15:8];
      if (mem_wstrb[2]) mem[mem_addr[9:2]][23:16] <= mem_wdata[23:16];
      if (mem_wstrb[3]) mem[mem_addr[9:2]][31:24] <= mem_wdata[31:24];
    end
  end

  task check(input bit c, input string s);
    if(c) $display("CORE PASS: %s",s); else begin $error("CORE FAIL: %s",s); errors++; end
  endtask

    initial begin
    $dumpfile("sim/output/rv32i_core.vcd"); $dumpvars(0, tb_rv32i_core);
    for(i=0;i<256;i=i+1) mem[i]=32'h00000013;
    // Program at 0x00:
    // x1=5; x2=7; x3=x1+x2=12; x4=x3-x1=7; x5=x3&x4=4;
    // x6=x3|x4=15; x7=x3^x4=11; x8=SLT(x1,x2)=1; x9=shift-left x1 by 2=20;
    // store/load x3 at address 0x100; BEQ skips the next ADDI; JAL jumps to loop.
    mem[0]  = 32'h00500093; // addi x1,x0,5
    mem[1]  = 32'h00700113; // addi x2,x0,7
    mem[2]  = 32'h002081B3; // add x3,x1,x2
    mem[3]  = 32'h40118233; // sub x4,x3,x1
    mem[4]  = 32'h0040F2B3; // and x5,x1,x4 = 5&7=5 (simple ALU check)
    mem[5]  = 32'h0041E333; // or x6,x3,x4 = 15
    mem[6]  = 32'h0041C3B3; // xor x7,x3,x4 = 11
    mem[7]  = 32'h0020A433; // slt x8,x1,x2
    mem[8]  = 32'h002094B3; // sll x9,x1,x2 (5<<7=640)
    mem[9]  = 32'h10000513; // addi x10,x0,256
    mem[10] = 32'h00352023; // sw x3,0(x10)
    mem[11] = 32'h00052303; // lw x6,0(x10)
    mem[12] = 32'h00618463; // beq x3,x6,+8 (skip instruction 13)
    mem[13] = 32'h00100393; // addi x7,x0,1 (must be skipped)
    mem[14] = 32'h00000013; // nop
    mem[15] = 32'h0000006F; // jal x0,0 (loop)

    repeat(5) @(posedge clk); resetn=1;
    repeat(500) @(posedge clk);
    check(dut.regs[1] === 32'd5, "ADDI");
    check(dut.regs[2] === 32'd7, "ADDI second operand");
    check(dut.regs[3] === 32'd12, "ADD");
    check(dut.regs[4] === 32'd7, "SUB");
    check(dut.regs[5] === 32'd5, "AND");
    check(dut.regs[6] === 32'd12, "LOAD after STORE");
    check(dut.regs[7] === 32'd11, "XOR and branch skip");
    check(dut.regs[8] === 32'd1, "SLT");
    check(dut.regs[9] === 32'd640, "SLL");
    check(mem[64] === 32'd12, "SW wrote memory");
    check(trap === 1'b0, "No illegal instruction trap");
    if(errors==0) $display("============================================\n RV32I CORE TEST PASSED\n============================================");
    else $fatal(1,"RV32I core errors=%0d",errors);
    $finish;
  end
endmodule
