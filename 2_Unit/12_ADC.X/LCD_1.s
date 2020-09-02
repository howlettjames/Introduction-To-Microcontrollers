    .include "p30F4013.inc"
    
    .GLOBAL __ADCInterrupt
    .GLOBAL _comandoLCD
    .GLOBAL _datoLCD
    .GLOBAL _busyFlagLCD	
    .GLOBAL _iniLCD8bits	
    .GLOBAL _imprimeLCD	
    .GLOBAL _clearLCD
    .GLOBAL _unlockExternOsc
   
    .GLOBAL _initWiFi
    .GLOBAL _RETARDO_1S
    .GLOBAL _comandoAT
    
    .EQU    RS_LCD, RD3
    .EQU    RW_LCD, RD9
    .EQU    EN_LCD, RD2

;/**@brief ESTA RUTINA GENERA UN RETARDO DE 15 MS
;*/    
_comandoAT:
    PUSH	W1
    
CICLO_AT:
    CLR		W1
    MOV.B	[W0++], W1
    CP0.B	W1
    BRA		Z, FIN_AT
    
    BCLR	IFS0, #U1TXIF
    MOV		W1, U1TXREG
    NOP
    
POLLING_TX:
    BTSS	IFS0, #U1TXIF
    GOTO	POLLING_TX
    
    GOTO	CICLO_AT
    
FIN_AT: 
    POP		W1
    RETURN

;/**@brief ESTA RUTINA GENERA UN RETARDO DE 15 MS
;*/    
_initWiFi:
    BSET	PORTA, #RA11
    NOP
    CALL	_RETARDO_1S
    BSET	PORTD, #RD0
    NOP
    CALL	_RETARDO_1S
    BCLR	PORTD, #RD0
    NOP
    CALL	_RETARDO_1S
    BSET	PORTD, #RD0
    NOP
    CALL	_RETARDO_1S
    
    RETURN
    
;/**@brief ESTA RUTINA GENERA UN RETARDO DE 15 MS
;*/
_unlockExternOsc:
    PUSH	W0
    MOV		#OSCCONL, W0
    MOV		#0X46, W1
    MOV		#0x57, W2
    MOV.B	W1, [W0]
    MOV.B	W2, [W0]
    BSET	OSCCONL, #LPOSCEN
    POP		W0
    
    RETURN

;/**@brief ESTA RUTINA GENERA UN RETARDO DE 15 MS
;*/
_clearLCD:
    CALL	_busyFlagLCD
    MOV		#0X01, W0
    CALL	_comandoLCD	    ; Clear Display
    
    RETURN

;/**@brief ESTA RUTINA GENERA UN RETARDO DE 15 MS
;*/
_iniLCD8bits:
    CALL	_RETARDO_15MS
    MOV		#0X30, W0
    CALL	_comandoLCD	    ; Function Set
    
    CALL	_RETARDO_15MS
    MOV		#0X30, W0
    CALL	_comandoLCD	    ; Function Set
    
    CALL	_RETARDO_15MS
    MOV		#0X30, W0
    CALL	_comandoLCD	    ; Function Set
    
    CALL	_busyFlagLCD
    MOV		#0X38, W0
    CALL	_comandoLCD	    ; Function Set
    
    CALL	_busyFlagLCD
    MOV		#0X08, W0
    CALL	_comandoLCD	    ; Display ON / OFF
    
    CALL	_busyFlagLCD
    MOV		#0X01, W0
    CALL	_comandoLCD	    ; Clear Display
    
    CALL	_busyFlagLCD
    MOV		#0X06, W0
    CALL	_comandoLCD	    ; Entry Mode Set
    
    CALL	_busyFlagLCD
    MOV		#0X0F, W0
    CALL	_comandoLCD	    ; Display ON / OFF
   
    RETURN

;/**@brief ESTA RUTINA GENERA UN RETARDO DE 15 MS
;*/
_busyFlagLCD:
    BCLR	PORTD, #RS_LCD
    NOP
    SETM.B	TRISB
    NOP
    BSET	PORTD, #RW_LCD
    NOP
    BSET	PORTD, #EN_LCD
    NOP

ESPERAR_LCD:
    BTSC	PORTB,	#RB7
    GOTO	ESPERAR_LCD
    
    BCLR	PORTD, #EN_LCD
    NOP
    BCLR	PORTD, #RW_LCD
    NOP
    CLR.B	TRISB
    NOP
    RETURN

;/**@brief ESTA RUTINA GENERA UN RETARDO DE 15 MS
;*/
_imprimeLCD:
    PUSH	W1
    MOV		W0, W1
    
CICLO_DATO: 
    MOV.B	[W1++], W0
    CP0.B	W0
    BRA		Z, FIN_IMPRIME
    
    CALL	_busyFlagLCD
    CALL	_datoLCD
    BRA		CICLO_DATO
    
FIN_IMPRIME:
    POP		W1
    RETURN

;/**@brief ESTA RUTINA GENERA UN RETARDO DE 15 MS
;*/
_datoLCD:
    BSET	PORTD, #RS_LCD	    ;RS = 1 
    NOP
    BCLR	PORTD, #RW_LCD
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
    BCLR	PORTD, #RS_LCD	    ;RS = 0 
    NOP
    BCLR	PORTD, #RW_LCD
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

;******************************************************************************
;DESCRICION:	ESTA RUTINA GENERA UN RETARDO DE 1S
;PARAMETROS: 	NINGUNO
;RETORNO: 		NINGUNO
;******************************************************************************
_RETARDO_1S:
		PUSH	W0
		PUSH	W1
		
		MOV		#10,			W1
CICLO2_1S:
		
		CLR		W0
CICLO1_11S:
		DEC		W0,				W0
		BRA		NZ,				CICLO1_11S

		DEC		W1,				W1
		BRA		NZ,				CICLO2_1S

		POP		W1
		POP		W0
		RETURN

;/**@brief ESTA RUTINA GENERA UN RETARDO DE 15 MS
;*/
__ADCInterrupt:
    PUSH	W0
    PUSH	W1
    PUSH	W2
    
    MOV		ADCBUF0, W0
    LSR		W0, #6, W1
    BSET	W1, #7
    MOV		#0X003F, W2
    AND		W0, W2, W0
    MOV		W0, U1TXREG
    MOV		W1, U1TXREG
    
    POP		W2
    POP		W1
    POP		W0
    BCLR	IFS0, #ADIF
    
    RETFIE