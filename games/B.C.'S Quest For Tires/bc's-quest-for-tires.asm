; =============================================================================
; B.C.'S QUEST FOR TIRES  1983  --  ColecoVision  (16 KB ROM, loads at $8000)
; Disassembled by z80cv_disasm.py  |  Annotated with Claude Sonnet 4.6
; Exact byte-match verified vs. b-c-s-quest-for-tires-1983.rom
; =============================================================================
;
; LEGEND / CROSS-REFERENCE INDEX
; All line numbers refer to THIS file.  ROM addresses shown as ($XXXX).
;
; --- HARDWARE / BIOS --------------------------------------------------------
;   BIOS EQU block:  lines  144- 193
;   I/O port defs:   lines  197- 203
;   RAM defs:        lines  207- 209
;     WORK_BUFFER $7000  JOYSTICK_BUFFER $702B  STACKTOP $73B9
;
; --- ROM LAYOUT (16 KB: $8000-$BFFF) ----------------------------------------
;   $8021  CART_ENTRY: JP NMI            line  251
;   $8024  START -- boot entry           line  271
;   $8077  LOC_8077 game/level re-entry  line  341
;   $807D  LOC_807D per-frame loop        line  363
;   $819C  SUB_819C level init            line  546
;   $824D  NMI handler (just RET)         line  625
;   $8269  VDP_DATA_8269 title screen     line  649
;   $B054  GAME_DATA level/sprite tables  line 5083
;   $BC00  TILE_BITMAPS 110 tiles         line 5464
;
; --- BOOT / INIT ($8024) ----------------------------------------------------
;   START ($8024)        line  271  warm-start XOR check $7037; zero $7000-$73B8
;                              SP=STACKTOP; SUB_ABDA (SN76489A silence)
;                              init JOYSTICK_BUFFER $702B/$702C=$9B
;   VDP_DATA_8269 ($8269) line  649  title screen (MODE_1, LOAD_ASCII, FILL_VRAM)
;   SUB_82B2 ($82B2)     line  679  GAME_OPT: player count selection ($703D)
;
; --- MAIN GAME LOOP ($807D) -------------------------------------------------
;   LOC_8077 ($8077)     line  341  level re-entry: SUB_834F + SUB_8392
;   LOC_807D ($807D)     line  363  per-frame: RST$08 + INIT_TABLE + scroll
;                              flush sprite name table $72B6 -> VRAM $2380 ($7C bytes)
;                              B.C. sprite pos -> VRAM; phase dispatch:
;                              SUB_8946 + SUB_A989 + SUB_8ACC + SUB_85B7
;                              SOUND_WRITE_A00E; SUB_9B5D; SUB_90F8; SUB_94EB
;
; --- VDP / TILE INIT ($8392) ------------------------------------------------
;   SUB_834F ($834F)     line  775  level data ptr loader ($9488/$94B8 table)
;   SUB_8392 ($8392)     line  812  full VDP + tile init (5x INIT_TABLE, 6x BEFA)
;   SUB_8492 ($8492)     line  917  init scroll ring buffer ptrs $709F/$70A1/$70A3
;   SUB_84B8 ($84B8)     line  937  merge two VRAM tile planes into scroll surface
;   DELAY_LOOP_8513 ($8513)  line  989  level table lookup ($9488 -> $7042/$7066/$7067)
;
; --- B.C. CHARACTER MOVEMENT ------------------------------------------------
;   SUB_85B7 ($85B7)     line 1026  B.C. vertical movement (DEC Y; boundary $02/$60)
;   SUB_876B ($876B)     line 1264  place B.C. sprite: IX offsets -> $7097/$7098 -> $7306
;   SUB_87CC ($87CC)     line 1317  countdown timer: DEC (HL) by $707D; reset $7097
;   SUB_87E2 ($87E2)     line 1336  apply IY-table delta to $7306 sprite X positions
;   SUB_8802 ($8802)     line 1353  random R-register jitter to sprite X (AND $7090)
;   SUB_8817 ($8817)     line 1373  adjust B by L when jump timers $7092/$7094 active
;
; --- SCROLL SYSTEM ----------------------------------------------------------
;   SUB_8946 ($8946)     line 1425  sprite tile animation + VRAM column advance
;   LOC_8A51 ($8A51)     line 1548  tile column writer: $706B ROM ptr -> $70C5 buffer
;   SUB_8A8A ($8A8A)     line 1582  scroll tile updater: select fn from $8AC0 by $707C
;   SUB_8ACC ($8ACC)     line 1619  scroll accumulator: $707C -> $70A5; count in $7070
;   DELAY_LOOP_ABBE ($ABBE) line 4899  pixel FIFO shift $70A7-$70C6 left $7055 steps
;   DELAY_LOOP_AB02 ($AB02) line 4792  column shift: $71C6/$724C/$7266 ring buffers
;   SOUND_WRITE_AB34 ($AB34) line 4813  level-clear: $71C6 nibbles -> $7264/$725A
;
; --- HAZARD / SPRITE MANAGEMENT ---------------------------------------------
;   SUB_8C56 ($8C56)     line 1832  hazard movement: advance X by $707C; remove off-left
;   SUB_8D87 ($8D87)     line 1895  oscillate (IX+2) $7C/$78/$80 via $706F flag
;   SUB_8E2E ($8E2E)     line 1934  allocate $7330 slot; load from $9056 table by type
;   SOUND_WRITE_8FBB ($8FBB) line 2173  mark sprite removed; free $72C6 slots; play sound
;   DELAY_LOOP_9ED7 ($9ED7) line 3497  scan $7330 for B.C. ID $10 (player hit test)
;   SUB_A1A8 ($A1A8)     line 3750  per-sprite: $10=B.C. $0A=hazard; -> SOUND_WRITE_A300
;   SOUND_WRITE_A300 ($A300) line 3953  bounding-box collision test (RET NC=hit)
;
; --- GAME STATE MACHINE -----------------------------------------------------
;   SUB_90F8 ($90F8)     line 2275  advance $7040 ptr; update $703F game phase
;   SUB_9152 ($9152)     line 2328  inter-level transition: VDP blank, reload tiles
;   SUB_94EB ($94EB)     line 2721  init per-phase state: player pos, sprite table
;   SUB_9B5D ($9B5D)     line 3075  configure difficulty params from $708A
;   SOUND_WRITE_A00E ($A00E) line 3548  game event: collision, score, phase transitions
;
; --- SCORE / SOUND ----------------------------------------------------------
;   SUB_A359 ($A359)     line 4026  BCD add C to $7048 (3-byte score)
;   SUB_A3B5 ($A3B5)     line 4095  hi-score check: $7048 vs $7037; update if higher
;   DELAY_LOOP_A2BE ($A2BE) line 3914  score bytes -> BCD digit tiles at $70A4
;   VDP_REG_93E3 ($93E3) line 2645  score digit render: $7037/$7048 -> VRAM $2091
;   SUB_ABDA ($ABDA)     line 4920  SN76489A init: SOUND_INIT 3-ch silence ($ABFE)
;   SUB_ABE3 ($ABE3)     line 4926  play 2 random sounds from scroll-phase table
;
; --- INPUT ------------------------------------------------------------------
;   SUB_A989 ($A989)     line 4616  decode P1=$702D / P2=$7032; fire/jump -> $705F
;   SOUND_WRITE_82E3 ($82E3) line  706  attract mode joystick poll loop
;   SUB_832C ($832C)     line  746  wait-for-VBL + POLLER + fire-button check
;
; --- VDP PRIMITIVES ---------------------------------------------------------
;   VDP_DATA_9622 ($9622) line 2876  sprite pattern chain: IY-table -> VRAM $3000
;   VDP_REG_A958 ($A958) line 4572  sprite attr rows: BC=count/width, $707F enable
;   VDP_REG_BEFA ($BEFA) line 5562  ROM->VRAM RLE compressed pattern writer
;   VDP_REG_BF8A ($BF8A) line 5656  RAM->VRAM: B pages + C remainder; DE=VRAM, HL=src
;   VDP_REG_BFA6 ($BFA6) line 5681  VRAM->RAM block read (complement of BF8A)
;
; --- KEY RAM VARIABLES -------------------------------------------------------
;   $702B JOYSTICK_BUFFER P1/P2 raw  $702D P1 ctrl  $7032 P2 ctrl
;   $703D player count (1/2)   $703E lives counter  $703F game phase
;     $01=run $03=death $05=level-clear $07=inter-level $09=attract
;   $7040 level data entry ptr   $7042 level ROM data ptr  $7044 game mode
;   $7045 current lives  $7046 anim frame  $7047 active player
;   $704E transition type flag   $705E decoded joystick  $705F go-UP/DOWN flag
;   $7054 B.C. sprite Y  $706D B.C. sprite X  $706E VRAM column pending
;   $706B scroll tile ROM ptr  $706F oscillator flag  $7070 column advance count
;   $707C scroll speed divisor  $707D RST $08 VBL delay  $707F VRAM write enable
;   $7080/$7081 movement/Y-anim counters  $7084/$7086 movement/Y data ptrs
;   $7082 collision data ptr  $7090 random mask  $7092/$7094 jump timers
;   $708A difficulty/enemy type  $708B state-machine advance flag
;   $7097 B.C. X position  $7098 B.C. Y position  $7099 X backup
;   $709B object-type dispatch ptr  $709F/$70A1/$70A3 scroll ring buffer ptrs
;   $70A5 scroll sub-pixel accumulator  $70A7-$70C6 pixel scroll FIFO (32 bytes)
;   $71C6/$724C scroll tile buffers  $7246 sprite attr buf  $7264/$725A tile targets
;   $7266 hazard row scroll buffer  $72B6 sprite name table buffer ($7C bytes)
;   $7306 sprite attribute buffer (IY write target)  $7326/$7330 sprite tables
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
; =============================================================================


; BIOS DEFINITIONS **************************

BOOT_UP:                 EQU $0000
BIOS_NMI:                EQU $0066
NUMBER_TABLE:            EQU $006C
PLAY_SONGS:              EQU $1F61
ACTIVATEP:               EQU $1F64
REFLECT_VERTICAL:        EQU $1F6A
REFLECT_HORIZONTAL:      EQU $1F6D
ROTATE_90:               EQU $1F70
ENLARGE:                 EQU $1F73
CONTROLLER_SCAN:         EQU $1F76
DECODER:                 EQU $1F79
GAME_OPT:                EQU $1F7C
LOAD_ASCII:              EQU $1F7F
FILL_VRAM:               EQU $1F82
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
INIT_TABLE:              EQU $1FB8
GET_VRAM:                EQU $1FBB
PUT_VRAM:                EQU $1FBE
INIT_SPR_NM_TBL:         EQU $1FC1
WR_SPR_NM_TBL:           EQU $1FC4
INIT_TIMER:              EQU $1FC7
FREE_SIGNAL:             EQU $1FCA
REQUEST_SIGNAL:          EQU $1FCD
TEST_SIGNAL:             EQU $1FD0
TIME_MGR:                EQU $1FD3
TURN_OFF_SOUND:          EQU $1FD6
WRITE_REGISTER:          EQU $1FD9
READ_REGISTER:           EQU $1FDC
WRITE_VRAM:              EQU $1FDF
READ_VRAM:               EQU $1FE2
INIT_WRITER:             EQU $1FE5
WRITER:                  EQU $1FE8
POLLER:                  EQU $1FEB
SOUND_INIT:              EQU $1FEE
PLAY_IT:                 EQU $1FF1
SOUND_MAN:               EQU $1FF4
ACTIVATE:                EQU $1FF7
PUTOBJ:                  EQU $1FFA
RAND_GEN:                EQU $1FFD

; I/O PORT DEFINITIONS **********************

KEYBOARD_PORT:           EQU $0080
DATA_PORT:               EQU $00BE
CTRL_PORT:               EQU $00BF
JOY_PORT:                EQU $00C0
CONTROLLER_02:           EQU $00F5
CONTROLLER_01:           EQU $00FC
SOUND_PORT:              EQU $00FF

; RAM DEFINITIONS ***************************

WORK_BUFFER:             EQU $7000
JOYSTICK_BUFFER:         EQU $702B
STACKTOP:                EQU $73B9

FNAME "output\B-C-S-QUEST-FOR-TIRES-1983-NEW.ROM"
CPU Z80

    ORG     $8000

    DW      $AA55                           ; cart magic $AA/$55 (BCS uses reversed byte order vs $55/$AA)
    DB      $00, $00
    DB      $00, $00
    DB      $00, $00
    DW      JOYSTICK_BUFFER                 ; BIOS POLLER writes P1/P2 controller raw data here
    DW      START                           ; cold-start entry address ($8024)
    DB      $C3, $6F, $AA, $C3, $00, $00, $C3, $00
    DB      $00, $C3, $00, $00, $C9, $00, $00, $C3
    DB      $00, $00, $C3, $00, $00

; =============================================================================
; CART_ENTRY ($8021) -- ROM entry point
; =============================================================================
; ROM header at $8000: magic $AA/$55, six zero-pad bytes, JOYSTICK_BUFFER ptr
; ($702B), START address, then BIOS trampoline JP patches:
;   $800C: JP $AA6F  -- RST $08 patched to VBL sync routine
;   $800F: JP $0000  -- RST $10 (unused)
;   ... remaining RST slots zeroed
; CART_ENTRY ($8021): JP NMI
;
; NMI ($824D): just RET -- this game does not use the NMI interrupt for
; per-frame work.  All VBL sync is done via RST $08 (patched to $AA6F):
;   LOC_AA6F ($AA6F, unlabeled -- reached only via RST $08):
;     LD A,($707D) / LD B,A    -- load frame-delay count into B
;     LOC: CALL READ_REGISTER  -- read VDP status
;          BIT 7,A / JR Z,LOC  -- spin until VBL (bit 7 set)
;     PUSH BC
;     CALL SOUND_MAN           -- BIOS: advance sound channel state
;     CALL PLAY_SONGS          -- BIOS: music tick
;     CALL $BFC2               -- BIOS: POLLER (read controller state)
;     if $7044 == $09 (attract mode):
;       read ($7031) joystick; if valid: JP LOC_804A (soft reset)
;     POP BC / DJNZ (repeat B times for $707D VBL frames)
;     RET
; =============================================================================
CART_ENTRY:                                 ; CART_ENTRY ($8021): route all hardware ints to NMI handler
    JP      NMI                             ; JP NMI -- all interrupts land here (NMI just does RET)

; =============================================================================
; START ($8024) -- power-on boot entry
; =============================================================================
; Entered once at power-on.  Checks for "warm start" save data in RAM:
;   LD BC,$0036 / LD E,$03 / LD IX,$7037
;   LOC_802E: test IX+0 ^ IX+3 for each of 3 bytes at $7037-$7039
;     if all match: JR LOC_8040 (skip full clear -- resume saved game)
;     else: LD BC,$0047 (full init flag)
;   LOC_8040: LD HL,WORK_BUFFER / LD DE,$7001 / LD (HL),$00 / LDIR
;     zero-fill RAM $7000-$73FF
;   LOC_804A/$804F: set SP=STACKTOP / PUSH AF
;     CALL SUB_ABDA  -- SN76489A sound init (silence all channels)
;     init JOYSTICK_BUFFER $702B/$702C = $9B
;   POP AF / if BC!=$0036: CALL VDP_DATA_8269 (title screen display init)
;                           CALL SUB_82B2     (GAME_OPT / player selection)
;   fall through to LOC_8077 (game init)
; =============================================================================
START:                                      ; START ($8024): cold-start; check for warm-start save data at $7037
    LD      BC, $0036                       ; BC=$0036 = stride for warm-start XOR validation
    LD      E, $03
    LD      IX, $7037                       ; IX=$7037: hi-score / save-data base in RAM
    OR      A                               ; clear carry before ADC validation loop

LOC_802E:
    LD      A, (IX+0)                       ; load byte from save-data slot 0
    ADC     A, (IX+3)                       ; XOR slot-0 vs slot-3 (warm-start check byte)
    JR      NZ, LOC_803D                    ; mismatch -> skip to cold init
    INC     IX
    DEC     E
    JR      NZ, LOC_802E
    JR      LOC_8040

LOC_803D:
    LD      BC, $0047                       ; BC=$0047 = cold-start flag (full RAM clear)

LOC_8040:
    LD      HL, WORK_BUFFER                 ; HL=WORK_BUFFER ($7000): start of zero-fill range
    LD      DE, $7001                       ; DE=$7001: LDIR destination
    LD      (HL), $00                       ; set first byte to 0
    LDIR                                    ; zero-fill RAM $7000-$73B8 (LDIR)

LOC_804A:
    LD      A, $FF
    JR      LOC_804F

LOC_804E:
    XOR     A

LOC_804F:
    LD      BC, $03B8
    LD      HL, $7048                   ; RAM $7048
    LD      DE, $7049                   ; RAM $7049
    LD      (HL), $00
    LDIR    
    LD      SP, STACKTOP                    ; init stack pointer at STACKTOP ($73B9)
    PUSH    AF                              ; save warm/cold flag (A) on stack
    CALL    SUB_ABDA                        ; CALL SUB_ABDA: silence SN76489A (all channels off)
    LD      A, $9B                          ; A=$9B: controller init value
    LD      B, A
    XOR     A
    LD      HL, JOYSTICK_BUFFER             ; HL=JOYSTICK_BUFFER ($702B)
    LD      (HL), B                         ; write $9B to $702B (P1 raw ctrl)
    INC     HL
    LD      (HL), B                         ; write $9B to $702C (P2 raw ctrl)
    POP     AF                              ; restore warm/cold flag
    OR      A
    JR      Z, LOC_8077                     ; cold start: skip title/GAME_OPT, go direct to LOC_8077
    CALL    VDP_DATA_8269                   ; CALL VDP_DATA_8269: title screen VDP setup (MODE_1, LOAD_ASCII)
    CALL    SUB_82B2                        ; CALL SUB_82B2: GAME_OPT player-count selection

; =============================================================================
; LOC_8077 ($8077) -- game / level re-entry
; =============================================================================
; Entered after GAME_OPT completes and after each life loss or level clear:
;   CALL SUB_834F  -- level data pointer loader:
;     DEC A / index into $94B8 table (12-byte stride) by level number
;     stores HL -> $7042 (level data ptr), loads $7066/$7067 (scroll params)
;   CALL SUB_8392  -- full VDP + tile init:
;     5 x INIT_TABLE calls for signal tables
;     WRITE_REGISTER x2 (VDP mode: sprites 8x8, color key, pattern base)
;     VDP_REG_BEFA x6: load tile bitmaps into VRAM pages
;       $0000/$0800/$1000/$1800/$2800 from ROM data ptrs $AE94/$AE94/$B431
;     SUB_8492: init scroll column ring buffer ($709F/$70A1/$70A3 pointers)
;     SUB_84B8: merge two VRAM tile planes into combined scroll surface
;     WRITE_REGISTER BC=$01C2 (enable display, 16x16 sprites)
;   fall through to LOC_807D (main per-frame loop)
; =============================================================================
LOC_8077:                                   ; LOC_8077 ($8077): game/level re-entry after each life or level clear
    CALL    SUB_834F                        ; CALL SUB_834F: load level data ptr from $9488/$94B8 table by level
    CALL    SUB_8392                        ; CALL SUB_8392: full VDP + tile init (5x INIT_TABLE, 6x VDP_REG_BEFA)

; =============================================================================
; LOC_807D ($807D) -- main per-frame game loop
; =============================================================================
; Top of the per-frame dispatch loop.  Loops back via JP LOC_807D (line 306).
;   RST $08          -- VBL sync + sound tick + input read (-> $AA6F):
;                       waits $707D VBL frames, calls SOUND_MAN/PLAY_SONGS/POLLER
;   LD HL,($709D) / LD A,$03 / CALL INIT_TABLE  -- advance signal timers
;   LD A,($706E) / CP $01        -- test "VRAM scroll column pending" flag
;     if set: clear flag, compute VRAM scroll offset, CALL VDP_REG_BF8A
;   LOC_80BA: CALL VDP_REG_BF8A  -- flush sprite name table ($72B6, $7C bytes)
;   if $703F == $03 or $05: write score/lives overlay ($7266, $08 bytes)
;   LOC_80E4: if $703F < $07: update B.C. character position + physics:
;     $706D (sprite X), $7054 (sprite Y), CALL VDP_REG_BF8A (char sprite)
;   LOC_810C/LOC_8118: per-frame sub-system dispatch via $703F:
;     $01 = normal run     $03 = death sequence    $05 = level transition
;     $07 = inter-level    $09 = attract / hi-score
;   RET NC / SBC HL,BC / JP NC,LOC_807D  -- loop if rounds remain
; =============================================================================
LOC_807D:                                   ; LOC_807D ($807D): top of per-frame dispatch loop
    RST     $08                             ; RST $08: VBL sync, SOUND_MAN, PLAY_SONGS, POLLER ($707D VBL frames)
    LD      HL, ($709D)                     ; HL = VRAM scroll base addr ($709D)
    LD      A, $03
    CALL    INIT_TABLE                      ; CALL INIT_TABLE: advance signal-timer entry at HL
    LD      A, ($706E)                      ; test "VRAM scroll column pending" flag ($706E)
    CP      $01
    JR      NZ, LOC_80BA                    ; no pending column: skip VRAM scroll write
    LD      A, $00
    LD      ($706E), A                      ; clear scroll pending flag
    LD      A, ($703F)                      ; check game phase ($703F)
    CP      $04
    JR      Z, LOC_80BA                     ; skip scroll in phase $04 (inter-level)
    LD      HL, $2000
    LD      BC, ($7056)                 ; RAM $7056
    ADD     HL, BC
    DB      $EB
    LD      HL, $70A6                   ; RAM $70A6
    LD      A, ($7055)                  ; RAM $7055
    LD      C, A
    OR      A
    JR      Z, LOC_80BA
    LD      B, $00
    LD      A, $05

LOC_80B0:
    SLA     C
    RL      B
    DEC     A
    JR      NZ, LOC_80B0
    CALL    VDP_REG_BF8A                    ; CALL VDP_REG_BF8A: write pending scroll tile column to VRAM

LOC_80BA:                                   ; LOC_80BA: sprite name table flush
    LD      BC, $007C                       ; BC=$007C = 124 bytes (sprite name table size)
    LD      DE, $2380                       ; DE=$2380 = VRAM sprite name table address
    LD      HL, $72B6                       ; HL=$72B6 = sprite name table RAM buffer
    CALL    VDP_REG_BF8A                    ; CALL VDP_REG_BF8A: flush sprite name table to VRAM each frame
    LD      A, ($703F)                      ; check game phase ($703F)
    CP      $03                             ; phase $03 = death sequence: write score/lives overlay
    JR      Z, LOC_80D1
    CP      $05                             ; phase $05 = level-clear: also write overlay
    JR      NZ, LOC_80E4

LOC_80D1:
    EX      AF, AF'
    LD      HL, ($709D)                 ; RAM $709D
    LD      BC, $0348
    ADD     HL, BC
    DB      $EB
    LD      BC, $0008                       ; BC=$0008 = hazard row width
    LD      HL, $7266                       ; HL=$7266 = foreground hazard row buffer
    CALL    VDP_REG_BF8A                    ; CALL VDP_REG_BF8A: flush hazard row to VRAM
    EX      AF, AF'

LOC_80E4:                                   ; LOC_80E4: B.C. character sprite update
    CP      $07                             ; phase >= $07: skip B.C. sprite (inter-level or attract)
    JR      NC, LOC_810C
    LD      DE, ($709D)                     ; DE = VRAM scroll base ($709D)
    LD      A, ($706D)                      ; A = B.C. sprite X position ($706D)
    LD      L, A
    LD      A, ($7054)                      ; A = B.C. sprite Y position ($7054)
    LD      C, A
    LD      H, $00
    LD      B, H
    LD      A, $03                          ; A=$03: shift count for VRAM tile address calc

LOC_80F9:
    SLA     L
    RL      H
    SLA     C
    RL      B
    DEC     A
    JR      NZ, LOC_80F9
    ADD     HL, DE                          ; HL += DE: add VRAM base to scaled sprite pos
    DB      $EB
    LD      HL, $7246                       ; HL=$7246 = B.C. sprite attribute buffer
    CALL    VDP_REG_BF8A                    ; CALL VDP_REG_BF8A: write B.C. sprite attributes to VRAM

LOC_810C:
    LD      A, ($707D)                      ; A = RST $08 VBL frame delay ($707D)
    LD      C, A
    LD      A, ($707A)                      ; A = remaining frame counter ($707A)
    SUB     C
    LD      ($707A), A                      ; update remaining frame counter
    JR      C, LOC_811B                     ; carry: new sub-frame started
    JR      NZ, LOC_813C

LOC_811B:
    LD      A, ($703F)                  ; RAM $703F
    CP      $07
    JR      C, LOC_812F
    LD      A, ($707D)                  ; RAM $707D
    ADD     A, $03
    LD      ($707A), A                  ; RAM $707A
    CALL    SUB_ABE3
    JR      LOC_813C

LOC_812F:
    LD      A, ($7045)                  ; RAM $7045
    LD      C, A
    LD      A, $08
    SUB     C
    LD      ($707A), A                  ; RAM $707A
    CALL    SUB_ABE3

LOC_813C:
    CALL    SUB_8946                        ; CALL SUB_8946: sprite tile animation + VRAM tileset update
    CALL    SUB_A989                        ; CALL SUB_A989: decode player joystick input
    CALL    SUB_8ACC                        ; CALL SUB_8ACC: scroll accumulator (add speed to $70A5)
    CALL    SUB_85B7                        ; CALL SUB_85B7: B.C. vertical movement (gravity + boundary)
    CALL    SOUND_WRITE_A00E                ; CALL SOUND_WRITE_A00E: game event/collision processor
    LD      A, ($7079)                      ; A = game active flag ($7079)
    OR      A
    JR      Z, LOC_8177
    LD      HL, $824E
    LD      B, $00
    LD      A, ($7079)                  ; RAM $7079
    DEC     A
    LD      ($7079), A                  ; RAM $7079
    JR      NZ, LOC_8163
    INC     HL
    INC     HL
    JR      LOC_8167

LOC_8163:
    AND     $01
    LD      C, A
    ADD     HL, BC

LOC_8167:
    LD      A, (HL)
    LD      DE, $0006
    LD      HL, $2300
    CALL    FILL_VRAM
    LD      A, $04
    LD      B, A
    CALL    PLAY_IT                         ; CALL PLAY_IT B=$04: play "enemy hit" sound

LOC_8177:
    LD      A, ($708B)                      ; A = game-state advance flag ($708B)
    CP      $01                             ; CP $01: state-machine advance requested?
    JR      NZ, LOC_818E
    CALL    SUB_9B5D                        ; CALL SUB_9B5D: reconfigure difficulty tables from $708A
    LD      A, ($708B)                  ; RAM $708B
    CP      $00                             ; check if $708B still clear after reconfigure
    JR      Z, LOC_818E

LOC_8188:
    CALL    SUB_90F8                        ; CALL SUB_90F8: advance game state ($7040 ptr, $703F phase)
    CALL    SUB_94EB                        ; CALL SUB_94EB: re-init gameplay state for new phase

LOC_818E:
    LD      HL, ($7064)                     ; HL = remaining scroll-distance counter ($7064)
    LD      BC, $000B
    AND     A
    SBC     HL, BC
    JP      NC, LOC_807D                    ; JP NC, LOC_807D: loop while counter not exhausted
    JR      LOC_8188

; =============================================================================
; SUB_819C ($819C) -- level start / gameplay init
; =============================================================================
; Called when starting a new level or after death (from LOC_807D dispatch):
;   LD A,$01 / LD ($708B),A   -- set "game active" flag
;   LD A,$01 / LD ($703F),A   -- set game phase = 1 (normal run)
;   CALL SUB_94EB             -- init object/enemy table for current level
;   LD A,$01 / LD ($707F),A   -- enable VRAM write mode
;   LD A,$00 / FILL_VRAM $2120 $0020 (blank sprite name table header)
;   VDP_REG_A958 x3: write sprite attribute rows $2140/$2150/$21B4/$2177
;     (B.C. character sprite + initial enemy sprite entries)
;   FILL_VRAM $2160 $0060 A=$35 (fill remaining sprite slots)
;   VDP_REG_BEFA $2300 DE=$857F HL=$1C: write 28-entry sprite order table
;   LDIR $8251->$72C6 $18: copy scroll speed / physics table
;   LD HL,$888E / LD ($709B),HL  -- set object-type dispatch table ptr
;   LD A,$6D / LD ($7097),A     -- B.C. character initial X position
;   LD A,$50 / LD ($7098),A     -- B.C. character initial Y position
;   CALL SUB_876B               -- place B.C. sprite at ($7097,$7098)
;   LD A,$0E / LD ($732D),A     -- set lives display count
;   VDP_REG_BF8A: flush score/status to VRAM
;   WRITE_REGISTER BC=$01C2 (display on, 16x16 sprites)
;   LD A,$01 / LD ($707D),A     -- RST $08 frame delay = 1 VBL
;   LOC_8232: RST $08 / wait until $7360==$FF (scroll settled); loop
; =============================================================================
SUB_819C:
    LD      A, $01
    LD      ($708B), A                  ; RAM $708B
    LD      A, $01
    LD      ($703F), A                  ; RAM $703F
    CALL    SUB_94EB
    LD      A, $01
    LD      ($707F), A                  ; RAM $707F
    LD      A, $00
    LD      DE, $0020
    LD      HL, $2120
    CALL    FILL_VRAM
    LD      DE, $BB27
    LD      BC, $2140
    CALL    VDP_REG_A958
    LD      BC, $2150
    CALL    VDP_REG_A958
    LD      A, $35
    LD      DE, $0060
    LD      HL, $2160
    CALL    FILL_VRAM
    LD      BC, $21B4
    LD      DE, $BD44
    CALL    VDP_REG_A958
    LD      BC, $2177
    LD      DE, $BDB4
    CALL    VDP_REG_A958
    LD      IX, $2300
    LD      DE, $857F
    LD      HL, $001C
    CALL    VDP_REG_BEFA
    LD      HL, $8251
    LD      DE, $72C6                   ; RAM $72C6
    LD      BC, $0018
    LDIR    
    LD      HL, $888E
    LD      ($709B), HL                 ; RAM $709B
    LD      A, $6D
    LD      ($7097), A                  ; RAM $7097
    LD      A, $50
    LD      ($7098), A                  ; RAM $7098
    CALL    SUB_876B
    LD      A, $0E
    LD      ($732D), A                  ; RAM $732D
    LD      BC, $007C
    LD      DE, $2380
    LD      HL, $72B6                   ; RAM $72B6
    CALL    VDP_REG_BF8A
    LD      B, $01
    LD      C, $C2
    CALL    WRITE_REGISTER
    LD      A, $01
    LD      ($707D), A                  ; RAM $707D
    LD      A, $00
    LD      ($709F), A                  ; RAM $709F

LOC_8232:
    RST     $08
    LD      A, ($7360)                  ; RAM $7360
    CP      $FF
    JR      NZ, LOC_8232
    LD      A, ($709F)                  ; RAM $709F
    CP      $01
    RET     Z
    LD      A, $01
    LD      ($709F), A                  ; RAM $709F
    LD      A, $13
    LD      B, A
    CALL    PLAY_IT
    JR      LOC_8232

; =============================================================================
; NMI ($824D) -- interrupt handler (stub only)
; =============================================================================
; The /NMI interrupt handler is a single RET instruction.
; This game performs all per-frame synchronization via RST $08 (see CART_ENTRY
; block above).  The bytes following RET are RST $08 routine data embedded
; inline and accessed only via the $AA6F trampoline, not as instructions.
; =============================================================================
NMI:                                        ; NMI ($824D): hardware NMI unused; VBL done via RST $08 -> $AA6F
    RET                                     ; RET: immediately return from NMI (no frame work here)
    DB      $B6, $BF, $B5, $4F, $C0, $D4, $09, $4F
    DB      $C8, $E0, $0B, $5F, $B8, $D8, $09, $5F
    DB      $C8, $DC, $09, $5F, $C8, $E4, $0B, $50
    DB      $80, $E8, $06

