package axi4_spi_uvm_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class axi4_spi_item extends uvm_sequence_item;
    rand bit [31:0] addr;
    rand bit [31:0] data;
    rand bit        write;

    `uvm_object_utils_begin(axi4_spi_item)
      `uvm_field_int(addr, UVM_DEFAULT)
      `uvm_field_int(data, UVM_DEFAULT)
      `uvm_field_int(write, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "axi4_spi_item");
      super.new(name);
    endfunction
  endclass

  class axi4_spi_sequencer extends uvm_sequencer #(axi4_spi_item);
    `uvm_component_utils(axi4_spi_sequencer)

    function new(string name = "axi4_spi_sequencer", uvm_component parent = null);
      super.new(name, parent);
    endfunction
  endclass

  class axi4_spi_driver extends uvm_driver #(axi4_spi_item);
    `uvm_component_utils(axi4_spi_driver)

    virtual axi4_lite_if axi_if;

    function new(string name = "axi4_spi_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
      axi4_spi_item req;
      forever begin
        seq_item_port.get_next_item(req);
        drive(req);
        seq_item_port.item_done();
      end
    endtask

    task drive(axi4_spi_item req);
      if (req.write) begin
        @(posedge axi_if.aclk);
        axi_if.awvalid <= 1'b1;
        axi_if.awaddr  <= req.addr;
        axi_if.wvalid  <= 1'b1;
        axi_if.wdata   <= req.data;
        axi_if.wstrb   <= 4'hF;
        while (!(axi_if.awready && axi_if.wready)) begin
          @(posedge axi_if.aclk);
        end
        @(posedge axi_if.aclk);
        axi_if.awvalid <= 1'b0;
        axi_if.wvalid  <= 1'b0;
        while (!axi_if.bvalid) begin
          @(posedge axi_if.aclk);
        end
        axi_if.bready <= 1'b1;
      end else begin
        @(posedge axi_if.aclk);
        axi_if.arvalid <= 1'b1;
        axi_if.araddr  <= req.addr;
        while (!axi_if.arready) begin
          @(posedge axi_if.aclk);
        end
        @(posedge axi_if.aclk);
        axi_if.arvalid <= 1'b0;
        while (!axi_if.rvalid) begin
          @(posedge axi_if.aclk);
        end
      end
    endtask
  endclass

  class axi4_spi_monitor extends uvm_monitor;
    `uvm_component_utils(axi4_spi_monitor)

    virtual axi4_lite_if axi_if;
    uvm_analysis_port #(axi4_spi_item) ap;

    function new(string name = "axi4_spi_monitor", uvm_component parent = null);
      super.new(name, parent);
      ap = new("ap", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      forever begin
        axi4_spi_item item = axi4_spi_item::type_id::create("item");
        @(posedge axi_if.aclk);
        if (axi_if.rvalid) begin
          item.write = 1'b0;
          item.addr  = axi_if.araddr;
          item.data  = axi_if.rdata;
          ap.write(item);
        end
      end
    endtask
  endclass

  class spi_scoreboard extends uvm_component;
    `uvm_component_utils(spi_scoreboard)

    uvm_analysis_imp #(axi4_spi_item, spi_scoreboard) mon_imp;

    function new(string name = "spi_scoreboard", uvm_component parent = null);
      super.new(name, parent);
      mon_imp = new("mon_imp", this);
    endfunction

    virtual function void write(axi4_spi_item item);
      `uvm_info("SCOREBOARD", $sformatf("Observed read: addr=%0h data=%0h", item.addr, item.data), UVM_LOW)
    endfunction
  endclass

  class axi4_spi_env extends uvm_env;
    `uvm_component_utils(axi4_spi_env)

    axi4_spi_sequencer sequencer;
    axi4_spi_driver    driver;
    axi4_spi_monitor   monitor;
    spi_scoreboard    scoreboard;

    function new(string name = "axi4_spi_env", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = axi4_spi_sequencer::type_id::create("sequencer", this);
      driver     = axi4_spi_driver::type_id::create("driver", this);
      monitor    = axi4_spi_monitor::type_id::create("monitor", this);
      scoreboard = spi_scoreboard::type_id::create("scoreboard", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
      monitor.ap.connect(scoreboard.mon_imp);
    endfunction
  endclass

  class axi4_spi_base_test extends uvm_test;
    `uvm_component_utils(axi4_spi_base_test)

    axi4_spi_env env;

    function new(string name = "axi4_spi_base_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = axi4_spi_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      axi4_spi_item req;
      phase.raise_objection(this);
      req = axi4_spi_item::type_id::create("req");
      req.write = 1'b1;
      req.addr  = 32'h00;
      req.data  = 32'h00000003;
      env.sequencer.execute_item(req);
      req.write = 1'b1;
      req.addr  = 32'h04;
      req.data  = 32'h00000002;
      env.sequencer.execute_item(req);
      req.write = 1'b1;
      req.addr  = 32'h08;
      req.data  = 32'h000000A5;
      env.sequencer.execute_item(req);
      phase.drop_objection(this);
    endtask
  endclass
endpackage
