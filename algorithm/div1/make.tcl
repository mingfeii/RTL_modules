vlib work

vlog pipeline_division.sv
vlog pipeline_division_tb.sv

 
vsim pipeline_division_tb +acc
do wave.do
run -all
