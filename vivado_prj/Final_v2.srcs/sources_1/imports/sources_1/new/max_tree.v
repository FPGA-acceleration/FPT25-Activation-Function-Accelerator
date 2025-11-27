`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2025 05:19:45 PM
// Design Name: 
// Module Name: get_maxof8
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


module max_tree#(
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

    reg [ParallelNum*16-1:0] s_axis_tdata;

    always @(posedge aclk or negedge arstn) begin
        if(!arstn) begin
            s_axis_tdata <= {ParallelNum{16'h0000}};
        end

        else if(S_AXIS_TREADY & S_AXIS_TVALID)begin
            s_axis_tdata <= S_AXIS_TDATA;
        end

        else begin
            s_axis_tdata <= s_axis_tdata;
        end
    end

    reg valid;

    always @(posedge aclk or negedge arstn) begin
        if(!arstn) begin
            valid <= 1'b0;
        end

        else if(S_AXIS_TREADY & S_AXIS_TVALID) begin
            valid <= 1'b1;
        end

        else if(M_AXIS_TREADY) begin
            valid <= 1'b0;
        end

        else begin
            valid <= valid;
        end
    end


    function integer clog2;
        input integer value;
        integer i;
        begin
            clog2 = 0;
            for (i = value - 1; i > 0; i = i >> 1)
                clog2 = clog2 + 1;
        end
    endfunction

    localparam STAGES = clog2(ParallelNum);

    reg [15:0] stages [0:STAGES-1][0:(ParallelNum>>1)-1];

    genvar s;
    generate
        for(s=0;s<STAGES;s=s+1) begin : gen_stages
            integer i;
            always @(posedge aclk or negedge arstn) begin
                if(!arstn) begin
                    for(i=0;i<(ParallelNum >> (s+1));i=i+1) begin
                        stages[s][i] <= 16'b0;
                    end
                end

                else if((S_AXIS_TREADY & S_AXIS_TVALID) | (M_AXIS_TREADY)) begin
                    if(s == 0) begin
                        for(i=0;i<(ParallelNum >> (s+1));i=i+1) begin
                            stages[s][i] <= bf16_max(s_axis_tdata[i*2*16 +:16], s_axis_tdata[i*2*16+16 +:16]);
                        end
                    end
                    else begin
                        for(i=0;i<(ParallelNum >> (s+1));i=i+1) begin
                            stages[s][i] <= bf16_max(stages[s-1][i*2], stages[s-1][i*2+1]);
                        end
                    end
                end

                else begin
                    for(i=0;i<(ParallelNum >> (s+1));i=i+1) begin
                        stages[s][i] <= stages[s][i];
                    end
                end
            end
        end
    endgenerate

    reg [STAGES-1:0] m_axis_tvalid;

    always @(posedge aclk or negedge arstn) begin
        if(!arstn) begin
            m_axis_tvalid <= {STAGES{1'b0}};
        end

        else if(S_AXIS_TREADY & S_AXIS_TVALID) begin
            m_axis_tvalid <= {m_axis_tvalid[STAGES-2:0], valid};
        end

        else if(M_AXIS_TREADY)begin
            m_axis_tvalid <= {m_axis_tvalid[STAGES-2:0], valid};
        end

        else begin
            m_axis_tvalid <= m_axis_tvalid;
        end
    end

    assign M_AXIS_TVALID = m_axis_tvalid[STAGES-1];

    assign M_AXIS_TDATA = stages[STAGES-1][0];

    assign S_AXIS_TREADY = !m_axis_tvalid[STAGES-1] || M_AXIS_TREADY;


    function automatic [15:0] bf16_max;
        input [15:0] a;
        input [15:0] b;
        reg a_sign, b_sign;
        reg [14:0] a_mag, b_mag;
        begin
            a_sign = a[15];
            b_sign = b[15];
            a_mag = a[14:0];
            b_mag = b[14:0];
            
            // 处理符号不同的情况
            if (a_sign != b_sign) begin
                // 正数总是大于负数
                bf16_max = (a_sign == 0) ? a : b;
            end
            // 处理符号相同的情况
            else if (a_sign == 0) begin
                // 两个正数：比较幅度
                bf16_max = (a_mag >= b_mag) ? a : b;
            end else begin
                // 两个负数：幅度小的更大
                bf16_max = (a_mag <= b_mag) ? a : b;
            end
        end
    endfunction
endmodule
