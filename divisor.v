module fullAdder(X, Y, CBin, result, CBout);
    input X, Y, R, CBin;
    output CBout, result;
    
    wire G, P;
    
    assign G = X & Y;

    assign P = X ^ Y;
    assign result = X ^ Y ^CBin;
    assign CBout = G | (P & CBin); 
endmodule

module CAS(Rin, Din, P, Cin, Cout, Rout);
    input Cin, Rin;
    inout P, Din;
    output Cout, Rout;

    assign sumaResta = P ^ Din;
    fullAdder f(Rin, sumaResta, Cin, Rout, Cout);

endmodule

module NRAD(X, Y, Q, R);
    input [3:0] X;
    output [1:0] Y;
    output [2:0] Q, R;

    wire [2:0] restoFila1;

    CAS[3:0] fila1(X[4:2], Y[2:0], X[4:2], restoFila1);

endmodule

/*

module tester(X, Y, Q, R);
    output [3:0] X;
    output [1:0] Y;
    input [2:0] Q;
    input [2:0] R;
    
    reg [3:0]X;
    reg [1:0]Y;
    integer i, j;

    initial
    begin

        $dumpfile("NRAD.vcd");
        $dumpvars;
        // i = x
        // j = y
        for(i = 0; i <= 15; i = i + 1) begin
          for(j = 1; j <= 3; j = j + 1) begin
            X = i;
            Y = j;
            #3;
          end
        end
        #5 $finish;
    end
endmodule


module testbench;
    wire [3:0] X;
    wire [1:0] Y;
    wire [2:0] Q;
    wire [2:0] R;
    
    NRAD divisor(X,Y,Q,R);
    tester t(X,Y,Q,R);
endmodule*/