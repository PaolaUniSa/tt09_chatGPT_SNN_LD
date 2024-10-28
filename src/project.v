/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_snn_with_delays_paolaunisa (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock 
    input  wire       rst_n     // reset_n - low to reset 
);

    wire reset = rst_n;
    wire SCLK;
    wire MOSI;
    wire CS;
    wire MISO;
    wire [7:0] debug_output;
    wire [8-1:0] output_spikes;
    wire input_ready; //additional input signal -- added 6Sep2024
    wire spi_instruction_done;  //additional support signal at protocol level -- added 6Sep2024
    wire data_valid_out; //additional debug signal -- added 6Sep2024
    
    
    spiking_network_top  spiking_network_top_uut (
        .system_clock(clk),
        .rst_n(reset),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .SS(CS),
        .input_ready(input_ready),
        .MISO(MISO),
        .debug_output(debug_output),
        .output_spikes(output_spikes),
        .data_valid_out(data_valid_out),
        .spi_instruction_done(spi_instruction_done)
    );
    
    // All output pins must be assigned. If not used, assign to 0.
    assign uo_out=debug_output;
    
    assign uio_oe = 8'b11110100; //8'b00110100;
    //input
    assign input_ready=ui_in[0];
    assign CS=uio_in[0];
    assign MOSI=uio_in[1];
    assign SCLK=uio_in[3];
    // List all unused inputs to prevent warnings
    wire _unused = &{ena, ui_in[7:1],uio_in[2],uio_in[7:4], 1'b0};
    
    //output
    assign uio_out[1:0]=2'b00;
    assign uio_out[2]=MISO;
    assign uio_out[3]=1'b0;
    assign uio_out[5:4]=output_spikes[1:0];
    assign uio_out[6]=data_valid_out;
    assign uio_out[7]=spi_instruction_done;
  
endmodule
