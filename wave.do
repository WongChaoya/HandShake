vlib work

vlog "../src/*v"
vlog "./*v"

vsim -voptargs=+acc work.HandShakeTb

view wave
view structure
view signals
radix unsigned

add wave -divider {HandShakeTb}
add wave HandShakeTb/*
add wave -divider {HandShakeTx}
add wave HandShakeTb/HandShakeTx_U0/*
add wave -divider {HandShakeRx}
add wave HandShakeTb/HandShakeRx_U0/*


.main clear
run 500ms
