module top(
   input clk_i,
   input reset_i,
   output trap_occured_o
);
   parameter MEM_FILE = "";
   parameter WB_DATA_WIDTH = 32;
   parameter WB_ADDR_WIDTH = 32;
   localparam BYTE_SIZE = 8;
   localparam WB_SEL_WIDTH = (WB_DATA_WIDTH / BYTE_SIZE);
   
   wire [WB_DATA_WIDTH - 1:0] wb_m2s_data;
   wire [WB_DATA_WIDTH - 1:0] wb_s2m_data;
   wire [WB_ADDR_WIDTH - 1:0] wb_addr;
   wire [ WB_SEL_WIDTH - 1:0] wb_sel;
   wire                       wb_we;
   wire                       wb_cyc;
   wire                       wb_stb;
   wire                       wb_ack;
   wire                       wb_err;
   wire                       wb_stall;


   wire prv32_trap_occured;
   assign trap_occured_o = prv32_trap_occured;
   /* verilator lint_off UNUSED */
   wire        prv32_pcpi_valid;
	wire [31:0] prv32_pcpi_insn;
	wire [31:0] prv32_pcpi_rs1;
	wire [31:0] prv32_pcpi_rs2;
   wire [31:0] prv32_eoi;
   wire        prv32_trace_valid;
	wire [35:0] prv32_trace_data;
	wire        prv32_mem_instr;
   /* verilator lint_on UNUSED */

   picorv32_wb#()
   PICORV0(.trap(prv32_trap_occured),
           .wb_rst_i(reset_i),
           .wb_clk_i(clk_i),
           .wbm_adr_o(wb_addr),
           .wbm_dat_o(wb_m2s_data),
           .wbm_dat_i(wb_s2m_data),
           .wbm_we_o(wb_we),
           .wbm_sel_o(wb_sel),
           .wbm_stb_o(wb_stb),
           .wbm_ack_i(wb_ack),
           .wbm_cyc_o(wb_cyc),
           .pcpi_valid(prv32_pcpi_valid),
           .pcpi_insn(prv32_pcpi_insn),
           .pcpi_rs1(prv32_pcpi_rs1),
           .pcpi_rs2(prv32_pcpi_rs2),
           .pcpi_wr(0),
           .pcpi_rd(0),
           .pcpi_wait(0),
           .pcpi_ready(0),
           .irq(0),
           .eoi(prv32_eoi),
           .trace_valid(prv32_trace_valid),
           .trace_data(prv32_trace_data),
           .mem_instr(prv32_mem_instr)
   );

   wb_ram #(
            .WB_DATA_WIDTH(WB_DATA_WIDTH),
            .WB_ADDR_WIDTH(WB_ADDR_WIDTH),
            .MEMORY_SIZE(256),
            .MEM_FILE(MEM_FILE))
   WB_RAM0(.wb_clk_i(clk_i),
           .wb_rst_i(reset_i),
           .wb_addr_i(wb_addr),
           .wb_data_i(wb_m2s_data),
           .wb_we_i(wb_we),
           .wb_sel_i(wb_sel),
           .wb_cyc_i(wb_cyc),
           .wb_stb_i(wb_stb),
           .wb_ack_o(wb_ack),
           .wb_err_o(wb_err),
           .wb_stall_o(wb_stall),
           .wb_data_o(wb_s2m_data));

endmodule
