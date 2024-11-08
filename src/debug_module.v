module debug_module(
    input wire clk,
    input wire rst,    // Active high reset
    input wire en,     // Enable signal
    input wire [7:0] debug_config_in,
    input wire [(8+8+2)*5-1:0] membrane_potentials, // Flattened array
    input wire [8-1:0] output_spikes_layer1,
    input wire [8-1:0] output_spikes_layer2,
    input wire [8-1:0] output_spikes_layer3,
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
            8'b00000000: debug_output =  {3'b000, membrane_potentials[5-1:0]};
            8'b00000001: debug_output =  {3'b000, membrane_potentials[2*5-1:5]};
            8'b00000010: debug_output = {3'b000, membrane_potentials[3*5-1:2*5]};
            8'b00000011: debug_output = {3'b000, membrane_potentials[4*5-1:3*5]};
            8'b00000100: debug_output = {3'b000, membrane_potentials[5*5-1:4*5]};
            8'b00000101: debug_output = {3'b000, membrane_potentials[6*5-1:5*5]};
            8'b00000110: debug_output = {3'b000, membrane_potentials[7*5-1:6*5]};
            8'b00000111: debug_output = {3'b000, membrane_potentials[8*5-1:7*5]};
            8'b00001000: debug_output = {3'b000, membrane_potentials[9*5-1:8*5]};
            8'b00001001: debug_output = {3'b000, membrane_potentials[10*5-1:9*5]};
            8'b00001010: debug_output = {3'b000, membrane_potentials[11*5-1:10*5]};
            8'b00001011: debug_output = {3'b000, membrane_potentials[12*5-1:11*5]};
            8'b00001100: debug_output = {3'b000, membrane_potentials[13*5-1:12*5]};
            8'b00001101: debug_output = {3'b000, membrane_potentials[14*5-1:13*5]};
            8'b00001110: debug_output = {3'b000, membrane_potentials[15*5-1:14*5]};
            8'b00001111: debug_output = {3'b000, membrane_potentials[16*5-1:15*5]};
            8'b00010000: debug_output = {3'b000, membrane_potentials[17*5-1:16*5]};
            8'b00010001: debug_output = {3'b000, membrane_potentials[18*5-1:17*5]};
            8'b00010010: debug_output = {3'b000, membrane_potentials[19*5-1:18*5]};
            8'b00010011: debug_output = {3'b000, membrane_potentials[20*5-1:19*5]};
            8'b00010100: debug_output = {3'b000, membrane_potentials[21*5-1:20*5]};
            8'b00010101: debug_output = {3'b000, membrane_potentials[22*5-1:21*5]};
            8'b00010110: debug_output = {3'b000, membrane_potentials[23*5-1:22*5]};
            8'b00010111: debug_output = {3'b000, membrane_potentials[24*5-1:23*5]};
            8'b00011110: debug_output = output_spikes_layer1;
            8'b00011111: debug_output = output_spikes_layer2;
            default: debug_output = output_spikes_layer3;
        endcase


endmodule

