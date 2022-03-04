// 32-bits ALU "signed" test (slt & ex tested)
// op=000: z=a AND b, op=001: z=a|b, op=010: z=a+b, op=110: z=a-b, op=111: slt
// c: iverilog LabL11.v yAlu.v yArith.v yMux.v yAdder.v yMux1.v yAdder1.v yMux4to1.v
// or compile with: iverilog LabL11.v cpu.v
// command line test: vvp a.out +op=111
module labL11 ();
    reg signed [31:0] a,b;  // !!"signed" to support slt comparison
    reg [31:0] expect;
    reg [2:0] op;
    reg ex;    // optional declaration
    wire [31:0] z;
    reg flag, zero, tmp;
    yAlu mine(z, ex, a, b, op);
    initial begin
        repeat(5)
        begin
            a = $random;
            b = $random;
            tmp = $random % 2;
            if (tmp == 0)   b=a;
            flag = $value$plusargs("op=%d", op);
            #1;
            // Compare the circuit's output with "expect"
            // !!! must include "3'b" to indicate 3-bits binary or ERROR will occur
            if (op === 3'b000) expect = a & b;
            else if (op === 3'b001) expect = a | b;
            else if (op === 3'b010) expect = a + b;
            else if (op === 3'b110) expect = a - b;
            else if (op === 3'b111) expect = (a<b)? 1:0; // slt Supported!

            zero = (expect == 0) ? 1:0;
            if (zero)   $display("ALL output bits are 0");

            // compare z with the expected output
            if (expect === z)
                // %d for decimal format to make outputs easier to read
                $display("PASS: a=%d b=%d op=%b; z=%d; expect=%b", a,b,op, z, expect);
            else
                $display("FAIL: a=%d b=%d op=%b; z=%d; expect=%b", a,b,op, z, expect);
            
        end
    $finish;
    end
endmodule