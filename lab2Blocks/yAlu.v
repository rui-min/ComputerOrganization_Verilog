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