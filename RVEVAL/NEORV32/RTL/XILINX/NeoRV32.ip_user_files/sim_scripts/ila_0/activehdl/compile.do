vlib work
vlib activehdl

vlib activehdl/xpm
vlib activehdl/xil_defaultlib

vmap xpm activehdl/xpm
vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xpm  -sv2k12 "+incdir+../../../../../../../../NEORV32/RTL/XILINX/NeoRV32.gen/sources_1/ip/ila_0/hdl/verilog" \
"F:/Vivado/Vivado/2022.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"F:/Vivado/Vivado/2022.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"F:/Vivado/Vivado/2022.1/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xil_defaultlib -93 \
"../../../../../../../../NEORV32/RTL/XILINX/NeoRV32.gen/sources_1/ip/ila_0/sim/ila_0.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

