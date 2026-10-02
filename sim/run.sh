#!/bin/bash
set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
OUT_DIR="$ROOT_DIR/sim"

if ! command -v iverilog >/dev/null 2>&1; then
  echo "iverilog is not installed in this environment."
  echo "Install it with your package manager and rerun this script."
  exit 1
fi

iverilog -g2012 -Wall \
  -I "$ROOT_DIR/rtl" \
  -I "$ROOT_DIR/tb" \
  "$ROOT_DIR/rtl/axi4_spi_registers_pkg.sv" \
  "$ROOT_DIR/rtl/axi4_lite_if.sv" \
  "$ROOT_DIR/rtl/spi_if.sv" \
  "$ROOT_DIR/rtl/spi_master.sv" \
  "$ROOT_DIR/rtl/axi4_spi_controller.sv" \
  "$ROOT_DIR/tb/tb_axi4_spi_controller.sv" \
  -o "$OUT_DIR/axi4_spi_controller.vvp"

vvp "$OUT_DIR/axi4_spi_controller.vvp"
