# VHDL files
VHDL_FILES = matrix_multiplier/matrix_multiplier.vhd \
			 matrix_multiplier/matrix_multiplier_testbench.vhd

# Testbench
TESTBENCH = matrix_multiplier_testbench

# GHDL configuration
GHDL_FLAGS = --std=93 
GHDL_CMD = /usr/local/bin/ghdl

WORKDIR = ./build

# Targets
all: run

# Analyze all VHDL files
analyze:
	@echo "Analyzing VHDL files..."
	@mkdir -p $(WORKDIR)
	@$(GHDL_CMD) -a $(GHDL_FLAGS) --workdir=$(WORKDIR) $(VHDL_FILES)

# Elaborate the testbench
elaborate: analyze
	@echo "Elaborating $(TESTBENCH)..."
	@cd $(WORKDIR) && $(GHDL_CMD) -e $(GHDL_FLAGS) $(TESTBENCH)

# Run the simulation
run: elaborate
	@echo "Running $(TESTBENCH)..."
	@cd $(WORKDIR) && $(GHDL_CMD) -r $(GHDL_FLAGS) $(TESTBENCH) --wave=$(TESTBENCH).ghw & \
	PID=$$!; trap "echo 'Stopping GHDL...'; kill $$PID" INT; wait $$PID

# Clean up generated files
clean:
	@echo "Cleaning up..."
	@rm -rf $(WORKDIR)
	@$(GHDL_CMD) --clean
	@$(GHDL_CMD) --remove
	@rm -f *.vcd

.PHONY: all analyze elaborate run clean
