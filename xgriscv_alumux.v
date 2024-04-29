`include "xgriscv_defines.v"
module alumux(
    input [`XLEN-1:0] rs2,
    input [`XLEN-1:0] imm,
    input ALUSrc,
    output wire [`XLEN-1:0] Srouce
);
assign Srouce = ALUSrc ? imm : rs2;  // ALUsrc为0则选择rs2，否则选择imm
endmodule