
module top #(parameter dataWidth = 32, parameter addrWidth = 32)
(
input clk,input rst,
//AXI4-Lite
input [addrWidth-1:0] awaddr, input [2:0] awprot, input awvalid,
input [dataWidth-1:0] wdata, input [dataWidth/4 - 1:0] wstrb, input wvalid,
input bready,
input [addrWidth-1:0] araddr, input [2:0] arprot, input arvalid,
input rready,

output awready, 
output wready,
output [1:0] bresp, 
output bvalid,
output arready,
output [dataWidth-1:0] rdata,
output [1:0] rresp,
output rvalid,

//APB
input pslverr,
input [dataWidth-1:0] prdata,
input pready,

output pwrite,
output [dataWidth/8 - 1:0]pstrb,
output [addrWidth-1:0]paddr,
output [dataWidth-1:0]pwdata
);

