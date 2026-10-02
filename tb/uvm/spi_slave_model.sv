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
