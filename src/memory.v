module memory
(
    input wire [7:0] data_in,//[N-1:0] data_in,
    input wire [6:0] addr,//[$clog2(M)-1:0] addr,
    input wire write_enable,
    input wire clk,
    input wire reset,
    output reg [7:0] data_out,//[N-1:0] data_out,
    output reg [113*8-1:0] all_data_out//[M*N-1:0] all_data_out   (5+32+64+1)=102 bytes
);

    // Declare the memory array 
    reg [7:0] mem [0:113-1];
    integer j;
    
    reg [6:0] addr_reg_out;
    wire [6:0] addr_reg_in;
    
    assign addr_reg_in = addr;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Asynchronous reset: clear all memory contents
//            for (i = 0; i < 149; i = i + 1) begin
//                mem[i] <= 0; 
//            end
            addr_reg_out <= 0;
            mem[0] <= 0;
            mem[1] <= 0;
            mem[2] <= 0;
            mem[3] <= 0;
            mem[4] <= 0;
            mem[5] <= 0;
            mem[6] <= 0;
            mem[7] <= 0;
            mem[8] <= 0;
            mem[9] <= 0;
            mem[10] <= 0;
            mem[11] <= 0;
            mem[12] <= 0;
            mem[13] <= 0;
            mem[14] <= 0;
            mem[15] <= 0;
            mem[16] <= 0;
            mem[17] <= 0;
            mem[18] <= 0;
            mem[19] <= 0;
            mem[20] <= 0;
            mem[21] <= 0;
            mem[22] <= 0;
            mem[23] <= 0;
            mem[24] <= 0;
            mem[25] <= 0;
            mem[26] <= 0;
            mem[27] <= 0;
            mem[28] <= 0;
            mem[29] <= 0;
            mem[30] <= 0;
            mem[31] <= 0;
            mem[32] <= 0;
            mem[33] <= 0;
            mem[34] <= 0;
            mem[35] <= 0;
            mem[36] <= 0;
            mem[37] <= 0;
            mem[38] <= 0;
            mem[39] <= 0;
            mem[40] <= 0;
            mem[41] <= 0;
            mem[42] <= 0;
            mem[43] <= 0;
            mem[44] <= 0;
            mem[45] <= 0;
            mem[46] <= 0;
            mem[47] <= 0;
            mem[48] <= 0;
            mem[49] <= 0;
            mem[50] <= 0;
            mem[51] <= 0;
            mem[52] <= 0;
            mem[53] <= 0;
            mem[54] <= 0;
            mem[55] <= 0;
            mem[56] <= 0;
            mem[57] <= 0;
            mem[58] <= 0;
            mem[59] <= 0;
            mem[60] <= 0;
            mem[61] <= 0;
            mem[62] <= 0;
            mem[63] <= 0;
            mem[64] <= 0;
            mem[65] <= 0;
            mem[66] <= 0;
            mem[67] <= 0;
            mem[68] <= 0;
            mem[69] <= 0;
            mem[70] <= 0;
            mem[71] <= 0;
            mem[72] <= 0;
            mem[73] <= 0;
            mem[74] <= 0;
            mem[75] <= 0;
            mem[76] <= 0;
            mem[77] <= 0;
            mem[78] <= 0;
            mem[79] <= 0;
            mem[80] <= 0;
            mem[81] <= 0;
            mem[82] <= 0;
            mem[83] <= 0;
            mem[84] <= 0;
            mem[85] <= 0;
            mem[86] <= 0;
            mem[87] <= 0;
            mem[88] <= 0;
            mem[89] <= 0;
            mem[90] <= 0;
            mem[91] <= 0;
            mem[92] <= 0;
            mem[93] <= 0;
            mem[94] <= 0;
            mem[95] <= 0;
            mem[96] <= 0;
            mem[97] <= 0;
            mem[98] <= 0;
            mem[99] <= 0;
            mem[100] <= 0;
            mem[101] <= 0;
            mem[102] <= 0;
            mem[103] <= 0;
            mem[104] <= 0;
            mem[105] <= 0;
            mem[106] <= 0;
            mem[107] <= 0;
            mem[108] <= 0;
            mem[109] <= 0;
            mem[110] <= 0;
            mem[111] <= 0;
            mem[112] <= 0;
//            mem[113] <= 0;
//            mem[114] <= 0;
//            mem[115] <= 0;
//            mem[116] <= 0;
//            mem[117] <= 0;
//            mem[118] <= 0;
//            mem[119] <= 0;
//            mem[120] <= 0;
//            mem[121] <= 0;
//            mem[122] <= 0;
//            mem[123] <= 0;
//            mem[124] <= 0;
//            mem[125] <= 0;
//            mem[126] <= 0;
//            mem[127] <= 0;
//            mem[128] <= 0;
//            mem[129] <= 0;
//            mem[130] <= 0;
//            mem[131] <= 0;
//            mem[132] <= 0;
//            mem[133] <= 0;
//            mem[134] <= 0;
//            mem[135] <= 0;
//            mem[136] <= 0;
//            mem[137] <= 0;
//            mem[138] <= 0;
//            mem[139] <= 0;
//            mem[140] <= 0;
//            mem[141] <= 0;
//            mem[142] <= 0;
//            mem[143] <= 0;
//            mem[144] <= 0;
//            mem[145] <= 0;
//            mem[146] <= 0;
//            mem[147] <= 0;
//            mem[148] <= 0;
            
        end else if (write_enable) begin
            mem[addr_reg_in] <= data_in;  // Write data to memory
            addr_reg_out <= addr_reg_in;
        end
    end

    always @(*) begin
        // Output the data at the current address
        data_out = mem[addr_reg_out];

        // Concatenate all memory data into all_data_out
        for (j = 0; j < 113; j = j + 1) begin
            all_data_out[j*8 +: 8] = mem[j];
        end
    end
    
endmodule
