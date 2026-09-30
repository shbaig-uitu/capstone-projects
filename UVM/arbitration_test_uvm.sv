class arbitration_test_uvm extends uvm_test;

    `uvm_component_utils(arbitration_test_uvm)

    soc_env_uvm env;

    function new(string name = "arbitration_test_uvm",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = soc_env_uvm::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);

        core_sequence_uvm core0_seq;
        core_sequence_uvm core1_seq;

        phase.raise_objection(this);

        // Wait until RTL reset is finished
        wait (env.core0_agent.driver.vif.reset == 0);
        @(posedge env.core0_agent.driver.vif.clk);

        core0_seq =
            core_sequence_uvm::type_id::create("core0_seq");

        core1_seq =
            core_sequence_uvm::type_id::create("core1_seq");


        // Core0 write request
        core0_seq.do_read  = 0;
        core0_seq.do_write = 1;
        core0_seq.addr     = 32'h0000_0010;
        core0_seq.data     = 32'hAAAA_1111;


        // Core1 write request
        core1_seq.do_read  = 0;
        core1_seq.do_write = 1;
        core1_seq.addr     = 32'h0000_0020;
        core1_seq.data     = 32'hBBBB_2222;


        `uvm_info(
            "TEST",
            "Starting simultaneous Core0 and Core1 SRAM requests",
            UVM_LOW
        )


        // Start both requests concurrently
        fork

            core0_seq.start(
                env.core0_agent.sequencer
            );

            core1_seq.start(
                env.core1_agent.sequencer
            );

        join


        #20;

        phase.drop_objection(this);

    endtask

endclass