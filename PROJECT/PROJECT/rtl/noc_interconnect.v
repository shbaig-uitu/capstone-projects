`timescale 1ns/1ps

module noc_interconnect (

    input wire clk,
    input wire rst,

    // =====================================================
    // CORE 0 AHB-LITE MASTER
    // =====================================================
    input wire [31:0] haddr0,
    input wire [31:0] hwdata0,
    input wire        hwrite0,
    input wire [1:0]  htrans0,

    output reg [31:0] hrdata0,
    output reg        hready0,
    output reg        hresp0,

    // =====================================================
    // CORE 1 AHB-LITE MASTER
    // =====================================================
    input wire [31:0] haddr1,
    input wire [31:0] hwdata1,
    input wire        hwrite1,
    input wire [1:0]  htrans1,

    output reg [31:0] hrdata1,
    output reg        hready1,
    output reg        hresp1,

    // =====================================================
    // GPIO OUTPUT
    // =====================================================
    output wire [31:0] gpio_out,

    // =====================================================
    // UART OUTPUT
    // =====================================================
    output wire [7:0] uart_tx_data,
    output wire       uart_tx_valid

);

    // =====================================================
    // REQUEST DETECTION
    // =====================================================

    wire req0;
    wire req1;

    assign req0 = (htrans0 == 2'b10);
    assign req1 = (htrans1 == 2'b10);


    // =====================================================
    // ARBITER SIGNALS
    // =====================================================

    wire arb_grant0;
    wire arb_grant1;


    // =====================================================
    // TRANSACTION LOCK REGISTERS
    // =====================================================

    reg active;
    reg owner;

    reg [31:0] trans_addr;
    reg [31:0] trans_wdata;
    reg        trans_write;


    // =====================================================
    // SLAVE RESPONSE SIGNALS
    // IMPORTANT: Declared BEFORE being used
    // =====================================================

    reg [31:0] slave_rdata;
    reg        slave_ready;
    reg        slave_error;


    // =====================================================
    // ARBITER
    // =====================================================

    round_robin_arbiter arbiter_inst (

        .clk(clk),
        .rst(rst),

        .req0(req0),
        .req1(req1),

        .grant0(arb_grant0),
        .grant1(arb_grant1)

    );


    // =====================================================
    // TRANSACTION CONTROL
    // =====================================================

    always @(posedge clk) begin

        if (rst) begin

            active      <= 1'b0;
            owner       <= 1'b0;

            trans_addr  <= 32'b0;
            trans_wdata <= 32'b0;
            trans_write <= 1'b0;

        end

        else begin

            // =============================================
            // NO ACTIVE TRANSACTION
            // =============================================

            if (!active) begin

                // Core 0 selected
                if (arb_grant0) begin

                    active      <= 1'b1;
                    owner       <= 1'b0;

                    trans_addr  <= haddr0;
                    trans_wdata <= hwdata0;
                    trans_write <= hwrite0;

                end

                // Core 1 selected
                else if (arb_grant1) begin

                    active      <= 1'b1;
                    owner       <= 1'b1;

                    trans_addr  <= haddr1;
                    trans_wdata <= hwdata1;
                    trans_write <= hwrite1;

                end

            end


            // =============================================
            // ACTIVE TRANSACTION
            // =============================================

            else begin

                // Transaction complete
                if (slave_ready) begin

                    active <= 1'b0;

                end

            end

        end

    end


    // =====================================================
    // ADDRESS DECODER SIGNALS
    // =====================================================

    wire sel_shared_ram;
    wire sel_mailbox;
    wire sel_gpio;
    wire sel_uart;
    wire sel_error;


    // =====================================================
    // ADDRESS DECODER
    // =====================================================

    address_decoder decoder_inst (

        .addr(trans_addr),

        .sel_shared_ram(sel_shared_ram),
        .sel_mailbox(sel_mailbox),
        .sel_gpio(sel_gpio),
        .sel_uart(sel_uart),
        .sel_error(sel_error)

    );


    // =====================================================
    // SHARED SRAM SIGNALS
    // =====================================================

    wire [31:0] sram_rdata;
    wire        sram_ready;
    wire        sram_error;


    // =====================================================
    // SHARED SRAM
    // =====================================================

    shared_sram shared_sram_inst (

        .clk(clk),
        .rst(rst),

        .req(active && sel_shared_ram),
        .write_en(trans_write),

        .addr(trans_addr),
        .wdata(trans_wdata),

        .rdata(sram_rdata),
        .ready(sram_ready),
        .error(sram_error)

    );


    // =====================================================
    // MAILBOX SIGNALS
    // =====================================================

    wire [31:0] mailbox_rdata;
    wire        mailbox_ready;
    wire        mailbox_error;


    // =====================================================
    // MAILBOX
    // =====================================================

    mailbox_unit mailbox_inst (

        .clk(clk),
        .rst(rst),

        .req(active && sel_mailbox),
        .write_en(trans_write),

        .addr(trans_addr),
        .wdata(trans_wdata),

        .rdata(mailbox_rdata),
        .ready(mailbox_ready),
        .error(mailbox_error)

    );


    // =====================================================
    // GPIO SIGNALS
    // =====================================================

    wire [31:0] gpio_rdata;
    wire        gpio_ready;
    wire        gpio_error;


    // =====================================================
    // GPIO
    // =====================================================

    gpio gpio_inst (

        .clk(clk),
        .rst(rst),

        .req(active && sel_gpio),
        .write_en(trans_write),

        .addr(trans_addr),
        .wdata(trans_wdata),

        .rdata(gpio_rdata),
        .ready(gpio_ready),
        .error(gpio_error),

        .gpio_out(gpio_out)

    );


    // =====================================================
    // UART SIGNALS
    // =====================================================

    wire [31:0] uart_rdata;
    wire        uart_ready;
    wire        uart_error;


    // =====================================================
    // UART
    // =====================================================

    simple_uart uart_inst (

        .clk(clk),
        .rst(rst),

        .req(active && sel_uart),
        .write_en(trans_write),

        .addr(trans_addr),
        .wdata(trans_wdata),

        .rdata(uart_rdata),
        .ready(uart_ready),
        .error(uart_error),

        .uart_tx_data(uart_tx_data),
        .uart_tx_valid(uart_tx_valid)

    );


    // =====================================================
    // SLAVE RESPONSE MUX
    // =====================================================

    always @(*) begin

        // Default values
        slave_rdata = 32'b0;
        slave_ready = 1'b0;
        slave_error = 1'b0;


        // ---------------------------------------------
        // SHARED SRAM
        // ---------------------------------------------

        if (sel_shared_ram) begin

            slave_rdata = sram_rdata;
            slave_ready = sram_ready;
            slave_error = sram_error;

        end


        // ---------------------------------------------
        // MAILBOX
        // ---------------------------------------------

        else if (sel_mailbox) begin

            slave_rdata = mailbox_rdata;
            slave_ready = mailbox_ready;
            slave_error = mailbox_error;

        end


        // ---------------------------------------------
        // GPIO
        // ---------------------------------------------

        else if (sel_gpio) begin

            slave_rdata = gpio_rdata;
            slave_ready = gpio_ready;
            slave_error = gpio_error;

        end


        // ---------------------------------------------
        // UART
        // ---------------------------------------------

        else if (sel_uart) begin

            slave_rdata = uart_rdata;
            slave_ready = uart_ready;
            slave_error = uart_error;

        end


        // ---------------------------------------------
        // INVALID ADDRESS
        // ---------------------------------------------

        else if (active && sel_error) begin

            slave_rdata = 32'b0;
            slave_ready = 1'b1;
            slave_error = 1'b1;

        end

    end


    // =====================================================
    // RESPONSE ROUTING
    // =====================================================

    always @(*) begin

        // =============================================
        // DEFAULT CORE 0 RESPONSE
        // =============================================

        hrdata0 = 32'b0;
        hready0 = 1'b0;
        hresp0  = 1'b0;


        // =============================================
        // DEFAULT CORE 1 RESPONSE
        // =============================================

        hrdata1 = 32'b0;
        hready1 = 1'b0;
        hresp1  = 1'b0;


        // =============================================
        // ROUTE RESPONSE TO TRANSACTION OWNER
        // =============================================

        if (active) begin

            // -----------------------------------------
            // CORE 0 OWNS TRANSACTION
            // -----------------------------------------

            if (owner == 1'b0) begin

                hrdata0 = slave_rdata;
                hready0 = slave_ready;
                hresp0  = slave_error;

            end


            // -----------------------------------------
            // CORE 1 OWNS TRANSACTION
            // -----------------------------------------

            else begin

                hrdata1 = slave_rdata;
                hready1 = slave_ready;
                hresp1  = slave_error;

            end

        end

    end

endmodule
