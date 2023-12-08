module apbMaster #(parameter dataWidth = 32, addrWidth = 32)
(
    input clk, rst,
    apb.masterAPB apbM,
    input [2:0] pprotM,
    input pselxM,
    input pwriteM,
    input [dataWidth/8 - 1:0] pstrbM,
    input [addrWidth-1:0] paddrM, 
    input [dataWidth-1:0] pwdataM,

    output logic pslverrM,
    output logic preadyM,
    output logic [dataWidth-1:0]prdataM
);
    logic penableM;
    // 1. psel = 1
endmodule