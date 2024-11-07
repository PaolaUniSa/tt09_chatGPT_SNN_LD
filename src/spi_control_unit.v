module spi_control_unit (
    input wire clk,
    input wire reset,
    input wire cs,                       // Chip Select signal
    input wire data_valid,               // Data valid signal
    input wire [7:0] SPI_instruction_reg_in,   // Instruction register input
    input wire [7:0] SPI_instruction_reg_out,  // Instruction register output
    output reg SPI_address_MSB_reg_en,   // Enable signal for Address MSB register
    output reg SPI_address_LSB_reg_en,   // Enable signal for Address LSB register
    output reg SPI_instruction_reg_en,   // Enable signal for Instruction register
    output reg clk_div_ready,
    output reg clk_div_ready_en,
    output reg debug_config_ready,
    output reg debug_config_ready_en,
    output reg write_memory_enable,
    output reg spi_instruction_done//additional support signal at protocol level --added 6Sep2024
);

    // State encoding
    parameter IDLE = 3'b000,
              WAIT_DATA_VALID_MSB = 3'b001,
              WAIT_DATA_VALID_LSB = 3'b010,
              WAIT_DATA_VALID_INSTR = 3'b011,
              WAIT_DATA_VALID_FINAL = 3'b100,
              SYSCLK_DOMAIN_EN = 3'b101;

    reg [2:0] current_state, next_state;

    // State transition on clock edge
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next state logic
    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (!cs)
                    next_state = WAIT_DATA_VALID_MSB;
            end
            WAIT_DATA_VALID_MSB: begin
                if (data_valid)
                    next_state = WAIT_DATA_VALID_LSB;
            end
            WAIT_DATA_VALID_LSB: begin
                if (data_valid)
                    next_state = WAIT_DATA_VALID_INSTR;
            end
            WAIT_DATA_VALID_INSTR: begin
                if (data_valid) begin
                    next_state = WAIT_DATA_VALID_FINAL;
                end
            end
            WAIT_DATA_VALID_FINAL: begin
                if (data_valid) begin
                    case (SPI_instruction_reg_out)
                        8'h05, 8'h09: next_state = SYSCLK_DOMAIN_EN;
                        default: next_state = IDLE;
                    endcase
                end
            end
            SYSCLK_DOMAIN_EN: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Output logic on clock edge
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            SPI_address_MSB_reg_en <= 0;
            SPI_address_LSB_reg_en <= 0;
            SPI_instruction_reg_en <= 0;
            clk_div_ready <= 0;
            clk_div_ready_en <= 0;
            debug_config_ready <= 0;
            debug_config_ready_en <= 0;
            write_memory_enable <= 0;
            spi_instruction_done <= 0;
        end else begin
            SPI_address_MSB_reg_en <= 0;
            SPI_address_LSB_reg_en <= 0;
            SPI_instruction_reg_en <= 0;
            clk_div_ready <= 0;
            clk_div_ready_en <= 0;
            debug_config_ready <= 0;
            debug_config_ready_en <= 0;
            write_memory_enable <= 0;
            
            case (current_state)
                WAIT_DATA_VALID_MSB: begin
                    spi_instruction_done <= 0;
                    if (data_valid)
                        SPI_address_MSB_reg_en <= 1;
                end
                WAIT_DATA_VALID_LSB: begin
                    spi_instruction_done <= 0;
                    if (data_valid)
                        SPI_address_LSB_reg_en <= 1;
                end
                WAIT_DATA_VALID_INSTR: begin
                    spi_instruction_done <= 0;
                    if (data_valid) begin
                        SPI_instruction_reg_en <= 1;
                        case (SPI_instruction_reg_in)
                            8'h05: clk_div_ready_en <= 1;
                            8'h09: debug_config_ready_en <= 1;
                        default: ;
                        endcase
                    end
                end
                WAIT_DATA_VALID_FINAL: begin
                    spi_instruction_done <= 0;
                    if (data_valid) begin
                        case (SPI_instruction_reg_out)
                            8'h01: begin
                                write_memory_enable <= 1;
                                spi_instruction_done <= 1;
                            end
                            8'h05, 8'h09:  write_memory_enable <= 1;
                        default:
                            spi_instruction_done <= 1; // Indicate completion before returning to idle - Assert when instruction cycle completes;
                        endcase
                    end
                end
                SYSCLK_DOMAIN_EN: begin
                    spi_instruction_done <= 1; // Indicate completion before returning to idle - Assert when instruction cycle completes
                    case (SPI_instruction_reg_out)
                        8'h05: begin
                            clk_div_ready <= 1;
                            clk_div_ready_en <= 1;
                        end
                        8'h09: begin
                            debug_config_ready <= 1;
                            debug_config_ready_en <= 1;
                        end
                        default: ;
                    endcase
                end
                default: ;
            endcase
        end
    end
