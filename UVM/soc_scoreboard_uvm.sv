`uvm_analysis_imp_decl(_core0)
`uvm_analysis_imp_decl(_core1)

class soc_scoreboard_uvm extends uvm_scoreboard;

    `uvm_component_utils(soc_scoreboard_uvm)

    uvm_analysis_imp_core0 #(core_transaction_uvm,
                             soc_scoreboard_uvm) core0_imp;

    uvm_analysis_imp_core1 #(core_transaction_uvm,
                             soc_scoreboard_uvm) core1_imp;

    // Reference model for shared SRAM
    bit [31:0] reference_memory [bit [31:0]];

    int writes;
    int reads;
    int match_count;
    int errors;


    function new(string name = "soc_scoreboard_uvm",
                 uvm_component parent = null);

        super.new(name, parent);

        core0_imp = new("core0_imp", this);
        core1_imp = new("core1_imp", this);

        writes      = 0;
        reads       = 0;
        match_count = 0;
        errors      = 0;

    endfunction


    function void write_core0(core_transaction_uvm tr);
        check_transaction(tr, 0);
    endfunction


    function void write_core1(core_transaction_uvm tr);
        check_transaction(tr, 1);
    endfunction


    function void check_transaction(
        core_transaction_uvm tr,
        int core_id
    );

        // Shared SRAM address range
        if (tr.address <= 32'h0000_0FFF) begin

            // WRITE
            if (tr.write) begin

                reference_memory[tr.address] = tr.write_data;
                writes++;

                `uvm_info(
                    "SCOREBOARD",
                    $sformatf(
                        "CORE%0d WRITE: ADDR=%08h DATA=%08h",
                        core_id,
                        tr.address,
                        tr.write_data
                    ),
                    UVM_LOW
                )

            end

            // READ
            else if (tr.read) begin

                reads++;

                if (reference_memory.exists(tr.address)) begin

                    if (tr.read_data ==
                        reference_memory[tr.address]) begin

                        match_count++;

                        `uvm_info(
                            "SCOREBOARD",
                            $sformatf(
                                "PASS CORE%0d READ: ADDR=%08h EXPECTED=%08h ACTUAL=%08h",
                                core_id,
                                tr.address,
                                reference_memory[tr.address],
                                tr.read_data
                            ),
                            UVM_LOW
                        )

                    end
                    else begin

                        errors++;

                        `uvm_error(
                            "SCOREBOARD",
                            $sformatf(
                                "FAIL CORE%0d READ: ADDR=%08h EXPECTED=%08h ACTUAL=%08h",
                                core_id,
                                tr.address,
                                reference_memory[tr.address],
                                tr.read_data
                            )
                        )

                    end

                end
                else begin

                    `uvm_warning(
                        "SCOREBOARD",
                        $sformatf(
                            "CORE%0d read from unwritten address %08h",
                            core_id,
                            tr.address
                        )
                    )

                end

            end

        end

    endfunction


    function void report_phase(uvm_phase phase);

        super.report_phase(phase);

        `uvm_info(
            "SCOREBOARD_SUMMARY",
            $sformatf(
                "WRITES=%0d READS=%0d MATCHES=%0d ERRORS=%0d",
                writes,
                reads,
                match_count,
                errors
            ),
            UVM_NONE
        )

    endfunction

endclass