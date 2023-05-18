//Modulo P_Fop
//Modela un full Operator
module P_FOp(X, Y, R, CBin, P, result, CBout);
    input X, Y, R, CBin;
    output P, result, CBout;
    
    wire W, G;

    assign W = X ^ R;
    assign G = W & Y;

    assign P = W ^ Y;
    assign result = X ^ Y ^CBin;
    assign CBout = G | (P & CBin); 
endmodule

//Módulo P_ripple_2 modela un ripple de 2 P_FOp.
module P_ripple_2(a, b, r, CBin, P, result, CBout);
    input [1:0]a, b; 
    input  CBin, r;
    output P, CBout;
    output [1:0] result;

    wire CBout0, P0, P1;

    //Ripple de 2 Full Operators.
    P_FOp  
        FOp0( a[0] , b[0], r, CBin, P0, result[0], CBout0 ),
        FOp1( a[1] , b[1], r, CBout0, P1, result[1], CBout );
    
    //Calculo del propagado grupal.
    assign P = P0 && P1;

endmodule

//Módulo P_ripple_3 modela un ripple de 3 P_FOp.
module P_ripple_3(a, b, r, CBin, P, result, CBout);
    input [2:0]a, b; 
    input  CBin, r;
    output P, CBout;
    output [2:0] result;

    wire CBout0, CBout1, P0, P1, P2 ; 

    //Ripple de 3 Full Operators
    P_FOp  
        FOp0( a[0] , b[0], r, CBin, P0, result[0], CBout0 ),
        FOp1( a[1] , b[1], r, CBout0, P1, result[1], CBout1 ),
        FOp2(a[2] , b[2], r, CBout1, P2, result[2], CBout );
    
    //Calculo del propagado grupal.
    assign P = P0 && P1 && P2;

endmodule

//Módulo P_ripple_4 modela un ripple de 4 P_FOp.
module P_ripple_4(a, b, r, CBin, P, result, CBout);

    input [3:0]a, b; 
    input  CBin, r;
    output P, CBout;
    output [3:0] result;
    wire CBout0, CBout1, CBout2, P0, P1, P2, P3 ; 

    //Ripple de 4 full Operators.
    P_FOp  
        FOp0( a[0] , b[0], r, CBin, P0, result[0], CBout0 ), 
        FOp1( a[1] , b[1], r, CBout0, P1, result[1], CBout1 ),
        FOp2(a[2] , b[2], r, CBout1, P2, result[2], CBout2 ),
        FOp3(a[3] , b[3], r, CBout2, P3, result[3], CBout ); 
    
    //Calculo del propagado grupal.
    assign P = P0 && P1 && P2 && P3;

endmodule

//Modulo reversible_carry_skip_operator16. Modela un summador/restador de 16 bits,
//usando modulos ripple con operandos de 2, 3, 4 bits, conectados en ripple con logica skip
//en los modulos 3, 4, 5.
module ReversibleCarrySkipOperator_16bits(a, b, r, CBin, result, CBout);
    input [15:0] a, b;
    input CBin, r;
    output [15:0] result;
    output CBout;

    wire P10, CB1out, P42, CB4out, CB5in, P85, CB8out, CB9in, P129, CB12out, CB13in, P1513;

    //Ripple de P_ripple_n , con logica skip en los modulos 3, 4 y 5.

    P_ripple_2 r1 (a[1:0], b[1:0], r, CBin, P10, result[1:0], CB1out);//modulo 1.
    
    P_ripple_3 r2 (a[4:2], b[4:2], r, CB1out, P42, result[4:2], CB4out);//modulo 2.
    //Logica skip que calcula el carry de entrada al modulo 3
    CarrySkip CarrySKip5 (P42, CB1out, CB4out, CB5in); 

    P_ripple_4 r3 (a[8:5], b[8:5], r, CB5in, P85, result[8:5], CB8out);//modulo 3.
    //Logica skip que calcula el carry de entrada al modulo 4
    CarrySkip CarrySkip9 (P85, CB5in, CB8out, CB9in);

    P_ripple_4 r4 (a[12:9], b[12:9], r, CB9in, P129, result[12:9], CB12out);//modulo 4
    //Logica skip que calcula el carry de entrada al modulo 5.
    CarrySkip CarrySkip13 (P129, CB9in, CB12out, CB13in);

    P_ripple_3 r5 (a[15:13], b[15:13], r, CB13in, P1513, result[15:13], CBout);//modulo 5.

endmodule

//Modulo CarrySkip que modela la logica de skip.
module CarrySkip( P, CBj, CBin, CBout);
    input P, CBj, CBin;
    output CBout;

    assign CBout = (CBj && P) | CBin;

endmodule

