module wb_ram(
   input                        wb_clk_i,
   input                        wb_rst_i,
   /* verilator lint_off UNUSED */
   input [WB_ADDR_WIDTH - 1:0]  wb_addr_i,
   input [WB_DATA_WIDTH - 1:0]  wb_data_i,
   input [WB_BYTE_SEL - 1:0]    wb_sel_i,
   input                        wb_we_i,
   input                        wb_cyc_i,
   input                        wb_stb_i,

   output                       wb_ack_o,
   output                       wb_err_o,
   output [WB_DATA_WIDTH - 1:0] wb_data_o
);

   parameter WB_DATA_WIDTH = 32;
   parameter WB_DATA_SIZE  = 2**16;
   parameter WB_ADDR_WIDTH = $clog2(WB_DATA_SIZE);
   parameter WB_MEM_FILE   = "";
   localparam BYTE_SIZE  = 8;
   localparam WB_BYTE_SEL  = WB_DATA_WIDTH / BYTE_SIZE;

   assign wb_err_o = 0;

   reg wb_ack;
   assign wb_ack_o = wb_ack;

   wire valid = wb_cyc_i & wb_stb_i;

   always @ (posedge wb_clk_i) begin
      if (wb_rst_i) begin
         wb_ack <= 0;
      end else begin
         wb_ack <= valid & !wb_ack;
      end
   end

   wire ram_we = wb_we_i & valid & wb_ack_o;

   reg [WB_DATA_WIDTH - 1:0] data;
   assign wb_data_o = data;
   reg [WB_DATA_WIDTH - 1:0] memory [0:WB_DATA_SIZE/4 - 1] /* verilator public */;
   reg [WB_DATA_WIDTH - 1:0] tmp_data_w;
   reg [WB_ADDR_WIDTH - 1:0] tmp_addr;

   always @ (posedge wb_clk_i) begin
      if (valid) begin
         tmp_addr <= wb_addr_i;
      end
   end

   always @(posedge wb_clk_i) begin
      if (valid) begin
         tmp_data_w[7:0]   <= wb_sel_i[0] ? wb_data_i[7:0]   : data[7:0];
         tmp_data_w[15:8]  <= wb_sel_i[1] ? wb_data_i[15:8]  : data[15:8];
         tmp_data_w[23:16] <= wb_sel_i[2] ? wb_data_i[23:16] : data[23:16];
         tmp_data_w[31:24] <= wb_sel_i[3] ? wb_data_i[31:24] : data[31:24];
      end
      if (ram_we) begin
         memory[tmp_addr[WB_ADDR_WIDTH - 1:2]] <= tmp_data_w;
      end
   end

   always @ (posedge wb_clk_i) begin
      if (valid) begin
         data <= memory[wb_addr_i[WB_ADDR_WIDTH - 1:2]];
      end else begin
         data <= 0;
      end
   end

   generate
      initial
         if (WB_MEM_FILE != "") begin
            $readmemh(WB_MEM_FILE, memory);
         end
   endgenerate

endmodule

