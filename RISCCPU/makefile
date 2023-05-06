EXACUTE:run sim 
.PHONY:cov debug clean verdi 

OUTPUT = RISC
ALL_DEFING=+define+DUMP_VPD
CM = -cm line+cond+fsm+branch+tgl
CM_NAME = -cm_name ${OUTPUT}
CM_DIR = -cm_dir ./${OUTPUT}.vdb
NOVAS_HOME=/opt/Synopsys/Verdi2018/verdi/Verdi_O-2018.09-SP2

VPD_NAME=+vpdfile+${OUTPUT}.vpd

VCS = vcs -sverilog +v2k -timescale=1ns/1ns -full64                          \
	  -debug_all							\
	  -o ${OUTPUT}							\
	  -l compile.log						\
	  ${ALL_DEFING}                         \
	  ${VPD_NAME}                           \
	  ${CM}                                 \
	  ${CM_NAME}                            \
	  ${CM_DIR}                             \
	  -debug_pp                             \
	  -Mupdate                              \
	  -sverilog \
	  -v2005 \
	  -error=noMPD \
	  +error+100 \
	  +delay_mode_zero \
	  +notimingcheck \
	  +nospecify \
	  -kdb     \
	  -P ${NOVAS_HOME}/share/PLI/VCS/LINUX64/novas.tab \
	  	 ${NOVAS_HOME}/share/PLI/VCS/LINUX64/pli.a \


SIM = ./${OUTPUT} ${VPD_NAME} \
	  ${CM} \
	  ${CM_NAME} \
	  ${CM_DIR} \
	  -l ${OUTPUT}.log

run:
	@echo "run compile"
	${VCS} -f risc_test.f

sim:
	@echo "simulation"
	${SIM}
cov:
	dve -covdir *.vdb -full64 &
debug:
	dve -vpd ${OUTPUT}.vpd -full64 &
clean:
	rm -rf ./csrc *.daidir *.log simv* *.key *.vpd ./DVEfiles ${OUTPUT} *.vdb *.fsdb
verdi:
	verdi -ssf *.fsdb &
