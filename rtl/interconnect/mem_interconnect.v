// Native RV32I bus interconnect and AXI4-Lite write/read adapter.
//
// Memory map:
//   0x0000_0000 - 0x0000_7FFF : instruction SRAM (32 KiB)
//   0x0000_8000 - 0x0000_FFFF : data SRAM        (32 KiB)
//   FB_BASE .. FB_BASE+0x4AFFF       : framebuffer (307200 bytes; FB_BASE is programmable)
//   0x1000_0000 - 0x1000_00FF : VGA registers    (AXI4-Lite)
//
// The CPU is the only native-bus master, so a small FSM is enough. VGA reads
// the framebuffer through the second RAM port and never needs arbitration.
module mem_interconnect #(
    parameter FRAME_WIDTH  = 640,
    parameter FRAME_HEIGHT = 480
)(
    input wire clk,
    input wire rst_n,
    input wire mem_valid,
    output reg mem_ready,
    input wire [31:0] mem_addr,
    input wire [31:0] mem_wdata,
    input wire [3:0] mem_wstrb,
    output reg [31:0] mem_rdata,

    output wire imem_valid,
    input wire imem_ready,
    output wire [31:0] imem_addr,
    input wire [31:0] imem_rdata,

    output wire dmem_valid,
    input wire dmem_ready,
    output wire [31:0] dmem_addr,
    output wire [31:0] dmem_wdata,
    output wire [3:0] dmem_wstrb,
    input wire [31:0] dmem_rdata,

    output reg [3:0] fb_we,
    output reg [$clog2(FRAME_WIDTH*FRAME_HEIGHT)-1:0] fb_addr,
    output reg [31:0] fb_wdata,
    input wire [7:0] fb_rdata,
    input wire [31:0] fb_base_reg,

    // AXI4-Lite master-side signals to the VGA register block.
    output reg [31:0] vga_awaddr,
    output reg vga_awvalid,
    input wire vga_awready,
    output reg [31:0] vga_wdata,
    output reg [3:0] vga_wstrb,
    output reg vga_wvalid,
    input wire vga_wready,
    input wire [1:0] vga_bresp,
    input wire vga_bvalid,
    output reg vga_bready,
    output reg [31:0] vga_araddr,
    output reg vga_arvalid,
    input wire vga_arready,
    input wire [31:0] vga_rdata,
    input wire [1:0] vga_rresp,
    input wire vga_rvalid,
    output reg vga_rready
);
    localparam IMEM_BASE = 32'h0000_0000;
    localparam IMEM_SIZE = 32'h0000_8000;
    localparam DMEM_BASE = 32'h0000_8000;
    localparam DMEM_SIZE = 32'h0000_8000;
    localparam FB_SIZE = FRAME_WIDTH * FRAME_HEIGHT;
    localparam VGA_BASE  = 32'h1000_0000;
    localparam VGA_SIZE  = 32'h0000_0100;

    localparam FB_ADDR_WIDTH = $clog2(FRAME_WIDTH * FRAME_HEIGHT);
    localparam ST_IDLE       = 3'd0;
    localparam ST_FB_RD      = 3'd1;
    localparam ST_FB_RD_WAIT = 3'd2;
    localparam ST_AXI_W      = 3'd3;
    localparam ST_AXI_R      = 3'd4;	
    localparam ST_AXI_B      = 3'd5;
    localparam ST_HOLD       = 3'd6;

    reg [2:0] state;
    wire is_write = |mem_wstrb;
    wire [31:0] fb_offset = mem_addr - fb_base_reg;

    wire sel_imem = (mem_addr >= IMEM_BASE) && (mem_addr < IMEM_BASE + IMEM_SIZE);
    wire sel_dmem = (mem_addr >= DMEM_BASE) && (mem_addr < DMEM_BASE + DMEM_SIZE);
    wire sel_fb   = (mem_addr >= fb_base_reg) && (mem_addr < fb_base_reg + FB_SIZE);
    wire sel_vga  = (mem_addr >= VGA_BASE)  && (mem_addr < VGA_BASE + VGA_SIZE);

    assign imem_valid = mem_valid && sel_imem && (state == ST_IDLE);
    assign imem_addr  = mem_addr;

    assign dmem_valid = mem_valid && sel_dmem && (state == ST_IDLE);
    assign dmem_addr  = mem_addr - DMEM_BASE;
    assign dmem_wdata = mem_wdata;
    assign dmem_wstrb = mem_wstrb;

    // The CPU bus uses byte addresses while the framebuffer write strobes are
    // word-lane strobes. Align the RAM address to the containing 32-bit word so
    // an SB/SH at an offset such as FB+5 writes the requested byte(s), not a
    // byte shifted by the lane index.
    wire [31:0] fb_word_offset = {fb_offset[31:2], 2'b00};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= ST_IDLE;
            mem_ready <= 1'b0;
            mem_rdata <= 32'h0;
            fb_we <= 4'h0;
            fb_addr <= '0;
            fb_wdata <= 32'h0;
            vga_awaddr <= 32'h0;
            vga_awvalid <= 1'b0;
            vga_wdata <= 32'h0;
            vga_wstrb <= 4'h0;
            vga_wvalid <= 1'b0;
            vga_bready <= 1'b0;
            vga_araddr <= 32'h0;
            vga_arvalid <= 1'b0;
            vga_rready <= 1'b0;
        end else begin
            mem_ready <= 1'b0;
            fb_we <= 4'h0;

            case (state)
                ST_IDLE: begin
                    if (mem_valid) begin
                        if (sel_imem) begin
                            if (imem_ready) begin
                                mem_rdata <= imem_rdata;
                                mem_ready <= 1'b1;
                                state <= ST_HOLD;
                            end
                        end else if (sel_dmem) begin
                            if (dmem_ready) begin
                                mem_rdata <= dmem_rdata;
                                mem_ready <= 1'b1;
                                state <= ST_HOLD;
                            end
                        end else if (sel_fb) begin
                            if (is_write)
                                fb_addr <= fb_word_offset[FB_ADDR_WIDTH-1:0];
                            else
                                fb_addr <= fb_offset[FB_ADDR_WIDTH-1:0];
                            fb_wdata <= mem_wdata;
                            if (is_write) begin
                                fb_we <= mem_wstrb;
                                mem_rdata <= 32'h0;
                                mem_ready <= 1'b1;
                                state <= ST_HOLD;
                            end else begin
                                state <= ST_FB_RD;
                            end
                        end else if (sel_vga) begin
                            if (is_write) begin
                                vga_awaddr <= mem_addr;
                                vga_awvalid <= 1'b1;
                                vga_wdata <= mem_wdata;
                                vga_wstrb <= mem_wstrb;
                                vga_wvalid <= 1'b1;
                                state <= ST_AXI_W;
                            end else begin
                                vga_araddr <= mem_addr;
                                vga_arvalid <= 1'b1;
                                vga_rready <= 1'b1;
                                state <= ST_AXI_R;
                            end
                        end else begin
                            // Unmapped address. Return a recognizable value so
                            // a software test can detect the bad access.
                            mem_rdata <= 32'hDEAD_BEEF;
                            mem_ready <= 1'b1;
                            state <= ST_HOLD;
                        end
                    end
                end

                ST_FB_RD: begin
		    // Framebuffer RAM Port A has a registered read output.
		// Hold the requested address for one full clock before	
		 // consuming fb_rdata.
		    state <= ST_FB_RD_WAIT;
		end

		ST_FB_RD_WAIT: begin
    // fb_rdata now corresponds to the address held in fb_addr.
		    mem_rdata <= {24'h0, fb_rdata};
		    mem_ready <= 1'b1;
		    state <= ST_HOLD;
		end

                ST_AXI_W: begin
                    if (vga_awvalid && vga_awready)
                        vga_awvalid <= 1'b0;
                    if (vga_wvalid && vga_wready)
                        vga_wvalid <= 1'b0;

                    if (vga_bvalid) begin
                        vga_bready <= 1'b1;
                        mem_rdata <= {30'h0, vga_bresp};
                        mem_ready <= 1'b1;
                        state <= ST_AXI_B;
                    end
                end

                ST_AXI_B: begin
                    if (vga_bvalid && vga_bready) begin
                        vga_bready <= 1'b0;
                        state <= ST_HOLD;
                    end
                end

                ST_AXI_R: begin
                    if (vga_arvalid && vga_arready)
                        vga_arvalid <= 1'b0;
                    if (vga_rvalid && vga_rready) begin
                        mem_rdata <= vga_rdata;
                        mem_ready <= 1'b1;
                        vga_rready <= 1'b0;
                        state <= ST_HOLD;
                    end
                end

                ST_HOLD: begin
                    // A native master may keep mem_valid asserted for the
                    // cycle in which it observes mem_ready. Do not treat that
                    // same request as a second transfer. Wait for valid to
                    // deassert before accepting a new request.
                    if (!mem_valid) begin
                        state <= ST_IDLE;
                    end
                end

                default: state <= ST_IDLE;
            endcase
        end
    end
endmodule
