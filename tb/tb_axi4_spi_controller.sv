`timescale 1ns/1ps

module tb_axi4_spi_controller;

  logic clk;
  logic rst_n;

  axi4_lite_if axi_if(.aclk(clk), .aresetn(rst_n));
  spi_if spi_if_inst(.clk(clk), .rst_n(rst_n));

  axi4_spi_controller dut (
    .axi_if(axi_if.slave),
    .spi_if(spi_if_inst.master)
  );

  spi_slave_model slave (
    .spi(spi_if_inst.slave)
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

    $display("SPI transaction complete");
    $finish;
  end

  always #5 clk = ~clk;

  task automatic write_reg(input logic [7:0] addr, input logic [31:0] data);
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

  task automatic read_reg(input logic [7:0] addr);
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

  task automatic wait_for_busy();
    begin
      while (dut.spi_busy) begin
        @(posedge clk);
      end
    end
  endtask

endmodule

module spi_slave_model (
  spi_if.slave spi
);

  logic [7:0] tx_shift;
  logic [7:0] rx_shift;

  initial begin
    tx_shift = 8'h5A;
    rx_shift = 8'h00;
    spi.miso = 1'b0;
  end

  always_ff @(posedge spi.sclk or negedge spi.cs_n) begin
    if (!spi.cs_n) begin
      rx_shift <= {rx_shift[6:0], spi.mosi};
      spi.miso <= tx_shift[7];
      tx_shift <= {tx_shift[6:0], 1'b0};
    end else begin
      tx_shift <= 8'h5A;
      rx_shift <= 8'h00;
      spi.miso <= 1'b0;
    end
  end

endmodule
