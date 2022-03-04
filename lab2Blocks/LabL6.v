// 32-bits Adder testing: Only check sum by fixing cin =0
// compile by: iverilog LabL6.v yAdder.v yAdder1.v
module labL6 ();
    wire [31:0] z;  // 32 bits
    wire cout;
    reg cin;
    reg [31:0] a, b, expect;    // 32 bits
    yAdder test6(z,cout,a,b,cin);
    initial begin
        repeat (10)
        begin
            a = $random;
            b = $random;
            cin = 0;
            // !!Below line MUST be after the above lines to ensure updated assignment
            expect = a + b + cin;

            #1;  // wait for z
            // compare z with the expected output
            if (expect === z)
                // $display("PASS: a=%b b=%b c=%b; z=%b; expect=%b", a,b,c, z, expect);
                // %d for decimal format to make outputs easier to read
                $display("PASS: a=%d b=%d cin=%d; z=%b; cout=%b", a,b,cin, z, cout);
            else
                $display("FAIL: a=%d b=%d cin=%d; z=%b; cout=%b", a,b,cin, z, cout); 
        end
    $finish;
    end
endmodule