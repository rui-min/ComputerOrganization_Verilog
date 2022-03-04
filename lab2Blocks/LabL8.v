// 32-bits enhanced Adder "signed" test: check sum automatically and examine final cout manually
// "signed" will NOT affect PASS or FAIL because MSB is discarded due to 32 limit
// an enhanced adder and cin=0/1 for add/sub
// compile by: iverilog LabL8.v yArith.v yAdder.v yAdder1.v yMux.v yMux1.v
module labL8 ();
    wire [31:0] z;  // 32 bits
    wire cout;
    reg cin;    // cin=0/1 for add/sub
    reg signed [31:0] a, b, expect;    // "signed" or not will NOT affect the result
    yArith test8(z,cout,a,b,cin);
    initial begin
        repeat (10)
        begin
            a = $random;
            b = $random;
            cin = $random % 2;
            // !!Below lines MUST be after the above lines to ensure updated assignment
            if (cin == 1)   // sub
                expect = a - b;
            else    // add
                expect = a + b;

            #1;  // wait for z
            // compare z with the expected output
            if (expect === z)
                // %d for decimal format to make outputs easier to read
                $display("PASS: a=%d b=%d cin=%b; z=%d; cout=%b", a,b,cin, z, cout);
            else
                $display("FAIL: a=%d b=%d cin=%b; z=%d; cout=%b", a,b,cin, z, cout); 
        end
    $finish;
    end
endmodule