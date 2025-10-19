#!/usr/bin/env bash
# Command to launch the delay_tb test
# The clean option deletes the xcelium.d directory (of previous runs). All source files are recompiled.

xrun -clean \
  $WORK_DIR/digital/tb/delay_tb.sv \
  $WORK_DIR/digital/rtl/delay/delay.sv
