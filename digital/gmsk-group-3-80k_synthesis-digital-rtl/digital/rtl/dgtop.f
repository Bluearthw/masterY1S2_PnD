# Xcelium argument file
# These files serve two purposes:
#   1) Supply arguments to the xrun call (see -f argument)
#   2) Hierarchically collect source files
# Pointers to source files



# Include other f-files
-f $WORK_DIR/digital/rtl/cic/cic.f
-f $WORK_DIR/digital/rtl/dds/dds_cordic.f

# At last, collect dgtop itself
$WORK_DIR/digital/rtl/dgtop.sv
$WORK_DIR/digital/rtl/downmixer/downmixer.v
$WORK_DIR/digital/rtl/mixer/mixer.v

