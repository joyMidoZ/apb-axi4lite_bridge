module apb_transactor #(parameter dataWidth = 32, addrWidth = 32)
(
    input clk, rst,
    apb.masterAPB apbM,
    input [2:0] pprot,
    input pselx,
    input penable,
    input pwrite,
    input [dataWidth/8 - 1:0] pstrb,
    input [addrWidth-1:0] paddr, 
    input [dataWidth-1:0] pwdata,

    output logic pslverr,
    output logic pready,
    output logic [dataWidth-1:0]prdata
);

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
        idle:begin
            if(pselx) next_state = setup;
            else next_state = idle;
        end
        setup:begin
            next_state = access;
        end
        access: begin
            if(apbM.pready&pselx) next_state = setup;
            else if (apbM.pready&~pselx) next_state = idle;
            else next_state = access;
        end

        endcase
    end

    always_ff @(posedge clk or negedge rst) begin
        if(~rst)begin
        end
        else begin
                case (state)
                    idle:begin
                        if(pselx)begin 
                            apbM.penable <= 0;
                            apbM.pprot <= pprot;
                            apbM.pstrb <= pstrb;
                            apbM.paddr <= paddr;
                            apbM.pwrite <= pwrite;

                            if(pwrite) begin
                                apbM.pwdata <= pwdata;
                                end

                            else begin
                                prdata <= apbM.prdata; 
                                pslverr <= apbM.pslverr;
                            end
                            
                        end
                    end
                    setup: begin
                        apbM.penable <=1;
                    end

                    access:begin
                        if(next_state==setup) apbM.penable <= 0;
                    end
                endcase
        end
    end
endmodule