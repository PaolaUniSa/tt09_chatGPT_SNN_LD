read_sdc $::env(SCRIPTS_DIR)/base.sdc

create_clock -period 10000.000 -name serial_clock -waveform {0.000 5000.000} -add [get_ports {uio_in[3]}]
set_clock_transition 0.1500 [get_clocks {serial_clock}]
set_clock_uncertainty 0.2500 [get_clocks {serial_clock}]

create_generated_clock -name generated_clock -source [get_ports clk] -divide_by 2 -add -master_clock [get_clocks {clk}] [get_pins -of [get_nets \spiking_network_top_uut.clk_div_inst.clk_out]]

set_clock_groups -asynchronous -group [get_clocks {clk}] -group [get_clocks {serial_clock}] -group [get_clocks {generated_clock}]

set_input_delay -clock [get_clocks clk] -add_delay 4.000 [get_ports {ui_in[0]}]
set_input_delay -clock [get_clocks serial_clock] -add_delay 4.000 [get_ports {uio_in[0]}]
set_input_delay -clock [get_clocks serial_clock] -add_delay 4.000 [get_ports {uio_in[1]}]

set_output_delay 4.0000 -clock [get_clocks {clk}] -add_delay [get_ports {uo_out[0]}]
set_output_delay 4.0000 -clock [get_clocks {clk}] -add_delay [get_ports {uo_out[1]}]
set_output_delay 4.0000 -clock [get_clocks {clk}] -add_delay [get_ports {uo_out[2]}]
set_output_delay 4.0000 -clock [get_clocks {clk}] -add_delay [get_ports {uo_out[3]}]
set_output_delay 4.0000 -clock [get_clocks {clk}] -add_delay [get_ports {uo_out[4]}]
set_output_delay 4.0000 -clock [get_clocks {clk}] -add_delay [get_ports {uo_out[5]}]
set_output_delay 4.0000 -clock [get_clocks {clk}] -add_delay [get_ports {uo_out[6]}]
set_output_delay 4.0000 -clock [get_clocks {clk}] -add_delay [get_ports {uo_out[7]}]

set_output_delay -clock [get_clocks serial_clock] -add_delay 4.000 [get_ports {uio_out[6]}]
set_output_delay -clock [get_clocks serial_clock] -add_delay 4.000 [get_ports {uio_out[2]}]
set_output_delay -clock [get_clocks serial_clock] -add_delay 4.000 [get_ports {uio_out[7]}]
