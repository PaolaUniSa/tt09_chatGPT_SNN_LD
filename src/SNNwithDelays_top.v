module SNNwithDelays_top //weight bit-length=2bits=(zero,sign) // membrane potential bit-length=6 bits // SNN:24|8|2
(
    input wire clk,                        // Clock signal
    input wire reset,                      // Asynchronous reset, active high
    input wire enable,                     // Enable input for the entire network
    input wire delay_clk,                  // Delay Clock signal
    input wire [8-1:0] input_spikes,        // M1-bit input spikes for the first layer
    input wire [(8*8+8*8+2*8)*2-1:0] weights,           // Combined weights for both layers (N1*M1*8 + N2*N1*8 bits)
    input wire [5-1:0] threshold,            // Firing threshold for both layers
    input wire [3-1:0] decay,                // Decay value for both layers
    input wire [5-1:0] refractory_period,    // Refractory period for both layers
    input wire [(8*8+8*8+2*8)*4-1:0] delays,     //320        // Combined delay values and delays for both layers (8*8*4 + 8*8*4 bits)
    output wire [(8+8+2)*5-1:0] membrane_potential_out, // (8+8)*6 bits
    output wire [7:0] output_spikes_layer1,    // Output spike signals for the first layer
    output wire [7:0] output_spikes_layer2,    // Output spike signals for the first layer
    output wire [8-1:0] output_spikes,           // Output spike signals for the second layer
    output wire output_data_ready
);

    // Split delays into delay_values1, delays1, delay_values2, and delays2
    wire [8*8*3-1:0] delay_values1; //8*8*3=192
    wire [8*8-1:0] delays1; //8*8=64
    wire [8*8*3-1:0] delay_values2;//8*2*3=48
    wire [8*8-1:0] delays2;//8*2
    wire [8*2*3-1:0] delay_values3;//8*2*3=48
    wire [8*2-1:0] delays3;//8*2
    //wire [1:0] output_spikes_layer3;
    
    genvar i;
    generate
        for (i = 0; i < 8*8; i = i + 1) begin : unpack_delays1  //160
            assign delay_values1[i*3 +: 3] = delays[i*4 +: 3];
            assign delays1[i] = delays[i*4 + 3];
        end
    endgenerate
    
    generate  
        for (i = 64; i < 8*8+8*8; i = i + 1) begin : unpack_delays2
            assign delay_values2[(i-64)*3 +: 3] = delays[i*4 +: 3];
            assign delays2[i-64] = delays[i*4 + 3];
        end
    endgenerate
    
    generate  
        for (i = 128; i < 144; i = i + 1) begin : unpack_delays3 //8*8+8*8 +8*4  
            assign delay_values3[(i-128)*3 +: 3] = delays[i*4 +: 3];
            assign delays3[i-128] = delays[i*4 + 3];
        end
    endgenerate
    

    ThreeLayerNetwork_debug three_layer_network_inst (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .delay_clk(delay_clk),
        .input_spikes(input_spikes),
        .weights1(weights[8*8*2-1:0]),         // weights1 part of the combined weights array
        .weights2(weights[8*8*2+8*8*2-1:8*8*2]),       // weights2 part of the combined weights array
        .weights3(weights[2*8*2+8*8*2+8*8*2-1:8*8*2+8*8*2]),
        .threshold1(threshold),
        .decay1(decay),
        .refractory_period1(refractory_period),
        .threshold2(threshold),
        .decay2(decay),
        .threshold3(threshold),
        .decay3(decay),
        .refractory_period2(refractory_period),
        .refractory_period3(refractory_period),
        .delay_values1(delay_values1),
        .delays1(delays1),
        .delay_values2(delay_values2),
        .delays2(delays2),
        .delay_values3(delay_values3),
        .delays3(delays3),
        .membrane_potential_out(membrane_potential_out),
        .output_spikes_layer1(output_spikes_layer1),
        .output_spikes_layer2(output_spikes_layer2),
        .output_spikes(output_spikes[1:0]),
        .output_data_ready(output_data_ready)
    );
    
    assign output_spikes[7:2]=6'b000000;

endmodule
