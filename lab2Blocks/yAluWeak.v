// op=000: z=a AND b, op=001: z=a|b, op=010: z=a+b, op=110: z=a-b
// "slt" and "ex" NOT supported
// utilise yArith.v yMux.v yAdder.v yMux1.v yAdder1.v yMux4to1.v 
module yAluWeak (z, ex, a, b, op);
    input [31:0] a,b;
    input [2:0] op;
    output [31:0] z;
    output ex;

    wire [31:0] zAnd, zOr, zArith, slt;

    assign slt = 0; // not supported
    assign ex = 0; // not supported
    // instantiate the components and connect them
    and upper[31:0](zAnd,a,b);
    or mid[31:0](zOr,a,b);
    yArith low(zArith, cout, a, b, op[2]);
    yMux4to1 #(32) mux(z, zAnd, zOr, zArith, slt, op[1:0]);

endmodule