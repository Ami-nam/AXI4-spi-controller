`timescale 1ns/1ps

module tb_axi4_spi_controller;

  reg clk;
  reg rst_n;

  axi4_lite_if axi_if(.aclk(clk), .aresetn(rst_n));
  spi_if spi_if_inst(.clk(clk), .rst_n(rst_n));

  axi4_spi_controller dut (
    .aclk(clk),
    .aresetn(rst_n),
    .awvalid(axi_if.awvalid),
    .awready(axi_if.awready),
    .awaddr(axi_if.awaddr),
    .wvalid(axi_if.wvalid),
    .wready(axi_if.wready),
    .wdata(axi_if.wdata),
    .wstrb(axi_if.wstrb),
    .bvalid(axi_if.bvalid),
    .bready(axi_if.bready),
    .bresp(axi_if.bresp),
    .arvalid(axi_if.arvalid),
    .arready(axi_if.arready),
    .araddr(axi_if.araddr),
    .rvalid(axi_if.rvalid),
    .rready(axi_if.rready),
    .rdata(axi_if.rdata),
    .rresp(axi_if.rresp),
    .cs_n(spi_if_inst.cs_n),
    .sclk(spi_if_inst.sclk),
    .mosi(spi_if_inst.mosi),
    .miso(spi_if_inst.miso)
  );

  spi_slave_model slave (
    .cs_n(spi_if_inst.cs_n),
    .sclk(spi_if_inst.sclk),
    .mosi(spi_if_inst.mosi),
    .miso(spi_if_inst.miso)
  );

  initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    axi_if.awvalid = 1'b0;
    axi_if.wvalid  = 1'b0;
    axi_if.arvalid = 1'b0;
    axi_if.bready  = 1'b1;
    axi_if.rready  = 1'b1;
    repeat (3) @(posedge clk);
    rst_n = 1'b1;
    repeat (2) @(posedge clk);

    write_reg(8'h00, 32'h00000001);
    write_reg(8'h04, 32'h00000002);
    write_reg(8'h08, 32'h000000A5);

    wait_for_busy();
    read_reg(8'h0C);
    read_reg(8'h10);

    if (dut.reg_rx !== 8'h5A) begin
      $error("RX data mismatch: expected 0x5A, got %0h", dut.reg_rx);
    end
    if (dut.reg_status !== 32'h0) begin
      $error("STATUS should be idle after transfer, got %0h", dut.reg_status);
    end

    write_reg(8'h00, 32'h00000002);
    write_reg(8'h08, 32'h000000F0);
    read_reg(8'h10);

    $display("SPI transaction complete");
    $finish;
  end

  always #5 clk = ~clk;

  task write_reg;
    input [7:0] addr;
    input [31:0] data;
    begin
      @(posedge clk);
      axi_if.awvalid <= 1'b1;
      axi_if.awaddr  <= {24'h0, addr};
      axi_if.wvalid  <= 1'b1;
      axi_if.wdata   <= data;
      axi_if.wstrb   <= 4'hF;

      while (!(axi_if.awready && axi_if.wready)) begin
        @(posedge clk);
      end

      @(posedge clk);
      axi_if.awvalid <= 1'b0;
      axi_if.wvalid  <= 1'b0;
      while (!axi_if.bvalid) begin
        @(posedge clk);
      end
      @(posedge clk);
      axi_if.bready <= 1'b1;
    end
  endtask

  task read_reg;
    input [7:0] addr;
    begin
      @(posedge clk);
      axi_if.arvalid <= 1'b1;
      axi_if.araddr  <= {24'h0, addr};
      while (!axi_if.arready) begin
        @(posedge clk);
      end
      @(posedge clk);
      axi_if.arvalid <= 1'b0;
      while (!axi_if.rvalid) begin
        @(posedge clk);
      end
      $display("READ[%h] = %h", addr, axi_if.rdata);
      @(posedge clk);
    end
  endtask

  task wait_for_busy;
    begin
      while (dut.spi_busy) begin
        @(posedge clk);
      end
    end
  endtask

endmodule

module spi_slave_model (
  input  logic cs_n,
  input  logic sclk,
  input  logic mosi,
  output logic miso
);

  reg [7:0] tx_shift;
  reg [7:0] rx_shift;

  initial begin
    tx_shift = 8'h5A;
    rx_shift = 8'h00;
    miso = 1'b0;
  end

  always @(posedge sclk or negedge cs_n) begin
    if (!cs_n) begin
      rx_shift <= {rx_shift[6:0], mosi};
      miso <= tx_shift[7];
      tx_shift <= {tx_shift[6:0], 1'b0};
    end else begin
      tx_shift <= 8'h5A;
      rx_shift <= 8'h00;
      miso <= 1'b0;
    end
  end

endmodule
