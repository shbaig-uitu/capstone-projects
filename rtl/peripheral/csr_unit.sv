/**
 * RISC-V SoC with Virtual Memory Support
 * Capstone Project
 * 
 * File: csr_unit.sv
 * Description: Control and Status Register (CSR) Handler Module
 *              Implements SATP (Supervisor Address Translation and Protection)
 *              and MSTATUS (Machine Status) registers with privilege checking.
 *              Provides cycle counter, timer, and exception PC storage.
 */

`include "../include/riscv_defines.sv"
`include "../include/riscv_types.sv"

module csr_unit (
  input  logic                clk,
  input  logic                rst_n,
  
  // CSR Read/Write Interface from Core
  input  logic                csr_valid,
  input  logic [11:0]         csr_addr,
  input  logic [`DATA_WIDTH-1:0]  csr_wdata,
  input  logic [1:0]          csr_op,        // 00=read, 01=write, 10=set, 11=clear
  output logic [`DATA_WIDTH-1:0]  csr_rdata,
  output logic                csr_ready,
  
  // MMU Interface (SATP register)
  output logic [`DATA_WIDTH-1:0]  satp_reg,
  output logic                satp_updated,
  
  // Status Register Output
  output logic [`DATA_WIDTH-1:0]  mstatus_reg,
  
  // Exception/Interrupt Signals
  input  logic                exception_valid,
  input  logic [3:0]          exception_code,
  input  logic [`ADDR_WIDTH-1:0]  exception_badaddr,
  input  logic [`ADDR_WIDTH-1:0]  exception_pc,
  
  // Interrupt Control
  output logic                global_interrupt_en,
  output logic                timer_interrupt,
  input  logic                ext_timer_interrupt,
  
  // Cycle Counter (for performance monitoring)
  output logic [`DATA_WIDTH-1:0]  cycle_count
);

  // ============================================================================
  // CSR Registers (using bit fields instead of structs)
  // ============================================================================
  
  logic [`DATA_WIDTH-1:0] satp;            // Supervisor Address Translation Protection
  logic [`DATA_WIDTH-1:0] mstatus;        // Machine Status
  logic [`DATA_WIDTH-1:0] mepc;           // Machine Exception PC
  logic [`DATA_WIDTH-1:0] mcause;         // Machine Cause
  logic [`DATA_WIDTH-1:0] mtval;          // Machine Trap Value (bad address)
  logic [`DATA_WIDTH-1:0] mie;            // Machine Interrupt Enable
  logic [`DATA_WIDTH-1:0] mip;            // Machine Interrupt Pending
  
  // Performance Counters
  logic [`DATA_WIDTH-1:0] mcycle;         // Machine Cycle Counter
  logic [`DATA_WIDTH-1:0] minstret;       // Machine Instructions Retired
  
  // Internal Signals
  logic [`DATA_WIDTH-1:0] csr_rdata_int;
  logic                   csr_write_en;
  logic                   csr_set_en;
  logic                   csr_clear_en;
  
  // ============================================================================
  // CSR Read Logic
  // ============================================================================
  
  always_comb begin
    csr_rdata_int = '0;
    
    case (csr_addr)
      `CSR_MSTATUS: csr_rdata_int = mstatus;           // MSTATUS
      `CSR_MISA:    csr_rdata_int = 32'h40000100;      // MISA - RV32I with M extension
      `CSR_MIE:     csr_rdata_int = mie;               // MIE (Machine Interrupt Enable)
      `CSR_MTVEC:   csr_rdata_int = 32'h80000000;      // MTVEC (Trap Vector)
      `CSR_MCAUSE:  csr_rdata_int = mcause;            // MCAUSE
      `CSR_MTVAL:   csr_rdata_int = mtval;             // MTVAL (bad addr/instr)
      `CSR_MIP:     csr_rdata_int = mip;               // MIP (Interrupt Pending)
      `CSR_MEPC:    csr_rdata_int = mepc;              // MEPC
      `CSR_SATP:    csr_rdata_int = satp;              // SATP
      `CSR_MCYCLE:  csr_rdata_int = mcycle;            // MCYCLE
      `CSR_MINSTRET: csr_rdata_int = minstret;         // MINSTRET
      default:      csr_rdata_int = '0;
    endcase
  end
  
  // ============================================================================
  // CSR Write and Update Logic
  // ============================================================================
  
  assign csr_write_en  = csr_valid && (csr_op == 2'b01);
  assign csr_set_en    = csr_valid && (csr_op == 2'b10);
  assign csr_clear_en  = csr_valid && (csr_op == 2'b11);
  assign csr_ready     = 1'b1;          // CSR reads/writes complete in 1 cycle
  assign csr_rdata     = csr_rdata_int;
  
  // SATP Update Flag
  assign satp_updated = csr_write_en && (csr_addr == `CSR_SATP);
  
  // ============================================================================
  // CSR Privilege Checks and Write Operations
  // ============================================================================
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      satp     <= '0;
      mstatus  <= '0;
      mepc     <= '0;
      mcause   <= '0;
      mtval    <= '0;
      mie      <= '0;
      mip      <= '0;
      mcycle   <= '0;
      minstret <= '0;
    end else begin
      
      // Cycle counter increments every cycle
      mcycle <= mcycle + 1;
      
      // Timer interrupt from external source
      if (ext_timer_interrupt) begin
        mip[7] <= 1'b1;  // Set MTIP (machine timer interrupt pending)
      end
      
      // Exception handling - update exception-related CSRs
      if (exception_valid) begin
        mepc   <= exception_pc;
        mcause <= {1'b0, exception_code};
        mtval  <= exception_badaddr;
      end
      
      // CSR Write Operations
      if (csr_write_en) begin
        case (csr_addr)
          // MSTATUS - only certain fields are writable
          `CSR_MSTATUS: begin
            mstatus[1]  <= csr_wdata[1];     // SIE
            mstatus[5]  <= csr_wdata[5];     // SPIE
            mstatus[8]  <= csr_wdata[8];     // SPP
            mstatus[20] <= csr_wdata[20];    // TVM
            mstatus[21] <= csr_wdata[21];    // TW
            mstatus[22] <= csr_wdata[22];    // TSR
          end
          
          // MIE - Machine Interrupt Enable
          `CSR_MIE: mie <= csr_wdata;
          
          // MCAUSE
          `CSR_MCAUSE: mcause <= csr_wdata;
          
          // MTVAL
          `CSR_MTVAL: mtval <= csr_wdata;
          
          // MIP
          `CSR_MIP: mip <= csr_wdata;
          
          // MEPC - Machine Exception PC
          `CSR_MEPC: mepc <= csr_wdata;
          
          // SATP - Supervisor Address Translation and Protection
          `CSR_SATP: begin
            satp <= csr_wdata;
          end
          
          // MINSTRET - Instruction Retired Counter
          `CSR_MINSTRET: minstret <= csr_wdata;
          
          default: begin
            // Unsupported CSR - silently ignore
          end
        endcase
      end
      
      // CSR Set (CSRRS) - Set Bits in CSR
      if (csr_set_en) begin
        case (csr_addr)
          `CSR_MSTATUS: mstatus <= mstatus | csr_wdata;
          `CSR_MIE:     mie     <= mie | csr_wdata;
          `CSR_MIP:     mip     <= mip | csr_wdata;
          default: begin
            // Other CSRs don't support set operation
          end
        endcase
      end
      
      // CSR Clear (CSRRC) - Clear Bits in CSR
      if (csr_clear_en) begin
        case (csr_addr)
          `CSR_MSTATUS: mstatus <= mstatus & ~csr_wdata;
          `CSR_MIE:     mie     <= mie & ~csr_wdata;
          `CSR_MIP:     mip     <= mip & ~csr_wdata;
          default: begin
            // Other CSRs don't support clear operation
          end
        endcase
      end
    end
  end
  
  // ============================================================================
  // Output Assignments
  // ============================================================================
  
  assign satp_reg = satp;
  assign mstatus_reg = mstatus;
  assign global_interrupt_en = mstatus[1];  // Supervisor interrupt enable (SIE)
  assign timer_interrupt = mip[7];           // Timer interrupt pending
  assign cycle_count = mcycle;
  
  // ============================================================================
  // MTVEC Register (Trap Vector) - Read-only, hardcoded for now
  // ============================================================================
  
  logic [`DATA_WIDTH-1:0] mtvec;
  assign mtvec = 32'h80000000;  // Base address for exception handlers

endmodule : csr_unit

