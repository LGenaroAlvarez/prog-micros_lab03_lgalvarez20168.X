; Archivo: lab03_lg20168.s
; Dispositivo: PIC16F887
; Autor: Luis Genaro Alvarez Sulecio
; Compilador: pic-as (v2.30), MPLABX V5.40
;
; Programa: CONTADOR HEXADECIMAL
; Hardware: 7 SEGMENT DISPLAY
;
; Creado: 9 feb, 2022
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
 ORG 80h			; Posición del código
 
//---------------------------INDICE DISPLAY 7SEG--------------------------------
PSECT HEX_INDEX, class = CODE, abs, delta = 2
ORG 100h

HEX_INDEX:
    CLRF PCLATH
    BSF PCLATH, 0		; PCLATH en 01
    ANDLW 0X0F
    ADDWF PCL			; PC = PCLATH + PCL | SUMAR W CON PCL PARA INDICAR POSICIÓN EN PC
    retlw 00111111B		; 0
    retlw 00000110B		; 1
    retlw 01011011B		; 2
    retlw 01001111B		; 3
    retlw 01100110B		; 4
    retlw 01101101B		; 5
    retlw 01111101B		; 6
    retlw 00000111B		; 7
    retlw 01111111B		; 8 
    retlw 01101111B		; 9
 
//----------------------------------MAIN----------------------------------------
main:
    CALL IO_CONFIG		; INICIAR CONFIGURACIÓN DE PINES
    CALL CLK_CONFIG		; INICIAR CONFIGURACIÓN DE RELOJ
    BANKSEL PORTA		; MANTENER PORTA ACCESIBLE
    
//------------------------------LOOP PRINCIPAL----------------------------------
loop:
    BTFSC RB0			; REVISAR SI EL PIN 0 DEL PORTB ESTA ACTIVADO, SI NO, SALTAR LA INSTRUCCION SIGUIENTE
    CALL INC_CONT		; ACCEDER SUBRUTINA DE INCREMENTO
    BTFSC RB1			; REVISAR SI EL PIN 1 DEL PORTB ESTÁ ACTIVADO, SI NO, SALTAR LA INSTRUCCION SIGUIENTE
    CALL DEC_CONT		; ACCEDER SUBRUTINA DE INCREMENTO
    
    MOVF PORTD, W
    CALL HEX_INDEX
    MOVWF PORTC
    GOTO loop

//-----------------------------CONFIGURACION IO---------------------------------
IO_CONFIG:
    BANKSEL ANSEL
    CLRF ANSEL
    CLRF ANSELH
    
    BANKSEL PORTA
    CLRF PORTA
    CLRF PORTB
    CLRF PORTC
    CLRF PORTD
    BANKSEL TRISA
    CLRF TRISA
    CLRF TRISC
    CLRF TRISD
    BSF TRISB, 0
    BSF TRISB, 1
    RETURN

//---------------------------------SUB-RUTINAS----------------------------------
CLK_CONFIG:
    BANKSEL OSCCON
    BSF SCS
    BSF IRCF0
    BCF IRCF1
    BSF IRCF2
    RETURN

INC_CONT:
    BTFSC RB0
    GOTO $-1
    
    INCF PORTD, 1
    RETURN
    
DEC_CONT:
    BTFSC RB1
    GOTO $-1
    
    DECF PORTD, 1
    RETURN

END