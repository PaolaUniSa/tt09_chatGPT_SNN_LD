module reset_manager(
    input  wire clk,           // Clock input
    input  wire async_reset_n,  // Asynchronous reset input (active low)
    output wire sync_reset_n    // Synchronous reset output (active low)
);

    // Internal signals for the flip-flop outputs
    wire reset_ff1;
    wire reset_ff2;

    // Instantiate two flip-flops for synchronization
    dff_async_reset u_ff1 (
        .clk(clk),
        .async_reset_n(async_reset_n),
        .d(1'b1),              // Propagate '1' through the flip-flops
        .q(reset_ff1)
    );

    dff_async_reset u_ff2 (
        .clk(clk),
        .async_reset_n(async_reset_n),
        .d(reset_ff1),
        .q(reset_ff2)
    );

    // Output the synchronized reset signal (active low)
    assign sync_reset_n = reset_ff2;

endmodule


module dff_async_reset (
    input  wire clk,          // Clock input
    input  wire async_reset_n, // Asynchronous reset input (active low)
    input  wire d,            // Data input
    output reg  q             // Data output
);

    always @(posedge clk or negedge async_reset_n) begin
        if (!async_reset_n) begin
            q <= 1'b0;        // Asynchronous reset (active low)
        end else begin
            q <= d;           // Normal operation
        end
    end

endmodule