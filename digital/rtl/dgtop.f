// Xcelium argument file
// These files serve two purposes:
//   1) Supply arguments to the xrun call (see -f argument)
//   2) Hierarchically collect source files

// Pointers to source files
$WORK_DIR/digital/rtl/delay/delay.sv
$WORK_DIR/digital/rtl/toggle/toggle.sv
$WORK_DIR/digital/rtl/inv/inv.sv

// Include other f-files
-f $WORK_DIR/digital/rtl/counter/counter.f

// At last, collect dgtop itself
$WORK_DIR/digital/rtl/dgtop.sv
