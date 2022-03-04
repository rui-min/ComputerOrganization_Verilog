/* display ram.dat (machine code) execution part
    displays memory content in a format that is instruction-aware */
// compile with: iverilog -y ./hrLib/ LabM6.v
// command: vvp a.out
module labM6;
    reg clk, read, write;
    reg [31:0] address, memIn;
    wire [31:0] memOut;
    mem data(memOut, address, memIn, clk, read, write);

    initial
    begin
        // !!from ram.dat(and RISC-V code), program starts at 0x28
        address = 16'h28; write = 0; read = 1; 
        repeat (11) begin
            #1; 
            // below use least 7 bits to detect instruction types
            if (memOut[6:0] == 7'h33)   // R-type
                $display("R-type: f7=%h, rs2=%h, rs1=%h, f3=%h, rd=%h, op=%h", 
                memOut[31:25], memOut[24:20], memOut[19:15], memOut[14:12], memOut[11:7], memOut[6:0]);
            else if (memOut[6:0] == 7'h3 || memOut[6:0]== 7'h13)   // I-type
                $display("I-type: imm=%h, rs1=%h, f3=%h, rd=%h, op=%h", 
                memOut[31:20], memOut[19:15], memOut[14:12], memOut[11:7], memOut[6:0]);
            else if (memOut[6:0] == 7'h23)   // S-type
                $display("S-type: imm7=%h, rs2=%h, rs1=%h, f3=%h, imm5=%h, op=%h", 
                memOut[31:25], memOut[24:20], memOut[19:15], memOut[14:12], memOut[11:7], memOut[6:0]);
            else if (memOut[6:0] == 7'h63)   // SB-type
                $display("SB-type: imm(1)=%h, rs2=%h, rs1=%h, f3=%h, imm(2)=%h, op=%h", 
                memOut[31:25], memOut[24:20], memOut[19:15], memOut[14:12], memOut[11:7], memOut[6:0]);
            else if (memOut[6:0] == 7'h6f)   // UJ-type
                $display("UJ-type: imm20=%h, rd=%h, op=%h", 
                memOut[31:12], memOut[11:7], memOut[6:0]);
            
            address = address + 4;  // increase PC by 4
        end
    $finish;
    end
endmodule