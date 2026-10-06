vlog list.svh
vopt +acc +cover=fcbest top -o UNDERFLOW
vsim -coverage -assertdebug UNDERFLOW -l fifo.log
coverage save -onexit UNDERFLOW.ucdb

do wave.do

add wave /top/dut/u_fifo_checks/a_full
add wave /top/dut/u_fifo_checks/a_overflow
add wave /top/dut/u_fifo_checks/a_empty
add wave /top/dut/u_fifo_checks/a_underflow
add wave /top/dut/u_fifo_checks/wr_en_a
add wave /top/dut/u_fifo_checks/rd_en_a
add wave /top/dut/u_fifo_checks/wdata_a
add wave /top/dut/u_fifo_checks/rdata_a

run -all


# vlog list.svh
# vopt top +cover=fcbest -o UNDERFLOW 
# vsim -coverage -assertdebug -voptargs=+acc UNDERFLOW -l fifo.log
# coverage save -onexit UNDERFLOW.ucdb
# #add wave -position insertpoint sim:/top/*
# do wave.do
# run -all
# add wave /tb/dut/u_fifo_checks/a_full
# add wave /tb/dut/u_fifo_checks/a_overflow
# add wave /tb/dut/u_fifo_checks/a_empty
# add wave /tb/dut/u_fifo_checks/a_underflow


