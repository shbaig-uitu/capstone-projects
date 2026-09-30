module soc_assertions(input logic clk, input logic rst_n,
  input logic axi_awvalid, axi_awready, axi_wvalid, axi_wready,
  input logic axi_bvalid, axi_bready, axi_arvalid, axi_arready,
  input logic axi_rvalid, axi_rready,
  input logic hit_pulse, miss_pulse, fault_pulse, fault_latched,
  input logic dmem_ready);
  default clocking cb @(posedge clk); endclocking
  a_bvalid_holds: assert property(disable iff(!rst_n) axi_bvalid && !axi_bready |=> axi_bvalid)
    else $error("AXI BVALID dropped before BREADY");
  a_rvalid_holds: assert property(disable iff(!rst_n) axi_rvalid && !axi_rready |=> axi_rvalid)
    else $error("AXI RVALID dropped before RREADY");
  a_fault_needs_miss: assert property(disable iff(!rst_n) fault_pulse |-> $past(miss_pulse))
    else $error("Fault without previous-cycle miss");
  a_fault_latches: assert property(disable iff(!rst_n) fault_pulse |=> fault_latched)
    else $error("Fault pulse did not latch status");
  a_hit_ready: assert property(disable iff(!rst_n) hit_pulse |-> dmem_ready)
    else $error("Hit pulse without access completion");
  a_miss_not_ready: assert property(disable iff(!rst_n) miss_pulse |-> !dmem_ready)
    else $error("Miss unexpectedly completed in miss cycle");
endmodule
