module axi4Lite_new(
    axi4_Lite.axiMaster axiM,
    axi4_Lite.axiSlave axiS
);

    /*
    logic handshake_a_w,handshake_a_r,handshake_d_w,handshake_d_r;
    // Write - adress
    always_ff @(posedge axiS.aclk or negedge axiS.aresetn) begin
        if(axiS.awvalid)&(axiM.awready)    //handshake по адресу запись
        begin
            axiM.awaddr <= axiS.awaddr;
            axiM.awprot <= axiS.awprot;
            handshake_a_w <= 1;
        end
    end
    // Write - data
    always_ff @(posedge axiS.aclk or negedge axiS.aresetn) begin
        if(handshake_a_w)&(axiS.wvalid)&(axiM.wready) // handshake по данным запись
        begin
            axiM.wdata <= axiS.wdata;
            axiM.wstrb <= axiS.wstrb;
            handshake_d_w <= 1;
        end
    end
    // Write - response
    always_ff @(posedge axiS.aclk or negedge axiS.aresetn) begin
        if(axiS.bready)&(axiM.bvalid)
        begin
            axiS.bresp <= axiM.bresp;
            handshake_d_w <= 0;
        end
    end

    // Read adress

    always_ff @(posedge axiS.aclk or negedge axiS.aclk) begin
        if(axiS.arvalid)&
    end
    
    */
    typedef enum logic [2:0] { IDLE, SETUP_W, SETUP_R, ACCESS_W, ACCESS_R} stateType;
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
                if(axiS.awvalid)&(axiM.awready) next_state = SETUP_W;
                else if (axiS.arvalid)&(arreadyFSM) next_state = SETUP_R;
                else next_state = IDLE;
            end
            SETUP_W:begin
                if(axiS.wvalid)&(wreadyFSM) next_state = ACCESS_W;
                else next_state = SETUP_W;
            end
            ACCESS_W:begin
                if(bvalidFSM)&(axiS.bready) next_state = IDLE;
                else next_state = SETUP_W;
            end
            SETUP_R:begin
                if(rvalidFSM)&(axiS.rready) next_state = ACCESS_R;
                else next_state = SETUP_R;
            end
            ACCESS_R:begin
                if(rrespFSM) next_state = IDLE;
                else next_state = SETUP_R;
            end
        endcase
    end

    always_ff @(posedge aclk or negedge aresetn) begin
        if(!aresetn)
        else begin
            case (state)
                SETUP_W:begin
                    awaddr <= axiS.awaddr;
                    awprot <= axiS.awprot;
                end
                ACCESS_W: begin
                    wdata <= axiS.wdata;
                    wstrb <= axiS.wstrb;
                end
                SETUP_R:begin
                    araddr <= axiS.araddr;
                    arprot <= axiS.arprot;
                end
                ACCESS_R:begin
                    axiS.rdata <= rdataFSM;
                end


            endcase
        end
    end
endmodule