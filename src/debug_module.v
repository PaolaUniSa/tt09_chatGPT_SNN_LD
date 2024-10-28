module debug_module(
    input wire clk,
    input wire rst,    // Active high reset
    input wire en,     // Enable signal
    input wire [7:0] debug_config_in,
    input wire [(8+8)*6-1:0] membrane_potentials, // Flattened array
    input wire [8-1:0] output_spikes_layer1,
    input wire [8-1:0] output_spikes_layer2,
    output reg [8-1:0] debug_output
);

    reg [7:0] debug_config;
    
    // 8-bit register with enable and active high reset
    always @(posedge clk or posedge rst) begin
        if (rst)
            debug_config <= 8'b0;
        else if (en)
            debug_config <= debug_config_in;
    end
    
    
    
    // Multiplexer to select the Nbits signal based on debug_config
    always @*
    case (debug_config)
        8'b00000000: debug_output =  {2'b00,membrane_potentials[6-1:0]};
        8'b00000001: debug_output =  {2'b00,membrane_potentials[2*6-1:6]};
        8'b00000010: debug_output = {2'b00,membrane_potentials[3*6-1:2*6]};
        8'b00000011: debug_output = {2'b00,membrane_potentials[4*6-1:3*6]};
        8'b00000100: debug_output = {2'b00,membrane_potentials[5*6-1:4*6]};
        8'b00000101: debug_output = {2'b00,membrane_potentials[6*6-1:5*6]};
        8'b00000110: debug_output = {2'b00, membrane_potentials[7*6-1:6*6]};
        8'b00000111: debug_output =  {2'b00,membrane_potentials[8*6-1:7*6]};
        8'b00001000: debug_output =  {2'b00,membrane_potentials[9*6-1:8*6]};
        8'b00001001: debug_output =  {2'b00,membrane_potentials[10*6-1:9*6]};
        8'b00001010: debug_output = {2'b00, membrane_potentials[11*6-1:10*6]};
        8'b00001011: debug_output = {2'b00, membrane_potentials[12*6-1:11*6]};
        8'b00001100: debug_output = {2'b00, membrane_potentials[13*6-1:12*6]};
        8'b00001101: debug_output = {2'b00, membrane_potentials[14*6-1:13*6]};
        8'b00001110: debug_output = {2'b00, membrane_potentials[15*6-1:14*6]};
        8'b00001111: debug_output = {2'b00, membrane_potentials[16*6-1:15*6]};
        8'b00011111: debug_output = output_spikes_layer1;
        default: debug_output = output_spikes_layer2;
    endcase

endmodule

