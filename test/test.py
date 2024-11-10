# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0
import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

async def apply_reset(dut, num_cycles=2):
    """Applies reset for a specified number of clock cycles."""
    dut._log.info("Applying reset")
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, num_cycles)
    dut.rst_n.value = 1
    dut._log.info("Reset released")

async def send_byte(dut, byte):
    """Sends a byte over MOSI, simulating the SPI behavior."""
    #dut._log.info(f"Sending byte: {byte:02X}")
    await ClockCycles(dut.clk, 40)
    await ClockCycles(dut.clk, 10) #1/4 serial_clk_period
    dut.uio_in[0].value = 0  # SS = 0, activate
    for i in range(8):
        dut.uio_in[1].value = (byte >> (7 - i)) & 1  # Set MOSI bit
        await ClockCycles(dut.clk, 40)
    dut.uio_in[0].value = 1  # SS = 1, deactivate
    await ClockCycles(dut.clk, 10)#1/4 serial_clk_period
    await ClockCycles(dut.clk, 20)#1/2 serial_clk_period

async def wait_serial_clock_cycles(dut, num_cycles):
    """Waits for a specified number of serial clock cycles."""
    #dut._log.info(f"Waiting for {num_cycles} serial clock cycles")
    await ClockCycles(dut.clk, num_cycles*40)

async def wait_system_clock_cycles(dut, num_cycles):
    """Waits for a specified number of system clock cycles."""
    #dut._log.info(f"Waiting for {num_cycles} system clock cycles")
    await ClockCycles(dut.clk, num_cycles)   

async def execute_instr(dut, address_msb, address_lsb, instruction, data_byte):
    """Executes an instruction by sending a sequence of bytes."""
    await send_byte(dut, address_msb)
    await wait_serial_clock_cycles(dut, 2)
    await send_byte(dut, address_lsb)
    await wait_serial_clock_cycles(dut, 2)
    await send_byte(dut, instruction)
    await wait_serial_clock_cycles(dut, 2)
    await send_byte(dut, data_byte)
    await wait_serial_clock_cycles(dut, 2)

async def write_input_spikes(dut, input_spikes):
    """Writes a 8-bit input spike data to the memory."""
    byte = input_spikes
    dut.ui_in.value = input_spikes
    await wait_system_clock_cycles(dut, 1)
    dut.uio_in[4].value = 1 #input_ready=1
    await wait_system_clock_cycles(dut, 1)
    dut.uio_in[4].value = 0 #input_ready=0
    await wait_system_clock_cycles(dut, 1)

async def write_parameters(dut, decay, refractory_period, threshold, div_value, delays, debug_config_in):
    """Writes network parameters to the memory."""
    await execute_instr(dut, 0x00, 0x00, 0x01, decay)
    await wait_serial_clock_cycles(dut, 1)
    await execute_instr(dut, 0x00, 0x01, 0x01, refractory_period)
    await wait_serial_clock_cycles(dut, 1)
    await execute_instr(dut, 0x00, 0x02, 0x01, threshold)
    await wait_serial_clock_cycles(dut, 1)
    await execute_instr(dut, 0x00, 0x03, 0x05, div_value)
    await wait_serial_clock_cycles(dut, 1)

    # for i in range(40, 112): 
        # await execute_instr(dut, 0x00, i, 0x01, delays)
        # await wait_serial_clock_cycles(dut, 1)
    """Writes random delays values (4 bits each) to memory addresses from (decimal)[40 - 112]"""
    for i in range(40, 112):
        # Generate 2 random 4-bit weights and concatenate them into an 8-bit weight byte
        weight_byte = ((random.randint(0, 3) << 4) | random.randint(0, 3))
        await execute_instr(dut, 0x00, i, 0x01, weight_byte)
        await wait_serial_clock_cycles(dut, 1)   
        

    await execute_instr(dut, 0x00, 0x70, 0x09, debug_config_in)
    await wait_serial_clock_cycles(dut, 1)

async def write_weights(dut, weight):
    """Writes weight values to memory addresses from 0x04 to 0x27 (decimal:[4 - 39])"""
    weight_byte = (weight << 6) | (weight << 4) | (weight << 2) | weight
    for i in range(4, 39):
        await execute_instr(dut, 0x00, i, 0x01, weight_byte)
        await wait_serial_clock_cycles(dut, 1)


async def write_random_weights(dut):
    """Writes random weight values (2 bits each) to memory addresses from 0x04 to 0x27 (decimal: [4 - 39])"""
    for i in range(4, 40):
        # Generate four random 2-bit weights and concatenate them into an 8-bit weight byte
        weight_byte = (
            (random.randint(0, 3) << 6) |
            (random.randint(0, 3) << 4) |
            (random.randint(0, 3) << 2) |
            random.randint(0, 3)
        )
        await execute_instr(dut, 0x00, i, 0x01, weight_byte)
        await wait_serial_clock_cycles(dut, 1)



