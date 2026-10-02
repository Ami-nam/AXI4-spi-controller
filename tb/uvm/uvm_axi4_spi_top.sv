`timescale 1ns/1ps

import uvm_pkg::*;
import axi4_spi_uvm_pkg::*;

module uvm_axi4_spi_top;
  logic clk;
  logic rst_n;

  axi4_lite_if axi_if(.aclk(clk), .aresetn(rst_n));
  spi_if spi_if_inst(.clk(clk), .rst_n(rst_n));

  axi4_spi_controller dut (
    .axi_if(axi_if),
    .spi_if(spi_if_inst)
  );

  spi_slave_model slave (
    .spi(spi_if_inst)
  );

  initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    repeat (5) @(posedge clk);
    rst_n = 1'b1;
  end

  always #5 clk = ~clk;

  initial begin
    uvm_config_db #(virtual axi4_lite_if)::set(null, "uvm_test_top.env.driver", "axi_if", axi_if);
    uvm_config_db #(virtual axi4_lite_if)::set(null, "uvm_test_top.env.monitor", "axi_if", axi_if);
    run_test("axi4_spi_base_test");
  end
endmodule
