#!/usr/bin/env bash
# Run the SpectreNetlister to generate an analog netlist for anatop.
$WORK_DIR/scripts/SpectreNetlister.sh -top gmsk.anatop:schematic -clean
