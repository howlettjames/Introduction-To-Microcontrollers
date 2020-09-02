    .include "p30F4013.inc"
    
    .GLOBAL __INT0Interrupt
    .GLOBAL _uni
    .GLOBAL _dec
    .GLOBAL _cen
    .GLOBAL _umi

__INT0Interrupt:
    PUSH	W0
    INC.B	_uni
    
    MOV		#10, W0
    CP.B	_uni
    BRA		NZ, FIN
    
    CLR.B	_uni
    INC.B	_dec
    
    CP.B	_dec
    BRA		NZ, FIN
    
    CLR.B	_dec
    INC.B	_cen
    
    CP.B	_cen
    BRA		NZ, FIN
    
    CLR.B	_cen
    INC.B	_umi
    
    CP.B	_umi
    BRA		NZ, FIN
    
    CLR.B	_umi
    
FIN:
    BCLR	IFS0, #INT0IF 
    POP		W0
    RETFIE



