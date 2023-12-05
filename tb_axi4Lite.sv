
`timescale 1ns / 1ps

module tb_axi4Lite();
    parameter addrWidth = 32;
    parameter dataWidth = 32;
    bit clk,rst;
    //always #5 clk = ~clk;
    axi4_Lite i_f(clk,rst);

    logic awreadyM,wreadyM,arreadyM,bvalidM,rreadyM;
    logic [1:0] brespM;
    logic [dataWidth-1:0] rdataM;
    logic [1:0] rrespM;

    logic [addrWidth-1:0] awaddrM;
    logic [2:0] awprotM;
    logic [dataWidth-1:0] wdataM;
    logic [dataWidth/8 - 1:0] wstrbM;
    logic [addrWidth-1:0] araddrM;
    logic [2:0] arprotM;

    localparam int TEST_ITERATIONS = 10;
    localparam int randTime;
    AXILite_Structure axi_dut (clk,rst,i_f.axiSlave,awreadyM,wreadyM,arreadyM,bvalidM,rvalidM,
    brespM,
    rdataM,
    rrespM,

    awaddrM,
    awprotM,
    wdataM,
    wstrbM,
    araddrM,
    arprotM);

    initial begin

         $randomseed = $time;
        clk <=0;
        rst <=0;
        i_f.axiSlave.awvalid <= 0;
        i_f.axiSlave.awaddr <= 0;
        i_f.axiSlave.awprot <= 0;

        i_f.axiSlave.wdata <= 0;
        i_f.axiSlave.wstrb <= 0;
        i_f.axiSlave.wvalid <= 0;

        i_f.axiSlave.bready <= 0;
        
        forever #5 clk = ~ clk;
        repeat(3) begin
            test_write();

            #30;
            end
        repeat(3)begin
            test_read();

            #30
        end

    end

    task test_write();      // TASK WRITE
        rst = 1;
        #($urandom_range(10, 40));

        // Начало транзакции WRITE
        i_f.axiSlave.awvalid <= 1;
        i_f.axiSlave.awaddr <= $urandom_range(0, 2**addrWidth-1);
        #($urandom_range(10, 40));
        awreadyM <= 1;

        #($urandom_range(10, 40));
        awreadyM <=0;
        i_f.axiSlave.awvalid <= 0;
        #($urandom_range(10, 40)); 

        // Ожидание окончания транзакции
        i_f.axiSlave.wvalid <= 1;
        i_f.axiSlave.wdata <= $urandom_range(0, 2**dataWidth-1);
        #($urandom_range(10, 40)); 

        // Ожидание окончания транзакции записи
        wreadyM <= 1;
        #($urandom_range(10, 40)); 
        wreadyM <=0;
        i_f.axiSlave.wvalid <= 0;
        #($urandom_range(10, 40));
        i_f.axiSlave.bready <= 1;

        #($urandom_range(10, 40));
        i_f.axiSlave.bready <= 0;
        // Завершение теста
        $stop;
    endtask

    task test_read()       // TASK READ
        rst = 1;
        #($urandom_range(10, 40));

        // Начало транзакции read
        i_f.axiSlave.arvalid <= 1;
        i_f.axiSlave.araddr <= $urandom_range(0, 2**addrWidth-1);

        #($urandom_range(10, 40));
        arreadyM <= 1;

        #($urandom_range(10, 40));
        arreadyM <=0;
        i_f.axiSlave.arvalid <= 0;

        #($urandom_range(10, 40)); 
        rvalidM <= 1;
        rrespM <= 1;
        rdataM <= $urandom_range(0, 2**dataWidth-1);

        #($urandom_range(10, 40)); 
        i_f.axiSlave.rready <= 1;

        #($urandom_range(10, 40)); 
        rvalidM <=0;
        rrespM <= 0;
        i_f.axiSlave.rready <= 0;
        $stop;
    endtask




endmodule

