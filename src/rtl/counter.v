module counter(
   input clk_i,
   input reset_i,
   output [CNT_WIDTH - 1:0] result_o
);
   parameter CNT_WIDTH = 10;
   parameter DEFAULT_VALUE = 0;
   
   reg [CNT_WIDTH - 1:0] cnt;
   assign result_o = cnt;
   
   always @ (posedge clk_i) begin
      if (reset_i) begin
         cnt <= DEFAULT_VALUE;
      end else begin
         cnt <= cnt + 1;
      end
   end
endmodule
