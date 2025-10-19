# If we want to dump/save waveforms, we must probe our simulation using tcl commands.
# One way to do this is to provide a tcl-script to the "-input" option of xrun.
# Make sure simulation objects are given read-access through "-access +r" option of xrun.
# This example tracks/dumps all signals on all levels.
# (Be aware that this approach can slow down large industry-scale simulations greatly)
database -open waves -default
probe -create -shm -all -depth all
run
exit
