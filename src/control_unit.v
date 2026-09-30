module control_unit(
    input  [6:0] opcode,
    input  [2:0] funct3,
    input        funct7,

    output reg       reg_write,
    output reg       mem_read,
    output reg       mem_write,
    output reg       alu_src,
    output reg       branch,
    output reg       jump,
    output reg       jalr,
    output reg       lui,
    output reg       auipc,

    output reg [1:0] result_src,
    output reg [3:0] alu_control,

    
    
    
    
    output reg [1:0] mem_size,

    
    
    
    output reg       mem_signed
);

always @(*) begin

    
    
    

    reg_write   = 1'b0;
    mem_read    = 1'b0;
    mem_write   = 1'b0;

    alu_src     = 1'b0;

    branch      = 1'b0;
    jump        = 1'b0;
    jalr        = 1'b0;

    lui         = 1'b0;
    auipc       = 1'b0;

    result_src  = 2'b00;

    alu_control = 4'b0000;

    
    mem_size    = 2'b10;

    
    mem_signed  = 1'b0;

    case (opcode)

        
        
        
        
        
        
        

        7'b0110011: begin

            reg_write = 1'b1;
            alu_src   = 1'b0;

            case (funct3)

                
                3'b000: begin

                    if (funct7)
                        alu_control = 4'b0001; 
                    else
                        alu_control = 4'b0000; 

                end

                
                3'b001:
                    alu_control = 4'b0111;

                
                3'b010:
                    alu_control = 4'b0101;

                
                3'b011:
                    alu_control = 4'b0110;

                
                3'b100:
                    alu_control = 4'b0100;

                
                3'b101: begin

                    if (funct7)
                        alu_control = 4'b1001; 
                    else
                        alu_control = 4'b1000; 

                end

                
                3'b110:
                    alu_control = 4'b0011;

                
                3'b111:
                    alu_control = 4'b0010;

                default:
                    alu_control = 4'b0000;

            endcase

        end

        
        
        
        
        
        
        

        7'b0010011: begin

            reg_write = 1'b1;
            alu_src   = 1'b1;

            case (funct3)

                
                3'b000:
                    alu_control = 4'b0000;

                
                3'b001:
                    alu_control = 4'b0111;

                
                3'b010:
                    alu_control = 4'b0101;

                
                3'b011:
                    alu_control = 4'b0110;

                
                3'b100:
                    alu_control = 4'b0100;

                
                3'b101: begin

                    if (funct7)
                        alu_control = 4'b1001;
                    else
                        alu_control = 4'b1000;

                end

                
                3'b110:
                    alu_control = 4'b0011;

                
                3'b111:
                    alu_control = 4'b0010;

                default:
                    alu_control = 4'b0000;

            endcase

        end

        
        
        
        
        
        
        
        
        
        

        7'b0000011: begin

            reg_write   = 1'b1;
            mem_read    = 1'b1;

            alu_src     = 1'b1;

            result_src  = 2'b01;

            
            
            alu_control = 4'b0000;

            case (funct3)

                
                
                

                3'b000: begin

                    mem_size   = 2'b00;
                    mem_signed = 1'b1;

                end

                
                
                

                3'b001: begin

                    mem_size   = 2'b01;
                    mem_signed = 1'b1;

                end

                
                
                

                3'b010: begin

                    mem_size   = 2'b10;
                    mem_signed = 1'b1;

                end

                
                
                

                3'b100: begin

                    mem_size   = 2'b00;
                    mem_signed = 1'b0;

                end

                
                
                

                3'b101: begin

                    mem_size   = 2'b01;
                    mem_signed = 1'b0;

                end

                
                
                

                default: begin

                    reg_write  = 1'b0;
                    mem_read   = 1'b0;

                    mem_size   = 2'b10;
                    mem_signed = 1'b0;

                end

            endcase

        end

        
        
        
        
        
        
        
        

        7'b0100011: begin

            mem_write   = 1'b1;

            alu_src     = 1'b1;

            
            
            alu_control = 4'b0000;

            case (funct3)

                
                
                

                3'b000: begin

                    mem_size = 2'b00;

                end

                
                
                

                3'b001: begin

                    mem_size = 2'b01;

                end

                
                
                

                3'b010: begin

                    mem_size = 2'b10;

                end

                
                
                

                default: begin

                    mem_write = 1'b0;
                    mem_size  = 2'b10;

                end

            endcase

        end

        
        
        
        
        
        
        

        7'b1100011: begin

            branch      = 1'b1;
            alu_src     = 1'b0;

            
            alu_control = 4'b0001;

        end

        
        
        

        7'b1101111: begin

            reg_write  = 1'b1;
            jump       = 1'b1;

            
            result_src = 2'b10;

        end

        
        
        

        7'b1100111: begin

            
            if (funct3 == 3'b000) begin

                reg_write   = 1'b1;

                jump        = 1'b1;
                jalr        = 1'b1;

                alu_src     = 1'b1;

                result_src  = 2'b10;

                alu_control = 4'b0000;

            end

        end

        
        
        

        7'b0110111: begin

            reg_write  = 1'b1;
            lui        = 1'b1;

            result_src = 2'b11;

        end

        
        
        

        7'b0010111: begin

            reg_write   = 1'b1;
            auipc       = 1'b1;

            alu_src     = 1'b1;

            alu_control = 4'b0000;

            
            result_src  = 2'b00;

        end

        
        
        

        default: begin

            reg_write   = 1'b0;

            mem_read    = 1'b0;
            mem_write   = 1'b0;

            alu_src     = 1'b0;

            branch      = 1'b0;
            jump        = 1'b0;
            jalr        = 1'b0;

            lui         = 1'b0;
            auipc       = 1'b0;

            result_src  = 2'b00;

            alu_control = 4'b0000;

            mem_size    = 2'b10;
            mem_signed  = 1'b0;

        end

    endcase

end

endmodule

