module soc_top (clk,
    instruct_en0,
    instruct_en1,
    rst,
    result0,
    result1);
 input clk;
 input instruct_en0;
 input instruct_en1;
 input rst;
 output [31:0] result0;
 output [31:0] result1;

 wire _00_;
 wire _01_;
 wire _02_;
 wire _03_;
 wire _04_;
 wire _05_;
 wire _06_;
 wire _07_;
 wire _08_;
 wire _09_;
 wire _10_;
 wire \core0.pc[2] ;
 wire \core0.pc[3] ;
 wire \core0.pc[4] ;
 wire \core1.pc[2] ;
 wire \core1.pc[3] ;
 wire \core1.pc[4] ;

 sky130_fd_sc_hd__nand2b_2 _11_ (.A_N(\core1.pc[4] ),
    .B(instruct_en1),
    .Y(_06_));
 sky130_fd_sc_hd__nor2_2 _12_ (.A(\core1.pc[2] ),
    .B(_06_),
    .Y(result1[2]));
 sky130_fd_sc_hd__nor2_2 _13_ (.A(\core1.pc[2] ),
    .B(\core1.pc[3] ),
    .Y(_07_));
 sky130_fd_sc_hd__a31o_2 _14_ (.A1(instruct_en1),
    .A2(\core1.pc[4] ),
    .A3(_07_),
    .B1(result1[2]),
    .X(result1[0]));
 sky130_fd_sc_hd__nor3b_2 _15_ (.A(\core0.pc[2] ),
    .B(\core0.pc[4] ),
    .C_N(instruct_en0),
    .Y(result0[2]));
 sky130_fd_sc_hd__nor2_2 _16_ (.A(\core0.pc[2] ),
    .B(\core0.pc[3] ),
    .Y(_08_));
 sky130_fd_sc_hd__a31o_2 _17_ (.A1(instruct_en0),
    .A2(\core0.pc[4] ),
    .A3(_08_),
    .B1(result0[2]),
    .X(result0[0]));
 sky130_fd_sc_hd__a31oi_2 _18_ (.A1(instruct_en1),
    .A2(\core1.pc[4] ),
    .A3(_07_),
    .B1(\core1.pc[2] ),
    .Y(_03_));
 sky130_fd_sc_hd__and2_2 _19_ (.A(\core1.pc[2] ),
    .B(\core1.pc[3] ),
    .X(_09_));
 sky130_fd_sc_hd__nor2_2 _20_ (.A(_07_),
    .B(_09_),
    .Y(_04_));
 sky130_fd_sc_hd__xor2_2 _21_ (.A(\core1.pc[4] ),
    .B(_09_),
    .X(_05_));
 sky130_fd_sc_hd__a31oi_2 _22_ (.A1(instruct_en0),
    .A2(\core0.pc[4] ),
    .A3(_08_),
    .B1(\core0.pc[2] ),
    .Y(_00_));
 sky130_fd_sc_hd__nand2_2 _23_ (.A(\core0.pc[2] ),
    .B(\core0.pc[3] ),
    .Y(_10_));
 sky130_fd_sc_hd__and2b_2 _24_ (.A_N(_08_),
    .B(_10_),
    .X(_01_));
 sky130_fd_sc_hd__xnor2_2 _25_ (.A(\core0.pc[4] ),
    .B(_10_),
    .Y(_02_));
 sky130_fd_sc_hd__dfrtp_2 _26_ (.CLK(clk),
    .D(_00_),
    .RESET_B(rst),
    .Q(\core0.pc[2] ));
 sky130_fd_sc_hd__dfrtp_2 _27_ (.CLK(clk),
    .D(_01_),
    .RESET_B(rst),
    .Q(\core0.pc[3] ));
 sky130_fd_sc_hd__dfrtp_2 _28_ (.CLK(clk),
    .D(_02_),
    .RESET_B(rst),
    .Q(\core0.pc[4] ));
 sky130_fd_sc_hd__dfrtp_2 _29_ (.CLK(clk),
    .D(_03_),
    .RESET_B(rst),
    .Q(\core1.pc[2] ));
 sky130_fd_sc_hd__dfrtp_2 _30_ (.CLK(clk),
    .D(_04_),
    .RESET_B(rst),
    .Q(\core1.pc[3] ));
 sky130_fd_sc_hd__dfrtp_2 _31_ (.CLK(clk),
    .D(_05_),
    .RESET_B(rst),
    .Q(\core1.pc[4] ));
 sky130_fd_sc_hd__conb_1 _32_ (.LO(result0[31]));
 sky130_fd_sc_hd__conb_1 _33_ (.LO(result0[30]));
 sky130_fd_sc_hd__conb_1 _34_ (.LO(result0[29]));
 sky130_fd_sc_hd__conb_1 _35_ (.LO(result0[28]));
 sky130_fd_sc_hd__conb_1 _36_ (.LO(result0[27]));
 sky130_fd_sc_hd__conb_1 _37_ (.LO(result0[26]));
 sky130_fd_sc_hd__conb_1 _38_ (.LO(result0[25]));
 sky130_fd_sc_hd__conb_1 _39_ (.LO(result0[24]));
 sky130_fd_sc_hd__conb_1 _40_ (.LO(result0[23]));
 sky130_fd_sc_hd__conb_1 _41_ (.LO(result0[22]));
 sky130_fd_sc_hd__conb_1 _42_ (.LO(result0[21]));
 sky130_fd_sc_hd__conb_1 _43_ (.LO(result0[20]));
 sky130_fd_sc_hd__conb_1 _44_ (.LO(result0[19]));
 sky130_fd_sc_hd__conb_1 _45_ (.LO(result0[18]));
 sky130_fd_sc_hd__conb_1 _46_ (.LO(result0[17]));
 sky130_fd_sc_hd__conb_1 _47_ (.LO(result0[16]));
 sky130_fd_sc_hd__conb_1 _48_ (.LO(result0[15]));
 sky130_fd_sc_hd__conb_1 _49_ (.LO(result0[14]));
 sky130_fd_sc_hd__conb_1 _50_ (.LO(result0[13]));
 sky130_fd_sc_hd__conb_1 _51_ (.LO(result0[12]));
 sky130_fd_sc_hd__conb_1 _52_ (.LO(result0[11]));
 sky130_fd_sc_hd__conb_1 _53_ (.LO(result0[10]));
 sky130_fd_sc_hd__conb_1 _54_ (.LO(result0[9]));
 sky130_fd_sc_hd__conb_1 _55_ (.LO(result0[8]));
 sky130_fd_sc_hd__conb_1 _56_ (.LO(result0[7]));
 sky130_fd_sc_hd__conb_1 _57_ (.LO(result0[6]));
 sky130_fd_sc_hd__conb_1 _58_ (.LO(result1[31]));
 sky130_fd_sc_hd__conb_1 _59_ (.LO(result1[30]));
 sky130_fd_sc_hd__conb_1 _60_ (.LO(result1[29]));
 sky130_fd_sc_hd__conb_1 _61_ (.LO(result1[28]));
 sky130_fd_sc_hd__conb_1 _62_ (.LO(result1[27]));
 sky130_fd_sc_hd__conb_1 _63_ (.LO(result1[26]));
 sky130_fd_sc_hd__conb_1 _64_ (.LO(result1[25]));
 sky130_fd_sc_hd__conb_1 _65_ (.LO(result1[24]));
 sky130_fd_sc_hd__conb_1 _66_ (.LO(result1[23]));
 sky130_fd_sc_hd__conb_1 _67_ (.LO(result1[22]));
 sky130_fd_sc_hd__conb_1 _68_ (.LO(result1[21]));
 sky130_fd_sc_hd__conb_1 _69_ (.LO(result1[20]));
 sky130_fd_sc_hd__conb_1 _70_ (.LO(result1[19]));
 sky130_fd_sc_hd__conb_1 _71_ (.LO(result1[18]));
 sky130_fd_sc_hd__conb_1 _72_ (.LO(result1[17]));
 sky130_fd_sc_hd__conb_1 _73_ (.LO(result1[16]));
 sky130_fd_sc_hd__conb_1 _74_ (.LO(result1[15]));
 sky130_fd_sc_hd__conb_1 _75_ (.LO(result1[14]));
 sky130_fd_sc_hd__conb_1 _76_ (.LO(result1[13]));
 sky130_fd_sc_hd__conb_1 _77_ (.LO(result1[12]));
 sky130_fd_sc_hd__conb_1 _78_ (.LO(result1[11]));
 sky130_fd_sc_hd__conb_1 _79_ (.LO(result1[10]));
 sky130_fd_sc_hd__conb_1 _80_ (.LO(result1[9]));
 sky130_fd_sc_hd__conb_1 _81_ (.LO(result1[8]));
 sky130_fd_sc_hd__conb_1 _82_ (.LO(result1[7]));
 sky130_fd_sc_hd__conb_1 _83_ (.LO(result1[6]));
 sky130_fd_sc_hd__conb_1 _84_ (.LO(result1[5]));
 sky130_fd_sc_hd__conb_1 _85_ (.LO(result0[5]));
 sky130_fd_sc_hd__conb_1 _86_ (.LO(result1[4]));
 sky130_fd_sc_hd__conb_1 _87_ (.LO(result0[4]));
 sky130_fd_sc_hd__conb_1 _88_ (.LO(result1[3]));
 sky130_fd_sc_hd__conb_1 _89_ (.LO(result0[3]));
 sky130_fd_sc_hd__conb_1 _90_ (.LO(result0[1]));
 sky130_fd_sc_hd__conb_1 _91_ (.LO(result1[1]));
endmodule
