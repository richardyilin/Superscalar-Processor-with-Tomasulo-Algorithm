`ifndef __CLOCKREPLACEMENT_SV__
`define __CLOCKREPLACEMENT_SV__

`include "../rtl/common/BitOperation.sv"
module ClockReplacement #(
	parameter ASSOCIATIVITY = 2
) (
	input [ASSOCIATIVITY-1:0] clock,
	input [ASSOCIATIVITY-1:0] clock_use,
	output logic [ASSOCIATIVITY-1:0] evicted_block_mask,
	output logic [ASSOCIATIVITY-1:0] clock_use_if_evict
);

logic [ASSOCIATIVITY*2-1:0] clock_extended_prefix_sum;
logic [ASSOCIATIVITY*2-1:0] clock_use_extended;
logic [ASSOCIATIVITY*2-1:0] clock_evicted_extended;
logic [ASSOCIATIVITY*2:0] clock_evicted_extended_LSB;
logic [ASSOCIATIVITY*2-1:0] clock_evicted_extended_prefix_sum;
logic [ASSOCIATIVITY-1:0] clock_use_reset_region;
logic [ASSOCIATIVITY*2-1:0] clock_use_reset_region_extended;

function [ASSOCIATIVITY-1:0] set_from_first_one_to_MSB;
	input [ASSOCIATIVITY-1:0] in;
	logic [ASSOCIATIVITY-1:0] out;
	out = in;
	begin
		for(int i = 1; i < ASSOCIATIVITY*2; i = 2*i) begin
			out = (out | (out << i));
		end
		set_from_first_one_to_MSB = out;
	end
endfunction

FindFirstOneFromLsb #(.N(2*ASSOCIATIVITY)) u_invalid_block_selector(
	.i_data(clock_evicted_extended),
	.o_prefix_sum(clock_evicted_extended_prefix_sum),
	.o_position(clock_evicted_extended_LSB)
);

always@(*) begin
	clock_extended_prefix_sum = {{(ASSOCIATIVITY){1'b1}}, set_from_first_one_to_MSB(clock)}; // which clock region is valid
	clock_use_extended = {(clock_use & (~clock)), clock_use}; // set the use bit of clock in the second comparison 0, make sure the clock is chosen if everyone's use bit is 1

	clock_evicted_extended = (~clock_use_extended) & clock_extended_prefix_sum;
	evicted_block_mask = clock_evicted_extended_LSB[2*ASSOCIATIVITY-1:ASSOCIATIVITY] | clock_evicted_extended_LSB[ASSOCIATIVITY-1:0];

	clock_use_reset_region_extended = clock_evicted_extended_prefix_sum ^ clock_extended_prefix_sum;
	clock_use_reset_region = clock_use_reset_region_extended[2*ASSOCIATIVITY-1:ASSOCIATIVITY] | clock_use_reset_region_extended[ASSOCIATIVITY-1:0];
	clock_use_if_evict = (clock_use & (~clock_use_reset_region)) | evicted_block_mask;

end

endmodule
`endif
