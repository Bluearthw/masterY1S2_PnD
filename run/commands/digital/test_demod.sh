xrun \
  -sv \
  -gui \
  -debug \
  -linedebug \
  +test_sequence=1 \
  +input_file=$WORK_DIR/digital/tb/adc_input.txt \
  $WORK_DIR/digital/rtl/downmixer/downmixer_recovery.v \
  $WORK_DIR/digital/rtl/mixer/mixer.v \
  $WORK_DIR/digital/tb/demod_test.sv \
  -f $WORK_DIR/digital/rtl/cic/cic.f \
  -f $WORK_DIR/digital/rtl/dds/dds_cordic.f \
  -f $WORK_DIR/digital/rtl/demod/demod.f
