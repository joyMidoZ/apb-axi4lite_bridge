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

    /////////

    // <-------MASTER SIGNALS-------> //
    logic [addrWidth-1:0] awaddrM; //out
    logic [2:0] awprotM; //out
    logic awvalidM;  //out
    logic awreadyM;  //in

    logic [dataWidth-1:0] wdataM;    //out
    logic [dataWidth/8 - 1:0] wstrbM;    //out
    logic wvalidM;   //out
    logic wreadyM;   //in

    logic [1:0] brespM;  //in
    logic bvalidM;   //in
    logic breadyM;   //out

    logic [addrWidth-1:0] araddrM;   //out
    logic [2:0]arprotM;  //out
    logic arvalidM;  //out
    logic arreadyM;  //in

    logic [dataWidth-1:0] rdataM;    //im
    logic [1:0] rrespM;  //in
    logic rvalidM;   //in
    logic rreadyM;   //out

    
    modport axiSlave
    (
        input aclk, aresetn,
        input awaddr, awprot, awvalid, wdata, wstrb, wvalid, bready, araddr, arprot, arvalid, rready,
        output awready, wready, bresp, bvalid, arready, rdata, rresp, rvalid
    );
    
    modport axiMaster
    (
        input aclk, aresetn,
        input awreadyM, wreadyM, brespM, bvalidM, arreadyM, rdataM, rrespM, rvalidM, 
        output awaddrM, awprotM, awvalidM, wdataM, wstrbM, wvalidM, breadyM, araddrM, arprotM, arvalidM, rreadyM
    );
endinterface
