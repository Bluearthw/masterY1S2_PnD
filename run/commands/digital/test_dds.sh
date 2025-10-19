xrun \
  -sv \
  -gui \
  -debug \
  -linedebug \
  +test_sequence=1 \
  $WORK_DIR/digital/tb/dds_test.sv \
  -f $WORK_DIR/digital/rtl/dds/dds_cordic.f
