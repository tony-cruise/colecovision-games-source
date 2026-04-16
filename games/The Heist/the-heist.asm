; ===== THE HEIST (1983) DISASSEMBLY LEGEND =====
; ROM: 16 KB ($8000-$BFFF). VDP: $A0=data $A1=ctrl. Sound: SN76489A on $E0.
;
; === CART ENTRY & TOP-LEVEL LOOPS ===
; CART_ENTRY ................. 197
; START ...................... 1418
; LOC_8D58 (outer loop) ...... 1422
; LOC_8D5E (level-start) ..... 1426
; LOC_8D61 (game tick) ....... 1429
;
; === NMI & INIT ===
; NMI ........................ 628
; SUB_8325 (cold init) ....... 603
; SUB_8DCF (VDP init) ........ 1482
;
; === SOUND (SN76489A via $E0) ===
; SUB_8024 (freq builder) .... 200
; SOUND_WRITE_8066 (vol wr) .. 237
; SUB_8090 (noise reg) ....... 265
; SUB_80AA (init 4 ch) ....... 282
; SUB_84A1 (write $E0) ....... 840
; SOUND_WRITE_83AC (enable) .. 664
; SOUND_WRITE_83C5 (disable) . 678
; SOUND_WRITE_83E4 (halt) .... 697
;
; === VDP (TMS9918A via $A0/$A1) ===
; SUB_83EF (read status) ..... 704
; SUB_83F2 (write reg) ....... 708
; SUB_83FE (VRAM write) ...... 718
; SUB_8430 (VRAM read) ....... 754
; SUB_8465 (clear VRAM) ...... 792
; SUB_842D (2-NOP delay) ..... 749
; SUB_8460 (4-NOP delay) ..... 785
;
; === SCREEN & GRAPHICS ===
; SUB_817F (screen setup) .... 416
; SUB_80D6 (tile copy) ....... 313
; SUB_8112 (VRAM fill) ....... 356
; SUB_8141 (tile bitmap) ..... 389
; SUB_81C2 (stride copy) ..... 443
;
; === VDP REGISTER SETTERS ===
; SOUND_WRITE_8E03 (reg1 b6). 1507
; SOUND_WRITE_8E19 (reg1 b5) .1523
; SUB_8E2F (plane mask) ...... 1539
; SUB_8E69 (sprite size) ..... 1566
; SUB_8E7F (sprite mag) ...... 1582
; SUB_8E95 (name table) ...... 1598
; SUB_8EA3 (colour table) .... 1607
; SUB_8EC1 (pattern table) ... 1626
; SUB_8EDD (spr-attr table) .. 1644
; SUB_8EEB (spr-pat table) ... 1653
; SUB_8EFB (bg colour) ....... 1663
;
; === SPRITES ===
; SUB_8F49 (spr-attr write) .. 1694
; SUB_9042 (clear 192 spr) ... 1812
; SUB_84BC (init spr table) .. 847
; SUB_84CE (clear 12 rec) .... 857
; SUB_856C (sprite update) ... 931
; SUB_934C (anim seq load) ... 1924
;
; === CONTROLLER ===
; SUB_8481 (read ctrl) ....... 810
; SUB_848E (set mode) ........ 822
;
; === GAME LOGIC ===
; SUB_8238 (init vars) ....... 516
; SOUND_WRITE_825A (lvl init) .531
; SOUND_WRITE_82D2 (frame upd) 569
;
; === COLLISION & SCORE ===
; SUB_9526 (collision CPI) ... 2157
; SUB_9541 (decrement lives) . 2175
; SUB_9574 (match CPI) ....... 2203
; SOUND_WRITE_958F (reset st). 2221
; SOUND_WRITE_95A9 (fr ctrl) . 2234
;
; === TITLE SCREEN ===
; SOUND_WRITE_9651 (title lp). 2314
; SOUND_WRITE_9683 (title rd). 2339
;
; === MISC HELPERS ===
; SUB_83DB (busy-wait NMI) ... 691
; SUB_B15F (ptr table lkup) .. 3923
;
; === DATA BLOCKS ===
; GAME_DATA .................. 3887
; TILE_BITMAPS ............... 4535
; SUB_BCDE (clr enemy flags) . 4565
; SUB_BCF0 (init enemies) .... 4577
;
; ================================================
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;

                                            ; BIOS entry-point definitions (EQU addresses in ROM)

BOOT_UP:                 EQU $0000          ; Cold-start / warm-start vector $0000
BIOS_NMI:                EQU $0066          ; BIOS NMI handler $0066
NUMBER_TABLE:            EQU $006C          ; BIOS number-table address $006C
PLAY_SONGS:              EQU $1F61          ; BIOS PLAY_SONGS $1F61
ACTIVATEP:               EQU $1F64          ; BIOS ACTIVATEP $1F64
REFLECT_VERTICAL:        EQU $1F6A          ; BIOS REFLECT_VERTICAL $1F6A
REFLECT_HORIZONTAL:      EQU $1F6D          ; BIOS REFLECT_HORIZONTAL $1F6D
ROTATE_90:               EQU $1F70          ; BIOS ROTATE_90 $1F70
ENLARGE:                 EQU $1F73          ; BIOS ENLARGE $1F73
CONTROLLER_SCAN:         EQU $1F76          ; BIOS CONTROLLER_SCAN $1F76
DECODER:                 EQU $1F79          ; BIOS DECODER $1F79
GAME_OPT:                EQU $1F7C          ; BIOS GAME_OPT $1F7C
LOAD_ASCII:              EQU $1F7F          ; BIOS LOAD_ASCII $1F7F
FILL_VRAM:               EQU $1F82          ; BIOS FILL_VRAM $1F82
MODE_1:                  EQU $1F85          ; BIOS MODE_1 $1F85
UPDATE_SPINNER:          EQU $1F88          ; BIOS UPDATE_SPINNER $1F88
INIT_TABLEP:             EQU $1F8B          ; BIOS INIT_TABLEP $1F8B
PUT_VRAMP:               EQU $1F91          ; BIOS PUT_VRAMP $1F91
INIT_SPR_ORDERP:         EQU $1F94          ; BIOS INIT_SPR_ORDERP $1F94
INIT_TIMERP:             EQU $1F9A          ; BIOS INIT_TIMERP $1F9A
REQUEST_SIGNALP:         EQU $1FA0          ; BIOS REQUEST_SIGNALP $1FA0
TEST_SIGNALP:            EQU $1FA3          ; BIOS TEST_SIGNALP $1FA3
WRITE_REGISTERP:         EQU $1FA6          ; BIOS WRITE_REGISTERP $1FA6
INIT_WRITERP:            EQU $1FAF          ; BIOS INIT_WRITERP $1FAF
SOUND_INITP:             EQU $1FB2          ; BIOS SOUND_INITP $1FB2
PLAY_ITP:                EQU $1FB5          ; BIOS PLAY_ITP $1FB5
INIT_TABLE:              EQU $1FB8          ; BIOS INIT_TABLE $1FB8
GET_VRAM:                EQU $1FBB          ; BIOS GET_VRAM $1FBB
PUT_VRAM:                EQU $1FBE          ; BIOS PUT_VRAM $1FBE
INIT_SPR_NM_TBL:         EQU $1FC1          ; BIOS INIT_SPR_NM_TBL $1FC1
WR_SPR_NM_TBL:           EQU $1FC4          ; BIOS WR_SPR_NM_TBL $1FC4
INIT_TIMER:              EQU $1FC7          ; BIOS INIT_TIMER $1FC7
FREE_SIGNAL:             EQU $1FCA          ; BIOS FREE_SIGNAL $1FCA
REQUEST_SIGNAL:          EQU $1FCD          ; BIOS REQUEST_SIGNAL $1FCD
TEST_SIGNAL:             EQU $1FD0          ; BIOS TEST_SIGNAL $1FD0
TIME_MGR:                EQU $1FD3          ; BIOS TIME_MGR $1FD3
TURN_OFF_SOUND:          EQU $1FD6          ; BIOS TURN_OFF_SOUND $1FD6
WRITE_REGISTER:          EQU $1FD9          ; BIOS WRITE_REGISTER $1FD9
READ_REGISTER:           EQU $1FDC          ; BIOS READ_REGISTER $1FDC
WRITE_VRAM:              EQU $1FDF          ; BIOS WRITE_VRAM $1FDF
READ_VRAM:               EQU $1FE2          ; BIOS READ_VRAM $1FE2
INIT_WRITER:             EQU $1FE5          ; BIOS INIT_WRITER $1FE5
WRITER:                  EQU $1FE8          ; BIOS WRITER $1FE8
POLLER:                  EQU $1FEB          ; BIOS POLLER $1FEB — reads controllers each frame into JOYSTICK_BUFFER
SOUND_INIT:              EQU $1FEE          ; BIOS SOUND_INIT $1FEE
PLAY_IT:                 EQU $1FF1          ; BIOS PLAY_IT $1FF1
SOUND_MAN:               EQU $1FF4          ; BIOS SOUND_MAN $1FF4
ACTIVATE:                EQU $1FF7          ; BIOS ACTIVATE $1FF7
PUTOBJ:                  EQU $1FFA          ; BIOS PUTOBJ $1FFA
RAND_GEN:                EQU $1FFD          ; BIOS RAND_GEN $1FFD — hardware random number generator

                                            ; I/O port definitions

KEYBOARD_PORT:           EQU $0080          ; KEYBOARD_PORT $80 — keypad/joystick mode select
DATA_PORT:               EQU $00BE          ; DATA_PORT $BE — (unused; Heist uses $A0 for VDP data instead)
CTRL_PORT:               EQU $00BF          ; CTRL_PORT $BF — (unused; Heist uses $A1 for VDP control instead)
JOY_PORT:                EQU $00C0          ; JOY_PORT $C0 — joystick direction mode select
CONTROLLER_02:           EQU $00F5          ; CONTROLLER_02 $F5 — player 2 controller read port
CONTROLLER_01:           EQU $00FC          ; CONTROLLER_01 $FC — player 1 controller read port
SOUND_PORT:              EQU $00FF          ; SOUND_PORT $FF — (note: Heist writes SN76489A via port $E0 not $FF)

                                            ; RAM / buffer definitions

JOYSTICK_BUFFER:         EQU $0000          ; JOYSTICK_BUFFER $0000 — BIOS POLLER writes controller state here
WORK_BUFFER:             EQU $7000          ; WORK_BUFFER $7000 — main work/flag byte
CONTROLLER_BUFFER:       EQU $702B          ; CONTROLLER_BUFFER $702B — raw controller input byte
STACKTOP:                EQU $73B9          ; STACKTOP $73B9 — top of stack

FNAME "output\HEIST-THE-1983-NEW.ROM"       ; Output ROM filename (suffix -NEW so original is never overwritten)
CPU Z80                                     ; Target CPU: Z80

    ORG     $8000                           ; ROM base address — ColecoVision cartridge space starts at $8000

    DW      $AA55                           ; Cart magic word $AA55 — required by BIOS cart detection
    DB      $00, $00
    DB      $00, $00
    DB      $00, $00
    DW      JOYSTICK_BUFFER                 ; Pointer to controller buffer — BIOS POLLER writes here each frame
    DW      START                           ; Pointer to START — BIOS jumps here after warm boot
    DB      $C3, $7F, $86, $C3, $80, $86, $C3, $81
    DB      $86, $C3, $82, $86, $C3, $83, $86, $C3
    DB      $84, $86, $C3, $5D, $83

CART_ENTRY:                                 ; CART_ENTRY: first word executed on cold start ($8000)
    JP      NMI                             ; Jump to NMI handler — CART_ENTRY repurposed as NMI dispatch target

SUB_8024:                                   ; SUB_8024: build TMS/SN76489A frequency bytes from 14-bit value; write to $7020
    PUSH    BC                              ; PUSH BC: save BC before building frequency word
    LD      BC, JOYSTICK_BUFFER             ; LD BC, JOYSTICK_BUFFER (BC = $0000): zero base for SLA shift
    LD      C, A                            ; C = A (frequency low byte)
    SLA     C                               ; SLA C: start building 10-bit frequency mantissa
    LD      HL, $7020                       ; HL = $7020: frequency shadow RAM table base
    ADD     HL, BC                          ; HL += BC×2: index into table by channel
    POP     BC
    LD      (HL), C                         ; (HL) = C: store frequency low nibble
    INC     HL                              ; INC HL: advance to high byte
    LD      (HL), B                         ; (HL) = B: store frequency high byte
    SLA     A                               ; SLA A × 5: build high-nibble tone command byte
    SLA     A
    SLA     A
    SLA     A
    SLA     A
    OR      $80                             ; OR $80: set tone-latch bit (SN76489A first byte format)
    LD      E, A
    LD      A, C
    AND     $0F
    OR      E
    LD      ($702D), A                      ; $702D = tone latch byte (high nibble + $80)
    RR      B                               ; RR B/C pair: extract 6-bit coarse frequency value
    RR      C
    RR      B
    RR      C
    SRL     C
    SRL     C
    LD      A, $3F                          ; AND $3F: mask to 6 bits (SN76489A second byte format)
    AND     C
    LD      ($702E), A                      ; $702E = frequency data byte (second byte)
    LD      A, ($702D)                  ; RAM $702D
    CALL    SUB_84A1                        ; CALL SUB_84A1: write $702D byte to port $E0
    LD      A, ($702E)                      ; Load second frequency byte
    CALL    SUB_84A1                        ; CALL SUB_84A1: write $702E byte to port $E0
    RET     

SOUND_WRITE_8066:                           ; SOUND_WRITE_8066: write SN76489A volume byte for channel B with value A
    LD      C, A                            ; C = A: save volume value
    LD      A, ($702C)                      ; Load $702C — sound-engine busy flag ($FF = silent)
    CP      $FF                             ; CP $FF: check if sound is silent/disabled
    JP      Z, LOC_808F                     ; JP Z LOC_808F: skip if disabled
    LD      A, C                            ; A = C: restore volume
    PUSH    BC
    LD      C, B
    LD      B, $00                          ; HL = $7026 + B×2: volume shadow table for this channel
    SLA     C
    LD      HL, $7026                   ; RAM $7026
    ADD     HL, BC
    LD      (HL), A                         ; (HL) = A: store volume byte
    POP     BC
    CPL                                     ; CPL: invert bits (SN76489A uses inverted attenuation)
    AND     $0F                             ; AND $0F: mask to 4 bits (volume nibble)
    SLA     B                               ; SLA B × 5: build channel-select bits for volume command
    SLA     B
    SLA     B
    SLA     B
    SLA     B
    OR      $90                             ; OR $90: set volume-latch bit (SN76489A: $90 | channel<<5 | volume)
    OR      B                               ; OR B: merge channel bits
    CALL    SUB_84A1                        ; CALL SUB_84A1: write volume command to port $E0

LOC_808F:
    RET     

SUB_8090:                                   ; SUB_8090: write SN76489A noise register / channel 3 control byte
    PUSH    AF                              ; PUSH AF: save A
    LD      ($702A), A                      ; $702A = A: noise shadow byte
    LD      A, B                            ; A = B: load channel-control byte
    LD      (CONTROLLER_BUFFER), A          ; $702B = B: save to CONTROLLER_BUFFER
    POP     AF
    AND     $01                             ; AND $01: isolate noise-type bit
    SLA     A                               ; SLA A × 2: shift to position in noise byte ($E0 format)
    SLA     A
    OR      $E0                             ; OR $E0: set noise-register latch bits
    LD      C, A                            ; C = noise register byte
    LD      A, B                            ; A = B: load original B
    AND     $03                             ; AND $03: low 2 bits = noise frequency divider
    OR      C                               ; OR C: merge into noise command
    CALL    SUB_84A1                        ; CALL SUB_84A1: write noise command to port $E0
    RET     

SUB_80AA:                                   ; SUB_80AA: init all 4 SN76489A channels (3 frequency pairs + noise control)
    LD      A, $00                          ; A = $00: channel 0
    LD      BC, JOYSTICK_BUFFER             ; BC = JOYSTICK_BUFFER (B=0, C=0): channel index

LOC_80AF:                                   ; LOC_80AF: loop — call SUB_8024 to write frequency for channels 0-2
    PUSH    AF
    PUSH    BC
    CALL    SUB_8024                        ; CALL SUB_8024: write frequency bytes for this channel
    POP     BC
    POP     AF
    INC     A                               ; INC A: next channel
    CP      $03                             ; CP $03: stop after channels 0-2
    JP      NZ, LOC_80AF
    LD      A, $00                          ; A = $00: frequency value for volume init
    LD      B, $00
    LD      C, $04                          ; C = $04: 4 volume bytes to write

LOC_80C2:                                   ; LOC_80C2: loop — write volume command for all 4 channels
    PUSH    AF
    PUSH    BC
    CALL    SOUND_WRITE_8066                ; CALL SOUND_WRITE_8066: write volume byte for channel B
    POP     BC
    POP     AF
    INC     B
    DEC     C
    JP      NZ, LOC_80C2
    LD      A, $00                          ; A = $00, B = $00: noise control value and channel
    LD      B, $00
    CALL    SUB_8090                        ; CALL SUB_8090: write noise/control byte
    RET     

SUB_80D6:                                   ; SUB_80D6: copy C rows of B-byte tile data from ROM(HL) to VRAM at row $38+B
    PUSH    HL                              ; PUSH HL: save source pointer
    LD      HL, $3800                       ; HL = $3800: VRAM tile pattern base
    LD      E, B                            ; E = B: row index
    LD      D, $00                          ; SLA E × 5 / RL D: B << 5 = B×32 (32 bytes per tile row)
    SLA     E
    RL      D
    SLA     E
    RL      D
    SLA     E
    RL      D
    SLA     E
    RL      D
    SLA     E
    RL      D
    ADD     HL, DE                          ; ADD HL, DE: compute VRAM target = $3800 + B×32
    LD      E, L
    LD      D, H
    POP     HL                              ; POP HL: restore source pointer

LOC_80F5:                                   ; LOC_80F5: copy loop — call SUB_83FE to write B bytes; advance ptrs; DEC C
    PUSH    BC                              ; PUSH BC/HL/DE: save loop state
    PUSH    HL
    PUSH    DE
    LD      B, $20                          ; B = $20: 32 bytes to write this row
    LD      A, $00                          ; A = $00: VRAM write mode (set addr then OUTI)
    CALL    SUB_83FE                        ; CALL SUB_83FE: write 32 bytes from HL to VRAM at DE
    POP     DE
    POP     HL
    LD      BC, $0020                       ; BC = $0020: stride = 32 bytes
    ADD     HL, BC
    PUSH    HL
    PUSH    DE
    POP     HL
    ADD     HL, BC
    PUSH    HL
    POP     DE
    POP     HL
    POP     BC
    DEC     C                               ; DEC C: one fewer row remaining
    JP      NZ, LOC_80F5
    RET     

SUB_8112:                                   ; SUB_8112: fill C rows × B bytes with value A to VRAM at address DE
    PUSH    AF                              ; PUSH AF / DE: save fill value and target VRAM address
    PUSH    DE
    PUSH    DE
    POP     BC                              ; CALL SUB_8EDD: set sprite attribute table addr from BC (VDP reg 5)
    CALL    SUB_8EDD
    POP     DE
    PUSH    DE
    LD      A, $01                          ; A = $01: VRAM addr-only mode
    CALL    SUB_83FE                        ; CALL SUB_83FE: set VRAM write address to DE
    POP     DE
    POP     AF
    SLA     A                               ; SLA A × 2: multiply fill count
    SLA     A
    LD      C, A                            ; C = A×4: total bytes this row
    CP      $00
    JP      Z, LOC_8139

LOC_812C:                                   ; LOC_812C: inner fill loop — mode $02 writes byte B repeatedly
    PUSH    BC
    LD      A, $02                          ; A = $02: VRAM data-write mode (write B to $A0)
    LD      B, $00                          ; B = $00: fill value
    CALL    SUB_83FE                        ; CALL SUB_83FE: write one fill byte to VRAM
    POP     BC
    DEC     C                               ; DEC C: loop for C bytes
    JP      NZ, LOC_812C

LOC_8139:
    LD      A, $02                          ; A = $02, B = $D0: write $D0 (sprite end marker) at row end
    LD      B, $D0
    CALL    SUB_83FE                        ; CALL SUB_83FE: write $D0 to VRAM
    RET     

SUB_8141:                                   ; SUB_8141: write tile bitmap row to VRAM at address DE (indexed by A)
    PUSH    AF
    PUSH    DE
    PUSH    DE
    POP     BC
    CALL    SUB_8E95                        ; CALL SUB_8E95: set VRAM name-table base from BC (VDP reg 2)
    POP     DE
    POP     AF
    LD      HL, $8177                       ; HL = $8177: jump table of VRAM write functions
    LD      B, $00                          ; B = $00, C = A: index into function table
    LD      C, A
    SLA     C                               ; SLA C: ×2 for 16-bit pointer table
    ADD     HL, BC                          ; ADD HL, BC: point to table entry
    PUSH    DE
    LD      E, (HL)                         ; E/D = (HL): load function pointer
    INC     HL
    LD      D, (HL)
    PUSH    DE
    POP     HL
    POP     DE
    JP      (HL)                            ; JP (HL): dispatch to selected write function
    DB      $C9, $3E, $01, $CD, $FE, $83, $06, $00
    DB      $0E, $03, $C5, $3E, $02, $CD, $FE, $83
    DB      $C1, $04, $C2, $65, $81, $0D, $C2, $65
    DB      $81, $C9, $C9, $C9, $5B, $81, $5C, $81
    DB      $75, $81, $76, $81

SUB_817F:                                   ; SUB_817F: screen setup — init VDP regs, clear tiles, load bitmap data
    CALL    SUB_8DCF                        ; CALL SUB_8DCF: init VDP register set from table $8DFB; clear VRAM
    LD      A, $01                          ; A = $01: enable sprite visibility plane
    CALL    SUB_8E2F                        ; CALL SUB_8E2F: set sprite plane A mask bits in $716C/$716D
    LD      A, $01
    CALL    SUB_8E69                        ; CALL SUB_8E69: set $716D bit 1 (sprite plane B on)
    LD      A, $00
    CALL    SUB_8E7F                        ; CALL SUB_8E7F: clear $716D bit 0 (sprites not magnified)
    LD      BC, $1800                       ; BC = $1800: name-table VRAM address (1×512 byte page)
    CALL    SUB_8E95                        ; CALL SUB_8E95: write VDP reg 2 (name-table addr = $1800>>$A = page 3)
    LD      BC, $2000                       ; BC = $2000: colour-table address
    CALL    SUB_8EA3                        ; CALL SUB_8EA3: write VDP reg 3 (colour table)
    LD      BC, JOYSTICK_BUFFER             ; BC = JOYSTICK_BUFFER: pattern table at $0000
    CALL    SUB_8EC1                        ; CALL SUB_8EC1: write VDP reg 4 (pattern table)
    LD      BC, $1C00                       ; BC = $1C00: sprite attribute table address
    CALL    SUB_8EDD                        ; CALL SUB_8EDD: write VDP reg 5 (sprite attribute table = $1C00)
    LD      BC, $3800                       ; BC = $3800: sprite pattern table
    CALL    SUB_8EEB                        ; CALL SUB_8EEB: write VDP reg 6 (sprite pattern table)
    LD      A, $00                          ; A = $00: background colour index 0 (black)
    CALL    SUB_8F15                        ; CALL SUB_8F15: write VDP reg 7 (backdrop colour)
    LD      A, $01
    LD      DE, $1800                       ; A = $01: write mode index
    CALL    SUB_8141                        ; CALL SUB_8141: write initial tile bitmap row to VRAM
    LD      A, $00
    CALL    SOUND_WRITE_8E03                ; CALL SOUND_WRITE_8E03: clear $716D bit 6 (sprite layer A off)
    RET     

SUB_81C2:                                   ; SUB_81C2: copy tile bitmap with stride: stride-8 (A=0) or stride-32 (A=1)
    CP      $00                             ; CP $00: check stride mode
    JP      NZ, LOC_81E7                    ; JP NZ LOC_81E7: use stride-32 if A != 0
    LD      IX, $0008                       ; IX = $0008: stride = 8 bytes
    PUSH    BC
    LD      C, B                            ; C = B: loop counter from B
    LD      B, $00                          ; B = $00
    SLA     C                               ; SLA C × 3: BC = B×8 (8-byte aligned)
    RL      B
    SLA     C
    RL      B
    SLA     C
    RL      B                               ; IY = DE + BC×8: compute VRAM start address
    PUSH    DE
    POP     IY
    ADD     IY, BC
    PUSH    IY
    POP     DE
    POP     BC
    JP      LOC_820C

LOC_81E7:
    LD      IX, $0020                       ; LOC_81E7: stride-32 path — IX = $0020
    PUSH    BC                              ; IX = $0020: stride = 32 bytes
    LD      C, B
    LD      B, $00
    SLA     C                               ; SLA C × 5: BC = B×32 (32-byte aligned)
    RL      B
    SLA     C
    RL      B
    SLA     C
    RL      B
    SLA     C
    RL      B
    SLA     C
    RL      B
    PUSH    DE
    POP     IY
    ADD     IY, BC
    PUSH    IY
    POP     DE
    POP     BC

LOC_820C:                                   ; LOC_820C: copy loop — call SUB_83FE to write IX bytes; advance DE by IX
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IX
    LD      A, $00
    PUSH    IX
    POP     BC
    LD      B, C
    CALL    SUB_83FE
    POP     IX
    POP     HL
    POP     DE
    POP     BC
    PUSH    IX
    POP     IY
    ADD     IY, DE
    PUSH    IY
    POP     DE
    DB      $EB
    PUSH    IX
    POP     IY
    ADD     IY, DE
    PUSH    IY
    POP     DE
    DB      $EB
    DEC     C
    JP      NZ, LOC_820C
    RET     

SUB_8238:                                   ; SUB_8238: init game state variables to zero at start of level
    LD      A, $00                          ; A = $00: zero value
    LD      ($71A3), A                      ; $71A3 = 0: clear score/object counter
    LD      ($7197), A                      ; $7197 = 0: clear difficulty/level-progress counter
    LD      ($71A0), A                  ; RAM $71A0
    LD      ($719C), A                      ; $719C = 0: clear level-completed flag
    LD      A, $00
    LD      ($719D), A                  ; RAM $719D
    LD      ($719E), A                  ; RAM $719E
    LD      ($719F), A                  ; RAM $719F
    LD      ($7196), A                  ; RAM $7196
    LD      A, $03                          ; A = $03: initial lives count
    LD      ($71A1), A                      ; $71A1 = $03 (BCD): 3 lives
    RET     

SOUND_WRITE_825A:                           ; SOUND_WRITE_825A: level-start sequence — init sound, render level, init all sprites
    CALL    SUB_84BC                        ; CALL SUB_84BC: init sprite attribute table at $7002
    LD      A, $04                          ; A = $04: number of guards/enemies on this level
    LD      ($719A), A                      ; $719A = 4: enemy count for this level
    LD      A, $FF
    CALL    SOUND_WRITE_8E03                ; CALL SOUND_WRITE_8E03: set $716D bit 6 (layer A enable)
    CALL    SUB_9042                        ; CALL SUB_9042: clear all 192 sprite slots (sprite visibility pass)
    CALL    SUB_B9B3                        ; CALL SUB_B9B3: generate level map / draw level tiles to VRAM
    LD      A, ($7197)                      ; Load $7197 — level index
    LD      C, A
    LD      HL, $82AB                       ; HL = $82AB: level title pointer table
    CALL    SUB_B15F                        ; CALL SUB_B15F: select level title string pointer from table
    LD      B, $0B                          ; B = $0B, C = $5C, D = $05: title tile position (row 11, col 92)
    LD      C, $5C
    LD      D, $05
    LD      HL, $9ECD                       ; HL = $9ECD: string data
    CALL    SUB_9EAC                        ; CALL SUB_9EAC: draw level title string to VRAM name table
    LD      A, $00
    CALL    SOUND_WRITE_8E03                ; CALL SOUND_WRITE_8E03: clear layer A bit (layer A off)
    CALL    SOUND_WRITE_B20E                ; CALL SOUND_WRITE_B20E: init/display lives counter
    CALL    SUB_C27F                        ; CALL SUB_C27F: draw level border/frame tiles
    CALL    SUB_BCDE                        ; CALL SUB_BCDE: clear 8 enemy active-flag bytes at $7216
    LD      HL, $0258                       ; HL = $0258: 600ms display delay
    CALL    SUB_97E8                        ; CALL SUB_97E8: delay (600 VBL ticks)
    LD      A, $FF
    CALL    SOUND_WRITE_8E03                ; CALL SOUND_WRITE_8E03: set layer A bit again
    CALL    SUB_9042                        ; CALL SUB_9042: re-clear all sprite slots
    CALL    SUB_AF95                        ; CALL SUB_AF95: place player/thief sprite at starting position
    LD      A, $01                          ; A = $01: forward direction
    LD      HL, $D62F                       ; HL = $D62F: sprite animation data
    CALL    SUB_D5E3                        ; CALL SUB_D5E3: start player walk animation
    RET     
    DB      $B1, $82, $BC, $82, $C7, $82, $2D, $20
    DB      $4C, $45, $56, $45, $4C, $20, $31, $20 ; "LEVEL 1 "
    DB      $AD, $2D, $20, $4C, $45, $56, $45, $4C
    DB      $20, $32, $20, $AD, $2D, $20, $4C, $45
    DB      $56, $45, $4C, $20, $33, $20, $AD

SOUND_WRITE_82D2:                           ; SOUND_WRITE_82D2: main frame update — render all layers and update game entities
    LD      A, $FF                          ; CALL SOUND_WRITE_8E03: set $716D bit 6 (layer A on)
    CALL    SOUND_WRITE_8E03
    CALL    SUB_84CE                        ; CALL SUB_84CE: reset 12 sprite records to blank, rebuild tile display
    CALL    SOUND_WRITE_9C06                ; CALL SOUND_WRITE_9C06: update guards/cops animation and movement
    CALL    SUB_AD5F                        ; CALL SUB_AD5F: check thief-vs-guard collision
    CALL    SOUND_WRITE_958F                ; CALL SOUND_WRITE_958F: reset score/stats display
    CALL    SUB_945F                        ; CALL SUB_945F: update all collectible objects (jewels/bags)
    CALL    SOUND_WRITE_C8A1                ; CALL SOUND_WRITE_C8A1: update score display
    CALL    SOUND_WRITE_CE10                ; CALL SOUND_WRITE_CE10: update player thief animation
    CALL    SOUND_WRITE_D09E                ; CALL SOUND_WRITE_D09E: process player controller input
    LD      A, $00                          ; CALL SOUND_WRITE_8E03: clear layer A bit
    CALL    SOUND_WRITE_8E03                ; CALL SOUND_WRITE_B257: draw player/thief sprite
    CALL    SOUND_WRITE_B257                ; CALL SUB_B9D5: draw all guard sprites
    CALL    SUB_B9D5                        ; CALL SUB_C291: draw all collectible-object sprites
    CALL    SUB_C291                        ; CALL SUB_BCF0: init/position enemy objects from level table
    CALL    SUB_BCF0                        ; CALL SOUND_WRITE_C454: draw HUD/status bar
    CALL    SOUND_WRITE_C454                ; CALL SOUND_WRITE_998D: draw/update key-item positions
    CALL    SOUND_WRITE_998D
    LD      A, $00                          ; A = $00: clear game-state flags
    LD      ($7198), A                      ; $7198 = 0: clear guard-hit flag
    LD      ($719B), A                  ; RAM $719B
    LD      ($719C), A                      ; $719C = 0: clear level-exit flag
    LD      ($7199), A                  ; RAM $7199
    LD      ($71F2), A                      ; $71F2 = 0: clear bonus flag
    LD      A, ($71A6)                      ; Load $71A6 — title-screen suppress flag
    CP      $FF
    JP      Z, LOC_8324                     ; JP Z LOC_8324: skip if flag clear
    LD      A, $00
    CALL    SUB_8CD2                        ; CALL SUB_8CD2: run title-screen entry sequence

LOC_8324:
    RET     

SUB_8325:                                   ; SUB_8325: cold hardware init — DI/IM1, VDP clear, sound mute, screen setup
    DB      $F3                             ; DB $F3: DI (disable interrupts)
    IM      1                               ; IM 1: set interrupt mode 1 (fixed vector $0038)
    CALL    SUB_8DCF                        ; CALL SUB_8DCF: init VDP from table; clear all VRAM
    CALL    SUB_80AA                        ; CALL SUB_80AA: mute all 4 SN76489A channels
    CALL    SUB_817F                        ; CALL SUB_817F: init sprite attrs, VDP regs, load tile bitmaps
    CALL    SUB_84CE                        ; CALL SUB_84CE: clear 12 sprite records
    CALL    SUB_9888                        ; CALL SUB_9888: init player position and animation vars
    LD      A, $00
    CALL    SOUND_WRITE_8E03                ; CALL SOUND_WRITE_8E03: clear $716D bit 6 (layer A off)
    LD      A, $00
    CALL    SOUND_WRITE_8E19                ; CALL SOUND_WRITE_8E19: clear $716D bit 5 (NMI music off)
    CALL    SOUND_WRITE_83E4                ; CALL SOUND_WRITE_83E4: $702F=1, $7033=$FF (halt music playback)
    LD      A, $00
    CALL    SUB_8EFB                        ; CALL SUB_8EFB: set background colour to black (VDP reg 7)
    LD      A, $00
    CALL    SUB_8F15                        ; CALL SUB_8F15: write VDP reg 7 (backdrop colour = 0)
    LD      BC, $3800                       ; BC = $3800: sprite pattern table
    CALL    SUB_8EEB                        ; CALL SUB_8EEB: set VDP reg 6 (sprite pattern table)
    LD      A, $00
    LD      ($702C), A                      ; $702C = 0: clear sound-engine busy flag
    LD      ($723E), A                      ; $723E = 0: clear game-over flag
    RET     
    DB      $ED, $4D

NMI:                                        ; NMI: VBL interrupt — save regs, service music, tick frame counter
    PUSH    AF                              ; PUSH AF, BC, DE, HL, IX, IY: save all registers
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IX
    PUSH    IY
    CALL    SUB_83EF                        ; CALL SUB_83EF: read TMS9918A status ($A1) to clear interrupt flag
    LD      ($7032), A                      ; $7032 = A: save VDP status byte (bit 7 = VBLANK flag)
    LD      A, $00                          ; A = $00: clear value
    CALL    SOUND_WRITE_8E19                ; CALL SOUND_WRITE_8E19: clear $716D bit 5 (disable NMI music path)
    LD      A, ($702F)                      ; Load $702F — NMI sync flag
    OR      $80                             ; OR $80: set bit 7 (NMI-has-fired flag)
    LD      ($702F), A                      ; $702F = updated: flag is now readable by main loop
    LD      HL, $7031                       ; HL = $7031: frame counter
    INC     (HL)                            ; INC ($7031): increment frame counter
    CALL    SOUND_WRITE_9611                ; CALL SOUND_WRITE_9611: advance music/sound sequencer one tick
    CALL    SUB_83EF                        ; CALL SUB_83EF: read VDP status again (second acknowledge)
    LD      A, ($702F)                      ; Load $702F
    AND     $01                             ; AND $01: check music-enable bit
    JP      NZ, LOC_8391                    ; JP NZ LOC_8391: skip if music not enabled
    LD      A, $FF                          ; A = $FF: set music-active value
    CALL    SOUND_WRITE_8E19                ; CALL SOUND_WRITE_8E19: set $716D bit 5 (re-enable NMI music path)

LOC_8391:                                   ; LOC_8391: restore all registers
    POP     IY                              ; POP IY, IX, HL, DE, BC, AF
    POP     IX
    POP     HL
    POP     DE
    POP     BC
    POP     AF
    RETN                                    ; RETN: return from NMI (re-enable interrupts)
    DB      $3A, $33, $70, $FE, $FF, $CA, $AB, $83
    DB      $3E, $00, $32, $2F, $70, $CD, $DB, $83
    DB      $C9

SOUND_WRITE_83AC:                           ; SOUND_WRITE_83AC: enable NMI music playback — set $702F bit 0 if not $FF
    LD      A, ($7033)                      ; Load $7033 — music-sequence pointer flag ($FF = no music)
    CP      $FF                             ; CP $FF: check if music disabled
    JP      Z, LOC_83C4                     ; JP Z LOC_83C4: skip if no music
    LD      A, ($702F)                      ; Load $702F — NMI sync flag
    AND     $01                             ; AND $01: check music-enable bit
    JP      NZ, LOC_83C4                    ; JP NZ LOC_83C4: already enabled
    LD      A, $01                          ; A = $01: set enable flag
    LD      ($702F), A                      ; $702F = 1: music enable bit set
    CALL    SUB_83DB                        ; CALL SUB_83DB: wait for NMI to fire (poll $702F bit 7)

LOC_83C4:
    RET     

SOUND_WRITE_83C5:                           ; SOUND_WRITE_83C5: disable NMI music — clear $702F, call SUB_83EF to ack
    LD      A, ($7033)                      ; Load $7033 — music pointer ($FF = disabled)
    CP      $FF
    JP      Z, LOC_83DA                     ; JP Z LOC_83DA: skip if already disabled
    CALL    SUB_83EF                        ; CALL SUB_83EF: read VDP status (flush pending interrupt)
    LD      A, $00                          ; A = $00: clear value
    LD      ($702F), A                      ; $702F = 0: clear NMI music sync flag
    LD      A, $FF
    CALL    SOUND_WRITE_8E19                ; CALL SOUND_WRITE_8E19: clear $716D bit 5 (NMI music path off)

LOC_83DA:
    RET     

SUB_83DB:                                   ; SUB_83DB: busy-wait until NMI fires — spin on $702F bit 7
    LD      A, ($702F)                      ; Load $702F — NMI sync flag
    AND     $80                             ; AND $80: check bit 7 (set by NMI handler)
    JP      Z, SUB_83DB                     ; JP Z SUB_83DB: loop until NMI fires (bit 7 set)
    RET     

