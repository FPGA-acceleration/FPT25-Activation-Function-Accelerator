module interconnect (
    input aclk,
    input aresetn,

    input wire s_axi_ctrl_aclk,
    input wire s_axi_ctrl_aresetn,
    input wire s_axi_ctrl_awvalid,
    output wire s_axi_ctrl_awready,
    input wire [6 : 0] s_axi_ctrl_awaddr,
    input wire s_axi_ctrl_wvalid,
    output wire s_axi_ctrl_wready,
    input wire [31 : 0] s_axi_ctrl_wdata,
    output wire s_axi_ctrl_bvalid,
    input wire s_axi_ctrl_bready,
    output wire [1 : 0] s_axi_ctrl_bresp,
    input wire s_axi_ctrl_arvalid,
    output wire s_axi_ctrl_arready,
    input wire [6 : 0] s_axi_ctrl_araddr,
    output wire s_axi_ctrl_rvalid,
    input wire s_axi_ctrl_rready,
    output wire [31 : 0] s_axi_ctrl_rdata,
    output wire [1 : 0] s_axi_ctrl_rresp,

    // ----- Individual S interfaces (external connections in BD) -----
    // S0 .. S13 : each is an AXIS slave interface (source -> switch)
    input  wire [511:0] s_axis_00_tdata, input  wire s_axis_00_tvalid, output wire s_axis_00_tready,
    input  wire [511:0] s_axis_01_tdata, input  wire s_axis_01_tvalid, output wire s_axis_01_tready,
    input  wire [511:0] s_axis_02_tdata, input  wire s_axis_02_tvalid, output wire s_axis_02_tready,
    input  wire [511:0] s_axis_03_tdata, input  wire s_axis_03_tvalid, output wire s_axis_03_tready,
    input  wire [511:0] s_axis_04_tdata, input  wire s_axis_04_tvalid, output wire s_axis_04_tready,
    input  wire [511:0] s_axis_05_tdata, input  wire s_axis_05_tvalid, output wire s_axis_05_tready,
    input  wire [511:0] s_axis_06_tdata, input  wire s_axis_06_tvalid, output wire s_axis_06_tready,
    input  wire [511:0] s_axis_07_tdata, input  wire s_axis_07_tvalid, output wire s_axis_07_tready,
    input  wire [511:0] s_axis_08_tdata, input  wire s_axis_08_tvalid, output wire s_axis_08_tready,
    input  wire [511:0] s_axis_09_tdata, input  wire s_axis_09_tvalid, output wire s_axis_09_tready,
    input  wire [511:0] s_axis_10_tdata, input  wire s_axis_10_tvalid, output wire s_axis_10_tready,
    input  wire [511:0] s_axis_11_tdata, input  wire s_axis_11_tvalid, output wire s_axis_11_tready,
    input  wire [511:0] s_axis_12_tdata, input  wire s_axis_12_tvalid, output wire s_axis_12_tready,
    input  wire [511:0] s_axis_13_tdata, input  wire s_axis_13_tvalid, output wire s_axis_13_tready,

    // ----- Individual M interfaces (external connections in BD) -----
    // M0 .. M12 : each is an AXIS master interface (switch -> sink)
    output wire [511:0] m_axis_00_tdata, output wire m_axis_00_tvalid, input  wire m_axis_00_tready,
    output wire [511:0] m_axis_01_tdata, output wire m_axis_01_tvalid, input  wire m_axis_01_tready,
    output wire [511:0] m_axis_02_tdata, output wire m_axis_02_tvalid, input  wire m_axis_02_tready,
    output wire [511:0] m_axis_03_tdata, output wire m_axis_03_tvalid, input  wire m_axis_03_tready,
    output wire [511:0] m_axis_04_tdata, output wire m_axis_04_tvalid, input  wire m_axis_04_tready,
    output wire [511:0] m_axis_05_tdata, output wire m_axis_05_tvalid, input  wire m_axis_05_tready,
    output wire [511:0] m_axis_06_tdata, output wire m_axis_06_tvalid, input  wire m_axis_06_tready,
    output wire [511:0] m_axis_07_tdata, output wire m_axis_07_tvalid, input  wire m_axis_07_tready,
    output wire [511:0] m_axis_08_tdata, output wire m_axis_08_tvalid, input  wire m_axis_08_tready,
    output wire [511:0] m_axis_09_tdata, output wire m_axis_09_tvalid, input  wire m_axis_09_tready,
    output wire [511:0] m_axis_10_tdata, output wire m_axis_10_tvalid, input  wire m_axis_10_tready,
    output wire [511:0] m_axis_11_tdata, output wire m_axis_11_tvalid, input  wire m_axis_11_tready,
    output wire [511:0] m_axis_12_tdata, output wire m_axis_12_tvalid, input  wire m_axis_12_tready
);


wire [512*14-1:0] s_tdata_concat;
wire [14-1:0]     s_tvalid_concat;
wire [14-1:0]     s_tready_concat;

wire [512*13-1:0] m_tdata_concat;
wire [13-1:0]     m_tvalid_concat;
wire [13-1:0]     m_tready_concat;

assign s_tdata_concat = {
    s_axis_13_tdata, s_axis_12_tdata, s_axis_11_tdata, s_axis_10_tdata,
    s_axis_09_tdata, s_axis_08_tdata, s_axis_07_tdata, s_axis_06_tdata,
    s_axis_05_tdata, s_axis_04_tdata, s_axis_03_tdata, s_axis_02_tdata,
    s_axis_01_tdata, s_axis_00_tdata
};

