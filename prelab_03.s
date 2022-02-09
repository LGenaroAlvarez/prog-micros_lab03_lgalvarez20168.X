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
    CALL CLK_CONFIG
    CALL TMR0_CONFIG
    CALL IO_CONFIG
    
//----------------------------RESTART LOOP MAIN---------------------------------
 loop:
    BTFSS T0IF
    GOTO loop
    
    CALL TMR0_RESTART
    INCF PORTD
    GOTO loop

//------------------------------CONFIGURACION IO--------------------------------
IO_CONFIG:
    BANKSEL ANSEL
    CLRF ANSEL
    CLRF ANSELH
    BANKSEL PORTD
    CLRF PORTD
    BANKSEL TRISD
    BCF TRISD, 0
    BCF TRISD, 1
    BCF TRISD, 2
    BCF TRISD, 3
    RETURN
    
//--------------------------------SUB-RUTINAS-----------------------------------
CLK_CONFIG:
    BANKSEL OSCCON
    BSF SCS			; USAR OSCILADOR INTERNO PARA RELOJ DE SISTEMA
    BSF IRCF0			; BIT 4 DE OSCCON EN 1
    BCF IRCF1			; BIT 5 DE OSCCON EN 0
    BSF IRCF2			; BIT 6 DE OSCCON EN 1
    //OSCCON 101 -> 2MHz RELOJ INTERNO
    RETURN
    
TMR0_CONFIG:
    BANKSEL OPTION_REG
    BCF PSA			; PRESCALER A TMR0
    BSF PS2
    BSF PS1
    BSF PS0			; PRESCALER 1:256
    BCF T0CS			; TMR0 MODO CONTADOR
    
    BANKSEL TMR0
    MOVLW 61			; DELAY DE 100mS
    MOVWF TMR0			; CARGAR VALOR AL TMR0
    BCF T0IF			; LIMPIAR BANDERA
    RETURN
    
TMR0_RESTART:
    BANKSEL TMR0
    MOVLW 61
    MOVWF TMR0
    BCF T0IF
    RETURN
    
END