SOUND_WRITE_83E4:                           ; SOUND_WRITE_83E4: halt music playback — $702F=1, $7033=$FF (sequence end)
    LD      A, $01                          ; A = $01: set NMI music-enable to 1
    LD      ($702F), A                      ; $702F = 1: prevents NMI from triggering music routine
    LD      A, $FF                          ; A = $FF: end-of-sequence marker
    LD      ($7033), A                      ; $7033 = $FF: music sequence pointer at end-sentinel
    RET     

SUB_83EF:                                   ; SUB_83EF: read TMS9918A status register — IN A, ($A1)
    IN      A, ($A1)                        ; IN A, ($A1): read VDP status (bit 7=VBLANK, bit 6=coinc, bit 5=5th sprite)
    RET     

SUB_83F2:                                   ; SUB_83F2: write TMS9918A register B with value A
    PUSH    AF                              ; PUSH AF: save A
    IN      A, ($A1)                        ; IN A, ($A1): read status (required before register write)
    POP     AF
    OUT     ($A1), A                        ; OUT ($A1), A: write register value
    LD      A, B                            ; A = B
    OR      $80                             ; OR $80: set register-write flag (high bit in address byte)
    OUT     ($A1), A                        ; OUT ($A1), A: write register address (B | $80)
    RET     

SUB_83FE:                                   ; SUB_83FE: TMS9918A VRAM write — 3 modes: set-addr (0/1) or write-data (2)
    LD      ($7034), A                      ; $7034 = A: save mode parameter
    CP      $02                             ; CP $02: check if data-write mode
    JP      NZ, LOC_840C                    ; JP NZ LOC_840C: go to addr-set mode if not 2
    LD      A, B                            ; A = B: get data byte
    OUT     ($A0), A                        ; OUT ($A0), A: write data byte to VRAM ($A0 = VDP data port)
    JP      LOC_842C                        ; JP LOC_842C: return

LOC_840C:                                   ; LOC_840C: addr-set mode — set VRAM address to DE
    IN      A, ($A1)                        ; IN A, ($A1): read status (VDP ready check)
    LD      A, D                            ; A = D: address high byte
    AND     $3F                             ; AND $3F: mask to 14-bit address
    OR      $40                             ; OR $40: set write-mode bit
    LD      D, A                            ; D = new high byte with write flag
    LD      A, E                            ; A = E: address low byte
    OUT     ($A1), A                        ; OUT ($A1), A: write low byte of VRAM address
    LD      A, D                            ; A = D
    OUT     ($A1), A                        ; OUT ($A1), A: write high byte of VRAM address (+ write-mode $40)
    LD      A, ($7034)                  ; RAM $7034
    CP      $01                             ; CP $01: mode 1 = address-only (no data write)
    JP      Z, LOC_842C                     ; JP Z LOC_842C: return if mode 1
    LD      C, $A0                          ; C = $A0: VDP data port for OUTI

LOC_8424:                                   ; LOC_8424: OUTI loop — write bytes from (HL) to port $A0; INC HL; DEC B
    CALL    SUB_842D                        ; CALL SUB_842D: 2-NOP timing delay
    OUTI                                    ; OUTI: write (HL) to port C ($A0), INC HL, DEC B
    JP      NZ, LOC_8424                    ; JP NZ LOC_8424: repeat for all B bytes

LOC_842C:
    RET     

SUB_842D:                                   ; SUB_842D: 2-NOP timing delay for TMS9918A port settling
    NOP     
    NOP     
    RET     

SUB_8430:                                   ; SUB_8430: TMS9918A VRAM read — 3 modes: read addr, read single byte, INI loop
    LD      ($7035), A                      ; $7035 = A: save read mode
    CP      $02                             ; CP $02: single-byte read?
    JP      NZ, LOC_8441                    ; JP NZ LOC_8441: go to addr-set+read mode
    CALL    SUB_8460                        ; CALL SUB_8460: 4-NOP timing delay
    IN      A, ($A0)                        ; IN A, ($A0): read one VRAM data byte
    LD      B, A                            ; B = A: return value in B
    JP      LOC_845F

LOC_8441:                                   ; LOC_8441: addr-set then INI read loop
    IN      A, ($A1)                        ; IN A, ($A1): read status
    LD      A, D
    AND     $3F                             ; D = address high AND $3F: compute read address
    LD      D, A
    LD      A, E
    OUT     ($A1), A                        ; OUT ($A1), A: write address low byte
    LD      A, D
    OUT     ($A1), A                        ; OUT ($A1), A: write address high byte (no $40 write-mode for reads)
    LD      A, ($7035)                  ; RAM $7035
    CP      $01
    JP      Z, LOC_845F                     ; JP Z LOC_845F: mode 1 = address-only
    LD      C, $A0                          ; C = $A0: VDP data port

LOC_8457:                                   ; LOC_8457: INI loop — IN (HL), C ($A0); INC HL; DEC B
    CALL    SUB_8460                        ; CALL SUB_8460: 4-NOP delay before each INI
    INI                                     ; INI: read port $A0 into (HL); INC HL; DEC B
    JP      NZ, LOC_8457

LOC_845F:
    RET     

SUB_8460:                                   ; SUB_8460: 4-NOP timing delay (longer settle for VRAM read)
    NOP     
    NOP     
    NOP     
    NOP     
    RET     

SUB_8465:                                   ; SUB_8465: clear all 16 KB VRAM — set write addr $0000, fill $C000 bytes with $00
    IN      A, ($A1)                        ; IN A, ($A1): flush VDP status
    LD      A, $00                          ; A = $00, OUT ($A1): address low byte = 0
    OUT     ($A1), A
    AND     $3F                             ; AND $3F, OR $40: address high byte = $40 (write-mode flag)
    OR      $40
    OUT     ($A1), A                        ; OUT ($A1): address high byte
    LD      A, $00                          ; A = $00: fill value
    LD      BC, $C000                       ; BC = $C000: 49152 bytes (all of VRAM)

LOC_8476:                                   ; LOC_8476: fill loop — OUT ($A0), A; INC C; loop until BC=0
    OUT     ($A0), A                        ; OUT ($A0), A: write $00 to VRAM
    INC     C
    JP      NZ, LOC_8476
    INC     B
    JP      NZ, LOC_8476
    RET     

SUB_8481:                                   ; SUB_8481: read controller port — A=0 → port $E0; A=1 → port $E2
    CP      $01                             ; CP $01: check which port
    JP      Z, LOC_848B                     ; JP Z LOC_848B: port $E2 for player 2
    IN      A, ($E0)                        ; IN A, ($E0): read player 1 controller
    JP      LOC_848D

LOC_848B:                                   ; LOC_848B: IN A, ($E2): read player 2 controller
    IN      A, ($E2)

LOC_848D:
    RET     

SUB_848E:                                   ; SUB_848E: set controller input mode — A=0 → keypad ($80); A=1 → joystick ($C0)
    CP      $01                             ; CP $01: check mode
    JP      Z, LOC_8498                     ; JP Z LOC_8498: joystick mode
    OUT     ($80), A                        ; OUT ($80), A: write to KEYBOARD_PORT (keypad mode)
    JP      LOC_849A                        ; JP LOC_849A: wait

LOC_8498:                                   ; LOC_8498: OUT ($C0): set JOY_PORT (joystick mode)
    OUT     ($C0), A                    ; JOY_PORT - set joystick mode

LOC_849A:
    LD      B, $0A                          ; B = $0A: wait counter

LOC_849C:                                   ; LOC_849C: 10×NOP delay for controller mode switch settling
    NOP     
    NOP     
    DJNZ    LOC_849C
    RET     

SUB_84A1:                                   ; SUB_84A1: write byte A to SN76489A sound chip via port $E0
    OUT     ($E0), A                        ; OUT ($E0), A: write to SN76489A (frequency/volume/noise command byte)
    RET     
    DB      $36, $70, $4E, $70, $66, $70, $7E, $70 ; "6pNpfp~p"
    DB      $96, $70, $AE, $70, $C6, $70, $DE, $70
    DB      $F6, $70, $0E, $71, $26, $71, $3E, $71

SUB_84BC:                                   ; SUB_84BC: init sprite attribute table — IX=$7002; write $D0; call SUB_8668
    LD      IX, $7002                       ; IX = $7002: sprite attribute RAM base
    LD      A, $D0                          ; A = $D0: sprite Y = $D0 (off-screen sentinel for TMS9918A)
    LD      (IX+0), A                       ; (IX+0) = $D0: first sprite Y is off-screen
    PUSH    IX
    POP     HL
    LD      A, $00
    CALL    SUB_8668                        ; CALL SUB_8668: write sprite attributes from $7002 to VRAM $1C00
    RET     

SUB_84CE:                                   ; SUB_84CE: clear 12 sprite records (from table $84A4); rebuild tile display
    LD      HL, $84A4                       ; HL = $84A4: pointer table with 12 sprite-record addresses (2 bytes each)
    LD      C, $0C                          ; C = $0C: 12 sprite records

LOC_84D3:                                   ; LOC_84D3: loop — load record pointer from $84A4 table into IX
    LD      E, (HL)                         ; (IX+0) = 0: clear sprite Y
    INC     HL
    LD      D, (HL)
    INC     HL
    PUSH    DE
    POP     IX
    LD      A, $00
    LD      (IX+0), A
    LD      A, $00
    LD      (IX+2), A                       ; (IX+2) = 0: clear sprite active/visible flag
    LD      A, $00
    LD      (IX+21), A                      ; (IX+21) = 0: clear sprite animation frame
    DEC     C
    JP      NZ, LOC_84D3
    LD      A, $01                          ; A = $01: enable sprite visibility
    CALL    SUB_8E69                        ; CALL SUB_8E69: set $716D bit 1
    LD      A, $00                          ; A = $00: disable magnification
    CALL    SUB_8E7F                        ; CALL SUB_8E7F: clear $716D bit 0
    LD      B, $00                          ; B = $00, C = $1A, HL = $8685: first tile bitmap block (guards)
    LD      C, $1A
    LD      HL, $8685
    CALL    SUB_80D6                        ; CALL SUB_80D6: copy $1A rows of guard tile bitmaps to VRAM
    LD      B, $1B                          ; B = $1B, C = $03, HL = $89C5: second tile block
    LD      C, $03
    LD      HL, $89C5
    CALL    SUB_80D6                        ; CALL SUB_80D6: copy 3 rows
    LD      B, $21                          ; B = $21, C = $01, HL = $8A25: third tile block
    LD      C, $01
    LD      HL, $8A25
    CALL    SUB_80D6                        ; CALL SUB_80D6: copy 1 row
    LD      B, $23                          ; B = $23, C = $06, HL = $8A45: fourth tile block
    LD      C, $06
    LD      HL, $8A45
    CALL    SUB_80D6                        ; CALL SUB_80D6: copy 6 rows
    LD      B, $2F                          ; B = $2F, C = $06, HL = $8B05: fifth tile block
    LD      C, $06
    LD      HL, $8B05
    CALL    SUB_80D6                        ; CALL SUB_80D6: copy 6 rows
    LD      DE, $1C00                       ; DE = $1C00, A = $20: fill sprite-attr table with $20/$D0 (off-screen)
    LD      A, $20
    CALL    SUB_8112                        ; CALL SUB_8112: fill sprite attribute table rows
    CALL    SUB_84BC                        ; CALL SUB_84BC: init sprite attribute table with $D0
    LD      A, $01
    LD      C, $01
    LD      D, $19
    LD      E, $1A
    CALL    SUB_CD24
    LD      A, $01
    LD      C, $03
    LD      D, $1B
    LD      E, $1E
    CALL    SUB_CD24
    LD      A, $01
    LD      C, $01
    LD      D, $21
    LD      E, $22
    CALL    SUB_CD24
    LD      A, $01
    LD      C, $06
    LD      D, $23
    LD      E, $29
    CALL    SUB_CD24
    LD      A, $01
    LD      C, $06
    LD      D, $2F
    LD      E, $35
    CALL    SUB_CD24
    RET     

SUB_856C:                                   ; SUB_856C: sprite update — iterate 12 records at $84A4, compute VDP attrs, call SUB_8668
    LD      HL, (WORK_BUFFER)               ; Load WORK_BUFFER: save current register snapshot
    PUSH    HL
    LD      HL, ($7002)                     ; Load $7002: save sprite attr base
    PUSH    HL
    LD      HL, ($7004)                 ; RAM $7004
    PUSH    HL
    LD      HL, ($7006)                 ; RAM $7006
    PUSH    HL
    LD      A, $00
    LD      ($7156), A                      ; $7156 = 0: sprite-write index counter
    LD      A, $0C                          ; A = $0C: 12 sprite records to process
    LD      ($7001), A                      ; $7001 = $0C: loop counter
    LD      HL, $84A4                       ; HL = $84A4: sprite record pointer table

LOC_8589:                                   ; LOC_8589: load IX = sprite record pointer from table
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    INC     HL
    PUSH    BC
    POP     IX
    LD      A, (IX+2)                       ; (IX+2): check if sprite visible (active flag)
    CP      $00
    JP      Z, LOC_864E                     ; JP Z LOC_864E: skip if not active/visible
    LD      A, $00
    LD      ($7006), A                      ; $7006 = 0: reset sprite-write sub-counter
    LD      C, (IX+3)                       ; C = (IX+3), B = (IX+4): sprite source pointer
    LD      B, (IX+4)
    LD      E, (IX+5)                       ; E = (IX+5), D = (IX+6): sprite data pointer
    LD      D, (IX+6)

LOC_85A9:                                   ; LOC_85A9: write loop — load sprite attr data from record, compute VDP bytes
    PUSH    DE                              ; Load (BC): pattern / colour byte pair
    LD      A, (BC)
    LD      E, A
    INC     BC                              ; INC BC: advance source pointer
    LD      A, (BC)
    LD      D, A
    INC     BC
    PUSH    DE
    POP     IY                              ; IY = DE: load sprite data pointer
    POP     DE
    LD      A, (IX+7)                       ; (IX+7): sprite Y base offset
    ADD     A, $00
    ADD     A, (IY+0)                       ; (IY+0): add Y offset from data table
    LD      ($7003), A                      ; $7003 = computed Y sprite attribute byte
    LD      A, (IX+8)                       ; (IX+8): sprite X base offset
    ADD     A, $FF
    ADD     A, (IY+1)
    LD      ($7002), A                      ; $7002 = computed X sprite attribute byte
    PUSH    BC                              ; BC += $0002: advance by 2 bytes
    LD      BC, $0002
    ADD     IY, BC
    LD      A, (IX+10)
    LD      B, $00
    LD      C, A
    ADD     IY, BC                          ; (IX+10): pattern-index sub-step size
    POP     BC
    LD      A, (IY+0)
    LD      ($7004), A                      ; $7004 = pattern index byte from IY
    LD      A, (DE)                         ; (DE): colour attribute byte
    INC     DE
    AND     $0F                             ; AND $0F: mask colour nibble
    LD      ($7005), A                      ; $7005 = colour byte
    LD      A, (IX+9)
    AND     $80
    PUSH    HL
    LD      HL, $7005                   ; RAM $7005
    OR      (HL)
    LD      (HL), A
    POP     HL
    LD      A, (IX+1)                       ; (IX+1) = $FF: check for last sprite in set
    CP      $FF
    JP      NZ, LOC_861C
    LD      A, ($716D)                      ; Load $716D — VDP register shadow (sprite flags)
    BIT     1, A                            ; BIT 1: check sprite plane B enable
    JP      Z, LOC_860C
    LD      A, ($7004)                  ; RAM $7004
    SLA     A
    SLA     A
    LD      ($7004), A                  ; RAM $7004

LOC_860C:
    LD      A, ($7002)                  ; RAM $7002
    CP      $D0
    JP      Z, LOC_861C
    LD      A, (IX+0)
    CP      $00
    JP      NZ, LOC_8626

LOC_861C:
    LD      A, $E1
    LD      ($7002), A                  ; RAM $7002
    LD      A, $00
    LD      ($7004), A                  ; RAM $7004

LOC_8626:
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IX                              ; LOC_8626: call SUB_8668 to write $7002-$7005 as VDP sprite attr entry
    PUSH    IY                              ; PUSH everything: save all pointers
    LD      A, ($7156)                      ; $7156: sprite-write index
    LD      HL, $7002                   ; RAM $7002
    CALL    SUB_8668                        ; CALL SUB_8668: write sprite Y/X/pattern/colour to VRAM $1C00+index
    POP     IY
    POP     IX
    POP     HL
    POP     DE
    POP     BC
    PUSH    HL
    LD      HL, $7156                   ; RAM $7156
    INC     (HL)
    LD      HL, $7006                   ; RAM $7006
    INC     (HL)
    LD      A, (HL)
    CP      (IX+2)
    POP     HL
    JP      NZ, LOC_85A9

LOC_864E:
    PUSH    HL
    LD      HL, $7001                   ; RAM $7001
    DEC     (HL)
    POP     HL
    JP      NZ, LOC_8589
    POP     HL
    LD      ($7006), HL                 ; RAM $7006
    POP     HL
    LD      ($7004), HL                 ; RAM $7004
    POP     HL
    LD      ($7002), HL                 ; RAM $7002
    POP     HL
    LD      (WORK_BUFFER), HL           ; WORK_BUFFER
    RET     

SUB_8668:
    PUSH    HL
    SLA     A
    SLA     A
    LD      D, $00
    LD      E, A
    LD      HL, $1C00
    ADD     HL, DE
    PUSH    HL
    POP     DE
    POP     HL
    LD      B, $04
    LD      A, $00
    CALL    SUB_83FE
    RET     
    DB      $C9, $C9, $C9, $C9, $C9, $C9, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $07, $0F, $0F, $0F, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $E0, $F0, $F0, $F0, $1F, $1F
    DB      $1F, $19, $1F, $1F, $1F, $1F, $07, $00
    DB      $00, $00, $00, $00, $00, $00, $F8, $F8
    DB      $18, $F8, $18, $F8, $98, $F8, $E0, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $7F
    DB      $DF, $DF, $7F, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $FE
    DB      $FB, $FB, $FE, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $6D, $00
    DB      $00, $00, $00, $6D, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $B6, $00
    DB      $00, $00, $00, $B6, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $36, $00
    DB      $00, $00, $00, $5B, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $DA, $00
    DB      $00, $00, $00, $6C, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $0F, $1F, $1F, $1F, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $F0, $F8, $F8, $F8, $78, $FC
    DB      $FC, $FC, $FC, $78, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $18, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $FF, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $FF, $FF
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $FF, $FF
    DB      $FF, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $FF, $FF
    DB      $FF, $FF, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $FF, $FF
    DB      $FF, $FF, $FF, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $07, $07, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $E0, $F8, $07, $07
    DB      $07, $03, $01, $00, $00, $01, $01, $00
    DB      $00, $00, $00, $00, $00, $00, $20, $F0
    DB      $00, $C0, $80, $00, $00, $80, $C0, $CC
    DB      $7C, $30, $00, $00, $00, $00, $07, $07
    DB      $07, $03, $01, $00, $00, $01, $11, $30
    DB      $30, $18, $08, $00, $00, $00, $20, $F0
    DB      $00, $C0, $80, $00, $00, $86, $C6, $FC
    DB      $38, $00, $00, $00, $00, $00, $07, $07
    DB      $07, $03, $01, $00, $00, $07, $1F, $38
    DB      $38, $1C, $0F, $03, $00, $00, $20, $F0
    DB      $00, $C0, $80, $00, $00, $86, $86, $1C
    DB      $18, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $03, $07, $0F, $0F, $0F
    DB      $0F, $0F, $07, $07, $07, $03, $00, $00
    DB      $00, $00, $00, $C0, $E0, $E0, $E0, $E0
    DB      $E0, $E0, $E0, $E0, $E0, $C0, $03, $07
    DB      $07, $07, $07, $03, $01, $01, $01, $01
    DB      $01, $01, $01, $01, $00, $00, $C0, $E0
    DB      $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0
    DB      $E0, $E0, $E0, $E0, $00, $00, $03, $07
    DB      $07, $07, $07, $07, $07, $07, $3E, $3E
    DB      $3C, $00, $00, $00, $00, $00, $C0, $C0
    DB      $E0, $E0, $70, $70, $70, $78, $38, $38
    DB      $38, $38, $38, $00, $00, $00, $03, $07
    DB      $07, $07, $07, $03, $1F, $1F, $1F, $03
    DB      $03, $03, $03, $03, $00, $00, $C0, $C0
    DB      $E0, $F0, $B0, $B8, $FC, $FC, $F8, $80
    DB      $80, $80, $80, $80, $00, $00, $03, $07
    DB      $07, $07, $07, $0F, $1E, $1C, $1C, $38
    DB      $78, $70, $70, $00, $00, $00, $C0, $C0
    DB      $E0, $F0, $7C, $3E, $1E, $1C, $38, $38
    DB      $38, $00, $00, $00, $00, $00, $03, $07
    DB      $0F, $0F, $1E, $1C, $3C, $38, $38, $70
    DB      $70, $E0, $E0, $00, $00, $00, $C0, $C0
    DB      $FE, $FF, $FF, $0E, $0E, $0E, $0E, $00
    DB      $00, $00, $00, $00, $00, $00, $03, $07
    DB      $07, $77, $77, $7F, $3E, $1C, $1C, $00
    DB      $00, $00, $00, $00, $00, $00, $C0, $C0
    DB      $FE, $FF, $FF, $0E, $0E, $0E, $0E, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $01, $01, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $E0, $F0, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $C0, $C0
    DB      $C0, $80, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $38, $3C, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $60, $60, $60
    DB      $40, $00, $00, $00, $03, $03, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $80, $C0, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $70, $78, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $38, $3C, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $E0, $F0, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $0E
    DB      $0F, $00, $00, $00, $00, $00, $00, $F0
    DB      $70, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $0E
    DB      $0F, $00, $00, $00, $00, $00, $57, $71
    DB      $60, $71

SUB_8BC9:
    LD      ($7169), A                  ; RAM $7169
    LD      A, $00
    CALL    SUB_848E
    LD      A, ($7169)                  ; RAM $7169
    CALL    SUB_8481
    LD      ($716A), A                  ; RAM $716A
    LD      A, $01
    CALL    SUB_848E
    LD      A, ($7169)                  ; RAM $7169
    CALL    SUB_8481
    LD      ($716B), A                  ; RAM $716B
    LD      A, ($7169)                  ; RAM $7169
    SLA     A
    LD      HL, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER
    LD      L, A
    LD      BC, $8BC5
    ADD     HL, BC
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    PUSH    BC
    POP     IX
    LD      A, ($716A)                  ; RAM $716A
    CPL     
    AND     $0F
    LD      L, A
    LD      BC, $8C74
    LD      H, $00
    ADD     HL, BC
    LD      A, (HL)
    LD      B, A
    CP      $FF
    JP      Z, LOC_8C26
    LD      A, (IX+8)
    CP      $05
    JP      C, LOC_8C1F
    LD      A, B
    LD      (IX+2), A
    LD      (IX+3), $FF

LOC_8C1F:
    LD      (IX+8), $00
    JP      LOC_8C32

LOC_8C26:
    LD      A, (IX+8)
    CP      $05
    JP      NC, LOC_8C32
    INC     A
    LD      (IX+8), A

LOC_8C32:
    LD      A, ($716A)                  ; RAM $716A
    LD      B, A
    BIT     6, B
    CALL    SUB_8C6B
    LD      (IX+1), A
    LD      A, ($716B)                  ; RAM $716B
    LD      B, A
    BIT     6, B
    CALL    SUB_8C6B
    LD      (IX+0), A
    BIT     0, B
    CALL    SUB_8C6B
    LD      (IX+6), A
    BIT     1, B
    CALL    SUB_8C6B
    LD      (IX+5), A
    BIT     2, B
    CALL    SUB_8C6B
    LD      (IX+7), A
    BIT     3, B
    CALL    SUB_8C6B
    LD      (IX+4), A
    RET     

SUB_8C6B:
    JP      Z, LOC_8C71
    LD      A, $00
    RET     

LOC_8C71:
    LD      A, $FF
    RET     
    DB      $FF, $06, $01, $03, $09, $00, $0A, $FF
    DB      $02, $0B, $07, $FF, $05, $04, $08, $FF

SUB_8C84:
    LD      A, (HL)
    CP      $00
    JP      NZ, LOC_8C90
    LD      A, $00
    LD      (DE), A
    INC     DE
    LD      (DE), A
    RET     

LOC_8C90:
    INC     DE
    LD      A, (DE)
    CP      $02
    JP      NZ, LOC_8CA3
    DEC     DE
    LD      A, (DE)
    CP      $FF
    JP      Z, LOC_8CA6
    LD      A, $FF
    LD      (DE), A
    LD      (HL), A
    RET     

LOC_8CA3:
    LD      A, (DE)
    INC     A
    LD      (DE), A

LOC_8CA6:
    LD      A, $00
    LD      (HL), A
    RET     

SOUND_WRITE_8CAA:
    PUSH    AF
    CALL    SUB_8BC9
    POP     AF
    LD      HL, $8BC5
    LD      C, A
    CALL    SUB_B15F
    LD      C, $FF
    LD      A, (IX+3)
    CP      $00
    JP      Z, LOC_8CC3
    LD      C, (IX+2)

LOC_8CC3:
    LD      A, C
    RET     
    DB      $47, $C5, $78, $CD, $AA, $8C, $C1, $FE
    DB      $FF, $CA, $C6, $8C, $C9

SUB_8CD2:
    LD      C, A
    LD      HL, $8BC5
    CALL    SUB_B15F
    LD      A, $00
    LD      (IX+3), A
    RET     
    DB      $54, $48, $45, $20, $48, $45, $49, $53 ; "THE HEIS"
    DB      $54, $50, $52, $4F, $47, $52, $41, $4D ; "TPROGRAM"
    DB      $20, $41, $4E, $44, $20, $4F, $52, $49 ; " AND ORI"
    DB      $47, $49, $4E, $41, $4C, $20, $4D, $55 ; "GINAL MU"
    DB      $53, $49, $43, $43, $4F, $50, $59, $52 ; "SICCOPYR"
    DB      $49, $47, $48, $54, $20, $31, $39, $38 ; "IGHT 198"
    DB      $33, $42, $59, $20, $4C, $49, $56, $45 ; "3BY LIVE"
    DB      $53, $41, $59, $20, $43, $4F, $4D, $50 ; "SAY COMP"
    DB      $55, $54, $45, $52, $20, $47, $41, $4D ; "UTER GAM"
    DB      $45, $53, $2C, $20, $49, $4E, $43, $2E ; "ES, INC."
    DB      $50, $52, $4F, $47, $52, $41, $4D, $20 ; "PROGRAM "
    DB      $41, $4E, $44, $20, $43, $4F, $4E, $43 ; "AND CONC"
    DB      $45, $50, $54, $20, $42, $59, $20, $4D ; "EPT BY M"
    DB      $49, $4B, $45, $20, $4C, $49, $56, $45 ; "IKE LIVE"
    DB      $53, $41, $59               ; "SAY"

START:                                      ; START: called by BIOS after cart detection; one-time init + game-loop entry
    LD      SP, $73FF                       ; LD SP, $73FF: set stack pointer to top of RAM
    CALL    SUB_8325                        ; CALL SUB_8325: cold hardware init (VDP, sound, screen)

LOC_8D58:                                   ; LOC_8D58: outer game loop — reset state, call level-start sequence
    CALL    SOUND_WRITE_9651                ; CALL SOUND_WRITE_9651: show title screen / attract mode
    CALL    SUB_8238                        ; CALL SUB_8238: clear game state vars (lives=$03, counters=0)

LOC_8D5E:                                   ; LOC_8D5E: level-start: render level, place sprites, wait for entry
    CALL    SOUND_WRITE_825A                ; CALL SOUND_WRITE_825A: level init (load tiles, spawn entities)

LOC_8D61:                                   ; LOC_8D61: game tick loop — update all entities, check win/lose each frame
    CALL    SOUND_WRITE_82D2                ; CALL SOUND_WRITE_82D2: full frame render+update (guards, thief, objects)
    CALL    SOUND_WRITE_95A9                ; CALL SOUND_WRITE_95A9: controller input + per-frame game-state update
    LD      A, ($719C)                      ; Load $719C — level-exit/win flag ($FF = level complete)
    CP      $FF
    JP      Z, LOC_8D58                     ; JP Z LOC_8D58: won → restart at outer loop
    LD      A, ($71F2)                      ; Load $71F2 — bonus/special flag
    CP      $FF
    JP      Z, LOC_8DAA                     ; JP Z LOC_8DAA: flag set → go to end-of-level path
    LD      A, ($7199)                      ; Load $7199 — extra-life flag
    CP      $FF
    JP      Z, LOC_8D61                     ; JP Z LOC_8D61: flag set → continue inner loop
    LD      A, ($71A2)                      ; Load $71A2 — caught/dead flag
    CP      $00                             ; CP $00: check if player was caught
    JP      NZ, LOC_8DAA                    ; JP NZ LOC_8DAA: caught → lose-a-life path
    LD      A, ($7197)                      ; Load $7197 — level-step counter
    ADD     A, $01                          ; ADD A, $01: increment step
    LD      ($7197), A                      ; $7197 updated
    CP      $03                             ; CP $03: have we done 3 steps (1 level cycle)?
    JP      C, LOC_8DA4
    LD      A, $00                          ; JP C LOC_8DA4: not yet — continue inner loop
    LD      ($7197), A                      ; $7197 = 0: reset step counter
    LD      HL, $7196                       ; HL = $7196: level/difficulty counter
    INC     (HL)                            ; INC (HL): advance difficulty
    LD      A, (HL)                         ; Load (HL): check new difficulty value
    CP      $02                             ; CP $02: max 2 difficulty levels?
    JP      NZ, LOC_8DA4
    DEC     (HL)                            ; DEC (HL): clamp at 2

LOC_8DA4:                                   ; LOC_8DA4: CALL SUB_DC85: advance to next level segment
    CALL    SUB_DC85
    JP      LOC_8D5E                        ; JP LOC_8D5E: back to level-start

LOC_8DAA:                                   ; LOC_8DAA: player caught/out-of-lives path
    LD      A, ($71A1)                      ; Load $71A1 — lives counter (BCD)
    SUB     $01                             ; SUB $01, DAA: decrement BCD lives
    DAA     
    LD      ($71A1), A                      ; $71A1 = new lives (BCD)
    CP      $00                             ; CP $00: check if out of lives
    JP      NZ, LOC_8DBE                    ; JP NZ LOC_8DBE: still lives left
    CALL    SUB_97B4                        ; CALL SUB_97B4: game-over sequence (flash screen, play tune)
    JP      LOC_8DCC                        ; JP LOC_8DCC: go back to outer loop (title screen)

LOC_8DBE:
    LD      A, $04
    LD      ($719A), A                  ; RAM $719A
    CALL    SOUND_WRITE_B20E
    CALL    SUB_9AAF
    JP      LOC_8D61

LOC_8DCC:
    JP      LOC_8D58

SUB_8DCF:                                   ; SUB_8DCF: init VDP from 8-byte register table at $8DFB; then clear VRAM
    LD      IX, $8DFB                       ; IX = $8DFB: VDP init register-value table
    LD      IY, $716C                       ; IY = $716C: VDP register shadow RAM
    LD      B, $00                          ; B = $00: register index 0

LOC_8DD9:                                   ; LOC_8DD9: loop — write (IX+0) to VDP register B and shadow RAM
    PUSH    IY
    PUSH    IX
    PUSH    BC
    LD      A, (IX+0)                       ; A = (IX+0): load register value from ROM table
    LD      (IY+0), A                       ; (IY+0) = A: shadow RAM copy
    CALL    SUB_83F2                        ; CALL SUB_83F2: write to VDP register B
    POP     BC
    POP     IX
    POP     IY
    INC     IX                              ; INC IX: next table value
    INC     IY                              ; INC IY: next shadow byte
    INC     B                               ; INC B: next register
    LD      A, B
    CP      $08                             ; CP $08: stop after 8 registers
    JP      NZ, LOC_8DD9
    CALL    SUB_8465                        ; CALL SUB_8465: clear all 16 KB VRAM
    RET     
    DB      $00, $80, $00, $00, $00, $00, $00, $00

SOUND_WRITE_8E03:                           ; SOUND_WRITE_8E03: set/clear $716D bit 6 (layer-A / sprite-table enable)
    LD      HL, $716D                       ; HL = $716D: VDP register 1 shadow
    CP      $FF                             ; CP $FF: $FF = set bit (enable), else clear
    JP      Z, LOC_8E10
    SET     6, (HL)                         ; SET 6, (HL): enable layer A (sprite table active)
    JP      LOC_8E12                        ; JP LOC_8E12: write $716D to VDP reg 1

LOC_8E10:                                   ; LOC_8E10: RES 6, (HL): disable layer A
    RES     6, (HL)

LOC_8E12:                                   ; LOC_8E12: LD B=$01; write $716D value to VDP register 1
    LD      B, $01
    LD      A, (HL)
    CALL    SUB_83F2
    RET     

SOUND_WRITE_8E19:                           ; SOUND_WRITE_8E19: set/clear $716D bit 5 (NMI music path enable)
    LD      HL, $716D                       ; HL = $716D: VDP register 1 shadow
    CP      $FF                             ; CP $FF: $FF = set bit, else clear
    JP      Z, LOC_8E26
    RES     5, (HL)                         ; RES 5, (HL): disable NMI music path
    JP      LOC_8E28

LOC_8E26:
    SET     5, (HL)

LOC_8E28:
    LD      B, $01
    LD      A, (HL)
    CALL    SUB_83F2
    RET     

SUB_8E2F:                                   ; SUB_8E2F: init sprite plane mask — A selects bits to set in $716C/$716D
    LD      ($7174), A                      ; $7174 = A: save plane index
    LD      BC, JOYSTICK_BUFFER             ; BC = JOYSTICK_BUFFER ($0000): zero base for index calc
    LD      C, A                            ; C = A: use A as byte offset
    LD      HL, $8E61                       ; HL = $8E61: mask table for $716C
    ADD     HL, BC                          ; ADD HL, BC: point to this plane's mask byte
    LD      A, ($716C)                      ; Load $716C — VDP reg 0 shadow
    LD      D, A
    LD      A, (HL)
    OR      D                               ; OR (HL): apply mask bit (OR to enable plane bits)
    LD      ($716C), A                      ; $716C = updated: write back
    LD      HL, $8E65                       ; HL = $8E65: mask table for $716D (register 1)
    ADD     HL, BC
    LD      A, ($716D)                      ; Load $716D — VDP reg 1 shadow
    LD      D, A
    LD      A, (HL)
    OR      D                               ; OR (HL): apply mask
    LD      ($716D), A                      ; $716D = updated
    LD      B, $00                          ; B = $00: write to VDP reg 0
    LD      A, ($716C)                  ; RAM $716C
    CALL    SUB_83F2                        ; CALL SUB_83F2: write $716C to VDP reg 0
    LD      B, $01                          ; B = $01: write to VDP reg 1
    LD      A, ($716D)                      ; Load $716D
    CALL    SUB_83F2                        ; CALL SUB_83F2: write $716D to VDP reg 1
    RET     
    DB      $00, $02, $00, $00, $00, $00, $08, $10

SUB_8E69:                                   ; SUB_8E69: set/clear $716D bit 1 (sprite size: 0=8×8, 1=16×16 double)
    LD      HL, $716D                       ; HL = $716D: VDP reg 1 shadow
    CP      $00                             ; CP $00: zero = clear bit
    JP      NZ, LOC_8E76                    ; JP NZ LOC_8E76: NZ = set bit
    RES     1, (HL)                         ; RES 1, (HL): clear bit 1
    JP      LOC_8E78

LOC_8E76:                                   ; LOC_8E76: SET 1, (HL): set bit 1
    SET     1, (HL)

LOC_8E78:                                   ; LOC_8E78: write updated $716D to VDP register 1
    LD      A, (HL)
    LD      B, $01
    CALL    SUB_83F2
    RET     

SUB_8E7F:                                   ; SUB_8E7F: set/clear $716D bit 0 (sprite magnification: 0=normal, 1=double size)
    LD      HL, $716D                       ; HL = $716D: VDP reg 1 shadow
    CP      $00                             ; CP $00: 0 = clear bit (normal size)
    JP      Z, LOC_8E8C
    SET     0, (HL)
    JP      LOC_8E8E

LOC_8E8C:
    RES     0, (HL)

LOC_8E8E:
    LD      A, (HL)
    LD      B, $01
    CALL    SUB_83F2
    RET     

SUB_8E95:                                   ; SUB_8E95: set name-table address — BC>>2 → $716E; write VDP reg 2
    SRL     B                               ; SRL B × 2: BC >> 2 (page units for VDP reg 2)
    SRL     B
    LD      A, B                            ; A = B: page value
    LD      ($716E), A                      ; $716E = A: name-table page shadow
    LD      B, $02                          ; B = $02: VDP register 2
    CALL    SUB_83F2                        ; CALL SUB_83F2: write to VDP reg 2
    RET     

SUB_8EA3:                                   ; SUB_8EA3: set colour-table address — BC<<2 → $716F; write VDP reg 3
    RL      C                               ; RL C, RL B × 2: BC << 2
    RL      B
    RL      C
    RL      B
    LD      A, ($7174)                      ; Load $7174 — sprite plane index
    CP      $01                             ; CP $01: plane 1 special case
    JP      NZ, LOC_8EB7                    ; JP NZ LOC_8EB7: skip
    LD      A, B                            ; A = B: get high byte
    OR      $7F                             ; OR $7F: set high bits for extended colour table
    LD      B, A

LOC_8EB7:                                   ; LOC_8EB7: A = B: final colour-table page value
    LD      A, B                            ; $716F = A: shadow
    LD      ($716F), A                      ; B = $03: VDP register 3
    LD      B, $03                          ; CALL SUB_83F2: write to VDP reg 3
    CALL    SUB_83F2
    RET     

SUB_8EC1:                                   ; SUB_8EC1: set pattern-table address — BC>>3 → $7170; write VDP reg 4
    SRL     B                               ; SRL B × 3: BC >> 3 (8-byte unit alignment)
    SRL     B
    SRL     B
    LD      A, ($7174)                      ; Load $7174 — plane index
    CP      $01                             ; CP $01: plane 1 special case
    JP      NZ, LOC_8ED3                    ; JP NZ LOC_8ED3
    LD      A, B                            ; A = B: get value
    OR      $03                             ; OR $03: set low bits for full pattern table
    LD      B, A

