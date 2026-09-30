`include "uvm_macros.svh"
import uvm_pkg::*;
import data_cache_pkg::*;
module tb_top;
    logic clk = 0;
    always #5 clk = ~clk;
 
    data_cache_if vif(clk);
 
    data_cache dut (
        .clk        (vif.clk),
        .mem_addr   (vif.mem_addr),
        .mem_read   (vif.mem_read),
        .mem_write  (vif.mem_write),
        .cache_i    (vif.cache_i),
        .cache_o    (vif.cache_o),
        .write_mask (vif.write_mask)
    );
 
    initial begin
        uvm_config_db#(virtual data_cache_if)::set(null, "*", "vif", vif);
        run_test("data_cache_test");
    end
endmodule