; =============================================================================
; VDP_DATA_8269 ($8269) -- title screen display init
; Called from START after cold boot to set up the title screen.
; Sequence:
;   CALL MODE_1                  -- set VDP mode 2 (graphics mode)
;   WRITE_REGISTER BC=$0744      -- VDP reg 7 = $44 (border/text colour)
;   FILL_VRAM $2000,$0020,$F4    -- write $20 bytes $F4 to colour table
;   CALL LOAD_ASCII              -- load ASCII font tiles into VRAM
;   FILL_VRAM $1B00,$0002,$D0    -- write 2 marker bytes to VRAM $1B00
;   FILL_VRAM $1800,$0300,$20    -- clear name-table (768 bytes, space $20)
;   VDP_REG_BEFA IX=$1828 DE=$BE6A HL=$0090
;                                -- write title string ($90 bytes) to VRAM
;   WRITE_REGISTER BC=$01C2      -- VDP reg 1 = $C2: enable display
;   LD A,$F0 -> ($707D)          -- set VBL delay count = $F0 frames/tick
;   RST $08                      -- VBL sync (spin one full delay cycle)
; Returns to START which then falls through to SUB_82B2 (GAME_OPT).
; =============================================================================
VDP_DATA_8269:                              ; VDP_DATA_8269 ($8269): title screen VDP init (MODE_1, FILL_VRAM x3, LOAD_ASCII)
    CALL    MODE_1
    LD      B, $07
    LD      C, $44
    CALL    WRITE_REGISTER
    LD      A, $F4
    LD      DE, $0020
    LD      HL, $2000
    CALL    FILL_VRAM
    CALL    LOAD_ASCII
    LD      A, $D0
    LD      DE, $0002
    LD      HL, $1B00
    CALL    FILL_VRAM
    LD      A, $20
    LD      DE, $0300
    LD      HL, $1800
    CALL    FILL_VRAM
    LD      IX, $1828
    LD      DE, $BE6A
    LD      HL, $0090
    CALL    VDP_REG_BEFA
    LD      B, $01
    LD      C, $C2
    CALL    WRITE_REGISTER
    LD      A, $F0
    LD      ($707D), A                  ; RAM $707D
    RST     $08
    RET     

SUB_82B2:                                   ; SUB_82B2 ($82B2): GAME_OPT screen -- prompt for 1 or 2 players; set $703D
    LD      A, $01
    LD      ($703D), A                  ; RAM $703D
    LD      A, $01
    LD      ($70A3), A                  ; RAM $70A3
    LD      HL, $0E10
    LD      ($70A1), HL                 ; RAM $70A1

LOC_82C2:
    CALL    GAME_OPT
    CALL    SUB_939A
    LD      ($7044), A                  ; RAM $7044
    CP      $09
    JR      Z, LOC_82DD
    CP      $05
    RET     C
    SUB     $04
    LD      ($7044), A                  ; RAM $7044
    LD      A, $02
    LD      ($703D), A                  ; RAM $703D
    RET     

LOC_82DD:
    CALL    SOUND_WRITE_82E3
    JR      C, LOC_82C2
    RET     

SOUND_WRITE_82E3:                           ; SOUND_WRITE_82E3 ($82E3): attract mode joystick poll loop
    LD      HL, $8547

LOC_82E6:
    LD      A, (HL)
    LD      C, A
    CP      $FF
    JR      Z, LOC_82F7
    INC     HL
    LD      E, (HL)
    INC     HL
    PUSH    HL
    CALL    SUB_832C
    POP     HL
    JR      NC, LOC_82E6
    RET     

LOC_82F7:
    LD      A, ($7044)                  ; RAM $7044
    CP      $09
    RET     Z
    LD      A, $20
    LD      DE, $0300
    LD      HL, $1800
    CALL    FILL_VRAM
    LD      IX, $18E8
    LD      DE, $BE8D
    LD      HL, $0017
    CALL    VDP_REG_BEFA
    LD      IX, $19AC
    LD      DE, $8554
    LD      HL, $0016
    CALL    VDP_REG_BEFA
    LD      A, $B4
    LD      ($707D), A                  ; RAM $707D
    RST     $08
    XOR     A
    SUB     $01
    RET     

SUB_832C:                                   ; SUB_832C ($832C): wait-for-VBL (RST $08) + POLLER + fire-button check
    LD      B, $78

LOC_832E:
    PUSH    BC
    PUSH    DE

LOC_8330:
    CALL    READ_REGISTER
    BIT     7, A
    JR      Z, LOC_8330
    CALL    POLLER
    LD      A, ($7031)                  ; RAM $7031
    POP     DE
    POP     BC
    CP      C
    RET     Z
    CP      E
    JR      NZ, LOC_834B
    LD      A, $4D
    LD      ($7044), A                  ; RAM $7044
    XOR     A
    RET     

LOC_834B:
    DJNZ    LOC_832E
    SCF     
    RET     

SUB_834F:                                   ; SUB_834F ($834F): load level data ptr; index $9488 table by level -> $7042/$7066/$7067
    LD      A, ($7044)                  ; RAM $7044
    CP      $09
    JR      NZ, LOC_835F
    LD      A, $03
    LD      ($7045), A                  ; RAM $7045
    LD      A, $01
    JR      LOC_8366

LOC_835F:
    DEC     A
    LD      ($7045), A                  ; RAM $7045
    LD      A, ($7044)                  ; RAM $7044

LOC_8366:
    CALL    DELAY_LOOP_8513
    XOR     A
    LD      ($7064), A                  ; RAM $7064
    LD      D, A
    LD      A, ($94B8)
    LD      E, A
    DEC     E
    ADD     HL, DE
    LD      A, (HL)
    LD      ($7065), A                  ; RAM $7065
    LD      HL, $94B8
    LD      ($7040), HL                 ; RAM $7040
    LD      A, (HL)
    LD      ($703F), A                  ; RAM $703F
    LD      A, $01
    LD      ($7047), A                  ; RAM $7047
    LD      A, $05
    LD      ($703E), A                  ; RAM $703E
    LD      A, $F0
    LD      ($7046), A                  ; RAM $7046
    RET     

SUB_8392:                                   ; SUB_8392 ($8392): full VDP + tile init (5x INIT_TABLE, VDP_REG_BEFA x6, WRITE_REGISTER)
    LD      HL, $852D
    LD      A, $04

LOC_8397:
    PUSH    AF
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    INC     HL
    DB      $EB
    PUSH    DE
    CALL    INIT_TABLE
    POP     HL
    POP     AF
    DEC     A
    JP      P, LOC_8397
    LD      B, $01
    LD      C, $82
    CALL    WRITE_REGISTER
    LD      B, $07
    LD      C, $11
    CALL    WRITE_REGISTER
    LD      IX, $2300
    LD      DE, $859B
    LD      HL, $001C
    CALL    VDP_REG_BEFA
    LD      IX, BOOT_UP
    LD      DE, $AE94
    LD      HL, $059D
    CALL    VDP_REG_BEFA
    LD      IX, $0800
    LD      DE, $AE94
    LD      HL, $059D
    CALL    VDP_REG_BEFA
    LD      IX, $1000
    LD      DE, $AE94
    LD      HL, $059D
    CALL    VDP_REG_BEFA
    LD      IX, $1800
    LD      DE, $AE94
    LD      HL, $059D
    CALL    VDP_REG_BEFA
    LD      IX, $2800
    LD      DE, $B431
    LD      HL, $0608
    CALL    VDP_REG_BEFA
    CALL    SUB_8492
    LD      HL, BOOT_UP
    LD      A, $03
    CALL    INIT_TABLE
    LD      A, $07
    LD      ($707E), A                  ; RAM $707E
    LD      ($7068), HL                 ; RAM $7068
    LD      A, $01
    LD      ($706E), A                  ; RAM $706E
    LD      A, $10
    LD      ($7095), A                  ; RAM $7095
    LD      A, $10
    LD      ($7096), A                  ; RAM $7096
    LD      A, $D0
    LD      ($732E), A                  ; RAM $732E
    LD      ($732F), A                  ; RAM $732F
    LD      A, $01
    LD      ($707F), A                  ; RAM $707F
    LD      ($708B), A                  ; RAM $708B
    LD      BC, $22C0
    LD      DE, $BA39
    CALL    VDP_REG_A958
    LD      BC, $000D
    LD      DE, $3400
    LD      HL, $703E                   ; RAM $703E
    CALL    VDP_REG_BF8A
    LD      A, ($703D)                  ; RAM $703D
    CP      $01
    JR      Z, LOC_8467
    LD      ($7047), A                  ; RAM $7047
    LD      BC, $000D
    LD      DE, $3414
    LD      HL, $703E                   ; RAM $703E
    CALL    VDP_REG_BF8A
    LD      A, $01
    LD      ($7047), A                  ; RAM $7047
    JR      LOC_8484

LOC_8467:
    LD      A, $00
    LD      DE, $000D
    LD      HL, $3414
    CALL    FILL_VRAM
    LD      HL, $E9E8
    LD      ($709F), HL                 ; RAM $709F
    LD      BC, $0002
    LD      DE, $22C8
    LD      HL, $709F                   ; RAM $709F
    CALL    VDP_REG_BF8A

LOC_8484:
    CALL    SUB_875C
    CALL    SUB_94EB
    LD      B, $01
    LD      C, $C2
    CALL    WRITE_REGISTER
    RET     

SUB_8492:                                   ; SUB_8492 ($8492): init scroll column ring buffer ptrs $709F/$70A1/$70A3
    LD      HL, BOOT_UP
    LD      ($709F), HL                 ; RAM $709F

LOC_8498:
    LD      HL, ($709F)                 ; RAM $709F
    LD      BC, $0008
    ADD     HL, BC
    LD      ($70A1), HL                 ; RAM $70A1
    LD      BC, $07F8
    ADD     HL, BC
    LD      ($70A3), HL                 ; RAM $70A3
    CALL    SUB_84B8
    LD      ($709F), HL                 ; RAM $709F
    LD      BC, $1800
    AND     A
    SBC     HL, BC
    JR      C, LOC_8498
    RET     

SUB_84B8:                                   ; SUB_84B8 ($84B8): merge two VRAM tile planes into combined scroll surface
    PUSH    HL
    LD      BC, $0238

LOC_84BC:
    PUSH    BC
    LD      HL, ($709F)                 ; RAM $709F
    DB      $EB
    LD      BC, $0001
    LD      HL, $737F                   ; RAM $737F
    PUSH    HL
    CALL    READ_VRAM
    POP     HL
    LD      C, (HL)
    PUSH    BC
    LD      HL, ($70A1)                 ; RAM $70A1
    DB      $EB
    LD      BC, $0001
    LD      HL, $737F                   ; RAM $737F
    PUSH    HL
    CALL    READ_VRAM
    POP     HL
    LD      A, (HL)
    POP     BC
    SLA     A
    RL      C
    SLA     A
    RL      C
    LD      HL, ($70A3)                 ; RAM $70A3
    DB      $EB
    LD      A, C
    LD      HL, $737F                   ; RAM $737F
    LD      (HL), A
    LD      BC, $0001
    CALL    WRITE_VRAM
    LD      HL, ($709F)                 ; RAM $709F
    INC     HL
    LD      ($709F), HL                 ; RAM $709F
    LD      HL, ($70A1)                 ; RAM $70A1
    INC     HL
    LD      ($70A1), HL                 ; RAM $70A1
    LD      HL, ($70A3)                 ; RAM $70A3
    INC     HL
    LD      ($70A3), HL                 ; RAM $70A3
    POP     BC
    DEC     BC
    LD      A, B
    OR      C
    JR      NZ, LOC_84BC
    POP     HL
    RET     

DELAY_LOOP_8513:                            ; DELAY_LOOP_8513 ($8513): level table lookup; index $9488 by level -> $7042/$7066/$7067
    DEC     A
    LD      E, A
    LD      D, $00
    LD      HL, $9488
    LD      B, $0C

LOC_851C:
    ADD     HL, DE
    DJNZ    LOC_851C
    LD      ($7042), HL                 ; RAM $7042
    LD      A, (HL)
    LD      ($7066), A                  ; RAM $7066
    INC     HL
    LD      A, (HL)
    LD      ($7067), A                  ; RAM $7067
    INC     HL
    RET     
    DB      $00, $23, $00, $00, $00, $20, $00, $28
    DB      $80, $23, $B0, $10, $24, $0E, $B0, $20
    DB      $24, $00, $B0, $30, $24, $00, $B0, $40
    DB      $24, $00, $00, $00, $0F, $0F, $03, $04
    DB      $0F, $0F, $00, $00, $0F, $0F, $FF, $07
    DB      $52, $20, $42, $41, $4E, $4B, $53, $77 ; "R BANKSw"
    DB      $20, $0B, $4D, $4C, $20, $4F, $27, $52
    DB      $4F, $55, $52, $4B, $45, $E1, $5E, $3A
    DB      $7D, $3F, $11, $3F, $E1, $5A, $35, $1E
    DB      $1D, $DE, $F5, $9F, $3F, $65, $15, $15
    DB      $95, $EE, $46, $A5, $06, $AF, $F5, $1A
    DB      $35, $3A, $36, $43, $3F, $0E, $13, $5A
    DB      $35, $1E, $1D, $DE, $F5, $1F, $1F, $65
    DB      $15, $15, $95, $AF, $43, $E1, $46, $B5
    DB      $06, $BF, $F5, $F5, $35, $3A, $36, $43
    DB      $3F, $0E, $13, $5A, $35, $1E, $1D, $DE
    DB      $F5, $9F, $3F, $65, $15, $15, $95, $AF
    DB      $43, $E1

SUB_85B7:                                   ; SUB_85B7 ($85B7): B.C. vertical movement (DEC Y-pos; boundary at $02/$60)
    LD      HL, $7092                   ; RAM $7092
    CALL    SUB_87CC
    JR      NZ, LOC_85C5
    LD      HL, $7094                   ; RAM $7094
    CALL    SUB_87CC

LOC_85C5:
    LD      A, ($705E)                  ; RAM $705E
    LD      E, A
    BIT     3, E
    JR      Z, LOC_85ED
    LD      A, ($7098)                  ; RAM $7098
    CP      $41
    JR      C, LOC_85ED
    LD      A, ($709A)                  ; RAM $709A
    DEC     A
    LD      ($709A), A                  ; RAM $709A
    LD      A, ($7098)                  ; RAM $7098
    DEC     A
    LD      ($7098), A                  ; RAM $7098
    CP      $40
    JR      Z, LOC_85ED
    LD      A, ($7098)                  ; RAM $7098
    DEC     A
    LD      ($7098), A                  ; RAM $7098

LOC_85ED:
    BIT     1, E
    JR      Z, LOC_861A
    LD      C, $B4
    LD      A, ($703F)                  ; RAM $703F
    CP      $05
    JR      NZ, LOC_85FC
    LD      C, $58

LOC_85FC:
    LD      A, ($7098)                  ; RAM $7098
    CP      C
    JR      NC, LOC_861A
    LD      A, ($709A)                  ; RAM $709A
    INC     A
    LD      ($709A), A                  ; RAM $709A
    LD      A, ($7098)                  ; RAM $7098
    INC     A
    LD      ($7098), A                  ; RAM $7098
    CP      C
    JR      Z, LOC_861A
    LD      A, ($7098)                  ; RAM $7098
    INC     A
    LD      ($7098), A                  ; RAM $7098

LOC_861A:
    LD      A, ($703F)                  ; RAM $703F
    CP      $03
    JR      Z, LOC_8625
    CP      $05
    JR      NZ, LOC_866C

LOC_8625:
    LD      A, ($7097)                  ; RAM $7097
    LD      B, A
    LD      A, ($7099)                  ; RAM $7099
    LD      D, A
    LD      A, ($709A)                  ; RAM $709A
    CP      $02
    JR      NZ, LOC_864B
    LD      A, $04
    LD      ($709A), A                  ; RAM $709A
    LD      A, ($703F)                  ; RAM $703F
    CP      $03
    JR      NZ, LOC_8644
    LD      L, $01
    JR      LOC_8646

LOC_8644:
    LD      L, $FF

LOC_8646:
    CALL    SUB_8817
    JR      LOC_8664

LOC_864B:
    CP      $06
    JR      NZ, LOC_866C
    LD      A, $04
    LD      ($709A), A                  ; RAM $709A
    LD      A, ($703F)                  ; RAM $703F
    CP      $03
    JR      NZ, LOC_865F
    LD      L, $FF
    JR      LOC_8661

LOC_865F:
    LD      L, $01

LOC_8661:
    CALL    SUB_8817

LOC_8664:
    LD      A, B
    LD      ($7097), A                  ; RAM $7097
    LD      A, D
    LD      ($7099), A                  ; RAM $7099

LOC_866C:
    CALL    SUB_876B
    LD      A, ($7092)                  ; RAM $7092
    OR      A
    JR      NZ, LOC_86C0
    LD      A, ($7094)                  ; RAM $7094
    OR      A
    JR      NZ, LOC_86ED
    LD      A, ($7093)                  ; RAM $7093
    OR      A
    JR      Z, LOC_8694
    LD      A, ($707C)                  ; RAM $707C
    LD      C, A
    LD      A, ($7093)                  ; RAM $7093
    SUB     C
    LD      ($7093), A                  ; RAM $7093
    JR      Z, LOC_8694
    JR      NC, LOC_86F4
    XOR     A
    LD      ($7093), A                  ; RAM $7093

LOC_8694:
    BIT     0, E
    JR      Z, LOC_86C9
    LD      A, $10
    LD      ($7093), A                  ; RAM $7093
    LD      A, ($7097)                  ; RAM $7097
    LD      ($7099), A                  ; RAM $7099
    LD      A, ($7091)                  ; RAM $7091
    LD      ($7092), A                  ; RAM $7092
    LD      A, ($7097)                  ; RAM $7097
    SUB     $0A
    LD      ($7097), A                  ; RAM $7097
    CALL    SUB_876B
    LD      A, $16
    LD      B, A
    CALL    PLAY_IT
    LD      A, $01
    LD      B, A
    CALL    PLAY_IT

LOC_86C0:
    LD      IY, $8837
    CALL    SUB_87E2
    JR      LOC_8728

LOC_86C9:
    BIT     2, E
    JR      Z, LOC_86F4
    LD      A, $0E
    LD      ($7093), A                  ; RAM $7093
    LD      A, ($7097)                  ; RAM $7097
    LD      ($7099), A                  ; RAM $7099
    LD      A, ($7091)                  ; RAM $7091
    LD      ($7094), A                  ; RAM $7094
    CALL    SUB_876B
    LD      A, $16
    LD      B, A
    CALL    PLAY_IT
    LD      A, $02
    LD      B, A
    CALL    PLAY_IT

LOC_86ED:
    LD      IY, $8828
    CALL    SUB_87E2

LOC_86F4:
    LD      A, ($707D)                  ; RAM $707D
    LD      C, A
    LD      A, ($7096)                  ; RAM $7096
    SUB     C
    LD      ($7096), A                  ; RAM $7096
    CP      $08
    JR      Z, LOC_8705
    JR      NC, LOC_8728

LOC_8705:
    LD      A, $10
    LD      ($7096), A                  ; RAM $7096
    LD      HL, $7326                   ; RAM $7326
    LD      A, ($7097)                  ; RAM $7097
    ADD     A, $26
    LD      D, A
    CALL    SUB_8802
    LD      HL, $732A                   ; RAM $732A
    LD      A, (HL)
    ADD     A, E
    LD      (HL), A
    LD      HL, $0040
    LD      A, ($7097)                  ; RAM $7097
    ADD     A, $1E
    LD      D, A
    CALL    SUB_8802

LOC_8728:
    LD      A, ($707D)                  ; RAM $707D
    LD      C, A
    LD      A, ($7095)                  ; RAM $7095
    SUB     C
    LD      ($7095), A                  ; RAM $7095
    CP      $08
    JR      Z, LOC_873A
    JR      C, LOC_873A
    RET     

LOC_873A:
    LD      A, $10
    LD      ($7095), A                  ; RAM $7095
    LD      A, ($708D)                  ; RAM $708D
    OR      A
    JR      Z, LOC_8750
    LD      A, ($708E)                  ; RAM $708E
    LD      ($730C), A                  ; RAM $730C
    XOR     A
    LD      ($708D), A                  ; RAM $708D
    RET     

LOC_8750:
    LD      A, ($708F)                  ; RAM $708F
    LD      ($730C), A                  ; RAM $730C
    LD      A, $01
    LD      ($708D), A                  ; RAM $708D
    RET     

SUB_875C:
    LD      A, $65
    LD      ($7097), A                  ; RAM $7097
    LD      A, $40
    LD      ($7098), A                  ; RAM $7098
    LD      A, $0A
    LD      ($708C), A                  ; RAM $708C

SUB_876B:                                   ; SUB_876B ($876B): copy IX-table coord offsets to $7097/$7098; build $7306 sprite entry
    EXX                                     ; A = B.C. X position ($7097)
    LD      IX, ($709B)                 ; RAM $709B
    LD      A, ($708C)                      ; A = B.C. Y position ($7098)
    LD      B, A
    LD      IY, $7306                       ; HL=$7306 = sprite attribute buffer target (IY write)
    LD      DE, $0004
    PUSH    BC

LOC_877C:
    LD      A, ($7097)                  ; RAM $7097
    ADD     A, (IX+0)
    LD      (IY+0), A
    LD      A, ($7098)                  ; RAM $7098
    ADD     A, (IX+1)
    LD      (IY+1), A
    LD      A, (IX+2)
    LD      (IY+2), A
    LD      A, (IX+3)
    LD      (IY+3), A
    LD      A, (IY+0)
    CP      $AF
    JR      NC, LOC_87A8
    LD      A, (IY+1)
    CP      $0F
    JR      NC, LOC_87AC

LOC_87A8:
    LD      (IY+3), $00

LOC_87AC:
    ADD     IX, DE
    ADD     IY, DE
    DJNZ    LOC_877C
    POP     BC
    LD      A, $08
    SUB     B
    JR      C, LOC_87CA
    JR      Z, LOC_87CA
    LD      B, A
    XOR     A

LOC_87BC:
    LD      (IY+0), $E0
    LD      (IY+1), A
    LD      (IY+3), A
    ADD     IY, DE
    DJNZ    LOC_87BC

LOC_87CA:
    EXX     
    RET     

SUB_87CC:                                   ; SUB_87CC ($87CC): countdown: DEC (HL) by $707D; at zero restore $7097 from $7099
    LD      A, ($707D)                      ; A = (HL): current countdown value
    LD      C, A                            ; CP $FF: already expired (terminal sentinel)
    LD      A, (HL)                         ; RET Z: already expired, nothing to do
    OR      A
    RET     Z                               ; A = frame delay ($707D)
    SUB     C                               ; subtract frame delay from counter
    LD      (HL), A                         ; JR C: counter crossed zero -> restore X
    JR      Z, LOC_87DA                     ; LD (HL),A: write decremented counter back
    RET     NC                              ; RET: not expired yet
    XOR     A
    LD      (HL), A

LOC_87DA:
    LD      A, ($7099)                  ; RAM $7099
    LD      ($7097), A                  ; RAM $7097
    OR      A
    RET     

SUB_87E2:                                   ; SUB_87E2 ($87E2): add signed delta from IY entry to $7306 sprite X positions
    LD      B, $00

LOC_87E4:
    LD      IX, $7306                   ; RAM $7306
    LD      C, (IY+0)
    ADD     IX, BC
    LD      A, (IY+1)
    ADD     A, (IX+0)
    LD      (IX+0), A
    INC     IY
    INC     IY
    LD      A, $64
    CP      (IY+0)
    JR      NZ, LOC_87E4
    RET     

SUB_8802:                                   ; SUB_8802 ($8802): add R-register random jitter (AND $7090) to sprite X offset
    LD      A, ($7090)                      ; A = R register (Z80 refresh counter = pseudo-random)
    LD      E, A                            ; AND $7090: apply random mask (difficulty controls entropy)
    LD      A, R                            ; A = (IX+0): current sprite X
    AND     E                               ; add jitter to sprite X
    LD      E, A                            ; write jittered X back to sprite entry
    LD      A, (HL)
    DEC     A
    CP      D
    JR      NC, LOC_8813
    LD      A, E
    NEG     
    LD      E, A

LOC_8813:
    LD      A, (HL)
    ADD     A, E
    LD      (HL), A
    RET     

SUB_8817:                                   ; SUB_8817 ($8817): if jump timers $7092/$7094 active, adjust B by sprite height L
    LD      A, ($7092)                  ; RAM $7092
    LD      C, A
    LD      A, ($7094)                  ; RAM $7094
    OR      C
    JR      Z, LOC_8824
    LD      A, L
    ADD     A, D
    LD      D, A

LOC_8824:
    LD      A, L
    ADD     A, B
    LD      B, A
    RET     
    DB      $00, $07, $04, $07, $08, $05, $0C, $05
    DB      $10, $07, $14, $05, $18, $05, $64, $1C
    DB      $FB, $20, $FB, $24, $FB, $64, $00, $00
    DB      $00, $09, $04, $04, $10, $01, $14, $00
    DB      $18, $01, $14, $F0, $08, $01, $04, $10
    DB      $04, $09, $10, $00, $0C, $09, $10, $F0
    DB      $14, $09, $1E, $F0, $1C, $09, $26, $F2
    DB      $20, $01, $26, $F0, $24, $0E, $00, $00
    DB      $40, $09, $01, $FA, $44, $01, $F0, $00
    DB      $00, $00, $11, $F7, $54, $01, $04, $FA
    DB      $4C, $09, $14, $F4, $50, $09, $15, $F0
    DB      $5C, $01, $21, $F2, $58, $09, $28, $F3
    DB      $20, $01, $28, $F1, $24, $0E, $00, $00
    DB      $2C, $01, $00, $00, $34, $09, $10, $00
    DB      $30, $01, $10, $00, $38, $09, $14, $F0
    DB      $08, $01, $10, $F0, $14, $09, $14, $00
    DB      $18, $01, $1E, $F0, $1C, $09, $26, $F2
    DB      $20, $01, $26, $F0, $24, $0E, $00, $00
    DB      $3C, $01, $00, $00, $34, $09, $10, $00
    DB      $30, $01, $10, $00, $38, $09, $14, $F0
    DB      $08, $01, $10, $F0, $14, $09, $14, $00
    DB      $18, $01, $1E, $F0, $1C, $09, $26, $F2
    DB      $20, $01, $26, $F0, $24, $0E, $08, $00
    DB      $A8, $01, $14, $F0, $08, $01, $08, $00
    DB      $A4, $09, $10, $F0, $14, $09, $04, $F0
    DB      $00, $00, $10, $00, $0C, $09, $14, $00
    DB      $18, $01, $1E, $F0, $1C, $09, $26, $F2
    DB      $20, $01, $26, $F0, $24, $0E, $00, $00
    DB      $C0, $01, $00, $00, $BC, $09, $10, $00
    DB      $C8, $01, $10, $00, $C4, $09, $F0, $00
    DB      $00, $00, $E0, $00, $00, $00, $D0, $00
    DB      $00, $00, $1E, $00, $D4, $0E, $1E, $00
    DB      $D0, $01, $1E, $00, $CC, $09, $08, $F0
    DB      $AC, $09, $08, $DC, $B0, $09, $E0, $F0
    DB      $B8, $01, $08, $F0, $AC, $09, $08, $DC
    DB      $B0, $09, $E0, $F0, $B4, $01

SUB_8946:                                   ; SUB_8946 ($8946): sprite tile animation; advance scroll tile columns; $703F dispatch
    LD      A, ($703F)                  ; RAM $703F
    CP      $0A
    JP      Z, LOC_8A51
    CP      $08
    JP      Z, LOC_8A51
    CP      $04
    JP      NZ, LOC_8A20
    LD      A, ($706A)                  ; RAM $706A
    CP      $00
    JR      NZ, LOC_897D
    LD      HL, ($7077)                 ; RAM $7077
    LD      A, L
    OR      H
    JR      Z, LOC_897D
    LD      BC, $0011
    AND     A
    SBC     HL, BC
    JP      NC, LOC_8A32
    LD      HL, $BC1B
    LD      ($706B), HL                 ; RAM $706B
    LD      A, ($BC1C)
    LD      ($706A), A                  ; RAM $706A
    JR      LOC_89C1

LOC_897D:
    LD      BC, $0005
    LD      DE, $716E                   ; RAM $716E
    LD      HL, $7146                   ; RAM $7146
    CALL    SUB_8A8A
    LD      BC, $000D
    LD      DE, $71DE                   ; RAM $71DE
    LD      HL, $7176                   ; RAM $7176
    CALL    SUB_8A8A
    LD      A, ($7063)                  ; RAM $7063
    LD      C, A
    LD      A, ($707C)                  ; RAM $707C
    ADD     A, C
    LD      ($7063), A                  ; RAM $7063
    CP      $08
    JR      C, LOC_89FC
    SUB     $08
    LD      ($7063), A                  ; RAM $7063
    LD      BC, $0005
    LD      DE, $716E                   ; RAM $716E
    LD      HL, $7146                   ; RAM $7146
    CALL    DELAY_LOOP_AAE1
    LD      BC, $000D
    LD      DE, $71DE                   ; RAM $71DE
    LD      HL, $7176                   ; RAM $7176
    CALL    DELAY_LOOP_AAE1

LOC_89C1:
    CALL    LOC_8A51
    LD      HL, $2000
    LD      BC, ($7056)                 ; RAM $7056
    ADD     HL, BC
    PUSH    HL
    LD      BC, $0020
    LD      DE, $70A6                   ; RAM $70A6
    DB      $EB
    CALL    VDP_REG_BF8A
    POP     HL
    LD      BC, $0020
    ADD     HL, BC
    LD      B, $04

LOC_89DE:
    PUSH    BC
    PUSH    HL
    LD      DE, $70C6                   ; RAM $70C6
    LD      BC, $0040
    DB      $EB
    CALL    VDP_REG_BF8A
    POP     HL
    LD      BC, $0040
    ADD     HL, BC
    POP     BC
    DJNZ    LOC_89DE
    LD      DE, $7106                   ; RAM $7106
    LD      BC, $0040
    DB      $EB
    CALL    VDP_REG_BF8A

LOC_89FC:
    LD      HL, ($709D)                 ; RAM $709D
    LD      BC, $0240
    ADD     HL, BC
    LD      DE, $7146                   ; RAM $7146
    LD      BC, $0028
    DB      $EB
    CALL    VDP_REG_BF8A
    LD      HL, ($709D)                 ; RAM $709D
    LD      BC, $0280
    ADD     HL, BC
    LD      DE, $7176                   ; RAM $7176
    LD      BC, $0068
    DB      $EB
    CALL    VDP_REG_BF8A
    JR      LOC_8A32

LOC_8A20:
    LD      A, ($707E)                  ; RAM $707E
    DEC     A
    LD      ($707E), A                  ; RAM $707E
    JR      NZ, LOC_8A32
    LD      A, ($707B)                  ; RAM $707B
    LD      ($707E), A                  ; RAM $707E
    CALL    SUB_ABAD

LOC_8A32:
    LD      BC, ($7054)                 ; RAM $7054
    LD      DE, ($705A)                 ; RAM $705A
    LD      HL, ($7058)                 ; RAM $7058
    CALL    SUB_8A8A
    LD      A, ($703F)                  ; RAM $703F
    CP      $03
    CALL    Z, DELAY_LOOP_AB02
    LD      A, ($703F)                  ; RAM $703F
    CP      $05
    CALL    Z, SOUND_WRITE_AB34
    RET     

LOC_8A51:                                   ; LOC_8A51 ($8A51): tile column writer: load column from $706B ROM ptr -> $70C5 scroll buf
    CALL    DELAY_LOOP_ABBE
    LD      IX, ($706B)                 ; RAM $706B
    LD      A, ($706A)                  ; RAM $706A
    LD      C, A
    CP      $00
    RET     Z
    LD      A, (IX+1)
    LD      E, A
    LD      D, $00
    SUB     C
    LD      C, A
    LD      B, $00
    INC     BC
    INC     BC
    ADD     IX, BC
    LD      HL, $70C5                   ; RAM $70C5
    LD      A, ($7055)                  ; RAM $7055
    LD      B, A

LOC_8A74:
    PUSH    BC
    LD      A, (IX+0)
    LD      (HL), A
    LD      BC, $0020
    ADD     HL, BC
    ADD     IX, DE
    POP     BC
    DJNZ    LOC_8A74
    LD      A, ($706A)                  ; RAM $706A
    DEC     A
    LD      ($706A), A                  ; RAM $706A
    RET     

