; =============================================================================
; ARTILLERY DUEL 1983  --  ColecoVision  (16 KB ROM, loads at $8000)
; Disassembled by z80cv_disasm.py  |  Annotated with Claude Sonnet 4.6
; Exact byte-match verified vs. artillery-duel-1983.rom
; =============================================================================
;
; LEGEND / CROSS-REFERENCE  --  all line numbers refer to THIS file.
; ROM addresses shown as ($XXXX).
;
; --- HARDWARE / BIOS ----------------------------------------------------------
;   BIOS entry points:         lines 152-201  (EQU block)
;   I/O port definitions:      lines 205-211
;   RAM definitions:           lines 215-217
;     WORK_BUFFER   $7000       general RAM workspace
;     CONTROLLER_BUFFER $702B   processed controller state table
;     STACKTOP      $73B9       (top of stack)
;
; --- ROM LAYOUT ($8000-$BFFF, 16 KB) -----------------------------------------
;   $8000  cart magic + header                         line  257
;   $8021  CART_ENTRY: JP NMI                          line  257
;   $8024  NMI: vectored dispatch to [$70AC]           line  263
;   $802A  SOUND_WRITE_802A: full NMI service handler  line  288
;   $8068  START: power-on boot entry point            line  341
;   $B054  GAME_DATA: animation/sprite raw DB data     line 5099
;
; --- NMI VECTORED DISPATCH MECHANISM -----------------------------------------
;   PUSH HL / LD HL,($70AC) / DB $E3 (EX (SP),HL) / RET
;   $70AC = current NMI handler target:
;     SOUND_WRITE_802A ($802A) -- full handler (armed by VDP_REG_8352)
;     $8063                    -- safe idle stub (set by SUB_8369)
;   VDP_REG_8352 ($8352)  line  857  arm:   $70AC = SOUND_WRITE_802A
;   SUB_8369 ($8369)      line  874  disarm: $70AC = safe stub $8063
;
; --- NMI SERVICE HANDLER ($802A, line  288) ---------------
;   Save all: AF/BC/DE/HL/IX/IY + EXX + shadow AF/BC/DE/HL (12 PUSH total)
;   INC ($70BE)              -- increment NMI frame counter
;   CALL SOUND_MAN           -- BIOS sound hardware update
;   CALL PLAY_SONGS          -- BIOS music sequence playback
;   CALL SOUND_WRITE_837D    -- read both controllers -> $70BF-$70C2
;   CALL SUB_B70F            -- update SN76489A channel data in VRAM
;   Restore all, IN A,($BF) acknowledge, XOR A -> $70AE, RETN
;
; --- BOOT / INIT SEQUENCE -----------------------------------------------------
;   START ($8068)           line  341    SP=$70AC, VDP off, zero RAM $7000-$73FF
;                                  LD ($73C8),HL (checksum), $70AF=$02
;   LOC_8085 ($8085)        line  385    frame ctr $0E10->$70B0, disarm NMI
;                                  blank VRAM, VDP_INIT_8278, call SUB_80C0
;   SUB_80C0 ($80C0)        line  413    load terrain tiles -> VRAM $1C60
;                                  $7120 = AI/2P mode, silence, VDP_INIT_99F4, prime sprites
;
; --- VDP HELPER ROUTINES (all disarm NMI, write, arm NMI) --------------------
;   VDP_WRITE_8490 ($8490)  line 1064  LDIR: HL->DE, BC bytes
;   VDP_WRITE_84A7 ($84A7)  line 1082  fill BC VRAM bytes at HL with constant A
;   VDP_WRITE_84C0 ($84C0)  line 1102  bit-reversed LDIR to VRAM
;   VDP_WRITE_84E4 ($84E4)  line 1130  POP HL as inline string ptr, write until $00
;   VDP_INIT_99F4 ($99F4)   line 2746  fill name table ($A0), init sprite attrs
;   SUB_86CC ($86CC)        line 1457  terrain tile loader (5 VDP_WRITE_8490 calls)
;   DELAY_LOOP_832E ($832E) line  825  biased random: scale RAND_GEN output
;   SUB_834C ($834C)        line  851  RAND_GEN wrapper (preserves HL)
;
; --- CONTROLLER INPUT ---------------------------------------------------------
;   SOUND_WRITE_837D ($837D) line  891  read P1 and P2 controllers:
;     OUT $C0 (joy mode), IN $FC -> $70BF, IN $FF -> $70C0
;     OUT $80 (keypad mode), IN $FC -> $70C1, IN $FF -> $70C2
;     CALL SUB_8446 x2: decode keypad bytes to BC bit flags
;     XOR/AND edge-detect: $70B2-$70B4 (P1 state), $70B5-$70B7 (P2 state)
;                          $70B8-$70BA (P1 new presses), $70BB-$70BD (P2)
;   SUB_8446 ($8446)         line 1002  decode keypad byte low nibble -> BC flags
;
; --- GAME-STATE DISPATCHER ---------------------------------------------------
;   SUB_8C67 ($8C67)         line 1690  dispatch table $8C9D indexed by A*2
;                                 skip if $70AF == 0
;   DELAY_LOOP_8C82 ($8C82)  line 1710  scan 5 task slots at $70E1 (stride $0A)
;
; --- MAIN GAME ROUND LOOP (LOC_9554) -----------------------------------------
;   LOC_9554 ($9554)   line 2059  round entry: VDP_REG_964C, hide sprites
;     VDP_INIT_99F4, place cannons (SUB_9675), wind (SUB_96E9/9727)
;     SOUND_WRITE_B6ED, prime sprites (SUB_9706), P1/P2 aim sequences
;   LOC_95B5 ($95B5)   line 2106  per-shot turn loop:
;     VDP_REG_95D6: arm NMI, set VDP reg 7, clear $70E1 timer
;     SUB_A64B ($A64B)  line 3840  per-frame: VSYNC sync, render sprites, check rounds
;     JR C: game over
;     SUB_9838 ($9838)  line 2473  swap active player ($7117, IX<->IY)
;     SUB_987A ($987A)  line 2501  fire: trajectory physics + collision detect
;   LOC_95C5 ($95C5)   line 2114  end-of-game:
;     SUB_98F3 ($98F3)  line 2568  INC winning player score byte (IX+4)
;     SUB_98FB ($98FB)  line 2573  display DAMAGE REPORT + player scores
;     SUB_B589: end-of-game sound sequence, VDP_INIT_95FF: clear VDP
;
; --- CANNON PLACEMENT AND AIM ------------------------------------------------
;   VDP_REG_964C ($964C)  line 2190  per-round init: $7117, clear score/damage vars
;   SUB_9675 ($9675)      line 2209  random X: P1 ($08-$18), P2 ($D8-$E8)
;                              SUB_96B2: scan VRAM column for terrain height Y
;   SUB_9706 ($9706)      line 2307  init IX/IY cannon sprite Y/tile/color attrs
;   SUB_9727 ($9727)      line 2318  wind direction init (reads $73C8 bit 5 for AI)
;   SUB_975F ($975F)      line 2354  render P1 cannon bitmap + place sprite
;   SUB_9794 ($9794)      line 2372  render P2 cannon bitmap + place sprite
;
; --- SOUND SYSTEM (SN76489A) -------------------------------------------------
;   SOUND_WRITE_B6ED ($B6ED) line 5801  silence: copy 16-byte init table to $7350
;   SUB_B70F ($B70F)         line 5812  NMI sound update: timing accum overflow drives
;                                 channel push; $734E = accumulator, $7350 = channel buffer
;   DELAY_LOOP_B79C ($B79C)  line 5924  reset channel flags (AND $80 each entry)
;   DELAY_LOOP_B7C0 ($B7C0)  line 5951  prime channel buffer (OR $0F each entry)
;
; --- KEY RAM VARIABLES --------------------------------------------------------
;   $70AC  NMI dispatch vector (SOUND_WRITE_802A when armed, $8063 stub when disarmed)
;   $70AE  NMI re-entry gate ($FF = NMI in progress)
;   $70AF  game phase (0=blank, 1=active, 2=intro)
;   $70B0  frame countdown (init $0E10 = 3600)
;   $70B2  P1 current controller state (3 bytes: joystick, key1, key2)
;   $70B5  P2 current controller state (3 bytes)
;   $70B8  P1 newly-pressed button events (XOR/AND edge detect)
;   $70BB  P2 newly-pressed button events
;   $70BE  NMI frame counter (INC each VSYNC)
;   $70BF  P1 raw joystick byte (CPL of IN $FC in joystick mode)
;   $70C0  P1 raw keypad byte (CPL of IN $FF in joystick mode)
;   $70C3  P1 cannon Y coordinate
;   $70C4  P1 cannon X coordinate
;   $70C6  wind speed/strength value
;   $70C7  P1 score display accumulator
;   $70CB  P2 score display accumulator
;   $70CD  P2 cannon Y coordinate
;   $70CE  P2 cannon X coordinate
;   $70D1  P1 damage counter (hits received this round)
;   $70D5  P2 damage counter (hits received this round)
;   $70E1  task frame budget slots (5 entries x $0A bytes stride)
;   $7115  digit-walk pointer (score display helper)
;   $7117  active player flag (1=P1, 2=P2)
;   $7118  active player cannon data pointer (IX during shot)
;   $711A  other player cannon data pointer (IY during shot)
;   $711C  wind vector word (applied to projectile each physics step)
;   $7120  AI/2P mode flag ($00=AI active, $FF=two players)
;   $7146  projectile active flag ($FF = shell in flight)
;   $714E  aim indicator sprite Y position buffer
;   $714F  aim indicator sprite X position buffer
;   $7350  SN76489A channel attribute buffer (16 bytes, 4 channels x 4 bytes)
;   $734E  sound timing accumulator word
;   $73C8  RAM checksum seed (from boot zero-fill loop)
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
CONTROLLER_BUFFER:       EQU $702B
STACKTOP:                EQU $73B9
JOYSTICK_BUFFER:         EQU $8008

FNAME "output\ARTILLERY-DUEL-1983-NEW.ROM"
CPU Z80

    ORG     $8000

    DW      $AA55                       ; cart magic
    DB      $02, $80
    DB      $04, $80
    DB      $06, $80
    DW      JOYSTICK_BUFFER             ; BIOS POLLER writes controller state here
    DW      START                       ; start address
    DB      $C3, $15, $83, $C3, $0F, $80, $C3, $12
    DB      $80, $C3, $15, $80, $C3, $18, $80, $C3
    DB      $1B, $80, $C3, $1E, $80

; =============================================================================
; CART_ENTRY ($8021) -- ROM entry / NMI vectored dispatch
; =============================================================================
; ROM header at $8000: magic $AA/$55, three JP-trampoline pairs patched by
; BIOS at startup, JOYSTICK_BUFFER pointer ($8008), START address.
; The header also patches 7 x $C3 JP stubs into BIOS RAM for trampoline use.
;
; CART_ENTRY ($8021): JP NMI  -- redirects /NMI vector to NMI.
;
; NMI ($8024): vectored dispatch mechanism:
;   PUSH HL
;   LD HL,($70AC)   -- load current dispatch target from RAM
;   DB $E3           -- EX (SP),HL  -- swap HL onto stack as return address
;   RET              -- "jump" to whatever address was in $70AC
;
; $70AC holds the current NMI handler pointer:
;   = SOUND_WRITE_802A ($802A)  -- full NMI body (armed by VDP_REG_8352)
;   = $8063                     -- minimal "safe" redirect (set by SUB_8369)
; VDP_REG_8352 ($8352): arms NMI (LD HL,SOUND_WRITE_802A / LD ($70AC),HL)
;   also polls VDP status and calls the handler if VBL missed
; SUB_8369 ($8369): disarms NMI (LD HL,$8063 / LD ($70AC),HL)
; =============================================================================
CART_ENTRY:
    JP      NMI

; =============================================================================
; NMI ($8024) -- see block above for dispatch mechanism
; =============================================================================
NMI:
    PUSH    HL                              ; save HL (NMI vectored dispatch setup)
    LD      HL, ($70AC)                     ; load NMI handler pointer from $70AC
    DB      $E3                             ; EX (SP),HL -- swap HL with stacked return address
    RET                                     ; jump to [$70AC] (SOUND_WRITE_802A when armed, $8063 stub when disarmed)

; =============================================================================
; SOUND_WRITE_802A ($802A) -- full NMI frame handler
; =============================================================================
; Despite the disassembler-assigned name, this is the complete per-frame
; interrupt service routine; it executes when NMI fires and $70AC = $802A.
;   LD A,$FF / LD ($70AE),A    -- set "NMI in progress" flag (re-entry gate)
;   PUSH AF/BC/DE/HL/IX/IY + EXX + PUSH AF/BC/DE/HL  -- save all registers
;   INC ($70BE)                -- increment NMI frame counter
;   CALL SOUND_MAN             -- BIOS: advance sound channel state
;   CALL PLAY_SONGS            -- BIOS: music tick
;   CALL SOUND_WRITE_837D      -- read both controllers into $70BF/$70C0/$70C1
;   CALL SUB_B70F              -- controller decode / input state update
;   POP HL/DE/BC/AF + EXX + POP IY/IX/HL/DE/BC  -- restore registers
;   IN A,($BF)                 -- read VDP status (clears VBL interrupt)
;   XOR A / LD ($70AE),A       -- clear "NMI in progress" flag
;   POP AF / RETN
; $70AE = $FF while handler is executing (prevents re-entrant NMI).
; VDP_REG_8352 checks $70AE before calling handler directly.
; =============================================================================
SOUND_WRITE_802A:
    PUSH    AF                              ; save AF
    LD      A, $FF                          ; NMI active flag = $FF
    LD      ($70AE), A                      ; mark NMI in-progress (prevents re-entry)
    PUSH    BC                              ; save BC
    PUSH    DE                              ; save DE
    PUSH    HL                              ; save HL
    PUSH    IX                              ; save IX
    PUSH    IY                              ; save IY
    EX      AF, AF'                         ; swap to alternate AF register
    EXX                                     ; swap to alternate BC/DE/HL registers
    PUSH    AF                              ; save alternate AF
    PUSH    BC                              ; save alternate BC
    PUSH    DE                              ; save alternate DE
    PUSH    HL                              ; save alternate HL
    LD      HL, $70BE                       ; HL = $70BE (frame counter byte)
    INC     (HL)                            ; increment frame counter ($70BE)
    CALL    SOUND_MAN                       ; update BIOS sound manager
    CALL    PLAY_SONGS                      ; play queued sound sequences
    CALL    SOUND_WRITE_837D                ; read both controllers into $70BF-$70C2
    CALL    SUB_B70F                        ; update sound channel registers in VRAM
    POP     HL                              ; restore alternate HL
    POP     DE                              ; restore alternate DE
    POP     BC                              ; restore alternate BC
    POP     AF                              ; restore alternate AF
    EX      AF, AF'                         ; swap back to main AF
    EXX                                     ; swap back to main BC/DE/HL
    POP     IY                              ; restore IY
    POP     IX                              ; restore IX
    POP     HL                              ; restore HL
    POP     DE                              ; restore DE
    POP     BC                              ; restore BC
    IN      A, ($BF)                        ; read VDP status (acknowledge VSYNC interrupt)
    XOR     A                               ; A = 0
    LD      ($70AE), A                      ; clear NMI active flag ($70AE = 0)
    POP     AF                              ; restore AF
    RETN                                    ; return from non-maskable interrupt
    DB      $F5, $18, $F6

; =============================================================================
; START ($8068) -- power-on boot entry
; =============================================================================
; One-time init sequence:
;   LD SP,$70AC           -- set stack pointer (note: $70AC also = NMI vector,
;                            uses pre-NMI value as initial SP)
;   OUT ($BF),$80 / OUT ($BF),$81  -- write VDP registers 0 and 1 (VDP off)
;   LD HL,WORK_BUFFER     -- zero all RAM $7000-$73FF:
;     LOC_8074: ADC A,(HL) / LD (HL),$00 / INC HL / BIT 2,H / JR Z,LOC_8074
;     (accumulates checksum in A; exits when H hits $74)
;   LD ($73C8),HL         -- store RAM checksum seed
;   LD A,$02 / LD ($70AF),A  -- set game phase = 2 (intro/title)
;   fall through to LOC_8085 (game init)
; =============================================================================
START:
    LD      SP, $70AC                       ; set stack pointer ($70AC = also NMI vector slot)
    LD      A, $80                          ; VDP disable value
    OUT     ($BF), A                        ; write VDP reg 0 (disable display)
    LD      A, $81                          ; VDP register 1 select
    OUT     ($BF), A                        ; write VDP reg 1 (select reg 0: disable display)
    LD      HL, WORK_BUFFER                 ; HL = $7000 (WORK_BUFFER base)

LOC_8074:
    ADC     A, (HL)                         ; accumulate RAM checksum byte
    LD      (HL), $00                       ; zero this RAM byte
    INC     HL                              ; advance pointer
    BIT     2, H                            ; test if H reached $74 (past $73FF)
    JR      Z, LOC_8074                     ; loop until all $400 bytes zeroed
    LD      L, A                            ; keep checksum in L
    LD      ($73C8), HL                     ; store checksum word at $73C8
    LD      A, $02                          ; game phase = 2 (intro/title)
    LD      ($70AF), A                      ; set game phase flag $70AF = 2

; =============================================================================
; LOC_8085 ($8085) -- game/level re-entry and init
; =============================================================================
; Entered from START and from game-over / new-game reset:
;   LD HL,$0E10 / LD ($70B0),HL   -- init frame counter (3600 dec)
;   CALL SUB_8369                  -- disarm NMI ($70AC = safe redirect)
;   LD A,$00 / CALL SUB_8C67       -- game-state dispatcher: phase 0 (blank)
;   LD A,$01 / CALL SUB_8C67       -- phase 1 (VDP register setup)
;   LD HL,BOOT_UP / LD BC,$4000    -- blank entire VRAM ($4000 bytes)
;   CALL VDP_WRITE_84A7
;   CALL VDP_INIT_8278             -- full VDP register init (9 writes via
;                                     SUB_8369/VDP_REG_8352 arm/disarm pairs)
;   CALL SUB_80C0                  -- level init:
;     load terrain tile block from ROM data ($8763/$8765 ptr pair -> VRAM)
;     SUB_834C (RAND_GEN wrapper) -> $7120 (game-mode / AI flag)
;     SOUND_WRITE_B6ED (SN76489A init), VDP_INIT_99F4 (sprite table setup)
;     DELAY_LOOP_B7C0 (clear sprite attribute buffer at $7350)
;     load HUD tile blocks, wait LOC_8107 (sync on NMI counter)
; LOC_80A9 ($80A9): LD A,$01 / LD ($70AF),A  -- game phase = 1
; LOC_80AE ($80AE): per-frame loop (called repeatedly):
;   CALL SUB_8C67 A=$01            -- phase-1 game logic dispatch
;   CALL DELAY_LOOP_B79C           -- flush sprite attr buffer $7350 to VDP $3F40
;   if $70AF != 0: CALL SOUND_WRITE_84FD  -- title music start
;   JP LOC_9554                    -- enter main 2-player game loop
; =============================================================================
LOC_8085:
    LD      HL, $0E10                       ; frame countdown = $0E10 (3600 frames ~= 60 seconds)
    LD      ($70B0), HL                     ; store frame counter at $70B0
    CALL    SUB_8369                        ; disarm NMI ($70AC = safe stub $8063)
    LD      A, $00                          ; dispatcher task 0 (blank phase)
    CALL    SUB_8C67                        ; call game-state dispatcher
    LD      A, $01                          ; dispatcher task 1 (VDP setup phase)
    CALL    SUB_8C67                        ; call game-state dispatcher
    LD      HL, BOOT_UP                     ; HL = VRAM base $0000
    LD      BC, $4000                       ; BC = $4000 (blank entire 16 KB VRAM)
    LD      A, $00                          ; fill value = $00
    CALL    VDP_WRITE_84A7                  ; blank all VRAM
    CALL    VDP_INIT_8278                   ; init all VDP registers (9 writes, via SUB_8369/VDP_REG_8352 pairs)
    CALL    SUB_80C0                        ; level init: terrain tiles, sound, sprites

LOC_80A9:
    LD      A, $01                          ; game phase = 1 (active game)
    LD      ($70AF), A                      ; set game phase flag $70AF = 1

LOC_80AE:
    LD      A, $01                          ; dispatcher task 1
    CALL    SUB_8C67                        ; per-frame game logic dispatch
    CALL    DELAY_LOOP_B79C                 ; flush sprite attribute buffer to VDP $3F40
    LD      A, ($70AF)                      ; check game phase flag
    OR      A                               ; test if zero
    CALL    NZ, SOUND_WRITE_84FD            ; nonzero: run title screen setup
    JP      LOC_9554                        ; enter main 2-player game round loop (LOC_9554)

SUB_80C0:
    LD      HL, ($8763)                     ; load terrain tile ROM source pointer from $8763
    LD      DE, $1C60                       ; VRAM destination for terrain tiles = $1C60
    LD      BC, ($8765)                     ; load terrain tile byte count from $8765
    CALL    VDP_WRITE_8490                  ; copy terrain tiles to VRAM
    CALL    SUB_834C                        ; get random byte (RAND_GEN wrapper)
    AND     $10                             ; isolate bit 4 (mode select)
    LD      ($7120), A                      ; store AI/two-player mode flag at $7120
    LD      A, $0A                          ; initial wind value = $0A
    LD      ($70C6), A                      ; set wind speed at $70C6
    CALL    SOUND_WRITE_B6ED                ; init SN76489A (silence all channels)
    CALL    VDP_INIT_99F4                   ; init sprite attribute table in VRAM
    CALL    DELAY_LOOP_B7C0                 ; prime sprite attribute buffer at $7350
    LD      HL, $3C00
    LD      BC, $0080
    LD      A, $20
    CALL    VDP_WRITE_84A7
    LD      HL, ($8A8B)
    LD      DE, $0100
    LD      BC, ($8A8D)
    CALL    VDP_WRITE_8490
    LD      HL, $2100
    LD      BC, ($8A8D)
    LD      A, $10
    CALL    VDP_WRITE_84A7

LOC_8107:
    CALL    DELAY_LOOP_8C82
    JR      NZ, LOC_8107
    LD      A, $0D
    CALL    SUB_8C67
    XOR     A
    LD      ($70AF), A                  ; RAM $70AF
    LD      ($7147), A                  ; RAM $7147

LOC_8118:
    LD      A, ($7147)                  ; RAM $7147
    OR      A
    JR      NZ, LOC_818F
    LD      DE, $3C00
    CALL    VDP_WRITE_84E4
    JR      NZ, LOC_8146
    JR      NZ, LOC_8148
    JR      NZ, LOC_814A
    JR      NZ, LOC_814C
    JR      NZ, LOC_816F
    LD      D, D
    LD      D, H
    LD      C, C
    LD      C, H
    LD      C, H
    LD      B, L
    LD      D, D
    LD      E, C
    JR      NZ, LOC_817C
    LD      D, L
    LD      B, L
    LD      C, H
    JR      NZ, LOC_815D
    JR      NZ, LOC_815F
    JR      NZ, LOC_8161
    JR      NZ, LOC_8143

LOC_8143:
    LD      DE, $3C40

LOC_8146:
    CALL    VDP_WRITE_84E4
    JR      NZ, LOC_816B
    JR      NZ, LOC_816D
    JR      NZ, LOC_816F
    JR      NZ, LOC_8171
    LD      B, B
    LD      SP, $3839
    INC     SP
    INC     L
    JR      NZ, LOC_81B1
    LD      C, A
    LD      C, (HL)
    LD      C, A
    LD      E, B

LOC_815D:
    JR      NZ, LOC_81A8

LOC_815F:
    LD      C, (HL)
    LD      B, E

LOC_8161:
    LD      L, $20
    JR      NZ, LOC_8185
    JR      NZ, LOC_8187
    NOP     
    LD      DE, $3C61

LOC_816B:
    CALL    VDP_WRITE_84E4

LOC_816E:
    JR      NZ, LOC_8190

LOC_8170:
    JR      NZ, LOC_8192
    JR      NZ, LOC_8194
    LD      B, C
    LD      C, H
    LD      C, H
    JR      NZ, LOC_81CB
    LD      C, C
    LD      B, A
    LD      C, B

LOC_817C:
    LD      D, H
    LD      D, E
    JR      NZ, LOC_81D2
    LD      B, L
    LD      D, E
    LD      B, L
    LD      D, D
    LD      D, (HL)

LOC_8185:
    LD      B, L
    LD      B, H

LOC_8187:
    LD      L, $20
    JR      NZ, LOC_81AB
    JR      NZ, LOC_818D

LOC_818D:
    JR      LOC_81FE

LOC_818F:
    LD      DE, $3C00

LOC_8192:
    CALL    VDP_WRITE_84E4
    JR      NZ, LOC_81B7
    JR      NZ, LOC_81B9
    JR      NZ, LOC_81BB
    JR      NZ, LOC_81BD
    JR      NZ, LOC_81BF
    JR      NZ, LOC_81C1
    JR      NZ, LOC_81C3
    JR      NZ, LOC_81C5
    JR      NZ, LOC_81C7
    JR      NZ, LOC_81C9
    JR      NZ, LOC_81CB

LOC_81AB:
    JR      NZ, LOC_81CD
    JR      NZ, LOC_81CF
    JR      NZ, LOC_81D1

LOC_81B1:
    JR      NZ, LOC_81D3
    NOP     

LOC_81B4:
    LD      DE, $3C40

LOC_81B7:
    CALL    VDP_WRITE_84E4

LOC_81BA:
    JR      NZ, LOC_81DC

LOC_81BC:
    LD      D, B

LOC_81BD:
    LD      D, D

LOC_81BE:
    LD      B, L

LOC_81BF:
    LD      D, E

LOC_81C0:
    LD      D, E

LOC_81C1:
    JR      NZ, LOC_820E

LOC_81C3:
    LD      B, L

LOC_81C4:
    LD      E, C

LOC_81C5:
    LD      D, B

LOC_81C6:
    LD      B, C

LOC_81C7:
    LD      B, H

LOC_81C8:
    JR      NZ, LOC_820C

LOC_81CA:
    LD      D, L

LOC_81CB:
    LD      D, H

LOC_81CC:
    LD      D, H

LOC_81CD:
    LD      C, A

LOC_81CE:
    LD      C, (HL)

LOC_81CF:
    JR      NZ, LOC_8225

LOC_81D1:
    LD      C, A

LOC_81D2:
    JR      NZ, LOC_8227
    LD      D, H
    LD      B, C
    LD      D, D
    LD      D, H
    NOP     
    LD      DE, $3C61

LOC_81DC:
    CALL    VDP_WRITE_84E4
    JR      NZ, LOC_8201
    JR      NZ, LOC_8203
    JR      NZ, LOC_8205
    JR      NZ, LOC_8207
    JR      NZ, LOC_8209
    JR      NZ, LOC_820B
    JR      NZ, LOC_820D
    JR      NZ, LOC_820F
    JR      NZ, LOC_8211
    JR      NZ, LOC_8213
    JR      NZ, LOC_8215
    JR      NZ, LOC_8217
    JR      NZ, LOC_8219
    JR      NZ, LOC_821B
    JR      NZ, LOC_821D
    NOP     

LOC_81FE:
    LD      A, $F0
    LD      ($7114), A                  ; RAM $7114

LOC_8203:
    CALL    SUB_834C
    AND     $0F
    JR      Z, LOC_81FE
    CP      $01

LOC_820C:
    JR      Z, LOC_81FE

LOC_820E:
    CP      $0F
    JR      Z, LOC_81FE
    CP      $06
    JR      Z, LOC_81FE
    CP      $0A
    JR      Z, LOC_81FE
    CALL    SUB_8369

LOC_821D:
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $87
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    CALL    VDP_REG_8352
    CALL    DELAY_LOOP_8372

LOC_8229:
    RST     $08
    LD      BC, $82CD
    ADC     A, H
    JR      NZ, LOC_8229
    LD      A, ($70B2)                  ; RAM $70B2
    LD      HL, $70B3                   ; RAM $70B3
    OR      (HL)
    INC     HL
    INC     HL
    OR      (HL)
    INC     HL
    OR      (HL)
    RET     NZ
    LD      HL, ($70B0)                 ; RAM $70B0
    DEC     HL
    LD      A, H
    OR      L
    JR      Z, LOC_825B
    LD      ($70B0), HL                 ; RAM $70B0
    LD      A, ($7114)                  ; RAM $7114
    DEC     A
    LD      ($7114), A                  ; RAM $7114
    JR      NZ, LOC_8229
    LD      A, ($7147)                  ; RAM $7147
    CPL     
    LD      ($7147), A                  ; RAM $7147
    JP      LOC_8118

