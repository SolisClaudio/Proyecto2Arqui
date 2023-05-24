`include "reversibleCarrySkipOperator.v"

module WallaceTreePipeline(X, Y, clk, rst, pseudosuma, pseudocarry);
    input  [15:0] X;
    input [15:0] Y;
    output [31:0] pseudosuma, pseudocarry;
    input clk, rst;

    reg [31:0] pseudosuma, pseudocarry;
    
    reg [31:0] ordenOperandos, operando1, operando2, operando3, operando4; //operando1, operando2, operando3, operando4;
    reg [15:0] multiplicador;
    reg [31:0] A, B, C, D, E, F, G ,H;

    initial
    begin
        //valor inicial de los operandos
        ordenOperandos[15:0] = X[15:0];
        ordenOperandos[31:16] = 8'b0;
        multiplicador = Y;
        pseudosuma = 0;
        pseudocarry = 0;
    end

    always @(rst)
    begin
        ordenOperandos[15:0] = X[15:0];
        ordenOperandos[31:16] = 8'b0;
        multiplicador[15:0] = Y[15:0];
        pseudosuma = 0;
        pseudocarry = 0;
        A=0;
        B=0;
        C=0;
        D=0;
        E=0;
        F=0;
        G=0;
        H=0;
    end

    always @(posedge clk) begin

        //Inicio de generacion de  Operandos
        operando1 = ordenOperandos & {32{multiplicador[0]}}; 
        ordenOperandos = ordenOperandos << 1;
        multiplicador = multiplicador >> 1;

        operando2 = ordenOperandos & {32{multiplicador[0]}}; 
        ordenOperandos = ordenOperandos<<1;
        multiplicador = multiplicador >> 1;

        operando3 = ordenOperandos & {32{multiplicador[0]}}; 
        ordenOperandos = ordenOperandos<<1;
        multiplicador = multiplicador >> 1;

        operando4 = ordenOperandos & {32{multiplicador[0]}}; 
        ordenOperandos = ordenOperandos<<1;
        multiplicador = multiplicador >> 1;
        //Fin de generacion de operandos

        //CSA 1
        A = (operando1 & operando2) | ((operando1 | operando2) & operando3);
        A = A << 1;
        B = operando1 ^ operando2 ^ operando3;

        //CSA 2
        C = (operando4 & pseudocarry) | ((operando4 | pseudocarry) & pseudosuma);
        C = C << 1;

        D = (operando4) ^ (pseudocarry) ^ (pseudosuma);

        //CSA 3
        E = (B & C) | ((B | C) & D);
        E = E << 1; 

        F = B ^ C ^ D;

        //CSA 4
        pseudocarry = (A & E) | ((A | E) & F);
        pseudocarry = pseudocarry << 1; 
        pseudosuma = A ^ E ^ F;
        

    end

endmodule


module tester(x, y, r, cin, clk, rst, p);
    input [31:0]p;
    output [15:0]x;
    output [15:0]y;
    output clk, rst, r, in;
    input cin;

    reg [15:0]x;
    reg [15:0]y;
    reg clk, rst, r, in;

    initial
    begin

        $dumpfile("WTPipeline.vcd");
        $dumpvars;
        
        clk = 0;
        rst = 0;
        r = 0;
        in = 0;

        x = 203; y = 5896; // p=1.196.888
        #9     rst=1;
        #1 rst=0; 
        x = 2485; y=18; // p=44.730
        #9 rst=1; 
        #1 rst=0; x = 5559; y =2475; //p=13.758.525
        #9 rst=1;
        #1 rst=0; x = 23690; y=9520; // p=225.528.800
        #9 rst=1; 
        #1 rst=0; x = 65500; y =65000; //p=4.257.500.000     
        #10 $finish;
    end

    // Generar la señal de reloj periódica
    always
    begin
        #1 clk=!clk;
    end
endmodule

// TODO: IMPLEMENTAR un módulo testbench empleando diseño estructural. 
// Debe instanciar un módulo WallaceTreePipeline, 
// dos módulos ReversibleCarrySkipOperator_16bits en ripple, y un módulo tester.
module testbench;
    wire [31:0] p, pseudosuma, pseudocarry;
    wire [15:0] x, y;
    wire r, cin, clk, rst, cbout, cboutnulo;

    tester t1(x, y, r, cboutnulo, clk, rst, p);
    WallaceTreePipeline wtp (x, y, clk, rst, pseudosuma, pseudocarry);
    ReversibleCarrySkipOperator_16bits suma(pseudosuma[15:0], pseudocarry[15:0], r, 1'b0, p[15:0], cbout);
    ReversibleCarrySkipOperator_16bits suma1(pseudosuma[31:16], pseudocarry[31:16], r, cbout, p[31:16], cboutnulo);

endmodule