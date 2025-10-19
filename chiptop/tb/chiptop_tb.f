# Include dgtop
-f $WORK_DIR/digital/rtl/top/top.f

# Include testbench components
-f $WORK_DIR/chiptop/tb/components/mix/mix.f
-f $WORK_DIR/chiptop/tb/components/anatop_driver/anatop_driver.f
-f $WORK_DIR/chiptop/tb/components/biasing/biasing.f

# Include chiptop
$WORK_DIR/chiptop/rtl/chiptop.sv

# Include chiptop testbench
$WORK_DIR/chiptop/tb/chiptop_tb.sv
