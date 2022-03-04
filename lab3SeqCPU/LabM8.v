// test yID & yIE modules in cpu.v
// compile with: iverilog -y ./hrLib/ LabM8.v cpu.v
// command: vvp a.out
module labM8;
    reg [31:0] PCin;
    reg RegWrite, clk, ALUSrc;
    reg [2:0] op;
    wire [31:0] wd, rd1, rd2, imm, ins, PCp4, z, jTarget, branch;
    wire zero;

    yIF myIF(ins, PCp4, PCin, clk);
    yID myID(rd1, rd2, imm, jTarget, branch, ins, wd, RegWrite, clk);
    yEX myEx(z, zero, rd1, rd2, imm, op, ALUSrc);
    
    assign wd = z;  // !!connect yEX output z back to wd input of yID

    initial
    begin
        clk = 0;  #1;  // clock initialization
        //---------------------------------Entry point
        PCin = 16'h28;
        //---------------------------------Run program
        
        repeat (11)
        begin
            #1;
            //-----------Fetch an ins by clk = 1 & stablize
            clk = 1; #1;
            //---------------------------------Set control signals
            RegWrite = 0; ALUSrc = 1; op = 3'b010;
            // Add statements to adjust the above defaults
            if (ins[6:0] == 7'h33) // R-Type
            begin
                RegWrite = 1; ALUSrc = 0;
                $display("R-type");
            end
            else if (ins[6:0] == 7'h3 || ins[6:0] == 7'h13) //I type
            begin
                RegWrite = 1; ALUSrc = 1;
                $display("I-type");
            end
            else if(ins[6:0] == 7'h6F) // UJ Type 
            begin
                RegWrite = 1; ALUSrc = 1;
                $display("UJ-type");
            end
            // else if (ins[6:0] == 7'h23)   // S-type
            // begin
            //     RegWrite = 1; ALUSrc = 1;
            //     $display("S-type");
            // end
            // else if (ins[6:0] == 7'h63)   // SB-type
            // begin
            //     RegWrite = 1; ALUSrc = 1;
            //     $display("SB-type");
            // end
            //------------------------initialize & execute
            clk = 0; #1;
            //------------------------------View results
            $display("ins=%h rd1=%h rd2=%h imm=%h jTarget=%h z=%h zero=%h",
                         ins, rd1, rd2, imm, jTarget, z, zero);
            PCin = PCp4; // !next instruction address already calculated
            
        end
    $finish;
    end

endmodule