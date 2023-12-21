module apbComb #(parameter DATAWIDTH = 32, ADDRWIDTH = 32)
(
    apb.masterAPB apbM,
    input [2:0] pprotM,
    input pselxM,
    input pwriteM,
    input penableM,
    input [DATAWIDTH/8 - 1:0] pstrbM,
    input [ADDRWIDTH-1:0] paddrM, 
    input [DATAWIDTH-1:0] pwdataM,

    output logic pslverrM,
    output logic preadyM,
    output logic [DATAWIDTH-1:0]prdataM
);
    /*
    assign apbM.pselx = pselxM;
    assign apbM.paddr = pselxM? paddrM: apbM.paddr;
    assign apbM.pwdata = pselxM? pwdataM: apbM.pwdata;
    assign apbM.penable = (pselxM&~apbM.pready|~apbM.penable)? 0:1;
    assign apbM.pwrite = pwriteM;
    assign preadyM = (apbM.penable)? apbM.pready:preadyM;
    */
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