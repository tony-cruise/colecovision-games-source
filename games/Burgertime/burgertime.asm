; ===== BURGERTIME (1984) DISASSEMBLY LEGEND =====
; ROM: 16 KB ($8000-$BFFF). VDP $BE/$BF. SN76489A on $FF.
; Cart magic: $55AA (reversed from standard $AA55).
;
; === CART ENTRY & TOP-LEVEL LOOPS ===
; CART_ENTRY (JP NMI; copyright str) ........ 202
; LOC_8076 (game init: VDP, sprites, sound) .. 226
; LOC_80D1 (state branch: lives/stage check) . 262
; LOC_8130 (main game tick loop) ............. 308
;
; === BOOT & INIT ===
; START (GAME_OPT, clear $7000-$73AF, attract) 212
; SUB_859E (VDP/display init: INIT_TABLE x5) .. 914
; SUB_90AC (player init: copy table->$70B1) ... 2584
;
; === NMI ===
; NMI (save all regs, TIME_MGR/SOUND_MAN/POLLER, 949
;     burger scroll, dec timers, WR_SPR_NM_TBL)
;
; === SOUND ===
; SOUND_WRITE_8753 (title/attract wait loop) .. 1138
; SOUND_WRITE_8CAB (load sound table $B853) ... 1960
; SOUND_WRITE_8CE9 (play channel sequence) .... 1998
; SUB_9CD7 (SOUND_INIT: B=4, HL=$9D2F) ....... 3746
; SUB_9CDF (PLAY_IT channels 1+2) ............. 3751
; SUB_9CE9 (PLAY_IT channels 3+4) ............. 3757
; SUB_9CF3 (PLAY_IT channels 5+6) ............. 3763
;
; === VDP ACCESS ===
; SUB_8397 (clear name table VRAM $1800/$0300) . 608
; DELAY_LOOP_83F8 (load 3 VDP tile pages) ..... 673
; DELAY_LOOP_8441 (load 1 tile page 17 rows) .. 708
; SUB_8469 (load sprite pattern tables x3) .... 734
; DELAY_LOOP_82CE (render score/HUD tiles) .... 523
;
; === PLAYER ===
; SUB_883C (player movement: $706F/$7070 Y/X) .. 1281
; SUB_87B9 (copy sprite indices -> $7061-$7065) . 1213
; SUB_8A71 (player walk + pepper action) ...... 1644
; SUB_84D1 (ingredient Y/X bounds + step type) . 790
; SUB_8268 (target burger-layer count for level) 468
;
; === ENEMY ===
; SUB_921D (enemy tick: gate, speed, PUTOBJ) ... 2807
; SUB_8E64 (pepper/enemy bounding-box hit) ..... 2229
; SUB_9A3D (bounding-box collision check) ...... 3306
; SUB_9A68 (shift enemy spawn ring buffer) ..... 3341
;
; === BURGER LAYERS ===
; SUB_9B95 (burger collision + layer drop) ..... 3538
; SUB_9CB7 (burger anim scroll one step) ....... 3717
; VDP_REG_9C7B (set VRAM addr lo byte) ......... 3662
; VDP_WRITE_9C80 (set VRAM read addr HL) ....... 3668
; VDP_WRITE_9C8B (set VRAM write addr HL+$40) .. 3677
;
; === SYNC & TIMING ===
; SUB_9046 (wait-for-NMI: spin on $7066) ...... 2525
; SUB_9053 (NMI sync + VDP disable) ........... 2537
; SUB_905F (VDP enable: WRITE_REGISTER $01E2) .. 2545
; SUB_83E2 (wait-for-frame: spin on $706E) ..... 657
;
; === SCORE & BONUS ===
; SUB_9AE7 (BCD score accumulate 3 bytes) ...... 3434
; DELAY_LOOP_9B1E (score write + controller) ... 3482
; SUB_9942 (bonus item check via $716D) ......... 3218
; SUB_9B42 (player walk animation frame) ........ 3518
;
; === MISC HELPERS ===
; SUB_8496 (tile index lookup from $B307 table) . 751
; SUB_9071 (RLCA x4: swap nibbles) ............. 2564
; SUB_9099 (SRL x3: A = A / 8) ................. 2576
; DELAY_LOOP_906A (fill B bytes at HL with A) .. 2554
; SUB_82BD (FILL_VRAM 1-byte helper) ........... 510
; SUB_82A8 (load 12 player vars from state) .... 497
;
; === KEY RAM ($7000-$73B9) ===
; $7047 JOYSTICK_BUFFER (non-std; std $5A48)
; $7054 player 1(0)/player 2(1) flag
; $705A game state (E0=title, C0=between lvl, F0=lvl done, D0=game-over)
; $705B stage number (0-based)
; $705C completed burger layer count (increases enemy speed)
; $705D active ingredient/burger tile count
; $705E pending burger tile drop count
; $705F stage loop counter (max $0B)
; $7060 screen/level iteration counter
; $7066 NMI-occurred flag (set in NMI, cleared by SUB_9046)
; $706E frame-rate timer (decremented in NMI; speed depends on $705C)
; $706F/$7070 player Y/X pixel position
; $7076/$7077 scroll ring index / previous scroll index
; $707C active enemy count
; $7080 enemy tick gate timer (decremented in NMI)
; $7083 bonus score timer (decremented in NMI)
;
; === DATA BLOCKS ===
; GAME_DATA (level/map data block) .............. 4422
; TILE_BITMAPS (sprite pattern bitmaps) ......... 4815
; DELAY_LOOP_BD9A (timing delay loop) ........... 4869
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

                                           ; BIOS SUBROUTINE JUMP TABLE DEFINITIONS

