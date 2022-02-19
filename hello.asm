; Hello world on CP/M with z80 assembly
;
; Karl Matthias -- 2022-02-19

BDOS  equ 5

	org		0100h

	jr start

; e must contain the char to print
print_char:
	ld 		c, 02h
	call 	BDOS
	ret

; de must contain address of string, terminated with $
print_string:
	ld		c, 9    	; CP/M write string to console call
	call	BDOS
	ret
	
; No args
reset:
	ld		c, 0    	; CP/M system reset call - shut down
	call	BDOS
	

msg: BYTE "\r\nHello, World!$"

start:
	ld 		e,'k'
	call	print_char
	ld   	de, msg
	call 	print_string

	call	reset	
	halt						; This code is never reached
