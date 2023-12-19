module top #(parameter dataWidth = 32, addrWidth = 32)
(
    input clk, rst, 
    axi4_Lite.axiSlave axiS,
    apb.masterAPB apbM
);
// AXI
logic awreadyM,wreadyM,arreadyM,bvalidM,rvalidM;
logic [1:0] brespM;
logic [dataWidth-1:0] rdataM;
logic [1:0] rrespM;
logic [addrWidth-1:0] awaddrM;
logic [2:0] awprotM;
logic [dataWidth-1:0] wdataM;
logic [dataWidth/8 - 1:0] wstrbM;
logic [addrWidth-1:0] araddrM;
logic [2:0] arprotM;
logic awvalidM,arvalidM,wvalidM;


// APB
logic [2:0] pprotM;
logic pselxM;
logic pwriteM;
logic penableM;
logic [dataWidth/8 - 1:0] pstrbM;
logic [addrWidth-1:0] paddrM;
logic [dataWidth-1:0] pwdataM;
 logic pslverrM;
 logic preadyM;
 logic [dataWidth-1:0]prdataM;

//fifo
logic empty_A, full_A, empty_D, full_D, empty_D_read, full_D_read;
logic push_A, pop_A, push_D,pop_D, push_D_read, pop_D_read;


// <------AXI-CONVERTER------>
axi4lite_transactor axi4lite_transactor(.clk(clk),.rst(rst),.axiS(axiS),
.awreadyM(awreadyM),.wreadyM(wreadyM),.arreadyM(arreadyM),.bvalidM(bvalidM),
.rvalidM(rvalidM),.brespM(brespM),.rdataM(rdataM),.rrespM(rrespM),.awaddrM(awaddrM),
.awprotM(awprotM),.wdataM(wdataM),.wstrbM(wstrbM),.araddrM(araddrM),.arprotM(arprotM),
.awvalidM(awvalidM),.arvalidM(arvalidM),.wvalidM(wvalidM));

apbComb apbComb(.apbM(apbM),.pprotM(pprotM),.pselxM(pselxM),.pwriteM(pwriteM),
.penableM(penableM),.pstrbM(pstrbM),.paddrM(paddrM),.pwdataM(pwdataM),
.pslverrM(pslverrM),.preadyM(preadyM),.prdataM(prdataM));

converter converter(.clk(clk),.rst(rst),.awprot(awprotM),.arprot(arprotM),
.wstrb(wstrbM),.awvalid(awvalidM),.arvalid(arvalidM),.wvalid(wvalidM),.awready(awreadyM),
.wready(wreadyM),.bvalid(bvalidM),.arready(arreadyM),.rvalid(rvalidM),
.bresp(brespM),.rresp(rrespM),.pslverr(pslverrM),.pready(preadyM),.pprot(pprotM),
.psel(pselxM),.penable(penableM),.pwrite(pwriteM),.pstrb(pstrbM),
.empty_A(empty_A),.full_A(full_A),.empty_D(empty_D),.full_D(full_D),.empty_D_read(empty_D_read),
.full_D_read(full_D_read),.push_A(push_A),.pop_A(pop_A),.push_D(push_D),
.pop_D(pop_D),.push_D_read(push_D_read),.pop_D_read(pop_D_read));

fifo fifo_A (.clk(clk),.rst(rst),.push(push_A),.pop(pop_A),.write_data(awaddrM),
.read_data(paddrM),.empty(empty_A),.full(full_A));

fifo fifo_D (.clk(clk),.rst(rst),.push(push_D),.pop(pop_D),.write_data(wdataM),
.read_data(pwdataM),.empty(empty_D),.full(full_D));

fifo fifo_D_read(.clk(clk),.rst(rst),.push(push_D_read),.pop(pop_D_read),
.write_data(rdataM),.read_data(prdataM),.empty(empty_D_read),.full(full_D_read));


// <------AXI-FIFO------>


// <------APB-CONVERTER------>


// <------APB-FIFO(READ)------>

    
endmodule