// 2 2-to-1 Muxes are combined and bus a 2-bit output wire z
// compile by: iverilog LabL2.v yMux1.v yMux2.v
module labL2 ();
    integer i,j,k;
    wire [1:0] z;
    reg c;
    reg [1:0] a, b, expect;
    yMux2 test2(z,a,b,c);
    initial begin
        for (i=0; i<2; i++)
        begin
            for (j=0; j<2; j++)
            begin
                for (k=0; k<2; k++)
                begin
                    a[0]=i; b[0]=j; c=k;
                    a[1]=j; b[1]=k;
                // !!Below two lines MUST be after the above two lines to ensure updated assignment
                    expect[0] = (a[0] & (~c)) | (b[0] & c);
                    expect[1] = (a[1] & (~c)) | (b[1] & c);
                    #4  // wait for z
                    if (expect === z)
                        $display("PASS: a=%b b=%b c=%b; z=%b; expect=%b", a,b,c, z, expect);
                    else
                        $display("FAIL: a=%b b=%b c=%b; z=%b; expect=%b", a,b,c, z, expect);    
                end
                
            end
        end
    $finish;
    end
endmodule