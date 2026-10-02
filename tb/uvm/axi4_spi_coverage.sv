class axi4_spi_coverage extends uvm_subscriber #(axi4_spi_item);
  `uvm_component_utils(axi4_spi_coverage)

  covergroup spi_addr_cg with function sample(bit [31:0] addr);
    option.per_instance = 1;
    addr_cp: coverpoint addr {
      bins ctrl   = {REG_CTRL};
      bins div    = {REG_DIV};
      bins tx     = {REG_TX};
      bins rx     = {REG_RX};
      bins status = {REG_STATUS};
    }
  endgroup

  covergroup spi_data_cg with function sample(bit [31:0] data);
    option.per_instance = 1;
    data_cp: coverpoint data {
      bins zero   = {32'h0};
      bins small  = {[1:15]};
      bins mid    = {[16:127]};
      bins large  = {[128:255]};
      bins pattern = {[32'hA5A5A5A5, 32'h5A5A5A5A]};
    }
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    spi_addr_cg = new();
    spi_data_cg = new();
  endfunction

  virtual function void write(axi4_spi_item t);
    spi_addr_cg.sample(t.addr);
    spi_data_cg.sample(t.data);
  endfunction
endclass
