// test register randomly with monitor & always blocks
// compile with: iverilog -y ./hrLib/ LabM2.v
// command: vvp a.out +enable=1

module labM2;
    // prev_d to remeber latest d value
    reg [31:0] d, e, prev_d; 
    reg clk, enable, flag;
    wire [31:0] z;
    register #(32) mine(z,d,clk,enable);

    initial begin
        flag = $value$plusargs("enable=%b",enable);
        clk = 0;    // !!initialization is a MUST
        
        $monitor("%5d:clk=%b,d=%d,z=%d,expect=%d", $time,clk,d,z,e);

        repeat(20) begin
            #2 prev_d = d; 
            d = $random;
        end
        $finish;
    end

    always
        #5 clk = ~clk;
    
    always @(posedge clk) 
        e = clk? d : prev_d;
           
endmodule