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