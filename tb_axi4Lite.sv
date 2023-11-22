module tb_axi4Lite();
    bit clk,rst;
    always #5 clk = ~clk;
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
);

    AXILite_Structure axi_dut (clk,rst,i_f.axiSlave,awreadyM,wreadyM,arreadyM,bvalidM,rreadyM,brespM,rdataM,
    rrespM,awaddrM,awprotM,wdataM,wstrbM,araddrM,arprotM);
    initial begin
        clk <=0;
        rst <=0;
        #20 rst = 1;
    end
endmodule