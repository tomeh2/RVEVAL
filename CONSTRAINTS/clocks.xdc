create_clock -period 5.000 [get_ports clk_in1_p]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1_p]] 0.050


set_property PHASESHIFT_MODE WAVEFORM [get_cells -hierarchical *adv*]
