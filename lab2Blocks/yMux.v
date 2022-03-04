// a generic 2to1 mux with single-bit signal c
// if c = 0 then a, otherwise b
module yMux(z, a, b, c);
    parameter SIZE = 2;
    output [SIZE-1:0] z;
    input [SIZE-1:0] a, b;
    input c;
    yMux1 mine[SIZE-1:0](z, a, b, c);
endmodule