LOC_825B:
    POP     AF
    LD      HL, $1C20
    LD      ($70B0), HL                 ; RAM $70B0
    LD      IY, $70C3                   ; RAM $70C3
    LD      (IY+2), $03
    LD      IY, $70CD                   ; RAM $70CD
    LD      (IY+2), $03
    CALL    SUB_86CC
    JP      LOC_80AE

VDP_INIT_8278:
    CALL    SUB_8369
    LD      A, $E2
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $80
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    CALL    VDP_REG_8352
    CALL    SUB_8369
    LD      A, $E2
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $81
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    CALL    VDP_REG_8352
    CALL    SUB_8369
    LD      A, $0F
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $82
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    CALL    VDP_REG_8352
    CALL    SUB_8369
    LD      A, $FF
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $83
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    CALL    VDP_REG_8352
    CALL    SUB_8369
    LD      A, $03
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $84
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    CALL    VDP_REG_8352
    CALL    SUB_8369
    LD      A, $7E
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $85
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    CALL    VDP_REG_8352
    CALL    SUB_8369
    LD      A, $03
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $86
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    CALL    VDP_REG_8352
    CALL    SUB_8369
    LD      A, $07
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $87
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    CALL    VDP_REG_8352
    LD      HL, $3C00
    LD      BC, $0300
    LD      A, $00
    CALL    VDP_WRITE_84A7
    LD      HL, BOOT_UP
    LD      BC, $1800
    LD      A, $00
    CALL    VDP_WRITE_84A7
    LD      HL, $2000
    LD      BC, $1800
    LD      A, $F0
    CALL    VDP_WRITE_84A7
    LD      HL, $1800
    LD      BC, $0800
    LD      A, $00
    CALL    VDP_WRITE_84A7
    RET     

LOC_8315:
    CALL    VDP_REG_8352
    DB      $E3
    PUSH    BC
    PUSH    AF
    LD      B, (HL)
    INC     HL
    LD      A, ($70BE)                  ; RAM $70BE
    LD      C, A

LOC_8321:
    LD      A, ($70BE)                  ; RAM $70BE
    CP      C
    JR      Z, LOC_8321
    LD      C, A
    DJNZ    LOC_8321
    POP     AF
    POP     BC
    DB      $E3
    RET     

DELAY_LOOP_832E:
    PUSH    BC                              ; save BC
    PUSH    HL                              ; save HL
    PUSH    DE                              ; save DE
    LD      C, A                            ; save full param in C
    AND     $0F                             ; isolate low nibble (RAND_GEN call count)
    LD      B, A                            ; B = loop count

LOC_8335:
    CALL    SUB_834C
    DJNZ    LOC_8335
    CALL    SUB_834C                        ; final RAND_GEN call
    LD      HL, BOOT_UP                     ; HL = BOOT_UP base ($0000)
    LD      D, $00                          ; D = 0 (high byte of DE offset)
    LD      E, A                            ; E = random byte (offset)
    LD      B, C                            ; B = full param (scale factor)

LOC_8344:
    ADD     HL, DE                          ; HL += DE (random offset)
    DJNZ    LOC_8344                        ; loop B times to scale
    LD      A, H                            ; return scaled random value in A (high byte)
    POP     DE
    POP     HL
    POP     BC
    RET     

SUB_834C:
    PUSH    HL                              ; save HL
    CALL    RAND_GEN                        ; call BIOS random number generator
    POP     HL                              ; restore HL
    RET     

VDP_REG_8352:
    PUSH    HL                              ; save HL
    PUSH    AF                              ; save AF
    LD      HL, SOUND_WRITE_802A            ; HL = SOUND_WRITE_802A (NMI handler address)
    LD      ($70AC), HL                     ; arm NMI: $70AC = SOUND_WRITE_802A
    LD      A, ($70AE)                      ; load NMI active flag
    OR      A                               ; is NMI currently in progress?
    JR      NZ, LOC_8366                    ; yes: skip immediate poll (avoid re-entry)
    IN      A, ($BF)                        ; read VDP status register
    RLA                                     ; test interrupt pending bit
    CALL    C, SOUND_WRITE_802A             ; if VSYNC pending: service it now

LOC_8366:                                   ; restore AF
    POP     AF                              ; restore HL
    POP     HL
    RET     

SUB_8369:
    PUSH    HL                              ; save HL
    LD      HL, $8063                       ; HL = $8063 (safe NMI stub / RETI)
    LD      ($70AC), HL                     ; disarm NMI: $70AC = stub
    POP     HL                              ; restore HL
    RET     

DELAY_LOOP_8372:
    LD      HL, $70B2                       ; HL = $70B2 (controller edge-detect buffer)
    LD      B, $0C                          ; 12 bytes to clear

LOC_8377:
    LD      (HL), $00                       ; zero byte
    INC     HL                              ; advance pointer
    DJNZ    LOC_8377                        ; loop 12 times
    RET     

SOUND_WRITE_837D:
    OUT     ($C0), A                        ; set joystick mode (OUT $C0)
    NOP     
    NOP     
    IN      A, ($FC)                        ; read controller 1 joystick byte
    CPL                                     ; invert (active-low -> active-high)
    LD      ($70BF), A                      ; store P1 joystick byte at $70BF
    IN      A, ($FF)                        ; read controller 1 keypad byte
    CPL                                     ; invert
    LD      ($70C0), A                      ; store P1 keypad byte at $70C0
    OUT     ($80), A                        ; set keypad mode (OUT $80)
    NOP     
    NOP     
    IN      A, ($FC)                        ; read controller 1 in keypad mode
    CPL                                     ; invert
    LD      ($70C1), A                      ; store P1 keypad scan byte at $70C1
    IN      A, ($FF)                        ; read P1 second keypad byte
    CPL                                     ; invert
    LD      ($70C2), A                      ; store P1 second keypad byte at $70C2
    LD      BC, BOOT_UP                     ; init decoded button bits BC = 0
    LD      A, ($70C1)                  ; RAM $70C1
    CALL    SUB_8446                        ; decode P1 keypad byte $70C1 -> BC bit flags
    LD      A, ($70BF)                      ; load P1 joystick byte
    AND     $0F                             ; isolate directional bits
    LD      D, A                            ; D = directional bit field
    LD      A, ($70BF)                  ; RAM $70BF
    BIT     6, A                            ; test fire/action button bit
    JR      Z, LOC_83B5
    SET     4, D                            ; set bit 4 if fire button pressed

LOC_83B5:
    LD      A, ($70C1)                  ; RAM $70C1
    BIT     6, A
    JR      Z, LOC_83BE
    SET     5, D

LOC_83BE:
    LD      A, ($70B2)                      ; load previous P1 button state
    XOR     B                               ; XOR: bits set where state changed
    AND     B                               ; AND: bits set where newly pressed this frame
    LD      H, A                            ; H = P1 edge-triggered button events
    LD      A, ($70B8)                  ; RAM $70B8
    OR      H
    LD      ($70B8), A                      ; store P1 button press events at $70B8
    LD      A, B
    LD      ($70B2), A                      ; update P1 current button state at $70B2
    LD      A, ($70B3)                  ; RAM $70B3
    XOR     C
    AND     C
    LD      H, A
    LD      A, ($70B9)                  ; RAM $70B9
    OR      H
    LD      ($70B9), A                  ; RAM $70B9
    LD      A, C
    LD      ($70B3), A                  ; RAM $70B3
    LD      A, ($70B4)                  ; RAM $70B4
    XOR     D
    AND     D
    LD      H, A
    LD      A, ($70BA)                  ; RAM $70BA
    OR      H
    LD      ($70BA), A                  ; RAM $70BA
    LD      A, D
    LD      ($70B4), A                  ; RAM $70B4
    LD      BC, BOOT_UP
    LD      A, ($70C2)                  ; RAM $70C2
    CALL    SUB_8446                        ; decode P2 keypad byte $70C2 -> BC bit flags
    LD      A, ($70C0)                  ; RAM $70C0
    AND     $0F
    LD      D, A
    LD      A, ($70C0)                  ; RAM $70C0
    BIT     6, A
    JR      Z, LOC_8409
    SET     4, D

LOC_8409:
    LD      A, ($70C2)                  ; RAM $70C2
    BIT     6, A
    JR      Z, LOC_8412
    SET     5, D

LOC_8412:
    LD      A, ($70B5)                  ; RAM $70B5
    XOR     B
    AND     B
    LD      H, A
    LD      A, ($70BB)                  ; RAM $70BB
    OR      H
    LD      ($70BB), A                  ; RAM $70BB
    LD      A, B
    LD      ($70B5), A                  ; RAM $70B5
    LD      A, ($70B6)                  ; RAM $70B6
    XOR     C
    AND     C
    LD      H, A
    LD      A, ($70BC)                  ; RAM $70BC
    OR      H
    LD      ($70BC), A                  ; RAM $70BC
    LD      A, C
    LD      ($70B6), A                  ; RAM $70B6
    LD      A, ($70B7)                  ; RAM $70B7
    XOR     D
    AND     D
    LD      H, A
    LD      A, ($70BD)                  ; RAM $70BD
    OR      H
    LD      ($70BD), A                  ; RAM $70BD
    LD      A, D
    LD      ($70B7), A                  ; RAM $70B7
    RET     

SUB_8446:
    AND     $0F                             ; mask to keypad code low nibble
    CP      $0D
    JR      NZ, LOC_844E
    SET     4, B

LOC_844E:
    CP      $0E
    JR      NZ, LOC_8454
    SET     0, C

LOC_8454:
    CP      $03
    JR      NZ, LOC_845A
    SET     3, B

LOC_845A:
    CP      $0C
    JR      NZ, LOC_8460
    SET     5, B

LOC_8460:
    CP      $0A
    JR      NZ, LOC_8466
    SET     7, B

LOC_8466:
    CP      $05
    JR      NZ, LOC_846C
    SET     0, B

LOC_846C:
    CP      $06
    JR      NZ, LOC_8472
    SET     2, C

LOC_8472:
    CP      $09
    JR      NZ, LOC_8478
    SET     3, C

LOC_8478:
    CP      $02
    JR      NZ, LOC_847E
    SET     1, B

LOC_847E:
    CP      $08
    JR      NZ, LOC_8484
    SET     2, B

LOC_8484:
    CP      $01
    JR      NZ, LOC_848A
    SET     6, B

LOC_848A:
    CP      $04
    RET     NZ
    SET     1, C
    RET     

VDP_WRITE_8490:
    CALL    SUB_8369                        ; disarm NMI
    LD      A, E                            ; VRAM address low byte (E)
    OUT     ($BF), A                        ; write VRAM address low byte to ctrl port
    LD      A, D                            ; VRAM address high byte (D)
    ADD     A, $40                          ; add $40 (set VRAM write mode bit)
    OUT     ($BF), A                        ; write VRAM address high byte

LOC_849B:
    LD      A, (HL)                         ; load source byte
    INC     HL                              ; advance source pointer
    OUT     ($BE), A                        ; write byte to VRAM data port
    DEC     BC                              ; decrement byte count
    LD      A, B
    OR      C                               ; test BC == 0
    JR      NZ, LOC_849B                    ; loop until all bytes written
    JP      VDP_REG_8352                    ; re-arm NMI and return

VDP_WRITE_84A7:
    CALL    SUB_8369                        ; disarm NMI
    PUSH    DE                              ; save DE (HL = VRAM addr, A = fill value)
    LD      D, A                            ; save fill value in D
    LD      A, L                            ; VRAM address low byte
    OUT     ($BF), A                        ; write VRAM address low byte
    LD      A, H                            ; VRAM address high byte
    ADD     A, $40                          ; add $40 (VRAM write mode)
    OUT     ($BF), A                        ; write VRAM address high byte

LOC_84B4:
    LD      A, D                            ; reload fill value
    OUT     ($BE), A                        ; write fill byte to VRAM
    DEC     BC                              ; decrement count BC
    LD      A, B
    OR      C                               ; test BC == 0
    JR      NZ, LOC_84B4                    ; loop until BC == 0
    POP     DE                              ; restore DE
    JP      VDP_REG_8352                    ; re-arm NMI and return

VDP_WRITE_84C0:
    CALL    SUB_8369                        ; disarm NMI
    LD      A, E                            ; VRAM address low byte
    OUT     ($BF), A                        ; write VRAM address low byte
    LD      A, D                            ; VRAM address high byte
    ADD     A, $40                          ; add $40 (VRAM write mode)
    OUT     ($BF), A                        ; write VRAM address high byte
    LD      D, B                            ; DE = byte count BC
    LD      E, C

LOC_84CD:
    LD      A, (HL)                         ; load source byte
    INC     HL                              ; advance source pointer
    LD      C, $00                          ; C = reversed byte accumulator = 0
    LD      B, $08                          ; 8 bits to reverse

LOC_84D3:
    RL      A                               ; shift source bit into carry
    RR      C                               ; shift carry into reversed accumulator
    DJNZ    LOC_84D3                        ; repeat 8 times (mirror all bits)
    LD      A, C                            ; A = bit-reversed byte
    OUT     ($BE), A                        ; write bit-reversed byte to VRAM
    DEC     DE
    LD      A, D
    OR      E
    JR      NZ, LOC_84CD
    JP      VDP_REG_8352

VDP_WRITE_84E4:
    CALL    SUB_8369                        ; disarm NMI
    POP     HL                              ; POP return address: use as inline string pointer
    LD      A, E                            ; VRAM address low byte
    OUT     ($BF), A                        ; write VRAM address low byte
    LD      A, D
    ADD     A, $40                          ; add $40 (VRAM write mode)
    OUT     ($BF), A                        ; write VRAM address high byte

LOC_84F0:
    LD      A, (HL)                         ; load next string byte
    INC     HL                              ; advance string pointer
    OR      A                               ; test for null terminator ($00)
    JR      Z, LOC_84F9                     ; zero = end of string
    OUT     ($BE), A                        ; write character tile to VRAM data port
    JR      LOC_84F0

LOC_84F9:
    PUSH    HL                              ; push updated string pointer (becomes new return address)
    JP      VDP_REG_8352                    ; re-arm NMI and return (past inline string data)

SOUND_WRITE_84FD:
    LD      HL, $2000
    LD      BC, $1800
    LD      A, $00
    CALL    VDP_WRITE_84A7
    LD      HL, BOOT_UP
    LD      BC, $1800
    LD      A, $00
    CALL    VDP_WRITE_84A7
    LD      HL, $2000
    LD      BC, $1800
    LD      A, $F0
    CALL    VDP_WRITE_84A7
    LD      HL, $3C00
    LD      BC, $0300
    LD      A, $FF
    CALL    VDP_WRITE_84A7
    LD      HL, $3F00
    LD      BC, $0080
    LD      A, $C0
    CALL    VDP_WRITE_84A7
    LD      HL, $1800
    LD      BC, $0800
    LD      A, $00
    CALL    VDP_WRITE_84A7
    LD      HL, ($8A8B)
    LD      DE, $0100
    LD      BC, ($8A8D)
    CALL    VDP_WRITE_8490
    LD      HL, ($8A8B)
    LD      DE, $0900
    LD      BC, ($8A8D)
    CALL    VDP_WRITE_8490
    LD      HL, ($8A8B)
    LD      DE, $1100
    LD      BC, ($8A8D)
    CALL    VDP_WRITE_8490
    LD      DE, $3D43
    CALL    VDP_WRITE_84E4
    LD      D, B
    LD      C, H
    LD      B, C
    LD      E, C
    LD      B, L
    LD      D, D
    JR      NZ, LOC_85A5
    JR      NZ, LOC_85C9
    LD      B, L
    LD      C, H
    LD      B, L
    LD      B, E
    LD      D, H
    JR      NZ, LOC_85D0
    LD      C, E
    LD      C, C
    LD      C, H
    LD      C, H
    JR      NZ, LOC_85CF
    LD      B, L
    LD      D, (HL)
    LD      B, L
    LD      C, H
    NOP     
    LD      DE, $3D8A
    CALL    VDP_WRITE_84E4
    LD      SP, $4320
    LD      C, A
    LD      D, D
    LD      D, B
    LD      C, A
    LD      D, D
    LD      B, C
    LD      C, H
    NOP     
    LD      DE, $3DAA
    CALL    VDP_WRITE_84E4
    LD      ($4320), A
    LD      B, C
    LD      D, B
    LD      D, H

LOC_85A5:
    LD      B, C
    LD      C, C
    LD      C, (HL)
    NOP     
    LD      DE, $3DCA
    CALL    VDP_WRITE_84E4
    INC     SP
    JR      NZ, LOC_85F9
    LD      B, L
    LD      C, (HL)
    LD      B, L
    LD      D, D
    LD      B, C
    LD      C, H
    NOP     
    CALL    SUB_8369
    LD      A, $07
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $87
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    CALL    VDP_REG_8352
    LD      IY, $70C3                   ; RAM $70C3
    LD      (IY+4), $00

LOC_85CF:
    LD      (IY+8), $00
    CALL    SUB_870E
    LD      A, (IY+2)
    CP      $01
    JR      Z, LOC_8601
    CP      $02
    JR      Z, LOC_8622
    LD      DE, $3E24
    CALL    VDP_WRITE_84E4
    LD      D, B
    LD      C, H
    LD      B, C
    LD      E, C
    LD      B, L
    LD      D, D
    JR      NZ, LOC_8620
    JR      NZ, LOC_8643
    LD      B, C
    LD      C, (HL)
    LD      C, E
    JR      NZ, LOC_8623
    JR      NZ, LOC_863F
    LD      B, L

LOC_85F9:
    LD      C, (HL)
    LD      B, L
    LD      D, D
    LD      B, C
    LD      C, H
    NOP     
    JR      LOC_8640

LOC_8601:
    LD      DE, $3E24
    CALL    VDP_WRITE_84E4
    LD      D, B
    LD      C, H
    LD      B, C
    LD      E, C
    LD      B, L
    LD      D, D
    JR      NZ, LOC_8640
    JR      NZ, LOC_8663
    LD      B, C
    LD      C, (HL)
    LD      C, E
    JR      NZ, LOC_8643
    JR      NZ, LOC_865B
    LD      C, A
    LD      D, D
    LD      D, B
    LD      C, A
    LD      D, D
    LD      B, C
    LD      C, H
    NOP     

LOC_8620:
    JR      LOC_8640

LOC_8622:
    LD      DE, $3E24
    CALL    VDP_WRITE_84E4
    LD      D, B
    LD      C, H
    LD      B, C
    LD      E, C
    LD      B, L
    LD      D, D
    JR      NZ, LOC_8661
    JR      NZ, LOC_8684
    LD      B, C
    LD      C, (HL)
    LD      C, E
    JR      NZ, LOC_8664
    JR      NZ, LOC_867C
    LD      B, C
    LD      D, B
    LD      D, H
    LD      B, C
    LD      C, C
    LD      C, (HL)

LOC_863F:
    NOP     

LOC_8640:
    RST     $08
    LD      BC, $4311
    DEC     A
    CALL    VDP_WRITE_84E4
    LD      D, B
    LD      C, H
    LD      B, C
    LD      E, C
    LD      B, L
    LD      D, D
    JR      NZ, LOC_8682
    NOP     
    LD      IY, $70CD                   ; RAM $70CD
    LD      (IY+4), $00
    LD      (IY+8), $00
    CALL    SUB_870E
    LD      A, (IY+2)

LOC_8663:
    CP      $01
    JR      Z, LOC_868B
    CP      $02
    JR      Z, LOC_86AC
    LD      DE, $3E64
    CALL    VDP_WRITE_84E4
    LD      D, B
    LD      C, H
    LD      B, C
    LD      E, C
    LD      B, L
    LD      D, D
    JR      NZ, LOC_86AB
    JR      NZ, LOC_86CD
    LD      B, C

LOC_867C:
    LD      C, (HL)
    LD      C, E
    JR      NZ, LOC_86AD
    JR      NZ, LOC_86C9

LOC_8682:
    LD      B, L
    LD      C, (HL)

LOC_8684:
    LD      B, L
    LD      D, D
    LD      B, C
    LD      C, H
    NOP     
    JR      LOC_86CA

LOC_868B:
    LD      DE, $3E64
    CALL    VDP_WRITE_84E4
    LD      D, B
    LD      C, H
    LD      B, C
    LD      E, C
    LD      B, L
    LD      D, D
    JR      NZ, LOC_86CB
    JR      NZ, LOC_86ED
    LD      B, C
    LD      C, (HL)
    LD      C, E
    JR      NZ, LOC_86CD
    JR      NZ, LOC_86E5
    LD      C, A
    LD      D, D
    LD      D, B
    LD      C, A
    LD      D, D
    LD      B, C
    LD      C, H
    NOP     
    JR      LOC_86CA

LOC_86AC:
    LD      DE, $3E64
    CALL    VDP_WRITE_84E4
    LD      D, B
    LD      C, H
    LD      B, C
    LD      E, C
    LD      B, L
    LD      D, D
    JR      NZ, LOC_86EC
    JR      NZ, SUB_870E
    LD      B, C
    LD      C, (HL)
    LD      C, E
    JR      NZ, LOC_86EE
    JR      NZ, LOC_8706
    LD      B, C
    LD      D, B
    LD      D, H
    LD      B, C
    LD      C, C
    LD      C, (HL)

LOC_86C9:
    NOP     

LOC_86CA:
    RST     $08

LOC_86CB:
    LD      H, H

SUB_86CC:
    LD      HL, ($8753)
    LD      DE, $1820
    LD      BC, ($8755)
    CALL    VDP_WRITE_8490
    LD      HL, ($8757)
    LD      DE, $1960
    LD      BC, ($8759)
    CALL    VDP_WRITE_84C0
    LD      HL, ($875F)
    LD      DE, $1B20

LOC_86EC:
    LD      BC, ($8761)
    CALL    VDP_WRITE_8490
    LD      HL, ($8763)
    LD      DE, $1C60
    LD      BC, ($8765)
    CALL    VDP_WRITE_8490
    LD      HL, ($8767)
    LD      DE, $1D00

LOC_8706:
    LD      BC, ($8769)
    CALL    VDP_WRITE_8490
    RET     

SUB_870E:
    RST     $08
    LD      BC, $B23A
    LD      (HL), B
    LD      B, A
    LD      A, ($70B5)                  ; RAM $70B5
    OR      B
    JR      NZ, SUB_870E
    LD      A, $3C
    LD      ($7114), A                  ; RAM $7114
    CALL    DELAY_LOOP_8372

LOC_8722:
    RST     $08
    LD      BC, $B83A
    LD      (HL), B
    BIT     1, A
    JR      NZ, LOC_8744
    BIT     2, A
    JR      NZ, LOC_8749
    BIT     3, A
    JR      NZ, LOC_874E
    LD      A, ($70BB)                  ; RAM $70BB
    BIT     1, A
    JR      NZ, LOC_8744
    BIT     2, A
    JR      NZ, LOC_8749
    BIT     3, A
    JR      NZ, LOC_874E
    JR      LOC_8722

LOC_8744:
    LD      (IY+2), $01
    RET     

LOC_8749:
    LD      (IY+2), $02
    RET     

LOC_874E:
    LD      (IY+2), $03
    RET     
    DB      $6B, $87, $40, $01, $AB, $87, $00, $01
    DB      $8B, $87, $20, $00, $AB, $88, $40, $01
    DB      $EB, $89, $80, $00, $6B, $8A, $20, $00
    DB      $C0, $C0, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $01, $33, $7B, $F5, $FB
    DB      $5F, $3F, $77, $FA, $FD, $4F, $04, $00
    DB      $00, $00, $C0, $E0, $D0, $AF, $FF, $FE
    DB      $F7, $EF, $FC, $F8, $D8, $80, $00, $00
    DB      $00, $00, $C0, $C0, $C0, $D8, $D8, $DC
    DB      $DE, $D8, $C0, $18, $1C, $14, $34, $00
    DB      $00, $00, $60, $60, $60, $6C, $6C, $6E
    DB      $6F, $6C, $60, $0C, $0E, $0A, $1A, $00
    DB      $00, $00, $18, $1A, $02, $02, $02, $02
    DB      $00, $02, $1A, $02, $00, $00, $40, $46
    DB      $00, $00, $0C, $0D, $01, $01, $01, $01
    DB      $00, $01, $0D, $01, $00, $00, $20, $23
    DB      $00, $C0, $C0, $C0, $D8, $D8, $DC, $DE
    DB      $D8, $C0, $18, $18, $14, $14, $08, $00
    DB      $00, $60, $60, $60, $6C, $6C, $6E, $6F
    DB      $6C, $60, $0C, $0C, $0A, $0A, $04, $00
    DB      $00, $18, $1A, $02, $02, $02, $02, $00
    DB      $02, $1A, $02, $00, $00, $20, $20, $0C
    DB      $00, $0C, $0D, $01, $01, $01, $01, $00
    DB      $01, $0D, $01, $00, $00, $20, $20, $06
    DB      $C0, $C0, $C0, $D8, $D8, $DC, $DE, $D8
    DB      $C0, $18, $1C, $16, $14, $10, $10, $00
    DB      $60, $60, $60, $6C, $6C, $6E, $6F, $6C ; "```llnol"
    DB      $60, $0C, $0E, $0B, $0A, $08, $08, $00
    DB      $18, $1A, $02, $02, $02, $02, $00, $02
    DB      $1A, $02, $00, $00, $00, $08, $04, $18
    DB      $0C, $0D, $01, $01, $01, $01, $00, $01
    DB      $0D, $01, $00, $00, $00, $04, $02, $0C
    DB      $00, $C0, $C0, $C0, $D8, $D8, $DC, $DE
    DB      $D8, $C0, $18, $18, $14, $14, $00, $00
    DB      $00, $60, $60, $60, $6C, $6C, $6E, $6F
    DB      $6C, $60, $0C, $0C, $0A, $0A, $00, $00
    DB      $00, $18, $1A, $02, $02, $02, $02, $00
    DB      $02, $1A, $02, $00, $00, $00, $26, $10
    DB      $00, $0C, $0D, $01, $01, $01, $01, $00
    DB      $01, $0D, $01, $00, $00, $00, $13, $08
    DB      $00, $00, $C0, $C0, $C0, $C0, $C0, $C0
    DB      $C0, $C0, $80, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $18, $18, $38, $30, $70, $60
    DB      $E0, $C0, $C0, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $0C, $1C, $38, $70
    DB      $E0, $C0, $80, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $03, $0F, $3C
    DB      $F0, $C0, $80, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $FF, $FF, $80, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $03, $03, $03, $03, $03, $03
    DB      $03, $03, $01, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $18, $18, $1C, $0C, $0E, $06
    DB      $07, $03, $03, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $30, $38, $1C, $0E
    DB      $07, $03, $01, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $C0, $F0, $3C
    DB      $0F, $03, $01, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $FF, $FF, $01, $00, $00, $00, $00, $00
    DB      $00, $38, $FD, $BD, $6E, $86, $00, $00
    DB      $01, $02, $01, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $82, $03, $01, $12, $09
    DB      $2F, $BD, $07, $02, $00, $00, $00, $00
    DB      $54, $AA, $7E, $B7, $BF, $7D, $9E, $57
    DB      $F5, $DF, $EE, $57, $0B, $00, $00, $00
    DB      $00, $00, $00, $20, $5C, $F6, $EB, $7E
    DB      $70, $60, $B0, $E0, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $03
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $0A, $16, $FF, $15, $FE
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $54, $AA, $7E, $B7, $FF, $DC, $78, $25
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $20, $5C, $F6, $E3, $0E
    DB      $B0, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $03, $03, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $C0, $C0, $00, $00, $00, $00, $00
    DB      $8F, $8A, $D8, $01, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $18, $18, $18, $18
    DB      $18, $00, $18, $00, $66, $66, $66, $00
    DB      $00, $00, $00, $00, $6C, $FE, $FE, $6C
    DB      $FE, $FE, $6C, $00, $38, $D6, $F0, $38
    DB      $1E, $D6, $38, $00, $F2, $F6, $0C, $18
    DB      $30, $DE, $DE, $00, $3C, $66, $6C, $38
    DB      $3A, $6E, $6E, $3C, $18, $18, $20, $00
    DB      $00, $00, $00, $00, $18, $30, $60, $60
    DB      $60, $30, $18, $00, $30, $18, $0C, $0C
    DB      $0C, $18, $30, $00, $92, $54, $38, $FE
    DB      $38, $54, $92, $00, $00, $18, $18, $7E
    DB      $7E, $18, $18, $00, $00, $00, $00, $00
    DB      $18, $18, $20, $00, $00, $00, $00, $FE
    DB      $FE, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $18, $18, $00, $03, $06, $0C, $18
    DB      $30, $60, $C0, $00, $7C, $FE, $C6, $C6
    DB      $C6, $FE, $7C, $00, $38, $78, $18, $18
    DB      $18, $FE, $FE, $00, $7C, $FE, $C6, $18
    DB      $60, $FE, $FE, $00, $7C, $FE, $06, $3E
    DB      $06, $FE, $7C, $00, $1C, $3C, $6C, $CC
    DB      $FE, $FE, $0C, $00, $FE, $FE, $C0, $FC
    DB      $06, $FE, $7C, $00, $7C, $FE, $C0, $FC
    DB      $C6, $FE, $7C, $00, $FE, $FE, $06, $0C
    DB      $18, $30, $30, $00, $7C, $FE, $C6, $7C
    DB      $C6, $FE, $7C, $00, $7C, $FE, $C6, $7E
    DB      $06, $FE, $7C, $00, $7C, $FE, $C6, $C6
    DB      $C6, $FE, $7C, $00, $00, $38, $38, $00
    DB      $00, $38, $38, $00, $06, $1C, $70, $C0
    DB      $70, $1C, $06, $00, $00, $FE, $FE, $00
    DB      $FE, $FE, $00, $00, $C0, $70, $1C, $06
    DB      $1C, $70, $C0, $00, $3C, $66, $C6, $0C
    DB      $18, $00, $18, $00, $7C, $82, $BA, $A2
    DB      $BA, $82, $7C, $00, $38, $6C, $C6, $FE
    DB      $C6, $C6, $C6, $00, $FC, $FE, $C6, $FC
    DB      $C6, $FE, $FC, $00, $3C, $FE, $E0, $C0
    DB      $E0, $FE, $3C, $00, $FC, $FE, $C6, $C6
    DB      $C6, $FE, $FC, $00, $FE, $FE, $C0, $F8
    DB      $C0, $FE, $FE, $00, $FE, $FE, $C0, $F8
    DB      $F8, $C0, $C0, $00, $7C, $FE, $C0, $CE
    DB      $C6, $FE, $7E, $00, $C6, $C6, $C6, $FE
    DB      $C6, $C6, $C6, $00, $3C, $18, $18, $18
    DB      $18, $18, $3C, $00, $06, $06, $06, $C6
    DB      $C6, $7E, $3C, $00, $C6, $CC, $D8, $F0
    DB      $D8, $CC, $C6, $00, $C0, $C0, $C0, $C0
    DB      $C0, $FE, $FE, $00, $C6, $C6, $EE, $FE
    DB      $D6, $C6, $C6, $00, $C6, $C6, $F6, $DE
    DB      $CE, $C6, $C6, $00, $FE, $FE, $C6, $C6
    DB      $C6, $FE, $FE, $00, $FC, $FE, $C6, $FE
    DB      $FC, $C0, $C0, $00, $7C, $FE, $C6, $C6
    DB      $DE, $FE, $7E, $03, $FC, $FE, $C6, $FE
    DB      $FC, $CC, $C6, $00, $7C, $FE, $80, $7C
    DB      $02, $FE, $7C, $00, $FE, $FE, $18, $18
    DB      $18, $18, $18, $00, $C6, $C6, $C6, $C6
    DB      $C6, $FE, $7C, $00, $C6, $C6, $C6, $C6
    DB      $66, $3C, $18, $00, $C6, $C6, $C6, $D6
    DB      $FE, $EE, $C6, $00, $C6, $6C, $38, $38
    DB      $6C, $C6, $C6, $00, $CC, $CC, $CC, $78
    DB      $30, $30, $30, $00, $FE, $FE, $0C, $18
    DB      $60, $FE, $FE, $00

