# Constraint file
# Default time unit is nanoseconds

#-----------------------------
# Set design rules
#-----------------------------
set_max_transition 0.25 [current_design]
set_max_fanout 8 [current_design]

#-----------------------------
# Declare clocks
#-----------------------------
# Specify your "source" clock(s) (in this case portname "clk" in my top-level design)
create_clock -period 5 [get_ports clk]
# You can create "derived clocks" like this
# create_generated_clock -source clk -divide_by 4 -name clk2 [get_ports clk2]

#-----------------------------
# Setup and hold time uncertainties
#-----------------------------
set_clock_uncertainty 0.1 -setup [get_clocks clk]
set_clock_uncertainty 0.05 -hold [get_clocks clk]

#-----------------------------
# Clock transition
#-----------------------------
set_clock_transition -fall 0.1 [get_clocks clk]
set_clock_transition -rise 0.1 [get_clocks clk]

# #-----------------------------
# # IO constraints
# #-----------------------------
set_input_delay -max 0.05 -clock clk [all_inputs]
set_output_delay -max 0.05 -clock clk  [all_outputs]

#-----------------------------
# Path naming
#-----------------------------
group_path -name "reg2reg" -from [ all_registers -clock_pins ] -to [ all_registers -data_pins ] -weight 5.0
group_path -name "in2reg"  -from [all_inputs] -to [ all_registers -data_pins ] -weight 2.50
group_path -name "reg2out" -from [ all_registers -clock_pins ] -to [all_outputs]

#-----------------------------
# Reset false paths
#-----------------------------
set_false_path -from rst_n
