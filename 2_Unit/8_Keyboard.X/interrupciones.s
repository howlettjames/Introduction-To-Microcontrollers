    .include "p30F4013.inc"
    
    .GLOBAL __T1Interrupt
    
__T1Interrupt:
    BTG		LATD, #LATD8
    NOP
    BCLR	IFS0, #T1IF
    RETFIE;



