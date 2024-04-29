`include "xgriscv_defines.v"
module CPU(
    input clk,
    input rstn,
    input [`INSTR_SIZE:0] instr,
    input [`XLEN:0] read_data,
    output memwrite,
    output [`ADDR_SIZE:0] pc,
    output [`ADDR_SIZE:0] addr,
    output [`XLEN:0] write_data,
    output [`XLEN:0] pcW
);
//1.将取到的指令译码，并得出控制信号

// 译码器的实例化
wire [6:0]opcode;
wire [6:0]funct7;
wire [2:0]funct3;
wire [4:0] rs1; //读取的寄存器地址1
wire [4:0] rs2; //读取的寄存器地址2
wire [4:0] rd;  //写入的寄存器地址

decoder U_decoder(
    .instruction(instr),
    .opcode(opcode),
    .funct7(funct7),
    .funct3(funct3),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd)
);
//控制信号
wire ALUSrc;
wire MemtoReg;
wire MemWrite;
wire RegWrite;
wire MemRead;
wire Branch;
wire Jump;
wire [1:0] preAluop; //ALUControl的输入信号，一个预制的信号。
wire [2:0] WriteBackSel; //用于选择写回寄存器的值
control U_control(
    .Opcode(opcode),
    .ALUSrc(ALUSrc),
    .MemtoReg(MemtoReg),
    .RegWrite(RegWrite),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .Branch(Branch),
    .jump(Jump),
    .Aluop(preAluop),
    .WriteBackSel(WriteBackSel)
);
// ALUControl的信号
wire [3:0] ALUOP ;
alucontrol U_alucontrol(
    .PreALUop(preAluop),
    .funct7(funct7),
    .funct3(funct3),
    .ALUop(ALUOP)
);
// RegFile模块的实例化
wire [31:0] rs1_data; //读取的数据 来自寄存器文件的输出1
wire [31:0] rs2_data; //读取的数据 来自寄存器文件的输出2
wire [31:0] write_reg_data; //写入的数据
regfile U_regfile(
    .clk(clk),
    .ra1(rs1),
    .ra2(rs2),
    .wa3(rd),
    .wd3(write_reg_data),
    .we3(RegWrite),
    .rd1(rs1_data),
    .rd2(rs2_data)    
);
// 立即数的生成
wire [`XLEN:0] imm;
immgen U_immgen(
    .instruction(instr),
    .imm(imm)
);

// 2.执行 EXE阶段
// ALUSrc的选择，使用alumux模块
wire [`XLEN:0] Srouce;
alumux U_alumux(
    .rs2(rs2_data),
    .imm(imm),
    .ALUSrc(ALUSrc),
    .Srouce(Srouce)
);
//ALU模块的实例化
wire [`XLEN:0] ALUout;//ALU的输出
wire Zero;  //ALU的零标志
alu U_alu(
    .ALUSource1(rs1_data),
    .ALUSource2(Srouce),
    .ALUOp(ALUOP),
    .ALUResult(ALUout),
    .Zero(Zero)
);


//计算下一次的pc，使用nextpc模块
wire [`ADDR_SIZE:0] next_pc; //保存下一次PC的值
PC U_PC(
    .clk(clk),
    .rstn(rstn),
    .NPC(next_pc),
    .PC(pc)
);   //计算下次执行时的pc值
nextpc U_nextpc(
    .Branch(Branch),
    .Jump(Jump),
    .currentpc(pc),
    .imm(imm),
    .funct3(funct3),
    .opcode(opcode),
    .rs1(rs1),
    .ALUresult(ALUout),
    .next_pc(next_pc),
    .pcW(pcW)
);    //计算下一条PC的值
// 3.访存阶段
    //mem的地址，由ALU计算得出
    assign addr=ALUout;
    //输入Mem的数据，store指令时，用第二个读端口读出来的数据
    assign write_data=rs2_data;
    //使能信号
    assign memwrite = MemWrite;

// 4.写回阶段，首先根据控制信号选择写入的数据
writebackMux U_writebackMux(
    .WriteBackSel(WriteBackSel),
    .aluout(ALUout),
    .imm(imm),
    .memout(read_data),
    .PC_out(pc),
    .write_reg_data(write_reg_data)
);

endmodule