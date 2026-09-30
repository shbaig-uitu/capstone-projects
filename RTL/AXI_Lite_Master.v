`timescale 1ns / 1ps

module axi_lite_master (
    input  wire        ACLK,
    input  wire        ARESETN,
    input  wire        START_READ,
    input  wire        START_WRITE,
    input  wire [31:0] address,
    input  wire [31:0] W_data,
    
    // Processor Handshake Signals
    output wire        busy,            
    output wire [31:0] rd_data_out,  

    // AXI4-Lite Interface
    output reg  [31:0] ARADDR,
    output reg         ARVALID,
    input  wire        ARREADY,
    input  wire [31:0] RDATA,
    input  wire [1:0]  RRESP,
    input  wire        RVALID,
    output reg         RREADY,

    output reg  [31:0] AWADDR,
    output reg         AWVALID,
    input  wire        AWREADY,
    output reg  [31:0] WDATA,
    output reg  [3:0]  WSTRB,
    output reg         WVALID,
    input  wire        WREADY,
    input  wire [1:0]  BRESP,
    input  wire        BVALID,
    output reg         BREADY
);

    localparam IDLE          = 3'd0;
    localparam RADDR_CHANNEL = 3'd1;
    localparam RDATA_CHANNEL = 3'd2;
    localparam WRITE_CHANNEL = 3'd3;
    localparam WRESP_CHANNEL = 3'd4;

    reg [2:0]  state;
    reg [31:0] read_buf;
    reg [31:0] addr_latched;
    reg [31:0] data_latched;
    reg        aw_done, w_done;
    reg        busy_reg;

    // Busy remains asserted as long as state is not IDLE or a new request comes in
    assign busy = busy_reg || START_READ || START_WRITE;
    assign rd_data_out = read_buf;

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            state        <= IDLE;
            ARADDR       <= 32'b0;
            ARVALID      <= 1'b0;
            RREADY       <= 1'b0;
            AWADDR       <= 32'b0;
            AWVALID      <= 1'b0;
            WDATA        <= 32'b0;
            WSTRB        <= 4'b0;
            WVALID       <= 1'b0;
            BREADY       <= 1'b0;
            read_buf     <= 32'b0;
            addr_latched <= 32'b0;
            data_latched <= 32'b0;
            aw_done      <= 1'b0;
            w_done       <= 1'b0;
            busy_reg     <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    ARVALID  <= 1'b0;
                    RREADY   <= 1'b0;
                    AWVALID  <= 1'b0;
                    WVALID   <= 1'b0;
                    BREADY   <= 1'b0;
                    aw_done  <= 1'b0;
                    w_done   <= 1'b0;

                    if (START_READ) begin
                        busy_reg     <= 1'b1;
                        addr_latched <= address;
                        ARADDR       <= address;
                        ARVALID      <= 1'b1;
                        state        <= RADDR_CHANNEL;
                    end else if (START_WRITE) begin
                        busy_reg     <= 1'b1;
                        addr_latched <= address;
                        data_latched <= W_data;
                        AWADDR       <= address;
                        AWVALID      <= 1'b1;
                        WDATA        <= W_data;
                        WSTRB        <= 4'b1111;
                        WVALID       <= 1'b1;
                        state        <= WRITE_CHANNEL;
                    end else begin
                        busy_reg     <= 1'b0;
                    end
                end

                RADDR_CHANNEL: begin
                    busy_reg <= 1'b1;
                    if (ARVALID && ARREADY) begin
                        ARVALID <= 1'b0;
                        RREADY  <= 1'b1;
                        state   <= RDATA_CHANNEL;
                    end
                end

                RDATA_CHANNEL: begin
                    busy_reg <= 1'b1;
                    if (RVALID && RREADY) begin
                        read_buf <= RDATA;
                        RREADY   <= 1'b0;
                        busy_reg <= 1'b0;
                        state    <= IDLE;
                    end
                end

                WRITE_CHANNEL: begin
                    busy_reg <= 1'b1;
                    if (AWVALID && AWREADY) begin
                        AWVALID <= 1'b0;
                        aw_done <= 1'b1;
                    end
                    if (WVALID && WREADY) begin
                        WVALID  <= 1'b0;
                        w_done  <= 1'b1;
                    end

                    if ((aw_done || (AWVALID && AWREADY)) && (w_done || (WVALID && WREADY))) begin
                        BREADY <= 1'b1;
                        state  <= WRESP_CHANNEL;
                    end
                end

                WRESP_CHANNEL: begin
                    busy_reg <= 1'b1;
                    if (BVALID && BREADY) begin
                        BREADY   <= 1'b0;
                        aw_done  <= 1'b0;
                        w_done   <= 1'b0;
                        busy_reg <= 1'b0;
                        state    <= IDLE;
                    end
                end

                default: begin
                    busy_reg <= 1'b0;
                    state    <= IDLE;
                end
            endcase
        end
    end

endmodule
