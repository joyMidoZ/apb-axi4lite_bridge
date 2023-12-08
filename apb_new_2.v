// **** Project -- Design  and verification of AMBA APB Protocol for             read and write operation.                               ******//


module AMBA_APB( 
     			//      Inputs   //
  			
  				input wire  	PCLK,
				  input wire  	PRESET,  //Active low
  				input wire 		PSEL,
  				input wire[7:0] PADDR,
  				input wire      PENABLE,
  				input wire		PWRITE,
  				input wire[7:0] PWDATA,
  
              //	outputs 		//
 			   
  				output reg[7:0] PRDATA,
 			    output reg 	    PREADY        );
  
  //          State encoding 
  
  parameter   IDLE   = 2'b00,
              SETUP  = 2'b01,
              ACCESS = 2'b10;
  
  //      State Declaration 
  
  reg [1:0] present_state;
  reg [1:0] next_state;
  
  reg [7:0] mem[31:0]; // storage elements
  
   
  //   Synchronous state - transition 
  
  always@ (posedge PCLK) 
    begin
      if(PRESET)
        present_state <= IDLE;
      else 
        present_state = next_state;
    end
    
  //   Conditional state - transition 
  
  always@( * )
    begin
      case(present_state)
        IDLE : begin
          if(PSEL==1 & PENABLE==0)
               next_state = SETUP;
           if(PSEL==0 & PENABLE==0)
               next_state = IDLE;
              end
        SETUP:begin
            if(PSEL==1 & PENABLE==1) begin
               next_state = ACCESS; 
               PREADY = 1;
               if(PWRITE) 
                 mem[PADDR] = PWDATA;
               else
                 PRDATA = mem[PADDR];
             end
         
           if(PSEL==0 & PENABLE==0)
                 next_state = IDLE;
               end
        ACCESS:begin
            if(PSEL==0 & PENABLE==0)
                 next_state = IDLE;
                 PREADY = 0;
            if(PSEL==1 & PENABLE==1)
                 next_state = ACCESS;
             end
      endcase
    end
  
endmodule
         
      
             