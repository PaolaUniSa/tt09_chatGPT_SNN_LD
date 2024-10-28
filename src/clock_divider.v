module clock_divider (
    input wire clk,               // Input clock
    input wire reset,             // Reset signal
    input wire enable,            // Enable signal
    input wire [7:0] div_value,   // 8-bit Divider value
    output reg clk_out            // Output clock=> f_out= f_in /2*(divider value+1) = [f_in ; f_in/512]
);

    reg [7:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            clk_out <= 0;
        end else if (enable) begin
            if (counter >= div_value) begin
                counter <= 0;
                clk_out <= ~clk_out;
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule
