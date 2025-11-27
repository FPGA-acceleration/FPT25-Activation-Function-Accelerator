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


module parallelAddorSub #(
    parameter ParallelNum = 32
)(
    input aclk,
    input arstn,
    input [1:0] opcode,
    input [15:0] const_in,

    input [ParallelNum*16-1:0] S_AXIS_A_TDATA,
    input S_AXIS_A_TVALID,
    output S_AXIS_A_TREADY,

    input [ParallelNum*16-1:0] S_AXIS_B_TDATA,
    input S_AXIS_B_TVALID,
    output S_AXIS_B_TREADY,

    output [ParallelNum*16-1:0] M_AXIS_TDATA,
    output M_AXIS_TVALID,
    input M_AXIS_TREADY
    );

    wire [ParallelNum-1:0] tready_A;
    wire [ParallelNum-1:0] tready_B;
    wire [ParallelNum-1:0] tvalid;
    assign S_AXIS_A_TREADY = tready_A[0];
    assign S_AXIS_B_TREADY = tready_B[0];
    assign M_AXIS_TVALID = tvalid[0];
    
    
    wire [ParallelNum*16-1:0] negDATA;
    wire [ParallelNum*16-1:0] Bdata;
    wire Bvalid;
    Negative #(
        .ParallelNum(ParallelNum)
    )Negative_u(
        .inDATA(S_AXIS_B_TDATA),
        .outDATA(negDATA)
    );
    
    assign Bdata = opcode == 2'b00 ? S_AXIS_B_TDATA :
                    opcode == 2'b01 ? negDATA:
                    opcode == 2'b10 ? {ParallelNum{const_in}} : 0;

    assign Bvalid = opcode[1] ? 1'b1 : S_AXIS_B_TVALID;

    genvar i;

    generate
        for(i=0;i<ParallelNum;i=i+1) begin:sub_inst
            bf16_add bf16_add_u (
            .aclk(aclk),                                  // input wire aclk
            .aresetn(arstn),                            // input wire aresetn

            .s_axis_a_tvalid(S_AXIS_A_TVALID),            // input wire s_axis_a_tvalid
            .s_axis_a_tready(tready_A[i]),            // output wire s_axis_a_tready
            .s_axis_a_tdata(S_AXIS_A_TDATA[(i*16)+:16]),              // input wire [15 : 0] s_axis_a_tdata

            .s_axis_b_tvalid(Bvalid),            // input wire s_axis_b_tvalid
            .s_axis_b_tready(tready_B[i]),            // output wire s_axis_b_tready
            .s_axis_b_tdata(Bdata[(i*16)+:16]),              // input wire [15 : 0] s_axis_b_tdata

            .m_axis_result_tvalid(tvalid[i]),  // output wire m_axis_result_tvalid
            .m_axis_result_tready(M_AXIS_TREADY),  // input wire m_axis_result_tready
            .m_axis_result_tdata(M_AXIS_TDATA[(i*16)+:16])    // output wire [15 : 0] m_axis_result_tdata
            );
        end
    endgenerate


    
endmodule
