`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/16 21:04:23
// Module Name: Negative
//////////////////////////////////////////////////////////////////////////////////

module Negative #(
    parameter ParallelNum = 32
)(
    input wire [16*ParallelNum-1:0] inDATA,

    output wire [16*ParallelNum-1:0] outDATA
);

// Per-channel unpack and sign inversion
genvar i;
generate
    for (i = 0; i < ParallelNum; i = i + 1) begin: neg_inst
        // local wires for this channel
        wire s       = inDATA[16*i + 15];
        wire [7:0] e = inDATA[16*i + 14 -:8];
        wire [6:0] m = inDATA[16*i + 6 -:7];

        assign outDATA[16*i + 15]     = ~s;
        assign outDATA[16*i + 14 -:8] = e;
        assign outDATA[16*i + 6 -:7]  = m;
    end
endgenerate


endmodule
