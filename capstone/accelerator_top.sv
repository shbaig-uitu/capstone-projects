// accelerator_top.sv
module accelerator_top #(parameter AW=32, DW=32)(
    input clk, rst,
    // AXI4-Lite Slave Interface
    input [AW-1:0] awaddr, input awvalid, output reg awready,
    input [DW-1:0] wdata,  input wvalid,  output reg wready,
    output reg bvalid,     input bready,
    input [AW-1:0] araddr, input arvalid, output reg arready,
    output reg [DW-1:0] rdata, output reg rvalid, input rready
);
    // 16-word buffers for 4x4 Matrices
    reg [31:0] weight_buf [0:15];
    reg [31:0] act_buf    [0:15];
    reg [31:0] result_buf [0:15];
    
    reg start, done, computing;
    reg [3:0] cycle_cnt;

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
                result_buf[k] <= 0;
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
                    weight_buf[(awaddr_lat[7:0] - 8'h40) >> 2] <= wdata_lat;
                else if (awaddr_lat[7:0] >= 8'h80 && awaddr_lat[7:0] < 8'hC0) 
                    act_buf[(awaddr_lat[7:0] - 8'h80) >> 2] <= wdata_lat;
            end

            if (bvalid && bready) bvalid <= 0;
        end
    end


    // --- AXI4-Lite Slave Read Logic ---
    always @(posedge clk) begin
        if (rst) begin arready <= 0; rvalid <= 0; end
        else begin
            arready <= arvalid && !arready;
            if (arvalid && arready) begin
                rvalid <= 1;
                if (araddr[7:0] == 8'h04) rdata <= {30'b0, done, computing};
                else if (araddr[7:0] >= 8'hC0) rdata <= result_buf[(araddr[7:0] - 8'hC0) >> 2];
                else rdata <= 32'hDEADBEEF;
            end
            if (rvalid && rready) rvalid <= 0;
        end
    end

    // --- Data Skewing & Systolic Control FSM (FIXED Mapping) ---
    wire signed [7:0] weights [0:3][0:3];
    wire signed [7:0] act_in  [0:3];
    wire signed [31:0] psum_out [0:3];
    reg load_weight;
    reg [2:0] state;
    localparam S_IDLE = 0, S_LOAD = 1, S_COMPUTE = 2;

    // Map 1D weight buffer to 2D array
    genvar i, j;
    generate
        for(i=0; i<4; i=i+1) begin : w_row
            for(j=0; j<4; j=j+1) begin : w_col
                assign weights[i][j] = weight_buf[i*4 + j][7:0];
            end
        end
    endgenerate

    // Dataflow mapping: Row 'k' of array gets Column 'k' of Matrix A
    assign act_in[0] = (cycle_cnt < 4) ? act_buf[(cycle_cnt)*4 + 0][7:0] : 8'd0;
    assign act_in[1] = (cycle_cnt >= 1 && cycle_cnt < 5) ? act_buf[(cycle_cnt-1)*4 + 1][7:0] : 8'd0;
    assign act_in[2] = (cycle_cnt >= 2 && cycle_cnt < 6) ? act_buf[(cycle_cnt-2)*4 + 2][7:0] : 8'd0;
    assign act_in[3] = (cycle_cnt >= 3 && cycle_cnt < 7) ? act_buf[(cycle_cnt-3)*4 + 3][7:0] : 8'd0;

    systolic_4x4 #(.DW(8), .AW(32), .N(4)) sys_array (
        .clk(clk), .rst_n(!rst),
        .load_weight(load_weight), .weights(weights),
        .act_in(act_in), .psum_out(psum_out)
    );

    always @(posedge clk) begin
        if (rst) begin
            state <= S_IDLE; computing <= 0; done <= 0; 
            cycle_cnt <= 0; load_weight <= 0;
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
                if (cycle_cnt == 4) begin result_buf[0]<=psum_out[0]; end
                if (cycle_cnt == 5) begin result_buf[4]<=psum_out[0]; result_buf[1]<=psum_out[1]; end
                if (cycle_cnt == 6) begin result_buf[8]<=psum_out[0]; result_buf[5]<=psum_out[1]; result_buf[2]<=psum_out[2]; end
                if (cycle_cnt == 7) begin result_buf[12]<=psum_out[0]; result_buf[9]<=psum_out[1]; result_buf[6]<=psum_out[2]; result_buf[3]<=psum_out[3]; end
                if (cycle_cnt == 8) begin result_buf[13]<=psum_out[1]; result_buf[10]<=psum_out[2]; result_buf[7]<=psum_out[3]; end
                if (cycle_cnt == 9) begin result_buf[14]<=psum_out[2]; result_buf[11]<=psum_out[3]; end
                if (cycle_cnt == 10) begin 
                    result_buf[15]<=psum_out[3]; 
                    computing <= 0; 
                    done <= 1; 
                    state <= S_IDLE; 
                end
            end
        endcase
    end
endmodule