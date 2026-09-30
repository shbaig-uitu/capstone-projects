
module  data_mem (
    clk,
    mem_addr,
    mem_read,
    mem_write,
    data_mem_i,
    data_mem_o,
    write_mask
    );

    input wire             clk;
    input wire        mem_read;
    input wire       mem_write;
    input wire[11:0]  mem_addr;
    input wire[31:0]data_mem_i;
    output reg[31:0]data_mem_o;
    input wire[3:0] write_mask;
    
    reg[31:0]data_mem[15:0];

    always@(posedge clk )begin

        if(mem_write) begin
            if (write_mask[0]) begin
                data_mem[mem_addr][7:0]<= data_mem_i[7:0];
            end

            if (write_mask[1])begin
                data_mem[mem_addr][15:8]<= data_mem_i[15:8];
            end
            if (write_mask[2])begin
                data_mem[mem_addr][23:16]<= data_mem_i[23:16];
            end
            if (write_mask[3])begin
                data_mem[mem_addr][31:24]<= data_mem_i[31:24];
            end
        end
    end
    always @(*)begin
     data_mem_o = data_mem[mem_addr];
    end
endmodule