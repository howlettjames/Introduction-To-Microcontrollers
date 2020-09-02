    .include "p30F4013.inc"
    .GLOBAL _funcion1
    .GLOBAL _funcion2
    .GLOBAL _funcion3
    .GLOBAL _funcion4
    .GLOBAL _var	;In C this is equal to "extern var"
        
_funcion1:
    PUSH	W0
    MOV		#3, W0
    MOV		W0, _var
    POP		W0
    RETURN;
    
_funcion2:
    PUSH	W1
    MOV		#12, W0
    MOV		#3, W1
    ADD		W0, W1, W0
    POP		W1
    RETURN;
    
_funcion3:
    ADD		W0, W1, W0
    RETURN;
    
_funcion4:
    PUSH	W1
    PUSH	W2
    CLR		W2
CICLO:
    MOV.B	[W0++], W1
    CP0.B	W1
    BRA		Z, FIN
    INC		W2, W2
    GOTO	CICLO
    
FIN:
    MOV		W2, W0
    POP		W2
    POP		W1
    RETURN;