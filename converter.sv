module converter(
    axi4_Lite.axiSlave axiS,
    apb.masterAPB apbM
);


//inputs с axiS - с тестбенча
//inputs c apbM - с тестбенча
// 
//
//
// axiS --> apbM
//logic {awreadyC,wreadyC,arreadyC} = {1,1,1};
typedef enum logic [2:0] { IDLE, SETUP_W, SETUP_R, ACCESS_W, ACCESS_R,
 RESPONCE_WRITE, RESPONCE_READ} stateType;
    stateType state,next_state;
    always_ff @(posedge axiS.aclk or negedge axiS.aresetn) begin
        if (!axiS.aresetn) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end


    always_comb begin
        case (state)
            IDLE:begin
                if(axiS.awvalid) next_state = SETUP_W;
                else if (axiS.arvalid) next_state = SETUP_R;
                else next_state = IDLE;
            end
            SETUP_W:begin
                if(axiS.wvalid) next_state = ACCESS_W;
                else next_state = SETUP_W;
            end
            ACCESS_W:begin
                if(apbM.pready)&(axiS.bready) next_state = RESPONCE_WRITE;
                else next_state = SETUP_W;
            end
            SETUP_R:begin
                if (axiS.rready) next_state = ACCESS_R;
                else next_state = SETUP_R;
            end
            ACCESS_R:begin
                if(apbM.pready) next_state = IDLE;
                else next_state = SETUP_R;
            end
            RESPONCE_WRITE:begin
                if(apbM.pslverr)next_state = IDLE;     //если ошибки транзакции нет, то переход в IDLE       //что будет если pslverr = 0?
            end
            RESPONCE_READ:begin
                if(apbM.pslverr)next_state = IDLE;
            end
        endcase
    end

    always_ff @(posedge axisS.aclk or negedge axisS.aresetn) begin
        if(axiS.aresetn)
        begin
            case (state)
                IDLE:begin 
                    apbM.pselx <= 0;

                    axiS.awready <= 1;
                    axiS.wready <= 1;
                    axiS.arready <= 1;
                    axiS.rvalid <= 1;
                    
                end
                SETUP_W:begin
                    apbM.paddr <= axiS.awaddr;
                    apbM.pprot <= axiS.awprot;
                    apbM.pwrite <= 1;
                    apbM.pselx <= 1;
                    apbM.penable <= 0;

                end

                ACCESS_W:begin
                    apbM.pwdata <= axiS.wdata;
                    apbM.pstrb <= axiS.wstrb;
                    apbM.penable <= 1;
                    apbM.pwrite <= 1;

                end
                SETUP_R: begin
                    apbM.paddr <= axiS.araddr;
                    apbM.pprot <= axiS.arprot;
                    apbM.pwrite <= 0;
                    apbM.pselx <= 1;
                    apbM.penable <= 0;

                end
                ACCESS_R:begin
                    apbM.pwrite <= 0;
                    axiS.rdata <= apbM.prdata;
                    apbM.penable <= 1;
                    
                end

                RESPONCE_WRITE:begin
                    axiS.bresp <= 2'b00;
                end
                RESPONCE_READ:begin
                    axiS.rresp <= 2'b00;
                end
            endcase
        end
        
    end
   
    
endmodule