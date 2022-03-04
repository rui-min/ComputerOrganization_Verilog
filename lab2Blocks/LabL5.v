// test 1-bit full adder
// compile by: iverilog LabL5.v yAdder1.v
module labL5 ();
    integer i,j,k;
    wire z,cout;
    reg a,b,cin;
    reg [1:0] expect;
    yAdder1 test5(z,cout,a,b,cin);
    initial begin
        for (i=0; i<2; i++)
        begin
            for (j=0; j<2; j++)
            begin
                for (k=0; k<2; k++)
                begin
                    a=i; b=j; cin=k;
                // !!Below two lines MUST be after the above two lines to ensure updated assignment
                    expect[0] = (a^b) ^ cin;
                    expect[1] = (a&b) | ( (a^b)&cin );
                    #4  // wait for z and cout
                    if (expect[0] === z && expect[1] === cout)
                        $display("PASS: a=%b b=%b cin=%b; z=%b cout=%b", a,b,cin, z, cout);
                    else
                        $display("FAIL: a=%b b=%b cin=%b; z=%b cout=%b", a,b,cin, z, cout);    
                end
                
            end
        end
    $finish;
    end
endmodule