LOC_8ED3:                                   ; LOC_8ED3: $7170 = A: shadow
    LD      A, B                            ; B = $04: VDP register 4
    LD      ($7170), A                  ; RAM $7170
    LD      B, $04                          ; CALL SUB_83F2: write to VDP reg 4
    CALL    SUB_83F2
    RET     

SUB_8EDD:                                   ; SUB_8EDD: set sprite-attribute-table address — BC<<1 → $7171; write VDP reg 5
    RL      C                               ; RL C, RL B: BC << 1
    RL      B
    LD      A, B                            ; A = B: page value
    LD      ($7171), A                      ; $7171 = A: shadow
    LD      B, $05                          ; B = $05: VDP register 5
    CALL    SUB_83F2                        ; CALL SUB_83F2: write to VDP reg 5
    RET     

SUB_8EEB:                                   ; SUB_8EEB: set sprite-pattern-table address — BC>>3 → $7172; write VDP reg 6
    SRL     B                               ; SRL B × 3: BC >> 3
    SRL     B
    SRL     B
    LD      A, B                            ; A = B: page value
    LD      ($7172), A                      ; $7172 = A: shadow
    LD      B, $06                          ; B = $06: VDP register 6
    CALL    SUB_83F2                        ; CALL SUB_83F2: write to VDP reg 6
    RET     

SUB_8EFB:                                   ; SUB_8EFB: set background colour — A<<4 merged with $7173 low nibble → VDP reg 7
    SLA     A                               ; SLA A × 4: shift A to high nibble
    SLA     A
    SLA     A
    SLA     A
    AND     $F0                             ; AND $F0: mask to high nibble (background colour)
    LD      B, A                            ; B = A: save for merge
    LD      A, ($7173)                      ; Load $7173 — foreground colour shadow
    AND     $0F
    OR      B
    LD      ($7173), A                  ; RAM $7173
    LD      B, $07
    CALL    SUB_83F2
    RET     

SUB_8F15:
    AND     $0F
    LD      B, A
    LD      A, ($7173)                  ; RAM $7173
    AND     $F0
    OR      B
    LD      ($7173), A                  ; RAM $7173
    LD      B, $07
    CALL    SUB_83F2
    RET     
    DB      $20, $01, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00

SUB_8F49:                                   ; SUB_8F49: compute TMS9918A sprite attribute bytes and write to VRAM $1C00
    LD      ($7175), A                      ; $7175 = A: save write-mode parameter
    LD      A, B                            ; A = B → $7176: save sprite row (Y screen position)
    LD      ($7176), A                  ; RAM $7176
    LD      A, C                            ; A = C → $7177: save sprite column (X screen position)
    LD      ($7177), A                  ; RAM $7177
    PUSH    HL                              ; PUSH HL → IX: sprite animation data pointer
    POP     IX
    LD      A, (IX+0)                       ; (IX+0) → $7178: load animation frame byte 0
    LD      ($7178), A                  ; RAM $7178
    LD      A, (IX+1)                       ; (IX+1) → $7179: load animation frame byte 1
    LD      ($7179), A                  ; RAM $7179
    LD      BC, $0002                       ; BC += 2: skip past the 2 anim bytes in data
    ADD     HL, BC
    PUSH    HL
    PUSH    DE
    POP     HL
    ADD     HL, BC
    PUSH    HL
    POP     DE
    POP     HL
    LD      A, ($716F)                      ; Load $716F — colour table page (VDP reg 3 shadow)
    AND     $80                             ; AND $80: extract sprite colour-table select bit
    SRL     A                               ; SRL A × 2: shift to colour-attr bit position
    SRL     A
    OR      $40                             ; OR $40: set VDP colour-attr flag
    LD      ($717A), A                      ; $717A = computed colour attribute byte
    LD      A, ($7170)                      ; Load $7170 — pattern table page (VDP reg 4 shadow)
    AND     $04                             ; AND $04: extract pattern-select bit
    SLA     A                               ; SLA A × 3: shift to pattern-attr position
    SLA     A
    SLA     A
    OR      $40                             ; OR $40: set attribute flag
    LD      ($717B), A                      ; $717B = computed pattern attribute byte

LOC_8F8C:                                   ; LOC_8F8C: compute final sprite attr bytes from $717A/$717B and position
    LD      A, ($717A)                      ; Load $717A: colour attr
    AND     $E0                             ; AND $E0: mask to high 3 bits
    LD      B, A                            ; B = masked value
    LD      A, ($7177)                      ; C = $7177 >> 3: compute column tile index
    SRL     A
    SRL     A
    SRL     A
    LD      C, A
    OR      B                               ; OR B: merge tile + colour bits → $717A
    LD      ($717A), A                  ; RAM $717A
    LD      A, ($717B)                      ; Load $717B: pattern attr
    AND     $E0
    OR      C
    LD      ($717B), A                  ; RAM $717B
    LD      A, ($7177)                      ; Load $7177: column
    AND     $07                             ; AND $07: low 3 bits of column
    LD      B, A                            ; B = low column bits
    LD      A, ($7176)                      ; Load $7176: row
    SLA     A                               ; SLA A × 3: row << 3 (row × 8)
    SLA     A
    SLA     A                               ; OR B: merge row and column bits → $717C
    OR      B
    LD      ($717C), A                  ; RAM $717C
    LD      A, ($7178)                      ; Load $7178: animation frame byte 0
    LD      B, A                            ; B = A: save for compare

LOC_8FC0:                                   ; LOC_8FC0: write sprite attribute to VDP at $1C00 + $7177
    LD      A, ($7175)                  ; RAM $7175
    CP      $02
    JP      Z, LOC_8FE3
    IN      A, ($A1)
    LD      A, ($717C)                  ; RAM $717C
    OUT     ($A1), A
    LD      A, ($717B)                  ; RAM $717B
    OUT     ($A1), A
    LD      A, (HL)
    LD      C, A
    LD      A, ($7175)                  ; RAM $7175
    CP      $00
    JP      NZ, LOC_8FE0
    LD      C, $00

LOC_8FE0:
    LD      A, C
    OUT     ($A0), A

LOC_8FE3:
    IN      A, ($A1)
    LD      A, ($717C)                  ; RAM $717C
    OUT     ($A1), A
    LD      A, ($717A)                  ; RAM $717A
    OUT     ($A1), A
    LD      A, (DE)
    LD      C, A
    LD      A, ($7175)                  ; RAM $7175
    CP      $00
    JP      NZ, LOC_8FFB
    LD      C, $00

LOC_8FFB:
    LD      A, C
    OUT     ($A0), A
    INC     HL
    INC     DE
    LD      A, ($717C)                  ; RAM $717C
    ADD     A, $08
    LD      ($717C), A                  ; RAM $717C
    DJNZ    LOC_8FC0
    LD      A, ($7177)                  ; RAM $7177
    INC     A
    LD      ($7177), A                  ; RAM $7177
    LD      A, ($7179)                  ; RAM $7179
    DEC     A
    LD      ($7179), A                  ; RAM $7179
    JP      NZ, LOC_8F8C
    RET     
    DB      $78, $F5, $3E, $01, $CD, $48, $92, $F1
    DB      $C5, $47, $CD, $FD, $92, $C1, $78, $A6
    DB      $C2, $37, $90, $79, $E6, $0F, $37, $3F
    DB      $C3, $41, $90, $CB, $39, $CB, $39, $CB
    DB      $39, $CB, $39, $79, $37, $C9

SUB_9042:                                   ; SUB_9042: clear all 192 sprite slots — loop C=0..$BF, call SUB_8F49 for each
    LD      B, $00                          ; B = $00, C = $00: start at slot 0
    LD      C, $00
                                            ; LOC_9046: write each slot — A=$01 (set-addr mode)
LOC_9046:
    LD      A, $01                          ; A = $01: VDP addr-set mode
    LD      DE, $8F27                       ; DE = $8F27, HL = $8F27: blank/clear sprite data pointer
    LD      HL, $8F27
    PUSH    BC                              ; PUSH BC: save loop counter
    CALL    SUB_8F49                        ; CALL SUB_8F49: write blank sprite entry for slot C
    POP     BC
    INC     C                               ; INC C: next slot
    LD      A, C
    CP      $C0                             ; CP $C0: done when C = 192
    JP      NZ, LOC_9046
    RET     
    DB      $32, $80, $71, $7C, $32, $7F, $71, $26
    DB      $00, $6A, $C5, $48, $06, $00, $37, $3F
    DB      $ED, $42, $C1, $22, $81, $71, $26, $00
    DB      $6B, $C5, $06, $00, $37, $3F, $ED, $42
    DB      $C1, $22, $83, $71, $78, $32, $7D, $71
    DB      $79, $32, $7E, $71, $2A, $81, $71, $CD
    DB      $9E, $91, $7D, $32, $85, $71, $2A, $83
    DB      $71, $CD, $9E, $91, $7D, $32, $86, $71
    DB      $3A, $82, $71, $E6, $80, $47, $3A, $84
    DB      $71, $A8, $E6, $80, $32, $87, $71, $3A
    DB      $86, $71, $47, $3A, $85, $71, $B8, $DA
    DB      $01, $91, $CD, $AE, $91, $3A, $7E, $71
    DB      $32, $8D, $71, $3E, $00, $32, $8C, $71
    DB      $3A, $82, $71, $E6, $80, $C2, $E0, $90
    DB      $0E, $00, $CD, $4E, $91, $0C, $3A, $81
    DB      $71, $47, $79, $B8, $DA, $CD, $90, $CA
    DB      $CD, $90, $C3, $4D, $91, $2A, $88, $71
    DB      $E5, $C1, $21, $00, $00, $37, $3F, $ED
    DB      $42, $22, $88, $71, $0E, $00, $CD, $4E
    DB      $91, $0D, $3A, $81, $71, $47, $79, $B8
    DB      $D2, $F1, $90, $C3, $4D, $91, $CD, $B9
    DB      $91, $3A, $7D, $71, $32, $8B, $71, $3E
    DB      $00, $32, $8A, $71, $3A, $84, $71, $E6
    DB      $80, $C2, $2C, $91, $0E, $00, $CD, $76
    DB      $91, $0C, $3A, $83, $71, $47, $79, $B8
    DB      $DA, $19, $91, $CA, $19, $91, $C3, $4D
    DB      $91, $2A, $88, $71, $E5, $C1, $21, $00
    DB      $00, $37, $3F, $ED, $42, $22, $88, $71
    DB      $0E, $00, $CD, $76, $91, $0D, $3A, $83
    DB      $71, $47, $79, $B8, $D2, $3D, $91, $C3
    DB      $4D, $91, $C9, $C5, $3A, $7D, $71, $81
    DB      $32, $8B, $71, $3A, $8B, $71, $47, $3A
    DB      $8D, $71, $4F, $3A, $7F, $71, $57, $3A
    DB      $80, $71, $CD, $F3, $91, $2A, $8C, $71
    DB      $E5, $C1, $2A, $88, $71, $09, $22, $8C
    DB      $71, $C1, $C9, $C5, $3A, $7E, $71, $81
    DB      $32, $8D, $71, $3A, $8B, $71, $47, $3A
    DB      $8D, $71, $4F, $3A, $7F, $71, $57, $3A
    DB      $80, $71, $CD, $F3, $91, $2A, $8A, $71
    DB      $E5, $C1, $2A, $88, $71, $09, $22, $8A
    DB      $71, $C1, $C9, $7C, $E6, $80, $CA, $AD
    DB      $91, $E5, $C1, $21, $00, $00, $37, $3F
    DB      $ED, $42, $C9, $3A, $86, $71, $67, $3A
    DB      $85, $71, $4F, $C3, $C1, $91, $3A, $85
    DB      $71, $67, $3A, $86, $71, $4F, $2E, $00
    DB      $06, $00, $11, $00, $00, $37, $3F, $ED
    DB      $42, $DA, $D3, $91, $13, $C3, $C8, $91
    DB      $7B, $32, $88, $71, $7A, $32, $89, $71
    DB      $3A, $87, $71, $FE, $00, $CA, $F2, $91
    DB      $2A, $88, $71, $E5, $C1, $21, $00, $00
    DB      $37, $3F, $ED, $42, $22, $88, $71, $C9
    DB      $32, $8E, $71, $7A, $32, $8F, $71, $C5
    DB      $3E, $01, $CD, $48, $92, $D1, $D5, $C5
    DB      $42, $CD, $FD, $92, $C1, $3A, $8E, $71
    DB      $FE, $00, $CA, $2B, $92, $7E, $EE, $FF
    DB      $A0, $47, $79, $E6, $F0, $4F, $3A, $8F
    DB      $71, $E6, $0F, $B1, $4F, $59, $50, $C1
    DB      $3E, $00, $CD, $48, $92, $C3, $47, $92
    DB      $7E, $B0, $47, $79, $E6, $0F, $4F, $3A
    DB      $8F, $71, $CB, $27, $CB, $27, $CB, $27
    DB      $CB, $27, $B1, $4F, $59, $50, $C1, $3E
    DB      $00, $CD, $48, $92, $C9, $32, $95, $71
    DB      $D5, $78, $32, $90, $71, $79, $32, $91
    DB      $71, $3A, $90, $71, $E6, $F8, $32, $94
    DB      $71, $3A, $91, $71, $E6, $07, $21, $94
    DB      $71, $B6, $77, $3A, $91, $71, $CB, $3F
    DB      $CB, $3F, $CB, $3F, $E6, $1F, $32, $92
    DB      $71, $32, $93, $71, $3A, $6F, $71, $E6
    DB      $80, $CB, $3F, $CB, $3F, $21, $93, $71
    DB      $B6, $E6, $3F, $77, $3A, $70, $71, $E6
    DB      $04, $CB, $27, $CB, $27, $CB, $27, $21
    DB      $92, $71, $B6, $E6, $3F, $77, $3A, $94
    DB      $71, $5F, $6F, $3A, $92, $71, $67, $3A
    DB      $93, $71, $57, $3A, $95, $71, $FE, $00
    DB      $CA, $CD, $92, $DD, $E1, $DB, $A1, $7D
    DB      $D3, $A1, $7C, $D3, $A1, $CD, $FA, $92
    DB      $DB, $A0, $47, $DB, $A1, $7B, $D3, $A1
    DB      $7A, $D3, $A1, $CD, $FA, $92, $DB, $A0
    DB      $4F, $C9, $C1, $DB, $A1, $3A, $94, $71
    DB      $D3, $A1, $3A, $92, $71, $F6, $40, $D3
    DB      $A1, $CD, $FA, $92, $78, $D3, $A0, $CD
    DB      $FA, $92, $DB, $A1, $3A, $94, $71, $D3
    DB      $A1, $3A, $93, $71, $F6, $40, $D3, $A1
    DB      $CD, $FA, $92, $79, $D3, $A0, $C9, $00
    DB      $00, $C9, $78, $E6, $07, $21, $09, $93
    DB      $5F, $16, $00, $19, $7E, $C9, $80, $40
    DB      $20, $10, $08, $04, $02, $01, $DD, $E5
    DB      $FD, $E5, $CB, $27, $4F, $06, $00, $DD
    DB      $21, $42, $93, $DD, $09, $3A, $9D, $71
    DB      $DD, $86, $00, $27, $32, $9D, $71, $3A
    DB      $9E, $71, $DD, $8E, $01, $27, $32, $9E
    DB      $71, $3A, $9F, $71, $CE, $00, $27, $32
    DB      $9F, $71, $FD, $E1, $DD, $E1, $C9, $50
    DB      $00, $00, $01, $50, $01, $00, $02, $50
    DB      $02

SUB_934C:                                   ; SUB_934C: load animation frame sequence for one sprite from ROM table
    LD      HL, $9381                       ; HL = $9381: animation sequence pointer table
    SLA     A                               ; SLA A: A×2 (16-bit pointer table)
    PUSH    BC
    LD      C, A                            ; C = A, B = $00: word index
    LD      B, $00
    ADD     HL, BC                          ; ADD HL, BC: point to this entry
    LD      C, (HL)                         ; C = (HL), B = (HL+1): load sequence address
    INC     HL
    LD      B, (HL)
    LD      L, C                            ; L = C, H = B: HL = sequence data pointer
    LD      H, B
    LD      BC, $71A7                       ; BC = $71A7: animation state record in RAM
    LD      A, $01                          ; (BC) = $01: set animation active flag
    LD      (BC), A
    INC     BC                              ; INC BC
    LD      A, $09                          ; (BC) = $09: set animation speed divider
    LD      (BC), A
    INC     BC                              ; SLA D × 4: D = frame index × 16 (bytes per frame)
    SLA     D
    SLA     D
    SLA     D
    SLA     D
    LD      A, D                            ; A = D: initial frame data offset
    LD      D, $09                          ; D = $09: animation tick counter

LOC_9371:
    LD      (BC), A
    INC     BC
    DEC     D
    JP      NZ, LOC_9371
    POP     BC
    LD      A, $01
    LD      DE, $71A7                   ; RAM $71A7
    CALL    SUB_8F49
    RET     
    DB      $95, $93, $A0, $93, $AB, $93, $B6, $93
    DB      $C1, $93, $CC, $93, $D7, $93, $E2, $93
    DB      $ED, $93, $F8, $93, $01, $09, $7E, $66
    DB      $66, $66, $66, $66, $66, $66, $7E, $01
    DB      $09, $18, $18, $18, $18, $18, $18, $18
    DB      $18, $18, $01, $09, $7E, $66, $06, $06
    DB      $7E, $60, $60, $66, $7E, $01, $09, $7E
    DB      $06, $06, $06, $7E, $06, $06, $06, $7E
    DB      $01, $09, $60, $66, $66, $66, $7F, $06
    DB      $06, $06, $06, $01, $09, $7E, $60, $60
    DB      $60, $7E, $06, $06, $06, $7E, $01, $09
    DB      $78, $60, $60, $60, $7E, $66, $66, $66 ; "x```~fff"
    DB      $7E, $01, $09, $7E, $66, $06, $0C, $18
    DB      $18, $18, $18, $18, $01, $09, $3C, $3C
    DB      $3C, $3C, $7E, $66, $66, $66, $7E, $01
    DB      $09, $7E, $66, $66, $66, $7E, $06, $06
    DB      $66, $7E

SOUND_WRITE_9403:
    PUSH    AF
    LD      A, $00
    LD      ($700C), A                  ; RAM $700C
    POP     AF
    LD      L, A
    DEC     A

LOC_940C:
    CP      $02
    JP      NC, LOC_9418
    PUSH    AF
    LD      A, $FF
    LD      ($700C), A                  ; RAM $700C
    POP     AF

LOC_9418:
    PUSH    AF
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    HL
    LD      L, E
    LD      H, D
    LD      D, $00
    LD      E, A
    SRL     E
    ADD     HL, DE
    AND     $01
    JP      NZ, LOC_9430
    LD      A, (HL)
    AND     $0F
    JP      LOC_9439

LOC_9430:
    LD      A, (HL)
    SRL     A
    SRL     A
    SRL     A
    SRL     A

LOC_9439:
    POP     HL
    LD      D, H
    PUSH    AF
    CP      $00
    JP      Z, LOC_9446
    LD      A, $FF
    LD      ($700C), A                  ; RAM $700C

LOC_9446:
    LD      A, ($700C)                  ; RAM $700C
    CP      $FF
    JP      Z, LOC_9450
    LD      D, $01

LOC_9450:
    POP     AF
    CALL    SUB_934C
    POP     HL
    POP     DE
    POP     BC
    POP     AF
    INC     B
    DEC     A
    DEC     L
    JP      NZ, LOC_940C
    RET     

SUB_945F:
    CALL    SUB_94A2
    JP      C, LOC_9472
    CALL    SUB_9526
    JP      C, LOC_9472
    CALL    SUB_9574
    JP      C, LOC_9472
    RET     

LOC_9472:
    CALL    SOUND_WRITE_83AC
    CALL    SUB_9482
    CALL    SUB_9506
    CALL    SUB_9541
    CALL    SOUND_WRITE_83C5
    RET     

SUB_9482:
    CALL    SUB_94A2
    JP      NC, LOC_94A1
    LD      BC, $0003
    LD      HL, $719D                   ; RAM $719D
    LD      DE, $71B3                   ; RAM $71B3
    LDIR    
    LD      H, $08
    LD      A, $06
    LD      B, $02
    LD      C, $0D
    LD      DE, $719D                   ; RAM $719D
    CALL    SOUND_WRITE_9403

LOC_94A1:
    RET     

SUB_94A2:
    LD      HL, $719D                   ; RAM $719D
    LD      IX, $71B3                   ; RAM $71B3
    LD      BC, $0003

LOC_94AC:
    LD      A, (IX+0)
    CPI     
    JP      NZ, LOC_94BB
    INC     IX
    JP      PE, LOC_94AC
    AND     A
    RET     

LOC_94BB:
    SCF     
    RET     

SUB_94BD:
    CALL    SUB_94EB
    JP      NC, LOC_94EA
    LD      BC, $0002
    LD      HL, $71A4                   ; RAM $71A4
    LD      DE, $71B6                   ; RAM $71B6
    LDIR    
    LD      A, $01
    LD      B, $0E
    LD      C, $0D
    LD      DE, $71A5                   ; RAM $71A5
    LD      H, $02
    CALL    SOUND_WRITE_9403
    LD      A, $02
    LD      B, $10
    LD      C, $0D
    LD      DE, $71A4                   ; RAM $71A4
    LD      H, $02
    CALL    SOUND_WRITE_9403

LOC_94EA:
    RET     

SUB_94EB:
    LD      HL, $71A4                   ; RAM $71A4
    LD      IX, $71B6                   ; RAM $71B6
    LD      BC, $0002

LOC_94F5:
    LD      A, (IX+0)
    CPI     
    JP      NZ, LOC_9504
    INC     IX
    JP      PE, LOC_94F5
    AND     A
    RET     

LOC_9504:
    SCF     
    RET     

SUB_9506:
    CALL    SUB_9526
    JP      NC, LOC_9525
    LD      BC, $0001
    LD      HL, $71A3                   ; RAM $71A3
    LD      DE, $71B8                   ; RAM $71B8
    LDIR    
    LD      H, $0D
    LD      A, $02
    LD      B, $16
    LD      C, $0D
    LD      DE, $71A3                   ; RAM $71A3
    CALL    SOUND_WRITE_9403

LOC_9525:
    RET     

SUB_9526:                                   ; SUB_9526: check $71A3 (score/obj count) against $71B8 table (CPI loop)
    LD      HL, $71A3                       ; HL = $71A3: object counter
    LD      IX, $71B8                       ; IX = $71B8: reference table
    LD      BC, $0001                       ; BC = $0001: compare 1 byte at a time

LOC_9530:                                   ; LOC_9530: CPI — compare (HL) to (IX); INC HL; DEC BC
    LD      A, (IX+0)
    CPI                                     ; CPI: compare and advance
    JP      NZ, LOC_953F                    ; JP NZ LOC_953F: mismatch → set carry (not found)
    INC     IX
    JP      PE, LOC_9530
    AND     A                               ; AND A: match — clear carry (found)
    RET     

LOC_953F:                                   ; LOC_953F: SCF: set carry (no match)
    SCF     
    RET     

SUB_9541:                                   ; SUB_9541: update score entry and decrement BCD lives count
    CALL    SUB_9574                        ; CALL SUB_9574: check $71A1 against $71B9 table
    JP      NC, LOC_9573                    ; JP NC LOC_9573: no match — skip update
    LD      BC, $0001
    LD      HL, $71A1                       ; HL = $71A1: lives BCD counter
    LD      DE, $71B9                       ; DE = $71B9: target lives table
    LDIR                                    ; LDIR: copy 1 byte ($71A1 → $71B9)
    LD      A, ($71A1)                      ; Load $71A1 — current lives
    PUSH    AF
    CP      $00
    JP      Z, LOC_9561                     ; JP Z LOC_9561: zero lives → display "00"
    SUB     $01                             ; SUB $01, DAA: decrement BCD lives count
    DAA     
    LD      ($71A1), A                      ; $71A1 = new BCD lives

LOC_9561:                                   ; LOC_9561: H = $05, A = $02: digit display parameters
    LD      H, $05
    LD      A, $02
    LD      B, $1C
    LD      C, $0D                          ; B = $1C, C = $0D: screen position (row 28, col 13)
    LD      DE, $71A1                       ; DE = $71A1: lives BCD pointer
    CALL    SOUND_WRITE_9403                ; CALL SOUND_WRITE_9403: draw BCD digit at screen position
    POP     AF
    LD      ($71A1), A                  ; RAM $71A1

LOC_9573:
    RET     

SUB_9574:                                   ; SUB_9574: match $71A1 against $71B9 table (CPI loop); carry set if no match
    LD      HL, $71A1                       ; HL = $71A1: current lives counter
    LD      IX, $71B9                       ; IX = $71B9: milestone lives table
    LD      BC, $0001                       ; BC = $0001: one byte at a time

LOC_957E:                                   ; LOC_957E: CPI comparison loop
    LD      A, (IX+0)
    CPI     
    JP      NZ, LOC_958D
    INC     IX
    JP      PE, LOC_957E
    AND     A
    RET     

LOC_958D:
    SCF     
    RET     

SOUND_WRITE_958F:                           ; SOUND_WRITE_958F: reset game stats — $71B3/$71B6/$71B8/$71B9=$FF; draw score
    LD      A, $FF                          ; A = $FF: end-of-table sentinel
    LD      ($71B3), A                      ; $71B3 = $FF: score milestone table sentinel
    LD      ($71B6), A                      ; $71B6 = $FF
    LD      ($71B8), A                      ; $71B8 = $FF: level-clear milestone sentinel
    LD      ($71B9), A                      ; $71B9 = $FF: lives milestone sentinel
    LD      A, $00                          ; A = $00: row 0
    LD      B, $0D                          ; B = $0D, C = $0D: screen row 13, col 13
    LD      C, $0D                          ; D = $02: BCD digit count
    LD      D, $02
    CALL    SUB_934C                        ; CALL SUB_934C: draw initial score "00" display
    RET     

SOUND_WRITE_95A9:                           ; SOUND_WRITE_95A9: per-frame logic — read controller, update entity states
    LD      A, $00                          ; A = $00: clear $7033 (enable music)
    LD      ($7033), A                      ; $7033 = 0
    CALL    SOUND_WRITE_83C5                ; CALL SOUND_WRITE_83C5: disable NMI music lock

LOC_95B1:                                   ; LOC_95B1: frame tick — load $7198 (game-over pending flag)
    LD      A, ($7198)                      ; Load $7198 — game-over flag ($FF = game over)
    CP      $FF                             ; CP $FF: check for game-over
    JP      Z, LOC_95EF                     ; JP Z LOC_95EF: game over path
    CALL    SUB_9880                        ; CALL SUB_9880: read controller; update player movement variables
    CALL    SOUND_WRITE_99B8                ; CALL SOUND_WRITE_99B8: update collectible object positions
    CALL    SUB_BA18                        ; CALL SUB_BA18: update guard pathfinding / collision detection
    CALL    SUB_945F                        ; CALL SUB_945F: update all collectible/jewel objects
    LD      A, (JOYSTICK_BUFFER)        ; JOYSTICK_BUFFER

LOC_95C8:
    LD      A, $00
    LD      ($9610), A
    LD      A, ($9610)
    CP      $FF
    JP      NZ, LOC_95C8
    LD      A, ($71A6)                  ; RAM $71A6
    CP      $FF
    JP      NZ, LOC_95EC
    LD      A, $00
    CALL    SOUND_WRITE_8CAA
    CP      $FF
    JP      Z, LOC_95EC
    LD      A, $FF
    LD      ($719B), A                  ; RAM $719B

LOC_95EC:
    JP      LOC_95B1

LOC_95EF:
    CALL    SOUND_WRITE_83AC
    LD      A, $FF
    LD      ($7033), A                  ; RAM $7033
    LD      A, $FF
    LD      DE, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER
    CALL    SOUND_WRITE_9B73
    LD      A, $FF
    LD      DE, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER
    CALL    SOUND_WRITE_9BA1
    LD      A, $FF
    LD      DE, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER
    CALL    SOUND_WRITE_9BCF
    RET     
    DB      $FF

SOUND_WRITE_9611:
    LD      A, ($7248)                  ; RAM $7248
    CP      $FF
    JP      Z, LOC_964D
    CALL    SUB_856C
    CALL    SOUND_WRITE_988F
    CALL    SOUND_WRITE_B289
    CALL    SUB_C2CA
    CALL    SOUND_WRITE_C931
    LD      A, ($7031)                  ; RAM $7031
    AND     $01
    JP      Z, LOC_9640
    CALL    SOUND_WRITE_9907
    CALL    SOUND_WRITE_D1B8
    CALL    SUB_C628
    CALL    SUB_BDAC
    CALL    SOUND_WRITE_9C31
    RET     

LOC_9640:
    CALL    SUB_9A5A
    CALL    SUB_C5F2
    CALL    SOUND_WRITE_CE68
    CALL    SUB_D4CF
    RET     

LOC_964D:
    CALL    SUB_DDFD
    RET     

SOUND_WRITE_9651:                           ; SOUND_WRITE_9651: title-screen sequence — show attract, wait for start button
    LD      A, $FF                          ; A = $FF: suppress game display
    LD      ($71A6), A                      ; $71A6 = $FF: title-screen active flag (suppresses game frame calls)
    LD      ($702C), A                      ; $702C = $FF: disable sound engine
    LD      A, $00
    CALL    SUB_8CD2                        ; CALL SUB_8CD2: draw title screen tiles and text

LOC_965E:                                   ; LOC_965E: wait loop — poll controllers
    CALL    SOUND_WRITE_9683                ; CALL SOUND_WRITE_9683: render title screen sprites + draw title text
    JP      C, LOC_966D                     ; JP C LOC_966D: carry set = start button pressed
    CALL    SOUND_WRITE_9794                ; CALL SOUND_WRITE_9794: check for start button
    JP      C, LOC_966D                     ; JP C LOC_966D: carry = start pressed
    JP      LOC_965E                        ; JP LOC_965E: no press — keep waiting

LOC_966D:                                   ; LOC_966D: start pressed — clean up and return to game
    LD      A, $FF
    CALL    SOUND_WRITE_8E03                ; CALL SOUND_WRITE_8E03: clear layer-A bit
    CALL    SUB_9042                        ; CALL SUB_9042: blank all sprites
    LD      A, $00
    CALL    SOUND_WRITE_8E03
    LD      A, $00
    LD      ($71A6), A                      ; $71A6 = 0: clear title-screen suppress flag
    LD      ($702C), A                      ; $702C = 0: re-enable sound engine
    RET     

SOUND_WRITE_9683:                           ; SOUND_WRITE_9683: title screen render — draw title tiles, guard sprites, text
    CALL    SUB_84BC                        ; CALL SUB_84BC: init sprite attribute table
    LD      A, $FF
    CALL    SOUND_WRITE_8E03
    CALL    SUB_9042                        ; CALL SUB_9042: clear all sprite slots
    CALL    SUB_A259                        ; CALL SUB_A259: draw title-screen logo tiles to VRAM
    LD      B, $0C                          ; B = $0C, C = $28: "THE HEIST" title position
    LD      C, $28
    LD      D, $07                          ; D = $07: string length
    LD      HL, $9ECD                       ; HL = $9ECD: tile data source for title string
    LD      IY, $9728                       ; IY = $9728: string character table
    CALL    SUB_9EAC                        ; CALL SUB_9EAC: draw title string to name table
    LD      B, $0A
    LD      C, $4E
    LD      D, $05
    LD      HL, $9ECD
    LD      IY, $978A
    CALL    SUB_9EAC
    LD      B, $10
    LD      C, $4E
    LD      D, $05
    LD      HL, $9ECD
    LD      IY, $978E
    CALL    SUB_9EAC
    LD      B, $05
    LD      C, $74
    LD      D, $02
    LD      HL, $9ECD
    LD      IY, $9730
    CALL    SUB_9EAC
    LD      B, $09
    LD      C, $80
    LD      D, $02
    LD      HL, $9ECD
    LD      IY, $9748
    CALL    SUB_9EAC
    LD      B, $06
    LD      C, $A8
    LD      D, $0A
    LD      HL, $9ECD
    LD      IY, $9757
    CALL    SUB_9EAC
    LD      B, $02
    LD      C, $B4
    LD      D, $0A
    LD      HL, $9ECD
    LD      IY, $976D
    CALL    SUB_9EAC
    LD      A, $00
    CALL    SOUND_WRITE_8E03
    LD      BC, $0200

LOC_9709:
    PUSH    BC
    LD      HL, $000A
    CALL    SUB_97E8
    CALL    SUB_A28C
    LD      A, $00
    CALL    SOUND_WRITE_8CAA
    POP     BC
    CP      $FF
    JP      NZ, LOC_9726
    DEC     BC
    LD      A, B
    OR      C
    JP      NZ, LOC_9709
    AND     A
    RET     

LOC_9726:
    SCF     
    RET     
    DB      $50, $52, $45, $53, $45, $4E, $54, $D3
    DB      $50, $52, $4F, $47, $52, $41, $4D, $20 ; "PROGRAM "
    DB      $41, $4E, $44, $20, $47, $41, $4D, $45 ; "AND GAME"
    DB      $20, $43, $4F, $4E, $43, $45, $50, $D4
    DB      $42, $59, $20, $4D, $49, $4B, $45, $20 ; "BY MIKE "
    DB      $4C, $49, $56, $45, $53, $41, $D9, $20
    DB      $20, $20, $20, $43, $4F, $50, $59, $52 ; "   COPYR"
    DB      $49, $47, $48, $54, $20, $31, $39, $38 ; "IGHT 198"
    DB      $33, $20, $20, $20, $A0, $42, $59, $20
    DB      $4C, $49, $56, $45, $53, $41, $59, $20 ; "LIVESAY "
    DB      $43, $4F, $4D, $50, $55, $54, $45, $52 ; "COMPUTER"
    DB      $20, $47, $41, $4D, $45, $53, $2C, $49 ; " GAMES,I"
    DB      $4E, $C3, $22, $54, $48, $C5, $48, $45
    DB      $49, $53, $54, $A2

SOUND_WRITE_9794:
    CALL    SUB_8238
    CALL    SOUND_WRITE_825A
    LD      C, $0A

LOC_979C:
    PUSH    BC
    CALL    SOUND_WRITE_82D2
    CALL    SOUND_WRITE_95A9
    POP     BC
    LD      A, ($7199)                  ; RAM $7199
    CP      $FF
    JP      NZ, LOC_97B2
    DEC     C
    JP      NZ, LOC_979C
    AND     A
    RET     

LOC_97B2:
    SCF     
    RET     

SUB_97B4:
    CALL    SOUND_WRITE_958F
    CALL    SUB_945F
    LD      B, $0C
    LD      C, $5C
    LD      D, $0A
    LD      HL, $9ECD
    LD      IY, $97DF
    CALL    SUB_9EAC
    LD      A, $14
    LD      HL, $D6A5
    CALL    SUB_D5E3

LOC_97D2:
    CALL    SUB_D4CF
    JP      NC, LOC_97D2
    LD      HL, $0578
    CALL    SUB_97E8
    RET     
    DB      $47, $41, $4D, $45, $20, $4F, $56, $45 ; "GAME OVE"
    DB      $D2

SUB_97E8:
    LD      BC, $0001

LOC_97EB:
    CALL    SUB_97F6
    AND     $00
    SBC     HL, BC
    JP      NZ, LOC_97EB
    RET     

SUB_97F6:
    LD      DE, $0096

LOC_97F9:
    DEC     DE
    LD      A, E
    CP      $00
    JP      NZ, LOC_97F9
    LD      A, D
    CP      $00
    JP      NZ, LOC_97F9
    RET     

SUB_9807:
    LD      C, A
    LD      B, $00
    ADD     IX, BC
    ADD     IY, BC
    RET     

SUB_980F:
    PUSH    BC
    LD      B, $00
    SLA     C
    RL      B
    ADD     HL, BC
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    PUSH    DE
    POP     IX
    PUSH    DE
    POP     IY
    POP     BC
    RET     

SUB_9822:
    CALL    SUB_980F
    LD      A, (IX+0)
    INC     IX
    INC     IY
    RET     
    DB      $06, $00, $DD, $21, $3B, $98, $DD, $09
    DB      $7E, $DD, $B6, $00, $77, $C9, $01, $02
    DB      $04, $08, $10, $20, $40, $80, $06, $00
    DB      $DD, $21, $3B, $98, $DD, $09, $DD, $7E
    DB      $00, $EE, $FF, $A6, $77, $C9, $06, $00
    DB      $DD, $21, $3B, $98, $DD, $09, $7E, $DD
    DB      $A6, $00, $CA, $65, $98, $3E, $FF, $C9
    DB      $3E, $00, $C9, $58, $16, $00, $19, $A7
    DB      $CA, $74, $98, $CD, $2D, $98, $C9, $CD
    DB      $43, $98, $C9, $58, $16, $00, $19, $CD
    DB      $53, $98, $C9

SUB_9880:
    LD      HL, ($71BA)                 ; RAM $71BA
    INC     HL
    LD      ($71BA), HL                 ; RAM $71BA
    RET     

SUB_9888:
    LD      HL, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER
    LD      ($71BA), HL                 ; RAM $71BA
    RET     

SOUND_WRITE_988F:
    LD      A, ($71A6)                  ; RAM $71A6
    CP      $FF
    JP      NZ, LOC_98B1
    LD      A, $FF
    LD      ($71C0), A                  ; RAM $71C0
    LD      ($71BE), A                  ; RAM $71BE
    LD      A, $00
    LD      ($71BC), A                  ; RAM $71BC
    LD      ($71BD), A                  ; RAM $71BD
    LD      ($71C1), A                  ; RAM $71C1
    LD      ($71BF), A                  ; RAM $71BF
    LD      ($71C2), A                  ; RAM $71C2
    RET     

