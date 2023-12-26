module apbComb #(parameter DATAWIDTH = 32, ADDRWIDTH = 32)
(
    apb.masterAPB apbM,
    input [2:0] pprotM,
    input logic pselxM,
    input pwriteM,
    input penableM,
    input [DATAWIDTH/8 - 1:0] pstrbM,
    input [ADDRWIDTH-1:0] paddrM, 
    input [DATAWIDTH-1:0] pwdataM,

    output logic pslverrM,
    output logic preadyM,
    output logic [DATAWIDTH-1:0]prdataM
);
    
    assign apbM.pselx = pselxM;
    assign apbM.paddr = paddrM;
    assign apbM.pwdata = pwdataM;
    assign apbM.penable = penableM;
    assign apbM.pwrite = pwriteM;
    assign apbM.pstrb = pstrbM;
    assign apbM.pprot = pprotM;

    assign preadyM =  apbM.pready;
    assign pslverrM = apbM.pslverr;
    assign prdataM = (preadyM) ? apbM.prdata : prdataM;
endmodule