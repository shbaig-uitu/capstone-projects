// accelerator_top.sv
module accelerator_top #(parameter AW=32, DW=32)(
    input clk, rst,
    // AXI4-Lite Slave Interface
    input [AW-1:0] awaddr, input awvalid, output reg awready,
    input [DW-1:0] wdata,  input wvalid,  output reg wready,
    output reg bvalid,     input bready,
    input [AW-1:0] araddr, input arvalid, output reg arready,
    output reg [DW-1:0] rdata, output reg rvalid, input rready,
    output wire computing_out,
    output wire done_out,
    output wire [31:0] c00_out
);
    // 16-word buffers for 4x4 Matrices
    reg [31:0] weight_buf [0:15];
    reg [31:0] act_buf    [0:15];
    reg [31:0] result_buf [0:15];
    
    assign c00_out = result_buf[0];
    
    reg start, done, computing;
    reg [3:0] cycle_cnt;

    assign computing_out = computing;
    assign done_out      = done;

// --- AXI4-Lite Slave Write Logic (FIXED Latch) ---
    reg [AW-1:0] awaddr_lat;
    reg [DW-1:0] wdata_lat; // NEW: Latch for write data
    reg aw_en, w_en;
    integer k;

    always @(posedge clk) begin
        if (rst) begin
            awready <= 0; wready <= 0; bvalid <= 0; start <= 0;
            aw_en <= 0; w_en <= 0;
            for (k = 0; k < 16; k = k + 1) begin
                weight_buf[k] <= 0;
                act_buf[k] <= 0;
            end
        end else begin
            start <= 0; 

            // Accept Address independently
            if (awvalid && !awready && !aw_en) begin
                awready <= 1; awaddr_lat <= awaddr; aw_en <= 1;
            end else awready <= 0;

            // Accept Data independently
            if (wvalid && !wready && !w_en) begin
                wready <= 1; wdata_lat <= wdata; w_en <= 1; // NEW: Capture data
            end else wready <= 0;

            // When both accepted, process the write using latched data
            if (aw_en && w_en) begin
                bvalid <= 1;
                aw_en <= 0; w_en <= 0;
                
                if (awaddr_lat[7:0] == 8'h00) start <= wdata_lat[0];
                else if (awaddr_lat[7:0] >= 8'h40 && awaddr_lat[7:0] < 8'h80) 
                    weight_buf[awaddr_lat[5:2]] <= wdata_lat;
                else if (awaddr_lat[7:0] >= 8'h80 && awaddr_lat[7:0] < 8'hC0) 
                    act_buf[awaddr_lat[5:2]] <= wdata_lat;
            end

            if (bvalid && bready) bvalid <= 0;
        end
    end


    // --- AXI4-Lite Slave Read Logic (Latched Address & Safe Default) ---
    reg [AW-1:0] araddr_lat;
    reg ar_en;

    always @(posedge clk) begin
        if (rst) begin
            arready    <= 0;
            rvalid     <= 0;
            rdata      <= 32'd0;
            araddr_lat <= 0;
            ar_en      <= 0;
        end else begin
            if (arvalid && !arready && !ar_en) begin
                arready    <= 1;
                araddr_lat <= araddr;
                ar_en      <= 1;
            end else begin
                arready <= 0;
            end

            if (ar_en && !rvalid) begin
                rvalid <= 1;
                ar_en  <= 0;
                if (araddr_lat[7:0] == 8'h04)
                    rdata <= {30'b0, done, computing};
                else if (araddr_lat[7:0] >= 8'hC0)
                    rdata <= result_buf[araddr_lat[5:2]];
                else
                    rdata <= 32'd0; // Safe default (bit 1 is 0, never false done)
            end

            if (rvalid && rready) begin
                rvalid <= 0;
            end
        end
    end

    // --- Data Skewing & Systolic Control FSM (Flattened 1D Vectors for Synthesis) ---
    wire signed [16*8-1:0]  weights_flat;
    wire signed [4*8-1:0]   act_in_flat;
    wire signed [4*32-1:0]  psum_out_flat;
    reg load_weight;
    reg [2:0] state;
    localparam S_IDLE = 0, S_LOAD = 1, S_COMPUTE = 2;

    // Pack 1D weight buffer (16 words) to flattened 128-bit vector
    genvar wi;
    generate
        for(wi = 0; wi < 16; wi = wi + 1) begin : w_flat
            assign weights_flat[wi*8 +: 8] = weight_buf[wi][7:0];
        end
    endgenerate

    // Safe indexing for Yosys bounds checking
    wire [3:0] r0 = cycle_cnt;
    wire [3:0] r1 = cycle_cnt - 4'd1;
    wire [3:0] r2 = cycle_cnt - 4'd2;
    wire [3:0] r3 = cycle_cnt - 4'd3;

    // Dataflow mapping: {r[1:0], 2'bXX} inherently bounds the index between 0 and 15
    assign act_in_flat[0*8 +: 8] = (cycle_cnt < 4)                   ? act_buf[{r0[1:0], 2'b00}][7:0] : 8'd0;
    assign act_in_flat[1*8 +: 8] = (cycle_cnt >= 1 && cycle_cnt < 5) ? act_buf[{r1[1:0], 2'b01}][7:0] : 8'd0;
    assign act_in_flat[2*8 +: 8] = (cycle_cnt >= 2 && cycle_cnt < 6) ? act_buf[{r2[1:0], 2'b10}][7:0] : 8'd0;
    assign act_in_flat[3*8 +: 8] = (cycle_cnt >= 3 && cycle_cnt < 7) ? act_buf[{r3[1:0], 2'b11}][7:0] : 8'd0;

    // Unpack 4 columns of 32-bit partial sums
    wire signed [31:0] psum_col [0:3];
    assign psum_col[0] = psum_out_flat[0*32 +: 32];
    assign psum_col[1] = psum_out_flat[1*32 +: 32];
    assign psum_col[2] = psum_out_flat[2*32 +: 32];
    assign psum_col[3] = psum_out_flat[3*32 +: 32];

    systolic_4x4 #(.DW(8), .AW(32), .N(4)) sys_array (
        .clk(clk), .rst_n(!rst),
        .load_weight(load_weight), .weights(weights_flat),
        .act_in(act_in_flat), .psum_out(psum_out_flat)
    );

    always @(posedge clk) begin
        if (rst) begin
            state <= S_IDLE; computing <= 0; done <= 0; 
            cycle_cnt <= 0; load_weight <= 0;
            for (k = 0; k < 16; k = k + 1) result_buf[k] <= 32'd0;
        end else case (state)
            S_IDLE: begin
                if (start) begin
                    load_weight <= 1; // Assert load
                    done <= 0;
                    state <= S_LOAD;
                end
            end
            S_LOAD: begin
                load_weight <= 0; // Weights latch this cycle
                computing <= 1;
                cycle_cnt <= 0;
                state <= S_COMPUTE;
            end
            S_COMPUTE: begin
                cycle_cnt <= cycle_cnt + 1;
                
                // Capture C matrix diagonals
                if (cycle_cnt == 4) begin result_buf[0]<=psum_col[0]; end
                if (cycle_cnt == 5) begin result_buf[4]<=psum_col[0]; result_buf[1]<=psum_col[1]; end
                if (cycle_cnt == 6) begin result_buf[8]<=psum_col[0]; result_buf[5]<=psum_col[1]; result_buf[2]<=psum_col[2]; end
                if (cycle_cnt == 7) begin result_buf[12]<=psum_col[0]; result_buf[9]<=psum_col[1]; result_buf[6]<=psum_col[2]; result_buf[3]<=psum_col[3]; end
                if (cycle_cnt == 8) begin result_buf[13]<=psum_col[1]; result_buf[10]<=psum_col[2]; result_buf[7]<=psum_col[3]; end
                if (cycle_cnt == 9) begin result_buf[14]<=psum_col[2]; result_buf[11]<=psum_col[3]; end
                if (cycle_cnt == 10) begin 
                    result_buf[15]<=psum_col[3]; 
                    computing <= 0; 
                    done <= 1; 
                    state <= S_IDLE; 
                end
            end
        endcase
    end
endmodule