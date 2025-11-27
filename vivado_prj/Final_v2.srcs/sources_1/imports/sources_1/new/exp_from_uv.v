//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2025 04:29:16 PM
// Design Name: 
// Module Name: exp_from_uv
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


module exp_from_uv(
    input aclk,
    input arstn,

    input [15:0] S_AXIS_TDATA,
    input S_AXIS_TVALID,
    output S_AXIS_TREADY,

    output [15:0] M_AXIS_TDATA,
    output M_AXIS_TVALID,
    input M_AXIS_TREADY
    );

    reg [15:0] s_axis_tdata;

    always @(posedge aclk or negedge arstn) begin
        if(!arstn) begin
            s_axis_tdata <= 16'b0;
        end

        else if(S_AXIS_TREADY & S_AXIS_TVALID)begin
            s_axis_tdata <= S_AXIS_TDATA;
        end

        else begin
            s_axis_tdata <= s_axis_tdata;
        end
    end

    reg m_axis_tvalid;

    always @(posedge aclk or negedge arstn) begin
        if(!arstn) begin
            m_axis_tvalid <= 1'b0;
        end

        else if(S_AXIS_TREADY & S_AXIS_TVALID) begin
            m_axis_tvalid <= 1'b1;
        end

        else if(M_AXIS_TREADY & M_AXIS_TVALID)begin
            m_axis_tvalid <= 1'b0;
        end

        else begin
            m_axis_tvalid <= m_axis_tvalid;
        end
    end

    assign M_AXIS_TVALID = m_axis_tvalid;


    wire [7:0] frac = s_axis_tdata[7:0];
    wire [7:0] int_value = s_axis_tdata[15:8];

    wire [6:0] power2_v = exp2_func(frac);

    wire [7:0] exp = int_value + 8'd127;

    wire [7:0] exp_modified = exp == 8'b1111_1111 ? 8'b0 : exp;

    assign M_AXIS_TDATA = {1'b0, exp_modified, power2_v};

    assign S_AXIS_TREADY = !m_axis_tvalid || M_AXIS_TREADY;
    
    function automatic [6:0] exp2_func;
        input [7:0] frac;
        begin
            case (frac)
                8'd0   : exp2_func = 7'd0;
                8'd1   : exp2_func = 7'd0;
                8'd2   : exp2_func = 7'd1;
                8'd3   : exp2_func = 7'd1;
                8'd4   : exp2_func = 7'd1;
                8'd5   : exp2_func = 7'd2;
                8'd6   : exp2_func = 7'd2;
                8'd7   : exp2_func = 7'd2;
                8'd8   : exp2_func = 7'd3;
                8'd9   : exp2_func = 7'd3;
                8'd10  : exp2_func = 7'd4;
                8'd11  : exp2_func = 7'd4;
                8'd12  : exp2_func = 7'd4;
                8'd13  : exp2_func = 7'd5;
                8'd14  : exp2_func = 7'd5;
                8'd15  : exp2_func = 7'd5;
                8'd16  : exp2_func = 7'd6;
                8'd17  : exp2_func = 7'd6;
                8'd18  : exp2_func = 7'd6;
                8'd19  : exp2_func = 7'd7;
                8'd20  : exp2_func = 7'd7;
                8'd21  : exp2_func = 7'd7;
                8'd22  : exp2_func = 7'd8;
                8'd23  : exp2_func = 7'd8;
                8'd24  : exp2_func = 7'd9;
                8'd25  : exp2_func = 7'd9;
                8'd26  : exp2_func = 7'd9;
                8'd27  : exp2_func = 7'd10;
                8'd28  : exp2_func = 7'd10;
                8'd29  : exp2_func = 7'd10;
                8'd30  : exp2_func = 7'd11;
                8'd31  : exp2_func = 7'd11;
                8'd32  : exp2_func = 7'd12;
                8'd33  : exp2_func = 7'd12;
                8'd34  : exp2_func = 7'd12;
                8'd35  : exp2_func = 7'd13;
                8'd36  : exp2_func = 7'd13;
                8'd37  : exp2_func = 7'd13;
                8'd38  : exp2_func = 7'd14;
                8'd39  : exp2_func = 7'd14;
                8'd40  : exp2_func = 7'd15;
                8'd41  : exp2_func = 7'd15;
                8'd42  : exp2_func = 7'd15;
                8'd43  : exp2_func = 7'd16;
                8'd44  : exp2_func = 7'd16;
                8'd45  : exp2_func = 7'd17;
                8'd46  : exp2_func = 7'd17;
                8'd47  : exp2_func = 7'd17;
                8'd48  : exp2_func = 7'd18;
                8'd49  : exp2_func = 7'd18;
                8'd50  : exp2_func = 7'd19;
                8'd51  : exp2_func = 7'd19;
                8'd52  : exp2_func = 7'd19;
                8'd53  : exp2_func = 7'd20;
                8'd54  : exp2_func = 7'd20;
                8'd55  : exp2_func = 7'd21;
                8'd56  : exp2_func = 7'd21;
                8'd57  : exp2_func = 7'd21;
                8'd58  : exp2_func = 7'd22;
                8'd59  : exp2_func = 7'd22;
                8'd60  : exp2_func = 7'd23;
                8'd61  : exp2_func = 7'd23;
                8'd62  : exp2_func = 7'd23;
                8'd63  : exp2_func = 7'd24;
                8'd64  : exp2_func = 7'd24;
                8'd65  : exp2_func = 7'd25;
                8'd66  : exp2_func = 7'd25;
                8'd67  : exp2_func = 7'd25;
                8'd68  : exp2_func = 7'd26;
                8'd69  : exp2_func = 7'd26;
                8'd70  : exp2_func = 7'd27;
                8'd71  : exp2_func = 7'd27;
                8'd72  : exp2_func = 7'd28;
                8'd73  : exp2_func = 7'd28;
                8'd74  : exp2_func = 7'd28;
                8'd75  : exp2_func = 7'd29;
                8'd76  : exp2_func = 7'd29;
                8'd77  : exp2_func = 7'd30;
                8'd78  : exp2_func = 7'd30;
                8'd79  : exp2_func = 7'd31;
                8'd80  : exp2_func = 7'd31;
                8'd81  : exp2_func = 7'd31;
                8'd82  : exp2_func = 7'd32;
                8'd83  : exp2_func = 7'd32;
                8'd84  : exp2_func = 7'd33;
                8'd85  : exp2_func = 7'd33;
                8'd86  : exp2_func = 7'd34;
                8'd87  : exp2_func = 7'd34;
                8'd88  : exp2_func = 7'd34;
                8'd89  : exp2_func = 7'd35;
                8'd90  : exp2_func = 7'd35;
                8'd91  : exp2_func = 7'd36;
                8'd92  : exp2_func = 7'd36;
                8'd93  : exp2_func = 7'd37;
                8'd94  : exp2_func = 7'd37;
                8'd95  : exp2_func = 7'd38;
                8'd96  : exp2_func = 7'd38;
                8'd97  : exp2_func = 7'd38;
                8'd98  : exp2_func = 7'd39;
                8'd99  : exp2_func = 7'd39;
                8'd100 : exp2_func = 7'd40;
                8'd101 : exp2_func = 7'd40;
                8'd102 : exp2_func = 7'd41;
                8'd103 : exp2_func = 7'd41;
                8'd104 : exp2_func = 7'd42;
                8'd105 : exp2_func = 7'd42;
                8'd106 : exp2_func = 7'd43;
                8'd107 : exp2_func = 7'd43;
                8'd108 : exp2_func = 7'd43;
                8'd109 : exp2_func = 7'd44;
                8'd110 : exp2_func = 7'd44;
                8'd111 : exp2_func = 7'd45;
                8'd112 : exp2_func = 7'd45;
                8'd113 : exp2_func = 7'd46;
                8'd114 : exp2_func = 7'd46;
                8'd115 : exp2_func = 7'd47;
                8'd116 : exp2_func = 7'd47;
                8'd117 : exp2_func = 7'd48;
                8'd118 : exp2_func = 7'd48;
                8'd119 : exp2_func = 7'd49;
                8'd120 : exp2_func = 7'd49;
                8'd121 : exp2_func = 7'd50;
                8'd122 : exp2_func = 7'd50;
                8'd123 : exp2_func = 7'd51;
                8'd124 : exp2_func = 7'd51;
                8'd125 : exp2_func = 7'd52;
                8'd126 : exp2_func = 7'd52;
                8'd127 : exp2_func = 7'd53;
                8'd128 : exp2_func = 7'd53;
                8'd129 : exp2_func = 7'd54;
                8'd130 : exp2_func = 7'd54;
                8'd131 : exp2_func = 7'd54;
                8'd132 : exp2_func = 7'd55;
                8'd133 : exp2_func = 7'd55;
                8'd134 : exp2_func = 7'd56;
                8'd135 : exp2_func = 7'd56;
                8'd136 : exp2_func = 7'd57;
                8'd137 : exp2_func = 7'd57;
                8'd138 : exp2_func = 7'd58;
                8'd139 : exp2_func = 7'd58;
                8'd140 : exp2_func = 7'd59;
                8'd141 : exp2_func = 7'd60;
                8'd142 : exp2_func = 7'd60;
                8'd143 : exp2_func = 7'd61;
                8'd144 : exp2_func = 7'd61;
                8'd145 : exp2_func = 7'd62;
                8'd146 : exp2_func = 7'd62;
                8'd147 : exp2_func = 7'd63;
                8'd148 : exp2_func = 7'd63;
                8'd149 : exp2_func = 7'd64;
                8'd150 : exp2_func = 7'd64;
                8'd151 : exp2_func = 7'd65;
                8'd152 : exp2_func = 7'd65;
                8'd153 : exp2_func = 7'd66;
                8'd154 : exp2_func = 7'd66;
                8'd155 : exp2_func = 7'd67;
                8'd156 : exp2_func = 7'd67;
                8'd157 : exp2_func = 7'd68;
                8'd158 : exp2_func = 7'd68;
                8'd159 : exp2_func = 7'd69;
                8'd160 : exp2_func = 7'd69;
                8'd161 : exp2_func = 7'd70;
                8'd162 : exp2_func = 7'd70;
                8'd163 : exp2_func = 7'd71;
                8'd164 : exp2_func = 7'd72;
                8'd165 : exp2_func = 7'd72;
                8'd166 : exp2_func = 7'd73;
                8'd167 : exp2_func = 7'd73;
                8'd168 : exp2_func = 7'd74;
                8'd169 : exp2_func = 7'd74;
                8'd170 : exp2_func = 7'd75;
                8'd171 : exp2_func = 7'd75;
                8'd172 : exp2_func = 7'd76;
                8'd173 : exp2_func = 7'd76;
                8'd174 : exp2_func = 7'd77;
                8'd175 : exp2_func = 7'd78;
                8'd176 : exp2_func = 7'd78;
                8'd177 : exp2_func = 7'd79;
                8'd178 : exp2_func = 7'd79;
                8'd179 : exp2_func = 7'd80;
                8'd180 : exp2_func = 7'd80;
                8'd181 : exp2_func = 7'd81;
                8'd182 : exp2_func = 7'd82;
                8'd183 : exp2_func = 7'd82;
                8'd184 : exp2_func = 7'd83;
                8'd185 : exp2_func = 7'd83;
                8'd186 : exp2_func = 7'd84;
                8'd187 : exp2_func = 7'd84;
                8'd188 : exp2_func = 7'd85;
                8'd189 : exp2_func = 7'd86;
                8'd190 : exp2_func = 7'd86;
                8'd191 : exp2_func = 7'd87;
                8'd192 : exp2_func = 7'd87;
                8'd193 : exp2_func = 7'd88;
                8'd194 : exp2_func = 7'd88;
                8'd195 : exp2_func = 7'd89;
                8'd196 : exp2_func = 7'd90;
                8'd197 : exp2_func = 7'd90;
                8'd198 : exp2_func = 7'd91;
                8'd199 : exp2_func = 7'd91;
                8'd200 : exp2_func = 7'd92;
                8'd201 : exp2_func = 7'd93;
                8'd202 : exp2_func = 7'd93;
                8'd203 : exp2_func = 7'd94;
                8'd204 : exp2_func = 7'd94;
                8'd205 : exp2_func = 7'd95;
                8'd206 : exp2_func = 7'd96;
                8'd207 : exp2_func = 7'd96;
                8'd208 : exp2_func = 7'd97;
                8'd209 : exp2_func = 7'd97;
                8'd210 : exp2_func = 7'd98;
                8'd211 : exp2_func = 7'd99;
                8'd212 : exp2_func = 7'd99;
                8'd213 : exp2_func = 7'd100;
                8'd214 : exp2_func = 7'd100;
                8'd215 : exp2_func = 7'd101;
                8'd216 : exp2_func = 7'd102;
                8'd217 : exp2_func = 7'd102;
                8'd218 : exp2_func = 7'd103;
                8'd219 : exp2_func = 7'd104;
                8'd220 : exp2_func = 7'd104;
                8'd221 : exp2_func = 7'd105;
                8'd222 : exp2_func = 7'd105;
                8'd223 : exp2_func = 7'd106;
                8'd224 : exp2_func = 7'd107;
                8'd225 : exp2_func = 7'd107;
                8'd226 : exp2_func = 7'd108;
                8'd227 : exp2_func = 7'd109;
                8'd228 : exp2_func = 7'd109;
                8'd229 : exp2_func = 7'd110;
                8'd230 : exp2_func = 7'd111;
                8'd231 : exp2_func = 7'd111;
                8'd232 : exp2_func = 7'd112;
                8'd233 : exp2_func = 7'd113;
                8'd234 : exp2_func = 7'd113;
                8'd235 : exp2_func = 7'd114;
                8'd236 : exp2_func = 7'd115;
                8'd237 : exp2_func = 7'd115;
                8'd238 : exp2_func = 7'd116;
                8'd239 : exp2_func = 7'd116;
                8'd240 : exp2_func = 7'd117;
                8'd241 : exp2_func = 7'd118;
                8'd242 : exp2_func = 7'd118;
                8'd243 : exp2_func = 7'd119;
                8'd244 : exp2_func = 7'd120;
                8'd245 : exp2_func = 7'd120;
                8'd246 : exp2_func = 7'd121;
                8'd247 : exp2_func = 7'd122;
                8'd248 : exp2_func = 7'd123;
                8'd249 : exp2_func = 7'd123;
                8'd250 : exp2_func = 7'd124;
                8'd251 : exp2_func = 7'd125;
                8'd252 : exp2_func = 7'd125;
                8'd253 : exp2_func = 7'd126;
                8'd254 : exp2_func = 7'd127;
                8'd255 : exp2_func = 7'd127;
            endcase
        end
    endfunction
endmodule