SUB_8A8A:                                   ; SUB_8A8A ($8A8A): select scroll update function from $8AC0 table by $707C speed
    EXX     
    LD      A, ($707C)                  ; RAM $707C
    LD      C, A
    DEC     C
    SLA     C
    LD      B, $00
    LD      HL, $8AC0
    ADD     HL, BC
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    PUSH    BC
    POP     IX
    EXX     
    PUSH    BC
    PUSH    DE
    PUSH    HL
    CALL    SUB_AA9D
    POP     HL
    POP     DE
    POP     BC
    LD      IX, $AAB8
    LD      A, ($707C)                  ; RAM $707C
    CP      $03
    JR      Z, LOC_8ABC
    CP      $05
    RET     C
    JR      NZ, LOC_8ABC
    LD      IX, $AAAC

LOC_8ABC:
    CALL    SUB_AA9D
    RET     
    DB      $AC, $AA, $B8, $AA, $AC, $AA, $CF, $AA
    DB      $CF, $AA, $CF, $AA

SUB_8ACC:                                   ; SUB_8ACC ($8ACC): add speed $707C to accumulator $70A5; count full-column advances in $7070
    LD      A, $00                          ; HL = scroll sub-pixel accumulator ($70A5)
    LD      ($7070), A                      ; A = scroll speed ($707C)
    LD      A, ($707C)                  ; RAM $707C
    LD      C, A                            ; add speed to accumulator low byte
    LD      A, ($70A5)                      ; ADC 0: propagate carry to high byte
    ADD     A, C
    LD      ($70A5), A                      ; HL = full-column advance counter ($7070)
                                            ; carry: one full column advance
LOC_8ADC:                                   ; INC ($7070): increment column advance count
    CP      $04
    JR      C, LOC_8AF1
    LD      A, ($7070)                  ; RAM $7070
    INC     A
    LD      ($7070), A                  ; RAM $7070
    LD      A, ($70A5)                  ; RAM $70A5
    SUB     $04
    LD      ($70A5), A                  ; RAM $70A5
    JR      LOC_8ADC

LOC_8AF1:
    LD      HL, ($7075)                 ; RAM $7075
    LD      A, H
    OR      L
    JR      Z, LOC_8B0E
    LD      IX, $7075                   ; RAM $7075
    CALL    SUB_901C
    JR      Z, LOC_8B03
    JR      NC, LOC_8B0E

LOC_8B03:
    LD      HL, BOOT_UP
    LD      ($7075), HL                 ; RAM $7075
    LD      C, $10
    CALL    SUB_8E2E

LOC_8B0E:
    LD      HL, ($7077)                 ; RAM $7077
    LD      A, H
    OR      L
    JR      Z, LOC_8B3E
    LD      IX, $7077                   ; RAM $7077
    CALL    SUB_901C
    JR      Z, LOC_8B2B
    JR      C, LOC_8B2B
    LD      BC, $0080
    AND     A
    SBC     HL, BC
    JP      C, LOC_8BA7
    JR      LOC_8B3E

LOC_8B2B:
    LD      HL, BOOT_UP
    LD      ($7077), HL                 ; RAM $7077
    LD      C, $0A
    CALL    SUB_8E2E
    LD      HL, $00FA
    LD      ($7064), HL                 ; RAM $7064
    JR      LOC_8BA7

LOC_8B3E:
    LD      IX, $7052                   ; RAM $7052
    CALL    SUB_901C
    JR      C, LOC_8B4F
    LD      BC, $0006
    AND     A
    SBC     HL, BC
    JR      NC, LOC_8B81

LOC_8B4F:
    LD      A, ($703F)                  ; RAM $703F
    CP      $08
    JR      C, LOC_8B6C
    LD      A, ($706A)                  ; RAM $706A
    OR      A
    JR      Z, LOC_8B6C
    LD      C, A
    LD      B, $00
    SLA     C
    SLA     C
    SLA     C
    LD      ($7052), BC                 ; RAM $7052
    JP      LOC_8BA7

LOC_8B6C:
    LD      HL, ($705C)                 ; RAM $705C
    LD      E, (HL)
    INC     HL
    PUSH    HL
    LD      BC, BOOT_UP
    CALL    SUB_8FFF
    DB      $EB
    POP     HL
    ADD     HL, DE
    LD      C, (HL)
    CALL    SUB_8E2E
    JR      LOC_8BA7

LOC_8B81:
    LD      A, ($706A)                  ; RAM $706A
    OR      A
    JR      NZ, LOC_8BA7
    LD      A, ($703F)                  ; RAM $703F
    CP      $08
    JR      C, LOC_8BA7
    LD      A, $02
    LD      ($706A), A                  ; RAM $706A
    JR      NZ, LOC_8B9A
    LD      BC, $BBE1
    JR      LOC_8BA3

LOC_8B9A:
    LD      BC, $BCAD
    LD      A, ($BCAE)
    LD      ($706A), A                  ; RAM $706A

LOC_8BA3:
    LD      ($706B), BC                 ; RAM $706B

LOC_8BA7:
    LD      IY, $7330                   ; RAM $7330

LOC_8BAB:
    LD      A, (IY+0)
    CP      $FE
    JR      Z, LOC_8BBE
    CP      $FF
    CALL    NZ, SUB_8C56
    LD      DE, $0004
    ADD     IY, DE
    JR      LOC_8BAB

LOC_8BBE:
    LD      IY, $7330                   ; RAM $7330
    LD      DE, $0004

LOC_8BC5:
    LD      A, (IY+0)
    CP      $FE
    RET     Z
    CP      $FF
    JP      Z, LOC_8C51
    LD      A, (IY+3)
    INC     A
    LD      IX, $72C2                   ; RAM $72C2

LOC_8BD8:
    ADD     IX, DE
    DEC     A
    JR      NZ, LOC_8BD8
    LD      A, (IY+1)
    LD      (IX+0), A
    LD      A, (IY+2)
    LD      (IX+1), A
    LD      A, (IY+0)
    CP      $12
    JR      NZ, LOC_8C00
    LD      A, (IX+0)
    LD      (IX+4), A
    LD      A, (IX+1)
    ADD     A, $10
    LD      (IX+5), A
    JR      LOC_8C51

LOC_8C00:
    CP      $10
    JR      NZ, LOC_8C1A
    LD      A, (IY+2)
    LD      (IX+5), A
    LD      (IX+9), A
    LD      A, (IY+1)
    LD      (IX+4), A
    ADD     A, $10
    LD      (IX+8), A
    JR      LOC_8C51

LOC_8C1A:
    CP      $0A
    JR      NZ, LOC_8C38
    LD      B, $03
    LD      A, (IX+1)
    LD      C, (IX+0)

LOC_8C26:
    ADD     IX, DE
    ADD     A, $10
    JR      NC, LOC_8C2E
    LD      A, $FF

LOC_8C2E:
    LD      (IX+1), A
    LD      (IX+0), C
    DJNZ    LOC_8C26
    JR      LOC_8C51

LOC_8C38:
    CP      $11
    JR      NZ, LOC_8C51
    LD      A, (IY+2)
    LD      (IX+5), A
    LD      A, (IY+1)
    LD      (IX+4), A
    CP      $90
    JR      NC, LOC_8C4E
    LD      A, $90

LOC_8C4E:
    LD      (IX+0), A

LOC_8C51:
    ADD     IY, DE
    JP      LOC_8BC5

SUB_8C56:                                   ; SUB_8C56 ($8C56): advance hazard X by scroll speed; remove if < $09 (off left edge)
    LD      A, (IY+0)                       ; A = (IY+0): hazard type byte
    LD      E, A                            ; LD E,A: save type
    CP      $10                             ; CP $10: type >= $10 means special (no simple speed sub)
    JR      NC, LOC_8C76
    LD      A, ($707C)                      ; A = scroll speed ($707C)
    LD      C, A
    LD      A, (IY+2)                       ; A = (IY+2): hazard X position
    SUB     C                               ; SUB C: subtract scroll speed from X
    LD      (IY+2), A                       ; write updated X back
    CP      $09                             ; CP $09: still on-screen? (X > 9)
    JR      NC, LOC_8C76
    LD      A, E                            ; A = type (restored)
    CP      $0B                             ; CP $0B: type $0B = special hazard (no removal)
    JR      Z, LOC_8C76
    CALL    SOUND_WRITE_8FBB                ; CALL SOUND_WRITE_8FBB: mark hazard removed, free sprite slot
    RET                                     ; RET: done

LOC_8C76:
    DEC     E
    LD      D, $00
    LD      HL, $9032
    SLA     E
    ADD     HL, DE
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    DB      $EB
    JP      (HL)
    DB      $3A, $7D, $70, $4F, $3A, $4F, $70, $91
    DB      $32, $4F, $70, $D0, $CD, $BB, $8F, $C9
    DB      $C9, $3A, $70, $70, $FE, $00, $C8, $4F
    DB      $FD, $7E, $00, $FE, $05, $FD, $7E, $01
    DB      $38, $03, $91, $18, $01, $81, $FD, $77
    DB      $01, $C9, $91, $FD, $77, $02, $3A, $70
    DB      $70, $FE, $00, $C8, $4F, $FD, $7E, $01
    DB      $81, $81, $FD, $77, $01, $FD, $4E, $03
    DB      $06, $00, $DD, $21, $C6, $72, $CB, $21
    DB      $CB, $21, $DD, $09, $DD, $7E, $02, $C6
    DB      $04, $FE, $78, $20, $02, $3E, $68, $DD
    DB      $77, $02, $C9, $2A, $73, $70, $3A, $45
    DB      $70, $4F, $06, $00, $A7, $ED, $42, $ED
    DB      $4B, $71, $70, $09, $22, $71, $70, $DD
    DB      $21, $E8, $90, $3A, $44, $70, $FE, $09
    DB      $20, $02, $3E, $01, $3D, $4F, $06, $00
    DB      $CB, $21, $CB, $10, $CB, $21, $CB, $10
    DB      $DD, $09, $DD, $4E, $00, $DD, $46, $01
    DB      $DD, $5E, $02, $DD, $56, $03, $CB, $7C
    DB      $20, $29, $A7, $ED, $52, $2A, $71, $70
    DB      $38, $14, $28, $0B, $ED, $53, $71, $70
    DB      $2A, $73, $70, $2B, $22, $73, $70, $7A ; "*sp+"spz"
    DB      $B7, $28, $2B, $C3, $AB, $8D, $CB, $78
    DB      $20, $24, $A7, $ED, $42, $38, $0D, $28
    DB      $16, $18, $1B, $CB, $78, $28, $05, $A7
    DB      $ED, $42, $30, $0B, $ED, $43, $71, $70
    DB      $2A, $73, $70, $23, $22, $73, $70, $78 ; "*sp#"spx"
    DB      $B7, $28, $03, $C3, $AB, $8D, $3A, $72
    DB      $70, $B7, $20, $43, $3A, $71, $70, $FD
    DB      $77, $02, $FD, $36, $01, $00, $3A, $70
    DB      $70, $FE, $00, $C8, $FD, $4E, $03, $06
    DB      $00, $DD, $21, $C6, $72, $CB, $21, $CB
    DB      $21, $DD, $09

SUB_8D87:                                   ; SUB_8D87 ($8D87): oscillate (IX+2) between $7C/$78/$80 using $706F flag
    LD      A, $7C                          ; A=$7C: mid-position reference
    CP      (IX+2)                          ; CP (IX+2): at mid-position?
    JR      Z, LOC_8D92                     ; JR Z, LOC_8D92: yes -> check oscillator flag
    LD      (IX+2), A                       ; LD (IX+2),A: snap to $7C if not already there
    RET     

LOC_8D92:
    LD      A, ($706F)                      ; A = oscillator flag ($706F): 0 or 1
    OR      A                               ; OR A: test flag
    JR      NZ, LOC_8DA2                    ; JR NZ, LOC_8DA2: flag=1 -> go to $80
    LD      A, $01                          ; A=$01: toggle flag to 1
    LD      ($706F), A                  ; RAM $706F
    LD      (IX+2), $78                     ; LD (IX+2),$78: set to $78 (lower position)
    RET     

LOC_8DA2:                                   ; XOR A: clear oscillator flag
    XOR     A
    LD      ($706F), A                  ; RAM $706F
    LD      (IX+2), $80                     ; LD (IX+2),$80: set to $80 (upper position)
    RET     
    DB      $FD, $36, $01, $E1, $FD, $36, $02, $00
    DB      $C9, $FE, $F7, $C0, $FD, $7E, $00, $FE
    DB      $0E, $3A, $6A, $70, $0E, $02, $38, $01
    DB      $0D, $B9, $C8, $FD, $36, $02, $FF, $C9
    DB      $FD, $7E, $01, $FE, $80, $30, $08, $C6
    DB      $04, $FD, $77, $01, $FE, $80, $D8, $FD
    DB      $7E, $02, $FE, $09, $D0, $CD, $BB, $8F
    DB      $C9, $FD, $E5, $E1, $01, $30, $73, $A7
    DB      $ED, $42, $CB, $3D, $CB, $3D, $4D, $06
    DB      $00, $21, $84, $70, $09, $ED, $5B, $88
    DB      $70, $EB, $09, $EB, $7E, $FE, $02, $20
    DB      $1D, $FD, $35, $01, $3A, $44, $70, $FE
    DB      $09, $20, $02, $3E, $01, $3D, $4F, $CB
    DB      $21, $3E, $82, $81, $4F, $FD, $7E, $01
    DB      $B9, $D0, $3E, $01, $77, $C9, $FD, $34
    DB      $01, $1A, $3D, $FD, $BE, $01, $D0, $3E
    DB      $02, $77, $C9

SUB_8E2E:                                   ; SUB_8E2E ($8E2E): find free slot in $7330 sprite table; load sprite data from $9056 table
    LD      HL, $9056                       ; HL=$9056: sprite type -> spawn-data lookup table

LOC_8E31:                                   ; LOC_8E31: scan $9056 table for matching type C
    LD      A, (HL)                         ; A=(HL): table entry type byte
    CP      $FE                             ; CP $FE: end-of-table sentinel
    SCF                                     ; SCF; RET Z: not found, return carry set
    RET     Z
    CP      C                               ; CP C: match current type?
    JR      Z, LOC_8E47                     ; JR Z, LOC_8E47: found -> allocate slot
    INC     HL
    LD      E, (HL)
    LD      D, $00
    INC     HL
    INC     HL
    INC     HL
    SLA     E
    RL      D
    ADD     HL, DE
    JR      LOC_8E31

LOC_8E47:
    LD      IY, $7330                       ; IY=$7330: sprite object table base
    LD      DE, $0004                       ; DE=$0004: slot stride (4 bytes per entry)

LOC_8E4E:
    LD      A, (IY+0)                       ; A=(IY+0): slot type byte
    CP      $FE                             ; CP $FE: end-of-table sentinel
    RET     Z                               ; RET Z: table full (no free slot)
    CP      $FF                             ; CP $FF: free slot marker
    JR      Z, LOC_8E5C                     ; JR Z, LOC_8E5C: found free slot -> fill it
    ADD     IY, DE
    JR      LOC_8E4E

LOC_8E5C:
    LD      A, (HL)
    LD      (IY+0), A
    INC     HL
    LD      IX, $72C6                   ; RAM $72C6
    LD      DE, $0004

LOC_8E68:
    LD      B, (HL)
    LD      A, $E0

LOC_8E6B:
    CP      (IX+0)
    JR      Z, LOC_8E74
    ADD     IX, DE
    JR      LOC_8E6B

LOC_8E74:
    PUSH    IX

LOC_8E76:
    CP      (IX+0)
    JR      Z, LOC_8E80
    ADD     IX, DE
    POP     BC
    JR      LOC_8E68

LOC_8E80:
    DEC     B
    JR      Z, LOC_8E87
    ADD     IX, DE
    JR      LOC_8E76

LOC_8E87:
    DB      $E3
    PUSH    HL
    POP     IX
    LD      DE, $72C6                   ; RAM $72C6
    AND     A
    SBC     HL, DE
    SRL     L
    SRL     L
    LD      (IY+3), L
    POP     HL
    LD      DE, $0004
    LD      B, (HL)
    INC     HL
    LD      A, (HL)
    LD      (IY+1), A
    INC     HL
    LD      A, (HL)
    LD      (IY+2), A
    INC     HL

LOC_8EA8:
    LD      A, (HL)
    LD      (IX+2), A
    INC     HL
    LD      A, (HL)
    LD      (IX+3), A
    INC     HL
    ADD     IX, DE
    DJNZ    LOC_8EA8
    LD      A, ($7066)                  ; RAM $7066
    LD      C, A
    LD      B, $00
    LD      A, ($7067)                  ; RAM $7067
    LD      E, A
    LD      D, $00
    CALL    SUB_8FFF
    LD      ($7052), HL                 ; RAM $7052
    LD      A, (IY+0)
    CP      $10
    JR      NZ, LOC_8EE8
    LD      BC, $0010
    LD      ($7071), BC                 ; RAM $7071
    LD      A, ($7045)                  ; RAM $7045
    LD      C, A
    LD      A, ($7062)                  ; RAM $7062
    CP      C
    JR      Z, LOC_8EE1
    INC     C

LOC_8EE1:
    LD      B, $00
    LD      ($7073), BC                 ; RAM $7073
    RET     

LOC_8EE8:
    CP      $0A
    JR      NZ, LOC_8EF3
    LD      HL, $012C
    LD      ($7052), HL                 ; RAM $7052
    RET     

LOC_8EF3:
    CP      $0C
    JR      NZ, LOC_8F03
    LD      A, $08
    LD      ($706A), A                  ; RAM $706A
    LD      HL, $BB97
    LD      ($706B), HL                 ; RAM $706B
    RET     

LOC_8F03:
    CP      $0D
    JR      NZ, LOC_8F13
    LD      A, $04
    LD      ($706A), A                  ; RAM $706A
    LD      HL, $BBF5
    LD      ($706B), HL                 ; RAM $706B
    RET     

LOC_8F13:
    CP      $0F
    JR      NZ, LOC_8F23
    LD      A, $04
    LD      ($706A), A                  ; RAM $706A
    LD      HL, $BC83
    LD      ($706B), HL                 ; RAM $706B
    RET     

LOC_8F23:
    CP      $0E
    JR      NZ, LOC_8F33
    LD      A, $04
    LD      ($706A), A                  ; RAM $706A
    LD      HL, $BC59
    LD      ($706B), HL                 ; RAM $706B
    RET     

LOC_8F33:
    CP      $11
    JR      NZ, LOC_8F65
    LD      IX, $72C6                   ; RAM $72C6
    LD      C, (IY+3)
    LD      B, $00
    SLA     C
    SLA     C
    ADD     IX, BC
    LD      A, ($7050)                  ; RAM $7050
    LD      (IX+1), A
    LD      (IY+2), A
    LD      (IX+5), A
    LD      A, ($7051)                  ; RAM $7051
    LD      (IX+4), A
    LD      (IY+1), A
    CP      $90
    JR      NC, LOC_8F61
    LD      A, $90

LOC_8F61:
    LD      (IX+0), A
    RET     

LOC_8F65:
    CP      $0B
    RET     NZ
    LD      BC, BOOT_UP
    LD      DE, $000A
    CALL    SUB_8FFF
    LD      C, (IY+2)
    SLA     L
    SLA     L
    SLA     L
    LD      A, L
    SLA     L
    ADD     A, L
    ADD     A, C
    LD      (IY+2), A
    LD      IX, $7330                   ; RAM $7330

LOC_8F86:
    LD      A, (IX+0)
    CP      $FE
    RET     Z
    CP      $FF
    JR      Z, LOC_8FB4
    LD      A, (IX+2)
    SUB     (IY+2)
    JR      C, LOC_8FA4
    JR      NZ, LOC_8FA6
    LD      A, (IX+1)
    CP      (IY+1)
    JR      NZ, LOC_8FAA
    JR      LOC_8FB4

LOC_8FA4:
    NEG     

LOC_8FA6:
    CP      $28
    JR      NC, LOC_8FB4

LOC_8FAA:
    CALL    SOUND_WRITE_8FBB
    LD      HL, $0004
    LD      ($7052), HL                 ; RAM $7052
    RET     

LOC_8FB4:
    LD      BC, $0004
    ADD     IX, BC
    JR      LOC_8F86

SOUND_WRITE_8FBB:                           ; SOUND_WRITE_8FBB ($8FBB): mark IY sprite removed ($FF); free $72C6 slots; play sound
    LD      C, (IY+0)                       ; C=(IY+0): save sprite type ID
    LD      (IY+0), $FF                     ; LD (IY+0),$FF: mark sprite slot free
    LD      IX, $9056                       ; IX=$9056: sprite-type -> sound+slot-count table

LOC_8FC6:
    LD      A, (IX+0)                       ; A=(IX+0): compare table entry type to C
    CP      C                               ; CP C: match?
    JR      Z, LOC_8FE1                     ; JR Z, LOC_8FE1: found -> free slots
    INC     IX
    LD      E, (IX+0)
    LD      D, $00
    INC     IX
    INC     IX
    INC     IX
    SLA     E
    RL      D
    ADD     IX, DE
    JR      LOC_8FC6

LOC_8FE1:
    LD      B, (IX+1)                       ; B=(IX+1): number of $72C6 slots to free
    LD      E, (IY+3)                       ; E=(IY+3): sprite index in $72C6 table
    LD      D, $00
    LD      IX, $72C6                       ; IX=$72C6: sprite attribute source table
    SLA     E                               ; SLA E: × 2
    SLA     E                               ; SLA E: × 4 (4-byte stride)
    ADD     IX, DE                          ; ADD IX,DE: point IX at first slot to clear
    LD      DE, $0004

LOC_8FF6:
    LD      (IX+0), $E0                     ; LD (IX+0),$E0: mark slot as free ($E0 sentinel)
    ADD     IX, DE
    DJNZ    LOC_8FF6
    RET     

SUB_8FFF:                                   ; SUB_8FFF ($8FFF): return HL = random value in [BC .. BC+DE-1] using R register
    DB      $EB
    LD      E, C
    LD      D, B
    AND     A
    SBC     HL, DE
    DB      $EB
    JR      Z, LOC_901A
    LD      H, $00                          ; LD H,$00: init HL=0 for random seed
    LD      A, D
    OR      A
    JR      Z, LOC_9011
    LD      A, R                            ; LD A,R: Z80 refresh counter (pseudo-random byte)
    LD      H, A                            ; LD H,A: use as high byte of seed

LOC_9011:
    LD      A, R                            ; LD A,R: second R read for extra entropy
    LD      L, A                            ; LD L,A: low byte of seed

LOC_9014:
    AND     A                               ; AND A: SBC HL,DE: reduce HL modulo DE
    SBC     HL, DE                          ; SBC HL,DE
    JR      NC, LOC_9014                    ; JR NC, LOC_9014: keep subtracting
    ADD     HL, DE                          ; ADD HL,DE: restore back into range

LOC_901A:
    ADD     HL, BC                          ; ADD HL,BC: add base (BC) -> result in [BC..BC+DE-1]
    RET     

SUB_901C:                                   ; SUB_901C ($901C): (IX+0:1) -= $707C (subtract scroll speed from 16-bit position)
    LD      L, (IX+0)                       ; L=(IX+0): low byte of position
    LD      H, (IX+1)                       ; H=(IX+1): high byte of position
    LD      A, ($707C)                      ; A=$707C: scroll speed
    LD      E, A
    LD      D, $00
    AND     A                               ; SBC HL,DE: subtract speed (16-bit)
    SBC     HL, DE
    LD      (IX+0), L                       ; LD (IX+0),L: write updated low byte
    LD      (IX+1), H                       ; LD (IX+1),H: write updated high byte
    RET     
    DB      $94, $8C, $94, $8C, $95, $8C, $95, $8C
    DB      $95, $8C, $95, $8C, $AE, $8C, $94, $8C
    DB      $94, $8C, $94, $8C, $CB, $8D, $B4, $8D
    DB      $B4, $8D, $B4, $8D, $B4, $8D, $DF, $8C
    DB      $E4, $8D, $84, $8C, $01, $01, $7E, $FF
    DB      $60, $0F, $02, $01, $7C, $FF, $64, $0A
    DB      $03, $01, $5C, $FF, $60, $0F, $04, $01
    DB      $58, $FF, $64, $0A, $05, $01, $9E, $FF
    DB      $60, $0F, $06, $01, $9C, $FF, $64, $0A
    DB      $07, $01, $58, $FF, $70, $08, $08, $01
    DB      $58, $FF, $60, $05, $09, $01, $54, $FF
    DB      $64, $0A, $0A, $04, $A0, $FF, $8C, $06
    DB      $90, $06, $94, $06, $98, $06, $0B, $01
    DB      $00, $00, $70, $06, $0C, $01, $30, $FF
    DB      $60, $00, $0D, $01, $88, $FF, $A0, $0B
    DB      $0E, $01, $48, $FF, $60, $00, $0F, $01
    DB      $A8, $FF, $60, $00, $10, $03, $00, $10
    DB      $7C, $0A, $84, $06, $88, $0A, $11, $02
    DB      $00, $00, $9C, $05, $D0, $0C, $12, $02
    DB      $20, $D0, $EC, $0F, $F0, $0F, $FE, $02
    DB      $01, $02, $04, $03, $04, $07, $07, $02
    DB      $08, $09, $02, $05, $06, $02, $0C, $0D
    DB      $02, $0E, $0F, $02, $0B, $0B, $45, $00
    DB      $AF, $00, $0C, $00, $F8, $00, $C0, $FF
    DB      $36, $01, $80, $FF, $80, $01

SUB_90F8:                                   ; SUB_90F8 ($90F8): advance level state machine ($7040 ptr); update $703F game phase
    LD      A, ($708B)                      ; A=$708B: state-machine active flag
    CP      $01                             ; CP $01: countdown active?
    JR      NZ, LOC_9128                    ; JR NZ, LOC_9128: no -> advance level ptr
    LD      HL, ($7040)                     ; HL=($7040): current level data entry ptr
    LD      A, (HL)
    CP      $06                             ; CP $06: end-of-sequence marker
    JR      NZ, LOC_910B                    ; JR NZ, LOC_910B: not end -> CALL SUB_A2E1
    DEC     HL                              ; DEC HL; LD ($7040),HL: back up ptr one entry
    LD      ($7040), HL                 ; RAM $7040

LOC_910B:
    CALL    SUB_A2E1                        ; CALL SUB_A2E1: decrement lives counter, update VRAM
    LD      A, ($703E)                  ; RAM $703E
    OR      A                               ; A=$703E: lives remaining
    JR      NZ, LOC_911E                    ; OR A: any lives left?
    LD      A, $03                          ; JR NZ, LOC_911E: yes -> continue play
    LD      ($704E), A                      ; A=$03: phase = death sequence
    CALL    VDP_REG_9367                    ; LD ($704E),A: set transition type
    JR      LOC_913B

LOC_911E:
    LD      A, $01
    LD      ($704E), A                      ; A=$01: phase = normal run
    CALL    SUB_9152
    JR      LOC_913B

LOC_9128:                                   ; LOC_9128: advance level ptr (state = not countdown)
    LD      HL, ($7040)                     ; HL=($7040): current ptr
    INC     HL                              ; INC HL; LD ($7040),HL: advance to next entry
    LD      ($7040), HL                 ; RAM $7040
    LD      A, (HL)
    OR      A
    JR      NZ, LOC_913B
    LD      A, $04                          ; A=$04: phase = level-complete transition
    LD      ($704E), A                  ; RAM $704E
    CALL    SUB_9152

LOC_913B:
    LD      HL, ($7040)                     ; LOC_913B: write new phase to $703F
    LD      A, (HL)
    LD      ($703F), A                      ; LD ($703F),A: commit new game phase
    LD      E, A
    XOR     A
    LD      D, A
    LD      ($7064), A                  ; RAM $7064
    LD      HL, ($7042)                     ; HL=($7042): level ROM data ptr
    INC     E
    ADD     HL, DE
    LD      A, (HL)
    LD      ($7065), A                      ; LD ($7065),A: store next phase data byte
    RET     

SUB_9152:                                   ; SUB_9152 ($9152): inter-level transition (VDP blank, reload tiles, score display)
    LD      A, ($704E)                      ; A=$704E: transition type flag
    CP      $04                             ; CP $04: level-complete transition?
    JR      NZ, LOC_9173                    ; JR NZ, LOC_9173: no -> handle lives/resume
    LD      B, $01                          ; LD B,$01; LD C,$82: VDP reg 1 = display off (mode 1 blank)
    LD      C, $82
    CALL    WRITE_REGISTER                  ; CALL WRITE_REGISTER: blank screen during tile reload
    CALL    SUB_819C                        ; CALL SUB_819C: re-init level gameplay state
    LD      HL, $94B8                       ; LD HL,$94B8: score display / level table
    LD      ($7040), HL                     ; LD ($7040),HL: reset level data ptr
    LD      A, (HL)
    LD      ($703F), A                  ; RAM $703F
    LD      A, $B4
    LD      ($707D), A                      ; LD ($707D),A: set RST $08 delay = $B4 (slow spin)
    RST     $08                             ; RST $08: wait VBL during setup

LOC_9173:                                   ; LOC_9173: check for attract mode $09
    LD      A, ($7044)                      ; A=$7044: game mode
    CP      $09                             ; CP $09: attract mode?
    JP      Z, LOC_92B2                     ; JP Z, LOC_92B2: yes -> skip to hi-score display
    LD      B, $01
    LD      C, $82                          ; LD B,$01; LD C,$82: VDP reg 1 = blank
    CALL    WRITE_REGISTER
    LD      HL, BOOT_UP                     ; CALL WRITE_REGISTER: blank display
    LD      A, $03                          ; LD HL,BOOT_UP; LD A,$03; CALL INIT_TABLE: init signal timer table
    CALL    INIT_TABLE
    CALL    LOAD_ASCII                      ; CALL LOAD_ASCII: reload ASCII font tiles
    LD      A, $E1
    LD      DE, $0020
    LD      HL, $2300
    CALL    FILL_VRAM
    LD      A, $20
    LD      DE, $0300
    LD      HL, $2000
    CALL    FILL_VRAM
    LD      IX, $2088
    LD      DE, $944F
    LD      HL, $0022
    CALL    VDP_REG_BEFA                    ; CALL VDP_REG_BEFA: write tile bitmaps to VRAM from ROM
    LD      A, $D0
    LD      DE, $0002
    LD      HL, $2380
    CALL    FILL_VRAM
    CALL    SUB_ABDA                        ; CALL SUB_ABDA: reinit SN76489A (mute during transition)
    CALL    VDP_REG_93E3
    LD      A, ($704E)                  ; RAM $704E
    CP      $01
    JP      Z, LOC_927E
    PUSH    AF
    CALL    VDP_REG_942F
    POP     AF
    CP      $03
    JR      NZ, LOC_91E2
    LD      BC, $0009
    LD      DE, $21EB
    LD      HL, $947F
    CALL    VDP_REG_BF8A
    RST     $08
    JP      LOC_927E

LOC_91E2:
    LD      A, $74
    LD      ($72B6), A                  ; RAM $72B6
    LD      A, $54
    LD      ($72B7), A                  ; RAM $72B7
    LD      BC, $007C
    LD      DE, $2380
    LD      HL, $72B6                   ; RAM $72B6
    CALL    VDP_REG_BF8A
    LD      A, $D0
    LD      DE, $0002
    LD      HL, $2384
    CALL    FILL_VRAM
    LD      BC, $0005
    LD      DE, $21ED
    LD      HL, $9477
    CALL    VDP_REG_BF8A
    LD      BC, $0003
    LD      DE, $222A
    LD      HL, $947C
    CALL    VDP_REG_BF8A
    LD      A, ($703E)                  ; RAM $703E
    LD      B, A
    LD      C, $30
    LD      DE, $21EE
    PUSH    BC
    CALL    SUB_9443
    POP     BC
    XOR     A
    LD      ($709F), A                  ; RAM $709F
    LD      ($70A1), A                  ; RAM $70A1

LOC_9230:
    ADD     A, $05
    DAA     
    DJNZ    LOC_9230
    LD      B, A
    LD      C, $00
    PUSH    BC
    LD      ($70A0), A                  ; RAM $70A0
    LD      HL, $709F                   ; RAM $709F
    CALL    DELAY_LOOP_A2BE
    LD      BC, $0004
    LD      DE, $21F2
    LD      HL, $70A1                   ; RAM $70A1
    CALL    VDP_REG_BF8A
    LD      A, $78
    LD      ($707D), A                  ; RAM $707D
    RST     $08
    POP     BC
    LD      A, ($703E)                  ; RAM $703E
    PUSH    AF
    CALL    SUB_A359
    LD      A, ($703E)                  ; RAM $703E
    LD      C, A
    POP     AF
    SUB     C
    JR      NZ, LOC_926A
    LD      A, $17
    LD      B, A
    CALL    PLAY_IT

