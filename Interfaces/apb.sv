interface apb
    #(DATAWIDTH = 32, ADDRWIDTH = 32)
    (
        input pclk, input presetn
    );
        logic [ADDRWIDTH - 1:0] paddr;
        logic [2:0] pprot;
        logic pselx;
        logic penable;
        logic pwrite;
        logic [DATAWIDTH - 1:0] pwdata;
        logic [DATAWIDTH/8 - 1:0]pstrb;
        logic pready;
        logic [DATAWIDTH - 1:0] prdata;
        logic pslverr;
        
        

        modport slaveAPB
        (
            input pclk, presetn,
            input pselx,penable,pprot,paddr,pwrite,pwdata,pstrb,
            output pready, prdata, pslverr
        );

        modport masterAPB
        (
            input pclk, presetn,
            input prdata, pready, pslverr,
            output pselx,penable,pprot,paddr,pwrite,pwdata,pstrb
        );
endinterface