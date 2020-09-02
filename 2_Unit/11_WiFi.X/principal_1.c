/**@brief: Este programa muestra los bloques de un 
 * programa en C embebido para el DSPIC, los bloques son:
 * BLOQUE 1. OPCIONES DE CONFIGURACION DEL DSC: OSCILADOR, WATCHDOG,
 * BROWN OUT RESET, POWER ON RESET Y CODIGO DE PROTECCION
 * BLOQUE 2. EQUIVALENCIAS Y DECLARACIONES GLOBALES
 * BLOQUE 3. ESPACIOS DE MEMORIA: PROGRAMA, DATOS X, DATOS Y, DATOS NEAR
 * BLOQUE 4. C�DIGO DE APLICACI�N
 * @device: DSPIC30F4013
 * @oscillator: FRC, 7.3728MHz
 */
#include "p30F4013.h"
/********************************************************************************/
/* 						BITS DE CONFIGURACI�N									*/	
/********************************************************************************/
/* SE DESACTIVA EL CLOCK SWITCHING Y EL FAIL-SAFE CLOCK MONITOR (FSCM) Y SE 	*/
/* ACTIVA EL OSCILADOR INTERNO (FAST RC) PARA TRABAJAR							*/
/* FSCM: PERMITE AL DISPOSITIVO CONTINUAR OPERANDO AUN CUANDO OCURRA UNA FALLA 	*/
/* EN EL OSCILADOR. CUANDO OCURRE UNA FALLA EN EL OSCILADOR SE GENERA UNA 		*/
/* TRAMPA Y SE CAMBIA EL RELOJ AL OSCILADOR FRC  								*/
/********************************************************************************/
//_FOSC(CSW_FSCM_OFF & FRC); 
#pragma config FOSFPR = FRC             // Oscillator (Internal Fast RC (No change to Primary Osc Mode bits))
#pragma config FCKSMEN = CSW_FSCM_OFF   // Clock Switching and Monitor (Sw Disabled, Mon Disabled)/********************************************************************************/
/* SE DESACTIVA EL WATCHDOG														*/
/********************************************************************************/
//_FWDT(WDT_OFF); 
#pragma config WDT = WDT_OFF            // Watchdog Timer (Disabled)
/********************************************************************************/
/* SE ACTIVA EL POWER ON RESET (POR), BROWN OUT RESET (BOR), 					*/	
/* POWER UP TIMER (PWRT) Y EL MASTER CLEAR (MCLR)								*/
/* POR: AL MOMENTO DE ALIMENTAR EL DSPIC OCURRE UN RESET CUANDO EL VOLTAJE DE 	*/	
/* ALIMENTACI�N ALCANZA UN VOLTAJE DE UMBRAL (VPOR), EL CUAL ES 1.85V			*/
/* BOR: ESTE MODULO GENERA UN RESET CUANDO EL VOLTAJE DE ALIMENTACI�N DECAE		*/
/* POR DEBAJO DE UN CIERTO UMBRAL ESTABLECIDO (2.7V) 							*/
/* PWRT: MANTIENE AL DSPIC EN RESET POR UN CIERTO TIEMPO ESTABLECIDO, ESTO 		*/
/* AYUDA A ASEGURAR QUE EL VOLTAJE DE ALIMENTACI�N SE HA ESTABILIZADO (16ms) 	*/
/********************************************************************************/
//_FBORPOR( PBOR_ON & BORV27 & PWRT_16 & MCLR_EN ); 
// FBORPOR
#pragma config FPWRT  = PWRT_16          // POR Timer Value (16ms)
#pragma config BODENV = BORV20           // Brown Out Voltage (2.7V)
#pragma config BOREN  = PBOR_ON          // PBOR Enable (Enabled)
#pragma config MCLRE  = MCLR_EN          // Master Clear Enable (Enabled)
/********************************************************************************/
/*SE DESACTIVA EL C�DIGO DE PROTECCI�N											*/
/********************************************************************************/
//_FGS(CODE_PROT_OFF);      
// FGS
#pragma config GWRP = GWRP_OFF          // General Code Segment Write Protect (Disabled)
#pragma config GCP = CODE_PROT_OFF      // General Segment Code Protection (Disabled)

/********************************************************************************/
/* SECCI�N DE DECLARACI�N DE CONSTANTES CON DEFINE								*/
/********************************************************************************/
#define EVER 1
#define MUESTRAS 64

