# Include dgtop
-f $WORK_DIR/digital/rtl/dgtop.f

# Include testbench components
-f $WORK_DIR/chiptop/tb/components/anatop_driver/anatop_driver.f
-f $WORK_DIR/chiptop/tb/components/biasing/biasing.f
-f $WORK_DIR/chiptop/tb/components/clk_gen/clk_gen.f

# Include chiptop
$WORK_DIR/chiptop/rtl/chiptop.sv

# Include chiptop testbench
$WORK_DIR/chiptop/tb/chiptop_tb.sv
