; =============================================================================
; HERO  --  ColecoVision  (16 KB ROM, loads at $8000)
; Disassembled by z80cv_disasm.py  |  Annotated with Claude Sonnet 4.6
; Exact byte-match verified vs. hero.rom
; =============================================================================
;
; LEGEND / CROSS-REFERENCE  --  all line numbers refer to THIS file.
; ROM addresses shown as ($XXXX).
;
; --- HARDWARE / BIOS ----------------------------------------------------------
;   BIOS entry points:       lines 161-210   (EQU block)
;   I/O port definitions:    lines 214-220
;   RAM definitions:         lines 224-227
;     WORK_BUFFER       $7000   general RAM workspace
;     CONTROLLER_BUFFER $702B   processed controller state (game-side)
;     JOYSTICK_BUFFER   $7031   raw BIOS POLLER output
;     STACKTOP          $73B9   top of stack (mirrored RAM $6000-$63FF)
;
; --- ROM LAYOUT ---------------------------------------------------------------
;   $8000  cart magic + header               line  244
;            LEVEL_COLOR_TABLE $8024         line  250   (see Level section)
;   $8021  CART_ENTRY / JP NMI               line  244
;   $8052  START -- boot init                line  266
;   $841E  NMI handler                       line  789
;   $B054  GAME_DATA  (raw DB, ~2.7 KB)      line 5206
;   $BC00  TILE_BITMAPS (110 x 8-byte tiles) line 5604
;   $BF70  Zero padding                      line 5717
;
; --- BOOT / INIT SEQUENCE -----------------------------------------------------
;   START ($8052)          line  266    stack init, RAM clear, VDP init, call SUB_9AC6
;   LOC_8074               line  286    VDP register setup, goto demo or game
;   LOC_80CA               line  338    first-run gate (skip title if $702E set)
;   LOC_80E4               line  350    new-game vs. continue branch
;   LOC_80FF               line  365    sound-engine reset, sprite/VDP init
;   SUB_9AC6 ($9AC6)       line 3067    title screen / intro animation
;
; --- NMI HANDLER ($841E) ------------------------------------------------------
;   NMI                    line  789    saves all regs incl. shadow set (EXX / EX AF,AF')
;                                    dispatches all per-frame game logic, then RET
;
; --- LEVEL SYSTEM -------------------------------------------------------------
;   $72A9 = level index 0-19.  At 20 wraps back to 12.  Reset to 0 on new game.
;   $72AA = difficulty cycle counter (reset to 0 at each level start).
;   $705D = player sprite color index (loaded from LEVEL_COLOR_TABLE each level).
;
;   LEVEL_COLOR_TABLE ($8024, 20 bytes)                line  250
;     Indexed by $72A9.  Player sprite TMS9918A color per level group:
;       Levels  0- 8:  $06  dark red
;       Levels  9-16:  $05  light blue
;       Levels 17-19:  $04  dark blue
;
;   LEVEL_ENEMY_OFFSET_TABLE ($B748, 20 bytes)         line 5433
;     Per-level byte offset into LEVEL_ENEMY_PARAMS ($B770).
;
;   LEVEL_ENEMY_SPAWN_THRESH ($B75C, 20 bytes)         line 5433
;     Enemy activation threshold vs. $72AA difficulty cycle.
;     Enemy activates when $72AA == threshold OR $72AA >= 10.
;
;   LEVEL_ENEMY_PARAMS ($B770+)                        line 5433
;     Enemy Y-position table.  Access: ROM[$B770 + B748[level] + $72AA].
;     $93 = off-screen / inactive sentinel value.
;
;   LOC_812C ($812C)  line  391   LEVEL ADVANCE: INC $72A9, wrap to 12 at 20
;   LOC_815B ($815B)  line  428   LEVEL STATE INIT: color lookup, reset $72AA
;   LOC_819A ($819A)  line  459   LEVEL START: draw cave, display level number
;   SUB_8792 ($8792)  line 1298   render level number on screen ($72A9 + 1)
;   DELAY_LOOP_AADB   line 4471   draw 10 RLE cave column strips to VRAM
;
; --- CAVE LAYOUT DATA (fixed -- same map every level) -------------------------
;   Cave column strip data A  ($B2F7, $B302)           line 5292
;     Strips 8-9, written to VRAM name table rows 2-3  ($3A80-$3B3F)
;   Cave column strip data B  ($B60D..$B6BB)           line 5393
;     Strips 0-7, written to VRAM name table rows 1-2  ($3900-$3A7F)
;   All 10 strips are RLE-encoded (SUB_86C7 format); drawn by DELAY_LOOP_AADB.
;   $93 values in strip data = blank / open cave space tile.
;
; --- PLAYER / SPRITE SYSTEM ---------------------------------------------------
;   Sprite struct: 6 bytes per entry at $719D (9 entries: hero + 8 enemies)
;   $719D  base of 9-sprite table (6 bytes each = 54 bytes total)
;   $72BB  IX base for enemy sub-structure (used in AEE6 / AD1D)
;   LOC_9003           line 2329   bump sprite right one pixel (used by physics)
;   LOC_900B           line 2334   bump sprite left one pixel
;   SUB_9013           line 2339   init both rotor sprites
;   SUB_9027 ($9027)   line 2347   init one rotor sprite (bounds, enable, color)
;   DELAY_LOOP_9040    line 2359   disable all 9 sprite slots
;   SOUND_WRITE_9051   line 2370   reset all sprites, re-enable active enemy
;   LOC_9084 ($9084)   line 2389   place hero sprite at level-start position
;   SUB_90ED ($90ED)   line 2411   hero entry animation setup
;   SUB_9153 ($9153)   line 2446   set sprite pattern index (IX+0)
;   SUB_9160 ($9160)   line 2455   set sprite bounds (IX+2, IX+3)
;   SUB_9167 ($9167)   line 2462   set velocity (IX+1) + color nibble (IX+5)
;   SUB_9174 ($9174)   line 2472   disable sprite: clear bit 7 of IX+5
;   LOC_9179 ($9179)   line 2478   enable  sprite: set  bit 7 of IX+5
;   SUB_917E ($917E)   line 2484   clamp position to bounds, set C flags
;   SUB_A70E ($A70E)   line 3877   sprite physics / movement update
;   SUB_A80B ($A80B)   line 4014   enemy appear / death animation dispatch
;   LOC_A5C7 ($A5C7)   line 3686   level-complete handler (sound + new level)
;   SUB_AEE6 ($AEE6)   line 5007   enemy init using B748 / B75C / B770 tables
;   SUB_9C12 ($9C12)   line 3171   enemy frame select (level % 4 four-cycle)
;
; --- SOUND SYSTEM (SN76489A via OUT $FF) --------------------------------------
;   All sound writes go through port $FF (SOUND_PORT).
;   SUB_888F ($888F)       line 1436   sound engine init / silence all channels
;   LOC_889B ($889B)       line 1445   per-frame sound update dispatch loop
;   CTRL_READ_88BD         line 1467   controller input read + sound trigger
;   LOC_8AC7 ($8AC7)       line 1778   level-complete fanfare START (8-step seq)
;   SUB_8AE5 ($8AE5)       line 1795   level-complete sound UPDATE (step counter)
;   SOUND_WRITE_8B08       line 1820   write noise channel register
;   SOUND_WRITE_8B14       line 1834   write tone frequency (two OUT bytes)
;   SOUND_WRITE_8B34       line 1865   write tone attenuation
;   SOUND_WRITE_8CDA       line 2031   set player/enemy sprite anim positions
;   SOUND_WRITE_82DB       line  609   wing-flap sound trigger (propeller)
;   SUB_8351 ($8351)       line  670   per-frame explosion / death anim driver
;   SUB_8A8A ($8A8A)       line 1738   bonus / score sound start
;
; --- VDP / VRAM UTILITIES (TMS9918A via BIOS) ---------------------------------
;   SUB_86C7 ($86C7)    line 1170   RLE decode -> VRAM buffer at $7079
;     Data format: 0x00 = end-of-stream
;                  0x01-0x7F = (count, fill-byte)  -- run of identical bytes
;                  0x80-0xFF = (N|0x80, N raw bytes) -- literal copy (LDIR)
;   SOUND_WRITE_86FA    line 1206   flush $7079 buffer to VRAM via WRITE_VRAM
;   SUB_98D4 ($98D4)    line 2968   SUB_86C7 + SOUND_WRITE_86FA combined
;   DELAY_LOOP_86A4     line 1132   memset: fill DE[0..C-1] with byte A
;   DELAY_LOOP_86AC     line 1143   timed fill (sound timing helper)
;   SUB_869D ($869D)    line 1122   byte table lookup: A = ROM[HL + A]
;   SUB_AA9E ($AA9E)    line 4432   draw one 3-byte cave strip entry to VRAM
;   DELAY_LOOP_AA5D     line 4381   init 4 sprite slots from (HL) table
;   DELAY_LOOP_AA00     line 4321   write D,E to IX slots (4-byte stride)
;   SUB_8762            line 1269   BCD digit helper
;   SUB_876C ($876C)    line 1279   score / high-score display update
;   SUB_881E ($881E)    line 1404   lives display update
;   SUB_8831            line 1414   palette / colour attribute table write
;   LOC_8C44 ($8C44)    line 1969   animate cave entrance (4 strip overlay)
;   SUB_8C97 ($8C97)    line 2007   hero entry animation (helicopter descent)
;   LOC_8CE4 ($8CE4)    line 2037   place hero + enemy sprites for new round
;   SUB_A1DC ($A1DC)    line 3263   load cave overlay to VRAM $1AE0
;   SUB_A1E5 ($A1E5)    line 3268   load HUD chrome strips to VRAM $190C/$192C
;
; --- COLLISION / GAME LOGIC ---------------------------------------------------
;   SUB_83CE ($83CE)    line  735   set collision flag C = 1
;   SUB_83D2 ($83D2)    line  739   clear collision state
;   SUB_84F1 ($84F1)    line  893   process player landing / miner rescue
;   SUB_8494 ($8494)    line  837   check cave-floor collision
;   LOC_8539 ($8539)    line  934   process per-level init flags (bits 0,1,3)
;   LOC_8573 ($8573)    line  967   handle player death / life decrement
;   LOC_8202 ($8202)    line  503   level-complete detect + fanfare trigger
;   LOC_83FC ($83FC)    line  767   game-over check (lives = 0)
;   SUB_A3B4 ($A3B4)    line 3381   cave orientation query (left/right branch)
;   SUB_A469 ($A469)    line 3479   look up directional sprite frame pair
;   LOC_A55A ($A55A)    line 3621   spawn / respawn enemy entity
;   SUB_A598 ($A598)    line 3654   enemy movement step
;   LOC_A84B ($A84B)    line 4047   place enemy sprite after appear animation
;   DELAY_LOOP_A4BD     line 3530   projectile move step
;   DELAY_LOOP_A4D4     line 3544   projectile collision check
;   DELAY_LOOP_A58A     line 3642   3-pass respawn sequence
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
CONTROLLER_BUFFER:       EQU $702B
JOYSTICK_BUFFER:         EQU $7031
STACKTOP:                EQU $73B9

FNAME "output\HERO-NEW.ROM"
CPU Z80

    ORG     $8000

    DW      $AA55                       ; cart magic
    DB      $00, $00
    DB      $00, $00
    DB      $00, $00
    DW      JOYSTICK_BUFFER             ; BIOS POLLER writes controller state here
    DW      START                       ; start address
    DB      $C9, $00, $00, $C9, $00, $00, $C9, $00
    DB      $00, $C9, $00, $00, $C9, $00, $00, $C9
    DB      $00, $00, $C9, $00, $00

CART_ENTRY:
    JP      NMI                         ; jump to NMI handler (CART_ENTRY vector)
; ------------------------------------------------------------
; CART HEADER DATA  ($8024 - $8051)
; Two data tables embedded in the unused cart header area:
;
; LEVEL_COLOR_TABLE  ($8024, 20 bytes) -- player sprite color by level:
;   Levels  0-8:  $06 = dark red
;   Levels  9-16: $05 = light blue
;   Levels 17-19: $04 = dark blue
; Loaded by: LD HL,$8024 / LD A,($72A9) / CALL SUB_869D -> ($705D)
;
; Bytes $8038+ are read by SUB_81ED for per-level init flags,
; double-indexed via LEVEL_ENEMY_OFFSET_TABLE ($B748).
; ------------------------------------------------------------
    DB      $06, $06, $06, $06, $06, $06, $06, $06
    DB      $06, $05, $05, $05, $05, $05, $05, $05
    DB      $05, $04, $04, $04, $02, $08, $02, $08
    DB      $02, $02, $02, $08, $02, $08, $02, $08
    DB      $02, $02, $08, $02, $08, $02, $08, $02
    DB      $06, $FF, $03, $38, $07, $00

START:
    LD      SP, STACKTOP                ; set stack pointer to $73B9 (top of RAM stack)
    XOR     A                           ; A = 0 (also clears carry and zero flags)
    LD      ($7069), A                  ; clear interrupt-active flag ($7069 = 0)
    LD      DE, CONTROLLER_BUFFER       ; DE -> $702B (processed controller state)
    LD      C, $30                      ; count = 48 bytes to clear
    CALL    DELAY_LOOP_86A4             ; memset: fill DE[0..47] with A (=0)
    LD      HL, STACKTOP                ; HL = $73B9 (stack base for zeroing loop)
    LD      BC, $0047                   ; loop counter = 71 iterations (zero stack area)

LOC_8067:
    LD      (HL), $00                   ; write 0 to [HL] (zeroing stack area)
    INC     HL                          ; advance pointer to next byte
    DEC     BC                          ; decrement 16-bit counter
    LD      A, B                        ; A = high byte of BC
    OR      C                           ; A = B|C (nonzero if BC != 0)
    JR      NZ, LOC_8067               ; loop until BC = 0
    LD      A, $01                      ; A = 1 (normal game mode value)
    LD      ($702D), A                  ; $702D = 1 (special-mode flag: normal)

LOC_8074:
    LD      SP, STACKTOP                ; reset stack pointer to $73B9
    LD      B, $01                      ; VDP register number = 1
    LD      C, $82                      ; value $82 = enable display, 16x16 sprites
    CALL    WRITE_REGISTER              ; BIOS: write VDP reg 1 = $82
    LD      B, $00                      ; VDP register number = 0
    LD      C, $02                      ; value $02 = mode 2 (bitmap graphics)
    CALL    WRITE_REGISTER              ; BIOS: write VDP reg 0 = $02
    CALL    SUB_83CE                    ; set collision flag (C=1 -> VDP backdrop color)
    LD      HL, WORK_BUFFER             ; HL -> $7000 (start of work RAM)
    LD      BC, $002B                   ; loop counter = 43 bytes (clear $7000-$702A)

LOC_808E:
    LD      (HL), $00                   ; zero byte at [HL]
    INC     HL                          ; advance pointer
    DEC     BC                          ; decrement counter
    LD      A, B                        ; A = high byte of BC
    OR      C                           ; A = B|C (nonzero if BC != 0)
    JR      NZ, LOC_808E               ; loop until BC = 0
    LD      HL, $705B                   ; HL -> $705B (player lives count)
    LD      BC, $035E                   ; loop counter = 862 bytes (clear $705B-$73B8)

LOC_809C:
    LD      (HL), $00                   ; zero byte at [HL]
    INC     HL                          ; advance pointer
    DEC     BC                          ; decrement counter
    LD      A, B                        ; A = high byte of BC
    OR      C                           ; A = B|C (nonzero if BC != 0)
    JR      NZ, LOC_809C               ; loop until BC = 0
    LD      HL, $804C                   ; HL -> $804C (VDP register init table in cart header)
    LD      B, $02                      ; start with VDP register 2

LOC_80A9:
    LD      C, (HL)                     ; C = VDP register value from table
    INC     HL                          ; advance to next table byte
    PUSH    BC                          ; save BC (register number + value)
    PUSH    HL                          ; save HL (table pointer)
    CALL    WRITE_REGISTER              ; BIOS: write VDP register B with value C
    POP     HL                          ; restore table pointer
    POP     BC                          ; restore register number
    INC     B                           ; B++ (next VDP register number)
    LD      A, B                        ; A = current register number
    CP      $08                         ; compare A to 8
    JR      C, LOC_80A9                 ; loop while B < 8 (write VDP registers 2-7)
    LD      A, ($702E)                  ; A = title-screen-seen flag
    AND     A                           ; test if zero (title not yet shown)
    JR      NZ, LOC_80CA               ; skip title if already shown ($702E != 0)
    LD      HL, BOOT_UP                 ; HL = $0000 (fill value = 0 for VRAM clear)
    LD      DE, $4000                   ; DE = 16384 bytes (full VRAM)
    CALL    FILL_VRAM                   ; BIOS: clear all VRAM to 0
    CALL    SUB_9AC6                    ; title screen: load patterns + name-table

LOC_80CA:
    LD      A, ($702E)                  ; A = title-screen-seen flag
    AND     A                           ; test if zero
    JR      NZ, LOC_80E4               ; if nonzero, skip title init (already done)
    LD      (CONTROLLER_BUFFER), A     ; CONTROLLER_BUFFER = 0 (clear controller state)
    LD      ($702C), A                  ; $702C = 0 (saved level index = 0)
    CALL    SUB_876C                    ; update score / high-score display
    CALL    SUB_8792                    ; render level number on screen
    LD      A, $FF                      ; A = $FF
    LD      (CONTROLLER_BUFFER), A     ; CONTROLLER_BUFFER = $FF (mark as initialized)
    LD      ($702E), A                  ; $702E = $FF (title-screen-seen flag set)

LOC_80E4:
    LD      A, (CONTROLLER_BUFFER)     ; A = processed controller state
    AND     A                           ; test if zero (new game)
    JR      Z, LOC_80F3                 ; if zero, start new game
    XOR     A                           ; A = 0
    LD      ($72A9), A                  ; level index = 0 (start from level 1)
    CALL    LOC_A120                    ; load new-game title screen graphics
    JR      LOC_80FF                    ; proceed to game init

LOC_80F3:
    LD      A, ($702C)                  ; A = saved level index (continue game)
    LD      ($72A9), A                  ; current level index = saved level
    CALL    SUB_A125                    ; load continue-game graphics
    CALL    SUB_A1DC                    ; load cave overlay to VRAM $1AE0

LOC_80FF:
    CALL    SUB_888F                    ; initialize sound engine (silence all channels)
    LD      A, $9B                      ; A = $9B (joystick neutral/idle value)
    LD      (JOYSTICK_BUFFER), A        ; JOYSTICK_BUFFER = $9B (raw controller idle)
    LD      ($7032), A                  ; $7032 = $9B (second controller idle)
    LD      A, $06                      ; A = 6
    LD      ($705C), A                  ; player score hundreds digit = 6 (display init)
    LD      A, $03                      ; A = 3
    LD      ($705B), A                  ; player lives count = 3
    LD      A, $03                      ; A = 3
    LD      ($705E), A                  ; player extra lives = 3
    CALL    SUB_9BCA                    ; initialize propeller animation state
    CALL    LOC_815B                    ; level state init: color lookup, reset $72AA
    CALL    SUB_876C                    ; update score / high-score display
    CALL    SUB_8630                    ; VDP: enable display, clear game-over flag

LOC_8125:
    LD      A, $27                      ; A = $27 (game-loop-running sentinel)
    LD      ($7069), A                  ; $7069 = $27 (signal NMI: game loop is running)
    JR      LOC_8125                    ; spin here -- NMI fires and runs game logic

; ; ---- LEVEL ADVANCE ----
; ; LOC_812C -- increment $72A9 (level index 0-19).
; ;   If $702D = $05 (special mode), derive level from $7067 mod 20.
; ;   Normal: INC $72A9; if >= $14 (20), wrap back to $0C (12) and set $705F=$FF.
; ;   After advance: if CONTROLLER_BUFFER nonzero, mask level to lower 2 bits (0-3).
LOC_812C:
    LD      HL, $72A9                   ; HL -> current level index
    LD      A, ($702D)                  ; A = special-mode flag
    CP      $05                         ; compare to $05 (special mode)
    JR      NZ, LOC_8143               ; if not special mode, use normal increment
    LD      A, ($7067)                  ; A = frame counter (used as level seed in special mode)
    ADD     A, $10                      ; add 16 (shift into range for mod-20 loop)

LOC_813B:
    SUB     $14                         ; subtract 20 (mod-20 reduction loop)
    JR      NC, LOC_813B               ; loop while result >= 0
    ADD     A, $14                      ; add 20 back (restore to 0-19 range)
    JR      LOC_8150                    ; store computed level

LOC_8143:
    LD      A, (HL)                     ; A = current level index ($72A9)
    INC     A                           ; A++ (advance to next level)
    CP      $14                         ; compare to 20 (max level + 1)
    JR      C, LOC_8150                 ; if A < 20, no wrap needed
    LD      A, $FF                      ; A = $FF
    LD      ($705F), A                  ; $705F = $FF (level-wrap flag: wrapped to 12)
    LD      A, $0C                      ; A = 12 (wrap-around level)

LOC_8150:
    LD      (HL), A                     ; store new level index into $72A9
    LD      A, (CONTROLLER_BUFFER)     ; A = controller state
    AND     A                           ; test if zero
    JR      Z, LOC_815B                 ; if zero, proceed to level init
    LD      A, (HL)                     ; A = new level index
    AND     $03                         ; mask to lower 2 bits (keep levels 0-3 only)
    LD      (HL), A                     ; store masked level index

; ; ---- LEVEL STATE INIT ----
; ; LOC_815B -- reset all per-level state after a new level index is set.
; ;   Reads LEVEL_COLOR_TABLE[$72A9] -> $705D (player sprite color).
; ;   Resets: $7063, $7072, $72AA (difficulty cycle), $7074, $7281, $7294, $7284.
; ;   Clears $72AB..$72BA (16 bytes of sprite state).
LOC_815B:
    LD      HL, $8024                   ; HL -> LEVEL_COLOR_TABLE base
    LD      A, ($72A9)                  ; A = current level index (0-19)
    CALL    SUB_869D                    ; A = ROM[$8024 + level] (player color for this level)
    LD      ($705D), A                  ; $705D = player sprite color index
    CALL    SOUND_WRITE_9051            ; reset all 9 sprite slots (disable all)
    XOR     A                           ; A = 0
    LD      ($7063), A                  ; $7063 = 0 (explosion/death anim timer)
    LD      ($7072), A                  ; $7072 = 0 (player movement state)
    LD      ($72AA), A                  ; $72AA = 0 (difficulty cycle counter reset)
    LD      ($7074), A                  ; $7074 = 0 (player direction/motion flag)
    LD      ($7281), A                  ; $7281 = 0 (player-on-ground flag)
    CPL                                 ; A = $FF (bitwise NOT of 0)
    LD      ($7294), A                  ; $7294 = $FF (collision/contact flag set)
    LD      ($7284), A                  ; $7284 = $FF (mine-contact state)
    LD      A, $06                      ; A = 6 (initial fuel/score display value)
    LD      ($705C), A                  ; $705C = 6 (score hundreds digit reset)
    LD      DE, $72AB                   ; DE -> $72AB (sprite state array)
    LD      C, $10                      ; count = 16 bytes to clear
    XOR     A                           ; A = 0
    CALL    DELAY_LOOP_86A4             ; memset: zero $72AB..$72BA
    LD      A, (CONTROLLER_BUFFER)     ; A = controller state
    AND     A                           ; test if zero
    JR      Z, LOC_819A                 ; if zero, go to level start
    LD      A, $03                      ; A = 3
    LD      ($705B), A                  ; player lives = 3 (reset on new game)

; ; ---- LEVEL START ----
; ; LOC_819A -- draw cave, init sprites, enter game loop.
; ;   DELAY_LOOP_AADB draws 10 RLE cave column strips to VRAM (name table).
; ;   SUB_8792 renders the level number (1-based $72A9+1) on screen.
LOC_819A:
    CALL    SUB_83CE                    ; set VDP backdrop color (collision flag)
    CALL    DELAY_LOOP_AADB             ; draw 10 RLE cave column strips to VRAM
    CALL    SUB_81B5                    ; init game-state variables for new level
    CALL    SUB_8792                    ; render level number on screen ($72A9+1)
    CALL    SUB_881E                    ; update lives display
    CALL    SUB_8831                    ; write color attribute table to VRAM
    CALL    DELAY_LOOP_AA1B             ; draw player sprite tiles based on direction
    CALL    SOUND_WRITE_8CDA            ; set player/enemy sprite animation positions
    JP      LOC_9084                    ; place player sprite at level-start position

SUB_81B5:
    LD      DE, $1C00                   ; DE = VRAM address $1C00 (sprite pattern table)
    LD      HL, $7079                   ; HL -> VRAM write buffer
    LD      (HL), $D0                   ; write $D0 to buffer (sprite pattern tile index)
    LD      C, $01                      ; count = 1 byte
    CALL    SOUND_WRITE_86FA            ; flush buffer to VRAM at DE=$1C00
    XOR     A                           ; A = 0
    LD      ($7292), A                  ; $7292 = 0 (score accumulator high byte)
    LD      ($7293), A                  ; $7293 = 0 (score accumulator low byte)
    LD      ($7285), A                  ; $7285 = 0 (enemy-visible flag)
    CPL                                 ; A = $FF
    LD      ($718E), A                  ; $718E = $FF (cave-entrance animation reset)
    CALL    SUB_AEE6                    ; enemy struct init (uses level tables)
    CALL    SOUND_WRITE_929D            ; set animation dispatch flag $71D3=$FF
    CALL    LOC_9BF7                    ; trigger propeller wing-flap sound + frame select
    CALL    SUB_9013                    ; init fuel-tank sprites at $71A3/$71A9
    CALL    SUB_8BCC                    ; init miner sprite at $71AF
    CALL    SUB_8B7D                    ; init dynamite sprite at $71CD
    LD      A, (CONTROLLER_BUFFER)     ; A = controller state
    AND     A                           ; test if zero
    RET     Z                           ; return if zero (normal mode, no special flags)
    CALL    SUB_81ED                    ; load per-level init flags from table
    JP      LOC_8539                    ; process per-level init flags (bits 0,1,3)

SUB_81ED:
    LD      HL, $B748                   ; HL -> LEVEL_ENEMY_OFFSET_TABLE
    LD      A, ($72A9)                  ; A = current level index
    CALL    SUB_869D                    ; A = offset for this level (B748[level])
    LD      HL, $8038                   ; HL -> per-level flag table in cart header
    CALL    SUB_869D                    ; A = flag byte for this level
    LD      A, ($72AA)                  ; A = difficulty cycle counter
    JP      SUB_869D                    ; A = ROM[$8038 + offset + $72AA] (init flags)

LOC_8202:
    LD      A, (CONTROLLER_BUFFER)     ; A = controller state
    AND     A                           ; test if zero
    RET     Z                           ; return if zero (not in game mode)
    LD      A, ($71BC)                  ; A = player vertical motion state
    AND     A                           ; test if zero
    LD      A, $02                      ; A = 2 (flag value for level-complete path)
    JP      M, LOC_8539                 ; if $71BC negative (moving up), branch
    LD      A, $08                      ; A = 8 (flag value for alternate path)
    JP      LOC_8539                    ; process level flags with A=8

SUB_8215:
    LD      A, ($7077)                  ; A = game-over / screen-flash flag
    AND     A                           ; test if nonzero
    JR      NZ, LOC_823A               ; if nonzero, skip main game logic (game over)
    CALL    SUB_9231                    ; update animation dispatch state machine
    LD      HL, ($7067)                 ; HL = frame counter (16-bit)
    INC     HL                          ; increment frame counter
    LD      ($7067), HL                 ; store updated frame counter
    CALL    SUB_8351                    ; per-frame explosion / death anim driver
    CALL    SUB_A373                    ; write score display tiles to VRAM
    CALL    SUB_A80B                    ; enemy appear / death animation dispatch
    CALL    SUB_A801                    ; update enemy sprite in VRAM name table
    CALL    SUB_A402                    ; update mine-contact sound state
    CALL    SUB_A484                    ; update player movement physics flags
    CALL    SUB_928C                    ; update animation sub-state for corridor

LOC_823A:
    CALL    POLLER                      ; BIOS: read controller ports into JOYSTICK_BUFFER
    CALL    SUB_8659                    ; decode controller input -> game action flags
    LD      A, ($7077)                  ; A = game-over flag
    AND     A                           ; test if nonzero
    RET     NZ                          ; return if game-over screen is showing
    CALL    SUB_858D                    ; update player gravity/momentum timer
    CALL    DELAY_LOOP_9214             ; update all 9 sprite structs (physics step)
    CALL    SUB_859D                    ; process landing timer / floor collision
    CALL    SUB_8C10                    ; animate cave entrance tiles
    CALL    SUB_A50D                    ; check player-vs-enemy collision
    CALL    SUB_A64A                    ; check projectile-vs-enemy collision
    CALL    SUB_97A0                    ; update propeller/rotor animation state
    CALL    SUB_82B3                    ; update wing-flap sound timer
    CALL    SUB_828D                    ; update score counter / level-advance logic
    CALL    SUB_82F8                    ; check fuel pickup / score thresholds
    CALL    SUB_82C8                    ; update propeller sound trigger
    CALL    SUB_AD9F                    ; update enemy path-find / movement frame
    CALL    SOUND_WRITE_A312            ; update scrolling score display in HUD
    CALL    SUB_8D74                    ; update mine-proximity sensor state
    CALL    SUB_A720                    ; update all projectile sprite positions
    CALL    SOUND_WRITE_A7A3            ; update projectile mask / visibility
    CALL    SUB_827B                    ; check idle-demo timer (15-frame timeout)
    JP      LOC_889B                    ; jump to per-frame sound update

SUB_827B:
    LD      HL, $7067                   ; HL -> frame counter low byte
    LD      A, (HL)                     ; A = frame counter low byte
    INC     HL                          ; HL -> frame counter high byte
    OR      (HL)                        ; A = low | high (nonzero if any frame counted)
    RET     NZ                          ; return if frame counter nonzero
    LD      HL, $7078                   ; HL -> idle-demo frame counter
    INC     (HL)                        ; increment idle counter
    LD      A, (HL)                     ; A = idle counter value
    CP      $0F                         ; compare to 15 (timeout threshold)
    JP      Z, LOC_862D                 ; if idle == 15, trigger demo/attract mode
    RET                                 ; return (not yet timed out)

SUB_828D:
    LD      A, ($7061)                  ; A = score-step countdown timer
    AND     A                           ; test if zero
    RET     Z                           ; return if no score step pending
    DEC     A                           ; decrement score-step timer
    LD      ($7061), A                  ; store updated timer
    RET     NZ                          ; return if timer not yet expired
    LD      A, ($705C)                  ; A = player score hundreds digit
    AND     A                           ; test if zero
    JP      Z, LOC_812C                 ; if zero score, advance to next level
    DEC     A                           ; decrement score digit
    LD      ($705C), A                  ; store decremented score
    CALL    CTRL_READ_88BD              ; trigger wall-hit sound (score tick beep)
    CALL    SUB_8831                    ; update color attribute table display
    LD      A, $0E                      ; A = 14 (next score-step delay)
    LD      ($7061), A                  ; reset score-step timer to 14 frames
    LD      DE, $0050                   ; DE = $0050 (score points value for display)
    JP      LOC_8720                    ; add DE to BCD score and update display

SUB_82B3:
    LD      A, ($7286)                  ; A = enemy respawn countdown timer
    AND     A                           ; test if zero
    RET     Z                           ; return if no respawn pending
    DEC     A                           ; decrement respawn timer
    LD      ($7286), A                  ; store updated timer
    JP      Z, LOC_A5EC                 ; if timer expired, trigger respawn sequence
    CP      $0F                         ; compare timer to 15
    RET     NZ                          ; return if not at threshold 15
    CALL    SUB_A598                    ; enemy movement step (mid-respawn)
    JP      LOC_A872                    ; clear sprite buffer, flush to VRAM

SUB_82C8:
    LD      A, ($72C4)                  ; A = player physics/motion flags
    AND     $02                         ; test bit 1 (propeller-active flag)
    RET     Z                           ; return if propeller not active
    LD      A, ($7067)                  ; A = frame counter low byte
    AND     $07                         ; keep lower 3 bits (0-7 cycle)
    CP      $05                         ; compare to 5
    CALL    Z, SOUND_WRITE_82DB         ; if frame & 7 == 5, trigger wing-flap sound
    JP      LOC_9BD9                    ; set animation dispatch flag $71D6=$FF

SOUND_WRITE_82DB:
    LD      A, ($72C4)                  ; A = player physics/motion flags
    AND     $02                         ; test bit 1 (propeller-active)
    RET     Z                           ; return if propeller not active
    LD      A, ($7067)                  ; A = frame counter low byte
    AND     $08                         ; test bit 3 (alternate flap phase)
    LD      A, $60                      ; A = $60 (tone value for flap-up)
    LD      C, $00                      ; C = 0 (pitch modifier for flap-up)
    JR      NZ, LOC_82F0               ; if bit 3 set, use flap-down values
    LD      A, $80                      ; A = $80 (tone value for flap-down)
    LD      C, $FF                      ; C = $FF (pitch modifier for flap-down)

LOC_82F0:
    LD      ($7244), A                  ; $7244 = tone register value for wing-flap
    LD      A, C                        ; A = pitch modifier
    LD      ($7062), A                  ; $7062 = pitch modifier byte
    RET                                 ; return

SUB_82F8:
    LD      HL, $7292                   ; HL -> score accumulator high byte
    LD      B, $05                      ; B = 5 (threshold parameter)
    CALL    SUB_8305                    ; check $7292 >= $B4 (fuel pickup)
    LD      HL, $7293                   ; HL -> score accumulator low byte
    LD      B, $04                      ; B = 4 (alternate threshold)

SUB_8305:
    LD      A, (HL)                     ; A = score accumulator byte
    CP      $B4                         ; compare to $B4 (180 decimal)
    RET     C                           ; return if below threshold (no pickup yet)
    CALL    SUB_8A8A                    ; trigger player-death sound (fuel exhausted)
    LD      (HL), $00                   ; reset score accumulator to 0
    CALL    DELAY_LOOP_A4D4             ; check projectile collision with enemy
    JP      LOC_AE97                    ; update enemy VRAM display state

SUB_8314:
    LD      A, ($7063)                  ; A = explosion/death animation timer
    LD      HL, $7281                   ; HL -> player-on-ground flag
    OR      (HL)                        ; A = timer | ground-flag (zero if both clear)
    RET     NZ                          ; return if animation active or on ground
    LD      A, ($705C)                  ; A = player score hundreds digit (fuel level)
    AND     A                           ; test if zero (no fuel)
    RET     Z                           ; return if no fuel remaining
    LD      A, ($7270)                  ; A = player X position
    LD      ($7066), A                  ; $7066 = player X (save for collision compare)
    ADD     A, $03                      ; A += 3 (X + 3 = right edge of player hitbox)
    LD      ($72A2), A                  ; $72A2 = player right-edge X
    LD      A, ($7271)                  ; A = player Y position
    LD      ($72A3), A                  ; $72A3 = player Y position
    XOR     A                           ; A = 0
    LD      ($72A4), A                  ; $72A4 = 0 (projectile state reset)
    LD      ($7064), A                  ; $7064 = 0 (explosion hit flag)
    LD      A, ($72AA)                  ; A = difficulty cycle counter
    LD      ($7065), A                  ; $7065 = current difficulty cycle
    LD      A, $2E                      ; A = $2E (46 frames for explosion anim)
    LD      ($7063), A                  ; $7063 = 46 (start explosion/death timer)
    LD      HL, $705C                   ; HL -> player score hundreds digit
    DEC     (HL)                        ; decrement fuel/score digit
    CALL    SUB_8831                    ; update color attribute display
    CALL    LOC_8416                    ; check dynamic object flag, trigger if set
    JP      LOC_894D                    ; start explosion sound (channel 2+3)

SUB_8351:
    LD      A, ($7063)                  ; A = explosion/death animation timer
    AND     A                           ; test if zero
    RET     Z                           ; return if no animation active
    DEC     A                           ; decrement animation timer
    LD      ($7063), A                  ; store updated timer
    LD      HL, $AB1B                   ; HL -> explosion frame table (upper half)
    CP      $11                         ; compare timer to 17
    JR      NC, LOC_8364               ; if timer >= 17, use upper-half table
    LD      HL, $AB12                   ; HL -> explosion frame table (lower half)

LOC_8364:
    PUSH    AF                          ; save current timer value
    SRL     A                           ; A >>= 1 (divide by 2 for frame index)
    AND     $03                         ; keep lower 2 bits (4-frame cycle)
    CALL    SUB_AA9E                    ; draw explosion strip tile to VRAM
    POP     AF                          ; restore timer value
    CP      $11                         ; compare to 17
    JR      Z, LOC_8394                 ; if timer == 17, clear collision state
    CP      $0F                         ; compare to 15
    JR      Z, LOC_838F                 ; if timer == 15, set collision flag
    CP      $0A                         ; compare to 10
    JR      Z, LOC_8394                 ; if timer == 10, clear collision state
    CP      $08                         ; compare to 8
    JR      Z, LOC_838F                 ; if timer == 8, set collision flag
    CP      $03                         ; compare to 3
    JR      Z, LOC_8387                 ; if timer == 3, check death flag
    CP      $01                         ; compare to 1
    JR      Z, LOC_838F                 ; if timer == 1, set collision flag
    JR      LOC_8397                    ; else continue to end-of-frame check

LOC_8387:
    LD      A, ($7064)                  ; A = explosion hit flag
    AND     A                           ; test if zero
    JR      Z, SUB_83D2                 ; if zero, clear collision (no hit scored)
    JR      LOC_8397                    ; else skip clear

LOC_838F:
    CALL    SUB_83CE                    ; set collision flag (C=1)
    JR      LOC_8397                    ; continue

LOC_8394:
    CALL    SUB_83D2                    ; clear collision state

LOC_8397:
    LD      A, ($7063)                  ; A = current animation timer
    CP      $11                         ; compare to 17 (mid-explosion trigger point)
    CALL    Z, SUB_8A8A                 ; if timer == 17, trigger bonus/score sound
    LD      A, ($7065)                  ; A = saved difficulty cycle at explosion start
    LD      C, A                        ; C = saved difficulty cycle
    LD      A, ($72AA)                  ; A = current difficulty cycle
    CP      C                           ; compare current to saved
    RET     NZ                          ; return if difficulty changed (enemy moved)
    LD      A, ($7063)                  ; A = animation timer
    CP      $18                         ; compare to 24
    JP      Z, LOC_8202                 ; if timer == 24, check level-complete
    CP      $0F                         ; compare to 15
    JP      Z, LOC_83D9                 ; if timer == 15, trigger player death sequence
    CP      $01                         ; compare to 1
    JP      Z, LOC_8416                 ; if timer == 1, trigger dynamic object
    RET                                 ; return
    DB      $3A, $63, $70, $A7, $C8, $FE, $10, $D8
    DB      $CD, $BA, $AF, $CD, $44, $A6, $AF, $32
    DB      $64, $70, $C9

SUB_83CE:
    LD      C, $01                      ; C = 1 (VDP backdrop color: set collision)
    JR      LOC_83D4                    ; jump to shared WRITE_REGISTER call

SUB_83D2:
    LD      C, $0F                      ; C = $0F (VDP backdrop color: clear collision)

LOC_83D4:
    LD      B, $07                      ; B = VDP register 7 (backdrop/border color)
    JP      WRITE_REGISTER              ; BIOS: write VDP reg 7 with value C

LOC_83D9:
    CALL    SUB_83E2                    ; check mine-sensor proximity condition
    CALL    SUB_AFBA                    ; process player-death: mine detonation check
    JP      LOC_A644                    ; go to projectile spawn at $7260

SUB_83E2:
    LD      A, ($7270)                  ; A = player X position
    LD      C, A                        ; C = player X
    LD      A, ($7066)                  ; A = saved X at explosion start
    CP      C                           ; compare saved X to current X
    RET     NZ                          ; return if X changed (player moved)
    LD      A, ($7294)                  ; A = collision/contact flag
    AND     A                           ; test if nonzero
    RET     NZ                          ; return if already in contact
    LD      A, ($726D)                  ; A = enemy Y position
    LD      HL, $72A3                   ; HL -> saved player Y
    SUB     (HL)                        ; A = enemy Y - player Y (signed difference)
    JP      P, LOC_83FC                 ; if positive (enemy below player), branch

    NEG                                 ; negate: A = |enemy Y - player Y|

LOC_83FC:
    CP      $12                         ; compare |delta Y| to 18 pixels
    RET     NC                          ; return if too far apart (no proximity trigger)
    LD      A, $04                      ; A = 4 (spawn mode flag)
    LD      ($7288), A                  ; $7288 = 4 (enemy spawn-mode parameter)
    XOR     A                           ; A = 0
    JP      LOC_A55A                    ; spawn / respawn enemy entity

SOUND_WRITE_8408:
    LD      A, ($7063)                  ; A = explosion/death animation timer
    SUB     $03                         ; A -= 3 (reduce timer by 3 frames)
    LD      ($7063), A                  ; store reduced timer
    LD      A, $FF                      ; A = $FF
    LD      ($7064), A                  ; $7064 = $FF (mark explosion hit scored)
    RET                                 ; return

LOC_8416:
    LD      A, ($723E)                  ; A = dynamic-object active flag
    AND     A                           ; test if zero
    RET     Z                           ; return if no dynamic object active
    JP      LOC_9BF7                    ; trigger propeller + enemy frame select

NMI:
    PUSH    AF                          ; save AF on stack (NMI entry: preserve main regs)
    PUSH    BC                          ; save BC
    PUSH    DE                          ; save DE
    PUSH    HL                          ; save HL
    PUSH    IX                          ; save IX
    PUSH    IY                          ; save IY
    EX      AF, AF'                     ; swap to alternate AF'
    EXX                                 ; swap BC/DE/HL with alternate register set
    PUSH    AF                          ; save alternate AF
    PUSH    BC                          ; save alternate BC
    PUSH    DE                          ; save alternate DE
    PUSH    HL                          ; save alternate HL
    LD      A, ($706B)                  ; A = VRAM-write-in-progress flag
    AND     A                           ; test if nonzero
    JR      NZ, LOC_8438               ; if VRAM write active, skip VDP status read
    CALL    READ_REGISTER               ; BIOS: read VDP status register -> A
    LD      ($706A), A                  ; $706A = VDP status byte (save for later)

LOC_8438:
    CALL    SUB_88AC                    ; per-frame sound update (death/contact/explosion)
    LD      A, ($7069)                  ; A = game-loop-running flag
    CP      $27                         ; compare to $27 (sentinel value)
    LD      A, $00                      ; A = 0 (pre-load zero for flag clear)
    LD      ($7069), A                  ; clear game-loop flag
    CALL    Z, SUB_8215                 ; if flag was $27, run one frame of game logic
    POP     HL                          ; restore alternate HL
    POP     DE                          ; restore alternate DE
    POP     BC                          ; restore alternate BC
    POP     AF                          ; restore alternate AF
    EXX                                 ; restore BC/DE/HL from alternate set
    EX      AF, AF'                     ; restore AF from alternate
    POP     IY                          ; restore IY
    POP     IX                          ; restore IX
    POP     HL                          ; restore HL
    POP     DE                          ; restore DE
    POP     BC                          ; restore BC
    POP     AF                          ; restore AF
    RET                                 ; return from NMI (resumes interrupted code)
    DB      $5F, $84, $69, $84, $F8, $84, $D9, $85
    DB      $A7, $C4, $1D, $86, $32, $6C, $70, $C3
    DB      $89, $84, $A7, $C4, $1D, $86, $32, $6D
    DB      $70, $CB, $40, $20, $15, $3A, $2B, $70
    DB      $A7, $C0, $21, $6D, $70, $7E, $A7, $36
    DB      $00, $C8, $3A, $9B, $71, $A7, $C0, $C3
    DB      $BC, $84, $21, $6C, $70, $7E, $23, $B6
    DB      $23, $BE, $20, $06, $C9

SUB_8494:
    LD      A, ($706E)                  ; A = floor-collision flag
    AND     A                           ; test if zero
    RET     Z                           ; return if no floor collision active
    LD      ($706E), A                  ; refresh floor-collision flag (no change)
    LD      A, (CONTROLLER_BUFFER)     ; A = controller state
    AND     A                           ; test if zero
    RET     NZ                          ; return if controller not active (demo mode)
    LD      A, ($719C)                  ; A = hero-entry-animation active flag
    AND     A                           ; test if nonzero
    JR      Z, LOC_84AD                 ; if zero, skip entry anim cleanup
    CALL    SUB_90ED                    ; clear entry-animation state, reset hero sprite
    CALL    SUB_851C                    ; process floor-contact physics / rescue check

LOC_84AD:
    LD      A, ($719B)                  ; A = player-in-flight flag
    AND     A                           ; test if nonzero
    RET     NZ                          ; return if player still airborne
    LD      A, ($706E)                  ; A = floor-collision flag
    AND     A                           ; test if zero
    JP      Z, SUB_A70E                 ; if zero, run normal sprite physics update
    JP      LOC_A715                    ; else run landing / thrust-off sequence

SUB_84BC:
    LD      A, ($7294)                  ; A = collision/contact flag
    AND     A                           ; test if nonzero
    RET     NZ                          ; return if already in contact
    LD      A, ($705C)                  ; A = score/fuel digit
    AND     A                           ; test if zero
    RET     Z                           ; return if no fuel (no enemy to spawn)
    LD      A, ($72AA)                  ; A = difficulty cycle counter
    LD      C, A                        ; C = difficulty cycle
    LD      A, ($72C5)                  ; A = enemy-active threshold
    CP      C                           ; compare threshold to difficulty cycle
    RET     Z                           ; return if at threshold (enemy already active)
    LD      A, ($726D)                  ; A = enemy Y position
    ADD     A, $04                      ; A += 4 (bottom edge of enemy hitbox)
    LD      C, A                        ; C = enemy bottom Y
    LD      A, ($726C)                  ; A = enemy X position
    ADD     A, $24                      ; A += 36 (right edge offset)
    LD      B, A                        ; B = enemy right X
    PUSH    BC                          ; save BC (enemy hitbox edges)
    CALL    SUB_8ECE                    ; check proximity / collision for point B,C
    POP     BC                          ; restore BC
    JR      C, LOC_84EB                 ; if carry (collision), trigger spawn
    LD      A, C                        ; A = enemy bottom Y
    ADD     A, $08                      ; A += 8 (extend hitbox further)
    LD      C, A                        ; C = extended bottom Y
    LD      A, B                        ; A = enemy right X
    CALL    SUB_8ECE                    ; check extended hitbox collision
    RET     NC                          ; return if no collision

LOC_84EB:
    CALL    SUB_8314                    ; trigger explosion/death sequence
    JP      LOC_8202                    ; check level-complete condition

SUB_84F1:
    LD      B, $00                      ; B = 0 (collision result pre-cleared)
    LD      A, ($706F)                  ; A = player landing / miner-rescue flags
    AND     A                           ; test if zero
    RET     Z                           ; return if no landing/rescue pending
    AND     A                           ; test again (NZ used for conditional call)
    CALL    NZ, SUB_861D                ; if nonzero, reset idle counter + redraw
    LD      C, A                        ; C = result from SUB_861D (new flag byte)
    LD      A, B                        ; A = B (0 = no collision scored)
    LD      ($7070), A                  ; $7070 = 0 (collision-scored flag)
    LD      A, ($706F)                  ; A = landing/rescue flags (fresh read)
    LD      ($7071), A                  ; $7071 = landing flags (save copy)
    LD      A, C                        ; A = new flag byte from SUB_861D
    LD      ($706F), A                  ; $706F = updated landing/rescue flags
    LD      A, (CONTROLLER_BUFFER)     ; A = controller state
    AND     A                           ; test if zero
    RET     NZ                          ; return if not in game mode
    LD      A, ($719C)                  ; A = hero-entry-animation active flag
    AND     A                           ; test if nonzero
    JR      Z, SUB_851C                 ; if zero, skip entry anim (go to physics)
    CALL    SUB_90ED                    ; clear entry-animation state
    CALL    LOC_84AD                    ; process floor-contact / flight check

SUB_851C:
    LD      A, ($719B)                  ; A = player-in-flight flag
    AND     A                           ; test if nonzero
    RET     NZ                          ; return if player still airborne
    LD      A, ($7070)                  ; A = collision-scored flag
    BIT     0, A                        ; test bit 0 (rescue-scored flag)
    JR      Z, LOC_8536                 ; if bit 0 clear, skip rescue check
    LD      A, ($706F)                  ; A = current landing/rescue flags
    LD      C, A                        ; C = current flags
    LD      A, ($7071)                  ; A = saved flags
    CPL                                 ; A = ~saved flags (inverted)
    AND     C                           ; A = new bits only (changed from saved)
    BIT     2, A                        ; test bit 2 (miner-rescue bit)
    CALL    NZ, SUB_84BC                ; if bit 2 set, check miner proximity/spawn

LOC_8536:
    LD      A, ($706F)                  ; A = current landing/rescue flags

LOC_8539:
    LD      C, A                        ; C = flags byte
    LD      A, $01                      ; A = 1 (positive direction value)
    BIT     0, C                        ; test bit 0 (direction flag)
    JR      NZ, LOC_8542               ; if bit 0 set, keep A=1 (rightward)
    NEG                                 ; A = -1 (negative direction: leftward)

LOC_8542:
    LD      ($71C2), A                  ; $71C2 = direction value (+1 or -1)
    BIT     1, C                        ; test bit 1 (vertical motion flag)
    LD      A, $00                      ; A = 0 (pre-load for NZ branch)
    LD      B, $0F                      ; B = $0F (VDP color for collision set)
    JR      NZ, LOC_8555               ; if bit 1 set, apply vertical motion
    BIT     3, C                        ; test bit 3 (landing/rescue complete flag)
    LD      A, $07                      ; A = $07 (velocity for landing)
    LD      B, $F1                      ; B = $F1 (VDP color for landing state)
    JR      Z, LOC_8573                 ; if bit 3 clear, go to player death handler

LOC_8555:
    LD      ($7074), A                  ; $7074 = motion direction (0 or up)
    LD      A, B                        ; A = B (VDP color value)
    LD      ($71BC), A                  ; $71BC = player vertical motion state
    XOR     A                           ; A = 0
    LD      ($7072), A                  ; $7072 = 0 (player movement state reset)
    LD      A, ($7281)                  ; A = player-on-ground flag
    AND     A                           ; test if nonzero
    RET     NZ                          ; return if already on ground
    CALL    DELAY_LOOP_AA1B             ; draw player sprite tiles based on direction
    CALL    SUB_8BE6                    ; init player re-entry sprite at $71C7
    LD      A, $06                      ; A = 6 (re-entry timer value)
    LD      ($7073), A                  ; $7073 = 6 (gravity/momentum timer)
    JP      LOC_8578                    ; set motion parameters

LOC_8573:
    LD      A, $FF                      ; A = $FF
    LD      ($7072), A                  ; $7072 = $FF (player death / respawn state)

LOC_8578:
    LD      C, $08                      ; C = 8 (velocity magnitude)

LOC_857A:
    LD      HL, $71BC                   ; HL -> player vertical motion state
    LD      A, (HL)                     ; A = current vertical motion state
    AND     A                           ; test if zero
    RET     Z                           ; return if motion state is zero
    CP      $80                         ; compare to $80 (downward threshold)
    LD      A, C                        ; A = velocity magnitude
    JR      C, LOC_8587                 ; if < $80, upward motion (positive)
    NEG                                 ; A = -C (downward velocity)

LOC_8587:
    LD      (HL), A                     ; $71BC = signed velocity value
    RET                                 ; return

LOC_8589:
    LD      C, $0F                      ; C = $0F (gravity velocity)
    JR      LOC_857A                    ; apply velocity to $71BC

SUB_858D:
    LD      A, ($7073)                  ; A = gravity/momentum timer
    AND     A                           ; test if zero
    RET     Z                           ; return if timer expired
    DEC     A                           ; decrement timer
    LD      ($7073), A                  ; store updated timer
    LD      HL, $7072                   ; HL -> player movement state
    OR      (HL)                        ; A = timer | movement state
    RET     NZ                          ; return if either nonzero
    JR      LOC_8589                    ; apply gravity velocity

SUB_859D:
    LD      A, (CONTROLLER_BUFFER)     ; A = controller state
    AND     A                           ; test if zero
    RET     Z                           ; return if not in game mode
    LD      A, ($7060)                  ; A = landing delay timer
    AND     A                           ; test if zero
    JR      Z, LOC_85BF                 ; if zero, process timeout counter
    DEC     A                           ; decrement landing timer
    LD      ($7060), A                  ; store updated timer
    RET     NZ                          ; return if timer still counting
    CALL    SUB_84F1                    ; process player landing / miner rescue
    CALL    SUB_8494                    ; check cave-floor collision
    LD      A, (CONTROLLER_BUFFER)     ; A = controller state
    AND     A                           ; test if zero
    RET     Z                           ; return if not in game mode
    LD      HL, $0834                   ; HL = $0834 (score display pointer)
    LD      ($7075), HL                 ; $7075 = $0834 (pending score display)
    RET                                 ; return

LOC_85BF:
    LD      HL, ($7075)                 ; HL = pending transition counter
    LD      A, H                        ; A = high byte
    OR      L                           ; A = H|L (zero if HL=0)
    RET     Z                           ; return if counter already zero
    DEC     HL                          ; decrement counter
    LD      ($7075), HL                 ; store decremented counter
    LD      A, H                        ; A = high byte
    OR      L                           ; A = H|L
    RET     NZ                          ; return if not yet zero
    JP      LOC_8074                    ; re-initialize VDP and restart level loop
    DB      $01, $05, $09, $0D, $11, $AF, $32, $5A
    DB      $70, $C9, $FE, $0F, $28, $F7, $4F, $3A
    DB      $5A, $70, $A7, $C0, $3E, $FF, $32, $5A
    DB      $70, $79, $FE, $06, $28, $2B, $FE, $01
    DB      $38, $1C, $FE, $06, $30, $18, $32, $2D
    DB      $70, $3D, $21, $CF, $85, $CD, $9D, $86
    DB      $3D, $32, $2C, $70, $AF, $32, $2B, $70
    DB      $CD, $1D, $86, $C3, $74, $80, $FE, $0A
    DB      $CA, $2D, $86, $FE, $0B, $CA, $1D, $86
    DB      $C9, $3A, $2D, $70, $18, $DB

SUB_861D:
    PUSH    AF                          ; save AF
    PUSH    BC                          ; save BC
    XOR     A                           ; A = 0
    LD      ($7078), A                  ; $7078 = 0 (idle-demo counter reset)
    LD      A, ($7077)                  ; A = game-over flag
    AND     A                           ; test if nonzero
    CALL    NZ, SUB_8630                ; if nonzero, re-enable display
    POP     BC                          ; restore BC
    POP     AF                          ; restore AF
    RET                                 ; return

LOC_862D:
    JP      LOC_863E                    ; jump to attract-mode trigger

SUB_8630:
    LD      B, $01                      ; B = VDP register 1
    LD      C, $A2                      ; C = $A2 (enable display, sprites on)
    CALL    WRITE_REGISTER              ; BIOS: write VDP reg 1 = $A2 (display on)
    XOR     A                           ; A = 0
    LD      ($7077), A                  ; $7077 = 0 (clear game-over flag)
    JP      LOC_927F                    ; set animation dispatch flag $71D8=$FF

LOC_863E:
    CALL    SUB_83CE                    ; set VDP backdrop color (collision)
    LD      B, $01                      ; B = VDP register 1
    LD      C, $A2                      ; C = $A2 (enable display)
    CALL    WRITE_REGISTER              ; BIOS: write VDP reg 1 = $A2
    LD      A, $FF                      ; A = $FF
    LD      ($7077), A                  ; $7077 = $FF (set attract/game-over flag)
    JP      TURN_OFF_SOUND              ; BIOS: silence all channels
    DB      $02, $07, $05, $0A, $03, $08, $06, $0B
    DB      $00

SUB_8659:
    LD      HL, $8650                   ; HL -> controller button mapping table
    LD      IX, $8457                   ; IX -> action dispatch address table

LOC_8660:
    LD      B, $00                      ; B = 0 (button index)

LOC_8662:
    LD      A, (HL)                     ; A = button code (0 = end of table)
    AND     A                           ; test if zero
    JR      Z, LOC_8691                 ; if zero, copy shadow and return
    INC     HL                          ; advance past button code
    PUSH    HL                          ; save table pointer
    LD      HL, JOYSTICK_BUFFER         ; HL -> $7031 raw controller input
    CALL    SUB_869D                    ; A = JOYSTICK_BUFFER[button code]
    LD      DE, $001D                   ; DE = 29 (offset to shadow buffer)
    ADD     HL, DE                      ; HL -> $704E (previous-frame shadow)
    CP      (HL)                        ; compare current to previous frame
    JR      Z, LOC_8684                 ; if unchanged, skip dispatch
    LD      E, (IX+0)                   ; E = action handler address low
    LD      D, (IX+1)                   ; D = action handler address high
    PUSH    BC                          ; save BC
    PUSH    IX                          ; save IX
    CALL    SUB_9212                    ; call action handler at DE
    POP     IX                          ; restore IX
    POP     BC                          ; restore BC

LOC_8684:
    POP     HL                          ; restore table pointer
    INC     B                           ; B++ (next button slot)
    LD      A, B                        ; A = slot index
    CP      $02                         ; compare to 2 (two buttons per entry)
    JR      C, LOC_8662                 ; loop for 2 buttons
    INC     IX                          ; advance IX (skip action address low)
    INC     IX                          ; advance IX (skip action address high)
    JR      LOC_8660                    ; next button entry

LOC_8691:
    LD      HL, $7033                   ; HL -> current joystick state buffer
    LD      DE, $7050                   ; DE -> previous-frame shadow buffer
    LD      BC, $000A                   ; BC = 10 bytes to copy
    LDIR                                ; copy current state -> previous shadow
    RET                                 ; return

SUB_869D:
    ADD     A, L                        ; L += A (compute table address low byte)
    LD      L, A                        ; L = updated low byte
    JR      NC, LOC_86A2               ; skip if no carry from addition
    INC     H                           ; H++ (carry into high byte)

LOC_86A2:
    LD      A, (HL)                     ; A = ROM[HL+A] (table lookup result)
    RET                                 ; return

DELAY_LOOP_86A4:
    PUSH    BC                          ; save BC
    LD      B, C                        ; B = count (number of bytes to write)

LOC_86A6:
    LD      (DE), A                     ; write fill byte A to [DE]
    INC     DE                          ; advance destination pointer
    DJNZ    LOC_86A6                    ; loop C times
    POP     BC                          ; restore BC
    RET                                 ; return (DE[0..C-1] filled with A)

DELAY_LOOP_86AC:
    PUSH    BC                          ; save BC
    PUSH    HL                          ; save HL
    LD      L, C                        ; L = count
    LD      H, $00                      ; H = 0 (HL = count as 16-bit)
    PUSH    DE                          ; save DE (source)
    DB      $EB                         ; EX DE,HL (DE=count, HL=source)
    AND     A                           ; clear carry for SBC
    SBC     HL, DE                      ; HL = source - count (base address)
    POP     DE                          ; restore DE

LOC_86B7:
    PUSH    BC                          ; save outer counter
    LD      B, $00                      ; B = 0 (LDIR block size high)
    PUSH    HL                          ; save source pointer
    LDIR                                ; copy block (timed fill for sound sync)
    POP     HL                          ; restore source
    POP     BC                          ; restore outer counter
    DJNZ    LOC_86B7                    ; repeat B times
    POP     HL                          ; restore HL
    POP     BC                          ; restore BC
    RET                                 ; return

SUB_86C4:
    PUSH    DE                          ; save DE (caller-supplied VRAM address)
    JR      LOC_86CB                    ; enter RLE decoder with caller DE

SUB_86C7:
    PUSH    DE                          ; save DE
    LD      DE, $7079                   ; DE -> VRAM write buffer ($7079)

LOC_86CB:
    LD      A, (HL)                     ; A = next RLE token byte
    INC     HL                          ; advance source pointer
    AND     A                           ; test if zero (end-of-stream)
    JR      Z, LOC_86E5                 ; if zero, finalize and return
    BIT     7, A                        ; test bit 7 (literal-block flag)
    JR      NZ, LOC_86DC               ; if set, literal block follows
    LD      C, A                        ; C = run length (1-127)
    LD      A, (HL)                     ; A = fill byte for this run
    INC     HL                          ; advance past fill byte
    CALL    DELAY_LOOP_86A4             ; write C copies of A to [DE]
    JR      LOC_86CB                    ; process next RLE token

LOC_86DC:
    AND     $7F                         ; strip bit 7 -> A = literal byte count
    LD      C, A                        ; C = count
    LD      B, $00                      ; B = 0 (BC = count for LDIR)
    LDIR                                ; copy C literal bytes from HL to DE
    JR      LOC_86CB                    ; process next token

LOC_86E5:
    PUSH    HL                          ; save HL (position after stream end)
    LD      HL, $8F87                   ; HL = $8F87 (buffer-end sentinel)
    ADD     HL, DE                      ; HL = $8F87 + DE (bytes written = buffer size)
    LD      C, L                        ; C = low byte = byte count in buffer
    POP     HL                          ; restore HL
    POP     DE                          ; restore caller DE
    RET                                 ; return (C = bytes decoded into buffer)
    DB      $C5, $E5, $0E, $08, $18, $0B, $C5, $E5
    DB      $0E, $30, $18, $05


SOUND_WRITE_86FA:
    PUSH    BC                          ; save BC
    PUSH    HL                          ; save HL
    LD      HL, $7079                   ; HL -> VRAM write buffer (decoded data)
    PUSH    DE                          ; save DE (destination VRAM address)
    LD      B, $00                      ; B = 0 (high byte of byte count)
    PUSH    BC                          ; save BC (count)
    PUSH    IX                          ; save IX
    LD      A, $FF                      ; A = $FF
    LD      ($706B), A                  ; $706B = $FF (VRAM-write-in-progress flag)
    CALL    WRITE_VRAM                  ; BIOS: write C bytes from HL to VRAM at DE
    XOR     A                           ; A = 0
    LD      ($706B), A                  ; $706B = 0 (clear VRAM-write flag)
    CALL    READ_REGISTER               ; BIOS: read VDP status -> A
    LD      ($706A), A                  ; $706A = VDP status byte (save)
    POP     IX                          ; restore IX
    POP     BC                          ; restore BC (count)
    POP     HL                          ; restore HL (buffer pointer after write)
    ADD     HL, BC                      ; HL += BC (advance past written bytes)
    DB      $EB                         ; EX DE,HL (DE = new buffer pos, HL = VRAM addr)
    POP     HL                          ; restore HL
    POP     BC                          ; restore BC
    RET                                 ; return

LOC_8720:
    LD      A, (CONTROLLER_BUFFER)     ; A = controller state
    LD      HL, $717C                   ; HL -> score-lock flag
    OR      (HL)                        ; A = controller | score-lock (zero if both clear)
    RET     NZ                          ; return if locked or not in game mode
    LD      HL, $7179                   ; HL -> BCD score buffer (6 digits at $7179-$717E)
    LD      C, A                        ; C = 0 (carry accumulator)
    LD      A, E                        ; A = low byte of points to add
    AND     A                           ; clear carry
    CALL    SUB_8762                    ; BCD add E to score digit at HL
    LD      A, D                        ; A = high byte of points
    CALL    SUB_8762                    ; BCD add D to next score digit
    LD      A, $00                      ; A = 0 (zero for final carry propagation)
    CALL    SUB_8762                    ; propagate carry into top digit
    LD      A, C                        ; A = carry/extra-life flag
    BIT     0, A                        ; test bit 0 (score-overflow / extra life)
    JR      Z, LOC_8744                 ; if no overflow, skip score-lock
    LD      A, $FF                      ; A = $FF
    LD      ($717C), A                  ; $717C = $FF (lock score display)

LOC_8744:
    LD      A, C                        ; A = carry flag byte
    BIT     1, A                        ; test bit 1 (extra-life earned flag)
    JR      Z, LOC_8760                 ; if no extra life, skip
    LD      A, ($717B)                  ; A = extra-life inhibit flag
    BIT     0, A                        ; test bit 0 (inhibit already set)
    JR      NZ, LOC_8760               ; if inhibited, skip extra life grant
    LD      A, ($705B)                  ; A = player lives count
    CP      $06                         ; compare to 6 (max lives)
    JR      NC, LOC_8760               ; if at max, skip extra life
    INC     A                           ; A++ (grant extra life)
    LD      ($705B), A                  ; store updated lives count
    PUSH    BC                          ; save BC
    CALL    SUB_881E                    ; update lives display
    POP     BC                          ; restore BC

LOC_8760:
    JR      SUB_876C                    ; update score / high-score display

SUB_8762:
    ADC     A, (HL)                     ; A = A + [HL] + carry (BCD add)
    DAA                                 ; decimal adjust A (BCD correction)
    LD      (HL), A                     ; store BCD digit back to score buffer
    RL      C                           ; rotate carry into C (tracks overflow)
    LD      B, C                        ; B = carry accumulator
    SRL     B                           ; B >>= 1 (isolate carry flag)
    INC     HL                          ; HL++ (advance to next score digit)
    RET                                 ; return

SUB_876C:
    LD      A, (CONTROLLER_BUFFER)     ; A = controller state
    AND     A                           ; test if zero
    RET     NZ                          ; return if not in game mode
    LD      A, ($717C)                  ; A = score-lock flag
    AND     A                           ; test if nonzero (score being animated)
    JR      NZ, LOC_8789               ; if locked, display fixed score
    LD      IX, $1AB2                   ; IX = VRAM address $1AB2 (score display area)
    LD      DE, $707F                   ; DE -> score digit render buffer
    LD      HL, $7179                   ; HL -> BCD score buffer
    LD      C, $06                      ; C = 6 (number of score digits)
    JP      LOC_87C8                    ; convert BCD digits and write to VRAM
    DB      $06, $0C, $00

LOC_8789:
    LD      HL, $8786                   ; HL -> fixed score display data
    LD      DE, $1AB2                   ; DE = VRAM address $1AB2 (score display)
    JP      SUB_98D4                    ; RLE decode + flush to VRAM

SUB_8792:
    LD      A, (CONTROLLER_BUFFER)     ; A = controller state
    AND     A                           ; test if zero
    RET     NZ                          ; return if not in game mode
    LD      A, ($705F)                  ; A = level-wrap flag
    AND     A                           ; test if nonzero
    JR      NZ, LOC_87BF               ; if wrapped, display special level indicator
    LD      A, ($702D)                  ; A = special-mode flag
    CP      $05                         ; compare to $05 (special mode)
    JR      Z, LOC_87BF                 ; if special mode, display special indicator
    LD      HL, $717D                   ; HL -> level-number display buffer
    LD      A, ($72A9)                  ; A = current level index (0-19)
    INC     A                           ; A++ (1-based level number for display)
    CALL    DELAY_LOOP_87F9             ; convert A to BCD (binary -> BCD)
    LD      (HL), A                     ; store BCD level number in display buffer
    LD      IX, $1AAC                   ; IX = VRAM address $1AAC (level display area)
    LD      DE, $707B                   ; DE -> level digit render buffer
    LD      C, $02                      ; C = 2 (two digits for level number)
    JP      LOC_87C8                    ; convert and write to VRAM
    DB      $82, $14, $15, $00

LOC_87BF:
    LD      HL, $87BB                   ; HL -> special level display data
    LD      DE, $1AAC                   ; DE = VRAM address $1AAC
    JP      SUB_98D4                    ; RLE decode + flush to VRAM

LOC_87C8:
    LD      B, C                        ; B = digit count
    SRL     B                           ; B >>= 1 (pairs: 2 nibbles per byte)
    XOR     A                           ; A = 0 (clear for RRD unpacking)

LOC_87CC:
    RRD                                 ; unpack high nibble of [HL] into A bits 3-0
    DEC     DE                          ; DE-- (write backwards into buffer)
    LD      (DE), A                     ; store digit
    RRD                                 ; unpack low nibble into A bits 3-0
    DEC     DE                          ; DE--
    LD      (DE), A                     ; store digit
    RRD                                 ; advance RRD state
    INC     HL                          ; advance source digit pointer
    DJNZ    LOC_87CC                    ; loop for B pairs
    PUSH    BC                          ; save BC
    LD      B, C                        ; B = total digit count
    LD      C, $00                      ; C = 0 (leading-zero suppress flag)

LOC_87DD:
    DEC     B                           ; B-- (process digits right to left)
    JR      Z, LOC_87E6                 ; if last digit, always display
    LD      A, (DE)                     ; A = current digit
    OR      C                           ; A = digit | suppress flag
    JR      Z, LOC_87EB                 ; if zero and suppressing, blank digit
    LD      C, $FF                      ; C = $FF (stop suppressing leading zeros)

LOC_87E6:
    LD      A, (DE)                     ; A = digit value
    ADD     A, $02                      ; A += 2 (convert to tile index: 0-9 -> 2-11)
    JR      LOC_87ED                    ; store adjusted tile

LOC_87EB:
    LD      A, $00                      ; A = 0 (blank tile for leading zero)

LOC_87ED:
    LD      (DE), A                     ; store display tile index
    INC     DE                          ; advance pointer
    INC     B                           ; B++ (restore for DJNZ)
    DJNZ    LOC_87DD                    ; loop for all digits
    POP     BC                          ; restore BC
    PUSH    IX                          ; IX = VRAM destination address
    POP     DE                          ; DE = VRAM destination (from IX)
    JP      SOUND_WRITE_86FA            ; flush digit buffer to VRAM at DE

DELAY_LOOP_87F9:
    LD      B, A                        ; B = count (binary value to convert)
    XOR     A                           ; A = 0 (BCD accumulator)

LOC_87FB:
    ADD     A, $01                      ; A += 1 (BCD increment)
    DAA                                 ; decimal adjust (keep BCD form)
    DJNZ    LOC_87FB                    ; loop B times (binary -> BCD conversion)
    RET                                 ; return with A = BCD value

SUB_8801:
    PUSH    BC                          ; save BC
    LD      A, B                        ; A = digit value (lives or score)
    LD      B, $06                      ; B = 6 (tile slots to fill)
    LD      HL, $7079                   ; HL -> VRAM write buffer

LOC_8808:
    CP      $06                         ; compare A to 6 (max filled tiles)
    JR      C, LOC_880F                 ; if A < 6, tile is filled
    LD      (HL), C                     ; write filled tile (C = tile index)
    JR      LOC_8811                    ; advance

LOC_880F:
    LD      (HL), $00                   ; write empty tile (blank)

LOC_8811:
    INC     HL                          ; advance buffer pointer
    INC     A                           ; A++ (track filled-tile count)
    DJNZ    LOC_8808                    ; loop 6 times
    LD      (HL), $00                   ; terminate buffer with zero
    LD      C, $07                      ; C = 7 bytes to write
    CALL    SOUND_WRITE_86FA            ; flush 7-byte tile row to VRAM at DE
    POP     BC                          ; restore BC
    RET                                 ; return

SUB_881E:
    LD      A, ($705B)                  ; A = player lives count
    LD      B, A                        ; B = lives count
    LD      C, $16                      ; C = $16 (lives tile index)
    LD      DE, $1A68                   ; DE = VRAM address $1A68 (lives row 1)
    CALL    SUB_8801                    ; write 6 lives tiles to VRAM row 1
    INC     C                           ; C = $17 (lives tile index row 2)
    LD      DE, $1A88                   ; DE = VRAM address $1A88 (lives row 2)
    JP      SUB_8801                    ; write 6 lives tiles to VRAM row 2

SUB_8831:
    LD      A, ($705C)                  ; A = player score hundreds digit (fuel level)
    LD      B, A                        ; B = digit value
    LD      C, $18                      ; C = $18 (fuel/score tile index)
    LD      DE, $1A72                   ; DE = VRAM address $1A72 (fuel row 1)
    CALL    SUB_8801                    ; write 6 fuel tiles to VRAM row 1
    INC     C                           ; C = $19 (fuel tile index row 2)
    LD      DE, $1A92                   ; DE = VRAM address $1A92 (fuel row 2)
    JP      SUB_8801                    ; write 6 fuel tiles to VRAM row 2
    DB      $3A, $9D, $71, $21, $79, $70, $0E, $0D
    DB      $47, $E6, $07, $CB, $28, $CB, $28, $CB
    DB      $28, $28, $06, $36, $1C, $23, $0D, $10
    DB      $FA, $36, $1B, $23, $0D, $28, $06, $41
    DB      $36, $1A, $23, $10, $FB, $11, $4B, $1A
    DB      $0E, $0D, $F5, $CD, $FA, $86, $F1, $21
    DB      $79, $70, $0E, $00, $A7, $28, $06, $47
    DB      $37, $CB, $19, $10, $FB, $06, $05, $71
    DB      $23, $10, $FC, $11, $D8, $10, $0E, $05
    DB      $C3, $FA, $86

; ; SOUND: turn off all channels, clear sound state ($717E-$7185)

SUB_888F:
    CALL    TURN_OFF_SOUND              ; BIOS: silence all SN76489A channels
    LD      DE, $717E                   ; DE -> sound state byte array ($717E)
    LD      C, $08                      ; C = 8 bytes to clear
    XOR     A                           ; A = 0
    JP      DELAY_LOOP_86A4             ; memset: zero $717E..$7185 (all sound flags)

; ; SOUND UPDATE (frame): fuel-pickup sweep, explosion, jetpack thrust

LOC_889B:
    LD      A, ($7077)                  ; A = game-over / attract flag
    AND     A                           ; test if nonzero
    RET     NZ                          ; return if attract mode (no sound updates)
    CALL    SUB_8A23                    ; update fuel-pickup frequency sweep
    CALL    SUB_8AE5                    ; update level-complete fanfare step
    CALL    SUB_8924                    ; update jetpack thrust pitch cycle
    JP      LOC_88E3                    ; update wall-hit fade-out

; ; SOUND UPDATE (frame): respawn tone, death noise, mine-contact buzz

SUB_88AC:
    LD      A, ($7077)                  ; A = attract flag
    AND     A                           ; test if nonzero
    RET     NZ                          ; return if attract mode
    CALL    SUB_8A60                    ; update channel-1 respawn tone cycle
    CALL    SUB_8AA9                    ; update player-death noise ramp
    CALL    SUB_89C7                    ; update mine-contact buzz cycle
    JP      LOC_8971                    ; update explosion noise pattern

; ; SOUND: wall-hit / damage -- noise burst on channel 3, then fade

CTRL_READ_88BD:
    LD      A, (CONTROLLER_BUFFER)     ; A = controller state
    AND     A                           ; test if zero
    RET     NZ                          ; return if not in game mode
    CPL                                 ; A = $FF (trigger wall-hit sound)
    LD      ($7185), A                  ; $7185 = $FF (wall-hit sound active flag)
    LD      A, $FC                      ; A = $FC (initial attenuation: nearly silent)
    LD      ($718D), A                  ; $718D = $FC (wall-hit fade counter)
    LD      C, $03                      ; C = 3 (noise channel)
    LD      DE, $0700                   ; D=$07 (noise config), E=$00 (volume)
    CALL    SOUND_WRITE_8B08            ; write noise channel config
    CALL    SOUND_WRITE_8B34            ; write noise channel volume (E=$00, loud)
    LD      HL, $0040                   ; HL = $0040 (tone frequency for channel 2)
    LD      C, $02                      ; C = 2 (tone channel 2)
    LD      E, $0F                      ; E = $0F (silent attenuation)
    CALL    SOUND_WRITE_8B14            ; write tone frequency for channel 2
    JP      SOUND_WRITE_8B34            ; write channel 2 attenuation (silent)

; ; SOUND UPDATE: wall-hit fade -- ramps volume on channel 3 to silence

LOC_88E3:
    LD      A, ($7185)                  ; A = wall-hit sound active flag
    AND     A                           ; test if zero
    RET     Z                           ; return if wall-hit sound not active
    LD      HL, $718D                   ; HL -> wall-hit fade counter
    INC     (HL)                        ; increment fade counter
    LD      A, (HL)                     ; A = updated fade counter
    SRL     A                           ; A >>= 1 (slow the fade rate)
    JP      P, LOC_88F3                 ; if positive, use shifted value
    XOR     A                           ; A = 0 (clamp to 0 if negative)

LOC_88F3:
    LD      E, A                        ; E = attenuation value
    LD      C, $03                      ; C = 3 (noise channel)
    CALL    SOUND_WRITE_8B34            ; write channel 3 attenuation (fade out)
    LD      A, E                        ; A = attenuation
    SUB     $0F                         ; A -= 15 (check if fully silent)
    RET     NZ                          ; return if not yet silent
    LD      ($7185), A                  ; $7185 = 0 (clear wall-hit flag, A=0)
    RET                                 ; return (wall-hit sound complete)

; ; SOUND: jetpack thrust START -- channel 0, cyclic pitch ($718C counter)

SUB_8901:
    LD      A, (CONTROLLER_BUFFER)     ; A = controller state
    AND     A                           ; test if zero
    RET     NZ                          ; return if not in game mode
    LD      ($718C), A                  ; $718C = 0 (reset pitch cycle counter)
    CPL                                 ; A = $FF
    LD      ($7184), A                  ; $7184 = $FF (jetpack thrust active flag)
    LD      C, $00                      ; C = 0 (channel 0)
    LD      E, $00                      ; E = 0 (full volume)
    LD      HL, $011C                   ; HL = $011C (initial tone frequency)
    CALL    SOUND_WRITE_8B14            ; write channel 0 frequency
    JP      SOUND_WRITE_8B34            ; write channel 0 volume (full)

; ; SOUND: jetpack thrust STOP -- silence channel 0

SUB_891A:
    XOR     A                           ; A = 0
    LD      ($7184), A                  ; $7184 = 0 (clear jetpack thrust flag)
    LD      C, A                        ; C = 0 (channel 0)
    LD      E, $0F                      ; E = $0F (silent)
    JP      SOUND_WRITE_8B34            ; write channel 0 attenuation (silent)

; ; SOUND UPDATE: jetpack thrust -- cycles pitch from table at $8949

SUB_8924:
    LD      A, ($7184)                  ; A = jetpack thrust active flag
    AND     A                           ; test if zero
    RET     Z                           ; return if thrust not active
    LD      HL, $718C                   ; HL -> pitch cycle counter
    INC     (HL)                        ; increment cycle counter
    LD      A, (HL)                     ; A = updated counter
    SRL     A                           ; A >>= 1 (divide by 2)
    SRL     A                           ; A >>= 1 (divide by 4)
    SRL     A                           ; A >>= 1 (divide by 8)
    SRL     A                           ; A >>= 1 (divide by 16)
    LD      C, A                        ; C = slow pitch index (0-15)
    LD      A, ($718C)                  ; A = raw cycle counter
    AND     $03                         ; keep lower 2 bits (0-3 table index)
    LD      HL, $8949                   ; HL -> pitch offset table (4 entries)
    CALL    SUB_869D                    ; A = pitch_table[counter & 3]
    ADD     A, C                        ; A += C (add slow index to table offset)
    LD      E, A                        ; E = final frequency value
    LD      C, $00                      ; C = 0 (channel 0)
    JP      SOUND_WRITE_8B34            ; write channel 0 attenuation with pitch
    DB      $07, $04, $02, $00

; ; SOUND: explosion / item-pickup START -- channel 2 tone + channel 3 noise

LOC_894D:
    LD      A, (CONTROLLER_BUFFER)     ; A = controller state
    AND     A                           ; test if zero
    RET     NZ                          ; return if not in game mode
    LD      ($7182), A                  ; $7182 = 0 (clear mine-contact flag)
    CPL                                 ; A = $FF
    LD      ($7183), A                  ; $7183 = $FF (explosion sound active)
    LD      HL, $0004                   ; HL = $0004 (explosion tone frequency)
    LD      C, $02                      ; C = 2 (channel 2)
    LD      E, $0F                      ; E = $0F (silent)
    CALL    SOUND_WRITE_8B14            ; write channel 2 frequency
    CALL    SOUND_WRITE_8B34            ; write channel 2 attenuation (silent)
    LD      C, $03                      ; C = 3 (noise channel)
    LD      DE, $0704                   ; D=$07 (noise config), E=$04 (attenuation)
    CALL    SOUND_WRITE_8B08            ; write noise channel config
    JP      SOUND_WRITE_8B34            ; write noise channel volume

; ; SOUND UPDATE: explosion noise -- cycles pattern from table at $8987

LOC_8971:
    LD      A, ($7183)                  ; A = explosion sound active flag
    AND     A                           ; test if zero
    RET     Z                           ; return if explosion not active
    LD      A, ($7067)                  ; A = frame counter
    AND     $0F                         ; keep lower 4 bits (0-15 table index)
    LD      HL, $8987                   ; HL -> explosion noise pattern table (16 entries)
    CALL    SUB_869D                    ; A = pattern_table[frame & 15]
    LD      E, A                        ; E = noise pattern value
    LD      C, $03                      ; C = 3 (noise channel)
    JP      SOUND_WRITE_8B34            ; write channel 3 attenuation
    DB      $01, $04, $08, $02, $02, $06, $04, $09
    DB      $01, $06, $03, $04, $01, $04, $07, $03

; ; SOUND: mine-contact START -- channel 3 noise ($718B counter)

SUB_8997:
    LD      A, (CONTROLLER_BUFFER)     ; A = controller state
    LD      HL, $7182                   ; HL -> mine-contact / explosion flag
    OR      (HL)                        ; A = controller | mine flag
    INC     HL                          ; HL -> explosion flag
    OR      (HL)                        ; A |= explosion flag
    LD      HL, $7180                   ; HL -> player-death flag
    OR      (HL)                        ; A |= player-death flag
    RET     NZ                          ; return if any sound already active
    LD      ($718B), A                  ; $718B = 0 (reset mine buzz counter)
    CPL                                 ; A = $FF
    LD      ($7182), A                  ; $7182 = $FF (mine-contact sound active)
    LD      C, $03                      ; C = 3 (noise channel)
    LD      DE, $0604                   ; D=$06 (noise config), E=$04 (attenuation)
    CALL    SOUND_WRITE_8B08            ; write noise channel config
    JP      SOUND_WRITE_8B34            ; write noise channel volume

; ; SOUND: mine-contact STOP -- silence channel 3

SUB_89B7:
    LD      A, ($7182)                  ; A = mine-contact sound active flag
    AND     A                           ; test if zero
    RET     Z                           ; return if not active
    XOR     A                           ; A = 0
    LD      ($7182), A                  ; $7182 = 0 (clear mine-contact flag)
    LD      C, $03                      ; C = 3 (noise channel)
    LD      E, $0F                      ; E = $0F (silent)
    JP      SOUND_WRITE_8B34            ; write channel 3 attenuation (silent)

; ; SOUND UPDATE: mine-contact -- cycles through 3-step buzz table at $89EC

SUB_89C7:
    LD      A, ($7182)                  ; A = mine-contact sound active flag
    AND     A                           ; test if zero
    RET     Z                           ; return if not active
    LD      HL, $718B                   ; HL -> mine buzz cycle counter
    INC     (HL)                        ; increment cycle counter
    LD      A, (HL)                     ; A = updated counter
    SRL     A                           ; A >>= 1 (every other frame)
    RET     C                           ; return on odd frames (update every 2 frames)
    CP      $03                         ; compare to 3 (buzz table length)
    JR      C, LOC_89D9                 ; if < 3, use directly as index
    XOR     A                           ; A = 0 (wrap around)

LOC_89D9:
    SLA     A                           ; A <<= 1 (restore pre-shift value)
    LD      ($718B), A                  ; store updated counter
    SRL     A                           ; A >>= 1 (back to table index)
    LD      HL, $89EC                   ; HL -> buzz pattern table (3 entries)
    CALL    SUB_869D                    ; A = buzz_table[index]
    LD      E, A                        ; E = attenuation value
    LD      C, $03                      ; C = 3 (noise channel)
    JP      SOUND_WRITE_8B34            ; write channel 3 attenuation
    DB      $03, $05, $07

; ; SOUND: fuel-pickup START -- channel 2+3, descending frequency sweep ($7186 countdown from $68)

SUB_89EF:
    LD      A, (CONTROLLER_BUFFER)     ; A = controller state
    AND     A                           ; test if zero
    RET     NZ                          ; return if not in game mode
    LD      ($7185), A                  ; $7185 = 0 (clear wall-hit flag)
    CPL                                 ; A = $FF
    LD      ($717E), A                  ; $717E = $FF (fuel-pickup sound active)
    LD      C, $03                      ; C = 3 (noise channel)
    LD      DE, $0702                   ; D=$07 (noise config), E=$02 (attenuation)
    CALL    SOUND_WRITE_8B08            ; write noise channel config
    CALL    SOUND_WRITE_8B34            ; write noise channel volume
    LD      C, $02                      ; C = 2 (channel 2)
    LD      A, $68                      ; A = $68 (104 = starting frequency)
    LD      ($7186), A                  ; $7186 = $68 (frequency countdown)
    LD      L, A                        ; L = $68 (frequency low byte)
    LD      H, $00                      ; H = 0 (frequency high byte = 0)
    LD      E, $0F                      ; E = $0F (silent attenuation)
    CALL    SOUND_WRITE_8B14            ; write channel 2 frequency
    JP      SOUND_WRITE_8B34            ; write channel 2 attenuation (silent)
    DB      $AF, $32, $7E, $71, $0E, $03, $1E, $0F
    DB      $C3, $34, $8B

; ; SOUND UPDATE: fuel-pickup -- decrements frequency each frame on channel 2

SUB_8A23:
    LD      A, ($717E)                  ; A = fuel-pickup sound active flag
    AND     A                           ; test if zero
    RET     Z                           ; return if not active
    LD      HL, $7186                   ; HL -> frequency countdown
    DEC     (HL)                        ; decrement frequency (sweep down)
    LD      A, (HL)                     ; A = updated frequency
    LD      L, A                        ; L = frequency low byte
    LD      H, $00                      ; H = 0 (high byte)
    LD      C, $02                      ; C = 2 (channel 2)
    CALL    SOUND_WRITE_8B14            ; write channel 2 frequency (descending)
    LD      C, $03                      ; C = 3 (noise channel)
    LD      E, $02                      ; E = $02 (noise attenuation, moderate volume)
    JP      SOUND_WRITE_8B34            ; write channel 3 volume

; ; SOUND: channel-1 tone START

LOC_8A3C:
    LD      A, (CONTROLLER_BUFFER)     ; A = controller state
    AND     A                           ; test if zero
    RET     NZ                          ; return if not in game mode
    LD      ($7187), A                  ; $7187 = 0 (reset channel-1 cycle counter)
    CPL                                 ; A = $FF
    LD      ($717F), A                  ; $717F = $FF (channel-1 tone active)
    LD      HL, $0113                   ; HL = $0113 (channel 1 tone frequency)
    LD      C, $01                      ; C = 1 (channel 1)
    LD      E, $05                      ; E = $05 (moderate attenuation)
    CALL    SOUND_WRITE_8B14            ; write channel 1 frequency
    JP      SOUND_WRITE_8B34            ; write channel 1 volume

; ; SOUND: channel-1 tone STOP

LOC_8A55:
    XOR     A                           ; A = 0
    LD      ($717F), A                  ; $717F = 0 (clear channel-1 tone flag)
    LD      C, $01                      ; C = 1 (channel 1)
    LD      E, $0F                      ; E = $0F (silent)
    JP      SOUND_WRITE_8B34            ; write channel 1 attenuation (silent)

; ; SOUND UPDATE: channel-1 tone -- cycles 4-step frequency table at $8A82

SUB_8A60:
    LD      A, ($717F)                  ; A = channel-1 tone active flag
    AND     A                           ; test if zero
    RET     Z                           ; return if not active
    LD      HL, $7187                   ; HL -> channel-1 cycle counter
    INC     (HL)                        ; increment cycle counter
    LD      A, (HL)                     ; A = counter
    AND     $03                         ; keep lower 2 bits (0-3 table index)
    LD      HL, $8A82                   ; HL -> 4-step frequency table
    SLA     A                           ; A <<= 1 (each entry is 2 bytes)
    CALL    SUB_869D                    ; A = freq_table[index].low
    LD      E, A                        ; E = frequency low byte
    INC     HL                          ; HL -> frequency high byte
    LD      D, (HL)                     ; D = frequency high byte
    DB      $EB                         ; EX DE,HL (HL = frequency, DE = ?)
    LD      C, $01                      ; C = 1 (channel 1)
    LD      E, $02                      ; E = $02 (moderate attenuation)
    CALL    SOUND_WRITE_8B14            ; write channel 1 frequency
    JP      SOUND_WRITE_8B34            ; write channel 1 volume
    DB      $13, $01, $70, $01, $DA, $00, $B4, $01

; ; SOUND: player death START -- channel 3 noise, clears contact/explosion flags ($7188 phase)

SUB_8A8A:
    LD      A, (CONTROLLER_BUFFER)     ; A = controller state
    AND     A                           ; test if zero
    RET     NZ                          ; return if not in game mode
    LD      ($7182), A                  ; $7182 = 0 (clear mine-contact flag)
    LD      ($7183), A                  ; $7183 = 0 (clear explosion flag)
    CPL                                 ; A = $FF
    LD      ($7180), A                  ; $7180 = $FF (player-death sound active)
    LD      A, $F3                      ; A = $F3 (initial phase counter)
    LD      ($7188), A                  ; $7188 = $F3 (death noise ramp start)
    LD      C, $03                      ; C = 3 (noise channel)
    LD      DE, $0600                   ; D=$06 (noise config), E=$00 (loud)
    CALL    SOUND_WRITE_8B08            ; write noise channel config
    JP      SOUND_WRITE_8B34            ; write channel 3 volume (loud)

; ; SOUND UPDATE: player death -- ramps noise volume on channel 3 to silence

SUB_8AA9:
    LD      A, ($7180)                  ; A = player-death sound active flag
    AND     A                           ; test if zero
    RET     Z                           ; return if not active
    LD      HL, $7188                   ; HL -> death noise ramp counter
    INC     (HL)                        ; increment ramp counter
    LD      A, (HL)                     ; A = updated counter
    SRA     A                           ; A >>= 1 (arithmetic shift, preserves sign)
    JP      P, LOC_8AB9                 ; if positive, use shifted value
    XOR     A                           ; A = 0 (clamp to 0)

LOC_8AB9:
    LD      E, A                        ; E = attenuation value
    LD      C, $03                      ; C = 3 (noise channel)
    CALL    SOUND_WRITE_8B34            ; write channel 3 attenuation (ramp to silence)
    LD      A, E                        ; A = attenuation
    SUB     $0F                         ; A -= 15 (check if silent)
    RET     NZ                          ; return if not yet silent
    LD      ($7180), A                  ; $7180 = 0 (clear death-sound flag)
    RET                                 ; return (death sound complete)

; ; SOUND: level-complete / bonus START -- channel 0, 8-step tone sequence ($7189 countdown)

LOC_8AC7:
    LD      A, (CONTROLLER_BUFFER)     ; A = controller state
    AND     A                           ; test if zero
    RET     NZ                          ; return if not in game mode
    CPL                                 ; A = $FF
    LD      ($7181), A                  ; $7181 = $FF (level-complete sound active)
    LD      ($718A), A                  ; $718A = $FF (repeat flag for fanfare)
    LD      A, $08                      ; A = 8 (number of fanfare steps)
    LD      ($7189), A                  ; $7189 = 8 (step countdown)
    LD      C, $00                      ; C = 0 (channel 0)
    LD      E, $02                      ; E = $02 (moderate volume)
    LD      HL, $0158                   ; HL = $0158 (fanfare tone frequency)
    CALL    SOUND_WRITE_8B14            ; write channel 0 frequency
    JP      SOUND_WRITE_8B34            ; write channel 0 volume

; ; SOUND UPDATE: level-complete -- decrements step counter, restarts when $718A nonzero

SUB_8AE5:
    LD      A, ($7181)                  ; A = level-complete sound active flag
    AND     A                           ; test if zero
    RET     Z                           ; return if not active
    LD      HL, $7189                   ; HL -> fanfare step counter
    DEC     (HL)                        ; decrement step counter
    LD      A, (HL)                     ; A = updated counter
    JR      Z, LOC_8AFB                 ; if zero, check repeat
    CP      $05                         ; compare to 5 (mid-fanfare silence point)
    RET     NZ                          ; return if not at step 5
    LD      C, $00                      ; C = 0 (channel 0)
    LD      E, $0F                      ; E = $0F (silent)
    JP      SOUND_WRITE_8B34            ; silence channel 0 at mid-fanfare

LOC_8AFB:
    LD      A, ($718A)                  ; A = fanfare repeat flag
    AND     A                           ; test if nonzero
    JP      NZ, LOC_8AC7               ; if repeat flag set, restart fanfare
    RET                                 ; return (fanfare complete)
    DB      $AF, $32, $8A, $71, $C9

; ; ---- SN76489A SOUND CHIP WRITE PRIMITIVES ----
; ; SOUND_WRITE_8B08 -- write noise channel
; ;   D bits 3-0 = noise config ($E0 | D[3:0])

SOUND_WRITE_8B08:
    PUSH    AF                          ; save AF
    PUSH    BC                          ; save BC
    LD      A, D                        ; A = noise config byte (from D)
    AND     $0F                         ; keep lower nibble (noise type/rate)
    OR      $E0                         ; set noise channel latch bits ($E0)
    OUT     ($FF), A                    ; write to SN76489A noise register (SOUND_PORT)
    POP     BC                          ; restore BC
    POP     AF                          ; restore AF
    RET                                 ; return

; ; SOUND_WRITE_8B14 -- write tone frequency (two OUT bytes)
; ;   C = channel (0-2), HL = 10-bit frequency

SOUND_WRITE_8B14:
    PUSH    AF                          ; save AF
    PUSH    BC                          ; save BC
    LD      A, C                        ; A = channel number (0-2)
    RRCA                                ; rotate right (shift channel into bits 5-4)
    RRCA                                ; rotate right again
    RRCA                                ; rotate right (A = channel << 5)
    OR      $80                         ; set latch bit (tone frequency command)
    LD      C, A                        ; C = tone latch byte header
    LD      A, L                        ; A = frequency low byte
    AND     $0F                         ; keep lower nibble (bits 3-0 of frequency)
    OR      C                           ; combine with channel header
    OUT     ($FF), A                    ; write first frequency byte to SN76489A
    LD      A, L                        ; A = frequency low byte again
    AND     $F0                         ; keep upper nibble (bits 7-4)
    LD      B, A                        ; B = upper nibble of L
    LD      A, H                        ; A = frequency high byte
    AND     $03                         ; keep lower 2 bits (bits 9-8 of frequency)
    OR      B                           ; combine with upper nibble of L
    RRCA                                ; rotate right (align bits)
    RRCA                                ; rotate right
    RRCA                                ; rotate right
    RRCA                                ; rotate right (bits into correct position)
    OUT     ($FF), A                    ; write second frequency byte to SN76489A
    POP     BC                          ; restore BC
    POP     AF                          ; restore AF
    RET                                 ; return

; ; SOUND_WRITE_8B34 -- write volume/attenuation
; ;   C = channel (0-3), E = attenuation (0=loud, $0F=silent)

SOUND_WRITE_8B34:
    PUSH    AF                          ; save AF
    PUSH    BC                          ; save BC
    LD      A, C                        ; A = channel number (0-3)
    RRCA                                ; rotate right (shift channel into bits 5-4)
    RRCA                                ; rotate right again
    RRCA                                ; rotate right (channel in bits 5-4 pos)
    OR      $90                         ; set volume latch bits ($90)
    LD      C, A                        ; C = volume latch byte header
    LD      A, E                        ; A = attenuation value
    AND     $0F                         ; keep lower nibble (0-15)
    OR      C                           ; combine with channel header
    OUT     ($FF), A                    ; write volume byte to SN76489A (SOUND_PORT)
    POP     BC                          ; restore BC
    POP     AF                          ; restore AF
    RET                                 ; return
    DB      $1E, $91, $B6, $90, $C9, $90, $7C, $8B
    DB      $32, $90, $3C, $90, $7C, $8B, $32, $90
    DB      $3C, $90, $BF, $8B, $C6, $8B, $C6, $8B
    DB      $39, $8D, $B6, $8F, $BB, $8F, $B4, $8D
    DB      $CC, $8F, $D3, $8F, $BA, $8C, $7C, $8B
    DB      $7C, $8B, $FE, $8B, $7C, $8B, $03, $8C
    DB      $9F, $8B, $7C, $8B, $7C, $8B, $C9


SUB_8B7D:
    LD      A, ($72E8)                  ; A = dynamite-active flag
    AND     A                           ; test if zero
    RET     Z                           ; return if no dynamite entity
    LD      IX, $71CD                   ; IX -> dynamite sprite struct at $71CD
    LD      DE, $32BE                   ; DE = X position $32, color/flags $BE
    CALL    SUB_9160                    ; set sprite bounds (IX+2=D, IX+3=E)
    LD      DE, BOOT_UP                 ; DE = $0000 (Y=0, velocity=0)
    CALL    SUB_9167                    ; set sprite velocity and flags
    CALL    LOC_9179                    ; enable sprite (set bit 7 of IX+5)
    LD      A, ($71BB)                  ; A = player horizontal position byte
    AND     A                           ; test sign
    JP      M, LOC_900B                 ; if negative (moving left), go to LOC_900B
    JP      LOC_9003                    ; else go to LOC_9003 (moving right)
    DB      $DD, $E5, $DD, $21, $CD, $71, $3A, $BB
    DB      $71, $DD, $96, $00, $16, $00, $28, $06
    DB      $16, $08, $30, $02, $16, $F8, $3A, $5D
    DB      $70, $5F, $CD, $67, $91, $DD, $E1, $C9
    DB      $DD, $21, $BB, $71, $C3, $B4, $8D, $CD
    DB      $07, $8C, $C3, $1B, $AA

SUB_8BCC:
    LD      IX, $71AF                   ; IX -> miner sprite struct at $71AF
    LD      DE, $30C0                   ; DE = X=$30, color=$C0 (miner position)
    CALL    SUB_9160                    ; set sprite bounds
    LD      DE, $1804                   ; DE = Y=$18, flags=$04
    CALL    SUB_9167                    ; set sprite velocity and flags
    LD      A, ($71BB)                  ; A = player horizontal motion
    AND     A                           ; test sign
    JP      M, LOC_900B                 ; if moving left, use LOC_900B
    JP      LOC_9003                    ; if moving right, use LOC_9003

SUB_8BE6:
    LD      IX, $71C7                   ; IX -> hero re-entry sprite struct at $71C7
    LD      DE, $001E                   ; DE = X bounds $00/$1E
    CALL    SUB_9160                    ; set sprite X bounds
    LD      D, $06                      ; D = $06 (Y velocity)
    LD      E, $00                      ; E = $00 (flags = 0)
    CALL    SUB_9167                    ; set sprite velocity/flags
    XOR     A                           ; A = 0 (pattern index 0)
    CALL    SUB_9153                    ; set sprite pattern index to 0
    JP      LOC_9179                    ; enable sprite (set bit 7 of IX+5)
    DB      $3A, $8C, $72, $A7, $C8, $AF, $C3, $53
    DB      $91, $DD, $7E, $01, $ED, $44, $DD, $77
    DB      $01, $C9

SUB_8C10:
    LD      A, ($72A8)                  ; A = cave-animation flags byte
    LD      C, A                        ; C = flags (save for bit tests)
    LD      A, ($7285)                  ; A = enemy-visible flag
    AND     A                           ; test if nonzero
    JR      NZ, LOC_8C1F               ; if enemy visible, proceed to cave anim
    LD      A, ($719B)                  ; A = player-in-flight flag
    AND     A                           ; test if nonzero
    RET     NZ                          ; return if player in flight (no cave anim)

LOC_8C1F:
    BIT     4, C                        ; test bit 4 of cave-anim flags
    JR      Z, LOC_8C3F                 ; if bit 4 clear, skip propeller anim
    LD      A, ($7067)                  ; A = frame counter
    AND     $07                         ; keep lower 3 bits (0-7 cycle)
    JR      NZ, LOC_8C3F               ; skip unless frame & 7 == 0 (every 8 frames)
    LD      A, ($718F)                  ; A = propeller animation frame counter
    INC     A                           ; increment frame counter
    LD      ($718F), A                  ; store updated counter
    BIT     2, A                        ; test bit 2 (4-frame cycle)
    JR      Z, LOC_8C37                 ; if bit 2 clear, use positive frame
    NEG                                 ; negate (alternate direction)

LOC_8C37:
    AND     $07                         ; keep lower 3 bits (0-7 frame index)
    LD      HL, $AB67                   ; HL -> propeller frame data table
    CALL    SUB_AA9E                    ; draw propeller strip tile to VRAM

LOC_8C3F:
    LD      A, ($719B)                  ; A = player-in-flight flag
    AND     A                           ; test if nonzero
    RET     NZ                          ; return if player in flight

LOC_8C44:
    LD      B, $02                      ; B = 2 (shift count for frame rate)
    LD      A, ($7067)                  ; A = frame counter

LOC_8C49:
    SRL     A                           ; A >>= 1 (divide by 2)
    RET     C                           ; return if odd (animate every 4 frames)
    DJNZ    LOC_8C49                    ; loop B times
    LD      A, ($718E)                  ; A = cave-entrance animation counter
    INC     A                           ; increment animation frame
    LD      ($718E), A                  ; store updated counter
    AND     $03                         ; keep lower 2 bits (4-frame cycle)
    LD      HL, $AB2E                   ; HL -> cave entrance strip table
    LD      B, $00                      ; B = 0 (strip index offset)
    BIT     2, C                        ; test bit 2 of cave-anim flags
    CALL    NZ, SUB_AA9E                ; if bit 2, draw cave strip
    SRL     A                           ; A >>= 1 (next bit)
    RET     C                           ; return if carry
    AND     $01                         ; keep bit 0
    LD      HL, $AB24                   ; HL -> left-wall strip table
    BIT     0, C                        ; test bit 0 of cave-anim flags
    CALL    NZ, SUB_AA9E                ; if bit 0, draw left-wall strip
    LD      HL, $AB29                   ; HL -> right-wall strip table
    BIT     1, C                        ; test bit 1 of cave-anim flags
    CALL    NZ, SUB_AA9E                ; if bit 1, draw right-wall strip
    LD      HL, $AB37                   ; HL -> ceiling strip table
    BIT     3, C                        ; test bit 3 of cave-anim flags
    CALL    NZ, SUB_AA9E                ; if bit 3, draw ceiling strip
    RET                                 ; return

LOC_8C7F:
    LD      A, $FF                      ; A = $FF
    LD      ($718E), A                  ; $718E = $FF (reset cave-entrance counter)
    LD      C, A                        ; C = $FF (flags: all bits set)
    JR      LOC_8C44                    ; draw all cave entrance strips
    DB      $10, $08, $06, $06, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $FA, $FA, $F8, $F0

SUB_8C97:
    LD      IX, $71C1                   ; IX -> hero-descent sprite struct at $71C1
    LD      DE, $000F                   ; DE = X=$00, flags=$0F (bounds)
    CALL    SUB_9160                    ; set sprite X bounds
    LD      DE, $0002                   ; DE = velocity=$00, flags=$02
    CALL    SUB_9167                    ; set sprite velocity/flags
    CALL    SUB_8CAD                    ; set descent pattern and lookup speed
    JP      LOC_9179                    ; enable sprite

SUB_8CAD:
    LD      A, $08                      ; A = 8 (pattern index for descent sprite)
    PUSH    IX                          ; save IX
    LD      IX, $71C1                   ; IX -> descent sprite
    CALL    SUB_9153                    ; set sprite pattern to 8
    POP     IX                          ; restore IX
    LD      A, ($71C1)                  ; A = current pattern index
    LD      HL, $8C87                   ; HL -> descent-speed lookup table
    CALL    SUB_869D                    ; A = speed_table[pattern]
    LD      ($71B6), A                  ; $71B6 = descent speed value
    RET                                 ; return
    DB      $3A, $C1, $71, $FE, $02, $30, $04, $3E
    DB      $02, $18, $05, $FE, $0F, $D8, $3E, $0F
    DB      $C3, $AF, $8C

SOUND_WRITE_8CDA:
    LD      A, $40                      ; A = $40 (player X start position)
    LD      ($7191), A                  ; $7191 = $40 (player sprite X)
    LD      A, $3A                      ; A = $3A (enemy Y start position)
    LD      ($7192), A                  ; $7192 = $3A (enemy sprite Y)

LOC_8CE4:
    LD      A, $FF                      ; A = $FF
    LD      ($7193), A                  ; $7193 = $FF (sprite visible flag)
    LD      IX, $71B5                   ; IX -> player X sprite struct at $71B5
    LD      DE, $0082                   ; DE = bounds $00/$82
    LD      A, ($7191)                  ; A = player X position
    LD      ($7190), A                  ; $7190 = player X (save copy)
    LD      A, $00                      ; A = 0 (pattern index 0)
    LD      B, $08                      ; B = 8 (flags byte)
    CALL    SUB_8D10                    ; init player sprite struct
    LD      IX, $71BB                   ; IX -> enemy X sprite struct at $71BB
    LD      DE, $08E8                   ; DE = bounds $08/$E8
    LD      A, ($7192)                  ; A = enemy Y position
    LD      B, $00                      ; B = 0 (flags byte)
    CALL    SUB_8D10                    ; init enemy sprite struct
    CALL    SUB_A8B9                    ; compute shadow mask for player/enemy
    RET                                 ; return

SUB_8D10:
    PUSH    BC                          ; save BC (flags byte)
    CALL    SUB_9160                    ; set sprite bounds (IX+2=D, IX+3=E)
    CALL    SUB_9153                    ; set sprite pattern index (A -> IX+0)
    POP     BC                          ; restore BC
    LD      D, B                        ; D = flags byte
    LD      A, ($705E)                  ; A = player extra lives
    LD      E, A                        ; E = extra lives (color nibble)
    CALL    SUB_9167                    ; set sprite velocity=D, flags nibble=E
    JP      LOC_9179                    ; enable sprite
    DB      $3A, $90, $71, $DD, $BE, $00, $C0, $AF
    DB      $32, $93, $71, $DD, $77, $01, $3A, $9E
    DB      $71, $A7, $F0, $C3, $CF, $90, $3A, $93
    DB      $71, $A7, $20, $E4, $3A, $85, $72, $A7
    DB      $C2, $84, $A3, $3A, $81, $72, $A7, $28
    DB      $0E, $3A, $B5, $71, $FE, $76, $3E, $76
    DB      $30, $0D, $CD, $C6, $A3, $18, $13, $CD
    DB      $57, $8E, $30, $0E, $3A, $91, $71, $DD
    DB      $77, $00, $3A, $85, $72, $A7, $C0, $CD
    DB      $C7, $8C, $DD, $7E, $00, $32, $91, $71
    DB      $C9

SUB_8D74:
    LD      A, ($7281)                  ; A = player-on-ground flag
    AND     A                           ; test if nonzero
    JR      NZ, LOC_8DA6               ; if on ground, set mine sensor to 0
    LD      A, ($726C)                  ; A = player X position
    CP      $0E                         ; compare to $0E (left mine zone)
    JR      Z, LOC_8D85                 ; if at left zone, check Y proximity
    CP      $38                         ; compare to $38 (right mine zone)
    JR      NZ, LOC_8DA2               ; if not in any zone, set $FF

LOC_8D85:
    LD      A, ($726D)                  ; A = player Y position
    ADD     A, $04                      ; A += 4 (player bottom edge)
    LD      C, A                        ; C = player bottom Y
    LD      A, ($726C)                  ; A = player X position
    ADD     A, $24                      ; A += 36 (mine X offset)
    LD      B, A                        ; B = mine X reference
    PUSH    BC                          ; save BC (mine proximity coords)
    CALL    SUB_8ECE                    ; check proximity for B,C
    POP     BC                          ; restore BC
    JR      C, LOC_8DA6                 ; if in range, set mine sensor active
    LD      A, C                        ; A = bottom Y
    ADD     A, $08                      ; A += 8 (extended range)
    LD      C, A                        ; C = extended Y
    LD      A, B                        ; A = mine X
    CALL    SUB_8ECE                    ; check extended proximity
    JR      C, LOC_8DA6                 ; if in extended range, activate sensor

LOC_8DA2:
    LD      A, $FF                      ; A = $FF (no mine proximity)
    JR      LOC_8DA7                    ; store and return

LOC_8DA6:
    XOR     A                           ; A = 0 (mine proximity active)

LOC_8DA7:
    LD      ($7284), A                  ; $7284 = mine-sensor state (0=active, $FF=inactive)
    RET                                 ; return
    DB      $3A, $AA, $72, $4F, $3A, $C5, $72, $B9
    DB      $C9, $3A, $93, $71, $A7, $C0, $3A, $81
    DB      $72, $A7, $28, $09, $3A, $AF, $71, $DD
    DB      $77, $00, $C3, $21, $8E, $3A, $72, $70
    DB      $A7, $28, $31, $3A, $92, $71, $C6, $02
    DB      $4F, $E6, $03, $20, $27, $79, $CD, $2E
    DB      $8F, $CB, $3F, $30, $09, $CB, $39, $CB
    DB      $39, $A9, $E6, $01, $28, $16, $3A, $92
    DB      $71, $DD, $77, $00, $AF, $DD, $77, $01
    DB      $32, $72, $70, $3A, $9B, $71, $A7, $CC
    DB      $1B, $AA, $18, $22, $CD, $57, $8E, $30
    DB      $1D, $3A, $92, $71, $DD, $77, $00, $3A
    DB      $72, $70, $A7, $20, $09, $3A, $2B, $70
    DB      $A7, $C4, $BC, $84, $18, $08, $DD, $7E
    DB      $01, $ED, $44, $DD, $77, $01, $CD, $AB
    DB      $8D, $20, $23, $3A, $6C, $72, $FE, $39
    DB      $30, $1C, $3A, $C4, $72, $CB, $3F, $CB
    DB      $3F, $FE, $14, $DD, $7E, $00, $30, $07
    DB      $FE, $40, $30, $0A, $C3, $71, $90, $FE
    DB      $B0, $38, $03, $C3, $71, $90, $DD, $7E
    DB      $00, $32, $92, $71, $3A, $E8, $72, $A7
    DB      $C4, $9F, $8B, $C9


SUB_8E57:
    LD      A, ($71BB)                  ; A = player horizontal position
    ADD     A, $03                      ; A += 3 (right edge offset)
    LD      C, A                        ; C = right edge X
    LD      A, ($71B5)                  ; A = player X position
    ADD     A, $F0                      ; A += $F0 (wrap/offset for left edge)
    CALL    SUB_8ECE                    ; check proximity at left edge
    JR      C, LOC_8E7C                 ; if in range (carry), trigger hazard
    CALL    DELAY_LOOP_8F93             ; check second proximity zone
    JR      C, LOC_8E7C                 ; if in range, trigger hazard
    LD      A, ($71B5)                  ; A = player X position
    ADD     A, $07                      ; A += 7 (right hitbox edge)
    CALL    SUB_8EE0                    ; check right-side proximity
    JR      C, LOC_8E7C                 ; if in range, trigger hazard
    CALL    DELAY_LOOP_8F93             ; check additional zone
    JR      C, LOC_8E7C                 ; if in range, trigger hazard
    RET                                 ; return (no hazard detected)

LOC_8E7C:
    LD      A, ($72C4)                  ; A = player physics/motion flags
    BIT     1, A                        ; test bit 1 (propeller active)
    JR      NZ, LOC_8E87               ; if propeller active, skip clear
    XOR     A                           ; A = 0
    LD      ($7194), A                  ; $7194 = 0 (clear proximity trigger)

LOC_8E87:
    LD      A, ($7194)                  ; A = proximity trigger flag
    AND     A                           ; test if zero
    PUSH    IX                          ; save IX
    JR      Z, LOC_8EB5                 ; if zero, check alternate spawn
    LD      C, $04                      ; C = 4 (default spawn mode)
    LD      A, ($7191)                  ; A = player X sprite position
    CP      $68                         ; compare to $68 (right zone threshold)
    JR      C, LOC_8E9A                 ; if < $68, use C=4
    LD      C, $02                      ; C = 2 (left-zone spawn mode)

LOC_8E9A:
    CP      $27                         ; compare to $27 (close range threshold)
    JR      NC, LOC_8EA0               ; if >= $27, keep current C
    LD      C, $00                      ; C = 0 (point-blank spawn mode)

LOC_8EA0:
    LD      A, C                        ; A = spawn mode
    LD      ($7288), A                  ; $7288 = spawn mode parameter
    LD      A, $00                      ; A = 0
    CALL    LOC_A55A                    ; spawn / respawn enemy entity
    CALL    LOC_8573                    ; handle player death / life decrement
    LD      IX, $71BB                   ; IX -> enemy sprite struct
    CALL    LOC_9179                    ; enable enemy sprite
    JR      LOC_8ECA                    ; pop IX and set carry

LOC_8EB5:
    LD      A, ($7195)                  ; A = alternate proximity flag
    AND     A                           ; test if zero
    JR      Z, LOC_8ECA                 ; if zero, just pop IX
    LD      A, $FF                      ; A = $FF
    LD      ($7285), A                  ; $7285 = $FF (enemy-visible flag)
    LD      A, $02                      ; A = 2 (spawn mode 2)
    LD      ($7288), A                  ; $7288 = spawn mode
    LD      A, $00                      ; A = 0
    CALL    LOC_A55A                    ; spawn / respawn enemy entity

LOC_8ECA:
    POP     IX                          ; restore IX
    SCF                                 ; set carry flag (hazard triggered)
    RET                                 ; return with carry set

SUB_8ECE:
    PUSH    AF                          ; save AF
    LD      A, C                        ; A = Y coordinate to check
    LD      ($7199), A                  ; $7199 = Y coordinate
    AND     $03                         ; keep lower 2 bits (coarse Y)
    LD      ($719A), A                  ; $719A = coarse Y
    LD      A, C                        ; A = Y coordinate
    CALL    SUB_8F2E                    ; A = proximity_table[Y >> 2]
    LD      ($7198), A                  ; $7198 = proximity value
    POP     AF                          ; restore AF

SUB_8EE0:
    PUSH    AF                          ; save AF
    XOR     A                           ; A = 0
    LD      ($7194), A                  ; $7194 = 0 (clear proximity trigger)
    LD      ($7195), A                  ; $7195 = 0 (clear alternate flag)
    POP     AF                          ; restore AF
    CP      $C0                         ; compare X to $C0 (far-right threshold)
    JR      C, LOC_8EEF                 ; if < $C0, in normal range
    LD      A, $10                      ; A = $10 (clamp X to $10)

LOC_8EEF:
    CP      $07                         ; compare X to $07 (near-left threshold)
    JR      NC, LOC_8EFD               ; if >= $07, check zone tables
    LD      A, ($72AA)                  ; A = difficulty cycle counter
    AND     A                           ; test if zero
    LD      A, $00                      ; A = 0 (pre-load for JR)
    JR      NZ, LOC_8EFD               ; if nonzero difficulty, do zone check
    SCF                                 ; set carry (proximity confirmed)
    RET                                 ; return with carry set

LOC_8EFD:
    LD      HL, $72C6                   ; HL -> zone table A
    CP      $2E                         ; compare X to $2E (zone A threshold)
    JR      C, LOC_8F1F                 ; if < $2E, use zone A
    LD      HL, $72D0                   ; HL -> zone table B
    CP      $58                         ; compare X to $58 (zone B threshold)
    JR      C, LOC_8F1A                 ; if < $58, use zone B
    LD      HL, $72DA                   ; HL -> zone table C
    CP      $80                         ; compare X to $80 (zone C threshold)
    JR      C, LOC_8F1F                 ; if < $80, use zone C

    LD      A, ($72AA)                  ; A = difficulty cycle counter
    CP      $0A                         ; compare to 10
    CCF                                 ; complement carry
    JR      C, LOC_8F28                 ; if difficulty < 10, set $7195

LOC_8F1A:
    LD      A, $FF                      ; A = $FF
    LD      ($7194), A                  ; $7194 = $FF (proximity trigger set)

LOC_8F1F:
    LD      ($7196), HL                 ; $7196 = zone table pointer
    LD      A, ($7198)                  ; A = proximity value
    JP      LOC_8F9E                    ; check proximity against zone

LOC_8F28:
    LD      A, $FF                      ; A = $FF
    LD      ($7195), A                  ; $7195 = $FF (alternate proximity flag)
    RET                                 ; return

SUB_8F2E:
    PUSH    HL                          ; save HL
    SRL     A                           ; A >>= 1 (divide by 2)
    SRL     A                           ; A >>= 1 (divide by 4)
    LD      HL, $8F3B                   ; HL -> proximity lookup table
    CALL    SUB_869D                    ; A = table[Y >> 2]
    POP     HL                          ; restore HL
    RET                                 ; return
    DB      $00, $00, $00, $01, $01, $02, $03, $03
    DB      $04, $05, $05, $06, $07, $07, $08, $09
    DB      $09, $0A, $0B, $0B, $0C, $0D, $0D, $0E
    DB      $0F, $0F, $10, $11, $11, $12, $13, $13
    DB      $14, $15, $15, $16, $17, $17, $18, $19
    DB      $19, $1A, $1B, $1B, $1C, $1D, $1D, $1E
    DB      $1F, $1F, $20, $21, $21, $22, $23, $23
    DB      $24, $25, $25, $26, $27, $27, $27, $27

SUB_8F7B:
    LD      A, $03                      ; A = 3 (proximity shift count)
    LD      ($719A), A                  ; $719A = 3
    LD      HL, ($7196)                 ; HL = zone table pointer
    LD      A, ($7199)                  ; A = saved Y coordinate
    SUB     $04                         ; A -= 4 (shift Y back)
    LD      ($7199), A                  ; store updated Y
    CALL    SUB_8F2E                    ; A = proximity_table[Y >> 2]
    LD      ($7198), A                  ; $7198 = updated proximity value
    JR      LOC_8F9E                    ; check against zone

DELAY_LOOP_8F93:
    LD      HL, ($7196)                 ; HL = zone table pointer
    LD      A, ($7199)                  ; A = saved Y coordinate
    ADD     A, $09                      ; A += 9 (extend zone check)
    CALL    SUB_8F2E                    ; A = proximity_table[(Y+9) >> 2]

LOC_8F9E:
    CP      $28                         ; compare proximity to $28 (40 decimal threshold)
    RET     NC                          ; return if out of range (no carry)
    LD      C, A                        ; C = proximity value
    AND     $03                         ; keep lower 2 bits (sub-cell position)
    NEG                                 ; negate (compute bit shift)
    ADD     A, $04                      ; A += 4
    LD      B, A                        ; B = number of right-shifts
    LD      A, C                        ; A = proximity value
    SRL     A                           ; A >>= 1 (divide by 2)
    SRL     A                           ; A >>= 1 (compute index into zone table)
    CALL    SUB_869D                    ; A = zone_table[proximity >> 2]

LOC_8FB1:
    RR      A                           ; rotate right (test bit at shift position)
    DJNZ    LOC_8FB1                    ; repeat B times
    RET                                 ; return with carry = bit state (0=open, 1=wall)
    DB      $CD, $0B, $90, $18, $2D, $3A, $85, $72
    DB      $A7, $C0, $DD, $E5, $CD, $BB, $83, $DD
    DB      $E1, $CD, $03, $90, $18, $16, $CD, $0B
    DB      $90, $3E, $00, $18, $07, $CD, $03, $90
    DB      $3E, $01, $18, $00, $21, $BD, $72, $AE
    DB      $CB, $1F, $30, $06, $3A, $AA, $72, $3C
    DB      $18, $04, $3A, $AA, $72, $3D, $32, $AA
    DB      $72, $DD, $E5, $CD, $B5, $81, $DD, $E1
    DB      $3A, $B5, $71, $32, $91, $71, $3A, $BB
    DB      $71, $32, $92, $71, $C9

LOC_9003:
    LD      A, (IX+2)                   ; A = sprite X lower bound (IX+2)
    ADD     A, $01                      ; A += 1 (move right one pixel)
    JP      SUB_9153                    ; set sprite position to A

LOC_900B:
    LD      A, (IX+3)                   ; A = sprite X upper bound (IX+3)
    SUB     $01                         ; A -= 1 (move left one pixel)
    JP      SUB_9153                    ; set sprite position to A

SUB_9013:
    LD      IX, $71A3                   ; IX -> fuel-tank sprite 1 at $71A3
    LD      DE, $000C                   ; DE = X=$00, flags=$0C
    CALL    SUB_9027                    ; init fuel-tank sprite 1
    LD      IX, $71A9                   ; IX -> fuel-tank sprite 2 at $71A9
    LD      DE, $0020                   ; DE = X=$00, flags=$20
    JP      SUB_9027                    ; init fuel-tank sprite 2

SUB_9027:
    CALL    SUB_9160                    ; set sprite bounds (IX+2=D, IX+3=E)
    CALL    LOC_9179                    ; enable sprite (set bit 7 of IX+5)
    LD      A, $04                      ; A = 4 (fuel-tank pattern index)
    CALL    SUB_9153                    ; set sprite pattern to 4
    LD      D, $15                      ; D = $15 (Y position for fuel tank)
    LD      A, ($705D)                  ; A = player sprite color index (from level)
    LD      E, A                        ; E = color nibble
    CALL    SUB_9167                    ; set sprite velocity=D, color=E
    RET                                 ; return
    DB      $16, $EB, $18, $F4

DELAY_LOOP_9040:
    LD      IX, $719D                   ; IX -> sprite table base ($719D)
    LD      B, $09                      ; B = 9 (iterate all 9 sprite slots)

LOC_9046:
    CALL    SUB_9174                    ; disable sprite (clear bit 7 of IX+5)
    LD      DE, $0006                   ; DE = 6 (bytes per sprite entry)
    ADD     IX, DE                      ; IX += 6 (advance to next sprite slot)
    DJNZ    LOC_9046                    ; loop 9 times
    RET                                 ; return (all sprites disabled)

SOUND_WRITE_9051:
    CALL    DELAY_LOOP_9040             ; disable all 9 sprite slots
    CALL    SUB_A70E                    ; clear $7289, silence channel 1
    LD      A, $FF                      ; A = $FF
    LD      ($719B), A                  ; $719B = $FF (player-in-flight flag)
    LD      A, ($7285)                  ; A = enemy-visible flag
    LD      C, A                        ; C = enemy-visible flag
    LD      A, ($72E8)                  ; A = dynamite-active flag
    AND     C                           ; A = dynamite AND enemy-visible
    RET     Z                           ; return if neither active
    PUSH    IX                          ; save IX
    LD      IX, $71CD                   ; IX -> dynamite sprite struct
    CALL    LOC_9179                    ; enable dynamite sprite
    POP     IX                          ; restore IX
    RET                                 ; return
    DB      $CD, $B7, $89, $CD, $51, $90, $AF, $32
    DB      $BC, $71, $CD, $1B, $AA, $CD, $F7, $A1
    DB      $C3, $A0, $90

LOC_9084:
    LD      IX, $719D                   ; IX -> player sprite struct at $719D
    LD      DE, $0067                   ; DE = X=$00, flags=$67 (player start X)
    CALL    SUB_9160                    ; set player sprite X bounds
    LD      A, $00                      ; A = 0 (player pattern index)
    CALL    SUB_9153                    ; set player sprite pattern to 0
    LD      DE, $0301                   ; DE = velocity=$03, flags=$01
    CALL    SUB_9167                    ; set player velocity and flags
    CALL    LOC_9179                    ; enable player sprite
    CALL    SUB_89EF                    ; start fuel-pickup sound
    RET                                 ; return
    DB      $DD, $21, $9D, $71, $DD, $7E, $00, $A7
    DB      $28, $0C, $CD, $C7, $8A, $11, $05, $EC
    DB      $CD, $67, $91, $C3, $79, $91, $CD, $74
    DB      $91, $3A, $9B, $71, $A7, $CA, $46, $A5
    DB      $CD, $03, $8B, $3E, $0E, $32, $61, $70
    DB      $C9, $CD, $18, $8A, $CD, $74, $91, $3E
    DB      $FF, $32, $9C, $71, $3A, $2B, $70, $A7
    DB      $20, $06, $CD, $94, $84, $C3, $F1, $84
    DB      $CD, $ED, $90, $CD, $15, $A7, $CD, $ED
    DB      $81, $CD, $39, $85, $C9

SUB_90ED:
    XOR     A                           ; A = 0
    LD      ($719C), A                  ; $719C = 0 (clear hero-entry-anim flag)
    LD      ($719B), A                  ; $719B = 0 (clear player-in-flight flag)
    LD      IX, $719D                   ; IX -> player sprite struct
    LD      DE, $FB08                   ; DE = Y=$FB, flags=$08
    CALL    SUB_9167                    ; set player sprite velocity/flags
    CALL    LOC_9179                    ; enable player sprite
    CALL    SUB_8C97                    ; start hero entry (helicopter descent) animation
    LD      IX, $71A3                   ; IX -> fuel-tank sprite 1
    CALL    LOC_9179                    ; enable fuel-tank sprite 1
    LD      IX, $71A9                   ; IX -> fuel-tank sprite 2
    CALL    LOC_9179                    ; enable fuel-tank sprite 2
    LD      A, ($72E8)                  ; A = dynamite-active flag
    AND     A                           ; test if zero
    RET     Z                           ; return if no dynamite
    LD      IX, $71CD                   ; IX -> dynamite sprite struct
    JP      LOC_9179                    ; enable dynamite sprite
    DB      $CD, $44, $88, $3A, $9B, $71, $A7, $C8
    DB      $DD, $CB, $01, $7E, $C8, $3A, $A9, $72
    DB      $21, $3F, $91, $CD, $9D, $86, $E6, $0F
    DB      $57, $7E, $E6, $F0, $5F, $CD, $20, $87
    DB      $C9, $10, $20, $40, $60, $80, $01, $21
    DB      $51, $81, $12, $42, $72, $03, $03, $03
    DB      $03, $03, $03, $03, $03

; ; ---- SPRITE PHYSICS STRUCT (6 bytes at IX+0..5) ----
; ;   +0  integer position
; ;   +1  velocity (signed)
; ;   +2  lower bound
; ;   +3  upper bound
; ;   +4  fractional accumulator
; ;   +5  flags: bit7=active, bits5-4=clamp dir, bits3-0=velocity shift
; ; SUB_9153 -- set position (A), clear fraction, clamp, update flags

SUB_9153:
    LD      (IX+0), A                   ; set sprite integer position (IX+0) = A
    XOR     A                           ; A = 0
    LD      (IX+4), A                   ; clear fractional accumulator (IX+4) = 0
    CALL    SUB_917E                    ; clamp position to bounds, set clamp bits in C
    JP      SUB_919B                    ; write C into flags byte (IX+5 bits 5-4)

; ; SUB_9160 -- set bounds: upper=D, lower=E

SUB_9160:
    LD      (IX+2), D                   ; set upper bound (IX+2) = D
    LD      (IX+3), E                   ; set lower bound (IX+3) = E
    RET                                 ; return

; ; SUB_9167 -- set velocity: D=high, E=low nibble of flags

SUB_9167:
    LD      (IX+1), D                   ; set velocity byte (IX+1) = D
    LD      A, (IX+5)                   ; A = current flags byte
    AND     $F0                         ; keep upper nibble (active + clamp bits)
    OR      E                           ; merge lower nibble from E (velocity shift)
    LD      (IX+5), A                   ; store updated flags byte
    RET                                 ; return

; ; SUB_9174 -- disable sprite (clear bit 7 of flags)

SUB_9174:
    RES     7, (IX+5)                   ; clear bit 7 of IX+5 (disable sprite)
    RET                                 ; return

; ; LOC_9179 -- enable sprite (set bit 7 of flags)

LOC_9179:
    SET     7, (IX+5)                   ; set bit 7 of IX+5 (enable sprite)
    RET                                 ; return

; ; SUB_917E -- clamp position to bounds, set clamp-direction bits in C

SUB_917E:
    LD      C, $00                      ; C = 0 (no clamp)
    LD      A, (IX+0)                   ; A = current position
    LD      D, (IX+3)                   ; D = lower bound
    CP      D                           ; compare position to lower bound
    JR      C, LOC_918D                 ; if position < lower bound, clamp low
    LD      C, $20                      ; C = $20 (clamped at upper end)
    JR      LOC_9197                    ; write clamped position

LOC_918D:
    LD      D, A                        ; D = current position (unclamped candidate)
    LD      A, (IX+2)                   ; A = upper bound
    CP      D                           ; compare upper bound to position
    JR      C, LOC_9197                 ; if upper < position, no clamp needed
    LD      D, A                        ; D = upper bound (clamp to upper)
    LD      C, $10                      ; C = $10 (clamped at lower end)

LOC_9197:
    LD      (IX+0), D                   ; store clamped position
    RET                                 ; return

; ; SUB_919B -- write C into clamp-direction bits of flags byte

SUB_919B:
    LD      A, (IX+5)                   ; A = flags byte
    AND     $CF                         ; clear bits 5-4 (clamp direction bits)
    OR      C                           ; set new clamp direction bits from C
    LD      (IX+5), A                   ; store updated flags
    RET                                 ; return

; ; DELAY_LOOP_91A5 -- per-frame sprite update: integrate velocity into position, clamp, fire callbacks

DELAY_LOOP_91A5:
    LD      D, (IX+1)                   ; D = velocity byte
    LD      E, $00                      ; E = 0 (fractional velocity low byte)
    LD      A, (IX+5)                   ; A = flags byte
    AND     $0F                         ; keep lower nibble (velocity shift count)
    JR      Z, LOC_91B8                 ; if shift=0, use velocity as-is
    LD      B, A                        ; B = shift count

LOC_91B2:
    SRA     D                           ; D >>= 1 (arithmetic shift velocity high)
    RR      E                           ; E >>= 1 through carry (velocity low)
    DJNZ    LOC_91B2                    ; loop B times (divide velocity by 2^B)

LOC_91B8:
    LD      L, (IX+4)                   ; L = fractional position accumulator
    LD      H, (IX+0)                   ; H = integer position
    PUSH    HL                          ; save old position (H=integer, L=fraction)
    AND     A                           ; clear carry
    ADC     HL, DE                      ; HL = HL + DE (add velocity to position)
    RR      A                           ; A = carry from add
    XOR     D                           ; A = carry XOR velocity sign
    RL      A                           ; A = overflow flag in bit 0
    JR      NC, LOC_91D0               ; if no overflow, continue
    BIT     7, D                        ; test velocity sign bit
    LD      H, $00                      ; H = 0 (pre-load for negative clamp)
    JR      NZ, LOC_91D0               ; if negative velocity, continue
    DEC     H                           ; H = $FF (clamp to maximum)

LOC_91D0:
    LD      (IX+4), L                   ; store fractional accumulator
    LD      (IX+0), H                   ; store new integer position
    CALL    SUB_917E                    ; clamp position, get clamp bits in C
    LD      A, (IX+5)                   ; A = flags byte
    CPL                                 ; A = ~flags
    LD      B, A                        ; B = inverted flags
    CALL    SUB_919B                    ; write new clamp bits into flags
    AND     B                           ; A = new clamp bits AND inverted old flags
    LD      B, A                        ; B = change bits (which clamp edges triggered)
    POP     AF                          ; restore old position (was H before)
    CP      (IX+0)                      ; compare old to new position
    PUSH    IY                          ; save IY (callback table pointer)
    CALL    SUB_91F9                    ; fire position-change callback if needed
    BIT     4, B                        ; test bit 4 (lower-bound hit)
    CALL    SUB_91F9                    ; fire lower-bound callback if bit 4 set
    BIT     5, B                        ; test bit 5 (upper-bound hit)
    CALL    SUB_91F9                    ; fire upper-bound callback if bit 5 set
    POP     IY                          ; restore IY
    RET                                 ; return

; ; SUB_91F9 -- read next callback address from IY table, call it if nonzero

SUB_91F9:
    LD      E, (IY+0)                   ; E = callback address low byte
    LD      D, (IY+1)                   ; D = callback address high byte
    INC     IY                          ; IY++ (advance past low byte)
    INC     IY                          ; IY++ (advance past high byte)
    RET     Z                           ; return if DE=0 (no callback)
    PUSH    BC                          ; save BC
    PUSH    IX                          ; save IX
    PUSH    IY                          ; save IY
    CALL    SUB_9212                    ; call handler at DE
    POP     IY                          ; restore IY
    POP     IX                          ; restore IX
    POP     BC                          ; restore BC
    RET                                 ; return

SUB_9212:
    PUSH    DE                          ; push DE as return address (indirect call via PUSH/RET)
    RET                                 ; jump to DE (indirect call)

; ; DELAY_LOOP_9214 -- update all 9 sprite structs starting at $719D
; ;   IY = $8B46 (callback dispatch table)

DELAY_LOOP_9214:
    LD      B, $09                      ; B = 9 (number of sprite slots)
    LD      IX, $719D                   ; IX -> sprite table base
    LD      IY, $8B46                   ; IY -> callback dispatch table

LOC_921E:
    BIT     7, (IX+5)                   ; test bit 7 of flags (sprite enabled)
    PUSH    BC                          ; save loop counter
    CALL    NZ, DELAY_LOOP_91A5         ; if enabled, run physics update
    POP     BC                          ; restore counter
    LD      DE, $0006                   ; DE = 6 (bytes per sprite entry)
    ADD     IX, DE                      ; IX += 6 (advance to next sprite)
    ADD     IY, DE                      ; IY += 6 (advance to next callback entry)
    DJNZ    LOC_921E                    ; loop 9 times
    RET                                 ; return

SUB_9231:
    LD      DE, $71D3                   ; DE -> animation-state flag $71D3
    LD      HL, $92A3                   ; HL -> SOUND_WRITE_929D dispatch
    LD      A, (DE)                     ; A = $71D3 animation-state value
    LD      ($71D9), A                  ; $71D9 = copy of $71D3 state
    AND     A                           ; test if nonzero
    JR      Z, LOC_9247                 ; if zero, check $71D4 instead
    CALL    SUB_927C                    ; clear $71D3 and jump to $92A3 handler
    XOR     A                           ; A = 0
    LD      ($71D4), A                  ; $71D4 = 0 (clear secondary anim state)
    JR      LOC_9252                    ; continue to $71D7 check

LOC_9247:
    LD      DE, $71D4                   ; DE -> animation-state flag $71D4
    LD      HL, $977D                   ; HL -> SOUND_WRITE_9777 dispatch
    LD      A, (DE)                     ; A = $71D4 state
    AND     A                           ; test if nonzero
    CALL    NZ, SUB_927C                ; if nonzero, clear and jump to $977D

LOC_9252:
    LD      DE, $71D7                   ; DE -> animation-state flag $71D7
    LD      HL, $9C06                   ; HL -> LOC_9BF7 dispatch (level init)
    LD      A, (DE)                     ; A = $71D7 state
    AND     A                           ; test if nonzero
    JR      Z, LOC_9265                 ; if zero, check $71D6
    CALL    SUB_927C                    ; clear $71D7 and jump to level-init handler
    XOR     A                           ; A = 0
    LD      ($71D6), A                  ; $71D6 = 0 (clear enemy-anim state)
    JR      LOC_9270                    ; continue to $71D8 check

LOC_9265:
    LD      DE, $71D6                   ; DE -> animation-state flag $71D6
    LD      HL, $9BDF                   ; HL -> LOC_9BD9 dispatch (enemy init)
    LD      A, (DE)                     ; A = $71D6 state
    AND     A                           ; test if nonzero
    CALL    NZ, SUB_927C                ; if nonzero, clear and dispatch

LOC_9270:
    LD      DE, $71D8                   ; DE -> display-redraw flag $71D8
    LD      HL, $9285                   ; HL -> SUB_928C dispatch
    LD      A, (DE)                     ; A = $71D8 state
    AND     A                           ; test if nonzero
    CALL    NZ, SUB_927C                ; if nonzero, clear and dispatch
    RET                                 ; return

SUB_927C:
    XOR     A                           ; A = 0
    LD      (DE), A                     ; clear the animation-state flag at DE
    JP      (HL)                        ; jump to the dispatch handler

LOC_927F:
    LD      A, $FF                      ; A = $FF
    LD      ($71D8), A                  ; $71D8 = $FF (request display redraw)
    RET                                 ; return
    DB      $06, $01, $0E, $E2, $C3, $D9, $1F

SUB_928C:
    LD      A, ($71D9)                  ; A = $71D9 (mirror of $71D3 state)
    AND     A                           ; test if nonzero
    RET     NZ                          ; return if $71D3 animation still pending
    LD      DE, $71D5                   ; DE -> rotor-animation state $71D5
    LD      HL, $97B8                   ; HL -> LOC_97B2 dispatch (rotor anim)
    LD      A, (DE)                     ; A = $71D5 state
    AND     A                           ; test if nonzero
    CALL    NZ, SUB_927C                ; if nonzero, clear and dispatch rotor anim
    RET                                 ; return

SOUND_WRITE_929D:
    LD      A, $FF                      ; A = $FF
    LD      ($71D3), A                  ; $71D3 = $FF (trigger animation state)
    RET                                 ; return
    DB      $CD, $CE, $83, $FD, $21, $00, $18, $21
    DB      $C6, $72, $3E, $00, $32, $DA, $71, $0E
    DB      $E0, $CD, $C1, $97, $CD, $EA, $92, $DD
    DB      $21, $F9, $70, $CD, $12, $93, $3E, $01
    DB      $32, $DA, $71, $DD, $21, $19, $71, $CD
    DB      $12, $93, $3E, $02, $32, $DA, $71, $DD
    DB      $21, $39, $71, $CD, $12, $93, $21, $DA
    DB      $72, $0E, $F0, $CD, $C1, $97, $CD, $AB
    DB      $8D, $CC, $F7, $A1, $C3, $97, $AE, $21
    DB      $C6, $72, $11, $D9, $70, $0E, $00, $D5
    DB      $CD, $E3, $96, $E1, $01, $20, $00, $ED
    DB      $B0, $21, $D0, $72, $0E, $00, $CD, $E3
    DB      $96, $21, $DA, $72, $D5, $CD, $E3, $96
    DB      $E1, $01, $20, $00, $ED, $B0, $C9, $AF
    DB      $32, $DC, $71, $32, $DB, $71, $DD, $E5
    DB      $06, $20, $11, $79, $70, $C5, $DD, $7E
    DB      $00, $FE, $00, $CA, $03, $94, $FE, $01
    DB      $CA, $E5, $94, $C3, $4B, $93, $12, $13
    DB      $DD, $23, $21, $DC, $71, $34, $C1, $10
    DB      $E4, $DD, $E1, $CD, $0C, $98, $21, $DB
    DB      $71, $34, $7E, $FE, $05, $38, $CF, $C9
    DB      $3A, $C4, $72, $E6, $02, $28, $08, $3A
    DB      $DA, $71, $FE, $01, $CA, $CC, $93, $3A
    DB      $DB, $71, $A7, $28, $07, $FE, $04, $28
    DB      $1D, $C3, $B0, $93, $DD, $7E, $E0, $A7
    DB      $CA, $9B, $93, $3A, $C4, $72, $E6, $02
    DB      $CA, $B0, $93, $3A, $DA, $71, $FE, $02
    DB      $C2, $B0, $93, $C3, $9B, $93, $DD, $7E
    DB      $20, $A7, $CA, $AB, $93, $3A, $C4, $72
    DB      $E6, $02, $CA, $B0, $93, $3A, $DA, $71
    DB      $FE, $00, $C2, $B0, $93, $C3, $AB, $93
    DB      $21, $E7, $93, $DD, $7E, $00, $D6, $02
    DB      $CD, $9D, $86, $C6, $19, $C3, $31, $93
    DB      $21, $EB, $93, $18, $EE, $21, $D3, $93
    DB      $06, $19, $DD, $7E, $00, $D6, $02, $4F
    DB      $CB, $27, $CB, $27, $81, $4F, $3A, $DB
    DB      $71, $81, $CD, $9D, $86, $80, $C3, $31
    DB      $93, $21, $EF, $93, $06, $27, $18, $E2
    DB      $02, $00, $00, $04, $02, $01, $05, $01
    DB      $05, $01, $02, $04, $02, $04, $02, $03
    DB      $03, $05, $05, $03, $06, $07, $08, $09
    DB      $0A, $0B, $0C, $0D, $01, $04, $01, $04
    DB      $01, $00, $05, $05, $00, $00, $02, $04
    DB      $04, $02, $03, $02, $05, $05, $02, $03
    DB      $3A, $DB, $71, $FE, $03, $DD, $7E, $E0
    DB      $38, $03, $DD, $7E, $20, $FE, $01, $CA
    DB      $18, $94, $C3, $26, $94, $21, $45, $94
    DB      $CD, $CB, $96, $CD, $9D, $86, $C6, $0C
    DB      $C3, $31, $93, $21, $00, $90, $3A, $DA
    DB      $71, $CB, $27, $CB, $27, $CD, $9D, $86
    DB      $3A, $DC, $71, $CD, $9D, $86, $E6, $0F
    DB      $FE, $03, $38, $01, $AF, $C6, $16, $C3
    DB      $31, $93, $04, $06, $05, $05, $06, $04
    DB      $06, $06, $04, $06, $05, $06, $05, $04
    DB      $06, $05, $04, $06, $06, $05, $04, $04
    DB      $06, $04, $05, $06, $05, $05, $06, $04
    DB      $05, $05, $0A, $0B, $00, $0C, $0A, $0B
    DB      $03, $0A, $0B, $00, $0A, $0C, $0A, $0B
    DB      $00, $0B, $0A, $0B, $0A, $01, $0B, $00
    DB      $0A, $0A, $00, $0B, $03, $01, $0A, $0B
    DB      $00, $0A, $0C, $0A, $01, $0A, $0C, $0A
    DB      $01, $0C, $0A, $01, $0A, $0A, $0C, $0A
    DB      $01, $0C, $0A, $01, $0B, $0A, $0A, $0C
    DB      $0A, $0A, $01, $0A, $01, $0B, $0A, $03
    DB      $01, $0B, $0A, $03, $0B, $02, $0B, $0A
    DB      $02, $0B, $0A, $03, $0C, $0A, $01, $0C
    DB      $02, $0A, $0C, $02, $03, $0C, $0B, $0A
    DB      $0B, $0C, $02, $0C, $03, $0C, $0A, $02
    DB      $0C, $0A, $07, $08, $09, $07, $07, $09
    DB      $09, $08, $07, $09, $07, $08, $09, $08
    DB      $09, $08, $09, $07, $07, $07, $08, $09
    DB      $08, $09, $08, $07, $09, $08, $09, $07
    DB      $08, $08, $3A, $C4, $72, $E6, $02, $28
    DB      $08, $3A, $DA, $71, $FE, $01, $CA, $64
    DB      $95, $3A, $DB, $71, $A7, $28, $07, $FE
    DB      $04, $28, $1D, $C3, $55, $95, $DD, $7E
    DB      $E0, $A7, $CA, $35, $95, $3A, $C4, $72
    DB      $E6, $02, $CA, $55, $95, $3A, $DA, $71
    DB      $FE, $02, $C2, $55, $95, $C3, $35, $95
    DB      $DD, $7E, $20, $A7, $CA, $43, $95, $3A
    DB      $C4, $72, $E6, $02, $CA, $55, $95, $3A
    DB      $DA, $71, $FE, $00, $C2, $55, $95, $C3
    DB      $43, $95, $21, $0B, $96, $3A, $DC, $71
    DB      $E6, $1F, $CD, $9D, $86, $C3, $31, $93
    DB      $21, $0B, $96, $3A, $DC, $71, $ED, $44
    DB      $E6, $1F, $CD, $9D, $86, $C6, $03, $C3
    DB      $31, $93, $21, $6B, $95, $06, $00, $CD
    DB      $CB, $96, $CD, $9D, $86, $80, $C3, $31
    DB      $93, $21, $2B, $96, $06, $27, $18, $EF
    DB      $04, $01, $05, $04, $00, $01, $04, $05
    DB      $01, $00, $02, $02, $04, $01, $04, $05
    DB      $04, $00, $02, $03, $02, $04, $05, $01
    DB      $00, $01, $04, $02, $01, $00, $00, $04
    DB      $02, $02, $00, $04, $02, $03, $02, $03
    DB      $02, $04, $00, $05, $02, $03, $02, $04
    DB      $05, $04, $05, $00, $05, $05, $04, $00
    DB      $02, $02, $03, $02, $03, $02, $04, $05
    DB      $02, $00, $03, $02, $01, $00, $01, $00
    DB      $04, $02, $03, $02, $00, $00, $04, $02
    DB      $03, $05, $04, $02, $03, $03, $02, $02
    DB      $04, $01, $00, $05, $00, $04, $02, $03
    DB      $01, $04, $01, $00, $01, $04, $04, $02
    DB      $05, $04, $01, $00, $04, $05, $05, $04
    DB      $00, $00, $05, $04, $00, $00, $00, $05
    DB      $02, $05, $04, $00, $02, $05, $04, $00
    DB      $00, $02, $03, $02, $04, $00, $02, $05
    DB      $00, $02, $02, $04, $02, $03, $00, $05
    DB      $02, $02, $04, $05, $02, $02, $05, $04
    DB      $00, $02, $03, $02, $04, $00, $05, $02
    DB      $06, $07, $08, $07, $07, $08, $06, $07
    DB      $08, $06, $07, $08, $06, $07, $08, $06
    DB      $07, $06, $08, $06, $08, $07, $08, $07
    DB      $07, $06, $06, $07, $06, $08, $06, $07
    DB      $04, $05, $03, $03, $04, $03, $04, $03
    DB      $02, $05, $02, $05, $03, $03, $04, $02
    DB      $03, $01, $02, $04, $02, $03, $04, $03
    DB      $02, $03, $05, $02, $05, $02, $05, $03
    DB      $03, $03, $04, $02, $03, $04, $03, $04
    DB      $03, $03, $04, $02, $03, $02, $02, $04
    DB      $02, $04, $03, $02, $04, $02, $02, $04
    DB      $03, $02, $02, $04, $02, $03, $04, $04
    DB      $02, $02, $04, $04, $03, $03, $02, $04
    DB      $02, $04, $03, $05, $04, $02, $03, $03
    DB      $05, $04, $03, $03, $02, $05, $02, $01
    DB      $02, $02, $04, $02, $03, $05, $02, $03
    DB      $05, $04, $02, $04, $05, $03, $04, $03
    DB      $05, $01, $01, $03, $02, $05, $03, $04
    DB      $02, $03, $02, $05, $03, $03, $03, $04
    DB      $05, $03, $05, $03, $04, $03, $03, $02
    DB      $03, $02, $04, $02, $04, $02, $03, $03
    DB      $03, $04, $02, $04, $03, $03, $02, $03
    DB      $02, $05, $04, $02, $04, $04, $02, $03
    DB      $02, $04, $03, $02, $05, $03, $02, $05
    DB      $3A, $DC, $71, $4F, $3A, $DA, $71, $CB
    DB      $27, $CB, $27, $CB, $27, $81, $E6, $1F
    DB      $4F, $3A, $DC, $71, $E6, $E0, $B1, $C9
    DB      $C5, $E5, $DD, $E5, $E5, $DD, $E1, $06
    DB      $01, $13, $D5, $DD, $7E, $00, $CB, $27
    DB      $DD, $86, $00, $21, $47, $97, $CD, $9D
    DB      $86, $23, $FE, $01, $CC, $2B, $97, $81
    DB      $12, $13, $04, $7E, $23, $81, $12, $13
    DB      $04, $7E, $FE, $01, $CC, $39, $97, $81
    DB      $12, $13, $04, $DD, $23, $78, $FE, $1F
    DB      $38, $D1, $1B, $1A, $13, $12, $13, $E1
    DB      $7E, $2B, $77, $DD, $E1, $E1, $C1, $C9
    DB      $DD, $CB, $FF, $46, $C0, $78, $FE, $01
    DB      $3E, $01, $C8, $3E, $05, $C9, $DD, $CB
    DB      $01, $5E, $C0, $78, $FE, $1E, $3E, $01
    DB      $C8, $3E, $04, $C9, $00, $00, $00, $00
    DB      $00, $05, $00, $03, $00, $00, $03, $01
    DB      $03, $02, $00, $03, $02, $05, $03, $04
    DB      $00, $03, $01, $01, $02, $00, $00, $02
    DB      $00, $05, $02, $03, $00, $02, $03, $01
    DB      $01, $02, $00, $01, $02, $05, $01, $04
    DB      $00, $01, $01, $01

SOUND_WRITE_9777:
    LD      A, $FF                      ; A = $FF
    LD      ($71D4), A                  ; $71D4 = $FF (trigger secondary anim state)
    RET                                 ; return
    DB      $3A, $86, $72, $A7, $28, $06, $CD, $B9
    DB      $A8, $CD, $10, $A8, $CD, $CE, $83, $CD
    DB      $EA, $92, $FD, $21, $C0, $18, $3E, $01
    DB      $32, $DA, $71, $DD, $21, $19, $71, $CD
    DB      $12, $93, $C9

SUB_97A0:
    LD      A, ($72E9)                  ; A = rotor-animation-enable flag
    AND     A                           ; test if nonzero
    RET     Z                           ; return if rotor animation disabled
    LD      A, ($7067)                  ; A = frame counter
    NEG                                 ; A = -frame_counter
    AND     $03                         ; keep bits 1-0 (0-3 cycle)
    CP      $03                         ; compare to 3
    JP      Z, LOC_97B2                 ; if frame & 3 == 3, trigger rotor anim
    RET                                 ; else return without triggering

LOC_97B2:
    LD      A, $FF                      ; A = $FF
    LD      ($71D5), A                  ; $71D5 = $FF (trigger rotor-animation state)
    RET                                 ; return
    DB      $FD, $21, $00, $1A, $21, $DA, $72, $0E
    DB      $F0, $11, $79, $70, $CD, $E3, $96, $79
    DB      $FE, $F0, $0E, $03, $20, $10, $3A, $E9
    DB      $72, $A7, $28, $0A, $3A, $67, $70, $ED
    DB      $44, $CB, $3F, $CB, $3F, $4F, $E5, $21
    DB      $79, $70, $06, $20, $CB, $56, $28, $06
    DB      $7E, $E6, $F8, $F6, $01, $77, $78, $E6
    DB      $07, $28, $07, $CB, $58, $20, $02, $0C
    DB      $0C, $0D, $79, $CB, $57, $28, $01, $2F
    DB      $E6, $03, $CB, $27, $CB, $27, $86, $77
    DB      $23, $10, $D9, $E1, $FD, $E5, $D1, $0E
    DB      $20, $CD, $FA, $86, $D5, $FD, $E1, $C9

LOC_9818:
    LD      A, ($72C4)                  ; A = level rotor-speed index byte
    SRL     A                           ; A >>= 1
    SRL     A                           ; A >>= 1 (A = bits 3-2 of $72C4)
    SLA     A                           ; A <<= 1 (restore one bit, keep bit pattern)
    LD      B, A                        ; B = intermediate rotor value
    SLA     A                           ; A <<= 1 (multiply by 2 more)
    ADD     A, B                        ; A = A*2 + B (A = 3x original shifted)
    ADD     A, $08                      ; A += 8 (rotor base frame offset)
    BIT     1, B                        ; test bit 1 of B (even/odd rotor group)
    JR      Z, LOC_982D                 ; if bit 1 clear, skip adjustment
    SUB     $02                         ; A -= 2 (adjust for odd rotor group)

LOC_982D:
    LD      ($71DD), A                  ; $71DD = rotor-frame index for VRAM
    SRL     A                           ; A >>= 1
    SRL     A                           ; A >>= 1
    SRL     A                           ; A >>= 3 total (strip frame sub-index)
    LD      HL, $18C0                   ; HL -> rotor color/shape lookup table
    CALL    SUB_869D                    ; A = table[$71DD>>3] (rotor shape/color)
    DB      $EB                         ; EX DE,HL (DE=table result, HL=old DE)
    LD      B, $05                      ; B = 5 (column count)
    CALL    DELAY_LOOP_A4F9             ; draw rotor tiles into VRAM
    LD      C, $01                      ; C = 1 (default: right rotor active)
    JR      NZ, LOC_9848               ; if NZ, rotor right active
    LD      C, $00                      ; C = 0 (rotor right inactive)

LOC_9848:
    LD      B, $04                      ; B = 4 (column count for inner rotor)
    CALL    DELAY_LOOP_A4F9             ; draw inner rotor tiles
    LD      A, $01                      ; A = 1 (default: left rotor active)
    JR      NZ, LOC_9852               ; if NZ, left rotor active
    XOR     A                           ; A = 0 (left rotor inactive)

LOC_9852:
    ADD     A, C                        ; A = left + right rotor active count
    JR      Z, LOC_985F                 ; if both inactive, use LOC_985F strip
    DEC     A                           ; A -= 1
    JR      Z, LOC_985A                 ; if exactly one active, use LOC_985A strip
    JR      LOC_986F                    ; both active: use LOC_986F strip

LOC_985A:
    LD      HL, $989A                   ; HL -> single-rotor strip table
    JR      LOC_9862                    ; draw strip

LOC_985F:
    LD      HL, $9886                   ; HL -> no-rotor strip table

LOC_9862:
    CALL    SUB_987B                    ; draw rotor hub tile based on $71DD
    CALL    DELAY_LOOP_98B8             ; write 5 tiles from HL to VRAM
    LD      BC, $0005                   ; BC = 5 (advance to next strip row)
    ADD     HL, BC                      ; HL -> second strip row
    JP      DELAY_LOOP_98B8             ; write second strip row and return

LOC_986F:
    LD      HL, $98AE                   ; HL -> both-rotors strip table
    CALL    DELAY_LOOP_98B8             ; write strip row
    LD      HL, $98B3                   ; HL -> second both-rotors strip row
    JP      DELAY_LOOP_98B8             ; write second row and return

SUB_987B:
    LD      A, ($71DD)                  ; A = rotor-frame index
    BIT     2, A                        ; test bit 2 (sub-frame selector)
    RET     NZ                          ; return if bit 2 set (no hub tile needed)
    LD      A, $0A                      ; A = 10 (hub tile offset)
    JP      SUB_869D                    ; A = hub_table[10] and return
    DB      $B7, $B6, $B7, $B6, $B7, $B8, $B9, $B8
    DB      $B9, $B8, $BB, $BA, $BB, $BA, $BB, $BC
    DB      $BD, $BC, $BD, $BC, $2E, $2D, $2E, $2D
    DB      $2E, $2F, $30, $2F, $30, $2F, $32, $31
    DB      $32, $31, $32, $33, $34, $33, $34, $33
    DB      $12, $17, $16, $18, $35, $12, $16, $18
    DB      $16, $36

DELAY_LOOP_98B8:
    PUSH    HL                          ; save HL (strip table pointer)
    PUSH    DE                          ; save DE (VRAM destination)
    LD      B, $05                      ; B = 5 (tiles per strip row)

LOC_98BC:
    PUSH    BC                          ; save loop counter
    LD      A, (HL)                     ; A = tile index from strip table
    INC     HL                          ; advance strip table pointer
    LD      ($7079), A                  ; $7079 = tile index (VRAM write buffer)
    LD      C, $01                      ; C = 1 (write 1 tile)
    CALL    SOUND_WRITE_86FA            ; flush 1 tile from buffer to VRAM at DE
    DB      $EB                         ; EX DE,HL (swap VRAM pointer and strip pointer)
    LD      BC, $001F                   ; BC = 31 (VRAM row stride - 1)
    ADD     HL, BC                      ; HL = VRAM pointer + 32 (next row)
    DB      $EB                         ; EX DE,HL (restore DE=VRAM, HL=strip table)
    POP     BC                          ; restore loop counter
    DJNZ    LOC_98BC                    ; loop for 5 tiles
    POP     DE                          ; restore DE
    POP     HL                          ; restore HL
    INC     DE                          ; DE++ (advance VRAM column by 1)
    RET                                 ; return

SUB_98D4:
    CALL    SUB_86C7                    ; decode RLE data from HL into buffer at $7079
    JP      SOUND_WRITE_86FA            ; flush decoded buffer to VRAM at DE

DELAY_LOOP_98DA:
    PUSH    BC                          ; save outer loop counter (B = strip count)
    LD      C, (HL)                     ; C = tile pattern byte from table
    INC     HL                          ; advance table pointer
    CALL    DELAY_LOOP_98E9             ; expand C as bit-mask into 32-byte VRAM buffer
    LD      C, $20                      ; C = $20 (32 bytes = one VRAM row)
    CALL    SOUND_WRITE_86FA            ; flush 32 bytes to VRAM at DE
    POP     BC                          ; restore outer counter
    DJNZ    DELAY_LOOP_98DA             ; loop B times
    RET                                 ; return

DELAY_LOOP_98E9:
    PUSH    DE                          ; save DE (VRAM destination)
    PUSH    HL                          ; save HL (source table pointer)
    LD      DE, $7079                   ; DE -> VRAM write buffer
    LD      HL, $B2D9                   ; HL -> bit-expansion pattern table
    LD      B, $04                      ; B = 4 (4 bytes = 32 bits to expand)

LOC_98F3:
    PUSH    BC                          ; save outer counter
    LD      B, $08                      ; B = 8 bits per byte

LOC_98F6:
    LD      A, (HL)                     ; A = pattern byte
    RLC     C                           ; rotate C left (get next pattern bit)
    JR      C, LOC_98FC                 ; if bit set, use pattern byte A
    XOR     A                           ; else A = 0 (transparent pixel)

LOC_98FC:
    LD      (DE), A                     ; write pixel byte to buffer
    INC     DE                          ; advance buffer pointer
    DJNZ    LOC_98F6                    ; loop 8 bits
    INC     HL                          ; advance pattern table row
    POP     BC                          ; restore outer counter
    DJNZ    LOC_98F3                    ; loop 4 rows
    POP     HL                          ; restore HL
    POP     DE                          ; restore DE
    RET                                 ; return
    DB      $01, $03, $07, $0F, $E0, $F0, $F8, $FC
    DB      $E0, $20, $63, $F7, $DF, $FD, $BC, $EF
    DB      $7B, $00, $40, $D9, $FD, $FF, $F9, $ED
    DB      $DF, $FB, $6E, $FB, $B7, $FF, $FD, $D8
    DB      $08, $F7, $9D, $FE, $B7, $CF, $85, $00
    DB      $00, $BE, $FB, $DF, $E7, $EF, $BC, $FB
    DB      $6F, $6F, $F6, $1D, $DF, $7B, $F2, $DB
    DB      $BE, $FF, $7F, $7F, $1C, $0C, $0C, $98
    DB      $C1, $FB, $F9, $79, $04, $06, $DD, $B7
    DB      $FE, $DF, $8F, $43, $21, $34, $DE, $FB
    DB      $FF, $BE, $EB, $F1, $20, $06, $8F, $DB
    DB      $F7, $BA, $DF, $D6, $73, $30, $10, $84
    DB      $EF, $C7, $10, $10, $30, $30, $3C, $7F
    DB      $FF, $D0, $95, $55, $4A, $32, $2A, $24
    DB      $2C, $14, $1C, $08, $0C, $08, $08, $10
    DB      $1C, $14, $1C, $34, $24, $2C, $EA, $A2
    DB      $56, $55, $38, $11, $12, $02, $24, $1A
    DB      $08, $11, $FD, $D5, $6C, $54, $2C, $06
    DB      $82, $15, $EF, $76, $34, $2E, $4C, $BA
    DB      $E0, $04, $BF, $DB, $7A, $60, $40, $02
    DB      $42, $04, $02, $05, $66, $04, $2A, $6C
    DB      $C5, $BD, $41, $C0, $B2, $58, $34, $34
    DB      $54, $EE, $04, $42, $02, $40, $60, $7A
    DB      $DB, $BF, $0B, $00, $8D, $04, $00, $00
    DB      $10, $00, $00, $40, $00, $00, $20, $01
    DB      $00, $00, $00, $F0, $E8, $E0, $B0, $E0
    DB      $C1, $E0, $F0, $74, $27, $0E, $07, $03
    DB      $4F, $0D, $07, $17, $7E, $FE, $D3, $F6
    DB      $FC, $BE, $6B, $FE, $7F, $DD, $6F, $3F
    DB      $F7, $CE, $7F, $77, $F8, $EC, $FC, $B8
    DB      $F1, $F8, $78, $F4, $1D, $0F, $0B, $0F
    DB      $1F, $37, $3F, $1E, $84, $C0, $E2, $C0
    DB      $E8, $F0, $D1, $70, $01, $03, $16, $07
    DB      $4F, $0D, $0F, $17, $C4, $70, $D0, $F8
    DB      $BF, $FF, $B7, $DE, $85, $0F, $17, $7E
    DB      $BF, $F7, $FB, $DF, $B1, $F0, $F0, $C0
    DB      $E2, $E0, $C0, $80, $4E, $0F, $0F, $07
    DB      $06, $8B, $07, $03, $BF, $EE, $FB, $7F
    DB      $BA, $F0, $E8, $C0, $BE, $EF, $EF, $F7
    DB      $3E, $17, $0F, $43, $B0, $04, $0B, $1B
    DB      $0E, $06, $1B, $0D, $0D, $D0, $B0, $60
    DB      $B0, $F8, $78, $B0, $90, $8E, $FF, $59
    DB      $51, $87, $BC, $FF, $7C, $3C, $78, $E2
    DB      $F6, $77, $F3, $DD, $0D, $3C, $F8, $F0
    DB      $AC, $84, $BE, $E8, $CC, $1E, $3F, $79
    DB      $37, $06, $3C, $1F, $1F, $D0, $0E, $0E
    DB      $04, $00, $02, $05, $01, $03, $07, $07
    DB      $03, $00, $04, $03, $07, $0F, $80, $86
    DB      $37, $7B, $7D, $3C, $08, $62, $F0, $EE
    DB      $DE, $1E, $EC, $E3, $E7, $CE, $EF, $EE
    DB      $4D, $01, $2E, $5E, $1E, $3C, $78, $78
    DB      $33, $07, $47, $33, $70, $F6, $00, $60
    DB      $70, $B0, $D0, $C0, $80, $20, $00, $E0
    DB      $E0, $E0, $C0, $30, $70, $E0, $00, $00
    DB      $02, $14, $01, $8C, $1D, $3B, $00, $00
    DB      $00, $D2, $E4, $70, $86, $EF, $00

SUB_9AC6:
    LD      DE, BOOT_UP                 ; DE = $0000 (VRAM destination offset 0)
    LD      HL, $990F                   ; HL -> title-screen RLE data block 1
    CALL    SUB_98D4                    ; RLE-decode and write to VRAM at $0000
    CALL    SUB_98D4                    ; decode next block to VRAM
    LD      DE, $0800                   ; DE = $0800 (VRAM color table offset)
    LD      HL, $990F                   ; HL -> same title data (color layer)
    CALL    SUB_98D4                    ; RLE-decode color data to VRAM $0800
    CALL    SUB_98D4                    ; decode next color block
    LD      DE, $05B0                   ; DE = $05B0 (VRAM pattern table region)
    LD      HL, $9B85                   ; HL -> title pattern RLE data
    CALL    SUB_98D4                    ; decode pattern block A to VRAM $05B0
    LD      HL, $A12E                   ; HL -> title pattern RLE data block B
    CALL    SUB_98D4                    ; decode pattern block B
    LD      DE, $0DB0                   ; DE = $0DB0 (second pattern table region)
    LD      HL, $9B85                   ; HL -> same pattern data (second copy)
    CALL    SUB_98D4                    ; decode to VRAM $0DB0
    LD      HL, $A12E                   ; HL -> pattern block B (second copy)
    CALL    SUB_98D4                    ; decode second copy of block B
    LD      HL, $A23A                   ; HL -> sprite/HUD pattern RLE data
    CALL    SUB_98D4                    ; decode sprite patterns to VRAM
    CALL    SUB_AA6F                    ; initialize sprite attributes in VRAM
    CALL    SOUND_WRITE_86FA            ; flush VRAM write buffer
    LD      DE, $0700                   ; DE = $0700 (name table region A)
    LD      HL, $9907                   ; HL -> name table RLE data
    LD      B, $04                      ; B = 4 (4 rows to decode)
    CALL    DELAY_LOOP_98DA             ; decode 4 name-table rows to VRAM $0700
    LD      DE, $0F00                   ; DE = $0F00 (name table region B)
    LD      HL, $9907                   ; HL -> same name table data (second copy)
    LD      B, $04                      ; B = 4
    CALL    DELAY_LOOP_98DA             ; decode 4 rows to VRAM $0F00
    LD      DE, $25B0                   ; DE = $25B0 (sprite pattern bank)
    LD      HL, $9BC7                   ; HL -> sprite RLE block C
    CALL    SUB_98D4                    ; decode sprite patterns to $25B0
    LD      HL, $A1C1                   ; HL -> sprite RLE block D
    CALL    SUB_98D4                    ; decode sprite patterns (block D)
    LD      DE, $2DB0                   ; DE = $2DB0 (second sprite pattern bank)
    LD      HL, $9BC7                   ; HL -> sprite block C (second copy)
    CALL    SUB_98D4                    ; decode to $2DB0
    LD      HL, $A1C1                   ; HL -> sprite block D (second copy)
    CALL    SUB_98D4                    ; decode second copy
    LD      HL, $A27A                   ; HL -> additional graphics RLE data
    CALL    SUB_86C7                    ; decode to VRAM write buffer (no auto-flush)
    LD      DE, $7089                   ; DE -> RAM buffer at $7089
    LD      BC, $0710                   ; BC = $0710 (source length, dest count)
    CALL    DELAY_LOOP_86AC             ; copy decoded data block to RAM $7089
    LD      C, $80                      ; C = $80 (128 bytes)
    LD      DE, $2E80                   ; DE = VRAM $2E80 (sprite generator table)
    CALL    SOUND_WRITE_86FA            ; flush 128 bytes to VRAM sprite table
    LD      HL, $B054                   ; HL -> enemy sprite RLE data block
    LD      DE, $1000                   ; DE = $1000 (VRAM pattern offset)
    CALL    SUB_98D4                    ; decode enemy pattern block 1
    CALL    SUB_98D4                    ; decode block 2
    CALL    SUB_98D4                    ; decode block 3
    LD      HL, $B252                   ; HL -> second enemy sprite RLE data
    LD      DE, $3000                   ; DE = $3000 (second VRAM pattern bank)
    CALL    SUB_98D4                    ; decode enemy pattern block 1 (bank 2)
    CALL    SUB_98D4                    ; decode block 2 (bank 2)
    CALL    SUB_98D4                    ; decode block 3 (bank 2)
    LD      HL, $B29A                   ; HL -> miscellaneous sprite RLE data
    LD      DE, $1A20                   ; DE = $1A20 (VRAM misc pattern region)
    CALL    SUB_98D4                    ; decode misc patterns
    LD      HL, $990B                   ; HL -> final name table RLE data
    LD      DE, $1780                   ; DE = $1780 (name table final region)
    LD      B, $04                      ; B = 4 rows
    JP      DELAY_LOOP_98DA             ; decode 4 final name-table rows and return
    DB      $C0, $07, $0F, $0F, $04, $01, $07, $0F
    DB      $0F, $0F, $0F, $07, $08, $1E, $1D, $1B
    DB      $0B, $C6, $DF, $9F, $3F, $3F, $9F, $DE
    DB      $C0, $F6, $F6, $EE, $0E, $EC, $F3, $F7
    DB      $E1, $3F, $7F, $7F, $78, $27, $0F, $3F
    DB      $7F, $7E, $7E, $3C, $41, $F1, $EC, $DE
    DB      $5E, $30, $F8, $F8, $F8, $F8, $F8, $F0
    DB      $00, $B0, $B0, $70, $70, $60, $98, $B8
    DB      $08, $00, $40, $E0, $00

SUB_9BCA:
    LD      DE, $71DE                   ; DE -> enemy struct array at $71DE
    LD      C, $30                      ; C = $30 (48 bytes = first block size)
    LD      A, $60                      ; A = $60 (fill value for enemy X positions)
    CALL    DELAY_LOOP_86A4             ; fill 48 bytes at $71DE with $60
    LD      A, $80                      ; A = $80 (fill value for second block)
    JP      DELAY_LOOP_86A4             ; fill remaining bytes and return

LOC_9BD9:
    LD      A, $FF                      ; A = $FF
    LD      ($71D6), A                  ; $71D6 = $FF (trigger enemy-init state)
    RET                                 ; return
    DB      $3A, $62, $70, $A7, $21, $DE, $71, $28
    DB      $03, $21, $0E, $72, $11, $38, $21, $CD
    DB      $F4, $86, $11, $38, $29, $C3, $F4, $86

LOC_9BF7:
    CALL    SOUND_WRITE_82DB            ; reset sound and clear level state
    CALL    SUB_9C12                    ; load level configuration data
    JP      LOC_9C00                    ; mark level-init complete

LOC_9C00:
    LD      A, $FF                      ; A = $FF
    LD      ($71D7), A                  ; $71D7 = $FF (trigger level-display state)
    RET                                 ; return
    DB      $CD, $6B, $9C, $CD, $B4, $9C, $CD, $FE
    DB      $9C, $C3, $0D, $9D

SUB_9C12:
    LD      A, ($72A9)                  ; A = current level index (0-19)
    AND     $03                         ; keep bits 1-0 (level mod 4)
    SLA     A                           ; A *= 2 (word index into pointer table)
    LD      HL, $9C63                   ; HL -> level-config pointer table
    CALL    SUB_869D                    ; E = low byte of level-config pointer
    LD      E, A                        ; E = level config address low
    INC     HL                          ; HL -> high byte entry
    LD      D, (HL)                     ; D = level config address high
    DB      $EB                         ; EX DE,HL (HL = level config address)
    LD      ($7241), HL                 ; $7241 = level config base address
    LD      A, ($723E)                  ; A = bonus-level flag
    AND     A                           ; test if nonzero
    JR      Z, LOC_9C43                 ; if zero, use standard config
    LD      HL, $A098                   ; HL -> hard-mode level config
    LD      A, ($7063)                  ; A = difficulty/level counter
    CP      $02                         ; compare to 2
    JR      C, LOC_9C43                 ; if < 2, not hard enough for override
    LD      A, ($7065)                  ; A = difficulty threshold value
    LD      C, A                        ; C = threshold
    LD      A, ($72AA)                  ; A = difficulty cycle counter
    CP      C                           ; compare cycle to threshold
    JR      NZ, LOC_9C43               ; if not at threshold, use standard config
    LD      HL, $A078                   ; HL -> bonus-difficulty level config

LOC_9C43:
    LD      ($723F), HL                 ; $723F = selected level config pointer
    PUSH    HL                          ; save config pointer
    POP     IX                          ; IX = level config structure
    LD      A, (IX+8)                   ; A = level enemy-type byte (offset 8)
    LD      ($7243), A                  ; $7243 = current enemy type
    LD      A, ($72C4)                  ; A = level rotor/difficulty flags
    BIT     1, A                        ; test bit 1 (hard-mode speed flag)
    JR      NZ, LOC_9C5C               ; if hard mode, skip overwriting $7244
    LD      A, (IX+8)                   ; A = enemy type (standard mode)
    LD      ($7244), A                  ; $7244 = standard-mode enemy type

LOC_9C5C:
    LD      A, (IX+8)                   ; A = enemy type
    LD      ($7245), A                  ; $7245 = alternate enemy-type copy
    RET                                 ; return
    DB      $20, $9E, $58, $9D, $B0, $9F, $E8, $9E
    DB      $2A, $3F, $72, $3A, $3E, $72, $A7, $DD
    DB      $21, $85, $9C, $CA, $D8, $A0, $DD, $21
    DB      $80, $9C, $C3, $D8, $A0, $00, $20, $27
    DB      $01, $00, $00, $20, $01, $01, $01, $04
    DB      $01, $05, $01, $09, $01, $0A, $01, $0B
    DB      $01, $0F, $02, $10, $01, $11, $01, $12
    DB      $01, $13, $04, $14, $03, $15, $03, $18
    DB      $01, $0C, $01, $0E, $01, $16, $02, $17
    DB      $02, $0D, $02, $17, $04, $0E, $04, $16
    DB      $00, $2A, $3F, $72, $3A, $C4, $72, $CB
    DB      $4F, $20, $0A, $DD, $21, $E5, $9C, $CD
    DB      $D8, $A0, $C3, $D8, $A0, $3A, $62, $70
    DB      $A7, $21, $B8, $A0, $28, $03, $21, $C8
    DB      $A0, $DD, $21, $EF, $9C, $CD, $D8, $A0
    DB      $DD, $21, $F4, $9C, $CD, $D8, $A0, $C3


LOC_A120:
    LD      HL, $A11A                   ; HL -> alternate digit sprite RLE table entry
    JR      LOC_A128                    ; jump to VRAM write

SUB_A125:
    LD      HL, $A11D                   ; HL -> standard digit sprite RLE table entry

LOC_A128:
    LD      DE, $3010                   ; DE = $3010 (VRAM sprite pattern offset)
    JP      SUB_98D4                    ; RLE-decode HL to VRAM at DE and return
    DB      $C8, $FF, $80, $80, $80, $80, $80, $80
    DB      $80, $FF, $00, $00, $00, $78, $CC, $C0
    DB      $C0, $FF, $00, $00, $00, $63, $F3, $F3
    DB      $9B, $FF, $00, $00, $00, $1B, $BB, $FB
    DB      $5B, $FF, $00, $00, $00, $E1, $03, $03
    DB      $03, $FF, $00, $00, $00, $E6, $36, $36
    DB      $36, $FF, $00, $00, $00, $6F, $6C, $6C
    DB      $6C, $FF, $00, $00, $00, $BE, $33, $33
    DB      $33, $FF, $01, $01, $01, $01, $01, $01
    DB      $01, $C8, $80, $80, $80, $80, $80, $80
    DB      $80, $FF, $DD, $CD, $CD, $79, $00, $00
    DB      $00, $FF, $FB, $9B, $9B, $9B, $00, $00
    DB      $00, $FF, $1B, $1B, $1B, $1B, $00, $00
    DB      $00, $FF, $C3, $03, $03, $E1, $00, $00
    DB      $00, $FF, $36, $33, $33, $E1, $00, $00
    DB      $00, $FF, $6F, $CC, $CC, $8F, $00, $00
    DB      $00, $FF, $3E, $33, $33, $33, $00, $00
    DB      $00, $FF, $01, $01, $01, $01, $01, $01
    DB      $01, $FF, $00, $48, $F1, $48, $F1, $00
    DB      $89, $BE, $BF, $C0, $C1, $C2, $C3, $C4
    DB      $C5, $C6, $00, $89, $C7, $C8, $C9, $CA
    DB      $CB, $CC, $CD, $CE, $CF, $00

SUB_A1DC:
    LD      HL, $B2CC                   ; HL -> score digit RLE pattern data
    LD      DE, $1AE0                   ; DE = $1AE0 (VRAM HUD digit pattern offset)
    JP      SUB_98D4                    ; RLE-decode digit patterns to VRAM

SUB_A1E5:
    LD      HL, $A1C6                   ; HL -> HUD pattern RLE block A
    LD      DE, $190C                   ; DE = $190C (VRAM HUD region A)
    CALL    SUB_98D4                    ; decode HUD patterns to VRAM $190C
    LD      HL, $A1D1                   ; HL -> HUD pattern RLE block B
    LD      DE, $192C                   ; DE = $192C (VRAM HUD region B)
    JP      SUB_98D4                    ; decode HUD patterns to VRAM $192C and return
    DB      $3A, $C4, $72, $CB, $3F, $CB, $3F, $FE
    DB      $14, $38, $06, $0E, $D0, $3E, $18, $18
    DB      $04, $0E, $D8, $3E, $06, $21, $20, $19
    DB      $CD, $9D, $86, $3A, $9B, $71, $A7, $28
    DB      $04, $3E, $04, $81, $4F, $EB, $CD, $29
    DB      $A2, $21, $1E, $00, $19, $EB, $CD, $29
    DB      $A2, $C9, $21, $79, $70, $71, $23, $0C
    DB      $0C, $71, $0D, $C5, $0E, $02, $CD, $FA
    DB      $86, $C1, $C9, $03, $00, $85, $0C, $07
    DB      $0F, $07, $07, $88, $03, $01, $0D, $1B
    DB      $3C, $33, $71, $0E, $05, $00, $03, $80
    DB      $88, $80, $40, $60, $60, $60, $E8, $C3
    DB      $3B, $03, $00, $85, $03, $01, $03, $01
    DB      $19, $88, $08, $05, $09, $1D, $3F, $32
    DB      $71, $0E, $04, $00, $84, $C0, $E0, $E0
    DB      $E0, $88, $E0, $A0, $A0, $A0, $20, $E8
    DB      $C3, $3B, $00, $04, $A0, $02, $70, $03
    DB      $A0, $03, $30, $03, $E0, $01, $40, $00
    DB      $3E, $3E, $3E, $3E, $3E, $3E, $3E, $3E
    DB      $3E, $3E, $3E, $3E, $2B, $3F, $28, $3F
    DB      $35, $3F, $32, $3F, $40, $41, $3E, $3E
    DB      $3E, $3E, $3E, $3E, $3E, $3E, $3E, $3E
    DB      $3E, $3E, $3E, $27, $28, $36, $2C, $2A
    DB      $31, $28, $27, $3E, $25, $3C, $3E, $2D
    DB      $32, $2B, $31, $3E, $39, $24, $31, $3E
    DB      $35, $3C, $3D, $2C, $31, $3E, $3E, $3E
    DB      $3E, $3E, $3E, $3E, $24, $27, $24, $33
    DB      $37, $28, $27, $3E, $25, $3C, $3E, $37
    DB      $2B, $28, $3E, $36, $32, $29, $37, $3A
    DB      $32, $35, $2E, $36, $3E, $3E, $3E, $3E
    DB      $3E, $3E, $3E, $3E, $26, $32, $33, $3C
    DB      $35, $2C, $2A, $2B, $37, $3E, $42, $43
    DB      $44, $45, $3E, $1D, $1D, $1D, $1D, $1E
    DB      $1F, $20, $21, $22, $3E, $3E, $3E, $3E
    DB      $20, $3E, $00, $87, $A2, $A7, $A2, $C7
    DB      $A2, $E7, $A2

SOUND_WRITE_A312:
    LD      A, (CONTROLLER_BUFFER)     ; A = controller state
    AND     A                           ; test if in game mode
    RET     Z                           ; return if not in game mode
    LD      A, ($7060)                  ; A = landing delay timer
    AND     A                           ; test if nonzero
    RET     NZ                          ; return if landing timer active
    LD      HL, $7030                   ; HL -> score units counter
    INC     (HL)                        ; increment units counter
    LD      A, (HL)                     ; A = updated units count
    CP      $FF                         ; compare to $FF (overflow check)
    JR      C, LOC_A332                 ; if < $FF, no carry to tens
    LD      (HL), $00                   ; reset units to 0 (carry)
    LD      HL, $702F                   ; HL -> score tens counter
    INC     (HL)                        ; increment tens counter
    LD      A, (HL)                     ; A = updated tens count
    CP      $04                         ; compare to 4 (max 4 tens = 400)
    JR      C, LOC_A332                 ; if < 4, no reset needed
    LD      (HL), $00                   ; reset tens to 0

LOC_A332:
    LD      A, ($7030)                  ; A = score units counter
    CP      $01                         ; compare to 1
    JP      Z, LOC_A367                 ; if exactly 1 (new cycle), redraw score
    SUB     $0A                         ; A -= 10 (skip first 10 ticks)
    RET     C                           ; return if A < 10 (not time to update)
    SRL     A                           ; A >>= 1 (divide by 2)
    RET     C                           ; return if odd (update every 2 ticks)
    CP      $20                         ; compare to 32 (max update range)
    RET     NC                          ; return if out of range
    LD      C, A                        ; C = digit position index
    LD      HL, $A30A                   ; HL -> score display address table
    LD      A, ($702F)                  ; A = score tens counter
    SLA     A                           ; A *= 2 (word offset into address table)
    CALL    SUB_869D                    ; A = address table[tens*2] (low byte)
    LD      E, A                        ; E = VRAM address low
    INC     HL                          ; HL -> high byte
    LD      D, (HL)                     ; D = VRAM address high
    DB      $EB                         ; EX DE,HL (HL = VRAM score address)
    LD      A, C                        ; A = digit position index
    CALL    SUB_869D                    ; A = digit_tile[position] (tile pattern)
    LD      ($7079), A                  ; $7079 = tile index to write
    LD      HL, $1AE0                   ; HL -> VRAM HUD digit position table
    LD      A, C                        ; A = digit position
    CALL    SUB_869D                    ; A = VRAM position offset
    DB      $EB                         ; EX DE,HL (HL = VRAM address, DE = offset)
    LD      C, $01                      ; C = 1 (write 1 tile)
    JP      SOUND_WRITE_86FA            ; flush 1 tile to VRAM and return

LOC_A367:
    LD      HL, $A307                   ; HL -> score RLE data (full score redraw)
    LD      DE, $1AE0                   ; DE = $1AE0 (VRAM HUD digit area)
    CALL    SUB_98D4                    ; RLE-decode full score row to VRAM
    JP      LOC_A120                    ; redraw score sprite patterns and return

SUB_A373:
    LD      A, $D0                      ; A = $D0 (player Y-position reset value)
    LD      ($7280), A                  ; $7280 = $D0 (player Y position)
    LD      HL, $7248                   ; HL -> player sprite data at $7248
    LD      DE, $1C00                   ; DE = $1C00 (VRAM sprite attribute table)
    LD      BC, $0039                   ; BC = 57 bytes (sprite attribute block size)
    JP      WRITE_VRAM                  ; BIOS: write player sprite data to VRAM
    DB      $3A, $B5, $71, $D6, $89, $ED, $44, $FA
    DB      $99, $A3, $FE, $10, $D0, $21, $40, $38
    DB      $CD, $9D, $86, $18, $09, $C6, $10, $F8
    DB      $21, $00, $38, $CD, $9D, $86, $11, $00
    DB      $00, $E5, $CD, $C3, $AA, $E1, $01, $20
    DB      $00, $09, $11, $00, $00, $C3, $C3, $AA

SUB_A3B4:
    LD      A, ($7281)                  ; A = player-on-ground flag
    AND     A                           ; test if on ground
    LD      A, ($7074)                  ; A = motion direction
    RET     Z                           ; return A=direction if on ground
    LD      A, ($71B0)                  ; A = player vertical momentum byte
    AND     A                           ; test sign
    LD      A, $00                      ; A = 0 (upward/neutral)
    RET     P                           ; return 0 if positive (rising)
    LD      A, $07                      ; A = 7 (downward index)
    RET                                 ; return 7 if negative (falling)
    DB      $3A, $BC, $71, $A7, $20, $06, $CD, $B4
    DB      $A3, $32, $74, $70, $AF, $32, $81, $72
    DB      $DD, $E5, $DD, $21, $AF, $71, $CD, $74
    DB      $91, $DD, $E1, $C9

LOC_A3E2:
    LD      A, ($7281)                  ; A = player-on-ground flag
    AND     A                           ; test if on ground
    RET     NZ                          ; return if already on ground
    LD      A, ($71B6)                  ; A = descent speed byte
    AND     A                           ; test sign
    RET     M                           ; return if still descending (negative)
    LD      A, $FF                      ; A = $FF (on-ground marker)
    LD      ($7281), A                  ; $7281 = $FF (player landed on ground)
    LD      A, $76                      ; A = $76 (player ground sprite X position)
    LD      ($71B5), A                  ; $71B5 = $76 (player position X = ground level)
    LD      IX, $71AF                   ; IX -> player-X sprite struct at $71AF
    JP      LOC_9179                    ; enable player-X sprite and return

LOC_A3FD:
    XOR     A                           ; A = 0
    LD      ($7282), A                  ; $7282 = 0 (clear player animation frame counter)
    RET                                 ; return

SUB_A402:
    LD      A, ($719B)                  ; A = player-in-flight flag
    AND     A                           ; test if nonzero (in flight)
    JR      Z, LOC_A416                 ; if not in flight, check mine proximity
    LD      A, ($719C)                  ; A = hero-entry-animation flag
    AND     A                           ; test if nonzero
    JR      NZ, LOC_A41D               ; if entry anim active, skip mine check
    LD      A, ($7193)                  ; A = enemy-visible flag
    AND     A                           ; test if nonzero
    JR      Z, LOC_A3FD                 ; if no enemy visible, clear frame counter
    JR      LOC_A41D                    ; else proceed to animation update

LOC_A416:
    LD      A, ($7294)                  ; A = player ground-proximity flag
    AND     A                           ; test if nonzero
    CALL    NZ, SUB_8997                ; if nonzero, process ground-proximity update

LOC_A41D:
    LD      A, ($7294)                  ; A = ground-proximity flag
    AND     A                           ; test if nonzero
    JR      NZ, LOC_A43F               ; if nonzero, check enemy frame rate
    CALL    SUB_89B7                    ; update player position sprite (X/Y)
    LD      A, ($71BC)                  ; A = player vertical motion state
    AND     A                           ; test if nonzero
    JR      Z, LOC_A44A                 ; if zero, store $7282 as-is
    LD      A, ($7281)                  ; A = player-on-ground flag
    AND     A                           ; test if on ground
    LD      A, $00                      ; A = 0 (pre-clear for NZ branch)
    JR      NZ, LOC_A44A               ; if on ground, store 0
    LD      A, ($7067)                  ; A = frame counter
    AND     $07                         ; keep lower 3 bits (0-7 cycle)
    CP      $01                         ; compare to 1
    JR      NZ, LOC_A44D               ; if not frame 1, skip frame update
    JR      LOC_A446                    ; at frame 1, increment frame counter

LOC_A43F:
    LD      A, ($7067)                  ; A = frame counter
    AND     $01                         ; keep bit 0 (alternate every frame)
    JR      NZ, LOC_A44D               ; if odd frame, skip increment

LOC_A446:
    LD      A, ($7282)                  ; A = player animation frame counter
    INC     A                           ; A++ (advance animation frame)

LOC_A44A:
    LD      ($7282), A                  ; $7282 = updated animation frame counter

LOC_A44D:
    LD      A, ($7286)                  ; A = enemy X position (or visible flag)
    LD      HL, $7193                   ; HL -> enemy-visible flag
    OR      (HL)                        ; A = enemy_X OR visible_flag
    RET     NZ                          ; return if any enemy visible
    CALL    SUB_A469                    ; get player sprite address pair into DE
    LD      HL, $3808                   ; HL = $3808 (VRAM sprite attribute base)
    PUSH    DE                          ; save DE (sprite data source)
    PUSH    HL                          ; save HL (VRAM address)
    CALL    LOC_AAC3                    ; write sprite attributes to VRAM
    POP     HL                          ; restore HL
    POP     DE                          ; restore DE
    LD      BC, $0020                   ; BC = 32 (next sprite row offset)
    ADD     HL, BC                      ; HL = $3828 (second sprite row)
    JP      LOC_AAC3                    ; write second sprite row and return

SUB_A469:
    LD      HL, $B2DF                   ; HL -> player sprite direction table
    CALL    SUB_A3B4                    ; A = direction/velocity index (0 or 7)
    AND     A                           ; test if zero
    JR      Z, LOC_A476                 ; if zero (moving right), use base table
    LD      DE, $0008                   ; DE = 8 (offset for leftward sprites)
    ADD     HL, DE                      ; HL -> leftward sprite table entry

LOC_A476:
    LD      A, ($7282)                  ; A = animation frame counter
    AND     $03                         ; keep bits 1-0 (4-frame cycle)
    SLA     A                           ; A *= 2 (word offset)
    CALL    SUB_869D                    ; E = sprite_table[A] low byte
    LD      E, (HL)                     ; E = sprite address low
    INC     HL                          ; HL -> high byte
    LD      D, (HL)                     ; D = sprite address high
    RET                                 ; return (DE = sprite data address)

SUB_A484:
    LD      HL, $7294                   ; HL -> player ground-proximity state
    LD      C, (HL)                     ; C = old ground-proximity state
    LD      A, ($7284)                  ; A = mine-sensor state (0=active, $FF=inactive)
    LD      (HL), A                     ; $7294 = updated mine-sensor state
    LD      A, ($719B)                  ; A = player-in-flight flag
    AND     A                           ; test if in flight
    JR      NZ, LOC_A4B8               ; if in flight, skip proximity animation
    LD      A, ($7284)                  ; A = new mine-sensor state
    CP      C                           ; compare to previous state
    CALL    NZ, DELAY_LOOP_AA1B         ; if changed, redraw player sprite tiles
    LD      A, ($71BC)                  ; A = player vertical motion state
    AND     A                           ; test if nonzero
    JR      Z, LOC_A4B8                 ; if zero, clear frame counter
    LD      A, ($7281)                  ; A = player-on-ground flag
    LD      HL, $7294                   ; HL -> ground-proximity state
    OR      (HL)                        ; A = on_ground OR proximity_state
    JR      NZ, LOC_A4B8               ; if either set, skip step animation
    LD      A, ($7283)                  ; A = footstep animation counter
    AND     $03                         ; keep bits 1-0 (4-step cycle)
    CALL    Z, DELAY_LOOP_A4BD          ; if at cycle start, draw step tile
    LD      A, ($7283)                  ; A = footstep counter
    INC     A                           ; A++ (advance footstep counter)
    CP      $14                         ; compare to 20 (full step cycle)
    JR      C, LOC_A4B9                 ; if < 20, keep counting

LOC_A4B8:
    XOR     A                           ; A = 0 (reset footstep counter)

LOC_A4B9:
    LD      ($7283), A                  ; $7283 = updated footstep counter
    RET                                 ; return

DELAY_LOOP_A4BD:
    CALL    SUB_A3B4                    ; A = direction index (0=right, 7=down)
    LD      B, A                        ; B = direction index
    LD      A, ($7283)                  ; A = footstep counter
    SRL     A                           ; A >>= 1
    SRL     A                           ; A >>= 1 (A = footstep_counter >> 2)
    LD      HL, $AB5C                   ; HL -> right-direction footstep tile table
    INC     B                           ; B++ (test if was 0 = rightward)
    DJNZ    LOC_A4D1                    ; if B was nonzero (not rightward), keep $AB5C
    LD      HL, $AB51                   ; HL -> leftward footstep tile table

LOC_A4D1:
    JP      SUB_AA9E                    ; draw footstep strip tile at current position

DELAY_LOOP_A4D4:
    PUSH    AF                          ; save AF
    LD      A, B                        ; A = projectile type (B)
    CP      $01                         ; compare to 1 (laser type)
    JR      NZ, LOC_A4E1               ; if not laser, skip difficulty check
    LD      A, ($72AA)                  ; A = difficulty cycle counter
    CP      $0B                         ; compare to 11 (laser difficulty threshold)
    JR      NC, LOC_A4F7               ; if at threshold, skip color update

LOC_A4E1:
    PUSH    BC                          ; save BC
    PUSH    HL                          ; save HL
    LD      A, $20                      ; A = $20 (shift base for B divisions)

LOC_A4E5:
    SRL     A                           ; A >>= 1 (divide by B)
    DJNZ    LOC_A4E5                    ; loop B times (A = $20 >> B)
    LD      C, A                        ; C = color mask
    LD      HL, $72AB                   ; HL -> projectile color table
    LD      A, ($72AA)                  ; A = difficulty cycle counter
    CALL    SUB_869D                    ; A = color_table[difficulty]
    OR      C                           ; A = color | mask
    LD      (HL), A                     ; $72AB = updated color value
    POP     HL                          ; restore HL
    POP     BC                          ; restore BC

LOC_A4F7:
    POP     AF                          ; restore AF
    RET                                 ; return

DELAY_LOOP_A4F9:
    PUSH    BC                          ; save BC
    PUSH    HL                          ; save HL
    LD      HL, $72AB                   ; HL -> projectile color/flags table
    LD      A, ($72AA)                  ; A = difficulty cycle counter
    CALL    SUB_869D                    ; A = color_table[difficulty]

LOC_A504:
    SLA     A                           ; A <<= 1 (shift left B times)
    DJNZ    LOC_A504                    ; loop B times
    BIT     5, A                        ; test bit 5 (projectile color/speed flag)
    POP     HL                          ; restore HL
    POP     BC                          ; restore BC
    RET                                 ; return (Z=0 if bit 5 set)

SUB_A50D:
    LD      A, ($719B)                  ; A = player-in-flight flag
    AND     A                           ; test if in flight
    RET     NZ                          ; return if player airborne
    LD      IX, $726C                   ; IX -> player position struct at $726C
    CALL    DELAY_LOOP_A69F             ; check projectile/enemy collision
    RET     NC                          ; return if no collision
    CALL    DELAY_LOOP_A4D4             ; update projectile color for difficulty
    LD      A, $04                      ; A = 4 (collision type = direct hit)
    LD      ($7288), A                  ; $7288 = 4 (set collision-type flag)
    LD      A, B                        ; A = collision type from DELAY_LOOP_A69F
    CP      $01                         ; compare to 1 (laser type)
    JP      NZ, LOC_A55A               ; if not laser, jump to general collision
    LD      A, ($72E7)                  ; A = shield-active flag
    AND     A                           ; test if nonzero
    JP      NZ, LOC_A3E2               ; if shielded, player lands (not die)
    LD      A, ($72E8)                  ; A = dynamite-active flag
    AND     A                           ; test if nonzero
    JR      NZ, LOC_A538               ; if dynamite active, detonate
    JP      LOC_A693                    ; else trigger level-complete

LOC_A538:
    LD      A, $FF                      ; A = $FF
    LD      ($7285), A                  ; $7285 = $FF (enemy visible after detonation)
    LD      A, $02                      ; A = 2 (detonation collision type)
    LD      ($7288), A                  ; $7288 = 2 (collision type = dynamite)
    XOR     A                           ; A = 0 (clear detonation flag)
    JP      LOC_A55A                    ; process collision and return
    DB      $CD, $B7, $89, $CD, $B5, $A5, $D2, $5B
    DB      $81, $3E, $69, $32, $86, $72, $CD, $14
    DB      $AA, $C3, $51, $90

LOC_A55A:
    LD      ($7287), A                  ; $7287 = A (collision direction flag)
    LD      A, $69                      ; A = $69 (enemy X spawn position)
    LD      ($7286), A                  ; $7286 = $69 (enemy X position)
    CALL    SUB_AA14                    ; initialize enemy sprite at ($7286,$7287)
    CALL    SOUND_WRITE_9051            ; update all sprites and enemy visibility
    CALL    SUB_89B7                    ; update player position
    CALL    SUB_8901                    ; handle player-enemy close encounter
    LD      A, ($7285)                  ; A = enemy-visible flag
    AND     A                           ; test if enemy visible
    RET     Z                           ; return if no enemy on screen
    PUSH    IX                          ; save IX
    LD      IX, $71B5                   ; IX -> player-X sprite struct at $71B5
    LD      DE, $00A2                   ; DE = bounds $00/$A2
    CALL    SUB_9160                    ; set player X sprite bounds
    LD      A, $02                      ; A = 2 (leftward velocity)
    LD      (IX+1), A                   ; IX+1 = 2 (set sprite velocity)
    CALL    LOC_9179                    ; enable player X sprite
    POP     IX                          ; restore IX
    RET                                 ; return

DELAY_LOOP_A58A:
    LD      B, $03                      ; B = 3 (3 death animation stages)

LOC_A58C:
    LD      A, B                        ; A = stage index (3, 2, 1)
    LD      ($7287), A                  ; $7287 = stage (death animation stage)
    PUSH    BC                          ; save loop counter
    CALL    SUB_A598                    ; draw death animation stage
    POP     BC                          ; restore counter
    DJNZ    LOC_A58C                    ; loop for all 3 stages
    RET                                 ; return

SUB_A598:
    LD      A, ($7287)                  ; A = death animation stage
    AND     A                           ; test if zero
    RET     Z                           ; return if stage 0 (no animation)
    CP      $04                         ; compare to 4 (post-death marker)
    RET     Z                           ; return if stage 4 (done)
    SUB     $03                         ; A -= 3 (remap stage 3->0, 2->-1, 1->-2)
    NEG                                 ; A = -A (remap to 0, 1, 2)
    SLA     A                           ; A *= 2
    SLA     A                           ; A *= 4 (word-table offset)
    LD      HL, $7295                   ; HL -> enemy sprite data table at $7295
    CALL    SUB_869D                    ; A = sprite_data[stage*4] (sprite Y)
    INC     HL                          ; HL -> next entry
    LD      (HL), $E2                   ; write $E2 (invisible) to sprite X slot
    INC     HL                          ; HL -> color entry
    LD      (HL), $00                   ; write $00 (clear color) to sprite color slot
    RET                                 ; return

SUB_A5B5:
    LD      A, ($705B)                  ; A = enemy-animation-step counter
    AND     A                           ; test if zero
    JP      Z, LOC_A5C5                 ; if zero, set carry (advance to next phase)
    DEC     A                           ; A-- (decrement step counter)
    LD      ($705B), A                  ; $705B = updated step counter
    CALL    SUB_881E                    ; draw current enemy animation frame
    AND     A                           ; clear carry (still animating)
    RET                                 ; return (NC = still animating)

LOC_A5C5:
    SCF                                 ; set carry (animation phase complete)
    RET                                 ; return (C = advance to next phase)

LOC_A5C7:
    CALL    SUB_888F                    ; reset enemy to ground position
    LD      A, $78                      ; A = $78 (landing timer = 120 frames)
    LD      ($7060), A                  ; $7060 = 120 (start landing delay)
    XOR     A                           ; A = 0
    LD      ($702F), A                  ; $702F = 0 (reset score tens counter)
    LD      ($7030), A                  ; $7030 = 0 (reset score units counter)
    CPL                                 ; A = $FF
    LD      (CONTROLLER_BUFFER), A     ; CONTROLLER_BUFFER = $FF (enter game mode)
    LD      ($719B), A                  ; $719B = $FF (player in flight)
    CALL    SUB_A1E5                    ; reload HUD pattern tiles to VRAM
    CALL    SUB_A70E                    ; clear projectile state and reset enemy
    CALL    LOC_A872                    ; clear VRAM sprite buffer (128 bytes to 0)
    CALL    DELAY_LOOP_A58A             ; play death animation (3 stages)
    JP      DELAY_LOOP_9040             ; disable all 9 sprites and return

LOC_A5EC:
    CALL    SUB_891A                    ; process enemy spawn / entry animation
    CALL    SUB_A5B5                    ; advance enemy animation step
    JP      C, LOC_A5C7                 ; if animation complete, do landing
    LD      A, ($7288)                  ; A = collision-type flag
    CP      $04                         ; compare to 4 (direct hit)
    JR      Z, LOC_A615                 ; if direct hit, skip X calculation
    LD      C, A                        ; C = collision type
    SLA     A                           ; A <<= 1
    SLA     A                           ; A <<= 2
    ADD     A, C                        ; A = 5*type (frame index)
    SLA     A                           ; A <<= 1
    SLA     A                           ; A <<= 2
    SLA     A                           ; A <<= 3 (A = 40*type)
    ADD     A, $20                      ; A += 32 (sprite X base offset)
    LD      ($7191), A                  ; $7191 = player X position for animation
    LD      A, $FF                      ; A = $FF
    LD      ($7294), A                  ; $7294 = $FF (set ground-proximity active)
    LD      ($7284), A                  ; $7284 = $FF (set mine-sensor active)

LOC_A615:
    LD      A, ($7294)                  ; A = ground-proximity state
    AND     A                           ; test if nonzero
    JR      NZ, LOC_A62A               ; if nonzero (active), skip toggle
    CPL                                 ; A = $FF (toggle to active)
    LD      ($7294), A                  ; $7294 = $FF (ground proximity active)
    LD      ($7284), A                  ; $7284 = $FF (mine sensor active)
    LD      A, ($7191)                  ; A = player X animation position
    SUB     $08                         ; A -= 8 (shift X left by 8)
    LD      ($7191), A                  ; $7191 = adjusted X position

LOC_A62A:
    LD      A, $01                      ; A = 1 (death stage = stage 1)
    LD      ($7287), A                  ; $7287 = 1 (death animation stage)
    LD      A, ($7285)                  ; A = enemy-visible flag
    LD      C, A                        ; C = enemy-visible flag
    LD      A, ($72E8)                  ; A = dynamite-active flag
    AND     C                           ; A = dynamite AND enemy (both present)
    CALL    NZ, SUB_A598                ; if both present, draw detonation frame
    XOR     A                           ; A = 0
    LD      ($7281), A                  ; $7281 = 0 (clear player-on-ground flag)
    LD      ($7285), A                  ; $7285 = 0 (clear enemy-visible flag)
    JP      LOC_8CE4                    ; re-initialize player position and continue

LOC_A644:
    LD      IX, $7260                   ; IX -> left projectile struct at $7260
    JR      LOC_A658                    ; check projectile collision

SUB_A64A:
    LD      A, ($719B)                  ; A = player-in-flight flag
    AND     A                           ; test if in flight
    RET     NZ                          ; return if airborne (no collision check)
    LD      A, ($7289)                  ; A = right-projectile active flag
    AND     A                           ; test if nonzero
    RET     Z                           ; return if no right projectile
    LD      IX, $7278                   ; IX -> right projectile struct at $7278

LOC_A658:
    CALL    DELAY_LOOP_A69F             ; check projectile vs enemy collision
    RET     NC                          ; return if no collision
    CALL    DELAY_LOOP_A4D4             ; update difficulty color for collision
    LD      A, B                        ; A = collision type (from DELAY_LOOP_A69F)
    CP      $01                         ; compare to 1 (direct laser hit)
    JR      Z, LOC_A693                 ; if laser hit, trigger level completion
    LD      A, $03                      ; A = 3
    SUB     B                           ; A = 3 - B (remap type 2->1, 3->0)
    SLA     A                           ; A *= 2
    SLA     A                           ; A *= 4 (word-table stride)
    LD      HL, $7295                   ; HL -> enemy sprite data table
    CALL    SUB_869D                    ; A = sprite data byte at offset
    LD      C, A                        ; C = sprite X/color data
    LD      (HL), $23                   ; write $23 (tile pattern) to first slot
    INC     HL                          ; HL -> next entry
    LD      A, (IY+0)                   ; A = enemy sprite attribute low
    LD      (HL), A                     ; write enemy Y attribute
    INC     HL                          ; HL -> next entry
    LD      A, (IY+1)                   ; A = enemy sprite attribute high
    LD      (HL), A                     ; write enemy X attribute
    INC     HL                          ; HL -> next entry
    LD      (HL), $18                   ; write $18 (explosion tile color)
    LD      A, C                        ; A = sprite data offset
    CP      $15                         ; compare to $15 (right-side threshold)
    JR      NZ, LOC_A68D               ; if not right-side, skip Y adjustment
    LD      A, (IY-3)                   ; A = enemy Y position (3 bytes back)
    ADD     A, $0E                      ; A += 14 (adjust Y for right-side position)
    DEC     HL                          ; HL -> Y attribute slot
    LD      (HL), A                     ; update Y attribute with adjusted value

LOC_A68D:
    LD      DE, $0050                   ; DE = $0050 (explosion timing count)
    JP      LOC_8720                    ; trigger explosion animation and return

LOC_A693:
    LD      A, ($723E)                  ; A = bonus-level flag
    AND     A                           ; test if nonzero
    RET     NZ                          ; return if already in bonus level
    CPL                                 ; A = $FF (set bonus-level marker)
    LD      ($723E), A                  ; $723E = $FF (enter bonus level state)
    JP      LOC_9BF7                    ; run level-init sequence and return

DELAY_LOOP_A69F:
    LD      IY, $724C                   ; IY -> enemy sprite attribute table at $724C
    LD      B, $03                      ; B = 3 (number of enemy sprites to check)

LOC_A6A5:
    CALL    SUB_A6B2                    ; check IX sprite vs IY enemy for collision
    RET     C                           ; return with carry if collision detected
    LD      DE, $0008                   ; DE = 8 (sprite struct stride)
    ADD     IY, DE                      ; IY -> next enemy sprite
    DJNZ    LOC_A6A5                    ; loop for all 3 enemy sprites
    AND     A                           ; clear carry (no collision)
    RET                                 ; return

SUB_A6B2:
    LD      A, ($7248)                  ; A = player sprite Y position
    CP      $D0                         ; compare to $D0 (off-screen marker)
    RET     Z                           ; return if player off screen
    LD      A, (IX+0)                   ; A = projectile Y position
    CP      $D0                         ; compare to off-screen marker
    JR      C, LOC_A6C3                 ; if < $D0, projectile on screen
    CP      $E3                         ; compare to $E3 (off-screen upper bound)
    CCF                                 ; complement carry
    RET     NC                          ; return if projectile off screen

LOC_A6C3:
    LD      A, (IY+0)                   ; A = enemy Y position
    CP      $D0                         ; compare to off-screen marker
    JR      C, LOC_A6CE                 ; if < $D0, enemy on screen
    CP      $E3                         ; compare to $E3 upper bound
    CCF                                 ; complement carry
    RET     NC                          ; return if enemy off screen

LOC_A6CE:
    LD      HL, $AB72                   ; HL -> collision-width table
    LD      A, (IY+2)                   ; A = enemy color/size byte
    CALL    SUB_869D                    ; A = collision_width[enemy_size]
    DB      $EB                         ; EX DE,HL (DE = width from table)
    LD      HL, $AB72                   ; HL -> same collision-width table
    LD      A, (IX+2)                   ; A = projectile color/size byte
    CALL    SUB_869D                    ; A = collision_width[projectile_size]
    CALL    SUB_A6F1                    ; check X overlap (carry if collision)
    RET     NC                          ; return if no X overlap
    INC     IX                          ; IX -> Y position byte
    INC     IY                          ; IY -> enemy Y position byte
    CALL    SUB_A6F1                    ; check Y overlap (carry if collision)
    DEC     IX                          ; restore IX
    DEC     IY                          ; restore IY
    RET                                 ; return (carry if both X and Y overlap)

SUB_A6F1:
    LD      A, (DE)                     ; A = projectile position
    INC     DE                          ; DE -> next byte
    ADD     A, (HL)                     ; A = projectile + collision_half_width
    INC     HL                          ; HL -> next byte
    JP      M, LOC_A70A                 ; if overflow (sign change), skip
    LD      C, A                        ; C = projectile + half_width
    LD      A, (DE)                     ; A = second projectile position byte
    INC     DE                          ; DE -> next
    ADD     A, (IY+0)                   ; A += enemy position
    SUB     (HL)                        ; A -= collision_half_width
    INC     HL                          ; HL -> next
    SUB     (IX+0)                      ; A -= projectile position
    JP      P, LOC_A708                 ; if positive (gap > 0), no collision
    NEG                                 ; A = -A (make positive)

LOC_A708:
    SUB     C                           ; A -= C (overlap amount)
    RET                                 ; return (carry if overlap > 0)

LOC_A70A:
    INC     DE                          ; advance DE past overflow position
    INC     HL                          ; advance HL
    AND     A                           ; clear carry (no collision on overflow)
    RET                                 ; return

SUB_A70E:
    XOR     A                           ; A = 0
    LD      ($7289), A                  ; $7289 = 0 (clear right-projectile flag)
    JP      LOC_8A55                    ; reset enemy state and return

LOC_A715:
    LD      A, $FF                      ; A = $FF
    LD      ($7289), A                  ; $7289 = $FF (set right-projectile active)
    CALL    SUB_8BE6                    ; init hero re-entry sprite at $71C7
    JP      LOC_8A3C                    ; resume enemy spawn sequence

SUB_A720:
    LD      IX, $7268                   ; IX -> enemy launch-point struct at $7268
    LD      A, ($71B5)                  ; A = player X position
    SUB     $18                         ; A -= 24 (player center offset)
    LD      D, A                        ; D = adjusted player X
    LD      A, ($71BB)                  ; A = player horizontal motion byte
    LD      E, A                        ; E = player motion
    LD      C, $02                      ; C = 2 (enemy struct stride count)
    CALL    DELAY_LOOP_AA00             ; initialize two enemy launch structs
    LD      A, $10                      ; A = $10 (offset for second pair)
    ADD     A, D                        ; A = D + $10 (X for second pair)
    LD      D, A                        ; D = second pair X
    CALL    DELAY_LOOP_AA00             ; initialize second enemy launch pair
    LD      IX, $7248                   ; IX -> player sprite data
    LD      IY, $7295                   ; IY -> enemy sprite attribute table
    LD      B, $03                      ; B = 3 (3 enemy sprites)

LOC_A744:
    PUSH    BC                          ; save counter
    LD      A, (IY+0)                   ; A = enemy sprite Y attribute
    INC     IY                          ; IY -> next entry
    LD      HL, $ABD2                   ; HL -> enemy sprite shape table
    CALL    SUB_869D                    ; A = shape_table[Y] (sprite tile)
    CALL    SUB_A945                    ; update enemy sprite at IX from IY shape
    POP     BC                          ; restore counter
    DJNZ    LOC_A744                    ; loop for all 3 sprites
    LD      IX, $7278                   ; IX -> right projectile struct at $7278
    LD      A, ($7289)                  ; A = right-projectile active flag
    AND     A                           ; test if nonzero
    LD      HL, $00E2                   ; HL = $00E2 (default: projectile off-screen)
    JR      Z, LOC_A772                 ; if no right projectile, use default
    LD      ($7268), HL                 ; $7268 = $00E2 (mark right slot off-screen)
    LD      A, ($71B5)                  ; A = player X position
    SUB     $18                         ; A -= 24 (center offset)
    LD      L, A                        ; L = adjusted player X
    LD      A, ($71BB)                  ; A = player horizontal motion
    ADD     A, $02                      ; A += 2 (forward offset)
    LD      H, A                        ; H = forward X with motion

LOC_A772:
    LD      ($72A5), HL                 ; $72A5 = projectile position (HL)
    LD      HL, $AC0A                   ; HL -> hero sprite shape table entry
    LD      IY, $72A5                   ; IY -> projectile position
    CALL    SUB_A3B4                    ; A = direction/velocity index
    CALL    SUB_869D                    ; A = shape_table[direction]
    CALL    SUB_A945                    ; update hero sprite from IY position
    LD      IX, $7260                   ; IX -> left projectile struct at $7260
    LD      HL, $AC1F                   ; HL -> default enemy sprite table entry
    LD      A, ($7063)                  ; A = difficulty/level counter
    AND     A                           ; test if nonzero
    JR      Z, LOC_A79C                 ; if zero (easy), use default
    LD      HL, $AC26                   ; HL -> medium difficulty entry
    CP      $11                         ; compare to 17
    JR      C, LOC_A79C                 ; if < 17, use medium
    LD      HL, $AC18                   ; HL -> hard difficulty entry

LOC_A79C:
    LD      IY, $72A2                   ; IY -> enemy position struct at $72A2
    JP      SUB_A945                    ; update enemy sprite from IY and return

SOUND_WRITE_A7A3:
    LD      A, ($7289)                  ; A = right-projectile active flag
    AND     A                           ; test if nonzero
    RET     Z                           ; return if no active right projectile
    XOR     A                           ; A = 0
    LD      ($728C), A                  ; $728C = 0 (clear shadow mask cache)
    LD      DE, BOOT_UP                 ; DE = $0000 (start shadow mask)
    LD      A, ($7279)                  ; A = projectile Y position
    LD      C, A                        ; C = projectile Y
    LD      A, ($71BB)                  ; A = player horizontal motion byte
    SUB     C                           ; A = player_motion - projectile_Y
    JR      NC, LOC_A7BB               ; if positive, use as-is
    NEG                                 ; A = absolute difference

LOC_A7BB:
    CP      $40                         ; compare to $40 (shadow distance threshold)
    JR      NC, LOC_A7FC               ; if >= $40, skip shadow drawing
    LD      A, ($7278)                  ; A = right projectile X position
    ADD     A, $0C                      ; A += 12 (shadow center offset)
    LD      B, $FF                      ; B = $FF (shadow fill byte)
    CALL    SUB_A8D4                    ; compute shadow bitmask for this position
    LD      A, ($71C7)                  ; A = hero re-entry sprite pattern index
    AND     A                           ; test if nonzero
    JR      NZ, LOC_A7E5               ; if nonzero, check flying mode
    CALL    SUB_A3B4                    ; A = direction index
    AND     A                           ; test if zero (rightward)
    JR      NZ, LOC_A7DD               ; if not rightward, use D mask only
    LD      D, $00                      ; D = 0 (clear upper shadow byte)
    LD      A, E                        ; A = E
    AND     $7C                         ; keep shadow bits 6-2
    LD      E, A                        ; E = masked lower shadow byte
    JR      LOC_A7E5                    ; continue

LOC_A7DD:
    LD      E, $00                      ; E = 0 (clear lower shadow byte)
    LD      A, D                        ; A = D
    AND     $FE                         ; keep all but bit 0
    LD      D, A                        ; D = masked upper shadow byte
    JR      LOC_A7E5                    ; continue

LOC_A7E5:
    LD      A, ($71C7)                  ; A = hero re-entry pattern index
    CP      $06                         ; compare to 6 (full-width pattern)
    JR      NZ, LOC_A7FC               ; if not full-width, skip shadow trim
    CALL    SUB_A3B4                    ; A = direction index
    AND     A                           ; test if rightward
    JR      NZ, LOC_A7F8               ; if not rightward, trim E
    LD      A, D                        ; A = D
    AND     $0F                         ; keep lower nibble
    LD      D, A                        ; D = trimmed upper shadow byte
    JR      LOC_A7FC                    ; continue

LOC_A7F8:
    LD      A, E                        ; A = E
    AND     $F0                         ; keep upper nibble
    LD      E, A                        ; E = trimmed lower shadow byte

LOC_A7FC:
    LD      ($728A), DE                 ; $728A = DE (shadow mask for sprite)
    RET                                 ; return

SUB_A801:
    LD      DE, ($728A)                 ; DE = shadow mask from $728A
    LD      HL, $39AC                   ; HL = $39AC (VRAM sprite shadow region)
    JP      LOC_AAC3                    ; write shadow mask to VRAM and return

SUB_A80B:
    LD      A, ($7193)                  ; A = enemy-visible flag
    AND     A                           ; test if nonzero
    RET     Z                           ; return if no enemy
    LD      A, ($7060)                  ; A = landing delay timer
    AND     A                           ; test if nonzero
    RET     NZ                          ; return if landing timer active
    LD      A, ($7286)                  ; A = enemy X position
    AND     A                           ; test if nonzero
    JR      NZ, LOC_A843               ; if nonzero, use enemy-visible sprite
    CALL    SUB_A3B4                    ; A = direction index (0=right, 7=down)
    AND     A                           ; test if rightward
    JR      NZ, LOC_A832               ; if not rightward, use leftward sprite
    LD      HL, $B37F                   ; HL -> rightward hero sprite RLE data
    CALL    SUB_86C7                    ; RLE-decode to VRAM write buffer
    LD      HL, $B3C5                   ; HL -> rightward HUD data
    LD      DE, $70D9                   ; DE -> RAM HUD buffer at $70D9
    CALL    SUB_86C4                    ; RLE-decode HUD data to $70D9
    JR      LOC_A84B                    ; continue

LOC_A832:
    LD      HL, $B3A2                   ; HL -> leftward hero sprite RLE data
    CALL    SUB_86C7                    ; RLE-decode to VRAM write buffer
    LD      HL, $B3D8                   ; HL -> leftward HUD data
    LD      DE, $70D9                   ; DE -> RAM HUD buffer
    CALL    SUB_86C4                    ; RLE-decode leftward HUD to $70D9
    JR      LOC_A84B                    ; continue

LOC_A843:
    LD      HL, $B4F5                   ; HL -> enemy-encounter hero sprite RLE
    CALL    SUB_86C7                    ; RLE-decode encounter sprite to buffer
    JR      LOC_A856                    ; skip address setup

LOC_A84B:
    CALL    SUB_A469                    ; get sprite data address into DE
    LD      A, D                        ; A = high byte of sprite address
    LD      ($7081), A                  ; $7081 = sprite address high
    LD      A, E                        ; A = low byte of sprite address
    LD      ($7091), A                  ; $7091 = sprite address low

LOC_A856:
    LD      IX, $7079                   ; IX -> VRAM write buffer start
    LD      A, ($726C)                  ; A = player X position
    CALL    SUB_A87D                    ; apply shadow mask to player sprite rows
    LD      IX, $70B9                   ; IX -> second sprite buffer region
    LD      A, ($7274)                  ; A = enemy X position
    CALL    SUB_A87D                    ; apply shadow mask to enemy sprite rows

LOC_A86A:
    LD      DE, $3800                   ; DE = $3800 (VRAM sprite pattern table)
    LD      C, $80                      ; C = $80 (128 bytes = one sprite pattern bank)
    JP      SOUND_WRITE_86FA            ; flush 128 bytes to VRAM sprite table

LOC_A872:
    LD      DE, $7079                   ; DE -> VRAM write buffer at $7079
    LD      C, $80                      ; C = $80 (128 bytes)
    XOR     A                           ; A = 0 (fill with zeroes)
    CALL    DELAY_LOOP_86A4             ; fill 128 bytes of buffer with 0
    JR      LOC_A86A                    ; flush zeroed buffer to VRAM

SUB_A87D:
    LD      C, A                        ; C = X position to test
    LD      B, $10                      ; B = 16 (16 sprite rows to process)

LOC_A880:
    LD      A, C                        ; A = current X position
    CP      $D0                         ; compare to $D0 (right-edge off-screen)
    JR      NC, LOC_A893               ; if >= $D0, use background mask
    CP      $57                         ; compare to $57 (sky/ground boundary)
    JR      NC, LOC_A8B3               ; if in sky zone, no mask (skip)
    CP      $2E                         ; compare to $2E (left mine zone)
    JR      C, LOC_A893                 ; if < $2E, use background mask
    LD      DE, ($728F)                 ; DE = shadow mask for visible zone
    JR      LOC_A897                    ; apply visible-zone mask

LOC_A893:
    LD      DE, ($728D)                 ; DE = shadow mask for background zone

LOC_A897:
    LD      A, (IX+0)                   ; A = sprite row byte 0
    AND     D                           ; apply mask high byte
    LD      (IX+0), A                   ; store masked byte 0
    LD      A, (IX+16)                  ; A = sprite row byte 16
    AND     E                           ; apply mask low byte
    LD      (IX+16), A                  ; store masked byte 16
    LD      A, (IX+32)                  ; A = sprite row byte 32
    AND     D                           ; apply mask high byte
    LD      (IX+32), A                  ; store masked byte 32
    LD      A, (IX+48)                  ; A = sprite row byte 48
    AND     E                           ; apply mask low byte
    LD      (IX+48), A                  ; store masked byte 48

LOC_A8B3:
    INC     IX                          ; IX -> next sprite column byte
    INC     C                           ; C++ (advance X position)
    DJNZ    LOC_A880                    ; loop for all 16 rows
    RET                                 ; return

SUB_A8B9:
    LD      A, ($71BB)                  ; A = player horizontal motion byte
    LD      C, A                        ; C = player motion (shadow center base)
    LD      A, $18                      ; A = $18 (near shadow zone offset)
    LD      B, $00                      ; B = 0 (near zone flag)
    PUSH    BC                          ; save BC (near zone params)
    CALL    SUB_A8D4                    ; compute near shadow bitmask
    LD      ($728D), DE                 ; $728D = near shadow mask (DE)
    POP     BC                          ; restore BC
    LD      A, $40                      ; A = $40 (far shadow zone offset)
    CALL    SUB_A8D4                    ; compute far shadow bitmask
    LD      ($728F), DE                 ; $728F = far shadow mask (DE)
    RET                                 ; return

SUB_A8D4:
    PUSH    AF                          ; save AF (zone offset)
    LD      A, B                        ; A = zone flag
    LD      ($7291), A                  ; $7291 = zone flag (0=near, nonzero=far)
    LD      A, $0F                      ; A = $0F (base shadow width)
    ADD     A, C                        ; A = $0F + player_motion (shadow center)
    LD      C, A                        ; C = shadow center position
    POP     AF                          ; restore AF (zone offset)
    CALL    SUB_8ECE                    ; compute initial bitmask for position A,C
    LD      DE, $8000                   ; DE = $8000 (initial shadow mask: MSB set)
    JR      LOC_A8E9                    ; enter shadow bit-shift loop

LOC_A8E6:
    CALL    SUB_8F7B                    ; advance shadow bit in DE

LOC_A8E9:
    PUSH    AF                          ; save AF
    JR      NC, LOC_A8FA               ; if no carry, shadow bit not at boundary
    LD      A, ($7291)                  ; A = zone flag
    AND     A                           ; test if nonzero (far zone)
    JR      Z, LOC_A8FA                ; if near zone, skip color increment
    LD      A, $FF                      ; A = $FF (shadow color marker)
    LD      ($728C), A                  ; $728C = $FF (shadow color active)
    CALL    SUB_A913                    ; update shadow color counters

LOC_A8FA:
    POP     AF                          ; restore AF
    CCF                                 ; complement carry
    RR      D                           ; shift shadow D right (advance mask)
    RR      E                           ; shift shadow E right
    LD      A, ($719A)                  ; A = shadow width parameter
    INC     A                           ; A++ (width + 1)
    LD      B, A                        ; B = width count

LOC_A907:
    SRA     D                           ; D >>= 1 (extend shadow right)
    RR      E                           ; E >>= 1

LOC_A90B:
    JR      C, LOC_A912                 ; if carry, shadow edge reached
    DEC     C                           ; C-- (advance position counter)
    DJNZ    LOC_A907                    ; loop for width
    JR      LOC_A8E6                    ; continue shifting shadow

LOC_A912:
    RET                                 ; return (DE = shadow bitmask)

SUB_A913:
    PUSH    AF                          ; save AF
    PUSH    BC                          ; save BC
    PUSH    DE                          ; save DE
    PUSH    HL                          ; save HL
    LD      A, ($7194)                  ; A = shadow-color-change enable flag
    AND     A                           ; test if nonzero
    JR      Z, LOC_A940                 ; if zero, skip color counter update
    LD      A, ($72C4)                  ; A = level speed/difficulty byte
    SRL     A                           ; A >>= 1
    SRL     A                           ; A >>= 2 (level speed bits 3-2)
    LD      C, A                        ; C = speed index
    LD      A, ($7198)                  ; A = current shadow color sub-index
    CP      C                           ; compare to speed index
    JR      Z, LOC_A92F                 ; if equal, check exact match
    INC     C                           ; C++ (check adjacent index)
    CP      C                           ; compare
    JR      NZ, LOC_A940               ; if not adjacent, skip

LOC_A92F:
    LD      B, $04                      ; B = 4 (shadow column count)
    CALL    DELAY_LOOP_A4F9             ; check difficulty flag for column
    JR      Z, LOC_A93C                 ; if flag clear, increment far counter
    LD      HL, $7292                   ; HL -> near shadow color counter
    INC     (HL)                        ; increment near shadow counter
    JR      LOC_A940                    ; continue

LOC_A93C:
    LD      HL, $7293                   ; HL -> far shadow color counter
    INC     (HL)                        ; increment far shadow counter

LOC_A940:
    POP     HL                          ; restore HL
    POP     DE                          ; restore DE
    POP     BC                          ; restore BC
    POP     AF                          ; restore AF
    RET                                 ; return

SUB_A945:
    LD      A, (IY+0)                   ; A = enemy Y attribute (or $E2 = inactive)
    CP      $E2                         ; compare to $E2 (off-screen/inactive marker)
    JR      NZ, LOC_A95E               ; if not inactive, update sprite
    LD      (IX+0), $E2                 ; IX+0 = $E2 (hide sprite Y)
    LD      (IX+1), $00                 ; IX+1 = $00 (clear sprite X)
    LD      (IX+4), $E2                 ; IX+4 = $E2 (hide second half Y)
    LD      (IX+5), $00                 ; IX+5 = $00 (clear second half X)
    JR      LOC_A9A5                    ; advance IX/IY and return

LOC_A95E:
    LD      A, (HL)                     ; A = sprite shape table delta Y
    INC     HL                          ; HL -> next shape entry
    AND     A                           ; test if nonzero
    CALL    NZ, SUB_A9F7                ; if nonzero, compute Y adjustment
    SUB     (IY+0)                      ; A = adjustment - enemy Y (negate offset)
    NEG                                 ; A = enemy Y - adjustment
    LD      (IX+0), A                   ; IX+0 = sprite Y position
    LD      (IX+4), A                   ; IX+4 = second-half sprite Y
    LD      A, (HL)                     ; A = shape delta X (low 7 bits = delta)
    AND     $7F                         ; mask off bit 7 (direction flag)
    AND     A                           ; test if nonzero
    CALL    NZ, SUB_A9F7                ; if nonzero, compute X adjustment
    BIT     7, (HL)                     ; test bit 7 (flip direction flag)
    INC     HL                          ; HL -> next shape entry
    CALL    NZ, SUB_A9BA                ; if bit 7 set, negate offset
    ADD     A, (IY+1)                   ; A = adjustment + enemy X
    LD      (IX+1), A                   ; IX+1 = sprite X position
    LD      (IX+5), A                   ; IX+5 = second-half sprite X
    LD      A, (HL)                     ; A = sprite pattern/color byte
    INC     HL                          ; HL -> next shape entry
    LD      (IX+2), A                   ; IX+2 = sprite pattern index
    ADD     A, $04                      ; A += 4 (second-half pattern offset)
    LD      (IX+6), A                   ; IX+6 = second-half pattern index
    CALL    SUB_A9D8                    ; get color byte, test if zero
    CALL    Z, SUB_A9BF                 ; if zero, compute color from enemy type
    LD      (IX+3), A                   ; IX+3 = sprite color
    CALL    SUB_A9D8                    ; get second color byte
    LD      (IX+7), A                   ; IX+7 = second-half sprite color
    LD      A, (IY+2)                   ; A = enemy lifetime counter
    AND     A                           ; test if nonzero
    CALL    NZ, SUB_A9B0                ; if nonzero, decrement lifetime

LOC_A9A5:
    LD      BC, $0003                   ; BC = 3 (IY struct stride)
    ADD     IY, BC                      ; IY -> next enemy attribute entry
    LD      BC, $0008                   ; BC = 8 (IX sprite struct stride)
    ADD     IX, BC                      ; IX -> next sprite entry
    RET                                 ; return

SUB_A9B0:
    DEC     A                           ; A-- (decrement lifetime)
    LD      (IY+2), A                   ; (IY+2) = updated lifetime counter
    RET     NZ                          ; return if still alive
    LD      (IY+0), $E2                 ; (IY+0) = $E2 (expire: mark off-screen)
    RET                                 ; return

SUB_A9BA:
    NEG                                 ; A = -A (negate X adjustment)
    SUB     $04                         ; A -= 4 (additional leftward offset)
    RET                                 ; return

SUB_A9BF:
    LD      A, (IY+1)                   ; A = enemy X position
    LD      (IX+1), A                   ; IX+1 = sprite X (override)
    PUSH    HL                          ; save HL
    LD      HL, $7243                   ; HL -> enemy-type byte
    LD      A, B                        ; A = sprite row index
    DEC     A                           ; A-- (zero-base row index)
    CALL    SUB_869D                    ; A = enemy_type_table[row]
    SRL     A                           ; A >>= 1
    SRL     A                           ; A >>= 2
    SRL     A                           ; A >>= 3
    SRL     A                           ; A >>= 4 (get color nibble)
    POP     HL                          ; restore HL
    RET                                 ; return (A = color nibble for sprite)


SUB_A9D8:
    PUSH    HL                          ; save HL (current shape table pointer)
    LD      H, (HL)                     ; H = color/flags byte from shape table
    BIT     7, H                        ; test bit 7 (conditional override flag)
    JR      Z, LOC_A9F0                 ; if bit 7 clear, use H as-is
    LD      A, ($723E)                  ; A = bonus-level flag
    AND     A                           ; test if nonzero
    JR      Z, LOC_A9F0                 ; if not in bonus level, use H as-is
    BIT     6, H                        ; test bit 6 (hard-mode color override)
    JR      NZ, LOC_A9EE               ; if bit 6 set, use override color $0E
    LD      A, ($7063)                  ; A = difficulty counter
    AND     A                           ; test if nonzero
    JR      NZ, LOC_A9F0               ; if nonzero difficulty, use H as-is

LOC_A9EE:
    LD      H, $0E                      ; H = $0E (hard-mode color override: yellow)

LOC_A9F0:
    LD      A, H                        ; A = color/flags byte
    AND     $0F                         ; keep lower nibble (color index 0-15)
    POP     HL                          ; restore HL
    INC     HL                          ; HL -> next byte (skip color byte)
    INC     HL                          ; HL -> byte after color (next shape field)
    RET                                 ; return (A = color nibble)

SUB_A9F7:
    PUSH    HL                          ; save HL (current shape pointer)
    LD      HL, $719D                   ; HL -> hero sprite position struct at $719D
    CALL    SUB_869D                    ; A = sprite_table[A] (position lookup)
    POP     HL                          ; restore HL
    RET                                 ; return (A = position from sprite table)

DELAY_LOOP_AA00:
    PUSH    BC                          ; save BC
    LD      B, C                        ; B = count (C = number of entries to init)

LOC_AA02:
    LD      (IX+0), D                   ; IX+0 = D (X position high byte)
    LD      (IX+1), E                   ; IX+1 = E (X position low byte / flags)
    INC     IX                          ; IX++ (advance to next struct byte)
    INC     IX                          ; IX++
    INC     IX                          ; IX++
    INC     IX                          ; IX -> next struct (stride = 4)
    DJNZ    LOC_AA02                    ; loop C times
    POP     BC                          ; restore BC
    RET                                 ; return (C entries initialized with D,E)

SUB_AA14:
    LD      HL, $AB42                   ; HL -> enemy spawn strip table
    XOR     A                           ; A = 0 (strip row index 0)
    JP      SUB_AA9E                    ; draw enemy strip at row 0 and return

DELAY_LOOP_AA1B:
    CALL    SUB_A3B4                    ; A = direction/velocity index (0 or 7)
    LD      B, A                        ; B = direction index
    LD      HL, $AB3F                   ; HL -> rightward player tile strip table
    INC     B                           ; B++ (test if was 0 = rightward)
    DJNZ    LOC_AA28                    ; if B was nonzero (was not 0), keep $AB3F
    LD      HL, $AB3C                   ; HL -> leftward player tile strip table

LOC_AA28:
    XOR     A                           ; A = 0 (row index 0)
    CALL    SUB_AA9E                    ; draw player tile strip at HL, row 0
    LD      HL, $AB48                   ; HL -> upper player strip table (head row)
    INC     B                           ; B++ (direction test again)
    DJNZ    LOC_AA35                    ; if B was nonzero, keep $AB48
    LD      HL, $AB45                   ; HL -> alternate upper strip table

LOC_AA35:
    LD      A, ($7294)                  ; A = ground-proximity state
    AND     A                           ; test if nonzero
    JR      NZ, LOC_AA56               ; if nonzero, skip footstep tile draw
    LD      A, ($7281)                  ; A = player-on-ground flag
    AND     A                           ; test if nonzero
    JR      NZ, LOC_AA4D               ; if on ground, skip flight tile
    LD      A, ($71BC)                  ; A = player vertical motion state
    AND     A                           ; test if nonzero
    JR      Z, LOC_AA4D                 ; if zero, skip motion tile
    CALL    DELAY_LOOP_A4BD             ; draw footstep tile for current frame
    JP      LOC_A44D                    ; update animation frame counter and return

LOC_AA4D:
    LD      HL, $AB4E                   ; HL -> player feet strip table (rightward)
    INC     B                           ; B++ (direction test)
    DJNZ    LOC_AA56                    ; if B was nonzero, keep $AB4E
    LD      HL, $AB4B                   ; HL -> player feet strip (leftward)

LOC_AA56:
    XOR     A                           ; A = 0 (row index 0)
    CALL    SUB_AA9E                    ; draw player feet strip tile
    JP      LOC_A44D                    ; update animation frame counter and return

DELAY_LOOP_AA5D:
    LD      IX, $726A                   ; IX -> enemy launch-pair struct at $726A
    LD      B, $04                      ; B = 4 (4 pairs to initialize)

LOC_AA63:
    LD      D, (HL)                     ; D = X position high byte from table
    INC     HL                          ; HL -> low byte
    LD      E, (HL)                     ; E = X position low byte
    INC     HL                          ; HL -> next entry
    LD      C, $01                      ; C = 1 (1 entry per IX advance)
    CALL    DELAY_LOOP_AA00             ; write D,E to (IX+0),(IX+1) and advance IX
    DJNZ    LOC_AA63                    ; loop for 4 pairs
    RET                                 ; return

SUB_AA6F:
    PUSH    BC                          ; save BC
    PUSH    DE                          ; save DE (destination)
    PUSH    HL                          ; save HL (source)
    LD      B, C                        ; B = C (original C, used as outer count)
    SRL     B                           ; B >>= 1
    SRL     B                           ; B >>= 2
    SRL     B                           ; B >>= 3
    SRL     B                           ; B >>= 4
    SRL     B                           ; B >>= 5 (B = C >> 5 = C / 32)
    LD      HL, $7079                   ; HL -> VRAM write buffer

LOC_AA80:
    PUSH    BC                          ; save outer count
    DB      $EB                         ; EX DE,HL (swap destination/source)
    LD      HL, $0010                   ; HL = $0010 (16 byte offset)
    ADD     HL, DE                      ; HL = DE + 16 (second half of buffer)
    LD      B, $10                      ; B = 16 (16 bytes per row)

LOC_AA88:
    LD      A, (DE)                     ; A = first-half byte
    LD      C, (HL)                     ; C = second-half byte
    CALL    DELAY_LOOP_AE0A             ; interleave bits: merge A and C
    LD      (HL), A                     ; write merged byte to second half
    INC     HL                          ; advance second half pointer
    LD      A, C                        ; A = second-half byte
    CALL    DELAY_LOOP_AE0A             ; interleave bits: merge A
    LD      (DE), A                     ; write merged byte to first half
    INC     DE                          ; advance first half pointer
    DJNZ    LOC_AA88                    ; loop 16 bytes
    POP     BC                          ; restore outer count
    DJNZ    LOC_AA80                    ; loop B times (C/32 times)
    POP     HL                          ; restore HL
    POP     DE                          ; restore DE
    POP     BC                          ; restore BC
    RET                                 ; return

SUB_AA9E:
    PUSH    AF                          ; save AF (row index A)
    PUSH    BC                          ; save BC
    LD      C, (HL)                     ; C = strip descriptor byte (Y address bits)
    INC     HL                          ; HL -> strip address table
    SLA     A                           ; A *= 2 (word-table index)
    CALL    SUB_869D                    ; A = strip_table[A*2] (VRAM column low)
    LD      E, (HL)                     ; E = column low byte
    INC     HL                          ; HL -> high byte
    LD      D, (HL)                     ; D = column high byte (DE = VRAM address)
    LD      B, $00                      ; B = 0 (high byte of BC)
    SLA     C                           ; C <<= 1 (extract VRAM row bits)
    RL      B                           ; carry into B
    SLA     C                           ; C <<= 1
    RL      B                           ; carry into B
    SLA     C                           ; C <<= 1
    RL      B                           ; B:C = row bits (BC = row * 8 row offset)
    LD      HL, $3800                   ; HL = $3800 (VRAM sprite table base)
    ADD     HL, BC                      ; HL = $3800 + (row << 3) (VRAM row address)
    DB      $EB                         ; EX DE,HL (DE = VRAM row, HL = column address)
    CALL    SUB_98D4                    ; RLE-decode strip tile data to VRAM at DE
    POP     BC                          ; restore BC
    POP     AF                          ; restore AF
    RET                                 ; return

LOC_AAC3:
    DB      $EB                         ; EX DE,HL (DE = VRAM address, HL = data source)
    LD      A, H                        ; A = data source high byte
    LD      ($7079), A                  ; $7079 = high byte (write buffer byte 0)
    LD      C, $01                      ; C = 1 (flush 1 byte)
    CALL    SOUND_WRITE_86FA            ; write high byte to VRAM at DE
    LD      A, L                        ; A = data source low byte
    LD      ($7079), A                  ; $7079 = low byte (write buffer byte 1)
    LD      HL, $000F                   ; HL = $000F (VRAM row stride offset)
    ADD     HL, DE                      ; HL = DE + 15 (next sprite row address)
    DB      $EB                         ; EX DE,HL (DE = next row address)
    LD      C, $01                      ; C = 1 (flush 1 byte)
    JP      SOUND_WRITE_86FA            ; write low byte to next VRAM row and return

DELAY_LOOP_AADB:
    LD      HL, $B2EF                   ; HL -> launch-pair position table
    CALL    DELAY_LOOP_AA5D             ; init 4 enemy launch pair structs from table
    LD      HL, $AAF4                   ; HL -> enemy strip initialization table
    LD      B, $0A                      ; B = 10 (10 strip entries to draw)
    XOR     A                           ; A = 0 (strip row index 0)

LOC_AAE7:
    PUSH    HL                          ; save table pointer
    CALL    SUB_AA9E                    ; draw one enemy strip entry
    POP     HL                          ; restore table pointer
    INC     HL                          ; advance past strip entry byte 1
    INC     HL                          ; advance past byte 2
    INC     HL                          ; advance past byte 3 (3 bytes per entry)
    DJNZ    LOC_AAE7                    ; loop 10 times
    JP      LOC_8C7F                    ; reset cave-entrance animation and return
    DB      $20, $0D, $B6, $24, $1C, $B6, $2C, $52
    DB      $B6, $38, $71, $B6, $3C, $83, $B6, $48
    DB      $96, $B6, $4C, $AA, $B6, $44, $BB, $B6
    DB      $54, $F7, $B2, $58, $02, $B3, $50, $F2
    DB      $B6, $09, $B7, $28, $B7, $09, $B7, $40
    DB      $C6, $B6, $D3, $B6, $E2, $B6, $D3, $B6
    DB      $10, $43, $B5, $59, $B5, $18, $6E, $B5
    DB      $84, $B5, $1C, $9D, $B5, $BF, $B5, $E1
    DB      $B5, $F3, $B5, $28, $2F, $B6, $41, $B6
    DB      $00, $7F, $B3, $00, $A2, $B3, $00, $F5
    DB      $B4, $0C, $C5, $B3, $0C, $D8, $B3, $0C
    DB      $EB, $B3, $0C, $F8, $B3, $0C, $68, $B4
    DB      $07, $B4, $21, $B4, $39, $B4, $53, $B4
    DB      $0C, $DD, $B4, $7F, $B4, $9A, $B4, $B0
    DB      $B4, $C8, $B4, $58, $02, $B3, $13, $B3
    DB      $28, $B3, $41, $B3, $5D, $B3, $0B, $14
    DB      $05, $08, $0B, $14, $05, $08, $0B, $14
    DB      $05, $08, $0B, $14, $05, $08, $00, $00
    DB      $00, $00, $06, $06, $05, $05, $00, $00
    DB      $00, $00, $05, $07, $05, $06, $06, $07
    DB      $05, $06, $00, $00, $00, $00, $04, $04
    DB      $06, $06, $00, $00, $00, $00, $04, $04
    DB      $03, $07, $01, $0C, $08, $08, $00, $00
    DB      $00, $00, $EC, $00, $EC, $00, $EC, $00
    DB      $EC, $00, $14, $F9, $18, $08, $EC, $00
    DB      $EC, $00, $EC, $00, $EC, $00, $14, $F9
    DB      $18, $08, $03, $00, $06, $08, $03, $00
    DB      $06, $08, $06, $0B, $06, $08, $00, $00
    DB      $10, $82, $82, $89, $89, $06, $00, $18
    DB      $89, $89, $00, $00, $06, $0C, $1C, $8F
    DB      $8F, $89, $89, $00, $06, $24, $00, $00
    DB      $82, $82, $00, $00, $2C, $C0, $C0, $CF
    DB      $CF, $00, $00, $38, $0B, $0B, $01, $01
    DB      $00, $12, $54, $0B, $0B, $00, $00, $00
    DB      $30, $58, $07, $07, $00, $00, $00, $2A
    DB      $34, $08, $08, $00, $00, $00, $AA, $34
    DB      $08, $08, $00, $00, $00, $00, $40, $0B
    DB      $0B, $08, $08, $00, $00, $48, $0B, $0B
    DB      $01, $01, $00, $00, $50, $0B, $0B, $00
    DB      $00

LOC_AC2D:
    XOR     A                           ; A = 0
    LD      ($72A8), A                  ; $72A8 = 0 (clear cave-animation flags)
    LD      DE, $72BB                   ; DE -> enemy speed-table at $72BB
    LD      HL, $7295                   ; HL -> enemy sprite attribute table at $7295
    LD      B, $03                      ; B = 3 (3 enemy sprites to initialize)
    LD      C, $63                      ; C = $63 (initial Y position reference)

LOC_AC3B:
    PUSH    BC                          ; save outer loop counter
    LD      A, B                        ; A = sprite index (3, 2, 1)
    CP      $01                         ; compare to 1 (last sprite)
    LD      A, $04                      ; A = 4 (default cave row for last sprite)
    JR      Z, LOC_AC49                 ; if last sprite, use row 4
    LD      A, (DE)                     ; A = speed byte from enemy table
    AND     $03                         ; keep bits 1-0 (cave row 0-3)
    CALL    DELAY_LOOP_AD08             ; set cave-animation bit for this row

LOC_AC49:
    LD      B, A                        ; B = cave row index
    SLA     A                           ; A <<= 1
    SLA     A                           ; A <<= 2
    SLA     A                           ; A <<= 3 (A = row * 8)
    SUB     B                           ; A -= B (A = row*8 - row = row*7)
    LD      (HL), A                     ; (HL) = enemy Y coordinate (row*7)
    LD      A, (DE)                     ; A = speed byte
    SRL     A                           ; A >>= 1
    SRL     A                           ; A >>= 2 (A = bits 3-2 = X position)
    CP      $04                         ; compare to $04 (minimum valid X)
    JR      C, LOC_AC8B                 ; if < 4, enemy is off-screen
    CP      $24                         ; compare to $24 (maximum valid X)
    JR      NC, LOC_AC8B               ; if >= $24, also off-screen
    SLA     A                           ; A <<= 1
    LD      B, A                        ; B = A * 2
    SLA     A                           ; A <<= 1
    ADD     A, B                        ; A = A*4 + A*2 = A*3 (X scaled)
    ADD     A, $08                      ; A += 8 (X base offset)
    BIT     1, B                        ; test bit 1 of B (even/odd X group)
    JR      Z, LOC_AC6D                 ; if even, no X adjustment
    SUB     $02                         ; A -= 2 (odd group X adjustment)

LOC_AC6D:
    LD      B, A                        ; B = enemy X position
    PUSH    BC                          ; save B (X), C (Y reference)
    PUSH    DE                          ; save DE (speed table pointer)
    PUSH    HL                          ; save HL (sprite attribute pointer)
    LD      A, (HL)                     ; A = enemy Y coordinate just stored
    CP      $15                         ; compare to $15 (right-side column threshold)
    JR      NZ, LOC_AC7A               ; if not right-side, no X adjustment
    LD      A, $0C                      ; A = $0C (right-side X offset)
    ADD     A, B                        ; A = X + $0C (adjusted for right column)
    LD      B, A                        ; B = adjusted X

LOC_AC7A:
    LD      A, C                        ; A = Y reference
    LD      C, B                        ; C = X position (swap for SUB_8ECE)
    CALL    SUB_8ECE                    ; check proximity: carry if in range
    POP     HL                          ; restore sprite pointer
    POP     DE                          ; restore speed table
    POP     BC                          ; restore B=X, C=Y reference
    JR      C, LOC_AC8B                 ; if in range (collision), mark off-screen

    INC     HL                          ; HL -> sprite X slot
    LD      (HL), C                     ; (HL) = X position
    INC     HL                          ; HL -> sprite pattern slot
    LD      (HL), B                     ; (HL) = sprite pattern / second byte
    INC     HL                          ; HL -> next entry slot
    JR      LOC_AC92                    ; continue to lifetime init

LOC_AC8B:
    INC     HL                          ; HL -> sprite X slot (skip Y)
    LD      (HL), $E2                   ; (HL) = $E2 (off-screen marker)
    INC     HL                          ; HL -> pattern slot
    LD      (HL), $00                   ; (HL) = $00 (clear pattern)
    INC     HL                          ; HL -> next entry slot

LOC_AC92:
    LD      (HL), $00                   ; (HL) = 0 (clear lifetime counter)
    INC     HL                          ; HL -> next sprite entry
    POP     BC                          ; restore outer loop counter
    LD      A, C                        ; A = Y reference
    SUB     $28                         ; A -= 40 (decrease Y reference for next sprite)
    LD      C, A                        ; C = updated Y reference
    INC     DE                          ; DE -> next speed byte
    DJNZ    LOC_AC3B                    ; loop for 3 sprites
    LD      HL, $00E2                   ; HL = $00E2 (hero position: off-screen Y)
    LD      ($72A2), HL                 ; $72A2 = $00E2 (hero sprite off-screen)
    XOR     A                           ; A = 0
    LD      ($72A4), A                  ; $72A4 = 0 (clear enemy-spawn timer)
    LD      ($723E), A                  ; $723E = 0 (clear bonus-level flag)
    LD      A, ($72E7)                  ; A = shield-active flag
    AND     A                           ; test if nonzero
    JR      Z, LOC_ACBC                 ; if no shield, check dynamite
    LD      HL, $729D                   ; HL -> shield sprite data at $729D
    LD      (HL), $2A                   ; write $2A (shield sprite Y)
    INC     HL                          ; HL -> X slot
    LD      (HL), $7E                   ; write $7E (shield sprite X)
    INC     HL                          ; HL -> pattern slot
    LD      (HL), $00                   ; write $00 (pattern 0)
    RET                                 ; return (shield spawned)

LOC_ACBC:
    LD      A, ($72E8)                  ; A = dynamite-active flag
    AND     A                           ; test if nonzero
    JR      Z, LOC_ACDE                 ; if no dynamite, check standard spawn
    LD      A, ($72A8)                  ; A = cave-animation flags
    SET     4, A                        ; set bit 4 (cave propeller anim enable)
    LD      ($72A8), A                  ; $72A8 = updated cave flags
    LD      HL, $729D                   ; HL -> dynamite sprite data
    LD      (HL), $31                   ; write $31 (dynamite sprite Y)
    INC     HL                          ; HL -> X slot
    LD      (HL), $71                   ; write $71 (dynamite sprite X)
    INC     HL                          ; HL -> pattern slot
    LD      (HL), $00                   ; write $00 (pattern 0)
    LD      HL, $7296                   ; HL -> enemy X position slot at $7296
    LD      A, (HL)                     ; A = current enemy X
    SUB     $02                         ; A -= 2 (shift dynamite left of enemy)
    LD      (HL), A                     ; $7296 = adjusted X position
    JR      LOC_ACEF                    ; continue to color/flag setup

LOC_ACDE:
    LD      HL, $7295                   ; HL -> first enemy sprite Y slot
    LD      A, (HL)                     ; A = enemy sprite Y
    CP      $07                         ; compare to $07 (top-zone threshold)
    JR      Z, LOC_ACEA                 ; if at top zone, adjust X
    CP      $0E                         ; compare to $0E (second zone threshold)
    JR      NZ, LOC_ACEF               ; if not at threshold, skip X adjust

LOC_ACEA:
    INC     HL                          ; HL -> enemy X slot
    LD      A, (HL)                     ; A = current enemy X
    ADD     A, $03                      ; A += 3 (shift X right for zone alignment)
    LD      (HL), A                     ; update enemy X position

LOC_ACEF:
    LD      HL, $729D                   ; HL -> special sprite data at $729D
    LD      A, (HL)                     ; A = special sprite Y
    CP      $1C                         ; compare to $1C (mid-screen threshold)
    JR      NZ, LOC_ACFC               ; if not at threshold, skip X adjust
    INC     HL                          ; HL -> special sprite X slot
    LD      A, (HL)                     ; A = special sprite X
    SUB     $02                         ; A -= 2 (shift left at threshold)
    LD      (HL), A                     ; update special sprite X

LOC_ACFC:
    LD      B, $01                      ; B = 1 (difficulty check level 1)
    CALL    DELAY_LOOP_A4F9             ; check difficulty flag for B=1
    RET     Z                           ; return if difficulty flag not set
    LD      A, $FF                      ; A = $FF
    LD      ($723E), A                  ; $723E = $FF (activate bonus-level mode)
    RET                                 ; return

DELAY_LOOP_AD08:
    PUSH    AF                          ; save AF (cave row index)
    PUSH    BC                          ; save BC
    INC     A                           ; A++ (1-based row index)
    LD      B, A                        ; B = row index (shift count)
    XOR     A                           ; A = 0
    SCF                                 ; set carry (seed bit)

LOC_AD0E:
    RL      A                           ; rotate left: shift carry bit in
    DJNZ    LOC_AD0E                    ; loop B times (create bitmask: 1<<row)
    LD      B, A                        ; B = cave-row bitmask
    LD      A, ($72A8)                  ; A = cave-animation flags
    OR      B                           ; set cave row bit in flags
    LD      ($72A8), A                  ; $72A8 = updated cave flags
    POP     BC                          ; restore BC
    POP     AF                          ; restore AF (cave row index)
    RET                                 ; return

SOUND_WRITE_AD1D:
    LD      IX, $72BB                   ; IX -> enemy speed parameter table at $72BB
    LD      A, ($72AA)                  ; A = difficulty cycle counter
    CP      $0B                         ; compare to 11 (hard difficulty threshold)
    JR      C, LOC_AD32                 ; if < 11, use normal speeds
    LD      (IX+5), $FF                 ; IX+5 = $FF (max speed for hard mode)
    LD      (IX+8), $FF                 ; IX+8 = $FF (max speed for second enemy)
    JR      LOC_AD3A                    ; continue to level config

LOC_AD32:
    LD      (IX+5), $C0                 ; IX+5 = $C0 (normal mode speed)
    LD      (IX+8), $FE                 ; IX+8 = $FE (normal mode second enemy speed)

LOC_AD3A:
    LD      HL, $B75C                   ; HL -> level enemy-spawn threshold table
    LD      A, ($72A9)                  ; A = current level index
    CALL    SUB_869D                    ; A = spawn_threshold[level]
    LD      (IX+10), A                  ; IX+10 = spawn threshold for this level
    LD      HL, $B748                   ; HL -> level enemy-offset table
    LD      A, ($72A9)                  ; A = level index
    CALL    SUB_869D                    ; A = enemy_offset[level] (index into params)
    LD      HL, $B770                   ; HL -> level enemy-params base table
    CALL    SUB_869D                    ; A = params[offset] (first param byte)
    LD      A, ($72AA)                  ; A = difficulty cycle counter
    CALL    SUB_869D                    ; A = params[offset + cycle] (cycle param)
    LD      DE, $0100                   ; DE = $0100 (stride through param table)
    LD      B, $08                      ; B = 8 (8 enemy parameter entries)

LOC_AD60:
    LD      A, (HL)                     ; A = enemy parameter byte
    LD      (IX+0), A                   ; IX+0 = parameter byte (speed/type)
    INC     IX                          ; IX -> next parameter slot
    LD      A, $04                      ; A = 4 (check for entry at slot 4)
    CP      B                           ; compare to B (slot counter)
    CALL    Z, SUB_AD84                 ; if at slot 4, adjust for mid-table
    LD      A, $02                      ; A = 2 (check for entry at slot 2)
    CP      B                           ; compare to B
    CALL    Z, SUB_AD84                 ; if at slot 2, adjust for end-table
    ADD     HL, DE                      ; HL += $0100 (advance to next row)
    DJNZ    LOC_AD60                    ; loop 8 entries
    LD      A, ($72AA)                  ; A = difficulty cycle
    AND     A                           ; test if nonzero
    RET     NZ                          ; return if not cycle 0
    LD      HL, $72C4                   ; HL -> level speed/difficulty flags at $72C4
    LD      A, (HL)                     ; A = current flags
    AND     $03                         ; keep lower 2 bits (rotor state)
    OR      $3C                         ; set bits 5-2 (speed flags for level 0)
    LD      (HL), A                     ; $72C4 = updated speed/difficulty flags
    RET                                 ; return

SUB_AD84:
    LD      A, ($72AA)                  ; A = difficulty cycle
    AND     A                           ; test if zero
    JR      Z, LOC_AD94                 ; if cycle 0, skip interpolation
    CP      $0B                         ; compare to 11
    JR      NC, LOC_AD94               ; if >= 11, use next entry directly
    DEC     HL                          ; HL -> previous entry
    LD      A, (HL)                     ; A = previous parameter byte
    INC     HL                          ; HL -> current entry
    LD      (IX+0), A                   ; IX+0 = previous byte (interpolate)

LOC_AD94:
    INC     IX                          ; IX -> next slot (skip one entry)
    RET                                 ; return
    DB      $0F, $1F, $3F, $7F, $FF, $7F, $3F, $1F

SUB_AD9F:
    LD      A, ($72E5)                  ; A = shield-animation active flag
    AND     A                           ; test if nonzero
    RET     Z                           ; return if shield not animating
    LD      A, ($719B)                  ; A = player-in-flight flag
    AND     A                           ; test if in flight
    LD      A, ($72E4)                  ; A = shield-animation frame counter
    JR      Z, LOC_ADB3                 ; if in flight, continue animation
    AND     A                           ; test frame counter
    JR      NZ, LOC_ADB3               ; if nonzero, continue animation
    LD      ($72E5), A                  ; $72E5 = 0 (clear shield-animation flag)

LOC_ADB3:
    INC     A                           ; A++ (advance shield frame counter)
    AND     $3F                         ; keep bits 5-0 (64-frame cycle)
    LD      ($72E4), A                  ; $72E4 = updated frame counter
    AND     $07                         ; keep bits 2-0 (8-frame sub-cycle)
    RET     NZ                          ; return if not at 8-frame boundary
    LD      A, ($72E4)                  ; A = frame counter
    SRL     A                           ; A >>= 1
    SRL     A                           ; A >>= 2
    SRL     A                           ; A >>= 3 (A = frame >> 3 = phase 0-7)
    AND     $07                         ; keep lower 3 bits
    LD      HL, $AD97                   ; HL -> shield bit-pattern table
    CALL    SUB_869D                    ; A = shield_pattern[phase]
    LD      ($72C1), A                  ; $72C1 = shield pixel pattern byte
    LD      HL, $72BE                   ; HL -> shield color data at $72BE
    LD      DE, $72D0                   ; DE -> shield VRAM buffer at $72D0
    CALL    SUB_ADF3                    ; expand shield color data to VRAM buffer
    CALL    DELAY_LOOP_AE23             ; rotate VRAM buffer bytes for animation
    CALL    SOUND_WRITE_9777            ; trigger secondary animation state
    CALL    SUB_8E57                    ; check proximity for shield effect
    RET     NC                          ; return if not in range
    LD      A, ($72E4)                  ; A = frame counter
    AND     A                           ; test if zero
    RET     Z                           ; return if counter wrapped to zero
    CP      $20                         ; compare to 32
    RET     NC                          ; return if past halfway
    NEG                                 ; A = -A (negate for wrap-around)
    ADD     A, $40                      ; A += 64 (remap to second half of cycle)
    LD      ($72E4), A                  ; $72E4 = remapped frame counter
    RET                                 ; return

SUB_ADF3:
    PUSH    DE                          ; save DE (VRAM buffer destination)
    LD      A, $0F                      ; A = $0F (first color fill byte)
    LD      (DE), A                     ; write $0F to first destination byte
    INC     DE                          ; DE -> next destination byte
    CALL    SUB_AE16                    ; expand nibbles from (HL) to DE
    INC     HL                          ; HL -> next source word (skip 2 bytes)
    INC     HL                          ; HL -> next word
    LD      A, (HL)                     ; A = pattern byte (3rd word)
    CALL    DELAY_LOOP_AE0A             ; interleave bits into A
    LD      HL, $72E6                   ; HL -> shield pattern register at $72E6
    LD      (HL), A                     ; $72E6 = interleaved pattern byte
    CALL    SUB_AE16                    ; expand next nibbles from (HL) to DE
    POP     DE                          ; restore DE
    RET                                 ; return

DELAY_LOOP_AE0A:
    PUSH    BC                          ; save BC
    LD      C, A                        ; C = source byte
    LD      B, $08                      ; B = 8 bits

LOC_AE0E:
    SRL     C                           ; C >>= 1 (extract bit into carry)
    RL      A                           ; rotate carry into A (interleave bits)
    DJNZ    LOC_AE0E                    ; loop 8 times
    POP     BC                          ; restore BC
    RET                                 ; return (A = bit-interleaved result)

SUB_AE16:
    XOR     A                           ; A = 0 (accumulator clear)
    RLD                                 ; rotate left digit: (HL) high nibble -> A low, A low -> (HL) low
    LD      (DE), A                     ; write first nibble-expanded byte to DE
    INC     DE                          ; advance destination
    RLD                                 ; rotate: (HL) low nibble -> A low, A low -> (HL) high
    LD      (DE), A                     ; write second nibble-expanded byte
    INC     DE                          ; advance destination
    RLD                                 ; clear HL slot
    INC     HL                          ; HL -> next source byte
    RET                                 ; return

DELAY_LOOP_AE23:
    PUSH    DE                          ; save DE (VRAM buffer base)
    LD      HL, $0009                   ; HL = 9 (offset to end of 10-byte buffer)
    ADD     HL, DE                      ; HL = DE + 9 (last byte of buffer)
    DB      $EB                         ; EX DE,HL (DE = last byte, HL = base)
    LD      B, $05                      ; B = 5 (5 bytes to process)

LOC_AE2B:
    LD      C, (HL)                     ; C = source byte from base
    INC     HL                          ; HL -> next source byte
    PUSH    BC                          ; save C
    LD      B, $04                      ; B = 4 bits to extract
    XOR     A                           ; A = 0

LOC_AE31:
    SRL     C                           ; C >>= 1 (extract bit)
    RL      A                           ; rotate bit into A
    DJNZ    LOC_AE31                    ; loop 4 bits
    POP     BC                          ; restore C
    LD      (DE), A                     ; write extracted nibble to destination
    DEC     DE                          ; DE-- (fill backwards into buffer)
    DJNZ    LOC_AE2B                    ; loop 5 bytes
    POP     DE                          ; restore DE
    RET                                 ; return

DELAY_LOOP_AE3E:
    PUSH    DE                          ; save DE
    LD      HL, $0009                   ; HL = 9
    ADD     HL, DE                      ; HL = DE + 9 (last byte)
    DB      $EB                         ; EX DE,HL
    LD      B, $05                      ; B = 5 (5 bytes)
    LD      A, $0F                      ; A = $0F (fill value for cleared shield)

LOC_AE48:
    LD      (DE), A                     ; write $0F to buffer byte
    DEC     DE                          ; advance backwards
    DJNZ    LOC_AE48                    ; loop 5 bytes
    POP     DE                          ; restore DE
    RET                                 ; return (shield VRAM buffer cleared to $0F)

DELAY_LOOP_AE4E:
    PUSH    DE                          ; save DE
    LD      HL, $0005                   ; HL = 5 (offset to second half)
    ADD     HL, DE                      ; HL = DE + 5 (second block start)
    DB      $EB                         ; EX DE,HL (DE = second block)
    LD      B, $05                      ; B = 5 (5 bytes to copy)

LOC_AE56:
    LD      A, (HL)                     ; A = byte from second block
    INC     HL                          ; HL -> next source
    LD      (DE), A                     ; write to first block
    INC     DE                          ; advance destination
    DJNZ    LOC_AE56                    ; loop 5 bytes
    POP     DE                          ; restore DE
    RET                                 ; return (second block copied to first)

LOC_AE5E:
    LD      A, $0F                      ; A = $0F (clear-screen value)
    LD      (DE), A                     ; write $0F to first destination byte
    RET                                 ; return

LOC_AE62:
    LD      HL, $0009                   ; HL = 9
    ADD     HL, DE                      ; HL = DE + 9 (last byte)
    LD      (HL), $0F                   ; write $0F to last buffer byte
    RET                                 ; return

SUB_AE69:
    LD      A, ($72AA)                  ; A = difficulty cycle counter
    CP      $0A                         ; compare to 10
    JR      NC, LOC_AE74               ; if >= 10, skip threshold check
    CP      (IX+10)                     ; compare to per-level spawn threshold
    RET     Z                           ; return if at threshold (no update)

LOC_AE74:
    LD      A, (IX+9)                   ; A = enemy X-position parameter
    SRL     A                           ; A >>= 1
    SRL     A                           ; A >>= 2 (strip lower 2 bits)
    RET     Z                           ; return if zero (no valid X)
    CP      $04                         ; compare to $04 (left-side boundary)
    JR      C, LOC_AE83                 ; if < $04, write zero to DE
    CP      $24                         ; compare to $24 (right-side boundary)
    RET     C                           ; return if in valid range (no override)

LOC_AE83:
    XOR     A                           ; A = 0
    LD      (DE), A                     ; write 0 to destination (clear parameter)
    RET                                 ; return

SUB_AE86:
    LD      A, (IX+9)                   ; A = enemy X-position parameter
    SRL     A                           ; A >>= 1
    SRL     A                           ; A >>= 2
    RET     Z                           ; return if zero
    CP      $04                         ; compare to $04 (left boundary)
    JR      C, LOC_AE5E                 ; if < $04, write $0F to DE (clear)
    CP      $24                         ; compare to $24 (right boundary)
    JR      NC, LOC_AE62               ; if >= $24, write $0F to last byte
    RET                                 ; return if in valid range

LOC_AE97:
    LD      DE, $72D0                   ; DE -> shield VRAM buffer at $72D0
    LD      A, ($72C4)                  ; A = level speed/difficulty flags
    SRL     A                           ; A >>= 1
    SRL     A                           ; A >>= 2 (X-position bits)
    CP      $04                         ; compare to $04 (left boundary)
    RET     C                           ; return if < $04 (off left)
    CP      $24                         ; compare to $24 (right boundary)
    RET     NC                          ; return if >= $24 (off right)
    LD      C, A                        ; C = X position
    LD      B, $05                      ; B = 5 (column check)
    CALL    DELAY_LOOP_A4F9             ; check difficulty flag for column 5
    JR      Z, LOC_AEB4                 ; if flag clear, skip inner check
    LD      B, $04                      ; B = 4 (column check)
    CALL    DELAY_LOOP_A4F9             ; check difficulty flag for column 4

LOC_AEB4:
    PUSH    AF                          ; save AF (flag result)
    CALL    DELAY_LOOP_AEC0             ; update column C in shield buffer
    INC     C                           ; C++ (next column)
    POP     AF                          ; restore AF
    CALL    DELAY_LOOP_AEC0             ; update adjacent column in shield buffer
    JP      LOC_9818                    ; redraw rotor tiles and return

DELAY_LOOP_AEC0:
    PUSH    BC                          ; save BC
    PUSH    AF                          ; save AF (NZ = active pixel)
    LD      A, C                        ; A = X column position
    LD      C, $10                      ; C = $10 (16 rows in shield buffer)
    LD      H, D                        ; H = D (copy DE to HL)
    LD      L, E                        ; L = E (HL = DE = buffer base)
    LD      B, A                        ; B = X column
    SRL     A                           ; A >>= 1
    SRL     A                           ; A >>= 2 (byte index)
    CALL    SUB_869D                    ; A = buffer[byte_index] (current byte)
    LD      A, B                        ; A = original X column
    AND     $03                         ; keep bits 1-0 (bit position 0-3)
    LD      B, A                        ; B = bit position
    INC     B                           ; B++ (1-based for shift loop)
    LD      A, C                        ; A = $10 (full-column mask seed)

LOC_AED5:
    RR      A                           ; rotate right: create bit mask for column
    DJNZ    LOC_AED5                    ; loop B times
    LD      B, A                        ; B = column bitmask
    CPL                                 ; A = ~bitmask (inverted)
    AND     (HL)                        ; A = buffer_byte AND ~mask (clear bit)
    LD      C, A                        ; C = byte with bit cleared
    POP     AF                          ; restore AF (NZ = set pixel)
    JR      NZ, LOC_AEE3               ; if NZ (active), skip OR step
    LD      A, C                        ; A = cleared byte
    OR      B                           ; A = cleared | mask (set bit)
    LD      C, A                        ; C = byte with bit set

LOC_AEE3:
    LD      (HL), C                     ; write updated byte to shield buffer
    POP     BC                          ; restore BC
    RET                                 ; return

SUB_AEE6:
    CALL    SOUND_WRITE_AD1D            ; load enemy speed parameters for level
    LD      IX, $72BB                   ; IX -> enemy speed table at $72BB
    XOR     A                           ; A = 0
    LD      ($72E5), A                  ; $72E5 = 0 (clear shield-animation flag)
    LD      ($72E7), A                  ; $72E7 = 0 (clear shield-active flag)
    LD      ($72E8), A                  ; $72E8 = 0 (clear dynamite-active flag)
    LD      ($72E4), A                  ; $72E4 = 0 (clear shield frame counter)
    CPL                                 ; A = $FF
    LD      ($72E9), A                  ; $72E9 = $FF (enable rotor animation)
    LD      A, ($72C5)                  ; A = rotor-disable threshold
    LD      C, A                        ; C = threshold
    LD      A, ($72AA)                  ; A = difficulty cycle counter
    CP      C                           ; compare to threshold
    JR      Z, LOC_AF10                 ; if at threshold, check speed range
    CP      $0A                         ; compare to 10
    JR      NC, LOC_AF10               ; if >= 10, check speed range

    XOR     A                           ; A = 0
    LD      ($72E9), A                  ; $72E9 = 0 (disable rotor animation)

LOC_AF10:
    LD      D, (IX+3)                   ; D = enemy speed parameter 3
    LD      E, (IX+6)                   ; E = enemy speed parameter 6
    LD      HL, $FF7F                   ; HL = $FF7F (shield threshold value)
    AND     A                           ; clear carry
    SBC     HL, DE                      ; HL = $FF7F - DE
    JR      NZ, LOC_AF2E               ; if not equal, skip shield check
    LD      A, (IX+9)                   ; A = enemy type/flag byte
    BIT     1, A                        ; test bit 1 (shield enable flag)
    JR      Z, LOC_AF2E                 ; if bit 1 clear, no shield
    LD      (IX+6), $0F                 ; IX+6 = $0F (set shield visual parameter)
    LD      A, $FF                      ; A = $FF
    LD      ($72E5), A                  ; $72E5 = $FF (enable shield animation)

LOC_AF2E:
    LD      D, (IX+4)                   ; D = dynamite threshold parameter 4
    LD      E, (IX+7)                   ; E = dynamite threshold parameter 7
    LD      HL, $C000                   ; HL = $C000 (dynamite activation threshold)
    AND     A                           ; clear carry
    SBC     HL, DE                      ; HL = $C000 - DE
    JR      NZ, LOC_AF4F               ; if not equal, skip dynamite check
    LD      A, ($72AA)                  ; A = difficulty cycle counter
    CP      $0B                         ; compare to 11
    JR      C, LOC_AF4F                 ; if < 11, not hard enough for dynamite
    LD      A, ($72A9)                  ; A = current level index
    CP      $08                         ; compare to 8 (level threshold)
    JR      C, LOC_AF4F                 ; if < level 8, no dynamite
    LD      A, $FF                      ; A = $FF
    LD      ($72E7), A                  ; $72E7 = $FF (activate shield/dynamite)

LOC_AF4F:
    LD      HL, $E000                   ; HL = $E000 (dynamite bomb threshold)
    AND     A                           ; clear carry
    SBC     HL, DE                      ; HL = $E000 - DE
    JR      NZ, LOC_AF6A               ; if not equal, skip bomb check
    LD      A, ($72AA)                  ; A = difficulty cycle counter
    CP      $0B                         ; compare to 11
    JR      C, LOC_AF6A                 ; if < 11, not hard enough
    LD      A, ($72A9)                  ; A = level index
    CP      $0A                         ; compare to 10 (bomb level threshold)
    JR      C, LOC_AF6A                 ; if < level 10, no bomb
    LD      A, $FF                      ; A = $FF
    LD      ($72E8), A                  ; $72E8 = $FF (activate dynamite bomb)

LOC_AF6A:
    CALL    SUB_B037                    ; mask enemy speed bits for difficulty
    LD      DE, $72C6                   ; DE -> enemy color data buffer at $72C6
    LD      HL, $72C0                   ; HL -> enemy color source at $72C0
    CALL    SUB_ADF3                    ; expand enemy color nibbles to buffer
    LD      A, ($72AA)                  ; A = difficulty cycle counter
    AND     A                           ; test if zero (first cycle)
    JR      NZ, LOC_AF81               ; if nonzero, use rotation
    CALL    DELAY_LOOP_AE3E             ; clear enemy color buffer (first cycle)
    JR      LOC_AF84                    ; continue

LOC_AF81:
    CALL    DELAY_LOOP_AE23             ; rotate enemy color buffer bytes

LOC_AF84:
    LD      DE, $72D0                   ; DE -> shield VRAM buffer at $72D0
    LD      HL, $72BE                   ; HL -> shield color source at $72BE
    CALL    SUB_ADF3                    ; expand shield color nibbles to buffer
    LD      A, ($72AA)                  ; A = difficulty cycle counter
    CP      $0A                         ; compare to 10
    JR      C, LOC_AF96                 ; if < 10, keep buffer
    XOR     A                           ; A = 0
    LD      (DE), A                     ; write 0 to first buffer byte (clear at cycle>=10)

LOC_AF96:
    CALL    SUB_AE69                    ; apply X-boundary check to shield buffer
    LD      A, (IX+9)                   ; A = enemy type parameter 9
    RR      A                           ; rotate right (bit 0 into carry)
    JR      NC, LOC_AFA5               ; if carry clear, use rotation
    CALL    DELAY_LOOP_AE4E             ; copy second half to first half of buffer
    JR      LOC_AFA8                    ; continue

LOC_AFA5:
    CALL    DELAY_LOOP_AE23             ; rotate buffer bytes

LOC_AFA8:
    CALL    SUB_AE86                    ; apply X-boundary clear to buffer
    LD      DE, $72DA                   ; DE -> dynamite color buffer at $72DA
    LD      HL, $72BF                   ; HL -> dynamite color source at $72BF
    CALL    SUB_ADF3                    ; expand dynamite color nibbles to buffer
    CALL    DELAY_LOOP_AE23             ; rotate dynamite color buffer
    JP      LOC_AC2D                    ; reinitialize enemy sprites and return

SUB_AFBA:
    CALL    SUB_B007                    ; check difficulty speed flags (returns NZ if active)
    JR      NZ, LOC_B031               ; if flags active, skip to default timing
    XOR     A                           ; A = 0
    LD      ($72EA), A                  ; $72EA = 0 (clear enemy-hit counter)
    LD      A, ($72C4)                  ; A = level speed/difficulty flags
    SRL     A                           ; A >>= 1
    SRL     A                           ; A >>= 2 (extract X position bits)
    CP      $04                         ; compare to $04 (left boundary)
    JR      C, LOC_B031                 ; if < $04, skip hit check
    CP      $24                         ; compare to $24 (right boundary)
    JR      NC, LOC_B031               ; if >= $24, skip hit check
    SLA     A                           ; A <<= 1
    LD      C, A                        ; C = A * 2
    SLA     A                           ; A <<= 1
    ADD     A, C                        ; A = A*4 + A*2 = A*3 (X scaled)
    ADD     A, $03                      ; A += 3 (center offset)
    LD      C, A                        ; C = left-hit zone X
    CALL    SUB_B011                    ; check if player X in left-hit zone
    LD      A, $06                      ; A = 6 (right-hit zone offset)
    ADD     A, C                        ; A = C + 6 (right-hit zone X)
    LD      C, A                        ; C = right-hit zone X
    CALL    SUB_B011                    ; check if player X in right-hit zone
    LD      A, ($72EA)                  ; A = enemy-hit counter
    AND     A                           ; test if nonzero
    JR      Z, LOC_B031                 ; if zero, no hit detected
    CALL    LOC_AE97                    ; update shield VRAM buffer
    CALL    SOUND_WRITE_8408            ; trigger hit sound effect
    CALL    SUB_B007                    ; re-check speed flags
    JR      Z, LOC_B031                 ; if no flags, skip detonation
    LD      A, ($7286)                  ; A = enemy X position
    AND     A                           ; test if nonzero
    JR      NZ, LOC_B031               ; if enemy visible, skip detonation
    LD      A, $18                      ; A = $18 (detonation spawn timer)
    LD      ($72A4), A                  ; $72A4 = $18 (set detonation timer)
    LD      DE, $0075                   ; DE = $0075 (score points for detonation)
    JP      LOC_8720                    ; trigger score addition and return

SUB_B007:
    LD      B, $05                      ; B = 5 (difficulty column 5)
    CALL    DELAY_LOOP_A4F9             ; check difficulty flag for column 5
    RET     Z                           ; return Z if flag not set
    DEC     B                           ; B = 4 (column 4)
    JP      DELAY_LOOP_A4F9             ; check difficulty flag for column 4 and return

SUB_B011:
    LD      A, ($72A3)                  ; A = player X position
    SUB     C                           ; A = player_X - zone_X
    JP      P, LOC_B01A                 ; if positive, use as-is
    NEG                                 ; A = |player_X - zone_X| (absolute difference)

LOC_B01A:
    CP      $16                         ; compare to 22 (proximity threshold)
    RET     NC                          ; return if too far (no hit)
    LD      HL, $72EA                   ; HL -> enemy-hit counter
    INC     (HL)                        ; increment hit counter
    LD      B, $05                      ; B = 5 (difficulty column 5)
    CALL    DELAY_LOOP_A4F9             ; check difficulty flag
    JP      Z, DELAY_LOOP_A4D4         ; if clear, update projectile color
    DEC     B                           ; B = 4
    CALL    DELAY_LOOP_A4F9             ; check column 4 flag
    JP      Z, DELAY_LOOP_A4D4         ; if clear, update projectile color
    RET                                 ; return

LOC_B031:
    LD      A, $0C                      ; A = $0C (default spawn delay)
    LD      ($72A4), A                  ; $72A4 = $0C (set spawn timer)
    RET                                 ; return

SUB_B037:
    LD      B, $03                      ; B = 3 (difficulty column 3)
    CALL    DELAY_LOOP_A4F9             ; check difficulty flag for column 3
    JR      Z, LOC_B046                 ; if flag clear, mask speed bits
    LD      A, (IX+0)                   ; A = enemy speed parameter 0
    AND     $03                         ; keep lower 2 bits (base speed)
    LD      (IX+0), A                   ; IX+0 = masked speed

LOC_B046:
    DEC     B                           ; B = 2 (column 2)
    CALL    DELAY_LOOP_A4F9             ; check difficulty flag for column 2
    RET     Z                           ; return if flag clear
    LD      A, (IX+1)                   ; A = enemy speed parameter 1
    AND     $03                         ; keep lower 2 bits
    LD      (IX+1), A                   ; IX+1 = masked speed
    RET                                 ; return

; ============================================================
; GAME DATA  ($B054 - $BBFF)
; Animation, sprite, level, and name-table data.
; (Tracer did not reach this area via static flow; kept as DB.)
; ============================================================
GAME_DATA:
    DB      $10, $00, $01, $3C, $06, $66, $01, $3C
    DB      $82, $18, $38, $05, $18, $02, $3C, $BF
    DB      $46, $06, $06, $3C, $60, $60, $7E, $3C
    DB      $46, $06, $0C, $0C, $06, $46, $3C, $0C
    DB      $1C, $2C, $4C, $7E, $0C, $0C, $0C, $7E
    DB      $60, $60, $7C, $06, $06, $46, $7C, $3C
    DB      $62, $60, $7C, $66, $66, $66, $3C, $7E
    DB      $42, $06, $0C, $18, $18, $18, $18, $3C
    DB      $66, $66, $3C, $3C, $66, $66, $3C, $3C
    DB      $66, $66, $66, $3E, $06, $46, $3C, $01
    DB      $FF, $04, $E7, $83, $FF, $E7, $FF, $A0
    DB      $C7, $C7, $C6, $C7, $C7, $C6, $F7, $F7
    DB      $B6, $B6, $36, $36, $36, $1C, $9C, $88
    DB      $F6, $F6, $C6, $E6, $E6, $C6, $F7, $F7
    DB      $30, $30, $30, $00, $00, $30, $B0, $B0
    DB      $85, $EE, $AA, $EA, $8A, $8E, $03, $00
    DB      $85, $85, $A5, $FD, $CD, $85, $03, $00
    DB      $85, $DC, $14, $98, $14, $D4, $03, $00
    DB      $98, $E7, $F7, $D6, $D6, $F7, $E7, $C6
    DB      $C6, $8E, $DB, $DB, $DB, $9B, $9B, $DB
    DB      $CE, $70, $20, $2C, $2C, $28, $34, $14
    DB      $14, $02, $08, $83, $18, $10, $10, $03
    DB      $00, $88, $00, $00, $08, $1C, $0C, $08
    DB      $08, $1C, $05, $1C, $13, $00, $05, $FF
    DB      $03, $00, $00, $07, $FF, $01, $00, $A7
    DB      $FF, $FE, $FC, $F9, $F0, $E7, $CF, $00
    DB      $BF, $84, $B5, $A5, $A5, $A5, $B5, $00
    DB      $C3, $46, $4C, $5A, $72, $62, $42, $00
    DB      $F8, $00, $EB, $8A, $EA, $2A, $EB, $00
    DB      $00, $00, $A4, $B4, $BC, $AC, $A4, $0A
    DB      $00, $E7, $18, $3C, $66, $66, $7E, $66
    DB      $00, $00, $7C, $66, $7C, $66, $66, $7C
    DB      $00, $00, $3C, $66, $60, $60, $66, $3C
    DB      $00, $00, $78, $6C, $66, $66, $6C, $78
    DB      $00, $00, $7E, $60, $7C, $60, $60, $7E
    DB      $00, $00, $7E, $60, $7C, $60, $60, $60
    DB      $00, $00, $3E, $60, $60, $6E, $66, $3E
    DB      $00, $00, $66, $66, $7E, $66, $66, $66
    DB      $00, $00, $7E, $18, $18, $18, $18, $7E
    DB      $00, $00, $06, $06, $06, $06, $66, $3C
    DB      $00, $00, $66, $6C, $78, $78, $6C, $66
    DB      $00, $00, $60, $60, $60, $60, $60, $70
    DB      $00, $00, $63, $77, $7F, $6B, $63, $63
    DB      $00, $00, $E7, $00, $66, $76, $7E, $7E
    DB      $6E, $66, $00, $00, $3C, $66, $66, $66
    DB      $66, $3C, $00, $00, $7C, $66, $66, $7C
    DB      $60, $60, $00, $00, $3C, $66, $66, $66
    DB      $6C, $36, $00, $00, $7C, $66, $66, $7C
    DB      $6C, $66, $00, $00, $3C, $60, $3C, $06
    DB      $06, $3C, $00, $00, $7E, $18, $18, $18
    DB      $18, $18, $00, $00, $66, $66, $66, $66
    DB      $66, $7E, $00, $00, $66, $66, $66, $66
    DB      $3C, $18, $00, $00, $63, $63, $6B, $7F
    DB      $77, $63, $00, $00, $66, $66, $3C, $3C
    DB      $66, $66, $00, $00, $66, $66, $3C, $18
    DB      $18, $18, $00, $00, $7E, $0C, $18, $30
    DB      $60, $7E, $0E, $00, $B2, $18, $18, $00
    DB      $74, $26, $27, $25, $24, $00, $00, $00
    DB      $40, $C0, $C0, $40, $40, $00, $00, $00
    DB      $00, $18, $38, $18, $18, $18, $7E, $00
    DB      $00, $3C, $66, $3E, $06, $0C, $38, $00
    DB      $00, $3C, $66, $3C, $66, $66, $3C, $00
    DB      $00, $0C, $1C, $3C, $6C, $7E, $0C, $05
    DB      $00, $08, $FF, $04, $00, $00, $10, $01
    DB      $78, $F1, $18, $F1, $10, $B1, $02, $A1
    DB      $02, $81, $04, $51, $05, $F1, $03, $01
    DB      $02, $01, $05, $A1, $01, $61, $05, $61
    DB      $03, $01, $05, $A6, $03, $01, $05, $A6
    DB      $03, $01, $05, $A6, $03, $01, $00, $90
    DB      $61, $91, $B1, $31, $21, $21, $41, $11
    DB      $6F, $9F, $BF, $3F, $2F, $2F, $4F, $11
    DB      $20, $F1, $08, $0E, $68, $F1, $00, $68
    DB      $F1, $40, $F1, $10, $E1, $00, $07, $46
    DB      $12, $00, $07, $46, $07, $23, $01, $00
    DB      $83, $11, $12, $13, $0D, $00, $01, $00
    DB      $0E, $23, $12, $00, $0E, $23, $12, $00
    DB      $0E, $23, $01, $00, $84, $0D, $0E, $0F
    DB      $10, $0C, $00, $01, $00, $07, $23, $07
    DB      $47, $12, $00, $07, $47, $20, $00, $00
    DB      $0C, $00, $04, $1D, $85, $1E, $1F, $20
    DB      $21, $22, $0B, $00, $00, $00, $FF, $F0
    DB      $0F, $FF, $FF, $00, $3E, $00, $7F, $00
    DB      $3E, $00, $1C, $7C, $00, $FE, $00, $7C

; -- Cave column strip data A: drawn to VRAM rows 2-3 (VRAM $3A80-$3B3F)
; -- Strips 8-9 of cave layout ($B2F7, $B302), RLE-encoded, SUB_86C7 format
    DB      $00, $38, $00, $00, $0A, $04, $06, $08
    DB      $04, $0C, $0F, $82, $1F, $1F, $0E, $00
    DB      $82, $F8, $F8, $0E, $00, $00, $0B, $00
    DB      $85, $03, $0F, $1C, $1C, $1C, $0B, $00
    DB      $85, $E0, $F8, $1C, $0C, $18, $00, $09
    DB      $00, $87, $03, $07, $0E, $1C, $1C, $1C
    DB      $1E, $09, $00, $87, $E0, $F8, $1C, $0C
    DB      $1C, $18, $70, $00, $06, $00, $87, $01
    DB      $07, $0E, $1C, $1C, $1C, $1E, $03, $0E
    DB      $06, $00, $87, $F0, $F8, $18, $1C, $0C
    DB      $98, $70, $03, $00, $00, $05, $00, $88
    DB      $01, $07, $0E, $1C, $1D, $1D, $1C, $1E
    DB      $03, $0E, $05, $00, $8B, $E0, $B0, $18
    DB      $88, $08, $18, $F0, $00, $00, $00, $70
    DB      $00, $A0, $00, $00, $00, $01, $07, $0E
    DB      $1D, $1D, $1D, $1C, $1E, $0E, $0E, $1E
    DB      $1C, $3D, $00, $00, $00, $E0, $10, $C8
    DB      $28, $08, $18, $E0, $00, $00, $00, $70
    DB      $FC, $FE, $00, $08, $00, $08, $08, $18
    DB      $00, $08, $08, $0B, $00, $85, $78, $C0
    DB      $C0, $F8, $70, $86, $1D, $1B, $1B, $1E
    DB      $06, $07, $0A, $00, $86, $E0, $78, $78
    DB      $F8, $18, $E8, $0A, $00, $00, $18, $00
    DB      $08, $10, $0B, $00, $85, $1E, $03, $03
    DB      $1F, $0E, $08, $00, $08, $10, $86, $07
    DB      $1E, $1E, $1F, $18, $17, $0A, $00, $86
    DB      $B8, $D8, $D8, $78, $60, $E0, $0A, $00
    DB      $00, $06, $00, $01, $01, $04, $00, $05
    DB      $01, $05, $00, $01, $10, $03, $E0, $04
    DB      $C0, $03, $80, $00, $05, $00, $01, $08
    DB      $03, $07, $04, $03, $03, $01, $06, $00
    DB      $01, $80, $04, $00, $05, $80, $00, $06
    DB      $00, $01, $01, $0E, $00, $01, $10, $09
    DB      $E0, $01, $F0, $00, $05, $00, $01, $08
    DB      $09, $07, $01, $0F, $06, $00, $01, $80
    DB      $09, $00, $00, $06, $00, $88, $01, $01
    DB      $01, $00, $00, $03, $03, $02, $07, $00
    DB      $8B, $10, $E0, $C0, $E0, $E0, $F0, $E0
    DB      $C0, $C0, $C0, $E0, $00, $06, $00, $06
    DB      $01, $84, $03, $03, $03, $01, $05, $00
    DB      $8B, $10, $E0, $E0, $F0, $F8, $B8, $18
    DB      $18, $1C, $00, $00, $00, $06, $00, $89
    DB      $01, $01, $01, $03, $07, $0C, $18, $10
    DB      $10, $06, $00, $89, $10, $E0, $E0, $F0
    DB      $B8, $18, $18, $1C, $02, $00, $00, $06
    DB      $00, $86, $01, $01, $09, $1D, $27, $03
    DB      $09, $00, $86, $10, $E0, $F8, $F8, $98
    DB      $9C, $05, $00, $00, $06, $00, $05, $01
    DB      $83, $0F, $0E, $08, $07, $00, $8B, $10
    DB      $E0, $C0, $E0, $E0, $B0, $B0, $30, $1C
    DB      $10, $00, $00, $05, $00, $8B, $08, $07
    DB      $03, $07, $07, $0F, $07, $03, $03, $03
    DB      $07, $06, $00, $03, $80, $87, $00, $00
    DB      $C0, $C0, $40, $00, $00, $00, $05, $00
    DB      $89, $08, $07, $07, $0F, $18, $1D, $18
    DB      $18, $38, $08, $00, $06, $80, $84, $C0
    DB      $C0, $C0, $80, $00, $05, $00, $88, $08
    DB      $07, $07, $0F, $1D, $18, $18, $38, $09
    DB      $00, $03, $80, $87, $C0, $E0, $30, $18
    DB      $08, $08, $00, $00, $05, $00, $86, $08
    DB      $07, $1F, $1F, $19, $39, $0B, $00, $86
    DB      $80, $80, $90, $B8, $E4, $C0, $04, $00
    DB      $00, $05, $00, $8A, $08, $07, $03, $07
    DB      $07, $0D, $0D, $0C, $38, $08, $07, $00
    DB      $05, $80, $85, $F0, $70, $10, $00, $00
    DB      $00, $08, $00, $01, $01, $0F, $00, $84
    DB      $FC, $20, $20, $30, $04, $10, $0B, $00
    DB      $85, $03, $04, $04, $07, $03, $0B, $00
    DB      $85, $80, $40, $40, $C0, $80, $88, $03
    DB      $0F, $1D, $1C, $1D, $17, $10, $10, $08
    DB      $00, $88, $98, $E8, $70, $70, $70, $D0
    DB      $10, $10, $0A, $00, $87, $02, $03, $02
    DB      $00, $07, $06, $16, $06, $06, $01, $0E
    DB      $89, $00, $00, $80, $80, $80, $00, $C0
    DB      $C0, $D0, $06, $C0, $01, $E0, $00, $06
    DB      $04, $20, $00, $86, $6E, $B5, $DF, $CE
    DB      $C0, $40, $0A, $00, $87, $C0, $A0, $60
    DB      $60, $60, $40, $00, $00, $07, $04, $20
    DB      $00, $86, $6E, $B5, $DF, $CE, $C0, $40
    DB      $0A, $00, $86, $C0, $A0, $60, $60, $60
    DB      $40, $00, $89, $00, $00, $4D, $62, $78
    DB      $3D, $3F, $1F, $07, $09, $00, $86, $90
    DB      $30, $F0, $E0, $E0, $C0, $05, $00, $00
    DB      $04, $00, $89, $0D, $02, $07, $0F, $1F
    DB      $3A, $30, $10, $08, $07, $00, $89, $80
    DB      $00, $00, $80, $C0, $E0, $60, $40, $80
    DB      $00, $A0, $00, $00, $80, $E0, $39, $09
    DB      $00, $00, $00, $09, $39, $E0, $80, $00
    DB      $00, $00, $00, $00, $10, $70, $C0, $00
    DB      $00, $00, $00, $00, $C0, $70, $10, $00
    DB      $00, $00, $00, $A0, $00, $40, $30, $19
    DB      $09, $09, $00, $00, $00, $09, $09, $19
    DB      $30, $40, $00, $00, $00, $20, $C0, $80
    DB      $00, $00, $00, $00, $00, $00, $00, $80
    DB      $C0, $20, $00, $00, $00, $8E, $00, $06
    DB      $0F, $0F, $09, $09, $00, $00, $00, $09
    DB      $09, $0F, $0F, $06, $12, $00, $00, $8E
    DB      $00, $10, $10, $19, $09, $09, $00, $00
    DB      $00, $09, $09, $19, $10, $10, $03, $00
; -- Cave column strip data B: drawn to VRAM rows 1-2 (VRAM $3900-$3A7F)
; -- Strips 0-7 of cave layout ($B60D..$B6BB), RLE-encoded, SUB_86C7 format
    DB      $03, $80, $07, $00, $03, $80, $02, $00
    DB      $00, $06, $00, $83, $1F, $3F, $1F, $0D
    DB      $00, $83, $80, $C0, $80, $07, $00, $00
    DB      $87, $03, $7F, $FF, $FF, $FF, $7F, $03
    DB      $09, $00, $87, $E0, $F0, $F0, $E0, $C0
    DB      $C0, $E0, $00, $86, $01, $03, $FF, $FE
    DB      $FF, $01, $0A, $00, $87, $E0, $30, $F0
    DB      $10, $00, $A0, $C0, $00, $85, $01, $03
    DB      $FF, $FF, $FF, $0B, $00, $87, $E0, $30
    DB      $F0, $10, $20, $E0, $00, $00, $86, $01
    DB      $03, $07, $0F, $00, $0F, $0A, $00, $86
    DB      $F0, $80, $C0, $E0, $00, $E0, $0E, $00
    DB      $84, $07, $00, $07, $03, $0C, $00, $84
    DB      $C0, $00, $C0, $80, $00, $04, $00, $86
    DB      $7C, $61, $7D, $0D, $0D, $78, $0A, $00
    DB      $01, $E0, $04, $B0, $01, $E0, $00, $03
    DB      $00, $01, $7F, $06, $FF, $01, $7F, $08
    DB      $00, $01, $F0, $06, $F8, $01, $F0, $05
    DB      $00, $00, $87, $00, $7D, $0D, $19, $30
    DB      $30, $31, $0A, $00, $86, $F0, $00, $E0
    DB      $30, $30, $E0, $03, $00, $00, $01, $7F
    DB      $06, $FF, $01, $7F, $08, $00, $01, $F0
    DB      $06, $F8, $01, $F0, $08, $00, $00, $06
    DB      $00, $07, $03, $09, $00, $07, $E0, $03
    DB      $00, $00, $82, $00, $03, $10, $00, $84
    DB      $60, $E0, $80, $80, $03, $00, $00, $83
    DB      $00, $00, $03, $0E, $00, $85, $80, $80
    DB      $C0, $80, $80, $03, $00, $00, $84, $00
    DB      $00, $03, $03, $0D, $00, $85, $60, $00
    DB      $80, $80, $80, $03, $00, $00, $04, $00
    DB      $87, $01, $03, $03, $01, $03, $03, $01
    DB      $09, $00, $87, $C0, $E0, $E0, $C0, $E0
    DB      $E0, $C0, $05, $00, $00, $8D, $00, $00
    DB      $09, $01, $03, $03, $21, $01, $0F, $07
    DB      $01, $01, $08, $05, $00, $8B, $88, $C0
    DB      $E0, $E0, $F4, $C0, $E0, $F8, $C0, $E0
    DB      $C8, $03, $00, $00, $8D, $00, $00, $31
    DB      $0C, $0F, $07, $01, $37, $07, $0F, $0D
    DB      $30, $06, $04, $00, $8C, $30, $06, $D8
; -- LEVEL_ENEMY_OFFSET_TABLE ($B748, 20 bytes)
; --   Indexed by level (0-19). Each byte is an offset into
; --   LEVEL_ENEMY_PARAMS ($B770) for that level's base entry.
; --   Offsets: 0x00, 0x02, 0x06, 0x0C, 0x14, 0x1C, 0x26, 0x32,
; --            0x40, 0x50, 0x60, 0x70, 0x80, 0x90, 0xA0, 0xB0,
; --            0xC0, 0xD0, 0xE0, 0xF0
; -- Followed immediately by LEVEL_ENEMY_SPAWN_THRESH ($B75C, 20 bytes)
; --   Per-level enemy activation threshold compared against $72AA
; --   (difficulty cycle). Values: 1,3,5,7,7,9,11,13,15...15 (max).
; -- Followed by LEVEL_ENEMY_PARAMS ($B770+)
; --   Enemy Y-position sub-table, double-indexed: B770[B748[level]+cycle].
; --   $93 = inactive/off-screen sentinel.
    DB      $F8, $F0, $F6, $C0, $E0, $F8, $C6, $C0
    DB      $18, $03, $00, $00, $00, $02, $06, $0C
    DB      $14, $1C, $26, $32, $40, $50, $60, $70
    DB      $80, $90, $A0, $B0, $C0, $D0, $E0, $F0
    DB      $01, $03, $05, $07, $07, $09, $0B, $0D
    DB      $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    DB      $0F, $0F, $0F, $0F, $93, $93, $93, $93
    DB      $50, $93, $93, $46, $93, $28, $93, $93
    DB      $93, $93, $4C, $18, $40, $4C, $51, $93
    DB      $93, $93, $5E, $93, $7B, $93, $71, $93
    DB      $93, $1A, $50, $60, $93, $3C, $18, $68
    DB      $93, $93, $93, $44, $93, $93, $13, $72
    DB      $19, $50, $68, $78, $48, $93, $93, $50
    DB      $50, $68, $1B, $93, $93, $93, $63, $93
    DB      $93, $36, $53, $93, $93, $7C, $38, $3D
    DB      $93, $3A, $93, $18, $93, $2A, $4E, $3E
    DB      $53, $52, $93, $93, $93, $19, $93, $1D
    DB      $93, $28, $81, $2E, $2E, $2E, $26, $3E
    DB      $53, $93, $2A, $93, $93, $38, $85, $50
    DB      $14, $15, $36, $41, $4D, $65, $93, $6D
    DB      $3C, $64, $20, $93, $93, $7D, $93, $29
    DB      $43, $28, $5A, $93, $36, $52, $5D, $57
    DB      $93, $64, $3C, $32, $93, $6C, $93, $93
    DB      $93, $88, $93, $51, $6D, $93, $3D, $62
    DB      $4C, $5E, $65, $3E, $93, $93, $43, $93
    DB      $43, $32, $93, $93, $25, $93, $16, $5E
    DB      $44, $53, $42, $5C, $93, $93, $40, $93
    DB      $42, $93, $6B, $93, $93, $93, $2A, $53
    DB      $5B, $3C, $93, $31, $93, $93, $32, $4C
    DB      $7F, $36, $42, $60, $61, $61, $4D, $5C
    DB      $1E, $4C, $54, $93, $93, $81, $21, $52
    DB      $4A, $93, $19, $93, $5E, $40, $13, $2E
    DB      $65, $53, $2C, $70, $93, $19, $6B, $51
    DB      $13, $93, $26, $93, $93, $31, $93, $5E
    DB      $4C, $35, $46, $93, $93, $93, $3E, $76
    DB      $89, $93, $40, $31, $2E, $35, $74, $2E
    DB      $4C, $64, $93, $69, $93, $80, $62, $28
    DB      $3A, $2E, $70, $6A, $62, $70, $4E, $4C
    DB      $70, $66, $6A, $93, $93, $30, $93, $3C
    DB      $39, $6D, $93, $2C, $30, $69, $42, $2A
    DB      $93, $7C, $79, $6B, $42, $6C, $84, $53
    DB      $93, $16, $4C, $4C, $16, $4C, $28, $4E
    DB      $93, $61, $49, $22, $56, $71, $81, $41
    DB      $1E, $34, $93, $34, $59, $2B, $22, $3C
    DB      $80, $17, $68, $4C, $81, $4D, $93, $3C
    DB      $93, $1A, $93, $4C, $70, $5B, $1D, $93
    DB      $4C, $63, $28, $4C, $93, $1D, $93, $93
    DB      $93, $93, $5C, $93, $41, $54, $80, $93
    DB      $70, $70, $84, $4C, $93, $2E, $6A, $2E
    DB      $73, $6F, $42, $18, $93, $59, $11, $2E
    DB      $3D, $93, $2E, $3E, $93, $93, $2A, $16
    DB      $72, $32, $4C, $93, $5C, $93, $3C, $5E
    DB      $7C, $5E, $79, $2E, $93, $24, $4C, $70
    DB      $46, $59, $93, $76, $28, $12, $10, $12
    DB      $53, $22, $2E, $42, $93, $14, $32, $22
    DB      $56, $81, $89, $2A, $38, $12, $62, $3C
    DB      $12, $2E, $42, $3E, $93, $32, $5E, $49
    DB      $6D, $93, $78, $89, $32, $2C, $45, $2E
    DB      $35, $24, $6C, $59, $93, $32, $39, $3A
    DB      $21, $4D, $18, $19, $18, $93, $59, $22
    DB      $33, $6B, $3E, $4C, $93, $89, $26, $54
    DB      $2D, $39, $70, $31, $93, $93, $6E, $20
    DB      $6E, $21, $2E, $38, $93, $2E, $80, $52
    DB      $4A, $4D, $32, $66, $78, $93, $32, $78
    DB      $1E, $39, $18, $2E, $93, $32, $88, $2E
    DB      $2E, $6A, $26, $4D, $93, $72, $56, $24
    DB      $20, $60, $88, $2A, $93, $36, $6E, $21
    DB      $80, $4C, $93, $2E, $43, $58, $3F, $75
    DB      $15, $22, $28, $62, $93, $36, $21, $73
    DB      $3A, $93, $12, $31, $31, $93, $88, $21
    DB      $1E, $25, $2E, $1A, $90, $90, $90, $90
    DB      $90, $90, $90, $50, $90, $68, $90, $90
    DB      $90, $50, $14, $24, $18, $50, $84, $90
    DB      $90, $51, $91, $80, $4C, $80, $50, $90
    DB      $90, $50, $84, $50, $60, $34, $70, $18
    DB      $68, $90, $90, $50, $18, $4C, $64, $80
    DB      $28, $1C, $50, $78, $40, $90, $90, $50
    DB      $68, $50, $68, $78, $50, $18, $68, $30
    DB      $39, $91, $91, $91, $90, $50, $80, $80
    DB      $80, $80, $80, $40, $18, $50, $80, $90
    DB      $90, $90, $90, $90, $90, $50, $80, $4C
    DB      $4C, $1C, $28, $84, $88, $88, $81, $91
    DB      $91, $91, $91, $91, $90, $50, $68, $84
    DB      $50, $2C, $84, $68, $88, $88, $68, $90
    DB      $90, $90, $90, $90, $93, $50, $1C, $90
    DB      $70, $50, $88, $80, $90, $68, $69, $91
    DB      $91, $91, $91, $91, $91, $50, $2C, $18
    DB      $28, $88, $88, $90, $50, $2D, $91, $91
    DB      $91, $91, $91, $91, $90, $51, $91, $50
    DB      $90, $50, $68, $84, $90, $88, $4C, $90
    DB      $90, $90, $90, $90, $90, $50, $68, $60
    DB      $20, $58, $80, $80, $80, $80, $51, $91
    DB      $91, $91, $91, $91, $90, $18, $90, $78
    DB      $68, $14, $64, $88, $88, $88, $78, $90
    DB      $90, $90, $90, $90, $90, $50, $28, $78
    DB      $88, $68, $4C, $81, $91, $80, $65, $91
    DB      $91, $91, $91, $91, $90, $50, $80, $7C
    DB      $50, $80, $90, $3C, $4C, $4C, $4C, $90
    DB      $90, $90, $90, $90, $90, $4C, $70, $5C
    DB      $24, $88, $4C, $68, $6C, $88, $79, $91
    DB      $91, $91, $91, $91, $90, $4C, $80, $88
    DB      $88, $88, $80, $70, $80, $80, $84, $90
    DB      $90, $90, $90, $90, $00, $C0, $00, $00
    DB      $E0, $C0, $00, $00, $00, $00, $00, $C0
    DB      $80, $00, $03, $80, $80, $00, $00, $C0
    DB      $00, $00, $00, $FF, $00, $00, $00, $00
    DB      $00, $00, $00, $C0, $FF, $00, $00, $00
    DB      $C0, $C0, $80, $80, $00, $FF, $F0, $F0
    DB      $FC, $E0, $E0, $C0, $00, $00, $80, $00
    DB      $FF, $00, $F8, $F8, $00, $00, $E0, $F0
    DB      $00, $00, $00, $00, $00, $00, $81, $F1
    DB      $FE, $FF, $FF, $00, $00, $FF, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $FC, $01, $00, $CF, $FF, $FF, $00, $00
    DB      $00, $00, $00, $00, $80, $FF, $00, $00
    DB      $00, $9C, $00, $FF, $FF, $FF, $03, $00
    DB      $00, $00, $00, $00, $E0, $C0, $00, $00
    DB      $00, $FC, $F3, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $9C, $80
    DB      $F0, $C3, $03, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $FF, $00, $00, $00, $FC, $03, $00
    DB      $00, $00, $00, $00, $00, $F8, $FC, $00
    DB      $00, $00, $00, $00, $00, $FF, $00, $00
    DB      $03, $00, $00, $00, $00, $00, $00, $FF
    DB      $00, $00, $FF, $FF, $FF, $FF, $00, $00
    DB      $00, $03, $00, $00, $00, $F0, $C3, $FF
    DB      $FF, $FF, $00, $00, $F0, $FF, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $07, $00
    DB      $00, $00, $00, $FF, $FF, $00, $0E, $00
    DB      $00, $00, $00, $00, $00, $00, $E0, $F0
    DB      $FC, $C0, $FF, $FC, $FF, $FF, $1F, $00
    DB      $00, $00, $00, $00, $00, $00, $F3, $F3
    DB      $FF, $FF, $00, $FF, $00, $FF, $0F, $03
    DB      $00, $00, $00, $00, $FF, $FF, $FF, $FC
    DB      $FF, $FF, $FF, $C0, $FF, $FC, $FF, $FF
    DB      $FF, $9F, $F1, $0F, $FF, $9F, $FF, $FF
    DB      $FF, $FF, $C0, $FF, $CF, $FF, $FC, $FF
    DB      $FF, $80, $FF, $E7, $FF, $FC, $CF, $FF
    DB      $FF, $FF, $FF, $CF, $FF, $FF, $C3, $00
    DB      $07, $FF, $F0, $FF, $F0, $FF, $FF, $FF
    DB      $FF, $FF, $F0, $FF, $CF, $FF, $00, $C0
    DB      $FC, $FE, $F0, $FF, $FF, $C3, $C0, $C0
    DB      $C0, $C0, $FF, $CF, $FF, $C0, $FF, $F0
    DB      $80, $FF, $C0, $FF, $FF, $CF, $FF, $E7
    DB      $E7, $F8, $87, $00, $00, $C0, $F0, $E0
    DB      $C0, $C0, $FC, $FF, $FF, $FF, $9F, $FF
    DB      $9E, $9F, $FF, $00, $00, $FF, $C0, $F0
    DB      $C0, $FF, $C0, $FF, $FF, $E7, $FF, $FC
    DB      $FF, $00, $C0, $FF, $FF, $FF, $C0, $00
    DB      $FF, $00, $C0, $FF, $FF, $9E, $0F, $FC
    DB      $03, $0F, $FF, $FF, $FE, $FF, $FF, $C0
    DB      $C0, $C0, $FF, $FF

; ============================================================
; TILE / SPRITE BITMAPS  ($BC00 - $BF6F)
; TMS9918A pattern table -- 8 bytes per tile (one byte per row).
; 110 tiles total.
; ============================================================
TILE_BITMAPS:
    DB      $FF, $FF, $FF, $FF, $C3, $FF, $81, $FF ; tile 0
    DB      $C0, $FF, $80, $C0, $C0, $C0, $C0, $FF ; tile 1
    DB      $FF, $FF, $FF, $F3, $FF, $CF, $C0, $CF ; tile 2
    DB      $CF, $FF, $FC, $00, $00, $C0, $FF, $FF ; tile 3
    DB      $CF, $FF, $F0, $FF, $9F, $FF, $00, $00 ; tile 4
    DB      $00, $F0, $C0, $C0, $E0, $C0, $F0, $FF ; tile 5
    DB      $FF, $00, $F0, $00, $FF, $FF, $CF, $FF ; tile 6
    DB      $C0, $FF, $C7, $E0, $E0, $E0, $C0, $F8 ; tile 7
    DB      $FF, $CC, $E0, $FF, $CF, $FF, $F0, $FF ; tile 8
    DB      $FF, $9F, $FF, $E0, $C0, $E0, $FF, $FC ; tile 9
    DB      $FF, $FC, $FF, $01, $07, $FF, $FF, $FE ; tile 10
    DB      $00, $F0, $80, $E0, $C0, $F0, $E0, $FF ; tile 11
    DB      $FF, $C0, $00, $00, $00, $C0, $FC, $C0 ; tile 12
    DB      $F0, $80, $80, $C0, $E0, $F0, $E0, $FF ; tile 13
    DB      $00, $00, $00, $00, $F0, $00, $00, $00 ; tile 14
    DB      $00, $00, $00, $00, $00, $00, $FF, $FF ; tile 15
    DB      $00, $00, $00, $C0, $00, $00, $00, $00 ; tile 16
    DB      $00, $00, $00, $00, $00, $00, $00, $00 ; tile 17
    DB      $00, $FE, $00, $00, $00, $00, $00, $00 ; tile 18
    DB      $00, $00, $F0, $00, $FC, $00, $00, $00 ; tile 19
    DB      $00, $00, $00, $00, $1F, $00, $F8, $00 ; tile 20
    DB      $00, $F0, $C0, $FF, $00, $FC, $00, $00 ; tile 21
    DB      $00, $00, $FF, $FF, $FC, $F1, $01, $00 ; tile 22
    DB      $00, $1F, $00, $00, $00, $F0, $FF, $00 ; tile 23
    DB      $00, $00, $00, $00, $FC, $FF, $00, $7F ; tile 24
    DB      $3F, $0F, $FF, $00, $00, $C0, $00, $00 ; tile 25
    DB      $00, $3F, $C0, $00, $1C, $00, $00, $3F ; tile 26
    DB      $C3, $3F, $C3, $00, $C0, $00, $00, $00 ; tile 27
    DB      $00, $00, $00, $00, $00, $00, $FF, $00 ; tile 28
    DB      $F8, $FC, $C0, $00, $C0, $00, $C0, $00 ; tile 29
    DB      $00, $1C, $00, $00, $00, $FF, $FF, $00 ; tile 30
    DB      $00, $00, $00, $00, $E0, $00, $00, $00 ; tile 31
    DB      $00, $00, $00, $00, $00, $7F, $FF, $00 ; tile 32
    DB      $00, $00, $03, $00, $E0, $00, $00, $00 ; tile 33
    DB      $00, $00, $F0, $00, $00, $00, $F0, $00 ; tile 34
    DB      $00, $7F, $FF, $00, $03, $FF, $00, $00 ; tile 35
    DB      $00, $F0, $E0, $03, $C0, $E0, $F3, $7F ; tile 36
    DB      $7C, $7F, $C0, $FF, $00, $FF, $00, $C0 ; tile 37
    DB      $00, $00, $FF, $00, $03, $03, $00, $00 ; tile 38
    DB      $00, $7F, $00, $FF, $00, $00, $FF, $00 ; tile 39
    DB      $00, $00, $FF, $00, $00, $00, $00, $00 ; tile 40
    DB      $7F, $1C, $00, $FF, $FF, $00, $00, $C0 ; tile 41
    DB      $00, $00, $E0, $00, $FC, $00, $7F, $C0 ; tile 42
    DB      $3F, $CF, $1F, $FC, $FF, $00, $C0, $C0 ; tile 43
    DB      $00, $00, $FF, $FF, $03, $7F, $FF, $FC ; tile 44
    DB      $FC, $FC, $FF, $FF, $C0, $F0, $C0, $C0 ; tile 45
    DB      $3F, $FF, $3F, $FF, $03, $FF, $3F, $00 ; tile 46
    DB      $FC, $FF, $3F, $FF, $3F, $FF, $FF, $FF ; tile 47
    DB      $3F, $FF, $07, $FF, $3F, $FF, $00, $7F ; tile 48
    DB      $FF, $3F, $FF, $FF, $3F, $FC, $3F, $F3 ; tile 49
    DB      $F9, $00, $FF, $FC, $3F, $FF, $3F, $FF ; tile 50
    DB      $7F, $F9, $FF, $FF, $FF, $3F, $FF, $CF ; tile 51
    DB      $00, $FF, $3F, $00, $3F, $FC, $FE, $3F ; tile 52
    DB      $FF, $FC, $FC, $F0, $00, $00, $C0, $FF ; tile 53
    DB      $3F, $FF, $00, $00, $00, $00, $C3, $FF ; tile 54
    DB      $3F, $00, $00, $00, $C0, $00, $00, $FF ; tile 55
    DB      $3F, $FF, $7F, $7F, $FF, $FF, $3F, $00 ; tile 56
    DB      $00, $00, $00, $00, $C0, $00, $C0, $FF ; tile 57
    DB      $3F, $00, $FF, $3F, $7E, $FF, $00, $00 ; tile 58
    DB      $00, $00, $E0, $C0, $00, $F0, $FF, $FF ; tile 59
    DB      $3F, $FF, $FF, $FF, $3F, $FF, $00, $FF ; tile 60
    DB      $00, $00, $E0, $E0, $00, $C0, $00, $00 ; tile 61
    DB      $3F, $3E, $FF, $FF, $FF, $FF, $FF, $3F ; tile 62
    DB      $FE, $FF, $FF, $E0, $00, $C0, $F0, $00 ; tile 63
    DB      $3F, $FF, $3F, $FF, $3F, $00, $FF, $FF ; tile 64
    DB      $FE, $7F, $00, $E0, $00, $C0, $0F, $C0 ; tile 65
    DB      $3F, $FC, $03, $FF, $0F, $7F, $FF, $FF ; tile 66
    DB      $7F, $3F, $00, $C0, $F0, $00, $FF, $F8 ; tile 67
    DB      $3F, $FF, $00, $00, $FF, $01, $00, $00 ; tile 68
    DB      $00, $00, $00, $00, $C0, $00, $E0, $00 ; tile 69
    DB      $3F, $FF, $00, $00, $00, $7F, $FF, $FF ; tile 70
    DB      $00, $01, $FF, $00, $C0, $C0, $00, $00 ; tile 71
    DB      $3F, $FF, $FF, $3F, $FF, $FF, $E0, $7F ; tile 72
    DB      $7F, $7C, $FF, $00, $00, $C0, $00, $00 ; tile 73
    DB      $7F, $FF, $07, $FF, $FF, $7F, $00, $00 ; tile 74
    DB      $00, $00, $00, $00, $00, $C0, $00, $00 ; tile 75
    DB      $7F, $FF, $00, $00, $00, $00, $00, $F0 ; tile 76
    DB      $F0, $F0, $00, $00, $00, $00, $00, $00 ; tile 77
    DB      $00, $08, $00, $34, $01, $98, $00, $00 ; tile 78
    DB      $00, $4C, $5C, $08, $00, $00, $00, $00 ; tile 79
    DB      $5C, $2C, $2C, $98, $00, $9A, $08, $02 ; tile 80
    DB      $34, $32, $3A, $98, $02, $3C, $5E, $00 ; tile 81
    DB      $4E, $01, $02, $4C, $3E, $08, $42, $5C ; tile 82
    DB      $3E, $40, $03, $64, $03, $64, $3E, $64 ; tile 83
    DB      $0A, $98, $02, $02, $02, $3E, $02, $3E ; tile 84
    DB      $3E, $76, $02, $02, $9A, $10, $4C, $08 ; tile 85
    DB      $02, $36, $02, $02, $02, $02, $02, $72 ; tile 86
    DB      $2E, $02, $0A, $00, $4C, $00, $00, $98 ; tile 87
    DB      $02, $6E, $3E, $6E, $03, $02, $5E, $02 ; tile 88
    DB      $02, $02, $9A, $00, $4C, $02, $4C, $08 ; tile 89
    DB      $02, $02, $22, $32, $02, $02, $02, $02 ; tile 90
    DB      $02, $02, $08, $4E, $02, $4C, $4C, $98 ; tile 91
    DB      $02, $36, $0A, $9A, $3A, $62, $02, $0A ; tile 92
    DB      $9A, $02, $9A, $4E, $1C, $4E, $02, $0A ; tile 93
    DB      $02, $22, $02, $4E, $4E, $02, $0A, $9A ; tile 94
    DB      $00, $9A, $4E, $4E, $02, $4E, $00, $08 ; tile 95
    DB      $02, $9B, $0A, $0A, $9A, $02, $03, $0A ; tile 96
    DB      $9A, $5A, $08, $4E, $02, $4E, $36, $9A ; tile 97
    DB      $02, $5E, $03, $6E, $32, $2E, $02, $4E ; tile 98
    DB      $66, $02, $11, $4E, $45, $02, $00, $08 ; tile 99
    DB      $02, $0A, $9A, $02, $22, $2A, $02, $02 ; tile 100
    DB      $02, $02, $0A, $02, $4E, $8E, $4E, $9A ; tile 101
    DB      $02, $62, $02, $00, $02, $02, $66, $9A ; tile 102
    DB      $0B, $02, $9A, $10, $4E, $4C, $02, $08 ; tile 103
    DB      $02, $62, $02, $62, $6A, $0A, $9A, $02 ; tile 104
    DB      $02, $02, $0A, $88, $02, $4E, $02, $9A ; tile 105
    DB      $02, $5E, $03, $6A, $03, $5A, $02, $01 ; tile 106
    DB      $02, $02, $98, $10, $02, $4E, $12, $0A ; tile 107
    DB      $02, $5E, $00, $02, $02, $02, $02, $02 ; tile 108
    DB      $02, $02, $08, $8E, $8A, $8A, $02, $9A ; tile 109

; ============================================================
; ZERO PADDING  ($BF70 - $BFFF)
; ============================================================
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
    DB      $00, $00, $00, $00, $00, $00, $00, $00
