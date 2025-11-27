`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/18/2025 10:51:45 AM
// Design Name: 
// Module Name: cal_rms_sum_top
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


module cal_rms_top#(
    parameter ParallelNum = 32
)(
    input aclk,
    input arstn,

    input [ParallelNum*16-1:0] S_AXIS_TDATA,
    input S_AXIS_TVALID,
    output S_AXIS_TREADY,

    output [15:0] M_AXIS_TDATA,
    output M_AXIS_TVALID,
    input M_AXIS_TREADY
    );
    
    wire [ParallelNum*16-1:0] square_data;
    wire square_valid;
    wire square_ready;
    
    
    
 
    
    
    parallelSquare #(
        .ParallelNum(ParallelNum)
    ) STAGE1_square_mul (
        .aclk(aclk),
        .arstn(arstn),
        .S_AXIS_TDATA(S_AXIS_TDATA),
        .S_AXIS_TVALID(S_AXIS_TVALID),
        .S_AXIS_TREADY(S_AXIS_TREADY),
        .M_AXIS_TDATA(square_data),
        .M_AXIS_TVALID(square_valid),
        .M_AXIS_TREADY(square_ready)
    );

    wire [15:0] acc_data;
    wire acc_valid;
    wire acc_ready;
    
    acc #(
        .ParallelNum(ParallelNum)
    ) STAGE2_acc (
        .aclk(aclk),
        .arstn(arstn),
        .S_AXIS_TDATA(square_data),
        .S_AXIS_TVALID(square_valid),
        .S_AXIS_TREADY(square_ready),
        .M_AXIS_TDATA(acc_data),
        .M_AXIS_TVALID(acc_valid),
        .M_AXIS_TREADY(acc_ready)
    );


    bf16_div STAGE3_div (
          .aclk(aclk),
          .aresetn(arstn),
          .s_axis_a_tvalid(acc_valid),
          .s_axis_a_tready(acc_ready),
          .s_axis_a_tdata(acc_data),
          
          
          .s_axis_b_tvalid(1'b1),
          .s_axis_b_tready(),
          .s_axis_b_tdata(16'h4440), //
          
          
          .m_axis_result_tvalid(M_AXIS_TVALID),
          .m_axis_result_tready(M_AXIS_TREADY),
          .m_axis_result_tdata(M_AXIS_TDATA)
      );  
    
   
    
    
    
endmodule
