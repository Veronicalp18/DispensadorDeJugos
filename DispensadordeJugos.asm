    List P=16F887 ; ;Tipo de procesador a usar 
    #include "p16f887.inc"
; CONFIG1
; __config 0xFCF1
 __CONFIG _CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_ON & _FCMEN_ON & _LVP_ON
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

 conteo equ 0x00
 PCL equ 0x02
 cont1 equ 0x20
 cont2 equ 0x21
 diferencia equ 0x22
 dollar equ 0x23
 centavo equ 0x24
 
    ORG 0x00; Inicio del programa 
    GOTO Inicio
 
Inicio 
  BCF STATUS, RP0; Accede al banco 0
  BCF STATUS, RP1
  CLRF PORTB; Limpia el PORTB
  CLRF PORTD; Limpia el PORTD
  CLRF PORTC; Limpia el PORTC
  CLRF PORTE; Limpia el PORTE
  BSF STATUS, RP0; Accede al banco 1
  CLRF TRISB; Configura todas las patitas de PORTB como salidas
  CLRF TRISD; Configura todas las patitas del PORTD como salidas
  CLRF TRISE; Configuramos todas las patitas del PORTE como salida
  MOVLW b'10111111'; Declaracion de entradas en el PORTC
  MOVWF TRISC; Cargo el valor al Trisc
  BCF STATUS, RP0; Regresa al banco 0 
  BSF STATUS, RP0
  BSF STATUS, RP1
  CLRF ANSELH
  BCF STATUS, RP0; Vuelve al banco 0
  BCF STATUS, RP1
  CALL inicio_uart
  MOVLW 0X00
  MOVWF diferencia
  MOVWF dollar
  MOVWF centavo

Jugos
    BTFSC PORTC,0 
    GOTO Jugo1
    BTFSC PORTC,1
    GOTO Jugo2
    GOTO Jugos

Jugo1
    MOVLW b'001'
    MOVWF PORTE
    CALL Retardo
    BTFSC PORTC,0 
    GOTO TamañoM
    BTFSC PORTC,1
    GOTO TamañoG
    GOTO Jugo1
        
Jugo2
    MOVLW b'010'
    MOVWF PORTE
    CALL Retardo 
    BTFSC PORTC,0 
    GOTO TamañoM1
    BTFSC PORTC,1
    GOTO TamañoG1
    GOTO Jugos

TamañoM
    CALL Retardo
    MOVLW b'011'
    MOVWF PORTE
    CALL Retardo
    MOVLW 0x00
    MOVWF PORTE
    MOVLW 0x01
    MOVWF dollar
    CALL DisplayDollar
    MOVLW 0x02
    MOVWF centavo
    CALL DisplayCentavo
  
    BTFSC PORTC,2; Boton 3 para activar 
    GOTO Activar
    BTFSC PORTC,3
    GOTO Inicio 
    GOTO TamañoM

TamañoG
    CALL Retardo 
    MOVLW b'101'
    MOVWF PORTE
    CALL Retardo
    MOVLW 0x00
    MOVWF PORTE
    MOVLW 0x02
    MOVWF dollar
    CALL DisplayDollar
    MOVLW 0x05
    MOVWF centavo
    CALL DisplayCentavo
    INCF diferencia,1;Me incrementa en uno 
    BTFSC PORTC,2; Boton 3 para activar 
    GOTO Activar
    BTFSC PORTC,3
    GOTO Inicio 
    GOTO TamañoG
    
TamañoM1
    CALL Retardo
    MOVLW b'110'
    MOVWF PORTE
    CALL Retardo
    MOVLW 0x00
    MOVWF PORTE
    MOVLW 0x01
    MOVWF dollar
    CALL DisplayDollar
    MOVLW 0x05
    MOVWF centavo
    CALL DisplayCentavo
    BTFSC PORTC,2; Boton 3 para activar 
    GOTO Activar
    BTFSC PORTC,3
    GOTO Inicio
    GOTO TamañoM1
    
TamañoG1
    CALL Retardo
    MOVLW b'111'
    MOVWF PORTE
    CALL Retardo
    MOVLW 0x00
    MOVWF PORTE
    MOVLW 0x03
    MOVWF dollar
    CALL DisplayDollar
    MOVLW 0x02
    MOVWF centavo
    CALL DisplayCentavo
    INCF diferencia,1;Me incrementa en uno 
    BTFSC PORTC,2; Boton 3 para activar
    GOTO Activar
    BTFSC PORTC,3
    GOTO Inicio
    GOTO TamañoG1