endmodule

//    Documentation:
//    The spi_control_unit is a Verilog module that manages the control signals required for SPI (Serial Peripheral Interface) communication. The module operates based on various states, transitioning through these states depending on input signals such as clk, reset, cs (Chip Select), and data_valid. It controls the enabling of registers and the readiness signals for different parts of the SPI system.
    
//    Inputs and Outputs
//    Inputs:
    
//    clk: Clock signal.
//    reset: Reset signal, active high. Resets the state machine to its initial state.
//    cs: Chip Select signal. When inactive (cs = 0), the state machine begins its operation.
//    data_valid: Indicates that the incoming data is valid and should be processed.
//    SPI_instruction_reg_in: 8-bit instruction register input used for configuring control signals during the WAIT_DATA_VALID_INSTR state.
//    SPI_instruction_reg_out: 8-bit instruction register output used for determining actions in the WAIT_DATA_VALID_FINAL and SYSCLK_DOMAIN_EN states.
//    Outputs:
    
//    SPI_address_MSB_reg_en: Enables the most significant byte of the SPI address register.
//    SPI_address_LSB_reg_en: Enables the least significant byte of the SPI address register.
//    SPI_instruction_reg_en: Enables the SPI instruction register.
//    clk_div_ready: Indicates that the clock divider is ready.
//    clk_div_ready_en: Enable signal for clk_div_ready.
//    input_spike_ready: Indicates that the input spike system is ready.
//    input_spike_ready_en: Enable signal for input_spike_ready.
//    debug_config_ready: Indicates that the debug configuration is ready.
//    debug_config_ready_en: Enable signal for debug_config_ready.
//    write_memory_enable: Enables write access to memory.
//    State Machine
//    The module operates as a finite state machine with six states:
    
//    IDLE (3'b000):
    
//    Default state after reset.
//    Transitions to WAIT_DATA_VALID_MSB when cs is inactive (cs = 0).
//    WAIT_DATA_VALID_MSB (3'b001):
    
//    Waits for data_valid signal.
//    On data_valid, enables the MSB address register (SPI_address_MSB_reg_en = 1) and transitions to WAIT_DATA_VALID_LSB.
//    WAIT_DATA_VALID_LSB (3'b010):
    
//    Waits for data_valid signal.
//    On data_valid, enables the LSB address register (SPI_address_LSB_reg_en = 1) and transitions to WAIT_DATA_VALID_INSTR.
//    WAIT_DATA_VALID_INSTR (3'b011):
    
//    Waits for data_valid signal.
//    On data_valid, enables the instruction register (SPI_instruction_reg_en = 1).
//    Checks the SPI_instruction_reg_in value to set specific readiness enable signals:
//    8'h05 sets clk_div_ready_en = 1.
//    8'h07 sets input_spike_ready_en = 1.
//    8'h09 sets debug_config_ready_en = 1.
//    Transitions to WAIT_DATA_VALID_FINAL.
//    WAIT_DATA_VALID_FINAL (3'b100):
    
