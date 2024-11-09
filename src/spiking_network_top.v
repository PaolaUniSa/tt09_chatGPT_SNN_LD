module spiking_network_top 
 (
    input wire system_clock, 
    input wire rst_n, 
    input wire SCLK,
    input wire MOSI,
    input wire SS,
    input wire input_ready,
    input wire SNN_en,
    input wire [8-1:0] input_spikes,
    output wire MISO,
    output wire [8-1:0] debug_output,
    output wire output_ready,
    output wire spi_instruction_done
);
    // Internal signals
    wire SNN_enable;
    wire clk_div_ready_reg_out;
    wire debug_config_ready_reg_out;
    wire clk_div_ready_sync;
    wire [3-1:0] decay;
    wire [5-1:0] refractory_period;
    wire [5-1:0] threshold;
    wire [7:0] div_value;
    wire [(8*8+8*8+8*2)*2-1:0] weights;
    wire [(8*8+8*8+8*2)*4-1:0] delays;
    wire [7:0] debug_config_in;
    wire [(8+8+2)*5-1:0] membrane_potentials; 
    wire [8-1:0] output_spikes_layer1,output_spikes_layer2,output_spikes_layer3;
    wire delay_clk;
    wire input_ready_sync;
    wire [(4+36+72+1)*8-1:0] all_data_out;//4:decay,refract,thresh,div_val 36:weights(144 synapses) 72:delays 1:output_select
    wire debug_config_ready_sync;
    wire sys_clk_reset_synchr, SPI_reset_synchr;
    wire sys_clk_reset, SPI_reset;
    wire data_valid_out;
    wire output_data_ready;
    
    wire SNN_en_sync;
    reg  [8-1:0] input_spikes_reg_out;
    
    
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
        .output_spikes_layer3(output_spikes_layer3),
        .debug_output(debug_output)
    );
    
    assign SNN_enable =  SNN_en_sync;
    
    SNNwithDelays_top snn_inst (
        .clk(system_clock),
        .reset(sys_clk_reset),
        .enable(SNN_enable),
        .delay_clk(delay_clk),
        .input_spikes(input_spikes_reg_out),
        .weights(weights),
        .threshold(threshold),
        .decay(decay),
        .refractory_period(refractory_period),
        .delays(delays),
        .membrane_potential_out(membrane_potentials),
        .output_spikes_layer1(output_spikes_layer1),
        .output_spikes_layer2(output_spikes_layer2),
        .output_spikes(output_spikes_layer3),
        .output_data_ready(output_data_ready)
    );
    

    // input_spikes registers
    always @(posedge system_clock or posedge sys_clk_reset) begin
        if (sys_clk_reset) begin
            // Reset 
            input_spikes_reg_out <= 8'b00000000;
        end else begin
            if (input_ready_sync) begin
                input_spikes_reg_out <= input_spikes;
            end
        end
    end


    // Assegnazione del segnale di uscita output_ready
    assign output_ready = data_valid_out | output_data_ready;
    
    
    // Synchronizers
    synchronizer input_ready_sync_inst (
        .clk(system_clock),
        .reset(sys_clk_reset),
        .async_signal(input_ready),
        .sync_signal(input_ready_sync)
    );
    
    synchronizer snn_en_sync_inst (
        .clk(system_clock),
        .reset(sys_clk_reset),
        .async_signal(SNN_en),
        .sync_signal(SNN_en_sync)
    );
    
    synchronizer clk_div_sync (
        .clk(system_clock),
        .reset(sys_clk_reset),
        .async_signal(clk_div_ready_reg_out),
        .sync_signal(clk_div_ready_sync)
    );

    synchronizer debug_config_sync (
        .clk(system_clock),
        .reset(sys_clk_reset),
        .async_signal(debug_config_ready_reg_out),
        .sync_signal(debug_config_ready_sync)
    );

    // all_data_out Assignments
    // output wire [113*8-1:0] all_data_out
    // all_data_out:
    // decay             = 5:0 bits in the 2° byte -- addr: 0x00
    // refractory_period = 5:0 bits in the 3° byte -- addr: 0x01
    // threshold         = 5:0 bits in the 4° byte -- addr: 0x02
    // div_value         = 5° byte  -- addr: 0x03
    // weights           = (8*8+8*8+8*2)*2 = 288 bits -> 36 bytes (from 5° to 40°)  -- addr: [0x04,0x27] decimal:[4 - 39]
    // delays            = (8*8+8*8+8*2)*4= 576 bits (72 bytes) (from 41° to 112°) -- addr: [0x28,0x6F] decimal:[40 - 111]
    // debug_config_in   = 8 bits in the 113 byte -- addr: 0x70 decimal:112
    
	//assign input_spikes = all_data_out      [8-1 : 0]; deleted 5 November
    assign decay = all_data_out            [2*8-1-5 -1*8: 1*8-1*8];    
    assign refractory_period = all_data_out [3*8-1-3 -1*8: 2*8-1*8];
    assign threshold = all_data_out         [4*8-1-3 -1*8: 3*8-1*8];    
    assign div_value = all_data_out         [5*8-1-1*8:4*8-1*8];  
    assign weights = all_data_out           [(5+36)*8-1-1*8:5*8-1*8]; 
    assign delays = all_data_out            [(5+36+72)*8-1-1*8:(5+36)*8-1*8];
    assign debug_config_in = all_data_out   [(5+36+72+1)*8-1-1*8:(5+36+72)*8-1*8];

endmodule   
