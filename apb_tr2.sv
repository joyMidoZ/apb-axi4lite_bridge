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
    always_ff @(posedge clk) begin
    
    
                    apbM.pselx <= pselxM;
                    apbM.paddr <= paddrM;
                    apbM.pwrite <= pwriteM;
                    apbM.pprot <= pprotM;
                    if(pwriteM) begin
                    apbM.pstrb <= pstrbM;
                    apbM.pwdata <= pwdataM;
                    end
                    
        case (state)
        
        
            idle:begin
                if(pselxM)
                begin
                   
                    apbM.penable <= 0;
                end
            end
            setup:begin
                apbM.penable <= ~apbM.penable;
                 

            end
            access:begin
                if(apbM.pready) apbM.penable <= ~apbM.penable;
      
                if(~pwriteM)
                begin
                    prdataM <= apbM.prdata;
                    apbM.pready <= preadyM;
                    pslverrM <= apbM.pslverr;
                end
            end
        endcase
    end
endmodule