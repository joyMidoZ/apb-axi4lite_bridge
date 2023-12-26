module top 
#(parameter DATAWIDTH = 32, ADDRWIDTH = 32)
(
    input                 clk,
                          rst, 
    axi4_Lite.axiSlave    axiS,
    apb.masterAPB         apbM
);
// AXI
logic awreadyM,
      wreadyM,
      arreadyM,
      bvalidM,
      rvalidM;

localparam BRESP_W = 2;
logic [BRESP_W-1:0]   brespM;
logic [DATAWIDTH-1:0] rdataM;
logic [1:0] rrespM;
logic [ADDRWIDTH-1:0] awaddrM;
logic [2:0] awprotM;
logic [DATAWIDTH-1:0] wdataM;
logic [DATAWIDTH/8 - 1:0] wstrbM;
logic [ADDRWIDTH-1:0] araddrM;
logic [2:0] arprotM;

logic awvalidM,
      arvalidM,
      wvalidM,
      rreadyM;


// APB
logic [2:0] pprotM;
logic pselxM;
logic pwriteM;
logic penableM;
logic [DATAWIDTH/8 - 1:0] pstrbM;
logic [ADDRWIDTH-1:0] paddrM;
logic [DATAWIDTH-1:0] pwdataM;
logic pslverrM;
logic preadyM;
logic [DATAWIDTH-1:0] prdataM;

//fifo

logic empty_A,
      full_A, 
      empty_D, 
      full_D, 
      empty_D_read, 
      full_D_read;

logic push_A, 
      pop_A, 
      push_D,
      pop_D, 
      push_D_read, 
      pop_D_read;


// <------AXI-CONVERTER------>
axi4lite_transactor axi4lite_transactor(
.clk        (clk),
.rst        (rst),

//<------axiS------>

.axiS       (axiS),
.awreadyM   (awreadyM),
.wreadyM    (wreadyM),
.arreadyM   (arreadyM),
.bvalidM    (bvalidM),
.rvalidM    (rvalidM),
.brespM     (brespM),
.rdataM     (rdataM),
.rrespM     (rrespM),
.awaddrM    (awaddrM),
.awprotM    (awprotM),
.wdataM     (wdataM),
.wstrbM     (wstrbM),
.araddrM    (araddrM),
.arprotM    (arprotM),
.awvalidM   (awvalidM),
.arvalidM   (arvalidM),
.wvalidM    (wvalidM),
.rreadyM    (rreadyM)
);

// <-----APB----->

apbComb apbComb(.apbM(apbM),
.pprotM     (pprotM),
.pselxM     (pselxM),
.pwriteM    (pwriteM),
.penableM   (penableM),
.pstrbM     (pstrbM),
.paddrM     (paddrM),
.pwdataM    (pwdataM),
.pslverrM   (pslverrM),
.preadyM    (preadyM),
.prdataM    (prdataM)
);

// <-----converter----->

converter converter(
  .clk              (clk),
  .rst              (rst),
  .awprot           (awprotM),
  .arprot           (arprotM),
  .wstrb            (wstrbM),
  .awvalid          (awvalidM),
  .arvalid          (arvalidM),
  .wvalid           (wvalidM),
  .rready           (rreadyM),
  .awready          (awreadyM),
  .wready           (wreadyM),
  .bvalid           (bvalidM),
  .arready          (arreadyM),
  .rvalid           (rvalidM),
  .bresp            (brespM),
  .rresp            (rrespM),
  .pslverr          (pslverrM),
  .pready           (preadyM),
  .pprot            (pprotM),
  .psel             (pselxM),
  .penable          (penableM),
  .pwrite           (pwriteM),
  .pstrb            (pstrbM),
  .empty_A          (empty_A),
  .full_A           (full_A),
  .empty_D          (empty_D),
  .full_D           (full_D),
  .empty_D_read     (empty_D_read),
  .full_D_read      (full_D_read),
  .push_A           (push_A),
  .pop_A            (pop_A),
  .push_D           (push_D),
  .pop_D            (pop_D),
  .push_D_read      (push_D_read),
  .pop_D_read       (pop_D_read)
);

// <------AXI-FIFO------>

logic [ADDRWIDTH-1:0] addr;
assign addr = (awvalidM) ? awaddrM : araddrM;

fifo fifo_A (
    .clk        (clk),
    .rst        (rst),
    .push       (push_A),
    .pop        (pop_A),
    .write_data (addr),
    .read_data  (paddrM),
    .empty      (empty_A),
    .full       (full_A)
    );

// <------AXI-FIFO------>


fifo fifo_D (
    .clk        (clk),
    .rst        (rst),
    .push       (push_D),
    .pop        (pop_D),
    .write_data (wdataM),
    .read_data  (pwdataM),
    .empty      (empty_D),
    .full       (full_D)
    );


// <------APB-FIFO(READ)------>

fifo fifo_D_read(
    .clk        (clk),
    .rst        (rst),
    .push       (push_D_read),
    .pop        (pop_D_read),
    .write_data (prdataM),
    .read_data  (rdataM),
    .empty      (empty_D_read),
    .full       (full_D_read)
    );

endmodule