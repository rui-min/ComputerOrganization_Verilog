/* CPU contains modules: yMux1, yMux, yMux4to1, yAdder1, yAdder, yArith, yAlu */

// The 2-to-1 Multiplexer The multiplexer act as an if statement: if c = 0 then z would be a.
// Otherwise z would be b. 
// library module without initial
module yMux1(z,a,b,c);
    output z;
    input a, b, c;
    wire notC, upper, lower;
    not my_not(notC, c);
    and upperAnd(upper, a, notC);
    and lowerAnd(lower, c, b);
    or my_or(z, upper, lower);
    
endmodule

// a generic 2to1 mux with single-bit signal c
// if c = 0 then a, otherwise b
module yMux(z, a, b, c);
    parameter SIZE = 2;
    output [SIZE-1:0] z;
    input [SIZE-1:0] a, b;
    input c;
    yMux1 mine[SIZE-1:0](z, a, b, c);
endmodule

// a generic 4to1 mux with 2-bits signal c
module yMux4to1(z, a0,a1,a2,a3, c);
    parameter SIZE = 2;
    output [SIZE-1:0] z;
    input [SIZE-1:0] a0, a1, a2, a3;
    input [1:0] c;
    wire [SIZE-1:0] zLo, zHi;
    yMux #(SIZE) lo(zLo, a0, a1, c[0]);
    yMux #(SIZE) hi(zHi, a2, a3, c[0]);
    yMux #(SIZE) final(z, zLo, zHi, c[1]);
endmodule

// The 1-bit full adder
// if cin is zero then z is nothing but the sum of a and b with a carry of cout.
// library module without initial
module yAdder1 (z, cout, a, b, cin);
    output z, cout;
    input a,b,cin;
    // !!! NO need to declare shared names if no "initial"
    xor left_xor(tmp, a,b);
    xor right_xor(z, cin, tmp);
    and left_and(outL, a, b);
    and right_and(outR, tmp, cin);
    or my_or(cout, outR, outL);
    
endmodule

// The 32-bits full adder
// if cin is zero then z is nothing but the sum of a and b with a carry of cout.
// library module without initial
module yAdder (z,cout,a,b,cin);
    output [31:0] z;
    output cout;
    input [31:0] a,b;
    input cin;
    // interconnects
    wire[31:0] in, out;

    yAdder1 mine[31:0](z,out,a,b,in);
    assign in[0] = cin;
    assign in[31:1] = out[30:0];
    assign cout = out[31];   // my extra line to get final carryout

endmodule

// The 32-bits enhanced adder
// add if ctrl =0, substract if ctrl=1
// library module without initial
// utilise yMux.v yAdder.v yMux1.v yAdder1.v
module yArith (z, cout, a, b, ctrl);
    // add if ctrl =0, substract if ctrl=1
    output [31:0] z;
    output cout;
    input [31:0] a,b;
    input ctrl;
    wire [31:0] notB, tmp;
    wire cin;
    // instantiate the components and connect them
    assign cin = ctrl;
    not my_not[31:0](notB, b);
    // Mux: if cin==0, tmp=b; if cin==1, tmp=notB
    yMux #(32) mux(tmp, b, notB, cin);
    // !! if cin==0, tmp=b & z=a+b+0; 
    // !! if cin==1, tmp=notB & z=a+notB+1=a-b;
    yAdder my_add(z, cout, a, tmp, cin);

endmodule   // yArith

