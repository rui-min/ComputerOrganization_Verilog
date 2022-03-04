// 32 4-to-1 Muxes are combined and bus a 32-bit output wire z
// compile by: iverilog LabL4to1.v yMux4to1.v yMux.v yMux1.v
module labL4to1 ();
    integer i;
    wire [31:0] z;  // 32 bits
    reg [1:0] c;    // 2 bits for control of 4to1 multiplexor
    reg [31:0] a0, a1, a2, a3, expect;    // 32 bits
    yMux4to1 #(.SIZE(32)) test3(z,a0,a1,a2,a3,c);
    initial begin
        repeat (10)
        begin
            a0 = $random;
            a1 = $random;
            a2 = $random;
            a3 = $random;
            c = $random % 4;    //!!! %4 to ensure c's 2 bits are stored properly
            // !!Below lines MUST be after the above lines to ensure updated assignment
            // !!!can NOT just code expect = (a & (~c)) | (b & c); MUST loop bit-by-bit assignment
            // because c is only 2-bits register!!
            for (i = 0; i < 32; i = i + 1)
            begin
                // !!boolean logic representation of the circuit
                expect[i] = ( ((a0[i] & ~c[0]) + (a1[i] & c[0])) &~c[1] )
                            | ( ((a2[i] & ~c[0]) + (a3[i] & c[0]) ) &c[1] ); 
            end
            
            #1;  // wait for z
            // compare z with the expected output
            if (expect === z)
                // $display("PASS: a=%b b=%b c=%b; z=%b; expect=%b", a,b,c, z, expect);
                // %d for decimal format to make outputs easier to read
                $display("PASS: a0=%d a1=%d a2=%d a3=%d c=%d; z=%b; expect=%b",
                             a0,a1,a2,a3,c, z, expect);
            else
                $display("FAIL: a0=%d a1=%d a2=%d a3=%d c=%d; z=%b; expect=%b",
                             a0,a1,a2,a3,c, z, expect);
        end
    $finish;
    end
endmodule