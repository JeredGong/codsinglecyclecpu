`include "xgriscv_defines.v"
module immgen(
    input [`INSTR_SIZE-1:0] instruction,
    output [`XLEN-1:0] imm
);
// I-type, S-type, B-type, U-type, J-type 的操作码定义
localparam OP_IMM  = 7'b0010011;  // I-type (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
localparam LOAD    = 7'b0000011;  // I-type (LW, LH, LB, LHU, LBU)
localparam STORE   = 7'b0100011;  // S-type (SW, SH, SB)
localparam BRANCH  = 7'b1100011;  // B-type (BEQ, BNE, BLT, BGE, BLTU, BGEU)
localparam LUI     = 7'b0110111;  // U-type (LUI)
localparam AUIPC   = 7'b0010111;  // U-type (AUIPC)
localparam JAL     = 7'b1101111;  // J-type (JAL)
localparam JALR    = 7'b1100111;  // I-type (JALR)

// 操作码位置
wire [6:0] opcode = instruction[6:0];

assign imm = 
    (opcode == OP_IMM || opcode == LOAD || opcode == JALR) ? 
        {{20{instruction[31]}}, instruction[31:20]} :  // I-type for immediate and load instructions
    (opcode == STORE) ? 
        {{20{instruction[31]}}, instruction[31:25], instruction[11:7]} :  // S-type for store instructions
    (opcode == BRANCH) ? 
        {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0} :  // B-type for branch instructions
    (opcode == LUI || opcode == AUIPC) ? 
        {instruction[31:12], 12'b0} :  // U-type for upper immediate
    (opcode == JAL) ? 
        {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0} :  // J-type for jump instructions
    32'b0;  // Default for unknown opcode
endmodule