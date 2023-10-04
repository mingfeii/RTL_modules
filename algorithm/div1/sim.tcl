if ![file isdirectory ./work] { vlib ./work }

vmap work ./work;

vlog pipeline_division.sv
vlog pipeline_data_delay.v
vlog division.sv
vlog tb.sv  +libext+.sv 

vsim work.tb  -voptargs=+acc
do wave.do
run -all
