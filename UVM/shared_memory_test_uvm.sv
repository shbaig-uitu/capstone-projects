class shared_memory_test_uvm extends uvm_test;

    `uvm_component_utils(shared_memory_test_uvm)

    soc_env_uvm env;

    function new(string name = "shared_memory_test_uvm",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = soc_env_uvm::type_id::create("env", this);
    endfunction


    task run_phase(uvm_phase phase);

        core_sequence_uvm write_seq;
        core_sequence_uvm read_seq;

        phase.raise_objection(this);


        // -----------------------------------------
        // Wait until DUT reset is deasserted
        // -----------------------------------------
        wait (env.core0_agent.driver.vif.reset == 0);

        // One extra clock for safe start
        @(posedge env.core0_agent.driver.vif.clk);


        // -----------------------------------------
        // CORE0 WRITE
        // -----------------------------------------
        write_seq = core_sequence_uvm::type_id::create("write_seq");

        write_seq.do_read  = 0;
        write_seq.do_write = 1;
        write_seq.addr     = 32'h0000_0010;
        write_seq.data     = 32'h1234_5678;

        `uvm_info(
            "TEST",
            "Core0 writing 0x12345678 to address 0x00000010",
            UVM_LOW
        )

        write_seq.start(env.core0_agent.sequencer);


        // -----------------------------------------
        // CORE1 READ
        // -----------------------------------------
        read_seq = core_sequence_uvm::type_id::create("read_seq");

        read_seq.do_read  = 1;
        read_seq.do_write = 0;
        read_seq.addr     = 32'h0000_0010;
        read_seq.data     = 32'h0000_0000;

        `uvm_info(
            "TEST",
            "Core1 reading address 0x00000010",
            UVM_LOW
        )

        read_seq.start(env.core1_agent.sequencer);


        // Allow monitor / scoreboard to finish
        #20;


        phase.drop_objection(this);

    endtask

endclass