LOC_98B1:
    LD      A, $00
    CALL    SUB_8BC9
    LD      IX, $7157                   ; RAM $7157
    LD      A, $FF
    LD      ($71BC), A                  ; RAM $71BC
    LD      ($71BD), A                  ; RAM $71BD
    LD      A, (IX+4)
    LD      B, A
    LD      ($71C0), A                  ; RAM $71C0
    LD      A, (IX+5)
    LD      ($71C1), A                  ; RAM $71C1
    OR      B
    CPL     
    LD      ($71BC), A                  ; RAM $71BC
    LD      A, (IX+6)
    LD      ($71BE), A                  ; RAM $71BE
    LD      B, A
    LD      A, (IX+7)
    LD      ($71BF), A                  ; RAM $71BF
    OR      B
    CPL     
    LD      ($71BD), A                  ; RAM $71BD
    LD      A, (IX+0)
    OR      (IX+1)
    LD      (IX+0), A
    PUSH    IX
    POP     HL
    LD      BC, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER
    ADD     HL, BC
    LD      DE, $71C3                   ; RAM $71C3
    PUSH    IX
    CALL    SUB_8C84
    POP     IX
    LD      A, (IX+0)
    LD      ($71C2), A                  ; RAM $71C2
    RET     

SOUND_WRITE_9907:
    LD      A, ($71A6)                  ; RAM $71A6
    CP      $FF
    JP      NZ, LOC_9910
    RET     

LOC_9910:
    LD      A, $00
    CALL    SOUND_WRITE_8CAA
    CP      $FF
    JP      Z, LOC_9937
    LD      C, $04
    LD      IY, $9940
    LD      DE, $9944

LOC_9923:
    LD      B, A
    LD      A, (DE)
    LD      L, A
    INC     DE
    LD      A, (DE)
    LD      H, A
    INC     DE
    LD      A, B
    CP      (IY+0)
    JP      Z, LOC_9938
    INC     IY
    DEC     C
    JP      NZ, LOC_9923

LOC_9937:
    RET     

LOC_9938:
    PUSH    HL
    LD      A, $00
    CALL    SUB_8CD2
    POP     HL
    JP      (HL)
    DB      $0A, $00, $0B, $08, $4C, $99, $5E, $99
    DB      $64, $99, $85, $99, $CD, $AA, $80, $3E
    DB      $01, $06, $03, $CD, $90, $80, $3A, $2C
    DB      $70, $2F, $32, $2C, $70, $C9, $3E, $FF
    DB      $32, $9C, $71, $C9, $CD, $AA, $80, $3E
    DB      $01, $06, $03, $CD, $90, $80, $3E, $00
    DB      $CD, $AA, $8C, $FE, $FF, $CA, $64, $99
    DB      $F5, $3E, $00, $CD, $D2, $8C, $F1, $FE
    DB      $0B, $C2, $64, $99, $C9, $3A, $3E, $72
    DB      $2F, $32, $3E, $72, $C9

SOUND_WRITE_998D:
    LD      A, $00
    LD      ($71C3), A                  ; RAM $71C3
    LD      ($71C4), A                  ; RAM $71C4
    LD      A, $00
    LD      ($71BE), A                  ; RAM $71BE
    LD      ($71BF), A                  ; RAM $71BF
    LD      ($71C0), A                  ; RAM $71C0
    LD      ($71C1), A                  ; RAM $71C1
    LD      A, $FF
    LD      ($71BC), A                  ; RAM $71BC
    LD      ($71BD), A                  ; RAM $71BD
    LD      IX, $7157                   ; RAM $7157
    LD      A, $00
    LD      (IX+3), A
    LD      (IX+8), A
    RET     

SOUND_WRITE_99B8:
    CALL    SUB_9A00
    LD      A, ($719B)                  ; RAM $719B
    CP      $FF
    JP      Z, LOC_99EA
    LD      A, ($719C)                  ; RAM $719C
    CP      $FF
    JP      Z, LOC_99E5
    LD      A, ($7199)                  ; RAM $7199
    CP      $FF
    JP      Z, LOC_99E5
    LD      A, ($71A2)                  ; RAM $71A2
    AND     A
    JP      Z, LOC_99E5
    LD      A, ($71F2)                  ; RAM $71F2
    CP      $FF
    JP      Z, LOC_99E5
    JP      LOC_99FF

LOC_99E5:
    LD      A, $FF
    LD      ($719B), A                  ; RAM $719B

LOC_99EA:
    LD      A, ($71C6)                  ; RAM $71C6
    CP      $FF
    JP      NZ, LOC_99FF
    LD      A, ($71F4)                  ; RAM $71F4
    CP      $FF
    JP      NZ, LOC_99FF
    LD      A, $FF
    LD      ($7198), A                  ; RAM $7198

LOC_99FF:
    RET     

SUB_9A00:
    LD      A, ($71A0)                  ; RAM $71A0
    CP      $03
    JP      Z, LOC_9A4D
    SLA     A
    SLA     A
    LD      C, A
    LD      B, $00
    LD      IX, $9A4E
    ADD     IX, BC
    LD      A, ($719F)                  ; RAM $719F
    CP      (IX+2)
    JP      C, LOC_9A4D
    JP      NZ, LOC_9A36
    LD      A, ($719E)                  ; RAM $719E
    CP      (IX+1)
    JP      C, LOC_9A4D
    JP      NZ, LOC_9A36
    LD      A, ($719D)                  ; RAM $719D
    CP      (IX+0)
    JP      C, LOC_9A4D

LOC_9A36:
    LD      HL, $71A0                   ; RAM $71A0
    INC     (HL)
    LD      A, ($71A1)                  ; RAM $71A1
    ADD     A, $01
    DAA     
    CP      $00
    JP      Z, LOC_9A4D
    LD      ($71A1), A                  ; RAM $71A1
    LD      A, $01
    CALL    SUB_9CAD

LOC_9A4D:
    RET     
    DB      $00, $00, $02, $00, $00, $00, $04, $00
    DB      $00, $00, $06, $00

SUB_9A5A:
    CALL    SUB_94BD
    LD      A, ($71A5)                  ; RAM $71A5
    CP      $00
    JP      NZ, LOC_9A6E
    LD      A, ($71A4)                  ; RAM $71A4
    CP      $00
    JP      NZ, LOC_9A6E
    RET     

LOC_9A6E:
    LD      HL, $71C5                   ; RAM $71C5
    DEC     (HL)
    JP      NZ, LOC_9AAE
    LD      A, $1E
    LD      (HL), A
    LD      A, $04
    CALL    SUB_9CAD
    LD      A, ($71A4)                  ; RAM $71A4
    SUB     $01
    DAA     
    CP      $99
    JP      NZ, LOC_9A93
    LD      A, ($71A5)                  ; RAM $71A5
    SUB     $01
    DAA     
    LD      ($71A5), A                  ; RAM $71A5
    LD      A, $59

LOC_9A93:
    LD      ($71A4), A                  ; RAM $71A4
    AND     A
    JP      NZ, LOC_9AAE
    LD      A, ($71A5)                  ; RAM $71A5
    AND     A
    JP      NZ, LOC_9AAE
    LD      A, ($71A6)                  ; RAM $71A6
    CP      $FF
    JP      Z, LOC_9AAE
    LD      A, $FF
    LD      ($71F2), A                  ; RAM $71F2

LOC_9AAE:
    RET     

SUB_9AAF:
    LD      A, ($7196)                  ; RAM $7196
    SLA     A
    LD      C, A
    LD      B, $00
    LD      IX, $9ACF
    ADD     IX, BC
    LD      A, (IX+1)
    LD      ($71A5), A                  ; RAM $71A5
    LD      A, (IX+0)
    LD      ($71A4), A                  ; RAM $71A4
    LD      A, $1E
    LD      ($71C5), A                  ; RAM $71C5
    RET     
    DB      $00, $02, $30, $01, $00, $01, $DD, $46
    DB      $07, $FD, $4E, $07, $DD, $7E, $09, $FE
    DB      $FF, $C2, $EC, $9A, $78, $FE, $21, $DA
    DB      $1A, $9B, $D6, $20, $47, $FD, $7E, $09
    DB      $FE, $FF, $C2, $FD, $9A, $79, $FE, $21
    DB      $DA, $1A, $9B, $D6, $20, $4F, $CD, $1E
    DB      $9B, $DA, $19, $9B, $DD, $E5, $FD, $E5
    DB      $DD, $E5, $FD, $E5, $DD, $E1, $FD, $E1
    DB      $78, $41, $4F, $CD, $1E, $9B, $FD, $E1
    DB      $DD, $E1, $C9, $A7, $C3, $19, $9B, $FD
    DB      $7E, $08, $DD, $BE, $08, $DA, $33, $9B
    DB      $DD, $7E, $08, $DD, $86, $0F, $FD, $BE
    DB      $08, $D2, $4A, $9B, $FD, $7E, $08, $FD
    DB      $86, $0F, $DD, $BE, $08, $DA, $6F, $9B
    DB      $57, $DD, $7E, $08, $DD, $86, $0F, $BA
    DB      $DA, $6F, $9B, $79, $B8, $DA, $57, $9B
    DB      $78, $DD, $86, $0E, $B9, $D2, $6D, $9B
    DB      $79, $FD, $86, $0E, $B8, $DA, $6F, $9B
    DB      $78, $DD, $86, $0E, $FD, $96, $0E, $DA
    DB      $6F, $9B, $B9, $DA, $6F, $9B, $37, $C9
    DB      $37, $3F, $C9, $C9

SOUND_WRITE_9B73:
    LD      H, A
    INC     H
    LD      A, ($71C7)                  ; RAM $71C7
    CP      H
    JP      C, LOC_9BA0
    LD      A, H
    LD      ($71C7), A                  ; RAM $71C7
    LD      A, D
    CP      $00
    JP      NZ, LOC_9B8B
    LD      A, $FF
    LD      ($71C7), A                  ; RAM $71C7

LOC_9B8B:
    PUSH    IX
    PUSH    IY
    PUSH    DE
    LD      A, $00
    CALL    SUB_8024
    POP     DE
    LD      A, D
    LD      B, $00
    CALL    SOUND_WRITE_8066
    POP     IY
    POP     IX

LOC_9BA0:
    RET     

SOUND_WRITE_9BA1:
    LD      H, A
    INC     H
    LD      A, ($71C8)                  ; RAM $71C8
    CP      H
    JP      C, LOC_9BCE
    LD      A, H
    LD      ($71C8), A                  ; RAM $71C8
    LD      A, D
    CP      $00
    JP      NZ, LOC_9BB9
    LD      A, $FF
    LD      ($71C8), A                  ; RAM $71C8

LOC_9BB9:
    PUSH    IX
    PUSH    IY
    PUSH    DE
    LD      A, $01
    CALL    SUB_8024
    POP     DE
    LD      A, D
    LD      B, $01
    CALL    SOUND_WRITE_8066
    POP     IY
    POP     IX

LOC_9BCE:
    RET     

SOUND_WRITE_9BCF:
    LD      H, A
    INC     H
    LD      A, ($71C9)                  ; RAM $71C9
    CP      H
    JP      C, LOC_9C05
    LD      A, H
    LD      ($71C9), A                  ; RAM $71C9
    LD      A, D
    OR      E
    CP      $00
    JP      NZ, LOC_9BE8
    LD      A, $FF
    LD      ($71C9), A                  ; RAM $71C9

LOC_9BE8:
    PUSH    IX
    PUSH    IY
    PUSH    DE
    LD      A, $02
    CALL    SUB_8024
    POP     DE
    PUSH    DE
    LD      A, D
    LD      B, $02
    CALL    SOUND_WRITE_8066
    POP     DE
    LD      A, E
    LD      B, $03
    CALL    SOUND_WRITE_8066
    POP     IY
    POP     IX

LOC_9C05:
    RET     

SOUND_WRITE_9C06:
    LD      A, $FF
    LD      ($71C7), A                  ; RAM $71C7
    LD      ($71C8), A                  ; RAM $71C8
    LD      ($71C9), A                  ; RAM $71C9
    LD      IX, $71CA                   ; RAM $71CA
    LD      A, ($9CCF)
    LD      B, A
    LD      A, $00

LOC_9C1B:
    LD      (IX+0), A
    INC     IX
    DEC     B
    JP      NZ, LOC_9C1B
    LD      A, $00
    LD      ($71C6), A                  ; RAM $71C6
    LD      A, $01
    LD      B, $03
    CALL    SUB_8090
    RET     

SOUND_WRITE_9C31:
    LD      A, ($71C6)                  ; RAM $71C6
    CP      $FF
    JP      Z, LOC_9C86
    LD      A, ($719B)                  ; RAM $719B
    CP      $FF
    JP      NZ, LOC_9C5C
    LD      IX, $71CA                   ; RAM $71CA
    LD      A, ($9CCF)
    LD      B, A

LOC_9C49:
    LD      A, (IX+0)
    AND     $01
    JP      NZ, LOC_9C5C
    INC     IX
    DEC     B
    JP      NZ, LOC_9C49
    LD      A, $FF
    LD      ($71C6), A                  ; RAM $71C6

LOC_9C5C:
    LD      A, ($9CCF)
    LD      C, A
    LD      B, $00
    LD      IX, $71CA                   ; RAM $71CA

LOC_9C66:
    PUSH    BC
    PUSH    IX
    CALL    SOUND_WRITE_9C87
    POP     IX
    POP     BC
    JP      NC, LOC_9C77
    LD      A, $00
    LD      (IX+0), A

LOC_9C77:
    LD      A, (IX+0)
    AND     $7F
    LD      (IX+0), A
    INC     IX
    INC     B
    DEC     C
    JP      NZ, LOC_9C66

LOC_9C86:
    RET     

SOUND_WRITE_9C87:
    LD      A, (IX+0)
    AND     $01
    JP      Z, LOC_9CAB
    LD      E, B
    SLA     E
    LD      D, $00
    LD      HL, $9CC7
    ADD     HL, DE
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    PUSH    DE
    POP     HL
    LD      C, $FF
    LD      A, (IX+0)
    AND     $80
    JP      NZ, LOC_9CA9
    LD      C, $00

LOC_9CA9:
    LD      A, C
    JP      (HL)

LOC_9CAB:
    SCF     
    RET     

SUB_9CAD:
    PUSH    IX
    PUSH    IY
    LD      C, A
    LD      B, $00
    LD      IX, $71CA                   ; RAM $71CA
    ADD     IX, BC
    LD      A, (IX+0)
    OR      $81
    LD      (IX+0), A
    POP     IY
    POP     IX
    RET     
    DB      $D0, $9C, $84, $9D, $D2, $9D, $22, $9E
    DB      $04, $FE, $FF, $C2, $E0, $9C, $3E, $00
    DB      $32, $D1, $71, $21, $F0, $03, $22, $CE
    DB      $71, $78, $32, $D0, $71, $3A, $D1, $71
    DB      $CB, $27, $4F, $06, $00, $21, $80, $9D
    DB      $09, $4E, $23, $46, $C5, $E1, $E9, $3A
    DB      $D0, $71, $ED, $4B, $CE, $71, $16, $0D
    DB      $CD, $73, $9B, $ED, $4B, $CE, $71, $0B
    DB      $0B, $16, $0D, $3A, $D0, $71, $CD, $A1
    DB      $9B, $2A, $CE, $71, $01, $B5, $FF, $09
    DB      $22, $CE, $71, $7C, $FE, $02, $D2, $29
    DB      $9D, $7D, $FE, $F0, $D2, $29, $9D, $C3
    DB      $2B, $9D, $A7, $C9, $3E, $01, $32, $D1
    DB      $71, $01, $F0, $00, $ED, $43, $CE, $71
    DB      $A7, $C9, $3A, $D0, $71, $ED, $4B, $CE
    DB      $71, $16, $0D, $CD, $73, $9B, $ED, $4B
    DB      $CE, $71, $0B, $0B, $16, $0D, $3A, $D0
    DB      $71, $CD, $A1, $9B, $2A, $CE, $71, $01
    DB      $D8, $FF, $09, $22, $CE, $71, $7C, $FE
    DB      $01, $D2, $6C, $9D, $7D, $FE, $70, $D2
    DB      $6C, $9D, $C3, $6E, $9D, $A7, $C9, $16
    DB      $00, $3A, $D0, $71, $CD, $73, $9B, $16
    DB      $00, $3A, $D0, $71, $CD, $A1, $9B, $37
    DB      $C9, $F6, $9C, $39, $9D, $FE, $FF, $C2
    DB      $8E, $9D, $3E, $1C, $32, $D2, $71, $78
    DB      $F5, $01, $40, $00, $3A, $31, $70, $E6
    DB      $02, $C2, $9F, $9D, $21, $D2, $71, $35
    DB      $2E, $00, $16, $00, $3A, $D2, $71, $E6
    DB      $01, $CA, $BB, $9D, $2E, $0F, $3A, $31
    DB      $70, $CB, $3F, $EE, $FF, $E6, $03, $CB
    DB      $27, $CB, $27, $57, $C5, $D5, $7D, $CD
    DB      $15, $8F, $D1, $C1, $F1, $CD, $73, $9B
    DB      $3A, $D2, $71, $A7, $C2, $D0, $9D, $37
    DB      $C9, $A7, $C9, $FE, $FF, $C2, $DD, $9D
    DB      $21, $01, $00, $22, $D3, $71, $78, $F5
    DB      $ED, $4B, $D3, $71, $16, $0D, $CD, $73
    DB      $9B, $ED, $4B, $D3, $71, $CB, $21, $CB
    DB      $10, $0B, $0B, $16, $0D, $F1, $F5, $CD
    DB      $A1, $9B, $2A, $D3, $71, $01, $23, $00
    DB      $09, $22, $D3, $71, $F1, $47, $7D, $FE
    DB      $E0, $DA, $20, $9E, $7C, $FE, $01, $DA
    DB      $20, $9E, $78, $16, $00, $F5, $CD, $73
    DB      $9B, $F1, $16, $00, $CD, $A1, $9B, $37
    DB      $C9, $A7, $C9, $FE, $FF, $C2, $2C, $9E
    DB      $3E, $10, $32, $D5, $71, $3A, $31, $70
    DB      $E6, $02, $C2, $41, $9E, $3A, $D5, $71
    DB      $D6, $04, $D2, $3E, $9E, $3E, $00, $32
    DB      $D5, $71, $78, $F5, $01, $20, $00, $3A
    DB      $D5, $71, $57, $F1, $CD, $73, $9B, $3A
    DB      $D5, $71, $FE, $00, $C2, $58, $9E, $37
    DB      $C9, $A7, $C9

SUB_9E5A:
    PUSH    BC
    SUB     $20
    LD      C, A
    LD      B, $00
    SLA     C
    RL      B
    SLA     C
    RL      B
    SLA     C
    RL      B
    ADD     HL, BC
    SLA     D
    SLA     D
    SLA     D
    SLA     D
    LD      IX, $71D6                   ; RAM $71D6
    LD      IY, $71E0                   ; RAM $71E0
    LD      B, $08

LOC_9E7F:
    LD      A, (HL)
    LD      (IX+2), A
    LD      (IY+2), D
    INC     HL
    INC     IX
    INC     IY
    DEC     B
    JP      NZ, LOC_9E7F
    LD      A, $01
    LD      ($71D6), A                  ; RAM $71D6
    LD      ($71E0), A                  ; RAM $71E0
    LD      A, $08
    LD      ($71D7), A                  ; RAM $71D7
    LD      ($71E1), A                  ; RAM $71E1
    LD      A, $01
    POP     BC
    LD      DE, $71E0                   ; RAM $71E0
    LD      HL, $71D6                   ; RAM $71D6
    CALL    SUB_8F49
    RET     

SUB_9EAC:
    LD      A, (IY+0)
    AND     $7F
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IY
    CALL    SUB_9E5A
    POP     IY
    POP     HL
    POP     DE
    POP     BC
    INC     B
    LD      A, (IY+0)
    AND     $80
    JP      NZ, LOC_9ECC
    INC     IY
    JP      SUB_9EAC

LOC_9ECC:
    RET     
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $30, $30, $30, $30, $30, $00, $30, $00
    DB      $6C, $6C, $6C, $00, $00, $00, $00, $00
    DB      $6C, $6C, $FE, $6C, $FE, $6C, $6C, $00
    DB      $10, $7C, $D0, $7C, $16, $FC, $10, $00
    DB      $C0, $C8, $10, $20, $40, $98, $18, $00
    DB      $40, $A0, $A0, $40, $A8, $90, $68, $00
    DB      $30, $30, $30, $00, $00, $00, $00, $00
    DB      $20, $40, $80, $80, $80, $40, $20, $00
    DB      $20, $10, $08, $08, $08, $10, $20, $00
    DB      $20, $A8, $70, $20, $70, $A8, $20, $00
    DB      $00, $30, $30, $FC, $FC, $30, $30, $00
    DB      $00, $00, $00, $00, $30, $30, $C0, $00
    DB      $00, $00, $00, $FC, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $30, $30, $00
    DB      $00, $08, $10, $20, $40, $80, $00, $00
    DB      $78, $CC, $CC, $CC, $CC, $CC, $78, $00
    DB      $30, $70, $70, $30, $30, $30, $78, $00
    DB      $78, $FC, $8C, $38, $70, $C0, $FC, $00
    DB      $F8, $0C, $0C, $78, $0C, $0C, $F8, $00
    DB      $CC, $CC, $CC, $FE, $0C, $0C, $0C, $00
    DB      $FC, $C0, $C0, $F8, $0C, $0C, $F8, $00
    DB      $7C, $C0, $C0, $F8, $CC, $CC, $78, $00
    DB      $FC, $0C, $18, $30, $30, $30, $30, $00
    DB      $78, $CC, $CC, $78, $CC, $CC, $78, $00
    DB      $78, $CC, $CC, $7C, $0C, $18, $30, $00
    DB      $00, $00, $30, $00, $30, $00, $00, $00
    DB      $00, $00, $30, $00, $30, $30, $C0, $00
    DB      $10, $20, $40, $80, $40, $20, $10, $00
    DB      $00, $00, $FC, $00, $FC, $00, $00, $00
    DB      $40, $20, $10, $08, $10, $20, $40, $00
    DB      $70, $88, $10, $20, $20, $00, $20, $00
    DB      $70, $88, $A8, $B8, $B0, $80, $78, $00
    DB      $78, $FC, $CC, $FC, $CC, $CC, $CC, $00
    DB      $F8, $CC, $CC, $F8, $CC, $CC, $F8, $00
    DB      $78, $CC, $C0, $C0, $C0, $CC, $78, $00
    DB      $F8, $CC, $CC, $CC, $CC, $CC, $F8, $00
    DB      $FC, $C0, $C0, $F8, $C0, $C0, $FC, $00
    DB      $FC, $C0, $C0, $F8, $C0, $C0, $C0, $00
    DB      $7C, $C0, $C0, $C0, $DC, $CC, $7C, $00
    DB      $CC, $CC, $CC, $FC, $CC, $CC, $CC, $00
    DB      $78, $30, $30, $30, $30, $30, $78, $00
    DB      $0C, $0C, $0C, $0C, $0C, $CC, $78, $00
    DB      $CC, $CC, $D8, $F0, $D8, $CC, $CC, $00
    DB      $C0, $C0, $C0, $C0, $C0, $FC, $FC, $00
    DB      $CC, $CC, $FC, $CC, $CC, $CC, $CC, $00
    DB      $CC, $CC, $EC, $FC, $DC, $CC, $CC, $00
    DB      $78, $CC, $CC, $CC, $CC, $CC, $78, $00
    DB      $F8, $CC, $CC, $F8, $C0, $C0, $C0, $00
    DB      $78, $CC, $CC, $CC, $CC, $DC, $7C, $00
    DB      $F8, $CC, $CC, $F8, $CC, $C6, $C6, $00
    DB      $78, $CC, $C0, $78, $0C, $CC, $78, $00
    DB      $FC, $FC, $30, $30, $30, $30, $30, $00
    DB      $CC, $CC, $CC, $CC, $CC, $CC, $78, $00
    DB      $CC, $CC, $CC, $CC, $CC, $78, $30, $00
    DB      $C6, $C6, $C6, $C6, $D6, $EE, $C6, $00
    DB      $CC, $CC, $78, $30, $78, $CC, $CC, $00
    DB      $CC, $CC, $CC, $78, $30, $30, $30, $00
    DB      $FC, $0C, $18, $30, $60, $C0, $FC, $00
    DB      $0A, $0D, $00, $00, $00, $00, $00, $00
    DB      $1C, $00, $00, $00, $00, $00, $80, $00
    DB      $00, $00, $3E, $00, $00, $00, $00, $01
    DB      $C0, $00, $00, $00, $67, $00, $00, $00
    DB      $00, $00, $80, $00, $00, $00, $62, $00
    DB      $00, $75, $00, $00, $00, $00, $00, $00
    DB      $60, $00, $00, $27, $3D, $F0, $87, $C3
    DB      $C1, $F0, $7C, $42, $1F, $25, $FF, $F9
    DB      $CC, $E7, $23, $98, $70, $E7, $31, $25
    DB      $C7, $19, $CC, $47, $73, $98, $70, $E7
    DB      $33, $80, $C7, $19, $CC, $07, $63, $98
    DB      $70, $E7, $3B, $80, $E7, $39, $CC, $07
    DB      $03, $98, $70, $E3, $3B, $80, $F7, $79
    DB      $CC, $47, $03, $98, $70, $E3, $3B, $80
    DB      $F7, $79, $CC, $E7, $03, $98, $70, $F6
    DB      $3B, $80, $62, $30, $87, $C2, $01, $F0
    DB      $20, $7C, $11, $00, $0A, $0D, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $0A, $01, $80, $80, $80, $80, $80, $80
    DB      $80, $80, $80, $80, $0A, $01, $20, $20
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $0A, $01, $50, $50, $50, $50, $50, $50
    DB      $50, $50, $50, $50, $0A, $01, $A0, $A0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0
    DB      $0C, $05, $0A, $EA, $E7, $55, $3B, $BB
    DB      $9D, $4E, $EC, $EA, $EC, $A0, $0A, $4A
    DB      $84, $57, $22, $A2, $15, $C8, $AA, $8A
    DB      $8A, $A0, $0A, $4E, $E7, $57, $3A, $BB
    DB      $95, $CE, $AC, $EA, $EC, $A0, $00, $4A
    DB      $84, $55, $2A, $A0, $95, $48, $AA, $8A
    DB      $8A, $00, $00, $4A, $E4, $75, $3B, $BB
    DB      $9D, $48, $EA, $E4, $EA, $00, $0C, $05
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0

SUB_A259:
    LD      A, $01
    LD      B, $0B
    LD      C, $08
    LD      DE, $A129
    LD      HL, $A0A5
    CALL    SUB_8F49
    LD      A, $01
    LD      B, $0A
    LD      C, $19
    LD      DE, $A21B
    LD      HL, $A1DD
    CALL    SUB_8F49
    LD      A, $06
    LD      ($71EA), A                  ; RAM $71EA
    LD      A, $0A
    LD      ($71EB), A                  ; RAM $71EB
    LD      A, $0E
    LD      ($71EC), A                  ; RAM $71EC
    LD      A, $12
    LD      ($71ED), A                  ; RAM $71ED
    RET     

SUB_A28C:
    LD      HL, $71EA                   ; RAM $71EA
    LD      B, $00

LOC_A291:
    PUSH    BC
    PUSH    HL
    LD      E, B
    LD      B, $0B
    LD      C, (HL)
    LD      A, C
    CP      $15
    JP      C, LOC_A29F
    LD      C, $05

LOC_A29F:
    INC     C
    LD      (HL), C
    LD      HL, $A2BE
    LD      D, $00
    SLA     E
    ADD     HL, DE
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    PUSH    DE
    POP     HL
    LD      A, $02
    CALL    SUB_8F49
    POP     HL
    POP     BC
    INC     HL
    INC     B
    LD      A, B
    CP      $04
    JP      NZ, LOC_A291
    RET     
    DB      $AD, $A1, $B9, $A1, $C5, $A1, $D1, $A1

SUB_A2C6:
    LD      A, ($7197)                  ; RAM $7197
    LD      C, A
    LD      B, $00
    SLA     C
    ADD     HL, BC
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    PUSH    BC
    POP     HL
    PUSH    BC
    POP     IX
    RET     

