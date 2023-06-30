`ifndef __MEMORYUNIT_SV__
`define __MEMORYUNIT_SV__

`include "../rtl/common/Define.sv"
module MemoryUnit#(
	parameter BW_PROCESSOR_DATA = 32,
	parameter NUM_LOAD_RESERVATION_STATION = 5,
	parameter NUM_STORE_RESERVATION_STATION = 5,
	parameter AQ_LENGTH = 10,
	parameter BW_TAG = 1,
	parameter BW_ADDRESS = 32
)(
	input clk,
	input rst_n,
//----------From Instruction Queue----------
	`valid_ready_input(i_lsrsv),
	input i_lsrsv_opcode, // r = 0, w = 1
	input [BW_TAG-1:0] i_lsrsv_tag,
	input [BW_ADDRESS-1:0] i_lsrsv_rwaddr,
	input signed [BW_PROCESSOR_DATA-1:0] i_lsrsv_wdata,
	input i_lsrsv_load_forwarding_valid, // if it is valid, we do not need to load data, just use i_lsrsv_load_forwarding_data
	input signed [BW_PROCESSOR_DATA-1:0] i_lsrsv_load_forwarding_data, // load forwarding

//----------To Data Memory----------
	`valid_ready_output(o_D_mem),
	input signed [BW_PROCESSOR_DATA-1:0] o_D_mem_rdata,
	output logic o_D_mem_r0w1, // r = 0, w = 1
	output logic [BW_ADDRESS-1:0] o_D_mem_rwaddr,
	output logic signed [BW_PROCESSOR_DATA-1:0] o_D_mem_wdata,

//----------To CDB broadcast load----------
	`valid_ready_output(o_cdb),
	output logic [BW_TAG-1:0] o_cdb_tag,
	output logic signed [BW_PROCESSOR_DATA-1:0] o_cdb_data
);
logic i_lsrsv_i_cen;
`valid_ready_logic(i_pf1);
PipelineForward u_pf1(
	.clk(clk),
	.rst(rst_n),
	`valid_ready_connect(i, i_lsrsv),
	.i_cen(i_lsrsv_i_cen),
	`valid_ready_connect(o, i_pf1)
);

`valids_readies_logic(i_broadcast, 2);
Broadcast#(
	.N(2)
) u_broadcast(
	.clk(clk),
	.rst(rst_n),
	`valid_ready_connect(i, i_pf1),
	`valid_ready_connect(o, i_broadcast)
);

logic s1_load_forwarding_valid;
logic signed [BW_PROCESSOR_DATA-1:0] s1_load_forwarding_data;
`valid_ready_logic(i_enable_D_mem);
assign i_enable_D_mem_valid = i_broadcast_valid[0];
assign i_broadcast_ready[0] = i_enable_D_mem_ready;
logic s1_D_mem_enable;
assign s1_D_mem_enable = !s1_load_forwarding_valid;
ForwardConditional u_fc_D_mem(
	`valid_ready_connect(i, i_enable_D_mem),
	`valid_ready_connect(o, o_D_mem),
	.enable(s1_D_mem_enable)
);


`valid_ready_logic(i_D_mem_pf);
`valid_ready_logic(o_D_mem_pf);
logic D_mem_cen;
assign i_D_mem_pf_valid = `handshake(o_D_mem) && (!o_D_mem_r0w1);
assign o_D_mem_pf_ready = o_cdb_ready;
PipelineForward u_D_mem_pf(
	.clk(clk),
	.rst(rst_n),
	`valid_ready_connect(i, i_D_mem_pf),
	.i_cen(D_mem_cen),
	`valid_ready_connect(o, o_D_mem_pf)
);


`valid_ready_logic(i_enable_forwarding);
`valid_ready_logic(o_enable_forwarding);
assign i_enable_forwarding_valid = i_broadcast_valid[1];
assign i_broadcast_ready[1] = i_enable_forwarding_ready;
assign o_enable_forwarding_ready = !o_D_mem_pf_valid && o_cdb_ready; // D_mem has priority because it has longer latency
ForwardConditional u_fc_forwarding(
	`valid_ready_connect(i, i_enable_forwarding),
	`valid_ready_connect(o, o_enable_forwarding),
	.enable(s1_load_forwarding_valid)
);

assign o_cdb_valid = o_D_mem_pf_valid || o_enable_forwarding_valid;

logic i_D_mem_r0w1;
assign i_D_mem_r0w1 = i_lsrsv_opcode == `STORE;
logic [BW_TAG-1:0] s1_tag;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		o_D_mem_r0w1 <= 1'b0;
		s1_tag <= 'd0;
		o_D_mem_rwaddr <= 'd0;
		o_D_mem_wdata <= 'd0;
		s1_load_forwarding_valid <= 1'b0;
		s1_load_forwarding_data <= 'd0;
	end else if (i_lsrsv_i_cen) begin
		o_D_mem_r0w1 <= i_D_mem_r0w1;
		s1_tag <= i_lsrsv_tag;
		o_D_mem_rwaddr <= i_lsrsv_rwaddr;
		o_D_mem_wdata <= i_lsrsv_wdata;
		s1_load_forwarding_valid <= i_lsrsv_load_forwarding_valid;
		s1_load_forwarding_data <= i_lsrsv_load_forwarding_data;
	end
end

logic [BW_TAG-1:0] s2_tag;
logic signed [BW_PROCESSOR_DATA-1:0] s2_data;

assign o_cdb_tag = (o_D_mem_pf_valid) ? s2_tag : s1_tag;
assign o_cdb_data = (o_D_mem_pf_valid) ? s2_data : s1_load_forwarding_data;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		s2_tag <= 'd0;
		s2_data <= 'd0;
	end else if (D_mem_cen) begin
		s2_tag <= s1_tag;
		s2_data <= o_D_mem_rdata;
	end
end
endmodule
`endif