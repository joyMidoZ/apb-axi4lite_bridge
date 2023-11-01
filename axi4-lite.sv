interface axi4_Lite
    #(parameter dataWidth = 32, addrWidth = 32)
    (
        input aclk, input aresetn
    );

    logic [addrWidth-1:0] awaddr;
    logic [2:0] awprot;
    logic awvalid;
    logic awready;

    logic [dataWidth-1:0] wdata;
    logic [dataWidth/8 - 1:0] wstrb;
    logic wvalid;
    logic wready;

    logic [1:0] bresp;
    logic bvalid;
    logic bready;

    logic [addrWidth-1:0] araddr;
    logic [2:0]arprot;
    logic arvalid;
    logic arready;

    logic [dataWidth-1:0] rdata;
    logic [1:0] rresp;
    logic rvalid;
    logic rready;
    
    modport axiSlave
    (
        input aclk, aresetn,
        input awaddr, awprot, awvalid, wdata, wstrb, wvalid, bready, araddr, arprot, arvalid, rready,
        output awready, wready, bresp, bvalid, arready, rdata, rresp, rvalid
    );
    
    modport axiMaster
    (
        input aclk, aresetn,
        input awready, wready, bresp, bvalid, arready, rdata, rresp, rvalid, 
        output awaddr, awprot, awvalid, wdata, wstrb, wvalid, bready, araddr, arprot, arvalid, rready
    );
endinterface