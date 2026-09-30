module riscv_soc_top (axi_arready,
    axi_arvalid,
    axi_awready,
    axi_awvalid,
    axi_bready,
    axi_bvalid,
    axi_rready,
    axi_rvalid,
    axi_wready,
    axi_wvalid,
    clk,
    ext_interrupt,
    rst_n,
    uart_rx,
    uart_tx,
    axi_araddr,
    axi_awaddr,
    axi_bresp,
    axi_rdata,
    axi_rresp,
    axi_wdata,
    axi_wstrb,
    gpio_in,
    gpio_out);
 output axi_arready;
 input axi_arvalid;
 output axi_awready;
 input axi_awvalid;
 input axi_bready;
 output axi_bvalid;
 input axi_rready;
 output axi_rvalid;
 output axi_wready;
 input axi_wvalid;
 input clk;
 input ext_interrupt;
 input rst_n;
 input uart_rx;
 output uart_tx;
 input [31:0] axi_araddr;
 input [31:0] axi_awaddr;
 output [1:0] axi_bresp;
 output [31:0] axi_rdata;
 output [1:0] axi_rresp;
 input [31:0] axi_wdata;
 input [3:0] axi_wstrb;
 input [7:0] gpio_in;
 output [7:0] gpio_out;

 wire _000_;
 wire _001_;
 wire _002_;
 wire _003_;
 wire _004_;
 wire _005_;
 wire _006_;
 wire _007_;
 wire _008_;
 wire _009_;
 wire _010_;
 wire _011_;
 wire _012_;
 wire _013_;
 wire _014_;
 wire _015_;
 wire _016_;
 wire _017_;
 wire _018_;
 wire _019_;
 wire _020_;
 wire _021_;
 wire _022_;
 wire _023_;
 wire _024_;
 wire _025_;
 wire _026_;
 wire _027_;
 wire _028_;
 wire _029_;
 wire _030_;
 wire _031_;
 wire _032_;
 wire _033_;
 wire _034_;
 wire _035_;
 wire _036_;
 wire _037_;
 wire _038_;
 wire _039_;
 wire _040_;
 wire _041_;
 wire _042_;
 wire _043_;
 wire _044_;
 wire _045_;
 wire _046_;
 wire _047_;
 wire _048_;
 wire _049_;
 wire _050_;
 wire _051_;
 wire _052_;
 wire _053_;
 wire _054_;
 wire _055_;
 wire _056_;
 wire _057_;
 wire _058_;
 wire _059_;
 wire _060_;
 wire _061_;
 wire _062_;
 wire _063_;
 wire _064_;
 wire _065_;
 wire _066_;
 wire _067_;
 wire _068_;
 wire _069_;
 wire _070_;
 wire _071_;
 wire _072_;
 wire _073_;
 wire _074_;
 wire _075_;
 wire _076_;
 wire net1;
 wire net2;
 wire net3;
 wire net4;
 wire net5;
 wire net6;
 wire net7;
 wire net8;
 wire net9;
 wire net10;
 wire net11;
 wire net12;
 wire net13;
 wire net14;
 wire net15;
 wire net16;
 wire net17;
 wire net18;
 wire net19;
 wire net20;
 wire net21;
 wire net22;
 wire net23;
 wire net24;
 wire net25;
 wire net26;
 wire net27;
 wire net28;
 wire net29;
 wire net30;
 wire net31;
 wire net32;
 wire net35;
 wire net36;
 wire net83;
 wire net80;
 wire net84;
 wire net37;
 wire net38;
 wire net39;
 wire net40;
 wire net41;
 wire net42;
 wire net43;
 wire net44;
 wire net45;
 wire net46;
 wire net47;
 wire net48;
 wire net49;
 wire net50;
 wire net51;
 wire net52;
 wire net53;
 wire net54;
 wire net55;
 wire net56;
 wire net57;
 wire net58;
 wire net59;
 wire net60;
 wire net61;
 wire net62;
 wire net63;
 wire net64;
 wire net65;
 wire net66;
 wire net67;
 wire net68;
 wire net81;
 wire net82;
 wire clknet_0_clk;
 wire net69;
 wire \counter[0] ;
 wire \counter[10] ;
 wire \counter[11] ;
 wire \counter[12] ;
 wire \counter[13] ;
 wire \counter[14] ;
 wire \counter[15] ;
 wire \counter[16] ;
 wire \counter[17] ;
 wire \counter[18] ;
 wire \counter[19] ;
 wire \counter[1] ;
 wire \counter[20] ;
 wire \counter[21] ;
 wire \counter[22] ;
 wire \counter[23] ;
 wire \counter[24] ;
 wire \counter[25] ;
 wire \counter[26] ;
 wire \counter[27] ;
 wire \counter[28] ;
 wire \counter[29] ;
 wire \counter[2] ;
 wire \counter[30] ;
 wire \counter[31] ;
 wire \counter[3] ;
 wire \counter[4] ;
 wire \counter[5] ;
 wire \counter[6] ;
 wire \counter[7] ;
 wire \counter[8] ;
 wire \counter[9] ;
 wire net70;
 wire net71;
 wire net72;
 wire net73;
 wire net74;
 wire net75;
 wire net76;
 wire net77;
 wire net33;
 wire net34;
 wire net78;
 wire net79;
 wire net;
 wire clknet_2_0__leaf_clk;
 wire clknet_2_1__leaf_clk;
 wire clknet_2_2__leaf_clk;
 wire clknet_2_3__leaf_clk;
 wire net85;
 wire net86;
 wire net87;
 wire net88;
 wire net89;
 wire net90;
 wire net91;
 wire net92;
 wire net93;
 wire net94;
 wire net95;
 wire net96;
 wire net97;
 wire net98;
 wire net99;
 wire net100;
 wire net101;
 wire net102;
 wire net103;
 wire net104;

 sky130_fd_sc_hd__fill_2 FILLER_0_110 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_146 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_29 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_45 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_71 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_74 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_85 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_95 ();
 sky130_fd_sc_hd__decap_3 FILLER_10_136 ();
 sky130_fd_sc_hd__fill_1 FILLER_10_139 ();
 sky130_fd_sc_hd__decap_3 FILLER_10_25 ();
 sky130_fd_sc_hd__decap_3 FILLER_10_29 ();
 sky130_fd_sc_hd__fill_1 FILLER_10_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_10_32 ();
 sky130_fd_sc_hd__decap_3 FILLER_10_43 ();
 sky130_fd_sc_hd__decap_3 FILLER_10_67 ();
 sky130_fd_sc_hd__fill_1 FILLER_10_93 ();
 sky130_fd_sc_hd__fill_2 FILLER_11_113 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_144 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_25 ();
 sky130_fd_sc_hd__fill_1 FILLER_11_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_44 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_47 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_50 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_53 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_60 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_63 ();
 sky130_fd_sc_hd__fill_1 FILLER_11_66 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_78 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_141 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_144 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_50 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_53 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_56 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_59 ();
 sky130_fd_sc_hd__fill_1 FILLER_12_6 ();
 sky130_fd_sc_hd__fill_2 FILLER_12_62 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_85 ();
 sky130_fd_sc_hd__fill_2 FILLER_13_129 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_144 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_3 ();
 sky130_fd_sc_hd__fill_1 FILLER_13_33 ();
 sky130_fd_sc_hd__fill_2 FILLER_13_42 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_52 ();
 sky130_fd_sc_hd__fill_1 FILLER_13_55 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_57 ();
 sky130_fd_sc_hd__fill_1 FILLER_13_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_60 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_63 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_66 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_69 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_72 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_75 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_78 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_81 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_84 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_87 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_90 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_93 ();
 sky130_fd_sc_hd__fill_2 FILLER_14_102 ();
 sky130_fd_sc_hd__fill_2 FILLER_14_125 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_141 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_144 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_24 ();
 sky130_fd_sc_hd__fill_1 FILLER_14_27 ();
 sky130_fd_sc_hd__fill_2 FILLER_14_34 ();
 sky130_fd_sc_hd__fill_2 FILLER_14_44 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_72 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_75 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_78 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_81 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_85 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_88 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_91 ();
 sky130_fd_sc_hd__fill_2 FILLER_14_94 ();
 sky130_fd_sc_hd__decap_3 FILLER_15_53 ();
 sky130_fd_sc_hd__fill_2 FILLER_15_63 ();
 sky130_fd_sc_hd__decap_3 FILLER_15_91 ();
 sky130_fd_sc_hd__decap_3 FILLER_15_94 ();
 sky130_fd_sc_hd__decap_3 FILLER_16_135 ();
 sky130_fd_sc_hd__fill_2 FILLER_16_138 ();
 sky130_fd_sc_hd__decap_3 FILLER_16_141 ();
 sky130_fd_sc_hd__decap_3 FILLER_16_144 ();
 sky130_fd_sc_hd__decap_3 FILLER_16_24 ();
 sky130_fd_sc_hd__fill_1 FILLER_16_27 ();
 sky130_fd_sc_hd__fill_2 FILLER_16_69 ();
 sky130_fd_sc_hd__fill_2 FILLER_17_103 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_126 ();
 sky130_fd_sc_hd__fill_2 FILLER_17_129 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_144 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_41 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_44 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_47 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_57 ();
 sky130_fd_sc_hd__fill_1 FILLER_17_6 ();
 sky130_fd_sc_hd__fill_2 FILLER_17_60 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_70 ();
 sky130_fd_sc_hd__fill_2 FILLER_17_73 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_106 ();
 sky130_fd_sc_hd__fill_2 FILLER_18_109 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_137 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_141 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_144 ();
 sky130_fd_sc_hd__fill_1 FILLER_18_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_38 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_41 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_44 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_47 ();
 sky130_fd_sc_hd__fill_1 FILLER_18_50 ();
 sky130_fd_sc_hd__decap_3 FILLER_19_103 ();
 sky130_fd_sc_hd__decap_3 FILLER_19_106 ();
 sky130_fd_sc_hd__decap_3 FILLER_19_109 ();
 sky130_fd_sc_hd__fill_2 FILLER_19_113 ();
 sky130_fd_sc_hd__decap_3 FILLER_19_144 ();
 sky130_fd_sc_hd__fill_1 FILLER_19_19 ();
 sky130_fd_sc_hd__decap_3 FILLER_19_26 ();
 sky130_fd_sc_hd__decap_3 FILLER_19_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_19_32 ();
 sky130_fd_sc_hd__decap_3 FILLER_19_35 ();
 sky130_fd_sc_hd__fill_2 FILLER_19_43 ();
 sky130_fd_sc_hd__fill_1 FILLER_19_55 ();
 sky130_fd_sc_hd__fill_1 FILLER_19_57 ();
 sky130_fd_sc_hd__fill_1 FILLER_19_74 ();
 sky130_fd_sc_hd__fill_2 FILLER_1_12 ();
 sky130_fd_sc_hd__fill_1 FILLER_1_146 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_51 ();
 sky130_fd_sc_hd__fill_2 FILLER_1_54 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_60 ();
 sky130_fd_sc_hd__fill_1 FILLER_1_63 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_77 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_80 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_9 ();
 sky130_fd_sc_hd__fill_2 FILLER_1_91 ();
 sky130_fd_sc_hd__decap_3 FILLER_20_11 ();
 sky130_fd_sc_hd__decap_3 FILLER_20_111 ();
 sky130_fd_sc_hd__decap_3 FILLER_20_114 ();
 sky130_fd_sc_hd__decap_3 FILLER_20_117 ();
 sky130_fd_sc_hd__decap_3 FILLER_20_120 ();
 sky130_fd_sc_hd__fill_1 FILLER_20_123 ();
 sky130_fd_sc_hd__decap_3 FILLER_20_14 ();
 sky130_fd_sc_hd__decap_3 FILLER_20_141 ();
 sky130_fd_sc_hd__decap_3 FILLER_20_144 ();
 sky130_fd_sc_hd__decap_3 FILLER_20_17 ();
 sky130_fd_sc_hd__decap_3 FILLER_20_20 ();
 sky130_fd_sc_hd__decap_3 FILLER_20_23 ();
 sky130_fd_sc_hd__fill_2 FILLER_20_26 ();
 sky130_fd_sc_hd__decap_3 FILLER_20_29 ();
 sky130_fd_sc_hd__fill_1 FILLER_20_32 ();
 sky130_fd_sc_hd__fill_1 FILLER_20_83 ();
 sky130_fd_sc_hd__fill_1 FILLER_20_85 ();
 sky130_fd_sc_hd__decap_3 FILLER_20_93 ();
 sky130_fd_sc_hd__fill_2 FILLER_20_96 ();
 sky130_fd_sc_hd__decap_3 FILLER_21_11 ();
 sky130_fd_sc_hd__fill_1 FILLER_21_111 ();
 sky130_fd_sc_hd__decap_3 FILLER_21_119 ();
 sky130_fd_sc_hd__decap_3 FILLER_21_122 ();
 sky130_fd_sc_hd__decap_3 FILLER_21_125 ();
 sky130_fd_sc_hd__decap_3 FILLER_21_128 ();
 sky130_fd_sc_hd__decap_3 FILLER_21_14 ();
 sky130_fd_sc_hd__decap_3 FILLER_21_17 ();
 sky130_fd_sc_hd__fill_2 FILLER_21_20 ();
 sky130_fd_sc_hd__decap_3 FILLER_21_78 ();
 sky130_fd_sc_hd__fill_1 FILLER_21_81 ();
 sky130_fd_sc_hd__decap_3 FILLER_22_114 ();
 sky130_fd_sc_hd__decap_3 FILLER_22_117 ();
 sky130_fd_sc_hd__decap_3 FILLER_22_120 ();
 sky130_fd_sc_hd__decap_3 FILLER_22_123 ();
 sky130_fd_sc_hd__decap_3 FILLER_22_126 ();
 sky130_fd_sc_hd__decap_3 FILLER_22_129 ();
 sky130_fd_sc_hd__decap_3 FILLER_22_132 ();
 sky130_fd_sc_hd__decap_3 FILLER_22_135 ();
 sky130_fd_sc_hd__fill_2 FILLER_22_138 ();
 sky130_fd_sc_hd__decap_3 FILLER_22_141 ();
 sky130_fd_sc_hd__decap_3 FILLER_22_15 ();
 sky130_fd_sc_hd__fill_2 FILLER_22_18 ();
 sky130_fd_sc_hd__decap_3 FILLER_22_29 ();
 sky130_fd_sc_hd__fill_2 FILLER_22_53 ();
 sky130_fd_sc_hd__decap_3 FILLER_22_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_22_81 ();
 sky130_fd_sc_hd__fill_2 FILLER_22_9 ();
 sky130_fd_sc_hd__decap_3 FILLER_23_11 ();
 sky130_fd_sc_hd__fill_1 FILLER_23_111 ();
 sky130_fd_sc_hd__decap_3 FILLER_23_121 ();
 sky130_fd_sc_hd__decap_3 FILLER_23_124 ();
 sky130_fd_sc_hd__decap_3 FILLER_23_127 ();
 sky130_fd_sc_hd__decap_3 FILLER_23_130 ();
 sky130_fd_sc_hd__decap_3 FILLER_23_133 ();
 sky130_fd_sc_hd__decap_3 FILLER_23_136 ();
 sky130_fd_sc_hd__decap_3 FILLER_23_14 ();
 sky130_fd_sc_hd__fill_2 FILLER_23_17 ();
 sky130_fd_sc_hd__decap_3 FILLER_23_65 ();
 sky130_fd_sc_hd__fill_1 FILLER_23_68 ();
 sky130_fd_sc_hd__decap_3 FILLER_24_106 ();
 sky130_fd_sc_hd__decap_3 FILLER_24_109 ();
 sky130_fd_sc_hd__decap_3 FILLER_24_129 ();
 sky130_fd_sc_hd__decap_3 FILLER_24_132 ();
 sky130_fd_sc_hd__decap_3 FILLER_24_135 ();
 sky130_fd_sc_hd__fill_2 FILLER_24_138 ();
 sky130_fd_sc_hd__decap_3 FILLER_24_141 ();
 sky130_fd_sc_hd__decap_3 FILLER_24_144 ();
 sky130_fd_sc_hd__fill_1 FILLER_24_27 ();
 sky130_fd_sc_hd__decap_3 FILLER_24_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_24_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_24_32 ();
 sky130_fd_sc_hd__fill_1 FILLER_24_35 ();
 sky130_fd_sc_hd__fill_2 FILLER_24_49 ();
 sky130_fd_sc_hd__decap_3 FILLER_24_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_24_6 ();
 sky130_fd_sc_hd__fill_2 FILLER_24_9 ();
 sky130_fd_sc_hd__decap_3 FILLER_2_12 ();
 sky130_fd_sc_hd__decap_3 FILLER_2_135 ();
 sky130_fd_sc_hd__fill_2 FILLER_2_138 ();
 sky130_fd_sc_hd__decap_3 FILLER_2_141 ();
 sky130_fd_sc_hd__decap_3 FILLER_2_144 ();
 sky130_fd_sc_hd__decap_3 FILLER_2_15 ();
 sky130_fd_sc_hd__fill_2 FILLER_2_18 ();
 sky130_fd_sc_hd__fill_2 FILLER_2_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_2_6 ();
 sky130_fd_sc_hd__fill_1 FILLER_2_70 ();
 sky130_fd_sc_hd__decap_3 FILLER_2_9 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_12 ();
 sky130_fd_sc_hd__fill_2 FILLER_3_129 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_15 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_18 ();
 sky130_fd_sc_hd__fill_1 FILLER_3_21 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_9 ();
 sky130_fd_sc_hd__fill_1 FILLER_4_118 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_12 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_141 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_144 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_15 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_18 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_21 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_24 ();
 sky130_fd_sc_hd__fill_1 FILLER_4_27 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_81 ();
 sky130_fd_sc_hd__fill_1 FILLER_4_85 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_9 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_11 ();
 sky130_fd_sc_hd__fill_1 FILLER_5_111 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_113 ();
 sky130_fd_sc_hd__fill_1 FILLER_5_116 ();
 sky130_fd_sc_hd__fill_1 FILLER_5_125 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_14 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_17 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_28 ();
 sky130_fd_sc_hd__fill_1 FILLER_5_31 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_57 ();
 sky130_fd_sc_hd__fill_1 FILLER_5_60 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_77 ();
 sky130_fd_sc_hd__fill_2 FILLER_5_80 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_116 ();
 sky130_fd_sc_hd__fill_1 FILLER_6_19 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_85 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_28 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_31 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_34 ();
 sky130_fd_sc_hd__fill_1 FILLER_7_37 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_53 ();
 sky130_fd_sc_hd__fill_1 FILLER_7_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_141 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_144 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_3 ();
 sky130_fd_sc_hd__fill_2 FILLER_8_37 ();
 sky130_fd_sc_hd__fill_1 FILLER_8_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_80 ();
 sky130_fd_sc_hd__fill_1 FILLER_8_83 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_121 ();
 sky130_fd_sc_hd__fill_2 FILLER_9_145 ();
 sky130_fd_sc_hd__fill_1 FILLER_9_24 ();
 sky130_fd_sc_hd__fill_2 FILLER_9_41 ();
 sky130_fd_sc_hd__fill_2 FILLER_9_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_72 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_0_Left_25 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_0_Right_0 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_10_Left_35 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_10_Right_10 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_11_Left_36 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_11_Right_11 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_12_Left_37 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_12_Right_12 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_13_Left_38 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_13_Right_13 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_14_Left_39 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_14_Right_14 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_15_Left_40 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_15_Right_15 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_16_Left_41 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_16_Right_16 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_17_Left_42 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_17_Right_17 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_18_Left_43 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_18_Right_18 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_19_Left_44 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_19_Right_19 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_1_Left_26 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_1_Right_1 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_20_Left_45 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_20_Right_20 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_21_Left_46 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_21_Right_21 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_22_Left_47 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_22_Right_22 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_23_Left_48 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_23_Right_23 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_24_Left_49 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_24_Right_24 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_2_Left_27 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_2_Right_2 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_3_Left_28 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_3_Right_3 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_4_Left_29 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_4_Right_4 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_5_Left_30 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_5_Right_5 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_6_Left_31 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_6_Right_6 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_7_Left_32 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_7_Right_7 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_8_Left_33 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_8_Right_8 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_9_Left_34 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_9_Right_9 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_50 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_51 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_52 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_53 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_54 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_10_77 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_10_78 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_10_79 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_11_80 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_11_81 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_12_82 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_12_83 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_12_84 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_13_85 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_13_86 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_14_87 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_14_88 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_14_89 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_15_90 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_15_91 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_16_92 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_16_93 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_16_94 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_17_95 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_17_96 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_18_97 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_18_98 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_18_99 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_19_100 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_19_101 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_1_55 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_1_56 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_20_102 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_20_103 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_20_104 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_21_105 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_21_106 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_22_107 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_22_108 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_22_109 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_23_110 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_23_111 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_24_112 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_24_113 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_24_114 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_24_115 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_24_116 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_2_57 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_2_58 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_2_59 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_3_60 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_3_61 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_4_62 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_4_63 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_4_64 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_5_65 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_5_66 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_6_67 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_6_68 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_6_69 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_7_70 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_7_71 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_8_72 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_8_73 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_8_74 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_9_75 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_9_76 ();
 sky130_fd_sc_hd__inv_2 _077_ (.A(net92),
    .Y(_000_));
 sky130_fd_sc_hd__xor2_2 _078_ (.A(\counter[0] ),
    .B(net1),
    .X(net37));
 sky130_fd_sc_hd__xor2_2 _079_ (.A(\counter[1] ),
    .B(net12),
    .X(net48));
 sky130_fd_sc_hd__xor2_2 _080_ (.A(\counter[2] ),
    .B(net23),
    .X(net59));
 sky130_fd_sc_hd__xor2_2 _081_ (.A(\counter[3] ),
    .B(net26),
    .X(net62));
 sky130_fd_sc_hd__xor2_2 _082_ (.A(\counter[4] ),
    .B(net27),
    .X(net63));
 sky130_fd_sc_hd__xor2_2 _083_ (.A(\counter[5] ),
    .B(net28),
    .X(net64));
 sky130_fd_sc_hd__xor2_2 _084_ (.A(\counter[6] ),
    .B(net29),
    .X(net65));
 sky130_fd_sc_hd__xor2_2 _085_ (.A(\counter[7] ),
    .B(net30),
    .X(net66));
 sky130_fd_sc_hd__xor2_2 _086_ (.A(\counter[8] ),
    .B(net31),
    .X(net67));
 sky130_fd_sc_hd__xor2_2 _087_ (.A(\counter[9] ),
    .B(net32),
    .X(net68));
 sky130_fd_sc_hd__xor2_2 _088_ (.A(\counter[10] ),
    .B(net2),
    .X(net38));
 sky130_fd_sc_hd__xor2_2 _089_ (.A(\counter[11] ),
    .B(net3),
    .X(net39));
 sky130_fd_sc_hd__xor2_2 _090_ (.A(\counter[12] ),
    .B(net4),
    .X(net40));
 sky130_fd_sc_hd__xor2_2 _091_ (.A(\counter[13] ),
    .B(net5),
    .X(net41));
 sky130_fd_sc_hd__xor2_2 _092_ (.A(\counter[14] ),
    .B(net6),
    .X(net42));
 sky130_fd_sc_hd__xor2_2 _093_ (.A(\counter[15] ),
    .B(net7),
    .X(net43));
 sky130_fd_sc_hd__xor2_2 _094_ (.A(\counter[16] ),
    .B(net8),
    .X(net44));
 sky130_fd_sc_hd__xor2_2 _095_ (.A(\counter[17] ),
    .B(net9),
    .X(net45));
 sky130_fd_sc_hd__xor2_2 _096_ (.A(\counter[18] ),
    .B(net10),
    .X(net46));
 sky130_fd_sc_hd__xor2_2 _097_ (.A(\counter[19] ),
    .B(net11),
    .X(net47));
 sky130_fd_sc_hd__xor2_2 _098_ (.A(\counter[20] ),
    .B(net13),
    .X(net49));
 sky130_fd_sc_hd__xor2_2 _099_ (.A(\counter[21] ),
    .B(net14),
    .X(net50));
 sky130_fd_sc_hd__xor2_2 _100_ (.A(\counter[22] ),
    .B(net15),
    .X(net51));
 sky130_fd_sc_hd__xor2_2 _101_ (.A(\counter[23] ),
    .B(net16),
    .X(net52));
 sky130_fd_sc_hd__xor2_2 _102_ (.A(\counter[24] ),
    .B(net17),
    .X(net53));
 sky130_fd_sc_hd__xor2_2 _103_ (.A(\counter[25] ),
    .B(net18),
    .X(net54));
 sky130_fd_sc_hd__xor2_2 _104_ (.A(\counter[26] ),
    .B(net19),
    .X(net55));
 sky130_fd_sc_hd__xor2_2 _105_ (.A(\counter[27] ),
    .B(net20),
    .X(net56));
 sky130_fd_sc_hd__xor2_2 _106_ (.A(\counter[28] ),
    .B(net21),
    .X(net57));
 sky130_fd_sc_hd__xor2_2 _107_ (.A(\counter[29] ),
    .B(net22),
    .X(net58));
 sky130_fd_sc_hd__xor2_2 _108_ (.A(\counter[30] ),
    .B(net24),
    .X(net60));
 sky130_fd_sc_hd__xor2_2 _109_ (.A(\counter[31] ),
    .B(net25),
    .X(net61));
 sky130_fd_sc_hd__nand2_2 _110_ (.A(\counter[0] ),
    .B(\counter[1] ),
    .Y(_033_));
 sky130_fd_sc_hd__or2_2 _111_ (.A(\counter[0] ),
    .B(\counter[1] ),
    .X(_034_));
 sky130_fd_sc_hd__and2_2 _112_ (.A(_033_),
    .B(_034_),
    .X(_011_));
 sky130_fd_sc_hd__xnor2_2 _113_ (.A(net99),
    .B(_033_),
    .Y(_022_));
 sky130_fd_sc_hd__and4_2 _114_ (.A(\counter[0] ),
    .B(\counter[1] ),
    .C(\counter[2] ),
    .D(\counter[3] ),
    .X(_035_));
 sky130_fd_sc_hd__a31o_2 _115_ (.A1(\counter[0] ),
    .A2(\counter[1] ),
    .A3(\counter[2] ),
    .B1(\counter[3] ),
    .X(_036_));
 sky130_fd_sc_hd__and2b_2 _116_ (.A_N(_035_),
    .B(_036_),
    .X(_025_));
 sky130_fd_sc_hd__nand2_2 _117_ (.A(\counter[4] ),
    .B(_035_),
    .Y(_037_));
 sky130_fd_sc_hd__xor2_2 _118_ (.A(\counter[4] ),
    .B(_035_),
    .X(_026_));
 sky130_fd_sc_hd__xnor2_2 _119_ (.A(net98),
    .B(_037_),
    .Y(_027_));
 sky130_fd_sc_hd__and4_2 _120_ (.A(\counter[4] ),
    .B(\counter[5] ),
    .C(\counter[6] ),
    .D(_035_),
    .X(_038_));
 sky130_fd_sc_hd__a31o_2 _121_ (.A1(\counter[4] ),
    .A2(\counter[5] ),
    .A3(_035_),
    .B1(\counter[6] ),
    .X(_039_));
 sky130_fd_sc_hd__and2b_2 _122_ (.A_N(_038_),
    .B(_039_),
    .X(_028_));
 sky130_fd_sc_hd__and4_2 _123_ (.A(\counter[4] ),
    .B(\counter[5] ),
    .C(\counter[6] ),
    .D(\counter[7] ),
    .X(_040_));
 sky130_fd_sc_hd__nand2_2 _124_ (.A(_035_),
    .B(_040_),
    .Y(_041_));
 sky130_fd_sc_hd__o21a_2 _125_ (.A1(net101),
    .A2(_038_),
    .B1(_041_),
    .X(_029_));
 sky130_fd_sc_hd__xnor2_2 _126_ (.A(\counter[8] ),
    .B(_041_),
    .Y(_030_));
 sky130_fd_sc_hd__and2_2 _127_ (.A(\counter[8] ),
    .B(\counter[9] ),
    .X(_042_));
 sky130_fd_sc_hd__nand2_2 _128_ (.A(\counter[8] ),
    .B(\counter[9] ),
    .Y(_043_));
 sky130_fd_sc_hd__a31o_2 _129_ (.A1(\counter[8] ),
    .A2(_035_),
    .A3(_040_),
    .B1(\counter[9] ),
    .X(_044_));
 sky130_fd_sc_hd__o21a_2 _130_ (.A1(_041_),
    .A2(_043_),
    .B1(_044_),
    .X(_031_));
 sky130_fd_sc_hd__and4_2 _131_ (.A(\counter[10] ),
    .B(_035_),
    .C(_040_),
    .D(_042_),
    .X(_045_));
 sky130_fd_sc_hd__o21ba_2 _132_ (.A1(_041_),
    .A2(_043_),
    .B1_N(\counter[10] ),
    .X(_046_));
 sky130_fd_sc_hd__nor2_2 _133_ (.A(_045_),
    .B(_046_),
    .Y(_001_));
 sky130_fd_sc_hd__and2_2 _134_ (.A(\counter[11] ),
    .B(_045_),
    .X(_047_));
 sky130_fd_sc_hd__nor2_2 _135_ (.A(\counter[11] ),
    .B(_045_),
    .Y(_048_));
 sky130_fd_sc_hd__nor2_2 _136_ (.A(_047_),
    .B(_048_),
    .Y(_002_));
 sky130_fd_sc_hd__xor2_2 _137_ (.A(\counter[12] ),
    .B(_047_),
    .X(_003_));
 sky130_fd_sc_hd__a21oi_2 _138_ (.A1(\counter[12] ),
    .A2(_047_),
    .B1(\counter[13] ),
    .Y(_049_));
 sky130_fd_sc_hd__and3_2 _139_ (.A(\counter[12] ),
    .B(\counter[13] ),
    .C(_047_),
    .X(_050_));
 sky130_fd_sc_hd__nor2_2 _140_ (.A(_049_),
    .B(_050_),
    .Y(_004_));
 sky130_fd_sc_hd__and4_2 _141_ (.A(\counter[12] ),
    .B(\counter[13] ),
    .C(\counter[14] ),
    .D(_047_),
    .X(_051_));
 sky130_fd_sc_hd__xor2_2 _142_ (.A(net90),
    .B(_050_),
    .X(_005_));
 sky130_fd_sc_hd__and4_2 _143_ (.A(\counter[12] ),
    .B(\counter[13] ),
    .C(\counter[14] ),
    .D(\counter[15] ),
    .X(_052_));
 sky130_fd_sc_hd__and3_2 _144_ (.A(\counter[11] ),
    .B(_045_),
    .C(_052_),
    .X(_053_));
 sky130_fd_sc_hd__o21ba_2 _145_ (.A1(\counter[15] ),
    .A2(_051_),
    .B1_N(_053_),
    .X(_006_));
 sky130_fd_sc_hd__nand2_2 _146_ (.A(\counter[16] ),
    .B(_053_),
    .Y(_054_));
 sky130_fd_sc_hd__xor2_2 _147_ (.A(\counter[16] ),
    .B(_053_),
    .X(_007_));
 sky130_fd_sc_hd__xnor2_2 _148_ (.A(net100),
    .B(_054_),
    .Y(_008_));
 sky130_fd_sc_hd__a31oi_2 _149_ (.A1(\counter[16] ),
    .A2(\counter[17] ),
    .A3(_053_),
    .B1(\counter[18] ),
    .Y(_055_));
 sky130_fd_sc_hd__and4_2 _150_ (.A(\counter[16] ),
    .B(\counter[17] ),
    .C(\counter[18] ),
    .D(_053_),
    .X(_056_));
 sky130_fd_sc_hd__nor2_2 _151_ (.A(_055_),
    .B(_056_),
    .Y(_009_));
 sky130_fd_sc_hd__and4_2 _152_ (.A(\counter[16] ),
    .B(\counter[17] ),
    .C(\counter[18] ),
    .D(\counter[19] ),
    .X(_057_));
 sky130_fd_sc_hd__and4_2 _153_ (.A(\counter[11] ),
    .B(_045_),
    .C(_052_),
    .D(_057_),
    .X(_058_));
 sky130_fd_sc_hd__o21ba_2 _154_ (.A1(net103),
    .A2(_056_),
    .B1_N(_058_),
    .X(_010_));
 sky130_fd_sc_hd__xor2_2 _155_ (.A(net104),
    .B(_058_),
    .X(_012_));
 sky130_fd_sc_hd__a21oi_2 _156_ (.A1(\counter[20] ),
    .A2(_058_),
    .B1(net97),
    .Y(_059_));
 sky130_fd_sc_hd__and2_2 _157_ (.A(\counter[20] ),
    .B(\counter[21] ),
    .X(_060_));
 sky130_fd_sc_hd__a21oi_2 _158_ (.A1(_058_),
    .A2(_060_),
    .B1(_059_),
    .Y(_013_));
 sky130_fd_sc_hd__a21oi_2 _159_ (.A1(_058_),
    .A2(_060_),
    .B1(\counter[22] ),
    .Y(_061_));
 sky130_fd_sc_hd__and3_2 _160_ (.A(\counter[22] ),
    .B(_058_),
    .C(_060_),
    .X(_062_));
 sky130_fd_sc_hd__nor2_2 _161_ (.A(_061_),
    .B(_062_),
    .Y(_014_));
 sky130_fd_sc_hd__and3_2 _162_ (.A(\counter[21] ),
    .B(\counter[22] ),
    .C(\counter[23] ),
    .X(_063_));
 sky130_fd_sc_hd__and3_2 _163_ (.A(\counter[20] ),
    .B(_057_),
    .C(_063_),
    .X(_064_));
 sky130_fd_sc_hd__and4_2 _164_ (.A(\counter[11] ),
    .B(_045_),
    .C(_052_),
    .D(_064_),
    .X(_065_));
 sky130_fd_sc_hd__and4_2 _165_ (.A(\counter[22] ),
    .B(\counter[23] ),
    .C(_057_),
    .D(_060_),
    .X(_066_));
 sky130_fd_sc_hd__and4_2 _166_ (.A(\counter[11] ),
    .B(_045_),
    .C(_052_),
    .D(_066_),
    .X(_067_));
 sky130_fd_sc_hd__o21ba_2 _167_ (.A1(\counter[23] ),
    .A2(_062_),
    .B1_N(_065_),
    .X(_015_));
 sky130_fd_sc_hd__xor2_2 _168_ (.A(\counter[24] ),
    .B(_065_),
    .X(_016_));
 sky130_fd_sc_hd__a21oi_2 _169_ (.A1(\counter[24] ),
    .A2(_065_),
    .B1(\counter[25] ),
    .Y(_068_));
 sky130_fd_sc_hd__and3_2 _170_ (.A(\counter[24] ),
    .B(\counter[25] ),
    .C(_065_),
    .X(_069_));
 sky130_fd_sc_hd__nor2_2 _171_ (.A(_068_),
    .B(_069_),
    .Y(_017_));
 sky130_fd_sc_hd__and4_2 _172_ (.A(\counter[24] ),
    .B(\counter[25] ),
    .C(\counter[26] ),
    .D(_067_),
    .X(_070_));
 sky130_fd_sc_hd__o21ba_2 _173_ (.A1(\counter[26] ),
    .A2(_069_),
    .B1_N(_070_),
    .X(_018_));
 sky130_fd_sc_hd__and4_2 _174_ (.A(\counter[24] ),
    .B(\counter[25] ),
    .C(\counter[26] ),
    .D(\counter[27] ),
    .X(_071_));
 sky130_fd_sc_hd__o2bb2a_2 _175_ (.A1_N(_065_),
    .A2_N(_071_),
    .B1(_070_),
    .B2(\counter[27] ),
    .X(_019_));
 sky130_fd_sc_hd__a21oi_2 _176_ (.A1(_065_),
    .A2(_071_),
    .B1(\counter[28] ),
    .Y(_072_));
 sky130_fd_sc_hd__and3_2 _177_ (.A(\counter[28] ),
    .B(_067_),
    .C(_071_),
    .X(_073_));
 sky130_fd_sc_hd__nor2_2 _178_ (.A(_072_),
    .B(_073_),
    .Y(_020_));
 sky130_fd_sc_hd__and2_2 _179_ (.A(\counter[28] ),
    .B(\counter[29] ),
    .X(_074_));
 sky130_fd_sc_hd__and3_2 _180_ (.A(_067_),
    .B(_071_),
    .C(_074_),
    .X(_075_));
 sky130_fd_sc_hd__o21ba_2 _181_ (.A1(net102),
    .A2(_073_),
    .B1_N(_075_),
    .X(_021_));
 sky130_fd_sc_hd__and4_2 _182_ (.A(\counter[30] ),
    .B(_065_),
    .C(_071_),
    .D(_074_),
    .X(_076_));
 sky130_fd_sc_hd__xor2_2 _183_ (.A(net96),
    .B(_075_),
    .X(_023_));
 sky130_fd_sc_hd__xor2_2 _184_ (.A(net95),
    .B(_076_),
    .X(_024_));
 sky130_fd_sc_hd__xor2_2 _185_ (.A(net91),
    .B(net34),
    .X(_032_));
 sky130_fd_sc_hd__dfrtp_2 _186_ (.CLK(clknet_2_1__leaf_clk),
    .D(_032_),
    .RESET_B(net33),
    .Q(net78));
 sky130_fd_sc_hd__dfrtp_2 _187_ (.CLK(clknet_2_1__leaf_clk),
    .D(_000_),
    .RESET_B(net33),
    .Q(\counter[0] ));
 sky130_fd_sc_hd__dfrtp_2 _188_ (.CLK(clknet_2_1__leaf_clk),
    .D(_011_),
    .RESET_B(net33),
    .Q(\counter[1] ));
 sky130_fd_sc_hd__dfrtp_2 _189_ (.CLK(clknet_2_1__leaf_clk),
    .D(_022_),
    .RESET_B(net33),
    .Q(\counter[2] ));
 sky130_fd_sc_hd__dfrtp_2 _190_ (.CLK(clknet_2_1__leaf_clk),
    .D(_025_),
    .RESET_B(net33),
    .Q(\counter[3] ));
 sky130_fd_sc_hd__dfrtp_2 _191_ (.CLK(clknet_2_0__leaf_clk),
    .D(_026_),
    .RESET_B(net33),
    .Q(\counter[4] ));
 sky130_fd_sc_hd__dfrtp_2 _192_ (.CLK(clknet_2_0__leaf_clk),
    .D(_027_),
    .RESET_B(net33),
    .Q(\counter[5] ));
 sky130_fd_sc_hd__dfrtp_2 _193_ (.CLK(clknet_2_0__leaf_clk),
    .D(_028_),
    .RESET_B(net33),
    .Q(\counter[6] ));
 sky130_fd_sc_hd__dfrtp_2 _194_ (.CLK(clknet_2_0__leaf_clk),
    .D(_029_),
    .RESET_B(net33),
    .Q(\counter[7] ));
 sky130_fd_sc_hd__dfrtp_2 _195_ (.CLK(clknet_2_1__leaf_clk),
    .D(_030_),
    .RESET_B(net79),
    .Q(\counter[8] ));
 sky130_fd_sc_hd__dfrtp_2 _196_ (.CLK(clknet_2_0__leaf_clk),
    .D(_031_),
    .RESET_B(net79),
    .Q(\counter[9] ));
 sky130_fd_sc_hd__dfrtp_2 _197_ (.CLK(clknet_2_0__leaf_clk),
    .D(_001_),
    .RESET_B(net79),
    .Q(\counter[10] ));
 sky130_fd_sc_hd__dfrtp_2 _198_ (.CLK(clknet_2_2__leaf_clk),
    .D(_002_),
    .RESET_B(net79),
    .Q(\counter[11] ));
 sky130_fd_sc_hd__dfrtp_2 _199_ (.CLK(clknet_2_2__leaf_clk),
    .D(_003_),
    .RESET_B(net79),
    .Q(\counter[12] ));
 sky130_fd_sc_hd__dfrtp_2 _200_ (.CLK(clknet_2_2__leaf_clk),
    .D(_004_),
    .RESET_B(net79),
    .Q(\counter[13] ));
 sky130_fd_sc_hd__dfrtp_2 _201_ (.CLK(clknet_2_2__leaf_clk),
    .D(_005_),
    .RESET_B(net79),
    .Q(\counter[14] ));
 sky130_fd_sc_hd__dfrtp_2 _202_ (.CLK(clknet_2_2__leaf_clk),
    .D(_006_),
    .RESET_B(net79),
    .Q(\counter[15] ));
 sky130_fd_sc_hd__dfrtp_2 _203_ (.CLK(clknet_2_2__leaf_clk),
    .D(_007_),
    .RESET_B(net79),
    .Q(\counter[16] ));
 sky130_fd_sc_hd__dfrtp_2 _204_ (.CLK(clknet_2_2__leaf_clk),
    .D(_008_),
    .RESET_B(net79),
    .Q(\counter[17] ));
 sky130_fd_sc_hd__dfrtp_2 _205_ (.CLK(clknet_2_2__leaf_clk),
    .D(_009_),
    .RESET_B(net79),
    .Q(\counter[18] ));
 sky130_fd_sc_hd__dfrtp_2 _206_ (.CLK(clknet_2_2__leaf_clk),
    .D(_010_),
    .RESET_B(net79),
    .Q(\counter[19] ));
 sky130_fd_sc_hd__dfrtp_2 _207_ (.CLK(clknet_2_3__leaf_clk),
    .D(_012_),
    .RESET_B(net79),
    .Q(\counter[20] ));
 sky130_fd_sc_hd__dfrtp_2 _208_ (.CLK(clknet_2_3__leaf_clk),
    .D(_013_),
    .RESET_B(net79),
    .Q(\counter[21] ));
 sky130_fd_sc_hd__dfrtp_2 _209_ (.CLK(clknet_2_3__leaf_clk),
    .D(_014_),
    .RESET_B(net79),
    .Q(\counter[22] ));
 sky130_fd_sc_hd__dfrtp_2 _210_ (.CLK(clknet_2_3__leaf_clk),
    .D(_015_),
    .RESET_B(net79),
    .Q(\counter[23] ));
 sky130_fd_sc_hd__dfrtp_2 _211_ (.CLK(clknet_2_3__leaf_clk),
    .D(_016_),
    .RESET_B(net79),
    .Q(\counter[24] ));
 sky130_fd_sc_hd__dfrtp_2 _212_ (.CLK(clknet_2_3__leaf_clk),
    .D(_017_),
    .RESET_B(net79),
    .Q(\counter[25] ));
 sky130_fd_sc_hd__dfrtp_2 _213_ (.CLK(clknet_2_3__leaf_clk),
    .D(_018_),
    .RESET_B(net79),
    .Q(\counter[26] ));
 sky130_fd_sc_hd__dfrtp_2 _214_ (.CLK(clknet_2_3__leaf_clk),
    .D(_019_),
    .RESET_B(net79),
    .Q(\counter[27] ));
 sky130_fd_sc_hd__dfrtp_2 _215_ (.CLK(clknet_2_1__leaf_clk),
    .D(_020_),
    .RESET_B(net79),
    .Q(\counter[28] ));
 sky130_fd_sc_hd__dfrtp_2 _216_ (.CLK(clknet_2_1__leaf_clk),
    .D(_021_),
    .RESET_B(net79),
    .Q(\counter[29] ));
 sky130_fd_sc_hd__dfrtp_2 _217_ (.CLK(clknet_2_1__leaf_clk),
    .D(_023_),
    .RESET_B(net79),
    .Q(\counter[30] ));
 sky130_fd_sc_hd__dfrtp_2 _218_ (.CLK(clknet_2_1__leaf_clk),
    .D(_024_),
    .RESET_B(net79),
    .Q(\counter[31] ));
 sky130_fd_sc_hd__dfrtp_2 _219_ (.CLK(clknet_2_1__leaf_clk),
    .D(net93),
    .RESET_B(net79),
    .Q(net70));
 sky130_fd_sc_hd__dfrtp_2 _220_ (.CLK(clknet_2_1__leaf_clk),
    .D(net87),
    .RESET_B(net79),
    .Q(net71));
 sky130_fd_sc_hd__dfrtp_2 _221_ (.CLK(clknet_2_0__leaf_clk),
    .D(net85),
    .RESET_B(net79),
    .Q(net72));
 sky130_fd_sc_hd__dfrtp_2 _222_ (.CLK(clknet_2_2__leaf_clk),
    .D(net89),
    .RESET_B(net79),
    .Q(net73));
 sky130_fd_sc_hd__dfrtp_2 _223_ (.CLK(clknet_2_0__leaf_clk),
    .D(net94),
    .RESET_B(net79),
    .Q(net74));
 sky130_fd_sc_hd__dfrtp_2 _224_ (.CLK(clknet_2_2__leaf_clk),
    .D(net88),
    .RESET_B(net79),
    .Q(net75));
 sky130_fd_sc_hd__dfrtp_2 _225_ (.CLK(clknet_2_2__leaf_clk),
    .D(net90),
    .RESET_B(net79),
    .Q(net76));
 sky130_fd_sc_hd__dfrtp_2 _226_ (.CLK(clknet_2_2__leaf_clk),
    .D(net86),
    .RESET_B(net79),
    .Q(net77));
 sky130_fd_sc_hd__buf_2 _233_ (.A(axi_arvalid),
    .X(net35));
 sky130_fd_sc_hd__buf_2 _234_ (.A(axi_awvalid),
    .X(net36));
 sky130_fd_sc_hd__buf_2 _235_ (.A(axi_wvalid),
    .X(net69));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_0_clk (.A(clk),
    .X(clknet_0_clk));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_2_0__f_clk (.A(clknet_0_clk),
    .X(clknet_2_0__leaf_clk));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_2_1__f_clk (.A(clknet_0_clk),
    .X(clknet_2_1__leaf_clk));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_2_2__f_clk (.A(clknet_0_clk),
    .X(clknet_2_2__leaf_clk));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_2_3__f_clk (.A(clknet_0_clk),
    .X(clknet_2_3__leaf_clk));
 sky130_fd_sc_hd__inv_4 clkload0 (.A(clknet_2_0__leaf_clk));
 sky130_fd_sc_hd__clkbuf_4 clkload1 (.A(clknet_2_1__leaf_clk));
 sky130_fd_sc_hd__inv_4 clkload2 (.A(clknet_2_3__leaf_clk));
 sky130_fd_sc_hd__dlygate4sd3_1 hold100 (.A(\counter[17] ),
    .X(net100));
 sky130_fd_sc_hd__dlygate4sd3_1 hold101 (.A(\counter[7] ),
    .X(net101));
 sky130_fd_sc_hd__dlygate4sd3_1 hold102 (.A(\counter[29] ),
    .X(net102));
 sky130_fd_sc_hd__dlygate4sd3_1 hold103 (.A(\counter[19] ),
    .X(net103));
 sky130_fd_sc_hd__dlygate4sd3_1 hold104 (.A(\counter[20] ),
    .X(net104));
 sky130_fd_sc_hd__dlygate4sd3_1 hold85 (.A(\counter[10] ),
    .X(net85));
 sky130_fd_sc_hd__dlygate4sd3_1 hold86 (.A(\counter[15] ),
    .X(net86));
 sky130_fd_sc_hd__dlygate4sd3_1 hold87 (.A(\counter[9] ),
    .X(net87));
 sky130_fd_sc_hd__dlygate4sd3_1 hold88 (.A(\counter[13] ),
    .X(net88));
 sky130_fd_sc_hd__dlygate4sd3_1 hold89 (.A(\counter[11] ),
    .X(net89));
 sky130_fd_sc_hd__dlygate4sd3_1 hold90 (.A(\counter[14] ),
    .X(net90));
 sky130_fd_sc_hd__dlygate4sd3_1 hold91 (.A(net78),
    .X(net91));
 sky130_fd_sc_hd__dlygate4sd3_1 hold92 (.A(\counter[0] ),
    .X(net92));
 sky130_fd_sc_hd__dlygate4sd3_1 hold93 (.A(\counter[8] ),
    .X(net93));
 sky130_fd_sc_hd__dlygate4sd3_1 hold94 (.A(\counter[12] ),
    .X(net94));
 sky130_fd_sc_hd__dlygate4sd3_1 hold95 (.A(\counter[31] ),
    .X(net95));
 sky130_fd_sc_hd__dlygate4sd3_1 hold96 (.A(\counter[30] ),
    .X(net96));
 sky130_fd_sc_hd__dlygate4sd3_1 hold97 (.A(\counter[21] ),
    .X(net97));
 sky130_fd_sc_hd__dlygate4sd3_1 hold98 (.A(\counter[5] ),
    .X(net98));
 sky130_fd_sc_hd__dlygate4sd3_1 hold99 (.A(\counter[2] ),
    .X(net99));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input1 (.A(axi_araddr[0]),
    .X(net1));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input10 (.A(axi_araddr[18]),
    .X(net10));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input11 (.A(axi_araddr[19]),
    .X(net11));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input12 (.A(axi_araddr[1]),
    .X(net12));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input13 (.A(axi_araddr[20]),
    .X(net13));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input14 (.A(axi_araddr[21]),
    .X(net14));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input15 (.A(axi_araddr[22]),
    .X(net15));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input16 (.A(axi_araddr[23]),
    .X(net16));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input17 (.A(axi_araddr[24]),
    .X(net17));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input18 (.A(axi_araddr[25]),
    .X(net18));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input19 (.A(axi_araddr[26]),
    .X(net19));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input2 (.A(axi_araddr[10]),
    .X(net2));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input20 (.A(axi_araddr[27]),
    .X(net20));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input21 (.A(axi_araddr[28]),
    .X(net21));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input22 (.A(axi_araddr[29]),
    .X(net22));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input23 (.A(axi_araddr[2]),
    .X(net23));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input24 (.A(axi_araddr[30]),
    .X(net24));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input25 (.A(axi_araddr[31]),
    .X(net25));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input26 (.A(axi_araddr[3]),
    .X(net26));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input27 (.A(axi_araddr[4]),
    .X(net27));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input28 (.A(axi_araddr[5]),
    .X(net28));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input29 (.A(axi_araddr[6]),
    .X(net29));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input3 (.A(axi_araddr[11]),
    .X(net3));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input30 (.A(axi_araddr[7]),
    .X(net30));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input31 (.A(axi_araddr[8]),
    .X(net31));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input32 (.A(axi_araddr[9]),
    .X(net32));
 sky130_fd_sc_hd__buf_4 input33 (.A(rst_n),
    .X(net33));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input34 (.A(uart_rx),
    .X(net34));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input4 (.A(axi_araddr[12]),
    .X(net4));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input5 (.A(axi_araddr[13]),
    .X(net5));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input6 (.A(axi_araddr[14]),
    .X(net6));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input7 (.A(axi_araddr[15]),
    .X(net7));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input8 (.A(axi_araddr[16]),
    .X(net8));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input9 (.A(axi_araddr[17]),
    .X(net9));
 sky130_fd_sc_hd__buf_12 max_cap79 (.A(net33),
    .X(net79));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output35 (.A(net35),
    .X(axi_arready));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output36 (.A(net36),
    .X(axi_awready));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output37 (.A(net37),
    .X(axi_rdata[0]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output38 (.A(net38),
    .X(axi_rdata[10]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output39 (.A(net39),
    .X(axi_rdata[11]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output40 (.A(net40),
    .X(axi_rdata[12]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output41 (.A(net41),
    .X(axi_rdata[13]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output42 (.A(net42),
    .X(axi_rdata[14]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output43 (.A(net43),
    .X(axi_rdata[15]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output44 (.A(net44),
    .X(axi_rdata[16]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output45 (.A(net45),
    .X(axi_rdata[17]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output46 (.A(net46),
    .X(axi_rdata[18]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output47 (.A(net47),
    .X(axi_rdata[19]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output48 (.A(net48),
    .X(axi_rdata[1]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output49 (.A(net49),
    .X(axi_rdata[20]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output50 (.A(net50),
    .X(axi_rdata[21]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output51 (.A(net51),
    .X(axi_rdata[22]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output52 (.A(net52),
    .X(axi_rdata[23]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output53 (.A(net53),
    .X(axi_rdata[24]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output54 (.A(net54),
    .X(axi_rdata[25]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output55 (.A(net55),
    .X(axi_rdata[26]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output56 (.A(net56),
    .X(axi_rdata[27]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output57 (.A(net57),
    .X(axi_rdata[28]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output58 (.A(net58),
    .X(axi_rdata[29]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output59 (.A(net59),
    .X(axi_rdata[2]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output60 (.A(net60),
    .X(axi_rdata[30]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output61 (.A(net61),
    .X(axi_rdata[31]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output62 (.A(net62),
    .X(axi_rdata[3]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output63 (.A(net63),
    .X(axi_rdata[4]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output64 (.A(net64),
    .X(axi_rdata[5]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output65 (.A(net65),
    .X(axi_rdata[6]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output66 (.A(net66),
    .X(axi_rdata[7]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output67 (.A(net67),
    .X(axi_rdata[8]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output68 (.A(net68),
    .X(axi_rdata[9]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output69 (.A(net69),
    .X(axi_wready));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output70 (.A(net70),
    .X(gpio_out[0]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output71 (.A(net71),
    .X(gpio_out[1]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output72 (.A(net72),
    .X(gpio_out[2]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output73 (.A(net73),
    .X(gpio_out[3]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output74 (.A(net74),
    .X(gpio_out[4]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output75 (.A(net75),
    .X(gpio_out[5]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output76 (.A(net76),
    .X(gpio_out[6]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output77 (.A(net77),
    .X(gpio_out[7]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output78 (.A(net78),
    .X(uart_tx));
 sky130_fd_sc_hd__conb_1 riscv_soc_top (.LO(net));
 sky130_fd_sc_hd__conb_1 riscv_soc_top_80 (.LO(net80));
 sky130_fd_sc_hd__conb_1 riscv_soc_top_81 (.LO(net81));
 sky130_fd_sc_hd__conb_1 riscv_soc_top_82 (.LO(net82));
 sky130_fd_sc_hd__conb_1 riscv_soc_top_83 (.HI(net83));
 sky130_fd_sc_hd__conb_1 riscv_soc_top_84 (.HI(net84));
 assign axi_bresp[0] = net82;
 assign axi_bresp[1] = net;
 assign axi_bvalid = net83;
 assign axi_rresp[0] = net80;
 assign axi_rresp[1] = net81;
 assign axi_rvalid = net84;
endmodule
