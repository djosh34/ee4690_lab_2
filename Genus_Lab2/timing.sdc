set_time_unit -nanoseconds;

create_clock -name "clk" -add -period 10 [get_ports *CLK]

set_clock_latency 0.05 clk

set_input_delay -clock clk -max 0.1296 [all_inputs -no_clocks]
set_input_delay -clock clk -min 0.1296 [all_inputs -no_clocks]

set_input_transition 0.1 [all_inputs]

set_output_delay -clock clk -max 0.0528 [all_outputs]
set_output_delay -clock clk -min 0.0528 [all_outputs] 

set_load 5 [all_outputs]