LOC_926A:
    CALL    SUB_A3B5
    CALL    VDP_REG_93E3
    LD      A, ($7044)                  ; RAM $7044
    CP      $04
    JR      NC, LOC_927E
    INC     A
    LD      ($7044), A                  ; RAM $7044
    CALL    DELAY_LOOP_8513

LOC_927E:
    CALL    VDP_REG_9337
    CALL    Z, VDP_REG_9337
    RET     Z
    LD      A, $20
    LD      DE, $0300
    LD      HL, $2000
    CALL    FILL_VRAM
    LD      A, $D0
    LD      DE, $0002
    LD      HL, $2380
    CALL    FILL_VRAM
    CALL    VDP_REG_942F
    RST     $08
    LD      A, ($703F)                  ; RAM $703F
    CP      $01
    JR      NZ, LOC_92B2
    LD      A, ($7044)                  ; RAM $7044
    DEC     A
    LD      ($7045), A                  ; RAM $7045
    LD      A, $F0
    LD      ($7046), A                  ; RAM $7046

LOC_92B2:
    LD      B, $01
    LD      C, $82
    CALL    WRITE_REGISTER
    LD      IX, $2300
    LD      DE, $859B
    LD      HL, $001C
    CALL    VDP_REG_BEFA
    LD      IX, BOOT_UP
    LD      DE, $AE94
    LD      HL, $059D
    CALL    VDP_REG_BEFA
    LD      BC, $22C0
    LD      DE, $BA39
    CALL    VDP_REG_A958
    LD      A, ($703D)                  ; RAM $703D
    CP      $01
    JR      NZ, LOC_92F7
    LD      HL, $E9E8
    LD      ($709F), HL                 ; RAM $709F
    LD      BC, $0002
    LD      DE, $22C8
    LD      HL, $709F                   ; RAM $709F
    CALL    VDP_REG_BF8A
    JR      LOC_9307

LOC_92F7:
    LD      A, ($7047)                  ; RAM $7047
    DEC     A
    JR      NZ, LOC_92FF
    SET     1, A

LOC_92FF:
    LD      C, $F0
    LD      DE, $22C9
    CALL    SUB_9443

LOC_9307:
    LD      C, $F0
    LD      DE, $22D8
    CALL    SUB_9440
    LD      A, ($7046)                  ; RAM $7046
    LD      HL, $22F3
    DB      $EB
    LD      A, A
    LD      HL, $737F                   ; RAM $737F
    LD      (HL), A
    LD      BC, $0001
    CALL    WRITE_VRAM
    LD      A, $01
    LD      ($708B), A                  ; RAM $708B
    XOR     A
    LD      ($704E), A                  ; RAM $704E
    LD      ($705F), A                  ; RAM $705F
    LD      ($7060), A                  ; RAM $7060
    CALL    LOC_A0AA
    LD      A, $01
    AND     A
    RET     

VDP_REG_9337:                               ; VDP_REG_9337 ($9337): compare player score vs hi-score; write both rows to VRAM $3400/$3414
    LD      DE, $3400                       ; DE=$3400: player score VRAM row
    LD      HL, $3414                       ; HL=$3414: hi-score VRAM row
    LD      A, ($7047)                  ; RAM $7047
    CP      $01
    JR      Z, LOC_9345
    DB      $EB

LOC_9345:
    LD      BC, $000D                       ; BC=$000D: 13 bytes per score row
    PUSH    HL
    LD      HL, $703E                   ; RAM $703E
    PUSH    HL
    PUSH    BC
    CALL    VDP_REG_BF8A
    LD      HL, $7048                       ; LD HL,$703E: lives-count source byte
    LD      DE, $704B                   ; RAM $704B
    LD      BC, $0003
    LDIR                                    ; LDIR: copy score data to comparison buffer
    POP     BC
    POP     HL
    POP     DE
    CALL    VDP_REG_BFA6
    LD      A, ($703E)                  ; RAM $703E
    OR      A
    RET     

VDP_REG_9367:                               ; VDP_REG_9367 ($9367): end-of-life: copy $72B6 sprite name tbl -> VRAM $2380, wait RST $08
    LD      HL, $7310                   ; RAM $7310
    LD      A, (HL)
    CP      $B4
    JR      Z, LOC_9373
    CP      $B8
    JR      NZ, LOC_9376

LOC_9373:
    INC     HL
    LD      (HL), $00

LOC_9376:
    LD      BC, $007C                       ; BC=$007C: sprite name table size
    LD      DE, $2380                       ; DE=$2380: VRAM sprite name table addr
    LD      HL, $72B6                       ; HL=$72B6: sprite name table buffer
    CALL    VDP_REG_BF8A                    ; CALL VDP_REG_BF8A: flush sprite name table
    CALL    SUB_ABDA                        ; CALL SUB_ABDA: reinit SN76489A (silence)
    LD      A, $B4
    LD      ($707D), A                      ; LD ($707D),A: delay = $B4 VBL frames (slow wait)
    RST     $08                             ; RST $08: wait $B4 VBL frames
    CALL    SUB_9152
    RET     NZ
    LD      A, $00
    LD      ($70A3), A                  ; RAM $70A3
    LD      HL, $0E10
    LD      ($70A1), HL                 ; RAM $70A1

SUB_939A:                                   ; SUB_939A ($939A): credits/name-entry: RST $08 loop, tick player inputs, DEC $70A1 counter
    LD      A, $01                          ; A=$01: single-frame VBL delay
    LD      ($707D), A                      ; LD ($707D),A: set RST $08 = 1 VBL per tick

LOC_939F:
    RST     $08                             ; RST $08: wait one VBL (sound + input update)
    LD      A, ($703D)                      ; A=$703D: player count
    CP      $02                             ; CP $02: two players?
    JR      NZ, LOC_93AD                    ; JR NZ, LOC_93AD: skip P2 input if 1P
    LD      A, ($7036)                      ; A=$7036: P2 scroll-select byte
    CALL    SUB_93C7                        ; CALL SUB_93C7: process P2 scroll input

LOC_93AD:
    LD      A, ($7031)                      ; A=$7031: P1 scroll-select byte
    CALL    SUB_93C7                        ; CALL SUB_93C7: process P1 scroll input
    LD      HL, ($70A1)                     ; HL=($70A1): frame/scroll line counter
    DEC     HL                              ; DEC HL: advance one tick
    LD      ($70A1), HL                     ; LD ($70A1),HL: write back
    LD      A, L                            ; A=L|H: test for zero
    OR      H
    JR      NZ, LOC_939F                    ; JR NZ, LOC_939F: loop while counter > 0
    LD      B, $01                          ; LD B,$01; LD C,$82: VDP reg 1 = display off
    LD      C, $82
    CALL    WRITE_REGISTER                  ; CALL WRITE_REGISTER: blank display at end of scroll sequence
    JR      LOC_939F

SUB_93C7:                                   ; SUB_93C7 ($93C7): process player scroll input: $0A=soft-reset, $0B=scroll-return
    EX      AF, AF'                         ; EX AF,AF: stash current input byte
    LD      A, ($70A3)                      ; A=$70A3: scroll direction flag
    CP      $00                             ; CP $00: any scroll direction set?
    JR      NZ, LOC_93DB                    ; JR NZ, LOC_93DB: yes -> process directed scroll
    EX      AF, AF'                         ; EX AF,AF: restore input byte
    CP      $0A                             ; CP $0A: fire-button (soft reset) action?
    JP      Z, LOC_804E                     ; JP Z, LOC_804E: yes -> soft reset to title
    CP      $0B                             ; CP $0B: select button?
    JP      Z, LOC_804A                     ; JP Z, LOC_804A: yes -> reset score and continue
    RET     

LOC_93DB:
    EX      AF, AF'
    OR      A
    RET     Z
    CP      $0A
    RET     NC
    POP     BC
    RET     

VDP_REG_93E3:                               ; VDP_REG_93E3 ($93E3): render $7037 score bytes as BCD digit tiles to VRAM $2091/$20D1
    LD      HL, $7037                       ; HL=$7037: score / hi-score RAM area
    CALL    DELAY_LOOP_A2BE                 ; CALL DELAY_LOOP_A2BE: convert 3 score bytes -> BCD nibble pairs at $70A4
    LD      BC, $0006                       ; BC=$0006: 6 digit tiles
    LD      DE, $2091                       ; DE=$2091: VRAM score row address
    LD      HL, $709F                       ; HL=$709F: digit tile buffer
    CALL    VDP_REG_BF8A                    ; CALL VDP_REG_BF8A: write score digits to VRAM
    LD      HL, $7048                       ; HL=$7048: player score area
    CALL    DELAY_LOOP_A2BE                 ; CALL DELAY_LOOP_A2BE: convert player score to digit tiles
    LD      DE, $20D1
    LD      HL, $2111
    LD      A, ($7047)                  ; RAM $7047
    CP      $01
    JR      Z, LOC_9409
    DB      $EB

LOC_9409:
    PUSH    HL
    LD      HL, $709F                   ; RAM $709F
    LD      BC, $0006
    PUSH    BC
    PUSH    HL
    CALL    VDP_REG_BF8A
    LD      HL, $704B                   ; RAM $704B
    CALL    DELAY_LOOP_A2BE
    POP     HL
    POP     BC
    POP     DE
    CALL    VDP_REG_BF8A
    LD      B, $01                          ; CALL VDP_REG_BF8A: write player score digits to VRAM
    LD      C, $C2                          ; LD B,$01; LD C,$C2: VDP reg 1 = display on (sprites 16x16)
    CALL    WRITE_REGISTER
    LD      A, $B4                          ; CALL WRITE_REGISTER: re-enable display after score update
    LD      ($707D), A                      ; LD ($707D),A: delay = $B4 (pause to show score)
    RST     $08                             ; RST $08: wait during score display
    RET     

VDP_REG_942F:                               ; VDP_REG_942F ($942F): write "GAME OVER" or "HISCORE" ASCII block to VRAM $218C
    LD      BC, $0006                       ; BC=$0006: 6 bytes
    LD      DE, $218C                       ; DE=$218C: VRAM text destination
    LD      HL, $9471                       ; HL=$9471: source text data in ROM
    CALL    VDP_REG_BF8A                    ; CALL VDP_REG_BF8A: write text block to VRAM
    LD      C, $30
    LD      DE, $2193

SUB_9440:                                   ; SUB_9440 ($9440): write current player number (A+C) as digit tile to VRAM via $737F
    LD      A, ($7047)                  ; RAM $7047

SUB_9443:                                   ; SUB_9443 ($9443): add A+C, store to $737F, WRITE_VRAM 1 byte at DE
    ADD     A, C
    LD      HL, $737F                   ; RAM $737F
    LD      (HL), A
    LD      BC, $0001
    CALL    WRITE_VRAM
    RET     
    DB      $09, $48, $49, $53, $43, $4F, $52, $45
    DB      $20, $20, $77, $20, $09, $50, $31, $53
    DB      $43, $4F, $52, $45, $20, $20, $77, $20 ; "CORE  w "
    DB      $09, $50, $32, $53, $43, $4F, $52, $45
    DB      $20, $20, $50, $4C, $41, $59, $45, $52 ; "  PLAYER"
    DB      $58, $30, $20, $3D, $20, $35, $30, $30 ; "X0 = 500"
    DB      $47, $41, $4D, $45, $20, $4F, $56, $45 ; "GAME OVE"
    DB      $52, $B4, $FF, $07, $07, $07, $07, $07
    DB      $07, $07, $07, $07, $07, $78, $FF, $08
    DB      $09, $09, $07, $09, $07, $09, $09, $09
    DB      $09, $4B, $9E, $09, $0F, $0F, $07, $0A
    DB      $08, $0F, $0C, $0F, $0F, $41, $64, $07
    DB      $14, $14, $07, $0E, $08, $14, $0D, $14
    DB      $16, $01, $08, $07, $03, $04, $05, $06
    DB      $02, $09, $0A, $00, $3D, $9B, $7A, $96
    DB      $3D, $9B, $59, $96, $EC, $99, $9C, $96
    DB      $2D, $9A, $28, $97, $48, $9A, $8B, $97
    DB      $79, $9A, $1D, $98, $9F, $9A, $B5, $98
    DB      $C7, $9A, $C8, $98, $F7, $9A, $FB, $98
    DB      $1A, $9B, $41, $99

SUB_94EB:                                   ; SUB_94EB ($94EB): init per-phase gameplay state (player pos, sprite table, timers)
    LD      A, ($7044)                      ; A=$7044: game mode
    CP      $09                             ; CP $09: attract mode?
    JR      NZ, LOC_94F4                    ; JR NZ, LOC_94F4: no -> normal mode
    SUB     $05                             ; SUB $05: attract demo: adjust phase to valid level

LOC_94F4:
    DEC     A                               ; DEC A: phase - 1 = zero-based level
    LD      ($7061), A                      ; LD ($7061),A: set min-level boundary
    LD      A, $07
    LD      ($7062), A                      ; A=$07; LD ($7062),A: max level = 7
    LD      A, ($7045)                      ; A=$7045: lives remaining
    CALL    LOC_AA02                        ; CALL LOC_AA02: set speed params from difficulty table
    CALL    LOC_A0AA                        ; CALL LOC_A0AA: update lives-display digit
    XOR     A
    LD      ($7079), A                      ; XOR A; LD ($7079),A: clear player X offset
    LD      A, $03
    LD      ($7090), A                      ; A=$03; LD ($7090),A: random jitter mask = $03
    LD      HL, BOOT_UP                     ; LD HL,BOOT_UP; LD ($7075),HL: clear hazard timer 1
    LD      ($7075), HL                 ; RAM $7075
    LD      ($7077), HL                     ; LD ($7077),HL: clear hazard timer 2
    LD      IX, $94C3                       ; LD IX,$94C3: player startup data table
    LD      A, ($703F)                      ; A=$703F: current game phase
    LD      C, A                            ; LD C,A: phase index (0-based)
    LD      B, $00
    DEC     C                               ; DEC C: phase - 1
    SLA     C                               ; SLA C; SLA C: × 4 (stride into $94C3 table)
    SLA     C
    ADD     IX, BC                          ; ADD IX,BC: point IX at phase entry in $94C3
    LD      L, (IX+0)                       ; LD L,(IX+0); LD H,(IX+1): load player start-position ptr
    LD      H, (IX+1)
    LD      DE, $7054                       ; LD DE,$7054: player sprite data destination ($7054 block)
    LD      BC, $000A                       ; LD BC,$000A: 10 bytes to copy
    LDIR                                    ; LDIR: copy sprite Y/X/tile/color/anim state to $7054 block
    PUSH    IX
    PUSH    HL
    LD      HL, $0005
    LD      ($7052), HL                 ; RAM $7052
    LD      HL, $883E                       ; LD HL,$883E: object-type dispatch table in ROM
    LD      ($709B), HL                     ; LD ($709B),HL: set object dispatch table ptr
    LD      A, $10                          ; A=$10; LD ($708E),A: sprite tile = $10 (B.C. standing frame)
    LD      ($708E), A                  ; RAM $708E
    LD      A, $28                          ; A=$28; LD ($708F),A: sprite tile offset = $28
    LD      ($708F), A                  ; RAM $708F
    LD      A, $0A                          ; A=$0A; LD ($708C),A: animation frame counter = 10
    LD      ($708C), A                  ; RAM $708C
    CALL    SUB_876B                        ; CALL SUB_876B: place B.C. sprite at initial position
    LD      B, $28
    LD      IX, $7330                   ; RAM $7330

LOC_955E:
    LD      (IX+0), $FF
    INC     IX
    DJNZ    LOC_955E
    LD      (IX+0), $FE
    LD      (IX+1), $FE
    LD      (IX+2), $FE
    LD      (IX+3), $FE
    LD      HL, $72C6                   ; RAM $72C6
    LD      DE, $0004
    LD      B, $10

LOC_957E:
    LD      A, $E0
    LD      (HL), A
    ADD     HL, DE
    DJNZ    LOC_957E
    LD      A, ($703F)                  ; RAM $703F
    CP      $0A
    JR      Z, LOC_958F
    CP      $01
    JR      NZ, LOC_95A5

LOC_958F:
    LD      B, $01
    LD      C, $82
    CALL    WRITE_REGISTER
    LD      BC, $007C
    LD      DE, $2380
    LD      HL, $72B6                   ; RAM $72B6
    CALL    VDP_REG_BF8A
    LD      A, ($703F)                  ; RAM $703F

LOC_95A5:
    CP      $03
    JR      Z, LOC_95AD
    CP      $05
    JR      NZ, LOC_95B8

LOC_95AD:
    LD      A, $FF
    LD      DE, $0008
    LD      HL, $0348
    CALL    FILL_VRAM

LOC_95B8:
    POP     IY
    CALL    VDP_DATA_9622
    LD      A, ($703F)                  ; RAM $703F
    CP      $09
    JR      NZ, LOC_95D7
    LD      A, $35
    LD      HL, $321B
    DB      $EB
    LD      A, A
    LD      HL, $737F                   ; RAM $737F
    LD      (HL), A
    LD      BC, $0001
    CALL    WRITE_VRAM
    JR      LOC_95EC

LOC_95D7:
    CP      $04
    JR      NZ, LOC_95EC
    LD      A, $35
    LD      HL, $230E
    DB      $EB
    LD      A, A
    LD      HL, $737F                   ; RAM $737F
    LD      (HL), A
    LD      BC, $0001
    CALL    WRITE_VRAM

LOC_95EC:
    LD      A, ($703F)                  ; RAM $703F
    CP      $0A
    JR      NZ, LOC_95F8
    CALL    SUB_ABDA
    JR      LOC_9614

LOC_95F8:
    CP      $03
    JR      NZ, LOC_960F
    LD      A, ($708B)                  ; RAM $708B
    CP      $01
    JR      Z, LOC_9608
    LD      A, $04
    CALL    SUB_A488

LOC_9608:
    LD      IY, $9A06
    CALL    VDP_DATA_9622

LOC_960F:
    LD      A, $20
    CALL    SUB_A488

LOC_9614:
    POP     IX
    LD      L, (IX+2)
    LD      H, (IX+3)
    LD      A, $00
    LD      ($707F), A                  ; RAM $707F
    JP      (HL)

VDP_DATA_9622:                              ; VDP_DATA_9622 ($9622): sprite pattern data transfer chain: IY-table entries -> VRAM $3000
    LD      A, $01                          ; A=$01; LD ($707F),A: enable VRAM write mode
    LD      ($707F), A                  ; RAM $707F
    LD      E, (IY+0)                       ; LD E,(IY+0); LD D,(IY+1): source address (ROM data ptr)
    LD      D, (IY+1)
    LD      L, (IY+2)                       ; LD L,(IY+2); LD H,(IY+3): byte count
    LD      H, (IY+3)
    LD      IX, $3000                       ; LD IX,$3000: VRAM sprite pattern base address
    PUSH    IY                              ; PUSH IY: save IY for chain iteration
    CALL    VDP_REG_BEFA                    ; CALL VDP_REG_BEFA: write tile bitmaps to VRAM $3000 from ROM
    POP     HL
    LD      BC, $0004
    ADD     HL, BC

LOC_9641:                                   ; LOC_9641: iterate remaining chain entries
    LD      E, (HL)                         ; LD E,(HL); LD D,(HL): next source ptr
    INC     HL
    LD      D, (HL)
    INC     HL
    LD      A, E
    OR      D                               ; OR D: test for chain terminator (DE=0)
    RET     Z                               ; RET Z: end of chain
    LD      B, (HL)                         ; LD B,(HL): row count for this chain entry
    INC     HL

LOC_964A:
    PUSH    BC
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    INC     HL
    PUSH    HL
    CALL    VDP_REG_A958                    ; CALL VDP_REG_A958: write sprite attribute rows from chain entry
    POP     HL
    POP     BC
    DJNZ    LOC_964A
    JR      LOC_9641
    DB      $3E, $0C, $32, $79, $70, $21, $66, $88
    DB      $22, $9B, $70, $3E, $44, $32, $8E, $70
    DB      $3E, $48, $32, $8F, $70, $21, $64, $00
    DB      $22, $52, $70, $21, $E5, $90, $22, $5C
    DB      $70, $01, $A6, $70, $11, $91, $BA, $CD
    DB      $58, $A9, $3E, $70, $32, $6D, $70, $01
    DB      $40, $00, $11, $80, $03, $21, $46, $72
    DB      $CD, $A6, $BF, $06, $01, $0E, $C2, $CD
    DB      $D9, $1F, $C9, $21, $66, $88, $22, $9B
    DB      $70, $3E, $44, $32, $8E, $70, $3E, $48
    DB      $32, $8F, $70, $21, $A6, $70, $11, $A7
    DB      $70, $01, $00, $01, $36, $00, $ED, $B0
    DB      $11, $39, $BB, $01, $AA, $70, $CD, $58
    DB      $A9, $01, $B9, $70, $CD, $58, $A9, $11
    DB      $27, $BB, $01, $86, $71, $CD, $58, $A9
    DB      $01, $96, $71, $CD, $58, $A9, $3E, $04
    DB      $32, $9A, $70, $3E, $60, $32, $6D, $70
    DB      $21, $52, $BE, $11, $C6, $71, $01, $03
    DB      $00, $ED, $B0, $11, $CE, $71, $01, $03
    DB      $00, $ED, $B0, $11, $D6, $71, $01, $03
    DB      $00, $ED, $B0, $11, $DE, $71, $01, $03
    DB      $00, $ED, $B0, $21, $46, $72, $0E, $05
    DB      $1E, $00, $3E, $08, $93, $47, $28, $05
    DB      $36, $00, $23, $10, $FB, $7B, $47, $B7
    DB      $28, $05, $36, $FF, $23, $10, $FB, $7B
    DB      $C6, $02, $5F, $0D, $20, $E4, $C9, $21
    DB      $00, $02, $22, $75, $70, $2A, $64, $70
    DB      $25, $22, $77, $70, $AF, $32, $6A, $70
    DB      $3E, $70, $32, $6D, $70, $11, $87, $BA
    DB      $01, $A6, $70, $CD, $58, $A9, $01, $AE
    DB      $70, $CD, $58, $A9, $01, $B6, $70, $CD
    DB      $58, $A9, $01, $BE, $70, $CD, $58, $A9
    DB      $21, $C6, $70, $01, $80, $00, $3E, $68
    DB      $77, $23, $0B, $79, $B0, $20, $F7, $21
    DB      $C2, $BD, $11, $46, $71, $01, $28, $00
    DB      $ED, $B0, $21, $EA, $BD, $11, $76, $71
    DB      $01, $68, $00, $ED, $B0, $01, $40, $00
    DB      $11, $80, $03, $21, $46, $72, $CD, $A6
    DB      $BF, $C9, $3E, $3F, $21, $0E, $23, $EB
    DB      $7F, $21, $7F, $73, $77, $01, $01, $00
    DB      $CD, $DF, $1F, $21, $A6, $70, $11, $A7
    DB      $70, $01, $00, $01, $36, $00, $ED, $B0
    DB      $11, $39, $BB, $01, $AA, $70, $CD, $58
    DB      $A9, $01, $B9, $70, $CD, $58, $A9, $11
    DB      $27, $BB, $01, $86, $71, $CD, $58, $A9
    DB      $01, $96, $71, $CD, $58, $A9, $3E, $04
    DB      $32, $9A, $70, $3E, $64, $32, $6D, $70
    DB      $21, $5E, $BE, $11, $C6, $71, $01, $03
    DB      $00, $ED, $B0, $11, $CE, $71, $01, $03
    DB      $00, $ED, $B0, $11, $D6, $71, $01, $03
    DB      $00, $ED, $B0, $11, $DE, $71, $01, $03
    DB      $00, $ED, $B0, $21, $46, $72, $0E, $04
    DB      $1E, $06, $3E, $08, $93, $47, $AF, $77
    DB      $23, $10, $FC, $7B, $47, $B7, $28, $05
    DB      $36, $FF, $23, $10, $FB, $7B, $D6, $02
    DB      $5F, $0D, $20, $E6, $06, $08, $36, $FF
    DB      $23, $10, $FB, $C9, $3E, $00, $32, $9F
    DB      $70, $3A, $44, $70, $FE, $03, $38, $06
    DB      $FE, $09, $20, $02, $3E, $FE, $C6, $02
    DB      $4F, $3A, $45, $70, $B9, $38, $05, $3E
    DB      $01, $32, $9F, $70, $CF, $CD, $B7, $85
    DB      $01, $7C, $00, $11, $80, $23, $21, $B6
    DB      $72, $CD, $8A, $BF, $CD, $89, $A9, $3A
    DB      $7C, $70, $4F, $3A, $98, $70, $81, $32
    DB      $98, $70, $FE, $74, $38, $DE, $FE, $8C
    DB      $38, $06, $01, $02, $00, $CD, $71, $98
    DB      $01, $01, $00, $CD, $71, $98, $18, $CC
    DB      $3A, $44, $70, $FE, $09, $28, $2A, $79
    DB      $FE, $02, $28, $0B, $3A, $92, $70, $B7
    DB      $C0, $3A, $5E, $70, $CB, $47, $C8, $3A
    DB      $9F, $70, $FE, $01, $28, $04, $3E, $05
    DB      $18, $11, $79, $FE, $02, $20, $04, $3E
    DB      $04, $18, $08, $01, $00, $01, $CD, $59
    DB      $A3, $3E, $03, $32, $8A, $70, $3E, $01
    DB      $32, $8B, $70, $C1, $C1, $AF, $32, $92
    DB      $70, $C3, $77, $81, $21, $18, $A9, $22
    DB      $88, $70, $CD, $B7, $A6, $21, $05, $00
    DB      $22, $64, $70, $E1, $C3, $77, $81, $3E
    DB      $70, $32, $6D, $70, $01, $A6, $70, $11
    DB      $97, $BB, $CD, $58, $A9, $21, $AE, $70
    DB      $06, $0C, $11, $E1, $BB, $C5, $E5, $4D
    DB      $44, $CD, $58, $A9, $E1, $23, $23, $C1
    DB      $10, $F3, $21, $E1, $BB, $22, $6B, $70
    DB      $3A, $E2, $BB, $32, $6A, $70, $CD, $B5
    DB      $99, $C9, $3E, $EB, $21, $1A, $23, $EB
    DB      $7F, $21, $7F, $73, $77, $01, $01, $00
    DB      $CD, $DF, $1F, $3E, $EE, $21, $1C, $23
    DB      $EB, $7F, $21, $7F, $73, $77, $01, $01
    DB      $00, $CD, $DF, $1F, $3E, $1B, $21, $0B
    DB      $23, $EB, $7F, $21, $7F, $73, $77, $01
    DB      $01, $00, $CD, $DF, $1F, $21, $40, $A9
    DB      $22, $88, $70, $CD, $B7, $A6, $21, $05
    DB      $00, $22, $64, $70, $E1, $C3, $77, $81
    DB      $01, $15, $00, $11, $08, $23, $21, $6A
    DB      $85, $CD, $8A, $BF, $3E, $FE, $11, $C0
    DB      $02, $21, $00, $20, $CD, $82, $1F, $21
    DB      $00, $00, $3E, $03, $CD, $B8, $1F, $3E
    DB      $12, $47, $CD, $F1, $1F, $3E, $70, $32
    DB      $6D, $70, $AF, $32, $92, $70, $32, $94
    DB      $70, $32, $93, $70, $01, $A6, $70, $3E
    DB      $08, $11, $AD, $BC, $F5, $C5, $CD, $58
    DB      $A9, $C1, $03, $03, $03, $03, $F1, $3D
    DB      $20, $F2, $21, $AD, $BC, $22, $6B, $70
    DB      $3A, $AE, $BC, $32, $6A, $70, $3E, $65
    DB      $32, $97, $70, $32, $99, $70, $3E, $40
    DB      $32, $98, $70, $3E, $0F, $32, $7D, $70
    DB      $CF, $CD, $B5, $99, $06, $01, $0E, $C2
    DB      $CD, $D9, $1F, $C9, $3A, $45, $70, $FE
    DB      $03, $30, $07, $3E, $03, $32, $45, $70
    DB      $18, $09, $FE, $06, $38, $0E, $3E, $06
    DB      $32, $45, $70, $3E, $00, $32, $5F, $70
    DB      $AF, $32, $60, $70, $3E, $03, $32, $61
    DB      $70, $3E, $06, $32, $62, $70, $3E, $08
    DB      $32, $7C, $70, $AF, $32, $7B, $70, $CD
    DB      $2A, $AA, $C9, $04, $08, $80, $00, $C6
    DB      $71, $E6, $71, $D4, $90, $61, $AE, $19
    DB      $00, $27, $BB, $01, $60, $31, $89, $BB
    DB      $01, $20, $32, $00, $00, $6E, $AD, $2B
    DB      $00, $39, $BB, $02, $84, $30, $93, $30
    DB      $27, $BB, $02, $60, $31, $70, $31, $13
    DB      $BB, $08, $9C, $31, $B8, $31, $D4, $31
    DB      $F0, $31, $0C, $32, $28, $32, $44, $32
    DB      $60, $32, $00, $00, $08, $05, $60, $01
    DB      $46, $72, $86, $72, $D9, $90, $99, $AD
    DB      $19, $00, $87, $BA, $04, $60, $31, $68
    DB      $31, $70, $31, $78, $31, $00, $00, $04
    DB      $08, $80, $00, $C6, $71, $E6, $71, $DC
    DB      $90, $B2, $AD, $2D, $00, $39, $BB, $02
    DB      $84, $30, $93, $30, $27, $BB, $02, $60
    DB      $31, $70, $31, $1D, $BB, $08, $80, $31
    DB      $A4, $31, $C8, $31, $EC, $31, $10, $32
    DB      $34, $32, $58, $32, $7C, $32, $00, $00
    DB      $00, $00, $20, $01, $00, $00, $00, $00
    DB      $00, $00, $DF, $AD, $1F, $00, $91, $BA
    DB      $01, $20, $31, $87, $BA, $02, $60, $32
    DB      $68, $32, $45, $BB, $01, $4C, $32, $51
    DB      $BB, $01, $BA, $31, $00, $00, $20, $01
    DB      $60, $02, $A6, $70, $C6, $70, $00, $00
    DB      $19, $AE, $48, $00, $39, $BB, $02, $A4
    DB      $30, $71, $30, $27, $BB, $02, $60, $31
    DB      $70, $31, $44, $BD, $01, $B6, $31, $D7
    DB      $BC, $01, $B6, $30, $00, $00, $20, $09
    DB      $00, $01, $A6, $70, $C6, $71, $DF, $90
    DB      $FE, $AD, $1B, $00, $97, $BB, $01, $00
    DB      $31, $E1, $BB, $0C, $08, $31, $0A, $31
    DB      $0C, $31, $0E, $31, $10, $31, $12, $31
    DB      $14, $31, $16, $31, $18, $31, $1A, $31
    DB      $1C, $31, $1E, $31, $00, $00, $20, $01
    DB      $60, $02, $A6, $70, $C6, $70, $00, $00
    DB      $19, $AE, $48, $00, $39, $BB, $02, $A4
    DB      $30, $71, $30, $27, $BB, $02, $60, $31
    DB      $70, $31, $6E, $BD, $01, $BC, $30, $00
    DB      $00, $20, $0A, $40, $01, $A6, $70, $E6
    DB      $71, $E2, $90, $7A, $AE, $1A, $00, $AD
    DB      $BC, $08, $40, $21, $44, $21, $48, $21
    DB      $4C, $21, $50, $21, $54, $21, $58, $21 ; "L!P!T!X!"
    DB      $5C, $21, $00, $00, $08, $04, $20, $01
    DB      $46, $72, $86, $72, $D1, $90, $55, $AD
    DB      $19, $00, $91, $BA, $01, $20, $31, $87
    DB      $BA, $04, $00, $32, $08, $32, $10, $32
    DB      $18, $32, $00, $00

