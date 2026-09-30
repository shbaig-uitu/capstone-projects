class systolic_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(systolic_scoreboard)
    uvm_analysis_imp #(axi_seq_item, systolic_scoreboard) item_imp;

    // Internal golden storage
    logic signed [7:0]  weights[4][4];
    logic signed [7:0]  acts[4][4];
    logic signed [31:0] expected_results[16];

    function new(string name, uvm_component parent);
        super.new(name, parent);
        item_imp = new("item_imp", this);
    endfunction

    virtual function void write(axi_seq_item t);
        if (t.op == AXI_WRITE) begin
            // Track Weights (0x40 - 0x7C)
            if (t.addr[7:0] >= 8'h40 && t.addr[7:0] < 8'h80) begin
                int idx = (t.addr[7:0] - 8'h40) >> 2;
                weights[idx / 4][idx % 4] = $signed(t.data[7:0]);
            end
            // Track Activations (0x80 - 0xBC)
            else if (t.addr[7:0] >= 8'h80 && t.addr[7:0] < 8'hC0) begin
                int idx = (t.addr[7:0] - 8'h80) >> 2;
                acts[idx / 4][idx % 4] = $signed(t.data[7:0]);
            end
            // Start Trigger -> Compute Golden Product
            else if (t.addr[7:0] == 8'h00 && t.data[0] == 1'b1) begin
                compute_golden();
            end
        end 
        else if (t.op == AXI_READ) begin
            // Result Check (0xC0 - 0xFC)
            if (t.addr[7:0] >= 8'hC0 && t.addr[7:0] < 8'hFC + 4) begin
                int idx = (t.addr[7:0] - 8'hC0) >> 2;
                if (idx < 16) begin
                    if ($signed(t.rdata) !== expected_results[idx]) begin
                        `uvm_error("SCB_FAIL", $sformatf("MISMATCH at index %0d! Expected=0x%08h (%0d), Got=0x%08h (%0d)",
                            idx, expected_results[idx], expected_results[idx], t.rdata, $signed(t.rdata)))
                    end else begin
                        `uvm_info("SCB_PASS", $sformatf("MATCH at index %0d: Data=0x%08h (%0d)", 
                            idx, t.rdata, $signed(t.rdata)), UVM_LOW)
                    end
                end
            end
        end
    endfunction

    function void compute_golden();
        // Hardware dataflow mapping: Row 'k' gets col 'k' of Matrix A,
        // which accumulates C[i][j] = Sum(Act[i][k] * Weight[k][j])
        for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 4; j++) begin
                logic signed [31:0] sum = 0;
                for (int k = 0; k < 4; k++) begin
                    sum += acts[i][k] * weights[k][j];
                end
                expected_results[i * 4 + j] = sum;
            end
        end
        `uvm_info("SCB", "Golden matrix multiplication computed successfully.", UVM_MEDIUM)
    endfunction
endclass