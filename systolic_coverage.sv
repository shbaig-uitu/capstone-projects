

class systolic_coverage extends uvm_subscriber #(axi_seq_item);
    `uvm_component_utils(systolic_coverage)

    axi_seq_item cov_item;

    covergroup cg_axi;
        cp_op: coverpoint cov_item.op;
        cp_addr: coverpoint cov_item.addr[7:0] {
            bins ctrl_reg   = {8'h00};
            bins status_reg = {8'h04};
            bins weight_mem = {[8'h40:8'h7C]};
            bins act_mem    = {[8'h80:8'hBC]};
            bins result_mem = {[8'hC0:8'hFC]};
        }
        cp_weight_data: coverpoint $signed(cov_item.data[7:0]) iff (cov_item.op == AXI_WRITE && cov_item.addr >= 32'h40 && cov_item.addr < 32'h80) {
            bins zero = {0};
            bins negative = {[-128:-1]};
            bins positive = {[1:127]};
        }
        cp_act_data: coverpoint $signed(cov_item.data[7:0]) iff (cov_item.op == AXI_WRITE && cov_item.addr >= 32'h80 && cov_item.addr < 32'hC0) {
            bins zero = {0};
            bins negative = {[-128:-1]};
            bins positive = {[1:127]};
        }
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_axi = new();
    endfunction

    virtual function void write(axi_seq_item t);
        cov_item = t;
        cg_axi.sample();
    endfunction
endclass