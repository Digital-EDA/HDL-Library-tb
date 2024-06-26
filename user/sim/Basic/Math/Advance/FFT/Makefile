###################
# cocotb Variables
###################
# python test file name
MODULE = test_ifft
COCOTB_HDL_TIMEUNIT 	 = 1ns
COCOTB_HDL_TIMEPERCISION = 1ps

###################
# make scripts Variables
###################
SIM ?= vcs
TOPLEVEL		?= tb_top
TOPLEVEL_LANG   ?= verilog
# VERILOG_SOURCES ?= $(shell find ../../user/src/compare/ifft -name "*.v")
COMPILE_ARGS    += -LDFLAGS -Wl,--no-as-needed -f ../flist/wave.f -f ../flist/ref.f
SIM_ARGS		+=
EXTRA_ARGS		+=
PLUS_ARGS		+=

###################
# output path
###################
SIM_BUILD 		?= ../build/
COCOTB_RESULTS_FILE = $(SIM_BUILD)/results.xml

$(shell mkdir -p $(SIM_BUILD))
$(shell cp ../../user/src/compare/ifft/*.mem $(SIM_BUILD))

include $(shell cocotb-config --makefiles)/Makefile.sim
