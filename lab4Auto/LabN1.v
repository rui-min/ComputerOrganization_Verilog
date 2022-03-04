// test yIF~yDM,yWB modules in cpu.v
// compile with: iverilog -y ./hrLib/ LabN1.v cpuOld.v
// command: vvp a.out
module labN1;
    reg [31:0] PCin;
    reg RegWrite, clk, ALUSrc;
    reg MemRead, MemWrite, Mem2Reg, beq, jal; // new added for yDM, yWB
    reg [2:0] op;
    wire [31:0] wd, rd1, rd2, imm, ins, PCp4, z, jTarget, branch;
    wire [31:0] memOut, wb; // new added for yDM, yWB
    wire zero;
    reg [16*8:0] string = ""; // string for displaying type (max 16 chars)

    yIF myIF(ins, PCp4, PCin, clk);
    yID myID(rd1, rd2, imm, jTarget, branch, ins, wd, RegWrite, clk);
    yEX myEx(z, zero, rd1, rd2, imm, op, ALUSrc);
    yDM myDM(memOut, z, rd2, clk, MemRead, MemWrite);
    yWB myWB(wb, z, memOut, Mem2Reg);
    assign wd = wb;  // !!connect yWB output wb back to wd input of yID

    initial
    begin
        clk = 0;  #1;  // clock initialization
        //---------------------------------Entry point
        PCin = 16'h28;
        //---------------------------------Run program
        
        repeat (43)
        begin
            //-----------Fetch an ins by clk = 1 & stablize
            clk = 1; #1;
            //---------------------------------Set control signals
            RegWrite = 0; ALUSrc = 1; op = 3'b010; beq = 0; jal=0;
            // Add statements to adjust the above defaults
            if (ins[6:0] == 7'h33) // R-Type
            begin
                RegWrite = 1; ALUSrc = 0; MemRead=0; MemWrite=0;Mem2Reg=0;
                string = "R";
                if (ins[5:0] == 'h20)   op = 3'b010; //add
                if (ins[5:0] == 'h22)   op = 3'b110; //sub
                if (ins[5:0] == 'h24)   op = 3'b000; //AND
                if (ins[5:0] == 'h25)   op = 3'b001; //OR
            end
            else if (ins[6:0] == 7'h3) //I type lw
            begin
                RegWrite = 1; ALUSrc = 1; MemRead=1; MemWrite=0;Mem2Reg=1;
                string="I_lw";
                op = 3'b010;
            end
            else if (ins[6:0] == 7'h13) //I type addi
            begin
                RegWrite = 1; ALUSrc = 1; MemRead=0; MemWrite=0;Mem2Reg=0;
                string="I_xxi";
                op = 3'b010;
            end
            else if(ins[6:0] == 7'h6F) // UJ Type jump(jal)
            begin
                RegWrite = 1; ALUSrc = 1;
                string="UJ_jal";
                op = 3'b010; jal =1;
            end
            else if(ins[6:0] == 7'h23) // S-Type store
            begin
                RegWrite = 0; ALUSrc = 1; MemRead = 0; MemWrite = 1; Mem2Reg = 0;
                // Mem2Reg is don't care
                string="S_store";
                op = 3'b010;
            end
            else if(ins[6:0] == 7'h63) // SB-Type branching
            begin
                RegWrite = 0; ALUSrc = 0; MemRead = 0; MemWrite = 0; Mem2Reg = 0;
                // Mem2Reg is don't care
                string="SB_branch";
                op = 3'b010; beq = 1;
            end
            //------------------------initialize & execute
            clk = 0; #1;
            //------------------------------View results
            $display("%s-Type: ins(h)=%h rd1=%h rd2=%h imm(h)=%h jTarget=%h z=%h zero=%h wb=%h",
                         string, ins, rd1, rd2, imm, jTarget, z, zero, wb);
            //---------------------------------Prepare for the next ins
            if (beq && zero == 1)
                PCin = PCin + (imm << 1);   // NOT follow prelab, maybe typo in prelab
            else if (jal)
                PCin = PCin + (jTarget << 2);
            else
                PCin = PCp4;
        end
    $finish;
    end
endmodule