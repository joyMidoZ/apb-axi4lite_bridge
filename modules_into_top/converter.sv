module converter 
  import specConst::*;
#(parameter DATAWIDTH = 32, ADDRWIDTH = 32)
(
    input clk, rst,

    //FROM axi
    input [PROT_LEN-1:0] awprot, 
                arprot,
    input [STROBE_LEN-1:0] wstrb,
    input awvalid,
          arvalid,
          wvalid,
          rready,
    //TO axi
    output logic awready,
                 wready,
                 bvalid,
                 arready,
                 rvalid,
    output logic [RESP_LEN-1:0] bresp, 
                                rresp,

    //FROM apb
    input pslverr, 
          pready,

    //TO apb
    output logic [PROT_LEN-1:0] pprot,
    output logic psel, 
                 penable,
                 pwrite,  
    output logic [STROBE_LEN - 1:0] pstrb,

    //FORM fifo
    input empty_A, 
          full_A,
          empty_D, 
          full_D, 
          empty_D_read, 
          full_D_read,

    //TO fifo
    output      logic  push_A, 
                logic  pop_A, 
                logic  push_D,
                logic  pop_D, 
                logic  push_D_read, 
                logic  pop_D_read

);
    

    assign awready = (~full_A)?1:0;
    assign arready = (~full_A)?1:0;
    assign wready = (~full_A&~full_D)? 1:0;
    assign bvalid = (pready)?1:0;
    
    assign bresp = (psel&penable&pslverr)?2'b10:2'b00;
    
    assign push_A = (~full_A&(awvalid|arvalid))?1:0;
    //assign pop_A = ((empty_A&wvalid&write)|(empty_A&~write&arvalid)) ? 1 : 0;
    //assign pop_D = (empty_D&wvalid) ? 1 : 0;
    assign push_D = (~full_D&wvalid) ? 1 : 0;
    //assign push_D_read = (~write&pready&~full_D_read) ? 1 : 0;
    assign pop_D_read = (empty_D_read&rvalid&rready) ? 1 : 0;

    logic selWait,preadyREG,write;
    always_ff@(posedge clk or negedge rst)
    begin
        //pop_A <= 0;
        //pop_D <= 0;
        preadyREG <= pready;
        if(awvalid) write <= 1;
        else if(arvalid) write <= 0;
        else write <= write;
        if(pready) selWait <= 1;
        else selWait <= 0;
    end
/*
    always_ff@(posedge clk or negedge rst)
    begin
        if(pready) psel <= 0;
        else 
        begin
            if(write)
                begin
                    if(wvalid)
                        begin
                            psel <= 1;
                            //pop_A <= 1;
                            //pop_D <= 1;
                            pwrite <= 1; 
                        end
                    else
                        begin
                            psel <= psel;
                            //pop_A <= pop_A;
                            //pop_D <= pop_D;
                            pwrite <= pwrite;
                        end
                end
            else
                begin
                    if(pready&~full_D_read)
                        begin
                            rvalid <= 1;
                            psel <=0;
                            if(~pslverr) begin 
                                //push_D_read <= 1; 
                                rresp <= 2'b00;
                            end
                            else begin 
                                //push_D_read <= 0;
                                rresp <= 2'b10;
                            end
                        end
                    else begin 
                        rvalid <= 0;
                        psel <= 1;
                        //pop_A <= 1;
                        pwrite <= 0;
                    end
                    
                        
                    
                end
        end
    end
    */
    
    always_comb begin 
        pop_A = 0;
        pop_D = 0;
        rresp = 2'b00;
        //psel = 0;
        if(selWait)begin
            psel = 0;
        end

        else
            begin
                if(write)
                    begin
                        if(wvalid)
                            begin
                                psel = 1;
                                pop_A = 1;
                                pop_D = 1;
                                pwrite = 1;
                            end

                        else 
                            begin
                                psel = psel;
                                pop_A = pop_A;
                                pop_D = pop_D;
                                pwrite = pwrite;
                            end
                    end
                
                else
                    begin
                        psel = 1;
                        pop_A = 1;
                        pwrite = 0;
                        if(pready&~full_D_read)begin
                            rvalid = 1;
                            psel = 0;
                            pop_A = 0;
                            if(~pslverr) begin 
                                push_D_read = 1; 
                                rresp = 2'b00;
                            end
                            else begin 
                                push_D_read = 0;
                                rresp = 2'b10;
                            end
                        end
                        else begin 
                            rvalid = 0;
                            push_D_read = push_D_read;
                            rresp = rresp;
                        end 
                            
                    end
                /*
                if(~awvalid&arvalid) begin
                    psel = 1;
                    pop_A = 1;
                    pwrite = 0;
                end

                else 
                    begin
                        psel = 0;
                        pop_A = 0;
                        pwrite = 0;
                    end
                */
            end
        
    end
    
    assign pprot = (pwrite)? awprot:arprot;
    assign pstrb = (pwrite)? wstrb:pstrb;



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
                if(psel) next_state = setup;
                else next_state = idle;
            end
            setup: begin
                next_state = access;
            end
            access: begin
                if(preadyREG & psel) next_state = setup;
                else if (preadyREG & ~psel) next_state = idle;
                else next_state = access;
            end
        endcase
    end
    always_comb begin
    
    
        case (state)

            idle:begin
                if(psel) penable = 0;
                else penable = penable;

            end
            setup:begin
                penable = 1;
            end
            access:begin
      /*
                if(~pwrite)
                begin
                    if(pready&~full_D_read) begin 
                        push_D_read = 1; 
                        rvalid = 1;
                    end
                    else begin 
                        push_D_read = 0;
                        rvalid = 0;
                    end
                end*/
            end
        endcase
    end

endmodule