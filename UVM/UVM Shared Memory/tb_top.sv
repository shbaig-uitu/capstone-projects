`include "uvm_macros.svh"
import uvm_pkg::*;
import shared_mem_pkg::*;

module tb_top;
    logic clk = 0;
    always #5 clk = ~clk;

    shared_mem_if vif(clk);

    shared_mem dut (
        .clk    (vif.clk),
        .addr0  (vif.addr0),  .read0  (vif.read0),  .write0 (vif.write0),
        .wdata0 (vif.wdata0), .wmask0 (vif.wmask0), .rdata0 (vif.rdata0),
        .addr1  (vif.addr1),  .read1  (vif.read1),  .write1 (vif.write1),
        .wdata1 (vif.wdata1), .wmask1 (vif.wmask1), .rdata1 (vif.rdata1)
    );

    initial begin
        uvm_config_db#(virtual shared_mem_if)::set(null, "*", "vif", vif);
        run_test("shared_mem_test");
    end
endmodule
