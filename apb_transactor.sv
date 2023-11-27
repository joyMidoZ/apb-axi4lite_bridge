module apb_transactor #(parameter dataWidth = 32, addrWidth = 32)(
    input clk, rst,
    apb.masterAPB = apbM,

    input [2:0] pprot,
    input pselx,
    input penable,
    input pwrite,
    input [dataWidth/8 - 1:0] pstrb,
    input [addrWidth-1:0] paddr, 
    input [dataWidth-1:0] pwdata,

    output pslverr,
    output pready,
    output [dataWidth-1:0]pradata
);

    typedef enum logic [1:0] { idle, setup, access } FSMstr;
    FSMstr = state,next_state;

endmodule