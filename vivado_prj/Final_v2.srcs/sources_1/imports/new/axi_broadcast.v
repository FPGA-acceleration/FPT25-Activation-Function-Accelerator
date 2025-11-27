`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: axi_broadcast
//////////////////////////////////////////////////////////////////////////////////

module axi_broadcast #(
    parameter ParallelNum = 32
) (
    input  wire                     aclk,
    input  wire                     aresetn,

    input  wire [ParallelNum*16-1:0]    S_AXIS_TDATA,
    input  wire                     S_AXIS_TVALID,
    output wire                     S_AXIS_TREADY,

    output wire [ParallelNum*16-1:0]    M0_AXIS_TDATA,
    input  wire                     M0_AXIS_TREADY,
    output wire                     M0_AXIS_TVALID,

    output wire [ParallelNum*16-1:0]    M1_AXIS_TDATA,
    input  wire                     M1_AXIS_TREADY,
    output wire                     M1_AXIS_TVALID
);

// Use Xilinx axis_broadcaster_0 IP (2 outputs, 128b each)
axis_broadcaster axis_broadcaster_u (
    .aclk          (aclk),
    .aresetn       (aresetn),
    .s_axis_tvalid (S_AXIS_TVALID),
    .s_axis_tready (S_AXIS_TREADY),
    .s_axis_tdata  (S_AXIS_TDATA),
    .m_axis_tvalid ({M0_AXIS_TVALID, M1_AXIS_TVALID}),
    .m_axis_tready ({M0_AXIS_TREADY, M1_AXIS_TREADY}),
    .m_axis_tdata  ({M0_AXIS_TDATA, M1_AXIS_TDATA})
);

endmodule

