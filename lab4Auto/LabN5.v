// test yIF~yDM,yWB modules in cpu.v
// compile with: iverilog -y ./hrLib/ LabN5.v cpu.v
// command: vvp a.out
module labN5;
    reg [31:0] entryPoint;
    reg clk, INT;
    wire [31:0] ins, rd2, wb;
    yChip myChip(ins, rd2, wb, entryPoint, INT, clk);

    initial
    begin
        //---------------------------------Entry point
        entryPoint = 16'h28;  INT = 1; #1; // int=1 to let initial fetch
        //---------------------------------Run program
        
        repeat (43) // 43 according to ram.dat file
        begin
            //-----------Fetch an ins by clk = 1 & stablize
            clk = 1; #1; INT = 0;
            //---------------------------------Set control signals empty!
            //------------------------initialize & execute
            clk = 0; #1;
            //------------------------------View results
            $display("%h: rd2=%3d wb=%3d", ins, rd2, wb);
            //---------------------------------Prepare for the next ins
            // !!! do NOthing because next address is automated inside cpu !!!
        end
    $finish;
    end
endmodule