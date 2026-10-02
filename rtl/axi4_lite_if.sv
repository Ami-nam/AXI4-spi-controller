interface axi4_lite_if(input logic aclk, input logic aresetn);
  logic awvalid;
  logic awready;
  logic [31:0] awaddr;

  logic wvalid;
  logic wready;
  logic [31:0] wdata;
  logic [3:0] wstrb;

  logic bvalid;
  logic bready;
  logic [1:0] bresp;

  logic arvalid;
  logic arready;
  logic [31:0] araddr;

  logic rvalid;
  logic rready;
  logic [31:0] rdata;
  logic [1:0] rresp;

  modport master (
    input  aclk,
    input  aresetn,
    output awvalid,
    input  awready,
    output awaddr,
    output wvalid,
    input  wready,
    output wdata,
    output wstrb,
    input  bvalid,
    output bready,
    input  bresp,
    output arvalid,
    input  arready,
    output araddr,
    input  rvalid,
    output rready,
    input  rdata,
    input  rresp
  );

  modport slave (
    input  aclk,
    input  aresetn,
    input  awvalid,
    output awready,
    input  awaddr,
    input  wvalid,
    output wready,
    input  wdata,
    input  wstrb,
    output bvalid,
    input  bready,
    output bresp,
    input  arvalid,
    output arready,
    input  araddr,
    output rvalid,
    input  rready,
    output rdata,
    output rresp
  );
endinterface
