module  axi4lite_transactor
    import specConst::*;
    #(parameter DATAWIDTH = 32, ADDRWIDTH = 32)
(
    input clk, rst, 
    axi4_Lite.axiSlave axiS,
    input   awreadyM,
            wreadyM,
            arreadyM,
            bvalidM,
            rvalidM,
    input  [RESP_LEN-1:0] brespM,
    input  [DATAWIDTH-1:0] rdataM,
    input  [RESP_LEN-1:0] rrespM,

    output logic [ADDRWIDTH-1:0] awaddrM,
    output logic [PROT_LEN-1:0] awprotM,
    output logic [DATAWIDTH-1:0] wdataM,
    output logic [STROBE_LEN-1:0] wstrbM,
    output logic [ADDRWIDTH-1:0] araddrM,
    output logic [2:0] arprotM,
    output logic awvalidM,
                 arvalidM,
                 wvalidM,
                 rreadyM
);
    typedef enum logic [1:0] { addr, data_w, data_r, respone } regFSM;
    regFSM state,next_state;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= addr;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin
        case (state)
            addr:begin
                if(axiS.awvalid&awreadyM) next_state = data_w;
                else if (axiS.arvalid&arreadyM) next_state = data_r;
                else next_state = addr;
            end
            data_w:begin
                if(axiS.wvalid&wreadyM) next_state = respone;
                else next_state = data_w;
            end
            respone:begin
                if(axiS.bready&bvalidM) next_state = addr;
                else next_state = respone;
            end
            data_r:begin
                if(axiS.rready&rvalidM) next_state = addr;
                else next_state = data_r;
            end
            default:begin
                next_state = addr;
            end
        endcase
    end

    always_ff @(posedge clk or negedge rst) begin
        if(~rst)begin
            awaddrM <= {ADDRWIDTH{1'b0}};
            awprotM <= {3{1'b0}};
            araddrM <= {ADDRWIDTH{1'b0}};
            arprotM <= {3{1'b0}};
            wdataM  <= {DATAWIDTH{1'b0}};
            wstrbM  <= {DATAWIDTH/8{1'b0}};
            axiS.bresp <= {2{1'b0}};
            axiS.rresp <= {2{1'b0}};
            axiS.rdata <= {DATAWIDTH{1'b0}};
            arvalidM <= 0;
            awvalidM <= 0;
            wvalidM <= 0;
        end
        else begin
        awvalidM <= axiS.awvalid;
        wvalidM <= axiS.wvalid;
        arvalidM <= axiS.arvalid;
        axiS.rvalid<= rvalidM;
        rreadyM <= axiS.rready;
            case (state)
                addr: begin
                    //axiS.bvalid <= 0;
                    //axiS.rvalid <= 0;
                    if(axiS.awvalid&awreadyM) begin
                        awaddrM <= axiS.awaddr;
                        awprotM <= axiS.awprot;
                        //awvalidM <= axiS.awvalid;
                        axiS.awready <= awreadyM;
                    end
                    else if (axiS.arvalid&arreadyM) begin
                        araddrM <= axiS.araddr;
                        arprotM <= axiS.arprot;
                        axiS.arready <= arreadyM;
                        //arvalidM <= axiS.arvalid;
                    end
                end
                data_w: begin
                    //axiS.awready <= 0;
                    if(axiS.wvalid&wreadyM) begin
                        wdataM <= axiS.wdata;
                        wstrbM <= axiS.wstrb;
                        axiS.wready <= wreadyM;
                        //wvalidM <= axiS.wvalid;
                    end
                end
                respone: begin
                    //axiS.wready <= 0;
                    if(axiS.bready&bvalidM) begin
                        axiS.bresp <= brespM;
                        axiS.bvalid <= bvalidM;
                    end
                end
                data_r: begin
                    //axiS.arready <= 0;
                    if(axiS.rready&rvalidM)begin
                        axiS.rresp <= rrespM;
                        axiS.rdata <= rdataM;
                       // axiS.rvalid <= rvalidM;
                    end
                end
            endcase
        end
    end

endmodule