SUB_8C67:
    PUSH    BC                              ; save BC
    PUSH    DE                              ; save DE
    PUSH    HL                              ; save HL
    PUSH    IX                              ; save IX
    PUSH    IY                              ; save IY
    LD      E, A                            ; E = task index (from A)
    LD      A, ($70AF)                      ; load game phase flag $70AF
    OR      A                               ; is game phase zero?
    JP      Z, LOC_8D93                     ; yes: skip dispatch (fall through to LOC_8D93)
    LD      D, $00                          ; D = 0 (high byte for HL offset)
    LD      HL, $8C9D                       ; HL = dispatch table base $8C9D
    ADD     HL, DE                          ; HL += E (index into table)
    ADD     HL, DE                          ; HL += E again (each entry is 2 bytes)
    LD      A, (HL)                         ; load low byte of target address
    INC     HL                              ; advance to high byte
    LD      H, (HL)                         ; H = high byte of target
    LD      L, A                            ; L = low byte of target
    JP      (HL)                            ; jump to dispatch table entry

DELAY_LOOP_8C82:
    PUSH    HL                              ; save HL
    PUSH    DE                              ; save DE
    PUSH    BC                              ; save BC
    LD      C, A                            ; save A (task context)
    LD      DE, $000A                       ; DE = $000A (stride between task slots)
    LD      HL, $70E1                       ; HL = $70E1 (first task slot)
    LD      B, $05                          ; B = 5 (number of task slots to check)

LOC_8C8E:
    LD      A, (HL)                         ; load task slot byte
    AND     $3F                             ; mask to lower 6 bits (frame usage)
    CP      $3F                             ; compare to $3F (slot full?)
    JR      NZ, LOC_8C98                    ; not full: return NZ (slot available)
    ADD     HL, DE                          ; advance to next slot
    DJNZ    LOC_8C8E                        ; loop all 5 slots

LOC_8C98:
    LD      A, C                            ; restore A
    POP     BC
    POP     DE
    POP     HL
    RET     
    DB      $9B, $8D, $A0, $8D, $69, $8D, $70, $8D
    DB      $77, $8D, $37, $8D, $43, $8D, $BF, $8C
    DB      $21, $8D, $CC, $8C, $DE, $8C, $F0, $8C
    DB      $7E, $8D, $8C, $8D, $FD, $8C, $0F, $8D
    DB      $29, $8D, $06, $1A, $CD, $F1, $1F, $06
    DB      $1B, $CD, $F1, $1F, $C3, $93, $8D, $06
    DB      $1C, $CD, $F1, $1F, $06, $1D, $CD, $F1
    DB      $1F, $06, $1E, $CD, $F1, $1F, $C3, $93
    DB      $8D, $06, $16, $CD, $F1, $1F, $06, $1F
    DB      $CD, $F1, $1F, $06, $20, $CD, $F1, $1F
    DB      $C3, $93, $8D, $06, $21, $CD, $F1, $1F
    DB      $06, $22, $CD, $F1, $1F, $C3, $93, $8D
    DB      $06, $16, $CD, $F1, $1F, $06, $23, $CD
    DB      $F1, $1F, $06, $24, $CD, $F1, $1F, $C3
    DB      $93, $8D, $06, $25, $CD, $F1, $1F, $06
    DB      $26, $CD, $F1, $1F, $06, $27, $CD, $F1
    DB      $1F, $C3, $93, $8D, $06, $0B, $CD, $F1
    DB      $1F, $C3, $93, $8D, $CD, $4C, $83, $E6
    DB      $03, $C6, $29, $47, $CD, $F1, $1F, $C3
    DB      $93, $8D, $06, $05, $CD, $F1, $1F, $06
    DB      $0D, $CD, $F1, $1F, $18, $50, $06, $02
    DB      $CD, $F1, $1F, $06, $0D, $CD, $F1, $1F
    DB      $18, $44, $06, $03, $CD, $F1, $1F, $18
    DB      $3D, $06, $04, $CD, $F1, $1F, $18, $36
    DB      $06, $01, $CD, $F1, $1F, $06, $0C, $CD
    DB      $F1, $1F, $18, $2A, $06, $06, $CD, $F1
    DB      $1F, $18, $23, $06, $07, $CD, $F1, $1F
    DB      $18, $1C, $06, $08, $CD, $F1, $1F, $18
    DB      $15, $06, $09, $CD, $F1, $1F, $18, $0E
    DB      $06, $0A, $CD, $F1, $1F, $18, $07, $06
    DB      $0E, $CD, $F1, $1F, $18, $00

LOC_8D93:
    POP     IY                              ; restore IY
    POP     IX                              ; restore IX
    POP     HL                              ; restore HL
    POP     DE                              ; restore DE
    POP     BC                              ; restore BC
    RET     
    DB      $CD, $D6, $1F, $18, $F3, $21, $AA, $8D
    DB      $06, $05, $CD, $EE, $1F, $18, $E9, $01
    DB      $8F, $E1, $70, $86, $8E, $EB, $70, $8D
    DB      $8E, $EB, $70, $FA, $8E, $E1, $70, $5C
    DB      $8E, $EB, $70, $8F, $91, $FF, $70, $0E
    DB      $8F, $EB, $70, $77, $8F, $EB, $70, $7C
    DB      $8F, $EB, $70, $5B, $91, $E1, $70, $43
    DB      $95, $EB, $70, $8D, $8F, $EB, $70, $63
    DB      $8E, $F5, $70, $3D, $91, $EB, $70, $87
    DB      $8F, $F5, $70, $88, $8F, $E1, $70, $89
    DB      $8F, $EB, $70, $8A, $8F, $F5, $70, $8B
    DB      $8F, $FF, $70, $8C, $8F, $09, $71, $8D
    DB      $8F, $E1, $70, $8D, $8F, $EB, $70, $8D
    DB      $8F, $F5, $70, $8D, $8F, $FF, $70, $8D
    DB      $8F, $09, $71, $8F, $8F, $F5, $70, $A0
    DB      $8F, $FF, $70, $B1, $8F, $EB, $70, $BA
    DB      $8F, $F5, $70, $C3, $8F, $FF, $70, $C8
    DB      $8F, $09, $71, $D1, $8F, $FF, $70, $DA
    DB      $8F, $FF, $70, $E1, $8F, $09, $71, $E6
    DB      $8F, $FF, $70, $40, $90, $09, $71, $9A
    DB      $90, $EB, $70, $69, $91, $F5, $70, $6A
    DB      $91, $FF, $70, $3D, $91, $E1, $70, $E2
    DB      $94, $F5, $70, $FE, $94, $F5, $70, $13
    DB      $95, $F5, $70, $8D, $8F, $F5, $70, $FF
    DB      $FF, $42, $64, $10, $05, $25, $11, $10
    DB      $80, $32, $10, $01, $82, $32, $F0, $04
    DB      $F4, $11, $82, $32, $B0, $04, $22, $11
    DB      $10, $C0, $F1, $10, $02, $22, $C2, $74
    DB      $F0, $03, $F6, $11, $C2, $74, $90, $03
    DB      $16, $11, $10, $42, $74, $10, $05, $25
    DB      $11, $10, $42, $7F, $00, $0F, $53, $11
    DB      $42, $FE, $00, $0F, $53, $11, $42, $7F
    DB      $00, $0F, $53, $11, $42, $FE, $00, $0F
    DB      $53, $11, $42, $7F, $00, $0F, $53, $11
    DB      $42, $FE, $00, $0F, $53, $11, $42, $7F
    DB      $00, $0F, $53, $11, $42, $FE, $00, $0F
    DB      $53, $11, $42, $7F, $00, $0F, $53, $11
    DB      $42, $FE, $00, $0F, $53, $11, $42, $7F
    DB      $00, $0F, $53, $11, $42, $FE, $00, $0F
    DB      $53, $11, $42, $7F, $00, $0F, $53, $11
    DB      $42, $FE, $00, $0F, $53, $11, $42, $7F
    DB      $00, $0F, $53, $11, $42, $FE, $00, $0F
    DB      $53, $11, $42, $7F, $00, $0F, $53, $11
    DB      $42, $FE, $00, $0F, $53, $11, $10, $02
    DB      $FE, $14, $D7, $11, $F0, $10, $02, $FE
    DB      $D0, $10, $FA, $22, $02, $FE, $60, $10
    DB      $16, $22, $10, $42, $8E, $00, $03, $53
    DB      $11, $27, $42, $8E, $00, $03, $53, $11
    DB      $27, $42, $8E, $00, $03, $53, $11, $26
    DB      $42, $8E, $00, $03, $53, $11, $26, $42
    DB      $8E, $00, $03, $53, $11, $25, $42, $8E
    DB      $00, $03, $53, $11, $25, $42, $8E, $00
    DB      $03, $53, $11, $24, $42, $8E, $00, $03
    DB      $53, $11, $24, $42, $8E, $00, $03, $53
    DB      $11, $23, $42, $8E, $00, $03, $53, $11
    DB      $23, $42, $8E, $00, $03, $53, $11, $22
    DB      $42, $8E, $00, $03, $53, $11, $22, $42
    DB      $8E, $00, $03, $53, $11, $21, $42, $8E
    DB      $00, $03, $53, $11, $21, $42, $8E, $00
    DB      $03, $53, $11, $10, $00, $7F, $E4, $FF
    DB      $18, $00, $7F, $E4, $01, $10, $00, $FF
    DB      $34, $03, $21, $10, $C9, $10, $10, $10
    DB      $10, $10, $10, $C9, $C3, $01, $F0, $10
    DB      $11, $21, $00, $00, $C0, $01, $F0, $FF
    DB      $C0, $01, $F0, $FF, $10, $03, $00, $07
    DB      $10, $00, $00, $5F, $00, $00, $00, $A7
    DB      $FF, $00, $00, $A7, $FF, $10, $83, $20
    DB      $E0, $FF, $75, $01, $00, $00, $10, $C3
    DB      $01, $F0, $FF, $75, $01, $00, $00, $10
    DB      $00, $00, $C7, $FF, $18, $03, $01, $07
    DB      $30, $75, $00, $45, $F0, $10, $C3, $90
    DB      $F0, $30, $15, $04, $00, $00, $10, $C1
    DB      $2C, $70, $17, $11, $FF, $18, $00, $00
    DB      $33, $17, $18, $C3, $70, $F0, $30, $11
    DB      $04, $00, $00, $C3, $01, $F0, $10, $11
    DB      $0B, $00, $00, $C3, $70, $F0, $08, $11
    DB      $0B, $00, $00, $C3, $40, $F0, $10, $11
    DB      $0B, $00, $00, $22, $C3, $01, $F0, $19
    DB      $11, $0B, $00, $00, $C3, $31, $F0, $0F
    DB      $11, $01, $00, $00, $C3, $51, $F0, $14
    DB      $11, $09, $00, $00, $C3, $71, $F0, $0C
    DB      $11, $FF, $00, $00, $C3, $27, $F0, $27
    DB      $11, $0E, $00, $00, $C3, $20, $F0, $30
    DB      $11, $0E, $00, $00, $C3, $40, $F0, $48
    DB      $11, $0D, $00, $00, $10, $03, $00, $07
    DB      $30, $00, $00, $31, $10, $03, $00, $07
    DB      $10, $00, $00, $31, $10, $03, $00, $07
    DB      $08, $00, $00, $61, $10, $03, $00, $07
    DB      $10, $00, $00, $31, $10, $22, $03, $00
    DB      $07, $19, $00, $00, $59, $10, $03, $00
    DB      $07, $0F, $00, $00, $59, $10, $03, $00
    DB      $07, $14, $00, $00, $52, $10, $03, $00
    DB      $07, $0C, $00, $00, $50, $10, $03, $00
    DB      $07, $27, $00, $00, $32, $10, $03, $00
    DB      $07, $30, $00, $00, $32, $10, $03, $00
    DB      $07, $48, $00, $00, $32, $10, $10, $C0
    DB      $53, $71, $54, $C0, $28, $71, $0C, $C0
    DB      $C5, $71, $0C, $C0, $53, $71, $0C, $C0
    DB      $0D, $71, $0C, $05, $5C, $91, $C0, $C5
    DB      $71, $0C, $C0, $53, $71, $54, $C0, $28
    DB      $71, $0C, $C0, $C5, $71, $0C, $C0, $53
    DB      $71, $0C, $05, $5C, $91, $C0, $0D, $71
    DB      $0C, $C0, $C5, $71, $0C, $C0, $53, $71
    DB      $54, $C0, $28, $71, $0C, $05, $5C, $91
    DB      $C0, $0D, $71, $0C, $C0, $FE, $70, $0C
    DB      $C0, $E2, $70, $0C, $05, $5C, $91, $C0
    DB      $C9, $70, $0C, $C0, $E2, $70, $06, $C0
    DB      $C9, $70, $06, $05, $5C, $91, $C0, $E2
    DB      $70, $06, $C0, $C9, $70, $06, $C0, $E2
    DB      $70, $06, $05, $5C, $91, $C0, $C9, $70
    DB      $06, $C0, $E2, $70, $06, $C0, $C9, $70
    DB      $06, $05, $5C, $91, $C0, $E2, $70, $06
    DB      $C0, $C9, $70, $06, $05, $5C, $91, $C0
    DB      $E2, $70, $06, $C0, $C9, $70, $06, $C0
    DB      $E2, $70, $06, $05, $5C, $91, $C0, $C9
    DB      $70, $06, $C0, $F0, $70, $0C, $C0, $E2
    DB      $70, $0C, $02, $FE, $1F, $50, $13, $3F
    DB      $02, $FE, $1F, $50, $13, $3F, $02, $FE
    DB      $1F, $50, $13, $21, $02, $FE, $1F, $50
    DB      $13, $21, $02, $FE, $1F, $50, $13, $3F
    DB      $10, $DD, $75, $01, $DD, $74, $02, $C9
    DB      $3E, $10, $CD, $67, $8C, $C9, $10, $42
    DB      $1B, $42, $6C, $10, $C2, $42, $88, $43
    DB      $24, $10, $42, $42, $1B, $42, $6C, $10
    DB      $C2, $42, $88, $43, $24, $10, $42, $42
    DB      $1B, $42, $90, $10, $F2, $42, $88, $43
    DB      $4C, $10, $C2, $10, $03, $00, $44, $05
    DB      $00, $00, $10, $11, $03, $00, $54, $05
    DB      $00, $00, $10, $11, $03, $00, $44, $05
    DB      $00, $00, $10, $11, $03, $00, $04, $0F
    DB      $00, $00, $10, $21, $03, $00, $24, $0F
    DB      $00, $00, $10, $21, $03, $00, $04, $0F
    DB      $00, $00, $10, $21, $03, $00, $44, $05
    DB      $00, $00, $10, $11, $03, $00, $54, $05
    DB      $00, $00, $10, $11, $03, $00, $44, $05
    DB      $00, $00, $10, $11, $03, $00, $14, $07
    DB      $00, $00, $10, $11, $03, $00, $34, $08
    DB      $00, $00, $10, $11, $03, $00, $14, $07
    DB      $00, $00, $10, $11, $03, $00, $34, $08
    DB      $00, $00, $10, $11, $03, $00, $04, $0F
    DB      $00, $00, $10, $21, $03, $00, $44, $05
    DB      $00, $00, $10, $11, $03, $00, $54, $05
    DB      $00, $00, $10, $11, $03, $00, $44, $05
    DB      $00, $00, $10, $11, $03, $00, $04, $0F
    DB      $00, $00, $10, $21, $03, $00, $14, $07
    DB      $00, $00, $10, $11, $03, $00, $34, $08
    DB      $00, $00, $10, $11, $03, $00, $14, $07
    DB      $00, $00, $10, $11, $03, $00, $34, $08
    DB      $00, $00, $10, $11, $03, $00, $04, $07
    DB      $00, $00, $10, $21, $03, $00, $34, $08
    DB      $00, $00, $10, $11, $03, $00, $14, $07
    DB      $00, $00, $10, $11, $03, $00, $34, $08
    DB      $00, $00, $10, $11, $03, $00, $04, $0F
    DB      $00, $00, $10, $21, $03, $00, $04, $0F
    DB      $00, $00, $10, $21, $03, $00, $44, $05
    DB      $00, $00, $10, $11, $03, $00, $54, $05
    DB      $00, $00, $10, $11, $03, $00, $44, $05
    DB      $00, $00, $10, $11, $03, $00, $04, $0F
    DB      $00, $00, $10, $21, $03, $00, $24, $0F
    DB      $00, $00, $10, $21, $03, $00, $04, $0F
    DB      $00, $00, $10, $21, $03, $00, $44, $05
    DB      $00, $00, $10, $11, $03, $00, $54, $05
    DB      $00, $00, $10, $11, $03, $00, $44, $05
    DB      $00, $00, $10, $11, $03, $00, $14, $07
    DB      $00, $00, $10, $11, $03, $00, $34, $08
    DB      $00, $00, $10, $11, $03, $00, $14, $07
    DB      $00, $00, $10, $11, $03, $00, $34, $08
    DB      $00, $00, $10, $11, $03, $00, $04, $0F
    DB      $00, $00, $10, $21, $03, $00, $44, $05
    DB      $00, $00, $10, $11, $03, $00, $54, $05
    DB      $00, $00, $10, $11, $03, $00, $44, $05
    DB      $00, $00, $10, $11, $03, $00, $04, $0F
    DB      $00, $00, $10, $21, $03, $00, $14, $07
    DB      $00, $00, $10, $11, $03, $00, $34, $08
    DB      $00, $00, $10, $11, $03, $00, $14, $07
    DB      $00, $00, $10, $11, $03, $00, $34, $08
    DB      $00, $00, $10, $11, $03, $00, $04, $07
    DB      $00, $00, $10, $21, $03, $00, $34, $08
    DB      $00, $00, $10, $11, $03, $00, $04, $1E
    DB      $00, $00, $10, $21, $2F, $03, $00, $44
    DB      $05, $00, $00, $10, $11, $03, $00, $54
    DB      $05, $00, $00, $10, $11, $03, $00, $44
    DB      $05, $00, $00, $10, $11, $03, $00, $04
    DB      $0F, $00, $00, $10, $21, $03, $00, $24
    DB      $0F, $00, $00, $10, $21, $03, $00, $04
    DB      $0F, $00, $00, $10, $21, $03, $00, $44
    DB      $05, $00, $00, $10, $11, $03, $00, $54
    DB      $05, $00, $00, $10, $11, $03, $00, $44
    DB      $05, $00, $00, $10, $11, $03, $00, $14
    DB      $07, $00, $00, $10, $11, $03, $00, $34
    DB      $08, $00, $00, $10, $11, $03, $00, $14
    DB      $07, $00, $00, $10, $11, $03, $00, $34
    DB      $08, $00, $00, $10, $11, $03, $00, $04
    DB      $0F, $00, $00, $10, $21, $03, $00, $44
    DB      $05, $00, $00, $10, $11, $03, $00, $54
    DB      $05, $00, $00, $10, $11, $03, $00, $44
    DB      $05, $00, $00, $10, $11, $03, $00, $04
    DB      $0F, $00, $00, $10, $21, $03, $00, $14
    DB      $07, $00, $00, $10, $11, $03, $00, $34
    DB      $08, $00, $00, $10, $11, $03, $00, $14
    DB      $07, $00, $00, $10, $11, $03, $00, $34
    DB      $08, $00, $00, $10, $11, $03, $00, $04
    DB      $07, $00, $00, $10, $21, $03, $00, $34
    DB      $08, $00, $00, $10, $11, $03, $00, $14
    DB      $07, $00, $00, $10, $11, $03, $00, $34
    DB      $08, $00, $00, $10, $11, $03, $00, $04
    DB      $0F, $00, $00, $10, $21, $03, $00, $04
    DB      $0F, $00, $00, $10, $21, $03, $00, $44
    DB      $05, $00, $00, $10, $11, $03, $00, $54
    DB      $05, $00, $00, $10, $11, $03, $00, $44
    DB      $05, $00, $00, $10, $11, $03, $00, $04
    DB      $0F, $00, $00, $10, $21, $03, $00, $24
    DB      $0F, $00, $00, $10, $21, $03, $00, $04
    DB      $0F, $00, $00, $10, $21, $03, $00, $44
    DB      $05, $00, $00, $10, $11, $03, $00, $54
    DB      $05, $00, $00, $10, $11, $03, $00, $44
    DB      $05, $00, $00, $10, $11, $03, $00, $14
    DB      $07, $00, $00, $10, $11, $03, $00, $34
    DB      $08, $00, $00, $10, $11, $03, $00, $14
    DB      $07, $00, $00, $10, $11, $03, $00, $34
    DB      $08, $00, $00, $10, $11, $03, $00, $04
    DB      $0F, $00, $00, $10, $21, $03, $00, $44
    DB      $05, $00, $00, $10, $11, $03, $00, $54
    DB      $05, $00, $00, $10, $11, $03, $00, $44
    DB      $05, $00, $00, $10, $11, $03, $00, $04
    DB      $0F, $00, $00, $10, $21, $03, $00, $14
    DB      $07, $00, $00, $10, $11, $03, $00, $34
    DB      $08, $00, $00, $10, $11, $03, $00, $14
    DB      $07, $00, $00, $10, $11, $03, $00, $34
    DB      $08, $00, $00, $10, $11, $03, $00, $04
    DB      $07, $00, $00, $10, $21, $03, $00, $34
    DB      $08, $00, $00, $10, $11, $03, $00, $04
    DB      $1E, $00, $00, $10, $21, $2F, $10, $81
    DB      $1C, $40, $07, $11, $02, $30, $81, $1C
    DB      $40, $04, $11, $02, $2A, $81, $1C, $40
    DB      $04, $11, $02, $2B, $81, $1C, $40, $04
    DB      $11, $02, $10, $81, $15, $60, $07, $11
    DB      $FE, $30, $81, $20, $80, $06, $11, $FE
    DB      $2A, $81, $22, $60, $05, $11, $FE, $10
    DB      $81, $20, $40, $07, $15, $FF, $22, $80
    DB      $14, $70, $02, $80, $26, $70, $02, $80
    DB      $14, $70, $02, $80, $26, $70, $02, $80
    DB      $14, $70, $02, $80, $26, $70, $02, $80
    DB      $14, $80, $02, $80, $26, $80, $02, $80
    DB      $14, $80, $02, $80, $26, $80, $02, $10
    DB      $83, $62, $00, $05, $11, $FE, $30, $11
    DB      $83, $5F, $00, $05, $00, $00, $30, $11
    DB      $18

; =============================================================================
; LOC_9554 ($9554) -- main 2-player game loop
; =============================================================================
; Entry from LOC_80AE.  Outer loop = one full game; inner loop = one round.
;   LOC_9554: CALL VDP_REG_964C  -- arm NMI, init VDP color register (backdrop)
;
;   LOC_9557 (per-round loop):
;     DELAY_LOOP_B79C         -- flush sprite attr buffer $7350 to VDP $3F40
;     VDP_WRITE_84A7 $3F00    -- clear sprite table header ($0080 bytes, $C0)
;     VDP_INIT_99F4           -- init sprite attribute table from $7350 data
;     LD IX,($7118) / LD IY,($711A)  -- load P1/P2 cannon data ptrs
;     SUB_9675                -- pick P1 cannon horizontal position (RNG into $70C4)
;     SUB_96E9                -- pick P2 cannon horizontal position (RNG into $70CE)
;     SUB_9727                -- set wind / angle parameter (RNG -> $70C6/$70D0)
;       bit 5 of $73C8: determines 1-player vs 2-player mode -> $7120
;     SOUND_WRITE_B6ED        -- SN76489A init (silence all channels)
;     DELAY_LOOP_B7C0         -- prime sprite attr buffer (set $7350+3 |= $0F x4)
;     SUB_9706                -- init IX+5/6/7/9 and IY+5/6/7/9 (cannon sprites)
;     LOC_9589/LOC_95A0:  P1 or P2 aim sequence:
;       DELAY_LOOP_8C82 sync, SUB_975F (render cannon P1), SUB_9794 (render P2)
;
;   VDP_REG_95D6 ($95D6): arm NMI ($70AC=SOUND_WRITE_802A), clear $70E1 timer
;
;   LOC_95B5 (per-shot turn loop):
;     SUB_A64B ($A64B)    -- test game-over: C flag set if all rounds done
;     JR C, LOC_95C5      -- end of game
;     SUB_9838 ($9838)    -- swap active player: $7117 toggles 1<->2,
;                            swaps IX=$7118 <-> IY=$711A (cannon data ptrs)
;     SUB_987A ($987A)    -- projectile physics: trajectory render + collision
;     JR LOC_95B5
;
;   LOC_95C5 (end-of-game):
;     SUB_98F3, SUB_98FB  -- score update / victory display
;     SUB_B589            -- end-of-game sound sequence
;     SUB_9838            -- reset player pointer
;     VDP_INIT_95FF       -- clear VDP for next round
;     JR LOC_9557         -- start new round
; =============================================================================
LOC_9554:
    CALL    VDP_REG_964C                    ; init per-round score/damage vars (VDP_REG_964C)