SUB_A2D8:
    PUSH    BC
    CALL    SUB_A2C6
    POP     BC
    PUSH    BC
    CALL    SUB_9822
    POP     BC
    RET     
    DB      $E9, $A2, $EA, $A2, $EB, $A2, $24, $27
    DB      $2A, $F2, $A2, $06, $A3, $1A, $A3, $2E
    DB      $A3, $3B, $A3, $50, $A3, $69, $A3, $7E
    DB      $A3, $8F, $A3, $A4, $A3, $B1, $A3, $CA
    DB      $A3, $CB, $A3, $E0, $A3, $F9, $A3, $06
    DB      $A4, $13, $A4, $28, $A4, $41, $A4, $56
    DB      $A4, $67, $A4, $7C, $A4, $91, $A4, $AA
    DB      $A4, $BB, $A4, $D4, $A4, $ED, $A4, $FE
    DB      $A4, $17, $A5, $28, $A5, $3D, $A5, $56
    DB      $A5, $63, $A5, $03, $05, $00, $02, $00
    DB      $17, $00, $02, $01, $0F, $02, $00, $02
    DB      $05, $08, $00, $02, $03, $14, $00, $02
    DB      $04, $0F, $01, $00, $05, $04, $02, $03
    DB      $06, $09, $02, $03, $07, $06, $05, $00
    DB      $01, $10, $05, $01, $02, $11, $05, $02
    DB      $01, $12, $17, $00, $01, $13, $17, $01
    DB      $02, $14, $17, $02, $01, $15, $05, $07
    DB      $00, $01, $16, $15, $00, $01, $17, $07
    DB      $01, $02, $20, $02, $02, $03, $21, $1D
    DB      $02, $00, $22, $04, $06, $00, $02, $23
    DB      $16, $00, $02, $24, $06, $01, $01, $25
    DB      $16, $01, $01, $26, $05, $0E, $00, $02
    DB      $27, $06, $01, $03, $30, $17, $01, $03
    DB      $31, $06, $02, $00, $32, $19, $02, $00
    DB      $33, $03, $03, $00, $02, $34, $19, $00
    DB      $02, $35, $07, $01, $01, $36, $06, $06
    DB      $00, $02, $37, $16, $00, $02, $40, $06
    DB      $01, $03, $41, $14, $01, $01, $42, $03
    DB      $02, $03, $43, $1A, $02, $03, $44, $00
    DB      $05, $0F, $00, $00, $45, $06, $01, $02
    DB      $46, $16, $01, $02, $47, $05, $02, $03
    DB      $50, $18, $02, $03, $51, $06, $05, $00
    DB      $01, $21, $04, $01, $02, $22, $05, $02
    DB      $01, $23, $16, $00, $01, $24, $17, $01
    DB      $02, $25, $16, $02, $01, $26, $03, $06
    DB      $00, $01, $16, $1D, $01, $00, $17, $09
    DB      $02, $02, $20, $03, $0E, $00, $02, $13
    DB      $0E, $01, $02, $14, $0E, $02, $02, $15
    DB      $05, $07, $00, $02, $06, $15, $00, $02
    DB      $07, $02, $01, $00, $10, $1C, $01, $00
    DB      $11, $0E, $02, $02, $12, $06, $03, $00
    DB      $01, $00, $19, $00, $01, $01, $08, $01
    DB      $02, $02, $14, $01, $02, $03, $09, $02
    DB      $01, $04, $13, $02, $01, $05, $05, $0E
    DB      $00, $03, $27, $18, $00, $02, $30, $04
    DB      $02, $03, $31, $0E, $02, $01, $33, $19
    DB      $02, $03, $32, $04, $06, $00, $03, $34
    DB      $17, $00, $03, $35, $08, $01, $02, $36
    DB      $19, $02, $01, $37, $05, $0E, $00, $01
    DB      $40, $13, $01, $02, $41, $09, $01, $02
    DB      $42, $11, $02, $00, $43, $16, $02, $00
    DB      $44, $05, $0E, $01, $02, $45, $05, $02
    DB      $00, $46, $07, $02, $00, $47, $17, $02
    DB      $00, $50, $19, $02, $00, $51, $06, $02
    DB      $00, $03, $52, $1B, $00, $03, $53, $09
    DB      $01, $02, $54, $13, $01, $02, $55, $05
    DB      $02, $03, $56, $10, $02, $02, $57, $04
    DB      $06, $00, $03, $00, $17, $00, $03, $01
    DB      $02, $02, $03, $02, $1B, $02, $03, $03
    DB      $06, $0A, $00, $02, $04, $0A, $01, $02
    DB      $05, $0A, $02, $02, $06, $12, $00, $02
    DB      $07, $12, $01, $02, $10, $12, $02, $02
    DB      $11, $06, $0E, $00, $02, $12, $12, $01
    DB      $03, $13, $1B, $01, $03, $14, $15, $02
    DB      $01, $15, $0E, $02, $01, $16, $07, $02
    DB      $01, $17, $04, $06, $00, $01, $20, $1C
    DB      $00, $03, $21, $09, $02, $01, $22, $13
    DB      $02, $01, $23, $06, $0E, $00, $02, $24
    DB      $04, $01, $01, $25, $18, $01, $01, $26
    DB      $0B, $02, $00, $27, $0F, $02, $00, $30
    DB      $13, $02, $00, $31, $04, $03, $00, $02
    DB      $32, $18, $00, $02, $33, $18, $01, $01
    DB      $34, $03, $02, $01, $35, $05, $02, $00
    DB      $01, $36, $1A, $00, $01, $37, $07, $01
    DB      $01, $40, $1D, $01, $00, $41, $1D, $02
    DB      $00, $42, $06, $0A, $00, $00, $43, $14
    DB      $00, $00, $44, $06, $01, $03, $45, $1C
    DB      $01, $00, $46, $07, $02, $01, $47, $11
    DB      $02, $01, $50, $03, $02, $00, $02, $51
    DB      $1A, $00, $02, $52, $0E, $02, $01, $53
    DB      $06, $07, $00, $02, $54, $15, $00, $02
    DB      $55, $02, $01, $01, $56, $1A, $01, $01
    DB      $57, $16, $02, $03, $60, $07, $02, $03
    DB      $61, $82, $A5, $96, $A5, $AA, $A5, $BE
    DB      $A5, $C7, $A5, $CC, $A5, $CD, $A5, $CE
    DB      $A5, $CF, $A5, $D0, $A5, $D9, $A5, $E2
    DB      $A5, $E3, $A5, $E8, $A5, $E9, $A5, $F2
    DB      $A5, $F3, $A5, $F4, $A5, $01, $A6, $12
    DB      $A6, $17, $A6, $1C, $A6, $1D, $A6, $26
    DB      $A6, $27, $A6, $28, $A6, $2D, $A6, $3E
    DB      $A6, $3F, $A6, $48, $A6, $49, $A6, $52
    DB      $A6, $5B, $A6, $02, $02, $02, $00, $01
    DB      $1C, $02, $01, $01, $01, $1A, $02, $02
    DB      $00, $00, $00, $00, $00, $02, $1D, $01
    DB      $03, $00, $1D, $02, $04, $00, $02, $0B
    DB      $01, $05, $01, $1C, $01, $06, $00, $00
    DB      $01, $0F, $02, $07, $00, $00, $02, $02
    DB      $01, $03, $01, $18, $02, $04, $00, $00
    DB      $00, $03, $04, $02, $00, $00, $0F, $02
    DB      $01, $01, $1A, $02, $02, $00, $04, $0B
    DB      $01, $05, $00, $10, $01, $06, $00, $15
    DB      $01, $07, $00, $1A, $01, $10, $00, $01
    DB      $03, $01, $11, $01, $01, $1B, $02, $12
    DB      $01, $00, $02, $02, $02, $13, $01, $1C
    DB      $02, $14, $00, $00, $00, $01, $17, $01
    DB      $00, $01, $04, $1C, $01, $01, $00, $1C
    DB      $02, $02, $00, $02, $02, $03, $00, $0F
    DB      $02, $04, $01, $00, $02, $02, $01, $05
    DB      $00, $1C, $02, $06, $01, $00, $02, $03
    DB      $01, $07, $01, $03, $02, $10, $01, $02
    DB      $0A, $02, $11, $00, $14, $02, $12, $00
    DB      $00, $62, $A6, $76, $A6, $8A, $A6, $9E
    DB      $A6, $A9, $A6, $AF, $A6, $BF, $A6, $C5
    DB      $A6, $C6, $A6, $D6, $A6, $DC, $A6, $E2
    DB      $A6, $E3, $A6, $E9, $A6, $EA, $A6, $F5
    DB      $A6, $00, $A7, $10, $A7, $16, $A7, $21
    DB      $A7, $27, $A7, $32, $A7, $3D, $A7, $43
    DB      $A7, $4E, $A7, $5E, $A7, $6E, $A7, $79
    DB      $A7, $84, $A7, $85, $A7, $8B, $A7, $96
    DB      $A7, $A6, $A7, $02, $02, $00, $01, $38
    DB      $00, $02, $01, $01, $C0, $00, $01, $00
    DB      $02, $00, $02, $EE, $03, $02, $03, $00
    DB      $7C, $00, $02, $04, $01, $7C, $00, $02
    DB      $05, $02, $7C, $00, $01, $00, $06, $00
    DB      $02, $EE, $00, $03, $00, $07, $02, $02
    DB      $EE, $02, $10, $00, $38, $00, $02, $11
    DB      $00, $C0, $00, $01, $00, $12, $00, $60
    DB      $90, $01, $02, $13, $00, $7C, $00, $00
    DB      $01, $00, $14, $00, $02, $EE, $00, $02
    DB      $02, $06, $02, $7C, $00, $02, $07, $02
    DB      $2C, $00, $02, $01, $04, $00, $00, $00
    DB      $00, $05, $01, $60, $90, $03, $00, $01
    DB      $00, $08, $EE, $02, $02, $02, $4C, $00
    DB      $02, $03, $02, $AC, $00, $01, $01, $00
    DB      $00, $00, $00, $02, $02, $10, $00, $10
    DB      $00, $01, $11, $02, $00, $00, $01, $01
    DB      $12, $00, $00, $00, $02, $00, $13, $00
    DB      $60, $90, $01, $14, $01, $00, $00, $02
    DB      $02, $15, $00, $10, $00, $02, $16, $00
    DB      $E8, $00, $01, $00, $17, $00, $30, $C0
    DB      $02, $01, $00, $00, $00, $00, $00, $01
    DB      $02, $68, $88, $03, $01, $02, $00, $00
    DB      $00, $01, $03, $01, $00, $00, $01, $04
    DB      $02, $00, $00, $03, $00, $05, $01, $78
    DB      $A8, $02, $06, $02, $64, $00, $02, $07
    DB      $02, $94, $00, $02, $02, $10, $02, $30
    DB      $00, $02, $11, $02, $C0, $00, $02, $01
    DB      $12, $00, $00, $00, $01, $13, $02, $00
    DB      $00, $00, $01, $02, $14, $00, $7C, $00
    DB      $02, $02, $15, $00, $18, $00, $02, $16
    DB      $00, $E0, $00, $03, $02, $20, $00, $60
    DB      $00, $02, $21, $00, $98, $00, $01, $22
    DB      $01, $00, $00, $03, $02, $23, $00, $60
    DB      $00, $02, $24, $00, $98, $00, $00, $25
    DB      $01, $68, $88, $BC, $A7, $D0, $A7, $E4
    DB      $A7, $F8, $A7, $1D, $A8, $39, $A8, $70
    DB      $A8, $83, $A8, $9C, $A8, $CA, $A8, $EF
    DB      $A8, $14, $A9, $39, $A9, $5B, $A9, $6E
    DB      $A9, $87, $A9, $B5, $A9, $D7, $A9, $F0
    DB      $A9, $06, $AA, $25, $AA, $50, $AA, $7E
    DB      $AA, $97, $AA, $B9, $AA, $02, $AB, $21
    DB      $AB, $2E, $AB, $5F, $AB, $7E, $AB, $9A
    DB      $AB, $BC, $AB, $D8, $AB, $0C, $01, $0B
    DB      $00, $01, $13, $00, $02, $0F, $00, $00
    DB      $02, $01, $00, $0B, $01, $02, $0F, $01
    DB      $00, $13, $01, $00, $1C, $01, $04, $06
    DB      $02, $04, $16, $02, $02, $0C, $02, $02
    DB      $12, $02, $09, $00, $03, $00, $00, $0F
    DB      $00, $00, $1B, $00, $01, $02, $01, $01
    DB      $1C, $01, $04, $08, $01, $04, $14, $01
    DB      $00, $16, $02, $00, $0E, $02, $12, $00
    DB      $02, $00, $00, $0B, $00, $00, $13, $00
    DB      $00, $1C, $00, $02, $06, $00, $02, $18
    DB      $00, $00, $02, $01, $00, $0B, $01, $00
    DB      $13, $01, $02, $06, $01, $02, $18, $01
    DB      $00, $1C, $01, $00, $02, $02, $00, $0B
    DB      $02, $00, $13, $02, $00, $1C, $02, $02
    DB      $06, $02, $02, $18, $02, $06, $00, $02
    DB      $00, $01, $0F, $00, $00, $1C, $00, $01
    DB      $02, $01, $01, $0E, $01, $01, $19, $02
    DB      $08, $00, $02, $00, $01, $02, $01, $01
    DB      $02, $02, $01, $0F, $00, $01, $0F, $01
    DB      $00, $1C, $00, $01, $1C, $01, $01, $1C
    DB      $02, $0F, $00, $03, $00, $00, $0A, $00
    DB      $02, $0F, $00, $00, $14, $00, $00, $1B
    DB      $00, $00, $02, $01, $01, $0B, $01, $02
    DB      $0F, $01, $01, $13, $01, $00, $1C, $01
    DB      $04, $04, $02, $01, $0A, $02, $04, $0E
    DB      $02, $01, $14, $02, $04, $18, $02, $0C
    DB      $04, $03, $00, $02, $0A, $00, $02, $14
    DB      $00, $01, $0C, $00, $01, $12, $00, $04
    DB      $19, $00, $00, $02, $01, $04, $07, $01
    DB      $00, $0E, $01, $01, $03, $02, $01, $19
    DB      $02, $04, $13, $02, $0C, $00, $02, $00
    DB      $00, $0C, $00, $00, $12, $00, $00, $1C
    DB      $00, $01, $02, $01, $01, $0F, $01, $01
    DB      $07, $02, $02, $0A, $02, $00, $0C, $02
    DB      $00, $12, $02, $02, $14, $02, $01, $17
    DB      $02, $0C, $04, $03, $00, $01, $09, $00
    DB      $04, $18, $00, $01, $14, $00, $00, $03
    DB      $01, $01, $09, $01, $01, $14, $01, $00
    DB      $1A, $01, $04, $03, $02, $01, $09, $02
    DB      $04, $18, $02, $01, $14, $02, $0B, $00
    DB      $03, $00, $00, $0B, $00, $00, $13, $00
    DB      $00, $1B, $00, $01, $02, $01, $04, $06
    DB      $01, $01, $0F, $01, $04, $16, $01, $01
    DB      $1C, $01, $01, $0A, $02, $01, $14, $02
    DB      $06, $04, $05, $00, $01, $09, $01, $04
    DB      $05, $02, $04, $16, $00, $01, $14, $01
    DB      $04, $16, $02, $08, $04, $06, $00, $01
    DB      $02, $00, $01, $0C, $00, $01, $1C, $00
    DB      $04, $18, $01, $00, $14, $01, $01, $1C
    DB      $02, $04, $09, $02, $0F, $04, $03, $00
    DB      $02, $0A, $00, $02, $14, $00, $04, $19
    DB      $00, $00, $02, $01, $00, $06, $01, $02
    DB      $0A, $01, $02, $14, $01, $04, $0E, $01
    DB      $00, $18, $01, $00, $1C, $01, $04, $03
    DB      $02, $04, $19, $02, $02, $09, $02, $02
    DB      $15, $02, $0B, $00, $03, $00, $04, $07
    DB      $00, $00, $0D, $00, $00, $11, $00, $04
    DB      $15, $00, $00, $1B, $00, $01, $02, $02
    DB      $02, $06, $02, $04, $0E, $02, $02, $18
    DB      $02, $01, $1C, $02, $08, $01, $09, $00
    DB      $04, $0E, $00, $01, $15, $00, $01, $03
    DB      $01, $01, $0F, $01, $01, $1B, $01, $04
    DB      $09, $02, $04, $13, $02, $07, $02, $05
    DB      $00, $02, $05, $01, $01, $02, $01, $01
    DB      $0A, $02, $01, $14, $02, $00, $09, $00
    DB      $00, $14, $00, $0A, $01, $01, $00, $01
    DB      $0C, $00, $01, $12, $00, $01, $1D, $00
    DB      $02, $0F, $00, $04, $08, $01, $00, $1C
    DB      $01, $01, $02, $02, $01, $14, $02, $04
    DB      $19, $02, $0E, $00, $03, $00, $00, $07
    DB      $00, $02, $0A, $00, $04, $0E, $00, $02
    DB      $14, $00, $00, $17, $00, $00, $1B, $00
    DB      $01, $04, $01, $04, $09, $01, $01, $0F
    DB      $01, $04, $13, $01, $01, $1A, $01, $04
    DB      $03, $02, $01, $0B, $02, $0F, $00, $06
    DB      $00, $00, $0B, $00, $03, $0E, $00, $00
    DB      $13, $00, $00, $18, $00, $01, $04, $01
    DB      $02, $09, $01, $04, $0E, $01, $02, $15
    DB      $01, $01, $1B, $01, $01, $02, $02, $01
    DB      $0A, $02, $02, $0F, $02, $01, $14, $02
    DB      $01, $1C, $02, $08, $01, $05, $01, $04
    DB      $09, $01, $01, $0F, $01, $04, $13, $01
    DB      $01, $19, $01, $00, $0B, $02, $04, $10
    DB      $02, $00, $17, $02, $0B, $00, $03, $00
    DB      $00, $0A, $00, $00, $14, $00, $00, $1B
    DB      $00, $00, $02, $01, $00, $1C, $01, $01
    DB      $07, $02, $02, $0B, $02, $01, $0F, $02
    DB      $02, $13, $02, $01, $17, $02, $18, $01
    DB      $02, $00, $02, $05, $00, $02, $09, $00
    DB      $02, $0D, $00, $02, $11, $00, $02, $15
    DB      $00, $02, $19, $00, $01, $1C, $00, $00
    DB      $02, $01, $02, $05, $01, $02, $09, $01
    DB      $02, $0D, $01, $02, $11, $01, $02, $15
    DB      $01, $02, $19, $01, $00, $1C, $01, $01
    DB      $02, $02, $02, $05, $02, $02, $09, $02
    DB      $02, $0D, $02, $02, $11, $02, $02, $15
    DB      $02, $02, $19, $02, $01, $1C, $02, $0A
    DB      $04, $04, $00, $00, $0A, $00, $02, $0F
    DB      $00, $00, $14, $00, $04, $18, $00, $01
    DB      $02, $01, $04, $06, $01, $01, $0C, $01
    DB      $01, $02, $02, $01, $1C, $02, $04, $01
    DB      $02, $00, $01, $0C, $00, $01, $02, $01
    DB      $00, $16, $01, $10, $01, $03, $00, $01
    DB      $0A, $00, $01, $14, $00, $01, $1B, $00
    DB      $04, $04, $01, $02, $0D, $01, $02, $11
    DB      $01, $04, $18, $01, $01, $02, $02, $02
    DB      $05, $02, $02, $09, $02, $02, $0D, $02
    DB      $02, $11, $02, $02, $15, $02, $02, $19
    DB      $02, $01, $1C, $02, $0A, $04, $03, $00
    DB      $01, $0A, $00, $01, $14, $00, $04, $18
    DB      $00, $01, $0A, $01, $01, $14, $01, $04
    DB      $18, $01, $04, $03, $02, $01, $0A, $02
    DB      $01, $14, $02, $09, $01, $08, $00, $02
    DB      $0B, $00, $02, $13, $00, $01, $16, $00
    DB      $01, $03, $01, $04, $07, $01, $01, $0D
    DB      $01, $00, $03, $02, $01, $19, $02, $0B
    DB      $02, $07, $00, $01, $0F, $00, $02, $17
    DB      $00, $01, $0C, $01, $01, $12, $01, $00
    DB      $18, $01, $04, $07, $02, $01, $0D, $02
    DB      $04, $11, $02, $01, $17, $02, $00, $1B
    DB      $02, $09, $02, $08, $00, $01, $0F, $00
    DB      $02, $16, $00, $01, $02, $01, $01, $1C
    DB      $01, $01, $02, $02, $01, $06, $02, $01
    DB      $18, $02, $01, $1C, $02, $10, $01, $03
    DB      $00, $02, $08, $00, $02, $0F, $00, $02
    DB      $16, $00, $01, $1B, $00, $04, $02, $01
    DB      $01, $08, $01, $02, $0B, $01, $01, $0F
    DB      $01, $02, $13, $01, $01, $16, $01, $04
    DB      $1A, $01, $01, $03, $02, $02, $0B, $02
    DB      $02, $13, $02, $01, $1B, $02, $0F, $AC
    DB      $23, $AC, $37, $AC, $4B, $AC, $4C, $AC
    DB      $53, $AC, $54, $AC, $55, $AC, $59, $AC
    DB      $5A, $AC, $5B, $AC, $5F, $AC, $60, $AC
    DB      $67, $AC, $68, $AC, $69, $AC, $70, $AC
    DB      $77, $AC, $7E, $AC, $7F, $AC, $80, $AC
    DB      $87, $AC, $8E, $AC, $95, $AC, $9C, $AC
    DB      $9D, $AC, $9E, $AC, $9F, $AC, $A6, $AC
    DB      $A7, $AC, $A8, $AC, $AF, $AC, $B0, $AC
    DB      $00, $02, $28, $01, $28, $D0, $01, $32
    DB      $00, $00, $01, $7C, $02, $28, $00, $00
    DB      $01, $7C, $02, $1E, $00, $02, $14, $02
    DB      $28, $E4, $02, $32, $00, $00, $02, $64
    DB      $02, $0F, $94, $02, $0F, $02, $64, $01
    DB      $0F, $94, $01, $0C, $02, $30, $01, $14
    DB      $C8, $01, $19, $00, $00, $02, $4C, $02
    DB      $0A, $6C, $02, $0A, $02, $64, $01, $14
    DB      $94, $01, $19, $02, $14, $01, $14, $E4
    DB      $01, $11, $02, $6C, $01, $14, $8C, $01
    DB      $14, $00, $00, $00, $02, $54, $01, $14
    DB      $A4, $01, $14, $00, $00, $02, $54, $01
    DB      $0A, $A4, $01, $11, $00, $01, $7C, $02
    DB      $08, $BA, $AC, $CE, $AC, $E2, $AC, $F6
    DB      $AC, $F7, $AC, $F8, $AC, $F9, $AC, $FF
    DB      $AC, $05, $AD, $06, $AD, $0C, $AD, $0D
    DB      $AD, $13, $AD, $14, $AD, $1A, $AD, $20
    DB      $AD, $21, $AD, $27, $AD, $28, $AD, $29
    DB      $AD, $2F, $AD, $30, $AD, $31, $AD, $37
    DB      $AD, $3D, $AD, $3E, $AD, $44, $AD, $4A
    DB      $AD, $4B, $AD, $51, $AD, $57, $AD, $58
    DB      $AD, $5E, $AD, $00, $00, $00, $01, $00
    DB      $19, $02, $01, $00, $01, $01, $02, $01
    DB      $00, $00, $00, $01, $00, $19, $02, $00
    DB      $00, $00, $01, $02, $00, $00, $00, $00
    DB      $00, $01, $02, $00, $00, $00, $00, $01
    DB      $00, $16, $01, $00, $00, $00, $01, $01
    DB      $01, $01, $00, $00, $00, $00, $01, $00
    DB      $16, $02, $00, $00, $00, $00, $01, $01
    DB      $00, $00, $00, $00, $01, $01, $01, $00
    DB      $00, $00, $00, $01, $01, $02, $01, $00
    DB      $00, $01, $00, $16, $01, $01, $00, $00
    DB      $01, $02, $00, $00, $00, $00, $01, $00
    DB      $16, $02, $00, $00, $00, $01, $01, $01
    DB      $00, $00, $00, $00

SUB_AD5F:
    LD      C, $15
    LD      B, $40
    CALL    SUB_AE06
    LD      C, $46
    LD      B, $7D
    CALL    SUB_AE06
    LD      C, $83
    LD      B, $BA
    CALL    SUB_AE06
    LD      C, $40
    CALL    SUB_ADE3
    LD      C, $7D
    CALL    SUB_ADE3
    LD      C, $BA
    CALL    SUB_ADE3
    LD      A, ($719A)                  ; RAM $719A
    LD      C, A
    LD      HL, $A7B6
    CALL    SUB_A2D8
    LD      C, A
    AND     A
    JP      Z, LOC_ADE2

LOC_AD92:
    LD      (WORK_BUFFER), IX           ; WORK_BUFFER
    PUSH    BC
    LD      C, (IX+0)
    LD      HL, $AE78
    CALL    SUB_980F
    LD      IX, (WORK_BUFFER)           ; WORK_BUFFER
    LD      C, (IX+2)
    LD      B, $00
    ADD     IY, BC
    LD      C, (IY+0)
    LD      B, (IX+1)
    PUSH    BC
    LD      C, (IX+0)
    LD      HL, $AE64
    CALL    SUB_980F
    PUSH    IY
    LD      IX, (WORK_BUFFER)           ; WORK_BUFFER
    LD      C, (IX+0)
    LD      HL, $AE6E
    CALL    SUB_980F
    POP     HL
    PUSH    IX
    POP     DE
    POP     BC
    LD      A, $01
    CALL    SUB_8F49
    LD      IX, (WORK_BUFFER)           ; WORK_BUFFER
    LD      A, $03
    CALL    SUB_9807
    POP     BC
    DEC     C
    JP      NZ, LOC_AD92

LOC_ADE2:
    RET     

SUB_ADE3:
    LD      B, $00

LOC_ADE5:
    PUSH    BC
    LD      A, ($7197)                  ; RAM $7197
    LD      E, A
    SLA     E
    LD      D, $00
    LD      HL, $AE46
    ADD     HL, DE
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    LD      HL, $AE3E
    LD      A, $01
    CALL    SUB_8F49
    POP     BC
    INC     B
    LD      A, B
    CP      $20
    JP      NZ, LOC_ADE5
    RET     

SUB_AE06:
    PUSH    BC
    LD      B, $00
    LD      A, $01
    LD      DE, $AE1C
    LD      HL, $AE1C
    CALL    SUB_8F49
    POP     BC
    INC     C
    LD      A, C
    CP      B
    JP      NZ, SUB_AE06
    RET     
    DB      $20, $01, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $01, $06, $FF, $81, $81, $81
    DB      $81, $FF, $4C, $AE, $54, $AE, $5C, $AE
    DB      $01, $06, $F6, $F6, $F6, $F6, $F6, $F6
    DB      $01, $06, $F4, $F4, $F4, $F4, $F4, $F4
    DB      $01, $06, $F3, $F3, $F3, $F3, $F3, $F3
    DB      $91, $AE, $CD, $AE, $21, $AF, $2F, $AF
    DB      $49, $AF, $AF, $AE, $F7, $AE, $21, $AF
    DB      $2F, $AF, $6F, $AF, $82, $AE, $85, $AE
    DB      $88, $AE, $8B, $AE, $8E, $AE, $32, $6F
    DB      $AC, $2C, $69, $A6, $40, $7D, $BA, $40
    DB      $7D, $BA, $37, $74, $B1, $02, $0E, $03
    DB      $E0, $0F, $38, $16, $98, $1F, $FC, $3F
    DB      $C8, $2F, $EC, $1F, $FC, $31, $CC, $01
    DB      $80, $1F, $F8, $1F, $F8, $1F, $F8, $1F
    DB      $F8, $07, $E0, $02, $0E, $20, $20, $20
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $D0
    DB      $D0, $F0, $F0, $D0, $D0, $D0, $D0, $D0
    DB      $D0, $02, $14, $01, $80, $03, $C0, $0C
    DB      $F8, $0F, $CC, $1F, $3C, $19, $98, $0D
    DB      $EC, $0F, $9C, $0F, $38, $07, $E0, $01
    DB      $80, $01, $80, $01, $80, $1F, $F8, $1F
    DB      $F8, $1F, $F8, $1F, $F8, $1F, $F8, $1F
    DB      $F8, $07, $E0, $02, $14, $20, $20, $20
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $40 ; "       @"
    DB      $40, $60, $60, $60, $60, $40, $40, $40 ; "@````@@@"
    DB      $40, $40, $40, $40, $40, $02, $06, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $04, $06, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $04, $09, $3F
    DB      $FC, $3F, $FC, $7F, $FE, $7F, $FE, $7F
    DB      $FE, $7F, $FE, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $C0, $00, $00, $03, $C0
    DB      $00, $00, $03, $C0, $00, $00, $03, $C0
    DB      $00, $00, $03, $04, $09, $40, $40, $40
    DB      $40, $40, $40, $40, $40, $40, $40, $40 ; "@@@@@@@@"
    DB      $40, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0

SUB_AF95:
    LD      C, $07
    LD      HL, $AFD5
    LD      DE, $AFE3
    LD      IX, $AFF1

LOC_AFA1:
    PUSH    BC
    PUSH    HL
    PUSH    DE
    PUSH    IX
    PUSH    HL
    POP     IY
    LD      L, (IY+0)
    LD      H, (IY+1)
    PUSH    DE
    POP     IY
    LD      E, (IY+0)
    LD      D, (IY+1)
    LD      B, (IX+0)
    LD      C, (IX+1)
    LD      A, $01
    CALL    SUB_8F49
    POP     IX
    POP     DE
    POP     HL
    POP     BC
    INC     IX
    INC     IX
    INC     HL
    INC     HL
    INC     DE
    INC     DE
    DEC     C
    JP      NZ, LOC_AFA1
    RET     
    DB      $0B, $B0, $7B, $B0, $D9, $B0, $01, $B1
    DB      $21, $B1, $21, $B1, $FF, $AF, $43, $B0
    DB      $AA, $B0, $ED, $B0, $11, $B1, $40, $B1
    DB      $40, $B1, $05, $B0, $02, $00, $0D, $00
    DB      $16, $00, $1C, $00, $02, $0A, $02, $0B
    DB      $0F, $10, $01, $04, $18, $00, $00, $18
    DB      $01, $04, $20, $20, $20, $20, $06, $09
    DB      $07, $E7, $E7, $E7, $C7, $E0, $06, $66
    DB      $66, $66, $66, $00, $06, $06, $06, $66
    DB      $66, $00, $06, $06, $06, $66, $66, $00
    DB      $07, $E6, $06, $67, $E7, $E0, $00, $66
    DB      $06, $66, $C6, $00, $00, $66, $06, $66
    DB      $E6, $00, $06, $66, $66, $66, $66, $00
    DB      $07, $E7, $E7, $E6, $67, $E0, $06, $09
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20 ; "       "

; ============================================================
; GAME DATA  ($B054 - $BBFF)
; Animation, sprite, level, and name-table data.
; (Tracer did not reach this area via static flow; kept as DB.)
; ============================================================
GAME_DATA:                                  ; GAME_DATA: level animation/sprite/map data block (space chars + encoded entries)
    DB      $20, $20, $20, $20, $20, $20, $20, $20; Space-fill padding ($20) — empty tile area at start of game data
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $05
    DB      $09, $07, $E3, $C7, $E7, $E0, $01, $81
    DB      $8F, $F6, $00, $01, $81, $8D, $B6, $00
    DB      $01, $81, $8D, $B6, $00, $01, $81, $8C
    DB      $37, $E0, $01, $81, $8C, $36, $00, $01
    DB      $81, $8E, $76, $00, $01, $81, $8E, $76
    DB      $00, $01, $83, $CE, $77, $E0, $05, $09
    DB      $50, $50, $50, $50, $50, $50, $50, $50 ; "PPPPPPPP"
    DB      $50, $50, $50, $50, $50, $50, $50, $50 ; "PPPPPPPP"
    DB      $50, $50, $50, $50, $50, $50, $50, $50 ; "PPPPPPPP"
    DB      $50, $50, $50, $50, $50, $50, $50, $50 ; "PPPPPPPP"
    DB      $50, $50, $50, $50, $50, $50, $50, $50 ; "PPPPPPPP"
    DB      $50, $50, $50, $50, $50, $02, $09, $03
    DB      $C0, $06, $60, $06, $60, $03, $C0, $01
    DB      $80, $01, $80, $01, $B0, $01, $F0, $01
    DB      $B0, $02, $09, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $02, $07, $07
    DB      $E0, $07, $F8, $07, $20, $07, $F0, $07
    DB      $00, $03, $C0, $01, $80, $02, $07, $D0
    DB      $D0, $D0, $D0, $B0, $B0, $B0, $B0, $B0
    DB      $B0, $B0, $B0, $B0, $B0, $1D, $01, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $1D, $01, $B0, $B0
    DB      $B0, $B0, $B0, $B0, $B0, $B0, $B0, $B0
    DB      $B0, $B0, $B0, $B0, $B0, $B0, $B0, $B0
    DB      $B0, $B0, $B0, $B0, $B0, $B0, $B0, $B0
    DB      $B0, $B0, $B0

SUB_B15F:                                   ; SUB_B15F: look up 2-byte pointer from HL table indexed by C; return in IX/IY
    PUSH    BC                              ; PUSH BC: save BC
    LD      B, $00
    SLA     C                               ; SLA C: C×2 (word index)
    ADD     HL, BC                          ; ADD HL, BC: HL points to table entry
    LD      C, (HL)                         ; C = (HL), B = (HL+1): load pointer from table
    INC     HL
    LD      B, (HL)
    PUSH    BC                              ; PUSH BC, POP IX: IX = loaded pointer
    POP     IX
    PUSH    BC                              ; PUSH BC, POP IY: IY = loaded pointer
    POP     IY
    DEC     HL
    POP     BC
    RET     

