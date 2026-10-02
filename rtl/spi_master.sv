module spi_master #(
  parameter int DATA_WIDTH = 8,
  parameter int DIV_WIDTH  = 16
) (
  input  logic clk,
  input  logic rst_n,
  input  logic start,
  input  logic [DIV_WIDTH-1:0] clk_div,
  input  logic [DATA_WIDTH-1:0] tx_data,
  output logic [DATA_WIDTH-1:0] rx_data,
  output logic busy,
  output logic cs_n,
  output logic sclk,
  output logic mosi,
  input  logic miso
);

  logic [DIV_WIDTH-1:0] div_counter;
  logic [DATA_WIDTH-1:0] tx_shift;
  logic [DATA_WIDTH-1:0] rx_shift;
  logic [3:0] bit_count;
  logic clock_phase;
  logic active;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      div_counter <= '0;
      tx_shift    <= '0;
      rx_shift    <= '0;
      bit_count   <= '0;
      clock_phase <= 1'b0;
      cs_n        <= 1'b1;
      sclk        <= 1'b0;
      mosi        <= 1'b0;
      rx_data     <= '0;
      busy        <= 1'b0;
      active      <= 1'b0;
    end else begin
      if (start && !busy) begin
        active      <= 1'b1;
        busy        <= 1'b1;
        cs_n        <= 1'b0;
        tx_shift    <= tx_data;
        rx_shift    <= '0;
        bit_count   <= DATA_WIDTH - 1;
        div_counter <= '0;
        clock_phase <= 1'b0;
        sclk        <= 1'b0;
        mosi        <= tx_data[DATA_WIDTH-1];
      end else if (active) begin
        if (div_counter == clk_div) begin
          div_counter <= '0;
          clock_phase <= ~clock_phase;

          if (!clock_phase) begin
            sclk <= 1'b1;
            mosi <= tx_shift[DATA_WIDTH-1];
          end else begin
            sclk <= 1'b0;
            rx_shift <= {rx_shift[DATA_WIDTH-2:0], miso};
            tx_shift <= {tx_shift[DATA_WIDTH-2:0], 1'b0};
            if (bit_count == 0) begin
              active  <= 1'b0;
              busy    <= 1'b0;
              cs_n    <= 1'b1;
              sclk    <= 1'b0;
              rx_data <= {rx_shift[DATA_WIDTH-2:0], miso};
            end else begin
              bit_count <= bit_count - 1;
            end
          end
        end else begin
          div_counter <= div_counter + 1'b1;
        end
      end
    end
  end
endmodule
