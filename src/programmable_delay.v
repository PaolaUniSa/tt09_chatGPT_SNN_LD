module programmable_delay (
    input wire clk,        // Clock input
    input wire reset,      // Reset input
    input wire enable,
    input wire [2:0] delay, // 3-bit programmable delay input (0-7)
    input wire din,        // Data input
    output wire dout       // Data output
);

reg [7:0] shift_reg;       // 8-bit shift register to store the input values

always @(posedge clk or posedge reset) begin
    if (reset) begin
        shift_reg <= 8'b0; // Reset shift register
    end else begin
        if (enable) begin
            // Shift the register and store the new input
            shift_reg <= {shift_reg[6:0], din};
        end
    end
end

assign dout = shift_reg[delay]; // Output the delayed value

endmodule
