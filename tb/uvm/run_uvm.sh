#!/bin/bash
set -e

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

if [ -z "$QUESTA_HOME" ]; then
  echo "This script expects a UVM-capable simulator such as Questa or ModelSim."
  echo "Set QUESTA_HOME or use your simulator's equivalent compile command."
  echo "Example:"
  echo "  vlog +acc -mfcu -timescale 1ns/1ps \
    $ROOT_DIR/rtl/axi4_lite_if.sv \
    $ROOT_DIR/rtl/spi_if.sv \
    $ROOT_DIR/rtl/spi_master.sv \
    $ROOT_DIR/rtl/axi4_spi_controller.sv \
    $ROOT_DIR/tb/uvm/axi4_spi_uvm_pkg.sv \
    $ROOT_DIR/tb/uvm/uvm_axi4_spi_top.sv"
  exit 1
fi

vlog +acc -mfcu -timescale 1ns/1ps \
  "$ROOT_DIR/rtl/axi4_spi_registers_pkg.sv" \
  "$ROOT_DIR/rtl/axi4_lite_if.sv" \
  "$ROOT_DIR/rtl/spi_if.sv" \
  "$ROOT_DIR/rtl/spi_master.sv" \
  "$ROOT_DIR/rtl/axi4_spi_controller.sv" \
  "$ROOT_DIR/tb/uvm/spi_slave_model.sv" \
  "$ROOT_DIR/tb/uvm/axi4_spi_uvm_pkg.sv" \
  "$ROOT_DIR/tb/uvm/uvm_axi4_spi_top.sv"

vsim -c -do "run -all; quit" work.uvm_axi4_spi_top
