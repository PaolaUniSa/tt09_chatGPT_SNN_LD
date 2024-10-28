module InputCurrentCalculator #(
    parameter M = 4  // Number of input spikes and weights
)(
    input wire clk,                       // Clock signal
    input wire reset,                     // Asynchronous reset, active high
    input wire enable,                    // Enable input for calculation
    input wire [M-1:0] input_spikes,      // M-bit input spikes
    input wire [M*2-1:0] weights,         // M x 2bit-weights = M x (zero,sign)
    output reg [6-1:0] input_current        // 6bit-input current  -- with M<32 there is no overflow-underflow
);
    integer i;
    
    reg signed [6-1:0] current_sum;

    // Combinational logic for current sum
    always @(*) begin
        current_sum = 0;  // Initialize current sum to zero
        for (i = 0; i < M; i = i + 1) begin
            if ((input_spikes[i] & (~weights[2*i])) == 1'b1) begin
                if (weights[2*i+1] == 1'b1) begin
                    current_sum = current_sum - 1;
                end else begin
                    current_sum = current_sum + 1;
                end
            end
        end
    end

    // Register update for input_current
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            input_current <= 6'b0;
        end else if (enable) begin
            // Handle overflow
            if (current_sum > 31) begin
                input_current <= 6'b011111;  // Clamp to 31
            end else if (current_sum < -32) begin
                input_current <= 6'b100000;  // Clamp to -32
            end else begin
                input_current <= current_sum[6-1:0];
            end
        end
    end
endmodule
