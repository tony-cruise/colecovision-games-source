; ===== STAR WARS THE ARCADE GAME (1984) DISASSEMBLY LEGEND =====
; ROM: 16 KB ($8000-$BFFF). VDP $BE/$BF. SN76489A on $FF.
; Cart magic: $AA55 (standard). JOYSTICK_BUFFER: $7002 (non-std; std $5A48).
;
; === CART ENTRY & MAIN LOOP ===
; CART_ENTRY (JP NMI; no copyright string) ........... 202
; LOC_8066 (main loop: READ_REGISTER, A455, 9CDB) .... 230
;
; === BOOT & INIT ===
; START (DI, SP=STACKTOP, clear RAM, init VDP+sound) . 205
; SUB_9FD4 (zero-fill $031A bytes at $7050) .......... 3632
; SUB_A006 (SOUND_INIT: B=4, HL=$B217 song table) ... 3660
; SUB_9FB9 (fill VRAM $0000..$3FFE with $00) ......... 3616
; SUB_A7FB (init VDP tile tables: INIT_TABLE/WRITE) .. 4369
; DELAY_LOOP_A8EF (load ASCII font + title VRAM) ..... 4450
; SUB_A79D (title screen VRAM layout: $7053=$03) ..... 4344
; SUB_ABD1 (VDP enable: $71EC=$00, REG $01E2) ........ 4838
; SUB_A48A (wait for button press: spin $7282/$7283) . 4209
; SUB_AC9A (option screen: $7053=$0E, diff+wave) ..... 4960
;
; === NMI ===
; NMI ($71EC gate, $7055 special mode, $7053 dispatch) 236
;
; === NMI PHASE DISPATCH ($7053) ===
; SUB_8DAE (phase 0: in-game AI, enemy logic, collide) 1632
; SUB_86D7 (phase 1: TIE fighter targeting sequence) . 892
; SUB_917E (phase 2: death star trench run) ........... 1902
; SUB_9D61 (phase 3: bonus count / game-over handler) . 3262
;
; === PER-FRAME NMI TAIL (shared by all phases) ===
; SUB_9E5F (enemy/object animation tick) .............. 3410
; SUB_A0F0 (player sprite: hit flash + animation) ..... 3753
; DELAY_LOOP_A426 (HUD/score tile update) ............. 4154
; SUB_AF39 (commit sprites + VDP state) ............... 5150
;
; === PLAYER INPUT & CROSSHAIR ===
; SUB_835F (joystick -> crosshair $71EF/$71F0) ........ 405
; SUB_83D2 (crosshair tile update: colour + VRAM pos) . 483
;
; === GAME DISPATCH & PERSPECTIVE ===
; SUB_A455 (6-slot dispatch: IX=$727B, IY=$810D tbl) .. 4181
; SUB_9CDB (perspective crosshair corner recalculation) 3203
;
; === VDP HELPERS ===
; SUB_ABDC (VDP disable: $71EC=$01, WRITE_REG $01C2) .. 4845
;
; === KEY RAM ($7000-$73B9) ===
; $7002  JOYSTICK_BUFFER (non-std; std $5A48)
; $702B  CONTROLLER_BUFFER
; $7050  RAM clear base (zero-filled $031A bytes at START)
; $7053  NMI phase: 0=game, 1=TIE, 2=trench, 3=gameover, $0E=option
; $7055  special-mode flag (TURN_OFF_SOUND path in NMI)
; $7063  lives counter (init $09 at START)
; $71EC  NMI re-entry flag (set on entry, cleared at exit)
; $71ED  NMI frame counter (16-bit, INC each NMI)
; $71EF  crosshair X position (updated by SUB_835F)
; $71F0  crosshair Y position
; $712F  TIE sequence counter (0-2, cycles in SUB_86D7)
; $7282/$7283  controller button-press latch
; $727B  6-slot dispatch flag array (IX base for SUB_A455)
; $810D  function pointer table (IY base for SUB_A455)
; $73C8  ROM presence marker ($1234)
;
; === DATA BLOCKS ===
; GAME_DATA (level/object/enemy data) ................ 5230
; TILE_BITMAPS (VDP pattern table bitmaps) ........... 5700
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

                                           ; BIOS SUBROUTINE JUMP TABLE DEFINITIONS

