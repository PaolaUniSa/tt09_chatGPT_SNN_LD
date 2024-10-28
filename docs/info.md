<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements 16 programmable digital LIF neurons with programmable delays and a total of 128 synapsis. The neurons are arranged in 2 layers (8 inputs + FC (8 neurons) + FC (8 neurons) ). Spikes_in directly maps to the inputs of the first layer neurons. When an input spike is received, it is first multiplied by an 2 bit weight, programmable from an SPI interface, 1 per input neuron. This 8 bit value is then added to the membrane potential of the respective neuron. When the first layer neurons activate, its pulse is routed to each of the 8 neurons in the next layer. There are 128 (8x8+8x8) programmable weights describing the connectivity between the input spikes and the first layer (64 weights=8x8), the first and second layers (64 weights=8x8). Output spikes from the 2nd layer drive spikes_out.

## How to test

Explain how to use your project

## External hardware

List external hardware used in your project (e.g. PMOD, LED display, etc), if any
