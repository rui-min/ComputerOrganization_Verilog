/* vvp a.out +a=1 +b=1" to adjust a & b */
module labK;

reg a, b, flag;    // reg without size means 1-bit (default 'x')
wire notOutput, lowerInput, z;
// tmp is an output; b is an input
not my_not(notOutput, b);
// z output; a, tmp are inputs
and my_and(z, a, lowerInput);
assign lowerInput = notOutput;

initial begin
    flag = $value$plusargs("a=%b", a);
    flag = $value$plusargs("b=%b", b);
    #1 $display("a=%b b=%b z=%b", a, b, z);
    $finish;
end
    
endmodule   // labK