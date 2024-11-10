# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../src
PROJECT_SOURCES = project.v
PROJECT_SOURCES += spiking_network_top.v
PROJECT_SOURCES += clock_divider.v
PROJECT_SOURCES += debug_module.v
PROJECT_SOURCES += InputCurrentCalculator.v
PROJECT_SOURCES += LeakyIntegrateFireNeuron_debug.v
PROJECT_SOURCES += LIF_Neuron_debug.v
PROJECT_SOURCES += memory.v
PROJECT_SOURCES += neuron_delay.v
PROJECT_SOURCES += NeuronLayerWithDelays_debug.v
PROJECT_SOURCES += NeuronWithDelays_debug.v
PROJECT_SOURCES += programmable_delay.v
PROJECT_SOURCES += SNNwithDelays_top.v
PROJECT_SOURCES += spi_control_unit.v
PROJECT_SOURCES += spi_interface.v
PROJECT_SOURCES += spi_slave.v
PROJECT_SOURCES += synchronizer.v
PROJECT_SOURCES += ThreeLayerNetwork_debug.v
PROJECT_SOURCES += reset_manager.v

ifneq ($(GATES),yes)

# RTL simulation:
SIM_BUILD				= sim_build/rtl
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))
COMPILE_ARGS 		+= -I$(SRC_DIR)

else

# Gate level simulation:
SIM_BUILD				= sim_build/gl
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v

# this gets copied in by the GDS action workflow
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

endif

# Include the testbench sources:
VERILOG_SOURCES += $(PWD)/tb.v
TOPLEVEL = tb

# MODULE is the basename of the Python test file
MODULE = test

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
