package specConst;
    localparam DATAWIDTH = 32;
    localparam ADDRWIDTH = 32;

    //parameter DATAWIDTH = 32;
    //parameter ADDRWIDTH = 32;
    parameter STROBE_LEN = DATAWIDTH / 8; 
    parameter PROT_LEN = 3;
    parameter RESP_LEN = 2;
endpackage