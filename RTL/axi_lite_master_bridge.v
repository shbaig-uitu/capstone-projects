module axi_lite_master_bridge(
    input clk,
    input reset,

    
    
    

    input         req_read,
    input         req_write,

    input  [31:0] req_address,
    input  [31:0] req_write_data,
    input  [3:0]  req_write_strobe,

    
    
    

    output reg [31:0] resp_read_data,
    output reg        resp_ready,
    output reg        resp_error,

    
    
    

    output reg [31:0] m_axi_awaddr,
    output reg        m_axi_awvalid,
    input             m_axi_awready,

    
    
    

    output reg [31:0] m_axi_wdata,
    output reg [3:0]  m_axi_wstrb,
    output reg        m_axi_wvalid,
    input             m_axi_wready,

    
    
    

    input      [1:0]  m_axi_bresp,
    input             m_axi_bvalid,
    output reg        m_axi_bready,

    
    
    

    output reg [31:0] m_axi_araddr,
    output reg        m_axi_arvalid,
    input             m_axi_arready,

    
    
    

    input      [31:0] m_axi_rdata,
    input      [1:0]  m_axi_rresp,
    input             m_axi_rvalid,
    output reg        m_axi_rready
);

localparam IDLE        = 3'd0;
localparam WRITE_ADDR  = 3'd1;
localparam WRITE_RESP  = 3'd2;
localparam READ_ADDR   = 3'd3;
localparam READ_DATA   = 3'd4;

reg [2:0] state;

reg [31:0] saved_address;
reg [31:0] saved_write_data;
reg [3:0]  saved_write_strobe;

always @(posedge clk) begin

    if (reset) begin

        state <= IDLE;

        saved_address      <= 32'b0;
        saved_write_data   <= 32'b0;
        saved_write_strobe <= 4'b0;

        resp_read_data <= 32'b0;
        resp_ready     <= 1'b0;
        resp_error     <= 1'b0;

        m_axi_awaddr  <= 32'b0;
        m_axi_awvalid <= 1'b0;

        m_axi_wdata   <= 32'b0;
        m_axi_wstrb   <= 4'b0;
        m_axi_wvalid  <= 1'b0;

        m_axi_bready  <= 1'b0;

        m_axi_araddr  <= 32'b0;
        m_axi_arvalid <= 1'b0;

        m_axi_rready  <= 1'b0;

    end
    else begin

        
        resp_ready <= 1'b0;
        resp_error <= 1'b0;

        case (state)

            
            
            

            IDLE: begin

                m_axi_awvalid <= 1'b0;
                m_axi_wvalid  <= 1'b0;
                m_axi_bready  <= 1'b0;

                m_axi_arvalid <= 1'b0;
                m_axi_rready  <= 1'b0;

                
                
                

                if (req_write) begin

                    saved_address      <= req_address;
                    saved_write_data   <= req_write_data;
                    saved_write_strobe <= req_write_strobe;

                    m_axi_awaddr  <= req_address;
                    m_axi_awvalid <= 1'b1;

                    m_axi_wdata   <= req_write_data;
                    m_axi_wstrb   <= req_write_strobe;
                    m_axi_wvalid  <= 1'b1;

                    state <= WRITE_ADDR;

                end

                
                
                

                else if (req_read) begin

                    saved_address <= req_address;

                    m_axi_araddr  <= req_address;
                    m_axi_arvalid <= 1'b1;

                    state <= READ_ADDR;

                end

            end

            
            
            
            
            
            
            
            

            WRITE_ADDR: begin

                if (m_axi_awvalid && m_axi_awready)
                    m_axi_awvalid <= 1'b0;

                if (m_axi_wvalid && m_axi_wready)
                    m_axi_wvalid <= 1'b0;

                
                if (
                    (!m_axi_awvalid || m_axi_awready) &&
                    (!m_axi_wvalid  || m_axi_wready)
                ) begin

                    m_axi_bready <= 1'b1;
                    state        <= WRITE_RESP;

                end

            end

            
            
            

            WRITE_RESP: begin

                if (m_axi_bvalid && m_axi_bready) begin

                    m_axi_bready <= 1'b0;

                    resp_ready <= 1'b1;

                    
                    
                    
                    
                    
                    resp_error <=
                        (m_axi_bresp[1] == 1'b1);

                    state <= IDLE;

                end

            end

            
            
            

            READ_ADDR: begin

                if (m_axi_arvalid && m_axi_arready) begin

                    m_axi_arvalid <= 1'b0;
                    m_axi_rready  <= 1'b1;

                    state <= READ_DATA;

                end

            end

            
            
            

            READ_DATA: begin

                if (m_axi_rvalid && m_axi_rready) begin

                    m_axi_rready <= 1'b0;

                    resp_read_data <= m_axi_rdata;
                    resp_ready     <= 1'b1;

                    resp_error <=
                        (m_axi_rresp[1] == 1'b1);

                    state <= IDLE;

                end

            end

            
            
            

            default: begin

                state <= IDLE;

                m_axi_awvalid <= 1'b0;
                m_axi_wvalid  <= 1'b0;
                m_axi_bready  <= 1'b0;

                m_axi_arvalid <= 1'b0;
                m_axi_rready  <= 1'b0;

            end

        endcase

    end

end

endmodule

