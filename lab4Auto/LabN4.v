// test yIF~yDM,yWB modules in cpu.v
// compile with: iverilog -y ./hrLib/ LabN4.v cpu.v
// command: vvp a.out
module labN4;
    wire [31:0] PCin;   // require changing PCin from reg to wire
    reg [31:0] entryPoint;  // new2!
    wire zero, isbranch, isjump, isStype, isRtype, isItype, isLw;  // new3!
    reg INT, clk;    // new2!
    wire RegWrite, ALUSrc, MemRead, MemWrite, Mem2Reg; // from reg to wire
    wire [2:0] op;      // new4 from reg to wire
    wire [6:0] opCode;   // new3!
    wire [1:0] ALUop;    // new4!
    wire [2:0] funct3;   // new4!

    wire [31:0] PC, branchImm,jImm; // new2!
    wire [31:0] wd, rd1, rd2, imm, ins, PCp4, z;
    wire [31:0] memOut, wb; // new added for yDM, yWB
    reg [16*8:0] string = ""; // string for displaying type (max 16 chars)

    yIF myIF(ins, PC, PCp4, PCin, clk);
    yID myID(rd1, rd2, imm, jImm, branchImm, ins, wd, RegWrite, clk);
    yEX myEx(z, zero, rd1, rd2, imm, op, ALUSrc);
    yDM myDM(memOut, z, rd2, clk, MemRead, MemWrite);
    yWB myWB(wb, z, memOut, Mem2Reg);
    assign wd = wb;  // !!connect yWB output wb back to wd input of yID

    yPC myPC(PCin, PC, PCp4,INT,entryPoint,branchImm,jImm,zero,isbranch,isjump);
    assign opCode = ins[6:0];
    yC1 myC1(isStype, isRtype, isItype, isLw, isjump, isbranch, opCode);
    yC2 myC2(RegWrite, ALUSrc, MemRead, MemWrite, Mem2Reg,
            isStype, isRtype, isItype, isLw, isjump, isbranch);
    yC3 myC3(ALUop, isRtype, isbranch);
    assign funct3=ins[14:12];
    yC4 myC4(op, ALUop, funct3);

    initial
    begin
        // clk = 0;  #1;  // clock initialization
        //---------------------------------Entry point
        entryPoint = 16'h28;  INT = 1; #1; // int=1 to let initial in
        //---------------------------------Run program
        
        repeat (43) // 43 according to ram.dat file
        begin
            //-----------Fetch an ins by clk = 1 & stablize
            clk = 1; #1; INT = 0;
            //---------------------------------Set control signals empty!
            //------------------------initialize & execute
            clk = 0; #1;
            //------------------------------View results
            $display("ins(h)=%h rd1=%h rd2=%h imm(h)=%h jImm=%h z=%h zero=%h wb=%h",
                         ins, rd1, rd2, imm, jImm, z, zero, wb);
            //---------------------------------Prepare for the next ins
            // !!! do NOthing because next address is automated inside cpu !!!
        end
    $finish;
    end
endmodule