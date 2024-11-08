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
