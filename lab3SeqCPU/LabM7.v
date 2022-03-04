// test yIF(...) module in cpu.v
// compile with: iverilog -y ./hrLib/ LabM7.v cpu.v
// command: vvp a.out
module labM7;
    reg [31:0] PCin;
    reg clk;
    wire [31:0] ins, PCp4;
    yIF myIF(ins, PCp4, PCin, clk);

    initial
    begin
        clk = 0;    // clock initialization
        //---------------------------------Entry point
        PCin = 16'h28;
        //---------------------------------Run program
        repeat (11)
        begin
            //-----------Fetch an ins by clk = 1 & Stablize
            clk = 1; #1;
            //------------------------initialize & execute
            clk = 0; #1;
            //------------------------------View results
            $display("instruction = %h", ins);
            // !next instruction address is calculated
            PCin = PCp4;
        end
    $finish;
    end
endmodule