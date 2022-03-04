// 32-bits ALU "unsigned" test (slt not made in yALU.v and set 0)
// op=000: z=a AND b, op=001: z=a|b, op=010: z=a+b, op=110: z=a-b
// c: iverilog LabL9.v yAluWeak.v yArith.v yMux.v yAdder.v yMux1.v yAdder1.v yMux4to1.v
// command line test: vvp a.out +op=110
module labL9 ();
    reg [31:0] a,b;
    reg [31:0] expect;
    reg [2:0] op;
    wire ex;
    wire [31:0] z;
    reg ok, flag;
    yAluWeak mine(z, ex, a, b, op);
    initial begin
        repeat(5)
        begin
            a = $random;
            b = $random;
            flag = $value$plusargs("op=%d", op);
            #1;
            // Compare the circuit's output with "expect"
            // !!! must include "3'b" to indicate 3-bits binary or ERROR will occur
            if (op === 3'b000) expect = a & b;
            else if (op === 3'b001) expect = a | b;
            else if (op === 3'b010) expect = a + b;
            else if (op === 3'b110) expect = a - b;
            else if (op === 3'b111) expect = 0; // slt not supported

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