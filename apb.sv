interface apb
    #(dataWidth = 32, addrWidth = 32)
    (
        input pclk, input presetn
    );
        logic [addrWidth - 1:0] paddr;
        logic [2:0] pprot;
        logic pselx;
        logic peneable;
        logic pwrite;
        logic [dataWidth - 1:0] pwdata;
        logic [dataWidth/8 - 1:0]pstrb;
        logic pready;
        logic [dataWidth - 1:0] prdata;
        logic pslverr;

        always_ff @(posedge pclk or negedge presetn) begin
            if (!presetn) begin
                
            end
            else begin
                pwdata = (peneable&pwrite)?
            end
        end

        modport slaveAPB
        (
            input pclk, presetn,
            input pwrite, pstrb, paddr, pwdata,
            output pready, prdata, pslverr
        );

        modport masterAPB
        (
            input pclk, presetn,
            input pprot, pselx,peneable,pwrite, pstrb,paddr,pwdata,
            output prdata, pready, pslverr
        );
endinterface