module top(
   input clk_i,
   input reset_i,
   output [WIDTH - 1:0] output_o
);
   parameter WIDTH = 4;

   counter #(.CNT_WIDTH(WIDTH))
   CNT(.reset_i(reset_i),
       .clk_i(clk_i),
       .result_o(output_o));

endmodule
