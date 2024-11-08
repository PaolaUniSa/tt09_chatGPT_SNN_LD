module NeuronWithDelays_debug (
    input wire clk,                      // Clock signal
    input wire reset,                    // Asynchronous reset, active high
    input wire enable,                   // Enable input for the entire neuron
    input wire delay_clk,                // Delay Clock signal
    input wire [8-1:0] input_spikes,     // M-bit input spikes
    input wire [8*2-1:0] weights,        // M Nbit weights
    input wire [5-1:0] threshold,          // Firing threshold (V_thresh)
    input wire [3-1:0] decay,              // Decay value
    input wire [5-1:0] refractory_period,  // Refractory period in number of clock cycles
    input wire [8*3-1:0] delay_values,   // Flattened array of 3-bit delay values
    input wire [8-1:0] delays,           // Array of delay enables for each input
    output wire [5-1:0] membrane_potential_out, // add for debug
    output wire spike_out                // Output spike signal
);
    wire [8-1:0] delayed_spikes;     // Delayed input spikes

    // Generate neuron_delay instances for each input spike
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin: neuron_delay_gen
            neuron_delay neuron_delay_inst (
                .sys_clk(clk),
                .reset(reset),
                .enable(enable),
                .delay_clk(delay_clk), // Assuming delay clock is same as system clock
                .delay_value(delay_values[i*3 +: 3]),
                .delay(delays[i]),
                .din(input_spikes[i]),
                .dout(delayed_spikes[i])
            );
        end
    endgenerate

    // Instantiate the LIF_Neuron module
    LIF_Neuron_debug lif_neuron_inst (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .input_spikes(delayed_spikes),
        .weights(weights),
        .threshold(threshold),
        .decay(decay),
        .refractory_period(refractory_period),
        .membrane_potential_out(membrane_potential_out),
        .spike_out(spike_out)
    );

endmodule
