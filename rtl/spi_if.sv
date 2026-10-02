interface spi_if(input logic clk, input logic rst_n);
  logic cs_n;
  logic sclk;
  logic mosi;
  logic miso;

  modport master (
    output cs_n,
    output sclk,
    output mosi,
    input  miso
  );

  modport slave (
    input  cs_n,
    input  sclk,
    input  mosi,
    output miso
  );
endinterface
