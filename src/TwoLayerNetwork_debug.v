module TwoLayerNetwork_debug #( //weight bit-length=2bits=(zero,sign) // membrane potential bit-length=6 bits
    parameter M1 = 8,                // Number of input spikes for the first layer
    parameter N1 = 8,                 // Number of neurons in the first layer
    parameter N2 = 8                 // Number of neurons in the second layer 
)(
    input wire clk,                        // Clock signal
    input wire reset,                      // Asynchronous reset, active high
    input wire enable,                     // Enable input for the entire network
    input wire delay_clk,                  // Delay Clock signal
    input wire [M1-1:0] input_spikes,      // M1-bit input spikes for the first layer
    input wire [N1*M1*2-1:0] weights1,     // N1 * M1 Nbit weights for the first layer
    input wire [N2*N1*2-1:0] weights2,     // N2 * N1 Nbit weights for the second layer
    input wire [6-1:0] threshold1,           // Firing threshold for the first layer
    input wire [6-1:0] decay1,               // Decay value for the first layer
    input wire [6-1:0] refractory_period1,   // Refractory period for the first layer
    input wire [6-1:0] threshold2,           // Firing threshold for the second layer
    input wire [6-1:0] decay2,               // Decay value for the second layer
    input wire [6-1:0] refractory_period2,   // Refractory period for the second layer
    input wire [N1*M1*3-1:0] delay_values1,// Delay values for the first layer
    input wire [N1*M1-1:0] delays1,        // Delays for the first layer
    input wire [N2*N1*3-1:0] delay_values2,// Delay values for the second layer
    input wire [N2*N1-1:0] delays2,        // Delays for the second layer
    output wire [(N1+N2)*6-1:0] membrane_potential_out, // add for debug
    output wire [N1-1:0] output_spikes_layer1,     // Output spike signals for the first layer
    output wire [N2-1:0] output_spikes     // Output spike signals for the second layer
);

    // Internal wires to connect the first and second layers
    wire [N1-1:0] layer1_output_spikes;

    // First layer
    NeuronLayerWithDelays_debug #(
        .M(M1),
        .N(N1)
    ) layer1 (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .delay_clk(delay_clk),
        .input_spikes(input_spikes),
        .weights(weights1),
        .threshold(threshold1),
        .decay(decay1),
        .refractory_period(refractory_period1),
        .delay_values(delay_values1),
        .delays(delays1),
        .membrane_potential_out(membrane_potential_out[N1*6-1:0]),
        .output_spikes(layer1_output_spikes)
    );
    
    assign output_spikes_layer1=layer1_output_spikes;
    
    
    // Second layer
    NeuronLayerWithDelays_debug #(
        .M(N1),
        .N(N2)
    ) layer2 (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .delay_clk(delay_clk),
        .input_spikes(layer1_output_spikes),
        .weights(weights2),
        .threshold(threshold2),
        .decay(decay2),
        .refractory_period(refractory_period2),
        .delay_values(delay_values2),
        .delays(delays2),
        .membrane_potential_out(membrane_potential_out[(N1+N2)*6-1:N1*6]),
        .output_spikes(output_spikes)
    );
    
    endmodule