LOC_9557:
    CALL    DELAY_LOOP_B79C                 ; reset sprite attribute buffer channels
    LD      HL, $3F00                       ; sprite attribute VRAM base = $3F00
    LD      BC, $0080                       ; 128 bytes to fill
    LD      A, $C0                          ; fill with $C0 (all sprites off-screen)
    CALL    VDP_WRITE_84A7                  ; hide all sprites
    CALL    VDP_INIT_99F4                   ; init name table and colour table (VDP_INIT_99F4)
    LD      IX, ($7118)                     ; IX = active player cannon data pointer ($7118)
    LD      IY, ($711A)                     ; IY = other player cannon data pointer ($711A)
    CALL    SUB_9675                        ; place P1 cannon at random X position
    CALL    SUB_96E9                        ; setup wind direction table pointer ($711C)
    CALL    SUB_9727                        ; init wind arrow display
    CALL    SOUND_WRITE_B6ED                ; silence all SN76489A channels
    CALL    DELAY_LOOP_B7C0                 ; prime sprite attribute buffer ($7350+3 |= $0F x4)
    CALL    SUB_9706                        ; init cannon sprite Y/tile/color for both cannons
    LD      A, ($7117)                      ; load active player flag from $7117
    CP      $01                             ; is active player P1?
    JR      NZ, LOC_95A0                    ; no: jump to P2-first aim sequence

LOC_9589:
    CALL    DELAY_LOOP_8C82                 ; wait for free frame budget slot
    JR      NZ, LOC_9589                    ; loop until slot available
    CALL    SUB_975F                        ; render P1 cannon sprite at stored position
    LD      A, $0D                          ; dispatcher task $0D
    CALL    SUB_8C67                        ; enqueue aim/control task for P1

LOC_9596:
    CALL    DELAY_LOOP_8C82                 ; wait for free frame budget slot
    JR      NZ, LOC_9596                    ; loop until slot available
    CALL    SUB_9794                        ; render P2 cannon sprite at stored position
    JR      LOC_95B5                        ; enter per-shot turn loop

LOC_95A0:
    CALL    DELAY_LOOP_8C82                 ; wait for free slot (P2 aims first)
    JR      NZ, LOC_95A0
    CALL    SUB_9794                        ; render P2 cannon sprite
    LD      A, $01                          ; dispatcher task $01
    CALL    SUB_8C67                        ; enqueue aim/control task for P2

LOC_95AD:
    CALL    DELAY_LOOP_8C82                 ; wait for free slot
    JR      NZ, LOC_95AD
    CALL    SUB_975F                        ; render P1 cannon sprite

LOC_95B5:
    CALL    VDP_REG_95D6                    ; arm NMI, set VDP reg 7 (background), clear $70E1 timer
    CALL    SUB_A64B                        ; per-frame: render cannon+projectile, check for game over
    JR      C, LOC_95C5                     ; carry set: all rounds done (game over)
    CALL    SUB_9838                        ; swap active player (toggle $7117, swap IX<->IY)
    CALL    SUB_987A                        ; fire projectile: trajectory physics + collision detect
    JR      LOC_95B5                        ; next shot

LOC_95C5:
    CALL    SUB_98F3                        ; increment winning player score (IX+4)
    CALL    SUB_98FB                        ; display DAMAGE REPORT and player scores
    CALL    SUB_B589                        ; play end-of-game sound sequence
    CALL    SUB_9838                        ; reset player pointers
    CALL    VDP_INIT_95FF                   ; clear VDP for new round
    JR      LOC_9557                        ; jump back: start new round

VDP_REG_95D6:
    CALL    SUB_8369                        ; disarm NMI
    LD      A, $07                          ; VDP register 7 (background color)
    OUT     ($BF), A                        ; write register number
    LD      A, $87                          ; register value $87
    OUT     ($BF), A                        ; write register value
    CALL    VDP_REG_8352                    ; re-arm NMI
    LD      A, $01                          ; dispatcher task 1
    CALL    SUB_8C67                        ; enqueue frame task
    LD      A, $08                          ; dispatcher task 8
    CALL    SUB_8C67                        ; enqueue $70E1 clear task
    LD      B, $0A

LOC_95F0:
    PUSH    BC
    CALL    SUB_A9C4
    RST     $08
    LD      B, $CD
    SUB     A
    XOR     C
    RST     $08
    LD      B, $C1
    DJNZ    LOC_95F0
    RET     

VDP_INIT_95FF:
    CALL    VDP_WRITE_9F71
    CALL    SUB_8369
    LD      A, $01
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $87
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    CALL    VDP_REG_8352
    CALL    VDP_REG_9622
    CALL    SUB_8369
    LD      A, $07
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $87
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    CALL    VDP_REG_8352
    RET     

VDP_REG_9622:
    LD      B, $96
    LD      A, $F0
    LD      ($711E), A                  ; RAM $711E
    LD      A, $BF
    CALL    DELAY_LOOP_832E
    LD      E, A
    XOR     A
    CALL    DELAY_LOOP_832E
    LD      D, A
    CALL    SUB_9E7A
    CP      $00
    JR      Z, LOC_9640

LOC_963B:
    RST     $08
    LD      BC, $EA10
    RET     

LOC_9640:
    LD      A, ($7121)                  ; RAM $7121
    CP      $60
    JR      Z, LOC_963B
    CALL    SUB_9EAB
    JR      LOC_963B

VDP_REG_964C:
    CALL    SUB_8369                        ; disarm NMI
    LD      A, $07                          ; VDP register 7
    OUT     ($BF), A                        ; write register number
    LD      A, $87                          ; write register value $87
    OUT     ($BF), A                        ; write register value
    CALL    VDP_REG_8352                    ; re-arm NMI
    LD      A, $01                          ; dispatcher task 1
    CALL    SUB_8C67                        ; enqueue round-start task
    LD      A, $02                          ; active player = P2 initially
    LD      ($7117), A                      ; set active player flag $7117 = 2
    CALL    SUB_9838                        ; swap to P1 (since $7117=2, swap sets $7117=1)
    XOR     A                               ; A = 0
    LD      ($70C7), A                      ; clear P1 score display var $70C7
    LD      ($70CB), A                      ; clear P2 score display var $70CB
    LD      ($70D1), A                      ; clear P1 damage counter $70D1
    LD      ($70D5), A                      ; clear P2 damage counter $70D5
    RET     

SUB_9675:
    CALL    SUB_834C                        ; get random byte (P1 X candidate)
    AND     $F8                             ; snap to 8-pixel boundary
    CP      $08                             ; minimum P1 X = $08
    JR      C, SUB_9675                     ; too small: retry
    CP      $18                             ; maximum valid P1 X = $18
    JR      Z, LOC_9684                     ; exactly $18: accept
    JR      NC, SUB_9675                    ; too large: retry

LOC_9684:
    LD      ($70C4), A                      ; store P1 cannon X at $70C4

LOC_9687:
    CALL    SUB_834C                        ; get random byte (P2 X candidate)
    AND     $F8                             ; snap to 8-pixel boundary
    CP      $D8                             ; minimum P2 X = $D8
    JR      C, LOC_9687                     ; too small: retry
    CP      $E8
    JR      Z, LOC_9696                     ; maximum valid P2 X = $E8
    JR      NC, LOC_9687                    ; exactly $E8: accept
                                            ; too large: retry
LOC_9696:
    LD      ($70CE), A                      ; store P2 cannon X at $70CE
    LD      A, ($70C4)                      ; load P1 X
    LD      D, A                            ; D = P1 X (column for terrain height scan)
    LD      E, $00                          ; E = 0 (start Y for scan)
    CALL    SUB_96B2                        ; find P1 terrain Y by scanning VRAM column
    LD      ($70C3), A                      ; store P1 cannon Y at $70C3
    LD      A, ($70CE)                      ; load P2 X
    LD      D, A                            ; D = P2 X
    LD      E, $00                          ; E = 0
    CALL    SUB_96B2                        ; find P2 terrain Y
    LD      ($70CD), A                      ; store P2 cannon Y at $70CD
    RET     

SUB_96B2:
    CALL    SUB_9E7A
    CP      $0A
    JR      Z, LOC_96C0
    CP      $0C
    JR      Z, LOC_96C0
    INC     E
    JR      SUB_96B2

LOC_96C0:
    CALL    SOUND_WRITE_96CD
    OR      A
    JR      NZ, LOC_96C9
    INC     E
    JR      SUB_96B2

LOC_96C9:
    LD      A, E
    SUB     $0C
    RET     

SOUND_WRITE_96CD:
    PUSH    DE
    PUSH    BC
    LD      B, $0F
    INC     D

LOC_96D2:
    CALL    SUB_9E7A
    CP      $0A
    JR      Z, LOC_96DD
    CP      $0C
    JR      NZ, LOC_96E5

LOC_96DD:
    INC     D
    DJNZ    LOC_96D2
    POP     BC
    POP     DE
    LD      A, $FF
    RET     

LOC_96E5:
    XOR     A
    POP     BC
    POP     DE
    RET     

SUB_96E9:
    CALL    SUB_834C                        ; get random byte
    AND     $03                             ; keep low 2 bits (0-3: four directions)
    LD      E, A                            ; E = random direction index
    LD      D, $00                          ; D = 0
    LD      HL, $96FE                       ; HL = wind table base $96FE
    ADD     HL, DE                          ; HL += DE (index into table)
    ADD     HL, DE                          ; HL += DE again (each entry 2 bytes)
    LD      E, (HL)                         ; E = low byte of wind vector
    INC     HL                              ; advance to high byte
    LD      D, (HL)                         ; D = high byte of wind vector
    LD      ($711C), DE                     ; store wind vector at $711C
    RET     
    DB      $04, $00, $05, $00, $05, $00, $06, $00

SUB_9706:
    LD      (IX+6), $60                     ; P1: sprite color/palette = $60
    LD      (IX+7), $70                     ; P1: sprite tile index = $70
    LD      (IX+5), $6B                     ; P1: sprite Y = $6B (off-screen / below play area)
    LD      (IX+9), $6B                     ; P1: second sprite Y = $6B
    LD      (IY+6), $60                     ; P2: sprite color = $60
    LD      (IY+7), $70                     ; P2: sprite tile = $70
    LD      (IY+5), $6B                     ; P2: sprite Y = $6B
    LD      (IY+9), $6B                     ; P2: second sprite Y = $6B
    RET     

SUB_9727:
    CALL    SUB_9748                        ; read random wind byte (via SUB_9748)
    CP      $20                             ; compare to $20
    JR      Z, LOC_9730                     ; exactly $20: accept
    JR      NC, SUB_9727                    ; too large: retry

LOC_9730:
    LD      ($70C6), A                      ; store wind value for P1 side at $70C6
    LD      ($70D0), A                      ; store wind value for P2 side at $70D0
    LD      A, ($73C8)                      ; load game checksum/mode byte from $73C8
    BIT     5, A                            ; test bit 5 (two-player mode flag)
    JR      Z, LOC_9742                     ; zero: not AI mode, set wind=$FF
    XOR     A
    LD      ($7120), A                      ; A = 0 (AI mode active)
    RET                                     ; set AI mode flag $7120 = 0

LOC_9742:
    LD      A, $FF                          ; wind = $FF (wind display disabled)
    LD      ($7120), A                      ; set AI mode flag $7120 = $FF
    RET     

SUB_9748:
    PUSH    BC
    LD      A, $09
    CALL    DELAY_LOOP_832E
    SLA     A
    SLA     A
    SLA     A
    SLA     A
    LD      B, A
    LD      A, $09
    CALL    DELAY_LOOP_832E
    OR      B
    POP     BC
    RET     

SUB_975F:
    LD      A, $03                          ; dispatcher task 3
    CALL    SUB_8C67                        ; enqueue cannon render task
    LD      A, ($70C3)                      ; load P1 cannon Y ($70C3)
    LD      E, A                            ; E = P1 Y
    LD      A, ($70C4)                      ; load P1 cannon X ($70C4)
    LD      D, A                            ; D = P1 X
    LD      HL, $977C                       ; HL = P1 cannon bitmap table ($977C)
    CALL    DELAY_LOOP_97CA                 ; render cannon bitmap at (D,E) using table HL
    XOR     A                               ; A = 0 (P1 = left-facing cannon)
    CALL    SUB_B0ED                        ; place P1 cannon sprite via SUB_B0ED
    LD      A, $01                          ; dispatcher task 1
    CALL    SUB_8C67                        ; enqueue frame update task
    RET     
    DB      $00, $00, $00, $FE, $01, $FF, $03, $FF
    DB      $07, $FF, $0F, $FF, $0F, $FF, $0F, $FF
    DB      $0F, $FF, $00, $78, $01, $FE, $03, $FF

SUB_9794:
    LD      A, $03                          ; dispatcher task 3
    CALL    SUB_8C67                        ; enqueue cannon render task
    LD      A, ($70CD)                      ; load P2 cannon Y ($70CD)
    LD      E, A                            ; E = P2 Y
    LD      A, ($70CE)                      ; load P2 cannon X ($70CE)
    LD      D, A                            ; D = P2 X
    LD      HL, $97B2                       ; HL = P2 cannon bitmap table ($97B2)
    CALL    DELAY_LOOP_97CA                 ; render cannon bitmap at (D,E) using table HL
    LD      A, $01                          ; A = 1 (P2 = right-facing cannon)
    CALL    SUB_B0ED                        ; place P2 cannon sprite via SUB_B0ED
    LD      A, $01                          ; dispatcher task 1
    CALL    SUB_8C67                        ; enqueue frame update task
    RET     
    DB      $00, $00, $7F, $00, $FF, $80, $FF, $C0
    DB      $FF, $E0, $FF, $F0, $FF, $F0, $FF, $F0
    DB      $FF, $F0, $1E, $00, $7F, $80, $FF, $C0

DELAY_LOOP_97CA:
    LD      A, E
    ADD     A, $0B
    LD      E, A
    LD      B, $01

LOC_97D0:
    PUSH    HL
    PUSH    DE
    PUSH    BC
    LD      A, D

LOC_97D4:
    LD      C, (HL)
    INC     HL
    CALL    DELAY_LOOP_97FB
    LD      C, (HL)
    INC     HL
    CALL    DELAY_LOOP_97FB
    INC     E
    LD      D, A
    DJNZ    LOC_97D4
    CALL    DELAY_LOOP_97F0
    POP     BC
    INC     B
    POP     DE
    DEC     E
    POP     HL
    LD      A, B
    CP      $0D
    RET     Z
    JR      LOC_97D0

DELAY_LOOP_97F0:
    PUSH    BC
    LD      B, $06
    PUSH    BC
    RST     $08
    LD      BC, $10C1
    JP      M, $C9C1

DELAY_LOOP_97FB:
    PUSH    BC
    LD      B, $08

LOC_97FE:
    RLC     C
    PUSH    AF
    CALL    SUB_980A
    POP     AF
    INC     D
    DJNZ    LOC_97FE
    POP     BC
    RET     

SUB_980A:
    JR      NC, LOC_9823
    CALL    SUB_9E7A
    LD      A, ($7121)                  ; RAM $7121
    AND     $0F
    CP      $00
    LD      A, $10
    JR      Z, LOC_981C
    LD      A, $16

LOC_981C:
    LD      ($711E), A                  ; RAM $711E
    CALL    SUB_9EAB
    RET     

LOC_9823:
    CALL    SUB_9E7A
    LD      A, ($7121)                  ; RAM $7121
    CP      $00
    LD      A, $10
    JR      Z, LOC_9831
    LD      A, $16

LOC_9831:
    LD      ($711F), A                  ; RAM $711F
    CALL    SUB_9ECD
    RET     

SUB_9838:
    PUSH    AF                              ; save AF
    LD      A, ($7117)                      ; load active player flag $7117
    CP      $01                             ; is active player P1 (=1)?
    JR      NZ, LOC_985D                    ; not P1: jump to P1-setup path
    LD      A, $02                          ; new active player = P2
    LD      ($7117), A                      ; set active player flag = 2
    LD      IX, $70CD                       ; IX = P2 cannon data base ($70CD)
    LD      IY, $70C3                       ; IY = P1 cannon data base ($70C3)
    LD      ($7118), IX                     ; store P2 as active cannon pointer ($7118)
    LD      ($711A), IY                     ; store P1 as other cannon pointer ($711A)
    LD      A, (IY+3)                       ; load P1 aim angle (IY+3)
    LD      (IX+3), A                       ; copy P1 aim to P2 initial aim (IX+3)
    POP     AF
    RET     

LOC_985D:
    LD      A, $01                          ; new active player = P1
    LD      ($7117), A                      ; set active player flag = 1
    LD      IX, $70C3                       ; IX = P1 cannon data base ($70C3)
    LD      IY, $70CD                       ; IY = P2 cannon data base ($70CD)
    LD      ($7118), IX                 ; RAM $7118
    LD      ($711A), IY                 ; RAM $711A
    LD      A, (IY+3)
    LD      (IX+3), A
    POP     AF
    RET     

SUB_987A:
    LD      A, $01                          ; dispatcher task 1
    CALL    SUB_8C67                        ; enqueue projectile frame task
    LD      A, ($7146)                      ; load projectile active flag $7146
    OR      A                               ; is projectile in flight?
    RET     Z                               ; no projectile: return immediately
    LD      A, $6B                          ; $6B = sprite off-screen Y sentinel
    SUB     (IX+5)                          ; subtract cannon Y from $6B
    RET     Z                               ; cannon at off-screen position: return
    PUSH    AF
    LD      A, $0B                          ; dispatcher task $0B
    CALL    SUB_8C67                        ; enqueue trajectory compute task
    LD      HL, $3C00                       ; score display VRAM row = $3C00
    LD      BC, $0080                       ; 128 bytes to clear
    LD      A, $20                          ; fill with space tile $20
    CALL    VDP_WRITE_84A7                  ; clear score display row
    LD      HL, $2000
    LD      BC, $0400
    LD      A, $10
    CALL    VDP_WRITE_84A7
    LD      HL, ($8A8B)
    LD      DE, $0100
    LD      BC, ($8A8D)
    CALL    VDP_WRITE_8490
    RST     $08
    LD      BC, $4611
    INC     A
    CALL    VDP_WRITE_84E4
    LD      B, H
    LD      B, C
    LD      C, L
    LD      B, C
    LD      B, A
    LD      B, L
    JR      NZ, LOC_9915
    LD      B, L
    LD      D, B
    LD      C, A
    LD      D, D
    LD      D, H
    JR      NZ, LOC_98CA

LOC_98CA:
    POP     AF
    CALL    SUB_99C3
    LD      A, $20
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    LD      A, $25
    NOP     
    NOP     
    NOP     
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    CALL    VDP_REG_8352
    LD      B, $FA
    PUSH    BC
    PUSH    BC
    RST     $08
    LD      BC, $10C1
    JP      M, $21C1
    NOP     
    LD      BC, $4BED
    ADC     A, L
    ADC     A, D
    LD      A, $00
    CALL    VDP_WRITE_84A7
    RET     

SUB_98F3:
    LD      IX, ($7118)                     ; IX = active (winning) player cannon data ptr ($7118)
    INC     (IX+4)                          ; increment winning player score byte (IX+4)
    RET     

SUB_98FB:
    LD      HL, $3C00                       ; score display VRAM row
    LD      BC, $0080                       ; 128 bytes
    LD      A, $20                          ; space tile
    CALL    VDP_WRITE_84A7                  ; clear score row
    LD      HL, ($8A8B)                     ; load HUD tile ROM source pointer ($8A8B)
    LD      DE, $0100                       ; VRAM destination = $0100
    LD      BC, ($8A8D)                     ; load HUD tile byte count ($8A8D)
    CALL    VDP_WRITE_8490                  ; copy HUD tiles to VRAM
    LD      HL, $2000
    LD      BC, $0400
    LD      A, $10
    CALL    VDP_WRITE_84A7
    RST     $08
    LD      BC, $2111
    INC     A
    CALL    VDP_WRITE_84E4
    LD      D, B
    LD      C, H
    LD      B, C
    LD      E, C
    LD      B, L
    LD      D, D
    JR      NZ, LOC_995F
    NOP     
    LD      DE, $3C41
    CALL    VDP_WRITE_84E4
    LD      D, D
    LD      B, C
    LD      C, (HL)
    LD      C, E
    JR      NZ, LOC_9968
    JR      NZ, LOC_993D

LOC_993D:
    LD      A, ($70C5)                  ; RAM $70C5
    CALL    VDP_DATA_998F
    LD      DE, $3C61
    CALL    VDP_WRITE_84E4
    LD      D, E
    LD      B, E
    LD      C, A
    LD      D, D
    LD      B, L
    JR      NZ, LOC_9970
    NOP     
    LD      A, ($70C7)                  ; RAM $70C7
    CALL    SUB_99C3
    LD      DE, $3C31
    CALL    VDP_WRITE_84E4
    LD      D, B
    LD      C, H

LOC_995F:
    LD      B, C
    LD      E, C
    LD      B, L
    LD      D, D
    JR      NZ, LOC_9997
    NOP     
    LD      DE, $3C51
    CALL    VDP_WRITE_84E4
    LD      D, D
    LD      B, C
    LD      C, (HL)
    LD      C, E

LOC_9970:
    JR      NZ, LOC_999F
    JR      NZ, LOC_9974

LOC_9974:
    LD      A, ($70CF)                  ; RAM $70CF
    CALL    VDP_DATA_998F
    LD      DE, $3C71
    CALL    VDP_WRITE_84E4
    LD      D, E
    LD      B, E
    LD      C, A
    LD      D, D
    LD      B, L
    JR      NZ, LOC_99A7
    NOP     
    LD      A, ($70D1)                  ; RAM $70D1
    CALL    SUB_99C3
    RET     

VDP_DATA_998F:
    LD      HL, $99A8
    CP      $01
    JR      Z, LOC_99A0
    LD      HL, $99B1
    CP      $02
    JR      Z, LOC_99A0
    LD      HL, LOC_99BA

LOC_99A0:
    LD      A, (HL)
    INC     HL
    OR      A
    RET     Z
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    JR      LOC_99A0
    LD      B, E
    LD      C, A
    LD      D, D
    LD      D, B
    LD      C, A
    LD      D, D
    LD      B, C
    LD      C, H
    NOP     
    LD      B, E
    LD      B, C
    LD      D, B
    LD      D, H
    LD      B, C
    LD      C, C
    LD      C, (HL)
    JR      NZ, LOC_99BA

LOC_99BA:
    LD      B, A
    LD      B, L
    LD      C, (HL)
    LD      B, L
    LD      D, D
    LD      B, C
    LD      C, H
    JR      NZ, SUB_99C3

SUB_99C3:
    PUSH    DE                              ; save DE
    LD      E, $00                          ; E = 0 (leading-zero suppression flag)
    LD      C, $64                          ; C = 100 (hundreds digit divisor)
    CALL    SUB_99D8                        ; extract hundreds digit
    LD      C, $0A                          ; C = 10 (tens digit divisor)
    CALL    SUB_99D8                        ; extract tens digit
    INC     E                               ; INC E (ensure next digit is written)
    LD      C, $01                          ; C = 1 (ones digit)
    CALL    SUB_99D8                        ; extract ones digit
    POP     DE
    RET     

SUB_99D8:
    LD      B, $00

LOC_99DA:
    SUB     C
    JR      C, LOC_99E0
    INC     B
    JR      LOC_99DA

LOC_99E0:
    ADD     A, C
    PUSH    AF
    LD      A, B
    OR      A
    JR      NZ, LOC_99ED
    LD      A, E
    OR      A
    LD      A, B
    JR      NZ, LOC_99ED
    POP     AF
    RET     

LOC_99ED:
    ADD     A, $30
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    INC     E
    POP     AF
    RET     

VDP_INIT_99F4:
    CALL    SUB_8369                        ; disarm NMI
    LD      A, $82                          ; VDP reg 2 value ($82 = name table at $2000)
    OUT     ($BF), A                        ; write VDP register
    LD      A, $81                          ; VDP register 2 select byte ($81)
    OUT     ($BF), A                        ; select register 2
    CALL    VDP_REG_8352                    ; re-arm NMI
    LD      HL, BOOT_UP                     ; HL = VRAM base $0000
    LD      BC, $1800                       ; BC = $1800 (name table size)
    LD      A, $00                          ; fill value = $00
    CALL    VDP_WRITE_84A7                  ; clear pattern generator table
    LD      HL, $2000                       ; name table base = $2000
    LD      BC, $1800                       ; BC = $1800
    LD      A, $A0                          ; fill with background tile $A0
    CALL    VDP_WRITE_84A7                  ; fill name table with background tile
    CALL    VDP_WRITE_9D95
    CALL    SUB_8369
    LD      A, $E2
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $81
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    CALL    VDP_REG_8352
    LD      A, $0F
    CALL    SUB_8C67
    LD      IX, $9A9F
    LD      B, $03

LOC_9A34:
    PUSH    BC
    CALL    SUB_9BA2
    CALL    SUB_9ADB
    LD      BC, $000E
    ADD     IX, BC
    POP     BC
    DJNZ    LOC_9A34
    LD      B, $4B

LOC_9A45:
    PUSH    BC
    LD      A, $DC
    CALL    DELAY_LOOP_832E
    SUB     $6E
    LD      E, A
    LD      A, $78
    CALL    DELAY_LOOP_832E
    SUB     $5A
    LD      D, A
    LD      A, $07
    CALL    DELAY_LOOP_832E
    LD      B, A

LOC_9A5C:
    LD      C, $00
    INC     B
    LD      A, B
    CP      $08
    JR      C, LOC_9A66
    LD      B, $07

LOC_9A66:
    PUSH    DE
    PUSH    BC
    CALL    SUB_9C4A
    POP     BC
    POP     DE
    JR      Z, LOC_9A8A
    INC     C
    LD      A, D
    ADD     A, $03
    LD      D, A
    LD      A, $03
    CALL    DELAY_LOOP_832E
    DEC     A
    ADD     A, E
    LD      E, A
    RST     $08
    LD      BC, $E610

LOC_9A80:
    POP     BC
    DJNZ    LOC_9A45
    CALL    SOUND_WRITE_B6ED
    CALL    DELAY_LOOP_B7C0
    RET     

LOC_9A8A:
    LD      A, $05
    CALL    DELAY_LOOP_832E
    OR      A
    JR      Z, LOC_9A80
    LD      A, D
    SUB     $05
    LD      D, A
    JP      P, LOC_9A5C
    CP      $A6
    JR      NC, LOC_9A5C
    JR      LOC_9A80
    DB      $4A, $A6, $F6, $0F, $09, $09, $03, $05
    DB      $FB, $0D, $01, $01, $0F, $9B, $1E, $F6
    DB      $32, $0A, $07, $06, $02, $04, $FD, $09
    DB      $01, $00, $1F, $9B, $05, $1E, $23, $05
    DB      $05, $03, $01, $02, $04, $FF, $00, $00
    DB      $50, $9B

SUB_9AC9:
    CALL    SUB_8369                        ; disarm NMI
    CALL    WRITE_VRAM                      ; BIOS WRITE_VRAM call
    JP      VDP_REG_8352                    ; re-arm NMI and return

SUB_9AD2:
    CALL    SUB_8369                        ; disarm NMI
    CALL    READ_VRAM                       ; BIOS READ_VRAM call
    JP      VDP_REG_8352                    ; re-arm NMI and return

