# VHDL files
VHDL_FILES = apc/apc_package.vhd apc/apc.vhd apc/apc_testbench.vhd
			 

# Testbench
TESTBENCH = apc_testbench

# GHDL configuration
GHDL_FLAGS = --std=08
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
	@cd $(WORKDIR) && $(GHDL_CMD) -r $(GHDL_FLAGS) $(TESTBENCH) --vcd=$(TESTBENCH).vcd & \
	PID=$$!; trap "echo 'Stopping GHDL...'; kill $$PID" INT; wait $$PID
	# @cd $(WORKDIR) && $(GHDL_CMD) -r $(GHDL_FLAGS) $(TESTBENCH) & \

# Clean up generated files
clean:
	@echo "Cleaning up..."
	@rm -rf $(WORKDIR)
	@$(GHDL_CMD) --clean
	@$(GHDL_CMD) --remove
	@rm -f *.vcd

.PHONY: all analyze elaborate run clean
