# AXI4 SPI Controller

This project is a stronger AXI4-Lite SPI master reference design built for a verification-focused portfolio. The RTL is organized for clarity, expandable register access, explicit protocol behavior, and realistic SPI timing for hardware verification work.

## What is improved

- Cleaner AXI4-Lite write/read control flow
- More deterministic SPI shift-register timing
- Better register map handling and transaction gating
- Proper invalid-address response handling
- Reusable UVM write/read sequences
- Functional coverage collection for register access and data values
- A stronger verification harness suitable for a DV portfolio

## Top-level features

- AXI4-Lite slave register interface
- SPI master transaction engine
- Configurable clock divider
- TX/RX byte transfer support
- Busy and status reporting

## Register map

| Address | Name | Description |
| --- | --- | --- |
| 0x00 | CTRL | Bit 0 = enable, Bit 1 = start trigger |
| 0x04 | DIV | SPI clock divider |
| 0x08 | TX_DATA | Byte to transmit |
| 0x0C | RX_DATA | Byte received from SPI slave |
| 0x10 | STATUS | Busy indicator |

## Directory structure

- `rtl/` : synthesizable SystemVerilog RTL
- `tb/` : plain simulation testbench and UVM testbench
- `sim/` : compile/run script

## Simulation

```bash
cd /home/amit/Downloads/AXI4_SPI_Controller
./sim/run.sh
```

This compiles the RTL with `iverilog` when installed.

## UVM verification

The project contains a UVM-style environment in `tb/uvm/` with:

- sequence-based register access
- driver + monitor + scoreboard
- coverage collection for address and data bins
- a simulator wrapper for Questa/ModelSim-style flows

## Notes

This is a compact but realistic controller suitable for learning, building a DV portfolio, and extending into DMA, FIFOs, or multi-chip-select SPI designs.