assign s_tvalid_concat = {
    s_axis_13_tvalid, s_axis_12_tvalid, s_axis_11_tvalid, s_axis_10_tvalid,
    s_axis_09_tvalid, s_axis_08_tvalid, s_axis_07_tvalid, s_axis_06_tvalid,
    s_axis_05_tvalid, s_axis_04_tvalid, s_axis_03_tvalid, s_axis_02_tvalid,
    s_axis_01_tvalid, s_axis_00_tvalid
};

assign { s_axis_13_tready, s_axis_12_tready, s_axis_11_tready, s_axis_10_tready,
         s_axis_09_tready, s_axis_08_tready, s_axis_07_tready, s_axis_06_tready,
         s_axis_05_tready, s_axis_04_tready, s_axis_03_tready, s_axis_02_tready,
         s_axis_01_tready, s_axis_00_tready } = s_tready_concat;



assign { m_axis_12_tdata, m_axis_11_tdata, m_axis_10_tdata,
         m_axis_09_tdata, m_axis_08_tdata, m_axis_07_tdata, m_axis_06_tdata,
         m_axis_05_tdata, m_axis_04_tdata, m_axis_03_tdata, m_axis_02_tdata,
         m_axis_01_tdata, m_axis_00_tdata } = m_tdata_concat;

assign { m_axis_12_tvalid, m_axis_11_tvalid, m_axis_10_tvalid,
         m_axis_09_tvalid, m_axis_08_tvalid, m_axis_07_tvalid, m_axis_06_tvalid,
         m_axis_05_tvalid, m_axis_04_tvalid, m_axis_03_tvalid, m_axis_02_tvalid,
         m_axis_01_tvalid, m_axis_00_tvalid } = m_tvalid_concat;

assign m_tready_concat = {
    m_axis_12_tready, m_axis_11_tready, m_axis_10_tready,
    m_axis_09_tready, m_axis_08_tready, m_axis_07_tready, m_axis_06_tready,
    m_axis_05_tready, m_axis_04_tready, m_axis_03_tready, m_axis_02_tready,
    m_axis_01_tready, m_axis_00_tready
};


axis_switch axis_switch_u (
  .aclk(aclk),                              // input wire aclk
  .aresetn(aresetn),                        // input wire aresetn

  .s_axis_tvalid(s_tvalid_concat),            // input wire [13 : 0] s_axis_tvalid
  .s_axis_tready(s_tready_concat),            // output wire [13 : 0] s_axis_tready
  .s_axis_tdata(s_tdata_concat),              // input wire [7167 : 0] s_axis_tdata
  .m_axis_tvalid(m_tvalid_concat),            // output wire [12 : 0] m_axis_tvalid
  .m_axis_tready(m_tready_concat),            // input wire [12 : 0] m_axis_tready
  .m_axis_tdata(m_tdata_concat),              // output wire [6655 : 0] m_axis_tdata

  .s_axi_ctrl_aclk(s_axi_ctrl_aclk),        // input wire s_axi_ctrl_aclk
  .s_axi_ctrl_aresetn(s_axi_ctrl_aresetn),  // input wire s_axi_ctrl_aresetn
  .s_axi_ctrl_awvalid(s_axi_ctrl_awvalid),  // input wire s_axi_ctrl_awvalid
  .s_axi_ctrl_awready(s_axi_ctrl_awready),  // output wire s_axi_ctrl_awready
  .s_axi_ctrl_awaddr(s_axi_ctrl_awaddr),    // input wire [6 : 0] s_axi_ctrl_awaddr
  .s_axi_ctrl_wvalid(s_axi_ctrl_wvalid),    // input wire s_axi_ctrl_wvalid
  .s_axi_ctrl_wready(s_axi_ctrl_wready),    // output wire s_axi_ctrl_wready
  .s_axi_ctrl_wdata(s_axi_ctrl_wdata),      // input wire [31 : 0] s_axi_ctrl_wdata
  .s_axi_ctrl_bvalid(s_axi_ctrl_bvalid),    // output wire s_axi_ctrl_bvalid
  .s_axi_ctrl_bready(s_axi_ctrl_bready),    // input wire s_axi_ctrl_bready
  .s_axi_ctrl_bresp(s_axi_ctrl_bresp),      // output wire [1 : 0] s_axi_ctrl_bresp
  .s_axi_ctrl_arvalid(s_axi_ctrl_arvalid),  // input wire s_axi_ctrl_arvalid
  .s_axi_ctrl_arready(s_axi_ctrl_arready),  // output wire s_axi_ctrl_arready
  .s_axi_ctrl_araddr(s_axi_ctrl_araddr),    // input wire [6 : 0] s_axi_ctrl_araddr
  .s_axi_ctrl_rvalid(s_axi_ctrl_rvalid),    // output wire s_axi_ctrl_rvalid
  .s_axi_ctrl_rready(s_axi_ctrl_rready),    // input wire s_axi_ctrl_rready
  .s_axi_ctrl_rdata(s_axi_ctrl_rdata),      // output wire [31 : 0] s_axi_ctrl_rdata
  .s_axi_ctrl_rresp(s_axi_ctrl_rresp)      // output wire [1 : 0] s_axi_ctrl_rresp
);


endmodule
