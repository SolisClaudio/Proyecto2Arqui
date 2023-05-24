module fullAdder(X, Y, CBin, result, CBout);
    input X, Y, CBin;
    output CBout, result;
    
    assign result = X ^ Y ^ CBin;
    assign CBout = (X & Y) | ( (X | Y) & CBin); 
endmodule

module CAS(Rin, Din, P, Cin, Cout, Rout);
    input Cin, Rin;
    input P, Din;
    output Cout, Rout;

    assign sumaResta = P ^ Din;
    fullAdder f(Rin, sumaResta, Cin, Rout, Cout);

endmodule

module NRAD(X, Y, Q, R);
    input [3:0] X;
    input [1:0] Y;
    output [2:0] Q, R;

    wire [4:0] dividendo;
    wire [2:0] divisor;
    wire P;
    wire [2:0] restoFila1, CinFila1, restoFila2, restoFila3;
    wire [1:0] CoutFila1, CoutFila2, CoutFila3;

    assign dividendo = {1'b0 ,X};f
    assign divisor = {1'b0 ,Y};

    assign P = (~dividendo[4]) ^ divisor[2];


    CAS fila1[2:0](dividendo[4:2]                 , divisor[2:0], P          , {CoutFila1[1:0], P},      {Q[2],CoutFila1[1:0]},     restoFila1[2:0]);
    CAS fila2[2:0]({restoFila1[1:0], dividendo[1]}, divisor[2:0], {3{Q[2]}}  , {CoutFila2[1:0], Q[2]},   {Q[1], CoutFila2[1:0]},    restoFila2[2:0]);
    CAS fila3[2:0]({restoFila2[1:0], dividendo[0]}, divisor[2:0], {3{Q[1]}}  , {CoutFila3, Q[1]}, {Q[0], CoutFila3[1:0]},           restoFila3[2:0]);

    wire [2:0] correccion, carry;
    assign correccion = {3{restoFila3[2]}} & divisor;
    fullAdder rippleAdder[2:0](correccion, restoFila3, {carry[1:0], 1'b0}, R[2:0], carry[2:0]);
    
endmodule

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
    
    tester t(X,Y,Q,R);
    NRAD divisor(X,Y,Q,R);
endmodule