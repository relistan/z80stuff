; ------------------------------------------------------------------------------
; Terminal and color control routines for CP/M in Z80 assembly
;   -- requires a 256 color terminal, which should be no issue in 2022
;
; Karl Matthias -- 2022-02-21
; ------------------------------------------------------------------------------


; ------------------------------------------------------------------------------
; DATA
; ------------------------------------------------------------------------------

; Color code will have the color segment overwritten when set_color
; is called.
color_code:     BYTE 27,'[38;5;000m',255
term_reset:     BYTE 27,'c',255
clrscrn:        BYTE 27,'[2J',255
back_black:     BYTE 27,'[48;5;0m',255
back_white:     BYTE 27,'[48;5;15m',255
color_intense:  BYTE 27,'[1m',255
color_normal:   BYTE 27,'[0m',255
cursor_hide:    BYTE 27,'[?25l',255
cursor_show:    BYTE 27,'[?25h',255

; Color bar configuration
bar_up:         BYTE 16,196,36,'=' 
bar_down:       BYTE 196,16,-36,'='

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
  
  MACRO PUTC ch
    ld    e, ch
    call  print_char
  ENDM

; BDOS call to print a string to console
; de must contain address of string, terminated with $
print_string:
  ld    c, 9           ; CP/M write string to console call
  call  BDOS
  ret

  MACRO PUTS str_loc
    ld    de, str_loc
    call  print_string
  ENDM

; Sets the screen color by echoing an ANSI color code to the terminal
; using the BDOS output routines.
;
; Destroys
;   ix a de hl ix bc
set_color:
  ld    ix, color_code+6
  call  hl_itoa
  PUTS  color_code
  ret

; ------------------------------------------------------------------------------
; Draw a color bar at current position
;    iy = block of args
;         0 = starting color
;         1 = ending color
;         2 = increment
;         3 = character to draw

; Wrappers to load up the right place from memory
color_bar_up:
  ld  iy, bar_up
  jr  color_bar

color_bar_down:
  ld iy, bar_down

color_bar:
  ld    a, (iy)
  sub   (iy+2)
.loop:
  add   (iy+2)     ; sub -36 (add)
  push  af         ; preserve a, to be whacked by set_color

  ld    l, a       ; store 196 into l
  call  set_color  ; set the color

  ld    de, (iy+3) ; put '=' into e
  call  print_char ; print e

  pop   af         ; restore a
  ld    b, (iy+1)  ; put 16 into b
  cp    b          ; compare a to 16
  jr    nz, .loop
  ret

  MACRO FULL_COLOR_BAR
    call color_bar_up
    call color_bar_down
  ENDM
; ------------------------------------------------------------------------------
