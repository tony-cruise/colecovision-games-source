; =============================================================
; DONKEY KONG JR. (1983) ColecoVision disassembly
; =============================================================
;
; LEGEND
;
; --- CODE SECTION ---
;
;   CART_ENTRY          line   209  cart entry point ($8055)
;   NMI                 line   235  NMI handler (full reg save + dispatch)
;   START               line   345  game initialization
;   DELAY_LOOP_8130     line   359  power-on init (timers, GAME_OPT)
;   SUB_8190            line   410  difficulty selection loop
;   SUB_81FB            line   477  per-player-turn init (lives/stage)
;   DELAY_LOOP_822C     line   499  clear score/timer display buffers
;   SUB_8247            line   536  per-level all-subsystem init
;   SUB_8295            line   587  main game loop setup
;   LOC_82B2            line   601  signal dispatch loop (infinite)
;   SUB_82F9            line   626  flip screen for 2-player swap
;   SUB_831B            line   648  2-player turn alternation
;   LOC_833A            line   667  level/life result handler
;   SUB_83E5            line   756  tile data loader engine
;   SUB_844B            line   819  BIOS object table init + screen draw
;   SUB_84CA            line   889  sprite name-table clear
;   SUB_8503            line   914  advance difficulty at stage wrap
;   SUB_8539            line   945  select vine/platform data set
;   SUB_85E2            line  1033  allocate fruit/item signals
;   SUB_8623            line  1059  render level tilemap to VRAM
;   DELAY_LOOP_8675     line  1099  post-render init (sprite tables)
;   SUB_883A            line  1337  init enemy starting positions
;   SUB_885F            line  1359  timer countdown display
;   SUB_89D6            line  1436  vine/ground collision probe
;   SUB_8A31            line  1513  get platform table by stage type
;   SUB_8B42            line  1688  Kong/Pauline subsystem
;   SUB_8BBD            line  1764  Kong animation frame update
;   LOC_8EF5            line  2209  Kong phase transition (arm left)
;   SUB_9245            line  2661  collision probe helper
;   SUB_9404            line  2843  init collision box table
;   SUB_9441            line  2868  Junior collision scan
;   SUB_9494            line  2918  abs-diff compare (+-6 range)
;   DELAY_LOOP_950B     line  2939  Junior sprite display + PUTOBJ
;   SUB_95C8            line  3000  Junior character controller
;   DELAY_LOOP_971B     line  3048  scan 12 vine-grip slots
;   SUB_9A5C            line  3171  fruit-collection timer
;   SUB_9AAE            line  3211  init vine grip offsets
;   SUB_9AEA            line  3246  init enemy/vine layout
;   SUB_9B2A            line  3270  enemy spawn / movement
;   SUB_9BC3            line  3358  init P1 vine tile scroll registers
;   DELAY_LOOP_9D75     line  3594  write vine tile rows to VRAM
;   SUB_9DA4            line  3625  copy vine scroll data to VRAM
;   SOUND_WRITE_9DE3    line  3660  bit-rotate vine tile data
;   SUB_9E29            line  3719  vertical platform collision (Jr)
;   SUB_9E58            line  3739  horizontal vine collision (Jr)
;   SUB_9EBF            line  3797  apply vine scroll to platform
;   SUB_9FF7            line  3859  enemy-die handler
;   LOC_A011            line  3872  vine sprite tile update
;   SOUND_WRITE_A042    line  3897  reset sprite write pointer
;   SOUND_WRITE_A055    line  3910  add sprite sound to queue
;   SOUND_WRITE_A06A    line  3926  read next Jr sprite from queue
;   SUB_A0F9            line  4000  sprite attr flush + proximity
;   LOC_A172            line  4082  game-over / life-lost handler
;   LOC_A17E            line  4089  level complete -- score tally
;   LOC_A1B3            line  4115  game over / no-lives path
;   SUB_A1DD            line  4134  enemy AI tick (snapjaws + birds)
;   SUB_A2C3            line  4254  abs-diff compare |A-B| < H
;   SUB_A48C            line  4471  add score + update display
;   SUB_A4EF            line  4539  BCD add score increment
;   SUB_A4FD            line  4552  select player structs IX=P1 IY=P2
;   SUB_A514            line  4562  enable NMI + init PLAY_SONGS
;   SUB_A530            line  4576  turn display off
;   SUB_A5FF            line  4628  display stage number
;   SUB_A658            line  4690  write score buffer to VRAM
;   SUB_A679            line  4712  reset sound engine
;   SUB_A681            line  4717  game-state init + stage music
;   SUB_A699            line  4738  play stage-complete jingle
;   SOUND_WRITE_A6E8    line  4805  death sound + busy-wait
;
; --- DATA SECTION ---
;
;   GAME_DATA           line  5121  animation/sprite/level data ($B054)
;   TILE_BITMAPS        line  5502  TMS9918A pattern table, 110 tiles ($BC00)
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


; BIOS DEFINITIONS **************************

BOOT_UP:                 EQU $0000         ; BOOT_UP=$0000: VDP init / soft reset entry point
BIOS_NMI:                EQU $0066         ; BIOS_NMI=$0066: Z80 NMI vector (BIOS NMI handler)
NUMBER_TABLE:            EQU $006C         ; NUMBER_TABLE=$006C: BCD digit lookup table
PLAY_SONGS:              EQU $1F61         ; PLAY_SONGS=$1F61: RST $28 target -- queue sound effect
ACTIVATEP:               EQU $1F64         ; ACTIVATEP=$1F64: activate player-sprite set (paged)
REFLECT_VERTICAL:        EQU $1F6A         ; REFLECT_VERTICAL=$1F6A: flip sprite pattern vertically
REFLECT_HORIZONTAL:      EQU $1F6D         ; REFLECT_HORIZONTAL=$1F6D: flip sprite pattern horizontally
ROTATE_90:               EQU $1F70         ; ROTATE_90=$1F70: rotate sprite pattern 90 degrees
ENLARGE:                 EQU $1F73         ; ENLARGE=$1F73: double sprite size
CONTROLLER_SCAN:         EQU $1F76         ; CONTROLLER_SCAN=$1F76: read joystick/keypad into buffer
DECODER:                 EQU $1F79         ; DECODER=$1F79: decode raw controller scan to direction bits
GAME_OPT:                EQU $1F7C         ; GAME_OPT=$1F7C: wait for 1-player or 2-player selection
LOAD_ASCII:              EQU $1F7F         ; LOAD_ASCII=$1F7F: write ASCII tile index to VRAM at HL
FILL_VRAM:               EQU $1F82         ; FILL_VRAM=$1F82: LDIR block fill to VRAM
MODE_1:                  EQU $1F85         ; MODE_1=$1F85: set VDP to mode 1 (Graphics I)
UPDATE_SPINNER:          EQU $1F88         ; UPDATE_SPINNER=$1F88: advance spinner animation frame
INIT_TABLEP:             EQU $1F8B         ; INIT_TABLEP=$1F8B: init object table (paged)
PUT_VRAMP:               EQU $1F91         ; PUT_VRAMP=$1F91: write tile to VRAM (paged)
INIT_SPR_ORDERP:         EQU $1F94         ; INIT_SPR_ORDERP=$1F94: init sprite render order (paged)
INIT_TIMERP:             EQU $1F9A         ; INIT_TIMERP=$1F9A: init timer (paged)
REQUEST_SIGNALP:         EQU $1FA0         ; REQUEST_SIGNALP=$1FA0: allocate timer signal (paged)
TEST_SIGNALP:            EQU $1FA3         ; TEST_SIGNALP=$1FA3: poll timer signal (paged)
WRITE_REGISTERP:         EQU $1FA6         ; WRITE_REGISTERP=$1FA6: write VDP register (paged)
INIT_WRITERP:            EQU $1FAF         ; INIT_WRITERP=$1FAF: init RST $18 WRITER (paged)
SOUND_INITP:             EQU $1FB2         ; SOUND_INITP=$1FB2: init sound engine (paged)
PLAY_ITP:                EQU $1FB5         ; PLAY_ITP=$1FB5: play music track (paged)
INIT_TABLE:              EQU $1FB8         ; INIT_TABLE=$1FB8: init BIOS object table
GET_VRAM:                EQU $1FBB         ; GET_VRAM=$1FBB: read bytes from VRAM
PUT_VRAM:                EQU $1FBE         ; PUT_VRAM=$1FBE: write bytes to VRAM
INIT_SPR_NM_TBL:         EQU $1FC1         ; INIT_SPR_NM_TBL=$1FC1: init sprite name table in RAM
WR_SPR_NM_TBL:           EQU $1FC4         ; WR_SPR_NM_TBL=$1FC4: flush sprite name table to VDP
INIT_TIMER:              EQU $1FC7         ; INIT_TIMER=$1FC7: init software timer
FREE_SIGNAL:             EQU $1FCA         ; FREE_SIGNAL=$1FCA: release a timer signal
REQUEST_SIGNAL:          EQU $1FCD         ; REQUEST_SIGNAL=$1FCD: allocate timer signal; returns handle in A
TEST_SIGNAL:             EQU $1FD0         ; TEST_SIGNAL=$1FD0: test signal handle in A; NZ = expired
TIME_MGR:                EQU $1FD3         ; TIME_MGR=$1FD3: decrement all active timers (called each NMI)
TURN_OFF_SOUND:          EQU $1FD6         ; TURN_OFF_SOUND=$1FD6: mute all sound channels
WRITE_REGISTER:          EQU $1FD9         ; WRITE_REGISTER=$1FD9: write VDP register (B=reg, C=val)
READ_REGISTER:           EQU $1FDC         ; READ_REGISTER=$1FDC: read VDP status register
WRITE_VRAM:              EQU $1FDF         ; WRITE_VRAM=$1FDF: write data block to VRAM
READ_VRAM:               EQU $1FE2         ; READ_VRAM=$1FE2: read data block from VRAM
INIT_WRITER:             EQU $1FE5         ; INIT_WRITER=$1FE5: init RST $18 streaming writer (HL=VRAM addr)
WRITER:                  EQU $1FE8         ; WRITER=$1FE8: RST $18 target -- stream A to VRAM at DE with length E
POLLER:                  EQU $1FEB         ; POLLER=$1FEB: scan controllers; update JOYSTICK_BUFFER + CONTROLLER_BUFFER
SOUND_INIT:              EQU $1FEE         ; SOUND_INIT=$1FEE: RST $30 target -- init/control sound engine
PLAY_IT:                 EQU $1FF1         ; PLAY_IT=$1FF1: RST $20 target -- start music track
SOUND_MAN:               EQU $1FF4         ; SOUND_MAN=$1FF4: advance sound engine one tick (called each NMI)
ACTIVATE:                EQU $1FF7         ; ACTIVATE=$1FF7: activate sprite in object table
PUTOBJ:                  EQU $1FFA         ; PUTOBJ=$1FFA: RST $10 target -- write object to sprite buffer
RAND_GEN:                EQU $1FFD         ; RAND_GEN=$1FFD: generate pseudo-random byte

; I/O PORT DEFINITIONS **********************

KEYBOARD_PORT:           EQU $0080         ; KEYBOARD_PORT=$80: keyboard/joystick select port
DATA_PORT:               EQU $00BE         ; DATA_PORT=$BE: VDP data read/write port
CTRL_PORT:               EQU $00BF         ; CTRL_PORT=$BF: VDP command/status port
JOY_PORT:                EQU $00C0         ; JOY_PORT=$C0: joystick direct read port
CONTROLLER_02:           EQU $00F5         ; CONTROLLER_02=$F5: player 2 controller register
CONTROLLER_01:           EQU $00FC         ; CONTROLLER_01=$FC: player 1 controller register
SOUND_PORT:              EQU $00FF         ; SOUND_PORT=$FF: SN76489A sound chip write port

; RAM DEFINITIONS ***************************

JOYSTICK_BUFFER:         EQU $7000         ; JOYSTICK_BUFFER=$7000: BIOS writes decoded controller state here
CONTROLLER_BUFFER:       EQU $702B         ; CONTROLLER_BUFFER=$702B: BIOS raw controller scan buffer
STACKTOP:                EQU $73B9         ; STACKTOP=$73B9: initial stack pointer

FNAME "output\DONKEY-KONG-JR-1983-NEW.ROM" ; FNAME directive: assembled output file (NEW suffix avoids overwrite)
CPU Z80                                    ; CPU Z80: tniasm directive

    ORG     $8000                          ; ORG $8000: ColecoVision ROM entry at $8000

    DW      $55AA                          ; cart magic $55AA: ColecoVision cart identifier word
    DB      $FF, $72                       ; NMI save area pointers: $72FF (IY) and $72EF (IX) alternate register save
    DB      $EF, $72                       ; pointer to JOYSTICK_BUFFER ($702B) for BIOS POLLER
    DB      $2B, $70                       ; JOYSTICK_BUFFER = $7000
    DW      JOYSTICK_BUFFER                ; DW START: cart start address patched into header
    DW      START                          ; DW START: cart start address in header
    DB      $C3, $5A, $80, $C3, $60, $80, $C3, $66; JP table at $8003..$801C: BIOS trampoline entry points
    DB      $80, $C3, $6C, $80, $C3, $72, $80, $C3; trampoline JPs continued
    DB      $78, $80, $ED, $4D, $00        ; trampoline JPs + RETN (ED 4D)

; =============================================================================
; CART_ENTRY ($8021) / NMI HANDLER
; =============================================================================
; CART_ENTRY: JP NMI + Nintendo copyright string + BIOS trampoline patches.
; NMI ($8075): saves ALL registers AF,HL,DE,BC,IX,IY + alternates (EXX).
;   $7054 bit 0 = re-entry gate:
;     if bit 0 SET:   SET bit 7 of $7054 (busy), skip to LOC_80D2 (restore+RETN)
;     if bit 0 CLEAR: LOC_80B4 -- full NMI body:
;       CALL DELAY_LOOP_80E1  update sprite-scroll gradient table at $72F1
;       CALL WR_SPR_NM_TBL    write 16 sprites to VDP name table
;       CALL PLAY_SONGS / SOUND_MAN / POLLER / TIME_MGR
;       XOR A / LD ($7058),A  clear frame event flag
;       CALL READ_REGISTER -> $7055  (VDP status, clear interrupt)
;   LOC_80D2: restore all registers, RETN.
; =============================================================================

CART_ENTRY:                                ; CART_ENTRY: JP NMI + Nintendo copyright string follows
    JP      NMI                            ; JP NMI: jump to NMI handler (cold-boot skips this)
    DB      $4E, $49, $4E, $54, $45, $4E, $44, $4F ; "NINTENDO"
    DB      $20, $4F, $46, $20, $41, $4D, $45, $52 ; " OF AMER"
    DB      $49, $43, $41, $20, $49, $4E, $43, $2F ; "ICA INC/"
    DB      $20, $44, $4F, $4E, $4B, $45, $59, $20 ; " DONKEY "
    DB      $4B, $4F, $4E, $47, $20, $4A, $52, $1E
    DB      $1F, $20, $20, $1D, $20, $31, $39, $38
    DB      $32, $2F, $31, $39, $38, $33, $DD, $21
    DB      $DF, $1F, $18, $1C, $DD, $21, $BE, $1F
    DB      $18, $16, $DD, $21, $82, $1F, $18, $10
    DB      $DD, $21, $B8, $1F, $18, $0A, $DD, $21
    DB      $D9, $1F, $18, $04, $DD, $21, $F1, $1F

SUB_807C:                                  ; SUB_807C: RST $08 trampoline; sets $7054 bit 0, swaps HL via XCHG opcode
    PUSH    AF                             ; PUSH AF: save flags before NMI trampoline setup
    LD      A, $01                         ; LD A,$01: value to set NMI-active flag
    LD      ($7054), A                     ; LD ($7054),A: set NMI-active flag
    POP     AF                             ; POP AF: restore flags
    PUSH    HL                             ; PUSH HL: save HL before swapping return address
    LD      HL, $808A                      ; LD HL,$808A: return address after trampoline
    DB      $E3                            ; DB $E3: XCHG (SP),HL - swap HL with stack top
    JP      (IX)                           ; JP (IX): dispatch to IX-pointed handler
    DB      $E5, $21, $54, $70, $CB, $86, $CB, $7E
    DB      $36, $00, $E1, $C4, $99, $80, $C9

NMI:                                       ; NMI: full register save (AF HL DE BC IX IY + alternates EXX)
    PUSH    AF                             ; save IY to RAM $7202
    PUSH    HL                             ; save IX to RAM $730B
    PUSH    DE                             ; B = 13 (slot count)
    PUSH    BC                             ; PUSH BC: save BC at NMI entry
    PUSH    IX                             ; PUSH IX: save IX at NMI entry
    PUSH    IY                             ; PUSH IY: save IY at NMI entry
    EXX                                    ; EXX: switch to alternate register set
    PUSH    HL                             ; PUSH HL: save alternate HL
    PUSH    DE                             ; PUSH DE: save alternate DE
    PUSH    BC                             ; PUSH BC: save alternate BC
    EXX                                    ; EXX: switch back to main register set
    LD      A, ($7054)                     ; LD A,($7054): read NMI-active flag
    BIT     0, A                           ; BIT 0,A: test NMI-active bit
    JR      Z, LOC_80B4                    ; JR Z,LOC_80B4: if not active, skip to NMI body
    SET     7, A                           ; SET 7,A: mark NMI reentrance (bit 7)
    LD      ($7054), A                     ; LD ($7054),A: store reentrance flag
    JR      LOC_80D2                       ; JR LOC_80D2: jump to register restore and RETN

LOC_80B4:                                  ; LOC_80B4: full NMI body -- NMI gate was clear
    CALL    DELAY_LOOP_80E1                ; CALL DELAY_LOOP_80E1: read VDP status to clear interrupt flag
    LD      A, $10                         ; call WR_SPR_NM_TBL: flush sprite buffer to VDP
    CALL    WR_SPR_NM_TBL                  ; call PLAY_SONGS (RST $28): advance sound engine
    CALL    PLAY_SONGS                     ; call SOUND_MAN: advance music sequencer
    CALL    SOUND_MAN                      ; call POLLER: scan controllers
    CALL    POLLER                         ; call TIME_MGR: tick all timer signals
    CALL    TIME_MGR                       ; XOR A: A=0 = clear frame-event flag
    XOR     A                              ; clear $7058 frame event
    LD      ($7058), A                     ; READ_REGISTER -> A (VDP status byte, clears interrupt)
    CALL    READ_REGISTER                  ; save VDP status to $7055
    LD      ($7055), A                  ; RAM $7055

LOC_80D2:                                  ; LOC_80D2: NMI register restore and return
    EXX                                    ; EXX: switch to alternate register set for restore
    POP     BC                             ; POP BC: restore alternate BC
    POP     DE                             ; POP DE: restore alternate DE
    POP     HL                             ; POP HL: restore alternate HL
    EXX                                    ; EXX: switch back to main register set
    POP     IY                             ; POP IY: restore IY
    POP     IX                             ; POP IX: restore IX
    POP     BC                             ; POP BC: restore BC
    POP     DE                             ; POP DE: restore DE
    POP     HL                             ; POP HL: restore HL
    POP     AF                             ; POP AF: restore AF
    RETN                                   ; RETN: return from NMI

DELAY_LOOP_80E1:                           ; DELAY_LOOP_80E1: sprite-scroll gradient -- update $72F1 table (16 slots)
    LD      HL, $72F1                      ; IY = sprite table $7202
    LD      B, $0E                         ; IX = scroll-target table $730B
    LD      A, ($7056)                     ; B = 12 iteration count
    OR      A                              ; LOC_80EC: loop -- read slot IY+0
    JR      NZ, LOC_8112                   ; skip inactive sprite (IY+0 == 0)
    LD      A, ($7057)                  ; RAM $7057
    CP      $02                            ; CP $02: check scroll speed lower bound
    JR      C, LOC_80F9                    ; JR C,LOC_80F9: if below 2, clamp to 2
    ADD     A, $02                         ; ADD A,$02: advance scroll step by 2

LOC_80F5:                                  ; LOC_80F5: check scroll speed upper bound
    CP      $10                            ; CP $10: compare with max speed $10
    JR      C, LOC_80FB                    ; JR C,LOC_80FB: if below max, store value

LOC_80F9:                                  ; LOC_80F9: clamp scroll speed to minimum
    LD      A, $02                         ; LD A,$02: minimum scroll value

LOC_80FB:                                  ; LOC_80FB: store scroll speed byte
    LD      (HL), A                        ; LD (HL),A: write scroll value to table
    INC     A                              ; INC A: increment speed for next entry
    INC     HL                             ; INC HL: advance table pointer
    DJNZ    LOC_80F5                       ; DJNZ LOC_80F5: loop for all 14 entries
    LD      A, ($7057)                     ; LD A,($7057): read fine scroll counter
    ADD     A, $02                         ; ADD A,$02: advance fine scroll
    CP      $10                            ; CP $10: check against max
    JR      C, LOC_810B                    ; JR C,LOC_810B: if below max, store
    LD      A, $02                         ; LD A,$02: reset fine scroll to min

LOC_810B:                                  ; LOC_810B: store updated fine scroll
    LD      ($7057), A                  ; RAM $7057
    LD      ($7056), A                  ; RAM $7056
    RET                                    ; RET: return from LOC_810B fine-scroll write

LOC_8112:                                  ; LOC_8112: restore all regs + RETN from NMI
    LD      A, $0F                         ; LD A,$0F: start value for descending fill

LOC_8114:                                  ; LOC_8114: fill RAM table with descending values $0F...
    LD      (HL), A                        ; LD (HL),A: write current value to table
    INC     HL                             ; INC HL: advance pointer
    DEC     A                              ; DEC A: decrement value
    DJNZ    LOC_8114                       ; DJNZ LOC_8114: loop for B entries
    XOR     A                              ; XOR A: A = 0
    LD      ($7056), A                     ; LD ($7056),A: clear scroll enable flag
    RET                                    ; RET: return from scroll table init

; =============================================================================
; START ($8021+) -- POWER-ON BOOT ENTRY
; =============================================================================
; Sets SP = $73C2, then falls through to the game init sequence:
;   LOC_8121: CALL DELAY_LOOP_8130   full one-time game init
;   LOC_8124: CALL SUB_81FB          level/lives setup
;   LOC_8127: CALL SUB_8247          all-subsystem per-level init
;             CALL SUB_8295          main game loop setup, enters LOC_82B2
;             JP   LOC_833A          level-end / game-over handler
; DELAY_LOOP_8130 ($8130): full power-on init:
;   SUB_8372: zero RAM JOYSTICK_BUFFER-$7001
;   INIT_TIMER $72D1, init sprite-scroll table $72EF
;   POLLER, GAME_OPT (player count + skill from option screen)
;   SUB_A679 + SUB_A514: init IX/IY player-data pointers
;   Sets $7284 (skill), $7285 (player count), $7287
;   JP SUB_81D5 -> RST $28 (PLAY_SONGS) to start music
; =============================================================================

START:                                     ; START: init stack pointer $73C2
    LD      SP, $73C2                      ; LD SP,$73C2: set stack

LOC_8121:                                  ; LOC_8121: outer game loop (1-player/2-player alternation)
    CALL    DELAY_LOOP_8130                ; CALL DELAY_LOOP_8130: one-time power-on init

LOC_8124:                                  ; LOC_8124: per-player-turn loop entry
    CALL    SUB_81FB                       ; CALL SUB_81FB: init lives / stage state for player

LOC_8127:                                  ; LOC_8127: per-level loop -- init level, run game, check result
    CALL    SUB_8247                       ; CALL SUB_8247: all-subsystem level init
    CALL    SUB_8295                       ; CALL SUB_8295: main game loop (runs until life lost)
    JP      LOC_833A                       ; JP LOC_833A: level-end check

DELAY_LOOP_8130:                           ; DELAY_LOOP_8130: power-on init -- clear signals, init timers, call GAME_OPT
    CALL    SUB_8372                       ; CALL SUB_8372: clear joystick buffer
    LD      HL, $72D1                      ; HL = $72D1: timer base
    LD      DE, BOOT_UP                    ; DE = BOOT_UP: timer period
    CALL    INIT_TIMER                     ; CALL INIT_TIMER: start master timer
    LD      HL, $72EF                      ; HL = $72EF: sprite name table RAM
    LD      B, $10                         ; B = 16: 16 sprite slots
    XOR     A                              ; XOR A: start ascending fill from 0
                                           ; LOC_8142: fill $72EF..$72FE with 0..15
LOC_8142:                                  ; LOC_8142: ascending fill of RAM block
    LD      (HL), A                        ; LD (HL),A: write value to RAM
    INC     HL                             ; INC HL: advance pointer
    INC     A                              ; INC A: increment fill value
    DJNZ    LOC_8142                       ; DJNZ LOC_8142: loop B times
    LD      HL, $72FF                      ; HL = $72FF: sprite jump table RAM
    LD      DE, $0004                      ; DE = 4: stride
    LD      B, $10                         ; B = 16

LOC_814F:                                  ; LOC_814F: fill $72FF..$733F with $C3 (JP opcode) x16
    LD      (HL), $C3                      ; LD (HL),$C3: write JP opcode into sprite jump-table slot
    ADD     HL, DE                         ; ADD HL,DE: advance pointer by 4-byte stride
    DJNZ    LOC_814F                       ; LD A,$9B: unused JP target padding
    LD      A, $9B                         ; patch Kong entity area at ($8008)
    LD      HL, ($8008)                    ; LD (HL),A: write byte
    LD      (HL), A                        ; LD (HL),A: write sprite Y to sprite table
    INC     HL                             ; INC HL: advance to next sprite slot
    LD      (HL), A                        ; LD (HL),A: write sprite Y to second field
    CALL    POLLER                         ; CALL POLLER: read controllers
    CALL    GAME_OPT                       ; CALL GAME_OPT: 1-player/2-player title screen
    CALL    SUB_A679                       ; CALL SUB_A679: reset sound engine
    CALL    SUB_A514                       ; CALL SUB_A514: enable NMI
    LD      B, $01                         ; B=1 C=9: difficulty range (1..9)
    LD      C, $09                         ; LD C,$09: upper difficulty bound = 9
    CALL    SUB_8190                       ; CALL SUB_8190: read difficulty selection from joystick
    PUSH    AF                             ; PUSH AF: save difficulty level
    CALL    SUB_A4FD                       ; CALL SUB_A4FD: set IX=P1 IY=P2 (or swap for P2 turn)
    POP     AF                             ; POP AF: restore difficulty level from stack
    LD      HL, $7285                      ; HL = $7285: 2-player flag
    CP      $05                            ; CP $05: check difficulty >= 5
    LD      (HL), $01                      ; LD (HL),$01: 1-player mode
    JR      C, LOC_8181                    ; JR C,LOC_8181: skip if below 5
    LD      (HL), $02                      ; LD (HL),$02: 2-player mode
    SUB     $04                            ; SUB $04: map difficulty 5-9 to 1-5

LOC_8181:                                  ; LOC_8181: store difficulty
    LD      ($7284), A                     ; LD ($7284),A: save difficulty $7284
    LD      (IX+3), A                      ; LD (IX+3),A: P1 difficulty
    LD      (IY+3), A                      ; LD (IY+3),A: P2 difficulty
    LD      ($7287), A                     ; LD ($7287),A: current stage display value
    JP      SUB_81D5                       ; JP SUB_81D5: show title / start music

SUB_8190:                                  ; SUB_8190: spin on joystick input until direction pressed; A=direction
    LD      ($705B), BC                    ; LD ($705B),BC: store clamp range

LOC_8194:                                  ; LOC_8194: outer retry loop
    LD      HL, $0380                      ; HL = $0380: frame counter
    LD      ($705E), HL                    ; LD ($705E),HL: reset frame timeout

LOC_819A:                                  ; LOC_819A: inner frame loop
    LD      HL, $705D                      ; HL = $705D: timeout countdown
    DEC     (HL)                           ; DEC (HL): decrement lo byte
    JR      NZ, LOC_81A8                   ; JR NZ,LOC_81A8: if timer not expired, skip
    INC     HL                             ; INC HL: advance to next timer byte
    DEC     (HL)                           ; DEC (HL): decrement second timer
    JR      NZ, LOC_81A8                   ; JR NZ,LOC_81A8: if second timer not zero, skip
    INC     HL                             ; INC HL: advance to third timer byte
    DEC     (HL)                           ; DEC (HL): decrement third timer
    JR      Z, LOC_81CA                    ; JR Z,LOC_81CA: if third timer expired, handle completion

LOC_81A8:                                  ; LOC_81A8: normal frame -- call POLLER
    CALL    POLLER                         ; CALL POLLER
    LD      BC, ($705B)                    ; BC = ($705B): restore range
    LD      A, ($7006)                     ; A = $7006: player 1 direction
    CALL    SUB_81CF                       ; CALL SUB_81CF: check if in range; return if match
    LD      A, ($700B)                     ; A = $700B: player 2 direction
    CALL    SUB_81CF                       ; CALL SUB_81CF
    LD      A, ($7285)                     ; A = ($7285): 2-player flag
    DEC     A                              ; DEC A: 1-player?
    JR      Z, LOC_819A                    ; JR Z,LOC_819A: single-player -- just loop
    LD      A, ($71DB)                     ; A = ($71DB): 2-player display toggle
    DEC     A                              ; DEC A: check if active
    CALL    Z, SUB_81DE                    ; CALL Z,SUB_81DE: swap player display
    JR      LOC_819A                       ; JR LOC_819A

LOC_81CA:                                  ; LOC_81CA: timeout -- restart init sequence
    CALL    SUB_81D5                       ; CALL SUB_81D5: stop music
    JR      LOC_8194                       ; JR LOC_8194: retry

SUB_81CF:                                  ; SUB_81CF: clamp check A in [B,C); RET if out of range, otherwise POP and RET
    CP      B                              ; CP B: A >= B?
    RET     C                              ; RET C: A < B -- not in range
    CP      C                              ; CP C: A < C?
    RET     NC                             ; RET NC: A >= C -- not in range (fall through = in range)
    POP     HL                             ; POP HL: discard return addr (tail-return to caller of caller)
    RET                                    ; RET

SUB_81D5:                                  ; SUB_81D5: stop music / hide all sprites (RST $28 with B=7 C=1)
    CALL    SUB_A541                       ; CALL SUB_A541
    LD      B, $07                         ; B=7 C=1
    LD      C, $01                         ; LD C,$01: sound channel 1
    RST     $28                            ; RST $28: BIOS sound write
    RET                                    ; RET: return from SUB_81D5

SUB_81DE:                                  ; SUB_81DE: 2-player display timer -- swap stage/lives display every 10s
    LD      HL, $7060                      ; HL = $7060: display toggle countdown
    DEC     (HL)                           ; DEC (HL)
    RET     NZ                             ; RET NZ: not yet
    LD      HL, $7061                      ; HL = $7061: timer reload
    DEC     (HL)                           ; DEC (HL)
    RET     NZ                             ; RET NZ
    LD      (HL), $0A                      ; LD (HL),$0A: reload 10 ticks
    LD      A, ($7286)                     ; A = ($7286): current player (1 or 2)
    XOR     $03                            ; XOR $03: toggle 1<->2
    LD      ($7286), A                     ; LD ($7286),A: store player
    CALL    SUB_A658                       ; CALL SUB_A658: update score display
    CALL    SUB_A60C                       ; CALL SUB_A60C: update lives display
    JP      SUB_A5FF                       ; JP SUB_A5FF: update stage number display

SUB_81FB:                                  ; SUB_81FB: per-player-turn init -- set lives IX+0/IY+0 and stage IX+2/IY+2
    LD      A, $01                         ; LD A,$01
    LD      ($7286), A                     ; LD ($7286),A: start with player 1
    CALL    SUB_A4FD                       ; CALL SUB_A4FD: IX=P1 IY=P2
    LD      A, ($7284)                     ; A = ($7284): difficulty
    DEC     A                              ; DEC A: difficulty == 1?
    JR      Z, LOC_8213                    ; JR Z,LOC_8213
    LD      (IX+0), $03                    ; LD (IX+0),$03: P1 lives = 3
    LD      (IY+0), $03                    ; LD (IY+0),$03: P2 lives = 3
    JR      LOC_821B                       ; JR LOC_821B

LOC_8213:                                  ; LOC_8213: difficulty 1 = 5 lives each
    LD      (IX+0), $05                    ; LD (IX+0),$05
    LD      (IY+0), $05                    ; LD (IY+0),$05

LOC_821B:                                  ; LOC_821B: set stage 1 for both players
    LD      (IX+2), $01                    ; LD (IX+2),$01: P1 stage = 1
    LD      (IY+2), $01                    ; LD (IY+2),$01: P2 stage = 1
    CALL    DELAY_LOOP_822C                ; CALL DELAY_LOOP_822C: clear score/timer display RAM
    CALL    SUB_844B                       ; CALL SUB_844B: init BIOS object table + draw initial screen
    JP      LOC_8383                       ; JP LOC_8383: load level tiles

DELAY_LOOP_822C:                           ; DELAY_LOOP_822C: clear score and timer display buffers to ASCII 0
    LD      HL, $7298                      ; HL = $7298: P1 score buffer
    LD      B, $06                         ; B = 6
    CALL    DELAY_LOOP_8241                ; CALL DELAY_LOOP_8241: fill 6 bytes with $30
    LD      B, $06                         ; B = 6
    LD      HL, $72A5                      ; HL = $72A5: P2 score buffer
    CALL    DELAY_LOOP_8241                ; CALL DELAY_LOOP_8241
    LD      B, $04                         ; B = 4
    LD      HL, $728A                      ; HL = $728A: timer buffer

DELAY_LOOP_8241:                           ; DELAY_LOOP_8241: fill B bytes at HL with $30 (ASCII 0)
    LD      (HL), $30                      ; LD (HL),$30: write ASCII 0
    INC     HL                             ; INC HL
    DJNZ    DELAY_LOOP_8241                ; DJNZ DELAY_LOOP_8241
    RET                                    ; RET: return from DELAY_LOOP_8241 score digit fill

; =============================================================================
; SUB_8247 ($8247) -- PER-LEVEL ALL-SUBSYSTEM INIT
; =============================================================================
; Called from LOC_8127 at the start of each level / player turn.
; Sequences all major subsystems to build the level state:
;   SUB_A679 + SUB_A514   player sprite/position init
;   SUB_A549              VDP sprite attribute clear
;   SUB_8286              level scroll data (stage table at $8B01)
;   SUB_A541              VDP display config + sprite mode
;   SUB_84CA              clear sprite name-table entries (BC=BOOT_UP)
;   SUB_85E2              fruit/item placement on screen
;   SUB_A681              game-state init ($7062/$7063 flags)
;   SUB_8623              screen tile renderer (draws level map to VRAM)
;   DELAY_LOOP_8675       VDP frame sync
;   SUB_883A + SUB_9AEA   enemy/vine placement
;   SUB_A5FF + SUB_A60C + SUB_A636 + SUB_A658 + SUB_A66E  object-pool setup
;   SUB_9404              collision-box table init
;   SUB_A27B              player-visible sprite init
;   JP SUB_A549           final VDP sprite flush
; =============================================================================

SUB_8247:                                  ; SUB_8247: per-level all-subsystem init (called from LOC_8127)
    CALL    SUB_A679                       ; CALL SUB_A679: reset sound engine
    CALL    SUB_A514                       ; CALL SUB_A514: enable NMI + reinit PLAY_SONGS
    CALL    SUB_A549                       ; CALL SUB_A549: VDP sprite attribute clear
    CALL    SUB_8286                       ; CALL SUB_8286: load stage scroll data
    CALL    SUB_A541                       ; CALL SUB_A541: VDP display config
    LD      BC, BOOT_UP                    ; BC = BOOT_UP: sprite name table init value
    CALL    SUB_84CA                       ; CALL SUB_84CA: clear sprite name table
    CALL    SUB_85E2                       ; CALL SUB_85E2: place fruit/items on screen
    CALL    SUB_A681                       ; CALL SUB_A681: game-state init
    CALL    SUB_8623                       ; CALL SUB_8623: render level tilemap to VRAM
    CALL    DELAY_LOOP_8675                ; CALL DELAY_LOOP_8675: VDP frame sync + clear sprite tables
    CALL    SUB_883A                       ; CALL SUB_883A: init enemy/vine positions
    CALL    SUB_9AEA                       ; CALL SUB_9AEA: init vine layout + enemy table
    CALL    SUB_A5FF                       ; CALL SUB_A5FF: display stage number
    CALL    SUB_A60C                       ; CALL SUB_A60C: display lives
    CALL    SUB_A636                       ; CALL SUB_A636: display 1-UP/2-UP indicator
    CALL    SUB_A658                       ; CALL SUB_A658: write player score to screen
    CALL    SUB_A66E                       ; CALL SUB_A66E: write timer to screen
    CALL    SUB_9404                       ; CALL SUB_9404: init collision box table
    CALL    SUB_A27B                       ; CALL SUB_A27B: init player-visible sprite slots
    JP      SUB_A549                       ; JP SUB_A549: final VDP sprite flush

SUB_8286:                                  ; SUB_8286: load stage scroll data from table at $8B01
    LD      A, ($7286)                     ; A = ($7286): player 1 or 2
    DEC     A                              ; DEC A
    LD      HL, $8B01                      ; HL = $8B01: stage scroll table
    LD      B, $32                         ; B = $32 ($50): scroll distance
    JR      NZ, LOC_8292                   ; JR NZ,LOC_8292: player 2 -- use B=50
    DEC     B                              ; DEC B: player 1 -- B=49

LOC_8292:                                  ; LOC_8292
    JP      LOC_8AB3                       ; JP LOC_8AB3: scroll in stage data via RST $08

; =============================================================================
; SUB_8295 ($8295) -- MAIN GAME LOOP SETUP / LOC_82B2 SIGNAL DISPATCH LOOP
; =============================================================================
; SUB_8295: saves SP -> $7059, calls SUB_A681 (game-state), writes VDP mode
;   ($2008/$40), inits $728E/$7062/$7063, then falls into LOC_82B2.
; LOC_82B2 ($82B2): infinite signal dispatch loop (runs until lives lost):
;   TEST_SIGNAL $72CB -> CALL NZ SUB_95C8  Junior character controller
;   TEST_SIGNAL $7081 -> CALL NZ SUB_8B42  Donkey Kong animations + drops
;   CALL SUB_A1DD                          enemy AI tick (snapjaws, birds)
;   TEST_SIGNAL $72CA -> CALL NZ SUB_9B2A  enemy spawn / movement
;   TEST_SIGNAL $72CC -> CALL NZ SUB_885F  platform/vine collision check
;   TEST_SIGNAL $72CF -> CALL NZ SUB_82F9  screen-content flip (2-player)
;   TEST_SIGNAL $72D0 -> CALL NZ SUB_831B  2-player turn alternation
;   CALL SUB_A0F9                          sprite attribute flush to VDP
;   JR LOC_82B2 (loop forever)
; =============================================================================

SUB_8295:                                  ; SUB_8295: main game loop setup -- save SP, set VDP mode, init flags, fall to LOC_82B2
    LD      HL, BOOT_UP                    ; HL = BOOT_UP: HL = 0
    ADD     HL, SP                         ; ADD HL,SP: HL = SP value
    LD      ($7059), HL                    ; LD ($7059),HL: save SP for emergency restore (LOC_A13A)
    CALL    SUB_A681                       ; CALL SUB_A681: game-state init
    LD      HL, $2008                      ; HL=$2008: VDP reg2 nameTable at $2000
    LD      A, $40                         ; A=$40: VDP reg1 display ON
    CALL    SUB_8330                       ; CALL SUB_8330: write VDP register pair
    XOR     A                              ; XOR A
    LD      ($728E), A                     ; LD ($728E),A: clear collision-detect flag
    INC     A                              ; INC A
    LD      ($7062), A                     ; LD ($7062),A: set screen-content flag = 1
    LD      ($7063), A                     ; LD ($7063),A: set 2P-turn flag = 1

LOC_82B2:                                  ; LOC_82B2: infinite signal dispatch loop -- runs until LOC_A172 pops SP
    LD      A, ($72CB)                     ; A = $72CB: Junior character signal
    CALL    TEST_SIGNAL                    ; CALL TEST_SIGNAL
    CALL    NZ, SUB_95C8                   ; CALL NZ,SUB_95C8: run Junior player controller
    LD      A, ($7081)                     ; A = $7081: Kong signal
    CALL    TEST_SIGNAL                    ; CALL TEST_SIGNAL
    CALL    NZ, SUB_8B42                   ; CALL NZ,SUB_8B42: run Kong/Pauline animation + drop barrels
    CALL    SUB_A1DD                       ; CALL SUB_A1DD: enemy AI tick (snapjaws + birds)
    LD      A, ($72CA)                     ; A = $72CA: enemy spawn signal
    CALL    TEST_SIGNAL                    ; CALL TEST_SIGNAL
    CALL    NZ, SUB_9B2A                   ; CALL NZ,SUB_9B2A: enemy spawn / movement update
    LD      A, ($72CC)                     ; A = $72CC: platform/vine collision signal
    CALL    TEST_SIGNAL                    ; CALL TEST_SIGNAL
    CALL    NZ, SUB_885F                   ; CALL NZ,SUB_885F: timer countdown update
    LD      A, ($72CF)                     ; A = $72CF: screen flip signal (2-player)
    CALL    TEST_SIGNAL                    ; CALL TEST_SIGNAL
    CALL    NZ, SUB_82F9                   ; CALL NZ,SUB_82F9: flip screen content for player swap
    LD      A, ($72D0)                     ; A = $72D0: 2-player alternation signal
    CALL    TEST_SIGNAL                    ; CALL TEST_SIGNAL
    CALL    NZ, SUB_831B                   ; CALL NZ,SUB_831B: 2-player turn alternation
    CALL    SUB_A0F9                       ; CALL SUB_A0F9: flush sprite attribute buffer to VDP
    JR      LOC_82B2                       ; JR LOC_82B2: loop forever
    DB      $3A, $06, $70, $FE, $02, $D0, $3C, $E1
    DB      $C9

SUB_82F9:                                  ; SUB_82F9: flip screen display content for 2-player swap
    LD      A, ($728A)                     ; A = ($728A): stage value
    AND     $0F                            ; AND $0F: mask low nibble
    RET     NZ                             ; RET NZ: only flip on stage boundary
    LD      BC, $7062                      ; BC = $7062: screen-content flag
    LD      HL, $1877                      ; HL = $1877: VRAM address for score display
    LD      A, (BC)                        ; A = (BC): current flag
    XOR     $01                            ; XOR $01: toggle
    JP      NZ, LOC_8311                   ; JP NZ,LOC_8311: branch on new flag value
    LD      (BC), A                        ; LD (BC),A: write value to VRAM via BC pointer
    LD      DE, $0005                      ; LD DE,$0005: VRAM stride (5 bytes per row offset)
    RST     $18                            ; RST $18: BIOS VRAM fill/copy
    RET                                    ; RET: return from branch

LOC_8311:                                  ; LOC_8311: alternate VRAM write path
    LD      (BC), A                        ; LD (BC),A: write value to VRAM
    LD      BC, $0005                      ; LD BC,$0005: count/stride for copy
    DB      $EB                            ; DB $EB: EX DE,HL - swap DE/HL
    LD      HL, $8335                      ; LD HL,$8335: source data pointer
    RST     $08                            ; RST $08: BIOS LDIR-style block copy
    RET                                    ; RET: return

SUB_831B:                                  ; SUB_831B: 2-player turn alternation -- swap VDP display colors
    LD      A, ($7288)                     ; A = ($7288): difficulty / player count
    DEC     A                              ; DEC A
    RET     Z                              ; RET Z: 1-player -- nothing to do
    LD      BC, $7063                      ; BC = $7063: 2P turn flag
    LD      HL, $2008                      ; HL = $2008: VDP nametable address reg
    LD      A, (BC)                        ; A = (BC): current turn
    XOR     $01                            ; XOR $01: toggle P1/P2 turn
    LD      (BC), A                        ; LD (BC),A
    LD      A, $40                         ; A = $40: color palette A
    JR      NZ, SUB_8330                   ; JR NZ,SUB_8330
    LD      A, $D0                         ; LD A,$D0: color palette B

SUB_8330:                                  ; SUB_8330: write VDP register pair (HL=addr, A=val) via RST $18
    LD      DE, $0010                      ; LD DE,$0010: 1 byte to VRAM
    RST     $18                            ; RST $18: WRITER -- write A to VRAM HL
    RET                                    ; RET: return from SUB_8330 VDP byte write
    DB      $24, $25, $26, $27, $28     ; "$%&'("

LOC_833A:                                  ; LOC_833A: level/life result handler -- A=0 level complete, else check lives
    PUSH    AF                             ; PUSH AF: save result
    CALL    DELAY_LOOP_84AD                ; CALL DELAY_LOOP_84AD: flush sprite name table to VDP
    POP     AF                             ; POP AF
    DEC     A                              ; DEC A: A was 0? (level complete)
    JP      Z, LOC_A17E                    ; JP Z,LOC_A17E: yes -- level complete path
    CALL    SUB_A4FD                       ; CALL SUB_A4FD: IX=current player
    LD      A, ($7285)                     ; A = ($7285): 2-player mode flag
    CP      $02                            ; CP $02
    JR      Z, LOC_8356                    ; JR Z,LOC_8356: 2-player turn swap

LOC_834D:                                  ; LOC_834D: decrement lives; if zero: game over
    DEC     (IX+0)                         ; DEC (IX+0): lives--
    JP      NZ, LOC_8127                   ; JP NZ,LOC_8127: still alive -- play level again
    JP      LOC_A1B3                       ; JP LOC_A1B3: no lives -- game over

LOC_8356:                                  ; LOC_8356: 2-player -- check other player lives
    LD      A, (IY+0)                      ; A = (IY+0): other player lives
    OR      A                              ; OR A
    JR      Z, LOC_834D                    ; JR Z,LOC_834D: other player also dead -- game over
    DEC     (IX+0)                         ; DEC (IX+0): this player lives--
    CALL    SUB_8A72                       ; CALL SUB_8A72: check if other player should take over
    LD      A, ($7286)                     ; A = ($7286): current player
    DEC     A                              ; DEC A
    LD      A, $02                         ; A = $02
    JR      Z, LOC_836C                    ; JR Z,LOC_836C: player 1 finished -- switch to P2
    LD      A, $01                         ; LD A,$01

LOC_836C:                                  ; LOC_836C: store new player number
    LD      ($7286), A                     ; LD ($7286),A: set active player
    JP      LOC_8127                       ; JP LOC_8127: replay level for new player

SUB_8372:                                  ; SUB_8372: clear JOYSTICK_BUFFER and adjacent RAM (LDIR, C=L B=H)
    LD      HL, $8FFF                      ; HL = $8FFF
    ADD     HL, SP                         ; ADD HL,SP: HL = SP + $8FFF
    LD      C, L                           ; C = L
    LD      B, H                           ; B = H
    LD      HL, JOYSTICK_BUFFER            ; HL = JOYSTICK_BUFFER: $7000
    LD      DE, $7001                      ; DE = $7001
    XOR     A                              ; XOR A
    LD      (HL), A                        ; LD (HL),A: zero first byte
    LDIR                                   ; LDIR: fill BC bytes from $7001 copying $7000
    RET                                    ; RET: return from SUB_8372 JOYSTICK_BUFFER zero-fill

; =============================================================================
; LOC_8383 ($8383) / SUB_83E5 ($83E5) -- LEVEL TILE LOADER
; =============================================================================
; LOC_8383: called from LOC_821B (after lives/level init) to load all 7
;   tile-data blocks for the current stage. Loads IY/IX pointer pairs and
;   a VRAM base address HL, then JP SUB_83E5 for each block:
;   blocks cover $0000/$0800/$1000/$2000/$2800/$3000/$3800 in VRAM.
; SUB_83E5 ($83E5): iterates through a tile-data sequence:
;   $7064 = IX ptr, $7066 = IY ptr, $7068 = HL (VRAM offset)
;   For each entry (IX+0 non-zero):
;     bit 7 SET:  RST $18 (WRITER) -- write 1 byte directly to VRAM addr IY
;     bit 7 CLEAR: RST $08 (frame sync) -- timed write, BC count bytes
;   Advances IX, IY, HL by entry-size on each iteration.
; =============================================================================

LOC_8383:                                  ; LOC_8383: level tile loader -- load 7 VRAM blocks for current stage
    LD      IY, $AB63                      ; IY=$AB63 IX=$ADFE: block 0 data pointers
    LD      IX, $ADFE                      ; LD IX,$ADFE: sprite/tile data pointer for set 0
    LD      HL, BOOT_UP                    ; LD HL,BOOT_UP: VRAM base address
    CALL    SUB_83E5                       ; CALL SUB_83E5: load tile set into VRAM
    LD      IY, $AE75                      ; LD IY,$AE75: tile data segment 1 start
    LD      IX, $B066                      ; LD IX,$B066: tile data segment 1 end
    LD      HL, $0800                      ; LD HL,$0800: VRAM page $0800
    CALL    SUB_83E5                       ; CALL SUB_83E5: load tile set 1 into VRAM
    LD      IY, $B0BF                      ; LD IY,$B0BF: tile data segment 2 start
    LD      IX, $B1BC                      ; LD IX,$B1BC: tile data segment 2 end
    LD      HL, $1000                      ; LD HL,$1000: VRAM page $1000
    CALL    SUB_83E5                       ; CALL SUB_83E5: load tile set 2 into VRAM
    LD      IY, $B1F3                      ; LD IY,$B1F3: tile data segment 3 start
    LD      IX, $B2AA                      ; LD IX,$B2AA: tile data segment 3 end
    LD      HL, $2000                      ; LD HL,$2000: VRAM page $2000
    CALL    SUB_83E5                       ; CALL SUB_83E5: load tile set 3 into VRAM
    LD      IY, $B32B                      ; LD IY,$B32B: tile data segment 4 start
    LD      IX, $B39E                      ; LD IX,$B39E: tile data segment 4 end
    LD      HL, $2800                      ; LD HL,$2800: VRAM page $2800
    CALL    SUB_83E5                       ; CALL SUB_83E5: load tile set 4 into VRAM
    LD      IY, $B3EE                      ; LD IY,$B3EE: tile data segment 5 start
    LD      IX, $B46E                      ; LD IX,$B46E: tile data segment 5 end
    LD      HL, $3000                      ; LD HL,$3000: VRAM page $3000
    CALL    SUB_83E5                       ; CALL SUB_83E5: load tile set 5 into VRAM
    LD      IY, $B4BF                      ; LD IY,$B4BF: tile data segment 6 start
    LD      IX, $BA70                      ; LD IX,$BA70: tile data segment 6 end
    LD      HL, $3800                      ; LD HL,$3800: VRAM page $3800
    JP      SUB_83E5                       ; JP SUB_83E5: load last block and return

SUB_83E5:                                  ; SUB_83E5: tile-data loader engine -- iterate tile entries at IX; write via IY/RST
    LD      ($7064), IX                    ; LD ($7064),IX: save tile-descriptor pointer
    LD      ($7066), IY                    ; LD ($7066),IY: save tile-data pointer
    LD      ($7068), HL                    ; LD ($7068),HL: save VRAM base address

LOC_83F0:                                  ; LOC_83F0: main loader loop
    LD      A, (IX+0)                      ; A = (IX+0): descriptor byte
    OR      A                              ; OR A: zero = end of block
    RET     Z                              ; RET Z: end of block
    PUSH    IX                             ; PUSH IX
    PUSH    AF                             ; PUSH AF: save descriptor byte before mode test
    AND     $80                            ; AND $80: test bit 7 (write-mode flag)
    JR      Z, LOC_8418                    ; JR Z,LOC_8418: bit 7 clear = RST $08 timed LDIR write
    POP     AF                             ; POP AF
    PUSH    AF                             ; PUSH AF
    AND     $7F                            ; AND $7F: strip bit 7 for byte count
    LD      E, A                           ; LD E,A
    LD      D, $00                         ; LD D,$00
    LD      IY, ($7066)                    ; IY = ($7066)
    LD      A, (IY+0)                      ; A = (IY+0): source byte
    LD      HL, ($7068)                    ; HL = ($7068): VRAM dest
    RST     $18                            ; RST $18: WRITER -- write 1 byte at HL
    LD      HL, ($7066)                    ; HL = ($7066)
    INC     HL                             ; INC HL: advance tile-data pointer
    LD      ($7066), HL                    ; LD ($7066),HL
    POP     AF                             ; POP AF: restore descriptor after indirect tile write
    JR      LOC_8437                       ; JR LOC_8437: advance VRAM pointer

LOC_8418:                                  ; LOC_8418: RST $08 timed block write path
    POP     AF                             ; POP AF
    PUSH    AF                             ; PUSH AF: save descriptor before RST $08 timed LDIR write
    AND     $7F                            ; AND $7F: byte count
    LD      C, A                           ; C = A
    LD      B, $00                         ; B = $00: BC = count
    LD      HL, ($7066)                    ; HL = ($7066): source pointer
    LD      DE, ($7068)                    ; DE = ($7068): VRAM base
    PUSH    HL                             ; PUSH HL
    RST     $08                            ; RST $08: timed write BC bytes from HL to VRAM DE
    POP     HL                             ; POP HL: restore HL (VRAM address)
    POP     AF                             ; POP AF: restore AF (flags)
    PUSH    AF                             ; PUSH AF: re-save AF for later use
    AND     $7F                            ; AND $7F: mask out high bit of offset
    ADD     A, L                           ; ADD A,L: add masked offset to HL low
    LD      L, A                           ; LD L,A: HL.L = adjusted address low
    LD      A, $00                         ; LD A,$00: clear A for ADC carry
    ADC     A, H                           ; ADC A,H: HL.H += carry
    LD      H, A                           ; LD H,A: store adjusted high byte
    LD      ($7066), HL                    ; LD ($7066),HL: save adjusted VRAM write address
    POP     AF                             ; POP AF: restore AF

LOC_8437:                                  ; LOC_8437: second VRAM address computation
    LD      HL, ($7068)                    ; LD HL,($7068): load second VRAM base pointer
    AND     $7F                            ; AND $7F: mask offset
    ADD     A, L                           ; ADD A,L: add to low byte
    LD      L, A                           ; LD L,A: store result
    LD      A, $00                         ; LD A,$00: clear for carry
    ADC     A, H                           ; ADC A,H: add carry to high byte
    LD      H, A                           ; LD H,A: store high byte
    LD      ($7068), HL                 ; RAM $7068
    POP     IX                             ; POP IX: restore descriptor pointer
    INC     IX                             ; INC IX: next descriptor entry
    JR      LOC_83F0                       ; JR LOC_83F0

SUB_844B:                                  ; SUB_844B: BIOS object table init + initial screen draw
    LD      HL, $71D9                      ; LD HL,$71D9 LD (HL),$01: P1 score init
    LD      (HL), $01                      ; LD (HL),$01
    INC     HL                             ; INC HL
    LD      (HL), $01                      ; LD (HL),$01
    CALL    SUB_A551                       ; CALL SUB_A551: RST $28 PLAY_SONGS
    LD      C, $02                         ; C=$02 B=$00
    LD      B, $00                         ; LD B,$00: B=0 for ADD HL,BC stage-phase index
    RST     $28                            ; RST $28 = PLAY_SONGS: start music
    LD      HL, BOOT_UP                    ; HL=BOOT_UP A=$03
    LD      A, $03                         ; RST $20 = PLAY_IT: play track 3 from BOOT_UP
    RST     $20                            ; RST $20: BIOS set VRAM write address
    LD      HL, $2000                      ; LD HL,$2000: VRAM name table page 4
    LD      A, $04                         ; LD A,$04: color table index 4
    RST     $20                            ; RST $20: set color table address
    LD      HL, $1800                      ; LD HL,$1800: VRAM name table page 3
    LD      A, $02                         ; LD A,$02: color table index 2
    RST     $20                            ; RST $20: set color table address
    LD      HL, $3800                      ; LD HL,$3800: VRAM name table page 7
    LD      A, $01                         ; LD A,$01: color table index 1
    RST     $20                            ; RST $20: set VRAM color table
    LD      HL, $1F80                      ; LD HL,$1F80: sprite attribute table address
    LD      A, $00                         ; LD A,$00: zero fill value
    RST     $20                            ; RST $20: clear sprite attribute table
    LD      HL, BOOT_UP                    ; LD HL,BOOT_UP: start of VRAM pattern area
    LD      DE, $3FFF                      ; LD DE,$3FFF: length to clear
    XOR     A                              ; XOR A: fill value = 0
    RST     $18                            ; RST $18: BIOS block fill VRAM
    CALL    SUB_84C0                       ; CALL SUB_84C0: initialize sprite table
    XOR     A                              ; XOR A: A = 0
    LD      ($73C6), A                     ; LD ($73C6),A: clear P1 score high
    LD      ($73C7), A                     ; LD ($73C7),A: clear P1 score low
    LD      ($7344), A                     ; LD ($7344),A: clear P1 lives display
    LD      ($7345), A                     ; LD ($7345),A: clear P2 lives display
    LD      A, ($7284)                     ; LD A,($7284): read number of players
    LD      ($7294), A                     ; LD ($7294),A: store for player 1 lives init
    LD      ($72A1), A                     ; LD ($72A1),A: store for player 2 lives init
    LD      A, $0A                         ; LD A,$0A: score init value $0A
    LD      HL, $72AB                      ; LD HL,$72AB: score RAM base
    CALL    INIT_WRITER                    ; CALL INIT_WRITER: initialize score display RAM
    LD      HL, $72EF                      ; LD HL,$72EF: sprite Y table base
    XOR     A                              ; XOR A: fill value = 0
    LD      B, $10                         ; LD B,$10: 16 entries

LOC_84A8:                                  ; LOC_84A8: ascending fill of sprite Y table
    LD      (HL), A                        ; LD (HL),A: write sprite Y entry
    INC     HL                             ; INC HL: advance pointer
    INC     A                              ; INC A: next Y value
    DJNZ    LOC_84A8                       ; DJNZ LOC_84A8: loop 16 times

DELAY_LOOP_84AD:                           ; DELAY_LOOP_84AD: initialize sprite-type RAM block
    LD      HL, $72FF                      ; LD HL,$72FF: sprite type table base
    LD      DE, $0004                      ; LD DE,$0004: stride per sprite entry
    LD      B, $10                         ; LD B,$10: 16 sprites

LOC_84B5:                                  ; LOC_84B5: fill sprite type bytes
    LD      (HL), $C3                      ; LD (HL),$C3: sprite type = $C3
    ADD     HL, DE                         ; ADD HL,DE: advance by stride
    DJNZ    LOC_84B5                       ; DJNZ LOC_84B5: loop all 16 sprite slots
    LD      A, $10                         ; LD A,$10: 16 sprites
    CALL    WR_SPR_NM_TBL                  ; CALL WR_SPR_NM_TBL: write sprite name table
    RET                                    ; RET: return from SUB_844B

SUB_84C0:                                  ; SUB_84C0: write $D0 (end sentinel) to VRAM $1F80+$0080
    LD      HL, $1F80                      ; HL = $1F80
    LD      DE, $0080                      ; DE = $0080
    LD      A, $D0                         ; A = $D0: sentinel byte
    RST     $18                            ; RST $18: WRITER
    RET                                    ; RET: return from SUB_84C0 sprite-sentinel write

SUB_84CA:                                  ; SUB_84CA: clear sprite name-table entries (BC = start tile, fill 12 rows)
    CALL    SUB_A4FD                       ; CALL SUB_A4FD: IX = current player
    LD      A, (IX+2)                      ; A = (IX+2): stage number
    DEC     A                              ; DEC A
    AND     $07                            ; AND $07: stage mod 8
    LD      ($7289), A                     ; LD ($7289),A: store stage phase
    PUSH    AF                             ; PUSH AF
    CALL    Z, SUB_8503                    ; CALL Z,SUB_8503: if phase 0 -- advance difficulty
    LD      A, (IX+3)                      ; A = (IX+3): difficulty
    LD      ($7287), A                     ; LD ($7287),A
    POP     AF                             ; POP AF
    LD      HL, $84FB                      ; HL=$84FB: vine offset table
    LD      C, A                           ; LD C,A: stage phase as index
    LD      B, $00                         ; LD B,$00: B=0 (zero-extend stage phase for table index)
    ADD     HL, BC                         ; ADD HL,BC: index into table
    LD      A, (HL)                        ; A=(HL): get offset
    LD      (IX+1), A                      ; LD (IX+1),A: save vine offset
    LD      ($7288), A                     ; LD ($7288),A: current stage type
    CALL    SUB_8539                       ; CALL SUB_8539: select vine data set by type
    LD      A, ($7288)                  ; RAM $7288
    CP      $01                            ; CP $01: check if stage flag = 1
    RET     NZ                             ; RET NZ: return if not stage 1
    JP      LOC_8566                       ; JP LOC_8566: jump to stage-advance animation
    DB      $00, $01, $00, $02, $01, $00, $02, $01

SUB_8503:                                  ; SUB_8503: advance difficulty -- called when stage phase wraps to 0
    LD      A, (IX+6)                      ; A = (IX+6): last difficulty phase
    CP      (IX+2)                         ; CP (IX+2): same as current stage?
    RET     Z                              ; RET Z: no change
    LD      A, ($728E)                     ; A = ($728E): collision detect flag
    CP      $02                            ; CP $02
    JR      Z, LOC_8537                    ; JR Z,LOC_8537: already max -- no advance
    LD      A, (IX+2)                      ; A = (IX+2): stage number
    LD      (IX+6), A                      ; LD (IX+6),A: save as last seen
    DEC     A                              ; DEC A
    JR      Z, LOC_8537                    ; JR Z,LOC_8537: stage 1 -- no advance
    LD      A, ($7284)                     ; A = ($7284): base difficulty
    LD      B, $03                         ; B=$03
    CP      $01                            ; CP $01
    JR      Z, LOC_852B                    ; JR Z,LOC_852B
    LD      B, $04                         ; B=$04
    CP      $04                            ; CP $04
    JR      C, LOC_852B                    ; JR C,LOC_852B
    LD      B, $05                         ; B=$05

LOC_852B:                                  ; LOC_852B: advance difficulty if not already at cap
    LD      A, (IX+3)                      ; A = (IX+3): current difficulty
    CP      B                              ; CP B
    JR      NC, LOC_8537                   ; JR NC,LOC_8537: at cap -- do nothing
    INC     (IX+3)                         ; INC (IX+3): difficulty++
    INC     (IX+4)                         ; INC (IX+4): sub-difficulty++

LOC_8537:                                  ; LOC_8537: return (XOR A = NZ clear)
    XOR     A                              ; XOR A: clear A (Z cleared; function returns A as scratch)
    RET                                    ; RET: return from LOC_8537 difficulty cap

SUB_8539:                                  ; SUB_8539: select vine/platform data set by stage type in A
    OR      A                              ; OR A
    JR      Z, LOC_8544                    ; JR Z,LOC_8544: type 0 = first level set
    DEC     A                              ; DEC A
    JR      Z, LOC_854E                    ; JR Z,LOC_854E: type 1 = second level set
    DEC     A                              ; DEC A
    JR      Z, LOC_8558                    ; JR Z,LOC_8558: type 2 = third level set
    JR      LOC_8560                       ; JR LOC_8560: type 3 = use previous (no reload)

LOC_8544:                                  ; LOC_8544: IY=$BB6B IX=$BCE0: set 0 vine/platform data
    LD      IY, $BB6B                      ; LD IY,$BB6B: point IY to Jr sprite data set A
    LD      IX, $BCE0                      ; LD IX,$BCE0: point IX to Jr sprite data set A end
    JR      LOC_8560                       ; JR LOC_8560: jump to tile load

LOC_854E:                                  ; LOC_854E: alternate Jr sprite data set
    LD      IY, $BD57                      ; LD IY,$BD57: point IY to Jr sprite data set B
    LD      IX, $BE13                      ; LD IX,$BE13: point IX to Jr sprite data set B end
    JR      LOC_8560                       ; JR LOC_8560: jump to tile load

LOC_8558:                                  ; LOC_8558: IY=$BE40 IX=$BF90: set 2 data
    LD      IY, $BE40                      ; LD IY,$BE40: point IY to vine tile data set 2 start
    LD      IX, $BF90                      ; LD IX,$BF90: point IX to vine tile data set 2 end

LOC_8560:                                  ; LOC_8560: HL=$1800: VRAM base for tile write
    LD      HL, $1800                      ; HL=$1800
    JP      SUB_83E5                       ; JP SUB_83E5: run tile loader with selected data

LOC_8566:                                  ; LOC_8566: stage-advance animation (bonus stage clear)
    LD      HL, $4140                      ; LD HL,$4140: animation step coordinates
    CALL    SUB_85C5                       ; CALL SUB_85C5: draw animation frame at HL
    LD      B, $0A                         ; LD B,$0A: loop count 10
    LD      DE, $0106                      ; LD DE,$0106: sprite position row=1 col=6
    LD      A, $14                         ; LD A,$14: delay count $14
    LD      ($706A), A                     ; LD ($706A),A: store delay counter
    CALL    DELAY_LOOP_85AF                ; CALL DELAY_LOOP_85AF: timed animation delay
    LD      DE, $01C6                      ; LD DE,$01C6: next sprite position
    LD      HL, $4C4B                      ; LD HL,$4C4B: next frame data
    CALL    DELAY_LOOP_85A4                ; CALL DELAY_LOOP_85A4: draw and delay
    LD      DE, $01E6                      ; LD DE,$01E6: next sprite position
    LD      HL, $4E4D                      ; LD HL,$4E4D: next frame data
    CALL    DELAY_LOOP_85A4                ; CALL DELAY_LOOP_85A4: draw and delay
    LD      HL, $4342                      ; LD HL,$4342: animation frame data
    CALL    SUB_85C5                       ; CALL SUB_85C5: draw animation frame
    LD      B, $01                         ; LD B,$01: loop once
    LD      DE, $0286                      ; LD DE,$0286: sprite position for this frame
    CALL    DELAY_LOOP_85AF                ; CALL DELAY_LOOP_85AF: timed delay
    LD      DE, $0104                      ; LD DE,$0104: final frame position
    CALL    SUB_85D4                       ; CALL SUB_85D4: draw final frame
    LD      DE, $011B                      ; LD DE,$011B: end-of-animation position
    JR      SUB_85D4                       ; JR SUB_85D4: draw and return

DELAY_LOOP_85A4:                           ; DELAY_LOOP_85A4: set vine position registers $706E $7074 $707C
    LD      ($706E), HL                    ; LD ($706E),HL
    LD      ($7074), HL                    ; LD ($7074),HL
    LD      ($707C), HL                    ; LD ($707C),HL
    LD      B, $01                         ; LD B,$01: B=1 iteration count for vine sprite update

DELAY_LOOP_85AF:                           ; DELAY_LOOP_85AF: update vine/platform sprite positions, B iterations
    PUSH    BC                             ; PUSH BC
    PUSH    DE                             ; PUSH DE
    LD      HL, $706C                      ; HL = $706C: vine sprite X register
    LD      IY, ($706A)                    ; IY = ($706A): Y anchor
    LD      A, $02                         ; A=$02
    RST     $10                            ; RST $10 = PUTOBJ: write vine sprite to object buffer
    POP     HL                             ; POP HL
    LD      DE, $0020                      ; LD DE,$0020: step VRAM row (+32 bytes)
    ADD     HL, DE                         ; ADD HL,DE
    DB      $EB                            ; DB $EB: EX DE,HL
    POP     BC                             ; POP BC
    DJNZ    DELAY_LOOP_85AF                ; DJNZ DELAY_LOOP_85AF
    RET                                    ; RET: return from DELAY_LOOP_85AF vine-sprite update

SUB_85C5:                                  ; SUB_85C5: copy HL into 9 consecutive vine position registers
    LD      ($706C), HL                    ; LD ($706C),HL
    LD      HL, $706C                      ; HL = $706C
    LD      DE, $706E                      ; DE = $706E
    LD      BC, $0012                      ; BC = $0012: 18 bytes
    LDIR                                   ; LDIR: copy 9 positions
    RET                                    ; RET: return from SUB_85C5 vine-position register copy

SUB_85D4:                                  ; SUB_85D4: set vine position to fixed column $51, 1 row
    LD      A, $51                         ; LD A,$51
    LD      ($706C), A                     ; LD ($706C),A
    LD      A, $01                         ; LD A,$01
    LD      ($706A), A                     ; LD ($706A),A
    LD      B, $0F                         ; B=$0F
    JR      DELAY_LOOP_85AF                ; JR DELAY_LOOP_85AF

SUB_85E2:                                  ; SUB_85E2: place fruit/items on screen -- allocate signals for 5 item types
    LD      HL, $72D1                      ; HL=$72D1: item timer base
    LD      DE, BOOT_UP                    ; DE=BOOT_UP
    CALL    INIT_TIMER                     ; CALL INIT_TIMER
    LD      A, $01                         ; A=$01: signal type = one-shot
    LD      HL, $0001                      ; HL=$0001: period 1 tick
    CALL    REQUEST_SIGNAL                 ; CALL REQUEST_SIGNAL
    LD      ($72CB), A                     ; LD ($72CB),A: store Junior signal handle
    LD      A, $01                         ; LD A,$01
    LD      HL, $0003                      ; HL=$0003
    CALL    REQUEST_SIGNAL                 ; CALL REQUEST_SIGNAL
    LD      ($72CA), A                     ; LD ($72CA),A: enemy signal handle
    LD      A, $01                         ; LD A,$01
    LD      HL, $005A                      ; HL=$005A: 90 ticks
    CALL    REQUEST_SIGNAL                 ; CALL REQUEST_SIGNAL
    LD      ($72CC), A                     ; LD ($72CC),A: vine/platform signal handle
    LD      A, $01                         ; LD A,$01
    LD      HL, $0014                      ; HL=$0014: 20 ticks
    CALL    REQUEST_SIGNAL                 ; CALL REQUEST_SIGNAL
    LD      ($72CF), A                     ; LD ($72CF),A: screen flip signal handle
    LD      A, $01                         ; LD A,$01
    LD      HL, $0078                      ; HL=$0078: 120 ticks
    CALL    REQUEST_SIGNAL                 ; CALL REQUEST_SIGNAL
    LD      ($72D0), A                     ; LD ($72D0),A: 2-player alternation signal handle
    RET                                    ; RET: return from LOC_820E after allocating two signals

SUB_8623:                                  ; SUB_8623: render level tile map to VRAM -- 3 tile types (plain, shadow, color)
    LD      A, ($7288)                     ; A = ($7288): stage type
    LD      L, A                           ; L = A: index
    LD      H, $00                         ; H = $00
    ADD     HL, HL                         ; ADD HL,HL
    ADD     HL, HL                         ; ADD HL,HL: HL = A*4 (4 bytes per entry)
    LD      DE, $865F                      ; DE = $865F: tile descriptor table
    ADD     HL, DE                         ; ADD HL,DE: point to current entry
    LD      BC, $71EE                      ; BC = $71EE: Junior IY struct base
    XOR     A                              ; XOR A
    LD      (BC), A                        ; LD (BC),A: clear IY+0
    LD      A, (HL)                        ; A = (HL): first tile descriptor byte
    INC     BC                             ; INC BC
    LD      (BC), A                        ; LD (BC),A: IY+1 = Y anchor
    INC     HL                             ; INC HL
    INC     BC                             ; INC BC: skip IY+2
    INC     BC                             ; INC BC: skip IY+2
    LD      A, (HL)                        ; A = (HL): second descriptor byte
    LD      (BC), A                        ; LD (BC),A: IY+3 = X anchor
    INC     HL                             ; INC HL
    LD      BC, $70B1                      ; BC = $70B1: Kong Y register
    LD      A, (HL)                        ; A = (HL): third byte
    LD      (BC), A                        ; LD (BC),A
    INC     HL                             ; INC HL
    INC     BC                             ; INC BC
    LD      A, (HL)                        ; A = (HL): fourth byte
    LD      (BC), A                        ; LD (BC),A: $70B2 = Kong X register
    LD      HL, $0001                      ; HL = $0001
    LD      A, $01                         ; LD A,$01
    CALL    REQUEST_SIGNAL                 ; CALL REQUEST_SIGNAL
    LD      ($7081), A                     ; LD ($7081),A: Kong signal handle
    LD      HL, $866B                      ; HL = $866B: Kong initial position table
    LD      DE, $7082                      ; DE = $7082: Kong struct base
    LD      BC, $000A                      ; BC = $000A: 10 bytes
    LDIR                                   ; LDIR: copy Kong initial state
    JP      DELAY_LOOP_950B                ; JP DELAY_LOOP_950B: init Junior sprite display
    DB      $08, $9F, $08, $F0, $28, $A7, $28, $C4
    DB      $08, $8F, $08, $F0, $07, $04, $0A, $04
    DB      $06, $08, $03, $02, $01, $00

DELAY_LOOP_8675:                           ; DELAY_LOOP_8675: post-render init -- clear sprite tables and enemy state
    CALL    DELAY_LOOP_8EE2                ; CALL DELAY_LOOP_8EE2: clear snapjaw frame timers (6 slots)
    LD      HL, $733F                      ; HL = $733F: sprite clear area
    XOR     A                              ; XOR A
    LD      (HL), A                        ; LD (HL),A: clear byte 1
    INC     HL                             ; INC HL
    LD      (HL), A                        ; LD (HL),A: clear byte 2
    LD      ($708C), A                     ; LD ($708C),A: snapjaw slot counter
    LD      ($708D), A                     ; LD ($708D),A: snapjaw slot index
    LD      ($70F5), A                     ; LD ($70F5),A: fruit collection timer flag
    LD      HL, $730B                      ; HL = $730B: scroll target table
    LD      ($7092), HL                    ; LD ($7092),HL: init scroll pointer
    LD      DE, $7202                      ; DE = $7202: sprite attribute buffer
    LD      B, $78                         ; B = $78 (120): bytes to clear

LOC_8693:                                  ; LOC_8693: zero-fill 120 bytes of sprite buffer
    LD      (DE), A                        ; LD (DE),A: clear sprite byte
    INC     DE                             ; INC DE
    DJNZ    LOC_8693                       ; DJNZ LOC_8693
    CALL    SOUND_WRITE_A042               ; CALL SOUND_WRITE_A042: reset sprite write pointer
    LD      A, ($7288)                     ; A = ($7288): stage type (0=vine, 1=rope, 2=croc)
    OR      A                              ; OR A
    JR      Z, LOC_86A9                    ; JR Z,LOC_86A9: type 0
    DEC     A                              ; DEC A
    JR      Z, LOC_86AF                    ; JR Z,LOC_86AF: type 1
    CALL    SUB_8729                       ; CALL SUB_8729: type 2 -- croc stage vine data
    JP      LOC_874A                       ; JP LOC_874A

LOC_86A9:                                  ; LOC_86A9: vine stage (type 0)
    CALL    SUB_86B8                       ; CALL SUB_86B8
    JP      LOC_870A                       ; JP LOC_870A

LOC_86AF:                                  ; LOC_86AF: rope stage (type 1)
    CALL    SUB_86F4                       ; CALL SUB_86F4
    CALL    LOC_870A                       ; CALL LOC_870A
    JP      LOC_8720                       ; JP LOC_8720

SUB_86B8:                                  ; SUB_86B8: vine stage column data -- IY=$86C2, DE=$A5B6
    LD      IY, $86C2                      ; IY = $86C2: vine descriptor table
    LD      DE, $A5B6                      ; DE = $A5B6: vine data array
    JP      LOC_875B                       ; JP LOC_875B: dispatch vine column
    DB      $5D, $34, $08, $08, $64, $DC, $08, $08
    DB      $35, $A4, $08, $08, $35, $B4, $08, $08
    DB      $2D, $0C, $10, $08

LOC_86D6:                                  ; LOC_86D6: vine column copier
    PUSH    IY                             ; PUSH IY: save vine table pointer
    POP     HL                             ; POP HL
    LD      IX, ($708E)                    ; IX = ($708E): vine slot IX
    LD      B, $00                         ; B = $00
    LD      A, (IX+0)                      ; A = (IX+0): vine slot type
    OR      A                              ; OR A: empty?
    RET     Z                              ; RET Z
    LD      C, A                           ; C = A
    SLA     C                              ; SLA C: C *= 4 (4 bytes per vine entry)
    SLA     C                              ; SLA C
    LD      DE, ($7092)                    ; DE = ($7092): vine data write pointer
    LDIR                                   ; LDIR: copy vine entry
    LD      ($7092), DE                    ; LD ($7092),DE: advance pointer
    RET                                    ; RET: return from vine column entry copy loop

SUB_86F4:                                  ; SUB_86F4: rope stage column data -- IY=$86FE, DE=$A5B6
    LD      IY, $86FE                      ; IY = $86FE
    LD      DE, $A5B6                      ; DE = $A5B6
    JP      LOC_875B                       ; JP LOC_875B
    DB      $2C, $40, $08, $08, $2C, $AA, $08, $08
    DB      $2C, $7C, $08, $08

LOC_870A:                                  ; LOC_870A: platform data -- IY=$8714, DE=$A5B9
    LD      IY, $8714                      ; IY = $8714
    LD      DE, $A5B9                      ; DE = $A5B9
    JP      LOC_875B                       ; JP LOC_875B
    DB      $C3, $7C, $08, $04, $C3, $7C, $08, $04
    DB      $C3, $7C, $08, $04

LOC_8720:                                  ; LOC_8720: rope stage vine positions -- IY=$8732, DE=$A5BC
    LD      IY, $8732                      ; LD IY,$8732: point IY to vine column descriptor 3
    LD      DE, $A5BC                      ; LD DE,$A5BC: VRAM target address for vine column
    JR      LOC_875B                       ; JR LOC_875B: jump to vine column renderer

SUB_8729:                                  ; SUB_8729: vine column setup entry point B
    LD      IY, $873E                      ; LD IY,$873E: point IY to vine column descriptor 4
    LD      DE, $A5BC                      ; LD DE,$A5BC: VRAM target address
    JR      LOC_875B                       ; JR LOC_875B: jump to vine renderer
    DB      $C3, $7C, $04, $03, $C3, $7C, $04, $03
    DB      $C3, $7C, $04, $03, $C3, $7C, $04, $03
    DB      $C3, $7C, $04, $03, $C3, $7C, $04, $03

LOC_874A:                                  ; LOC_874A: vine column setup entry point C
    LD      IY, $8753                      ; LD IY,$8753: point IY to vine column descriptor 5
    LD      DE, $A5BF                      ; LD DE,$A5BF: VRAM target for alternate column
    JR      LOC_875B                       ; JR LOC_875B: jump to vine renderer
    DB      $C3, $7C, $38, $0F, $C3, $7C, $38, $0F

LOC_875B:                                  ; LOC_875B: vine column renderer entry
    LD      HL, $A557                      ; LD HL,$A557: base of vine tile map
    LD      A, ($7289)                     ; LD A,($7289): read current stage number
    SLA     A                              ; SLA A: A *= 2 (stage index * 2)
    CP      $03                            ; CP $03: compare with max stage offset
    JR      C, LOC_876D                    ; JR C,LOC_876D: if small, skip extra inc
    INC     A                              ; INC A: add 1 for higher stages
    CP      $0A                            ; CP $0A: second threshold check
    JR      C, LOC_876D                    ; JR C,LOC_876D: if below $0A, skip
    INC     A                              ; INC A: further increment for large stages

LOC_876D:                                  ; LOC_876D: compute vine column VRAM offset
    LD      B, $00                         ; LD B,$00: clear B for 16-bit offset
    LD      C, A                           ; LD C,A: C = column offset
    LD      A, ($708D)                     ; LD A,($708D): read vine column index
    ADD     A, C                           ; ADD A,C: add column offset
    LD      C, A                           ; LD C,A: result in C
    ADD     HL, BC                         ; ADD HL,BC: HL = vine map base + offset
    LD      A, ($7287)                     ; LD A,($7287): read vine scroll position
    DEC     A                              ; DEC A: adjust by 1
    CP      $05                            ; CP $05: compare with scroll threshold
    JR      C, LOC_8780                    ; JR C,LOC_8780: if small, use smaller B
    LD      A, $04                         ; LD A,$04: clamp to 4 vine segments

LOC_8780:                                  ; LOC_8780: B = number of vine column entries
    LD      B, A                           ; LD B,A: set loop count
    OR      A                              ; OR A: test if zero
    JR      Z, LOC_8789                    ; JR Z,LOC_8789: skip offset calc if zero
    XOR     A                              ; XOR A: clear accumulator

LOC_8785:                                  ; LOC_8785: compute row offset (B * $13)
    ADD     A, $13                         ; ADD A,$13: add 19 per row
    DJNZ    LOC_8785                       ; DJNZ LOC_8785: loop B times

LOC_8789:                                  ; LOC_8789: add row offset to vine map pointer
    LD      C, A                           ; LD C,A: offset in C
    ADD     HL, BC                         ; ADD HL,BC: HL = vine map row pointer
    LD      A, ($708D)                     ; LD A,($708D): read vine column index
    INC     A                              ; INC A: increment column index
    LD      ($708D), A                     ; LD ($708D),A: store updated column index
    DB      $EB                            ; DB $EB: EX DE,HL - swap DE/HL
    LD      ($7090), HL                    ; LD ($7090),HL: save vine map source pointer
    LD      A, (DE)                        ; LD A,(DE): read vine descriptor byte
    LD      C, A                           ; LD C,A: C = vine descriptor
    PUSH    HL                             ; PUSH HL: save vine map pointer
    ADD     HL, BC                         ; ADD HL,BC: HL = vine data pointer
    LD      ($708E), HL                    ; LD ($708E),HL: save vine data pointer
    LD      B, (HL)                        ; LD B,(HL): B = number of vine segments
    POP     HL                             ; POP HL: restore pointer
    INC     B                              ; INC B: test B+1
    DEC     B                              ; DEC B: restore B
    RET     Z                              ; RET Z: return if no segments
    LD      IX, $7202                      ; LD IX,$7202: point IX to sprite attribute table
    PUSH    BC                             ; PUSH BC: save segment count
    LD      A, ($708C)                     ; LD A,($708C): read vine sprite column
    OR      A                              ; OR A: test if zero
    JR      Z, LOC_87B3                    ; JR Z,LOC_87B3: skip offset if column 0
    LD      B, A                           ; LD B,A: B = column number
    XOR     A                              ; XOR A: clear accumulator

LOC_87AF:                                  ; LOC_87AF: compute sprite table offset (B * $0A)
    ADD     A, $0A                         ; ADD A,$0A: add 10 per column
    DJNZ    LOC_87AF                       ; DJNZ LOC_87AF: loop B times

LOC_87B3:                                  ; LOC_87B3: apply column offset to IX
    POP     BC                             ; POP BC: restore segment count
    LD      D, $00                         ; LD D,$00: D = 0 for 16-bit offset
    LD      E, A                           ; LD E,A: E = column byte offset
    ADD     IX, DE                         ; ADD IX,DE: IX = sprite slot for this column
    LD      C, $00                         ; LD C,$00: clear segment counter

LOC_87BB:                                  ; LOC_87BB: vine segment render loop
    LD      A, (HL)                        ; LD A,(HL): read vine tile byte
    PUSH    AF                             ; PUSH AF: save vine byte
    BIT     1, A                           ; BIT 1,A: test color/type bit 1
    JR      NZ, LOC_87CA                   ; JR NZ,LOC_87CA: if set, skip sound write
    LD      A, ($708C)                     ; LD A,($708C): read vine column index
    LD      C, A                           ; LD C,A: C = column index for sound
    PUSH    HL                             ; PUSH HL: save pointer
    CALL    SOUND_WRITE_A055               ; CALL SOUND_WRITE_A055: write vine sound event
    POP     HL                             ; POP HL: restore pointer

LOC_87CA:                                  ; LOC_87CA: decode vine segment attributes
    POP     AF                             ; POP AF: restore vine byte
    AND     $0F                            ; AND $0F: mask low nibble (tile pattern)
    LD      (IX+1), A                      ; LD (IX+1),A: store tile number in sprite slot
    LD      A, (HL)                        ; LD A,(HL): re-read vine byte
    AND     $30                            ; AND $30: mask bits 4-5 (tile bank)
    SRL     A                              ; SRL A: shift right 1
    SRL     A                              ; SRL A: shift right 2
    SRL     A                              ; SRL A: shift right 3
    SRL     A                              ; SRL A: shift right 4 (bank in bits 0-1)
    LD      (IX+0), A                      ; LD (IX+0),A: store tile bank in sprite slot
    INC     HL                             ; INC HL: advance to second vine byte
    LD      A, (HL)                        ; LD A,(HL): read second vine byte
    AND     $0F                            ; AND $0F: mask color nibble
    LD      (IX+2), A                      ; LD (IX+2),A: store color in sprite slot
    LD      A, (HL)                        ; LD A,(HL): re-read second byte
    BIT     6, A                           ; BIT 6,A: test early-expire bit
    JR      Z, LOC_87F0                    ; JR Z,LOC_87F0: if not set, use duration 1
    LD      (IX+5), $3C                    ; LD (IX+5),$3C: set long duration ($3C frames)
    JR      LOC_87F4                       ; JR LOC_87F4: skip short duration

LOC_87F0:                                  ; LOC_87F0: use short sprite duration
    LD      (IX+5), $01                    ; LD (IX+5),$01: set duration 1 frame

LOC_87F4:                                  ; LOC_87F4: read vine segment Y data
    LD      HL, ($708E)                    ; LD HL,($708E): load vine data pointer
    INC     HL                             ; INC HL: advance to Y offset byte
    LD      A, (HL)                        ; LD A,(HL): read Y offset
    AND     $F0                            ; AND $F0: mask high nibble
    SRL     A                              ; SRL A: shift right 1
    SRL     A                              ; SRL A: shift right 2
    SRL     A                              ; SRL A: shift right 3
    SRL     A                              ; SRL A: shift right 4
    LD      (IX+6), A                      ; LD (IX+6),A: store Y high in sprite slot
    LD      (IX+7), A                      ; LD (IX+7),A: store Y copy
    LD      A, (HL)                        ; LD A,(HL): re-read byte
    AND     $0F                            ; AND $0F: mask Y low nibble
    LD      HL, ($7090)                    ; LD HL,($7090): load vine map source pointer
    INC     HL                             ; INC HL: advance
    INC     HL                             ; INC HL: advance to X byte
    LD      C, (HL)                        ; LD C,(HL): read X offset
    ADD     A, C                           ; ADD A,C: combine Y low and X
    LD      (IX+4), A                      ; LD (IX+4),A: store X position in sprite slot
    LD      DE, $000A                      ; LD DE,$000A: sprite slot stride
    ADD     IX, DE                         ; ADD IX,DE: advance IX to next sprite slot
    LD      A, ($708C)                     ; LD A,($708C): read vine column counter
    INC     A                              ; INC A: increment column counter
    LD      ($708C), A                  ; RAM $708C
    LD      HL, ($7090)                 ; RAM $7090
    DJNZ    LOC_87BB                       ; DJNZ LOC_87BB: loop for all vine segments
    LD      C, A                           ; LD C,A: C = segments rendered
    LD      A, $0C                         ; LD A,$0C: max segments = 12
    SUB     C                              ; SUB C: A = remaining empty slots
    JP      Z, LOC_86D6                    ; JP Z,LOC_86D6: if full, return
    LD      B, A                           ; LD B,A: B = count of slots to blank

LOC_882F:                                  ; LOC_882F: blank remaining sprite slots
    LD      (IX+0), $04                    ; LD (IX+0),$04: set blank tile bank
    ADD     IX, DE                         ; ADD IX,DE: advance to next slot
    DJNZ    LOC_882F                       ; DJNZ LOC_882F: loop remaining
    JP      LOC_86D6                       ; JP LOC_86D6: return via LOC_86D6

SUB_883A:                                  ; SUB_883A: init enemy starting position based on stage type
    CALL    SUB_A4FD                       ; CALL SUB_A4FD: IX=player IY=other
    LD      A, (IX+2)                      ; A = (IX+2): stage number
    DEC     A                              ; DEC A: stage 0-indexed
    LD      L, $35                         ; L = $35
    LD      B, $50                         ; B = $50: low difficulty bounds
    CP      $02                            ; CP $02
    JR      C, LOC_8855                    ; JR C,LOC_8855: stage < 2 -- use easy
    LD      L, $36                         ; L = $36
    LD      B, $60                         ; B = $60: medium
    CP      $05                            ; CP $05
    JR      C, LOC_8855                    ; JR C,LOC_8855
    LD      L, $37                         ; L = $37: hard
    LD      B, $70                         ; B = $70

LOC_8855:                                  ; LOC_8855: store enemy Y range and timer
    LD      H, $30                         ; H = $30: high byte
    LD      ($728A), HL                    ; LD ($728A),HL: enemy Y range
    LD      A, B                           ; A = B
    LD      ($7094), A                     ; LD ($7094),A: enemy spawn timer
    RET                                    ; RET: return from SUB_8855 enemy Y range and spawn timer

SUB_885F:                                  ; SUB_885F: timer countdown display -- decrement $7094 and draw to screen
    LD      BC, $728B                      ; BC = $728B: timer display buffer lo
    LD      HL, $7094                      ; HL = $7094: countdown value
    LD      A, (HL)                        ; A = (HL): current value
    DEC     A                              ; DEC A
    DAA                                    ; DAA: BCD decrement
    LD      (HL), A                        ; LD (HL),A: store
    JR      Z, LOC_888C                    ; JR Z,LOC_888C: hit zero
    AND     $0F                            ; AND $0F: low BCD digit
    OR      $30                            ; OR $30: ASCII digit
    LD      (BC), A                        ; LD (BC),A: write lo digit to display
    LD      A, (HL)                        ; A = (HL)
    SRL     A                              ; SRL A: shift high nibble down
    SRL     A                              ; SRL A: shift A right 1
    SRL     A                              ; SRL A: shift A right 2
    SRL     A                              ; SRL A: shift A right 3 (divide by 8)
    OR      $30                            ; OR $30: ASCII hi digit
    DEC     BC                             ; DEC BC
    LD      (BC), A                        ; LD (BC),A: write hi digit
    PUSH    HL                             ; PUSH HL
    CALL    SUB_A66E                       ; CALL SUB_A66E: write timer display to VRAM
    POP     HL                             ; POP HL
    LD      A, (HL)                        ; A = (HL): reload countdown
    CP      $09                            ; CP $09
    RET     NZ                             ; RET NZ: not at 9 -- done
    CALL    SUB_A679                       ; CALL SUB_A679: play sound at 9
    JP      LOC_A6C6                       ; JP LOC_A6C6

LOC_888C:                                  ; LOC_888C: timer hit zero -- play alarm, advance to next enemy state
    LD      A, $30                         ; LD A,$30
    LD      (BC), A                        ; LD (BC),A: zero lo digit
    INC     BC                             ; INC BC
    LD      (BC), A                        ; LD (BC),A: zero hi digit
    CALL    SUB_A66E                       ; CALL SUB_A66E: update timer display
    POP     DE                             ; POP DE: unwind stack
    JP      LOC_A172                       ; JP LOC_A172: life lost / game over
    DB      $A0, $88, $C2, $88, $F0, $88, $0C, $89
    DB      $AF, $00, $43, $A7, $64, $7B, $AF, $8C
    DB      $A0, $A7, $B4, $C4, $9F, $D4, $F0, $87
    DB      $2F, $5F, $6F, $CE, $F7, $67, $2F, $4F
    DB      $3F, $91, $D3, $37, $40, $9A, $37, $14
    DB      $38, $FF, $18, $37, $9B, $28, $37, $93
    DB      $38, $87, $9B, $38, $67, $87, $68, $37
    DB      $93, $98, $3F, $83, $A8, $3F, $6B, $B8
    DB      $3F, $8B, $C8, $3F, $83, $D8, $67, $8B
    DB      $D8, $1E, $67, $E8, $67, $8B, $E8, $1E
    DB      $67, $9A, $08, $1B, $58, $10, $1B, $FF
    DB      $90, $2F, $5F, $76, $D0, $FA, $6D, $2F
    DB      $44, $68, $2F, $44, $48, $80, $DB, $40
    DB      $00, $7F, $1E, $C0, $F7, $08, $7C, $B4
    DB      $10, $3C, $78, $FF, $96, $38, $3F, $28
    DB      $78, $8F, $67, $78, $8F, $C8, $60, $77
    DB      $FD, $60, $77, $28, $58, $6F, $57, $58
    DB      $6F, $FF, $2A, $89, $31, $89, $50, $89
    DB      $54, $89, $37, $18, $EB, $B7, $00, $FF
    DB      $FF, $38, $37, $A2, $48, $37, $A2, $58
    DB      $37, $A2, $68, $37, $A2, $78, $37, $A2
    DB      $88, $37, $A2, $98, $37, $A2, $A8, $37
    DB      $A2, $B8, $37, $A2, $C8, $37, $A2, $FF
    DB      $3C, $10, $F5, $FF, $FF, $00, $FF, $D8
    DB      $00, $FF, $FF, $63, $89, $82, $89, $BF
    DB      $89, $D5, $89, $9F, $00, $25, $9F, $58
    DB      $77, $9F, $CC, $EB, $7F, $00, $2B, $7F
    DB      $A4, $CC, $AB, $37, $49, $27, $50, $98
    DB      $2F, $A8, $D5, $FE, $95, $70, $FE, $98
    DB      $70, $FF, $18, $2E, $69, $28, $2E, $69
    DB      $38, $2E, $4B, $48, $2E, $43, $58, $2E ; "8.KH.CX."
    DB      $4B, $68, $2E, $43, $78, $2E, $4B, $88
    DB      $2E, $4B, $98, $2F, $55, $A0, $00, $0F
    DB      $78, $00, $12, $A8, $35, $4B, $B8, $35
    DB      $4B, $C8, $35, $4B, $D8, $1D, $43, $E8
    DB      $1D, $43, $D8, $68, $8B, $E8, $68, $8B
    DB      $FE, $9B, $70, $FE, $9E, $70, $FF, $2F
    DB      $00, $A0, $35, $A0, $D4, $5D, $30, $D7
    DB      $6C, $CE, $FA, $1D, $D1, $F8, $01, $00
    DB      $FF, $FE, $A1, $70, $FF, $FF

SUB_89D6:                                  ; SUB_89D6: vine/ground collision probe -- B=Y C=X, test at platform table
    LD      DE, BOOT_UP                    ; LD DE,BOOT_UP: DE=0
    JR      LOC_89F1                       ; JR LOC_89F1

LOC_89DB:                                  ; LOC_89DB: collision probe variant 2 (DE=$0002)
    LD      DE, $0002                      ; LD DE,$0002
    JR      LOC_89EA                       ; JR LOC_89EA

SUB_89E0:                                  ; SUB_89E0: collision probe variant 3 (DE=$0004)
    LD      DE, $0004                      ; LD DE,$0004
    JR      LOC_89F1                       ; JR LOC_89F1

SUB_89E5:                                  ; SUB_89E5: collision probe variant 4 (DE=$0006)
    LD      DE, $0006                      ; LD DE,$0006
    JR      LOC_89EA                       ; JR LOC_89EA

LOC_89EA:                                  ; LOC_89EA: store C at $70A6, load A=B, jump to LOC_89F6
    LD      A, C                           ; LD A,C
    LD      ($70A6), A                     ; LD ($70A6),A
    LD      A, B                           ; LD A,B
    JR      LOC_89F6                       ; JR LOC_89F6

LOC_89F1:                                  ; LOC_89F1: store B at $70A6, load A=C, continue
    LD      A, B                           ; LD A,B
    LD      ($70A6), A                     ; LD ($70A6),A
    LD      A, C                           ; LD A,C

LOC_89F6:                                  ; LOC_89F6: push coord; call SUB_8A31 (get platform table); advance DE
    PUSH    AF                             ; PUSH AF
    CALL    SUB_8A31                       ; CALL SUB_8A31: get platform data pointer by stage type
    POP     AF                             ; POP AF
    ADD     HL, DE                         ; ADD HL,DE: offset into platform table
    LD      E, (HL)                        ; E = (HL): load platform row count
    INC     HL                             ; INC HL: advance to next table entry
    LD      D, (HL)                        ; LD D,(HL): read high byte of address
    DB      $EB                            ; DB $EB: EX DE,HL - swap DE and HL
    LD      B, A                           ; B = A: save coord

LOC_8A01:                                  ; LOC_8A01: scan platform table entries
    LD      A, (HL)                        ; A = (HL): entry byte
    CP      $FF                            ; CP $FF: end of table?
    RET     Z                              ; RET Z
    CP      $FE                            ; CP $FE: extension marker?
    JP      Z, LOC_8A46                    ; JP Z,LOC_8A46
    LD      ($70A7), A                     ; LD ($70A7),A: save entry Y-range
    PUSH    HL                             ; PUSH HL
    LD      H, $04                         ; H = $04: comparison width
    CALL    SUB_A2C3                       ; CALL SUB_A2C3: abs-diff compare A vs B
    POP     HL                             ; POP HL
    JR      C, LOC_8A1B                    ; JR C,LOC_8A1B: within range
    INC     HL                             ; INC HL: skip 3 bytes
    INC     HL                             ; INC HL
    INC     HL                             ; INC HL
    JR      LOC_8A01                       ; JR LOC_8A01

LOC_8A1B:                                  ; LOC_8A1B: Y matched -- check X range
    LD      A, ($70A6)                     ; A = ($70A6): stored X coord
    INC     HL                             ; INC HL
    CP      (HL)                           ; CP (HL): compare X with table lo
    JR      C, LOC_8A2D                    ; JR C,LOC_8A2D: below range
    INC     HL                             ; INC HL
    CP      (HL)                           ; CP (HL): compare X with table hi
    JR      Z, LOC_8A28                    ; JR Z,LOC_8A28: exactly at hi
    JR      NC, LOC_8A2E                   ; JR NC,LOC_8A2E: above range

LOC_8A28:                                  ; LOC_8A28: match -- return entry in A, OR A
    LD      A, ($70A7)                     ; A = ($70A7)
    OR      A                              ; OR A: set flags
    RET                                    ; RET

LOC_8A2D:                                  ; LOC_8A2D: advance HL by 1 and retry scan
    INC     HL                             ; INC HL: skip one byte

LOC_8A2E:                                  ; LOC_8A2E: advance HL by 1 more and loop
    INC     HL                             ; INC HL: advance pointer
    JR      LOC_8A01                       ; JR LOC_8A01: back to scan loop top

SUB_8A31:                                  ; SUB_8A31: get platform table pointer by stage type ($7288)
    LD      A, ($7288)                     ; A = ($7288): 0=vine 1=rope 2=croc
    DEC     A                              ; DEC A
    JR      Z, LOC_8A3E                    ; JR Z,LOC_8A3E: type 1
    DEC     A                              ; DEC A
    JR      Z, LOC_8A42                    ; JR Z,LOC_8A42: type 2
    LD      HL, $8898                      ; HL = $8898: vine stage platform table
    RET                                    ; RET

LOC_8A3E:                                  ; LOC_8A3E: HL=$8922: rope stage platform table
    LD      HL, $8922                      ; HL = $8922
    RET                                    ; RET: return from LOC_8A3E with HL = rope platform table

LOC_8A42:                                  ; LOC_8A42: HL=$895B: croc stage platform table
    LD      HL, $895B                      ; HL = $895B
    RET                                    ; RET: return from LOC_8A42 with HL = croc platform table

LOC_8A46:                                  ; LOC_8A46: collision table entry processing
    INC     HL                             ; INC HL: advance to X low byte
    LD      E, (HL)                        ; LD E,(HL): read X low
    INC     HL                             ; INC HL: advance to X high byte
    LD      D, (HL)                        ; LD D,(HL): read X high byte
    INC     HL                             ; INC HL: advance past X
    LD      ($70A4), HL                    ; LD ($70A4),HL: save current table pointer
    DB      $EB                            ; DB $EB: EX DE,HL - swap DE/HL
    LD      A, (HL)                        ; LD A,(HL): read X position byte
    LD      ($70A7), A                     ; LD ($70A7),A: save X for later compare
    PUSH    HL                             ; PUSH HL: save pointer
    LD      H, $04                         ; LD H,$04: proximity threshold
    CALL    SUB_A2C3                       ; CALL SUB_A2C3: check proximity to player
    POP     HL                             ; POP HL: restore pointer
    JR      C, LOC_8A62                    ; JR C,LOC_8A62: if within range, check further

LOC_8A5C:                                  ; LOC_8A5C: restore pointer and continue scan
    LD      HL, ($70A4)                    ; LD HL,($70A4): reload saved table pointer
    JP      LOC_8A01                       ; JP LOC_8A01: continue main scan loop

LOC_8A62:                                  ; LOC_8A62: fine collision check
    INC     HL                             ; INC HL: advance to Y-min byte
    LD      A, ($70A6)                     ; LD A,($70A6): read player Y position
    CP      (HL)                           ; CP (HL): compare player Y with Y-min
    JR      C, LOC_8A5C                    ; JR C,LOC_8A5C: player above range, no hit
    INC     HL                             ; INC HL: advance to Y-max byte
    CP      (HL)                           ; CP (HL): compare player Y with Y-max
    JR      NC, LOC_8A5C                   ; JR NC,LOC_8A5C: player below range, no hit
    LD      A, ($70A7)                     ; LD A,($70A7): reload saved X byte
    OR      A                              ; OR A: test X for zero (collision flag)
    RET                                    ; RET: return with Z=1 if collision

SUB_8A72:                                  ; SUB_8A72: check if other player should take over when lives < 2
    LD      A, ($7285)                     ; A = ($7285): 2-player mode flag
    DEC     A                              ; DEC A: 1-player?
    JR      NZ, LOC_8A7B                   ; JR NZ,LOC_8A7B: 2-player
    LD      ($729E), A                     ; LD ($729E),A: clear P2 score display

LOC_8A7B:                                  ; LOC_8A7B
    CALL    SUB_A4FD                       ; CALL SUB_A4FD: IX=current player IY=other
    DEC     A                              ; DEC A
    LD      HL, $8AF0                      ; HL = $8AF0: vine type table
    LD      B, $31                         ; B=$31: platform type A
    JR      Z, LOC_8A89                    ; JR Z,LOC_8A89
    DEC     A                              ; DEC A
    LD      B, $32                         ; B=$32: platform type B

LOC_8A89:                                  ; LOC_8A89: compare player X with sprite bounds
    CP      (IX+0)                         ; CP (IX+0): compare player X with sprite left edge
    RET     NZ                             ; RET NZ: no match, return
    CP      (IY+0)                         ; CP (IY+0): compare with alternate bound
    JR      Z, LOC_8A94                    ; JR Z,LOC_8A94: if equal, draw success tiles
    JR      LOC_8AB3                       ; JR LOC_8AB3: jump to fail path

LOC_8A94:                                  ; LOC_8A94: draw success vine tile sequence
    LD      HL, $19AA                      ; LD HL,$19AA: VRAM address for success tiles
    LD      B, $03                         ; LD B,$03: 3 tile rows

LOC_8A99:                                  ; LOC_8A99: success tile draw loop
    PUSH    BC                             ; PUSH BC: save row counter
    PUSH    HL                             ; PUSH HL: save VRAM pointer
    XOR     A                              ; XOR A: fill value 0
    LD      DE, $000C                      ; LD DE,$000C: tile count per row
    RST     $18                            ; RST $18: BIOS block fill
    POP     HL                             ; POP HL: restore VRAM pointer
    POP     BC                             ; POP BC: restore row counter
    LD      DE, $0020                      ; LD DE,$0020: row advance (32 tiles)
    ADD     HL, DE                         ; ADD HL,DE: advance to next row
    DJNZ    LOC_8A99                       ; DJNZ LOC_8A99: loop 3 rows
    LD      DE, $19CB                      ; LD DE,$19CB: source data for final tile row
    LD      HL, $8AE5                      ; LD HL,$8AE5: dest data pointer
    LD      BC, $000B                      ; LD BC,$000B: 11 bytes to copy
    RST     $08                            ; RST $08: BIOS LDIR block copy
    RET                                    ; RET: return from success tile draw

LOC_8AB3:                                  ; LOC_8AB3: fail path - blank two tile rows
    PUSH    BC                             ; PUSH BC: save counter
    PUSH    HL                             ; PUSH HL: save pointer
    LD      A, $00                         ; LD A,$00: fill value
    LD      HL, $1800                      ; LD HL,$1800: VRAM name table row
    LD      DE, $0300                      ; LD DE,$0300: row offset
    RST     $18                            ; RST $18: BIOS fill
    LD      DE, $19C8                      ; LD DE,$19C8: source tile row data
    LD      BC, $0011                      ; LD BC,$0011: 17 bytes
    POP     HL                             ; POP HL: restore dest pointer
    PUSH    BC                             ; PUSH BC: save count
    PUSH    DE                             ; PUSH DE: save source
    RST     $08                            ; RST $08: BIOS copy
    POP     HL                             ; POP HL: restore HL from stack
    POP     BC                             ; POP BC: restore BC
    ADD     HL, BC                         ; ADD HL,BC: advance dest pointer
    LD      DE, $0001                      ; LD DE,$0001: increment
    POP     BC                             ; POP BC: restore outer counter
    LD      A, B                           ; LD A,B: get count in A
    RST     $18                            ; RST $18: BIOS fill
    LD      HL, $0078                      ; LD HL,$0078: signal delay value
    LD      A, $00                         ; LD A,$00: signal channel 0
    CALL    REQUEST_SIGNAL                 ; CALL REQUEST_SIGNAL: request audio signal
    LD      ($70AA), A                  ; RAM $70AA

LOC_8ADC:                                  ; LOC_8ADC: wait for signal $70AA
    LD      A, ($70AA)                     ; LD A,($70AA): read signal flag
    CALL    TEST_SIGNAL                    ; CALL TEST_SIGNAL: test if signal active
    RET     NZ                             ; RET NZ: return if signal fired
    JR      LOC_8ADC                       ; JR LOC_8ADC: spin-wait loop
    DB      $21, $1C, $23, $1D, $00, $00, $1E, $27
    DB      $1D, $25, $00, $21, $1C, $23, $1D, $00
    DB      $1E, $27, $1D, $25, $00, $24, $22, $1C
    DB      $28, $1D, $25, $00, $21, $1D, $26, $00
    DB      $25, $1D, $1C, $2B, $28, $00, $24, $22
    DB      $1C, $28, $1D, $25, $00

SOUND_WRITE_8B12:                          ; SOUND_WRITE_8B12: vine-match sound lookup and play
    LD      A, ($7288)                     ; LD A,($7288): read player number
    LD      L, A                           ; LD L,A: L = player number
    LD      H, $00                         ; LD H,$00: HL = player number
    ADD     HL, HL                         ; ADD HL,HL: HL *= 2
    ADD     HL, DE                         ; ADD HL,DE: HL = base + player offset
    DB      $EB                            ; DB $EB: EX DE,HL
    LD      A, (DE)                        ; LD A,(DE): read sound table entry low
    LD      L, A                           ; LD L,A: L = low byte of sound pointer
    INC     DE                             ; INC DE: advance to high byte
    LD      A, (DE)                        ; LD A,(DE): read sound table entry high
    LD      H, A                           ; LD H,A: H = high byte of sound pointer

LOC_8B20:                                  ; LOC_8B20: scan sound entry list
    LD      A, (HL)                        ; LD A,(HL): read sound list byte
    CP      $FF                            ; CP $FF: check end marker
    RET     Z                              ; RET Z: return at end of list
    CP      C                              ; CP C: compare with target X
    JR      NC, LOC_8B3C                   ; JR NC,LOC_8B3C: if >= target X, skip entry
    INC     HL                             ; INC HL: advance to Y-min
    LD      A, (HL)                        ; LD A,(HL): read Y-min
    CP      C                              ; CP C: compare Y-min with target
    JR      C, LOC_8B3D                    ; JR C,LOC_8B3D: if Y-min > target, skip
    INC     HL                             ; INC HL: advance to third byte
    LD      A, (HL)                        ; LD A,(HL): read proximity delta
    ADD     A, $FD                         ; ADD A,$FD: bias proximity delta
    CP      B                              ; CP B: compare with B
    JR      NC, LOC_8B3E                   ; JR NC,LOC_8B3E: out of range, skip
    ADD     A, $05                         ; ADD A,$05: extend range check
    CP      B                              ; CP B: compare again
    JR      C, LOC_8B3E                    ; JR C,LOC_8B3E: still out of range, skip
    LD      A, $01                         ; LD A,$01: match found, A=1
    OR      A                              ; OR A: set flags
    RET                                    ; RET: return with match

LOC_8B3C:                                  ; LOC_8B3C: advance past first byte of entry
    INC     HL                             ; INC HL: skip X byte

LOC_8B3D:                                  ; LOC_8B3D: advance past second byte
    INC     HL                             ; INC HL: skip Y-min byte

LOC_8B3E:                                  ; LOC_8B3E: advance past third byte and loop
    INC     HL                             ; INC HL: skip third byte
    JR      LOC_8B20                       ; JR LOC_8B20: next entry
    DB      $C9

SUB_8B42:                                  ; SUB_8B42: Kong/Pauline subsystem -- animate Kong, drop fruit, check player kill
    LD      A, ($7286)                     ; A = ($7286): current player
    DEC     A                              ; DEC A
    LD      IX, ($8008)                    ; IX = ($8008): Kong entity pointer
    LD      A, (IX+3)                      ; A = (IX+3): Kong Y
    LD      B, (IX+2)                      ; B = (IX+2): Kong X
    LD      C, (IX+5)                      ; C = (IX+5): Kong extra
    JR      Z, LOC_8B5E                    ; JR Z,LOC_8B5E: player 1
    LD      A, (IX+8)                      ; A = (IX+8): player 2 offset Y
    LD      B, (IX+7)                      ; B = (IX+7)
    LD      C, (IX+10)                     ; C = (IX+10)

LOC_8B5E:                                  ; LOC_8B5E: setup Kong parameters
    LD      HL, $70AB                      ; HL = $70AB: Kong state variable
    LD      (HL), A                        ; LD (HL),A: Kong Y
    LD      A, B                           ; A = B
    LD      ($70AD), A                     ; LD ($70AD),A: Kong X
    LD      A, C                           ; A = C
    LD      ($70AE), A                     ; LD ($70AE),A: Kong extra param
    LD      A, ($708B)                     ; A = ($708B): Kong phase (0=ground 1=mid 2=top 3=off)
    OR      A                              ; OR A
    JR      Z, LOC_8B91                    ; JR Z,LOC_8B91: phase 0
    DEC     A                              ; DEC A
    JR      Z, LOC_8B7A                    ; JR Z,LOC_8B7A: phase 1
    DEC     A                              ; DEC A
    JP      Z, LOC_9272                    ; JP Z,LOC_9272: phase 2
    JP      LOC_8D0B                       ; JP LOC_8D0B: phase 3 (off-screen)

LOC_8B7A:                                  ; LOC_8B7A: Kong phase 1 -- mid-screen animation
    LD      A, (HL)                        ; A = (HL): Kong state
    OR      A                              ; OR A
    RET     Z                              ; RET Z: idle
    LD      A, (HL)                        ; A = (HL)
    AND     $05                            ; AND $05: test movement bits
    JR      Z, LOC_8B8E                    ; JR Z,LOC_8B8E: no movement
    LD      (HL), A                        ; LD (HL),A
    LD      A, ($70AC)                     ; A = ($70AC): side (0=left 1=right)
    CP      $02                            ; CP $02
    JP      Z, LOC_901E                    ; JP Z,LOC_901E: right side -- check player Y
    JP      LOC_8F0F                       ; JP LOC_8F0F: left side

LOC_8B8E:                                  ; LOC_8B8E
    JP      LOC_9106                       ; JP LOC_9106: movement completed

LOC_8B91:                                  ; LOC_8B91: Kong phase 0 -- ground-level movement
    LD      A, (HL)                        ; A = (HL): Kong state
    AND     $0A                            ; AND $0A: test ground-movement bits
    LD      (HL), A                        ; LD (HL),A
    OR      A                              ; OR A
    CALL    NZ, SUB_8BBD                   ; CALL NZ,SUB_8BBD: if moving -- update Kong animation
    CALL    SUB_8BA6                       ; CALL SUB_8BA6: check X boundary
    JP      NZ, LOC_8CA8                   ; JP NZ,LOC_8CA8: at boundary -- change direction
    CALL    SUB_8BAE                       ; CALL SUB_8BAE: check Y boundary
    JP      NZ, LOC_8CA8                   ; JP NZ,LOC_8CA8
    RET                                    ; RET: return if Kong within X and Y movement bounds

SUB_8BA6:                                  ; SUB_8BA6: check if Kong X at boundary $70AD
    LD      A, ($70AD)                     ; A = ($70AD)
    LD      HL, $70AF                      ; HL = $70AF
    JR      LOC_8BB4                       ; JR LOC_8BB4

SUB_8BAE:                                  ; SUB_8BAE: check if Kong Y at boundary $70AE
    LD      A, ($70AE)                     ; A = ($70AE)
    LD      HL, $70B0                      ; HL = $70B0

LOC_8BB4:                                  ; LOC_8BB4: compare A vs (HL)
    OR      A                              ; OR A
    JR      Z, LOC_8BBB                    ; JR Z,LOC_8BBB
    LD      A, $40                         ; LD A,$40
    CP      (HL)                           ; CP (HL)
    RET     Z                              ; RET Z: return if (HL) = $40

LOC_8BBB:                                  ; LOC_8BBB: write A to (HL)
    LD      (HL), A                        ; LD (HL),A: store value at HL
    RET                                    ; RET: return

SUB_8BBD:                                  ; SUB_8BBD: Kong animation -- decrement frame timer $7082; advance IY sprite
    LD      HL, $7082                      ; HL = $7082: Kong frame timer
    DEC     (HL)                           ; DEC (HL)
    RET     NZ                             ; RET NZ: not expired
    LD      (HL), $07                      ; LD (HL),$07: reload 7 ticks
    LD      IY, $71EE                      ; IY = $71EE: Kong sprite structure
    LD      A, ($70AB)                     ; A = ($70AB): Kong state
    CP      $08                            ; CP $08
    JR      NZ, LOC_8C1F                   ; JR NZ,LOC_8C1F: not max
    LD      A, ($7089)                  ; RAM $7089
    CP      $08                            ; CP $08: check Kong Y phase = 8
    JR      Z, LOC_8BF3                    ; JR Z,LOC_8BF3: if phase 8, enter landing sequence

LOC_8BD6:                                  ; LOC_8BD6: set Kong sprite to neutral pose
    LD      (IY+0), $04                    ; LD (IY+0),$04: set IY sprite type = 4
    LD      A, $04                         ; LD A,$04: value 4
    LD      ($708A), A                     ; LD ($708A),A: store Kong direction state
    LD      A, $08                         ; LD A,$08: Kong Y boundary value
    LD      ($7089), A                  ; RAM $7089
    LD      A, ($70B1)                  ; RAM $70B1
    CP      (IY+1)                         ; CP (IY+1): compare A with Kong Y position
    JP      C, LOC_8CA5                    ; JP C,LOC_8CA5: if below, go to main loop
    LD      (IY+1), A                      ; LD (IY+1),A: update Kong Y position
    JP      LOC_8CA5                       ; JP LOC_8CA5: continue main loop

LOC_8BF3:                                  ; LOC_8BF3: Kong landing sequence
    LD      C, (IY+3)                      ; LD C,(IY+3): C = Kong X position
    LD      B, (IY+1)                      ; LD B,(IY+1): B = Kong Y position
    CALL    LOC_89DB                       ; CALL LOC_89DB: check vine collision at (B,C)
    POP     BC                             ; POP BC: restore saved BC
    JP      NZ, LOC_8D6F                   ; JP NZ,LOC_8D6F: if blocked, deflect
    PUSH    BC                             ; PUSH BC: re-save BC
    LD      B, (IY+1)                      ; LD B,(IY+1): B = Kong Y
    LD      A, (IY+3)                      ; LD A,(IY+3): A = Kong X
    ADD     A, $0A                         ; ADD A,$0A: X offset for grab check
    LD      C, A                           ; LD C,A: C = adjusted X
    CALL    SUB_89E5                       ; CALL SUB_89E5: check platform/vine at (B,C)
    POP     HL                             ; POP HL: restore stack as HL
    JR      NZ, LOC_8C86                   ; JR NZ,LOC_8C86: if blocked, look up next state
    PUSH    HL                             ; PUSH HL: re-save
    LD      A, ($70B1)                     ; LD A,($70B1): read Kong climb limit high
    CP      (IY+1)                         ; CP (IY+1): compare with Kong Y
    RET     NC                             ; RET NC: if at limit, stop
    LD      A, (IY+1)                      ; LD A,(IY+1): A = current Kong Y
    ADD     A, $FC                         ; ADD A,$FC: subtract 4 from Y (move up)
    JR      LOC_8C5F                       ; JR LOC_8C5F: apply new Y

LOC_8C1F:                                  ; LOC_8C1F: check Kong direction flag
    LD      A, ($7089)                     ; LD A,($7089): read Kong direction (0=right,2=left)
    CP      $02                            ; CP $02: is Kong going left?
    JR      Z, LOC_8C41                    ; JR Z,LOC_8C41: if left, handle left movement

LOC_8C26:                                  ; LOC_8C26: Kong moving right - set forward pose
    LD      (IY+0), $01                    ; LD (IY+0),$01: sprite type 1 (right-facing)
    LD      A, $02                         ; LD A,$02: state 2
    LD      ($708A), A                     ; LD ($708A),A: store Kong movement state
    LD      A, $02                         ; LD A,$02: Y step for right movement
    LD      ($7089), A                  ; RAM $7089
    LD      A, ($70B2)                  ; RAM $70B2
    CP      (IY+1)                         ; CP (IY+1): compare Y step with Kong Y
    JR      NC, LOC_8CA5                   ; JR NC,LOC_8CA5: at edge, jump to main loop
    LD      (IY+1), A                      ; LD (IY+1),A: update Kong Y position
    JR      LOC_8CA5                       ; JR LOC_8CA5: continue main loop

LOC_8C41:                                  ; LOC_8C41: Kong moving left - check vine above
    LD      C, (IY+3)                      ; LD C,(IY+3): C = Kong X
    LD      A, (IY+1)                      ; LD A,(IY+1): A = Kong Y
    ADD     A, $12                         ; ADD A,$12: Y offset $12 above Kong
    LD      B, A                           ; LD B,A: B = check Y position
    CALL    LOC_89DB                       ; CALL LOC_89DB: check vine at (B,C)
    POP     BC                             ; POP BC: restore BC
    JP      NZ, LOC_8D6F                   ; JP NZ,LOC_8D6F: if blocked, deflect
    PUSH    BC                             ; PUSH BC: re-save
    LD      A, ($70B2)                     ; LD A,($70B2): read Kong Y lower limit
    CP      (IY+1)                         ; CP (IY+1): compare with current Y
    RET     Z                              ; RET Z: at bottom, stop
    RET     C                              ; RET C: already past bottom, stop
    LD      A, (IY+1)                      ; LD A,(IY+1): current Kong Y
    ADD     A, $04                         ; ADD A,$04: move down 4 pixels

LOC_8C5F:                                  ; LOC_8C5F: store new Kong Y and check landing
    LD      (IY+1), A                      ; LD (IY+1),A: update Kong Y
    ADD     A, $08                         ; ADD A,$08: add 8 for collision check
    LD      B, A                           ; LD B,A: B = lower edge
    LD      A, (IY+3)                      ; LD A,(IY+3): A = Kong X
    ADD     A, $0F                         ; ADD A,$0F: X offset for landing check
    LD      C, A                           ; LD C,A: C = adjusted X
    CALL    SUB_89D6                       ; CALL SUB_89D6: check surface at (B,C)
    JR      NZ, LOC_8C86                   ; JR NZ,LOC_8C86: if surface found, look up state
    POP     BC                             ; POP BC: restore BC
    LD      A, ($7089)                     ; LD A,($7089): read direction flag
    CP      $02                            ; CP $02: is Kong going left?
    LD      A, $01                         ; LD A,$01: state for right-direction landing
    LD      HL, $93E6                      ; LD HL,$93E6: animation table for landing right
    JP      Z, LOC_9260                    ; JP Z,LOC_9260: jump if going left
    LD      A, $00                         ; LD A,$00: state for left-direction landing
    LD      HL, $93FD                      ; LD HL,$93FD: animation table for landing left
    JP      LOC_9260                       ; JP LOC_9260: dispatch to animation

LOC_8C86:                                  ; LOC_8C86: look up next Kong state from table
    LD      A, ($708A)                     ; LD A,($708A): read current Kong movement state
    LD      L, A                           ; LD L,A: L = state index
    LD      H, $00                         ; LD H,$00: H = 0 for 16-bit index
    ADD     HL, HL                         ; ADD HL,HL: HL *= 2
    LD      DE, $9392                      ; LD DE,$9392: Kong state table base
    ADD     HL, DE                         ; ADD HL,DE: HL = table entry address
    LD      A, (HL)                        ; LD A,(HL): read state sprite type
    LD      (IY+0), A                      ; LD (IY+0),A: store new sprite type
    INC     HL                             ; INC HL: advance to second byte
    LD      A, (HL)                        ; LD A,(HL): read second state byte
    LD      ($708A), A                  ; RAM $708A
    LD      HL, $7088                   ; RAM $7088
    DEC     (HL)                           ; DEC (HL): decrement hit count
    JR      NZ, LOC_8CA5                   ; JR NZ,LOC_8CA5: if not zero, continue
    LD      (HL), $02                      ; LD (HL),$02: reset hit count to 2
    CALL    SUB_A6D9                       ; CALL SUB_A6D9: trigger Kong hit sound/event

LOC_8CA5:                                  ; LOC_8CA5: jump to DELAY_LOOP_950B
    JP      DELAY_LOOP_950B                ; JP DELAY_LOOP_950B: main loop throttle

LOC_8CA8:                                  ; LOC_8CA8: compute Kong animation state from flags
    XOR     A                              ; XOR A: A = 0
    LD      ($70B7), A                     ; LD ($70B7),A: clear Kong hit flag
    LD      A, ($70AB)                     ; LD A,($70AB): read Kong phase flag
    OR      A                              ; OR A: test if nonzero
    LD      A, $00                         ; LD A,$00: default state 0
    JR      Z, LOC_8CBF                    ; JR Z,LOC_8CBF: if phase 0, use default
    LD      A, ($7089)                     ; LD A,($7089): read Kong direction
    CP      $02                            ; CP $02: is direction left?
    LD      A, $02                         ; LD A,$02: state for left direction
    JR      Z, LOC_8CBF                    ; JR Z,LOC_8CBF: if left, use state 2
    LD      A, $03                         ; LD A,$03: state for right direction

LOC_8CBF:                                  ; LOC_8CBF: compute Kong animation pointer
    LD      IY, $71EE                   ; RAM $71EE
    LD      ($70B3), A                  ; RAM $70B3
    ADD     A, A                           ; ADD A,A: A *= 2 for table index
    LD      C, A                           ; LD C,A: C = table byte offset
    LD      B, $00                         ; LD B,$00: B = 0
    LD      IX, $938A                      ; LD IX,$938A: Kong animation table base
    ADD     IX, BC                         ; ADD IX,BC: IX = animation entry
    LD      H, (IX+1)                      ; LD H,(IX+1): H = animation address high
    LD      L, (IX+0)                      ; LD L,(IX+0): L = animation address low
    LD      ($70B4), HL                    ; LD ($70B4),HL: save animation pointer
    XOR     A                              ; XOR A: A = 0
    LD      ($70B6), A                     ; LD ($70B6),A: clear animation frame counter
    CALL    SOUND_WRITE_A6BD               ; CALL SOUND_WRITE_A6BD: play Kong roar sound
    CALL    DELAY_LOOP_8EE2                ; CALL DELAY_LOOP_8EE2: wait one vblank frame
    LD      A, ($708B)                     ; LD A,($708B): read Kong phase counter
    CP      $02                            ; CP $02: compare with phase 2
    LD      A, $03                         ; LD A,$03: next phase = 3
    LD      ($708B), A                     ; LD ($708B),A: store new phase
    JR      NZ, LOC_8CF5                   ; JR NZ,LOC_8CF5: if not phase 2, skip decrement
    LD      A, ($70BD)                     ; LD A,($70BD): read barrel counter
    DEC     A                              ; DEC A: decrement barrel counter
    JR      LOC_8CFA                       ; JR LOC_8CFA: store barrel count

LOC_8CF5:                                  ; LOC_8CF5: read direction for barrel offset
    LD      A, ($7089)                     ; LD A,($7089): read Kong direction flag
    CP      $02                            ; CP $02: is Kong going left?

LOC_8CFA:                                  ; LOC_8CFA: set barrel launch tile
    LD      HL, $71EE                      ; LD HL,$71EE: barrel tile pointer
    LD      (HL), $06                      ; LD (HL),$06: set barrel tile to 6
    JR      Z, LOC_8D03                    ; JR Z,LOC_8D03: if left, use tile 6
    LD      (HL), $07                      ; LD (HL),$07: set barrel tile to 7 (right)

LOC_8D03:                                  ; LOC_8D03: set Kong active and jump to state machine
    LD      HL, $7083                      ; LD HL,$7083: Kong active flag
    LD      (HL), $01                      ; LD (HL),$01: mark Kong active
    JP      LOC_8E47                       ; JP LOC_8E47: jump to state dispatch

LOC_8D0B:                                  ; LOC_8D0B: Kong active timer countdown
    LD      HL, $7083                      ; LD HL,$7083: Kong active timer
    DEC     (HL)                           ; DEC (HL): decrement timer
    RET     NZ                             ; RET NZ: if not expired, return
    LD      (HL), $04                      ; LD (HL),$04: reload timer to 4
    LD      IY, $71EE                   ; RAM $71EE
    LD      A, ($7089)                  ; RAM $7089
    CP      $02                            ; CP $02: is phase 2 (left approach)?
    LD      A, $12                         ; LD A,$12: Y offset $12 for left
    JR      Z, LOC_8D21                    ; JR Z,LOC_8D21: if phase 2, use $12 offset
    LD      A, $02                         ; LD A,$02: Y offset $02 for right

LOC_8D21:                                  ; LOC_8D21: compute Kong grab check position
    ADD     A, (IY+1)                      ; ADD A,(IY+1): add Kong Y
    LD      B, A                           ; LD B,A: B = check Y
    LD      C, (IY+3)                      ; LD C,(IY+3): C = Kong X
    CALL    SUB_9441                       ; CALL SUB_9441: platform collision at (B,C)
    LD      A, (IY+1)                      ; LD A,(IY+1): current Kong Y
    ADD     A, $09                         ; ADD A,$09: Y + 9 for body check
    LD      B, A                           ; LD B,A: B = body check Y
    LD      A, (IY+3)                      ; LD A,(IY+3): Kong X
    ADD     A, $08                         ; ADD A,$08: X + 8 for body check
    LD      C, A                           ; LD C,A: C = body check X
    CALL    SUB_89E0                       ; CALL SUB_89E0: check vine at body position
    JR      Z, LOC_8D4F                    ; JR Z,LOC_8D4F: if vine found, proceed to drop
    LD      (IY+3), A                      ; LD (IY+3),A: update Kong X from vine hit
    LD      A, ($7089)                     ; LD A,($7089): read direction flag
    CP      $02                            ; CP $02: is Kong going left?
    LD      A, $01                         ; LD A,$01: animation index for left
    JR      Z, LOC_8D49                    ; JR Z,LOC_8D49: if left, use index 1
    XOR     A                              ; XOR A: animation index 0 for right

LOC_8D49:                                  ; LOC_8D49: dispatch to animation table
    LD      HL, $93D5                      ; LD HL,$93D5: Kong animation dispatch table
    JP      LOC_9260                       ; JP LOC_9260: animate Kong

LOC_8D4F:                                  ; LOC_8D4F: compute Kong drop start
    LD      HL, ($70B4)                    ; LD HL,($70B4): load animation pointer
    CALL    SUB_8E50                       ; CALL SUB_8E50: check Kong drop boundary
    LD      A, ($7089)                     ; LD A,($7089): read direction
    CP      $02                            ; CP $02: is going left?
    LD      A, $10                         ; LD A,$10: X offset $10 for left
    JR      Z, LOC_8D60                    ; JR Z,LOC_8D60: if left, use $10
    LD      A, $03                         ; LD A,$03: X offset $03 for right

LOC_8D60:                                  ; LOC_8D60: check vine at computed X offset
    ADD     A, (IY+1)                      ; ADD A,(IY+1): add Kong Y
    LD      B, A                           ; LD B,A: B = check Y
    LD      A, (IY+3)                      ; LD A,(IY+3): Kong X
    ADD     A, $02                         ; ADD A,$02: X + 2
    LD      C, A                           ; LD C,A: C = check X
    CALL    LOC_89DB                       ; CALL LOC_89DB: check vine at (B,C)
    JR      Z, LOC_8D90                    ; JR Z,LOC_8D90: if vine found, go to drop

LOC_8D6F:                                  ; LOC_8D6F: Kong vine deflection
    LD      L, A                           ; LD L,A: save vine offset in L
    LD      A, ($7089)                     ; LD A,($7089): read direction
    CP      $02                            ; CP $02: left?
    LD      A, $F6                         ; LD A,$F6: deflect amount -10 for left
    JR      Z, LOC_8D7B                    ; JR Z,LOC_8D7B: if left, use -10
    LD      A, $FD                         ; LD A,$FD: deflect -3 for right

LOC_8D7B:                                  ; LOC_8D7B: apply X deflection to Kong
    ADD     A, L                           ; ADD A,L: add vine offset
    LD      (IY+1), A                      ; LD (IY+1),A: update Kong Y with deflection
    LD      A, $01                         ; LD A,$01: state 1 after deflect
    LD      ($708B), A                  ; RAM $708B
    LD      A, ($7089)                  ; RAM $7089
    CP      $02                            ; CP $02: check if direction is 2
    JP      Z, LOC_8EF5                    ; JP Z,LOC_8EF5: if direction 2, go right-fall path
    JP      LOC_8F03                       ; JP LOC_8F03: otherwise left-fall path
    DB      $C9

LOC_8D90:                                  ; LOC_8D90: Kong on-vine drop sequence
    LD      A, (IY+3)                      ; LD A,(IY+3): Kong X
    ADD     A, $0E                         ; ADD A,$0E: X + 14
    LD      C, A                           ; LD C,A: C = right-edge X
    LD      A, $09                         ; LD A,$09: Y offset 9
    ADD     A, (IY+1)                      ; ADD A,(IY+1): add Kong Y
    LD      B, A                           ; LD B,A: B = lower-body Y
    CALL    SUB_89D6                       ; CALL SUB_89D6: check surface below
    JP      NZ, LOC_8DBA                   ; JP NZ,LOC_8DBA: if surface, check for Jr hit
    LD      A, (IY+3)                      ; LD A,(IY+3): Kong X
    ADD     A, $0E                         ; ADD A,$0E: X + 14
    LD      C, A                           ; LD C,A: right-edge X
    LD      A, $02                         ; LD A,$02: Y offset 2
    ADD     A, (IY+1)                      ; ADD A,(IY+1): add Kong Y
    LD      B, A                           ; LD B,A: B = upper-body Y
    CALL    SUB_89E5                       ; CALL SUB_89E5: check vine above
    JP      Z, LOC_8E37                    ; JP Z,LOC_8E37: if vine above, check hit state
    LD      (IY+1), A                      ; LD (IY+1),A: update Kong Y from vine
    JP      LOC_8E37                       ; JP LOC_8E37: check hit state

LOC_8DBA:                                  ; LOC_8DBA: Kong-Jr proximity check for capture
    ADD     A, $F0                         ; ADD A,$F0: subtract 16 from vine offset
    LD      L, A                           ; LD L,A: save in L
    LD      A, ($7288)                     ; LD A,($7288): read current player number
    CP      $02                            ; CP $02: is player 2?
    JR      NZ, LOC_8E04                   ; JR NZ,LOC_8E04: if not P2, skip capture path
    LD      A, (IY+1)                      ; LD A,(IY+1): Kong Y
    CP      $7F                            ; CP $7F: compare with Jr Y boundary
    JR      NC, LOC_8E04                   ; JR NC,LOC_8E04: if Kong below $7F, skip
    LD      A, (IY+3)                      ; LD A,(IY+3): Kong X
    ADD     A, $0F                         ; ADD A,$0F: X + 15
    CP      $A8                            ; CP $A8: compare with Jr X boundary
    JR      C, LOC_8E04                    ; JR C,LOC_8E04: if Kong left of Jr, skip
    CALL    SUB_8BA6                       ; CALL SUB_8BA6: check Kong hit flag
    JR      NZ, LOC_8DDE                   ; JR NZ,LOC_8DDE: if not hit, try alternate
    CALL    SUB_8BAE                       ; CALL SUB_8BAE: check Kong grab state
    JR      Z, LOC_8DE8                    ; JR Z,LOC_8DE8: if grab active, set capture state 2

LOC_8DDE:                                  ; LOC_8DDE: set Kong capture state 1
    LD      A, ($7089)                     ; LD A,($7089): read direction
    CP      $02                            ; CP $02: left direction?
    LD      A, $01                         ; LD A,$01: capture state 1
    JP      Z, LOC_8DF4                    ; JP Z,LOC_8DF4: if left, go to capture dispatch

LOC_8DE8:                                  ; LOC_8DE8: set Kong capture state 2
    LD      A, ($7089)                     ; LD A,($7089): read direction
    CP      $02                            ; CP $02: left direction?
    LD      A, $02                         ; LD A,$02: capture state 2
    JP      Z, LOC_8DF4                    ; JP Z,LOC_8DF4: if left, go to capture dispatch
    LD      A, $03                         ; LD A,$03: capture state 3 (right side)

LOC_8DF4:                                  ; LOC_8DF4: dispatch Kong capture animation
    LD      HL, $8EED                      ; LD HL,$8EED: capture animation table pointer
    PUSH    AF                             ; PUSH AF: save capture state
    CALL    SUB_8ED1                       ; CALL SUB_8ED1: run capture animation
    LD      A, $01                         ; LD A,$01: set hit flag
    LD      ($70B7), A                     ; LD ($70B7),A: store Kong hit flag
    POP     AF                             ; POP AF: restore state
    JP      LOC_8CBF                       ; JP LOC_8CBF: re-enter Kong state machine

LOC_8E04:                                  ; LOC_8E04: Kong free-fall update
    LD      A, ($70B6)                     ; LD A,($70B6): read fall frame counter
    CP      $20                            ; CP $20: compare with 32
    JR      C, LOC_8E13                    ; JR C,LOC_8E13: if early in fall, update Y
    OR      A                              ; OR A: test if zero
    JP      M, LOC_8E13                    ; JP M,LOC_8E13: if negative, update Y
    POP     HL                             ; POP HL: discard saved HL
    JP      LOC_A172                       ; JP LOC_A172: jump to game-over / Jr-fall handler

LOC_8E13:                                  ; LOC_8E13: update Kong X during fall
    LD      (IY+3), L                      ; LD (IY+3),L: update Kong X from vine
    XOR     A                              ; XOR A: clear A
    LD      ($708B), A                  ; RAM $708B
    LD      A, ($70B3)                  ; RAM $70B3
    CP      $01                            ; CP $01: check Kong sprite type = 1
    JP      Z, LOC_8C26                    ; JP Z,LOC_8C26: if type 1, go to right-movement path
    CP      $02                            ; CP $02: check type 2
    JP      Z, LOC_8C26                    ; JP Z,LOC_8C26: if type 2, also right-movement path
    CP      $03                            ; CP $03: check type 3
    JP      Z, LOC_8BD6                    ; JP Z,LOC_8BD6: if type 3, neutral pose
    LD      A, ($7089)                     ; LD A,($7089): read direction flag
    CP      $02                            ; CP $02: is direction 2 (left)?
    JP      NZ, LOC_8BD6                   ; JP NZ,LOC_8BD6: if not left, neutral pose
    JP      LOC_8C26                       ; JP LOC_8C26: left direction, right-movement path

LOC_8E37:                                  ; LOC_8E37: check and clear Kong hit flag
    LD      A, ($70B7)                     ; LD A,($70B7): read Kong hit flag
    OR      A                              ; OR A: test flag
    JR      Z, LOC_8E47                    ; JR Z,LOC_8E47: if no hit, go to state dispatch
    LD      HL, $8EF1                      ; LD HL,$8EF1: hit animation data pointer
    CALL    SUB_8ED1                       ; CALL SUB_8ED1: run hit animation
    XOR     A                              ; XOR A: clear A
    LD      ($70B7), A                  ; RAM $70B7

LOC_8E47:                                  ; LOC_8E47: call Kong position checkers
    CALL    SUB_8BA6                       ; CALL SUB_8BA6: check Kong hit flag at ($70B0)
    CALL    SUB_8BAE                       ; CALL SUB_8BAE: check Kong grab flag
    JP      DELAY_LOOP_950B                ; JP DELAY_LOOP_950B: main loop wait

SUB_8E50:                                  ; SUB_8E50: Kong drop boundary check
    LD      A, ($70B3)                     ; LD A,($70B3): read Kong phase/facing byte
    CP      $02                            ; CP $02: check if phase 2
    JR      NZ, LOC_8E67                   ; JR NZ,LOC_8E67: if not phase 2, check phase 3
    LD      A, ($70B2)                     ; LD A,($70B2): read Y lower boundary
    ADD     A, $04                         ; ADD A,$04: boundary + 4
    CP      (IY+1)                         ; CP (IY+1): compare with Kong Y
    LD      B, $01                         ; LD B,$01: state B = 1
    JR      Z, LOC_8E77                    ; JR Z,LOC_8E77: at boundary, set state
    JR      NC, LOC_8E85                   ; JR NC,LOC_8E85: above boundary, continue fall
    JR      LOC_8E77                       ; JR LOC_8E77: below boundary, set state

LOC_8E67:                                  ; LOC_8E67: check phase 3 boundary
    CP      $03                            ; CP $03: phase 3?
    JR      NZ, LOC_8E85                   ; JR NZ,LOC_8E85: if not phase 3, continue fall
    LD      A, ($70B1)                     ; LD A,($70B1): read Y upper boundary
    CP      (IY+1)                         ; CP (IY+1): compare with Kong Y
    LD      B, $00                         ; LD B,$00: state B = 0
    JR      Z, LOC_8E77                    ; JR Z,LOC_8E77: at upper boundary, set state
    JR      C, LOC_8E85                    ; JR C,LOC_8E85: above upper boundary, continue

LOC_8E77:                                  ; LOC_8E77: set Kong boundary state and dispatch
    LD      HL, $93D5                      ; LD HL,$93D5: Kong animation dispatch table
    LD      (IY+1), A                      ; LD (IY+1),A: store new Y
    LD      A, B                           ; LD A,B: A = state index
    LD      IX, LOC_9260                   ; LD IX,LOC_9260: animation dispatcher address
    EX      (SP), IX                       ; EX (SP),IX: inject dispatcher as return address
    RET                                    ; RET: return through dispatcher

LOC_8E85:                                  ; LOC_8E85: Kong fall out-of-bounds check
    LD      A, (IY+3)                      ; LD A,(IY+3): Kong X
    CP      $BA                            ; CP $BA: compare with right boundary $BA
    JR      C, LOC_8E91                    ; JR C,LOC_8E91: if in bounds, continue
    POP     HL                             ; POP HL: discard two stack frames
    POP     HL                             ; POP HL: discard second frame
    JP      LOC_A172                       ; JP LOC_A172: Kong fell off screen, game over

LOC_8E91:                                  ; LOC_8E91: Kong Y and X clamp
    LD      A, (IY+1)                      ; LD A,(IY+1): Kong Y
    CP      $C6                            ; CP $C6: compare with Y max $C6
    JR      C, LOC_8EA3                    ; JR C,LOC_8EA3: if above max, update position
    LD      A, (IY+3)                      ; LD A,(IY+3): Kong X
    CP      $1D                            ; CP $1D: compare with X min $1D
    LD      B, $01                         ; LD B,$01: state 1
    LD      A, $C6                         ; LD A,$C6: clamp Y to $C6
    JR      C, LOC_8E77                    ; JR C,LOC_8E77: if at min X, dispatch state

LOC_8EA3:                                  ; LOC_8EA3: update Kong position from motion table
    LD      A, (HL)                        ; LD A,(HL): read motion byte
    CP      $80                            ; CP $80: check end-of-table marker
    JR      NZ, LOC_8EB4                   ; JR NZ,LOC_8EB4: if not end, apply motion
    LD      A, $04                         ; LD A,$04: Y step 4 for wrap
    PUSH    AF                             ; PUSH AF: save Y step
    ADD     A, (IY+3)                      ; ADD A,(IY+3): add to Kong X
    LD      (IY+3), A                      ; LD (IY+3),A: update Kong X
    POP     AF                             ; POP AF: restore step
    JR      LOC_8EC5                       ; JR LOC_8EC5: apply to frame counter

LOC_8EB4:                                  ; LOC_8EB4: apply motion vector to Kong
    ADD     A, (IY+1)                      ; ADD A,(IY+1): add delta to Kong Y
    LD      (IY+1), A                      ; LD (IY+1),A: update Kong Y
    INC     HL                             ; INC HL: advance to X delta
    LD      A, (HL)                        ; LD A,(HL): read X delta
    INC     HL                             ; INC HL: advance past X delta
    PUSH    AF                             ; PUSH AF: save X delta
    ADD     A, (IY+3)                      ; ADD A,(IY+3): add X delta to Kong X
    LD      (IY+3), A                      ; LD (IY+3),A: update Kong X
    POP     AF                             ; POP AF: restore X delta for counter

LOC_8EC5:                                  ; LOC_8EC5: accumulate motion into frame counter
    LD      B, A                           ; LD B,A: B = delta value
    LD      A, ($70B6)                     ; LD A,($70B6): read animation frame counter
    ADD     A, B                           ; ADD A,B: add delta to counter
    LD      ($70B6), A                  ; RAM $70B6
    LD      ($70B4), HL                 ; RAM $70B4
    RET                                    ; RET: return from Kong animation frame counter update

SUB_8ED1:                                  ; SUB_8ED1: draw fruit bite mark at VRAM $1AA7 (2 rows)
    PUSH    HL                             ; PUSH HL
    LD      DE, $1AA7                      ; DE = $1AA7: VRAM row 1
    LD      BC, $0002                      ; BC = $0002: 2 bytes
    PUSH    BC                             ; PUSH BC
    RST     $08                            ; RST $08: write 2 bytes to VRAM $1AA7
    POP     BC                             ; POP BC
    POP     HL                             ; POP HL
    ADD     HL, BC                         ; ADD HL,BC
    LD      DE, $1AC7                      ; DE = $1AC7: VRAM row 2
    RST     $08                            ; RST $08: write row 2
    RET                                    ; RET: return from SUB_8ED1 fruit-bite mark VRAM write

DELAY_LOOP_8EE2:                           ; DELAY_LOOP_8EE2: clear snapjaw frame-timer table ($70EB, 6 slots, fill $0F)
    LD      HL, $70EB                      ; HL = $70EB: snapjaw frame timer array
    LD      B, $06                         ; B = $06

LOC_8EE7:                                  ; LOC_8EE7: fill loop
    LD      (HL), $0F                      ; LD (HL),$0F: reset timer to 15
    INC     HL                             ; INC HL
    DJNZ    LOC_8EE7                       ; DJNZ LOC_8EE7
    RET                                    ; RET: return from DELAY_LOOP_8EE2 snapjaw frame-timer init
    DB      $00, $00, $5C, $87, $60, $61, $62, $63

LOC_8EF5:                                  ; LOC_8EF5: Kong phase transition -- arm left side (AC=0)
    XOR     A                              ; XOR A
    LD      ($70AC), A                     ; LD ($70AC),A: side = left
    LD      (IY+0), $08                    ; LD (IY+0),$08: Kong sprite index
    CALL    SUB_8FFB                       ; CALL SUB_8FFB: draw Kong feet tiles
    JP      LOC_8FD4                       ; JP LOC_8FD4

LOC_8F03:                                  ; LOC_8F03: arm right side (AC=1)
    LD      A, $01                         ; LD A,$01
    LD      ($70AC), A                     ; LD ($70AC),A: side = right
    LD      (IY+0), $09                    ; LD (IY+0),$09
    JP      LOC_8FD4                       ; JP LOC_8FD4

LOC_8F0F:                                  ; LOC_8F0F: Kong left-side movement handler
    LD      HL, $7086                      ; HL = $7086: left-side frame timer
    DEC     (HL)                           ; DEC (HL)
    RET     NZ                             ; RET NZ: not expired
    LD      A, ($70AB)                     ; A = ($70AB): Kong Y position
    CP      $01                            ; CP $01
    LD      IY, $71EE                      ; IY = $71EE
    JR      NZ, LOC_8F85                   ; JR NZ,LOC_8F85: not at leftmost -- move right
    LD      (HL), $06                      ; LD (HL),$06: reload 6 ticks
    LD      C, (IY+3)                      ; LD C,(IY+3): C = Kong X for left-side check
    CALL    SUB_8FDA                       ; CALL SUB_8FDA: check left-side obstacle
    CALL    SUB_89E0                       ; CALL SUB_89E0: check vine at computed position
    RET     NZ                             ; RET NZ: if vine found, stop
    LD      A, $FE                         ; LD A,$FE: X step -2 (moving left)
    ADD     A, (IY+3)                      ; ADD A,(IY+3): apply X step to Kong X
    LD      (IY+3), A                      ; LD (IY+3),A: update Kong X
    LD      A, ($70AC)                     ; LD A,($70AC): read Kong left-side flag
    OR      A                              ; OR A: test flag
    JR      NZ, LOC_8F57                   ; JR NZ,LOC_8F57: if set, use right-side sprite
    LD      A, ($71EF)                     ; LD A,($71EF): read Kong arm sprite Y
    ADD     A, $0A                         ; ADD A,$0A: arm Y + 10
    CALL    SUB_8FEA                       ; CALL SUB_8FEA: draw arm sprite at computed pos
    LD      A, (IY+0)                      ; LD A,(IY+0): read Kong sprite type
    CP      $0C                            ; CP $0C: compare with type $0C
    LD      (IY+0), $08                    ; LD (IY+0),$08: set sprite type to $08
    JR      Z, LOC_8F53                    ; JR Z,LOC_8F53: if was $0C, keep $08
    LD      (IY+0), $0C                    ; LD (IY+0),$0C: alternate: set type $0C
    LD      A, (IY+1)                      ; LD A,(IY+1): Kong Y

LOC_8F53:                                  ; LOC_8F53: add arm Y offset and draw
    ADD     A, $0A                         ; ADD A,$0A: Y + 10 for arm position
    JR      LOC_8F73                       ; JR LOC_8F73: jump to arm draw

LOC_8F57:                                  ; LOC_8F57: right-side arm draw
    LD      A, (IY+1)                      ; LD A,(IY+1): Kong Y
    ADD     A, $03                         ; ADD A,$03: Y + 3 for right arm
    CALL    SUB_8FEA                       ; CALL SUB_8FEA: draw right arm sprite
    LD      A, (IY+0)                      ; LD A,(IY+0): Kong sprite type
    CP      $0D                            ; CP $0D: compare with type $0D
    LD      (IY+0), $09                    ; LD (IY+0),$09: set type $09
    JR      Z, LOC_8F6E                    ; JR Z,LOC_8F6E: if was $0D, keep $09
    LD      (IY+0), $0D                    ; LD (IY+0),$0D: alternate: type $0D

LOC_8F6E:                                  ; LOC_8F6E: compute right arm Y position
    LD      A, (IY+1)                      ; LD A,(IY+1): Kong Y
    ADD     A, $03                         ; ADD A,$03: Y + 3

LOC_8F73:                                  ; LOC_8F73: draw arm tile pair
    LD      B, A                           ; LD B,A: B = arm Y position
    LD      C, (IY+3)                      ; LD C,(IY+3): C = Kong X
    PUSH    BC                             ; PUSH BC: save arm position
    CALL    SUB_9441                       ; CALL SUB_9441: draw lower arm tile
    POP     BC                             ; POP BC: restore arm position
    LD      A, $0D                         ; LD A,$0D: X offset $0D for upper arm
    ADD     A, C                           ; ADD A,C: C = upper arm X
    LD      C, A                           ; LD C,A: store
    CALL    SUB_9441                       ; CALL SUB_9441: draw upper arm tile
    JR      LOC_8FD4                       ; JR LOC_8FD4: advance to next frame

LOC_8F85:                                  ; LOC_8F85: Kong right-side movement
    LD      (HL), $03                      ; LD (HL),$03: 3 ticks
    LD      A, $10                         ; LD A,$10: Y offset $10 for right-side check
    ADD     A, (IY+3)                      ; ADD A,(IY+3): add to Kong X
    LD      C, A                           ; LD C,A: C = adjusted X
    LD      A, (IY+1)                      ; LD A,(IY+1): Kong Y
    CALL    SUB_8FDA                       ; CALL SUB_8FDA: check right-side obstacle
    CALL    SUB_89D6                       ; CALL SUB_89D6: check surface at position
    RET     NZ                             ; RET NZ: if obstacle, stop
    LD      A, $04                         ; LD A,$04: X step +4 (moving right)
    ADD     A, (IY+3)                      ; ADD A,(IY+3): apply to Kong X
    LD      (IY+3), A                      ; LD (IY+3),A: update Kong X
    LD      C, A                           ; LD C,A: C = new X
    LD      A, ($70AC)                     ; LD A,($70AC): read Kong right-side flag
    OR      A                              ; OR A: test flag
    LD      A, $0C                         ; LD A,$0C: sprite type $0C for right-arm down
    JR      Z, LOC_8FAA                    ; JR Z,LOC_8FAA: if clear, use right-arm-down
    LD      A, $03                         ; LD A,$03: sprite type $03 for right-arm up

LOC_8FAA:                                  ; LOC_8FAA: compute arm position and draw
    ADD     A, (IY+1)                      ; ADD A,(IY+1): add Kong Y
    LD      B, A                           ; LD B,A: B = arm Y
    CALL    LOC_89DB                       ; CALL LOC_89DB: check vine at arm position
    PUSH    AF                             ; PUSH AF: save result
    CALL    SUB_8FFB                       ; CALL SUB_8FFB: draw Kong right arm tiles
    LD      A, C                           ; LD A,C: restore X
    ADD     A, $04                         ; ADD A,$04: X + 4
    LD      C, A                           ; LD C,A: updated X
    LD      A, $04                         ; LD A,$04: sprite count
    PUSH    IY                             ; PUSH IY: save IY
    CALL    SUB_A297                       ; CALL SUB_A297: draw Kong sprite set
    POP     IY                             ; POP IY: restore IY
    POP     AF                             ; POP AF: restore vine check result
    JR      NZ, LOC_8FD4                   ; JR NZ,LOC_8FD4: if vine, advance frame
    LD      A, ($70AC)                     ; LD A,($70AC): re-read right-side flag
    OR      A                              ; OR A: test
    LD      A, $01                         ; LD A,$01: player 1 state
    JR      Z, LOC_8FCE                    ; JR Z,LOC_8FCE: if clear, use P1 state
    XOR     A                              ; XOR A: P2 state = 0

LOC_8FCE:                                  ; LOC_8FCE: dispatch Kong grab animation
    LD      HL, $93D5                      ; LD HL,$93D5: animation table
    JP      LOC_9260                       ; JP LOC_9260: dispatch

LOC_8FD4:                                  ; LOC_8FD4: update Kong sprite via PUTOBJ
    CALL    SUB_A6D2                       ; CALL SUB_A6D2: play Kong sound effect
    JP      DELAY_LOOP_950B                ; JP DELAY_LOOP_950B: update Junior sprite position

SUB_8FDA:                                  ; SUB_8FDA: compute Kong B-register from side flag $70AC
    LD      A, ($70AC)                     ; A = ($70AC): 0=left 1=right
    CP      $00                            ; CP $00
    LD      A, $03                         ; LD A,$03
    JR      Z, LOC_8FE5                    ; JR Z,LOC_8FE5: left -- use $03
    LD      A, $0D                         ; LD A,$0D: right -- use $0D

LOC_8FE5:                                  ; LOC_8FE5: compute arm Y from IY+1
    ADD     A, (IY+1)                      ; ADD A,(IY+1): add Kong Y
    LD      B, A                           ; LD B,A: B = computed Y
    RET                                    ; RET: return

SUB_8FEA:                                  ; SUB_8FEA: draw Kong arm sprite at (B,C)
    LD      B, A                           ; LD B,A: B = arm Y passed in A
    LD      A, ($71F1)                     ; LD A,($71F1): read arm X base
    ADD     A, $08                         ; ADD A,$08: arm X + 8
    LD      C, A                           ; LD C,A: C = arm X
    LD      A, $84                         ; LD A,$84: sprite attribute byte
    PUSH    IY                             ; PUSH IY: save IY
    CALL    SUB_A297                       ; CALL SUB_A297: draw arm sprite
    POP     IY                             ; POP IY: restore IY
    RET                                    ; RET: return

SUB_8FFB:                                  ; SUB_8FFB: draw Kong foot tiles (2 rows)
    LD      A, ($70AC)                     ; A = ($70AC)
    OR      A                              ; OR A
    LD      A, $0D                         ; LD A,$0D
    JR      Z, LOC_9005                    ; JR Z,LOC_9005
    LD      A, $03                         ; LD A,$03

LOC_9005:                                  ; LOC_9005: draw Kong upper and lower arm tiles
    ADD     A, (IY+1)                      ; ADD A,(IY+1): add Kong Y for arm position
    LD      B, A                           ; LD B,A: B = arm Y
    LD      A, $0D                         ; LD A,$0D: X offset $0D
    ADD     A, (IY+3)                      ; ADD A,(IY+3): add Kong X
    LD      C, A                           ; LD C,A: C = arm X
    PUSH    BC                             ; PUSH BC: save arm position
    PUSH    BC                             ; PUSH BC: duplicate for second call
    CALL    SUB_9441                       ; CALL SUB_9441: draw lower arm tile
    POP     BC                             ; POP BC: restore arm position
    LD      A, $F6                         ; LD A,$F6: X offset -10
    ADD     A, C                           ; ADD A,C: C = upper arm X
    LD      C, A                           ; LD C,A: store
    CALL    SUB_9441                       ; CALL SUB_9441: draw upper arm tile
    POP     BC                             ; POP BC: restore original position
    RET                                    ; RET: return

LOC_901E:                                  ; LOC_901E: Kong right-side -- periodic Y-drop handler
    LD      HL, $7087                      ; HL = $7087: right-side frame timer
    DEC     (HL)                           ; DEC (HL)
    RET     NZ                             ; RET NZ
    LD      (HL), $08                      ; LD (HL),$08: reload 8 ticks
    LD      IY, $71EE                      ; IY = $71EE
    LD      A, ($70B8)                     ; A = ($70B8): right-drop active flag
    OR      A                              ; OR A
    RET     NZ                             ; RET NZ: already dropping
    LD      A, ($70AB)                     ; A = ($70AB): Kong Y
    CP      $01                            ; CP $01
    JP      NZ, LOC_908C                   ; JP NZ,LOC_908C: not leftmost position
    LD      A, (IY+0)                      ; LD A,(IY+0): read Kong sprite type
    CP      $0A                            ; CP $0A: compare with type $0A
    LD      A, $10                         ; LD A,$10: Y offset $10 for type $0A
    JR      Z, LOC_9040                    ; JR Z,LOC_9040: if type $0A, use $10 offset
    XOR     A                              ; XOR A: otherwise offset = 0

LOC_9040:                                  ; LOC_9040: compute Kong drop check Y
    ADD     A, (IY+1)                      ; ADD A,(IY+1): add Kong Y
    LD      B, A                           ; LD B,A: B = check Y
    LD      C, (IY+3)                      ; LD C,(IY+3): C = Kong X
    CALL    LOC_89DB                       ; CALL LOC_89DB: check vine at (B,C)
    RET     Z                              ; RET Z: if on vine, stop
    LD      A, (IY+0)                      ; LD A,(IY+0): Kong sprite type
    XOR     $01                            ; XOR $01: toggle low bit (alternate type)
    LD      (IY+0), A                      ; LD (IY+0),A: update sprite type
    LD      C, (IY+3)                      ; LD C,(IY+3): Kong X
    LD      A, (IY+1)                      ; LD A,(IY+1): Kong Y
    ADD     A, $08                         ; ADD A,$08: Y + 8 for lower check
    LD      B, A                           ; LD B,A: B = lower check Y
    CALL    SUB_89E0                       ; CALL SUB_89E0: check surface/vine at lower Y
    JP      NZ, LOC_906A                   ; JP NZ,LOC_906A: if surface, jump to X adjust
    LD      A, (IY+3)                      ; LD A,(IY+3): Kong X
    ADD     A, $FC                         ; ADD A,$FC: X - 4 (move left)
    LD      (IY+3), A                      ; LD (IY+3),A: update Kong X

LOC_906A:                                  ; LOC_906A: alternate sprite frame selection
    LD      A, $10                         ; LD A,$10: frame offset $10
    BIT     0, (IY+0)                      ; BIT 0,(IY+0): test sprite type bit 0
    JR      NZ, LOC_9073                   ; JR NZ,LOC_9073: if set, use $10 offset
    XOR     A                              ; XOR A: else offset = 0

LOC_9073:                                  ; LOC_9073: draw Kong right-drop sprites
    ADD     A, (IY+1)                      ; ADD A,(IY+1): add Kong Y
    LD      B, A                           ; LD B,A: B = sprite Y
    LD      A, $02                         ; LD A,$02: sprite attribute
    CALL    SUB_90FC                       ; CALL SUB_90FC: draw right-drop sprite pair
    LD      A, C                           ; LD A,C: restore X
    ADD     A, $06                         ; ADD A,$06: X + 6
    LD      C, A                           ; LD C,A: adjusted X
    PUSH    IY                             ; PUSH IY: save IY
    LD      A, $84                         ; LD A,$84: sprite attribute byte
    CALL    SUB_A297                       ; CALL SUB_A297: draw sprite at (B,C)
    POP     IY                             ; POP IY: restore IY
    JP      LOC_90F9                       ; JP LOC_90F9: advance to next drop frame

LOC_908C:                                  ; LOC_908C: Kong right-drop lateral check
    LD      A, (IY+1)                      ; LD A,(IY+1): Kong Y
    ADD     A, $08                         ; ADD A,$08: Y + 8
    LD      B, A                           ; LD B,A: B = check Y
    LD      A, (IY+3)                      ; LD A,(IY+3): Kong X
    ADD     A, $11                         ; ADD A,$11: X + 17
    LD      C, A                           ; LD C,A: C = check X
    CALL    SUB_89D6                       ; CALL SUB_89D6: check surface at right edge
    RET     NZ                             ; RET NZ: if surface, stop
    BIT     0, (IY+0)                      ; BIT 0,(IY+0): test sprite type bit 0
    LD      B, (IY+1)                      ; LD B,(IY+1): B = Kong Y
    JR      NZ, LOC_90AB                   ; JR NZ,LOC_90AB: if type odd, use Y as-is
    LD      A, (IY+1)                      ; LD A,(IY+1): Kong Y
    ADD     A, $10                         ; ADD A,$10: Y + 16
    LD      B, A                           ; LD B,A: B = offset Y for even type

LOC_90AB:                                  ; LOC_90AB: check vine at right edge
    LD      A, (IY+3)                      ; LD A,(IY+3): Kong X
    ADD     A, $08                         ; ADD A,$08: X + 8
    LD      C, A                           ; LD C,A: C = right-edge X
    CALL    LOC_89DB                       ; CALL LOC_89DB: check vine at (B,C)
    JR      NZ, LOC_90D0                   ; JR NZ,LOC_90D0: if vine found, advance X
    LD      A, $FD                         ; LD A,$FD: X step -3 (move left)
    ADD     A, (IY+1)                      ; ADD A,(IY+1): add Kong Y
    LD      (IY+1), A                      ; LD (IY+1),A: update Kong Y
    BIT     0, (IY+0)                      ; BIT 0,(IY+0): test sprite type
    JP      Z, LOC_8F03                    ; JP Z,LOC_8F03: if even type, go left-fall
    LD      A, $09                         ; LD A,$09: offset +9 for odd type
    ADD     A, (IY+1)                      ; ADD A,(IY+1): add to Kong Y
    LD      (IY+1), A                      ; LD (IY+1),A: update Y
    JP      LOC_8EF5                       ; JP LOC_8EF5: go right-fall

LOC_90D0:                                  ; LOC_90D0: advance Kong X right and update sprite
    LD      A, (IY+3)                      ; LD A,(IY+3): Kong X
    ADD     A, $04                         ; ADD A,$04: X + 4
    LD      (IY+3), A                      ; LD (IY+3),A: update Kong X
    LD      A, (IY+0)                      ; LD A,(IY+0): sprite type
    XOR     $01                            ; XOR $01: toggle type
    LD      (IY+0), A                      ; LD (IY+0),A: store updated type
    LD      A, $10                         ; LD A,$10: frame offset $10
    BIT     0, (IY+0)                      ; BIT 0,(IY+0): test type bit
    JR      Z, LOC_90E9                    ; JR Z,LOC_90E9: if even, offset = $10
    XOR     A                              ; XOR A: odd type: offset = 0

LOC_90E9:                                  ; LOC_90E9: draw Kong right-drop sprite
    ADD     A, (IY+1)                      ; ADD A,(IY+1): add Kong Y
    LD      B, A                           ; LD B,A: B = sprite Y
    LD      A, $08                         ; LD A,$08: sprite attribute
    CALL    SUB_90FC                       ; CALL SUB_90FC: draw sprite pair
    INC     C                              ; INC C: C+1
    INC     C                              ; INC C: C+2
    LD      A, $04                         ; LD A,$04: sprite count
    CALL    SUB_A297                       ; CALL SUB_A297: draw right-drop sprite

LOC_90F9:                                  ; LOC_90F9: jump to post-drop handler
    JP      LOC_923F                       ; JP LOC_923F: continue Kong drop sequence

SUB_90FC:                                  ; SUB_90FC: sub helper -- C = A + (IY+3); call SUB_9441
    ADD     A, (IY+3)                      ; ADD A,(IY+3)
    LD      C, A                           ; C = A
    PUSH    BC                             ; PUSH BC
    CALL    SUB_9441                       ; CALL SUB_9441: Jr player/snapjaw collision
    POP     BC                             ; POP BC
    RET                                    ; RET: return from SUB_9441 Jr/snapjaw collision call

LOC_9106:                                  ; LOC_9106: Kong movement completed -- phase 0 ground loop reset
    LD      HL, $7084                      ; HL = $7084: ground movement timer
    DEC     (HL)                           ; DEC (HL)
    RET     NZ                             ; RET NZ
    LD      (HL), $0A                      ; LD (HL),$0A: reload 10
    LD      IY, $71EE                      ; IY = $71EE
    LD      A, ($70AB)                     ; A = ($70AB): Kong Y position
    CP      $02                            ; CP $02
    LD      A, ($70AC)                     ; LD A,($70AC): side flag
    JP      NZ, LOC_91AD                   ; JP NZ,LOC_91AD: not position 2
    DEC     A                              ; DEC A: side was 1 (right) -- now 0; Z set if matched
    JR      Z, LOC_913D                    ; DEC A
    DEC     A                              ; JR Z,LOC_913D
    JR      Z, LOC_9181                    ; JR Z,LOC_9181: side was 1 -- take right-vine climb path
    XOR     A                              ; XOR A
    LD      ($70B8), A                     ; LD ($70B8),A
    LD      DE, $9360                      ; LD DE,$9360: left-side vine collision table
    CALL    SUB_9245                       ; CALL SUB_9245: probe; pop-return if no collision
    LD      A, $01                         ; A = $01: set side = right
    LD      ($70AC), A                     ; LD ($70AC),A: Kong side = 1 (right)
    LD      (IY+0), $09                    ; LD (IY+0),$09: Kong sprite index right
    LD      A, (IY+1)                      ; A = (IY+1): Jr Y
    ADD     A, $07                         ; ADD A,$07: Jr Y + 7
    JP      LOC_9234                       ; JP LOC_9234: write Jr Y

LOC_913D:                                  ; LOC_913D: Kong side=2 -- probe vine, Jr step up-right
    LD      DE, $9360                      ; LD DE,$9360: vine table (left)
    CALL    SUB_9245                       ; CALL SUB_9245: probe; pop-return if miss
    LD      A, $02                         ; A = $02
    LD      ($70AC), A                     ; LD ($70AC),A: Kong side = 2
    LD      (IY+0), $0A                    ; LD (IY+0),$0A: Kong sprite index
    LD      A, (IY+1)                      ; A = (IY+1): Jr Y
    ADD     A, $03                         ; ADD A,$03: Jr Y + 3
    LD      (IY+1), A                      ; LD (IY+1),A: update Jr Y
    ADD     A, $10                         ; ADD A,$10: Jr Y + $10 for second probe
    CALL    SUB_9252                       ; CALL SUB_9252: probe B=A C=(IY+3)
    PUSH    AF                             ; PUSH AF: save probe result
    LD      A, (IY+1)                      ; A = (IY+1): Jr Y
    ADD     A, $10                         ; ADD A,$10
    LD      B, A                           ; LD B,A: B = Jr Y + $10
    LD      A, $08                         ; A = $08
    CALL    SUB_9259                       ; CALL SUB_9259: probe C=A+(IY+3)
    POP     AF                             ; POP AF: restore first probe result
    JR      Z, LOC_917D                    ; JR Z,LOC_917D: Z = collision
    LD      IX, $709B                      ; IX = $709B: vine-slot data pointer
    LD      A, (IY+1)                      ; A = (IY+1): Jr Y
    LD      C, A                           ; LD C,A: save Jr Y
    ADD     A, $11                         ; ADD A,$11: Jr Y + $11
    CP      (IX+0)                         ; CP (IX+0): compare with vine slot
    LD      A, C                           ; LD A,C: restore Jr Y
    JR      NZ, LOC_917A                   ; JR NZ,LOC_917A: no vine match
    JR      LOC_917D                       ; JR LOC_917D

LOC_917A:                                  ; LOC_917A: JP LOC_9234 (Jr Y miss -- continue loop)
    JP      LOC_9234                       ; JP LOC_9234

LOC_917D:                                  ; LOC_917D: set direction-latch $70B9 = 2
    LD      A, $02                         ; A = $02
    JR      LOC_91DF                       ; JR LOC_91DF

LOC_9181:                                  ; LOC_9181: Kong side=1 -- check $70B9 latch for vine-climb trigger
    LD      A, ($70B9)                     ; A = ($70B9): direction-latch
    CP      $02                            ; CP $02: latch = 2?
    JR      NZ, LOC_919A                   ; JR NZ,LOC_919A: no latch -- idle
    LD      A, ($70B8)                     ; A = ($70B8): drop/swing flag
    OR      A                              ; OR A
    JR      Z, LOC_919A                    ; JR Z,LOC_919A: drop flag clear -- idle
    XOR     A                              ; XOR A
    LD      ($70B8), A                     ; LD ($70B8),A: clear drop flag
    LD      A, $01                         ; A = $01: climb direction = down
    LD      HL, $93E6                      ; LD HL,$93E6: climb path table (down)
    JP      LOC_9260                       ; JP LOC_9260: start climb -- set $70BB/$70BD/$70BA, phase=2

LOC_919A:                                  ; LOC_919A: idle left -- clear drop/side flags, reset sprite
    XOR     A                              ; XOR A
    LD      ($70B8), A                     ; LD ($70B8),A: clear drop flag
    LD      ($70AC), A                     ; LD ($70AC),A: Kong side = 0 (left)
    LD      (IY+0), $08                    ; LD (IY+0),$08: Kong sprite index left
    LD      A, (IY+1)                      ; A = (IY+1): Jr Y
    ADD     A, $06                         ; ADD A,$06: Jr Y + 6
    JP      LOC_9234                       ; JP LOC_9234

LOC_91AD:                                  ; LOC_91AD: Kong Y > 2 -- dispatch on positions 3 and 4
    DEC     A                              ; DEC A: check A == 0 (position 3)?
    JR      Z, LOC_91EA                    ; JR Z,LOC_91EA: position=3
    DEC     A                              ; DEC A
    JP      Z, LOC_9203                    ; JP Z,LOC_9203: position=4
    LD      DE, $9366                      ; LD DE,$9366: right-side vine table
    CALL    SUB_9245                       ; CALL SUB_9245: probe; pop-return if miss
    LD      A, $02                         ; A = $02
    LD      ($70AC), A                     ; LD ($70AC),A: side = 2
    LD      (IY+0), $0B                    ; LD (IY+0),$0B: Kong sprite index
    LD      A, (IY+1)                      ; A = (IY+1): Jr Y
    ADD     A, $FA                         ; ADD A,$FA: Jr Y - 6
    LD      (IY+1), A                      ; LD (IY+1),A: Jr Y -= 6
    CALL    SUB_9252                       ; CALL SUB_9252: probe at new Jr Y
    PUSH    AF                             ; PUSH AF
    LD      B, (IY+1)                      ; B = (IY+1): Jr Y
    LD      A, $08                         ; A = $08
    CALL    SUB_9259                       ; CALL SUB_9259
    POP     AF                             ; POP AF
    JR      Z, LOC_91DD                    ; JR Z,LOC_91DD: Z = hit
    JP      LOC_9234                       ; JP LOC_9234

LOC_91DD:                                  ; LOC_91DD: set direction-latch = $08
    LD      A, $08                         ; A = $08

LOC_91DF:                                  ; LOC_91DF: store direction-latch $70B9; set drop flag $70B8
    LD      ($70B9), A                     ; LD ($70B9),A: $70B9 = direction latch
    LD      A, $01                         ; A = $01
    LD      ($70B8), A                     ; LD ($70B8),A: $70B8 = 1 (drop flag set)
    JP      LOC_9237                       ; JP LOC_9237

LOC_91EA:                                  ; LOC_91EA: position=3 -- probe vine, clear flags, set left sprite
    LD      DE, $9366                      ; LD DE,$9366
    CALL    SUB_9245                       ; CALL SUB_9245
    XOR     A                              ; XOR A
    LD      ($70B8), A                     ; LD ($70B8),A: clear drop flag
    LD      ($70AC), A                     ; LD ($70AC),A: side = 0 (left)
    LD      (IY+0), $08                    ; LD (IY+0),$08
    LD      A, (IY+1)                      ; A = (IY+1): Jr Y
    ADD     A, $F9                         ; ADD A,$F9: Jr Y - 7
    JP      LOC_9234                       ; JP LOC_9234

LOC_9203:                                  ; LOC_9203: position=4 -- check $70B9 latch for climb-up trigger
    LD      A, ($70B9)                     ; A = ($70B9): direction-latch
    CP      $08                            ; CP $08: latch = $08?
    JR      NZ, LOC_921A                   ; JR NZ,LOC_921A: no latch
    LD      A, ($70B8)                     ; A = ($70B8): drop flag
    OR      A                              ; OR A
    JR      Z, LOC_921A                    ; JR Z,LOC_921A: drop flag clear

LOC_9210:                                  ; LOC_9210: initiate climb up via path $93FD
    XOR     A                              ; XOR A
    LD      ($70B8), A                     ; LD ($70B8),A: clear drop flag
    LD      HL, $93FD                      ; LD HL,$93FD: climb path table (upward)
    JP      LOC_9260                       ; JP LOC_9260: start climb

LOC_921A:                                  ; LOC_921A: position=4 no latch -- set right sprite, probe vine
    XOR     A                              ; XOR A
    LD      ($70B8), A                     ; LD ($70B8),A: clear drop flag
    LD      A, $01                         ; A = $01
    LD      ($70AC), A                     ; LD ($70AC),A: side = 1 (right)
    LD      (IY+0), $09                    ; LD (IY+0),$09: Kong sprite index right
    LD      B, (IY+1)                      ; B = (IY+1): Jr Y
    LD      C, (IY+3)                      ; C = (IY+3): Jr X
    CALL    LOC_89DB                       ; CALL LOC_89DB: vine collision probe (DE=$0002)
    JR      Z, LOC_9210                    ; JR Z,LOC_9210: Z = collision -- start climb
    ADD     A, $FD                         ; ADD A,$FD: A -= 3

LOC_9234:                                  ; LOC_9234: write Jr Y to IY+1; fall to LOC_9237
    LD      (IY+1), A                      ; LD (IY+1),A: store Jr Y

LOC_9237:                                  ; LOC_9237: decrement Kong position timer $7088; draw + return
    LD      HL, $7088                      ; HL = $7088: Kong position timer
    DEC     (HL)                           ; DEC (HL)
    JR      NZ, LOC_923F                   ; JR NZ,LOC_923F: not expired
    LD      (HL), $02                      ; LD (HL),$02: reload 2

LOC_923F:                                  ; LOC_923F: play Kong sound and update Jr sprite
    CALL    SUB_A6D2                       ; CALL SUB_A6D2: play Kong sound effect (RST $30 ch $07/$08)
    JP      DELAY_LOOP_950B                ; JP DELAY_LOOP_950B

SUB_9245:                                  ; SUB_9245: collision probe helper -- call SOUND_WRITE_8B12; pop on no-match
    LD      B, (IY+1)                      ; B = (IY+1): Junior Y
    LD      C, (IY+3)                      ; C = (IY+3): Junior X
    CALL    SOUND_WRITE_8B12               ; CALL SOUND_WRITE_8B12
    POP     DE                             ; POP DE: pop callers return
    RET     NZ                             ; RET NZ: match -- return to *caller of caller*
    PUSH    DE                             ; PUSH DE: no match -- restore return
    RET                                    ; RET

SUB_9252:                                  ; SUB_9252: collision probe: B=A C=(IY+3); JP LOC_89DB
    LD      B, A                           ; B = A
    LD      C, (IY+3)                      ; C = (IY+3)
    JP      LOC_89DB                       ; JP LOC_89DB

SUB_9259:                                  ; SUB_9259: collision probe: C = A+(IY+3); JP SUB_9441
    ADD     A, (IY+3)                      ; ADD A,(IY+3)
    LD      C, A                           ; C = A
    JP      SUB_9441                       ; JP SUB_9441

LOC_9260:                                  ; LOC_9260: Junior climb-state dispatch -- set $70BB $70BD $70BA and phase to 2
    LD      ($70BB), HL                    ; LD ($70BB),HL: climb path pointer
    LD      ($70BD), A                     ; LD ($70BD),A: climb direction (0=up 1=down)
    XOR     A                              ; XOR A
    LD      ($70BA), A                     ; LD ($70BA),A: climb progress = 0
    LD      A, $02                         ; LD A,$02
    LD      ($708B), A                     ; LD ($708B),A: Kong phase = 2
    JP      LOC_935D                       ; JP LOC_935D: return via DELAY_LOOP_950B

LOC_9272:                                  ; LOC_9272: Kong phase 2 -- off-top handler
    LD      HL, $7085                      ; HL = $7085: off-top timer
    DEC     (HL)                           ; DEC (HL)
    RET     NZ                             ; RET NZ
    LD      (HL), $04                      ; LD (HL),$04: reload 4
    LD      IY, $71EE                      ; IY = $71EE: Junior entity struct
    LD      A, ($70BD)                     ; A = ($70BD): climb direction (0=up 1=down)
    DEC     A                              ; DEC A: Z if direction=1 (down)
    LD      A, $0F                         ; A = $0F: large probe offset (down-direction)
    JR      Z, LOC_9287                    ; JR Z,LOC_9287: down-direction -- keep $0F
    LD      A, $03                         ; A = $03: small probe offset (up-direction)

LOC_9287:                                  ; LOC_9287: probe vine at Jr Y + offset
    ADD     A, (IY+1)                      ; A = offset + (IY+1): probe Y = offset + Jr Y
    CALL    SUB_9252                       ; CALL SUB_9252: vine collision probe B=A C=(IY+3)
    JR      Z, LOC_92AD                    ; JR Z,LOC_92AD: Z = no collision -- try boundary move
    LD      L, A                           ; L = A: save probe hit Y
    LD      A, ($70BD)                     ; A = ($70BD): climb direction
    OR      A                              ; OR A: Z if direction=0 (up)
    LD      A, $FD                         ; A = $FD: down-step (-3)
    JR      Z, LOC_929A                    ; JR Z,LOC_929A: up-direction -- use $FD step
    LD      A, $F6                         ; A = $F6: up-step (-10)

LOC_929A:                                  ; LOC_929A: apply Y step to Junior; Kong phase back to mid
    ADD     A, L                           ; A = step + L: step + probe Y
    LD      (IY+1), A                      ; LD (IY+1),A: new Jr Y
    LD      A, $01                         ; A = $01
    LD      ($708B), A                     ; LD ($708B),A: $708B = 1 = Kong phase mid-screen
    LD      A, ($70BD)                     ; A = ($70BD): climb side flag
    OR      A                              ; OR A: Z if side=0
    JP      Z, LOC_8F03                    ; JP Z,LOC_8F03: side=0 -- arm right
    JP      LOC_8EF5                       ; JP LOC_8EF5: side=1 -- arm left

LOC_92AD:                                  ; LOC_92AD: Jr X boundary check; step Jr toward Kong per direction
    LD      A, (IY+3)                      ; A = (IY+3): Jr X
    CP      $BA                            ; CP $BA: right boundary check
    JP      NC, LOC_9317                   ; JP NC,LOC_9317: X >= $BA -- off-screen, life lost
    ADD     A, $0D                         ; ADD A,$0D: Jr X + $0D (probe offset)
    LD      C, A                           ; C = A: adjusted X for vine probe
    LD      A, ($70BD)                     ; A = ($70BD): climb direction
    OR      A                              ; OR A: Z if direction=0
    LD      A, $04                         ; A = $04: small Y step (down)
    JR      Z, LOC_92C2                    ; JR Z,LOC_92C2: direction=0 -- use +4
    LD      A, $0A                         ; A = $0A: larger Y step

LOC_92C2:                                  ; LOC_92C2: probe vine/floor below new Jr Y; land Jr on hit
    ADD     A, (IY+1)                      ; A = step + (IY+1): probe Y
    LD      B, A                           ; B = A: probe Y for SUB_89D6
    CALL    SUB_89D6                       ; CALL SUB_89D6: vine/ground collision probe (B=Y C=X)
    JR      Z, LOC_931B                    ; JR Z,LOC_931B: Z = hit vine/floor -- land Jr
    ADD     A, $F0                         ; ADD A,$F0: A -= $10 (adjust X target)
    LD      L, A                           ; L = A: save adjusted X
    LD      A, ($7288)                     ; A = ($7288): stage type
    CP      $02                            ; CP $02: croc stage?
    JR      NZ, LOC_92FF                   ; JR NZ,LOC_92FF: non-croc -- skip bite check
    LD      A, (IY+1)                      ; A = (IY+1): Jr Y (croc bite zone check)
    CP      $7F                            ; CP $7F: Y >= $7F -- outside bite zone
    JR      NC, LOC_92FF                   ; JR NC,LOC_92FF: outside
    LD      A, (IY+3)                      ; A = (IY+3): Jr X
    ADD     A, $0D                         ; ADD A,$0D
    CP      $A8                            ; CP $A8: in croc bite zone?
    JR      C, LOC_92FF                    ; JR C,LOC_92FF: X below zone
    LD      A, ($70BD)                     ; A = ($70BD): side for bite direction
    OR      A                              ; OR A: Z if side=0
    LD      A, $03                         ; A = $03: right bite tile offset
    JR      Z, LOC_92EF                    ; JR Z,LOC_92EF: side=0 -- use $03
    LD      A, $02                         ; A = $02: left bite tile offset

LOC_92EF:                                  ; LOC_92EF: draw croc bite mark; set croc-bite flag $70B7
    PUSH    AF                             ; PUSH AF: save bite tile offset
    LD      HL, $8EED                      ; HL = $8EED: bite-mark tile data
    CALL    SUB_8ED1                       ; CALL SUB_8ED1: draw 2-row bite mark to VRAM
    LD      A, $01                         ; A = $01
    LD      ($70B7), A                     ; LD ($70B7),A: $70B7 = 1 = croc-bite active
    POP     AF                             ; POP AF: restore bite offset
    JP      LOC_8CBF                       ; JP LOC_8CBF: continue Kong main loop

LOC_92FF:                                  ; LOC_92FF: check climb progress limit; update Jr X from probe
    LD      A, ($70BA)                     ; A = ($70BA): climb progress counter
    CP      $18                            ; CP $18: progress >= 24 (climb limit)?
    JR      NC, LOC_9317                   ; JR NC,LOC_9317: exceeded limit -- life lost
    LD      (IY+3), L                      ; LD (IY+3),L: Jr X = L (probe adjusted X)
    XOR     A                              ; XOR A
    LD      ($708B), A                     ; LD ($708B),A: $708B = 0 = Kong phase ground
    LD      A, ($70BD)                     ; A = ($70BD): climb side
    OR      A                              ; OR A: Z if side=0
    JP      Z, LOC_8BD6                    ; JP Z,LOC_8BD6: side=0 -- left ground movement
    JP      LOC_8C26                       ; JP LOC_8C26: side=1 -- right ground movement

LOC_9317:                                  ; LOC_9317: climb out-of-bounds / limit exceeded -- life lost
    POP     HL                             ; POP HL: unwind call stack
    JP      LOC_A172                       ; JP LOC_A172: life lost

LOC_931B:                                  ; LOC_931B: Jr vine/floor contact -- advance along climb path table
    LD      HL, ($70BB)                    ; HL = ($70BB): climb path data pointer
    LD      A, (HL)                        ; A = (HL): path step byte
    CP      $80                            ; CP $80: end-of-path sentinel?
    JR      NZ, LOC_9327                   ; JR NZ,LOC_9327: not end -- read Y/X steps
    LD      A, $04                         ; A = $04: default Y step at path end
    JR      LOC_9333                       ; JR LOC_9333: apply step

LOC_9327:                                  ; LOC_9327: read Y and X steps from climb path table
    ADD     A, (IY+1)                      ; A = Y-step + (IY+1): Jr Y += Y-step
    LD      (IY+1), A                      ; LD (IY+1),A: new Jr Y
    INC     HL                             ; INC HL: advance to X-step byte
    LD      A, (HL)                        ; A = (HL): X-step from path table
    INC     HL                             ; INC HL: advance past X-step
    LD      ($70BB), HL                    ; LD ($70BB),HL: update climb path pointer

LOC_9333:                                  ; LOC_9333: apply X step to Jr X; update climb progress $70BA
    PUSH    AF                             ; PUSH AF: save X-step
    ADD     A, (IY+3)                      ; A = X-step + (IY+3): Jr X += X-step
    LD      (IY+3), A                      ; LD (IY+3),A: new Jr X
    POP     AF                             ; POP AF: restore X-step
    LD      B, A                           ; B = A: B = X-step for progress add
    LD      A, ($70BA)                     ; A = ($70BA): climb progress
    ADD     A, B                           ; ADD A,B: progress += step
    LD      ($70BA), A                     ; LD ($70BA),A: store updated progress
    LD      A, ($7288)                     ; A = ($7288): stage type
    CP      $02                            ; CP $02: croc stage?
    JR      NZ, LOC_935D                   ; JR NZ,LOC_935D: non-croc -- done
    LD      A, (IY+1)                      ; A = (IY+1): Jr Y (croc kill-zone check)
    CP      $CD                            ; CP $CD: Jr Y >= $CD?
    JR      C, LOC_935D                    ; JR C,LOC_935D: in safe zone
    LD      A, (IY+3)                      ; A = (IY+3): Jr X
    CP      $64                            ; CP $64: X >= $64?
    JR      NC, LOC_935D                   ; JR NC,LOC_935D: X above kill zone
    CP      $51                            ; CP $51
    JP      NC, LOC_9317                   ; JP NC,LOC_9317: X in croc kill zone -- life lost

LOC_935D:                                  ; LOC_935D: climb step complete; update Jr sprite
    JP      DELAY_LOOP_950B                ; JP DELAY_LOOP_950B: render Jr sprite and return
    DB      $6C, $93, $76, $93, $77, $93, $7E, $93; climb path jump table + path data ($935E-$9403)
    DB      $85, $93, $86, $93, $77, $8F, $1E, $60
    DB      $78, $BE, $57, $6F, $1E, $FF, $FF, $2E
    DB      $36, $95, $2E, $36, $8E, $FF, $2F, $47
    DB      $D5, $76, $90, $5E, $FF, $FF, $21, $37
    DB      $D5, $FF, $A6, $93, $BB, $93, $D6, $93
    DB      $ED, $93, $00, $01, $01, $02, $02, $03
    DB      $01, $00, $03, $05, $04, $06, $05, $07
    DB      $04, $04, $06, $09, $07, $08, $00, $F9
    DB      $00, $FB, $00, $FD, $00, $FE, $00, $FF
    DB      $00, $01, $00, $02, $00, $03, $00, $05
    DB      $00, $07, $80, $00, $F3, $00, $F6, $00
    DB      $F9, $01, $FA, $03, $FA, $04, $FB, $05
    DB      $FE, $02, $00, $02, $00, $05, $02, $04
    DB      $05, $03, $06, $01, $06, $80, $03, $FC
    DB      $04, $FA, $04, $FC, $03, $FE, $03, $FF
    DB      $03, $01, $03, $02, $04, $04, $04, $06
    DB      $02, $04, $01, $04, $80, $FD, $FC, $FC
    DB      $FA, $FC, $FC, $FD, $FE, $FD, $FF, $FD
    DB      $01, $FD, $02, $FC, $04, $FC, $06, $FE
    DB      $04, $FF, $04, $80

SUB_9404:                                  ; SUB_9404: compute Kong barrel throw trajectory
    LD      DE, $949C                      ; LD DE,$949C: barrel trajectory table base
    LD      A, ($7288)                     ; LD A,($7288): read player number
    LD      L, A                           ; LD L,A: L = player number
    LD      H, $00                         ; LD H,$00: HL = player number
    ADD     HL, HL                         ; ADD HL,HL: HL *= 2
    ADD     HL, HL                         ; ADD HL,HL: HL *= 4
    ADD     HL, DE                         ; ADD HL,DE: HL = table entry for this player
    PUSH    HL                             ; PUSH HL: save table pointer
    POP     IX                             ; PUSH HL: save pointer
    LD      L, (IX+0)                      ; POP IX
    LD      H, (IX+1)                      ; L = (IX+0)
    LD      C, (IX+2)                      ; H = (IX+1): HL = box pointer
    LD      B, (IX+3)                      ; C = (IX+2)
    LD      DE, $70BE                      ; B = (IX+3): BC = box count
    LDIR                                   ; DE = $70BE: collision box array base
    LD      IX, $727A                      ; LDIR: copy collision boxes
    LD      (IX+0), $03                    ; IX = $727A: player entity
    LD      (IX+1), $01                    ; LD (IX+0),$03
    LD      (IX+4), $34                    ; LD (IX+1),$01
    LD      (IX+5), $04                    ; LD (IX+4),$34
    LD      (IX+6), $02                    ; LD (IX+5),$04
    LD      (IX+7), $02                    ; LD (IX+6),$02
    RET                                    ; LD (IX+7),$02

SUB_9441:                                  ; SUB_9441: Junior player collision check -- scan $70BE table for Y/X overlap
    PUSH    IY                             ; PUSH IY
    LD      HL, $70BE                      ; HL = $70BE: collision box array

LOC_9446:                                  ; LOC_9446: scan loop
    PUSH    HL                             ; PUSH HL
    LD      A, (HL)                        ; A = (HL): first byte
    CP      $FE                            ; CP $FE: invalid/end marker?
    JR      Z, LOC_9486                    ; JR Z,LOC_9486: skip
    CALL    SUB_9494                       ; CALL SUB_9494: abs-diff Y compare
    JR      NC, LOC_9486                   ; JR NC,LOC_9486: Y miss
    INC     HL                             ; INC HL
    LD      A, (HL)                        ; A = (HL)
    PUSH    BC                             ; PUSH BC
    LD      B, C                           ; B = C
    CALL    SUB_9494                       ; CALL SUB_9494: abs-diff X compare
    POP     BC                             ; POP BC
    JR      NC, LOC_9486                   ; JR NC,LOC_9486: X miss
    LD      A, $04                         ; LD A,$04: hit!
    LD      ($7342), A                     ; LD ($7342),A: set score-award flag
    CALL    SUB_A48C                       ; CALL SUB_A48C: add score
    POP     HL                             ; POP HL
    LD      (HL), $FE                      ; LD (HL),$FE: mark box consumed
    INC     HL                             ; INC HL
    INC     HL                             ; INC HL
    LD      DE, $733B                      ; DE = $733B
    LD      BC, $0004                      ; BC = $0004: 4 bytes
    LDIR                                   ; LDIR: copy collision record
    LD      A, (HL)                        ; A = (HL)
    LD      ($71D7), A                     ; LD ($71D7),A: snapjaw type
    INC     HL                             ; INC HL
    LD      A, (HL)                        ; A = (HL)
    LD      ($71D8), A                     ; LD ($71D8),A: snapjaw variant
    XOR     A                              ; XOR A
    LD      ($727A), A                     ; LD ($727A),A: clear player entity flag
    CALL    SUB_A6CE                       ; CALL SUB_A6CE: play collision sound
    CALL    SUB_A0BA                       ; CALL SUB_A0BA: update lives display
    POP     IY                             ; POP IY: restore IY (player entity pointer)
    RET                                    ; RET: return from collision handler to game loop

LOC_9486:                                  ; LOC_9486: miss -- advance to next entry (+8 bytes)
    POP     HL                             ; POP HL
    LD      DE, $0008                      ; DE = $0008
    ADD     HL, DE                         ; ADD HL,DE
    LD      A, $FF                         ; A = $FF
    CP      (HL)                           ; CP (HL): end sentinel?
    JP      NZ, LOC_9446                   ; JP NZ,LOC_9446: continue
    POP     IY                             ; POP IY: no table match -- restore IY and return
    RET                                    ; RET: return from LOC_9486 (all collision entries checked)

SUB_9494:                                  ; SUB_9494: abs-diff A vs B compare with H=$06 (±6 range)
    PUSH    HL                             ; PUSH HL
    LD      H, $06                         ; H = $06
    CALL    SUB_A2C3                       ; CALL SUB_A2C3
    POP     HL                             ; POP HL
    RET                                    ; RET: return from DELAY_LOOP_950B
    DB      $A8, $94, $29, $00, $D1, $94, $19, $00
    DB      $EA, $94, $21, $00, $98, $0F, $07, $90
    DB      $4C, $06, $32, $18, $28, $50, $48, $20
    DB      $48, $06, $24, $19, $68, $4F, $47, $60
    DB      $4C, $06, $2C, $19, $B8, $57, $4F, $B0
    DB      $48, $06, $56, $19, $97, $67, $5F, $8F
    DB      $50, $0B, $92, $19, $FF, $48, $76, $6E
    DB      $40, $4C, $06, $C8, $19, $78, $76, $6E
    DB      $70, $4C, $06, $CE, $19, $B8, $76, $6E
    DB      $B0, $4C, $06, $D6, $19, $FF, $38, $37
    DB      $2F, $30, $4C, $06, $C6, $18, $58, $37
    DB      $2F, $50, $4C, $06, $CA, $18, $78, $47
    DB      $3F, $70, $50, $0B, $0E, $19, $A0, $08
    DB      $00, $98, $4C, $06, $13, $18, $FF

DELAY_LOOP_950B:                           ; DELAY_LOOP_950B: update Junior sprite position and call PUTOBJ
    LD      IY, $71EE                      ; IY = $71EE: Junior entity struct
    LD      C, (IY+0)                      ; C = (IY+0): sprite tile index
    XOR     A                              ; XOR A
    LD      B, $09                         ; B = $09: 9 iterations for 3 sprite slots

LOC_9515:                                  ; LOC_9515: multiply C*9 into A
    ADD     A, C                           ; ADD A,C
    DJNZ    LOC_9515                       ; DJNZ LOC_9515
    LD      L, A                           ; L = A
    LD      H, $00                         ; H = $00
    LD      DE, $9549                      ; DE = $9549: sprite layout table
    ADD     HL, DE                         ; ADD HL,DE: index into table
    LD      DE, $72FF                      ; DE = $72FF: sprite output buffer
    PUSH    DE                             ; PUSH DE
    LD      B, $03                         ; B = $03: 3 sprite rows

LOC_9525:                                  ; LOC_9525: build sprite row
    LD      A, (IY+3)                      ; A = (IY+3): X position
    ADD     A, (HL)                        ; ADD A,(HL): X offset from table
    LD      (DE), A                        ; LD (DE),A: write sprite X
    INC     HL                             ; INC HL
    INC     DE                             ; INC DE
    LD      A, (IY+1)                      ; A = (IY+1): Y position
    ADD     A, (HL)                        ; ADD A,(HL): Y offset
    LD      (DE), A                        ; LD (DE),A: write sprite Y
    INC     HL                             ; INC HL
    INC     DE                             ; INC DE
    LD      A, (HL)                        ; A = (HL): tile index
    LD      (DE), A                        ; LD (DE),A: write tile
    INC     HL                             ; INC HL
    INC     DE                             ; INC DE
    INC     DE                             ; INC DE: skip color byte
    DJNZ    LOC_9525                       ; DJNZ LOC_9525
    POP     HL                             ; POP HL
    LD      DE, $0003                      ; DE = $0003: offset to timer field
    ADD     HL, DE                         ; ADD HL,DE
    LD      (HL), $0F                      ; LD (HL),$0F: set timer slot
    INC     DE                             ; INC DE: advance DE to offset 4 (next slot field)
    ADD     HL, DE                         ; ADD HL,DE: next slot
    LD      (HL), $0A                      ; LD (HL),$0A
    ADD     HL, DE                         ; ADD HL,DE
    LD      (HL), $06                      ; LD (HL),$06
    RET                                    ; RET: return from subroutine
    DB      $00, $00, $84, $00, $05, $B4, $00, $00
    DB      $54, $00, $01, $88, $00, $07, $B8, $00
    DB      $00, $58, $00, $00, $8C, $00, $01, $BC
    DB      $00, $00, $5C, $00, $01, $90, $00, $00
    DB      $C0, $00, $01, $60, $00, $01, $94, $00
    DB      $00, $C4, $00, $01, $64, $00, $01, $98
    DB      $00, $00, $C8, $00, $01, $68, $04, $00
    DB      $9C, $00, $04, $CC, $04, $00, $6C, $04
    DB      $04, $A0, $00, $00, $D0, $04, $04, $70
    DB      $02, $01, $A4, $00, $00, $D4, $00, $00
    DB      $74, $02, $03, $A8, $01, $02, $D8, $00
    DB      $00, $78, $03, $03, $AC, $00, $00, $DC
    DB      $02, $00, $7C, $03, $04, $B0, $00, $00
    DB      $E0, $02, $00, $80, $02, $00, $F0, $00
    DB      $00, $F8, $02, $00, $E4, $02, $03, $EC
    DB      $00, $02, $F4, $02, $00, $E8, $C9

SUB_95C8:                                  ; SUB_95C8: main Jr/P1 controller dispatcher
    CALL    DELAY_LOOP_971B                ; CALL DELAY_LOOP_971B: process Jr movement input
    CALL    SUB_9A5C                       ; CALL SUB_9A5C: process Jr position update
    LD      IX, $95D6                      ; LD IX,$95D6: dispatch table entry
    CALL    SUB_807C                       ; CALL SUB_807C: RST $08 trampoline dispatch
    RET                                    ; RET: return from dispatcher
    DB      $FD, $21, $02, $72, $DD, $21, $0B, $73
    DB      $06, $0D, $C5, $ED, $43, $E8, $70, $AF
    DB      $32, $E7, $70, $CD, $84, $96, $3A, $E7
    DB      $70, $B7, $20, $48, $FD, $35, $06, $CC
    DB      $63, $9F, $FD, $7E, $01, $FE, $01, $28
    DB      $3B, $FD, $35, $05, $CC, $8C, $A0, $FD
    DB      $CB, $02, $7E, $C4, $11, $A0, $FD, $7E
    DB      $01, $FE, $06, $C2, $2F, $96, $FD, $7E
    DB      $02, $E6, $F0, $F6, $07, $FD, $77, $02
    DB      $FD, $CB, $04, $6E, $CA, $2F, $96, $FD
    DB      $7E, $02, $E6, $F0, $F6, $09, $FD, $77
    DB      $02, $CD, $28, $9A, $3A, $8B, $70, $FE
    DB      $03, $CC, $E4, $96, $11, $0A, $00, $FD
    DB      $19, $1E, $04, $DD, $19, $C1, $10, $9A
    DB      $3A, $8B, $70, $FE, $03, $20, $04, $32
    DB      $F1, $70, $C9, $3A, $F1, $70, $B7, $C8
    DB      $AF, $32, $F1, $70, $4F, $21, $EB, $70
    DB      $06, $06, $3E, $0F, $BE, $28, $04, $0C
    DB      $23, $10, $F9, $79, $B7, $C8, $3E, $01
    DB      $C5, $CD, $8C, $A4, $CD, $E4, $A6, $C1
    DB      $0D, $C8, $3E, $03, $C5, $CD, $8C, $A4
    DB      $CD, $E4, $A6, $C1, $18, $F2, $FD, $7E
    DB      $00, $B7, $28, $42, $3D, $C8, $3D, $CC
    DB      $96, $96, $3E, $01, $32, $E7, $70, $C9
    DB      $FD, $35, $05, $C0, $FD, $36, $00, $00
    DB      $FD, $36, $05, $04, $FD, $CB, $02, $FE
    DB      $3A, $88, $72, $FD, $7E, $01, $FE, $05
    DB      $C8, $FE, $06, $CC, $C3, $96, $3A, $88
    DB      $72, $B7, $C0, $ED, $5F, $FE, $60, $D8
    DB      $FD, $CB, $04, $A6, $C9, $FD, $CB, $04
    DB      $BE, $FD, $CB, $04, $B6, $C9, $FD, $7E
    DB      $01, $FE, $03, $30, $06, $FE, $01, $C8
    DB      $C3, $34, $9F, $FE, $05, $CA, $3E, $97
    DB      $DA, $FA, $98, $C3, $47, $98, $3A, $EF
    DB      $71, $C6, $08, $DD, $46, $01, $26, $08
    DB      $CD, $C3, $A2, $D0, $18, $00, $3A, $F1
    DB      $71, $C6, $18, $DD, $46, $00, $26, $05
    DB      $CD, $C3, $A2, $D0, $18, $00, $3A, $E9
    DB      $70, $47, $3E, $0C, $90, $47, $21, $EB
    DB      $70, $7E, $B8, $C8, $FE, $0F, $20, $02
    DB      $70, $C9, $23, $18, $F4

DELAY_LOOP_971B:                           ; DELAY_LOOP_971B: scan 12 vine-grip slots -- count grips, store in $7340
    XOR     A                              ; XOR A
    LD      ($7340), A                     ; LD ($7340),A: clear grip count
    LD      DE, $0004                      ; DE = $0004: slot stride
    LD      IX, $730B                      ; IX = $730B: vine-grip table
    LD      C, $00                         ; C = $00: counter
    LD      B, $0C                         ; B = $0C: 12 slots

LOC_972A:                                  ; LOC_972A: scan loop
    LD      A, (IX+0)                      ; A = (IX+0): slot type byte
    SUB     $40                            ; SUB $40: subtract $40
    JR      NC, LOC_9732                   ; JR NC,LOC_9732: >= $40 = not gripping
    INC     C                              ; INC C: grip count++

LOC_9732:                                  ; LOC_9732
    ADD     IX, DE                         ; ADD IX,DE: next slot
    DJNZ    LOC_972A                       ; DJNZ LOC_972A
    LD      A, C                           ; A = C: grip count
    CP      $04                            ; CP $04: at least 4 grips?
    RET     C                              ; RET C: fewer than 4 -- not gripping vine
    LD      ($7340), A                     ; LD ($7340),A: store grip count
    RET                                    ; RET: return from grip scan with count stored in $7340
    DB      $FD, $CB, $02, $76, $C8, $3A, $88, $72
    DB      $FE, $01, $CA, $0D, $98, $26, $47, $0E
    DB      $1B, $06, $1F, $FD, $CB, $04, $6E, $20
    DB      $50, $ED, $5F, $A0, $81, $DD, $86, $00
    DB      $FE, $59, $38, $14, $FE, $79, $30, $10
    DB      $F5, $DD, $7E, $01, $FE, $80, $38, $05
    DB      $F1, $D6, $17, $18, $03, $F1, $C6, $30
    DB      $BC, $38, $01, $7C, $FD, $77, $03, $3A
    DB      $88, $72, $FE, $02, $20, $12, $3A, $8A
    DB      $72, $FE, $31, $38, $0B, $DD, $E5, $FD
    DB      $E5, $CD, $F3, $A6, $FD, $E1, $DD, $E1
    DB      $FD, $CB, $04, $EE, $FD, $CB, $04, $E6
    DB      $FD, $CB, $02, $FE, $FD, $CB, $02, $B6
    DB      $C9, $FD, $36, $03, $00, $FD, $CB, $04
    DB      $AE, $FD, $CB, $04, $A6, $3A, $87, $72
    DB      $3D, $28, $E5, $06, $60, $FE, $04, $38
    DB      $08, $06, $78, $FE, $05, $38, $02, $06
    DB      $AF, $CD, $FD, $1F, $4F, $ED, $5F, $A9
    DB      $B8, $30, $CD, $06, $0C, $21, $03, $72
    DB      $11, $0A, $00, $7E, $FE, $02, $20, $29
    DB      $2B, $7E, $B7, $28, $24, $36, $00, $23
    DB      $23, $23, $36, $78, $3E, $0C, $90, $21
    DB      $0B, $73, $11, $04, $00, $B7, $28, $04
    DB      $19, $3D, $20, $FC, $DD, $7E, $00, $77
    DB      $23, $DD, $7E, $01, $77, $C3, $9E, $97
    DB      $23, $19, $10, $CF, $C3, $9E, $97, $3A
    DB      $89, $72, $E6, $07, $FE, $02, $30, $04
    DB      $26, $97, $18, $02, $26, $A7, $0E, $20
    DB      $06, $1F, $FD, $CB, $04, $6E, $CA, $57
    DB      $97, $DD, $7E, $01, $FE, $80, $38, $0A
    DB      $FD, $36, $03, $0C, $FD, $CB, $04, $A6
    DB      $18, $08, $FD, $36, $03, $FA, $FD, $CB
    DB      $04, $E6, $FD, $CB, $04, $AE, $C3, $9E
    DB      $97, $FD, $7E, $06, $FE, $01, $C0, $FD
    DB      $7E, $04, $E6, $30, $FE, $20, $20, $06
    DB      $FD, $CB, $04, $8E, $18, $04, $FD, $CB
    DB      $04, $CE, $CD, $DE, $98, $FD, $CB, $04
    DB      $6E, $20, $2F, $CD, $EB, $98, $C5, $CD
    DB      $DB, $89, $C1, $C8, $6F, $E5, $CD, $FD
    DB      $1F, $E1, $FE, $20, $D0, $7D, $D6, $08
    DB      $DD, $77, $01, $FD, $CB, $04, $EE, $ED
    DB      $5F, $CB, $47, $28, $47, $DD, $7E, $00
    DB      $D6, $10, $4F, $CD, $DB, $89, $28, $3C
    DB      $18, $31, $C5, $CD, $DB, $89, $C1, $28
    DB      $24, $D6, $08, $DD, $77, $01, $C5, $CD
    DB      $D6, $89, $C1, $C8, $57, $CD, $FD, $1F
    DB      $FE, $38, $D0, $7A, $D6, $0C, $DD, $77
    DB      $00, $FD, $CB, $04, $AE, $ED, $5F, $CB
    DB      $47, $28, $11, $18, $06, $FD, $CB, $04
    DB      $66, $28, $09, $DD, $35, $00, $FD, $CB
    DB      $04, $A6, $18, $07, $DD, $34, $00, $FD
    DB      $CB, $04, $E6, $FD, $CB, $02, $FE, $C9
    DB      $DD, $7E, $01, $C6, $08, $47, $DD, $7E
    DB      $00, $C6, $0C, $4F, $C9, $C5, $CD, $D6
    DB      $89, $C1, $D1, $28, $D0, $D5, $D6, $0C
    DB      $DD, $77, $00, $C9, $FD, $7E, $06, $3D
    DB      $C0, $FD, $CB, $02, $76, $20, $5F, $FD
    DB      $CB, $04, $7E, $C0, $CD, $DE, $98, $3A
    DB      $88, $72, $B7, $20, $08, $FD, $CB, $04
    DB      $66, $28, $6A, $18, $33, $FD, $CB, $04
    DB      $6E, $20, $1A, $CD, $EB, $98, $18, $76
    DB      $CD, $FD, $1F, $FE, $10, $D0, $C5, $CD
    DB      $DB, $89, $C1, $20, $01, $C9, $D6, $08
    DB      $DD, $77, $01, $18, $29, $CD, $FD, $1F
    DB      $FE, $30, $D8, $CD, $D6, $89, $FE, $3F
    DB      $C0, $FD, $CB, $04, $AE, $C3, $D2, $98
    DB      $FD, $CB, $04, $6E, $20, $C7, $78, $FE
    DB      $98, $28, $06, $FE, $CF, $30, $19, $18
    DB      $BC, $79, $FE, $37, $20, $B7, $FD, $CB
    DB      $02, $B6, $FD, $CB, $04, $BE, $FD, $CB
    DB      $04, $EE, $DD, $34, $00, $C3, $D2, $98
    DB      $ED, $5F, $FE, $20, $DA, $C9, $98, $DD
    DB      $36, $01, $D0, $18, $E1, $79, $FE, $37
    DB      $20, $93, $FD, $CB, $04, $FE, $ED, $5F
    DB      $CB, $47, $28, $05, $FD, $36, $03, $10
    DB      $C9, $FD, $36, $03, $20, $C9, $3A, $89
    DB      $72, $FE, $02, $38, $0C, $FE, $05, $38
    DB      $04, $16, $30, $18, $06, $16, $18, $18
    DB      $02, $16, $08, $CD, $FD, $1F, $BA, $D2
    DB      $26, $99, $3A, $F1, $71, $FE, $29, $DA
    DB      $26, $99, $3A, $8B, $70, $3D, $28, $1C
    DB      $3A, $EF, $71, $C6, $08, $6F, $26, $04
    DB      $CD, $C3, $A2, $30, $09, $C5, $CD, $DB
    DB      $89, $C1, $C2, $34, $99, $C9, $7D, $B8
    DB      $38, $34, $18, $28, $3A, $AC, $70, $B7
    DB      $28, $11, $3D, $28, $07, $3A, $EF, $71
    DB      $C6, $10, $18, $0C, $3A, $EF, $71, $C6
    DB      $03, $18, $05, $3A, $EF, $71, $C6, $0D
    DB      $57, $26, $02, $CD, $C3, $A2, $38, $18
    DB      $7A, $B8, $38, $0A, $FD, $CB, $04, $66
    DB      $C2, $26, $99, $C3, $D2, $98, $FD, $CB
    DB      $04, $66, $CA, $26, $99, $C3, $C9, $98
    DB      $3A, $8B, $70, $3D, $C2, $26, $99, $C3
    DB      $2C, $99, $DD, $E5, $21, $F1, $71, $06
    DB      $02, $DD, $7E, $00, $96, $30, $04, $7E
    DB      $DD, $96, $00, $4F, $FD, $7E, $02, $E6
    DB      $0F, $B9, $38, $17, $DD, $23, $2B, $2B
    DB      $10, $E7, $DD, $E1, $FD, $7E, $01, $FE
    DB      $02, $CC, $3F, $9F, $ED, $7B, $59, $70
    DB      $C3, $72, $A1, $DD, $E1, $C9

SUB_9A5C:                                  ; SUB_9A5C: fruit-collection timer -- allocate signal if needed, check expiry
    LD      A, ($70F5)                     ; A = ($70F5): timer active flag
    OR      A                              ; OR A
    JR      NZ, LOC_9A6F                   ; JR NZ,LOC_9A6F: already active
    XOR     A                              ; XOR A
    LD      HL, $0078                      ; HL = $0078: 120 ticks
    CALL    REQUEST_SIGNAL                 ; CALL REQUEST_SIGNAL: allocate fruit timer
    LD      ($72CE), A                     ; LD ($72CE),A: store signal handle
    LD      ($70F5), A                     ; LD ($70F5),A: mark timer active

LOC_9A6F:                                  ; LOC_9A6F: test fruit timer
    LD      A, ($72CE)                     ; A = ($72CE): signal handle
    CALL    TEST_SIGNAL                    ; CALL TEST_SIGNAL
    RET     Z                              ; RET Z: not expired yet
    XOR     A                              ; XOR A
    LD      ($70F5), A                     ; LD ($70F5),A: clear flag
    LD      IX, $730B                      ; IX = $730B: vine-grip table
    LD      IY, $7202                      ; IY = $7202: sprite buffer
    LD      BC, $0004                      ; BC = $0004: stride for IX
    LD      DE, $000A                      ; DE = $000A: stride for IY
    CALL    SOUND_WRITE_A06A               ; CALL SOUND_WRITE_A06A: find Jr sprite, return index in A
    RET     Z                              ; RET Z: no sprite found
    OR      A                              ; OR A: test if slot index A is zero
    JR      Z, LOC_9A96                    ; JR Z,LOC_9A96: index=0 -- skip advance loop

LOC_9A8F:                                  ; LOC_9A8F: advance IX/IY by A slots
    ADD     IX, BC                         ; ADD IX,BC
    ADD     IY, DE                         ; ADD IY,DE
    DEC     A                              ; DEC A
    JR      NZ, LOC_9A8F                   ; JR NZ,LOC_9A8F

LOC_9A96:                                  ; LOC_9A96: update vine slot to grab state
    CALL    SUB_9AAE                       ; CALL SUB_9AAE: init vine grip
    LD      (IX+1), B                      ; LD (IX+1),B: vine slot Y
    LD      (IX+0), C                      ; LD (IX+0),C: vine slot X
    LD      (IY+5), $3C                    ; LD (IY+5),$3C: sprite timer
    LD      (IY+0), $02                    ; LD (IY+0),$02: sprite state = active
    RES     6, (IY+2)                      ; RES 6,(IY+2): clear grip bit
    JP      LOC_A011                       ; JP LOC_A011: update vine sprite tile

SUB_9AAE:                                  ; SUB_9AAE: init vine grip offsets by stage type ($7288)
    LD      A, ($7288)                     ; A = ($7288): 0=vine 1=rope 2=croc
    OR      A                              ; OR A
    JR      Z, LOC_9AC8                    ; JR Z,LOC_9AC8: vine stage
    DEC     A                              ; DEC A
    JR      Z, LOC_9ACE                    ; JR Z,LOC_9ACE: rope stage
    LD      B, $30                         ; B=$30 C=$18: croc stage offsets
    LD      C, $18                         ; A = (IY+1)
    LD      A, (IY+1)                      ; CP $05
    CP      $05                            ; JR NZ,LOC_9AE1
    JR      NZ, LOC_9AE1                   ; LD (IY+3),$98
    LD      (IY+3), $98                    ; JR LOC_9ADD
    JR      LOC_9ADD                       ; JR LOC_9ADD: set flip bit for croc top row

LOC_9AC8:                                  ; LOC_9AC8: vine offsets B=$48 C=$2B
    LD      B, $48                         ; B = $48
    LD      C, $2B                         ; C = $2B
    JR      LOC_9AE1                       ; JR LOC_9AE1

LOC_9ACE:                                  ; LOC_9ACE: rope offsets B=$28 C=$2B
    LD      B, $28                         ; B = $28
    LD      C, $2B                         ; C = $2B
    LD      A, (IY+1)                      ; LD A,(IY+1): read Jr Y position
    CP      $05                            ; CP $05: compare with Y min $05
    JR      NZ, LOC_9AE1                   ; JR NZ,LOC_9AE1: if not at top, skip
    LD      (IY+3), $E6                    ; LD (IY+3),$E6: set Jr X to $E6 (rightmost position)

LOC_9ADD:                                  ; LOC_9ADD: set flip bit 7 of IY+4
    SET     7, (IY+4)                      ; SET 7,(IY+4)

LOC_9AE1:                                  ; LOC_9AE1: set grip bits
    SET     4, (IY+4)                      ; SET 4,(IY+4)
    RES     5, (IY+4)                      ; RES 5,(IY+4)
    RET                                    ; RET: return from SUB_9AAE grip offset init

SUB_9AEA:                                  ; SUB_9AEA: init enemy/vine layout -- copy tables, load VRAM data
    LD      HL, $9F0D                      ; HL=$9F0D DE=$7095 BC=$000F: copy 15-byte snapjaw table
    LD      DE, $7095                      ; LD HL,$9F0D
    LD      BC, $000F                      ; LD DE,$7095
    LDIR                                   ; BC = $000F
    LD      HL, $9F1C                      ; LDIR
    LD      DE, $70F6                      ; HL=$9F1C DE=$70F6 BC=$0018: copy 24-byte vine timer table
    LD      BC, $0018                      ; LD HL,$9F1C
    LDIR                                   ; LD DE,$70F6
    LD      HL, $7112                      ; BC = $0018
    LD      DE, $1320                      ; LDIR
    LD      BC, $0018                      ; HL=$7112: vine tile VRAM buffer
    LD      IX, READ_VRAM                  ; DE=$1320: VRAM destination
    CALL    SUB_807C                       ; BC=$0018: 24 bytes
    CALL    SUB_9BC3                       ; IX = READ_VRAM
    CALL    SUB_9CA1                       ; CALL SUB_807C: read VRAM via BIOS trampoline
    LD      HL, $7172                      ; CALL SUB_9BC3: init P1 vine tile scroll registers
    LD      DE, $0A00                      ; CALL SUB_9CA1: init P2 vine tile scroll registers
    LD      BC, $0020                      ; HL=$7172: horizontal vine buffer
    LD      IX, READ_VRAM                  ; DE=$0A00
    CALL    SUB_807C                       ; BC=$0020
    CALL    SUB_9DAF                       ; IX = READ_VRAM
    RET                                    ; CALL SUB_807C
                                           ; CALL SUB_9DAF: init croc/chain scroll registers
SUB_9B2A:                                  ; SUB_9B2A: enemy spawn / movement -- only runs for stage type 2 (crocs)
    LD      A, ($7288)                     ; A = ($7288): stage type
    CP      $02                            ; CP $02
    RET     NZ                             ; RET NZ: only run for croc stage
    LD      HL, $70FE                      ; HL = $70FE: enemy spawn countdown
    DEC     (HL)                           ; DEC (HL)
    JP      NZ, LOC_9BF6                   ; JP NZ,LOC_9BF6: not yet
    LD      (HL), $02                      ; LD (HL),$02: reload 2

LOC_9B39:                                  ; LOC_9B39: P1 vine column scroll countdown
    LD      HL, $70FF                      ; LD HL,$70FF: P1 vine column counter
    DEC     (HL)                           ; DEC (HL): decrement column counter
    JR      Z, LOC_9B59                    ; JR Z,LOC_9B59: if zero, advance to next column set
    PUSH    HL                             ; PUSH HL: save counter pointer
    CALL    SUB_9BA6                       ; CALL SUB_9BA6: draw P1 vine sound tiles
    CALL    SUB_9BB8                       ; CALL SUB_9BB8: copy P1 vine tiles to VRAM
    POP     HL                             ; POP HL: restore pointer
    LD      A, $07                         ; LD A,$07: check counter = 7
    CP      (HL)                           ; CP (HL): compare
    JR      NZ, LOC_9B57                   ; JR NZ,LOC_9B57: if not 7, skip tile refresh
    LD      HL, $9EF1                      ; LD HL,$9EF1: vine tile pattern data
    LD      DE, ($7102)                    ; LD DE,($7102): P1 VRAM vine address
    LD      BC, $0005                      ; LD BC,$0005: 5 bytes to copy
    RST     $08                            ; RST $08: BIOS block copy to VRAM

LOC_9B57:                                  ; LOC_9B57: jump to post-scroll update
    JR      LOC_9B96                       ; JR LOC_9B96: continue to sprite update

LOC_9B59:                                  ; LOC_9B59: advance P1 vine to next column
    LD      (HL), $08                      ; LD (HL),$08: reload column counter to 8
    LD      HL, $7100                      ; LD HL,$7100: P1 vine column position
    DEC     (HL)                           ; DEC (HL): decrement column position
    JR      NZ, LOC_9B71                   ; JR NZ,LOC_9B71: if not zero, scroll vine
    LD      (HL), $03                      ; LD (HL),$03: reload position counter to 3
    LD      A, ($7101)                     ; LD A,($7101): read P1 vine direction
    XOR     $01                            ; XOR $01: toggle direction
    LD      ($7101), A                     ; LD ($7101),A: store new direction
    LD      HL, $70FF                      ; LD HL,$70FF: P1 vine column counter
    DEC     (HL)                           ; DEC (HL): decrement again
    JR      LOC_9B39                       ; JR LOC_9B39: loop back

LOC_9B71:                                  ; LOC_9B71: scroll P1 vine tile
    LD      A, ($7101)                     ; LD A,($7101): read vine scroll direction
    OR      A                              ; OR A: test if zero
    LD      HL, $9EEB                      ; LD HL,$9EEB: vine tile data (forward)
    LD      DE, $0001                      ; LD DE,$0001: VRAM advance +1
    JR      NZ, LOC_9B83                   ; JR NZ,LOC_9B83: if nonzero direction, skip
    LD      HL, $9EEC                      ; LD HL,$9EEC: vine tile data (reverse)
    LD      DE, $FFFF                      ; LD DE,$FFFF: VRAM advance -1

LOC_9B83:                                  ; LOC_9B83: write vine tile and update VRAM pointer
    PUSH    DE                             ; PUSH DE: save VRAM advance
    LD      DE, ($7102)                    ; LD DE,($7102): load P1 VRAM vine address
    PUSH    DE                             ; PUSH DE: save current VRAM address
    LD      BC, $0005                      ; LD BC,$0005: bytes to copy
    RST     $08                            ; RST $08: write vine tile to VRAM
    POP     HL                             ; POP HL: restore VRAM address as HL
    POP     DE                             ; POP DE: restore advance delta
    ADD     HL, DE                         ; ADD HL,DE: compute new VRAM address
    LD      ($7102), HL                    ; LD ($7102),HL: store updated VRAM address
    CALL    SUB_9BC3                       ; CALL SUB_9BC3: reinit P1 vine tile buffer

LOC_9B96:                                  ; LOC_9B96: update P1 vine sprite attributes
    LD      HL, $7101                      ; LD HL,$7101: vine direction pointer
    LD      IX, $7095                      ; LD IX,$7095: P1 vine sprite IX base
    CALL    SUB_9E29                       ; CALL SUB_9E29: update vine sprite position
    CALL    SUB_9EBF                       ; CALL SUB_9EBF: check vine-Jr collision
    JP      LOC_9BF6                       ; JP LOC_9BF6: continue to P2 vine update

SUB_9BA6:                                  ; SUB_9BA6: draw P1 vine sound tile set
    LD      A, ($7101)                     ; LD A,($7101): read P1 vine direction
    OR      A                              ; OR A: test direction
    LD      HL, $712A                      ; LD HL,$712A: P1 vine tile buffer left
    LD      B, $05                         ; LD B,$05: 5 tiles
    JR      NZ, LOC_9BB4                   ; JR NZ,LOC_9BB4: if nonzero, use left buffer
    LD      HL, $714A                      ; LD HL,$714A: P1 vine tile buffer right

LOC_9BB4:                                  ; LOC_9BB4: write vine tiles from buffer
    CALL    SOUND_WRITE_9DE3               ; CALL SOUND_WRITE_9DE3: write vine tile data to VRAM
    RET                                    ; RET: return

SUB_9BB8:                                  ; SUB_9BB8: copy P1 vine tile source to buffer
    LD      HL, $712A                      ; LD HL,$712A: P1 vine tile buffer
    LD      DE, $1258                      ; LD DE,$1258: P1 VRAM vine target row
    LD      BC, $0028                      ; LD BC,$0028: 40 bytes
    RST     $08                            ; RST $08: block copy
    RET                                    ; RET: return

SUB_9BC3:                                  ; SUB_9BC3: clear and reload P1 vine tile buffer
    LD      HL, $712A                      ; LD HL,$712A: P1 tile buffer start
    LD      (HL), $00                      ; LD (HL),$00: clear first byte
    LD      DE, $712B                      ; LD DE,$712B: P1 tile buffer +1
    LD      BC, $0027                      ; LD BC,$0027: 39 bytes
    LDIR                                   ; LDIR: clear buffer
    LD      A, ($7101)                     ; LD A,($7101): read P1 vine direction
    OR      A                              ; OR A: test direction
    LD      DE, $712A                      ; LD DE,$712A: left buffer destination
    PUSH    AF                             ; PUSH AF: save direction flag
    JR      NZ, LOC_9BDD                   ; JR NZ,LOC_9BDD: if nonzero, use left destination
    LD      DE, $7132                      ; LD DE,$7132: right buffer destination

LOC_9BDD:                                  ; LOC_9BDD: copy P1 vine tile row A into buffer
    LD      HL, $7112                      ; LD HL,$7112: vine tile source row A
    LD      BC, $0010                      ; LD BC,$0010: 16 bytes
    PUSH    BC                             ; PUSH BC: save count
    LDIR                                   ; LDIR: copy row A
    POP     BC                             ; POP BC: restore count
    POP     AF                             ; POP AF: restore direction
    LD      DE, $713A                      ; LD DE,$713A: second half destination A
    JR      NZ, LOC_9BF0                   ; JR NZ,LOC_9BF0: if nonzero, use destination A
    LD      DE, $7142                      ; LD DE,$7142: second half destination B

LOC_9BF0:                                  ; LOC_9BF0: copy P1 vine tile row B
    LD      HL, $711A                      ; LD HL,$711A: vine tile source row B
    LDIR                                   ; LDIR: copy row B
    RET                                    ; RET: return from SUB_9BC3

LOC_9BF6:                                  ; LOC_9BF6: P2 vine scroll countdown
    LD      HL, $70F6                      ; LD HL,$70F6: P2 vine frame counter
    DEC     (HL)                           ; DEC (HL): decrement frame counter
    JP      NZ, LOC_9CC3                   ; JP NZ,LOC_9CC3: if not zero, skip to rope update
    LD      (HL), $02                      ; LD (HL),$02: reload P2 vine frame counter

LOC_9BFF:                                  ; LOC_9BFF: P2 vine column countdown
    LD      HL, $70F7                      ; LD HL,$70F7: P2 vine column counter
    DEC     (HL)                           ; DEC (HL): decrement column counter
    JR      Z, LOC_9C20                    ; JR Z,LOC_9C20: if zero, advance column
    PUSH    HL                             ; PUSH HL: save counter pointer
    CALL    SUB_9C84                       ; CALL SUB_9C84: draw P2 vine sound tiles
    CALL    SUB_9C96                       ; CALL SUB_9C96: copy P2 vine tiles to VRAM
    POP     HL                             ; POP HL: restore pointer
    LD      A, $07                         ; LD A,$07: check counter = 7
    CP      (HL)                           ; CP (HL): compare with counter
    JP      NZ, LOC_9C1E                   ; JP NZ,LOC_9C1E: if not 7, skip tile refresh
    LD      HL, $9EFB                      ; LD HL,$9EFB: vine tile pattern data for P2
    LD      DE, ($70FA)                    ; LD DE,($70FA): P2 VRAM vine address
    LD      BC, $0004                      ; LD BC,$0004: 4 bytes
    RST     $08                            ; RST $08: copy tile to VRAM

LOC_9C1E:                                  ; LOC_9C1E: jump to post-column update
    JR      LOC_9C5D                       ; JR LOC_9C5D: continue to sprite update

LOC_9C20:                                  ; LOC_9C20: advance P2 vine to next column
    LD      (HL), $08                      ; LD (HL),$08: reload column counter
    LD      HL, $70F8                      ; LD HL,$70F8: P2 vine column position
    DEC     (HL)                           ; DEC (HL): decrement position
    JR      NZ, LOC_9C38                   ; JR NZ,LOC_9C38: if not zero, scroll vine
    LD      (HL), $06                      ; LD (HL),$06: reload position to 6
    LD      A, ($70F9)                     ; LD A,($70F9): read P2 vine direction
    XOR     $01                            ; XOR $01: toggle direction
    LD      ($70F9), A                  ; RAM $70F9
    LD      HL, $70F7                   ; RAM $70F7
    DEC     (HL)                           ; DEC (HL): decrement P2 vine column counter
    JR      LOC_9BFF                       ; JR LOC_9BFF: loop back to P2 column countdown

LOC_9C38:                                  ; LOC_9C38: scroll P2 vine tile
    LD      A, ($70F9)                     ; LD A,($70F9): read P2 vine direction
    OR      A                              ; OR A: test direction
    LD      HL, $9EF6                      ; LD HL,$9EF6: P2 vine tile data (forward)
    LD      DE, $0001                      ; LD DE,$0001: VRAM advance +1
    JR      NZ, LOC_9C4A                   ; JR NZ,LOC_9C4A: if nonzero direction, skip
    LD      HL, $9EF7                      ; LD HL,$9EF7: P2 vine tile data (reverse)
    LD      DE, $FFFF                      ; LD DE,$FFFF: VRAM advance -1

LOC_9C4A:                                  ; LOC_9C4A: write P2 vine tile and update pointer
    PUSH    DE                             ; PUSH DE: save advance delta
    LD      DE, ($70FA)                    ; LD DE,($70FA): load P2 VRAM vine address
    PUSH    DE                             ; PUSH DE: save current address
    LD      BC, $0004                      ; LD BC,$0004: bytes to copy
    RST     $08                            ; RST $08: write P2 vine tile
    POP     HL                             ; POP HL: restore address as HL
    POP     DE                             ; POP DE: restore advance delta
    ADD     HL, DE                         ; ADD HL,DE: compute new address
    LD      ($70FA), HL                    ; LD ($70FA),HL: store updated P2 VRAM address
    CALL    SUB_9CA1                       ; CALL SUB_9CA1: reinit P2 vine tile buffer

LOC_9C5D:                                  ; LOC_9C5D: update P2 vine sprite attributes
    LD      HL, $70F9                      ; LD HL,$70F9: P2 vine direction pointer
    LD      IX, $7098                      ; LD IX,$7098: P2 vine sprite IX base
    CALL    SUB_9E29                       ; CALL SUB_9E29: update vine sprite position
    CALL    SUB_9EBF                       ; CALL SUB_9EBF: check vine-Jr collision P2
    LD      IX, $70A1                      ; LD IX,$70A1: rope sprite IX base
    LD      A, (HL)                        ; LD A,(HL): read direction
    OR      A                              ; OR A: test
    JR      NZ, LOC_9C73                   ; JR NZ,LOC_9C73: if nonzero, negate
    DEC     A                              ; DEC A: A = -1 (scroll left)

LOC_9C73:                                  ; LOC_9C73: update rope sprite positions
    PUSH    AF                             ; PUSH AF: save delta
    ADD     A, (IX+1)                      ; ADD A,(IX+1): add to rope sprite Y
    LD      (IX+1), A                      ; LD (IX+1),A: update rope Y
    POP     AF                             ; POP AF: restore delta
    ADD     A, (IX+2)                      ; ADD A,(IX+2): add to rope sprite X
    LD      (IX+2), A                      ; LD (IX+2),A: update rope X
    JP      LOC_9CC3                       ; JP LOC_9CC3: continue to rope update

SUB_9C84:                                  ; SUB_9C84: draw P2 vine sound tiles
    LD      A, ($70F9)                     ; LD A,($70F9): read P2 vine direction
    OR      A                              ; OR A: test direction
    LD      HL, $7152                      ; LD HL,$7152: P2 vine tile buffer left
    LD      B, $04                         ; LD B,$04: 4 tiles
    JR      NZ, LOC_9C92                   ; JR NZ,LOC_9C92: if nonzero, use left buffer
    LD      HL, $716A                   ; RAM $716A

LOC_9C92:                                  ; LOC_9C92: write P2 vine tiles from buffer
    CALL    SOUND_WRITE_9DE3               ; CALL SOUND_WRITE_9DE3: write vine tile data to VRAM
    RET                                    ; RET: return from SUB_9C84

SUB_9C96:                                  ; SUB_9C96: copy P2 vine tile source to VRAM
    LD      HL, $7152                      ; LD HL,$7152: P2 vine tile buffer
    LD      DE, $1290                      ; LD DE,$1290: P2 VRAM vine target row
    LD      BC, $0020                      ; LD BC,$0020: 32 bytes
    RST     $08                            ; RST $08: block copy
    RET                                    ; RET: return from SUB_9C96

SUB_9CA1:                                  ; SUB_9CA1: clear and reload P2 vine tile buffer
    LD      HL, $7152                      ; LD HL,$7152: P2 tile buffer start
    LD      (HL), $00                      ; LD (HL),$00: clear first byte
    LD      DE, $7153                      ; LD DE,$7153: P2 tile buffer +1
    LD      BC, $001F                      ; LD BC,$001F: 31 bytes
    LDIR                                   ; LDIR: clear buffer
    LD      A, ($70F9)                     ; LD A,($70F9): read P2 vine direction
    OR      A                              ; OR A: test direction
    LD      DE, $7152                      ; LD DE,$7152: left buffer destination
    JR      NZ, LOC_9CBA                   ; JR NZ,LOC_9CBA: if nonzero, use left
    LD      DE, $715A                      ; LD DE,$715A: right buffer destination

LOC_9CBA:                                  ; LOC_9CBA: copy P2 vine tile source into buffer
    LD      HL, $7112                      ; LD HL,$7112: vine tile source
    LD      BC, $0018                      ; LD BC,$0018: 24 bytes
    LDIR                                   ; LDIR: copy
    RET                                    ; RET: return from SUB_9CA1

LOC_9CC3:                                  ; LOC_9CC3: rope frame counter countdown
    LD      HL, $7106                      ; LD HL,$7106: rope frame counter
    DEC     (HL)                           ; DEC (HL): decrement
    RET     NZ                             ; RET NZ: if not expired, return
    LD      (HL), $02                      ; LD (HL),$02: reload rope counter

LOC_9CCA:                                  ; LOC_9CCA: rope column countdown
    LD      HL, $7107                      ; LD HL,$7107: rope column counter
    DEC     (HL)                           ; DEC (HL): decrement column counter
    JR      Z, LOC_9CF1                    ; JR Z,LOC_9CF1: if zero, advance rope column
    PUSH    HL                             ; PUSH HL: save pointer
    CALL    SUB_9D92                       ; CALL SUB_9D92: draw rope segment tiles
    CALL    SUB_9DA4                       ; CALL SUB_9DA4: copy rope tiles to VRAM
    POP     HL                             ; POP HL: restore pointer
    LD      A, $07                         ; LD A,$07: check counter = 7
    CP      (HL)                           ; CP (HL): compare
    JR      NZ, LOC_9CEF                   ; JR NZ,LOC_9CEF: if not 7, skip tile refresh
    LD      DE, ($710A)                    ; LD DE,($710A): first rope VRAM address
    LD      B, $02                         ; LD B,$02: 2 bytes
    CALL    DELAY_LOOP_9E0F                ; CALL DELAY_LOOP_9E0F: write rope tile 1 to VRAM
    LD      DE, ($710C)                    ; LD DE,($710C): second rope VRAM address
    LD      B, $03                         ; LD B,$03: 3 bytes
    CALL    DELAY_LOOP_9E0F                ; CALL DELAY_LOOP_9E0F: write rope tile 2 to VRAM

LOC_9CEF:                                  ; LOC_9CEF: jump to post-rope update
    JR      LOC_9D50                       ; JR LOC_9D50: continue to rope sprite update

LOC_9CF1:                                  ; LOC_9CF1: advance rope to next column
    LD      (HL), $08                      ; LD (HL),$08: reload column counter
    LD      HL, $7108                      ; LD HL,$7108: rope column position
    DEC     (HL)                           ; DEC (HL): decrement position
    JR      NZ, LOC_9D09                   ; JR NZ,LOC_9D09: if not zero, scroll rope
    LD      (HL), $03                      ; LD (HL),$03: reload position counter
    LD      A, ($7109)                     ; LD A,($7109): read rope direction
    XOR     $01                            ; XOR $01: toggle direction
    LD      ($7109), A                  ; RAM $7109
    LD      HL, $7107                   ; RAM $7107
    DEC     (HL)                           ; DEC (HL): decrement rope column counter
    JR      LOC_9CCA                       ; JR LOC_9CCA: loop back to rope column

LOC_9D09:                                  ; LOC_9D09: scroll rope tile
    LD      A, ($7109)                     ; LD A,($7109): read rope direction
    OR      A                              ; OR A: test direction
    LD      HL, $9EFF                      ; LD HL,$9EFF: rope tile data (forward)
    LD      BC, $9F06                      ; LD BC,$9F06: secondary rope tile data pointer
    LD      DE, $0001                      ; LD DE,$0001: VRAM advance +1
    JR      NZ, LOC_9D21                   ; JR NZ,LOC_9D21: if nonzero direction, skip
    LD      HL, $9F00                      ; LD HL,$9F00: rope tile data (reverse)
    LD      BC, $9F07                      ; LD BC,$9F07: secondary pointer reverse
    LD      DE, $FFFF                      ; LD DE,$FFFF: VRAM advance -1

LOC_9D21:                                  ; LOC_9D21: write rope tiles and update pointers
    PUSH    DE                             ; PUSH DE: save advance delta
    LD      ($7110), BC                    ; LD ($7110),BC: save secondary rope tile pointer
    LD      ($710E), HL                    ; LD ($710E),HL: save primary rope tile pointer
    LD      DE, ($710A)                    ; LD DE,($710A): first rope VRAM address
    LD      B, $02                         ; LD B,$02: 2 bytes
    CALL    DELAY_LOOP_9D75                ; CALL DELAY_LOOP_9D75: write first rope tile
    LD      HL, ($710E)                    ; LD HL,($710E): reload primary pointer
    LD      DE, ($710C)                    ; LD DE,($710C): second rope VRAM address
    LD      B, $03                         ; LD B,$03: 3 bytes
    CALL    DELAY_LOOP_9D75                ; CALL DELAY_LOOP_9D75: write second rope tile
    POP     DE                             ; POP DE: restore advance delta
    LD      HL, ($710A)                    ; LD HL,($710A): first rope VRAM address
    ADD     HL, DE                         ; ADD HL,DE: advance first address
    LD      ($710A), HL                    ; LD ($710A),HL: store updated first address
    LD      HL, ($710C)                    ; LD HL,($710C): second rope VRAM address
    ADD     HL, DE                         ; ADD HL,DE: advance second address
    LD      ($710C), HL                    ; LD ($710C),HL: store updated second address
    CALL    SUB_9DAF                       ; CALL SUB_9DAF: reinit rope tile buffers

LOC_9D50:                                  ; LOC_9D50: update rope sprite attributes
    LD      IX, $709B                      ; LD IX,$709B: rope sprite IX base
    LD      HL, $7109                      ; LD HL,$7109: rope direction pointer
    CALL    SUB_9E58                       ; CALL SUB_9E58: update rope sprite from direction
    LD      A, (HL)                        ; LD A,(HL): read direction
    OR      A                              ; OR A: test
    JR      NZ, LOC_9D5F                   ; JR NZ,LOC_9D5F: if nonzero, use as-is
    DEC     A                              ; DEC A: A = -1 (scroll left)

LOC_9D5F:                                  ; LOC_9D5F: update two rope sprite pairs
    PUSH    AF                             ; PUSH AF: save delta
    ADD     A, (IX+0)                      ; ADD A,(IX+0): add to first rope sprite
    LD      (IX+0), A                      ; LD (IX+0),A: update
    LD      IX, $709E                      ; LD IX,$709E: second rope sprite base
    CALL    SUB_9E58                       ; CALL SUB_9E58: update second rope sprite
    POP     AF                             ; POP AF: restore delta
    ADD     A, (IX+0)                      ; ADD A,(IX+0): add to second rope sprite
    LD      (IX+0), A                      ; LD (IX+0),A: update
    RET                                    ; RET: return from rope update

DELAY_LOOP_9D75:                           ; DELAY_LOOP_9D75: RST $08 write 3 bytes to VRAM DE, loop B times, advancing DE by $20
    PUSH    BC                             ; PUSH BC
    PUSH    HL                             ; PUSH HL
    PUSH    DE                             ; PUSH DE
    LD      BC, $0003                      ; BC = $0003
    RST     $08                            ; RST $08: write 3 bytes from HL to VRAM DE
    POP     HL                             ; POP HL
    LD      DE, $0020                      ; LD DE,$0020
    ADD     HL, DE                         ; ADD HL,DE: advance source by 32
    DB      $EB                            ; DB $EB: EX DE,HL
    POP     HL                             ; POP HL
    POP     BC                             ; POP BC
    DJNZ    DELAY_LOOP_9D75                ; DJNZ DELAY_LOOP_9D75
    LD      HL, ($7110)                    ; HL = ($7110)
    LD      BC, $0003                      ; BC = $0003
    RST     $08                            ; RST $08: final row write
    RET                                    ; RET: return from vine scroll tile write loop
    DB      $CD, $AF, $9D, $C9

SUB_9D92:                                  ; SUB_9D92: select vine scroll source buffer by direction flag $7109
    LD      A, ($7109)                     ; A = ($7109): vine scroll direction
    OR      A                              ; OR A
    LD      HL, $7192                      ; HL = $7192
    LD      B, $06                         ; B = $06
    JR      NZ, LOC_9DA0                   ; JR NZ,LOC_9DA0: direction=1
    LD      HL, $71BA                      ; HL = $71BA

LOC_9DA0:                                  ; LOC_9DA0: draw rope sound tiles from selected buffer
    CALL    SOUND_WRITE_9DE3               ; CALL SOUND_WRITE_9DE3: write rope tile data to VRAM
    RET                                    ; RET: return from SUB_9D92

SUB_9DA4:                                  ; SUB_9DA4: copy vine scroll data to VRAM ($0B48, 48 bytes)
    LD      HL, $7192                      ; HL = $7192
    LD      DE, $0B48                      ; DE = $0B48
    LD      BC, $0030                      ; BC = $0030
    RST     $08                            ; RST $08
    RET                                    ; RET: return from SUB_9DA4 vine scroll VRAM copy

SUB_9DAF:                                  ; SUB_9DAF: shift vine scroll buffer left, reload from VRAM $7172
    LD      HL, $7192                      ; LD HL,$7192: rope tile buffer start
    LD      (HL), $00                      ; LD (HL),$00: clear first byte
    LD      DE, $7193                      ; LD DE,$7193: rope tile buffer +1
    LD      BC, $002F                      ; LD BC,$002F: 47 bytes
    LDIR                                   ; LDIR: clear rope tile buffer
    LD      A, ($7109)                     ; LD A,($7109): read rope direction
    OR      A                              ; OR A: test direction
    LD      DE, $7192                      ; LD DE,$7192: left buffer destination
    PUSH    AF                             ; PUSH AF: save direction flag
    JR      NZ, LOC_9DC9                   ; JR NZ,LOC_9DC9: if nonzero, use left dest
    LD      DE, $719A                      ; LD DE,$719A: right buffer destination

LOC_9DC9:                                  ; LOC_9DC9: copy rope tile row A to buffer
    LD      HL, $7172                      ; LD HL,$7172: rope tile source row A
    LD      BC, $0010                      ; LD BC,$0010: 16 bytes
    LDIR                                   ; LDIR: copy row A
    POP     AF                             ; POP AF: restore direction
    LD      DE, $71AA                      ; LD DE,$71AA: second half destination A
    JR      NZ, LOC_9DDA                   ; JR NZ,LOC_9DDA: if nonzero, use destination A
    LD      DE, $71B2                      ; LD DE,$71B2: second half destination B

LOC_9DDA:                                  ; LOC_9DDA: copy rope tile row B
    LD      HL, $7182                      ; LD HL,$7182: rope tile source row B
    LD      BC, $0010                      ; LD BC,$0010: 16 bytes
    LDIR                                   ; LDIR: copy row B
    RET                                    ; RET: return from SOUND_WRITE_9DE3

SOUND_WRITE_9DE3:                          ; SOUND_WRITE_9DE3: bit-rotate B bytes of vine tile data starting at HL
    LD      C, $08                         ; C = $08: 8 bit-columns
    JR      NZ, LOC_9DFB                   ; JR NZ,LOC_9DFB: NZ = rotate right

LOC_9DE7:                                  ; LOC_9DE7: rotate-left path
    PUSH    BC                             ; PUSH BC
    PUSH    HL                             ; PUSH HL
    OR      A                              ; OR A: clear carry

LOC_9DEA:                                  ; LOC_9DEA: RL (HL) + step 8 bytes back
    RL      (HL)                           ; RL (HL): rotate left through carry
    PUSH    AF                             ; PUSH AF
    LD      DE, $FFF8                      ; DE = $FFF8: -8
    ADD     HL, DE                         ; ADD HL,DE: step back 8 bytes
    POP     AF                             ; POP AF
    DJNZ    LOC_9DEA                       ; DJNZ LOC_9DEA
    POP     HL                             ; POP HL
    INC     HL                             ; INC HL: next byte column
    POP     BC                             ; POP BC
    DEC     C                              ; DEC C
    JR      NZ, LOC_9DE7                   ; JR NZ,LOC_9DE7
    RET                                    ; RET: return from SOUND_WRITE_9DE3 tile rotation loop

LOC_9DFB:                                  ; LOC_9DFB: rotate-right path
    PUSH    BC                             ; PUSH BC
    PUSH    HL                             ; PUSH HL
    OR      A                              ; OR A

LOC_9DFE:                                  ; LOC_9DFE: RR (HL) + step 8 bytes forward
    RR      (HL)                           ; RR (HL)
    PUSH    AF                             ; PUSH AF
    LD      DE, $0008                      ; DE = $0008
    ADD     HL, DE                         ; ADD HL,DE: step forward 8 bytes
    POP     AF                             ; POP AF: restore AF after tile write
    DJNZ    LOC_9DFE                       ; DJNZ LOC_9DFE: loop for B bytes
    POP     HL                             ; POP HL: restore HL pointer
    INC     HL                             ; INC HL: advance to next entry
    POP     BC                             ; POP BC: restore BC outer loop
    DEC     C                              ; DEC C: decrement outer count
    JR      NZ, LOC_9DFB                   ; JR NZ,LOC_9DFB: loop all entries
    RET                                    ; RET: return from DELAY_LOOP_9E0F

DELAY_LOOP_9E0F:                           ; DELAY_LOOP_9E0F: write vine tile rows to VRAM DE, B iterations, step $20
    PUSH    BC                             ; PUSH BC
    LD      HL, $9F03                      ; HL = $9F03: vine tile data source
    PUSH    DE                             ; PUSH DE
    LD      BC, $0003                      ; BC = $0003
    RST     $08                            ; RST $08: write 3 bytes
    POP     HL                             ; POP HL
    LD      DE, $0020                      ; LD DE,$0020
    ADD     HL, DE                         ; ADD HL,DE
    DB      $EB                            ; DB $EB: EX DE,HL
    POP     BC                             ; POP BC
    DJNZ    DELAY_LOOP_9E0F                ; DJNZ DELAY_LOOP_9E0F
    LD      BC, $0003                      ; BC = $0003
    LD      HL, $9F0A                      ; HL = $9F0A
    RST     $08                            ; RST $08
    RET                                    ; RET: return from DELAY_LOOP_9E0F vine tile VRAM write

SUB_9E29:                                  ; SUB_9E29: vertical platform collision check for Junior vs vine/ground row
    PUSH    HL                             ; PUSH HL
    PUSH    IX                             ; PUSH IX
    LD      IY, $71EE                      ; IY = $71EE: Junior entity
    LD      C, A                           ; C = A: save direction
    LD      A, ($708B)                     ; A = ($708B): Kong phase
    CP      $01                            ; CP $01
    JP      Z, LOC_9EB8                    ; JP Z,LOC_9EB8: Kong in phase 1 -- skip
    LD      A, $08                         ; A=$08 + (IY+1): Jr Y + 8
    ADD     A, (IY+1)                      ; ADD A,(IY+1)
    CP      (IX+1)                         ; CP (IX+1): vs platform top
    JP      C, LOC_9EB8                    ; JP C,LOC_9EB8: Jr above platform
    CP      (IX+2)                         ; CP (IX+2): vs platform bottom
    JP      NC, LOC_9EB8                   ; JP NC,LOC_9EB8: Jr below platform
    LD      A, (IY+3)                      ; A = (IY+3): Jr X
    ADD     A, $10                         ; ADD A,$10: X + 16
    CP      (IX+0)                         ; CP (IX+0): vs platform X
    JP      NZ, LOC_9EB8                   ; JP NZ,LOC_9EB8: X mismatch
    JP      LOC_9EA4                       ; JP LOC_9EA4: hit!

SUB_9E58:                                  ; SUB_9E58: horizontal vine collision check for Junior vs vine column
    PUSH    HL                             ; PUSH HL
    PUSH    IX                             ; PUSH IX
    LD      IY, $71EE                      ; IY = $71EE
    LD      A, ($708B)                     ; A = ($708B): Kong phase
    OR      A                              ; OR A
    JR      Z, LOC_9EB8                    ; JR Z,LOC_9EB8: Kong on ground -- skip
    LD      A, (IY+3)                      ; A = (IY+3): Jr X
    CP      (IX+1)                         ; CP (IX+1): vs vine left edge
    JR      C, LOC_9EB8                    ; JR C,LOC_9EB8
    CP      (IX+2)                         ; CP (IX+2): vs vine right edge
    JR      NC, LOC_9EB8                   ; JR NC,LOC_9EB8
    LD      A, ($70AC)                     ; A = ($70AC): Kong side
    LD      B, $0A                         ; B = $0A
    CP      $00                            ; CP $00
    JR      Z, LOC_9E90                    ; JR Z,LOC_9E90: left -- B=$0A
    CP      $01                            ; CP $01
    LD      B, $03                         ; B=$03
    JR      Z, LOC_9E90                    ; JR Z,LOC_9E90: direction=1 -- use B=$03 row bias
    CP      $02                            ; CP $02: direction=2 (climbing up)?
    JR      NZ, LOC_9EB8                   ; CP $02
    LD      A, (IY+0)                      ; JR NZ,LOC_9EB8
    CP      $0A                            ; A = (IY+0): Jr sprite tile
    LD      B, $00                         ; CP $0A
    JR      Z, LOC_9E90                    ; B=$00
    LD      B, $11                         ; JR Z,LOC_9E90
                                           ; B=$11
LOC_9E90:                                  ; LOC_9E90: vine-Jr proximity hit check
    LD      A, B                           ; LD A,B: A = vine row B
    ADD     A, (IY+1)                      ; ADD A,(IY+1): add Jr Y
    ADD     A, $FD                         ; ADD A,$FD: bias -3
    CP      (IX+0)                         ; CP (IX+0): compare with vine sprite left edge
    JR      NC, LOC_9EB8                   ; JR NC,LOC_9EB8: if at or right of left edge, continue
    ADD     A, $06                         ; ADD A,$06: add 6 for right-edge check
    CP      (IX+0)                         ; CP (IX+0): compare with left edge
    JR      C, LOC_9EB8                    ; JR C,LOC_9EB8: if left of left edge, no hit
    LD      D, $01                         ; LD D,$01: D=1 signals vine hit

LOC_9EA4:                                  ; LOC_9EA4: collision confirmed
    LD      A, (HL)                        ; A = (HL): scroll speed from vine table
    OR      A                              ; OR A
    JR      NZ, LOC_9EA9                   ; JR NZ,LOC_9EA9: non-zero speed
    DEC     A                              ; DEC A: A = $FF (-1)

LOC_9EA9:                                  ; LOC_9EA9: apply scroll to Junior Y
    LD      C, A                           ; C = A
    ADD     A, (IY+1)                      ; ADD A,(IY+1): IY+1 += speed
    LD      (IY+1), A                      ; LD (IY+1),A
    LD      A, (IY+0)                      ; A = (IY+0): sprite tile
    CP      $0B                            ; CP $0B
    CALL    Z, SUB_9ED3                    ; CALL Z,SUB_9ED3: at vine-end -- snap Jr position

LOC_9EB8:                                  ; LOC_9EB8: end of collision check
    CALL    DELAY_LOOP_950B                ; CALL DELAY_LOOP_950B: update Junior sprite
    POP     IX                             ; POP IX
    POP     HL                             ; POP HL
    RET                                    ; RET: return from SUB_9E29 Jr vine/platform collision

SUB_9EBF:                                  ; SUB_9EBF: apply vine scroll to platform IX+1 and IX+2 counters
    LD      A, (HL)                        ; A = (HL): speed
    OR      A                              ; OR A
    JR      NZ, LOC_9EC4                   ; JR NZ,LOC_9EC4
    DEC     A                              ; DEC A

LOC_9EC4:                                  ; LOC_9EC4
    PUSH    AF                             ; PUSH AF
    ADD     A, (IX+1)                      ; ADD A,(IX+1)
    LD      (IX+1), A                      ; LD (IX+1),A
    POP     AF                             ; POP AF
    ADD     A, (IX+2)                      ; ADD A,(IX+2)
    LD      (IX+2), A                      ; LD (IX+2),A
    RET                                    ; RET: return from SUB_9EBF vine-scroll counter update

SUB_9ED3:                                  ; SUB_9ED3: snap Junior X to vine X when at vine top/bottom
    LD      A, (IY+1)                      ; A = (IY+1): Jr Y
    ADD     A, $10                         ; ADD A,$10
    CP      (IX+0)                         ; CP (IX+0): vine X
    RET     Z                              ; RET Z
    LD      A, (IX+0)                      ; A = (IX+0)
    ADD     A, $F0                         ; ADD A,$F0: A -= 16
    ADD     A, C                           ; ADD A,C: + speed
    LD      (IY+1), A                      ; LD (IY+1),A: snap Jr Y
    LD      HL, $7084                      ; HL = $7084: ground-movement timer
    LD      (HL), $06                      ; LD (HL),$06: reload 6
    RET                                    ; RET: return from SUB_9EBF
    DB      $00, $64, $65, $65, $66, $00, $4B, $4C
    DB      $4D, $4E, $4F, $00, $64, $65, $66, $00
    DB      $52, $53, $54, $55, $00, $40, $41, $00
    DB      $69, $6A, $6B, $00, $42, $43, $00, $6C
    DB      $6D, $6E, $A7, $8A, $A7, $87, $67, $82
    DB      $58, $5D, $73, $98, $5D, $75, $8C, $67
    DB      $7F, $07, $08, $04, $00, $2C, $1A, $00
    DB      $00, $02, $08, $02, $01, $B1, $1A, $00
    DB      $00, $08, $08, $04, $00, $89, $19, $91
    DB      $19, $FD, $CB, $02, $76, $C8, $DD, $CB
    DB      $02, $56, $20, $12, $FD, $CB, $02, $F6
    DB      $DD, $CB, $02, $D6, $AF, $21, $0A, $00
    DB      $CD, $CD, $1F, $32, $C2, $71, $3A, $C2
    DB      $71, $CD, $D0, $1F, $C8, $DD, $CB, $02
    DB      $96, $FD, $CB, $02, $B6, $C3, $F7, $9F
    DB      $FD, $7E, $07, $FD, $77, $06, $FD, $7E
    DB      $04, $CB, $7F, $C2, $9D, $9F, $CB, $6F
    DB      $20, $14, $CB, $67, $20, $09, $E6, $0F
    DB      $4F, $DD, $7E, $01, $91, $18, $3F, $E6
    DB      $0F, $DD, $86, $01, $18, $38, $CB, $67
    DB      $20, $09, $E6, $0F, $4F, $DD, $7E, $00
    DB      $91, $18, $59, $E6, $0F, $DD, $86, $00
    DB      $18, $52, $CB, $6F, $20, $2E, $E6, $0F
    DB      $4F, $DD, $7E, $01, $FD, $BE, $03, $30
    DB      $08, $81, $FD, $BE, $03, $38, $0F, $18
    DB      $06, $91, $FD, $BE, $03, $30, $07, $FD
    DB      $CB, $02, $F6, $FD, $7E, $03, $FE, $08
    DB      $DA, $F7, $9F, $FE, $F8, $D2, $F7, $9F
    DB      $DD, $77, $01, $C9, $E6, $0F, $4F, $DD
    DB      $7E, $00, $FD, $BE, $03, $30, $08, $81
    DB      $FD, $BE, $03, $38, $0F, $18, $06, $91
    DB      $FD, $BE, $03, $30, $07, $FD, $CB, $02
    DB      $F6, $FD, $7E, $03, $FE, $B7, $30, $04
    DB      $DD, $77, $00, $C9

SUB_9FF7:                                  ; SUB_9FF7: enemy-die handler -- mark slot $C3, play sound, score
    LD      (IX+0), $C3                    ; LD (IX+0),$C3: mark sprite dead
    LD      (IY+0), $03                    ; LD (IY+0),$03: set state to dying
    LD      A, (IY+1)                      ; A = (IY+1): Y
    LD      BC, ($70E8)                    ; BC = ($70E8): sound parameter
    BIT     1, A                           ; BIT 1,A
    RET     NZ                             ; RET NZ: skip if bit 1 set
    LD      A, $0D                         ; A=$0D
    SUB     B                              ; SUB B
    LD      C, A                           ; C = A
    CALL    SOUND_WRITE_A055               ; CALL SOUND_WRITE_A055: add to sprite sound queue
    RET                                    ; RET: return after enqueueing sprite sound

LOC_A011:                                  ; LOC_A011: vine sprite tile update -- select correct grip tile by state
    RES     7, (IY+2)                      ; RES 7,(IY+2)
    LD      A, (IY+1)                      ; A = (IY+1): vine Y
    CP      $04                            ; CP $04
    RET     C                              ; RET C: Y < 4 -- too high
    LD      A, (IY+4)                      ; A = (IY+4): sprite flags
    AND     $30                            ; AND $30: extract tile-select bits 4-5
    SRL     A                              ; SRL A
    SRL     A                              ; SRL A
    SRL     A                              ; SRL A: shift to 0-3
    LD      DE, $A03A                      ; DE = $A03A: grip tile table
    SBC     HL, HL                         ; SBC HL,HL: HL = 0
    LD      L, A                           ; L = A: offset
    ADD     HL, DE                         ; ADD HL,DE: index into table
    LD      A, (IY+1)                      ; A = (IY+1)
    CP      $05                            ; CP $05
    JR      NZ, LOC_A035                   ; JR NZ,LOC_A035
    INC     HL                             ; INC HL: stage 5 uses next tile

LOC_A035:                                  ; LOC_A035
    LD      A, (HL)                        ; A = (HL): tile index
    LD      (IX+2), A                      ; LD (IX+2),A: set sprite tile
    RET                                    ; RET: return from LOC_A035 vine sprite tile update
    DB      $00, $28, $08, $20, $10, $00, $18, $30

SOUND_WRITE_A042:                          ; SOUND_WRITE_A042: reset sprite attribute write pointer to buffer start
    LD      HL, $71C3                      ; HL = $71C3: sprite sound buffer
    LD      ($71D3), HL                    ; LD ($71D3),HL: write pointer
    LD      ($71D5), HL                    ; LD ($71D5),HL: add pointer
    LD      B, $0F                         ; B = $0F: 15 slots

LOC_A04D:                                  ; LOC_A04D: fill with $80 (empty)
    LD      (HL), $80                      ; LD (HL),$80
    INC     HL                             ; INC HL
    DJNZ    LOC_A04D                       ; DJNZ LOC_A04D
    LD      (HL), $FF                      ; LD (HL),$FF: end sentinel
    RET                                    ; RET: return from SOUND_WRITE_A042 sprite buffer init

SOUND_WRITE_A055:                          ; SOUND_WRITE_A055: add sprite sound to queue at ($71D5)
    LD      A, C                           ; A = C: check for $0C (silent)
    CP      $0C                            ; CP $0C
    RET     Z                              ; RET Z: do nothing
    LD      HL, ($71D5)                    ; HL = ($71D5): current write position
    LD      A, (HL)                        ; A = (HL): current slot
    CP      $FF                            ; CP $FF: hit end?
    JR      NZ, LOC_A064                   ; JR NZ,LOC_A064
    LD      HL, $71C3                      ; HL = $71C3: wrap to start

LOC_A064:                                  ; LOC_A064
    LD      (HL), C                        ; LD (HL),C: store sound value
    INC     HL                             ; INC HL
    LD      ($71D5), HL                    ; LD ($71D5),HL: advance pointer
    RET                                    ; RET: return from SOUND_WRITE_A055 sound enqueue

SOUND_WRITE_A06A:                          ; SOUND_WRITE_A06A: read next Jr sprite from sound queue; returns A=slot index
    LD      A, ($7340)                     ; A = ($7340): grip count
    OR      A                              ; OR A
    JR      NZ, LOC_A087                   ; JR NZ,LOC_A087: gripping -- skip
    LD      HL, ($71D3)                    ; HL = ($71D3): read pointer

LOC_A073:                                  ; LOC_A073: scan for non-empty slot
    LD      A, (HL)                        ; A = (HL)
    CP      $80                            ; CP $80: empty?
    RET     Z                              ; RET Z: queue empty
    CP      $FF                            ; CP $FF: end sentinel?
    JR      NZ, LOC_A080                   ; JR NZ,LOC_A080
    LD      HL, $71C3                      ; HL = $71C3: wrap
    JR      LOC_A073                       ; JR LOC_A073

LOC_A080:                                  ; LOC_A080: found entry
    LD      (HL), $80                      ; LD (HL),$80: mark consumed
    INC     HL                             ; INC HL
    LD      ($71D3), HL                    ; LD ($71D3),HL: advance read pointer
    RET                                    ; RET: return from LOC_A080 with consumed slot in A

LOC_A087:                                  ; LOC_A087: return $80 as signal
    XOR     A                              ; XOR A: clear A
    LD      A, $80                         ; LD A,$80: return value $80
    RET                                    ; RET: return
    DB      $C9, $FD, $7E, $01, $FE, $03, $D8, $FD
    DB      $7E, $07, $FE, $02, $30, $04, $3E, $04
    DB      $18, $0A, $FE, $04, $30, $04, $3E, $05
    DB      $18, $02, $3E, $07, $FD, $77, $05, $DD
    DB      $CB, $02, $56, $28, $05, $DD, $CB, $02
    DB      $96, $C9, $DD, $CB, $02, $D6, $C9

SUB_A0BA:                                  ; SUB_A0BA: write lives/status display -- choose P1 or P2 buffer, write to VRAM
    LD      A, ($7288)                     ; A = ($7288): player count
    OR      A                              ; OR A
    LD      HL, $A0F3                      ; HL = $A0F3
    JR      Z, LOC_A0C6                    ; JR Z,LOC_A0C6: 1-player
    LD      HL, $A0F5                      ; HL = $A0F5

LOC_A0C6:                                  ; LOC_A0C6: select tile copy count based on Jr X
    LD      A, ($733D)                     ; LD A,($733D): read Jr X position
    CP      $50                            ; CP $50: compare with $50
    LD      C, $01                         ; LD C,$01: default copy count = 1
    JR      NZ, LOC_A0D7                   ; JR NZ,LOC_A0D7: if X != $50, use 1
    LD      A, ($7288)                     ; LD A,($7288): read player number
    OR      A                              ; OR A: test player
    JR      Z, LOC_A0D7                    ; JR Z,LOC_A0D7: if P1, use 1
    LD      C, $02                         ; LD C,$02: P2 at $50, copy 2 tiles

LOC_A0D7:                                  ; LOC_A0D7: two-row tile blit using BC count
    LD      A, C                           ; LD A,C: A = copy count
    PUSH    AF                             ; PUSH AF: save count
    LD      BC, $0002                      ; LD BC,$0002: 2 bytes per tile row
    PUSH    BC                             ; PUSH BC: save stride
    LD      DE, ($71D7)                    ; LD DE,($71D7): load VRAM dest address
    PUSH    HL                             ; PUSH HL: save source pointer
    PUSH    DE                             ; PUSH DE: save dest
    RST     $08                            ; RST $08: BIOS block copy row 1
    POP     DE                             ; POP DE: restore dest
    LD      HL, $0020                      ; LD HL,$0020: row stride 32
    ADD     HL, DE                         ; ADD HL,DE: advance to row 2
    DB      $EB                            ; DB $EB: EX DE,HL
    POP     HL                             ; POP HL: restore source
    POP     BC                             ; POP BC: restore stride
    POP     AF                             ; POP AF: restore count
    DEC     A                              ; DEC A: decrement count
    JR      Z, LOC_A0F1                    ; JR Z,LOC_A0F1: if done, write row 2
    ADD     HL, BC                         ; ADD HL,BC: advance source by stride

LOC_A0F1:                                  ; LOC_A0F1: write second row
    RST     $08                            ; RST $08: BIOS block copy row 2
    RET                                    ; RET: return from LOC_A0D7
    DB      $0B, $0A, $40, $41, $42, $43

SUB_A0F9:                                  ; SUB_A0F9: sprite attr flush + Jr/enemy hit proximity check
    LD      A, ($7288)                     ; A = ($7288): stage type
    CP      $01                            ; CP $01
    JP      Z, LOC_A159                    ; JP Z,LOC_A159: type 1 -- special case
    LD      HL, $71F1                      ; LD HL,$71F1: read Jr Y from RAM
    LD      E, (HL)                        ; LD E,(HL): E = Jr Y
    DEC     HL                             ; DEC HL: advance to Jr X high
    DEC     HL                             ; DEC HL: advance to Jr X low
    LD      D, (HL)                        ; LD D,(HL): D = Jr X
    OR      A                              ; OR A: test mode flag
    JR      Z, LOC_A14A                    ; JR Z,LOC_A14A: if mode 0, go to left boundary
    CP      $02                            ; CP $02: mode 2?
    JR      Z, LOC_A119                    ; JR Z,LOC_A119: if mode 2, go to right boundary
    LD      A, $50                         ; LD A,$50: left boundary $50
    CP      D                              ; CP D: compare with Jr X
    RET     C                              ; RET C: if Jr X > $50, return
    LD      A, $18                         ; LD A,$18: bottom boundary $18
    CP      E                              ; CP E: compare with Jr Y
    RET     C                              ; RET C: if Jr Y > $18, return
    JR      LOC_A169                       ; JR LOC_A169: within bounds, trigger capture

LOC_A119:                                  ; LOC_A119: Jr at right side boundary check
    LD      A, D                           ; LD A,D: A = Jr X
    CP      $68                            ; CP $68: compare with X $68
    JR      NC, LOC_A12B                   ; JR NC,LOC_A12B: if at or past $68, check further
    LD      A, $27                         ; LD A,$27: Y boundary $27
    CP      E                              ; CP E: compare with Jr Y
    RET     C                              ; RET C: if Jr Y > $27, return
    LD      (HL), $68                      ; LD (HL),$68: clamp Jr X to $68
    XOR     A                              ; XOR A: A = 0
    LD      HL, $93D5                      ; LD HL,$93D5: animation table pointer
    JP      LOC_9260                       ; JP LOC_9260: dispatch to animation

LOC_A12B:                                  ; LOC_A12B: Jr right-side far boundary
    LD      A, ($708B)                     ; LD A,($708B): read Kong phase
    DEC     A                              ; DEC A: decrement phase
    RET     NZ                             ; RET NZ: if not phase 1, return
    LD      A, $78                         ; LD A,$78: X boundary $78
    CP      D                              ; CP D: compare with Jr X
    RET     C                              ; RET C: if Jr X > $78, return
    LD      A, $06                         ; LD A,$06: Y boundary $06
    CP      E                              ; CP E: compare with Jr Y
    RET     C                              ; RET C: if Jr Y > $06, return
    JR      LOC_A169                       ; JR LOC_A169: trigger capture

LOC_A13A:                                  ; LOC_A13A: Jr left-side boundary check
    LD      A, $27                         ; LD A,$27: Y boundary $27
    CP      E                              ; CP E: compare with Jr Y
    RET     C                              ; RET C: if Jr Y > $27, return
    LD      A, $02                         ; LD A,$02: boundary value $02
    LD      ($728E), A                  ; RAM $728E
    LD      SP, ($7059)                 ; RAM $7059
    JP      LOC_A172                       ; JP LOC_A172: out of bounds -- trigger life-lost path

LOC_A14A:                                  ; LOC_A14A: type 0 -- check Jr proximity to Kong
    LD      A, D                           ; A = D: X
    CP      $40                            ; CP $40
    JR      C, LOC_A13A                    ; JR C,LOC_A13A: X < $40 -- check close
    LD      A, $58                         ; A=$58
    CP      D                              ; CP D
    RET     C                              ; RET C: X > $58
    LD      A, $13                         ; A=$13
    CP      E                              ; CP E
    RET     C                              ; RET C
    JR      LOC_A169                       ; JR LOC_A169

LOC_A159:                                  ; LOC_A159: type 1 -- stage-clear check at tile $7343
    LD      A, ($7343)                     ; A = ($7343): stage-clear counter
    CP      $06                            ; CP $06
    RET     NZ                             ; RET NZ: not done
    LD      BC, $0002                      ; BC=$0002
    LD      DE, $184F                      ; DE=$184F: VRAM position
    LD      HL, $A170                      ; HL=$A170: 2-byte data
    RST     $08                            ; RST $08: write stage-clear marker to VRAM

LOC_A169:                                  ; LOC_A169: proximity hit -- set flag $728E=1
    POP     HL                             ; POP HL: unwind from nested call
    LD      A, $01                         ; LD A,$01
    LD      ($728E), A                     ; LD ($728E),A: set collision/proximity flag
    RET                                    ; RET: return from LOC_A169 proximity flag set ($728E=1)
    DB      $8F, $90

LOC_A172:                                  ; LOC_A172: game-over / life-lost handler -- set $728E=2, play death, wait
    LD      A, $02                         ; LD A,$02
    LD      ($728E), A                     ; LD ($728E),A: set game-over flag
    CALL    SUB_A679                       ; CALL SUB_A679: reset sound engine
    CALL    SOUND_WRITE_A6E8               ; CALL SOUND_WRITE_A6E8: play death sound, wait for completion
    RET                                    ; RET: return from LOC_A172 after death sound busy-wait

LOC_A17E:                                  ; LOC_A17E: level complete -- score tally + prepare next stage
    LD      A, ($7094)                     ; A = ($7094): time remaining
    CALL    SUB_A48C                       ; CALL SUB_A48C: add time bonus to score
    CALL    SUB_A530                       ; CALL SUB_A530: turn off display
    CALL    DELAY_LOOP_84AD                ; CALL DELAY_LOOP_84AD: flush sprite table
    CALL    SUB_84C0                       ; CALL SUB_84C0: write $D0 sentinel
    CALL    SUB_A514                       ; CALL SUB_A514: enable NMI
    CALL    DELAY_LOOP_950B                ; CALL DELAY_LOOP_950B: update sprite positions
    CALL    SUB_A699                       ; CALL SUB_A699: play stage-complete music
    CALL    SUB_A530                       ; CALL SUB_A530
    CALL    DELAY_LOOP_84AD                ; CALL DELAY_LOOP_84AD
    CALL    SUB_84C0                       ; CALL SUB_84C0
    CALL    SUB_A4FD                       ; CALL SUB_A4FD: IX = current player
    INC     (IX+2)                         ; INC (IX+2): stage++
    DEC     A                              ; DEC A: lives check
    LD      HL, $71D9                      ; HL = $71D9: score buffer
    JR      Z, LOC_A1AC                    ; JR Z,LOC_A1AC: P1
    INC     HL                             ; INC HL: P2

LOC_A1AC:                                  ; LOC_A1AC: increment score BCD
    LD      A, (HL)                        ; A = (HL)
    INC     A                              ; INC A
    DAA                                    ; DAA: BCD increment
    LD      (HL), A                        ; LD (HL),A
    JP      LOC_8127                       ; JP LOC_8127: replay level with new stage

LOC_A1B3:                                  ; LOC_A1B3: game over / life lost -- clear $71DB, 10-wait, check continues
    CALL    SUB_8A72                       ; CALL SUB_8A72
    CALL    SUB_A679                       ; CALL SUB_A679
    LD      A, $01                         ; LD A,$01
    LD      ($71DB), A                     ; LD ($71DB),A: re-enable 2-player swap
    LD      A, $0A                         ; LD A,$0A
    LD      ($7061), A                     ; LD ($7061),A: swap timer
    LD      B, $0A                         ; B=$0A C=$0C
    LD      C, $0C                         ; LD C,$0C
    CALL    SUB_8190                       ; CALL SUB_8190: wait for direction input
    PUSH    AF                             ; PUSH AF: save direction result
    CALL    SUB_A541                       ; CALL SUB_A541
    CALL    SUB_A679                       ; CALL SUB_A679
    CALL    SUB_A530                       ; CALL SUB_A530
    POP     AF                             ; POP AF
    CP      $0A                            ; CP $0A
    JP      Z, LOC_8124                    ; JP Z,LOC_8124: direction $0A = continue same player
    JP      LOC_8121                       ; JP LOC_8121: other direction = restart game

SUB_A1DD:                                  ; SUB_A1DD: enemy AI tick -- snapjaws + birds proximity check to Junior
    LD      A, ($727A)                     ; A = ($727A): player entity flag
    OR      A                              ; OR A
    RET     NZ                             ; RET NZ: player entity busy
    LD      IY, $7202                      ; IY = $7202: sprite buffer
    LD      IX, $730B                      ; IX = $730B: vine-grip table
    LD      B, $0C                         ; B = $0C: 12 slots

LOC_A1EC:                                  ; LOC_A1EC: per-slot loop
    PUSH    BC                             ; PUSH BC
    INC     B                              ; INC B: slot number
    LD      A, B                           ; LD A,B
    LD      ($70E9), A                     ; LD ($70E9),A: store slot
    LD      A, ($733B)                     ; A = ($733B): Jr Y
    LD      B, (IX+0)                      ; B = (IX+0): slot Y
    LD      H, $0B                         ; H=$0B
    CALL    SUB_A2C3                       ; CALL SUB_A2C3: abs-diff compare Y
    JR      NC, LOC_A210                   ; JR NC,LOC_A210: Y miss
    LD      D, A                           ; D = A: save Y diff
    LD      A, ($733C)                     ; A = ($733C): Jr X
    LD      B, (IX+1)                      ; B = (IX+1): slot X
    CALL    SUB_A2C3                       ; CALL SUB_A2C3: abs-diff compare X
    JR      NC, LOC_A210                   ; JR NC,LOC_A210: X miss
    ADD     A, D                           ; ADD A,D: sum of diffs
    CP      $20                            ; CP $20: within $20?
    JR      C, LOC_A21E                    ; JR C,LOC_A21E: close enough -- kill

LOC_A210:                                  ; LOC_A210: advance IX IY
    LD      DE, $0004                      ; DE = $0004
    ADD     IX, DE                         ; ADD IX,DE
    LD      DE, $000A                      ; DE = $000A
    ADD     IY, DE                         ; ADD IY,DE
    POP     BC                             ; POP BC
    DJNZ    LOC_A1EC                       ; DJNZ LOC_A1EC
    RET                                    ; RET: return from SUB_A1DD enemy AI tick (all slots done)

LOC_A21E:                                  ; LOC_A21E: enemy hits Junior
    LD      A, (IX+2)                      ; A = (IX+2): enemy type
    PUSH    IY                             ; PUSH IY
    PUSH    AF                             ; PUSH AF
    PUSH    IX                             ; PUSH IX
    LD      A, ($7342)                     ; A = ($7342): score flag
    ADD     A, $04                         ; ADD A,$04
    DAA                                    ; DAA: BCD add
    LD      ($7342), A                     ; LD ($7342),A
    CALL    SUB_A48C                       ; CALL SUB_A48C: add to score
    LD      HL, $003C                      ; HL=$003C: 60 ticks
    XOR     A                              ; XOR A
    CALL    REQUEST_SIGNAL                 ; CALL REQUEST_SIGNAL: allocate death timer
    LD      ($71DC), A                     ; LD ($71DC),A: death-blink signal
    LD      A, $FF                         ; LD A,$FF
    LD      ($7346), A                     ; LD ($7346),A
    CALL    SUB_A6CA                       ; CALL SUB_A6CA: play hit sound
    POP     IX                             ; POP IX: restore IX (player entity) after score add

LOC_A246:                                  ; LOC_A246: wait for score update signal
    LD      A, ($71DC)                     ; LD A,($71DC): read signal slot
    LD      (IX+2), $40                    ; LD (IX+2),$40: set sprite attribute $40 (hide)
    PUSH    IX                             ; PUSH IX: save IX
    CALL    TEST_SIGNAL                    ; CALL TEST_SIGNAL: test signal
    POP     IX                             ; POP IX: restore IX
    LD      (IX+2), $44                    ; LD (IX+2),$44: set sprite attribute $44
    JR      Z, LOC_A246                    ; JR Z,LOC_A246: loop until signal fires
    POP     AF                             ; POP AF: restore AF after signal wait
    LD      (IX+2), A                      ; LD (IX+2),A: restore original sprite attribute
    PUSH    IX                             ; PUSH IX: save IX for player check
    LD      A, ($728A)                     ; LD A,($728A): read player count flag
    AND     $0F                            ; AND $0F: mask low nibble
    CP      $01                            ; CP $01: 1-player game?
    JR      NC, LOC_A26E                   ; JR NC,LOC_A26E: if 2-player, alternate bonus
    CALL    LOC_A6C6                       ; CALL LOC_A6C6: 1-player bonus sound
    JR      LOC_A271                       ; JR LOC_A271: skip 2-player path

LOC_A26E:                                  ; LOC_A26E: 2-player bonus sound
    CALL    SUB_A681                       ; CALL SUB_A681: 2-player bonus sound/effect

LOC_A271:                                  ; LOC_A271: restore IY and IX, loop
    POP     IX                             ; POP IX: restore IX
    POP     IY                             ; POP IY: restore IY
    CALL    SUB_9FF7                       ; CALL SUB_9FF7: score display update
    JP      LOC_A210                       ; JP LOC_A210: loop back to score sequence

SUB_A27B:                                  ; SUB_A27B: initialize score digit table
    LD      HL, $A28B                      ; LD HL,$A28B: score digit source data
    LD      DE, $71DF                      ; LD DE,$71DF: score digit RAM buffer
    LD      BC, $000C                      ; LD BC,$000C: 12 bytes
    LDIR                                   ; LDIR: copy score digit data
    XOR     A                              ; XOR A: A = 0
    LD      ($7343), A                     ; LD ($7343),A: clear score advance flag
    RET                                    ; RET: return from SUB_A27B
    DB      $C8, $98, $A8, $98, $98, $98, $68, $98
    DB      $58, $98, $38, $98

SUB_A297:                                  ; SUB_A297: enemy-spawn routine -- find empty slot, draw 2x2 enemy tile
    LD      ($71DD), A                     ; LD ($71DD),A: save tile index
    LD      A, ($7288)                     ; A = ($7288)
    CP      $01                            ; CP $01: only run for stage type 1
    RET     NZ                             ; RET NZ
    LD      D, $06                         ; D=$06
    LD      IX, $71DF                      ; IX = $71DF: enemy sprite table

LOC_A2A6:                                  ; LOC_A2A6: scan 6 enemy slots
    LD      A, (IX+0)                      ; A = (IX+0): slot X
    PUSH    BC                             ; PUSH BC
    LD      H, $06                         ; H=$06
    CALL    SUB_A2C3                       ; CALL SUB_A2C3: abs-diff Jr X vs slot X
    JR      NC, LOC_A2BA                   ; JR NC,LOC_A2BA: miss
    LD      B, C                           ; B = C
    LD      A, (IX+1)                      ; A = (IX+1): slot Y
    CALL    SUB_A2C3                       ; CALL SUB_A2C3: abs-diff Jr Y vs slot Y
    JR      C, LOC_A2CB                    ; JR C,LOC_A2CB: both match -- hit!

LOC_A2BA:                                  ; LOC_A2BA: advance to next slot
    POP     BC                             ; POP BC
    INC     IX                             ; INC IX: IX += 2
    INC     IX                             ; INC IX
    DEC     D                              ; DEC D
    JR      NZ, LOC_A2A6                   ; JR NZ,LOC_A2A6
    RET                                    ; RET: return from enemy proximity scan loop

SUB_A2C3:                                  ; SUB_A2C3: abs-difference compare |A-B| < H; carry set if within range
    LD      E, A                           ; E = A
    SUB     B                              ; SUB B: A - B
    JR      NC, LOC_A2C9                   ; JR NC,LOC_A2C9
    LD      A, B                           ; A = B
    SUB     E                              ; SUB E: B - A (always >= 0)

LOC_A2C9:                                  ; LOC_A2C9: CP H; carry if abs-diff < H
    CP      H                              ; CP H
    RET                                    ; RET: return from SUB_A2C3 with carry set if within range

LOC_A2CB:                                  ; LOC_A2CB: barrel Y update from player position
    LD      A, D                           ; LD A,D: A = barrel Y from D
    LD      ($71DE), A                     ; LD ($71DE),A: store barrel Y in RAM
    LD      A, ($71DD)                     ; LD A,($71DD): read barrel X
    BIT     7, A                           ; BIT 7,A: test high-bit (falling flag)
    JR      NZ, LOC_A308                   ; JR NZ,LOC_A308: if falling, use fall path
    POP     BC                             ; POP BC: restore BC
    LD      A, (IX+1)                      ; LD A,(IX+1): read sprite Y from sprite table
    CP      $98                            ; CP $98: compare with Y boundary $98
    JR      NC, LOC_A2E4                   ; JR NC,LOC_A2E4: if at or below $98, advance Y
    LD      A, ($71DD)                     ; LD A,($71DD): reload barrel X
    ADD     A, C                           ; ADD A,C: add C offset
    AND     $FC                            ; AND $FC: align to 4-pixel boundary

LOC_A2E4:                                  ; LOC_A2E4: barrel X boundary check
    CP      $9C                            ; CP $9C: compare with X boundary $9C
    RET     NC                             ; RET NC: if past boundary, return
    ADD     A, $04                         ; ADD A,$04: X + 4
    PUSH    AF                             ; PUSH AF: save new barrel X
    CALL    DELAY_LOOP_A37B                ; CALL DELAY_LOOP_A37B: draw barrel sprite tiles
    LD      HL, $A367                      ; LD HL,$A367: barrel tile data pointer
    CALL    SUB_A342                       ; CALL SUB_A342: draw barrel sprite row
    POP     AF                             ; POP AF: restore barrel X
    LD      (IX+1), A                      ; LD (IX+1),A: update sprite X in table
    CALL    DELAY_LOOP_A37B                ; CALL DELAY_LOOP_A37B: draw again for next frame
    LD      HL, $A36B                      ; LD HL,$A36B: second barrel tile data
    BIT     2, (IX+1)                      ; BIT 2,(IX+1): test sprite orientation bit
    JR      NZ, SUB_A342                   ; JR NZ,SUB_A342: if set, draw orientation B
    LD      HL, $A36F                      ; LD HL,$A36F: orientation A tile data
    JR      SUB_A342                       ; JR SUB_A342: draw barrel tile row

LOC_A308:                                  ; LOC_A308: barrel falling Y update
    CALL    DELAY_LOOP_A37B                ; CALL DELAY_LOOP_A37B: draw barrel tile row
    LD      HL, $A367                      ; LD HL,$A367: tile data
    CALL    SUB_A342                       ; CALL SUB_A342: draw tile row
    POP     BC                             ; POP BC: restore BC
    LD      A, ($71DD)                     ; LD A,($71DD): read barrel X
    AND     $0F                            ; AND $0F: mask low nibble
    LD      B, A                           ; LD B,A: B = X nibble
    LD      A, C                           ; LD A,C: A = C parameter
    SUB     B                              ; SUB B: A = C - X nibble
    SUB     $04                            ; SUB $04: subtract 4
    CP      $44                            ; CP $44: compare with boundary $44
    JR      C, LOC_A39E                    ; JR C,LOC_A39E: if below $44, barrel lands
    JR      Z, LOC_A39E                    ; JR Z,LOC_A39E: if equal $44, barrel lands
    AND     $FC                            ; AND $FC: align
    CP      $48                            ; CP $48: compare with $48
    JR      NC, LOC_A32A                   ; JR NC,LOC_A32A: if >= $48, barrel still falling
    LD      A, $44                         ; LD A,$44: clamp to $44

LOC_A32A:                                  ; LOC_A32A: update barrel X and redraw
    LD      (IX+1), A                      ; LD (IX+1),A: store new barrel X
    CALL    DELAY_LOOP_A37B                ; CALL DELAY_LOOP_A37B: draw barrel
    LD      HL, $A36B                      ; LD HL,$A36B: tile data B
    BIT     2, (IX+1)                      ; BIT 2,(IX+1): test orientation
    JR      Z, SUB_A342                    ; JR Z,SUB_A342: if orientation A, draw A
    LD      HL, $A36F                      ; LD HL,$A36F: tile data C
    DB      $EB                            ; DB $EB: EX DE,HL
    LD      BC, $0020                      ; LD BC,$0020: 32 bytes
    ADD     HL, BC                         ; ADD HL,BC: advance tile pointer
    DB      $EB                            ; DB $EB: EX DE,HL

SUB_A342:                                  ; SUB_A342: draw barrel sprite row
    LD      A, ($71DD)                     ; LD A,($71DD): read barrel X
    LD      B, $02                         ; LD B,$02: 2 tile rows
    BIT     2, (IX+1)                      ; BIT 2,(IX+1): test orientation
    JR      NZ, LOC_A34F                   ; JR NZ,LOC_A34F: if orientation B, draw 2 rows
    LD      B, $02                         ; LD B,$02: 2 rows (same for A)

LOC_A34F:                                  ; LOC_A34F: draw B rows of barrel tiles
    PUSH    BC                             ; PUSH BC: save row count
    PUSH    HL                             ; PUSH HL: save tile data pointer
    PUSH    DE                             ; PUSH DE: save dest
    PUSH    IX                             ; PUSH IX: save IX
    LD      BC, $0002                      ; LD BC,$0002: 2 bytes per row
    RST     $08                            ; RST $08: BIOS block copy
    POP     IX                             ; POP IX: restore IX
    POP     HL                             ; POP HL: restore tile data
    LD      DE, $0020                      ; LD DE,$0020: row stride 32
    ADD     HL, DE                         ; ADD HL,DE: advance tile data to next row
    DB      $EB                            ; DB $EB: EX DE,HL
    POP     HL                             ; POP HL: restore HL as dest
    INC     HL                             ; INC HL: advance dest
    INC     HL                             ; INC HL: advance dest by 2
    POP     BC                             ; POP BC: restore row count
    DJNZ    LOC_A34F                       ; DJNZ LOC_A34F: loop for B rows
    RET                                    ; RET: return from SUB_A342
    DB      $40, $41, $40, $41, $47, $48, $49, $4A ; "@A@AGHIJ"
    DB      $3E, $3F, $40, $41, $40, $41, $3E, $3F ; ">?@A@A>?"
    DB      $57, $58, $40, $41          ; "WX@A"

DELAY_LOOP_A37B:                           ; DELAY_LOOP_A37B: compute VRAM address HL from IX sprite position
    LD      B, $00                         ; B=$00
    LD      HL, $1800                      ; HL=$1800: VRAM base
    LD      C, (IX+0)                      ; C = (IX+0): sprite X
    CALL    SUB_A396                       ; CALL SUB_A396: X to VRAM column
    ADD     HL, BC                         ; ADD HL,BC: add column
    LD      C, (IX+1)                      ; C = (IX+1): sprite Y
    CALL    SUB_A396                       ; CALL SUB_A396: Y to VRAM row
    LD      B, C                           ; B = C: row into B
    LD      DE, $0020                      ; DE = $0020: row stride

LOC_A391:                                  ; LOC_A391: add B rows to HL
    ADD     HL, DE                         ; ADD HL,DE
    DJNZ    LOC_A391                       ; DJNZ LOC_A391
    DB      $EB                            ; DB $EB: EX DE,HL (result in DE)
    RET                                    ; RET: return from LOC_A391 with result in DE

SUB_A396:                                  ; SUB_A396: tile coord to VRAM index (C = C>>3 - 1)
    SRL     C                              ; SRL C
    SRL     C                              ; SRL C
    SRL     C                              ; SRL C: divide by 8
    DEC     C                              ; DEC C
    RET                                    ; RET: return from SUB_A396 (C = C/8 - 1)

LOC_A39E:                                  ; LOC_A39E: barrel landing sequence
    LD      (IX+1), $C3                    ; LD (IX+1),$C3: set barrel sprite X to $C3 (landed)
    CALL    SUB_A3B8                       ; CALL SUB_A3B8: draw barrel landing sprite
    CALL    SOUND_WRITE_A3D2               ; CALL SOUND_WRITE_A3D2: play barrel land sound
    CALL    SOUND_WRITE_A41D               ; CALL SOUND_WRITE_A41D: play barrel bounce sound
    LD      HL, $7343                      ; LD HL,$7343: Kong score flag
    INC     (HL)                           ; INC (HL): increment score flag
    LD      A, $02                         ; LD A,$02: score increment 2
    CALL    SUB_A48C                       ; CALL SUB_A48C: update Kong score display
    CALL    SUB_A6DD                       ; CALL SUB_A6DD: trigger bonus event
    RET                                    ; RET: return from barrel land handler

SUB_A3B8:                                  ; SUB_A3B8: draw barrel landing/explosion sprite
    LD      IY, $A3C6                      ; LD IY,$A3C6: barrel explosion tile table
    CALL    SUB_A479                       ; CALL SUB_A479: load tile pointer from table
    DB      $EB                            ; DB $EB: EX DE,HL
    LD      HL, $A377                      ; LD HL,$A377: barrel VRAM address table
    JP      SUB_A342                       ; JP SUB_A342: draw barrel sprite row
    DB      $E6, $18, $EA, $18, $EC, $18, $F2, $18
    DB      $F4, $18, $F8, $18

SOUND_WRITE_A3D2:                          ; SOUND_WRITE_A3D2: draw barrel flash tiles in sequence
    LD      IY, $A3EB                      ; LD IY,$A3EB: barrel flash tile table
    CALL    SUB_A479                       ; CALL SUB_A479: load tile pointer

LOC_A3D9:                                  ; LOC_A3D9: draw tile list until $FF
    LD      A, (HL)                        ; LD A,(HL): read tile byte
    CP      $FF                            ; CP $FF: check end marker
    RET     Z                              ; RET Z: return at end
    PUSH    HL                             ; PUSH HL: save source
    LD      HL, $1800                      ; LD HL,$1800: VRAM name table base
    LD      L, A                           ; LD L,A: L = tile number
    LD      DE, $0001                      ; LD DE,$0001: 1 byte to write
    XOR     A                              ; XOR A: fill byte
    RST     $18                            ; RST $18: BIOS write tile to VRAM
    POP     HL                             ; POP HL: restore source
    INC     HL                             ; INC HL: advance to next tile
    JR      LOC_A3D9                       ; JR LOC_A3D9: loop
    DB      $F7, $A3, $01, $A4, $06, $A4, $0A, $A4
    DB      $0E, $A4, $13, $A4, $C6, $C7, $A7, $A8
    DB      $89, $8A, $6B, $6C, $6D, $FF, $CA, $CB
    DB      $AC, $8D, $FF, $CC, $CD, $AE, $FF, $D2
    DB      $D3, $B1, $FF, $D4, $D5, $B3, $92, $FF
    DB      $D8, $D9, $B7, $B8, $95, $96, $72, $73
    DB      $74, $FF

SOUND_WRITE_A41D:                          ; SOUND_WRITE_A41D: draw barrel bounce sprite sequence
    LD      IY, $A43D                      ; LD IY,$A43D: barrel bounce tile table
    CALL    SUB_A479                       ; CALL SUB_A479: load tile pointer
    INC     HL                             ; INC HL: advance to D byte
    LD      D, (HL)                        ; LD D,(HL): read D (row advance)
    LD      BC, $0003                      ; LD BC,$0003: 3 bytes per entry
    INC     HL                             ; INC HL: advance to first entry

LOC_A42A:                                  ; LOC_A42A: draw bounce tile sequence loop
    PUSH    HL                             ; PUSH HL: save source
    PUSH    DE                             ; PUSH DE: save D byte
    PUSH    BC                             ; PUSH BC: save stride
    RST     $08                            ; RST $08: BIOS block copy
    POP     BC                             ; POP BC: restore stride
    POP     HL                             ; POP HL: restore D as HL
    LD      DE, $0020                      ; LD DE,$0020: row stride 32
    ADD     HL, DE                         ; ADD HL,DE: advance VRAM row
    DB      $EB                            ; DB $EB: EX DE,HL
    POP     HL                             ; POP HL: restore source
    ADD     HL, BC                         ; ADD HL,BC: advance source by stride
    LD      A, (HL)                        ; LD A,(HL): read next tile
    CP      $FF                            ; CP $FF: end marker?
    RET     Z                              ; RET Z: return at end
    JR      LOC_A42A                       ; JR LOC_A42A: loop
    DB      $49, $A4, $55, $A4, $5B, $A4, $61, $A4
    DB      $67, $A4, $6D, $A4, $0D, $18, $9B, $00
    DB      $6E, $87, $88, $89, $8D, $8E, $11, $FF
    DB      $6D, $18, $00, $93, $94, $FF, $8D, $18
    DB      $00, $97, $98, $FF, $90, $18, $99, $9A
    DB      $00, $FF, $70, $18, $95, $96, $00, $FF
    DB      $10, $18, $6F, $00, $9C, $8A, $8B, $8C
    DB      $12, $91, $92, $FF

SUB_A479:                                  ; SUB_A479: resolve tile pointer from IY table by barrel state
    LD      A, ($71DE)                     ; LD A,($71DE): read barrel Y state
    DEC     A                              ; DEC A: A -= 1
    LD      D, $00                         ; LD D,$00: D = 0
    LD      E, A                           ; LD E,A: E = index
    SLA     E                              ; SLA E: E *= 2
    ADD     IY, DE                         ; ADD IY,DE: IY = table entry for this state
    LD      H, (IY+1)                      ; LD H,(IY+1): H = tile pointer high
    LD      L, (IY+0)                      ; LD L,(IY+0): L = tile pointer low
    LD      E, (HL)                        ; LD E,(HL): E = first tile byte
    RET                                    ; RET: return with HL = tile pointer

SUB_A48C:                                  ; SUB_A48C: update score display for Kong capture
    LD      ($71ED), A                     ; LD ($71ED),A: store score increment
    LD      A, ($7286)                     ; LD A,($7286): read display page flag
    DEC     A                              ; DEC A: A -= 1
    PUSH    AF                             ; PUSH AF: save page flag
    LD      DE, $72A5                      ; LD DE,$72A5: P2 score RAM
    JR      NZ, LOC_A49C                   ; JR NZ,LOC_A49C: if not P1, use P2 RAM
    LD      DE, $7298                      ; LD DE,$7298: P1 score RAM

LOC_A49C:                                  ; LOC_A49C: compute score digits
    PUSH    DE                             ; PUSH DE: save score RAM pointer
    LD      B, $02                         ; LD B,$02: 2 digit pairs
    LD      HL, $71EB                      ; LD HL,$71EB: score digit buffer
    PUSH    HL                             ; PUSH HL: save digit buffer
    CALL    DELAY_LOOP_A4D7                ; CALL DELAY_LOOP_A4D7: compute BCD score digits
    LD      HL, $71EC                      ; LD HL,$71EC: second digit buffer
    CALL    SUB_A4EF                       ; CALL SUB_A4EF: compute second digit pair
    POP     HL                             ; POP HL: restore digit buffer
    POP     DE                             ; POP DE: restore score RAM
    PUSH    DE                             ; PUSH DE: save again
    LD      A, $30                         ; LD A,$30: add $30 to digits for display
    LD      B, $02                         ; LD B,$02: 2 digits
    CALL    DELAY_LOOP_A4E3                ; CALL DELAY_LOOP_A4E3: write digits to VRAM
    CALL    SUB_A658                       ; CALL SUB_A658: draw score tile to VRAM
    POP     DE                             ; POP DE: restore score RAM
    INC     DE                             ; INC DE: advance past first score byte
    POP     AF                             ; POP AF: restore player flag
    OR      A                              ; OR A: test player
    LD      BC, $7345                      ; LD BC,$7345: P2 lives display pointer
    LD      HL, $729E                      ; LD HL,$729E: P2 score bonus pointer
    JR      NZ, LOC_A4C9                   ; JR NZ,LOC_A4C9: if P2, use P2 pointers
    DEC     BC                             ; DEC BC: BC = $7344 (P1 lives display)
    LD      HL, $7291                      ; LD HL,$7291: P1 score bonus pointer

LOC_A4C9:                                  ; LOC_A4C9: check bonus life threshold
    LD      A, (BC)                        ; LD A,(BC): read lives display value
    OR      A                              ; OR A: test
    RET     NZ                             ; RET NZ: if already awarded, return
    LD      A, (DE)                        ; LD A,(DE): read current score byte
    CP      $31                            ; CP $31: compare with bonus threshold $31
    RET     C                              ; RET C: if below threshold, return
    LD      A, $01                         ; LD A,$01: bonus life awarded flag
    LD      (BC), A                        ; LD (BC),A: store bonus life flag
    INC     (HL)                           ; INC (HL): increment lives count
    JP      SUB_A636                       ; JP SUB_A636: jump to score display update

DELAY_LOOP_A4D7:                           ; DELAY_LOOP_A4D7: RLD 2 BCD digits from (DE) into (HL) (unpacks packed BCD)
    LD      A, (DE)                        ; A = (DE)
    RLD                                    ; RLD: rotate left digit (HL) through A
    INC     DE                             ; INC DE
    LD      A, (DE)                        ; A = (DE)
    RLD                                    ; RLD
    INC     DE                             ; INC DE
    INC     HL                             ; INC HL
    DJNZ    DELAY_LOOP_A4D7                ; DJNZ DELAY_LOOP_A4D7
    RET                                    ; RET: return from DELAY_LOOP_A4D7 BCD unpack loop

DELAY_LOOP_A4E3:                           ; DELAY_LOOP_A4E3: RLD-and-store: write 2 unpacked BCD bytes to (DE)
    RLD                                    ; RLD: shift digit from (HL) to A high nibble
    LD      (DE), A                        ; LD (DE),A
    INC     DE                             ; INC DE
    RLD                                    ; RLD
    LD      (DE), A                        ; LD (DE),A
    INC     DE                             ; INC DE
    INC     HL                             ; INC HL
    DJNZ    DELAY_LOOP_A4E3                ; DJNZ DELAY_LOOP_A4E3
    RET                                    ; RET: return from DELAY_LOOP_A4E3 2-digit BCD unpack

SUB_A4EF:                                  ; SUB_A4EF: BCD add $71ED to (HL)/(HL-1) (2-byte BCD add with carry)
    OR      A                              ; OR A: clear carry
    LD      A, ($71ED)                     ; A = ($71ED): increment
    ADD     A, (HL)                        ; ADD A,(HL): add low byte
    DAA                                    ; DAA
    LD      (HL), A                        ; LD (HL),A
    DEC     HL                             ; DEC HL
    LD      A, $00                         ; A=$00
    ADC     A, (HL)                        ; ADC A,(HL): add carry to high byte
    DAA                                    ; DAA
    LD      (HL), A                        ; LD (HL),A
    RET                                    ; RET: return from SUB_A4EF BCD score byte add

SUB_A4FD:                                  ; SUB_A4FD: select player structs IX=P1 IY=P2 (or swap if $7286=2)
    LD      IX, $7291                      ; IX = $7291: P1 entity struct
    LD      IY, $729E                      ; IY = $729E: P2 entity struct
    LD      A, ($7286)                     ; A = ($7286): current player
    CP      $01                            ; CP $01
    RET     Z                              ; RET Z: player 1 -- IX/IY already correct
    LD      IX, $729E                      ; IX = $729E: swap for player 2
    LD      IY, $7291                      ; IY = $7291
    RET                                    ; RET: return from SUB_A4FD with IX=P2 IY=P1

SUB_A514:                                  ; SUB_A514: enable NMI + init PLAY_SONGS
    XOR     A                              ; XOR A
    LD      ($7054), A                     ; LD ($7054),A: clear NMI gate
    LD      A, $01                         ; LD A,$01
    LD      ($73C6), A                     ; LD ($73C6),A
    LD      ($73C7), A                     ; LD ($73C7),A
    LD      A, $0A                         ; A=$0A
    LD      HL, $72AB                      ; HL=$72AB
    CALL    INIT_WRITER                    ; CALL INIT_WRITER: init WRITER stream to $72AB
    LD      A, ($73C4)                     ; A = ($73C4)
    SET     5, A                           ; SET 5,A: set bit 5
    LD      C, A                           ; C = A
    JR      LOC_A53C                       ; JR LOC_A53C

SUB_A530:                                  ; SUB_A530: turn display off (RES bit 5)
    XOR     A                              ; XOR A
    LD      ($73C6), A                     ; LD ($73C6),A
    LD      ($73C7), A                     ; LD ($73C7),A
    LD      A, ($73C4)                     ; A = ($73C4)
    RES     5, A                           ; RES 5,A: clear display-on bit

LOC_A53C:                                  ; LOC_A53C: LD C,A; B=1; RST $28 = PLAY_SONGS
    LD      C, A                           ; C = A
    LD      B, $01                         ; B=$01
    RST     $28                            ; RST $28: PLAY_SONGS -- send display register
    RET                                    ; RET: return from LOC_A53C VDP register write

SUB_A541:                                  ; SUB_A541: VDP display config via PLAY_SONGS (clears bit 6)
    LD      A, ($73C4)                     ; A = ($73C4)
    RES     6, A                           ; RES 6,A
    LD      C, A                           ; C = A
    JR      LOC_A53C                       ; JR LOC_A53C

SUB_A549:                                  ; SUB_A549: set score color attribute with bit 6
    LD      A, ($73C4)                     ; LD A,($73C4): read color attribute byte
    SET     6, A                           ; SET 6,A: set bit 6 for bright color
    LD      C, A                           ; LD C,A: C = color attribute
    JR      LOC_A53C                       ; JR LOC_A53C

SUB_A551:                                  ; SUB_A551: output sound register pair
    LD      C, $82                         ; LD C,$82: sound register address $82
    LD      B, $01                         ; LD B,$01: sound register value 1
    RST     $28                            ; RST $28: BIOS sound write
    RET                                    ; RET: return
    DB      $18, $11, $1C, $11, $14, $16, $11, $14
    DB      $33, $1C, $11, $0C, $16, $11, $14, $33
    DB      $1C, $11, $0C, $20, $1B, $1E, $1B, $20
    DB      $22, $1B, $1E, $33, $20, $1D, $20, $22
    DB      $1B, $28, $33, $20, $1D, $20, $2A, $25
    DB      $28, $25, $2A, $2C, $25, $28, $33, $2A ; "(%*,%(3*"
    DB      $27, $2A, $2C, $25, $32, $33, $2A, $27 ; "'*,%23*'"
    DB      $2A, $34, $2F, $32, $2F, $34, $36, $2F ; "*4/2/46/"
    DB      $32, $33, $34, $31, $34, $36, $2F, $3C ; "234146/<"
    DB      $33, $34, $31, $34, $3E, $39, $3C, $39 ; "3414>9<9"
    DB      $3E, $40, $39, $3C, $33, $3E, $3B, $3E ; ">@9<3>;>"
    DB      $40, $39, $40, $33, $3E, $3B, $3E, $A6
    DB      $07, $00, $34, $49, $10, $35, $49, $90
    DB      $32, $09, $B0, $A3, $4A, $10, $30, $49
    DB      $B0, $04, $74, $01, $83, $04, $83, $03
    DB      $83, $02, $74, $02, $83, $02, $63, $03
    DB      $63, $05, $63, $03, $64, $06, $64, $02
    DB      $53, $03, $53, $05, $53, $03, $54, $06
    DB      $54, $02, $43, $03, $43, $05, $43, $03
    DB      $44, $06, $44, $02, $33, $03, $33, $05
    DB      $33, $03, $34, $06, $34, $03, $24, $C9

SUB_A5FF:                                  ; SUB_A5FF: display current stage number at VRAM $1803
    CALL    SUB_A4FD                       ; CALL SUB_A4FD
    LD      HL, $1803                      ; HL=$1803: VRAM stage tile
    LD      DE, $0001                      ; DE=$0001
    ADD     A, $30                         ; ADD A,$30: convert to ASCII
    RST     $18                            ; RST $18: WRITER -- write stage digit
    RET                                    ; RET: return from SUB_A5FF stage digit VRAM write

SUB_A60C:                                  ; SUB_A60C: display lives count for current player
    LD      A, ($7286)                     ; A = ($7286): current player
    LD      B, $00                         ; B=$00
    LD      C, A                           ; C = A
    DEC     C                              ; DEC C
    LD      HL, $71D9                      ; HL = $71D9: score/lives buffer
    ADD     HL, BC                         ; ADD HL,BC: index to player entry
    LD      A, (HL)                        ; A = (HL): lives value
    PUSH    AF                             ; PUSH AF
    AND     $0F                            ; AND $0F: lo nibble
    OR      $30                            ; OR $30: ASCII digit
    LD      HL, $187E                      ; HL=$187E: VRAM lives display position
    LD      DE, $0001                      ; DE=$0001
    PUSH    HL                             ; PUSH HL
    PUSH    DE                             ; PUSH DE
    RST     $18                            ; RST $18: write lo digit
    POP     DE                             ; POP DE: restore DE (VRAM stride) after lo-digit write
    POP     HL                             ; POP HL: restore HL (VRAM base) for hi-digit write
    POP     AF                             ; POP AF
    DEC     HL                             ; DEC HL: move to hi digit position
    SRL     A                              ; SRL A: shift hi nibble down
    SRL     A                              ; SRL A: A >>= 1
    SRL     A                              ; SRL A: A >>= 2
    SRL     A                              ; SRL A: A >>= 3 (divide by 8)
    OR      $30                            ; OR $30: combine with display tile offset
    RST     $18                            ; RST $18: BIOS write tile to VRAM
    RET                                    ; RET: return from score digit write

SUB_A636:                                  ; SUB_A636: display 1-UP/2-UP indicator at VRAM $1819
    CALL    SUB_A4FD                       ; CALL SUB_A4FD
    LD      HL, $1819                      ; HL=$1819
    LD      D, $00                         ; D=$00
    LD      E, (IX+0)                      ; E = (IX+0): lives count
    DEC     E                              ; DEC E
    JR      Z, LOC_A64D                    ; JR Z,LOC_A64D: zero lives
    LD      A, E                           ; A = E
    CP      $06                            ; CP $06
    JR      NC, LOC_A652                   ; JR NC,LOC_A652: >= 6 lives
    LD      A, $2F                         ; A=$2F
    RST     $18                            ; RST $18: write 1-up tile
    RET                                    ; RET: return from SUB_A60C lives display (< 6 lives)

LOC_A64D:                                  ; LOC_A64D: lives=0
    XOR     A                              ; XOR A
    LD      E, $06                         ; E=$06
    RST     $18                            ; RST $18
    RET                                    ; RET: return from LOC_A64D lives display (0 lives)

LOC_A652:                                  ; LOC_A652
    LD      E, $05                         ; E=$05
    LD      A, $2F                         ; LD A,$2F
    RST     $18                            ; RST $18
    RET                                    ; RET: return from LOC_A652 lives display (>= 6 lives)

SUB_A658:                                  ; SUB_A658: write player score buffer to VRAM $1822 or $182F
    LD      A, ($7286)                     ; A = ($7286): player
    LD      DE, $1822                      ; DE=$1822: P1 score VRAM
    LD      BC, $0006                      ; BC=$0006
    DEC     A                              ; DEC A
    JR      NZ, LOC_A669                   ; JR NZ,LOC_A669
    LD      HL, $7298                      ; HL=$7298: P1 score buffer
    RST     $08                            ; RST $08: write 6 bytes
    RET                                    ; RET: return from SUB_A658 P1 score buffer to VRAM

LOC_A669:                                  ; LOC_A669
    LD      HL, $72A5                      ; HL=$72A5: P2 score buffer
    RST     $08                            ; RST $08
    RET                                    ; RET: return from LOC_A669 P2 score buffer to VRAM

SUB_A66E:                                  ; SUB_A66E: write timer display buffer $728A to VRAM $1858 (4 bytes)
    LD      HL, $728A                      ; HL=$728A: timer display buffer
    LD      DE, $1858                      ; DE=$1858: VRAM timer display
    LD      BC, $0004                      ; BC=$0004
    RST     $08                            ; RST $08
    RET                                    ; RET: return from SUB_A66E timer display VRAM write

SUB_A679:                                  ; SUB_A679: reset sound engine -- call SOUND_INIT with B=6 channels
    LD      HL, $A6F7                      ; HL=$A6F7: sound channel table
    LD      B, $06                         ; B=$06
    JP      SOUND_INIT                     ; JP SOUND_INIT

SUB_A681:                                  ; SUB_A681: game-state init + play stage music
    CALL    SUB_A679                       ; CALL SUB_A679: reset sound
    LD      A, ($7288)                     ; A = ($7288): stage type
    OR      A                              ; OR A
    JR      Z, LOC_A695                    ; JR Z,LOC_A695: type 0
    DEC     A                              ; DEC A
    JR      Z, LOC_A691                    ; JR Z,LOC_A691: type 1
    LD      B, $11                         ; B=$11
    RST     $30                            ; RST $30 = SOUND_INIT: play croc-stage music
    RET                                    ; RET: return from LOC_A691 rope-stage music start

LOC_A691:                                  ; LOC_A691: B=$02
    LD      B, $02                         ; B=$02
    RST     $30                            ; RST $30: play rope-stage music
    RET                                    ; RET: return from LOC_A695 vine-stage music start

LOC_A695:                                  ; LOC_A695: B=$01
    LD      B, $01                         ; B=$01
    RST     $30                            ; RST $30: play vine-stage music
    RET                                    ; RET: return from SUB_A681 croc-stage music start

SUB_A699:                                  ; SUB_A699: play stage-complete jingle
    CALL    SUB_A679                       ; CALL SUB_A679
    LD      A, ($7288)                     ; A = ($7288)
    CP      $03                            ; CP $03
    JR      Z, LOC_A6AF                    ; JR Z,LOC_A6AF
    CP      $01                            ; CP $01
    JR      Z, LOC_A6AF                    ; JR Z,LOC_A6AF
    LD      B, $03                         ; B=$03
    RST     $30                            ; RST $30
    LD      B, $04                         ; B=$04
    RST     $30                            ; RST $30
    JR      LOC_A6B5                       ; JR LOC_A6B5

LOC_A6AF:                                  ; LOC_A6AF
    LD      B, $0F                         ; B=$0F
    RST     $30                            ; RST $30
    LD      B, $10                         ; B=$10
    RST     $30                            ; RST $30

LOC_A6B5:                                  ; LOC_A6B5: wait for $7346 to clear
    LD      A, ($7346)                     ; A = ($7346): completion flag
    CP      $FF                            ; CP $FF
    JR      NZ, LOC_A6B5                   ; JR NZ,LOC_A6B5: busy-wait
    RET                                    ; RET: return after busy-wait for completion flag $7346

SOUND_WRITE_A6BD:                          ; SOUND_WRITE_A6BD: play bonus-sound channel 6 via RST $30
    LD      A, $FF                         ; LD A,$FF
    LD      ($735A), A                     ; LD ($735A),A
    LD      B, $06                         ; B=$06
    RST     $30                            ; RST $30
    RET                                    ; RET: return from SOUND_WRITE_A6BD bonus channel 6

LOC_A6C6:                                  ; LOC_A6C6: RST $30 channel $13
    LD      B, $13                         ; B=$13
    RST     $30                            ; RST $30
    RET                                    ; RET: return from LOC_A6C6 sound channel $13

SUB_A6CA:                                  ; SUB_A6CA: RST $30 channel $05
    LD      B, $05                         ; B=$05
    RST     $30                            ; RST $30
    RET                                    ; RET: return from SUB_A6CA sound channel $05

SUB_A6CE:                                  ; SUB_A6CE: RST $30 channel $07
    LD      B, $07                         ; B=$07
    RST     $30                            ; RST $30
    RET                                    ; RET: return from SUB_A6CE sound channel $07

SUB_A6D2:                                  ; SUB_A6D2: RST $30 channels $08 and $09
    LD      B, $08                         ; B=$08
    RST     $30                            ; RST $30
    LD      B, $09                         ; B=$09
    RST     $30                            ; RST $30
    RET                                    ; RET: return from SUB_A6D2 channels $08/$09

SUB_A6D9:                                  ; SUB_A6D9: RST $30 channel $0A
    LD      B, $0A                         ; B=$0A
    RST     $30                            ; RST $30
    RET                                    ; RET: return from SUB_A6D9 channel $0A

SUB_A6DD:                                  ; SUB_A6DD: trigger two sound channels (B=$0B and $0C)
    LD      B, $0B                         ; LD B,$0B: first sound channel
    RST     $30                            ; RST $30: BIOS sound trigger
    LD      B, $0C                         ; LD B,$0C: second sound channel
    RST     $30                            ; RST $30: BIOS sound trigger
    RET                                    ; RET: return from SUB_A6DD
    DB      $06, $0D, $F7, $C9

SOUND_WRITE_A6E8:                          ; SOUND_WRITE_A6E8: trigger channel $0E and wait for $7350
    LD      B, $0E                         ; LD B,$0E: sound channel $0E
    RST     $30                            ; RST $30: BIOS sound trigger

LOC_A6EB:                                  ; LOC_A6EB: spin-wait on sound register $7350
    LD      A, ($7350)                     ; LD A,($7350): read sound completion flag
    CP      $FF                            ; CP $FF: compare with $FF (busy)
    JR      NZ, LOC_A6EB                   ; JR NZ,LOC_A6EB: loop while busy
    RET                                    ; RET: return when sound complete
    DB      $06, $12, $F7, $C9, $43, $A7, $46, $73
    DB      $B0, $A7, $46, $73, $48, $A8, $46, $73
    DB      $B9, $A8, $50, $73, $B8, $A9, $50, $73
    DB      $C9, $A9, $5A, $73, $F4, $A9, $78, $73
    DB      $05, $AA, $5A, $73, $0C, $AA, $6E, $73
    DB      $15, $AA, $5A, $73, $1C, $AA, $78, $73
    DB      $57, $AA, $64, $73, $94, $AA, $78, $73
    DB      $B3, $AA, $50, $73, $02, $A9, $46, $73
    DB      $5D, $A9, $50, $73, $33, $A8, $46, $73
    DB      $3B, $A8, $78, $73, $1A, $AB, $46, $73
    DB      $42, $FA, $52, $11, $19, $18, $42, $89
    DB      $63, $11, $18, $19, $42, $F8, $63, $11
    DB      $18, $19, $42, $89, $63, $09, $16, $15
    DB      $42, $FA, $52, $11, $19, $18, $42, $FA
    DB      $52, $12, $19, $18, $42, $89, $63, $08
    DB      $16, $15, $42, $F8, $63, $11, $18, $18
    DB      $42, $89, $63, $11, $18, $18, $42, $A7
    DB      $52, $11, $19, $18, $42, $27, $63, $11
    DB      $18, $19, $42, $89, $63, $11, $18, $19
    DB      $42, $27, $63, $09, $16, $15, $42, $A7
    DB      $52, $11, $19, $18, $42, $A7, $52, $12
    DB      $19, $18, $42, $27, $63, $08, $16, $15
    DB      $42, $89, $63, $11, $18, $18, $42, $27
    DB      $63, $11, $18, $18, $58, $40, $CA, $52
    DB      $06, $66, $40, $CA, $52, $05, $71, $40
    DB      $BF, $53, $06, $66, $40, $CA, $52, $06
    DB      $66, $40, $CA, $52, $05, $71, $40, $BF
    DB      $53, $06, $66, $40, $CA, $52, $06, $66
    DB      $40, $CA, $52, $05, $71, $40, $BF, $53
    DB      $06, $66, $40, $CA, $52, $06, $66, $40
    DB      $FA, $52, $06, $66, $40, $CA, $52, $06
    DB      $66, $40, $A7, $52, $06, $66, $40, $81
    DB      $52, $06, $66, $40, $81, $52, $05, $71
    DB      $40, $57, $53, $06, $66, $40, $81, $52
    DB      $06, $66, $40, $81, $52, $05, $71, $40
    DB      $57, $53, $06, $66, $40, $81, $52, $06
    DB      $66, $40, $81, $52, $05, $71, $40, $57
    DB      $53, $06, $66, $40, $81, $52, $06, $66
    DB      $40, $A7, $52, $06, $66, $40, $81, $52
    DB      $06, $66, $40, $5D, $52, $06, $66, $58
    DB      $41, $40, $50, $05, $11, $F9, $66, $58
    DB      $41, $39, $50, $07, $33, $08, $41, $79
    DB      $50, $0A, $33, $24, $50, $42, $A0, $20
    DB      $0B, $1D, $22, $42, $78, $20, $17, $1D
    DB      $22, $42, $A0, $20, $0A, $1D, $22, $42
    DB      $78, $20, $16, $1D, $22, $42, $A0, $20
    DB      $16, $1D, $22, $42, $AA, $20, $0B, $1D
    DB      $22, $42, $78, $20, $17, $1D, $22, $42
    DB      $AA, $20, $0A, $1D, $22, $42, $78, $20
    DB      $16, $1D, $22, $42, $AA, $20, $16, $1D
    DB      $22, $42, $B4, $20, $0B, $1D, $22, $42
    DB      $78, $20, $17, $1D, $22, $42, $B4, $20
    DB      $0A, $1D, $22, $42, $78, $20, $16, $1D
    DB      $22, $42, $5F, $20, $16, $1D, $22, $42
    DB      $50, $20, $16, $1D, $22, $40, $53, $21
    DB      $02, $42, $40, $21, $14, $1D, $22, $42
    DB      $81, $22, $1E, $1D, $22, $50, $82, $E0
    DB      $21, $16, $1D, $22, $82, $7D, $21, $16
    DB      $1D, $22, $82, $40, $21, $16, $1D, $22
    DB      $82, $7D, $21, $16, $1D, $22, $82, $E0
    DB      $21, $16, $1D, $22, $82, $94, $21, $16
    DB      $1D, $22, $82, $53, $21, $16, $1D, $22
    DB      $82, $94, $21, $16, $1D, $22, $82, $AC
    DB      $21, $16, $1D, $22, $82, $68, $21, $16
    DB      $1D, $22, $82, $1D, $21, $16, $1D, $22
    DB      $82, $F0, $20, $16, $1D, $22, $90, $42
    DB      $F0, $30, $13, $1B, $23, $42, $A0, $30
    DB      $13, $1B, $23, $42, $BE, $30, $09, $1B
    DB      $23, $42, $F0, $30, $1D, $1B, $23, $42
    DB      $FE, $30, $13, $1B, $23, $42, $A0, $30
    DB      $13, $1B, $23, $42, $BE, $30, $09, $1B
    DB      $23, $42, $FE, $30, $1D, $1B, $23, $42
    DB      $1D, $31, $13, $1B, $23, $42, $F0, $30
    DB      $13, $1B, $23, $42, $BE, $30, $0A, $1B
    DB      $23, $42, $A0, $30, $12, $1B, $23, $42
    DB      $BE, $30, $0A, $1B, $23, $42, $D6, $30
    DB      $26, $1B, $23, $42, $F0, $30, $26, $1B
    DB      $23, $50, $82, $E0, $31, $13, $1B, $23
    DB      $82, $81, $32, $13, $1B, $23, $82, $BF
    DB      $33, $13, $1B, $23, $82, $81, $32, $13
    DB      $1B, $23, $82, $7D, $31, $13, $1B, $23
    DB      $82, $FC, $31, $13, $1B, $23, $82, $7D
    DB      $31, $13, $1B, $23, $82, $FC, $31, $13
    DB      $1B, $23, $82, $CA, $32, $13, $1B, $23
    DB      $82, $BF, $33, $13, $1B, $23, $82, $7D
    DB      $31, $13, $1B, $23, $82, $FC, $31, $13
    DB      $1B, $23, $82, $81, $32, $13, $1B, $23
    DB      $82, $57, $33, $13, $1B, $23, $82, $E0
    DB      $31, $13, $1B, $23, $90, $83, $FF, $22
    DB      $0F, $22, $E2, $CF, $22, $83, $3D, $21
    DB      $0F, $22, $E2, $CF, $22, $90, $81, $D6
    DB      $20, $0C, $16, $FC, $83, $B4, $20, $0A
    DB      $11, $03, $14, $11, $81, $D2, $50, $06
    DB      $11, $FA, $83, $B4, $60, $06, $11, $06
    DB      $13, $11, $81, $C4, $80, $06, $11, $FD
    DB      $83, $B4, $90, $09, $11, $03, $15, $11
    DB      $90, $43, $35, $20, $0F, $11, $05, $8F
    DB      $11, $43, $80, $20, $0F, $11, $05, $8F
    DB      $11, $50, $C1, $88, $90, $06, $11, $23
    DB      $D0, $83, $11, $20, $0B, $11, $05, $17
    DB      $11, $90, $81, $FF, $42, $05, $11, $81
    DB      $90, $02, $06, $03, $53, $11, $02, $06
    DB      $03, $53, $11, $82, $BF, $03, $03, $63
    DB      $11, $82, $AF, $03, $03, $53, $11, $82
    DB      $9F, $13, $03, $53, $11, $82, $8F, $23
    DB      $03, $43, $11, $82, $7F, $33, $03, $43
    DB      $11, $82, $6F, $43, $03, $33, $11, $82
    DB      $5F, $53, $03, $33, $11, $82, $4F, $63
    DB      $03, $23, $11, $90, $C2, $FF, $23, $03
    DB      $63, $11, $C2, $FF, $33, $03, $63, $11
    DB      $C2, $8F, $40, $03, $22, $11, $C2, $8E
    DB      $50, $03, $22, $11, $C2, $8D, $60, $03
    DB      $22, $11, $C2, $8C, $70, $03, $22, $11
    DB      $C2, $8B, $80, $03, $22, $11, $C2, $8A
    DB      $90, $03, $22, $11, $C2, $89, $A0, $03
    DB      $22, $11, $C2, $88, $B0, $03, $22, $11
    DB      $D0, $40, $BE, $10, $03, $42, $B4, $10
    DB      $0A, $1A, $13, $40, $7F, $10, $03, $42
    DB      $78, $10, $0A, $1A, $13, $40, $5F, $10
    DB      $03, $42, $5A, $10, $0A, $1A, $13, $50
    DB      $41, $61, $10, $04, $11, $F9, $41, $4C
    DB      $10, $05, $11, $09, $41, $70, $10, $04
    DB      $11, $F9, $41, $5B, $10, $05, $11, $09
    DB      $41, $7F, $10, $04, $11, $F9, $41, $6A
    DB      $10, $05, $11, $09, $41, $8E, $10, $04
    DB      $11, $F9, $41, $79, $10, $05, $11, $09
    DB      $41, $9D, $10, $04, $11, $F9, $41, $88
    DB      $10, $05, $11, $09, $41, $AC, $10, $04
    DB      $11, $F9, $41, $97, $20, $05, $11, $09
    DB      $41, $BB, $30, $04, $11, $F9, $41, $A6
    DB      $40, $05, $11, $09, $41, $CA, $50, $04
    DB      $11, $F9, $41, $B5, $60, $05, $11, $09
    DB      $41, $D9, $70, $04, $11, $F9, $50, $42
    DB      $BF, $23, $09, $1A, $14, $42, $BF, $23
    DB      $09, $1A, $14, $42, $BF, $23, $09, $1A
    DB      $14, $42, $BF, $23, $09, $1A, $14, $42
    DB      $57, $23, $09, $1A, $14, $42, $FA, $22
    DB      $09, $1A, $14, $42, $CA, $22, $09, $1A
    DB      $14, $42, $CA, $22, $09, $1A, $14, $42
    DB      $CA, $22, $09, $1A, $14, $42, $CA, $22
    DB      $09, $1A, $14, $42, $FA, $22, $09, $1A
    DB      $14, $42, $57, $23, $09, $1A, $14, $58
    DB      $00, $0F, $0C, $0D, $0C, $0E, $0E, $06
    DB      $03, $F0, $30, $B0, $30, $F0, $F0, $60
    DB      $C0, $3E, $BE, $FF, $CB, $C0, $C3, $07
    DB      $07, $40, $C0, $80, $E0, $F0, $E0, $80
    DB      $80, $01, $38, $38, $18, $3E, $38, $3E
    DB      $3E, $04, $02, $82, $C4, $E8, $F0, $20
    DB      $00, $07, $0F, $07, $FF, $3F, $FD, $FB
    DB      $E3, $FD, $8F, $FC, $E0, $F0, $E0, $80
    DB      $01, $CC, $0F, $3F, $F3, $E1, $C0, $62
    DB      $72, $20, $F0, $FC, $CF, $87, $03, $46
    DB      $4E, $04, $33, $CC, $CF, $41, $80, $80
    DB      $9F, $A0, $C0, $E0, $F8, $82, $01, $01
    DB      $F9, $05, $03, $07, $1F, $33, $F3, $FF
    DB      $FF, $CC, $FF, $FF, $31, $01, $06, $0F
    DB      $01, $03, $07, $80, $60, $F0, $80, $C0
    DB      $E0, $0F, $0F, $07, $01, $B0, $70, $E0
    DB      $80, $FF, $FF, $8C, $FF, $FF, $33, $CC
    DB      $FF, $7F, $31, $FF, $FF, $8C, $FF, $FF
    DB      $33, $FF, $FE, $01, $03, $07, $0F, $0E
    DB      $0D, $07, $01, $80, $C0, $E0, $F0, $70
    DB      $B0, $E0, $80, $00, $F0, $88, $88, $F0
    DB      $88, $88, $F0, $00, $70, $88, $70, $00
    DB      $88, $88, $C8, $A8, $98, $88, $88, $00
    DB      $88, $70, $00, $70, $88, $80, $70, $08
    DB      $88, $70, $00, $F0, $88, $88, $F0, $80
    DB      $00, $80, $F8, $00, $7F, $FF, $CC, $CC
    DB      $01, $03, $06, $00, $00, $80, $C0, $60
    DB      $00, $FF, $FF, $01, $07, $1C, $3E, $7F
    DB      $2F, $C9, $09, $01, $03, $70, $88, $98
    DB      $A8, $C8, $88, $78, $00, $20, $60, $20
    DB      $70, $00, $70, $88, $08, $30, $40, $80
    DB      $F8, $00, $F8, $08, $10, $30, $08, $88
    DB      $70, $00, $10, $30, $50, $90, $F8, $10
    DB      $10, $00, $F8, $80, $F0, $08, $08, $88
    DB      $70, $00, $38, $40, $80, $F0, $88, $88
    DB      $70, $00, $F8, $08, $10, $20, $40, $00
    DB      $70, $88, $88, $70, $88, $88, $70, $00
    DB      $70, $88, $88, $78, $08, $10, $E0, $00
    DB      $06, $1F, $03, $07, $0F, $00, $60, $F8
    DB      $C0, $E0, $F0, $0F, $06, $03, $01, $00
    DB      $B0, $60, $C0, $80, $00, $FE, $FF, $33
    DB      $33, $00, $FF, $FF, $80, $E0, $01, $01
    DB      $03, $02, $02, $03, $01, $01, $80, $80
    DB      $C0, $40, $40, $C0, $80, $80, $01, $01
    DB      $03, $03, $00, $80, $80, $C0, $C0, $00
    DB      $0F, $03, $01, $01, $0B, $0F, $FF, $C3
    DB      $81, $81, $CB, $FF, $F0, $C0, $80, $80
    DB      $C0, $F0, $1F, $1F, $07, $07, $0F, $07
    DB      $FC, $F8, $EC, $F8, $F0, $E0, $3F, $1F
    DB      $37, $1F, $0F, $07, $F8, $F8, $E0, $E0
    DB      $F0, $E0, $01, $01, $03, $06, $1F, $03
    DB      $07, $0F, $80, $80, $C0, $60, $F8, $C0
    DB      $E0, $F0, $0F, $06, $03, $01, $02, $03
    DB      $01, $01, $B0, $60, $C0, $80, $40, $C0
    DB      $80, $80, $01, $03, $06, $0C, $08, $30
    DB      $60, $C0, $00, $03, $0E, $38, $E0, $03
    DB      $0E, $38, $E0, $80, $00, $C0, $70, $1C
    DB      $07, $01, $00, $C0, $70, $1C, $07, $80
    DB      $C0, $60, $30, $18, $0C, $06, $03, $EF
    DB      $DE, $BC, $BC, $BE, $BE, $DE, $EF, $F7
    DB      $7B, $3D, $3D, $7D, $7D, $7B, $F7, $EF
    DB      $DE, $BC, $BC, $BE, $BE, $DE, $DF, $F7
    DB      $7B, $3D, $3D, $7D, $7D, $7B, $F7, $00
    DB      $00, $00, $3F, $3F, $1F, $0F, $0F, $07
    DB      $03, $03, $C0, $F0, $F8, $FE, $FC, $FF
    DB      $0F, $3F, $F3, $C1, $C0, $62, $72, $21
    DB      $F0, $FC, $CF, $83, $03, $46, $4E, $84
    DB      $03, $0F, $1F, $7F, $3F, $FF, $FC, $FC
    DB      $F8, $F0, $F0, $E0, $C0, $C0, $01, $01
    DB      $00, $FE, $FE, $FF, $7F, $3F, $3F, $1F
    DB      $0F, $00, $7F, $3F, $9F, $C0, $FF, $FF
    DB      $87, $00, $FE, $FC, $F9, $03, $FF, $FF
    DB      $E1, $7F, $7F, $FF, $FE, $FC, $F8, $F8
    DB      $F0, $80, $80, $00, $07, $07, $03, $07
    DB      $81, $80, $C0, $F0, $C0, $E0, $81, $01
    DB      $03, $0F, $03, $07, $E0, $E0, $C0, $E0
    DB      $07, $07, $03, $03, $01, $03, $07, $0F
    DB      $F0, $FF, $F0, $F8, $FC, $0F, $FF, $0F
    DB      $1F, $3F, $E0, $E0, $C0, $C0, $80, $C0
    DB      $E0, $F0, $7E, $FF, $F0, $EF, $DF, $DB
    DB      $E7, $7E, $7E, $FF, $0F, $F7, $FB, $DB
    DB      $E7, $7E, $EF, $DE, $BC, $BC, $BE, $BE
    DB      $DE, $EF, $F7, $7B, $3D, $3D, $7D, $7D
    DB      $7B, $F7, $00, $88, $32, $86, $0A, $86
    DB      $88, $88, $88, $10, $88, $87, $11, $87
    DB      $03, $86, $02, $86, $83, $05, $83, $08
    DB      $85, $03, $85, $02, $86, $02, $86, $86
    DB      $02, $86, $02, $86, $02, $86, $12, $90
    DB      $09, $85, $0A, $86, $0E, $83, $01, $86
    DB      $01, $85, $04, $84, $04, $84, $02, $86
    DB      $16, $84, $2E, $83, $10, $84, $05, $83
    DB      $09, $84, $04, $88, $04, $84, $18, $84
    DB      $04, $84, $83, $05, $83, $05, $83, $0A
    DB      $83, $05, $83, $05, $83, $05, $83, $28
    DB      $84, $09, $83, $05, $87, $2C, $FF, $FF
    DB      $F2, $0C, $83, $15, $83, $0B, $86, $22
    DB      $86, $02, $83, $83, $04, $83, $05, $83
    DB      $03, $83, $83, $0C, $84, $04, $84, $28
    DB      $88, $00, $00, $0F, $3F, $7F, $FF, $FF
    DB      $E3, $C1, $3F, $FF, $FF, $E3, $E3, $C1
    DB      $C1, $80, $80, $F0, $FC, $FE, $FF, $FF
    DB      $C7, $83, $FC, $00, $07, $0F, $07, $FF
    DB      $3F, $FD, $FB, $E3, $FD, $8F, $FC, $E0
    DB      $F0, $E0, $80, $01, $03, $06, $00, $00
    DB      $80, $C0, $60, $00, $00, $01, $06, $1F
    DB      $03, $0F, $1F, $80, $60, $F8, $C0, $70
    DB      $B8, $1F, $0E, $01, $B8, $B8, $78, $F0
    DB      $80, $1E, $0F, $07, $01, $F0, $00, $80
    DB      $C0, $80, $00, $01, $06, $0F, $01, $03
    DB      $07, $80, $60, $F0, $80, $C0, $E0, $0F
    DB      $0F, $07, $01, $B0, $70, $E0, $80, $01
    DB      $05, $02, $0F, $02, $07, $0F, $1D, $80
    DB      $80, $00, $00, $80, $00, $80, $F8, $20
    DB      $50, $88, $88, $F8, $88, $88, $00, $F8
    DB      $80, $80, $F0, $80, $80, $F8, $00, $70
    DB      $88, $70, $00, $70, $88, $70, $00, $70
    DB      $88, $80, $88, $70, $00, $78, $80, $98
    DB      $88, $78, $00, $80, $F8, $00, $88, $D8
    DB      $A8, $A8, $88, $00, $F0, $88, $88, $F0
    DB      $80, $00, $F0, $88, $88, $F0, $A0, $90
    DB      $88, $00, $F8, $20, $00, $88, $50, $20
    DB      $00, $88, $88, $50, $20, $00, $88, $A8
    DB      $A8, $D8, $88, $00, $88, $88, $C8, $A8
    DB      $98, $88, $88, $00, $F0, $88, $F0, $00
    DB      $70, $88, $98, $A8, $C8, $88, $78, $00
    DB      $20, $60, $20, $70, $00, $70, $88, $08
    DB      $30, $40, $80, $F8, $00, $F8, $08, $10
    DB      $30, $08, $88, $70, $00, $10, $30, $50
    DB      $90, $F8, $10, $10, $00, $F8, $80, $F0
    DB      $08, $08, $88, $70, $00, $38, $40, $80
    DB      $F0, $88, $88, $70, $00, $F8, $08, $10
    DB      $20, $40, $00, $70, $88, $88, $70, $88
    DB      $88, $70, $00, $70, $88, $88, $78, $08
    DB      $10, $E0, $00, $03, $06, $0E, $0E, $0C
    DB      $0D, $0C, $0F, $C0, $60, $F0, $F0, $70
    DB      $F0, $01, $01, $03, $02, $02, $03, $01
    DB      $01, $80, $80, $C0, $40, $40, $C0, $80
    DB      $80, $01, $01, $03, $03, $00, $80, $80
    DB      $C0, $C0, $00, $0F, $03, $01, $01, $0B
    DB      $0F, $FF, $C3, $81, $81, $CB, $FF, $F0
    DB      $C0, $80, $80, $C0, $F0, $01, $01, $03
    DB      $02, $03, $06, $0E, $0E, $80, $80, $C0
    DB      $40, $C0, $60, $F0, $F0, $0C, $0D, $0C
    DB      $0F, $02, $03, $01, $01, $70, $F0, $40
    DB      $C0, $80, $80, $01, $01, $03, $06, $1F
    DB      $03, $07, $0F, $80, $80, $C0, $60, $F8
    DB      $C0, $E0, $F0, $0F, $06, $03, $01, $02
    DB      $03, $01, $01, $B0, $60, $C0, $80, $40
    DB      $C0, $80, $80, $00, $81, $81, $A5, $7E
    DB      $24, $7E, $A5, $81, $00, $EF, $DE, $BC
    DB      $BC, $BE, $BE, $DE, $EF, $F7, $7B, $3D
    DB      $3D, $7D, $7D, $7B, $F7, $00, $FF, $FF
    DB      $01, $07, $1C, $39, $77, $6F, $DE, $DD
    DB      $80, $E0, $78, $9C, $EE, $F6, $7B, $BB
    DB      $BB, $BA, $5B, $67, $36, $0D, $38, $7F
    DB      $BB, $5B, $DA, $E6, $6C, $B0, $1C, $FE
    DB      $01, $03, $02, $06, $0F, $02, $07, $0F
    DB      $80, $C0, $40, $C0, $E0, $00, $00, $C0
    DB      $0D

                                           ; GAME_DATA section: animation, sprite, and level layout data ($B054-$BBFF)
; GAME DATA  ($B054 - $BBFF)
; Animation, sprite, level, and name-table data.
; (Tracer did not reach this area via static flow; kept as DB.)
; ============================================================
GAME_DATA:                                 ; GAME_DATA: start of animation/sprite/level data
    DB      $0E, $07, $03, $01, $02, $03, $01, $F8
    DB      $F0, $00, $80, $C0, $40, $C0, $80, $00
    DB      $00, $00, $88, $18, $98, $02, $86, $0A
    DB      $86, $88, $8C, $04, $84, $04, $83, $05
    DB      $83, $05, $83, $01, $84, $04, $84, $03
    DB      $85, $04, $84, $90, $83, $05, $83, $08
    DB      $85, $03, $85, $21, $85, $03, $85, $04
    DB      $83, $04, $83, $04, $86, $06, $83, $05; GAME_DATA+64 animation/sprite/level data
    DB      $83, $0A, $86, $01, $85, $06, $84, $01
    DB      $83, $0E, $85, $01, $A1, $0A, $84, $2E
    DB      $83, $10, $A1, $0C, $83, $15, $84, $04
    DB      $84, $83, $05, $83, $05, $83, $1D, $83
    DB      $25, $90, $08, $98, $10, $CE, $42, $FF
    DB      $FF, $BA, $00, $00, $0F, $3F, $7F, $FF
    DB      $FF, $E3, $C1, $3F, $FF, $FF, $E3, $E3
    DB      $C1, $C1, $80, $80, $F0, $FC, $FE, $FF; GAME_DATA+128 animation/sprite/level data
    DB      $FF, $C7, $83, $FC, $0F, $FF, $FE, $FD
    DB      $E3, $FF, $FF, $EF, $9F, $F0, $07, $0F
    DB      $07, $FF, $3F, $FD, $FB, $E3, $FD, $8F
    DB      $FC, $E0, $F0, $E0, $80, $01, $03, $06
    DB      $00, $00, $80, $C0, $60, $00, $F0, $B0
    DB      $C1, $E3, $F3, $FF, $FF, $F7, $E7, $83
    DB      $03, $E7, $D9, $3F, $00, $08, $18, $7C
    DB      $FC, $E7, $D9, $3F, $0F, $0D, $83, $C7; GAME_DATA+192 animation/sprite/level data
    DB      $CF, $FF, $00, $00, $00, $03, $06, $0E
    DB      $0E, $0C, $0D, $0C, $0F, $C0, $60, $F0
    DB      $F0, $70, $F0, $01, $01, $03, $02, $02
    DB      $03, $01, $01, $80, $80, $C0, $40, $40
    DB      $C0, $80, $80, $01, $01, $03, $03, $00
    DB      $80, $80, $C0, $C0, $00, $0F, $03, $01
    DB      $01, $0B, $0F, $FF, $C3, $81, $81, $CB
    DB      $FF, $F0, $C0, $80, $80, $C0, $F0, $01; GAME_DATA+256 animation/sprite/level data
    DB      $01, $03, $02, $03, $06, $0E, $0E, $80
    DB      $80, $C0, $40, $C0, $60, $F0, $F0, $0C
    DB      $0D, $0C, $0F, $02, $03, $01, $01, $70
    DB      $F0, $40, $C0, $80, $80, $00, $81, $81
    DB      $A5, $7E, $24, $7E, $A5, $81, $00, $FF
    DB      $FF, $7F, $3F, $07, $1C, $70, $1F, $00
    DB      $FF, $FF, $7F, $3F, $00, $FF, $FF, $FE
    DB      $FC, $03, $06, $0C, $18, $18, $0C, $06; GAME_DATA+320 animation/sprite/level data
    DB      $03, $C0, $60, $30, $18, $18, $30, $60
    DB      $C0, $3F, $7F, $FF, $C0, $80, $80, $FF
    DB      $8C, $08, $00, $FC, $FE, $FF, $FF, $7F
    DB      $03, $01, $01, $00, $00, $00, $00, $FF
    DB      $FF, $FE, $FC, $E0, $38, $0E, $F8, $00
    DB      $88, $18, $88, $08, $88, $02, $86, $0A
    DB      $86, $88, $8C, $04, $84, $02, $A2, $83
    DB      $15, $83, $05, $FF, $FF, $C2, $0C, $83; GAME_DATA+384 animation/sprite/level data
    DB      $15, $84, $04, $84, $83, $05, $83, $05
    DB      $83, $1D, $83, $05, $B0, $08, $D0, $08
    DB      $9C, $04, $84, $16, $83, $03, $83, $01
    DB      $83, $09, $FF, $FF, $0A, $C0, $00, $00
    DB      $40, $80, $6F, $F4, $F4, $80, $F0, $F0
    DB      $80, $F0, $F0, $F4, $40, $80, $F0, $20
    DB      $C0, $A0, $20, $C6, $A1, $A6, $A6, $20
    DB      $C0, $A0, $C0, $E1, $60, $60, $6A, $60; GAME_DATA+448 animation/sprite/level data
    DB      $60, $6A, $E1, $E6, $EA, $E6, $6A, $E6
    DB      $EA, $E6, $E1, $E1, $E6, $C0, $90, $C0
    DB      $90, $C0, $90, $C0, $E6, $E1, $E1, $E6
    DB      $EA, $EA, $EE, $E1, $E6, $E6, $E1, $EE
    DB      $EE, $E6, $E6, $E1, $EE, $EE, $E6, $EA
    DB      $EA, $EE, $E1, $60, $00, $91, $E1, $C0
    DB      $E1, $61, $61, $60, $6B, $91, $C0, $90
    DB      $C0, $90, $E1, $61, $61, $70, $50, $70; GAME_DATA+512 animation/sprite/level data
    DB      $70, $50, $60, $F0, $D0, $60, $F0, $D0
    DB      $60, $F0, $D0, $60, $60, $E0, $E0, $60
    DB      $6E, $6E, $E0, $E0, $60, $6E, $6E, $E0
    DB      $E0, $60, $E0, $E0, $60, $70, $C0, $C0
    DB      $90, $70, $C0, $C0, $90, $70, $90, $70
    DB      $E0, $B0, $40, $00, $00, $00, $60, $6A
    DB      $60, $60, $6A, $60, $60, $6A, $60, $6A ; "``j``j`j"
    DB      $60, $6A, $6A, $66, $60, $6A, $66, $66; GAME_DATA+576 animation/sprite/level data
    DB      $6A, $6A, $66, $6A, $66, $66, $6A, $60 ; "jjfjffj`"
    DB      $6A, $60, $A0, $6A, $66, $60, $A0, $6A
    DB      $66, $60, $A0, $60, $A0, $40, $88, $90
    DB      $83, $83, $02, $83, $05, $84, $01, $83
    DB      $88, $02, $86, $02, $84, $04, $86, $90
    DB      $88, $02, $86, $02, $86, $88, $84, $83
    DB      $01, $90, $84, $83, $85, $02, $8A, $85
    DB      $83, $85, $87, $84, $84, $84, $8C, $02; GAME_DATA+640 animation/sprite/level data
    DB      $86, $06, $84, $04, $84, $02, $84, $04
    DB      $90, $90, $B8, $88, $90, $86, $02, $84
    DB      $84, $D0, $85, $83, $85, $93, $8E, $02
    DB      $92, $86, $02, $86, $02, $86, $02, $86
    DB      $02, $86, $04, $84, $04, $84, $04, $86
    DB      $02, $84, $83, $02, $83, $83, $02, $87
    DB      $84, $84, $84, $B0, $90, $90, $FF, $FF
    DB      $F2, $8B, $85, $02, $86, $02, $86, $83; GAME_DATA+704 animation/sprite/level data
    DB      $85, $90, $03, $85, $85, $05, $83, $02
    DB      $83, $96, $90, $8D, $83, $02, $83, $83
    DB      $02, $83, $83, $85, $93, $90, $00, $00
    DB      $30, $30, $20, $20, $CA, $C6, $CA, $A0
    DB      $3A, $2A, $2C, $26, $CA, $30, $30, $20
    DB      $20, $CA, $C6, $CA, $A0, $20, $C0, $A0
    DB      $20, $C6, $A1, $A6, $A6, $20, $C0, $A0
    DB      $C0, $80, $C0, $80, $C0, $80, $C0, $B0; GAME_DATA+768 animation/sprite/level data
    DB      $C0, $B0, $C0, $90, $C0, $90, $C0, $90
    DB      $C0, $B0, $C0, $00, $C0, $00, $B0, $B0
    DB      $91, $91, $91, $40, $70, $50, $70, $70
    DB      $50, $60, $F0, $D0, $60, $F0, $D0, $60
    DB      $F0, $D0, $70, $40, $70, $40, $70, $40
    DB      $70, $C0, $C0, $90, $70, $C0, $C0, $90
    DB      $70, $90, $70, $B0, $E0, $70, $C0, $C0
    DB      $B0, $70, $C0, $B0, $70, $B0, $70, $50; GAME_DATA+832 animation/sprite/level data
    DB      $70, $70, $50, $70, $70, $50, $50, $00
    DB      $00, $00, $88, $0C, $84, $07, $99, $02
    DB      $86, $02, $84, $04, $86, $A5, $83, $85
    DB      $87, $84, $84, $84, $84, $84, $84, $99
    DB      $83, $85, $87, $84, $84, $87, $85, $01
    DB      $83, $04, $FF, $FF, $92, $90, $92, $86
    DB      $02, $86, $02, $86, $02, $86, $02, $86
    DB      $84, $84, $84, $88, $84, $84, $87, $02; GAME_DATA+896 animation/sprite/level data
    DB      $83, $83, $02, $87, $84, $84, $9C, $F8
    DB      $A0, $83, $02, $83, $83, $84, $86, $83
    DB      $85, $9D, $86, $02, $86, $04, $FF, $FF
    DB      $8E, $00, $00, $30, $30, $20, $20, $CA
    DB      $C6, $CA, $A0, $3A, $2A, $2C, $26, $CA
    DB      $30, $30, $20, $20, $CA, $C6, $CA, $A0
    DB      $A6, $A0, $20, $C0, $A0, $20, $C6, $A1
    DB      $A6, $A6, $20, $C0, $A0, $C0, $A0, $40; GAME_DATA+960 animation/sprite/level data
    DB      $A4, $4F, $40, $4F, $A0, $40, $40, $40
    DB      $70, $50, $70, $70, $50, $60, $F0, $D0
    DB      $60, $F0, $D0, $60, $F0, $D0, $70, $40
    DB      $70, $40, $70, $40, $70, $C0, $CA, $CA
    DB      $C0, $CA, $CA, $C0, $CA, $CA, $C0, $70
    DB      $C0, $CA, $CA, $C0, $CA, $CA, $C0, $60
    DB      $50, $50, $E0, $50, $C0, $00, $66, $66
    DB      $60, $60, $00, $66, $66, $60, $60, $E0; GAME_DATA+1024 animation/sprite/level data
    DB      $40, $40, $E0, $40, $40, $E0, $C0, $CA
    DB      $CA, $C0, $CA, $CA, $C0, $CA, $CA, $C0
    DB      $00, $C0, $00, $00, $60, $50, $50, $E0
    DB      $50, $C0, $88, $0C, $84, $07, $89, $88
    DB      $88, $02, $86, $02, $84, $04, $86, $C0
    DB      $84, $84, $85, $83, $85, $83, $84, $FF
    DB      $FF, $D6, $92, $86, $02, $86, $02, $86
    DB      $02, $86, $02, $86, $84, $84, $84, $88; GAME_DATA+1088 animation/sprite/level data
    DB      $84, $84, $84, $8B, $02, $86, $02, $86
    DB      $02, $93, $88, $8B, $02, $86, $02, $BB
    DB      $84, $04, $98, $84, $04, $84, $04, $83
    DB      $02, $86, $02, $83, $83, $02, $86, $02
    DB      $86, $02, $9A, $01, $B0, $FF, $B9, $84
    DB      $04, $C0, $00, $00, $70, $70, $F8, $FC
    DB      $9E, $37, $23, $01, $13, $1F, $9E, $FC
    DB      $F8, $70, $00, $30, $78, $CC, $CC, $89; GAME_DATA+1152 animation/sprite/level data
    DB      $F9, $F2, $8A, $04, $00, $7F, $55, $55
    DB      $2A, $6B, $7F, $00, $30, $78, $CC, $CC
    DB      $89, $FB, $FC, $00, $0C, $1E, $33, $33
    DB      $91, $9F, $4F, $51, $20, $00, $0E, $0E
    DB      $1F, $3F, $79, $EC, $C4, $80, $C8, $F8
    DB      $79, $3F, $1F, $0E, $00, $0C, $1E, $33
    DB      $33, $91, $DF, $3F, $00, $FE, $AA, $AA
    DB      $54, $D6, $FE, $00, $38, $70, $70, $7E; GAME_DATA+1216 animation/sprite/level data
    DB      $3C, $1C, $0E, $07, $03, $01, $02, $04
    DB      $03, $00, $38, $1E, $DE, $7E, $38, $70
    DB      $E0, $C0, $F0, $B8, $8C, $8C, $F8, $30
    DB      $00, $C0, $00, $06, $07, $04, $07, $04
    DB      $07, $06, $01, $00, $F0, $30, $F0, $30
    DB      $F0, $30, $E0, $F0, $B8, $8C, $8C, $F8
    DB      $30, $80, $C0, $03, $00, $0C, $1F, $31
    DB      $31, $1D, $0F, $03, $07, $0E, $1C, $7E; GAME_DATA+1280 animation/sprite/level data
    DB      $7B, $78, $1C, $00, $C0, $20, $40, $80
    DB      $C0, $E0, $70, $38, $3C, $7E, $0E, $0E
    DB      $1C, $03, $01, $0C, $1F, $31, $31, $1D
    DB      $0F, $07, $04, $07, $04, $07, $04, $07
    DB      $00, $80, $60, $E0, $20, $E0, $20, $E0
    DB      $60, $00, $80, $80, $9F, $7F, $3F, $0F
    DB      $13, $27, $3B, $03, $3F, $07, $FF, $00
    DB      $80, $CC, $DA, $5F, $7F, $B1, $81, $C0; GAME_DATA+1344 animation/sprite/level data
    DB      $F0, $F8, $E0, $7F, $03, $1F, $81, $81
    DB      $9F, $7F, $3F, $0E, $10, $24, $3A, $00
    DB      $F0, $FC, $F8, $E0, $80, $80, $CC, $DA
    DB      $5F, $7F, $31, $01, $01, $00, $01, $33
    DB      $5B, $FA, $FE, $8D, $81, $03, $0F, $1F
    DB      $07, $00, $01, $01, $F9, $FE, $FC, $F0
    DB      $C8, $E4, $DC, $C0, $FC, $E0, $FF, $0F
    DB      $3F, $1F, $07, $01, $01, $33, $5B, $FA; GAME_DATA+1408 animation/sprite/level data
    DB      $FE, $8C, $80, $00, $FF, $C0, $F3, $81
    DB      $81, $F9, $FE, $FC, $70, $08, $24, $5C
    DB      $00, $87, $83, $81, $A3, $A3, $A7, $EF
    DB      $FF, $F9, $F9, $F3, $73, $63, $01, $E1
    DB      $C1, $81, $C5, $C5, $E5, $F7, $FF, $9F
    DB      $9F, $CF, $CE, $C6, $80, $87, $83, $81
    DB      $A3, $A3, $A7, $EF, $FF, $F9, $F9, $F3
    DB      $73, $63, $01, $E1, $C1, $81, $C5, $C5; GAME_DATA+1472 animation/sprite/level data
    DB      $E5, $F7, $FF, $9F, $9F, $CF, $CE, $C6
    DB      $80, $00, $03, $07, $0F, $0B, $0B, $0D
    DB      $07, $03, $00, $C0, $E0, $F0, $E0, $C0
    DB      $00, $04, $23, $46, $20, $08, $0C, $0E
    DB      $07, $00, $10, $02, $00, $00, $0A, $46
    DB      $6C, $18, $00, $08, $07, $0C, $18, $11
    DB      $19, $08, $0E, $13, $00, $80, $C8, $30
    DB      $20, $30, $A0, $20, $60, $D0, $00, $A5; GAME_DATA+1536 animation/sprite/level data
    DB      $1A, $30, $60, $CA, $45, $4C, $98, $90
    DB      $CC, $42, $4B, $20, $10, $48, $07, $C8
    DB      $31, $0C, $04, $D2, $A2, $21, $21, $31
    DB      $22, $42, $82, $04, $18, $62, $80, $00
    DB      $04, $06, $03, $01, $0F, $1F, $0E, $00
    DB      $20, $60, $C0, $80, $E0, $78, $B8, $78
    DB      $F0, $00, $06, $03, $01, $03, $07, $0F
    DB      $0F, $06, $03, $00, $60, $C0, $80, $C0; GAME_DATA+1600 animation/sprite/level data
    DB      $E0, $F0, $B0, $60, $C0, $00, $02, $09
    DB      $05, $03, $02, $07, $0F, $0D, $0E, $0F
    DB      $07, $01, $00, $80, $00, $80, $F8, $F0
    DB      $00, $80, $C0, $C0, $00, $01, $02, $02
    DB      $00, $03, $01, $0C, $1E, $3E, $FC, $F1
    DB      $C0, $60, $FF, $E0, $C0, $63, $40, $18
    DB      $DE, $E0, $F0, $F8, $FC, $3E, $4E, $E4
    DB      $F0, $F8, $00, $01, $02, $01, $03, $03; GAME_DATA+1664 animation/sprite/level data
    DB      $01, $19, $3C, $3C, $7E, $7E, $67, $77
    DB      $FF, $E0, $C0, $63, $40, $80, $CE, $E8
    DB      $E2, $E6, $F6, $7C, $68, $28, $00, $80
    DB      $00, $00, $01, $02, $02, $00, $1F, $3F
    DB      $3F, $38, $1B, $0F, $87, $C3, $C0, $60
    DB      $01, $FE, $E0, $C0, $63, $40, $18, $9E
    DB      $80, $04, $06, $8F, $C5, $C0, $E0, $F0
    DB      $FF, $07, $03, $C6, $02, $18, $7B, $07; GAME_DATA+1728 animation/sprite/level data
    DB      $0F, $1F, $3E, $7C, $72, $27, $0F, $1F
    DB      $00, $80, $40, $40, $00, $C0, $80, $30
    DB      $78, $7C, $3F, $0F, $03, $06, $FF, $07
    DB      $03, $C6, $02, $01, $73, $17, $47, $67
    DB      $6F, $1E, $16, $14, $00, $01, $00, $80
    DB      $40, $80, $C0, $C0, $80, $98, $3C, $3C
    DB      $7E, $7E, $F6, $EE, $80, $7F, $07, $03
    DB      $C6, $02, $18, $79, $01, $20, $60, $F1; GAME_DATA+1792 animation/sprite/level data
    DB      $A3, $03, $07, $0F, $00, $00, $80, $40
    DB      $40, $00, $F8, $FC, $FC, $1C, $D8, $F0
    DB      $E1, $C3, $03, $06, $00, $00, $01, $00
    DB      $00, $06, $1F, $1F, $0E, $00, $00, $30
    DB      $3B, $79, $F0, $E0, $07, $FF, $E3, $40
    DB      $46, $00, $8F, $CC, $00, $E0, $F0, $F0
    DB      $38, $3C, $E0, $FF, $C7, $02, $62, $00
    DB      $F1, $33, $00, $07, $0F, $0F, $1C, $3C; GAME_DATA+1856 animation/sprite/level data
    DB      $00, $00, $80, $00, $00, $60, $F8, $F8
    DB      $30, $00, $00, $0C, $DC, $9E, $0F, $07
    DB      $3F, $75, $60, $33, $20, $03, $64, $F0
    DB      $FF, $7F, $1F, $00, $07, $0F, $07, $00
    DB      $C0, $00, $30, $38, $18, $98, $30, $60
    DB      $00, $A0, $30, $30, $B8, $E0, $F0, $78
    DB      $1F, $05, $60, $E6, $C0, $CE, $61, $30
    DB      $07, $2F, $67, $60, $EF, $3F, $7F, $F0; GAME_DATA+1920 animation/sprite/level data
    DB      $E0, $70, $30, $60, $20, $00, $30, $78
    DB      $F8, $F0, $C0, $00, $00, $80, $00, $00
    DB      $4F, $E0, $F0, $66, $40, $0F, $03, $00
    DB      $08, $0C, $0E, $0E, $07, $0E, $E0, $30
    DB      $18, $20, $00, $00, $18, $3C, $3E, $1F
    DB      $0C, $7C, $FC, $0E, $0F, $00, $07, $0C
    DB      $18, $04, $00, $00, $18, $3C, $7C, $F8
    DB      $30, $3E, $3F, $70, $F0, $00, $F2, $27; GAME_DATA+1984 animation/sprite/level data
    DB      $8F, $66, $02, $F0, $C0, $00, $10, $30
    DB      $70, $70, $E0, $70, $00, $04, $0E, $1C
    DB      $1C, $3C, $3E, $33, $01, $01, $03, $00
    DB      $04, $0A, $0C, $00, $C0, $80, $00, $08
    DB      $18, $3C, $38, $78, $7C, $CC, $86, $87
    DB      $03, $00, $08, $14, $18, $00, $30, $10
    DB      $00, $04, $0E, $00, $07, $24, $20, $00
    DB      $0C, $00, $04, $0A, $0C, $00, $80, $40; GAME_DATA+2048 animation/sprite/level data
    DB      $40, $E0, $F8, $70, $20, $00, $20, $50
    DB      $30, $00, $01, $03, $01, $00, $20, $70
    DB      $38, $38, $3C, $7C, $CC, $80, $80, $C0
    DB      $00, $20, $50, $30, $00, $18, $10, $01
    DB      $03, $03, $00, $20, $30, $78, $38, $3C
    DB      $7C, $66, $C2, $C2, $80, $00, $20, $50
    DB      $30, $00, $01, $02, $02, $07, $1F, $0E
    DB      $04, $00, $20, $70, $00, $E0, $24, $04; GAME_DATA+2112 animation/sprite/level data
    DB      $00, $30, $00, $02, $01, $00, $00, $11
    DB      $18, $18, $0E, $04, $00, $08, $14, $18
    DB      $80, $40, $20, $E0, $7C, $FC, $18, $00
    DB      $10, $28, $18, $01, $02, $04, $07, $3E
    DB      $3F, $18, $00, $40, $80, $00, $00, $88
    DB      $18, $18, $70, $20, $00, $1B, $00, $01
    DB      $01, $00, $C0, $FF, $70, $20, $10, $00
    DB      $80, $00, $00, $80, $80, $00, $6C, $00; GAME_DATA+2176 animation/sprite/level data
    DB      $C0, $C0, $00, $01, $FF, $87, $02, $04
    DB      $00, $80, $80, $00, $10, $34, $0C, $00
    DB      $00, $01, $E2, $FE, $7F, $3F, $1C, $08
    DB      $00, $80, $00, $80, $00, $04, $16, $18
    DB      $00, $80, $40, $23, $3F, $7F, $FE, $1C
    DB      $08, $00, $80, $80, $00, $03, $26, $32
    DB      $37, $1C, $04, $03, $01, $00, $40, $60
    DB      $E0, $00, $F0, $F0, $30, $E0, $80, $00; GAME_DATA+2240 animation/sprite/level data
    DB      $20, $60, $60, $E0, $00, $0C, $98, $C8
    DB      $DF, $3F, $18, $0B, $0E, $00, $08, $28
    DB      $18, $38, $00, $C0, $80, $00, $02, $03
    DB      $03, $00, $A0, $F0, $60, $00, $30, $60
    DB      $20, $7F, $CF, $42, $7C, $30, $00, $00
    DB      $05, $07, $03, $06, $00, $0C, $06, $04
    DB      $FE, $F3, $C2, $7C, $18, $00, $40, $60
    DB      $60, $70, $00, $00, $40, $C0, $C0, $80; GAME_DATA+2304 animation/sprite/level data
    DB      $00, $20, $60, $70, $00, $0C, $06, $04
    DB      $FE, $FF, $C6, $74, $1C, $00, $04, $05
    DB      $06, $07, $00, $00, $40, $C0, $C0, $00
    DB      $0C, $06, $04, $FE, $F3, $42, $3E, $0C
    DB      $00, $00, $A0, $E0, $C0, $60, $00, $40
    DB      $C0, $C0, $00, $05, $0F, $06, $00, $01
    DB      $1A, $1A, $07, $03, $01, $01, $78, $70
    DB      $10, $06, $0C, $1C, $3F, $0C, $08, $00; GAME_DATA+2368 animation/sprite/level data
    DB      $20, $10, $F8, $08, $30, $E0, $00, $60
    DB      $30, $38, $FC, $30, $10, $00, $04, $08
    DB      $1F, $10, $0C, $07, $00, $80, $58, $58
    DB      $E0, $C0, $80, $80, $1E, $0E, $08, $00
    DB      $0A, $12, $CC, $DF, $7C, $1B, $0F, $00
    DB      $A0, $20, $C0, $E0, $60, $C0, $00, $C0
    DB      $40, $C0, $00, $AA, $89, $66, $FF, $C7
    DB      $7B, $1E, $E0, $C0, $E0, $00, $60, $60; GAME_DATA+2432 animation/sprite/level data
    DB      $C0, $00, $C0, $C0, $80, $01, $08, $18
    DB      $3F, $30, $1C, $03, $00, $C0, $60, $58
    DB      $F8, $E0, $C3, $83, $01, $00, $03, $06
    DB      $1A, $1F, $07, $C3, $C1, $80, $00, $03
    DB      $03, $01, $80, $10, $18, $FC, $0C, $38
    DB      $C0, $00, $3F, $75, $60, $33, $20, $07
    DB      $7F, $FF, $78, $00, $07, $0F, $07, $00
    DB      $F0, $38, $38, $30, $00, $00, $80, $00; GAME_DATA+2496 animation/sprite/level data
    DB      $00, $20, $30, $30, $B8, $E0, $F0, $78
    DB      $7F, $E5, $E0, $66, $00, $07, $0F, $07
    DB      $01, $20, $60, $60, $EF, $3F, $7F, $F0
    DB      $E0, $70, $30, $60, $20, $00, $F0, $F8
    DB      $F8, $00, $80, $00, $6C, $00, $78, $FF
    DB      $87, $02, $04, $00, $80, $00, $0D, $00
    DB      $07, $7F, $38, $10, $08, $00, $80, $00
    DB      $80, $C0, $40, $00, $E0, $E0, $00, $2A; GAME_DATA+2560 animation/sprite/level data
    DB      $09, $66, $FF, $E3, $40, $60, $00, $60
    DB      $60, $C0, $00, $0A, $12, $CC, $DF, $78
    DB      $00, $E0, $E0, $00, $80, $00, $C0, $E0
    DB      $E0, $40, $C0, $00, $0F, $83, $09, $8A
    DB      $06, $87, $07, $89, $09, $86, $0E, $83
    DB      $07, $8C, $06, $85, $09, $83, $1C, $86
    DB      $83, $23, $83, $18, $83, $86, $07, $84
    DB      $0D, $85, $17, $84, $0D, $88, $0B, $83; GAME_DATA+2624 animation/sprite/level data
    DB      $19, $84, $0C, $84, $0D, $83, $0D, $83
    DB      $0D, $83, $0D, $83, $84, $08, $89, $02
    DB      $83, $02, $8C, $08, $88, $08, $83, $09
    DB      $87, $09, $84, $26, $85, $01, $85, $06
    DB      $83, $02, $87, $09, $87, $09, $85, $0C
    DB      $86, $01, $83, $07, $83, $04, $83, $1A
    DB      $83, $50, $83, $1A, $83, $43, $83, $0D
    DB      $83, $5C, $83, $2D, $83, $06, $83, $0A; GAME_DATA+2688 animation/sprite/level data
    DB      $84, $03, $87, $02, $86, $0A, $84, $03
    DB      $85, $02, $89, $02, $83, $05, $84, $0B
    DB      $84, $03, $86, $03, $86, $0A, $84, $03
    DB      $85, $05, $85, $0A, $85, $0B, $87, $02
    DB      $83, $05, $86, $09, $85, $0A, $86, $0A
    DB      $88, $09, $83, $01, $84, $08, $89, $05
    DB      $85, $01, $84, $08, $8B, $02, $86, $0C
    DB      $88, $01, $84, $01, $86, $0C, $8A, $02; GAME_DATA+2752 animation/sprite/level data
    DB      $89, $08, $84, $03, $84, $05, $83, $0D
    DB      $83, $04, $84, $83, $01, $8B, $03, $85
    DB      $03, $84, $17, $83, $0A, $87, $0C, $83
    DB      $09, $8D, $0E, $83, $03, $85, $03, $88
    DB      $17, $83, $0D, $89, $12, $89, $0A, $85
    DB      $0A, $88, $03, $8B, $0A, $89, $08, $88
    DB      $08, $85, $0A, $86, $09, $83, $2D, $84
    DB      $01, $84, $01, $85, $01, $83, $03, $8A; GAME_DATA+2816 animation/sprite/level data
    DB      $83, $86, $01, $85, $01, $83, $03, $83
    DB      $01, $85, $01, $83, $01, $83, $0A, $8B
    DB      $03, $8B, $05, $88, $0A, $86, $00, $00
    DB      $27, $29, $00, $16, $17, $00, $2B, $2E
    DB      $3F, $3E, $00, $01, $02, $00, $18, $19
    DB      $00, $28, $00, $0C, $0D, $0E, $0F, $00
    DB      $2C, $2D, $00, $2C, $2D, $00, $24, $25
    DB      $26, $27, $28, $00, $20, $10, $11, $12; GAME_DATA+2880 animation/sprite/level data
    DB      $13, $21, $00, $0B, $0A, $0B, $0A, $00
    DB      $22, $14, $15, $1A, $1B, $23, $03, $04
    DB      $00, $0B, $0A, $0B, $0A, $00, $1C, $1D
    DB      $1E, $1F, $00, $05, $06, $00, $0B, $0A
    DB      $0B, $0A, $00, $00, $08, $00, $0B, $0A
    DB      $0B, $0A, $00, $0B, $0A, $0B, $0A, $00
    DB      $0B, $0A, $00, $00, $08, $0B, $0A, $0B
    DB      $0A, $00, $0B, $0A, $0E, $0F, $00, $16; GAME_DATA+2944 animation/sprite/level data
    DB      $17, $00, $0B, $0A, $0B, $0A, $0B, $0A
    DB      $0B, $0A, $0B, $0A, $0B, $0A, $00, $0B
    DB      $0A, $10, $11, $00, $18, $19, $00, $0B
    DB      $0A, $0B, $0A, $0E, $0F, $0B, $0A, $0B
    DB      $0A, $0B, $0A, $00, $0B, $0A, $0B, $0A
    DB      $00, $0B, $0A, $00

; ============================================================
; TILE / SPRITE BITMAPS  ($BC00 - $BF6F)
; TMS9918A pattern table -- 8 bytes per tile (one byte per row).
; 110 tiles total.
; ============================================================
TILE_BITMAPS:                              ; tile 0: TMS9918A pattern row (8 bytes)
    DB      $0B, $0A, $0B, $0A, $10, $11, $0B, $0A; tile 1: TMS9918A pattern row (8 bytes)
    DB      $0B, $0A, $0B, $0A, $00, $0B, $0A, $0B; tile 2: TMS9918A pattern row (8 bytes)
    DB      $0A, $00, $0B, $0A, $00, $1A, $1B, $0B; tile 3: TMS9918A pattern row (8 bytes)
    DB      $0A, $0B, $0A, $0B, $0A, $0B, $0A, $0B; tile 4: TMS9918A pattern row (8 bytes)
    DB      $0A, $00, $0B, $0A, $0B, $0A, $08, $00; tile 5: TMS9918A pattern row (8 bytes)
    DB      $00, $0B, $0A, $00, $12, $13, $0C, $0D; tile 6: TMS9918A pattern row (8 bytes)
    DB      $0B, $0A, $0B, $0A, $0B, $0A, $0B, $0A; tile 7: TMS9918A pattern row (8 bytes)
    DB      $00, $0B, $0A, $0B, $0A, $0B, $0A, $00; tile 8: TMS9918A pattern row (8 bytes)
    DB      $0B, $0A, $00, $0B, $0A, $00, $00, $0B; tile 9: TMS9918A pattern row (8 bytes)
    DB      $0A, $0B, $0A, $08, $00, $0B, $0A, $0B; tile 10: TMS9918A pattern row (8 bytes)
    DB      $0A, $0B, $0A, $00, $0B, $0A, $00, $0B; tile 11: TMS9918A pattern row (8 bytes)
    DB      $0A, $00, $00, $0B, $0A, $0B, $0A, $0B; tile 12: TMS9918A pattern row (8 bytes)
    DB      $0A, $0B, $0A, $00, $0B, $0A, $0B, $0A; tile 13: TMS9918A pattern row (8 bytes)
    DB      $0B, $0A, $00, $0B, $0A, $00, $0C, $0D; tile 14: TMS9918A pattern row (8 bytes)
    DB      $00, $00, $0B, $0A, $0C, $0D, $0B, $0A; tile 15: TMS9918A pattern row (8 bytes)
    DB      $0B, $0A, $00, $0B, $0A, $0B, $0A, $08; tile 16: TMS9918A pattern row (8 bytes)
    DB      $0B, $0A, $00, $0C, $0D, $00, $00, $0C; tile 17: TMS9918A pattern row (8 bytes)
    DB      $0D, $0C, $0D, $00, $0B, $0A, $0C, $0D; tile 18: TMS9918A pattern row (8 bytes)
    DB      $0B, $0A, $00, $0C, $0D, $00, $0C, $0D; tile 19: TMS9918A pattern row (8 bytes)
    DB      $00, $00, $0C, $0D, $00, $01, $02, $02; tile 20: TMS9918A pattern row (8 bytes)
    DB      $03, $00, $01, $02, $03, $00, $01, $02; tile 21: TMS9918A pattern row (8 bytes)
    DB      $03, $00, $04, $05, $05, $06, $00, $01; tile 22: TMS9918A pattern row (8 bytes)
    DB      $02, $03, $00, $04, $05, $06, $00, $00; tile 23: TMS9918A pattern row (8 bytes)
    DB      $01, $02, $03, $00, $00, $04, $05, $06; tile 24: TMS9918A pattern row (8 bytes)
    DB      $00, $04, $05, $05, $06, $00, $00, $14; tile 25: TMS9918A pattern row (8 bytes)
    DB      $15, $13, $12, $14, $15, $13, $12, $14; tile 26: TMS9918A pattern row (8 bytes)
    DB      $14, $15, $13, $12, $14, $14, $15, $13; tile 27: TMS9918A pattern row (8 bytes)
    DB      $12, $14, $15, $13, $13, $12, $14, $14; tile 28: TMS9918A pattern row (8 bytes)
    DB      $84, $02, $AC, $02, $8E, $04, $84, $02; tile 29: TMS9918A pattern row (8 bytes)
    DB      $86, $02, $89, $01, $84, $04, $84, $02; tile 30: TMS9918A pattern row (8 bytes)
    DB      $86, $02, $83, $05, $85, $06, $93, $04; tile 31: TMS9918A pattern row (8 bytes)
    DB      $83, $08, $91, $04, $84, $07, $91, $06; tile 32: TMS9918A pattern row (8 bytes)
    DB      $93, $87, $04, $84, $04, $86, $04, $8A; tile 33: TMS9918A pattern row (8 bytes)
    DB      $04, $84, $04, $86, $02, $84, $0C, $84; tile 34: TMS9918A pattern row (8 bytes)
    DB      $04, $86, $02, $84, $0C, $84, $04, $86; tile 35: TMS9918A pattern row (8 bytes)
    DB      $02, $84, $0C, $84, $04, $86, $02, $84; tile 36: TMS9918A pattern row (8 bytes)
    DB      $0C, $84, $04, $84, $04, $84, $0C, $84; tile 37: TMS9918A pattern row (8 bytes)
    DB      $06, $84, $02, $84, $08, $85, $83, $06; tile 38: TMS9918A pattern row (8 bytes)
    DB      $84, $02, $84, $0C, $84, $06, $84, $02; tile 39: TMS9918A pattern row (8 bytes)
    DB      $84, $0C, $84, $04, $86, $02, $88, $08; tile 40: TMS9918A pattern row (8 bytes)
    DB      $84, $06, $84, $02, $94, $06, $B2, $04; tile 41: TMS9918A pattern row (8 bytes)
    DB      $8E, $03, $87, $08, $83, $01, $85, $01; tile 42: TMS9918A pattern row (8 bytes)
    DB      $84, $16, $85, $01, $84, $14, $00, $00; tile 43: TMS9918A pattern row (8 bytes)
    DB      $27, $29, $00, $2B, $2E, $3F, $3E, $00; tile 44: TMS9918A pattern row (8 bytes)
    DB      $0C, $0D, $0E, $0F, $00, $20, $10, $11; tile 45: TMS9918A pattern row (8 bytes)
    DB      $12, $13, $21, $00, $28, $00, $50, $51; tile 46: TMS9918A pattern row (8 bytes)
    DB      $22, $14, $15, $1A, $1B, $23, $52, $53; tile 47: TMS9918A pattern row (8 bytes)
    DB      $00, $00, $24, $25, $26, $27, $28, $00; tile 48: TMS9918A pattern row (8 bytes)
    DB      $50, $51, $00, $00, $4F, $1C, $1D, $1E; tile 49: TMS9918A pattern row (8 bytes)
    DB      $1F, $54, $00, $00, $52, $53, $00, $03; tile 50: TMS9918A pattern row (8 bytes)
    DB      $04, $00, $00, $50, $51, $00, $4F, $00; tile 51: TMS9918A pattern row (8 bytes)
    DB      $4F, $00, $00, $54, $00, $54, $00, $52; tile 52: TMS9918A pattern row (8 bytes)
    DB      $53, $00, $05, $06, $00, $47, $4A, $00; tile 53: TMS9918A pattern row (8 bytes)
    DB      $00, $47, $48, $47, $48, $00, $49, $4A; tile 54: TMS9918A pattern row (8 bytes)
    DB      $49, $4A, $00, $00, $47, $4A, $00, $44; tile 55: TMS9918A pattern row (8 bytes)
    DB      $45, $55, $56, $45, $45, $55, $56, $55; tile 56: TMS9918A pattern row (8 bytes)
    DB      $56, $45, $55, $56, $55, $56, $45, $45; tile 57: TMS9918A pattern row (8 bytes)
    DB      $55, $56, $45, $46, $00, $00, $00, $47; tile 58: TMS9918A pattern row (8 bytes)
    DB      $48, $40, $41, $47, $48, $47, $48, $40; tile 59: TMS9918A pattern row (8 bytes)
    DB      $41, $40, $41, $47, $48, $47, $48, $40; tile 60: TMS9918A pattern row (8 bytes)
    DB      $41, $47, $48, $00, $49, $4A, $40, $41; tile 61: TMS9918A pattern row (8 bytes)
    DB      $49, $4A, $49, $4A, $40, $41, $40, $41; tile 62: TMS9918A pattern row (8 bytes)
    DB      $49, $4A, $49, $4A, $40, $41, $49, $4A; tile 63: TMS9918A pattern row (8 bytes)
    DB      $00, $42, $43, $42, $43, $42, $43, $42; tile 64: TMS9918A pattern row (8 bytes)
    DB      $43, $42, $43, $42, $43, $42, $43, $42; tile 65: TMS9918A pattern row (8 bytes)
    DB      $43, $42, $43, $42, $43, $00, $44, $45; tile 66: TMS9918A pattern row (8 bytes)
    DB      $46, $00, $00, $84, $02, $88, $04, $9C; tile 67: TMS9918A pattern row (8 bytes)
    DB      $04, $9B, $06, $8A, $01, $8D, $11, $8D; tile 68: TMS9918A pattern row (8 bytes)
    DB      $0E, $8C, $06, $83, $08, $83, $02, $8A; tile 69: TMS9918A pattern row (8 bytes)
    DB      $0B, $84, $08, $86, $01, $85, $08, $84; tile 70: TMS9918A pattern row (8 bytes)
    DB      $08, $84, $01, $FF, $FF, $C9, $14, $8C; tile 71: TMS9918A pattern row (8 bytes)
    DB      $14, $8C, $14, $C8, $01, $9A, $03, $00; tile 72: TMS9918A pattern row (8 bytes)
    DB      $00, $27, $29, $00, $2B, $2E, $3F, $3E; tile 73: TMS9918A pattern row (8 bytes)
    DB      $00, $40, $41, $00, $4B, $4C, $00, $0C; tile 74: TMS9918A pattern row (8 bytes)
    DB      $0D, $0E, $0F, $00, $01, $02, $00, $4D; tile 75: TMS9918A pattern row (8 bytes)
    DB      $4E, $00, $20, $10, $11, $12, $13, $21; tile 76: TMS9918A pattern row (8 bytes)
    DB      $42, $43, $00, $42, $43, $00, $28, $00; tile 77: TMS9918A pattern row (8 bytes)
    DB      $03, $04, $00, $22, $14, $15, $1A, $1B; tile 78: TMS9918A pattern row (8 bytes)
    DB      $23, $00, $24, $25, $26, $27, $28, $00; tile 79: TMS9918A pattern row (8 bytes)
    DB      $05, $06, $00, $00, $1C, $1D, $1E, $1F; tile 80: TMS9918A pattern row (8 bytes)
    DB      $00, $40, $41, $40, $41, $00, $00, $08; tile 81: TMS9918A pattern row (8 bytes)
    DB      $09, $00, $40, $41, $40, $41, $00, $40; tile 82: TMS9918A pattern row (8 bytes)
    DB      $41, $40, $41, $4B, $4C, $40, $41, $4B; tile 83: TMS9918A pattern row (8 bytes)
    DB      $4C, $40, $41, $40, $41, $40, $41, $40; tile 84: TMS9918A pattern row (8 bytes)
    DB      $41, $07, $08, $40, $41, $40, $41, $00; tile 85: TMS9918A pattern row (8 bytes)
    DB      $40, $41, $40, $41, $4D, $4E, $40, $41; tile 86: TMS9918A pattern row (8 bytes)
    DB      $4D, $4E, $40, $41, $40, $41, $40, $41; tile 87: TMS9918A pattern row (8 bytes)
    DB      $40, $41, $40, $41, $40, $41, $40, $41; tile 88: TMS9918A pattern row (8 bytes)
    DB      $40, $41, $40, $41, $00, $40, $41, $40; tile 89: TMS9918A pattern row (8 bytes)
    DB      $41, $40, $41, $42, $43, $40, $41, $42; tile 90: TMS9918A pattern row (8 bytes)
    DB      $43, $65, $66, $40, $41, $40, $41, $40; tile 91: TMS9918A pattern row (8 bytes)
    DB      $41, $40, $41, $40, $41, $42, $43, $42; tile 92: TMS9918A pattern row (8 bytes)
    DB      $43, $00, $40, $41, $40, $41, $42, $43; tile 93: TMS9918A pattern row (8 bytes)
    DB      $00, $00, $42, $43, $00, $00, $67, $68; tile 94: TMS9918A pattern row (8 bytes)
    DB      $42, $43, $40, $41, $42, $43, $42, $43; tile 95: TMS9918A pattern row (8 bytes)
    DB      $42, $43, $00, $40, $41, $40, $41, $00; tile 96: TMS9918A pattern row (8 bytes)
    DB      $42, $43, $00, $40, $41, $40, $41, $60; tile 97: TMS9918A pattern row (8 bytes)
    DB      $61, $62, $00, $40, $41, $40, $41, $00; tile 98: TMS9918A pattern row (8 bytes)
    DB      $40, $41, $00, $40, $41, $00, $63, $64; tile 99: TMS9918A pattern row (8 bytes)
    DB      $00, $42, $43, $42, $43, $00, $40, $41; tile 100: TMS9918A pattern row (8 bytes)
    DB      $00, $40, $41, $00, $01, $02, $02, $03; tile 101: TMS9918A pattern row (8 bytes)
    DB      $00, $42, $43, $00, $40, $41, $00, $40; tile 102: TMS9918A pattern row (8 bytes)
    DB      $41, $40, $41, $00, $42, $43, $00, $40; tile 103: TMS9918A pattern row (8 bytes)
    DB      $41, $40, $41, $00, $00, $02, $03, $00; tile 104: TMS9918A pattern row (8 bytes)
    DB      $01, $02, $03, $40, $41, $40, $41, $00; tile 105: TMS9918A pattern row (8 bytes)
    DB      $42, $43, $42, $43, $00, $02, $03, $00; tile 106: TMS9918A pattern row (8 bytes)
    DB      $01, $02, $02, $03, $00, $01, $02, $03; tile 107: TMS9918A pattern row (8 bytes)
    DB      $00, $00, $05, $06, $00, $00, $60, $61; tile 108: TMS9918A pattern row (8 bytes)
    DB      $00, $00, $04, $05, $05, $06, $00, $04; tile 109: TMS9918A pattern row (8 bytes)
    DB      $05, $06, $00, $00, $05, $06, $00, $00 ; tile 109

; ============================================================
; ZERO PADDING  ($BF70 - $BFFF)
                                           ; ZERO PADDING: filler bytes $BF70-$BFFF
    DB      $62, $63, $00, $00, $04, $05, $05, $06; padding byte
    DB      $00, $04, $05, $06, $00, $00, $13, $12; padding byte
    DB      $14, $14, $13, $13, $14, $14, $15, $13; padding byte
    DB      $13, $12, $14, $15, $13, $12, $14, $14; padding byte
    DB      $84, $02, $83, $07, $83, $02, $94, $07; padding byte
    DB      $83, $02, $93, $08, $83, $02, $88, $01; padding byte
    DB      $87, $09, $89, $05, $89, $08, $8D, $06; padding byte
    DB      $93, $01, $86, $04, $84, $13, $85, $04; padding byte
    DB      $84, $1C, $84, $1C, $84, $18, $88, $04; padding byte
    DB      $8C, $02, $8E, $04, $95, $02, $85, $04; padding byte
    DB      $84, $02, $86, $02, $87, $02, $85, $04; padding byte
    DB      $84, $02, $86, $02, $86, $04, $8C, $02; padding byte
    DB      $86, $02, $86, $04, $94, $02, $86, $06; padding byte
    DB      $85, $01, $8E, $01, $84, $05, $9C, $04; padding byte
    DB      $C2, $84, $01, $86, $04, $8A, $01, $83; padding byte
    DB      $03, $84, $0B, $8A, $01, $83, $03, $84; padding byte
    DB      $0B, $8A, $01, $83, $03, $84, $0B, $8A; padding byte
    DB      $01, $83, $03, $00, $FF, $FF, $FF, $FF; padding byte
