`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2025 09:21:30 PM
// Design Name: 
// Module Name: max
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module max#(
    parameter ParallelNum = 32
)(
    input aclk,
    input arstn,

    input [ParallelNum*16-1:0] S_AXIS_TDATA,
    input S_AXIS_TVALID,
    output S_AXIS_TREADY,

    //meta data output
    output [15:0] M_AXIS_TDATA,
    output M_AXIS_TVALID,
    input M_AXIS_TREADY
    );

    wire [15:0] tdata_p2s;
    wire tvalid_p2s;
    wire tready_p2s;

    max_tree#(
        .ParallelNum(ParallelNum)
    )max_tree_u(
        .aclk(aclk),
        .arstn(arstn),

        .S_AXIS_TDATA(S_AXIS_TDATA),
        .S_AXIS_TVALID(S_AXIS_TVALID),
        .S_AXIS_TREADY(S_AXIS_TREADY),

        .M_AXIS_TDATA(tdata_p2s),
        .M_AXIS_TVALID(tvalid_p2s),
        .M_AXIS_TREADY(tready_p2s)
    );

    serial_max#(
        .ParallelNum(ParallelNum)
    )serial_max_u(
        .aclk(aclk),
        .arstn(arstn),

        .S_AXIS_TDATA(tdata_p2s),
        .S_AXIS_TVALID(tvalid_p2s),
        .S_AXIS_TREADY(tready_p2s),

        .M_AXIS_TDATA(M_AXIS_TDATA),
        .M_AXIS_TVALID(M_AXIS_TVALID),
        .M_AXIS_TREADY(M_AXIS_TREADY)
    );
endmodule
