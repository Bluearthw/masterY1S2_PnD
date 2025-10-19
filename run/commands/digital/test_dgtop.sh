#!/usr/bin/env bash
# Command to launch the dgtop testbench

xrun \
  -access +r \
  -input $WORK_DIR/run/commands/digital/probe.tcl \
  +driver_file=$WORK_DIR/run/commands/digital/driver_file.txt \
  -f $WORK_DIR/digital/rtl/dgtop.f \
  $WORK_DIR/digital/tb/components/driver.sv \
  $WORK_DIR/digital/tb/dgtop_tb.sv