// op=000: z=a AND b, op=001: z=a|b, op=010: z=a+b, op=110: z=a-b
// utilise yArith.v yMux.v yAdder.v yMux1.v yAdder1.v yMux4to1.v 
module yAlu (z, ex, a, b, op);
    input [31:0] a,b;
    input [2:0] op;
    output [31:0] z;
    output ex;
    wire [31:0] zAnd, zOr, zArith, slt, tmp;
    wire [15:0] z16;
    wire [7:0] z8;
    wire [3:0] z4;
    wire [1:0] z2;
    wire z0, z1;    // optional declaration

    // ex ('or' all bits of z, then 'not' the result)
    // zero flag by divide and conquer manner
    or or16[15:0](z16, z[15:0],z[31:16]);
    or or8[7:0](z8, z16[7:0], z16[15:8]);
    or or4[3:0](z4, z8[3:0], z8[7:4]);
    or or2[1:0](z2, z4[1:0], z4[3:2]);
    or or1(z1, z2[1], z2[0]);
    not my_not(z0, z1);
    assign ex = z0;

    assign slt[31:1] = 0; // upper bits are always 0
    // instantiate a circuit to set slt[0]
    // if a[31]!=b[31] 1(true); else 0(false)
    xor (condition, a[31], b[31]);
    yArith slt_arith(tmp, cout, a, b, 1'b1); // tmp=a-b
    // condition==0, tmp[31]; condition==1, a[31]
    yMux #(.SIZE(1)) slt_mux(slt[0], tmp[31], a[31], condition);
    
    // instantiate the components and connect them
    and upper[31:0](zAnd,a,b);
    or mid[31:0](zOr,a,b);
    yArith low(zArith, cout, a, b, op[2]);
    yMux4to1 #(32) mux(z, zAnd, zOr, zArith, slt, op[1:0]);

endmodule

// circuit for Instruction Fetch(IF)
module yIF(ins, PC, PCp4, PCin, clk);
    output [31:0] ins, PC, PCp4;
    input [31:0] PCin;
    input clk;
    
    wire zero;
    wire read, write, enable;
    wire [31:0] a, memIn;
    wire [2:0] op;
    
    register #(32) pcReg(PC, PCin, clk, enable);
    mem insMem(ins, PC, memIn, clk, read, write);
    yAlu myAlu(PCp4, zero, a, PC, op);
    
    assign enable = 1'b1;
    assign a = 32'h0004;
    assign op = 3'b010;
    assign read = 1'b1;
    assign write = 1'b0;
endmodule

// circuit for instruction decoder(ID)
module yID(rd1, rd2, immOut, jTarget, branch, ins, wd, RegWrite, clk);
    output[31:0] rd1, rd2, immOut;
    output[31:0] jTarget, branch;
    input [31:0] ins, wd;
    input RegWrite, clk;

    wire [19:0] zeros, ones;  // for I-type and SB-type
    wire [11:0] zerosj, onesj;  // for UJ-type
    wire [31:0] imm, saveImm;  // for S-type
    // decode to send to rd1, rd2
    rf myRF(rd1, rd2, ins[19:15], ins[24:20],ins[11:7],wd,clk,RegWrite);
    
    // imm for I-type, UJ-type?
    assign imm[11:0] = ins[31:20];
    assign zeros = 20'h00000;
    assign ones = 20'hFFFFF;
    yMux #(20) se(imm[31:12], zeros, ones, ins[31]);  //sign select
    
    // imm for S-type, SB-type
    assign saveImm[11:5] = ins[31:25];
    assign saveImm[4:0] = ins[11:7];
    yMux #(20) saveImmSe(saveImm[31:12], zeros, ones, ins[31]);  // sign
    
    // select 1 of above imms through ins[5]
    yMux #(32) immSelection(immOut, imm, saveImm, ins[5]);

    //...
    assign branch[11] = ins[31];
    assign branch[10] = ins[7];
    assign branch[9:4] = ins[30:25];
    assign branch[3:0] = ins[11:8];
    yMux #(20) bra(branch[31:12], zeros, ones, ins[31]); // sign

    assign zerosj = 12'h000;
    assign onesj = 12'hFFF;
    assign jTarget[19] = ins[31];
    assign jTarget[18:11] = ins[19:12];
    assign jTarget[10] = ins[20];
    assign jTarget[9:0] = ins[30:21];
    yMux #(12) jum(jTarget[31:20], zerosj, onesj, jTarget[19]); // sign

endmodule

// circuit for instruction execution
module yEX(z, zero, rd1, rd2, imm, op, ALUSrc);
    output [31:0] z;
    output zero;
    input [31:0] rd1, rd2, imm;
    input [2:0] op;
    input ALUSrc;

    wire [31:0] muxOut;

    yMux #(32) regORimm(muxOut,rd2,imm,ALUSrc);
    yAlu myAlu(z, zero, rd1, muxOut, op); 

endmodule

module yDM(memOut, exeOut, rd2, clk, MemRead, MemWrite);
    output [31:0] memOut;
    input [31:0] exeOut, rd2;
    input clk, MemRead, MemWrite;

    mem DM(memOut, exeOut, rd2, clk, MemRead, MemWrite);
    
endmodule

module yWB(wb, exeOut, memOut, Mem2Reg);
    output [31:0] wb;
    input [31:0] exeOut, memOut;
    input Mem2Reg;

    yMux #(32) mux(wb, exeOut, memOut, Mem2Reg);

endmodule


module yPC(PCin, PC, PCp4,INT,entryPoint,branchImm,jImm,zero,isbranch,isjump);
    output [31:0] PCin;
    input [31:0] PC, PCp4, entryPoint, branchImm;
    input [31:0] jImm;
    input INT, zero, isbranch, isjump;
    wire [31:0] branchImmX4, jImmX4, jImmX4PPCp4, bTarget, choiceA, choiceB;
    wire doBranch, zf;
    // Shifting left branchImm twice
    assign branchImmX4[31:2] = branchImm[29:0];
    assign branchImmX4[1:0] = 2'b00;
    // Shifting left jump twice
    assign jImmX4[31:2] = jImm[29:0];
    assign jImmX4[1:0] = 2'b00;
    // adding PC to shifted twice,
    // !!! should be "PC" below instead of "PCp4" !!!
    yAlu bALU(bTarget, zf, PC, branchImmX4, 3'b010);  //010 for add
    
    // adding PC to shifted twice, jImm
    // !!! should be "PC" below instead of "PCp4" !!!
    yAlu jALU(jImmX4PPCp4, zf, PC, jImmX4, 3'b010);   //010 for add
    // deciding to do branch
    and (doBranch, isbranch, zero);
    yMux #(32) mux1(choiceA, PCp4, bTarget, doBranch);
    yMux #(32) mux2(choiceB, choiceA, jImmX4PPCp4, isjump);
    yMux #(32) mux3(PCin, choiceB, entryPoint, INT);
endmodule

// opCode
// 2. lw       0000011
// 3. I-Type   0010011
// 4. R-Type   0110011
// 5. SB-Type  1100011
// 15.UJ-Type  1101111
// 3. S-Type   0100011
module yC1(isStype, isRtype, isItype, isLw, isjump, isbranch, opCode);
    
    output isStype, isRtype, isItype, isLw, isjump, isbranch;
    input [6:0] opCode;
    wire lwor, ISselect, JBselect, sbz, sz;

    // Detect UJ-type
    assign isjump=opCode[3];

    // Detect lw
    or (lwor, opCode[6], opCode[5], opCode[4], opCode[3], opCode[2]); not(isLw, lwor);

    // Select between S-type and I-type
    // below find S&I common op digits
    xor (ISselect, opCode[6],opCode[3],opCode[2],opCode[1],opCode[0]);
    // below check different digits
    and (isStype, ISselect, opCode[5]);
    and (isItype, ISselect, opCode[4]);

    // Detect R-Type
    and (isRtype, opCode[5], opCode[4]);

    // Select between JAL and Branch
    and (JBselect, opCode[6], opCode[5]); // SB and UJ are the only ones with bits 5 and 6
    not (sbz, opCode[3]);   // SB has 0 in bits 2 and 3
    and (isbranch, JBselect, sbz);

endmodule

    // ALUSrc is 1 for I-Type and sw and UJ
    // Mem2Reg is 1 for lw
    // RegWrite is 1 for R-format and lw and UJ
    // MemRead is 1 for lw
    // MemWrite is 1 for sw
module yC2(RegWrite, ALUSrc, MemRead, MemWrite, Mem2Reg,
            isStype, isRtype, isItype, isLw, isjump, isbranch);

    output RegWrite, ALUSrc, MemRead, MemWrite, Mem2Reg;
    input isStype, isRtype, isItype, isLw, isjump, isbranch;
    // gates & assignments
    //or ALUsrc_or(ALUSrc, isItype, isStype, isjump);
    //or RegWrite_or(RegWrite, isRtype, isLw, isjump);
    // the code below from one of the GitHubs worked better than my own lol
    nor (ALUSrc, isRtype, isbranch);    // 0 - do calculation; 1 - add immediate
    nor (RegWrite, isStype, isbranch);  // need to write to a register

    assign Mem2Reg = isLw;
    assign MemRead = isLw;
    assign MemWrite = isStype;

endmodule

// I-lw 00; I-addi 00; S-sw 00
// SB-beq 01; UJ-jal-xx; R-add 10(opration unknown)
module yC3(ALUop, isRtype, isbranch);    
    output [1:0] ALUop;
    input isRtype, isbranch;
    assign ALUop[1] = isRtype;
    assign ALUop[0] = isbranch;
endmodule

//ALUop Funct3  op
//00    xxx     010
//01    xxx     110
//10    111     000
//10    110     001
//10    000     010
module yC4 (op, ALUop, funct3);
    output [2:0] op;
    input [2:0] funct3;
    input [1:0] ALUop;
    // instantiate and connect

    xor (leftup,funct3[2],funct3[1]);
    xor (leftdown,funct3[1],funct3[0]);

    and (midup, ALUop[1], leftup);
    or (op[2], ALUop[0], midup);
    
    not (op1up, ALUop[1]);
    not (op1down, funct3[1]);
    or (op[1], op1up, op1down);

    and (op[0], ALUop[1], leftdown);

    // assign op[2] = ALUop[0]; // op[2]
    // // op[1]
    // nand (temp1, ALUop[1], funct[1]);
    // assign op[1] = temp1;
    // // op[0]
    // and (temp2, ALUop[1], funct[0]);
    // and (temp3, ALUop[1], funct[1]);
    // xor (temp4, temp2, temp3);
    // assign op[0] = temp4;
endmodule

module yChip(ins, rd2, wb, entryPoint, INT, clk);
    output [31:0] ins, rd2, wb;
    input [31:0] entryPoint;
    input INT, clk;

    wire [31:0] PCin;   // require changing PCin from reg to wire
    wire zero, isbranch, isjump, isStype, isRtype, isItype, isLw;  // new3!
    wire RegWrite, ALUSrc, MemRead, MemWrite, Mem2Reg; // from reg to wire
    wire [2:0] op;      // new4 from reg to wire
    wire [6:0] opCode;   // new3!
    wire [1:0] ALUop;    // new4!
    wire [2:0] funct3;   // new4!

    wire [31:0] PC, branchImm,jImm; // new2!
    wire [31:0] wd, rd1, rd2, imm, ins, PCp4, z;
    wire [31:0] memOut, wb; // new added for yDM, yWB

    // below in real order
    yPC myPC(PCin, PC, PCp4,INT,entryPoint,branchImm,jImm,zero,isbranch,isjump);
    
    yIF myIF(ins, PC, PCp4, PCin, clk);
    
    assign opCode = ins[6:0];
    yC1 myC1(isStype, isRtype, isItype, isLw, isjump, isbranch, opCode);
    yC2 myC2(RegWrite, ALUSrc, MemRead, MemWrite, Mem2Reg,
            isStype, isRtype, isItype, isLw, isjump, isbranch);
    yC3 myC3(ALUop, isRtype, isbranch);
    assign funct3=ins[14:12];
    yC4 myC4(op, ALUop, funct3);

    yID myID(rd1, rd2, imm, jImm, branchImm, ins, wd, RegWrite, clk);
    yEX myEx(z, zero, rd1, rd2, imm, op, ALUSrc);
    yDM myDM(memOut, z, rd2, clk, MemRead, MemWrite);
    yWB myWB(wb, z, memOut, Mem2Reg);
    assign wd = wb;  // !!connect yWB output wb back to wd input of yID

endmodule