SUB_9ADB:
    LD      HL, BOOT_UP
    LD      B, $20

LOC_9AE0:
    PUSH    BC
    PUSH    HL
    XOR     A
    LD      BC, $0118
    CALL    SUB_9D44
    LD      E, (IX+12)
    LD      D, (IX+13)
    LD      HL, $7152                   ; RAM $7152
    LD      IY, $7212                   ; RAM $7212
    LD      BC, $C000
    CALL    SUB_9BA0
    POP     HL
    PUSH    HL
    LD      A, $01
    LD      BC, $0118
    CALL    SUB_9D44
    POP     HL
    LD      DE, $0008
    ADD     HL, DE
    POP     BC
    DJNZ    LOC_9AE0
    RET     
    DB      $7E, $B1, $4F, $77, $20, $04, $FD, $36
    DB      $00, $00, $23, $FD, $23, $10, $F1, $C9
    DB      $FD, $7E, $00, $FE, $A0, $20, $0E, $79
    DB      $B7, $28, $16, $FD, $36, $00, $A6, $23
    DB      $FD, $23, $10, $EC, $C9, $7E, $B1, $4F
    DB      $77, $28, $F4, $FD, $36, $00, $60, $18
    DB      $EE, $7E, $23, $A6, $2B, $BE, $28, $E7
    DB      $4F, $10, $02, $3E, $FF, $77, $04, $18
    DB      $DA, $3E, $5F, $DD, $96, $01, $47, $0C
    DB      $7E, $23, $A6, $2B, $AE, $20, $06, $23
    DB      $FD, $23, $10, $F3, $C9, $41, $FD, $E5
    DB      $FD, $36, $00, $F0, $FD, $2B, $10, $F8
    DB      $FD, $E1, $7E, $3C, $20, $0D, $3D, $77
    DB      $FD, $36, $00, $F6, $C8, $FD, $23, $23
    DB      $A6, $18, $F4, $7E, $23, $B6, $2B, $3C
    DB      $20, $0B, $3D, $06, $0A, $E5, $23, $A6
    DB      $28, $0C, $10, $FA, $E1, $06, $0A, $7E
    DB      $23, $B6, $77, $10, $FB, $C9, $E1, $18
    DB      $D5

SUB_9BA0:
    PUSH    DE
    RET     

SUB_9BA2:
    LD      E, $80
    LD      A, (IX+0)
    CALL    DELAY_LOOP_832E
    ADD     A, (IX+1)
    LD      D, A
    LD      A, (IX+5)
    CALL    DELAY_LOOP_832E
    LD      C, A

LOC_9BB5:
    LD      A, (IX+3)
    CALL    DELAY_LOOP_832E
    INC     A
    ADD     A, E
    JP      PO, LOC_9BC2
    LD      A, $7F

LOC_9BC2:
    LD      L, A
    LD      A, (IX+4)
    CALL    DELAY_LOOP_832E
    SUB     C
    ADD     A, D
    JP      P, LOC_9C32
    BIT     7, (IX+2)
    JR      Z, LOC_9BD9
    CP      (IX+2)
    JR      NC, LOC_9C3D

LOC_9BD9:
    BIT     7, (IX+1)
    JR      Z, LOC_9BE4

LOC_9BDF:
    CP      (IX+1)
    JR      NC, LOC_9BEA

LOC_9BE4:
    LD      A, (IX+1)
    LD      C, (IX+6)

LOC_9BEA:
    LD      H, A
    LD      A, (IX+10)
    CALL    SUB_9DD1
    LD      A, (IX+11)
    OR      A
    JR      Z, LOC_9C03
    PUSH    HL
    LD      HL, $1000

LOC_9BFB:
    DEC     HL
    PUSH    BC
    POP     BC
    LD      A, H
    OR      L
    JR      NZ, LOC_9BFB
    POP     HL

LOC_9C03:
    BIT     7, C
    JR      NZ, LOC_9C18
    LD      A, C
    CP      (IX+7)
    JR      C, LOC_9C18
    ADD     A, $02
    CP      (IX+9)
    JR      C, LOC_9C17
    LD      A, (IX+9)

LOC_9C17:
    LD      C, A

LOC_9C18:
    LD      A, $03
    CALL    DELAY_LOOP_832E
    LD      L, A
    LD      A, C
    SUB     L
    LD      C, A
    JP      P, LOC_9C2B
    LD      A, (IX+8)
    CP      C
    JR      C, LOC_9C2B
    LD      C, A

LOC_9C2B:
    LD      A, E
    CP      $7F
    JP      NZ, LOC_9BB5
    RET     

LOC_9C32:
    BIT     7, (IX+2)
    JR      NZ, LOC_9C3D
    CP      (IX+2)
    JR      C, LOC_9C42

LOC_9C3D:
    LD      C, (IX+7)
    JR      LOC_9BEA

LOC_9C42:
    BIT     7, (IX+1)
    JR      Z, LOC_9BDF
    JR      LOC_9BEA

SUB_9C4A:
    PUSH    BC
    LD      A, D
    ADD     A, $08
    LD      D, A
    LD      A, E
    SUB     $03
    LD      E, A
    CALL    SUB_9DAC
    DB      $EB
    LD      A, L
    AND     $07
    LD      C, A
    LD      A, L
    AND     $F8
    LD      L, A
    PUSH    HL
    PUSH    BC
    LD      BC, $0202
    XOR     A
    CALL    SUB_9D44
    POP     BC
    LD      A, B
    LD      IX, $7152                   ; RAM $7152
    LD      IY, $7212                   ; RAM $7212
    LD      B, $00
    ADD     IX, BC
    ADD     IY, BC
    LD      B, A
    LD      A, (IY+9)
    AND     $0F
    CP      $0A
    JR      Z, LOC_9C93
    LD      A, (IY+9)
    AND     $F0
    CP      $A0
    CALL    NZ, SUB_9CEB
    LD      A, (IX+9)
    INC     A
    CALL    NZ, SUB_9CEB

LOC_9C93:
    LD      A, (IY+25)
    AND     $0F
    CP      $0A
    JR      Z, LOC_9CAD
    LD      A, (IY+25)
    AND     $F0
    CP      $A0
    CALL    NZ, SUB_9CEB
    LD      A, (IX+25)
    INC     A
    CALL    NZ, SUB_9CEB

LOC_9CAD:
    LD      A, B
    LD      DE, $9D3B
    OR      A
    XOR     $07
    INC     A
    LD      C, A
    LD      B, $09

LOC_9CB8:
    PUSH    BC
    LD      B, C
    LD      A, (DE)
    LD      L, A
    LD      H, $00

LOC_9CBE:
    ADD     HL, HL
    DJNZ    LOC_9CBE
    CALL    SUB_9CFB
    PUSH    IX
    PUSH    IY
    LD      BC, $0010
    ADD     IX, BC
    ADD     IY, BC
    LD      H, L
    CALL    SUB_9CFB
    POP     IY
    POP     IX
    POP     BC
    INC     DE
    INC     IX
    INC     IY
    DJNZ    LOC_9CB8
    POP     HL
    LD      BC, $0202
    LD      A, $01
    CALL    SUB_9D44
    POP     BC
    INC     C
    RET     

SUB_9CEB:
    POP     DE
    POP     HL
    LD      A, B
    POP     BC
    PUSH    BC
    LD      B, A
    LD      A, C
    OR      A
    JR      Z, LOC_9CF8
    PUSH    HL
    PUSH    DE
    RET     

LOC_9CF8:
    POP     BC
    XOR     A
    RET     

SUB_9CFB:
    LD      A, H
    OR      A
    RET     Z
    LD      A, (IY+0)
    AND     $F0
    CP      $C0
    JR      NZ, LOC_9D0F
    LD      A, (IX+0)
    OR      H
    LD      (IX+0), A
    RET     

LOC_9D0F:
    LD      A, (IX+0)
    CALL    SUB_9D2B
    CP      $04
    LD      A, (IY+0)
    JR      C, LOC_9D20
    RLCA    
    RLCA    
    RLCA    
    RLCA    

LOC_9D20:
    AND     $0F
    OR      $C0
    LD      (IY+0), A
    LD      (IX+0), H
    RET     

SUB_9D2B:
    PUSH    BC
    LD      C, $00

LOC_9D2E:
    OR      A
    JR      Z, LOC_9D38
    SLA     A
    JR      NC, LOC_9D2E
    INC     C
    JR      LOC_9D2E

LOC_9D38:
    LD      A, C
    POP     BC
    RET     
    DB      $10, $10, $92, $54, $38, $91, $52, $34
    DB      $18

SUB_9D44:
    LD      DE, $7152                   ; RAM $7152
    DB      $EB

LOC_9D48:
    PUSH    BC
    PUSH    DE
    LD      B, C

LOC_9D4B:
    PUSH    BC
    PUSH    AF
    PUSH    HL
    PUSH    DE
    LD      BC, $0008
    OR      A
    JR      NZ, LOC_9D8B
    CALL    SUB_9AD2

LOC_9D58:
    POP     DE
    POP     HL
    POP     BC
    PUSH    BC
    PUSH    HL
    PUSH    DE
    LD      A, D
    XOR     $20
    LD      D, A
    LD      A, B
    LD      BC, $7152                   ; RAM $7152
    SBC     HL, BC
    LD      BC, $7212                   ; RAM $7212
    ADD     HL, BC
    OR      A
    LD      BC, $0008
    JR      NZ, LOC_9D90
    CALL    SUB_9AD2

LOC_9D75:
    POP     DE
    INC     D
    POP     HL
    LD      BC, $0008
    ADD     HL, BC
    POP     AF
    POP     BC
    DJNZ    LOC_9D4B
    POP     DE
    DB      $EB
    LD      BC, $0008
    ADD     HL, BC
    DB      $EB
    POP     BC
    DJNZ    LOC_9D48
    RET     

LOC_9D8B:
    CALL    SUB_9AC9
    JR      LOC_9D58

LOC_9D90:
    CALL    SUB_9AC9
    JR      LOC_9D75

VDP_WRITE_9D95:
    LD      B, $03
    LD      HL, $3C00
    LD      A, L
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, H
    ADD     A, $40
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    XOR     A

LOC_9DA3:
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    INC     A
    OR      A
    JR      NZ, LOC_9DA3
    DJNZ    LOC_9DA3
    RET     

SUB_9DAC:
    PUSH    AF
    LD      HL, BOOT_UP
    LD      A, E
    XOR     $80
    LD      E, A
    AND     $07
    LD      B, A
    XOR     E
    LD      E, A
    LD      A, $5F
    SUB     D
    LD      D, A
    AND     $07
    OR      E
    LD      E, A
    LD      A, D
    RRA     
    RRA     
    RRA     
    AND     $1F
    LD      D, A
    ADD     HL, DE
    DB      $EB
    LD      HL, $7152                   ; RAM $7152
    LD      C, $01
    POP     AF
    RET     

SUB_9DD1:
    PUSH    BC
    PUSH    AF
    PUSH    DE
    LD      B, L
    LD      C, E
    CALL    SUB_9E51
    LD      L, B
    LD      E, C
    LD      B, H
    LD      C, D
    CALL    SUB_9E51
    LD      H, B
    LD      D, C
    LD      ($7150), HL                 ; RAM $7150
    LD      C, $00
    LD      A, D
    CP      E
    JR      C, LOC_9DEE
    LD      D, E
    LD      E, A
    INC     C

LOC_9DEE:
    LD      A, D
    SRL     A
    LD      B, A
    DB      $EB
    LD      ($714E), HL                 ; RAM $714E
    POP     DE
    INC     L
    DB      $E3
    PUSH    HL

LOC_9DFA:
    POP     AF
    CALL    DELAY_LOOP_9E24
    POP     HL
    DEC     L
    JR      Z, LOC_9E22
    PUSH    HL
    PUSH    AF
    LD      HL, ($714E)                 ; RAM $714E
    LD      A, B
    ADD     A, H
    LD      B, A
    SUB     L
    LD      HL, ($7150)                 ; RAM $7150
    JR      C, LOC_9E19
    LD      B, A
    LD      A, E
    ADD     A, L
    LD      E, A

LOC_9E14:
    LD      A, D
    ADD     A, H
    LD      D, A
    JR      LOC_9DFA

LOC_9E19:
    LD      A, C
    OR      A
    JR      NZ, LOC_9E14
    LD      A, E
    ADD     A, L
    LD      E, A
    JR      LOC_9DFA

LOC_9E22:
    POP     BC
    RET     

DELAY_LOOP_9E24:
    PUSH    AF
    PUSH    BC
    PUSH    DE
    PUSH    HL
    CALL    SUB_9DAC
    PUSH    HL
    PUSH    DE
    PUSH    BC
    PUSH    AF
    LD      B, $00
    CALL    SUB_9AD2
    POP     HL
    LD      L, $FE
    POP     BC
    INC     B

LOC_9E39:
    RRC     H
    RRC     L
    DJNZ    LOC_9E39
    LD      A, ($7152)                  ; RAM $7152
    AND     L
    OR      H
    LD      ($7152), A                  ; RAM $7152
    POP     DE
    POP     HL
    CALL    SUB_9AC9
    POP     HL
    POP     DE
    POP     BC
    POP     AF
    RET     

SUB_9E51:
    PUSH    HL
    PUSH    DE
    LD      L, C
    CALL    SUB_9E73
    DB      $EB
    LD      L, B
    CALL    SUB_9E73
    XOR     A
    SBC     HL, DE
    OR      H
    JR      Z, LOC_9E6A
    LD      B, A
    LD      A, L
    NEG     
    LD      C, A

LOC_9E67:
    POP     DE
    POP     HL
    RET     

LOC_9E6A:
    OR      L
    LD      C, L
    LD      B, A
    JR      Z, LOC_9E67
    LD      B, $01
    JR      LOC_9E67

SUB_9E73:
    LD      H, $00
    LD      A, L
    OR      A
    RET     P
    DEC     H
    RET     

SUB_9E7A:
    PUSH    HL
    PUSH    BC
    CALL    SUB_9EEF
    LD      HL, $2000
    ADD     HL, BC
    CALL    VDP_WRITE_9F14
    LD      ($7121), A                  ; RAM $7121
    LD      HL, BOOT_UP
    ADD     HL, BC
    CALL    VDP_WRITE_9F14
    LD      C, $01
    CALL    DELAY_LOOP_9F39
    AND     C
    LD      A, ($7121)                  ; RAM $7121
    JR      NZ, LOC_9EA0
    AND     $0F
    POP     BC
    POP     HL
    RET     

LOC_9EA0:
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    POP     BC
    POP     HL
    RET     

SUB_9EAB:
    PUSH    BC
    PUSH    HL
    CALL    SUB_9EEF
    LD      HL, $2000
    ADD     HL, BC
    LD      A, ($711E)                  ; RAM $711E
    CALL    VDP_WRITE_9F25
    LD      HL, BOOT_UP
    ADD     HL, BC
    CALL    VDP_WRITE_9F14
    LD      C, $01
    CALL    DELAY_LOOP_9F39
    OR      C
    CALL    VDP_WRITE_9F25
    POP     HL
    POP     BC
    RET     

SUB_9ECD:
    PUSH    BC
    PUSH    HL
    CALL    SUB_9EEF
    LD      HL, $2000
    ADD     HL, BC
    LD      A, ($711F)                  ; RAM $711F
    CALL    VDP_WRITE_9F25
    LD      HL, BOOT_UP
    ADD     HL, BC
    CALL    VDP_WRITE_9F14
    LD      C, $FE
    CALL    DELAY_LOOP_9F39
    AND     C
    CALL    VDP_WRITE_9F25
    POP     HL
    POP     BC
    RET     

SUB_9EEF:
    LD      A, E
    SRL     A
    SRL     A
    SRL     A
    LD      L, A
    LD      H, $00
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    LD      A, D
    SRL     A
    SRL     A
    SRL     A
    LD      C, A
    LD      B, $00
    ADD     HL, BC
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    LD      A, E
    AND     $07
    LD      C, A
    ADD     HL, BC
    LD      B, H
    LD      C, L
    RET     

VDP_WRITE_9F14:
    CALL    SUB_8369
    LD      A, L
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, H
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    PUSH    BC
    POP     BC
    NOP     
    IN      A, ($BE)                    ; DATA_PORT - read VRAM
    JP      VDP_REG_8352

VDP_WRITE_9F25:
    CALL    SUB_8369
    PUSH    AF
    LD      A, L
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, H
    ADD     A, $40
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    POP     AF
    NOP     
    NOP     
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    JP      VDP_REG_8352

DELAY_LOOP_9F39:
    PUSH    AF
    LD      A, D
    AND     $07
    LD      B, A
    LD      A, $07
    SUB     B
    JR      Z, LOC_9F48
    LD      B, A

LOC_9F44:
    RLC     C
    DJNZ    LOC_9F44

LOC_9F48:
    POP     AF
    RET     

SUB_9F4A:
    LD      HL, ($A0A5)
    LD      DE, $2000
    LD      BC, ($A0A9)
    CALL    VDP_WRITE_8490
    LD      HL, ($A0A3)
    LD      DE, BOOT_UP
    LD      BC, ($A0A7)
    CALL    VDP_WRITE_8490
    LD      HL, $9FA3
    LD      DE, $3C00
    LD      BC, $0100
    CALL    VDP_WRITE_8490
    RET     

VDP_WRITE_9F71:
    LD      HL, $2000
    LD      BC, $0400
    LD      A, $A0
    CALL    VDP_WRITE_84A7
    LD      HL, BOOT_UP
    LD      BC, $0400
    LD      A, $00
    CALL    VDP_WRITE_84A7
    LD      HL, $3C00
    LD      B, $00
    LD      A, L
    CALL    SUB_8369
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, H
    ADD     A, $40
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    XOR     A

LOC_9F98:
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    INC     A
    NOP     
    NOP     
    DJNZ    LOC_9F98
    CALL    VDP_REG_8352
    RET     
    DB      $01, $02, $02, $02, $02, $02, $02, $02
    DB      $02, $02, $02, $02, $02, $02, $02, $02
    DB      $02, $02, $02, $02, $02, $03, $04, $04
    DB      $04, $04, $05, $02, $02, $02, $02, $06
    DB      $07, $00, $00, $00, $08, $09, $0A, $00
    DB      $00, $00, $00, $00, $08, $09, $0A, $00
    DB      $08, $09, $09, $0A, $00, $0B, $0C, $0D
    DB      $0E, $0F, $07, $1C, $1D, $1D, $1E, $0B
    DB      $07, $1F, $20, $20, $21, $22, $24, $00
    DB      $00, $1F, $20, $20, $21, $22, $24, $00
    DB      $25, $22, $22, $26, $00, $0B, $10, $11
    DB      $12, $13, $07, $27, $28, $29, $30, $0B
    DB      $07, $31, $32, $33, $34, $35, $36, $00
    DB      $00, $31, $37, $38, $34, $35, $36, $00
    DB      $25, $22, $22, $26, $00, $0B, $14, $15
    DB      $16, $17, $07, $57, $2A, $2B, $30, $0B
    DB      $07, $39, $3A, $3A, $3B, $22, $24, $00
    DB      $00, $39, $3A, $3A, $3B, $22, $24, $00
    DB      $3C, $3D, $3D, $3E, $00, $0B, $18, $19
    DB      $1A, $1B, $07, $58, $3F, $40, $30, $0B
    DB      $07, $00, $00, $00, $3C, $3D, $3E, $00
    DB      $00, $00, $00, $00, $3C, $3D, $3E, $00
    DB      $41, $42, $43, $44, $00, $45, $47, $46
    DB      $46, $46, $48, $49, $4A, $4A, $4B, $0B
    DB      $07, $4C, $4D, $43, $43, $44, $4E, $00
    DB      $00, $4F, $50, $51, $52, $44, $43, $00
    DB      $00, $59, $5A, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $51, $42, $53, $52, $0B
    DB      $54, $55, $55, $55, $55, $55, $55, $55 ; "TUUUUUUU"
    DB      $55, $55, $55, $55, $55, $55, $55, $55 ; "UUUUUUUU"
    DB      $55, $55, $55, $55, $55, $55, $55, $55 ; "UUUUUUUU"
    DB      $55, $55, $55, $55, $55, $55, $55, $56 ; "UUUUUUUV"
    DB      $83, $A3, $AB, $A0, $C8, $02, $DE, $02
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $91, $91, $91, $91, $91, $91, $91, $91
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $41, $F1
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $41, $F1
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $41, $F1
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $41, $F1
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $91, $91, $41
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1
    DB      $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $41, $41, $41, $41, $41, $41, $41, $41 ; "AAAAAAAA"
    DB      $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1
    DB      $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $FF, $FF, $C0, $CC, $D2, $CC, $C0, $C0
    DB      $FF, $FF, $00, $00, $00, $00, $00, $00
    DB      $FF, $FF, $00, $00, $00, $00, $03, $03
    DB      $FF, $FF, $00, $00, $00, $00, $FF, $FF
    DB      $FF, $FF, $00, $00, $00, $00, $C0, $C0
    DB      $FF, $FF, $03, $33, $2B, $33, $03, $03
    DB      $C0, $C0, $C0, $C0, $C0, $C0, $C0, $C0
    DB      $00, $00, $00, $00, $00, $07, $07, $06
    DB      $00, $00, $00, $00, $00, $FF, $FF, $00
    DB      $00, $00, $00, $00, $00, $E0, $E0, $60
    DB      $03, $03, $03, $03, $03, $03, $03, $03
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
    DB      $00, $00, $00, $00, $00, $00, $00, $03
    DB      $00, $00, $00, $00, $00, $00, $00, $FF
    DB      $00, $00, $00, $00, $00, $00, $00, $80
    DB      $00, $00, $00, $00, $00, $0F, $0F, $0C
    DB      $00, $00, $00, $00, $00, $FF, $FF, $00
    DB      $06, $06, $06, $06, $06, $E6, $E6, $66
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $60, $60, $60, $60, $60, $60, $60, $60 ; "````````"
    DB      $06, $06, $06, $06, $06, $06, $06, $06
    DB      $60, $60, $60, $60, $60, $60, $60, $60 ; "````````"
    DB      $02, $02, $02, $02, $02, $02, $02, $02
    DB      $00, $01, $01, $01, $01, $01, $01, $01
    DB      $00, $00, $C0, $F0, $FC, $FC, $3C, $0C
    DB      $01, $01, $01, $01, $01, $00, $FF, $00
    DB      $00, $00, $00, $00, $00, $00, $FF, $00
    DB      $00, $00, $03, $0F, $3F, $3F, $3C, $30
    DB      $00, $80, $80, $80, $80, $80, $80, $80
    DB      $00, $00, $00, $00, $00, $00, $FF, $00
    DB      $80, $80, $80, $80, $80, $00, $FF, $00
    DB      $80, $80, $80, $80, $80, $80, $80, $80
    DB      $0C, $0C, $0E, $0E, $0E, $0C, $0C, $0C
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $66, $67, $E7, $E0, $E0, $67, $67, $66
    DB      $00, $FF, $FF, $00, $00, $FF, $FF, $00
    DB      $60, $E0, $E0, $00, $00, $E0, $E0, $60
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $0F, $0F, $00, $00, $00, $00, $00, $00
    DB      $FF, $FF, $00, $00, $00, $00, $00, $00
    DB      $E6, $E6, $06, $06, $06, $06, $06, $06
    DB      $06, $07, $07, $00, $00, $00, $00, $00
    DB      $00, $FF, $FF, $00, $00, $00, $00, $00
    DB      $60, $E0, $E0, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $FE, $FE, $C0, $F8, $F8, $C0, $C0, $00
    DB      $3C, $18, $18, $18, $18, $18, $3C, $00
    DB      $FC, $FE, $C6, $FE, $FC, $CC, $C6, $00
    DB      $FE, $FE, $C0, $F8, $C0, $FE, $FE, $00
    DB      $03, $03, $00, $00, $00, $00, $00, $00
    DB      $FF, $FF, $00, $00, $00, $7E, $7E, $00
    DB      $FF, $FF, $00, $00, $00, $7E, $7E, $00
    DB      $C0, $C0, $00, $00, $00, $00, $00, $00
    DB      $03, $00, $00, $00, $00, $00, $00, $00
    DB      $FF, $00, $00, $00, $00, $00, $00, $00
    DB      $80, $00, $00, $00, $00, $00, $00, $00
    DB      $FC, $FE, $C6, $FC, $C6, $FE, $FC, $00
    DB      $38, $6C, $C6, $FE, $C6, $C6, $C6, $00
    DB      $C0, $C0, $C0, $C0, $C0, $FE, $FE, $00
    DB      $FC, $FE, $C6, $FE, $FC, $C0, $C0, $00
    DB      $FE, $FE, $C6, $C6, $C6, $FE, $FE, $00
    DB      $C6, $C6, $C6, $D6, $FE, $EE, $C6, $00
    DB      $FC, $FE, $C6, $C6, $C6, $FE, $FC, $00
    DB      $C6, $C6, $F6, $DE, $CE, $C6, $C6, $00
    DB      $C0, $C0, $CC, $D2, $CC, $C0, $FF, $FF
    DB      $00, $00, $00, $00, $00, $00, $FF, $FF
    DB      $03, $03, $33, $4B, $33, $03, $FF, $FF
    DB      $02, $02, $02, $02, $02, $02, $03, $02
    DB      $02, $02, $02, $02, $02, $02, $02, $02

SUB_A64B:
    LD      A, $01                          ; dispatcher task 1 (frame update)
    CALL    SUB_8C67                        ; service dispatcher queue
    CALL    SUB_9F4A                        ; sync to VSYNC (SUB_9F4A frame wait)
    CALL    SUB_ABC0                        ; init projectile tracking data (SUB_ABC0)
    LD      BC, BOOT_UP                     ; BC = $0000
    LD      ($7115), BC                     ; reset digit-walk pointer at $7115
    CALL    SUB_AA25                        ; display P1 cannon sprite at stored position
    CALL    SUB_AA31                        ; display P2 cannon sprite at stored position
    CALL    SUB_AABE                        ; update wind arrow display
    LD      A, $02                          ; round limit flag = 2
    LD      ($715A), A                      ; set round tracking variable at $715A
    CALL    SUB_A939                        ; per-frame cannon animation (SUB_A939)
    CALL    SUB_A8BB                        ; per-frame projectile position update (SUB_A8BB)
    LD      HL, $3F00                       ; sprite attribute VRAM base
    LD      BC, $0040                       ; $40 bytes (16 sprites x 4 bytes)
    LD      A, $C0                          ; sprite off-screen value $C0
    CALL    VDP_WRITE_84A7                  ; clear sprite attribute area 0-15
    LD      HL, $3F50
    LD      BC, $000C
    LD      A, $C0
    CALL    VDP_WRITE_84A7
    LD      HL, $3F60
    LD      BC, $0010
    LD      A, $C0
    CALL    VDP_WRITE_84A7

LOC_A692:
    RST     $08
    LD      BC, $CDAF
    LDIR    
    LD      A, $01
    CALL    SUB_B0ED
    CALL    SUB_A8DC
    CALL    C, SUB_A75B
    CALL    SUB_ABDA
    CALL    SUB_A915
    LD      A, ($70AF)                  ; RAM $70AF
    OR      A
    CALL    Z, SUB_A730
    CALL    SUB_A9FE
    OR      A
    JR      Z, LOC_A692
    LD      C, A
    LD      A, ($70AF)                  ; RAM $70AF
    OR      A
    JP      Z, LOC_A74C
    LD      A, C
    BIT     3, A
    JR      NZ, LOC_A6D7
    BIT     1, A
    JR      NZ, LOC_A6DC
    BIT     0, A
    JR      NZ, LOC_A6E1
    BIT     2, A
    JR      NZ, LOC_A6E6
    LD      HL, $A712
    CALL    SUB_A705
    JR      LOC_A692

LOC_A6D7:
    LD      HL, $A71C
    JR      LOC_A6E9

LOC_A6DC:
    LD      HL, $A721
    JR      LOC_A6E9

LOC_A6E1:
    LD      HL, $A726
    JR      LOC_A6E9

LOC_A6E6:
    LD      HL, $A72B

