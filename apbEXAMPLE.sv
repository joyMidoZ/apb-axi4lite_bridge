interface apb_if
#(
    AW = 0,
    DW = 0,
    REG = 0,
    AR = 1,
    AM = 0
)
(
    input  wire         PCLK,
                        PRESETn/*, causing INSTARR-HC-NYS error in vcs

    input  logic [AW  -1:0]
                        cfg_BASE_ADDR,
    integer             cfg_SIZE*/
);
//just a vcs workaround
    logic [AW  -1:0]        cfg_BASE_ADDR,
    /*integer*/             cfg_SIZE;

    logic [AW - 1:0]    PADDR,  PADDR_r,    PADDR_sp;
    logic [AW - 1:0]    addr_offset;
    logic               PWRITE, PWRITE_r;
    logic               PREADY, PREADY_r;
    logic [DW - 1:0]    PWDATA, PWDATA_r;
    logic [DW - 1:0]    PRDATA, PRDATA_r;
    logic               PSEL,   PSEL_r;
    logic               PENABLE,PENABLE_r;
    logic               PSLVERR,PSLVERR_r;
    logic [2:0]         PPROT,  PPROT_r;
    logic [DW/8 - 1:0]  PSTRB,  PSTRB_r;

function automatic [AW - 1:0] offset;
    begin
        offset = 0;
        for(int i=0;(i<AW) && ~cfg_BASE_ADDR[i];i++)
            offset[i] = PADDR[i];
    end
endfunction

generate
if(REG)begin:gen_reg
    always_ff @(posedge PCLK)begin
        PADDR_r     <= PADDR;
        PWRITE_r    <= PWRITE;
        PREADY_r    <= PREADY & PSEL_r & PENABLE_r;
        PWDATA_r    <= PWDATA;
        PRDATA_r    <= PRDATA;
        PSLVERR_r   <= PSLVERR;
        PPROT_r     <= PPROT;
        PSTRB_r     <= PSTRB;
        addr_offset <= offset();
    end
    if(AR)begin:gen_async_rst
    always_ff @(posedge PCLK or negedge PRESETn)
        if(~PRESETn)begin
            PSEL_r      <= 0;
            PENABLE_r   <= 0;
        end
        else begin
            PSEL_r      <= PSEL & ~(PREADY & PSEL_r & PENABLE_r | PREADY_r);
            PENABLE_r   <= PENABLE & ~(PREADY & PSEL_r & PENABLE_r | PREADY_r);
        end
    end
    else begin:gen_sync_rst
    always_ff @(posedge PCLK)begin
            PSEL_r      <= PSEL & ~(PREADY & PSEL_r & PENABLE_r | PREADY_r) & PRESETn;
            PENABLE_r   <= PENABLE & ~(PREADY & PSEL_r & PENABLE_r | PREADY_r) & PRESETn;
        end
    end
end
else begin:gen_comb
    always_comb begin
        PADDR_r     = PADDR;
        PWRITE_r    = PWRITE;
        PREADY_r    = PREADY;
        PWDATA_r    = PWDATA;
        PRDATA_r    = PRDATA;
        PSEL_r      = PSEL;
        PENABLE_r   = PENABLE;
        PSLVERR_r   = PSLVERR;
        PPROT_r     = PPROT;
        PSTRB_r     = PSTRB;
        addr_offset = offset();
    end
end
endgenerate

always_comb
    PADDR_sp = AM ? addr_offset : PADDR_r;
//wire [AW - 1:0]   PADDR_sp = AM ? addr_offset : PADDR_r;  //sometimes vivado creates multiple driver because of this expression

modport sp
(
    input               cfg_BASE_ADDR,
                        cfg_SIZE,
                        PCLK,
                        PRESETn,

    input               .PADDR(PADDR_sp),
                        .PWRITE(PWRITE_r),
                        .PWDATA(PWDATA_r),
                        .PSEL(PSEL_r),
                        .PENABLE(PENABLE_r),
                        .PPROT(PPROT_r),
                        .PSTRB(PSTRB_r),
    output              .PREADY(PREADY),
                        .PRDATA(PRDATA),
                        .PSLVERR(PSLVERR)
);
modport mp
(
    input               cfg_BASE_ADDR,
                        cfg_SIZE,
                        PCLK,
                        PRESETn,

    output              .PADDR(PADDR),
                        .PWRITE(PWRITE),
                        .PWDATA(PWDATA),
                        .PSEL(PSEL),
                        .PENABLE(PENABLE),
                        .PPROT(PPROT),
                        .PSTRB(PSTRB),
    input               .PREADY(PREADY_r),
                        .PRDATA(PRDATA_r),
                        .PSLVERR(PSLVERR_r)
);

endinterface:apb_if
