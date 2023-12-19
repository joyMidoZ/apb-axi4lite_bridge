
module tb_bridge();
    parameter addrWidth = 32;
    parameter dataWidth = 32;
    bit clk,rst;
    always #5 clk = ~clk;
    axi4_Lite i_f();
    apb IF();
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
    logic pslverr, pready;
    //localparam int TEST_ITERATIONS = 10;
    //localparam int randTime;
    top dut (clk,rst,i_f.axiSlave,IF.masterAPB);
    bit flag = 0;
    int randAwready,randWready,randArready,randRready,randBready,randAddr,randData;
    initial begin

         //$randomseed = $time;
        clk <= 0;
        rst <= 0;
        IF.masterAPB.pready <= 0;
        IF.masterAPB.pslverr <= 0;
        i_f.axiSlave.awvalid <= 0;
        i_f.axiSlave.arvalid <= 0;
        i_f.axiSlave.awaddr <= 0;
        i_f.axiSlave.awprot <= 0;
        
        i_f.axiSlave.wdata <= 0;
        i_f.axiSlave.wstrb <= 0;
        i_f.axiSlave.wvalid <= 0;

        i_f.axiSlave.bready <= 0;

        i_f.axiSlave.rready <= 0;
        

        #25;
        rst <= 1;
        #20;
            test_write();
        #100;
            test_write();
    end
    int randsVar1,randsVar2,randsVar3;
    task automatic test_write();
        test_write_addr();
        test_write_data();
        test_write_resp();
    endtask //automatic
    task automatic test_read ();
        
    endtask //automatic
    task  preadyTest();
        fork
        @(posedge clk) begin
            randAwready = $urandom_range(2, 9)*10;
            #randAwready;
            IF.masterAPB.pready <= 1;
            
            end
        join
    endtask

    task automatic test_write_addr();
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
        
    endtask //automatic

    task automatic test_write_data();
        randsVar2 = $urandom_range(1,9)*10;
        #randsVar2;
        fork
            i_f.axiSlave.wvalid <= 1;
            i_f.axiSlave.wdata <= $urandom_range(0, 1024);
            i_f.axiSlave.wstrb <= $urandom_range(0, (2**dataWidth)/8-1);            
        join
        @((i_f.axiSlave.wready == 1) & (i_f.axiSlave.wvalid == 1))
        begin
            #10;
            i_f.axiSlave.wvalid <= 0;
            preadyTest();
        end
    endtask //automatic

    task automatic test_write_resp();
        randsVar3 = $urandom_range(1,9)*10;
        #randsVar3;
        fork
            i_f.axiSlave.bready <= 1;
            IF.masterAPB.pslverr <= 1;
        join
        @(i_f.axiSlave.bvalid == 1)
        begin
            i_f.axiSlave.bready <=0;
            IF.masterAPB.pslverr <= 0;
        end
    endtask //automatic
endmodule
