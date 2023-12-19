// A generic D-flip-flop based FIFO

module fifo
# (
  parameter width = 32, depth = 10
)
(
  input                clk,
  input                rst,
  input                push,
  input                pop,
  input  [width - 1:0] write_data,

  output logic [width - 1:0] read_data,
  output               empty,
  output               full
);

  localparam pointer_width = $clog2 (depth),
             counter_width = $clog2 (depth + 1);

  localparam [counter_width - 1:0] max_ptr = counter_width' (depth - 1);

  logic [pointer_width - 1:0] wr_ptr, rd_ptr;
  logic [counter_width - 1:0] cnt;

  reg [width - 1:0] data [0: depth - 1];

  //--------------------------------------------------------------------------

  always @ (posedge clk)
    if (rst)
      wr_ptr <= '0;
    else if (push)
      wr_ptr <= wr_ptr == max_ptr ? '0 : wr_ptr + 1'b1;

  // TODO: Add logic for rd_ptr
    always@(posedge clk)
        if(rst)
            rd_ptr <= '0;
        else if(pop)
            rd_ptr <= rd_ptr == max_ptr ? '0 : rd_ptr +1'b1;
  //--------------------------------------------------------------------------

/*  always @ (posedge clk)
  begin
    if (push)
      data [wr_ptr] <= write_data;
    
    
    end
*/
    always_comb begin 
      data [wr_ptr] = (push)? write_data:data[wr_ptr];
      read_data =(pop)?data[rd_ptr]:read_data;
    end

    //always @ (posedge clk)
    //if(pop) read_data <= data[rd_ptr];    
  //assign read_data = data [rd_ptr];

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
    
  // TODO: Add logic for full output
    assign full = (cnt==depth)? 1:0;
endmodule

//----------------------------------------------------------------------------
/*
module fifo_model
# (
  parameter width = 8, depth = 2
)
(
  input                      clk,
  input                      rst,
  input                      push,
  input                      pop,
  input        [width - 1:0] write_data,
  output logic [width - 1:0] read_data,
  output logic               empty,
  output logic               full
);

  logic [width - 1:0] queue [$];
  logic [width - 1:0] dummy;

  always @ (posedge clk)
    if (rst)
    begin
      queue  = {};
      empty <= '1;
      full  <= '0;
    end
    else
    begin
      assert (~ (queue.size () == depth & push & ~ pop));
      assert (~ (queue.size () == 0     & pop));
      
      if (queue.size () > 0 & pop)
        dummy <= queue.pop_front ();

      if (queue.size () < depth & push)
        queue.push_back (write_data);
        
      if (queue.size () > 0)
        read_data <= queue [0];
      else
        read_data <= 'x;

      empty <= queue.size () == 0;
      full  <= queue.size () == depth;
    end
      
endmodule*/