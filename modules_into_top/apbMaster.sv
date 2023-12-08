module apbMaster #(parameter dataWidth = 32, addrWidth = 32)
(
    input clk, rst,
    apb.masterAPB apbM,
    input [2:0] pprotM,
    input pselxM,
    input pwriteM,
    input [dataWidth/8 - 1:0] pstrbM,
    input [addrWidth-1:0] paddrM, 
    input [dataWidth-1:0] pwdataM,

    output logic pslverrM,
    output logic preadyM,
    output logic [dataWidth-1:0]prdataM
);
    logic penableM;
    // 1. psel - валидность инфы

    // write (pwrite = 1)
    // когда psel == 1 то enable = 0, на след такт psel может быть как 0 так и 1, но enable 1 всегда пока не будет сигнал от pready, если он 0 -
    // то происходит транзакция, если он 1 то будет либо ожидание транзакции(psel = 0), либо новая транзакция (psel = 1)

    // read (pwrite = 0)
    // когда psel == 1 то enable = 0, на след такт psel может быть как 0 так и 1, но enable 1 всегда пока не будет сигнал от pready, если он 0 -
    // то ждем транзакцию, если 1 то транзакция происходит, на след такт мы переходим либо в ожидание новой транзакции (psel = 0), либо 
    // в новую транзакция (psel = 1)

    typedef enum logic [1:0] { idle, setup, access } fsmStr;
    fsmStr state,next_state;
    always_ff @(posedge clk or negedge rst) begin
        if(~rst)
        begin
            state <= idle;
        end

        else begin
            state <= next_state;
        end

    end

    always_comb begin
        case (state)
            idle: begin
                if(pselxM) next_state = setup;
                else next_state = idle;
            end
            setup: begin
                next_state = access;
            end
            access: begin
                if(apbM.pready & pselxM) next_state = setup;
                else if (apbM.pready & ~pselxM) next_state = idle;
                else next_state = access;
            end
        endcase
    end
    always_comb begin
        case (state)
            idle:begin
                if(pselxM)
                begin
                    apbM.psel = pselxM;
                    apbM.paddr = paddrM;
                    apbM.pwrite = pwriteM;
                    if(pwriteM)
                    apbM.pwdata = pwdataM;
                    
                    apbM.penable = 0;
                end
            end
            setup:begin
                apbM.penable = 1;
                 /*apbM.psel = pselxM;
                    apbM.paddr = paddrM;
                    apbM.pwrite = pwriteM;
                    if(pwriteM)
                    apbM.pwdata = pwdataM;
                    
                    apbM.penable = 0;
                    */
                
            end
            access:begin
                if(preadyM) apbM.penable = 0;
                
                if(~pwriteM)
                begin
                    prdataM = apbM.prdata;
                    preadyM = apbM.pready;
                    pslverrM = apbM.pslverr;
                end
            end
        endcase
    end
endmodule