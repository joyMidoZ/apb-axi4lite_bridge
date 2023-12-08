
module tb_axi4Lite();
    parameter addrWidth = 32;
    parameter dataWidth = 32;
    bit clk,rst;
    always #5 clk = ~clk;
    axi4_Lite i_f();

    logic awreadyM,wreadyM,arreadyM,bvalidM,rvalidM;
    logic [1:0] brespM;
    logic [dataWidth-1:0] rdataM;
    logic [1:0] rrespM;

    logic [addrWidth-1:0] awaddrM;
    logic [2:0] awprotM;
    logic [dataWidth-1:0] wdataM;
    logic [dataWidth/8 - 1:0] wstrbM;
    logic [addrWidth-1:0] araddrM;
    logic [2:0] arprotM;

    //localparam int TEST_ITERATIONS = 10;
    //localparam int randTime;
    axi4lite_transactor axi_dut (clk,rst,i_f.axiSlave,awreadyM,wreadyM,arreadyM,bvalidM,rvalidM,
    brespM,
    rdataM,
    rrespM,

    awaddrM,
    awprotM,
    wdataM,
    wstrbM,
    araddrM,
    arprotM);

    event itsOVER;
    int i = 0;
    int randAwready,randWready,randArready,randRready,randBready;
    initial begin

         //$randomseed = $time;
        clk <= 0;
        rst <= 0;
        i_f.axiSlave.awvalid <= 0;
        awreadyM <= 0;
        wreadyM <= 0;
        i_f.axiSlave.awaddr <= 0;
        i_f.axiSlave.awprot <= 0;

        i_f.axiSlave.wdata <= 0;
        i_f.axiSlave.wstrb <= 0;
        i_f.axiSlave.wvalid <= 0;

        i_f.axiSlave.bready <= 0;
        bvalidM <= 0;

        arreadyM <= 0;
        i_f.axiSlave.rready <= 0;
        rvalidM <= 0;
        
        //forever #5 clk = ~ clk;
        /*#5;
        
        repeat(1) begin
                    fork
                        repeat(10) signals_neIF_write();
                        
                        repeat(10) test_write();
                    join
                    -> itsOVER;
                    #30;
                    
        end
        repeat(1) begin
                    fork
                        repeat(10) signals_neIF_read();
                        
                        repeat(10) test_read();
                    join
                    -> itsOVER;
                    #30;
                    
        end
        */
        
        
        #5
            fork 
                repeat(10) begin
                    test_write();
                    -> itsOVER;
                    #30;
                end
                wait(itsOVER.triggered()); i = i + 1;
                while(i!=10)
                repeat(10) signals_neIF_write();
            join
        /*
        repeat(3)begin
            test_read();
            #30
        end*/

    end
     
    task signals_neIF_write();
        fork
        @(posedge clk) begin
            randAwready = $urandom_range(0, 15)*10;
            #randAwready;
            awreadyM <= ~awreadyM;
            
            end
        join
        fork
        @(posedge clk) begin
            randWready = $urandom_range(1, 10)*10;
            #randWready;
            wreadyM <= ~wreadyM;
            end
        join
        fork
         @(posedge clk) begin
            randBready = $urandom_range(0, 15)*10;
            #randBready;
            i_f.axiSlave.bready <= ~i_f.axiSlave.bready;
            end
        join
    endtask

    task signals_neIF_read();
        fork
        @(posedge clk) begin
            randArready = $urandom_range(0, 15)*10;
            #randArready;
            arreadyM <= ~arreadyM;
            end
        join
        fork
        @(posedge clk) begin
            randRready = $urandom_range(0, 10)*10;
            #randRready;
            i_f.axiSlave.rready <= ~i_f.axiSlave.rready;
            end
        join
         
        
    endtask

    task test_write();      // TASK WRITE
        #10;
        rst = 1;
        @(posedge clk)
        #($urandom_range(10, 40));
        // ???????????? ???????????????????? WRITE

        //  handshake addr
        i_f.axiSlave.awvalid <= 1;
        i_f.axiSlave.awaddr <= $urandom_range(0, 1024);
        i_f.axiSlave.awprot <= 3'b000;
        wait((awreadyM == 1) & (i_f.axiSlave.awvalid == 1)) // handshake!!!
            begin
                #10;
                awreadyM <=0;
                i_f.axiSlave.awvalid <= 0;
                // end handshake addr

                // handshake data
                #($urandom_range(10, 40)); 
                i_f.axiSlave.wvalid <= 1;
                i_f.axiSlave.wdata <= $urandom_range(0, 1024);
                i_f.axiSlave.wstrb <= $urandom_range(0, (2**dataWidth)/8-1);
                wait((wreadyM == 1) & (i_f.axiSlave.wvalid == 1)) // handshake!!!
                    begin 
                        #10; 
                        wreadyM <=0;
                        i_f.axiSlave.wvalid <= 0;
                        bvalidM <= 1;
                        brespM <= 2'b00;
                        //end handshake
                        // ???????????????????? ??????????
                    end
            end
        //$stop;
    endtask

    task test_read();      // TASK READ
        rst = 1;
        #($urandom_range(10, 40));

        //  handshake addr
        i_f.axiSlave.arvalid <= 1;
        i_f.axiSlave.araddr <= $urandom_range(0, 1024);
        i_f.axiSlave.arprot <= 3'b000;
        wait((arreadyM == 1) & (i_f.axiSlave.arvalid == 1)) // handshake!!!
            begin
                #10;
                arreadyM <=0;
                i_f.axiSlave.arvalid <= 0;
                // end handshake addr

                // handshake data
                #($urandom_range(10, 40)); 
                rvalidM <= 1;
                rdataM <= $urandom_range(0, 1024);
                wait((i_f.axiSlave.rready == 1) & (rvalidM == 1)) // handshake!!!
                    begin
                        #10; 
                        i_f.axiSlave.rready <=0;
                        rvalidM <= 0;
                        rrespM <= 1;
                        //end handshake
                    end
                
            end
        //$stop;
    endtask
endmodule
