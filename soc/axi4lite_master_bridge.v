// axi4lite_master_bridge.v
module axi4lite_master_bridge (
    input  wire        clk, rst,
    input  wire        cpu_req,     
    input  wire [31:0] cpu_addr,
    input  wire [31:0] cpu_wdata,
    input  wire        cpu_we,
    output wire [31:0] cpu_rdata,  // Changed to wire for combinational bypass
    output wire        cpu_stall,  // Changed to wire for immediate stall
    
    // AXI4-Lite Master Interface
    output reg  [31:0] awaddr,
    output reg         awvalid,
    input  wire        awready,
    output reg  [31:0] wdata,
    output reg         wvalid,
    input  wire        wready,
    input  wire        bvalid,
    output reg         bready,
    output reg  [31:0] araddr,
    output reg         arvalid,
    input  wire        arready,
    input  wire [31:0] rdata,
    input  wire        rvalid,
    output reg         rready
);

    localparam IDLE = 0, WR_ADDR = 1, WR_DATA = 2, WR_RESP = 3;
    localparam RD_ADDR = 4, RD_DATA = 5;
    reg [2:0] state;

    // Combinational stall: freeze CPU if there's a request, UNLESS it's the exact cycle it finishes.
    wire write_done = (state == WR_RESP && bvalid);
    wire read_done  = (state == RD_DATA && rvalid);
    assign cpu_stall = cpu_req && !(write_done || read_done);
    
    // Combinational read data bypass so CPU regfile captures it on the finishing edge
    assign cpu_rdata = (state == RD_DATA && rvalid) ? rdata : 32'd0;

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            {awvalid, wvalid, bready, arvalid, rready} <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (cpu_req) begin
                        if (cpu_we) begin
                            awaddr <= cpu_addr; awvalid <= 1; state <= WR_ADDR;
                        end else begin
                            araddr <= cpu_addr; arvalid <= 1; state <= RD_ADDR;
                        end
                    end
                end
                
                WR_ADDR: if (awready) begin 
                    awvalid <= 0; wdata <= cpu_wdata; wvalid <= 1; state <= WR_DATA; 
                end
                WR_DATA: if (wready) begin 
                    wvalid <= 0; bready <= 1; state <= WR_RESP; 
                end
                WR_RESP: if (bvalid) begin 
                    bready <= 0; state <= IDLE; 
                end
                
                RD_ADDR: if (arready) begin 
                    arvalid <= 0; rready <= 1; state <= RD_DATA; 
                end
                RD_DATA: if (rvalid) begin 
                    rready <= 0; state <= IDLE; 
                end
            endcase
        end
    end
endmodule
