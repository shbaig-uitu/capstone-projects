class core_sequence_uvm extends uvm_sequence #(core_transaction_uvm);

    `uvm_object_utils(core_sequence_uvm)

    bit        do_read;
    bit        do_write;
    bit [31:0] addr;
    bit [31:0] data;

    // Response information returned by the driver
    bit [31:0] response_data;
    bit        response_ready;

    // Useful for arbitration-order checking
    time start_time;
    time completion_time;

    function new(string name = "core_sequence_uvm");
        super.new(name);
    endfunction

    virtual task body();

        core_transaction_uvm req;

        req = core_transaction_uvm::type_id::create("req");

        start_time = $time;

        start_item(req);

        req.read       = do_read;
        req.write      = do_write;
        req.address    = addr;
        req.write_data = data;

        finish_item(req);

        response_data   = req.read_data;
        response_ready  = req.ready;
        completion_time = $time;

    endtask

endclass
