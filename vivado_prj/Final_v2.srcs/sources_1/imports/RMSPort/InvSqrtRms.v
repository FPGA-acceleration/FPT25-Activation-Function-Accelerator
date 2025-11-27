`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2025 08:40:09 PM
// Design Name: 
// Module Name: InvSqrtRms
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


module InvSqrtRms#(
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

wire [15:0] post_invsqrt_data; 
wire post_invsqrt_valid;
wire post_invsqrt_ready;



    cal_rms_top #(
        .ParallelNum(ParallelNum)
    ) cal_rms_top(
        .aclk(aclk),
        .arstn(arstn),
        .S_AXIS_TVALID(S_AXIS_TVALID),            // input wire s_axis_a_tvalid
        .S_AXIS_TREADY(S_AXIS_TREADY),            // output wire s_axis_a_tready
        .S_AXIS_TDATA(S_AXIS_TDATA),              // input wire [15 : 0] s_axis_a_tdata
        .M_AXIS_TVALID(post_invsqrt_valid),  // output wire m_axis_result_tvalid
        .M_AXIS_TREADY(post_invsqrt_ready),  // input wire m_axis_result_tready
        .M_AXIS_TDATA(post_invsqrt_data)    // output wire [15 : 0] m_axis_result_tdata
    );




wire add_eps_ready;
wire add_eps_valid;
wire [15:0] add_eps_data;

bf16_add STAGE1_addeps(
        .aclk(aclk),
        .aresetn(arstn),
        .s_axis_a_tvalid(post_invsqrt_valid),            // input wire s_axis_a_tvalid
        .s_axis_a_tready(post_invsqrt_ready),            // output wire s_axis_a_tready
        .s_axis_a_tdata(post_invsqrt_data),              // input wire [15 : 0] s_axis_a_tdata
        .s_axis_b_tready(),
        .s_axis_b_tvalid(1'b1),
        .s_axis_b_tdata(16'h3728),

        .m_axis_result_tvalid(add_eps_valid),  // output wire m_axis_result_tvalid
        .m_axis_result_tready(add_eps_ready),  // input wire m_axis_result_tready
        .m_axis_result_tdata(add_eps_data)    // output wire [15 : 0] m_axis_result_tdata

  );  


wire invsqrt_ready;
wire invsqrt_valid;
wire [15:0] invsqrt_data;

bf16_invsqrt_shell STAGE1_invsqrt(
        .aclk(aclk),
        .aresetn(arstn),
        .S_AXIS_TVALID(add_eps_valid),            // input wire s_axis_a_tvalid
        .S_AXIS_TREADY(add_eps_ready),            // output wire s_axis_a_tready
        .S_AXIS_TDATA(add_eps_data),              // input wire [15 : 0] s_axis_a_tdata
        .M_AXIS_TVALID(invsqrt_valid),  // output wire m_axis_result_tvalid
        .M_AXIS_TREADY(invsqrt_ready),  // input wire m_axis_result_tready
        .M_AXIS_TDATA(invsqrt_data)    // output wire [15 : 0] m_axis_result_tdata

  );

assign M_AXIS_TDATA = {ParallelNum{invsqrt_data}};
assign M_AXIS_TVALID = invsqrt_valid;
assign invsqrt_ready = M_AXIS_TREADY;


endmodule