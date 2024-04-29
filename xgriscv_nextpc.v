`include "xgriscv_defines.v"
module nextpc(
    input Branch,
    input Jump,
    input [`INSTR_SIZE-1:0] currentpc,
    input [`INSTR_SIZE-1:0] imm,
    input [2:0] funct3,
    input [6:0] opcode,
    input [`XLEN-1:0] ALUresult,
    input [4:0] rs1,
    output wire [`XLEN-1:0] next_pc,
    output wire [`XLEN-1:0] pcW

);
assign pcW = currentpc;
// 先对分支条件进行判断，写成组合逻辑
// 1. beq
wire BEQ_Taken = (funct3 == 3'b000)&&(ALUresult == 0);
// 2. bne
wire BNE_Taken = (funct3 == 3'b001)&&(ALUresult != 0);
// 3. blt
wire BLT_Taken = (funct3 == 3'b100)&&(ALUresult == 32'b1);
// 4. bge
wire BGE_Taken = (funct3 == 3'b101)&&(ALUresult == 32'b1);
// 5.bltu
wire BLTU_Taken = (funct3 == 3'b110)&&(ALUresult == 32'b1);
// 6.bgeu
wire BGEU_Taken = (funct3 == 3'b111)&&(ALUresult == 32'b1);
//组合起来，判断分支到底有没有被执行
wire Branch_Taken =(Branch)&&(BEQ_Taken || BNE_Taken || BLT_Taken || BGE_Taken || BLTU_Taken || BGEU_Taken);

//再对跳转的地址进行计算
// 1. jal
wire JAL_Taken = (Jump)&&(opcode == 7'b1101111);
// 2. jalr
wire JALR_Taken = (Jump)&&(opcode == 7'b1100111);

//考虑auipc指令
wire AUIPC_Taken = (opcode == 7'b0010111);
//计算下一次的地址
assign next_pc = (Branch_Taken) ? (currentpc + imm) :
                (JAL_Taken) ? (currentpc + imm) :
                (JALR_Taken) ? (U_regfile.rf[rs1]+ imm) :
                (currentpc + 4);
endmodule