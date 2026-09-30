module tb_uart_rx();
	parameter CLKS_PER_BIT = 8;
	reg t_clk;
	reg t_reset;
	reg t_rx;
	wire [7:0] t_data;
	wire t_done;
	wire t_perr;
	wire t_ferr;

uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uut(
    	.clk(t_clk),
    	.reset(t_reset),
    	.rx_line(t_rx),
    	.rx_data(t_data),
    	.rx_done(t_done),
    	.parity_err(t_perr),
    	.frame_err(t_ferr)
);

always #5 t_clk = ~t_clk;

task send_bit;
    input value;
    begin
        t_rx = value;
        #(CLKS_PER_BIT*10);
    end
endtask

task send_frame;
    input [7:0] data;
    input bad_parity;
    input bad_stop;
    integer i;
    reg p;
    begin
        p = ^data;
        if (bad_parity)
            p = ~p;

        send_bit(1'b0);
        for (i = 0; i < 8; i = i+1)
            send_bit(data[i]);
        send_bit(p);
        if (bad_stop)
            send_bit(1'b0);
        else
            send_bit(1'b1);
    end
endtask

initial begin
    t_clk = 0;
    t_reset = 1;
    t_rx = 1;
    #20;
    t_reset = 0;

    $monitor("Time=%0t done=%b data=%b perr=%b ferr=%b", $time, t_done, t_data, t_perr, t_ferr);

    send_frame(8'b10110010, 1'b0, 1'b0);
    #(CLKS_PER_BIT*10);

    send_frame(8'b00001111, 1'b1, 1'b0);
    #(CLKS_PER_BIT*10);

    send_frame(8'b11110000, 1'b0, 1'b1);
    #(CLKS_PER_BIT*10);

    $finish;
end

endmodule
