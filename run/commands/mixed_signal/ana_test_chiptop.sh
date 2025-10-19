#!/usr/bin/env bash
# 1) Run the SpectreNetlister to generate an analog netlist for anatop
$WORK_DIR/scripts/SpectreNetlister.sh -top gmsk.mix_anatop:schematic -clean -out ./anatop.scs

# 2) Run the chiptop simulation
#    See Spectre AMS Designer and Xcelium Simulator Mixed-Signal User Guide for more information.
#    The netlister does not provide direct links to the models used (using spectre include statements),
#    we can however link this information through xrun argument -modelpath.
  # -debug \
  # -linedebug \ liberal
xrun \
  -gui \
  -dms_cosim \
  -dms_perf \
  -dms_report \
  -access +r \
  -timescale 1ns/10ps \
  -spectre_args "++aps=conservative"\
  -top chiptop_tb \
  -modelpath "$PDK_DIR/models/spectre/toplevel.scs(tt_lib)" \
  $WORK_DIR/run/commands/mixed_signal/amscf.scs \
  -f $WORK_DIR/chiptop/tb/chiptop_tb.f \
  -input $WORK_DIR/run/commands/mixed_signal/probe2.tcl
