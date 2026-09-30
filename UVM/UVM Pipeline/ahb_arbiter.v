module ahb_arbiter (
    HCLK,
    HRESETn,

    // Core 0 side
    HADDR0,
    HWRITE0,
    HTRANS0,
    HSIZE0,
    HWDATA0,
    HREADY0,

    // Core 1 side
    HADDR1,
    HWRITE1,
    HTRANS1,
    HSIZE1,
    HWDATA1,
    HREADY1,

    // Shared, arbitrated output to decoder/slave side
    HADDR,
    HWRITE,
    HTRANS,
    HSIZE,
    HWDATA,

    // Common response, broadcast back
    HRDATA,
    HREADY,
    HRESP
);
    input wire HCLK;
    input wire HRESETn;

    input wire [31:0] HADDR0;
    input wire        HWRITE0;
    input wire [1:0]  HTRANS0;
    input wire [2:0]  HSIZE0;
    input wire [31:0] HWDATA0;
    output wire       HREADY0;

    input wire [31:0] HADDR1;
    input wire        HWRITE1;
    input wire [1:0]  HTRANS1;
    input wire [2:0]  HSIZE1;
    input wire [31:0] HWDATA1;
    output wire       HREADY1;

    output reg [31:0] HADDR;
    output reg        HWRITE;
    output reg [1:0]  HTRANS;
    output reg [2:0]  HSIZE;
    output reg [31:0] HWDATA;

    input wire [31:0] HRDATA;
    input wire        HREADY;
    input wire        HRESP;

    parameter IDLE = 2'b00;

    wire req0 = (HTRANS0 != IDLE);
    wire req1 = (HTRANS1 != IDLE);

    wire grant0 = req0;
    wire grant1 = req1 && !req0;

    always @(*) begin
        if (grant0) begin
            HADDR  = HADDR0;
            HWRITE = HWRITE0;
            HTRANS = HTRANS0;
            HSIZE  = HSIZE0;
            HWDATA = HWDATA0;
        end
        else if (grant1) begin
            HADDR  = HADDR1;
            HWRITE = HWRITE1;
            HTRANS = HTRANS1;
            HSIZE  = HSIZE1;
            HWDATA = HWDATA1;
        end
        else begin
            HADDR  = 32'b0;
            HWRITE = 1'b0;
            HTRANS = IDLE;
            HSIZE  = 3'b0;
            HWDATA = 32'b0;
        end
    end

    assign HREADY0 = grant0 ? HREADY : 1'b0;
    assign HREADY1 = grant1 ? HREADY : 1'b0;

endmodule