BOOT_UP:                 EQU $0000         ; BOOT_UP: warm/soft reset ($0000)
BIOS_NMI:                EQU $0066
NUMBER_TABLE:            EQU $006C
PLAY_SONGS:              EQU $1F61         ; PLAY_SONGS: BIOS play song data via SOUND_MAN
ACTIVATEP:               EQU $1F64
REFLECT_VERTICAL:        EQU $1F6A
REFLECT_HORIZONTAL:      EQU $1F6D
ROTATE_90:               EQU $1F70
ENLARGE:                 EQU $1F73
CONTROLLER_SCAN:         EQU $1F76
DECODER:                 EQU $1F79
GAME_OPT:                EQU $1F7C
LOAD_ASCII:              EQU $1F7F
FILL_VRAM:               EQU $1F82         ; FILL_VRAM: BIOS fill VRAM[HL] with A, count DE
MODE_1:                  EQU $1F85
UPDATE_SPINNER:          EQU $1F88
INIT_TABLEP:             EQU $1F8B
PUT_VRAMP:               EQU $1F91
INIT_SPR_ORDERP:         EQU $1F94
INIT_TIMERP:             EQU $1F9A
REQUEST_SIGNALP:         EQU $1FA0
TEST_SIGNALP:            EQU $1FA3
WRITE_REGISTERP:         EQU $1FA6
INIT_WRITERP:            EQU $1FAF
SOUND_INITP:             EQU $1FB2
PLAY_ITP:                EQU $1FB5
INIT_TABLE:              EQU $1FB8         ; INIT_TABLE: BIOS init VRAM table (A=table#, HL=base)
GET_VRAM:                EQU $1FBB         ; GET_VRAM: BIOS read VRAM tile into buffer
PUT_VRAM:                EQU $1FBE         ; PUT_VRAM: BIOS write tile data to VRAM at DE (IY=stride)
INIT_SPR_NM_TBL:         EQU $1FC1         ; INIT_SPR_NM_TBL: BIOS init sprite name table in RAM
WR_SPR_NM_TBL:           EQU $1FC4         ; WR_SPR_NM_TBL: BIOS write sprite name table to VRAM
INIT_TIMER:              EQU $1FC7
FREE_SIGNAL:             EQU $1FCA
REQUEST_SIGNAL:          EQU $1FCD
TEST_SIGNAL:             EQU $1FD0
TIME_MGR:                EQU $1FD3         ; TIME_MGR: BIOS advance all timer channels (call from NMI)
TURN_OFF_SOUND:          EQU $1FD6
WRITE_REGISTER:          EQU $1FD9         ; WRITE_REGISTER: BIOS set VDP register (BC: B=reg, C=val)
READ_REGISTER:           EQU $1FDC         ; READ_REGISTER: BIOS read VDP status register -> A
WRITE_VRAM:              EQU $1FDF         ; WRITE_VRAM: BIOS write data block to VRAM
READ_VRAM:               EQU $1FE2         ; READ_VRAM: BIOS read data block from VRAM
INIT_WRITER:             EQU $1FE5         ; INIT_WRITER: BIOS init WRITER DMA engine
WRITER:                  EQU $1FE8         ; WRITER: BIOS DMA-copy tile buffer to VRAM
POLLER:                  EQU $1FEB         ; POLLER: BIOS poll controller -> JOYSTICK_BUFFER / CONTROLLER_BUFFER
SOUND_INIT:              EQU $1FEE         ; SOUND_INIT: BIOS init sound engine (B=channels, HL=song table)
PLAY_IT:                 EQU $1FF1         ; PLAY_IT: BIOS play sound effect (B=channel)
SOUND_MAN:               EQU $1FF4         ; SOUND_MAN: BIOS advance sound engine (call from NMI)
ACTIVATE:                EQU $1FF7         ; ACTIVATE: BIOS activate sprite slot at IY
PUTOBJ:                  EQU $1FFA         ; PUTOBJ: BIOS position + display object record at IX
RAND_GEN:                EQU $1FFD         ; RAND_GEN: BIOS LCG random number -> A

; I/O PORT DEFINITIONS **********************

KEYBOARD_PORT:           EQU $0080         ; KEYBOARD_PORT: $0080 keyboard matrix
DATA_PORT:               EQU $00BE         ; DATA_PORT: $00BE VDP VRAM data port
CTRL_PORT:               EQU $00BF         ; CTRL_PORT: $00BF VDP control/status port
JOY_PORT:                EQU $00C0         ; JOY_PORT: $00C0 joystick port
CONTROLLER_02:           EQU $00F5         ; CONTROLLER_02: $00F5 player 2 controller
CONTROLLER_01:           EQU $00FC         ; CONTROLLER_01: $00FC player 1 controller
SOUND_PORT:              EQU $00FF         ; SOUND_PORT: $00FF SN76489A sound chip

; RAM DEFINITIONS ***************************

WORK_BUFFER:             EQU $7000         ; WORK_BUFFER: $7000 general RAM base
JOYSTICK_BUFFER:         EQU $7002         ; JOYSTICK_BUFFER: $7002 BIOS POLLER output (non-std; std $5A48)
CONTROLLER_BUFFER:       EQU $702B         ; CONTROLLER_BUFFER: $702B controller state buffer
STACKTOP:                EQU $73B9         ; STACKTOP: $73B9 stack top

FNAME "output\STAR-WARS-THE-ARCADE-GAME-1984-NEW.ROM"; output ROM: STAR-WARS-THE-ARCADE-GAME-1984-NEW.ROM
CPU Z80

    ORG     $8000                          ; ROM loads at $8000

    DW      $AA55                          ; cart magic $AA55 (standard)
    DB      $00, $00                       ; header bytes
    DB      $00, $00                       ; header bytes
    DB      $EA, $72                       ; header bytes: I/O pointer $72EA
    DW      JOYSTICK_BUFFER                ; JOYSTICK_BUFFER ($7002) address in header
    DW      START                          ; game start address (START label)
    DB      $C9, $00, $00, $C9, $00, $00, $C9, $00; NOP/RET stubs for unused BIOS slots
    DB      $00, $C9, $00, $00, $C9, $00, $00, $C9; NOP/RET stubs continued
    DB      $00, $00, $ED, $4D, $00        ; RETN stub at end of cart header

CART_ENTRY:                                ; CART_ENTRY: JP NMI (no copyright string; NMI is the game entry handler)
    JP      NMI                            ; jump to NMI handler at $8086

START:                                     ; START: DI, SP=STACKTOP, VDP disable, clear RAM, init tables, option screen
    DB      $F3                            ; DI: disable interrupts during init
    LD      SP, STACKTOP                   ; SP = STACKTOP ($73B9)
    CALL    SUB_ABDC                       ; SUB_ABDC: VDP disable ($71EC=$01, WRITE_REGISTER $01C2)
    CALL    READ_REGISTER                  ; READ_REGISTER: flush VDP status
    CALL    MODE_1                         ; MODE_1: set VDP text mode 1
    CALL    TURN_OFF_SOUND                 ; TURN_OFF_SOUND: silence all sound channels
    LD      HL, $7050                      ; HL = $7050: RAM clear base
    LD      DE, $031A                      ; DE = $031A: $031A bytes to clear
    CALL    SUB_9FD4                       ; SUB_9FD4: zero-fill $031A bytes at $7050
    CALL    SUB_A006                       ; SUB_A006: SOUND_INIT (B=4, HL=$B217 song table)
    LD      HL, BOOT_UP                    ; HL = BOOT_UP: VRAM fill base $0000
    LD      DE, $3FFF                      ; DE = $3FFF: fill $3FFF VRAM bytes
    CALL    SUB_9FB9                       ; SUB_9FB9: fill VRAM ($0000..$3FFE) with $00
    CALL    SUB_A7FB                       ; SUB_A7FB: init VDP tile tables (INIT_TABLE, WRITE_VRAM, REFLECT, ROTATE)
    CALL    DELAY_LOOP_A8EF                ; DELAY_LOOP_A8EF: load ASCII font + title screen VRAM setup
    LD      HL, $1234                      ; HL = $1234
    LD      ($73C8), HL                    ; ($73C8) = $1234: ROM presence marker / checksum sentinel
    CALL    SUB_A79D                       ; SUB_A79D: title screen VRAM layout (sets $7053=$03)
    CALL    SUB_ABD1                       ; SUB_ABD1: VDP enable ($71EC=$00, WRITE_REGISTER $01E2)
    CALL    SUB_A48A                       ; SUB_A48A: wait for controller button press (spin on $7282/$7283)
    CALL    SUB_AC9A                       ; SUB_AC9A: option select screen ($7053=$0E, difficulty+wave)
    LD      A, $09                         ; A = $09
    LD      ($7063), A                     ; ($7063) = $09: init lives counter

LOC_8066:                                  ; LOC_8066: main game loop (READ_REGISTER, dispatch SUB_A455, SUB_9CDB)
    CALL    READ_REGISTER                  ; READ_REGISTER: read VDP status to clear interrupt flag
    CALL    SUB_A455                       ; SUB_A455: dispatch 6 slots (IX=$727B flags, IY=$810D function table)
    CALL    SUB_9CDB                       ; SUB_9CDB: perspective crosshair corner recalculation
    JR      LOC_8066                       ; JR LOC_8066: loop forever

NMI:                                       ; NMI: save regs, gate $71EC, TURN_OFF_SOUND if $7055, dispatch by $7053
    PUSH    AF                             ; PUSH AF
    PUSH    BC                             ; PUSH BC
    PUSH    DE                             ; PUSH DE
    PUSH    HL                             ; PUSH HL
    PUSH    IX                             ; PUSH IX
    PUSH    IY                             ; PUSH IY
    LD      A, ($7055)                     ; A = ($7055): special-mode flag
    OR      A                              ; OR A: test special mode
    JR      Z, LOC_8088                    ; JR Z: if zero, proceed normally
    CALL    TURN_OFF_SOUND                 ; TURN_OFF_SOUND: silence all channels in special mode
    CALL    SUB_A006                       ; SUB_A006: SOUND_INIT: re-init sound engine
    CALL    TURN_OFF_SOUND                 ; TURN_OFF_SOUND: silence again

LOC_8088:                                  ; LOC_8088: main NMI body (check re-entry $71EC)
    LD      A, ($71EC)                     ; A = ($71EC): NMI re-entry flag
    OR      A                              ; OR A: test flag
    JP      NZ, LOC_80F7                   ; JP NZ: if set, skip to LOC_80F7 (fast path)
    INC     A                              ; INC A: A = 1
    LD      ($71EC), A                     ; ($71EC) = 1: set re-entry flag
    LD      HL, $71EF                      ; HL = $71EF: crosshair position block
    LD      BC, $002C                      ; BC = $002C: 44 bytes
    LD      DE, $1B00                      ; DE = $1B00: VRAM dest for crosshair sprites
    CALL    WRITE_VRAM                     ; WRITE_VRAM: flush crosshair sprite data to VRAM
    LD      A, ($7055)                     ; A = ($7055): special mode
    OR      A                              ; OR A: test
    JR      NZ, LOC_80E6                   ; JR NZ: special mode path
    CALL    PLAY_SONGS                     ; CALL PLAY_SONGS: advance song engine
    CALL    SOUND_MAN                      ; CALL SOUND_MAN: advance sound engine
    CALL    DELAY_LOOP_A3FD                ; DELAY_LOOP_A3FD: joystick/input update
    CALL    SUB_835F                       ; SUB_835F: player input (joystick -> crosshair $71EF/$71F0)
    CALL    SUB_83D2                       ; SUB_83D2: crosshair tile update (color tables)
    LD      A, ($7053)                     ; A = ($7053): game phase
    OR      A                              ; OR A: test if phase=0 (in-game)
    JR      NZ, LOC_80BF                   ; JR NZ: if non-zero, dispatch to phase handler
    CALL    SUB_8DAE                       ; SUB_8DAE: in-game logic (phase=0): enemy AI, collision
    JR      LOC_80D3                       ; JR LOC_80D3: continue with object updates

LOC_80BF:                                  ; LOC_80BF: phase=1 (targeting/approach)
    DEC     A                              ; DEC A: phase test
    JR      NZ, LOC_80C7                   ; JR NZ: if not 1, check phase 2
    CALL    SUB_86D7                       ; SUB_86D7: phase 1 handler (TIE fighter targeting)
    JR      LOC_80D3                       ; JR LOC_80D3

LOC_80C7:                                  ; LOC_80C7: phase=2 (death star trench)
    DEC     A                              ; DEC A
    JR      NZ, LOC_80CF                   ; JR NZ: check phase 3
    CALL    SUB_917E                       ; SUB_917E: phase 2 handler (death star trench)
    JR      LOC_80D3                       ; JR LOC_80D3

LOC_80CF:                                  ; LOC_80CF: phase=3 (game over / bonus)
    DEC     A                              ; DEC A
    CALL    Z, SUB_9D61                    ; CALL Z: if phase=3, SUB_9D61 (bonus/game-over handler)

LOC_80D3:                                  ; LOC_80D3: per-frame object updates (shared by all phases)
    CALL    SUB_9E5F                       ; SUB_9E5F: enemy/object animation tick
    CALL    SUB_A0F0                       ; SUB_A0F0: player sprite update (hit flash, animation)
    CALL    DELAY_LOOP_A426                ; DELAY_LOOP_A426: HUD/score tile update
    CALL    SUB_AF39                       ; SUB_AF39: commit sprites + VDP state
    LD      HL, ($71ED)                    ; HL = ($71ED): NMI frame counter (16-bit)
    INC     HL                             ; INC HL
    LD      ($71ED), HL                    ; ($71ED) = incremented frame counter

LOC_80E6:                                  ; LOC_80E6: NMI exit (restore regs, clear $71EC, RETN)
    POP     IY                             ; POP IY
    POP     IX                             ; POP IX
    POP     HL                             ; POP HL
    POP     DE                             ; POP DE
    POP     BC                             ; POP BC
    CALL    READ_REGISTER                  ; READ_REGISTER: read VDP status (flush int flag)
    XOR     A                              ; XOR A: A = 0
    LD      ($71EC), A                     ; ($71EC) = 0: clear NMI re-entry flag
    POP     AF                             ; POP AF
    RETN                                   ; RETN: return from NMI

LOC_80F7:                                  ; LOC_80F7: fast NMI path (re-entrant: only SUB_835F/83D2 + songs)
    CALL    SUB_835F                       ; SUB_835F: minimal input update
    CALL    SUB_83D2                       ; SUB_83D2: minimal crosshair update
    CALL    PLAY_SONGS                     ; PLAY_SONGS
    CALL    SOUND_MAN                      ; SOUND_MAN
    POP     IY                             ; POP IY/IX/HL/DE/BC/AF
    POP     IX
    POP     HL
    POP     DE
    POP     BC
    POP     AF                             ; POP AF
    RETN                                   ; RETN
    DB      $19, $81, $D8, $81, $EA, $81, $4A, $82; inline jump table: NMI sub-handler addresses
    DB      $A5, $82, $B0, $82, $3A, $2C, $71, $3D
    DB      $FE, $B4, $28, $27, $32, $2C, $71, $B7
    DB      $20, $2B, $CD, $84, $81, $CD, $59, $81
    DB      $3A, $58, $70, $5F, $16, $00, $21, $CB
    DB      $81, $19, $7E, $32, $2C, $71, $3A, $2A
    DB      $71, $B7, $20, $11, $3E, $FA, $32, $2C
    DB      $71, $18, $0A, $3A, $2B, $71, $B7, $CC
    DB      $12, $A3, $C3, $A0, $A6, $21, $05, $00
    DB      $22, $6F, $72, $C9, $DD, $21, $38, $71
    DB      $06, $06, $DD, $7E, $04, $DD, $86, $05
    DB      $28, $15, $DD, $7E, $0B, $B7, $20, $0F
    DB      $DD, $66, $01, $DD, $6E, $03, $DD, $E5
    DB      $0E, $19, $CD, $20, $A0, $DD, $E1, $11
    DB      $0D, $00, $DD, $19, $10, $DC, $C9, $DD
    DB      $21, $38, $71, $06, $06, $11, $0D, $00
    DB      $DD, $7E, $04, $DD, $86, $05, $28, $05
    DB      $DD, $19, $10, $F4, $C9, $CD, $FD, $1F
    DB      $CB, $3F, $C6, $40, $DD, $77, $01, $AF
    DB      $DD, $77, $08, $DD, $77, $09, $DD, $77
    DB      $0B, $3A, $2B, $71, $B7, $20, $04, $3C
    DB      $DD, $77, $0B, $3A, $2A, $71, $3D, $32
    DB      $2A, $71, $21, $00, $80, $DD, $75, $02
    DB      $DD, $74, $03, $C3, $BE, $87, $14, $14
    DB      $12, $11, $10, $0F, $0E, $0D, $0C, $0B
    DB      $0A, $0A, $0A, $AF, $32, $6A, $70, $3C
    DB      $32, $54, $70, $CD, $AE, $A7, $21, $90
    DB      $01, $22, $79, $72, $C9, $3A, $FA, $70
    DB      $3D, $32, $FA, $70, $20, $3B, $CD, $FD
    DB      $1F, $E6, $03, $32, $6A, $70, $3A, $F9
    DB      $70, $B7, $20, $1D, $3A, $FB, $70, $B7
    DB      $20, $22, $3E, $04, $32, $6A, $70, $21
    DB      $64, $00, $22, $77, $72, $21, $AB, $70
    DB      $11, $7E, $00, $CD, $D4, $9F, $C3, $B6
    DB      $AB, $2A, $FD, $70, $7E, $23, $22, $FD
    DB      $70, $CD, $F6, $8E, $3E, $0A, $32, $FA
    DB      $70, $3A, $FA, $70, $E6, $03, $20, $0E
    DB      $3A, $04, $71, $6F, $3A, $00, $71, $67
    DB      $B7, $0E, $0A, $C4, $20, $A0, $21, $05
    DB      $00, $22, $73, $72, $C9, $3A, $17, $72
    DB      $FE, $DD, $20, $47, $3A, $AD, $70, $B7
    DB      $28, $48, $3E, $04, $32, $6A, $70, $21
    DB      $50, $00, $22, $71, $72, $06, $05, $CD
    DB      $EE, $AB, $21, $AB, $70, $11, $7E, $00
    DB      $CD, $D4, $9F, $CD, $B6, $AB, $3E, $64
    DB      $32, $66, $70, $CD, $37, $AC, $3E, $03
    DB      $32, $53, $70, $DD, $21, $6B, $70, $06
    DB      $10, $11, $04, $00, $3E, $60, $DD, $77
    DB      $01, $3E, $80, $DD, $77, $03, $DD, $19
    DB      $10, $F2, $C9, $21, $02, $00, $22, $75
    DB      $72, $C9, $CD, $A0, $A6, $C3, $CD, $AA
    DB      $3A, $56, $70, $FE, $01, $CA, $A0, $A6
    DB      $C3, $A4, $A5, $DD, $21, $5A, $70, $3A
    DB      $63, $70, $47, $87, $87, $80, $DD, $46
    DB      $03, $80, $DD, $77, $03, $21, $CB, $82
    DB      $E5, $DD, $E5, $C3, $20, $A3, $3A, $30
    DB      $71, $B7, $20, $1B, $3A, $59, $70, $5F
    DB      $16, $00, $21, $56, $83, $19, $7E, $DD
    DB      $46, $03, $80, $DD, $77, $03, $21, $EC
    DB      $82, $E5, $DD, $E5, $C3, $20, $A3, $3A
    DB      $57, $70, $3D, $87, $87, $87, $47, $3A
    DB      $59, $70, $80, $5F, $16, $00, $21, $3E
    DB      $83, $19, $7E, $DD, $46, $03, $80, $DD
    DB      $77, $03, $21, $10, $83, $E5, $DD, $E5
    DB      $C3, $20, $A3, $3A, $63, $70, $47, $3A
    DB      $64, $70, $80, $32, $63, $70, $3A, $56
    DB      $70, $3C, $32, $56, $70, $32, $58, $70 ; "p<2Vp2Xp"
    DB      $32, $59, $70, $FE, $07, $38, $0F, $3E
    DB      $07, $32, $59, $70, $47, $3A, $ED, $71
    DB      $E6, $03, $80, $32, $58, $70, $C3, $A4
    DB      $A4, $00, $0A, $0A, $0A, $41, $41, $96
    DB      $96, $00, $41, $41, $41, $41, $41, $96
    DB      $96, $00, $96, $96, $96, $96, $96, $96
    DB      $96, $05, $05

LOC_8358:
    LD      A, (BC)
    RRCA    
    ADD     HL, DE
    LD      ($6464), A                  ; RAM $6464
    LD      H, H

SUB_835F:                                  ; SUB_835F: read joystick, update crosshair position ($71EF/$71F0)
    LD      HL, ($7067)                 ; RAM $7067
    LD      A, ($71ED)                  ; RAM $71ED
    AND     $01
    JR      NZ, LOC_8385
    LD      A, ($7052)                  ; RAM $7052
    LD      B, A

LOC_836D:
    LD      A, ($7282)                  ; RAM $7282
    XOR     B
    BIT     2, A
    JR      Z, LOC_8376
    DEC     H

LOC_8376:
    BIT     1, A
    JR      Z, LOC_837B
    INC     L

LOC_837B:
    BIT     0, A
    JR      Z, LOC_8380
    INC     H

LOC_8380:
    BIT     3, A
    JR      Z, LOC_8385
    DEC     L

LOC_8385:
    LD      A, L
    CALL    SUB_83BC
    CALL    SUB_AC00
    LD      A, C
    ADD     A, A
    LD      ($7067), A                  ; RAM $7067
    LD      B, A
    LD      A, ($71F0)                  ; RAM $71F0
    ADD     A, B
    SUB     $80
    CALL    SUB_AC00
    JR      Z, LOC_836D
    LD      ($71F0), A                  ; RAM $71F0
    LD      A, H
    CALL    SUB_83BC
    CALL    SUB_AC00
    LD      A, C
    ADD     A, A
    LD      ($7068), A                  ; RAM $7068
    LD      B, A
    LD      A, ($71EF)                  ; RAM $71EF
    ADD     A, B
    SUB     $80
    CALL    SUB_AC00
    JR      LOC_8358
    DB      $32, $EF, $71, $C9

SUB_83BC:
    LD      B, A
    LD      A, ($7282)                  ; RAM $7282
    AND     $0F
    LD      A, B
    RET     NZ
    CALL    SUB_83C7

SUB_83C7:
    CP      $80
    RET     Z
    BIT     7, A
    JR      Z, LOC_83D0
    DEC     A
    RET     

LOC_83D0:
    INC     A
    RET     

SUB_83D2:                                  ; SUB_83D2: update crosshair tile indices in VRAM (colour + position)
    LD      A, ($71C2)                  ; RAM $71C2
    OR      A
    JP      NZ, LOC_8530
    LD      A, ($7283)                  ; RAM $7283
    OR      A
    RET     Z
    LD      A, ($7054)                  ; RAM $7054
    OR      A
    RET     NZ
    LD      A, $02
    LD      ($71C2), A                  ; RAM $71C2
    LD      A, ($7131)                  ; RAM $7131
    OR      A
    JR      NZ, LOC_83F2
    INC     A
    LD      ($7130), A                  ; RAM $7130

LOC_83F2:
    LD      B, $03
    CALL    SUB_ABEE
    LD      A, ($71C1)                  ; RAM $71C1
    XOR     $40
    LD      ($71C1), A                  ; RAM $71C1

LOC_83FF:
    LD      A, ($71C1)                  ; RAM $71C1
    OR      A
    JR      NZ, LOC_843F
    LD      A, $28
    LD      ($71C6), A                  ; RAM $71C6
    LD      ($71CF), A                  ; RAM $71CF
    XOR     A
    LD      ($71C8), A                  ; RAM $71C8
    LD      ($71D1), A                  ; RAM $71D1
    LD      A, ($71F0)                  ; RAM $71F0
    LD      ($71C3), A                  ; RAM $71C3
    SUB     $28
    LD      ($71C7), A                  ; RAM $71C7
    LD      ($71D0), A                  ; RAM $71D0
    LD      A, ($71EF)                  ; RAM $71EF
    LD      ($71C4), A                  ; RAM $71C4
    LD      D, $6D
    LD      IX, $71C9                   ; RAM $71C9
    CALL    SUB_84A3
    LD      A, ($71EF)                  ; RAM $71EF
    LD      D, $A3
    LD      IX, $71D2                   ; RAM $71D2
    CALL    SUB_84A3
    JR      LOC_847A

LOC_843F:
    LD      A, $D2
    LD      ($71C6), A                  ; RAM $71C6
    LD      ($71CF), A                  ; RAM $71CF
    LD      A, $01
    LD      ($71C8), A                  ; RAM $71C8
    LD      ($71D1), A                  ; RAM $71D1
    LD      A, ($71F0)                  ; RAM $71F0
    LD      ($71C3), A                  ; RAM $71C3
    SUB     $D2
    NEG     
    LD      ($71C7), A                  ; RAM $71C7
    LD      ($71D0), A                  ; RAM $71D0
    LD      A, ($71EF)                  ; RAM $71EF
    LD      ($71C4), A                  ; RAM $71C4
    LD      D, $6D
    LD      IX, $71C9                   ; RAM $71C9
    CALL    SUB_84A3
    LD      A, ($71EF)                  ; RAM $71EF
    LD      D, $A3
    LD      IX, $71D2                   ; RAM $71D2
    CALL    SUB_84A3

LOC_847A:
    LD      A, $0F
    LD      ($71F6), A                  ; RAM $71F6
    LD      IX, $71C5                   ; RAM $71C5
    LD      A, (IX+1)
    LD      ($71F4), A                  ; RAM $71F4
    LD      A, (IX+5)
    LD      ($71F3), A                  ; RAM $71F3
    LD      A, (IX+8)
    LD      ($71F5), A                  ; RAM $71F5
    LD      IX, $71CE                   ; RAM $71CE
    CALL    SUB_86C3
    LD      IX, $71D2                   ; RAM $71D2
    JP      SUB_86C3

SUB_84A3:
    LD      E, A
    LD      (IX+1), D
    LD      B, $00
    SUB     D
    JR      NC, LOC_84BB
    NEG     
    INC     B
    SUB     $10
    LD      C, A
    LD      A, (IX+1)
    SUB     $10
    LD      (IX+1), A
    LD      A, C

LOC_84BB:
    LD      (IX+2), A
    LD      (IX+3), B
    LD      A, E
    SUB     D
    JP      P, LOC_84C8
    NEG     

LOC_84C8:
    CP      $10
    JR      NC, LOC_84DE
    LD      (IX+1), D
    LD      A, $24
    LD      (IX+4), A
    BIT     7, (IX+2)
    RET     Z
    XOR     A
    LD      (IX+2), A
    RET     

LOC_84DE:
    DEC     IX
    DEC     IX
    LD      E, (IX+0)
    INC     IX
    INC     IX
    LD      D, $00
    LD      L, (IX+2)
    LD      H, D
    CALL    SOUND_WRITE_8510
    LD      D, A
    ADD     A, $04
    LD      B, A
    LD      A, ($71C1)                  ; RAM $71C1
    ADD     A, B
    LD      (IX+4), A
    BIT     0, (IX+3)
    RET     NZ
    LD      A, D
    SUB     $40
    NEG     
    LD      B, A
    LD      A, ($71C1)                  ; RAM $71C1
    ADD     A, B
    LD      (IX+4), A
    RET     

SOUND_WRITE_8510:
    CALL    DELAY_LOOP_AB27
    LD      HL, $8526
    LD      C, $FF

LOC_8518:
    INC     HL
    INC     C
    CP      (HL)
    JR      C, LOC_8518
    LD      A, C
    CP      $08
    JR      C, LOC_8524
    LD      A, $07

LOC_8524:
    ADD     A, A
    ADD     A, A
    RET     
    DB      $32, $1A, $0F, $0A, $06, $04, $02, $00
    DB      $00

LOC_8530:
    LD      IX, $71C5                   ; RAM $71C5
    LD      HL, $71ED                   ; RAM $71ED
    BIT     0, (HL)
    JR      Z, LOC_853F
    LD      IX, $71CE                   ; RAM $71CE

LOC_853F:
    LD      A, (IX+8)
    LD      ($71F5), A                  ; RAM $71F5
    CALL    SUB_869E
    LD      ($71F4), A                  ; RAM $71F4
    LD      B, A
    LD      A, ($71C3)                  ; RAM $71C3
    SUB     B
    LD      C, A
    LD      DE, $0004
    ADD     IX, DE
    CALL    SUB_869E
    LD      ($71F3), A                  ; RAM $71F3
    LD      B, A
    LD      A, ($71C4)                  ; RAM $71C4
    SUB     B
    CP      $05
    RET     NC
    LD      A, C
    CP      $05
    RET     NC
    LD      A, ($7053)                  ; RAM $7053
    OR      A
    JR      Z, LOC_85C4
    CP      $01
    JP      NZ, LOC_8618
    LD      IX, $7138                   ; RAM $7138
    LD      B, $06

LOC_8579:
    LD      A, (IX+1)
    OR      A
    JR      Z, LOC_85BB
    LD      A, (IX+11)
    OR      A
    JR      NZ, LOC_85BB
    LD      E, (IX+3)
    LD      L, $0A
    CALL    SUB_8683
    JR      NC, LOC_85BB
    LD      A, $01
    LD      (IX+11), A
    LD      C, $0B
    CALL    DELAY_LOOP_A242
    LD      A, ($7129)                  ; RAM $7129
    LD      B, A

LOC_859D:
    PUSH    BC
    CALL    SUB_A2E7
    POP     BC
    DJNZ    LOC_859D
    LD      A, ($7129)                  ; RAM $7129
    INC     A
    INC     A
    LD      ($7129), A                  ; RAM $7129
    LD      A, ($712B)                  ; RAM $712B
    DEC     A
    CP      $FF
    JP      Z, LOC_8649
    LD      ($712B), A                  ; RAM $712B
    JP      LOC_8649

LOC_85BB:
    LD      DE, $000D
    ADD     IX, DE
    DJNZ    LOC_8579
    JR      LOC_8618

LOC_85C4:
    LD      IX, $70FF                   ; RAM $70FF
    LD      IY, $7207                   ; RAM $7207
    LD      B, $03

LOC_85CE:
    LD      A, (IX+1)
    OR      A
    JR      Z, LOC_860C
    CALL    SUB_867E
    JR      NC, LOC_860C
    LD      A, (IX+13)
    CP      $02
    JR      Z, LOC_8649
    CP      $01
    JR      Z, LOC_85FA
    XOR     A
    LD      (IX+1), A
    LD      (IY+1), A
    LD      A, $C8
    LD      (IY+0), A
    LD      C, $0B
    CALL    DELAY_LOOP_A242
    CALL    SUB_A302
    JR      LOC_8649

LOC_85FA:
    LD      A, $02
    LD      (IX+13), A
    CALL    SUB_A302
    CALL    SUB_A302
    LD      B, $05
    CALL    SUB_ABEE
    JR      LOC_8649

LOC_860C:
    LD      DE, $000E
    ADD     IX, DE
    LD      DE, $0004
    ADD     IY, DE
    DJNZ    LOC_85CE

LOC_8618:
    LD      IX, $70D5                   ; RAM $70D5
    LD      B, $04

LOC_861E:
    LD      A, (IX+1)
    OR      A
    JR      Z, LOC_8642
    CALL    SUB_867E
    JR      NC, LOC_8642
    XOR     A
    LD      (IX+1), A
    LD      (IX+5), A
    LD      (IX+8), A
    LD      A, $80
    LD      (IX+3), A
    CALL    SUB_A2BF
    LD      B, $09
    CALL    SUB_ABEE
    JR      LOC_8649

LOC_8642:
    LD      DE, $0009
    ADD     IX, DE
    DJNZ    LOC_861E

LOC_8649:
    LD      A, ($7132)                  ; RAM $7132
    OR      A
    JR      Z, LOC_8667
    LD      A, ($7218)                  ; RAM $7218
    LD      D, A
    LD      A, ($7217)                  ; RAM $7217
    LD      E, A
    CP      $5A
    JR      C, LOC_8667
    LD      L, $19
    CALL    SUB_8686
    JR      NC, LOC_8667
    LD      A, $01
    LD      ($70AD), A                  ; RAM $70AD

LOC_8667:
    XOR     A
    LD      ($71F3), A                  ; RAM $71F3
    LD      ($71F4), A                  ; RAM $71F4
    LD      A, $01
    LD      ($71F6), A                  ; RAM $71F6
    LD      A, ($71C2)                  ; RAM $71C2
    DEC     A
    LD      ($71C2), A                  ; RAM $71C2
    JP      NZ, LOC_83FF
    RET     

SUB_867E:
    LD      L, $0A
    LD      E, (IX+5)

SUB_8683:
    LD      D, (IX+1)

SUB_8686:
    LD      A, ($71C3)                  ; RAM $71C3
    SUB     D
    JP      P, LOC_868F
    NEG     

LOC_868F:
    CP      L
    RET     NC
    LD      A, ($71C4)                  ; RAM $71C4
    SUB     E
    JP      P, LOC_869A
    NEG     

LOC_869A:
    CP      L
    RET     NC
    SCF     
    RET     

SUB_869E:
    LD      L, (IX+2)
    LD      H, $00
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    LD      E, L
    LD      D, H
    LD      L, (IX+0)
    LD      H, (IX+1)
    LD      A, (IX+3)
    OR      A
    JR      NZ, LOC_86B9
    ADD     HL, DE
    JR      LOC_86BB

LOC_86B9:
    SBC     HL, DE

LOC_86BB:
    LD      (IX+1), H
    LD      (IX+0), L
    LD      A, H
    RET     

SUB_86C3:
    LD      A, (IX+3)
    XOR     $01
    LD      (IX+3), A
    CALL    SUB_869E
    LD      A, (IX+3)
    XOR     $01
    LD      (IX+3), A
    RET     

SUB_86D7:                                  ; SUB_86D7: phase 1 handler (TIE fighter targeting state machine)
    LD      A, ($712F)                     ; A = ($712F): TIE sequence counter
    INC     A                              ; INC A
    CP      $03                            ; CP $03: wrap at 3
    JR      NZ, LOC_86E0                   ; JR NZ: if not 3, keep
    XOR     A                              ; XOR A: wrap to 0

LOC_86E0:                                  ; LOC_86E0: dispatch based on sequence count
    LD      ($712F), A                     ; ($712F) = updated counter
    OR      A                              ; OR A: test count
    JR      Z, LOC_86EC                    ; JR Z: count=0 -> JP SUB_9254 (TIE spawn)
    DEC     A                              ; DEC A
    JR      Z, LOC_86EF                    ; JR Z: count=1 -> SUB_8BD1/8B9C + clear IX records
    DEC     A
    JR      Z, LOC_8707                    ; DEC A: count=2 -> LOC_8707 (TIE fire/update)

LOC_86EC:                                  ; LOC_86EC: TIE spawn (JP SUB_9254)
    JP      SUB_9254

LOC_86EF:                                  ; LOC_86EF: TIE init (SUB_8BD1, SUB_8B9C, clear 6 object records)
    CALL    SUB_8BD1                       ; SUB_8BD1: TIE fighter sprites init
    CALL    SUB_8B9C                       ; SUB_8B9C: TIE object placement
    LD      IX, $7138                      ; IX = $7138: first object record
    LD      B, $06                         ; B = $06: 6 records
    LD      DE, $000D                      ; DE = $000D: record stride (13 bytes each)
    XOR     A                              ; XOR A

LOC_86FF:                                  ; LOC_86FF: clear (IX+10) in each record
    LD      (IX+10), A                     ; (IX+10) = 0: clear state byte
    ADD     IX, DE                         ; IX += $000D
    DJNZ    LOC_86FF                       ; DJNZ: loop 6
    RET                                    ; RET

LOC_8707:
    LD      C, $00
    LD      IX, $7138                   ; RAM $7138
    LD      B, $06

LOC_870F:
    LD      A, (IX+10)
    OR      A
    JR      NZ, LOC_872C
    LD      A, (IX+4)
    ADD     A, (IX+5)
    JR      Z, LOC_872C
    LD      A, (IX+3)
    CP      C
    JR      C, LOC_872C
    LD      C, (IX+3)
    PUSH    IX
    POP     HL
    LD      ($71D7), HL                 ; RAM $71D7

LOC_872C:
    LD      DE, $000D
    ADD     IX, DE
    DJNZ    LOC_870F
    LD      A, C
    OR      A
    JR      Z, LOC_876D
    LD      HL, ($71D7)                 ; RAM $71D7
    PUSH    HL
    POP     IX
    LD      A, $01
    LD      (IX+10), A
    CALL    DELAY_LOOP_87BE
    LD      A, (IX+1)
    CP      $28
    JR      C, LOC_8757
    CP      $D7
    JR      NC, LOC_8757
    LD      A, (IX+9)
    CP      $22
    JR      NZ, LOC_8768

LOC_8757:
    XOR     A
    LD      (IX+1), A
    LD      (IX+4), A
    LD      (IX+5), A
    LD      B, $06
    CALL    SUB_ABEE
    JR      LOC_876B

LOC_8768:
    CALL    SUB_8877

LOC_876B:
    JR      LOC_8707

LOC_876D:
    CALL    SUB_B15E
    LD      A, ($71ED)                  ; RAM $71ED
    AND     $C0
    JR      NZ, LOC_879A
    CALL    SUB_AB85
    LD      H, D
    NOP     
    INC     E
    DEC     (HL)
    JR      NC, LOC_87BB
    JR      NC, LOC_87B2
    JR      NC, LOC_8784

LOC_8784:
    LD      (HL), B
    LD      L, A
    LD      L, C
    LD      L, (HL)
    LD      (HL), H
    LD      (HL), E
    NOP     
    LD      H, (HL)
    LD      L, A
    LD      (HL), D
    NOP     
    LD      H, C
    LD      L, H
    LD      L, H
    NOP     
    LD      (HL), H
    LD      L, A
    LD      (HL), A
    LD      H, L
    LD      (HL), D
    LD      (HL), E
    RET     

LOC_879A:
    LD      A, ($7129)                  ; RAM $7129
    LD      DE, $0065
    CALL    SOUND_WRITE_A395
    CALL    SUB_AB85
    LD      H, A
    NOP     
    INC     D
    JR      NC, LOC_87DB
    NOP     
    LD      (HL), B
    LD      L, A
    LD      L, C
    LD      L, (HL)
    LD      (HL), H
    LD      (HL), E

LOC_87B2:
    NOP     
    LD      L, (HL)
    LD      H, L
    LD      A, B
    LD      (HL), H
    NOP     
    LD      (HL), H
    LD      L, A
    LD      (HL), A

LOC_87BB:
    LD      H, L
    LD      (HL), D
    RET     

DELAY_LOOP_87BE:
    LD      A, ($7067)                  ; RAM $7067
    NEG     
    LD      L, A
    LD      H, $00
    LD      A, (IX+3)
    SUB     $80
    NEG     
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    ADD     A, $04
    LD      B, A
    LD      DE, $0080

LOC_87DD:
    DB      $EB
    ADD     HL, HL
    DB      $EB
    ADD     HL, HL
    DJNZ    LOC_87DD
    OR      A
    SBC     HL, DE
    LD      A, ($7067)                  ; RAM $7067
    CP      $80
    JR      NZ, LOC_87F9
    LD      E, (IX+1)
    LD      D, $00
    ADD     HL, DE
    LD      DE, $0080
    OR      A
    SBC     HL, DE

LOC_87F9:
    ADD     HL, HL
    ADD     HL, HL
    LD      E, (IX+0)
    LD      D, (IX+1)
    ADD     HL, DE
    LD      (IX+0), L
    LD      (IX+1), H
    LD      L, (IX+8)
    LD      H, (IX+9)
    LD      DE, $0070
    ADD     HL, DE
    LD      (IX+8), L
    LD      (IX+9), H
    LD      L, H
    LD      H, $00
    LD      DE, $88F8
    ADD     HL, DE
    LD      A, (HL)
    ADD     A, A
    LD      E, A
    LD      A, (IX+1)
    SRL     A
    SRL     A
    XOR     $01
    AND     $01
    OR      E
    LD      E, A
    ADD     A, A
    LD      E, A
    LD      D, $00
    LD      HL, $891B
    ADD     HL, DE
    ADD     A, A
    LD      (IX+12), A
    LD      E, (HL)
    LD      (IX+4), E
    INC     HL
    LD      D, (HL)
    LD      (IX+5), D
    DB      $EB
    INC     HL
    LD      A, (HL)
    SRL     A
    INC     A
    ADD     A, A
    ADD     A, A
    ADD     A, A
    LD      B, A
    LD      A, $80
    SUB     B
    LD      (IX+3), A
    LD      A, (IX+1)
    SRL     A
    SRL     A
    SRL     A
    LD      E, A
    LD      D, $00
    LD      HL, ($7134)                 ; RAM $7134
    ADD     HL, DE
    LD      A, (IX+3)
    AND     $F8
    DB      $EB
    LD      L, A
    LD      H, $00
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, DE
    LD      (IX+6), L
    LD      (IX+7), H
    RET     

SUB_8877:
    LD      L, (IX+4)
    LD      H, (IX+5)
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    INC     HL
    LD      E, (IX+6)
    LD      D, (IX+7)
    LD      A, C
    CP      $04
    JR      C, LOC_8892
    DEC     DE
    CP      $06
    JR      C, LOC_8892
    DEC     DE

LOC_8892:
    PUSH    HL
    CALL    SUB_88E3
    LD      A, (IX+12)
    SRL     A
    SRL     A
    SRL     A
    CP      $0C
    JR      Z, LOC_88AA
    CP      $0D
    JR      Z, LOC_88AA
    POP     AF
    JR      LOC_88AB

LOC_88AA:
    POP     HL

LOC_88AB:
    LD      A, ($7135)                  ; RAM $7135
    CP      $18
    LD      A, D
    JR      NZ, LOC_88BB
    CP      $18
    JR      C, LOC_88C5
    CP      $1B
    JR      LOC_88C1

LOC_88BB:
    CP      $10
    JR      C, LOC_88C5
    CP      $14

LOC_88C1:
    JR      NC, LOC_88C5
    DJNZ    LOC_8892

LOC_88C5:
    LD      A, (IX+11)
    OR      A
    RET     Z
    LD      DE, $8B2C
    LD      L, (IX+12)
    LD      H, $00
    ADD     HL, DE
    LD      E, (IX+6)
    LD      D, (IX+7)
    LD      C, $02
    CALL    SUB_88E3
    LD      C, $02
    JP      SUB_88E3

SUB_88E3:
    PUSH    BC
    LD      B, $00
    PUSH    BC
    PUSH    HL
    PUSH    DE
    CALL    WRITE_VRAM
    POP     DE
    LD      BC, $0020
    DB      $EB
    ADD     HL, BC
    DB      $EB
    POP     BC
    POP     HL
    ADD     HL, BC
    POP     BC
    RET     
    DB      $00, $00, $00, $00, $01, $01, $01, $02
    DB      $02, $02, $03, $03, $03, $04, $04, $04
    DB      $05, $05, $06, $06, $07, $07, $08, $08
    DB      $09, $09, $0A, $0A, $0B, $0B, $0C, $0C
    DB      $0C, $0D, $0D, $53, $89, $5B, $89, $63
    DB      $89, $6B, $89, $73, $89, $7F, $89, $8B
    DB      $89, $97, $89, $A3, $89, $B3, $89, $C3
    DB      $89, $D3, $89, $E3, $89, $00, $8A, $28
    DB      $8A, $14, $8A, $5D, $8A, $45, $8A, $98
    DB      $8A, $80, $8A, $D7, $8A, $BB, $8A, $00
    DB      $8B, $00, $8B, $1C, $8B, $1C, $8B, $23
    DB      $8B, $23, $8B, $02, $03, $00, $C9, $00
    DB      $A1, $00, $D7, $02, $03, $B7, $DF, $C4
    DB      $DD, $E1, $E2, $02, $03, $00, $CB, $00
    DB      $9C, $00, $C1, $02, $03, $B6, $E6, $D8
    DB      $DD, $E7, $E8, $02, $05, $00, $C9, $00
    DB      $A1, $00, $9C, $00, $9C, $00, $D7, $02
    DB      $05, $B7, $DF, $C4, $DD, $D8, $DD, $D8
    DB      $DD, $E1, $E2, $02, $05, $00, $BF, $00
    DB      $D3, $00, $D3, $00, $D3, $00, $B9, $02
    DB      $05, $D4, $D2, $EB, $EC, $EB, $EC, $EB
    DB      $EC, $ED, $EE, $02, $07, $00, $95, $00
    DB      $AA, $00, $D3, $00, $D3, $00, $D3, $A8
    DB      $94, $00, $CE, $02, $07, $B1, $BB, $D5
    DB      $BE, $EB, $EC, $EB, $EC, $EB, $EC, $F2
    DB      $F3, $F4, $F5, $02, $07, $00, $BF, $00
    DB      $D3, $00, $D3, $00, $D3, $00, $D3, $00
    DB      $D3, $DB, $DA, $02, $07, $D4, $D2, $EB
    DB      $EC, $EB, $EC, $EB, $EC, $EB, $EC, $EB
    DB      $EC, $F7, $F6, $03, $09, $00, $BD, $00
    DB      $00, $C2, $00, $00, $A2, $00, $00, $A2
    DB      $00, $00, $A2, $00, $00, $A2, $00, $00
    DB      $A2, $00, $9B, $98, $D9, $00, $CE, $00
    DB      $02, $09, $B1, $BB, $BA, $B8, $F8, $F9
    DB      $F8, $F9, $F8, $F9, $F8, $F9, $F8, $F9
    DB      $FA, $FB, $FD, $FC, $02, $09, $B5, $B4
    DB      $F8, $F9, $F8, $F9, $F8, $F9, $F8, $F9
    DB      $F8, $F9, $F8, $F9, $F8, $F9, $90, $A0
    DB      $03, $09, $00, $C5, $00, $00, $A2, $00
    DB      $00, $A2, $00, $00, $A2, $00, $00, $A2
    DB      $00, $00, $A2, $00, $00, $A2, $00, $00
    DB      $A2, $00, $9A, $99, $91, $02, $0B, $B1
    DB      $BB, $BA, $B8, $F8, $F9, $F8, $F9, $F8
    DB      $F9, $F8, $F9, $F8, $F9, $F8, $F9, $F8
    DB      $F9, $FA, $FB, $FD, $FC, $03, $0B, $00
    DB      $BD, $00, $00, $C2, $00, $00, $A2, $00
    DB      $00, $A2, $00, $00, $A2, $00, $00, $A2
    DB      $00, $00, $A2, $00, $00, $A2, $00, $00
    DB      $A2, $00, $9B, $98, $D9, $00, $CE, $00
    DB      $02, $0B, $AC, $A7, $96, $93, $CF, $D6
    DB      $CF, $D6, $CF, $D6, $CF, $D6, $CF, $D6
    DB      $CF, $D6, $CF, $D6, $CF, $D6, $E4, $E3
    DB      $03, $0B, $A4, $A3, $00, $92, $A5, $00
    DB      $92, $CF, $00, $92, $CF, $00, $92, $CF
    DB      $00, $92, $CF, $00, $92, $CF, $00, $92
    DB      $CF, $00, $92, $CF, $00, $92, $CF, $00
    DB      $A9, $A6, $AB, $02, $0D, $B2, $B3, $AF
    DB      $AE, $CF, $D6, $CF, $D6, $CF, $D6, $CF
    DB      $D6, $CF, $D6, $CF, $D6, $CF, $D6, $CF
    DB      $D6, $CF, $D6, $BC, $D0, $F4, $FC, $03
    DB      $0D, $00, $BD, $00, $92, $97, $00, $92
    DB      $CF, $00, $92, $CF, $00, $92, $CF, $00
    DB      $92, $CF, $00, $92, $CF, $00, $92, $CF
    DB      $00, $92, $CF, $00, $92, $CF, $00, $92
    DB      $CF, $00, $9D, $9F, $9E, $00, $CE, $00
    DB      $02, $0D, $AC, $A7, $96, $93, $CF, $D6
    DB      $CF, $D6, $CF, $D6, $CF, $D6, $CF, $D6
    DB      $CF, $D6, $CF, $D6, $CF, $D6, $CF, $D6
    DB      $CF, $D6, $E4, $E3, $05, $14, $D6, $00
    DB      $D6, $00, $D6, $07, $16, $D6, $00, $00
    DB      $D6, $00, $00, $D6, $00, $C3, $00, $9C
    DB      $DE, $DF, $D8, $DD, $00, $C6, $00, $9C
    DB      $E5, $E6, $D8, $DD, $00, $C3, $00, $9C
    DB      $DE, $DF, $D8, $DD, $00, $C7, $00, $D3
    DB      $E9, $EA, $EB, $EC, $00, $CA, $00, $D3
    DB      $EF, $F1, $EB, $EC, $00, $C7, $00, $D3
    DB      $E9, $EA, $EB, $EC, $00, $CA, $00, $A2
    DB      $EF, $F1, $F8, $F9, $00, $CC, $00, $A2
    DB      $FE, $FF, $F8, $F9, $00, $CA, $00, $A2
    DB      $EF, $F1, $F8, $F9, $A4, $D1, $92, $CF
    DB      $AD, $DC, $CF, $D6, $00, $CD, $92, $CF
    DB      $B0, $C0, $CF, $D6, $AD, $DC, $CF, $D6
    DB      $AD, $DC, $CF, $D6, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00

SUB_8B9C:
    LD      IX, $7138                   ; RAM $7138
    LD      B, $06

LOC_8BA2:
    LD      A, (IX+4)
    ADD     A, (IX+5)
    JR      Z, LOC_8BC9
    LD      A, (IX+9)
    CP      $21
    JR      C, LOC_8BC9
    LD      A, (IX+1)
    CP      $5D
    JR      C, LOC_8BC9
    CP      $A3
    JR      NC, LOC_8BC9
    CALL    SUB_AACD
    XOR     A
    LD      (IX+1), A
    LD      (IX+4), A
    LD      (IX+5), A

LOC_8BC9:
    LD      DE, $000D
    ADD     IX, DE
    DJNZ    LOC_8BA2
    RET     

SUB_8BD1:
    XOR     A
    LD      ($7069), A                  ; RAM $7069
    LD      IX, $706B                   ; RAM $706B

LOC_8BD9:
    LD      A, ($7069)                  ; RAM $7069
    LD      L, A
    LD      H, $00
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    DB      $EB
    LD      HL, ($7136)                 ; RAM $7136
    ADD     HL, DE
    LD      DE, $0400
    ADD     HL, DE
    LD      DE, $0008
    CALL    SUB_9FB9
    CALL    SUB_8C87
    LD      A, ($712C)                  ; RAM $712C
    CP      $C8
    JR      NC, LOC_8C08
    CP      $96
    JR      C, LOC_8C08
    CALL    SUB_8C87
    CALL    SUB_8C87
    CALL    SUB_8C87

LOC_8C08:
    LD      A, (IX+3)
    CP      $C0
    JR      C, LOC_8C1C
    CP      $E0
    JR      C, LOC_8C17
    SUB     $40
    JR      LOC_8C19

LOC_8C17:
    ADD     A, $40

LOC_8C19:
    LD      (IX+3), A

LOC_8C1C:
    LD      A, (IX+3)
    AND     $F8
    LD      L, A
    LD      H, $00
    ADD     HL, HL
    ADD     HL, HL
    LD      A, (IX+1)
    SRL     A
    SRL     A
    SRL     A
    LD      E, A
    LD      D, $00
    ADD     HL, DE
    DB      $EB
    LD      HL, ($7134)                 ; RAM $7134
    ADD     HL, DE
    LD      A, ($7069)                  ; RAM $7069
    ADD     A, $80
    CALL    SUB_A000
    LD      A, (IX+1)
    AND     $07
    LD      E, A
    LD      D, $00
    LD      HL, $8C7F
    ADD     HL, DE
    LD      A, (HL)
    PUSH    AF
    LD      A, ($7069)                  ; RAM $7069
    LD      L, A
    LD      H, $00
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    DB      $EB
    LD      HL, ($7136)                 ; RAM $7136
    ADD     HL, DE
    LD      DE, $0400
    ADD     HL, DE
    LD      A, (IX+3)
    AND     $07
    LD      E, A
    LD      D, $00
    ADD     HL, DE
    POP     AF
    CALL    SUB_A000
    LD      DE, $0004
    ADD     IX, DE
    LD      A, ($7069)                  ; RAM $7069
    INC     A
    LD      ($7069), A                  ; RAM $7069
    CP      $10
    JP      NZ, LOC_8BD9
    RET     
    DB      $80, $40, $20, $10, $08, $04, $02, $01

SUB_8C87:
    LD      A, ($706A)                  ; RAM $706A
    OR      A
    JP      Z, LOC_8D1C
    DEC     A
    JP      Z, LOC_8D37
    DEC     A
    JP      Z, LOC_8D52
    DEC     A
    JP      Z, LOC_8D58
    DEC     A
    JP      Z, LOC_8D61
    LD      A, ($7067)                  ; RAM $7067
    NEG     
    LD      L, A
    LD      H, $00
    LD      A, (IX+3)
    SUB     $78
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    ADD     A, $04
    LD      B, A
    LD      DE, $0080

LOC_8CBB:
    DB      $EB
    ADD     HL, HL
    DB      $EB
    ADD     HL, HL
    DJNZ    LOC_8CBB
    OR      A
    SBC     HL, DE
    LD      A, ($7067)                  ; RAM $7067
    CP      $80
    JR      NZ, LOC_8CD7
    LD      E, (IX+1)
    LD      D, $00
    ADD     HL, DE
    LD      DE, $0080
    OR      A
    SBC     HL, DE

LOC_8CD7:
    ADD     HL, HL
    ADD     HL, HL
    LD      E, (IX+0)
    LD      D, (IX+1)
    ADD     HL, DE
    LD      (IX+0), L
    LD      (IX+1), H
    LD      A, (IX+3)
    SUB     $78
    LD      L, A
    LD      H, $00
    ADD     HL, HL
    LD      E, (IX+2)
    LD      D, (IX+3)
    DB      $EB
    ADD     HL, DE
    ADD     HL, DE
    ADD     HL, DE
    LD      (IX+2), L
    LD      (IX+3), H
    LD      A, H
    CP      $C0
    JR      NC, LOC_8D10
    LD      A, (IX+1)
    CP      $F0
    JR      NC, LOC_8D10
    CP      $10
    JR      C, LOC_8D10
    RET     

LOC_8D10:
    LD      H, $80
    LD      (IX+3), H
    CALL    RAND_GEN
    LD      (IX+1), A
    RET     

LOC_8D1C:
    PUSH    IX
    POP     BC
    LD      DE, $0190
    BIT     2, C
    JR      NZ, LOC_8D29
    LD      DE, $02BC

LOC_8D29:
    LD      L, (IX+2)
    LD      H, (IX+3)
    ADD     HL, DE
    LD      (IX+2), L
    LD      (IX+3), H
    RET     

LOC_8D37:
    PUSH    IX
    POP     BC
    LD      DE, $02BC
    BIT     2, C
    JR      NZ, LOC_8D44
    LD      DE, $03E8

LOC_8D44:
    LD      L, (IX+0)
    LD      H, (IX+1)
    ADD     HL, DE
    LD      (IX+0), L
    LD      (IX+1), H
    RET     

LOC_8D52:
    CALL    LOC_8D37
    JP      LOC_8D1C

LOC_8D58:
    CALL    LOC_8D37
    CALL    LOC_8D1C
    JP      LOC_8D1C

LOC_8D61:
    CALL    SUB_8D70
    INC     IX
    INC     IX
    CALL    SUB_8D70
    DEC     IX
    DEC     IX
    RET     

SUB_8D70:
    LD      A, (IX+1)
    SUB     $80
    JP      P, LOC_8D7A
    NEG     

LOC_8D7A:
    CP      $60
    JR      NC, LOC_8DA3
    LD      L, A
    LD      H, $00
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    LD      DE, $0096
    ADD     HL, DE
    LD      E, (IX+0)
    LD      D, (IX+1)
    DB      $EB
    BIT     7, (IX+1)
    JR      Z, LOC_8D9A
    ADD     HL, DE
    ADD     HL, DE

LOC_8D9A:
    SBC     HL, DE
    LD      (IX+0), L
    LD      (IX+1), H
    RET     

LOC_8DA3:
    CALL    RAND_GEN
    AND     $0F
    ADD     A, $78
    LD      (IX+1), A
    RET     

SUB_8DAE:                                  ; SUB_8DAE: in-game handler (phase=0): enemy AI + collision detection
    CALL    SUB_8E1C
    LD      A, ($712F)                  ; RAM $712F
    INC     A
    CP      $03
    JR      NZ, LOC_8DBA
    XOR     A

LOC_8DBA:
    LD      ($712F), A                  ; RAM $712F
    OR      A
    JR      Z, LOC_8DCA
    CP      $01
    JP      Z, LOC_8DCD
    CP      $02
    JP      Z, LOC_8DF4

LOC_8DCA:
    JP      SUB_9254

LOC_8DCD:
    CALL    SUB_8BD1
    LD      A, ($706A)                  ; RAM $706A
    CP      $04
    JR      Z, LOC_8DF3
    LD      A, ($70F9)                  ; RAM $70F9
    CP      $01
    JR      NC, LOC_8DF3
    LD      A, $02
    LD      ($706A), A                  ; RAM $706A
    LD      HL, $7217                   ; RAM $7217
    INC     (HL)
    INC     HL
    INC     (HL)
    LD      A, $9C
    LD      ($7219), A                  ; RAM $7219
    LD      A, $02
    LD      ($721A), A                  ; RAM $721A

LOC_8DF3:
    RET     

LOC_8DF4:
    CALL    SUB_8E1C
    CALL    SUB_B15E
    LD      A, ($71ED)                  ; RAM $71ED
    AND     $40
    RET     Z
    LD      A, ($706A)                  ; RAM $706A
    CP      $04
    RET     Z
    CALL    SUB_AB85
    LD      C, C
    NOP     
    RRCA    
    LD      (HL), E
    LD      L, B
    LD      L, A
    LD      L, A
    LD      (HL), H
    NOP     
    LD      H, (HL)
    LD      L, C
    LD      (HL), D
    LD      H, L
    LD      H, D
    LD      H, C
    LD      L, H
    LD      L, H
    LD      (HL), E
    RET     

SUB_8E1C:
    XOR     A
    LD      ($70FB), A                  ; RAM $70FB
    LD      IX, $70FF                   ; RAM $70FF
    LD      IY, $7207                   ; RAM $7207
    LD      HL, $3D00
    LD      B, $03

LOC_8E2D:
    PUSH    BC
    PUSH    HL
    LD      A, (IX+1)
    OR      A
    JP      Z, LOC_8EE1
    LD      ($70FB), A                  ; RAM $70FB
    CALL    SUB_AB3C
    LD      A, (IX+1)
    CP      $05
    JR      C, LOC_8E80
    CP      $FB
    JR      NC, LOC_8E80
    LD      A, (IX+5)
    CP      $0A
    JR      C, LOC_8E80
    CP      $BB
    JR      NC, LOC_8E80
    LD      A, (IX+10)
    DEC     A
    LD      (IX+10), A
    JR      NZ, LOC_8E89
    LD      L, (IX+11)
    LD      H, (IX+12)
    LD      A, (HL)
    OR      A
    JR      Z, LOC_8E80
    LD      (IX+3), A
    INC     HL
    LD      A, (HL)
    LD      (IX+7), A
    INC     HL
    LD      A, (HL)
    LD      (IX+9), A
    INC     HL
    LD      A, (HL)
    LD      (IX+10), A
    INC     HL
    LD      (IX+11), L
    LD      (IX+12), H
    JR      LOC_8E89

LOC_8E80:
    XOR     A
    LD      (IX+1), A
    LD      A, $C8
    LD      (IX+5), A

LOC_8E89:
    LD      A, (IX+1)
    LD      (IY+1), A
    LD      A, (IX+5)
    LD      (IY+0), A
    LD      A, $0B
    LD      (IY+3), A
    LD      A, (IX+13)
    CP      $02
    JR      NZ, LOC_8EB5
    BIT     0, (IX+10)
    JR      Z, LOC_8EB0
    LD      A, (IX+9)
    INC     A
    AND     $0F
    LD      (IX+9), A

LOC_8EB0:
    LD      A, $0F
    LD      (IY+3), A

LOC_8EB5:
    LD      A, (IX+9)
    CP      (IX+8)
    JR      Z, LOC_8EE1
    LD      (IX+8), A
    LD      L, A
    LD      H, $00
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    LD      DE, $2800
    LD      A, (IX+13)
    OR      A
    JR      Z, LOC_8ED4
    LD      DE, $3000

LOC_8ED4:
    ADD     HL, DE
    DB      $EB
    CALL    SUB_9FE2
    POP     DE
    PUSH    DE
    LD      HL, $72EA                   ; RAM $72EA
    CALL    SUB_AC2B

LOC_8EE1:
    LD      DE, $000E
    ADD     IX, DE
    LD      DE, $0004
    ADD     IY, DE
    POP     HL
    LD      DE, $0020
    ADD     HL, DE
    POP     BC
    DEC     B
    JP      NZ, LOC_8E2D
    RET     
    DB      $6F, $DD, $21, $FF, $70, $06, $03, $DD
    DB      $7E, $01, $B7, $28, $08, $11, $0E, $00
    DB      $DD, $19, $10, $F3, $C9, $7D, $87, $5F
    DB      $16, $00, $21, $DA, $8F, $19, $5E, $23
    DB      $56, $EB, $7E, $23, $DD, $77, $01, $7E
    DB      $23, $DD, $77, $05, $7E, $23, $DD, $77
    DB      $02, $7E, $23, $DD, $77, $06, $7E, $23
    DB      $DD, $77, $03, $7E, $23, $DD, $77, $07
    DB      $7E, $23, $DD, $77, $09, $7E, $23, $DD
    DB      $77, $0A, $DD, $75, $0B, $DD, $74, $0C
    DB      $06, $00, $FD, $21, $FF, $70, $FD, $7E
    DB      $0D, $FD, $86, $1B, $FD, $86, $29, $20
    DB      $08, $3A, $F9, $70, $E6, $03, $20, $01
    DB      $04, $DD, $70, $0D, $3E, $FF, $DD, $77
    DB      $08, $3A, $F9, $70, $3D, $32, $F9, $70
    DB      $C9, $87, $8F, $8F, $8F, $97, $8F, $9F
    DB      $8F, $A6, $8F, $AD, $8F, $B5, $8F, $AD
    DB      $8F, $A6, $8F, $B5, $8F, $9F, $8F, $B5
    DB      $8F, $04, $05, $06, $0B, $02, $07, $01
    DB      $08, $05, $09, $00, $07, $06, $07, $02
    DB      $0A, $08, $09, $07, $02, $03, $09, $0B
    DB      $05, $06, $0B, $08, $09, $0A, $09, $0A
    DB      $0A, $07, $0A, $05, $06, $04, $07, $0B
    DB      $0A, $09, $08, $07, $06, $05, $04, $0B
    DB      $0A, $0B, $01, $06, $09, $0A, $0A, $07
    DB      $0A, $05, $06, $04, $07, $05, $09, $00
    DB      $07, $06, $07, $02, $0A, $06, $0B, $08
    DB      $09, $0A, $09, $0A, $0B, $0A, $09, $08
    DB      $07, $06, $05, $04, $F2, $8F, $07, $90
    DB      $1C, $90, $31, $90, $46, $90, $5F, $90
    DB      $78, $90, $85, $90, $8E, $90, $CB, $90
    DB      $10, $91, $55, $91, $07, $9B, $8F, $6C
    DB      $80, $80, $0D, $64, $80, $81, $0D, $1E
    DB      $80, $80, $0E, $FA, $80, $80, $0E, $FA
    DB      $00, $F5, $9B, $71, $6C, $80, $80, $0A
    DB      $64, $80, $81, $0A, $1E, $80, $80, $09
    DB      $FA, $80, $80, $09, $FA, $00, $F5, $14
    DB      $71, $95, $80, $80, $06, $64, $7F, $7F
    DB      $06, $1E, $80, $80, $07, $FA, $80, $80
    DB      $07, $FA, $00, $07, $1E, $8F, $94, $80
    DB      $80, $02, $64, $81, $7F, $02, $1E, $80
    DB      $80, $01, $FA, $80, $80, $01, $FA, $00
    DB      $64, $0F, $71, $94, $80, $80, $06, $28
    DB      $81, $80, $05, $28, $80, $80, $04, $32
    DB      $81, $80, $03, $3C, $80, $80, $03, $F0
    DB      $00, $A0, $0F, $8F, $94, $80, $80, $02
    DB      $28, $7F, $80, $03, $28, $80, $80, $04
    DB      $32, $7F, $80, $05, $46, $80, $80, $05
    DB      $F0, $00, $80, $0F, $80, $9E, $80, $80
    DB      $04, $64, $82, $80, $03, $C8, $00, $07
    DB      $7D, $99, $94, $80, $80, $01, $C8, $00
    DB      $64, $0F, $71, $92, $80, $80, $06, $28
    DB      $81, $80, $05, $28, $80, $80, $04, $32
    DB      $81, $80, $03, $32, $82, $7F, $02, $1E
    DB      $80, $80, $01, $32, $7F, $7E, $00, $14
    DB      $7F, $7F, $0F, $14, $7F, $7F, $0E, $14
    DB      $7F, $7F, $0D, $14, $7F, $7F, $0C, $14
    DB      $7E, $7F, $0B, $14, $7D, $80, $0A, $14
    DB      $80, $80, $0A, $FA, $00, $FA, $5A, $64
    DB      $71, $80, $80, $0A, $46, $80, $81, $09
    DB      $28, $80, $80, $09, $14, $80, $81, $08
    DB      $28, $81, $81, $07, $14, $81, $81, $06
    DB      $14, $82, $81, $05, $14, $80, $80, $04
    DB      $1E, $82, $7F, $04, $14, $82, $80, $03
    DB      $1E, $80, $80, $02, $32, $81, $7F, $01
    DB      $14, $81, $7E, $00, $14, $81, $7F, $0F
    DB      $14, $80, $7D, $0E, $14, $80, $7D, $0D
    DB      $FA, $00, $0A, $50, $9C, $71, $80, $80
    DB      $0E, $46, $80, $81, $0F, $28, $80, $80
    DB      $0F, $14, $80, $81, $00, $28, $7F, $81
    DB      $01, $14, $7F, $81, $02, $14, $7E, $81
    DB      $03, $14, $80, $80, $04, $1E, $7E, $7F
    DB      $04, $14, $7E, $80, $05, $1E, $80, $80
    DB      $06, $32, $7F, $7F, $07, $14, $7F, $7E
    DB      $08, $14, $7F, $7F, $09, $14, $80, $7D
    DB      $0A, $14, $80, $7D, $0B, $FA, $00, $64
    DB      $0F, $71, $94, $80, $80, $06, $28, $81
    DB      $80, $05, $28, $80, $80, $04, $32, $81
    DB      $80, $03, $32, $82, $7F, $02, $28, $80
    DB      $80, $01, $28, $80, $7E, $00, $28, $80
    DB      $7F, $0F, $28, $7F, $7F, $0E, $28, $00

SUB_917E:                                  ; SUB_917E: phase 2 handler (death star trench: scroll, turrets, exhaust port)
    CALL    SUB_91DE
    CALL    SUB_91C2
    CALL    DELAY_LOOP_928C
    CALL    SUB_91C2
    CALL    SUB_9A7C
    CALL    SUB_91C2
    CALL    SUB_99A5
    LD      A, ($71ED)                  ; RAM $71ED
    ADD     A, A
    AND     $1F
    ADD     A, $48
    LD      L, A
    LD      A, ($71ED)                  ; RAM $71ED
    AND     $20
    ADD     A, $74
    LD      H, A
    LD      C, $78
    CALL    SUB_A020
    LD      A, ($7130)                  ; RAM $7130
    OR      A
    RET     NZ
    CALL    SUB_AB85
    LD      C, D
    NOP     
    DEC     C
    LD      (HL), L
    LD      (HL), E
    LD      H, L
    NOP     
    LD      (HL), H
    LD      L, B
    LD      H, L
    NOP     
    LD      H, (HL)
    LD      L, A
    LD      (HL), D
    LD      H, E
    LD      H, L
    RET     

SUB_91C2:
    LD      HL, $71EF                   ; RAM $71EF
    LD      BC, $0018
    LD      DE, $1B00
    CALL    WRITE_VRAM
    CALL    SUB_A0F0
    CALL    SUB_9E5F
    LD      HL, ($71ED)                 ; RAM $71ED
    INC     HL
    LD      ($71ED), HL                 ; RAM $71ED
    JP      READ_REGISTER

SUB_91DE:
    CALL    SUB_9254
    CALL    SUB_B15E
    CALL    SUB_AB85
    SUB     B
    LD      BC, $7C02                   ; RAM $7C02
    LD      A, L
    CALL    SUB_AB85
    OR      B
    LD      BC, $7E02                   ; RAM $7E02
    LD      A, A
    LD      HL, $7161                   ; RAM $7161
    LD      DE, $001E
    CALL    SUB_9FD4
    LD      HL, $7183                   ; RAM $7183
    LD      DE, $001E
    CALL    SUB_9FD4
    CALL    SUB_91C2
    CALL    READ_REGISTER
    LD      IX, $7138                   ; RAM $7138
    LD      B, $04

LOC_9212:
    PUSH    BC
    LD      A, (IX+0)
    CALL    SUB_9BC1
    LD      A, (IX+0)
    CALL    SUB_9BFC
    LD      A, (DE)
    LD      L, A
    LD      H, $00
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    LD      E, (IX+8)
    LD      D, (IX+9)
    ADD     HL, DE
    DB      $EB
    LD      BC, $0040
    CALL    SUB_9FE5
    LD      L, (IX+7)
    LD      H, $00
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    DB      $EB
    LD      HL, ($7136)                 ; RAM $7136
    ADD     HL, DE
    LD      DE, $72EA                   ; RAM $72EA
    DB      $EB
    LD      BC, $0040
    CALL    WRITE_VRAM
    POP     BC
    LD      DE, $000A
    ADD     IX, DE
    DJNZ    LOC_9212
    RET     

SUB_9254:
    LD      A, ($7133)                  ; RAM $7133
    XOR     $01
    LD      ($7133), A                  ; RAM $7133
    JR      Z, LOC_9269
    CALL    SUB_AC4A
    LD      HL, $0800
    LD      DE, $1000
    JR      LOC_927F

LOC_9269:
    LD      A, $03
    LD      HL, $0800
    CALL    INIT_TABLE
    LD      A, $02
    LD      HL, $1000
    CALL    INIT_TABLE
    LD      HL, BOOT_UP
    LD      DE, $1800

LOC_927F:
    LD      ($7136), HL                 ; RAM $7136
    DB      $EB
    LD      ($7134), HL                 ; RAM $7134
    LD      DE, $0300
    JP      SUB_9FB9

DELAY_LOOP_928C:
    LD      A, ($71A1)                  ; RAM $71A1
    INC     A
    LD      ($71A1), A                  ; RAM $71A1
    CP      $05
    JP      C, LOC_9313
    LD      IX, $71A5                   ; RAM $71A5
    LD      B, $04
    LD      DE, $0007

LOC_92A1:
    LD      A, (IX+1)
    OR      A
    JR      Z, LOC_92AD
    ADD     IX, DE
    DJNZ    LOC_92A1
    JR      LOC_9313

LOC_92AD:
    XOR     A
    LD      (IX+0), A
    LD      (IX+2), A
    LD      (IX+3), A
    LD      (IX+4), A
    LD      (IX+5), A
    INC     A
    LD      (IX+1), A
    LD      A, ($7160)                  ; RAM $7160
    INC     A
    AND     $01
    LD      ($7160), A                  ; RAM $7160
    JR      Z, LOC_930C
    LD      HL, ($71A3)                 ; RAM $71A3
    LD      A, (HL)
    INC     HL
    CP      $FD
    JR      NZ, LOC_92D9
    LD      B, $07
    JR      LOC_92DF

LOC_92D9:
    CP      $FE
    JR      NZ, LOC_92E4
    LD      B, $08

LOC_92DF:
    CALL    SUB_ABEE
    LD      A, (HL)
    INC     HL

LOC_92E4:
    CP      $0F
    JR      NZ, LOC_92EB
    LD      ($7131), A                  ; RAM $7131

LOC_92EB:
    CP      $FF
    JR      NZ, LOC_9309
    LD      A, ($7132)                  ; RAM $7132
    OR      A
    LD      A, $00
    JR      NZ, LOC_930C
    INC     A
    LD      ($7132), A                  ; RAM $7132
    PUSH    IX
    POP     HL
    LD      ($70AB), HL                 ; RAM $70AB
    LD      A, $4D
    LD      ($7217), A                  ; RAM $7217
    XOR     A
    JR      LOC_930C

LOC_9309:
    LD      ($71A3), HL                 ; RAM $71A3

LOC_930C:
    LD      (IX+6), A
    XOR     A
    LD      ($71A1), A                  ; RAM $71A1

LOC_9313:
    LD      A, ($7132)                  ; RAM $7132
    OR      A
    JR      Z, LOC_9379
    LD      HL, ($70AB)                 ; RAM $70AB
    PUSH    HL
    POP     IX
    LD      A, (IX+3)
    SRL     A
    ADD     A, (IX+2)
    SUB     $08
    LD      ($7218), A                  ; RAM $7218
    LD      A, (IX+5)
    ADD     A, (IX+4)
    JR      NZ, LOC_933D
    LD      B, A
    LD      A, ($7217)                  ; RAM $7217
    CP      $4D
    JR      Z, LOC_9379
    LD      A, B

LOC_933D:
    SUB     $08
    LD      C, A
    LD      A, ($7217)                  ; RAM $7217
    CP      $4D
    JR      NZ, LOC_934B
    LD      A, C
    LD      ($7217), A                  ; RAM $7217

LOC_934B:
    LD      A, C
    LD      B, A
    LD      A, ($7217)                  ; RAM $7217
    SUB     B
    JR      NC, LOC_9355
    NEG     

LOC_9355:
    CP      $14
    JR      C, LOC_935B
    LD      B, $DD

LOC_935B:
    LD      A, B
    CP      $B0
    JR      C, LOC_9362
    LD      A, $DD

LOC_9362:
    LD      ($7217), A                  ; RAM $7217
    SUB     $58
    SRL     A
    SRL     A
    SRL     A
    AND     $FC
    ADD     A, $8C
    LD      ($7219), A                  ; RAM $7219
    LD      A, $0F
    LD      ($721A), A                  ; RAM $721A

LOC_9379:
    CALL    SUB_91C2
    LD      IX, $71A5                   ; RAM $71A5
    LD      B, $04

LOC_9382:
    PUSH    BC
    LD      A, (IX+1)
    OR      A
    JP      Z, LOC_9543
    CALL    SUB_97E9
    LD      A, (IX+1)
    CALL    SOUND_WRITE_98F4
    LD      A, ($71DB)                  ; RAM $71DB
    LD      (IX+2), A
    LD      B, A
    LD      A, ($71DF)                  ; RAM $71DF
    SUB     B
    LD      (IX+3), A
    SRL     A
    LD      ($71A2), A                  ; RAM $71A2
    LD      A, ($71DF)                  ; RAM $71DF
    CP      $70
    JR      NC, LOC_93B2
    LD      A, $EF
    LD      ($71DF), A                  ; RAM $71DF

LOC_93B2:
    LD      A, ($71DF)                  ; RAM $71DF
    CP      $EF
    JR      NZ, LOC_93E1
    LD      A, (IX+1)
    SRL     A
    CALL    SOUND_WRITE_98F4
    LD      A, ($71DB)                  ; RAM $71DB
    LD      B, A
    LD      A, ($71DF)                  ; RAM $71DF
    SUB     B
    LD      ($71A2), A                  ; RAM $71A2
    LD      B, A
    LD      A, ($71DB)                  ; RAM $71DB
    ADD     A, B
    JR      C, LOC_93D7
    CP      $EF
    JR      C, LOC_93E1

LOC_93D7:
    LD      A, ($71DB)                  ; RAM $71DB
    SUB     $EF
    NEG     
    LD      ($71A2), A                  ; RAM $71A2

LOC_93E1:
    LD      A, (IX+2)
    CALL    SUB_984A
    LD      A, ($71E3)                  ; RAM $71E3
    LD      (IX+4), A
    LD      D, A
    LD      A, ($71E7)                  ; RAM $71E7
    CP      $B8
    JR      NZ, LOC_9418
    LD      A, (IX+2)
    SUB     $80
    NEG     
    SRL     A
    SRL     A
    SUB     $80
    NEG     
    CALL    SUB_984A
    LD      A, ($71E3)                  ; RAM $71E3
    LD      D, A
    LD      A, ($71E7)                  ; RAM $71E7
    SUB     D
    ADD     A, A
    ADD     A, A
    CP      $64
    JR      NC, LOC_9419
    JP      LOC_9507

LOC_9418:
    SUB     D

LOC_9419:
    LD      (IX+5), A
    LD      A, (IX+2)
    CP      $14
    JP      C, LOC_9507
    LD      A, (IX+4)
    CP      $14
    JP      C, LOC_9507
    LD      A, (IX+6)
    OR      A
    JR      NZ, LOC_9443
    LD      A, (IX+2)
    ADD     A, (IX+3)
    CALL    SUB_984A
    LD      A, ($71E3)                  ; RAM $71E3
    LD      B, A
    LD      A, ($71E7)                  ; RAM $71E7
    SUB     B

LOC_9443:
    LD      IY, $72EA                   ; RAM $72EA
    LD      (IY+14), A
    LD      B, (IX+2)
    LD      (IY+1), B
    LD      C, (IX+3)
    LD      (IY+9), C
    LD      A, B
    ADD     A, C
    LD      (IY+3), A
    LD      A, ($71A2)                  ; RAM $71A2
    LD      C, A
    LD      (IY+10), C
    LD      A, B
    ADD     A, C
    LD      (IY+2), A
    LD      B, (IX+4)
    LD      (IY+4), B
    LD      C, (IX+5)
    LD      (IY+11), C
    LD      A, B
    ADD     A, C
    CALL    SUB_954E
    LD      (IY+8), A
    SRL     C
    LD      (IY+12), C
    LD      A, B
    ADD     A, C
    CALL    SUB_954E
    LD      (IY+6), A
    SRL     C
    LD      (IY+13), C
    ADD     A, C
    CALL    SUB_954E
    LD      (IY+7), A
    LD      A, (IY+4)
    ADD     A, C
    CALL    SUB_954E
    LD      (IY+5), A
    LD      A, (IY+12)
    LD      B, (IY+13)
    ADD     A, B
    LD      (IY+15), A
    LD      L, (IX+6)
    LD      H, $00
    ADD     HL, HL
    LD      DE, $9665
    ADD     HL, DE
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    PUSH    DE
    POP     IY

LOC_94B8:
    LD      C, (IY+0)
    DEC     C
    INC     C
    JP      Z, LOC_9543
    LD      B, $00
    LD      HL, $72EA                   ; RAM $72EA
    ADD     HL, BC
    LD      E, (HL)
    LD      C, (IY+1)
    LD      B, $00
    LD      HL, $72EA                   ; RAM $72EA
    ADD     HL, BC
    LD      D, (HL)
    LD      C, (IY+2)
    LD      B, $00
    LD      HL, $72EA                   ; RAM $72EA
    ADD     HL, BC
    LD      B, (HL)
    LD      L, B
    LD      A, (IY+3)
    OR      A
    JR      NZ, LOC_94E7
    CALL    DELAY_LOOP_980F
    JR      LOC_94FD

LOC_94E7:
    LD      A, (IX+6)
    CP      $07
    JR      Z, LOC_94F2
    CP      $0A
    JR      NZ, LOC_94FA

LOC_94F2:
    LD      A, E
    ADD     A, L
    JR      NC, LOC_94FA
    LD      A, $FA
    SUB     E
    LD      L, A

LOC_94FA:
    CALL    SUB_9840

LOC_94FD:
    INC     IY
    INC     IY
    INC     IY
    INC     IY
    JR      LOC_94B8

LOC_9507:
    XOR     A
    LD      (IX+1), A
    LD      (IX+4), A
    LD      (IX+5), A
    LD      A, ($71EF)                  ; RAM $71EF
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    LD      E, A
    LD      D, $00
    LD      HL, $9695
    ADD     HL, DE
    LD      B, (HL)
    LD      A, ($71F0)                  ; RAM $71F0
    CP      $80
    JR      C, LOC_9533
    SLA     B
    SLA     B
    SLA     B
    SLA     B

LOC_9533:
    LD      E, (IX+6)
    LD      D, $00
    LD      HL, $9685
    ADD     HL, DE
    LD      A, (HL)
    AND     B
    JR      Z, LOC_9543
    CALL    SUB_AACD

LOC_9543:
    LD      BC, $0007
    ADD     IX, BC
    POP     BC
    DEC     B
    JP      NZ, LOC_9382
    RET     

SUB_954E:
    RET     NC
    XOR     A
    RET     
    DB      $6B, $95, $6B, $95, $8A, $95, $AC, $95
    DB      $D1, $95, $AC, $95, $1B, $96, $3C, $96
    DB      $FA, $95, $1B, $96, $3C, $96, $1B, $96
    DB      $FA, $95, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $0F, $0F
    DB      $FF, $00, $00, $03, $04, $05, $03, $02
    DB      $04, $FD, $04, $05, $03, $05, $03, $02
    DB      $0C, $03, $02, $FE, $0D, $03, $02, $05
    DB      $0C, $0C, $02, $FE, $0D, $0D, $02, $05
    DB      $0F, $0F, $FF, $00, $00, $02, $03, $01
    DB      $05, $04, $02, $FD, $04, $03, $01, $02
    DB      $02, $05, $06, $08, $07, $09, $0C, $0C
    DB      $02, $02, $FE, $0C, $02, $FE, $0C, $02
    DB      $01, $06, $07, $08, $09, $0F, $0F, $FF
    DB      $00, $00, $04, $05, $04, $05, $02, $01
    DB      $0C, $0D, $0C, $01, $FE, $0E, $03, $01
    DB      $02, $03, $01, $05, $0C, $0D, $0C, $FD
    DB      $0E, $03, $01, $02, $04, $05, $03, $03
    DB      $01, $05, $0C, $0D, $0C, $FD, $0F, $0F
    DB      $FF, $00, $00, $05, $04, $03, $01, $02
    DB      $01, $0C, $0D, $0C, $01, $FE, $0A, $0B
    DB      $0A, $0A, $0B, $0B, $0A, $0B, $FE, $0C
    DB      $02, $02, $FE, $0C, $0C, $02, $01, $0F
    DB      $0F, $FF, $00, $00, $0C, $0D, $01, $0E
    DB      $0C, $0C, $0D, $0D, $0C, $FD, $0A, $0B
    DB      $0B, $0A, $0A, $0B, $FE, $01, $0C, $0D
    DB      $01, $0D, $0A, $0B, $0A, $0B, $0A, $0B
    DB      $0F, $0F, $FF, $00, $00, $0E, $0C, $02
    DB      $0E, $0C, $0C, $0D, $0D, $0C, $FD, $01
    DB      $0C, $0D, $01, $0D, $0A, $0B, $0A, $0B
    DB      $0A, $0B, $06, $09, $07, $08, $06, $07
    DB      $08, $09, $0A, $0A, $0B, $0B, $0A, $0B
    DB      $FE, $0F, $0F, $FF, $A1, $96, $AA, $96
    DB      $51, $97, $66, $97, $7B, $97, $90, $97
    DB      $A5, $97, $B6, $97, $C7, $97, $D8, $97
    DB      $E9, $96, $CC, $96, $06, $97, $38, $97
    DB      $1F, $97, $C7, $96, $00, $EE, $11, $22
    DB      $44, $88, $01, $10, $08, $80, $F0, $0F
    DB      $33, $CC, $66, $00, $01, $01, $01, $02
    DB      $02, $04, $04, $04, $08, $08, $08, $08
    DB      $01, $04, $0B, $00, $03, $04, $0E, $00
    DB      $00, $01, $05, $09, $01, $01, $06, $09
    DB      $01, $01, $07, $09, $01, $01, $08, $09
    DB      $01, $01, $05, $0F, $00, $02, $05, $0F
    DB      $00, $03, $05, $0F, $00, $00, $01, $08
    DB      $09, $01, $00, $01, $04, $0A, $01, $01
    DB      $05, $0A, $01, $01, $06, $0A, $01, $01
    DB      $07, $0A, $01, $01, $08, $0A, $01, $01
    DB      $04, $0B, $00, $02, $04, $0B, $00, $00
    DB      $02, $04, $0A, $01, $02, $05, $0A, $01
    DB      $02, $06, $0A, $01, $02, $07, $0A, $01
    DB      $02, $08, $0A, $01, $02, $04, $0B, $00
    DB      $03, $04, $0B, $00, $00, $01, $04, $09
    DB      $01, $01, $05, $09, $01, $01, $06, $09
    DB      $01, $01, $04, $0C, $00, $02, $04, $0C
    DB      $00, $03, $04, $0C, $00, $00, $01, $07
    DB      $09, $01, $01, $05, $09, $01, $01, $06
    DB      $09, $01, $01, $05, $0C, $00, $02, $05
    DB      $0C, $00, $03, $05, $0C, $00, $00, $01
    DB      $06, $09, $01, $01, $07, $09, $01, $01
    DB      $08, $09, $01, $01, $06, $0C, $00, $02
    DB      $06, $0C, $00, $03, $06, $0C, $00, $00
    DB      $01, $04, $09, $01, $01, $05, $09, $01
    DB      $01, $04, $0D, $00, $02, $04, $0D, $00
    DB      $03, $04, $0D, $00, $00, $01, $05, $09
    DB      $01, $01, $06, $09, $01, $01, $05, $0D
    DB      $00, $02, $05, $0D, $00, $03, $05, $0D
    DB      $00, $00, $01, $06, $09, $01, $01, $07
    DB      $09, $01, $01, $06, $0D, $00, $02, $06
    DB      $0D, $00, $03, $06, $0D, $00, $00, $01
    DB      $07, $09, $01, $01, $08, $09, $01, $01
    DB      $07, $0D, $00, $02, $07, $0D, $00, $03
    DB      $07, $0D, $00, $00, $01, $04, $0A, $01
    DB      $01, $05, $0A, $01, $01, $04, $0D, $00
    DB      $02, $04, $0D, $00, $00, $02, $04, $0A
    DB      $01, $02, $05, $0A, $01, $03, $04, $0D
    DB      $00, $02, $04, $0D, $00, $00, $01, $07
    DB      $0A, $01, $01, $08, $0A, $01, $01, $07
    DB      $0D, $00, $02, $07, $0D, $00, $00, $02
    DB      $07, $0A, $01, $02, $08, $0A, $01, $03
    DB      $07, $0D, $00, $02, $07, $0D, $00, $00

SUB_97E9:
    LD      E, (IX+0)
    LD      D, (IX+1)
    LD      L, D
    LD      H, $00
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, DE
    LD      A, ($7068)                  ; RAM $7068
    SUB     $80
    ADD     A, A
    ADD     A, A
    ADD     A, A
    ADD     A, A
    ADD     A, $80
    LD      E, A
    LD      D, $00
    ADD     HL, DE
    LD      (IX+0), L
    LD      (IX+1), H
    RET     

DELAY_LOOP_980F:
    PUSH    IX
    PUSH    BC
    PUSH    AF
    LD      A, E
    CP      $D8
    JR      NC, LOC_983B
    LD      IX, $7161                   ; RAM $7161

LOC_981C:
    LD      A, L
    OR      A
    JR      Z, LOC_983B
    LD      B, $0A

LOC_9822:
    LD      A, (IX+1)
    OR      A
    JR      Z, LOC_9832
    INC     IX
    INC     IX
    INC     IX
    DJNZ    LOC_9822
    JR      LOC_983B

LOC_9832:
    LD      (IX+0), E
    LD      (IX+1), D
    LD      (IX+2), L

LOC_983B:
    POP     AF
    POP     BC
    POP     IX
    RET     

SUB_9840:
    PUSH    IX
    PUSH    BC
    PUSH    AF
    LD      IX, $7183                   ; RAM $7183
    JR      LOC_981C

SUB_984A:
    LD      B, A
    AND     $07
    LD      E, A
    LD      D, $00
    LD      HL, $8C7F
    ADD     HL, DE
    LD      A, (HL)
    LD      ($71D7), A                  ; RAM $71D7
    LD      A, B
    SRL     A
    SRL     A
    SRL     A
    LD      E, A
    LD      D, $00
    LD      HL, $0180
    ADD     HL, DE
    DB      $EB
    LD      HL, ($7134)                 ; RAM $7134
    ADD     HL, DE
    PUSH    HL
    LD      A, $68
    LD      ($71E3), A                  ; RAM $71E3
    LD      B, $0B

LOC_9873:
    PUSH    BC
    PUSH    HL
    CALL    SUB_98EB
    JR      Z, LOC_9896
    CALL    SUB_9B71
    LD      B, $08
    LD      HL, $72F2                   ; RAM $72F2
    LD      A, ($71D7)                  ; RAM $71D7
    LD      D, A

LOC_9886:
    DEC     HL
    LD      A, ($71E3)                  ; RAM $71E3
    DEC     A
    LD      ($71E3), A                  ; RAM $71E3
    LD      A, (HL)
    AND     D
    JR      NZ, LOC_98AA
    DJNZ    LOC_9886
    JR      LOC_989E

LOC_9896:
    LD      A, ($71E3)                  ; RAM $71E3
    SUB     $08
    LD      ($71E3), A                  ; RAM $71E3

LOC_989E:
    POP     HL
    LD      DE, $0020
    OR      A
    SBC     HL, DE
    POP     BC
    DJNZ    LOC_9873
    JR      LOC_98AC

LOC_98AA:
    POP     HL
    POP     HL

LOC_98AC:
    POP     HL
    LD      A, $60
    LD      ($71E7), A                  ; RAM $71E7
    LD      B, $0B

LOC_98B4:
    PUSH    BC
    PUSH    HL
    CALL    SUB_98EB
    JR      Z, LOC_98D7
    CALL    SUB_9B71
    LD      B, $08
    LD      HL, $72E9                   ; RAM $72E9
    LD      A, ($71D7)                  ; RAM $71D7
    LD      D, A

LOC_98C7:
    INC     HL
    LD      A, ($71E7)                  ; RAM $71E7
    INC     A
    LD      ($71E7), A                  ; RAM $71E7
    LD      A, (HL)
    AND     D
    JR      NZ, LOC_98E8
    DJNZ    LOC_98C7
    JR      LOC_98DF

LOC_98D7:
    LD      A, ($71E7)                  ; RAM $71E7
    ADD     A, $08
    LD      ($71E7), A                  ; RAM $71E7

LOC_98DF:
    POP     HL
    LD      DE, $0020
    ADD     HL, DE
    POP     BC
    DJNZ    LOC_98B4
    RET     

LOC_98E8:
    POP     HL
    POP     HL
    RET     

SUB_98EB:
    DB      $EB
    CALL    SUB_9FDD
    LD      A, ($72EA)                  ; RAM $72EA
    OR      A
    RET     

SOUND_WRITE_98F4:
    SRL     A
    SUB     $5E
    NEG     
    LD      ($71E8), A                  ; RAM $71E8
    AND     $F8
    LD      L, A
    LD      H, $00
    ADD     HL, HL
    ADD     HL, HL
    DB      $EB
    LD      HL, ($7134)                 ; RAM $7134
    ADD     HL, DE
    LD      DE, $0010
    ADD     HL, DE
    PUSH    HL
    LD      A, $FF
    LD      ($71E3), A                  ; RAM $71E3
    LD      ($71E4), A                  ; RAM $71E4
    LD      A, $F8
    LD      ($71E7), A                  ; RAM $71E7
    CALL    SUB_9943
    NEG     
    ADD     A, A
    SUB     $90
    NEG     
    LD      ($71DB), A                  ; RAM $71DB
    POP     HL
    LD      A, $01
    LD      ($71E3), A                  ; RAM $71E3
    XOR     A
    LD      ($71E4), A                  ; RAM $71E4
    LD      A, $08
    LD      ($71E7), A                  ; RAM $71E7
    CALL    SUB_9943
    SUB     $08
    ADD     A, A
    ADD     A, $7F
    LD      ($71DF), A                  ; RAM $71DF
    RET     

SUB_9943:
    XOR     A
    LD      ($71D7), A                  ; RAM $71D7
    LD      B, $08
    DB      $EB

LOC_994A:
    PUSH    DE
    PUSH    BC
    CALL    SUB_9FDD
    LD      A, ($72EA)                  ; RAM $72EA
    OR      A
    JR      Z, LOC_9976
    LD      A, ($72EA)                  ; RAM $72EA
    LD      L, A
    LD      H, $00
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    DB      $EB
    LD      HL, ($7136)                 ; RAM $7136
    ADD     HL, DE
    LD      A, ($71E8)                  ; RAM $71E8
    AND     $07
    LD      E, A
    LD      D, $00
    ADD     HL, DE
    DB      $EB
    CALL    SUB_9FDD
    LD      A, ($72EA)                  ; RAM $72EA
    OR      A
    JR      NZ, LOC_998C

LOC_9976:
    POP     BC
    POP     DE
    LD      HL, ($71E3)                 ; RAM $71E3
    ADD     HL, DE
    DB      $EB
    LD      A, ($71D7)                  ; RAM $71D7
    LD      L, A
    LD      A, ($71E7)                  ; RAM $71E7
    ADD     A, L
    LD      ($71D7), A                  ; RAM $71D7
    DJNZ    LOC_994A
    JR      LOC_99A4

LOC_998C:
    POP     BC
    POP     DE
    LD      B, A
    LD      A, ($71E3)                  ; RAM $71E3
    INC     A
    LD      A, ($71D7)                  ; RAM $71D7
    JR      Z, LOC_999F

LOC_9998:
    INC     A
    RL      B
    JR      NC, LOC_9998
    JR      LOC_99A4

LOC_999F:
    DEC     A
    RR      B
    JR      NC, LOC_999F

LOC_99A4:
    RET     

SUB_99A5:
    LD      IX, $7183                   ; RAM $7183
    LD      B, $0A

LOC_99AB:
    LD      A, (IX+1)
    OR      A
    JP      Z, LOC_9A61
    PUSH    BC
    AND     $07
    ADD     A, $88
    LD      ($71D7), A                  ; RAM $71D7
    CALL    SUB_9BA1
    LD      A, (IX+0)
    SRL     A
    SRL     A
    SRL     A
    LD      B, A
    LD      A, (IX+2)
    ADD     A, (IX+0)
    SRL     A
    SRL     A
    SRL     A
    SUB     B
    INC     A
    LD      B, A
    LD      A, (IX+0)
    AND     $07
    LD      E, A
    LD      D, $00
    LD      HL, $9A6C
    ADD     HL, DE
    LD      A, (HL)
    LD      ($7181), A                  ; RAM $7181

LOC_99E6:
    PUSH    IY
    POP     DE
    LD      A, ($7135)                  ; RAM $7135
    CP      $18
    LD      A, D
    JR      NZ, LOC_99FA
    CP      $18
    JP      C, LOC_9A60
    CP      $1B
    JR      LOC_9A01

LOC_99FA:
    CP      $10
    JP      C, LOC_9A60
    CP      $14

LOC_9A01:
    JP      NC, LOC_9A60
    PUSH    BC
    CALL    SUB_9FDD
    LD      A, ($7181)                  ; RAM $7181
    INC     A
    JR      NZ, LOC_9A1F
    LD      A, ($72EA)                  ; RAM $72EA
    OR      A
    JR      NZ, LOC_9A1F
    PUSH    IY
    POP     HL
    LD      A, ($71D7)                  ; RAM $71D7
    CALL    SUB_A000
    JR      LOC_9A3C

LOC_9A1F:
    LD      A, ($717F)                  ; RAM $717F
    INC     A
    JR      Z, LOC_9A3C
    CALL    SUB_9B65
    LD      A, (IX+1)
    AND     $07
    LD      E, A
    LD      D, $00
    LD      HL, $72EA                   ; RAM $72EA
    ADD     HL, DE
    LD      A, ($7181)                  ; RAM $7181
    OR      (HL)
    LD      (HL), A
    CALL    SUB_9B83

LOC_9A3C:
    LD      A, $FF
    LD      ($7181), A                  ; RAM $7181
    INC     IY
    POP     BC
    LD      A, B
    CP      $02
    JR      NZ, LOC_9A5C
    LD      A, (IX+0)
    ADD     A, (IX+2)
    AND     $07
    LD      E, A
    LD      D, $00
    LD      HL, $9A74
    ADD     HL, DE
    LD      A, (HL)
    LD      ($7181), A                  ; RAM $7181

LOC_9A5C:
    DEC     B
    JP      NZ, LOC_99E6

LOC_9A60:
    POP     BC

LOC_9A61:
    INC     IX
    INC     IX
    INC     IX
    DEC     B
    JP      NZ, LOC_99AB
    RET     
    DB      $FF, $7F, $3F, $1F, $0F, $07, $03, $01
    DB      $80, $C0, $E0, $F0, $F8, $FC, $FE, $FF

SUB_9A7C:
    LD      A, $B0
    LD      ($717F), A                  ; RAM $717F
    LD      IX, $7161                   ; RAM $7161
    LD      B, $0A

LOC_9A87:
    LD      A, (IX+1)
    OR      A
    JP      Z, LOC_9B5A
    PUSH    BC
    LD      A, (IX+0)
    AND     $07
    LD      E, A
    ADD     A, $80
    LD      ($71D7), A                  ; RAM $71D7
    LD      D, $00
    LD      HL, $8C7F
    ADD     HL, DE
    LD      A, (HL)
    LD      ($71D8), A                  ; RAM $71D8
    CALL    SUB_9BA1
    LD      A, (IX+1)
    SRL     A
    SRL     A
    SRL     A
    LD      B, A
    LD      A, (IX+2)
    ADD     A, (IX+1)
    SRL     A
    SRL     A
    SRL     A
    SUB     B
    INC     A
    LD      B, A
    LD      A, (IX+1)
    AND     $07
    LD      ($7181), A                  ; RAM $7181

LOC_9AC8:
    PUSH    IY
    POP     DE
    LD      A, ($7135)                  ; RAM $7135
    CP      $18
    LD      A, D
    JR      NZ, LOC_9ADC
    CP      $18
    JP      C, LOC_9B59
    CP      $1B
    JR      LOC_9AE3

LOC_9ADC:
    CP      $10
    JP      C, LOC_9B59
    CP      $14

LOC_9AE3:
    JP      NC, LOC_9B59
    PUSH    BC
    LD      A, B
    LD      ($7182), A                  ; RAM $7182
    CALL    SUB_9FDD
    LD      A, ($7182)                  ; RAM $7182
    CP      $01
    JR      Z, LOC_9B0C
    LD      A, ($7181)                  ; RAM $7181
    OR      A
    JR      NZ, LOC_9B0C
    LD      A, ($72EA)                  ; RAM $72EA
    OR      A
    JR      NZ, LOC_9B0C
    PUSH    IY
    POP     HL
    LD      A, ($71D7)                  ; RAM $71D7
    CALL    SUB_A000
    JR      LOC_9B4B

LOC_9B0C:
    LD      A, ($717F)                  ; RAM $717F
    INC     A
    JR      Z, LOC_9B4B
    CALL    SUB_9B65
    LD      A, ($71D8)                  ; RAM $71D8
    LD      C, A
    LD      HL, $72EA                   ; RAM $72EA
    LD      B, $08
    LD      A, ($7181)                  ; RAM $7181
    AND     $07
    JR      Z, LOC_9B2F
    LD      E, A
    LD      D, $00
    ADD     HL, DE
    LD      A, $08
    SUB     E
    LD      B, A
    JR      LOC_9B42

LOC_9B2F:
    LD      A, ($7182)                  ; RAM $7182
    CP      $01
    JR      NZ, LOC_9B42
    LD      A, (IX+1)
    LD      B, A
    LD      A, (IX+2)
    ADD     A, B
    AND     $07
    INC     A
    LD      B, A

LOC_9B42:
    LD      A, (HL)
    OR      C
    LD      (HL), A
    INC     HL
    DJNZ    LOC_9B42
    CALL    SUB_9B83

LOC_9B4B:
    XOR     A
    LD      ($7181), A                  ; RAM $7181
    LD      BC, $0020
    ADD     IY, BC
    POP     BC
    DEC     B
    JP      NZ, LOC_9AC8

LOC_9B59:
    POP     BC

LOC_9B5A:
    INC     IX
    INC     IX
    INC     IX
    DEC     B
    JP      NZ, LOC_9A87
    RET     

SUB_9B65:
    PUSH    IY
    POP     HL
    LD      A, ($717F)                  ; RAM $717F
    CALL    SUB_A000
    LD      A, ($72EA)                  ; RAM $72EA

SUB_9B71:
    LD      L, A
    LD      H, $00
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    DB      $EB
    LD      HL, ($7136)                 ; RAM $7136
    ADD     HL, DE
    DB      $EB
    LD      BC, $0008
    JP      SUB_9FE5

SUB_9B83:
    LD      A, ($717F)                  ; RAM $717F
    LD      L, A
    LD      H, $00
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    DB      $EB
    LD      HL, ($7136)                 ; RAM $7136
    ADD     HL, DE
    LD      DE, $72EA                   ; RAM $72EA
    DB      $EB
    CALL    SUB_AC31
    LD      A, ($717F)                  ; RAM $717F
    INC     A
    RET     Z
    LD      ($717F), A                  ; RAM $717F
    RET     

SUB_9BA1:
    LD      A, (IX+1)
    AND     $F8
    LD      L, A
    LD      H, $00
    ADD     HL, HL
    ADD     HL, HL
    LD      A, (IX+0)
    SRL     A
    SRL     A
    SRL     A
    LD      E, A
    LD      D, $00
    ADD     HL, DE
    DB      $EB
    LD      HL, ($7134)                 ; RAM $7134
    ADD     HL, DE
    PUSH    HL
    POP     IY
    RET     

SUB_9BC1:
    LD      E, (IX+4)
    LD      D, (IX+5)
    LD      HL, ($7134)                 ; RAM $7134
    ADD     HL, DE
    CALL    SUB_9BFC
    INC     DE

LOC_9BCF:
    PUSH    DE
    LD      A, (DE)
    SRL     A
    SRL     A
    ADD     A, (IX+7)
    CALL    SUB_A000
    POP     DE
    PUSH    DE
    LD      A, (DE)
    AND     $03
    JR      Z, LOC_9BFA
    OR      (IX+6)
    ADD     A, A
    LD      E, A
    LD      D, $00
    LD      IY, $9C0D
    ADD     IY, DE
    LD      E, (IY+0)
    LD      D, (IY+1)
    ADD     HL, DE
    POP     DE
    INC     DE
    JR      LOC_9BCF

LOC_9BFA:
    POP     DE
    RET     

SUB_9BFC:
    ADD     A, A
    LD      E, A
    LD      D, $00
    LD      IY, $9C2D
    ADD     IY, DE
    LD      E, (IY+0)
    LD      D, (IY+1)
    RET     
    DB      $00, $00, $E0, $FF, $01, $00, $E1, $FF
    DB      $00, $00, $20, $00, $01, $00, $21, $00
    DB      $00, $00, $E0, $FF, $FF, $FF, $DF, $FF
    DB      $00, $00, $20, $00, $FF, $FF, $1F, $00
    DB      $47, $9C, $51, $9C, $5B, $9C, $65, $9C
    DB      $6F, $9C, $7C, $9C, $8C, $9C, $96, $9C
    DB      $A6, $9C, $B3, $9C, $BD, $9C, $C7, $9C
    DB      $D1, $9C, $00, $01, $05, $09, $0D, $11
    DB      $15, $19, $1F, $00, $08, $01, $05, $09
    DB      $0F, $01, $05, $09, $0F, $00, $0C, $01
    DB      $05, $0B, $01, $05, $0B, $01, $05, $08
    DB      $0F, $01, $07, $01, $07, $01, $07, $01
    DB      $07, $00, $11, $01, $06, $09, $0F, $01
    DB      $06, $09, $0F, $01, $06, $09, $0C, $15
    DB      $01, $06, $09, $0E, $11, $16, $19, $1F
    DB      $01, $06, $09, $0E, $11, $16, $18, $1D
    DB      $03, $03, $03, $03, $03, $03, $03, $03
    DB      $00, $33, $02, $05, $0A, $0D, $12, $15
    DB      $1A, $1F, $02, $05, $0A, $0D, $12, $15
    DB      $18, $2F, $02, $05, $0A, $0F, $02, $05
    DB      $0A, $0F, $02, $05, $0A, $0C, $2D, $02
    DB      $07, $02, $07, $02, $07, $02, $07, $00
    DB      $2A, $02, $06, $0B, $02, $06, $0B, $02
    DB      $06, $08, $26, $02, $06, $0A, $0F, $02
    DB      $06, $0A, $0F, $00, $1E, $02, $06, $0A
    DB      $0E, $12, $16, $1A, $1F, $00

SUB_9CDB:                                  ; SUB_9CDB: recalculate 4 perspective crosshair corner positions
    LD      A, ($7053)                     ; A = ($7053): game phase
    CP      $02                            ; CP $02: only run in phase 2 (trench approach)
    RET     NZ                             ; RET NZ: skip if not phase 2
    LD      A, ($71F0)                     ; A = ($71F0): crosshair X
    LD      L, A                           ; L = X
    LD      A, ($71EF)                     ; A = ($71EF): crosshair Y
    ADD     A, $20                         ; ADD A, $20: Y + $20 offset
    LD      E, A                           ; E = Y+$20
    CALL    SUB_9D2A                       ; SUB_9D2A: perspective scale lookup -> A
    LD      ($7138), A                     ; ($7138) = result: corner 0 tile (top-right)
    LD      A, ($71F0)                     ; A = ($71F0)
    NEG                                    ; NEG: negate X
    LD      L, A                           ; L = -X
    LD      A, ($71EF)                     ; A = ($71EF)
    ADD     A, $20                         ; ADD A, $20
    LD      E, A                           ; E = Y+$20
    CALL    SUB_9D2A                       ; SUB_9D2A
    LD      ($7142), A                     ; ($7142) = corner 1 tile (top-left)
    LD      A, ($71F0)                     ; A = ($71F0)
    LD      L, A                           ; L = X
    LD      A, ($71EF)                     ; A = ($71EF)
    ADD     A, $20                         ; ADD A, $20
    NEG                                    ; NEG: negate Y
    LD      E, A                           ; E = -(Y+$20)
    CALL    SUB_9D2A                       ; SUB_9D2A
    LD      ($714C), A                     ; ($714C) = corner 2 tile (bottom-right)
    LD      A, ($71F0)                     ; A = ($71F0)
    NEG                                    ; NEG
    LD      L, A                           ; L = -X
    LD      A, ($71EF)                     ; A = ($71EF)
    ADD     A, $20                         ; ADD A, $20
    NEG                                    ; NEG
    LD      E, A                           ; E = -(Y+$20)
    CALL    SUB_9D2A                       ; SUB_9D2A
    LD      ($7156), A                     ; ($7156) = corner 3 tile (bottom-left)
    RET                                    ; RET

SUB_9D2A:                                  ; SUB_9D2A: look up perspective scale factor (0-$20 range clamp, table at $9D3F)
    LD      H, $00                         ; H = $00
    LD      D, H                           ; D = H
    CALL    DELAY_LOOP_AB27                ; DELAY_LOOP_AB27: compute scaled position HL = L * E
    CP      $20                            ; CP $20: clamp to $20
    JR      C, LOC_9D36                    ; JR C: if < $20, keep
    LD      A, $20                         ; A = $20: clamp

LOC_9D36:                                  ; LOC_9D36: table lookup
    LD      E, A                           ; E = A
    LD      D, $00                         ; D = $00
    LD      HL, $9D3F                      ; HL = $9D3F: perspective scale table
    ADD     HL, DE                         ; HL += E: index into table
    LD      A, (HL)                        ; A = (HL): scale value
    RET                                    ; RET
    DB      $00, $01, $02, $03, $04, $05, $05, $06
    DB      $06, $06, $07, $07, $07, $07, $08, $08
    DB      $08, $08, $09, $09, $09, $09, $0A, $0A
    DB      $0A, $0A, $0B, $0B, $0B, $0B, $0B, $0B
    DB      $0B, $0B

SUB_9D61:                                  ; SUB_9D61: phase=3 handler (bonus scoring / game-over / attract sequence)
    LD      A, ($712F)                  ; RAM $712F
    INC     A
    CP      $03
    JR      NZ, LOC_9D6A
    XOR     A

LOC_9D6A:
    LD      ($712F), A                  ; RAM $712F
    OR      A
    JR      Z, LOC_9D78
    CP      $01
    JR      Z, LOC_9D7B
    CP      $02
    JR      Z, LOC_9D7E

LOC_9D78:
    JP      SUB_9254

LOC_9D7B:
    JP      SUB_8BD1

LOC_9D7E:
    LD      A, ($706A)                  ; RAM $706A
    CP      $04
    RET     Z
    LD      A, ($7054)                  ; RAM $7054
    OR      A
    JR      NZ, LOC_9DDD
    LD      DE, $012B
    LD      IY, $A7C2
    CALL    DELAY_LOOP_A3D7
    CALL    SUB_AB85
    ADD     A, L
    NOP     
    JR      LOC_9E0B
    DB      $61, $72, $6B, $65, $72, $00, $62, $72
    DB      $6F, $74, $68, $65, $72, $73, $00, $70
    DB      $72, $65, $73, $65, $6E, $74, $73, $CD
    DB      $85, $AB, $0A, $02, $0E, $63, $6F, $70
    DB      $79, $72, $69, $67, $68, $74, $00, $31
    DB      $39, $38, $34, $CD, $85, $AB, $4A, $02
    DB      $0E, $7E, $00, $00, $6C, $66, $6C, $00
    DB      $7F, $00, $61, $74, $61, $72, $69, $C3
    DB      $64, $B1

LOC_9DDD:
    CALL    SUB_AB85
    ADD     A, (HL)
    NOP     
    INC     D
    LD      H, H
    LD      H, L
    LD      H, C
    LD      (HL), H
    LD      L, B
    NOP     
    LD      (HL), E
    LD      (HL), H
    LD      H, C
    LD      (HL), D
    NOP     
    LD      H, H
    LD      H, L
    LD      (HL), E
    LD      (HL), H
    LD      (HL), D
    LD      L, A
    LD      A, C
    LD      H, L
    LD      H, H
    CALL    SUB_AB85
    INC     HL
    LD      BC, $701B                   ; RAM $701B
    LD      L, A
    LD      L, C
    LD      L, (HL)
    LD      (HL), H
    LD      (HL), E
    NOP     
    LD      H, (HL)
    LD      L, A
    LD      (HL), D
    NOP     
    LD      (HL), D
    LD      H, L
    LD      L, L

LOC_9E0B:
    LD      H, C
    LD      L, C
    LD      L, (HL)
    LD      L, C
    LD      L, (HL)
    LD      H, A
    NOP     
    LD      (HL), E
    LD      L, B
    LD      L, C
    LD      H, L
    LD      L, H
    LD      H, H
    LD      A, ($7063)                  ; RAM $7063
    LD      DE, $014B
    CALL    SOUND_WRITE_A395
    CALL    SUB_AB85
    LD      C, (HL)
    LD      BC, $7807                   ; RAM $7807
    NOP     
    DEC     (HL)
    DEC     SP
    JR      NC, LOC_9E5D
    JR      NC, LOC_9E6D
    RET     NC
    LD      ($7217), A                  ; RAM $7217
    LD      A, ($7063)                  ; RAM $7063
    LD      B, A
    ADD     A, $03
    CP      $09
    JR      C, LOC_9E3F
    LD      A, $09

LOC_9E3F:
    SUB     B
    LD      ($7064), A                  ; RAM $7064
    LD      DE, $01A8
    CALL    SOUND_WRITE_A395
    CALL    SUB_AB85
    XOR     E
    LD      BC, $610F                   ; RAM $610F
    LD      H, H
    LD      H, H
    LD      H, L
    LD      H, H
    NOP     
    LD      (HL), H
    LD      L, A
    NOP     
    LD      (HL), E
    LD      L, B
    LD      L, C
    LD      H, L
    LD      L, H

LOC_9E5D:
    LD      H, H
    RET     

SUB_9E5F:                                  ; SUB_9E5F: enemy/object animation tick (4 records at $70D5, anim via $A090 table)
    LD      A, ($70D3)                     ; A = ($70D3): animation frame counter (0-5)
    INC     A                              ; INC A
    CP      $06                            ; CP $06: wrap at 6
    JR      NZ, LOC_9E68                   ; JR NZ: keep if < 6
    XOR     A                              ; XOR A: wrap to 0

LOC_9E68:                                  ; LOC_9E68: process 4 object records
    LD      ($70D3), A                     ; ($70D3) = updated anim counter
    LD      IY, $71F7                      ; IY = $71F7: sprite parameter block
    LD      IX, $70D5                      ; IX = $70D5: first enemy object record
    LD      B, $04                         ; B = $04: 4 objects

LOC_9E75:                                  ; LOC_9E75: per-object loop
    PUSH    BC                             ; save BC
    LD      A, (IX+1)                      ; A = (IX+1): object active flag
    OR      A                              ; OR A: test active
    JP      Z, LOC_9F8B                    ; JP Z: inactive, skip
    LD      A, (IX+8)                      ; A = (IX+8): object type index
    ADD     A, A                           ; ADD A,A / ADD A,A / ADD A,A / ADD A,A: A = type * 16
    ADD     A, A                           ; ADD A,A
    ADD     A, A                           ; ADD A,A
    ADD     A, A                           ; ADD A,A
    LD      E, A                           ; E = A
    LD      D, $00                         ; D = $00
    ADD     A, A                           ; ADD A,A: A = type * 32
    LD      HL, $A090                      ; HL = $A090: animation data table
    ADD     HL, DE                         ; HL += E: point to type entry
    LD      A, (HL)                        ; A = (HL): tile base for this object type
    LD      (IY+2), A                      ; (IY+2) = tile base
    INC     HL                             ; INC HL
    LD      A, ($70D3)                     ; A = ($70D3): anim frame counter
    ADD     A, A                           ; ADD A,A
    LD      E, A                           ; E = frame * 2
    ADD     HL, DE                         ; HL += E: index into frame sequence
    LD      A, (HL)                        ; A = (HL): frame Y offset
    ADD     A, (IX+1)                      ; ADD A, (IX+1): add object Y pos
    LD      (IY+1), A                      ; (IY+1) = sprite Y
    INC     HL                             ; INC HL
    LD      A, (HL)                        ; A = (HL): frame X offset
    ADD     A, (IX+5)                      ; ADD A, (IX+5): add object X pos
    LD      (IY+0), A                      ; (IY+0) = sprite X
    CALL    SUB_AB3C                       ; SUB_AB3C: compute sprite tile and attributes
    LD      A, ($7053)                     ; A = ($7053): game phase
    CP      $01                            ; CP $01: targeting phase?
    JR      Z, LOC_9EED                    ; JR Z: targeting - different sprite update
    CP      $02                            ; CP $02: trench phase?
    JR      NZ, LOC_9F07                   ; JR NZ: other phase
    LD      B, $00
    LD      A, ($71EF)                  ; RAM $71EF
    CP      $18
    JR      Z, LOC_9ECC
    CP      $A0
    JR      Z, LOC_9ECC
    LD      A, ($7068)                  ; RAM $7068
    SUB     $80
    SRA     A
    SRA     A
    ADD     A, B
    LD      B, A

LOC_9ECC:
    LD      A, B
    ADD     A, $80
    CALL    DELAY_LOOP_9F9E
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    LD      E, (IX+4)
    LD      D, (IX+5)
    ADD     HL, DE
    LD      (IX+4), L
    LD      (IX+5), H
    LD      A, ($71F0)                  ; RAM $71F0
    CP      $28
    JR      Z, LOC_9F07
    CP      $D0
    JR      Z, LOC_9F07

LOC_9EED:
    LD      A, ($7067)                  ; RAM $7067
    CALL    DELAY_LOOP_9F9E
    LD      A, ($7053)                  ; RAM $7053
    DEC     A
    JR      Z, LOC_9EFA
    ADD     HL, HL

LOC_9EFA:
    LD      E, (IX+0)
    LD      D, (IX+1)
    ADD     HL, DE
    LD      (IX+0), L
    LD      (IX+1), H

LOC_9F07:
    LD      A, (IX+1)
    CP      $30
    JR      C, LOC_9F3C
    CP      $C8
    JR      NC, LOC_9F3C
    LD      A, (IX+5)
    CP      $20
    JR      C, LOC_9F3C
    CP      $98
    JR      NC, LOC_9F3C
    LD      D, $3F
    LD      A, ($7053)                  ; RAM $7053
    OR      A
    JR      Z, LOC_9F27
    LD      D, $1F

LOC_9F27:
    LD      A, ($71ED)                  ; RAM $71ED
    AND     D
    JR      NZ, LOC_9F85
    LD      A, (IX+8)
    INC     A
    CP      $06
    JR      NZ, LOC_9F82
    LD      A, ($7053)                  ; RAM $7053
    CP      $02
    JR      NZ, LOC_9F6E

LOC_9F3C:
    LD      A, ($7053)                  ; RAM $7053
    CP      $02
    JR      NZ, LOC_9F76
    LD      A, ($71EF)                  ; RAM $71EF
    CP      $28
    JR      NC, LOC_9F4C
    LD      A, $28

LOC_9F4C:
    CP      $90
    JR      C, LOC_9F52
    LD      A, $90

LOC_9F52:
    LD      D, A
    LD      A, (IX+5)
    SUB     D
    JP      P, LOC_9F5C
    NEG     

LOC_9F5C:
    CP      $28
    JR      NC, LOC_9F76
    LD      A, (IX+1)
    AND     $80
    LD      D, A
    LD      A, ($71F0)                  ; RAM $71F0
    AND     $80
    SUB     D
    JR      NZ, LOC_9F76

LOC_9F6E:
    CALL    SUB_AAD5
    LD      B, $01
    CALL    SUB_ABEE

LOC_9F76:
    XOR     A
    LD      (IX+5), A
    LD      (IX+1), A
    LD      A, $C8
    LD      (IY+0), A

LOC_9F82:
    LD      (IX+8), A

LOC_9F85:
    LD      A, (IY+3)
    INC     A
    AND     $0F

LOC_9F8B:
    LD      (IY+3), A
    LD      DE, $0009
    ADD     IX, DE
    LD      DE, $0004
    ADD     IY, DE
    POP     BC
    DEC     B
    JP      NZ, LOC_9E75
    RET     

DELAY_LOOP_9F9E:
    NEG     
    LD      L, A
    LD      H, $00
    LD      DE, $0080
    OR      A
    SBC     HL, DE
    DB      $EB
    LD      A, (IX+8)
    ADD     A, $05
    LD      B, A
    LD      HL, BOOT_UP

LOC_9FB3:
    ADD     HL, DE
    DJNZ    LOC_9FB3
    ADD     HL, HL
    ADD     HL, HL
    RET     

SUB_9FB9:                                  ; SUB_9FB9: fill VRAM at HL with A=0, count DE (JP FILL_VRAM)
    XOR     A                              ; XOR A: A = 0

LOC_9FBA:                                  ; LOC_9FBA: JP FILL_VRAM
    JP      FILL_VRAM                      ; JP FILL_VRAM: fill VRAM (tail call)
    DB      $06, $0A, $CD, $EE, $AB, $06, $0B, $CD
    DB      $EE, $AB, $06, $0C, $C3, $EE, $AB

SUB_9FCC:
    PUSH    DE
    PUSH    BC
    CALL    SUB_A000
    POP     BC
    POP     DE
    RET     

SUB_9FD4:                                  ; SUB_9FD4: zero-fill DE bytes of RAM at HL
    XOR     A                              ; XOR A
    LD      (HL), A                        ; (HL) = 0
    INC     HL                             ; INC HL
    DEC     DE                             ; DEC DE
    LD      A, D                           ; A = D
    OR      E                              ; OR E: test if DE=0
    JR      NZ, SUB_9FD4                   ; JR NZ: loop until DE=0
    RET                                    ; RET

SUB_9FDD:
    LD      BC, $0001
    JR      SUB_9FE5

SUB_9FE2:
    LD      BC, $0020

SUB_9FE5:
    LD      HL, $72EA                   ; RAM $72EA
    JP      READ_VRAM
    DB      $3A, $58, $70, $3D, $87, $5F, $16, $00
    DB      $DD, $19, $DD, $6E, $00, $DD, $66, $01
    DB      $C9, $00, $00, $00, $00

SUB_A000:
    LD      DE, $0001
    JP      LOC_9FBA

SUB_A006:                                  ; SUB_A006: SOUND_INIT wrapper (B=4 channels, HL=$B217 song table)
    LD      B, $04                         ; B = $04
    LD      HL, $B217                      ; HL = $B217: song/sound data table
    JP      SOUND_INIT                     ; JP SOUND_INIT (tail call)

SUB_A00E:
    LD      IY, $AAC9
    JP      LOC_AC71

SUB_A015:
    LD      A, $B0

SUB_A017:
    LD      HL, $2010
    LD      DE, $0010
    JP      FILL_VRAM

SUB_A020:
    LD      A, ($7058)                  ; RAM $7058
    INC     A
    INC     A
    LD      B, A
    LD      A, ($70D4)                  ; RAM $70D4
    ADD     A, B
    LD      ($70D4), A                  ; RAM $70D4
    CP      C
    RET     C
    XOR     A
    LD      ($70D4), A                  ; RAM $70D4
    LD      A, H
    CP      $30
    RET     C
    CP      $C8
    RET     NC
    LD      A, L
    CP      $20
    RET     C
    CP      $98
    RET     NC
    LD      IX, $70D5                   ; RAM $70D5
    LD      B, $04

LOC_A047:
    LD      A, (IX+1)
    OR      A
    JR      Z, LOC_A055
    LD      DE, $0009
    ADD     IX, DE
    DJNZ    LOC_A047
    RET     

LOC_A055:
    LD      (IX+1), H
    LD      (IX+5), L
    XOR     A
    LD      (IX+8), A
    LD      A, $80
    LD      (IX+3), A
    LD      (IX+7), A
    LD      A, H
    SUB     $80
    SRA     A
    ADD     A, $80
    LD      (IX+2), A
    LD      A, L
    SUB     $60
    SRA     A
    SRA     A
    ADD     A, $80
    LD      (IX+6), A
    LD      A, ($7053)                  ; RAM $7053
    OR      A
    JR      NZ, LOC_A08B
    LD      A, $80
    LD      (IX+2), A
    LD      (IX+6), A

LOC_A08B:
    LD      B, $02
    JP      SUB_ABEE
    DB      $F8, $00, $00, $FF, $FF, $01, $01, $00
    DB      $00, $FF, $01, $01, $FF, $00, $00, $00
    DB      $F8, $00, $00, $FE, $FF, $02, $02, $00
    DB      $FE, $FE, $02, $02, $FF, $00, $00, $00
    DB      $F8, $00, $00, $FD, $FE, $03, $03, $00
    DB      $FD, $FD, $03, $03, $FE, $00, $00, $00
    DB      $FC, $00, $00, $FE, $FF, $02, $02, $00
    DB      $FE, $FE, $02, $02, $FF, $00, $00, $00
    DB      $FC, $00, $00, $FC, $FE, $04, $04, $00
    DB      $FC, $FC, $04, $04, $FC, $00, $00, $00
    DB      $FC, $00, $00, $F8, $FD, $06, $06, $00
    DB      $F4, $FA, $06, $08, $FD, $00, $00, $00

SUB_A0F0:                                  ; SUB_A0F0: player sprite update (hit flash, VDP tile, INIT_TABLE)
    LD      A, ($7066)                     ; A = ($7066): player hit-flash timer
    OR      A                              ; OR A: test timer
    JR      Z, LOC_A117                    ; JR Z: no flash, skip to LOC_A117
    DEC     A                              ; DEC A: decrement timer
    LD      ($7066), A                     ; ($7066) = decremented timer
    BIT     1, A                           ; BIT 1, A: even flash frame?
    JR      NZ, LOC_A103                   ; JR NZ: odd frame, use $37C0 tile
    LD      HL, $2000                      ; HL = $2000: even flash frame tile
    JR      LOC_A112                       ; JR LOC_A112

LOC_A103:                                  ; LOC_A103: odd flash frame
    LD      HL, $37C0                      ; HL = $37C0: alternate tile during flash
    BIT     0, A                           ; BIT 0, A: alternation bit
    JR      Z, LOC_A112                    ; JR Z: use $37C0
    LD      A, ($7271)                     ; A = ($7271): shield flag
    OR      A                              ; OR A
    JR      Z, LOC_A112                    ; JR Z: no shield, use base tile
    LD      L, $80                         ; L = $80: shield flash tile

LOC_A112:                                  ; LOC_A112: INIT_TABLE to update player tile
    LD      A, $04                         ; A = $04: INIT_TABLE table #4 (sprite-attr)
    CALL    INIT_TABLE                     ; INIT_TABLE: update sprite attribute table with HL base

LOC_A117:                                  ; LOC_A117: player sprite animation (IX=$70AF player record, $70AE anim frame)
    LD      IX, $70AF                      ; IX = $70AF: player object record
    LD      A, (IX+1)                      ; A = (IX+1): player active flag
    OR      A                              ; OR A: test active
    RET     Z                              ; RET Z: not active
    LD      A, ($70AE)                     ; A = ($70AE): animation frame (0-2, cycles)
    INC     A                              ; INC A
    CP      $03                            ; CP $03: wrap at 3
    JR      C, LOC_A129                    ; JR C: keep if < 3
    XOR     A                              ; XOR A: wrap to 0

LOC_A129:                                  ; LOC_A129: A = frame * 6 (stride into player sprite table)
    LD      ($70AE), A                     ; ($70AE) = updated frame
    ADD     A, A                           ; ADD A,A: A * 2
    ADD     A, A                           ; ADD A,A: A * 4
    LD      B, A                           ; B = A
    ADD     A, B                           ; ADD A,B: A * 6
    ADD     A, B                           ; ADD A,B
    LD      E, A                           ; E = A * 6: table index
    LD      D, $00                         ; D = $00
    ADD     IX, DE                         ; IX += DE: advance to current frame block
    LD      A, (IX+11)                     ; A = (IX+11): sub-frame counter
    INC     A                              ; INC A
    AND     $03                            ; AND $03: mod 4
    LD      (IX+11), A                     ; (IX+11) = updated sub-frame
    JR      NZ, LOC_A163                   ; JR NZ: if not 0, skip tile update
    LD      E, (IX+10)                     ; E = (IX+10): tile sequence index
    LD      D, $00                         ; D = $00
    LD      HL, $A1CA                      ; HL = $A1CA: player tile sequence table
    ADD     HL, DE                         ; HL += E
    LD      A, (HL)                        ; A = (HL): next tile index
    LD      (IX+3), A                      ; (IX+3) = tile: update sprite tile
    OR      A                              ; OR A
    JR      Z, LOC_A192                    ; JR Z: tile=0, handle end of sequence
    INC     HL
    LD      A, (HL)
    LD      (IX+7), A
    INC     HL
    LD      A, (HL)
    LD      (IX+8), A
    LD      A, (IX+10)
    ADD     A, $03
    LD      (IX+10), A

LOC_A163:
    PUSH    IX
    CALL    SUB_A1A3
    INC     IX
    INC     IX
    INC     IX
    INC     IX
    CALL    SUB_A1A3
    POP     IX
    LD      IY, $7213                   ; RAM $7213
    LD      A, (IX+5)
    LD      (IY+0), A
    LD      A, (IX+1)
    LD      (IY+1), A
    LD      A, (IX+8)
    LD      (IY+2), A
    LD      A, (IX+9)
    LD      (IY+3), A
    RET     

LOC_A192:
    XOR     A
    LD      (IX+1), A
    LD      (IY+3), A
    LD      IY, $7213                   ; RAM $7213
    LD      A, $C8
    LD      (IY+0), A
    RET     

SUB_A1A3:
    LD      A, (IX+3)
    ADD     A, (IX+2)
    SUB     $80
    LD      (IX+2), A
    LD      L, A
    LD      H, $00
    LD      DE, $0080
    OR      A
    SBC     HL, DE
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    LD      E, (IX+0)
    LD      D, (IX+1)
    ADD     HL, DE
    LD      (IX+0), L
    LD      (IX+1), H
    RET     
    DB      $82, $84, $E8, $80, $82, $EC, $80, $80
    DB      $F4, $80, $80, $F0, $80, $80, $E8, $80
    DB      $80, $EC, $00, $83, $84, $E8, $80, $83
    DB      $EC, $80, $80, $F4, $80, $80, $F0, $80
    DB      $80, $E8, $80, $80, $EC, $00, $7E, $85
    DB      $F0, $7F, $80, $F4, $80, $7F, $EC, $80
    DB      $80, $EC, $80, $80, $E8, $80, $80, $E8
    DB      $00, $7D, $83, $F0, $7D, $80, $F4, $80
    DB      $80, $EC, $80, $80, $EC, $80, $80, $E8
    DB      $80, $80, $E8, $00, $81, $7C, $EC, $80
    DB      $80, $EC, $80, $7F, $F4, $81, $80, $F4
    DB      $80, $80, $F4, $80, $80, $F0, $80, $80
    DB      $F0, $00, $82, $7C, $F0, $80, $80, $F0
    DB      $80, $7F, $F4, $7E, $82, $F4, $80, $80
    DB      $F4, $80, $80, $EC, $80, $80, $EC, $00

DELAY_LOOP_A242:
    LD      A, ($71C4)                  ; RAM $71C4
    LD      L, A
    LD      A, ($71C3)                  ; RAM $71C3
    LD      H, A
    LD      IX, $70AF                   ; RAM $70AF
    LD      B, $03

LOC_A250:
    LD      (IX+1), H
    LD      A, $80
    LD      (IX+3), A
    LD      (IX+7), A
    LD      (IX+5), L
    LD      (IX+9), C
    XOR     A
    LD      (IX+11), A
    LD      DE, $000C
    ADD     IX, DE
    DJNZ    LOC_A250
    LD      IX, $70AF                   ; RAM $70AF
    LD      A, $6E
    LD      (IX+2), A
    LD      (IX+6), A
    LD      (IX+18), A
    LD      A, $96
    LD      (IX+14), A
    LD      A, $80
    LD      (IX+26), A
    LD      A, $96
    LD      (IX+30), A
    LD      B, $05
    CALL    SUB_ABEE
    LD      A, ($71ED)                  ; RAM $71ED
    AND     $08
    JR      Z, LOC_A2A2
    LD      A, $00
    LD      (IX+10), A
    LD      A, $26
    LD      (IX+22), A
    JR      LOC_A2AC

LOC_A2A2:
    LD      A, $13
    LD      (IX+10), A
    LD      A, $39
    LD      (IX+22), A

LOC_A2AC:
    LD      A, ($71ED)                  ; RAM $71ED
    AND     $10
    JR      Z, LOC_A2B9
    LD      A, $4C
    LD      (IX+34), A
    RET     

LOC_A2B9:
    LD      A, $62
    LD      (IX+34), A
    RET     

SUB_A2BF:
    PUSH    IX
    LD      IX, $705A                   ; RAM $705A
    LD      A, (IX+0)
    ADD     A, $03
    LD      (IX+0), A
    LD      A, (IX+1)
    ADD     A, $03
    LD      (IX+1), A
    JR      LOC_A320
    DB      $DD, $E5, $DD, $21, $5A, $70, $DD, $7E
    DB      $01, $C6, $05, $DD, $77, $01, $18, $39

SUB_A2E7:
    PUSH    IX
    LD      IX, $705A                   ; RAM $705A
    INC     (IX+2)
    JR      LOC_A320
    DB      $DD, $E5, $DD, $21, $5A, $70, $DD, $7E
    DB      $02, $C6, $05, $DD, $77, $02, $18, $1E

SUB_A302:
    PUSH    IX
    LD      IX, $705A                   ; RAM $705A
    LD      A, (IX+3)
    ADD     A, $01
    LD      (IX+3), A
    JR      LOC_A320
    DB      $DD, $E5, $DD, $21, $5A, $70, $DD, $7E
    DB      $04, $C6, $05, $DD, $77, $04

LOC_A320:
    LD      IX, $705A                   ; RAM $705A
    LD      B, $08

LOC_A326:
    LD      A, (IX+0)
    CP      $0A
    JR      C, LOC_A337
    SUB     $0A
    LD      (IX+0), A
    INC     (IX+1)
    JR      LOC_A326

LOC_A337:
    INC     IX
    DJNZ    LOC_A326
    POP     IX
    RET     

SUB_A33E:
    PUSH    IX
    LD      HL, ($7134)                 ; RAM $7134
    LD      BC, $0022
    ADD     HL, BC
    LD      IX, $7061                   ; RAM $7061
    LD      B, $08
    XOR     A
    LD      ($71D7), A                  ; RAM $71D7

LOC_A351:
    LD      A, ($71D7)                  ; RAM $71D7
    OR      A
    JR      NZ, LOC_A361
    LD      A, B
    OR      A
    JR      Z, LOC_A361
    LD      A, (IX+0)
    OR      A
    JR      Z, LOC_A36B

LOC_A361:
    LD      A, (IX+0)
    ADD     A, $30
    LD      ($71D7), A                  ; RAM $71D7
    JR      LOC_A36C

LOC_A36B:
    XOR     A

LOC_A36C:
    PUSH    AF
    PUSH    HL
    CALL    SUB_A000
    POP     HL
    INC     HL
    LD      A, B
    CP      $07
    JR      Z, LOC_A37C
    CP      $04
    JR      NZ, LOC_A38D

LOC_A37C:
    POP     AF
    OR      A
    JR      Z, LOC_A384
    LD      A, $3B
    JR      LOC_A385

LOC_A384:
    XOR     A

LOC_A385:
    PUSH    HL
    CALL    SUB_A000
    POP     HL
    INC     HL
    JR      LOC_A38E

LOC_A38D:
    POP     AF

LOC_A38E:
    DEC     IX
    DJNZ    LOC_A351
    POP     IX
    RET     

SOUND_WRITE_A395:
    PUSH    DE
    LD      B, $FF

LOC_A398:
    INC     B
    SUB     $0A
    JP      P, LOC_A398
    PUSH    AF
    LD      A, B
    OR      A
    JR      Z, LOC_A3AC
    ADD     A, $30
    LD      HL, ($7134)                 ; RAM $7134
    ADD     HL, DE
    CALL    SUB_A000

LOC_A3AC:
    POP     AF
    ADD     A, $0A
    ADD     A, $30
    POP     DE
    INC     DE
    LD      HL, ($7134)                 ; RAM $7134
    ADD     HL, DE
    JP      SUB_A000
    DB      $CD, $CE, $A3, $CD, $B6, $AB, $CD, $64
    DB      $B1, $CD, $B9, $AE

SUB_A3C6:
    LD      HL, $0400
    LD      DE, $0080
    JR      LOC_A3D4

SUB_A3CE:
    LD      HL, $1800
    LD      DE, $0300

LOC_A3D4:
    JP      SUB_9FB9

DELAY_LOOP_A3D7:
    LD      HL, ($7134)                 ; RAM $7134
    ADD     HL, DE
    LD      C, (IY+0)
    INC     IY
    LD      D, (IY+0)
    INC     IY

LOC_A3E5:
    LD      B, D
    PUSH    DE
    PUSH    HL

LOC_A3E8:
    LD      A, (IY+0)
    INC     IY
    CALL    SUB_9FCC
    INC     HL
    DJNZ    LOC_A3E8
    POP     HL
    LD      DE, $0020
    ADD     HL, DE
    POP     DE
    DEC     C
    JR      NZ, LOC_A3E5
    RET     

DELAY_LOOP_A3FD:
    LD      IX, $7281                   ; RAM $7281
    LD      H, (IX+0)
    LD      L, $01
    CALL    DECODER
    LD      (IX+2), H
    LD      (IX+3), L
    LD      B, $1E

LOC_A411:
    DJNZ    LOC_A411
    LD      H, (IX+0)
    LD      L, $00
    CALL    DECODER
    LD      (IX+1), L
    LD      A, (IX+2)
    OR      H
    LD      (IX+2), A
    RET     

DELAY_LOOP_A426:
    LD      IX, $726F                   ; RAM $726F
    LD      IY, $727B                   ; RAM $727B
    LD      B, $06
    LD      C, $01

LOC_A432:
    LD      H, (IX+1)
    LD      L, (IX+0)
    LD      DE, $0001
    OR      A
    SBC     HL, DE
    JP      M, LOC_A44C
    JR      NZ, LOC_A446
    LD      (IY+0), C

LOC_A446:
    LD      (IX+1), H
    LD      (IX+0), L

LOC_A44C:
    INC     IY
    INC     IX
    INC     IX
    DJNZ    LOC_A432
    RET     

SUB_A455:                                  ; SUB_A455: main dispatch (B=6 slots, IX=$727B flags, IY=$810D function table)
    LD      B, $06                         ; B = $06: 6 dispatch slots
    LD      IX, $727B                      ; IX = $727B: slot active flags
    LD      IY, $810D                      ; IY = $810D: slot function pointer table

LOC_A45F:                                  ; LOC_A45F: slot dispatch loop
    LD      A, (IX+0)                      ; A = (IX+0): slot active flag
    OR      A                              ; OR A: test
    JR      Z, LOC_A47E                    ; JR Z: inactive slot, skip
    LD      L, (IY+0)                      ; L = (IY+0): function addr lo
    LD      H, (IY+1)                      ; H = (IY+1): function addr hi
    PUSH    BC                             ; save BC/IX/IY
    PUSH    IX
    PUSH    IY
    LD      DE, $A475                      ; DE = $A475: return address
    PUSH    DE                             ; PUSH DE: set return address
    JP      (HL)                           ; JP (HL): call slot function
    DB      $FD, $E1, $DD, $E1, $C1, $AF, $DD, $77
    DB      $00

LOC_A47E:                                  ; LOC_A47E: inactive slot
    CALL    READ_REGISTER                  ; READ_REGISTER: flush VDP interrupt
    INC     IX                             ; INC IX: next flag
    INC     IY                             ; INC IY / INC IY: next function ptr
    INC     IY                             ; DJNZ: loop 6 slots
    DJNZ    LOC_A45F                       ; RET
    RET     

SUB_A48A:                                  ; SUB_A48A: wait for controller button press (spin on $7282+$7283 sum)
    XOR     A                              ; XOR A
    LD      ($7281), A                     ; ($7281) = 0: clear input latch

LOC_A48E:                                  ; LOC_A48E: main wait loop
    LD      A, ($7281)                     ; A = ($7281)
    XOR     $01                            ; XOR $01: toggle input latch
    LD      ($7281), A                     ; ($7281) = toggled
    CALL    DELAY_LOOP_A3FD                ; DELAY_LOOP_A3FD: joystick poll
    LD      A, ($7282)                     ; A = ($7282): button state hi
    LD      B, A                           ; B = A
    LD      A, ($7283)                     ; A = ($7283): button state lo
    ADD     A, B                           ; ADD A,B: combine
    JR      Z, LOC_A48E                    ; JR Z: if zero (no button), loop
    RET                                    ; RET: button pressed
    DB      $CD, $DC, $AB, $CD, $37, $AC, $CD, $BD
    DB      $9F, $AF, $32, $53, $70, $32, $54, $70
    DB      $DD, $21, $6F, $8F, $CD, $EB, $9F, $22
    DB      $FD, $70, $CD, $BA, $A3, $CD, $80, $A5
    DB      $CD, $80, $A5, $CD, $A5, $AB, $07, $72
    DB      $0C, $00, $00, $A0, $00, $00, $00, $A4
    DB      $00, $00, $00, $A8, $00, $21, $05, $00
    DB      $22, $73, $72, $3E, $12, $32, $F9, $70
    DB      $3E, $03, $32, $FA, $70, $AF, $32, $17
    DB      $72, $32, $18, $72, $CD, $93, $AB, $10
    DB      $20, $01, $F1, $CD, $93, $AB, $40, $3F
    DB      $80, $00, $00, $00, $00, $00, $01, $02
    DB      $05, $0B, $0E, $0C, $04, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $C0, $C0, $C0
    DB      $80, $00, $C0, $40, $60, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $03, $03, $03
    DB      $01, $00, $03, $02, $06, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $80, $40
    DB      $A0, $D0, $70, $30, $20, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $04, $0C, $0E
    DB      $0B, $05, $02, $01, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $60, $40, $C0
    DB      $00, $80, $C0, $C0, $C0, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $06, $02, $03
    DB      $00, $01, $03, $03, $03, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $20, $30, $70
    DB      $D0, $A0, $40, $80, $00, $00, $00, $00
    DB      $00, $C3, $D1, $AB

LOC_A580:
    LD      B, $10
    LD      HL, $706B                   ; RAM $706B

LOC_A585:
    INC     HL
    PUSH    HL
    CALL    RAND_GEN
    CALL    RAND_GEN
    CALL    RAND_GEN
    POP     HL
    LD      (HL), A
    INC     HL
    INC     HL
    PUSH    HL
    CALL    RAND_GEN
    POP     HL
    CP      $B8
    JR      C, LOC_A59F
    SUB     $60

LOC_A59F:
    LD      (HL), A
    INC     HL
    DJNZ    LOC_A585
    RET     
    DB      $CD, $DC, $AB, $CD, $37, $AC, $3E, $01
    DB      $32, $53, $70, $CD, $BA, $A3, $3E, $0A
    DB      $32, $6A, $70, $06, $10, $DD, $21, $6B
    DB      $70, $DD, $77, $00, $DD, $77, $02, $CD
    DB      $FD, $1F, $DD, $77, $01, $CD, $FD, $1F
    DB      $CB, $3F, $CB, $3F, $C6, $80, $DD, $77
    DB      $03, $11, $04, $00, $DD, $19, $10, $E1
    DB      $11, $00, $04, $CD, $97, $A6, $11, $00
    DB      $0C, $CD, $97, $A6, $21, $38, $71, $11
    DB      $3C, $00, $CD, $D4, $9F, $21, $05, $00
    DB      $22, $6F, $72, $3E, $12, $32, $2A, $71
    DB      $3E, $10, $32, $2B, $71, $3E, $0A, $32
    DB      $2C, $71, $3E, $02, $32, $29, $71, $CD
    DB      $15, $A0, $CD, $93, $AB, $40, $3F, $80
    DB      $00, $00, $00, $30, $28, $26, $11, $11
    DB      $08, $08, $08, $0B, $04, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $80
    DB      $40, $40, $40, $C0, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $01
    DB      $02, $02, $02, $03, $00, $00, $00, $00
    DB      $00, $00, $00, $0C, $14, $64, $88, $88
    DB      $10, $10, $10, $D0, $20, $00, $00, $00
    DB      $00, $00, $00, $04, $0B, $08, $08, $08
    DB      $11, $11, $26, $28, $30, $00, $00, $00
    DB      $00, $00, $00, $00, $C0, $40, $40, $40
    DB      $80, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $03, $02, $02, $02
    DB      $01, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $20, $D0, $10, $10, $10
    DB      $88, $88, $64, $14, $0C, $00, $00, $00
    DB      $C3, $D1, $AB, $21, $CA, $B8, $01, $00
    DB      $04, $C3, $DF, $1F, $CD, $DC, $AB, $CD
    DB      $37, $AC, $3E, $02, $32, $53, $70, $21
    DB      $05, $00, $22, $75, $72, $3E, $05, $32
    DB      $2D, $71, $32, $2C, $71, $3E, $C8, $32
    DB      $2E, $71, $21, $A5, $71, $11, $1C, $00
    DB      $CD, $D4, $9F, $CD, $BA, $A3, $CD, $A5
    DB      $AB, $38, $71, $28, $01, $00, $00, $00
    DB      $6F, $01, $08, $90, $20, $22, $01, $00
    DB      $00, $00, $72, $01, $00, $98, $40, $20
    DB      $01, $00, $00, $00, $CF, $01, $0C, $A0
    DB      $20, $26, $01, $00, $00, $00, $D2, $01
    DB      $04, $A8, $40, $24, $21, $7D, $A7, $11
    DB      $E0, $03, $CD, $2B, $AC, $21, $7D, $A7
    DB      $11, $E0, $0B, $CD, $2B, $AC, $21, $40
    DB      $04, $CD, $44, $A7, $21, $40, $0C, $CD
    DB      $44, $A7, $21, $00, $04, $CD, $5C, $A7
    DB      $21, $00, $0C, $CD, $5C, $A7, $DD, $21
    DB      $51, $95, $CD, $EB, $9F, $22, $A3, $71
    DB      $AF, $32, $32, $71, $32, $31, $71, $32
    DB      $AD, $70, $32, $30, $71, $3E, $FA, $32
    DB      $17, $72, $CD, $15, $A0, $C3, $D1, $AB
    DB      $E5, $11, $40, $00, $CD, $B9, $9F, $E1
    DB      $06, $08, $E5, $3E, $FF, $CD, $00, $A0
    DB      $E1, $11, $09, $00, $19, $10, $F3, $C9
    DB      $3E, $80, $32, $D7, $71, $06, $08, $E5
    DB      $11, $08, $00, $3A, $D7, $71, $CD, $82
    DB      $1F, $E1, $11, $08, $00, $19, $3A, $D7
    DB      $71, $CB, $3F, $32, $D7, $71, $10, $E7
    DB      $C9, $80, $80, $80, $80, $80, $80, $80
    DB      $80, $01, $01, $01, $01, $01, $01, $01
    DB      $01, $80, $80, $80, $80, $80, $80, $FF
    DB      $FF, $01, $01, $01, $01, $01, $01, $FF
    DB      $FF

SUB_A79D:                                  ; SUB_A79D: title screen VRAM layout (DE=$0480/$0C80, VRAM, $7053=$03)
    LD      DE, $0480                      ; DE = $0480: title screen VRAM offset 1
    CALL    SUB_A7B9                       ; SUB_A7B9: write title tile data to VRAM at DE
    LD      DE, $0C80                      ; DE = $0C80: title screen offset 2
    CALL    SUB_A7B9                       ; SUB_A7B9: write second title block
    LD      A, $40                         ; A = $40: tile fill value
    CALL    SUB_A017                       ; SUB_A017: fill VRAM $2010 ($0010 bytes) with $40
    CALL    SUB_AC37                       ; SUB_AC37: additional screen init
    LD      A, $03                         ; A = $03
    LD      ($7053), A                     ; ($7053) = $03: set game phase to title/attract
    JP      LOC_A580                       ; JP LOC_A580: continue title sequence

SUB_A7B9:
    LD      HL, $BDCD
    LD      BC, $0200
    JP      WRITE_VRAM
    DB      $05, $0B, $00, $00, $90, $91, $92, $93
    DB      $94, $95, $96, $00, $00, $00, $97, $98
    DB      $99, $9A, $9B, $9C, $9D, $9E, $9F, $00
    DB      $00, $A0, $A1, $A2, $A3, $A4, $A5, $A6
    DB      $A7, $A8, $A9, $AA, $AB, $AC, $AD, $AE
    DB      $AF, $B0, $B1, $B2, $B3, $B4, $B5, $B6
    DB      $B7, $B5, $B8, $B9, $BA, $BB, $BC, $BD
    DB      $BE

SUB_A7FB:                                  ; SUB_A7FB: VDP tile table init (INIT_TABLE, WRITE_VRAM, REFLECT_VERTICAL, ROTATE_90)
    LD      A, $03                         ; A = $03: INIT_TABLE table #3 (pattern gen)
    LD      HL, $2000                      ; HL = $2000: pattern table base
    CALL    INIT_TABLE                     ; BIOS: clear pattern table at $2000
    LD      DE, $2040                      ; DE = $2040: VRAM dest for base tiles
    LD      HL, $BCCA                      ; HL = $BCCA: tile source data
    LD      BC, $0100                      ; BC = $0100: 256 bytes
    CALL    WRITE_VRAM                     ; WRITE_VRAM: write 256-byte tile block to $2040
    LD      A, $03                         ; A = $03: table #3
    LD      DE, $0008                      ; DE = $0008: stride
    LD      HL, $0080                      ; HL = $0080: source offset
    LD      BC, $001E                      ; BC = $001E: 30 bytes
    CALL    REFLECT_VERTICAL               ; BIOS: reflect tile block vertically
    LD      A, $03                         ; A = $03
    LD      DE, $0080                      ; DE = $0080
    LD      HL, $0026                      ; HL = $0026
    LD      BC, $001E                      ; BC = $001E
    CALL    ROTATE_90                      ; BIOS: rotate tile block 90 degrees
    LD      A, $03
    LD      DE, $0008
    LD      HL, $0044
    LD      BC, $003C
    CALL    REFLECT_VERTICAL
    LD      A, $03
    LD      DE, BOOT_UP
    LD      HL, $0080
    LD      BC, $0080
    CALL    REFLECT_HORIZONTAL
    LD      A, $03
    LD      HL, BOOT_UP
    CALL    INIT_TABLE
    LD      HL, $2800
    LD      ($71DB), HL                 ; RAM $71DB
    LD      HL, $BF45
    CALL    SUB_A86F
    LD      HL, $3000
    LD      ($71DB), HL                 ; RAM $71DB
    LD      HL, $B8EA
    CALL    SUB_A86F
    LD      A, $01
    LD      HL, $3800
    JP      INIT_TABLE

SUB_A86F:
    PUSH    HL
    LD      A, $01
    LD      HL, ($71DB)                 ; RAM $71DB
    PUSH    HL
    CALL    INIT_TABLE
    POP     DE
    POP     HL
    LD      BC, $0060
    CALL    WRITE_VRAM
    LD      HL, ($71DB)                 ; RAM $71DB
    LD      DE, $0060
    ADD     HL, DE
    PUSH    HL
    LD      BC, $000C
    PUSH    BC
    LD      A, $01
    LD      HL, $0078
    LD      DE, $0004
    LD      BC, $0004
    CALL    REFLECT_VERTICAL
    LD      HL, ($71DB)                 ; RAM $71DB
    LD      DE, $03C0
    ADD     HL, DE
    DB      $EB
    LD      HL, $A8AC
    LD      ($71D7), HL                 ; RAM $71D7
    JP      LOC_B1FC
    DB      $3E, $01, $11, $00, $00, $21, $10, $00
    DB      $01, $10, $00, $CD, $70, $1F, $11, $80
    DB      $00, $CD, $E5, $A8, $3E, $01, $11, $10
    DB      $00, $21, $20, $00, $01, $10, $00, $CD
    DB      $70, $1F, $11, $00, $01, $CD, $E5, $A8
    DB      $3E, $01, $11, $20, $00, $21, $30, $00
    DB      $01, $10, $00, $CD, $70, $1F, $11, $80
    DB      $01, $2A, $DB, $71, $19, $EB, $06, $04
    DB      $C3, $0E, $A0

DELAY_LOOP_A8EF:                           ; DELAY_LOOP_A8EF: load ASCII font + fill title screen sprite area
    CALL    LOAD_ASCII                     ; LOAD_ASCII: load ASCII character font into VRAM
    CALL    SUB_AB93                       ; SUB_AB93: VRAM write helper
    EXX                                    ; EXX: switch registers
    LD      BC, $0002
    NOP     
    CALL    SUB_AB93
    RET     P
    INC     BC
    DJNZ    LOC_A93D
    LD      B, D
    SBC     A, C
    AND     C
    AND     C
    SBC     A, C
    LD      B, D
    INC     A
    LD      B, B
    AND     B
    AND     B
    LD      B, B
    XOR     B
    SUB     B
    LD      L, B
    NOP     
    LD      HL, $37C0                      ; HL = $37C0: sprite VRAM base
    LD      A, $FF                         ; A = $FF: fill with $FF
    LD      DE, $0020                      ; DE = $0020: $0020 bytes
    CALL    FILL_VRAM                      ; FILL_VRAM: fill $37C0 sprite area
    LD      HL, $3780                      ; HL = $3780: sprite name VRAM
    LD      A, $99                         ; A = $99: tile #$99
    LD      DE, $0020                      ; DE = $0020
    CALL    FILL_VRAM                      ; FILL_VRAM: fill sprite name table
    LD      HL, $AE99                      ; HL = $AE99: title graphic source
    LD      DE, $3CE0                      ; DE = $3CE0: VRAM dest (colour table)
    CALL    SUB_AC2B                       ; SUB_AC2B: write decompressed/RLE data to VRAM
    LD      HL, $BF9F
    LD      DE, $3C60
    LD      BC, $0040
    CALL    WRITE_VRAM
    LD      HL, $BFBF
    LD      DE, $3CA0
    LD      BC, $0040
    CALL    WRITE_VRAM
    LD      HL, $B74E
    LD      DE, $0080
    LD      BC, $0040
    CALL    WRITE_VRAM
    LD      DE, $0010
    LD      HL, $0018
    LD      BC, $0008
    LD      A, $03
    CALL    REFLECT_VERTICAL
    LD      HL, $B7AA
    LD      DE, $02C0
    CALL    SUB_AC2B
    LD      DE, $0058
    LD      HL, $005C
    LD      BC, $0004
    LD      A, $03
    CALL    REFLECT_VERTICAL
    LD      HL, $B78A
    LD      DE, $0040
    CALL    SUB_AC2B
    LD      A, $03
    LD      DE, $0008
    LD      HL, $000C
    LD      BC, $0004
    CALL    REFLECT_VERTICAL
    LD      HL, $BDBA
    LD      DE, $0010
    LD      BC, $0018
    CALL    WRITE_VRAM
    LD      A, $03
    LD      DE, $0002
    LD      HL, $0005
    LD      BC, $0003
    CALL    REFLECT_VERTICAL
    LD      HL, $B7CA
    LD      DE, $0100
    LD      BC, $0018
    CALL    WRITE_VRAM
    LD      HL, $B7E2
    LD      DE, $0140
    LD      BC, $0028
    CALL    WRITE_VRAM
    LD      HL, $B80A
    LD      DE, $0280
    LD      BC, $0040
    CALL    WRITE_VRAM
    LD      HL, $B84A
    LD      DE, $3820
    LD      BC, $00A0
    CALL    WRITE_VRAM
    LD      HL, $38C0
    LD      BC, $0018
    LD      DE, $0010
    PUSH    HL
    CALL    SUB_B1E9
    LD      HL, $38E0
    LD      BC, $001C
    LD      DE, $000C
    PUSH    HL
    CALL    SUB_B1E9
    LD      HL, $3900
    LD      BC, $0020
    LD      DE, $0008
    PUSH    HL
    CALL    SUB_B1E9
    LD      A, $01
    LD      DE, $0004
    LD      HL, $0024
    LD      BC, $0020
    CALL    ROTATE_90
    LD      DE, $3920
    LD      B, $08
    CALL    SUB_A00E
    LD      A, $01
    LD      DE, $0004
    LD      HL, $0044
    LD      BC, $0040
    CALL    REFLECT_VERTICAL
    LD      DE, $3A20
    LD      B, $10
    CALL    SUB_AC66
    CALL    SUB_AB93
    RET     NZ
    CCF     
    LD      B, B
    NOP     
    NOP     
    NOP     
    NOP     
    NOP     
    LD      (BC), A
    ADD     HL, BC
    LD      B, $03
    INC     C
    LD      (BC), A
    INC     B
    NOP     
    NOP     
    NOP     
    NOP     
    NOP     
    NOP     
    NOP     
    NOP     
    ADD     A, B
    AND     B
    XOR     B
    RET     P
    RET     NZ
    OR      B
    ADD     A, B
    LD      B, B
    NOP     
    NOP     
    NOP     
    NOP     
    NOP     
    NOP     
    LD      BC, $0409
    LD      (BC), A
    ADD     HL, SP
    LD      B, $01
    LD      C, $12
    INC     B
    INC     B
    EX      AF, AF'
    NOP     
    NOP     
    NOP     
    NOP     
    DJNZ    LOC_AA76
    AND     H
    AND     H
    XOR     B
    RET     P
    RET     NZ
    OR      B
    ADC     A, B
    LD      C, B
    LD      B, B
    JR      NZ, LOC_AA71

LOC_AA71:
    NOP     
    CALL    SUB_AB93
    NOP     

LOC_AA76:
    JR      NZ, LOC_AA88
    LD      B, C
    LD      B, C
    LD      H, C
    LD      H, C
    LD      H, C
    LD      B, C
    OR      C
    OR      C
    POP     BC
    POP     BC
    LD      H, C
    LD      H, C
    POP     AF
    POP     AF
    POP     AF
    POP     AF

LOC_AA88:
    CALL    SUB_A015
    LD      DE, $3800
    LD      HL, $B72E
    CALL    SUB_AC2B
    LD      A, $34
    LD      ($71EF), A                  ; RAM $71EF
    LD      A, $80
    LD      ($71F0), A                  ; RAM $71F0
    LD      ($7067), A                  ; RAM $7067
    LD      ($7068), A                  ; RAM $7068
    LD      B, $20
    LD      IX, BOOT_UP
    LD      IY, $0800

LOC_AAAE:
    PUSH    BC
    PUSH    IX
    POP     DE
    CALL    SUB_9FE2
    PUSH    IY
    POP     DE
    LD      HL, $72EA                   ; RAM $72EA
    CALL    SUB_AC2B
    LD      BC, $0020
    ADD     IX, BC
    ADD     IY, BC
    POP     BC
    DJNZ    LOC_AAAE
    RET     
    DB      $08, $18, $00, $10

SUB_AACD:
    CALL    SUB_AAD5
    LD      B, $04
    JP      SUB_ABEE

SUB_AAD5:
    LD      A, ($7063)                  ; RAM $7063
    DEC     A
    BIT     7, A
    JR      NZ, LOC_AAE6
    LD      ($7063), A                  ; RAM $7063
    LD      A, $1E
    LD      ($7066), A                  ; RAM $7066
    RET     

LOC_AAE6:
    XOR     A
    LD      ($7066), A                  ; RAM $7066
    LD      A, $04
    LD      ($7055), A                  ; RAM $7055
    LD      HL, $2000
    CALL    INIT_TABLE
    LD      HL, ($7134)                 ; RAM $7134
    PUSH    HL
    LD      HL, $1800
    CALL    SUB_AB0F
    LD      HL, $1000
    CALL    SUB_AB0F
    POP     HL
    LD      ($7134), HL                 ; RAM $7134
    CALL    TURN_OFF_SOUND
    JP      SUB_A006

SUB_AB0F:
    LD      ($7134), HL                 ; RAM $7134
    CALL    SUB_B15E
    CALL    SUB_AB85
    INC     L
    LD      BC, $6709                   ; RAM $6709
    LD      H, C
    LD      L, L
    LD      H, L
    NOP     
    LD      L, A
    HALT    
    DB      $65, $72, $C3, $18, $AF

DELAY_LOOP_AB27:
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    LD      B, $40

LOC_AB2C:
    OR      A
    SBC     HL, DE
    JR      C, LOC_AB36
    DJNZ    LOC_AB2C
    LD      A, $40
    RET     

LOC_AB36:
    LD      A, B
    SUB     $40
    NEG     
    RET     

SUB_AB3C:
    PUSH    IX
    PUSH    IY
    CALL    SUB_AB53
    INC     IX
    INC     IX
    INC     IX
    INC     IX
    CALL    SUB_AB53
    POP     IY
    POP     IX
    RET     

SUB_AB53:
    LD      A, ($71ED)                  ; RAM $71ED
    AND     $03
    JR      NZ, LOC_AB6A
    LD      A, (IX+3)
    SUB     $80
    ADD     A, (IX+2)
    CALL    SUB_AC00
    LD      A, (BC)
    OR      $DD
    LD      (HL), A
    LD      (BC), A

LOC_AB6A:
    LD      L, (IX+2)
    LD      H, $00
    LD      DE, $0080
    SBC     HL, DE
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    LD      E, (IX+0)
    LD      D, (IX+1)
    ADD     HL, DE
    LD      (IX+0), L
    LD      (IX+1), H
    RET     

SUB_AB85:
    POP     HL
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    INC     HL
    PUSH    HL
    LD      HL, ($7134)                 ; RAM $7134
    ADD     HL, DE
    DB      $EB
    POP     HL
    JR      LOC_AB98

SUB_AB93:
    POP     HL
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    INC     HL

LOC_AB98:
    LD      C, (HL)
    LD      B, $00
    INC     HL
    PUSH    HL
    PUSH    BC
    CALL    WRITE_VRAM
    POP     BC
    POP     HL
    ADD     HL, BC
    JP      (HL)
    DB      $E1, $5E, $23, $56, $23, $4E, $23, $06
    DB      $00, $E5, $C5, $ED, $B0, $C1, $E1, $09
    DB      $E9, $21, $F3, $71, $11, $3C, $00, $CD
    DB      $D4, $9F, $21, $D5, $70, $11, $1B, $00
    DB      $CD, $D4, $9F, $21, $AF, $70, $11, $24
    DB      $00, $C3, $D4, $9F

SUB_ABD1:                                  ; SUB_ABD1: VDP enable ($71EC=$00, WRITE_REGISTER $01E2)
    XOR     A                              ; XOR A
    LD      ($71EC), A                     ; ($71EC) = 0: clear NMI re-entry flag
    CALL    READ_REGISTER                  ; READ_REGISTER: flush VDP status
    LD      C, $E2                         ; C = $E2: VDP enable command
    JR      LOC_ABE6                       ; JR LOC_ABE6

SUB_ABDC:                                  ; SUB_ABDC: VDP disable ($71EC=$01, WRITE_REGISTER $01C2)
    LD      A, $01                         ; A = $01
    LD      ($71EC), A                     ; ($71EC) = 1: set NMI re-entry flag (block NMI)
    CALL    READ_REGISTER                  ; READ_REGISTER: flush
    LD      C, $C2                         ; C = $C2: VDP disable command

LOC_ABE6:                                  ; LOC_ABE6: execute VDP register write
    LD      B, $01                         ; B = $01: register 1
    CALL    WRITE_REGISTER                 ; WRITE_REGISTER: set VDP reg 1
    JP      READ_REGISTER                  ; JP READ_REGISTER: flush status (tail call)

SUB_ABEE:
    PUSH    HL
    PUSH    DE
    PUSH    BC
    PUSH    IX
    PUSH    IY
    CALL    PLAY_IT
    POP     IY
    POP     IX
    POP     BC
    POP     DE
    POP     HL
    RET     

SUB_AC00:
    POP     IY
    PUSH    DE
    PUSH    HL
    LD      D, $00
    LD      E, A
    LD      H, D
    LD      L, (IY+0)
    OR      A
    SBC     HL, DE
    JP      M, LOC_AC16
    LD      A, (IY+0)
    JR      LOC_AC23

LOC_AC16:
    LD      H, D
    LD      L, (IY+1)
    OR      A
    SBC     HL, DE
    JP      P, LOC_AC23
    LD      A, (IY+1)

LOC_AC23:
    INC     IY
    INC     IY
    POP     HL
    POP     DE
    JP      (IY)

SUB_AC2B:
    LD      BC, $0020
    JP      WRITE_VRAM

SUB_AC31:
    LD      BC, $0008
    JP      WRITE_VRAM

SUB_AC37:
    LD      HL, BOOT_UP
    LD      ($7136), HL                 ; RAM $7136
    LD      HL, $1800
    LD      ($7134), HL                 ; RAM $7134
    XOR     A
    LD      ($7133), A                  ; RAM $7133
    LD      ($712F), A                  ; RAM $712F

SUB_AC4A:
    LD      A, $03
    LD      HL, BOOT_UP
    CALL    INIT_TABLE
    LD      A, $02
    LD      HL, $1800
    CALL    INIT_TABLE
    RET     
    DB      $FD, $21, $62, $AC, $C3, $71, $AC, $08
    DB      $00, $18, $10

SUB_AC66:
    LD      IY, $AC6D
    JP      LOC_AC71
    DB      $10, $18, $00, $08

LOC_AC71:
    PUSH    BC
    PUSH    DE
    CALL    SUB_9FE2
    POP     DE
    PUSH    IY
    LD      B, $04

LOC_AC7B:
    PUSH    BC
    LD      C, (IY+0)
    INC     IY
    LD      B, $00
    LD      HL, $72EA                   ; RAM $72EA
    ADD     HL, BC
    PUSH    DE
    CALL    SUB_AC31
    POP     DE
    LD      HL, $0008
    ADD     HL, DE
    DB      $EB
    POP     BC
    DJNZ    LOC_AC7B
    POP     IY
    POP     BC
    DJNZ    LOC_AC71
    RET     

SUB_AC9A:                                  ; SUB_AC9A: option select screen (difficulty, wave select, $7053=$0E)
    CALL    SUB_ABDC                       ; SUB_ABDC: VDP disable
    CALL    SUB_AC37                       ; SUB_AC37: additional display init
    CALL    SUB_A3CE                       ; SUB_A3CE: clear score/HUD VRAM
    CALL    SUB_A3C6                       ; SUB_A3C6: display init helper
    CALL    SUB_B164                       ; SUB_B164: title/banner display
    LD      A, $0F                         ; A = $0F
    LD      ($71F2), A                     ; ($71F2) = $0F: option select timeout
    LD      A, $0E                         ; A = $0E
    LD      ($7053), A                     ; ($7053) = $0E: set game phase to option-select
    LD      HL, $AE99
    LD      DE, $0580
    CALL    SUB_AC2B
    CALL    SUB_AB93
    LD      D, $20
    LD      (BC), A
    POP     BC
    POP     BC
    CALL    SUB_AB93
    RLCA    
    JR      LOC_ACDD
    DB      $73, $65, $6C, $65, $63, $74, $00, $61; DB "select": option menu text ("select")
    DB      $00, $64, $65, $61, $74, $68, $00, $73
    DB      $74, $61, $72               ; "tar"

LOC_ACDD:
    CALL    SUB_AB93
    ADD     A, H
    JR      LOC_ACE9
    DB      $77, $61, $76, $65, $00, $31   ; DB "wave 1": wave selection text

LOC_ACE9:
    CALL    SUB_AB93
    RET     
    DB      $18, $04, $65, $61, $73, $79, $CD, $93
    DB      $AB, $E4, $18, $05, $62, $6F, $6E, $75
    DB      $73, $CD, $93, $AB, $04, $19, $06, $31
    DB      $30, $3B, $30, $30, $30, $11, $A6, $00
    DB      $FD, $21, $93, $AE, $CD, $D7, $A3, $CD
    DB      $93, $AB, $EE, $19, $06, $77, $61, $76
    DB      $65, $00, $32, $CD, $93, $AB, $0E, $1A
    DB      $06, $6D, $65, $64, $69, $75, $6D, $CD
    DB      $93, $AB, $6E, $1A, $05, $62, $6F, $6E
    DB      $75, $73, $CD, $93, $AB, $8E, $1A, $06
    DB      $36, $35, $3B, $30, $30, $30, $11, $30
    DB      $02, $FD, $21, $93, $AE, $CD, $D7, $A3
    DB      $CD, $93, $AB, $98, $18, $06, $77, $61
    DB      $76, $65, $00, $33, $CD, $93, $AB, $D5
    DB      $18, $04, $68, $61, $72, $64, $CD, $93
    DB      $AB, $F8, $18, $05, $62, $6F, $6E, $75
    DB      $73, $CD, $93, $AB, $17, $19, $07, $31
    DB      $35, $30, $3B, $30, $30, $30, $11, $BA
    DB      $00, $FD, $21, $93, $AE, $CD, $D7, $A3
    DB      $CD, $D1, $AB, $CD, $8A, $A4, $3A, $84
    DB      $72, $FE, $0F, $C4, $E0, $AD, $CD, $DC
    DB      $1F, $3A, $83, $72, $B7, $28, $EF, $3A
    DB      $EF, $71, $47, $3A, $F0, $71, $80, $FE
    DB      $C9, $20, $07, $3A, $EF, $71, $FE, $A0
    DB      $28, $6C, $3A, $EF, $71, $FE, $70, $30
    DB      $13, $3A, $F0, $71, $FE, $50, $38, $08
    DB      $FE, $A0, $38, $CA, $3E, $03, $18, $06
    DB      $3E, $01, $18, $02, $3E, $02, $32, $56
    DB      $70, $32, $57, $70, $32, $59, $70, $32 ; "p2Wp2Yp2"
    DB      $58, $70, $21, $00, $00, $22, $ED, $71
    DB      $C3, $A4, $A4, $CD, $DC, $AB, $3A, $52
    DB      $70, $EE, $05, $32, $52, $70, $28, $19
    DB      $CD, $93, $AB, $48, $18, $11, $6A, $6F
    DB      $79, $73, $74, $69, $63, $6B, $00, $69
    DB      $6E, $76, $65, $72, $74, $65, $64, $18
    DB      $09, $21, $48, $18, $11, $12, $00, $CD
    DB      $B9, $9F, $CD, $D1, $AB, $21, $00, $A0
    DB      $2B, $7C, $B5, $20, $FB, $C9, $CD, $93
    DB      $AB, $06, $18, $15, $67, $61, $6D, $65
    DB      $00, $62, $79, $00, $77, $65, $6E, $64
    DB      $65, $6C, $6C, $00, $62, $72, $6F, $77
    DB      $6E, $CD, $93, $AB, $24, $18, $19, $67
    DB      $72, $61, $70, $68, $69, $63, $73, $00
    DB      $62, $79, $00, $6B, $61, $72, $65, $6E
    DB      $00, $65, $6C, $6C, $69, $6F, $74, $74
    DB      $CD, $93, $AB, $45, $18, $17, $73, $6F
    DB      $75, $6E, $64, $73, $00, $62, $79, $00
    DB      $6E, $65, $69, $6C, $00, $6D, $63, $6B
    DB      $65, $6E, $7A, $69, $65, $CD, $93, $AB
    DB      $44, $19, $19, $6D, $61, $79, $00, $74
    DB      $68, $65, $00, $66, $6F, $72, $63, $65
    DB      $00, $62, $65, $00, $77, $69, $74, $68
    DB      $00, $79, $6F, $75, $18, $FE, $02, $02
    DB      $B0, $B2, $B1, $B3, $07, $1C, $30, $60
    DB      $40, $CA, $80, $88, $FF, $80, $CA, $40
    DB      $62, $30, $1C, $07, $E0, $38, $2C, $26
    DB      $52, $AB, $89, $51, $FF, $09, $8B, $02
    DB      $16, $0C, $38, $E0

SUB_AEB9:
    CALL    SUB_AB85
    RLCA    
    NOP     
    DEC     D
    LD      D, B
    LD      D, C
    LD      D, D
    NOP     
    NOP     
    LD      B, B
    LD      B, C
    LD      B, D
    LD      B, E
    LD      B, H
    LD      B, L
    LD      B, (HL)
    LD      B, A
    LD      C, B
    NOP     
    NOP     
    NOP     
    NOP     
    LD      D, E
    LD      D, H
    LD      D, D
    CALL    SUB_AB85
    INC     L
    NOP     
    ADD     HL, BC
    LD      C, C
    LD      C, D
    LD      C, E
    NOP     
    NOP     
    NOP     
    LD      C, H
    LD      C, L
    LD      C, (HL)
    LD      A, ($7053)                  ; RAM $7053
    CP      $01
    JR      NZ, LOC_AEFC
    CALL    SUB_AB85
    ADD     HL, SP
    NOP     
    INC     BC
    LD      D, L
    LD      D, (HL)
    LD      D, A
    LD      A, ($712B)                  ; RAM $712B
    LD      DE, $0037
    CALL    SOUND_WRITE_A395

LOC_AEFC:
    LD      A, ($7056)                  ; RAM $7056
    LD      DE, $0017
    CALL    SOUND_WRITE_A395
    LD      A, ($7063)                  ; RAM $7063
    ADD     A, $30
    CP      $30
    JR      Z, LOC_AF18
    LD      DE, $0030
    LD      HL, ($7134)                 ; RAM $7134
    ADD     HL, DE
    JP      SUB_A000

LOC_AF18:
    CALL    SUB_AB85
    DEC     BC
    NOP     
    DEC     BC
    LD      (HL), E
    LD      L, B
    LD      L, C
    LD      H, L
    LD      L, H
    LD      H, H
    NOP     
    LD      H, A
    LD      L, A
    LD      L, (HL)
    LD      H, L
    CALL    SUB_AB85
    INC     L
    NOP     
    ADD     HL, BC
    NOP     
    NOP     
    NOP     
    NOP     
    NOP     
    NOP     
    NOP     
    NOP     
    NOP     
    RET     

SUB_AF39:                                  ; SUB_AF39: commit sprites to VRAM + advance sound state
    LD      A, ($7065)                  ; RAM $7065
    LD      B, A
    LD      A, ($7063)                  ; RAM $7063
    CP      B
    RET     Z
    LD      ($7065), A                  ; RAM $7065
    LD      B, A
    ADD     A, A
    ADD     A, A
    ADD     A, A
    ADD     A, A
    SUB     B
    LD      E, A
    LD      D, $00
    LD      IX, $AF88
    ADD     IX, DE
    LD      DE, $0200
    LD      IY, $0A00
    LD      B, $0F

LOC_AF5D:
    PUSH    BC
    PUSH    DE
    LD      A, (IX+0)
    ADD     A, A
    ADD     A, A
    LD      L, A
    LD      H, $00
    ADD     HL, HL
    LD      BC, $B01E
    ADD     HL, BC
    PUSH    HL
    CALL    SUB_AC31
    POP     HL
    PUSH    IY
    POP     DE
    CALL    SUB_AC31
    POP     DE
    LD      HL, $0008
    ADD     HL, DE
    DB      $EB
    LD      BC, $0008
    ADD     IY, BC
    INC     IX
    POP     BC
    DJNZ    LOC_AF5D
    RET     
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $26, $27, $25, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $22, $05, $23, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $04, $05, $1D, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $1C, $04
    DB      $05, $06, $1E, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $13, $04, $05
    DB      $06, $15, $00, $00, $00, $00, $0C, $14
    DB      $00, $00, $00, $12, $03, $04, $05, $06
    DB      $07, $16, $00, $00, $1B, $0C, $0D, $1F
    DB      $00, $11, $02, $03, $04, $05, $06, $07
    DB      $17, $00, $1A, $0B, $0C, $0D, $20, $00
    DB      $10, $02, $03, $04, $05, $06, $07, $08
    DB      $18, $19, $0B, $0C, $0D, $0E, $21, $01
    DB      $02, $03, $04, $05, $06, $07, $08, $09
    DB      $0A, $0B, $0C, $0D, $0E, $0F, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $7F
    DB      $41, $41, $41, $40, $40, $40, $00, $FF
    DB      $08, $08, $08, $08, $08, $08, $00, $FF
    DB      $88, $88, $00, $00, $03, $1C, $00, $FF
    DB      $80, $81, $8E, $F0, $80, $00, $00, $FF
    DB      $38, $C7, $00, $00, $00, $00, $00, $FF
    DB      $02, $02, $E2, $1E

; ============================================================
; GAME DATA  ($B054 - $BBFF)
; Animation, sprite, level, and name-table data.
; (Tracer did not reach this area via static flow; kept as DB.)
; ============================================================
GAME_DATA:                                 ; GAME_DATA: game data tables (level data, enemy patterns, score tables)
    DB      $03, $00, $00, $FF, $22, $22, $00, $00
    DB      $80, $70, $00, $FF, $21, $21, $21, $20
    DB      $20, $20, $00, $FC, $04, $04, $04, $04
    DB      $04, $04, $40, $40, $40, $41, $4E, $70
    DB      $00, $00, $08, $0F, $38, $C0, $00, $00
    DB      $00, $00, $E0, $00, $00, $00, $00, $00
    DB      $00, $00, $0E, $01, $00, $00, $00, $00
    DB      $00, $00, $20, $E0, $38, $07, $00, $00
    DB      $00, $00, $04, $04, $04, $04, $E4, $1C
    DB      $00, $00, $00, $0F, $09, $09, $09, $08
    DB      $08, $08, $00, $01, $01, $01, $01, $01
    DB      $01, $01, $00, $0F, $08, $08, $08, $08
    DB      $08, $08, $00, $FF, $88, $88, $80, $80
    DB      $83, $9C, $0E, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $FE, $22, $22, $02, $02
    DB      $82, $72, $00, $E0, $20, $20, $20, $20
    DB      $20, $20, $00, $FF, $21, $21, $21, $21
    DB      $21, $21, $00, $E0, $20, $20, $20, $20
    DB      $20, $20, $08, $08, $08, $09, $0E, $00
    DB      $00, $00, $01, $01, $01, $01, $00, $00
    DB      $00, $00, $08, $0F, $08, $00, $00, $00
    DB      $00, $00, $00, $0F, $08, $08, $08, $08
    DB      $0B, $0C, $00, $FE, $02, $02, $E2, $1E
    DB      $02, $00, $00, $E0, $20, $20, $20, $20
    DB      $A0, $60, $20, $E0, $20, $00, $00, $00
    DB      $00, $00, $21, $E1, $39, $07, $00, $00
    DB      $00, $00, $20, $20, $20, $20, $E0, $00
    DB      $00, $00, $00, $1F, $10, $11, $1E, $10
    DB      $00, $00, $00, $F0, $10, $10, $F0, $10
    DB      $00, $00, $00, $FF, $38, $C7, $00, $00
    DB      $00, $00, $00, $80, $80, $80, $80, $00
    DB      $00, $00, $00, $03, $02, $03, $03, $00
    DB      $00, $00, $00, $FF, $38, $C7, $01, $00
    DB      $00, $00

SUB_B15E:
    CALL    SUB_AEB9
    CALL    SUB_A33E

SUB_B164:
    LD      DE, $0181
    LD      IY, $B1A1
    CALL    DELAY_LOOP_A3D7
    LD      DE, $019C
    LD      IY, $B1B3
    CALL    DELAY_LOOP_A3D7
    LD      DE, $0281
    LD      IY, $B1C5
    CALL    DELAY_LOOP_A3D7
    LD      DE, $029C
    LD      IY, $B1D7
    CALL    DELAY_LOOP_A3D7
    CALL    SUB_AB85
    RST     $08
    LD      (BC), A
    INC     BC
    JR      NZ, LOC_B1B5
    LD      ($85CD), HL
    XOR     E
    XOR     $02
    DEC     B
    JR      Z, LOC_B1C6
    LD      HL, ($2C2B)
    RET     
    DB      $04, $04, $00, $10, $11, $00, $02, $58
    DB      $59, $02, $03, $5A, $5B, $04, $00, $16
    DB      $17, $00, $04, $04

LOC_B1B5:
    NOP     
    ADD     HL, DE
    JR      LOC_B1B9

LOC_B1B9:
    DEC     B
    LD      E, L
    LD      E, H
    DEC     B
    RLCA    
    LD      E, A
    LD      E, (HL)
    LD      B, $00
    RRA     
    LD      E, $00
    INC     B

LOC_B1C6:
    INC     B
    NOP     
    DJNZ    LOC_B1DB
    EX      AF, AF'
    NOP     
    LD      (DE), A
    INC     DE
    ADD     HL, BC
    LD      A, (BC)
    INC     D
    DEC     D
    NOP     
    DEC     BC
    LD      D, $17
    NOP     
    INC     B
    INC     B
    INC     C
    ADD     HL, DE

LOC_B1DB:
    JR      LOC_B1DD

LOC_B1DD:
    DEC     C
    DEC     DE
    LD      A, (DE)
    NOP     
    NOP     
    DEC     E
    INC     E
    LD      C, $00
    RRA     
    LD      E, $0F

SUB_B1E9:
    POP     HL
    LD      ($71D7), HL                 ; RAM $71D7
    PUSH    BC
    LD      A, $01
    LD      HL, $0078
    LD      BC, $0004
    CALL    REFLECT_VERTICAL
    LD      DE, $3BC0

LOC_B1FC:
    LD      B, $01
    CALL    SUB_AC66
    LD      A, $01
    LD      DE, $0078
    POP     HL
    LD      BC, $0004
    CALL    ROTATE_90
    POP     DE
    LD      B, $01
    CALL    SUB_A00E
    LD      HL, ($71D7)                 ; RAM $71D7
    JP      (HL)
    DB      $57, $B5, $85, $72, $A8, $B5, $85, $72
    DB      $C2, $B5, $8F, $72, $27, $B6, $8F, $72
    DB      $64, $B6, $85, $72, $7E, $B6, $85, $72
    DB      $98, $B6, $8F, $72, $B9, $B6, $8F, $72
    DB      $1E, $B7, $85, $72, $47, $B2, $A3, $72
    DB      $B2, $B3, $99, $72, $A1, $B4, $8F, $72
    DB      $40, $7D, $B1, $06, $62, $40, $7D, $B1
    DB      $06, $62, $40, $7D, $B1, $06, $62, $40
    DB      $1D, $B1, $30, $40, $BE, $B0, $30, $40
    DB      $D6, $B0, $08, $40, $E2, $B0, $08, $40
    DB      $FE, $B0, $08, $40, $8F, $B0, $30, $40
    DB      $BE, $B0, $18, $40, $D6, $B0, $08, $40
    DB      $E2, $B0, $08, $40, $FE, $B0, $08, $40
    DB      $8F, $B0, $30, $40, $BE, $B0, $18, $40
    DB      $D6, $B0, $08, $40, $E2, $B0, $08, $40
    DB      $D6, $B0, $08, $40, $FE, $B0, $30, $40
    DB      $7D, $B1, $0E, $62, $40, $7D, $B1, $06
    DB      $62, $40, $1D, $B1, $30, $40, $BE, $B0
    DB      $30, $40, $D6, $B0, $08, $40, $E2, $B0
    DB      $08, $40, $FE, $B0, $08, $40, $8F, $B0
    DB      $30, $40, $BE, $B0, $18, $40, $D6, $B0
    DB      $08, $40, $E2, $B0, $08, $40, $FE, $B0
    DB      $08, $40, $8F, $B0, $30, $40, $BE, $B0
    DB      $18, $40, $D6, $B0, $08, $40, $E2, $B0
    DB      $08, $40, $D6, $B0, $08, $40, $FE, $B0
    DB      $30, $40, $7D, $B1, $0E, $62, $40, $7D
    DB      $B1, $06, $62, $40, $53, $B1, $22, $62
    DB      $40, $53, $B1, $0C, $40, $D6, $B0, $0C
    DB      $40, $E2, $B0, $0C, $40, $FE, $B0, $0C
    DB      $40, $1D, $B1, $0A, $62, $40, $1D, $B1
    DB      $08, $40, $FE, $B0, $08, $40, $E2, $B0
    DB      $08, $40, $FE, $B0, $10, $40, $53, $B1
    DB      $08, $40, $2E, $B1, $18, $40, $7D, $B1
    DB      $0E, $62, $40, $7D, $B1, $06, $62, $40
    DB      $53, $B1, $22, $62, $40, $53, $B1, $0C
    DB      $40, $D6, $B0, $0C, $40, $E2, $B0, $0C
    DB      $40, $FE, $B0, $0C, $40, $1D, $B1, $0C
    DB      $40, $BE, $B0, $18, $40, $FE, $B0, $30
    DB      $40, $7D, $B1, $0E, $62, $40, $7D, $B1
    DB      $06, $62, $40, $53, $B1, $22, $62, $40
    DB      $53, $B1, $0C, $40, $D6, $B0, $0C, $40
    DB      $E2, $B0, $0C, $40, $FE, $B0, $0C, $40
    DB      $1D, $B1, $0A, $62, $40, $1D, $B1, $08
    DB      $40, $FE, $B0, $08, $40, $E2, $B0, $08
    DB      $40, $FE, $B0, $10, $40, $53, $B1, $08
    DB      $40, $2E, $B1, $18, $40, $BE, $B0, $0E
    DB      $62, $40, $BE, $B0, $06, $62, $40, $8F
    DB      $B0, $0C, $40, $A0, $B0, $0C, $40, $B4
    DB      $B0, $0C, $40, $BE, $B0, $0C, $40, $D6
    DB      $B0, $0C, $40, $F0, $B0, $0C, $40, $FE
    DB      $B0, $0C, $40, $1D, $B1, $0C, $40, $BE
    DB      $B0, $48, $50, $B8, $80, $3B, $E2, $18
    DB      $80, $5D, $E2, $18, $80, $A7, $E2, $18
    DB      $80, $FA, $E2, $18, $80, $AC, $E1, $18
    DB      $80, $C5, $E1, $18, $80, $FC, $E1, $18
    DB      $80, $3B, $E2, $18, $80, $AC, $E1, $18
    DB      $80, $C5, $E1, $18, $80, $FC, $E1, $18
    DB      $80, $3B, $E2, $18, $80, $81, $E2, $18
    DB      $80, $FA, $E2, $18, $80, $FA, $C2, $18
    DB      $B8, $80, $3B, $E2, $18, $80, $5D, $E2
    DB      $18, $80, $A7, $E2, $18, $80, $FA, $E2
    DB      $18, $80, $AC, $E1, $18, $80, $C5, $E1
    DB      $18, $80, $FC, $E1, $18, $80, $3B, $E2
    DB      $18, $80, $AC, $E1, $18, $80, $C5, $E1
    DB      $18, $80, $FC, $E1, $18, $80, $3B, $E2
    DB      $18, $80, $81, $E2, $18, $80, $FA, $E2
    DB      $30, $AC, $AC, $AC, $AC, $80, $FA, $E2
    DB      $2E, $A2, $80, $FA, $E2, $2E, $A2, $80
    DB      $FA, $E2, $2E, $A2, $80, $FA, $E2, $2E
    DB      $A2, $80, $FA, $E2, $2E, $A2, $80, $FA
    DB      $E2, $18, $80, $C0, $E3, $18, $80, $FA
    DB      $E2, $2E, $A2, $80, $FA, $E2, $2E, $A2
    DB      $80, $FA, $E2, $2E, $A2, $80, $FA, $E2
    DB      $2E, $A2, $80, $FA, $E2, $2E, $A2, $80
    DB      $FA, $E2, $18, $80, $F9, $E3, $0C, $80
    DB      $8A, $E3, $0C, $80, $57, $E3, $0C, $80
    DB      $FA, $E2, $0C, $80, $CF, $E2, $0C, $80
    DB      $81, $E2, $0C, $80, $3B, $E2, $0C, $80
    DB      $FC, $E1, $0C, $AC, $AC, $80, $FA, $E2
    DB      $06, $A2, $80, $FA, $E2, $06, $A2, $80
    DB      $FA, $E2, $06, $A2, $80, $FA, $E2, $0C
    DB      $AC, $90, $F8, $C0, $C5, $E1, $30, $C0
    DB      $1D, $E1, $30, $C0, $53, $E1, $18, $C0
    DB      $E2, $E0, $30, $C0, $1D, $E1, $18, $C0
    DB      $53, $E1, $18, $C0, $E2, $E0, $30, $C0
    DB      $1D, $E1, $18, $C0, $40, $E1, $18, $C0
    DB      $2E, $E1, $18, $C0, $7D, $E1, $18, $F8
    DB      $C0, $C5, $E1, $30, $C0, $1D, $E1, $30
    DB      $C0, $53, $E1, $18, $C0, $E2, $E0, $30
    DB      $C0, $1D, $E1, $18, $C0, $53, $E1, $18
    DB      $C0, $E2, $E0, $30, $C0, $1D, $E1, $18
    DB      $C0, $40, $E1, $18, $C0, $2E, $E1, $18
    DB      $C0, $7D, $E1, $18, $EC, $EC, $C0, $AC
    DB      $E1, $2E, $E2, $C0, $53, $E1, $2E, $E2
    DB      $C0, $53, $E1, $2E, $E2, $C0, $FC, $E1
    DB      $2E, $E2, $C0, $AC, $E1, $2E, $E2, $C0
    DB      $53, $E1, $2E, $E2, $C0, $40, $E1, $18
    DB      $C0, $2E, $E1, $30, $EC, $EC, $C0, $AC
    DB      $E1, $2E, $E2, $C0, $53, $E1, $2E, $E2
    DB      $C0, $53, $E1, $2E, $E2, $C0, $FC, $E1
    DB      $18, $EC, $EC, $C0, $B4, $E0, $18, $C0
    DB      $D6, $E0, $18, $C0, $1D, $E1, $18, $C0
    DB      $68, $E1, $18, $EC, $EC, $C0, $FE, $E0
    DB      $16, $E2, $C0, $FE, $E0, $0C, $EC, $D0
    DB      $02, $F1, $03, $00, $00, $02, $E1, $03
    DB      $00, $00, $02, $D1, $03, $00, $00, $02
    DB      $C1, $03, $00, $00, $02, $B1, $03, $00
    DB      $00, $02, $A1, $03, $00, $00, $02, $91
    DB      $03, $00, $00, $02, $81, $03, $00, $00
    DB      $02, $71, $03, $00, $00, $02, $61, $03
    DB      $00, $00, $02, $51, $03, $00, $00, $02
    DB      $41, $03, $00, $00, $02, $31, $03, $00
    DB      $00, $02, $21, $03, $00, $00, $02, $11
    DB      $03, $00, $00, $02, $01, $03, $00, $00
    DB      $10, $02, $30, $01, $00, $00, $02, $20
    DB      $01, $00, $00, $02, $86, $06, $00, $00
    DB      $02, $46, $0C, $00, $00, $02, $86, $06
    DB      $00, $00, $10, $C0, $2F, $00, $01, $C0
    DB      $4F, $10, $01, $C0, $6F, $20, $01, $C0
    DB      $8F, $30, $01, $C0, $AF, $40, $01, $C0
    DB      $0F, $41, $01, $C0, $1F, $51, $01, $C0
    DB      $2F, $51, $01, $C0, $3F, $61, $01, $C0
    DB      $4F, $61, $01, $C0, $5F, $71, $01, $C0
    DB      $6F, $71, $01, $C0, $7F, $81, $01, $C0
    DB      $8F, $81, $01, $C0, $9F, $91, $01, $C0
    DB      $AF, $91, $01, $C0, $BF, $A1, $01, $C0
    DB      $CF, $A1, $01, $C0, $DF, $B1, $01, $C0
    DB      $EF, $B1, $01, $C0, $FF, $C1, $01, $C0
    DB      $0F, $C2, $01, $C0, $1F, $D2, $01, $C0
    DB      $2F, $D2, $01, $C0, $3F, $E2, $01, $50
    DB      $C0, $EF, $03, $01, $C0, $47, $11, $01
    DB      $C0, $5A, $22, $01, $C0, $08, $30, $01
    DB      $C0, $20, $43, $01, $C0, $11, $52, $02
    DB      $C0, $CB, $60, $02, $C0, $EF, $71, $02
    DB      $C0, $EF, $83, $02, $C0, $0F, $91, $02
    DB      $C0, $EF, $A2, $02, $C0, $EF, $B0, $02
    DB      $C0, $EF, $C2, $02, $C0, $EF, $D3, $02
    DB      $C0, $EF, $E0, $02, $50, $02, $44, $08
    DB      $00, $00, $02, $64, $08, $00, $00, $02
    DB      $84, $08, $00, $00, $02, $C4, $08, $00
    DB      $00, $02, $E4, $08, $00, $00, $10, $02
    DB      $E4, $02, $00, $00, $02, $C4, $02, $00
    DB      $00, $02, $A4, $02, $00, $00, $02, $84
    DB      $02, $00, $00, $02, $64, $02, $00, $00
    DB      $10, $C0, $28, $00, $04, $C0, $08, $00
    DB      $04, $C0, $68, $00, $04, $C0, $48, $00
    DB      $04, $C0, $50, $00, $04, $C0, $10, $00
    DB      $04, $C0, $D0, $00, $04, $C0, $90, $00
    DB      $04, $50, $C0, $30, $00, $06, $C0, $50
    DB      $00, $06, $C0, $30, $00, $06, $C0, $70
    DB      $00, $0A, $C0, $D0, $00, $01, $C0, $C8
    DB      $00, $01, $C0, $C0, $00, $01, $C0, $B8
    DB      $00, $01, $C0, $B0, $00, $01, $C0, $A8
    DB      $00, $01, $C0, $A0, $00, $01, $C0, $98
    DB      $00, $01, $C0, $90, $00, $01, $C0, $88
    DB      $00, $01, $C0, $80, $00, $01, $C0, $78
    DB      $00, $01, $C0, $70, $00, $01, $C0, $68
    DB      $00, $01, $C0, $60, $00, $01, $C0, $58
    DB      $00, $01, $C0, $50, $00, $01, $C0, $48
    DB      $00, $01, $C0, $40, $00, $01, $C0, $38
    DB      $00, $01, $C0, $30, $00, $01, $50, $02
    DB      $3E, $04, $00, $00, $02, $8E, $03, $00
    DB      $00, $02, $CE, $03, $00, $00, $10, $00
    DB      $00, $20, $30, $18, $7C, $0E, $00, $00
    DB      $0E, $7C, $18, $30, $00, $00, $00, $00
    DB      $00, $08, $18, $30, $7C, $70, $00, $00
    DB      $E0, $7C, $20, $18, $08, $00, $00, $00
    DB      $07, $0F, $1F, $38, $7F, $C0, $9F, $00
    DB      $FF, $A7, $CD, $1A, $F4, $48, $50, $BF
    DB      $AF, $A7, $87, $81, $9C, $96, $92, $A1
    DB      $A7, $AE, $AD, $AA, $A4, $A8, $A0, $36
    DB      $4A, $B2, $62, $8C, $23, $57, $90, $A0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $50, $78
    DB      $3F, $0C, $07, $00, $00, $00, $00, $48
    DB      $F9, $0F, $FF, $00, $00, $00, $00, $1C
    DB      $3C, $68, $D0, $A0, $40, $80, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $03, $07
    DB      $1E, $3C, $F8, $E3, $C4, $88, $10, $20
    DB      $40, $80, $00, $BF, $AF, $A7, $A7, $81
    DB      $9C, $96, $F2, $A0, $A0, $A0, $A0, $A0
    DB      $A0, $BF, $BF, $02, $FA, $02, $12, $8C
    DB      $E3, $FF, $40, $AA, $BF, $A0, $A0, $A0
    DB      $A0, $A0, $50, $00, $01, $03, $07, $0E
    DB      $3C, $61, $D3, $00, $FF, $9B, $BD, $14
    DB      $FE, $47, $FF, $00, $00, $80, $C0, $E0
    DB      $78, $0C, $96, $03, $03, $06, $0C, $19
    DB      $33, $6F, $FF, $FF, $06, $0C, $7F, $E0
    DB      $DB, $93, $37, $FF, $00, $00, $FF, $00
    DB      $FF, $FF, $FF, $FF, $C1, $60, $FC, $2E
    DB      $B7, $93, $D9, $80, $80, $C0, $60, $30
    DB      $98, $CC, $F6, $00, $EE, $88, $E8, $28
    DB      $EE, $00, $00, $00, $EE, $AA, $AE, $AA
    DB      $EA, $00, $00, $00, $E0, $80, $E0, $80
    DB      $E0, $00, $00, $00, $22, $2A, $2A, $36
    DB      $22, $00, $00, $00, $EA, $AA, $EA, $AA
    DB      $A4, $00, $00, $00, $EE, $4A, $4A, $4A
    DB      $4E, $00, $00, $00, $8B, $AA, $AB, $DA
    DB      $8B, $00, $00, $00, $BB, $2A, $BB, $29
    DB      $AB, $00, $00, $80, $80, $80, $80, $80
    DB      $80, $80, $80, $80, $80, $80, $80, $80
    DB      $80, $80, $80, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $10, $10, $10, $10, $20
    DB      $20, $20, $20, $40, $40, $40, $40, $80
    DB      $80, $80, $80, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $01, $01, $02, $02, $04
    DB      $04, $08, $08, $10, $10, $20, $20, $40
    DB      $40, $80, $80, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $01
    DB      $02, $02, $04, $08, $08, $10, $20, $20
    DB      $40, $80, $80, $20, $40, $80, $80, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $01, $02, $04, $08, $10
    DB      $20, $40, $80, $01, $02, $04, $08, $10
    DB      $20, $40, $80, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $03, $06, $0E, $1A, $12
    DB      $02, $03, $06, $05, $06, $03, $12, $1A
    DB      $0E, $06, $03, $80, $C0, $E0, $B0, $90
    DB      $80, $80, $C0, $40, $C0, $80, $90, $B0
    DB      $E0, $C0, $80, $03, $0F, $3B, $02, $06
    DB      $06, $0E, $1B, $15, $1B, $8E, $CC, $48
    DB      $2B, $3E, $18, $00, $80, $80, $40, $40
    DB      $20, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $03, $06, $05, $22, $27, $2A, $34, $38
    DB      $1F, $00, $00, $00, $F8, $1C, $2C, $54
    DB      $A4, $44, $44, $40, $80, $00, $00, $00
    DB      $00, $00, $00, $09, $11, $21, $11, $09
    DB      $05, $03, $01, $00, $00, $00, $80, $00
    DB      $00, $00, $00, $01, $01, $01, $01, $01
    DB      $01, $01, $01, $F0, $70, $30, $10, $10
    DB      $10, $10, $10, $54, $54, $54, $54, $54
    DB      $54, $94, $16, $00, $00, $00, $00, $00
    DB      $10, $38, $7C, $1E, $1D, $19, $11, $11
    DB      $11, $11, $11, $FF, $FF, $FF, $FF, $EF
    DB      $D7, $93, $11, $92, $92, $92, $92, $92
    DB      $12, $13, $11, $92, $12, $13, $11, $91
    DB      $52, $3C, $18, $00, $01, $02, $01, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $01, $02, $01, $28, $28, $28, $28, $28
    DB      $28, $28, $28, $01, $01, $01, $01, $02
    DB      $04, $02, $01, $00, $00, $00, $00, $00
    DB      $80, $C0, $80, $11, $11, $11, $11, $11
    DB      $11, $10, $10, $20, $20, $30, $18, $10
    DB      $20, $C0, $80, $38, $38, $28, $28, $28
    DB      $28, $28, $28, $92, $92, $92, $92, $92
    DB      $92, $92, $92, $10, $38, $7C, $FE, $FF
    DB      $FF, $FF, $EF, $00, $00, $00, $00, $01
    DB      $01, $01, $01, $D7, $93, $11, $11, $11
    DB      $11, $11, $11, $11, $11, $10, $10, $91
    DB      $52, $3C, $18, $00, $80, $C0, $E0, $F0
    DB      $F0, $F0, $F0, $00, $00, $00, $00, $00
    DB      $00, $00, $01, $02, $04, $02, $01, $00
    DB      $00, $00, $00, $7C, $7C, $6C, $54, $54
    DB      $54, $54, $54, $00, $80, $C0, $80, $00
    DB      $00, $00, $00, $01, $03, $07, $0F, $1F
    DB      $1F, $1F, $1F, $01, $02, $05, $09, $11
    DB      $11, $11, $11, $F0, $F0, $F0, $F0, $F0
    DB      $70, $30, $10, $1F, $1F, $1F, $1F, $1E
    DB      $1D, $19, $11, $00, $00, $00, $00, $01
    DB      $02, $05, $09, $00, $00, $00, $00, $00
    DB      $01, $03, $07, $00, $00, $00, $00, $01
    DB      $03, $07, $0F, $00, $00, $00, $00, $00
    DB      $80, $C0, $E0, $00, $80, $C0, $E0, $E0
    DB      $E0, $E0, $60, $01, $03, $07, $0F, $0F
    DB      $0F, $0E, $0D, $00, $00, $01, $03, $03
    DB      $03, $03, $02, $00, $00, $00, $00, $00
    DB      $01, $03, $03, $E0, $E0, $E0, $E0, $60
    DB      $20, $20, $20, $54, $54, $54, $54, $96
    DB      $54, $38, $10, $0F, $0F, $0F, $0E, $0D
    DB      $09, $09, $09, $00, $00, $00, $00, $00
    DB      $00, $80, $C0, $11, $11, $11, $11, $21
    DB      $41, $21, $11, $00, $00, $00, $00, $10
    DB      $38, $7C, $FE, $C0, $C0, $C0, $40, $40
    DB      $40, $40, $40, $00, $10, $38, $7C, $7C
    DB      $7C, $6C, $54, $00, $00, $00, $00, $00
    DB      $80, $40, $20, $28, $28, $28, $28, $6C
    DB      $38, $00, $00, $FE, $EE, $D6, $92, $92
    DB      $92, $92, $92, $00, $00, $00, $00, $00
    DB      $10, $28, $28, $03, $03, $02, $02, $02
    DB      $02, $02, $02, $10, $38, $7C, $FE, $FE
    DB      $FE, $EE, $D6, $00, $00, $10, $28, $28
    DB      $28, $28, $28, $00, $10, $28, $54, $54
    DB      $54, $54, $54, $11, $11, $11, $11, $11
    DB      $11, $01, $01, $00, $00, $00, $00, $00
    DB      $10, $38, $38, $00, $00, $00, $00, $00
    DB      $10, $28, $54, $00, $00, $10, $38, $38
    DB      $38, $38, $28, $10, $28, $54, $92, $92
    DB      $92, $92, $92, $00, $00, $00, $00, $10
    DB      $28, $54, $92, $93, $52, $3C, $18, $00
    DB      $00, $00, $00, $11, $11, $11, $11, $11
    DB      $11, $11, $11, $10, $10, $10, $10, $10
    DB      $18, $0C, $08, $10, $28, $54, $92, $11
    DB      $11, $11, $11, $00, $00, $80, $C0, $C0
    DB      $C0, $C0, $40, $54, $54, $54, $54, $54
    DB      $54, $54, $54, $00, $01, $03, $07, $07
    DB      $07, $06, $05, $07, $07, $06, $05, $05
    DB      $05, $05, $05, $10, $10, $10, $10, $10
    DB      $10, $10, $10, $28, $6C, $38, $00, $00
    DB      $00, $00, $00, $02, $02, $02, $02, $02
    DB      $02, $02, $02, $00, $00, $00, $00, $00
    DB      $00, $00, $80, $54, $54, $94, $16, $93
    DB      $52, $3C, $18, $00, $00, $00, $01, $00
    DB      $00, $00, $00, $00, $80, $40, $20, $10
    DB      $10, $10, $10, $80, $80, $80, $80, $80
    DB      $80, $80, $80, $00, $00, $00, $00, $00
    DB      $01, $02, $02, $00, $00, $00, $00, $00
    DB      $00, $80, $80, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $02, $06, $03, $00, $00
    DB      $00, $00, $00, $80, $C0, $80, $00, $00
    DB      $00, $00, $00, $10, $18, $0C, $08, $10
    DB      $20, $C0, $80, $21, $41, $21, $11, $09
    DB      $05, $03, $01, $00, $00, $01, $02, $02
    DB      $02, $02, $02, $00, $00, $00, $80, $80
    DB      $80

; ============================================================
; TILE / SPRITE BITMAPS  ($BC00 - $BF6F)
; TMS9918A pattern table -- 8 bytes per tile (one byte per row).
; 110 tiles total.
; ============================================================
TILE_BITMAPS:                              ; TILE_BITMAPS: sprite/tile pattern bitmaps for VDP pattern generator
    DB      $80, $80, $02, $02, $02, $02, $06, $03 ; tile 0
    DB      $00, $00, $80, $80, $80, $80, $C0, $80 ; tile 1
    DB      $00, $00, $00, $01, $02, $05, $05, $05 ; tile 2
    DB      $05, $05, $00, $00, $80, $40, $40, $40 ; tile 3
    DB      $40, $40, $05, $05, $05, $05, $05, $05 ; tile 4
    DB      $05, $05, $40, $40, $40, $40, $40, $40 ; tile 5
    DB      $40, $40, $05, $05, $05, $05, $09, $05 ; tile 6
    DB      $03, $01, $40, $40, $40, $40, $60, $40 ; tile 7
    DB      $80, $00, $00, $00, $00, $00, $00, $01 ; tile 8
    DB      $02, $05, $00, $00, $00, $00, $00, $00 ; tile 9
    DB      $00, $00, $00, $00, $00, $00, $00, $00 ; tile 10
    DB      $80, $40, $05, $05, $05, $05, $05, $05 ; tile 11
    DB      $09, $11, $40, $40, $40, $40, $40, $40 ; tile 12
    DB      $40, $60, $09, $05, $03, $01, $00, $00 ; tile 13
    DB      $00, $00, $30, $20, $C0, $80, $00, $00 ; tile 14
    DB      $00, $00, $40, $40, $40, $60, $30, $20 ; tile 15
    DB      $C0, $80, $05, $05, $09, $11, $09, $05 ; tile 16
    DB      $03, $01, $09, $09, $09, $09, $09, $09 ; tile 17
    DB      $09, $09, $20, $20, $20, $20, $20, $20 ; tile 18
    DB      $20, $20, $09, $09, $09, $09, $09, $11 ; tile 19
    DB      $21, $11, $20, $20, $20, $20, $20, $20 ; tile 20
    DB      $30, $18, $10, $20, $C0, $80, $00, $00 ; tile 21
    DB      $00, $00, $09, $05, $03, $01, $00, $00 ; tile 22
    DB      $00, $00, $01, $02, $05, $09, $09, $09 ; tile 23
    DB      $09, $09, $00, $80, $40, $20, $20, $20 ; tile 24
    DB      $20, $20, $80, $80, $80, $80, $80, $80 ; tile 25
    DB      $80, $80, $40, $40, $40, $40, $40, $40 ; tile 26
    DB      $40, $40, $20, $20, $20, $20, $20, $20 ; tile 27
    DB      $20, $20, $10, $10, $10, $10, $10, $10 ; tile 28
    DB      $10, $10, $08, $08, $08, $08, $08, $08 ; tile 29
    DB      $08, $08, $04, $04, $04, $04, $04, $04 ; tile 30
    DB      $04, $04, $02, $02, $02, $02, $02, $02 ; tile 31
    DB      $02, $02, $01, $01, $01, $01, $01, $01 ; tile 32
    DB      $01, $01, $40, $40, $40, $40, $80, $80 ; tile 33
    DB      $80, $80, $10, $10, $10, $10, $20, $20 ; tile 34
    DB      $20, $20, $04, $04, $04, $04, $08, $08 ; tile 35
    DB      $08, $08, $01, $01, $01, $01, $02, $02 ; tile 36
    DB      $02, $02, $20, $20, $40, $40, $40, $80 ; tile 37
    DB      $80, $80, $04, $08, $08, $08, $10, $10 ; tile 38
    DB      $10, $20, $01, $01, $01, $02, $02, $02 ; tile 39
    DB      $04, $04, $10, $10, $20, $20, $40, $40 ; tile 40
    DB      $80, $80, $01, $01, $02, $02, $04, $04 ; tile 41
    DB      $08, $08, $04, $08, $10, $10, $20, $40 ; tile 42
    DB      $40, $80, $00, $00, $00, $00, $01, $01 ; tile 43
    DB      $02, $04, $20, $40, $40, $80, $00, $00 ; tile 44
    DB      $00, $00, $01, $02, $02, $04, $08, $08 ; tile 45
    DB      $10, $20, $04, $04, $08, $10, $20, $40 ; tile 46
    DB      $40, $80, $00, $00, $00, $00, $00, $00 ; tile 47
    DB      $01, $02, $08, $10, $20, $40, $40, $80 ; tile 48
    DB      $00, $00, $00, $00, $00, $00, $01, $02 ; tile 49
    DB      $04, $04, $20, $40, $40, $80, $00, $00 ; tile 50
    DB      $00, $00, $00, $00, $01, $02, $04, $04 ; tile 51
    DB      $08, $10, $40, $80, $00, $00, $00, $00 ; tile 52
    DB      $00, $00, $01, $02, $04, $04, $08, $10 ; tile 53
    DB      $20, $40, $01, $02, $04, $08, $10, $20 ; tile 54
    DB      $40, $80, $00, $00, $00, $00, $00, $00 ; tile 55
    DB      $FE, $FF, $00, $0F, $F8, $00, $00, $00 ; tile 56
    DB      $00, $00, $F8, $00, $00, $00, $00, $00 ; tile 57
    DB      $00, $00, $01, $03, $06, $00, $00, $00 ; tile 58
    DB      $00, $FF, $80, $00, $00, $00, $00, $00 ; tile 59
    DB      $00, $FF, $00, $00, $00, $00, $00, $00 ; tile 60
    DB      $00, $F7, $04, $0C, $09, $00, $00, $00 ; tile 61
    DB      $00, $CF, $6C, $2C, $94, $00, $00, $00 ; tile 62
    DB      $00, $FF, $00, $3E, $1B, $00, $00, $00 ; tile 63
    DB      $00, $C0, $70, $18, $8C, $00, $00, $00 ; tile 64
    DB      $00, $00, $00, $03, $06, $08, $08, $08 ; tile 65
    DB      $0C, $0E, $0F, $FF, $00, $3F, $38, $38 ; tile 66
    DB      $1C, $0C, $06, $06, $0D, $F1, $31, $63 ; tile 67
    DB      $43, $C7, $86, $84, $0D, $F1, $F3, $A0 ; tile 68
    DB      $20, $40, $43, $82, $87, $8C, $C6, $03 ; tile 69
    DB      $03, $01, $C1, $20, $E0, $00, $00, $00 ; tile 70
    DB      $88, $86, $C3, $61, $70, $04, $8C, $3C ; tile 71
    DB      $1C, $0E, $83, $C0, $70, $00, $00, $00 ; tile 72
    DB      $00, $00, $00, $FE, $03, $0F, $18, $1F ; tile 73
    DB      $7F, $60, $60, $C1, $83, $FF, $00, $FF ; tile 74
    DB      $E1, $61, $E2, $E4, $A8, $FA, $13, $F3 ; tile 75
    DB      $EF, $01, $03, $07, $0E, $FB, $1B, $FB ; tile 76
    DB      $FF, $F0, $C0, $40, $81, $FC, $0C, $78 ; tile 77
    DB      $FB, $0E, $06, $07, $C3, $3F, $18, $1F ; tile 78
    DB      $FF, $00, $00, $83, $81, $F7, $14, $FF ; tile 79
    DB      $F7, $00, $00, $FE, $E3, $DF, $C8, $47 ; tile 80
    DB      $E7, $7A, $18, $0E, $0F, $FF, $00, $FF ; tile 81
    DB      $FF, $00, $00, $07, $83, $80, $80, $80 ; tile 82
    DB      $E0, $30, $08, $F8, $00, $01, $02, $06 ; tile 83
    DB      $0C, $18, $30, $60, $C0, $03, $04, $00 ; tile 84
    DB      $00, $00, $1C, $38, $78, $30, $20, $00 ; tile 85
    DB      $00, $01, $03, $07, $0E, $1D, $3A, $74 ; tile 86
    DB      $EC, $D8, $B0, $60, $C0, $03, $07, $00 ; tile 87
    DB      $00, $00, $3F, $61, $CF, $41, $E1, $00 ; tile 88
    DB      $00, $00, $C0, $60, $30, $C0, $C0, $C0 ; tile 89
    DB      $C1, $60, $60, $30, $30, $7F, $00, $00 ; tile 90
    DB      $80, $E0, $B8, $CE, $67, $8B, $19, $30 ; tile 91
    DB      $1C, $07, $00, $00, $80, $E0, $F8, $7E ; tile 92
    DB      $0F, $FE, $00, $00, $00, $F8, $38, $0E ; tile 93
    DB      $03, $01, $03, $06, $0D, $FF, $80, $FF ; tile 94
    DB      $80, $FF, $00, $00, $00, $EF, $D8, $AF ; tile 95
    DB      $C8, $8F, $00, $00, $00, $FD, $0B, $FE ; tile 96
    DB      $0C, $F8, $00, $00, $00, $A0, $DF, $A0 ; tile 97
    DB      $C0, $80, $00, $00, $00, $FF, $E0, $7F ; tile 98
    DB      $20, $1F, $00, $00, $00, $F7, $14, $F7 ; tile 99
    DB      $14, $F7, $00, $00, $00, $F3, $09, $F9 ; tile 100
    DB      $08, $F8, $00, $00, $00, $FF, $00, $FF ; tile 101
    DB      $00, $FF, $00, $00, $00, $FF, $00, $FF ; tile 102
    DB      $00, $FF, $00, $00, $00, $FB, $16, $FC ; tile 103
    DB      $18, $F0, $00, $00, $00, $00, $0F, $04 ; tile 104
    DB      $03, $00, $00, $00, $00, $00, $00, $00 ; tile 105
    DB      $00, $0F, $04, $03, $00, $00, $FC, $12 ; tile 106
    DB      $FF, $00, $60, $60, $90, $F8, $70, $20 ; tile 107
    DB      $60, $7C, $32, $FF, $00, $00, $00, $00 ; tile 108
    DB      $00, $00, $00, $00, $00, $00, $08, $0E ; tile 109

; ============================================================
; ZERO PADDING  ($BF70 - $BFFF)
; ============================================================
    DB      $0C, $0C, $07, $01, $00, $C0, $F0, $9C
    DB      $C7, $75, $1F, $27, $E1, $70, $50, $C0
    DB      $80, $00, $60, $E0, $60, $00, $00, $00
    DB      $00, $00, $00, $03, $03, $41, $62, $76
    DB      $6C, $34, $1E, $0E, $06, $60, $70, $68
    DB      $34, $1A, $6E, $46, $C2, $C0, $C0, $00
    DB      $00, $00, $00, $00, $00, $03, $06, $04
    DB      $08, $1F, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $C0, $60, $20
    DB      $10, $F8, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $07, $04, $0C, $08, $18
    DB      $10, $30, $20, $7F, $00, $00, $00, $00
    DB      $00, $00, $00, $E0, $20, $30, $10, $18
    DB      $08, $0C, $04, $FE, $00, $00, $00, $00
    DB      $00, $00, $07, $04, $0C, $08, $18, $10
    DB      $30, $20, $60, $40, $FF, $00, $00, $00
    DB      $00, $00, $E0, $20, $30, $10, $18, $08
    DB      $0C, $04, $06, $02, $FF, $00, $00, $00

; ---- mid-instruction label aliases (EQU) ----
LOC_87DB:        EQU $87DB
LOC_9E6D:        EQU $9E6D
LOC_A93D:        EQU $A93D
