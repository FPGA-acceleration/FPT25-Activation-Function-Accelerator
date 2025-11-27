module add_tree#(
    parameter ParallelNum = 32
)(
    input              aclk,
    input              arstn,

    input  [ParallelNum*16-1:0]     S_AXIS_TDATA,
    input              S_AXIS_TVALID,
    output             S_AXIS_TREADY,

    output [15:0]      M_AXIS_TDATA,
    output             M_AXIS_TVALID,
    input              M_AXIS_TREADY
);

    localparam STAGES = clog2(ParallelNum);

    function integer clog2;
        input integer value;
        integer i;
        begin
            clog2 = 0;
            for (i = value - 1; i > 0; i = i >> 1)
                clog2 = clog2 + 1;
        end
    endfunction

    wire [15:0] stages_data [0:STAGES-1][0:(ParallelNum>>1)-1];
    wire stages_valid [0:STAGES-1][0:(ParallelNum>>1)-1];
    wire stages_ready [0:STAGES-1][0:(ParallelNum>>1)-1];

    wire ready [(ParallelNum>>1)-1:0];

    genvar s, n;
    generate
        for (s=0; s<STAGES; s=s+1) begin : STAGE
            localparam num = ParallelNum >> (s+1);
            for (n=0; n<num; n=n+1) begin : NODE
                if (s == 0) begin
                    bf16_add add_inst (
                        .aclk(aclk),
                        .aresetn(arstn),

                        .s_axis_a_tvalid(S_AXIS_TVALID),
                        .s_axis_a_tready(ready[n]),
                        .s_axis_a_tdata(S_AXIS_TDATA[16*2*n +:16]),

                        .s_axis_b_tvalid(S_AXIS_TVALID),
                        .s_axis_b_tready(),
                        .s_axis_b_tdata(S_AXIS_TDATA[16*(2*n+1) +:16]),

                        .m_axis_result_tvalid(stages_valid[s][n]),
                        .m_axis_result_tready(stages_ready[s][n]),
                        .m_axis_result_tdata(stages_data[s][n])
                    );
                end
                else begin
                    bf16_add add_inst (
                        .aclk(aclk),
                        .aresetn(arstn),

                        .s_axis_a_tvalid(stages_valid[s-1][n*2]),
                        .s_axis_a_tready(stages_ready[s-1][n*2]),
                        .s_axis_a_tdata(stages_data[s-1][n*2]),

                        .s_axis_b_tvalid(stages_valid[s-1][n*2+1]),
                        .s_axis_b_tready(stages_ready[s-1][n*2+1]),
                        .s_axis_b_tdata(stages_data[s-1][n*2+1]),

                        .m_axis_result_tvalid(stages_valid[s][n]),
                        .m_axis_result_tready(stages_ready[s][n]),
                        .m_axis_result_tdata(stages_data[s][n])
                    );
                end
            end
        end
    endgenerate

    assign S_AXIS_TREADY = ready[0];
    assign M_AXIS_TVALID = stages_valid[STAGES-1][0];
    assign stages_ready[STAGES-1][0] = M_AXIS_TREADY;
    assign M_AXIS_TDATA = stages_data[STAGES-1][0];

endmodule
