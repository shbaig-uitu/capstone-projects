module ahb_decoder (
    HADDR,
    HWRITE,
    HTRANS,
    HSIZE,
    HWDATA,
    HRDATA,
    HREADY,
    HRESP,

    HADDR_mem,
    HWRITE_mem,
    HTRANS_mem,
    HSIZE_mem,
    HWDATA_mem,
    HRDATA_mem,
    HREADY_mem,
    HRESP_mem
);
    input  wire [31:0] HADDR;
    input  wire        HWRITE;
    input  wire [1:0]  HTRANS;
    input  wire [2:0]  HSIZE;
    input  wire [31:0] HWDATA;
    output reg  [31:0] HRDATA;
    output reg         HREADY;
    output reg         HRESP;

    output wire [31:0] HADDR_mem;
    output wire        HWRITE_mem;
    output wire [1:0]  HTRANS_mem;
    output wire [2:0]  HSIZE_mem;
    output wire [31:0] HWDATA_mem;
    input  wire [31:0] HRDATA_mem;
    input  wire        HREADY_mem;
    input  wire        HRESP_mem;

    parameter IDLE = 2'b00;

    wire sel_mem = (HADDR[15:8] == 8'h00);

    assign HADDR_mem  = HADDR;
    assign HWRITE_mem = HWRITE;
    assign HTRANS_mem = sel_mem ? HTRANS : IDLE;
    assign HSIZE_mem  = HSIZE;
    assign HWDATA_mem = HWDATA;

    always @(*) begin
        if (sel_mem) begin
            HRDATA = HRDATA_mem;
            HREADY = HREADY_mem;
            HRESP  = HRESP_mem;
        end
        else begin
            HRDATA = 32'b0;
            HREADY = 1'b1;
            HRESP  = 1'b1;
        end
    end

endmodule