/********************************************************************************/
/* DECLARACIONES GLOBALES														*/
/********************************************************************************/
/*DECLARACI�N DE LA ISR DEL TIMER 1 USANDO __attribute__						*/
/********************************************************************************/
void __attribute__((__interrupt__)) _T1Interrupt( void );

/********************************************************************************/
/* CONSTANTES ALMACENADAS EN EL ESPACIO DE LA MEMORIA DE PROGRAMA				*/
/********************************************************************************/
int ps_coeff __attribute__ ((aligned (2), space(prog)));
/********************************************************************************/
/* VARIABLES NO INICIALIZADAS EN EL ESPACIO X DE LA MEMORIA DE DATOS			*/
/********************************************************************************/
int x_input[MUESTRAS] __attribute__ ((space(xmemory)));
/********************************************************************************/
/* VARIABLES NO INICIALIZADAS EN EL ESPACIO Y DE LA MEMORIA DE DATOS			*/
/********************************************************************************/
int y_input[MUESTRAS] __attribute__ ((space(ymemory)));
/********************************************************************************/
/* VARIABLES NO INICIALIZADAS LA MEMORIA DE DATOS CERCANA (NEAR), LOCALIZADA	*/
/* EN LOS PRIMEROS 8KB DE RAM													*/
/********************************************************************************/
int var1 __attribute__ ((near));

void RETARDO_1S(void);
void iniPerifericos( void );
void iniLCD8bits();
void iniInterrupciones( void );
void initWiFi( void );
void configureWiFi( void );
void comandoAT(const char *);
void cerrarConexion(void);

void busyFlagLCD();
void comandoLCD(char);
void datoLCD(char);
void imprimeLCD(char *);
void clearLCD(void);
void unlockExternOsc(void);

char cmdRST[] = "AT+RST\r\n";
char cmdCWMODE[] = "AT+CWMODE=1\r\n";
char cmdCIPMUX[] = "AT+CIPMUX=0\r\n";
char cmdCWJAP[] = "AT+CWJAP=\"Daniela\",\"00000000\"\r\n"; // Join access point
char cmdCIFSR[] = "AT+CIFSR\r\n";
char cmdCIPSTART[] = "AT+CIPSTART=\"TCP\",\"192.168.43.220\",9000\r\n"; // Se conecta al servidor como cliente
char cmdCIPMODE[] = "AT+CIPMODE=1\r\n";
char cmdCIPSEND[] = "AT+CIPSEND\r\n";
char cmdCIPCLOSE[] = "AT+CIPCLOSE\r\n";
char cmdSTOPPT[] = "+++";

int main (void)
{       
    iniPerifericos();
    
    U1MODE = 0X0000;
    Nop();
    U1STA = 0X8000;
    Nop();
    U1BRG = 0;
    Nop();
    
    U2MODE = 0X0000;
    Nop();
    U2STA = 0X8000;
    Nop();
    U2BRG = 0;
    Nop();
    
    iniInterrupciones();
    
    U1MODEbits.UARTEN = 1;
    Nop();
    U1STAbits.UTXEN = 1;
    Nop();
    
    U2MODEbits.UARTEN = 1;
    Nop();
    U2STAbits.UTXEN = 1;
    Nop();
    
    initWiFi();
    configureWiFi();
    
    
    U1TXREG = 'H';
    U1TXREG = 'O';
    U1TXREG = 'L';
    U1TXREG = 'A';
    
    
    RETARDO_1S();
    
    cerrarConexion();
    
    for(;EVER;)
    {
        Nop();
    }
    
    return 0;
}

