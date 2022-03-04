// The 32-bits enhanced adder
// add if ctrl =0, substract if ctrl=1
// library module without initial
// utilise yMux.v yAdder.v yMux1.v yAdder1.v
module yArith (z, cout, a, b, ctrl);
    // add if ctrl =0, substract if ctrl=1
    output [31:0] z;
    output cout;
    input [31:0] a,b;
    input ctrl;
    wire [31:0] notB, tmp;
    wire cin;
    // instantiate the components and connect them
    assign cin = ctrl;
    not my_not[31:0](notB, b);
    // Mux: if cin==0, tmp=b; if cin==1, tmp=notB
    yMux #(32) mux(tmp, b, notB, cin);
    // !! if cin==0, tmp=b & z=a+b+0; 
    // !! if cin==1, tmp=notB & z=a+notB+1=a-b;
    yAdder my_add(z, cout, a, tmp, cin);

endmodule   // yArith