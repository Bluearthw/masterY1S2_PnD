# Main synthesis script
# For documentation, see:
#  - /users/micas/gmsk100/students/gmsk100-2025/EDA_docs/Genus_Command_Reference.pdf
#  - /users/micas/gmsk100/students/gmsk100-2025/EDA_docs/Genus_User_Guide.pdf

# 1) Create database with tsmc65 Front_End library
set_db library $env(PDK_DIR)/../Libs/tcbn65lpbwp7tbc_ccs.lib
set_db hdl_track_filename_row_col true
#set none to see every module
set_db auto_ungroup none

#set area to optimize area
#set_db auto_ungroup area

#advanced tryout
# set_db syn_opt_effort high
# set_db syn_global_effort high
# set_db design_power_effort high

# 2) Collect your design
# In this example we do this through a file-list file, another option is to specifiy a list of paths
 read_hdl -language sv -f $env(WORK_DIR)/digital/rtl/top/top.f
# Specify the top-level of your design (in this case "dgtop")(should be name of the .v or .sv file)
 elaborate top

######for gardner
# read_hdl -language sv -f $env(WORK_DIR)/digital/rtl/gardner/gardner.f
# elaborate bit_sync

# 3) Collect constraints
read_sdc $env(WORK_DIR)/scripts/synthesis/constraints.sdc

# 4) Run synthesis steps
syn_generic
syn_map
syn_opt

# 5) Generate reports
set OUTPUT_DIR ./synthesis
report_area -depth 3 > $OUTPUT_DIR/reports/report_area.rpt
report_timing -nworst 10 > $OUTPUT_DIR/reports/report_timing.rpt
report_power > $OUTPUT_DIR/reports/report_power.rpt

# 6) Write outputs
write_hdl > $OUTPUT_DIR/outputs/gmsk_netlist.v
write_sdc > $OUTPUT_DIR/outputs/gmsk_sdc.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > $OUTPUT_DIR/outputs/delay.sdf

#exit
