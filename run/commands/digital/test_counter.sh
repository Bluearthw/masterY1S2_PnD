#!/usr/bin/env bash
# Command to launch the delay_tb test with simVision GUI.
# This command will launch Cadence Simvision. You can inspect waves by adding the desired signals to the waveform window.
# The simulation can be started by pressing the "Start/continue simulation" button.
# The debug option (or identically -access +rw) gives read/write access to simulation objects, allowing you to see waves.
# With the -linedebug option, you can control linebreaks through the source window.

xrun \
  -gui \
  -debug \
  -linedebug \
  +test_sequence=1 \
  $WORK_DIR/digital/tb/counter_tb.sv \
  -f $WORK_DIR/digital/rtl/counter/counter.f