SUB_9B5D:                                   ; SUB_9B5D ($9B5D): configure difficulty params from $708A (movement/anim/collision tables)
    LD      A, ($7044)                      ; A=$7044: check game mode
    CP      $09
    JR      NZ, LOC_9B75                    ; JR NZ, LOC_9B75: not attract mode -> use $708A directly
    LD      A, ($708A)                      ; A=$708A: difficulty/enemy sub-type
    CP      $01                             ; CP $01: sub-type 1?
    JR      Z, LOC_9B75                     ; JR Z, LOC_9B75: use difficulty table
    CP      $03                             ; CP $03: sub-type 3?
    JR      Z, LOC_9B75                     ; JR Z, LOC_9B75: use difficulty table
    LD      A, $00
    LD      ($708B), A                      ; LD ($708B),A: clear state flag (abort sub-state if attract demo)
    RET     

LOC_9B75:                                   ; LOC_9B75: LD A,$708A: load difficulty index
    LD      A, ($708A)                      ; SLA A: × 2
    SLA     A                               ; SLA A: × 4
    SLA     A                               ; SLA A: × 8 (stride for 8-byte entries)
    SLA     A
    LD      IX, $9EEC                       ; LD IX,$9EEC: difficulty parameter table base
    LD      C, A
    LD      B, $00                          ; LD C,A; LD B,$00: BC = stride offset
    ADD     IX, BC                          ; ADD IX,BC: point IX at difficulty entry
    LD      A, (IX+0)                       ; A=(IX+0): frame-delay for this difficulty
    LD      ($707D), A                      ; LD ($707D),A: set RST $08 VBL delay
    LD      C, (IX+1)                       ; LD C,(IX+1); LD B,(IX+2): movement data ptr
    LD      B, (IX+2)
    LD      ($7084), BC                     ; LD ($7084),BC: store movement table ptr
    LD      A, (BC)                         ; A=(BC): first movement timer count
    LD      ($7080), A                      ; LD ($7080),A: init movement frame counter
    LD      C, (IX+3)                       ; LD C,(IX+3); LD B,(IX+4): Y-animation data ptr
    LD      B, (IX+4)
    LD      ($7086), BC                     ; LD ($7086),BC: store Y-anim table ptr
    LD      A, (BC)                         ; A=(BC): first Y-anim frame count
    LD      ($7081), A                      ; LD ($7081),A: init Y-anim counter
    LD      C, (IX+5)                       ; LD C,(IX+5); LD B,(IX+6): collision data ptr
    LD      B, (IX+6)
    LD      ($7082), BC                     ; LD ($7082),BC: store collision data ptr
    LD      B, (IX+7)
    CALL    PLAY_IT                         ; CALL PLAY_IT B=(IX+7): play level-entry sound effect
    LD      A, $08                          ; A=$08; LD ($708C),A: animation step = 8
    LD      ($708C), A                  ; RAM $708C
    LD      A, ($708A)                  ; RAM $708A
    OR      A
    PUSH    AF
    CALL    Z, VDP_REG_9BFD
    POP     AF
    CP      $03
    JR      Z, LOC_9BCF
    CP      $01
    JR      NZ, LOC_9BD4

LOC_9BCF:
    LD      A, $02
    LD      ($708B), A                  ; RAM $708B

LOC_9BD4:
    CALL    DELAY_LOOP_9ED7
    JP      C, LOC_9BF9
    LD      A, ($708A)                  ; RAM $708A
    CP      $01
    JR      NZ, LOC_9BF6
    LD      E, (IY+3)
    LD      D, $00
    SLA     E
    SLA     E
    LD      IX, $72C6                   ; RAM $72C6
    ADD     IX, DE
    LD      ($70A1), IX                 ; RAM $70A1
    JR      LOC_9BF9

LOC_9BF6:
    CALL    SOUND_WRITE_8FBB

LOC_9BF9:
    CALL    VDP_REG_9D2C
    RET     

VDP_REG_9BFD:
    LD      A, ($7079)                  ; RAM $7079
    OR      A
    JR      Z, LOC_9C10
    LD      HL, $8250
    LD      A, (HL)
    LD      DE, $0006
    LD      HL, $2300
    CALL    FILL_VRAM

LOC_9C10:
    LD      HL, $88B6
    LD      ($709B), HL                 ; RAM $709B
    CALL    SUB_876B
    LD      BC, $007C
    LD      DE, $2380
    LD      HL, $72B6                   ; RAM $72B6
    CALL    VDP_REG_BF8A
    LD      A, $1E
    LD      ($707D), A                  ; RAM $707D
    RST     $08
    LD      A, ($703F)                  ; RAM $703F
    CP      $02
    JR      NZ, LOC_9C5B
    LD      DE, $0004
    LD      IY, $7330                   ; RAM $7330

LOC_9C39:
    LD      A, (IY+0)
    CP      $FE
    JR      Z, LOC_9C5B
    CP      $0B
    JR      NZ, LOC_9C57
    LD      IX, $72C6                   ; RAM $72C6
    LD      C, (IY+3)
    LD      B, $00
    SLA     C
    SLA     C
    ADD     IX, BC
    LD      (IX+0), $80

LOC_9C57:
    ADD     IY, DE
    JR      LOC_9C39

LOC_9C5B:
    LD      A, ($7099)                  ; RAM $7099
    LD      ($7097), A                  ; RAM $7097
    LD      A, $0A
    LD      ($708C), A                  ; RAM $708C
    CALL    SUB_876B
    LD      A, $08
    LD      ($708C), A                  ; RAM $708C
    LD      A, ($7327)                  ; RAM $7327
    AND     $F8
    ADD     A, $50
    LD      ($7098), A                  ; RAM $7098
    SUB     $28
    SRL     A
    SRL     A
    SRL     A
    LD      E, A
    LD      D, $00
    LD      C, D
    LD      A, ($703F)                  ; RAM $703F
    CP      $03
    JR      NZ, LOC_9C8F
    LD      C, $08
    JR      LOC_9C95

LOC_9C8F:
    CP      $05
    JR      NZ, LOC_9C95
    LD      C, $10

LOC_9C95:
    LD      A, ($7326)                  ; RAM $7326
    AND     $F8
    ADD     A, C
    LD      L, A
    LD      H, $00
    AND     $F8
    ADD     A, $10
    LD      ($7097), A                  ; RAM $7097
    SLA     L
    RL      H
    SLA     L
    RL      H
    ADD     HL, DE
    LD      A, $01
    LD      ($707F), A                  ; RAM $707F
    LD      DE, $2060
    ADD     HL, DE
    PUSH    HL
    LD      DE, $22A0
    AND     A
    SBC     HL, DE
    JR      C, LOC_9CC8
    POP     HL
    LD      DE, $0020
    AND     A
    SBC     HL, DE
    PUSH    HL

LOC_9CC8:
    POP     BC
    LD      DE, $BA7B
    CALL    VDP_REG_A958
    LD      A, $04
    LD      B, A
    CALL    PLAY_IT
    LD      A, ($703F)                  ; RAM $703F
    CP      $03
    JR      NZ, LOC_9CF6
    LD      A, $10
    LD      B, A
    CALL    PLAY_IT
    LD      A, $06
    LD      B, A
    CALL    PLAY_IT
    LD      HL, $9FA9
    LD      ($7086), HL                 ; RAM $7086
    LD      HL, $0028
    LD      ($7082), HL                 ; RAM $7082
    JR      LOC_9D20

LOC_9CF6:
    CP      $05
    JR      NZ, LOC_9D14
    LD      A, $11
    LD      B, A
    CALL    PLAY_IT
    LD      A, $07
    LD      B, A
    CALL    PLAY_IT
    LD      HL, $9FBC
    LD      ($7086), HL                 ; RAM $7086
    LD      HL, $002A
    LD      ($7082), HL                 ; RAM $7082
    JR      LOC_9D20

LOC_9D14:
    LD      A, $0F
    LD      B, A
    CALL    PLAY_IT
    LD      A, $05
    LD      B, A
    CALL    PLAY_IT

LOC_9D20:
    LD      A, ($9EEC)
    LD      ($707D), A                  ; RAM $707D
    LD      A, $03
    LD      ($708C), A                  ; RAM $708C
    RET     

VDP_REG_9D2C:
    LD      DE, ($7082)                 ; RAM $7082
    LD      A, $00
    LD      ($709F), A                  ; RAM $709F
    LD      A, $01
    LD      ($707F), A                  ; RAM $707F

LOC_9D3A:
    PUSH    DE
    RST     $08
    LD      BC, $007C
    LD      DE, $2380
    LD      HL, $72B6                   ; RAM $72B6
    CALL    VDP_REG_BF8A
    CALL    SOUND_WRITE_9DD9
    CALL    SOUND_WRITE_9E83
    LD      A, ($709F)                  ; RAM $709F
    CPL     
    LD      ($709F), A                  ; RAM $709F
    LD      A, ($708A)                  ; RAM $708A
    OR      A
    JP      Z, LOC_9DD1
    LD      A, ($703F)                  ; RAM $703F
    CP      $04
    JR      NZ, LOC_9D8A
    LD      IX, ($70A1)                 ; RAM $70A1
    CALL    SUB_8D87
    LD      A, ($7097)                  ; RAM $7097
    SUB     $10
    LD      (IX+0), A
    LD      (IX+4), A
    ADD     A, $10
    LD      (IX+8), A
    LD      A, ($7098)                  ; RAM $7098
    SUB     $06
    LD      (IX+1), A
    LD      (IX+5), A
    LD      (IX+9), A
    JR      LOC_9DD1

LOC_9D8A:
    LD      HL, ($7084)                 ; RAM $7084
    LD      BC, $9F6E
    AND     A
    SBC     HL, BC
    JR      NZ, LOC_9DD1
    LD      A, ($709F)                  ; RAM $709F
    OR      A
    JR      NZ, LOC_9DB7
    LD      HL, $1000
    LD      A, $03
    CALL    INIT_TABLE
    LD      BC, $224B
    LD      DE, $BB45
    CALL    VDP_REG_A958
    LD      BC, $21B9
    LD      DE, $BB51
    CALL    VDP_REG_A958
    JR      LOC_9DD1

LOC_9DB7:
    LD      HL, BOOT_UP
    LD      A, $03
    CALL    INIT_TABLE
    LD      BC, $224C
    LD      DE, $BB45
    CALL    VDP_REG_A958
    LD      BC, $21BA
    LD      DE, $BB51
    CALL    VDP_REG_A958

LOC_9DD1:
    POP     DE
    DEC     DE
    LD      A, D
    OR      E
    JP      NZ, LOC_9D3A
    RET     

SOUND_WRITE_9DD9:                           ; SOUND_WRITE_9DD9 ($9DD9): DEC movement counter $7080; advance $7084 ptr at zero; update $7097/$7098
    LD      A, ($7080)                      ; A=$7080: movement frame counter
    CP      $FF                             ; CP $FF: terminal sentinel (sequence done)
    JR      Z, LOC_9DFD                     ; JR Z, LOC_9DFD: done -> check for attract reset
    DEC     A                               ; DEC A: count down
    LD      ($7080), A                      ; LD ($7080),A: write back
    LD      IX, ($7084)                     ; LD IX,($7084): movement data table ptr
    JR      NZ, LOC_9E1A                    ; JR NZ, LOC_9E1A: counter not zero -> apply current entry
    LD      DE, $0005                       ; LD DE,$0005: stride to next movement entry
    ADD     IX, DE                          ; ADD IX,DE: advance to next entry
    LD      ($7084), IX                     ; LD ($7084),IX: save updated ptr
    LD      A, (IX+0)                       ; A=(IX+0): new frame count
    LD      ($7080), A                      ; LD ($7080),A: reload counter
    CP      $FF
    JR      NZ, LOC_9E1A

LOC_9DFD:
    LD      A, ($708A)                  ; RAM $708A
    OR      A
    RET     NZ
    LD      HL, ($7084)                 ; RAM $7084
    LD      BC, $9F24
    AND     A
    SBC     HL, BC
    RET     C
    LD      IX, $9F24
    LD      ($7084), IX                 ; RAM $7084
    LD      A, (IX+0)
    LD      ($7080), A                  ; RAM $7080

LOC_9E1A:
    LD      L, (IX+3)                       ; LOC_9E1A: LD L,(IX+3); LD H,(IX+4): load object dispatch table ptr
    LD      H, (IX+4)
    LD      ($709B), HL                     ; LD ($709B),HL: update object dispatch ptr
    LD      C, (IX+1)                       ; LD C,(IX+1): X-delta for this entry
    LD      A, ($7097)                      ; A=$7097: current B.C. X position
    ADD     A, C                            ; ADD A,C: apply X delta
    LD      ($7097), A                      ; LD ($7097),A: store updated X
    LD      C, (IX+2)                       ; LD C,(IX+2): Y-delta
    LD      A, ($7098)                      ; A=$7098: current B.C. Y position
    ADD     A, C                            ; ADD A,C: apply Y delta
    LD      ($7098), A                      ; LD ($7098),A: store updated Y
    JR      NC, LOC_9E4B
    LD      A, ($708A)                  ; RAM $708A
    CP      $01
    JR      NZ, LOC_9E4B
    BIT     7, (IX+2)
    JR      NZ, LOC_9E4B
    LD      A, $FF
    LD      ($7098), A                  ; RAM $7098

LOC_9E4B:
    CALL    SUB_876B                        ; CALL SUB_876B: update B.C. sprite position in $7306
    LD      A, ($708A)                  ; RAM $708A
    OR      A
    RET     NZ
    LD      HL, ($7084)                 ; RAM $7084
    LD      BC, $9F24
    AND     A
    SBC     HL, BC
    RET     C
    LD      A, ($7080)                  ; RAM $7080
    CP      $01
    RET     NZ
    LD      A, $00
    LD      ($7311), A                  ; RAM $7311
    RET     
    DB      $3A, $8B, $70, $FE, $01, $C0, $3A, $8A
    DB      $70, $B7, $C0, $DD, $21, $24, $9F, $DD
    DB      $22, $84, $70, $3A, $24, $9F, $32, $80
    DB      $70, $C9

SOUND_WRITE_9E83:                           ; SOUND_WRITE_9E83 ($9E83): DEC Y-anim counter $7081; advance $7086; add delta to $7326 Y coords
    LD      A, ($7081)                      ; A=$7081: Y-animation frame counter
    CP      $FF                             ; CP $FF: terminal sentinel
    RET     Z                               ; RET Z: done when counter = $FF
    DEC     A                               ; DEC A: count down
    LD      ($7081), A                      ; LD ($7081),A: write back
    LD      IX, ($7086)                     ; LD IX,($7086): Y-animation data ptr
    JR      NZ, LOC_9EA5                    ; JR NZ, LOC_9EA5: counter not zero -> apply current entry
    LD      DE, $0003                       ; LD DE,$0003: stride to next Y-anim entry
    ADD     IX, DE                          ; ADD IX,DE: advance ptr
    LD      ($7086), IX                     ; LD ($7086),IX: save
    LD      A, (IX+0)                       ; A=(IX+0): new Y-anim frame count
    LD      ($7081), A                      ; LD ($7081),A: reload counter
    CP      $FF                             ; CP $FF: check for terminal
    RET     Z                               ; RET Z: terminal -> stop Y animation

LOC_9EA5:
    LD      IY, $7326                       ; IY=$7326: sprite position table (Y/X pairs)
    LD      C, (IX+1)                       ; LD C,(IX+1): Y delta
    LD      A, (IY+0)                       ; A=(IY+0): sprite 0 Y
    ADD     A, C                            ; ADD A,C: apply Y delta
    LD      (IY+0), A                       ; LD (IY+0),A: write sprite 0 Y
    LD      A, (IY+4)                       ; A=(IY+4): sprite 1 Y
    ADD     A, C                            ; ADD A,C: apply same Y delta
    LD      (IY+4), A                       ; LD (IY+4),A: write sprite 1 Y
    LD      C, (IX+2)                       ; LD C,(IX+2): X delta
    LD      A, (IY+5)                       ; A=(IY+5): sprite 1 X
    ADD     A, C                            ; ADD A,C: apply X delta
    LD      (IY+5), A                       ; LD (IY+5),A: write sprite 1 X
    LD      A, (IY+1)                       ; A=(IY+1): sprite 0 X
    ADD     A, C                            ; ADD A,C
    LD      (IY+1), A                       ; LD (IY+1),A: write sprite 0 X
    CP      $F5                             ; CP $F5: off-screen boundary?
    RET     C                               ; RET C: still on-screen
    LD      (IY+3), $00                     ; LD (IY+3),$00: clear sprite 0 collision flag
    LD      (IY+7), $00                     ; LD (IY+7),$00: clear sprite 1 collision flag
    RET     

DELAY_LOOP_9ED7:                            ; DELAY_LOOP_9ED7 ($9ED7): scan $7330 for B.C. sprite ID $10; RET NC=found, SCF=not found
    LD      IY, $7330                       ; IY=$7330: sprite object table
    LD      DE, $0004                       ; DE=$0004: slot stride
    LD      B, $0B                          ; LD B,$0B: 11 slots to scan
    LD      A, $10                          ; LD A,$10: B.C. player sprite type ID

LOC_9EE2:
    CP      (IY+0)                          ; CP (IY+0): compare slot type
    RET     Z                               ; RET Z: found B.C. -> return NC (no carry)
    ADD     IY, DE                          ; ADD IY,DE: advance to next slot
    DJNZ    LOC_9EE2                        ; DJNZ LOC_9EE2: scan all slots
    SCF                                     ; SCF: not found in table -> set carry (player hit)
    RET     
    DB      $04, $24, $9F, $99, $9F, $1A, $00, $03
    DB      $03, $3F, $9F, $D9, $9F, $19, $00, $12
    DB      $02, $2F, $9F, $CF, $9F, $4B, $00, $15
    DB      $04, $4F, $9F, $E3, $9F, $20, $00, $13
    DB      $03, $64, $9F, $F0, $9F, $4B, $00, $14
    DB      $02, $79, $9F, $FD, $9F, $4B, $00, $15
    DB      $02, $8E, $9F, $07, $A0, $2D, $00, $15
    DB      $02, $00, $00, $2E, $89, $02, $00, $00
    DB      $3A, $89, $FF, $06, $00, $04, $3E, $88
    DB      $1E, $00, $00, $B6, $88, $11, $09, $00
    DB      $B6, $88, $FF, $03, $FB, $03, $3E, $88
    DB      $18, $00, $04, $8E, $88, $03, $05, $03
    DB      $8E, $88, $FF, $12, $FD, $04, $8E, $88
    DB      $06, $00, $04, $8E, $88, $04, $02, $04
    DB      $8E, $88, $04, $01, $02, $8E, $88, $FF
    DB      $08, $FF, $05, $B6, $88, $06, $01, $05
    DB      $B6, $88, $28, $00, $00, $DE, $88, $0A
    DB      $08, $00, $DE, $88, $FF, $08, $FE, $04
    DB      $B6, $88, $03, $01, $06, $B6, $88, $1E
    DB      $00, $00, $B6, $88, $0C, $09, $00, $B6
    DB      $88, $FF, $14, $00, $00, $B6, $88, $14
    DB      $05, $00, $B6, $88, $FF, $05, $F7, $09
    DB      $05, $09, $09, $05, $F7, $09, $05, $09
    DB      $09, $05, $F7, $09, $FF, $07, $F7, $05
    DB      $06, $07, $07, $07, $F8, $06, $06, $06
    DB      $07, $07, $F8, $06, $06, $06, $07, $FF
    DB      $05, $F8, $09, $08, $09, $06, $06, $F9
    DB      $08, $08, $09, $07, $06, $F8, $08, $08
    DB      $09, $07, $FF, $06, $00, $04, $0F, $00
    DB      $00, $0E, $09, $00, $FF, $03, $FB, $03
    DB      $18, $00, $04, $03, $05, $03, $FF, $12
    DB      $FD, $04, $06, $00, $04, $04, $02, $04
    DB      $04, $01, $02, $FF, $08, $FF, $05, $06
    DB      $01, $05, $0A, $00, $00, $0A, $0A, $00
    DB      $FF, $08, $FE, $04, $03, $01, $06, $0C
    DB      $09, $00, $FF, $14, $00, $00, $14, $05
    DB      $00, $FF

SOUND_WRITE_A00E:                           ; SOUND_WRITE_A00E ($A00E): game event processor: collision, score, phase transitions
    LD      A, ($703F)                      ; A=$703F: game phase
    CP      $07                             ; CP $07: inter-level or attract?
    JR      Z, LOC_A028                     ; JR Z, LOC_A028: yes -> skip scroll-counter update
    CP      $09                             ; CP $09: attract?
    JR      Z, LOC_A028
    LD      HL, ($7064)                     ; HL=($7064): scroll-distance counter
    LD      A, ($707C)                      ; A=$707C: scroll speed
    LD      C, A
    LD      B, $00
    AND     A
    SBC     HL, BC                          ; LD ($7064),HL: update remaining scroll distance
    LD      ($7064), HL                 ; RAM $7064

LOC_A028:
    LD      A, $00                          ; LD A,$00; LD ($709F),A: clear hazard-present flag
    LD      ($709F), A                      ; LD ($708B),A: clear state-advance flag
    LD      ($708B), A                  ; RAM $708B
    LD      IX, $7330                       ; LD IX,$7330: sprite object table

LOC_A034:
    LD      A, (IX+0)                       ; A=(IX+0): slot type byte
    CP      $FE                             ; CP $FE: end-of-table?
    JP      Z, LOC_A04F                     ; JP Z, LOC_A04F: yes -> post-scan checks
    CP      $FF                             ; CP $FF: empty slot?
    CALL    NZ, SUB_A1A8                    ; CALL NZ, SUB_A1A8: active sprite -> process collision/score
    LD      A, ($708B)                      ; A=$708B: check if state-advance was set
    CP      $01
    JR      Z, LOC_A094                     ; JR Z, LOC_A094: not set -> continue scan
    LD      DE, $0004
    ADD     IX, DE
    JR      LOC_A034

LOC_A04F:
    LD      A, ($703F)                  ; RAM $703F
    CP      $07
    JR      Z, LOC_A073
    CP      $09
    JR      NZ, LOC_A094
    LD      A, ($7082)                  ; RAM $7082
    CP      $05
    JR      C, LOC_A073
    LD      A, ($7081)                  ; RAM $7081
    OR      A
    JR      NZ, LOC_A094
    LD      A, $01
    LD      ($708B), A                  ; RAM $708B
    LD      A, $06
    LD      ($708A), A                  ; RAM $708A
    JR      LOC_A094

LOC_A073:
    LD      A, ($709F)                  ; RAM $709F
    CP      $00
    JR      NZ, LOC_A094
    LD      A, ($7082)                  ; RAM $7082
    OR      A
    JR      Z, LOC_A094
    CP      $05
    JR      Z, LOC_A094
    LD      A, ($7092)                  ; RAM $7092
    OR      A
    JR      NZ, LOC_A094
    LD      A, $01
    LD      ($708B), A                  ; RAM $708B
    LD      A, $06
    LD      ($708A), A                  ; RAM $708A

LOC_A094:
    LD      A, ($703F)                  ; RAM $703F
    CP      $07
    JR      Z, LOC_A09F
    CP      $09
    JR      NZ, LOC_A0AA

LOC_A09F:
    LD      A, ($707D)                  ; RAM $707D
    LD      C, A
    LD      A, ($7068)                  ; RAM $7068
    ADD     A, C
    LD      ($707D), A                  ; RAM $707D

LOC_A0AA:
    LD      A, ($7045)                  ; RAM $7045
    ADD     A, $F1
    LD      ($709F), A                  ; RAM $709F
    LD      HL, $22F3
    DB      $EB
    LD      BC, $0001
    LD      HL, $737F                   ; RAM $737F
    PUSH    HL
    CALL    READ_VRAM
    POP     HL
    LD      A, (HL)
    LD      ($70A0), A                  ; RAM $70A0
    LD      ($7046), A                  ; RAM $7046
    LD      A, ($707D)                  ; RAM $707D
    LD      C, A
    LD      A, ($7060)                  ; RAM $7060
    OR      A
    JP      Z, LOC_A156
    SUB     C
    LD      ($7060), A                  ; RAM $7060
    JR      Z, LOC_A0E0
    JP      NC, LOC_A156
    XOR     A
    LD      ($7060), A                  ; RAM $7060

LOC_A0E0:
    LD      A, ($705F)                  ; RAM $705F
    CP      $01
    JR      NZ, LOC_A10A
    LD      A, ($70A0)                  ; RAM $70A0
    INC     A
    LD      ($70A0), A                  ; RAM $70A0
    CP      $FA
    JR      C, LOC_A156
    LD      A, $F0
    LD      ($70A0), A                  ; RAM $70A0
    LD      A, ($709F)                  ; RAM $709F
    INC     A
    LD      ($709F), A                  ; RAM $709F
    LD      A, ($7045)                  ; RAM $7045
    INC     A
    LD      ($7045), A                  ; RAM $7045
    LD      BC, $FFFF
    JR      LOC_A143

LOC_A10A:
    CP      $02
    JR      NZ, LOC_A156
    LD      A, ($70A0)                  ; RAM $70A0
    DEC     A
    LD      ($70A0), A                  ; RAM $70A0
    CP      $F0
    JR      NC, LOC_A156
    LD      A, ($7061)                  ; RAM $7061
    LD      C, A
    LD      A, ($7045)                  ; RAM $7045
    CP      C
    JR      NZ, LOC_A12D
    LD      A, $F0
    LD      ($70A0), A                  ; RAM $70A0
    LD      BC, BOOT_UP
    JR      LOC_A143

LOC_A12D:
    LD      A, $F9
    LD      ($70A0), A                  ; RAM $70A0
    LD      A, ($709F)                  ; RAM $709F
    DEC     A
    LD      ($709F), A                  ; RAM $709F
    LD      A, ($7045)                  ; RAM $7045
    DEC     A
    LD      ($7045), A                  ; RAM $7045
    LD      BC, $0001

LOC_A143:
    LD      A, $00
    LD      ($705F), A                  ; RAM $705F
    LD      A, ($703F)                  ; RAM $703F
    CP      $04
    JR      NZ, LOC_A156
    LD      HL, ($7073)                 ; RAM $7073
    ADD     HL, BC
    LD      ($7073), HL                 ; RAM $7073

LOC_A156:
    LD      BC, $0002
    LD      DE, $22F2
    LD      HL, $709F                   ; RAM $709F
    CALL    VDP_REG_BF8A
    LD      HL, $7048                   ; RAM $7048
    CALL    DELAY_LOOP_A2BE
    LD      BC, $0006
    LD      DE, $22F8
    LD      HL, $709F                   ; RAM $709F
    CALL    VDP_REG_BF8A
    LD      A, ($703E)                  ; RAM $703E
    ADD     A, $F0
    LD      HL, $22C5
    DB      $EB
    LD      A, A
    LD      HL, $737F                   ; RAM $737F
    LD      (HL), A
    LD      BC, $0001
    CALL    WRITE_VRAM
    CALL    SUB_A3B5
    LD      HL, $7037                   ; RAM $7037
    LD      A, ($703D)                  ; RAM $703D
    CP      $01
    JR      Z, LOC_A198
    LD      HL, $704B                   ; RAM $704B

LOC_A198:
    CALL    DELAY_LOOP_A2BE
    LD      BC, $0006
    LD      DE, $22E9
    LD      HL, $709F                   ; RAM $709F
    CALL    VDP_REG_BF8A
    RET     

SUB_A1A8:                                   ; SUB_A1A8 ($A1A8): per-sprite dispatcher: $10=B.C. $0A=hazard; test collision via A300
    CP      $10                             ; CP $10: is this the B.C. player sprite?
    RET     Z                               ; RET Z: player sprite: no action here
    CP      $0A                             ; CP $0A: is this a hazard sprite?
    JP      NZ, LOC_A1F6
    CALL    SOUND_WRITE_A300                ; CALL SOUND_WRITE_A300: bounding box collision test (carry = no hit)
    NOP                                     ; NOP
    JR      NZ, LOC_A1AE                    ; JR NZ, LOC_A1AE: no collision -> continue
    RET     C
    JR      NZ, LOC_A1EB
    LD      A, ($7092)                  ; RAM $7092
    OR      A
    RET     Z
    CALL    DELAY_LOOP_9ED7
    JP      C, LOC_A1EB
    PUSH    IX
    PUSH    IY
    POP     IX
    CALL    SOUND_WRITE_A300
    JR      LOC_A1E7
    DB      $00, $DD, $E1, $D8, $C0, $3E, $01, $32
    DB      $8B, $70, $3E, $01, $32, $8A, $70, $3A
    DB      $44, $70, $FE, $09, $C8, $01, $00, $02

LOC_A1E7:
    CALL    SUB_A359
    RET     

LOC_A1EB:
    LD      A, $01
    LD      ($708B), A                  ; RAM $708B
    LD      A, $02
    LD      ($708A), A                  ; RAM $708A
    RET     

LOC_A1F6:
    CP      $0C
    JR      Z, LOC_A1FE
    CP      $0E
    JR      NZ, LOC_A214

LOC_A1FE:
    CALL    SOUND_WRITE_A300
    DJNZ    LOC_A203

LOC_A203:
    EX      AF, AF'
    RET     C
    RET     NZ
    LD      A, ($7094)                  ; RAM $7094
    OR      A
    RET     NZ
    LD      ($708A), A                  ; RAM $708A
    LD      A, $01
    LD      ($708B), A                  ; RAM $708B
    RET     

LOC_A214:
    CP      $0B
    JR      NZ, LOC_A23B
    LD      A, (IX+1)
    CP      $78
    JP      NC, LOC_A2A8
    LD      C, (IX+1)
    LD      A, ($7097)                  ; RAM $7097
    DEC     A
    CP      C
    RET     NC
    CALL    SOUND_WRITE_A300
    DJNZ    LOC_A22E

LOC_A22E:
    NOP     
    RET     C
    RET     NZ
    LD      A, $01
    LD      ($708B), A                  ; RAM $708B
    XOR     A
    LD      ($708A), A                  ; RAM $708A
    RET     

LOC_A23B:
    CP      $11
    JP      NZ, LOC_A2A8
    CALL    SOUND_WRITE_A300
    DJNZ    LOC_A245

LOC_A245:
    RET     M
    RET     C
    RET     NZ
    LD      A, $01
    LD      ($709F), A                  ; RAM $709F
    LD      A, ($7082)                  ; RAM $7082
    OR      A
    RET     Z
    CP      $05
    RET     Z
    LD      A, ($7092)                  ; RAM $7092
    OR      A
    JR      NZ, LOC_A272
    LD      HL, $7330                   ; RAM $7330
    LD      A, ($7082)                  ; RAM $7082
    LD      C, A
    LD      B, $00
    DEC     C
    SLA     C
    SLA     C
    ADD     HL, BC
    INC     HL
    LD      A, (HL)
    CP      $90
    JR      C, LOC_A272
    JR      NZ, LOC_A287

LOC_A272:
    LD      A, ($703F)                  ; RAM $703F
    CP      $07
    JR      NZ, LOC_A292
    LD      A, ($7081)                  ; RAM $7081
    OR      A
    RET     NZ
    LD      A, ($7098)                  ; RAM $7098
    CP      $90
    RET     C
    CP      $B1
    RET     NC

LOC_A287:
    LD      A, $01
    LD      ($708B), A                  ; RAM $708B
    LD      A, $06
    LD      ($708A), A                  ; RAM $708A
    RET     

LOC_A292:
    LD      A, ($7082)                  ; RAM $7082
    CP      $05
    RET     NZ
    LD      A, ($7081)                  ; RAM $7081
    OR      A
    RET     NZ
    LD      A, $01
    LD      ($708B), A                  ; RAM $708B
    LD      A, $06
    LD      ($708A), A                  ; RAM $708A
    RET     

LOC_A2A8:
    CALL    SOUND_WRITE_A300
    DJNZ    LOC_A2AD

LOC_A2AD:
    RET     M
    RET     C
    RET     NZ
    LD      A, ($7092)                  ; RAM $7092
    OR      A
    RET     NZ
    LD      ($708A), A                  ; RAM $708A
    LD      A, $01
    LD      ($708B), A                  ; RAM $708B
    RET     

DELAY_LOOP_A2BE:                            ; DELAY_LOOP_A2BE ($A2BE): convert 3 BCD score bytes at HL -> 6 VRAM digit tiles at $70A4
    LD      IY, $70A4                       ; IY=$70A4: output digit buffer (6 bytes, high to low)
    LD      B, $03                          ; LD B,$03: 3 score bytes

