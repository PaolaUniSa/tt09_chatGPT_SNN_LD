module neuron_delay (
    input wire sys_clk,      // System clock
    input wire reset,        // Reset input
    input wire enable,
    input wire delay_clk,    // Delay module clock
    input wire [2:0] delay_value, // 3-bit programmable delay value
    input wire delay,        // 1-bit delay enable
    input wire din,          // Data input
    output wire dout         // Data output
);

wire delayed_dout;
wire sync_dout;

// Instantiate the programmable delay module
programmable_delay pd (
    .clk(delay_clk),
    .reset(reset),
    .enable(enable),
    .delay(delay_value),
    .din(din),
    .dout(delayed_dout)
);

// Synchronizer in the system clock domain
reg sync_reg1, sync_reg2;
always @(posedge sys_clk or posedge reset) begin
    if (reset) begin
        sync_reg1 <= 1'b0;
        sync_reg2 <= 1'b0;
    end else begin
        if (enable) begin
            sync_reg1 <= delayed_dout;
            sync_reg2 <= sync_reg1;
        end
    end
end
assign sync_dout = sync_reg2;

// Mux to select between din and the synchronized delayed output
assign dout = (delay == 1'b1) ? sync_dout: din;

endmodule
