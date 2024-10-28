module NeuronLayerWithDelays_debug #( //weight bit-length=2bits=(zero,sign) // membrane potential bit-length=6 bits
    parameter M = 2,                // Number of input spikes and weights
    parameter N = 4                 // Number of neurons in the layer
)(
    input wire clk,                      // Clock signal
    input wire reset,                    // Asynchronous reset, active high
    input wire enable,                   // Enable input for the entire layer
    input wire delay_clk,                // Delay Clock signal
    input wire [M-1:0] input_spikes,     // M-bit input spikes
    input wire [N*M*2-1:0] weights,      // N * M Nbit weights
    input wire [6-1:0] threshold,          // Firing threshold (V_thresh)
    input wire [6-1:0] decay,              // Decay value
    input wire [6-1:0] refractory_period,  // Refractory period in number of clock cycles
    input wire [N*M*3-1:0] delay_values, // Flattened array of 3-bit delay values
    input wire [N*M-1:0] delays,         // Array of delay enables for each input
    output wire [N*6-1:0] membrane_potential_out, // add for debug
    output wire [N-1:0] output_spikes    // Output spike signals for each neuron 
);

    // Generate NeuronWithDelays instances for each neuron
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin: neuron_gen
            NeuronWithDelays_debug #(
                .M(M)
            ) neuron_inst (
                .clk(clk),
                .reset(reset),
                .enable(enable),
                .delay_clk(delay_clk),
                .input_spikes(input_spikes),
                .weights(weights[i*M*2 +: M*2]),
                .threshold(threshold),
                .decay(decay),
                .refractory_period(refractory_period),
                .delay_values(delay_values[i*M*3 +: M*3]),
                .delays(delays[i*M +: M]),
                .membrane_potential_out(membrane_potential_out[i*6 +: 6]),
                .spike_out(output_spikes[i])
            );
        end
    endgenerate

endmodule
