module InputCurrentCalculator //M=8
(
    input wire [7:0] input_spikes,      // M-bit input spikes
    input wire [15:0] weights,          // M x 2-bit weights
    output wire [4:0] input_current     // 5-bit input current, M < 15 ensures no overflow/underflow
);
    //use smaller bit-width adders for early stages and increase the bit-width gradually as we accumulate values
    // Array of weighted sums, using 3 bits initially since weights are 2 bits
    wire signed [2:0] weighted_sum [0:7]; 

    // Intermediate sums for the adder tree
    wire signed [2:0] level1_sum [0:3];  // 3-bit adders for first level
    wire signed [3:0] level2_sum [0:1];  // 4-bit adders for second level
    wire signed [4:0] final_sum;         // 5-bit adder for final sum

    // Generate weighted sums based on input spikes and weights, with sign extension
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : weighted_sum_loop
            // Concatenate the most significant bit (sign bit) to create a 3-bit signed value
            assign weighted_sum[i] = input_spikes[i] ? $signed({weights[i*2 + 1], weights[i*2 +: 2]}) : $signed(3'd0);
        end
    endgenerate

    // First level of the adder tree (3-bit adders), using generate for cleaner code
    generate
        for (i = 0; i < 4; i = i + 1) begin : level1_sum_loop
            assign level1_sum[i] = weighted_sum[2*i] + weighted_sum[2*i + 1];
        end
    endgenerate

    // Second level of the adder tree (4-bit adders) with sign extension
    assign level2_sum[0] = $signed({level1_sum[0][2], level1_sum[0]}) + $signed({level1_sum[1][2], level1_sum[1]});
    assign level2_sum[1] = $signed({level1_sum[2][2], level1_sum[2]}) + $signed({level1_sum[3][2], level1_sum[3]});

    // Final level of the adder tree (5-bit adder) with sign extension
    assign final_sum = $signed({level2_sum[0][3], level2_sum[0]}) + $signed({level2_sum[1][3], level2_sum[1]});

    // Assign final output
    assign input_current = final_sum;

endmodule



//module InputCurrentCalculator //M=8
//(
//    input wire [7:0] input_spikes,      // M-bit input spikes
//    input wire [15:0] weights,          // M x 2-bit weights
//    output wire [4:0] input_current     // 5-bit input current, M < 15 ensures no overflow/underflow
//);

//    // Array of weighted sums, using 3 bits initially since weights are 2 bits
//    wire signed [4:0] weighted_sum [0:7]; 

//    wire signed [4:0] partial_sum [0:8];    // Array to accumulate sums
    
//    // Generate weighted sums based on input spikes and weights, with sign extension
//    genvar i;
//    generate
//        for (i = 0; i < 8; i = i + 1) begin : weighted_sum_loop
//            // Concatenate the most significant bit (sign bit) to create a 3-bit signed value
//            assign weighted_sum[i] = input_spikes[i] ? $signed({{3{weights[i*2 + 1]}}, weights[i*2 +: 2]}) : $signed(3'd0);
//        end
//    endgenerate
    
//    // Sum all weighted values combinationally
//    assign partial_sum[0] = 5'd0; // Initialize the first partial sum to zero
//    generate
//        for (i = 0; i < 8; i = i + 1) begin : sum_loop
//            assign partial_sum[i+1] = partial_sum[i] + weighted_sum[i];
//        end
//    endgenerate

//    // The final output is the last element in the partial_sum array
//    assign input_current = partial_sum[8];
    
//endmodule




//module InputCurrentCalculator
//(
//    input wire [8-1:0] input_spikes,      // M-bit input spikes
//    input wire [8*2-1:0] weights,         // M x 2bit-weights
//    output wire [4:0] input_current       // 5-bit input current, M < 15 ensures no overflow/underflow
//);

//    wire signed [4:0] weighted_sum [0:8-1]; // Array of intermediate weighted sums
//    wire signed [4:0] partial_sum [0:8];    // Array to accumulate sums

//    // Initialize weighted sums based on input spikes and weights
//    genvar i;
//    generate
//        for (i = 0; i <8; i = i + 1) begin : weighted_sum_loop
//            assign weighted_sum[i] = input_spikes[i] ? $signed(weights[i*2 +: 2]) : 5'd0;
//        end
//    endgenerate

//    // Sum all weighted values combinationally
//    assign partial_sum[0] = 5'd0; // Initialize the first partial sum to zero
//    generate
//        for (i = 0; i < 8; i = i + 1) begin : sum_loop
//            assign partial_sum[i+1] = partial_sum[i] + weighted_sum[i];
//        end
//    endgenerate

//    // The final output is the last element in the partial_sum array
//    assign input_current = partial_sum[8];

//endmodule



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
