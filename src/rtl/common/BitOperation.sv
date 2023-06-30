`ifndef __BIT_OPERATION_SV__
`define __BIT_OPERATION_SV__

module FindFirstOneFromLsb #(parameter N = 4)(
	input [N-1:0] i_data,
	output logic [N-1:0] o_prefix_sum,
	output logic [N:0] o_position
);

always@(*) begin
	o_prefix_sum = i_data;
	for (int i = 1; i < N; i = (i << 1)) begin
		o_prefix_sum = o_prefix_sum | (o_prefix_sum << i);
	end
	o_position = {o_prefix_sum, 1'b0} ^ {1'b1, o_prefix_sum};
end
endmodule

module Onehot2Binary #(
	parameter N = 10
)(
	input [N-1:0] i_one_hot,
	output logic [$clog2(N)-1:0] o_binary
);

always@(*) begin
	o_binary = 'd0;
	for (int i = 0; i < N; i++) begin
		o_binary = o_binary | (i & {($clog2(N)){i_one_hot[i]}});
	end
end
endmodule

module RoundRobin#(
	parameter NUM_CANDIDATE = 5
)(
	input clk,
	input rst_n,

	input [NUM_CANDIDATE-1:0] i_valid,
	output [NUM_CANDIDATE:0] o_chosen, // MSB = 1 means no one is chosen

//----------If the chosen output is taken by the next stage----------
	input i_handshake
);

localparam BW_BINARY = $clog2(NUM_CANDIDATE);

logic [2*NUM_CANDIDATE:0] result_shift_right, result;
logic [2*NUM_CANDIDATE-1:0] valid_2x, valid_shift_right_2x;
logic [BW_BINARY-1:0] selected_binary, start_binary_w, start_binary;
logic [NUM_CANDIDATE-1:0] selected_mask, selected_mask_shift_right;

FindFirstOneFromLsb #(
	.N(2*NUM_CANDIDATE)
) u_ffl(
	.i_data(valid_shift_right_2x),
	.o_prefix_sum(),
	.o_position(result_shift_right)
);
Onehot2Binary #(
	.N(NUM_CANDIDATE)
) u_oh2b (
	.i_one_hot(selected_mask),
	.o_binary(selected_binary)
);
assign valid_2x = {2{i_valid}};
assign valid_shift_right_2x = valid_2x >> start_binary;
assign result = result_shift_right << start_binary;
assign selected_mask = (result[2*NUM_CANDIDATE-1:NUM_CANDIDATE] | result[NUM_CANDIDATE-1:0]);
assign o_chosen = {result_shift_right[2*NUM_CANDIDATE], selected_mask};

always @(*) begin
	if (start_binary == NUM_CANDIDATE - 1) begin
		start_binary_w = 'd0;
	end else begin
		start_binary_w = start_binary + 'd1;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		start_binary <= 'd0;
	end else if (i_handshake) begin
		start_binary <= start_binary_w;
	end
end
endmodule

`endif
