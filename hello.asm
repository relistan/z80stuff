; Fancy Hello world on CP/M with z80 assembly
;   -- requires a 256 color terminal, which should be no issue in 2022
; 
; Assembler: sjasmplus (https://github.com/z00m128/sjasmplus)
; Debugging: ZSID (http://www.retroarchive.org/cpm/lang/lang.htm)
;
; Karl Matthias -- 2022-02-19

BDOS  equ 5

  org   0100h
  jp    start

; ------------------------------------------------------------------------------
; DATA
; ------------------------------------------------------------------------------
msg: BYTE "\r\n Hello, World!\r\n",255

; Color code will have the color segment overwritten when set_color
; is called.
color_code:     BYTE 27,"[38;5;000m",255
term_reset:     BYTE 27,"c",255
clrscrn:        BYTE 27,"[2J",255
back_black:     BYTE 27,"[48;5;0m",255
back_white:     BYTE 27,"[48;5;15m",255
color_intense:  BYTE 27,"[1m",255
color_normal:   BYTE 27,"[0m",255
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; FUNCTIONS
; ------------------------------------------------------------------------------

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
  ld    (ix), a   ; store the value of a at address of ix
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

; Draw a color bar starting from 16, up to 196
color_bar_up:
  ld    a, -20         ; Starting color - 36
.loop:
  add   a, 36
  ld    l, a
  push  af
  call  set_color
  ld    e, '='
  call  print_char
  pop   af
  ld    b, 196         ; Ending color
  cp    b
  jr    nz, .loop
  ret

; Draw a color bar starting from 196, down to 16
color_bar_down:
  ld    a, 232         ; Starting color + 36
.loop:
  add   a, -36
  ld    l, a
  push  af
  call  set_color
  ld    e, '='
  call  print_char
  pop   af
  ld    b, 16          ; Ending color
  cp    b
  jr    nz, .loop
  ret

; Set up the terminal screen
; Destroys
;	de
set_up_screen:
  ld    de, term_reset
  call  print_string

  ld    de, color_intense   ; Turn on color intensity
  call  print_string

  ld    de, back_black
  call  print_string

  ld    de, clrscrn
  call  print_string
  ret

; Reset the screen and colors
; Destroys
; 	hl de
reset_screen:
  ld    hl, 60
  call  set_color           ; Reset color before exiting

  ld    de, color_normal
  call  print_string
  ret

; BDOS call to exit and return to CP
; No args
reset:
  ld    c, 0                ; CP/M system reset call - shut down
  call  BDOS
  
; ------------------------------------------------------------------------------
; MAIN
; ------------------------------------------------------------------------------
start:
  call  set_string_delimiter  ; $ is a dumb string delimiter, use 255
  call  set_up_screen

  ld    e, ' '
  call  print_char

  call  color_bar_up        ; Draw color bars
  call  color_bar_down

  ld    hl, 25              ; Set color 25
  call  set_color

  ld    de, msg             ; Hello World!
  call  print_string

  ld    e, ' '
  call  print_char

  call  color_bar_up        ; Draw color bars
  call  color_bar_down

  ld    e, "\n"
  call  print_char 
  ld    e, "\n"
  call  print_char

  call  reset_screen
  call  reset  
  halt                      ; This code is never reached
