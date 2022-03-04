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