LOC_A2C4:
    LD      A, (HL)                         ; A=(HL): load current BCD score byte
    PUSH    AF                              ; PUSH AF
    OR      $F0                             ; OR $F0: low nibble -> VRAM digit tile index ($F0-$F9)
    LD      (IY+0), A                       ; LD (IY+0),A: store low digit
    DEC     IY                              ; DEC IY
    POP     AF                              ; POP AF
    SRL     A                               ; SRL A: shift high nibble down (× 4)
    SRL     A                               ; SRL A
    SRL     A                               ; SRL A
    SRL     A                               ; SRL A
    OR      $F0                             ; OR $F0: high nibble -> VRAM digit tile index
    LD      (IY+0), A                       ; LD (IY+0),A: store high digit
    INC     HL                              ; INC HL: advance to next score byte
    DEC     IY                              ; DEC IY
    DJNZ    LOC_A2C4                        ; DJNZ LOC_A2C4: loop for all 3 bytes
    RET     

SUB_A2E1:                                   ; SUB_A2E1 ($A2E1): DEC lives counter $703E; write updated digit to VRAM $22C5
    LD      A, ($7044)                      ; A=$7044: check game mode
    CP      $09                             ; CP $09: attract mode?
    RET     Z                               ; RET Z: don't decrement in attract
    LD      A, ($703E)                      ; A=$703E: current lives count
    DEC     A                               ; DEC A: lose one life
    LD      ($703E), A                      ; LD ($703E),A: store updated lives
    ADD     A, $F0                          ; ADD A,$F0: convert to VRAM digit tile index
    LD      HL, $22C5
    DB      $EB
    LD      A, A
    LD      HL, $737F                       ; LD (HL),A: stage digit in $737F buffer
    LD      (HL), A
    LD      BC, $0001                       ; CALL WRITE_VRAM: write lives digit to VRAM $22C5
    CALL    WRITE_VRAM
    RET     

SOUND_WRITE_A300:                           ; SOUND_WRITE_A300 ($A300): inline-data bounding-box test: sprite(IX) vs B.C. pos; RET NC=hit
    POP     HL                              ; POP HL: return address used as inline data ptr
    LD      A, (IX+2)                       ; A=(IX+2): sprite X center
    ADD     A, (HL)                         ; ADD A,(HL): + left X half-width
    JR      NC, LOC_A309                    ; JR NC, LOC_A309: no overflow
    LD      A, $FF                          ; A=$FF: clamp to $FF

LOC_A309:
    LD      E, A                            ; LD E,A: E = right X boundary
    SUB     (HL)                            ; SUB (HL): subtract span
    INC     HL                              ; INC HL
    SUB     (HL)                            ; SUB (HL): subtract left margin
    JR      NC, LOC_A310                    ; JR NC, LOC_A310: X within range
    XOR     A                               ; XOR A: X out of range (carry set)

LOC_A310:
    LD      C, A
    INC     HL
    LD      A, ($7098)                      ; A=$7098: B.C. Y position
    ADD     A, (HL)                         ; ADD A,(HL): + Y offset
    INC     HL
    PUSH    HL
    CP      C
    RET     C                               ; CP C: compare to Y max bound
    SUB     E                               ; RET C: Y too small -> no collision (RET NC)
    JR      NC, LOC_A31F
    XOR     A
    RET     

LOC_A31F:
    EX      AF, AF'
    LD      A, ($7044)                  ; RAM $7044
    CP      $09
    JR      Z, LOC_A395
    LD      A, ($707C)                  ; RAM $707C
    LD      C, A
    LD      A, (IX+0)
    CP      $07
    JR      NZ, LOC_A334
    SLA     C

LOC_A334:
    EX      AF, AF'
    SUB     C
    JR      C, LOC_A33B
    JR      Z, LOC_A395
    RET     NZ

LOC_A33B:
    LD      A, (IX+0)
    CP      $11
    JR      NZ, LOC_A344
    JR      LOC_A395

LOC_A344:
    LD      HL, $A3EB
    LD      C, A
    LD      B, $00
    ADD     HL, BC
    LD      A, ($7045)                  ; RAM $7045
    LD      B, A
    LD      A, (HL)
    SRL     B
    JR      Z, LOC_A358

LOC_A354:
    ADD     A, A
    DAA     
    DJNZ    LOC_A354

LOC_A358:
    LD      C, A

SUB_A359:                                   ; SUB_A359 ($A359): BCD add C (score) to $7048 (3-byte BCD); check/update hi-score
    LD      HL, ($7049)                     ; LD HL,($7049): load current hi-score
    PUSH    HL
    LD      HL, $7048                       ; LD HL,$7048: player score base
    LD      A, C                            ; A=C: score delta to add
    ADD     A, (HL)                         ; ADD A,(HL): BCD add to score byte 0
    DAA                                     ; DAA: BCD adjust
    LD      (HL), A                         ; LD (HL),A: store byte 0
    INC     HL                              ; INC HL
    LD      A, B                            ; A=B: carry BCD digit
    ADC     A, (HL)                         ; ADC A,(HL): add carry to byte 1
    DAA                                     ; DAA
    LD      (HL), A                         ; LD (HL),A: store byte 1
    INC     HL
    LD      A, (HL)                         ; A=(HL): byte 2
    ADC     A, $00                          ; ADC A,$00: propagate carry
    DAA                                     ; DAA
    LD      (HL), A                         ; LD (HL),A: store byte 2
    POP     HL
    CALL    DELAY_LOOP_A399
    PUSH    DE
    LD      HL, ($7049)                 ; RAM $7049
    CALL    DELAY_LOOP_A399
    POP     HL
    AND     A
    SBC     HL, DE
    JR      Z, LOC_A395
    LD      A, ($703E)                  ; RAM $703E
    CP      $09
    JR      Z, LOC_A395
    SUB     L
    LD      ($703E), A                  ; RAM $703E
    PUSH    IX
    LD      A, $17
    LD      B, A
    CALL    PLAY_IT                         ; CALL PLAY_IT B=$17: play score sound
    POP     IX

LOC_A395:
    LD      A, $01
    OR      A
    RET     

DELAY_LOOP_A399:                            ; DELAY_LOOP_A399 ($A399): score scaler: convert $7048 3-byte to (DE,H) = (pages, offset)
    LD      A, ($7044)                  ; RAM $7044
    LD      B, A
    LD      C, $10
    LD      A, C

LOC_A3A0:
    ADD     A, C
    DJNZ    LOC_A3A0
    LD      C, A
    LD      DE, BOOT_UP
    LD      A, L

LOC_A3A8:
    SUB     C
    JR      NC, LOC_A3B2
    DEC     H
    RET     M
    ADD     A, C
    ADD     A, $A0
    JR      LOC_A3A8

LOC_A3B2:
    INC     DE
    JR      LOC_A3A8

SUB_A3B5:                                   ; SUB_A3B5 ($A3B5): hi-score update: compare $7048 player score vs $7037 hi-score; update if higher
    LD      BC, ($7048)                     ; LD BC,($7048): player score bytes 0-1
    LD      A, ($704A)                      ; A=$704A: player score byte 2
    LD      E, A
    LD      HL, ($7037)                     ; LD HL,($7037): hi-score bytes 0-1
    LD      A, ($7039)                      ; A=$7039: hi-score byte 2
    SUB     E
    JR      C, LOC_A3CF
    JR      Z, LOC_A3CA
    JR      NC, LOC_A3D7

LOC_A3CA:
    AND     A
    SBC     HL, BC
    JR      NC, LOC_A3D7

LOC_A3CF:
    LD      ($7037), BC                 ; RAM $7037
    LD      A, E
    LD      ($7039), A                  ; RAM $7039

LOC_A3D7:
    LD      IX, $7037                   ; RAM $7037
    LD      B, $03
    OR      A

LOC_A3DE:
    LD      A, $00
    SBC     A, (IX+0)
    LD      (IX+3), A
    INC     IX
    DJNZ    LOC_A3DE
    RET     
    DB      $00, $10, $10, $10, $10, $10, $10, $15
    DB      $10, $10, $00, $15, $10, $10, $10, $10
    DB      $00, $00

SUB_A3FD:                                   ; SUB_A3FD ($A3FD): full tile init loop: INIT_TABLE + VDP_REG_BF8A per VRAM column pass
    PUSH    BC
    LD      HL, BOOT_UP                     ; LD HL,BOOT_UP; CALL INIT_TABLE A=$03: advance signal timer table
    LD      A, $03
    CALL    INIT_TABLE
    POP     BC
    LD      HL, BOOT_UP
    LD      ($709D), HL                     ; LD ($709D),HL: save VRAM scroll base ptr
    LD      B, C                            ; LD B,C: outer loop count from caller

LOC_A40E:
    PUSH    BC
    LD      HL, $2000                       ; LD HL,$2000; LD ($709F),HL: scroll plane 0 VRAM base
    LD      ($709F), HL                 ; RAM $709F
    LD      HL, $3000
    LD      ($70A1), HL                     ; LD HL,$3000; LD ($70A1),HL: scroll plane 1 VRAM base
    LD      A, $00
    LD      ($706F), A                  ; RAM $706F

LOC_A420:                                   ; LOC_A420: per-pass scroll column update loop
    LD      A, ($706F)                      ; A=$706F; INC A: advance pass counter
    INC     A
    LD      ($706F), A                  ; RAM $706F
    CP      $03
    JR      Z, LOC_A484                     ; CP $03: done after 3 passes?
    RST     $08                             ; JR Z, LOC_A484: yes -> done
    LD      B, $0B                          ; RST $08: wait one VBL between passes

LOC_A42E:
    PUSH    BC
    LD      BC, $0020
    LD      DE, ($709F)                 ; RAM $709F
    LD      HL, $70A6                       ; LD HL,$70A6: scroll plane 0 buffer
    CALL    VDP_REG_BFA6                    ; CALL VDP_REG_BFA6: read VRAM column into buffer
    LD      BC, $0020
    LD      DE, ($70A1)                 ; RAM $70A1
    LD      HL, $70C6                   ; RAM $70C6
    CALL    VDP_REG_BFA6
    LD      HL, $70A7                   ; RAM $70A7
    LD      DE, $70A6                   ; RAM $70A6
    LD      BC, $0040
    LDIR    
    LD      BC, $0020
    LD      DE, ($709F)                 ; RAM $709F
    LD      HL, $70A6                   ; RAM $70A6
    CALL    VDP_REG_BF8A                    ; CALL VDP_REG_BF8A: write updated column to VRAM
    LD      BC, $0020
    LD      DE, ($70A1)                 ; RAM $70A1
    LD      HL, $70C6                   ; RAM $70C6
    CALL    VDP_REG_BF8A
    LD      BC, $0020
    LD      HL, ($709F)                 ; RAM $709F
    ADD     HL, BC
    LD      ($709F), HL                 ; RAM $709F
    LD      HL, ($70A1)                 ; RAM $70A1
    ADD     HL, BC
    LD      ($70A1), HL                 ; RAM $70A1
    POP     BC
    DJNZ    LOC_A42E
    JR      LOC_A420

LOC_A484:
    POP     BC
    DJNZ    LOC_A40E
    RET     

SUB_A488:                                   ; SUB_A488 ($A488): game-over/phase transition: clear VRAM, set start pos, RST $08 wait
    PUSH    AF                              ; PUSH AF: save phase type
    CP      $04                             ; CP $04: game-over transition?
    JR      Z, LOC_A4AC                     ; JR Z, LOC_A4AC: yes -> go directly to state update
    CALL    SUB_ABDA                        ; CALL SUB_ABDA: silence SN76489A
    LD      A, ($703F)                      ; A=$703F: check current phase
    CP      $01
    JR      NZ, LOC_A49B
    LD      B, $12
    JR      LOC_A4A9

LOC_A49B:
    CP      $03
    JR      NZ, LOC_A4A3
    LD      B, $13
    JR      LOC_A4A9

LOC_A4A3:
    CP      $08
    JR      NZ, LOC_A4AC
    LD      B, $12

LOC_A4A9:
    CALL    PLAY_IT

LOC_A4AC:
    LD      A, ($708B)                  ; RAM $708B
    CP      $01
    JR      NZ, LOC_A511
    LD      HL, $8537
    LD      DE, $72B6                   ; RAM $72B6
    LD      BC, $0010
    LDIR    
    LD      BC, $007C
    LD      DE, $2380
    LD      HL, $72B6                   ; RAM $72B6
    CALL    VDP_REG_BF8A
    LD      A, $D0
    LD      DE, $0002
    LD      HL, $2390
    CALL    FILL_VRAM
    LD      A, $FE
    LD      DE, $02C0
    LD      HL, $2000
    CALL    FILL_VRAM
    LD      HL, $A6A5
    LD      A, ($703F)                  ; RAM $703F
    LD      C, A
    DEC     C
    SLA     C
    LD      B, $00
    ADD     HL, BC
    LD      A, (HL)
    LD      ($7097), A                  ; RAM $7097
    LD      ($7099), A                  ; RAM $7099
    INC     HL
    LD      A, (HL)
    LD      ($7098), A                  ; RAM $7098
    LD      HL, BOOT_UP
    LD      ($70A3), HL                 ; RAM $70A3
    LD      A, ($704E)                      ; CALL WRITE_REGISTER: apply VDP settings
    CP      $04
    JP      Z, LOC_A5D0
    LD      B, $01
    LD      C, $C2
    CALL    WRITE_REGISTER
    JP      LOC_A5D0

LOC_A511:
    LD      HL, $A69A
    LD      DE, $7246                   ; RAM $7246
    LD      BC, $000B
    LDIR    
    LD      IX, $7246                   ; RAM $7246
    LD      A, ($7098)                  ; RAM $7098
    LD      D, A
    SRL     D
    SRL     D
    SRL     D
    LD      A, $20
    SUB     D
    LD      (IX+0), A
    LD      A, ($703F)                  ; RAM $703F
    CP      $03
    JR      NZ, LOC_A543
    LD      C, $03
    LD      A, (IX+0)
    ADD     A, C
    LD      (IX+0), A
    LD      A, D
    SUB     C
    LD      D, A

LOC_A543:
    LD      (IX+5), D
    LD      A, ($703F)                  ; RAM $703F
    CP      $01
    JR      Z, LOC_A584
    LD      HL, ($7040)                 ; RAM $7040
    DEC     HL
    LD      A, (HL)
    CP      $06
    JR      NZ, LOC_A55C
    LD      (IX+1), $02
    JR      LOC_A58A

LOC_A55C:
    CP      $03
    JR      NZ, LOC_A56C
    INC     (IX+0)
    DEC     (IX+5)
    LD      (IX+1), $FE
    JR      LOC_A574

LOC_A56C:
    CP      $05
    JR      NZ, LOC_A584
    LD      (IX+1), $02

LOC_A574:
    LD      A, ($7092)                  ; RAM $7092
    OR      A
    JR      Z, LOC_A58A
    LD      A, ($7097)                  ; RAM $7097
    ADD     A, $0A
    LD      ($7097), A                  ; RAM $7097
    JR      LOC_A58A

LOC_A584:
    LD      A, ($7099)                  ; RAM $7099
    LD      ($7097), A                  ; RAM $7097

LOC_A58A:
    LD      HL, $A6A5
    LD      A, ($703F)                  ; RAM $703F
    LD      C, A
    DEC     C
    SLA     C
    LD      B, $00
    ADD     HL, BC
    LD      A, (HL)
    LD      ($7099), A                  ; RAM $7099
    LD      E, (IX+1)
    LD      B, (IX+0)
    XOR     A

LOC_A5A2:
    DEC     B
    JP      M, LOC_A5A9
    ADD     A, E
    JR      LOC_A5A2

LOC_A5A9:
    LD      E, A
    LD      A, ($7097)                  ; RAM $7097
    ADD     A, E
    LD      E, A
    LD      IX, $70A3                   ; RAM $70A3
    LD      IY, $724C                   ; RAM $724C
    CALL    SUB_A65D
    INC     HL
    LD      A, ($7098)                  ; RAM $7098
    LD      E, A
    INC     IX
    INC     IY
    CALL    SUB_A65D
    LD      HL, $7246                   ; RAM $7246
    LD      ($7084), HL                 ; RAM $7084
    LD      A, (HL)
    LD      ($7080), A                  ; RAM $7080

LOC_A5D0:
    POP     AF
    LD      B, A
    PUSH    BC
    LD      A, ($707D)                  ; RAM $707D
    PUSH    AF
    LD      A, $01
    LD      ($707D), A                  ; RAM $707D
    LD      A, $0A
    LD      ($708C), A                  ; RAM $708C
    XOR     A
    LD      ($7092), A                  ; RAM $7092
    LD      ($7094), A                  ; RAM $7094
    LD      ($7093), A                  ; RAM $7093
    LD      ($7063), A                  ; RAM $7063

LOC_A5EE:
    PUSH    BC
    RST     $08
    LD      BC, $0001
    CALL    SUB_A3FD
    LD      A, ($708B)                  ; RAM $708B
    CP      $01
    JR      Z, LOC_A60F
    CALL    SOUND_WRITE_9DD9
    CALL    SUB_876B
    LD      BC, $007C
    LD      DE, $2380
    LD      HL, $72B6                   ; RAM $72B6
    CALL    VDP_REG_BF8A

LOC_A60F:
    POP     BC
    DJNZ    LOC_A5EE
    LD      DE, ($70A3)                 ; RAM $70A3
    LD      A, ($7098)                  ; RAM $7098
    ADD     A, D
    LD      ($7098), A                  ; RAM $7098
    LD      A, ($7097)                  ; RAM $7097
    ADD     A, E
    LD      ($7097), A                  ; RAM $7097
    CALL    SUB_876B
    POP     AF
    LD      ($707D), A                  ; RAM $707D
    POP     BC
    LD      A, ($703F)                  ; RAM $703F
    CP      $07
    JR      Z, LOC_A650
    CP      $09
    JR      Z, LOC_A650
    CP      $04
    JR      Z, LOC_A650
    LD      HL, ($7052)                 ; RAM $7052
    PUSH    HL
    LD      C, $12
    CALL    SUB_8E2E
    CALL    LOC_8BBE
    LD      A, $3C
    LD      ($704F), A                  ; RAM $704F
    POP     HL
    LD      ($7052), HL                 ; RAM $7052

LOC_A650:
    LD      BC, $007C
    LD      DE, $2380
    LD      HL, $72B6                   ; RAM $72B6
    CALL    VDP_REG_BF8A
    RET     

SUB_A65D:
    LD      A, (HL)
    SUB     E
    JR      C, LOC_A66B
    CALL    SUB_A67C
    LD      (IX+0), A
    LD      (IY+0), B
    RET     

LOC_A66B:
    NEG     
    CALL    SUB_A67C
    NEG     
    LD      (IX+0), A
    LD      A, B
    NEG     
    LD      (IY+0), A
    RET     

SUB_A67C:
    LD      B, $00

LOC_A67E:
    SUB     D
    JR      C, LOC_A684
    INC     B
    JR      LOC_A67E

LOC_A684:
    ADD     A, D
    PUSH    AF
    SLA     A
    CP      D
    JR      C, LOC_A690
    INC     B
    POP     AF
    SUB     D
    JR      LOC_A691

LOC_A690:
    POP     AF

LOC_A691:
    RET     
    DB      $28, $C8, $EC, $0F, $28, $D8, $F0, $0F
    DB      $00, $00, $00, $3E, $88, $00, $00, $00
    DB      $3E, $88, $FF, $54, $80, $54, $45, $5E
    DB      $4A, $28, $80, $3B, $45, $68, $45, $54
    DB      $34, $58, $30, $54, $28, $21, $00, $00
    DB      $22, $68, $70, $2A, $88, $70, $06, $04
    DB      $C5, $7E, $32, $50, $70, $23, $7E, $32
    DB      $51, $70, $23, $E5, $01, $11, $00, $CD
    DB      $2E, $8E, $E1, $C1, $10, $EA, $3A, $44
    DB      $70, $FE, $09, $28, $0D, $4F, $0D, $06
    DB      $00, $CB, $21, $CB, $10, $CB, $21, $CB
    DB      $10, $09, $22, $88, $70, $3E, $01, $32
    DB      $80, $70, $32, $81, $70, $3E, $00, $32
    DB      $8B, $70, $AF, $32, $82, $70, $3E, $05
    DB      $32, $7D, $70, $3A, $3F, $70, $FE, $07
    DB      $20, $18, $11, $84, $70, $21, $08, $A9
    DB      $01, $04, $00, $ED, $B0, $11, $EA, $72
    DB      $21, $0C, $A9, $01, $0C, $00, $ED, $B0
    DB      $18, $16, $11, $84, $70, $21, $30, $A9
    DB      $01, $04, $00, $ED, $B0, $11, $EA, $72
    DB      $21, $34, $A9, $01, $0C, $00, $ED, $B0
    DB      $DD, $21, $F6, $72, $11, $04, $00, $06
    DB      $04, $DD, $36, $00, $A0, $DD, $36, $01
    DB      $00, $DD, $36, $02, $9C, $DD, $36, $03
    DB      $00, $DD, $19, $10, $EC, $CF, $CD, $6B
    DB      $87, $01, $80, $00, $11, $80, $23, $21
    DB      $B6, $72, $CD, $8A, $BF, $21, $32, $00
    DB      $22, $52, $70, $CD, $CC, $8A, $CD, $DE
    DB      $A7, $3A, $44, $70, $FE, $09, $28, $05
    DB      $CD, $89, $A9, $18, $06, $AF, $CB, $CF
    DB      $32, $5E, $70, $3A, $92, $70, $B7, $28
    DB      $05, $CD, $C4, $A8, $18, $06, $CD, $60
    DB      $A8, $CD, $82, $A8, $CD, $0E, $A0, $3A
    DB      $82, $70, $FE, $05, $38, $2D, $3A, $44
    DB      $70, $FE, $09, $C8, $11, $00, $02, $2A
    DB      $68, $70, $01, $2C, $01, $A7, $ED, $42
    DB      $38, $13, $01, $78, $00, $A7, $ED, $42
    DB      $38, $0B, $EB, $01, $20, $00, $A7, $ED
    DB      $42, $EB, $D8, $18, $ED, $4B, $42, $CD
    DB      $59, $A3, $C9, $3A, $8B, $70, $FE, $01
    DB      $C2, $57, $A7, $3A, $44, $70, $FE, $09
    DB      $CA, $57, $A7, $C9, $3A, $80, $70, $3D
    DB      $32, $80, $70, $C0, $3E, $0E, $32, $80
    DB      $70, $3E, $01, $32, $7F, $70, $3A, $81
    DB      $70, $B7, $20, $35, $3E, $01, $32, $81
    DB      $70, $3E, $0B, $47, $CD, $F1, $1F, $3A
    DB      $3F, $70, $FE, $07, $20, $17, $01, $B6
    DB      $20, $11, $D7, $BC, $CD, $58, $A9, $3E
    DB      $BC, $32, $EC, $72, $3E, $0F, $32, $F1
    DB      $72, $32, $F5, $72, $C9, $3E, $00, $32
    DB      $ED, $72, $32, $F1, $72, $32, $F5, $72
    DB      $C9, $AF, $32, $81, $70, $3E, $0E, $47
    DB      $CD, $F1, $1F, $3A, $3F, $70, $FE, $07
    DB      $20, $16, $01, $B6, $20, $11, $11, $BD
    DB      $CD, $58, $A9, $3E, $C0, $32, $EC, $72
    DB      $AF, $32, $F1, $72, $32, $F5, $72, $C9
    DB      $3E, $0F, $32, $ED, $72, $3E, $0C, $32
    DB      $F1, $72, $32, $F5, $72, $C9, $3A, $92
    DB      $70, $B7, $C0, $3A, $82, $70, $B7, $C8
    DB      $FE, $05, $C8, $4F, $0D, $06, $00, $21
    DB      $30, $73, $CB, $21, $CB, $21, $09, $23
    DB      $7E, $0E, $32, $91, $32, $97, $70, $C9
    DB      $3A, $5E, $70, $B7, $C8, $3A, $97, $70
    DB      $32, $99, $70, $3A, $5E, $70, $CB, $5F
    DB      $28, $10, $3A, $82, $70, $B7, $C8, $3D
    DB      $32, $82, $70, $3E, $04, $32, $92, $70
    DB      $18, $0F, $CB, $4F, $C8, $3E, $01, $32
    DB      $92, $70, $3A, $82, $70, $3C, $32, $82
    DB      $70, $3E, $4D, $32, $97, $70, $3E, $06
    DB      $32, $93, $70, $3E, $01, $47, $CD, $F1
    DB      $1F, $C9, $3A, $92, $70, $FE, $04, $20
    DB      $04, $0E, $F8, $18, $06, $FE, $01, $20
    DB      $13, $0E, $08, $3A, $93, $70, $3D, $32
    DB      $93, $70, $28, $08, $3A, $98, $70, $81
    DB      $32, $98, $70, $C9, $AF, $32, $92, $70
    DB      $3A, $99, $70, $32, $97, $70, $3A, $82
    DB      $70, $B7, $C0, $21, $B1, $A6, $3A, $3F
    DB      $70, $D6, $07, $CB, $27, $4F, $06, $00
    DB      $09, $7E, $32, $97, $70, $C9, $01, $02
    DB      $01, $02, $43, $C8, $BC, $09, $3C, $A6
    DB      $F4, $0F, $3C, $B6, $F8, $0F, $48, $84
    DB      $70, $94, $98, $80, $C0, $8E, $90, $90
    DB      $90, $90, $90, $90, $94, $96, $92, $98
    DB      $92, $96, $92, $98, $94, $98, $01, $02
    DB      $02, $01, $43, $DB, $CC, $0F, $43, $D8
    DB      $C4, $0C, $43, $E8, $C8, $0C, $40, $88
    DB      $68, $94, $90, $90, $B8, $90, $94, $92
    DB      $92, $98, $94, $98, $96, $A0, $98, $9A
    DB      $9A, $9E, $98, $94, $9A, $9A

VDP_REG_A958:                               ; VDP_REG_A958 ($A958): write sprite attribute rows to VRAM; respects $707F write-enable flag
    PUSH    DE                              ; PUSH DE
    PUSH    BC                              ; PUSH BC
    POP     HL                              ; POP HL: HL = BC (VRAM address)
    DB      $EB
    LD      B, (HL)                         ; LD B,(HL): row count (outer loop)
    INC     HL
    LD      C, (HL)                         ; LD C,(HL): bytes per row
    INC     HL

LOC_A960:
    PUSH    BC
    PUSH    DE
    LD      B, $00
    LD      A, ($707F)                      ; A=$707F: VRAM write enable flag
    CP      $01                             ; CP $01
    JR      NZ, LOC_A97B                    ; JR NZ, LOC_A97B: flag clear -> LDIR (no VRAM write)
    PUSH    HL
    PUSH    BC                              ; CALL VDP_REG_BF8A: write BC bytes from HL to VRAM at DE
    CALL    VDP_REG_BF8A
    POP     BC
    POP     HL
    LD      A, C
    ADD     A, L
    LD      L, A
    LD      A, $00
    ADC     A, H
    LD      H, A
    JR      LOC_A97D

LOC_A97B:
    LDIR                                    ; LDIR: copy row directly in RAM (VRAM write disabled)

LOC_A97D:
    POP     DE
    DB      $EB
    LD      BC, $0020                       ; LD BC,$0020: advance VRAM pointer by 32 per row
    ADD     HL, BC                          ; ADD HL,BC: advance VRAM dest
    DB      $EB
    POP     BC
    DJNZ    LOC_A960                        ; DJNZ LOC_A960: repeat for all rows
    POP     DE
    RET     

SUB_A989:                                   ; SUB_A989 ($A989): decode player input: P1=$702D / P2=$7032; merge cols; store to $705E
    LD      A, ($7047)                      ; A=$7047: active player (1 or 2)
    CP      $01                             ; CP $01: player 1?
    JR      NZ, LOC_A996                    ; JR NZ, LOC_A996: no -> P2 input
    LD      IX, $702D                       ; LD IX,$702D: P1 BIOS POLLER controller output
    JR      LOC_A99A

LOC_A996:
    LD      IX, $7032                       ; LD IX,$7032: P2 BIOS POLLER controller output

LOC_A99A:
    LD      A, (IX+1)                       ; A=(IX+1); AND $0F: low nibble of column 1 (directions)
    AND     $0F
    OR      (IX+0)                          ; OR (IX+0): OR with column 0 bits
    LD      C, (IX+3)                       ; LD C,(IX+3): fire/jump button byte
    SLA     C                               ; SLA C: shift button bit to bit 1
    OR      C
    LD      ($705E), A                      ; LD ($705E),A: store merged joystick state
    EX      AF, AF'                         ; EX AF,AF: stash decoded input
    LD      A, ($703F)                      ; A=$703F: check game phase
    CP      $08                             ; CP $08: phase 8 (attract hi-score)?
    JR      Z, LOC_A9BA                     ; JR Z, LOC_A9BA: yes -> process fire/jump
    CP      $0A
    JR      Z, LOC_A9BA                     ; JR Z, LOC_A9BA: phase $0A -> process fire/jump
    CP      $06                             ; CP $06: phase < 6?
    RET     NC                              ; RET NC: phase >= 6 -> no movement input

LOC_A9BA:
    EX      AF, AF'                         ; EX AF,AF: restore decoded input
    AND     $C0                             ; AND $C0: extract fire ($80) / jump ($40) bits
    JR      Z, LOC_AA02                     ; JR Z, LOC_AA02: neither pressed -> set speed params
    AND     $80                             ; AND $80: fire button?
    JR      NZ, LOC_A9E8                    ; JR NZ, LOC_A9E8: fire -> go-up logic
    LD      A, ($7061)                  ; RAM $7061
    LD      C, A
    LD      A, ($7045)                      ; A=$7045: current lives
    CP      C                               ; CP C: lives at maximum?
    JR      NZ, LOC_A9E1                    ; JR NZ, LOC_A9E1: no -> set go-down flag
    LD      HL, $22F3
    DB      $EB
    LD      BC, $0001
    LD      HL, $737F                   ; RAM $737F
    PUSH    HL
    CALL    READ_VRAM
    POP     HL
    LD      A, (HL)
    CP      $F0
    JR      Z, LOC_AA02

LOC_A9E1:
    LD      A, $02                          ; A=$02; LD ($705F),A: set go-DOWN flag
    LD      ($705F), A                  ; RAM $705F
    JR      LOC_A9F7

LOC_A9E8:                                   ; LOC_A9E8: go-up logic
    LD      A, ($7062)                      ; A=$7062: max level
    LD      C, A
    LD      A, ($7045)                      ; A=$7045: current lives
    CP      C                               ; CP C: at max level?
    JR      Z, LOC_AA02                     ; JR Z, LOC_AA02: yes -> no change
    LD      A, $01                          ; A=$01; LD ($705F),A: set go-UP flag
    LD      ($705F), A                  ; RAM $705F

LOC_A9F7:
    LD      A, ($7060)                  ; RAM $7060
    OR      A
    JR      NZ, LOC_AA02
    LD      A, $06
    LD      ($7060), A                  ; RAM $7060

LOC_AA02:
    LD      A, ($703F)                  ; RAM $703F
    CP      $08
    JR      NC, LOC_AA2A
    LD      A, ($7045)                  ; RAM $7045
    LD      HL, $AA47
    LD      E, A
    LD      D, $00
    ADD     HL, DE
    ADD     HL, DE
    ADD     HL, DE
    ADD     HL, DE
    LD      A, (HL)
    LD      ($707C), A                  ; RAM $707C
    INC     HL
    LD      A, (HL)
    LD      ($707D), A                  ; RAM $707D
    INC     HL
    LD      A, (HL)
    LD      ($707B), A                  ; RAM $707B
    INC     HL
    LD      A, (HL)
    LD      ($7091), A                  ; RAM $7091
    RET     

LOC_AA2A:
    LD      HL, $AA67
    LD      A, ($7061)                  ; RAM $7061
    LD      E, A
    LD      A, ($7045)                  ; RAM $7045
    SUB     E
    LD      E, A
    LD      D, $00
    SLA     E
    RL      D
    ADD     HL, DE
    LD      A, (HL)
    LD      ($707D), A                  ; RAM $707D
    INC     HL
    LD      A, (HL)
    LD      ($7091), A                  ; RAM $7091
    RET     
    DB      $01, $02, $09, $48, $02, $02, $06, $27
    DB      $03, $02, $04, $1C, $02, $01, $08, $17
    DB      $03, $01, $06, $11, $04, $01, $06, $0E
    DB      $05, $01, $06, $0C, $06, $01, $04, $0B
    DB      $04, $14, $03, $14, $02, $10, $01, $08
    DB      $3A, $7D, $70, $47, $CD, $DC, $1F, $CB
    DB      $7F, $28, $F9, $C5, $CD, $F4, $1F, $CD
    DB      $61, $1F, $CD, $C2, $BF, $3A, $44, $70
    DB      $FE, $09, $20, $0E, $3A, $31, $70, $FE
    DB      $0F, $28, $07, $FE, $0A, $38, $03, $C3
    DB      $4A, $80, $C1, $10, $D7, $C9