LOC_A6E9:
    LD      A, ($715A)                  ; RAM $715A
    LD      E, A
    LD      D, $00
    ADD     HL, DE
    LD      E, (HL)
    CP      E
    JP      Z, LOC_A692
    LD      A, E
    CALL    SUB_A968
    LD      ($715A), A                  ; RAM $715A
    CALL    SUB_A939
    CALL    SUB_A9E7
    JP      LOC_A692

SUB_A705:
    LD      A, ($715A)                  ; RAM $715A
    LD      E, A
    LD      D, $00
    ADD     HL, DE
    ADD     HL, DE
    LD      A, (HL)
    INC     HL
    LD      H, (HL)
    LD      L, A
    JP      (HL)
    DB      $78, $A7, $CA, $A7, $26, $A8, $65, $A8
    DB      $5B, $A7, $00, $00, $00, $01, $02, $02
    DB      $03, $04, $04, $04, $00, $00, $02, $02
    DB      $04, $01, $01, $03, $03, $04

SUB_A730:
    LD      HL, ($70B0)                 ; RAM $70B0
    DEC     HL
    LD      A, H
    OR      L
    JR      Z, LOC_A73C
    LD      ($70B0), HL                 ; RAM $70B0
    RET     

LOC_A73C:
    POP     HL
    POP     HL
    LD      HL, $3F00
    LD      BC, $0080
    LD      A, $C0
    CALL    VDP_WRITE_84A7
    JP      LOC_8085

LOC_A74C:
    POP     HL
    LD      HL, $3F00
    LD      BC, $0080
    LD      A, $C0
    CALL    VDP_WRITE_84A7
    JP      LOC_80A9

SUB_A75B:
    POP     HL
    CALL    SUB_A9C4
    LD      HL, $3F70
    LD      BC, $0004
    LD      A, $C0
    CALL    VDP_WRITE_84A7
    CALL    SUB_A968
    CALL    VDP_WRITE_9F71
    LD      A, $01
    CALL    SUB_8C67
    JP      LOC_AE09
    DB      $DD, $7E, $06, $FE, $90, $C8, $D0, $01
    DB      $00, $00, $ED, $43, $15, $71, $DD, $7E
    DB      $06, $CD, $25, $AA, $3A, $15, $71, $FE
    DB      $07, $28, $0C, $3C, $32, $15, $71, $CF
    DB      $03, $CD, $A9, $A8, $C3, $86, $A7, $01
    DB      $00, $00, $ED, $43, $15, $71, $DD, $7E
    DB      $06, $C6, $01, $27, $DD, $77, $06, $CD
    DB      $25, $AA, $3E, $05, $CD, $67, $8C, $DD
    DB      $7E, $06, $E6, $0F, $CA, $1E, $A8, $FE
    DB      $05, $CA, $1E, $A8, $CD, $25, $AA, $C3
    DB      $86, $A7, $DD, $7E, $06, $FE, $00, $C8
    DB      $D8, $01, $00, $00, $ED, $43, $15, $71
    DB      $DD, $7E, $06, $CD, $25, $AA, $ED, $4B
    DB      $15, $71, $79, $ED, $44, $FE, $07, $28
    DB      $0D, $0B, $ED, $43, $15, $71, $CF, $03
    DB      $CD, $A9, $A8, $C3, $D8, $A7, $01, $00
    DB      $00, $ED, $43, $15, $71, $DD, $7E, $06
    DB      $D6, $01, $27, $DD, $77, $06, $CD, $25
    DB      $AA, $3E, $06, $CD, $67, $8C, $DD, $7E
    DB      $06, $E6, $0F, $CA, $1E, $A8, $FE, $05
    DB      $CA, $1E, $A8, $C3, $D8, $A7, $3A, $17
    DB      $71, $EE, $01, $C3, $ED, $B0, $DD, $7E
    DB      $07, $FE, $99, $C8, $D0, $01, $00, $00
    DB      $ED, $43, $15, $71, $DD, $7E, $07, $CD
    DB      $31, $AA, $3A, $15, $71, $FE, $07, $28
    DB      $0B, $3C, $32, $15, $71, $CF, $03, $CD
    DB      $A9, $A8, $18, $E8, $01, $00, $00, $ED
    DB      $43, $15, $71, $DD, $7E, $07, $C6, $01
    DB      $27, $DD, $77, $07, $CD, $31, $AA, $3E
    DB      $05, $CD, $67, $8C, $C9, $DD, $7E, $07
    DB      $FE, $00, $C8, $D8, $01, $00, $00, $ED
    DB      $43, $15, $71, $DD, $7E, $07, $CD, $31
    DB      $AA, $ED, $4B, $15, $71, $79, $ED, $44
    DB      $FE, $07, $28, $0C, $0B, $ED, $43, $15
    DB      $71, $CF, $03, $CD, $A9, $A8, $18, $E3
    DB      $01, $00, $00, $ED, $43, $15, $71, $DD
    DB      $7E, $07, $D6, $01, $27, $DD, $77, $07
    DB      $CD, $31, $AA, $3E, $06, $CD, $67, $8C
    DB      $C9, $C5, $06, $03, $C5, $CD, $DC, $A8
    DB      $CD, $15, $A9, $CD, $DA, $AB, $C1, $10
    DB      $F3, $C1, $C9

SUB_A8BB:
    LD      A, (IX+2)
    CP      $03
    JR      Z, LOC_A8CE
    CP      $02
    JR      Z, LOC_A8CA
    LD      A, $59
    JR      LOC_A8D0

LOC_A8CA:
    LD      A, $30
    JR      LOC_A8D0

LOC_A8CE:
    LD      A, $15

LOC_A8D0:
    LD      ($715F), A                  ; RAM $715F
    LD      A, $3C
    LD      ($7163), A                  ; RAM $7163
    CALL    SUB_AA0D
    RET     

SUB_A8DC:
    LD      A, ($715F)                  ; RAM $715F
    OR      A
    JR      Z, LOC_A913
    LD      A, ($7163)                  ; RAM $7163
    DEC     A
    JR      Z, LOC_A8ED
    LD      ($7163), A                  ; RAM $7163
    OR      A
    RET     

LOC_A8ED:
    LD      A, $3C
    LD      ($7163), A                  ; RAM $7163
    LD      A, ($715F)                  ; RAM $715F
    ADD     A, $99
    DAA     
    LD      ($715F), A                  ; RAM $715F
    PUSH    BC
    LD      BC, ($7115)                 ; RAM $7115
    PUSH    BC
    LD      BC, BOOT_UP
    LD      ($7115), BC                 ; RAM $7115
    CALL    SUB_AA0D
    POP     BC
    LD      ($7115), BC                 ; RAM $7115
    POP     BC
    OR      A
    RET     

LOC_A913:
    SCF     
    RET     

SUB_A915:
    PUSH    AF
    LD      A, ($7114)                  ; RAM $7114
    DEC     A
    LD      ($7114), A                  ; RAM $7114
    JR      NZ, LOC_A922
    CALL    SUB_A924

LOC_A922:
    POP     AF
    RET     

SUB_A924:
    PUSH    HL
    CALL    SUB_A9D0
    CALL    VDP_WRITE_9F14
    CP      $22
    JR      NZ, LOC_A934
    CALL    SUB_A939
    POP     HL
    RET     

LOC_A934:
    CALL    SUB_A968
    POP     HL
    RET     

SUB_A939:
    PUSH    AF
    LD      A, ($715A)                  ; RAM $715A
    CP      $04
    JR      Z, LOC_A94B
    CALL    SUB_A9D0
    LD      A, $23
    CALL    VDP_WRITE_9F25
    JR      LOC_A961

LOC_A94B:
    LD      HL, $3C51
    LD      BC, $0002
    LD      A, $23
    CALL    VDP_WRITE_84A7
    LD      HL, $3C71
    LD      BC, $0002
    LD      A, $23
    CALL    VDP_WRITE_84A7

LOC_A961:
    LD      A, $14
    LD      ($7114), A                  ; RAM $7114
    POP     AF
    RET     

SUB_A968:
    PUSH    AF
    LD      A, ($715A)                  ; RAM $715A
    CP      $04
    JR      Z, LOC_A97A
    CALL    SUB_A9D0
    LD      A, $22
    CALL    VDP_WRITE_9F25
    JR      LOC_A990

LOC_A97A:
    LD      HL, $3C51
    LD      BC, $0002
    LD      A, $22
    CALL    VDP_WRITE_84A7
    LD      HL, $3C71
    LD      BC, $0002
    LD      A, $22
    CALL    VDP_WRITE_84A7

LOC_A990:
    LD      A, $14
    LD      ($7114), A                  ; RAM $7114
    POP     AF
    RET     
    DB      $DD, $E5, $DD, $2A, $18, $71, $DD, $7E
    DB      $00, $D6, $04, $32, $26, $71, $DD, $7E
    DB      $01, $32, $27, $71, $3E, $A0, $32, $28
    DB      $71, $3E, $0B, $32, $29, $71, $DD, $E1
    DB      $21, $26, $71, $11, $5C, $3F, $01, $04
    DB      $00, $CD, $90, $84, $C9

SUB_A9C4:
    LD      HL, $3F5C
    LD      BC, $0004
    LD      A, $C0
    CALL    VDP_WRITE_84A7
    RET     

SUB_A9D0:
    PUSH    DE
    LD      A, ($715A)                  ; RAM $715A
    LD      E, A
    LD      D, $00
    LD      HL, $A9E2
    ADD     HL, DE
    LD      E, (HL)
    LD      HL, $3C00
    ADD     HL, DE
    POP     DE
    RET     
    DB      $45, $85, $4D, $8D, $51

SUB_A9E7:
    PUSH    AF

LOC_A9E8:
    RST     $08
    LD      BC, $DCCD
    XOR     B
    CALL    C, SUB_A75B
    CALL    SUB_ABDA
    CALL    SUB_A915
    CALL    SUB_A9FE
    OR      A
    JR      NZ, LOC_A9E8
    POP     AF
    RET     

SUB_A9FE:
    LD      A, ($7117)                  ; RAM $7117
    CP      $01
    JR      Z, LOC_AA09
    LD      A, ($70B7)                  ; RAM $70B7
    RET     

LOC_AA09:
    LD      A, ($70B4)                  ; RAM $70B4
    RET     

SUB_AA0D:
    LD      A, ($715F)                  ; RAM $715F
    LD      BC, $02C8
    LD      ($715B), BC                 ; RAM $715B
    JR      LOC_AA3B

SUB_AA19:
    LD      A, (IX+3)
    LD      BC, $01F8
    LD      ($715B), BC                 ; RAM $715B
    JR      LOC_AA3B

SUB_AA25:
    LD      A, (IX+6)
    LD      BC, $0190
    LD      ($715B), BC                 ; RAM $715B
    JR      LOC_AA3B

SUB_AA31:
    LD      A, (IX+7)
    LD      BC, $01B8
    LD      ($715B), BC                 ; RAM $715B

LOC_AA3B:
    LD      BC, ($7115)                 ; RAM $7115
    LD      HL, $AAA8
    PUSH    AF
    AND     $0F
    LD      E, A
    LD      D, $00
    JR      NZ, LOC_AA50
    BIT     7, B
    JR      Z, LOC_AA50
    LD      E, $0A

LOC_AA50:
    PUSH    HL
    ADD     HL, DE
    ADD     HL, DE
    LD      A, (HL)
    INC     HL
    LD      H, (HL)
    LD      L, A
    ADD     HL, BC
    LD      BC, ($8A8B)
    ADD     HL, BC
    LD      DE, ($715B)                 ; RAM $715B
    DB      $EB
    LD      BC, $0008
    ADD     HL, BC
    DB      $EB
    CALL    VDP_WRITE_8490
    LD      BC, ($7115)                 ; RAM $7115
    POP     HL
    POP     AF
    PUSH    AF
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    LD      E, A
    LD      D, $00
    ADD     HL, DE
    ADD     HL, DE
    LD      A, (HL)
    INC     HL
    LD      H, (HL)
    LD      L, A
    LD      DE, ($8A8B)
    ADD     HL, DE
    POP     AF
    AND     $0F
    CP      $09
    JR      NZ, LOC_AA95
    BIT     7, B
    JR      NZ, LOC_AA9D
    ADD     HL, BC
    JR      LOC_AA9D

LOC_AA95:
    OR      A
    JR      NZ, LOC_AA9D
    BIT     7, B
    JR      Z, LOC_AA9D
    ADD     HL, BC

LOC_AA9D:
    LD      DE, ($715B)                 ; RAM $715B
    LD      BC, $0008
    CALL    VDP_WRITE_8490
    RET     
    DB      $80, $00, $88, $00, $90, $00, $98, $00
    DB      $A0, $00, $A8, $00, $B0, $00, $B8, $00
    DB      $C0, $00, $C8, $00, $D0, $00

SUB_AABE:
    CALL    VDP_WRITE_AB84
    LD      DE, BOOT_UP
    LD      ($7115), DE                 ; RAM $7115
    LD      A, (IX+3)
    CALL    SUB_AA19
    LD      A, (IX+2)
    CP      $03
    JR      NZ, LOC_AADD
    LD      A, $06
    CALL    DELAY_LOOP_832E
    INC     A
    JR      LOC_AAEC

LOC_AADD:
    CALL    SUB_834C
    AND     $07
    RET     Z
    LD      B, A
    LD      A, (IX+2)
    SLA     A
    CP      B
    RET     Z
    RET     C

LOC_AAEC:
    LD      B, A
    CALL    SUB_834C
    BIT     0, A
    JR      Z, LOC_AB43

LOC_AAF4:
    PUSH    BC
    LD      B, $07

LOC_AAF7:
    PUSH    BC
    RST     $08
    DEC     B
    LD      A, (IX+3)
    OR      A
    JP      Z, LOC_AB54
    CALL    SUB_AA19
    LD      DE, ($7115)                 ; RAM $7115
    DEC     DE
    LD      ($7115), DE                 ; RAM $7115
    POP     BC
    DJNZ    LOC_AAF7
    RST     $08
    DEC     B
    LD      A, (IX+3)
    SUB     $01
    DAA     
    LD      (IX+3), A
    LD      DE, BOOT_UP
    LD      ($7115), DE                 ; RAM $7115
    LD      A, (IX+3)
    CALL    SUB_AA19
    LD      A, $06
    CALL    SUB_8C67
    LD      A, (IX+3)
    OR      A
    JR      Z, LOC_AB37
    POP     BC
    DJNZ    LOC_AAF4
    RET     

LOC_AB37:
    LD      A, ($7120)                  ; RAM $7120
    CPL     
    LD      ($7120), A                  ; RAM $7120
    CALL    VDP_WRITE_AB84
    JR      LOC_AB80

LOC_AB43:
    LD      A, (IX+3)
    CP      $30
    JR      Z, LOC_AB4B
    RET     NC

LOC_AB4B:
    PUSH    BC
    LD      B, $07

LOC_AB4E:
    PUSH    BC
    RST     $08
    DEC     B
    LD      A, (IX+3)

LOC_AB54:
    CALL    SUB_AA19
    LD      DE, ($7115)                 ; RAM $7115
    INC     DE
    LD      ($7115), DE                 ; RAM $7115
    POP     BC
    DJNZ    LOC_AB4E
    RST     $08
    DEC     B
    LD      DE, BOOT_UP
    LD      ($7115), DE                 ; RAM $7115
    LD      A, (IX+3)
    ADD     A, $01
    DAA     
    LD      (IX+3), A
    LD      A, (IX+3)
    CALL    SUB_AA19
    LD      A, $05
    CALL    SUB_8C67

LOC_AB80:
    POP     BC
    DJNZ    LOC_AB43
    RET     

VDP_WRITE_AB84:
    RST     $08
    LD      BC, $69CD                   ; RAM $69CD
    ADD     A, E
    LD      A, ($7120)                  ; RAM $7120
    OR      A
    LD      C, $28
    JR      Z, LOC_AB93
    LD      C, $2C

LOC_AB93:
    LD      DE, $3C5C
    LD      A, E
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, D
    ADD     A, $40
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, C
    INC     C
    NOP     
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    LD      A, C
    INC     C
    NOP     
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    LD      DE, $3C7C
    LD      A, E
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, D
    ADD     A, $40
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, C
    INC     C
    NOP     
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    LD      A, C
    INC     C
    NOP     
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    JP      VDP_REG_8352

SUB_ABC0:
    PUSH    AF
    LD      A, $01
    LD      ($7124), A                  ; RAM $7124
    LD      A, $00
    LD      ($7125), A                  ; RAM $7125
    LD      ($7122), A                  ; RAM $7122
    CALL    SUB_834C
    AND     $11
    ADD     A, $3C
    LD      ($7123), A                  ; RAM $7123
    POP     AF
    RET     

SUB_ABDA:
    PUSH    AF
    PUSH    BC
    PUSH    DE
    PUSH    HL
    LD      A, ($7123)                  ; RAM $7123
    DEC     A
    LD      ($7123), A                  ; RAM $7123
    JR      NZ, LOC_ABFD
    CALL    SUB_834C
    AND     $11
    ADD     A, $3C
    LD      ($7123), A                  ; RAM $7123
    LD      A, ($7122)                  ; RAM $7122
    CPL     
    LD      ($7122), A                  ; RAM $7122
    LD      A, $78
    LD      ($7124), A                  ; RAM $7124

LOC_ABFD:
    LD      A, ($7122)                  ; RAM $7122
    OR      A
    JP      NZ, LOC_AC8C
    LD      A, ($7124)                  ; RAM $7124
    CP      $78
    JR      NZ, LOC_AC10
    LD      A, $07
    LD      ($7124), A                  ; RAM $7124

LOC_AC10:
    LD      A, $04
    CALL    SUB_8C67
    LD      A, ($7124)                  ; RAM $7124
    DEC     A
    LD      ($7124), A                  ; RAM $7124
    JP      NZ, LOC_AC52
    LD      A, $07
    LD      ($7124), A                  ; RAM $7124
    LD      A, ($7125)                  ; RAM $7125
    INC     A
    AND     $03
    LD      ($7125), A                  ; RAM $7125
    LD      HL, $AC3A
    LD      E, A
    LD      D, $00
    ADD     HL, DE
    ADD     HL, DE
    LD      A, (HL)
    INC     HL
    LD      H, (HL)
    LD      L, A
    JP      (HL)
    DB      $42, $AC, $65, $AC, $72, $AC, $7F, $AC
    DB      $21, $B9, $3C, $3E, $46, $CD, $25, $9F
    DB      $21, $B6, $3C, $3E, $47, $CD, $25, $9F

LOC_AC52:
    LD      HL, $3F70
    LD      BC, $0004
    LD      A, $00
    CALL    VDP_WRITE_84A7
    CALL    VDP_WRITE_ADCD

LOC_AC60:
    POP     HL
    POP     DE
    POP     BC
    POP     AF
    RET     
    DB      $21, $B6, $3C, $3E, $46, $CD, $25, $9F
    DB      $21, $B7, $3C, $18, $DB, $21, $B7, $3C
    DB      $3E, $46, $CD, $25, $9F, $21, $B8, $3C
    DB      $18, $CE, $21, $B8, $3C, $3E, $46, $CD
    DB      $25, $9F, $21, $B9, $3C, $18, $C1

LOC_AC8C:
    LD      A, ($7124)                  ; RAM $7124
    CP      $78
    JR      Z, LOC_AC9A
    DEC     A
    LD      ($7124), A                  ; RAM $7124
    JP      LOC_AC60

LOC_AC9A:
    LD      A, $0C
    CALL    SUB_8C67
    LD      A, $77
    LD      ($7123), A                  ; RAM $7123
    LD      ($7124), A                  ; RAM $7124
    PUSH    IX
    LD      IX, ($711A)                 ; RAM $711A
    LD      A, (IX+0)
    LD      ($7152), A                  ; RAM $7152

LOC_ACB3:
    CALL    SUB_834C
    AND     $18
    CP      $10
    JR      Z, LOC_ACBE
    JR      NC, LOC_ACB3

LOC_ACBE:
    LD      ($714E), A                  ; RAM $714E
    NEG     
    ADD     A, (IX+0)
    CP      $A0
    JR      Z, LOC_ACCC
    JR      NC, LOC_ACB3

LOC_ACCC:
    SRL     A
    SRL     A
    SRL     A
    LD      L, A
    LD      H, $00
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL

LOC_ACDA:
    CALL    SUB_834C
    CP      $10
    JR      Z, LOC_ACE3
    JR      NC, LOC_ACDA

LOC_ACE3:
    AND     $18
    LD      ($714F), A                  ; RAM $714F
    SUB     $10
    ADD     A, (IX+1)
    CP      $E0
    JR      Z, LOC_ACF3
    JR      NC, LOC_ACDA

LOC_ACF3:
    SRL     A
    SRL     A
    SRL     A
    LD      C, A
    LD      B, $00
    ADD     HL, BC
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    PUSH    HL
    LD      IX, $714E                   ; RAM $714E
    LD      HL, $3F2E
    LD      A, (IX+1)
    ADD     A, $10
    LD      (IX+1), A
    LD      A, ($7117)                  ; RAM $7117
    CP      $01
    JR      Z, LOC_AD22
    LD      HL, $3F32
    LD      A, (IX+1)
    SUB     $20
    LD      (IX+1), A

LOC_AD22:
    LD      A, L
    CALL    SUB_8369
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, H
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, ($7152)                  ; RAM $7152
    AND     $07
    ADD     A, $02
    ADD     A, (IX+0)
    LD      (IX+0), A
    LD      A, $C0
    SUB     (IX+1)
    LD      (IX+1), A
    IN      A, ($BE)                    ; DATA_PORT - read VRAM
    LD      (IX+2), A
    LD      (IX+3), $01
    LD      HL, $714E                   ; RAM $714E
    LD      DE, $3F70
    LD      BC, $0004
    CALL    VDP_WRITE_8490
    POP     HL
    PUSH    HL
    LD      BC, BOOT_UP
    ADD     HL, BC
    LD      B, $04
    EXX     
    LD      HL, $0060
    LD      DE, $0020
    EXX     

LOC_AD65:
    PUSH    BC
    CALL    VDP_WRITE_AD9B
    CALL    VDP_WRITE_ADB2
    EXX     
    ADD     HL, DE
    EXX     
    LD      DE, $0100
    ADD     HL, DE
    POP     BC
    DJNZ    LOC_AD65
    POP     HL
    LD      BC, $2000
    ADD     HL, BC
    LD      B, $04
    EXX     
    LD      HL, $2060
    LD      DE, $0020
    EXX     

LOC_AD85:
    PUSH    BC
    CALL    VDP_WRITE_AD9B
    CALL    VDP_WRITE_ADB2
    EXX     
    ADD     HL, DE
    EXX     
    LD      DE, $0100
    ADD     HL, DE
    POP     BC
    DJNZ    LOC_AD85
    POP     IX
    JP      LOC_AC60

VDP_WRITE_AD9B:
    LD      A, L
    CALL    SUB_8369
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, H
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      B, $20
    LD      DE, $7126                   ; RAM $7126

LOC_ADA9:
    IN      A, ($BE)                    ; DATA_PORT - read VRAM
    LD      (DE), A
    INC     DE
    DJNZ    LOC_ADA9
    JP      VDP_REG_8352

VDP_WRITE_ADB2:
    EXX     
    LD      A, L
    CALL    SUB_8369
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, H
    ADD     A, $40
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    EXX     
    LD      B, $20
    LD      DE, $7126                   ; RAM $7126

LOC_ADC4:
    LD      A, (DE)
    INC     DE
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    DJNZ    LOC_ADC4
    JP      VDP_REG_8352

VDP_WRITE_ADCD:
    CALL    SUB_834C
    LD      HL, ($73C8)                 ; RAM $73C8
    LD      DE, $0060
    LD      A, E
    CALL    SUB_8369
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, D
    ADD     A, $40
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, H
    AND     $0F
    LD      H, A
    LD      A, L
    OR      $80
    LD      L, A
    LD      B, $80

LOC_ADEB:
    LD      A, (HL)
    INC     HL
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    DJNZ    LOC_ADEB
    LD      DE, $2060
    LD      A, E
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, D
    ADD     A, $40
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      B, $80
    LD      A, $1F

LOC_AE00:
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    NOP     
    NOP     
    DJNZ    LOC_AE00
    JP      VDP_REG_8352

LOC_AE09:
    LD      A, $01
    CALL    SUB_8C67
    LD      IY, $70D7                   ; RAM $70D7
    LD      IX, ($7118)                 ; RAM $7118
    CALL    SUB_AF63
    CALL    SUB_AF8D
    CALL    SUB_AFDB
    LD      A, $07
    CALL    SUB_8C67

LOC_AE24:
    RST     $08
    LD      (BC), A
    CALL    SUB_AFFF
    JR      C, LOC_AE35
    CALL    SUB_B043
    CALL    VDP_WRITE_B05D
    JR      C, LOC_AE35
    JR      LOC_AE47

LOC_AE35:
    CALL    VDP_WRITE_B09D
    LD      A, $0A
    CALL    SUB_8C67
    LD      B, $0F
    CALL    VDP_INIT_B0B4
    XOR     A
    LD      ($7146), A                  ; RAM $7146
    RET     

LOC_AE47:
    BIT     7, (IY+0)
    JP      NZ, LOC_AE24
    LD      A, (IY+4)
    SUB     (IX+1)
    SUB     $10
    BIT     7, (IY+7)
    JR      Z, LOC_AE60
    ADD     A, $10
    NEG     

LOC_AE60:
    CP      $28
    JP      C, LOC_AE24
    LD      D, (IY+4)
    LD      E, (IY+1)
    CALL    SUB_9E7A
    CP      $0A
    JR      Z, LOC_AE90
    CP      $01
    JR      Z, LOC_AE90
    CP      $0C
    JR      Z, LOC_AE7D
    JP      LOC_AE24

LOC_AE7D:
    LD      A, (IX+2)
    CP      $01
    JR      Z, LOC_AE24
    CP      $03
    JR      Z, LOC_AE90
    CALL    SUB_834C
    CP      $20
    JP      NC, LOC_AE24

LOC_AE90:
    LD      A, $0A
    CALL    SUB_8C67
    LD      HL, $3F08
    LD      BC, $0004
    XOR     A
    CALL    VDP_WRITE_84A7
    LD      A, D
    CP      $08
    JR      NC, LOC_AEA6
    LD      A, $08

LOC_AEA6:
    SUB     $08
    LD      D, A
    LD      A, E
    CP      $F7
    JR      C, LOC_AEB2
    JR      Z, LOC_AEB2
    LD      A, $F7

LOC_AEB2:
    SUB     $08
    LD      E, A
    LD      A, (IX+2)
    LD      HL, $B238
    CP      $01
    JR      Z, LOC_AEC9
    LD      HL, $B298
    CP      $02
    JR      Z, LOC_AEC9
    LD      HL, $B2F8

LOC_AEC9:
    LD      B, $0A
    LD      C, $02
    XOR     A
    CALL    SOUND_WRITE_B378
    LD      IY, ($711A)                 ; RAM $711A
    LD      A, (IY+5)
    LD      (IY+9), A
    LD      (IY+5), $00
    XOR     A
    LD      ($7146), A                  ; RAM $7146
    LD      E, (IY+0)
    LD      D, (IY+1)
    LD      A, D
    LD      ($714E), A                  ; RAM $714E
    LD      B, $0C

LOC_AEEF:
    PUSH    BC
    LD      B, $10

LOC_AEF2:
    CALL    SUB_9E7A
    CP      $01
    JR      NZ, LOC_AEFC
    INC     (IY+5)

LOC_AEFC:
    INC     D
    DJNZ    LOC_AEF2
    INC     E
    LD      A, ($714E)                  ; RAM $714E
    LD      D, A
    POP     BC
    DJNZ    LOC_AEEF
    LD      A, (IY+5)
    CP      (IY+9)
    JR      Z, LOC_AF1A
    LD      A, $FF
    LD      ($7146), A                  ; RAM $7146
    INC     (IX+8)
    LD      A, (IY+5)

LOC_AF1A:
    CP      $3A
    JR      NC, LOC_AF61
    RST     $08
    LD      BC, $0E3E
    CALL    SUB_8C67
    LD      A, ($7117)                  ; RAM $7117
    CP      $01
    JR      NZ, LOC_AF39
    LD      HL, $3F2C
    LD      BC, $0004
    LD      A, $C0
    CALL    VDP_WRITE_84A7
    JR      LOC_AF44

