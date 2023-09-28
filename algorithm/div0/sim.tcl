if ![file isdirectory ./work] { vlib ./work }


vmap work ./work

vlog divider_cell.v
vlog divider_main.v
vlog ../pipeline_data_delay.v
vlog divider.v
vlog test.sv  +libext+.v +libext+.sv

vsim work.test -L altera_mf_ver -voptargs=+acc
do wave.do
run -all
