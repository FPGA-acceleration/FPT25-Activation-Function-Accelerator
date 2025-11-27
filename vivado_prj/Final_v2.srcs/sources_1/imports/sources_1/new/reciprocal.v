`timescale 1ns / 1ps


module reciprocal #(
    parameter USE_SHARED_LUT = 1'b0
)(
    input  wire        aclk,
    input  wire        aresetn,

    input  wire [15:0] S_AXIS_TDATA,
    input  wire        S_AXIS_TVALID,
    output wire        S_AXIS_TREADY,

    output wire [15:0] M_AXIS_TDATA,
    output wire        M_AXIS_TVALID,
    input  wire        M_AXIS_TREADY,

    // Optional shared LUT interface (used when USE_SHARED_LUT == 1)
    output wire [6:0]  shared_lut_addr,
    output wire        shared_lut_en,
    input  wire [6:0]  shared_lut_dout
);

// ======================================================
// 5-stage pipeline
// ======================================================
localparam integer PIPELINE_STAGES = 5;

reg  [15:0] pipe_data  [0:PIPELINE_STAGES-1];
reg         pipe_valid [0:PIPELINE_STAGES-1];
wire        pipe_ready [0:PIPELINE_STAGES-1];

// Ready chain
assign pipe_ready[0] = !pipe_valid[0] || pipe_ready[1];
assign pipe_ready[1] = !pipe_valid[1] || pipe_ready[2];
assign pipe_ready[2] = !pipe_valid[2] || pipe_ready[3];
assign pipe_ready[3] = !pipe_valid[3] || pipe_ready[4];
assign pipe_ready[4] = !pipe_valid[4] || M_AXIS_TREADY;

assign S_AXIS_TREADY = pipe_ready[0];

// ======================================================
// Stage 0: input buffer
// ======================================================
always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        pipe_data[0]  <= 16'h0000;
        pipe_valid[0] <= 1'b0;
    end else if (pipe_ready[0]) begin
        pipe_valid[0] <= S_AXIS_TVALID;
        if (S_AXIS_TVALID)
            pipe_data[0] <= S_AXIS_TDATA;
    end
end

// ======================================================
// Stage 1: Special cases & exponent computation
// ======================================================
wire        s1_sign = pipe_data[0][15];
wire [7:0]  s1_exp  = pipe_data[0][14:7];
wire [6:0]  s1_frac = pipe_data[0][6:0];

wire s1_is_zero    = (s1_exp==0)  && (s1_frac==0);
wire s1_is_inf     = (s1_exp==8'hFF) && (s1_frac==0);
wire s1_is_nan     = (s1_exp==8'hFF) && (s1_frac!=0);
wire s1_is_subnorm = (s1_exp==0)  && (s1_frac!=0);

reg [8:0] out_exp9;
reg [7:0] out_exp8;

always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        pipe_data[1]  <= 16'h0000;
        pipe_valid[1] <= 1'b0;
    end else if (pipe_ready[1]) begin
        if (pipe_valid[0]) begin
            if (s1_is_nan)
                pipe_data[1] <= {s1_sign, 8'hFF, 7'h40};
            else if (s1_is_zero)
                pipe_data[1] <= {s1_sign, 8'hFF, 7'h00};
            else if (s1_is_inf)
                pipe_data[1] <= {s1_sign, 8'h00, 7'h00};
            else if (s1_is_subnorm)
                pipe_data[1] <= {s1_sign, 8'hFF, 7'h00};
            else begin
                out_exp9 = (9'd254 - {1'b0, s1_exp}) - (s1_frac==0 ? 0 : 1);
                if (out_exp9[8] || out_exp9==0)
                    pipe_data[1] <= {s1_sign, 8'h00, 7'h00};
                else if (out_exp9[7:0] == 8'hFF)
                    pipe_data[1] <= {s1_sign, 8'hFF, 7'h00};
                else begin
                    out_exp8 = out_exp9[7:0];
                    pipe_data[1] <= {s1_sign, out_exp8, s1_frac};
                end
            end
            pipe_valid[1] <= 1'b1;
        end else
            pipe_valid[1] <= 1'b0;
    end
end

// ======================================================
// Stage 2: 发起 ROM 查询（同步 ROM 的地址输入）
// ======================================================
wire        s2_sign = pipe_data[1][15];
wire [7:0]  s2_exp  = pipe_data[1][14:7];
wire [6:0]  s2_frac = pipe_data[1][6:0];

// ROM synchronous output
wire        s2_accept = pipe_ready[2] && pipe_valid[1];
wire [6:0]  s2_frac_rec;

generate
if (USE_SHARED_LUT) begin : g_shared_lut
    assign shared_lut_addr = s2_frac;
    assign shared_lut_en   = s2_accept;
    assign s2_frac_rec     = shared_lut_dout;
end else begin : g_internal_lut
    assign shared_lut_addr = 7'd0;
    assign shared_lut_en   = 1'b0;

    reciprocal_lut lut_inst (
        .addra (s2_frac),
        .clka  (aclk),
        .ena   (1'b1),
        .douta (s2_frac_rec),
        .addrb (7'd0),
        .clkb  (1'b0),
        .enb   (1'b0),
        .doutb ()
    );
end
endgenerate

always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        pipe_data[2]  <= 16'h0000;
        pipe_valid[2] <= 1'b0;
    end else if (pipe_ready[2]) begin
        if (pipe_valid[1]) begin
            // 保存 sign+exp，mantissa 在下一级计算
            pipe_data[2] <= {s2_sign, s2_exp, s2_frac};
            pipe_valid[2] <= 1'b1;
        end else
            pipe_valid[2] <= 1'b0;
    end
end

// ======================================================
// NEW Stage 3: 接收 BRAM 的同步输出（关键增加）
// ======================================================
reg [15:0] stage3_data;

always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        pipe_data[3]  <= 16'h0000;
        pipe_valid[3] <= 1'b0;
    end else if (pipe_ready[3]) begin
        if (pipe_valid[2]) begin
            if (pipe_data[2][14:7] == 8'hFF ||
                pipe_data[2][14:7] == 8'h00)
                pipe_data[3] <= pipe_data[2]; // pass-through
            else if (pipe_data[2][6:0] == 0)
                pipe_data[3] <= {pipe_data[2][15], pipe_data[2][14:7], 7'd0};
            else
                pipe_data[3] <= {pipe_data[2][15], pipe_data[2][14:7], s2_frac_rec};

            pipe_valid[3] <= 1'b1;
        end else
            pipe_valid[3] <= 1'b0;
    end
end

// ======================================================
// Stage 4: final output register
// ======================================================
always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        pipe_data[4]  <= 16'h0000;
        pipe_valid[4] <= 1'b0;
    end else if (pipe_ready[4]) begin
        if (pipe_valid[3]) begin
            pipe_data[4]  <= pipe_data[3];
            pipe_valid[4] <= 1'b1;
        end else
            pipe_valid[4] <= 1'b0;
    end
end

assign M_AXIS_TDATA  = pipe_data[4];
assign M_AXIS_TVALID = pipe_valid[4];

endmodule
