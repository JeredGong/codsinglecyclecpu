`include "xgriscv_defines.v"

module xgriscv_tb();

    reg                  clk, rstn;
    wire[`ADDR_SIZE-1:0] pc;

    // instantiation of xgriscv_sc
    xgriscv_sc xgriscv(clk, rstn, pc);

    integer counter = 0;

    initial begin
        // input instruction for simulation
        $readmemh("./testbenchcode/riscv32_sim7.hex", xgriscv.U_imem.RAM);
        clk = 1;
        rstn = 1;
        #5 ;
        rstn = 0;  // Active low reset
    end
    
    always begin
        #(50) clk = ~clk;

        if (clk == 1'b1) begin
            counter = counter + 1;

            // Display the current program counter and any relevant data
            $display("Time: %t, PC: %h", $time, pc);

            // Simple check to stop simulation if it reaches a known program end or runs too long
            if (pc == 32'h80000078 || counter > 100) begin
                $display("Simulation stopped at PC = %h", pc);
                $stop;
            end
        end
        
    end //end always

endmodule
