`include "xgriscv_defines.v"
module decoder(
    input [`INSTR_SIZE-1:0] instruction,
    output [6:0] opcode,
    output [6:0] funct7,
    output [2:0] funct3,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd
);
assign opcode = instruction[6:0];
assign funct7 = instruction[31:25];
assign funct3 = instruction[14:12];
assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];
assign rd = instruction[11:7];
endmodule