Activar
    BTFSS diferencia,1
    GOTO Mediano
    GOTO Grande
    
Mediano
    CALL Retardo
    MOVLW b'001'
    MOVWF PORTE
    CALL Retardo
    CALL Retardo 
    MOVLW b'010'
    MOVWF PORTE
    CALL Retardo
    CALL Retardo
    CALL Retardo
    MOVLW b'100'
    MOVWF PORTE
    MOVLW 0x00
    MOVWF PORTE
    GOTO Completo
    
Grande
    CALL Retardo
    MOVLW b'001'
    MOVWF PORTE
    CALL Retardo
    CALL Retardo
    CALL Retardo
    MOVLW b'010'
    MOVWF PORTE
    CALL Retardo
    CALL Retardo 
    CALL Retardo
    
Completo
    MOVLW b'100'
    MOVWF PORTE
    CALL SEND_DATA
    CALL Retardo 
    MOVLW 0x00
    MOVWF PORTE
    CALL Retardo
    GOTO Completo
    
DisplayDollar 
	movf dollar,0
	call Tabla
	movwf PORTB
	RETURN  

DisplayCentavo
	movf centavo,0
	call Tabla
	movwf PORTD
	RETURN 
	  
Tabla
    ADDWF PCL,f
    RETLW 3Fh ; //Valor 0 en hexadecimal para el display
    RETLW 06h; //Valor  1 en hexadecimal para el display
    RETLW 5Bh ; //Valor 2 en hexadecimal para el display
    RETLW 4Fh ; //Valor 3 en hexadecimal para el display
    RETLW 66h ; //Valor 4 en hexadecimal para el display
    RETLW 6Dh ; //Valor 5 en hexadecimal para el display
    RETLW 7Ch ; //Valor 6 en hexadecimal para el display
    RETLW 07h ; //Valor 7 en hexadecimal para el display
    RETLW 7Fh ; //Valor 8 en hexadecimal para el display
    RETLW 6Fh ; //Valor 9 en hexadecimal para el display
    RETURN 

inicio_uart  
          bsf     STATUS,RP0     ; Bank01
          bcf     STATUS,RP1
          movlw   b'00100100'    ; Configuración USART
          movwf   TXSTA          ; y activación de transmisión
          movlw   .25            ; 9600 baudios
          movwf   SPBRG
          bcf     STATUS,RP0     ; Bank00
          movlw   b'10010000'    ; Configuración del USART para recepción continua
          movwf   RCSTA          ; Puesta en ON
	  return
	      
SEND_DATA movf dollar,0
	  addlw 0x30
	  CALL TX_DATO1
	  movlw 0x2C ; Coma para el sistema
	  CALL TX_DATO1
	  movf centavo,0
	  addlw 0x30
	  CALL TX_DATO1
	  movlw 0x0A;numero \r
	  CALL TX_DATO1
	  movlw 0x0d;numero \n
	  CALL TX_DATO1
	  return  
	  
TX_DATO1  bcf     PIR1,TXIF      ; Restaura el flag del transmisor
	  movwf   TXREG          ; Mueve el byte a transmitir al registro de transmision
          bsf     STATUS,RP0     ; Bank01
          bcf     STATUS,RP1
	  
TX_DAT_1  btfss   TXSTA,TRMT     ; ¿Byte transmitido?
          goto    TX_DAT_1       ; No, esperar
          bcf     STATUS,RP0     ; Si, vuelta a Bank00
          return    
	  
Retardo    
    MOVLW 0X20; W se carga con el número 20h (Comienza la llamada)
    MOVWF cont2; y se pasa a cont2

Retardo1 
    MOVLW 0X30; W se carga con el número 30h
    MOVWF cont1; y se pasa a cont1

Retardo2      
    MOVLW 0X50; W se carga con el número 50h
    MOVWF conteo; y se pasa a conteo

Retardo3    
    DECFSZ conteo,1; Le resta una unidad a conteo
    GOTO Retardo3; sigue decrementando hasta que conteo llegue a 0
    DECFSZ cont1,1; Le resta una unidad a cont1 cuando conteo llegue a 0
    GOTO Retardo2; vuelve a cargar conteo y se repite la rutina Retardo3
    DECFSZ cont2,1; Le resto una unidad a cont2 cuando cont1 llegue a 0
    GOTO Retardo1; vuelve a cargar cont1 y conteo, se repite la rutina de la Retardo2
    RETURN; Termina la llamada y regresa 
    
End