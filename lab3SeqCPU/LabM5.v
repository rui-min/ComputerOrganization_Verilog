// display ram.dat (machine code) execution part
// compile with: iverilog -y ./hrLib/ LabM5.v
// command: vvp a.out

module labM5;
    reg clk, read, write;
    reg [31:0] address, memIn;
    wire [31:0] memOut;
    mem data(memOut, address, memIn, clk, read, write);

    initial
    begin
        // !!from ram.dat(and RISC-V code), program starts at 0x28
        address = 16'h28; write = 0; read = 1; 
        repeat (11) begin
            #1 $display("Address %h contains %h", address, memOut);
            address = address + 4;
        end

    $finish;
    end
endmodule