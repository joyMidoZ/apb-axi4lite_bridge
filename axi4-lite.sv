interface axi4_Lite
    #(parameter dataWidth = 32, addrWidth = 32)
    (
        input aclk, input aresetn
    );

    logic [addrWidth-1:0] awaddr; //in
    logic [2:0] awprot; //in
    logic awvalid;  //in
    logic awready;  //out

    logic [dataWidth-1:0] wdata;    //in
    logic [dataWidth/8 - 1:0] wstrb;    //in
    logic wvalid;   //in
    logic wready;   //out

    logic [1:0] bresp;  //out
    logic bvalid;   //out
    logic bready;   //in

    logic [addrWidth-1:0] araddr;   //in
    logic [2:0]arprot;  //in
    logic arvalid;  //in
    logic arready;  //out

    logic [dataWidth-1:0] rdata;    //out
    logic [1:0] rresp;  //out
    logic rvalid;   //out
    logic rready;   //in
    
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
