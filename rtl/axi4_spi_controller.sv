module axi4_spi_controller (
  input  wire aclk,
  input  wire aresetn,
  input  wire awvalid,
  output reg awready,
  input  wire [31:0] awaddr,
  input  wire wvalid,
  output reg wready,
  input  wire [31:0] wdata,
  input  wire [3:0] wstrb,
  output reg bvalid,
  input  wire bready,
  output reg [1:0] bresp,
  input  wire arvalid,
  output reg arready,
  input  wire [31:0] araddr,
  output reg rvalid,
  input  wire rready,
  output reg [31:0] rdata,
  output reg [1:0] rresp,
  output reg cs_n,
  output reg sclk,
  output reg mosi,
  input  wire miso
);

  localparam REG_CTRL   = 8'h00;
  localparam REG_DIV    = 8'h04;
  localparam REG_TX     = 8'h08;
  localparam REG_RX     = 8'h0C;
  localparam REG_STATUS = 8'h10;

  reg [31:0] reg_ctrl;
  reg [31:0] reg_div;
  reg [31:0] reg_tx;
  reg [31:0] reg_rx;
  reg [31:0] reg_status;
  reg [7:0] spi_rx_data;
  reg start_transfer;
  reg spi_busy;
  reg prev_spi_busy;

  spi_master #(
    .DATA_WIDTH(8),
    .DIV_WIDTH(16)
  ) u_spi_master (
    .clk      (aclk),
    .rst_n    (aresetn),
    .start    (start_transfer),
    .clk_div  (reg_div[15:0]),
    .tx_data  (reg_tx[7:0]),
    .rx_data  (spi_rx_data),
    .busy     (spi_busy),
    .cs_n     (cs_n),
    .sclk     (sclk),
    .mosi     (mosi),
    .miso     (miso)
  );

  always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
      reg_ctrl       <= 32'h0;
      reg_div        <= 32'd2;
      reg_tx         <= 32'h0;
      reg_rx         <= 32'h0;
      reg_status     <= 32'h0;
      start_transfer <= 1'b0;
      prev_spi_busy  <= 1'b0;
      awready        <= 1'b0;
      wready         <= 1'b0;
      arready        <= 1'b0;
      bvalid         <= 1'b0;
      bresp          <= 2'b00;
      rvalid         <= 1'b0;
      rdata          <= 32'h0;
      rresp          <= 2'b00;
    end else begin
      awready <= 1'b1;
      wready  <= 1'b1;
      arready <= 1'b1;
      bvalid  <= 1'b0;
      rvalid  <= 1'b0;
      start_transfer <= 1'b0;
      prev_spi_busy  <= spi_busy;

      if (awvalid && wvalid) begin
        if (awaddr[7:0] == REG_CTRL) begin
          reg_ctrl <= wdata & 32'h00000003;
          if (wdata[0]) begin
            reg_status <= 32'h00000001;
          end
          if (wdata[1] && wdata[0]) begin
            start_transfer <= 1'b1;
          end
          bresp <= 2'b00;
        end else if (awaddr[7:0] == REG_DIV) begin
          reg_div <= wdata;
          bresp <= 2'b00;
        end else if (awaddr[7:0] == REG_TX) begin
          reg_tx <= wdata;
          if (reg_ctrl[0]) begin
            start_transfer <= 1'b1;
          end
          bresp <= 2'b00;
        end else begin
          bresp <= 2'b10;
        end

        bvalid <= 1'b1;
      end

      if (arvalid) begin
        case (araddr[7:0])
          REG_CTRL:   begin rdata <= reg_ctrl; rresp <= 2'b00; end
          REG_DIV:    begin rdata <= reg_div; rresp <= 2'b00; end
          REG_TX:     begin rdata <= reg_tx; rresp <= 2'b00; end
          REG_RX:     begin rdata <= reg_rx; rresp <= 2'b00; end
          REG_STATUS: begin rdata <= reg_status; rresp <= 2'b00; end
          default:    begin rdata <= 32'h0; rresp <= 2'b10; end
        endcase

        rvalid <= 1'b1;
      end

      if (prev_spi_busy && !spi_busy) begin
        reg_rx <= {24'h0, spi_rx_data};
        reg_status <= 32'h00000000;
      end else begin
        reg_status <= spi_busy ? 32'h00000001 : 32'h00000000;
      end
    end
  end
endmodule