@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")
    
    #Inizialization
    dut._log.info("Initialization...")
    dut.ena.value = 1
    dut.ui_in.value = 0 # input_ready=ui_in[0] 
    dut.uio_in.value = 0 #MOSI= uio_in[1]
    dut.uio_in[0].value = 1 #SS
    
    # Set the clock periods for system and SPI clocks
    dut._log.info("Set the clock periods for system and SPI clocks...")
    serial_clock_period = 1000  # 1 MHz
    system_clock_period = serial_clock_period/40  # 40 MHz

    # Initialize clocks
    system_clock = Clock(dut.clk, system_clock_period, units="ns")
    cocotb.start_soon(system_clock.start())

    serial_clock = Clock(dut.uio_in[3], serial_clock_period, units="ns")
    cocotb.start_soon(serial_clock.start())

    await ClockCycles(dut.clk, 1)
    

    # Apply reset
    dut._log.info("Reset")
    await apply_reset(dut)
    
    await ClockCycles(dut.clk, 10)
    
    #startup mode
    dut._log.info("Startup mode...")
    dut._log.info("Writing parameters...")
    await write_parameters(dut,0x05,0x01,0x07,0x01,0x01,0x81) #decay,refractory_period,threshold,div_value,delays,debug_config_in);
    
    dut._log.info("Writing weights (set all the weights to +1)...")
    await write_weights(dut,1)
    
    # dut._log.info("Writing random weights...")
    # dut.uio_in[6].value = 0 #SNN_en=0;
    # await write_random_weights(dut)
    # await wait_serial_clock_cycles(dut, 1)
    
    dut._log.info("Writing input spikes (0xFF)...")
    await write_input_spikes(dut,0xFF )
    dut._log.info("SNN_en=1")
    dut.uio_in[6].value = 1 #SNN_en=1; 
    dut._log.info("Computation for 8 spikes...")
    await wait_system_clock_cycles(dut, 1)
    dut.uio_in[6].value = 0 #SNN_en=0;
   
    dut._log.info("Writing input spikes (0xAB)...")
    await write_input_spikes(dut,0xAB )
    dut._log.info("SNN_en=1")
    dut.uio_in[6].value = 1 #SNN_en=1; 
    dut._log.info("Computation for 8 spikes...")
    await wait_system_clock_cycles(dut, 1)
    dut.uio_in[6].value = 0 #SNN_en=0;   
    
    dut._log.info("Writing input spikes (0x75)...")
    await write_input_spikes(dut,0x75 )
    dut._log.info("SNN_en=1")
    dut.uio_in[6].value = 1 #SNN_en=1; 
    dut._log.info("Computation for 8 spikes...")
    await wait_system_clock_cycles(dut, 1)
    dut.uio_in[6].value = 0 #SNN_en=0;   
    
    dut._log.info("Writing input spikes (0xFF)...")
    await write_input_spikes(dut,0xFF )
    dut._log.info("SNN_en=1")
    dut.uio_in[6].value = 1 #SNN_en=1; 
    dut._log.info("Computation for 8 spikes...")
    await wait_system_clock_cycles(dut, 1)
    dut.uio_in[6].value = 0 #SNN_en=0;
    await wait_system_clock_cycles(dut, 1)
    
    dut._log.info("Writing random input spikes...")
    for i in range(2):
        # Generate a random 8-bit input spike
        random_spike = random.randint(0, 255)
        dut._log.info(f"Writing input spikes ({hex(random_spike)})...")
        await write_input_spikes(dut, random_spike)
        
        # Enable SNN computation
        dut._log.info("SNN_en=1")
        dut.uio_in[6].value = 1  # SNN_en=1; 
        
        # Wait for one system clock cycle to simulate computation
        dut._log.info("Computation...")
        await wait_system_clock_cycles(dut, 1)
        
        # Disable SNN computation
        dut.uio_in[6].value = 0  # SNN_en=0; 

    dut._log.info("Writing other 100000 random input spikes...")


    dut._log.info("Writing 100000 random input spikes...")
    for i in range(100000):
        # Generate a random 8-bit input spike
        random_spike = random.randint(0, 255)
        
        # Write input spike
        #dut._log.info(f"Writing input spikes ({hex(random_spike)})...")
        await write_input_spikes(dut, random_spike)
        
        # Enable SNN computation
        dut.uio_in[6].value = 1  # SNN_en=1;
        
        # Wait for one system clock cycle to simulate computation
        await wait_system_clock_cycles(dut, 1)
        
        # Disable SNN computation
        dut.uio_in[6].value = 0  # SNN_en=0;
        
        # Log progress at specific percentages
        if i == 25000:
            dut._log.info(f"Input spikes ({hex(random_spike)}) written at this step...")
            dut._log.info("25% complete...")
        elif i == 50000:
            dut._log.info("50% complete...")
        elif i == 75000:
            dut._log.info("75% complete...")
        elif i == 90000:
            dut._log.info("90% complete...")
        elif i == 99999:  # i reaches 100000 at the end of the loop (0-indexed)
            dut._log.info("100% complete...")

        
    # dut._log.info("Send a byte")
    # await send_byte(dut, 0x00)
    # await wait_serial_clock_cycles(dut, 2)

    # # Reset
    # dut._log.info("Reset")
    # dut.ena.value = 1
    # dut.ui_in.value = 0
    # dut.uio_in.value = 0
    # dut.rst_n.value = 0
    # await ClockCycles(dut.clk, 10)
    # dut.rst_n.value = 1

    # dut._log.info("Test project behavior")

    # # Set the input values you want to test
    # dut.ui_in.value = 20
    # dut.uio_in.value = 30

    # # Wait for one clock cycle to see the output values
    # await ClockCycles(dut.clk, 1)
    
    
    # #First test # Apply reset
    # await apply_reset(dut)
    
    # await ClockCycles(dut.clk, 5)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    #assert dut.uo_out.value == 50

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
