; Archivo: lab03_lg20168.s
; Dispositivo: PIC16F887
; Autor: Luis Genaro Alvarez Sulecio
; Compilador: pic-as (v2.30), MPLABX V5.40
;
; Programa: CONTADOR HEXADECIMAL
; Hardware: 7 SEGMENT DISPLAY
;
; Creado: 9 feb, 2022
; �ltima modificaci�n: 12 feb, 2022

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

 PSECT udata_bank0
    Cont10:   DS 1		; DEFINIR VARIABLE PARA INTERVALOS DE 10 DEL TMR0
    Cont0:  DS 2		; DEFINIR VARIABLE PARA CONTADOR DE DISPLAY 7SEG
  
 //-----------------------------Vector reset------------------------------------
 PSECT resVect, class = CODE, abs, delta = 2;
 ORG 00h			; Posici�n 0000h RESET
 resetVec:			; Etiqueta para el vector de reset
    PAGESEL main
    goto main
  
 PSECT code, delta = 2, abs
 ORG 100h			; Posici�n del c�digo

//---------------------------INDICE DISPLAY 7SEG--------------------------------
PSECT HEX_INDEX, class = CODE, abs, delta = 2
ORG 200h			; POSICI�N DE LA TABLA

HEX_INDEX:
    CLRF PCLATH
    BSF PCLATH, 1		; PCLATH en 01
    ANDLW 0x0F
    ADDWF PCL			; PC = PCLATH + PCL | SUMAR W CON PCL PARA INDICAR POSICI�N EN PC
    RETLW 00111111B		; 0
    RETLW 00000110B		; 1
    RETLW 01011011B		; 2
    RETLW 01001111B		; 3
    RETLW 01100110B		; 4
    RETLW 01101101B		; 5
    RETLW 01111101B		; 6
    RETLW 00000111B		; 7
    RETLW 01111111B		; 8 
    RETLW 01101111B		; 9
    RETLW 01110111B		; A
    RETLW 01111100B		; b
    RETLW 00111001B		; C
    RETLW 01011110B		; D
    RETLW 01111001B		; C
    RETLW 01110001B		; F
 
//----------------------------------MAIN----------------------------------------
main:
    CALL IO_CONFIG		; INICIAR CONFIGURACI�N DE PINES
    CALL CLK_CONFIG		; INICIAR CONFIGURACI�N DE RELOJ
    CALL TMR0_CONFIG		; INICIAR CONFIGURACI�N DE TMR0
    BANKSEL PORTA		; MANTENER PORTA ACCESIBLE
    
//------------------------------LOOP PRINCIPAL----------------------------------
loop:
    CALL TMR0_LOOP		; ACCEDER SUBRUTINA DEL CONTADOR TMR0
    
    BTFSC PORTB, 0		; REVISAR SI EL PIN 0 DEL PORTB ESTA ACTIVADO, SI NO, SALTAR LA INSTRUCCION SIGUIENTE
    CALL INC_CONT		; ACCEDER SUBRUTINA DE INCREMENTO
    BTFSC PORTB, 1		; REVISAR SI EL PIN 1 DEL PORTB EST� ACTIVADO, SI NO, SALTAR LA INSTRUCCION SIGUIENTE
    CALL DEC_CONT		; ACCEDER SUBRUTINA DE INCREMENTO
    
    MOVF Cont0, W		; MOVER EL VALOR EN PORTD (LA CUENTA) AL REGISTRO W
    CALL HEX_INDEX		; LLAMAR TABLA DE INDEXADO PARA DISPLAY DE 7 SEGMENTOS
    MOVWF PORTC			; CARGAR VALOR EN REGISTRO W AL PORTC PARA MOSTRAR VALOR EN DISPLAY
    GOTO loop


//-----------------------------CONFIGURACION IO---------------------------------
IO_CONFIG:
    BANKSEL ANSEL		; SEECCIONAR BANCO 3
    CLRF ANSEL			; PORTA COMO DIGITAL
    CLRF ANSELH			; PORTB COMO DIGITAL
    
    BANKSEL PORTA		; SELECCIONAR BANCO 1
    CLRF PORTA			; LIMPIAR VALORES EN PORTA
    CLRF PORTB			; LIMPIAR VALORES EN PORTB
    CLRF PORTC			; LIMPIAR VALORES EN PORTC
    CLRF PORTD			; LIMPIAR VALORES EN PORTD
    CLRF PORTE			; LIMPIAR VALORES EN PORTE
    
    BANKSEL TRISA		; SELECCIONAR BANCO 2
    BCF TRISA, 0		; PIN 0 PORTA COMO SALIDA
    BCF TRISA, 1		; PIN 1 PORTA COMO SALIDA
    BCF TRISA, 2		; PIN 2 PORTA COMO SALIDA
    BCF TRISA, 3		; PIN 3 PORTA COMO SALIDA
    CLRF TRISC			; SETEAR PORTC COMO SALIDA
    BSF TRISB, 0		; SETEAR PORTB PIN 0 COMO ENTRADA
    BSF TRISB, 1		; SETEAR PORTB PIN 1 COMO ENTRADA
    BCF TRISD, 0		; PIN 0 PORTD COMO SALIDA
    BCF TRISD, 1		; PIN 1 PORTD COMO SALIDA
    BCF TRISD, 2		; PIN 2 PORTD COMO SALIDA
    BCF TRISD, 3		; PIN 3 PORTD COMO SALIDA
    BCF TRISE, 0		; PIN 0 PORTE COMO SALIDA
    RETURN

