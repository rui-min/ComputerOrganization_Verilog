// compile with: iverilog -y ./hrLib/ LabN2Other.v cpu.v
module labN2;
    wire [31:0] PCin;
    reg RegWrite, MemRead, MemWrite, Mem2Reg, clk, ALUSrc, INT;
    reg [31:0] entryPoint;
    reg [2:0] op;

    wire [31:0] wd, rd1, rd2, imm, ins, PCp4, z, wb, PC;
    wire [31:0] jTarget, branch, memOut;
    wire zero, isbranch, isjump, isStype, isRtype, isItype, isLw;
    wire [6:0] opCode;

    yIF myIF(ins, PC, PCp4, PCin, clk);
    yID myID(rd1, rd2, imm, jTarget, branch, ins, wd, RegWrite, clk);
    yEX myEx(z, zero, rd1, rd2, imm, op, ALUSrc);
    yDM myDM(memOut, z, rd2, clk, MemRead, MemWrite);
    yWB myWB(wb, z, memOut, Mem2Reg);
    assign wd = wb;

    yPC myPC(PCin, PC, PCp4, INT, entryPoint, imm, jTarget, zero, isbranch, isjump);
    yC1 myC1(isStype, isRtype, isItype, isLw, isjump, isbranch, opCode);
    assign opCode = ins[6:0];

    initial begin
        //--------------------------------Entry point
        entryPoint = 16'h28; INT = 1; #1;
        //--------------------------------Run program
        repeat (43)
        begin
            //----------------------------Fetch an ins
            clk = 1; #1;
            INT = 0;
            // Temporally set
            RegWrite = 0;
            ALUSrc = 1;
            MemRead = 0;
            MemWrite = 0;
            Mem2Reg = 0;
            op = 3'b010;
            // Add statements to adjust the above defaults
            if(ins[6:0] == 7'h33) // R-Type
                begin
                    RegWrite = 1; ALUSrc = 0; MemRead = 0; MemWrite = 0; Mem2Reg = 0;
                    if(ins[14:12] == 3'b110)
                        op = 3'b001;
                end
            else if(ins[6:0] == 7'h6F) // UJ-Type
                begin
                    RegWrite = 1; ALUSrc = 1; MemRead = 0; MemWrite = 0; Mem2Reg = 0;
                end
            else if(ins[6:0] == 7'h3) // I-Type lw
                begin
                    RegWrite = 1; ALUSrc = 1; MemRead = 1; MemWrite = 0; Mem2Reg = 1;
                end
            else if(ins[6:0] == 7'h13) // I-Type addi
                begin
                    RegWrite = 1; ALUSrc = 1; MemRead = 0; MemWrite = 0; Mem2Reg = 0;
                end
            else if(ins[6:0] == 7'h23) // S-Type
                begin
                    RegWrite = 0; ALUSrc = 1; MemRead = 0; MemWrite = 1; Mem2Reg = 0;
                end
            else if(ins[6:0] == 7'h63) // SB-Type
                begin
                    RegWrite = 0; ALUSrc = 0; MemRead = 0; MemWrite = 0; Mem2Reg = 0;
                end
            //----------------------------Execute the ins
            clk = 0; #1;
            //----------------------------View results
            // display the following signals ins, rd1, rd2, imm, jTarget, z, zero
            $display("%h: rd1=%2d rd2=%2d exeOut=%3d zero=%b wb=%2d", ins, rd1, rd2, z, zero, wb);
            // Prepare for the next ins do nothing!
        end
        $finish;
    end
endmodule