; =============================================================
; DONKEY KONG (1982) ColecoVision disassembly
; =============================================================
;
; LEGEND
;
;   CART_ENTRY          line   207  cart entry point ($8055)
;   START               line   215  game initialization
;   NMI                 line   822  NMI handler (TIME_MGR/SOUND_MAN/PLAY_SONGS)
;
; --- CODE SECTION ---
;
;   SUB_826F            line   483  controller/input handler
;   SUB_82D6            line   523  level setup / game state init
;   SUB_8307            line   543  score/display helper
;   SUB_8336            line   561  score digit display
;   SUB_84A3            line   741  main game loop dispatcher
;   SUB_868D            line  1015  player entity update
;   SUB_86B7            line  1044  Kong barrel-throw loop (4 slots)
;   SUB_887E            line  1285  fire entity update
;   LOC_8887            line  1291  fire entity state machine
;   SUB_897E            line  1411  enemy sprite init
;   SUB_8A60            line  1522  firebird entity init
;   SUB_8AF2            line  1583  game state dispatch
;   SUB_8B1A            line  1603  Pauline/fireball dispatch
;   SUB_8C71            line  1786  barrel/player X/Y proximity check
;   SUB_8CA9            line  1810  Kong-ladder collision
;   SUB_8CEF            line  1850  barrel-player kill check
;   SUB_8D5B            line  1906  player movement
;   SUB_8D9B            line  1936  Kong-player proximity
;   SUB_8DF6            line  1987  Kong entity init
;   SUB_8ED0            line  2081  Kong ladder-climb
;   SUB_8F2A            line  2122  Kong movement state machine
;   SUB_9066            line  2281  elevator movement
;   LOC_921C            line  2508  platform entity update
;   LOC_9231            line  2517  barrel lateral movement
;   SUB_9289            line  2561  load screen position into entity
;   SUB_9296            line  2568  barrel vs player bounce check
;   SUB_92E0            line  2609  barrel 4-slot loop (elevator/rivet)
;   SUB_92F3            line  2625  per-barrel-slot update
;   LOC_93FE            line  2761  inactive barrel spawn check
;   SUB_9494            line  2831  barrel display + player-hit loop
;   SUB_94B9            line  2854  barrel movement update
;   SUB_955C            line  2935  hammer power-up handler
;   SUB_9615            line  3017  reset hammer sprite
;   SUB_9628            line  3027  absolute difference |A-B|
;   SUB_9639            line  3043  load barrel slot entity IX/IY
;   SUB_9672            line  3091  advance animation frame
;   SUB_9688            line  3105  copy controller state to buffer
;   DELAY_LOOP_9705     line  3176  fill IX buffer + compute scaled values
;   SUB_9735            line  3212  VDP enable display (reg1=$C2)
;   SUB_973B            line  3216  integer division HL/DE
;   LOC_9751            line  3236  barrel X/Y boundary movement
;   SOUND_WRITE_9801    line  3324  find X slot for barrel X
;   SUB_9836            line  3363  find Y lane index for barrel Y
;   SUB_9858            line  3389  reset barrel entity to idle
;   SUB_9877            line  3405  load Y lane data
;   SUB_9895            line  3425  load X-slot data
;   SUB_98AA            line  3440  skip N table entries then LDIR
;   SUB_98B4            line  3450  toggle active player (P1/P2)
;   SUB_98C2            line  3461  reverse barrel X velocity
;   SOUND_WRITE_98CF    line  3471  scan Y lanes for barrel match
;   SUB_990F            line  3516  erase 3 score digit tiles
;   SUB_9930            line  3538  PLAY_IT wrapper
;   SUB_9940            line  3550  display entity via PUTOBJ
;   SUB_9956            line  3565  pseudo-random byte
;   SUB_9983            line  3597  load 16-bit pointer from IX+A
;   SUB_99A1            line  3610  allocate repeating timer signal
;   SUB_99A5            line  3614  allocate one-shot timer signal
;   SUB_99B2            line  3625  apply X movement + boundary check
;   SUB_9A54            line  3708  compare barrel X vs right boundary
;   SUB_9A5E            line  3714  init sound engine (7 channels)
;   SUB_9A66            line  3719  TEST_SIGNAL wrapper
;   SUB_9A7C            line  3735  allocate signal and spin-wait
;   SUB_9A8B            line  3745  store 16-bit pointer into IX+A slot
;   SUB_9AA7            line  3756  reset barrel velocity to zero
;
; --- DATA SECTION ---
;
;   GAME_DATA           line  4460  anim/sprite/nametable data ($B054-$BBFF)
;   TILE_BITMAPS        line  4841  TMS9918A pattern table, 110 tiles ($BC00-$BF6F)
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

BOOT_UP:                 EQU $0000          ; BOOT_UP: warm/soft reset ($0000)
BIOS_NMI:                EQU $0066          ; BIOS_NMI: hardware NMI vector ($0066)
NUMBER_TABLE:            EQU $006C          ; NUMBER_TABLE: BIOS decimal conversion table ($006C)
PLAY_SONGS:              EQU $1F61          ; PLAY_SONGS: BIOS advance song playback (call from NMI)
ACTIVATEP:               EQU $1F64          ; ACTIVATEP: BIOS activate sprite slot at IX
REFLECT_VERTICAL:        EQU $1F6A          ; REFLECT_VERTICAL: BIOS flip sprite bitmap vertically
REFLECT_HORIZONTAL:      EQU $1F6D          ; REFLECT_HORIZONTAL: BIOS flip sprite bitmap horizontally
ROTATE_90:               EQU $1F70          ; ROTATE_90: BIOS rotate sprite bitmap 90 degrees
ENLARGE:                 EQU $1F73          ; ENLARGE: BIOS enlarge sprite to 2x scale
CONTROLLER_SCAN:         EQU $1F76          ; CONTROLLER_SCAN: BIOS scan controller state -> buffer
DECODER:                 EQU $1F79          ; DECODER: BIOS decode raw controller port value
GAME_OPT:                EQU $1F7C          ; GAME_OPT: BIOS game options screen (players/difficulty)
LOAD_ASCII:              EQU $1F7F          ; LOAD_ASCII: BIOS load ASCII font into VRAM pattern table
FILL_VRAM:               EQU $1F82          ; FILL_VRAM: BIOS fill VRAM[HL] with A, count DE
MODE_1:                  EQU $1F85          ; MODE_1: BIOS init VDP text mode 1
UPDATE_SPINNER:          EQU $1F88          ; UPDATE_SPINNER: BIOS update spinner/dial input
INIT_TABLEP:             EQU $1F8B          ; INIT_TABLEP: BIOS init VRAM table via IX (pattern/colour)
PUT_VRAMP:               EQU $1F91          ; PUT_VRAMP: BIOS write sprite pattern via IX
INIT_SPR_ORDERP:         EQU $1F94          ; INIT_SPR_ORDERP: BIOS init sprite order table via IX
INIT_TIMERP:             EQU $1F9A          ; INIT_TIMERP: BIOS init timer channel via IX
REQUEST_SIGNALP:         EQU $1FA0          ; REQUEST_SIGNALP: BIOS allocate signal slot via IX
TEST_SIGNALP:            EQU $1FA3          ; TEST_SIGNALP: BIOS test signal via IX
WRITE_REGISTERP:         EQU $1FA6          ; WRITE_REGISTERP: BIOS write VDP register via IX
INIT_WRITERP:            EQU $1FAF          ; INIT_WRITERP: BIOS init WRITER DMA via IX
SOUND_INITP:             EQU $1FB2          ; SOUND_INITP: BIOS init sound engine via IX
PLAY_ITP:                EQU $1FB5          ; PLAY_ITP: BIOS play sound effect via IX
INIT_TABLE:              EQU $1FB8          ; INIT_TABLE: BIOS init VRAM from table (A=table#, HL=base)
GET_VRAM:                EQU $1FBB          ; GET_VRAM: BIOS read VRAM tile into buffer
PUT_VRAM:                EQU $1FBE          ; PUT_VRAM: BIOS write tile data to VRAM at DE
INIT_SPR_NM_TBL:         EQU $1FC1          ; INIT_SPR_NM_TBL: BIOS init sprite name table in RAM
WR_SPR_NM_TBL:           EQU $1FC4          ; WR_SPR_NM_TBL: BIOS write sprite name table to VRAM
INIT_TIMER:              EQU $1FC7          ; INIT_TIMER: BIOS init timer channel
FREE_SIGNAL:             EQU $1FCA          ; FREE_SIGNAL: BIOS free a signal slot
REQUEST_SIGNAL:          EQU $1FCD          ; REQUEST_SIGNAL: BIOS allocate a signal slot
TEST_SIGNAL:             EQU $1FD0          ; TEST_SIGNAL: BIOS test if signal is set
TIME_MGR:                EQU $1FD3          ; TIME_MGR: BIOS advance all timer channels (call from NMI)
TURN_OFF_SOUND:          EQU $1FD6          ; TURN_OFF_SOUND: BIOS silence all SN76489A channels
WRITE_REGISTER:          EQU $1FD9          ; WRITE_REGISTER: BIOS set VDP register (BC: B=reg, C=val)
READ_REGISTER:           EQU $1FDC          ; READ_REGISTER: BIOS read VDP status register -> A
WRITE_VRAM:              EQU $1FDF          ; WRITE_VRAM: BIOS write data block to VRAM
READ_VRAM:               EQU $1FE2          ; READ_VRAM: BIOS read data block from VRAM
INIT_WRITER:             EQU $1FE5          ; INIT_WRITER: BIOS init WRITER DMA engine
WRITER:                  EQU $1FE8          ; WRITER: BIOS DMA-copy tile buffer to VRAM
POLLER:                  EQU $1FEB          ; POLLER: BIOS poll controller -> JOYSTICK_BUFFER
SOUND_INIT:              EQU $1FEE          ; SOUND_INIT: BIOS init sound engine (B=channels, HL=table)
PLAY_IT:                 EQU $1FF1          ; PLAY_IT: BIOS play sound effect (B=channel)
SOUND_MAN:               EQU $1FF4          ; SOUND_MAN: BIOS advance sound engine (call from NMI)
ACTIVATE:                EQU $1FF7          ; ACTIVATE: BIOS activate sprite slot at IY
PUTOBJ:                  EQU $1FFA          ; PUTOBJ: BIOS position + display object record at IX
RAND_GEN:                EQU $1FFD          ; RAND_GEN: BIOS LCG random number -> A

; I/O PORT DEFINITIONS **********************

KEYBOARD_PORT:           EQU $0080          ; KEYBOARD_PORT: $0080 keyboard matrix
DATA_PORT:               EQU $00BE          ; DATA_PORT: $00BE VDP VRAM data port
CTRL_PORT:               EQU $00BF          ; CTRL_PORT: $00BF VDP control/status port
JOY_PORT:                EQU $00C0          ; JOY_PORT: $00C0 joystick port
CONTROLLER_02:           EQU $00F5          ; CONTROLLER_02: $00F5 player 2 controller
CONTROLLER_01:           EQU $00FC          ; CONTROLLER_01: $00FC player 1 controller
SOUND_PORT:              EQU $00FF          ; SOUND_PORT: $00FF SN76489A sound chip

; RAM DEFINITIONS ***************************

WORK_BUFFER:             EQU $7000          ; WORK_BUFFER: $7000 main RAM workspace base
CONTROLLER_BUFFER:       EQU $702B          ; CONTROLLER_BUFFER: $702B BIOS POLLER output (P1/P2 selector)
JOYSTICK_BUFFER:         EQU $7040          ; JOYSTICK_BUFFER: $7040 joystick state (non-standard offset)
STACKTOP:                EQU $73B9          ; STACKTOP: $73B9 top of stack

FNAME "output\DONKEY-KONG-1982-NEW.ROM"     ; output ROM: DONKEY-KONG-1982-NEW.ROM
CPU Z80

    ORG     $8000                           ; ROM loads at $8000
                                            ; cart magic $55AA
    DW      $55AA                           ; header padding bytes $31,$72
    DB      $31, $72                        ; header padding bytes $21,$72
    DB      $21, $72                        ; header bytes $00,$70 (WORK_BUFFER hi byte)
    DB      $00, $70                        ; JOYSTICK_BUFFER ($7040) address in header
    DW      JOYSTICK_BUFFER                 ; START entry address in header
    DW      START                           ; NOP/RET stubs for unused BIOS slots
    DB      $C9, $00, $00, $C9, $00, $00, $C9, $00 ; NOP/RET stubs continued
    DB      $00, $C9, $00, $00, $C9, $00, $00, $C9 ; RETN stub at cart header end ($ED,$4D,$00)
    DB      $00, $00, $ED, $4D, $00
                                            ; CART_ENTRY: JP NMI (game enters via NMI at $0066)
CART_ENTRY:                                 ; JP NMI: jump to NMI handler on reset
    JP      NMI                             ; copyright: "DONKEY K" ASCII bytes
    DB      $44, $4F, $4E, $4B, $45, $59, $20, $4B ; copyright: "ONG/PRES" ASCII bytes
    DB      $4F, $4E, $47, $2F, $50, $52, $45, $53 ; copyright: "ENTS NIN" ASCII bytes
    DB      $45, $4E, $54, $53, $20, $4E, $49, $4E ; copyright: "TENDO'S/" ASCII bytes
    DB      $54, $45, $4E, $44, $4F, $27, $53, $2F ; copyright: "1982" + null terminator
    DB      $31, $39, $38, $32          ; "1982"

START:                                      ; START: cold-start entry; init 944-byte workspace, run options
    LD      HL, $03B0                       ; LD HL $03B0: byte count 944 for workspace clear
    LD      IX, WORK_BUFFER                 ; LD IX WORK_BUFFER: IX -> $7000 workspace base

LOC_804F:                                   ; LOC_804F: workspace zero-fill loop head
    LD      (IX+0), $00                     ; LD (IX+0) $00: zero one byte at [IX]
    INC     IX                              ; INC IX: advance workspace pointer
    DEC     HL                              ; DEC HL: decrement byte count
    LD      A, H                            ; LD A H: high byte of remaining count
    OR      L                               ; OR L: A|=L; zero only when HL==0
    JR      NZ, LOC_804F                    ; JR NZ LOC_804F: loop until all 944 bytes zeroed
    CALL    GAME_OPT                        ; CALL GAME_OPT: BIOS game options (player count/difficulty)
    CALL    SUB_84D8                        ; CALL SUB_84D8: joystick skill-level select loop
    LD      A, ($70A6)                      ; LD A ($70A6): read selected difficulty
    LD      ($70A7), A                      ; LD ($70A7) A: save difficulty for per-level restore
    CALL    SUB_827E                        ; CALL SUB_827E: full VDP init (mode/tables/sprites)
    CALL    SUB_84A3                        ; CALL SUB_84A3: draw title screen tile patterns
    LD      HL, $73C7                       ; LD HL $73C7: pointer to NMI enable flag
    LD      (HL), $01                       ; LD (HL) $01: enable NMI-driven display updates
    SUB     A                               ; SUB A: A = 0
    LD      ($7149), A                      ; LD ($7149) A: clear Kong alternation counter

LOC_8075:                                   ; LOC_8075: main game loop; restore difficulty, init level
    LD      A, ($70A7)                      ; LD A ($70A7): reload saved difficulty
    LD      ($70A6), A                      ; LD ($70A6) A: restore difficulty for new level
    CALL    SUB_80D2                        ; CALL SUB_80D2: init player IX ptrs; clear controller buf
    CALL    SUB_9735                        ; CALL SUB_9735: WRITE_REGISTER $01C2 (enable VDP display)
    LD      A, $90                          ; LD A $90: no-input sentinel value
    LD      (JOYSTICK_BUFFER), A            ; LD (JOYSTICK_BUFFER) A: init P1 joystick buffer
    LD      ($7041), A                      ; LD ($7041) A: init P2 joystick buffer
    CALL    SUB_8606                        ; CALL SUB_8606: init HUD buffer + write score to VRAM
    LD      C, $FF                          ; LD C $FF: C=255, first-pass flag for intro loop

LOC_808E:                                   ; LOC_808E: cutscene/intro driver loop (C=pass counter)
    PUSH    BC                              ; PUSH BC: save pass counter
    CALL    SUB_85CF                        ; CALL SUB_85CF: build HUD tile buffer (score/lives)
    CALL    SUB_8615                        ; CALL SUB_8615: write SN76489A sound register
    LD      HL, $0258                       ; LD HL $0258: signal timeout = 600 ticks
    CALL    SUB_99A5                        ; CALL SUB_99A5: REQUEST_SIGNAL with HL timeout
    LD      ($714A), A                      ; LD ($714A) A: save cutscene timer signal handle

LOC_809E:                                   ; LOC_809E: frame-wait loop (polls NMI-driven timer signal)
    CALL    POLLER                          ; CALL POLLER: BIOS poll controller -> JOYSTICK_BUFFER
    CALL    TIME_MGR                        ; CALL TIME_MGR: BIOS advance timer channels
    LD      A, ($714A)                      ; LD A ($714A): reload cutscene timer signal handle
    CALL    SUB_9A66                        ; CALL SUB_9A66: TEST_SIGNAL -> Z if not yet fired
    JR      Z, LOC_809E                     ; JR Z LOC_809E: wait until timer fires
    CALL    SUB_98B4                        ; CALL SUB_98B4: toggle controller buffer (switch active player)
    POP     BC                              ; POP BC: restore pass counter
    DEC     C                               ; DEC C: decrement pass counter
    JR      NZ, LOC_80B9                    ; JR NZ LOC_80B9: not last pass -> skip VDP off
    LD      BC, $0180                       ; LD BC $0180: VDP reg1 value: disable display
    CALL    WRITE_REGISTER                  ; CALL WRITE_REGISTER: disable VDP display during transition

LOC_80B9:                                   ; LOC_80B9: route to next screen by P1/P2 game-state code
    LD      A, ($7046)                      ; LD A ($7046): read P1 game-state code
    CP      $0A                             ; CP $0A: $0A = level complete
    JR      Z, LOC_8075                     ; JR Z LOC_8075: P1 level done -> main game loop
    CP      $0B                             ; CP $0B: $0B = game over / restart
    JR      Z, START                        ; JR Z START: P1 game over -> cold start
    LD      A, ($704B)                      ; LD A ($704B): read P2 game-state code
    CP      $0A                             ; CP $0A: $0A = P2 level complete
    JR      Z, LOC_8075                     ; JR Z LOC_8075: P2 level done -> main game loop
    CP      $0B                             ; CP $0B: $0B = P2 game over / restart
    JR      NZ, LOC_808E                    ; JR NZ LOC_808E: neither -> continue cutscene
    JP      START                           ; JP START: P2 game over -> full cold start

SUB_80D2:                                   ; SUB_80D2: init player struct ptrs; clear controller buffer
    LD      IX, $702E                       ; LD IX $702E: IX -> P1 player struct base
    CALL    SUB_9858                        ; CALL SUB_9858: init player struct at IX (zero + set lives)
    LD      A, ($702D)                      ; LD A ($702D): read player count
    DEC     A                               ; DEC A: 1-player if A==0 after dec
    JR      Z, LOC_80E6                     ; JR Z LOC_80E6: 1-player -> skip P2 init
    LD      IX, $7037                       ; LD IX $7037: IX -> P2 player struct
    CALL    SUB_9858                        ; CALL SUB_9858: init P2 player struct

LOC_80E6:                                   ; LOC_80E6: clear CONTROLLER_BUFFER to select P1
    SUB     A                               ; SUB A: A = 0
    LD      (CONTROLLER_BUFFER), A          ; LD (CONTROLLER_BUFFER) A: 0=P1 active, 1=P2 active

LOC_80EA:                                   ; LOC_80EA: per-level game engine loop
    CALL    SUB_8207                        ; CALL SUB_8207: set IX -> active player struct
    LD      A, (IX+6)                       ; LD A (IX+6): read player lives count
    OR      A                               ; OR A: test lives == 0
    JR      NZ, LOC_80FE                    ; JR NZ LOC_80FE: lives remain -> run game tick
    CALL    SUB_98B4                        ; CALL SUB_98B4: toggle controller buffer (try other player)
    CALL    SUB_8207                        ; CALL SUB_8207: re-select IX for new active player
    LD      A, (IX+6)                       ; LD A (IX+6): check new player lives
    OR      A                               ; OR A: test == 0
    RET     Z                               ; RET Z: both out of lives -> return to lobby

LOC_80FE:                                   ; LOC_80FE: player has lives; run full game tick
    CALL    SUB_8215                        ; CALL SUB_8215: new level init (VDP/VRAM/entities)
    LD      B, $05                          ; LD B $05: sound channel 5 for level-start fanfare
    CALL    SUB_9930                        ; CALL SUB_9930: PLAY_IT ch5 (level-start sound)
    LD      B, $06                          ; LD B $06: sound channel 6 extra music layer
    CALL    SUB_9930                        ; CALL SUB_9930: PLAY_IT ch6
    CALL    SUB_8207                        ; CALL SUB_8207: refresh IX -> active player
    LD      A, $04                          ; LD A $04: score table register index 4
    CALL    SUB_9983                        ; CALL SUB_9983: load score HL from IX-indexed table
    LD      DE, $0190                       ; LD DE $0190: score accumulation constant
    ADD     HL, DE                          ; ADD HL DE: add constant to score
    LD      A, $00                          ; LD A $00: register index 0
    CALL    SUB_9A8B                        ; CALL SUB_9A8B: write HL back to IX-indexed table[0]
    SUB     A                               ; SUB A: A = 0
    LD      ($70A8), A                      ; LD ($70A8) A: clear game-phase register
    LD      HL, $00B4                       ; LD HL $00B4: 180-tick main timer timeout
    SUB     A                               ; SUB A: A = 0
    LD      ($714D), A                      ; LD ($714D) A: clear phase-change flag
    CALL    SUB_99A5                        ; CALL SUB_99A5: REQUEST_SIGNAL; HL=timeout -> handle in A
    LD      ($714A), A                      ; LD ($714A) A: save main game timer signal handle

LOC_812D:                                   ; LOC_812D: per-game-tick inner loop
    LD      HL, ($70A9)                     ; LD HL ($70A9): load current level-data pointer
    LD      DE, $70AB                       ; LD DE $70AB: destination for 7-byte level copy
    LD      BC, $0007                       ; LD BC $0007: 7 bytes to copy
    LDIR                                    ; LDIR: copy 7-byte level descriptor into working RAM
    CALL    SUB_9494                        ; CALL SUB_9494: update barrel entities (4 slots)
    CALL    SUB_92E0                        ; CALL SUB_92E0: update rivets/springs entities
    CALL    SUB_8B1A                        ; CALL SUB_8B1A: update Pauline/fireballs (level 0)
    CALL    SUB_86B7                        ; CALL SUB_86B7: update Kong entity (barrels level)
    CALL    SUB_955C                        ; CALL SUB_955C: update bonus timer / hammer entity
    LD      A, ($714D)                      ; LD A ($714D): read phase-change flag
    OR      A                               ; OR A: test == 0
    JR      Z, LOC_8152                     ; JR Z LOC_8152: flag clear -> check main timer signal
    CALL    SUB_90EC                        ; CALL SUB_90EC: Kong fall / rivet-complete logic
    JR      LOC_8164                        ; JR LOC_8164: skip timer check, continue tick

LOC_8152:                                   ; LOC_8152: check if main timer signal has fired
    LD      A, ($714A)                      ; LD A ($714A): reload main timer signal handle
    CALL    SUB_9A66                        ; CALL SUB_9A66: TEST_SIGNAL -> Z if not fired
    JR      Z, LOC_8164                     ; JR Z LOC_8164: not fired -> continue
    LD      HL, $714D                       ; LD HL $714D: pointer to phase-change flag
    LD      (HL), $01                       ; LD (HL) $01: set phase-change flag
    LD      B, $01                          ; LD B $01: sound channel 1 for phase-change event
    CALL    SUB_9930                        ; CALL SUB_9930: PLAY_IT ch1

LOC_8164:                                   ; LOC_8164: update player/Kong position math
    CALL    SUB_8207                        ; CALL SUB_8207: refresh IX -> active player
    LD      A, $00                          ; LD A $00: position register index 0
    CALL    SUB_9983                        ; CALL SUB_9983: load position HL from table at IX
    LD      A, H                            ; LD A H: high byte of position
    BIT     7, A                            ; BIT 7 A: test sign bit
    JR      NZ, LOC_8174                    ; JR NZ LOC_8174: negative -> set phase 2
    OR      L                               ; OR L: OR in low byte
    JR      NZ, LOC_8179                    ; JR NZ LOC_8179: non-zero -> skip phase set

LOC_8174:                                   ; LOC_8174: position at/below origin -> set game phase 2
    LD      A, $02                          ; LD A $02: phase code 2
    LD      ($70A8), A                      ; LD ($70A8) A: set game-phase register to 2

LOC_8179:                                   ; LOC_8179: threshold check for bonus life award
    LD      DE, $0064                       ; LD DE $0064: 100-unit threshold
    OR      A                               ; OR A: clear carry
    SBC     HL, DE                          ; SBC HL DE: HL = position - 100
    JP      P, LOC_8187                     ; JP P LOC_8187: positive -> skip penalty
    LD      B, $03                          ; LD B $03: sound channel 3 penalty event
    CALL    SUB_9930                        ; CALL SUB_9930: PLAY_IT ch3 penalty sound

LOC_8187:                                   ; LOC_8187: check game-phase for advanced logic
    LD      A, ($70A8)                      ; LD A ($70A8): read game-phase register
    OR      A                               ; OR A: test == 0
    JR      Z, LOC_812D                     ; JR Z LOC_812D: phase 0 -> loop back to game tick
    LD      A, $02                          ; LD A $02: position register index 2
    CALL    SUB_9983                        ; CALL SUB_9983: load HL from position table[2]
    LD      DE, $03E8                       ; LD DE $03E8: 1000-unit threshold
    OR      A                               ; OR A: clear carry
    SBC     HL, DE                          ; SBC HL DE: HL = position - 1000
    JP      M, LOC_81A7                     ; JP M LOC_81A7: negative -> skip bonus life
    LD      A, (IX+8)                       ; LD A (IX+8): read move-flags byte
    OR      A                               ; OR A: test == 0
    JR      NZ, LOC_81A7                    ; JR NZ LOC_81A7: move-flags set -> skip bonus
    INC     (IX+8)                          ; INC (IX+8): set move-flags (trigger bonus animation)
    INC     (IX+6)                          ; INC (IX+6): increment lives (bonus life awarded)

LOC_81A7:                                   ; LOC_81A7: route by game phase (1=level-active, 2=death)
    LD      A, ($70A8)                      ; LD A ($70A8): read game-phase register
    CP      $01                             ; CP $01: test phase 1
    JR      NZ, LOC_81DB                    ; JR NZ LOC_81DB: not phase 1 -> death path
    CALL    SUB_85C4                        ; CALL SUB_85C4: push score BC from active player
    CALL    SUB_9A74                        ; CALL SUB_9A74: add BC to $7165 score accumulator
    INC     (IX+7)                          ; INC (IX+7): advance animation-frame counter
    LD      A, (IX+7)                       ; LD A (IX+7): read animation frame
    CP      $05                             ; CP $05: compare with 5-frame limit
    JR      C, LOC_81C2                     ; JR C LOC_81C2: under 5 -> no wrap
    SUB     A                               ; SUB A: A = 0
    LD      (IX+7), A                       ; LD (IX+7) A: wrap animation frame to 0

LOC_81C2:                                   ; LOC_81C2: check rope-jump / girder completion
    CALL    SUB_826F                        ; CALL SUB_826F: get level-type code -> A (0/1/2)
    CP      $00                             ; CP $00: test for girder level
    JR      NZ, LOC_8201                    ; JR NZ LOC_8201: not girder -> skip
    LD      A, $04                          ; LD A $04: position register index 4
    CALL    SUB_9983                        ; CALL SUB_9983: load HL from position table[4]
    LD      DE, $0064                       ; LD DE $0064: 100-unit increment
    ADD     HL, DE                          ; ADD HL DE: add increment to position
    CALL    SUB_9A8B                        ; CALL SUB_9A8B: write back to position table[4]
    LD      HL, $70A6                       ; LD HL $70A6: pointer to difficulty byte
    INC     (HL)                            ; INC (HL): increment difficulty level
    JR      LOC_8201                        ; JR LOC_8201: continue

LOC_81DB:                                   ; LOC_81DB: level-end / death sequence
    PUSH    IX                              ; PUSH IX: save player struct pointer
    CALL    SUB_9A5E                        ; CALL SUB_9A5E: SOUND_INIT (B=7, HL=$9EA4 table)
    LD      B, $0C                          ; LD B $0C: sound channel 12 death jingle
    CALL    SUB_9930                        ; CALL SUB_9930: PLAY_IT ch12 death jingle
    LD      B, $0D                          ; LD B $0D: sound channel 13 death chord
    CALL    SUB_9930                        ; CALL SUB_9930: PLAY_IT ch13 death chord
    LD      HL, $00F0                       ; LD HL $00F0: 240-tick delay
    CALL    SUB_9A7C                        ; CALL SUB_9A7C: alloc signal + blocking wait
    CALL    SUB_9A5E                        ; CALL SUB_9A5E: SOUND_INIT reset
    LD      HL, $0050                       ; LD HL $0050: 80-tick second delay
    CALL    SUB_9A7C                        ; CALL SUB_9A7C: blocking wait for second delay
    POP     IX                              ; POP IX: restore player struct pointer
    DEC     (IX+6)                          ; DEC (IX+6): decrement player lives count
    CALL    SUB_98B4                        ; CALL SUB_98B4: toggle controller buffer (2-player)

LOC_8201:                                   ; LOC_8201: complete game tick; update score and loop
    CALL    SUB_9A5E                        ; CALL SUB_9A5E: SOUND_INIT reset
    JP      LOC_80EA                        ; JP LOC_80EA: loop back to game engine

SUB_8207:                                   ; SUB_8207: set IX -> active player struct (P1=$702E, P2=$7037)
    LD      IX, $702E                       ; LD IX $702E: assume P1
    LD      A, (CONTROLLER_BUFFER)          ; LD A (CONTROLLER_BUFFER): read P1/P2 selector (0=P1)
    OR      A                               ; OR A: test == 0
    RET     Z                               ; RET Z: P1 active -> IX already correct
    LD      IX, $7037                       ; LD IX $7037: P2 active -> IX -> P2 struct
    RET                                     ; RET

SUB_8215:                                   ; SUB_8215: new level init: level type, VDP, VRAM, entities
    CALL    SUB_826F                        ; CALL SUB_826F: get level-type -> A
    LD      ($702C), A                      ; LD ($702C) A: store level type (0=girder,1=elev,2=rivet)
    LD      E, A                            ; LD E A: E = level type for table lookup
    LD      HL, $8278                       ; LD HL $8278: base of level-data pointer table
    CALL    SUB_982B                        ; CALL SUB_982B: HL = table[E*2] (level data pointer)
    LD      ($70A9), HL                     ; LD ($70A9) HL: store level data pointer
    LD      B, $83                          ; LD B $83: no-input sentinel
    LD      HL, JOYSTICK_BUFFER             ; LD HL JOYSTICK_BUFFER: P1 joystick buffer address
    LD      (HL), B                         ; LD (HL) B: init P1 joystick to no-input
    LD      A, ($702D)                      ; LD A ($702D): read player count
    DEC     A                               ; DEC A: 1-player if A==0
    JR      Z, LOC_8235                     ; JR Z LOC_8235: 1-player -> skip P2 init
    LD      HL, $7041                       ; LD HL $7041: P2 joystick buffer address
    LD      (HL), B                         ; LD (HL) B: init P2 joystick to no-input

LOC_8235:                                   ; LOC_8235: VDP and entity init for new level
    CALL    SUB_9735                        ; CALL SUB_9735: WRITE_REGISTER $01C2 (enable VDP)
    SUB     A                               ; SUB A: A = 0
    LD      ($73C6), A                      ; LD ($73C6) A: clear NMI sync flag
    LD      HL, ($8002)                     ; LD HL ($8002): load ROM tile/palette table pointer
    LD      B, $40                          ; LD B $40: 64 bytes to fill
    CALL    DELAY_LOOP_97FA                 ; CALL DELAY_LOOP_97FA: fill 64 bytes at HL with 0
    LD      A, $0A                          ; LD A $0A: INIT_WRITER command code
    LD      HL, $704C                       ; LD HL $704C: WRITER DMA target address
    CALL    INIT_WRITER                     ; CALL INIT_WRITER: init WRITER DMA engine
    CALL    SUB_8438                        ; CALL SUB_8438: load level background tiles to VRAM
    LD      HL, $706A                       ; LD HL $706A: timer base address
    LD      DE, $70A2                       ; LD DE $70A2: timer data address
    CALL    INIT_TIMER                      ; CALL INIT_TIMER: init countdown timer channel
    CALL    SUB_8DF6                        ; CALL SUB_8DF6: init Kong entity at $70D8
    CALL    SUB_897E                        ; CALL SUB_897E: init 4 enemy sprite slots
    CALL    SUB_8AF2                        ; CALL SUB_8AF2: init bonus object / rivet overlay
    CALL    SUB_9615                        ; CALL SUB_9615: activate bonus barrel sprite
    CALL    SUB_85CF                        ; CALL SUB_85CF: build HUD tile buffer (score/lives)
    LD      HL, $73C6                       ; LD HL $73C6: pointer to NMI sync flag
    LD      (HL), $01                       ; LD (HL) $01: enable NMI display sync
    JP      LOC_974B                        ; JP LOC_974B: WRITE_REGISTER $01E2 (mode2 on); return

SUB_826F:                                   ; SUB_826F: get level type -> A via IX+7 animation frame
    LD      HL, $9AAF                       ; LD HL $9AAF: level-select data base
    LD      A, (IX+7)                       ; LD A (IX+7): player animation frame index
    JP      LOC_965D                        ; JP LOC_965D: A = HL[A] -> level type in A; RET
    DB      $B4, $9A, $EB, $9A, $12, $9B    ; DB: extra data bytes for SUB_826F jump table

SUB_827E:                                   ; SUB_827E: full VDP init: mode2, clear VRAM, load all tables
    CALL    SUB_9A5E                        ; CALL SUB_9A5E: SOUND_INIT (B=7, reset all channels)
    LD      A, $D0                          ; LD A $D0: tile buffer fill value
    LD      B, $48                          ; LD B $48: 72 bytes to fill
    LD      HL, ($8004)                     ; LD HL ($8004): ROM tile/palette data pointer
    CALL    DELAY_LOOP_97FA                 ; CALL DELAY_LOOP_97FA: fill 72 bytes at HL with A
    LD      A, $00                          ; LD A $00: A=0 for PUT_VRAM
    LD      DE, BOOT_UP                     ; LD DE BOOT_UP: VRAM dest $0000
    LD      IY, $0012                       ; LD IY $0012: 18 bytes to write
    CALL    PUT_VRAM                        ; CALL PUT_VRAM: write 18 bytes to VRAM at $0000
    LD      A, $10                          ; LD A $10: 16 sprite slots
    CALL    INIT_SPR_NM_TBL                 ; CALL INIT_SPR_NM_TBL: init sprite name table
    CALL    SUB_856C                        ; CALL SUB_856C: init sprite ptrs + clear entity ptrs
    LD      BC, $0002                       ; LD BC $0002: VDP reg0: graphics mode 2
    CALL    WRITE_REGISTER                  ; CALL WRITE_REGISTER: set VDP mode 2
    LD      BC, $0700                       ; LD BC $0700: VDP reg7: default palette
    CALL    WRITE_REGISTER                  ; CALL WRITE_REGISTER: set VDP palette register
    LD      A, $00                          ; LD A $00: INIT_TABLE type 0
    LD      HL, $1C00                       ; LD HL $1C00: VRAM dest for table 0
    CALL    INIT_TABLE                      ; CALL INIT_TABLE: load VRAM table 0
    LD      A, $01                          ; LD A $01: INIT_TABLE type 1
    LD      HL, $3800                       ; LD HL $3800: VRAM dest for table 1
    CALL    INIT_TABLE                      ; CALL INIT_TABLE: load VRAM table 1
    LD      A, $02                          ; LD A $02: INIT_TABLE type 2 (color table)
    LD      HL, $1800                       ; LD HL $1800: VRAM color table dest
    CALL    INIT_TABLE                      ; CALL INIT_TABLE: load color table to $1800
    LD      A, $03                          ; LD A $03: INIT_TABLE type 3
    LD      HL, $2000                       ; LD HL $2000: VRAM dest for table 3
    CALL    INIT_TABLE                      ; CALL INIT_TABLE: load VRAM table 3
    LD      A, $04                          ; LD A $04: INIT_TABLE type 4 (sprite patterns)
    LD      HL, BOOT_UP                     ; LD HL BOOT_UP: sprite pattern VRAM dest $0000
    CALL    INIT_TABLE                      ; CALL INIT_TABLE: load sprite patterns to $0000
    JP      SUB_9735                        ; JP SUB_9735: WRITE_REGISTER enable; return

SUB_82D6:                                   ; SUB_82D6: init Kong sprite pair for current level type
    LD      HL, $8324                       ; LD HL $8324: base of Kong sprite descriptor table
    LD      A, ($702C)                      ; LD A ($702C): read level type (0/1/2)
    ADD     A, A                            ; ADD A A: A *= 2 (table is 2 bytes/entry)
    CALL    LOC_965D                        ; CALL LOC_965D: HL = table[A] (Kong sprite desc ptr)
    LD      E, (HL)                         ; LD E (HL): low byte of sprite descriptor ptr
    INC     HL                              ; INC HL
    LD      D, (HL)                         ; LD D (HL): high byte of sprite descriptor ptr
    LD      ($7163), DE                     ; LD ($7163) DE: store sprite descriptor ptr
    LD      HL, $B43D                       ; LD HL $B43D: Kong sprite-0 PUTOBJ descriptor base
    LD      ($7161), HL                     ; LD ($7161) HL: store PUTOBJ ptr for sprite 0
    LD      DE, $71CE                       ; LD DE $71CE: tile data dest RAM for sprite 0
    LD      ($715C), DE                     ; LD ($715C) DE: store tile data dest
    CALL    SUB_8307                        ; CALL SUB_8307: activate + position Kong sprite 0
    LD      HL, $B4EE                       ; LD HL $B4EE: Kong sprite-1 PUTOBJ descriptor base
    LD      ($7161), HL                     ; LD ($7161) HL: store PUTOBJ ptr for sprite 1
    LD      DE, $71BB                       ; LD DE $71BB: tile data dest RAM for sprite 1
    LD      ($715C), DE                     ; LD ($715C) DE: store tile data dest
    JP      SUB_8307                        ; JP SUB_8307: activate + position Kong sprite 1; return

SUB_8307:                                   ; SUB_8307: ACTIVATE sprite at ($7161) + copy tiles to ($715C)
    OR      A                               ; OR A: clear carry
    CALL    ACTIVATE                        ; CALL ACTIVATE: BIOS activate sprite slot at IY
    LD      HL, ($7163)                     ; LD HL ($7163): load sprite descriptor ptr
    LD      DE, ($715C)                     ; LD DE ($715C): load tile data dest
    LDI                                     ; LDI: copy tile byte 0
    XOR     A                               ; XOR A: A = 0 (attribute clear)
    LD      (DE), A                         ; LD (DE) A: clear attribute byte 0
    INC     DE                              ; INC DE
    LDI                                     ; LDI: copy tile byte 1
    LD      (DE), A                         ; LD (DE) A: clear attribute byte 1
    LD      ($7163), HL                     ; LD ($7163) HL: update sprite descriptor ptr
    LD      IX, ($7161)                     ; LD IX ($7161): load PUTOBJ descriptor address
    JP      PUTOBJ                          ; JP PUTOBJ: position + display Kong sprite; return
    DB      $2A, $83, $2E, $83, $32, $83, $B8, $10 ; DB: PUTOBJ data bytes for Kong sprites
    DB      $78, $00, $68, $30, $78, $10, $28, $18
    DB      $8C, $08

SUB_8336:                                   ; SUB_8336: iterate enemy sprite list from IY; A=count
    LD      C, A                            ; LD C A: C = sprite count
    LD      B, $00                          ; LD B $00: B = 0 for BC index
    PUSH    IY                              ; PUSH IY: save IY base ptr
    POP     HL                              ; POP HL: HL = IY base
    ADD     HL, BC                          ; ADD HL BC: HL += C
    ADD     HL, BC                          ; ADD HL BC: HL += C (total offset = C*2)
    LD      E, (HL)                         ; LD E (HL): low byte of entry ptr
    INC     HL                              ; INC HL
    LD      D, (HL)                         ; LD D (HL): high byte of entry ptr
    DB      $EB                             ; DB $EB: EX DE,HL
    LD      A, (HL)                         ; LD A (HL): read sprite count byte
    LD      ($715E), A                      ; LD ($715E) A: store sprite count for inner loop
    OR      A                               ; OR A: test count == 0
    RET     Z                               ; RET Z: empty list -> return
    INC     HL                              ; INC HL: advance past count to first entry

LOC_8349:                                   ; LOC_8349: sprite activation loop per entry
    LD      ($715C), HL                     ; LD ($715C) HL: save current entry ptr
    LD      E, (HL)                         ; LD E (HL): tile descriptor ptr low
    INC     HL                              ; INC HL
    LD      D, (HL)                         ; LD D (HL): tile descriptor ptr high
    DB      $EB                             ; DB $EB: EX DE,HL
    LD      ($7161), HL                     ; LD ($7161) HL: store tile descriptor ptr
    LD      E, (HL)                         ; LD E (HL): sprite X position
    INC     HL                              ; INC HL
    LD      D, (HL)                         ; LD D (HL): sprite Y position
    LD      ($715F), HL                     ; LD ($715F) HL: store sprite XY ptr
    INC     HL                              ; INC HL
    LD      E, (HL)                         ; LD E (HL): sprite attribute byte 1
    INC     HL                              ; INC HL
    LD      D, (HL)                         ; LD D (HL): sprite attribute byte 2
    DB      $EB                             ; DB $EB: EX DE,HL
    LD      ($7163), HL                     ; LD ($7163) HL: store attribute ptr
    LD      HL, ($7161)                     ; LD HL ($7161): reload tile descriptor ptr
    OR      A                               ; OR A: clear carry
    CALL    ACTIVATE                        ; CALL ACTIVATE: BIOS activate sprite slot
    LD      HL, ($715C)                     ; LD HL ($715C): reload entry ptr
    INC     HL                              ; INC HL
    INC     HL                              ; INC HL: skip past tile descriptor ptr
    LD      DE, ($7163)                     ; LD DE ($7163): load attribute ptr
    INC     DE                              ; INC DE: advance ptr
    LDI                                     ; LDI: copy attribute byte 0
    XOR     A                               ; XOR A
    LD      (DE), A                         ; LD (DE) A: clear attribute byte
    INC     DE                              ; INC DE
    LDI                                     ; LDI: copy attribute byte 2
    LD      (DE), A                         ; LD (DE) A: clear attribute byte
    LD      ($715C), HL                     ; LD ($715C) HL: update entry ptr
    LD      IX, ($7161)                     ; LD IX ($7161): load tile descriptor addr
    LD      HL, ($715F)                     ; LD HL ($715F): load XY ptr
    CALL    PUTOBJ                          ; CALL PUTOBJ: position sprite via BIOS PUTOBJ
    LD      HL, ($715C)                     ; LD HL ($715C): reload entry ptr for next iteration
    LD      A, ($715E)                      ; LD A ($715E): read remaining sprite count
    DEC     A                               ; DEC A: decrement count
    LD      ($715E), A                      ; LD ($715E) A: save new count
    JR      NZ, LOC_8349                    ; JR NZ LOC_8349: more sprites -> loop
    RET                                     ; RET

SUB_8394:                                   ; SUB_8394: index IX table by A; load ptr->IX; read 1 byte
    LD      C, A                            ; LD C A: C = table index
    LD      B, $00                          ; LD B $00: B = 0 for 16-bit index
    ADD     IX, BC                          ; ADD IX BC: IX += index
    ADD     IX, BC                          ; ADD IX BC: IX += index again (total = index*2)
    LD      L, (IX+0)                       ; LD L (IX+0): ptr low byte
    LD      H, (IX+1)                       ; LD H (IX+1): ptr high byte
    PUSH    HL                              ; PUSH HL
    POP     IX                              ; POP IX: IX = dereferenced pointer
    LD      A, (IX+0)                       ; LD A (IX+0): read first byte (entry count)
    LD      ($715B), A                      ; LD ($715B) A: store entry count
    INC     IX                              ; INC IX: advance IX past count byte
    RET                                     ; RET

SOUND_WRITE_83AD:                           ; SOUND_WRITE_83AD: write multi-frame sprite tile data to VRAM
    LD      A, (IX+0)                       ; LD A (IX+0): read frame count
    LD      ($715E), A                      ; LD ($715E) A: store frame count
    LD      E, (IX+1)                       ; LD E (IX+1): VRAM dest low
    LD      D, (IX+2)                       ; LD D (IX+2): VRAM dest high
    LD      A, (IX+3)                       ; LD A (IX+3): tile pattern index
    LD      HL, ($8006)                     ; LD HL ($8006): tile buffer address
    LD      (HL), A                         ; LD (HL) A: write pattern index to tile buffer
    LD      ($7161), IX                     ; LD ($7161) IX: save IX pointer

LOC_83C4:                                   ; LOC_83C4: per-frame VRAM write loop
    LD      ($715F), DE                     ; LD ($715F) DE: save VRAM dest
    LD      IY, $0001                       ; LD IY $0001: 1 byte to write
    LD      A, $02                          ; LD A $02: PUT_VRAM type 2
    LD      HL, ($8006)                     ; LD HL ($8006): reload tile buffer
    CALL    PUT_VRAM                        ; CALL PUT_VRAM: write 1 byte to VRAM at DE
    LD      HL, $FFE0                       ; LD HL $FFE0: -32 (one tile-row stride)
    LD      DE, ($715F)                     ; LD DE ($715F): reload VRAM dest
    ADD     HL, DE                          ; ADD HL DE: advance VRAM addr by one tile row
    DB      $EB                             ; DB $EB: EX DE,HL (DE = new VRAM addr)
    LD      A, ($715E)                      ; LD A ($715E): read remaining frame count
    DEC     A                               ; DEC A
    LD      ($715E), A                      ; LD ($715E) A: save new count
    JR      NZ, LOC_83C4                    ; JR NZ LOC_83C4: more frames -> loop
    LD      BC, $0004                       ; LD BC $0004: entry stride = 4 bytes
    LD      IX, ($7161)                     ; LD IX ($7161): reload saved IX
    ADD     IX, BC                          ; ADD IX BC: advance IX to next entry
    LD      A, ($715B)                      ; LD A ($715B): remaining entry count
    DEC     A                               ; DEC A
    LD      ($715B), A                      ; LD ($715B) A: save new count
    JR      NZ, SOUND_WRITE_83AD            ; JR NZ SOUND_WRITE_83AD: more entries -> loop
    RET                                     ; RET

SUB_83F9:                                   ; SUB_83F9: fill tile buffer with pattern; write to VRAM
    LD      C, (IX+0)                       ; LD C (IX+0): fill count
    PUSH    BC                              ; PUSH BC
    POP     IY                              ; POP IY: IY = fill count
    LD      E, (IX+1)                       ; LD E (IX+1): VRAM dest low
    LD      D, (IX+2)                       ; LD D (IX+2): VRAM dest high
    LD      HL, ($8006)                     ; LD HL ($8006): tile buffer address
    LD      A, (IX+3)                       ; LD A (IX+3): tile pattern byte to fill with

LOC_840B:                                   ; LOC_840B: fill loop
    LD      (HL), A                         ; LD (HL) A: write tile byte to buffer
    INC     HL                              ; INC HL: advance buffer pointer
    DEC     C                               ; DEC C: decrement fill count
    JR      NZ, LOC_840B                    ; JR NZ LOC_840B: loop until buffer filled
    LD      HL, ($8006)                     ; LD HL ($8006): reload tile buffer base
    LD      A, $02                          ; LD A $02: PUT_VRAM type 2
    LD      ($7161), IX                     ; LD ($7161) IX: save IX
    CALL    PUT_VRAM                        ; CALL PUT_VRAM: write buffer to VRAM at DE
    LD      IX, ($7161)                     ; LD IX ($7161): restore IX
    LD      BC, $0004                       ; LD BC $0004: stride = 4 bytes per entry
    ADD     IX, BC                          ; ADD IX BC: advance IX to next entry
    LD      A, ($715B)                      ; LD A ($715B): remaining entry count
    DEC     A                               ; DEC A
    LD      ($715B), A                      ; LD ($715B) A: save new count
    JR      NZ, SUB_83F9                    ; JR NZ SUB_83F9: more entries -> loop
    RET                                     ; RET
    DB      $CD, $35, $97, $CD, $99, $84, $C3, $4B ; DB: inline data / call stub bytes
    DB      $97

SUB_8438:                                   ; SUB_8438: load level VRAM tiles (background + sprites + HUD)
    LD      BC, $0182                       ; LD BC $0182: VDP reg1 enable display+sprites
    CALL    WRITE_REGISTER                  ; CALL WRITE_REGISTER: set VDP display mode
    CALL    SUB_8499                        ; CALL SUB_8499: clear name table VRAM ($1800, 768 bytes)
    LD      IX, $B099                       ; LD IX $B099: level background tile descriptor table
    LD      A, ($702C)                      ; LD A ($702C): read level type
    CALL    SUB_8394                        ; CALL SUB_8394: index into descriptor table by level type
    CALL    SUB_83F9                        ; CALL SUB_83F9: fill+write background tile buffer to VRAM
    LD      IX, $B093                       ; LD IX $B093: tile pattern index table
    LD      A, ($702C)                      ; LD A ($702C): read level type
    CALL    SUB_8394                        ; CALL SUB_8394: index into pattern table
    CALL    SOUND_WRITE_83AD                ; CALL SOUND_WRITE_83AD: write multi-frame patterns to VRAM
    LD      IY, $B359                       ; LD IY $B359: entity sprite descriptor table
    LD      A, ($702C)                      ; LD A ($702C): read level type
    CALL    SUB_8336                        ; CALL SUB_8336: activate sprite list for level type
    CALL    SUB_82D6                        ; CALL SUB_82D6: init Kong sprite pair
    CALL    SUB_846E                        ; CALL SUB_846E: draw score/lives/timer HUD tiles
    JP      SUB_9735                        ; JP SUB_9735: enable VDP display; return

SUB_846E:                                   ; SUB_846E: draw score/lives/timer HUD tiles to VRAM
    LD      IY, $000A                       ; LD IY $000A: 10 bytes to write
    LD      DE, $00A2                       ; LD DE $00A2: VRAM dest for score/lives line
    PUSH    DE                              ; PUSH DE: save VRAM dest
    LD      HL, (NUMBER_TABLE)              ; LD HL (NUMBER_TABLE): BIOS decimal tile table addr
    LD      A, $03                          ; LD A $03: PUT_VRAM type 3
    CALL    PUT_VRAM                        ; CALL PUT_VRAM: write score/lives tiles to VRAM
    LD      IY, $0002                       ; LD IY $0002: 2 bytes to write
    LD      DE, $00AC                       ; LD DE $00AC: VRAM dest for level indicator
    LD      HL, $AB9B                       ; LD HL $AB9B: level indicator tile data
    LD      A, $03                          ; LD A $03: PUT_VRAM type 3
    CALL    PUT_VRAM                        ; CALL PUT_VRAM: write level indicator to VRAM
    POP     HL                              ; POP HL: restore score VRAM dest
    ADD     HL, HL                          ; ADD HL HL
    ADD     HL, HL                          ; ADD HL HL
    ADD     HL, HL                          ; ADD HL HL: HL *= 8 (shift to HUD line address)
    LD      DE, $0060                       ; LD DE $0060: additional VRAM offset
    LD      A, $F0                          ; LD A $F0: fill value
    JP      FILL_VRAM                       ; JP FILL_VRAM: BIOS fill HUD remainder; return

SUB_8499:                                   ; SUB_8499: clear VRAM name table ($1800, 768 bytes)
    LD      HL, $1800                       ; LD HL $1800: VRAM name table base
    LD      DE, $0300                       ; LD DE $0300: 768 bytes to clear
    XOR     A                               ; XOR A: fill value = 0
    JP      FILL_VRAM                       ; JP FILL_VRAM: BIOS fill $1800..$1AFF; return

SUB_84A3:                                   ; SUB_84A3: draw title screen tile patterns to VRAM
    LD      BC, $0182                       ; LD BC $0182: VDP reg1 enable display
    CALL    WRITE_REGISTER                  ; CALL WRITE_REGISTER: enable VDP display
    LD      A, $03                          ; LD A $03: tile table type 3 (title border)
    LD      HL, $A7D3                       ; LD HL $A7D3: title tile data base
    CALL    SUB_990F                        ; CALL SUB_990F: load 3 tile sub-tables to VRAM
    LD      A, $04                          ; LD A $04: tile table type 4 (game logo)
    LD      HL, $ABAB                       ; LD HL $ABAB: logo tile data base
    CALL    SUB_990F                        ; CALL SUB_990F: load 3 logo sub-tables to VRAM
    LD      A, $01                          ; LD A $01: INIT_TABLE type 1 (sprite patterns)
    LD      HL, $A113                       ; LD HL $A113: sprite pattern data
    LD      DE, $0100                       ; LD DE $0100: 256 bytes to transfer
    CALL    SUB_991E                        ; CALL SUB_991E: PUT_VRAM sprite patterns
    CALL    SUB_8499                        ; CALL SUB_8499: clear VRAM name table
    LD      A, $03                          ; LD A $03: reflected tile type
    LD      DE, $001F                       ; LD DE $001F: reflect params (width/height)
    LD      BC, $0027                       ; LD BC $0027: reflect second param
    LD      HL, $007B                       ; LD HL $007B: reflect source address
    CALL    REFLECT_VERTICAL                ; CALL REFLECT_VERTICAL: BIOS flip sprite bitmap
    JP      SUB_9735                        ; JP SUB_9735: enable display; return

SUB_84D8:                                   ; SUB_84D8: skill-level select: read joystick until valid code
    LD      HL, ($8008)                     ; LD HL ($8008): joystick buffer base pointer
    LD      A, $90                          ; LD A $90: no-input sentinel
    LD      (HL), A                         ; LD (HL) A: init P1 joystick sentinel
    INC     HL                              ; INC HL
    LD      (HL), A                         ; LD (HL) A: init P2 joystick sentinel
    INC     HL                              ; INC HL
    LD      B, $0A                          ; LD B $0A: 10 bytes to zero
    SUB     A                               ; SUB A: fill value 0
    CALL    DELAY_LOOP_97FA                 ; CALL DELAY_LOOP_97FA: zero joystick data area
    CALL    SUB_851E                        ; CALL SUB_851E: check P1 joystick for first input
    LD      (HL), $0F                       ; LD (HL) $0F: init P1 direction field (centered)
    CALL    SUB_8523                        ; CALL SUB_8523: check P2 joystick
    LD      (HL), $0F                       ; LD (HL) $0F: init P2 direction field (centered)

LOC_84F1:                                   ; LOC_84F1: poll joystick until valid skill code pressed
    CALL    POLLER                          ; CALL POLLER: BIOS poll controller
    CALL    SUB_851E                        ; CALL SUB_851E: read P1 joystick direction
    JR      NZ, LOC_8500                    ; JR NZ LOC_8500: P1 pressed valid -> parse skill
    CALL    SUB_8523                        ; CALL SUB_8523: read P2 joystick direction
    JR      NZ, LOC_8500                    ; JR NZ LOC_8500: P2 pressed valid -> parse skill
    JR      LOC_84F1                        ; JR LOC_84F1: neither pressed -> keep polling

LOC_8500:                                   ; LOC_8500: valid joystick input; parse skill code in A
    OR      A                               ; OR A: test A == 0
    JR      Z, SUB_84D8                     ; JR Z SUB_84D8: invalid code -> re-poll
    CP      $09                             ; CP $09: test A >= 9
    JR      NC, SUB_84D8                    ; JR NC SUB_84D8: code >= 9 invalid -> re-poll
    LD      HL, $702D                       ; LD HL $702D: pointer to player-count byte
    LD      (HL), $01                       ; LD (HL) $01: default 1 player
    DEC     A                               ; DEC A: A -= 1 to isolate player/skill bits
    BIT     2, A                            ; BIT 2 A: bit 2 set = 2-player code
    JR      Z, LOC_8512                     ; JR Z LOC_8512: bit 2 clear -> 1-player
    INC     (HL)                            ; INC (HL): set 2-player count

LOC_8512:                                   ; LOC_8512: extract difficulty level from joystick code
    INC     A                               ; INC A: restore A
    AND     $F3                             ; AND $F3: mask out player-count bits
    JR      NZ, LOC_8519                    ; JR NZ LOC_8519: non-zero -> use as difficulty
    LD      A, $04                          ; LD A $04: default difficulty 4

LOC_8519:                                   ; LOC_8519: store parsed difficulty
    LD      HL, $70A6                       ; LD HL $70A6: pointer to difficulty byte
    LD      (HL), A                         ; LD (HL) A: store selected difficulty
    RET                                     ; RET

SUB_851E:                                   ; SUB_851E: read P1 joystick (offset 6 into buffer)
    LD      DE, $0006                       ; LD DE $0006: P1 joystick field offset
    JR      LOC_8526                        ; JR LOC_8526: jump to compare logic

SUB_8523:                                   ; SUB_8523: read P2 joystick (offset $0B into buffer)
    LD      DE, $000B                       ; LD DE $000B: P2 joystick field offset

LOC_8526:                                   ; LOC_8526: compare joystick[HL+DE] with $0F (centered)
    LD      HL, ($8008)                     ; LD HL ($8008): joystick buffer base
    ADD     HL, DE                          ; ADD HL DE: HL += offset -> joystick direction field
    LD      A, (HL)                         ; LD A (HL): read joystick value
    CP      $0F                             ; CP $0F: $0F = centered / no direction
    RET                                     ; RET: Z=1 if centered, NZ if direction pressed

NMI:                                        ; NMI: hardware NMI handler; save regs, run engines, restore
    PUSH    AF                              ; PUSH AF
    PUSH    BC                              ; PUSH BC
    PUSH    DE                              ; PUSH DE
    PUSH    HL                              ; PUSH HL
    PUSH    IX                              ; PUSH IX
    PUSH    IY                              ; PUSH IY
    EX      AF, AF'                         ; EX AF AF': switch to alternate AF
    EXX                                     ; EXX: switch to alternate BC,DE,HL
    PUSH    AF                              ; PUSH AF: save alternate AF
    PUSH    BC                              ; PUSH BC: save alternate BC
    PUSH    DE                              ; PUSH DE: save alternate DE
    PUSH    HL                              ; PUSH HL: save alternate HL
    CALL    TIME_MGR                        ; CALL TIME_MGR: BIOS advance timer channels
    CALL    SOUND_MAN                       ; CALL SOUND_MAN: BIOS advance sound engine
    CALL    PLAY_SONGS                      ; CALL PLAY_SONGS: BIOS advance song playback
    CALL    SUB_868D                        ; CALL SUB_868D: alternate Kong sprite animation
    LD      A, $10                          ; LD A $10: 16 sprite slots
    CALL    WR_SPR_NM_TBL                   ; CALL WR_SPR_NM_TBL: BIOS write sprite name table to VRAM
    CALL    WRITER                          ; CALL WRITER: BIOS DMA-copy tile buffer to VRAM
    CALL    POLLER                          ; CALL POLLER: BIOS poll controller -> JOYSTICK_BUFFER
    CALL    SOUND_WRITE_8587                ; CALL SOUND_WRITE_8587: throttled SN76489A sound write
    CALL    READ_REGISTER                   ; CALL READ_REGISTER: read VDP status register -> A
    LD      ($73C5), A                      ; LD ($73C5) A: cache VDP status byte
    POP     HL                              ; POP HL: restore alternate HL
    POP     DE                              ; POP DE: restore alternate DE
    POP     BC                              ; POP BC: restore alternate BC
    POP     AF                              ; POP AF: restore alternate AF
    EX      AF, AF'                         ; EX AF AF': restore main AF
    EXX                                     ; EXX: restore main BC,DE,HL
    POP     IY                              ; POP IY
    POP     IX                              ; POP IX
    POP     HL                              ; POP HL
    POP     DE                              ; POP DE
    POP     BC                              ; POP BC
    POP     AF                              ; POP AF
    RETN                                    ; RETN: return from non-maskable interrupt

SUB_856C:                                   ; SUB_856C: init entity ptrs; clear sprite/score data
    LD      HL, BOOT_UP                     ; LD HL BOOT_UP: HL = $0000
    LD      ($7165), HL                     ; LD ($7165) HL: init score accumulator to 0
    LD      ($702E), HL                     ; LD ($702E) HL: clear P1 sprite ptr
    LD      ($7030), HL                     ; LD ($7030) HL: clear P1 auxiliary ptr
    LD      ($7037), HL                     ; LD ($7037) HL: clear P2 sprite ptr
    LD      ($7039), HL                     ; LD ($7039) HL: clear P2 auxiliary ptr
    LD      HL, $7169                       ; LD HL $7169: sound throttle counter ptr
    LD      (HL), $0F                       ; LD (HL) $0F: init primary throttle = 15
    INC     HL                              ; INC HL
    LD      (HL), $08                       ; LD (HL) $08: init secondary throttle = 8
    RET                                     ; RET

SOUND_WRITE_8587:                           ; SOUND_WRITE_8587: throttled per-NMI SN76489A sound writer
    LD      HL, $7169                       ; LD HL $7169: primary sound throttle counter
    DEC     (HL)                            ; DEC (HL): decrement counter
    RET     NZ                              ; RET NZ: not zero -> skip this frame
    LD      (HL), $0F                       ; LD (HL) $0F: reload throttle to 15
    CALL    SUB_8615                        ; CALL SUB_8615: write SN76489A register data
    LD      HL, $716A                       ; LD HL $716A: secondary throttle counter
    DEC     (HL)                            ; DEC (HL): decrement secondary counter
    RET     NZ                              ; RET NZ: not zero -> skip secondary update
    LD      (HL), $08                       ; LD (HL) $08: reload secondary throttle to 8
    CALL    SUB_860E                        ; CALL SUB_860E: VRAM score display update
    CALL    SUB_85C4                        ; CALL SUB_85C4: load BC = current player score
    LD      HL, $FFF6                       ; LD HL $FFF6: offset -10
    ADD     HL, BC                          ; ADD HL BC: HL = score - 10
    CALL    SUB_9A8B                        ; CALL SUB_9A8B: write (score-10) to IX-table
    LD      BC, ($7165)                     ; LD BC ($7165): load score accumulator
    LD      HL, BOOT_UP                     ; LD HL BOOT_UP: HL = $0000
    LD      ($7165), HL                     ; LD ($7165) HL: clear score accumulator
    LD      A, $02                          ; LD A $02: register index 2
    CALL    SUB_9983                        ; CALL SUB_9983: load old score -> HL
    ADD     HL, BC                          ; ADD HL BC: new score = old + accumulated
    PUSH    HL                              ; PUSH HL
    POP     DE                              ; POP DE: DE = new score
    LD      BC, $2710                       ; LD BC $2710: 10000 (bonus life threshold)
    OR      A                               ; OR A: clear carry
    SBC     HL, BC                          ; SBC HL BC: HL = score - 10000
    JP      NC, SUB_9A8B                    ; JP NC SUB_9A8B: score >= 10000 -> bonus life
    DB      $EB                             ; DB $EB: EX DE,HL (HL = new score)
    JP      SUB_9A8B                        ; JP SUB_9A8B: write new score; return

SUB_85C4:                                   ; SUB_85C4: read current player score from IX table -> BC
    CALL    SUB_8207                        ; CALL SUB_8207: set IX -> active player struct
    LD      A, $00                          ; LD A $00: score register index 0
    CALL    SUB_9983                        ; CALL SUB_9983: load score -> HL from IX table
    PUSH    HL                              ; PUSH HL
    POP     BC                              ; POP BC: BC = score value
    RET                                     ; RET

SUB_85CF:                                   ; SUB_85CF: build HUD tile buffer at $7150 for score/lives
    LD      HL, $7150                       ; LD HL $7150: HUD tile buffer base
    LD      A, (CONTROLLER_BUFFER)          ; LD A (CONTROLLER_BUFFER): read P1/P2 selector
    ADD     A, $A3                          ; ADD A $A3: offset to player label tile code
    LD      (HL), $00                       ; LD (HL) $00: tile[0] = blank
    INC     HL                              ; INC HL
    LD      (HL), A                         ; LD (HL) A: tile[1] = player label
    INC     HL                              ; INC HL
    LD      (HL), $AC                       ; LD (HL) $AC: tile[2] = score digit area
    INC     HL                              ; INC HL
    LD      (HL), $AD                       ; LD (HL) $AD: tile[3] = score digit continued
    INC     HL                              ; INC HL
    LD      (HL), $00                       ; LD (HL) $00: tile[4] = blank end
    LD      DE, $0021                       ; LD DE $0021: VRAM dest for HUD row
    CALL    LOC_862D                        ; CALL LOC_862D: PUT_VRAM 5 bytes at $7150 to VRAM
    CALL    SUB_85FD                        ; CALL SUB_85FD: zero HUD buffer
    CALL    SUB_8207                        ; CALL SUB_8207: refresh IX -> active player
    LD      A, (IX+6)                       ; LD A (IX+6): read lives count
    ADD     A, $A2                          ; ADD A $A2: offset to lives tile code
    LD      ($7151), A                      ; LD ($7151) A: store lives tile in buffer
    LD      DE, $003D                       ; LD DE $003D: VRAM dest for lives row
    JR      LOC_862D                        ; JR LOC_862D: PUT_VRAM lives tile; return

SUB_85FD:                                   ; SUB_85FD: zero 5-byte HUD buffer at $7150
    LD      B, $05                          ; LD B $05: 5 bytes to zero
    LD      HL, $7150                       ; LD HL $7150: HUD buffer base
    SUB     A                               ; SUB A: fill value = 0
    JP      DELAY_LOOP_97FA                 ; JP DELAY_LOOP_97FA: fill; return

SUB_8606:                                   ; SUB_8606: zero HUD buffer then write score to VRAM
    CALL    SUB_85FD                        ; CALL SUB_85FD: zero HUD buffer at $7150
    LD      DE, $0081                       ; LD DE $0081: VRAM dest for score area
    JR      LOC_862D                        ; JR LOC_862D: PUT_VRAM score tiles; return

SUB_860E:                                   ; SUB_860E: write score display tile-0 to VRAM $0081
    LD      A, $00                          ; LD A $00: source index = 0
    LD      DE, $0081                       ; LD DE $0081: VRAM dest for score tile
    JR      LOC_861A                        ; JR LOC_861A: shared display-write path

SUB_8615:                                   ; SUB_8615: write score display tile-2 to VRAM $0026
    LD      A, $02                          ; LD A $02: source index = 2
    LD      DE, $0026                       ; LD DE $0026: VRAM dest for score tile 2

LOC_861A:                                   ; LOC_861A: shared path: set IX, write score tile via DELAY_LOOP
    PUSH    AF                              ; PUSH AF: save source index
    CALL    SUB_8207                        ; CALL SUB_8207: set IX -> active player
    POP     AF                              ; POP AF: restore source index
    CALL    SUB_9983                        ; CALL SUB_9983: load score HL from IX table[A]
    PUSH    IX                              ; PUSH IX: save player struct ptr
    LD      IX, $7150                       ; LD IX $7150: HUD tile buffer
    CALL    DELAY_LOOP_9705                 ; CALL DELAY_LOOP_9705: write 5 score tiles to VRAM at DE
    POP     IX                              ; POP IX: restore player struct ptr

LOC_862D:                                   ; LOC_862D: PUT_VRAM 5 bytes from $7150 to VRAM at DE
    LD      IY, $0005                       ; LD IY $0005: 5 bytes to write
    LD      HL, $7150                       ; LD HL $7150: tile data buffer
    LD      A, $02                          ; LD A $02: PUT_VRAM type 2
    JP      PUT_VRAM                        ; JP PUT_VRAM: write to VRAM at DE; return

DELAY_LOOP_8639:                            ; DELAY_LOOP_8639: find free barrel slot; init it with A,B,C
    PUSH    BC                              ; PUSH BC
    PUSH    DE                              ; PUSH DE
    LD      IX, $70F4                       ; LD IX $70F4: IX -> first barrel entity slot
    LD      B, $04                          ; LD B $04: 4 barrel slots to check
    LD      DE, $0010                       ; LD DE $0010: stride = 16 bytes per slot

LOC_8644:                                   ; LOC_8644: scan barrel slots for free entry
    BIT     0, (IX+0)                       ; BIT 0 (IX+0): test active flag
    JR      Z, LOC_8651                     ; JR Z LOC_8651: flag clear -> slot is free
    ADD     IX, DE                          ; ADD IX DE: IX += 16 (next slot)
    DJNZ    LOC_8644                        ; DJNZ LOC_8644: check all 4 slots
    POP     DE                              ; POP DE: no free slot -> restore DE
    POP     BC                              ; POP BC
    RET                                     ; RET: return with no slot assigned

LOC_8651:                                   ; LOC_8651: free slot at IX; init barrel entity
    POP     DE                              ; POP DE
    POP     BC                              ; POP BC
    LD      (IX+0), A                       ; LD (IX+0) A: set active flag from caller
    LD      (IX+7), $02                     ; LD (IX+7) $02: animation frame = 2 (rolling)
    LD      (IX+13), B                      ; LD (IX+13) B: Y-velocity from caller
    LD      (IX+8), $00                     ; LD (IX+8) $00: clear move-flags
    LD      (IX+12), C                      ; LD (IX+12) C: X-velocity from caller
    LD      (IX+6), $00                     ; LD (IX+6) $00: clear lives/state
    LD      (IX+9), $04                     ; LD (IX+9) $04: state flags = $04
    LD      (IX+10), $04                    ; LD (IX+10) $04: collision width = 4
    LD      (IX+11), $06                    ; LD (IX+11) $06: collision height = 6
    LD      L, (IX+1)                       ; LD L (IX+1): sprite pattern ptr low
    LD      H, (IX+2)                       ; LD H (IX+2): sprite pattern ptr high
    PUSH    HL                              ; PUSH HL
    POP     IY                              ; POP IY: IY -> sprite pattern record
    LD      L, (IY+2)                       ; LD L (IY+2): pattern data low
    LD      H, (IY+3)                       ; LD H (IY+3): pattern data high
    INC     HL                              ; INC HL: advance past data byte 0
    LD      (HL), D                         ; LD (HL) D: write spawn Y position
    INC     HL                              ; INC HL
    XOR     A                               ; XOR A: A = 0
    LD      (HL), A                         ; LD (HL) A: clear attribute byte
    INC     HL                              ; INC HL
    LD      (HL), E                         ; LD (HL) E: write spawn X position
    INC     HL                              ; INC HL
    LD      (HL), A                         ; LD (HL) A: clear trailing attribute byte
    RET                                     ; RET

SUB_868D:                                   ; SUB_868D: alternate Kong sprite frames each NMI call
    LD      HL, $7221                       ; LD HL $7221: Kong frame-A tile data
    LD      DE, $722A                       ; LD DE $722A: Kong frame-B tile data
    LD      A, ($7149)                      ; LD A ($7149): read alternation counter
    CPL                                     ; CPL: toggle 0 <-> $FF
    LD      ($7149), A                      ; LD ($7149) A: save new counter
    OR      A                               ; OR A: test == 0 (was $FF -> now 0)
    JR      Z, LOC_86A7                     ; JR Z LOC_86A7: zero -> load frame-A tiles
    LD      BC, $0003                       ; LD BC $0003: 3 tile bytes to copy
    LDIR                                    ; LDIR: copy frame-B tiles from HL to DE
    LD      HL, $7221                       ; LD HL $7221: reload frame-A pointer
    JR      LOC_86B0                        ; JR LOC_86B0: write to VRAM

LOC_86A7:                                   ; LOC_86A7: load frame-A tile data (incrementing bytes)
    LD      B, $03                          ; LD B $03: 3 bytes to fill
    XOR     A                               ; XOR A: fill value = 0

LOC_86AA:                                   ; LOC_86AA: fill Kong tile bytes loop
    LD      (HL), A                         ; LD (HL) A: write tile byte
    INC     A                               ; INC A: increment tile value
    INC     HL                              ; INC HL: advance pointer
    DJNZ    LOC_86AA                        ; DJNZ LOC_86AA: 3 iterations
    DB      $EB                             ; DB $EB: EX DE,HL (HL = $722A dest)

LOC_86B0:                                   ; LOC_86B0: write 3 Kong animation tiles to VRAM
    LD      B, $03                          ; LD B $03: 3 bytes to write
    LD      A, $0F                          ; LD A $0F: fill value
    JP      DELAY_LOOP_97FA                 ; JP DELAY_LOOP_97FA: write 3 bytes at HL; return

SUB_86B7:                                   ; SUB_86B7: update Kong barrel-throw; level 0 (girder) only
    LD      A, ($702C)                      ; LD A ($702C): read level type
    OR      A                               ; OR A: test == 0 (girder level)
    RET     NZ                              ; RET NZ: not girder -> return
    CALL    SUB_9956                        ; CALL SUB_9956: RAND_GEN for barrel spawn randomness
    LD      IY, $B62A                       ; LD IY $B62A: IY -> barrel entity pointer table
    LD      B, $04                          ; LD B $04: 4 barrel slots to process

LOC_86C5:                                   ; LOC_86C5: per-barrel update loop
    LD      L, (IY+0)                       ; LD L (IY+0): barrel entity ptr low
    LD      H, (IY+1)                       ; LD H (IY+1): barrel entity ptr high
    PUSH    HL                              ; PUSH HL
    POP     IX                              ; POP IX: IX -> barrel entity struct
    INC     IY                              ; INC IY: advance IY to next ptr
    INC     IY                              ; INC IY
    PUSH    BC                              ; PUSH BC: save loop counter
    BIT     0, (IX+0)                       ; BIT 0 (IX+0): test barrel active flag
    JP      Z, LOC_8831                     ; JP Z LOC_8831: inactive -> skip to next slot
    BIT     5, (IX+0)                       ; BIT 5 (IX+0): test "just spawned" flag
    JR      Z, LOC_86F8                     ; JR Z LOC_86F8: not just spawned -> normal update
    RES     5, (IX+0)                       ; RES 5 (IX+0): clear spawn flag
    CALL    SUB_887E                        ; CALL SUB_887E: clear barrel velocity buffer ($7269)
    BIT     6, (IX+0)                       ; BIT 6 (IX+0): test "held by Kong" flag
    JR      Z, LOC_86F8                     ; JR Z LOC_86F8: not held -> normal update
    RES     6, (IX+0)                       ; RES 6 (IX+0): clear held flag
    LD      (IX+8), $01                     ; LD (IX+8) $01: set move-flags to 1 (release barrel)
    JP      LOC_8831                        ; JP LOC_8831: done for this slot

LOC_86F8:                                   ; LOC_86F8: barrel movement state machine
    BIT     7, (IX+0)                       ; BIT 7 (IX+0): test "in-throw" flag
    JR      Z, LOC_872B                     ; JR Z LOC_872B: not throwing -> platform movement
    BIT     2, (IX+9)                       ; BIT 2 (IX+9): test throw-phase flag
    JP      Z, LOC_87F8                     ; JP Z LOC_87F8: throw done -> deactivate check
    BIT     6, (IX+8)                       ; BIT 6 (IX+8): test "pre-throw" flag
    JR      Z, LOC_8716                     ; JR Z LOC_8716: not pre-throw -> start throw
    LD      (IX+8), $01                     ; LD (IX+8) $01: clear move flags to 1
    LD      (IX+9), $00                     ; LD (IX+9) $00: clear state flags
    JP      LOC_8831                        ; JP LOC_8831: done

LOC_8716:                                   ; LOC_8716: start barrel throw; set direction from position
    LD      (IX+8), $41                     ; LD (IX+8) $41: set move-flags $41 (throw mode)
    CALL    SUB_884B                        ; CALL SUB_884B: get throw direction -> A ($01 right/$FE left)
    LD      (IX+12), A                      ; LD (IX+12) A: store X-velocity direction
    LD      (IX+13), $FE                    ; LD (IX+13) $FE: set Y-velocity to -2 (upward arc)
    LD      (IX+9), $00                     ; LD (IX+9) $00: clear state flags
    JP      LOC_8831                        ; JP LOC_8831: done

LOC_872B:                                   ; LOC_872B: barrel on platform; handle movement/direction
    BIT     5, (IX+9)                       ; BIT 5 (IX+9): test "on-ramp" state
    JR      Z, LOC_8758                     ; JR Z LOC_8758: not on ramp -> normal platform move
    BIT     4, (IX+0)                       ; BIT 4 (IX+0): test "fast" mode flag
    JR      Z, LOC_873E                     ; JR Z LOC_873E: normal speed -> check direction
    SET     0, (IX+8)                       ; SET 0 (IX+8): set move bit 0
    JP      LOC_87F8                        ; JP LOC_87F8: jump to deactivate path

LOC_873E:                                   ; LOC_873E: check barrel direction from IX+7 anim bit
    BIT     1, (IX+7)                       ; BIT 1 (IX+7): test direction bit (1=left)
    JR      Z, LOC_874E                     ; JR Z LOC_874E: bit clear -> set dir right
    LD      (IX+7), $04                     ; LD (IX+7) $04: animation frame 4 (rolling right)
    LD      (IX+12), $02                    ; LD (IX+12) $02: X-velocity +2 (roll right)
    JR      LOC_875E                        ; JR LOC_875E: continue

LOC_874E:                                   ; LOC_874E: set direction left
    LD      (IX+7), $02                     ; LD (IX+7) $02: animation frame 2 (rolling left)
    LD      (IX+12), $FE                    ; LD (IX+12) $FE: X-velocity -2 (roll left)
    JR      LOC_875E                        ; JR LOC_875E

LOC_8758:                                   ; LOC_8758: normal platform movement; check escalator flag
    BIT     4, (IX+7)                       ; BIT 4 (IX+7): test escalator flag
    JR      NZ, LOC_87CA                    ; JR NZ LOC_87CA: on escalator -> reverse/wrap logic

LOC_875E:                                   ; LOC_875E: barrel movement collision check
    LD      HL, $70E2                       ; LD HL $70E2: pointer to floor collision threshold
    LD      A, (IX+11)                      ; LD A (IX+11): collision height
    OR      A                               ; OR A: test == 0
    JR      NZ, LOC_876D                    ; JR NZ LOC_876D: non-zero -> compare with floor
    LD      A, (IX+10)                      ; LD A (IX+10): collision width
    OR      A                               ; OR A: test == 0
    JR      Z, LOC_8774                     ; JR Z LOC_8774: both zero -> mark for removal

LOC_876D:                                   ; LOC_876D: compare barrel collision dims with floor threshold
    LD      A, (IX+10)                      ; LD A (IX+10): collision width
    DEC     A                               ; DEC A: width - 1
    CP      (HL)                            ; CP (HL): compare with floor threshold at $70E2
    JR      NC, LOC_8778                    ; JR NC LOC_8778: >= threshold -> keep going

LOC_8774:                                   ; LOC_8774: barrel below threshold; mark for removal
    LD      (IX+0), $15                     ; LD (IX+0) $15: set state $15 (removal marker)

LOC_8778:                                   ; LOC_8778: check collision flags for lateral movement
    BIT     2, (IX+9)                       ; BIT 2 (IX+9): test lateral collision flag
    JR      Z, LOC_87F8                     ; JR Z LOC_87F8: no collision -> deactivate check
    BIT     1, (IX+8)                       ; BIT 1 (IX+8): test move bit 1
    JR      NZ, LOC_87CA                    ; JR NZ LOC_87CA: set -> reverse path
    BIT     0, (IX+8)                       ; BIT 0 (IX+8): test move bit 0
    JR      NZ, LOC_878E                    ; JR NZ LOC_878E: set -> clear Y-vel
    LD      (IX+13), $00                    ; LD (IX+13) $00: clear Y-velocity

LOC_878E:                                   ; LOC_878E: check tumble/fall trigger conditions
    BIT     0, (IX+9)                       ; BIT 0 (IX+9): test fall trigger flag
    JR      Z, LOC_87CA                     ; JR Z LOC_87CA: clear -> reverse/wrap
    BIT     4, (IX+0)                       ; BIT 4 (IX+0): test fast-mode flag
    JP      NZ, LOC_8831                    ; JP NZ LOC_8831: fast mode -> skip tumble
    BIT     5, (IX+7)                       ; BIT 5 (IX+7): test tumble-active flag
    JP      NZ, LOC_8831                    ; JP NZ LOC_8831: already tumbling -> skip
    SET     5, (IX+7)                       ; SET 5 (IX+7): set tumble-active flag
    LD      A, $01                          ; LD A $01: seed for tumble delay shift
    LD      B, $00                          ; LD B $00: B = 0, will accumulate bit pattern

LOC_87AA:                                   ; LOC_87AA: build random tumble delay bitmask
    SCF                                     ; SCF: set carry
    RL      B                               ; RL B: rotate carry into B
    SRL     A                               ; SRL A: shift A right
    JR      NZ, LOC_87AA                    ; JR NZ LOC_87AA: loop until A==0
    LD      A, ($73C8)                      ; LD A ($73C8): read frame counter
    AND     B                               ; AND B: mask with tumble bitmask
    JP      NZ, LOC_8831                    ; JP NZ LOC_8831: not our frame -> skip tumble
    LD      (IX+6), $03                     ; LD (IX+6) $03: set lives/state to 3 (tumble state)
    SET     1, (IX+8)                       ; SET 1 (IX+8): set move bit 1
    LD      (IX+13), $01                    ; LD (IX+13) $01: set Y-velocity to 1 (fall)
    SET     4, (IX+7)                       ; SET 4 (IX+7): set animation bit 4
    JR      LOC_8831                        ; JR LOC_8831: done

LOC_87CA:                                   ; LOC_87CA: reverse or wrap barrel direction
    RES     5, (IX+7)                       ; RES 5 (IX+7): clear tumble flag
    BIT     1, (IX+9)                       ; BIT 1 (IX+9): test reverse flag
    JR      Z, LOC_87F8                     ; JR Z LOC_87F8: not set -> deactivate check
    XOR     A                               ; XOR A: A = 0
    CP      (IX+12)                         ; CP (IX+12): compare A with X-velocity
    JR      NZ, LOC_87F8                    ; JR NZ LOC_87F8: non-zero vel -> deactivate check
    LD      (IX+6), $00                     ; LD (IX+6) $00: clear lives/state
    BIT     1, (IX+7)                       ; BIT 1 (IX+7): test direction bit 1
    JR      Z, LOC_87EE                     ; JR Z LOC_87EE: clear -> set direction right
    LD      (IX+7), $04                     ; LD (IX+7) $04: animation frame 4
    LD      (IX+12), $02                    ; LD (IX+12) $02: X-velocity +2 (roll right)
    JR      LOC_8831                        ; JR LOC_8831

LOC_87EE:                                   ; LOC_87EE: set barrel rolling left
    LD      (IX+7), $02                     ; LD (IX+7) $02: animation frame 2 (roll left)
    LD      (IX+12), $FE                    ; LD (IX+12) $FE: X-velocity -2
    JR      LOC_8831                        ; JR LOC_8831

LOC_87F8:                                   ; LOC_87F8: deactivate check: test "done" flag
    BIT     2, (IX+8)                       ; BIT 2 (IX+8): test barrel-done flag
    JR      Z, LOC_8804                     ; JR Z LOC_8804: not done -> check edge position
    LD      (IX+0), $00                     ; LD (IX+0) $00: deactivate barrel slot
    JR      LOC_8831                        ; JR LOC_8831

LOC_8804:                                   ; LOC_8804: check barrel sprite Y position for edge fall
    CALL    SUB_8837                        ; CALL SUB_8837: get sprite IY ptr from IX sprite record
    PUSH    HL                              ; PUSH HL: save sprite record ptr
    INC     HL                              ; INC HL: advance to Y-position byte
    LD      A, (HL)                         ; LD A (HL): read sprite Y
    INC     HL                              ; INC HL: advance to next byte
    CP      $F2                             ; CP $F2: compare Y with $F2 (off-screen low)
    JR      NC, LOC_8814                    ; JR NC LOC_8814: >= $F2 -> check kill
    LD      A, (HL)                         ; LD A (HL): read next sprite byte
    CP      $FF                             ; CP $FF: compare with $FF (off-screen marker)
    JR      Z, LOC_881E                     ; JR Z LOC_881E: $FF -> kill barrel

LOC_8814:                                   ; LOC_8814: check $01 kill marker
    CP      $01                             ; CP $01
    JR      Z, LOC_881E                     ; JR Z LOC_881E: $01 -> kill barrel
    INC     HL                              ; INC HL: advance to X byte
    LD      A, (HL)                         ; LD A (HL): read sprite X
    CP      $C0                             ; CP $C0: compare X with $C0 (right edge)
    JR      C, LOC_8830                     ; JR C LOC_8830: X < $C0 -> still on screen

LOC_881E:                                   ; LOC_881E: kill barrel; write $CF/$00 to sprite record
    POP     HL                              ; POP HL: restore sprite record ptr
    INC     HL                              ; INC HL
    INC     HL                              ; INC HL: advance to Y field
    LD      (HL), $CF                       ; LD (HL) $CF: write kill-Y marker
    INC     HL                              ; INC HL
    LD      (HL), $00                       ; LD (HL) $00: clear next byte
    SET     2, (IX+8)                       ; SET 2 (IX+8): set done flag
    LD      (IX+13), $00                    ; LD (IX+13) $00: clear Y-velocity
    JR      LOC_8831                        ; JR LOC_8831

LOC_8830:                                   ; LOC_8830: barrel still on screen; pop saved HL
    POP     HL                              ; POP HL

LOC_8831:                                   ; LOC_8831: end of per-barrel update; advance to next slot
    POP     BC                              ; POP BC: restore loop counter
    DEC     B                               ; DEC B
    JP      NZ, LOC_86C5                    ; JP NZ LOC_86C5: more barrels -> loop
    RET                                     ; RET

SUB_8837:                                   ; SUB_8837: get sprite IY ptr from IX entity sprite record
    LD      L, (IX+1)                       ; LD L (IX+1): sprite ptr low from entity
    LD      H, (IX+2)                       ; LD H (IX+2): sprite ptr high
    PUSH    IY                              ; PUSH IY: save IY
    PUSH    HL                              ; PUSH HL
    POP     IY                              ; POP IY: IY -> sprite record
    LD      L, (IY+2)                       ; LD L (IY+2): sprite data ptr low
    LD      H, (IY+3)                       ; LD H (IY+3): sprite data ptr high
    POP     IY                              ; POP IY: restore IY
    RET                                     ; RET: HL = sprite data pointer

SUB_884B:                                   ; SUB_884B: get barrel throw direction based on X positions
    LD      HL, $7232                       ; LD HL $7232: pointer to Kong X reference
    LD      B, (HL)                         ; LD B (HL): B = Kong X reference
    CALL    SUB_8837                        ; CALL SUB_8837: get sprite ptr -> HL
    INC     HL                              ; INC HL
    INC     HL                              ; INC HL
    INC     HL                              ; INC HL: advance to X-position byte in sprite
    LD      A, (HL)                         ; LD A (HL): read barrel X position
    CP      $C0                             ; CP $C0: compare X with $C0 (right boundary)
    JR      C, LOC_885E                     ; JR C LOC_885E: X < $C0 -> check direction
    LD      (IX+0), $00                     ; LD (IX+0) $00: X >= $C0: deactivate barrel

LOC_885E:                                   ; LOC_885E: compare barrel X to Kong X
    DEC     HL                              ; DEC HL
    DEC     HL                              ; DEC HL: back to Y-position byte
    LD      A, (HL)                         ; LD A (HL): read barrel Y position
    SUB     B                               ; SUB B: barrel Y - Kong X reference
    JR      C, LOC_8867                     ; JR C LOC_8867: carry -> barrel left of Kong -> dir right
    LD      A, $FE                          ; LD A $FE: A = $FE (direction left, X-vel -2)
    RET                                     ; RET

LOC_8867:                                   ; LOC_8867: barrel is left of Kong -> direction right
    LD      A, $01                          ; LD A $01: A = $01 (direction right, X-vel +1)
    RET                                     ; RET

DELAY_LOOP_886A:                            ; DELAY_LOOP_886A: scan barrel slots; return 1 if any free
    LD      B, $04                          ; LD B $04: 4 barrel slots
    LD      DE, $0010                       ; LD DE $0010: stride = 16 bytes
    LD      HL, $70F4                       ; LD HL $70F4: IX -> first barrel slot

LOC_8872:                                   ; LOC_8872: check each barrel slot active flag
    BIT     0, (HL)                         ; BIT 0 (HL): test active flag
    JR      Z, LOC_887B                     ; JR Z LOC_887B: flag clear -> free slot found
    ADD     HL, DE                          ; ADD HL DE: advance HL by 16 (next slot)
    DJNZ    LOC_8872                        ; DJNZ LOC_8872: check all 4 slots
    XOR     A                               ; XOR A: all slots occupied -> A = 0
    RET                                     ; RET

LOC_887B:                                   ; LOC_887B: at least one free barrel slot
    LD      A, $01                          ; LD A $01: A = 1 (free slot exists)
    RET                                     ; RET

SUB_887E:                                   ; SUB_887E: clear 4-byte barrel velocity buffer at $7269
    LD      HL, $7269                       ; LD HL $7269: barrel velocity buffer
    SUB     A                               ; SUB A: fill value = 0
    LD      B, $04                          ; LD B $04: 4 bytes to clear
    JP      DELAY_LOOP_97FA                 ; JP DELAY_LOOP_97FA: fill; return

LOC_8887:                                   ; LOC_8887: update 4 fire entity sprites (level 0 Pauline/firebug)
    LD      A, ($716E)                      ; LD A ($716E): fire entity timer signal handle
    CALL    SUB_9A66                        ; CALL SUB_9A66: TEST_SIGNAL -> Z if not fired
    RET     Z                               ; RET Z: timer not fired -> skip update
    LD      IX, $7172                       ; LD IX $7172: IX -> first fire entity slot
    LD      IY, $70CC                       ; LD IY $70CC: IY -> fire animation table
    LD      DE, $0006                       ; LD DE $0006: stride = 6 bytes per entity slot
    LD      B, $04                          ; LD B $04: 4 fire entity slots

LOC_889B:                                   ; LOC_889B: per-fire-entity update loop
    PUSH    BC                              ; PUSH BC
    PUSH    DE                              ; PUSH DE
    LD      A, (IX+1)                       ; LD A (IX+1): read fire entity Y position
    CP      $38                             ; CP $38: compare Y with $38 (top zone)
    JR      NZ, LOC_88EB                    ; JR NZ LOC_88EB: Y != $38 -> check bottom path
    LD      A, (IX+3)                       ; LD A (IX+3): read fire entity X position
    CP      $4A                             ; CP $4A: compare X with $4A (left boundary)
    JR      NZ, LOC_88BF                    ; JR NZ LOC_88BF: X != $4A -> check middle logic
    ADD     A, $FE                          ; ADD A $FE: X -= 2
    LD      (IX+3), A                       ; LD (IX+3) A: update X position
    LD      HL, $8AD0                       ; LD HL $8AD0: animation frame table for this state
    LD      (IY+0), L                       ; LD (IY+0) L: store anim frame ptr low
    LD      (IY+1), H                       ; LD (IY+1) H: store anim frame ptr high
    LD      (IY+2), $00                     ; LD (IY+2) $00: reset frame index
    JR      LOC_88E6                        ; JR LOC_88E6

LOC_88BF:                                   ; LOC_88BF: check fire entity animation state
    LD      A, (IY+0)                       ; LD A (IY+0): read current anim ptr low
    CP      $D0                             ; CP $D0: compare with $D0 (default anim base)
    JR      NZ, LOC_88E0                    ; JR NZ LOC_88E0: not at base -> move entity
    LD      A, (IX+0)                       ; LD A (IX+0): read fire entity flags
    CP      $0C                             ; CP $0C: test if fully grown
    JR      NZ, LOC_88E6                    ; JR NZ LOC_88E6: not grown -> advance anim
    LD      (IX+3), $A6                     ; LD (IX+3) $A6: snap X to $A6 (right boundary)
    LD      HL, $8AC0                       ; LD HL $8AC0: new anim table ptr
    LD      (IY+0), L                       ; LD (IY+0) L
    LD      (IY+1), H                       ; LD (IY+1) H
    LD      (IY+2), $00                     ; LD (IY+2) $00: reset frame
    JR      LOC_88E6                        ; JR LOC_88E6

LOC_88E0:                                   ; LOC_88E0: slow fire entity movement (2-step decrement)
    DEC     (IX+3)                          ; DEC (IX+3): X -= 1
    DEC     (IX+3)                          ; DEC (IX+3): X -= 1

LOC_88E6:                                   ; LOC_88E6: advance fire animation frame
    CALL    SUB_8967                        ; CALL SUB_8967: step animation from IY table -> IX+0
    JR      LOC_893D                        ; JR LOC_893D: continue to next entity

LOC_88EB:                                   ; LOC_88EB: fire entity at lower zone (Y != $38)
    LD      A, (IX+3)                       ; LD A (IX+3): read fire X position
    CP      $9E                             ; CP $9E: compare X with $9E (right side)
    JR      NZ, LOC_8906                    ; JR NZ LOC_8906: X != $9E -> check upward movement
    ADD     A, $02                          ; ADD A $02: X += 2
    LD      (IX+3), A                       ; LD (IX+3) A: update X
    LD      HL, $8AEA                       ; LD HL $8AEA: anim table for this state
    LD      (IY+0), L                       ; LD (IY+0) L
    LD      (IY+1), H                       ; LD (IY+1) H
    LD      (IY+2), $00                     ; LD (IY+2) $00: reset frame
    JR      LOC_893A                        ; JR LOC_893A

LOC_8906:                                   ; LOC_8906: check fire entity upper animation state
    LD      A, (IY+0)                       ; LD A (IY+0): read anim ptr low
    CP      $EA                             ; CP $EA: compare with $EA anim base
    JR      NZ, LOC_8927                    ; JR NZ LOC_8927: not at $EA base -> check growth
    LD      A, (IX+0)                       ; LD A (IX+0): read entity flags
    CP      $0C                             ; CP $0C: test if grown
    JR      NZ, LOC_88E6                    ; JR NZ LOC_88E6: not grown -> advance anim
    LD      (IX+3), $48                     ; LD (IX+3) $48: snap X to $48
    LD      HL, $8ADA                       ; LD HL $8ADA: new anim table
    LD      (IY+0), L                       ; LD (IY+0) L
    LD      (IY+1), H                       ; LD (IY+1) H
    LD      (IY+2), $00                     ; LD (IY+2) $00: reset frame
    JR      LOC_893A                        ; JR LOC_893A

LOC_8927:                                   ; LOC_8927: check fire entity upward movement
    LD      A, (IX+0)                       ; LD A (IX+0): read entity flags
    CP      $05                             ; CP $05: compare with grown stage
    JR      NZ, LOC_8934                    ; JR NZ LOC_8934: not $05 -> increment X
    LD      (IX+3), $48                     ; LD (IX+3) $48: snap X to $48
    JR      LOC_893A                        ; JR LOC_893A

LOC_8934:                                   ; LOC_8934: increment fire entity X (move right 2)
    INC     (IX+3)                          ; INC (IX+3): X += 1
    INC     (IX+3)                          ; INC (IX+3): X += 1

LOC_893A:                                   ; LOC_893A: advance fire animation frame
    CALL    SUB_8967                        ; CALL SUB_8967: step animation

LOC_893D:                                   ; LOC_893D: advance to next fire entity slot
    POP     DE                              ; POP DE: restore stride
    POP     BC                              ; POP BC: restore loop counter
    ADD     IX, DE                          ; ADD IX DE: IX += 6 (next fire entity)
    INC     IY                              ; INC IY: advance IY anim table ptr
    INC     IY                              ; INC IY
    INC     IY                              ; INC IY
    DEC     B                               ; DEC B: decrement entity counter
    JP      NZ, LOC_889B                    ; JP NZ LOC_889B: more entities -> loop
    LD      IX, $B55C                       ; LD IX $B55C: fire sprite descriptor 0
    CALL    PUTOBJ                          ; CALL PUTOBJ: position fire sprite 0
    LD      IX, $B562                       ; LD IX $B562: fire sprite descriptor 1
    CALL    PUTOBJ                          ; CALL PUTOBJ: position fire sprite 1
    LD      IX, $B568                       ; LD IX $B568: fire sprite descriptor 2
    CALL    PUTOBJ                          ; CALL PUTOBJ: position fire sprite 2
    LD      IX, $B56E                       ; LD IX $B56E: fire sprite descriptor 3
    JP      PUTOBJ                          ; JP PUTOBJ: position fire sprite 3; return

SUB_8967:                                   ; SUB_8967: step one animation frame from IY table -> IX+0
    LD      L, (IY+0)                       ; LD L (IY+0): anim table ptr low
    LD      H, (IY+1)                       ; LD H (IY+1): anim table ptr high
    LD      E, (IY+2)                       ; LD E (IY+2): current frame index
    LD      D, $00                          ; LD D $00: D = 0 for 16-bit offset
    ADD     HL, DE                          ; ADD HL DE: HL = table base + frame index
    ADD     HL, DE                          ; ADD HL DE: HL += frame index again (stride 2)
    LD      A, (HL)                         ; LD A (HL): read frame tile byte
    LD      (IX+0), A                       ; LD (IX+0) A: write tile to entity flags
    INC     HL                              ; INC HL
    LD      A, (HL)                         ; LD A (HL): read next-frame index
    LD      (IY+2), A                       ; LD (IY+2) A: update frame index in IY
    RET                                     ; RET

SUB_897E:                                   ; SUB_897E: init 4 enemy sprite slots with random start positions
    LD      HL, $8A3E                       ; LD HL $8A3E: entity init table (level 0)
    LD      A, ($702C)                      ; LD A ($702C): read level type
    OR      A                               ; OR A: test == 0
    JR      Z, LOC_898A                     ; JR Z LOC_898A: level 0 -> use $8A3E table
    LD      HL, $8A46                       ; LD HL $8A46: entity init table (other levels)

LOC_898A:                                   ; LOC_898A: EXX to alt regs; set up IY ptr table
    EXX                                     ; EXX: switch to alt BC,DE,HL (HL = init table)
    LD      IY, $B62A                       ; LD IY $B62A: IY -> entity sprite ptr table
    LD      B, $04                          ; LD B $04: 4 entity slots

LOC_8991:                                   ; LOC_8991: per-entity init loop
    PUSH    BC                              ; PUSH BC
    LD      HL, $0002                       ; LD HL $0002: Y range = 2 (level 0)
    LD      A, ($702C)                      ; LD A ($702C): read level type
    OR      A                               ; OR A: test == 0
    JR      Z, LOC_899E                     ; JR Z LOC_899E: level 0 -> use range 2
    LD      HL, $0005                       ; LD HL $0005: Y range = 5 (other levels)

LOC_899E:                                   ; LOC_899E: REQUEST_SIGNAL for entity Y start position
    CALL    SUB_99A1                        ; CALL SUB_99A1: REQUEST_SIGNAL (A=1) with HL range -> A
    PUSH    AF                              ; PUSH AF: save Y position
    LD      HL, $0004                       ; LD HL $0004: X range = 4 (level 0)
    LD      A, ($702C)                      ; LD A ($702C): read level type
    OR      A                               ; OR A: test == 0
    JR      Z, LOC_89AE                     ; JR Z LOC_89AE: level 0 -> use range 4
    LD      HL, $0005                       ; LD HL $0005: X range = 5

LOC_89AE:                                   ; LOC_89AE: REQUEST_SIGNAL for entity X start position
    CALL    SUB_99A1                        ; CALL SUB_99A1: REQUEST_SIGNAL -> X position in A
    LD      L, (IY+0)                       ; LD L (IY+0): entity ptr low
    LD      H, (IY+1)                       ; LD H (IY+1): entity ptr high
    INC     IY                              ; INC IY
    INC     IY                              ; INC IY: advance IY to next ptr
    PUSH    HL                              ; PUSH HL
    POP     IX                              ; POP IX: IX -> entity struct
    LD      (IX+3), A                       ; LD (IX+3) A: set entity Y start position
    POP     AF                              ; POP AF: restore X position
    LD      (IX+14), A                      ; LD (IX+14) A: set entity timer/anim start
    LD      HL, $8A4E                       ; LD HL $8A4E: entity animation table (level 0)
    LD      A, ($702C)                      ; LD A ($702C): read level type
    OR      A                               ; OR A: test == 0
    JR      Z, LOC_89D1                     ; JR Z LOC_89D1: level 0 -> use $8A4E
    LD      HL, $B626                       ; LD HL $B626: entity anim table (other levels)

LOC_89D1:                                   ; LOC_89D1: store entity animation table; set entity fields
    LD      (IX+4), L                       ; LD (IX+4) L: anim table ptr low
    LD      (IX+5), H                       ; LD (IX+5) H: anim table ptr high
    LD      (IX+0), $04                     ; LD (IX+0) $04: entity active flag = $04
    LD      (IX+8), $00                     ; LD (IX+8) $00: clear move-flags
    EXX                                     ; EXX: switch to alt regs (HL = init table)
    LD      E, (HL)                         ; LD E (HL): sprite ptr low from init table
    LD      (IX+1), E                       ; LD (IX+1) E: store sprite ptr low
    INC     HL                              ; INC HL
    LD      D, (HL)                         ; LD D (HL): sprite ptr high
    LD      (IX+2), D                       ; LD (IX+2) D: store sprite ptr high
    INC     HL                              ; INC HL: advance init table
    PUSH    DE                              ; PUSH DE
    EXX                                     ; EXX: back to main regs
    POP     HL                              ; POP HL: HL = sprite ptr
    PUSH    IY                              ; PUSH IY
    PUSH    HL                              ; PUSH HL: save sprite ptr
    PUSH    DE                              ; PUSH DE
    INC     HL                              ; INC HL
    INC     HL                              ; INC HL: advance to sprite Y field
    LD      E, (HL)                         ; LD E (HL): sprite Y byte
    INC     HL                              ; INC HL
    LD      D, (HL)                         ; LD D (HL): sprite attr byte
    DB      $EB                             ; DB $EB: EX DE,HL (HL = sprite Y)
    INC     HL                              ; INC HL
    INC     HL                              ; INC HL
    INC     HL                              ; INC HL: advance to sprite kill marker
    LD      (HL), $CF                       ; LD (HL) $CF: write kill-Y marker to sprite
    INC     HL                              ; INC HL
    LD      (HL), $00                       ; LD (HL) $00: clear next byte
    POP     DE                              ; POP DE
    POP     HL                              ; POP HL: HL = sprite ptr
    PUSH    HL                              ; PUSH HL
    OR      A                               ; OR A: clear carry
    CALL    ACTIVATE                        ; CALL ACTIVATE: BIOS activate sprite slot at IY
    POP     HL                              ; POP HL: restore sprite ptr
    PUSH    IX                              ; PUSH IX: save entity IX
    PUSH    HL                              ; PUSH HL
    POP     IX                              ; POP IX: IX = sprite ptr
    CALL    PUTOBJ                          ; CALL PUTOBJ: BIOS position sprite
    POP     IX                              ; POP IX: restore entity IX
    POP     IY                              ; POP IY: restore IY
    POP     BC                              ; POP BC: restore loop counter
    DEC     B                               ; DEC B
    JP      NZ, LOC_8991                    ; JP NZ LOC_8991: more entities -> loop
    LD      A, ($702C)                      ; LD A ($702C): read level type
    OR      A                               ; OR A: test == 0
    RET     Z                               ; RET Z: level 0 -> done
    LD      HL, $0002                       ; LD HL $0002: signal range for extra entity
    CALL    SUB_99A5                        ; CALL SUB_99A5: REQUEST_SIGNAL (A=0) -> handle in A
    LD      HL, $70F4                       ; LD HL $70F4: barrel entity slot base
    LD      DE, $0007                       ; LD DE $0007: offset to extra slot
    ADD     HL, DE                          ; ADD HL DE: HL -> extra slot
    LD      (HL), A                         ; LD (HL) A: store signal handle
    LD      HL, $0064                       ; LD HL $0064: 100 ticks for extra signal
    CALL    SUB_99A1                        ; CALL SUB_99A1: REQUEST_SIGNAL -> A
    LD      ($714B), A                      ; LD ($714B) A: save extra timer signal handle
    RET                                     ; RET
    DB      $03, $03, $03, $04, $04, $05, $05, $05 ; DB: entity init table data bytes
    DB      $05, $2A, $B5, $2F, $B5, $34, $B5, $39 ; DB: entity init table data continued
    DB      $B5, $D1, $B5, $D6, $B5, $DB, $B5, $E0 ; DB: entity init table data continued
    DB      $B5, $00, $01, $01, $02, $02, $00, $03 ; DB: entity init table data continued
    DB      $04, $04, $05, $05, $03, $03, $01, $04 ; DB: entity init table data continued
    DB      $02, $05, $00                   ; DB: entity init table data continued

SUB_8A60:                                   ; SUB_8A60: init level-2 (rivet) firebird entity and sprites
    LD      HL, $0004                       ; LD HL $0004: signal range = 4
    CALL    SUB_99A1                        ; CALL SUB_99A1: REQUEST_SIGNAL -> firebird count in A
    LD      ($716E), A                      ; LD ($716E) A: save firebird active count signal
    LD      HL, $70CC                       ; LD HL $70CC: firebird animation state base
    LD      DE, $8AC0                       ; LD DE $8AC0: firebird anim table ptr A
    CALL    DELAY_LOOP_8AB4                 ; CALL DELAY_LOOP_8AB4: fill 2 firebird anim slots from DE
    LD      DE, $8ADA                       ; LD DE $8ADA: firebird anim table ptr B
    CALL    DELAY_LOOP_8AB4                 ; CALL DELAY_LOOP_8AB4: fill 2 more anim slots
    LD      HL, $B55C                       ; LD HL $B55C: firebird sprite-0 IY descriptor
    OR      A                               ; OR A: clear carry
    CALL    ACTIVATE                        ; CALL ACTIVATE: BIOS activate sprite-0
    LD      HL, $B562                       ; LD HL $B562: firebird sprite-1
    OR      A                               ; OR A
    CALL    ACTIVATE                        ; CALL ACTIVATE: BIOS activate sprite-1
    LD      HL, $B568                       ; LD HL $B568: firebird sprite-2
    OR      A                               ; OR A
    CALL    ACTIVATE                        ; CALL ACTIVATE: BIOS activate sprite-2
    LD      HL, $B56E                       ; LD HL $B56E: firebird sprite-3
    OR      A                               ; OR A
    CALL    ACTIVATE                        ; CALL ACTIVATE: BIOS activate sprite-3
    LD      B, $04                          ; LD B $04: 4 entity slots
    LD      HL, $8AAC                       ; LD HL $8AAC: firebird start position table
    LD      DE, $7173                       ; LD DE $7173: firebird entity X/Y data
    XOR     A                               ; XOR A: A = 0 (zero fill for extra fields)

LOC_8A9D:                                   ; LOC_8A9D: copy 4 firebird start positions from table to RAM
    PUSH    BC                              ; PUSH BC
    LDI                                     ; LDI: copy X byte from table
    LD      (DE), A                         ; LD (DE) A: clear extra byte
    INC     DE                              ; INC DE
    LDI                                     ; LDI: copy Y byte from table
    LD      (DE), A                         ; LD (DE) A: clear extra byte
    INC     DE                              ; INC DE
    INC     DE                              ; INC DE
    INC     DE                              ; INC DE
    POP     BC                              ; POP BC
    DJNZ    LOC_8A9D                        ; DJNZ LOC_8A9D: loop 4 entities
    RET                                     ; RET
    DB      $38, $90, $38, $60, $7C, $8E, $7C, $5E ; DB: firebird start position table data

DELAY_LOOP_8AB4:                            ; DELAY_LOOP_8AB4: fill 2 animation table entries at HL with ptr DE
    LD      B, $02                          ; LD B $02: 2 entries to fill

LOC_8AB6:                                   ; LOC_8AB6: write one animation entry (ptr + frame count)
    LD      (HL), E                         ; LD (HL) E: write DE ptr low
    INC     HL                              ; INC HL
    LD      (HL), D                         ; LD (HL) D: write DE ptr high
    INC     HL                              ; INC HL
    LD      (HL), $04                       ; LD (HL) $04: write frame count = 4
    INC     HL                              ; INC HL
    DJNZ    LOC_8AB6                        ; DJNZ LOC_8AB6: loop 2 entries
    RET                                     ; RET
    DB      $08, $01, $07, $02, $06, $03, $05, $04 ; DB: firebird movement/animation data
    DB      $01, $05, $02, $06, $03, $07, $04, $04 ; DB: firebird movement data continued
    DB      $04, $01, $09, $02, $0A, $03, $0B, $04 ; DB: firebird movement data continued
    DB      $0C, $04, $0B, $01, $0A, $02, $09, $03 ; DB: firebird movement data continued
    DB      $05, $04, $03, $05, $02, $06, $01, $07 ; DB: firebird movement data continued
    DB      $00, $04, $06, $01, $07, $02, $08, $03 ; DB: firebird movement data continued
    DB      $0C, $03                        ; DB: firebird movement data continued

SUB_8AF2:                                   ; SUB_8AF2: route bonus/enemy init by level type
    LD      A, ($702C)                      ; LD A ($702C): read level type
    OR      A                               ; OR A: test == 0 (girder)
    JR      Z, LOC_8AFE                     ; JR Z LOC_8AFE: level 0 -> Pauline/bonus init
    CP      $02                             ; CP $02: test level type 2 (rivet)
    CALL    Z, SUB_8A60                     ; CALL Z SUB_8A60: level 2 -> init firebird entity
    RET                                     ; RET

LOC_8AFE:                                   ; LOC_8AFE: level 0 Pauline/bonus entity init
    LD      HL, $8C40                       ; LD HL $8C40: Pauline anim state table
    LD      ($7170), HL                     ; LD ($7170) HL: store anim state ptr
    LD      HL, $0028                       ; LD HL $0028: Y range = 40
    CALL    SUB_99A1                        ; CALL SUB_99A1: REQUEST_SIGNAL -> Y position
    LD      ($716E), A                      ; LD ($716E) A: save Y signal handle
    LD      ($716D), A                      ; LD ($716D) A: save copy
    LD      HL, $0050                       ; LD HL $0050: X range = 80
    CALL    SUB_99A1                        ; CALL SUB_99A1: REQUEST_SIGNAL -> X position
    LD      ($716C), A                      ; LD ($716C) A: save X signal handle
    RET                                     ; RET

SUB_8B1A:                                   ; SUB_8B1A: dispatch Pauline/fireball update by level type
    LD      A, ($702C)                      ; LD A ($702C): read level type
    CP      $02                             ; CP $02: level 2 (rivet)?
    JP      Z, LOC_8887                     ; JP Z LOC_8887: level 2 -> firebird update
    OR      A                               ; OR A: test == 0 (girder)
    RET     NZ                              ; RET NZ: not level 0 -> return
    LD      A, ($716E)                      ; LD A ($716E): Pauline Y signal handle
    CALL    SUB_9A66                        ; CALL SUB_9A66: TEST_SIGNAL -> Z if not fired
    RET     Z                               ; RET Z: timer not fired -> skip
    CALL    SUB_9956                        ; CALL SUB_9956: RAND_GEN for Pauline behavior
    LD      A, ($7170)                      ; LD A ($7170): read Pauline state ptr low
    CP      $40                             ; CP $40: test state $40 (initial)
    JR      NZ, LOC_8B47                    ; JR NZ LOC_8B47: not $40 -> check other states
    CALL    DELAY_LOOP_886A                 ; CALL DELAY_LOOP_886A: check if any barrel slot free
    CP      $01                             ; CP $01: test result == 1
    RET     NZ                              ; RET NZ: no free slot -> return
    LD      HL, $8C48                       ; LD HL $8C48: next state ptr
    LD      ($7170), HL                     ; LD ($7170) HL: advance state to $8C48
    LD      A, $00                          ; LD A $00
    LD      ($716F), A                      ; LD ($716F) A: reset state phase to 0
    RET                                     ; RET

LOC_8B47:                                   ; LOC_8B47: check state $42 (barrel throw phase)
    LD      A, ($7170)                      ; LD A ($7170): read state ptr low
    CP      $42                             ; CP $42: test state $42
    JR      NZ, LOC_8B99                    ; JR NZ LOC_8B99: not $42 -> check $48
    LD      A, ($716F)                      ; LD A ($716F): read state phase
    CP      $00                             ; CP $00: test phase 0
    JR      NZ, LOC_8B60                    ; JR NZ LOC_8B60: not phase 0 -> phase 1
    LD      BC, $20E0                       ; LD BC $20E0: barrel params (size/speed)
    LD      A, $9C                          ; LD A $9C: barrel spawn state
    CALL    SUB_8C50                        ; CALL SUB_8C50: store barrel params in $7269
    JP      LOC_8C24                        ; JP LOC_8C24: update Pauline PUTOBJ and advance state

LOC_8B60:                                   ; LOC_8B60: barrel throw phase 1
    CP      $01                             ; CP $01: test phase 1
    JR      NZ, LOC_8B8C                    ; JR NZ LOC_8B8C: not phase 1 -> phase other
    LD      BC, $17C8                       ; LD BC $17C8: barrel second-row params
    LD      A, $AC                          ; LD A $AC: barrel state $AC
    CALL    SUB_8C50                        ; CALL SUB_8C50: store barrel params
    LD      DE, $C817                       ; LD DE $C817: barrel velocity DE
    LD      B, $FE                          ; LD B $FE: B = $FE (direction left)
    LD      A, $F5                          ; LD A $F5: barrel spawn flags
    CALL    DELAY_LOOP_8639                 ; CALL DELAY_LOOP_8639: find free barrel slot; init with A,B,C
    CALL    SUB_884B                        ; CALL SUB_884B: determine barrel X-velocity direction
    LD      (IX+12), A                      ; LD (IX+12) A: set barrel X-velocity
    LD      DE, $8A5A                       ; LD DE $8A5A: barrel animation table
    LD      (IX+4), E                       ; LD (IX+4) E: set barrel anim ptr low
    LD      (IX+5), D                       ; LD (IX+5) D: set barrel anim ptr high
    LD      (IX+9), $00                     ; LD (IX+9) $00: clear barrel state flags
    JP      LOC_8C24                        ; JP LOC_8C24: update Pauline PUTOBJ

LOC_8B8C:                                   ; LOC_8B8C: reset state to initial $8C40
    LD      HL, $8C40                       ; LD HL $8C40: initial state ptr
    LD      ($7170), HL                     ; LD ($7170) HL: reset state
    XOR     A                               ; XOR A
    LD      ($716F), A                      ; LD ($716F) A: reset phase
    JP      LOC_8C24                        ; JP LOC_8C24: update Pauline PUTOBJ

LOC_8B99:                                   ; LOC_8B99: check state $48 (Pauline distress cry)
    LD      A, ($7170)                      ; LD A ($7170): read state ptr low
    CP      $48                             ; CP $48: test state $48
    JP      NZ, LOC_8C24                    ; JP NZ LOC_8C24: not $48 -> update PUTOBJ only
    LD      A, ($716F)                      ; LD A ($716F): read phase
    CP      $00                             ; CP $00: test phase 0
    JR      NZ, LOC_8BB2                    ; JR NZ LOC_8BB2: not phase 0 -> phase 1
    LD      BC, $20E0                       ; LD BC $20E0: distress animation params
    LD      A, $9C                          ; LD A $9C: distress state code
    CALL    SUB_8C50                        ; CALL SUB_8C50: store params
    JR      LOC_8C24                        ; JR LOC_8C24

LOC_8BB2:                                   ; LOC_8BB2: distress phase 1
    LD      A, ($716F)                      ; LD A ($716F): read phase
    CP      $01                             ; CP $01
    JR      NZ, LOC_8BC3                    ; JR NZ LOC_8BC3: not phase 1 -> phase 2
    LD      BC, $17C8                       ; LD BC $17C8: distress phase 1 params
    LD      A, $AC                          ; LD A $AC
    CALL    SUB_8C50                        ; CALL SUB_8C50: store params
    JR      LOC_8C24                        ; JR LOC_8C24

LOC_8BC3:                                   ; LOC_8BC3: distress phase 2
    LD      A, ($716F)                      ; LD A ($716F): read phase
    CP      $02                             ; CP $02
    JR      NZ, LOC_8BE1                    ; JR NZ LOC_8BE1: not phase 2 -> phase 3
    LD      B, $00                          ; LD B $00
    LD      C, $FE                          ; LD C $FE: barrel dir C=$FE (left)
    LD      DE, $B01D                       ; LD DE $B01D: barrel data ptr
    LD      A, $25                          ; LD A $25: barrel spawn flags
    CALL    DELAY_LOOP_8639                 ; CALL DELAY_LOOP_8639: spawn barrel in free slot
    LD      DE, $8A4E                       ; LD DE $8A4E: barrel anim table
    LD      (IX+4), E                       ; LD (IX+4) E: store anim ptr low
    LD      (IX+5), D                       ; LD (IX+5) D: store anim ptr high
    JR      LOC_8C24                        ; JR LOC_8C24

LOC_8BE1:                                   ; LOC_8BE1: distress phase 3; choose Pauline cry interval
    LD      A, ($716F)                      ; LD A ($716F): read phase
    CP      $03                             ; CP $03
    JR      NZ, LOC_8C24                    ; JR NZ LOC_8C24: not phase 3 -> skip
    XOR     A                               ; XOR A
    LD      ($716F), A                      ; LD ($716F) A: reset phase
    LD      HL, $8C40                       ; LD HL $8C40: reset state ptr
    LD      ($7170), HL                     ; LD ($7170) HL
    LD      B, $03                          ; LD B $03: default interval = 3
    LD      A, ($70A6)                      ; LD A ($70A6): read difficulty
    CP      $04                             ; CP $04: compare with difficulty 4
    JR      Z, LOC_8C04                     ; JR Z LOC_8C04: == 4 -> random interval
    JR      NC, LOC_8C19                    ; JR NC LOC_8C19: > 4 -> harder interval
    SUB     $04                             ; SUB $04: A = 4 - difficulty
    NEG                                     ; NEG: negate to get countdown value
    LD      B, A                            ; LD B A: B = difficulty-based interval
    JR      LOC_8C0D                        ; JR LOC_8C0D

LOC_8C04:                                   ; LOC_8C04: difficulty 4: random cry interval
    LD      A, ($73C8)                      ; LD A ($73C8): read frame counter
    AND     $07                             ; AND $07: mask low 3 bits
    JR      Z, LOC_8C1E                     ; JR Z LOC_8C1E: zero -> use slow interval
    JR      LOC_8C19                        ; JR LOC_8C19: non-zero -> use hard interval

LOC_8C0D:                                   ; LOC_8C0D: count down B using frame counter
    LD      A, ($73C8)                      ; LD A ($73C8): read frame counter
    AND     $07                             ; AND $07: mask low 3 bits
    JR      Z, LOC_8C1E                     ; JR Z LOC_8C1E: zero -> slow interval

LOC_8C14:                                   ; LOC_8C14: decrement B counter loop
    DEC     A                               ; DEC A
    JR      Z, LOC_8C1E                     ; JR Z LOC_8C1E: A==0 -> slow interval
    DJNZ    LOC_8C14                        ; DJNZ LOC_8C14: count down B

LOC_8C19:                                   ; LOC_8C19: load fast cry interval from $716D
    LD      A, ($716D)                      ; LD A ($716D): fast/normal cry interval
    JR      LOC_8C21                        ; JR LOC_8C21

LOC_8C1E:                                   ; LOC_8C1E: load slow cry interval from $716C
    LD      A, ($716C)                      ; LD A ($716C): slow cry interval

LOC_8C21:                                   ; LOC_8C21: store cry interval as new timer handle
    LD      ($716E), A                      ; LD ($716E) A: save new cry interval signal

LOC_8C24:                                   ; LOC_8C24: update Pauline PUTOBJ; advance state phase counter
    LD      DE, $71CD                       ; LD DE $71CD: Pauline PUTOBJ tile field
    LD      HL, ($7170)                     ; LD HL ($7170): load state ptr
    LD      A, ($716F)                      ; LD A ($716F): read phase counter
    LD      C, A                            ; LD C A: C = phase
    LD      B, $00                          ; LD B $00
    ADD     HL, BC                          ; ADD HL BC: HL = state table + phase
    ADD     HL, BC                          ; ADD HL BC: HL += phase again (stride 2)
    LD      A, (HL)                         ; LD A (HL): read tile byte from state table
    LD      (DE), A                         ; LD (DE) A: write to PUTOBJ tile field
    INC     HL                              ; INC HL
    LD      A, (HL)                         ; LD A (HL): read next-phase index
    LD      ($716F), A                      ; LD ($716F) A: advance phase counter
    LD      IX, $B43D                       ; LD IX $B43D: Pauline PUTOBJ descriptor
    JP      PUTOBJ                          ; JP PUTOBJ: position/display Pauline; return
    DB      $00, $00, $02, $01, $00, $02, $00, $00 ; DB: Pauline state machine transition table
    DB      $02, $01, $00, $02, $01, $03, $03, $00 ; DB: state table data continued

SUB_8C50:                                   ; SUB_8C50: store 4-byte entity params at $7269
    LD      HL, $7269                       ; LD HL $7269: entity param buffer
    LD      (HL), B                         ; LD (HL) B: write byte 0 (param B)
    INC     HL                              ; INC HL
    LD      (HL), C                         ; LD (HL) C: write byte 1 (param C)
    INC     HL                              ; INC HL
    LD      (HL), A                         ; LD (HL) A: write byte 2 (state code A)
    INC     HL                              ; INC HL
    LD      (HL), $06                       ; LD (HL) $06: write byte 3 = $06 (param count)
    RET                                     ; RET

SUB_8C5C:                                   ; SUB_8C5C: iterate 2 barrel entities with SUB_8C71 (X/Y check)
    LD      DE, $0002                       ; LD DE $0002: 2 entities to check

LOC_8C5F:                                   ; LOC_8C5F: per-entity loop
    PUSH    DE                              ; PUSH DE
    PUSH    HL                              ; PUSH HL: save entity table ptr
    CALL    SUB_982B                        ; CALL SUB_982B: HL = entity ptr from table[E]
    PUSH    HL                              ; PUSH HL
    POP     IX                              ; POP IX: IX -> entity struct
    CALL    SUB_8C71                        ; CALL SUB_8C71: check entity X/Y vs Kong
    POP     HL                              ; POP HL: restore table ptr
    POP     DE                              ; POP DE
    DEC     E                               ; DEC E
    JP      P, LOC_8C5F                     ; JP P LOC_8C5F: E >= 0 -> more entities
    RET                                     ; RET

SUB_8C71:                                   ; SUB_8C71: check barrel X vs Kong X; set Pauline kill if overlap
    CALL    SUB_964D                        ; CALL SUB_964D: load IY=pos table for barrel at IX
    LD      A, ($7135)                      ; LD A ($7135): Kong X position
    LD      B, (IY+1)                       ; LD B (IY+1): barrel left-edge X
    CALL    SUB_9628                        ; CALL SUB_9628: compute X overlap -> A
    LD      B, $02                          ; LD B $02: X tolerance = 2
    CALL    SUB_96F4                        ; CALL SUB_96F4: compare overlap A with tolerance B
    RET     P                               ; RET P: overlap positive (too far) -> no hit
    LD      A, (IY+0)                       ; LD A (IY+0): barrel flags
    OR      A                               ; OR A: test barrel active
    RET     NZ                              ; RET NZ: barrel not active -> no kill
    LD      A, ($7137)                      ; LD A ($7137): Kong Y position
    LD      B, (IY+3)                       ; LD B (IY+3): barrel top-edge Y
    CALL    SUB_9628                        ; CALL SUB_9628: compute Y overlap -> A
    LD      B, $09                          ; LD B $09: Y tolerance = 9
    CALL    SUB_96F4                        ; CALL SUB_96F4: compare Y overlap
    RET     P                               ; RET P: too far -> no hit
    LD      B, $09                          ; LD B $09: sound channel 9 for collision
    CALL    SUB_9930                        ; CALL SUB_9930: PLAY_IT collision sound ch9
    LD      BC, $001E                       ; LD BC $001E: score = 30
    CALL    SUB_9A74                        ; CALL SUB_9A74: add score to accumulator
    LD      (IY+0), $01                     ; LD (IY+0) $01: mark barrel as hit
    JP      PUTOBJ                          ; JP PUTOBJ: update Pauline sprite; return

SUB_8CA9:                                   ; SUB_8CA9: check Kong-to-ladder collision for Pauline kill
    LD      HL, $B678                       ; LD HL $B678: ladder entity table
    CALL    SUB_982B                        ; CALL SUB_982B: HL -> ladder struct at E
    PUSH    HL                              ; PUSH HL
    POP     IY                              ; POP IY: IY -> ladder struct
    LD      A, (IY+3)                       ; LD A (IY+3): ladder top Y
    SUB     $10                             ; SUB $10: ladder Y - 16
    LD      B, A                            ; LD B A: B = adjusted Y
    LD      A, ($7137)                      ; LD A ($7137): Kong Y
    CALL    SUB_96F4                        ; CALL SUB_96F4: compare Kong Y vs ladder Y
    RET     P                               ; RET P: Kong too high -> no hit
    LD      C, A                            ; LD C A: C = Y delta
    LD      A, ($70E5)                      ; LD A ($70E5): Kong height param
    ADD     A, C                            ; ADD A C: combine deltas
    ADD     A, $03                          ; ADD A $03: add tolerance
    CALL    SUB_96F4                        ; CALL SUB_96F4: check total delta
    RET     M                               ; RET M: too much delta -> no hit
    LD      A, B                            ; LD A B: A = adjusted ladder Y
    LD      ($7137), A                      ; LD ($7137) A: update Kong Y to ladder Y
    LD      HL, $70E1                       ; LD HL $70E1: pointer to Kong state flags
    SET     6, (HL)                         ; SET 6 (HL): set flag 6 (Kong hit ladder)
    LD      ($70E8), IY                     ; LD ($70E8) IY: save ladder IY ptr
    JP      SUB_8ED0                        ; JP SUB_8ED0: enter Kong-climbing sequence

SUB_8CDA:                                   ; SUB_8CDA: iterate 3 barrel entities with SUB_8CEF
    LD      DE, $0003                       ; LD DE $0003: 3 entities to check (E=3)

LOC_8CDD:                                   ; LOC_8CDD: per-entity loop
    PUSH    DE                              ; PUSH DE
    PUSH    HL                              ; PUSH HL: save entity table ptr
    CALL    SUB_982B                        ; CALL SUB_982B: HL = entity ptr from table
    PUSH    HL                              ; PUSH HL
    POP     IX                              ; POP IX: IX -> entity struct
    CALL    SUB_8CEF                        ; CALL SUB_8CEF: Y/X overlap check for player kill
    POP     HL                              ; POP HL: restore table ptr
    POP     DE                              ; POP DE
    DEC     E                               ; DEC E
    JP      P, LOC_8CDD                     ; JP P LOC_8CDD: E >= 0 -> loop
    RET                                     ; RET

SUB_8CEF:                                   ; SUB_8CEF: barrel-to-player Y/X kill check
    BIT     0, (IX+0)                       ; BIT 0 (IX+0): test barrel active flag
    RET     Z                               ; RET Z: not active -> no check
    CALL    SUB_9648                        ; CALL SUB_9648: load IY = player position table
    LD      B, (IY+1)                       ; LD B (IY+1): barrel right-edge X
    LD      A, ($7135)                      ; LD A ($7135): player X position
    CALL    SUB_9628                        ; CALL SUB_9628: compute X delta -> A
    LD      B, $07                          ; LD B $07: X tolerance = 7
    CALL    SUB_96F4                        ; CALL SUB_96F4: compare X delta
    RET     P                               ; RET P: X too far -> no hit
    LD      A, ($7137)                      ; LD A ($7137): player Y
    LD      B, (IY+3)                       ; LD B (IY+3): barrel bottom Y
    CALL    SUB_9628                        ; CALL SUB_9628: compute Y delta -> A
    LD      B, $07                          ; LD B $07: Y tolerance = 7
    CALL    SUB_96F4                        ; CALL SUB_96F4: compare Y delta
    JR      NC, LOC_8D3A                    ; JR NC LOC_8D3A: hit! -> check platform kill
    LD      A, ($70E0)                      ; LD A ($70E0): read kill flags
    BIT     5, A                            ; BIT 5 A: test "kill in progress" flag
    JR      Z, LOC_8D2A                     ; JR Z LOC_8D2A: not in progress -> set kill flag
    LD      B, $09                          ; LD B $09: sound channel 9
    CALL    SUB_9930                        ; CALL SUB_9930: PLAY_IT ch9
    LD      BC, $001E                       ; LD BC $001E: score = 30
    CALL    SUB_9A74                        ; CALL SUB_9A74: add score
    JR      LOC_8D2F                        ; JR LOC_8D2F

LOC_8D2A:                                   ; LOC_8D2A: set kill flag in $70E0
    LD      HL, $70E0                       ; LD HL $70E0: kill flags
    SET     2, (HL)                         ; SET 2 (HL): set kill-player flag 2

LOC_8D2F:                                   ; LOC_8D2F: write $C4 to barrel bottom and deactivate
    LD      (IY+3), $C4                     ; LD (IY+3) $C4: mark barrel bottom as dead
    SUB     A                               ; SUB A: A = 0
    LD      (IX+0), A                       ; LD (IX+0) A: deactivate barrel entity
    JP      LOC_993C                        ; JP LOC_993C: PUTOBJ barrel; return

LOC_8D3A:                                   ; LOC_8D3A: check platform kill (jump+barrel)
    LD      B, $10                          ; LD B $10: tolerance = 16
    CALL    SUB_96F4                        ; CALL SUB_96F4: compare platform overlap
    RET     P                               ; RET P: too far -> no kill
    LD      HL, $714F                       ; LD HL $714F: pointer to platform-kill flag
    LD      (HL), $01                       ; LD (HL) $01: set platform-kill flag
    RET                                     ; RET

LOC_8D46:                                   ; LOC_8D46: run platform/ladder collision on 2 entity slots
    PUSH    HL                              ; PUSH HL: save entity table ptr
    LD      E, $00                          ; LD E $00: check slot 0
    CALL    SUB_982B                        ; CALL SUB_982B: HL = entity ptr slot 0
    PUSH    HL                              ; PUSH HL
    POP     IX                              ; POP IX: IX -> slot 0
    CALL    SUB_8D5B                        ; CALL SUB_8D5B: X/Y collision check slot 0
    POP     HL                              ; POP HL: restore table ptr
    LD      E, $01                          ; LD E $01: check slot 1
    CALL    SUB_982B                        ; CALL SUB_982B: HL = entity ptr slot 1
    PUSH    HL                              ; PUSH HL
    POP     IX                              ; POP IX: IX -> slot 1

SUB_8D5B:                                   ; SUB_8D5B: platform/elevator Y/X collision -> player kill
    CALL    SUB_964D                        ; CALL SUB_964D: load IY = position table for IX
    LD      A, ($7137)                      ; LD A ($7137): player Y
    LD      B, (IY+3)                       ; LD B (IY+3): entity bottom Y
    CALL    SUB_9628                        ; CALL SUB_9628: compute Y delta
    LD      B, $05                          ; LD B $05: Y tolerance = 5
    CALL    SUB_96F4                        ; CALL SUB_96F4: compare Y delta
    RET     P                               ; RET P: too far -> no check
    LD      A, ($7135)                      ; LD A ($7135): player X
    LD      B, (IY+1)                       ; LD B (IY+1): entity right-edge X
    CALL    SUB_9628                        ; CALL SUB_9628: compute X delta
    LD      B, $04                          ; LD B $04: X tolerance = 4
    CALL    SUB_96F4                        ; CALL SUB_96F4: compare X delta
    RET     P                               ; RET P: X too far -> no check
    LD      A, (IY+0)                       ; LD A (IY+0): entity active flag
    OR      A                               ; OR A: test active
    RET     NZ                              ; RET NZ: not active -> no kill
    LD      B, $02                          ; LD B $02: sound channel 2
    CALL    SUB_9930                        ; CALL SUB_9930: PLAY_IT ch2 hit sound
    LD      HL, $70E0                       ; LD HL $70E0: kill flags
    SET     5, (HL)                         ; SET 5 (HL): set kill flag 5
    LD      (IY+0), $01                     ; LD (IY+0) $01: mark entity as hit
    LD      B, $00                          ; LD B $00: B = 0 for PUTOBJ
    JP      PUTOBJ                          ; JP PUTOBJ: update entity sprite; return

SUB_8D94:                                   ; SUB_8D94: run Kong-player collision check for both passes
    LD      E, $00                          ; LD E $00: pass 0
    CALL    SUB_8D9B                        ; CALL SUB_8D9B: check Kong collision pass 0
    LD      E, $01                          ; LD E $01: pass 1

SUB_8D9B:                                   ; SUB_8D9B: Kong-to-player proximity/kill check (IX=$70D8)
    LD      IX, $70D8                       ; LD IX $70D8: IX -> Kong entity struct
    LD      A, (IX+10)                      ; LD A (IX+10): Kong collision width
    OR      A                               ; OR A: test == 0
    RET     Z                               ; RET Z: no collision -> return
    CALL    SUB_92CD                        ; CALL SUB_92CD: load IY = Kong sprite position ptr
    PUSH    HL                              ; PUSH HL
    POP     IY                              ; POP IY: IY -> Kong sprite position
    LD      A, ($7135)                      ; LD A ($7135): player X
    ADD     A, $03                          ; ADD A $03: X + 3 (center offset)
    LD      B, (IY+1)                       ; LD B (IY+1): Kong sprite right-edge X
    SUB     B                               ; SUB B: delta X = player X+3 - Kong right X
    JR      Z, LOC_8DB7                     ; JR Z LOC_8DB7: zero delta -> vertical check
    DEC     A                               ; DEC A: delta - 1
    RET     NZ                              ; RET NZ: non-zero -> no hit

LOC_8DB7:                                   ; LOC_8DB7: check vertical overlap for Kong kill
    LD      HL, $70E0                       ; LD HL $70E0: kill flags
    LD      A, (IY+0)                       ; LD A (IY+0): Kong sprite active flag
    OR      A                               ; OR A: test == 0
    JR      NZ, LOC_8DE5                    ; JR NZ LOC_8DE5: active -> advanced kill logic
    BIT     0, (HL)                         ; BIT 0 (HL): test kill-in-progress flag
    JR      Z, LOC_8DCF                     ; JR Z LOC_8DCF: no kill -> init kill sequence
    LD      A, ($70E5)                      ; LD A ($70E5): Kong height param
    CP      $07                             ; CP $07: compare with 7
    JP      M, LOC_8DCF                     ; JP M LOC_8DCF: < 7 -> init kill
    SET     2, (HL)                         ; SET 2 (HL): set kill-player flag 2
    RET                                     ; RET

LOC_8DCF:                                   ; LOC_8DCF: start Kong kill sequence
    INC     (IY+0)                          ; INC (IY+0): advance sprite active counter
    LD      BC, $000A                       ; LD BC $000A: score = 10 for near-Kong
    CALL    SUB_9A74                        ; CALL SUB_9A74: add score
    CALL    PUTOBJ                          ; CALL PUTOBJ: update Kong sprite
    LD      B, $09                          ; LD B $09: sound channel 9
    CALL    SUB_9930                        ; CALL SUB_9930: PLAY_IT ch9
    LD      HL, $7155                       ; LD HL $7155: pointer to kill counter
    INC     (HL)                            ; INC (HL): increment kill counter
    RET                                     ; RET

LOC_8DE5:                                   ; LOC_8DE5: advanced Kong kill: check flags before applying
    BIT     0, (HL)                         ; BIT 0 (HL): test kill-in-progress flag
    RET     NZ                              ; RET NZ: already killing -> return
    BIT     3, (HL)                         ; BIT 3 (HL): test kill-complete flag
    RET     NZ                              ; RET NZ: kill complete -> return
    SET     0, (HL)                         ; SET 0 (HL): set kill-in-progress flag
    SUB     A                               ; SUB A: A = 0
    LD      ($70E4), A                      ; LD ($70E4) A: clear kill phase
    LD      B, $0A                          ; LD B $0A: sound channel 10 for Kong hit
    JP      SUB_9930                        ; JP SUB_9930: PLAY_IT ch10; return

SUB_8DF6:                                   ; SUB_8DF6: init Kong entity struct at $70D8
    LD      HL, $AF7D                       ; LD HL $AF7D: Kong sprite descriptor
    SUB     A                               ; SUB A: A = 0
    CALL    ACTIVATE                        ; CALL ACTIVATE: BIOS activate Kong sprite slot at IY
    SUB     A                               ; SUB A: A = 0
    LD      B, $12                          ; LD B $12: 18 bytes to zero
    LD      HL, $70D8                       ; LD HL $70D8: Kong entity struct base
    PUSH    HL                              ; PUSH HL
    POP     IX                              ; POP IX: IX -> Kong struct
    LD      IY, $7134                       ; LD IY $7134: IY -> Kong position data
    CALL    DELAY_LOOP_97FA                 ; CALL DELAY_LOOP_97FA: zero 18 bytes at $70D8
    LD      HL, $AF7D                       ; LD HL $AF7D: Kong sprite ptr
    LD      ($70D9), HL                     ; LD ($70D9) HL: store Kong sprite ptr
    LD      A, ($702C)                      ; LD A ($702C): read level type
    ADD     A, A                            ; ADD A A: * 2
    ADD     A, A                            ; ADD A A: * 4 (each level has 4 bytes in table)
    LD      HL, $B087                       ; LD HL $B087: Kong start-position table
    CALL    LOC_965D                        ; CALL LOC_965D: HL = table[A] (Kong X pos entry)
    LD      E, (HL)                         ; LD E (HL): Kong initial X low
    INC     HL                              ; INC HL
    LD      D, (HL)                         ; LD D (HL): Kong initial X high
    LD      ($7135), DE                     ; LD ($7135) DE: store Kong X position
    INC     HL                              ; INC HL
    LD      E, (HL)                         ; LD E (HL): Kong initial Y low
    INC     HL                              ; INC HL
    LD      D, (HL)                         ; LD D (HL): Kong initial Y high
    LD      ($7137), DE                     ; LD ($7137) DE: store Kong Y position
    LD      HL, $70E1                       ; LD HL $70E1: Kong state flags
    LD      (HL), $04                       ; LD (HL) $04: set Kong state flag 2 (idle)
    LD      HL, $0003                       ; LD HL $0003: timer range = 3
    CALL    SUB_99A1                        ; CALL SUB_99A1: REQUEST_SIGNAL -> barrel timer handle
    LD      ($7156), A                      ; LD ($7156) A: save barrel timer handle
    LD      ($70E6), A                      ; LD ($70E6) A: save copy
    LD      HL, $0004                       ; LD HL $0004: timer range = 4
    CALL    SUB_99A1                        ; CALL SUB_99A1: REQUEST_SIGNAL -> animation timer
    LD      ($7157), A                      ; LD ($7157) A: save animation timer handle
    LD      ($70DB), A                      ; LD ($70DB) A: save copy
    LD      HL, $0008                       ; LD HL $0008: timer range = 8
    CALL    SUB_99A1                        ; CALL SUB_99A1: REQUEST_SIGNAL -> position timer A
    LD      ($7158), A                      ; LD ($7158) A: save position timer A handle
    LD      HL, $0008                       ; LD HL $0008: timer range = 8
    CALL    SUB_99A1                        ; CALL SUB_99A1: REQUEST_SIGNAL -> position timer B
    LD      ($7159), A                      ; LD ($7159) A: save position timer B handle
    LD      HL, $0003                       ; LD HL $0003: timer range = 3
    CALL    SUB_99A1                        ; CALL SUB_99A1: REQUEST_SIGNAL -> climb timer
    LD      ($715A), A                      ; LD ($715A) A: save climb timer handle
    LD      HL, $70D8                       ; LD HL $70D8: Kong struct
    LD      (HL), $04                       ; LD (HL) $04: set Kong active flag
    LD      HL, $70DF                       ; LD HL $70DF: Kong extra flags
    SET     2, (HL)                         ; SET 2 (HL): set flag 2
    LD      HL, $B069                       ; LD HL $B069: Kong PUTOBJ descriptor
    LD      ($70DC), HL                     ; LD ($70DC) HL: store Kong PUTOBJ ptr
    CALL    SUB_9672                        ; CALL SUB_9672: load Kong animation frame state
    SUB     A                               ; SUB A: A = 0
    LD      ($7155), A                      ; LD ($7155) A: clear kill counter
    LD      ($714F), A                      ; LD ($714F) A: clear platform-kill flag
    LD      HL, $714E                       ; LD HL $714E: pointer to Pauline-present flag
    LD      (HL), $01                       ; LD (HL) $01: set Pauline-present flag
    JP      LOC_993C                        ; JP LOC_993C: PUTOBJ Kong; return

LOC_8E87:                                   ; LOC_8E87: start Kong climbing: clear Pauline flag, set state
    SUB     A                               ; SUB A: A = 0
    LD      ($714E), A                      ; LD ($714E) A: clear Pauline-present flag
    SET     3, (IX+8)                       ; SET 3 (IX+8): set move-flag 3 (climbing)
    SET     1, (IX+0)                       ; SET 1 (IX+0): set active flag 1
    RES     2, (IX+9)                       ; RES 2 (IX+9): clear state flag 2
    RES     6, (IX+9)                       ; RES 6 (IX+9): clear state flag 6
    LD      E, $02                          ; LD E $02: E=2 for leftward animation
    BIT     2, (IX+7)                       ; BIT 2 (IX+7): test animation bit 2
    JR      NZ, LOC_8EA5                    ; JR NZ LOC_8EA5: set -> use E=2
    LD      E, $03                          ; LD E $03: E=3 for rightward animation

LOC_8EA5:                                   ; LOC_8EA5: set Kong climb animation; restore timers
    CALL    SUB_91C9                        ; CALL SUB_91C9: set Kong animation data pointer from E
    LD      A, ($715A)                      ; LD A ($715A): climb timer handle
    LD      ($70E6), A                      ; LD ($70E6) A: restore climb timer
    LD      ($70DB), A                      ; LD ($70DB) A: restore copy
    LD      A, $F8                          ; LD A $F8: -8 (climb velocity up-left)
    BIT     6, (IX+9)                       ; BIT 6 (IX+9): test direction flag
    JR      NZ, LOC_8EBB                    ; JR NZ LOC_8EBB: set -> use $F8
    LD      A, $FB                          ; LD A $FB: -5 (climb velocity up-right)

LOC_8EBB:                                   ; LOC_8EBB: set Kong Y/X velocities for climb
    LD      (IX+13), A                      ; LD (IX+13) A: set Y-velocity for climb direction
    LD      HL, $7137                       ; LD HL $7137: Kong Y position
    ADD     A, (HL)                         ; ADD A (HL): new Y = old Y + velocity
    LD      (HL), A                         ; LD (HL) A: update Kong Y
    LD      HL, $7135                       ; LD HL $7135: Kong X position
    LD      A, (HL)                         ; LD A (HL): read Kong X
    ADD     A, (IX+12)                      ; ADD A (IX+12): new X = old X + X-velocity
    LD      (HL), A                         ; LD (HL) A: update Kong X
    LD      B, $0B                          ; LD B $0B: sound channel 11 for Kong climb
    JP      SUB_9930                        ; JP SUB_9930: PLAY_IT ch11; return

SUB_8ED0:                                   ; SUB_8ED0: Kong ladder-climb sequence (called on ladder hit)
    LD      IX, $70D8                       ; LD IX $70D8: IX -> Kong struct
    LD      IY, $7134                       ; LD IY $7134: IY -> Kong position
    LD      E, $04                          ; LD E $04: E=4 for climb-complete anim (right)
    BIT     2, (IX+7)                       ; BIT 2 (IX+7): test direction bit
    JR      NZ, LOC_8EE2                    ; JR NZ LOC_8EE2: set -> use E=4
    LD      E, $05                          ; LD E $05: E=5 for climb-complete anim (left)

LOC_8EE2:                                   ; LOC_8EE2: set post-climb animation; reset movement flags
    CALL    SUB_91C9                        ; CALL SUB_91C9: set animation data ptr from E
    CALL    SUB_9672                        ; CALL SUB_9672: reload animation frame state
    SET     4, (IX+8)                       ; SET 4 (IX+8): set move-flag 4 (climb done)
    RES     0, (IX+8)                       ; RES 0 (IX+8): clear move-flag 0
    RES     3, (IX+8)                       ; RES 3 (IX+8): clear move-flag 3
    LD      HL, $0003                       ; LD HL $0003: score range = 3
    LD      A, ($70E5)                      ; LD A ($70E5): Kong height param
    CP      $01                             ; CP $01: compare with minimum
    JP      M, LOC_8F02                     ; JP M LOC_8F02: < 1 -> use range 3
    LD      L, A                            ; LD L A: L = height param
    LD      H, $00                          ; LD H $00: H = 0

LOC_8F02:                                   ; LOC_8F02: REQUEST_SIGNAL for Kong climb timer
    CALL    SUB_99A5                        ; CALL SUB_99A5: REQUEST_SIGNAL (A=0) with HL range
    LD      ($70E6), A                      ; LD ($70E6) A: save new timer handle
    LD      A, ($70E5)                      ; LD A ($70E5): Kong height param
    CP      $08                             ; CP $08: compare with max height 8
    JP      M, LOC_8F14                     ; JP M LOC_8F14: < 8 -> normal
    SET     2, (IX+8)                       ; SET 2 (IX+8): set done-climbing flag

LOC_8F14:                                   ; LOC_8F14: check platform-kill flag after Kong climb
    CALL    SUB_9AA7                        ; CALL SUB_9AA7: clear Kong X/Y velocities
    LD      HL, $714F                       ; LD HL $714F: platform-kill flag
    LD      A, (HL)                         ; LD A (HL): read flag
    OR      A                               ; OR A: test == 0
    RET     Z                               ; RET Z: no kill -> return
    LD      (HL), $00                       ; LD (HL) $00: clear flag
    LD      B, $09                          ; LD B $09: sound channel 9
    CALL    SUB_9930                        ; CALL SUB_9930: PLAY_IT ch9
    LD      BC, $000A                       ; LD BC $000A: score = 10
    JP      SUB_9A74                        ; JP SUB_9A74: add score; return

SUB_8F2A:                                   ; SUB_8F2A: Kong movement state machine (fall/land/move)
    BIT     3, (IX+8)                       ; BIT 3 (IX+8): test climbing flag
    JR      Z, LOC_8F3F                     ; JR Z LOC_8F3F: not climbing -> check landing
    BIT     0, (IX+8)                       ; BIT 0 (IX+8): test grounded flag
    JR      NZ, LOC_8F45                    ; JR NZ LOC_8F45: grounded -> post-land
    SET     0, (IX+8)                       ; SET 0 (IX+8): set grounded
    RES     3, (IX+8)                       ; RES 3 (IX+8): clear climbing flag
    RET                                     ; RET

LOC_8F3F:                                   ; LOC_8F3F: check grounded flag
    BIT     0, (IX+8)                       ; BIT 0 (IX+8): test grounded
    JR      Z, LOC_8F50                     ; JR Z LOC_8F50: not grounded -> player movement

LOC_8F45:                                   ; LOC_8F45: post-land: update position, check ladder again
    CALL    LOC_9751                        ; CALL LOC_9751: update Kong Y/X positions
    BIT     2, (IX+9)                       ; BIT 2 (IX+9): test ladder-reached flag
    CALL    NZ, SUB_8ED0                    ; CALL NZ SUB_8ED0: if reached ladder -> climb sequence
    RET                                     ; RET

LOC_8F50:                                   ; LOC_8F50: check fire/bonus state flags
    LD      A, ($70B3)                      ; LD A ($70B3): player state flags
    OR      A                               ; OR A: test == 0
    JR      Z, LOC_8F5A                     ; JR Z LOC_8F5A: no flags -> check hammer
    SET     1, (IX+0)                       ; SET 1 (IX+0): set Kong active flag 1

LOC_8F5A:                                   ; LOC_8F5A: check hammer flag for player kill
    LD      A, ($70B2)                      ; LD A ($70B2): hammer active flag
    OR      A                               ; OR A: test == 0
    JR      Z, LOC_8F70                     ; JR Z LOC_8F70: no hammer -> Kong normal update
    LD      A, ($714E)                      ; LD A ($714E): Pauline-present flag
    OR      A                               ; OR A: test == 0
    JR      Z, LOC_8F70                     ; JR Z LOC_8F70: no Pauline -> skip
    LD      A, (IX+8)                       ; LD A (IX+8): read move-flags
    AND     $2B                             ; AND $2B: mask state bits
    JR      NZ, LOC_8F70                    ; JR NZ LOC_8F70: state active -> skip kill
    JP      LOC_8E87                        ; JP LOC_8E87: start Kong climbing sequence

LOC_8F70:                                   ; LOC_8F70: Kong not in bonus/hammer; normal movement
    LD      A, ($70B3)                      ; LD A ($70B3): player state flags
    OR      A                               ; OR A: test == 0
    JR      NZ, LOC_8F84                    ; JR NZ LOC_8F84: flags set -> check direction
    CALL    SUB_9AA7                        ; CALL SUB_9AA7: clear Kong X/Y velocities
    RES     1, (IX+0)                       ; RES 1 (IX+0): clear active flag 1
    LD      A, ($7156)                      ; LD A ($7156): barrel timer handle
    LD      (IX+14), A                      ; LD (IX+14) A: store barrel timer
    RET                                     ; RET

LOC_8F84:                                   ; LOC_8F84: player state flags set; route movement
    BIT     1, A                            ; BIT 1 A: test left-movement flag
    JR      NZ, LOC_8F8C                    ; JR NZ LOC_8F8C: left -> lateral movement
    BIT     3, A                            ; BIT 3 A: test bonus flag
    JR      Z, LOC_8F8F                     ; JR Z LOC_8F8F: no bonus -> check other flags

LOC_8F8C:                                   ; LOC_8F8C: lateral movement -> jump to main movement handler
    JP      LOC_9231                        ; JP LOC_9231: jump to lateral movement path

LOC_8F8F:                                   ; LOC_8F8F: check jump/platform flags
    BIT     2, A                            ; BIT 2 A: test jump flag
    JR      NZ, LOC_8F96                    ; JR NZ LOC_8F96: jump flag -> jump movement
    BIT     0, A                            ; BIT 0 A: test platform flag
    RET     Z                               ; RET Z: no flags -> return

LOC_8F96:                                   ; LOC_8F96: player jumping; check barrel and position
    BIT     1, (IX+8)                       ; BIT 1 (IX+8): test move-flag 1 (in-air)
    JR      Z, LOC_8FFC                     ; JR Z LOC_8FFC: not in-air -> launch check
    CALL    SUB_9877                        ; CALL SUB_9877: update Kong sprite slot tracker
    SET     1, (IX+0)                       ; SET 1 (IX+0): set active flag 1
    LD      A, ($70B3)                      ; LD A ($70B3): player state flags
    LD      B, $02                          ; LD B $02: default X-velocity +2
    BIT     0, A                            ; BIT 0 A: test right-move flag
    JR      Z, LOC_8FCB                     ; JR Z LOC_8FCB: right -> use B=$02
    LD      A, ($70BF)                      ; LD A ($70BF): player barrel-track index
    LD      B, $FE                          ; LD B $FE: left X-velocity -2
    CP      $02                             ; CP $02: compare track index
    JR      NZ, LOC_8FCB                    ; JR NZ LOC_8FCB: not track 2 -> use B
    LD      A, ($70C2)                      ; LD A ($70C2): barrel-track X data
    ADD     A, $18                          ; ADD A $18: + 24 offset
    LD      B, A                            ; LD B A: B = adjusted velocity
    LD      A, ($7137)                      ; LD A ($7137): player Y
    CALL    SUB_96F4                        ; CALL SUB_96F4: compare player Y
    LD      B, $FE                          ; LD B $FE: fallback left velocity
    JR      NC, LOC_8FCB                    ; JR NC LOC_8FCB
    RES     1, (IX+0)                       ; RES 1 (IX+0): clear active flag
    LD      B, $00                          ; LD B $00: B = 0

LOC_8FCB:                                   ; LOC_8FCB: set Kong X-velocity and update sprite tracker
    LD      (IX+13), B                      ; LD (IX+13) B: set Y-velocity from B
    CALL    SUB_969D                        ; CALL SUB_969D: update Kong position and direction flags
    BIT     3, (IX+9)                       ; BIT 3 (IX+9): test state flag 3
    RET     NZ                              ; RET NZ: flag set -> done
    BIT     0, (IX+9)                       ; BIT 0 (IX+9): test flag 0
    JR      Z, LOC_8FE2                     ; JR Z LOC_8FE2: clear -> clear flag 1
    RES     0, (IX+9)                       ; RES 0 (IX+9): clear flag 0
    JR      LOC_8FE6                        ; JR LOC_8FE6

LOC_8FE2:                                   ; LOC_8FE2: clear state flag 1
    RES     1, (IX+9)                       ; RES 1 (IX+9): clear direction flag 1

LOC_8FE6:                                   ; LOC_8FE6: update animation and clear active state
    CALL    SUB_9836                        ; CALL SUB_9836: get barrel slot index -> A
    LD      (IX+10), A                      ; LD (IX+10) A: store collision width
    LD      (IX+6), $00                     ; LD (IX+6) $00: clear lives/state
    CALL    SUB_9672                        ; CALL SUB_9672: reload animation frame
    RES     1, (IX+0)                       ; RES 1 (IX+0): clear active flag 1
    LD      (IX+7), $00                     ; LD (IX+7) $00: clear animation frame
    RET                                     ; RET

LOC_8FFC:                                   ; LOC_8FFC: player not in-air; check for launch condition
    CALL    SUB_9968                        ; CALL SUB_9968: load entity collision data from IX
    LD      A, ($70B3)                      ; LD A ($70B3): player state flags
    BIT     0, A                            ; BIT 0 A: test right-move
    JR      Z, LOC_900E                     ; JR Z LOC_900E: not right -> left-check
    CALL    SOUND_WRITE_98CF                ; CALL SOUND_WRITE_98CF: check barrel right of player -> A
    JP      P, LOC_901E                     ; JP P LOC_901E: positive -> try launch
    JR      LOC_9029                        ; JR LOC_9029: negative -> check in-air

LOC_900E:                                   ; LOC_900E: check barrel to left of player
    CALL    SUB_98CB                        ; CALL SUB_98CB: check barrel left of player -> A
    JP      M, LOC_9029                     ; JP M LOC_9029: negative -> check in-air
    CALL    SUB_9877                        ; CALL SUB_9877: update sprite slot tracker
    LD      A, ($70BF)                      ; LD A ($70BF): player barrel-track index
    CP      $00                             ; CP $00: test == 0
    JR      Z, LOC_9029                     ; JR Z LOC_9029

LOC_901E:                                   ; LOC_901E: test launch condition (move flags)
    LD      A, (IX+8)                       ; LD A (IX+8): read move-flags
    AND     $39                             ; AND $39: mask relevant bits
    JR      NZ, LOC_9029                    ; JR NZ LOC_9029: flags set -> do in-air check
    SET     1, (IX+8)                       ; SET 1 (IX+8): set in-air flag

LOC_9029:                                   ; LOC_9029: in-air check; if in-air update position
    BIT     1, (IX+8)                       ; BIT 1 (IX+8): test in-air flag
    JR      Z, LOC_905F                     ; JR Z LOC_905F: not in-air -> clear and return
    CALL    SUB_9877                        ; CALL SUB_9877: update sprite slot tracker
    LD      A, ($70B3)                      ; LD A ($70B3): player state flags
    BIT     0, A                            ; BIT 0 A: test right-move
    JR      NZ, LOC_903E                    ; JR NZ LOC_903E: right -> use barrel X from $70C2
    LD      A, ($70C2)                      ; LD A ($70C2): barrel X position data
    JR      LOC_9041                        ; JR LOC_9041

LOC_903E:                                   ; LOC_903E: use barrel X from $70C4 for left movement
    LD      A, ($70C4)                      ; LD A ($70C4): barrel X left data

LOC_9041:                                   ; LOC_9041: update Kong IY position and velocity for in-air move
    LD      (IY+3), A                       ; LD (IY+3) A: set Kong sprite Y target
    LD      A, ($70C0)                      ; LD A ($70C0): barrel Y data
    LD      (IY+1), A                       ; LD (IY+1) A: set Kong sprite X target
    LD      (IX+12), $00                    ; LD (IX+12) $00: clear X-velocity
    LD      A, ($7158)                      ; LD A ($7158): position timer A handle
    LD      (IX+14), A                      ; LD (IX+14) A: store timer handle
    LD      A, ($7159)                      ; LD A ($7159): position timer B handle
    LD      (IX+3), A                       ; LD (IX+3) A: store as entity field 3
    LD      E, $06                          ; LD E $06: E=6 for in-air animation
    JP      SUB_91C9                        ; JP SUB_91C9: set Kong animation data ptr; return

LOC_905F:                                   ; LOC_905F: not in-air; clear active flag
    RES     1, (IX+0)                       ; RES 1 (IX+0): clear active flag 1
    JP      SUB_9AA7                        ; JP SUB_9AA7: clear X/Y velocities; return

SUB_9066:                                   ; SUB_9066: Kong elevator path movement (level 1)
    CALL    SUB_90E0                        ; CALL SUB_90E0: compare Kong X to elevator column
    JP      P, LOC_907A                     ; JP P LOC_907A: positive -> skip X-adjust
    LD      A, ($70E2)                      ; LD A ($70E2): floor collision threshold
    CP      $04                             ; CP $04: test if at column edge
    JR      NZ, LOC_907A                    ; JR NZ LOC_907A: not edge -> skip
    RES     1, (IX+0)                       ; RES 1 (IX+0): clear Kong active flag 1
    LD      (IY+1), B                       ; LD (IY+1) B: set Kong sprite X from B

LOC_907A:                                   ; LOC_907A: update Kong position; check barrel collisions
    PUSH    IX                              ; PUSH IX: save Kong IX
    LD      HL, $B668                       ; LD HL $B668: barrel entity table A
    CALL    SUB_8CDA                        ; CALL SUB_8CDA: check 3 barrel entities for kill
    LD      HL, $B672                       ; LD HL $B672: barrel entity table B
    CALL    SUB_8C5C                        ; CALL SUB_8C5C: check 2 barrel entities for kill
    LD      A, ($70E0)                      ; LD A ($70E0): kill flags
    BIT     0, A                            ; BIT 0 A: test kill flag 0
    JR      Z, LOC_90C4                     ; JR Z LOC_90C4: no kill -> check Y boundary
    LD      A, ($7135)                      ; LD A ($7135): Kong X position
    LD      B, $2F                          ; LD B $2F: left column X
    CALL    SUB_96F4                        ; CALL SUB_96F4: compare Kong X to left column
    JR      C, LOC_90C4                     ; JR C LOC_90C4: Kong left of column -> skip ladder check
    LD      B, $45                          ; LD B $45: right column X
    CALL    SUB_96F4                        ; CALL SUB_96F4: compare Kong X to right column
    JR      NC, LOC_90AC                    ; JR NC LOC_90AC: Kong right -> check far ladder
    LD      E, $00                          ; LD E $00: E=0 for left ladder check
    CALL    SUB_8CA9                        ; CALL SUB_8CA9: check Kong-to-ladder hit slot 0
    LD      E, $01                          ; LD E $01: E=1 for right ladder check
    CALL    SUB_8CA9                        ; CALL SUB_8CA9: check Kong-to-ladder hit slot 1
    JR      LOC_90C4                        ; JR LOC_90C4

LOC_90AC:                                   ; LOC_90AC: check far-right ladder columns
    LD      B, $6F                          ; LD B $6F: far-left column X
    CALL    SUB_96F4                        ; CALL SUB_96F4: compare Kong X to $6F
    JR      C, LOC_90C4                     ; JR C LOC_90C4: left of $6F -> skip
    LD      B, $85                          ; LD B $85: far-right column X
    CALL    SUB_96F4                        ; CALL SUB_96F4: compare to $85
    JR      NC, LOC_90C4                    ; JR NC LOC_90C4: right of $85 -> skip
    LD      E, $02                          ; LD E $02: E=2 ladder slot
    CALL    SUB_8CA9                        ; CALL SUB_8CA9: check Kong-to-ladder slot 2
    LD      E, $03                          ; LD E $03: E=3 ladder slot
    CALL    SUB_8CA9                        ; CALL SUB_8CA9: check Kong-to-ladder slot 3

LOC_90C4:                                   ; LOC_90C4: check Kong Y boundary for state change
    POP     IX                              ; POP IX: restore Kong IX
    LD      A, ($7137)                      ; LD A ($7137): Kong Y
    LD      B, $96                          ; LD B $96: Y boundary $96
    CALL    SUB_96F4                        ; CALL SUB_96F4: compare Kong Y to $96
    JR      NC, LOC_90DB                    ; JR NC LOC_90DB: Kong above $96 -> set done flag
    LD      B, $45                          ; LD B $45: Y boundary $45
    CALL    SUB_96F4                        ; CALL SUB_96F4: compare to $45
    RET     P                               ; RET P: Kong above $45 -> return
    BIT     6, (IX+9)                       ; BIT 6 (IX+9): test elevator-done flag
    RET     Z                               ; RET Z: not done -> return

LOC_90DB:                                   ; LOC_90DB: set Kong movement-done flag
    SET     2, (IX+8)                       ; SET 2 (IX+8): set done flag
    RET                                     ; RET

SUB_90E0:                                   ; SUB_90E0: get Kong X vs floor-column position delta
    LD      A, ($71CE)                      ; LD A ($71CE): floor column X reference
    ADD     A, $20                          ; ADD A $20: + 32 offset
    LD      B, A                            ; LD B A: B = column reference + 32
    LD      A, ($7135)                      ; LD A ($7135): Kong X
    JP      SUB_96F4                        ; JP SUB_96F4: compare A to B; return flags

SUB_90EC:                                   ; SUB_90EC: Kong fall / rivet-complete logic (main game over/win)
    LD      IX, $70D8                       ; LD IX $70D8: IX -> Kong struct
    LD      IY, $7134                       ; LD IY $7134: IY -> Kong position
    CALL    SUB_9688                        ; CALL SUB_9688: copy player state to $70B2..$70B6
    LD      A, ($70B2)                      ; LD A ($70B2): player left-right flag
    OR      A                               ; OR A: test == 0
    JR      NZ, LOC_9102                    ; JR NZ LOC_9102: flag set -> run Kong timer logic
    LD      HL, $714E                       ; LD HL $714E: Pauline-present flag
    LD      (HL), $01                       ; LD (HL) $01: set Pauline-present

LOC_9102:                                   ; LOC_9102: check barrel timer
    LD      A, ($70E6)                      ; LD A ($70E6): barrel timer handle
    CALL    SUB_9A66                        ; CALL SUB_9A66: TEST_SIGNAL
    JR      Z, LOC_9148                     ; JR Z LOC_9148: not fired -> skip Kong level logic
    BIT     4, (IX+8)                       ; BIT 4 (IX+8): test post-throw flag
    JR      Z, LOC_9127                     ; JR Z LOC_9127: not post-throw -> movement update
    RES     4, (IX+8)                       ; RES 4 (IX+8): clear post-throw flag
    LD      E, $00                          ; LD E $00: E=0 for left-facing anim
    BIT     2, (IX+7)                       ; BIT 2 (IX+7): test facing direction bit
    JR      NZ, LOC_911E                    ; JR NZ LOC_911E: right-facing -> use E=0
    LD      E, $01                          ; LD E $01: E=1 for right-facing after throw

LOC_911E:                                   ; LOC_911E: set Kong animation; reload frame; check collision
    CALL    SUB_91C9                        ; CALL SUB_91C9: set Kong animation ptr from E
    CALL    SUB_9672                        ; CALL SUB_9672: reload animation frame
    CALL    SUB_9289                        ; CALL SUB_9289: restore player Y/X from saved values

LOC_9127:                                   ; LOC_9127: Kong movement update; dispatch by level type
    PUSH    IX                              ; PUSH IX
    PUSH    IY                              ; PUSH IY
    CALL    SUB_8F2A                        ; CALL SUB_8F2A: Kong movement state machine
    LD      A, ($702C)                      ; LD A ($702C): read level type
    CP      $01                             ; CP $01: test level 1 (elevator)
    JR      Z, LOC_913C                     ; JR Z LOC_913C: level 1 -> elevator movement
    JR      C, LOC_9141                     ; JR C LOC_9141: level 0 -> girder movement
    CALL    SUB_9066                        ; CALL SUB_9066: level 2 -> elevator platform movement
    JR      LOC_9144                        ; JR LOC_9144

LOC_913C:                                   ; LOC_913C: level 1 elevator Kong movement
    CALL    SUB_9203                        ; CALL SUB_9203: check elevator position / trigger ladder
    JR      LOC_9144                        ; JR LOC_9144

LOC_9141:                                   ; LOC_9141: level 0 girder Kong movement
    CALL    SUB_91D7                        ; CALL SUB_91D7: check girder position / throw barrel

LOC_9144:                                   ; LOC_9144: restore registers after movement dispatch
    POP     IY                              ; POP IY
    POP     IX                              ; POP IX

LOC_9148:                                   ; LOC_9148: check animation timer; run Kong animation
    LD      A, ($70DB)                      ; LD A ($70DB): animation timer handle
    CALL    SUB_9A66                        ; CALL SUB_9A66: TEST_SIGNAL
    JR      Z, LOC_917D                     ; JR Z LOC_917D: not fired -> skip anim
    BIT     1, (IX+0)                       ; BIT 1 (IX+0): test active flag 1
    JR      Z, LOC_917D                     ; JR Z LOC_917D: not active -> skip anim
    BIT     0, (IX+8)                       ; BIT 0 (IX+8): test grounded flag
    JR      NZ, LOC_917D                    ; JR NZ LOC_917D: grounded -> skip
    CALL    SUB_9672                        ; CALL SUB_9672: advance animation frame
    LD      A, (IX+8)                       ; LD A (IX+8): read move-flags
    AND     $28                             ; AND $28: mask bits 3,5
    JR      NZ, LOC_917D                    ; JR NZ LOC_917D: flags set -> skip
    LD      B, $04                          ; LD B $04: check sound ch4
    BIT     1, (IX+8)                       ; BIT 1 (IX+8): test in-air flag
    JR      NZ, LOC_917A                    ; JR NZ LOC_917A: in-air -> use B=$04
    LD      A, (IX+6)                       ; LD A (IX+6): read lives/state
    OR      A                               ; OR A: test == 0
    JR      Z, LOC_917A                     ; JR Z LOC_917A: zero -> use B=$04
    CP      $02                             ; CP $02: compare with 2
    JR      NZ, LOC_917D                    ; JR NZ LOC_917D: not 2 -> skip
    LD      B, $08                          ; LD B $08: sound ch8

LOC_917A:                                   ; LOC_917A: play animation sound
    CALL    SUB_9930                        ; CALL SUB_9930: PLAY_IT ch B

LOC_917D:                                   ; LOC_917D: check done-flag for game-over/win transition
    BIT     2, (IX+8)                       ; BIT 2 (IX+8): test movement-done flag
    JR      Z, LOC_9188                     ; JR Z LOC_9188: not done -> check level type
    LD      HL, $70A8                       ; LD HL $70A8: game-phase register
    LD      (HL), $02                       ; LD (HL) $02: set game-phase 2 (level end / win)

LOC_9188:                                   ; LOC_9188: check level type for kill/finish routing
    LD      A, ($702C)                      ; LD A ($702C): read level type
    CP      $01                             ; CP $01: test level 1
    JR      NZ, LOC_9198                    ; JR NZ LOC_9198: not level 1 -> check rivets
    LD      A, ($7155)                      ; LD A ($7155): kill counter
    CP      $06                             ; CP $06: test 6 kills
    JR      Z, LOC_919F                     ; JR Z LOC_919F: 6 kills -> set win
    JR      LOC_91A4                        ; JR LOC_91A4

LOC_9198:                                   ; LOC_9198: level 0/2 check rivet/barrel count
    LD      A, (IX+10)                      ; LD A (IX+10): collision width (rivet count)
    CP      $05                             ; CP $05: test 5 rivets
    JR      NZ, LOC_91A4                    ; JR NZ LOC_91A4: not 5 -> skip

LOC_919F:                                   ; LOC_919F: set win condition (game-phase 1)
    LD      HL, $70A8                       ; LD HL $70A8: game-phase register
    LD      (HL), $01                       ; LD (HL) $01: set game-phase 1 (level won)

LOC_91A4:                                   ; LOC_91A4: check Pauline ladder-reached flag
    BIT     6, (IX+9)                       ; BIT 6 (IX+9): test ladder-reached flag
    JR      Z, LOC_91C6                     ; JR Z LOC_91C6: not reached -> done
    PUSH    IY                              ; PUSH IY
    LD      IY, ($70E8)                     ; LD IY ($70E8): load saved ladder IY ptr
    LD      A, (IY+0)                       ; LD A (IY+0): ladder top tile byte
    SUB     $05                             ; SUB $05: subtract 5
    ADD     A, A                            ; ADD A A: *2
    LD      B, A                            ; LD B A: B = offset
    LD      A, (IY+3)                       ; LD A (IY+3): ladder top Y
    SUB     $10                             ; SUB $10: ladder Y - 16
    POP     IY                              ; POP IY
    CP      $90                             ; CP $90: compare with $90
    JR      NZ, LOC_91C3                    ; JR NZ LOC_91C3: not $90 -> add B
    ADD     A, B                            ; ADD A B: A += B (adjust Y for Kong position)

LOC_91C3:                                   ; LOC_91C3: store adjusted Y into IY+3
    LD      (IY+3), A                       ; LD (IY+3) A

LOC_91C6:                                   ; LOC_91C6: PUTOBJ Kong; return
    JP      LOC_993C                        ; JP LOC_993C: PUTOBJ Kong sprite; return

SUB_91C9:                                   ; SUB_91C9: set Kong animation data ptr from E-indexed table at $B05B
    LD      HL, $B05B                       ; LD HL $B05B: Kong animation table base
    CALL    SUB_982B                        ; CALL SUB_982B: HL = table[E*2] (animation data ptr)
    LD      ($70DC), HL                     ; LD ($70DC) HL: store Kong animation data ptr
    SUB     A                               ; SUB A: A = 0
    LD      ($70DE), A                      ; LD ($70DE) A: reset animation phase
    RET                                     ; RET

SUB_91D7:                                   ; SUB_91D7: Kong girder-level movement (check throw + barrel spawn)
    CALL    SUB_91F7                        ; CALL SUB_91F7: compare Kong X to girder column
    JP      M, LOC_91EB                     ; JP M LOC_91EB: negative (far right) -> check collision tables
    LD      A, ($70E2)                      ; LD A ($70E2): floor column reference
    CP      $04                             ; CP $04: test column 4
    JR      NZ, LOC_91EB                    ; JR NZ LOC_91EB: not col 4 -> skip
    RES     1, (IX+0)                       ; RES 1 (IX+0): clear Kong active flag
    LD      (IY+1), B                       ; LD (IY+1) B: update Kong sprite X from B

LOC_91EB:                                   ; LOC_91EB: run barrel collision tables for girder level
    LD      HL, $B636                       ; LD HL $B636: barrel A entity table
    CALL    SUB_8CDA                        ; CALL SUB_8CDA: check 3 barrel entities for kill
    LD      HL, $B640                       ; LD HL $B640: barrel B entity table
    JP      LOC_8D46                        ; JP LOC_8D46: check 2 entity slots for platform kill

SUB_91F7:                                   ; SUB_91F7: get Kong X vs girder column delta
    LD      A, ($71CE)                      ; LD A ($71CE): girder column X reference
    SUB     $10                             ; SUB $10: column X - 16
    LD      B, A                            ; LD B A: B = adjusted column X
    LD      A, ($7135)                      ; LD A ($7135): Kong X
    JP      SUB_96F4                        ; JP SUB_96F4: compare A to B; return

SUB_9203:                                   ; SUB_9203: level-1 elevator position check; trigger ladder
    CALL    SUB_90E0                        ; CALL SUB_90E0: compare Kong X to elevator column
    JP      P, LOC_921C                     ; JP P LOC_921C: positive -> normal elevator update
    CALL    SUB_91F7                        ; CALL SUB_91F7: compare to girder column
    JR      Z, LOC_921C                     ; JR Z LOC_921C: zero -> normal
    JP      M, LOC_921C                     ; JP M LOC_921C: negative -> normal
    LD      A, ($70E2)                      ; LD A ($70E2): floor column reference
    CP      $03                             ; CP $03: test column 3
    JR      NZ, LOC_921C                    ; JR NZ LOC_921C: not col 3 -> normal
    SET     2, (IX+8)                       ; SET 2 (IX+8): set done-climbing flag

LOC_921C:                                   ; LOC_921C: platform entity update - check position and refresh display
    CALL    SUB_8D94                        ; CALL SUB_8D94 - check entity Y boundary
    LD      HL, $B652                       ; LD HL $B652 - load first display record pointer
    CALL    SUB_8CDA                        ; CALL SUB_8CDA - X/Y collision/display check
    LD      HL, $B65C                       ; LD HL $B65C - load second display record pointer
    CALL    SUB_8C5C                        ; CALL SUB_8C5C - call display helper
    LD      HL, $B662                       ; LD HL $B662 - load exit display record pointer
    JP      LOC_8D46                        ; JP LOC_8D46 - jump to display update exit

LOC_9231:                                   ; LOC_9231: barrel lateral movement - clear temp flag, test falling
    XOR     A                               ; XOR A - A=0
    LD      ($714F), A                      ; LD ($714F) A - clear temp lateral movement flag
    BIT     1, (IX+8)                       ; BIT 1 (IX+8) - test falling/off-screen flag
    JR      NZ, LOC_9284                    ; JR NZ LOC_9284 - falling: deactivate entity
    CALL    SUB_9289                        ; CALL SUB_9289 - load screen pos from $7156/$7157 into entity
    LD      B, $FE                          ; LD B $FE - default X velocity = -2 (leftward)
    LD      A, ($70B3)                      ; LD A ($70B3) - load level direction flags
    BIT     3, A                            ; BIT 3 A - test direction flag bit 3
    JR      Z, LOC_9259                     ; JR Z LOC_9259 - flag clear: go right path
    BIT     1, (IX+7)                       ; BIT 1 (IX+7) - test left-moving flag
    JR      NZ, LOC_926E                    ; JR NZ LOC_926E - already moving left: skip direction set
    SET     1, (IX+7)                       ; SET 1 (IX+7) - set left-moving flag
    RES     2, (IX+7)                       ; RES 2 (IX+7) - clear right-moving flag
    LD      E, $01                          ; LD E $01 - E=1: leftward animation direction arg
    JR      LOC_926B                        ; JR LOC_926B - call animation update for direction change

LOC_9259:                                   ; LOC_9259: right-direction path
    LD      B, $02                          ; LD B $02 - X velocity = +2 (rightward)
    BIT     2, (IX+7)                       ; BIT 2 (IX+7) - test right-moving flag
    JR      NZ, LOC_926E                    ; JR NZ LOC_926E - already moving right: skip
    SET     2, (IX+7)                       ; SET 2 (IX+7) - set right-moving flag
    RES     1, (IX+7)                       ; RES 1 (IX+7) - clear left-moving flag
    LD      E, $00                          ; LD E $00 - E=0: rightward animation direction arg

LOC_926B:                                   ; LOC_926B: direction changed - update animation frame
    CALL    SUB_91C9                        ; CALL SUB_91C9 - update entity animation frame for new direction

LOC_926E:                                   ; LOC_926E: apply X velocity and move entity
    LD      (IX+12), B                      ; LD (IX+12) B - store X velocity
    CALL    SUB_99B2                        ; CALL SUB_99B2 - apply X movement and boundary check
    BIT     0, (IX+8)                       ; BIT 0 (IX+8) - test floor-hit flag
    JR      Z, LOC_927F                     ; JR Z LOC_927F - no floor hit: skip landing sound
    LD      B, $0A                          ; LD B $0A - sound effect $0A (barrel landing)
    CALL    SUB_9930                        ; CALL SUB_9930 - play landing sound via PLAY_IT

LOC_927F:                                   ; LOC_927F: check done/boundary flag
    BIT     5, (IX+9)                       ; BIT 5 (IX+9) - test boundary-done flag
    RET     Z                               ; RET Z - not done: return normally

LOC_9284:                                   ; LOC_9284: deactivate barrel entity
    RES     1, (IX+0)                       ; RES 1 (IX+0) - clear active flag
    RET                                     ; RET

SUB_9289:                                   ; SUB_9289: load screen position from $7156/$7157 into entity slot
    LD      A, ($7156)                      ; LD A ($7156) - load screen X value
    LD      (IX+14), A                      ; LD (IX+14) A - entity +14 = screen X
    LD      A, ($7157)                      ; LD A ($7157) - load screen Y value
    LD      (IX+3), A                       ; LD (IX+3) A - entity +3 = screen Y / signal handle
    RET                                     ; RET

SUB_9296:                                   ; SUB_9296: check barrel slot E vs player; bounce on close approach
    LD      A, (IX+10)                      ; LD A (IX+10) - load entity slot state byte
    OR      A                               ; OR A - test active
    RET     Z                               ; RET Z - inactive: return
    PUSH    IX                              ; PUSH IX - save barrel IX
    PUSH    BC                              ; PUSH BC - save slot counter BC
    CALL    SUB_92CD                        ; CALL SUB_92CD - look up entity data pointer for slot E
    PUSH    HL                              ; PUSH HL
    POP     IX                              ; POP IX - IX = entity data pointer
    LD      A, (IX+1)                       ; LD A (IX+1) - load entity X
    LD      B, (IY+1)                       ; LD B (IY+1) - B = player sprite X
    CALL    SUB_9628                        ; CALL SUB_9628 - |entity_X - player_X| -> A
    LD      B, $03                          ; LD B $03 - proximity threshold = 3 pixels
    CALL    SUB_96F4                        ; CALL SUB_96F4 - carry if distance < 3
    POP     BC                              ; POP BC - restore slot counter BC
    JR      NC, LOC_92CA                    ; JR NC LOC_92CA - not close enough: skip bounce
    LD      A, (IX+0)                       ; LD A (IX+0) - load entity flags
    OR      A                               ; OR A - test if entity active
    JR      Z, LOC_92CA                     ; JR Z LOC_92CA - inactive entity: skip
    POP     IX                              ; POP IX - restore barrel IX
    CALL    SUB_98C2                        ; CALL SUB_98C2 - negate barrel X velocity (bounce)
    LD      A, (IX+12)                      ; LD A (IX+12) - load new X velocity after bounce
    ADD     A, (IY+1)                       ; ADD A (IY+1) - add to player sprite X
    LD      (IY+1), A                       ; LD (IY+1) A - push player sideways
    RET                                     ; RET

LOC_92CA:                                   ; LOC_92CA: no-hit cleanup
    POP     IX                              ; POP IX - restore barrel IX
    RET                                     ; RET

SUB_92CD:                                   ; SUB_92CD: compute entity data block pointer for slot index A
    ADD     A, A                            ; ADD A A - A *= 2
    ADD     A, A                            ; ADD A A - A *= 4 (4 bytes per pointer table entry)
    LD      HL, $B640                       ; LD HL $B640 - entity pointer table base $B640
    CALL    LOC_965D                        ; CALL LOC_965D - A = table byte at offset A from HL
    CALL    SUB_982B                        ; CALL SUB_982B - HL = word at [base + A*2] (dereference pointer)
    PUSH    HL                              ; PUSH HL
    POP     IX                              ; POP IX - IX = entity data block
    LD      A, $02                          ; LD A $02 - field index 2
    JP      SUB_9983                        ; JP SUB_9983 - return HL = 16-bit pointer at (IX+2)

SUB_92E0:                                   ; SUB_92E0: barrel 4-slot outer loop (elevator/rivet levels only)
    LD      A, ($702C)                      ; LD A ($702C) - load level type
    OR      A                               ; OR A - test for girder level (0)
    RET     Z                               ; RET Z - girder level: barrel loop not used
    LD      C, $00                          ; LD C $00 - slot index = 0

LOC_92E7:                                   ; LOC_92E7: iterate barrel slots 0..3
    PUSH    BC                              ; PUSH BC - save slot counter
    CALL    SUB_92F3                        ; CALL SUB_92F3 - process barrel slot C
    POP     BC                              ; POP BC - restore slot counter
    INC     C                               ; INC C - next slot
    LD      A, C                            ; LD A C
    CP      $04                             ; CP $04 - all 4 slots done?
    JR      C, LOC_92E7                     ; JR C LOC_92E7 - no: loop
    RET                                     ; RET

SUB_92F3:                                   ; SUB_92F3: per-barrel-slot update - position, direction, display
    CALL    SUB_9639                        ; CALL SUB_9639 - load slot C entity IX and IY from table
    LD      HL, $B626                       ; LD HL $B626 - default sprite table (leftward moving)
    BIT     7, (IX+12)                      ; BIT 7 (IX+12) - test X velocity sign (bit7=1 -> negative = leftward)
    JR      NZ, LOC_9302                    ; JR NZ LOC_9302 - leftward: keep $B626 sprite table
    LD      HL, $B628                       ; LD HL $B628 - rightward: use $B628 sprite table

LOC_9302:                                   ; LOC_9302: store sprite table pointer, test active flag
    LD      A, $04                          ; LD A $04 - field index 4
    CALL    SUB_9A8B                        ; CALL SUB_9A8B - store HL sprite table pointer at (IX+4) word slot
    BIT     0, (IX+0)                       ; BIT 0 (IX+0) - test active flag
    JP      Z, LOC_93FE                     ; JP Z LOC_93FE - not active: check for spawn
    CALL    SUB_988F                        ; CALL SUB_988F - load horizontal lane data for this slot
    BIT     5, (IX+9)                       ; BIT 5 (IX+9) - test boundary-hit flag
    JR      NZ, LOC_931D                    ; JR NZ LOC_931D - boundary hit: process direction change
    BIT     0, (IX+8)                       ; BIT 0 (IX+8) - test floor-hit flag
    JR      Z, LOC_9360                     ; JR Z LOC_9360 - no floor hit: go to Y motion check

LOC_931D:                                   ; LOC_931D: process boundary/direction change on barrel
    SET     2, (IX+9)                       ; SET 2 (IX+9) - set X-active flag
    RES     5, (IX+9)                       ; RES 5 (IX+9) - clear boundary-hit flag
    LD      A, ($70CA)                      ; LD A ($70CA) - floor Y for current lane
    LD      (IY+3), A                       ; LD (IY+3) A - snap barrel sprite Y to floor
    BIT     0, (IX+8)                       ; BIT 0 (IX+8) - test floor-hit flag
    JR      Z, LOC_934A                     ; JR Z LOC_934A - not floor-hit: lateral boundary snap
    RES     0, (IX+8)                       ; RES 0 (IX+8) - clear floor-hit flag
    BIT     7, (IX+12)                      ; BIT 7 (IX+12) - test direction: negative=leftward
    JR      Z, LOC_9341                     ; JR Z LOC_9341 - going right: load right-edge X
    LD      A, ($70C6)                      ; LD A ($70C6) - left-edge X of lane
    INC     A                               ; INC A - step one pixel inward
    JR      LOC_9345                        ; JR LOC_9345

LOC_9341:                                   ; LOC_9341: going right: snap to right edge
    LD      A, ($70C8)                      ; LD A ($70C8) - right-edge X of lane
    DEC     A                               ; DEC A - step one pixel inward

LOC_9345:                                   ; LOC_9345: store barrel X at edge
    LD      (IY+1), A                       ; LD (IY+1) A - barrel sprite X = edge X
    JR      LOC_935D                        ; JR LOC_935D - go to reverse velocity

LOC_934A:                                   ; LOC_934A: lateral boundary snap (not floor-hit path)
    BIT     7, (IX+12)                      ; BIT 7 (IX+12) - test direction
    JR      Z, LOC_9356                     ; JR Z LOC_9356 - going right: use right boundary $70AE
    LD      A, ($70AC)                      ; LD A ($70AC) - left boundary X
    INC     A                               ; INC A
    JR      LOC_935A                        ; JR LOC_935A

LOC_9356:                                   ; LOC_9356: right boundary path
    LD      A, ($70AE)                      ; LD A ($70AE) - right boundary X
    DEC     A                               ; DEC A

LOC_935A:                                   ; LOC_935A: store snapped X position
    LD      (IY+1), A                       ; LD (IY+1) A - barrel sprite X = boundary X

LOC_935D:                                   ; LOC_935D: reverse X velocity after wall/boundary
    CALL    SUB_98C2                        ; CALL SUB_98C2 - negate (IX+12)

LOC_9360:                                   ; LOC_9360: check Y motion flag
    BIT     1, (IX+8)                       ; BIT 1 (IX+8) - off-screen/falling flag
    JP      NZ, LOC_93E3                    ; JP NZ LOC_93E3 - off-screen: check bottom Y
    LD      B, $00                          ; LD B $00 - default Y velocity = 0
    BIT     1, (IX+9)                       ; BIT 1 (IX+9) - left-boundary-reached flag
    JR      Z, LOC_937A                     ; JR Z LOC_937A - not at left: check right
    CALL    SUB_9956                        ; CALL SUB_9956 - pseudo-random byte
    AND     $07                             ; AND $07 - keep low 3 bits (0..7)
    JR      NZ, LOC_9389                    ; JR NZ LOC_9389 - non-zero: no Y motion this frame
    LD      B, $FE                          ; LD B $FE - Y velocity = -2 (upward)
    JR      LOC_9389                        ; JR LOC_9389

LOC_937A:                                   ; LOC_937A: check right-boundary flag
    BIT     0, (IX+9)                       ; BIT 0 (IX+9) - right-boundary-reached flag
    JR      Z, LOC_9389                     ; JR Z LOC_9389 - neither boundary: B stays 0
    CALL    SUB_9956                        ; CALL SUB_9956 - pseudo-random byte
    AND     $07                             ; AND $07
    JR      NZ, LOC_9389                    ; JR NZ LOC_9389 - non-zero: no Y motion
    LD      B, $02                          ; LD B $02 - Y velocity = +2 (downward)

LOC_9389:                                   ; LOC_9389: store Y velocity; choose X direction if both zero
    LD      (IX+13), B                      ; LD (IX+13) B - IX+13 = Y velocity
    LD      A, (IX+12)                      ; LD A (IX+12) - load X velocity
    OR      B                               ; OR B - combine with Y velocity
    JR      NZ, LOC_93A7                    ; JR NZ LOC_93A7 - either non-zero: proceed to random flip
    LD      A, (IX+9)                       ; LD A (IX+9) - load state flags
    AND     $03                             ; AND $03 - keep direction bits 0+1
    JR      Z, LOC_93A7                     ; JR Z LOC_93A7 - no direction bits: proceed
    LD      (IX+12), $02                    ; LD (IX+12) $02 - set default X velocity +2
    CALL    SUB_9956                        ; CALL SUB_9956 - pseudo-random byte
    AND     $01                             ; AND $01 - bit 0: 50% chance
    JR      NZ, LOC_93A7                    ; JR NZ LOC_93A7 - 50%: keep direction
    CALL    SUB_98C2                        ; CALL SUB_98C2 - negate X velocity (random direction)

LOC_93A7:                                   ; LOC_93A7: random direction-flip test
    CALL    SUB_9956                        ; CALL SUB_9956 - pseudo-random byte
    AND     $01                             ; AND $01 - 50% chance
    JR      NZ, LOC_93D4                    ; JR NZ LOC_93D4 - skip flip 50% of frames
    LD      A, ($70FB)                      ; LD A ($70FB) - direction-flip signal handle
    CALL    SUB_9A66                        ; CALL SUB_9A66 - test signal (fired?)
    JR      Z, LOC_93D4                     ; JR Z LOC_93D4 - not fired: skip
    CALL    SUB_9956                        ; CALL SUB_9956 - random byte
    AND     $03                             ; AND $03 - 0..3 -> new flip interval
    LD      L, A                            ; LD L A - HL low = random period
    LD      H, $00                          ; LD H $00 - HL = random (0..3)
    CALL    SUB_99A5                        ; CALL SUB_99A5 - allocate one-shot signal with random period
    LD      ($70FB), A                      ; LD ($70FB) A - store new signal handle
    LD      A, (IX+8)                       ; LD A (IX+8) - load movement flags
    AND     $03                             ; AND $03 - keep bits 0+1
    JR      NZ, LOC_93D1                    ; JR NZ LOC_93D1 - flags set: reverse velocity
    BIT     5, (IX+9)                       ; BIT 5 (IX+9) - boundary flag
    JR      Z, LOC_93D4                     ; JR Z LOC_93D4 - no boundary: skip reverse

LOC_93D1:                                   ; LOC_93D1: reverse X velocity
    CALL    SUB_98C2                        ; CALL SUB_98C2 - negate (IX+12)

LOC_93D4:                                   ; LOC_93D4: elevator-level player-hit check
    LD      A, ($702C)                      ; LD A ($702C) - load level type
    DEC     A                               ; DEC A - level type - 1
    JR      NZ, LOC_93E3                    ; JR NZ LOC_93E3 - not elevator level: skip
    LD      E, $00                          ; LD E $00 - slot 0
    CALL    SUB_9296                        ; CALL SUB_9296 - check barrel vs player slot 0
    INC     E                               ; INC E - slot 1
    CALL    SUB_9296                        ; CALL SUB_9296 - check barrel vs player slot 1

LOC_93E3:                                   ; LOC_93E3: check barrel Y at off-screen bottom ($CF)
    LD      A, (IY+3)                       ; LD A (IY+3) - load barrel sprite Y
    CP      $CF                             ; CP $CF - compare to off-screen Y marker ($CF)
    JR      NZ, LOC_93EF                    ; JR NZ LOC_93EF - not at bottom: check flags
    RES     0, (IX+0)                       ; RES 0 (IX+0) - deactivate barrel slot
    RET                                     ; RET

LOC_93EF:                                   ; LOC_93EF: check pending direction-change flag
    BIT     2, (IX+8)                       ; BIT 2 (IX+8) - test direction-change pending flag
    RET     Z                               ; RET Z - not set: return
    LD      (IY+3), $CF                     ; LD (IY+3) $CF - push barrel Y to off-screen
    CALL    SUB_9672                        ; CALL SUB_9672 - advance animation frame
    JP      SUB_9940                        ; JP SUB_9940 - display entity via PUTOBJ

LOC_93FE:                                   ; LOC_93FE: inactive slot - check spawn timer
    LD      A, ($714B)                      ; LD A ($714B) - spawn-rate timer signal handle
    CALL    SUB_9A66                        ; CALL SUB_9A66 - test signal (fired?)
    RET     Z                               ; RET Z - not fired: stay inactive
    LD      A, C                            ; LD A C - slot index
    CP      $03                             ; CP $03 - is slot 3?
    JR      C, LOC_9414                     ; JR C LOC_9414 - slot < 3: spawn unconditionally
    LD      A, ($70A6)                      ; LD A ($70A6) - load difficulty level
    CP      $05                             ; CP $05 - difficulty >= 5?
    JR      NC, LOC_9414                    ; JR NC LOC_9414 - difficulty >= 5: spawn anyway
    CP      $02                             ; CP $02 - difficulty >= 2?
    RET     M                               ; RET M - difficulty < 2: block slot-3 spawn

LOC_9414:                                   ; LOC_9414: init new barrel entity for spawn
    LD      (IX+0), $05                     ; LD (IX+0) $05 - set active + type flags = $05
    LD      (IX+12), $FE                    ; LD (IX+12) $FE - X velocity = -2 (leftward)
    LD      (IX+13), $00                    ; LD (IX+13) $00 - Y velocity = 0
    LD      (IX+9), $04                     ; LD (IX+9) $04 - state flags = $04
    LD      (IX+8), $00                     ; LD (IX+8) $00 - clear movement flags
    LD      (IX+6), $00                     ; LD (IX+6) $00 - reset animation frame counter
    LD      A, ($702C)                      ; LD A ($702C) - load level type
    CP      $02                             ; CP $02 - elevator level?
    JR      Z, LOC_9441                     ; JR Z LOC_9441 - yes: use elevator spawn params
    LD      HL, $9480                       ; LD HL $9480 - girder-level spawn param table
    CALL    SUB_946C                        ; CALL SUB_946C - load spawn params from table
    BIT     0, C                            ; BIT 0 C - test slot bit 0 (even/odd)
    RET     Z                               ; RET Z - even slot: no X position override
    LD      (IY+1), $C8                     ; LD (IY+1) $C8 - odd slot: override sprite start X = $C8
    RET                                     ; RET

LOC_9441:                                   ; LOC_9441: elevator-level spawn - select param table entry
    LD      HL, $9484                       ; LD HL $9484 - elevator param entry 1 ($9484)
    LD      A, C                            ; LD A C - slot index
    CP      $01                             ; CP $01 - slot 1?
    JR      Z, SUB_946C                     ; JR Z SUB_946C - yes: use entry 1
    JR      NC, LOC_945A                    ; JR NC LOC_945A - slot > 1: check higher entries
    LD      HL, $9488                       ; LD HL $9488 - elevator param entry 2 ($9488)
    LD      A, ($70A6)                      ; LD A ($70A6) - load difficulty
    CP      $05                             ; CP $05 - difficulty >= 5?
    JR      NC, SUB_946C                    ; JR NC SUB_946C - yes: use entry 2
    LD      HL, $948C                       ; LD HL $948C - difficulty < 5: use entry 3 ($948C)
    JR      SUB_946C                        ; JR SUB_946C

LOC_945A:                                   ; LOC_945A: slot 2+: select harder spawn params
    LD      HL, $9490                       ; LD HL $9490 - elevator param entry 4 ($9490)
    LD      A, C                            ; LD A C - slot index
    CP      $03                             ; CP $03 - slot 3?
    JR      NZ, SUB_946C                    ; JR NZ SUB_946C - not slot 3: use entry 4
    LD      A, ($70A6)                      ; LD A ($70A6) - difficulty
    CP      $05                             ; CP $05 - difficulty >= 5?
    JR      C, SUB_946C                     ; JR C SUB_946C - difficulty < 5: use entry 4
    LD      HL, $948C                       ; LD HL $948C - slot 3 + difficulty >= 5: use entry 3

SUB_946C:                                   ; SUB_946C: load barrel spawn params: entity fields and sprite start position
    LD      A, (HL)                         ; LD A (HL) - param[0]
    LD      (IX+10), A                      ; LD (IX+10) A - entity +10 = param[0]
    INC     HL                              ; INC HL
    LD      A, (HL)                         ; LD A (HL) - param[1]
    LD      (IX+11), A                      ; LD (IX+11) A - entity +11 = param[1]
    INC     HL                              ; INC HL
    LD      A, (HL)                         ; LD A (HL) - param[2]
    LD      (IY+1), A                       ; LD (IY+1) A - sprite start X = param[2]
    INC     HL                              ; INC HL
    LD      A, (HL)                         ; LD A (HL) - param[3]
    LD      (IY+3), A                       ; LD (IY+3) A - sprite start Y = param[3]
    RET                                     ; RET
    DB      $01, $00, $1C, $80, $01, $04, $DC, $70 ; spawn param table: entry 0 ($9480) and entry 1 ($9484)
    DB      $02, $00, $20, $50, $01, $01, $64, $80 ; spawn param table: entry 2 ($9488) and entry 3 ($948C)
    DB      $03, $00, $B8, $40              ; spawn param table: entry 4 ($9490)

SUB_9494:                                   ; SUB_9494: barrel 4-slot display and player-hit check outer loop
    LD      C, $00                          ; LD C $00 - slot index = 0

LOC_9496:                                   ; LOC_9496: per-slot: load entity, check active, update, display
    PUSH    BC                              ; PUSH BC - save slot counter
    CALL    SUB_9639                        ; CALL SUB_9639 - load slot C entity into IX/IY
    BIT     0, (IX+0)                       ; BIT 0 (IX+0) - test active flag
    JR      Z, LOC_94B1                     ; JR Z LOC_94B1 - not active: skip
    CALL    SUB_94B9                        ; CALL SUB_94B9 - barrel movement update
    LD      A, (IX+3)                       ; LD A (IX+3) - load entity signal handle (+3)
    CALL    SUB_9A66                        ; CALL SUB_9A66 - test Y-movement timer signal
    JR      Z, LOC_94B1                     ; JR Z LOC_94B1 - timer not fired: skip display
    CALL    SUB_9672                        ; CALL SUB_9672 - advance animation frame
    CALL    SUB_9940                        ; CALL SUB_9940 - display entity via PUTOBJ

LOC_94B1:                                   ; LOC_94B1: advance to next slot
    POP     BC                              ; POP BC - restore slot counter
    INC     C                               ; INC C - next slot
    LD      A, C                            ; LD A C
    CP      $04                             ; CP $04 - all 4 slots processed?
    JR      C, LOC_9496                     ; JR C LOC_9496 - no: loop
    RET                                     ; RET

SUB_94B9:                                   ; SUB_94B9: barrel movement update for active slot
    BIT     2, (IX+0)                       ; BIT 2 (IX+0) - test in-flight flag (bit 2)
    RET     Z                               ; RET Z - not in flight: done
    LD      A, (IX+14)                      ; LD A (IX+14) - load X-boundary signal handle
    CALL    SUB_9A66                        ; CALL SUB_9A66 - test signal
    RET     Z                               ; RET Z - signal not fired: hold position
    BIT     0, (IX+8)                       ; BIT 0 (IX+8) - test elevator-riding flag
    JP      NZ, LOC_9751                    ; JP NZ LOC_9751 - on elevator: go to X/Y boundary movement
    BIT     1, (IX+8)                       ; BIT 1 (IX+8) - test falling flag
    JR      Z, LOC_94EE                     ; JR Z LOC_94EE - not falling: handle Y direction
    CALL    SUB_969D                        ; CALL SUB_969D - determine Y direction from tile/lane
    BIT     1, (IX+9)                       ; BIT 1 (IX+9) - left-move flag
    JR      Z, LOC_94E0                     ; JR Z LOC_94E0 - not going left: check right flag
    DEC     (IX+10)                         ; DEC (IX+10) - going left: decrement X counter
    JR      LOC_94E9                        ; JR LOC_94E9

LOC_94E0:                                   ; LOC_94E0: check right-move flag
    BIT     0, (IX+9)                       ; BIT 0 (IX+9) - right-move flag
    JR      Z, LOC_94E9                     ; JR Z LOC_94E9 - neither: skip
    INC     (IX+10)                         ; INC (IX+10) - going right: increment X counter

LOC_94E9:                                   ; LOC_94E9: clear Y velocity
    LD      (IX+11), $00                    ; LD (IX+11) $00 - zero Y velocity
    RET                                     ; RET

LOC_94EE:                                   ; LOC_94EE: Y direction dispatch via IX+13
    LD      A, (IX+13)                      ; LD A (IX+13) - load Y direction byte
    OR      A                               ; OR A - test if zero
    JR      Z, LOC_9530                     ; JR Z LOC_9530 - zero: check direction-change timer
    JP      M, LOC_94FF                     ; JP M LOC_94FF - negative: going up
    BIT     0, (IX+9)                       ; BIT 0 (IX+9) - going down: test right-move flag
    JR      Z, LOC_9530                     ; JR Z LOC_9530 - no flag: direction timer
    JR      LOC_9505                        ; JR LOC_9505 - enter lateral movement

LOC_94FF:                                   ; LOC_94FF: going up: test left-move flag
    BIT     1, (IX+9)                       ; BIT 1 (IX+9) - left-move flag
    JR      Z, LOC_9530                     ; JR Z LOC_9530 - no flag: direction timer

LOC_9505:                                   ; LOC_9505: begin lateral movement for barrel
    LD      (IX+8), $02                     ; LD (IX+8) $02 - set lateral-active flag
    CALL    SOUND_WRITE_98CF                ; CALL SOUND_WRITE_98CF - scan Y slots right-direction for lane match
    CP      $FF                             ; CP $FF - lane found?
    JR      NZ, LOC_9513                    ; JR NZ LOC_9513 - yes: use found lane
    CALL    SUB_98CB                        ; CALL SUB_98CB - no right slot: scan left-direction

LOC_9513:                                   ; LOC_9513: set barrel sprite position to lane entry
    CALL    SUB_9877                        ; CALL SUB_9877 - load Y lane data into RAM buffer
    LD      A, ($70C0)                      ; LD A ($70C0) - lane start X
    LD      (IY+1), A                       ; LD (IY+1) A - barrel sprite X = lane start X
    LD      A, ($70C4)                      ; LD A ($70C4) - default lane Y (right-direction)
    BIT     1, (IX+9)                       ; BIT 1 (IX+9) - going left?
    JR      NZ, LOC_9528                    ; JR NZ LOC_9528 - yes: use default Y
    LD      A, ($70C2)                      ; LD A ($70C2) - going right: use alternate lane Y

LOC_9528:                                   ; LOC_9528: store barrel Y and clear X velocity
    LD      (IY+3), A                       ; LD (IY+3) A - barrel sprite Y
    LD      (IX+12), $00                    ; LD (IX+12) $00 - zero X velocity
    RET                                     ; RET

LOC_9530:                                   ; LOC_9530: direction-change timer: check X-active flag
    BIT     2, (IX+9)                       ; BIT 2 (IX+9) - X-active flag
    RET     Z                               ; RET Z - not active: done
    CALL    SUB_99B2                        ; CALL SUB_99B2 - apply X movement
    RES     1, (IX+9)                       ; RES 1 (IX+9) - clear left-move flag
    RES     0, (IX+9)                       ; RES 0 (IX+9) - clear right-move flag
    CALL    SOUND_WRITE_98CF                ; CALL SOUND_WRITE_98CF - scan right: find Y lane slot
    CP      $FF                             ; CP $FF - no right slot?
    JR      Z, LOC_954D                     ; JR Z LOC_954D - no: try left
    SET     1, (IX+9)                       ; SET 1 (IX+9) - right slot found: set left-move flag
    JR      LOC_9557                        ; JR LOC_9557

LOC_954D:                                   ; LOC_954D: no right slot - try left
    CALL    SUB_98CB                        ; CALL SUB_98CB - scan left: find Y lane slot
    CP      $FF                             ; CP $FF - no left slot?
    RET     Z                               ; RET Z - no slot either: done
    SET     0, (IX+9)                       ; SET 0 (IX+9) - left slot found: set right-move flag

LOC_9557:                                   ; LOC_9557: confirm X-active flag
    SET     2, (IX+9)                       ; SET 2 (IX+9) - set X-active flag
    RET                                     ; RET

SUB_955C:                                   ; SUB_955C: bonus/hammer power-up handler
    LD      A, ($70E0)                      ; LD A ($70E0) - load power-up state byte
    BIT     5, A                            ; BIT 5 A - test hammer-active flag
    JR      NZ, LOC_958F                    ; JR NZ LOC_958F - hammer active: go update it
    LD      A, ($70EA)                      ; LD A ($70EA) - load hammer entity flag
    BIT     0, A                            ; BIT 0 A - test visible/initialized bit
    RET     Z                               ; RET Z - hammer not visible: return
    LD      A, $CF                          ; LD A $CF - off-screen Y value
    LD      ($7290), A                      ; LD ($7290) A - move hammer sprite off-screen
    SUB     A                               ; SUB A - A=0
    LD      ($70EA), A                      ; LD ($70EA) A - clear hammer entity flag
    LD      IX, $B5E5                       ; LD IX $B5E5 - hammer object record at $B5E5
    LD      B, $01                          ; LD B $01 - sprite mode
    CALL    PUTOBJ                          ; CALL PUTOBJ - hide/remove hammer sprite
    LD      A, ($70ED)                      ; LD A ($70ED) - hammer animation signal handle
    CALL    FREE_SIGNAL                     ; CALL FREE_SIGNAL - free animation signal
    LD      A, ($70F3)                      ; LD A ($70F3) - hammer hit-check signal handle
    CALL    FREE_SIGNAL                     ; CALL FREE_SIGNAL - free hit-check signal
    CALL    SUB_9A5E                        ; CALL SUB_9A5E - re-init sound engine (7 channels)
    LD      B, $01                          ; LD B $01 - sound channel 1
    JP      SUB_9930                        ; JP SUB_9930 - play deactivation sound and return

LOC_958F:                                   ; LOC_958F: hammer is active - initialize or update
    LD      IX, $70EA                       ; LD IX $70EA - hammer entity data at $70EA
    LD      IY, $728D                       ; LD IY $728D - hammer sprite record at $728D
    LD      A, ($70EA)                      ; LD A ($70EA) - load hammer entity flag
    BIT     0, A                            ; BIT 0 A - test initialized bit
    JR      NZ, LOC_95D0                    ; JR NZ LOC_95D0 - already initialized: check duration timer
    CALL    SUB_9A5E                        ; CALL SUB_9A5E - init sound engine for hammer sounds
    LD      B, $02                          ; LD B $02 - sound channel 2
    CALL    SUB_9930                        ; CALL SUB_9930 - play hammer activation sound
    LD      A, $01                          ; LD A $01 - initialized flag = 1
    LD      ($70EA), A                      ; LD ($70EA) A - mark hammer as initialized
    LD      HL, $0007                       ; LD HL $0007 - signal period = 7 frames
    CALL    SUB_99A1                        ; CALL SUB_99A1 - allocate periodic signal (hammer swing animation)
    LD      ($70ED), A                      ; LD ($70ED) A - store swing animation signal handle
    LD      HL, $0003                       ; LD HL $0003 - signal period = 3 frames
    CALL    SUB_99A1                        ; CALL SUB_99A1 - allocate periodic signal (hammer hit-check rate)
    LD      ($70F3), A                      ; LD ($70F3) A - store hit-check signal handle
    LD      HL, $B5E5                       ; LD HL $B5E5 - hammer object record pointer
    LD      ($70EB), HL                     ; LD ($70EB) HL - store hammer object pointer in RAM
    SUB     A                               ; SUB A - A=0
    LD      ($70F0), A                      ; LD ($70F0) A - clear hammer phase counter
    LD      HL, $0320                       ; LD HL $0320 - timer period = $0320 (800 frames)
    CALL    SUB_99A5                        ; CALL SUB_99A5 - allocate one-shot signal (hammer duration)
    LD      ($714C), A                      ; LD ($714C) A - store hammer-duration signal handle

LOC_95D0:                                   ; LOC_95D0: hammer active - check duration signal
    LD      A, ($714C)                      ; LD A ($714C) - load hammer-duration signal handle
    CALL    SUB_9A66                        ; CALL SUB_9A66 - test signal (duration expired?)
    JR      Z, LOC_95DE                     ; JR Z LOC_95DE - expired: go update enemy position
    LD      HL, $70E0                       ; LD HL $70E0 - power-up flags address
    RES     5, (HL)                         ; RES 5 (HL) - clear hammer-active flag in power-up byte
    RET                                     ; RET

LOC_95DE:                                   ; LOC_95DE: hammer duration expired - position enemy relative to player
    LD      A, ($7135)                      ; LD A ($7135) - player sprite X
    SUB     $0F                             ; SUB $0F - subtract 15 (center offset)
    LD      ($728E), A                      ; LD ($728E) A - store enemy X relative to player
    LD      A, ($7137)                      ; LD A ($7137) - player sprite Y
    SUB     $0F                             ; SUB $0F - subtract 15
    LD      ($7290), A                      ; LD ($7290) A - store enemy Y relative to player
    LD      A, ($70F3)                      ; LD A ($70F3) - hit-check signal handle
    CALL    SUB_9A66                        ; CALL SUB_9A66 - test signal
    RET     Z                               ; RET Z - not fired: skip enemy display
    LD      HL, $B617                       ; LD HL $B617 - sprite table for hammer-high position
    LD      A, ($7134)                      ; LD A ($7134) - player Y position
    CP      $06                             ; CP $06 - compare to threshold 6
    JR      NC, LOC_9602                    ; JR NC LOC_9602 - Y >= 6: use $B617 (hammer high)
    LD      HL, $B613                       ; LD HL $B613 - Y < 6: use $B613 (hammer low)

LOC_9602:                                   ; LOC_9602: load sprite animation table and advance frame
    LD      A, $04                          ; LD A $04 - field index 4
    CALL    SUB_9A8B                        ; CALL SUB_9A8B - store HL sprite table at (IX+4) word slot
    LD      A, ($70ED)                      ; LD A ($70ED) - swing animation signal handle
    CALL    SUB_9A66                        ; CALL SUB_9A66 - test signal
    JR      Z, LOC_9612                     ; JR Z LOC_9612 - not fired: skip frame advance
    CALL    SUB_9672                        ; CALL SUB_9672 - advance animation frame

LOC_9612:                                   ; LOC_9612: display hammer sprite
    JP      SUB_9940                        ; JP SUB_9940 - display entity via PUTOBJ

SUB_9615:                                   ; SUB_9615: reset hammer sprite to idle (remove from screen)
    SUB     A                               ; SUB A - A=0
    LD      ($70EA), A                      ; LD ($70EA) A - clear hammer entity flag
    LD      ($70F0), A                      ; LD ($70F0) A - clear hammer phase counter
    LD      HL, $B5E5                       ; LD HL $B5E5 - hammer object record
    LD      ($70EB), HL                     ; LD ($70EB) HL - reset hammer object pointer
    LD      A, $01                          ; LD A $01 - sprite mode
    OR      A                               ; OR A - clear carry
    JP      ACTIVATE                        ; JP ACTIVATE - BIOS: activate/show sprite record

SUB_9628:                                   ; SUB_9628: compute |A - B| (absolute difference)
    CALL    SUB_96F4                        ; CALL SUB_96F4 - HL = A - B; carry if A < B
    JR      NC, LOC_9630                    ; JR NC LOC_9630 - A >= B: difference is A-B already
    PUSH    BC                              ; PUSH BC - save BC
    LD      B, A                            ; LD B A - B = A (smaller value)
    POP     AF                              ; POP AF - A = original B (larger value from stack)

LOC_9630:                                   ; LOC_9630: compute difference with larger value in A
    PUSH    HL                              ; PUSH HL
    PUSH    DE                              ; PUSH DE
    CALL    SUB_96FC                        ; CALL SUB_96FC - HL = A - B (A>=B so result is |A-B|)
    LD      A, L                            ; LD A L - A = |A - B| (low byte)
    POP     DE                              ; POP DE
    POP     HL                              ; POP HL
    RET                                     ; RET

SUB_9639:                                   ; SUB_9639: load barrel slot C entity pointers into IX and IY
    PUSH    BC                              ; PUSH BC - save BC
    LD      B, $00                          ; LD B $00 - B=0 for 16-bit BC = C
    LD      HL, $B62A                       ; LD HL $B62A - barrel slot pointer table base
    ADD     HL, BC                          ; ADD HL BC - HL += C
    ADD     HL, BC                          ; ADD HL BC - HL += C*2 (2 bytes per entry)
    LD      C, (HL)                         ; LD C (HL) - C = low byte of entity pointer
    INC     HL                              ; INC HL
    LD      B, (HL)                         ; LD B (HL) - B = high byte of entity pointer
    PUSH    BC                              ; PUSH BC
    POP     IX                              ; POP IX - IX = entity pointer from table[C]
    POP     BC                              ; POP BC - restore original BC

SUB_9648:                                   ; SUB_9648: load entity display pointer into IY via field 1 of IX
    LD      A, $01                          ; LD A $01 - field index 1
    CALL    SUB_9983                        ; CALL SUB_9983 - HL = 16-bit pointer at (IX+1)

SUB_964D:                                   ; SUB_964D: load IX pointer from field 2 into HL then IY; restore IX
    PUSH    IX                              ; PUSH IX - save current IX
    PUSH    HL                              ; PUSH HL
    POP     IX                              ; POP IX - IX = HL (temporary)
    LD      A, $02                          ; LD A $02 - field index 2
    CALL    SUB_9983                        ; CALL SUB_9983 - HL = 16-bit pointer at (IX+2)
    PUSH    HL                              ; PUSH HL
    POP     IY                              ; POP IY - IY = pointer from field 2
    POP     IX                              ; POP IX - restore original IX
    RET                                     ; RET

LOC_965D:                                   ; LOC_965D: indexed byte read: A = [HL + A]
    PUSH    DE                              ; PUSH DE - save DE
    LD      E, A                            ; LD E A - E = A (byte offset)
    LD      D, $00                          ; LD D $00 - DE = A (16-bit)
    ADD     HL, DE                          ; ADD HL DE - HL += A
    LD      A, (HL)                         ; LD A (HL) - A = byte at [HL+A]
    OR      A                               ; OR A - set flags
    POP     DE                              ; POP DE - restore DE
    RET                                     ; RET

SUB_9666:                                   ; SUB_9666: advance IX by A and read byte: A = (IX+A), sets Z if zero
    PUSH    BC                              ; PUSH BC - save BC
    LD      C, A                            ; LD C A - C = A (byte offset)
    LD      B, $00                          ; LD B $00 - BC = A
    ADD     IX, BC                          ; ADD IX BC - IX += A
    LD      A, (IX+0)                       ; LD A (IX+0) - A = byte at new IX
    OR      A                               ; OR A - set flags (Z if zero)
    POP     BC                              ; POP BC - restore BC
    RET                                     ; RET

SUB_9672:                                   ; SUB_9672: advance animation frame for entity at IX
    LD      A, $04                          ; LD A $04 - field index 4
    CALL    SUB_9983                        ; CALL SUB_9983 - HL = animation table pointer at (IX+4)
    LD      E, (IX+6)                       ; LD E (IX+6) - E = current animation frame counter
    LD      D, $00                          ; LD D $00 - DE = frame counter
    ADD     HL, DE                          ; ADD HL DE - HL += frame * 1
    ADD     HL, DE                          ; ADD HL DE - HL += frame * 2 (2 bytes per frame entry)
    LD      A, (HL)                         ; LD A (HL) - A = sprite tile for this frame
    LD      (IY+0), A                       ; LD (IY+0) A - sprite tile = frame tile
    INC     HL                              ; INC HL
    LD      A, (HL)                         ; LD A (HL) - A = next frame index (linked list)
    LD      (IX+6), A                       ; LD (IX+6) A - store next frame counter
    RET                                     ; RET

SUB_9688:                                   ; SUB_9688: copy active controller state to RAM buffer $70B2
    LD      HL, $7042                       ; LD HL $7042 - player 1 controller data table
    LD      A, (CONTROLLER_BUFFER)          ; LD A (CONTROLLER_BUFFER) - load player select (0=P1, 1=P2)
    OR      A                               ; OR A - test
    JR      Z, LOC_9694                     ; JR Z LOC_9694 - player 1: use $7042
    LD      HL, $7047                       ; LD HL $7047 - player 2: use $7047

LOC_9694:                                   ; LOC_9694: copy 5 bytes to $70B2
    LD      DE, $70B2                       ; LD DE $70B2 - destination RAM $70B2
    LD      BC, $0005                       ; LD BC $0005 - 5 bytes
    LDIR                                    ; LDIR - copy controller data to working buffer
    RET                                     ; RET

SUB_969D:                                   ; SUB_969D: set barrel Y direction from lane position check
    CALL    SUB_9877                        ; CALL SUB_9877 - load Y lane data into buffer
    LD      (IX+12), $00                    ; LD (IX+12) $00 - zero X velocity
    LD      A, (IY+3)                       ; LD A (IY+3) - load barrel sprite Y
    ADD     A, (IX+13)                      ; ADD A (IX+13) - add current Y direction
    LD      C, A                            ; LD C A - C = new Y position
    RES     1, (IX+9)                       ; RES 1 (IX+9) - clear left-bound flag
    RES     0, (IX+9)                       ; RES 0 (IX+9) - clear right-bound flag
    SET     3, (IX+9)                       ; SET 3 (IX+9) - set scanning flag
    LD      A, (IX+13)                      ; LD A (IX+13) - load Y direction
    OR      A                               ; OR A - test if zero
    JR      Z, LOC_96EF                     ; JR Z LOC_96EF - zero: just store new Y
    JP      P, LOC_96D0                     ; JP P LOC_96D0 - positive: going down
    LD      A, ($70C2)                      ; LD A ($70C2) - top Y limit for lane
    LD      B, C                            ; LD B C - B = new Y
    CALL    SUB_96F4                        ; CALL SUB_96F4 - carry if top_limit < new_Y (still above top)
    JR      C, LOC_96EF                     ; JR C LOC_96EF - above top: not yet at boundary
    LD      C, A                            ; LD C A - C = top_limit (clamped)
    SET     0, (IX+9)                       ; SET 0 (IX+9) - set right-bound flag: reached top
    JR      LOC_96DF                        ; JR LOC_96DF

LOC_96D0:                                   ; LOC_96D0: going down - check bottom limit
    LD      A, C                            ; LD A C - A = new Y
    LD      HL, $70C4                       ; LD HL $70C4 - bottom Y limit address
    LD      B, (HL)                         ; LD B (HL) - B = bottom limit
    CALL    SUB_96F4                        ; CALL SUB_96F4 - carry if new_Y < bottom_limit
    JR      C, LOC_96EF                     ; JR C LOC_96EF - still above bottom: continue
    LD      C, A                            ; LD C A - C = new_Y (at/below bottom)
    SET     1, (IX+9)                       ; SET 1 (IX+9) - set left-bound flag: reached bottom

LOC_96DF:                                   ; LOC_96DF: boundary reached - stop Y motion, enable X motion
    LD      (IX+13), $00                    ; LD (IX+13) $00 - zero Y velocity
    RES     1, (IX+8)                       ; RES 1 (IX+8) - clear falling flag
    SET     2, (IX+9)                       ; SET 2 (IX+9) - set X-active flag
    RES     3, (IX+9)                       ; RES 3 (IX+9) - clear scanning flag

LOC_96EF:                                   ; LOC_96EF: store new barrel Y position
    LD      A, C                            ; LD A C - A = new Y (clamped or original)
    LD      (IY+3), A                       ; LD (IY+3) A - store barrel sprite Y
    RET                                     ; RET

SUB_96F4:                                   ; SUB_96F4: unsigned compare A vs B; carry if A < B (preserves HL/DE)
    PUSH    HL                              ; PUSH HL - save HL
    PUSH    DE                              ; PUSH DE - save DE
    CALL    SUB_96FC                        ; CALL SUB_96FC - HL = A - B; carry if A < B
    POP     DE                              ; POP DE - restore DE
    POP     HL                              ; POP HL - restore HL
    RET                                     ; RET

SUB_96FC:                                   ; SUB_96FC: unsigned compare A vs B -> HL = A-B; carry if A < B
    LD      D, $00                          ; LD D $00 - D=0
    LD      H, D                            ; LD H D - H=0
    LD      L, A                            ; LD L A - HL = A (16-bit)
    LD      E, B                            ; LD E B - E = B
    OR      A                               ; OR A - clear carry flag
    SBC     HL, DE                          ; SBC HL DE - HL = A - B; carry set if A < B (unsigned)
    RET                                     ; RET

DELAY_LOOP_9705:                            ; DELAY_LOOP_9705: fill 5 IX bytes with $A2; compute scaled values if H bit7 clear
    PUSH    HL                              ; PUSH HL - save HL (holds period)
    PUSH    IX                              ; PUSH IX - save IX
    PUSH    DE                              ; PUSH DE - save DE
    PUSH    BC                              ; PUSH BC - save BC
    LD      B, $05                          ; LD B $05 - fill count = 5 bytes
    LD      A, $A2                          ; LD A $A2 - fill value $A2

LOC_970E:                                   ; LOC_970E: fill 5 bytes at IX with $A2
    LD      (IX+0), A                       ; LD (IX+0) A - write $A2 to (IX)
    INC     IX                              ; INC IX - advance to next byte
    DJNZ    LOC_970E                        ; DJNZ LOC_970E - repeat 5 times
    BIT     7, H                            ; BIT 7 H - test HL sign (negative period = no scaling)
    JR      NZ, LOC_972F                    ; JR NZ LOC_972F - negative: skip scaling, restore and return
    LD      DE, $000A                       ; LD DE $000A - divisor = 10
    LD      C, D                            ; LD C D - C = 0
    DEC     B                               ; DEC B - B = $FF (wraps to 255 as counter sentinel)
    DEC     IX                              ; DEC IX - back to last written byte

LOC_9720:                                   ; LOC_9720: compute scaled byte values for IX buffer
    CALL    SUB_973B                        ; CALL SUB_973B - HL /= DE: HL = quotient, BC = remainder
    LD      A, C                            ; LD A C - A = remainder low byte
    ADD     A, $A2                          ; ADD A $A2 - add base offset $A2
    DEC     IX                              ; DEC IX - step back one byte
    LD      (IX+0), A                       ; LD (IX+0) A - store scaled value
    LD      A, H                            ; LD A H - test HL (quotient) for zero
    OR      L                               ; OR L
    JR      NZ, LOC_9720                    ; JR NZ LOC_9720 - HL != 0: continue scaling loop

LOC_972F:                                   ; LOC_972F: restore registers and return
    POP     BC                              ; POP BC - restore BC
    POP     DE                              ; POP DE - restore DE
    POP     IX                              ; POP IX - restore IX
    POP     HL                              ; POP HL - restore HL
    RET                                     ; RET

SUB_9735:                                   ; SUB_9735: VDP enable display (reg 1 = $C2)
    LD      BC, $01C2                       ; LD BC $01C2 - B=reg1, C=$C2 (8x8 sprites, display enable)
    JP      WRITE_REGISTER                  ; JP WRITE_REGISTER - BIOS: write VDP register

SUB_973B:                                   ; SUB_973B: integer division HL / DE -> quotient HL, remainder BC
    LD      BC, BOOT_UP                     ; LD BC BOOT_UP - BC = $0000 (quotient = 0)
    OR      A                               ; OR A - clear carry

LOC_973F:                                   ; LOC_973F: subtract loop
    SBC     HL, DE                          ; SBC HL DE - HL -= DE; carry on borrow
    INC     BC                              ; INC BC - quotient++
    JR      NC, LOC_973F                    ; JR NC LOC_973F - no borrow: keep subtracting
    DEC     BC                              ; DEC BC - one over: undo last increment
    ADD     HL, DE                          ; ADD HL DE - restore remainder
    PUSH    BC                              ; PUSH BC - push quotient
    LD      B, H                            ; LD B H - B = remainder high
    LD      C, L                            ; LD C L - C = remainder low
    POP     HL                              ; POP HL - HL = quotient
    RET                                     ; RET - returns: HL=quotient, BC=remainder

LOC_974B:                                   ; LOC_974B: VDP blank display (reg 1 = $E2)
    LD      BC, $01E2                       ; LD BC $01E2 - B=reg1, C=$E2 (blank display, 8x8 sprites)
    JP      WRITE_REGISTER                  ; JP WRITE_REGISTER - BIOS: write VDP register

LOC_9751:                                   ; LOC_9751: barrel X/Y boundary movement with gravity
    INC     (IX+13)                         ; INC (IX+13) - increment Y velocity (gravity acceleration)
    LD      A, (IY+1)                       ; LD A (IY+1) - load barrel sprite X
    ADD     A, (IX+12)                      ; ADD A (IX+12) - add X velocity
    LD      (IY+1), A                       ; LD (IY+1) A - store new barrel X
    LD      A, (IY+3)                       ; LD A (IY+3) - load barrel sprite Y
    ADD     A, (IX+13)                      ; ADD A (IX+13) - add Y velocity
    LD      C, A                            ; LD C A - C = new barrel Y
    LD      A, $74                          ; LD A $74 - bitmask $74
    CPL                                     ; CPL - ~$74 = $8B
    AND     (IX+9)                          ; AND (IX+9) - clear flag bits 0,1,2,4 in state flags
    LD      (IX+9), A                       ; LD (IX+9) A - store updated state flags
    LD      A, (IY+3)                       ; LD A (IY+3) - reload barrel Y (before update)
    LD      HL, $70B0                       ; LD HL $70B0 - floor boundary address
    LD      B, (HL)                         ; LD B (HL) - B = floor Y value
    CALL    SUB_96F4                        ; CALL SUB_96F4 - carry if barrel_Y < floor_Y
    JR      C, LOC_9788                     ; JR C LOC_9788 - above floor: check X boundaries
    SET     4, (IX+9)                       ; SET 4 (IX+9) - set floor-landing flag
    BIT     4, (IX+0)                       ; BIT 4 (IX+0) - test special-entity type flag
    JR      NZ, LOC_97C7                    ; JR NZ LOC_97C7 - special entity: skip floor snap
    LD      (IY+3), B                       ; LD (IY+3) B - snap barrel Y to floor
    JR      LOC_97F6                        ; JR LOC_97F6 - store C and return

LOC_9788:                                   ; LOC_9788: barrel above floor - check left boundary
    LD      A, ($70AC)                      ; LD A ($70AC) - left boundary X
    LD      B, (IY+1)                       ; LD B (IY+1) - B = barrel sprite X
    CALL    SUB_96F4                        ; CALL SUB_96F4 - carry if left_bound < barrel_X
    JR      C, LOC_97A9                     ; JR C LOC_97A9 - barrel right of left bound: check right
    SET     5, (IX+9)                       ; SET 5 (IX+9) - barrel at/past left boundary: set X-boundary flag
    BIT     4, (IX+0)                       ; BIT 4 (IX+0) - special entity flag
    JR      NZ, LOC_97C7                    ; JR NZ LOC_97C7 - special: skip snap
    CALL    SUB_98C2                        ; CALL SUB_98C2 - reverse X velocity (bounce off left wall)
    LD      A, ($70AC)                      ; LD A ($70AC) - left boundary X
    INC     A                               ; INC A - one pixel right of boundary
    LD      (IY+1), A                       ; LD (IY+1) A - snap barrel X to left boundary
    JR      LOC_97C7                        ; JR LOC_97C7

LOC_97A9:                                   ; LOC_97A9: check right boundary
    LD      A, B                            ; LD A B - A = barrel X
    LD      HL, $70AE                       ; LD HL $70AE - right boundary address
    LD      B, (HL)                         ; LD B (HL) - B = right boundary X
    CALL    SUB_96F4                        ; CALL SUB_96F4 - carry if barrel_X < right_bound
    JR      C, LOC_97C7                     ; JR C LOC_97C7 - barrel left of right bound: ok
    SET     5, (IX+9)                       ; SET 5 (IX+9) - barrel at/past right boundary: set flag
    BIT     4, (IX+0)                       ; BIT 4 (IX+0) - special entity flag
    JR      NZ, LOC_97C7                    ; JR NZ LOC_97C7 - special: skip snap
    CALL    SUB_98C2                        ; CALL SUB_98C2 - reverse X velocity (bounce off right wall)
    LD      A, ($70AE)                      ; LD A ($70AE) - right boundary X
    DEC     A                               ; DEC A - one pixel left of boundary
    LD      (IY+1), A                       ; LD (IY+1) A - snap barrel X to right boundary

LOC_97C7:                                   ; LOC_97C7: find Y lane index for barrel position
    CALL    SUB_9836                        ; CALL SUB_9836 - scan lane Y ranges for match; A = lane or $FF
    CP      $FF                             ; CP $FF - no lane found?
    JR      Z, LOC_97D1                     ; JR Z LOC_97D1 - no match: skip lane store
    LD      (IX+10), A                      ; LD (IX+10) A - store Y lane index

LOC_97D1:                                   ; LOC_97D1: find X slot index for barrel X position
    CALL    SOUND_WRITE_9801                ; CALL SOUND_WRITE_9801 - scan X slots; A = slot or $FF
    CP      $FF                             ; CP $FF - no slot found?
    JR      Z, LOC_97F6                     ; JR Z LOC_97F6 - no slot: skip
    LD      (IX+11), A                      ; LD (IX+11) A - store X slot index
    LD      A, C                            ; LD A C - A = new barrel Y
    LD      HL, $70CA                       ; LD HL $70CA - lane floor Y address
    LD      B, (HL)                         ; LD B (HL) - B = lane floor Y
    CALL    SUB_96F4                        ; CALL SUB_96F4 - carry if new_Y < floor_Y
    JR      C, LOC_97F6                     ; JR C LOC_97F6 - barrel above floor: skip floor snap
    LD      A, (IY+3)                       ; LD A (IY+3) - load old barrel Y
    CALL    SUB_96F4                        ; CALL SUB_96F4 - carry if old_Y < floor_Y
    JR      NC, LOC_97F6                    ; JR NC LOC_97F6 - old_Y already at/below floor: skip
    RES     0, (IX+8)                       ; RES 0 (IX+8) - clear elevator flag
    LD      C, B                            ; LD C B - C = floor_Y (snap barrel to floor)
    SET     2, (IX+9)                       ; SET 2 (IX+9) - set on-floor flag

LOC_97F6:                                   ; LOC_97F6: store final barrel Y
    LD      (IY+3), C                       ; LD (IY+3) C - barrel sprite Y = C (new or floor-snapped)
    RET                                     ; RET

DELAY_LOOP_97FA:                            ; DELAY_LOOP_97FA: fill B bytes at (HL) with value A
    PUSH    HL                              ; PUSH HL - save base address

LOC_97FB:                                   ; LOC_97FB: write loop
    LD      (HL), A                         ; LD (HL) A - write byte
    INC     HL                              ; INC HL - advance address
    DJNZ    LOC_97FB                        ; DJNZ LOC_97FB - repeat B times
    POP     HL                              ; POP HL - restore base address
    RET                                     ; RET

SOUND_WRITE_9801:                           ; SOUND_WRITE_9801: find X slot containing barrel X position
    CALL    SUB_9968                        ; CALL SUB_9968 - load IX+10 (barrel slot index) into E
    LD      E, $FF                          ; LD E $FF - slot counter = -1 (pre-increment)

LOC_9806:                                   ; LOC_9806: scan X slots for barrel X
    INC     E                               ; INC E - next slot
    LD      HL, ($70BB)                     ; LD HL ($70BB) - pointer to X-slot count
    LD      A, E                            ; LD A E - A = current slot
    CP      (HL)                            ; CP (HL) - compare to total slot count
    JR      Z, LOC_9828                     ; JR Z LOC_9828 - reached end: return $FF
    CALL    SUB_9895                        ; CALL SUB_9895 - load slot E X-range data into $70C6
    LD      A, (IY+1)                       ; LD A (IY+1) - barrel sprite X
    LD      HL, $70C6                       ; LD HL $70C6 - left X limit
    LD      B, (HL)                         ; LD B (HL) - B = left X limit
    CALL    SUB_96F4                        ; CALL SUB_96F4 - carry if barrel_X < left_limit
    JR      C, LOC_9806                     ; JR C LOC_9806 - X left of slot range: next slot
    LD      HL, $70C8                       ; LD HL $70C8 - right X limit
    LD      B, (HL)                         ; LD B (HL) - B = right X limit
    CALL    SUB_96F4                        ; CALL SUB_96F4 - carry if barrel_X < right_limit
    JR      NC, LOC_9806                    ; JR NC LOC_9806 - X at/right of slot range: next slot
    LD      A, E                            ; LD A E - A = matched slot index
    RET                                     ; RET - return slot index

LOC_9828:                                   ; LOC_9828: no matching slot found
    LD      A, $FF                          ; LD A $FF - return $FF (no match)
    RET                                     ; RET

SUB_982B:                                   ; SUB_982B: load 16-bit word from table at HL + A*2
    PUSH    DE                              ; PUSH DE - save DE
    LD      D, $00                          ; LD D $00 - D=0
    ADD     HL, DE                          ; ADD HL DE - HL += A (using D=0, E=A from earlier)
    ADD     HL, DE                          ; ADD HL DE - HL += A*2 (2 bytes per entry)
    LD      E, (HL)                         ; LD E (HL) - E = low byte
    INC     HL                              ; INC HL
    LD      D, (HL)                         ; LD D (HL) - D = high byte
    DB      $EB                             ; DB $EB - EX DE HL (swap: HL = the loaded word)
    POP     DE                              ; POP DE - restore DE
    RET                                     ; RET

SUB_9836:                                   ; SUB_9836: find Y lane index for IY+3 (barrel Y) by scanning lane table
    LD      E, $00                          ; LD E $00 - lane index = 0

LOC_9838:                                   ; LOC_9838: scan lane Y-range entries
    CALL    SUB_996B                        ; CALL SUB_996B - load lane entry E data into RAM $70B7
    LD      A, (IY+3)                       ; LD A (IY+3) - barrel sprite Y
    LD      HL, $70B7                       ; LD HL $70B7 - lane top Y address
    CP      (HL)                            ; CP (HL) - compare barrel_Y vs lane top
    JR      C, LOC_984E                     ; JR C LOC_984E - barrel above lane top: next lane
    LD      HL, $70B9                       ; LD HL $70B9 - lane bottom Y address
    CP      (HL)                            ; CP (HL) - compare barrel_Y vs lane bottom
    JR      Z, LOC_984C                     ; JR Z LOC_984C - at bottom: found matching lane
    JR      NC, LOC_984E                    ; JR NC LOC_984E - barrel below bottom: next lane

LOC_984C:                                   ; LOC_984C: matching lane found
    LD      A, E                            ; LD A E - A = lane index
    RET                                     ; RET

LOC_984E:                                   ; LOC_984E: lane not matched - try next
    INC     E                               ; INC E - next lane index
    LD      A, ($70AB)                      ; LD A ($70AB) - total lane count
    CP      E                               ; CP E - all lanes checked?
    JR      NZ, LOC_9838                    ; JR NZ LOC_9838 - no: continue scan
    LD      A, $FF                          ; LD A $FF - no lane matched
    RET                                     ; RET

SUB_9858:                                   ; SUB_9858: reset barrel entity to default/idle state
    SUB     A                               ; SUB A - A=0
    PUSH    IX                              ; PUSH IX
    POP     HL                              ; POP HL - HL = IX (entity base address)
    LD      B, $09                          ; LD B $09 - count = 9 bytes
    CALL    DELAY_LOOP_97FA                 ; CALL DELAY_LOOP_97FA - zero 9 entity bytes from IX
    LD      A, $00                          ; LD A $00 - A=0
    LD      HL, $0190                       ; LD HL $0190 - timer period = $190 (400 frames)
    CALL    SUB_9A8B                        ; CALL SUB_9A8B - store HL=$0190 at (IX+0) word slot
    LD      (IX+6), $03                     ; LD (IX+6) $03 - animation frame = 3 (default)
    LD      A, ($70A6)                      ; LD A ($70A6) - load difficulty level
    DEC     A                               ; DEC A - difficulty - 1
    RET     NZ                              ; RET NZ - not difficulty 1: done
    LD      (IX+6), $05                     ; LD (IX+6) $05 - difficulty 1: use frame 5 instead
    RET                                     ; RET

SUB_9877:                                   ; SUB_9877: load IX+15 (lane slot index) as parameter for lane data lookup
    CALL    SUB_9968                        ; CALL SUB_9968 - load (IX+10) into E (barrel slot index)
    LD      A, (IX+15)                      ; LD A (IX+15) - A = lane slot index from entity +15

SUB_987D:                                   ; SUB_987D: copy 7-byte lane entry A into RAM $70BF
    PUSH    BC                              ; PUSH BC - save BC
    PUSH    DE                              ; PUSH DE - save DE
    LD      HL, ($70BD)                     ; LD HL ($70BD) - pointer to Y-lane table
    INC     HL                              ; INC HL - skip count word
    LD      DE, $70BF                       ; LD DE $70BF - destination RAM $70BF
    LD      BC, $0007                       ; LD BC $0007 - 7 bytes per entry
    CALL    SUB_98AA                        ; CALL SUB_98AA - copy entry A (skip A entries of 7 bytes, then copy)
    POP     DE                              ; POP DE - restore DE
    POP     BC                              ; POP BC - restore BC
    RET                                     ; RET

SUB_988F:                                   ; SUB_988F: load (IX+11) X-slot index as parameter for lane X data lookup
    CALL    SUB_9968                        ; CALL SUB_9968 - load (IX+10) into E
    LD      E, (IX+11)                      ; LD E (IX+11) - E = X-slot index from entity +11

SUB_9895:                                   ; SUB_9895: copy 6-byte X-slot entry E into RAM $70C6
    PUSH    BC                              ; PUSH BC - save BC
    PUSH    DE                              ; PUSH DE - save DE
    PUSH    AF                              ; PUSH AF - save AF
    LD      A, E                            ; LD A E - A = X-slot index
    LD      HL, ($70BB)                     ; LD HL ($70BB) - pointer to X-slot table
    INC     HL                              ; INC HL - skip count word
    LD      DE, $70C6                       ; LD DE $70C6 - destination RAM $70C6
    LD      BC, $0006                       ; LD BC $0006 - 6 bytes per entry
    CALL    SUB_98AA                        ; CALL SUB_98AA - copy X-slot entry A
    POP     AF                              ; POP AF - restore AF
    POP     DE                              ; POP DE - restore DE
    POP     BC                              ; POP BC - restore BC
    RET                                     ; RET

SUB_98AA:                                   ; SUB_98AA: skip A entries (each BC bytes) in HL table, then LDIR BC bytes to DE
    DEC     A                               ; DEC A - A--
    JP      M, LOC_98B1                     ; JP M LOC_98B1 - A went negative: at correct entry
    ADD     HL, BC                          ; ADD HL BC - skip one entry (BC bytes)
    JR      SUB_98AA                        ; JR SUB_98AA - check next

LOC_98B1:                                   ; LOC_98B1: copy entry
    LDIR                                    ; LDIR - copy BC bytes from (HL) to (DE)
    RET                                     ; RET

SUB_98B4:                                   ; SUB_98B4: toggle active player (P1/P2) if 2-player game
    LD      A, ($702D)                      ; LD A ($702D) - load player count
    DEC     A                               ; DEC A - player count - 1
    RET     Z                               ; RET Z - 1 player: no toggle
    LD      HL, CONTROLLER_BUFFER           ; LD HL CONTROLLER_BUFFER - controller select buffer
    LD      A, (HL)                         ; LD A (HL) - load current player select (0=P1, 1=P2)
    CPL                                     ; CPL - invert all bits
    AND     $01                             ; AND $01 - keep bit 0 only (toggle 0<->1)
    LD      (HL), A                         ; LD (HL) A - store new player select
    RET                                     ; RET

SUB_98C2:                                   ; SUB_98C2: reverse barrel X velocity (negate IX+12)
    LD      A, (IX+12)                      ; LD A (IX+12) - load X velocity
    NEG                                     ; NEG - negate
    LD      (IX+12), A                      ; LD (IX+12) A - store reversed velocity
    RET                                     ; RET

SUB_98CB:                                   ; SUB_98CB: scan Y lanes with C=0 (left-direction search)
    LD      C, $00                          ; LD C $00 - C=0: left-direction
    JR      LOC_98D1                        ; JR LOC_98D1

SOUND_WRITE_98CF:                           ; SOUND_WRITE_98CF: scan Y lanes with C=1 (right-direction search)
    LD      C, $01                          ; LD C $01 - C=1: right-direction

LOC_98D1:                                   ; LOC_98D1: scan Y lanes for barrel vertical position match
    CALL    SUB_9968                        ; CALL SUB_9968 - load (IX+10) into E
    LD      E, $FF                          ; LD E $FF - lane counter = -1 (pre-increment)

LOC_98D6:                                   ; LOC_98D6: increment lane and check against total
    INC     E                               ; INC E - next lane
    LD      HL, ($70BD)                     ; LD HL ($70BD) - pointer to Y-lane table (count word)
    LD      A, E                            ; LD A E - A = current lane index
    CP      (HL)                            ; CP (HL) - compare to total lane count
    JR      Z, LOC_9908                     ; JR Z LOC_9908 - reached end: return $FF
    CALL    SUB_987D                        ; CALL SUB_987D - load lane entry E into $70BF
    LD      A, ($70C0)                      ; LD A ($70C0) - lane Y reference
    LD      B, (IY+1)                       ; LD B (IY+1) - B = barrel sprite X (used as Y comparison)
    CALL    SUB_9628                        ; CALL SUB_9628 - |A - B| -> A (proximity)
    LD      B, $03                          ; LD B $03 - proximity threshold = 3
    CALL    SUB_96F4                        ; CALL SUB_96F4 - carry if proximity < 3
    JR      NC, LOC_98D6                    ; JR NC LOC_98D6 - not close: try next lane
    LD      A, C                            ; LD A C - A = direction flag (0=left, 1=right)
    OR      A                               ; OR A - test
    JR      Z, LOC_98FE                     ; JR Z LOC_98FE - C=0 (left): check $70BF < 2
    LD      A, ($70BF)                      ; LD A ($70BF) - load lane X field
    CP      $02                             ; CP $02 - lane X >= 2?
    JR      NC, LOC_9905                    ; JR NC LOC_9905 - yes: this lane matches
    JR      LOC_98D6                        ; JR LOC_98D6 - no: next lane

LOC_98FE:                                   ; LOC_98FE: left-direction: check $70BF < 2
    LD      A, ($70BF)                      ; LD A ($70BF) - lane X field
    CP      $02                             ; CP $02 - X < 2?
    JR      NC, LOC_98D6                    ; JR NC LOC_98D6 - X >= 2: skip, try next lane

LOC_9905:                                   ; LOC_9905: lane match found
    LD      A, E                            ; LD A E - A = matched lane index
    JR      LOC_990A                        ; JR LOC_990A

LOC_9908:                                   ; LOC_9908: end of lane table
    LD      A, $FF                          ; LD A $FF - no match: A = $FF

LOC_990A:                                   ; LOC_990A: store result in IX+15
    LD      (IX+15), A                      ; LD (IX+15) A - store found lane index (or $FF)
    OR      A                               ; OR A - set flags
    RET                                     ; RET

SUB_990F:                                   ; SUB_990F: erase 3 score digit tiles at VRAM $0100/$0101/$0102
    LD      DE, $0100                       ; LD DE $0100 - VRAM address $0100
    CALL    SUB_991E                        ; CALL SUB_991E - write blank tile at $0100
    LD      DE, $0101                       ; LD DE $0101 - VRAM address $0101
    CALL    SUB_991E                        ; CALL SUB_991E - write blank tile at $0101
    LD      DE, $0102                       ; LD DE $0102 - VRAM address $0102

SUB_991E:                                   ; SUB_991E: write blank (zero) tile at VRAM address DE via PUT_VRAM
    PUSH    AF                              ; PUSH AF - save AF
    PUSH    HL                              ; PUSH HL - save HL
    PUSH    DE                              ; PUSH DE - save DE
    LD      E, $00                          ; LD E $00 - E=0
    PUSH    DE                              ; PUSH DE
    POP     IY                              ; POP IY - IY = 0 (blank tile data)
    POP     DE                              ; POP DE - restore DE (VRAM address)
    LD      D, E                            ; LD D E - D = E = 0 (VRAM addr high byte = 0)
    LD      E, $00                          ; LD E $00 - E = 0
    CALL    PUT_VRAM                        ; CALL PUT_VRAM - BIOS: write 1 tile to VRAM at DE
    POP     HL                              ; POP HL - restore HL
    POP     AF                              ; POP AF - restore AF
    RET                                     ; RET

SUB_9930:                                   ; SUB_9930: call PLAY_IT preserving IX and IY
    PUSH    IX                              ; PUSH IX - save IX
    PUSH    IY                              ; PUSH IY - save IY
    CALL    PLAY_IT                         ; CALL PLAY_IT - BIOS: play sound effect channel B
    POP     IY                              ; POP IY - restore IY
    POP     IX                              ; POP IX - restore IX
    RET                                     ; RET

LOC_993C:                                   ; LOC_993C: display entity with B=0 (hide sprite)
    LD      B, $00                          ; LD B $00 - B=0: hide sprite
    JR      LOC_9942                        ; JR LOC_9942

SUB_9940:                                   ; SUB_9940: display entity sprite via PUTOBJ with B=1
    LD      B, $01                          ; LD B $01 - B=1: show sprite

LOC_9942:                                   ; LOC_9942: load PUTOBJ data record and call PUTOBJ
    PUSH    IX                              ; PUSH IX - save entity IX
    PUSH    IY                              ; PUSH IY - save sprite IY
    LD      A, $01                          ; LD A $01 - field index 1
    CALL    SUB_9983                        ; CALL SUB_9983 - HL = PUTOBJ data pointer at (IX+1)
    PUSH    HL                              ; PUSH HL
    POP     IX                              ; POP IX - IX = PUTOBJ data record
    CALL    PUTOBJ                          ; CALL PUTOBJ - BIOS: position and display object
    POP     IY                              ; POP IY - restore IY
    POP     IX                              ; POP IX - restore entity IX
    RET                                     ; RET

SUB_9956:                                   ; SUB_9956: generate pseudo-random byte (RAND_GEN XOR R register)
    PUSH    IX                              ; PUSH IX - save IX
    PUSH    IY                              ; PUSH IY - save IY
    PUSH    BC                              ; PUSH BC - save BC
    CALL    RAND_GEN                        ; CALL RAND_GEN - BIOS LCG random -> A
    LD      B, A                            ; LD B A - B = RAND_GEN result
    LD      A, R                            ; LD A R - A = Z80 R (refresh) register
    XOR     B                               ; XOR B - A ^= RAND_GEN result (extra entropy)
    POP     BC                              ; POP BC - restore BC
    POP     IY                              ; POP IY - restore IY
    POP     IX                              ; POP IX - restore IX
    RET                                     ; RET

SUB_9968:                                   ; SUB_9968: load entity slot index (IX+10) into E
    LD      E, (IX+10)                      ; LD E (IX+10) - E = barrel/entity slot index from IX+10

SUB_996B:                                   ; SUB_996B: load lane table entry E (8 bytes) into RAM $70B7
    PUSH    AF                              ; PUSH AF - save AF
    PUSH    BC                              ; PUSH BC - save BC
    PUSH    DE                              ; PUSH DE - save DE
    LD      A, E                            ; LD A E - A = lane index
    LD      HL, ($70A9)                     ; LD HL ($70A9) - pointer to main lane table
    LD      BC, $0007                       ; LD BC $0007 - 7 bytes offset to skip count word
    ADD     HL, BC                          ; ADD HL BC - advance past count word
    LD      DE, $70B7                       ; LD DE $70B7 - destination RAM $70B7
    LD      BC, $0008                       ; LD BC $0008 - 8 bytes per lane entry
    CALL    SUB_98AA                        ; CALL SUB_98AA - copy lane entry A to $70B7
    POP     DE                              ; POP DE - restore DE
    POP     BC                              ; POP BC - restore BC
    POP     AF                              ; POP AF - restore AF
    RET                                     ; RET

SUB_9983:                                   ; SUB_9983: load 16-bit pointer at (IX + A*1) into HL
    PUSH    IX                              ; PUSH IX - save IX
    PUSH    AF                              ; PUSH AF - save AF
    CALL    SUB_9666                        ; CALL SUB_9666 - IX += A; A = (IX+0)
    LD      L, (IX+0)                       ; LD L (IX+0) - L = low byte of pointer
    INC     IX                              ; INC IX - advance to high byte
    LD      H, (IX+0)                       ; LD H (IX+0) - H = high byte of pointer
    POP     AF                              ; POP AF - restore AF
    POP     IX                              ; POP IX - restore IX
    RET                                     ; RET
    DB      $DD, $E5, $FD, $E5, $DD, $E1, $CD, $83 ; inline data bytes following SUB_9983
    DB      $99, $DD, $E1, $C9              ; inline data bytes following SUB_9983 (continued)

SUB_99A1:                                   ; SUB_99A1: allocate repeating timer signal with period HL (A=1)
    LD      A, $01                          ; LD A $01 - A=1: periodic/repeating mode
    JR      LOC_99A6                        ; JR LOC_99A6

SUB_99A5:                                   ; SUB_99A5: allocate one-shot timer signal with period HL (A=0)
    SUB     A                               ; SUB A - A=0: one-shot mode

LOC_99A6:                                   ; LOC_99A6: call REQUEST_SIGNAL preserving IX and IY
    PUSH    IX                              ; PUSH IX - save IX
    PUSH    IY                              ; PUSH IY - save IY
    CALL    REQUEST_SIGNAL                  ; CALL REQUEST_SIGNAL - BIOS: allocate timer signal (HL=period, A=mode)
    POP     IY                              ; POP IY - restore IY
    POP     IX                              ; POP IX - restore IX
    RET                                     ; RET

SUB_99B2:                                   ; SUB_99B2: apply barrel X velocity; check elevator and wall boundaries
    LD      A, (IX+12)                      ; LD A (IX+12) - load X velocity
    ADD     A, (IY+1)                       ; ADD A (IY+1) - add to sprite X
    LD      (IY+1), A                       ; LD (IY+1) A - store new sprite X
    RES     5, (IX+9)                       ; RES 5 (IX+9) - clear X-boundary flag
    RES     2, (IX+9)                       ; RES 2 (IX+9) - clear on-floor flag
    BIT     6, (IX+9)                       ; BIT 6 (IX+9) - test elevator-attached flag
    JR      Z, LOC_99E9                     ; JR Z LOC_99E9 - not on elevator: check wall boundaries
    PUSH    IY                              ; PUSH IY - save IY
    LD      IY, ($70E8)                     ; LD IY ($70E8) - IY = elevator entity pointer
    LD      B, (IY+1)                       ; LD B (IY+1) - B = elevator sprite X
    POP     IY                              ; POP IY - restore IY
    LD      A, (IY+1)                       ; LD A (IY+1) - A = barrel sprite X
    CALL    SUB_9628                        ; CALL SUB_9628 - |barrel_X - elevator_X| -> A
    LD      B, $0C                          ; LD B $0C - proximity threshold = 12 pixels
    CALL    SUB_96F4                        ; CALL SUB_96F4 - carry if distance < 12
    RET     M                               ; RET M - negative result (carry+sign): skip
    LD      (IX+8), $01                     ; LD (IX+8) $01 - set elevator-riding flag
    RES     6, (IX+9)                       ; RES 6 (IX+9) - clear elevator-attached flag
    RET                                     ; RET

LOC_99E9:                                   ; LOC_99E9: check left wall boundary
    LD      A, (IY+1)                       ; LD A (IY+1) - barrel sprite X
    LD      B, A                            ; LD B A - B = barrel X
    LD      A, ($70AC)                      ; LD A ($70AC) - left boundary X
    CALL    SUB_96F4                        ; CALL SUB_96F4 - carry if left_bound < barrel_X
    JR      NC, LOC_99FA                    ; JR NC LOC_99FA - left_bound >= barrel_X: barrel at left wall
    CALL    SUB_9A54                        ; CALL SUB_9A54 - compare barrel X vs right boundary
    JR      C, LOC_9A1B                     ; JR C LOC_9A1B - barrel X < right_bound: barrel at right wall

LOC_99FA:                                   ; LOC_99FA: check special-entity flag
    BIT     4, (IX+0)                       ; BIT 4 (IX+0) - special entity type flag
    JR      NZ, LOC_9A12                    ; JR NZ LOC_9A12 - special: skip boundary snap
    CALL    SUB_9A54                        ; CALL SUB_9A54 - compare barrel X vs right boundary
    JR      NC, LOC_9A0B                    ; JR NC LOC_9A0B - barrel X >= right_bound: snap to right
    LD      A, ($70AC)                      ; LD A ($70AC) - left boundary
    INC     A                               ; INC A
    JR      LOC_9A0F                        ; JR LOC_9A0F

LOC_9A0B:                                   ; LOC_9A0B: barrel at right boundary
    LD      A, ($70AE)                      ; LD A ($70AE) - right boundary X
    DEC     A                               ; DEC A

LOC_9A0F:                                   ; LOC_9A0F: snap sprite X to boundary
    LD      (IY+1), A                       ; LD (IY+1) A - barrel sprite X = boundary

LOC_9A12:                                   ; LOC_9A12: set X-boundary flags
    SET     5, (IX+9)                       ; SET 5 (IX+9) - set X-boundary-hit flag
    SET     2, (IX+9)                       ; SET 2 (IX+9) - set on-floor/platform flag
    RET                                     ; RET

LOC_9A1B:                                   ; LOC_9A1B: barrel at right wall - look up horizontal slot position
    CALL    SUB_988F                        ; CALL SUB_988F - load right-side lane X data
    LD      A, (IY+1)                       ; LD A (IY+1) - barrel sprite X
    LD      HL, $70C6                       ; LD HL $70C6 - lane left X limit
    LD      B, (HL)                         ; LD B (HL) - B = lane left X
    CALL    SUB_96F4                        ; CALL SUB_96F4 - carry if barrel_X < left_X
    JR      C, LOC_9A33                     ; JR C LOC_9A33 - barrel left of slot range: find slot
    LD      HL, $70C8                       ; LD HL $70C8 - lane right X limit
    LD      B, (HL)                         ; LD B (HL) - B = lane right X
    CALL    SUB_96F4                        ; CALL SUB_96F4 - carry if barrel_X < right_X
    JR      C, LOC_9A4F                     ; JR C LOC_9A4F - barrel within slot range: set on-platform

LOC_9A33:                                   ; LOC_9A33: find horizontal slot for barrel
    CALL    SOUND_WRITE_9801                ; CALL SOUND_WRITE_9801 - scan X slots; return slot index or $FF
    LD      B, A                            ; LD B A - B = slot result
    CP      $0D                             ; CP $0D - special slot 13?
    RET     Z                               ; RET Z - slot 13: skip
    CP      $FF                             ; CP $FF - no slot found?
    JR      NZ, LOC_9A43                    ; JR NZ LOC_9A43 - slot found: store it
    LD      (IX+8), $01                     ; LD (IX+8) $01 - no slot: set elevator-riding flag
    RET                                     ; RET

LOC_9A43:                                   ; LOC_9A43: store slot and snap barrel Y to floor
    LD      (IX+11), B                      ; LD (IX+11) B - store X-slot index
    CALL    SUB_988F                        ; CALL SUB_988F - reload slot X data
    LD      A, ($70CA)                      ; LD A ($70CA) - lane floor Y
    LD      (IY+3), A                       ; LD (IY+3) A - snap barrel sprite Y to floor

LOC_9A4F:                                   ; LOC_9A4F: set on-platform flag
    SET     2, (IX+9)                       ; SET 2 (IX+9) - set on-floor/platform flag
    RET                                     ; RET

SUB_9A54:                                   ; SUB_9A54: compare barrel sprite X vs right boundary ($70AE)
    LD      A, (IY+1)                       ; LD A (IY+1) - barrel sprite X
    LD      HL, $70AE                       ; LD HL $70AE - right boundary address
    LD      B, (HL)                         ; LD B (HL) - B = right boundary X
    JP      SUB_96F4                        ; JP SUB_96F4 - carry if barrel_X < right_bound

SUB_9A5E:                                   ; SUB_9A5E: init sound engine (7 channels, table at $9EA4)
    LD      B, $07                          ; LD B $07 - 7 sound channels
    LD      HL, $9EA4                       ; LD HL $9EA4 - sound table at $9EA4
    JP      SOUND_INIT                      ; JP SOUND_INIT - BIOS: init sound engine

SUB_9A66:                                   ; SUB_9A66: test signal A, preserving IX/IY/BC
    PUSH    BC                              ; PUSH BC - save BC
    PUSH    IX                              ; PUSH IX - save IX
    PUSH    IY                              ; PUSH IY - save IY
    CALL    TEST_SIGNAL                     ; CALL TEST_SIGNAL - BIOS: test if signal A has fired
    POP     IY                              ; POP IY - restore IY
    POP     IX                              ; POP IX - restore IX
    POP     BC                              ; POP BC - restore BC
    RET                                     ; RET

SUB_9A74:                                   ; SUB_9A74: advance score pointer in RAM $7165 by BC
    LD      HL, ($7165)                     ; LD HL ($7165) - load score display pointer
    ADD     HL, BC                          ; ADD HL BC - advance by BC
    LD      ($7165), HL                     ; LD ($7165) HL - store updated pointer
    RET                                     ; RET

SUB_9A7C:                                   ; SUB_9A7C: allocate one-shot signal, store handle, spin-wait for it
    CALL    SUB_99A5                        ; CALL SUB_99A5 - allocate one-shot timer signal
    LD      ($714A), A                      ; LD ($714A) A - store signal handle

LOC_9A82:                                   ; LOC_9A82: spin-wait loop until signal fires
    LD      A, ($714A)                      ; LD A ($714A) - reload signal handle
    CALL    SUB_9A66                        ; CALL SUB_9A66 - test signal
    JR      Z, LOC_9A82                     ; JR Z LOC_9A82 - not fired: loop
    RET                                     ; RET

SUB_9A8B:                                   ; SUB_9A8B: store 16-bit pointer HL into (IX+A) word slot
    PUSH    IX                              ; PUSH IX - save IX
    CALL    SUB_9666                        ; CALL SUB_9666 - advance IX by A
    LD      (IX+0), L                       ; LD (IX+0) L - store HL low byte
    INC     IX                              ; INC IX - advance to next byte
    LD      (IX+0), H                       ; LD (IX+0) H - store HL high byte
    POP     IX                              ; POP IX - restore original IX
    RET                                     ; RET
    DB      $DD, $E5, $FD, $E5, $DD, $E1, $CD, $8B ; inline data bytes following SUB_9A8B
    DB      $9A, $DD, $E1, $C9              ; inline data bytes following SUB_9A8B (continued)

SUB_9AA7:                                   ; SUB_9AA7: reset barrel entity velocity to zero
    SUB     A                               ; SUB A - A=0
    LD      (IX+12), A                      ; LD (IX+12) A - zero X velocity
    LD      (IX+13), A                      ; LD (IX+13) A - zero Y velocity
    RET                                     ; RET
    DB      $00, $01, $02, $01, $02, $06, $10, $00 ; game anim/sprite/level data row 0
    DB      $E8, $00, $B0, $00, $98, $00, $A8, $00 ; game anim/sprite/level data row 1
    DB      $12, $9D, $E7, $9B, $70, $00, $88, $00 ; game anim/sprite/level data row 2
    DB      $49, $9D, $F6, $9B, $58, $00, $68, $00 ; game anim/sprite/level data row 3
    DB      $80, $9D, $13, $9C, $30, $00, $48, $00 ; game anim/sprite/level data row 4
    DB      $B7, $9D, $37, $9C, $18, $00, $28, $00 ; game anim/sprite/level data row 5
    DB      $EE, $9D, $54, $9C, $00, $00, $08, $00 ; game anim/sprite/level data row 6
    DB      $1F, $9E, $63, $9C, $04, $18, $00, $D8 ; game anim/sprite/level data row 7
    DB      $00, $B0, $00, $90, $00, $A0, $00, $F6 ; game anim/sprite/level data row 8
    DB      $9C, $49, $9B, $70, $00, $80, $00, $FD ; game anim/sprite/level data row 9
    DB      $9C, $66, $9B, $50, $00, $60, $00, $04 ; game anim/sprite/level data row 10
    DB      $9D, $98, $9B, $30, $00, $40, $00, $0B ; game anim/sprite/level data row 11
    DB      $9D, $CA, $9B, $06, $10, $00, $F0, $00 ; game anim/sprite/level data row 12
    DB      $A0, $00, $81, $00, $90, $00, $26, $9E ; game anim/sprite/level data row 13
    DB      $64, $9C, $59, $00, $80, $00, $45, $9E ; game anim/sprite/level data row 14
    DB      $73, $9C, $41, $00, $58, $00, $6A, $9E ; game anim/sprite/level data row 15
    DB      $A5, $9C, $29, $00, $40, $00, $83, $9E ; game anim/sprite/level data row 16
    DB      $D0, $9C, $24, $00, $28, $00, $96, $9E ; game anim/sprite/level data row 17
    DB      $DF, $9C, $00, $00, $10, $00, $9D, $9E ; game anim/sprite/level data row 18
    DB      $EE, $9C, $04, $03, $1C, $00, $80, $00 ; game anim/sprite/level data row 19
    DB      $A0, $00, $03, $54, $00, $80, $00, $A0 ; game anim/sprite/level data row 20
    DB      $00, $03, $9C, $00, $80, $00, $A0, $00 ; game anim/sprite/level data row 21
    DB      $03, $D4, $00, $80, $00, $A0, $00, $07 ; game anim/sprite/level data row 22
    DB      $01, $1C, $00, $80, $00, $A0, $00, $03 ; game anim/sprite/level data row 23
    DB      $24, $00, $60, $00, $80, $00, $01, $54 ; game anim/sprite/level data row 24
    DB      $00, $80, $00, $A0, $00, $03, $74, $00 ; game anim/sprite/level data row 25
    DB      $60, $00, $80, $00, $01, $9C, $00, $80 ; game anim/sprite/level data row 26
    DB      $00, $A0, $00, $03, $CC, $00, $60, $00 ; game anim/sprite/level data row 27
    DB      $80, $00, $01, $D4, $00, $80, $00, $A0 ; game anim/sprite/level data row 28
    DB      $00, $07, $01, $24, $00, $60, $00, $80 ; game anim/sprite/level data row 29
    DB      $00, $03, $2C, $00, $40, $00, $60, $00 ; game anim/sprite/level data row 30
    DB      $03, $4C, $00, $40, $00, $60, $00, $01 ; game anim/sprite/level data row 31
    DB      $74, $00, $60, $00, $80, $00, $03, $A4 ; game anim/sprite/level data row 32
    DB      $00, $40, $00, $60, $00, $03, $C4, $00 ; game anim/sprite/level data row 33
    DB      $40, $00, $60, $00, $01, $CC, $00, $60 ; game anim/sprite/level data row 34
    DB      $00, $80, $00, $04, $01, $2C, $00, $40 ; game anim/sprite/level data row 35
    DB      $00, $60, $00, $01, $4C, $00, $40, $00 ; game anim/sprite/level data row 36
    DB      $60, $00, $01, $A4, $00, $40, $00, $60 ; game anim/sprite/level data row 37
    DB      $00, $01, $C4, $00, $40, $00, $60, $00 ; game anim/sprite/level data row 38
    DB      $02, $02, $64, $00, $83, $00, $A7, $00 ; game anim/sprite/level data row 39
    DB      $03, $D4, $00, $88, $00, $A1, $00, $04 ; game anim/sprite/level data row 40
    DB      $03, $24, $00, $68, $00, $81, $00, $00 ; game anim/sprite/level data row 41
    DB      $64, $00, $83, $00, $A7, $00, $03, $74 ; game anim/sprite/level data row 42
    DB      $00, $64, $00, $84, $00, $01, $D4, $00 ; game anim/sprite/level data row 43
    DB      $88, $00, $A1, $00, $05, $01, $24, $00 ; game anim/sprite/level data row 44
    DB      $68, $00, $7F, $00, $02, $5C, $00, $43 ; game anim/sprite/level data row 45
    DB      $00, $65, $00, $01, $74, $00, $64, $00 ; game anim/sprite/level data row 46
    DB      $84, $00, $03, $9C, $00, $46, $00, $63 ; game anim/sprite/level data row 47
    DB      $00, $03, $D4, $00, $48, $00, $60, $00 ; game anim/sprite/level data row 48
    DB      $04, $03, $24, $00, $27, $00, $41, $00 ; game anim/sprite/level data row 49
    DB      $00, $5C, $00, $43, $00, $64, $00, $01 ; game anim/sprite/level data row 50
    DB      $9C, $00, $46, $00, $63, $00, $01, $D4 ; game anim/sprite/level data row 51
    DB      $00, $48, $00, $60, $00, $02, $01, $24 ; game anim/sprite/level data row 52
    DB      $00, $27, $00, $41, $00, $03, $65, $00 ; game anim/sprite/level data row 53
    DB      $08, $00, $24, $00, $00, $02, $03, $1C ; game anim/sprite/level data row 54
    DB      $00, $78, $00, $90, $00, $03, $E4, $00 ; game anim/sprite/level data row 55
    DB      $78, $00, $90, $00, $07, $01, $1C, $00 ; game anim/sprite/level data row 56
    DB      $78, $00, $90, $00, $03, $24, $00, $50 ; game anim/sprite/level data row 57
    DB      $00, $78, $00, $03, $4C, $00, $50, $00 ; game anim/sprite/level data row 58
    DB      $80, $00, $03, $64, $00, $50, $00, $80 ; game anim/sprite/level data row 59
    DB      $00, $03, $9C, $00, $48, $00, $60, $00 ; game anim/sprite/level data row 60
    DB      $03, $CC, $00, $58, $00, $70, $00, $01 ; game anim/sprite/level data row 61
    DB      $E4, $00, $78, $00, $90, $00, $06, $01 ; game anim/sprite/level data row 62
    DB      $24, $00, $50, $00, $78, $00, $01, $4C ; game anim/sprite/level data row 63
    DB      $00, $50, $00, $80, $00, $01, $64, $00 ; game anim/sprite/level data row 64
    DB      $50, $00, $80, $00, $01, $9C, $00, $48 ; game anim/sprite/level data row 65
    DB      $00, $60, $00, $01, $CC, $00, $58, $00 ; game anim/sprite/level data row 66
    DB      $70, $00, $03, $E4, $00, $30, $00, $58 ; game anim/sprite/level data row 67
    DB      $00, $02, $03, $B4, $00, $28, $00, $40 ; game anim/sprite/level data row 68
    DB      $00, $01, $E4, $00, $30, $00, $58, $00 ; game anim/sprite/level data row 69
    DB      $02, $03, $9C, $00, $10, $00, $28, $00 ; game anim/sprite/level data row 70
    DB      $01, $B4, $00, $28, $00, $40, $00, $01 ; game anim/sprite/level data row 71
    DB      $01, $9C, $00, $10, $00, $28, $00, $01 ; game anim/sprite/level data row 72
    DB      $10, $00, $E0, $00, $A0, $00, $01, $18 ; game anim/sprite/level data row 73
    DB      $00, $D8, $00, $80, $00, $01, $20, $00 ; game anim/sprite/level data row 74
    DB      $D0, $00, $60, $00, $01, $28, $00, $C8 ; game anim/sprite/level data row 75
    DB      $00, $40, $00, $09, $08, $00, $78, $00 ; game anim/sprite/level data row 76
    DB      $A8, $00, $78, $00, $88, $00, $A7, $00 ; game anim/sprite/level data row 77
    DB      $88, $00, $98, $00, $A6, $00, $98, $00 ; game anim/sprite/level data row 78
    DB      $A8, $00, $A5, $00, $A8, $00, $B8, $00 ; game anim/sprite/level data row 79
    DB      $A4, $00, $B8, $00, $C8, $00, $A3, $00 ; game anim/sprite/level data row 80
    DB      $C8, $00, $D8, $00, $A2, $00, $D8, $00 ; game anim/sprite/level data row 81
    DB      $E8, $00, $A1, $00, $E8, $00, $F8, $00 ; game anim/sprite/level data row 82
    DB      $A0, $00, $09, $08, $00, $28, $00, $80 ; game anim/sprite/level data row 83
    DB      $00, $28, $00, $4C, $00, $81, $00, $4C ; game anim/sprite/level data row 84
    DB      $00, $64, $00, $82, $00, $64, $00, $7C ; game anim/sprite/level data row 85
    DB      $00, $83, $00, $7C, $00, $94, $00, $84 ; game anim/sprite/level data row 86
    DB      $00, $94, $00, $AC, $00, $85, $00, $AC ; game anim/sprite/level data row 87
    DB      $00, $C4, $00, $86, $00, $C4, $00, $DC ; game anim/sprite/level data row 88
    DB      $00, $87, $00, $DC, $00, $E0, $00, $88 ; game anim/sprite/level data row 89
    DB      $00, $09, $1A, $00, $30, $00, $68, $00 ; game anim/sprite/level data row 90
    DB      $30, $00, $48, $00, $67, $00, $48, $00 ; game anim/sprite/level data row 91
    DB      $60, $00, $66, $00, $60, $00, $78, $00 ; game anim/sprite/level data row 92
    DB      $65, $00, $78, $00, $90, $00, $64, $00 ; game anim/sprite/level data row 93
    DB      $90, $00, $A8, $00, $63, $00, $A8, $00 ; game anim/sprite/level data row 94
    DB      $C0, $00, $62, $00, $C0, $00, $D8, $00 ; game anim/sprite/level data row 95
    DB      $61, $00, $D8, $00, $F8, $00, $60, $00 ; game anim/sprite/level data row 96
    DB      $09, $10, $00, $28, $00, $40, $00, $28 ; game anim/sprite/level data row 97
    DB      $00, $40, $00, $41, $00, $40, $00, $58 ; game anim/sprite/level data row 98
    DB      $00, $42, $00, $58, $00, $70, $00, $43 ; game anim/sprite/level data row 99
    DB      $00, $70, $00, $88, $00, $44, $00, $88 ; game anim/sprite/level data row 100
    DB      $00, $A0, $00, $45, $00, $A0, $00, $B8 ; game anim/sprite/level data row 101
    DB      $00, $46, $00, $B8, $00, $D0, $00, $47 ; game anim/sprite/level data row 102
    DB      $00, $D0, $00, $E0, $00, $48, $00, $08 ; game anim/sprite/level data row 103
    DB      $1A, $00, $28, $00, $27, $00, $28, $00 ; game anim/sprite/level data row 104
    DB      $38, $00, $26, $00, $38, $00, $48, $00 ; game anim/sprite/level data row 105
    DB      $25, $00, $48, $00, $58, $00, $24, $00 ; game anim/sprite/level data row 106
    DB      $58, $00, $68, $00, $23, $00, $68, $00 ; game anim/sprite/level data row 107
    DB      $78, $00, $22, $00, $78, $00, $88, $00 ; game anim/sprite/level data row 108
    DB      $21, $00, $88, $00, $FF, $00, $20, $00 ; game anim/sprite/level data row 109
    DB      $01, $60, $00, $FF, $00, $08, $00, $05 ; game anim/sprite/level data row 110
    DB      $08, $00, $28, $00, $90, $00, $88, $00 ; game anim/sprite/level data row 111
    DB      $A0, $00, $90, $00, $A8, $00, $B8, $00 ; game anim/sprite/level data row 112
    DB      $88, $00, $C0, $00, $D0, $00, $90, $00 ; game anim/sprite/level data row 113
    DB      $D8, $00, $F0, $00, $90, $00, $06, $10 ; game anim/sprite/level data row 114
    DB      $00, $28, $00, $78, $00, $48, $00, $68 ; game anim/sprite/level data row 115
    DB      $00, $80, $00, $90, $00, $A8, $00, $60 ; game anim/sprite/level data row 116
    DB      $00, $B0, $00, $C0, $00, $68, $00, $C8 ; game anim/sprite/level data row 117
    DB      $00, $D8, $00, $70, $00, $E0, $00, $F0 ; game anim/sprite/level data row 118
    DB      $00, $78, $00, $04, $10, $00, $28, $00 ; game anim/sprite/level data row 119
    DB      $50, $00, $48, $00, $68, $00, $50, $00 ; game anim/sprite/level data row 120
    DB      $88, $00, $A8, $00, $48, $00, $C8, $00 ; game anim/sprite/level data row 121
    DB      $F0, $00, $58, $00, $03, $B0, $00, $C0 ; game anim/sprite/level data row 122
    DB      $00, $40, $00, $C8, $00, $D8, $00, $38 ; game anim/sprite/level data row 123
    DB      $00, $E0, $00, $F0, $00, $30, $00, $01 ; game anim/sprite/level data row 124
    DB      $10, $00, $B8, $00, $28, $00, $01, $90 ; game anim/sprite/level data row 125
    DB      $00, $A4, $00, $10, $00, $F6, $9F, $DA ; game anim/sprite/level data row 126
    DB      $71, $A8, $A0, $DA, $71, $03, $A1, $EE ; game anim/sprite/level data row 127
    DB      $71, $7D, $9F, $02, $72, $1F, $A0, $0C ; game anim/sprite/level data row 128
    DB      $72, $4A, $A0, $02, $72, $0C, $A0, $E4 ; game anim/sprite/level data row 129
    DB      $71, $6C, $9F, $02, $72, $93, $A0, $0C ; game anim/sprite/level data row 130
    DB      $72, $EF, $9F, $02, $72, $8E, $9F, $02 ; game anim/sprite/level data row 131
    DB      $72, $E6, $9E, $02, $72, $D8, $9E, $16 ; game anim/sprite/level data row 132
    DB      $72, $7C, $7C, $7C, $7C, $40, $E0, $01 ; game anim/sprite/level data row 133
    DB      $16, $76, $40, $BF, $13, $2C, $50, $80 ; game anim/sprite/level data row 134
    DB      $78, $20, $02, $A2, $80, $20, $00, $04 ; game anim/sprite/level data row 135
    DB      $80, $5F, $20, $02, $A2, $80, $22, $00 ; game anim/sprite/level data row 136
    DB      $04, $80, $65, $20, $02, $A2, $80, $24 ; game anim/sprite/level data row 137
    DB      $00, $04, $80, $6B, $20, $02, $A2, $80 ; game anim/sprite/level data row 138
    DB      $26, $00, $04, $80, $71, $20, $02, $A2 ; game anim/sprite/level data row 139
    DB      $80, $28, $00, $04, $80, $78, $20, $02 ; game anim/sprite/level data row 140
    DB      $A2, $80, $2A, $00, $04, $80, $7F, $20 ; game anim/sprite/level data row 141
    DB      $02, $A2, $80, $2D, $00, $04, $80, $87 ; game anim/sprite/level data row 142
    DB      $20, $02, $A2, $80, $30, $00, $04, $80 ; game anim/sprite/level data row 143
    DB      $8F, $20, $02, $A2, $80, $32, $00, $04 ; game anim/sprite/level data row 144
    DB      $80, $97, $20, $02, $A2, $80, $34, $00 ; game anim/sprite/level data row 145
    DB      $04, $80, $A0, $20, $02, $A2, $80, $39 ; game anim/sprite/level data row 146
    DB      $00, $04, $80, $AA, $20, $02, $A2, $80 ; game anim/sprite/level data row 147
    DB      $3C, $00, $04, $80, $B4, $20, $02, $A2 ; game anim/sprite/level data row 148
    DB      $80, $40, $00, $04, $80, $BE, $10, $08 ; game anim/sprite/level data row 149
    DB      $80, $5F, $30, $16, $80, $81, $02, $16 ; game anim/sprite/level data row 150
    DB      $80, $E0, $01, $2C, $90, $83, $DF, $00 ; game anim/sprite/level data row 151
    DB      $05, $11, $04, $15, $11, $83, $EB, $50 ; game anim/sprite/level data row 152
    DB      $03, $11, $FC, $13, $11, $90, $83, $BF ; game anim/sprite/level data row 153
    DB      $00, $05, $11, $FC, $15, $11, $83, $B3 ; game anim/sprite/level data row 154
    DB      $50, $03, $11, $04, $13, $11, $90, $81 ; game anim/sprite/level data row 155
    DB      $2E, $01, $03, $11, $F6, $81, $3E, $00 ; game anim/sprite/level data row 156
    DB      $06, $11, $F6, $81, $1D, $11, $03, $11 ; game anim/sprite/level data row 157
    DB      $F6, $81, $3E, $20, $06, $11, $F6, $81 ; game anim/sprite/level data row 158
    DB      $1D, $31, $03, $11, $F6, $81, $3E, $40 ; game anim/sprite/level data row 159
    DB      $06, $11, $F6, $81, $1D, $51, $03, $11 ; game anim/sprite/level data row 160
    DB      $F6, $81, $3E, $60, $06, $11, $F6, $81 ; game anim/sprite/level data row 161
    DB      $1D, $71, $03, $11, $F6, $81, $3E, $80 ; game anim/sprite/level data row 162
    DB      $06, $11, $F6, $81, $1D, $91, $03, $11 ; game anim/sprite/level data row 163
    DB      $F6, $81, $3E, $A0, $06, $11, $F6, $81 ; game anim/sprite/level data row 164
    DB      $1D, $B1, $03, $11, $F6, $81, $3E, $C0 ; game anim/sprite/level data row 165
    DB      $06, $11, $F6, $81, $1D, $D1, $03, $11 ; game anim/sprite/level data row 166
    DB      $F6, $81, $3E, $E0, $06, $11, $F6, $90 ; game anim/sprite/level data row 167
    DB      $81, $3D, $00, $50, $11, $01, $90, $C0 ; game anim/sprite/level data row 168
    DB      $BF, $53, $0C, $F0, $C0, $FA, $52, $10 ; game anim/sprite/level data row 169
    DB      $C0, $81, $52, $08, $C0, $3B, $52, $08 ; game anim/sprite/level data row 170
    DB      $C0, $81, $52, $08, $D8, $C2, $BF, $23 ; game anim/sprite/level data row 171
    DB      $08, $1C, $22, $C2, $BF, $23, $08, $1C ; game anim/sprite/level data row 172
    DB      $22, $C2, $FA, $22, $10, $1C, $22, $D8 ; game anim/sprite/level data row 173
    DB      $C2, $D6, $00, $12, $1C, $22, $C2, $BE ; game anim/sprite/level data row 174
    DB      $00, $12, $1C, $22, $C2, $A0, $00, $18 ; game anim/sprite/level data row 175
    DB      $1C, $22, $C2, $BE, $00, $0C, $1C, $22 ; game anim/sprite/level data row 176
    DB      $C2, $D6, $00, $0C, $1C, $22, $C2, $BE ; game anim/sprite/level data row 177
    DB      $00, $0C, $1C, $22, $C2, $F0, $20, $18 ; game anim/sprite/level data row 178
    DB      $1C, $22, $D0, $82, $81, $22, $18, $1C ; game anim/sprite/level data row 179
    DB      $22, $82, $57, $23, $18, $1C, $22, $82 ; game anim/sprite/level data row 180
    DB      $81, $22, $18, $1C, $22, $82, $57, $23 ; game anim/sprite/level data row 181
    DB      $18, $1C, $22, $82, $BF, $23, $0C, $1C ; game anim/sprite/level data row 182
    DB      $22, $82, $57, $23, $06, $1C, $22, $82 ; game anim/sprite/level data row 183
    DB      $FA, $22, $06, $1C, $22, $82, $CA, $22 ; game anim/sprite/level data row 184
    DB      $06, $1C, $22, $82, $81, $22, $06, $1C ; game anim/sprite/level data row 185
    DB      $22, $82, $3B, $12, $06, $1C, $22, $82 ; game anim/sprite/level data row 186
    DB      $FC, $11, $06, $1C, $22, $82, $E0, $01 ; game anim/sprite/level data row 187
    DB      $18, $1C, $22, $90, $C0, $3C, $00, $07 ; game anim/sprite/level data row 188
    DB      $C0, $35, $00, $07, $C0, $30, $00, $07 ; game anim/sprite/level data row 189
    DB      $C0, $24, $00, $09, $C0, $2D, $00, $0E ; game anim/sprite/level data row 190
    DB      $D0, $80, $E0, $21, $06, $A6, $80, $E0 ; game anim/sprite/level data row 191
    DB      $21, $03, $A3, $80, $E0, $21, $03, $A3 ; game anim/sprite/level data row 192
    DB      $80, $E0, $21, $06, $A6, $80, $E0, $21 ; game anim/sprite/level data row 193
    DB      $06, $A6, $80, $7D, $21, $06, $A6, $80 ; game anim/sprite/level data row 194
    DB      $E0, $21, $06, $A6, $80, $7D, $21, $06 ; game anim/sprite/level data row 195
    DB      $A6, $80, $E0, $21, $06, $A6, $80, $7D ; game anim/sprite/level data row 196
    DB      $21, $06, $A6, $80, $7D, $21, $03, $A3 ; game anim/sprite/level data row 197
    DB      $80, $7D, $21, $03, $A3, $80, $7D, $21 ; game anim/sprite/level data row 198
    DB      $06, $A6, $80, $7D, $21, $06, $A6, $80 ; game anim/sprite/level data row 199
    DB      $40, $21, $06, $A6, $80, $7D, $21, $06 ; game anim/sprite/level data row 200
    DB      $A6, $80, $40, $21, $06, $A6, $80, $7D ; game anim/sprite/level data row 201
    DB      $21, $06, $A6, $98, $40, $78, $50, $05 ; game anim/sprite/level data row 202
    DB      $65, $40, $50, $50, $05, $65, $40, $5F ; game anim/sprite/level data row 203
    DB      $50, $05, $65, $58, $07, $03, $00, $00 ; game anim/sprite/level data row 204
    DB      $00, $04, $04, $0C, $1E, $1F, $1F, $1F ; game anim/sprite/level data row 205
    DB      $1F, $0E, $07, $00, $E0, $C0, $00, $00 ; game anim/sprite/level data row 206
    DB      $00, $20, $20, $30, $78, $F8, $F8, $F8 ; game anim/sprite/level data row 207
    DB      $F8, $70, $E0, $00, $00, $00, $00, $00 ; game anim/sprite/level data row 208
    DB      $07, $00, $00, $00, $80, $E0, $00, $00 ; game anim/sprite/level data row 209
    DB      $00, $00, $00, $00, $00, $00, $00, $00 ; game anim/sprite/level data row 210
    DB      $E0, $00, $00, $00, $01, $07, $00, $00 ; game anim/sprite/level data row 211
    DB      $00, $00, $00, $00, $00, $0C, $0F, $07 ; game anim/sprite/level data row 212
    DB      $08, $1B, $3B, $73, $61, $00, $00, $00 ; game anim/sprite/level data row 213
    DB      $00, $00, $08, $0F, $00, $30, $F0, $E0 ; game anim/sprite/level data row 214
    DB      $10, $D8, $DC, $CE, $86, $00, $00, $00 ; game anim/sprite/level data row 215
    DB      $00, $00, $10, $F0, $00, $03, $1F, $00 ; game anim/sprite/level data row 216
    DB      $00, $00, $00, $00, $06, $1B, $3E, $3C ; game anim/sprite/level data row 217
    DB      $3E, $1E, $00, $00, $00, $C0, $E0, $00 ; game anim/sprite/level data row 218
    DB      $00, $00, $00, $00, $00, $00, $00, $10 ; game anim/sprite/level data row 219
    DB      $70, $F0, $00, $00, $00, $00, $00, $06 ; game anim/sprite/level data row 220
    DB      $3B, $76, $03, $1F, $00, $04, $00, $03 ; game anim/sprite/level data row 221
    DB      $01, $00, $00, $00, $00, $00, $00, $00 ; game anim/sprite/level data row 222
    DB      $60, $60, $C0, $C0, $00, $00, $00, $80 ; game anim/sprite/level data row 223
    DB      $80, $00, $00, $00, $00, $00, $00, $01 ; game anim/sprite/level data row 224
    DB      $04, $09, $3C, $00, $19, $00, $01, $00 ; game anim/sprite/level data row 225
    DB      $00, $00, $1C, $3D, $00, $00, $00, $E0 ; game anim/sprite/level data row 226
    DB      $90, $90, $38, $00, $E0, $E0, $E0, $60 ; game anim/sprite/level data row 227
    DB      $00, $00, $E0, $E0, $03, $1F, $00, $00 ; game anim/sprite/level data row 228
    DB      $00, $00, $00, $02, $00, $00, $0F, $0F ; game anim/sprite/level data row 229
    DB      $0F, $07, $00, $00, $C0, $E0, $00, $00 ; game anim/sprite/level data row 230
    DB      $00, $00, $00, $00, $00, $30, $FC, $FC ; game anim/sprite/level data row 231
    DB      $FC, $3C, $00, $00, $00, $00, $06, $3B ; game anim/sprite/level data row 232
    DB      $76, $03, $1F, $08, $1C, $0C, $00, $00 ; game anim/sprite/level data row 233
    DB      $00, $00, $00, $00, $00, $00, $00, $60 ; game anim/sprite/level data row 234
    DB      $60, $C0, $C0, $F8, $08, $0A, $00, $00 ; game anim/sprite/level data row 235
    DB      $00, $00, $00, $00, $00, $00, $01, $04 ; game anim/sprite/level data row 236
    DB      $09, $3C, $00, $01, $03, $03, $00, $00 ; game anim/sprite/level data row 237
    DB      $00, $00, $03, $07, $00, $00, $E0, $90 ; game anim/sprite/level data row 238
    DB      $90, $38, $00, $F0, $F0, $C0, $03, $03 ; game anim/sprite/level data row 239
    DB      $03, $01, $80, $80, $03, $1F, $00, $00 ; game anim/sprite/level data row 240
    DB      $00, $00, $00, $01, $03, $E0, $1F, $1F ; game anim/sprite/level data row 241
    DB      $1F, $1C, $00, $00, $C0, $E0, $00, $00 ; game anim/sprite/level data row 242
    DB      $00, $00, $00, $80, $80, $80, $C0, $E0 ; game anim/sprite/level data row 243
    DB      $E0, $C0, $00, $00, $00, $00, $06, $3B ; game anim/sprite/level data row 244
    DB      $76, $03, $1F, $40, $C0, $D1, $00, $00 ; game anim/sprite/level data row 245
    DB      $00, $00, $00, $00, $00, $00, $00, $60 ; game anim/sprite/level data row 246
    DB      $60, $C0, $C0, $00, $0C, $0C, $08, $00 ; game anim/sprite/level data row 247
    DB      $00, $00, $00, $00, $00, $00, $01, $04 ; game anim/sprite/level data row 248
    DB      $09, $3C, $00, $1E, $3C, $20, $40, $60 ; game anim/sprite/level data row 249
    DB      $60, $60, $00, $00, $00, $00, $E0, $90 ; game anim/sprite/level data row 250
    DB      $90, $C8, $00, $70, $70, $70, $00, $00 ; game anim/sprite/level data row 251
    DB      $10, $30, $30, $60, $01, $0F, $00, $00 ; game anim/sprite/level data row 252
    DB      $00, $00, $00, $00, $01, $07, $07, $3F ; game anim/sprite/level data row 253
    DB      $3F, $3F, $00, $00, $E0, $F0, $00, $00 ; game anim/sprite/level data row 254
    DB      $00, $00, $00, $80, $C0, $40, $E0, $E0 ; game anim/sprite/level data row 255
    DB      $F0, $F8, $F0, $60, $00, $00, $03, $1D ; game anim/sprite/level data row 256
    DB      $3B, $01, $6F, $60, $00, $00, $00, $00 ; game anim/sprite/level data row 257
    DB      $00, $00, $00, $00, $00, $00, $00, $B0 ; game anim/sprite/level data row 258
    DB      $30, $E0, $E0, $02, $03, $82, $00, $00 ; game anim/sprite/level data row 259
    DB      $00, $00, $00, $00, $00, $00, $00, $02 ; game anim/sprite/level data row 260
    DB      $04, $1E, $00, $1F, $7E, $00, $80, $C0 ; game anim/sprite/level data row 261
    DB      $C0, $C0, $00, $00, $00, $00, $F0, $48 ; game anim/sprite/level data row 262
    DB      $C8, $1C, $00, $7C, $3C, $20, $08, $1C ; game anim/sprite/level data row 263
    DB      $0E, $02, $00, $00, $01, $0F, $00, $00 ; game anim/sprite/level data row 264
    DB      $00, $00, $00, $00, $03, $05, $0F, $0F ; game anim/sprite/level data row 265
    DB      $17, $11, $08, $00, $E0, $F0, $00, $00 ; game anim/sprite/level data row 266
    DB      $00, $00, $00, $80, $00, $90, $F0, $F0 ; game anim/sprite/level data row 267
    DB      $F0, $E0, $C0, $00, $00, $00, $03, $1D ; game anim/sprite/level data row 268
    DB      $3B, $01, $0F, $00, $E0, $C2, $00, $00 ; game anim/sprite/level data row 269
    DB      $00, $00, $00, $00, $00, $00, $00, $B0 ; game anim/sprite/level data row 270
    DB      $30, $E0, $E0, $00, $00, $0F, $02, $00 ; game anim/sprite/level data row 271
    DB      $00, $0C, $0C, $13, $00, $00, $00, $02 ; game anim/sprite/level data row 272
    DB      $04, $1E, $00, $3F, $1C, $00, $00, $00 ; game anim/sprite/level data row 273
    DB      $48, $6E, $37, $1B, $00, $00, $F0, $48 ; game anim/sprite/level data row 274
    DB      $C8, $1C, $1E, $7F, $F7, $60, $00, $00 ; game anim/sprite/level data row 275
    DB      $00, $00, $00, $00, $00, $07, $03, $00 ; game anim/sprite/level data row 276
    DB      $00, $00, $04, $04, $1E, $3F, $3F, $1F ; game anim/sprite/level data row 277
    DB      $01, $00, $00, $00, $00, $E0, $C0, $00 ; game anim/sprite/level data row 278
    DB      $00, $00, $40, $40, $78, $F8, $F8, $F8 ; game anim/sprite/level data row 279
    DB      $10, $00, $00, $00, $18, $18, $00, $00 ; game anim/sprite/level data row 280
    DB      $00, $07, $00, $00, $00, $00, $00, $00 ; game anim/sprite/level data row 281
    DB      $00, $00, $00, $00, $00, $00, $00, $00 ; game anim/sprite/level data row 282
    DB      $00, $E0, $00, $00, $00, $00, $00, $00 ; game anim/sprite/level data row 283
    DB      $00, $00, $00, $00, $00, $00, $1C, $3F ; game anim/sprite/level data row 284
    DB      $3F, $38, $1B, $1B, $01, $00, $00, $00 ; game anim/sprite/level data row 285
    DB      $1E, $00, $01, $01, $00, $00, $20, $F0 ; game anim/sprite/level data row 286
    DB      $F0, $1C, $DE, $DE, $86, $00, $00, $00 ; game anim/sprite/level data row 287
    DB      $E0, $F0, $E0, $E0, $00, $03, $07, $00 ; game anim/sprite/level data row 288
    DB      $00, $00, $00, $00, $00, $00, $00, $08 ; game anim/sprite/level data row 289
    DB      $0E, $0F, $00, $00, $00, $C0, $F8, $00 ; game anim/sprite/level data row 290
    DB      $00, $00, $00, $00, $60, $D8, $7C, $3C ; game anim/sprite/level data row 291
    DB      $7C, $B8, $00, $00, $00, $00, $00, $00 ; game anim/sprite/level data row 292
    DB      $06, $06, $03, $03, $00, $00, $00, $01 ; game anim/sprite/level data row 293
    DB      $01, $00, $00, $00, $00, $00, $00, $60 ; game anim/sprite/level data row 294
    DB      $DC, $6E, $C0, $F8, $00, $20, $00, $C0 ; game anim/sprite/level data row 295
    DB      $80, $00, $00, $00, $00, $00, $00, $07 ; game anim/sprite/level data row 296
    DB      $09, $09, $1C, $00, $07, $07, $07, $06 ; game anim/sprite/level data row 297
    DB      $00, $00, $07, $07, $00, $00, $00, $80 ; game anim/sprite/level data row 298
    DB      $20, $90, $3C, $00, $98, $00, $80, $00 ; game anim/sprite/level data row 299
    DB      $00, $00, $38, $BC, $03, $07, $00, $00 ; game anim/sprite/level data row 300
    DB      $00, $00, $00, $00, $00, $0C, $3F, $3F ; game anim/sprite/level data row 301
    DB      $3F, $3C, $00, $00, $C0, $F8, $00, $00 ; game anim/sprite/level data row 302
    DB      $00, $00, $00, $00, $00, $00, $F0, $F0 ; game anim/sprite/level data row 303
    DB      $F0, $E0, $00, $00, $00, $00, $00, $06 ; game anim/sprite/level data row 304
    DB      $06, $03, $03, $00, $10, $30, $00, $00 ; game anim/sprite/level data row 305
    DB      $00, $00, $00, $00, $00, $00, $60, $DC ; game anim/sprite/level data row 306
    DB      $6E, $C0, $F8, $00, $38, $30, $00, $00 ; game anim/sprite/level data row 307
    DB      $00, $00, $00, $00, $00, $00, $07, $09 ; game anim/sprite/level data row 308
    DB      $09, $1C, $00, $03, $0F, $03, $C0, $C0 ; game anim/sprite/level data row 309
    DB      $C0, $80, $00, $00, $00, $00, $80, $20 ; game anim/sprite/level data row 310
    DB      $90, $3C, $00, $F0, $C0, $C0, $00, $00 ; game anim/sprite/level data row 311
    DB      $00, $00, $C0, $E0, $03, $07, $00, $00 ; game anim/sprite/level data row 312
    DB      $00, $00, $00, $00, $01, $01, $03, $07 ; game anim/sprite/level data row 313
    DB      $07, $03, $00, $00, $C0, $F8, $00, $00 ; game anim/sprite/level data row 314
    DB      $00, $00, $00, $00, $C0, $70, $F8, $F8 ; game anim/sprite/level data row 315
    DB      $F8, $38, $00, $00, $00, $00, $00, $06 ; game anim/sprite/level data row 316
    DB      $06, $03, $03, $00, $30, $38, $30, $00 ; game anim/sprite/level data row 317
    DB      $00, $00, $00, $00, $00, $00, $60, $DC ; game anim/sprite/level data row 318
    DB      $6E, $C0, $F8, $00, $07, $8B, $00, $00 ; game anim/sprite/level data row 319
    DB      $00, $00, $00, $00, $00, $00, $07, $09 ; game anim/sprite/level data row 320
    DB      $09, $1C, $00, $03, $0E, $06, $00, $00 ; game anim/sprite/level data row 321
    DB      $08, $0C, $0C, $06, $00, $00, $80, $20 ; game anim/sprite/level data row 322
    DB      $90, $3C, $00, $F0, $38, $04, $02, $06 ; game anim/sprite/level data row 323
    DB      $06, $06, $00, $00, $07, $0F, $00, $00 ; game anim/sprite/level data row 324
    DB      $00, $00, $00, $01, $03, $02, $07, $07 ; game anim/sprite/level data row 325
    DB      $0F, $1F, $0F, $06, $80, $F0, $00, $00 ; game anim/sprite/level data row 326
    DB      $00, $00, $00, $00, $80, $E0, $E0, $FC ; game anim/sprite/level data row 327
    DB      $FC, $FC, $00, $00, $00, $00, $00, $0D ; game anim/sprite/level data row 328
    DB      $0C, $07, $07, $40, $C0, $41, $00, $00 ; game anim/sprite/level data row 329
    DB      $00, $00, $00, $00, $00, $00, $C0, $B8 ; game anim/sprite/level data row 330
    DB      $DC, $80, $F6, $06, $00, $00, $00, $00 ; game anim/sprite/level data row 331
    DB      $00, $00, $00, $00, $00, $00, $0F, $12 ; game anim/sprite/level data row 332
    DB      $13, $38, $00, $3E, $3C, $04, $10, $38 ; game anim/sprite/level data row 333
    DB      $70, $40, $00, $00, $00, $00, $00, $40 ; game anim/sprite/level data row 334
    DB      $20, $78, $00, $F8, $7E, $00, $01, $03 ; game anim/sprite/level data row 335
    DB      $03, $03, $00, $00, $07, $0F, $00, $00 ; game anim/sprite/level data row 336
    DB      $00, $00, $00, $01, $00, $09, $0F, $0F ; game anim/sprite/level data row 337
    DB      $0F, $07, $03, $00, $80, $F0, $00, $00 ; game anim/sprite/level data row 338
    DB      $00, $00, $00, $00, $C0, $60, $F0, $F0 ; game anim/sprite/level data row 339
    DB      $E8, $88, $10, $00, $00, $00, $00, $0D ; game anim/sprite/level data row 340
    DB      $0C, $07, $07, $00, $00, $F0, $40, $00 ; game anim/sprite/level data row 341
    DB      $00, $40, $30, $C8, $00, $00, $C0, $B8 ; game anim/sprite/level data row 342
    DB      $DC, $80, $F0, $00, $07, $80, $00, $00 ; game anim/sprite/level data row 343
    DB      $00, $00, $00, $00, $00, $00, $0F, $12 ; game anim/sprite/level data row 344
    DB      $13, $38, $78, $FE, $EF, $06, $00, $00 ; game anim/sprite/level data row 345
    DB      $00, $00, $00, $00, $00, $00, $00, $40 ; game anim/sprite/level data row 346
    DB      $20, $78, $00, $FC, $38, $00, $00, $00 ; game anim/sprite/level data row 347
    DB      $12, $76, $EC, $D8, $00, $07, $03, $00 ; game anim/sprite/level data row 348
    DB      $00, $00, $02, $02, $1E, $1F, $1F, $1F ; game anim/sprite/level data row 349
    DB      $04, $00, $00, $00, $00, $E0, $C0, $00 ; game anim/sprite/level data row 350
    DB      $00, $00, $20, $20, $78, $FC, $FC, $F8 ; game anim/sprite/level data row 351
    DB      $80, $00, $00, $00, $00, $00, $00, $00 ; game anim/sprite/level data row 352
    DB      $00, $07, $00, $00, $00, $00, $00, $00 ; game anim/sprite/level data row 353
    DB      $00, $00, $00, $00, $18, $18, $00, $00 ; game anim/sprite/level data row 354
    DB      $00, $E0, $00, $00, $00, $00, $00, $00 ; game anim/sprite/level data row 355
    DB      $00, $00, $00, $00, $00, $00, $04, $0F ; game anim/sprite/level data row 356
    DB      $0F, $38, $7B, $7B, $60, $00, $00, $00 ; game anim/sprite/level data row 357
    DB      $07, $0F, $07, $07, $00, $00, $38, $FC ; game anim/sprite/level data row 358
    DB      $FC, $1C, $D8, $D8, $80, $00, $00, $00 ; game anim/sprite/level data row 359
    DB      $78, $00, $80, $80, $00, $00, $00, $00 ; game anim/sprite/level data row 360
    DB      $00, $03, $0F, $1F, $3F, $3F, $37, $3B ; game anim/sprite/level data row 361
    DB      $3D, $1E, $0F, $03, $00, $00, $00, $00 ; game anim/sprite/level data row 362
    DB      $00, $C0, $F0, $F8, $9C, $9C, $FC, $FC ; game anim/sprite/level data row 363
    DB      $FC, $F8, $F0, $C0, $00, $00, $00, $00 ; game anim/sprite/level data row 364
    DB      $00, $03, $0F, $1E, $3D, $3B, $37, $3F ; game anim/sprite/level data row 365
    DB      $3F, $1F, $0F, $03, $00, $00, $00, $00 ; game anim/sprite/level data row 366
    DB      $00, $C0, $F0, $F8, $FC, $FC, $FC, $9C ; game anim/sprite/level data row 367
    DB      $9C, $F8, $F0, $C0, $00, $00, $00, $00 ; game anim/sprite/level data row 368
    DB      $00, $03, $0F, $1F, $3F, $3F, $3F, $39 ; game anim/sprite/level data row 369
    DB      $39, $1F, $0F, $03, $00, $00, $00, $00 ; game anim/sprite/level data row 370
    DB      $00, $C0, $F0, $78, $BC, $DC, $EC, $FC ; game anim/sprite/level data row 371
    DB      $FC, $F8, $F0, $C0, $00, $00, $00, $00 ; game anim/sprite/level data row 372
    DB      $00, $1F, $3F, $F0, $C7, $FF, $FF, $FF ; game anim/sprite/level data row 373
    DB      $FF, $FF, $3F, $1F, $00, $00, $00, $00 ; game anim/sprite/level data row 374
    DB      $00, $F8, $FC, $0F, $E3, $FF, $FF, $FF ; game anim/sprite/level data row 375
    DB      $FF, $FF, $FC, $F8, $00, $00, $00, $00 ; game anim/sprite/level data row 376
    DB      $00, $1F, $3F, $FF, $FF, $FF, $C0, $FF ; game anim/sprite/level data row 377
    DB      $FF, $FF, $3F, $1F, $00, $00, $00, $00 ; game anim/sprite/level data row 378
    DB      $00, $F8, $FC, $FF, $FF, $FF, $03, $FF ; game anim/sprite/level data row 379
    DB      $FF, $FF, $FC, $F8, $00, $00, $00, $00 ; game anim/sprite/level data row 380
    DB      $00, $1F, $3F, $FF, $FF, $FF, $FF, $FF ; game anim/sprite/level data row 381
    DB      $C7, $F0, $3F, $1F, $00, $00, $00, $00 ; game anim/sprite/level data row 382
    DB      $00, $F8, $FC, $FF, $FF, $FF, $FF, $FF ; game anim/sprite/level data row 383
    DB      $E3, $0F, $FC, $F8, $00, $00, $0C, $9E ; game anim/sprite/level data row 384
    DB      $9F, $8D, $8F, $FE, $FF, $E0, $DF, $3F ; game anim/sprite/level data row 385
    DB      $7F, $1F, $00, $00, $00, $00, $30, $79 ; game anim/sprite/level data row 386
    DB      $F9, $B1, $F1, $7F, $FF, $07, $FB, $FC ; game anim/sprite/level data row 387
    DB      $FE, $F8, $00, $00, $00, $00, $01, $07 ; game anim/sprite/level data row 388
    DB      $07, $0D, $3F, $7F, $7F, $FF, $03, $7D ; game anim/sprite/level data row 389
    DB      $3F, $3F, $03, $00, $00, $80, $C0, $E0 ; game anim/sprite/level data row 390
    DB      $EE, $EE, $EE, $8E, $8C, $FC, $FC, $F8 ; game anim/sprite/level data row 391
    DB      $E0, $E0, $80, $00, $00, $01, $03, $07 ; game anim/sprite/level data row 392
    DB      $67, $E7, $E7, $F1, $30, $31, $3B, $1F ; game anim/sprite/level data row 393
    DB      $07, $07, $01, $00, $00, $00, $80, $E0 ; game anim/sprite/level data row 394
    DB      $E0, $B0, $FC, $FE, $FE, $FF, $C0, $BE ; game anim/sprite/level data row 395
    DB      $7C, $FC, $80, $00, $00, $00, $00, $78 ; game anim/sprite/level data row 396
    DB      $DA, $7C, $3C, $00, $00, $00, $00, $00 ; game anim/sprite/level data row 397
    DB      $00, $00, $00, $00, $00, $00, $00, $00 ; game anim/sprite/level data row 398
    DB      $00, $00, $00, $00, $00, $00, $00, $00 ; game anim/sprite/level data row 399
    DB      $00, $00, $00, $00, $00, $00, $00, $00 ; game anim/sprite/level data row 400
    DB      $00, $03, $27, $47, $C7, $E3, $77, $7F ; game anim/sprite/level data row 401
    DB      $3F, $3F, $1F, $07, $00, $00, $00, $00 ; game anim/sprite/level data row 402
    DB      $F0, $F8, $AC, $AC, $F8, $FC, $FE, $FE ; game anim/sprite/level data row 403
    DB      $FE, $FE, $FC, $F8, $00, $00, $00, $00 ; game anim/sprite/level data row 404
    DB      $0F, $1F, $35, $35, $1F, $3F, $7F, $7F ; game anim/sprite/level data row 405
    DB      $7F, $7F, $3F, $1F, $00, $00, $00, $00 ; game anim/sprite/level data row 406
    DB      $00, $C0, $E4, $E2, $E3, $C7, $EE, $FE ; game anim/sprite/level data row 407
    DB      $FC, $FC, $F8, $E0, $00, $00, $00, $00 ; game anim/sprite/level data row 408
    DB      $01, $0F, $10, $1F, $1F, $1F, $0F, $01 ; game anim/sprite/level data row 409
    DB      $01, $01, $01, $01, $00, $00, $00, $00 ; game anim/sprite/level data row 410
    DB      $80, $F8, $58, $F8, $F8, $F8, $F0, $80 ; game anim/sprite/level data row 411
    DB      $80, $80, $80, $80, $00, $00, $00, $03 ; game anim/sprite/level data row 412
    DB      $07, $05, $07, $0D, $0D, $05, $05, $05 ; game anim/sprite/level data row 413
    DB      $03, $00, $00, $00, $00, $00, $00, $C0 ; game anim/sprite/level data row 414
    DB      $E0, $E0, $E0, $FF, $FF, $E0, $E0, $E0 ; game anim/sprite/level data row 415
    DB      $C0, $00, $00, $00, $00, $00, $00, $03 ; game anim/sprite/level data row 416
    DB      $07, $07, $07, $FF, $FF, $07, $07, $07 ; game anim/sprite/level data row 417
    DB      $03, $00, $00, $00, $00, $00, $00, $C0 ; game anim/sprite/level data row 418
    DB      $A0, $A0, $A0, $B0, $B0, $E0, $A0, $E0 ; game anim/sprite/level data row 419
    DB      $C0, $00, $00, $00, $00, $00, $00, $00 ; game anim/sprite/level data row 420
    DB      $00, $00, $00, $00, $FF, $FF, $C3, $66 ; game anim/sprite/level data row 421
    DB      $3C, $18, $FF, $FF, $00, $FF, $FF, $C3 ; game anim/sprite/level data row 422
    DB      $66, $3C, $18, $FF, $00, $00, $FF, $FF ; game anim/sprite/level data row 423
    DB      $C3, $66, $3C, $18, $00, $00, $00, $FF ; game anim/sprite/level data row 424
    DB      $FF, $C3, $66, $3C, $00, $00, $00, $00 ; game anim/sprite/level data row 425
    DB      $FF, $FF, $C3, $66, $00, $00, $00, $00 ; game anim/sprite/level data row 426
    DB      $00, $FF, $FF, $C3, $00, $00, $00, $00 ; game anim/sprite/level data row 427
    DB      $00, $00, $FF, $FF, $00, $00, $00, $00 ; game anim/sprite/level data row 428
    DB      $00, $00, $00, $FF, $FF, $00, $00, $00 ; game anim/sprite/level data row 429
    DB      $00, $00, $00, $00, $FF, $FF, $00, $00 ; game anim/sprite/level data row 430
    DB      $00, $00, $00, $00, $18, $FF, $FF, $00 ; game anim/sprite/level data row 431
    DB      $00, $00, $00, $00, $3C, $18, $FF, $FF ; game anim/sprite/level data row 432
    DB      $00, $00, $00, $00, $66, $3C, $18, $FF ; game anim/sprite/level data row 433
    DB      $FF, $00, $00, $00, $C3, $66, $3C, $18 ; game anim/sprite/level data row 434
    DB      $FF, $FF, $00, $00, $FF, $C3, $66, $3C ; game anim/sprite/level data row 435
    DB      $18, $FF, $FF, $00, $81, $FF, $81, $81 ; game anim/sprite/level data row 436
    DB      $81, $FF, $81, $81, $81, $FF, $FF, $C3 ; game anim/sprite/level data row 437
    DB      $66, $3C, $18, $FF, $81, $81, $FF, $FF ; game anim/sprite/level data row 438
    DB      $C3, $66, $3C, $18, $FF, $81, $81, $FF ; game anim/sprite/level data row 439
    DB      $FF, $C3, $66, $3C, $81, $FF, $81, $81 ; game anim/sprite/level data row 440
    DB      $FF, $FF, $C3, $66, $81, $81, $FF, $81 ; game anim/sprite/level data row 441
    DB      $81, $FF, $FF, $C3, $81, $81, $81, $FF ; game anim/sprite/level data row 442
    DB      $81, $81, $FF, $FF, $FF, $81, $81, $81 ; game anim/sprite/level data row 443
    DB      $FF, $81, $81, $FF, $FF, $FF, $81, $81 ; game anim/sprite/level data row 444
    DB      $81, $FF, $81, $81, $FF, $FF, $81, $81 ; game anim/sprite/level data row 445
    DB      $81, $FF, $81, $81, $18, $FF, $FF, $81 ; game anim/sprite/level data row 446
    DB      $81, $FF, $81, $81, $3C, $18, $FF, $FF ; game anim/sprite/level data row 447
    DB      $81, $FF, $81, $81, $66, $3C, $18, $FF ; game anim/sprite/level data row 448
    DB      $FF, $FF, $81, $81, $C3, $66, $3C, $18 ; game anim/sprite/level data row 449
    DB      $FF, $FF, $81, $81, $FF, $C3, $66, $3C ; game anim/sprite/level data row 450
    DB      $18, $FF, $FF, $81, $00, $00, $00, $00 ; game anim/sprite/level data row 451
    DB      $00, $00, $00, $03, $00, $00, $00, $01 ; game anim/sprite/level data row 452
    DB      $03, $03, $03, $0F, $0F, $3F, $7F, $FF ; game anim/sprite/level data row 453
    DB      $F9, $F9, $FF, $FF, $F0, $FC, $FE, $FF ; game anim/sprite/level data row 454
    DB      $9F, $9F, $FF, $FF, $00, $00, $00, $80 ; game anim/sprite/level data row 455
    DB      $C0, $C0, $C0, $F0, $00, $00, $00, $01 ; game anim/sprite/level data row 456
    DB      $01, $01, $01, $01, $1F, $7F, $FF, $FF ; game anim/sprite/level data row 457
    DB      $F7, $F3, $F9, $FC, $FF, $FF, $FF, $FF ; game anim/sprite/level data row 458
    DB      $FF, $FF, $FF, $4F, $FF, $FF, $FF, $FF ; game anim/sprite/level data row 459
    DB      $FF, $FF, $FF, $F2, $F8, $FE, $FF, $FF ; game anim/sprite/level data row 460
    DB      $EF, $CF, $9F, $3F, $00, $00, $00, $80 ; game anim/sprite/level data row 461
    DB      $80, $80, $80, $80, $FF, $7F, $3F, $1F ; game anim/sprite/level data row 462
    DB      $0F, $1F, $7F, $7F, $81, $D1, $E3, $91 ; game anim/sprite/level data row 463
    DB      $01, $E1, $FE, $C0, $81, $8B, $C7, $89 ; game anim/sprite/level data row 464
    DB      $80, $C7, $7F, $03, $FF, $FE, $FC, $F8 ; game anim/sprite/level data row 465
    DB      $F0, $F8, $FE, $FE, $00, $00, $00, $00 ; game anim/sprite/level data row 466
    DB      $00, $00, $01, $03, $7F, $7F, $3F, $3F ; game anim/sprite/level data row 467
    DB      $3F, $7F, $FF, $FF, $F0, $FF, $F0, $C0 ; game anim/sprite/level data row 468
    DB      $C0, $C0, $C0, $00, $07, $FF, $0F, $03 ; game anim/sprite/level data row 469
    DB      $03, $03, $03, $00, $FE, $FE, $FC, $FC ; game anim/sprite/level data row 470
    DB      $FC, $FE, $FF, $FF, $00, $00, $00, $00 ; game anim/sprite/level data row 471
    DB      $00, $00, $80, $C0, $01, $03, $03, $07 ; game anim/sprite/level data row 472
    DB      $07, $0D, $3F, $7F, $F0, $FE, $FF, $FF ; game anim/sprite/level data row 473
    DB      $FF, $FF, $FF, $FF, $00, $00, $00, $C0 ; game anim/sprite/level data row 474
    DB      $F8, $FF, $FF, $DF, $00, $00, $00, $00 ; game anim/sprite/level data row 475
    DB      $00, $00, $00, $80, $7F, $FF, $7F, $7F ; game anim/sprite/level data row 476
    DB      $3F, $3F, $03, $01, $FF, $FF, $FF, $FF ; game anim/sprite/level data row 477
    DB      $FF, $FF, $FF, $FF, $CF, $EF, $EF, $EF ; game anim/sprite/level data row 478
    DB      $EF, $EF, $CF, $9F, $C0, $C0, $E0, $E0 ; game anim/sprite/level data row 479
    DB      $F0, $F0, $F0, $F8, $01, $01, $03, $03 ; game anim/sprite/level data row 480
    DB      $07, $07, $0F, $07, $FF, $FE, $FE, $FC ; game anim/sprite/level data row 481
    DB      $F8, $F8, $F0, $E4, $3F, $7F, $3F, $3F ; game anim/sprite/level data row 482
    DB      $3F, $0F, $03, $00, $FC, $FE, $FF, $FF ; game anim/sprite/level data row 483
    DB      $FF, $FF, $FF, $FF, $00, $00, $00, $80 ; game anim/sprite/level data row 484
    DB      $C0, $C0, $E0, $F0, $07, $1F, $1F, $3F ; game anim/sprite/level data row 485
    DB      $FF, $FE, $7C, $38, $EE, $CF, $CF, $8F ; game anim/sprite/level data row 486
    DB      $0F, $1F, $7F, $FF, $FF, $E0, $F8, $F0 ; game anim/sprite/level data row 487
    DB      $F0, $F0, $F0, $C0, $3F, $1F, $1F, $1F ; game anim/sprite/level data row 488
    DB      $0F, $00, $01, $03, $FE, $F8, $F8, $F4 ; game anim/sprite/level data row 489
    DB      $F0, $10, $FC, $F8, $3C, $3C, $3C, $3C ; game anim/sprite/level data row 490
    DB      $3C, $3C, $3C, $3C, $FF, $FE, $AC, $FC ; game anim/sprite/level data row 491
    DB      $0E, $07, $E3, $E0, $FF, $FF, $A0, $E3 ; game anim/sprite/level data row 492
    DB      $A3, $E1, $A0, $7F, $01, $01, $01, $01 ; game anim/sprite/level data row 493
    DB      $01, $01, $01, $01, $7F, $A0, $E5, $A2 ; game anim/sprite/level data row 494
    DB      $E1, $A0, $FF, $00, $E0, $E3, $07, $0E ; game anim/sprite/level data row 495
    DB      $FC, $AC, $FE, $FF, $FF, $7F, $35, $3F ; game anim/sprite/level data row 496
    DB      $70, $E0, $C7, $07, $FF, $FF, $05, $87 ; game anim/sprite/level data row 497
    DB      $47, $57, $05, $FE, $80, $80, $80, $80 ; game anim/sprite/level data row 498
    DB      $80, $80, $80, $80, $FE, $05, $87, $C5 ; game anim/sprite/level data row 499
    DB      $67, $05, $FF, $00, $07, $CE, $E0, $70 ; game anim/sprite/level data row 500
    DB      $3F, $35, $EF, $FF, $03, $07, $0F, $1F ; game anim/sprite/level data row 501
    DB      $3F, $7F, $FF, $FF, $80, $C0, $E0, $F0 ; game anim/sprite/level data row 502
    DB      $F8, $FC, $FE, $FE, $DD, $89, $01, $01 ; game anim/sprite/level data row 503
    DB      $01, $01, $01, $00, $76, $22, $00, $00 ; game anim/sprite/level data row 504
    DB      $00, $20, $20, $C0, $00, $00, $00, $00 ; game anim/sprite/level data row 505
    DB      $00, $00, $00, $FF, $E3, $E3, $FF, $FF ; game anim/sprite/level data row 506
    DB      $FF, $FF, $FF, $FF, $00, $0C, $7F, $82 ; game anim/sprite/level data row 507
    DB      $FF, $FF, $FF, $7F, $0C, $0C, $0C, $0C ; game anim/sprite/level data row 508
    DB      $0C, $0C, $00, $00, $00, $00, $80, $C0 ; game anim/sprite/level data row 509
    DB      $C0, $C0, $C0, $80, $00, $00, $00, $00 ; game anim/sprite/level data row 510
    DB      $00, $00, $00, $00, $03, $07, $0F, $0F ; game anim/sprite/level data row 511
    DB      $3F, $7F, $E3, $1C, $C0, $E0, $F0, $F0 ; game anim/sprite/level data row 512
    DB      $FC, $FE, $8F, $7F, $3C, $42, $BD, $7E ; game anim/sprite/level data row 513
    DB      $A5, $DB, $E7, $FF, $04, $24, $22, $17 ; game anim/sprite/level data row 514
    DB      $33, $27, $77, $7E, $14, $22, $54, $76 ; game anim/sprite/level data row 515
    DB      $26, $4E, $EC, $FF, $74, $3D, $3F, $7F ; game anim/sprite/level data row 516
    DB      $BF, $BF, $BF, $BF, $EE, $DE, $FC, $FF ; game anim/sprite/level data row 517
    DB      $FF, $FF, $FF, $FF, $BF, $BF, $00, $BF ; game anim/sprite/level data row 518
    DB      $B1, $B5, $B5, $B1, $FF, $FF, $00, $FF ; game anim/sprite/level data row 519
    DB      $27, $27, $27, $23, $BF, $00, $BF, $A4 ; game anim/sprite/level data row 520
    DB      $BF, $BF, $BF, $BF, $FF, $00, $FF, $63 ; game anim/sprite/level data row 521
    DB      $FF, $FF, $FF, $FF, $00, $00, $7E, $FF ; game anim/sprite/level data row 522
    DB      $7F, $DF, $7F, $3D, $00, $00, $00, $00 ; game anim/sprite/level data row 523
    DB      $90, $8C, $18, $F0, $0F, $1F, $1F, $0F ; game anim/sprite/level data row 524
    DB      $1F, $77, $3F, $1F, $FC, $E8, $C0, $E0 ; game anim/sprite/level data row 525
    DB      $F0, $B8, $F0, $E0, $7F, $7F, $7F, $7F ; game anim/sprite/level data row 526
    DB      $FF, $1F, $1C, $74, $F8, $F8, $F8, $F8 ; game anim/sprite/level data row 527
    DB      $FC, $E0, $E0, $B8, $FF, $FF, $81, $42 ; game anim/sprite/level data row 528
    DB      $24, $18, $FF, $FF, $01, $01, $01, $01 ; game anim/sprite/level data row 529
    DB      $01, $01, $FF, $FF, $80, $80, $80, $80 ; game anim/sprite/level data row 530
    DB      $80, $80, $FF, $FF, $81, $42, $24, $18 ; game anim/sprite/level data row 531
    DB      $FF, $FF, $01, $01, $81, $42, $24, $18 ; game anim/sprite/level data row 532
    DB      $FF, $FF, $80, $80, $01, $01, $01, $01 ; game anim/sprite/level data row 533
    DB      $FF, $FF, $81, $42, $80, $80, $80, $80 ; game anim/sprite/level data row 534
    DB      $FF, $FF, $81, $42, $24, $18, $FF, $FF ; game anim/sprite/level data row 535
    DB      $01, $01, $01, $01, $24, $18, $FF, $FF ; game anim/sprite/level data row 536
    DB      $80, $80, $80, $80, $01, $01, $FF, $FF ; game anim/sprite/level data row 537
    DB      $81, $42, $24, $18, $80, $80, $FF, $FF ; game anim/sprite/level data row 538
    DB      $81, $42, $24, $18, $FF, $FF, $01, $01 ; game anim/sprite/level data row 539
    DB      $01, $01, $01, $01, $FF, $FF, $80, $80 ; game anim/sprite/level data row 540
    DB      $80, $80, $80, $80, $82, $82, $82, $82 ; game anim/sprite/level data row 541
    DB      $82, $82, $7E, $00, $7C, $82, $82, $82 ; game anim/sprite/level data row 542
    DB      $FC, $80, $80, $00, $00, $00, $00, $00 ; game anim/sprite/level data row 543
    DB      $00, $00, $00, $00, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 544
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 545
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 546
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 547
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 548
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 549
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 550
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 551
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 552
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 553
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 554
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 555
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 556
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 557
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 558
    DB      $D0, $D0, $D0, $D0, $70, $70, $70, $70 ; game anim/sprite/level data row 559
    DB      $70, $70, $70, $70, $70, $D0, $D0, $D0 ; game anim/sprite/level data row 560
    DB      $D0, $D0, $D0, $D0, $70, $70, $D0, $D0 ; game anim/sprite/level data row 561
    DB      $D0, $D0, $D0, $D0, $70, $70, $70, $D0 ; game anim/sprite/level data row 562
    DB      $D0, $D0, $D0, $D0, $70, $70, $70, $70 ; game anim/sprite/level data row 563
    DB      $D0, $D0, $D0, $D0, $70, $70, $70, $70 ; game anim/sprite/level data row 564
    DB      $70, $D0, $D0, $D0, $70, $70, $70, $70 ; game anim/sprite/level data row 565
    DB      $70, $70, $D0, $D0, $70, $70, $70, $70 ; game anim/sprite/level data row 566
    DB      $70, $70, $70, $D0, $D0, $70, $70, $70 ; game anim/sprite/level data row 567
    DB      $70, $70, $70, $70, $D0, $D0, $70, $70 ; game anim/sprite/level data row 568
    DB      $70, $70, $70, $70, $D0, $D0, $D0, $70 ; game anim/sprite/level data row 569
    DB      $70, $70, $70, $70, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 570
    DB      $70, $70, $70, $70, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 571
    DB      $D0, $70, $70, $70, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 572
    DB      $D0, $D0, $70, $70, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 573
    DB      $D0, $D0, $D0, $70, $00, $00, $00, $00 ; game anim/sprite/level data row 574
    DB      $00, $00, $00, $00, $00, $00, $00, $B0 ; game anim/sprite/level data row 575
    DB      $B0, $B0, $B0, $60, $60, $60, $60, $60 ; game anim/sprite/level data row 576
    DB      $60, $60, $60, $60, $60, $60, $60, $60 ; game anim/sprite/level data row 577
    DB      $60, $60, $60, $60, $00, $00, $00, $B0 ; game anim/sprite/level data row 578
    DB      $B0, $B0, $B0, $60, $60, $60, $60, $60 ; game anim/sprite/level data row 579
    DB      $60, $60, $60, $60, $60, $60, $60, $60 ; game anim/sprite/level data row 580
    DB      $6B, $6B, $6B, $6B, $60, $60, $60, $60 ; game anim/sprite/level data row 581
    DB      $60, $60, $60, $6B, $60, $60, $60, $60 ; game anim/sprite/level data row 582
    DB      $60, $60, $60, $6B, $60, $60, $60, $60 ; game anim/sprite/level data row 583
    DB      $6B, $6B, $6B, $6B, $60, $60, $60, $60 ; game anim/sprite/level data row 584
    DB      $60, $60, $60, $60, $60, $60, $60, $60 ; game anim/sprite/level data row 585
    DB      $B0, $60, $60, $60, $6B, $6B, $6B, $6B ; game anim/sprite/level data row 586
    DB      $6B, $6B, $6B, $6B, $6B, $6B, $6B, $6B ; game anim/sprite/level data row 587
    DB      $6B, $6B, $6B, $6B, $60, $60, $60, $60 ; game anim/sprite/level data row 588
    DB      $B0, $60, $60, $60, $00, $00, $00, $00 ; game anim/sprite/level data row 589
    DB      $00, $00, $B0, $B0, $60, $60, $60, $60 ; game anim/sprite/level data row 590
    DB      $60, $B0, $B0, $B0, $6B, $6B, $60, $60 ; game anim/sprite/level data row 591
    DB      $60, $B0, $B0, $B0, $6B, $60, $60, $60 ; game anim/sprite/level data row 592
    DB      $60, $B0, $B0, $B0, $60, $60, $60, $60 ; game anim/sprite/level data row 593
    DB      $60, $B0, $B0, $B0, $00, $00, $00, $00 ; game anim/sprite/level data row 594
    DB      $00, $00, $B0, $B0, $60, $60, $60, $60 ; game anim/sprite/level data row 595
    DB      $60, $60, $60, $60, $60, $60, $60, $60 ; game anim/sprite/level data row 596
    DB      $60, $60, $60, $60, $60, $60, $60, $60 ; game anim/sprite/level data row 597
    DB      $60, $60, $60, $60, $60, $60, $60, $60 ; game anim/sprite/level data row 598
    DB      $60, $60, $60, $60, $60, $60, $60, $60 ; game anim/sprite/level data row 599
    DB      $60, $60, $60, $60, $60, $60, $60, $60 ; game anim/sprite/level data row 600
    DB      $60, $60, $60, $60, $6B, $6B, $6B, $6B ; game anim/sprite/level data row 601
    DB      $6B, $6B, $6B, $6B, $60, $60, $60, $60 ; game anim/sprite/level data row 602
    DB      $60, $60, $60, $60, $60, $60, $60, $60 ; game anim/sprite/level data row 603
    DB      $60, $60, $60, $6B, $6B, $6B, $6B, $6B ; game anim/sprite/level data row 604
    DB      $6B, $6B, $6B, $6B, $6B, $6B, $6B, $6B ; game anim/sprite/level data row 605
    DB      $6B, $6B, $6B, $6B, $60, $60, $6B, $6B ; game anim/sprite/level data row 606
    DB      $6B, $6B, $6B, $6B, $60, $60, $60, $60 ; game anim/sprite/level data row 607
    DB      $60, $60, $60, $60, $6B, $B0, $B0, $B0 ; game anim/sprite/level data row 608
    DB      $B0, $B0, $B0, $B0, $6B, $60, $60, $60 ; game anim/sprite/level data row 609
    DB      $60, $B0, $B0, $B0, $B0, $6B, $6B, $60 ; game anim/sprite/level data row 610
    DB      $60, $B0, $B0, $B0, $6B, $6B, $6B, $60 ; game anim/sprite/level data row 611
    DB      $60, $B0, $B0, $B0, $6B, $6B, $6B, $6B ; game anim/sprite/level data row 612
    DB      $6B, $6B, $B0, $B0, $60, $60, $60, $60 ; game anim/sprite/level data row 613
    DB      $60, $60, $60, $60, $B0, $B6, $B6, $B6 ; game anim/sprite/level data row 614
    DB      $B6, $B6, $B6, $B6, $10, $B0, $B6, $B6 ; game anim/sprite/level data row 615
    DB      $B6, $B6, $B6, $B0, $60, $60, $60, $60 ; game anim/sprite/level data row 616
    DB      $60, $60, $60, $60, $B0, $B6, $B6, $B6 ; game anim/sprite/level data row 617
    DB      $B6, $B6, $B6, $10, $B6, $B6, $B6, $B6 ; game anim/sprite/level data row 618
    DB      $B6, $B6, $B6, $B6, $B0, $B6, $B6, $B6 ; game anim/sprite/level data row 619
    DB      $B6, $B6, $B6, $B6, $10, $B0, $B6, $B6 ; game anim/sprite/level data row 620
    DB      $B6, $B6, $B6, $B6, $60, $60, $60, $60 ; game anim/sprite/level data row 621
    DB      $60, $60, $60, $60, $B0, $B6, $B6, $B6 ; game anim/sprite/level data row 622
    DB      $B6, $B6, $B6, $10, $B6, $B6, $B6, $B6 ; game anim/sprite/level data row 623
    DB      $B6, $B6, $B6, $B6, $F0, $D0, $F0, $F0 ; game anim/sprite/level data row 624
    DB      $D0, $F0, $F0, $D0, $F0, $D0, $F0, $F0 ; game anim/sprite/level data row 625
    DB      $D0, $F0, $F0, $D0, $F0, $D0, $F0, $F0 ; game anim/sprite/level data row 626
    DB      $D0, $F0, $F0, $D0, $F0, $F0, $F0, $F0 ; game anim/sprite/level data row 627
    DB      $F0, $D0, $D0, $D0, $00, $00, $00, $00 ; game anim/sprite/level data row 628
    DB      $00, $00, $00, $50, $B6, $B6, $B0, $B0 ; game anim/sprite/level data row 629
    DB      $B0, $B0, $B0, $B0, $00, $80, $0C, $CF ; game anim/sprite/level data row 630
    DB      $C0, $C0, $C0, $C0, $80, $80, $80, $80 ; game anim/sprite/level data row 631
    DB      $80, $80, $80, $80, $C0, $C0, $C0, $C0 ; game anim/sprite/level data row 632
    DB      $C0, $C0, $C0, $C0, $00, $00, $00, $00 ; game anim/sprite/level data row 633
    DB      $00, $00, $00, $00, $F0, $F0, $F0, $D0 ; game anim/sprite/level data row 634
    DB      $40, $F0, $DF, $D0, $F0, $F0, $F0, $D0 ; game anim/sprite/level data row 635
    DB      $40, $F0, $DF, $D0, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 636
    DB      $DF, $DF, $DF, $D0, $80, $80, $80, $80 ; game anim/sprite/level data row 637
    DB      $80, $80, $80, $80, $80, $80, $80, $80 ; game anim/sprite/level data row 638
    DB      $80, $80, $80, $80, $80, $80, $80, $4F ; game anim/sprite/level data row 639
    DB      $4F, $4F, $4F, $4F, $80, $80, $80, $40 ; game anim/sprite/level data row 640
    DB      $40, $40, $40, $40, $4F, $4F, $4F, $4F ; game anim/sprite/level data row 641
    DB      $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F ; game anim/sprite/level data row 642
    DB      $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F ; game anim/sprite/level data row 643
    DB      $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F ; game anim/sprite/level data row 644
    DB      $4F, $4F, $4F, $4F, $B0, $B0, $B0, $B0 ; game anim/sprite/level data row 645
    DB      $B0, $B0, $B0, $B0, $B0, $B0, $B0, $B0 ; game anim/sprite/level data row 646
    DB      $B0, $B0, $B0, $B0, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 647
    DB      $D0, $D0, $D0, $D0, $B0, $B0, $D0, $D0 ; game anim/sprite/level data row 648
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 649
    DB      $D0, $D0, $F0, $F0, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 650
    DB      $D0, $D0, $F0, $F0, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 651
    DB      $D0, $D0, $D0, $D0, $60, $60, $60, $60 ; game anim/sprite/level data row 652
    DB      $60, $60, $D0, $D0, $60, $60, $60, $60 ; game anim/sprite/level data row 653
    DB      $60, $60, $D0, $D0, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 654
    DB      $D0, $D0, $60, $60, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 655
    DB      $D0, $D0, $60, $60, $60, $60, $60, $60 ; game anim/sprite/level data row 656
    DB      $D0, $D0, $D0, $D0, $60, $60, $60, $60 ; game anim/sprite/level data row 657
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 658
    DB      $60, $60, $60, $60, $D0, $D0, $D0, $D0 ; game anim/sprite/level data row 659
    DB      $60, $60, $60, $60, $60, $60, $D0, $D0 ; game anim/sprite/level data row 660
    DB      $D0, $D0, $D0, $D0, $60, $60, $D0, $D0 ; game anim/sprite/level data row 661
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $60, $60 ; game anim/sprite/level data row 662
    DB      $60, $60, $60, $60, $D0, $D0, $60, $60 ; game anim/sprite/level data row 663
    DB      $60, $60, $60, $60, $60, $4F, $4F, $4F ; game anim/sprite/level data row 664
    DB      $60, $6F, $40, $40, $7D, $AF, $87, $AF ; game anim/sprite/level data row 665
    DB      $34, $71, $E9, $AF, $0F, $B0, $35, $B0 ; game anim/sprite/level data row 666
    DB      $34, $BC, $AF, $E3, $AF, $BF, $AF, $E3 ; game anim/sprite/level data row 667
    DB      $AF, $C2, $AF, $E3, $AF, $C5, $AF, $E3 ; game anim/sprite/level data row 668
    DB      $AF, $C8, $AF, $E3, $AF, $CB, $AF, $E3 ; game anim/sprite/level data row 669
    DB      $AF, $CE, $AF, $E3, $AF, $D1, $AF, $E3 ; game anim/sprite/level data row 670
    DB      $AF, $D4, $AF, $E3, $AF, $D7, $AF, $E3 ; game anim/sprite/level data row 671
    DB      $AF, $DA, $AF, $E3, $AF, $DD, $AF, $E3 ; game anim/sprite/level data row 672
    DB      $AF, $E0, $AF, $E3, $AF, $00, $00, $00 ; game anim/sprite/level data row 673
    DB      $01, $01, $01, $02, $02, $02, $03, $03 ; game anim/sprite/level data row 674
    DB      $03, $04, $04, $04, $05, $05, $05, $06 ; game anim/sprite/level data row 675
    DB      $06, $06, $07, $07, $07, $08, $08, $08 ; game anim/sprite/level data row 676
    DB      $09, $09, $09, $0A, $0A, $0A, $0B, $0B ; game anim/sprite/level data row 677
    DB      $0B, $0C, $0C, $0C, $00, $00, $00, $00 ; game anim/sprite/level data row 678
    DB      $00, $00, $EE, $AF, $39, $71, $00, $03 ; game anim/sprite/level data row 679
    DB      $00, $13, $A1, $9C, $F5, $AF, $06, $00 ; game anim/sprite/level data row 680
    DB      $06, $0C, $06, $18, $06, $24, $06, $30 ; game anim/sprite/level data row 681
    DB      $06, $3C, $06, $48, $06, $54, $06, $60 ; game anim/sprite/level data row 682
    DB      $06, $6C, $06, $78, $06, $84, $06, $90 ; game anim/sprite/level data row 683
    DB      $14, $B0, $3E, $71, $01, $03, $00, $13 ; game anim/sprite/level data row 684
    DB      $A1, $9C, $1B, $B0, $0F, $04, $0F, $10 ; game anim/sprite/level data row 685
    DB      $0F, $1C, $0F, $28, $0F, $34, $0F, $40 ; game anim/sprite/level data row 686
    DB      $0F, $4C, $0F, $58, $0F, $64, $0F, $70 ; game anim/sprite/level data row 687
    DB      $0F, $7C, $0F, $88, $0F, $94, $3A, $B0 ; game anim/sprite/level data row 688
    DB      $43, $71, $02, $03, $00, $13, $A1, $9C ; game anim/sprite/level data row 689
    DB      $41, $B0, $04, $08, $04, $14, $04, $20 ; game anim/sprite/level data row 690
    DB      $04, $2C, $04, $38, $04, $44, $04, $50 ; game anim/sprite/level data row 691
    DB      $04, $5C, $04, $68, $04         ; game anim/sprite/level data row 692
                                            ; game anim/sprite/level data row 693
; ============================================================
; GAME DATA  ($B054 - $BBFF)
; Animation, sprite, level, and name-table data.
; (Tracer did not reach this area via static flow; kept as DB.)
; ============================================================
GAME_DATA:                                  ; GAME_DATA: anim/sprite/nametable data ($B054-$BBFF)
    DB      $74, $04, $80, $04, $8C, $04, $98, $69 ; GAME_DATA row 0
    DB      $B0, $71, $B0, $79, $B0, $7B, $B0, $7D ; GAME_DATA row 1
    DB      $B0, $7F, $B0, $81, $B0, $07, $01, $08 ; GAME_DATA row 2
    DB      $02, $07, $03, $09, $00, $01, $01, $02 ; GAME_DATA row 3
    DB      $02, $01, $03, $03, $00, $0A, $00, $04 ; GAME_DATA row 4
    DB      $00, $0B, $00, $05, $00, $00, $01, $06 ; GAME_DATA row 5
    DB      $02, $0C, $01, $30, $00, $A8, $00, $3C ; GAME_DATA row 6
    DB      $00, $A0, $00, $1E, $00, $90, $00, $9F ; GAME_DATA row 7
    DB      $B0, $4E, $B2, $18, $B3, $D0, $B0, $39 ; GAME_DATA row 8
    DB      $B2, $83, $B2, $0C, $02, $CD, $02, $10 ; GAME_DATA row 9
    DB      $01, $6D, $02, $1A, $02, $BB, $02, $10 ; GAME_DATA row 10
    DB      $02, $25, $02, $10, $02, $2F, $02, $10 ; GAME_DATA row 11
    DB      $01, $EF, $01, $1C, $02, $B4, $01, $10 ; GAME_DATA row 12
    DB      $02, $BB, $01, $10, $02, $25, $01, $10 ; GAME_DATA row 13
    DB      $02, $AD, $00, $10, $06, $B3, $00, $10 ; GAME_DATA row 14
    DB      $06, $B5, $00, $10, $5A, $0D, $E2, $02 ; GAME_DATA row 15
    DB      $01, $02, $EF, $02, $0F, $02, $F1, $02 ; GAME_DATA row 16
    DB      $0E, $02, $F3, $02, $0D, $02, $F5, $02 ; GAME_DATA row 17
    DB      $0C, $02, $F7, $02, $0B, $02, $F9, $02 ; GAME_DATA row 18
    DB      $0A, $02, $FB, $02, $09, $02, $CF, $02 ; GAME_DATA row 19
    DB      $08, $02, $D1, $02, $07, $02, $D3, $02 ; GAME_DATA row 20
    DB      $06, $02, $D5, $02, $05, $02, $D7, $02 ; GAME_DATA row 21
    DB      $04, $02, $D9, $02, $03, $02, $DB, $02 ; GAME_DATA row 22
    DB      $02, $02, $DD, $02, $01, $03, $42, $02 ; GAME_DATA row 23
    DB      $01, $01, $45, $02, $11, $03, $46, $02 ; GAME_DATA row 24
    DB      $02, $03, $49, $02, $03, $03, $4C, $02 ; GAME_DATA row 25
    DB      $04, $01, $4F, $02, $14, $02, $50, $02 ; GAME_DATA row 26
    DB      $05, $03, $52, $02, $06, $03, $55, $02 ; GAME_DATA row 27
    DB      $07, $03, $58, $02, $08, $03, $66, $02 ; GAME_DATA row 28
    DB      $09, $03, $69, $02, $0A, $03, $6C, $02 ; GAME_DATA row 29
    DB      $0B, $03, $6F, $02, $0C, $03, $72, $02 ; GAME_DATA row 30
    DB      $0D, $03, $75, $02, $0E, $03, $78, $02 ; GAME_DATA row 31
    DB      $0F, $02, $7B, $02, $01, $02, $E4, $01 ; GAME_DATA row 32
    DB      $01, $03, $E6, $01, $0F, $03, $E9, $01 ; GAME_DATA row 33
    DB      $0E, $03, $EC, $01, $0D, $03, $EF, $01 ; GAME_DATA row 34
    DB      $0C, $03, $F2, $01, $0B, $03, $F5, $01 ; GAME_DATA row 35
    DB      $0A, $03, $F8, $01, $09, $03, $C6, $01 ; GAME_DATA row 36
    DB      $08, $03, $C9, $01, $07, $02, $CD, $01 ; GAME_DATA row 37
    DB      $06, $03, $CF, $01, $05, $02, $D2, $01 ; GAME_DATA row 38
    DB      $04, $01, $D4, $01, $13, $03, $D5, $01 ; GAME_DATA row 39
    DB      $03, $03, $D8, $01, $02, $04, $DB, $01 ; GAME_DATA row 40
    DB      $01, $03, $42, $01, $01, $02, $46, $01 ; GAME_DATA row 41
    DB      $02, $03, $48, $01, $03, $03, $4B, $01 ; GAME_DATA row 42
    DB      $04, $03, $4E, $01, $05, $03, $51, $01 ; GAME_DATA row 43
    DB      $06, $03, $54, $01, $07, $03, $57, $01 ; GAME_DATA row 44
    DB      $08, $03, $65, $01, $09, $03, $68, $01 ; GAME_DATA row 45
    DB      $0A, $03, $6B, $01, $0B, $03, $6E, $01 ; GAME_DATA row 46
    DB      $0C, $03, $71, $01, $0D, $02, $75, $01 ; GAME_DATA row 47
    DB      $0E, $03, $77, $01, $0F, $03, $7A, $01 ; GAME_DATA row 48
    DB      $01, $01, $C4, $00, $08, $02, $C5, $00 ; GAME_DATA row 49
    DB      $07, $02, $C7, $00, $06, $02, $C9, $00 ; GAME_DATA row 50
    DB      $05, $02, $CB, $00, $04, $01, $CD, $00 ; GAME_DATA row 51
    DB      $12, $01, $CE, $00, $03, $02, $CF, $00 ; GAME_DATA row 52
    DB      $02, $0E, $D1, $00, $01, $06, $6D, $00 ; GAME_DATA row 53
    DB      $01, $01, $C4, $00, $08, $01, $E4, $00 ; GAME_DATA row 54
    DB      $0F, $01, $E5, $00, $1D, $01, $E6, $00 ; GAME_DATA row 55
    DB      $0E, $02, $E7, $00, $0D, $02, $E9, $00 ; GAME_DATA row 56
    DB      $0B, $02, $EB, $00, $0A, $02, $ED, $00 ; GAME_DATA row 57
    DB      $09, $01, $CC, $01, $15, $01, $45, $01 ; GAME_DATA row 58
    DB      $11, $01, $74, $01, $1D, $01, $6C, $01 ; GAME_DATA row 59
    DB      $1A, $01, $AC, $01, $10, $05, $1A, $C3 ; GAME_DATA row 60
    DB      $02, $01, $18, $44, $02, $01, $16, $C5 ; GAME_DATA row 61
    DB      $01, $01, $14, $46, $01, $01, $0E, $A9 ; GAME_DATA row 62
    DB      $00, $01, $0D, $03, $A4, $02, $10, $03 ; GAME_DATA row 63
    DB      $AB, $02, $10, $03, $B4, $02, $10, $03 ; GAME_DATA row 64
    DB      $BB, $02, $10, $03, $25, $02, $10, $03 ; GAME_DATA row 65
    DB      $2F, $02, $10, $03, $3A, $02, $10, $03 ; GAME_DATA row 66
    DB      $A6, $01, $10, $03, $AA, $01, $10, $03 ; GAME_DATA row 67
    DB      $B5, $01, $10, $03, $B9, $01, $10, $04 ; GAME_DATA row 68
    DB      $2B, $01, $46, $04, $34, $01, $46, $25 ; GAME_DATA row 69
    DB      $1D, $C2, $02, $01, $04, $82, $02, $01 ; GAME_DATA row 70
    DB      $03, $92, $02, $01, $02, $76, $02, $01 ; GAME_DATA row 71
    DB      $04, $4A, $02, $01, $02, $99, $02, $01 ; GAME_DATA row 72
    DB      $03, $9C, $02, $01, $03, $23, $02, $01 ; GAME_DATA row 73
    DB      $02, $3D, $02, $01, $02, $1A, $02, $01 ; GAME_DATA row 74
    DB      $02, $F7, $01, $01, $03, $D3, $01, $01 ; GAME_DATA row 75
    DB      $03, $83, $01, $01, $04, $8A, $01, $01 ; GAME_DATA row 76
    DB      $05, $BA, $01, $01, $04, $72, $01, $01 ; GAME_DATA row 77
    DB      $02, $57, $01, $01, $02, $3A, $01, $01 ; GAME_DATA row 78
    DB      $02, $1D, $01, $01, $16, $E2, $00, $01 ; GAME_DATA row 79
    DB      $06, $8F, $00, $01, $01, $C7, $02, $4B ; GAME_DATA row 80
    DB      $01, $C8, $02, $50, $01, $A7, $02, $4A ; GAME_DATA row 81
    DB      $01, $A8, $02, $4F, $01, $E7, $00, $47 ; GAME_DATA row 82
    DB      $01, $E8, $00, $4C, $01, $07, $01, $48 ; GAME_DATA row 83
    DB      $01, $08, $01, $4D, $01, $CF, $02, $4B ; GAME_DATA row 84
    DB      $01, $D0, $02, $50, $01, $AF, $02, $4A ; GAME_DATA row 85
    DB      $01, $B0, $02, $4F, $01, $EF, $00, $47 ; GAME_DATA row 86
    DB      $01, $F0, $00, $4C, $01, $0F, $01, $48 ; GAME_DATA row 87
    DB      $01, $10, $01, $4D, $10, $02, $64, $02 ; GAME_DATA row 88
    DB      $10, $05, $2D, $02, $10, $05, $2A, $02 ; GAME_DATA row 89
    DB      $10, $04, $05, $02, $10, $02, $FA, $01 ; GAME_DATA row 90
    DB      $10, $02, $B4, $01, $10, $04, $9D, $01 ; GAME_DATA row 91
    DB      $10, $02, $37, $01, $10, $02, $D4, $00 ; GAME_DATA row 92
    DB      $10, $07, $CE, $00, $10, $07, $CC, $00 ; GAME_DATA row 93
    DB      $10, $0C, $87, $02, $49, $0C, $88, $02 ; GAME_DATA row 94
    DB      $4E, $0C, $8F, $02, $49, $0C, $90, $02 ; GAME_DATA row 95
    DB      $4E, $02, $7D, $02, $10, $5F, $B3, $6C ; GAME_DATA row 96
    DB      $B3, $99, $B3, $03, $DB, $B3, $C0, $38 ; GAME_DATA row 97
    DB      $E1, $B3, $C0, $78, $D5, $B4, $18, $98 ; GAME_DATA row 98
    DB      $0B, $A6, $B3, $40, $48, $AC, $B3, $B8 ; GAME_DATA row 99
    DB      $48, $B2, $B3, $40, $68, $B8, $B3, $B8 ; GAME_DATA row 100
    DB      $68, $BE, $B3, $40, $88, $C4, $B3, $B8 ; GAME_DATA row 101
    DB      $88, $28, $B4, $30, $40, $DB, $B3, $78 ; GAME_DATA row 102
    DB      $58, $E1, $B3, $18, $78, $FC, $B3, $C0 ; GAME_DATA row 103
    DB      $88, $13, $B4, $80, $A8, $03, $FC, $B3 ; GAME_DATA row 104
    DB      $58, $88, $28, $B4, $18, $50, $13, $B4 ; GAME_DATA row 105
    DB      $E8, $38, $CA, $B3, $72, $71, $FF, $BF ; GAME_DATA row 106
    DB      $CA, $B3, $78, $71, $FF, $BF, $CA, $B3 ; GAME_DATA row 107
    DB      $7E, $71, $FF, $BF, $CA, $B3, $84, $71 ; GAME_DATA row 108
    DB      $FF, $BF, $CA, $B3, $8A, $71, $FF, $BF ; GAME_DATA row 109
    DB      $CA, $B3, $90, $71, $FF, $BF, $F0, $55 ; GAME_DATA row 110
    DB      $02, $7B, $AA, $D3, $B3, $D7, $B3, $01 ; GAME_DATA row 111
    DB      $02, $55, $56, $01, $02, $00, $00, $E7 ; GAME_DATA row 112
    DB      $B3, $9C, $71, $FF, $BF, $E7, $B3, $A2 ; GAME_DATA row 113
    DB      $71, $FF, $BF, $F0, $57, $04, $8B, $AA ; GAME_DATA row 114
    DB      $F0, $B3, $F6, $B3, $02, $02, $57, $59 ; GAME_DATA row 115
    DB      $58, $5A, $02, $02, $00, $00, $00, $00 ; GAME_DATA row 116
    DB      $02, $B4, $A8, $71, $FF, $BF, $F0, $5B ; GAME_DATA row 117
    DB      $02, $AB, $AA, $0B, $B4, $0F, $B4, $02 ; GAME_DATA row 118
    DB      $01, $5B, $5C, $02, $01, $00, $00, $19 ; GAME_DATA row 119
    DB      $B4, $AE, $71, $FF, $BF, $F0, $5D, $01 ; GAME_DATA row 120
    DB      $BB, $AA, $22, $B4, $25, $B4, $01, $01 ; GAME_DATA row 121
    DB      $5D, $01, $01, $00, $2E, $B4, $96, $71 ; GAME_DATA row 122
    DB      $FF, $BF, $F0, $51, $04, $5B, $AA, $37 ; GAME_DATA row 123
    DB      $B4, $F6, $B3, $02, $02, $51, $52, $53 ; GAME_DATA row 124
    DB      $54, $45, $B4, $CD, $71, $64, $B4, $76 ; GAME_DATA row 125
    DB      $B4, $24, $52, $B4, $58, $B4, $54, $B4 ; GAME_DATA row 126
    DB      $5C, $B4, $56, $B4, $60, $B4, $00, $00 ; GAME_DATA row 127
    DB      $01, $01, $02, $02, $10, $00, $00, $00 ; GAME_DATA row 128
    DB      $00, $00, $00, $00, $20, $00, $00, $00 ; GAME_DATA row 129
    DB      $69, $B4, $D4, $71, $0C, $03, $B4, $B3 ; GAME_DATA row 130
    DB      $A6, $14, $70, $B4, $0F, $00, $0F, $04 ; GAME_DATA row 131
    DB      $0F, $08, $7C, $B4, $B4, $71, $FF, $BF ; GAME_DATA row 132
    DB      $F0, $1F, $18, $CB, $A8, $87, $B4, $A1 ; GAME_DATA row 133
    DB      $B4, $BB, $B4, $06, $04, $1F, $20, $21 ; GAME_DATA row 134
    DB      $22, $23, $1F, $24, $25, $26, $27, $28 ; GAME_DATA row 135
    DB      $29, $1F, $2A, $2B, $2C, $2D, $1F, $2E ; GAME_DATA row 136
    DB      $2F, $30, $31, $32, $33, $06, $04, $34 ; GAME_DATA row 137
    DB      $35, $36, $37, $1F, $1F, $38, $39, $3A ; GAME_DATA row 138
    DB      $3B, $1F, $1F, $3C, $3D, $3E, $3F, $40 ; GAME_DATA row 139
    DB      $1F, $41, $42, $43, $44, $45, $1F, $06 ; GAME_DATA row 140
    DB      $04, $7B, $7B, $93, $92, $91, $90, $7B ; GAME_DATA row 141
    DB      $7B, $97, $96, $95, $94, $7B, $9C, $9B ; GAME_DATA row 142
    DB      $9A, $99, $98, $7B, $A1, $A0, $9F, $9E ; GAME_DATA row 143
    DB      $9D, $DB, $B4, $90, $71, $FF, $BF, $F0 ; GAME_DATA row 144
    DB      $5E, $08, $C3, $AA, $E4, $B4, $E4, $B4 ; GAME_DATA row 145
    DB      $02, $04, $5E, $5F, $60, $61, $62, $63 ; GAME_DATA row 146
    DB      $64, $65, $F6, $B4, $BA, $71, $1C, $B5 ; GAME_DATA row 147
    DB      $07, $B5, $24, $FF, $B4, $03, $B5, $01 ; GAME_DATA row 148
    DB      $B5, $03, $B5, $00, $00, $01, $01, $00 ; GAME_DATA row 149
    DB      $00, $00, $00, $0D, $B5, $C1, $71, $FF ; GAME_DATA row 150
    DB      $BF, $F0, $66, $18, $03, $AB, $14, $B5 ; GAME_DATA row 151
    DB      $02, $03, $66, $67, $68, $69, $6A, $6B ; GAME_DATA row 152
    DB      $21, $B5, $C7, $71, $0D, $03, $C0, $13 ; GAME_DATA row 153
    DB      $A7, $14, $28, $B5, $0F, $00, $43, $B5 ; GAME_DATA row 154
    DB      $72, $71, $03, $43, $B5, $78, $71, $04 ; GAME_DATA row 155
    DB      $43, $B5, $7E, $71, $05, $43, $B5, $84 ; GAME_DATA row 156
    DB      $71, $06, $43, $B5, $8A, $71, $07, $03 ; GAME_DATA row 157
    DB      $9C, $F3, $A5, $14, $4A, $B5, $06, $00 ; GAME_DATA row 158
    DB      $06, $04, $06, $08, $06, $0C, $06, $10 ; GAME_DATA row 159
    DB      $06, $14, $00, $01, $04, $02, $08, $00 ; GAME_DATA row 160
    DB      $74, $B5, $72, $71, $FF, $BF, $74, $B5 ; GAME_DATA row 161
    DB      $78, $71, $FF, $BF, $74, $B5, $7E, $71 ; GAME_DATA row 162
    DB      $FF, $BF, $74, $B5, $84, $71, $FF, $BF ; GAME_DATA row 163
    DB      $F0, $6C, $04, $33, $AB, $93, $B5, $99 ; GAME_DATA row 164
    DB      $B5, $9F, $B5, $A5, $B5, $AB, $B5, $B1 ; GAME_DATA row 165
    DB      $B5, $B5, $B5, $B9, $B5, $BD, $B5, $C1 ; GAME_DATA row 166
    DB      $B5, $C5, $B5, $C9, $B5, $CD, $B5, $02 ; GAME_DATA row 167
    DB      $02, $49, $4E, $6C, $6C, $02, $02, $6D ; GAME_DATA row 168
    DB      $6E, $6F, $70, $02, $02, $71, $72, $73 ; GAME_DATA row 169
    DB      $74, $02, $02, $75, $76, $77, $78, $02 ; GAME_DATA row 170
    DB      $02, $6C, $6C, $49, $4E, $02, $01, $6C ; GAME_DATA row 171
    DB      $6C, $02, $01, $75, $76, $02, $01, $71 ; GAME_DATA row 172
    DB      $72, $02, $01, $6D, $6E, $02, $01, $6F ; GAME_DATA row 173
    DB      $70, $02, $01, $73, $74, $02, $01, $77 ; GAME_DATA row 174
    DB      $78, $02, $01, $49, $4E, $1B, $B6, $79 ; GAME_DATA row 175
    DB      $72, $03, $1B, $B6, $7E, $72, $04, $1B ; GAME_DATA row 176
    DB      $B6, $83, $72, $05, $1B, $B6, $88, $72 ; GAME_DATA row 177
    DB      $06, $EB, $B5, $8D, $72, $01, $B6, $14 ; GAME_DATA row 178
    DB      $F8, $B5, $FB, $B5, $F9, $B5, $FD, $B5 ; GAME_DATA row 179
    DB      $FA, $B5, $FF, $B5, $00, $01, $02, $0F ; GAME_DATA row 180
    DB      $00, $1E, $0F, $00, $0F, $06, $B6, $92 ; GAME_DATA row 181
    DB      $72, $08, $03, $CC, $73, $A7, $0C, $0D ; GAME_DATA row 182
    DB      $B6, $0C, $00, $0C, $08, $0C, $04, $00 ; GAME_DATA row 183
    DB      $01, $02, $00, $00, $01, $01, $00, $03 ; GAME_DATA row 184
    DB      $C4, $33, $A7, $08, $22, $B6, $06, $00 ; GAME_DATA row 185
    DB      $06, $04, $01, $00, $00, $00, $F4, $70 ; GAME_DATA row 186
    DB      $04, $71, $14, $71, $24, $71, $CD, $71 ; GAME_DATA row 187
    DB      $90, $71, $F4, $70, $04, $71, $14, $71 ; GAME_DATA row 188
    DB      $24, $71, $24, $71, $DB, $B3, $E1, $B3 ; GAME_DATA row 189
    DB      $BE, $B3, $C4, $B3, $B2, $B3, $B8, $B3 ; GAME_DATA row 190
    DB      $A6, $B3, $AC, $B3, $CD, $71, $F4, $70 ; GAME_DATA row 191
    DB      $04, $71, $14, $71, $24, $71, $24, $71 ; GAME_DATA row 192
    DB      $13, $B4, $28, $B4, $FC, $B3, $DB, $B3 ; GAME_DATA row 193
    DB      $E1, $B3, $CD, $71, $F4, $70, $04, $71 ; GAME_DATA row 194
    DB      $14, $71, $24, $71, $24, $71, $13, $B4 ; GAME_DATA row 195
    DB      $28, $B4, $FC, $B3, $72, $71, $78, $71 ; GAME_DATA row 196
    DB      $7E, $71, $84, $71, $FF, $FF, $FF, $FF ; GAME_DATA row 197
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 198
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 199
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 200
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 201
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 202
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 203
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 204
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 205
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 206
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 207
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 208
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 209
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 210
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 211
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 212
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 213
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 214
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 215
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 216
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 217
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 218
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 219
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 220
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 221
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 222
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 223
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 224
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 225
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 226
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 227
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 228
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 229
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 230
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 231
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 232
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 233
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 234
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 235
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 236
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 237
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 238
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 239
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 240
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 241
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 242
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 243
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 244
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 245
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 246
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 247
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 248
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 249
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 250
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 251
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 252
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 253
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 254
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 255
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 256
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 257
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 258
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 259
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 260
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 261
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 262
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 263
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 264
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 265
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 266
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 267
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 268
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 269
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 270
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 271
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 272
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 273
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 274
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 275
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 276
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 277
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 278
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 279
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 280
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 281
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 282
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 283
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 284
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 285
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 286
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 287
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 288
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 289
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 290
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 291
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 292
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 293
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 294
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 295
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 296
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 297
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 298
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 299
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 300
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 301
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 302
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 303
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 304
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 305
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 306
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 307
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 308
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 309
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 310
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 311
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 312
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 313
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 314
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 315
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 316
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 317
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 318
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 319
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 320
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 321
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 322
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 323
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 324
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 325
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 326
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 327
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 328
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 329
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 330
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 331
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 332
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 333
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 334
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 335
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 336
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 337
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 338
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 339
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 340
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 341
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 342
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 343
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 344
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 345
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 346
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 347
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 348
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 349
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 350
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 351
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 352
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 353
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 354
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 355
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 356
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 357
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 358
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 359
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 360
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 361
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 362
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 363
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 364
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 365
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 366
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 367
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 368
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 369
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 370
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 371
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; GAME_DATA row 372
    DB      $FF, $FF, $FF, $FF              ; GAME_DATA row 373
                                            ; GAME_DATA row 374
                                            ; GAME_DATA row 375
                                            ; GAME_DATA row 376
                                            ; GAME_DATA row 377
                                            ; GAME_DATA row 378
                                            ; GAME_DATA row 379
TILE_BITMAPS:                               ; TILE_BITMAPS: TMS9918A pattern table 8b/tile 110 tiles ($BC00-$BF6F)
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 0
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 1
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 2
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 3
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 4
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 5
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 6
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 7
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 8
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 9
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 10
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 11
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 12
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 13
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 14
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 15
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 16
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 17
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 18
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 19
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 20
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 21
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 22
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 23
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 24
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 25
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 26
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 27
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 28
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 29
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 30
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 31
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 32
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 33
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 34
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 35
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 36
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 37
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 38
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 39
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 40
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 41
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 42
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 43
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 44
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 45
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 46
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 47
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 48
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 49
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 50
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 51
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 52
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 53
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 54
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 55
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 56
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 57
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 58
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 59
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 60
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 61
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 62
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 63
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 64
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 65
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 66
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 67
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 68
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 69
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 70
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 71
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 72
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 73
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 74
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 75
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 76
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 77
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 78
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 79
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 80
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 81
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 82
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 83
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 84
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 85
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 86
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 87
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 88
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 89
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 90
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 91
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 92
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 93
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 94
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 95
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 96
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 97
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 98
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 99
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 100
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 101
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 102
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 103
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 104
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 105
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 106
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 107
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 108
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 109

; ============================================================
; ZERO PADDING  ($BF70 - $BFFF)
; ============================================================
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; ROM padding row 0
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; ROM padding row 1
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; ROM padding row 2
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; ROM padding row 3
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; ROM padding row 4
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; ROM padding row 5
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; ROM padding row 6
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; ROM padding row 7
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; ROM padding row 8
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; ROM padding row 9
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; ROM padding row 10
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; ROM padding row 11
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; ROM padding row 12
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; ROM padding row 13
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; ROM padding row 14
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; ROM padding row 15
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; ROM padding row 16
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; ROM padding row 17
