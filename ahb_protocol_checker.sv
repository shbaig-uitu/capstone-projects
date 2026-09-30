
`ifndef AHB_PROTOCOL_CHECKER_SV
`define AHB_PROTOCOL_CHECKER_SV

module ahb_protocol_checker (
    input logic         clk,
    input logic         rst_n,
    input logic [31:0] haddr,
    input logic          hwrite,
    input logic [1:0]  hsize,
    input logic [31:0] hwdata,
    input logic          hvalid,
    input logic [31:0] hrdata,
    input logic          hready,
    input logic          hresp
);

    property p_reset_clears_valid;
        @(posedge clk)
        (!rst_n) |-> (!hvalid);
    endproperty
    assert property (p_reset_clears_valid)
        else $error("PROTOCOL VIOLATION: hvalid asserted while rst_n is low");

    property p_no_unknown_addr;
        @(posedge clk) disable iff (!rst_n)
        (hvalid) |-> (!$isunknown(haddr));
    endproperty
    assert property (p_no_unknown_addr)
        else $error("PROTOCOL VIOLATION: haddr contains unknown bits while hvalid is asserted");

    property p_stable_during_wait;
        @(posedge clk) disable iff (!rst_n)
        (hvalid && !hready) |=> ($stable(haddr) && $stable(hwrite) && $stable(hwdata) && $stable(hsize) && hvalid);
    endproperty
    assert property (p_stable_during_wait)
        else $error("PROTOCOL VIOLATION: address/data changed or hvalid dropped while a transfer was still waiting on hready");

    property p_no_indefinite_hang;
        @(posedge clk) disable iff (!rst_n)
        (hvalid) |-> ##[0:5] (hready);
    endproperty
    assert property (p_no_indefinite_hang)
        else $error("PROTOCOL VIOLATION: hready did not arrive within 5 cycles of hvalid being asserted");

    cover property (
        @(posedge clk) disable iff (!rst_n)
        (hvalid && !hready)
    );

endmodule

bind ahb_if ahb_protocol_checker u_ahb_protocol_checker (
    .clk    (clk),
    .rst_n  (rst_n),
    .haddr  (haddr),
    .hwrite (hwrite),
    .hsize  (hsize),
    .hwdata (hwdata),
    .hvalid (hvalid),
    .hrdata (hrdata),
    .hready (hready),
    .hresp  (hresp)
);

`endif