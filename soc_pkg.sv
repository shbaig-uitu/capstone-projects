// =============================================================
// soc_pkg.sv
// Shared parameters for the RV32I + simplified virtual memory SoC.
// Values match docs/architecture.md (confirmed scope).
// =============================================================
package soc_pkg;

  // ---- Address widths -----------------------------------------------
  localparam int VA_WIDTH   = 13;  // virtual data address  (8 KB space)
  localparam int PA_WIDTH   = 12;  // physical data address (4 KB space)
  localparam int PAGE_BITS  = 8;   // page size = 256 B -> 8-bit offset
  localparam int VPN_BITS   = VA_WIDTH - PAGE_BITS; // 5 bits -> 32 vpages
  localparam int PPN_BITS   = PA_WIDTH - PAGE_BITS; // 4 bits -> 16 pframes

  localparam int NUM_VPAGES = (1 << VPN_BITS); // 32
  localparam int NUM_PFRAMES= (1 << PPN_BITS); // 16

  // ---- TLB -------------------------------------------------------------
  localparam int TLB_ENTRIES = 4;
  localparam int TLB_IDX_BITS = 2; // log2(4)

  // ---- Instruction memory (physical, untranslated) ----------------------
  localparam int IMEM_BYTES = 4096;
  localparam int IMEM_WORDS = IMEM_BYTES/4;
  localparam int IMEM_ADDR_BITS = 12;

  // ---- Fault sentinel value returned to core / status regs on a page fault
  localparam logic [31:0] FAULT_PATTERN = 32'hDEAD_DEAD;

endpackage
