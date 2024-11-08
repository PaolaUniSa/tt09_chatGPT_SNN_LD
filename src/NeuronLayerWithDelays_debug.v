module NeuronLayerWithDelays_debug #( //weight =2bits
    parameter N = 4                 // Number of neurons in the layer
)(
    input wire clk,                      // Clock signal
    input wire reset,                    // Asynchronous reset, active high
    input wire enable,                   // Enable input for the entire layer
    input wire delay_clk,                // Delay Clock signal
    input wire [8-1:0] input_spikes,     // M-bit input spikes
    input wire [N*8*2-1:0] weights,      // N * M Nbit weights
    input wire [5-1:0] threshold,          // Firing threshold (V_thresh)
    input wire [3-1:0] decay,              // Decay value
    input wire [5-1:0] refractory_period,  // Refractory period in number of clock cycles
    input wire [N*8*3-1:0] delay_values, // Flattened array of 3-bit delay values
    input wire [N*8-1:0] delays,         // Array of delay enables for each input
    output wire [N*5-1:0] membrane_potential_out, // add for debug
    output wire [N-1:0] output_spikes    // Output spike signals for each neuron 
);

    // Generate NeuronWithDelays instances for each neuron
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin: neuron_gen
            NeuronWithDelays_debug neuron_inst (
                .clk(clk),
                .reset(reset),
                .enable(enable),
                .delay_clk(delay_clk),
                .input_spikes(input_spikes),
                .weights(weights[i*8*2 +: 8*2]),
                .threshold(threshold),
                .decay(decay),
                .refractory_period(refractory_period),
                .delay_values(delay_values[i*8*3 +: 8*3]),
                .delays(delays[i*8 +: 8]),
                .membrane_potential_out(membrane_potential_out[i*5 +: 5]),
                .spike_out(output_spikes[i])
            );
        end
    endgenerate

endmodule
