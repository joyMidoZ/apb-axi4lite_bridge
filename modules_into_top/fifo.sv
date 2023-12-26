// A generic D-flip-flop based FIFO

module fifo
# (
  parameter WIDTH = 32,
            DEPTH = 10
)
(
  input                clk,
  input                rst,
  input                push,
  input                pop,
  input  [WIDTH - 1:0] write_data,

  output logic [WIDTH - 1:0]  read_data,
  output logic                empty,
  output logic                full
);
  localparam DEPTH_INCR = DEPTH + 1;
  localparam DEPTH_DINCR = DEPTH - 1;
  localparam POINTER_WIDTH = $clog2 (DEPTH),
             COUNTER_WIDTH = $clog2 (DEPTH_INCR);

  localparam [COUNTER_WIDTH - 1:0] max_ptr = COUNTER_WIDTH' (DEPTH_DINCR);

  logic [POINTER_WIDTH - 1:0] wr_ptr, rd_ptr;
  logic [COUNTER_WIDTH - 1:0] cnt;

  logic [WIDTH - 1:0] data [0: DEPTH_DINCR];

  //--------------------------------------------------------------------------

  always @ (posedge clk)
    if (rst)
      wr_ptr <= '0;
    else if (push)
      wr_ptr <= wr_ptr == max_ptr ? '0 : wr_ptr + 1'b1;


    always@(posedge clk)
        if(rst)
            rd_ptr <= '0;
        else if(pop)
            rd_ptr <= rd_ptr == max_ptr ? '0 : rd_ptr +1'b1;
  //--------------------------------------------------------------------------


    always_comb begin 
      data [wr_ptr] = (push)? write_data:data[wr_ptr];
      read_data =(pop)?data[rd_ptr]:read_data;
    end



  //--------------------------------------------------------------------------

  always @ (posedge clk)
    if (rst)
      cnt <= '0;
    else if (push & ~ pop)
      cnt <= cnt + 1'b1;
    else if (pop & ~ push)
      cnt <= cnt - 1'b1;
    

  //--------------------------------------------------------------------------

  assign empty = ~| cnt;
    

    assign full = (cnt==DEPTH)? 1:0;
endmodule

