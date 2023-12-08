module apb_transactor #(parameter dataWidth = 32, addrWidth = 32)
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
    typedef enum logic [1:0] { idle, setup, access } FSMstr;
    FSMstr state,next_state;
    always_ff @(posedge clk or negedge rst) begin
        if (~rst) begin
            state <= idle;
        end
        else begin
            state <= next_state;
        end
    end
    
    always_comb begin
        case (state)

        idle: begin
            next_state = state;
        end

        setup:begin
            if(pselx) next_state = access;
            else next_state = idle;
        end
        access:begin
            if(apbM.pready&pselx) next_state = setup;
            else if(apbM.pready&~pselx) next_state = idle;
            else next_state = access;
        end
        
        endcase
    end

    always_ff @(posedge clk or negedge rst) begin
        if(~rst)begin
        end
        else begin
                apbM.penable <= 0;
                apbM.pselx <= pselx;
            case (state)
                setup:begin
                    if(pselx) begin
                        if(pwrite) begin
                        apbM.penable <= 1;
                        apbM.pprot <= pprot;
                        
                        apbM.pstrb <= pstrb;
                        apbM.paddr <= paddr;
                        apbM.pwdata <= pwdata;
                        apbM.pwrite <= pwrite;
                        end
                        else begin
                            apbM.penable <= 1;
                            apbM.pprot <= pprot;
                            apbM.pstrb <= pstrb;
                            apbM.paddr <= paddr;
                            apbM.pwrite <= pwrite;
                            if(pready) begin 
                                prdata <= apbM.prdata; 
                                pslverr <= apbM.pslverr;
                            end
                        end
                    end
                end

            endcase
        end
    end
endmodule