BOOT_UP:                 EQU $0000         ; BOOT_UP: warm/soft reset entry ($0000)
BIOS_NMI:                EQU $0066         ; BIOS_NMI: BIOS NMI vector ($0066)
NUMBER_TABLE:            EQU $006C
PLAY_SONGS:              EQU $1F61         ; PLAY_SONGS: play song data via SOUND_MAN
ACTIVATEP:               EQU $1F64         ; ACTIVATEP: pointer-mode sprite activate
REFLECT_VERTICAL:        EQU $1F6A
REFLECT_HORIZONTAL:      EQU $1F6D
ROTATE_90:               EQU $1F70
ENLARGE:                 EQU $1F73
CONTROLLER_SCAN:         EQU $1F76         ; CONTROLLER_SCAN: raw controller scan
DECODER:                 EQU $1F79         ; DECODER: decode raw controller -> CONTROLLER_BUFFER
GAME_OPT:                EQU $1F7C         ; GAME_OPT: process option selection screen
LOAD_ASCII:              EQU $1F7F
FILL_VRAM:               EQU $1F82         ; FILL_VRAM: fill VRAM at HL with A, count DE
MODE_1:                  EQU $1F85         ; MODE_1: set VDP mode 1 (40-col text)
UPDATE_SPINNER:          EQU $1F88
INIT_TABLEP:             EQU $1F8B         ; INIT_TABLEP: pointer-mode table init
PUT_VRAMP:               EQU $1F91
INIT_SPR_ORDERP:         EQU $1F94
INIT_TIMERP:             EQU $1F9A
REQUEST_SIGNALP:         EQU $1FA0
TEST_SIGNALP:            EQU $1FA3
WRITE_REGISTERP:         EQU $1FA6         ; WRITE_REGISTERP: pointer-mode VDP reg write
INIT_WRITERP:            EQU $1FAF         ; INIT_WRITERP: pointer-mode WRITER init
SOUND_INITP:             EQU $1FB2         ; SOUND_INITP: pointer-mode sound init
PLAY_ITP:                EQU $1FB5         ; PLAY_ITP: pointer-mode PLAY_IT
INIT_TABLE:              EQU $1FB8         ; INIT_TABLE: initialize VRAM table (A=table#, HL=base)
GET_VRAM:                EQU $1FBB         ; GET_VRAM: read tile at VRAM offset into buffer
PUT_VRAM:                EQU $1FBE         ; PUT_VRAM: write tile data from HL to VRAM at DE (IY=stride)
INIT_SPR_NM_TBL:         EQU $1FC1         ; INIT_SPR_NM_TBL: init sprite name table in RAM
WR_SPR_NM_TBL:           EQU $1FC4         ; WR_SPR_NM_TBL: write sprite name table to VRAM (A=count)
INIT_TIMER:              EQU $1FC7         ; INIT_TIMER: init timer channel at HL
FREE_SIGNAL:             EQU $1FCA         ; FREE_SIGNAL: release BIOS signal slot
REQUEST_SIGNAL:          EQU $1FCD         ; REQUEST_SIGNAL: allocate BIOS signal slot
TEST_SIGNAL:             EQU $1FD0         ; TEST_SIGNAL: test BIOS signal
TIME_MGR:                EQU $1FD3         ; TIME_MGR: advance all timer channels (call from NMI)
TURN_OFF_SOUND:          EQU $1FD6         ; TURN_OFF_SOUND: silence all sound channels
WRITE_REGISTER:          EQU $1FD9         ; WRITE_REGISTER: write VDP register (BC: B=reg, C=val)
READ_REGISTER:           EQU $1FDC         ; READ_REGISTER: read VDP status register -> A
WRITE_VRAM:              EQU $1FDF         ; WRITE_VRAM: write data to VRAM
READ_VRAM:               EQU $1FE2         ; READ_VRAM: read data from VRAM
INIT_WRITER:             EQU $1FE5         ; INIT_WRITER: init WRITER DMA engine (A=mode, HL=buf)
WRITER:                  EQU $1FE8         ; WRITER: DMA-copy tile buffer to VRAM
POLLER:                  EQU $1FEB         ; POLLER: poll controller input -> JOYSTICK_BUFFER / CONTROLLER_BUFFER
SOUND_INIT:              EQU $1FEE         ; SOUND_INIT: init sound engine (B=channels, HL=song table)
PLAY_IT:                 EQU $1FF1         ; PLAY_IT: play sound effect (B=channel index)
SOUND_MAN:               EQU $1FF4         ; SOUND_MAN: advance sound engine (call from NMI)
ACTIVATE:                EQU $1FF7         ; ACTIVATE: activate sprite slot for object at IY
PUTOBJ:                  EQU $1FFA         ; PUTOBJ: display object record at IX (pos+sprite)
RAND_GEN:                EQU $1FFD         ; RAND_GEN: LCG random number generator -> A

                                           ; I/O PORT DEFINITIONS

KEYBOARD_PORT:           EQU $0080         ; KEYBOARD_PORT: $0080 keyboard matrix
DATA_PORT:               EQU $00BE         ; DATA_PORT: $00BE VDP VRAM data read/write
CTRL_PORT:               EQU $00BF         ; CTRL_PORT: $00BF VDP control/status port
JOY_PORT:                EQU $00C0         ; JOY_PORT: $00C0 joystick input port
CONTROLLER_02:           EQU $00F5         ; CONTROLLER_02: $00F5 player 2 controller port
CONTROLLER_01:           EQU $00FC         ; CONTROLLER_01: $00FC player 1 controller port
SOUND_PORT:              EQU $00FF         ; SOUND_PORT: $00FF SN76489A sound chip port

                                           ; RAM DEFINITIONS

WORK_BUFFER:             EQU $7000         ; WORK_BUFFER: $7000 general work RAM base
CONTROLLER_BUFFER:       EQU $702B         ; CONTROLLER_BUFFER: $702B BIOS controller state buffer
JOYSTICK_BUFFER:         EQU $7047         ; JOYSTICK_BUFFER: $7047 BIOS joystick buffer (non-std; std $5A48)
STACKTOP:                EQU $73B9         ; STACKTOP: $73B9 stack top

FNAME "output\BURGERTIME-1984-NEW.ROM"     ; output ROM file: BURGERTIME-1984-NEW.ROM
CPU Z80

    ORG     $8000                          ; ROM base address $8000

    DW      $55AA                          ; cart magic word $55AA (reversed from standard $AA55)
    DB      $0C, $71                       ; header bytes: I/O pointers
    DB      $4C, $71                       ; header bytes continued
    DB      $00, $70                       ; header bytes continued
    DW      JOYSTICK_BUFFER                ; BIOS joystick state address ($7047) in header
    DW      START                          ; game start address (START label)
    DB      $C9, $00, $00, $C9, $00, $00, $C9, $00; NOP/RET stubs for unused BIOS slots
    DB      $00, $C9, $00, $00, $C9, $00, $00, $C9; NOP/RET stubs continued
    DB      $00, $00, $ED, $4D, $00        ; RETN at end of cart header block

CART_ENTRY:                                ; cart entry point: JP NMI (NMI handler is true game entry)
    JP      NMI                            ; jump to NMI at $86A0
    DB      $1D, $00, $31, $39, $38, $32, $20, $44; copyright string: 1982 Data East U.S.A. Inc.
    DB      $41, $54, $41, $20, $45, $41, $53, $54; copyright string continued: "ATA EAST"
    DB      $20, $55, $2E, $53, $2E, $41, $2E, $2C; copyright string continued: " U.S.A.,"
    DB      $49, $4E, $43, $2E, $2F, $50, $52, $45; copyright string continued: "INC./PRE"
    DB      $53, $45, $4E, $54, $53, $20, $42, $55; copyright string continued: "SENTS BU"
    DB      $52, $47, $45, $52, $54, $49, $4D, $45; copyright string continued: "RGERTIME"
    DB      $1E, $1F, $2F, $31, $39, $38, $34; copyright string tail: year and markers

START:                                     ; START: cold start - GAME_OPT, clear RAM, set title state, start
    CALL    GAME_OPT                       ; BIOS option screen: select 1/2 players and difficulty
    LD      HL, WORK_BUFFER                ; HL = WORK_BUFFER ($7000): begin RAM clear
    LD      E, L                           ; DE = HL (dest = source+1 for LDIR fill)
    LD      D, H                           ; DE = HL+1
    INC     DE                             ; DE++
    LD      BC, $03AF                      ; BC = $03AF: clear $03B0 bytes ($7000-$73AF)
    LD      (HL), $00                      ; (HL) = $00: seed value for LDIR fill
    LDIR                                   ; LDIR: zero-fill $7000-$73AF
    LD      A, $E0                         ; A = $E0 (title/attract state)
    LD      ($705A), A                     ; set game state $705A = $E0 (title screen)
    CALL    SOUND_WRITE_8753               ; run title screen / attract mode wait loop
    CALL    SUB_8397                       ; clear VDP name table: VRAM $1800, $0300 bytes

LOC_8076:                                  ; LOC_8076: game init loop (per life / level start)
    CALL    SUB_859E                       ; VDP/display init (clear bufs, INIT_WRITER, WRITE_REGISTER, INIT_TABLE x5)
    CALL    SUB_8469                       ; load sprite pattern tables (3 banks: $AEF8, $AF90, $15A3)
    CALL    DELAY_LOOP_83F8                ; load 3 VDP tile pages from $B19F table
    CALL    SUB_9CD7                       ; SOUND_INIT wrapper: B=4 channels, HL=$9D2F song table
    LD      HL, $73C7                      ; HL = $73C7: init-complete flag address
    LD      (HL), $01                      ; ($73C7) = $01: mark init complete
    SUB     A                              ; A = 0: clear $73C6 counter
    LD      ($73C6), A                     ; ($73C6) = 0
    LD      A, $01                         ; A = $01: stride byte for PUT_VRAM
    LD      IY, $0100                      ; IY = $0100: row stride
    LD      HL, $A798                      ; HL = $A798: game name-table tile data
    LD      DE, BOOT_UP                    ; DE = BOOT_UP ($0000): VRAM base address
    CALL    PUT_VRAM                       ; PUT_VRAM: write game name-table to VRAM
    LD      HL, $73C6                      ; HL = $73C6
    INC     (HL)                           ; increment $73C6 counter
    CALL    SUB_905F                       ; SUB_905F: VDP enable (WRITE_REGISTER $01E2)
    LD      A, $06                         ; A = $06: frame-rate timer initial value
    LD      ($706E), A                     ; ($706E) = $06: set frame timer
    LD      A, $06                         ; A = $06: enemy tick gate initial value
    LD      ($7080), A                     ; ($7080) = $06: set enemy tick gate
    LD      A, $8B                         ; A = $8B: joystick/controller init byte
    LD      (JOYSTICK_BUFFER), A           ; (JOYSTICK_BUFFER) = $8B: init $7047
    LD      ($7048), A                     ; ($7048) = $8B: init secondary joy byte
    LD      DE, $702F                      ; DE = $702F: player 1 state block
    CALL    SUB_8283                       ; init player 1 state from ROM table
    LD      DE, $703B                      ; DE = $703B: player 2 state block
    CALL    SUB_8283                       ; init player 2 state from ROM table
    LD      A, $01                         ; A = $01: player 2 flag
    LD      ($7054), A                     ; ($7054) = $01: select player 2
    CALL    SOUND_WRITE_8CAB               ; init player 2 sprite/animation table
    SUB     A                              ; A = 0: player 1 flag
    LD      ($7054), A                     ; ($7054) = $00: select player 1
    CALL    SOUND_WRITE_8CAB               ; init player 1 sprite/animation table
    CALL    SOUND_WRITE_8CAB               ; init player 1 sprite/animation table again

LOC_80D1:                                  ; LOC_80D1: game state branch (check lives/stage)
    CALL    SUB_82A8                       ; update active player vars from saved state
    LD      A, ($705B)                     ; A = ($705B): stage number
    OR      A                              ; test if any stages pending
    JR      NZ, LOC_80ED                   ; if stages > 0, go handle stage display
    LD      A, ($7054)                     ; A = ($7054): player 1/2 flag
    OR      A                              ; test player flag
    LD      A, ($7041)                     ; A = ($7041): player 1 lives
    JR      Z, LOC_80E6                    ; if P1, use $7041 lives
    LD      A, ($7035)                     ; A = ($7035): player 2 lives

LOC_80E6:                                  ; test A: if lives > 0 go to game, else game over
    OR      A                              ; if lives > 0 jump to game-tick setup
    JP      NZ, LOC_8213                   ; if lives = 0 jump to game-over flow
    JP      LOC_8204

LOC_80ED:                                  ; LOC_80ED: stage display path (stages pending)
    LD      HL, $837C                      ; HL = $837C: score tile data
    LD      DE, $014C                      ; DE = $014C: VRAM offset for score area
    CALL    SUB_83A6                       ; render score area; Z if extra-life check passes
    JR      Z, LOC_810A                    ; if Z skip player select display
    LD      A, ($7054)                     ; A = ($7054): player flag
    OR      A                              ; test player
    LD      HL, $8385                      ; HL = $8385: P1 score display data
    JR      Z, LOC_8104                    ; if P1, use P1 label
    LD      HL, $838E                      ; HL = $838E: P2 score display data

LOC_8104:                                  ; DE = $018D: VRAM offset
    LD      DE, $018D                      ; render player label/score to VRAM
    CALL    SUB_83F3

LOC_810A:                                  ; wait for frame (spin on $706E)
    CALL    SUB_83E2                       ; update camera IX pointer from $7067
    CALL    SUB_8C71                       ; save IX -> $7067 game-screen IX pointer
    LD      ($7067), IX                    ; CALL SUB_B949 (screen renderer)
    CALL    SUB_B949                       ; player init: copy $90A6 table to $70B1, PUTOBJ
    CALL    SUB_90AC                       ; init sound channels 3+4
    CALL    SUB_9CE9                       ; NMI sync + VDP disable
    CALL    SUB_9053                       ; render game screen score/HUD
    CALL    DELAY_LOOP_82CE                ; SOUND_WRITE_8CE9: play sound channel sequence from IX
    CALL    SOUND_WRITE_8CE9               ; VDP enable
    CALL    SUB_905F                       ; start sound channels 1+2
    CALL    SUB_9CDF
    SUB     A                              ; A = 0: clear $705A game state
    LD      ($705A), A                     ; ($705A) = 0 (game-play state)

LOC_8130:                                  ; LOC_8130: main game tick (per-frame inner loop)
    CALL    SUB_9046                       ; wait for NMI flag ($7066 != 0)
    CALL    SUB_87B9                       ; copy player sprite indices from table -> $7061-$7065
    CALL    SUB_883C                       ; player movement: update $706F/$7070 Y/X position
    CALL    SUB_921D                       ; enemy tick: check gate, move each enemy record
    CALL    SUB_8E64                       ; pepper/enemy hit detect (bounding-box checks)
    LD      A, ($7055)                     ; A = ($7055): current level-within-stage (0-5)
    CP      $03                            ; compare level to $03
    LD      B, $05                         ; B = $05: call SUB_8A71 5 times if level=$03
    JR      Z, LOC_8150                    ; if level=3 jump with B=$05
    CP      $04                            ; compare level to $04
    LD      B, $03                         ; B = $03: call SUB_8A71 3 times if level=$04
    JR      Z, LOC_8150                    ; if level=4 jump with B=$03
    LD      B, $01                         ; B = $01: default 1 call

LOC_8150:                                  ; push call count
    PUSH    BC                             ; player walk + pepper action (IX=$7067)
    CALL    SUB_8A71                       ; pop; loop SUB_8A71 B times
    POP     BC
    DJNZ    LOC_8150                       ; loop B times
    CALL    SUB_9942                       ; bonus item check ($716D)
    CALL    SUB_9B95                       ; burger collision + drop logic
    LD      A, ($705D)                     ; A = ($705D): active burger tile count
    LD      B, A                           ; B = active count
    CALL    SUB_8268                       ; SUB_8268: get target burger count for current level
    CP      B                              ; compare actual vs target
    JR      NZ, LOC_81AE                   ; if not equal, game tick continues
    SUB     A                              ; A = 0
    LD      ($705D), A                     ; ($705D) = 0: clear active tile count
    LD      ($705E), A                     ; ($705E) = 0: clear pending drop count
    LD      A, ($705A)                     ; A = ($705A): game state
    CP      $F0                            ; compare to $F0 (level-complete state)
    JR      NZ, LOC_8178                   ; if not $F0, set state $C0 (between-level)
    CALL    SUB_BDC6                       ; level complete: call BurgerTime victory routine

LOC_8178:                                  ; A = $C0 (between-level state)
    LD      A, $C0                         ; ($705A) = $C0
    LD      ($705A), A                     ; init next level sound channels 5+6
    CALL    SUB_9CF3                       ; A = $0A: count for level-complete sequence
    LD      A, $0A                         ; ($7076) = $0A: scroll ring update count
    LD      ($7076), A                     ; C = $0A
    LD      C, A                           ; run scroll/animation delay loop
    CALL    DELAY_LOOP_BD9A                ; HL = $7060: level iteration counter
    LD      HL, $7060                      ; increment $7060
    INC     (HL)                           ; HL = $7055: level-within-stage
    LD      HL, $7055                      ; increment $7055
    INC     (HL)                           ; A = $7055 value
    LD      A, (HL)                        ; compare to $06
    CP      $06                            ; if less than 6 keep going
    JR      NZ, LOC_81A4                   ; ($7055) = $00: wrap level back to 0
    LD      (HL), $00                      ; A = ($705F): stage loop counter
    LD      A, ($705F)                     ; increment stage loop counter
    INC     A                              ; compare to $0B (max 11 stage loops)
    OR      A                              ; if less than $0B keep incrementing
    CP      $0B
    JR      NC, LOC_81A4                   ; ($705F) = stage loop: cap at $0B
    LD      ($705F), A                  ; RAM $705F

LOC_81A4:                                  ; SOUND_WRITE_8CAB: load sound table for next stage
    CALL    SOUND_WRITE_8CAB               ; HL = $705C: burger layer count
    LD      HL, $705C                      ; increment $705C (enemy speed up)
    INC     (HL)                           ; jump to stage display path
    JP      LOC_80ED

LOC_81AE:                                  ; LOC_81AE: burger target not met - check state $F0 (level done)
    LD      A, ($705A)                     ; A = ($705A): game state
    CP      $F0                            ; compare to $F0 (level-complete)
    JP      NZ, LOC_8130                   ; if not $F0, continue game tick
    CALL    SUB_8C71                       ; SUB_8C71: set IX = player sprite record pointer ($71DA or $725B)

LOC_81B9:                                  ; LOC_81B9: wait for all sprites to finish animation (IX+3 = 0)
    LD      A, (IX+3)                      ; A = (IX+3): animation-done flag
    OR      A                              ; test if sprite still animating
    JP      NZ, LOC_8130                   ; if animating, continue tick
    LD      DE, $0004                      ; DE = $0004: advance to next sprite record
    ADD     IX, DE                         ; step IX to next record
    LD      A, (IX+0)                      ; A = (IX+0): record valid byte
    CP      $FF                            ; compare to $FF (end sentinel)
    JR      NZ, LOC_81B9                   ; if not end, check next record
    SUB     A                              ; A = 0: all animation done
    LD      ($705A), A                     ; ($705A) = 0: clear level-complete state
    CALL    SUB_BDC6                       ; level-complete special routine
    CALL    SUB_8C71                       ; reset player sprite pointer

LOC_81D6:                                  ; LOC_81D6: clear all pending sprite records
    SUB     A                              ; A = 0
    LD      (IX+3), A                      ; (IX+3) = 0: clear animation flag
    LD      A, $FF                         ; A = $FF
    CP      (IX+2)                         ; compare (IX+2) to $FF
    JR      Z, LOC_81E5                    ; if $FF skip reset
    LD      (IX+2), $00                    ; (IX+2) = $00: clear record

LOC_81E5:                                  ; advance to next record
    LD      DE, $0004                      ; DE = $0004
    ADD     IX, DE                         ; IX += 4
    LD      A, (IX+0)                      ; A = (IX+0)
    CP      $FF                            ; test for $FF end sentinel
    JR      NZ, LOC_81D6                   ; if not end, clear next record
    LD      HL, $705B                      ; HL = $705B: stage number
    DEC     (HL)                           ; decrement stage count
    LD      A, (HL)                        ; A = stage count
    OR      A                              ; test if zero
    JR      NZ, LOC_8213                   ; if stages remain, go to score display
    LD      HL, $705A                      ; HL = $705A
    LD      (HL), $D0                      ; ($705A) = $D0: game-over state
    LD      A, ($7053)                     ; A = ($7053): 2-player mode flag
    OR      A                              ; test 2P mode
    JR      NZ, LOC_823A                   ; if 1P, go to game-over attract

LOC_8204:                                  ; LOC_8204: game-over / attract mode entry
    LD      DE, $0168                      ; DE = $0168: VRAM offset for game-over screen
    LD      HL, $8373                      ; HL = $8373: game-over tile data
    CALL    DELAY_LOOP_83C3                ; render game-over screen, then wait for frame
    CALL    SUB_83E2                       ; wait for frame ($706E)
    JP      LOC_86D9                       ; go to attract/game-over loop

LOC_8213:                                  ; LOC_8213: save current player state back to buffer
    LD      DE, $702F                      ; DE = $702F: player 1 state dest
    LD      HL, $7055                      ; HL = $7055: current player vars source
    LD      BC, $000C                      ; BC = $000C: 12 bytes to copy
    LD      A, ($7054)                     ; A = ($7054): player flag
    OR      A                              ; test player
    JR      Z, LOC_8225                    ; if P1, dest = $702F
    LD      DE, $703B                      ; DE = $703B: player 2 state dest

LOC_8225:                                  ; LDIR: save 12 bytes of player state
    LDIR                                   ; A = ($7053): 2-player mode flag
    LD      A, ($7053)                     ; test 2P mode
    OR      A                              ; if 1P, jump back to stage display
    JP      Z, LOC_80ED                    ; A = ($7054): player flag
    LD      A, ($7054)                     ; increment player flag
    INC     A                              ; AND $01: toggle P1/P2
    AND     $01                            ; ($7054) = toggled player: switch active player
    LD      ($7054), A                     ; go to game state branch for new player
    JP      LOC_80D1

LOC_823A:
    LD      A, ($707B)                  ; RAM $707B
    OR      A
    JR      NZ, LOC_8204
    LD      A, ($7054)                  ; RAM $7054
    OR      A
    JR      NZ, LOC_824B
    LD      HL, $8385
    JR      LOC_824E

LOC_824B:
    LD      HL, $838E

LOC_824E:
    LD      DE, $018D
    CALL    SUB_83A6
    LD      DE, $014C
    LD      HL, $8373
    CALL    SUB_83F3
    CALL    SUB_83E2
    LD      A, $01
    LD      ($707B), A                  ; RAM $707B
    JP      LOC_8213

SUB_8268:                                  ; SUB_8268: get target burger-layer count for current level
    LD      A, ($7055)                     ; A = ($7055): current level
    LD      HL, $B943                      ; HL = $B943: level->burger-count table
    JP      SUB_8FF4                       ; JP SUB_8FF4: index table by A, return count
    DB      $00, $00, $00, $00, $00, $00, $05, $00
    DB      $00, $00, $01, $07, $03, $06, $05, $05
    DB      $07, $04

SUB_8283:                                  ; SUB_8283: init player state block from ROM tables (DE=dest)
    LD      HL, $8271                      ; HL = $8271: base 12-byte player-state table
    LD      BC, $000C                      ; BC = $000C: 12 bytes
    LDIR                                   ; LDIR: copy base state to DE
    LD      A, ($7075)                     ; A = ($7075): difficulty level
    CP      $01                            ; compare to $01 (easy)
    RET     Z                              ; if easy, return
    DEC     E                              ; DEC E: back up 2 bytes in dest
    DEC     E                              ; DEC E
    CP      $03                            ; CP $03: compare difficulty
    LD      BC, $0002                      ; BC = $0002: 2 bytes to overwrite
    LD      HL, $827D                      ; HL = $827D: medium difficulty table
    JR      C, LOC_82A5                    ; if diff < 3 use medium
    LD      HL, $827F                      ; HL = $827F: hard table
    JR      Z, LOC_82A5                    ; if diff=3 use hard
    LD      HL, $8281                      ; HL = $8281: very hard table

LOC_82A5:                                  ; LDIR: overwrite difficulty bytes
    LDIR                                   ; RET
    RET     

SUB_82A8:                                  ; SUB_82A8: load 12 player vars from saved state into $7055+
    LD      HL, $702F                      ; HL = $702F: player 1 state
    LD      A, ($7054)                     ; A = ($7054): player flag
    OR      A                              ; test player
    JR      Z, LOC_82B4                    ; if P1, HL = $702F
    LD      HL, $703B                      ; HL = $703B: player 2 state

LOC_82B4:                                  ; DE = $7055: dest (current player vars)
    LD      DE, $7055                      ; BC = $000C: 12 bytes
    LD      BC, $000C                      ; LDIR: copy saved state -> current vars
    LDIR                                   ; RET
    RET     

SUB_82BD:                                  ; SUB_82BD: write 1 byte to VRAM at HL (preserves BC/IX/DE)
    PUSH    DE                             ; save BC
    PUSH    IX                             ; save DE
    PUSH    BC                             ; save IX
    PUSH    AF                             ; save AF
    LD      DE, $0001                      ; DE = $0001: write 1 byte
    CALL    FILL_VRAM                      ; FILL_VRAM: A->VRAM[HL], count DE
    POP     AF                             ; restore AF
    POP     BC                             ; restore BC/IX/DE
    POP     IX                             ; RET
    POP     DE
    RET     

DELAY_LOOP_82CE:                           ; DELAY_LOOP_82CE: render game screen score tiles (calls SUB_8397 first)
    CALL    SUB_8397                       ; clear VRAM name table ($1800, $0300 bytes)
    LD      A, $D2                         ; A = $D2: level index into $B307 tile table
    LD      IX, $B307                      ; IX = $B307: score-digit tile base
    CALL    DELAY_LOOP_8807                ; DELAY_LOOP_8807: advance IX by $7055 * A offset
    LD      HL, $1842                      ; HL = $1842: VRAM dest for score row
    LD      C, $15                         ; C = $15: 21 score rows to render

LOC_82DF:                                  ; B = $0A: 10 tiles per row
    LD      B, $0A
                                           ; A = (IX+0): hi nibble tile index
LOC_82E1:                                  ; AND $F0: mask hi nibble
    LD      A, (IX+0)                      ; SUB_9071: RLCA x4 (nibble-swap -> lo nibble)
    AND     $F0                            ; write hi-nibble tile to VRAM[HL]
    CALL    SUB_9071                       ; advance VRAM dest
    CALL    SUB_82BD                       ; A = (IX+0): lo nibble
    INC     HL                             ; AND $0F: mask lo nibble
    LD      A, (IX+0)                      ; write lo-nibble tile to VRAM[HL]
    AND     $0F                            ; IX++: next tile byte
    CALL    SUB_82BD                       ; HL++: next VRAM dest
    INC     IX                             ; DJNZ: loop 10 tiles
    INC     HL                             ; DE = $000C: skip to next VRAM row
    DJNZ    LOC_82E1                       ; HL += $000C
    LD      DE, $000C                      ; C--: next row
    ADD     HL, DE                         ; loop 21 rows
    DEC     C                              ; DE = $0018
    JR      NZ, LOC_82DF                   ; HL = $8385: P1 score display
    LD      DE, $0018                      ; IY = $0008: stride
    LD      HL, $8385                      ; A = $02: PUT_VRAM mode
    LD      IY, $0008                      ; write score to VRAM
    LD      A, $02                         ; A = ($7053): 2P mode flag
    CALL    PUT_VRAM                       ; test 2P
    LD      A, ($7053)                     ; if 1P skip P2 score
    OR      A
    JR      Z, LOC_833C
    LD      DE, $00B8
    LD      HL, $838E
    LD      A, $02
    LD      IY, $0008
    CALL    PUT_VRAM
    LD      A, ($7054)                  ; RAM $7054
    OR      A
    LD      IX, $703C                   ; RAM $703C
    LD      HL, $18F7
    JR      Z, LOC_8339
    LD      IX, $7030                   ; RAM $7030
    LD      HL, $1857

LOC_8339:
    CALL    SUB_9A8E

LOC_833C:
    LD      A, $0E
    LD      IX, $B7F3
    CALL    DELAY_LOOP_8807

LOC_8345:
    LD      A, (IX+0)
    OR      A
    JR      NZ, LOC_834C
    RET     

LOC_834C:
    LD      C, (IX+1)
    CALL    DELAY_LOOP_8A5D
    LD      BC, $1800
    ADD     HL, BC
    LD      A, $10
    CALL    SUB_82BD
    INC     A
    INC     HL
    CALL    SUB_82BD
    INC     A
    INC     HL
    CALL    SUB_82BD
    INC     IX
    INC     IX
    JR      LOC_8345
    DB      $48, $49, $2D, $53, $43, $4F, $52, $45 ; "HI-SCORE"
    DB      $47, $41, $4D, $45, $20, $4F, $56, $45 ; "GAME OVE"
    DB      $52, $47, $45, $54, $20, $52, $45, $41 ; "RGET REA"
    DB      $44, $59, $20, $43, $48, $45, $46, $20 ; "DY CHEF "
    DB      $31, $20, $20, $20, $43, $48, $45, $46 ; "1   CHEF"
    DB      $20, $32, $20, $20          ; " 2  "

SUB_8397:                                  ; SUB_8397: clear VDP name table (VRAM $1800, $0300 bytes with $00)
    PUSH    DE                             ; save DE
    PUSH    HL                             ; save HL
    LD      HL, $1800                      ; HL = $1800: VRAM name table base
    LD      DE, $0300                      ; DE = $0300: $0300 bytes (entire name table)
    XOR     A                              ; A = $00: fill with blank tile
    CALL    FILL_VRAM                      ; BIOS: fill VRAM with A
    POP     HL                             ; restore HL
    POP     DE                             ; restore DE
    RET                                    ; RET

SUB_83A6:                                  ; SUB_83A6: NMI sync, clear name table, set state=$E0, enable VDP
    CALL    SUB_9053                       ; NMI sync + VDP disable
    CALL    SUB_8397                       ; clear VRAM name table ($1800)

LOC_83AC:                                  ; LOC_83AC: PUT_VRAM with IY=$0009 stride, A=$02 mode
    LD      IY, $0009                      ; IY = $0009: stride
    LD      A, $02                         ; A = $02: PUT_VRAM mode
    CALL    PUT_VRAM                       ; write tile data to VRAM
    CALL    SUB_905F                       ; VDP enable
    LD      A, $D0                         ; A = $D0
    LD      ($710C), A                     ; ($710C) = $D0: init display control byte
    LD      A, $E0                         ; A = $E0
    LD      ($705A), A                     ; ($705A) = $E0: set title/attract state
    RET                                    ; RET

DELAY_LOOP_83C3:                           ; DELAY_LOOP_83C3: render blank/title screen tiles then go to LOC_83AC
    PUSH    DE                             ; save DE
    PUSH    HL                             ; save HL
    CALL    SUB_9053                       ; NMI sync + VDP disable
    LD      HL, $1947                      ; HL = $1947: VRAM dest row
    LD      C, $03                         ; C = $03: 3 rows

LOC_83CD:                                  ; B = $0B: 11 tiles per row
    LD      B, $0B                         ; A = $00: blank tile
    LD      A, $00

LOC_83D1:                                  ; write blank tile to VRAM[HL]
    CALL    SUB_82BD                       ; HL++
    INC     HL                             ; DJNZ: loop 11
    DJNZ    LOC_83D1                       ; DE = $0015: row stride
    LD      DE, $0015                      ; HL += $0015
    ADD     HL, DE                         ; C--: next row
    DEC     C                              ; loop 3 rows
    JR      NZ, LOC_83CD                   ; restore HL/DE
    POP     HL
    POP     DE                             ; jump to SUB_83AC (PUT_VRAM + state=$E0)
    JR      LOC_83AC

SUB_83E2:                                  ; SUB_83E2: wait-for-frame (spin on $706E until zero, then reload $06)
    LD      A, $60                         ; A = ($706E): frame-rate timer
    LD      ($706E), A                     ; test timer
                                           ; RET NZ: not yet (still counting)
LOC_83E7:                                  ; B = $06: new frame period
    LD      A, ($706E)                     ; A = ($705C): completed burger count
    OR      A                              ; compare to $06
    JR      NZ, LOC_83E7                   ; if < 6 keep B=$06
    LD      A, $06                         ; DEC B: speed up (B=$05) if >= 6 burgers done
    LD      ($706E), A                     ; compare to $0C
    RET                                    ; if < 12 keep B=$05
                                           ; DEC B: further speedup (B=$04) if >= 12
SUB_83F3:                                  ; SUB_83F3: render string from HL to VRAM at DE offset (IY=stride)
    CALL    SUB_905F                       ; RET
    JR      LOC_83AC

DELAY_LOOP_83F8:                           ; DELAY_LOOP_83F8: load 3 VDP tile pages from IX=$B19F table
    LD      B, $03                         ; NMI sync + VDP disable
    LD      HL, $F800                      ; HL = $F800: VDP pattern table base
                                           ; B = $03: 3 tile pages to load
LOC_83FD:                                  ; IX = $B19F: per-page descriptor table
    PUSH    BC                             ; CALL DELAY_LOOP_8441: load one tile page (17 rows)
    LD      BC, $0800                      ; step IX to next page descriptor
    ADD     HL, BC                         ; DJNZ: loop 3 pages
    CALL    DELAY_LOOP_8441                ; init sprite name table after tile load
    POP     BC
    DJNZ    LOC_83FD
    LD      HL, $B1B0
    LD      IX, $B2C0
    LD      DE, $0010
    CALL    SUB_9009
    LD      B, $03
    LD      IY, $843E
    LD      HL, $F900

LOC_841E:
    LD      DE, $0800
    ADD     HL, DE
    LD      DE, $02D0
    LD      A, (IY+0)
    INC     IY
    PUSH    HL
    CALL    FILL_VRAM
    POP     HL
    DJNZ    LOC_841E
    LD      HL, $B1B0
    LD      IX, $B2C4
    LD      DE, $007A
    JP      SUB_9009
    DB      $81, $71, $B1

DELAY_LOOP_8441:                           ; DELAY_LOOP_8441: load 1 tile page (17 rows from $B19F descriptor)
    PUSH    HL                             ; HL = ??: VRAM pattern area start
    LD      B, $11                         ; B = $11: 17 rows per page
    LD      IX, $B19F                      ; save HL/BC/DE
    LD      E, $05                         ; A = (IX+0): row tile count
                                           ; LD DE = count
LOC_844A:                                  ; push row descriptor ptr
    PUSH    BC                             ; HL = tile source from IX+1/2
    LD      D, $00                         ; FILL_VRAM: write tile row to VRAM
    LD      A, $D1                         ; pop IX, advance HL to next VRAM row
    PUSH    DE                             ; DJNZ: loop 17 rows
    CALL    FILL_VRAM                      ; RET
    POP     DE
    ADD     HL, DE
    LD      DE, $0002
    INC     IX
    LD      A, (IX+0)
    CALL    FILL_VRAM
    INC     HL
    INC     HL
    LD      E, $06
    POP     BC
    DJNZ    LOC_844A
    POP     HL
    RET     

SUB_8469:                                  ; SUB_8469: load sprite pattern tables (3 banks: $AEF8, $AF90, $15A3)
    LD      DE, BOOT_UP                    ; HL = $AEF8: sprite bank 0 source
    LD      HL, $AEF8                      ; A = $03: 3 pattern blocks
    LD      A, $03                         ; IY = $004A: VRAM offset for bank 0
    LD      IY, $0013                      ; DE = $001A: row stride
    CALL    SUB_9030                       ; load bank 0 into VRAM
    LD      HL, $15A3                      ; HL = $AF90: sprite bank 1 source
    LD      A, $03                         ; A = $03: 3 blocks
    LD      IY, $005A                      ; IY = $005A: VRAM offset
    LD      DE, $0020                      ; DE = $0020: stride
    CALL    SUB_9030                       ; load bank 1 into VRAM
    LD      HL, $AF90                      ; HL = $AF90: sprite bank 2 source
    LD      A, $03                         ; A = $03: 3 blocks
    LD      IY, $0060                      ; IY = $0060: VRAM offset
    LD      DE, $007A                      ; DE = $007A: stride
    JP      SUB_9030                       ; JP SUB_9030: load bank 2 (tail call)

SUB_8496:                                  ; SUB_8496: look up tile index from $B307 table (C=row, A=col)
    CALL    SUB_9099                       ; SRL x3: A = A / 8 (col -> block)
    SUB     $02                            ; SUB $02: adjust offset
    LD      B, A                           ; B = tile-block row
    LD      A, C                           ; SRL x3: C = C / 8 (row -> block)
    CALL    SUB_9099                       ; SUB $02: adjust offset
    SUB     $02                            ; C = tile-block col
    LD      C, A                           ; A = B * 10: row * 10 (stride)
    LD      A, B                           ; B = A
    ADD     A, A                           ; A = A*2
    LD      B, A                           ; A = A*4
    ADD     A, A                           ; A = A*8
    ADD     A, A                           ; A += B (= B*10)
    ADD     A, B                           ; push tile offset
    PUSH    AF                             ; A = $D2: tile page index
    LD      A, $D2                         ; IX = $B307: tile table base
    LD      IX, $B307                      ; advance IX by $7055 * A (level offset)
    CALL    DELAY_LOOP_8807                ; pop offset A
    POP     AF                             ; E = A: tile offset
    LD      E, A                           ; D = $00
    LD      D, $00                         ; IX += DE: indexed into tile table
    ADD     IX, DE                         ; SRA C: test bit 0 of col (even/odd)
    SRA     C                              ; A = C
    LD      A, C                           ; E = A
    LD      E, A                           ; if bit 0 clear use hi nibble path
    JR      C, LOC_84C9                    ; IX += E: second offset
    ADD     IX, DE                         ; A = (IX+0): tile byte
    LD      A, (IX+0)                      ; SUB_9071: swap nibbles (RLCA x4)
    CALL    SUB_9071                       ; jump to AND $0F
    JR      LOC_84CE

LOC_84C9:                                  ; IX += E: odd col path
    ADD     IX, DE                         ; A = (IX+0)
    LD      A, (IX+0)
                                           ; AND $0F: extract lo nibble tile index
LOC_84CE:                                  ; RET
    AND     $0F
    RET     

SUB_84D1:                                  ; SUB_84D1: ingredient step: check Y/X bounds, advance X, get step type
    LD      A, ($706F)                     ; A = ($706F): player Y position
    CP      $18                            ; CP $18: compare to top boundary ($18)
    JP      C, LOC_8552                    ; if Y < $18 -> out of bounds (JP LOC_8552)
    CP      $A8                            ; CP $A8: compare to bottom boundary ($A8)
    JP      NC, LOC_8552                   ; if Y >= $A8 -> out of bounds
    LD      A, ($7070)                     ; A = ($7070): player X position
    CP      $00                            ; CP $00
    JP      C, LOC_8552                    ; if X < $00 -> out of bounds
    CP      $A4                            ; CP $A4: compare to right boundary ($A4)
    JP      NC, LOC_8552                   ; if X >= $A4 -> out of bounds
    LD      A, ($7070)                     ; A = ($7070): X position
    ADD     A, $10                         ; ADD A, $10: advance X by one tile ($10)
    LD      ($7070), A                     ; ($7070) = updated X
    SUB     A                              ; A = 0
    LD      ($7069), A                     ; ($7069) = 0: clear step flag
    LD      A, ($706F)                     ; A = ($706F): Y position
    CALL    SUB_855C                       ; SUB_855C: convert Y/X to tile col, look up tile in $B307 table
    CP      $01                            ; CP $01: step type 1 (edge of ingredient)
    JR      NZ, LOC_8514                   ; if step != 1, check other thresholds
    CALL    SUB_8563                       ; SUB_8563: check ingredient horizontal center
    CALL    SOUND_WRITE_8573               ; SOUND_WRITE_8573: check ingredient vertical center
    CALL    SUB_858B                       ; SUB_858B: check ingredient landing zone
    CALL    SUB_8596                       ; SUB_8596: check X alignment ($7070 AND $07 == $03)
    RET     Z                              ; RET Z: aligned at center
    RET     C                              ; RET C: above tile
    LD      A, $01                         ; A = $01: step flag = edge
    JP      LOC_8581                       ; JP LOC_8581: OR into $7069

LOC_8514:                                  ; LOC_8514: step type $06 check
    CP      $06                            ; CP $06
    JR      NZ, LOC_8524                   ; if not $06, check $0A
    CALL    SUB_8563                       ; SUB_8563: horizontal center check
    CALL    SOUND_WRITE_8573               ; SOUND_WRITE_8573: vertical center check
    CALL    SUB_8587                       ; SUB_8587: landing-zone half-check (C=$01)
    JP      SUB_858B                       ; JP SUB_858B: landing-zone full-check (C=$02)

LOC_8524:                                  ; LOC_8524: step type $0A check
    CP      $0A                            ; CP $0A
    JR      NZ, LOC_852E                   ; if not $0A, check $0D
    CALL    SUB_8587                       ; SUB_8587: landing half-check
    JP      SUB_858B                       ; JP SUB_858B: landing full-check

LOC_852E:                                  ; LOC_852E: step type $0D check
    CP      $0D                            ; CP $0D
    JR      NZ, LOC_8544                   ; if not $0D, check $02/$07
    CALL    SUB_8563                       ; SUB_8563: horizontal center check
    CALL    SOUND_WRITE_8573               ; SOUND_WRITE_8573: vertical center check
    CALL    SUB_8587                       ; SUB_8587: landing half-check
    CALL    SUB_8596                       ; SUB_8596: X-alignment check
    RET     NC                             ; RET NC: not aligned
    LD      A, $02                         ; A = $02: step flag = corner
    JP      LOC_8581                       ; JP LOC_8581: set in $7069

LOC_8544:                                  ; LOC_8544: step types $02 or $07 (ladder entry)
    CP      $02                            ; CP $02
    JR      Z, LOC_854C                    ; if $02, go to SUB_8563
    CP      $07                            ; CP $07
    JR      NZ, LOC_8552                   ; if not $07, out of bounds

LOC_854C:                                  ; LOC_854C: step $02 or $07
    CALL    SUB_8563                       ; SUB_8563: horizontal center check
    JP      SOUND_WRITE_8573               ; JP SOUND_WRITE_8573: vertical center check (tail call)

LOC_8552:                                  ; LOC_8552: out-of-bounds (any boundary fail)
    SUB     A                              ; A = 0
    LD      ($7069), A                     ; ($7069) = 0: clear step flag
    RET                                    ; RET

SUB_8557:                                  ; SUB_8557: compute Y+B position, then look up tile (-> SUB_855C)
    LD      HL, $706F                      ; HL = $706F: Y position
    LD      A, B                           ; A = B
    ADD     A, (HL)                        ; A += (HL): A = Y + B

SUB_855C:                                  ; SUB_855C: convert (A=Y, $7070=X) to tile, look up in $B307
    LD      C, A                           ; C = A: save Y
    LD      A, ($7070)                     ; A = ($7070): X
    JP      SUB_8496                       ; JP SUB_8496: index $B307 table (C=row, A=col)

SUB_8563:                                  ; SUB_8563: check horizontal center alignment ($7070 AND $07 == $0B)
    LD      B, $08                         ; B = $08
    CALL    SUB_8596                       ; SUB_8596: X-alignment check
    RET     NZ                             ; RET NZ: not on tile center column
    CALL    SUB_8557                       ; SUB_8557: look up tile at Y+B
    CP      $0B                            ; CP $0B: tile = horizontal exit?
    RET     Z                              ; RET Z: if $0B, on center
    LD      A, $04                         ; A = $04: step flag = horiz-center
    JR      LOC_8581                       ; JR LOC_8581

SOUND_WRITE_8573:                          ; SOUND_WRITE_8573: check vertical center ($7070 AND $07 == $0C)
    LD      B, $FF                         ; B = $FF
    CALL    SUB_8596                       ; SUB_8596: X-alignment
    RET     NZ                             ; RET NZ
    CALL    SUB_8557                       ; SUB_8557: look up tile at Y+B ($FF = -1)
    CP      $0C                            ; CP $0C: tile = vertical exit?
    RET     Z                              ; RET Z
    LD      A, $08                         ; A = $08: step flag = vert-center

LOC_8581:                                  ; LOC_8581: OR step flag into $7069
    LD      HL, $7069                      ; HL = $7069: step accumulator
    OR      (HL)                           ; OR (HL): combine with existing flags
    LD      (HL), A                        ; (HL) = combined step flags
    RET                                    ; RET

SUB_8587:                                  ; SUB_8587: set $7069 bit 0 if Y-aligned (C=$01)
    LD      C, $01                         ; C = $01
    JR      LOC_858D                       ; JR LOC_858D

SUB_858B:                                  ; SUB_858B: set $7069 bit 1 if Y-aligned (C=$02)
    LD      C, $02                         ; C = $02

LOC_858D:                                  ; LOC_858D: check $706F Y AND $07 == 0 (Y on tile row)
    LD      A, ($706F)                     ; A = ($706F): Y
    AND     $07                            ; AND $07: test row alignment
    RET     NZ                             ; RET NZ: not aligned
    LD      A, C                           ; A = C: alignment flag
    JR      LOC_8581                       ; JR LOC_8581: OR into $7069

SUB_8596:                                  ; SUB_8596: check $7070 X AND $07 == $03 (on tile col)
    LD      A, ($7070)                     ; A = ($7070): X
    AND     $07                            ; AND $07: column bits
    CP      $03                            ; CP $03: on tile center?
    RET                                    ; RET: Z if centered

SUB_859E:                                  ; SUB_859E: VDP/display init - clear bufs, init WRITER/TIMER, set regs, INIT_TABLE x5, VDP disable
    LD      A, $D0                         ; A = $D0: fill byte
    LD      B, $40                         ; B = $40: 64 bytes
    LD      HL, $710C                      ; HL = $710C: display control buffer
    CALL    DELAY_LOOP_906A                ; fill $710C buffer ($40 bytes) with $D0
    LD      A, $0A                         ; A = $0A: WRITER mode
    LD      HL, $70E1                      ; HL = $70E1: WRITER tile buffer base
    CALL    INIT_WRITER                    ; BIOS: init WRITER DMA engine
    LD      A, $10                         ; A = $10: sprite count
    CALL    INIT_SPR_NM_TBL                ; BIOS: init sprite name table (16 sprites)
    LD      BC, $0002                      ; BC = $0002: VDP reg 0, value 2
    CALL    WRITE_REGISTER                 ; set VDP register 0 = $02 (mode)
    LD      BC, $0700                      ; BC = $0700: VDP reg 7 = $00 (black border)
    CALL    WRITE_REGISTER                 ; set VDP register 7 = $00
    LD      A, $00                         ; A = $00: INIT_TABLE table #0
    LD      HL, $1C00                      ; HL = $1C00: VRAM colour table base
    CALL    INIT_TABLE                     ; BIOS: init colour table at $1C00
    LD      A, $01                         ; A = $01: table #1
    LD      HL, $3800                      ; HL = $3800: VRAM sprite-pattern table
    CALL    INIT_TABLE                     ; BIOS: init sprite pattern table at $3800
    LD      A, $02                         ; A = $02: table #2
    LD      HL, $1800                      ; HL = $1800: VRAM name table
    CALL    INIT_TABLE                     ; BIOS: init name table at $1800
    LD      A, $03                         ; A = $03: table #3
    LD      HL, $2000                      ; HL = $2000: VRAM pattern generator table
    CALL    INIT_TABLE                     ; BIOS: init pattern generator at $2000
    LD      A, $04                         ; A = $04: table #4
    LD      HL, BOOT_UP                    ; HL = BOOT_UP ($0000): sprite attribute table
    CALL    INIT_TABLE                     ; BIOS: init sprite attribute table at $0000
    LD      HL, $70FF                      ; HL = $70FF: timer channel base in RAM
    LD      DE, $7108                      ; DE = $7108: timer channel end
    CALL    INIT_TIMER                     ; BIOS: init timer channel at $70FF/$7108
    LD      BC, $01C2                      ; BC = $01C2: VDP reg 1, value $C2 (disable display)
    JP      WRITE_REGISTER                 ; JP WRITE_REGISTER: VDP disable (tail call)

NMI:                                       ; NMI: save all regs (both banks), manage game timers, RETN
    PUSH    AF                             ; save AF
    PUSH    BC                             ; save BC
    PUSH    DE                             ; save DE
    PUSH    HL                             ; save HL
    PUSH    IX                             ; save IX
    PUSH    IY                             ; save IY
    EX      AF, AF'                        ; EX AF,AF: switch to alternate AF
    EXX                                    ; EXX: switch to alternate BC/DE/HL
    PUSH    AF                             ; save alternate AF
    PUSH    BC                             ; save alternate BC
    PUSH    DE                             ; save alternate DE
    PUSH    HL                             ; save alternate HL
    LD      HL, $7066                      ; HL = $7066: NMI-occurred flag
    LD      (HL), $01                      ; ($7066) = $01: signal NMI occurred
    LD      A, ($7077)                     ; A = ($7077): previous scroll index
    LD      B, A                           ; B = prev index
    LD      A, ($7076)                     ; A = ($7076): current scroll index
    CP      B                              ; compare current vs previous scroll index
    JR      Z, LOC_8631                    ; if same, skip scroll ring update
    LD      IX, $B99A                      ; IX = $B99A: scroll ring table
    LD      A, ($7076)                     ; A = ($7076): current index
    LD      ($7077), A                     ; ($7077) = A: save as previous
    CALL    SUB_8823                       ; SUB_8823: advance IX by $7076 offset (scroll pointer)
    PUSH    IX                             ; HL = IX (scroll data pointer)
    POP     HL                             ; convert IX to HL
    LD      DE, BOOT_UP                    ; DE = BOOT_UP ($0000): VRAM base
    LD      IY, $0008                      ; IY = $0008: stride for PUT_VRAM
    LD      A, $01                         ; A = $01: PUT_VRAM mode
    CALL    PUT_VRAM                       ; PUT_VRAM: write scroll tile to VRAM

LOC_8631:                                  ; LOC_8631: BIOS service calls
    CALL    TIME_MGR                       ; BIOS: advance all timer channels
    CALL    SOUND_MAN                      ; BIOS: advance sound engine
    CALL    PLAY_SONGS                     ; BIOS: play active songs
    CALL    POLLER                         ; BIOS: poll controllers -> $7047
    LD      A, ($705A)                     ; A = ($705A): game state
    CP      $E0                            ; CP $E0: title/attract state?
    JR      Z, LOC_8692                    ; if title state, skip burger scroll update
    CALL    SUB_9A68                       ; SUB_9A68: shift enemy spawn ring buffer
    CALL    SUB_9B42                       ; SUB_9B42: update player walk animation frame
    LD      A, ($70AE)                     ; A = ($70AE): burger 0 base column
    LD      E, A                           ; E = base col
    LD      HL, ($70B1)                    ; HL = ($70B1): burger 0 scroll address in VRAM
    LD      A, L                           ; A = L
    OR      H                              ; OR H: test if burger 0 scroll active
    JR      Z, LOC_8692                    ; if zero, skip all burger scroll
    LD      A, ($705B)                     ; A = ($705B): stage number (selects animation table)
    DEC     A                              ; DEC A: index from 0
    LD      D, $B9                         ; D = $B9: hi byte of burger scroll table
    CALL    SUB_9CB7                       ; SUB_9CB7: scroll burger 0 one step
    LD      ($70B1), HL                    ; ($70B1) = updated burger 0 VRAM addr
    LD      A, E                           ; A = E
    LD      ($70AE), A                     ; ($70AE) = updated col
    LD      A, ($70AF)                     ; A = ($70AF): burger 1 base column
    LD      E, A                           ; E = base col
    LD      A, ($7060)                     ; A = ($7060): level iteration counter (selects anim table row)
    LD      HL, ($70B5)                    ; HL = ($70B5): burger 1 VRAM addr
    LD      D, $BA                         ; D = $BA
    CALL    SUB_9CB7                       ; SUB_9CB7: scroll burger 1 one step
    LD      ($70B5), HL                    ; ($70B5) = updated burger 1 VRAM addr
    LD      A, E                           ; A = E
    LD      ($70AF), A                     ; ($70AF) = updated col
    LD      A, ($70B0)                     ; A = ($70B0): burger 2 base column
    LD      E, A                           ; E = base col
    LD      A, ($705C)                     ; A = ($705C): completed burger count (selects table)
    INC     A                              ; INC A
    LD      HL, ($70B3)                    ; HL = ($70B3): burger 2 VRAM addr
    LD      D, $BB                         ; D = $BB: burger 2 scroll table hi byte
    CALL    SUB_9CB7                       ; SUB_9CB7: scroll burger 2 one step
    LD      ($70B3), HL                    ; ($70B3) = updated burger 2 VRAM addr
    LD      A, E                           ; A = E
    LD      ($70B0), A                     ; ($70B0) = updated col

LOC_8692:                                  ; LOC_8692: decrement $7080 (enemy tick gate, if non-zero)
    LD      A, ($7080)                     ; A = ($7080): enemy tick gate
    OR      A                              ; test gate
    JR      Z, LOC_869C                    ; if zero skip
    DEC     A                              ; DEC A
    LD      ($7080), A                     ; ($7080) = decremented gate

LOC_869C:                                  ; LOC_869C: decrement $7083 (bonus score timer)
    LD      A, ($7083)                     ; A = ($7083): bonus timer
    OR      A                              ; test timer
    JR      Z, LOC_86A6                    ; if zero skip
    DEC     A                              ; DEC A
    LD      ($7083), A                     ; ($7083) = decremented bonus timer

LOC_86A6:                                  ; LOC_86A6: decrement $706E (frame-rate timer)
    LD      A, ($706E)                     ; A = ($706E): frame timer
    OR      A                              ; test
    JR      Z, LOC_86B0                    ; if zero skip
    DEC     A                              ; DEC A
    LD      ($706E), A                     ; ($706E) = decremented frame timer

LOC_86B0:                                  ; LOC_86B0: decrement $707E (16-bit counter)
    LD      HL, ($707E)                    ; HL = ($707E): 16-bit counter
    LD      A, L                           ; A = L
    OR      H                              ; OR H: test if zero
    JR      Z, LOC_86BB                    ; if zero skip
    DEC     HL                             ; DEC HL
    LD      ($707E), HL                    ; ($707E) = decremented counter

LOC_86BB:                                  ; LOC_86BB: BIOS sprite/writer service calls
    LD      A, $10                         ; A = $10: sprite count
    CALL    WR_SPR_NM_TBL                  ; WR_SPR_NM_TBL: write sprite name table to VRAM
    CALL    WRITER                         ; WRITER: DMA-copy tile buffer to VRAM
    CALL    READ_REGISTER                  ; READ_REGISTER: read VDP status -> A
    LD      ($73C5), A                     ; ($73C5) = VDP status byte
    POP     HL                             ; restore alternate HL
    POP     DE                             ; restore alternate DE
    POP     BC                             ; restore alternate BC
    POP     AF                             ; restore alternate AF
    EX      AF, AF'                        ; EX AF,AF: back to main AF
    EXX                                    ; EXX: back to main BC/DE/HL
    POP     IY                             ; restore IY
    POP     IX                             ; restore IX
    POP     HL                             ; restore HL
    POP     DE                             ; restore DE
    POP     BC                             ; restore BC
    POP     AF                             ; restore AF
    RETN                                   ; RETN: return from NMI, re-enable interrupts

LOC_86D9:                                  ; LOC_86D9: game-over / attract mode loop
    CALL    SUB_8735                       ; SUB_8735: init attract mode (joy=$90, clear $7049)
    LD      HL, BOOT_UP                    ; HL = count
                                           ; countdown loop
LOC_86DF:                                  ; LD A,L / OR H: test countdown
    DEC     HL                             ; if expired go to next phase
    LD      A, L                           ; CALL POLLER: poll controller input
    OR      H                              ; check if start pressed
    JP      NZ, LOC_86EE                   ; if not pressed, continue countdown
    CALL    SUB_9053                       ; if pressed, handle start
    CALL    SUB_8397
    CALL    SUB_905F

LOC_86EE:
    CALL    POLLER
    CALL    SUB_8789
    JR      NZ, LOC_86FB
    CALL    SUB_878F
    JR      Z, LOC_86DF

LOC_86FB:
    CP      $0A
    JR      NZ, LOC_8725
    CALL    SUB_9053
    LD      A, ($7053)                  ; RAM $7053
    LD      B, A
    LD      A, ($7075)                  ; RAM $7075
    PUSH    BC
    LD      HL, WORK_BUFFER             ; WORK_BUFFER
    LD      E, L
    LD      D, H
    INC     DE
    LD      BC, $0300
    LD      (HL), $00
    LDIR    
    POP     BC
    LD      ($7075), A                  ; RAM $7075
    LD      A, B
    LD      ($7053), A                  ; RAM $7053
    CALL    SUB_905F
    JP      LOC_8076

LOC_8725:                                  ; LOC_8725: max stage loops ($0B) reached -> restart from BOOT_UP
    CP      $0B                            ; CP $0B
    JR      NZ, LOC_86D9                   ; if not $0B, continue attract
    LD      HL, $B3BB                      ; HL = $B3BB: game-over/title tile data
    LD      DE, BOOT_UP                    ; DE = BOOT_UP
    CALL    SUB_83A6                       ; SUB_83A6: clear screen + set state=$E0
    JP      START                          ; JP START: full game restart

SUB_8735:                                  ; SUB_8735: attract mode init (clear joy, zero $7049+$0A bytes)
    PUSH    HL                             ; save HL
    LD      A, $90                         ; A = $90
    LD      (JOYSTICK_BUFFER), A           ; (JOYSTICK_BUFFER) = $90: reset joy
    LD      ($7048), A                     ; ($7048) = $90
    LD      HL, $7049                      ; HL = $7049: sprite index table
    LD      B, $0A                         ; B = $0A: 10 bytes to clear
    SUB     A                              ; A = 0
    CALL    DELAY_LOOP_906A                ; fill $0A bytes with 0 (clear sprite table)
    CALL    SUB_8795                       ; SUB_8795: additional attract init
    LD      (HL), $0F                      ; (HL) = $0F: write terminator at HL
    CALL    SUB_879A                       ; SUB_879A: secondary attract init
    LD      (HL), $0F                      ; (HL) = $0F
    POP     HL                             ; restore HL
    RET                                    ; RET

SOUND_WRITE_8753:                          ; SOUND_WRITE_8753: title/attract wait loop (FFFF countdown, POLLER, check start)
    CALL    SUB_8735                       ; SUB_8735: attract mode init
    LD      HL, $FFFF                      ; HL = $FFFF: countdown start

LOC_8759:                                  ; LOC_8759: main countdown loop
    DEC     HL                             ; DEC HL
    LD      A, L                           ; A = L
    OR      H                              ; OR H
    JR      Z, LOC_87A5                    ; if expired, go to title display
    CALL    POLLER                         ; CALL POLLER: poll controllers
    CALL    SUB_8789                       ; check button state
    JR      NZ, LOC_876B                   ; if button pressed, check which
    CALL    SUB_878F                       ; secondary input check
    JR      Z, LOC_8759                    ; if nothing, continue countdown

LOC_876B:                                  ; LOC_876B: button detected
    OR      A                              ; OR A: test result
    JR      Z, SOUND_WRITE_8753            ; if zero restart attract
    CP      $09                            ; CP $09: valid button range?
    JR      NC, SOUND_WRITE_8753           ; if >= 9 restart attract
    LD      HL, $7053                      ; HL = $7053: 2P mode flag
    LD      (HL), $00                      ; ($7053) = $00: default 1P
    DEC     A                              ; DEC A: adjust button code
    BIT     2, A                           ; BIT 2, A: test for 2P selection
    JR      Z, LOC_877D                    ; if bit 2 clear, stay 1P
    INC     (HL)                           ; INC (HL): set 2P mode

LOC_877D:                                  ; LOC_877D: save player count and start game
    INC     A                              ; INC A
    AND     $F3                            ; AND $F3: keep lives/option bits
    JR      NZ, LOC_8784                   ; if zero, use default
    LD      A, $04                         ; A = $04: default lives

LOC_8784:
    LD      HL, $7075                   ; RAM $7075
    LD      (HL), A
    RET     

SUB_8789:
    PUSH    HL
    CALL    SUB_8795
    POP     HL
    RET     

SUB_878F:
    PUSH    HL
    CALL    SUB_879A
    POP     HL
    RET     

SUB_8795:
    LD      DE, $0006
    JR      LOC_879D

SUB_879A:
    LD      DE, $000B

LOC_879D:
    LD      HL, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER
    ADD     HL, DE
    LD      A, (HL)
    CP      $0F
    RET     

LOC_87A5:
    CALL    SUB_8397

LOC_87A8:
    CALL    POLLER
    CALL    SUB_8795
    JP      NZ, START
    CALL    SUB_879A
    JR      Z, LOC_87A8
    JP      START

SUB_87B9:                                  ; SUB_87B9: copy active player sprite indices from $7049/$704E -> $7061-$7065
    LD      HL, $7049                      ; HL = $7049: player 1 sprite index table
    LD      A, ($7054)                     ; A = ($7054): player flag
    OR      A                              ; test flag
    JR      Z, LOC_87C5                    ; if P1, HL = $7049
    LD      HL, $704E                      ; HL = $704E: player 2 sprite index table

LOC_87C5:                                  ; LOC_87C5: common copy
    LD      BC, $0005                      ; BC = $0005: 5 bytes
    LD      DE, $7061                      ; DE = $7061: destination (sprite index buffer)
    LDIR                                   ; LDIR: copy 5 sprite indices
    RET                                    ; RET
    DB      $7A, $7B, $7C, $7D, $7B, $7F, $7A, $7E
    DB      $7C, $83, $84, $85, $86, $84, $88, $83
    DB      $87, $85, $8C, $8D, $8E, $8F, $8D, $91
    DB      $8C, $90, $8E, $95, $96, $97, $98, $96
    DB      $9A, $95, $99, $97, $9E, $9F, $A0, $A1
    DB      $9F, $A3, $9E, $A2, $A0, $A7, $A8, $A9
    DB      $AA, $A8, $AC, $A7, $AB, $A9, $B0, $B1
    DB      $B2

DELAY_LOOP_8807:                           ; DELAY_LOOP_8807: advance IX by ($7055 * A) (level-indexed table lookup)
    PUSH    HL                             ; save HL
    PUSH    AF                             ; save AF (A = base offset)
    LD      A, ($7055)                     ; A = ($7055): current level (0-5)

LOC_880C:                                  ; LOC_880C: test level index
    OR      A                              ; OR A: test if zero (level 0)
    JR      Z, LOC_8820                    ; if zero return with IX unchanged
    LD      B, A                           ; B = level count
    POP     AF                             ; pop AF (base offset back to A)
    LD      E, A                           ; E = A: offset as 16-bit
    LD      D, $00                         ; D = $00
    LD      HL, BOOT_UP                    ; HL = BOOT_UP ($0000)

LOC_8817:                                  ; LOC_8817: HL += DE (B times)
    ADD     HL, DE                         ; HL += E (accumulate level*offset)
    DJNZ    LOC_8817                       ; DJNZ: loop for each level
    PUSH    HL                             ; IX += HL: advance IX by level-indexed amount
    POP     DE                             ; HL -> DE for ADD IX
    ADD     IX, DE                         ; ADD IX,DE
    POP     HL                             ; restore HL
    RET                                    ; RET

LOC_8820:                                  ; LOC_8820: level=0 path (no advance)
    POP     AF                             ; pop AF
    POP     HL                             ; restore HL
    RET                                    ; RET

SUB_8823:                                  ; SUB_8823: advance IX by ($7076 * $40) (scroll ring lookup)
    PUSH    HL                             ; save HL
    LD      A, $40                         ; A = $40: stride per scroll ring entry
    PUSH    AF                             ; push A
    LD      A, ($7076)                     ; A = ($7076): scroll ring index
    JR      LOC_880C                       ; JR LOC_880C: use DELAY_LOOP_8807 loop

SUB_882C:
    LD      A, ($715F)                  ; RAM $715F
    AND     $F8
    ADD     A, $03
    RET     

SUB_8834:
    LD      A, ($715D)                  ; RAM $715D
    AND     $F8
    ADD     A, $04
    RET     

SUB_883C:                                  ; SUB_883C: player movement (reads $706E, updates $706F/$7070 Y/X)
    LD      A, ($706E)                     ; A = ($706E): frame-rate timer
    OR      A                              ; test timer
    RET     NZ                             ; RET NZ: skip movement if timer still counting
    LD      B, $05                         ; B = $05: default speed
    LD      A, ($705C)                     ; A = ($705C): completed burger count
    CP      $06                            ; CP $06
    JR      C, LOC_8850                    ; if < 6, keep B=$05
    DEC     B                              ; DEC B: speed B=$04 if 6+ burgers done
    CP      $0C                            ; CP $0C
    JR      C, LOC_8850
    DEC     B

LOC_8850:
    LD      A, B
    LD      ($706E), A                  ; RAM $706E
    LD      A, ($705A)                  ; RAM $705A
    CP      $F0
    RET     Z
    LD      A, ($7062)                  ; RAM $7062
    OR      A
    JR      Z, LOC_88BD
    LD      HL, $706A                   ; RAM $706A
    LD      (HL), $04
    BIT     1, A
    JR      NZ, LOC_8879
    LD      (HL), $08
    BIT     3, A
    JR      NZ, LOC_8879
    LD      (HL), $02
    BIT     2, A
    JR      NZ, LOC_8879
    LD      (HL), $01
    BIT     0, A

LOC_8879:
    LD      A, ($715D)                  ; RAM $715D
    AND     $07
    CP      $06
    JR      NC, LOC_888B
    CP      $03
    JR      C, LOC_888B
    CALL    SUB_8834
    JR      LOC_888E

LOC_888B:
    LD      A, ($715D)                  ; RAM $715D

LOC_888E:
    ADD     A, $04
    LD      ($706F), A                  ; RAM $706F
    LD      A, ($715F)                  ; RAM $715F
    AND     $07
    CP      $05
    JR      NC, LOC_88A5
    CP      $02
    JR      C, LOC_88A5
    CALL    SUB_882C
    JR      LOC_88A8

LOC_88A5:
    LD      A, ($715F)                  ; RAM $715F

LOC_88A8:
    LD      ($7070), A                  ; RAM $7070
    CALL    SUB_84D1
    LD      HL, $7069                   ; RAM $7069
    LD      A, ($706A)                  ; RAM $706A
    AND     (HL)
    JR      NZ, LOC_88CC
    LD      A, ($706B)                  ; RAM $706B
    AND     (HL)
    JR      NZ, LOC_88C9

LOC_88BD:
    LD      A, $0A
    LD      ($7076), A                  ; RAM $7076
    LD      IX, $B96B
    JP      PUTOBJ

LOC_88C9:
    LD      ($706A), A                  ; RAM $706A

LOC_88CC:
    LD      ($706B), A                  ; RAM $706B
    LD      BC, $0602
    LD      HL, $715F                   ; RAM $715F
    CP      $02
    JR      Z, LOC_88DE
    LD      BC, $04FE
    JR      NC, LOC_88F2

LOC_88DE:
    PUSH    AF
    CALL    SUB_8834
    LD      ($715D), A                  ; RAM $715D
    POP     AF
    LD      A, ($7076)                  ; RAM $7076
    INC     A
    AND     $01
    ADD     A, B
    LD      ($7076), A                  ; RAM $7076
    JR      LOC_8910

LOC_88F2:
    CALL    SUB_882C
    LD      ($715F), A                  ; RAM $715F
    LD      HL, $715D                   ; RAM $715D
    LD      A, ($706A)                  ; RAM $706A
    CP      $04
    CALL    SUB_8964
    LD      C, $02
    JR      Z, LOC_890C
    CALL    SUB_8953
    LD      C, $FE

LOC_890C:
    LD      A, B
    LD      ($7076), A                  ; RAM $7076

LOC_8910:
    LD      A, C
    ADD     A, (HL)
    LD      (HL), A
    LD      IX, $B96B
    CALL    PUTOBJ
    LD      A, ($715D)                  ; RAM $715D
    AND     $07
    JR      Z, LOC_8924
    CP      $04
    RET     NZ

LOC_8924:
    LD      A, $08
    LD      C, $03
    CALL    SOUND_WRITE_8989
    LD      A, ($706D)                  ; RAM $706D
    LD      B, A
    LD      A, ($706A)                  ; RAM $706A
    CP      B
    JR      NZ, LOC_8946
    CP      $04
    LD      A, $06
    JR      Z, LOC_8941
    LD      A, $08
    JR      C, LOC_8941
    LD      A, $0C

LOC_8941:
    LD      C, $06
    CALL    SOUND_WRITE_8989

LOC_8946:
    LD      A, ($706C)                  ; RAM $706C
    LD      ($706D), A                  ; RAM $706D
    LD      A, ($706A)                  ; RAM $706A
    LD      ($706C), A                  ; RAM $706C
    RET     

SUB_8953:
    PUSH    HL
    LD      HL, $8960
    LD      IX, $7078                   ; RAM $7078
    CALL    SUB_8975
    POP     HL
    RET     
    DB      $02, $03, $08, $03

SUB_8964:
    PUSH    HL
    LD      HL, $8971
    LD      IX, $7079                   ; RAM $7079
    CALL    SUB_8975
    POP     HL
    RET     
    DB      $00, $01, $09, $01

SUB_8975:
    PUSH    AF
    LD      E, (IX+0)
    LD      D, $00
    ADD     HL, DE
    LD      A, (HL)
    LD      B, A
    INC     A
    CP      $04
    JR      C, LOC_8984
    SUB     A

LOC_8984:
    LD      (IX+0), A
    POP     AF
    RET     

SOUND_WRITE_8989:
    PUSH    BC
    LD      HL, $715D                   ; RAM $715D
    ADD     A, (HL)
    LD      C, A
    LD      A, ($715F)                  ; RAM $715F
    CALL    SUB_9099
    INC     A
    INC     A
    LD      B, A
    CALL    SOUND_WRITE_8A1B
    LD      A, E
    CP      $FF
    JR      Z, LOC_8A19
    LD      A, (IX+2)
    CP      $77
    JR      NC, LOC_8A18
    POP     BC
    PUSH    BC
    LD      A, C
    CP      $03
    JR      Z, LOC_89B3
    LD      A, E
    CALL    SUB_9071
    LD      E, A

LOC_89B3:
    PUSH    DE
    CALL    SUB_8E21
    POP     DE
    PUSH    AF
    LD      A, (IX+2)
    AND     E
    JR      NZ, LOC_8A18
    LD      A, (IX+2)
    OR      E
    LD      (IX+2), A
    CP      $57
    JR      Z, LOC_89CE
    CP      $70
    JR      C, LOC_89D6

LOC_89CE:
    LD      (IX+3), $FF
    LD      (IX+2), $77

LOC_89D6:
    LD      A, E
    CP      $10
    JR      C, LOC_89DE
    CALL    SUB_9071

LOC_89DE:
    CP      $02
    LD      E, $00
    JR      C, LOC_89F0
    LD      E, $01
    JR      Z, LOC_89F0
    CP      $08
    LD      E, $02
    JR      C, LOC_89F0
    LD      E, $03

LOC_89F0:
    POP     AF
    ADD     A, E
    POP     BC
    ADD     A, C
    PUSH    AF
    CALL    SUB_8DAB
    LD      L, A
    LD      H, $00
    LD      B, $05

LOC_89FD:
    ADD     HL, HL
    DJNZ    LOC_89FD
    CALL    SUB_8D98
    ADD     A, E
    CALL    SUB_8FF4
    LD      DE, $1800
    ADD     HL, DE
    CALL    SUB_9053
    POP     AF
    CALL    SUB_82BD
    CALL    SUB_905F
    JP      LOC_9D07

LOC_8A18:
    POP     AF

LOC_8A19:
    POP     BC
    RET     

SOUND_WRITE_8A1B:
    CALL    SUB_8C71

LOC_8A1E:
    LD      A, (IX+0)
    CP      $FF
    LD      E, $FF
    RET     Z
    CALL    SUB_8DAB
    CP      B
    JR      Z, LOC_8A33

LOC_8A2C:
    LD      DE, $0004
    ADD     IX, DE
    JR      LOC_8A1E

LOC_8A33:
    PUSH    BC
    LD      A, C
    PUSH    AF
    CALL    SUB_8D98
    CALL    DELAY_LOOP_8A69
    LD      C, A
    POP     AF
    CP      C
    JR      C, LOC_8A55
    SUB     $08
    LD      E, $01
    CP      C
    JR      C, LOC_8A58
    INC     E
    SUB     $08
    CP      C
    JR      C, LOC_8A58
    INC     E
    INC     E
    SUB     $08
    CP      C
    JR      C, LOC_8A58

LOC_8A55:
    POP     BC
    JR      LOC_8A2C

LOC_8A58:
    POP     BC
    PUSH    IX
    POP     HL
    RET     

DELAY_LOOP_8A5D:
    PUSH    AF
    LD      L, A
    LD      H, $00
    LD      B, $05

LOC_8A63:
    ADD     HL, HL
    DJNZ    LOC_8A63
    ADD     HL, BC
    POP     AF
    RET     

DELAY_LOOP_8A69:
    PUSH    BC
    LD      B, $03

LOC_8A6C:
    ADD     A, A
    DJNZ    LOC_8A6C
    POP     BC
    RET     

SUB_8A71:                                  ; SUB_8A71: player walk and pepper action (IX from $7067)
    LD      IX, ($7067)                    ; IX = ($7067): player sprite record pointer

LOC_8A75:                                  ; LOC_8A75: main pepper/walk loop
    PUSH    IX                             ; save IX
    LD      A, (IX+3)                      ; A = (IX+3): sprite animation state
    OR      A                              ; test state
    JP      Z, LOC_8C55                    ; if zero -> sprite finished, check next
    JP      P, LOC_8A8D                    ; JP P: if positive (1-127) -> walk/move branch
    INC     (IX+3)                         ; INC (IX+3): increment negative state (pepper countdown)
    CALL    SUB_9053                       ; NMI sync + VDP disable
    CALL    DELAY_LOOP_8D1F                ; delay frame (DELAY_LOOP_8D1F)
    JP      LOC_8B61                       ; JP LOC_8B61: continue

LOC_8A8D:                                  ; LOC_8A8D: walk branch
    LD      A, (IX+3)                      ; A = (IX+3): animation state
    CP      $02                            ; CP $02
    JR      Z, LOC_8A9F                    ; if state=2 use $10 threshold
    LD      B, $20                         ; B = $20: threshold for state > 2
    CALL    SUB_8E07                       ; SUB_8E07: check pepper proximity (B=threshold)
    JR      C, LOC_8AB5                    ; if C (within range), handle pepper hit
    CP      $03                            ; CP $03
    JR      Z, LOC_8AAA                    ; if state=3 use SUB_8AAA

LOC_8A9F:                                  ; LOC_8A9F: state=2 or other
    LD      B, $10                         ; B = $10
    CALL    SUB_8E07                       ; SUB_8E07: pepper proximity check
    CALL    SUB_9053                       ; NMI sync + VDP disable
    JP      LOC_8B61                       ; JP LOC_8B61

LOC_8AAA:
    CALL    SUB_8C7F
    JR      Z, LOC_8AB5
    CALL    SUB_9053
    JP      LOC_8B61

LOC_8AB5:
    LD      C, $08
    CALL    SUB_8E13
    CALL    SUB_9053
    CALL    DELAY_LOOP_8D1F
    CALL    SUB_8D98
    LD      C, A
    CALL    SUB_8DAB
    ADD     A, $01
    CALL    SUB_8DDC
    CALL    DELAY_LOOP_8A5D
    DB      $EB
    LD      A, $02
    LD      IY, $0001
    LD      HL, $7071                   ; RAM $7071
    PUSH    IX
    CALL    GET_VRAM
    POP     IX
    LD      A, ($7071)                  ; RAM $7071
    OR      A
    JP      Z, LOC_8BFB
    CP      $0F
    JP      Z, LOC_8BFB
    CP      $0B
    JP      Z, LOC_8BFB
    CP      $10
    JR      C, LOC_8B61
    JR      Z, LOC_8B50
    PUSH    IX
    CALL    SUB_8D98
    LD      ($706F), A                  ; RAM $706F
    CALL    SUB_8DAB
    LD      ($7070), A                  ; RAM $7070
    CALL    SUB_8E1A
    LD      C, A
    CALL    SUB_8C71

LOC_8B0C:
    CALL    SUB_8D98
    LD      B, A
    LD      A, ($706F)                  ; RAM $706F
    CP      B
    JR      NZ, LOC_8B26
    CALL    SUB_8DAB
    LD      B, A
    LD      A, ($7070)                  ; RAM $7070
    CP      B
    JR      NZ, LOC_8B26
    CALL    SUB_8E1A
    CP      C
    JR      NZ, LOC_8B37

LOC_8B26:
    LD      DE, $0004
    ADD     IX, DE
    LD      A, (IX+0)
    CP      $FF
    JR      NZ, LOC_8B0C
    CALL    SUB_8C71
    JR      LOC_8B0C

LOC_8B37:
    LD      A, (IX+2)
    CP      $FF
    JR      Z, LOC_8B4E
    CP      $F0
    JR      NC, LOC_8B46
    LD      (IX+2), $77

LOC_8B46:
    LD      (IX+3), $01
    POP     IX
    JR      LOC_8B54

LOC_8B4E:
    POP     IX

LOC_8B50:
    LD      (IX+2), $FF

LOC_8B54:
    CALL    SUB_8DAB
    SUB     $01
    CALL    SUB_8DDC
    LD      C, $F8
    CALL    SUB_8E13

LOC_8B61:
    LD      A, (IX+3)
    INC     A
    AND     $03
    LD      (IX+3), A
    JR      Z, LOC_8B6F
    JP      LOC_8BFB

LOC_8B6F:
    CALL    SUB_8DF8
    CP      $05
    JR      NZ, LOC_8B93
    LD      A, (IX+2)
    CP      $FF
    JR      NZ, LOC_8B93
    LD      B, $40
    CALL    SUB_8E07
    CALL    DELAY_LOOP_8D1F
    CALL    SUB_8DAB
    INC     A
    CALL    SUB_8DDC
    LD      C, $08
    CALL    SUB_8E13
    JR      LOC_8B98

LOC_8B93:
    LD      B, $00
    CALL    SUB_8E07

LOC_8B98:
    LD      C, $FF
    CALL    SUB_8E13
    LD      A, E
    OR      A
    JR      Z, LOC_8BD6
    LD      A, (IX+2)
    CP      $FF
    JR      Z, LOC_8BD6
    CP      $77
    JR      NZ, LOC_8BC6
    LD      A, E
    CP      $04
    LD      E, $F9
    JR      Z, LOC_8BC3
    LD      E, $F9
    JR      NC, LOC_8BC3
    CP      $02
    LD      E, $F3
    JR      C, LOC_8BC3
    LD      E, $F5
    JR      Z, LOC_8BC3
    LD      E, $F7

LOC_8BC3:
    LD      (IX+2), E

LOC_8BC6:
    LD      (IX+3), $FF
    DEC     (IX+2)
    LD      A, (IX+2)
    AND     $0F
    JR      Z, LOC_8BD6
    JR      LOC_8BF0

LOC_8BD6:
    LD      C, $00
    CALL    SUB_8E13
    SUB     A
    LD      (IX+3), A
    LD      A, (IX+2)
    CP      $FF
    JR      NZ, LOC_8BEC
    LD      HL, $705D                   ; RAM $705D
    INC     (HL)
    JR      LOC_8BF0

LOC_8BEC:
    LD      (IX+2), $00

LOC_8BF0:
    LD      B, $00
    LD      C, $50
    CALL    SUB_93A2
    JR      LOC_8BFB
    DB      $DD, $E1

LOC_8BFB:                                  ; LOC_8BFB: game/sound state init at level start (set $710C, $705A=$D0)
    CALL    SUB_8C96
    CP      $0F
    JR      NZ, LOC_8C0B
    CALL    SUB_8DF8
    CP      $00
    JR      Z, LOC_8C39
    JR      LOC_8C10

LOC_8C0B:
    CALL    SUB_8C7F
    JR      Z, LOC_8C39

LOC_8C10:
    LD      A, (IX+2)
    CP      $FF
    JR      NZ, LOC_8C39
    CALL    SUB_8DAB
    INC     A
    CALL    SUB_8DDC
    LD      B, (IX+0)

LOC_8C21:
    LD      DE, $0004
    ADD     IX, DE
    LD      A, (IX+0)
    CP      $FF
    JR      NZ, LOC_8C32
    CALL    SUB_8C71
    JR      LOC_8C21

LOC_8C32:
    CP      B
    JR      NZ, LOC_8C21
    LD      (IX+0), $17

LOC_8C39:
    CALL    DELAY_LOOP_8CFC
    CALL    SUB_905F
    LD      DE, $0004
    ADD     IX, DE
    LD      A, (IX+0)
    CP      $FF
    JR      NZ, LOC_8C4E
    CALL    SUB_8C71

LOC_8C4E:
    LD      ($7067), IX                 ; RAM $7067
    POP     IX
    RET     

LOC_8C55:
    POP     IX
    LD      DE, $0004
    ADD     IX, DE
    LD      A, (IX+0)
    CP      $FF
    JR      NZ, LOC_8C66
    CALL    SUB_8C71

LOC_8C66:
    PUSH    IX
    POP     HL
    LD      A, ($7067)                  ; RAM $7067
    CP      L
    JP      NZ, LOC_8A75
    RET     

SUB_8C71:                                  ; SUB_8C71: set IX = player sprite record ($71DA for P1, $725B for P2)
    LD      IX, $71DA                      ; IX = $71DA: player 1 sprite record
    LD      A, ($7054)                     ; A = ($7054): player flag
    OR      A                              ; OR A: test P1/P2
    RET     Z                              ; RET Z: P1 - IX stays $71DA
    LD      IX, $725B                      ; IX = $725B: player 2 sprite record
    RET                                    ; RET

SUB_8C7F:
    CALL    SUB_8DAB
    CP      $17
    JR      NC, LOC_8C94
    CALL    SUB_8C96
    OR      A
    RET     Z
    CP      $0F
    JR      NZ, LOC_8C91
    SUB     A
    RET     

LOC_8C91:
    CP      $0B
    RET     

LOC_8C94:
    SUB     A
    RET     

SUB_8C96:
    CALL    SUB_8D98
    CALL    DELAY_LOOP_8A69
    LD      C, A
    CALL    SUB_8DAB
    CALL    DELAY_LOOP_8A69
    PUSH    IX
    CALL    SUB_8496
    POP     IX
    RET     

SOUND_WRITE_8CAB:                          ; SOUND_WRITE_8CAB: load sound channel map from $B853 (SUB_8C71 selects table)
    LD      A, $28                         ; A = $28: $28-byte stride for DELAY_LOOP_8807
    LD      IX, $B853                      ; IX = $B853: sound channel table base
    CALL    DELAY_LOOP_8807                ; DELAY_LOOP_8807: advance IX by level offset ($7055 * $28)
    PUSH    IX                             ; save IX (base for this level)
    POP     HL                             ; convert IX to HL
    CALL    SUB_8C71                       ; SUB_8C71: update IX -> player sprite record
    PUSH    IX                             ; save player record IX
    SUB     A                              ; A = 0
    LD      B, $81                         ; B = $81: 129 bytes to clear

LOC_8CBF:                                  ; LOC_8CBF: clear player record buffer
    LD      (IX+0), A                      ; (IX+0) = 0
    INC     IX                             ; IX++
    DJNZ    LOC_8CBF                       ; DJNZ: clear $81 bytes
    POP     IX                             ; restore base IX
    LD      C, $00                         ; C = $00: channel index

LOC_8CCA:                                  ; LOC_8CCA: scan channel table until 6 $FF bytes
    LD      A, (HL)                        ; A = (HL): channel byte
    CP      $FF                            ; CP $FF: terminator?
    JR      NZ, LOC_8CDB                   ; if not $FF, store in record
    INC     C                              ; INC C: count $FF bytes
    INC     HL                             ; INC HL
    LD      A, C                           ; A = C
    CP      $06                            ; CP $06: check for 6 terminators
    JR      NZ, LOC_8CCA                   ; if < 6, continue scanning
    LD      (IX+0), $FF                    ; (IX+0) = $FF: write final terminator
    RET                                    ; RET

LOC_8CDB:                                  ; LOC_8CDB: store channel byte into record
    LD      (IX+0), A                      ; (IX+0) = A: sound channel code
    INC     HL                             ; INC HL: advance source
    LD      (IX+1), C                      ; (IX+1) = C: channel index
    LD      DE, $0004                      ; DE = $0004: stride to next slot
    ADD     IX, DE                         ; IX += $0004: advance to next record slot
    JR      LOC_8CCA                       ; JR LOC_8CCA: continue scan

SOUND_WRITE_8CE9:                          ; SOUND_WRITE_8CE9: play sound channel sequence from IX record (SUB_8C71 selects)
    CALL    SUB_8C71                       ; SUB_8C71: set IX = player sprite record

LOC_8CEC:                                  ; LOC_8CEC: iterate channel records until $FF
    LD      A, (IX+0)                      ; A = (IX+0): channel code
    CP      $FF                            ; CP $FF: end?
    RET     Z                              ; RET Z: done
    CALL    DELAY_LOOP_8CFC                ; DELAY_LOOP_8CFC: play channel from record at IX
    LD      DE, $0004                      ; DE = $0004: stride
    ADD     IX, DE                         ; IX += $0004: next record
    JR      LOC_8CEC                       ; JR LOC_8CEC

DELAY_LOOP_8CFC:                           ; DELAY_LOOP_8CFC: play one sound channel from IX record (calls SUB_8D98/8DAB/8E21)
    PUSH    IX                             ; save IX
    CALL    SUB_8D98                       ; SUB_8D98: get channel data from IX+0
    LD      C, A                           ; C = result
    CALL    SUB_8DAB                       ; SUB_8DAB: get secondary byte from IX
    CALL    DELAY_LOOP_8A5D                ; DELAY_LOOP_8A5D: scale A value
    LD      DE, $1800                      ; DE = $1800: VRAM name table base
    ADD     HL, DE                         ; HL += DE: add VRAM offset
    CALL    SUB_8E21                       ; SUB_8E21: play via WRITE_VRAM path
    LD      B, $03

LOC_8D11:
    CALL    SUB_82BD
    INC     IY
    LD      A, (IY+0)
    INC     HL
    DJNZ    LOC_8D11
    POP     IX
    RET     

DELAY_LOOP_8D1F:
    CALL    SUB_8D98
    LD      C, A
    CALL    SUB_8DAB
    CALL    DELAY_LOOP_8A5D
    LD      DE, $1800
    ADD     HL, DE
    CP      $17
    JR      NC, LOC_8D71
    LD      B, $03

LOC_8D33:
    PUSH    AF
    PUSH    BC
    PUSH    HL
    LD      HL, BOOT_UP
    SUB     $02
    LD      E, A
    LD      D, $00
    LD      B, $0A

LOC_8D40:
    ADD     HL, DE
    DJNZ    LOC_8D40
    LD      A, C
    SUB     $02
    SRA     A
    PUSH    AF
    LD      C, A
    ADD     HL, BC
    PUSH    IX
    LD      IX, $B307
    LD      A, $D2
    CALL    DELAY_LOOP_8807
    PUSH    IX
    POP     DE
    POP     IX
    ADD     HL, DE
    LD      B, (HL)
    POP     AF
    LD      A, B
    JR      C, LOC_8D64
    CALL    SUB_9071

LOC_8D64:
    AND     $0F
    POP     HL
    CALL    SUB_82BD
    POP     BC
    POP     AF
    INC     HL
    INC     C
    DJNZ    LOC_8D33
    RET     

LOC_8D71:
    LD      B, $03
    LD      A, $00

LOC_8D75:
    CALL    SUB_82BD
    INC     HL
    DJNZ    LOC_8D75
    RET     
    DB      $05, $09, $0D, $11, $02, $03, $04, $05
    DB      $06, $07, $08, $09, $0A, $0B, $0C, $0D
    DB      $0E, $0F, $10, $11, $12, $13, $14, $15
    DB      $16, $17, $18, $D0

SUB_8D98:
    PUSH    HL
    LD      A, (IX+0)
    AND     $E0
    CALL    SUB_9071
    SRL     A
    LD      HL, $8D7C
    CALL    SUB_8FF4
    POP     HL
    RET     

SUB_8DAB:
    PUSH    HL
    LD      A, (IX+0)
    AND     $1F
    LD      HL, $8D80
    CALL    SUB_8FF4
    POP     HL
    RET     
    DB      $F5, $E5, $C5, $06, $00, $21, $7C, $8D
    DB      $BE, $28, $04, $04, $23, $18, $F9, $78
    DB      $CD, $71, $90, $CB, $27, $47, $DD, $7E
    DB      $00, $E6, $1F, $80, $DD, $77, $00, $C1
    DB      $E1, $F1, $C9

SUB_8DDC:
    PUSH    AF
    PUSH    HL
    PUSH    BC
    LD      B, $00
    LD      HL, $8D80

LOC_8DE4:
    CP      (HL)
    JR      Z, LOC_8DEB
    INC     B
    INC     HL
    JR      LOC_8DE4

LOC_8DEB:
    LD      A, (IX+0)
    AND     $E0
    ADD     A, B
    LD      (IX+0), A
    POP     BC
    POP     HL
    POP     AF
    RET     

SUB_8DF8:
    LD      A, (IX+1)
    AND     $0F
    RET     

SUB_8DFE:
    LD      A, (IX+1)
    AND     $F0
    CALL    SUB_9071
    RET     

SUB_8E07:
    PUSH    AF
    LD      A, (IX+1)
    AND     $0F
    OR      B
    LD      (IX+1), A
    POP     AF
    RET     

SUB_8E13:
    CALL    SUB_8E1A
    LD      D, A
    JP      LOC_8F96

SUB_8E1A:
    PUSH    HL
    PUSH    IX
    POP     HL
    LD      A, L
    POP     HL
    RET     

SUB_8E21:
    PUSH    HL
    LD      HL, BOOT_UP
    CALL    SUB_8DF8
    OR      A
    JR      Z, LOC_8E31
    LD      B, A
    LD      E, $09
    CALL    DELAY_LOOP_8E52

LOC_8E31:
    CALL    SUB_8DFE
    OR      A
    JR      Z, LOC_8E45
    CP      $04
    LD      IY, $8804
    JR      Z, LOC_8E4D
    LD      E, $03
    LD      B, A
    CALL    DELAY_LOOP_8E52

LOC_8E45:
    DB      $EB
    LD      HL, $87CE
    ADD     HL, DE
    PUSH    HL
    POP     IY

LOC_8E4D:
    LD      A, (IY+0)
    POP     HL
    RET     

DELAY_LOOP_8E52:
    LD      D, $00

LOC_8E54:
    ADD     HL, DE
    DJNZ    LOC_8E54
    RET     

SUB_8E58:
    LD      A, ($707C)                  ; RAM $707C
    LD      B, A
    LD      IX, $7084                   ; RAM $7084
    LD      HL, $9733
    RET     

SUB_8E64:
    CALL    SUB_8E58
    LD      A, B
    OR      A
    RET     Z

LOC_8E6A:
    PUSH    BC
    PUSH    HL
    PUSH    IX
    LD      A, (IX+4)
    CP      $05
    JP      NC, LOC_8EEE
    PUSH    IX
    CALL    SUB_91A4
    POP     IX
    PUSH    HL
    LD      A, $05
    CALL    SUB_95FF
    LD      A, (IY+1)
    ADD     A, (HL)
    POP     HL
    ADD     A, $04
    LD      C, A
    PUSH    IX
    PUSH    HL
    LD      A, $06
    CALL    SUB_95FF
    LD      A, (IY+3)
    ADD     A, (HL)
    POP     HL
    AND     $07
    CP      $03
    JR      NZ, LOC_8EEC
    LD      A, (IY+3)
    CALL    SUB_9099
    ADD     A, $02
    LD      B, A
    CALL    SOUND_WRITE_8A1B
    LD      A, E
    CP      $FF
    JR      Z, LOC_8EEC
    PUSH    HL
    POP     IY
    LD      A, (IY+2)
    CP      $77
    JR      NZ, LOC_8EEC
    LD      A, (IY+3)
    CP      $FF
    JR      NZ, LOC_8EEC
    POP     IX
    LD      A, (IX+2)
    CP      $0C
    JR      NC, LOC_8EEE
    PUSH    IX
    CALL    SUB_9D11
    POP     IX
    LD      (IX+2), $00
    LD      (IX+7), $01
    LD      (IX+3), $01
    PUSH    IX
    PUSH    IY
    POP     IX
    CALL    SUB_8E1A
    POP     IX
    LD      (IX+5), A
    JR      LOC_8EEE

LOC_8EEC:
    POP     IX

LOC_8EEE:
    POP     IX
    POP     HL
    POP     BC
    LD      A, $08
    CALL    SUB_8FFD
    LD      DE, $0008
    ADD     HL, DE
    DEC     B
    JP      NZ, LOC_8E6A
    CALL    SUB_8E58

LOC_8F02:
    PUSH    BC
    PUSH    HL
    PUSH    IX
    PUSH    IX
    CALL    SUB_91A4
    POP     HL
    CALL    SUB_8C71

LOC_8F0F:
    LD      A, (IX+0)
    CP      $FF
    JR      Z, LOC_8F84
    PUSH    IX
    PUSH    HL
    POP     IX
    PUSH    HL
    LD      A, $05
    CALL    SUB_95FF
    LD      A, (IY+1)
    ADD     A, (HL)
    POP     HL
    POP     IX
    LD      B, A
    CALL    SUB_8D98
    CALL    DELAY_LOOP_8A69
    SUB     $05
    CP      B
    JR      NC, LOC_8F7D
    ADD     A, $18
    CP      B
    JR      C, LOC_8F7D
    PUSH    HL
    PUSH    IX
    PUSH    HL
    POP     IX
    LD      A, $06
    CALL    SUB_95FF
    LD      A, (IY+3)
    ADD     A, (HL)
    POP     IX
    POP     HL
    SUB     $05
    LD      B, A
    CALL    SUB_8DAB
    CALL    DELAY_LOOP_8A69
    CP      B
    JR      C, LOC_8F7D
    SUB     $0D
    CP      B
    JR      NC, LOC_8F7D
    LD      A, (IX+3)
    OR      A
    JR      Z, LOC_8F7D
    PUSH    IX
    PUSH    HL
    POP     IX
    LD      A, (IX+2)
    CP      $0C
    JR      NC, LOC_8F7B
    LD      A, $02
    LD      (IX+2), A
    LD      (IX+7), $01
    LD      (IX+3), $01

LOC_8F7B:
    POP     IX

LOC_8F7D:
    LD      DE, $0004
    ADD     IX, DE
    JR      LOC_8F0F

LOC_8F84:
    POP     IX
    POP     HL
    POP     BC
    LD      A, $08
    CALL    SUB_8FFD
    LD      DE, $0008
    ADD     HL, DE
    DEC     B
    JP      NZ, LOC_8F02
    RET     

LOC_8F96:
    PUSH    IX
    PUSH    IY
    CALL    SUB_8E58
    LD      A, B
    OR      A
    JR      Z, LOC_8FE4
    LD      E, $00

LOC_8FA3:
    PUSH    BC
    PUSH    HL
    PUSH    IX
    PUSH    IX
    PUSH    HL
    CALL    SUB_91A4
    POP     HL
    POP     IX
    LD      A, (IX+2)
    CP      $00
    JR      NZ, LOC_8FD3
    LD      A, (IX+5)
    CP      D
    JR      NZ, LOC_8FD3
    LD      A, C
    OR      A
    JR      Z, LOC_8FE9
    CP      $FF
    JR      Z, LOC_8FF1
    ADD     A, (IY+3)
    LD      (IY+3), A
    PUSH    HL
    POP     IX
    PUSH    DE
    CALL    PUTOBJ
    POP     DE

LOC_8FD3:
    POP     IX
    POP     HL
    POP     BC
    LD      A, $08
    CALL    SUB_8FFD
    PUSH    DE
    LD      DE, $0008
    ADD     HL, DE
    POP     DE
    DJNZ    LOC_8FA3

LOC_8FE4:
    POP     IY
    POP     IX
    RET     

LOC_8FE9:
    LD      (IX+2), $0E
    LD      (IX+7), $01

LOC_8FF1:
    INC     E
    JR      LOC_8FD3

SUB_8FF4:
    PUSH    DE
    LD      E, A
    LD      D, $00
    ADD     HL, DE
    LD      A, (HL)
    OR      A
    POP     DE
    RET     

SUB_8FFD:
    PUSH    BC
    LD      C, A
    LD      B, $00
    ADD     IX, BC
    LD      A, (IX+0)
    OR      A
    POP     BC
    RET     

SUB_9009:
    LD      A, (IX+0)
    DEC     A
    RET     M
    PUSH    IX
    PUSH    HL
    PUSH    DE
    PUSH    DE
    PUSH    HL
    LD      L, A
    LD      H, $00
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    DB      $EB
    POP     HL
    ADD     HL, DE
    POP     DE
    LD      A, $04
    LD      IY, $0001
    CALL    SUB_9030
    POP     DE
    POP     HL
    POP     IX
    INC     IX
    INC     DE
    JR      SUB_9009

SUB_9030:
    CALL    SUB_9038
    INC     D
    CALL    SUB_9038
    INC     D

SUB_9038:
    PUSH    AF
    PUSH    HL
    PUSH    DE
    PUSH    IY
    CALL    PUT_VRAM
    POP     IY
    POP     DE
    POP     HL
    POP     AF
    RET     

SUB_9046:                                  ; SUB_9046: wait for NMI (clear $7066, spin until $7066 != 0)
    PUSH    AF                             ; A = 0
    SUB     A                              ; ($7066) = 0: clear NMI flag
    LD      ($7066), A                     ; LOC_904A: spin until NMI sets $7066
                                           ; A = ($7066)
LOC_904B:                                  ; OR A
    LD      A, ($7066)                     ; JR Z: loop if flag still 0
    OR      A                              ; RET
    JR      Z, LOC_904B
    POP     AF
    RET     

SUB_9053:                                  ; SUB_9053: NMI sync + VDP disable (SUB_9046 then WRITE_REGISTER $01C2)
    PUSH    BC                             ; SUB_9046: wait for NMI
    CALL    SUB_9046                       ; BC = $01C2: VDP disable command
    LD      BC, $01C2                      ; WRITE_REGISTER: set VDP reg 1 = $C2 (display off)
    CALL    WRITE_REGISTER                 ; RET
    POP     BC
    RET     

SUB_905F:                                  ; SUB_905F: VDP enable (WRITE_REGISTER $01E2)
    PUSH    BC                             ; BC = $01E2: VDP enable command
    PUSH    AF                             ; JP WRITE_REGISTER: set VDP reg 1 = $E2 (display on)
    LD      BC, $01E2
    CALL    WRITE_REGISTER
    POP     AF
    POP     BC
    RET     

DELAY_LOOP_906A:                           ; DELAY_LOOP_906A: fill B bytes of RAM at HL with A
    PUSH    HL                             ; LOC_906B: store A into (HL)
                                           ; (HL) = A
LOC_906B:                                  ; INC HL
    LD      (HL), A                        ; DJNZ
    INC     HL                             ; RET
    DJNZ    LOC_906B
    POP     HL
    RET     

SUB_9071:                                  ; SUB_9071: RLCA x4 (swap hi/lo nibbles of A)
    RLCA                                   ; RLCA
    RLCA                                   ; RLCA
    RLCA                                   ; RLCA
    RLCA                                   ; RLCA
    RET                                    ; RET
    DB      $3E, $01, $18, $01, $97, $DD, $E5, $FD
    DB      $E5, $CD, $CD, $1F, $FD, $E1, $DD, $E1
    DB      $C9, $C5, $DD, $E5, $FD, $E5, $CD, $D0
    DB      $1F, $FD, $E1, $DD, $E1, $C1, $C9, $4F
    DB      $81, $10, $FD

SUB_9099:                                  ; SUB_9099: SRL x3 (A = A / 8)
    SRL     A                              ; SRL A
    SRL     A                              ; SRL A
    SRL     A                              ; SRL A
    RET                                    ; RET
    DB      $AD, $96, $8B, $96, $69, $96, $1D, $1B
    DB      $19, $1B, $1B, $1B

SUB_90AC:                                  ; SUB_90AC: player init (copy $90A6 table -> $70B1, clear enemy ptrs, PUTOBJ player)
    LD      DE, $70B1                   ; RAM $70B1
    LD      HL, $90A6
    LD      BC, $0006
    LDIR    
    XOR     A
    LD      ($7074), A                  ; RAM $7074
    LD      ($70AE), A                  ; RAM $70AE
    LD      ($70B0), A                  ; RAM $70B0
    LD      ($70AF), A                  ; RAM $70AF
    LD      ($716D), A                  ; RAM $716D
    LD      ($716E), A                  ; RAM $716E
    LD      A, $C0
    LD      ($7170), A                  ; RAM $7170
    LD      IX, $971B
    CALL    PUTOBJ
    LD      DE, $7084                   ; RAM $7084
    LD      HL, $0F00
    LD      ($707E), HL                 ; RAM $707E
    LD      A, ($7075)                  ; RAM $7075
    DEC     A
    SLA     A
    LD      B, A
    SLA     A
    SLA     A
    SLA     A
    ADD     A, B
    LD      B, A
    LD      A, ($705C)                  ; RAM $705C
    LD      C, A
    SLA     A
    ADD     A, B
    ADD     A, C
    CP      $48
    JR      C, LOC_90FC
    LD      A, $45

LOC_90FC:
    LD      HL, $9621
    ADD     A, L
    LD      L, A
    JR      NC, LOC_9104
    INC     H

LOC_9104:
    LD      B, $04
    XOR     A
    LD      ($707C), A                  ; RAM $707C

LOC_910A:
    DJNZ    LOC_910E
    JR      LOC_9143

LOC_910E:
    LD      A, (HL)
    INC     HL
    OR      A
    JR      Z, LOC_910A
    LD      C, A
    PUSH    HL
    PUSH    BC
    LD      HL, $707C                   ; RAM $707C
    ADD     A, (HL)
    LD      (HL), A
    LD      HL, $90A0
    LD      A, B
    DEC     A
    SLA     A
    ADD     A, L
    LD      L, A
    JR      NC, LOC_9127
    INC     H

LOC_9127:
    LD      A, (HL)
    INC     HL
    LD      H, (HL)
    LD      L, A

LOC_912B:
    PUSH    BC
    PUSH    HL
    LD      BC, $0007
    LDIR    
    LD      A, R
    AND     $1F
    OR      $08
    LD      (DE), A
    INC     DE
    POP     HL
    POP     BC
    DEC     C
    JR      NZ, LOC_912B
    POP     BC
    POP     HL
    JR      LOC_910A

LOC_9143:
    LD      A, ($707C)                  ; RAM $707C
    LD      B, A
    LD      HL, $9733
    LD      IY, $7084                   ; RAM $7084

LOC_914E:
    OR      A
    PUSH    IY
    PUSH    HL
    PUSH    BC
    CALL    ACTIVATE
    POP     BC
    POP     HL
    POP     IY
    PUSH    HL
    PUSH    IY
    CALL    SUB_91B1
    POP     IY
    LD      A, B
    DEC     A
    AND     $03
    SLA     A
    SLA     A
    OR      (IY+0)
    LD      (IY+0), A
    CALL    SUB_91DB
    POP     IX
    PUSH    IX
    PUSH    IY
    PUSH    BC
    CALL    PUTOBJ
    POP     BC
    POP     IY
    POP     HL
    LD      DE, $0008
    ADD     HL, DE
    LD      DE, $0008
    ADD     IY, DE
    DJNZ    LOC_914E
    LD      A, ($707C)                  ; RAM $707C
    INC     A
    SLA     A
    INC     A
    LD      C, A
    LD      B, $00
    LD      HL, $714C                   ; RAM $714C
    ADD     HL, BC
    LD      A, $0F
    LD      (HL), A
    LD      B, C
    DEC     B

LOC_919F:
    DEC     HL
    LD      (HL), B
    DJNZ    LOC_919F
    RET     

SUB_91A4:
    INC     HL
    INC     HL
    LD      A, (HL)
    INC     HL
    LD      H, (HL)
    LD      L, A
    PUSH    HL
    POP     IY
    PUSH    HL
    POP     IX
    RET     

SUB_91B1:
    CALL    SUB_91A4
    LD      (IX+0), $12
    RET     
    DB      $3A, $7D, $70, $3C, $32, $7D, $70, $CB
    DB      $2F, $C9, $83, $83, $03, $03, $43, $43
    DB      $03, $03, $83, $63, $03, $03, $73, $73
    DB      $03, $03, $A3, $A3, $03, $03, $73, $83
    DB      $13, $63

SUB_91DB:
    LD      A, (IY+0)
    SRA     A
    SRA     A
    LD      E, A
    LD      A, ($705C)                  ; RAM $705C

LOC_91E6:
    CP      $06
    JR      C, LOC_91EE
    SUB     $06
    JR      LOC_91E6

LOC_91EE:
    SLA     A
    SLA     A
    LD      D, $00
    ADD     A, E
    LD      E, A
    LD      HL, $91C3
    ADD     HL, DE
    LD      D, (HL)
    LD      A, (IY+0)
    AND     $03
    JR      NZ, LOC_9206
    LD      A, D
    SUB     $02
    LD      D, A

LOC_9206:
    LD      (IX+3), D
    LD      D, $10
    LD      C, $03
    LD      A, E
    AND     $01
    JR      Z, LOC_9216
    LD      D, $AA
    LD      C, $02

LOC_9216:
    LD      (IX+1), D
    LD      (IY+1), C
    RET     

SUB_921D:                                  ; SUB_921D: enemy tick (check $7080 gate, advance each enemy record at $7084)
    LD      A, ($7080)                     ; A = ($7080): enemy tick gate
    OR      A                              ; OR A
    JP      NZ, LOC_92C5                   ; JP NZ: skip if gate non-zero (throttle enemy speed)
    LD      C, $06
    LD      A, ($705C)                  ; RAM $705C
    CP      $06
    JR      C, LOC_923D
    DEC     C
    CP      $0C
    JR      C, LOC_923D
    DEC     C
    CP      $12
    JR      C, LOC_923D
    DEC     C
    CP      $18
    JR      C, LOC_923D
    DEC     C

LOC_923D:
    LD      HL, ($707E)                 ; RAM $707E
    LD      A, L
    OR      H
    JR      NZ, LOC_9245
    DEC     C

LOC_9245:
    LD      A, ($707C)                  ; RAM $707C
    LD      B, A
    LD      A, C
    LD      ($7080), A                  ; RAM $7080
    LD      IX, $7084                   ; RAM $7084
    LD      HL, $9733

LOC_9254:
    PUSH    BC
    PUSH    HL
    PUSH    IX
    DEC     (IX+7)
    JR      NZ, LOC_927C
    PUSH    HL
    PUSH    IX
    CALL    SUB_92E9
    POP     IX
    LD      A, ($705F)                  ; RAM $705F
    DEC     A
    LD      B, A
    SLA     A
    SLA     A
    SLA     A
    SUB     B
    LD      B, A
    LD      HL, $96D5
    CALL    SUB_92C9
    LD      (IX+7), A
    POP     HL

LOC_927C:
    DEC     (IX+3)
    JR      NZ, LOC_92AF
    LD      A, ($705A)                  ; RAM $705A
    CP      $F0
    JR      Z, LOC_92AF
    CP      $C0
    JR      Z, LOC_92AF
    LD      A, (IX+2)
    CP      $00
    JR      Z, LOC_92A0
    CP      $12
    JR      Z, LOC_92A0
    CP      $10
    JR      Z, LOC_92A0
    PUSH    HL
    CALL    SUB_95DC
    POP     HL

LOC_92A0:
    LD      A, (IX+2)
    CP      $04
    LD      A, (IX+7)
    JR      NZ, LOC_92AC
    LD      A, $02

LOC_92AC:
    LD      (IX+3), A

LOC_92AF:
    PUSH    HL
    POP     IX
    CALL    PUTOBJ
    POP     IX
    POP     HL
    POP     BC
    LD      A, $08
    CALL    SUB_8FFD
    LD      DE, $0008
    ADD     HL, DE
    DEC     B
    JR      NZ, LOC_9254

LOC_92C5:
    RET     

SUB_92C6:
    CALL    SUB_960A

SUB_92C9:
    LD      A, (IX+1)
    ADD     A, B
    LD      D, $00
    LD      E, A
    ADD     HL, DE
    LD      A, (HL)
    RET     
    DB      $4A, $93, $B4, $93, $02, $94, $0B, $93
    DB      $FC, $92, $2C, $93, $E7, $93, $4B, $93
    DB      $D2, $93, $4A, $93, $46, $93

SUB_92E9:
    PUSH    HL
    LD      C, (IX+2)
    LD      HL, $92D3
    LD      B, $00
    ADD     HL, BC
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    PUSH    BC
    POP     IY
    POP     HL
    JP      (IY)
    DB      $DD, $36, $02, $06, $C9, $3F, $94, $60
    DB      $94, $69, $94, $00, $00, $75, $94, $CD
    DB      $11, $94, $B7, $DD, $E5, $28, $06, $DD
    DB      $36, $02, $0A, $18, $2A, $DD, $7E, $01
    DB      $DD, $36, $06, $0A, $11, $01, $93, $FE
    DB      $03, $20, $02, $3E, $04, $C3, $74, $95
    DB      $DD, $7E, $06, $B7, $28, $03, $DD, $35
    DB      $06, $3A, $5A, $70, $FE, $F0, $C8, $FE
    DB      $C0, $C8, $CD, $11, $94, $DD, $E5, $C3
    DB      $86, $94, $DD, $36, $02, $10, $C9, $E5
    DB      $FD, $21, $84, $70, $3A, $7C, $70, $4F
    DB      $DD, $7E, $05, $21, $89, $70, $11, $08
    DB      $00, $06, $00, $BE, $20, $13, $04, $36
    DB      $00, $FD, $36, $02, $14, $FD, $36, $01
    DB      $06, $FD, $36, $03, $01, $FD, $36, $07
    DB      $01, $19, $FD, $19, $0D, $20, $E4, $DD
    DB      $36, $02, $10, $E1, $CD, $A4, $91, $78
    DB      $C6, $0C, $FD, $77, $00, $21, $AA, $93

SUB_938C:
    LD      C, B
    LD      B, $00
    ADD     HL, BC
    LD      B, (HL)
    LD      C, $00
    CALL    SUB_93A2
    LD      A, $90
    CP      (HL)
    RET     NZ
    LD      B, $70
    LD      C, $00
    JP      SUB_93A2
    DB      $C9

SUB_93A2:
    PUSH    HL
    LD      HL, $7056                   ; RAM $7056
    CALL    DELAY_LOOP_9B1E
    POP     HL
    RET     
    DB      $05, $10, $20, $40, $80, $90, $01, $03
    DB      $02, $DD, $36, $02, $0C, $DD, $7E, $01
    DB      $DD, $77, $04, $DD, $36, $01, $05, $DD
    DB      $7E, $00, $E6, $03, $47, $21, $B1, $93
    DB      $CD, $8C, $93, $CD, $0C, $9D, $C9, $DD
    DB      $36, $02, $0A, $DD, $7E, $04, $DD, $46
    DB      $01, $DD, $70, $04, $DD, $77, $01, $DD
    DB      $36, $06, $0F, $C9, $DD, $36, $02, $08
    DB      $DD, $E5, $CD, $B1, $91, $DD, $E1, $DD
    DB      $E5, $FD, $E5, $DD, $E1, $FD, $E1, $CD
    DB      $DB, $91, $C9, $00, $01, $02, $03, $DD
    DB      $36, $02, $0A, $DD, $7E, $04, $DD, $77
    DB      $01, $DD, $36, $03, $01, $C9, $E5, $DD
    DB      $E5, $E5, $3E, $05, $CD, $FF, $95, $4E
    DB      $3E, $06, $CD, $FF, $95, $56, $E1, $CD
    DB      $A4, $91, $DD, $46, $01, $79, $80, $32
    DB      $6F, $70, $DD, $46, $03, $7A, $80, $32
    DB      $70, $70, $CD, $D1, $84, $3A, $69, $70
    DB      $DD, $E1, $E1, $C9, $06, $00, $FD, $7E
    DB      $03, $3D, $3D, $FD, $77, $03, $DD, $E1
    DB      $DD, $7E, $01, $DD, $77, $04, $DD, $70
    DB      $01, $CD, $F0, $99, $DD, $7E, $06, $B7
    DB      $C0, $CD, $22, $9A, $C9, $06, $01, $FD
    DB      $7E, $03, $3C, $3C, $18, $DD, $06, $02
    DB      $FD, $7E, $01, $3D, $3D, $FD, $77, $01
    DB      $18, $D4, $06, $03, $FD, $7E, $01, $3C
    DB      $3C, $18, $F2, $0D, $0E, $0B, $07, $0E
    DB      $0D, $07, $0B, $16, $00, $4F, $06, $04
    DB      $CB, $39, $30, $01, $14, $10, $F9, $15
    DB      $CA, $6E, $95, $DD, $4E, $01, $E5, $21
    DB      $7E, $94, $09, $5E, $23, $23, $23, $23
    DB      $46, $E1, $4F, $7B, $EE, $0F, $A1, $79
    DB      $28, $66, $A3, $15, $CA, $6E, $95, $15
    DB      $20, $5E, $4F, $DD, $7E, $00, $E6, $03
    DB      $FE, $00, $20, $02, $18, $13, $FE, $01
    DB      $20, $0A, $FD, $7E, $03, $FE, $10, $30
    DB      $16, $79, $18, $44, $CD, $B9, $91, $18
    DB      $0B, $CD, $B9, $91, $38, $09, $CB, $2F
    DB      $38, $05, $CB, $2F, $79, $30, $31, $CD
    DB      $55, $95, $28, $2B, $11, $64, $95, $ED
    DB      $43, $81, $70, $79, $A0, $CD, $71, $95
    DB      $CD, $4D, $95, $11, $64, $95, $ED, $43
    DB      $81, $70, $CD, $71, $95, $CD, $B9, $91
    DB      $30, $05, $CD, $4D, $95, $18, $64, $ED
    DB      $4B, $81, $70, $79, $A0, $18, $5C, $79
    DB      $A0, $4F, $E6, $0C, $79, $28, $1E, $FE
    DB      $0C, $20, $50, $CD, $CD, $95, $20, $0F
    DB      $7A, $B7, $20, $05, $CD, $B9, $91, $18
    DB      $06, $78, $2F, $E6, $0F, $18, $3C, $D2
    DB      $75, $94, $C3, $69, $94, $FE, $03, $20
    DB      $32, $CD, $C0, $95, $CA, $48, $95, $D2
    DB      $60, $94, $C3, $3F, $94, $CD, $B9, $91
    DB      $18, $F5, $ED, $4B, $81, $70, $CD, $55
    DB      $95, $C9, $78, $EE, $0F, $A1, $C9, $3F
    DB      $94, $60, $94, $75, $94, $00, $00, $69
    DB      $94, $86, $95, $94, $95, $B1, $95, $00
    DB      $00, $A3, $95, $11, $5A, $95

LOC_9571:
    OR      A
    SRL     A
    SLA     A
    PUSH    HL
    LD      H, D
    LD      L, E
    LD      C, A
    LD      B, $00
    ADD     HL, BC
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    PUSH    BC
    POP     IX
    POP     HL
    JP      (IX)
    DB      $C1, $DD, $E1, $CD, $C0, $95, $DD, $E5
    DB      $C5, $D0, $C1, $C3, $3F, $94, $C1, $DD
    DB      $E1, $CD, $C0, $95, $DD, $E5, $C5, $C8
    DB      $D8, $C1, $C3, $60, $94, $C1, $DD, $E1
    DB      $CD, $CD, $95, $DD, $E5, $C5, $D0, $C1
    DB      $C3, $69, $94, $C1, $DD, $E1, $CD, $CD
    DB      $95, $DD, $E5, $C5, $C8, $D8, $C1, $C3
    DB      $75, $94, $3E, $06, $CD, $FF, $95, $3A
    DB      $5F, $71, $96, $FD, $BE, $03, $C9, $3E
    DB      $05, $CD, $FF, $95, $3A, $5D, $71, $C6
    DB      $04, $96, $FD, $BE, $01, $C9

SUB_95DC:
    PUSH    IX
    CALL    SUB_91A4
    POP     IX
    LD      B, $07
    CALL    SUB_92C6
    LD      B, (IY+0)
    INC     B
    LD      DE, $0007
    OR      A
    SBC     HL, DE
    LD      C, (HL)
    CP      B
    JR      C, LOC_95FB
    LD      A, B
    CP      C
    JR      C, LOC_95FB
    LD      C, B

LOC_95FB:
    LD      (IY+0), C
    RET     

SUB_95FF:
    CALL    SUB_960A
    ADD     A, $0E
    ADD     A, L
    LD      L, A
    JR      NC, LOC_9609
    INC     H

LOC_9609:
    RET     

SUB_960A:
    PUSH    DE
    PUSH    AF
    LD      A, (IX+0)
    AND     $03
    SLA     A
    LD      HL, $96CF
    LD      E, A
    LD      D, $00
    ADD     HL, DE
    LD      E, (HL)
    INC     HL
    LD      H, (HL)
    LD      L, E
    POP     AF
    POP     DE
    RET     
    DB      $02, $01, $00, $01, $02, $00, $00, $01
    DB      $02, $02, $00, $01, $00, $02, $01, $01
    DB      $01, $01, $03, $01, $00, $03, $01, $00
    DB      $02, $01, $01, $01, $00, $03, $00, $02
    DB      $02, $01, $01, $02, $03, $01, $00, $02
    DB      $02, $00, $01, $01, $02, $02, $00, $02
    DB      $00, $03, $01, $02, $01, $01, $04, $01
    DB      $00, $04, $01, $00, $02, $01, $02, $03
    DB      $00, $02, $00, $03, $02, $02, $02, $01
    DB      $00, $02, $08, $01, $00, $00, $00, $19
    DB      $00, $08, $02, $06, $00, $04, $0A, $12
    DB      $09, $03, $07, $01, $05, $0A, $00, $04
    DB      $02, $04, $06, $02, $04, $02, $03, $04
    DB      $03, $0A, $01, $02, $08, $01, $00, $00
    DB      $00, $19, $00, $17, $15, $19, $13, $2B
    DB      $0C, $12, $18, $16, $1A, $14, $2C, $0C
    DB      $00, $2B, $04, $05, $05, $03, $04, $00
    DB      $02, $08, $04, $08, $02, $02, $08, $01
    DB      $00, $00, $00, $19, $00, $23, $27, $1F
    DB      $1B, $2D, $0B, $12, $26, $2A, $22, $1E
    DB      $2E, $0B, $00, $2D, $05, $04, $07, $02
    DB      $04, $00, $04, $08, $04, $0A, $72, $96
    DB      $94, $96, $B6, $96, $01, $01, $01, $01
    DB      $32, $1E, $32, $01, $01, $01, $01, $2D
    DB      $19, $2D, $01, $01, $01, $01, $28, $14
    DB      $28, $01, $01, $01, $01, $23, $12, $23
    DB      $01, $01, $01, $01, $1E, $0F, $1E, $01
    DB      $01, $01, $01, $19, $0C, $19, $01, $01
    DB      $01, $01, $14, $0A, $14, $01, $01, $01
    DB      $01, $0F, $08, $0F, $01, $01, $01, $01
    DB      $0A, $05, $0A, $01, $01, $01, $01, $05
    DB      $02, $05, $20, $97, $6D, $71, $02, $03
    DB      $08, $D8, $A7, $08, $27, $97, $0F, $A0
    DB      $0F, $00, $0F, $04, $0F, $34, $0F, $38
    DB      $0F, $88, $63, $97, $73, $71, $7E, $98
    DB      $83, $98, $63, $97, $84, $71, $88, $98
    DB      $8D, $98, $63, $97, $95, $71, $92, $98
    DB      $97, $98, $63, $97, $A6, $71, $9C, $98
    DB      $A1, $98, $63, $97, $B7, $71, $A6, $98
    DB      $AB, $98, $63, $97, $C9, $71, $B0, $98
    DB      $B5, $98, $24, $20, $98, $70, $98, $22
    DB      $98, $70, $98, $24, $98, $70, $98, $26
    DB      $98, $70, $98, $2A, $98, $70, $98, $28
    DB      $98, $70, $98, $2C, $98, $70, $98, $2E
    DB      $98, $70, $98, $30, $98, $70, $98, $32
    DB      $98, $70, $98, $34, $98, $76, $98, $36
    DB      $98, $76, $98, $38, $98, $76, $98, $3A
    DB      $98, $76, $98, $3C, $98, $76, $98, $3E
    DB      $98, $76, $98, $40, $98, $76, $98, $42
    DB      $98, $76, $98, $44, $98, $76, $98, $46
    DB      $98, $74, $98, $48, $98, $74, $98, $4A
    DB      $98, $74, $98, $4C, $98, $74, $98, $4E
    DB      $98, $74, $98, $50, $98, $74, $98, $52
    DB      $98, $74, $98, $54, $98, $74, $98, $5C
    DB      $98, $7A, $98, $6C, $98, $7A, $98, $5A
    DB      $98, $7A, $98, $6C, $98, $7A, $98, $56
    DB      $98, $7A, $98, $6A, $98, $7A, $98, $58
    DB      $98, $7A, $98, $6A, $98, $7A, $98, $5E
    DB      $98, $7A, $98, $6E, $98, $7A, $98, $5A
    DB      $98, $7A, $98, $6E, $98, $7A, $98, $60
    DB      $98, $7A, $98, $6C, $98, $7A, $98, $5A
    DB      $98, $7A, $98, $6C, $98, $7A, $98, $64
    DB      $98, $74, $98, $62, $98, $74, $98, $68
    DB      $98, $7A, $98, $66, $98, $7A, $98, $00
    DB      $00, $01, $01, $02, $02, $03, $03, $08
    DB      $04, $09, $05, $04, $00, $05, $01, $06
    DB      $02, $07, $03, $0A, $06, $22, $06, $23
    DB      $06, $0B, $06, $0C, $06, $0D, $06, $0E
    DB      $06, $0F, $06, $10, $06, $13, $09, $14
    DB      $0A, $15, $0D, $16, $0E, $10, $0B, $10
    DB      $0C, $11, $07, $12, $08, $19, $06, $1F
    DB      $06, $20, $06, $1A, $06, $1B, $06, $1C
    DB      $06, $17, $0F, $18, $10, $1D, $06, $1E
    DB      $06, $24, $06, $25, $06, $26, $06, $00
    DB      $00, $00, $10, $00, $00, $00, $00, $10
    DB      $00, $00, $00, $7F, $7F, $BA, $98, $78
    DB      $71, $03, $0F, $99, $7E, $71, $04, $BA
    DB      $98, $89, $71, $05, $0F, $99, $8F, $71
    DB      $06, $BA, $98, $9A, $71, $07, $0F, $99
    DB      $A0, $71, $08, $BA, $98, $AB, $71, $09
    DB      $0F, $99, $B1, $71, $0A, $BA, $98, $BC
    DB      $71, $0B, $0F, $99, $C2, $71, $0C, $BA
    DB      $98, $CE, $71, $0D, $0F, $99, $D4, $71
    DB      $0E, $03, $10, $18, $A8, $98, $C1, $98
    DB      $08, $00, $08, $04, $08, $08, $08, $0C
    DB      $08, $10, $08, $14, $08, $18, $08, $1C
    DB      $0A, $20, $0A, $24, $0F, $28, $0F, $2C
    DB      $0F, $30, $0F, $34, $0F, $38, $0F, $3C
    DB      $01, $98, $0A, $40, $0A, $44, $0A, $48
    DB      $0A, $4C, $0A, $50, $0A, $54, $08, $58
    DB      $08, $5C, $03, $60, $03, $64, $03, $68
    DB      $03, $6C, $0B, $70, $0B, $74, $0C, $78
    DB      $0C, $7C, $0F, $80, $0F, $84, $0F, $88
    DB      $02, $8C, $02, $90, $02, $94, $03, $A8
    DB      $D8, $AC, $44, $16, $99, $02, $2C, $02
    DB      $30, $02, $34, $02, $38, $02, $3C, $02
    DB      $40, $01, $00, $0F, $04, $0F, $08, $0F
    DB      $0C, $0F, $10, $0F, $14, $0F, $18, $0F
    DB      $1C, $0F, $20, $0B, $24, $0B, $28, $BB
    DB      $99, $D2, $99, $D9, $99, $00, $00, $E9
    DB      $99

SUB_9942:                                  ; SUB_9942: bonus item check ($716D: 0=skip; <3 check $7083 timer; else show PUTOBJ $971B)
    LD      A, ($716D)                  ; RAM $716D
    OR      A
    JR      Z, LOC_997A
    CP      $03
    JR      C, LOC_9954
    LD      A, ($7083)                  ; RAM $7083
    OR      A
    JR      NZ, LOC_997A
    JR      LOC_995A

LOC_9954:
    LD      A, ($7083)                  ; RAM $7083
    OR      A
    JR      NZ, LOC_996F

LOC_995A:
    LD      A, $B8
    LD      ($716E), A                  ; RAM $716E
    LD      ($7170), A                  ; RAM $7170
    XOR     A
    LD      ($716D), A                  ; RAM $716D

LOC_9966:
    LD      IX, $971B
    CALL    PUTOBJ
    JR      LOC_997A

LOC_996F:
    CP      $17
    JR      NC, LOC_997A
    LD      A, $02
    LD      ($716D), A                  ; RAM $716D
    JR      LOC_9966

LOC_997A:
    LD      A, ($705A)                  ; RAM $705A
    CP      $F0
    RET     Z
    CP      $C0
    RET     Z
    LD      A, ($7064)                  ; RAM $7064
    OR      A
    JR      NZ, LOC_9993
    LD      A, ($7061)                  ; RAM $7061
    OR      A
    JR      NZ, LOC_9993
    LD      ($707A), A                  ; RAM $707A
    RET     

LOC_9993:
    LD      A, ($707A)                  ; RAM $707A
    OR      A
    RET     NZ
    LD      A, $01
    LD      ($707A), A                  ; RAM $707A
    LD      A, ($7060)                  ; RAM $7060
    OR      A
    JR      NZ, LOC_99A6
    JP      LOC_9D2A

LOC_99A6:
    DEC     A
    LD      ($7060), A                  ; RAM $7060
    CALL    SUB_9D25
    LD      A, $46
    LD      ($7083), A                  ; RAM $7083
    LD      A, ($706A)                  ; RAM $706A
    LD      DE, $9938
    JP      LOC_9571
    DB      $3A, $5F, $71, $D6, $10, $32, $70, $71
    DB      $3A, $5D, $71, $D6, $02, $32, $6E, $71
    DB      $3E, $01, $32, $6D, $71, $18, $94, $3A
    DB      $5F, $71, $C6, $10, $18, $E7, $3A, $5D
    DB      $71, $C6, $0C, $32, $6E, $71, $3A, $5F
    DB      $71, $32, $70, $71, $18, $E2, $3A, $5D
    DB      $71, $D6, $0C, $18, $EE, $3A, $6D, $71
    DB      $FE, $03, $D0, $3A, $6E, $71, $4F, $3A
    DB      $70, $71, $C6, $02, $57, $1E, $0C, $3E
    DB      $07, $CD, $FF, $95, $CD, $3D, $9A, $B7
    DB      $C0, $DD, $7E, $02, $FE, $06, $C8, $DD
    DB      $36, $02, $04, $DD, $7E, $01, $DD, $77
    DB      $04, $DD, $36, $01, $04, $C1, $C9, $3A
    DB      $5D, $71, $3C, $4F, $3A, $5F, $71, $57 ; "]q<O:_qW"
    DB      $1E, $06, $3E, $01, $CD, $FF, $95, $CD
    DB      $3D, $9A, $B7, $C0, $3E, $F0, $32, $5A
    DB      $70, $C9

SUB_9A3D:                                  ; SUB_9A3D: bounding-box collision check (IY=sprite A, HL=sprite B bounds, C/D=pos)
    LD      A, (IY+1)                      ; A = (IY+1): sprite A Y position
    ADD     A, $10                         ; ADD A, $10: Y + half-height
    ADD     A, (HL)                        ; ADD A, (HL): Y+$10 + sprite B Y
    LD      B, A                           ; B = sum
    LD      A, C                           ; A = C: test object Y
    ADD     A, $10                         ; ADD A, $10
    ADD     A, E                           ; ADD A, E
    CP      B                              ; CP B: compare upper bound
    RET     C                              ; RET C: no collision (above)
    SUB     E                              ; SUB E: adjust
    INC     HL                             ; INC HL
    SUB     (HL)                           ; SUB (HL): check lower bound
    CP      B                              ; CP B
    RET     NC                             ; RET NC: no collision (below)
    LD      A, (IY+3)                      ; A = (IY+3): sprite A X position
    ADD     A, $10                         ; ADD A, $10
    INC     HL                             ; INC HL
    ADD     A, (HL)                        ; ADD A, (HL)
    LD      B, A                           ; B = X sum
    LD      A, D                           ; A = D: test object X
    ADD     A, $10                         ; ADD A, $10
    ADD     A, $0C                         ; ADD A, $0C
    CP      B                              ; CP B: compare left bound
    RET     C                              ; RET C: no collision (left)
    INC     HL                             ; INC HL
    SUB     (HL)                           ; SUB (HL): check right bound
    LD      C, A                           ; C = A
    LD      A, B                           ; A = B
    ADD     A, $0C                         ; ADD A, $0C
    CP      C                              ; CP C
    RET     C                              ; RET C: no collision (right)
    XOR     A                              ; XOR A: A = 0 -> collision detected
    RET                                    ; RET

SUB_9A68:                                  ; SUB_9A68: shift enemy spawn ring buffer at $714D (length from $707C)
    LD      A, ($707C)                     ; A = ($707C): active enemy count
    OR      A                              ; OR A
    RET     Z                              ; RET Z: no enemies, skip
    LD      HL, ($714F)                    ; HL = ($714F): ring buffer tail (last 2 bytes)
    PUSH    HL                             ; save tail
    LD      HL, ($714D)                    ; HL = ($714D): ring buffer head
    PUSH    HL                             ; save head
    LD      HL, $7150                      ; HL = $7150: src (ring+2)
    LD      DE, $714D                      ; DE = $714D: dest (ring start)
    SLA     A                              ; SLA A: A*2
    DEC     A                              ; DEC A: count = 2*N-1
    LD      C, A                           ; C = count
    LD      B, $00                         ; B = $00
    LDIR                                   ; LDIR: shift ring buffer left by 1 entry
    POP     HL                             ; restore head to HL
    LD      A, L                           ; write head lo byte to new tail
    LD      (DE), A                        ; INC DE
    INC     DE                             ; write head hi byte
    LD      A, H                           ; INC DE
    LD      (DE), A                        ; restore tail to HL
    INC     DE                             ; write tail lo byte to ring end
    POP     HL                             ; RET
    LD      A, L
    LD      (DE), A
    RET     

SUB_9A8E:                                  ; SUB_9A8E: render one VRAM tile row from IX tile buf (B rows, HL=VRAM, E=offset)
    PUSH    BC                             ; save BC
    LD      B, $04                         ; B = $04: 4 bytes per tile
    JR      LOC_9A94
    DB      $C5

LOC_9A94:
    PUSH    DE
    PUSH    HL
    PUSH    IX
    LD      E, $30

LOC_9A9A:
    LD      A, (IX+0)
    CALL    SUB_9071
    AND     $0F
    JR      NZ, LOC_9AC1
    INC     HL
    LD      A, (IX+0)
    AND     $0F
    JR      NZ, LOC_9ACB
    INC     IX
    INC     HL
    DJNZ    LOC_9A9A
    LD      A, $30
    DEC     HL
    CALL    SUB_9ADA
    JR      LOC_9AD4

LOC_9AB9:
    LD      A, (IX+0)
    CALL    SUB_9071
    AND     $0F

LOC_9AC1:
    ADD     A, E
    CALL    SUB_9ADA
    INC     HL
    LD      A, (IX+0)
    AND     $0F

LOC_9ACB:
    ADD     A, E
    CALL    SUB_9ADA
    INC     IX
    INC     HL
    DJNZ    LOC_9AB9

LOC_9AD4:
    POP     IX
    POP     HL
    POP     DE
    POP     BC
    RET     

SUB_9ADA:                                  ; SUB_9ADA: write 1 byte to VRAM at HL (preserve BC/AF/DE)
    PUSH    BC                             ; save BC
    PUSH    AF                             ; save AF
    PUSH    DE                             ; save DE
    LD      DE, $0001                      ; DE = $0001: write 1 byte
    CALL    FILL_VRAM                      ; FILL_VRAM
    POP     DE                             ; restore DE/AF/BC
    POP     AF
    POP     BC
    RET                                    ; RET

SUB_9AE7:                                  ; SUB_9AE7: BCD add C/B to score bytes at HL+1..HL+3 (3-byte BCD)
    PUSH    BC                             ; save BC/DE/HL
    PUSH    DE                             ; D = $00
    LD      D, $00                         ; save HL
    PUSH    HL                             ; INC HL
    INC     HL                             ; E = (HL): score lo byte
    LD      E, (HL)                        ; HL += 2: point to score hi byte
    INC     HL                             ; A = (HL): hi byte
    INC     HL                             ; ADD A,C: add low score increment
    LD      A, (HL)                        ; DAA: decimal adjust
    ADD     A, C                           ; (HL) = result
    DAA                                    ; DEC HL
    LD      (HL), A                        ; A = (HL): mid byte
    DEC     HL                             ; ADC A,B: add carry + high increment
    LD      A, (HL)                        ; DAA
    ADC     A, B                           ; (HL) = result
    DAA                                    ; B = $02: loop 2 more bytes
    LD      (HL), A
    LD      B, $02                         ; LOC_9AFB: propagate carry through remaining BCD bytes
                                           ; DEC HL
LOC_9AFB:                                  ; A = (HL)
    DEC     HL                             ; ADC A,D: carry only
    LD      A, (HL)                        ; DAA
    ADC     A, D                           ; (HL) = result
    DAA                                    ; D = $00
    LD      (HL), A                        ; DJNZ: loop
    LD      D, $00                         ; restore HL
    DJNZ    LOC_9AFB                       ; INC HL
    POP     HL                             ; A = (HL): hi score byte
    INC     HL                             ; CP E: compare to saved lo byte
    LD      A, (HL)                        ; JR Z: if match, no stage advance
    CP      E                              ; A = ($705B): stage counter
    JR      Z, LOC_9B1A                    ; INC A: advance stage
    LD      A, ($705B)                     ; ($705B) = incremented stage
    INC     A                              ; save HL/IX
    LD      ($705B), A                     ; play bonus sound (SUB_9D20)
    PUSH    HL
    PUSH    IX                             ; restore IX/HL
    CALL    SUB_9D20
    POP     IX
    POP     HL                             ; LOC_9B1A: pop and return
                                           ; DEC HL
LOC_9B1A:                                  ; restore DE/BC
    DEC     HL                             ; RET
    POP     DE
    POP     BC
    RET     

DELAY_LOOP_9B1E:                           ; DELAY_LOOP_9B1E: BCD score write (SUB_9AE7) + controller/direction update
    CALL    SUB_9AE7                       ; SUB_9AE7: BCD score accumulate
    PUSH    BC                             ; save BC/DE/HL
    PUSH    DE                             ; DE = CONTROLLER_BUFFER
    PUSH    HL                             ; B = $04: 4 direction bytes
    LD      DE, CONTROLLER_BUFFER       ; CONTROLLER_BUFFER
    LD      B, $04

LOC_9B29:
    PUSH    BC
    LD      A, (DE)
    LD      B, (HL)
    CP      B
    POP     BC
    JR      NZ, LOC_9B36
    INC     HL
    INC     DE
    DJNZ    LOC_9B29
    JR      LOC_9B3E

LOC_9B36:
    JR      NC, LOC_9B3E

LOC_9B38:
    LD      A, (HL)
    LD      (DE), A
    INC     HL
    INC     DE
    DJNZ    LOC_9B38

LOC_9B3E:
    POP     HL
    POP     DE
    POP     BC
    RET     

SUB_9B42:                                  ; SUB_9B42: player walk animation frame ($7054 selects P1/P2 VRAM row, IX=$7056)
    LD      HL, $1857
    LD      A, ($7054)                  ; RAM $7054
    OR      A
    JR      Z, LOC_9B4E
    LD      HL, $18F7

LOC_9B4E:
    LD      IX, $7056                   ; RAM $7056
    CALL    SUB_9A8E
    RET     
    DB      $04, $08, $0C, $46, $46, $05, $07, $0D
    DB      $46, $46, $04, $08, $0E, $46, $46, $06
    DB      $10, $16, $1C, $46, $03, $06, $09, $46
    DB      $46, $03, $07, $0C, $0E, $46, $B5, $B7
    DB      $B3, $AC, $18, $4C, $19, $4C, $19, $0C
    DB      $18, $90, $18, $0C, $19, $5E, $5E, $5E
    DB      $5E, $7E, $5E, $2B, $53, $53, $03, $23
    DB      $43, $05, $10, $15, $03, $04, $05

SUB_9B95:                                  ; SUB_9B95: burger collision: check $7055/$705E/$705D vs table $9B56; drop via VDP_WRITE_9C80/9C8B
    LD      A, ($7055)                  ; RAM $7055
    LD      HL, $9B56
    LD      E, A
    SLA     A
    SLA     A
    ADD     A, E
    LD      B, A
    LD      A, ($705E)                  ; RAM $705E
    LD      D, A
    ADD     A, B
    CALL    SUB_9C97
    LD      B, (HL)
    LD      A, ($705D)                  ; RAM $705D
    CP      B
    JR      C, LOC_9BEE
    INC     D
    PUSH    DE
    CALL    SUB_9D16
    POP     DE
    LD      A, D
    LD      ($705E), A                  ; RAM $705E
    CALL    SUB_9CAA
    JR      NZ, LOC_9BE8
    CALL    SUB_9CAF
    LD      HL, $9B74
    CALL    SUB_9C97
    LD      D, (HL)
    CALL    SUB_9C9C
    CALL    SUB_9053
    CALL    VDP_WRITE_9C80
    LD      ($7072), A                  ; RAM $7072
    CALL    VDP_WRITE_9C8B
    CALL    SUB_9C75
    CALL    VDP_WRITE_9C80
    LD      ($7073), A                  ; RAM $7073
    CALL    VDP_WRITE_9C8B
    CALL    SUB_905F

LOC_9BE8:
    LD      A, $F0
    LD      ($7074), A                  ; RAM $7074
    RET     

LOC_9BEE:
    CALL    SUB_9CAA
    RET     Z
    DEC     A
    LD      ($7074), A                  ; RAM $7074
    JR      NZ, LOC_9C13
    CALL    SUB_9C9C
    LD      A, ($7072)                  ; RAM $7072
    LD      D, A
    CALL    SUB_9053
    CALL    VDP_WRITE_9C8B
    CALL    SUB_9C76
    LD      A, ($7073)                  ; RAM $7073
    LD      D, A
    CALL    VDP_WRITE_9C8B
    CALL    SUB_905F
    RET     

LOC_9C13:
    LD      D, $00
    LD      HL, $9B83
    ADD     HL, DE
    LD      C, (HL)
    LD      HL, $9B89
    ADD     HL, DE
    LD      D, (HL)
    PUSH    DE
    PUSH    BC
    LD      E, $08
    LD      HL, $9C71
    LD      IY, $715C                   ; RAM $715C
    CALL    SUB_9A3D
    POP     BC
    POP     DE
    OR      A
    RET     NZ
    PUSH    DE
    PUSH    BC
    LD      A, $01
    LD      ($7074), A                  ; RAM $7074
    LD      A, ($7060)                  ; RAM $7060
    INC     A
    LD      ($7060), A                  ; RAM $7060
    CALL    SUB_9CAF
    LD      B, A
    LD      HL, $9B8F
    CALL    SUB_938C
    LD      A, ($716D)                  ; RAM $716D
    POP     BC
    POP     DE
    OR      A
    RET     NZ
    PUSH    DE
    PUSH    BC
    PUSH    HL
    CALL    SUB_9D1B
    POP     HL
    LD      A, $5A
    LD      ($7083), A                  ; RAM $7083
    LD      DE, $0003
    ADD     HL, DE
    LD      A, (HL)
    LD      ($716D), A                  ; RAM $716D
    POP     BC
    POP     DE
    LD      A, C
    LD      ($716E), A                  ; RAM $716E
    LD      A, D
    LD      ($7170), A                  ; RAM $7170
    JP      LOC_9966
    DB      $00, $05, $03, $0B

SUB_9C75:
    INC     D

SUB_9C76:
    LD      BC, $0020
    ADD     HL, BC
    RET     

VDP_REG_9C7B:                              ; VDP_REG_9C7B: set VRAM address low byte (OUT $BF with L, return H)
    LD      A, L
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, H
    RET     

VDP_WRITE_9C80:                            ; VDP_WRITE_9C80: set VRAM read address HL, IN from $BE -> A
    CALL    VDP_REG_9C7B
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    NOP     
    NOP     
    NOP     
    IN      A, ($BE)                    ; DATA_PORT - read VRAM
    RET     

VDP_WRITE_9C8B:                            ; VDP_WRITE_9C8B: set VRAM write address HL+$40, OUT $BE with D
    CALL    VDP_REG_9C7B
    OR      $40
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, D
    NOP     
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    RET     

SUB_9C97:
    LD      C, A
    LD      B, $00
    ADD     HL, BC
    RET     

SUB_9C9C:
    LD      HL, $9B77
    LD      A, E
    SLA     A
    CALL    SUB_9C97
    LD      A, (HL)
    INC     HL
    LD      H, (HL)
    LD      L, A
    RET     

SUB_9CAA:
    LD      A, ($7074)                  ; RAM $7074
    OR      A
    RET     

SUB_9CAF:
    LD      A, E

LOC_9CB0:
    CP      $03
    RET     C
    SUB     $03
    JR      LOC_9CB0

SUB_9CB7:                                  ; SUB_9CB7: advance burger layer scroll one step (SBC/ADD HL, write 2 VRAM bytes)
    LD      B, A
    LD      A, E
    CP      $0A
    LD      A, B
    RET     NC
    OR      A
    RET     M
    CP      E
    RET     Z
    LD      BC, $0020
    JR      C, LOC_9CCC
    OR      A
    SBC     HL, BC
    INC     E
    JR      LOC_9CCE

LOC_9CCC:
    LD      D, $00

LOC_9CCE:
    CALL    VDP_WRITE_9C8B
    LD      A, D
    OR      A
    RET     NZ
    ADD     HL, BC
    DEC     E
    RET     

SUB_9CD7:                                  ; SUB_9CD7: SOUND_INIT wrapper (B=4, HL=$9D2F, JP SOUND_INIT)
    LD      B, $04                         ; B = $04: 4 sound channels
    LD      HL, $9D2F                      ; HL = $9D2F: song table
    JP      SOUND_INIT                     ; JP SOUND_INIT: init sound engine (tail call)

SUB_9CDF:                                  ; SUB_9CDF: PLAY_IT channels 1+2 (B=1 then B=2)
    LD      B, $01                         ; LD B,$01
    CALL    PLAY_IT                        ; CALL PLAY_IT
    LD      B, $02                         ; LD B,$02
    JP      PLAY_IT                        ; JP PLAY_IT

SUB_9CE9:                                  ; SUB_9CE9: PLAY_IT channels 3+4
    LD      B, $03                         ; LD B,$03
    CALL    PLAY_IT                        ; CALL PLAY_IT
    LD      B, $04                         ; LD B,$04
    JP      PLAY_IT                        ; JP PLAY_IT

SUB_9CF3:                                  ; SUB_9CF3: PLAY_IT channels 5+6
    LD      B, $05                         ; LD B,$05
    CALL    PLAY_IT                        ; CALL PLAY_IT
    LD      B, $06                         ; LD B,$06
    JP      PLAY_IT                        ; JP PLAY_IT

SUB_9CFD:                                  ; SUB_9CFD: PLAY_IT channels 7+8
    LD      B, $07                         ; LD B,$07
    CALL    PLAY_IT                        ; CALL PLAY_IT
    LD      B, $08                         ; LD B,$08
    JP      PLAY_IT                        ; JP PLAY_IT

LOC_9D07:
    LD      B, $09
    JP      PLAY_IT
    DB      $06, $0A, $C3, $F1, $1F

SUB_9D11:
    LD      B, $0B
    JP      PLAY_IT

SUB_9D16:
    LD      B, $0C
    JP      PLAY_IT

SUB_9D1B:
    LD      B, $0D
    JP      PLAY_IT

SUB_9D20:
    LD      B, $0E
    JP      PLAY_IT

SUB_9D25:
    LD      B, $0F
    JP      PLAY_IT

LOC_9D2A:
    LD      B, $10
    JP      PLAY_IT
    DB      $6F, $9D, $B7, $70, $25, $9E, $C1, $70
    DB      $AE, $9E, $B7, $70, $0A, $9F, $C1, $70
    DB      $4D, $9F, $B7, $70, $99, $9F, $C1, $70
    DB      $DC, $9F, $B7, $70, $10, $A0, $C1, $70
    DB      $44, $A0, $CB, $70, $59, $A0, $CB, $70
    DB      $7A, $A0, $CB, $70, $BD, $A0, $D5, $70
    DB      $DD, $A0, $D5, $70, $F3, $A0, $CB, $70
    DB      $24, $A1, $CB, $70, $38, $A1, $D5, $70
    DB      $40, $AA, $50, $03, $63, $40, $AA, $50
    DB      $03, $63, $40, $A0, $50, $03, $63, $40
    DB      $A0, $50, $03, $63, $40, $97, $50, $03
    DB      $63, $40, $97, $50, $03, $63, $40, $87
    DB      $50, $03, $63, $40, $87, $50, $03, $63
    DB      $40, $7F, $50, $09, $63, $40, $AA, $50
    DB      $09, $63, $40, $7F, $50, $09, $63, $40
    DB      $AA, $50, $09, $63, $63, $40, $8F, $50
    DB      $03, $63, $40, $6B, $50, $03, $63, $40
    DB      $71, $50, $03, $63, $40, $7F, $50, $03
    DB      $63, $40, $8F, $50, $03, $63, $40, $97
    DB      $50, $03, $63, $40, $8F, $50, $03, $63
    DB      $40, $97, $50, $03, $63, $40, $8F, $50
    DB      $09, $63, $40, $6B, $50, $09, $63, $40
    DB      $8F, $50, $09, $63, $40, $6B, $50, $09
    DB      $63, $40, $8F, $50, $08, $64, $40, $55
    DB      $50, $0A, $62, $40, $8F, $50, $08, $64
    DB      $40, $55, $50, $08, $64, $40, $7F, $50
    DB      $08, $64, $40, $5F, $50, $08, $64, $40
    DB      $8F, $50, $08, $64, $40, $6B, $50, $08
    DB      $64, $40, $7F, $50, $08, $64, $40, $5F
    DB      $50, $08, $64, $40, $8F, $50, $08, $64
    DB      $40, $6B, $50, $08, $64, $58, $80, $40
    DB      $61, $03, $A3, $80, $40, $61, $03, $A3
    DB      $80, $53, $61, $03, $A3, $80, $53, $61
    DB      $03, $A3, $80, $68, $61, $03, $A3, $80
    DB      $68, $61, $03, $A3, $80, $7D, $61, $03
    DB      $A3, $80, $7D, $61, $03, $A3, $80, $94
    DB      $61, $0F, $A3, $80, $94, $61, $03, $A3
    DB      $80, $94, $61, $15, $A3, $A3, $80, $AC
    DB      $61, $03, $A9, $80, $7D, $61, $03, $A9
    DB      $80, $53, $61, $03, $A3, $80, $7D, $61
    DB      $03, $A3, $80, $53, $61, $03, $A3, $80
    DB      $7D, $61, $03, $A3, $80, $53, $61, $06
    DB      $AC, $80, $53, $61, $03, $A3, $80, $53
    DB      $61, $06, $B2, $80, $AC, $61, $08, $AA
    DB      $80, $AC, $61, $04, $A2, $80, $AC, $61
    DB      $08, $B0, $80, $7D, $61, $08, $B0, $80
    DB      $AC, $61, $08, $B0, $80, $7D, $61, $08
    DB      $B0, $80, $AC, $61, $08, $B0, $98, $62
    DB      $40, $E2, $10, $0A, $62, $40, $BE, $10
    DB      $0A, $62, $40, $BE, $10, $0A, $62, $40
    DB      $D7, $10, $04, $62, $40, $E2, $10, $04
    DB      $62, $40, $D7, $10, $0A, $62, $40, $AA
    DB      $10, $0A, $62, $40, $AA, $10, $0A, $62
    DB      $40, $BE, $10, $04, $62, $40, $D7, $10
    DB      $04, $62, $40, $BE, $10, $0A, $62, $40
    DB      $97, $10, $0A, $62, $40, $97, $10, $0A
    DB      $62, $40, $AA, $10, $04, $62, $40, $97
    DB      $10, $04, $62, $40, $8F, $10, $0A, $62
    DB      $40, $AA, $10, $0A, $62, $40, $BE, $10
    DB      $16, $62, $50, $A2, $80, $3B, $22, $0A
    DB      $A2, $80, $C5, $21, $0A, $A2, $80, $7D
    DB      $21, $0A, $AE, $80, $FC, $21, $0A, $A2
    DB      $80, $AC, $21, $0A, $A2, $80, $53, $21
    DB      $0A, $AE, $80, $2E, $21, $0A, $A2, $80
    DB      $7D, $21, $0A, $A2, $80, $53, $21, $0A
    DB      $A2, $80, $2E, $21, $0A, $A2, $80, $1D
    DB      $21, $0A, $A2, $80, $53, $21, $0A, $A2
    DB      $80, $7D, $21, $0A, $AE, $90, $62, $40
    DB      $E2, $10, $1A, $62, $40, $D7, $10, $0C
    DB      $62, $40, $E2, $10, $0C, $62, $40, $FE
    DB      $10, $1A, $62, $40, $AA, $10, $0C, $62
    DB      $40, $BE, $10, $05, $62, $40, $D7, $10
    DB      $05, $62, $40, $E2, $10, $0C, $62, $40
    DB      $BE, $10, $0C, $62, $40, $AA, $10, $0C
    DB      $62, $40, $97, $10, $0C, $62, $40, $8F
    DB      $10, $08, $40, $BE, $10, $04, $62, $40
    DB      $97, $10, $0C, $62, $40, $8F, $10, $1A
    DB      $62, $50, $A2, $80, $C5, $21, $0C, $A2
    DB      $80, $3B, $22, $0C, $A2, $80, $FC, $21
    DB      $0C, $A2, $80, $C5, $21, $0C, $A2, $80
    DB      $AC, $21, $0C, $A2, $80, $AC, $21, $0C
    DB      $A2, $80, $AC, $21, $0C, $A2, $80, $AC
    DB      $21, $0C, $A2, $80, $C5, $21, $0C, $A2
    DB      $80, $C5, $21, $0C, $A2, $80, $FC, $21
    DB      $0C, $A2, $80, $FC, $21, $0C, $A2, $80
    DB      $3B, $22, $0C, $AC, $90, $62, $40, $40
    DB      $11, $07, $62, $40, $FE, $10, $07, $62
    DB      $40, $D7, $10, $07, $62, $40, $A0, $10
    DB      $07, $62, $40, $D7, $10, $07, $62, $40
    DB      $FE, $10, $07, $62, $40, $40, $11, $07
    DB      $62, $40, $FE, $10, $07, $62, $40, $D7
    DB      $10, $07, $62, $40, $A0, $10, $09, $62
    DB      $50, $A6, $80, $40, $31, $07, $A2, $80
    DB      $40, $31, $07, $A2, $80, $40, $31, $07
    DB      $A2, $80, $40, $31, $07, $A2, $80, $40
    DB      $31, $07, $A2, $80, $40, $31, $07, $A2
    DB      $80, $40, $31, $07, $A2, $80, $40, $31
    DB      $07, $A2, $80, $40, $31, $07, $A2, $80
    DB      $40, $31, $05, $A2, $90, $C0, $57, $23
    DB      $04, $E2, $C0, $CF, $22, $04, $E2, $C0
    DB      $57, $23, $05, $E2, $C0, $CF, $22, $05
    DB      $E2, $D0, $C0, $74, $10, $01, $C0, $69
    DB      $10, $01, $C0, $5F, $10, $01, $C0, $56
    DB      $10, $01, $C0, $4E, $10, $01, $C0, $46
    DB      $10, $01, $C0, $40, $10, $01, $C0, $46
    DB      $10, $01, $D0, $E1, $C0, $6B, $20, $02
    DB      $E1, $C0, $71, $20, $02, $E1, $C0, $78
    DB      $20, $02, $E1, $C0, $7F, $20, $02, $E1
    DB      $C0, $87, $20, $02, $E1, $C0, $8F, $20
    DB      $02, $E1, $C0, $97, $20, $02, $E1, $C0
    DB      $A0, $20, $02, $E1, $C0, $AA, $20, $02
    DB      $E1, $C0, $B4, $20, $02, $E1, $C0, $BE
    DB      $20, $02, $E1, $C0, $CA, $20, $02, $E1
    DB      $C0, $D7, $20, $02, $E1, $D0, $E2, $C0
    DB      $D7, $10, $05, $E2, $C0, $D7, $10, $05
    DB      $E2, $C0, $FE, $10, $05, $E2, $C0, $FE
    DB      $10, $05, $E2, $C0, $40, $11, $05, $E2
    DB      $C0, $40, $11, $05, $E2, $D0, $E2, $C0
    DB      $AC, $11, $04, $E2, $C0, $AC, $11, $04
    DB      $E2, $C0, $53, $11, $04, $E2, $C0, $1D
    DB      $11, $04, $E2, $D0, $C0, $56, $00, $05
    DB      $C0, $65, $00, $05, $C0, $56, $00, $05
    DB      $C0, $65, $00, $05, $C0, $56, $20, $05
    DB      $C0, $65, $20, $05, $C0, $56, $50, $05
    DB      $C0, $65, $50, $05, $C0, $56, $90, $05
    DB      $C0, $65, $90, $05, $C0, $56, $D0, $05
    DB      $C0, $65, $D0, $05, $D0, $00, $00, $04
    DB      $05, $22, $00, $00, $24, $05, $22, $00
    DB      $00, $44, $05, $22, $00, $00, $64, $05
    DB      $10, $00, $00, $02, $05, $10, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $1C, $1C
    DB      $1E, $12, $12, $13, $10, $10, $38, $28
    DB      $69, $49, $C9, $8B, $0B, $0A, $FB, $8B
    DB      $88, $08, $08, $08, $F8, $18, $FF, $FF
    DB      $41, $41, $41, $41, $41, $41, $EF, $EC
    DB      $0C, $1F, $10, $10, $10, $10, $D0, $10
    DB      $10, $D0, $10, $10, $10, $1F, $7E, $60
    DB      $60, $FE, $80, $80, $80, $80, $40, $40
    DB      $40, $41, $41, $41, $41, $7D, $FD, $C1
    DB      $C1, $FD, $01, $01, $01, $01, $FB, $FB
    DB      $00, $00, $00, $00, $00, $00, $FB, $FA
    DB      $42, $42, $43, $43, $42, $42, $F9, $09
    DB      $09, $09, $F9, $FD, $05, $05, $FD, $05
    DB      $05, $05, $05, $05, $05, $05, $FC, $FC
    DB      $04, $04, $04, $04, $04, $04, $9F, $9F
    DB      $90, $90, $90, $90, $90, $90, $BF, $B0
    DB      $30, $30, $3F, $01, $01, $01, $9D, $09
    DB      $09, $00, $80, $80, $80, $80, $B0, $F0
    DB      $50, $00, $00, $00, $00, $00, $10, $10
    DB      $00, $00, $00, $00, $00, $00, $0C, $0C
    DB      $00, $00, $00, $00, $00, $00, $18, $18
    DB      $00, $00, $00, $00, $00, $00, $41, $41
    DB      $00, $00, $00, $00, $00, $00, $1F, $1F
    DB      $00, $00, $00, $00, $00, $00, $DF, $DF
    DB      $00, $00, $00, $00, $00, $00, $80, $FE
    DB      $00, $00, $00, $00, $00, $00, $7D, $7D
    DB      $00, $00, $00, $00, $00, $00, $01, $FD
    DB      $00, $00, $00, $00, $00, $00, $F8, $F8
    DB      $00, $00, $00, $00, $00, $00, $42, $42
    DB      $00, $00, $00, $00, $00, $00, $05, $05
    DB      $00, $00, $00, $00, $00, $00, $FD, $FD
    DB      $00, $00, $00, $00, $00, $00, $05, $05
    DB      $00, $00, $00, $00, $00, $00, $DF, $DF
    DB      $00, $00, $00, $00, $00, $00, $81, $BF
    DB      $00, $00, $00, $00, $00, $00, $80, $80
    DB      $00, $00, $00, $00, $00, $00, $0F, $38
    DB      $60, $47, $CC, $88, $88, $88, $80, $E0
    DB      $30, $10, $98, $08, $08, $08, $00, $00
    DB      $39, $39, $09, $09, $09, $09, $00, $00
    DB      $F1, $F1, $11, $11, $11, $F3, $00, $00
    DB      $F3, $10, $10, $10, $10, $F1, $00, $00
    DB      $E0, $20, $20, $20, $20, $F0, $8C, $C7
    DB      $40, $60, $38, $0F, $00, $00, $88, $18
    DB      $10, $30, $E0, $80, $00, $00, $08, $08
    DB      $08, $3E, $3E, $00, $00, $00, $12, $12
    DB      $12, $13, $13, $00, $00, $00, $10, $10
    DB      $10, $F3, $F3, $00, $00, $00, $10, $10
    DB      $10, $F0, $F0, $00, $00, $00, $FF, $FE
    DB      $FE, $FC, $FC, $F8, $F8, $F0, $00, $3F
    DB      $70, $40, $03, $07, $0F, $0F, $03, $00
    DB      $00, $00, $80, $C0, $E0, $E0, $FF, $FF
    DB      $7F, $3F, $3F, $1F, $1F, $1F, $FF, $FF
    DB      $FE, $F8, $F0, $F0, $E0, $E0, $FF, $C0
    DB      $00, $7F, $E0, $C0, $0E, $1F, $FF, $3E
    DB      $1C, $08, $00, $00, $00, $00, $FF, $C0
    DB      $80, $3F, $30, $00, $80, $C0, $FF, $00
    DB      $00, $00, $00, $00, $00, $00, $FF, $00
    DB      $00, $00, $00, $00, $00, $00, $FF, $00
    DB      $00, $00, $00, $00, $00, $00, $FF, $07
    DB      $03, $01, $01, $01, $03, $07, $F0, $E0
    DB      $E0, $C0, $C0, $80, $80, $00, $0F, $07
    DB      $03, $00, $00, $00, $00, $00, $E0, $C0
    DB      $80, $00, $00, $00, $00, $01, $1F, $1F
    DB      $1F, $3F, $47, $43, $83, $83, $FF, $FF
    DB      $FF, $FF, $F1, $E0, $E0, $E0, $FF, $FF
    DB      $FF, $FF, $FF, $FE, $7E, $7E, $FF, $FF
    DB      $FF, $FF, $0F, $07, $0C, $00, $E0, $C0
    DB      $C0, $F8, $86, $01, $00, $00, $3F, $3F
    DB      $3F, $1F, $0E, $00, $80, $80, $80, $80
    DB      $80, $00, $00, $00, $01, $01, $FF, $FF
    DB      $FF, $FF, $FF, $FE, $F8, $F0, $FF, $FF
    DB      $FF, $FF, $C1, $3C, $F0, $80, $FF, $FF
    DB      $FF, $FF, $F0, $60, $20, $10, $FF, $FF
    DB      $FF, $FF, $7F, $3E, $18, $10, $FF, $FF
    DB      $FF, $FF, $FF, $07, $03, $01, $FE, $FC
    DB      $FC, $F8, $F8, $F0, $F0, $E0, $01, $03
    DB      $03, $07, $07, $3F, $47, $83, $FF, $FF
    DB      $FF, $FF, $E1, $C0, $80, $80, $FF, $FF
    DB      $FF, $FF, $F0, $C0, $80, $80, $FF, $FF
    DB      $FF, $FF, $78, $70, $20, $20, $FF, $FF
    DB      $FF, $FF, $7F, $3C, $38, $30, $FF, $FF
    DB      $FF, $FF, $07, $01, $F8, $E0, $FF, $FE
    DB      $FE, $FC, $FC, $F8, $F8, $F0, $00, $00
    DB      $00, $00, $00, $00, $00, $0F, $00, $00
    DB      $00, $00, $00, $00, $00, $FF, $03, $01
    DB      $00, $00, $00, $00, $00, $C0, $03, $03
    DB      $83, $43, $23, $23, $13, $13, $E0, $E0
    DB      $E0, $E0, $F0, $F0, $F0, $F0, $7C, $7C
    DB      $78, $78, $70, $70, $20, $20, $00, $00
    DB      $00, $00, $03, $0F, $1F, $1F, $00, $00
    DB      $00, $80, $C1, $FF, $FF, $E0, $80, $80
    DB      $80, $80, $00, $80, $07, $00, $01, $03
    DB      $03, $07, $0F, $3F, $FE, $3E, $E0, $C0
    DB      $80, $80, $00, $01, $03, $00, $00, $00
    DB      $1C, $7E, $FF, $FF, $FF, $01, $08, $08
    DB      $04, $04, $04, $88, $F0, $F0, $00, $00
    DB      $00, $00, $02, $03, $07, $0F, $01, $01
    DB      $01, $01, $03, $07, $FF, $FE, $E1, $C1
    DB      $C1, $81, $81, $01, $00, $00, $03, $03
    DB      $01, $01, $01, $00, $80, $80, $FF, $FF
    DB      $FE, $FE, $FC, $FC, $F8, $F8, $00, $00
    DB      $00, $00, $01, $01, $03, $02, $00, $00
    DB      $00, $00, $00, $00, $00, $01, $00, $00
    DB      $00, $00, $00, $80, $80, $00, $30, $20
    DB      $20, $20, $41, $41, $81, $80, $00, $00
    DB      $01, $FF, $FF, $FF, $FF, $00, $F0, $E0
    DB      $E0, $C0, $C0, $80, $80, $00, $1F, $3F
    DB      $7F, $7F, $7F, $7F, $7F, $7F, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $E0, $F0
    DB      $F8, $F8, $F8, $F8, $F8, $F8, $09, $09
    DB      $09, $09, $09, $09, $10, $10, $F0, $F0
    DB      $F0, $F8, $F8, $F8, $F8, $F8, $20, $20
    DB      $20, $20, $10, $10, $10, $10, $1F, $3F
    DB      $3F, $7E, $7E, $FC, $FC, $FC, $80, $00
    DB      $00, $00, $00, $01, $07, $07, $00, $00
    DB      $00, $00, $00, $FF, $FF, $FF, $02, $01
    DB      $01, $00, $00, $80, $E0, $E0, $00, $00
    DB      $00, $80, $80, $47, $47, $43, $00, $00
    DB      $00, $00, $01, $FF, $FF, $FF, $F0, $F8
    DB      $F8, $F8, $F8, $F8, $FC, $FC, $1F, $1F
    DB      $0F, $0F, $0F, $07, $07, $07, $FE, $FC
    DB      $FC, $F8, $F8, $F0, $F0, $E0, $01, $03
    DB      $03, $07, $07, $0F, $0F, $1F, $C0, $C0
    DB      $C0, $E0, $E0, $E0, $F0, $F0, $70, $70
    DB      $60, $20, $20, $20, $10, $10, $06, $0C
    DB      $0C, $18, $18, $30, $30, $60, $01, $03
    DB      $02, $06, $04, $0C, $0C, $18, $00, $01
    DB      $01, $03, $03, $07, $07, $0F, $80, $00
    DB      $00, $00, $00, $03, $03, $01, $00, $00
    DB      $00, $00, $00, $FF, $FF, $FF, $7F, $3F
    DB      $3F, $3F, $7F, $FF, $FF, $FF, $FF, $FE
    DB      $FE, $FC, $FC, $F8, $F8, $F0, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $1F, $0F
    DB      $00, $00, $00, $00, $00, $00, $FF, $FF
    DB      $00, $00, $00, $00, $00, $00, $E0, $C0
    DB      $00, $00, $01, $03, $0F, $FF, $20, $20
    DB      $40, $80, $C0, $E0, $F0, $F8, $F8, $70
    DB      $00, $00, $00, $00, $00, $00, $11, $11
    DB      $11, $13, $23, $23, $47, $E7, $FC, $FC
    DB      $FC, $FE, $FF, $FF, $FF, $FF, $01, $00
    DB      $00, $00, $00, $80, $E0, $F8, $FF, $00
    DB      $00, $00, $00, $00, $00, $00, $80, $00
    DB      $00, $00, $00, $01, $07, $1F, $40, $40
    DB      $40, $80, $80, $80, $C0, $F0, $FF, $1F
    DB      $0F, $07, $07, $07, $07, $0F, $FC, $FE
    DB      $FE, $FE, $FF, $FF, $FF, $FF, $03, $03
    DB      $03, $01, $01, $01, $81, $83, $E0, $C0
    DB      $C0, $80, $80, $80, $80, $C1, $1F, $3F
    DB      $3F, $7F, $7F, $FF, $FF, $FF, $F0, $F8
    DB      $F8, $F8, $FC, $FC, $FC, $FE, $10, $08
    DB      $08, $08, $04, $05, $05, $0B, $60, $60
    DB      $C0, $C0, $C0, $C0, $C0, $E1, $18, $38
    DB      $30, $70, $70, $F0, $F0, $F8, $0F, $1F
    DB      $1F, $3F, $3F, $7F, $7F, $FF, $00, $80
    DB      $80, $C0, $C0, $E0, $F0, $FE, $7F, $00
    DB      $00, $00, $00, $00, $00, $00, $FF, $1F
    DB      $0F, $0F, $0F, $1F, $3F, $FF, $FF, $FF
    DB      $FF, $00, $00, $00, $FF, $FF, $11, $11
    DB      $11, $11, $11, $11, $11, $11, $19, $19
    DB      $19, $19, $19, $19, $19, $19, $19, $F9
    DB      $F9, $F9, $19, $19, $19, $19, $19, $19
    DB      $19, $F9, $F9, $F9, $19, $19, $19, $19
    DB      $19, $19, $19, $F9, $F9, $F9, $19, $19
    DB      $19, $19, $19, $19, $F9, $F9, $B9, $B9
    DB      $B9, $B9, $B9, $B9, $B9, $B9, $B9, $B9
    DB      $29, $29, $69, $69, $69, $B9, $21, $21
    DB      $21, $21, $21, $21, $21, $21, $1B, $1B
    DB      $1B, $1B, $1B, $1B, $1B, $1B, $19, $19
    DB      $B9, $B9, $B9, $B9, $B9, $B9, $B9, $B9
    DB      $B9, $B9, $19, $19, $19, $19, $01, $09
    DB      $09, $09, $09, $09, $09, $09, $09, $09
    DB      $09, $09, $09, $09, $09, $09, $09, $09
    DB      $09, $09, $09, $09, $09, $09, $09, $09
    DB      $09, $09, $09, $09, $09, $09, $09, $09
    DB      $09, $09, $09, $09, $09, $09, $09, $09
    DB      $09, $09, $09, $09, $09, $09, $02, $03
    DB      $02, $02, $02, $04, $02, $04, $02, $02
    DB      $02, $02, $02, $02, $02, $02, $02, $02
    DB      $02, $02, $02, $02, $02, $05, $02, $02
    DB      $02, $02, $02, $02, $02, $02, $02, $06
    DB      $02, $07, $07, $0B, $02, $02, $02, $02
    DB      $02, $02, $02, $02, $02, $02, $02, $02
    DB      $02, $02, $02, $02, $02, $02, $02, $02
    DB      $02, $08, $08, $08, $02, $02, $02, $02
    DB      $02, $02, $02, $02, $02, $02, $02, $02
    DB      $02, $02, $02, $02, $02, $02, $02, $02
    DB      $02, $02, $02, $07, $07, $0C, $02, $02
    DB      $02, $02, $02, $02, $02, $02, $02, $02
    DB      $02, $02, $02, $02, $02, $02, $02, $02
    DB      $02, $02, $02, $0A, $00, $06, $04, $03
    DB      $03, $04, $05, $0D, $11, $01, $05, $08
    DB      $18, $08, $19, $06, $1A, $02, $00, $08
    DB      $06, $01, $0C, $0D, $06, $01, $0B, $00
    DB      $0F, $06, $1A, $06, $00, $16, $00, $01
    DB      $3E, $A7, $21, $00, $18, $CD, $7B, $A7
    DB      $16, $2F, $01, $2C, $A7, $21, $60, $18
    DB      $CD, $7B, $A7, $16, $23, $01, $47, $A7
    DB      $21, $80, $1A, $CD, $7B, $A7, $16, $9D
    DB      $06, $1A, $21, $04, $19, $CD, $8B, $9C
    DB      $23, $10, $FA, $C9, $1E, $00, $0A, $B7
    DB      $C8, $C5, $47, $7B, $CB, $2F, $38, $05
    DB      $23, $10, $FD, $18, $07, $14, $CD, $8B
    DB      $9C, $23, $10, $F9, $C1, $1C, $03, $18
    DB      $E5, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $A4, $49, $B6, $54, $22, $58, $00
    DB      $10, $00, $04, $20, $00, $00, $00, $00
    DB      $00, $50, $90, $60, $30, $00, $10, $00
    DB      $40, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $10, $00, $04, $20, $00, $44, $10, $EE
    DB      $F7, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $30, $C0
    DB      $D0, $00, $00, $0F, $1F, $17, $1B, $1F
    DB      $0F, $07, $03, $07, $0D, $0B, $0F, $06
    DB      $03, $00, $00, $00, $C0, $A8, $B0, $F0
    DB      $F8, $F8, $F8, $F8, $F0, $F0, $E0, $C0
    DB      $80, $00, $00, $01, $07, $0F, $1F, $1F
    DB      $3F, $3F, $3F, $37, $1F, $1B, $0D, $06
    DB      $01, $00, $00, $E0, $F0, $D4, $D4, $F0
    DB      $60, $C0, $80, $C0, $E0, $F0, $F0, $E0
    DB      $C0, $00, $00, $03, $07, $0B, $0B, $0F
    DB      $07, $02, $01, $03, $07, $0D, $0B, $0C
    DB      $07, $00, $00, $80, $E0, $70, $78, $F8
    DB      $BC, $7C, $FC, $FC, $F8, $F0, $F0, $E0
    DB      $80, $00, $00, $01, $07, $0E, $1E, $1F
    DB      $3D, $3E, $37, $3F, $1B, $1D, $0E, $07
    DB      $01, $00, $00, $C0, $E0, $D0, $D0, $F0
    DB      $E0, $40, $80, $C0, $E0, $F0, $D0, $30
    DB      $E0, $00, $00, $00, $03, $15, $0D, $0F
    DB      $1F, $1F, $1F, $1B, $0F, $0D, $06, $03
    DB      $01, $00, $00, $F0, $F8, $F8, $F8, $F8
    DB      $F0, $E0, $C0, $E0, $F0, $F0, $F0, $60
    DB      $C0, $00, $00, $07, $0F, $2B, $2B, $0F
    DB      $06, $03, $01, $03, $07, $0D, $0D, $06
    DB      $03, $00, $00, $80, $E0, $F0, $F8, $F8
    DB      $FC, $FC, $FC, $FC, $F8, $F8, $F0, $E0
    DB      $80, $00, $00, $03, $07, $0F, $0F, $0D
    DB      $06, $03, $01, $03, $07, $0F, $0B, $0C
    DB      $07, $00, $00, $80, $E0, $F0, $F8, $F8
    DB      $FC, $7C, $FC, $FC, $F8, $F8, $F0, $E0
    DB      $80, $00, $00, $01, $07, $0F, $1F, $1F
    DB      $3F, $3F, $37, $3F, $1F, $1D, $0E, $07
    DB      $01, $00, $00, $C0, $E0, $F0, $F0, $F0
    DB      $E0, $40, $80, $C0, $E0, $F0, $D0, $30
    DB      $E0, $00, $00, $03, $07, $05, $07, $06
    DB      $03, $01, $01, $01, $03, $06, $05, $06
    DB      $03, $00, $00, $C4, $E0, $F3, $F4, $F8
    DB      $78, $F8, $F9, $F8, $F8, $F0, $F0, $E4
    DB      $C0, $00, $08, $03, $47, $2F, $0F, $1F
    DB      $1F, $1F, $97, $17, $1F, $0B, $2D, $06
    DB      $83, $00, $00, $C0, $E0, $E0, $E0, $E0
    DB      $C0, $80, $80, $80, $C0, $E0, $A0, $60
    DB      $C0, $06, $06, $06, $02, $02, $02, $02
    DB      $07, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $77, $77, $55, $55, $55, $55, $55
    DB      $77, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $0F, $0F, $08, $08, $0F, $03, $03
    DB      $0F, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $77, $77, $55, $55, $55, $55, $55
    DB      $77, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $67, $67, $25, $25, $25, $25, $25
    DB      $77, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $77, $77, $55, $55, $55, $55, $55
    DB      $77, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $F7, $F7, $15, $15, $F5, $85, $85
    DB      $F7, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $77, $77, $55, $55, $55, $55, $55
    DB      $77, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $D7, $D7, $D5, $D5, $F5, $15, $15
    DB      $17, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $77, $77, $55, $55, $55, $55, $55
    DB      $77, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $F7, $F7, $95, $95, $F5, $95, $95
    DB      $F7, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $77, $77, $55, $55, $55, $55, $55
    DB      $77, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $1E, $3B
    DB      $4D, $4F, $3F, $1E, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $80, $80, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $1E
    DB      $3B, $4D, $4F, $3F, $1E, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $80, $80, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $01, $01, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $78, $EC
    DB      $F2, $F2, $FC, $78, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $01, $01, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $78
    DB      $EC, $F2, $F2, $FC, $78, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $03, $07
    DB      $0E, $0E, $07, $03, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $C0, $60
    DB      $30, $70, $E0, $C0, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $03
    DB      $07, $0F, $0F, $06, $02, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $C0
    DB      $60, $B0, $F0, $60, $40, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $03, $07, $0F, $0C, $0F, $07, $03
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $C0, $60, $70, $10, $70, $60, $C0
    DB      $00, $00, $00, $00, $00, $00, $03, $07
    DB      $0F, $0C, $0F, $07, $03, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $C0, $60
    DB      $70, $10, $70, $60, $C0, $00, $00, $00
    DB      $00, $03, $0F, $1F, $AF, $AB, $7D, $7F
    DB      $7F, $7D, $3B, $3F, $1F, $0F, $03, $04
    DB      $3C, $C0, $F0, $F8, $FC, $DC, $BE, $FE
    DB      $FE, $BE, $DC, $FC, $FA, $F2, $C6, $3C
    DB      $00, $03, $0F, $1F, $3F, $3B, $7D, $7F
    DB      $7F, $7D, $3B, $3F, $5F, $4F, $63, $3C
    DB      $00, $C0, $F0, $F8, $F5, $D5, $BE, $FE
    DB      $FE, $BE, $DC, $FC, $F8, $F0, $C0, $20
    DB      $3C, $03, $0F, $1F, $3F, $3F, $7F, $7F
    DB      $7F, $7F, $3F, $3F, $5F, $4F, $63, $3C
    DB      $00, $C0, $F0, $F8, $FC, $FC, $FE, $FE
    DB      $FE, $FE, $FC, $FC, $F8, $F0, $C0, $20
    DB      $3C, $03, $0F, $1F, $3B, $3B, $7D, $7F
    DB      $7F, $7D, $3B, $3F, $5F, $4F, $63, $3C
    DB      $00, $C0, $F0, $F8, $DC, $DC, $BE, $FE
    DB      $FE, $BE, $DC, $FC, $F8, $F0, $C0, $20
    DB      $3C, $00, $10, $03, $8F, $1F, $3B, $3F
    DB      $7F, $6E, $7F, $3B, $3F, $9E, $CF, $63
    DB      $1C, $00, $08, $C2, $F0, $B8, $FD, $FC
    DB      $FE, $FE, $EE, $FC, $FC, $F9, $F3, $C6
    DB      $38, $00, $03, $4F, $1F, $3F, $AF, $7D
    DB      $5F, $7F, $2F, $3F, $1D, $0F, $03, $64
    DB      $78, $08, $C0, $72, $F8, $EC, $FC, $FE
    DB      $BA, $FE, $FC, $7C, $E8, $F0, $C0, $26
    DB      $1E, $00, $00, $00, $00, $00, $00, $7F
    DB      $7F, $7F, $00, $00, $00, $00, $04, $04
    DB      $3C, $00, $00, $00, $00, $00, $00, $FE
    DB      $FE, $FE, $00, $02, $02, $06, $3C, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $7F
    DB      $7F, $7F, $00, $00, $40, $40, $60, $3C
    DB      $00, $00, $00, $00, $00, $00, $00, $FE
    DB      $FE, $FE, $00, $00, $00, $00, $00, $20
    DB      $3C, $CF, $CF, $48, $48, $4F, $43, $43
    DB      $EF, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $77, $77, $55, $55, $55, $55, $55
    DB      $77, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $0F, $0F, $01, $01, $0F, $08, $08
    DB      $0F, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $77, $77, $55, $55, $55, $55, $55
    DB      $77, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $0F, $0F, $01, $01, $07, $01, $01
    DB      $0F, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $77, $77, $55, $55, $55, $55, $55
    DB      $77, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $03, $0F, $3F, $3F, $79
    DB      $7F, $39, $3F, $0F, $43, $40, $60, $3C
    DB      $00, $00, $00, $C0, $F0, $FC, $FC, $9E
    DB      $FE, $9C, $FC, $F0, $C0, $00, $00, $20
    DB      $3C, $00, $00, $03, $0F, $3F, $3F, $79
    DB      $7F, $39, $3F, $0F, $03, $00, $04, $04
    DB      $3C, $00, $00, $C0, $F0, $FC, $FC, $9E
    DB      $FE, $9C, $FC, $F2, $C2, $06, $3C, $00
    DB      $00, $00, $00, $03, $0F, $3F, $3F, $7F
    DB      $7F, $3F, $3F, $0F, $03, $00, $00, $04
    DB      $3C, $00, $00, $C0, $F0, $FC, $FC, $FE
    DB      $FE, $FC, $FC, $F0, $C2, $02, $06, $3C
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $01, $03, $07, $0F, $1F, $61, $C4
    DB      $82, $80, $80, $40, $21, $3F, $1F, $08
    DB      $70, $F0, $F8, $B8, $DC, $FC, $FE, $FF
    DB      $7F, $7F, $7F, $FE, $FE, $FC, $E0, $38
    DB      $08, $0F, $1F, $3E, $3F, $7F, $7F, $E1
    DB      $C4, $82, $80, $80, $40, $61, $1F, $01
    DB      $07, $80, $C0, $E0, $60, $F0, $B8, $DC
    DB      $FF, $7F, $7E, $7C, $F8, $F0, $E0, $80
    DB      $80, $0F, $1F, $1F, $3F, $3F, $7F, $FF
    DB      $FE, $FE, $FE, $7F, $7F, $3F, $07, $1C
    DB      $10, $80, $C0, $E0, $F0, $F8, $86, $13
    DB      $01, $01, $01, $02, $84, $FC, $F8, $10
    DB      $0E, $03, $03, $07, $07, $0F, $1D, $3F
    DB      $EF, $DE, $7E, $3E, $1F, $0F, $07, $01
    DB      $01, $F0, $F8, $FC, $FC, $FE, $FE, $87
    DB      $13, $01, $01, $01, $02, $86, $F8, $80
    DB      $E0, $01, $03, $0F, $1F, $1F, $3F, $7F
    DB      $FF, $FB, $7F, $3D, $1F, $1F, $0F, $06
    DB      $1C, $C0, $E0, $F0, $F8, $F8, $FC, $FE
    DB      $FF, $FF, $FF, $7F, $FE, $F8, $F0, $3C
    DB      $00, $00, $07, $0F, $0F, $1F, $3F, $7F
    DB      $77, $FF, $FB, $FF, $7E, $3F, $1F, $3C
    DB      $00, $00, $E0, $F0, $F8, $F8, $FC, $FC
    DB      $FE, $FF, $FF, $FF, $FE, $FC, $F8, $60
    DB      $38, $03, $07, $0E, $1F, $1F, $3C, $78
    DB      $F0, $F0, $F0, $F8, $7C, $1F, $0F, $3C
    DB      $00, $00, $C0, $F0, $B8, $D8, $3C, $9E
    DB      $4F, $0F, $0E, $1C, $38, $F8, $F0, $60
    DB      $38, $00, $07, $0F, $1F, $1F, $3F, $3C
    DB      $78, $F0, $F0, $F0, $78, $3C, $1F, $06
    DB      $3C, $00, $E0, $F0, $70, $D8, $EC, $3E
    DB      $9E, $4F, $0F, $0F, $1E, $3C, $F8, $3C
    DB      $00, $00, $00, $20, $07, $0D, $9F, $17
    DB      $3F, $3C, $78, $F0, $B3, $F0, $78, $BC
    DB      $5F, $00, $10, $00, $E4, $F0, $71, $D8
    DB      $EC, $3E, $9E, $8F, $EF, $8B, $9E, $3C
    DB      $F8, $84, $53, $06, $8F, $3F, $1C, $78
    DB      $F0, $F3, $F0, $78, $7C, $1F, $4F, $8C
    DB      $3C, $01, $C3, $F4, $B0, $D8, $3A, $9C
    DB      $8F, $EF, $8E, $9C, $38, $FA, $F0, $31
    DB      $3C, $66, $1C, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $40, $40, $3C, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $02, $02, $3C, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $66, $38, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $06, $0C, $F8, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $C6, $78, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $63, $1E, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $60, $30, $1F, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $C6, $6C, $18, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $C6, $6C, $30, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $06, $0C, $F8, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $C0, $60, $3E, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $FF, $FF
    DB      $00, $00, $00, $00, $00, $00, $FF, $FF
    DB      $00, $00, $00, $00, $0F, $0F, $F0, $00
    DB      $F0, $00, $F0, $00, $0F, $0F, $F0, $00
    DB      $F0, $00, $0F, $00, $F0, $F0, $0F, $00
    DB      $0F, $FF, $00, $00, $00, $FF, $FF, $FF
    DB      $00, $00, $00, $00, $00, $00, $FF, $FF
    DB      $00, $00, $F0, $00, $F0, $00, $F0, $00
    DB      $F0, $00, $0F, $00, $0F, $00, $0F, $00
    DB      $0F, $FF, $00, $00, $00, $FF, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $C0, $C0
    DB      $00, $00, $00, $00, $00, $00, $03, $03
    DB      $00, $FF, $00, $00, $00, $FF, $FF, $FF
    DB      $00, $00, $F0, $00, $0F, $0F, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $80
    DB      $7F, $00, $00, $00, $00, $00, $00, $00
    DB      $FF, $00, $00, $00, $00, $00, $00, $01
    DB      $FE, $0F, $37, $7D, $EF, $BA, $E9, $00
    DB      $00, $BD, $76, $DF, $FB, $AA, $04, $00
    DB      $00, $D0, $FC, $BE, $F7, $AA, $44, $00
    DB      $00, $00, $0F, $37, $7D, $EF, $BA, $E9
    DB      $00, $00, $BD, $76, $DF, $FB, $AA, $04
    DB      $00, $00, $D0, $FC, $BE, $F7, $55, $44
    DB      $00, $00, $00, $0F, $37, $7D, $EF, $BA
    DB      $E9, $00, $00, $BD, $76, $DF, $FB, $AA
    DB      $04, $00, $00, $D0, $FC, $BE, $F7, $AA
    DB      $44, $3F, $F6, $DF, $AE, $D5, $29, $00
    DB      $00, $FF, $DC, $F3, $AE, $15, $BB, $00
    DB      $00, $FC, $B9, $EE, $BB, $55, $AE, $00
    DB      $00, $00, $3F, $F6, $DF, $AE, $D5, $29
    DB      $00, $00, $FF, $DC, $F3, $AE, $15, $BB
    DB      $00, $00, $FC, $B9, $EE, $BB, $55, $AE
    DB      $00, $00, $00, $3F, $F6, $DF, $AE, $D5
    DB      $29, $00, $00, $FF, $DC, $F3, $AE, $15
    DB      $BB, $00, $00, $FC, $B9, $EE, $BB, $55
    DB      $AE, $7F, $E1, $DF, $C7, $C1, $7F, $00
    DB      $00, $FF, $9A, $FF, $FF, $15, $FF, $00
    DB      $00, $FE, $07, $E3, $FB, $D7, $FE, $00
    DB      $00, $00, $7F, $E1, $DF, $C7, $C1, $7F
    DB      $00, $00, $FF, $9A, $FF, $FF, $15, $FF
    DB      $00, $00, $FE, $07, $E3, $FB, $D7, $FE
    DB      $00, $00, $00, $7F, $E1

; ============================================================
; GAME DATA  ($B054 - $BBFF)
; Animation, sprite, level, and name-table data.
; (Tracer did not reach this area via static flow; kept as DB.)
; ============================================================
GAME_DATA:                                 ; GAME_DATA: level/map data block
    DB      $DF, $C7, $C1, $7F, $00, $00, $FF, $9A
    DB      $FF, $FF, $15, $FF, $00, $00, $FE, $07
    DB      $E3, $FB, $D7, $FE, $7F, $FF, $DF, $CF
    DB      $E5, $7F, $00, $00, $FF, $3C, $FF, $FF
    DB      $FF, $FF, $00, $00, $FE, $E7, $F3, $FB
    DB      $57, $FE, $00, $00, $00, $7F, $FF, $DF
    DB      $CF, $E5, $7F, $00, $00, $FF, $3C, $FF
    DB      $FF, $FF, $FF, $00, $00, $FE, $E7, $F3
    DB      $FB, $57, $FE, $00, $00, $00, $7F, $FF
    DB      $DF, $CF, $E5, $7F, $00, $00, $FF, $3C
    DB      $FF, $FF, $FF, $FF, $00, $00, $FE, $E7
    DB      $F3, $FB, $57, $FE, $2C, $75, $BB, $7D
    DB      $DB, $A0, $00, $00, $01, $42, $B6, $DF
    DB      $7E, $3A, $00, $00, $34, $AE, $BB, $7F
    DB      $2D, $06, $00, $00, $00, $2C, $75, $BB
    DB      $7D, $DB, $A0, $00, $00, $01, $42, $B6
    DB      $DF, $7E, $3A, $00, $00, $34, $AE, $BB
    DB      $7F, $2D, $06, $00, $00, $00, $2C, $75
    DB      $BB, $7D, $DB, $A0, $00, $00, $01, $42
    DB      $B6, $DF, $7E, $3A, $00, $00, $34, $AE
    DB      $BB, $7F, $2D, $06, $55, $55, $D5, $FF
    DB      $55, $2F, $00, $00, $55, $55, $55, $FF
    DB      $DF, $FF, $00, $00, $55, $55, $55, $FF
    DB      $FE, $FC, $00, $00, $00, $55, $55, $D5
    DB      $FF, $55, $2F, $00, $00, $55, $55, $55
    DB      $FF, $DF, $FF, $00, $00, $55, $55, $55
    DB      $FF, $FE, $FC, $00, $00, $00, $55, $55
    DB      $D5, $FF, $55, $2F, $00, $00, $55, $55
    DB      $55, $FF, $DF, $FF, $00, $00, $55, $55
    DB      $55, $FF, $FE, $FC, $55, $55, $D5, $FF
    DB      $55, $2F, $80, $7F, $55, $55, $55, $FF
    DB      $DF, $FF, $00, $FF, $55, $55, $55, $FF
    DB      $FE, $FC, $01, $FE, $20, $24, $2D, $BA
    DB      $54, $2C, $BB, $5E, $3C, $00, $FF, $E3
    DB      $6E, $66, $6E, $6E, $00, $38, $7E, $EF
    DB      $DF, $B7, $DF, $24, $FF, $3C, $5C, $38
    DB      $18, $28, $10, $10, $00, $00, $00, $00
    DB      $7C, $C6, $82, $82, $82, $C7, $FD, $7F
    DB      $38, $C7, $7E, $3C, $EF, $77, $7E, $3C
    DB      $3C, $3C, $18, $00, $38, $7C, $38, $7C
    DB      $54, $54, $38, $00, $7E, $FB, $F9, $7E
    DB      $5E, $FB, $7E, $00, $11, $77, $71, $47
    DB      $47, $47, $77, $44, $E1, $E1, $D1, $71
    DB      $71, $77, $47, $11, $60, $60, $80, $9F
    DB      $9A, $9B, $00, $00, $00, $60, $60, $80
    DB      $9F, $9A, $9B, $00, $00, $00, $60, $60
    DB      $80, $9F, $9A, $9B, $90, $69, $69, $61
    DB      $61, $61, $00, $00, $00, $90, $69, $69
    DB      $61, $61, $61, $00, $00, $00, $90, $69
    DB      $69, $61, $61, $61, $B0, $AF, $AF, $AF
    DB      $A9, $A0, $00, $00, $00, $B0, $AF, $AF
    DB      $AF, $A9, $A0, $00, $00, $00, $B0, $AF
    DB      $AF, $AF, $A9, $A0, $90, $8F, $8F, $8F
    DB      $8F, $60, $00, $00, $30, $39, $80, $80
    DB      $80, $66, $00, $00, $00, $90, $8F, $8F
    DB      $8F, $8F, $60, $00, $00, $30, $39, $80
    DB      $80, $80, $66, $00, $00, $00, $90, $8F
    DB      $8F, $8F, $8F, $60, $00, $00, $30, $39
    DB      $80, $80, $80, $66, $30, $30, $3E, $20
    DB      $20, $C0, $00, $00, $00, $30, $30, $3E
    DB      $20, $20, $C0, $00, $00, $00, $30, $30
    DB      $3E, $20, $20, $C0, $FA, $9A, $69, $60
    DB      $60, $60, $F0, $F0, $00, $FA, $9A, $69
    DB      $60, $60, $60, $00, $00, $00, $FA, $9A
    DB      $69, $60, $60, $60, $B0, $AF, $AF, $AF
    DB      $AF, $A0, $00, $00, $00, $B0, $AF, $AF
    DB      $AF, $AF, $A0, $00, $00, $00, $B0, $AF
    DB      $AF, $AF, $AF, $A0, $00, $00, $00, $00
    DB      $00, $00, $F0, $F0, $11, $F1, $F1, $F1
    DB      $F8, $F5, $FB, $F1, $A1, $A1, $A1, $A1
    DB      $A1, $A1, $A1, $A1, $11, $11, $11, $11
    DB      $F1, $F1, $F1, $B1, $F1, $F1, $F1, $F1
    DB      $F1, $F1, $FB, $B1, $B1, $B1, $B1, $B1
    DB      $B1, $B1, $B1, $B1, $BF, $FF, $81, $81
    DB      $81, $81, $81, $81, $F1, $F1, $F1, $F1
    DB      $A1, $A1, $A1, $11, $A1, $81, $81, $81
    DB      $81, $81, $81, $11, $60, $9F, $AF, $60
    DB      $60, $AF, $60, $00, $19, $19, $19, $00
    DB      $01, $01, $01, $02, $02, $02, $03, $03
    DB      $03, $04, $04, $04, $05, $05, $05, $06
    DB      $06, $06, $07, $07, $16, $08, $08, $17
    DB      $09, $09, $18, $0A, $0B, $0A, $0C, $0D
    DB      $0C, $0E, $0F, $0E, $10, $10, $10, $11
    DB      $11, $11, $12, $12, $12, $13, $13, $13
    DB      $14, $14, $14, $15, $15, $15, $13, $13
    DB      $13, $1E, $1F, $1A, $1B, $1C, $1D, $20
    DB      $21, $22, $00, $0C, $17, $77, $17, $17
    DB      $17, $77, $17, $77, $1B, $00, $A0, $00
    DB      $A0, $A0, $A0, $00, $A0, $00, $A0, $00
    DB      $A0, $00, $A0, $A0, $A0, $00, $A0, $00
    DB      $A0, $0C, $D7, $17, $6B, $AC, $67, $17
    DB      $67, $77, $6B, $00, $00, $A0, $A0, $A0
    DB      $A0, $A0, $A0, $00, $A0, $00, $00, $AC
    DB      $67, $D7, $6B, $A0, $A0, $00, $A0, $00
    DB      $00, $A0, $A0, $00, $A0, $A0, $A0, $00
    DB      $A0, $0C, $17, $67, $6B, $00, $A0, $AC
    DB      $67, $17, $DB, $00, $A0, $A0, $A0, $00
    DB      $A0, $A0, $A0, $A0, $00, $00, $A0, $AC
    DB      $67, $77, $67, $D7, $6B, $A0, $00, $00
    DB      $A0, $A0, $A0, $00, $A0, $00, $A0, $A0
    DB      $00, $00, $A0, $A0, $A0, $00, $A0, $0C
    DB      $67, $67, $1B, $00, $A0, $A0, $A0, $00
    DB      $A0, $00, $A0, $A0, $A0, $0C, $67, $D7
    DB      $67, $77, $67, $77, $6B, $A0, $A0, $00
    DB      $A0, $00, $A0, $00, $A0, $00, $A0, $A0
    DB      $A0, $00, $A0, $00, $A0, $00, $A0, $00
    DB      $A0, $A0, $A0, $0C, $D7, $77, $D7, $77
    DB      $D7, $77, $D7, $D7, $DB, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $0C, $17, $17
    DB      $17, $17, $17, $17, $17, $17, $1B, $00
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0
    DB      $A0, $0C, $67, $67, $67, $67, $6B, $A0
    DB      $A0, $A0, $A0, $00, $A0, $A0, $A0, $A0
    DB      $A0, $A0, $A0, $A0, $A0, $0C, $67, $67
    DB      $6B, $AC, $67, $67, $67, $67, $6B, $00
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0
    DB      $A0, $00, $A0, $AC, $67, $67, $6B, $AC
    DB      $67, $67, $6B, $00, $A0, $A0, $A0, $A0
    DB      $A0, $A0, $A0, $A0, $A0, $0C, $D7, $D7
    DB      $D7, $67, $67, $67, $D7, $D7, $DB, $00
    DB      $00, $00, $00, $A0, $A0, $A0, $00, $00
    DB      $00, $00, $00, $00, $00, $AC, $67, $62
    DB      $2B, $00, $00, $00, $00, $00, $00, $A0
    DB      $A0, $A0, $00, $00, $00, $00, $00, $0C
    DB      $22, $67, $6B, $A0, $00, $00, $00, $00
    DB      $00, $00, $00, $A0, $A0, $A0, $00, $00
    DB      $00, $00, $00, $00, $00, $AC, $67, $62
    DB      $2B, $00, $00, $00, $00, $00, $00, $A0
    DB      $A0, $A0, $00, $00, $00, $00, $00, $0C
    DB      $22, $D7, $67, $D2, $2B, $00, $00, $00
    DB      $00, $00, $00, $00, $A0, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $A0, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $0C
    DB      $DB, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $0C
    DB      $17, $77, $17, $17, $77, $17, $77, $77
    DB      $1B, $00, $A0, $00, $A0, $A0, $00, $A0
    DB      $00, $00, $A0, $0C, $67, $77, $67, $D7
    DB      $17, $D7, $17, $77, $6B, $00, $A0, $00
    DB      $A0, $00, $A0, $00, $A0, $00, $A0, $0C
    DB      $67, $77, $D7, $17, $6B, $0C, $67, $77
    DB      $6B, $00, $A0, $00, $00, $A0, $A0, $00
    DB      $A0, $00, $A0, $0C, $D7, $77, $17, $67
    DB      $67, $17, $D7, $77, $DB, $00, $00, $00
    DB      $A0, $A0, $A0, $A0, $00, $00, $00, $00
    DB      $00, $0C, $6B, $AC, $67, $D7, $1B, $00
    DB      $00, $00, $00, $00, $A0, $A0, $A0, $00
    DB      $A0, $00, $00, $00, $00, $0C, $67, $D7
    DB      $D7, $77, $6B, $00, $00, $00, $00, $00
    DB      $A0, $00, $00, $00, $A0, $00, $00, $0C
    DB      $17, $17, $6B, $00, $00, $0C, $67, $77
    DB      $1B, $00, $A0, $A0, $A0, $00, $00, $00
    DB      $A0, $00, $A0, $0C, $67, $67, $6B, $00
    DB      $00, $0C, $67, $17, $6B, $00, $A0, $A0
    DB      $A0, $00, $00, $00, $A0, $A0, $A0, $0C
    DB      $D7, $D7, $6B, $00, $00, $0C, $67, $D7
    DB      $DB, $00, $00, $00, $A0, $00, $00, $00
    DB      $A0, $00, $00, $00, $00, $0C, $67, $17
    DB      $77, $17, $6B, $00, $00, $00, $00, $00
    DB      $A0, $A0, $00, $A0, $A0, $00, $00, $00
    DB      $00, $0C, $D7, $D7, $77, $D7, $DB, $00
    DB      $00, $0C, $17, $77, $17, $77, $17, $77
    DB      $17, $77, $1B, $00, $A0, $00, $A0, $00
    DB      $A0, $00, $A0, $00, $A0, $0C, $D7, $17
    DB      $D7, $17, $D7, $17, $D7, $17, $DB, $00
    DB      $00, $A0, $00, $A0, $00, $A0, $00, $A0
    DB      $00, $0C, $17, $D7, $17, $D7, $17, $D7
    DB      $17, $D7, $1B, $00, $A0, $00, $A0, $00
    DB      $A0, $00, $A0, $00, $A0, $0C, $D7, $17
    DB      $D7, $17, $67, $17, $D7, $17, $DB, $00
    DB      $00, $A0, $00, $A0, $A0, $A0, $00, $A0
    DB      $00, $0C, $17, $D7, $17, $D7, $67, $D7
    DB      $17, $D7, $1B, $00, $A0, $00, $A0, $00
    DB      $A0, $00, $A0, $00, $A0, $0C, $67, $17
    DB      $D7, $17, $D7, $17, $D7, $17, $6B, $00
    DB      $A0, $A0, $00, $A0, $00, $A0, $00, $A0
    DB      $A0, $0C, $67, $D7, $17, $D7, $17, $D7
    DB      $17, $D7, $6B, $00, $A0, $00, $A0, $00
    DB      $A0, $00, $A0, $00, $A0, $0C, $D7, $77
    DB      $D7, $77, $D7, $77, $D7, $77, $DB, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $0C, $17, $77, $77, $77
    DB      $77, $77, $77, $17, $1B, $00, $A0, $00
    DB      $00, $00, $00, $00, $00, $A0, $A0, $0C
    DB      $D7, $77, $77, $77, $17, $77, $17, $67
    DB      $6B, $00, $00, $00, $00, $00, $A0, $00
    DB      $A0, $A0, $A0, $0C, $17, $77, $77, $77
    DB      $D7, $77, $DB, $A0, $A0, $00, $A0, $00
    DB      $00, $00, $00, $00, $00, $A0, $A0, $0C
    DB      $67, $77, $77, $77, $77, $77, $1B, $A0
    DB      $A0, $00, $A0, $00, $00, $00, $00, $00
    DB      $A0, $A0, $A0, $0C, $67, $77, $17, $77
    DB      $77, $77, $D7, $67, $6B, $00, $A0, $00
    DB      $A0, $00, $00, $00, $00, $A0, $A0, $0C
    DB      $67, $77, $D7, $77, $77, $77, $1B, $A0
    DB      $A0, $00, $A0, $00, $00, $00, $00, $00
    DB      $A0, $A0, $A0, $0C, $67, $77, $77, $77
    DB      $77, $77, $6B, $A0, $A0, $00, $A0, $00
    DB      $00, $00, $00, $00, $A0, $A0, $A0, $0C
    DB      $67, $77, $77, $77, $77, $77, $DB, $A0
    DB      $A0, $00, $AF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $A0, $A0, $00, $A0, $00, $00, $00
    DB      $00, $0C, $17, $D7, $6B, $00, $A0, $00
    DB      $00, $00, $00, $00, $A0, $00, $A0, $00
    DB      $A0, $00, $00, $00, $00, $00, $A0, $00
    DB      $A0, $00, $A0, $00, $00, $00, $00, $00
    DB      $A0, $00, $A0, $0C, $DB, $00, $00, $00
    DB      $00, $0C, $D7, $77, $DB, $00, $00, $0C
    DB      $17, $17, $2B, $0C, $12, $22, $2B, $00
    DB      $00, $00, $A0, $A0, $00, $00, $A0, $00
    DB      $00, $0C, $22, $22, $6B, $AC, $22, $17
    DB      $DB, $00, $00, $00, $00, $00, $A0, $A0
    DB      $00, $A0, $00, $00, $00, $00, $00, $0C
    DB      $67, $67, $1B, $AC, $12, $22, $2B, $00
    DB      $00, $00, $A0, $A0, $A0, $A0, $A0, $00
    DB      $00, $0C, $22, $22, $DB, $AC, $67, $D7
    DB      $6B, $00, $00, $00, $00, $00, $00, $A0
    DB      $A0, $00, $A0, $00, $00, $00, $00, $0C
    DB      $17, $D7, $6B, $0C, $62, $22, $2B, $00
    DB      $00, $00, $A0, $00, $A0, $00, $A0, $00
    DB      $00, $0C, $22, $22, $6B, $0C, $D7, $17
    DB      $DB, $00, $00, $00, $00, $00, $A0, $00
    DB      $00, $A0, $00, $00, $00, $00, $00, $0C
    DB      $67, $17, $1B, $AC, $12, $22, $2B, $00
    DB      $00, $00, $A0, $A0, $A0, $A0, $A0, $00
    DB      $00, $0C, $22, $22, $DB, $AC, $D7, $67
    DB      $6B, $00, $00, $00, $00, $00, $00, $A0
    DB      $00, $A0, $A0, $00, $00, $00, $00, $0C
    DB      $17, $D2, $1B, $AC, $62, $22, $2B, $00
    DB      $00, $00, $AF, $FF, $A0, $A0, $A0, $00
    DB      $00, $0C, $22, $22, $DB, $FC, $D2, $D7
    DB      $DB, $00, $00, $00, $FF, $FF, $00, $00
    DB      $0F, $FF, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $17
    DB      $05, $17, $09, $17, $0D, $17, $11, $00
    DB      $00, $00, $00, $00, $00, $13, $05, $13
    DB      $11, $17, $09, $17, $0D, $00, $00, $00
    DB      $00, $00, $00, $17, $05, $11, $09, $11
    DB      $0D, $17, $11, $0C, $05, $0C, $11, $00
    DB      $00, $17, $05, $17, $09, $17, $0D, $17
    DB      $11, $00, $00, $00, $00, $00, $00, $17
    DB      $09, $17, $0D, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $17, $05, $17
    DB      $09, $17, $0D, $17, $11, $00, $00, $00
    DB      $00, $00, $00, $5C, $83, $5C, $9B, $5C
    DB      $A3, $5C, $73, $7C, $A3, $5C, $93, $20
    DB      $40, $60, $03, $FF, $2D, $67, $0D, $49
    DB      $FF, $FF, $FF, $43, $63, $29, $07, $FF
    DB      $10, $30, $50, $70, $FF, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $20, $40, $60, $FF, $FF, $04, $22, $4E
    DB      $66, $FF, $FF, $02, $26, $4A, $64, $FF
    DB      $08, $30, $50, $68, $FF, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $20, $40, $60, $0C, $6C, $FF, $04, $42
    DB      $6E, $FF, $FF, $0E, $22, $64, $FF, $FF
    DB      $06, $26, $46, $66, $10, $70, $FF, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $20, $40, $60, $FF, $08, $26, $48, $66
    DB      $FF, $02, $2A, $4A, $62, $FF, $04, $0C
    DB      $24, $28, $42, $46, $68, $6C, $FF, $06
    DB      $0A, $22, $2C, $44, $4C, $64, $6A, $FF
    DB      $0E, $2E, $4E, $6E, $FF, $00, $00, $20
    DB      $40, $FF, $26, $2A, $44, $48, $FF, $FF
    DB      $22, $2C, $42, $4A, $FF, $24, $28, $46
    DB      $4C, $FF, $2E, $4E, $FF, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $02
    DB      $20, $42, $60, $FF, $0A, $28, $4E, $64
    DB      $FF, $06, $24, $2C, $46, $4A, $68, $FF
    DB      $FF, $FF, $12, $30, $52, $6C, $FF, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $10
    DB      $10, $12, $20, $10, $12

SUB_B949:                                  ; SUB_B949: game screen renderer (tile/sprite update)
    LD      A, ($7055)                  ; RAM $7055
    ADD     A, A
    LD      HL, $B847
    CALL    SUB_8FF4
    LD      ($715D), A                  ; RAM $715D
    INC     HL
    LD      A, (HL)
    LD      ($715F), A                  ; RAM $715F
    LD      A, $0A
    LD      ($7076), A                  ; RAM $7076
    SUB     A
    LD      ($7076), A                  ; RAM $7076
    LD      IX, $B96B
    JP      PUTOBJ
    DB      $73, $B9, $5C, $71, $7E, $B9, $83, $B9
    DB      $24, $78, $B9, $7A, $B9, $00, $00, $00
    DB      $00, $00, $00, $88, $B9, $61, $71, $00
    DB      $91, $B9, $67, $71, $01, $03, $00, $98
    DB      $A7, $04, $8F, $B9, $0F, $00, $03, $04
    DB      $B8, $A7, $04, $98, $B9, $09, $00, $03
    DB      $0F, $1D, $3B, $37, $0F, $07, $00, $3F
    DB      $7F, $77, $0F, $1F, $3F, $3C, $20, $C0
    DB      $80, $C0, $E0, $E0, $D0, $00, $00, $80
    DB      $E8, $F6, $74, $F8, $E0, $D8, $70, $00
    DB      $00, $00, $00, $00, $00, $00, $0F, $00
    DB      $00, $80, $E0, $40, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $D0, $F0, $60
    DB      $00, $00, $03, $06, $00, $00, $00, $0F
    DB      $1E, $3F, $77, $6F, $57, $60, $0F, $1F
    DB      $1F, $3A, $30, $0B, $0F, $07, $07, $00
    DB      $00, $C0, $E0, $D0, $00, $00, $00, $60
    DB      $70, $D8, $FC, $FC, $E0, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $0F, $00, $00
    DB      $00, $04, $0E, $04, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $D0, $F0, $E0, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $03
    DB      $01, $03, $07, $07, $0B, $00, $00, $01
    DB      $0F, $0E, $11, $1F, $07, $1B, $0E, $C0
    DB      $F0, $B8, $DC, $EC, $F0, $E0, $00, $F0
    DB      $FC, $FC, $F0, $F0, $CC, $3C, $04, $00
    DB      $00, $00, $00, $00, $00, $0B, $0F, $06
    DB      $30, $10, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $F0, $00
    DB      $00, $02, $04, $00, $00, $00, $00, $00
    DB      $00, $03, $07, $0B, $00, $00, $00, $06
    DB      $0E, $1B, $3F, $3F, $07, $00, $03, $F0
    DB      $78, $FC, $EE, $F6, $EA, $06, $F0, $F8
    DB      $F8, $5C, $0C, $D0, $E0, $E0, $E0, $00
    DB      $00, $00, $00, $00, $0B, $0F, $07, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $F0, $00, $00
    DB      $00, $20, $70, $20, $00, $00, $00, $07
    DB      $0F, $0F, $0B, $04, $07, $07, $08, $1C
    DB      $3F, $77, $3F, $09, $1E, $00, $00, $E0
    DB      $70, $B0, $E0, $E0, $E0, $E0, $10, $38
    DB      $F8, $E0, $F0, $F8, $F8, $60, $78, $00
    DB      $00, $00, $00, $00, $00, $00, $07, $03
    DB      $00, $00, $C0, $E0, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $E0, $C0
    DB      $04, $0C, $00, $00, $00, $00, $00, $07
    DB      $0F, $0F, $0B, $04, $07, $07, $08, $1C
    DB      $1F, $07, $0F, $1F, $1F, $06, $1E, $E0
    DB      $70, $B0, $E0, $E0, $E0, $E0, $10, $38
    DB      $FC, $EE, $FC, $90, $78, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $07, $03
    DB      $20, $30, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $E0, $C0
    DB      $00, $00, $03, $07, $00, $00, $00, $07
    DB      $0D, $0C, $05, $07, $04, $00, $08, $1C
    DB      $3D, $77, $0D, $09, $1E, $00, $00, $E0
    DB      $B0, $30, $A0, $E0, $20, $00, $10, $38
    DB      $B8, $E0, $B0, $F8, $F8, $60, $78, $00
    DB      $00, $00, $00, $00, $03, $05, $07, $03
    DB      $00, $00, $E0, $C0, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $C0, $A0, $E0, $C0
    DB      $04, $0C, $00, $00, $00, $00, $00, $07
    DB      $0D, $0C, $05, $07, $04, $00, $08, $1C
    DB      $1D, $07, $0D, $1F, $1F, $06, $1E, $E0
    DB      $B0, $30, $A0, $E0, $20, $00, $10, $38
    DB      $BC, $EE, $B0, $90, $78, $00, $00, $00
    DB      $00, $00, $00, $00, $03, $05, $07, $03
    DB      $20, $30, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $C0, $A0, $E0, $C0
    DB      $00, $00, $07, $03, $00, $00, $00, $03
    DB      $01, $03, $07, $07, $0B, $00, $00, $01
    DB      $17, $67, $2E, $1F, $07, $1B, $0E, $C0
    DB      $F0, $B8, $DC, $EC, $F0, $E0, $00, $FC
    DB      $FE, $EE, $F0, $F8, $FC, $3C, $04, $00
    DB      $00, $00, $00, $00, $00, $0B, $0F, $06
    DB      $00, $00, $C0, $60, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $F0, $00
    DB      $00, $01, $07, $02, $00, $00, $00, $03
    DB      $0F, $1D, $3B, $37, $0F, $07, $00, $0F
    DB      $3F, $3F, $0F, $0F, $33, $3C, $20, $C0
    DB      $80, $C0, $E0, $E0, $D0, $00, $00, $80
    DB      $F0, $70, $88, $F8, $E0, $D8, $70, $00
    DB      $00, $00, $00, $00, $00

; ============================================================
; TILE / SPRITE BITMAPS  ($BC00 - $BF6F)
; TMS9918A pattern table -- 8 bytes per tile (one byte per row).
; 110 tiles total.
; ============================================================
TILE_BITMAPS:                              ; TILE_BITMAPS: sprite pattern data (tile graphics bitmaps)
    DB      $00, $0F, $00, $00, $40, $20, $00, $00 ; tile 0
    DB      $00, $00, $00, $00, $00, $00, $00, $00 ; tile 1
    DB      $D0, $F0, $60, $0C, $08, $00, $00, $00 ; tile 2
    DB      $00, $00, $0F, $0D, $04, $05, $07, $04 ; tile 3
    DB      $00, $00, $1C, $3D, $77, $6D, $0F, $07 ; tile 4
    DB      $06, $1E, $F0, $B0, $20, $A0, $E0, $20 ; tile 5
    DB      $00, $00, $38, $AC, $EE, $A6, $F0, $E0 ; tile 6
    DB      $60, $78, $00, $00, $00, $00, $00, $03 ; tile 7
    DB      $05, $07, $03, $00, $00, $00, $70, $20 ; tile 8
    DB      $00, $00, $00, $00, $00, $00, $00, $C0 ; tile 9
    DB      $A0, $E0, $C0, $00, $00, $00, $0E, $04 ; tile 10
    DB      $00, $00, $0F, $0D, $04, $05, $07, $64 ; tile 11
    DB      $60, $78, $3D, $1F, $0D, $0F, $00, $07 ; tile 12
    DB      $06, $1E, $F0, $B0, $20, $A0, $E0, $26 ; tile 13
    DB      $06, $1E, $BC, $F8, $B0, $F0, $00, $E0 ; tile 14
    DB      $60, $78, $00, $00, $00, $60, $70, $03 ; tile 15
    DB      $05, $07, $00, $00, $00, $00, $07, $00 ; tile 16
    DB      $00, $00, $00, $00, $00, $06, $0E, $C0 ; tile 17
    DB      $A0, $E0, $00, $00, $00, $00, $60, $00 ; tile 18
    DB      $00, $00, $00, $00, $00, $00, $00, $20 ; tile 19
    DB      $30, $38, $3C, $3D, $1F, $1D, $0F, $07 ; tile 20
    DB      $06, $1E, $00, $00, $00, $00, $00, $04 ; tile 21
    DB      $0C, $1C, $3C, $BC, $F8, $38, $F0, $E0 ; tile 22
    DB      $60, $78, $00, $08, $04, $32, $38, $13 ; tile 23
    DB      $05, $07, $03, $00, $00, $00, $00, $00 ; tile 24
    DB      $00, $00, $80, $88, $90, $2C, $1C, $C8 ; tile 25
    DB      $A0, $E0, $C0, $00, $00, $00, $00, $00 ; tile 26
    DB      $00, $00, $00, $00, $00, $00, $00, $00 ; tile 27
    DB      $00, $08, $1F, $19, $19, $1B, $09, $03 ; tile 28
    DB      $00, $00, $00, $00, $00, $00, $00, $00 ; tile 29
    DB      $00, $10, $F8, $98, $98, $D8, $90, $C0 ; tile 30
    DB      $00, $00, $00, $00, $00, $00, $00, $03 ; tile 31
    DB      $65, $77, $20, $06, $06, $04, $06, $00 ; tile 32
    DB      $00, $00, $00, $00, $00, $00, $00, $C0 ; tile 33
    DB      $A6, $EE, $04, $60, $60, $20, $30, $00 ; tile 34
    DB      $00, $00, $00, $00, $00, $00, $00, $00 ; tile 35
    DB      $00, $00, $00, $00, $30, $70, $F0, $C8 ; tile 36
    DB      $08, $00, $00, $00, $00, $00, $00, $00 ; tile 37
    DB      $00, $00, $00, $00, $0C, $0E, $0F, $13 ; tile 38
    DB      $10, $00, $00, $00, $00, $00, $00, $E0 ; tile 39
    DB      $00, $30, $38, $1C, $0F, $0F, $0F, $07 ; tile 40
    DB      $07, $03, $00, $00, $00, $00, $00, $07 ; tile 41
    DB      $00, $0C, $1C, $38, $F0, $F0, $F0, $E0 ; tile 42
    DB      $E0, $C0, $00, $00, $00, $00, $00, $00 ; tile 43
    DB      $00, $00, $00, $E0, $F0, $30, $10, $08 ; tile 44
    DB      $08, $00, $00, $00, $00, $00, $00, $00 ; tile 45
    DB      $00, $00, $00, $07, $0F, $0C, $08, $10 ; tile 46
    DB      $10, $00, $00, $00, $00, $00, $06, $08 ; tile 47
    DB      $00, $0C, $0E, $0E, $0F, $0F, $0F, $07 ; tile 48
    DB      $07, $03, $00, $00, $00, $00, $60, $10 ; tile 49
    DB      $00, $30, $70, $70, $F0, $F0, $F0, $E0 ; tile 50
    DB      $E0, $C0                    ; tile 51

DELAY_LOOP_BD9A:                           ; DELAY_LOOP_BD9A: timing delay loop
    LD      B, $14

LOC_BD9C:
    PUSH    BC

LOC_BD9D:
    LD      A, ($706E)                  ; RAM $706E
    OR      A
    JR      NZ, LOC_BD9D
    LD      A, $0E
    LD      ($706E), A                  ; RAM $706E
    LD      A, ($7076)                  ; RAM $7076
    INC     A
    AND     $01
    ADD     A, C
    LD      ($7076), A                  ; RAM $7076
    LD      IX, $B96B
    CALL    PUTOBJ
    CALL    SUB_921D
    CALL    SUB_9B95
    CALL    SUB_9942
    POP     BC
    DJNZ    LOC_BD9C
    RET     

SUB_BDC6:                                  ; SUB_BDC6: level-complete victory sequence
    CALL    SUB_9CFD
    LD      A, $0C
    CALL    SUB_BDDC
    LD      A, $0D
    CALL    SUB_BDDC
    LD      A, $0E
    LD      ($7076), A                  ; RAM $7076
    LD      C, A
    JP      DELAY_LOOP_BD9A

SUB_BDDC:                                  ; SUB_BDDC: level-complete sub-routine continued
    PUSH    AF
    LD      A, $14
    LD      ($706E), A                  ; RAM $706E
    POP     AF
    LD      ($7076), A                  ; RAM $7076

LOC_BDE6:
    LD      A, ($706E)                  ; RAM $706E
    OR      A
    JR      NZ, LOC_BDE6
    RET     
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $FF, $00, $00, $00, $00
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
    DB      $00, $00, $00, $00, $00, $00, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00

; ============================================================
; ZERO PADDING  ($BF70 - $BFFF)
; ============================================================
    DB      $FF, $00, $FF, $00, $FF, $00, $FF, $00
    DB      $FF, $00, $FF, $00, $FF, $00, $FF, $00
    DB      $FF, $00, $FF, $00, $FF, $00, $FF, $00
    DB      $FF, $00, $FF, $00, $FF, $00, $FF, $00
    DB      $FF, $00, $FF, $00, $FF, $00, $FF, $00
    DB      $FF, $00, $FF, $00, $FF, $00, $FF, $00
    DB      $FF, $00, $FF, $00, $FF, $00, $FF, $00
    DB      $FF, $00, $FF, $00, $FF, $00, $FF, $00
    DB      $FF, $00, $FF, $00, $FF, $00, $FF, $00
    DB      $FF, $00, $FF, $00, $FF, $00, $FF, $00
    DB      $FF, $00, $FF, $00, $FF, $00, $FF, $00
    DB      $FF, $00, $FF, $00, $FF, $00, $FF, $00
    DB      $FF, $00, $FF, $00, $FF, $00, $FF, $00
    DB      $FF, $00, $FF, $00, $FF, $00, $FF, $00
    DB      $FF, $00, $FF, $00, $FF, $00, $FF, $00
    DB      $FF, $00, $FF, $00, $FF, $00, $FF, $00
    DB      $FF, $00, $FF, $00, $FF, $00, $FF, $00
    DB      $FF, $00, $FF, $00, $FF, $00, $FF, $00
