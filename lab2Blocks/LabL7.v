// 32-bits Adder "signed" test: check sum automatically and examine final cout manually
// "signed" will NOT affect PASS or FAIL because MSB is discarded due to 32 limit
// NOT an enhanced adder and cin=0 (always)
// compile by: iverilog LabL7.v yAdder.v yAdder1.v
module labL7 ();
    wire [31:0] z;  // 32 bits
    wire cout;
    reg cin = 0; // this is NOT an enhanced adder and only supports addition
    reg signed [31:0] a, b, expect;    // "signed" or not will NOT affect the result
    yAdder test7(z,cout,a,b,cin);
    initial begin
        repeat (10)
        begin
            a = $random;
            b = $random;
            // !!Below line MUST be after the above lines to ensure updated assignment
            expect = a + b + cin;

            #1;  // wait for z
            // compare z with the expected output
            if (expect === z)
                // $display("PASS: a=%b b=%b c=%b; z=%b; expect=%b", a,b,c, z, expect);
                // %d for decimal format to make outputs easier to read
                $display("PASS: a=%b b=%b cin=%d; z=%b; cout=%b", a,b,cin, z, cout);
            else
                $display("FAIL: a=%d b=%d cin=%d; z=%d; cout=%b", a,b,cin, z, cout); 
        end
    $finish;
    end
endmodule