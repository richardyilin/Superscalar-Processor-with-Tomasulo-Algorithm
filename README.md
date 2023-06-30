# Tomasulo Algorithm

## Table of contents

<!--ts-->
   * [Table of contents](#table-of-contents)
   * [Introduction](#introduction)
   * [Getting Started](#getting-started)
      * [Prerequisites](#prerequisites)
      * [Installation](#installation)
      * [Run the testbench](#run-the-testbench)
   * [Overview of the macros and the parameters](#overview-of-the-macros-and-the-parameters)
      * [Usage of macro](#usage-of-macro)
      * [Explanation of parameters](#explanation-of-parameters)
         * [Parameters that can be modified](#parameters-that-can-be-modified)
         * [Parameters that cannot be modified](#parameters-that-cannot-be-modified)
   * [Reference](#reference)
<!--te-->



## Introduction
 
   1. This project integrates a RISC-V processor with Tomasulo Algorithm and multilevel caches on a chip. Tomasulo Algorithm enables out-of-order execution with dynamic scheduling of instructions to improve instruction-level parallelism.
   2. Besides Tomasulo Algorithm, this project also adopts a correlating branch predictor and speculation on the processor to improve the performance.
 
## Getting Started
 
### Prerequisites
   This project is run with Icarus Verilog. The SystemVerilog code of this project follows IEEE Standard 1800-2005. To install Icarus Verilog, you can refer to its [installation guide](https://iverilog.fandom.com/wiki/Installation_Guide).
 
### Installation
 
   ```sh
   git clone https://github.com/richardyilin/Superscalar-Processor-with-Tomasulo-Algorithm.git
   ```
### Run the testbench
 
   ```sh
   cd Superscalar-Processor-with-Tomasulo-Algorithm/src/tb
   iverilog -g2005-sv -o wave tb_Chip.sv
   vvp -n wave -fst
   ```
   You can change the macro `hasHazard` in [`tb_Chip.sv`](./src/tb/tb_Chip.sv). The options of the macro are `hasHazard`, `BrPred`, `L2Cache`, `leaf`, `fact`, `recursion`. Each option corresponds to six different test cases in the folder [`test_cases`](./src/tb/test_cases).

## Overview of the macros and the parameters
### Usage of macro
 
   1. The macro of this project is in [Define.sv](./src/rtl/common/Define.sv). 
   2. The macro you can change (comment or uncomment) are `L2`, `SYNTHESIS`, and `BRANCH_PREDICTION`. 
   3. With the macro `L2`, caches on the chip are 2-level. Otherwise, there are only L1 caches. 
   4. With the macro `SYNTHESIS`, the code is synthesizable, otherwise it is for simulation only. 
   5. With the macro `BRANCH_PREDICTION`, the branch prediction is enabled, otherwise the processor always fetches the next instruction at the address of `PC + 4`.
 
### Explanation of parameters

   1. This design is fully parameterized. Thus, this design is very flexible and you can easily change its configuration by changing the parameters.  
   2. The parameters of this design are in [tb_Chip.sv](./src/tb/tb_Chip.sv).

#### Parameters that can be modified
   1. The following is an explanation of the parameters that you can modify.  
   2. `BW_ADDRESS`: The bit width of an address.  
   3. `BW_PROCESSOR_BLOCK`: The bit width of a block in the processor.  
   4. `L1_LATENCY`: The latency of the L1 cache.  
   5. `L1_ASSOCIATIVITY`: The associativity of the L1 cache.  
   6. `L1_NUM_SET`: The number of sets in the L1 cache.  
   7. `L1_BW_BLOCK `: The bit width of a block in the L1 cache.  
   8. `L2_LATENCY`: The latency of the L2 cache.  
   9. `L2_ASSOCIATIVITY`: The associativity of the L2 cache.  
   10. `L2_NUM_SET`: The number of sets in the L2 cache.  
   11. `L2_BW_BLOCK`: The bit width of a block in the L2 cache.  
   12. `MEMORY_LATENCY`: The latency of the main memory.  
   13. `MEMORY_SIZE`: The capacity of the main memory.  
   14. `BW_PROCESSOR_DATA`: The bit width of data in the processor.  
   15. `IQ_LENGTH`: The number of entries of the instruction queue.  
   16. `NUM_INT_RESERVATION_STATION`: The number of reservation stations for the integer unit.  
   17. `NUM_MUL_RESERVATION_STATION`: The number of reservation stations for the multiplier.  
   18. `NUM_LOAD_RESERVATION_STATION`: The number of reservation stations for the load unit.  
   19. `NUM_STORE_RESERVATION_STATION`: The number of reservation stations for the store unit.  
   20. `NUM_GLOBAL_HISTORY`: The number of most recent branches we use as global history.  
   21. `BW_SELECTED_PC`: The number of bits selected from the program counter to index the local history table.  
   22. `NUM_BTB`: The number of entries of the branch target buffer.  
   23. `AQ_LENGTH`: The number of entries of the address queue.  

#### Parameters that cannot be modified
   1. The following is an explanation of the parameters that cannot be modified (unless you want to change the design).  
   2. `BW_OPCODE_BRANCH`: The bit width of the opcode in the branch unit.  
   3. `BW_OPCODE_INT`: The bit width of the opcode in the integer unit.  
   4. `NUM_KINDS_OF_RESERVATION_STATION`: The number of kinds of reservation stations.  
   5. `NUM_KINDS_OF_UNIT`: The number of kinds of functional units.  

## Reference
   1. Hennessy, John L., and David A. Patterson. Computer architecture: a quantitative approach. Elsevier, 2011.  
   2. Yeh, Tse-Yu, and Yale N. Patt. "Two-level adaptive training branch prediction." Proceedings of the 24th annual international symposium on Microarchitecture. 1991.
