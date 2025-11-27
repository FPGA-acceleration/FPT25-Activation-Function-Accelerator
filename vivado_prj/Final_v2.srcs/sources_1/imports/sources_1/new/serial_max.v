`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2025 05:39:50 PM
// Design Name: 
// Module Name: get_max
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


module serial_max#(
    parameter ParallelNum = 32
)(
    input aclk,
    input arstn,

    input [15:0] S_AXIS_TDATA,
    input S_AXIS_TVALID,
    output S_AXIS_TREADY,

    output [15:0] M_AXIS_TDATA,
    output M_AXIS_TVALID,
    input M_AXIS_TREADY
    );


    reg [4:0] count;
    reg [4:0] out_count;
    reg [15:0] max_value;
    reg [15:0] maxo_reg;

    reg state;
    localparam WAIT = 1'b0;
    localparam OUTPUT = 1'b1;

    always @(posedge aclk or negedge arstn) begin
        if(!arstn) begin
            state <= 1'b0;
        end

        else begin
            case (state)
                WAIT:
                    state <= (count == 5'd23) ? OUTPUT : WAIT;
                OUTPUT:
                    if(out_count == 5'd23 && count != 5'd0) begin
                        state <= WAIT;
                    end
                    else begin
                        state <= OUTPUT;
                    end
            endcase
        end
    end

    always @(posedge aclk or negedge arstn) begin
        if(!arstn) begin
            count <= 5'b11111;
        end

        else if(S_AXIS_TREADY & S_AXIS_TVALID) begin
            if(count == 5'd23) begin
                count <= 5'b0;
            end
            else begin
                count <= count + 1'b1;
            end

        end

        else begin
            count <= count;
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


    always @(posedge aclk or negedge arstn) begin
        if(!arstn) begin
            max_value <= 16'hFFFF;
        end

        else if(S_AXIS_TREADY & S_AXIS_TVALID) begin
            if(count == 5'd23) begin
                max_value <= S_AXIS_TDATA;
            end
            else begin
                max_value <= bf16_max(S_AXIS_TDATA, max_value);
            end
        end

        else begin
            max_value <= max_value;
        end
    end


    always @(posedge aclk or negedge arstn) begin
        if(!arstn) begin
            maxo_reg <= 16'h0000;
        end

        else if(count == 5'd23) begin
            maxo_reg <= max_value;
        end

        else begin
            maxo_reg <= maxo_reg;
        end
    end



    assign S_AXIS_TREADY = (state == WAIT) | M_AXIS_TREADY;
    assign M_AXIS_TVALID = (state == OUTPUT);
    assign M_AXIS_TDATA = maxo_reg;


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