//    Waits for data_valid signal.
//    On data_valid, checks SPI_instruction_reg_out value:
//    If it matches 8'h01, 8'h05, 8'h07, or 8'h09, sets write_memory_enable = 1.
//    Transitions to SYSCLK_DOMAIN_EN for certain instruction values (8'h05, 8'h07, 8'h09), otherwise returns to IDLE.
//    SYSCLK_DOMAIN_EN (3'b101):
    
//    Executes additional actions based on SPI_instruction_reg_out value:
//    8'h05 sets clk_div_ready and clk_div_ready_en.
//    8'h07 sets input_spike_ready and input_spike_ready_en.
//    8'h09 sets debug_config_ready and debug_config_ready_en.
//    Transitions back to IDLE.
//    Reset Behavior
//    On reset (reset = 1), the module returns to the IDLE state, and all output signals are set to 0.

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
   
//    SPI Control Unit Operation
//    The SPI control unit functions as a state machine that manages the transitions and control signals for SPI communication. Its operation can be summarized as follows:
    
//    IDLE State:
    
//    The unit begins in the IDLE state and waits for the Chip Select (cs) signal to become active low (cs = 0).
//    When cs is low, the state machine transitions to the WAIT_DATA_VALID_MSB state, where it waits for the data_valid signal to become high.
//    WAIT_DATA_VALID_MSB State:
    
//    In the WAIT_DATA_VALID_MSB state, the unit waits for the data_valid signal to assert (go high).
//    When data_valid is high, the control unit asserts the SPI_address_MSB_reg_en signal to enable the most significant byte of the address register.
//    It then transitions to the WAIT_DATA_VALID_LSB state, waiting again for the data_valid signal to go high.
//    WAIT_DATA_VALID_LSB State:
    
//    In the WAIT_DATA_VALID_LSB state, the unit waits for the data_valid signal to assert.
//    When data_valid is high, the control unit asserts the SPI_address_LSB_reg_en signal to enable the least significant byte of the address register.
//    It then transitions to the WAIT_DATA_VALID_INSTR state, where it continues to wait for the data_valid signal.
//    WAIT_DATA_VALID_INSTR State:
    
//    In the WAIT_DATA_VALID_INSTR state, the unit waits for the data_valid signal to assert.
//    When data_valid is high, the control unit asserts the SPI_instruction_reg_en signal to enable the instruction register.
//    Based on the value of SPI_instruction_reg_in, it performs the following actions:
//    If SPI_instruction_reg_in is 8'h05, it deasserts clk_div_ready and asserts clk_div_ready_en.
//    If SPI_instruction_reg_in is 8'h07, it deasserts input_spike_ready and asserts input_spike_ready_en.
//    If SPI_instruction_reg_in is 8'h09, it deasserts debug_config_ready and asserts debug_config_ready_en.
//    The state machine then transitions to the WAIT_DATA_VALID_FINAL state, continuing to wait for the data_valid signal.
//    WAIT_DATA_VALID_FINAL State:
    
//    In the WAIT_DATA_VALID_FINAL state, the unit waits for the data_valid signal to assert.
//    When data_valid is high, the control unit checks the value of SPI_instruction_reg_out:
//    If SPI_instruction_reg_out is 8'h01, it asserts write_memory_enable and transitions back to the IDLE state.
//    If SPI_instruction_reg_out is 8'h05, 8'h07, or 8'h09, it asserts write_memory_enable and transitions to the SYSCLK_DOMAIN_EN state.
//    For any other value, it transitions back to the IDLE state.
//    SYSCLK_DOMAIN_EN State:
    
//    In the SYSCLK_DOMAIN_EN state, the unit performs actions based on the value of SPI_instruction_reg_out:
//    If SPI_instruction_reg_out is 8'h05, it asserts both clk_div_ready and clk_div_ready_en.
//    If SPI_instruction_reg_out is 8'h07, it asserts both input_spike_ready and input_spike_ready_en.
//    If SPI_instruction_reg_out is 8'h09, it asserts both debug_config_ready and debug_config_ready_en.
//    After performing the corresponding actions, the state machine transitions back to the IDLE state.

