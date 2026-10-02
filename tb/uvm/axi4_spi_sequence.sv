class axi4_spi_write_seq extends uvm_sequence #(axi4_spi_item);
  `uvm_object_utils(axi4_spi_write_seq)

  rand bit [31:0] addr;
  rand bit [31:0] data;

  function new(string name = "axi4_spi_write_seq");
    super.new(name);
  endfunction

  virtual task body();
    req = axi4_spi_item::type_id::create("req");
    start_item(req);
    req.write = 1'b1;
    req.addr  = addr;
    req.data  = data;
    finish_item(req);
  endtask
endclass

class axi4_spi_read_seq extends uvm_sequence #(axi4_spi_item);
  `uvm_object_utils(axi4_spi_read_seq)

  rand bit [31:0] addr;

  function new(string name = "axi4_spi_read_seq");
    super.new(name);
  endfunction

  virtual task body();
    req = axi4_spi_item::type_id::create("req");
    start_item(req);
    req.write = 1'b0;
    req.addr  = addr;
    req.data  = 32'h0;
    finish_item(req);
  endtask
endclass
