module axi4_spi_controller (
  axi4_lite_if.slave axi_if,
  spi_if.master spi_if
);

  localparam int REG_CTRL   = 8'h00;
  localparam int REG_DIV    = 8'h04;
  localparam int REG_TX     = 8'h08;
  localparam int REG_RX     = 8'h0C;
  localparam int REG_STATUS = 8'h10;

  logic [31:0] reg_ctrl;
  logic [31:0] reg_div;
  logic [31:0] reg_tx;
  logic [31:0] reg_rx;
  logic [31:0] reg_status;
  logic [7:0] spi_rx_data;
  logic start_transfer;
  logic spi_busy;
  logic prev_spi_busy;

  spi_master #(
    .DATA_WIDTH(8),
    .DIV_WIDTH(16)
  ) u_spi_master (
    .clk      (axi_if.aclk),
    .rst_n    (axi_if.aresetn),
    .start    (start_transfer),
    .clk_div  (reg_div[15:0]),
    .tx_data  (reg_tx[7:0]),
    .rx_data  (spi_rx_data),
    .busy     (spi_busy),
    .cs_n     (spi_if.cs_n),
    .sclk     (spi_if.sclk),
    .mosi     (spi_if.mosi),
    .miso     (spi_if.miso)
  );

  always_ff @(posedge axi_if.aclk or negedge axi_if.aresetn) begin
    if (!axi_if.aresetn) begin
      reg_ctrl       <= 32'h0;
      reg_div        <= 32'd2;
      reg_tx         <= 32'h0;
      reg_rx         <= 32'h0;
      reg_status     <= 32'h0;
      spi_rx_data    <= 8'h0;
      start_transfer <= 1'b0;
      prev_spi_busy  <= 1'b0;
      axi_if.awready <= 1'b0;
      axi_if.wready  <= 1'b0;
      axi_if.arready <= 1'b0;
      axi_if.bvalid  <= 1'b0;
      axi_if.bresp   <= 2'b00;
      axi_if.rvalid  <= 1'b0;
      axi_if.rdata   <= 32'h0;
      axi_if.rresp   <= 2'b00;
    end else begin
      axi_if.awready <= 1'b1;
      axi_if.wready  <= 1'b1;
      axi_if.arready <= 1'b1;
      axi_if.bvalid  <= 1'b0;
      axi_if.rvalid  <= 1'b0;
      start_transfer <= 1'b0;
      prev_spi_busy  <= spi_busy;

      if (axi_if.awvalid && axi_if.wvalid) begin
        unique case (axi_if.awaddr[7:0])
          REG_CTRL: begin
            reg_ctrl <= axi_if.wdata & 32'h00000003;
            if (axi_if.wdata[1] && axi_if.wdata[0]) begin
              start_transfer <= 1'b1;
            end
          end
          REG_DIV: begin
            reg_div <= axi_if.wdata;
          end
          REG_TX: begin
            reg_tx <= axi_if.wdata;
            if (reg_ctrl[0]) begin
              start_transfer <= 1'b1;
            end
          end
          default: begin
          end
        endcase

        axi_if.bvalid <= 1'b1;
        axi_if.bresp  <= 2'b00;
      end

      if (axi_if.arvalid) begin
        unique case (axi_if.araddr[7:0])
          REG_CTRL:   axi_if.rdata <= reg_ctrl;
          REG_DIV:    axi_if.rdata <= reg_div;
          REG_TX:     axi_if.rdata <= reg_tx;
          REG_RX:     axi_if.rdata <= reg_rx;
          REG_STATUS: axi_if.rdata <= {31'h0, spi_busy};
          default:    axi_if.rdata <= 32'h0;
        endcase

        axi_if.rvalid <= 1'b1;
        axi_if.rresp  <= 2'b00;
      end

      if (prev_spi_busy && !spi_busy) begin
        reg_rx <= {24'h0, spi_rx_data};
      end

      reg_status <= spi_busy ? 32'h1 : 32'h0;
    end
  end
endmodule
