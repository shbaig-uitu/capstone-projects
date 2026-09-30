class data_cache_scoreboard extends uvm_subscriber #(seq_item);

    `uvm_component_utils(data_cache_scoreboard)

    // Expected cache contents
    logic [31:0] expected_data [0:15];

    // Tells whether an address has been written
    logic valid [0:15];


    function new(string name, uvm_component parent);

        super.new(name, parent);

        // Initialize expected cache
        for (int i = 0; i < 16; i++) begin
            expected_data[i] = 32'h0000_0000;
            valid[i] = 1'b0;
        end

    endfunction


    function void write(seq_item t);

        // =================================================
        // WRITE
        // =================================================
        if (t.mem_write) begin

            // Update expected cache
            expected_data[t.mem_addr] = t.cache_i;
            valid[t.mem_addr] = 1'b1;


            // For WRITE, cache_o should be 0
            if (t.cache_o == 32'h0000_0000) begin

                `uvm_info(
                    "SB",
                    $sformatf(
                        "WRITE MATCH: addr=%0d | expected=00000000 | actual=%h | write_data=%h | mask=%h",
                        t.mem_addr,
                        32'h0000_0000,
                        t.cache_o,
                        t.cache_i,
                        t.write_mask
                    ),
                    UVM_LOW
                );

            end
            else begin

                `uvm_error(
                    "SB",
                    $sformatf(
                        "WRITE MISMATCH: addr=%0d | expected=00000000 | actual=%h | write_data=%h",
                        t.mem_addr,
                        t.cache_o,
                        t.cache_i
                    )
                );

            end

        end


        // =================================================
        // READ
        // =================================================
        else if (t.mem_read) begin


            // =================================================
            // EXPECTED HIT
            // =================================================
            if (valid[t.mem_addr]) begin

                if (t.cache_o == expected_data[t.mem_addr]) begin

                    `uvm_info(
                        "SB",
                        $sformatf(
                            "READ HIT MATCH: addr=%0d | expected=%h | actual=%h",
                            t.mem_addr,
                            expected_data[t.mem_addr],
                            t.cache_o
                        ),
                        UVM_LOW
                    );

                end
                else begin

                    `uvm_error(
                        "SB",
                        $sformatf(
                            "READ HIT MISMATCH: addr=%0d | expected=%h | actual=%h",
                            t.mem_addr,
                            expected_data[t.mem_addr],
                            t.cache_o
                        )
                    );

                end

            end


            // =================================================
            // EXPECTED MISS
            // =================================================
            else begin

                if (t.cache_o == 32'h0000_0000) begin

                    `uvm_info(
                        "SB",
                        $sformatf(
                            "READ MISS MATCH: addr=%0d | expected=00000000 | actual=%h",
                            t.mem_addr,
                            t.cache_o
                        ),
                        UVM_LOW
                    );

                end
                else begin

                    `uvm_error(
                        "SB",
                        $sformatf(
                            "READ MISS MISMATCH: addr=%0d | expected=00000000 | actual=%h",
                            t.mem_addr,
                            t.cache_o
                        )
                    );

                end

            end

        end

    endfunction

endclass
