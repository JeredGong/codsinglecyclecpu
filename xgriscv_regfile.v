`include "xgriscv_defines.v"

module regfile(
  input                      	clk, //时钟
  input  [`RFIDX_WIDTH-1:0]  	ra1, ra2,  // 输入读取地址1，2
  output [`XLEN-1:0]          rd1, rd2,  // 输出读取数据1，2

  input                      	we3,       // 写使能信号
  input  [`RFIDX_WIDTH-1:0]  	wa3,       // 输入写寄存器地址
  input  [`XLEN-1:0]          wd3        // 输入写数据
  );

  reg [`XLEN-1:0] rf[`RFREG_NUM-1:0];

  // three ported register file
  // read two ports combinationally
  // write third port on falling edge of clock
  // register 0 hardwired to 0
  integer i;
  initial begin
        for(i=0;i<=31;i=i+1)
            rf[i] =0;
  end
  always @(negedge clk)
    if (we3&&(wa3!=0))
      begin
        rf[wa3] <= wd3;
        // DO NOT CHANGE THIS display LINE!!!
        // 不要修改下面这行display语句！！！
        /**********************************************************************/
        $display("x%d = %h", wa3, wd3);
        /**********************************************************************/
      end

  assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
  assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
endmodule
