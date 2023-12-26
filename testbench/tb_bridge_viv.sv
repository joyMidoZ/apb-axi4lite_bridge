`timescale 1ns/1ps
module tb_bridge();
    parameter ADDRWIDTH = 32;
    parameter DATAWIDTH = 32;
    parameter DEPTH = 10;
    bit clk,rst;
    always #5 clk = ~clk;
    axi4_Lite i_f();
    apb IF();
    logic awreadyM,
          wreadyM,
          arreadyM,
          bvalidM,
          rvalidM;
    logic [1:0] brespM;
    logic [DATAWIDTH-1:0] rdataM;
    logic [1:0] rrespM;

    logic [ADDRWIDTH-1:0] awaddrM;
    logic [2:0] awprotM;
    logic [DATAWIDTH-1:0] wdataM;
    logic [DATAWIDTH/8 - 1:0] wstrbM;
    logic [ADDRWIDTH-1:0] araddrM;
    logic [2:0] arprotM;
    logic pslverr,
          pready;
    logic [DATAWIDTH-1:0]data [0:DEPTH-1];


    //localparam int TEST_ITERATIONS = 10;
    //localparam int randTime;
    top dut (clk,
             rst,
             i_f.axiSlave,
             IF.masterAPB);

    
    bit flag = 0;
    int randAwready,randWready,randArready,randRready,
    randBready,randAddr,randData,randTestMake,randNum1;

    initial begin

         //$randomseed = $time;
        clk <= 0;
        rst <= 0;

        dut.rdataM <=0;
        dut.arreadyM <=0;
        dut.pselxM <=0;
        dut.penableM <=0;
        dut.pwriteM <=0;
        dut.pstrbM <=0;
        dut.wreadyM <=0;
        dut.awreadyM <=0;
        dut.rvalidM <=0;
        dut.paddrM <=0;
        dut.pwdataM <=0;
        dut.prdataM <=0;
        dut.empty_A <=0;
        dut.full_A <=0;
        dut.empty_D <=0;
        dut.full_D <=0;
        dut.empty_D_read <=0;
        dut.full_D_read <=0;
        dut.push_D_read <=0;
        for (int i=0; i<DEPTH; ++i) begin
            dut.fifo_A.data[i] <=0; 
        end
        for (int j=0; j<DEPTH; ++j) begin
            dut.fifo_D.data[j] <=0;
        end
        for (int h=0; h<DEPTH; ++h) begin
            dut.fifo_D_read.data[h] <=0;
        end

        IF.masterAPB.pready <= 0;
        IF.masterAPB.pslverr <= 0;
        IF.masterAPB.pselx <= 0;
        IF.masterAPB.penable <=0;
        IF.masterAPB.prdata <=0;
        IF.masterAPB.paddr <=0;
        IF.masterAPB.pwdata <=0;
        IF.masterAPB.pstrb <=0;
        i_f.axiSlave.araddr <=0;
        i_f.axiSlave.awvalid <= 0;
        i_f.axiSlave.arvalid <= 0;
        i_f.axiSlave.arprot <=0;
        i_f.axiSlave.rdata <=0;
        i_f.axiSlave.rresp <= 0;
        i_f.axiSlave.awaddr <= 0;
        i_f.axiSlave.awprot <= 0;
        
        i_f.axiSlave.wdata <= 0;
        i_f.axiSlave.wstrb <= 0;
        i_f.axiSlave.wvalid <= 0;

        i_f.axiSlave.bready <= 0;

        i_f.axiSlave.rready <= 0;
        
        #25;
        rst <= 1;
        /*
        #20;
            test_write();
        #100;
            test_write();*/
            
            repeat(100)begin
                randTestMake = $urandom_range(0,999);
                if(randTestMake%2)begin
                    #50;
                    test_read();
                end

                else begin
                    #50;
                    test_write();
                end
            end
            
                    
    end
    int randsVar1,randsVar2,randsVar3,randsVar4;
    task  test_write();
        test_write_addr();
        $strobe("[strobe] ADDR || awaddr=0x%0h || paddr=0x%0h || ",
         i_f.axiSlave.awaddr,IF.masterAPB.paddr);
        test_write_data();
        $strobe("[strobe] DATA || pwdata=0x%0h || wdata=0x%0h ||",
         IF.masterAPB.pwdata, i_f.axiSlave.wdata);
        test_write_resp();
        
        //$strobe("[strobe] time=%0t || awaddr=0x%0h", $time, i_f.axiSlave.awaddr);
    endtask //automatic
    task test_read ();
        test_read_addr();
        $strobe("[strobe] ADDR || araddr=0x%0h || paddr=0x%0h || ",
         i_f.axiSlave.araddr,IF.masterAPB.paddr);
         
        test_read_data();
        $strobe("[strobe] DATA || prdata=0x%0h || rdata=0x%0h ||",
         IF.masterAPB.prdata, i_f.axiSlave.rdata);
         
    endtask
    task  preadyTest();
        fork
        @(posedge clk) begin
            randAwready = $urandom_range(2, 9)*10;
            randNum1 = $urandom_range(0,1);
            #randAwready;
            fork
            IF.masterAPB.pready <= 1;
            IF.masterAPB.pslverr <= randNum1;
            join
            #10;
            fork
            IF.masterAPB.pready <= 0;
            IF.masterAPB.pslverr <= 0;
            join
            end
        join
    endtask

    task pslverrTest();
        fork
            @(posedge clk)begin
                randNum1 = $urandom_range(2, 5)*10;
                #randNum1;
                IF.masterAPB.pslverr <= 1;
                #10;
                IF.masterAPB.pslverr <= 0;
            end
            join
    endtask

    task  test_write_addr();
        randsVar1 = $urandom_range(1,9)*10;
        #randsVar1;
        fork
            i_f.axiSlave.awvalid <= 1;
            i_f.axiSlave.awaddr <= $urandom_range(0, 1024);
            i_f.axiSlave.awprot <= 3'b000;
        join
        @((i_f.axiSlave.awready == 1)& (i_f.axiSlave.awvalid == 1)) 
        begin
            #10;
            i_f.axiSlave.awvalid <= 0;
        end
        //$strobe("[strobe] time=%0t || awaddr=0x%0h", $time, i_f.axiSlave.awaddr);
        //$display("[strobe] time=%0t || awaddr=0x%0h", $time, i_f.axiSlave.awaddr);
    endtask 

    task  test_write_data();
        randsVar2 = $urandom_range(1,9)*10;
        #randsVar2;
        fork
            i_f.axiSlave.wvalid <= 1;
            i_f.axiSlave.wdata <= $urandom_range(0, 1024);
            i_f.axiSlave.wstrb <= $urandom_range(0, (2**DATAWIDTH)/8-1);  
                 
        join
        @((i_f.axiSlave.wready == 1) & (i_f.axiSlave.wvalid == 1))
        begin
            #10;
            i_f.axiSlave.wvalid <= 0;
        end
             
    endtask //automatic

    task  test_write_resp();
        //randsVar3 = $urandom_range(1,9)*10;
        #10;
        fork
            i_f.axiSlave.bready <= 1;
            preadyTest();
            //pslverrTest();
            
        join
        wait((i_f.axiSlave.bvalid == 1)&(i_f.axiSlave.bready == 1))
        begin
            i_f.axiSlave.bready <=0;
            
        end
    endtask 

    task test_read_addr();
        randsVar1 = $urandom_range(1,9)*10;
        #randsVar1;
        fork
            i_f.axiSlave.arvalid <= 1;
            i_f.axiSlave.araddr <= $urandom_range(0, 1024);
            i_f.axiSlave.arprot <= 3'b000;
        join
        @((i_f.axiSlave.arready == 1) & (i_f.axiSlave.arvalid == 1)) 
        begin
            #10;
            i_f.axiSlave.arvalid <= 0;
        end
                
    endtask

    task  test_read_data();
        randsVar4 = $urandom_range(1,9)*10;
        #randsVar4;
        fork
            i_f.axiSlave.rready <= 1;
            IF.masterAPB.prdata <= $urandom_range(0, 1024);
            preadyTest();
        join
        @((i_f.axiSlave.rready == 1) & (i_f.axiSlave.rvalid == 1))
        begin
            #10;
            i_f.axiSlave.rready <= 0;
        end


        endtask
endmodule