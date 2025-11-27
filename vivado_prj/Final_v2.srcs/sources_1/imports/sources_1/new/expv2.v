`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2025 11:09:08 AM
// Design Name: 
// Module Name: expv2
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


module expv2#(
    parameter ParallelNum = 32
)(
    input aclk,
    input arstn,

    input [16*ParallelNum-1:0] S_AXIS_TDATA,
    input S_AXIS_TVALID,
    output S_AXIS_TREADY,

    output [16*ParallelNum-1:0] M_AXIS_TDATA,
    output M_AXIS_TVALID,
    input M_AXIS_TREADY
    );


    wire [ParallelNum-1:0] exp_ready;
    wire [ParallelNum-1:0] exp_valid;
    assign S_AXIS_TREADY = exp_ready[0];
    assign M_AXIS_TVALID = exp_valid[0];


    genvar i;

    generate
        for(i=0; i<ParallelNum; i=i+1) begin:exp_inst

            wire [31:0] tdata_mul2fixed;
            wire tvalid_mul2fixed;
            wire tready_mul2fixed;
            wire unused;

            fp32_mul mul (
            .aclk(aclk),                                  // input wire aclk
            .aresetn(arstn),                            // input wire aresetn

            .s_axis_a_tvalid(S_AXIS_TVALID),            // input wire s_axis_a_tvalid
            .s_axis_a_tready(exp_ready[i]),            // output wire s_axis_a_tready
            .s_axis_a_tdata({S_AXIS_TDATA[16*i+15:16*i], 16'b0}),              // input wire [31 : 0] s_axis_a_tdata

            .s_axis_b_tvalid(1'b1),            // input wire s_axis_b_tvalid
            .s_axis_b_tready(unused),            // output wire s_axis_b_tready
            .s_axis_b_tdata(32'h3FB8AA3B),              // input wire [31 : 0] s_axis_b_tdata

            .m_axis_result_tvalid(tvalid_mul2fixed),  // output wire m_axis_result_tvalid
            .m_axis_result_tready(tready_mul2fixed),  // input wire m_axis_result_tready
            .m_axis_result_tdata(tdata_mul2fixed)    // output wire [15 : 0] m_axis_result_tdata
            );

            wire [15:0] tdata_fixed2exp;
            wire tvalid_fixed2exp;
            wire tready_fixed2exp;

            fp32_Q88 fixed (
            .aclk(aclk),                                  // input wire aclk
            .aresetn(arstn),                            // input wire aresetn

            .s_axis_a_tvalid(tvalid_mul2fixed),            // input wire s_axis_a_tvalid
            .s_axis_a_tready(tready_mul2fixed),            // output wire s_axis_a_tready
            .s_axis_a_tdata(tdata_mul2fixed),              // input wire [15 : 0] s_axis_a_tdata

            .m_axis_result_tvalid(tvalid_fixed2exp),  // output wire m_axis_result_tvalid
            .m_axis_result_tready(tready_fixed2exp),  // input wire m_axis_result_tready
            .m_axis_result_tdata(tdata_fixed2exp)    // output wire [15 : 0] m_axis_result_tdata
            );

            exp_from_uv exp_from_uv_inst(
            .aclk(aclk),
            .arstn(arstn),

            .S_AXIS_TDATA(tdata_fixed2exp),
            .S_AXIS_TVALID(tvalid_fixed2exp),
            .S_AXIS_TREADY(tready_fixed2exp),

            .M_AXIS_TDATA(M_AXIS_TDATA[16*i+15:16*i]),
            .M_AXIS_TVALID(exp_valid[i]),
            .M_AXIS_TREADY(M_AXIS_TREADY)
            );
        end
    endgenerate


endmodule
