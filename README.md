# AXI4 SPI Controller

This project provides a small but complete SystemVerilog implementation of an AXI4-Lite SPI controller. It is intended as a reusable reference design for embedded verification, hardware-software interfaces, and IP prototyping.

## Features

- AXI4-Lite slave interface for register access
- SPI master mode with configurable clock divider
- 8-bit transmit and receive path
- Busy/status register for software polling
- Simple simulation testbench with a SPI slave model

## Directory layout

- `rtl/` : synthesizable RTL modules
- `tb/` : testbench, BFM, and simulation helpers
- `sim/` : compile/run scripts

## Register map

| Address | Name | Description |
| --- | --- | --- |
| 0x00 | CTRL | Bit 0 = enable, Bit 1 = start transfer |
| 0x04 | DIV | SPI clock divider value |
| 0x08 | TX_DATA | Data to transmit |
| 0x0C | RX_DATA | Received data |
| 0x10 | STATUS | Bit 0 = busy |

## Example usage

1. Program `DIV` with a divider value to set the SPI clock.
2. Write `TX_DATA` with the byte to send.
3. Set `CTRL.start` bit.
4. Poll `STATUS.busy` until it clears.
5. Read `RX_DATA` for the incoming byte.

## Simulation

Run the following from the project root:

```bash
./sim/run.sh
```

The script compiles the RTL and testbench using `iverilog` if available.

## Notes

This is a compact reference implementation, not a full vendor IP block. It is focused on clarity and portability so it can be expanded for more advanced features such as FIFO buffering, DMA, multiple chip-selects, or AXI4 full protocol support.
