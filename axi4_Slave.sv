module axi4_Slave(
    axi4_Lite.axiSlave axiS,
    output logic []awaddr,
    output logic []wdata
);
    logic []awaddr;
    logic []wdata;
    always_ff @(posedge axiS.aclk or negedge axiS.aresetn) begin
        //waddr
        if(~axiS.aresetn)begin
           aw
        end
    end
endmodule