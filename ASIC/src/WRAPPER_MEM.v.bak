module wrapper_mem (
    wrapper_mem_o_for_cache_i,
    wrapper_mem_o,
    wrapper_mem_i,
    instruction, 
    mem_write,
    store_op,
    mem_read,
    mem_addr,
    clk,
    shared_addr,
    shared_read,
    shared_write,
    shared_wdata,
    shared_wmask,
    shared_rdata
 );
 input  wire [31:0]               instruction;
 input  wire [13:0]                  mem_addr; 
 output reg  [3:0]                   store_op;
 wire   [31:0]                        cache_o;
 input  wire [31:0]             wrapper_mem_i;
 output reg  [31:0]             wrapper_mem_o;
 input  wire                        mem_write;
 input  wire                         mem_read;
 input  wire                              clk;
 output reg  [31:0]  wrapper_mem_o_for_cache_i;

 output wire [3:0]                shared_addr;
 output wire                      shared_read;
 output wire                      shared_write;
 output wire [31:0]               shared_wdata;
 output wire [3:0]                shared_wmask;
 input  wire [31:0]               shared_rdata;

 always@(*)begin
     store_op = 4'b0;
     wrapper_mem_o_for_cache_i = 32'b0;
     wrapper_mem_o = 32'b0;
     if(instruction[14:12]==3'b000)begin //sb
           case(mem_addr[1:0])
           2'b00:begin 
             store_op=4'b0001;
             wrapper_mem_o_for_cache_i = wrapper_mem_i;
             end
           2'b01:begin
             store_op=4'b0010;
             wrapper_mem_o_for_cache_i = {wrapper_mem_i[31:16],wrapper_mem_i[7:0],wrapper_mem_i[7:0]};
           end
           2'b10:begin
             store_op=4'b0100;
             wrapper_mem_o_for_cache_i = {wrapper_mem_i[31:24],wrapper_mem_i[7:0],wrapper_mem_i[15:0]};
           end
           2'b11:begin
             store_op=4'b1000;
             wrapper_mem_o_for_cache_i = {wrapper_mem_i[7:0],wrapper_mem_i[23:0]};
           end
           endcase
     end
     if(instruction[14:12]==3'b001)begin//sh
           case(mem_addr[1:0])
           2'b00: begin
             store_op = 4'b0011;
             wrapper_mem_o_for_cache_i = wrapper_mem_i;
           end
           2'b01:begin
             store_op = 4'b0110;
             wrapper_mem_o_for_cache_i = {wrapper_mem_i[31:24],wrapper_mem_i[15:0],wrapper_mem_i[7:0]};
           end
           2'b10:begin
             store_op=4'b1100;
             wrapper_mem_o_for_cache_i = {wrapper_mem_i[15:0],wrapper_mem_i[15:0]};
           end
           endcase
     end
     if(instruction[14:12]==3'b010)begin//sw
       store_op=4'b1111;
       wrapper_mem_o_for_cache_i = wrapper_mem_i;   
     end
     if(instruction[14:12]==3'b000)begin //lb
           case(mem_addr[1:0])
           2'b00:wrapper_mem_o={{24{cache_o[7]}},cache_o[7:0]};
           2'b01:wrapper_mem_o={{24{cache_o[15]}},cache_o[15:8]};
           2'b10:wrapper_mem_o={{24{cache_o[23]}},cache_o[23:16]};
           2'b11:wrapper_mem_o={{24{cache_o[31]}},cache_o[31:24]};
           endcase
     end
     if(instruction[14:12]==3'b001)begin//lh
           case(mem_addr[1:0])
           2'b00:wrapper_mem_o={{16{cache_o[15]}},cache_o[15:0]};
           2'b01:wrapper_mem_o={{16{cache_o[23]}},cache_o[23:8]};
           2'b10:wrapper_mem_o={{16{cache_o[31]}},cache_o[31:16]};
           endcase
     end
     if(instruction[14:12]==3'b010)begin//lw
        wrapper_mem_o=cache_o;
     end
     if(instruction[14:12]==3'b100)begin//lbu
         case(mem_addr[1:0])
           2'b00:wrapper_mem_o={24'b0,cache_o[7:0]};
           2'b01:wrapper_mem_o={24'b0,cache_o[15:8]};
           2'b10:wrapper_mem_o={24'b0,cache_o[23:16]};
           2'b11:wrapper_mem_o={24'b0,cache_o[31:24]};
           endcase
     end
     if(instruction[14:12]==3'b101)begin//lhu
         case(mem_addr[1:0])
           2'b00:wrapper_mem_o={16'b0,cache_o[15:0]};
           2'b01:wrapper_mem_o={16'b0,cache_o[23:8]};
           2'b10:wrapper_mem_o={16'b0,cache_o[31:16]};
           endcase
     end
 end

     data_cache u_dc (
       .clk         (                         clk),
       .mem_addr    (               mem_addr[5:2]),
       .mem_read    (                    mem_read),
       .mem_write   (                   mem_write),
       .cache_i     (   wrapper_mem_o_for_cache_i),
       .cache_o     (                     cache_o),
       .write_mask  (                    store_op),
       .shared_addr (                 shared_addr),
       .shared_read (                 shared_read),
       .shared_write(                shared_write),
       .shared_wdata(                shared_wdata),
       .shared_wmask(                shared_wmask),
       .shared_rdata(                shared_rdata)
     );

endmodule
