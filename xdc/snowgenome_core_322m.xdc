create_clock -name clk_322m -period 3.100 [get_ports clk_i]
set_clock_uncertainty 0.030 [get_clocks clk_322m]
