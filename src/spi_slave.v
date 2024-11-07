// SPI: MODE=0 MSB first
module spi_slave (
    input wire SCLK,  // SPI clock
    input wire MOSI,  // Master Out Slave In
    input wire SS,    // Slave Select (active low)
    input wire RESET, // Asynchronous reset (active high)
    output reg MISO,  // Master In Slave Out
    input wire [7:0] data_to_send,  // Data to be sent to master
    output reg [7:0] received_data, // Data received from master
    output reg data_valid  // Flag indicating received data is valid
);

    reg [2:0] bit_cnt;  // Bit counter
    reg [6:0] shift_reg;  // 7-bit Shift register for receiving data

    // Asynchronous reset and data receiving process
    always @(posedge SCLK or posedge RESET) begin
        if (RESET) begin
            // When RESET is high, reset all internal registers
            shift_reg <= 7'b0;
            received_data <= 8'b0;
            data_valid <= 1'b0;
        end else begin
            if (SS) begin
                // When SS is high (inactive), reset the shift register and data_valid
                shift_reg <= 7'b0;
                data_valid <= 1'b0;
            end else begin
                // Shift in data on the rising edge of SCLK
                if (bit_cnt < 3'b111) begin
                    shift_reg <= {shift_reg[5:0], MOSI};
                end
                if (bit_cnt == 3'b111) begin
                    // When 8 bits are received, store the data and raise data_valid
                    received_data <= {shift_reg, MOSI};
                    data_valid <= 1'b1;
                end else begin
                    data_valid <= 1'b0;
                end
            end
        end
    end

    // MISO control and bit counter process
    always @(negedge SCLK or posedge RESET) begin //always @(negedge SCLK or posedge RESET or posedge SS) begin modified 10Sep2024
        if (RESET) begin
            // When RESET is high, reset MISO and bit counter
            MISO <= 1'b0;
            bit_cnt <= 3'b000;
        end else if (SS) begin
            // When SS is high (inactive), assign MISO to data_to_send[0] and reset bit counter
            MISO <= data_to_send[0];
            bit_cnt <= 3'b000;
        end else begin
            // Shift out data on the falling edge of SCLK
            MISO <= data_to_send[7 - bit_cnt];
            bit_cnt <= bit_cnt + 1;
        end
    end

endmodule
