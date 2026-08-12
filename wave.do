onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/wr_clk_i
add wave -noupdate /top/rd_clk_i
add wave -noupdate /top/rst_i
add wave -noupdate /top/pif/wr_en_i
add wave -noupdate /top/pif/rd_en_i
add wave -noupdate /top/pif/wdata_i
add wave -noupdate /top/pif/rdata_o
add wave -noupdate /top/pif/full_o
add wave -noupdate /top/pif/empty_o
add wave -noupdate /top/pif/overflow_o
add wave -noupdate /top/pif/underflow_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ns} {1 us}
