module parallelReci #(
   parameter ParallelNum = 32
)(
    input  wire        aclk,
    input  wire        aresetn,

    input  wire [16*ParallelNum-1:0] S_AXIS_TDATA,
    input  wire        S_AXIS_TVALID,
    output wire        S_AXIS_TREADY,

    output wire [16*ParallelNum-1:0] M_AXIS_TDATA,
    output wire        M_AXIS_TVALID,
    input  wire        M_AXIS_TREADY
);

wire [ParallelNum-1:0] s_axis_tready;
wire [ParallelNum-1:0] m_axis_tvalid;
wire [6:0]             shared_lut_addr [0:ParallelNum-1];
wire [ParallelNum-1:0] shared_lut_en;
wire [6:0]             shared_lut_dout [0:ParallelNum-1];

// 每通道 reciprocal 实例
genvar i;
generate
    for (i = 0; i < ParallelNum; i = i + 1) begin : reciprocal_inst
        reciprocal #(
            .USE_SHARED_LUT(1'b1)
        ) u_reciprocal (
            .aclk(aclk),
            .aresetn(aresetn),
            .S_AXIS_TDATA (S_AXIS_TDATA [16*i +: 16]),
            .S_AXIS_TVALID(S_AXIS_TVALID),
            .S_AXIS_TREADY(s_axis_tready[i]),
            .M_AXIS_TDATA (M_AXIS_TDATA [16*i +: 16]),
            .M_AXIS_TVALID(m_axis_tvalid[i]),
            .M_AXIS_TREADY(M_AXIS_TREADY),
            .shared_lut_addr (shared_lut_addr[i]),
            .shared_lut_en   (shared_lut_en[i]),
            .shared_lut_dout (shared_lut_dout[i])
        );
    end
endgenerate

// Pair lanes so each dual-port LUT services two reciprocals
localparam integer LUT_GROUPS = (ParallelNum + 1) / 2;
genvar g;
generate
    for (g = 0; g < LUT_GROUPS; g = g + 1) begin : reciprocal_lut_bank
        localparam integer LANE0 = 2*g;
        localparam integer LANE1 = 2*g + 1;

        wire [6:0] douta_wire;
        wire [6:0] doutb_wire;
        wire [6:0] addrb_wire;
        wire       enb_wire;

        if (LANE1 < ParallelNum) begin : has_lane1
            assign addrb_wire      = shared_lut_addr[LANE1];
            assign enb_wire        = shared_lut_en[LANE1];
            assign shared_lut_dout[LANE1] = doutb_wire;
        end else begin : no_lane1
            assign addrb_wire = 7'd0;
            assign enb_wire   = 1'b0;
        end

        reciprocal_lut lut_inst (
            .addra (shared_lut_addr[LANE0]),
            .clka  (aclk),
            .ena   (shared_lut_en[LANE0]),
            .douta (douta_wire),
            
            .addrb (addrb_wire),
            .clkb  (aclk),
            .enb   (enb_wire),
            .doutb (doutb_wire)
        );

        assign shared_lut_dout[LANE0] = douta_wire;
    end
endgenerate

// 汇总 ready/valid 信号
assign S_AXIS_TREADY = &s_axis_tready;
assign M_AXIS_TVALID = &m_axis_tvalid;

endmodule