SUB_B171:
    PUSH    BC
    LD      B, $00
    ADD     HL, BC
    LD      A, (HL)
    POP     BC
    RET     
    DB      $8C, $B1, $F4, $B1, $A6, $B1, $C0, $B1
    DB      $DA, $B1, $0D, $0B, $02, $0F, $05, $0D
    DB      $08, $02, $0F, $05, $FB, $F2, $19, $1A
    DB      $19, $19, $19, $19, $19, $19, $19, $19
    DB      $19, $19, $1A, $1A, $1A, $1A, $1A, $1A
    DB      $1A, $1A, $1A, $1A, $19, $1A, $FB, $02
    DB      $21, $22, $21, $21, $21, $21, $21, $21 ; "!"!!!!!!"
    DB      $21, $21, $21, $21, $22, $22, $22, $22 ; "!!!!"""""
    DB      $22, $22, $22, $22, $22, $22, $21, $22 ; """""""!""
    DB      $FB, $12, $23, $29, $24, $25, $26, $27
    DB      $28, $24, $25, $26, $27, $28, $2A, $2B ; "($%&'(*+"
    DB      $2C, $2D, $2E, $2A, $2B, $2C, $2D, $2E ; ",-.*+,-."
    DB      $28, $2E, $FB, $12, $2F, $35, $30, $31
    DB      $32, $33, $34, $30, $31, $32, $33, $34 ; "23401234"
    DB      $36, $37, $38, $39, $3A, $36, $37, $38 ; "6789:678"
    DB      $39, $3A, $34, $3A, $FB, $02, $1B, $1E
    DB      $1C, $1C, $1B, $1B, $1B, $1D, $1D, $1B
    DB      $1B, $1B, $1F, $1F, $1E, $1E, $1E, $20
    DB      $20, $1E, $1E, $1E, $1C, $1F

SOUND_WRITE_B20E:
    LD      IX, $70DE                   ; RAM $70DE
    LD      A, $00
    LD      (IX+22), A
    LD      BC, $B178
    LD      (IX+3), C
    LD      (IX+4), B
    LD      BC, $B182
    LD      (IX+5), C
    LD      (IX+6), B
    LD      A, $FF
    LD      (IX+9), A
    LD      A, $9E
    LD      (IX+7), A
    LD      A, $46
    LD      (IX+8), A
    LD      A, $00
    LD      (IX+10), A
    LD      A, $00
    LD      (IX+23), A
    LD      A, $00
    LD      ($71EE), A                  ; RAM $71EE
    LD      ($71EF), A                  ; RAM $71EF
    LD      ($71F0), A                  ; RAM $71F0
    LD      ($71F1), A                  ; RAM $71F1
    LD      ($71F2), A                  ; RAM $71F2
    LD      ($71F3), A                  ; RAM $71F3
    RET     

SOUND_WRITE_B257:
    LD      IX, $70DE                   ; RAM $70DE
    LD      B, $FF
    LD      (IX+21), B
    LD      A, $FF
    LD      (IX+0), A
    LD      A, $FF
    LD      (IX+1), A
    LD      A, $05
    LD      (IX+2), A
    LD      A, $00
    LD      (IX+23), A
    LD      BC, $B182
    LD      (IX+5), C
    LD      (IX+6), B
    LD      A, $00
    LD      ($71F2), A                  ; RAM $71F2
    LD      ($71F3), A                  ; RAM $71F3
    LD      ($71F4), A                  ; RAM $71F4
    RET     

SOUND_WRITE_B289:
    CALL    SOUND_WRITE_B2A4
    LD      A, ($7199)                  ; RAM $7199
    CP      $FF
    JP      Z, LOC_B2A3
    LD      IX, $70DE                   ; RAM $70DE
    LD      A, (IX+21)
    CP      $FF
    JP      NZ, LOC_B2A3
    CALL    SOUND_WRITE_B35F

LOC_B2A3:
    RET     

SOUND_WRITE_B2A4:
    LD      A, ($70E6)                  ; RAM $70E6
    CP      $C0
    JP      C, LOC_B2B1
    LD      A, $FF
    LD      ($71F2), A                  ; RAM $71F2

LOC_B2B1:
    LD      A, ($71A6)                  ; RAM $71A6
    CP      $FF
    JP      NZ, LOC_B2BE
    LD      A, $00
    LD      ($71F2), A                  ; RAM $71F2

LOC_B2BE:
    LD      A, ($70E5)                  ; RAM $70E5
    CP      $20
    JP      NC, LOC_B2DE
    LD      A, ($70E7)                  ; RAM $70E7
    CP      $FF
    JP      Z, LOC_B2DE
    LD      A, $FF
    LD      ($70E7), A                  ; RAM $70E7
    LD      A, ($70E5)                  ; RAM $70E5
    ADD     A, $20
    LD      ($70E5), A                  ; RAM $70E5
    JP      LOC_B2FB

LOC_B2DE:
    LD      A, ($70E5)                  ; RAM $70E5
    CP      $40
    JP      C, LOC_B2FB
    LD      A, ($70E7)                  ; RAM $70E7
    CP      $FF
    JP      NZ, LOC_B2FB
    LD      A, $00
    LD      ($70E7), A                  ; RAM $70E7
    LD      A, ($70E5)                  ; RAM $70E5
    SUB     $20
    LD      ($70E5), A                  ; RAM $70E5

LOC_B2FB:
    LD      A, ($7199)                  ; RAM $7199
    CP      $FF
    JP      Z, LOC_B34E
    LD      A, ($70E7)                  ; RAM $70E7
    CP      $FF
    JP      NZ, LOC_B32C
    LD      A, ($70E5)                  ; RAM $70E5
    CP      $10
    JP      NC, LOC_B34E
    LD      A, $00
    LD      ($70E7), A                  ; RAM $70E7
    LD      A, $FD
    LD      ($70E5), A                  ; RAM $70E5
    LD      HL, $719A                   ; RAM $719A
    DEC     (HL)
    JP      P, LOC_B329
    LD      A, $09
    LD      ($719A), A                  ; RAM $719A

LOC_B329:
    JP      LOC_B34F

LOC_B32C:
    LD      A, ($70E5)                  ; RAM $70E5
    CP      $FF
    JP      C, LOC_B34E
    LD      A, $11
    LD      ($70E5), A                  ; RAM $70E5
    LD      A, $FF
    LD      ($70E7), A                  ; RAM $70E7
    LD      HL, $719A                   ; RAM $719A
    INC     (HL)
    LD      A, (HL)
    CP      $0A
    JP      C, LOC_B34B
    LD      A, $00
    LD      (HL), A

LOC_B34B:
    JP      LOC_B34F

LOC_B34E:
    RET     

LOC_B34F:
    LD      A, $FF
    LD      ($7199), A                  ; RAM $7199
    LD      A, $00
    LD      ($70DE), A                  ; RAM $70DE
    LD      A, $FF
    LD      ($71F4), A                  ; RAM $71F4
    RET     

SOUND_WRITE_B35F:
    LD      A, ($71F3)                  ; RAM $71F3
    CP      $FF
    JP      Z, LOC_B386
    LD      A, ($71F2)                  ; RAM $71F2
    CP      $FF
    JP      NZ, LOC_B386
    LD      A, (IX+23)
    CP      $FF
    JP      Z, LOC_B386
    LD      A, $FF
    LD      (IX+23), A
    LD      A, $64
    LD      (IX+12), A
    LD      A, $07
    LD      (IX+22), A

LOC_B386:
    LD      A, ($71F3)                  ; RAM $71F3
    CP      $FF
    JP      NZ, LOC_B398
    LD      A, $FF
    LD      (IX+23), A
    LD      A, $09
    LD      (IX+22), A

LOC_B398:
    LD      A, ($719B)                  ; RAM $719B
    CP      $FF
    JP      NZ, LOC_B3B2
    LD      A, (IX+23)
    CP      $FF
    JP      Z, LOC_B3B2
    LD      A, $0A
    LD      (IX+22), A
    LD      A, $FF
    LD      (IX+23), A

LOC_B3B2:
    LD      C, (IX+22)
    LD      HL, $B813
    PUSH    IX
    PUSH    IY
    CALL    SUB_B15F
    PUSH    IX
    POP     HL
    POP     IY
    POP     IX
    JP      (HL)
    DB      $3E, $00, $DD, $77, $11, $DD, $77, $12
    DB      $3E, $FF, $DD, $77, $0B, $3E, $06, $DD
    DB      $77, $0E, $3E, $21, $DD, $77, $0F, $3E
    DB      $01, $DD, $77, $16, $C9, $3E, $00, $32
    DB      $EE, $71, $3A, $C2, $71, $FE, $FF, $CA
    DB      $1A, $B4, $3A, $BC, $71, $FE, $FF, $C2
    DB      $4C, $B4, $3E, $FF, $32, $EE, $71, $DD
    DB      $7E, $0B, $FE, $FF, $CA, $0E, $B4, $3E
    DB      $01, $DD, $77, $0A, $C3, $13, $B4, $3E
    DB      $00, $DD, $77, $0A, $CD, $30, $BC, $D2
    DB      $65, $B4, $C9, $3A, $BC, $71, $FE, $FF
    DB      $C2, $62, $B4, $3E, $FF, $32, $EF, $71
    DB      $0E, $16, $DD, $7E, $0B, $FE, $FF, $CA
    DB      $33, $B4, $0E, $17, $DD, $71, $0A, $DD
    DB      $7E, $08, $D6, $10, $DD, $77, $10, $3E
    DB      $02, $DD, $77, $16, $CD, $30, $BC, $3E
    DB      $00, $CD, $AD, $9C, $C9, $3E, $FF, $32
    DB      $F1, $71, $3E, $AA, $DD, $77, $0B, $3E
    DB      $03, $DD, $77, $16, $CD, $30, $BC, $D2
    DB      $65, $B4, $C9, $C3, $64, $B5, $3E, $FF
    DB      $32, $F0, $71, $3E, $00, $32, $EE, $71
    DB      $32, $F1, $71, $3E, $06, $DD, $77, $16
    DB      $CD, $30, $BC, $DA, $C8, $B5, $C9, $DD
    DB      $7E, $08, $DD, $BE, $10, $CA, $9E, $B4
    DB      $DD, $35, $08, $CD, $30, $BC, $D2, $9D
    DB      $B4, $3E, $00, $32, $EF, $71, $3E, $FF
    DB      $32, $EE, $71, $C3, $C8, $B5, $C9, $3E
    DB      $00, $32, $EF, $71, $3E, $FF, $32, $F0
    DB      $71, $3E, $06, $DD, $77, $16, $CD, $30
    DB      $BC, $D2, $C0, $B4, $3E, $00, $32, $F0
    DB      $71, $3E, $FF, $32, $EE, $71, $C3, $C8
    DB      $B5, $C9, $3E, $00, $32, $F1, $71, $3A
    DB      $BC, $71, $FE, $FF, $CA, $61, $B5, $3A
    DB      $C2, $71, $FE, $FF, $CA, $64, $B5, $3E
    DB      $FF, $32, $F1, $71, $3A, $C1, $71, $DD
    DB      $BE, $0B, $CA, $F9, $B4, $DD, $77, $0B
    DB      $E6, $FF, $C2, $F4, $B4, $3E, $0C, $DD
    DB      $77, $0A, $C3, $F9, $B4, $3E, $02, $DD
    DB      $77, $0A, $3A, $31, $70, $E6, $03, $C2
    DB      $29, $B5, $DD, $7E, $0B, $FE, $FF, $CA
    DB      $19, $B5, $DD, $7E, $0A, $FE, $15, $C2
    DB      $26, $B5, $3E, $0B, $DD, $77, $0A, $C3
    DB      $26, $B5, $DD, $7E, $0A, $FE, $0B, $C2
    DB      $26, $B5, $3E, $01, $DD, $77, $0A, $DD
    DB      $34, $0A, $DD, $7E, $0B, $FE, $FF, $CA
    DB      $39, $B5, $3E, $FF, $DD, $77, $11, $C3
    DB      $3E, $B5, $3E, $01, $DD, $77, $11, $3E
    DB      $00, $DD, $77, $12, $DD, $7E, $07, $DD
    DB      $86, $11, $DD, $77, $07, $3A, $A6, $71
    DB      $A7, $C2, $5A, $B5, $CD, $30, $BC, $D2
    DB      $98, $B5, $C9, $CD, $30, $BC, $D2, $64
    DB      $B5, $C9, $C3, $C8, $B5, $3E, $FF, $32
    DB      $EF, $71, $3E, $00, $32, $F1, $71, $3A
    DB      $C1, $71, $DD, $77, $0B, $A7, $CA, $80
    DB      $B5, $3E, $16, $DD, $77, $0A, $C3, $85
    DB      $B5, $3E, $17, $DD, $77, $0A, $3E, $00
    DB      $DD, $77, $10, $3E, $04, $DD, $77, $16
    DB      $CD, $30, $BC, $3E, $00, $CD, $AD, $9C
    DB      $C9, $3E, $FF, $32, $F0, $71, $DD, $7E
    DB      $0B, $FE, $FF, $CA, $AD, $B5, $3E, $17
    DB      $DD, $77, $0A, $C3, $B2, $B5, $3E, $16
    DB      $DD, $77, $0A, $3E, $06, $DD, $77, $16
    DB      $3E, $21, $DD, $77, $0F, $3E, $06, $DD
    DB      $77, $0E, $CD, $30, $BC, $DA, $C8, $B5
    DB      $C9, $3E, $00, $32, $F0, $71, $32, $F1
    DB      $71, $3E, $01, $DD, $77, $16, $CD, $30
    DB      $BC, $D2, $98, $B5, $C9, $DD, $7E, $10
    DB      $FE, $18, $CA, $33, $B6, $DD, $E5, $DD
    DB      $4E, $10, $21, $5B, $B6, $CD, $5F, $B1
    DB      $DD, $E1, $FD, $E5, $C1, $DD, $71, $11
    DB      $DD, $70, $12, $DD, $34, $10, $DD, $7E
    DB      $0B, $FE, $FF, $CA, $0D, $B6, $3E, $00
    DB      $DD, $96, $11, $DD, $77, $11, $DD, $7E
    DB      $07, $DD, $86, $11, $DD, $77, $07, $DD
    DB      $7E, $08, $DD, $86, $12, $DD, $77, $08
    DB      $CD, $30, $BC, $D2, $32, $B6, $3E, $00
    DB      $32, $EF, $71, $3E, $FF, $32, $EE, $71
    DB      $C3, $C8, $B5, $C9, $3E, $00, $32, $EF
    DB      $71, $3E, $FF, $32, $F0, $71, $3E, $00
    DB      $DD, $77, $10, $3E, $05, $DD, $77, $16
    DB      $CD, $30, $BC, $D2, $5A, $B6, $3E, $00
    DB      $32, $F0, $71, $3E, $FF, $32, $EE, $71
    DB      $C3, $C8, $B5, $C9, $01, $FF, $00, $FF
    DB      $01, $FF, $00, $FF, $01, $FF, $00, $FF
    DB      $01, $FF, $01, $FF, $00, $FF, $01, $FF
    DB      $01, $FF, $00, $FF, $01, $FF, $01, $FF
    DB      $00, $FF, $01, $FF, $01, $FF, $00, $FF
    DB      $01, $FF, $01, $FF, $01, $00, $01, $00
    DB      $01, $00, $01, $00, $CD, $30, $BC, $DA
    DB      $C8, $B5, $DD, $7E, $10, $FE, $23, $C2
    DB      $A6, $B6, $3E, $00, $DD, $77, $11, $3E
    DB      $01, $DD, $77, $12, $C3, $BF, $B6, $DD
    DB      $E5, $DD, $4E, $10, $21, $FD, $B6, $CD
    DB      $5F, $B1, $DD, $E1, $FD, $E5, $C1, $DD
    DB      $71, $11, $DD, $70, $12, $DD, $34, $10
    DB      $DD, $7E, $0B, $FE, $FF, $CA, $CF, $B6
    DB      $3E, $00, $DD, $96, $11, $DD, $77, $11
    DB      $DD, $7E, $11, $DD, $86, $07, $DD, $77
    DB      $07, $DD, $7E, $08, $DD, $86, $12, $DD
    DB      $77, $08, $CD, $30, $BC, $D2, $F4, $B6
    DB      $3E, $00, $32, $F0, $71, $3E, $FF, $32
    DB      $EE, $71, $C3, $C8, $B5, $C9, $3E, $00
    DB      $32, $F0, $71, $C3, $C8, $B5, $01, $01
    DB      $01, $00, $01, $01, $00, $01, $01, $01
    DB      $01, $01, $00, $01, $01, $01, $01, $01
    DB      $00, $01, $01, $01, $01, $01, $00, $01
    DB      $01, $01, $01, $01, $00, $01, $01, $01
    DB      $00, $01, $01, $01, $00, $01, $01, $01
    DB      $00, $01, $01, $01, $00, $01, $01, $01
    DB      $00, $01, $01, $01, $00, $01, $01, $01
    DB      $01, $01, $00, $01, $01, $01, $01, $01
    DB      $00, $01, $01, $01, $CD, $30, $BC, $DA
    DB      $C8, $B5, $DD, $34, $08, $CD, $30, $BC
    DB      $DA, $C8, $B5, $C9, $01, $87, $B1, $DD
    DB      $71, $05, $DD, $70, $06, $DD, $7E, $08
    DB      $FE, $C0, $D2, $90, $B7, $3A, $31, $70
    DB      $E6, $02, $CB, $3F, $DD, $77, $0A, $CB
    DB      $27, $4F, $06, $00, $21, $A3, $B7, $09
    DB      $4E, $23, $46, $16, $0D, $3E, $FF, $DD
    DB      $E5, $FD, $E5, $CD, $73, $9B, $FD, $E1
    DB      $DD, $E1, $DD, $35, $0C, $CA, $90, $B7
    DB      $C9, $DD, $4E, $08, $06, $00, $CB, $21
    DB      $CB, $10, $ED, $43, $F5, $71, $3E, $08
    DB      $DD, $77, $16, $C9, $F0, $03, $20, $03
    DB      $DD, $E5, $FD, $E5, $ED, $4B, $F5, $71
    DB      $16, $0D, $3E, $FF, $C5, $CD, $73, $9B
    DB      $C1, $0B, $0B, $3E, $FF, $16, $0D, $CD
    DB      $A1, $9B, $FD, $E1, $DD, $E1, $2A, $F5
    DB      $71, $01, $04, $00, $09, $22, $F5, $71
    DB      $DD, $7E, $08, $C6, $02, $DD, $77, $08
    DB      $FE, $C0, $D2, $DD, $B7, $C9, $3E, $FF
    DB      $16, $00, $DD, $E5, $FD, $E5, $CD, $73
    DB      $9B, $3E, $FF, $16, $00, $CD, $A1, $9B
    DB      $FD, $E1, $DD, $E1, $3E, $0A, $DD, $77
    DB      $16, $C9, $3A, $F3, $71, $FE, $FF, $C2
    DB      $02, $B8, $C9, $3E, $00, $DD, $77, $17
    DB      $3E, $01, $DD, $77, $16, $C9, $3E, $FF
    DB      $32, $F4, $71, $C9, $C7, $B3, $E4, $B3
    DB      $7E, $B4, $C1, $B4, $DC, $B5, $8B, $B6
    DB      $43, $B7, $53, $B7, $A7, $B7, $F9, $B7
    DB      $0D, $B8, $FA, $71, $FD, $71, $00, $72
    DB      $03, $72, $06, $72, $09, $72, $01, $0B
    DB      $3C, $66, $66, $66, $3C, $18, $18, $1B
    DB      $1F, $1F, $1B, $01, $0B, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $04, $0F, $07, $FF, $FF, $E0, $07, $FF
    DB      $FF, $E0, $06, $00, $00, $60, $06, $7C
    DB      $00, $60, $06, $6C, $00, $60, $06, $6D
    DB      $FF, $60, $06, $6D, $83, $60, $06, $6D
    DB      $83, $60, $06, $7F, $FB, $60, $06, $7D
    DB      $9B, $60, $06, $7D, $FF, $60, $06, $1F
    DB      $F8, $60, $06, $00, $00, $60, $07, $FF
    DB      $FF, $E0, $07, $FF, $FF, $E0, $04, $0F
    DB      $F0, $FF, $FF, $F0, $F0, $FF, $FF, $F0
    DB      $F0, $00, $00, $F0, $F0, $DF, $DF, $F0
    DB      $F0, $DF, $DF, $F0, $F0, $DF, $DF, $F0
    DB      $F0, $DF, $DF, $F0, $F0, $DF, $DF, $F0
    DB      $F0, $DF, $DF, $F0, $F0, $DF, $DF, $F0
    DB      $F0, $DF, $DF, $F0, $F0, $DF, $DF, $F0
    DB      $F0, $00, $00, $F0, $F0, $FF, $FF, $F0
    DB      $F0, $FF, $FF, $F0, $04, $10, $07, $FF
    DB      $FF, $E0, $07, $FF, $FF, $E0, $06, $00
    DB      $00, $60, $06, $00, $00, $60, $06, $00
    DB      $00, $60, $06, $00, $00, $60, $06, $03
    DB      $C0, $60, $06, $03, $C0, $60, $06, $03
    DB      $C0, $60, $06, $03, $C0, $60, $06, $00
    DB      $00, $60, $06, $00, $00, $60, $06, $00
    DB      $00, $60, $06, $00, $00, $60, $07, $FF
    DB      $FF, $E0, $07, $FF, $FF, $E0, $04, $10
    DB      $F0, $FF, $FF, $F0, $F0, $FF, $FF, $F0
    DB      $F0, $00, $00, $F0, $F0, $F5, $F5, $F0
    DB      $F0, $F5, $F5, $F0, $F0, $F2, $F2, $F0
    DB      $F0, $F2, $F2, $F0, $F0, $FD, $FD, $F0
    DB      $F0, $FD, $FD, $F0, $F0, $FB, $FB, $F0
    DB      $F0, $FB, $FB, $F0, $F0, $F5, $F5, $F0
    DB      $F0, $F5, $F5, $F0, $F0, $00, $00, $F0
    DB      $F0, $FF, $FF, $F0, $F0, $FF, $FF, $F0
    DB      $03, $10, $07, $FF, $E0, $07, $FF, $E0
    DB      $06, $00, $60, $06, $F0, $60, $06, $F0
    DB      $60, $06, $F0, $60, $06, $F0, $60, $06
    DB      $F0, $60, $06, $F0, $60, $06, $F0, $60
    DB      $06, $F0, $60, $06, $F0, $60, $06, $F0
    DB      $60, $06, $00, $60, $07, $FF, $E0, $07
    DB      $FF, $E0, $03, $10, $F0, $FF, $F0, $F0
    DB      $FF, $F0, $F0, $00, $F0, $F0, $2B, $F0
    DB      $F0, $2B, $F0, $F0, $2B, $F0, $F0, $2B
    DB      $F0, $F0, $2B, $F0, $F0, $2B, $F0, $F0
    DB      $2B, $F0, $F0, $2B, $F0, $F0, $2B, $F0
    DB      $F0, $2B, $F0, $F0, $00, $F0, $F0, $FF
    DB      $F0, $F0, $FF, $F0

SUB_B9B3:
    LD      IX, $720C                   ; RAM $720C
    LD      C, $08
    LD      A, $00

LOC_B9BB:
    LD      (IX+0), A
    INC     IX
    DEC     C
    JP      NZ, LOC_B9BB
    CALL    SUB_9AAF
    LD      A, ($7197)                  ; RAM $7197
    LD      C, A
    LD      HL, $A2E3
    CALL    SUB_9822
    LD      ($71A2), A                  ; RAM $71A2
    RET     

SUB_B9D5:
    LD      A, ($719A)                  ; RAM $719A
    LD      C, A
    LD      HL, $A2EC
    CALL    SUB_A2D8
    LD      ($71F9), A                  ; RAM $71F9
    AND     A
    JP      Z, LOC_BA0D
    LD      B, A
    LD      C, $00

LOC_B9E9:
    PUSH    BC
    PUSH    IX
    LD      HL, $B829
    CALL    SUB_980F
    POP     IX
    PUSH    IX
    POP     DE
    LD      (IY+1), E
    LD      (IY+2), D
    LD      A, $00
    LD      (IY+0), A
    LD      A, $04
    CALL    SUB_9807
    POP     BC
    INC     C
    DEC     B
    JP      NZ, LOC_B9E9

LOC_BA0D:
    LD      A, $0A
    LD      ($71F8), A                  ; RAM $71F8
    LD      A, $00
    LD      ($71F7), A                  ; RAM $71F7
    RET     

SUB_BA18:
    LD      HL, $71F8                   ; RAM $71F8
    INC     (HL)
    LD      A, ($71F9)                  ; RAM $71F9
    AND     A
    JP      Z, LOC_BA65
    LD      A, ($71F8)                  ; RAM $71F8
    AND     $1F
    JP      NZ, LOC_BA3C
    LD      A, ($71F7)                  ; RAM $71F7
    ADD     A, $01
    LD      HL, $71F9                   ; RAM $71F9
    CP      (HL)
    JP      C, LOC_BA39
    LD      A, $00

LOC_BA39:
    LD      ($71F7), A                  ; RAM $71F7

LOC_BA3C:
    LD      C, $00

LOC_BA3E:
    LD      HL, $B829
    CALL    SUB_980F
    LD      E, (IX+1)
    LD      D, (IX+2)
    PUSH    DE
    POP     IY
    LD      D, $00
    LD      A, ($71F7)                  ; RAM $71F7
    CP      C
    JP      NZ, LOC_BA58
    LD      D, $FF

LOC_BA58:
    PUSH    BC
    CALL    SUB_BA66
    POP     BC
    INC     C
    LD      A, ($71F9)                  ; RAM $71F9
    CP      C
    JP      NZ, LOC_BA3E

LOC_BA65:
    RET     

SUB_BA66:
    LD      A, D
    LD      ($7214), A                  ; RAM $7214
    LD      C, (IX+0)
    LD      HL, $BC2A
    PUSH    IX
    PUSH    IY
    CALL    SUB_B15F
    PUSH    IX
    POP     HL
    POP     IY
    POP     IX
    JP      (HL)
    DB      $DD, $E5, $FD, $E5, $CD, $BF, $BA, $CD
    DB      $78, $98, $FD, $E1, $DD, $E1, $C2, $B9
    DB      $BA, $DD, $E5, $FD, $E5, $CD, $AC, $83
    DB      $FD, $E1, $DD, $E1, $CD, $D7, $BA, $DD
    DB      $E5, $FD, $E5, $3E, $01, $CD, $49, $8F
    DB      $CD, $C5, $83, $FD, $E1, $DD, $E1, $3E
    DB      $08, $32, $F8, $71, $3E, $01, $DD, $77
    DB      $00, $C9, $3E, $02, $DD, $77, $00, $C9
    DB      $FD, $7E, $03, $E6, $0F, $4F, $FD, $7E
    DB      $03, $E6, $F0, $CB, $3F, $CB, $3F, $CB
    DB      $3F, $CB, $3F, $47, $21, $0C, $72, $C9
    DB      $DD, $E5, $FD, $E5, $06, $00, $FD, $4E
    DB      $01, $C5, $FD, $4E, $02, $CB, $21, $C5
    DB      $FD, $4E, $02, $21, $2B, $BB, $CD, $0F
    DB      $98, $DD, $E5, $21, $33, $BB, $CD, $0F
    DB      $98, $DD, $E5, $D1, $E1, $C1, $DD, $E1
    DB      $E5, $DD, $E5, $21, $17, $BB, $09, $4E
    DB      $23, $46, $C5, $E1, $C1, $09, $4E, $E1
    DB      $FD, $E1, $DD, $E1, $FD, $46, $00, $C9
    DB      $1F, $BB, $22, $BB, $25, $BB, $28, $BB
    DB      $1E, $5B, $98, $19, $56, $93, $19, $56
    DB      $93, $20, $5D, $9A, $35, $B8, $4F, $B8
    DB      $CB, $B8, $4F, $B9, $42, $B8, $8D, $B8
    DB      $0D, $B9, $81, $B9, $3A, $F2, $71, $47
    DB      $3A, $A6, $71, $B0, $CA, $47, $BB, $C9
    DB      $3A, $BA, $71, $E6, $01, $CA, $50, $BB
    DB      $C9, $DD, $E5, $DD, $21, $C6, $70, $3E
    DB      $00, $DD, $77, $09, $FD, $7E, $00, $CB
    DB      $27, $CB, $27, $CB, $27, $C6, $02, $DD
    DB      $77, $07, $06, $00, $FD, $4E, $02, $CB
    DB      $21, $21, $17, $BB, $09, $4E, $23, $46
    DB      $C5, $E1, $06, $00, $FD, $4E, $01, $09
    DB      $7E, $DD, $77, $08, $FD, $4E, $02, $06
    DB      $00, $21, $21, $BC, $09, $7E, $DD, $77
    DB      $0E, $21, $25, $BC, $09, $7E, $DD, $77
    DB      $0F, $FD, $E5, $FD, $21, $DE, $70, $CD
    DB      $D5, $9A, $FD, $E1, $DD, $E1, $DA, $A9
    DB      $BB, $C9, $DD, $E5, $FD, $E5, $CD, $BF
    DB      $BA, $3E, $FF, $CD, $68, $98, $CD, $AC
    DB      $83, $FD, $E1, $DD, $E1, $CD, $D7, $BA
    DB      $FD, $E5, $DD, $E5, $3E, $00, $CD, $49
    DB      $8F, $CD, $C5, $83, $DD, $E1, $FD, $E1
    DB      $21, $A2, $71, $35, $FD, $7E, $02, $FE
    DB      $00, $C2, $E5, $BB, $34, $3A, $A3, $71
    DB      $C6, $01, $27, $32, $A3, $71, $0E, $00
    DB      $FD, $7E, $02, $FE, $00, $CA, $F1, $BB
    DB      $0E, $02, $79, $CD, $11, $93, $21, $9D
    DB      $71, $3A, $A4, $71, $86, $27, $77, $23
    DB      $3A

; ============================================================
; TILE / SPRITE BITMAPS  ($BC00 - $BF6F)
; TMS9918A pattern table -- 8 bytes per tile (one byte per row).
; 110 tiles total.
; ============================================================
TILE_BITMAPS:                               ; TILE_BITMAPS: TMS9918A sprite pattern data at $BC00 (27 patterns, 8 bytes each)
    DB      $A5, $71, $8E, $27, $77, $23, $3E, $00; Tile 0: player/thief sprite frame A
    DB      $8E, $27, $77, $DD, $E5, $FD, $E5, $CD ; tile 1
    DB      $AF, $9A, $3E, $02, $CD, $AD, $9C, $FD ; tile 2
    DB      $E1, $DD, $E1, $3E, $02, $DD, $77, $00 ; tile 3
    DB      $C9, $02, $0E, $0E, $05, $0A, $10, $10 ; tile 4
    DB      $0C, $C9, $7F, $BA, $3B, $BB, $29, $BC ; tile 5
    DB      $DD, $7E, $08, $DD, $86, $0F, $3C, $4F ; tile 6
    DB      $DD, $7E, $0E, $CB, $3F, $DD, $86, $07 ; tile 7
    DB      $47, $DD, $7E, $09, $A7, $CA, $4C, $BC ; tile 8
    DB      $78, $D6, $20, $47, $DD, $E5, $C5, $CD ; tile 9
    DB      $B1, $BC, $C1, $DD, $E1, $DA, $AD, $BC ; tile 10
    DB      $79, $FE, $40, $CA, $81, $BC, $FE, $7D ; tile 11
    DB      $CA, $81, $BC, $FE, $BA, $CA, $81, $BC ; tile 12
    DB      $3A, $A6, $71, $FE, $FF, $C2, $7E, $BC ; tile 13
    DB      $79, $FE, $BB, $DA, $7E, $BC, $3E, $BA ; tile 14
    DB      $DD, $77, $08, $C3, $AD, $BC, $C3, $AF ; tile 15
    DB      $BC, $78, $FE, $F8, $D2, $AD, $BC, $79 ; tile 16
    DB      $FE, $C0, $D2, $AF, $BC, $DD, $E5, $3E ; tile 17
    DB      $01, $CD, $48, $92, $DD, $E1, $78, $FE ; tile 18
    DB      $FF, $C2, $A5, $BC, $79, $E6, $F0, $CA ; tile 19
    DB      $AF, $BC, $C3, $AD, $BC, $79, $E6, $0F ; tile 20
    DB      $FE, $01, $C2, $AF, $BC, $37, $C9, $A7 ; tile 21
    DB      $C9, $3A, $35, $72, $A7, $CA, $D1, $BC ; tile 22
    DB      $3A, $86, $70, $B9, $C2, $D1, $BC, $78 ; tile 23
    DB      $FE, $40, $DA, $D1, $BC, $FE, $C0, $D2 ; tile 24
    DB      $D1, $BC, $3E, $FF, $32, $93, $70, $37 ; tile 25
    DB      $C9, $3E, $00, $32, $93, $70, $A7, $C9 ; tile 26
    DB      $36, $70, $4E, $70, $66, $70 ; tile 27

SUB_BCDE:                                   ; SUB_BCDE: clear 8 enemy-active bytes at $7216 (IX loop with DEC C)
    LD      IX, $7216                       ; IX = $7216: enemy active-flag array
    LD      C, $08                          ; C = $08: 8 bytes to clear
    LD      A, $00                          ; A = $00: clear value

LOC_BCE6:                                   ; LOC_BCE6: (IX+0) = 0; INC IX; DEC C; loop
    LD      (IX+0), A
    INC     IX
    DEC     C
    JP      NZ, LOC_BCE6
    RET     

SUB_BCF0:                                   ; SUB_BCF0: init/position enemy objects from level table based on $719A
    LD      A, ($719A)                      ; Load $719A — current level enemy count
    LD      C, A                            ; C = A: enemy count
    LD      HL, $A65C                       ; HL = $A65C: enemy spawn-position table
    CALL    SUB_A2D8                        ; CALL SUB_A2D8: select enemy spawn data from table by level
    LD      ($7215), A                      ; $7215 = A: number of enemies to spawn
    AND     A
    JP      Z, LOC_BD5D                     ; JP Z LOC_BD5D: skip if no enemies
    LD      B, A                            ; B = A: enemy count
    LD      C, $00                          ; C = $00: enemy slot index

LOC_BD04:                                   ; LOC_BD04: for each enemy — call SUB_980F to init, store in IY record
    PUSH    BC
    PUSH    IX
    LD      HL, $BCD8
    CALL    SUB_980F
    POP     IX
    PUSH    IX
    POP     DE
    LD      (IY+12), E
    LD      (IY+13), D
    LD      A, $00
    LD      (IY+22), A
    LD      A, (IX+0)
    LD      E, A
    LD      D, $00
    LD      HL, $BD6A
    ADD     HL, DE
    LD      A, (HL)
    LD      (IY+2), A
    LD      A, $00
    LD      (IY+9), A
    LD      A, (IX+0)
    SLA     A
    LD      E, A
    LD      D, $00
    LD      HL, $BD5E
    ADD     HL, DE
    LD      A, (HL)
    LD      (IY+5), A
    INC     HL
    LD      A, (HL)
    LD      (IY+6), A
    LD      HL, $BD64
    ADD     HL, DE
    LD      A, (HL)
    LD      (IY+3), A
    INC     HL
    LD      A, (HL)
    LD      (IY+4), A
    LD      A, $05
    CALL    SUB_9807
    POP     BC
    INC     C
    DEC     B
    JP      NZ, LOC_BD04

LOC_BD5D:
    RET     
    DB      $6D, $BD, $70, $BD, $72, $BD, $74, $BD
    DB      $8C, $BD, $9C, $BD, $03, $02, $02, $0F
    DB      $02, $08, $0F, $08, $08, $0F, $7A, $BD
    DB      $80, $BD, $86, $BD, $FE, $04, $03, $03
    DB      $03, $03, $FE, $04, $04, $05, $04, $05
    DB      $FE, $F4, $06, $06, $06, $06, $96, $BD
    DB      $90, $BD, $00, $00, $07, $07, $07, $07
    DB      $00, $F2, $08, $08, $08, $08, $A0, $BD
    DB      $A6, $BD, $FC, $F4, $01, $01, $00, $00
    DB      $FC, $04, $02, $02, $02, $02

SUB_BDAC:
    LD      A, ($7215)                  ; RAM $7215
    AND     A
    JP      Z, LOC_BDD1
    LD      C, $00

LOC_BDB5:
    PUSH    BC
    LD      HL, $BCD8
    CALL    SUB_980F
    LD      E, (IX+12)
    LD      D, (IX+13)
    PUSH    DE
    POP     IY
    CALL    SUB_BDD2
    POP     BC
    INC     C
    LD      A, ($7215)                  ; RAM $7215
    CP      C
    JP      NZ, LOC_BDB5

LOC_BDD1:
    RET     

SUB_BDD2:
    LD      C, (IX+22)
    LD      HL, $C03D
    PUSH    IX
    PUSH    IY
    CALL    SUB_B15F
    PUSH    IX
    POP     HL
    POP     IY
    POP     IX
    JP      (HL)
    DB      $3E, $FF, $DD, $77, $00, $3E, $FF, $DD
    DB      $77, $01, $3E, $00, $DD, $77, $0A, $FD
    DB      $4E, $00, $06, $00, $21, $DA, $BE, $09
    DB      $7E, $DD, $77, $0B, $21, $E0, $BE, $09
    DB      $7E, $DD, $77, $0E, $21, $E3, $BE, $09
    DB      $7E, $DD, $77, $0F, $21, $E6, $BE, $09
    DB      $7E, $DD, $77, $11, $21, $E9, $BE, $09
    DB      $7E, $DD, $77, $12, $21, $DD, $BE, $09
    DB      $7E, $DD, $77, $16, $21, $D4, $BE, $DD
    DB      $E5, $FD, $E5, $CD, $5F, $B1, $DD, $E5
    DB      $E1, $FD, $E1, $DD, $E1, $CD, $71, $BE
    DB      $FD, $7E, $01, $E6, $0F, $4F, $FD, $7E
    DB      $01, $CB, $3F, $CB, $3F, $CB, $3F, $CB
    DB      $3F, $47, $21, $16, $72, $DD, $E5, $FD
    DB      $E5, $CD, $78, $98, $FD, $E1, $DD, $E1
    DB      $C2, $63, $BE, $C9, $3E, $00, $DD, $77
    DB      $01, $DD, $77, $00, $3E, $04, $DD, $77
    DB      $16, $C9, $E9, $FD, $7E, $02, $4F, $21
    DB      $CB, $BE, $06, $00, $09, $7E, $DD, $77
    DB      $08, $FD, $7E, $04, $FD, $96, $03, $CB
    DB      $3F, $FD, $86, $03, $DD, $77, $07, $3A
    DB      $96, $71, $FE, $01, $DA, $9B, $BE, $3E
    DB      $03, $DD, $77, $11, $C9, $FD, $4E, $02
    DB      $06, $00, $21, $CE, $BE, $09, $7E, $DD
    DB      $77, $08, $DD, $77, $15, $C6, $0B, $DD
    DB      $77, $17, $3E, $80, $DD, $77, $07, $C9
    DB      $FD, $4E, $02, $06, $00, $21, $D1, $BE
    DB      $09, $7E, $DD, $77, $08, $FD, $7E, $03
    DB      $DD, $77, $07, $C9, $36, $73, $B0, $2E
    DB      $6B, $A8, $33, $70, $AD, $72, $BE, $9C
    DB      $BE, $B7, $BE, $00, $00, $08, $01, $02
    DB      $03, $0B, $05, $04, $0A, $06, $0A, $02
    DB      $03, $00, $00, $00, $00, $DD, $7E, $0B
    DB      $A7, $CA, $F9, $BE, $DD, $35, $0B, $C3
    DB      $23, $BF, $FD, $4E, $00, $06, $00, $21
    DB      $DA, $BE, $09, $7E, $DD, $77, $0B, $DD
    DB      $34, $0A, $DD, $7E, $0A, $E6, $03, $DD
    DB      $77, $0A, $DD, $7E, $07, $DD, $86, $11
    DB      $DD, $77, $07, $DD, $7E, $08, $DD, $86
    DB      $12, $DD, $77, $08, $DD, $46, $07, $DD
    DB      $4E, $08, $C5, $FD, $7E, $00, $FE, $02
    DB      $C2, $3E, $BF, $3E, $02, $80, $DD, $77
    DB      $07, $3E, $02, $81, $DD, $77, $08, $FD
    DB      $E5, $FD, $21, $DE, $70, $CD, $D5, $9A
    DB      $FD, $E1, $C1, $DD, $70, $07, $DD, $71
    DB      $08, $DA, $54, $BF, $C9, $3A, $A6, $71
    DB      $FE, $FF, $CA, $B0, $BF, $3A, $F2, $71
    DB      $FE, $FF, $CA, $B0, $BF, $FD, $7E, $00
    DB      $FE, $00, $C2, $AB, $BF, $3A, $A3, $71
    DB      $A7

; ============================================================
; ZERO PADDING  ($BF70 - $BFFF)
; ============================================================
    DB      $CA, $AB, $BF, $3A, $A3, $71, $D6, $01
    DB      $27, $32, $A3, $71, $DD, $E5, $FD, $E5
    DB      $21, $16, $72, $FD, $7E, $01, $E6, $0F
    DB      $4F, $FD, $7E, $01, $CB, $3F, $CB, $3F
    DB      $CB, $3F, $CB, $3F, $47, $3E, $FF, $CD
    DB      $68, $98, $3E, $01, $CD, $11, $93, $FD
    DB      $E1, $DD, $E1, $3E, $02, $CD, $AD, $9C
    DB      $C3, $63, $BE, $3E, $FF, $32, $F2, $71
    DB      $C9, $CD, $EC, $BE, $FD, $7E, $03, $DD
    DB      $BE, $07, $D2, $C7, $BF, $FD, $7E, $04
    DB      $DD, $BE, $07, $DA, $C7, $BF, $C9, $DD
    DB      $77, $07, $3E, $00, $DD, $96, $11, $DD
    DB      $77, $11, $C9, $CD, $EC, $BE, $DD, $7E
    DB      $07, $FE, $F7, $DA, $EE, $BF, $3E, $F6
    DB      $DD, $77, $07, $3E, $00, $DD, $77, $11
    DB      $3E, $02, $DD, $77, $12, $C9, $FE, $06
    DB      $D2, $03, $C0, $3E, $06, $DD, $77, $07
    DB      $3E, $00, $DD, $77, $11, $3E, $FE, $DD
    DB      $77, $12, $C9, $DD, $7E, $08, $DD, $BE
    DB      $15, $D2, $1D, $C0, $DD, $7E, $15, $DD
    DB      $77, $08, $3E, $03, $DD, $77, $11, $3E
    DB      $00, $DD, $77, $12, $C9, $DD, $7E, $08
    DB      $DD, $BE, $17, $DA, $38, $C0, $DD, $7E
    DB      $17, $D6, $01, $DD, $77, $08, $3E, $FD
    DB      $DD, $77, $11, $3E, $00, $DD, $77, $12
    DB      $C9, $C3, $EC, $BE, $C9, $E7, $BD, $B1
    DB      $BF, $D3, $BF, $39, $C0, $3C, $C0, $1F
    DB      $72, $22, $72, $25, $72, $28, $72, $02
    DB      $37, $07, $E0, $07, $E0, $07, $E0, $07
    DB      $E0, $07, $E0, $07, $E0, $07, $E0, $07
    DB      $E0, $07, $E0, $07, $E0, $07, $E0, $07
    DB      $E0, $07, $E0, $07, $E0, $07, $E0, $07
    DB      $E0, $07, $E0, $07, $E0, $07, $E0, $00
    DB      $00, $07, $E0, $07, $E0, $07, $E0, $07
    DB      $E0, $07, $E0, $07, $E0, $07, $E0, $07
    DB      $E0, $07, $E0, $07, $E0, $07, $E0, $07
    DB      $E0, $07, $E0, $07, $E0, $07, $E0, $07
    DB      $E0, $07, $E0, $07, $E0, $37, $EC, $3F
    DB      $FC, $3F, $FC, $37, $EC, $07, $E0, $07
    DB      $E0, $0F, $F0, $0F, $F0, $0F, $F0, $0F
    DB      $F0, $07, $E0, $07, $E0, $07, $E0, $07
    DB      $E0, $07, $E0, $07, $E0, $07, $E0, $02
    DB      $37, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $02
    DB      $37, $07, $E0, $07, $E0, $07, $E0, $07
    DB      $E0, $07, $E0, $07, $E0, $07, $E0, $07
    DB      $E0, $07, $E0, $07, $E0, $07, $E0, $07
    DB      $E0, $07, $E0, $07, $E0, $07, $E0, $07
    DB      $E0, $07, $E0, $07, $E0, $07, $E0, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $02
    DB      $37, $3E, $7C, $3E, $7C, $3E, $7C, $3F ; "7>|>|>|?"
    DB      $FC, $33, $CC, $33, $CC, $33, $CC, $3F
    DB      $FC, $3E, $7C, $3E, $7C, $3E, $7C, $3F
    DB      $FC, $33, $CC, $33, $CC, $33, $CC, $3F
    DB      $FC, $3E, $7C, $3E, $7C, $3E, $7C, $3F
    DB      $FC, $33, $CC, $33, $CC, $33, $CC, $3F
    DB      $FC, $3E, $7C, $3E, $7C, $3E, $7C, $3F
    DB      $FC, $33, $CC, $33, $CC, $33, $CC, $3F
    DB      $FC, $3E, $7C, $3E, $7C, $3E, $7C, $3F
    DB      $FC, $33, $CC, $33, $CC, $33, $CC, $3F
    DB      $FC, $3E, $7C, $3E, $7C, $3E, $7C, $3F
    DB      $FC, $33, $CC, $33, $CC, $33, $CC, $3F
    DB      $FC, $3E, $7C, $3E, $7C, $3E, $7C, $3F
    DB      $FC, $33, $CC, $33, $CC, $33, $CC, $02
    DB      $37, $60, $60, $60, $60, $60, $60, $F0
    DB      $F0, $60, $60, $60, $60, $60, $60, $F0
    DB      $F0, $60, $60, $60, $60, $60, $60, $F0
    DB      $F0, $60, $60, $60, $60, $60, $60, $F0
    DB      $F0, $60, $60, $60, $60, $60, $60, $F0
    DB      $F0, $60, $60, $60, $60, $60, $60, $F0
    DB      $F0, $60, $60, $60, $60, $60, $60, $F0
    DB      $F0, $60, $60, $60, $60, $60, $60, $F0
    DB      $F0, $60, $60, $60, $60, $60, $60, $F0
    DB      $F0, $60, $60, $60, $60, $60, $60, $F0
    DB      $F0, $60, $60, $60, $60, $60, $60, $F0
    DB      $F0, $60, $60, $60, $60, $60, $60, $F0
    DB      $F0, $60, $60, $60, $60, $60, $60, $F0
    DB      $F0, $60, $60, $60, $60, $60, $60

SUB_C27F:
    LD      IX, $722B                   ; RAM $722B
    LD      C, $08
    LD      A, $00

LOC_C287:
    LD      (IX+0), A
    INC     IX
    DEC     C
    JP      NZ, LOC_C287
    RET     

SUB_C291:
    LD      A, ($719A)                  ; RAM $719A
    LD      C, A
    LD      HL, $A57C
    CALL    SUB_A2D8
    LD      ($721E), A                  ; RAM $721E
    AND     A
    JP      Z, LOC_C2C9
    LD      B, A
    LD      C, $00

LOC_C2A5:
    PUSH    BC
    PUSH    IX
    LD      HL, $C047
    CALL    SUB_980F
    POP     IX
    PUSH    IX
    POP     DE
    LD      (IY+1), E
    LD      (IY+2), D
    LD      A, $00
    LD      (IY+0), A
    LD      A, $04
    CALL    SUB_9807
    POP     BC
    INC     C
    DEC     B
    JP      NZ, LOC_C2A5

LOC_C2C9:
    RET     

SUB_C2CA:
    LD      A, ($721E)                  ; RAM $721E
    AND     A
    JP      Z, LOC_C2EF
    LD      C, $00

LOC_C2D3:
    PUSH    BC
    LD      HL, $C047
    CALL    SUB_980F
    LD      E, (IX+1)
    LD      D, (IX+2)
    PUSH    DE
    POP     IY
    CALL    SUB_C2F0
    POP     BC
    INC     C
    LD      A, ($721E)                  ; RAM $721E
    CP      C
    JP      NZ, LOC_C2D3

LOC_C2EF:
    RET     

SUB_C2F0:
    LD      C, (IX+0)
    LD      HL, $C448
    PUSH    IX
    PUSH    IY
    CALL    SUB_B15F
    PUSH    IX
    POP     HL
    POP     IY
    POP     IX
    JP      (HL)
    DB      $CD, $45, $C3, $3A, $A6, $71, $FE, $FF
    DB      $CA, $27, $C3, $DD, $E5, $FD, $E5, $CD
    DB      $2D, $C3, $CD, $78, $98, $FD, $E1, $DD
    DB      $E1, $C2, $27, $C3, $3E, $01, $DD, $77
    DB      $00, $C9, $3E, $02, $DD, $77, $00, $C9
    DB      $FD, $7E, $02, $E6, $0F, $4F, $FD, $7E
    DB      $02, $E6, $F0, $CB, $3F, $CB, $3F, $CB
    DB      $3F, $CB, $3F, $47, $21, $2B, $72, $C9
    DB      $DD, $E5, $FD, $E5, $DD, $E5, $FD, $E5
    DB      $CD, $2D, $C3, $CD, $78, $98, $FD, $E1
    DB      $DD, $E1, $FD, $E5, $E6, $01, $4F, $FD
    DB      $7E, $03, $E6, $01, $CB, $27, $B1, $4F
    DB      $C5, $21, $97, $C3, $CD, $0F, $98, $C1
    DB      $DD, $E5, $21, $9F, $C3, $CD, $0F, $98
    DB      $DD, $E5, $D1, $E1, $FD, $E1, $FD, $46
    DB      $00, $FD, $4E, $01, $C5, $E5, $21, $A7
    DB      $C3
    LD      B, $00
    ADD     HL, BC
    LD      A, (HL)
    POP     HL
    POP     BC
    LD      C, A
    LD      A, $01
    CALL    SUB_8F49
    POP     IY
    POP     IX
    RET     
    DB      $4F, $C0, $2F, $C1, $9F, $C1, $9F, $C1
    DB      $BF, $C0, $BF, $C0, $0F, $C2, $0F, $C2
    DB      $46, $46, $83, $3A, $F2, $71, $4F, $3A
    DB      $99, $71, $B1, $FE, $FF, $C2, $B8, $C3
    DB      $C9, $DD, $E5, $DD, $21, $AE, $70, $3E
    DB      $00, $DD, $77, $09, $FD, $7E, $00, $CB
    DB      $27, $CB, $27, $CB, $27, $D6, $02, $DD
    DB      $77, $07, $FD, $4E, $01, $21, $A7, $C3
    DB      $06, $00, $09, $7E, $DD, $77, $08, $3E
    DB      $12, $DD, $77, $0E, $3E, $37, $DD, $77
    DB      $0F, $FD, $E5, $FD, $21, $DE, $70, $CD
    DB      $D5, $9A, $FD, $E1, $DD, $E1, $DA, $F9
    DB      $C3, $C9, $FD, $7E, $03, $FE, $01, $CA
    DB      $08, $C4, $3A, $A3, $71, $A7, $C2, $1B
    DB      $C4, $3A, $E9, $70, $A7, $C2, $16, $C4
    DB      $21, $E5, $70, $34, $C3, $1A, $C4, $21
    DB      $E5, $70, $35, $C9, $DD, $E5, $FD, $E5
    DB      $3E, $04, $CD, $11, $93, $CD, $2D, $C3
    DB      $3E, $FF, $CD, $68, $98, $FD, $E1, $DD
    DB      $E1, $CD, $45, $C3, $3A, $A3, $71, $D6
    DB      $01, $27, $32, $A3, $71, $3E, $03, $CD
    DB      $AD, $9C, $3E, $02, $DD, $77, $00, $C9
    DB      $C9, $05, $C3, $AA, $C3, $47, $C4, $0E
    DB      $71, $26, $71, $3E, $71     ; "q&q>q"

SOUND_WRITE_C454:
    LD      A, ($719A)                  ; RAM $719A
    LD      C, A
    LD      HL, $AC09
    CALL    SUB_A2D8
    LD      ($7233), A                  ; RAM $7233
    AND     A
    JP      Z, LOC_C4D2
    LD      B, A
    LD      C, $00

LOC_C468:
    PUSH    BC
    PUSH    IX
    LD      HL, $C44E
    CALL    SUB_980F
    POP     IX
    PUSH    IX
    POP     DE
    LD      (IY+12), E
    LD      (IY+13), D
    LD      A, $FF
    LD      (IY+0), A
    LD      (IY+1), A
    LD      A, $00
    LD      (IY+22), A
    LD      A, $04
    LD      (IY+2), A
    LD      A, $00
    LD      (IY+9), A
    LD      HL, $C4D6
    LD      (IY+5), L
    LD      (IY+6), H
    LD      HL, $C4DE
    LD      (IY+3), L
    LD      (IY+4), H
    LD      A, $0A
    LD      (IY+10), A
    LD      A, $08
    LD      (IY+14), A
    LD      C, (IX+1)
    LD      B, $00
    LD      HL, $C4D3
    ADD     HL, BC
    LD      A, (HL)
    LD      (IY+8), A
    LD      A, (IX+0)
    LD      (IY+7), A
    LD      A, $01
    LD      (IY+11), A
    LD      A, $03
    CALL    SUB_9807
    POP     BC
    INC     C
    DEC     B
    JP      NZ, LOC_C468

LOC_C4D2:
    RET     
    DB      $46, $46, $83, $08, $08, $08, $08, $0F
    DB      $0F, $0F, $0F, $E6, $C4, $29, $C5, $6C
    DB      $C5, $AF, $C5, $00, $00, $00, $09, $0A
    DB      $0B, $0C, $0D, $0E, $0F, $10, $11, $12
    DB      $13, $14, $15, $16, $17, $18, $18, $18
    DB      $18, $18, $18, $18, $18, $18, $18, $18
    DB      $18, $18, $18, $18, $18, $18, $18, $18
    DB      $18, $18, $18, $18, $18, $18, $18, $18
    DB      $18, $18, $18, $18, $18, $18, $18, $18
    DB      $18, $18, $18, $18, $18, $18, $18, $18
    DB      $18, $18, $18, $18, $18, $18, $00, $10
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $09, $0A, $0B, $0C, $0D, $0E, $0F
    DB      $10, $11, $12, $13, $14, $15, $16, $17
    DB      $18, $18, $18, $18, $18, $18, $18, $18
    DB      $18, $18, $18, $18, $18, $18, $18, $18
    DB      $18, $18, $18, $18, $18, $18, $18, $18
    DB      $18, $18, $18, $18, $18, $18, $18, $18
    DB      $18, $00, $20, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $09, $0A, $0B, $0C
    DB      $0D, $0E, $0F, $10, $11, $12, $13, $14
    DB      $15, $16, $17, $18, $18, $18, $18, $18
    DB      $18, $18, $18, $18, $18, $18, $18, $18
    DB      $18, $18, $18, $18, $00, $30, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $09
    DB      $0A, $0B, $0C, $0D, $0E, $0F, $10, $11
    DB      $12, $13, $14, $15, $16, $17, $18

SUB_C5F2:
    LD      A, ($7233)                  ; RAM $7233
    AND     A
    JP      NZ, LOC_C5FA
    RET     

LOC_C5FA:
    LD      C, $00

LOC_C5FC:
    PUSH    BC
    LD      HL, $C44E
    CALL    SUB_980F
    LD      A, ($7031)                  ; RAM $7031
    AND     $04
    SRL     A
    LD      C, A
    LD      B, $00
    LD      HL, $C624
    ADD     HL, BC
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    LD      (IX+5), C
    LD      (IX+6), B
    POP     BC
    INC     C
    LD      A, ($7233)                  ; RAM $7233
    CP      C
    JP      NZ, LOC_C5FC
    RET     
    DB      $D6, $C4, $DA, $C4

SUB_C628:
    LD      A, ($7233)                  ; RAM $7233
    AND     A
    JP      Z, LOC_C64D
    LD      C, $00

LOC_C631:
    PUSH    BC
    LD      HL, $C44E
    CALL    SUB_980F
    LD      E, (IX+12)
    LD      D, (IX+13)
    PUSH    DE
    POP     IY
    CALL    SUB_C64E
    POP     BC
    INC     C
    LD      A, ($7233)                  ; RAM $7233
    CP      C
    JP      NZ, LOC_C631

LOC_C64D:
    RET     

SUB_C64E:
    LD      C, (IX+22)
    LD      HL, $C6EA
    PUSH    IX
    PUSH    IY
    CALL    SUB_B15F
    PUSH    IX
    POP     HL
    POP     IY
    POP     IX
    JP      (HL)
    DB      $CD, $8B, $C6, $DD, $35, $0B, $CA, $6D
    DB      $C6, $C9, $FD, $46, $02, $3A, $96, $71
    DB      $FE, $01, $DA, $82, $C6, $CB, $38, $78
    DB      $FE, $04, $D2, $82, $C6, $06, $04, $DD
    DB      $70, $0B, $3E, $01, $DD, $77, $16, $C9
    DB      $3A, $31, $70, $E6, $02, $C2, $B8, $C6
    DB      $DD, $E5, $FD, $E5, $DD, $7E, $0A, $DD
    DB      $77, $0F, $FD, $21, $DE, $70, $CD, $D5
    DB      $9A, $FD, $E1, $DD, $E1, $D2, $B8, $C6
    DB      $3A, $A6, $71, $FE, $FF, $CA, $B8, $C6
    DB      $3E, $FF, $32, $F2, $71, $C9, $CD, $8B
    DB      $C6, $DD, $7E, $0A, $C6, $04, $DD, $77
    DB      $0A, $FE, $38, $D2, $CA, $C6, $C9, $3E
    DB      $38, $DD, $77, $0A, $3E, $02, $DD, $77
    DB      $16, $C9, $CD, $8B, $C6, $DD, $35, $0A
    DB      $DD, $7E, $0A, $FE, $0A, $CA, $E4, $C6
    DB      $C9, $3E, $00, $DD, $77, $16, $C9, $63
    DB      $C6, $B9, $C6, $D5, $C6, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $FC, $F0, $C0, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $FC, $F0
    DB      $C0, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $3F, $3C, $30, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $3F, $3C, $30
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $0F, $0F, $0C, $00, $C0, $00, $00, $00
    DB      $00, $00, $00, $00, $0F, $0F, $0C, $00
    DB      $C0, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $03
    DB      $03, $03, $00, $F0, $C0, $00, $00, $00
    DB      $00, $00, $00, $03, $03, $03, $00, $F0
    DB      $C0, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $3F, $3C, $30, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $3C, $30
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $0F, $0F, $0C, $00, $C0, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $0C, $00
    DB      $C0, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $03
    DB      $03, $03, $00, $F0, $C0, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $F0
    DB      $C0, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $FC, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $FC, $F0
    DB      $C0, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $3F, $3C, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $3F, $3C, $30
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $0F, $0F, $0C, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $0F, $0F, $0C, $00
    DB      $C0, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $03
    DB      $03, $03, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $03, $03, $03, $00, $F0
    DB      $C0, $00, $00, $00, $00, $02, $02, $02
    DB      $02, $02, $02, $02, $02, $02, $6B, $C8
    DB      $71, $C8, $77, $C8, $7D, $C8, $83, $C8
    DB      $89, $C8, $8F, $C8, $95, $C8, $9B, $C8
    DB      $00, $00, $09, $0D, $0E, $0F, $F0, $08
    DB      $09, $0A, $0B, $0C, $E0, $10, $09, $0A
    DB      $0B, $0C, $D0, $18, $09, $0A, $0B, $0C
    DB      $C0, $20, $09, $0A, $0B, $0C, $B0, $28
    DB      $09, $0A, $0B, $0C, $A0, $30, $09, $0A
    DB      $0B, $0C, $90, $38, $10, $11, $12, $13
    DB      $80, $40, $09, $0A, $0B, $0C

SOUND_WRITE_C8A1:
    LD      A, $00
    LD      ($7234), A                  ; RAM $7234
    LD      A, ($719A)                  ; RAM $719A
    LD      C, A
    LD      HL, $ACB4
    CALL    SUB_A2D8
    AND     A
    JP      Z, LOC_C92D
    LD      B, A
    LD      C, $00

LOC_C8B7:
    PUSH    BC
    LD      A, (IX+0)
    CP      $00
    JP      NZ, LOC_C922
    PUSH    IX
    POP     DE
    LD      IY, $70F6                   ; RAM $70F6
    LD      (IY+12), E
    LD      (IY+13), D
    LD      A, $FF
    LD      (IY+0), A
    LD      (IY+1), A
    LD      ($7234), A                  ; RAM $7234
    LD      A, $00
    LD      (IY+22), A
    LD      A, $08
    LD      (IY+2), A
    LD      A, $00
    LD      (IY+9), A
    LD      HL, $C850
    LD      (IY+5), L
    LD      (IY+6), H
    LD      HL, $C859
    LD      (IY+3), L
    LD      (IY+4), H
    LD      A, $00
    LD      (IY+10), A
    LD      C, (IX+2)
    LD      B, $00
    LD      HL, $C92E
    ADD     HL, BC
    LD      A, (HL)
    SUB     $09
    LD      (IY+8), A
    LD      A, (IX+1)
    SLA     A
    SLA     A
    SLA     A
    SUB     $06
    LD      (IY+7), A
    POP     BC
    CALL    SUB_C94D
    JP      LOC_C92D

LOC_C922:
    LD      A, $05
    CALL    SUB_9807
    POP     BC
    INC     C
    DEC     B
    JP      NZ, LOC_C8B7

LOC_C92D:
    RET     
    DB      $40, $40, $7D               ; "@@}"

SOUND_WRITE_C931:
    LD      A, ($7234)                  ; RAM $7234
    CP      $FF
    JP      NZ, LOC_C94C
    CALL    SUB_CB55
    LD      IX, $70F6                   ; RAM $70F6
    LD      E, (IX+12)
    LD      D, (IX+13)
    PUSH    DE
    POP     IY
    CALL    SUB_CB96

LOC_C94C:
    RET     

SUB_C94D:
    LD      A, $01
    LD      B, $09
    LD      C, $0B
    LD      DE, $3800
    LD      HL, $C6F0
    CALL    SUB_81C2
    LD      IX, $70F6                   ; RAM $70F6
    LD      E, (IX+12)
    LD      D, (IX+13)
    PUSH    DE
    POP     IY
    CALL    SUB_C973
    CALL    SUB_CA68
    CALL    SUB_C9A0
    RET     

SUB_C973:
    PUSH    IX
    PUSH    IY
    LD      A, (IY+1)
    SUB     $07
    LD      B, A
    LD      C, $0B

LOC_C97F:
    PUSH    BC
    LD      E, (IY+2)
    LD      D, $00
    LD      HL, $CAD9
    ADD     HL, DE
    LD      C, (HL)
    LD      A, $00
    LD      DE, $CB4D
    LD      HL, $CB4D
    CALL    SUB_8F49
    POP     BC
    INC     B
    DEC     C
    JP      NZ, LOC_C97F
    POP     IY
    POP     IX
    RET     

SUB_C9A0:
    PUSH    IX
    PUSH    IY
    LD      C, (IY+2)
    LD      B, $00
    LD      HL, $CAD9
    ADD     HL, BC
    LD      A, (HL)
    SUB     $10
    LD      ($7001), A                  ; RAM $7001
    LD      A, (IY+1)
    DEC     A
    LD      (WORK_BUFFER), A            ; WORK_BUFFER
    LD      A, ($7001)                  ; RAM $7001
    LD      C, A
    DEC     C
    LD      A, (WORK_BUFFER)            ; WORK_BUFFER
    ADD     A, $02
    LD      B, A
    PUSH    BC
    LD      A, $01
    LD      DE, $CB19
    LD      HL, $CB14
    CALL    SUB_8F49
    POP     BC
    INC     C
    PUSH    BC
    LD      A, $01
    LD      DE, $CB19
    LD      HL, $CB14
    CALL    SUB_8F49
    POP     BC
    INC     C
    INC     B
    INC     B
    LD      HL, $CB21
    CALL    SUB_CA52
    LD      C, $00
    LD      B, $3D

LOC_C9ED:
    PUSH    BC
    LD      A, C
    AND     $03
    LD      C, A
    LD      HL, $CAF8
    CALL    SUB_B15F
    PUSH    IX
    POP     HL
    LD      A, (WORK_BUFFER)            ; WORK_BUFFER
    LD      B, A
    LD      A, ($7001)                  ; RAM $7001
    LD      C, A
    LD      A, $01
    LD      DE, $CB10
    CALL    SUB_8F49
    POP     BC
    INC     C
    LD      A, C
    AND     $03
    JP      NZ, LOC_CA17
    LD      HL, WORK_BUFFER             ; WORK_BUFFER
    DEC     (HL)

LOC_CA17:
    LD      HL, $7001                   ; RAM $7001
    INC     (HL)
    DEC     B
    JP      NZ, LOC_C9ED
    LD      A, (WORK_BUFFER)            ; WORK_BUFFER
    SUB     $01
    LD      B, A
    LD      A, ($7001)                  ; RAM $7001
    SUB     $01
    LD      C, A
    LD      A, $01
    LD      DE, $CB19
    LD      HL, $CB14
    PUSH    BC
    CALL    SUB_8F49
    POP     BC
    INC     C
    LD      A, $01
    LD      DE, $CB19
    LD      HL, $CB14
    PUSH    BC
    CALL    SUB_8F49
    POP     BC
    INC     C
    LD      HL, $CB1E
    CALL    SUB_CA52
    POP     IY
    POP     IX
    RET     

SUB_CA52:
    LD      E, $0F

LOC_CA54:
    PUSH    BC
    PUSH    DE
    PUSH    HL
    LD      DE, $CB24
    LD      A, $01
    CALL    SUB_8F49
    POP     HL
    POP     DE
    POP     BC
    INC     C
    DEC     E
    JP      NZ, LOC_CA54
    RET     

SUB_CA68:
    PUSH    IX
    PUSH    IY
    LD      A, (IY+1)
    LD      (WORK_BUFFER), A            ; WORK_BUFFER
    LD      C, (IY+2)
    LD      HL, $CAD9
    CALL    SUB_B171
    LD      ($7001), A                  ; RAM $7001
    LD      C, $00
    LD      B, $3D

LOC_CA82:
    PUSH    BC
    LD      A, C
    AND     $03
    LD      C, A
    LD      HL, $CB27
    CALL    SUB_B15F
    PUSH    IX
    POP     HL
    LD      A, ($7001)                  ; RAM $7001
    LD      C, A
    LD      A, (WORK_BUFFER)            ; WORK_BUFFER
    LD      B, A
    LD      DE, $CB47
    LD      A, $01
    CALL    SUB_8F49
    POP     BC
    INC     C
    LD      A, C
    AND     $03
    JP      NZ, LOC_CAAC
    LD      HL, WORK_BUFFER             ; WORK_BUFFER
    DEC     (HL)

LOC_CAAC:
    LD      HL, $7001                   ; RAM $7001
    INC     (HL)
    DEC     B
    JP      NZ, LOC_CA82
    POP     IY
    PUSH    IY
    LD      B, (IY+1)
    INC     B
    INC     B
    PUSH    BC
    LD      C, (IY+2)
    LD      HL, $CAD9
    CALL    SUB_B171
    POP     BC
    LD      C, A
    LD      A, $01
    LD      DE, $CAEA
    LD      HL, $CADC
    CALL    SUB_8F49
    POP     IY
    POP     IX
    RET     
    DB      $40, $40, $7D, $02, $06, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $02, $06, $D0, $D0, $D0, $D0, $D0
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $00
    DB      $CB, $04, $CB, $08, $CB, $0C, $CB, $02
    DB      $01, $00, $0F, $02, $01, $00, $3C, $02
    DB      $01, $00, $F0, $02, $01, $03, $C0, $02
    DB      $01, $D0, $D0, $03, $01, $FF, $FF, $FF
    DB      $03, $01, $D0, $D0, $D0, $01, $01, $E0
    DB      $01, $01, $07, $01, $01, $D0, $2F, $CB
    DB      $35, $CB, $3B, $CB, $41, $CB, $04, $01
    DB      $00, $FF, $FF, $FF, $04, $01, $03, $FF
    DB      $FF, $FC, $04, $01, $0F, $FF, $FF, $F0
    DB      $04, $01, $3F, $FF, $FF, $C0, $04, $01
    DB      $D1, $D0, $D0, $D0, $01, $06, $00, $00
    DB      $00, $00, $00, $00

SUB_CB55:
    LD      IX, $70F6                   ; RAM $70F6
    LD      E, (IX+12)
    LD      D, (IX+13)
    PUSH    DE
    POP     IY
    LD      A, ($7031)                  ; RAM $7031
    AND     $01
    JP      NZ, LOC_CB95
    LD      A, (IY+3)
    CP      $00
    JP      NZ, LOC_CB85
    INC     (IX+10)
    LD      A, (IX+10)
    CP      $04
    JP      NZ, LOC_CB95
    LD      A, $00
    LD      (IX+10), A
    JP      LOC_CB95

LOC_CB85:
    DEC     (IX+10)
    LD      A, (IX+10)
    CP      $FF
    JP      NZ, LOC_CB95
    LD      A, $03
    LD      (IX+10), A

LOC_CB95:
    RET     

SUB_CB96:
    LD      C, (IX+22)
    LD      HL, $CD1E
    PUSH    IX
    PUSH    IY
    CALL    SUB_B15F
    PUSH    IX
    POP     HL
    POP     IY
    POP     IX
    JP      (HL)
    DB      $3A, $BD, $71, $A7, $C2, $E5, $CB, $3A
    DB      $EF, $71, $A7, $C2, $E5, $CB, $3A, $EE
    DB      $71, $A7, $C2, $E5, $CB, $3A, $F0, $71
    DB      $A7, $C2, $E5, $CB, $3A, $F2, $71, $A7
    DB      $C2, $E5, $CB, $3A, $F1, $71, $A7, $CA
    DB      $E5, $CB, $CD, $E6, $CB, $DA, $E5, $CB
    DB      $3E, $FF, $32, $F3, $71, $3E, $01, $DD
    DB      $77, $16, $C9, $FD, $4E, $03, $21, $FB
    DB      $CB, $DD, $E5, $FD, $E5, $CD, $5F, $B1
    DB      $DD, $E5, $E1, $FD, $E1, $DD, $E1, $E9
    DB      $FF, $CB, $44, $CC, $3A, $E9, $70, $FE
    DB      $FF, $C2, $42, $CC, $FD, $4E, $02, $06
    DB      $00, $21, $99, $CC, $09, $3A, $ED, $70
    DB      $3C, $4F, $7E, $91, $4F, $3A, $E6, $70
    DB      $B9, $C2, $42, $CC, $CD, $89, $CC, $FD
    DB      $7E, $01, $D6, $0F, $CB, $27, $CB, $27
    DB      $CB, $27, $B9, $C2, $42, $CC, $3E, $00
    DB      $32, $E8, $70, $3E, $02, $DD, $77, $11
    DB      $3E, $FF, $DD, $77, $12, $A7, $C9, $37
    DB      $C9, $3A, $E9, $70, $FE, $00, $C2, $87
    DB      $CC, $FD, $4E, $02, $06, $00, $21, $D9
    DB      $CA, $09, $3A, $ED, $70, $3C, $4F, $7E
    DB      $91, $4F, $3A, $E6, $70, $B9, $C2, $87
    DB      $CC, $CD, $89, $CC, $FD, $7E, $01, $CB
    DB      $27, $CB, $27, $CB, $27, $C6, $04, $B9
    DB      $C2, $87, $CC, $3E, $01, $32, $E8, $70
    DB      $3E, $FE, $DD, $77, $11, $3E, $01, $DD
    DB      $77, $12, $A7, $C9, $37, $C9, $3A, $E5
    DB      $70, $4F, $3A, $E7, $70, $A7, $CA, $98
    DB      $CC, $79, $D6, $20, $4F, $C9, $7D, $7D
    DB      $BA, $0E, $03, $FD, $7E, $03, $FE, $00
    DB      $CA, $A8, $CC, $0E, $00, $DD, $7E, $0A
    DB      $B9, $C2, $BC, $CC, $3A, $31, $70, $E6
    DB      $01, $C2, $BC, $CC, $3E, $02, $DD, $77
    DB      $16, $C9, $3A, $31, $70, $E6, $01, $C2
    DB      $FA, $CC, $3A, $E5, $70, $DD, $86, $11
    DB      $32, $E5, $70, $3A, $E6, $70, $57, $21
    DB      $1B, $CD, $FD, $7E, $03, $FE, $00, $C2
    DB      $E0, $CC, $21, $18, $CD, $FD, $4E, $02
    DB      $06, $00, $09, $3A, $ED, $70, $3C, $4F
    DB      $7E, $91, $BA, $CA, $FB, $CC, $3A, $E6
    DB      $70, $DD, $86, $12, $32, $E6, $70, $C9
    DB      $DD, $E5, $FD, $E5, $DD, $21, $DE, $70
    DB      $CD, $30, $BC, $FD, $E1, $DD, $E1, $D2
    DB      $17, $CD, $3E, $00, $32, $F3, $71, $3E
    DB      $00, $DD, $77, $16, $C9, $40, $40, $7D
    DB      $7D, $7D, $BA, $AB, $CB, $9C, $CC, $BD
    DB      $CC

SUB_CD24:
    LD      (WORK_BUFFER), A            ; WORK_BUFFER
    LD      A, C
    LD      ($7001), A                  ; RAM $7001
    LD      A, (WORK_BUFFER)            ; WORK_BUFFER
    CP      $00
    JP      Z, LOC_CD69
    PUSH    DE
    LD      HL, $7001                   ; RAM $7001
    LD      C, (HL)

LOC_CD38:
    PUSH    BC
    PUSH    DE
    LD      A, D
    CALL    SUB_CDAC
    PUSH    HL
    POP     IX
    LD      A, E
    CALL    SUB_CDAC
    PUSH    HL
    POP     IY
    PUSH    IX
    PUSH    IY
    LD      BC, $0010
    ADD     IY, BC
    CALL    SUB_CDD2
    POP     IY
    POP     IX
    LD      BC, $0010
    ADD     IX, BC
    CALL    SUB_CDD2
    POP     DE
    POP     BC
    INC     D
    INC     E
    DEC     C
    JP      NZ, LOC_CD38
    POP     DE

LOC_CD69:
    LD      HL, $7001                   ; RAM $7001
    LD      C, (HL)
    LD      A, E
    CALL    SUB_CDAC

LOC_CD71:
    PUSH    BC
    LD      C, $08
    LD      A, (WORK_BUFFER)            ; WORK_BUFFER
    CP      $01
    JP      NZ, LOC_CD7E
    LD      C, $20

LOC_CD7E:
    PUSH    BC
    PUSH    HL
    PUSH    HL
    PUSH    HL
    POP     DE
    LD      A, $01
    CALL    SUB_8430
    LD      A, $02
    CALL    SUB_8430
    LD      A, B
    CALL    DELAY_LOOP_CE03
    POP     DE
    LD      B, A
    PUSH    BC
    LD      A, $01
    CALL    SUB_83FE
    POP     BC
    LD      A, $02
    CALL    SUB_83FE
    POP     HL
    POP     BC
    INC     HL
    DEC     C
    JP      NZ, LOC_CD7E
    POP     BC
    DEC     C
    JP      NZ, LOC_CD71
    RET     

SUB_CDAC:
    PUSH    BC
    LD      C, A
    LD      B, $00
    SLA     C
    RL      B
    SLA     C
    RL      B
    SLA     C
    RL      B
    LD      A, (WORK_BUFFER)            ; WORK_BUFFER
    CP      $00
    JP      Z, LOC_CDCC
    SLA     C
    RL      B
    SLA     C
    RL      B

LOC_CDCC:
    LD      HL, $3800
    ADD     HL, BC
    POP     BC
    RET     

SUB_CDD2:
    LD      C, $10

LOC_CDD4:
    PUSH    BC
    PUSH    IX
    PUSH    IY
    PUSH    IX
    POP     DE
    LD      A, $01
    PUSH    IY
    CALL    SUB_8430
    LD      A, $02
    CALL    SUB_8430
    POP     DE
    PUSH    BC
    LD      A, $01
    CALL    SUB_83FE
    POP     BC
    LD      A, $02
    CALL    SUB_83FE
    POP     IY
    POP     IX
    POP     BC
    INC     IX
    INC     IY
    DEC     C
    JP      NZ, LOC_CDD4
    RET     

DELAY_LOOP_CE03:
    PUSH    BC
    LD      B, $08

LOC_CE06:
    SRL     A
    RL      C
    DJNZ    LOC_CE06
    LD      A, C
    POP     BC
    RET     
    DB      $C9

SOUND_WRITE_CE10:
    LD      A, $00
    LD      ($7235), A                  ; RAM $7235
    LD      A, ($719A)                  ; RAM $719A
    LD      C, A
    LD      HL, $ACB4
    CALL    SUB_A2D8
    AND     A
    JP      Z, LOC_CE64
    LD      B, A
    LD      C, $00

LOC_CE26:
    PUSH    BC
    LD      A, (IX+0)
    CP      $01
    JP      NZ, LOC_CE59
    PUSH    IX
    POP     DE
    LD      IY, $707E                   ; RAM $707E
    LD      (IY+12), E
    LD      (IY+13), D
    LD      A, $FF
    LD      ($7235), A                  ; RAM $7235
    LD      A, $00
    LD      (IY+21), A
    LD      C, (IX+1)
    LD      B, $00
    LD      HL, $CE65
    ADD     HL, BC
    LD      A, (HL)
    LD      (IY+8), A
    CALL    SUB_CFA8
    JP      LOC_CE64

LOC_CE59:
    LD      A, $05
    CALL    SUB_9807
    POP     BC
    INC     C
    DEC     B
    JP      NZ, LOC_CE26

LOC_CE64:
    RET     
    DB      $40, $7D, $BA

SOUND_WRITE_CE68:
    LD      A, ($7235)                  ; RAM $7235
    CP      $FF
    JP      NZ, LOC_CF3D
    LD      A, ($7031)                  ; RAM $7031
    AND     $02
    JP      NZ, LOC_CF3D
    LD      IX, $707E                   ; RAM $707E
    LD      E, (IX+12)
    LD      D, (IX+13)
    PUSH    DE
    POP     IY
    LD      A, (IX+10)
    INC     A
    AND     $03
    LD      (IX+10), A
    LD      C, A
    LD      A, (IY+2)
    CP      $01
    JP      Z, LOC_CEEA
    PUSH    IX
    PUSH    IY
    LD      B, (IX+8)
    PUSH    BC
    LD      HL, $CF3E
    CALL    SUB_B15F
    PUSH    IX
    POP     HL
    POP     BC
    PUSH    BC
    LD      C, B
    LD      A, $01
    LD      B, $08
    LD      DE, $CF96
    CALL    SUB_8F49
    POP     BC
    PUSH    BC
    LD      HL, $CF46
    CALL    SUB_B15F
    PUSH    IX
    POP     HL
    POP     BC
    LD      A, $05
    ADD     A, B
    LD      C, A
    LD      B, $08
    LD      DE, $CF96
    LD      A, $01
    CALL    SUB_8F49
    LD      A, ($7093)                  ; RAM $7093
    AND     A
    JP      Z, LOC_CEDE
    LD      A, ($70E5)                  ; RAM $70E5
    ADD     A, $02
    LD      ($70E5), A                  ; RAM $70E5

LOC_CEDE:
    LD      A, $00
    LD      ($7093), A                  ; RAM $7093
    POP     IY
    POP     IX
    JP      LOC_CF3D

LOC_CEEA:
    PUSH    IX
    PUSH    IY
    LD      B, (IX+8)
    PUSH    BC
    LD      HL, $CF46
    CALL    SUB_B15F
    PUSH    IX
    POP     HL
    POP     BC
    PUSH    BC
    LD      C, B
    LD      A, $01
    LD      B, $08
    LD      DE, $CF96
    CALL    SUB_8F49
    POP     BC
    PUSH    BC
    LD      HL, $CF3E
    CALL    SUB_B15F
    PUSH    IX
    POP     HL
    POP     BC
    LD      A, $05
    ADD     A, B
    LD      C, A
    LD      B, $08
    LD      DE, $CF96
    LD      A, $01
    CALL    SUB_8F49
    LD      A, ($7093)                  ; RAM $7093
    AND     A
    JP      Z, LOC_CF31
    LD      A, ($70E5)                  ; RAM $70E5
    ADD     A, $FE
    LD      ($70E5), A                  ; RAM $70E5

LOC_CF31:
    LD      A, $00
    LD      ($7093), A                  ; RAM $7093
    POP     IY
    POP     IX
    JP      LOC_CF3D

LOC_CF3D:
    RET     
    DB      $84, $CF, $72, $CF, $60, $CF, $4E, $CF
    DB      $4E, $CF, $60, $CF, $72, $CF, $84, $CF
    DB      $10, $01, $3F, $3F, $3F, $3F, $3F, $3F
    DB      $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F ; "????????"
    DB      $3F, $3F, $10, $01, $FC, $FC, $FC, $FC
    DB      $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
    DB      $FC, $FC, $FC, $FC, $10, $01, $F3, $F3
    DB      $F3, $F3, $F3, $F3, $F3, $F3, $F3, $F3
    DB      $F3, $F3, $F3, $F3, $F3, $F3, $10, $01
    DB      $CF, $CF, $CF, $CF, $CF, $CF, $CF, $CF
    DB      $CF, $CF, $CF, $CF, $CF, $CF, $CF, $CF
    DB      $10, $01, $20, $20, $20, $20, $20, $20
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20

SUB_CFA8:
    LD      IX, $707E                   ; RAM $707E
    LD      E, (IX+12)
    LD      D, (IX+13)
    PUSH    DE
    POP     IY
    CALL    SUB_D00E
    CALL    SUB_CFBC
    RET     

SUB_CFBC:
    PUSH    IX
    PUSH    IY
    LD      A, (IX+8)
    SUB     $10
    LD      C, A
    LD      B, $06
    LD      D, $14

LOC_CFCA:
    PUSH    BC
    PUSH    DE
    LD      A, $01
    LD      DE, $D04C
    LD      HL, $D048
    CALL    SUB_8F49
    POP     DE
    POP     BC
    INC     B
    DEC     D
    JP      NZ, LOC_CFCA
    INC     C
    INC     C
    LD      D, $0E

LOC_CFE2:
    PUSH    BC
    PUSH    DE
    LD      A, $01
    LD      B, $06
    LD      DE, $D053
    LD      HL, $D050
    CALL    SUB_8F49
    POP     DE
    POP     BC
    PUSH    BC
    PUSH    DE
    LD      A, $01
    LD      B, $19
    LD      DE, $D053
    LD      HL, $D050
    CALL    SUB_8F49
    POP     DE
    POP     BC
    INC     C
    DEC     D
    JP      NZ, LOC_CFE2
    POP     IY
    POP     IX
    RET     

SUB_D00E:
    PUSH    IX
    PUSH    IY
    LD      C, (IX+8)
    INC     C
    LD      B, $08
    LD      D, $08

LOC_D01A:
    PUSH    BC
    PUSH    DE
    LD      A, $01
    LD      DE, $D03E
    LD      HL, $D034
    CALL    SUB_8F49
    POP     DE
    POP     BC
    INC     B
    INC     B
    DEC     D
    JP      NZ, LOC_D01A
    POP     IY
    POP     IX
    RET     
    DB      $02, $04, $FF, $FF, $80, $01, $80, $01
    DB      $FF, $FF, $02, $04, $F0, $F0, $FD, $FD
    DB      $FD, $FD, $F0, $F0, $01, $02, $FF, $FF
    DB      $01, $02, $40, $40, $01, $01, $3C, $01
    DB      $01, $B0, $04, $04, $04, $04, $04, $04
    DB      $68, $D0, $71, $D0, $7A, $D0, $83, $D0
    DB      $8C, $D0, $95, $D0, $00, $00, $01, $02
    DB      $03, $04, $05, $06, $00, $10, $00, $08
    DB      $09, $0A, $0B, $0C, $0D, $00, $00, $10
    DB      $01, $02, $03, $04, $05, $06, $00, $10
    DB      $10, $08, $09, $0A, $0B, $0C, $0D, $00
    DB      $00, $20, $0F, $10, $11, $12, $13, $14
    DB      $00, $10, $20, $16, $17, $18, $3B, $3C
    DB      $3D, $00

SOUND_WRITE_D09E:
    LD      A, $00
    LD      ($7236), A                  ; RAM $7236
    LD      A, ($719A)                  ; RAM $719A
    LD      C, A
    LD      HL, $ACB4
    CALL    SUB_A2D8
    AND     A
    JP      Z, LOC_D1B7
    LD      B, A
    LD      C, $00

LOC_D0B4:
    PUSH    BC
    LD      A, (IX+0)
    CP      $02
    JP      NZ, LOC_D1AC
    LD      A, $FF
    LD      ($7036), A                  ; RAM $7036
    LD      ($704E), A                  ; RAM $704E
    LD      ($7066), A                  ; RAM $7066
    LD      ($710E), A                  ; RAM $710E
    LD      ($7126), A                  ; RAM $7126
    LD      ($713E), A                  ; RAM $713E
    LD      ($7037), A                  ; RAM $7037
    LD      ($704F), A                  ; RAM $704F
    LD      ($7067), A                  ; RAM $7067
    LD      ($710F), A                  ; RAM $710F
    LD      ($7127), A                  ; RAM $7127
    LD      ($713F), A                  ; RAM $713F
    LD      ($7236), A                  ; RAM $7236
    LD      A, $00
    LD      ($7040), A                  ; RAM $7040
    LD      ($7058), A                  ; RAM $7058
    LD      ($7070), A                  ; RAM $7070
    LD      ($7118), A                  ; RAM $7118
    LD      ($7130), A                  ; RAM $7130
    LD      ($7148), A                  ; RAM $7148
    LD      A, $00
    LD      ($704C), A                  ; RAM $704C
    LD      A, $00
    LD      ($7038), A                  ; RAM $7038
    LD      ($7050), A                  ; RAM $7050
    LD      ($7068), A                  ; RAM $7068
    LD      A, $06
    LD      ($7110), A                  ; RAM $7110
    LD      ($7128), A                  ; RAM $7128
    LD      ($7140), A                  ; RAM $7140
    LD      A, $00
    LD      ($703F), A                  ; RAM $703F
    LD      ($7057), A                  ; RAM $7057
    LD      ($706F), A                  ; RAM $706F
    LD      ($7117), A                  ; RAM $7117
    LD      ($712F), A                  ; RAM $712F
    LD      ($7147), A                  ; RAM $7147
    LD      A, $D0
    LD      ($703C), A                  ; RAM $703C
    LD      ($7054), A                  ; RAM $7054
    LD      ($706C), A                  ; RAM $706C
    LD      ($7114), A                  ; RAM $7114
    LD      ($712C), A                  ; RAM $712C
    LD      ($7144), A                  ; RAM $7144
    LD      A, $56
    LD      ($703B), A                  ; RAM $703B
    LD      ($7053), A                  ; RAM $7053
    LD      ($706B), A                  ; RAM $706B
    LD      ($7113), A                  ; RAM $7113
    LD      ($712B), A                  ; RAM $712B
    LD      ($7143), A                  ; RAM $7143
    LD      A, $D0
    LD      ($703A), A                  ; RAM $703A
    LD      ($7052), A                  ; RAM $7052
    LD      ($706A), A                  ; RAM $706A
    LD      ($7112), A                  ; RAM $7112
    LD      ($712A), A                  ; RAM $712A
    LD      ($7142), A                  ; RAM $7142
    LD      A, $5C
    LD      ($7039), A                  ; RAM $7039
    LD      ($7051), A                  ; RAM $7051
    LD      ($7069), A                  ; RAM $7069
    LD      ($7111), A                  ; RAM $7111
    LD      ($7129), A                  ; RAM $7129
    LD      ($7141), A                  ; RAM $7141
    LD      A, $6C
    LD      ($703D), A                  ; RAM $703D
    LD      ($7055), A                  ; RAM $7055
    LD      ($706D), A                  ; RAM $706D
    LD      ($7115), A                  ; RAM $7115
    LD      ($712D), A                  ; RAM $712D
    LD      ($7145), A                  ; RAM $7145
    LD      A, $1B
    LD      ($703E), A                  ; RAM $703E
    LD      ($7116), A                  ; RAM $7116
    LD      A, $58
    LD      ($7056), A                  ; RAM $7056
    LD      ($712E), A                  ; RAM $712E
    LD      A, $95
    LD      ($706E), A                  ; RAM $706E
    LD      ($7146), A                  ; RAM $7146
    CALL    SUB_D1C8
    POP     BC
    JP      LOC_D1B7

LOC_D1AC:
    LD      A, $05
    CALL    SUB_9807
    POP     BC
    INC     C
    DEC     B
    JP      NZ, LOC_D0B4

LOC_D1B7:
    RET     

SOUND_WRITE_D1B8:
    LD      A, ($7236)                  ; RAM $7236
    CP      $FF
    JP      NZ, LOC_D1C7
    LD      IX, $7036                   ; RAM $7036
    CALL    SUB_D2AF

LOC_D1C7:
    RET     

SUB_D1C8:
    LD      B, $01
    LD      C, $10
    LD      D, $00
    LD      E, $06
    LD      IX, $D297
    LD      IY, $D29D
    CALL    SUB_D460
    LD      B, $08
    LD      C, $10
    LD      D, $00
    LD      E, $06
    LD      IX, $D2A3
    LD      IY, $D2A9
    CALL    SUB_D460
    LD      B, $0F
    LD      C, $05
    LD      D, $00
    LD      E, $06
    LD      IX, $D297
    LD      IY, $D29D
    CALL    SUB_D460
    LD      B, $16
    LD      C, $05
    LD      D, $00
    LD      E, $03
    LD      IX, $D2A3
    LD      IY, $D2A9
    CALL    SUB_D460
    LD      B, $3B
    LD      C, $05
    LD      D, $03
    LD      E, $03
    LD      IX, $D2A3
    LD      IY, $D2A9
    CALL    SUB_D460
    LD      C, $17
    LD      B, $05
    CALL    SUB_D252
    LD      C, $1B
    LD      B, $25
    CALL    SUB_D267
    LD      C, $46
    LD      B, $12
    CALL    SUB_D252
    LD      C, $58
    LD      B, $25
    CALL    SUB_D267
    LD      C, $83
    LD      B, $12
    CALL    SUB_D252
    LD      C, $95
    LD      B, $25
    CALL    SUB_D267
    RET     

SUB_D252:
    PUSH    BC
    LD      B, $0C
    LD      DE, $D285
    LD      HL, $D27C
    LD      A, $01
    CALL    SUB_8F49
    POP     BC
    INC     C
    DEC     B
    JP      NZ, SUB_D252
    RET     

SUB_D267:
    PUSH    BC
    LD      B, $0C
    LD      DE, $D285
    LD      HL, $D28E
    LD      A, $01
    CALL    SUB_8F49
    POP     BC
    INC     C
    DEC     B
    JP      NZ, SUB_D267
    RET     
    DB      $07, $01, $00, $FF, $FF, $FF, $FF, $FF
    DB      $00, $07, $01, $A0, $A0, $A0, $A0, $A0
    DB      $A0, $A0, $07, $01, $00, $FF, $00, $00
    DB      $00, $FF, $00, $0F, $0F, $0F, $0F, $0F
    DB      $0C, $FF, $FC, $F0, $C0, $00, $00, $FF
    DB      $3F, $0F, $03, $00, $00, $F0, $F0, $F0
    DB      $F0, $F0, $30

SUB_D2AF:
    LD      C, (IX+22)
    LD      HL, $D456
    PUSH    IX
    PUSH    IY
    CALL    SUB_B15F
    PUSH    IX
    POP     HL
    POP     IY
    POP     IX
    JP      (HL)
    DB      $3A, $A6, $71, $FE, $FF, $C2, $DC, $D2
    DB      $3A, $E5, $70, $FE, $7D, $D2, $5F, $D3
    DB      $3E, $00, $DD, $77, $0B, $C3, $24, $D3
    DB      $DD, $E5, $3E, $00, $CD, $AA, $8C, $DD
    DB      $E1, $FE, $FF, $CA, $5F, $D3, $FE, $01
    DB      $DA, $5F, $D3, $FE, $04, $D2, $5F, $D3
    DB      $3D, $4F, $06, $00, $21, $60, $D3, $09
    DB      $7E, $DD, $77, $0B, $DD, $E5, $3E, $00
    DB      $CD, $D2, $8C, $DD, $E1, $3A, $E5, $70
    DB      $FE, $71, $DA, $5F, $D3, $FE, $83, $D2
    DB      $5F, $D3, $3A, $EE, $71, $A7, $CA, $5F
    DB      $D3, $3A, $F2, $71, $A7, $C2, $5F, $D3
    DB      $DD, $4E, $0B, $06, $00, $21, $63, $D3
    DB      $09, $3A, $ED, $70, $4F, $0C, $3A, $E6
    DB      $70, $81, $BE, $CA, $5F, $D3, $21, $63
    DB      $D3, $0E, $00, $BE, $CA, $48, $D3, $23
    DB      $0C, $C3, $3F, $D3, $DD, $71, $0C, $3E
    DB      $FF, $32, $F3, $71, $3A, $E9, $70, $EE
    DB      $FF, $E6, $01, $32, $E8, $70, $3E, $01
    DB      $DD, $77, $16, $C9, $02, $01, $00, $40
    DB      $7D, $BA, $3A, $31, $70, $E6, $02, $C2
    DB      $95, $D3, $DD, $E5, $CB, $21, $06, $00
    DB      $21, $C6, $D3, $09, $5E, $23, $56, $D5
    DB      $DD, $E1, $21, $CC, $D3, $09, $5E, $23
    DB      $56, $D5, $FD, $E1, $DD, $34, $0A, $FD
    DB      $34, $0A, $FD, $7E, $0A, $FE, $06, $DD
    DB      $E1, $C9, $3A, $31, $70, $E6, $02, $C2
    DB      $C5, $D3, $DD, $E5, $CB, $21, $06, $00
    DB      $21, $C6, $D3, $09, $5E, $23, $56, $D5
    DB      $DD, $E1, $21, $CC, $D3, $09, $5E, $23
    DB      $56, $D5, $FD, $E1, $DD, $35, $0A, $FD
    DB      $35, $0A, $FD, $7E, $0A, $FE, $00, $DD
    DB      $E1, $C9, $36, $70, $4E, $70, $66, $70
    DB      $0E, $71, $26, $71, $3E, $71, $DD, $4E
    DB      $0C, $CD, $66, $D3, $CA, $DC, $D3, $C9
    DB      $3E, $02, $DD, $77, $16, $3E, $00, $32
    DB      $10, $71, $32, $28, $71, $32, $40, $71
    DB      $3E, $06, $32, $38, $70, $32, $50, $70
    DB      $32, $68, $70, $C9, $DD, $4E, $0C, $CD
    DB      $96, $D3, $CA, $02, $D4, $C9, $DD, $4E
    DB      $0B, $06, $00, $21, $63, $D3, $09, $3A
    DB      $ED, $70, $3C, $4F, $7E, $91, $32, $E6
    DB      $70, $3E, $03, $DD, $77, $16, $C9, $DD
    DB      $4E, $0B, $CD, $66, $D3, $CA, $25, $D4
    DB      $C9, $3E, $04, $DD, $77, $16, $3E, $06
    DB      $32, $10, $71, $32, $28, $71, $32, $40
    DB      $71, $3E, $00, $32, $38, $70, $32, $50
    DB      $70, $32, $68, $70, $C9, $DD, $4E, $0B
    DB      $CD, $96, $D3, $CA, $4B, $D4, $C9, $3E
    DB      $00, $32, $F3, $71, $3E, $00, $DD, $77
    DB      $16, $C9, $C4, $D2, $D2, $D3, $F8, $D3
    DB      $1B, $D4, $41, $D4

SUB_D460:
    LD      HL, WORK_BUFFER             ; WORK_BUFFER
    LD      (HL), C
    PUSH    DE
    PUSH    IX
    PUSH    IY
    LD      C, B
    LD      B, $00
    SLA     C
    RL      B
    SLA     C
    RL      B
    SLA     C
    RL      B
    SLA     C
    RL      B
    SLA     C
    RL      B
    LD      HL, $3800
    ADD     HL, BC
    PUSH    HL
    POP     DE
    LD      A, $01
    CALL    SUB_83FE
    POP     IY
    POP     IX
    POP     DE

LOC_D490:
    PUSH    IX
    POP     HL
    CALL    SUB_D4A2
    PUSH    IY
    POP     HL
    CALL    SUB_D4A2
    INC     D
    DEC     E
    JP      NZ, LOC_D490
    RET     

SUB_D4A2:
    PUSH    DE
    PUSH    IX
    PUSH    IY
    LD      C, D
    LD      B, $00
    ADD     HL, BC
    LD      C, $00

LOC_D4AD:
    PUSH    BC
    PUSH    HL
    LD      B, (HL)
    LD      A, (WORK_BUFFER)            ; WORK_BUFFER
    LD      D, A
    LD      A, C
    CP      D
    JP      C, LOC_D4BB
    LD      B, $00

LOC_D4BB:
    LD      A, $02
    CALL    SUB_83FE
    POP     HL
    POP     BC
    INC     C
    LD      A, $10
    CP      C
    JP      NZ, LOC_D4AD
    POP     IY
    POP     IX
    POP     DE
    RET     

SUB_D4CF:
    LD      A, ($723D)                  ; RAM $723D
    AND     A
    JP      NZ, LOC_D501

LOC_D4D6:
    LD      A, ($723B)                  ; RAM $723B
    LD      B, A
    LD      DE, $723C                   ; RAM $723C
    LD      A, $14
    LD      HL, $D522
    CALL    SOUND_WRITE_D528
    JP      NC, LOC_D520
    LD      HL, ($7239)                 ; RAM $7239
    INC     HL
    INC     HL
    LD      ($7239), HL                 ; RAM $7239
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    PUSH    BC
    POP     HL
    LD      A, H
    CP      $00
    JP      NZ, LOC_D513
    LD      A, L
    CP      $00
    JP      NZ, LOC_D508

LOC_D501:
    LD      A, $FF
    LD      ($723D), A                  ; RAM $723D
    SCF     
    RET     

LOC_D508:
    LD      HL, ($7237)                 ; RAM $7237
    LD      ($7239), HL                 ; RAM $7239
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    PUSH    BC
    POP     HL

LOC_D513:
    LD      IX, $D522
    LD      DE, $723C                   ; RAM $723C
    CALL    SUB_D601
    JP      LOC_D4D6

LOC_D520:
    AND     A
    RET     
    DB      $3F, $72, $42, $72, $45, $72 ; "?rBrEr"

SOUND_WRITE_D528:
    LD      IY, (WORK_BUFFER)           ; WORK_BUFFER
    PUSH    IY
    LD      (WORK_BUFFER), A            ; WORK_BUFFER
    LD      A, (DE)
    INC     A
    CP      B
    JP      NZ, LOC_D539
    LD      A, $00

LOC_D539:
    LD      (DE), A
    LD      ($7001), A                  ; RAM $7001
    LD      D, $FF
    LD      C, $00

LOC_D541:
    PUSH    BC
    PUSH    HL
    PUSH    DE
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    PUSH    DE
    POP     IX
    LD      E, (IX+0)
    LD      D, (IX+1)
    PUSH    DE
    POP     IY
    POP     DE
    LD      A, (IY+0)
    AND     (IY+1)
    PUSH    AF
    AND     D
    LD      D, A
    POP     AF
    PUSH    DE
    CP      $FF
    JP      Z, LOC_D585
    LD      A, ($7001)                  ; RAM $7001
    AND     A
    JP      NZ, LOC_D585
    DEC     (IX+2)
    JP      NZ, LOC_D585
    LD      DE, $0004
    ADD     IY, DE
    PUSH    IY
    POP     DE
    LD      (IX+0), E
    LD      (IX+1), D
    LD      A, (IY+2)
    LD      (IX+2), A

LOC_D585:
    LD      E, C
    LD      C, (IY+0)
    LD      B, (IY+1)
    LD      D, $09
    LD      A, B
    CP      $FF
    JP      NZ, LOC_D599
    LD      BC, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER
    LD      D, $00

LOC_D599:
    CALL    SOUND_WRITE_D5BD
    POP     DE
    POP     HL
    POP     BC
    INC     HL
    INC     HL
    INC     C
    LD      A, $03
    CP      C
    JP      NZ, LOC_D541
    LD      A, D
    CP      $FF
    JP      Z, LOC_D5B2
    AND     A
    JP      LOC_D5B6

LOC_D5B2:
    SCF     
    JP      LOC_D5B6

LOC_D5B6:
    POP     IY
    LD      (WORK_BUFFER), IY           ; WORK_BUFFER
    RET     

SOUND_WRITE_D5BD:
    PUSH    DE
    SLA     E
    LD      D, $00
    LD      HL, $D5DD
    ADD     HL, DE
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    PUSH    DE
    POP     HL
    POP     DE
    LD      E, $00
    LD      A, ($723E)                  ; RAM $723E
    CP      $FF
    JP      NZ, LOC_D5D9
    LD      DE, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER

LOC_D5D9:
    LD      A, (WORK_BUFFER)            ; WORK_BUFFER
    JP      (HL)
    DB      $73, $9B, $A1, $9B, $CF, $9B

SUB_D5E3:
    LD      ($723B), A                  ; RAM $723B
    LD      A, $00
    LD      ($723D), A                  ; RAM $723D
    LD      ($7237), HL                 ; RAM $7237
    LD      ($7239), HL                 ; RAM $7239
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    PUSH    BC
    POP     HL
    LD      IX, $D522
    LD      DE, $723C                   ; RAM $723C
    CALL    SUB_D601
    RET     

SUB_D601:
    LD      A, $00
    LD      (DE), A
    LD      D, $03

LOC_D606:
    LD      C, (IX+0)
    INC     IX
    LD      B, (IX+0)
    INC     IX
    PUSH    BC
    POP     IY
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    INC     HL
    PUSH    IX
    PUSH    BC
    POP     IX
    LD      (IY+0), C
    LD      (IY+1), B
    LD      A, (IX+2)
    LD      (IY+2), A
    POP     IX
    DEC     D
    JP      NZ, LOC_D606
    RET     
    DB      $A9, $D6, $A9, $D6, $D5, $D6, $A9, $D6
    DB      $FD, $D6, $25, $D7, $63, $D7, $63, $D7
    DB      $A3, $D7, $63, $D7, $A9, $D7, $11, $D8
    DB      $63, $D7, $63, $D7, $A3, $D7, $63, $D7
    DB      $A9, $D7, $E9, $D7, $51, $D8, $51, $D8
    DB      $D9, $D8, $51, $D8, $61, $D9, $D9, $D8
    DB      $51, $D8, $E9, $D9, $51, $D8, $51, $D8
    DB      $D9, $D8, $51, $D8, $61, $D9, $D9, $D8
    DB      $51, $D8, $E9, $D9, $05, $DA, $05, $DA
    DB      $05, $DA, $05, $DA, $8F, $DA, $8F, $DA
    DB      $05, $DA, $05, $DA, $19, $DB, $8F, $DA
    DB      $05, $DA, $A3, $DB, $05, $DA, $05, $DA
    DB      $05, $DA, $05, $DA, $8F, $DA, $8F, $DA
    DB      $05, $DA, $05, $DA, $19, $DB, $8F, $DA
    DB      $05, $DA, $A3, $DB, $01, $00, $F5, $DB
    DB      $00, $00, $AF, $D6, $D1, $D6, $D3, $D6
    DB      $BC, $03, $0C, $00, $F6, $02, $0C, $00
    DB      $7E, $02, $0C, $00, $38, $02, $0C, $00
    DB      $18, $02, $0C, $00, $38, $02, $0C, $00
    DB      $7E, $02, $0C, $00, $F6, $02, $0C, $00
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $DB, $D6
    DB      $D1, $D6, $D3, $D6, $CC, $02, $0C, $00
    DB      $38, $02, $0C, $00, $DE, $01, $0C, $00
    DB      $A9, $01, $0C, $00, $92, $01, $0C, $00
    DB      $A9, $01, $0C, $00, $DE, $01, $0C, $00
    DB      $38, $02, $0C, $00, $FF, $FF, $03, $D7
    DB      $D1, $D6, $D3, $D6, $7E, $02, $0C, $00
    DB      $FA, $01, $0C, $00, $A9, $01, $0C, $00
    DB      $FA, $01, $0C, $00, $7E, $02, $0C, $00
    DB      $CC, $02, $0C, $00, $F6, $02, $0C, $00
    DB      $53, $03, $0C, $00, $FF, $FF, $2B, $D7
    DB      $41, $D7, $D3, $D6, $BC, $03, $0C, $00
    DB      $F6, $02, $0C, $00, $7E, $02, $0C, $00
    DB      $38, $02, $0C, $00, $BC, $03, $0C, $00
    DB      $FF, $FF, $00, $FF, $30, $00, $00, $FF
    DB      $18, $00, $00, $FF, $04, $00, $00, $FF
    DB      $04, $00, $C9, $00, $04, $00, $BD, $00
    DB      $04, $00, $9F, $00, $04, $00, $8E, $00
    DB      $04, $00, $FF, $FF, $AF, $D6, $69, $D7
    DB      $D3, $D6, $77, $00, $06, $00, $EF, $00
    DB      $06, $00, $00, $FF, $0C, $00, $EF, $00
    DB      $06, $00, $00, $FF, $06, $00, $00, $FF
    DB      $06, $00, $EF, $00, $06, $00, $00, $FF
    DB      $18, $00, $00, $FF, $04, $00, $00, $FF
    DB      $04, $00, $C9, $00, $04, $00, $BD, $00
    DB      $04, $00, $9F, $00, $04, $00, $8E, $00
    DB      $04, $00, $FF, $FF, $DB, $D6, $69, $D7
    DB      $D3, $D6, $03, $D7, $AF, $D7, $D3, $D6
    DB      $6A, $00, $06, $00, $D4, $00, $06, $00
    DB      $00, $FF, $0C, $00, $D4, $00, $06, $00
    DB      $00, $FF, $06, $00, $00, $FF, $06, $00
    DB      $D4, $00, $06, $00, $00, $FF, $18, $00
    DB      $00, $FF, $04, $00, $00, $FF, $04, $00
    DB      $C9, $00, $04, $00, $BD, $00, $04, $00
    DB      $9F, $00, $04, $00, $8E, $00, $04, $00
    DB      $FF, $FF, $2B, $D7, $EF, $D7, $D3, $D6
    DB      $77, $00, $06, $00, $EF, $00, $06, $00
    DB      $00, $FF, $0C, $00, $EF, $00, $06, $00
    DB      $00, $FF, $06, $00, $00, $FF, $06, $00
    DB      $77, $00, $06, $00, $00, $FF, $30, $00
    DB      $FF, $FF, $2B, $D7, $17, $D8, $D3, $D6
    DB      $77, $00, $06, $00, $EF, $00, $06, $00
    DB      $00, $FF, $0C, $00, $EF, $00, $06, $00
    DB      $00, $FF, $06, $00, $00, $FF, $06, $00
    DB      $77, $00, $06, $00, $00, $FF, $18, $00
    DB      $00, $FF, $04, $00, $00, $FF, $04, $00
    DB      $C9, $00, $04, $00, $BD, $00, $04, $00
    DB      $9F, $00, $04, $00, $8E, $00, $04, $00
    DB      $FF, $FF, $57, $D8, $D1, $D6, $D3, $D6
    DB      $BC, $03, $03, $00, $00, $FF, $03, $00
    DB      $BC, $03, $03, $00, $00, $FF, $03, $00
    DB      $DE, $01, $03, $00, $00, $FF, $03, $00
    DB      $BC, $03, $03, $00, $00, $FF, $03, $00
    DB      $BC, $03, $03, $00, $00, $FF, $03, $00
    DB      $18, $02, $03, $00, $00, $FF, $03, $00
    DB      $BC, $03, $03, $00, $00, $FF, $03, $00
    DB      $BC, $03, $03, $00, $00, $FF, $03, $00
    DB      $38, $02, $03, $00, $00, $FF, $03, $00
    DB      $BC, $03, $03, $00, $00, $FF, $03, $00
    DB      $BC, $03, $03, $00, $00, $FF, $03, $00
    DB      $7E, $02, $03, $00, $00, $FF, $03, $00
    DB      $BC, $03, $03, $00, $00, $FF, $03, $00
    DB      $BC, $03, $03, $00, $00, $FF, $03, $00
    DB      $F6, $02, $03, $00, $00, $FF, $03, $00
    DB      $CC, $02, $03, $00, $00, $FF, $03, $00
    DB      $FF, $FF, $DF, $D8, $D1, $D6, $D3, $D6
    DB      $CC, $02, $03, $00, $00, $FF, $03, $00
    DB      $CC, $02, $03, $00, $00, $FF, $03, $00
    DB      $66, $01, $03, $00, $00, $FF, $03, $00
    DB      $CC, $02, $03, $00, $00, $FF, $03, $00
    DB      $CC, $02, $03, $00, $00, $FF, $03, $00
    DB      $92, $01, $03, $00, $00, $FF, $03, $00
    DB      $CC, $02, $03, $00, $00, $FF, $03, $00
    DB      $CC, $02, $03, $00, $00, $FF, $03, $00
    DB      $A9, $01, $03, $00, $00, $FF, $03, $00
    DB      $CC, $02, $03, $00, $00, $FF, $03, $00
    DB      $CC, $02, $03, $00, $00, $FF, $03, $00
    DB      $DE, $01, $03, $00, $00, $FF, $03, $00
    DB      $CC, $02, $03, $00, $00, $FF, $03, $00
    DB      $CC, $02, $03, $00, $00, $FF, $03, $00
    DB      $38, $02, $03, $00, $00, $FF, $03, $00
    DB      $18, $02, $03, $00, $00, $FF, $03, $00
    DB      $FF, $FF, $67, $D9, $D1, $D6, $D3, $D6
    DB      $7E, $02, $03, $00, $00, $FF, $03, $00
    DB      $7E, $02, $03, $00, $00, $FF, $03, $00
    DB      $3F, $01, $03, $00, $00, $FF, $03, $00
    DB      $7E, $02, $03, $00, $00, $FF, $03, $00
    DB      $7E, $02, $03, $00, $00, $FF, $03, $00
    DB      $66, $01, $03, $00, $00, $FF, $03, $00
    DB      $7E, $02, $03, $00, $00, $FF, $03, $00
    DB      $7E, $02, $03, $00, $00, $FF, $03, $00
    DB      $7B, $01, $03, $00, $00, $FF, $03, $00
    DB      $7E, $02, $03, $00, $00, $FF, $03, $00
    DB      $7E, $02, $03, $00, $00, $FF, $03, $00
    DB      $A9, $01, $03, $00, $00, $FF, $03, $00
    DB      $7E, $02, $03, $00, $00, $FF, $03, $00
    DB      $7E, $02, $03, $00, $00, $FF, $03, $00
    DB      $FA, $01, $03, $00, $00, $FF, $03, $00
    DB      $DE, $01, $03, $00, $00, $FF, $03, $00
    DB      $FF, $FF, $EF, $D9, $D1, $D6, $D3, $D6
    DB      $BC, $03, $06, $00, $00, $FF, $06, $00
    DB      $00, $FF, $0C, $00, $00, $FF, $18, $00
    DB      $00, $FF, $30, $00, $FF, $FF, $0B, $DA
    DB      $4D, $DA, $D3, $D6, $BC, $03, $06, $00
    DB      $00, $FF, $06, $00, $BC, $03, $06, $00
    DB      $00, $FF, $06, $00, $BC, $03, $06, $00
    DB      $00, $FF, $06, $00, $BC, $03, $06, $00
    DB      $00, $FF, $06, $00, $BC, $03, $06, $00
    DB      $00, $FF, $06, $00, $BC, $03, $06, $00
    DB      $00, $FF, $06, $00, $BC, $03, $06, $00
    DB      $00, $FF, $06, $00, $BC, $03, $06, $00
    DB      $00, $FF, $06, $00, $FF, $FF, $3F, $01
    DB      $06, $00, $7B, $01, $06, $00, $DE, $01
    DB      $06, $00, $1C, $01, $06, $00, $66, $01
    DB      $06, $00, $DE, $01, $06, $00, $0C, $01
    DB      $06, $00, $3F, $01, $06, $00, $DE, $01
    DB      $06, $00, $1C, $01, $06, $00, $66, $01
    DB      $06, $00, $DE, $01, $06, $00, $0C, $01
    DB      $06, $00, $3F, $01, $06, $00, $1C, $01
    DB      $06, $00, $66, $01, $06, $00, $FF, $FF
    DB      $95, $DA, $D7, $DA, $D3, $D6, $CC, $02
    DB      $06, $00, $00, $FF, $06, $00, $CC, $02
    DB      $06, $00, $00, $FF, $06, $00, $CC, $02
    DB      $06, $00, $00, $FF, $06, $00, $CC, $02
    DB      $06, $00, $00, $FF, $06, $00, $CC, $02
    DB      $06, $00, $00, $FF, $06, $00, $CC, $02
    DB      $06, $00, $00, $FF, $06, $00, $CC, $02
    DB      $06, $00, $00, $FF, $06, $00, $CC, $02
    DB      $06, $00, $00, $FF, $06, $00, $FF, $FF
    DB      $EF, $00, $06, $00, $1C, $01, $06, $00
    DB      $66, $01, $06, $00, $D4, $00, $06, $00
    DB      $0C, $01, $06, $00, $66, $01, $06, $00
    DB      $C9, $00, $06, $00, $EF, $00, $06, $00
    DB      $66, $01, $06, $00, $D4, $00, $06, $00
    DB      $0C, $01, $06, $00, $66, $01, $06, $00
    DB      $C9, $00, $06, $00, $EF, $00, $06, $00
    DB      $D4, $00, $06, $00, $0C, $01, $06, $00
    DB      $FF, $FF, $1F, $DB, $61, $DB, $D3, $D6
    DB      $7E, $02, $06, $00, $00, $FF, $06, $00
    DB      $7E, $02, $06, $00, $00, $FF, $06, $00
    DB      $7E, $02, $06, $00, $00, $FF, $06, $00
    DB      $7E, $02, $06, $00, $00, $FF, $06, $00
    DB      $7E, $02, $06, $00, $00, $FF, $06, $00
    DB      $7E, $02, $06, $00, $00, $FF, $06, $00
    DB      $7E, $02, $06, $00, $00, $FF, $06, $00
    DB      $7E, $02, $06, $00, $00, $FF, $06, $00
    DB      $FF, $FF, $D4, $00, $06, $00, $FD, $00
    DB      $06, $00, $3F, $01, $06, $00, $BD, $00
    DB      $06, $00, $EF, $00, $06, $00, $3F, $01
    DB      $06, $00, $B3, $00, $06, $00, $D4, $00
    DB      $06, $00, $3F, $01, $06, $00, $BD, $00
    DB      $06, $00, $EF, $00, $06, $00, $3F, $01
    DB      $06, $00, $B3, $00, $06, $00, $D4, $00
    DB      $06, $00, $BD, $00, $06, $00, $EF, $00
    DB      $06, $00, $FF, $FF, $A9, $DB, $CF, $DB
    DB      $D3, $D6, $BC, $03, $06, $00, $00, $FF
    DB      $06, $00, $BC, $03, $06, $00, $00, $FF
    DB      $06, $00, $BC, $03, $06, $00, $00, $FF
    DB      $06, $00, $BC, $03, $06, $00, $00, $FF
    DB      $06, $00, $00, $FF, $30, $00, $FF, $FF
    DB      $3F, $01, $06, $00, $7B, $01, $06, $00
    DB      $DE, $01, $06, $00, $EF, $00, $06, $00
    DB      $3F, $01, $06, $00, $DE, $01, $06, $00
    DB      $EF, $00, $06, $00, $00, $FF, $06, $00
    DB      $00, $FF, $30, $00, $FF, $FF, $FB, $DB
    DB      $25, $DC, $D3, $D6, $3F, $01, $0C, $00
    DB      $EF, $00, $0C, $00, $3F, $01, $0C, $00
    DB      $52, $01, $0C, $00, $EF, $00, $0C, $00
    DB      $52, $01, $0C, $00, $66, $01, $0C, $00
    DB      $EF, $00, $0C, $00, $66, $01, $0C, $00
    DB      $7B, $01, $54, $00, $FF, $FF, $7B, $01
    DB      $0C, $00, $00, $FF, $0C, $00, $7B, $01
    DB      $0C, $00, $92, $01, $0C, $00, $00, $FF
    DB      $0C, $00, $92, $01, $0C, $00, $A9, $01
    DB      $0C, $00, $00, $FF, $0C, $00, $A9, $01
    DB      $0C, $00, $DE, $01, $54, $00, $FF, $FF

SOUND_WRITE_DC4F:
    LD      A, $00
    LD      ($7033), A                  ; RAM $7033
    CALL    SOUND_WRITE_83C5

LOC_DC57:
    LD      A, ($7249)                  ; RAM $7249
    CP      $FF
    JP      NZ, LOC_DC57
    CALL    SOUND_WRITE_83AC
    LD      A, $FF
    LD      ($7033), A                  ; RAM $7033
    LD      A, $FF
    LD      DE, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER
    CALL    SOUND_WRITE_9B73
    LD      A, $FF
    LD      DE, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER
    CALL    SOUND_WRITE_9BA1
    LD      A, $FF
    LD      DE, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER
    CALL    SOUND_WRITE_9BCF
    LD      A, $00
    LD      ($7248), A                  ; RAM $7248
    RET     

SUB_DC85:
    CALL    SOUND_WRITE_DC8C
    CALL    SOUND_WRITE_DC4F
    RET     

SOUND_WRITE_DC8C:
    LD      A, $FF
    LD      ($7248), A                  ; RAM $7248
    LD      A, $00
    LD      ($7249), A                  ; RAM $7249
    LD      ($71F2), A                  ; RAM $71F2
    LD      A, $FF
    CALL    SOUND_WRITE_8E03
    CALL    SUB_84CE
    CALL    SUB_DCE8
    CALL    SOUND_WRITE_B20E
    CALL    SOUND_WRITE_B257
    LD      A, $98
    LD      ($70E6), A                  ; RAM $70E6
    LD      A, $00
    LD      ($70E7), A                  ; RAM $70E7
    LD      A, $21
    LD      ($70E5), A                  ; RAM $70E5
    LD      A, $00
    LD      ($71BC), A                  ; RAM $71BC
    LD      ($71C0), A                  ; RAM $71C0
    LD      ($71C2), A                  ; RAM $71C2
    LD      ($7198), A                  ; RAM $7198
    LD      ($719B), A                  ; RAM $719B
    LD      ($719C), A                  ; RAM $719C
    LD      ($7199), A                  ; RAM $7199
    LD      ($71F2), A                  ; RAM $71F2
    LD      A, $FF
    LD      ($71C1), A                  ; RAM $71C1
    LD      A, $00
    LD      ($724A), A                  ; RAM $724A
    LD      A, $BA
    LD      ($724B), A                  ; RAM $724B
    LD      A, $00
    CALL    SOUND_WRITE_8E03
    RET     

SUB_DCE8:
    CALL    SUB_9042
    LD      A, ($7197)                  ; RAM $7197
    PUSH    AF
    LD      A, ($719A)                  ; RAM $719A
    PUSH    AF
    LD      A, $00
    LD      ($7197), A                  ; RAM $7197
    LD      A, $08
    LD      ($719A), A                  ; RAM $719A
    CALL    SUB_AD5F
    POP     AF
    LD      ($719A), A                  ; RAM $719A
    POP     AF
    LD      ($7197), A                  ; RAM $7197
    LD      B, $40
    LD      C, $00
    CALL    SUB_DD24
    LD      B, $7D
    LD      C, $46
    CALL    SUB_DD24
    LD      B, $BA
    LD      C, $83
    CALL    SUB_DD24
    CALL    SUB_DD3A
    CALL    SUB_DD6B
    RET     

SUB_DD24:
    PUSH    BC
    LD      B, $0D
    LD      DE, $DDCF
    LD      HL, $DDC8
    LD      A, $01
    CALL    SUB_8F49
    POP     BC
    INC     C
    LD      A, C
    CP      B
    JP      NZ, SUB_DD24
    RET     

SUB_DD3A:
    LD      C, $00

LOC_DD3C:
    PUSH    BC
    LD      B, $0E
    LD      DE, $DDD6
    LD      HL, $DDD6
    LD      A, $01
    CALL    SUB_8F49
    POP     BC
    INC     C
    LD      A, C
    CP      $C0
    JP      NZ, LOC_DD3C
    LD      B, $0E
    LD      C, $BB

LOC_DD56:
    PUSH    BC
    LD      DE, $DDEC
    LD      HL, $DDDB
    LD      A, $01
    CALL    SUB_8F49
    POP     BC
    DEC     C
    LD      A, C
    CP      $B9
    JP      NZ, LOC_DD56
    RET     

SUB_DD6B:
    LD      B, $00
    LD      C, $00

LOC_DD6F:
    PUSH    BC
    LD      A, $01
    LD      DE, $DDA6
    LD      HL, $DD84
    CALL    SUB_8F49
    POP     BC
    INC     C
    LD      A, C
    CP      $07
    JP      NZ, LOC_DD6F
    RET     
    DB      $20, $01, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $F0
    DB      $00, $00, $00, $0F, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $20, $01, $2D, $2D, $2D, $2D
    DB      $2D, $2D, $2D, $2D, $2D, $2D, $2D, $2D ; "--------"
    DB      $2D, $2D, $00, $00, $00, $2D, $2D, $2D
    DB      $2D, $2D, $2D, $2D, $2D, $2D, $2D, $2D ; "--------"
    DB      $2D, $2D, $2D, $2D, $05, $01, $0F, $00
    DB      $00, $00, $F0, $05, $01, $D0, $D0, $D0
    DB      $D0, $D0, $03, $01, $00, $00, $00, $03
    DB      $05, $3F, $FF, $FC, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $3F, $FF, $FC, $00, $FF, $00
    DB      $03, $05, $41, $41, $41, $40, $40, $40
    DB      $40, $40, $40, $40, $40, $40, $20, $20 ; "@@@@@@  "
    DB      $20

SUB_DDFD:
    CALL    SUB_DE07
    CALL    SOUND_WRITE_B289
    CALL    SUB_856C
    RET     

SUB_DE07:
    LD      A, ($724A)                  ; RAM $724A
    SLA     A
    LD      C, A
    LD      B, $00
    LD      HL, $DE87
    ADD     HL, BC
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    PUSH    BC
    POP     HL
    JP      (HL)
    DB      $3A, $E7, $70, $FE, $FF, $CA, $29, $DE
    DB      $3A, $E5, $70, $FE, $78, $CA, $2A, $DE
    DB      $C9, $3E, $01, $32, $4A, $72, $3E, $00
    DB      $32, $E8, $70, $3E, $FF, $32, $F3, $71
    DB      $C9, $21, $4B, $72, $35, $E5, $3E, $00
    DB      $06, $00, $4E, $16, $0D, $CD, $73, $9B
    DB      $E1, $4E, $06, $0E, $11, $EC, $DD, $21
    DB      $DB, $DD, $3E, $01, $CD, $49, $8F, $21
    DB      $E6, $70, $35, $3A, $4B, $72, $FE, $00
    DB      $CA, $65, $DE, $C9, $16, $00, $3E, $00
    DB      $CD, $73, $9B, $3E, $32, $32, $4B, $72
    DB      $3E, $02, $32, $4A, $72, $C9, $21, $4B
    DB      $72, $35, $C2, $86, $DE, $3E, $01, $77
    DB      $3E, $FF, $32, $49, $72, $C9, $19, $DE
    DB      $3A, $DE, $77, $DE, $00, $FD, $4E, $02
    DB      $CB, $21, $21, $17, $BB, $09, $4E, $23
    DB      $46, $C5, $E1, $06, $00, $FD, $4E, $01
    DB      $09, $7E, $DD, $77, $08, $FD, $4E, $02
    DB      $06, $00, $21, $21, $BC, $09, $7E, $DD
    DB      $77, $0E, $21, $25, $BC, $09, $7E, $DD
    DB      $77, $0F, $FD, $E5, $FD, $21, $DE, $70
    DB      $CD, $D5, $9A, $FD, $E1, $DD, $E1, $DA
    DB      $A9, $BB, $C9, $DD, $E5, $FD, $E5, $CD
    DB      $BF, $BA, $3E, $FF, $CD, $68, $98, $CD
    DB      $AC, $83, $FD, $E1, $DD, $E1, $CD, $D7
    DB      $BA, $FD, $E5, $DD, $E5, $3E, $00, $CD
    DB      $49, $8F, $CD, $C5, $83, $DD, $E1, $FD
    DB      $E1, $21, $A2, $71, $35, $FD, $7E, $02
    DB      $FE, $00, $C2, $E5, $BB, $34, $3A, $A3
    DB      $71, $C6, $01, $27, $32, $A3, $71, $0E
    DB      $00, $FD, $7E, $02, $FE, $00, $CA, $F1
    DB      $BB, $0E, $02, $79, $CD, $11, $93, $21
    DB      $9D, $71, $3A, $A4, $71, $86, $27, $77
    DB      $23, $3A, $A5, $71, $8E, $27, $77, $23
    DB      $3E, $00, $8E, $27, $77, $DD, $E5, $FD
    DB      $E5, $CD, $AF, $9A, $3E, $02, $CD, $AD
    DB      $9C, $FD, $E1, $DD, $E1, $3E, $02, $DD
    DB      $77, $00, $C9, $02, $0E, $0E, $05, $0A
    DB      $10, $10, $0C, $C9, $7F, $BA, $3B, $BB
    DB      $29, $BC, $DD, $7E, $08, $DD, $86, $0F
    DB      $3C, $4F, $DD, $7E, $0E, $CB, $3F, $DD
    DB      $86, $07, $47, $DD, $7E, $09, $A7, $CA
    DB      $4C, $BC, $78, $D6, $20, $47, $DD, $E5
    DB      $C5, $CD, $B1, $BC, $C1, $DD, $E1, $DA
    DB      $AD, $BC, $79, $FE, $40, $CA, $81, $BC
    DB      $FE, $7D, $CA, $81, $BC, $FE, $BA, $CA
    DB      $81, $BC, $3A, $A6, $71, $FE, $FF, $C2
    DB      $7E, $BC, $79, $FE, $BB, $DA, $7E, $BC
    DB      $3E, $BA, $DD, $77, $08, $C3, $AD, $BC
    DB      $C3, $AF, $BC, $78, $FE, $F8, $D2, $AD
    DB      $BC, $79, $FE, $C0, $D2, $AF, $BC, $DD
    DB      $E5, $3E, $01, $CD, $48, $92, $DD, $E1
    DB      $78, $FE, $FF, $C2, $A5, $BC, $79, $E6
    DB      $F0, $CA, $AF, $BC, $C3, $AD, $BC, $79
    DB      $E6, $0F, $FE, $01, $C2, $AF, $BC, $37
    DB      $C9, $A7, $C9, $3A, $35, $72, $A7, $CA
    DB      $D1, $BC, $3A, $86, $70, $B9, $C2, $D1
    DB      $BC, $78, $FE, $40, $DA, $D1, $BC, $FE
    DB      $C0, $D2, $D1, $BC, $3E, $FF, $32, $93
    DB      $70, $37, $C9, $3E, $00, $32, $93, $70
    DB      $A7, $C9, $36, $70, $4E, $70, $66
