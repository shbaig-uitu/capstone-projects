package vga_uvm_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"


    // ------------------------------------------------------------------
    // Native framebuffer UVM agent. This drives the same native CPU-side
    // interface used by mem_interconnect, allowing the UVM environment to
    // verify actual framebuffer writes/reads and boundary behavior.
    // ------------------------------------------------------------------
    class native_mem_item extends uvm_sequence_item;
        rand bit is_write;
        rand bit [31:0] addr;
        rand bit [31:0] data;
        rand bit [3:0] strb;
        bit [31:0] rdata;

        `uvm_object_utils_begin(native_mem_item)
            `uvm_field_int(is_write, UVM_ALL_ON)
            `uvm_field_int(addr,    UVM_ALL_ON)
            `uvm_field_int(data,    UVM_ALL_ON)
            `uvm_field_int(strb,    UVM_ALL_ON)
            `uvm_field_int(rdata,   UVM_ALL_ON)
        `uvm_object_utils_end

        function new(string name="native_mem_item");
            super.new(name);
        endfunction
    endclass

    class native_mem_sequencer extends uvm_sequencer#(native_mem_item);
        `uvm_component_utils(native_mem_sequencer)
        function new(string name, uvm_component parent);
            super.new(name,parent);
        endfunction
    endclass

    class native_mem_driver extends uvm_driver#(native_mem_item);
        `uvm_component_utils(native_mem_driver)
        virtual native_mem_if vif;

        function new(string name, uvm_component parent);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual native_mem_if)::get(this,"","mem_vif",vif))
                `uvm_fatal("NOVIF","Native memory interface was not supplied")
        endfunction

        task reset_bus();
            vif.mem_valid <= 1'b0;
            vif.mem_instr <= 1'b0;
            vif.mem_addr  <= 32'h0;
            vif.mem_wdata <= 32'h0;
            vif.mem_wstrb <= 4'h0;
        endtask

        task run_phase(uvm_phase phase);
            reset_bus();
            forever begin
                seq_item_port.get_next_item(req);
                @(posedge vif.clk);
                vif.mem_addr  <= req.addr;
                vif.mem_wdata <= req.data;
                vif.mem_wstrb <= req.is_write ? req.strb : 4'h0;
                vif.mem_instr <= 1'b0;
                vif.mem_valid <= 1'b1;
                while(!vif.mem_ready) @(posedge vif.clk);
                #1step;
                if(!req.is_write)
                    req.rdata = vif.mem_rdata;
                @(posedge vif.clk);
                vif.mem_valid <= 1'b0;
                vif.mem_wstrb <= 4'h0;
                seq_item_port.item_done();
            end
        endtask
    endclass

    class native_mem_monitor extends uvm_monitor;
        `uvm_component_utils(native_mem_monitor)
        virtual native_mem_if vif;
        uvm_analysis_port#(native_mem_item) ap;

        function new(string name, uvm_component parent);
            super.new(name,parent); ap=new("ap",this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual native_mem_if)::get(this,"","mem_vif",vif))
                `uvm_fatal("NOVIF","Native memory interface was not supplied")
        endfunction

        task run_phase(uvm_phase phase);
            forever begin
                @(posedge vif.clk);
                #1step;
                if(vif.mem_valid && vif.mem_ready) begin
                    native_mem_item t=new("native_mon");
                    t.addr=vif.mem_addr;
                    t.is_write=|vif.mem_wstrb;
                    t.data=vif.mem_wdata;
                    t.strb=vif.mem_wstrb;
                    if(!t.is_write) t.rdata=vif.mem_rdata;
                    ap.write(t);
                end
            end
        endtask
    endclass

    class native_mem_agent extends uvm_agent;
        `uvm_component_utils(native_mem_agent)
        native_mem_sequencer sqr;
        native_mem_driver drv;
        native_mem_monitor mon;

        function new(string name, uvm_component parent);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sqr=native_mem_sequencer::type_id::create("sqr",this);
            drv=native_mem_driver::type_id::create("drv",this);
            mon=native_mem_monitor::type_id::create("mon",this);
        endfunction

        function void connect_phase(uvm_phase phase);
            drv.seq_item_port.connect(sqr.seq_item_export);
        endfunction
    endclass

    class native_mem_scoreboard extends uvm_component;
        `uvm_component_utils(native_mem_scoreboard)
        uvm_analysis_imp#(native_mem_item,native_mem_scoreboard) item_export;
        bit [7:0] model [0:307199];
        int errors;

        function new(string name, uvm_component parent);
            super.new(name,parent); item_export=new("item_export",this);
        endfunction

        function void build_phase(uvm_phase phase);
            int i;
            super.build_phase(phase);
            errors=0;
            for(i=0;i<307200;i++) model[i]=8'h00;
        endfunction

        function void write(native_mem_item t);
            int unsigned off;
            int unsigned base;
            int lane;
            off = t.addr - 32'h0001_0000;
            if(t.is_write) begin
                base = (off & 32'hFFFF_FFFC);
                for(lane=0; lane<4; lane++) begin
                    if(t.strb[lane] && (base+lane)<307200)
                        model[base+lane] = t.data[8*lane +: 8];
                end
                // A native write outside the framebuffer is not modeled here.
                if(t.addr < 32'h0001_0000 || t.addr >= 32'h0005_B000)
                    `uvm_warning("NATIVE_SB","Write outside framebuffer was not modeled")
            end else begin
                if(t.addr >= 32'h0001_0000 && t.addr < 32'h0005_B000) begin
                    if(t.rdata !== {24'h0,model[off]}) begin
                        `uvm_error("NATIVE_SB",$sformatf("FB read 0x%08h expected 0x%02h got 0x%08h",t.addr,model[off],t.rdata))
                        errors++;
                    end
                end else if(t.rdata !== 32'hDEAD_BEEF) begin
                    `uvm_error("NATIVE_SB",$sformatf("unmapped read 0x%08h expected DEADBEEF got 0x%08h",t.addr,t.rdata))
                    errors++;
                end
            end
        endfunction
    endclass

    class framebuffer_smoke_seq extends uvm_sequence#(native_mem_item);
        `uvm_object_utils(framebuffer_smoke_seq)
        function new(string name="framebuffer_smoke_seq"); super.new(name); endfunction

        task automatic write_mem(bit [31:0] a, bit [31:0] d, bit [3:0] st);
            native_mem_item t=native_mem_item::type_id::create("wr");
            start_item(t); t.is_write=1; t.addr=a; t.data=d; t.strb=st; finish_item(t);
        endtask

        task automatic read_mem(bit [31:0] a);
            native_mem_item t=native_mem_item::type_id::create("rd");
            start_item(t); t.is_write=0; t.addr=a; t.data=0; t.strb=0; finish_item(t);
        endtask

        task body();
            // Word write, byte-lane write, and framebuffer endpoints.
            write_mem(32'h0001_0000,32'h11223344,4'hF);
            read_mem (32'h0001_0000);
            write_mem(32'h0001_0005,32'h0000_AA00,4'h2);
            read_mem (32'h0001_0005);
            read_mem (32'h0001_0003);
            read_mem (32'h0005_AFFF);
            read_mem (32'h0005_B000);
        endtask
    endclass

    class axi_item extends uvm_sequence_item;
        rand bit is_write;
        rand bit [31:0] addr;
        rand bit [31:0] data;
        rand bit [3:0] strb;
        bit [1:0] resp;
        bit [31:0] rdata;

        `uvm_object_utils_begin(axi_item)
            `uvm_field_int(is_write, UVM_ALL_ON)
            `uvm_field_int(addr,    UVM_ALL_ON)
            `uvm_field_int(data,    UVM_ALL_ON)
            `uvm_field_int(strb,    UVM_ALL_ON)
            `uvm_field_int(resp,    UVM_ALL_ON)
            `uvm_field_int(rdata,   UVM_ALL_ON)
        `uvm_object_utils_end

        function new(string name="axi_item");
            super.new(name);
        endfunction
    endclass

    class axi_sequencer extends uvm_sequencer#(axi_item);
        `uvm_component_utils(axi_sequencer)
        function new(string name, uvm_component parent);
            super.new(name,parent);
        endfunction
    endclass

    class axi_driver extends uvm_driver#(axi_item);
        `uvm_component_utils(axi_driver)
        virtual axi_lite_if vif;
        uvm_analysis_port#(axi_item) ap;

        function new(string name, uvm_component parent);
            super.new(name,parent);
            ap = new("ap",this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual axi_lite_if)::get(this,"","vif",vif))
                `uvm_fatal("NOVIF","AXI interface was not supplied")
        endfunction

        task reset_bus();
            vif.awvalid<=0; vif.wvalid<=0; vif.arvalid<=0;
            vif.bready<=0; vif.rready<=0;
        endtask

        task drive_write(axi_item t);
            bit aw_done, w_done;
            aw_done=0; w_done=0;
            @(posedge vif.clk);
            vif.awaddr<=t.addr; vif.awvalid<=1;
            vif.wdata<=t.data; vif.wstrb<=t.strb; vif.wvalid<=1;
            while(!aw_done || !w_done) begin
                @(posedge vif.clk);
                if(vif.awready) aw_done=1;
                if(vif.wready)  w_done=1;
            end
            vif.awvalid<=0; vif.wvalid<=0;
            vif.bready<=1;
            while(!vif.bvalid) @(posedge vif.clk);
            t.resp=vif.bresp;
            @(posedge vif.clk);
            vif.bready<=0;
        endtask

        task drive_read(axi_item t);
            @(posedge vif.clk);
            vif.araddr<=t.addr; vif.arvalid<=1;
            while(!vif.arready) @(posedge vif.clk);
            @(posedge vif.clk);
            vif.arvalid<=0; vif.rready<=1;
            while(!vif.rvalid) @(posedge vif.clk);
            t.rdata=vif.rdata; t.resp=vif.rresp;
            @(posedge vif.clk);
            vif.rready<=0;
        endtask

        task run_phase(uvm_phase phase);
            reset_bus();
            forever begin
                seq_item_port.get_next_item(req);
                if(req.is_write) drive_write(req);
                else drive_read(req);
                ap.write(req);
                seq_item_port.item_done();
            end
        endtask
    endclass

    class axi_monitor extends uvm_monitor;
        `uvm_component_utils(axi_monitor)
        virtual axi_lite_if vif;
        uvm_analysis_port#(axi_item) ap;
        bit aw_seen, w_seen, ar_seen;
        bit [31:0] mon_awaddr, mon_wdata, mon_araddr;
        bit [3:0] mon_wstrb;

        function new(string name, uvm_component parent);
            super.new(name,parent); ap=new("ap",this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual axi_lite_if)::get(this,"","vif",vif))
                `uvm_fatal("NOVIF","AXI interface was not supplied")
        endfunction

        task run_phase(uvm_phase phase);
            forever begin
                @(posedge vif.clk);
                if(vif.awvalid && vif.awready) begin
                    aw_seen=1; mon_awaddr=vif.awaddr;
                end
                if(vif.wvalid && vif.wready) begin
                    w_seen=1; mon_wdata=vif.wdata; mon_wstrb=vif.wstrb;
                end
                if(aw_seen && w_seen && vif.bvalid) begin
                    axi_item t=new("mon_write");
                    t.is_write=1; t.addr=mon_awaddr; t.data=mon_wdata;
                    t.strb=mon_wstrb; t.resp=vif.bresp;
                    ap.write(t); aw_seen=0; w_seen=0;
                end
                if(vif.arvalid && vif.arready) begin
                    ar_seen=1; mon_araddr=vif.araddr;
                end
                if(ar_seen && vif.rvalid) begin
                    axi_item t=new("mon_read");
                    t.is_write=0; t.addr=mon_araddr; t.rdata=vif.rdata; t.resp=vif.rresp;
                    ap.write(t); ar_seen=0;
                end
            end
        endtask
    endclass

    class axi_agent extends uvm_agent;
        `uvm_component_utils(axi_agent)
        axi_sequencer sqr;
        axi_driver drv;
        axi_monitor mon;
        function new(string name, uvm_component parent); super.new(name,parent); endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sqr=axi_sequencer::type_id::create("sqr",this);
            drv=axi_driver::type_id::create("drv",this);
            mon=axi_monitor::type_id::create("mon",this);
        endfunction
        function void connect_phase(uvm_phase phase);
            drv.seq_item_port.connect(sqr.seq_item_export);
        endfunction
    endclass

    class axi_scoreboard extends uvm_component;
        `uvm_component_utils(axi_scoreboard)
        uvm_analysis_imp#(axi_item,axi_scoreboard) item_export;
        bit [31:0] ctrl_model;
        bit [31:0] fb_base_model;

        function new(string name, uvm_component parent);
            super.new(name,parent); item_export=new("item_export",this);
        endfunction
        function void build_phase(uvm_phase phase);
            ctrl_model=0; fb_base_model=32'h0001_0000;
        endfunction

        function void write(axi_item t);
            if(t.is_write) begin
                if(t.resp==2'b00) begin
                    case(t.addr[7:0])
                        8'h00: if(t.strb[0]) ctrl_model=t.data;
                        8'h10: begin
                            if (t.strb[0]) fb_base_model[7:0]   = t.data[7:0];
                            if (t.strb[1]) fb_base_model[15:8]  = t.data[15:8];
                            if (t.strb[2]) fb_base_model[23:16] = t.data[23:16];
                            if (t.strb[3]) fb_base_model[31:24] = t.data[31:24];
                        end
                        default: ;
                    endcase
                end
            end else begin
                case(t.addr[7:0])
                    8'h00: if(t.resp==2'b00 && t.rdata!=={30'h0,ctrl_model[1:0]})
                               `uvm_error("SCORE","CTRL readback mismatch")
                    8'h10: if(t.resp==2'b00 && t.rdata!==fb_base_model)
                               `uvm_error("SCORE","FB_BASE readback mismatch")
                    8'h08: if(t.resp==2'b00 && t.rdata!==640)
                               `uvm_error("SCORE","WIDTH mismatch")
                    8'h0C: if(t.resp==2'b00 && t.rdata!==480)
                               `uvm_error("SCORE","HEIGHT mismatch")
                    default: ;
                endcase
            end
        endfunction
    endclass

    class axi_coverage extends uvm_subscriber#(axi_item);
        `uvm_component_utils(axi_coverage)
        bit is_write_s;
        bit [7:0] addr_s;
        bit [1:0] resp_s;
        covergroup cg;
            cp_dir: coverpoint is_write_s { bins read={0}; bins write={1}; }
            cp_addr: coverpoint addr_s {
                bins ctrl={8'h00}; bins status={8'h04}; bins width={8'h08};
                bins height={8'h0C}; bins fb_base={8'h10}; bins hcount={8'h14};
                bins vcount={8'h18}; bins state={8'h20}; bins frame={8'h24};
                bins invalid={[8'h28:8'hFF]};
            }
            cp_resp: coverpoint resp_s { bins okay={2'b00}; bins error={2'b10}; }
            cross cp_dir,cp_resp;
        endgroup
        function new(string name, uvm_component parent);
            super.new(name,parent); cg=new;
        endfunction
        function void write(axi_item t);
            is_write_s=t.is_write; addr_s=t.addr[7:0]; resp_s=t.resp; cg.sample();
        endfunction
    endclass

    class vga_smoke_seq extends uvm_sequence#(axi_item);
        `uvm_object_utils(vga_smoke_seq)
        virtual axi_lite_if vif;
        function new(string name="vga_smoke_seq"); super.new(name); endfunction
        task pre_body();
            if(!uvm_config_db#(virtual axi_lite_if)::get(null,"*","vif",vif))
                `uvm_fatal("NOVIF","Sequence could not get AXI interface")
        endtask

        task automatic do_write(bit [31:0] a, bit [31:0] d, bit [3:0] st=4'hF);
            axi_item t=axi_item::type_id::create("wr");
            start_item(t); t.is_write=1; t.addr=a; t.data=d; t.strb=st; finish_item(t);
            if(((a[7:0]==8'h7C) || (a[7:0]==8'h10 && d[1:0]!=2'b00)) && t.resp!=2'b10)
                `uvm_error("SEQ","invalid write/configuration should fail")
            if(!((a[7:0]==8'h7C) || (a[7:0]==8'h10 && d[1:0]!=2'b00)) && t.resp!=2'b00)
                `uvm_error("SEQ","valid write failed")
        endtask

        task automatic do_read(bit [31:0] a, bit [31:0] expected, bit [1:0] expected_resp=2'b00);
            axi_item t=axi_item::type_id::create("rd");
            start_item(t); t.is_write=0; t.addr=a; t.data=0; t.strb=0; finish_item(t);
            if(t.resp!==expected_resp) `uvm_error("SEQ","read response mismatch")
            if(expected_resp==2'b00 && t.rdata!==expected)
                `uvm_error("SEQ",$sformatf("read 0x%02h expected 0x%08h got 0x%08h",a[7:0],expected,t.rdata))
        endtask

        task body();
            do_write(32'h1000_0000,32'h0000_0003,4'h1);
            do_read (32'h1000_0000,32'h0000_0003);
            do_write(32'h1000_0010,32'h0002_0000,4'hF);
            do_read (32'h1000_0010,32'h0002_0000);
            do_write(32'h1000_0010,32'h0002_0002,4'hF);
            do_read (32'h1000_0010,32'h0002_0000);
            do_read (32'h1000_0008,32'd640);
            do_read (32'h1000_000C,32'd480);
            do_read (32'h1000_007C,32'h0,2'b10);
            do_write(32'h1000_007C,32'hDEADBEEF,4'hF);
            do_write(32'h1000_0000,32'h0000_0000,4'h1);
            // Give VGA two clocks to see display disable.
            repeat(3) @(posedge vif.clk);
            if(vif.vga_rgb!==8'h00)
                `uvm_error("VGA","RGB is not black after display disable")
            do_write(32'h1000_0000,32'h0000_0001,4'h1);

            // Invalid register/configuration cases plus status/animation reads.
            do_read (32'h1000_007C,32'h0,2'b10);
            do_write(32'h1000_007C,32'hDEADBEEF,4'hF);
            do_read (32'h1000_0028,32'h0,2'b10);

            // Restore the normal framebuffer base before leaving the test.
            do_write(32'h1000_0010,32'h0001_0000,4'hF);
        endtask
    endclass

    class vga_uvm_test extends uvm_test;
        `uvm_component_utils(vga_uvm_test)
        axi_agent agent;
        axi_scoreboard sb;
        axi_coverage cov;
        native_mem_agent mem_agent;
        native_mem_scoreboard mem_sb;
        virtual axi_lite_if vif;
        virtual native_mem_if mem_vif;
        function new(string name, uvm_component parent); super.new(name,parent); endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent=axi_agent::type_id::create("agent",this);
            sb=axi_scoreboard::type_id::create("sb",this);
            cov=axi_coverage::type_id::create("cov",this);
            mem_agent=native_mem_agent::type_id::create("mem_agent",this);
            mem_sb=native_mem_scoreboard::type_id::create("mem_sb",this);
            if(!uvm_config_db#(virtual axi_lite_if)::get(this,"","vif",vif))
                `uvm_fatal("NOVIF","AXI interface missing")
            if(!uvm_config_db#(virtual native_mem_if)::get(this,"","mem_vif",mem_vif))
                `uvm_fatal("NOVIF","Native memory interface missing")
        endfunction
        function void connect_phase(uvm_phase phase);
            // Scoreboard consumes observed DUT transactions, not driver intent.
            agent.mon.ap.connect(sb.item_export);
            agent.mon.ap.connect(cov.analysis_export);
            mem_agent.mon.ap.connect(mem_sb.item_export);
        endfunction
        task run_phase(uvm_phase phase);
            vga_smoke_seq seq;
            phase.raise_objection(this);
            // Run the native framebuffer sequence before changing FB_BASE in
            // the AXI sequence, keeping the two independent bus checks deterministic.
            begin
                framebuffer_smoke_seq mem_seq;
                mem_seq=framebuffer_smoke_seq::type_id::create("mem_seq");
                mem_seq.start(mem_agent.sqr);
            end
            seq=vga_smoke_seq::type_id::create("seq");
            seq.start(agent.sqr);
            phase.drop_objection(this);
        endtask
    endclass
endpackage
