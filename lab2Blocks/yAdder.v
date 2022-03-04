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