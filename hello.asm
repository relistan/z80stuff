; Hello world on CP/M with z80 assembly
;
; Karl Matthias -- 2022-02-19

BDOS  equ 5

  org 0100h

  jr start

msg: BYTE "\r\nHello, World!\r\n$"

; BDOS call to print a character to console
; e must contain the char to print
print_char:
  ld    c, 2 
  call  BDOS
  ret

; BDOS call to print a string to console
; de must contain address of string, terminated with $
print_string:
  ld    c, 9          ; CP/M write string to console call
  call  BDOS
  ret
  
; BDOS call to exit and return to CP
; No args
reset:
  ld    c, 0          ; CP/M system reset call - shut down
  call  BDOS
  
start:
  ld    e,'k'
  call  print_char    ; Print the letter 'k'

  ld    de, msg
  call  print_string  ; Print the msg string

  call  reset  
  halt                ; This code is never reached
