    .include "p30F4013.inc"
    
    .GLOBAL __T1Interrupt
    .GLOBAL _useg
    .GLOBAL _dseg
    .GLOBAL _umin
    .GLOBAL _dmin
    .GLOBAL _uhr
    .GLOBAL _dhr
    
__T1Interrupt:
    PUSH	W0
    MOV		#10, W0
    
    INC.B	_useg   
    
    CP.B	_useg
    BRA		NZ, FIN
    
    CLR.B	_useg
    INC.B	_dseg
    
    MOV		#6, W0
    CP.B	_dseg, 
    BRA		NZ, FIN
    
    CLR.B	_dseg
    INC.B	_umin
    
    MOV		#10, W0
    CP.B	_umin
    BRA		NZ, FIN
    
    CLR.B	_umin
    INC.B	_dmin
    
    MOV		#6, W0
    CP.B	_dmin
    BRA		NZ, FIN
    
    CLR.B	_dmin
    INC.B	_uhr
    
    ; ---------- IMPORTANTE
    MOV		#2, W0
    CP.B	_dhr
    BRA		Z, COMPARACION_2
    
    ; ---------- COMPARACION 1
    MOV		#10, W0
    CP.B	_uhr
    BRA		NZ, FIN
    
    CLR.B	_uhr
    INC.B	_dhr
    
FIN:
    BCLR	IFS0, #T1IF 
    POP		W0
    RETFIE

COMPARACION_2:
    MOV		#4, W0
    CP.B	_uhr
    BRA		NZ, FIN
    
    CLR.B	_uhr
    CLR.B	_dhr
    
    GOTO	FIN



