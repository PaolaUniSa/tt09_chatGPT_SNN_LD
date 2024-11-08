module LIF_Neuron_debug (
    input wire clk,                        // Clock signal
    input wire reset,                      // Asynchronous reset, active high
    input wire enable,                     // Enable input for the entire LIF neuron
    input wire [8-1:0] input_spikes,       // M-bit input spikes
    input wire [8*2-1:0] weights,          // M Nbit weights
    input wire [5-1:0] threshold,            // Firing threshold (V_thresh)
    input wire [3-1:0] decay,                // Decay value
    input wire [5-1:0] refractory_period,    // Refractory period in number of clock cycles
    output wire [5-1:0] membrane_potential_out, // add for debug
    output wire spike_out                  // Output spike signal
);
    wire [5-1:0] input_current;         // Nbit input current from InputCurrentCalculator

    // Instantiate the InputCurrentCalculator module
    InputCurrentCalculator input_current_calculator_inst (
        //.clk(clk),
        //.reset(reset),
        //.enable(enable),
        .input_spikes(input_spikes),
        .weights(weights),
        .input_current(input_current)
    );

    // Instantiate the LeakyIntegrateFireNeuron module
    LeakyIntegrateFireNeuron_debug lif_neuron_inst (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .input_current(input_current),
        .threshold(threshold),
        .decay(decay),
        .refractory_period(refractory_period),
        .membrane_potential_out(membrane_potential_out),
        .spike_out(spike_out)
    );

endmodule
