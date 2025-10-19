xrun \
  -sv \
  -gui \
  -debug \
  -linedebug \
  +test_sequence=1 \
  +input_file=$WORK_DIR/digital/tb/cosx0p25m7p5m12bit.txt \
  $WORK_DIR/digital/tb/cic_test.sv \
  -f $WORK_DIR/digital/rtl/cic/cic.f

