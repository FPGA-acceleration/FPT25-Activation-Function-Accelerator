//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2025 07:51:31 PM
// Design Name: 
// Module Name: accumulater
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


module acc#(
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

    wire [15:0] tdata_add2last;
    wire tvalid_add2last;
    wire tready_add2last;

    add_tree#(
        .ParallelNum(ParallelNum)
    )add_tree_u(
        .aclk(aclk),
        .arstn(arstn),

        .S_AXIS_TDATA(S_AXIS_TDATA),
        .S_AXIS_TVALID(S_AXIS_TVALID),
        .S_AXIS_TREADY(S_AXIS_TREADY),

        .M_AXIS_TDATA(tdata_add2last),
        .M_AXIS_TVALID(tvalid_add2last),
        .M_AXIS_TREADY(tready_add2last)
    );

    wire [15:0] tdata_last2acc;
    wire tvalid_last2acc;
    wire tlast_last2acc;
    wire tready_last2acc;

    gen_tlast#(
        .ParallelNum(ParallelNum)
    )gen_last_u(
        .aclk(aclk),
        .arstn(arstn),

        .S_AXIS_TDATA(tdata_add2last),
        .S_AXIS_TVALID(tvalid_add2last),
        .S_AXIS_TREADY(tready_add2last),

        .M_AXIS_TDATA(tdata_last2acc),
        .M_AXIS_TVALID(tvalid_last2acc),
        .M_AXIS_TLAST(tlast_last2acc),    
        .M_AXIS_TREADY(tready_last2acc)
    );

    wire [15:0] acc_data;
    wire acc_valid;
    wire acc_ready;
    wire acc_last;


    bf16_acc acc_u (
        .aclk(aclk),                                  // input wire aclk
        .aresetn(arstn),                            // input wire aresetn

        .s_axis_a_tvalid(tvalid_last2acc),            // input wire s_axis_a_tvalid
        .s_axis_a_tready(tready_last2acc),            // output wire s_axis_a_tready
        .s_axis_a_tdata(tdata_last2acc),              // input wire [15 : 0] s_axis_a_tdata
        .s_axis_a_tlast(tlast_last2acc),              // input wire s_axis_a_tlast
        
        .m_axis_result_tvalid(acc_valid),  // output wire m_axis_result_tvalid
        .m_axis_result_tready(acc_ready),  // input wire m_axis_result_tready
        .m_axis_result_tdata(acc_data),    // output wire [15 : 0] m_axis_result_tdata
        .m_axis_result_tlast(acc_last)    // output wire m_axis_result_tlast
    );
    
    reg state;
    reg [4:0] out_count;
    localparam WAIT = 1'b0;
    localparam OUTPUT = 1'b1;

    always @(posedge aclk or negedge arstn) begin
        if(!arstn) begin
            state <= 1'b0;
        end

        else begin
            case (state)
                WAIT:
                    if(acc_last) begin
                        state <= OUTPUT;
                    end

                    else begin
                        state <= state;
                    end
                OUTPUT:
                    if(out_count == 5'd22 && !acc_last) begin
                        state <= WAIT;
                    end
                    else begin
                        state <= state;
                    end
            endcase
        end
    end

    always @(posedge aclk or negedge arstn) begin
        if(!arstn) begin
            out_count <= 5'b11111;
        end

        else if(M_AXIS_TREADY & M_AXIS_TVALID) begin
            if(out_count == 5'd23) begin
                out_count <= 5'b0;
            end
            else begin
                out_count <= out_count + 1'b1;
            end

        end

        else begin
            out_count <= out_count;
        end
    end

    reg [15:0] acc_holdon;
    always @(posedge aclk or negedge arstn) begin
        if(!arstn) begin
            acc_holdon <= 16'h0000;
        end

        else if(acc_last) begin
            acc_holdon <= acc_data;
        end

        else begin
            acc_holdon <= acc_holdon;
        end
    end

    assign M_AXIS_TDATA[15:0] = acc_holdon;
    assign M_AXIS_TVALID = (state == OUTPUT) ? 1'b1 : 1'b0;
    assign acc_ready = (state == WAIT) | M_AXIS_TREADY;


endmodule
