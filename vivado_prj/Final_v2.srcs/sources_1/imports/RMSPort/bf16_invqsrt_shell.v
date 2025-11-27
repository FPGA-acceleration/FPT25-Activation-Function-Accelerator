`timescale 1ns / 1ps

module bf16_invsqrt_shell(
    input  wire        aclk,
    input  wire        aresetn,

    input  wire [15:0] S_AXIS_TDATA,
    input  wire        S_AXIS_TVALID,
    output wire        S_AXIS_TREADY,

    output wire [15:0] M_AXIS_TDATA,
    output wire        M_AXIS_TVALID,
    input  wire        M_AXIS_TREADY
    );
    
   
   wire [31:0] m_axis_result_tdata ;
   
    fp32_invsqrt u_invsqrt(
       .aclk(aclk),                                  // input wire aclk
      .aresetn(aresetn),                            // input wire aresetn
      .s_axis_a_tvalid(S_AXIS_TVALID),            // input wire s_axis_a_tvalid
      .s_axis_a_tready(S_AXIS_TREADY),            // output wire s_axis_a_tready
      .s_axis_a_tdata({ S_AXIS_TDATA, 16'h0000 }),              // input wire [31 : 0] s_axis_a_tdata
      .m_axis_result_tvalid(M_AXIS_TVALID),  // output wire m_axis_result_tvalid
      .m_axis_result_tready(M_AXIS_TREADY),  // input wire m_axis_result_tready
      .m_axis_result_tdata(m_axis_result_tdata)    // output wire [31 : 0] m_axis_result_tdata
    
    );
    
    
    assign M_AXIS_TDATA = m_axis_result_tdata[31:16] + m_axis_result_tdata[15];  

endmodule