SUB_AA9D:                                   ; SUB_AA9D ($AA9D): pixel-level bit collision check (rotate/AND VRAM tiles vs sprite)
    DEC     DE
    PUSH    DE
    LD      DE, $0008
    LD      B, C
    LD      C, $08
    LD      A, (HL)
    POP     HL
    INC     HL
    PUSH    HL
    PUSH    BC
    JP      (IX)
    DB      $17, $08, $A7, $ED, $52, $08, $CB, $16
    DB      $10, $F7, $18, $22, $17, $CB, $11, $17
    DB      $08, $A7, $ED, $52, $CB, $39, $CB, $16
    DB      $CB, $11, $08, $CB, $16, $10, $F1, $CB
    DB      $39, $18, $0B, $0F, $0F, $0F, $0F, $A7
    DB      $ED, $52, $ED, $6F, $10, $F9, $23, $C1
    DB      $0D, $20, $C6, $E1, $C9

DELAY_LOOP_AAE1:                            ; DELAY_LOOP_AAE1 ($AAE1): left-rotate scroll ring buffer; stride DE=$8 bytes per row
    DEC     HL                              ; DEC HL: HL points to last byte of row
    PUSH    HL
    DB      $EB                             ; DB $EB: EX DE,HL (swap: DE=end, HL=start)
    LD      DE, $0008                       ; LD DE,$0008: row stride
    AND     A                               ; AND A; SBC HL,DE: HL = start of row
    SBC     HL, DE
    LD      B, C                            ; LD B,C: row count
    LD      C, $08                          ; LD C,$08: 8 bytes per row

LOC_AAED:
    LD      A, (HL)
    POP     HL
    INC     HL
    PUSH    HL
    PUSH    BC

LOC_AAF2:
    LD      C, (HL)
    LD      (HL), A
    ADD     HL, DE
    LD      A, C
    DJNZ    LOC_AAF2
    AND     A
    SBC     HL, DE
    INC     HL
    POP     BC
    DEC     C
    JR      NZ, LOC_AAED
    POP     HL
    RET     

DELAY_LOOP_AB02:                            ; DELAY_LOOP_AB02 ($AB02): shift scroll column left: $71C6/$724C/$7266 ring buffers, DE=$0003
    LD      IX, $71C6                       ; LD IX,$71C6: foreground scroll tile buffer
    LD      IY, $724C                       ; LD IY,$724C: background scroll tile buffer
    LD      C, $00                          ; LD C,$00: nibble-parity flag (0=even)
    LD      DE, $0003                       ; LD DE,$0003: stride per column entry (3 bytes)
    CALL    SUB_AB62                        ; CALL SUB_AB62: extract low nibble IX[0] -> (IY+0)
    CALL    SUB_AB75                        ; CALL SUB_AB75: merge IX[0] hi + IX[1] lo -> (IY+0)
    LD      IY, $7266                       ; LD IY,$7266: hazard row scroll buffer
    CALL    SUB_AB75                        ; CALL SUB_AB75: merge IY[0] hi + IY[1] lo -> hazard row
    CALL    SUB_AB91                        ; CALL SUB_AB91: finalize and advance column ptrs
    LD      IY, $7252                   ; RAM $7252
    LD      B, $03

LOC_AB25:
    CALL    SUB_AB62
    CALL    SUB_AB75
    CALL    SUB_AB75
    CALL    SUB_AB91
    DJNZ    LOC_AB25
    RET     

SOUND_WRITE_AB34:                           ; SOUND_WRITE_AB34 ($AB34): level-clear: unpack $71C6 nibbles -> $7264/$725A scroll targets
    LD      IX, $71C6                       ; LD IX,$71C6: foreground tile buffer source
    LD      IY, $7264                       ; LD IY,$7264: level-clear scroll target 1
    LD      C, $01                          ; LD C,$01: high-nibble rotation flag
    LD      DE, $FFF3                       ; LD DE,$FFF3: stride = -13 (reverse scan)
    CALL    SUB_AB62
    CALL    SUB_AB75
    CALL    SUB_AB75
    CALL    SUB_AB91
    LD      IY, $725A                   ; RAM $725A
    LD      B, $03

LOC_AB53:
    CALL    SUB_AB62
    CALL    SUB_AB75
    CALL    SUB_AB75
    CALL    SUB_AB91
    DJNZ    LOC_AB53
    RET     

SUB_AB62:                                   ; SUB_AB62 ($AB62): extract low nibble of (IX+0); if C bit0 set, rotate to high nibble; -> (IY+0)
    LD      A, (IX+0)                       ; A=(IX+0): load source byte
    AND     $0F                             ; AND $0F: isolate low nibble
    BIT     0, C                            ; BIT 0,C: check rotation flag
    JR      Z, LOC_AB6F                     ; JR Z, LOC_AB6F: no rotation needed
    RLCA                                    ; RLCA: × 2
    RLCA                                    ; RLCA: × 4
    RLCA                                    ; RLCA: × 8
    RLCA                                    ; RLCA: × 16 (nibble rotated to high position)

LOC_AB6F:
    LD      (IY+0), A                       ; LD (IY+0),A: store nibble to output
    INC     IY                              ; INC IY
    RET     

SUB_AB75:                                   ; SUB_AB75 ($AB75): merge (IX+0) high nibble with (IX+1) low nibble; optional rotate; -> (IY+0)
    LD      A, (IX+0)                       ; A=(IX+0): load first source byte
    AND     $F0                             ; AND $F0: isolate high nibble
    LD      L, A                            ; LD L,A: save high nibble
    LD      A, (IX+1)                       ; A=(IX+1): load second source byte
    AND     $0F                             ; AND $0F: isolate low nibble
    OR      L                               ; OR L: combine high + low nibbles
    BIT     0, C                            ; BIT 0,C: check rotation flag
    JR      Z, LOC_AB89                     ; JR Z, LOC_AB89: no rotation
    RLCA                                    ; RLCA: rotate nibble pair to alternate position
    RLCA    
    RLCA    
    RLCA    

LOC_AB89:
    LD      (IY+0), A
    INC     IY
    INC     IX
    RET     

SUB_AB91:
    LD      A, (IX+0)
    AND     $F0
    OR      $0F
    BIT     0, C
    JR      Z, LOC_ABA0
    RLCA    
    RLCA    
    RLCA    
    RLCA    

LOC_ABA0:
    LD      (IY+0), A
    ADD     IY, DE
    PUSH    DE
    LD      DE, $0006
    ADD     IX, DE
    POP     DE
    RET     

SUB_ABAD:
    LD      HL, ($709D)                 ; RAM $709D
    LD      BC, $0800
    ADD     HL, BC
    LD      A, H
    AND     $18
    LD      H, A
    LD      ($709D), HL                 ; RAM $709D
    CP      $00
    RET     NZ

DELAY_LOOP_ABBE:                            ; DELAY_LOOP_ABBE ($ABBE): shift pixel scroll FIFO $70A7-$70C6 left one column ($7055 steps)
    LD      A, $01                          ; A=$01; LD ($706E),A: set "VRAM scroll column pending" flag
    LD      ($706E), A                  ; RAM $706E
    LD      A, ($7055)                      ; A=$7055: B.C. scroll X offset (pending steps)
    LD      B, A                            ; LD B,A: loop count = pending steps
    LD      HL, $70A7                       ; LD HL,$70A7: scroll FIFO ring buffer base

LOC_ABCA:
    PUSH    BC
    LD      BC, $001F                       ; LD BC,$001F: 31 bytes to shift
    LD      E, L
    LD      D, H
    DEC     DE
    LD      A, (DE)                         ; LD A,(DE): save first byte (will be overwritten)
    LDIR                                    ; LDIR: shift 31 bytes left (overwrite slot 0)
    LD      (DE), A                         ; LD (DE),A: wrap last byte to front
    INC     HL                              ; INC HL: advance base by 1
    POP     BC
    DJNZ    LOC_ABCA                        ; DJNZ LOC_ABCA: repeat for all pending steps
    RET     

SUB_ABDA:                                   ; SUB_ABDA ($ABDA): init SN76489A: SOUND_INIT with 3-channel silence table at $ABFE
    LD      HL, $ABFE                       ; LD HL,$ABFE: sound init data (3 channels, silence)
    LD      B, $03                          ; LD B,$03: 3 SN76489A channels
    CALL    SOUND_INIT                      ; CALL SOUND_INIT: BIOS sound init (volume 0, no tone)
    RET     

SUB_ABE3:                                   ; SUB_ABE3 ($ABE3): play two random PLAY_IT sounds from scroll-phase table
    LD      BC, $0008                       ; LD BC,$0008; LD DE,$000A: range for first random sound [$08..$11]
    LD      DE, $000A
    CALL    SUB_8FFF                        ; CALL SUB_8FFF: random value in [BC..BC+DE-1]
    LD      B, L                            ; LD B,L: B = random sound index (low byte)
    CALL    PLAY_IT                         ; CALL PLAY_IT: play first random sound
    LD      BC, $000B                       ; LD BC,$000B; LD DE,$000E: range for second random sound [$0B..$18]
    LD      DE, $000E
    CALL    SUB_8FFF                        ; CALL SUB_8FFF: random value in second range
    LD      B, L                            ; LD B,L: B = second random sound index
    CALL    PLAY_IT                         ; CALL PLAY_IT: play second random sound
    RET     
    DB      $64, $AC, $60, $73, $71, $AC, $60, $73
    DB      $7E, $AC, $74, $73, $83, $AC, $74, $73
    DB      $9D, $AC, $60, $73, $A5, $AC, $60, $73
    DB      $AD, $AC, $60, $73, $CC, $AC, $6A, $73
    DB      $D2, $AC, $6A, $73, $D7, $AC, $6A, $73
    DB      $DC, $AC, $74, $73, $E2, $AC, $74, $73
    DB      $E7, $AC, $74, $73, $EC, $AC, $74, $73
    DB      $89, $AC, $6A, $73, $8F, $AC, $6A, $73
    DB      $96, $AC, $6A, $73, $F2, $AC, $60, $73
    DB      $2A, $AD, $60, $73, $B5, $AC, $6A, $73
    DB      $BD, $AC, $6A, $73, $63, $AC, $74, $73
    DB      $5A, $AC, $74, $73, $40, $E0, $10, $04
    DB      $40, $BC, $10, $10, $10, $10, $40, $78
    DB      $51, $02, $43, $BC, $31, $05, $17, $B0
    DB      $57, $05, $10, $40, $78, $51, $02, $43
    DB      $BC, $30, $05, $17, $40, $57, $05, $10
    DB      $00, $00, $06, $08, $10, $02, $04, $1F
    DB      $1F, $10, $10, $02, $03, $23, $1F, $3F
    DB      $18, $02, $03, $23, $1F, $3F, $2D, $18
    DB      $02, $03, $23, $1F, $3F, $30, $18, $C1
    DB      $10, $00, $14, $11, $FF, $2B, $18, $C1
    DB      $10, $00, $14, $11, $FF, $37, $18, $C1
    DB      $10, $00, $14, $11, $FF, $3B, $18, $3F
    DB      $2F, $27, $02, $04, $1F, $1F, $10, $3F
    DB      $28, $81, $70, $00, $20, $10, $05, $3F
    DB      $02, $04, $1F, $1F, $10, $10, $00, $00
    DB      $66, $02, $22, $10, $00, $00, $64, $02
    DB      $10, $00, $00, $65, $02, $10, $80, $F0
    DB      $63, $02, $23, $10, $80, $84, $63, $02
    DB      $10, $80, $4E, $63, $02, $10, $80, $1C
    DB      $63, $02, $22, $10, $40, $78, $11, $02
    DB      $22, $40, $78, $11, $02, $22, $40, $78
    DB      $11, $02, $26, $40, $78, $11, $02, $22
    DB      $40, $78, $11, $02, $22, $40, $78, $11
    DB      $02, $26, $40, $78, $11, $02, $22, $40
    DB      $78, $11, $02, $22, $40, $1A, $11, $02
    DB      $26, $40, $FC, $10, $04, $24, $40, $E0
    DB      $10, $04, $24, $10, $40, $1A, $11, $04
    DB      $40, $E0, $10, $04, $40, $BC, $10, $10
    DB      $40, $BC, $10, $04, $40, $A6, $11, $04
    DB      $40, $E0, $10, $04, $40, $FC, $10, $04
    DB      $40, $1A, $11, $08, $24, $40, $E0, $10
    DB      $08, $24, $40, $1A, $11, $08, $10, $9F
    DB      $9F, $9F, $9F, $9F, $9F, $9F, $9F, $9F
    DB      $9F, $9F, $9F, $8C, $7F, $35, $7F, $35
    DB      $62, $35, $7F, $68, $7F, $68, $62, $68
    DB      $9F, $9F, $9F, $9F, $9F, $9F, $9F, $9F
    DB      $9F, $9F, $9F, $9F, $8C, $5C, $35, $44
    DB      $68, $58, $35, $48, $68, $54, $35, $4C ; "hX5HhT5L"
    DB      $68, $50, $35, $50, $68, $4C, $35, $54 ; "hP5PhL5T"
    DB      $68, $48, $35, $58, $68, $44, $35, $7F
    DB      $68, $7D, $68, $9F, $9F, $9F, $9F, $9F
    DB      $9F, $9F, $9F, $9F, $9F, $9F, $9F, $8C
    DB      $7F, $68, $7F, $68, $7F, $68, $7F, $68
    DB      $7F, $68, $45, $68, $9F, $9F, $9F, $9F
    DB      $9F, $9F, $9F, $9F, $9F, $9F, $9F, $9F
    DB      $8C, $44, $68, $5C, $35, $48, $68, $58
    DB      $35, $4C, $68, $54, $35, $50, $68, $50 ; "5LhT5PhP"
    DB      $35, $54, $68, $4C, $35, $58, $68, $48 ; "5ThL5XhH"
    DB      $35, $5C, $68, $44, $35, $7F, $68, $61
    DB      $68, $9F, $9F, $9F, $9F, $9F, $9F, $9F
    DB      $9F, $9F, $9F, $9F, $9F, $8C, $7F, $35
    DB      $7F, $35, $7F, $35, $7F, $35, $44, $35
    DB      $50, $68, $50, $35, $50, $68, $50, $35 ; "PhP5PhP5"
    DB      $7F, $68, $7F, $68, $7F, $68, $7F, $68
    DB      $7F, $68, $65, $68, $9F, $01, $00, $7F
    DB      $68, $7F, $68, $7F, $68, $7F, $68, $7F
    DB      $68, $45, $68, $9F, $9F, $9F, $9F, $9F
    DB      $9F, $9F, $9F, $9F, $9F, $9F, $9F, $8C
    DB      $7F, $35, $7F, $35, $0A, $35, $35, $70
    DB      $71, $72, $73, $74, $75, $62, $BB, $53
    DB      $35, $4C, $68, $15, $A9, $A8, $A9, $A8
    DB      $A9, $A8, $A9, $A8, $A9, $A8, $A9, $A8
    DB      $A9, $A8, $A9, $A8, $A9, $A8, $A9, $A8
    DB      $A9, $4B, $68, $55, $AA, $4B, $68, $55
    DB      $AA, $4B, $68, $55, $AA, $4B, $68, $55
    DB      $AA, $44, $68, $9F, $9F, $9F, $9F, $9F
    DB      $9F, $9F, $9F, $9F, $9F, $9F, $9F, $8C
    DB      $7F, $35, $7F, $35, $7F, $35, $63, $35
    DB      $7F, $68, $61, $68, $7F, $FE, $7F, $FE
    DB      $7F, $FE, $7F, $FE, $7F, $FE, $45, $FE
    DB      $7F, $35, $7F, $35, $7F, $35, $7F, $35
    DB      $7F, $35, $45, $35, $7F, $FE, $91, $0F
    DB      $03, $03, $0F, $1F, $3F, $3F, $7F, $00
    DB      $80, $C0, $E0, $F0, $F8, $FC, $FE, $8C
    DB      $0C, $01, $01, $01, $03, $80, $80, $E0
    DB      $F8, $F8, $FC, $FE, $FE, $8F, $01, $0F
    DB      $85, $03, $0F, $FF, $FF, $85, $03, $80
    DB      $F0, $FF, $87, $01, $07, $86, $02, $1C
    DB      $FF, $87, $01, $F0, $8E, $07, $0F, $FF
    DB      $01, $03, $07, $0F, $3F, $B3, $08, $00
    DB      $80, $C0, $E0, $F0, $F8, $FC, $FE, $8F
    DB      $01, $0F, $87, $01, $F0, $88, $08, $03
    DB      $03, $07, $0F, $0F, $1F, $3F, $7F, $A8
    DB      $05, $00, $C0, $E0, $F0, $FC, $A3, $86
    DB      $02, $C0, $F0, $88, $A6, $08, $FE, $F9
    DB      $F0, $FD, $FB, $F7, $CF, $3F, $AA, $03
    DB      $80, $E0, $F8, $A5, $08, $00, $03, $0F
    DB      $3F, $CF, $F3, $FD, $FE, $A8, $02, $03
    DB      $1F, $AE, $09, $F0, $FD, $FB, $F7, $CF
    DB      $3F, $FF, $FF, $FC, $A7, $04, $00, $00
    DB      $C0, $F8, $A4, $83, $01, $0F, $A4, $02
    DB      $00, $0F, $A6, $03, $00, $00, $E0, $A5
    DB      $08, $00, $03, $0F, $3F, $CF, $F3, $FD
    DB      $FE, $A8, $03, $80, $E0, $F8, $A5, $09
    DB      $00, $01, $01, $83, $F7, $EF, $9F, $7F
    DB      $FC, $A7, $88, $04, $07, $1F, $7F, $FF
    DB      $84, $A4, $84, $A4, $85, $03, $C0, $F0
    DB      $FE, $98, $A4, $8A, $09, $03, $0F, $1F
    DB      $3F, $3F, $7F, $1C, $3E, $7F, $A5, $03
    DB      $00, $18, $7C, $A5, $08, $00, $00, $C0
    DB      $E0, $F0, $F8, $FC, $FC, $90, $05, $3F
    DB      $1F, $1F, $07, $03, $83, $A3, $02, $7E
    DB      $1C, $83, $A4, $09, $FE, $7C, $38, $00
    DB      $F8, $F8, $F0, $E0, $C0, $8B, $04, $02
    DB      $04, $07, $04, $84, $04, $10, $20, $F8
    DB      $0F, $84, $0E, $40, $80, $88, $0C, $1F
    DB      $0F, $01, $00, $C3, $C3, $C3, $81, $81
    DB      $81, $84, $03, $08, $45, $54, $A3, $08
    DB      $00, $08, $12, $55, $F8, $FC, $F8, $F0
    DB      $8A, $06, $08, $04, $02, $07, $03, $03
    DB      $83, $02, $14, $92, $A3, $18, $7F, $3E
    DB      $3E, $3C, $3C, $38, $18, $08, $00, $04
    DB      $00, $12, $40, $10, $22, $80, $12, $00
    DB      $44, $10, $02, $28, $00, $44, $A8, $08
    DB      $F0, $F0, $F8, $F8, $F0, $F0, $E0, $E0
    DB      $88, $08, $07, $07, $03, $03, $07, $07
    DB      $07, $0F, $A8, $08, $E0, $E0, $E0, $F0
    DB      $F0, $F0, $E0, $E0, $88, $08, $0F, $0F
    DB      $0F, $07, $07, $07, $03, $03, $A8, $08
    DB      $F0, $F8, $F8, $FC, $FE, $FE, $FF, $FF
    DB      $88, $07, $03, $03, $07, $07, $1F, $1F
    DB      $3F, $A9, $10, $00, $00, $08, $18, $1C
    DB      $3C, $7E, $FF, $FF, $7F, $3F, $1F, $0F
    DB      $07, $03, $01, $8E, $02, $22, $9F, $84
    DB      $09, $24, $92, $4F, $FF, $00, $00, $49
    DB      $24, $A7, $A3, $03, $01, $4D, $27, $A5
    DB      $03, $80, $B2, $E4, $A5, $05, $00, $80
    DB      $12, $24, $E5, $A3, $83, $05

