OUTPUT = aes
name = ${OUTPUT}
SIM_VERSION:= v0.3
SIM_PATH:= ../../../../../../../prj/SIM${SIM_VERSION}
SIM_NAME:= ${name}
SEED=0
TC=${name}_case0



CMP_ARGE:= +acc 
CMP_ARGE+= +vpi 
CMP_ARGE+= -full64 
CMP_ARGE+= +v2k
CMP_ARGE+= -sverilog
CMP_ARGE+= -ntb_opts uvm-1.2  
CMP_ARGE+= +define+DEBUG  
CMP_ARGE+= -CFLAGS 
CMP_ARGE+= -DVCS 
CMP_ARGE+= -lca 
CMP_ARGE+= -kdb 
CMP_ARGE+= +lint=TFIPC-L 
CMP_ARGE+= -timescale=1ns/1ps 
CMP_ARGE+= -debug_acc+all 
CMP_ARGE+= -debug_region+cell+encrypt 
CMP_ARGE+= -LDFLAGS 
CMP_ARGE+= -rdynamic  
CMP_ARGE+= -P ${VERDI_HOME}/share/PLI/VCS/LINUX64/novas.tab ${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a  

SIM_ARGE:=  +vcs+lic+wait  
SIM_ARGE+=	+fsdb+all=on  
SIM_ARGE+=	+fsdbfile+hw.fsdb   
SIM_ARGE+=	-l sim.log

UVM_ARGE:=   +UVM_TESTNAME=${TC}
UVM_ARGE+=   +UVM_TIMEOUT="90000000ns, yes"
UVM_ARGE+=   +UVM_MAX_QUIT_COUNT=15,no
UVM_ARGE+=   +UVM_VERBOSITY=UVM_MEDIUM
UVM_ARGE+=   +ntb_random_seed=${SEED}





clean:
	rm -rf  ./verdiLog  ./dff ./csrc *.daidir *log *.vpd *.vdb simv* *.key *race.out* *.rc *.fsdb *.vpd *.log *.conf *.dat *.conf

comp: 
	-mkdir ./prj
	rm -rf ${SIM_PATH} && mkdir ${SIM_PATH}
	cd ${SIM_PATH} && vcs ${CMP_ARGE} -f ../../user/sim/Basic/Math/Advance/aes/filelist/filelist.f ../../user/sim/Basic/Math/Advance/aes/tb/aes_tb.sv
	
sim:
	cd ${SIM_PATH} && ./simv ${SIM_ARGE} ${UVM_ARGE}

all: comp sim