LOC_AF39:
    LD      HL, $3F30
    LD      BC, $0004
    LD      A, $C0
    CALL    VDP_WRITE_84A7

LOC_AF44:
    LD      E, (IY+0)
    LD      D, (IY+1)
    LD      HL, $B358
    LD      B, $20
    LD      C, $03
    LD      A, $FF
    CALL    SOUND_WRITE_B378
    LD      IY, ($711A)                 ; RAM $711A
    LD      A, $01
    CALL    SUB_8C67
    SCF     
    RET     

LOC_AF61:
    XOR     A
    RET     

SUB_AF63:
    LD      A, ($7117)                  ; RAM $7117
    CP      $01
    LD      A, (IX+1)
    JR      NZ, LOC_AF6F
    ADD     A, $12

LOC_AF6F:
    SUB     $01
    LD      (IY+4), A
    LD      A, (IX+0)
    ADD     A, $03
    LD      (IY+1), A
    LD      (IY+0), $00
    LD      (IY+2), $00
    LD      (IY+3), $00
    LD      (IY+5), $00
    RET     

SUB_AF8D:
    LD      DE, BOOT_UP
    XOR     A

LOC_AF91:
    CP      (IX+6)
    JR      Z, LOC_AF9C
    ADD     A, $05
    DAA     
    INC     DE
    JR      LOC_AF91

LOC_AF9C:
    LD      HL, $B1A0
    LD      A, ($7117)                  ; RAM $7117
    CP      $01
    JR      Z, LOC_AFA9
    LD      HL, $B1EC

LOC_AFA9:
    ADD     HL, DE
    ADD     HL, DE
    ADD     HL, DE
    ADD     HL, DE
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    SRA     D
    RR      E
    INC     HL
    LD      A, (IX+7)
    CALL    SUB_B0D7
    CALL    SUB_B192
    LD      (IY+6), E
    LD      (IY+7), D
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    SRA     D
    RR      E
    LD      A, (IX+7)
    CALL    SUB_B0D7
    CALL    SUB_B192
    LD      (IY+8), E
    LD      (IY+9), D
    RET     

SUB_AFDB:
    LD      L, (IY+6)
    LD      H, (IY+7)
    LD      A, (IX+3)
    CALL    SUB_B0D7
    SLA     A
    LD      E, A
    LD      D, $00
    LD      A, ($7120)                  ; RAM $7120
    OR      A
    JR      Z, LOC_AFF7
    AND     A
    SBC     HL, DE
    JR      LOC_AFF8

LOC_AFF7:
    ADD     HL, DE

LOC_AFF8:
    LD      (IY+6), L
    LD      (IY+7), H
    RET     

SUB_AFFF:
    LD      E, (IY+8)
    LD      D, (IY+9)
    LD      L, (IY+2)
    LD      H, (IY+1)
    ADD     HL, DE
    LD      (IY+2), L
    LD      (IY+1), H
    LD      A, $00
    BIT     7, D
    JR      Z, LOC_B019
    CPL     

LOC_B019:
    ADC     A, (IY+0)
    LD      (IY+0), A
    LD      E, (IY+6)
    LD      D, (IY+7)
    LD      L, (IY+5)
    LD      H, (IY+4)
    ADD     HL, DE
    LD      (IY+5), L
    LD      (IY+4), H
    LD      A, $00
    BIT     7, D
    JR      Z, LOC_B039
    CPL     

LOC_B039:
    ADC     A, (IY+3)
    LD      (IY+3), A
    OR      A
    RET     Z
    SCF     
    RET     

SUB_B043:
    LD      L, (IY+8)
    LD      H, (IY+9)
    LD      DE, ($711C)                 ; RAM $711C
    ADD     HL, DE
    LD      (IY+8), L
    LD      (IY+9), H

; ============================================================
; GAME DATA  ($B054 - $BBFF)
; Animation, sprite, level, and name-table data.
; (Tracer did not reach this area via static flow; kept as DB.)
; ============================================================
GAME_DATA:
    BIT     7, H                            ; first instruction of GAME_DATA area (bytes decoded as instructions)
    RET     NZ
    LD      A, $09
    CALL    SUB_8C67
    RET     

VDP_WRITE_B05D:
    LD      A, (IY+0)                       ; load projectile status byte (IY+0)
    BIT     7, A                            ; test bit 7 (sprite hidden flag)
    JP      NZ, VDP_WRITE_B09D              ; hidden: show off-screen sprite
    OR      A                               ; test for zero
    JP      NZ, LOC_B098                    ; nonzero, not-hidden: out-of-bounds path
    LD      DE, $3F08                       ; sprite attribute VRAM address = $3F08
    LD      A, E
    CALL    SUB_8369
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, D
    ADD     A, $40
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, (IY+1)                       ; sprite Y coordinate (IY+1)
    OUT     ($BE), A                        ; write sprite Y to VRAM
    NOP     
    LD      A, (IY+4)                       ; sprite tile index (IY+4)
    OUT     ($BE), A                        ; write sprite tile to VRAM
    LD      A, $04
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    LD      A, $01
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    CALL    VDP_REG_8352
    LD      A, (IY+1)
    CP      $BF
    JR      Z, LOC_B096
    JR      NC, LOC_B098

LOC_B096:
    OR      A
    RET     

LOC_B098:
    CALL    VDP_WRITE_B09D
    SCF     
    RET     

VDP_WRITE_B09D:
    LD      DE, $3F08                       ; sprite attribute VRAM address = $3F08
    LD      A, E
    CALL    SUB_8369
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, D
    ADD     A, $40
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $C0                          ; A = $C0 (off-screen Y position)
    OUT     ($BE), A                        ; write off-screen Y to sprite attr
    CALL    VDP_REG_8352                    ; re-arm NMI
    OR      A
    RET     

VDP_INIT_B0B4:
    CALL    SUB_834C                        ; read random byte for background color
    AND     $03                             ; keep low 2 bits (4 possible BG colors)
    ADD     A, $07                          ; add $07 (offset into VDP color register range)
    CALL    SUB_8369                        ; disarm NMI
    OUT     ($BF), A                        ; write VDP register number
    LD      A, $87                          ; VDP register control byte = $87
    OUT     ($BF), A                        ; write VDP control value
    RST     $08
    INC     BC
    DJNZ    VDP_INIT_B0B4                   ; repeat for animation loop
    CALL    SUB_8369
    LD      A, $07
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $87
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    CALL    VDP_REG_8352
    RET     

SUB_B0D7:
    PUSH    BC
    LD      B, A                            ; A >>= 4 (extract high nibble)
    SRL     A                               ; continue shift
    SRL     A                               ; continue shift
    SRL     A                               ; continue shift
    SRL     A                               ; C = high nibble value
    LD      C, A                            ; A *= 2
    ADD     A, A                            ; A *= 4
    ADD     A, A                            ; A += C => A *= 5
    ADD     A, C                            ; A *= 10 (high_nibble x 10)
    ADD     A, A                            ; C = high_nibble * 10
    LD      C, A                            ; restore A
    LD      A, B                            ; isolate low nibble
    AND     $0F                             ; A = low_nibble + high_nibble*10 (packed BCD to binary)
    ADD     A, C
    POP     BC
    RET     

SUB_B0ED:
    OR      A                               ; test which player (A=0: P1, A=1: P2)
    JR      NZ, LOC_B141                    ; A != 0: P2 aim indicator
    LD      A, ($70C3)                      ; load P1 cannon Y ($70C3)
    SUB     $06                             ; subtract 6 (indicator Y offset above cannon)
    LD      ($714E), A                      ; store indicator Y at $714E
    LD      A, ($70C4)                      ; load P1 cannon X ($70C4)
    ADD     A, $10                          ; add $10 (center indicator over cannon)
    LD      ($714F), A                      ; store indicator X at $714F
    LD      A, ($70C9)                  ; RAM $70C9
    LD      B, $64
    CP      $79
    JR      Z, LOC_B10B
    JR      NC, LOC_B125

LOC_B10B:
    LD      B, $68
    CP      $57
    JR      Z, LOC_B113
    JR      NC, LOC_B125

LOC_B113:
    LD      B, $6C
    CP      $34
    JR      Z, LOC_B11B
    JR      NC, LOC_B125

LOC_B11B:
    LD      B, $70
    CP      $12
    JR      Z, LOC_B123
    JR      NC, LOC_B125

LOC_B123:
    LD      B, $74

LOC_B125:
    LD      A, B
    LD      ($7150), A                  ; RAM $7150
    LD      A, $01
    LD      ($7151), A                  ; RAM $7151
    CALL    SUB_8369
    LD      HL, $714E                   ; RAM $714E
    LD      DE, $3F30
    LD      BC, $0004
    CALL    VDP_WRITE_8490
    CALL    VDP_REG_8352
    RET     

LOC_B141:
    LD      A, ($70CD)                  ; RAM $70CD
    SUB     $06
    LD      ($714E), A                  ; RAM $714E
    LD      A, ($70CE)                  ; RAM $70CE
    SUB     $10
    LD      ($714F), A                  ; RAM $714F
    LD      A, ($70D3)                  ; RAM $70D3
    LD      B, $78
    CP      $79
    JR      Z, LOC_B15C
    JR      NC, LOC_B176

LOC_B15C:
    LD      B, $7C
    CP      $57
    JR      Z, LOC_B164
    JR      NC, LOC_B176

LOC_B164:
    LD      B, $80
    CP      $34
    JR      Z, LOC_B16C
    JR      NC, LOC_B176

LOC_B16C:
    LD      B, $84
    CP      $12
    JR      Z, LOC_B174
    JR      NC, LOC_B176

LOC_B174:
    LD      B, $88

LOC_B176:
    LD      A, B
    LD      ($7150), A                  ; RAM $7150
    LD      A, $01
    LD      ($7151), A                  ; RAM $7151
    CALL    SUB_8369
    LD      HL, $714E                   ; RAM $714E
    LD      DE, $3F2C
    LD      BC, $0004
    CALL    VDP_WRITE_8490
    CALL    VDP_REG_8352
    RET     

SUB_B192:
    PUSH    HL
    LD      HL, BOOT_UP

LOC_B196:
    OR      A
    JR      Z, LOC_B19D
    ADD     HL, DE
    DEC     A
    JR      LOC_B196

LOC_B19D:
    DB      $EB
    POP     HL
    RET     
    DB      $0F, $00, $00, $00, $0F, $00, $FF, $FF
    DB      $0F, $00, $FE, $FF, $0F, $00, $FC, $FF
    DB      $0F, $00, $FB, $FF, $0E, $00, $FA, $FF
    DB      $0D, $00, $F8, $FF, $0D, $00, $F7, $FF
    DB      $0C, $00, $F6, $FF, $0B, $00, $F5, $FF
    DB      $0A, $00, $F4, $FF, $09, $00, $F3, $FF
    DB      $08, $00, $F3, $FF, $06, $00, $F2, $FF
    DB      $05, $00, $F1, $FF, $04, $00, $F1, $FF
    DB      $02, $00, $F1, $FF, $01, $00, $F1, $FF
    DB      $00, $00, $F1, $FF, $F1, $FF, $00, $00
    DB      $F1, $FF, $FF, $FF, $F1, $FF, $FE, $FF
    DB      $F1, $FF, $FC, $FF, $F1, $FF, $FB, $FF
    DB      $F2, $FF, $FA, $FF, $F3, $FF, $F8, $FF
    DB      $F3, $FF, $F7, $FF, $F4, $FF, $F6, $FF
    DB      $F5, $FF, $F5, $FF, $F6, $FF, $F4, $FF
    DB      $F7, $FF, $F3, $FF, $F8, $FF, $F3, $FF
    DB      $FA, $FF, $F2, $FF, $FB, $FF, $F1, $FF
    DB      $FC, $FF, $F1, $FF, $FE, $FF, $F1, $FF
    DB      $FF, $FF, $F1, $FF, $00, $00, $F1, $FF
    DB      $00, $00, $00, $00, $E3, $C7, $73, $CE
    DB      $3F, $FC, $1F, $F8, $1F, $F0, $3F, $FC
    DB      $3F, $FC, $0F, $F0, $1F, $F8, $3F, $FC
    DB      $73, $CE, $E3, $C7, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $73, $CE
    DB      $3F, $FC, $1F, $FC, $3F, $FF, $FF, $FF
    DB      $3F, $FC, $FF, $F0, $1F, $FF, $3F, $FC
    DB      $F3, $CF, $40, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $0F, $F0
    DB      $3F, $FC, $7F, $FE, $FF, $FF, $3F, $FC
    DB      $3F, $FF, $0F, $FC, $FF, $FF, $3F, $FC
    DB      $1E, $3C, $07, $07, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $33, $CC
    DB      $1B, $D8, $0F, $F0, $0F, $E0, $1F, $F8
    DB      $1F, $F8, $07, $E0, $0F, $F0, $1B, $D8
    DB      $33, $CC, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $1B, $D8, $0F, $F0, $1F, $FC, $7F, $FE
    DB      $1F, $F8, $07, $FE, $3F, $FC, $1B, $D8
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $03, $C0, $7F, $FC, $3F, $FE, $1F, $FF
    DB      $1F, $F8, $7F, $FC, $0F, $F0, $F8, $FE
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $07, $E0, $0F, $F0, $1F, $F8
    DB      $3F, $FC, $07, $E0, $07, $E0, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $03, $C0, $07, $E0, $7F, $FE
    DB      $7F, $FE, $07, $E0, $03, $C0, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $09, $90, $07, $E0, $07, $E0, $0F, $F0
    DB      $0F, $F0, $07, $E0, $07, $E0, $09, $90
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

SOUND_WRITE_B378:
    LD      ($7147), A                  ; RAM $7147
    PUSH    BC
    LD      A, (HL)
    CP      $FF
    JR      Z, LOC_B392
    LD      BC, $0020

LOC_B384:
    CALL    SUB_834C
    AND     $03
    JR      Z, LOC_B384
    DEC     A
    JR      Z, LOC_B392

LOC_B38E:
    ADD     HL, BC
    DEC     A
    JR      NZ, LOC_B38E

LOC_B392:
    XOR     A
    LD      ($714D), A                  ; RAM $714D
    LD      IY, $714E                   ; RAM $714E
    LD      B, $10

LOC_B39C:
    PUSH    DE
    LD      C, (HL)
    INC     HL
    CALL    DELAY_LOOP_B3B4
    LD      C, (HL)
    INC     HL
    CALL    DELAY_LOOP_B3B4
    POP     DE
    INC     E
    LD      A, E
    CP      $C0
    JP      NC, LOC_B439
    DJNZ    LOC_B39C
    JP      LOC_B439

DELAY_LOOP_B3B4:
    PUSH    BC
    LD      B, $08

LOC_B3B7:
    RLC     C
    CALL    C, SUB_B3C1
    INC     D
    DJNZ    LOC_B3B7
    POP     BC
    RET     

SUB_B3C1:
    CALL    SUB_9E7A
    CP      $0A
    JR      Z, LOC_B3DC
    CP      $01
    JR      Z, LOC_B3ED
    CP      $0C
    RET     NZ
    LD      A, ($7121)                  ; RAM $7121
    CP      $C1
    JR      Z, LOC_B3ED
    CP      $C0
    JR      Z, LOC_B3FC
    JR      LOC_B3E3

LOC_B3DC:
    LD      A, ($7121)                  ; RAM $7121
    CP      $A6
    JR      Z, LOC_B3FC

LOC_B3E3:
    LD      A, $C6
    LD      ($711E), A                  ; RAM $711E
    CALL    SUB_9EAB
    JR      LOC_B3FC

LOC_B3ED:
    LD      A, ($7121)                  ; RAM $7121
    CP      $16
    JR      Z, LOC_B3FC
    LD      A, $16
    LD      ($711E), A                  ; RAM $711E
    CALL    SUB_9EAB

LOC_B3FC:
    LD      A, ($714D)                  ; RAM $714D
    INC     A
    CP      $80
    JR      Z, LOC_B405
    RET     NC

LOC_B405:
    LD      ($714D), A                  ; RAM $714D
    LD      (IY+1), E
    LD      (IY+0), D
    LD      A, $05
    CALL    DELAY_LOOP_832E
    NEG     
    LD      (IY+3), A
    LD      A, $05
    CALL    DELAY_LOOP_832E
    PUSH    AF
    LD      A, ($73C8)                  ; RAM $73C8
    BIT     5, A
    JR      NZ, LOC_B42B
    POP     AF
    LD      (IY+2), A
    JR      LOC_B431

LOC_B42B:
    POP     AF
    NEG     
    LD      (IY+2), A

LOC_B431:
    PUSH    DE
    LD      DE, $0004
    ADD     IY, DE
    POP     DE
    RET     

LOC_B439:
    POP     BC
    LD      A, ($714D)                  ; RAM $714D
    OR      A
    RET     Z
    LD      A, C
    LD      ($714B), A                  ; RAM $714B
    LD      A, B
    LD      ($714C), A                  ; RAM $714C

LOC_B447:
    LD      A, ($714B)                  ; RAM $714B
    LD      B, A

LOC_B44B:
    RST     $08
    LD      BC, $76CD                   ; RAM $76CD
    OR      H
    DJNZ    LOC_B44B
    CALL    VDP_REG_B4CA
    LD      A, ($714C)                  ; RAM $714C
    DEC     A
    LD      ($714C), A                  ; RAM $714C
    OR      A
    JR      NZ, LOC_B46E
    CALL    SUB_8369
    LD      A, $07
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $87
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    CALL    VDP_REG_8352
    RET     

LOC_B46E:
    CALL    VDP_REG_B48D
    CALL    VDP_REG_B4CA
    JR      LOC_B447
    DB      $3A, $47, $71, $B7, $C8, $CD, $4C, $83
    DB      $E6, $0F, $CD, $69, $83, $D3, $BF, $3E
    DB      $87, $D3, $BF, $CD, $52, $83, $C9

VDP_REG_B48D:
    LD      A, ($714D)                  ; RAM $714D
    LD      B, A
    LD      IY, $714E                   ; RAM $714E
    LD      DE, $0004

LOC_B498:
    LD      A, (IY+1)
    CP      $BF
    JR      Z, LOC_B4A1
    JR      NC, LOC_B4B3

LOC_B4A1:
    ADD     A, (IY+3)
    LD      (IY+1), A
    LD      A, (IY+0)
    ADD     A, (IY+2)
    CALL    SOUND_WRITE_B4B8
    LD      (IY+0), A

LOC_B4B3:
    ADD     IY, DE
    DJNZ    LOC_B498
    RET     

SOUND_WRITE_B4B8:
    PUSH    AF
    BIT     7, (IY+2)
    JR      NZ, LOC_B4C6
    POP     AF
    RET     NC

LOC_B4C1:
    LD      (IY+1), $FF
    RET     

LOC_B4C6:
    POP     AF
    RET     C
    JR      LOC_B4C1

VDP_REG_B4CA:
    LD      A, ($714D)                  ; RAM $714D
    LD      B, A
    LD      IY, $714E                   ; RAM $714E

LOC_B4D2:
    LD      A, (IY+1)
    CP      $BF
    JR      NC, LOC_B4FD
    LD      E, A
    LD      D, (IY+0)
    CALL    SUB_9E7A
    LD      C, A
    LD      A, ($7121)                  ; RAM $7121
    LD      ($711E), A                  ; RAM $711E
    LD      ($711F), A                  ; RAM $711F
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    CP      C
    JR      NZ, LOC_B4FA
    CALL    SUB_9ECD
    JR      LOC_B4FD

LOC_B4FA:
    CALL    SUB_9EAB

LOC_B4FD:
    LD      DE, $0004
    ADD     IY, DE
    DJNZ    LOC_B4D2
    RET     
    DB      $F0, $FF, $01, $00, $00, $30, $00, $08
    DB      $08, $10, $B5, $31, $00, $FF, $FF, $00
    DB      $F0, $FF, $08, $08, $00, $00, $F0, $FF
    DB      $01, $00, $00, $43, $00, $08, $08, $26
    DB      $B5, $44, $00, $FF, $FF, $00, $F0, $FF
    DB      $04, $04, $00, $00, $E0, $FF, $01, $00
    DB      $00, $20, $00, $08, $08, $3C, $B5, $21
    DB      $00, $FF, $FF, $00, $D4, $FE, $08, $08
    DB      $00, $00, $00, $01, $FF, $FF, $00, $C0
    DB      $00, $08, $08, $52, $B5, $BF, $00, $01
    DB      $00, $00, $00, $01, $08, $08, $00, $00
    DB      $00, $01, $FF, $FF, $00, $AC, $00, $08
    DB      $08, $68, $B5, $AB, $00, $01, $00, $00
    DB      $00, $01, $04, $04, $00, $00, $10, $01
    DB      $FF, $FF, $00, $D0, $00, $08, $08, $7E
    DB      $B5, $CF, $00, $01, $00, $00, $F4, $01
    DB      $08, $08, $00, $00

SUB_B589:
    LD      A, ($7117)                      ; load active player flag $7117
    CP      $01                             ; is active player P1?
    JR      NZ, LOC_B5B2                    ; not P1: jump to P2 sound path
    LD      HL, $B51B                       ; HL = P1 win sound data ($B51B)
    CALL    SUB_834C                        ; get random byte
    AND     $03                             ; keep low 2 bits (alternate endings)
    JR      Z, LOC_B59D                     ; zero: use main P1 sound
    LD      HL, $B505                       ; HL = alternate P1 win sound ($B505)

LOC_B59D:
    LD      DE, $714E                       ; DE = $714E (sound param buffer)
    LD      BC, $000B                       ; BC = $0B (11 bytes)
    LDIR                                    ; copy sound sequence data to buffer
    LD      HL, $B531
    LD      DE, $7162                   ; RAM $7162
    LD      BC, $000B
    LDIR    
    JR      LOC_B5D2

LOC_B5B2:
    LD      HL, $B55D
    CALL    SUB_834C
    AND     $03
    JR      Z, LOC_B5BF
    LD      HL, $B547

LOC_B5BF:
    LD      DE, $714E                   ; RAM $714E
    LD      BC, $000B
    LDIR    
    LD      HL, $B573
    LD      DE, $7162                   ; RAM $7162
    LD      BC, $000B
    LDIR    

LOC_B5D2:
    LD      A, $01
    CALL    SUB_8C67
    LD      A, $02
    CALL    SUB_8C67
    CALL    SUB_8369
    LD      HL, $3F00
    LD      BC, $0010
    LD      A, $00
    CALL    VDP_WRITE_84A7
    CALL    VDP_REG_8352
    LD      IX, $7176                   ; RAM $7176
    LD      IY, $714E                   ; RAM $714E
    CALL    SUB_B63A
    CALL    SUB_B6C6
    JR      C, LOC_B623
    LD      IX, $717E                   ; RAM $717E
    LD      IY, $7162                   ; RAM $7162
    CALL    SUB_B63A
    CALL    SUB_B6C6
    JR      C, LOC_B623
    CALL    SUB_8369
    LD      HL, $7176                   ; RAM $7176
    LD      DE, $3F00
    LD      BC, $0010
    CALL    VDP_WRITE_8490
    CALL    VDP_REG_8352
    RST     $08
    LD      BC, $CA18

LOC_B623:
    CALL    SUB_8369
    LD      HL, $3F00
    LD      BC, $0010
    LD      A, $00
    CALL    VDP_WRITE_84A7
    CALL    VDP_REG_8352
    LD      A, $01
    CALL    SUB_8C67
    RET     

SUB_B63A:
    DEC     (IY+8)
    JR      NZ, LOC_B661
    LD      A, (IY+7)
    LD      (IY+8), A
    LD      A, (IY+4)
    INC     A
    AND     $03
    LD      (IY+4), A
    LD      L, (IY+0)
    LD      H, (IY+1)
    LD      E, (IY+2)
    LD      D, (IY+3)
    ADD     HL, DE
    LD      (IY+0), L
    LD      (IY+1), H

LOC_B661:
    LD      C, $00
    LD      L, (IY+0)
    LD      H, (IY+1)
    BIT     7, H
    JR      NZ, LOC_B673
    LD      A, H
    OR      A
    JR      NZ, LOC_B67D
    JR      LOC_B688

LOC_B673:
    LD      DE, $0020
    ADD     HL, DE
    LD      C, $80
    BIT     7, H
    JR      Z, LOC_B688

LOC_B67D:
    PUSH    IX
    POP     HL
    XOR     A
    LD      B, $08

LOC_B683:
    LD      (HL), A
    INC     HL
    DJNZ    LOC_B683
    RET     

LOC_B688:
    LD      (IX+0), $AB
    LD      (IX+4), $AB
    LD      (IX+1), L
    LD      (IX+5), L
    LD      HL, $B6BE
    BIT     7, (IY+3)
    JR      Z, LOC_B6A2
    LD      HL, $B6C2

LOC_B6A2:
    LD      E, (IY+4)
    LD      D, $00
    ADD     HL, DE
    LD      A, (HL)
    LD      (IX+2), A
    ADD     A, $04
    LD      (IX+6), A
    LD      A, $0C
    OR      C
    LD      (IX+3), A
    LD      A, $01
    OR      C
    LD      (IX+7), A
    RET     
    DB      $0C, $14, $1C, $24, $2C, $34, $3C, $44

SUB_B6C6:
    LD      L, (IY+0)
    LD      H, (IY+1)
    LD      E, (IY+5)
    LD      D, (IY+6)
    AND     A
    SBC     HL, DE
    JR      NZ, LOC_B6E9
    LD      L, (IY+9)
    LD      H, (IY+10)
    LD      A, H
    OR      L
    JR      Z, LOC_B6EB
    PUSH    IY
    POP     DE
    LD      BC, $000B
    LDIR    

LOC_B6E9:
    XOR     A
    RET     

LOC_B6EB:
    SCF     
    RET     

SOUND_WRITE_B6ED:
    LD      HL, $B6FF                       ; HL = sound channel init table ($B6FF)
    LD      DE, $7350                       ; DE = $7350 (sound attribute buffer in RAM)
    LD      BC, $0010                       ; BC = $0010 (16 bytes)
    LDIR                                    ; copy channel init data to RAM buffer
    LD      HL, $FFFF                       ; timing accumulator = $FFFF (silence / max period)
    LD      ($734E), HL                     ; store timing at $734E
    RET     
    DB      $40, $20, $8C, $00, $40, $30, $90, $00
    DB      $50, $78, $94, $00, $50, $88, $98, $00

SUB_B70F:
    PUSH    HL                              ; save HL
    PUSH    DE                              ; save DE
    PUSH    BC                              ; save BC
    PUSH    AF                              ; save AF
    LD      HL, ($734E)                     ; load channel timing accumulator from $734E
    LD      A, L                            ; A = low byte of accumulator
    ADD     A, H                            ; add high byte (carry on overflow drives channel update)
    LD      ($734E), A                      ; store new accumulator value
    JP      NC, LOC_B779                    ; no overflow: skip channel update, flush to VRAM
    LD      A, ($70C6)                      ; load wind speed from $70C6
    CP      $05                             ; clamp minimum wind = $05
    JR      NC, LOC_B727                    ; already >= 5: use as-is
    LD      A, $05                          ; use minimum value = 5

LOC_B727:                                   ; A *= 2 (scale for SN76489A register format)
    ADD     A, A                            ; A *= 4
    ADD     A, A                            ; store volume/attenuation param at $734F
    LD      ($734F), A                  ; RAM $734F
    LD      HL, $7350                       ; HL = $7350 (channel attribute buffer)
    LD      A, ($7120)                      ; load wind direction flag from $7120
    OR      A                               ; test wind direction
    JR      NZ, LOC_B757                    ; nonzero direction: use decrement path
    LD      B, $04

LOC_B737:
    INC     HL
    INC     (HL)
    LD      A, (HL)
    INC     HL
    INC     HL
    BIT     7, (HL)
    JR      Z, LOC_B74E
    CP      $20
    JR      NZ, LOC_B74E
    DEC     HL
    DEC     HL
    LD      (HL), $00
    INC     HL
    INC     HL
    RES     7, (HL)
    JR      LOC_B752

LOC_B74E:
    OR      A
    CALL    Z, SUB_B78A

LOC_B752:
    INC     HL
    DJNZ    LOC_B737
    JR      LOC_B779

LOC_B757:
    LD      B, $04

