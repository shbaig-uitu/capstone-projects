
interface axi_if (input logic clk);
    logic rst;
    // Write Address Channel
    logic [31:0] awaddr;
    logic        awvalid;
    logic        awready;
    // Write Data Channel
    logic [31:0] wdata;
    logic        wvalid;
    logic        wready;
    // Write Response Channel
    logic        bvalid;
    logic        bready;
    // Read Address Channel
    logic [31:0] araddr;
    logic        arvalid;
    logic        arready;
    // Read Data Channel
    logic [31:0] rdata;
    logic        rvalid;
    logic        rready;
endinterface