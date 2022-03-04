// test mem write & read
// compile with: iverilog -y ./hrLib/ LabM4.v
// command: vvp a.out

module labM4;
    reg [31:0] address, memIn; 
    reg clk, read, write, flag;
    wire [31:0] memOut;
    mem data(memOut, address, memIn, clk, read, write);

    initial begin
        // write at address 16
        clk = 0;    // !clock initialization
        write = 1; read = 0; address = 16;
        memIn = 32'h12345678;
        clk = 1;    #1; // !clock rising & stablize

        // write at address 24
        clk = 0;    // !clock initialization
        write = 1; read = 0; address = 24;
        memIn = 32'h89abcdef;
        clk = 1;    #1; // !clock rising & stablize

        // switch to read mode & set start address
        write = 0; read = 1; address = 16;  
        repeat (3)
        begin
            #1 $display("Address %d contains %h", address, memOut);
            address = address +4;
        end

        $finish;
    end

endmodule