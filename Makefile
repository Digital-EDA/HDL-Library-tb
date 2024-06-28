XILINX_VERSION := 2018.3
XILINX_ENVPATH := /opt/xilinx/Vivado/${XILINX_VERSION}/settings64.sh

LIBRARY_PATH := /home/icer/.vscode-server/extensions/sterben.fpga-support-0.2.6/lib/com/Hardware/

ROOT_PATH:= /home/icer/Project/library
PRJ_PATH:= ${ROOT_PATH}/prj
USR_PATH:= ${ROOT_PATH}/user

# $(info $(test))
VERSION:=v0.3
SYN_SCRIPT:= ${USR_PATH}/script/synth.tcl
# 综合参数设置
SYN_PATH:= ${PRJ_PATH}/SYN${VERSION}
P&R_PATH:= ${PRJ_PATH}/P&R${VERSION}
SYN_ARGE:= -f ${SYN_SCRIPT}
SYN_ARGE+= -output_log_file synth.log

.PHONY: env
env :
	sudo podman attach ab57f231a84b

.PHONY: tolib
tolib :
	cd ${LIBRARY_PATH}

.PHONY: synth
synth :
	-mkdir ${PRJ_PATH}
	rm -rf command.log && rm -rf ${SYN_PATH} && mkdir ${SYN_PATH}
	cd ${SYN_PATH} && dc_shell ${SYN_ARGE}


LIB2DB_SCRIPT:= ${USR_PATH}/script/lib2db.tcl
.PHONY: lib2db
lib2db :
	lc_shell -f ${LIB2DB_SCRIPT}
	rm -rf ${ROOT_PATH}/lc_shell_command.log


P&R_SCRIPT:= ${USR_PATH}/script/p&r.tcl
P&R_ARGE:= -f ${P&R_SCRIPT}
P&R_ARGE+= -output_log_file p&r.log

.PHONY: p&r
p&r : 
	-mkdir ${P&R_PATH}
	rm -rf command.log && rm -rf ${P&R_PATH} && mkdir ${P&R_PATH}
	cd ${P&R_PATH} && icc_shell ${SYN_ARGE}

include sim.mk

.PHONY: clean
clean : 
	rm -rf ${PRJ_PATH}

