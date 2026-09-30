module data_mem (
    clk,
    rst,
    mem_addr,
    mem_read,
    mem_write,
    data_mem_i,
    data_mem_o,
    write_mask,
    mem_ready,

    snoop_invalidate,
    snoop_addr,

    HADDR,
    HWRITE,
    HTRANS,
    HSIZE,
    HWDATA,
    HRDATA,
    HREADY,
    HRESP
    );
    input wire        clk;
    input wire        rst;
    input wire [5:0]  mem_addr;
    input wire        mem_read;
    input wire        mem_write;
    input wire [31:0] data_mem_i;
    output reg [31:0] data_mem_o;
    input wire [3:0]  write_mask;
    output reg        mem_ready;

    input wire        snoop_invalidate;
    input wire [5:0]  snoop_addr;

    output reg [31:0] HADDR;
    output reg        HWRITE;
    output reg [1:0]  HTRANS;
    output reg [2:0]  HSIZE;
    output reg [31:0] HWDATA;
    input wire [31:0] HRDATA;
    input wire        HREADY;
    input wire        HRESP;

    parameter IDLE   = 2'b00;
    parameter NONSEQ = 2'b10;

    parameter ST_IDLE       = 2'b00;
    parameter ST_MISS_REQ   = 2'b01;
    parameter ST_MISS_WAIT  = 2'b10;
    parameter ST_WRITE_WAIT = 2'b11;

    reg [1:0] state;

    reg        valid [0:15];
    reg [1:0]  tag   [0:15];
    reg [31:0] data  [0:15];

    wire [3:0] index      = mem_addr[3:0];
    wire [1:0] req_tag    = mem_addr[5:4];
    wire       hit        = valid[index] && (tag[index] == req_tag);

    integer i;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (i = 0; i < 16; i = i + 1)
                valid[i] <= 1'b0;
            state      <= ST_IDLE;
            mem_ready  <= 1'b0;
            data_mem_o <= 32'b0;
            HTRANS     <= IDLE;
        end
        else begin
            mem_ready <= 1'b0;

            if (snoop_invalidate)
                valid[snoop_addr[3:0]] <= 1'b0;

            case (state)
                ST_IDLE: begin
                    if (mem_read && hit) begin
                        data_mem_o <= data[index];
                        mem_ready  <= 1'b1;
                    end
                    else if (mem_read && !hit) begin
                        HADDR  <= {24'b0, mem_addr, 2'b00};
                        HWRITE <= 1'b0;
                        HTRANS <= NONSEQ;
                        HSIZE  <= 3'b010;
                        state  <= ST_MISS_REQ;
                    end
                    else if (mem_write) begin
                        if (hit) begin
                            if (write_mask[0]) data[index][7:0]   <= data_mem_i[7:0];
                            if (write_mask[1]) data[index][15:8]  <= data_mem_i[15:8];
                            if (write_mask[2]) data[index][23:16] <= data_mem_i[23:16];
                            if (write_mask[3]) data[index][31:24] <= data_mem_i[31:24];
                        end
                        HADDR  <= {24'b0, mem_addr, 2'b00};
                        HWRITE <= 1'b1;
                        HTRANS <= NONSEQ;
                        HSIZE  <= 3'b010;
                        HWDATA <= data_mem_i;
                        state  <= ST_WRITE_WAIT;
                    end
                end

                ST_MISS_REQ: begin
                    state <= ST_MISS_WAIT;
                end

                ST_MISS_WAIT: begin
                    if (HREADY) begin
                        data[index]  <= HRDATA;
                        tag[index]   <= req_tag;
                        valid[index] <= 1'b1;
                        data_mem_o   <= HRDATA;
                        mem_ready    <= 1'b1;
                        HTRANS       <= IDLE;
                        state        <= ST_IDLE;
                    end
                end

                ST_WRITE_WAIT: begin
                    if (HREADY) begin
                        mem_ready <= 1'b1;
                        HTRANS    <= IDLE;
                        state     <= ST_IDLE;
                    end
                end
            endcase
        end
    end

endmodule