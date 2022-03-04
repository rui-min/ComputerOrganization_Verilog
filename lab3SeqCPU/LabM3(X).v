// test register file
// compile with: iverilog -y ./hrLib/ LabM3.v
// command: vvp a.out +w=0/+w=1
// this is problematic

module labM3;
   reg   [31:0] wd;
   reg   [4:0]  rs1, rs2, wn;
   reg          clk, w, flag;
   wire [31:0]  rd1, rd2;
   integer      i;

   rf myRF(rd1, rd2, rs1, rs2, wn, wd, clk, w);

   initial
     begin
        flag = $value$plusargs("w=%b", w);

        for (i = 0; i < 32; i = i + 1)
          begin
             clk = 0;
             wd = i * i;
             wn = i;
             clk = 1;
             #1;
          end

        for (i = 0; i < 10; i = i + 1)
          begin
             rs1 = $random % 32;
             rs2 = $random % 32;

             #2;
             $display("rs1=%d, rd1=%d  rs2=%d, rd2=%d; wn=%d, wd=%d", rs1, rd1, rs2, rd2, wn, wd);
          end

        $finish;
     end

endmodule // labM3