module instruction_memory #(
    parameter INIT_FILE = "firmware.hex",
    parameter ADDR_WIDTH = 5
)(
    input         clk,

    
    input         boot_write,
    input  [7:0]  boot_address,
    input  [31:0] boot_write_data,

    
    input  [31:0] address,
    output reg [31:0] instruction
);

    
    
    
    

    localparam WORDS = (1 << ADDR_WIDTH);

    reg [31:0] memory [0:WORDS-1];

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    initial begin
        $readmemh(INIT_FILE, memory);
    end

    
    
    
    
    
    
    
    
    
    

    always @(posedge clk) begin
        instruction <= memory[address[ADDR_WIDTH+1:2]];
    end

    
    
    

    always @(posedge clk) begin
        if (boot_write)
            memory[boot_address[ADDR_WIDTH-1:0]] <= boot_write_data;
    end

endmodule

