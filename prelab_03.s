; Archivo: prelab_03.s
; Dispositivo: PIC16F887
; Autor: Luis Genaro Alvarez Sulecio
; Compilador: pic-as (v2.30), MPLABX V5.40
;
; Programa: contador 4bits TIMER0
; Hardware: 
;
; Creado: 7 feb, 2022
; Última modificación: 9 feb, 2022

; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

PROCESSOR 16F887    
    
//---------------------------CONFIGURACION WORD1--------------------------------
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = ON            ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

//---------------------------CONFIGURACION WORD2--------------------------------
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

// config statements should precede project file includes.
#include <xc.inc>

 //-----------------------------Vector reset------------------------------------
 PSECT resVect, class = CODE, abs, delta = 2;
 ORG 00h			; Posición 0000h RESET
 resetVec:			; Etiqueta para el vector de reset
    PAGESEL main
    goto main
    
 PSECT code, delta = 2, abs
 ORG 100h			; Posición del código
 
//----------------------------------MAIN----------------------------------------
main:
    CALL IO_CONFIG		; INICIAR CONFIGURACIÓN DE PUERTOS
    CALL CLK_CONFIG		; INICIAR CONFIGURACIÓN DE OSCILADOR
    CALL TMR0_CONFIG		; INICIAR CONFIGURACIÓN DE TMR0
    
    
//----------------------------RESTART LOOP MAIN---------------------------------
 loop:				; LOOP PRINCIPAL PARA CONTADOR CON BASE A BANDERA DE TMR0
    BTFSS T0IF			; REVISAR BANDERA OVERFLOW DEL TMR0
    GOTO loop
    
    CALL TMR0_RESTART		; REINICIAR EL TMR0
    INCF PORTD			; INCREMENTAR LA CUENTA EN PORTD
    GOTO loop

//------------------------------CONFIGURACION IO--------------------------------
IO_CONFIG:			; CONFIGURACIÓN DE PUERTOS
    BANKSEL ANSEL		; SELECCIONAR ANSEL
    CLRF ANSEL			; PORTA COMO DIGITAL
    CLRF ANSELH			; PORTB COMO DIGITAL
    BANKSEL PORTD		; SELECCIONAR PORTD
    CLRF PORTD			; LIMPIAR PORTD
    BANKSEL TRISD		; CONFIGURAR SALIDAS DE PORTD
    BCF TRISD, 0		; PIN 0 COMO SALIDA
    BCF TRISD, 1		; PIN 1 COMO SALIDA
    BCF TRISD, 2		; PIN 2 COMO SALIDA
    BCF TRISD, 3		; PIN 3 COMO SALIDA
    RETURN
    
//--------------------------------SUB-RUTINAS-----------------------------------
CLK_CONFIG:			; CONFIGURACIÓN DEL OSCILADOR
    BANKSEL OSCCON		; SELECCIONAR CONFIGURADOR DEL OSCILADOR
    BSF SCS			; USAR OSCILADOR INTERNO PARA RELOJ DE SISTEMA
    BSF IRCF0			; BIT 4 DE OSCCON EN 1
    BCF IRCF1			; BIT 5 DE OSCCON EN 0
    BSF IRCF2			; BIT 6 DE OSCCON EN 1
    //OSCCON 101 -> 2MHz RELOJ INTERNO
    RETURN
    
TMR0_CONFIG:			; CONFIGURACIÓN DEL TMR0
    BANKSEL OPTION_REG		; SELECCIONAR OPTION REGISTER
    BCF PSA			; PRESCALER A TMR0
    BSF PS2			; PS2 EN 1
    BSF PS1			; PS1 EN 1
    BSF PS0			; PS0 EN 1 -> 111 = PRESCALER 1:256
    BCF T0CS			; TMR0 MODO CONTADOR
    
    BANKSEL TMR0		; SELECCIONAR TIMER0
    MOVLW 61			; DELAY DE 100mS CALCULADO CON ECUACIÓN DE TEMPORIZADOR
    MOVWF TMR0			; CARGAR VALOR AL TMR0
    BCF T0IF			; LIMPIAR BANDERA
    RETURN
    
TMR0_RESTART:			; CONFIGURACIÓN DEL REINICIO DEL TMR0
    BANKSEL TMR0		; SELECCIONAR TIMER0
    MOVLW 61			; DELAY DE 100mS
    MOVWF TMR0			; CARGAR VALOR AL TMR0
    BCF T0IF			; LIMPIAR BANDERA
    RETURN
    
END