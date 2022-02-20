; Hello world on CP/M with z80 assembly
;     For assembly with sjasmplus
;
; Karl Matthias -- 2022-02-19

BDOS  equ 5

  org 0100h
  jr start

msg: BYTE "\r\nHello, World!\r\n",255

; Color code will have the color segment overwritten when set_color
; is called.
color_code: BYTE 27,"[38;5;000m",255

; Stores an ASCII representation of the number in HL into the
; memory pointed to by IX.
;
; Destroys:
;   a de hl ix
hl_itoa:
  ld    de, -100  ; start subtracting 100s
  call  .loop1
  ld    e, -10    ; then subtract 10s
  call  .loop1
  ld    e, -1     ; then 1s
.loop1:
  ld    a, '0'-1
.loop2:
  inc   a
  add   hl, de    ; subtract the value of de (add b/c de is neg)
  jr    c, .loop2 ; keep going if we didn't roll over

  sbc   hl, de    ; add the value back when we did roll over
  inc   ix        ; increment ix
  ld    (ix+0), a ; store the value of a at address of ix
  ret

; Sets the screen color by echoing an ANSI color code to the terminal
; using the BDOS output routines.
;
; Destroys
;   ix a de hl ix bc
set_color:
  ld    ix, color_code+6
  call  hl_itoa
  ld    de, color_code
  call  print_string
  ret

; BDOS call to set the string delimiter to 255 instead of '$'
set_string_delimiter:
  ld    e, 255
  ld    c, 6Eh
  call  BDOS
  ret

; BDOS call to print a character to console
; e must contain the char to print
print_char:
  ld    c, 2 
  call  BDOS
  ret

; BDOS call to print a string to console
; de must contain address of string, terminated with $
print_string:
  ld    c, 9           ; CP/M write string to console call
  call  BDOS
  ret

draw_color_bar:
  ld    a, 87         ; Starting color - 1
.loop:
  inc   a
  ld    l, a
  push  af
  call  set_color
  ld    e, '='
  call  print_char
  pop   af
  ld    b, 100         ; Ending color
  cp    b
  jr    nz, .loop
  ret

; BDOS call to exit and return to CP
; No args
reset:
  ld    c, 0          ; CP/M system reset call - shut down
  call  BDOS
  
start:
  call  set_string_delimiter  ; $ is a dumb string delimiter

  ld    e, '-'
  call  print_char    ; Print the character '-'

  ld    hl, 25
  call  set_color

  ld    e, '-'
  call  print_char    ; Print the character '-'

  ld    de, msg
  call  print_string  ; Print the msg string

  call  draw_color_bar

  ld    hl, 60
  call  set_color     ; Reset color before exiting

  call  reset  
  halt                ; This code is never reached
