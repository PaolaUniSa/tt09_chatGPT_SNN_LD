module synchronizer (
    input wire clk,
    input wire reset,
    input wire async_signal,
    output reg sync_signal
);
    reg sync_ff1;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sync_ff1 <= 1'b0;
            sync_signal <= 1'b0;
        end else begin
            sync_ff1 <= async_signal;
            sync_signal <= sync_ff1;
        end
    end
endmodule