; ============================================================
; GAME DATA  ($B054 - $BBFF)
; Animation, sprite, level, and name-table data.
; (Tracer did not reach this area via static flow; kept as DB.)
; ============================================================
GAME_DATA:                                  ; GAME_DATA ($B054): level, animation, sprite, and name-table ROM tables ($B054-$BBFF)
    DB      $24, $49, $F2, $FF, $FF, $86, $02, $44
    DB      $F9, $A8, $10, $80, $C0, $F8, $F0, $F0
    DB      $F0, $E0, $E0, $10, $22, $25, $F8, $F8
    DB      $E0, $C0, $80, $83, $08, $0F, $7F, $FF
    DB      $7F, $1F, $00, $00, $E0, $A5, $84, $19
    DB      $80, $E0, $FC, $FF, $0F, $07, $07, $03
    DB      $03, $01, $01, $01, $80, $C0, $E0, $F0
    DB      $F8, $FC, $FE, $FF, $00, $00, $08, $45
    DB      $54, $A3, $83, $02, $14, $92, $A3, $05
    DB      $00, $00, $04, $82, $4F, $A3, $04, $00
    DB      $10, $08, $48, $A4, $05, $00, $00, $10
    DB      $8A, $C9, $A3, $08, $00, $00, $40, $22
    DB      $21, $FD, $FF, $FF, $83, $05, $02, $21
    DB      $15, $FF, $FF, $83, $15, $04, $12, $4F
    DB      $FF, $FF, $02, $06, $0E, $1F, $3C, $38
    DB      $70, $60, $80, $90, $20, $24, $5E, $4A
    DB      $5B, $F5, $44, $60, $14, $64, $E0, $75
    DB      $EB, $01, $00, $06, $81, $06, $8B, $65
    DB      $BB, $00, $30, $48, $00, $B0, $4E, $BD
    DB      $5F, $85, $03, $40, $69, $F6, $98, $0C
    DB      $1F, $9F, $CF, $E7, $F3, $F3, $F9, $F8
    DB      $FC, $FC, $FE, $FE, $A5, $1F, $7F, $3F
    DB      $1F, $0F, $0F, $87, $83, $C1, $E0, $F0
    DB      $F0, $F8, $F8, $FC, $FE, $3C, $39, $33
    DB      $27, $0F, $1F, $3F, $7F, $F0, $C0, $81
    DB      $03, $0F, $1F, $3F, $7F, $A5, $09, $FE
    DB      $FC, $F8, $01, $03, $0F, $1F, $3F, $7F
    DB      $A6, $04, $FE, $FC, $F8, $F0, $A5, $03
    DB      $3F, $07, $03, $A9, $34, $7F, $1F, $0F
    DB      $0F, $07, $03, $01, $FF, $FE, $FE, $FC
    DB      $F8, $E0, $C0, $80, $80, $E0, $F8, $FC
    DB      $FE, $FE, $FF, $FF, $01, $07, $0F, $3F
    DB      $3F, $7F, $7F, $FF, $FF, $3F, $1F, $0F
    DB      $07, $07, $03, $01, $FF, $FE, $F8, $F0
    DB      $F0, $E0, $80, $00, $7E, $7E, $7E, $3E
    DB      $3E, $46, $3C, $19, $1C, $1C, $18, $08
    DB      $08, $FF, $7E, $3C, $1C, $18, $08, $00
    DB      $00, $FF, $1F, $07, $03, $03, $01, $01
    DB      $00, $FF, $E0, $C0, $C0, $44, $80, $02
    DB      $F9, $30, $86, $10, $01, $03, $07, $0F
    DB      $1F, $7F, $FF, $FF, $80, $C0, $C0, $E0
    DB      $F8, $FC, $FE, $FF, $94, $14, $08, $18
    DB      $3C, $7F, $01, $01, $01, $03, $03, $07
    DB      $1F, $FF, $00, $80, $80, $C0, $C0, $E0
    DB      $F8, $FF, $86, $3F, $1C, $FE, $28, $30
    DB      $44, $20, $60, $80, $50, $80, $08, $20
    DB      $00, $A0, $00, $10, $80, $00, $40, $80
    DB      $A0, $00, $84, $80, $C0, $A0, $90, $C0
    DB      $40, $E2, $48, $60, $B0, $64, $50, $60
    DB      $A0, $60, $B0, $71, $54, $FA, $68, $F4
    DB      $79, $3C, $3A, $1C, $0E, $47, $02, $00
    DB      $00, $04, $20, $01, $0C, $37, $20, $00
    DB      $10, $40, $10, $03, $00, $30, $58, $A5
    DB      $03, $7E, $18, $00, $A3, $02, $E7, $C3
    DB      $9F, $94, $19, $1E, $0F, $07, $03, $01
    DB      $3C, $7F, $FF, $00, $00, $80, $C0, $E0
    DB      $E3, $F7, $F7, $E0, $F0, $78, $3C, $1C
    DB      $CE, $FE, $FF, $03, $86, $13, $01, $80
    DB      $00, $02, $04, $02, $00, $00, $02, $10
    DB      $08, $08, $10, $10, $60, $00, $00, $02
    DB      $0C, $85, $04, $0C, $04, $08, $06, $85
    DB      $38, $06, $3F, $7B, $7F, $FF, $FE, $FF
    DB      $7F, $C0, $F0, $F0, $FC, $FC, $FE, $FE
    DB      $FE, $F7, $FF, $BF, $7F, $1B, $06, $03
    DB      $00, $DC, $FE, $FA, $EC, $F8, $E0, $80
    DB      $00, $10, $22, $25, $F8, $F8, $E0, $C0
    DB      $80, $0F, $07, $07, $03, $03, $01, $01
    DB      $01, $80, $C0, $E0, $F0, $F8, $FC, $FE
    DB      $FF, $84, $04, $F0, $F8, $FC, $FE, $83
    DB      $12, $0E, $1F, $3F, $7F, $FE, $03, $03
    DB      $07, $0F, $0F, $1E, $3C, $78, $FE, $F8
    DB      $F0, $E0, $80, $84, $04, $01, $03, $07
    DB      $06, $88, $12, $01, $1F, $FF, $07, $1F
    DB      $3F, $7F, $FF, $FF, $7F, $3F, $FF, $FE
    DB      $FC, $F8, $F0, $E0, $C0, $89, $08, $80
    DB      $C0, $20, $80, $4F, $5F, $3F, $FF, $84
    DB      $14, $80, $C0, $E0, $F0, $08, $08, $08
    DB      $1C, $1F, $1F, $1F, $0E, $00, $03, $0F
    DB      $1F, $FF, $FF, $7F, $3E, $A5, $03, $7F
    DB      $7F, $FC, $46, $F8, $0B, $C0, $00, $25
    DB      $12, $09, $04, $43, $99, $20, $E0, $0F
    DB      $83, $04, $1F, $1F, $1F, $0E, $A6, $02
    DB      $7F, $3E, $85, $03, $01, $00, $01, $85
    DB      $17, $F0, $28, $58, $06, $01, $00, $04
    DB      $08, $08, $07, $10, $01, $03, $07, $07
    DB      $0F, $0F, $1F, $1F, $E0, $F8, $FC, $FE
    DB      $A4, $05, $3F, $3F, $3F, $7F, $7F, $A3
    DB      $18, $20, $10, $10, $00, $48, $88, $08
    DB      $00, $F8, $F0, $F0, $70, $38, $38, $1C
    DB      $1E, $1E, $3C, $78, $F0, $E0, $C0, $80
    DB      $80, $83, $1D, $01, $03, $07, $0F, $1F
    DB      $3E, $7C, $F8, $F1, $E1, $C3, $83, $03
    DB      $FC, $F8, $F8, $F0, $F0, $E0, $C0, $C0
    DB      $00, $00, $03, $0F, $FF, $F8, $F0, $E0
    DB      $90, $18, $F7, $FD, $DF, $F5, $DF, $FF
    DB      $AF, $FF, $80, $80, $C0, $E0, $E0, $F0
    DB      $F0, $FE, $01, $03, $07, $07, $0F, $1F
    DB      $3F, $3F, $A8, $17, $01, $03, $07, $0F
    DB      $0F, $1F, $3F, $FF, $80, $80, $80, $C0
    DB      $C0, $E0, $FC, $FE, $FB, $BF, $FD, $EF
    DB      $7F, $F7, $DD, $A6, $0D, $EF, $BD, $FF
    DB      $00, $42, $42, $7E, $42, $42, $42, $00
    DB      $00, $7C, $44, $10, $0C, $7C, $00, $00
    DB      $42, $24, $18, $18, $24, $42, $00, $00
    DB      $3C, $44, $42, $2C, $3C, $00, $00, $3C
    DB      $42, $40, $4E, $42, $3C, $00, $00, $7C
    DB      $42, $42, $7C, $44, $42, $00, $00, $7E
    DB      $40, $78, $40, $40, $7E, $00, $00, $3C
    DB      $40, $3C, $02, $02, $7C, $00, $00, $3C
    DB      $46, $4A, $52, $62, $3C, $00, $00, $18
    DB      $45, $08, $3F, $00, $00, $3C, $02, $02
    DB      $1C, $20, $3E, $00, $00, $3C, $02, $1C
    DB      $02, $02, $3C, $00, $00, $04, $0C, $14
    DB      $24, $3E, $04, $00, $00, $3E, $20, $1C
    DB      $02, $02, $3C, $00, $00, $0E, $10, $1C
    DB      $22, $22, $1C, $00, $00, $3C, $02, $0C
    DB      $10, $10, $10, $00, $00, $3C, $42, $3C
    DB      $42, $42, $3C, $00, $00, $1C, $22, $22
    DB      $1C, $04, $21, $38, $00, $00, $42, $42
    DB      $24, $24, $24, $18, $00, $00, $1E, $20
    DB      $40, $40, $20, $1E, $00, $00, $7C, $42
    DB      $42, $7C, $40, $40, $00, $00, $78, $44
    DB      $42, $42, $42, $7C, $89, $05, $F7, $E7
    DB      $E7, $E7, $C7, $43, $C3, $9A, $06, $08
    DB      $1F, $27, $1F, $1F, $1D, $87, $09, $80
    DB      $C0, $63, $BF, $FF, $F7, $78, $8E, $03
    DB      $89, $10, $C0, $F0, $F0, $F0, $E0, $00
    DB      $80, $00, $1C, $1F, $1F, $0F, $30, $40
    DB      $31, $0F, $88, $12, $03, $1C, $E0, $01
    DB      $0E, $30, $C0, $E0, $F0, $FC, $7F, $1F
    DB      $07, $01, $00, $00, $01, $1F, $A9, $0D
    DB      $FE, $FE, $FE, $FC, $3B, $FC, $FF, $F8
    DB      $F0, $C0, $C0, $80, $80, $8B, $0C, $3E
    DB      $01, $3E, $00, $39, $0E, $C2, $3C, $00
    DB      $04, $04, $C8, $85, $0A, $80, $60, $00
    DB      $80, $08, $04, $20, $40, $38, $07, $86
    DB      $01, $03, $83, $03, $0F, $7F, $0E, $88
    DB      $04, $0F, $FF, $FF, $1F, $A3, $16, $3F
    DB      $1F, $0F, $03, $00, $30, $C1, $1A, $62
    DB      $84, $04, $08, $10, $10, $20, $60, $E0
    DB      $F8, $FC, $FE, $7F, $80, $96, $0B, $01
    DB      $03, $07, $1F, $3C, $F9, $3F, $03, $00
    DB      $76, $7E, $44, $3B, $0A, $7B, $E7, $DE
    DB      $BC, $38, $10, $C0, $E0, $F0, $70, $85
    DB      $04, $0C, $1C, $3C, $18, $84, $02, $73
    DB      $1F, $83, $2B, $40, $30, $18, $1C, $0C
    DB      $0C, $0C, $18, $38, $70, $E0, $C0, $00
    DB      $00, $03, $0F, $3F, $3F, $7F, $7E, $FC
    DB      $F8, $FC, $7F, $7F, $3F, $1F, $03, $00
    DB      $00, $C0, $E0, $F0, $F8, $FC, $7C, $7E
    DB      $7E, $FE, $FC, $F8, $F0, $E0, $86, $0D
    DB      $1C, $63, $08, $7C, $02, $35, $5A, $02
    DB      $64, $98, $04, $04, $C8, $85, $3D, $80
    DB      $60, $00, $80, $08, $04, $20, $40, $38
    DB      $07, $00, $00, $02, $19, $25, $48, $10
    DB      $02, $20, $43, $04, $03, $00, $44, $43
    DB      $50, $50, $00, $1C, $62, $20, $08, $02
    DB      $22, $00, $E0, $10, $E2, $00, $14, $E4
    DB      $04, $04, $10, $14, $02, $0E, $32, $C2
    DB      $1A, $62, $84, $04, $08, $10, $10, $20
    DB      $60, $E0, $10, $10, $92, $04, $0F, $1F
    DB      $3F, $3F, $44, $7F, $04, $1F, $1F, $0F
    DB      $0F, $84, $10, $E0, $F0, $F0, $F8, $F8
    DB      $FC, $FC, $FC, $F8, $F8, $F0, $F0, $07
    DB      $07, $1F, $7F, $A8, $05, $FE, $FE, $FE
    DB      $FC, $C0, $48, $80, $88, $1F, $02, $19
    DB      $25, $48, $10, $03, $20, $43, $04, $03
    DB      $00, $47, $48, $40, $50, $00, $1C, $22
    DB      $60, $0A, $02, $62, $00, $E0, $10, $E0
    DB      $00, $F0, $0A, $02, $02, $84, $0C, $20
    DB      $FE, $9F, $7D, $7E, $77, $EF, $F1, $FE
    DB      $F8, $E0, $E0, $87, $06, $BE, $FF, $FF
    DB      $DE, $E0, $38, $84, $1B, $0E, $01, $1F
    DB      $00, $23, $1C, $06, $42, $31, $0E, $00
    DB      $00, $04, $02, $02, $00, $00, $80, $60
    DB      $00, $80, $08, $04, $20, $40, $38, $07
    DB      $84, $1C, $07, $08, $01, $0F, $10, $05
    DB      $1A, $22, $06, $3E, $40, $00, $00, $04
    DB      $02, $02, $80, $40, $80, $60, $00, $80
    DB      $08, $04, $20, $40, $38, $07, $8C, $08
    DB      $01, $03, $0F, $1F, $3F, $7F, $FF, $FF
    DB      $86, $44, $F0, $01, $E0, $45, $C0, $04
    DB      $07, $0F, $1F, $7F, $A3, $09, $7F, $07
    DB      $07, $0E, $0E, $1C, $38, $70, $E0, $AA
    DB      $86, $05, $04, $04, $04, $08, $08, $44
    DB      $11, $0C, $23, $23, $C7, $C7, $8F, $8F
    DB      $9F, $40, $40, $80, $80, $80, $85, $06
    DB      $80, $80, $C8, $FC, $FE, $FF, $46, $0E
    DB      $18, $0C, $1C, $1C, $38, $38, $38, $77
    DB      $7F, $78, $60, $F0, $F0, $78, $38, $38
    DB      $78, $70, $F0, $E0, $60, $20, $07, $F8
    DB      $80, $86, $0D, $30, $F0, $F8, $7F, $3F
    DB      $1F, $07, $03, $04, $18, $31, $0E, $11
    DB      $44, $22, $37, $46, $47, $8F, $8F, $1F
    DB      $1F, $3F, $40, $80, $00, $00, $FF, $7F
    DB      $7F, $3F, $1F, $1F, $3F, $1F, $1F, $1F
    DB      $0F, $0F, $07, $07, $03, $00, $FF, $FF
    DB      $FE, $FE, $FC, $FC, $FE, $FE, $FC, $F8
    DB      $FC, $F8, $F0, $E0, $00, $00, $07, $0F
    DB      $1F, $3B, $37, $6F, $5F, $DF, $CF, $73
    DB      $1C, $03, $84, $07, $80, $E0, $F0, $F8
    DB      $FC, $FE, $FE, $A3, $02, $7C, $E0, $84
    DB      $13, $0F, $1E, $1D, $1B, $37, $37, $3F
    DB      $7F, $7F, $3F, $1F, $0F, $03, $01, $00
    DB      $00, $C0, $70, $F8, $45, $FC, $06, $FE
    DB      $FF, $FF, $FE, $FE, $FC, $83, $13, $03
    DB      $07, $0F, $1F, $1F, $3F, $7F, $5F, $5F
    DB      $6F, $77, $79, $7F, $3E, $0C, $00, $00
    DB      $E0, $FC, $46, $FE, $0C, $FC, $FC, $F8
    DB      $F0, $00, $00, $1F, $3F, $3F, $7F, $7F
    DB      $3F, $45, $1F, $13, $0F, $07, $01, $00
    DB      $00, $C0, $E0, $F8, $FC, $FE, $FF, $FF
    DB      $FE, $F6, $F6, $EC, $DC, $3C, $F8, $85
    DB      $04, $0F, $1F, $3F, $3F, $46, $7F, $13
    DB      $3F, $07, $00, $00, $30, $7C, $FE, $3E
    DB      $DE, $EE, $F6, $F6, $FE, $FC, $F8, $F8
    DB      $F0, $E0, $C0, $83, $08, $80, $E0, $70
    DB      $10, $68, $18, $2C, $0C, $86, $0A, $10
    DB      $F8, $E8, $00, $08, $30, $70, $80, $E0
    DB      $38, $8C, $0D, $C0, $E0, $38, $9C, $F8
    DB      $48, $18, $30, $00, $00, $10, $F8, $E8
    DB      $83, $07, $18, $70, $C0, $F0, $98, $C0
    DB      $40, $89, $0D, $40, $68, $3C, $FC, $98
    DB      $30, $60, $C0, $80, $00, $10, $F8, $E8
    DB      $84, $1C, $40, $80, $F0, $D8, $40, $60
    DB      $20, $00, $00, $03, $04, $01, $02, $00
    DB      $C0, $70, $18, $FE, $9F, $3F, $7F, $9F
    DB      $0F, $07, $40, $40, $F8, $E0, $4A, $C0
    DB      $02, $80, $00, $48, $06, $05, $1E, $06
    DB      $0C, $18, $10, $93, $0A, $40, $01, $10
    DB      $09, $0C, $4A, $28, $9C, $5D, $7F, $A4
    DB      $83, $08, $04, $45, $08, $90, $08, $44
    DB      $A4, $B6, $A5, $83, $09, $02, $00, $94
    DB      $05, $49, $33, $37, $3F, $7F, $A4, $83
    DB      $08, $21, $00, $82, $2A, $18, $9C, $7C
    DB      $B2, $A5, $83, $09, $02, $00, $95, $24
    DB      $48, $22, $30, $3D, $7F, $A5, $0A, $00
    DB      $00, $21, $08, $02, $2A, $60, $14, $6C
    DB      $B2, $A6, $0A, $00, $00, $A0, $02, $28
    DB      $04, $04, $2B, $E8, $6D, $A6, $0C, $00
    DB      $00, $A1, $08, $AA, $00, $61, $14, $6C
    DB      $B2, $FF, $AF, $A4, $01, $00, $BF, $0A
    DB      $FF, $3C, $6F, $FF, $EF, $F7, $7C, $3F
    DB      $0F, $03, $89, $0A, $C0, $F8, $FE, $F9
    DB      $F7, $6F, $EF, $FF, $6E, $1E, $8B, $05
    DB      $07, $07, $0F, $1F, $7F, $A4, $05, $60
    DB      $F0, $F8, $7C, $7C, $49, $FC, $12, $F0
    DB      $C0, $00, $00, $07, $00, $00, $07, $00
    DB      $0F, $00, $01, $09, $04, $32, $C2, $1A
    DB      $62, $85, $08, $80, $20, $00, $10, $C0
    DB      $10, $10, $50, $90, $03, $31, $00, $20
    DB      $87, $08, $1C, $3E, $3F, $7F, $7F, $FE
    DB      $BE, $88, $84, $04, $20, $20, $60, $E0
    DB      $44, $F1, $05, $B1, $31, $11, $08, $01
    DB      $84, $14, $30, $70, $F8, $F8, $FC, $FC
    DB      $FE, $EF, $BF, $F7, $A1, $04, $09, $0B
    DB      $0E, $7C, $0E, $13, $31, $20, $90, $05
    DB      $24, $18, $78, $14, $20, $88, $11, $10
    DB      $54, $38, $18, $24, $40, $00, $03, $00
    DB      $01, $02, $20, $14, $78, $10, $28, $40
    DB      $84, $33, $40, $40, $70, $C0, $40, $20
    DB      $00, $00, $03, $02, $01, $7E, $FF, $FB
    DB      $77, $07, $00, $0F, $07, $07, $07, $03
    DB      $01, $03, $D7, $A7, $DF, $EF, $EE, $FE
    DB      $B6, $76, $F7, $FF, $FF, $FC, $F0, $E0
    DB      $00, $00, $03, $02, $01, $7E, $FF, $FB
    DB      $77, $07, $00, $0F, $00, $A3, $0F, $00
    DB      $00, $D0, $A0, $D8, $EC, $F6, $FB, $BC
    DB      $66, $DF, $1F, $FF, $FC, $E0, $83, $05
    DB      $01, $07, $0F, $1F, $3F, $44, $7F, $07
    DB      $3F, $1F, $0F, $07, $00, $42, $E7, $AE
    DB      $06, $00, $00, $F8, $FF, $FF, $FB, $44
    DB      $FD, $05, $FB, $FB, $F0, $E0, $C0, $85
    DB      $04, $80, $C0, $E0, $F0, $A4, $07, $7F
    DB      $3F, $07, $03, $00, $10, $10, $85, $0B
    DB      $80, $C5, $ED, $00, $6D, $2D, $0D, $00
    DB      $00, $08, $08, $85, $0C, $01, $A3, $B7
    DB      $00, $B6, $B4, $B0, $00, $07, $0D, $1F
    DB      $37, $46, $3F, $15, $7F, $7F, $FF, $7F
    DB      $03, $00, $E0, $F0, $78, $FC, $F0, $EE
    DB      $D5, $DF, $D1, $EE, $FE, $FC, $FB, $FE
    DB      $C0, $86, $0B, $01, $03, $FF, $7C, $3F
    DB      $1F, $0F, $1F, $3F, $FF, $7E, $84, $0C
    DB      $80, $E0, $E0, $F0, $7C, $F8, $E0, $C0
    DB      $C0, $F0, $F8, $E0, $88, $05, $0D, $3B
    DB      $F8, $FB, $1D, $83, $20, $1D, $03, $0F
    DB      $0F, $0F, $1F, $3F, $F3, $EF, $DF, $07
    DB      $F0, $FF, $FF, $07, $00, $C0, $C0, $C0
    DB      $E0, $F0, $F0, $F8, $F8, $B0, $70, $70
    DB      $F0, $E0, $E0, $C0, $C0, $93, $0D, $C0
    DB      $F3, $3F, $1F, $0F, $03, $07, $1D, $3B
    DB      $3D, $0F, $07, $1D, $84, $18, $F0, $FC
    DB      $FE, $FE, $EE, $F4, $F4, $EC, $EC, $9C
    DB      $F8, $F8, $3B, $37, $39, $1F, $0F, $0F
    DB      $07, $07, $0F, $0F, $07, $03, $84, $0C
    DB      $F0, $F0, $E0, $00, $80, $C0, $80, $80
    DB      $C0, $C0, $80, $C0, $84, $0D, $0E, $1F
    DB      $3F, $7B, $77, $6F, $6F, $77, $3B, $1D
    DB      $0F, $03, $01, $83, $3F, $1C, $7E, $BE
    DB      $F7, $FB, $F7, $FF, $FE, $FC, $F8, $F0
    DB      $E0, $C0, $C0, $40, $00, $03, $1F, $3F
    DB      $7F, $7D, $ED, $E9, $E5, $ED, $ED, $6F
    DB      $7F, $3F, $0F, $00, $00, $FF, $FF, $F7
    DB      $17, $77, $77, $11, $7F, $1D, $FD, $FC
    DB      $FD, $FD, $FF, $FF, $00, $FF, $1B, $5B
    DB      $5B, $1F, $7B, $7F, $E2, $AE, $A2, $2E
    DB      $A2, $BF, $FF, $F0, $2E, $00, $F0, $FC
    DB      $FE, $FE, $8B, $AB, $8B, $BF, $BA, $BE
    DB      $F8, $3C, $FE, $1E, $07, $01, $03, $1D
    DB      $3D, $7D, $FD, $ED, $F3, $FF, $CD, $BD
    DB      $CD, $F5, $CE, $7F, $0F, $03, $FF, $6B
    DB      $69, $6A, $6B, $6B, $9B, $FF, $B2, $AE
    DB      $AE, $AE, $72, $A4, $1E, $A3, $2B, $AB
    DB      $A3, $AF, $AF, $FF, $D1, $B7, $71, $B7
    DB      $D1, $FF, $FE, $F0, $F0, $BC, $BE, $BE
    DB      $BF, $FF, $BF, $FF, $1F, $5E, $3E, $5C
    DB      $6C, $DC, $06, $01, $01, $02, $20, $FE
    DB      $FE, $FE, $FE, $EA, $F5, $FE, $FE, $FC
    DB      $F2, $EF, $FB, $EB, $ED, $EE, $FE, $EF
    DB      $FC, $EE, $EE, $FD, $FE, $FE, $FC, $F1
    DB      $EF, $FB, $EB, $ED, $EE, $FE, $FE, $FE
    DB      $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE
    DB      $F0, $F0, $F0, $F0, $F0, $FE, $FE, $FE
    DB      $FE, $F1, $F0, $FE, $FE, $FE, $FE, $F0
    DB      $F0, $F0, $F0, $F0, $FE, $FE, $FE, $02
    DB      $05, $68, $78, $68, $68, $68, $79, $7A
    DB      $7B, $7C, $7D, $01, $08, $70, $71, $72
    DB      $73, $74, $75, $76, $77, $04, $20, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $01, $02, $03, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $04, $05, $06
    DB      $00, $00, $00, $00, $00, $00, $00, $08
    DB      $09, $0A, $0B, $0C, $0D, $00, $0E, $0F
    DB      $10, $11, $12, $13, $00, $14, $15, $16
    DB      $00, $00, $00, $0C, $0D, $17, $18, $19
    DB      $1A, $1B, $00, $00, $00, $00, $00, $11
    DB      $11, $11, $11, $11, $1D, $1E, $11, $11
    DB      $11, $11, $11, $1F, $20, $21, $11, $26
    DB      $27, $28, $23, $11, $1D, $25, $11, $11
    DB      $11, $26, $27, $28, $29, $2A, $2B, $34
    DB      $35, $35, $35, $30, $31, $32, $32, $32 ; "55501222"
    DB      $32, $32, $32, $32, $32, $33, $34, $35 ; "22222345"
    DB      $35, $35, $35, $30, $31, $32, $32, $32 ; "55501222"
    DB      $32, $32, $32, $32, $32, $32, $33, $02
    DB      $04, $60, $61, $62, $63, $69, $68, $68
    DB      $68, $02, $04, $64, $65, $66, $67, $68
    DB      $68, $68, $69, $01, $10, $1F, $20, $21
    DB      $19, $1A, $1B, $0E, $0F, $10, $1F, $2D
    DB      $2E, $26, $27, $28, $23, $02, $05, $38
    DB      $39, $3A, $3B, $3C, $3E, $3F, $40, $41 ; "9:;<>?@A"
    DB      $42, $02, $05, $35, $35, $60, $62, $6A
    DB      $62, $63, $68, $68, $35, $09, $06, $35
    DB      $6B, $6C, $6D, $35, $35, $35, $6E, $68 ; "klm555nh"
    DB      $68, $6F, $35, $35, $35, $68, $68, $68 ; "ho555hhh"
    DB      $6F, $35, $35, $68, $68, $68, $68, $35 ; "o55hhhh5"
    DB      $35, $68, $68, $68, $68, $35, $35, $68 ; "5hhhh55h"
    DB      $68, $68, $68, $35, $35, $68, $68, $68 ; "hhh55hhh"
    DB      $68, $35, $35, $68, $68, $68, $68, $35 ; "h55hhhh5"
    DB      $35, $68, $68, $68, $68, $03, $04, $6C
    DB      $6D, $35, $35, $68, $68, $6F, $35, $68 ; "m55hho5h"
    DB      $68, $68, $6F, $09, $08, $89, $8A, $8B
    DB      $8B, $8B, $8B, $89, $8A, $81, $00, $80
    DB      $8C, $8B, $8D, $00, $00, $82, $83, $80
    DB      $87, $85, $00, $00, $00, $13, $84, $80
    DB      $86, $08, $09, $28, $27, $35, $35, $80
    DB      $37, $37, $B8, $B9, $35, $35, $35, $80
    DB      $35, $35, $BA, $BB, $35, $35, $35, $80
    DB      $35, $35, $35, $35, $35, $35, $35, $80
    DB      $35, $35, $35, $35, $35, $70, $71, $80
    DB      $73, $74, $75, $76, $77, $09, $02, $89
    DB      $8A, $00, $00, $00, $00, $2A, $29, $35
    DB      $35, $35, $35, $35, $35, $35, $35, $70 ; "5555555p"
    DB      $71, $09, $04, $8B, $8B, $8B, $8B, $00
    DB      $8C, $8B, $8D, $00

; ============================================================
; TILE / SPRITE BITMAPS  ($BC00 - $BF6F)
; TMS9918A pattern table -- 8 bytes per tile (one byte per row).
; 110 tiles total.
; ============================================================
TILE_BITMAPS:                               ; TILE_BITMAPS ($BC00): TMS9918A pattern table (110 tiles × 8 bytes = $BC00-$BF6F)
    DB      $00, $00, $00, $23, $25, $27, $29, $35 ; tile 0
    DB      $35, $35, $35, $35, $35, $35, $35, $35 ; tile 1
    DB      $35, $35, $35, $35, $35, $35, $35, $70 ; tile 2
    DB      $71, $72, $73, $0B, $0C, $48, $49, $00 ; tile 3
    DB      $00, $00, $00, $00, $00, $00, $4A, $4B ; tile 4
    DB      $4C, $50, $51, $80, $80, $80, $80, $80 ; tile 5
    DB      $80, $80, $52, $53, $68, $54, $55, $80 ; tile 6
    DB      $80, $80, $80, $80, $80, $80, $56, $57 ; tile 7
    DB      $68, $50, $51, $80, $80, $80, $80, $80 ; tile 8
    DB      $80, $80, $52, $53, $68, $58, $59, $5A ; tile 9
    DB      $5A, $5A, $5A, $5A, $5A, $5A, $5A, $5B ; tile 10
    DB      $68, $0A, $04, $97, $95, $FE, $96, $E3 ; tile 11
    DB      $A0, $FE, $E3, $E3, $A1, $92, $E3, $4E ; tile 12
    DB      $E3, $93, $E3, $E3, $E3, $E3, $E3, $A2 ; tile 13
    DB      $E3, $E3, $4F, $A3, $E3, $E3, $4E, $A4 ; tile 14
    DB      $E3, $A3, $E3, $A5, $A7, $A4, $A6, $9D ; tile 15
    DB      $9E, $9C, $9F, $0A, $04, $97, $94, $95 ; tile 16
    DB      $96, $E3, $E3, $E3, $4E, $E3, $E3, $E3 ; tile 17
    DB      $E3, $4E, $E3, $A0, $E3, $4F, $E3, $A1 ; tile 18
    DB      $E3, $E3, $E3, $4F, $E3, $A1, $E3, $E3 ; tile 19
    DB      $E3, $A2, $E3, $FF, $A1, $A3, $A7, $47 ; tile 20
    DB      $A2, $9F, $98, $FE, $99, $0A, $04, $90 ; tile 21
    DB      $91, $4D, $97, $E3, $E3, $4F, $E3, $E3 ; tile 22
    DB      $E3, $E3, $4E, $E3, $A1, $E3, $E3, $E3 ; tile 23
    DB      $A2, $E3, $A0, $E3, $A2, $A1, $E3, $4E ; tile 24
    DB      $A3, $E3, $E3, $E3, $A4, $E3, $A3, $A7 ; tile 25
    DB      $A5, $A6, $A4, $9C, $9D, $9E, $9F, $08 ; tile 26
    DB      $07, $00, $00, $00, $00, $00, $00, $C0 ; tile 27
    DB      $00, $00, $00, $00, $00, $C1, $C2, $00 ; tile 28
    DB      $00, $00, $00, $C3, $D8, $00, $00, $00 ; tile 29
    DB      $00, $D1, $D2, $D9, $00, $00, $00, $00 ; tile 30
    DB      $D3, $D7, $C8, $C9, $00, $00, $00, $CA ; tile 31
    DB      $CB, $CC, $CD, $00, $0F, $1B, $DA, $DB ; tile 32
    DB      $DC, $10, $35, $35, $35, $B0, $B1, $B2 ; tile 33
    DB      $35, $07, $07, $00, $00, $00, $00, $00 ; tile 34
    DB      $00, $00, $00, $00, $00, $00, $00, $00 ; tile 35
    DB      $00, $00, $00, $00, $00, $00, $00, $00 ; tile 36
    DB      $00, $00, $00, $D1, $D2, $00, $00, $00 ; tile 37
    DB      $00, $00, $D3, $CE, $C8, $C9, $00, $C4 ; tile 38
    DB      $DD, $CF, $D0, $CC, $CD, $C5, $C6, $1B ; tile 39
    DB      $DA, $DB, $DC, $10, $04, $0A, $35, $35 ; tile 40
    DB      $E4, $E0, $E3, $E3, $E1, $35, $35, $35 ; tile 41
    DB      $35, $E2, $E6, $E3, $E3, $E3, $E3, $E1 ; tile 42
    DB      $35, $35, $E4, $E6, $E0, $E7, $E3, $E3 ; tile 43
    DB      $E3, $E0, $E5, $35, $E0, $E0, $E6, $E6 ; tile 44
    DB      $E7, $E7, $E7, $E7, $E7, $E1, $11, $04 ; tile 45
    DB      $00, $00, $0F, $28, $00, $10, $11, $11 ; tile 46
    DB      $00, $11, $11, $11, $00, $D4, $D5, $11 ; tile 47
    DB      $00, $D6, $E3, $11, $00, $E3, $E3, $11 ; tile 48
    DB      $2E, $E3, $E3, $11, $35, $E3, $E3, $11 ; tile 49
    DB      $35, $E3, $E3, $11, $35, $E3, $E3, $11 ; tile 50
    DB      $35, $5E, $FE, $11, $35, $11, $5E, $11 ; tile 51
    DB      $A9, $11, $11, $11, $AA, $11, $11, $11 ; tile 52
    DB      $AA, $11, $11, $11, $AA, $11, $11, $11 ; tile 53
    DB      $AA, $11, $11, $11, $03, $04, $35, $B3 ; tile 54
    DB      $B4, $B5, $35, $B6, $B7, $35, $44, $45 ; tile 55
    DB      $46, $BF, $00, $00, $08, $45, $54, $FF ; tile 56
    DB      $FF, $FF, $00, $08, $12, $55, $F8, $FC ; tile 57
    DB      $F8, $F0, $00, $00, $00, $00, $00, $00 ; tile 58
    DB      $00, $00, $00, $00, $08, $04, $02, $07 ; tile 59
    DB      $03, $03, $00, $00, $00, $14, $92, $FF ; tile 60
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 61
    DB      $FF, $FF, $F0, $F0, $F8, $F8, $F0, $F0 ; tile 62
    DB      $E0, $E0, $00, $00, $00, $00, $00, $00 ; tile 63
    DB      $00, $00, $07, $07, $03, $03, $07, $07 ; tile 64
    DB      $07, $0F, $FF, $FF, $FF, $FF, $FF, $FF ; tile 65
    DB      $FF, $FF, $E0, $E0, $E0, $F0, $F0, $F0 ; tile 66
    DB      $E0, $E0, $00, $00, $00, $00, $00, $00 ; tile 67
    DB      $00, $00, $0F, $0F, $0F, $07, $07, $07 ; tile 68
    DB      $03, $03, $FF, $FF, $FF, $FF, $FF, $FF ; tile 69
    DB      $FF, $FF, $F0, $F8, $F8, $FC, $FE, $FE ; tile 70
    DB      $FF, $FF, $00, $00, $00, $00, $00, $00 ; tile 71
    DB      $00, $00, $03, $03, $07, $07, $1F, $1F ; tile 72
    DB      $3F, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 73
    DB      $FF, $FF, $00, $22, $9F, $24, $92, $4F ; tile 74
    DB      $49, $24, $A7, $01, $4D, $27, $80, $B2 ; tile 75
    DB      $E4, $12, $24, $E5, $24, $49, $F2, $00 ; tile 76
    DB      $44, $F9, $11, $53, $49, $45, $52, $52 ; tile 77
    DB      $41, $20, $20, $4F, $4E, $2D, $4C, $49 ; tile 78
    DB      $4E, $45, $1E, $1F, $7F, $20, $54, $20 ; tile 79
    DB      $08, $50, $52, $45, $53, $45, $4E, $54 ; tile 80
    DB      $53, $7F, $20, $76, $20, $0F, $42, $2E ; tile 81
    DB      $43, $2E, $27, $53, $20, $20, $51, $55 ; tile 82
    DB      $45, $53, $54, $1E, $1F, $7F, $20, $58 ; tile 83
    DB      $20, $02, $42, $59, $7F, $20, $54, $20 ; tile 84
    DB      $1A, $53, $59, $44, $4E, $45, $59, $20 ; tile 85
    DB      $44, $45, $56, $45, $4C, $4F, $50, $4D ; tile 86
    DB      $45, $4E, $54, $20, $43, $4F, $52, $50 ; tile 87
    DB      $2E, $1E, $1F, $7F, $20, $7F, $20, $69 ; tile 88
    DB      $20, $17, $1D, $20, $20, $31, $39, $38 ; tile 89
    DB      $33, $20, $20, $53, $49, $45, $52, $52 ; tile 90
    DB      $41, $20, $4F, $4E, $2D, $4C, $49, $4E ; tile 91
    DB      $45, $69, $20, $16, $1E, $1F, $20, $49 ; tile 92
    DB      $4E, $44, $49, $43, $41, $54, $45, $53 ; tile 93
    DB      $20, $54, $52, $41, $44, $45, $4D, $41 ; tile 94
    DB      $52, $4B                    ; tile 95

VDP_REG_BEFA:                               ; VDP_REG_BEFA ($BEFA): ROM->VRAM compressed pattern writer; IX=VRAM addr, DE=src, HL=len
    ADD     HL, DE                          ; ADD HL,DE: HL = end-of-source address
    DB      $EB                             ; DB $EB: EX DE,HL (DE=end, HL=start)

LOC_BEFC:
    LD      A, (HL)                         ; A=(HL): read RLE control byte
    BIT     7, A                            ; BIT 7,A: bit 7 set = run-length or fill?
    JR      NZ, LOC_BF25                    ; JR NZ, LOC_BF25: yes -> RLE decode
    BIT     6, A                            ; BIT 6,A: bit 6 = multi-byte literal block?
    JR      NZ, LOC_BF1E                    ; JR NZ, LOC_BF1E: yes -> literal block
    LD      C, A                            ; LD C,A: count = low 6 bits (literal single byte)
    SUB     A
    LD      B, A                            ; INC HL: advance source ptr
    INC     HL
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IX
    PUSH    IX
    POP     DE
    CALL    WRITE_VRAM                      ; CALL WRITE_VRAM: write C bytes to VRAM at IX
    POP     IX
    POP     HL
    POP     DE
    POP     BC
    ADD     HL, BC                          ; ADD HL,BC: advance src ptr past literal
    ADD     IX, BC                          ; ADD IX,BC: advance VRAM dest
    JR      LOC_BF52

LOC_BF1E:
    AND     $BF
    PUSH    AF
    INC     HL
    LD      A, (HL)
    JR      LOC_BF35

LOC_BF25:
    BIT     5, A
    JR      NZ, LOC_BF30
    AND     $1F
    PUSH    AF
    LD      A, $00
    JR      LOC_BF35

LOC_BF30:
    AND     $1F
    PUSH    AF
    LD      A, $FF

LOC_BF35:
    DB      $E3
    PUSH    AF
    LD      C, H
    SUB     A
    LD      B, A
    POP     AF
    DB      $E3
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IX
    LD      D, B
    LD      E, C
    PUSH    IX
    POP     HL
    CALL    FILL_VRAM
    POP     IX
    POP     HL
    POP     DE
    POP     BC
    POP     AF
    ADD     IX, BC
    INC     HL

LOC_BF52:
    LD      A, H
    CP      D
    JR      NZ, LOC_BEFC
    LD      A, L
    CP      E
    JR      NZ, LOC_BEFC
    RET     
    DB      $61, $2E, $00, $16, $00, $06, $08, $29
    DB      $30, $01, $19, $10, $FA, $C9, $C5, $0E
    DB      $20, $CD, $5B, $BF, $C1

; ============================================================
; ZERO PADDING  ($BF70 - $BFFF)
; ============================================================
    DB      $06, $00, $09, $C9, $4E, $23, $5E, $23
    DB      $E5, $CD, $69, $BF, $EB, $E1, $4E, $06
    DB      $00, $C5, $FD, $E1, $23, $3E, $02, $C3
    DB      $BE, $1F

VDP_REG_BF8A:                               ; VDP_REG_BF8A ($BF8A): RAM->VRAM block: B=$100-byte pages, C=remainder; DE=VRAM, HL=src
    LD      A, B                            ; LD A,B: test page count
    CP      $00                             ; CP $00
    JR      Z, LOC_BF9F                     ; JR Z, LOC_BF9F: no pages -> skip page loop

LOC_BF8F:                                   ; LOC_BF8F: PUSH BC
    PUSH    BC                              ; LD BC,BOOT_UP: BC=$0000 for WRITE_VRAM (full page)
    LD      BC, BOOT_UP
    PUSH    DE
    PUSH    HL                              ; CALL WRITE_VRAM: write one $100-byte page to VRAM at DE from HL
    CALL    WRITE_VRAM                      ; POP HL: restore HL
    POP     HL                              ; INC H: advance src by $100 (next page)
    INC     H                               ; POP DE: restore DE
    POP     DE                              ; INC D: advance VRAM by $100 (next page)
    INC     D
    POP     BC                              ; DJNZ LOC_BF8F: loop for all pages
    DJNZ    LOC_BF8F

LOC_BF9F:
    LD      A, C                            ; LD A,C: test remainder
    OR      A                               ; OR A
    RET     Z                               ; RET Z: no remainder -> done
    CALL    WRITE_VRAM                      ; CALL WRITE_VRAM: write remainder C bytes
    RET     

VDP_REG_BFA6:                               ; VDP_REG_BFA6 ($BFA6): VRAM->RAM block read (mirror of BF8A using READ_VRAM)
    LD      A, B                            ; LD A,B: test page count
    CP      $00
    JR      Z, LOC_BFBB

LOC_BFAB:
    PUSH    BC
    LD      BC, BOOT_UP
    PUSH    DE
    PUSH    HL
    CALL    READ_VRAM                       ; CALL READ_VRAM: read one $100-byte page from VRAM
    POP     HL
    INC     H
    POP     DE
    INC     D
    POP     BC
    DJNZ    LOC_BFAB

LOC_BFBB:
    LD      A, C
    OR      A
    RET     Z
    CALL    READ_VRAM
    RET     
    DB      $CD, $EB, $1F, $3A, $31, $70, $21, $36
    DB      $70, $A6, $C0, $CD, $D6, $1F, $EF, $CD
    DB      $F6, $BF, $CD, $F0, $BF, $CD, $F6, $BF
    DB      $CD, $61, $1F, $C9, $CD, $DC, $1F, $CB
    DB      $7F, $28, $F9, $CD, $EB, $1F, $3A, $31
    DB      $70, $21, $36, $70, $A6, $C9, $CD, $DE
    DB      $BF, $C8, $18, $FA, $CD, $DE, $BF, $C0
    DB      $18, $FA, $EB, $E1, $FF, $FF

; ---- mid-instruction label aliases (EQU) ----
LOC_A1AE:        EQU $A1AE
