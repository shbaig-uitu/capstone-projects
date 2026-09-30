// =============================================================
// memories.sv
// Physical instruction memory (4KB, untranslated, byte-addressed but
// word-aligned access only) and physical data memory (4KB, sits behind
// the MMU). Both: async (combinational) read, sync write - a standard
// behavioral SRAM model, easily swapped for inferred/vendor BRAM later.
// =============================================================
import soc_pkg::*;

module instr_mem #(
  parameter string INIT_FILE = ""
) (
  input  logic [IMEM_ADDR_BITS-1:0] addr,   // byte address, word-aligned
  output logic [31:0]               rdata
);

  // Program is loaded by the testbench / boot flow via a hierarchical
  // $readmemh("file.hex", <path>.u_imem.mem) call - avoids relying on
  // string module parameters, which some toolchains handle inconsistently.
  logic [31:0] mem [0:IMEM_WORDS-1];

  initial begin
    for (int i = 0; i < IMEM_WORDS; i++) mem[i] = 32'h0000_0013; // NOP (ADDI x0,x0,0)
    if (INIT_FILE != "") $readmemh(INIT_FILE, mem);
  end

  assign rdata = mem[addr[IMEM_ADDR_BITS-1:2]];

endmodule


module data_mem (
  input  logic                  clk,
  input  logic [PA_WIDTH-1:0]   addr,   // physical byte address
  input  logic                  we,
  input  logic [31:0]           wdata,
  output logic [31:0]           rdata
);

  localparam int WORDS = (1 << PA_WIDTH) / 4;
  logic [31:0] mem [0:WORDS-1];

  initial begin
    for (int i = 0; i < WORDS; i++) mem[i] = 32'h0;
  end

  assign rdata = mem[addr[PA_WIDTH-1:2]];

  always_ff @(posedge clk) begin
    if (we) mem[addr[PA_WIDTH-1:2]] <= wdata;
  end

endmodule
