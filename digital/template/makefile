# Makefile for CORDIC Simulation

# Variables
VERILOG_SOURCES = user/src/cordic_serial.v user/sim/tb_cordic_serial.v
SOURCE_DIR = user/src
SIMULATION_DIR = user/sim
OUTPUT_FILE = cordic_serial_tb
WAVEFORM_DIR = waveform
WAVEFORM_FILE = $(WAVEFORM_DIR)/cordic_serial_tb.vcd

#work in diff os
ifeq ($(OS),Windows_NT)
    MKDIR = if not exist $(WAVEFORM_DIR) mkdir $(WAVEFORM_DIR)
    RM = del /F /Q
    RMDIR = rmdir /S /Q
else
    MKDIR = mkdir -p $(WAVEFORM_DIR)
    RM = rm -f
    RMDIR = rm -rf
endif

# Targets
all: $(OUTPUT_FILE)

$(OUTPUT_FILE): $(VERILOG_SOURCES)
	iverilog -o $(OUTPUT_FILE) $(VERILOG_SOURCES)

run: $(OUTPUT_FILE)
	vvp $(OUTPUT_FILE)

wave: run
	@echo "Waveform generated: $(WAVEFORM_FILE)"

cordic:
	iverilog -o cordic_serial_tb.out $(SOURCE_DIR)\cordic_serial.v $(SIMULATION_DIR)\tb_cordic_serial.v
	vvp cordic_serial_tb.out    
	gtkwave $(WAVEFORM_DIR)\cordic_serial_tb.vcd            

clean:
	@echo "Cleaning up generated files..."
ifeq ($(OS),Windows_NT)
	-$(RM) *.out *.vvp *.log *.vcd 2>nul  
	-$(RM) waveform\*.*

else
	-$(RM) *.out *.vvp *.log *.vcd         
	-$(RM) -f waveform/*           
endif


.PHONY: all run wave clean
