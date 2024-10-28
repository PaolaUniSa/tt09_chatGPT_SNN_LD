module spiking_network_top 
 (
    input wire system_clock, 
    input wire rst_n,
    input wire SCLK,
    input wire MOSI,
    input wire SS,
    input wire input_ready,
    output wire MISO,
    output wire [8-1:0] debug_output,//[7:0]
    output wire [8-1:0] output_spikes,
    output wire spi_instruction_done, //additional support signal at protocol level -- added 6Sep2024
    output wire data_valid_out //additional debug signal -- added 6Sep2024
);
    // Internal signals
    wire SNN_enable;
    wire clk_div_ready_reg_out;
    wire input_spike_ready_reg_out;
    wire debug_config_ready_reg_out;
    wire clk_div_ready_sync;
    wire input_spike_ready_sync;
    wire [8-1:0] input_spikes; 
    wire [6-1:0] decay;
    wire [6-1:0] refractory_period;
    wire [6-1:0] threshold;
    wire [7:0] div_value;
    wire [(8*8+8*8)*2-1:0] weights;
    wire [(8*8+8*8)*4-1:0] delays; // 832
    wire [7:0] debug_config_in;
    wire [(8+8)*6-1:0] membrane_potentials; 
    wire [8-1:0] output_spikes_layer1,output_spikes_layer2;
    wire delay_clk;
    wire input_ready_sync;
    wire [(5+32+64+1)*8-1:0] all_data_out; //66*8-1
    wire debug_config_ready_sync;
    wire sys_clk_reset_synchr, SPI_reset_synchr;
    wire sys_clk_reset, SPI_reset;
    // all_data_out Assignments
    // output wire [161*8-1:0] all_data_out
    // all_data_out:
    // input spikes      = 8 bits in the first byte-- addr: 0x00 
    // decay             = 5:0 bits in the 2Â° byte -- addr: 0x01
    // refractory_period = 5:0 bits in the 3Â° byte -- addr: 0x02
    // threshold         = 5:0 bits in the 4Â° byte -- addr: 0x03
    // div_value         = 5Â° byte  -- addr: 0x04
    // weights           = (8*8+8*2)*2 = 160 bits -> 20 bytes (from 6Â° to 25Â°)  -- addr: [0x07,0x3A] decimal:[5 - 24]
    // delays            = (8*8+8*2)*4= 320 bits (40 bytes) (from 26Â° to 65Â°) -- addr: [0x19,0x40] decimal:[25 - 64]
    // debug_config_in   = 8 bits in the 66 byte -- addr: 0x41 decimal:65
    
    // Instantiations
    
    // Instantiate the reset manager modules
    reset_manager u_SPI_reset (
        .clk(SCLK),
        .async_reset_n(rst_n),
        .sync_reset_n(SPI_reset_synchr)
    );
    
    reset_manager u_sys_clk_reset (
        .clk(system_clock),
        .async_reset_n(rst_n),
        .sync_reset_n(sys_clk_reset_synchr)
    );    
    
    assign SPI_reset= !SPI_reset_synchr;
    assign sys_clk_reset = !sys_clk_reset_synchr;
    
    
    spi_interface spi_inst (
        .SCLK(SCLK),
        .MOSI(MOSI),
        .SS(SS),
        .RESET(SPI_reset),
        .MISO(MISO),
        .clk_div_ready_reg_out(clk_div_ready_reg_out),
        .input_spike_ready_reg_out(input_spike_ready_reg_out),
        .debug_config_ready_reg_out(debug_config_ready_reg_out),
        .all_data_out(all_data_out),
        .spi_instruction_done(spi_instruction_done), //additional support signal at protocol level -- added 6Sep2024
        .data_valid_out(data_valid_out) //additional debug signal -- added 6Sep2024
    );

    clock_divider clk_div_inst (
        .clk(system_clock),
        .reset(sys_clk_reset),
        .enable(clk_div_ready_sync),
        .div_value(div_value),
        .clk_out(delay_clk)
    );

    debug_module debug_inst  (
        .clk(system_clock),
        .rst(sys_clk_reset),
        .en(debug_config_ready_sync),
        .debug_config_in(debug_config_in),
        .membrane_potentials(membrane_potentials),
        .output_spikes_layer1(output_spikes_layer1),
        .output_spikes_layer2(output_spikes_layer2),
        .debug_output(debug_output)
    );

    
    assign SNN_enable = input_spike_ready_sync & input_ready_sync;

    SNNwithDelays_top snn_inst (
        .clk(system_clock),
        .reset(sys_clk_reset),
        .enable(SNN_enable), //(input_spike_ready_sync),
        .delay_clk(delay_clk),
        .input_spikes(input_spikes),
        .weights(weights),
        .threshold(threshold),
        .decay(decay),
        .refractory_period(refractory_period),
        .delays(delays),
        .membrane_potential_out(membrane_potentials),
        .output_spikes_layer1(output_spikes_layer1),
        .output_spikes(output_spikes_layer2)
    );
    
    assign output_spikes = output_spikes_layer2;
    // Synchronizers
    synchronizer input_ready_sync_inst (
        .clk(system_clock),
        .reset(sys_clk_reset),
        .async_signal(input_ready),
        .sync_signal(input_ready_sync)
    );
    
    synchronizer clk_div_sync (
        .clk(system_clock),
        .reset(sys_clk_reset),
        .async_signal(clk_div_ready_reg_out),
        .sync_signal(clk_div_ready_sync)
    );

    synchronizer input_spike_sync (
        .clk(system_clock),
        .reset(sys_clk_reset),
        .async_signal(input_spike_ready_reg_out),
        .sync_signal(input_spike_ready_sync)
    );

    synchronizer debug_config_sync (
        .clk(system_clock),
        .reset(sys_clk_reset),
        .async_signal(debug_config_ready_reg_out),
        .sync_signal(debug_config_ready_sync)
    );

    // all_data_out Assignments
    // output wire [161*8-1:0] all_data_out
    // all_data_out:
    // input spikes      = 8 bits in the first byte-- addr: 0x00 
    // decay             = 5:0 bits in the 2° byte -- addr: 0x01
    // refractory_period = 5:0 bits in the 3° byte -- addr: 0x02
    // threshold         = 5:0 bits in the 4° byte -- addr: 0x03
    // div_value         = 5° byte  -- addr: 0x04
    // weights           = (8*8+8*2)*2 = 160 bits -> 20 bytes (from 6° to 25°)  -- addr: [0x07,0x3A] decimal:[5 - 24]
    // delays            = (8*8+8*2)*4= 320 bits (40 bytes) (from 26° to 65°) -- addr: [0x19,0x40] decimal:[25 - 64]
    // debug_config_in   = 8 bits in the 66 byte -- addr: 0x41 decimal:65
	assign input_spikes = all_data_out      [8-1 : 0];     // 8 bits in the first byte-- addr: 0x00
    assign decay = all_data_out             [2*8-1-2 : 1*8];   // 5:0 bits in the 2° byte -- addr: 0x01
    assign refractory_period = all_data_out [3*8-1-2 : 2*8];   // 5:0 bits in the 3° byte -- addr: 0x02
    assign threshold = all_data_out         [4*8-1-2 : 3*8];   // 5:0 bits in the 4° byte -- addr: 0x03
    assign div_value = all_data_out         [5*8-1:4*8];     // 5° byte  -- addr: 0x04
    assign weights = all_data_out           [(5+32)*8-1:5*8];    // (8*8+8*2)*2 = 160 bits -> 20 bytes (from 6° to 25°)  -- addr: [0x07,0x3A] decimal:[5 - 24]       
    assign delays = all_data_out            [(5+32+64)*8-1:(5+32)*8];  // (8*8+8*2)*4= 320 bits (40 bytes) (from 26° to 65°) -- addr: [0x19,0x40] decimal:[25 - 64]
    assign debug_config_in = all_data_out   [(5+32+64+1)*8-1:(5+32+64)*8]; // 8 bits in the 66 byte -- addr: 0x41 decimal:65

endmodule   
