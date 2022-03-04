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