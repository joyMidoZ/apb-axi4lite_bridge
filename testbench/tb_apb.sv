`timescale 1ns / 1ps

module tb_apb;

  // ????????? ???? APB
  parameter addrWidth = 32;
  parameter dataWidth = 32;
  apb IF(clk,rst);
  // ??????? ???? APB
  bit clk,rst,prv;
  
  int randW,randR,randSet1,randSet2;
  always #5 clk = ~clk;

    logic [2:0] pprotM;
    logic pselxM;
    logic pwriteM;
    logic [dataWidth/8 - 1:0] pstrbM;
    logic [addrWidth-1:0] paddrM;
    logic [dataWidth-1:0] pwdataM;
    logic pslverrM;
    logic preadyM;
    logic [dataWidth-1:0]prdataM;
  

    apbMaster dut (clk, rst, IF.masterAPB,
        pprotM,
        pselxM,
        pwriteM,
        pstrbM,
        paddrM, 
        pwdataM,
        pslverrM,
        preadyM,
        prdataM );
          
  initial begin

        pselxM = 0;
        pwriteM = 0;
        paddrM = 0;
        pwdataM = 0;
        pstrbM = 0;
        IF.masterAPB.pslverr = 0;
        IF.masterAPB.pready = 0;
        IF.masterAPB.prdata = 0;
        clk <= 0;
        rst <= 0;
        #55;
        rst <= 1;
    

    repeat(10)begin
    test_write_noWait();
    end

    #100;

    repeat(10)begin
    test_read();
    end
  end

  task  test_write_noWait();
        #30;
        randSet1 = $urandom_range(0, 1);
    
        pselxM = randSet1;

        if(pselxM)begin
        pwriteM = 1;
        pprotM = 0;
        paddrM = $urandom_range(0, 2048);
        pwdataM = $urandom_range(0, 2048);
        pstrbM = $urandom_range(0, 2**(dataWidth/8)-1);

        #10;
        IF.masterAPB.pready = 1;
        #10;
        IF.masterAPB.pready = 0;
        end
  endtask 
  task test_write();

    #30;
    prv = 0;
    
    randSet1 = $urandom_range(0, 1);
    
    pselxM = randSet1;
    if(pselxM) prv = 1;
    if(pselxM)begin
    pwriteM = 1;
    pprotM = 0;
    paddrM = $urandom_range(0, 2048);
    pwdataM = $urandom_range(0, 2048);
    pstrbM = $urandom_range(0, 2**(dataWidth/8)-1);

    randW = $urandom_range(1, 5)*10;
    #randW;
    IF.masterAPB.pready = 1;
    #10;
    IF.masterAPB.pready = 0;
    end
    
  endtask

  task test_read();
    #30;

    randSet2 = $urandom_range(0, 1);
    pselxM = randSet2;
    if(pselxM)begin
    pwriteM = 0;
    pprotM = 0;
    paddrM = $urandom_range(0, 2048);
    pstrbM = $urandom_range(0, 2**(dataWidth/8)-1);
    IF.masterAPB.pslverr = 0;
    
    IF.masterAPB.prdata = $urandom_range(0, 2048);

    randR = $urandom_range(1, 5)*10;
    #randR;
    IF.masterAPB.pready = 1;
    #10;
    IF.masterAPB.pready = 0;
    end

      endtask
endmodule