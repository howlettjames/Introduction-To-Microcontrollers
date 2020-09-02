    .include "p30F4013.inc"
    .GLOBAL _comandoLCD
    .GLOBAL _datoLCD
    .GLOBAL _busyFlagLCD	
    .GLOBAL _iniLCD8bits	
    .EQU    RS_LCD, RF2
    .EQU    RW_LCD, RF3
    .EQU    EN_LCD, RD2

;/**@brief ESTA RUTINA GENERA UN RETARDO DE 15 MS
;*/
_iniLCD8bits:
    CALL	_RETARDO_15MS
    MOV		#0X30, W0
    CALL	_comandoLCD
    
    CALL	_RETARDO_15MS
    MOV		#0X30, W0
    CALL	_comandoLCD
    
    CALL	_RETARDO_15MS
    MOV		#0X30, W0
    CALL	_comandoLCD
    
    CALL	_busyFlagLCD
    MOV		#0X38, W0
    CALL	_comandoLCD
    
    CALL	_busyFlagLCD
    MOV		#0X08, W0
    CALL	_comandoLCD
    
    CALL	_busyFlagLCD
    MOV		#0X01, W0
    CALL	_comandoLCD
    
    CALL	_busyFlagLCD
    MOV		#0X06, W0
    CALL	_comandoLCD
    
    CALL	_busyFlagLCD
    MOV		#0X0F, W0
    CALL	_comandoLCD
   
    RETURN

;/**@brief ESTA RUTINA GENERA UN RETARDO DE 15 MS
;*/
_busyFlagLCD:
    BCLR	PORTF, #RS_LCD
    NOP
    SETM.B	TRISB
    NOP
    BSET	PORTF, #RW_LCD
    NOP
    BSET	PORTD, #EN_LCD
    NOP
    
ESPERAR_LCD:
    BTSC	PORTB,	#RB7
    GOTO	ESPERAR_LCD
    
    BCLR	PORTD, #EN_LCD
    NOP
    BCLR	PORTF, #RW_LCD
    NOP
    CLR.B	TRISB
    NOP
    RETURN
   
;/**@brief ESTA RUTINA GENERA UN RETARDO DE 15 MS
;*/
_datoLCD:
    BSET	PORTF, #RS_LCD	    ;RS = 1 
    NOP
    BCLR	PORTF, #RW_LCD
    NOP
    BSET	PORTD, #EN_LCD
    NOP
    MOV.B	WREG, PORTB
    NOP
    BCLR	PORTD, #EN_LCD
    NOP    
    RETURN

;/**@brief ESTA RUTINA GENERA UN RETARDO DE 15 MS
;*/
_comandoLCD:
    BCLR	PORTF, #RS_LCD	    ;RS = 0 
    NOP
    BCLR	PORTF, #RW_LCD
    NOP
    BSET	PORTD, #EN_LCD
    NOP
    MOV.B	WREG,  PORTB
    NOP
    BCLR	PORTD, #EN_LCD
    NOP    
    RETURN
    
;/**@brief ESTA RUTINA GENERA UN RETARDO DE 15 MS
;*/
_RETARDO_15MS:
    PUSH	W0
    CLR		W0
    MOV		#9275, W0
    
CICLO1_1S:	
    DEC		W0, W0
    BRA		NZ, CICLO1_1S

    POP W0
    RETURN
