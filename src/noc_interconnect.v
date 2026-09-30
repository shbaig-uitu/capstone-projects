module noc_interconnect(
    input clk,
    input reset,

    
    
    

    input        core0_read,
    input        core0_write,
    input [3:0]  core0_write_strobe,
    input [31:0] core0_address,
    input [31:0] core0_write_data,

    output reg [31:0] core0_read_data,
    output reg        core0_ready,

    
    
    

    input        core1_read,
    input        core1_write,
    input [3:0]  core1_write_strobe,
    input [31:0] core1_address,
    input [31:0] core1_write_data,

    output reg [31:0] core1_read_data,
    output reg        core1_ready,

    
    
    

    output reg        mem_read,
    output reg        mem_write,
    output reg [3:0]  mem_write_strobe,
    output reg [31:0] mem_address,
    output reg [31:0] mem_write_data,

    input [31:0] mem_read_data,
    input        mem_ready,

    
    
    

    output reg        mailbox_read,
    output reg        mailbox_write,
    output reg [31:0] mailbox_address,
    output reg [31:0] mailbox_write_data,

    input [31:0] mailbox_read_data,

    
    
    

    output reg        uart_read,
    output reg        uart_write,
    output reg [3:0]  uart_write_strobe,
    output reg [31:0] uart_address,
    output reg [31:0] uart_write_data,

    input [31:0] uart_read_data,
    input        uart_ready,
    input        uart_error
);

wire core0_request;
wire core1_request;

assign core0_request =
    core0_read | core0_write;

assign core1_request =
    core1_read | core1_write;

reg last_grant;
reg grant_core;

reg uart_lock;
reg uart_owner;
reg mem_lock;
reg mem_owner;

reg        selected_read;
reg        selected_write;
reg [3:0]  selected_write_strobe;
reg [31:0] selected_address;
reg [31:0] selected_write_data;

wire selected_is_sram;

assign selected_is_sram =
    (selected_address[31:8] == 24'b0);

wire selected_is_mailbox;

assign selected_is_mailbox =
    (selected_address == 32'h00001000) ||
    (selected_address == 32'h00001004);

wire selected_is_uart;

assign selected_is_uart =
    (selected_address == 32'h00002000) ||
    (selected_address == 32'h00002004) ||
    (selected_address == 32'h00002008);

always @(*) begin

    
    grant_core = 1'b0;

    
    
    

    if (uart_lock) begin

        grant_core = uart_owner;

    end

    else if (mem_lock) begin

        grant_core = mem_owner;

    end

    
    
    

    else begin

        
        if (core0_request && !core1_request) begin

            grant_core = 1'b0;

        end

        
        else if (!core0_request && core1_request) begin

            grant_core = 1'b1;

        end

        
        else if (core0_request && core1_request) begin

            
            

            if (last_grant == 1'b0)
                grant_core = 1'b1;
            else
                grant_core = 1'b0;

        end

    end

end

always @(*) begin

    selected_read         = 1'b0;
    selected_write        = 1'b0;
    selected_write_strobe = 4'b0000;
    selected_address      = 32'b0;
    selected_write_data   = 32'b0;

    
    
    

    if (grant_core == 1'b0) begin

        selected_read =
            core0_read;

        selected_write =
            core0_write;

        selected_write_strobe =
            core0_write_strobe;

        selected_address =
            core0_address;

        selected_write_data =
            core0_write_data;

    end

    
    
    

    else begin

        selected_read =
            core1_read;

        selected_write =
            core1_write;

        selected_write_strobe =
            core1_write_strobe;

        selected_address =
            core1_address;

        selected_write_data =
            core1_write_data;

    end

end

always @(*) begin

    
    
    

    core0_read_data = 32'b0;
    core1_read_data = 32'b0;

    core0_ready = 1'b0;
    core1_ready = 1'b0;

    
    
    

    mem_read         = 1'b0;
    mem_write        = 1'b0;
    mem_write_strobe = 4'b0000;

    mem_address      = 32'b0;
    mem_write_data   = 32'b0;

    
    
    

    mailbox_read       = 1'b0;
    mailbox_write      = 1'b0;

    mailbox_address    = 32'b0;
    mailbox_write_data = 32'b0;

    
    
    

    uart_read         = 1'b0;
    uart_write        = 1'b0;
    uart_write_strobe = 4'b0000;

    uart_address      = 32'b0;
    uart_write_data   = 32'b0;

    
    
    

    if (core0_request ||
        core1_request ||
        uart_lock ||
        mem_lock) begin

        
        
        

        if (selected_is_sram) begin

            mem_read =
                selected_read;

            mem_write =
                selected_write;

            mem_write_strobe =
                selected_write_strobe;

            mem_address =
                selected_address;

            mem_write_data =
                selected_write_data;

            
            
            

            if (grant_core == 1'b0) begin

                core0_read_data =
                    mem_read_data;

                core0_ready =
                    mem_ready;

            end

            else begin

                core1_read_data =
                    mem_read_data;

                core1_ready =
                    mem_ready;

            end

        end

        
        
        

        else if (selected_is_mailbox) begin

            mailbox_read =
                selected_read;

            mailbox_write =
                selected_write;

            mailbox_address =
                selected_address;

            mailbox_write_data =
                selected_write_data;

            
            
            

            if (grant_core == 1'b0) begin

                core0_read_data =
                    mailbox_read_data;

                core0_ready =
                    1'b1;

            end

            else begin

                core1_read_data =
                    mailbox_read_data;

                core1_ready =
                    1'b1;

            end

        end

        
        
        

        else if (selected_is_uart) begin

            uart_read =
                selected_read;

            uart_write =
                selected_write;

            uart_write_strobe =
                selected_write_strobe;

            uart_address =
                selected_address;

            uart_write_data =
                selected_write_data;

            
            
            

            if (grant_core == 1'b0) begin

                core0_read_data =
                    uart_read_data;

                core0_ready =
                    uart_ready;

            end

            else begin

                core1_read_data =
                    uart_read_data;

                core1_ready =
                    uart_ready;

            end

        end

        
        
        

        else begin

            

            if (grant_core == 1'b0) begin

                core0_read_data =
                    32'b0;

                core0_ready =
                    1'b1;

            end

            else begin

                core1_read_data =
                    32'b0;

                core1_ready =
                    1'b1;

            end

        end

    end

end

always @(posedge clk) begin

    if (reset) begin

        last_grant <= 1'b0;

        uart_lock  <= 1'b0;
        uart_owner <= 1'b0;

        mem_lock   <= 1'b0;
        mem_owner  <= 1'b0;

    end

    else begin

        if (mem_lock) begin

            if (mem_ready) begin

                mem_lock <= 1'b0;

            end

        end

        else if (!uart_lock &&
                 (core0_request || core1_request) &&
                 selected_is_sram) begin

            mem_lock  <= 1'b1;
            mem_owner <= grant_core;

        end

        
        
        

        if (uart_lock) begin

            
            if (uart_ready) begin

                uart_lock <= 1'b0;

            end

        end

        else if (!mem_lock) begin

            
            
            
            

            if ((core0_request || core1_request) &&
                selected_is_uart) begin

                uart_lock  <= 1'b1;
                uart_owner <= grant_core;

            end

        end

        
        
        

        if (!uart_lock &&
            !mem_lock &&
            core0_request &&
            core1_request) begin

            last_grant <= grant_core;

        end

    end

end

endmodule

