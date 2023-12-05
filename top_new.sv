module top #(parameter dataWidth = 32, addrWidth = 32)(
    input clk,
    input resetn,
    axi4_Lite.axiSlave axiS_Top,
    apb.masterAPB apbM_Top
);
    //<------- Сигналы для AXI4Lite_Transactor -------->
    logic awreadyM,wreadyM,arreadyM,bvalidM,rvalidM;
    logic[1:0] brespM;
    logic[dataWidth-1:0] rdataM;
    logic[1:0] rrespM;
    logic [addrWidth-1:0] awaddrM;
    logic [2:0] awprotM;
    logic [dataWidth-1:0] wdataM;
    logic [dataWidth/8 - 1:0] wstrbM;
    logic [addrWidth-1:0] araddrM;
    logic [2:0] arprotM;
    //<------------------------------------------------>

    //<------- Сигналы для APB_Transactor -------->
    logic [2:0] pprot;
    logic pselx;
    logic penable;
    logic pwrite;
    logic [dataWidth/8 - 1:0] pstrb;
    logic [addrWidth-1:0] paddr;
    logic [dataWidth-1:0] pwdata;
    logic pslverr;
    logic pready;
    logic [dataWidth-1:0]pradata;
    //<------------------------------------------->

    converter converter(clk, resetn, axiS_Top.axiSlave,apbM_Top.masterAPB);

    axi4lite_transactor axi4lite_transactor(clk,resetn,axiS_Top.axiSlave,
    awreadyM,wreadyM,arreadyM,bvalidM,rvalidM,brespM,rdataM,rrespM,
    awaddrM,awprotM,wdataM,wstrbM,araddrM,arprotM);

    apb_transactor apb_transactor(clk,resetn,apbM_Top.masterAPB, pprot, pselx, penable, pwrite, pstrb, paddr,
    pwdata, pslverr, pready, pradata);
endmodule