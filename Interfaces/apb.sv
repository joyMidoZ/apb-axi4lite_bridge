interface apb
    #(dataWidth = 32, addrWidth = 32)
    (
        input pclk, input presetn
    );
        logic [addrWidth - 1:0] paddr;
        logic [2:0] pprot;
        logic pselx;
        logic penable;
        logic pwrite;
        logic [dataWidth - 1:0] pwdata;
        logic [dataWidth/8 - 1:0]pstrb;
        logic pready;
        logic [dataWidth - 1:0] prdata;
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