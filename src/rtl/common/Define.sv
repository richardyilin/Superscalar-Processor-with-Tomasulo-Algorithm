`ifndef __DEFINE_SV__
`define __DEFINE_SV__
`define L2
// `define SYNTHESIS
`define BRANCH_PREDICTION
`define BYTE 8
`define BW_BYTE 3

`define valid_input(name) input name``_valid
`define valid_output(name) output logic name``_valid
`define valid_logic(name) logic name``_valid
`define valid_connect(port, name) .port``_valid(name``_valid)

`define valid_ready_input(name) input name``_valid, output logic name``_ready
`define valid_ready_output(name) output logic name``_valid, input name``_ready
`define valid_ready_logic(name) logic name``_valid, name``_ready
`define valid_ready_connect(port, name) .port``_ready(name``_ready), .port``_valid(name``_valid)
`define valids_readies_input(name, N) input [N-1:0] name``_valid , output logic [N-1:0] name``_ready
`define valids_readies_output(name, N) output logic [N-1:0] name``_valid, input [N-1:0] name``_ready
`define valids_readies_logic(name, N) logic [N-1:0] name``_valid , name``_ready
`define handshake(name) name``_valid && name``_ready

`define LOAD_STORE 0
`define BRANCH 1
`define INT 2
`define MUL 3

`define LOAD 0
`define STORE 1

`define ADD 0
`define MINUS 1
`define SLT 2
`define XOR 3
`define OR 4
`define AND 5
`define SLLI 6
`define SRAI 7
`define SRLI 8
`define AUIPC 9

`define JAL 0
`define JALR 1
`define BEQ 2
`define BNE 3
`define BGE 4

`endif
