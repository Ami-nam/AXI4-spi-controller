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

  typedef enum logic [1:0] {IDLE, ACTIVE, DONE} state_t;

  state_t state;
  logic [DIV_WIDTH-1:0] div_counter;
  logic [DATA_WIDTH-1:0] tx_shift;
  logic [DATA_WIDTH-1:0] rx_shift;
  logic [3:0] bit_index;
  logic phase;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state      <= IDLE;
      div_counter<= '0;
      tx_shift   <= '0;
      rx_shift   <= '0;
      bit_index  <= '0;
      phase      <= 1'b0;
      cs_n       <= 1'b1;
      sclk       <= 1'b0;
      mosi       <= 1'b0;
      rx_data    <= '0;
      busy       <= 1'b0;
    end else begin
      case (state)
        IDLE: begin
          if (start && !busy) begin
            state      <= ACTIVE;
            busy       <= 1'b1;
            cs_n       <= 1'b0;
            sclk       <= 1'b0;
            phase      <= 1'b0;
            div_counter<= '0;
            tx_shift   <= tx_data;
            rx_shift   <= '0;
            bit_index  <= DATA_WIDTH - 1;
            mosi       <= tx_data[DATA_WIDTH-1];
          end
        end

        ACTIVE: begin
          if (div_counter == clk_div) begin
            div_counter <= '0;

            if (phase == 1'b0) begin
              phase <= 1'b1;
              sclk  <= 1'b1;
              mosi  <= tx_shift[DATA_WIDTH-1];
            end else begin
              phase <= 1'b0;
              sclk  <= 1'b0;
              rx_shift <= {rx_shift[DATA_WIDTH-2:0], miso};
              tx_shift <= {tx_shift[DATA_WIDTH-2:0], 1'b0};

              if (bit_index == 0) begin
                state   <= DONE;
                busy    <= 1'b0;
                cs_n    <= 1'b1;
                sclk    <= 1'b0;
                rx_data <= {rx_shift[DATA_WIDTH-2:0], miso};
              end else begin
                bit_index <= bit_index - 1;
                mosi      <= tx_shift[DATA_WIDTH-2];
              end
            end
          end else begin
            div_counter <= div_counter + 1'b1;
          end
        end

        DONE: begin
          state <= IDLE;
          cs_n  <= 1'b1;
          sclk  <= 1'b0;
        end

        default: state <= IDLE;
      endcase
    end
  end
endmodule
