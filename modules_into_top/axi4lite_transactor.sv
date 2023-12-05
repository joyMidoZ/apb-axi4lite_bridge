module  axi4lite_transactor #(parameter dataWidth = 32, addrWidth = 32)
(
    input clk, rst, 
    axi4_Lite.axiSlave axiS,
    input awreadyM,wreadyM,arreadyM,bvalidM,rvalidM,
    input [1:0] brespM,
    input [dataWidth-1:0] rdataM,
    input [1:0] rrespM,

    output logic [addrWidth-1:0] awaddrM,
    output logic [2:0] awprotM,
    output logic [dataWidth-1:0] wdataM,
    output logic [dataWidth/8 - 1:0] wstrbM,
    output logic [addrWidth-1:0] araddrM,
    output logic [2:0] arprotM
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
        endcase
    end

    always_ff @(posedge clk or negedge rst) begin
        if(~rst)begin
            awaddrM <= {addrWidth{1'bx}};
            awprotM <= {3{1'bx}};
            araddrM <= {addrWidth{1'bx}};
            arprotM <= {3{1'bx}};
            wdataM  <= {dataWidth{1'bx}};
            wstrbM  <= {dataWidth/8{1'bx}};
            axiS.bresp <= {2{1'bx}};
            axiS.rresp <= {2{1'bx}};
            axiS.rdata <= {dataWidth{1'bx}};
        end
        else begin
            case (state)
                addr: begin
                    if(axiS.awvalid&awreadyM) begin
                        awaddrM <= axiS.awaddr;
                        awprotM <= axiS.awprot;
                    end
                    else if (axiS.arvalid&arreadyM) begin
                        araddrM <= axiS.araddr;
                        arprotM <= axiS.arprot;
                    end
                end
                data_w: begin
                    if(axiS.wvalid&wreadyM) begin
                        wdataM <= axiS.wdata;
                        wstrbM <= axiS.wstrb;
                    end
                end
                respone: begin
                    if(axiS.bready&bvalidM) begin
                        axiS.bresp <= brespM;
                    end
                end
                data_r: begin
                    if(axiS.rready&rvalidM)begin
                        axiS.rresp <= rrespM;
                        axiS.rdata <= rdataM;
                    end
                end
            endcase
        end
    end

    assign  axiS.awready = awreadyM;
    assign  axiS.wready = wreadyM;
    assign  axiS.bvalid = bvalidM;
    assign  axiS.arready = arreadyM;
    assign  axiS.rvalid = rvalidM;
endmodule