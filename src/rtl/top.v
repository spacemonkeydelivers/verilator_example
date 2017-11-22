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

   /* verilator lint_off UNUSED */
   wire wb_ack;
   wire wb_err;
   wire [31:0] wb_data;
   /* verilator lint_off WIDTH */
   wire [31:0] input_data = ~output_o;
   wire [31:0] output_data;;

   wb_ram #()
   WB_RAM0(.wb_clk_i(clk_i),
           .wb_rst_i(reset_i),
           .wb_addr_i(output_o[10:0]),
           .wb_data_i(input_data),
           .wb_we_i(!output_o[14]),
           .wb_sel_i(4'b1111),
           .wb_cyc_i(output_o[1]),
           .wb_stb_i(output_o[1]),
           .wb_ack_o(wb_ack),
           .wb_err_o(wb_err),
           .wb_data_o(wb_data));

endmodule