//---------------------------------SUB-RUTINAS----------------------------------
CLK_CONFIG:			; CONFIGURACI�N DEL OSCILADOR
    BANKSEL OSCCON		; SELECCIONAR CONFIGURADOR DEL OSCILADOR
    BSF SCS			; USAR OSCILADOR INTERNO PARA RELOJ DE SISTEMA
    BSF IRCF0			; BIT 4 DE OSCCON EN 1
    BCF IRCF1			; BIT 5 DE OSCCON EN 0
    BSF IRCF2			; BIT 6 DE OSCCON EN 1
    //OSCCON 101 -> 2MHz RELOJ INTERNO
    RETURN

TMR0_CONFIG:			; CONFIGURACI�N DEL TMR0
    BANKSEL OPTION_REG		; SELECCIONAR OPTION REGISTER
    BCF PSA			; PRESCALER A TMR0
    BSF PS2			; PS2 EN 1
    BSF PS1			; PS1 EN 1
    BSF PS0			; PS0 EN 1 -> 111 = PRESCALER 1:256
    BCF T0CS			; TMR0 MODO TIMER
    
    BANKSEL TMR0		; SELECCIONAR TIMER0
    MOVLW 61			; DELAY DE 100mS CALCULADO CON ECUACI�N DE TEMPORIZADOR
    MOVWF TMR0			; CARGAR VALOR AL TMR0
    BCF T0IF			; LIMPIAR BANDERA
    RETURN
    
TMR0_RESTART:			; CONFIGURACI�N DEL REINICIO DEL TMR0
    BANKSEL TMR0		; SELECCIONAR TIMER0
    MOVLW 61			; DELAY DE 100mS
    MOVWF TMR0			; CARGAR VALOR AL TMR0
    BCF T0IF			; LIMPIAR BANDERA
    RETURN    
    
//--------------------------------LOOP TIMER0-----------------------------------    
TMR0_LOOP:
    BTFSS T0IF			; REVISAR BANDERA OVERFLOW DEL TMR0
    GOTO TMR0_LOOP
    
    CALL TMR0_RESTART		; REINICIAR EL TMR0
    INCF Cont10			; INCREMENTAR LA CUENTA DEL CONTADOR EN SEGUNDOS
    INCF PORTA			; INCREMENTAR LA CUENTA DEL TMR0
    BTFSS Cont10, 1		; REVISAR SI EL BIT 2 DE LA VARIABLE DE CONTEO DE SEGUNDOS EST� EN 1
    RETURN			; REGRESAR SI ESTABA EN 0
    BTFSS Cont10, 3		; REVISAR SI EL BIT 4 DE LA VARIABLE DE CONTEO DE SEGUNDOS EST� EN 1
    RETURN			; REGRESAR SI ESTABA EN 0
    CLRF Cont10			; PUESTO QUE EL CONTADOR HA LLEGADO A 10 LIMPIAR LA VARIABLE DE CONTEO
    INCF PORTD			; INCREMENTAR PORTD YA QUE UN SEGUNDO HA TRANSCURRIDO
    CALL SIM_TEST		; INICIAR SUBRUTINA PARA COMPARAR CONTADORES
    RETURN
        
SIM_TEST:
    MOVF PORTD, W		; CARGAR VALOR DEL PORTD AL REGISTRO W
    SUBWF Cont0, W		; RESTAR EL VALOR DEL PORTD A LA VARIABLE DEL CONTADOR DEL DISPLAY
    BTFSC ZERO			; REVISAR SI LA BANDERA DE CEROS ESTA ENCENDIDA, SI NO REGRESAR
    CALL ALARMA			; SI LA BANDERA ESTA ENCENDIDA, INICIAR SUBRUTINA DE ALARMA
    RETURN
    
ALARMA:
    CLRF PORTD			; LIMPIAR PORTD
    CLRF Cont10			; LIMPIAR VARIABLE DE CONTEO DE SEGUNDOS PARA REINICIAR DICHO CONTEO
    INCF PORTE			; SUMAR 1 AL PORTE PARA CAMBIAR EL ESTADO DEL LED DE ALARMA
    RETURN
    
INC_CONT:
    BTFSC PORTB, 0		; REVISAR SI EL BOTON YA NO ESTA PRESIONADO (SI EL VALOR DEL PIN RB0 ES 0) SI ES 1 MANTENER EL LOOP
    GOTO $-1
    
    INCF Cont0, 1		; INCREMENTAR LA CUENTA EN LA VARIABLE PARA EL CONTADOR DE 7SEG
    RETURN
    
DEC_CONT:
    BTFSC PORTB, 1		; REVISAR SI EL BOTON YA NO ESTA PRESIONADO (SI EL VALOR DEL PIN RB1 ES 0) SI ES 1 MANTENER EL LOOP
    GOTO $-1
    
    DECF Cont0, 1		; DISMINUIR LA CUENTA EN LA VARIABLE PARA EL CONTADOR DE 7SEG
    RETURN

END