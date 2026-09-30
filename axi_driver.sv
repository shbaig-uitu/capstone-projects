

class axi_driver extends uvm_driver #(axi_seq_item);
    `uvm_component_utils(axi_driver)
    virtual axi_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "Could not get virtual interface vif")
    endfunction

    task run_phase(uvm_phase phase);
        // Default pin states
        vif.awvalid <= 0;
        vif.wvalid  <= 0;
        vif.bready  <= 0;
        vif.arvalid <= 0;
        vif.rready  <= 0;
        vif.awaddr  <= 0;
        vif.wdata   <= 0;
        vif.araddr  <= 0;

        @(negedge vif.rst);
        @(posedge vif.clk);

        forever begin
            seq_item_port.get_next_item(req);
            if (req.op == AXI_WRITE) begin
                write_trans(req.addr, req.data);
            end else begin
                read_trans(req.addr, req.rdata);
            end
            seq_item_port.item_done();
        end
    endtask

    task write_trans(input [31:0] addr, input [31:0] data);
        @(posedge vif.clk);
        vif.awaddr  <= addr;
        vif.awvalid <= 1'b1;
        vif.wdata   <= data;
        vif.wvalid  <= 1'b1;
        vif.bready  <= 1'b1;

        fork
            begin
                wait (vif.awready);
                @(posedge vif.clk);
                vif.awvalid <= 1'b0;
            end
            begin
                wait (vif.wready);
                @(posedge vif.clk);
                vif.wvalid <= 1'b0;
            end
        join

        wait (vif.bvalid);
        @(posedge vif.clk);
        vif.bready <= 1'b0;
    endtask

    task read_trans(input [31:0] addr, output [31:0] data);
        @(posedge vif.clk);
        vif.araddr  <= addr;
        vif.arvalid <= 1'b1;
        vif.rready  <= 1'b1;

        wait (vif.arready);
        @(posedge vif.clk);
        vif.arvalid <= 1'b0;

        wait (vif.rvalid);
        data = vif.rdata;
        @(posedge vif.clk);
        vif.rready <= 1'b0;
    endtask
endclass