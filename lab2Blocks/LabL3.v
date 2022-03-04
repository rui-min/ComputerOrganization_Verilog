// 32 2-to-1 Muxes are combined and bus a 32-bit output wire z
// compile by: iverilog LabL3.v yMux.v yMux1.v
module labL3 ();
    integer i;
    wire [31:0] z;  // 32 bits
    reg c;
    reg [31:0] a, b, expect;    // 32 bits
    yMux #(.SIZE(32)) test3(z,a,b,c);
    initial begin
        repeat (10)
        begin
            a = $random;
            b = $random;
            c = $random % 2;
            // !!Below lines MUST be after the above lines to ensure updated assignment
            // !!!can NOT just code expect = (a & (~c)) | (b & c); MUST loop bit-by-bit assignment
            // because c is only 1 bit register!!
            for (i = 0; i < 32; i = i + 1)
            begin
                expect[i] = (a[i] & ~c) + (b[i] & c); // boolean logic representation of the circuit
            end
            
            #1;  // wait for z
            // compare z with the expected output
            if (expect === z)
                // $display("PASS: a=%b b=%b c=%b; z=%b; expect=%b", a,b,c, z, expect);
                // %d for decimal format to make outputs easier to read
                $display("PASS: a=%d b=%d c=%d; z=%b; expect=%b", a,b,c, z, expect);
            else
                $display("FAIL: a=%b b=%b c=%b; z=%b; expect=%b", a,b,c, z, expect); 
        end
    $finish;
    end
endmodule