vlog list.svh
vopt top +cover=fcbest -o UNDERFLOW 
vsim -coverage UNDERFLOW -l fifo.log
coverage save -onexit UNDERFLOW.ucdb
#add wave -position insertpoint sim:/top/*
do wave.do
run -all
