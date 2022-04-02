vmap -c
vlib work
vdel -lib work -all
vlib work
vlog -work work fifo_8_8/fifo_8_8.v
vlog -work work fifo_8_8_sa.v
vcom -work work tb_sclkfifo.vhd
vsim -L work -L pmi_work -L ovi_ecp5u  tb
view wave

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/u1/rst
add wave -noupdate /tb/u1/rd_clk
add wave -noupdate /tb/u1/rd_en
add wave -noupdate /tb/u1/wr_clk
add wave -noupdate /tb/u1/wr_en
add wave -noupdate -radix hexadecimal /tb/u1/din
add wave -noupdate /tb/u1/empty
add wave -noupdate /tb/u1/full
add wave -noupdate -radix hexadecimal /tb/u1/dout
add wave -noupdate /tb/u1/fifo_valid
add wave -noupdate /tb/u1/middle_valid
add wave -noupdate /tb/u1/dout_valid
add wave -noupdate -radix hexadecimal /tb/u1/middle_dout
add wave -noupdate -radix hexadecimal /tb/u1/fifo_dout
add wave -noupdate /tb/u1/fifo_empty
add wave -noupdate /tb/u1/fifo_rd_en
add wave -noupdate /tb/u1/will_update_middle
add wave -noupdate /tb/u1/will_update_dout
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {990000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 277
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
WaveRestoreZoom {0 ps} {1890 ns}

run 1800ns
