module InputCurrentCalculator //M=8
(
    input wire [7:0] input_spikes,      // M-bit input spikes
    input wire [15:0] weights,          // M x 2-bit weights
    output wire [4:0] input_current     // 5-bit input current, M < 15 ensures no overflow/underflow
);

    // Array of weighted sums, using 3 bits initially since weights are 2 bits
    wire signed [4:0] weighted_sum [0:7]; 

    wire signed [4:0] partial_sum [0:8];    // Array to accumulate sums
    
    // Generate weighted sums based on input spikes and weights, with sign extension
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : weighted_sum_loop
            // Concatenate the most significant bit (sign bit) to create a 3-bit signed value
            assign weighted_sum[i] = input_spikes[i] ? $signed({{3{weights[i*2 + 1]}}, weights[i*2 +: 2]}) : $signed(3'd0);
        end
    endgenerate
    
    // Sum all weighted values combinationally
    assign partial_sum[0] = 5'd0; // Initialize the first partial sum to zero
    generate
        for (i = 0; i < 8; i = i + 1) begin : sum_loop
            assign partial_sum[i+1] = partial_sum[i] + weighted_sum[i];
        end
    endgenerate

    // The final output is the last element in the partial_sum array
    assign input_current = partial_sum[8];
    
endmodule


//module InputCurrentCalculator #(
//    parameter M = 4  // Number of input spikes and weights
//)(
//    input wire clk,                       // Clock signal
//    input wire reset,                     // Asynchronous reset, active high
//    input wire enable,                    // Enable input for calculation
//    input wire [M-1:0] input_spikes,      // M-bit input spikes
//    input wire [M*2-1:0] weights,         // M x 2bit-weights
//    output reg [5-1:0] input_current        // 5bit-input current  -- with M<15 there is no overflow-underflow
//);

//    integer i;
//    reg signed [5-1:0] current_sum;       // Accumulator for the weighted sum

//    always @(posedge clk or posedge reset) begin
//        if (reset) begin
//            input_current <= 5'd0;        // Reset input_current to zero
//        end else if (enable) begin
//            current_sum = 5'd0;           // Reset the accumulator at the beginning of each calculation

//            // Loop through each spike and add the corresponding weight if spike is 1
//            for (i = 0; i < M; i = i + 1) begin
//                if (input_spikes[i] == 1'b1) begin
//                    current_sum = current_sum + $signed(weights[i*2 +: 2]); // Add 2-bit weight corresponding to spike
//                end
//            end

//            input_current <= current_sum; // Update the output with the computed sum
//        end
//    end

//endmodule