void configureWiFi(void)
{
    comandoAT(cmdRST);     // Reiniciar modulo WiFi
    RETARDO_1S();       RETARDO_1S();
    RETARDO_1S();       RETARDO_1S();       RETARDO_1S();   
    comandoAT(cmdCWMODE);  // Estableciendo CWMODE = 1
    RETARDO_1S();       RETARDO_1S();
    RETARDO_1S();       RETARDO_1S();       RETARDO_1S();
    comandoAT(cmdCIPMUX);  // Establecienod CIPMUX = 0
    RETARDO_1S();       RETARDO_1S();
    RETARDO_1S();       RETARDO_1S();       RETARDO_1S();
    comandoAT(cmdCWJAP);   // Conectando al punto de acceso
    RETARDO_1S();       RETARDO_1S();
    RETARDO_1S();       RETARDO_1S();       RETARDO_1S();
    comandoAT(cmdCIFSR);   // Obtener IP Local
    RETARDO_1S();       RETARDO_1S();
    RETARDO_1S();       RETARDO_1S();       RETARDO_1S();
    comandoAT(cmdCIPSTART);    // Conectandose
    RETARDO_1S();       RETARDO_1S();
    RETARDO_1S();       RETARDO_1S();       RETARDO_1S();
    comandoAT(cmdCIPMODE);     // Debemos dehabilitar el modo continuo
    RETARDO_1S();       RETARDO_1S();
    RETARDO_1S();       RETARDO_1S();       RETARDO_1S();
    comandoAT(cmdCIPSEND);     // Configuracion de cantidad de bytes
    RETARDO_1S();       RETARDO_1S();
    RETARDO_1S();       RETARDO_1S();       RETARDO_1S();
}

void cerrarConexion( void ){
    comandoAT(cmdSTOPPT);     // Detener el modo Passthrough
    RETARDO_1S();       RETARDO_1S();
    RETARDO_1S();       RETARDO_1S();       RETARDO_1S();   
    comandoAT(cmdCIPCLOSE);  // Cerrando la conexi�n
    RETARDO_1S();       RETARDO_1S();
    RETARDO_1S();       RETARDO_1S();       RETARDO_1S();
}

/****************************************************************************/
/* DESCRICION:	ESTA RUTINA INICIALIZA LAS INTERRPCIONES    				*/
/* PARAMETROS: NINGUNO                                                      */
/* RETORNO: NINGUNO															*/
/****************************************************************************/
void iniInterrupciones( void )
{
    IFS0bits.U1RXIF = 0;        //Interrupt Flag = 0
    //IFS0bits.U1TXIF = 0;        //Interrupt Flag = 0
    //IFS1bits.U2TXIF = 0;        //Interrupt Flag = 0
    
    IEC0bits.U1RXIE = 1;        //Interrupt Enable = 1
    //IEC0bits.U1TXIE = 1;        //Interrupt Enable = 1
    
    //IEC1bits.U2TXIE = 1;        //Interrupt Enable = 1
    
    //Habilitacion de interrupcion del perif�rico 1
    //Habilitacion de interrupcion del perif�rico 2
    //Habilitacion de interrupcion del perif�rico 3
}
/****************************************************************************/
/* DESCRICION:	ESTA RUTINA INICIALIZA LOS PERIFERICOS						*/
/* PARAMETROS: NINGUNO                                                      */
/* RETORNO: NINGUNO															*/
/****************************************************************************/
void iniPerifericos( void )
{
    PORTD = 0;
    Nop();
    LATD = 0;
    Nop();
    TRISD = 0;
    Nop();
    TRISDbits.TRISD0 = 0;
    Nop();
    
    PORTA = 0;
    Nop();
    LATA = 0;
    Nop();
    TRISA = 0;
    Nop();
    TRISAbits.TRISA11 = 0;
    Nop();
    
    PORTF = 0;
    Nop();
    LATF = 0;
    Nop();
    TRISF = 0;
    Nop();
    TRISFbits.TRISF2 = 1;
    Nop();
    TRISFbits.TRISF3 = 0;
    Nop();
    TRISFbits.TRISF4 = 1;
    Nop();
    TRISFbits.TRISF5 = 0;
    Nop();
}

/********************************************************************************/
/* DESCRICION:	ISR (INTERRUPT SERVICE ROUTINE) DEL TIMER 1						*/
/* LA RUTINA TIENE QUE SER GLOBAL PARA SER UNA ISR								*/	
/* SE USA PUSH.S PARA GUARDAR LOS REGISTROS W0, W1, W2, W3, C, Z, N Y DC EN LOS */
/* REGISTROS SOMBRA																*/
/********************************************************************************/
/*
void __attribute__((__interrupt__, no_auto_psv)) _U1RXInterrupt( void )
{
    // unsigned short int w;
    
    // w = U1RXREG;
    
    busyFlagLCD();
    datoLCD('A');
    
    IFS0bits.U1RXIF = 0;    //SE LIMPIA LA BANDERA DE INTERRUPCION DEL UART RX                      
}
*/