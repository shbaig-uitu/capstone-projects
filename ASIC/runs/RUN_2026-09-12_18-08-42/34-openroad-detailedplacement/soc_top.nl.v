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
 wire net1;
 wire net2;
 wire net4;
 wire net29;
 wire net28;
 wire net27;
 wire net26;
 wire net25;
 wire net24;
 wire net23;
 wire net22;
 wire net21;
 wire net20;
 wire net66;
 wire net19;
 wire net18;
 wire net17;
 wire net16;
 wire net15;
 wire net14;
 wire net13;
 wire net12;
 wire net11;
 wire net10;
 wire net5;
 wire net9;
 wire net8;
 wire net65;
 wire net63;
 wire net61;
 wire net33;
 wire net32;
 wire net31;
 wire net30;
 wire net6;
 wire net55;
 wire net54;
 wire net53;
 wire net52;
 wire net51;
 wire net50;
 wire net49;
 wire net48;
 wire net47;
 wire net46;
 wire net45;
 wire net44;
 wire net43;
 wire net42;
 wire net41;
 wire net40;
 wire net39;
 wire net38;
 wire net37;
 wire net36;
 wire net7;
 wire net35;
 wire net34;
 wire net64;
 wire net62;
 wire net60;
 wire net59;
 wire net58;
 wire net57;
 wire net56;
 wire net3;
 wire net;

 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_0_Left_13 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_0_Right_0 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_10_Left_23 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_10_Right_10 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_11_Left_24 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_11_Right_11 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_12_Left_25 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_12_Right_12 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_1_Left_14 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_1_Right_1 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_2_Left_15 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_2_Right_2 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_3_Left_16 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_3_Right_3 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_4_Left_17 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_4_Right_4 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_5_Left_18 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_5_Right_5 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_6_Left_19 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_6_Right_6 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_7_Left_20 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_7_Right_7 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_8_Left_21 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_8_Right_8 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_9_Left_22 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_9_Right_9 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_26 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_27 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_10_37 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_11_38 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_12_39 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_12_40 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_1_28 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_2_29 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_3_30 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_4_31 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_5_32 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_6_33 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_7_34 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_8_35 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_9_36 ();
 sky130_fd_sc_hd__nand2b_2 _11_ (.A_N(\core1.pc[4] ),
    .B(net2),
    .Y(_06_));
 sky130_fd_sc_hd__nor2_2 _12_ (.A(\core1.pc[2] ),
    .B(_06_),
    .Y(net7));
 sky130_fd_sc_hd__nor2_2 _13_ (.A(\core1.pc[2] ),
    .B(\core1.pc[3] ),
    .Y(_07_));
 sky130_fd_sc_hd__a31o_2 _14_ (.A1(net2),
    .A2(\core1.pc[4] ),
    .A3(_07_),
    .B1(net7),
    .X(net6));
 sky130_fd_sc_hd__nor3b_2 _15_ (.A(\core0.pc[2] ),
    .B(\core0.pc[4] ),
    .C_N(net1),
    .Y(net5));
 sky130_fd_sc_hd__nor2_2 _16_ (.A(\core0.pc[2] ),
    .B(\core0.pc[3] ),
    .Y(_08_));
 sky130_fd_sc_hd__a31o_2 _17_ (.A1(net1),
    .A2(\core0.pc[4] ),
    .A3(_08_),
    .B1(net5),
    .X(net4));
 sky130_fd_sc_hd__a31oi_2 _18_ (.A1(net2),
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
 sky130_fd_sc_hd__a31oi_2 _22_ (.A1(net1),
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
    .RESET_B(net3),
    .Q(\core0.pc[2] ));
 sky130_fd_sc_hd__dfrtp_2 _27_ (.CLK(clk),
    .D(_01_),
    .RESET_B(net3),
    .Q(\core0.pc[3] ));
 sky130_fd_sc_hd__dfrtp_2 _28_ (.CLK(clk),
    .D(_02_),
    .RESET_B(net3),
    .Q(\core0.pc[4] ));
 sky130_fd_sc_hd__dfrtp_2 _29_ (.CLK(clk),
    .D(_03_),
    .RESET_B(net3),
    .Q(\core1.pc[2] ));
 sky130_fd_sc_hd__dfrtp_2 _30_ (.CLK(clk),
    .D(_04_),
    .RESET_B(net3),
    .Q(\core1.pc[3] ));
 sky130_fd_sc_hd__dfrtp_2 _31_ (.CLK(clk),
    .D(_05_),
    .RESET_B(net3),
    .Q(\core1.pc[4] ));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input1 (.A(instruct_en0),
    .X(net1));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input2 (.A(instruct_en1),
    .X(net2));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input3 (.A(rst),
    .X(net3));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output4 (.A(net4),
    .X(result0[0]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output5 (.A(net5),
    .X(result0[2]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output6 (.A(net6),
    .X(result1[0]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output7 (.A(net7),
    .X(result1[2]));
 sky130_fd_sc_hd__conb_1 soc_top (.LO(net));
 sky130_fd_sc_hd__conb_1 soc_top_10 (.LO(net10));
 sky130_fd_sc_hd__conb_1 soc_top_11 (.LO(net11));
 sky130_fd_sc_hd__conb_1 soc_top_12 (.LO(net12));
 sky130_fd_sc_hd__conb_1 soc_top_13 (.LO(net13));
 sky130_fd_sc_hd__conb_1 soc_top_14 (.LO(net14));
 sky130_fd_sc_hd__conb_1 soc_top_15 (.LO(net15));
 sky130_fd_sc_hd__conb_1 soc_top_16 (.LO(net16));
 sky130_fd_sc_hd__conb_1 soc_top_17 (.LO(net17));
 sky130_fd_sc_hd__conb_1 soc_top_18 (.LO(net18));
 sky130_fd_sc_hd__conb_1 soc_top_19 (.LO(net19));
 sky130_fd_sc_hd__conb_1 soc_top_20 (.LO(net20));
 sky130_fd_sc_hd__conb_1 soc_top_21 (.LO(net21));
 sky130_fd_sc_hd__conb_1 soc_top_22 (.LO(net22));
 sky130_fd_sc_hd__conb_1 soc_top_23 (.LO(net23));
 sky130_fd_sc_hd__conb_1 soc_top_24 (.LO(net24));
 sky130_fd_sc_hd__conb_1 soc_top_25 (.LO(net25));
 sky130_fd_sc_hd__conb_1 soc_top_26 (.LO(net26));
 sky130_fd_sc_hd__conb_1 soc_top_27 (.LO(net27));
 sky130_fd_sc_hd__conb_1 soc_top_28 (.LO(net28));
 sky130_fd_sc_hd__conb_1 soc_top_29 (.LO(net29));
 sky130_fd_sc_hd__conb_1 soc_top_30 (.LO(net30));
 sky130_fd_sc_hd__conb_1 soc_top_31 (.LO(net31));
 sky130_fd_sc_hd__conb_1 soc_top_32 (.LO(net32));
 sky130_fd_sc_hd__conb_1 soc_top_33 (.LO(net33));
 sky130_fd_sc_hd__conb_1 soc_top_34 (.LO(net34));
 sky130_fd_sc_hd__conb_1 soc_top_35 (.LO(net35));
 sky130_fd_sc_hd__conb_1 soc_top_36 (.LO(net36));
 sky130_fd_sc_hd__conb_1 soc_top_37 (.LO(net37));
 sky130_fd_sc_hd__conb_1 soc_top_38 (.LO(net38));
 sky130_fd_sc_hd__conb_1 soc_top_39 (.LO(net39));
 sky130_fd_sc_hd__conb_1 soc_top_40 (.LO(net40));
 sky130_fd_sc_hd__conb_1 soc_top_41 (.LO(net41));
 sky130_fd_sc_hd__conb_1 soc_top_42 (.LO(net42));
 sky130_fd_sc_hd__conb_1 soc_top_43 (.LO(net43));
 sky130_fd_sc_hd__conb_1 soc_top_44 (.LO(net44));
 sky130_fd_sc_hd__conb_1 soc_top_45 (.LO(net45));
 sky130_fd_sc_hd__conb_1 soc_top_46 (.LO(net46));
 sky130_fd_sc_hd__conb_1 soc_top_47 (.LO(net47));
 sky130_fd_sc_hd__conb_1 soc_top_48 (.LO(net48));
 sky130_fd_sc_hd__conb_1 soc_top_49 (.LO(net49));
 sky130_fd_sc_hd__conb_1 soc_top_50 (.LO(net50));
 sky130_fd_sc_hd__conb_1 soc_top_51 (.LO(net51));
 sky130_fd_sc_hd__conb_1 soc_top_52 (.LO(net52));
 sky130_fd_sc_hd__conb_1 soc_top_53 (.LO(net53));
 sky130_fd_sc_hd__conb_1 soc_top_54 (.LO(net54));
 sky130_fd_sc_hd__conb_1 soc_top_55 (.LO(net55));
 sky130_fd_sc_hd__conb_1 soc_top_56 (.LO(net56));
 sky130_fd_sc_hd__conb_1 soc_top_57 (.LO(net57));
 sky130_fd_sc_hd__conb_1 soc_top_58 (.LO(net58));
 sky130_fd_sc_hd__conb_1 soc_top_59 (.LO(net59));
 sky130_fd_sc_hd__conb_1 soc_top_60 (.LO(net60));
 sky130_fd_sc_hd__conb_1 soc_top_61 (.LO(net61));
 sky130_fd_sc_hd__conb_1 soc_top_62 (.LO(net62));
 sky130_fd_sc_hd__conb_1 soc_top_63 (.LO(net63));
 sky130_fd_sc_hd__conb_1 soc_top_64 (.LO(net64));
 sky130_fd_sc_hd__conb_1 soc_top_65 (.LO(net65));
 sky130_fd_sc_hd__conb_1 soc_top_66 (.LO(net66));
 sky130_fd_sc_hd__conb_1 soc_top_8 (.LO(net8));
 sky130_fd_sc_hd__conb_1 soc_top_9 (.LO(net9));
 assign result0[10] = net28;
 assign result0[11] = net27;
 assign result0[12] = net26;
 assign result0[13] = net25;
 assign result0[14] = net24;
 assign result0[15] = net23;
 assign result0[16] = net22;
 assign result0[17] = net21;
 assign result0[18] = net20;
 assign result0[19] = net19;
 assign result0[1] = net65;
 assign result0[20] = net18;
 assign result0[21] = net17;
 assign result0[22] = net16;
 assign result0[23] = net15;
 assign result0[24] = net14;
 assign result0[25] = net13;
 assign result0[26] = net12;
 assign result0[27] = net11;
 assign result0[28] = net10;
 assign result0[29] = net9;
 assign result0[30] = net8;
 assign result0[31] = net;
 assign result0[3] = net64;
 assign result0[4] = net62;
 assign result0[5] = net60;
 assign result0[6] = net32;
 assign result0[7] = net31;
 assign result0[8] = net30;
 assign result0[9] = net29;
 assign result1[10] = net54;
 assign result1[11] = net53;
 assign result1[12] = net52;
 assign result1[13] = net51;
 assign result1[14] = net50;
 assign result1[15] = net49;
 assign result1[16] = net48;
 assign result1[17] = net47;
 assign result1[18] = net46;
 assign result1[19] = net45;
 assign result1[1] = net66;
 assign result1[20] = net44;
 assign result1[21] = net43;
 assign result1[22] = net42;
 assign result1[23] = net41;
 assign result1[24] = net40;
 assign result1[25] = net39;
 assign result1[26] = net38;
 assign result1[27] = net37;
 assign result1[28] = net36;
 assign result1[29] = net35;
 assign result1[30] = net34;
 assign result1[31] = net33;
 assign result1[3] = net63;
 assign result1[4] = net61;
 assign result1[5] = net59;
 assign result1[6] = net58;
 assign result1[7] = net57;
 assign result1[8] = net56;
 assign result1[9] = net55;
endmodule
