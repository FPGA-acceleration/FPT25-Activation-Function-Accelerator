`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/18/2025 04:21:51 PM
// Design Name: 
// Module Name: duplicate
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


module duplicate#(
    parameter ParallelNum = 32
)(
    input aclk,
    input arstn,
    
    input [15:0] S_AXIS_TDATA,
    input S_AXIS_TVALID,
    output S_AXIS_TREADY,
    
    output [ParallelNum*16-1:0] M_AXIS_TDATA,
    output M_AXIS_TVALID,
    input M_AXIS_TREADY
    
    );
    
    assign M_AXIS_TDATA = {ParallelNum{S_AXIS_TDATA}};
    assign M_AXIS_TVALID = S_AXIS_TVALID;
    assign S_AXIS_TREADY = M_AXIS_TREADY;
endmodule
