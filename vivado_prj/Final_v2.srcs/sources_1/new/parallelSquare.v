`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2025 09:32:51 PM
// Design Name: 
// Module Name: sub_max
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


module parallelSquare#(
    parameter ParallelNum = 32
)(
    input aclk,
    input arstn,

    input [ParallelNum*16-1:0] S_AXIS_TDATA,
    input S_AXIS_TVALID,
    output S_AXIS_TREADY,

    output [ParallelNum*16-1:0] M_AXIS_TDATA,
    output M_AXIS_TVALID,
    input M_AXIS_TREADY
    );

    wire [ParallelNum-1:0] tready;
    wire [ParallelNum-1:0] tvalid;
    assign S_AXIS_TREADY = tready[0];
    assign M_AXIS_TVALID = tvalid[0];

    genvar i;

    generate
        for(i=0;i<ParallelNum;i=i+1) begin:sub_inst
            bf16_mul bf16_mul_u (
            .aclk(aclk),                                  // input wire aclk
            .aresetn(arstn),                            // input wire aresetn

            .s_axis_a_tvalid(S_AXIS_TVALID),            // input wire s_axis_a_tvalid
            .s_axis_a_tready(tready[i]),            // output wire s_axis_a_tready
            .s_axis_a_tdata(S_AXIS_TDATA[(i*16)+:16]),              // input wire [15 : 0] s_axis_a_tdata

            .s_axis_b_tvalid(S_AXIS_TVALID),            // input wire s_axis_b_tvalid
            .s_axis_b_tready(),            // output wire s_axis_b_tready
            .s_axis_b_tdata(S_AXIS_TDATA[(i*16)+:16]),              // input wire [15 : 0] s_axis_b_tdata

            .m_axis_result_tvalid(tvalid[i]),  // output wire m_axis_result_tvalid
            .m_axis_result_tready(M_AXIS_TREADY),  // input wire m_axis_result_tready
            .m_axis_result_tdata(M_AXIS_TDATA[(i*16)+:16])    // output wire [15 : 0] m_axis_result_tdata
            );
        end
    endgenerate


    
endmodule
