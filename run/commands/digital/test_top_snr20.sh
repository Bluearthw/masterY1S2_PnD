# xrun \
#   -sv \
#   -gui \
#   -debug \
#   -linedebug \
#   +test_sequence=1 \
#   +input_file=$WORK_DIR/Matlab_Model/adc_input.txt \
#   +output_file=$WORK_DIR/Matlab_Model/out_char.txt \
#   $WORK_DIR/digital/tb/top_test.sv \
#   -f $WORK_DIR/digital/rtl/top/top.f
#xrun -sv -debug -linedebug +test_sequence=1 +input_file=/esat/studscratch/r0927191/gmsk-project/gmsk-arc/gmsk-group-3/Matlab_Model/adc_input.txt +/esat/studscratch/r0927191/gmsk-project/gmsk-arc/gmsk-group-3/digital/tb/top_test.sv -f /esat/studscratch/r0927191/gmsk-project/gmsk-arc/gmsk-group-3/digital/rtl/top/top.f -input restore.tcl
xrun -sv -debug -linedebug +test_sequence=1 +input_file=$WORK_DIR/Matlab_Model/adc_input_20db.txt +output_file=$WORK_DIR/digital/tb/out_char.txt $WORK_DIR/digital/tb/top_test.sv -f $WORK_DIR/digital/rtl/top/top.f -input /esat/studscratch/r0927191/gmsk-project/gmsk-arc/gmsk-group-3/run/restore.tcl
cd $WORK_DIR/digital/tb/
python3 check_message.py