LOC_B759:
    INC     HL
    DEC     (HL)
    LD      A, (HL)
    INC     HL
    INC     HL
    OR      A
    JR      NZ, LOC_B76D
    SET     7, (HL)
    DEC     HL
    DEC     HL
    LD      A, (HL)
    ADD     A, $20
    LD      (HL), A
    INC     HL
    INC     HL
    JR      LOC_B776

LOC_B76D:
    BIT     7, (HL)
    JR      Z, LOC_B776
    CP      $0F
    CALL    Z, SOUND_WRITE_B793

LOC_B776:
    INC     HL
    DJNZ    LOC_B759

LOC_B779:
    LD      HL, $7350                       ; HL = $7350 (channel buffer)
    LD      DE, $3F40                       ; VRAM destination = $3F40 (sprite/sound table)
    LD      BC, $0010                       ; 16 bytes
    CALL    VDP_WRITE_8490                  ; flush sound channel data to VRAM
    POP     AF                              ; restore AF
    POP     BC                              ; restore BC
    POP     DE                              ; restore DE
    POP     HL                              ; restore HL
    RET     

SUB_B78A:
    DEC     HL
    DEC     HL
    LD      (HL), $0F
    INC     HL
    INC     HL
    SET     7, (HL)
    RET     

SOUND_WRITE_B793:
    DEC     HL
    DEC     HL
    LD      (HL), $FF
    INC     HL
    INC     HL
    RES     7, (HL)
    RET     

DELAY_LOOP_B79C:
    PUSH    HL                              ; save HL
    PUSH    DE                              ; save DE
    PUSH    BC                              ; save BC
    PUSH    AF                              ; save AF
    LD      HL, $7350                       ; HL = $7350 (channel attribute buffer)
    LD      B, $04                          ; 4 channels to process

LOC_B7A5:
    INC     HL                              ; skip volume byte
    INC     HL                              ; skip frequency byte
    INC     HL                              ; point to flags byte (offset +3)
    LD      A, (HL)                         ; load channel flags
    AND     $80                             ; mask to bit 7 (keep active flag only)
    LD      (HL), A                         ; clear all other flags (reset channel state)
    INC     HL                              ; advance to next channel (4 bytes each)
    DJNZ    LOC_B7A5                        ; loop all 4 channels
    LD      HL, $7350                       ; HL = $7350
    LD      DE, $3F40                       ; VRAM destination = $3F40
    LD      BC, $0010                       ; 16 bytes
    CALL    VDP_WRITE_8490                  ; flush reset channel data to VRAM
    POP     AF
    POP     BC
    POP     DE
    POP     HL
    RET     

DELAY_LOOP_B7C0:
    PUSH    HL                              ; save HL
    PUSH    DE                              ; save DE
    PUSH    BC                              ; save BC
    PUSH    AF                              ; save AF
    LD      A, $03                          ; initial timing accumulator = $03
    LD      ($734E), A                      ; store timing at $734E
    LD      HL, $7350                       ; HL = $7350 (channel attribute buffer)
    LD      B, $04                          ; 4 channels to prime

LOC_B7CE:
    INC     HL                              ; skip to flags byte (+3)
    INC     HL                              ; skip
    INC     HL                              ; point to flags byte
    LD      A, (HL)                         ; load flags
    AND     $80                             ; mask to active flag bit
    OR      $0F                             ; OR $0F: set volume = $0F (maximum / fully on)
    LD      (HL), A                         ; write primed flags back
    INC     HL                              ; advance to next channel
    DJNZ    LOC_B7CE                        ; loop 4 channels
    LD      HL, $7350                       ; HL = $7350
    LD      DE, $3F40                       ; VRAM destination = $3F40
    LD      BC, $0010                       ; 16 bytes
    CALL    VDP_WRITE_8490                  ; flush primed channel data to VRAM
    POP     AF
    POP     BC
    POP     DE
    POP     HL
    RET     
    DB      $CD, $4C, $83, $CB, $5F, $20, $03, $36
    DB      $08, $C9, $36, $60, $C9, $FA, $C1, $C9
    DB      $C5, $06, $08, $CB, $01, $F5, $CD, $0A
    DB      $98, $F1, $14, $10, $F6, $C1, $C9, $30
    DB      $17, $CD, $7A, $9E, $3A, $21, $71, $E6
    DB      $0F, $FE, $00, $3E, $10, $28, $02, $3E
    DB      $16, $32, $1E, $71, $CD, $AB, $9E, $C9
    DB      $CD, $7A, $9E, $3A, $21, $71, $FE, $00
    DB      $3E, $10, $28, $02, $3E, $16, $32, $1F
    DB      $71, $CD, $CD, $9E, $C9, $F5, $3A, $17
    DB      $71, $FE, $01, $20, $1D, $3E, $02, $32
    DB      $17, $71, $DD, $21, $CD, $70, $FD, $21
    DB      $C3, $70, $DD, $22, $18, $71, $FD, $22
    DB      $1A, $71, $FD, $7E, $03, $DD, $77, $03
    DB      $F1, $C9, $3E, $01, $32, $17, $71, $DD
    DB      $21, $C3, $70, $FD, $21, $CD, $70, $DD
    DB      $22, $18, $71, $FD, $22, $1A, $71, $FD
    DB      $7E, $03, $DD, $77, $03, $F1, $C9, $3E
    DB      $01, $CD, $67, $8C, $3A, $46, $71, $B7
    DB      $C8, $3E, $6B, $DD, $96, $05, $C8, $F5
    DB      $3E, $0B, $CD, $67, $8C, $21, $00, $3C
    DB      $01, $80, $00, $3E, $20, $CD, $A7, $84
    DB      $21, $00, $20, $01, $00, $04, $3E, $10
    DB      $CD, $A7, $84, $2A, $8B, $8A, $11, $00
    DB      $01, $ED, $4B, $8D, $8A, $CD, $90, $84
    DB      $CF, $01, $11, $46, $3C, $CD, $E4, $84
    DB      $44, $41, $4D, $41, $47, $45, $20, $52 ; "DAMAGE R"
    DB      $45, $50, $4F, $52, $54, $20, $00, $F1
    DB      $CD, $C3, $99, $3E, $20, $D3, $BE, $3E
    DB      $25, $00, $00, $00, $D3, $BE, $CD, $52
    DB      $83, $06, $FA, $C5, $C5, $CF, $01, $C1
    DB      $10, $FA, $C1, $21, $00, $01, $ED, $4B
    DB      $8D, $8A, $3E, $00, $CD, $A7, $84, $C9
    DB      $DD, $2A, $18, $71, $DD, $34, $04, $C9
    DB      $21, $00, $3C, $01, $80, $00, $3E, $20
    DB      $CD, $A7, $84, $2A, $8B, $8A, $11, $00
    DB      $01, $ED, $4B, $8D, $8A, $CD, $90, $84
    DB      $21, $00, $20, $01, $00, $04, $3E, $10
    DB      $CD, $A7, $84, $CF, $01, $11, $21, $3C
    DB      $CD, $E4, $84, $50, $4C, $41, $59, $45
    DB      $52, $20, $31, $00, $11, $41, $3C, $CD
    DB      $E4, $84, $52, $41, $4E, $4B, $20, $2D
    DB      $20, $00, $3A, $C5, $70, $CD, $8F, $99
    DB      $11, $61, $3C, $CD, $E4, $84, $53, $43
    DB      $4F, $52, $45, $20, $20, $00, $3A, $C7
    DB      $70, $CD, $C3, $99, $11, $31, $3C, $CD
    DB      $E4, $84, $50, $4C, $41, $59, $45, $52
    DB      $20, $32, $00, $11, $51, $3C, $CD, $E4
    DB      $84, $52, $41, $4E, $4B, $20, $2D, $20
    DB      $00, $3A, $CF, $70, $CD, $8F, $99, $11
    DB      $71, $3C, $CD, $E4, $84, $53, $43, $4F
    DB      $52, $45, $20, $20, $00, $3A, $D1, $70
    DB      $CD, $C3, $99, $C9, $21, $A8, $99, $FE
    DB      $01, $28, $0A, $21, $B1, $99, $FE, $02
    DB      $28, $03, $21, $BA, $99, $7E, $23, $B7
    DB      $C8, $D3, $BE, $18, $F8, $43, $4F, $52
    DB      $50, $4F, $52, $41, $4C, $00, $43, $41
    DB      $50, $54, $41, $49, $4E, $20, $00, $47
    DB      $45, $4E, $45, $52, $41, $4C, $20, $00
    DB      $D5, $1E, $00, $0E, $64, $CD, $D8, $99
    DB      $0E, $0A, $CD, $D8, $99, $1C, $0E, $01
    DB      $CD, $D8, $99, $D1, $C9, $06, $00, $91
    DB      $38, $03, $04, $18, $FA, $81, $F5, $78
    DB      $B7, $20, $07, $7B, $B7, $78, $20, $02
    DB      $F1, $C9, $C6, $30, $D3, $BE, $1C, $F1
    DB      $C9, $CD, $69, $83, $3E, $82, $D3, $BF
    DB      $3E, $81, $D3, $BF, $CD, $52, $83, $21
    DB      $00, $00, $01, $00, $18, $3E, $00, $CD
    DB      $A7, $84, $21, $00, $20, $01, $00, $18
    DB      $3E, $A0, $CD, $A7, $84, $CD, $95, $9D
    DB      $CD, $69, $83, $3E, $E2, $D3, $BF, $3E
    DB      $81, $D3, $BF, $CD, $52, $83, $3E, $0F
    DB      $CD, $67, $8C, $DD, $21, $9F, $9A, $06
    DB      $03, $C5, $CD, $A2, $9B, $CD, $DB, $9A
    DB      $01, $0E, $00, $DD, $09, $C1, $10, $F1
    DB      $06, $4B, $C5, $3E, $DC, $CD, $2E, $83
    DB      $D6, $6E, $5F, $3E, $78, $CD, $2E, $83
    DB      $D6, $5A, $57, $3E, $07, $CD, $2E, $83
    DB      $47, $0E, $00, $04, $78, $FE, $08, $38
    DB      $02, $06, $07, $D5, $C5, $CD, $4A, $9C
    DB      $C1, $D1, $28, $1B, $0C, $7A, $C6, $03
    DB      $57, $3E, $03, $CD, $2E, $83, $3D, $83
    DB      $5F, $CF, $01, $10, $E6, $C1, $10, $C2
    DB      $CD, $ED, $B6, $CD, $C0, $B7, $C9, $3E
    DB      $05, $CD, $2E, $83, $B7, $28, $EE, $7A
    DB      $D6, $05, $57, $F2, $5C, $9A, $FE, $A6
    DB      $30, $BF, $18, $E1, $4A, $A6, $F6, $0F
    DB      $09, $09, $03, $05, $FB, $0D, $01, $01
    DB      $0F, $9B, $1E, $F6, $32, $0A, $07, $06
    DB      $02, $04, $FD, $09, $01, $00, $1F, $9B
    DB      $05, $1E, $23, $05, $05, $03, $01, $02
    DB      $04, $FF, $00, $00, $50, $9B, $CD, $69
    DB      $83, $CD, $DF, $1F, $C3, $52, $83, $CD
    DB      $69, $83, $CD, $E2, $1F, $C3, $52, $83
    DB      $21, $00, $00, $06, $20, $C5, $E5, $AF
    DB      $01, $18, $01, $CD, $44, $9D, $DD, $5E
    DB      $0C, $DD, $56, $0D, $21, $52, $71, $FD
    DB      $21, $12, $72, $01, $00, $C0, $CD, $A0
    DB      $9B, $E1, $E5, $3E, $01, $01, $18, $01
    DB      $CD, $44, $9D, $E1, $11, $08, $00, $19
    DB      $C1, $10, $D2, $C9, $7E, $B1, $4F, $77
    DB      $20, $04, $FD, $36, $00, $00, $23, $FD
    DB      $23, $10, $F1, $C9, $FD, $7E, $00, $FE
    DB      $A0, $20, $0E, $79, $B7, $28, $16, $FD
    DB      $36, $00, $A6, $23, $FD, $23, $10, $EC
    DB      $C9, $7E, $B1, $4F, $77, $28, $F4, $FD
    DB      $36, $00, $60, $18, $EE, $7E, $23, $A6
    DB      $2B, $BE, $28, $E7, $4F, $10, $02, $3E
    DB      $FF, $77, $04, $18, $DA, $3E, $5F, $DD
    DB      $96, $01, $47, $0C, $7E, $23, $A6, $2B
    DB      $AE, $20, $06, $23, $FD, $23, $10, $F3
    DB      $C9, $41, $FD, $E5, $FD, $36, $00, $F0
    DB      $FD, $2B, $10, $F8, $FD, $E1, $7E, $3C
    DB      $20, $0D, $3D, $77, $FD, $36, $00, $F6
    DB      $C8, $FD, $23, $23, $A6, $18, $F4, $7E
    DB      $23, $B6, $2B, $3C, $20, $0B, $3D, $06
    DB      $0A, $E5, $23, $A6, $28, $0C, $10, $FA
    DB      $E1, $06, $0A, $7E, $23, $B6, $77, $10
    DB      $FB, $C9, $E1, $18, $D5, $D5, $C9, $1E
    DB      $80, $DD, $7E, $00, $CD, $2E, $83, $DD
    DB      $86, $01, $57, $DD, $7E, $05, $CD, $2E
    DB      $83, $4F, $DD, $7E, $03, $CD, $2E, $83
    DB      $3C, $83, $E2, $C2, $9B, $3E, $7F, $6F
    DB      $DD, $7E, $04, $CD, $2E, $83, $91, $82
    DB      $F2, $32, $9C, $DD, $CB, $02, $7E, $28
    DB      $05, $DD, $BE, $02, $30, $64, $DD, $CB
    DB      $01, $7E, $28, $05, $DD, $BE, $01, $30
    DB      $06, $DD, $7E, $01, $DD, $4E, $06, $67
    DB      $DD, $7E, $0A, $CD, $D1, $9D, $DD, $7E
    DB      $0B, $B7, $28, $0C, $E5, $21, $00, $10
    DB      $2B, $C5, $C1, $7C, $B5

; ============================================================
; TILE / SPRITE BITMAPS  ($BC00 - $BF6F)
; TMS9918A pattern table -- 8 bytes per tile (one byte per row).
; 110 tiles total.
; ============================================================
TILE_BITMAPS:
    DB      $20, $F9, $E1, $CB, $79, $20, $11, $79 ; tile 0
    DB      $DD, $BE, $07, $38, $0B, $C6, $02, $DD ; tile 1
    DB      $BE, $09, $38, $03, $DD, $7E, $09, $4F ; tile 2
    DB      $3E, $03, $CD, $2E, $83, $6F, $79, $95 ; tile 3
    DB      $4F, $F2, $2B, $9C, $DD, $7E, $08, $B9 ; tile 4
    DB      $38, $01, $4F, $7B, $FE, $7F, $C2, $B5 ; tile 5
    DB      $9B, $C9, $DD, $CB, $02, $7E, $20, $05 ; tile 6
    DB      $DD, $BE, $02, $38, $05, $DD, $4E, $07 ; tile 7
    DB      $18, $A8, $DD, $CB, $01, $7E, $28, $97 ; tile 8
    DB      $18, $A0, $C5, $7A, $C6, $08, $57, $7B ; tile 9
    DB      $D6, $03, $5F, $CD, $AC, $9D, $EB, $7D ; tile 10
    DB      $E6, $07, $4F, $7D, $E6, $F8, $6F, $E5 ; tile 11
    DB      $C5, $01, $02, $02, $AF, $CD, $44, $9D ; tile 12
    DB      $C1, $78, $DD, $21, $52, $71, $FD, $21 ; tile 13
    DB      $12, $72, $06, $00, $DD, $09, $FD, $09 ; tile 14
    DB      $47, $FD, $7E, $09, $E6, $0F, $FE, $0A ; tile 15
    DB      $28, $11, $FD, $7E, $09, $E6, $F0, $FE ; tile 16
    DB      $A0, $C4, $EB, $9C, $DD, $7E, $09, $3C ; tile 17
    DB      $C4, $EB, $9C, $FD, $7E, $19, $E6, $0F ; tile 18
    DB      $FE, $0A, $28, $11, $FD, $7E, $19, $E6 ; tile 19
    DB      $F0, $FE, $A0, $C4, $EB, $9C, $DD, $7E ; tile 20
    DB      $19, $3C, $C4, $EB, $9C, $78, $11, $3B ; tile 21
    DB      $9D, $B7, $EE, $07, $3C, $4F, $06, $09 ; tile 22
    DB      $C5, $41, $1A, $6F, $26, $00, $29, $10 ; tile 23
    DB      $FD, $CD, $FB, $9C, $DD, $E5, $FD, $E5 ; tile 24
    DB      $01, $10, $00, $DD, $09, $FD, $09, $65 ; tile 25
    DB      $CD, $FB, $9C, $FD, $E1, $DD, $E1, $C1 ; tile 26
    DB      $13, $DD, $23, $FD, $23, $10, $D9, $E1 ; tile 27
    DB      $01, $02, $02, $3E, $01, $CD, $44, $9D ; tile 28
    DB      $C1, $0C, $C9, $D1, $E1, $78, $C1, $C5 ; tile 29
    DB      $47, $79, $B7, $28, $03, $E5, $D5, $C9 ; tile 30
    DB      $C1, $AF, $C9, $7C, $B7, $C8, $FD, $7E ; tile 31
    DB      $00, $E6, $F0, $FE, $C0, $20, $08, $DD ; tile 32
    DB      $7E, $00, $B4, $DD, $77, $00, $C9, $DD ; tile 33
    DB      $7E, $00, $CD, $2B, $9D, $FE, $04, $FD ; tile 34
    DB      $7E, $00, $38, $04, $07, $07, $07, $07 ; tile 35
    DB      $E6, $0F, $F6, $C0, $FD, $77, $00, $DD ; tile 36
    DB      $74, $00, $C9, $C5, $0E, $00, $B7, $28 ; tile 37
    DB      $07, $CB, $27, $30, $F9, $0C, $18, $F6 ; tile 38
    DB      $79, $C1, $C9, $10, $10, $92, $54, $38 ; tile 39
    DB      $91, $52, $34, $18, $11, $52, $71, $EB ; tile 40
    DB      $C5, $D5, $41, $C5, $F5, $E5, $D5, $01 ; tile 41
    DB      $08, $00, $B7, $20, $36, $CD, $D2, $9A ; tile 42
    DB      $D1, $E1, $C1, $C5, $E5, $D5, $7A, $EE ; tile 43
    DB      $20, $57, $78, $01, $52, $71, $ED, $42 ; tile 44
    DB      $01, $12, $72, $09, $B7, $01, $08, $00 ; tile 45
    DB      $20, $1E, $CD, $D2, $9A, $D1, $14, $E1 ; tile 46
    DB      $01, $08, $00, $09, $F1, $C1, $10, $CB ; tile 47
    DB      $D1, $EB, $01, $08, $00, $09, $EB, $C1 ; tile 48
    DB      $10, $BE, $C9, $CD, $C9, $9A, $18, $C8 ; tile 49
    DB      $CD, $C9, $9A, $18, $E0, $06, $03, $21 ; tile 50
    DB      $00, $3C, $7D, $D3, $BF, $7C, $C6, $40 ; tile 51
    DB      $D3, $BF, $AF, $D3, $BE, $3C, $B7, $20 ; tile 52
    DB      $FA, $10, $F8, $C9, $F5, $21, $00, $00 ; tile 53
    DB      $7B, $EE, $80, $5F, $E6, $07, $47, $AB ; tile 54
    DB      $5F, $3E, $5F, $92, $57, $E6, $07, $B3 ; tile 55
    DB      $5F, $7A, $1F, $1F, $1F, $E6, $1F, $57 ; tile 56
    DB      $19, $EB, $21, $52, $71, $0E, $01, $F1 ; tile 57
    DB      $C9, $C5, $F5, $D5, $45, $4B, $CD, $51 ; tile 58
    DB      $9E, $68, $59, $44, $4A, $CD, $51, $9E ; tile 59
    DB      $60, $51, $22, $50, $71, $0E, $00, $7A ; tile 60
    DB      $BB, $38, $03, $53, $5F, $0C, $7A, $CB ; tile 61
    DB      $3F, $47, $EB, $22, $4E, $71, $D1, $2C ; tile 62
    DB      $E3, $E5, $F1, $CD, $24, $9E, $E1, $2D ; tile 63
    DB      $28, $20, $E5, $F5, $2A, $4E, $71, $78 ; tile 64
    DB      $84, $47, $95, $2A, $50, $71, $38, $09 ; tile 65
    DB      $47, $7B, $85, $5F, $7A, $84, $57, $18 ; tile 66
    DB      $E1, $79, $B7, $20, $F7, $7B, $85, $5F ; tile 67
    DB      $18, $D8, $C1, $C9, $F5, $C5, $D5, $E5 ; tile 68
    DB      $CD, $AC, $9D, $E5, $D5, $C5, $F5, $06 ; tile 69
    DB      $00, $CD, $D2, $9A, $E1, $2E, $FE, $C1 ; tile 70
    DB      $04, $CB, $0C, $CB, $0D, $10, $FA, $3A ; tile 71
    DB      $52, $71, $A5, $B4, $32, $52, $71, $D1 ; tile 72
    DB      $E1, $CD, $C9, $9A, $E1, $D1, $C1, $F1 ; tile 73
    DB      $C9, $E5, $D5, $69, $CD, $73, $9E, $EB ; tile 74
    DB      $68, $CD, $73, $9E, $AF, $ED, $52, $B4 ; tile 75
    DB      $28, $08, $47, $7D, $ED, $44, $4F, $D1 ; tile 76
    DB      $E1, $C9, $B5, $4D, $47, $28, $F8, $06 ; tile 77
    DB      $01, $18, $F4, $26, $00, $7D, $B7, $F0 ; tile 78
    DB      $25, $C9, $E5, $C5, $CD, $EF, $9E, $21 ; tile 79
    DB      $00, $20, $09, $CD, $14, $9F, $32, $21 ; tile 80
    DB      $71, $21, $00, $00, $09, $CD, $14, $9F ; tile 81
    DB      $0E, $01, $CD, $39, $9F, $A1, $3A, $21 ; tile 82
    DB      $71, $20, $05, $E6, $0F, $C1, $E1, $C9 ; tile 83
    DB      $CB, $3F, $CB, $3F, $CB, $3F, $CB, $3F ; tile 84
    DB      $C1, $E1, $C9, $C5, $E5, $CD, $EF, $9E ; tile 85
    DB      $21, $00, $20, $09, $3A, $1E, $71, $CD ; tile 86
    DB      $25, $9F, $21, $00, $00, $09, $CD, $14 ; tile 87
    DB      $9F, $0E, $01, $CD, $39, $9F, $B1, $CD ; tile 88
    DB      $25, $9F, $E1, $C1, $C9, $C5, $E5, $CD ; tile 89
    DB      $EF, $9E, $21, $00, $20, $09, $3A, $1F ; tile 90
    DB      $71, $CD, $25, $9F, $21, $00, $00, $09 ; tile 91
    DB      $CD, $14, $9F, $0E, $FE, $CD, $39, $9F ; tile 92
    DB      $A1, $CD, $25, $9F, $E1, $C1, $C9, $7B ; tile 93
    DB      $CB, $3F, $CB, $3F, $CB, $3F, $6F, $26 ; tile 94
    DB      $00, $29, $29, $29, $29, $29, $7A, $CB ; tile 95
    DB      $3F, $CB, $3F, $CB, $3F, $4F, $06, $00 ; tile 96
    DB      $09, $29, $29, $29, $7B, $E6, $07, $4F ; tile 97
    DB      $09, $44, $4D, $C9, $CD, $69, $83, $7D ; tile 98
    DB      $D3, $BF, $7C, $D3, $BF, $C5, $C1, $00 ; tile 99
    DB      $DB, $BE, $C3, $52, $83, $CD, $69, $83 ; tile 100
    DB      $F5, $7D, $D3, $BF, $7C, $C6, $40, $D3 ; tile 101
    DB      $BF, $F1, $00, $00, $D3, $BE, $C3, $52 ; tile 102
    DB      $83, $F5, $7A, $E6, $07, $47, $3E, $07 ; tile 103
    DB      $90, $28, $05, $47, $CB, $01, $10, $FC ; tile 104
    DB      $F1, $C9, $2A, $A5, $A0, $11, $00, $20 ; tile 105
    DB      $ED, $4B, $A9, $A0, $CD, $90, $84, $2A ; tile 106
    DB      $A3, $A0, $11, $00, $00, $ED, $4B, $A7 ; tile 107
    DB      $A0, $CD, $90, $84, $21, $A3, $9F, $11 ; tile 108
    DB      $00, $3C, $01, $00, $01, $CD, $90, $84 ; tile 109

; ============================================================
; ZERO PADDING  ($BF70 - $BFFF)
; ============================================================
    DB      $C9, $21, $00, $20, $01, $00, $04, $3E
    DB      $A0, $CD, $A7, $84, $21, $00, $00, $01
    DB      $00, $04, $3E, $00, $CD, $A7, $84, $21
    DB      $00, $3C, $06, $00, $7D, $CD, $69, $83
    DB      $D3, $BF, $7C, $C6, $40, $D3, $BF, $AF
    DB      $D3, $BE, $3C, $00, $00, $10, $F9, $CD
    DB      $52, $83, $C9, $01, $02, $02, $02, $02
    DB      $02, $02, $02, $02, $02, $02, $02, $02
    DB      $02, $02, $02, $02, $02, $02, $02, $02
    DB      $03, $04, $04, $04, $04, $05, $02, $02
    DB      $02, $02, $06, $07, $00, $00, $00, $08
    DB      $09, $0A, $00, $00, $00, $00, $00, $08
    DB      $09, $0A, $00, $08, $09, $09, $0A, $00
    DB      $0B, $0C, $0D, $0E, $0F, $07, $1C, $1D
    DB      $1D, $1E, $0B, $07, $1F, $20, $20, $21
    DB      $22, $24, $00, $00, $1F, $20, $20, $21
    DB      $22, $24, $00, $25, $22, $22, $26, $00
    DB      $0B, $10, $11, $12, $13, $07, $27, $28

; ---- mid-instruction label aliases (EQU) ----
LOC_8148:        EQU $8148
LOC_814A:        EQU $814A
LOC_814C:        EQU $814C
LOC_816C:        EQU $816C
LOC_816D:        EQU $816D
LOC_816F:        EQU $816F
LOC_8171:        EQU $8171
LOC_8190:        EQU $8190
LOC_8191:        EQU $8191
LOC_8193:        EQU $8193
LOC_8194:        EQU $8194
LOC_81A8:        EQU $81A8
LOC_81B6:        EQU $81B6
LOC_81B8:        EQU $81B8
LOC_81B9:        EQU $81B9
LOC_81BB:        EQU $81BB
LOC_81C2:        EQU $81C2
LOC_81C9:        EQU $81C9
LOC_81D0:        EQU $81D0
LOC_81D3:        EQU $81D3
LOC_8201:        EQU $8201
LOC_8205:        EQU $8205
LOC_8207:        EQU $8207
LOC_8209:        EQU $8209
LOC_820B:        EQU $820B
LOC_820D:        EQU $820D
LOC_820F:        EQU $820F
LOC_8211:        EQU $8211
LOC_8213:        EQU $8213
LOC_8215:        EQU $8215
LOC_8217:        EQU $8217
LOC_8219:        EQU $8219
LOC_821B:        EQU $821B
LOC_8225:        EQU $8225
LOC_8227:        EQU $8227
LOC_85C9:        EQU $85C9
LOC_85D0:        EQU $85D0
LOC_8623:        EQU $8623
LOC_8643:        EQU $8643
LOC_865B:        EQU $865B
LOC_8661:        EQU $8661
LOC_8664:        EQU $8664
LOC_86AB:        EQU $86AB
LOC_86AD:        EQU $86AD
LOC_86CD:        EQU $86CD
LOC_86E5:        EQU $86E5
LOC_86ED:        EQU $86ED
LOC_86EE:        EQU $86EE
LOC_9915:        EQU $9915
LOC_9918:        EQU $9918
LOC_9968:        EQU $9968
LOC_9997:        EQU $9997
LOC_999F:        EQU $999F
LOC_99A7:        EQU $99A7
