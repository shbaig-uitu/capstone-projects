module shared_data_memory #(
    parameter ADDR_WIDTH = 6
)(
    input clk,
    input reset,
    input mem_read,
    input mem_write,
    input [3:0] write_strobe,
    input [31:0] address,
    input [31:0] write_data,
    output reg [31:0] read_data,
    output reg ready,
    output reg init_done
);

localparam WORDS = (1 << ADDR_WIDTH);

reg [31:0] memory [0:WORDS-1];
reg pending;
reg pending_write;
reg [ADDR_WIDTH-1:0] pending_address;
reg [31:0] pending_write_data;
reg [3:0] pending_write_strobe;

always @(posedge clk) begin
    if (reset) begin
        read_data <= 32'b0;
        ready <= 1'b0;
        init_done <= 1'b1;
        pending <= 1'b0;
        pending_write <= 1'b0;
        pending_address <= {ADDR_WIDTH{1'b0}};
        pending_write_data <= 32'b0;
        pending_write_strobe <= 4'b0;
    end else begin
        ready <= 1'b0;

        if (pending) begin
            if (pending_write) begin
                if (pending_write_strobe[0])
                    memory[pending_address][7:0] <= pending_write_data[7:0];
                if (pending_write_strobe[1])
                    memory[pending_address][15:8] <= pending_write_data[15:8];
                if (pending_write_strobe[2])
                    memory[pending_address][23:16] <= pending_write_data[23:16];
                if (pending_write_strobe[3])
                    memory[pending_address][31:24] <= pending_write_data[31:24];
            end else begin
                read_data <= memory[pending_address];
            end

            pending <= 1'b0;
            ready <= 1'b1;
        end else if (!ready && (mem_read || mem_write)) begin
            pending <= 1'b1;
            pending_write <= mem_write;
            pending_address <= address[ADDR_WIDTH+1:2];
            pending_write_data <= write_data;
            pending_write_strobe <= write_strobe;
        end
    end
end

endmodule

