// compile by: iverilog LabL1.v yMux1.v
module labL1 ();
    integer i,j,k;
    wire z;
    reg a, b, c;
    yMux1 test1(z,a,b,c);
    initial begin
        for (i=0; i<2; i++)
        begin
            for (j=0; j<2; j++)
            begin
                for (k=0; k<2; k++)
                begin
                    a=i; b=j; c=k;
                    #4  // wait for z
                    $display("a=%b b=%b c=%b; z=%b", a,b,c, z);
                end
                
            end
        end
    $finish;
    end
endmodule