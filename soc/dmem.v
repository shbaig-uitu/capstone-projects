// dmem.v - Data Memory (byte-addressable, 1 KB)
// 4 byte lanes to infer Xilinx Distributed RAM (RAM64M)
// Synchronous write, asynchronous read, byte/half/word via funct3
module dmem #(parameter DEPTH = 256) (
    input  wire        clk,
    input  wire        we,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    input  wire [ 2:0] funct3,
    output reg  [31:0] rdata
);
    // 4 byte lanes of 256 bytes each = 1024 bytes (1 KB)
    // Synchronous write, asynchronous read enables LUTRAM inference
    (* ram_style = "distributed" *) reg [7:0] mem0 [0:DEPTH-1];
    (* ram_style = "distributed" *) reg [7:0] mem1 [0:DEPTH-1];
    (* ram_style = "distributed" *) reg [7:0] mem2 [0:DEPTH-1];
    (* ram_style = "distributed" *) reg [7:0] mem3 [0:DEPTH-1];

    wire [7:0] word_idx = addr[9:2];
    wire [1:0] byte_off = addr[1:0];

    // Byte write enables based on funct3 and address offset
    reg [3:0] byte_we;
    always @(*) begin
        byte_we = 4'b0000;
        if (we) begin
            case (funct3)
                3'b000: begin // SB - store byte
                    case (byte_off)
                        2'b00: byte_we = 4'b0001;
                        2'b01: byte_we = 4'b0010;
                        2'b10: byte_we = 4'b0100;
                        2'b11: byte_we = 4'b1000;
                    endcase
                end
                3'b001: begin // SH - store half-word
                    if (byte_off[1] == 1'b0)
                        byte_we = 4'b0011;
                    else
                        byte_we = 4'b1100;
                end
                3'b010: begin // SW - store word
                    byte_we = 4'b1111;
                end
                default: byte_we = 4'b0000;
            endcase
        end
    end

    // Route write data to the appropriate lane
    wire [7:0] wdata0 = wdata[7:0];
    wire [7:0] wdata1 = (funct3 == 3'b000) ? wdata[7:0] : wdata[15:8];
    wire [7:0] wdata2 = (funct3 == 3'b010) ? wdata[23:16] : wdata[7:0];
    wire [7:0] wdata3 = (funct3 == 3'b010) ? wdata[31:24] :
                        (funct3 == 3'b001) ? wdata[15:8] : wdata[7:0];

    // Synchronous Writes
    always @(posedge clk) begin
        if (byte_we[0]) mem0[word_idx] <= wdata0;
        if (byte_we[1]) mem1[word_idx] <= wdata1;
        if (byte_we[2]) mem2[word_idx] <= wdata2;
        if (byte_we[3]) mem3[word_idx] <= wdata3;
    end

    // Asynchronous Reads
    wire [7:0] b0 = mem0[word_idx];
    wire [7:0] b1 = mem1[word_idx];
    wire [7:0] b2 = mem2[word_idx];
    wire [7:0] b3 = mem3[word_idx];

    wire [7:0] sel_b = (byte_off == 2'b00) ? b0 :
                       (byte_off == 2'b01) ? b1 :
                       (byte_off == 2'b10) ? b2 : b3;

    wire [15:0] sel_h = (byte_off[1] == 1'b0) ? {b1, b0} : {b3, b2};

    always @(*) begin
        case (funct3)
            3'b000: rdata = {{24{sel_b[7]}}, sel_b}; // LB - sign-extend byte
            3'b001: rdata = {{16{sel_h[15]}}, sel_h}; // LH - sign-extend half-word
            3'b010: rdata = {b3, b2, b1, b0};         // LW - full word
            3'b100: rdata = {24'b0, sel_b};          // LBU - zero-extend byte
            3'b101: rdata = {16'b0, sel_h};          // LHU - zero-extend half-word
            default: rdata = 32'b0;
        endcase
    end
endmodule