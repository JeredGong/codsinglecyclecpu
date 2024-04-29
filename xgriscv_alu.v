`include "xgriscv_defines.v"
module alu(
    input [`XLEN-1:0] ALUSource1,
    input [`XLEN-1:0] ALUSource2,
    input [3:0] ALUOp,
    output wire [`XLEN-1:0] ALUResult,
    output wire Zero
    );
// 定义操作码
// 定义操作码
localparam ADD  = 4'b0000;
localparam SUB  = 4'b0001;
localparam AND  = 4'b0010;
localparam OR   = 4'b0011;
localparam XOR  = 4'b0100;
localparam SLL  = 4'b0101;
localparam SRL  = 4'b0110;
localparam SRA  = 4'b0111;
localparam SLT  = 4'b1000;
localparam SLTU = 4'b1001;
localparam GE   = 4'b1010;
localparam GEU  = 4'b1011;

assign ALUResult = 
    (ALUOp == ADD)  ? ($unsigned(ALUSource1) + $unsigned(ALUSource2)) :
    (ALUOp == SUB)  ? ($unsigned(ALUSource1) - $unsigned(ALUSource2)) :
    (ALUOp == AND)  ? ($signed(ALUSource1) & $signed(ALUSource2)) :
    (ALUOp == OR)   ? ($signed(ALUSource1) | $signed(ALUSource2)) :
    (ALUOp == XOR)  ? ($signed(ALUSource1) ^ $signed(ALUSource2)) :
    (ALUOp == SLL)  ? ($signed(ALUSource1) << ALUSource2[4:0]) :
    (ALUOp == SRL)  ? ($signed(ALUSource1) >> ALUSource2[4:0]) :
    (ALUOp == SRA)  ? ($signed(ALUSource1) >>> ALUSource2[4:0]) :
    (ALUOp == SLT)  ? ($signed(ALUSource1) < $signed(ALUSource2) ? 32'b1 : 32'b0) :
    (ALUOp == SLTU) ? ($unsigned(ALUSource1) < $unsigned(ALUSource2) ? 32'b1 : 32'b0) :
    (ALUOp == GE)   ? ($signed(ALUSource1) >= $signed(ALUSource2) ? 32'b1 : 32'b0) :
    (ALUOp == GEU)  ? ($unsigned(ALUSource1) >= $unsigned(ALUSource2) ? 32'b1 : 32'b0) :
    0;  // 默认值

// 零标志输出
assign Zero = (ALUResult == 0);
endmodule
