; ===== CHOPLIFTER (1984) DISASSEMBLY LEGEND =====
; ROM: 16 KB ($8000-$BFFF). VDP $BE/$BF. SN76489A on $FF.
; Cart magic: $55AA. JOYSTICK_BUFFER: $7038 (non-std; std $5A48).
;
; === CART ENTRY & TOP-LEVEL LOOPS ===
; CART_ENTRY (JP NMI; Broderbund copyright) .... 194
; LOC_81F6 (outer game loop: frame sync, dispatch) 378
;
; === BOOT & INIT ===
; START (SP=STACKTOP, init $702B, call subs) .... 203
; SUB_82AF (init JOYSTICK_BUFFER to $9B) ....... 470
; SUB_82DE (level init: templates, hostages) .... 503
; DELAY_LOOP_8775 (clear RAM $7048+$74, fill VRAM) 1214
; SUB_8738 (VDP register setup: mode 1, sprites) . 1188
; SUB_8D3C (VDP init for main game) ............. 2032
; SUB_8A12 (game options / difficulty select) .... 1675
;
; === NMI ===
; NMI (gate $702B, save regs, POLLER, songs, inc $702C) 719
;
; === MAIN GAME LOOP (LOC_81F6 dispatch) ===
; SUB_8FA4 (player input: joystick+fire, move heli) 2327
; DELAY_LOOP_98EB (helicopter position + sprite) .. 3587
; SUB_9EB0 (helicopter collision check) .......... 4285
; SUB_9EBE (helicopter animation controller) ...... 4291
; SUB_9F1B (projectile pool: 5 missile slots) ..... 4316
; DELAY_LOOP_9D52 (missile/projectile update) ..... 4176
; SUB_A036 (vehicle/truck spawn controller) ....... 4362
; DELAY_LOOP_A4AB (vehicle/truck animation) ....... 4928
; SUB_AACF (enemy tank AI: move/animate/collide) .. 5737
; SUB_AE0E (boss/special enemy: spawn/move/fire) .. 6149
; SUB_A918 (hostage state machine) ................ 5521
; SOUND_WRITE_9DB3 (handle queued sound requests) . 4199
;
; === LEVEL SYSTEM ===
; SUB_895B (load level data indexed by $7031) ..... 1554
;
; === PLAYER / HELICOPTER ===
; SUB_88B8 (sprite + wall collision detect) ....... 1446
;
; === SCORING / HOSTAGE PICKUPS ===
; SUB_A739 (hostage capture handler) .............. 5243
; SUB_A752 (score BCD update on pickup) ........... 5256
; SUB_8B56 (write pickup count to HUD) ............ 1891
; SUB_8B67 (increment HUD pickup counter) ......... 1902
;
; === SOUND ===
; SOUND_WRITE_87D1 (sound trigger fire/events) .... 1288
; SOUND_WRITE_82CC (clear sound slots $703E/$7043) . 491
; SOUND_WRITE_94C0 (init/clear sound channel bufs) . 3082
;
; === SCREEN / VDP ===
; SUB_848E (screen setup / palette init) .......... 697
; SUB_8982 (init sprite palette + VDP display) .... 1576
; SUB_89A1 (init sprite name table entries) ....... 1595
; SUB_8788 (table lookup via RST $10, A-index) .... 1227
;
; === KEY RAM ($7000-$73B9) ===
; $7031  current level (0-2, wraps at 3)
; $702B  CONTROLLER_BUFFER -- NMI gate (bit 7)
; $702C  frame counter (INC each NMI)
; $702F  player flags (bit 0=facing, bit 1=2P, bit 2=difficulty)
; $7030  difficulty select (0-3)
; $703E  sound request ($FF = none)
; $7038  JOYSTICK_BUFFER (raw POLLER output)
; $7044  level width ($10F0 = 256 tiles)
; $70BC/$70BD  player helicopter X (16-bit)
; $70BE  player helicopter Y
; $70C0  hostages rescued this level
; $71FA-$7212  missile pool (5 x 6 bytes each)
; $7334  hostages remaining (0 = level complete)
; $73C5  VDP status cache (last read by NMI)
;
; === DATA BLOCKS ===
; GAME_DATA (RLE sprite data, backgrounds) ........ 6335
; TILE_BITMAPS (VDP pattern table bitmaps) ........ 6716
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


; BIOS DEFINITIONS **************************

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
GET_VRAM:                EQU $1FBB         ; GET_VRAM: BIOS read tile from VRAM
PUT_VRAM:                EQU $1FBE         ; PUT_VRAM: BIOS write tile data HL to VRAM at DE (IY=stride)
INIT_SPR_NM_TBL:         EQU $1FC1         ; INIT_SPR_NM_TBL: BIOS init sprite name table in RAM
WR_SPR_NM_TBL:           EQU $1FC4         ; WR_SPR_NM_TBL: BIOS write sprite name table to VRAM
INIT_TIMER:              EQU $1FC7
FREE_SIGNAL:             EQU $1FCA
REQUEST_SIGNAL:          EQU $1FCD
TEST_SIGNAL:             EQU $1FD0
TIME_MGR:                EQU $1FD3         ; TIME_MGR: BIOS advance all timer channels (call from NMI)
TURN_OFF_SOUND:          EQU $1FD6
WRITE_REGISTER:          EQU $1FD9         ; WRITE_REGISTER: BIOS set VDP register (BC: B=reg, C=val)
READ_REGISTER:           EQU $1FDC         ; READ_REGISTER: BIOS read VDP status -> A
WRITE_VRAM:              EQU $1FDF
READ_VRAM:               EQU $1FE2
INIT_WRITER:             EQU $1FE5         ; INIT_WRITER: BIOS init WRITER DMA engine (A=mode, HL=buf)
WRITER:                  EQU $1FE8         ; WRITER: BIOS DMA-copy tile buffer to VRAM
POLLER:                  EQU $1FEB         ; POLLER: BIOS poll controller -> JOYSTICK_BUFFER / CONTROLLER_BUFFER
SOUND_INIT:              EQU $1FEE         ; SOUND_INIT: BIOS init sound engine
PLAY_IT:                 EQU $1FF1         ; PLAY_IT: BIOS play sound effect (B=channel)
SOUND_MAN:               EQU $1FF4         ; SOUND_MAN: BIOS advance sound engine (call from NMI)
ACTIVATE:                EQU $1FF7         ; ACTIVATE: BIOS activate sprite slot (IY=slot)
PUTOBJ:                  EQU $1FFA         ; PUTOBJ: BIOS display object record at IX
RAND_GEN:                EQU $1FFD         ; RAND_GEN: BIOS LCG random number -> A

; I/O PORT DEFINITIONS **********************

KEYBOARD_PORT:           EQU $0080         ; KEYBOARD_PORT: $0080 keyboard matrix
DATA_PORT:               EQU $00BE         ; DATA_PORT: $00BE VDP VRAM data
CTRL_PORT:               EQU $00BF         ; CTRL_PORT: $00BF VDP control/status
JOY_PORT:                EQU $00C0         ; JOY_PORT: $00C0 joystick port
CONTROLLER_02:           EQU $00F5         ; CONTROLLER_02: $00F5 player 2 controller
CONTROLLER_01:           EQU $00FC         ; CONTROLLER_01: $00FC player 1 controller
SOUND_PORT:              EQU $00FF         ; SOUND_PORT: $00FF SN76489A sound chip

; RAM DEFINITIONS ***************************

WORK_BUFFER:             EQU $7000         ; WORK_BUFFER: $7000 general work RAM base
CONTROLLER_BUFFER:       EQU $702B         ; CONTROLLER_BUFFER: $702B NMI gate (bit 7) / mode flag
JOYSTICK_BUFFER:         EQU $7038         ; JOYSTICK_BUFFER: $7038 BIOS POLLER output buffer
STACKTOP:                EQU $73B9         ; STACKTOP: $73B9 stack top

FNAME "output\CHOPLIFTER-1984-NEW.ROM"     ; output ROM: CHOPLIFTER-1984-NEW.ROM
CPU Z80

    ORG     $8000                          ; ROM loads at $8000

    DW      $55AA                          ; cart magic $55AA (reversed from standard $AA55)
    DB      $48, $70                       ; header: I/O pointer hi/lo bytes at $7048/$7000
    DB      $00, $70
    DB      $00, $70
    DW      JOYSTICK_BUFFER                ; JOYSTICK_BUFFER ($7038) in header
    DW      START                          ; game start address (START)
    DB      $C3, $56, $2C, $C3, $46, $85, $C3, $47; JP stubs for alternate entry points ($2C56, $8546, $8547)
    DB      $85, $C3, $FB, $AB, $C9, $00, $00, $C9; JP/NOP stubs continued
    DB      $00, $00, $ED, $4D, $00        ; RETN at end of cart header block

CART_ENTRY:                                ; cart entry: JP NMI; followed by Broderbund copyright string
    JP      NMI                            ; jump to NMI handler at $84BC
    DB      $1D, $20, $31, $39, $38, $32, $20, $44; copyright: 1982 Dan Gorlin
    DB      $41, $4E, $20, $47, $4F, $52, $4C, $49; copyright continued: "AN GORLI"
    DB      $4E, $2F, $42, $52, $30, $44, $45, $52; copyright continued: "N/BR0DER"
    DB      $42, $55, $4E, $44, $27, $53, $20, $43; copyright continued: "BUND'S C"
    DB      $48, $4F, $50, $4C, $49, $46, $54, $45; copyright continued: "HOPLIFTE"
    DB      $52, $1E, $1F, $2F, $31, $39, $38, $34; copyright tail: "R" year markers

START:                                     ; START: init SP, CONTROLLER_BUFFER=$01, $702C=0, call init subs
    LD      SP, STACKTOP                   ; SP = STACKTOP ($73B9)
    LD      A, $01                         ; A = $01
    LD      (CONTROLLER_BUFFER), A         ; (CONTROLLER_BUFFER) = $01: init NMI gate
    LD      HL, BOOT_UP                    ; HL = BOOT_UP ($0000)
    LD      ($702C), HL                    ; ($702C) = $0000: clear frame counter
    CALL    SUB_82AF                       ; init joystick buffer to $9B
    CALL    DELAY_LOOP_8775                ; clear $7048-$74FF, fill VRAM $0000 with $00
    CALL    SUB_8D3C                       ; VDP register setup (mode 1, sprite mode)
    CALL    SUB_8A12                       ; game options / difficulty select screen

LOC_806E:                                  ; LOC_806E: level-start init (clear $70BC-$70C0, set $7031, init sprite pool)
    XOR     A                              ; A = 0
    LD      B, $05                         ; B = $05: clear 5 bytes
    LD      HL, $70BC                      ; HL = $70BC: player position base

LOC_8074:                                  ; LOC_8074: clear $70BC-$70C0 (player X/Y + facing)
    LD      (HL), A                        ; (HL) = 0
    INC     HL                             ; HL++
    DJNZ    LOC_8074                       ; DJNZ: loop 5
    LD      ($7031), A                     ; ($7031) = 0: clear level counter
    LD      HL, $7152                      ; HL = $7152: sprite pool
    DEC     A                              ; DEC A
    LD      B, $08                         ; B = $08: init 8 entries to $FF

LOC_8081:                                  ; LOC_8081: fill $7152+$08 with $FF
    LD      (HL), A                        ; (HL) = $FF
    INC     HL                             ; HL++
    DJNZ    LOC_8081                       ; DJNZ: loop 8
    LD      A, $03                         ; A = $03
    LD      ($7152), A                     ; ($7152) = $03: 3 helicopter lives
    LD      ($7156), A                     ; ($7156) = $03: 3 reserve lives
    LD      HL, $702F                      ; HL = $702F: player flags
    LD      A, (HL)                        ; A = ($702F)
    AND     $FA                            ; AND $FA: clear bits 0,2 (facing and difficulty)
    BIT     1, A                           ; BIT 1, A: test 2P mode
    JR      Z, LOC_8099                    ; if 1P, skip difficulty set
    SET     2, A                           ; SET 2, A: set difficulty from 2P selection

LOC_8099:                                  ; LOC_8099: ($702F) = updated flags
    LD      (HL), A                        ; ($702F) = flags

LOC_809A:                                  ; LOC_809A: per-life reset (resets $702B, frame counters, VDP init)
    LD      A, $01                         ; A = $01
    LD      (CONTROLLER_BUFFER), A         ; (CONTROLLER_BUFFER) = $01: re-enable NMI gate
    LD      HL, BOOT_UP                    ; HL = BOOT_UP
    LD      ($7032), HL                    ; ($7032) = $0000: clear P1 input latch
    LD      ($702C), HL                    ; ($702C) = $0000: clear frame counter
    INC     HL                             ; INC HL
    LD      ($7034), HL                    ; ($7034) = $0001: init P2 frame counter
    CALL    SUB_8738                       ; SUB_8738: VDP register setup
    LD      A, ($7030)                     ; A = ($7030): difficulty level
    ADD     A, A                           ; A = A*2: index into difficulty table
    LD      HL, $847E                      ; HL = $847E: difficulty table
    RST     $10                            ; RST $10: HL += A (table lookup)
    LD      DE, $714E                      ; DE = $714E: enemy spawn table dest
    LD      BC, $0004                      ; BC = $0004: 4 bytes
    LDIR                                   ; LDIR: copy 4-byte enemy template
    LD      HL, $B478                      ; HL = $B478: enemy data table
    LD      DE, $0060                      ; DE = $0060
    CALL    SUB_86DD                       ; SUB_86DD: indexed copy (level-indexed)
    LD      HL, $B56D                      ; HL = $B56D: hostage spawn data
    LD      DE, $0098                      ; DE = $0098
    CALL    SUB_86E9                       ; SUB_86E9: secondary indexed copy
    LD      HL, $B57A
    LD      DE, $009C
    CALL    SUB_86E9
    LD      HL, $BC20
    LD      DE, $00A0
    CALL    SUB_86DD
    LD      HL, $BC33
    LD      DE, $00A4
    CALL    SUB_86DD
    LD      HL, $BC54
    LD      DE, $00A8
    CALL    SUB_86DD
    LD      HL, $BC96
    LD      DE, $00B0
    CALL    SUB_86DD
    LD      HL, $BCDA
    LD      DE, $00B8
    CALL    SUB_86DD
    LD      HL, $BC96
    LD      DE, $00C0
    CALL    SUB_86DD
    LD      HL, $BD1F
    LD      DE, $00C8
    CALL    SUB_86DD
    LD      DE, BOOT_UP
    LD      HL, $AF3B
    CALL    VDP_DATA_85C0
    LD      DE, $0018
    LD      HL, (NUMBER_TABLE)
    LD      BC, $000A
    CALL    SUB_86D5
    LD      DE, $0100
    LD      HL, $AFB8
    CALL    VDP_DATA_85C0
    LD      DE, $010D
    LD      HL, (NUMBER_TABLE)
    LD      BC, $000A
    CALL    SUB_86D5
    LD      DE, $0117
    LD      HL, ($006A)
    LD      BC, $001A
    CALL    SUB_86D5
    LD      DE, $0200
    LD      HL, $B001
    CALL    VDP_DATA_85C0
    LD      DE, $0003
    LD      A, $02
    LD      B, $1A
    CALL    DELAY_LOOP_89DB
    LD      DE, $0022
    LD      A, $05
    CALL    SUB_89D3
    LD      DE, $0042
    LD      A, $07
    CALL    SUB_89D3
    LD      DE, $0062
    LD      A, $09
    CALL    SUB_89D3
    LD      DE, $0260
    LD      A, $02
    CALL    DELAY_LOOP_89D9
    LD      DE, $0280
    CALL    DELAY_LOOP_89D7
    LD      DE, $02A0
    CALL    DELAY_LOOP_89D7
    LD      DE, $02C0
    CALL    DELAY_LOOP_89D7
    LD      DE, $02E0
    CALL    DELAY_LOOP_89D7
    LD      HL, $B405
    CALL    DELAY_LOOP_89B9
    LD      DE, BOOT_UP
    LD      HL, $B360
    CALL    VDP_DATA_858A
    LD      DE, $0100
    LD      HL, $B381
    CALL    VDP_DATA_858A
    LD      DE, $0200
    LD      HL, $B38C
    CALL    VDP_DATA_858A
    XOR     A
    LD      HL, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER
    LD      (HL), A
    INC     HL
    LD      (HL), A
    LD      ($735E), A                  ; RAM $735E
    CALL    SUB_8B20
    CALL    SUB_8D3C
    CALL    SUB_82DE
    CALL    SUB_848E
    LD      HL, $702F                   ; RAM $702F
    SET     3, (HL)
    RES     4, (HL)
    CALL    SUB_8D25
    CALL    SUB_895B
    LD      B, $5A
    CALL    DELAY_LOOP_8AEC
    CALL    SUB_89A1
    LD      HL, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER
    CALL    SUB_8575
    JR      Z, LOC_81EF
    INC     HL

LOC_81EF:
    LD      (HL), $9B
    LD      HL, $702F                   ; RAM $702F
    RES     3, (HL)

; ---- MAIN GAME LOOP ----
; LOC_81F6 -- outer game loop: wait for frame, then dispatch all subsystems.
; Frame sync via DELAY_LOOP_8A94. Drives player, enemies, projectiles, hostages.
LOC_81F6:                                  ; LOC_81F6: outer game loop (frame sync, dispatch all subsystems)
    CALL    DELAY_LOOP_8A94                ; DELAY_LOOP_8A94: wait for VBLANK / frame sync
    LD      A, ($702C)                     ; A = ($702C): frame counter (incremented by NMI)
    LD      HL, $702E                      ; HL = $702E: frame shadow
    CP      (HL)                           ; compare current vs shadow
    JR      Z, LOC_81F6                    ; if same, frame not yet advanced - loop
    LD      (HL), A                        ; ($702E) = A: update shadow to current frame
    LD      A, ($735E)                     ; A = ($735E): animation toggle
    XOR     $01                            ; XOR $01: flip toggle bit
    LD      ($735E), A                     ; ($735E) = toggled animation toggle
    CALL    SOUND_WRITE_87D1               ; sound trigger for game events
    CALL    SUB_8D74                       ; SUB_8D74: update game state / difficulty timer
    CALL    DELAY_LOOP_A4AB                ; DELAY_LOOP_A4AB: vehicle/truck animation update
    CALL    SUB_A036                       ; SUB_A036: vehicle spawn controller
    CALL    SUB_AACF                       ; SUB_AACF: enemy tank AI (move/animate/collide)
    CALL    SUB_AE0E                       ; SUB_AE0E: boss/special enemy logic
    CALL    DELAY_LOOP_98EB                ; DELAY_LOOP_98EB: helicopter position update + sprite
    CALL    SUB_A918                       ; SUB_A918: hostage state machine
    CALL    SOUND_WRITE_9DB3               ; SOUND_WRITE_9DB3: handle queued sound requests
    CALL    SUB_9EB0                       ; SUB_9EB0: helicopter collision check
    CALL    SUB_9EBE                       ; SUB_9EBE: helicopter animation controller
    CALL    SUB_9F1B                       ; SUB_9F1B: projectile pool (5 missile slots)
    CALL    DELAY_LOOP_9D52                ; DELAY_LOOP_9D52: missile/projectile update
    JR      LOC_81F6                       ; JR LOC_81F6: loop forever

LOC_8234:                                  ; LOC_8234: high score entry after good result
    CALL    SUB_897A                       ; SUB_897A: high score display/entry screen
    JR      LOC_823C

LOC_8239:                                  ; LOC_8239: game over path
    CALL    SUB_8972                       ; SUB_8972: game over screen

LOC_823C:                                  ; LOC_823C: post-game-over flow (VDP reinit, check 2P, advance level)
    CALL    SUB_8D3C                       ; SUB_8D3C: VDP register init for main game
    LD      A, ($702F)                     ; A = ($702F): player flags
    BIT     1, A                           ; BIT 1, A: test 2-player mode
    JR      Z, LOC_8293                    ; if 1P, skip 2P flow
    BIT     2, A                           ; BIT 2, A: test difficulty flag
    JR      Z, LOC_8293                    ; if not set, skip
    RES     2, A                           ; RES 2, A: clear difficulty flag
    LD      ($702F), A                     ; ($702F) = updated flags
    CALL    SOUND_WRITE_82CC               ; clear sound channel map ($703E, $7043)
    CALL    SUB_82D5                       ; SUB_82D5: delay + init sprite tables
    CALL    SUB_82B8                       ; SUB_82B8: toggle player flag ($702F bit 0)
    JR      NZ, LOC_8283                   ; JR NZ: if toggled, restart life
    CALL    SUB_82C2                       ; SUB_82C2: increment level counter ($7031++)
    JR      C, LOC_8283                    ; JR C: if level < 3, continue
    JR      LOC_8299

LOC_8261:
    CALL    SUB_8D3C
    LD      A, ($702F)                  ; RAM $702F
    BIT     1, A
    JR      Z, LOC_828B
    BIT     2, A
    JR      Z, LOC_828B
    LD      A, ($7031)                  ; RAM $7031
    CP      $02
    JR      C, LOC_8286
    CALL    SUB_897A
    CALL    SUB_82D5
    LD      HL, $702F                   ; RAM $702F
    RES     2, (HL)
    SET     0, (HL)

LOC_8283:
    JP      LOC_809A

LOC_8286:
    CALL    SUB_82B8
    JR      NZ, LOC_8283

LOC_828B:
    CALL    SUB_82C2
    JR      C, LOC_8283
    CALL    SUB_897A

LOC_8293:
    CALL    SOUND_WRITE_82CC
    CALL    SUB_82D5

LOC_8299:
    CALL    SUB_82AF
    CALL    SUB_8982
    CALL    SUB_8A59
    LD      B, A
    CALL    SOUND_WRITE_82CC
    LD      A, B
    CP      $0A
    JP      NZ, START
    JP      LOC_806E

SUB_82AF:                                  ; SUB_82AF: init joystick buffer ($7038=$9B, $7039=$9B)
    LD      A, $9B                         ; A = $9B
    LD      (JOYSTICK_BUFFER), A           ; (JOYSTICK_BUFFER) = $9B: init $7038
    LD      ($7039), A                     ; ($7039) = $9B
    RET                                    ; RET

SUB_82B8:                                  ; SUB_82B8: toggle $702F bit 0 (facing/player flag) and return NZ if set
    LD      A, $01                         ; A = $01
    LD      HL, $702F                      ; HL = $702F
    XOR     (HL)                           ; XOR (HL): toggle bit 0
    LD      (HL), A                        ; ($702F) = toggled
    BIT     0, A                           ; BIT 0, A: test bit 0
    RET                                    ; RET: NZ if bit 0 set

SUB_82C2:                                  ; SUB_82C2: increment level counter ($7031) and return C if >= 3
    LD      A, ($7031)                     ; A = ($7031)
    INC     A                              ; INC A
    LD      ($7031), A                     ; ($7031) = level+1
    CP      $03                            ; CP $03: compare to max level (3)
    RET                                    ; RET: C if below 3

SOUND_WRITE_82CC:                          ; SOUND_WRITE_82CC: clear sound request slots ($703E=$FF, $7043=$FF)
    LD      A, $FF                         ; A = $FF
    LD      ($703E), A                     ; ($703E) = $FF: no sound request
    LD      ($7043), A                     ; ($7043) = $FF
    RET                                    ; RET

SUB_82D5:                                  ; SUB_82D5: delay B=$B4 frames + init sprite tables (SUB_89A1)
    LD      B, $B4                         ; B = $B4: delay count
    CALL    DELAY_LOOP_8AAA                ; DELAY_LOOP_8AAA: busy-wait B frames
    CALL    SUB_89A1                       ; SUB_89A1: init sprite name table entries
    RET                                    ; RET

SUB_82DE:                                  ; SUB_82DE: level init (copy templates, enemy records, hostage counts)
    LD      HL, $10F0                      ; HL = $10F0
    LD      ($7044), HL                    ; ($7044) = $10F0: level-width (16*16 = 256 tiles wide)
    LD      HL, BOOT_UP                    ; HL = BOOT_UP
    LD      ($7046), HL                    ; ($7046) = $0000: VRAM scroll base
    LD      HL, $8D44                      ; HL = $8D44: enemy template table
    LD      DE, $715A                      ; DE = $715A: enemy record destination
    LD      BC, $0020                      ; BC = $0020: 32 bytes
    LDIR                                   ; LDIR: copy 32-byte enemy templates
    LD      HL, $8D64                      ; HL = $8D64: enemy type data
    LD      DE, $7048                      ; DE = $7048: entity block base
    LD      BC, $0010                      ; BC = $0010: 16 bytes
    LDIR                                   ; LDIR: copy 16-byte enemy type data
    CALL    SOUND_WRITE_94C0               ; SOUND_WRITE_94C0: init/clear sound channel buffers
    CALL    SUB_8CB8                       ; SUB_8CB8: init entity colour/type tables
    LD      A, $06                         ; A = $06: 6 entity records to init
    LD      DE, $717A                      ; DE = $717A: entity block dest

LOC_830B:                                  ; LOC_830B: copy 10-byte entity template (6 times)
    LD      HL, $9D33                      ; HL = $9D33: entity template source
    LD      BC, $000A                      ; BC = $000A: 10 bytes
    LDIR                                   ; LDIR: copy entity record
    DEC     A                              ; DEC A
    JR      NZ, LOC_830B                   ; DJNZ: loop 6
    LD      HL, $0CE0                      ; HL = $0CE0
    LD      ($7185), HL                    ; ($7185) = $0CE0: entity 0 world X position
    LD      HL, $0DD0                      ; HL = $0DD0
    LD      ($718F), HL                    ; ($718F) = $0DD0: entity 1 world X
    LD      HL, $0EC0                      ; HL = $0EC0
    LD      ($7199), HL                    ; ($7199) = $0EC0: entity 2 world X
    LD      HL, $0FC0                      ; HL = $0FC0
    LD      ($71A3), HL                    ; ($71A3) = $0FC0: entity 3 world X
    LD      HL, $10B0
    LD      ($71AD), HL                 ; RAM $71AD
    LD      A, $04
    LD      DE, $71B6                   ; RAM $71B6

LOC_8339:
    LD      HL, $9D65
    LD      BC, $000A
    LDIR    
    DEC     A
    JR      NZ, LOC_8339
    LD      HL, $0880
    LD      ($71C1), HL                 ; RAM $71C1
    LD      HL, $0998
    LD      ($71CB), HL                 ; RAM $71CB
    LD      HL, $0AB0
    LD      ($71D5), HL                 ; RAM $71D5
    LD      HL, $7152                   ; RAM $7152
    CALL    SUB_8575
    JR      Z, LOC_8361
    LD      HL, $7156                   ; RAM $7156

LOC_8361:
    LD      B, $04

LOC_8363:
    LD      A, (HL)
    CP      $FF
    JR      Z, LOC_8383
    LD      IX, $71B6                   ; RAM $71B6
    AND     A
    JR      Z, LOC_8377

LOC_836F:
    LD      DE, $000A
    ADD     IX, DE
    DEC     A
    JR      NZ, LOC_836F

LOC_8377:
    LD      DE, $9D97
    LD      (IX+8), E
    LD      (IX+9), D
    INC     HL
    DJNZ    LOC_8363

LOC_8383:
    LD      A, $04
    LD      DE, $72FA                   ; RAM $72FA

LOC_8388:
    LD      HL, $9D6F
    LD      BC, $0008
    LDIR    
    DEC     A
    JR      NZ, LOC_8388
    LD      HL, $0892
    LD      ($7303), HL                 ; RAM $7303
    LD      HL, $09AA
    LD      ($730B), HL                 ; RAM $730B
    LD      HL, $0AC2
    LD      ($7313), HL                 ; RAM $7313
    LD      A, $0E
    LD      ($7302), A                  ; RAM $7302
    INC     A
    LD      ($730A), A                  ; RAM $730A
    INC     A
    LD      ($7312), A                  ; RAM $7312
    LD      HL, $9D77
    LD      DE, $707C                   ; RAM $707C
    LD      BC, $0010
    LDIR    
    LD      DE, $71DE                   ; RAM $71DE
    LD      HL, $9E2D
    LD      BC, $001C
    LDIR    
    LD      HL, $9E49
    LD      DE, $7058                   ; RAM $7058
    LD      BC, $0004
    LDIR    
    LD      DE, $71FA                   ; RAM $71FA
    LD      HL, $9EFD
    LD      BC, $001E
    LDIR    
    LD      HL, $9EE9
    LD      DE, $705C                   ; RAM $705C
    LD      BC, $0014
    LDIR    
    LD      A, $02
    LD      ($7333), A                  ; RAM $7333
    LD      DE, $7218                   ; RAM $7218

LOC_83F1:
    LD      HL, $9F56
    LD      BC, $001B
    LDIR    
    DEC     A
    JR      NZ, LOC_83F1
    LD      HL, $0BE0
    LD      ($7234), HL                 ; RAM $7234
    LD      A, $11
    LD      ($7248), A                  ; RAM $7248
    LD      A, $04
    LD      DE, $708C                   ; RAM $708C

LOC_840C:
    LD      HL, $9F52
    LD      BC, $0004
    LDIR    
    DEC     A
    JR      NZ, LOC_840C
    XOR     A
    LD      ($7337), A                  ; RAM $7337
    LD      ($7336), A                  ; RAM $7336
    LD      HL, $7338                   ; RAM $7338
    LD      B, $18

LOC_8423:
    LD      (HL), A
    INC     HL
    DJNZ    LOC_8423
    LD      DE, $709C                   ; RAM $709C
    LD      A, $06

LOC_842C:
    LD      HL, $98A0
    LD      BC, $0004
    LDIR    
    DEC     A
    JR      NZ, LOC_842C
    LD      DE, $72DC                   ; RAM $72DC
    LD      HL, $A8FF
    LD      BC, $0004
    LDIR    
    LD      A, $02
    LD      DE, $72E0                   ; RAM $72E0

LOC_8447:
    LD      HL, $A903
    LD      BC, $000D
    LDIR    
    DEC     A
    JR      NZ, LOC_8447
    LD      A, $1C
    LD      ($72ED), A                  ; RAM $72ED
    LD      HL, $A910
    LD      DE, $70B4                   ; RAM $70B4
    LD      BC, $0008
    LDIR    
    LD      HL, $AABD
    LD      DE, $731A                   ; RAM $731A
    LD      BC, $000E
    LDIR    
    LD      HL, $AACB
    LD      DE, $7078                   ; RAM $7078
    LD      BC, $0004
    LDIR    
    CALL    SUB_ADBE
    JP      LOC_A373
    DB      $80, $58, $02, $30, $A0, $E0, $01, $20
    DB      $C0, $68, $01, $10, $E0, $F0, $00, $08

SUB_848E:                                  ; SUB_848E: screen setup / palette init (map tile colours + sprite palette)
    XOR     A
    LD      (CONTROLLER_BUFFER), A      ; CONTROLLER_BUFFER
    LD      B, $01
    LD      C, $E2
    CALL    WRITE_REGISTER
    CALL    READ_REGISTER
    LD      ($73C5), A                  ; RAM $73C5
    RET     

LOC_84A0:
    PUSH    HL
    LD      HL, CONTROLLER_BUFFER       ; CONTROLLER_BUFFER
    RES     0, (HL)
    BIT     7, (HL)
    LD      (HL), $00
    POP     HL
    RET     Z

; ---- NMI HANDLER ($84BC) ----
; Bit 7 of CONTROLLER_BUFFER gates re-entry. Saves regs, POLLER, PLAY_SONGS, SOUND_MAN.
; Increments $702C (frame counter). Reads VDP status to $73C5.
NMI:                                       ; NMI: save regs, gate re-entry via $702B bit 7, POLLER/PLAY_SONGS/SOUND_MAN, inc frame counter
    PUSH    AF                             ; PUSH AF: save main AF
    LD      A, (CONTROLLER_BUFFER)         ; A = (CONTROLLER_BUFFER): NMI gate byte
    SET     7, A                           ; SET 7, A: set bit 7 (mark NMI in-progress)
    LD      (CONTROLLER_BUFFER), A         ; (CONTROLLER_BUFFER) = updated gate
    BIT     0, A                           ; BIT 0, A: test re-entry flag
    JR      Z, LOC_84BC                    ; JR Z: if not set, proceed with NMI
    POP     AF                             ; POP AF: restore (re-entry path)
    RETN                                   ; RETN: return immediately if re-entrant

LOC_84BC:                                  ; LOC_84BC: full NMI body
    PUSH    BC                             ; PUSH BC
    PUSH    DE                             ; PUSH DE
    PUSH    HL                             ; PUSH HL
    PUSH    IX                             ; PUSH IX
    PUSH    IY                             ; PUSH IY
    EX      AF, AF'                        ; EX AF,AF: switch to alternate AF
    EXX                                    ; EXX: switch to alternate registers
    PUSH    AF                             ; PUSH AF (alternate)
    PUSH    BC                             ; PUSH BC (alternate)
    PUSH    DE                             ; PUSH DE (alternate)
    PUSH    HL                             ; PUSH HL (alternate)
    CALL    POLLER                         ; CALL POLLER: poll controller -> $7038
    CALL    PLAY_SONGS                     ; CALL PLAY_SONGS: advance song engine
    CALL    SOUND_MAN                      ; CALL SOUND_MAN: advance sound engine
    LD      HL, ($702C)                    ; HL = ($702C): frame counter
    INC     HL                             ; INC HL
    LD      ($702C), HL                    ; ($702C) = incremented frame counter
    POP     HL                             ; POP HL (alternate)
    POP     DE                             ; POP DE (alternate)
    POP     BC                             ; POP BC (alternate)
    POP     AF                             ; POP AF (alternate)
    EX      AF, AF'                        ; EX AF,AF: back to main AF
    EXX                                    ; EXX: back to main registers
    POP     IY                             ; POP IY
    POP     IX                             ; POP IX
    POP     HL                             ; POP HL
    POP     DE                             ; POP DE
    CALL    READ_REGISTER                  ; READ_REGISTER: read VDP status -> A
    LD      ($73C5), A                     ; ($73C5) = VDP status byte cache
    POP     BC                             ; POP BC
    POP     AF                             ; POP AF
    RETN                                   ; RETN

SUB_84EF:                                  ; SUB_84EF: clear CONTROLLER_BUFFER gate (=$01, allow NMI)
    PUSH    AF                             ; PUSH AF
    LD      A, $01                         ; A = $01
    LD      (CONTROLLER_BUFFER), A         ; (CONTROLLER_BUFFER) = $01: clear bit 7 / re-enable NMI
    POP     AF                             ; POP AF
    RET                                    ; RET

SUB_84F7:                                  ; SUB_84F7: combined NMI-gate-clear + save full context
    CALL    SUB_84EF                       ; SUB_84EF: clear NMI gate
    PUSH    AF
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IX
    PUSH    IY
    CALL    SUB_86DD
    JR      LOC_853B

SUB_8507:
    CALL    SUB_84EF
    PUSH    AF
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IX
    PUSH    IY
    CALL    SUB_86E3
    JR      LOC_853B

LOC_8517:
    CALL    SUB_84EF
    PUSH    AF
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IX
    PUSH    IY
    CALL    SUB_86E9
    JR      LOC_853B

LOC_8527:
    LD      A, $00
    JR      LOC_852D

LOC_852B:
    LD      A, $02

LOC_852D:
    CALL    SUB_84EF
    PUSH    AF
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IX
    PUSH    IY
    CALL    SUB_86D7

LOC_853B:
    POP     IY
    POP     IX
    POP     HL
    POP     DE
    POP     BC
    POP     AF
    JP      LOC_84A0
    DB      $87, $5F, $16, $00, $19, $C9

SUB_854C:
    PUSH    HL
    LD      HL, $73C8                   ; RAM $73C8
    LD      A, R
    ADD     A, (HL)
    RRCA    
    LD      (HL), A
    POP     HL
    RET     

SUB_8557:
    LD      A, (IX+1)
    SUB     (IX+2)
    LD      (IX+1), A
    RET     NC
    LD      A, (IX+3)
    ADD     A, (IX+1)
    LD      (IX+1), A
    SCF     
    RET     

VDP_REG_856C:
    LD      A, E
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $40
    ADD     A, D
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    RET     

SUB_8575:
    LD      A, ($702F)                  ; RAM $702F
    BIT     0, A
    RET     

LOC_857B:
    CALL    VDP_REG_856C

LOC_857E:
    LD      A, (HL)
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    NOP     
    NOP     
    INC     HL
    DEC     BC
    LD      A, B
    OR      C
    JR      NZ, LOC_857E
    RET     

VDP_DATA_858A:
    CALL    SUB_86FF
    CALL    VDP_REG_856C

LOC_8590:
    LD      A, (HL)
    CP      $FF
    RET     Z
    BIT     7, A
    RES     7, A
    LD      C, A
    INC     HL
    JR      NZ, LOC_85B1

LOC_859C:
    PUSH    HL
    LD      B, $08

LOC_859F:
    LD      A, (HL)
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    NOP     
    NOP     
    INC     HL
    DJNZ    LOC_859F
    POP     HL
    DEC     C
    JR      NZ, LOC_859C
    LD      DE, $0008
    ADD     HL, DE
    JR      LOC_8590

LOC_85B1:
    LD      A, (HL)

LOC_85B2:
    LD      B, $08

LOC_85B4:
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    NOP     
    NOP     
    DJNZ    LOC_85B4
    DEC     C
    JR      NZ, LOC_85B2
    INC     HL
    JR      LOC_8590

VDP_DATA_85C0:
    CALL    SUB_870C

LOC_85C3:
    CALL    VDP_REG_856C

LOC_85C6:
    LD      A, (HL)
    BIT     7, A
    JR      Z, LOC_85DC
    BIT     6, A
    RET     NZ
    RES     7, A
    LD      B, A
    INC     HL

LOC_85D2:
    LD      A, (HL)
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    NOP     
    NOP     
    INC     HL
    DJNZ    LOC_85D2
    JR      LOC_85C6

LOC_85DC:
    LD      B, A
    INC     HL
    LD      A, (HL)
    INC     HL

LOC_85E0:
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    NOP     
    NOP     
    DJNZ    LOC_85E0
    JR      LOC_85C6

LOC_85E8:
    PUSH    DE
    LD      B, $02
    CALL    DELAY_LOOP_86AB
    POP     DE
    CALL    VDP_REG_856C
    LD      IY, WORK_BUFFER             ; WORK_BUFFER
    LD      L, (IY+2)
    LD      H, (IY+3)
    CALL    VDP_DATA_865A
    LD      L, (IY+0)
    LD      H, (IY+1)
    JR      VDP_DATA_865A

LOC_8607:
    PUSH    DE
    LD      B, $08
    CALL    DELAY_LOOP_86AB
    POP     DE
    CALL    VDP_REG_856C
    LD      IY, WORK_BUFFER             ; WORK_BUFFER
    LD      L, (IY+10)
    LD      H, (IY+11)
    CALL    VDP_DATA_865A
    LD      L, (IY+8)
    LD      H, (IY+9)
    CALL    VDP_DATA_865A
    LD      L, (IY+14)
    LD      H, (IY+15)
    CALL    VDP_DATA_865A
    LD      L, (IY+12)
    LD      H, (IY+13)
    CALL    VDP_DATA_865A
    LD      L, (IY+2)
    LD      H, (IY+3)
    CALL    VDP_DATA_865A
    LD      L, (IY+0)
    LD      H, (IY+1)
    CALL    VDP_DATA_865A
    LD      L, (IY+6)
    LD      H, (IY+7)
    CALL    VDP_DATA_865A
    LD      L, (IY+4)
    LD      H, (IY+5)

VDP_DATA_865A:
    LD      C, $00

LOC_865C:
    LD      A, C
    CP      $10
    RET     NC
    LD      A, (HL)
    BIT     7, A
    JR      NZ, LOC_8676
    LD      B, A
    ADD     A, C
    LD      C, A
    INC     HL
    LD      A, (HL)
    INC     HL
    CALL    SUB_8689

LOC_866E:
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    NOP     
    NOP     
    DJNZ    LOC_866E
    JR      LOC_865C

LOC_8676:
    RES     7, A
    LD      B, A
    ADD     A, C
    LD      C, A
    INC     HL

LOC_867C:
    LD      A, (HL)
    CALL    SUB_8689
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    NOP     
    NOP     
    INC     HL
    DJNZ    LOC_867C
    JR      LOC_865C

SUB_8689:
    SLA     A
    RR      E
    SLA     A
    RR      E
    SLA     A
    RR      E
    SLA     A
    RR      E
    SLA     A
    RR      E
    SLA     A
    RR      E
    SLA     A
    RR      E
    SLA     A
    RR      E
    LD      A, E
    RET     

DELAY_LOOP_86AB:
    DB      $EB
    LD      HL, WORK_BUFFER             ; WORK_BUFFER

LOC_86AF:
    LD      (HL), E
    INC     HL
    LD      (HL), D
    INC     HL
    DJNZ    LOC_86B6
    RET     

LOC_86B6:
    LD      C, $F0

LOC_86B8:
    LD      A, (DE)
    BIT     7, A
    JR      NZ, LOC_86C5
    INC     DE
    INC     DE

LOC_86BF:
    ADD     A, C
    LD      C, A
    JR      Z, LOC_86AF
    JR      LOC_86B8

LOC_86C5:
    RES     7, A
    INC     DE
    PUSH    HL
    LD      L, A
    LD      H, $00
    ADD     HL, DE
    POP     DE
    DB      $EB
    JR      LOC_86BF
    DB      $3E, $02, $18, $02

SUB_86D5:
    LD      A, $03

SUB_86D7:
    CALL    SUB_86EF
    JP      LOC_857B

SUB_86DD:                                  ; SUB_86DD: copy from HL into VRAM-dest block indexed by level ($7031)
    CALL    SUB_871E
    JP      LOC_85C3

SUB_86E3:
    CALL    SUB_871E
    JP      LOC_8607

SUB_86E9:                                  ; SUB_86E9: secondary level-indexed copy helper
    CALL    SUB_871E
    JP      LOC_85E8

SUB_86EF:
    CP      $00
    JR      Z, LOC_8718
    CP      $01
    JR      Z, SUB_871E
    CP      $02
    JR      Z, LOC_8712
    CP      $03
    JR      Z, SUB_870C

SUB_86FF:
    PUSH    HL
    LD      HL, ($73FA)                 ; RAM $73FA
    LD      A, ($73C3)                  ; RAM $73C3
    BIT     1, A
    JR      Z, LOC_872B
    JR      LOC_8722

SUB_870C:
    PUSH    HL
    LD      HL, ($73F8)                 ; RAM $73F8
    JR      LOC_8722

LOC_8712:
    PUSH    HL
    LD      HL, ($73F6)                 ; RAM $73F6
    JR      LOC_872B

LOC_8718:
    PUSH    HL
    LD      HL, ($73F2)                 ; RAM $73F2
    JR      LOC_8725

SUB_871E:
    PUSH    HL
    LD      HL, ($73F4)                 ; RAM $73F4

LOC_8722:
    CALL    SUB_872F

LOC_8725:
    CALL    SUB_872F
    CALL    SUB_872F

LOC_872B:
    ADD     HL, DE
    DB      $EB
    POP     HL
    RET     

SUB_872F:
    SLA     E
    RL      D
    SLA     C
    RL      B
    RET     

SUB_8738:                                  ; SUB_8738: VDP register setup (mode 1, sprite 8x8, all tables init)
    LD      B, $00
    LD      C, $02
    CALL    WRITE_REGISTER
    LD      B, $01
    LD      C, $80
    CALL    WRITE_REGISTER
    LD      A, $03
    LD      HL, BOOT_UP
    CALL    INIT_TABLE
    LD      A, $02
    LD      HL, $1800
    CALL    INIT_TABLE
    LD      A, $00
    LD      HL, $1B00
    CALL    INIT_TABLE
    LD      A, $04
    LD      HL, $2000
    CALL    INIT_TABLE
    LD      A, $01
    LD      HL, $3800
    CALL    INIT_TABLE
    LD      B, $07
    LD      C, $01
    CALL    WRITE_REGISTER

DELAY_LOOP_8775:                           ; DELAY_LOOP_8775: clear RAM $7048-$74FF ($74 bytes), fill VRAM $0000..$3FFF with $00
    XOR     A                              ; A = 0
    LD      HL, $7048                      ; HL = $7048: RAM clear base
    LD      B, $74                         ; B = $74: $74 bytes

LOC_877B:                                  ; LOC_877B: fill loop
    LD      (HL), A                        ; (HL) = 0
    INC     HL                             ; HL++
    DJNZ    LOC_877B                       ; DJNZ: loop $74
    LD      HL, BOOT_UP                    ; HL = BOOT_UP: VRAM fill base $0000
    LD      DE, $4000                      ; DE = $4000: 16 KB
    JP      FILL_VRAM                      ; JP FILL_VRAM: fill entire VRAM with 0 (tail call)

SUB_8788:                                  ; SUB_8788: table lookup via A (RST $10 index into $7048 table)
    LD      HL, $7048                      ; HL = $7048: lookup table base
    LD      A, (IX+0)                      ; A = (IX+0): index
    ADD     A, A                           ; ADD A,A: double index
    RST     $10                            ; RST $10: HL += A (add doubled index)
    PUSH    HL                             ; PUSH HL / POP IY: IY = table[index]
    POP     IY
    RET                                    ; RET

SUB_8794:
    XOR     A
    PUSH    HL
    LD      L, D
    LD      H, A
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    LD      D, A
    ADD     HL, DE
    DB      $EB
    POP     HL
    RET     

SUB_87A2:
    LD      DE, $7032                   ; RAM $7032
    LD      HL, $7036                   ; RAM $7036
    JR      LOC_87B7

LOC_87AA:
    LD      A, (IY+0)
    CP      $E0
    JR      Z, LOC_87C9
    LD      DE, $7033                   ; RAM $7033
    LD      HL, $7037                   ; RAM $7037

LOC_87B7:
    LD      A, (DE)
    OR      C
    LD      (DE), A
    LD      A, (HL)
    AND     C
    RET     NZ
    LD      (IY+0), $E0
    JP      LOC_88AA

SUB_87C4:
    LD      HL, $7032                   ; RAM $7032
    JR      LOC_87CC

LOC_87C9:
    LD      HL, $7033                   ; RAM $7033

LOC_87CC:
    LD      A, C
    CPL     
    AND     (HL)
    LD      (HL), A
    RET     

SOUND_WRITE_87D1:                          ; SOUND_WRITE_87D1: sound trigger for fire / game events
    LD      HL, $FFFF
    LD      ($7036), HL                 ; RAM $7036
    LD      A, ($7032)                  ; RAM $7032
    LD      B, A
    LD      A, ($7033)                  ; RAM $7033
    LD      C, A
    OR      B
    RET     Z
    INC     HL
    LD      ($7036), HL                 ; RAM $7036
    CALL    SUB_87F4
    CALL    SUB_87F4
    LD      A, ($7172)                  ; RAM $7172
    CP      $78
    RET     NC
    CALL    SUB_87F4

SUB_87F4:
    CALL    SUB_880B
    LD      A, B
    AND     L
    JR      Z, LOC_8800
    LD      HL, $7036                   ; RAM $7036
    JR      LOC_8808

LOC_8800:
    LD      A, C
    AND     H
    JR      Z, SUB_87F4
    LD      H, A
    LD      HL, $7037                   ; RAM $7037

LOC_8808:
    OR      (HL)
    LD      (HL), A
    RET     

SUB_880B:
    LD      HL, ($7034)                 ; RAM $7034
    LD      A, L
    RLA     
    RL      H
    RL      L
    LD      ($7034), HL                 ; RAM $7034
    RET     

LOC_8818:
    RES     7, (IY+3)
    LD      HL, ($7044)                 ; RAM $7044
    LD      E, (IX+1)
    LD      D, (IX+2)
    RST     $20
    JP      C, LOC_88A2
    LD      A, H
    AND     A
    JR      Z, LOC_8857
    CP      $02
    JP      NC, LOC_88A2
    LD      A, L
    CP      (IX+3)
    JR      NC, LOC_88A2
    LD      A, (IX+5)
    AND     A
    JR      NZ, LOC_8851

LOC_883E:
    SET     7, (IY+3)
    LD      B, $1E

LOC_8844:
    LD      A, B
    SUB     L

LOC_8846:
    LD      (IY+1), A
    LD      A, (IX+4)
    LD      (IY+0), A
    JR      LOC_88AA

LOC_8851:
    LD      A, $80
    ADD     A, L
    LD      B, A
    JR      LOC_8868

LOC_8857:
    LD      B, $FE
    LD      A, (IX+5)
    AND     A
    JR      Z, LOC_8844
    LD      A, B
    SUB     L
    SUB     $80
    LD      B, A
    JR      NC, LOC_8868
    NEG     

LOC_8868:
    LD      E, A
    LD      C, (IX+5)
    DEC     C
    JR      Z, LOC_887A
    DEC     C
    JR      Z, LOC_887C
    DEC     C
    JR      Z, LOC_887E
    DEC     C
    JR      Z, LOC_8880
    JR      LOC_8882

LOC_887A:
    SRL     A

LOC_887C:
    SRL     A

LOC_887E:
    SRL     A

LOC_8880:
    SRL     A

LOC_8882:
    ADD     A, A
    JR      C, LOC_88A2
    ADD     A, E
    JR      C, LOC_88A2
    BIT     7, B
    JR      NZ, LOC_8892
    ADD     A, $80
    JR      C, LOC_88A2
    JR      LOC_8846

LOC_8892:
    SUB     $80
    JR      C, LOC_889E
    CP      (IX+3)
    JR      NC, LOC_88A2
    LD      L, A
    JR      LOC_883E

LOC_889E:
    NEG     
    JR      LOC_8846

LOC_88A2:
    RES     7, (IY+3)
    LD      (IY+0), $E0

LOC_88AA:
    PUSH    IY
    POP     HL
    LD      E, (IX+0)
    LD      D, $00
    LD      BC, $0001
    JP      LOC_8527

SUB_88B8:                                  ; SUB_88B8: sprite + wall collision detection (IX=sprite rec, HL=$7044 level width)
    RES     1, (IX+0)                      ; RES 1, (IX+0): clear collision flag
    LD      HL, ($7044)                    ; HL = ($7044): level-width (used for bounds check)
    LD      E, (IX+1)                      ; E = (IX+1): sprite X lo byte
    LD      D, (IX+2)                      ; D = (IX+2): sprite X hi byte
    RST     $20                            ; RST $20: bounds check (DE vs HL)
    RET     C                              ; RET C: within bounds, no wall hit
    LD      A, H                           ; A = H
    AND     A                              ; AND A: test high byte
    JR      NZ, LOC_88D1                   ; JR NZ: if H != 0, at right edge
    LD      A, L                           ; A = L
    CP      $08                            ; CP $08: compare to left-edge threshold
    RET     C                              ; RET C: if < 8, no collision
    JR      LOC_88DF                       ; JR LOC_88DF: hit at left edge

LOC_88D1:
    CP      $02
    RET     NC
    LD      A, L
    SRL     A
    SRL     A
    SRL     A
    CP      (IX+3)
    RET     NC

LOC_88DF:                                  ; LOC_88DF: compute collision response (X-clamp, wall bounce)
    LD      A, $07                         ; A = $07
    AND     L                              ; AND L: position within tile
    SUB     $07                            ; SUB $07: invert
    NEG                                    ; NEG: pixel distance from edge
    LD      (IX+7), A                      ; (IX+7) = pixel distance from wall
    AND     $04                            ; AND $04: test tile quadrant
    LD      E, A                           ; E = quadrant flag
    SRL     H                              ; SRL H / RR L: H:L >> 1
    RR      L                              ; SRL H / RR L: H:L >> 2
    SRL     H
    RR      L
    SRL     H                              ; SRL H / RR L: H:L >> 3 (pixel -> tile coords)
    RR      L
    LD      A, $20                         ; A = $20
    SUB     L                              ; SUB L: distance from right edge
    LD      (IX+6), A                      ; (IX+6) = clamped X tile position
    LD      C, A
    JP      M, LOC_891F
    LD      A, $20
    SUB     C
    LD      C, (IX+3)
    CP      C
    JR      NC, LOC_890C
    LD      C, A

LOC_890C:
    LD      L, (IX+8)
    LD      H, (IX+9)
    LD      A, E
    SRL     A
    RST     $18
    LD      A, (HL)
    INC     HL
    LD      H, (HL)
    LD      L, A
    LD      E, (IX+6)
    JR      LOC_8939

LOC_891F:
    NEG     
    LD      B, A
    LD      A, (IX+3)
    SUB     B
    LD      C, A
    LD      L, (IX+8)
    LD      H, (IX+9)
    LD      A, E
    SRL     A
    RST     $18
    LD      A, (HL)
    INC     HL
    LD      H, (HL)
    LD      L, A
    LD      E, B
    ADD     HL, DE
    LD      E, $00

LOC_8939:
    SET     1, (IX+0)
    LD      B, (IX+4)
    LD      D, (IX+5)

LOC_8943:
    PUSH    BC
    PUSH    DE
    PUSH    HL
    CALL    SUB_8794
    LD      B, $00
    CALL    LOC_852B
    POP     HL
    LD      E, (IX+3)
    LD      D, $00
    ADD     HL, DE
    POP     DE
    INC     D
    POP     BC
    DJNZ    LOC_8943
    RET     

; ---- LEVEL DATA LOADER ----
; SUB_895B -- load level assets indexed by $7031 (0-2, wraps at 3).
; Tables at ROM $8B75/$8B85/$8B95. Sets enemy templates, hostage counts, scroll limits.
SUB_895B:                                  ; SUB_895B: load level data indexed by $7031 (level 0-2)
    CALL    SUB_89FC
    LD      A, ($7031)                  ; RAM $7031
    LD      HL, $896C
    RST     $10
    LD      A, (HL)
    INC     HL
    LD      H, (HL)
    LD      L, A
    JP      LOC_8996
    DB      $75, $BB, $85, $BB, $95, $BB

SUB_8972:                                  ; SUB_8972: game over screen
    CALL    SUB_89FC
    LD      HL, $BB6B
    JR      LOC_8996

SUB_897A:                                  ; SUB_897A: high score / game end screen
    CALL    SUB_89FC
    LD      HL, $BB5F
    JR      LOC_8996

SUB_8982:                                  ; SUB_8982: init sprite palette and VDP display mode
    LD      B, $0E
    CALL    SUB_89F5
    LD      HL, $BBA5
    CALL    LOC_8996
    LD      HL, $BBAD
    CALL    LOC_8996
    LD      HL, $BBBE

LOC_8996:
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    INC     HL
    LD      C, (HL)
    INC     HL
    LD      B, $00
    JP      LOC_852B

SUB_89A1:                                  ; SUB_89A1: init sprite name table entries
    LD      DE, $0108
    CALL    SUB_89CD
    LD      DE, $0128
    CALL    SUB_89CD
    LD      DE, $0148
    CALL    SUB_89CD
    LD      DE, $0168
    JP      SUB_89CD

DELAY_LOOP_89B9:
    LD      B, (HL)
    INC     HL

LOC_89BB:
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    INC     HL
    PUSH    HL
    PUSH    BC
    LD      BC, $0001
    CALL    LOC_852B
    POP     BC
    POP     HL
    INC     HL
    DJNZ    LOC_89BB
    RET     

SUB_89CD:
    LD      A, $00
    LD      B, $0F
    JR      DELAY_LOOP_89DB

SUB_89D3:
    LD      B, $1C
    JR      DELAY_LOOP_89DB

DELAY_LOOP_89D7:
    LD      A, $01

DELAY_LOOP_89D9:
    LD      B, $20

DELAY_LOOP_89DB:
    LD      C, B
    LD      HL, WORK_BUFFER             ; WORK_BUFFER

LOC_89DF:
    LD      (HL), A
    INC     HL
    DJNZ    LOC_89DF
    LD      HL, WORK_BUFFER             ; WORK_BUFFER
    JP      LOC_852B

SUB_89E9:
    LD      A, $08
    LD      B, $0D
    LD      DE, $0169
    CALL    DELAY_LOOP_89DB
    LD      B, $0D

SUB_89F5:
    LD      A, $07
    LD      DE, $0129
    JR      DELAY_LOOP_89DB

SUB_89FC:
    CALL    SUB_89E9
    LD      A, ($702F)                  ; RAM $702F
    BIT     1, A
    RET     Z
    LD      HL, $BB49
    CALL    SUB_8575
    JR      Z, LOC_8A10
    LD      HL, $BB54

LOC_8A10:
    JR      LOC_8996

SUB_8A12:                                  ; SUB_8A12: game options / difficulty select screen
    CALL    GAME_OPT

LOC_8A15:
    LD      HL, $1C20
    LD      (WORK_BUFFER), HL           ; WORK_BUFFER
    CALL    SUB_848E

LOC_8A1E:
    LD      A, ($703E)                  ; RAM $703E
    CALL    SUB_8A7D
    RET     C
    LD      A, ($7043)                  ; RAM $7043
    CALL    SUB_8A7D
    RET     C
    CALL    SUB_8A45
    JR      NZ, LOC_8A1E
    CALL    SUB_8B06

LOC_8A34:
    CALL    SUB_8AC4
    JR      NZ, LOC_8A34
    LD      B, $07
    LD      C, $05
    CALL    WRITE_REGISTER
    CALL    SUB_8B15
    JR      LOC_8A15

SUB_8A45:
    LD      A, ($702C)                  ; RAM $702C
    LD      HL, $702E                   ; RAM $702E
    CP      (HL)
    JR      Z, LOC_8A56
    LD      (HL), A
    LD      HL, (WORK_BUFFER)           ; WORK_BUFFER
    DEC     HL
    LD      (WORK_BUFFER), HL           ; WORK_BUFFER

LOC_8A56:
    LD      A, L
    OR      H
    RET     

SUB_8A59:
    LD      HL, $1C20
    LD      (WORK_BUFFER), HL           ; WORK_BUFFER

LOC_8A5F:
    CALL    SUB_8AC4
    RET     Z
    CALL    SUB_8A45
    JR      NZ, LOC_8A5F
    CALL    SUB_8B06

LOC_8A6B:
    CALL    SUB_8A71
    JR      NC, LOC_8A6B
    RET     

SUB_8A71:
    LD      A, ($703E)                  ; RAM $703E
    CP      $0C
    RET     C
    LD      A, ($7043)                  ; RAM $7043
    CP      $0C
    RET     

SUB_8A7D:
    DEC     A
    CP      $08
    RET     NC
    LD      HL, $702F                   ; RAM $702F
    LD      B, $00
    BIT     2, A
    JR      Z, LOC_8A8C
    LD      B, $02

LOC_8A8C:
    LD      (HL), B
    AND     $03
    LD      ($7030), A                  ; RAM $7030
    SCF     
    RET     

DELAY_LOOP_8A94:                           ; DELAY_LOOP_8A94: wait for VBLANK / frame sync (spin on VDP status)
    CALL    SUB_8AB3
    RET     NZ
    LD      B, $1E
    CALL    DELAY_LOOP_8AAA
    CALL    SUB_8B06

LOC_8AA0:
    CALL    SUB_8AB3
    JR      NZ, LOC_8AA0
    CALL    SUB_8B15
    LD      B, $78

DELAY_LOOP_8AAA:
    CALL    SUB_8AD6
    JR      Z, DELAY_LOOP_8AAA
    LD      (HL), A
    DJNZ    DELAY_LOOP_8AAA
    RET     

SUB_8AB3:
    LD      HL, $703E                   ; RAM $703E
    LD      A, ($702F)                  ; RAM $702F
    BIT     0, A
    JR      Z, LOC_8AC0
    LD      HL, $7043                   ; RAM $7043

LOC_8AC0:
    LD      A, (HL)
    CP      $0A
    RET     

SUB_8AC4:
    LD      A, ($703E)                  ; RAM $703E
    CP      $0A
    RET     Z
    CP      $0B
    RET     Z
    LD      A, ($7043)                  ; RAM $7043
    CP      $0A
    RET     Z
    CP      $0B
    RET     

SUB_8AD6:
    LD      A, ($702C)                  ; RAM $702C
    LD      HL, $702E                   ; RAM $702E
    CP      (HL)
    RET     

DELAY_LOOP_8ADE:
    PUSH    BC
    CALL    DELAY_LOOP_8A94
    POP     BC
    CALL    SUB_8AD6
    JR      Z, DELAY_LOOP_8ADE
    LD      (HL), A
    DJNZ    DELAY_LOOP_8ADE
    RET     

DELAY_LOOP_8AEC:
    PUSH    BC

LOC_8AED:
    CALL    DELAY_LOOP_8A94
    CALL    SUB_8AD6
    JR      Z, LOC_8AED
    LD      (HL), A
    CALL    SUB_8D74
    CALL    SUB_9EB0
    CALL    SUB_9EBE
    CALL    DELAY_LOOP_9D52
    POP     BC
    DJNZ    DELAY_LOOP_8AEC
    RET     

SUB_8B06:
    LD      B, $07
    LD      C, $01
    CALL    WRITE_REGISTER
    LD      HL, $73C4                   ; RAM $73C4
    LD      C, (HL)
    RES     6, C
    JR      LOC_8B1B

SUB_8B15:
    LD      HL, $73C4                   ; RAM $73C4
    LD      C, (HL)
    SET     6, C

LOC_8B1B:
    LD      B, $01
    JP      WRITE_REGISTER

SUB_8B20:
    XOR     A
    LD      ($70C0), A                  ; RAM $70C0

SUB_8B24:
    CALL    SUB_8B67
    CALL    SUB_8B56
    LD      HL, $70BC                   ; RAM $70BC
    CALL    SUB_8575
    JR      Z, LOC_8B35
    LD      HL, $70BD                   ; RAM $70BD

LOC_8B35:
    LD      A, (HL)
    LD      DE, $0058

LOC_8B39:
    LD      B, $00

LOC_8B3B:
    LD      C, A
    SUB     $0A
    JP      M, LOC_8B44
    INC     B
    JR      LOC_8B3B

LOC_8B44:
    LD      HL, $7001                   ; RAM $7001
    LD      A, $18
    ADD     A, C
    LD      (HL), A
    DEC     HL
    LD      A, $18
    ADD     A, B
    LD      (HL), A
    LD      BC, $0002
    JP      LOC_852B

SUB_8B56:                                  ; SUB_8B56: write hostage pickup count to HUD display
    LD      HL, $70BE                   ; RAM $70BE
    CALL    SUB_8575
    JR      Z, LOC_8B61
    LD      HL, $70BF                   ; RAM $70BF

LOC_8B61:
    LD      A, (HL)
    LD      DE, $0047
    JR      LOC_8B39

SUB_8B67:                                  ; SUB_8B67: increment HUD pickup counter display
    LD      A, ($70C0)                  ; RAM $70C0
    LD      DE, $004F
    JR      LOC_8B39
    DB      $43, $8C, $C1, $70, $5A, $8C, $CB, $70
    DB      $77, $8C, $D5, $70, $8A, $8C, $C1, $70
    DB      $A1, $8C, $CB, $70, $CA, $8B, $D5, $70
    DB      $0F, $8C, $C1, $70, $1C, $8C, $CB, $70
    DB      $29, $8C, $F3, $70, $2F, $8C, $FD, $70
    DB      $36, $8C, $F3, $70, $3C, $8C, $FD, $70
    DB      $D1, $8B, $25, $71, $DC, $8B, $2F, $71
    DB      $E7, $8B, $39, $71, $EE, $8B, $11, $71
    DB      $F3, $8B, $1B, $71, $F9, $8B, $F3, $70
    DB      $04, $8C, $FD, $70, $BF, $8B, $07, $71
    DB      $02, $84, $0F, $F5, $31, $02, $57, $69
    DB      $10, $FF, $10, $42, $99, $01, $0D, $86
    DB      $11, $50, $C0, $09, $F0, $19, $C1, $09
    DB      $F0, $3C, $11, $02, $D0, $02, $74, $0F
    DB      $F5, $31, $02, $37, $46, $13, $FF, $10
    DB      $E2, $22, $E2, $22, $E2, $22, $10, $80
    DB      $88, $F0, $1E, $90, $02, $07, $1E, $13
    DB      $5F, $10, $81, $00, $F1, $27, $27, $0B
    DB      $80, $C8, $F0, $3C, $90, $02, $07, $53
    DB      $00, $00, $02, $37, $3C, $1C, $4C, $10
    DB      $42, $2F, $32, $0A, $1C, $22, $42, $9F
    DB      $32, $06, $1C, $22, $50, $42, $9F, $32
    DB      $06, $1C, $22, $42, $2F, $32, $0A, $1C
    DB      $22, $50, $C0, $AF, $F0, $04, $E3, $D8
    DB      $02, $33, $04, $00, $00, $23, $18, $C0
    DB      $B1, $F0, $06, $E3, $D8, $02, $33, $06
    DB      $00, $00, $23, $18, $41, $7D, $11, $02
    DB      $88, $48, $40, $2E, $11, $08, $42, $53
    DB      $11, $18, $17, $33, $42, $FE, $10, $18
    DB      $1E, $1A, $50, $82, $5D, $12, $08, $14
    DB      $14, $82, $5D, $12, $08, $14, $14, $80
    DB      $7D, $11, $08, $82, $94, $11, $18, $17
    DB      $33, $82, $FC, $11, $18, $1E, $1A, $90
    DB      $C2, $FA, $12, $18, $17, $33, $C2, $A7
    DB      $12, $18, $17, $33, $C2, $F8, $13, $18
    DB      $1E, $1A, $D0, $42, $AA, $20, $0C, $16
    DB      $16, $40, $BE, $20, $04, $41, $CA, $20
    DB      $02, $44, $F4, $42, $AA, $20, $24, $1D
    DB      $2A, $50, $82, $CA, $20, $0C, $16, $16
    DB      $80, $E2, $20, $04, $81, $FE, $20, $02
    DB      $44, $E4, $82, $CA, $20, $24, $1D, $2A
    DB      $90

SUB_8CB8:                                  ; SUB_8CB8: init entity colour/type table for enemies
    LD      B, $0B
    CALL    SUB_8D0D
    LD      B, $0C
    JR      SUB_8D0D

LOC_8CC1:
    LD      A, $FF
    LD      ($7125), A                  ; RAM $7125
    LD      ($712F), A                  ; RAM $712F
    LD      ($7139), A                  ; RAM $7139
    LD      B, $0D
    CALL    SUB_8D0D
    LD      B, $0E
    CALL    SUB_8D0D
    LD      B, $0F
    JR      SUB_8D0D

SOUND_WRITE_8CDA:
    LD      A, $FF
    LD      ($7125), A                  ; RAM $7125
    LD      ($712F), A                  ; RAM $712F
    LD      ($7139), A                  ; RAM $7139

SOUND_WRITE_8CE5:
    LD      A, $FF
    LD      ($7111), A                  ; RAM $7111
    LD      ($711B), A                  ; RAM $711B
    LD      B, $10
    CALL    SUB_8D0D
    LD      B, $11
    JR      SUB_8D0D

LOC_8CF6:
    LD      B, $06
    JR      SUB_8D0D

SUB_8CFA:
    CALL    SUB_8D3C
    LD      B, $12
    CALL    SUB_8D0D
    LD      B, $13
    JR      SUB_8D0D

SUB_8D06:
    LD      B, $09
    CALL    SUB_8D0D
    LD      B, $0A

SUB_8D0D:
    PUSH    IX
    PUSH    IY
    CALL    PLAY_IT
    POP     IY
    POP     IX
    RET     

SUB_8D19:
    LD      B, $14
    JR      SUB_8D0D

SUB_8D1D:
    LD      B, $07
    JR      SUB_8D0D

SUB_8D21:
    LD      B, $08
    JR      SUB_8D0D

SUB_8D25:
    LD      B, $01
    CALL    SUB_8D0D
    LD      B, $02
    CALL    SUB_8D0D
    LD      B, $03
    JR      SUB_8D0D

SUB_8D33:
    LD      B, $04
    CALL    SUB_8D0D
    LD      B, $05
    JR      SUB_8D0D

SUB_8D3C:                                  ; SUB_8D3C: VDP register init for main game (INIT_TABLE x5, sprite tables)
    LD      B, $0E
    LD      HL, $8B6F
    JP      SOUND_INIT
    DB      $01, $01, $2C, $64, $02, $00, $02, $01
    DB      $01, $04, $04, $17, $96, $01, $00, $04
    DB      $00, $00, $04, $00, $00, $00, $01, $00
    DB      $82, $60, $00, $00, $FF, $FF, $01, $00
    DB      $82, $60, $00, $0F, $92, $60, $04, $0F
    DB      $82, $70, $08, $0F, $92, $70, $0C, $0F

SUB_8D74:
    LD      IX, $715A                   ; RAM $715A
    LD      IY, $703A                   ; RAM $703A
    CALL    SUB_8575
    JR      Z, LOC_8D85
    LD      IY, $703F                   ; RAM $703F

LOC_8D85:
    BIT     2, (IX+0)
    JP      NZ, LOC_97C7
    BIT     0, (IX+4)
    CALL    NZ, SUB_8E2E
    CALL    SUB_8DCA
    CALL    SOUND_WRITE_8E57
    CALL    SUB_8557
    JP      NC, LOC_8DB0
    BIT     2, (IX+4)
    CALL    NZ, SUB_8FA4
    BIT     2, (IX+4)
    CALL    Z, CTRL_READ_8E9D
    CALL    SUB_9286

LOC_8DB0:
    BIT     3, (IX+4)
    CALL    NZ, SUB_91FA
    BIT     3, (IX+4)
    CALL    Z, SUB_918F
    CALL    SUB_92D5
    CALL    SUB_93E7
    CALL    SUB_947D
    JP      LOC_9525

SUB_8DCA:
    DEC     (IX+8)
    RET     NZ
    LD      (IX+8), $01
    BIT     6, (IY+0)
    JR      NZ, LOC_8DDD
    SET     5, (IX+0)
    RET     

LOC_8DDD:
    BIT     5, (IX+0)
    RET     Z
    LD      A, (IX+4)
    BIT     0, A
    RET     NZ
    BIT     1, A
    RET     NZ
    LD      A, (IX+5)
    BIT     1, A
    JR      NZ, LOC_8E04
    RES     5, (IX+0)
    SET     0, (IX+4)
    LD      (IX+8), $05
    LD      A, (IX+9)
    INC     A
    JR      LOC_8E40

LOC_8E04:
    BIT     0, A
    LD      A, (IX+10)
    JR      Z, LOC_8E21
    LD      B, $06
    CP      $04
    JR      Z, LOC_8E16
    LD      B, $04
    CP      $02
    RET     NZ

LOC_8E16:
    LD      A, B
    RES     5, (IX+0)
    SET     0, (IX+4)
    JR      LOC_8E3C

LOC_8E21:
    LD      B, $00
    CP      $02
    JR      Z, LOC_8E16
    LD      B, $02
    CP      $00
    RET     NZ
    JR      LOC_8E16

SUB_8E2E:
    DEC     (IX+8)
    RET     NZ
    BIT     0, (IX+10)
    JR      Z, LOC_8E4E
    LD      A, (IX+9)
    INC     A

LOC_8E3C:
    LD      (IX+8), $01

LOC_8E40:
    AND     $07
    LD      (IX+9), A
    LD      HL, $961F
    RST     $18
    LD      A, (HL)
    LD      (IX+10), A
    RET     

LOC_8E4E:
    LD      (IX+8), $0C
    RES     0, (IX+4)
    RET     

SOUND_WRITE_8E57:
    LD      HL, ($7354)                 ; RAM $7354
    INC     HL
    LD      A, (HL)
    CP      $FF
    JR      NZ, LOC_8E63
    LD      HL, $7356                   ; RAM $7356

LOC_8E63:
    LD      A, $03
    AND     (IX+4)
    LD      B, A
    LD      A, ($702F)                  ; RAM $702F
    BIT     3, A
    JR      NZ, LOC_8E8E
    LD      A, (IY+1)
    LD      (WORK_BUFFER), A            ; WORK_BUFFER
    BIT     1, B
    JR      NZ, LOC_8E84
    BIT     3, A
    CALL    NZ, SUB_8E92
    BIT     1, A
    CALL    NZ, SUB_8E92

LOC_8E84:
    BIT     2, A
    CALL    NZ, SUB_8E9A
    BIT     0, A
    CALL    NZ, SUB_8E9A

LOC_8E8E:
    LD      (IX+4), B
    RET     

SUB_8E92:
    LD      ($7354), HL                 ; RAM $7354
    LD      (HL), $01
    SET     2, B
    RET     

SUB_8E9A:
    SET     3, B
    RET     

CTRL_READ_8E9D:
    LD      A, (IX+21)
    AND     A
    JP      Z, LOC_8F38
    LD      A, (IX+20)
    RES     7, A
    CP      $00
    JP      Z, LOC_8F38
    CP      $08
    JR      NC, LOC_8F04
    LD      (IX+31), $1F
    LD      (IX+22), $01
    LD      (IX+23), $04
    LD      A, (IX+5)
    CP      $03
    JR      Z, LOC_8EE2
    LD      A, $28
    CP      (IX+25)
    JR      NC, LOC_8ED9
    LD      (IX+20), $08
    LD      (IX+27), $FC
    LD      HL, $FFFC
    JR      LOC_8F01

LOC_8ED9:
    LD      (IX+20), $0A
    LD      HL, $FFFC
    JR      LOC_8EFD

LOC_8EE2:
    LD      A, (IX+25)
    CP      $A8
    JR      NC, LOC_8EF6
    LD      (IX+20), $09
    LD      (IX+27), $04
    LD      HL, $0004
    JR      LOC_8F01

LOC_8EF6:
    LD      (IX+20), $0B
    LD      HL, $0004

LOC_8EFD:
    LD      (IX+27), $00

LOC_8F01:
    LD      ($7046), HL                 ; RAM $7046

LOC_8F04:
    LD      A, (IX+20)
    CP      $0A
    JR      Z, LOC_8F66
    CP      $0B
    JR      Z, LOC_8F22
    CP      $08
    JR      Z, LOC_8F57
    LD      A, (IX+25)
    CP      $A8
    JR      C, LOC_8F22
    LD      (IX+20), $0B
    LD      (IX+27), $00

LOC_8F22:
    LD      HL, ($7044)                 ; RAM $7044
    LD      DE, $10F0
    RST     $20
    JR      C, LOC_8F7C
    LD      HL, BOOT_UP
    LD      ($7046), HL                 ; RAM $7046
    LD      A, (IX+25)
    CP      $A8
    JR      C, LOC_8F7C

LOC_8F38:
    CALL    SUB_94B9
    LD      (IX+21), $00
    LD      (IX+20), $00
    LD      (IX+27), $00
    LD      HL, BOOT_UP
    LD      ($7046), HL                 ; RAM $7046
    BIT     1, (IX+4)
    RET     NZ
    LD      (IX+5), $00
    RET     

LOC_8F57:
    LD      A, $28
    CP      (IX+25)
    JR      C, LOC_8F66
    LD      (IX+20), $0A
    LD      (IX+27), $00

LOC_8F66:
    LD      HL, ($7044)                 ; RAM $7044
    LD      DE, $07AA
    RST     $20
    JR      NC, LOC_8F7C
    LD      HL, BOOT_UP
    LD      ($7046), HL                 ; RAM $7046
    LD      A, $28
    CP      (IX+25)
    JR      NC, LOC_8F38

LOC_8F7C:
    DEC     (IX+22)
    RET     NZ
    LD      A, (IX+21)
    SRL     A
    JR      NZ, LOC_8F88
    INC     A

LOC_8F88:
    LD      (IX+22), A
    LD      A, (IX+23)
    DEC     A
    JR      Z, LOC_8F38
    LD      (IX+23), A
    CP      $03
    JR      NC, LOC_8F9C
    LD      (IX+5), $00

LOC_8F9C:
    LD      HL, $960D
    RST     $18
    LD      A, (HL)
    JP      SUB_94BB

; ---- PLAYER INPUT HANDLER ----
; SUB_8FA4 -- read joystick + fire button, update helicopter position and fire.
; Player X at $70BC/$70BD (16-bit), Y at $70BE. Facing in $702F bit 0.
SUB_8FA4:                                  ; SUB_8FA4: read joystick + fire, update helicopter position and fire
    LD      A, (WORK_BUFFER)               ; A = (WORK_BUFFER): game-state flags
    BIT     1, A                           ; BIT 1, A: test fire/input-active flag
    JP      NZ, LOC_90A5                   ; JP NZ: if set, skip to special state
    LD      (IX+5), $02                    ; (IX+5) = $02: set sprite mode
    LD      A, (IX+10)                     ; A = (IX+10): helicopter state
    CP      $03                            ; CP $03: hovering state?
    JR      NC, LOC_9008                   ; JR NC: if >= 3, check fire sequence
    LD      A, (IX+20)                     ; A = (IX+20): joystick input byte
    BIT     7, A                           ; BIT 7, A: test input-ready flag
    JP      Z, LOC_905B                    ; JP Z: if not ready, skip to move
    RES     7, A                           ; RES 7, A: clear input-ready flag
    CP      $08                            ; CP $08
    JP      NC, LOC_905B                   ; JP NC: if >= 8, invalid input range
    CP      $00                            ; CP $00
    JP      Z, LOC_905E                    ; JP Z: no direction pressed
    CALL    DELAY_LOOP_94E5                ; DELAY_LOOP_94E5: read and decode direction input
    CP      $05                            ; CP $05: fire left?
    JP      Z, LOC_9061                    ; JP Z: trigger fire left
    CP      $07                            ; CP $07: fire right?
    JP      Z, LOC_9061                    ; JP Z: trigger fire right
    CP      $01                            ; CP $01: up?
    JP      Z, LOC_9086                    ; JP Z: move up
    CP      $02                            ; CP $02: down?
    JP      Z, LOC_9090                    ; JP Z: move down
    CP      $04                            ; CP $04: left?
    JP      Z, LOC_90A2                    ; JP Z: move left

LOC_8FE7:
    LD      HL, ($7044)                 ; RAM $7044
    LD      DE, $07AA
    RST     $20
    RET     NC
    LD      (IX+20), $84

LOC_8FF3:
    LD      B, $FC
    LD      A, $10
    CP      (IX+25)

LOC_8FFA:
    JR      C, LOC_8FFE
    LD      B, $00

LOC_8FFE:
    LD      (IX+27), B
    LD      HL, BOOT_UP
    LD      ($7046), HL                 ; RAM $7046
    RET     

LOC_9008:
    LD      A, (IX+20)
    BIT     7, A
    JR      Z, LOC_9034
    RES     7, A
    CP      $08
    JR      NC, LOC_9034
    CP      $00
    JR      Z, LOC_9037
    CALL    DELAY_LOOP_94E5
    CP      $01
    JR      Z, LOC_903A
    CP      $02
    JR      Z, LOC_903A
    CP      $03
    JR      Z, LOC_903A
    CP      $05
    JR      Z, LOC_9051
    CP      $04
    JP      Z, LOC_90A2
    JP      LOC_8FE7

LOC_9034:
    CALL    SUB_94B9

LOC_9037:
    CALL    SOUND_WRITE_94C0

LOC_903A:
    LD      A, $28
    CP      (IX+25)
    JR      NC, LOC_904B
    LD      (IX+20), $85
    LD      (IX+27), $FC
    JR      LOC_9070

LOC_904B:
    LD      (IX+20), $87
    JR      LOC_909C

LOC_9051:
    LD      A, $28
    CP      (IX+25)
    JR      NC, LOC_904B
    JP      LOC_8FE7

LOC_905B:
    CALL    SUB_94B9

LOC_905E:
    CALL    SOUND_WRITE_94C0

LOC_9061:
    LD      A, $78
    CP      (IX+25)
    JR      NC, LOC_9079
    LD      (IX+20), $81
    LD      (IX+27), $FC

LOC_9070:
    LD      HL, BOOT_UP

LOC_9073:
    LD      ($7046), HL                 ; RAM $7046
    JP      LOC_8FE7

LOC_9079:
    LD      (IX+20), $82
    LD      (IX+27), $04

LOC_9081:
    LD      HL, $FFFC
    JR      LOC_9073

LOC_9086:
    LD      A, $78
    CP      (IX+25)
    JP      C, LOC_8FE7
    JR      LOC_9079

LOC_9090:
    LD      A, (IX+25)
    CP      $A8
    JP      C, LOC_8FE7
    LD      (IX+20), $83

LOC_909C:
    LD      (IX+27), $00
    JR      LOC_9081

LOC_90A2:
    JP      LOC_8FF3

LOC_90A5:
    LD      (IX+5), $03
    LD      A, (IX+10)
    CP      $02
    JR      C, LOC_90F4
    LD      A, (IX+20)
    BIT     7, A
    JP      NZ, LOC_9145
    CP      $08
    JP      NC, LOC_9145
    CP      $00
    JP      Z, LOC_9148
    CALL    DELAY_LOOP_94E5
    CP      $05
    JP      Z, LOC_914B
    CP      $07
    JP      Z, LOC_914B
    CP      $01
    JP      Z, LOC_9170
    CP      $02
    JP      Z, LOC_917A
    CP      $04
    JP      Z, LOC_918C

LOC_90DE:
    LD      HL, ($7044)                 ; RAM $7044
    LD      DE, $10F0
    RST     $20
    RET     C
    LD      (IX+20), $04

LOC_90EA:
    LD      B, $04
    LD      A, (IX+25)
    CP      $B0
    JP      LOC_8FFA

LOC_90F4:
    LD      A, (IX+20)
    BIT     7, A
    JR      NZ, LOC_911E
    CP      $08
    JR      NC, LOC_911E
    CP      $00
    JR      Z, LOC_9121
    CALL    DELAY_LOOP_94E5
    CP      $01
    JR      LOC_9124
    DB      $FE, $02, $18, $16, $FE, $03, $18, $12
    DB      $FE, $05, $28, $25, $FE, $04, $CA, $8C
    DB      $91, $C3, $DE, $90

LOC_911E:
    CALL    SUB_94B9

LOC_9121:
    CALL    SOUND_WRITE_94C0

LOC_9124:
    LD      A, (IX+25)
    CP      $B0
    JR      NC, LOC_9135
    LD      (IX+20), $05
    LD      (IX+27), $04
    JR      LOC_915A

LOC_9135:
    LD      (IX+20), $07
    JR      LOC_9186
    DB      $DD, $7E, $19, $FE, $B0, $30, $F3, $C3
    DB      $DE, $90

LOC_9145:
    CALL    SUB_94B9

LOC_9148:
    CALL    SOUND_WRITE_94C0

LOC_914B:
    LD      A, (IX+25)
    CP      $58
    JR      NC, LOC_9163
    LD      (IX+20), $01
    LD      (IX+27), $04

LOC_915A:
    LD      HL, BOOT_UP

LOC_915D:
    LD      ($7046), HL                 ; RAM $7046
    JP      LOC_90DE

LOC_9163:
    LD      (IX+20), $02
    LD      (IX+27), $FC

LOC_916B:
    LD      HL, $0004
    JR      LOC_915D

LOC_9170:
    LD      A, (IX+25)
    CP      $58
    JR      NC, LOC_9163
    JP      LOC_90DE

LOC_917A:
    LD      A, $38
    CP      (IX+25)
    JP      C, LOC_90DE
    LD      (IX+20), $03

LOC_9186:
    LD      (IX+27), $00
    JR      LOC_916B

LOC_918C:
    JP      LOC_90EA

SUB_918F:
    LD      A, (IX+17)
    AND     A
    JP      Z, LOC_91DC
    LD      A, (IX+16)
    CP      $00
    JR      Z, LOC_91DC
    CP      $08
    JR      NC, LOC_91B4
    LD      (IX+18), $01
    LD      (IX+19), $03
    LD      B, $09
    CP      $02
    JR      Z, LOC_91B1
    LD      B, $08

LOC_91B1:
    LD      (IX+16), B

LOC_91B4:
    DEC     (IX+18)
    RET     NZ
    LD      A, (IX+19)
    DEC     A
    JR      Z, LOC_91DC
    LD      (IX+19), A
    LD      HL, $9611
    RST     $10
    LD      A, (HL)
    ADD     A, (IX+17)
    LD      (IX+18), A
    INC     HL
    LD      B, (HL)
    LD      A, (IX+16)
    CP      $09
    LD      A, B
    JR      Z, LOC_91D8
    NEG     

LOC_91D8:
    LD      (IX+26), A
    RET     

LOC_91DC:
    LD      (IX+17), $00
    LD      (IX+16), $00
    LD      (IX+26), $00
    BIT     1, (IX+4)
    RET     Z
    DEC     (IX+30)
    RET     NZ
    LD      (IX+5), $00
    LD      (IX+30), $01
    RET     

SUB_91FA:
    LD      A, (WORK_BUFFER)            ; WORK_BUFFER
    BIT     2, A
    JR      NZ, LOC_9248
    LD      A, (IX+16)
    CP      $08
    JR      NC, LOC_9213
    CP      $00
    JR      Z, LOC_9213
    CP      $02
    JR      Z, LOC_9213
    JP      LOC_950C

LOC_9213:
    BIT     1, (IX+4)
    JR      Z, LOC_922D
    CALL    SUB_9238
    RET     NZ
    CALL    SUB_8D06
    RES     1, (IX+4)
    LD      (IX+5), $00
    LD      HL, $72DC                   ; RAM $72DC
    RES     2, (HL)

LOC_922D:
    LD      (IX+16), $01
    LD      (IX+26), $FE
    JP      LOC_94DC

SUB_9238:
    LD      HL, $A470

LOC_923B:
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    INC     HL
    LD      A, E
    OR      D
    RET     Z
    LD      A, (DE)
    BIT     6, A
    RET     NZ
    JR      LOC_923B

LOC_9248:
    LD      A, (IX+16)
    CP      $08
    JR      NC, LOC_925A
    CP      $00
    JR      Z, LOC_925A
    CP      $01
    JR      Z, LOC_925A
    JP      LOC_950C

LOC_925A:
    BIT     1, (IX+4)
    JR      NZ, LOC_926B
    LD      (IX+16), $02
    LD      (IX+26), $02
    JP      LOC_94DC

LOC_926B:
    DEC     (IX+30)
    RET     NZ

SUB_926F:
    LD      (IX+30), $07
    LD      A, (IX+5)
    CP      $01
    LD      A, $01
    JR      NZ, LOC_9282
    LD      A, $00
    LD      (IX+30), $07

LOC_9282:
    LD      (IX+5), A
    RET     

SUB_9286:
    LD      HL, ($7046)                 ; RAM $7046
    DB      $EB
    LD      HL, ($7044)                 ; RAM $7044
    ADD     HL, DE
    LD      ($7044), HL                 ; RAM $7044
    PUSH    HL
    LD      DE, $07A8
    RST     $20
    POP     HL
    JR      C, LOC_929F
    LD      DE, $10F0
    RST     $20
    JR      C, LOC_92A3

LOC_929F:
    DB      $EB
    LD      ($7044), HL                 ; RAM $7044

LOC_92A3:
    LD      A, (IX+27)
    AND     A
    RET     Z
    LD      C, A
    LD      E, (IX+25)
    CALL    SUB_9AC5
    JR      Z, LOC_92B3
    JR      NC, LOC_92B7

LOC_92B3:
    LD      C, $00
    JR      LOC_92BE

LOC_92B7:
    CP      $F0
    JR      NC, LOC_92B3
    LD      (IX+25), A

LOC_92BE:
    LD      HL, $7049                   ; RAM $7049

LOC_92C1:
    LD      B, $04
    BIT     2, (IX+0)
    JR      Z, LOC_92CB
    LD      B, $02

LOC_92CB:
    LD      A, (HL)
    ADD     A, C
    LD      (HL), A
    INC     HL
    INC     HL
    INC     HL
    INC     HL
    DJNZ    LOC_92CB
    RET     

SUB_92D5:
    LD      A, (IX+26)
    BIT     2, (IX+0)
    JR      NZ, LOC_92E8
    DEC     (IX+6)
    JR      NZ, LOC_92E8
    LD      (IX+6), $02
    INC     A

LOC_92E8:
    LD      C, A
    ADD     A, (IX+24)
    CP      $19
    JP      C, LOC_91DC
    BIT     2, (IX+0)
    JR      NZ, LOC_92FB
    CP      $83
    JR      NC, LOC_9303

LOC_92FB:
    LD      (IX+24), A
    LD      HL, $7048                   ; RAM $7048
    JR      LOC_92C1

LOC_9303:
    LD      A, (IX+17)
    CP      $04
    JR      NC, LOC_9312
    LD      A, (IX+31)
    CP      $20
    JP      C, LOC_931C

LOC_9312:
    CALL    SUB_968D
    CALL    LOC_94AC
    POP     AF
    JP      LOC_97C7

LOC_931C:
    BIT     1, (IX+4)
    RET     NZ
    LD      HL, ($7044)                 ; RAM $7044
    DEC     H
    LD      A, ($7173)                  ; RAM $7173
    RST     $18
    LD      DE, $103E
    RST     $20
    JR      C, LOC_933C
    LD      DE, $0028
    RST     $20
    JR      NC, LOC_933C
    LD      HL, $72DC                   ; RAM $72DC
    SET     0, (HL)
    SET     2, (HL)

LOC_933C:
    CALL    SUB_926F
    CALL    SUB_8CB8
    SET     1, (IX+4)
    CALL    LOC_8F38
    CALL    LOC_91DC
    PUSH    IY
    LD      B, $08
    LD      IY, $724E                   ; RAM $724E

LOC_9354:
    PUSH    BC
    PUSH    IY
    BIT     0, (IY+0)
    JR      Z, LOC_937A
    LD      HL, $000D
    LD      BC, $0014
    LD      A, (IX+10)
    CP      $02
    JR      Z, LOC_9377
    LD      HL, $0011
    LD      BC, $0011
    CP      $00
    JR      Z, LOC_9377
    LD      BC, $0018

LOC_9377:
    CALL    SUB_93D7

LOC_937A:
    POP     IY
    LD      DE, $0011
    ADD     IY, DE
    POP     BC
    DJNZ    LOC_9354
    LD      HL, $7152                   ; RAM $7152
    CALL    SUB_8575
    JR      Z, LOC_938F
    LD      HL, $7156                   ; RAM $7156

LOC_938F:
    LD      B, $04

LOC_9391:
    LD      A, (HL)
    CP      $FF
    JR      Z, LOC_93CD
    PUSH    HL
    PUSH    BC
    LD      HL, $A45E
    RST     $10
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    PUSH    DE
    POP     IY
    LD      L, (IY+1)
    LD      H, (IY+2)
    LD      A, (IY+7)
    ADD     A, $04
    LD      C, A
    LD      B, $00
    ADD     HL, BC
    DB      $EB
    LD      HL, ($7044)                 ; RAM $7044
    DEC     H
    LD      BC, $0010
    ADD     HL, BC
    LD      A, ($7173)                  ; RAM $7173
    LD      C, A
    ADD     HL, BC
    RST     $20
    JR      C, LOC_93C8
    LD      DE, $0020
    RST     $20
    JR      C, LOC_93D0

LOC_93C8:
    POP     BC
    POP     HL
    INC     HL
    DJNZ    LOC_9391

LOC_93CD:
    POP     IY
    RET     

LOC_93D0:
    POP     BC
    POP     HL
    POP     IY
    JP      LOC_9312

SUB_93D7:
    LD      A, (IY+7)
    LD      E, (IY+1)
    LD      D, (IY+2)
    CALL    SUB_A899
    CALL    NZ, SUB_A752
    RET     

SUB_93E7:
    LD      A, (IX+5)
    LD      B, A
    ADD     A, A
    ADD     A, A
    ADD     A, B
    ADD     A, (IX+10)
    BIT     3, (IX+0)
    JR      NZ, LOC_9411
    CP      (IX+28)
    RET     Z
    CP      (IX+29)
    SET     3, (IX+0)
    LD      HL, $961B
    LD      (IX+11), L
    LD      (IX+12), H
    RET     Z
    LD      (IX+29), A
    JR      LOC_9429

LOC_9411:
    CP      (IX+29)
    RET     Z
    CP      (IX+28)
    RES     3, (IX+0)
    LD      HL, $9617
    LD      (IX+11), L
    LD      (IX+12), H
    RET     Z
    LD      (IX+28), A

LOC_9429:
    LD      HL, $9627
    RST     $10
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    DB      $EB
    LD      A, (HL)
    INC     HL
    AND     A
    JR      NZ, LOC_9459
    LD      B, $03
    LD      C, $00

LOC_943A:
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    INC     HL
    PUSH    HL
    DB      $EB
    LD      A, C
    BIT     3, (IX+0)
    JR      Z, LOC_9449
    ADD     A, $30

LOC_9449:
    LD      E, A
    LD      D, $00
    PUSH    BC
    CALL    SUB_84F7
    POP     BC
    POP     HL
    LD      A, $10
    ADD     A, C
    LD      C, A
    DJNZ    LOC_943A
    RET     

LOC_9459:
    INC     HL
    LD      B, $03
    LD      C, $00

LOC_945E:
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    INC     HL
    PUSH    HL
    DB      $EB
    LD      A, C
    BIT     3, (IX+0)
    JR      Z, LOC_946D
    ADD     A, $30

LOC_946D:
    LD      E, A
    LD      D, $00
    PUSH    BC
    CALL    SUB_8507
    POP     BC
    POP     HL
    LD      A, $10
    ADD     A, C
    LD      C, A
    DJNZ    LOC_945E
    RET     

SUB_947D:
    LD      A, $03
    DEC     (IX+13)
    JP      NZ, LOC_94AC
    LD      (IX+13), A
    LD      A, (IX+14)
    INC     A
    CP      (IX+15)
    JR      C, LOC_9492
    XOR     A

LOC_9492:
    LD      (IX+14), A
    LD      L, (IX+11)
    LD      H, (IX+12)
    RST     $18
    LD      A, (HL)
    LD      HL, $704A                   ; RAM $704A
    LD      B, $04
    LD      C, $04

LOC_94A4:
    LD      (HL), A
    ADD     A, C
    INC     HL
    INC     HL
    INC     HL
    INC     HL
    DJNZ    LOC_94A4

LOC_94AC:
    LD      HL, $7048                   ; RAM $7048
    LD      E, $00
    LD      D, $00
    LD      BC, $0004
    JP      LOC_8527

SUB_94B9:
    LD      A, $24

SUB_94BB:
    LD      HL, $715C                   ; RAM $715C
    LD      (HL), A
    RET     

SOUND_WRITE_94C0:                          ; SOUND_WRITE_94C0: init/clear all sound channel buffers
    LD      (IX+21), $00
    LD      (IX+31), $00
    LD      (IX+22), $04
    LD      HL, $7356                   ; RAM $7356
    LD      ($7354), HL                 ; RAM $7354
    LD      B, $07

LOC_94D4:
    LD      (HL), $00
    INC     HL
    DJNZ    LOC_94D4
    LD      (HL), $FF
    RET     

LOC_94DC:
    LD      (IX+17), $00
    LD      (IX+18), $04
    RET     

DELAY_LOOP_94E5:                           ; DELAY_LOOP_94E5: read and decode joystick direction -> A
    PUSH    AF
    LD      HL, $7356                   ; RAM $7356
    XOR     A
    LD      B, $07

LOC_94EC:
    ADD     A, (HL)
    INC     HL
    DJNZ    LOC_94EC
    LD      (IX+21), A
    CP      $07
    JR      C, LOC_94FB
    LD      HL, $7179                   ; RAM $7179
    INC     (HL)

LOC_94FB:
    LD      HL, $9505
    RST     $18
    LD      A, (HL)
    CALL    SUB_94BB
    POP     AF
    RET     
    DB      $00, $24, $28, $2C, $30, $34, $38

LOC_950C:
    PUSH    AF
    DEC     (IX+18)
    JR      NZ, LOC_9523
    LD      (IX+18), $04
    LD      A, (IX+17)
    INC     A
    CP      $04
    JR      C, LOC_9520
    LD      A, $04

LOC_9520:
    LD      (IX+17), A

LOC_9523:
    POP     AF
    RET     

LOC_9525:
    BIT     1, (IX+4)
    RET     NZ
    DEC     (IX+7)
    JR      Z, LOC_9547
    BIT     4, (IX+0)
    JR      NZ, LOC_953F
    BIT     6, (IY+3)
    RET     NZ
    SET     4, (IX+0)
    RET     

LOC_953F:
    LD      A, (IX+7)
    LD      HL, $7335                   ; RAM $7335
    CP      (HL)
    RET     NC

LOC_9547:
    LD      (IX+7), $01
    BIT     6, (IY+3)
    JR      NZ, LOC_9556
    SET     4, (IX+0)
    RET     

LOC_9556:
    LD      A, ($7336)                  ; RAM $7336
    CP      $04
    RET     NC
    LD      A, (IX+24)
    CP      $90
    RET     NC
    RES     4, (IX+0)
    LD      (IX+7), $19
    LD      A, $0D
    LD      ($7335), A                  ; RAM $7335
    LD      B, $00
    LD      A, (IX+10)
    AND     A
    JR      Z, LOC_957F
    LD      B, $02
    CP      $04
    JR      Z, LOC_957F
    LD      B, $01

LOC_957F:
    LD      A, (IX+5)
    AND     A
    JR      Z, LOC_9586
    DEC     A

LOC_9586:
    LD      C, A
    ADD     A, A
    ADD     A, C
    ADD     A, B
    LD      E, A
    ADD     A, A
    ADD     A, E
    LD      HL, $95F2
    RST     $18
    LD      C, (HL)
    INC     HL
    LD      D, (HL)
    INC     HL
    LD      E, (HL)
    LD      A, C
    CP      $0D
    JR      Z, LOC_959F
    CP      $0C
    JR      NZ, LOC_95A8

LOC_959F:
    LD      A, $19
    LD      ($7335), A                  ; RAM $7335
    LD      (IX+7), $32

LOC_95A8:
    LD      A, (IX+25)
    ADD     A, E
    LD      E, A
    LD      A, (IX+24)
    ADD     A, D
    LD      D, A
    LD      H, $00
    LD      B, A
    LD      A, C
    CP      $07
    JR      Z, LOC_95EF
    CP      $06
    JR      Z, LOC_95EF
    LD      A, B
    LD      H, $09
    CP      $40
    JR      C, LOC_95EF
    LD      H, $08
    CP      $54
    JR      C, LOC_95EF
    DEC     H
    CP      $60
    JR      C, LOC_95EF
    DEC     H
    CP      $6C
    JR      C, LOC_95EF
    DEC     H
    CP      $78
    JR      C, LOC_95EF
    DEC     H
    CP      $80
    JR      C, LOC_95EF
    DEC     H
    CP      $88
    JR      C, LOC_95EF
    DEC     H
    CP      $90
    JR      C, LOC_95EF
    DEC     H
    CP      $98
    JR      C, LOC_95EF
    DEC     H

LOC_95EF:
    JP      LOC_98A4
    DB      $0C, $17, $01, $05, $18, $0F, $0D, $17
    DB      $1D, $07, $1C, $04, $08, $1A, $10, $0A
    DB      $11, $1D, $0B, $11, $01, $09, $1A, $0E
    DB      $06, $1C, $1A, $10, $20, $30, $40, $01
    DB      $02, $01, $01, $01, $01, $00, $10, $20
    DB      $10, $30, $40, $50, $40, $00, $01, $02
    DB      $03, $04, $03, $02, $01, $66, $96, $6E
    DB      $96, $5E, $96, $6D, $96, $65, $96, $57
    DB      $96, $4F, $96, $4F, $96, $4F, $96, $56
    DB      $96, $76, $96, $7E, $96, $7E, $96, $7E
    DB      $96, $85, $96, $86, $96, $7D, $96, $7D
    DB      $96, $7D, $96, $75, $96, $00, $F2, $B8
    DB      $25, $B9, $52, $B9, $01, $00, $88, $B5
    DB      $D5, $B5, $1E, $B6, $00, $F2, $B8, $25
    DB      $B9, $52, $B9, $01, $00, $88, $B5, $D5
    DB      $B5, $1E, $B6, $01, $00, $67, $B6, $A4
    DB      $B6, $DD, $B6, $01, $00, $16, $B7, $71
    DB      $B7, $C3, $B7, $01, $00, $7E, $B9, $C4
    DB      $B9, $FC, $B9, $01, $00, $11, $B8, $64
    DB      $B8, $AE, $B8

SUB_968D:
    CALL    SUB_8CFA
    LD      HL, $70BE                   ; RAM $70BE
    CALL    SUB_8575
    JR      Z, LOC_969B
    LD      HL, $70BF                   ; RAM $70BF

LOC_969B:
    LD      A, ($70C0)                  ; RAM $70C0
    ADD     A, (HL)
    LD      (HL), A
    XOR     A
    LD      ($70C0), A                  ; RAM $70C0
    CALL    SUB_8B24
    SET     2, (IX+0)
    LD      A, (IX+24)
    CP      $83
    JP      C, LOC_9793
    ADD     A, $10
    LD      (IX+24), A
    CALL    SUB_977F
    ADD     A, $10
    ADD     HL, DE
    LD      (HL), A
    CALL    SUB_9776

VDP_DATA_96C2:
    LD      (IX+26), $00
    LD      (IX+27), $00
    LD      HL, BOOT_UP
    LD      ($7046), HL                 ; RAM $7046
    LD      (IX+5), $04
    LD      (IX+15), $07
    LD      (IX+8), $62
    LD      HL, $9873
    CALL    SOUND_WRITE_9767
    LD      DE, BOOT_UP
    LD      HL, $BD68
    CALL    SUB_84F7
    LD      DE, $0008
    LD      HL, $BDA2
    CALL    SUB_84F7
    LD      DE, $0010
    LD      HL, $BDE2
    CALL    SUB_84F7
    LD      DE, $0018
    LD      HL, $BE27
    CALL    SUB_84F7
    LD      DE, $0020
    LD      HL, $BE69
    CALL    SUB_84F7
    LD      DE, $0028
    LD      HL, $BEAE
    CALL    SUB_84F7
    LD      DE, $0030
    LD      HL, $BEF0
    CALL    SUB_84F7
    LD      DE, $0038
    LD      HL, $BF35
    CALL    SUB_84F7
    LD      DE, $0040
    LD      HL, $BF7A
    CALL    SUB_84F7
    LD      DE, $0048
    LD      HL, $BFBF
    CALL    SUB_84F7
    PUSH    IX
    PUSH    IY
    LD      B, $08
    LD      IY, $724E                   ; RAM $724E

LOC_9746:
    PUSH    BC
    PUSH    IY
    BIT     0, (IY+0)
    JR      Z, LOC_9758
    LD      HL, $0020
    LD      BC, $0020
    CALL    SUB_93D7

LOC_9758:
    POP     IY
    LD      BC, $0011
    ADD     IY, BC
    POP     BC
    DJNZ    LOC_9746
    POP     IY
    POP     IX
    RET     

SOUND_WRITE_9767:
    LD      (IX+14), $FF
    LD      (IX+13), $01
    LD      (IX+11), L
    LD      (IX+12), H
    RET     

SUB_9776:
    LD      HL, $704A                   ; RAM $704A
    LD      (HL), $00
    ADD     HL, DE
    LD      (HL), $04
    RET     

SUB_977F:
    LD      DE, $0004
    LD      HL, $7048                   ; RAM $7048
    LD      (HL), A
    ADD     HL, DE
    LD      (HL), A
    ADD     HL, DE
    LD      (HL), $E0
    ADD     HL, DE
    LD      (HL), $E0
    LD      HL, $7049                   ; RAM $7049
    LD      A, (HL)
    RET     

LOC_9793:
    ADD     A, $10
    LD      (IX+24), A
    LD      (IX+26), $02
    CALL    SUB_977F
    ADD     A, $08
    LD      (IX+25), A
    LD      (HL), A
    ADD     HL, DE
    LD      (HL), A
    LD      (IX+27), $01
    LD      A, ($7332)                  ; RAM $7332
    BIT     7, A
    JR      Z, LOC_97B6
    LD      (IX+27), $FF

LOC_97B6:
    CALL    SUB_9776
    LD      (IX+5), $05
    LD      (IX+15), $04
    LD      HL, $9894
    JP      SOUND_WRITE_9767

LOC_97C7:
    LD      A, (IX+5)
    CP      $04
    JR      Z, LOC_9806
    CALL    SUB_9286
    CALL    SUB_92D5
    LD      A, (IX+24)
    CP      $92
    JR      C, LOC_980B
    LD      HL, $7049                   ; RAM $7049
    LD      A, (HL)
    SUB     $08
    JR      NC, LOC_97F8
    ADD     A, $1A
    LD      (IX+25), A
    LD      (HL), A
    INC     HL
    INC     HL
    SET     7, (HL)
    INC     HL
    INC     HL
    ADD     A, $10
    LD      (HL), A
    INC     HL
    INC     HL
    SET     7, (HL)
    JR      LOC_9803

LOC_97F8:
    LD      (IX+25), A
    LD      (HL), A
    LD      DE, $0004
    ADD     HL, DE
    ADD     A, $10
    LD      (HL), A

LOC_9803:
    CALL    VDP_DATA_96C2

LOC_9806:
    DEC     (IX+8)
    JR      Z, LOC_9859

LOC_980B:
    DEC     (IX+13)
    RET     NZ
    LD      A, (IX+5)
    CP      $04
    LD      A, $07
    JR      Z, LOC_981A
    LD      A, $03

LOC_981A:
    LD      (IX+13), A
    LD      A, (IX+14)
    INC     A
    CP      (IX+15)
    JR      C, LOC_9836
    LD      C, A
    LD      A, (IX+5)
    CP      $05
    JR      Z, LOC_9834
    LD      A, C
    CP      $0B
    JP      NC, LOC_9867

LOC_9834:
    LD      A, $01

LOC_9836:
    LD      (IX+14), A
    LD      B, A
    ADD     A, A
    ADD     A, B
    LD      L, (IX+11)
    LD      H, (IX+12)
    RST     $18
    LD      A, (HL)
    INC     HL
    LD      B, (HL)
    INC     HL
    LD      C, (HL)
    LD      HL, $704A                   ; RAM $704A
    LD      (HL), A
    INC     HL
    LD      (HL), B
    INC     HL
    INC     HL
    INC     HL
    ADD     A, $04
    LD      (HL), A
    INC     HL
    LD      (HL), C
    JP      LOC_94AC

LOC_9859:
    LD      (IX+8), $FF
    LD      (IX+14), $06
    LD      (IX+15), $0B
    JR      LOC_980B

LOC_9867:
    CALL    SUB_A9A0
    POP     AF
    LD      B, $1E
    CALL    DELAY_LOOP_8ADE
    JP      LOC_8261
    DB      $00, $0F, $0F, $08, $0A, $0A, $10, $06
    DB      $06, $18, $0A, $0A, $20, $06, $06, $28
    DB      $0A, $0A, $30, $06, $06, $38, $0A, $0A
    DB      $40, $06, $06, $48, $0A, $0A, $48, $00
    DB      $00, $C8, $0F, $00, $B0, $0A, $06, $B8
    DB      $0A, $06, $C0, $0A, $06, $E0, $80, $84
    DB      $0F

LOC_98A4:
    LD      A, C
    CP      $05
    JR      NC, LOC_98B5
    LD      A, ($7337)                  ; RAM $7337
    CP      $02
    RET     NC
    INC     A
    LD      ($7337), A                  ; RAM $7337
    JR      LOC_98BC

LOC_98B5:
    LD      A, ($7336)                  ; RAM $7336
    INC     A
    LD      ($7336), A                  ; RAM $7336

LOC_98BC:
    LD      IY, $7338                   ; RAM $7338
    LD      B, $06

LOC_98C2:
    BIT     4, (IY+0)
    JR      Z, LOC_98D3
    INC     IY
    INC     IY
    INC     IY
    INC     IY
    DJNZ    LOC_98C2
    RET     

LOC_98D3:
    LD      (IY+1), C
    LD      (IY+2), D
    LD      (IY+3), E
    LD      A, $10
    OR      H
    LD      (IY+0), A
    LD      A, C
    CP      $05
    JP      NC, LOC_8CC1
    JP      LOC_8CF6

DELAY_LOOP_98EB:                           ; DELAY_LOOP_98EB: helicopter position update + sprite positioning
    LD      B, $06
    LD      C, $01
    LD      IX, $7338                   ; RAM $7338
    LD      IY, $709C                   ; RAM $709C

LOC_98F7:
    PUSH    BC
    LD      A, (IX+0)
    BIT     4, A
    JP      NZ, LOC_9918

LOC_9900:
    LD      DE, $0004
    ADD     IY, DE
    ADD     IX, DE
    POP     BC
    SLA     C
    DJNZ    LOC_98F7
    LD      HL, $709C                   ; RAM $709C
    LD      DE, $0015
    LD      BC, $0006
    JP      LOC_8527

LOC_9918:
    BIT     5, A
    JP      NZ, LOC_9A72
    LD      A, (IX+1)
    CP      $05
    JR      C, LOC_992B
    LD      HL, $9CE3
    SUB     $05
    JR      LOC_993B

LOC_992B:
    ADD     A, A
    ADD     A, A
    LD      B, A
    LD      A, (IX+0)
    AND     $C0
    RLC     A
    RLC     A
    ADD     A, B
    LD      HL, $9CF5

LOC_993B:
    RST     $10
    LD      B, (HL)
    INC     HL
    LD      C, (HL)
    LD      A, (IX+1)
    CP      $05
    LD      E, (IX+3)
    JR      NC, LOC_9953
    CALL    SUB_9AB4
    LD      E, A
    JP      C, LOC_9A51
    JP      Z, LOC_9A51

LOC_9953:
    LD      A, C
    CALL    SUB_9AC5
    JP      C, LOC_9A51
    JP      Z, LOC_9A51
    LD      (IX+3), A
    LD      (IY+1), A
    LD      A, (IX+2)
    ADD     A, B
    CP      $1F
    JP      C, LOC_9A51
    CP      $C0
    JP      NC, LOC_9A51
    LD      (IX+2), A
    LD      (IY+0), A
    LD      B, A
    LD      HL, $7172                   ; RAM $7172
    SUB     (HL)
    JR      C, LOC_99B5
    CP      $20
    JR      NC, LOC_99B5
    LD      A, ($732C)                  ; RAM $732C
    CP      $E0
    JR      Z, LOC_99B5
    LD      C, A
    LD      A, B
    SUB     C
    JR      C, LOC_99B5
    CP      $10
    JR      NC, LOC_99B5
    LD      A, ($735E)                  ; RAM $735E
    AND     A
    JR      NZ, LOC_99B1
    PUSH    IX
    PUSH    IY
    LD      IX, $7328                   ; RAM $7328
    LD      IY, $7074                   ; RAM $7074
    LD      (IY+0), $E0
    CALL    LOC_88AA
    POP     IY
    POP     IX
    JR      LOC_99B5

LOC_99B1:
    LD      (IY+0), $E0

LOC_99B5:
    CALL    SUB_9AE1
    CALL    SUB_9BC8
    JP      NZ, LOC_9A51
    LD      A, (IX+1)
    CP      $05
    JR      NC, LOC_99E1
    LD      A, (IX+2)
    CP      $98
    JR      NZ, LOC_99E1
    LD      A, (IX+0)
    LD      E, A
    AND     $3F
    LD      C, A
    LD      A, E
    LD      E, $C0
    AND     E
    ADD     A, $40
    CP      E
    JR      C, LOC_99DD
    LD      A, E

LOC_99DD:
    OR      C
    LD      (IX+0), A

LOC_99E1:
    LD      A, (IX+1)
    CP      $05
    JR      C, LOC_99EF
    CP      $0A
    JR      C, LOC_99F9
    JP      LOC_9900

LOC_99EF:
    LD      A, (IX+0)
    AND     $C0
    CP      $C0
    JP      NZ, LOC_9900

LOC_99F9:
    LD      A, (IX+0)
    AND     $0F
    LD      B, A
    CP      $09
    JP      NC, LOC_9900
    LD      HL, $9CDA
    RST     $18
    LD      A, (IX+2)
    CP      (HL)
    JP      C, LOC_9900
    LD      A, B
    AND     A
    JR      NZ, LOC_9A2B
    CALL    SUB_9AF4
    LD      A, (IX+1)
    CP      $05
    JR      NC, LOC_9A28
    CALL    SOUND_WRITE_8CE5
    CALL    SUB_9B0C
    CALL    SUB_9B4F
    JR      LOC_9A2E

LOC_9A28:
    CALL    SUB_9B4F

LOC_9A2B:
    CALL    SOUND_WRITE_8CDA

LOC_9A2E:
    SET     5, (IX+0)
    LD      (IX+2), $01
    LD      (IX+3), $FF
    LD      (IY+3), $00
    LD      A, (IY+0)
    SUB     $10
    LD      (IY+0), A
    LD      A, (IY+1)
    SUB     $08
    LD      (IY+1), A
    JP      NC, LOC_9900

LOC_9A51:
    LD      (IX+0), $00
    LD      (IY+0), $E0
    LD      (IY+2), $84
    LD      (IY+3), $0F
    LD      HL, $7336                   ; RAM $7336
    LD      A, (IX+1)
    CP      $05
    JR      NC, LOC_9A6E
    LD      HL, $7337                   ; RAM $7337

LOC_9A6E:
    DEC     (HL)
    JP      LOC_9900

LOC_9A72:
    DEC     (IX+2)
    JP      NZ, LOC_9A90
    LD      (IX+2), $06
    LD      A, (IX+3)
    INC     A
    CP      $07
    JR      C, LOC_9A8A

LOC_9A84:
    CALL    SUB_87C4
    JP      LOC_9A51

LOC_9A8A:
    LD      (IX+3), A
    CALL    SUB_9AD3

LOC_9A90:
    CALL    SUB_9AB1
    JP      C, LOC_9A84
    JP      Z, LOC_9A84
    LD      (IY+1), A
    LD      A, (IX+0)
    AND     $0F
    LD      HL, $9CDA
    RST     $18
    LD      A, (HL)
    SUB     $10
    LD      (IY+0), A
    CALL    SUB_87A2
    JP      LOC_9900

SUB_9AB1:
    LD      E, (IY+1)

SUB_9AB4:
    LD      A, ($7046)                  ; RAM $7046
    BIT     7, A
    JR      NZ, LOC_9ABF
    LD      D, A
    LD      A, E
    SUB     D
    RET     

LOC_9ABF:
    NEG     
    LD      D, A
    LD      A, E
    ADD     A, D
    RET     

SUB_9AC5:
    BIT     7, A
    JR      Z, LOC_9ACF
    NEG     
    LD      D, A
    LD      A, E
    SUB     D
    RET     

LOC_9ACF:
    LD      D, A
    LD      A, E
    ADD     A, D
    RET     

SUB_9AD3:
    LD      HL, $9D1D

SUB_9AD6:
    RST     $10
    LD      A, (HL)
    INC     HL
    LD      B, (HL)
    LD      (IY+2), A
    LD      (IY+3), B
    RET     

SUB_9AE1:
    LD      HL, $7350                   ; RAM $7350
    LD      (HL), $02
    INC     HL
    LD      A, (IX+3)
    LD      (HL), A
    INC     HL
    LD      (HL), $01
    INC     HL
    LD      A, (IX+2)
    LD      (HL), A
    RET     

SUB_9AF4:
    LD      HL, $7350                   ; RAM $7350
    LD      (HL), $08
    INC     HL
    LD      A, (IX+3)
    SUB     $04
    JR      NC, LOC_9B02
    XOR     A

LOC_9B02:
    LD      (HL), A
    INC     HL
    LD      (HL), $01
    INC     HL
    LD      A, (IX+2)
    LD      (HL), A
    RET     

SUB_9B0C:
    LD      A, ($715A)                  ; RAM $715A
    BIT     2, A
    RET     NZ
    LD      A, ($7172)                  ; RAM $7172
    ADD     A, $10
    LD      B, A
    ADD     A, $10
    LD      C, A
    LD      A, ($7352)                  ; RAM $7352
    LD      E, A
    LD      A, ($7353)                  ; RAM $7353
    ADD     A, E
    CP      B
    JR      C, LOC_9B87
    SUB     E
    CP      C
    JR      NC, LOC_9B87
    LD      A, ($7351)                  ; RAM $7351
    LD      E, A
    LD      A, ($7350)                  ; RAM $7350
    ADD     A, $10
    LD      D, A
    LD      A, ($7173)                  ; RAM $7173
    ADD     A, $18
    SUB     E
    JR      C, LOC_9B87
    CP      D
    JR      NC, LOC_9B87
    PUSH    IX
    LD      IX, $715A                   ; RAM $715A
    CALL    SUB_968D
    CALL    LOC_94AC
    POP     IX
    JR      LOC_9B8E

SUB_9B4F:
    PUSH    IY
    LD      C, $04
    LD      B, $00
    LD      IY, $71B6                   ; RAM $71B6

LOC_9B59:
    PUSH    BC
    PUSH    IY
    CALL    SOUND_WRITE_9BA3
    POP     IY
    POP     BC
    JR      NC, LOC_9B92
    INC     B
    LD      DE, $000A
    ADD     IY, DE
    DEC     C
    JR      NZ, LOC_9B59
    LD      IY, $724E                   ; RAM $724E
    LD      B, $08

LOC_9B73:
    PUSH    IY
    PUSH    BC
    CALL    SUB_9B9E
    POP     BC
    POP     IY
    JR      NC, LOC_9B89
    LD      DE, $0011
    ADD     IY, DE
    DJNZ    LOC_9B73

LOC_9B85:
    POP     IY

LOC_9B87:
    XOR     A
    RET     

LOC_9B89:
    CALL    SUB_A739

LOC_9B8C:
    POP     IY

LOC_9B8E:
    LD      A, $01
    AND     A
    RET     

LOC_9B92:
    LD      (HL), B
    LD      HL, $9D97
    LD      (IY+8), L
    LD      (IY+9), H
    JR      LOC_9B8C

SUB_9B9E:
    LD      B, $07
    JP      SUB_9C9E

SOUND_WRITE_9BA3:
    LD      HL, $7152                   ; RAM $7152
    CALL    SUB_8575
    JR      Z, LOC_9BAE
    LD      HL, $7156                   ; RAM $7156

LOC_9BAE:
    LD      C, $04

LOC_9BB0:
    LD      A, (HL)
    CP      B
    JP      Z, LOC_9CD8
    CP      $FF
    JR      Z, LOC_9BC0
    INC     HL
    DEC     C
    JR      NZ, LOC_9BB0
    JP      LOC_9CD8

LOC_9BC0:
    PUSH    BC
    LD      B, $15
    CALL    SUB_9C9E
    POP     BC
    RET     

SUB_9BC8:
    LD      A, (IX+1)
    CP      $05
    JP      C, LOC_9B87
    PUSH    IY
    LD      A, ($7078)                  ; RAM $7078
    CP      $E0
    JP      Z, LOC_9C54
    LD      IY, $731A                   ; RAM $731A
    BIT     2, (IY+6)
    JR      NZ, LOC_9C54
    LD      A, (IY+11)
    RES     7, A
    CP      $08
    JR      NC, LOC_9C54
    CP      $05
    JR      C, LOC_9C54
    LD      A, (IY+4)
    ADD     A, $04
    LD      B, A
    ADD     A, $07
    LD      C, A
    LD      A, ($7352)                  ; RAM $7352
    LD      E, A
    LD      A, ($7353)                  ; RAM $7353
    ADD     A, E
    CP      B
    JR      C, LOC_9C54
    SUB     E
    CP      C
    JR      NC, LOC_9C54
    PUSH    IX
    LD      IX, $731A                   ; RAM $731A
    CALL    SUB_AE86
    ADD     A, $03
    POP     IX
    PUSH    AF
    LD      A, ($7351)                  ; RAM $7351
    LD      E, A
    LD      A, ($7350)                  ; RAM $7350
    ADD     A, $0A
    LD      D, A
    POP     AF
    ADD     A, $0A
    SUB     E
    JR      C, LOC_9C54
    CP      D
    JR      NC, LOC_9C54
    PUSH    IX
    LD      IX, $731A                   ; RAM $731A
    LD      IY, $7078                   ; RAM $7078
    CALL    SOUND_WRITE_ABCF
    LD      IX, $7328                   ; RAM $7328
    BIT     0, (IX+6)
    JR      Z, LOC_9C4F
    LD      A, (IX+8)
    CP      $02
    JR      NC, LOC_9C4F
    LD      IY, $7074                   ; RAM $7074
    CALL    SOUND_WRITE_AE94

LOC_9C4F:
    POP     IX
    JP      LOC_9B8C

LOC_9C54:
    LD      A, (IX+0)
    AND     $0F
    CP      $09
    JP      Z, LOC_9B85
    LD      A, (IX+2)
    CP      $AC
    JP      C, LOC_9B85
    LD      IY, $7218                   ; RAM $7218
    CALL    SUB_9C86
    JR      NC, LOC_9C79
    LD      IY, $7233                   ; RAM $7233
    CALL    SUB_9C86
    JP      C, LOC_9B85

LOC_9C79:
    BIT     2, (IY+0)
    JP      NZ, LOC_9B8C
    CALL    SOUND_WRITE_A258
    JP      LOC_9B8C

SUB_9C86:
    LD      A, (IY+7)
    ADD     A, $08
    LD      (IY+7), A
    LD      B, $10
    CALL    SUB_9CA4
    PUSH    AF
    LD      A, (IY+7)
    SUB     $08
    LD      (IY+7), A
    POP     AF
    RET     

SUB_9C9E:
    BIT     2, (IY+0)
    JR      NZ, LOC_9CD8

SUB_9CA4:
    BIT     0, (IY+0)
    JR      Z, LOC_9CD8
    BIT     1, (IY+0)
    JR      Z, LOC_9CD8
    PUSH    HL
    LD      A, ($7350)                  ; RAM $7350
    ADD     A, B
    LD      C, A
    LD      HL, ($7044)                 ; RAM $7044
    DEC     H
    LD      A, ($7351)                  ; RAM $7351
    RST     $18
    PUSH    HL
    LD      L, (IY+1)
    LD      H, (IY+2)
    LD      A, (IY+7)
    ADD     A, $09
    RST     $18
    LD      E, B
    ADD     HL, DE
    POP     DE
    RST     $20
    JR      C, LOC_9CD6
    LD      B, $00
    SBC     HL, BC
    CCF     

LOC_9CD6:
    POP     HL
    RET     

LOC_9CD8:
    SCF     
    RET     
    DB      $A1, $A3, $A5, $A8, $AB, $AE, $B3, $B8
    DB      $BE, $04, $00, $04, $04, $04, $FC, $04
    DB      $FE, $04, $02, $FE, $04, $FE, $FC, $00
    DB      $FC, $00, $04, $FF, $00, $00, $00, $00
    DB      $00, $01, $00, $FF, $FF, $00, $FE, $00
    DB      $FE, $01, $FF, $FF, $01, $00, $02, $00
    DB      $02, $01, $01, $FF, $00, $00, $00, $00
    DB      $00, $01, $FF, $FF, $00, $00, $00, $00
    DB      $00, $01, $01, $A0, $0F, $A4, $06, $A8
    DB      $0A, $B4, $06, $B0, $0A, $BC, $06, $C8
    DB      $0A, $B8, $06, $C0, $0A, $C4, $06, $C8
    DB      $0A, $01, $00, $0C, $09, $01, $13, $FF
    DB      $FF, $3D, $9D, $41, $9D, $49, $9D, $02
    DB      $07, $08, $09, $0A, $0B, $0C, $02, $02
    DB      $0D, $0E, $0F, $10, $11, $12, $13, $02

DELAY_LOOP_9D52:                           ; DELAY_LOOP_9D52: missile/projectile movement and collision update
    LD      IX, $717A                   ; RAM $717A
    LD      B, $06

LOC_9D58:
    PUSH    BC
    CALL    SUB_88B8
    POP     BC
    LD      DE, $000A
    ADD     IX, DE
    DJNZ    LOC_9D58
    RET     
    DB      $01, $68, $07, $06, $02, $12, $FF, $FF
    DB      $7B, $9D, $0D, $7A, $07, $09, $95, $00
    DB      $01, $00, $E0, $95, $68, $08, $7F, $9D
    DB      $8B, $9D, $00, $14, $15, $16, $00, $00
    DB      $02, $1B, $1C, $1D, $02, $02, $00, $17
    DB      $18, $19, $1A, $00, $02, $1E, $1F, $20
    DB      $21, $02, $9B, $9D, $A7, $9D, $00, $14
    DB      $15, $16, $00, $00, $02, $22, $23, $24
    DB      $02, $02, $00, $17, $18, $19, $1A, $00
    DB      $02, $1E, $25, $26, $27, $02

SOUND_WRITE_9DB3:                          ; SOUND_WRITE_9DB3: handle queued sound requests from $703E
    LD      B, $04
    LD      IX, $71B6                   ; RAM $71B6

LOC_9DB9:
    PUSH    BC
    CALL    SUB_88B8
    POP     BC
    LD      DE, $000A
    ADD     IX, DE
    DJNZ    LOC_9DB9
    LD      HL, $7152                   ; RAM $7152
    CALL    SUB_8575
    JR      Z, LOC_9DD0
    LD      HL, $7156                   ; RAM $7156

LOC_9DD0:
    LD      B, $04

LOC_9DD2:
    LD      A, (HL)
    CP      $FF
    RET     Z
    LD      IX, $72FA                   ; RAM $72FA
    LD      IY, $707C                   ; RAM $707C
    LD      C, $01
    AND     A
    JR      Z, LOC_9DF2

LOC_9DE3:
    LD      DE, $0008
    ADD     IX, DE
    LD      DE, $0004
    ADD     IY, DE
    SLA     C
    DEC     A
    JR      NZ, LOC_9DE3

LOC_9DF2:
    PUSH    HL
    PUSH    BC
    CALL    SUB_9DFD
    POP     BC
    POP     HL
    INC     HL
    DJNZ    LOC_9DD2
    RET     

SUB_9DFD:
    DEC     (IX+6)
    JR      NZ, LOC_9E25
    LD      A, (IX+7)
    XOR     $01
    LD      (IX+7), A
    LD      (IX+6), $07
    LD      (IY+2), $68
    LD      (IY+3), $08
    AND     A
    JR      Z, LOC_9E25
    LD      (IX+6), $07
    LD      (IY+2), $6C
    LD      (IY+3), $0A

LOC_9E25:
    PUSH    BC
    CALL    LOC_8818
    POP     BC
    JP      LOC_87AA
    DB      $01, $78, $10, $08, $03, $11, $FF, $FF
    DB      $4D, $9E, $01, $30, $10, $16, $01, $14
    DB      $FF, $FF, $81, $9E, $04, $A4, $10, $0A
    DB      $87, $00, $01, $00, $E0, $C0, $60, $06
    DB      $51, $9E, $69, $9E, $00, $00, $00, $00
    DB      $4F, $50, $00, $00, $00, $48, $49, $49
    DB      $4A, $4B, $00, $00, $02, $44, $44, $41
    DB      $44, $44, $02, $02, $00, $00, $00, $00
    DB      $00, $51, $52, $00, $00, $4C, $49, $49
    DB      $49, $4D, $4E, $00, $02, $45, $46, $42
    DB      $43, $46, $47, $02, $85, $9E, $9A, $9E
    DB      $01, $28, $29, $2A, $33, $34, $35, $2A
    DB      $3A, $3B, $3B, $3B, $3B, $3B, $3B, $3B ; ":;;;;;;;"
    DB      $3C, $2A, $2B, $2C, $01, $01, $2D, $2E
    DB      $2F, $36, $37, $38, $39, $3D, $3E, $3B ; "/6789=>;"
    DB      $3B, $3B, $3B, $3B, $3B, $3F, $40, $30 ; ";;;;;?@0"
    DB      $31, $32, $01

SUB_9EB0:                                  ; SUB_9EB0: helicopter collision check (vs enemies, projectiles)
    LD      IX, $71E8                   ; RAM $71E8
    CALL    SUB_88B8
    LD      IX, $71DE                   ; RAM $71DE
    JP      SUB_88B8

SUB_9EBE:                                  ; SUB_9EBE: helicopter animation controller (frame advance, sprite update)
    LD      IX, $71F2                   ; RAM $71F2
    LD      IY, $7058                   ; RAM $7058
    DEC     (IX+6)
    JR      NZ, LOC_9EE6
    LD      A, (IX+7)
    XOR     $01
    LD      (IX+7), A
    LD      (IX+6), $05
    LD      (IY+2), $60
    AND     A
    JR      Z, LOC_9EE6
    LD      (IX+6), $07
    LD      (IY+2), $64

LOC_9EE6:
    JP      LOC_8818
    DB      $E0, $C0, $80, $0E, $E0, $C0, $7C, $0E
    DB      $E0, $C0, $78, $0E, $E0, $C0, $74, $0E
    DB      $E0, $C0, $70, $0E, $09, $A0, $0F, $04
    DB      $8F, $01, $08, $A0, $0F, $06, $93, $02
    DB      $07, $A0, $0F, $0A, $A0, $03, $06, $A0
    DB      $0F, $0C, $A4, $04, $05, $A0, $0F, $10
    DB      $AA, $05

SUB_9F1B:                                  ; SUB_9F1B: projectile pool management (5 missile slots x 6 bytes at $71FA)
    LD      IX, $71FA                   ; RAM $71FA
    LD      IY, $706C                   ; RAM $706C
    CALL    LOC_8818
    LD      IX, $7200                   ; RAM $7200
    LD      IY, $7068                   ; RAM $7068
    CALL    LOC_8818
    LD      IX, $7206                   ; RAM $7206
    LD      IY, $7064                   ; RAM $7064
    CALL    LOC_8818
    LD      IX, $720C                   ; RAM $720C
    LD      IY, $7060                   ; RAM $7060
    CALL    LOC_8818
    LD      IX, $7212                   ; RAM $7212
    LD      IY, $705C                   ; RAM $705C
    JP      LOC_8818
    DB      $E0, $FF, $FF, $00, $01, $00, $0A, $07
    DB      $02, $15, $FF, $FF, $8F, $9F, $01, $06
    DB      $80, $20, $00, $00, $00, $00, $00, $01
    DB      $00, $11, $FF, $00, $10, $AC, $00, $18
    DB      $72, $33, $72, $00, $00, $00, $01, $02
    DB      $01, $8F, $9F, $9B, $9F, $8B, $9F, $97
    DB      $9F, $87, $9F, $93, $9F, $B8, $9F, $C4
    DB      $9F, $D1, $9F, $DD, $9F, $9F, $9F, $AB
    DB      $9F, $03, $A0, $0F, $A0, $1C, $A0, $28
    DB      $A0, $EA, $9F, $F6, $9F, $01, $01, $65
    DB      $66, $01, $01, $01, $01, $53, $5B, $5C
    DB      $54, $01, $01, $67, $68, $69, $01, $01
    DB      $01, $55, $5D, $5E, $5F, $56, $01, $01
    DB      $6A, $6B, $01, $01, $01, $01, $53, $5B
    DB      $5C, $54, $01, $01, $6C, $6D, $6E, $01
    DB      $01, $01, $55, $5D, $5E, $5F, $56, $01
    DB      $01, $6F, $70, $01, $01, $01, $01, $53
    DB      $5B, $5C, $54, $01, $01, $71, $72, $73
    DB      $01, $01, $01, $55, $5D, $5E, $5F, $56
    DB      $01, $01, $65, $66, $01, $01, $01, $01
    DB      $57, $60, $61, $58, $01, $01, $67, $68
    DB      $69, $01, $01, $01, $59, $62, $63, $64
    DB      $5A, $01, $01, $6A, $6B, $01, $01, $01
    DB      $01, $57, $60, $61, $58, $01, $01, $6C
    DB      $6D, $6E, $01, $01, $01, $59, $62, $63
    DB      $64, $5A, $01, $01, $6F, $70, $01, $01
    DB      $01, $01, $57, $60, $61, $58, $01, $01
    DB      $71, $72, $73, $01, $01, $01, $59, $62
    DB      $63, $64, $5A, $01

SUB_A036:                                  ; SUB_A036: vehicle/truck spawn controller (level-indexed spawn table)
    LD      IX, $7218                   ; RAM $7218
    CALL    SUB_A041
    LD      IX, $7233                   ; RAM $7233

SUB_A041:
    CALL    DELAY_LOOP_A1CC
    BIT     0, (IX+0)
    JR      NZ, LOC_A05B
    LD      L, (IX+19)
    LD      H, (IX+20)
    LD      A, H
    OR      L
    RET     Z
    DEC     HL
    LD      (IX+19), L
    LD      (IX+20), H
    RET     

LOC_A05B:
    BIT     2, (IX+0)
    JP      NZ, LOC_A29A
    DEC     (IX+12)
    JR      NZ, LOC_A0A3
    CALL    SUB_854C
    CP      $80
    JR      C, LOC_A07C
    LD      (IX+12), $08
    LD      BC, BOOT_UP
    LD      A, $00
    LD      (IX+18), A
    JR      LOC_A099

LOC_A07C:
    LD      (IX+12), $20
    LD      BC, $0004
    LD      HL, ($7044)                 ; RAM $7044
    DEC     H
    LD      A, ($7173)                  ; RAM $7173
    ADD     A, $08
    RST     $18
    LD      E, (IX+1)
    LD      D, (IX+2)
    RST     $20
    JR      NC, LOC_A099
    LD      BC, $FFFC

LOC_A099:
    LD      (IX+16), C
    LD      (IX+17), B
    LD      (IX+11), $01

LOC_A0A3:
    DEC     (IX+11)
    JR      NZ, LOC_A0F1
    LD      (IX+11), $06
    LD      A, (IX+16)
    AND     A
    JR      Z, LOC_A0F1
    LD      C, A
    LD      B, (IX+17)
    LD      L, (IX+1)
    LD      H, (IX+2)
    ADD     HL, BC
    LD      E, L
    LD      D, H
    LD      BC, $06AA
    AND     A
    SBC     HL, BC
    JR      C, LOC_A0DB
    LD      L, E
    LD      H, D
    LD      BC, $0E8C
    AND     A
    SBC     HL, BC
    JR      NC, LOC_A0DB
    PUSH    DE
    LD      HL, $9F71
    CALL    SUB_A8B7
    JR      Z, LOC_A0E2
    POP     HL

LOC_A0DB:
    LD      A, $00
    LD      (IX+18), A
    JR      LOC_A0F1

LOC_A0E2:
    POP     HL
    LD      (IX+1), L
    LD      (IX+2), H
    LD      A, (IX+18)
    XOR     $01
    LD      (IX+18), A

LOC_A0F1:
    DEC     (IX+13)
    JR      NZ, LOC_A149
    LD      (IX+13), $40
    CALL    SUB_854C
    CP      $80
    JR      C, LOC_A138
    LD      HL, ($7044)                 ; RAM $7044
    DEC     H
    LD      A, ($7173)                  ; RAM $7173
    ADD     A, $10
    RST     $18
    PUSH    HL
    LD      L, (IX+1)
    LD      H, (IX+2)
    LD      A, (IX+7)
    ADD     A, $18
    RST     $18
    POP     DE
    RST     $20
    JR      C, LOC_A12C
    LD      B, $02
    LD      A, H
    AND     A
    JR      NZ, LOC_A129
    LD      A, L

LOC_A123:
    CP      $08
    JR      NC, LOC_A129
    LD      B, $01

LOC_A129:
    LD      A, B
    JR      LOC_A13E

LOC_A12C:
    LD      B, $00
    LD      A, H
    CP      $FF
    JR      NZ, LOC_A129
    LD      A, L
    NEG     
    JR      LOC_A123

LOC_A138:
    LD      A, (IX+15)
    INC     A
    AND     $03

LOC_A13E:
    LD      (IX+15), A
    LD      HL, $9F77
    RST     $18
    LD      A, (HL)
    LD      (IX+14), A

LOC_A149:
    LD      A, (IX+14)
    ADD     A, A
    ADD     A, (IX+18)
    LD      HL, $9F7B
    RST     $10
    LD      A, (HL)
    LD      (IX+8), A
    INC     HL
    LD      A, (HL)
    LD      (IX+9), A
    CALL    SUB_88B8
    BIT     2, (IX+0)
    RET     NZ
    DEC     (IX+10)
    RET     NZ
    LD      (IX+10), $01
    LD      HL, $715A                   ; RAM $715A
    BIT     2, (HL)
    RET     NZ
    CALL    SUB_854C
    LD      HL, $714E                   ; RAM $714E
    CP      (HL)
    RET     NC
    BIT     1, (IX+0)
    RET     Z
    LD      A, (IX+6)
    CP      $1B
    RET     NC
    LD      (IX+10), $68
    LD      C, $00
    LD      E, $0E
    LD      A, (IX+14)
    CP      $01
    JR      Z, LOC_A1B5
    CP      $02
    JR      Z, LOC_A1A8
    CALL    SUB_854C
    LD      E, $16
    CP      $80
    LD      C, $02
    JR      C, LOC_A1B5
    LD      C, $04
    JR      LOC_A1B5

LOC_A1A8:
    CALL    SUB_854C
    LD      E, $06
    CP      $80
    LD      C, $01
    JR      NC, LOC_A1B5
    LD      C, $03

LOC_A1B5:
    LD      A, (IX+6)
    INC     A
    ADD     A, A
    ADD     A, A
    ADD     A, A
    ADD     A, (IX+7)
    RET     C
    RET     Z
    ADD     A, E
    RET     C
    RET     Z
    LD      E, A
    LD      D, $A7
    LD      H, $00
    JP      LOC_98A4

DELAY_LOOP_A1CC:
    LD      A, ($7333)                  ; RAM $7333
    CP      $02
    RET     NC
    LD      IY, $7218                   ; RAM $7218
    LD      B, $02

LOC_A1D8:
    BIT     0, (IY+0)
    JR      NZ, LOC_A1E7
    LD      L, (IY+19)
    LD      A, (IY+20)
    OR      L
    JR      Z, LOC_A1EF

LOC_A1E7:
    LD      DE, $001B
    ADD     IY, DE
    DJNZ    LOC_A1D8
    RET     

LOC_A1EF:
    PUSH    IY
    POP     DE
    LD      HL, $9F56
    LD      BC, $0015
    LDIR    
    RES     0, (IY+0)
    CALL    SUB_A225
    PUSH    IY
    PUSH    IX
    PUSH    DE
    PUSH    IY
    POP     IX
    LD      HL, $9F71
    CALL    SUB_A8B7
    POP     DE
    POP     IX
    POP     IY
    RET     NZ
    LD      (IY+1), E
    LD      (IY+2), D
    LD      HL, $7333                   ; RAM $7333
    INC     (HL)
    SET     0, (IY+0)
    RET     

SUB_A225:
    CALL    SUB_854C
    CP      $80
    JR      NC, LOC_A246

LOC_A22C:
    LD      HL, ($7044)                 ; RAM $7044

LOC_A22F:
    LD      DE, $FEC0
    ADD     HL, DE
    LD      E, L
    LD      D, H
    LD      BC, $0E8C
    AND     A
    SBC     HL, BC
    LD      L, E
    LD      H, D
    JR      NC, LOC_A22F
    LD      BC, $07A8
    AND     A
    SBC     HL, BC
    RET     NC

LOC_A246:
    LD      HL, ($7044)                 ; RAM $7044
    LD      DE, $0040
    ADD     HL, DE
    LD      E, L
    LD      D, H
    LD      BC, $0E8C
    AND     A
    SBC     HL, BC
    JR      NC, LOC_A22C
    RET     

SOUND_WRITE_A258:
    CALL    SOUND_WRITE_8CDA
    LD      HL, $7333                   ; RAM $7333
    DEC     (HL)
    SET     2, (IY+0)
    LD      B, $07
    LD      C, B
    LD      A, $01
    LD      D, (IY+5)
    LD      E, (IY+6)
    PUSH    DE
    CALL    DELAY_LOOP_A799
    POP     DE
    INC     D
    LD      BC, $0007
    CALL    LOC_A7A0
    LD      (IY+15), $FF
    LD      (IY+14), $01
    LD      L, (IY+1)
    LD      H, (IY+2)
    LD      A, (IY+7)
    ADD     A, $08
    RST     $18
    LD      DE, $0015
    ADD     IY, DE
    LD      (IY+1), L
    LD      (IY+2), H
    RET     

LOC_A29A:
    DEC     (IX+14)
    JR      NZ, LOC_A2AE
    LD      (IX+14), $07
    LD      A, (IX+15)
    INC     A
    LD      (IX+15), A
    CP      $0D
    JR      NC, LOC_A320

LOC_A2AE:
    LD      A, (IX+15)
    LD      B, A
    ADD     A, A
    ADD     A, B
    LD      HL, $A34C
    RST     $18
    LD      C, (HL)
    INC     HL
    LD      A, (HL)
    INC     HL
    LD      H, (HL)
    LD      L, A
    LD      A, (IX+21)
    SUB     $11
    LD      E, $D4
    JR      Z, LOC_A2C9
    LD      E, $DC

LOC_A2C9:
    LD      D, $00
    LD      B, E
    LD      A, (IX+14)
    CP      $07
    JR      NZ, LOC_A2D8
    PUSH    BC
    CALL    SUB_84F7
    POP     BC

LOC_A2D8:
    LD      DE, $0015
    ADD     IX, DE
    CALL    SUB_8788
    LD      (IY+2), B
    LD      (IY+3), C
    PUSH    BC
    CALL    LOC_8818
    POP     BC
    LD      A, (IX+0)
    PUSH    AF
    ADD     A, $01
    LD      (IX+0), A
    LD      L, (IX+1)
    LD      H, (IX+2)
    PUSH    HL
    LD      DE, $0010
    ADD     HL, DE
    LD      (IX+1), L
    LD      (IX+2), H
    CALL    SUB_8788
    LD      A, $04
    ADD     A, B
    LD      (IY+2), A
    LD      (IY+3), C
    CALL    LOC_8818
    POP     HL
    POP     AF
    LD      (IX+1), L
    LD      (IX+2), H
    LD      (IX+0), A
    RET     

LOC_A320:
    RES     0, (IX+0)
    LD      HL, ($714F)                 ; RAM $714F
    LD      (IX+19), L
    LD      (IX+20), H
    LD      DE, $0015
    ADD     IX, DE
    CALL    SUB_8788
    CALL    LOC_88A2
    LD      A, (IX+0)
    PUSH    AF
    ADD     A, $01
    LD      (IX+0), A
    CALL    SUB_8788
    CALL    LOC_88A2
    POP     AF
    LD      (IX+0), A
    RET     
    DB      $00, $42, $BD, $0F, $42, $BD, $0F, $68
    DB      $BD, $0A, $AE, $BE, $06, $F0, $BE, $0A
    DB      $27, $BE, $06, $69, $BE, $0A, $A2, $BD
    DB      $06, $E2, $BD, $0A, $35, $BF, $06, $7A
    DB      $BF, $0A, $BF, $BF, $00, $BF, $BF

LOC_A373:
    LD      A, $08
    LD      DE, $724E                   ; RAM $724E

LOC_A378:
    LD      HL, $A447
    LD      BC, $0011
    LDIR    
    DEC     A
    JR      NZ, LOC_A378
    LD      HL, $A458
    LD      DE, $72D6                   ; RAM $72D6
    LD      BC, $0006
    LDIR    
    XOR     A
    LD      ($7334), A                  ; RAM $7334

SUB_A392:
    LD      A, ($7334)                  ; RAM $7334
    CP      $08
    RET     NC
    LD      B, A
    LD      A, ($702F)                  ; RAM $702F
    BIT     0, A
    LD      IY, $7155                   ; RAM $7155
    LD      A, ($70BE)                  ; RAM $70BE
    LD      HL, $70BC                   ; RAM $70BC
    JR      Z, LOC_A3B4
    LD      IY, $7159                   ; RAM $7159
    LD      A, ($70BF)                  ; RAM $70BF
    LD      HL, $70BD                   ; RAM $70BD

LOC_A3B4:
    ADD     A, B
    ADD     A, (HL)
    LD      HL, $70C0                   ; RAM $70C0
    ADD     A, (HL)
    SUB     $40
    RET     Z
    NEG     
    LD      B, A
    LD      C, A
    LD      HL, $7334                   ; RAM $7334
    LD      A, $08
    SUB     (HL)
    CP      C
    JR      C, LOC_A3CB
    LD      A, C

LOC_A3CB:
    LD      C, A
    LD      IX, $724E                   ; RAM $724E
    LD      A, B
    LD      E, $00
    CP      $11
    JR      C, LOC_A3EB
    DEC     IY
    LD      E, $10
    CP      $21
    JR      C, LOC_A3EB
    DEC     IY
    LD      E, $20
    CP      $31
    JR      C, LOC_A3EB
    DEC     IY
    LD      E, $30

LOC_A3EB:
    SUB     E
    LD      B, A
    CP      C
    JR      C, LOC_A3F5

LOC_A3F0:
    LD      B, C
    LD      C, $00
    JR      LOC_A3F9

LOC_A3F5:
    SUB     C
    NEG     
    LD      C, A

LOC_A3F9:
    LD      A, (IY+0)
    CP      $FF
    RET     Z
    LD      HL, $A43F
    RST     $10
    LD      A, (HL)
    INC     HL
    LD      H, (HL)
    LD      L, A

LOC_A407:
    LD      A, (IX+12)
    CP      $06
    JR      Z, LOC_A415

LOC_A40E:
    LD      DE, $0011
    ADD     IX, DE
    JR      LOC_A407

LOC_A415:
    LD      (IX+1), L
    LD      (IX+2), H
    LD      (IX+7), $00
    LD      (IX+12), $05
    LD      (IX+13), $00
    LD      (IX+15), $08
    LD      (IX+16), $00
    LD      A, ($7334)                  ; RAM $7334
    INC     A
    LD      ($7334), A                  ; RAM $7334
    DJNZ    LOC_A40E
    INC     IY
    LD      A, C
    AND     A
    RET     Z
    JR      LOC_A3F0
    DB      $78, $07, $90, $08, $A8, $09, $C0, $0A
    DB      $00, $B0, $0A, $04, $01, $13, $FF, $FF
    DB      $FF, $00, $01, $10, $06, $00, $00, $01
    DB      $00, $0A, $FF, $00, $08, $97, $00, $B6
    DB      $71, $C0, $71, $CA, $71, $D4, $71, $7A
    DB      $71, $84, $71, $8E, $71, $98, $71, $00
    DB      $00, $4E, $72, $5F, $72, $70, $72, $81
    DB      $72, $92, $72, $A3, $72, $B4, $72, $C5
    DB      $72, $00, $00, $98, $A4, $9B, $A4, $92
    DB      $A4, $95, $A4, $9E, $A4, $A1, $A4, $A4
    DB      $A4, $A7, $A4, $02, $74, $02, $02, $75
    DB      $76, $02, $77, $02, $02, $78, $79, $02
    DB      $7B, $02, $02, $7C, $7A, $02, $7D, $02
    DB      $02, $7E, $7A, $02

DELAY_LOOP_A4AB:                           ; DELAY_LOOP_A4AB: vehicle/truck animation and movement update
    CALL    SUB_A392
    LD      IX, $724E                   ; RAM $724E
    LD      B, $08

LOC_A4B4:
    PUSH    IX
    PUSH    BC
    CALL    SUB_A4C5
    POP     BC
    POP     IX
    LD      DE, $0011
    ADD     IX, DE
    DJNZ    LOC_A4B4
    RET     

SUB_A4C5:
    BIT     0, (IX+0)
    JR      NZ, LOC_A509
    LD      A, ($715A)                  ; RAM $715A
    BIT     2, A
    RET     NZ
    LD      A, (IX+12)
    CP      $05
    RET     NZ
    LD      L, (IX+15)
    LD      H, (IX+16)
    DEC     HL
    LD      (IX+15), L
    LD      (IX+16), H
    LD      A, L
    OR      H
    RET     NZ
    LD      (IX+15), $08
    LD      (IX+16), $00
    LD      A, ($702F)                  ; RAM $702F
    BIT     4, A
    RET     NZ
    LD      (IX+0), $01
    LD      HL, $0004
    LD      (IX+12), L
    LD      (IX+13), H
    LD      (IX+10), $01
    JP      LOC_A6DB

LOC_A509:
    BIT     4, (IX+0)
    JP      NZ, LOC_A621
    LD      A, (IX+12)
    CP      $07
    JP      Z, LOC_A748
    DEC     (IX+11)
    JR      NZ, LOC_A524
    LD      (IX+11), $01
    CALL    SUB_A7BC

LOC_A524:
    DEC     (IX+10)
    JP      NZ, LOC_A5BF
    LD      (IX+10), $08
    BIT     1, (IX+0)
    JR      NZ, LOC_A538
    LD      (IX+10), $0B

LOC_A538:
    LD      A, (IX+12)
    AND     A
    JP      Z, LOC_A5BF
    LD      C, A
    LD      B, (IX+13)
    LD      L, (IX+1)
    LD      H, (IX+2)
    ADD     HL, BC
    LD      E, L
    LD      D, H
    CALL    SUB_A850
    JP      NZ, LOC_A768
    LD      L, E
    LD      H, D
    LD      BC, $06AA
    AND     A
    SBC     HL, BC
    JR      C, LOC_A569
    LD      L, E
    LD      H, D
    LD      BC, $0E1C
    AND     A
    SBC     HL, BC
    JR      C, LOC_A572
    JR      LOC_A569

LOC_A568:
    POP     HL

LOC_A569:
    RES     6, (IX+0)
    CALL    LOC_A822
    JR      LOC_A5BF

LOC_A572:
    PUSH    DE
    LD      HL, $715A                   ; RAM $715A
    BIT     2, (HL)
    JR      Z, LOC_A581
    LD      A, ($715F)                  ; RAM $715F
    CP      $04
    JR      Z, LOC_A568

LOC_A581:
    LD      HL, $A470
    CALL    SUB_A8B7
    JR      Z, LOC_A58F
    BIT     6, (IX+0)
    JR      Z, LOC_A568

LOC_A58F:
    LD      HL, $A45E
    CALL    SUB_A8B7
    JR      Z, LOC_A5B8
    BIT     6, (IX+0)
    JR      NZ, LOC_A5B8
    LD      A, ($702F)                  ; RAM $702F
    BIT     4, A
    JR      NZ, LOC_A568
    BIT     1, (IX+0)
    JR      NZ, LOC_A5B1
    CALL    SUB_854C
    CP      $80
    JR      C, LOC_A568

LOC_A5B1:
    POP     HL
    CALL    LOC_A6DB
    JP      LOC_A652

LOC_A5B8:
    POP     HL
    LD      (IX+1), L
    LD      (IX+2), H

LOC_A5BF:
    LD      A, (IX+12)
    AND     A
    JR      NZ, LOC_A5FB
    DEC     (IX+16)
    JR      NZ, LOC_A5E4
    LD      (IX+16), $20
    BIT     3, (IX+0)
    SET     3, (IX+0)
    LD      (IX+15), $01
    JR      Z, LOC_A5E4
    RES     3, (IX+0)
    LD      (IX+16), $FF

LOC_A5E4:
    BIT     3, (IX+0)
    JR      Z, LOC_A5FB
    DEC     (IX+15)
    JR      NZ, LOC_A5FB
    LD      (IX+15), $06
    LD      A, (IX+14)
    XOR     $01
    LD      (IX+14), A

LOC_A5FB:
    LD      HL, $A482
    LD      A, (IX+12)
    CP      $FC
    JR      Z, LOC_A618
    LD      HL, $A486
    CP      $04
    JR      Z, LOC_A618
    LD      HL, $A48A
    LD      A, (IX+14)
    AND     A
    JR      Z, LOC_A618
    LD      HL, $A48E

LOC_A618:
    LD      (IX+8), L
    LD      (IX+9), H
    JP      SUB_88B8

LOC_A621:
    CALL    SUB_A7BC
    DEC     (IX+11)
    JR      NZ, LOC_A649
    LD      (IX+11), $05
    LD      E, (IX+1)
    LD      D, (IX+2)
    LD      HL, $A45E
    CALL    SUB_A8B7
    JR      NZ, LOC_A649
    LD      HL, $A470
    CALL    SUB_A8B7
    JR      NZ, LOC_A649
    CALL    SUB_A719
    JP      LOC_A509

LOC_A649:
    LD      IY, $72D6                   ; RAM $72D6
    DEC     (IX+10)
    JR      NZ, LOC_A6AC

LOC_A652:
    LD      IY, $72D6                   ; RAM $72D6
    LD      (IX+10), $08
    LD      C, (IX+12)
    LD      B, (IX+13)
    LD      L, (IX+1)
    LD      H, (IX+2)
    ADD     HL, BC
    LD      E, L
    LD      D, H
    CALL    SUB_A850
    JP      NZ, LOC_A768
    LD      L, E
    LD      H, D
    LD      BC, $06AA
    AND     A
    SBC     HL, BC
    JR      NC, LOC_A688
    LD      (IX+11), $05
    LD      HL, $0004
    LD      (IX+12), L
    LD      (IX+13), H
    JR      LOC_A652

LOC_A688:
    LD      L, E
    LD      H, D
    LD      BC, $0E1C
    AND     A
    SBC     HL, BC
    JR      C, LOC_A6A1
    LD      (IX+11), $05
    LD      HL, $FFFC
    LD      (IX+12), L
    LD      (IX+13), H
    JR      LOC_A652

LOC_A6A1:
    LD      L, E
    LD      H, D
    LD      (IX+1), L
    LD      (IX+2), H
    CALL    SUB_A70C

LOC_A6AC:
    LD      B, $90
    BIT     7, (IX+12)
    JR      Z, LOC_A6B6
    LD      B, $98

LOC_A6B6:
    LD      E, (IY+1)
    LD      D, (IY+2)
    LD      HL, ($7044)                 ; RAM $7044
    RST     $20
    LD      A, $04
    AND     L
    ADD     A, B
    PUSH    IY
    POP     IX
    LD      IY, $7070                   ; RAM $7070
    LD      (IY+3), $0E
    LD      (IY+2), A
    CALL    LOC_8818
    LD      C, $10
    JP      LOC_87AA

LOC_A6DB:
    BIT     1, (IX+0)
    JR      Z, LOC_A6E8
    PUSH    IX
    POP     IY
    CALL    DELAY_LOOP_A78E

LOC_A6E8:
    LD      HL, $702F                   ; RAM $702F
    SET     4, (HL)
    RES     5, (IX+0)
    SET     4, (IX+0)
    LD      (IX+11), $10
    LD      A, $97
    LD      ($7070), A                  ; RAM $7070
    XOR     A
    LD      ($7073), A                  ; RAM $7073
    LD      IY, $72D6                   ; RAM $72D6
    LD      L, (IX+1)
    LD      H, (IX+2)

SUB_A70C:
    LD      A, (IX+7)
    ADD     A, $08
    RST     $18
    LD      (IY+1), L
    LD      (IY+2), H
    RET     

SUB_A719:
    RES     4, (IX+0)
    CALL    LOC_A822
    LD      (IX+11), $01

LOC_A724:
    LD      HL, $702F                   ; RAM $702F
    RES     4, (HL)
    LD      IY, $7070                   ; RAM $7070
    PUSH    IX
    LD      IX, $72D6                   ; RAM $72D6
    CALL    LOC_88A2
    POP     IX
    RET     

SUB_A739:                                  ; SUB_A739: hostage capture handler (check proximity, flag rescue)
    BIT     4, (IY+0)
    JR      NZ, SUB_A752
    LD      (IY+12), $07
    LD      (IY+16), $08
    RET     

LOC_A748:
    DEC     (IX+16)
    JP      NZ, SUB_88B8
    PUSH    IX
    POP     IY

SUB_A752:                                  ; SUB_A752: score update on hostage pickup (BCD add to score)
    CALL    SUB_8D1D
    LD      A, ($702F)                  ; RAM $702F
    LD      HL, $70BE                   ; RAM $70BE
    BIT     0, A
    JR      Z, LOC_A762
    LD      HL, $70BF                   ; RAM $70BF

LOC_A762:
    INC     (HL)
    CALL    SUB_8B56
    JR      LOC_A776

LOC_A768:
    CALL    SUB_8D21
    LD      HL, $70C0                   ; RAM $70C0
    INC     (HL)
    CALL    SUB_8B67
    PUSH    IX
    POP     IY

LOC_A776:
    LD      HL, $7334                   ; RAM $7334
    DEC     (HL)
    BIT     4, (IY+0)
    LD      A, $00
    LD      (IY+0), A
    LD      HL, $0006
    LD      (IY+12), L
    LD      (IY+13), H
    JR      NZ, LOC_A724

DELAY_LOOP_A78E:
    LD      A, $02
    LD      B, $04
    LD      C, B
    LD      D, (IY+5)
    LD      E, (IY+6)

DELAY_LOOP_A799:
    LD      HL, WORK_BUFFER             ; WORK_BUFFER

LOC_A79C:
    LD      (HL), A
    INC     HL
    DJNZ    LOC_A79C

LOC_A7A0:
    BIT     7, E
    JR      Z, LOC_A7A8
    INC     E
    DEC     C
    JR      LOC_A7A0

LOC_A7A8:
    CALL    SUB_8794
    LD      A, E
    AND     $1F
    SUB     $20
    NEG     
    CP      C
    JR      NC, LOC_A7B6
    LD      C, A

LOC_A7B6:
    LD      HL, WORK_BUFFER             ; WORK_BUFFER
    JP      LOC_852B

SUB_A7BC:
    LD      HL, $715E                   ; RAM $715E
    BIT     5, (IX+0)
    JR      Z, LOC_A7D6
    BIT     1, (HL)
    JR      Z, LOC_A7D0
    LD      A, (IX+12)
    AND     A
    JR      Z, LOC_A7DE
    RET     

LOC_A7D0:
    RES     5, (IX+0)
    JR      LOC_A822

LOC_A7D6:
    BIT     1, (HL)
    JR      Z, LOC_A816
    SET     5, (IX+0)

LOC_A7DE:
    LD      HL, ($7044)                 ; RAM $7044
    DEC     H
    LD      A, ($7173)                  ; RAM $7173
    RST     $18
    LD      A, $10
    RST     $18
    DB      $EB
    LD      L, (IX+1)
    LD      H, (IX+2)
    LD      A, (IX+7)
    ADD     A, $0C
    LD      C, A
    LD      B, $00
    ADD     HL, BC
    DB      $EB
    RST     $20
    LD      BC, $0004
    JR      NC, LOC_A805
    JR      Z, LOC_A805
    LD      BC, $FFFC

LOC_A805:
    BIT     4, (IX+0)
    JR      NZ, LOC_A80F
    LD      (IX+11), $20

LOC_A80F:
    LD      (IX+12), C
    LD      (IX+13), B
    RET     

LOC_A816:
    BIT     4, (IX+0)
    RET     NZ
    CALL    SUB_854C
    CP      $20
    JR      NC, LOC_A7DE

LOC_A822:
    BIT     4, (IX+0)
    RET     NZ
    LD      HL, BOOT_UP
    LD      (IX+12), L
    LD      (IX+13), H
    LD      (IX+11), $20
    RES     3, (IX+0)
    CALL    SUB_854C
    CP      $80
    LD      BC, BOOT_UP
    JR      NC, LOC_A80F
    SET     3, (IX+0)
    LD      (IX+15), $01
    LD      (IX+16), $20
    JR      LOC_A80F

SUB_A850:
    RES     6, (IX+0)
    LD      HL, $715E                   ; RAM $715E
    BIT     1, (HL)
    RET     Z
    LD      HL, $715A                   ; RAM $715A
    BIT     2, (HL)
    JP      NZ, LOC_A8FD
    LD      A, ($70C0)                  ; RAM $70C0
    CP      $10
    JP      NC, LOC_A8FD
    PUSH    DE
    LD      HL, $000D
    LD      BC, $0016
    LD      A, (IX+7)
    CALL    SUB_A899
    POP     DE
    RET     NZ
    BIT     4, (IX+0)
    JP      NZ, LOC_A8FD
    LD      A, H
    AND     A
    JR      Z, LOC_A88E
    CP      $FF
    JP      NZ, LOC_A8FD
    LD      A, L
    NEG     
    JR      LOC_A88F

LOC_A88E:
    LD      A, L

LOC_A88F:
    CP      $09
    JR      NC, LOC_A8FD
    SET     6, (IX+0)
    JR      LOC_A8FD

SUB_A899:
    PUSH    HL
    ADD     A, $0D
    LD      L, A
    LD      H, $00
    ADD     HL, DE
    DB      $EB
    LD      HL, ($7044)                 ; RAM $7044
    DEC     H
    ADD     HL, BC
    LD      A, ($7173)                  ; RAM $7173
    LD      C, A
    LD      B, $00
    ADD     HL, BC
    POP     BC
    RST     $20
    JR      C, LOC_A8FD
    SBC     HL, BC
    JR      NC, LOC_A8FD
    JR      LOC_A8F8

SUB_A8B7:
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    INC     HL
    LD      A, C
    OR      B
    JR      Z, LOC_A8FD
    PUSH    HL
    PUSH    IX
    POP     HL
    AND     A
    SBC     HL, BC
    JR      Z, LOC_A8F4
    PUSH    BC
    POP     IY
    BIT     0, (IY+0)
    JR      Z, LOC_A8F4
    LD      L, (IY+1)
    LD      H, (IY+2)
    LD      A, (IY+3)
    DEC     A
    ADD     A, A
    ADD     A, A
    ADD     A, A
    LD      C, A
    LD      B, $00
    ADD     HL, BC
    RST     $20
    JR      C, LOC_A8F4
    LD      A, (IX+3)
    DEC     A
    ADD     A, A
    ADD     A, A
    ADD     A, A
    ADD     A, C
    LD      C, A
    LD      B, $00
    SBC     HL, BC
    JR      C, LOC_A8F7

LOC_A8F4:
    POP     HL
    JR      SUB_A8B7

LOC_A8F7:
    POP     HL

LOC_A8F8:
    LD      A, $01
    AND     A
    RET     
    DB      $E1

LOC_A8FD:
    XOR     A
    RET     
    DB      $00, $FF, $00, $FF, $1B, $FF, $00, $07
    DB      $97, $00, $01, $00, $06, $00, $00, $01
    DB      $01, $E0, $80, $FF, $0E, $E0, $80, $FF
    DB      $0E

SUB_A918:                                  ; SUB_A918: hostage entity state machine (idle/walk/pickup/drop)
    LD      IY, $72DC                   ; RAM $72DC
    BIT     1, (IY+0)
    JR      Z, LOC_A934

LOC_A922:
    LD      IX, $72E0                   ; RAM $72E0
    CALL    SUB_A972
    LD      IY, $72DC                   ; RAM $72DC
    LD      IX, $72ED                   ; RAM $72ED
    JP      SUB_A972

LOC_A934:
    CALL    SUB_A99A
    BIT     0, (IY+0)
    RET     Z
    RES     0, (IY+0)
    BIT     2, (IY+0)
    RET     Z
    LD      A, ($70C0)                  ; RAM $70C0
    AND     A
    RET     Z
    LD      HL, ($7044)                 ; RAM $7044
    DEC     H
    LD      A, ($7173)                  ; RAM $7173
    ADD     A, $10
    RST     $18
    LD      (IY+1), L
    LD      (IY+2), H
    LD      DE, $1096
    DB      $EB
    RST     $20
    LD      A, L
    SRL     A
    SRL     A
    INC     A
    LD      (IY+3), A
    SET     1, (IY+0)
    CALL    SUB_8D33
    JP      LOC_A922

SUB_A972:
    LD      A, (IX+8)
    CP      $06
    JP      NZ, LOC_AA1C
    BIT     0, (IY+0)
    JR      NZ, LOC_A986
    BIT     2, (IY+0)
    JR      NZ, LOC_A9CE

LOC_A986:
    LD      A, ($72E8)                  ; RAM $72E8
    CP      $06
    RET     NZ
    LD      A, ($72F5)                  ; RAM $72F5
    CP      $06
    RET     NZ
    RES     1, (IY+0)
    CALL    SUB_A9A0
    RET     

SUB_A99A:
    LD      A, ($715A)                  ; RAM $715A
    BIT     2, A
    RET     NZ

SUB_A9A0:
    CALL    SUB_8575
    LD      HL, $70BC                   ; RAM $70BC
    LD      A, ($70BE)                  ; RAM $70BE
    JR      Z, LOC_A9B1
    LD      HL, $70BD                   ; RAM $70BD
    LD      A, ($70BF)                  ; RAM $70BF

LOC_A9B1:
    LD      B, A
    ADD     A, (HL)
    CP      $40
    RET     C
    LD      A, B
    AND     A
    JR      NZ, LOC_A9C4
    POP     AF
    POP     AF
    LD      B, $1E
    CALL    DELAY_LOOP_8ADE
    JP      LOC_8239

LOC_A9C4:
    POP     AF
    POP     AF
    LD      B, $1E
    CALL    DELAY_LOOP_8ADE
    JP      LOC_8234

LOC_A9CE:
    LD      A, ($72E7)                  ; RAM $72E7
    AND     A
    JR      NZ, LOC_A9DA
    LD      A, ($72F4)                  ; RAM $72F4
    AND     A
    JR      Z, LOC_A9E2

LOC_A9DA:
    LD      B, A
    LD      A, (IY+3)
    SRL     A
    CP      B
    RET     C

LOC_A9E2:
    LD      A, ($70C0)                  ; RAM $70C0
    AND     A
    JR      Z, LOC_A986
    DEC     A
    LD      ($70C0), A                  ; RAM $70C0
    LD      HL, $70BC                   ; RAM $70BC
    LD      A, ($702F)                  ; RAM $702F
    BIT     0, A
    JR      Z, LOC_A9F9
    LD      HL, $70BD                   ; RAM $70BD

LOC_A9F9:
    INC     (HL)
    CALL    SUB_8B24
    LD      HL, $0004
    LD      (IX+8), L
    LD      (IX+9), H
    LD      L, (IY+1)
    LD      H, (IY+2)
    LD      (IX+1), L
    LD      (IX+2), H
    LD      A, (IY+3)
    LD      (IX+7), A
    LD      (IX+6), $01

LOC_AA1C:
    CALL    SUB_8788
    DEC     (IX+6)
    JR      NZ, LOC_AA77
    LD      A, (IX+7)
    DEC     A
    LD      (IX+7), A
    JP      Z, LOC_AAB1
    CP      $06
    JR      NZ, LOC_AA60
    LD      A, ($70C0)                  ; RAM $70C0
    AND     A
    JR      NZ, LOC_AA60
    LD      A, (IX+8)
    CP      $04
    JR      NZ, LOC_AA4E
    LD      (IX+10), $00
    LD      (IX+11), $01
    LD      HL, BOOT_UP
    LD      A, $08
    JR      LOC_AA53

LOC_AA4E:
    LD      HL, $0004
    LD      A, $06

LOC_AA53:
    LD      (IX+8), L
    LD      (IX+9), H
    LD      (IX+7), A
    LD      (IX+6), $01

LOC_AA60:
    LD      (IX+6), $06
    LD      C, (IX+8)
    LD      B, (IX+9)
    LD      L, (IX+1)
    LD      H, (IX+2)
    ADD     HL, BC
    LD      (IX+1), L
    LD      (IX+2), H

LOC_AA77:
    LD      A, (IX+8)
    CP      $04
    JR      Z, LOC_AA9C
    DEC     (IX+11)
    JR      NZ, LOC_AAAE
    LD      A, (IX+10)
    XOR     $01
    LD      (IX+10), A
    LD      (IX+11), $06
    LD      (IY+2), $88
    AND     A
    JR      Z, LOC_AAAE
    LD      (IY+2), $8C
    JR      LOC_AAAE

LOC_AA9C:
    LD      HL, ($7044)                 ; RAM $7044
    LD      E, (IX+1)
    LD      D, (IX+2)
    RST     $20
    LD      A, $04
    AND     L
    ADD     A, $90
    LD      (IY+2), A

LOC_AAAE:
    JP      LOC_8818

LOC_AAB1:
    LD      HL, $0006
    LD      (IX+8), L
    LD      (IX+9), H
    JP      LOC_88A2
    DB      $0C, $FF, $00, $FF, $FF, $00, $00, $FF
    DB      $00, $FF, $FF, $FF, $2C, $01, $E0, $80
    DB      $CC, $0C

SUB_AACF:                                  ; SUB_AACF: enemy tank AI (move, animate, collision check, fire)
    LD      IX, $731A                   ; RAM $731A
    LD      IY, $7078                   ; RAM $7078
    BIT     0, (IX+6)
    JR      Z, LOC_AB33
    BIT     2, (IX+6)
    JP      Z, LOC_ABA8
    DEC     (IX+7)
    JR      NZ, LOC_AAFF
    LD      (IX+7), $06
    LD      A, (IX+8)
    INC     A
    CP      $08
    JP      NC, LOC_ABC8
    LD      (IX+8), A
    LD      HL, $9D23
    CALL    SUB_9AD6

LOC_AAFF:
    CALL    SUB_9AB1
    JP      C, LOC_ABC8
    JP      Z, LOC_ABC8
    LD      B, A
    LD      A, $01
    BIT     7, (IX+10)
    JR      Z, LOC_AB13
    LD      A, $FF

LOC_AB13:
    BIT     5, (IX+6)
    JR      Z, LOC_AB1B
    NEG     

LOC_AB1B:
    ADD     A, B
    CP      $FC
    JP      NC, LOC_ABC8
    LD      (IY+1), A
    LD      A, (IY+0)
    INC     A
    LD      (IY+0), A
    CP      $88
    JP      NC, LOC_ABC8
    JP      LOC_ABE2

LOC_AB33:
    LD      HL, ($702C)                 ; RAM $702C
    LD      DE, $1C20
    RST     $20
    JR      NC, LOC_AB4D
    LD      HL, $70BC                   ; RAM $70BC
    CALL    SUB_8575
    JR      Z, LOC_AB47
    LD      HL, $70BD                   ; RAM $70BD

LOC_AB47:
    LD      A, (HL)
    LD      HL, $7151                   ; RAM $7151
    CP      (HL)
    RET     C

LOC_AB4D:
    LD      L, (IX+12)
    LD      H, (IX+13)
    DEC     HL
    LD      (IX+12), L
    LD      (IX+13), H
    LD      A, L
    OR      H
    RET     NZ
    LD      HL, $0001
    LD      (IX+12), L
    LD      (IX+13), H
    LD      HL, ($7044)                 ; RAM $7044
    LD      DE, $0FC0
    RST     $20
    RET     NC
    LD      (IX+6), $01
    LD      (IY+3), $0C
    LD      HL, ($714F)                 ; RAM $714F
    LD      (IX+12), L
    LD      (IX+13), H
    CALL    SUB_A225
    RES     5, (IX+6)
    JR      NC, LOC_AB8C
    SET     5, (IX+6)

LOC_AB8C:
    LD      (IX+1), E
    LD      (IX+2), D
    LD      A, ($7172)                  ; RAM $7172
    SUB     $28
    JR      NC, LOC_AB9D
    LD      A, $48
    JR      LOC_ABA1

LOC_AB9D:
    SRL     A
    ADD     A, $28

LOC_ABA1:
    LD      (IX+4), A
    XOR     A
    JP      LOC_AC6E

LOC_ABA8:
    LD      A, (IX+7)
    CP      $FF
    JR      Z, LOC_ABFF
    DEC     (IX+7)
    JP      Z, LOC_AC65

LOC_ABB5:
    CALL    SUB_AD41
    LD      A, $CC
    BIT     3, (IX+6)
    JR      Z, LOC_ABC2
    LD      A, $D0

LOC_ABC2:
    LD      (IY+2), A
    JP      LOC_8818

LOC_ABC8:
    LD      (IX+6), $00
    JP      LOC_88A2

SOUND_WRITE_ABCF:
    CALL    SOUND_WRITE_8CDA
    SET     2, (IX+6)
    LD      (IX+8), $FF
    LD      (IX+7), $01
    LD      (IY+3), $00

LOC_ABE2:
    JP      LOC_88AA

SUB_ABE5:
    LD      HL, ($7044)                 ; RAM $7044
    DEC     H
    LD      A, ($7173)                  ; RAM $7173
    RST     $18
    DB      $EB
    LD      L, (IX+1)
    LD      H, (IX+2)
    BIT     5, (IX+6)
    JR      Z, LOC_ABFB
    DB      $EB

LOC_ABFB:
    AND     A
    SBC     HL, DE
    RET     

LOC_ABFF:
    LD      A, (IX+8)
    AND     A
    JR      Z, LOC_AC48
    BIT     6, (IX+6)
    JR      NZ, LOC_AC65
    CALL    SUB_ABE5
    JR      C, LOC_AC65
    PUSH    HL
    BIT     5, (IX+6)
    JR      NZ, LOC_AC2D
    LD      DE, $0038
    CALL    SUB_854C
    CP      $C0
    JR      NC, LOC_AC41
    LD      DE, $0048
    CP      $60
    JR      NC, LOC_AC41
    LD      DE, $0028
    JR      LOC_AC41

LOC_AC2D:
    LD      DE, $0028
    CALL    SUB_854C
    CP      $C0
    JR      NC, LOC_AC41
    LD      DE, $0038
    CP      $60
    JR      NC, LOC_AC41
    LD      DE, $0018

LOC_AC41:
    POP     HL
    RST     $20
    JR      C, LOC_AC65

LOC_AC45:
    JP      LOC_ABB5

LOC_AC48:
    LD      L, (IX+1)
    LD      H, (IX+2)
    LD      DE, $0E8C
    RST     $20
    JR      C, LOC_AC5A
    SET     6, (IX+6)
    JR      LOC_AC65

LOC_AC5A:
    CALL    SUB_ABE5
    JR      C, LOC_AC45
    LD      DE, $0040
    RST     $20
    JR      C, LOC_AC45

LOC_AC65:
    LD      A, (IX+8)
    INC     A
    CP      $0C
    JP      NC, LOC_ABC8

LOC_AC6E:
    LD      (IX+8), A
    PUSH    AF
    ADD     A, A
    LD      HL, $AD8E
    RST     $10
    CALL    SUB_AD2A
    INC     HL
    LD      A, (HL)
    LD      (IX+11), A
    LD      (IX+3), $10
    POP     AF
    CP      $04
    PUSH    AF
    CALL    Z, SUB_8D19
    POP     AF
    CP      $01
    JR      NZ, LOC_ACAE
    RES     7, (IX+6)
    LD      A, ($7172)                  ; RAM $7172
    SUB     (IX+4)
    JR      NC, LOC_AC9F
    SET     7, (IX+6)

LOC_AC9F:
    CALL    SUB_854C
    CP      $80
    JR      NC, LOC_ACAE
    LD      A, $80
    XOR     (IX+6)
    LD      (IX+6), A

LOC_ACAE:
    BIT     7, (IX+6)
    JR      Z, LOC_ACBC
    LD      A, (IX+9)
    NEG     
    LD      (IX+9), A

LOC_ACBC:
    LD      A, ($716F)                  ; RAM $716F
    CP      $07
    JR      C, LOC_ACCB
    LD      A, (IX+10)
    SLA     A
    LD      (IX+10), A

LOC_ACCB:
    LD      A, (IX+8)
    LD      B, $0F
    CP      $07
    JR      Z, LOC_ACDA
    LD      B, $07
    CP      $05
    JR      NZ, LOC_ACE4

LOC_ACDA:
    CALL    SUB_854C
    AND     B
    ADD     A, (IX+7)
    LD      (IX+7), A

LOC_ACE4:
    LD      A, (IX+11)
    RES     7, A
    LD      HL, $AD78
    RST     $10
    LD      A, (HL)
    INC     HL
    LD      H, (HL)
    LD      L, A
    LD      A, $08
    XOR     (IX+6)
    LD      (IX+6), A
    LD      DE, $00CC
    BIT     3, (IX+6)
    JR      Z, LOC_AD05
    LD      DE, $00D0

LOC_AD05:
    BIT     7, (IX+11)
    JR      NZ, LOC_AD16
    BIT     5, (IX+6)
    JR      NZ, LOC_AD1C

LOC_AD11:
    CALL    SUB_84F7
    JR      LOC_AD1F

LOC_AD16:
    BIT     5, (IX+6)
    JR      NZ, LOC_AD11

LOC_AD1C:
    CALL    LOC_8517

LOC_AD1F:
    LD      A, (IX+8)
    CP      $05
    CALL    Z, SUB_ADC4
    JP      LOC_ABB5

SUB_AD2A:
    LD      A, (HL)
    LD      (IX+9), A
    INC     HL
    LD      A, (HL)
    BIT     5, (IX+6)
    JR      Z, LOC_AD38
    NEG     

LOC_AD38:
    LD      (IX+10), A
    INC     HL
    LD      A, (HL)
    LD      (IX+7), A
    RET     

SUB_AD41:
    LD      B, $27
    LD      A, (IX+0)
    CP      $0C
    JR      Z, LOC_AD4C
    LD      B, $26

LOC_AD4C:
    LD      A, (IX+4)
    ADD     A, (IX+9)
    CP      B
    JR      NC, LOC_AD5B
    LD      (IX+9), $00
    JR      LOC_AD5E

LOC_AD5B:
    LD      (IX+4), A

LOC_AD5E:
    LD      A, (IX+10)
    LD      D, $00
    BIT     7, A
    JR      Z, LOC_AD69
    LD      D, $FF

LOC_AD69:
    LD      E, A
    LD      L, (IX+1)
    LD      H, (IX+2)
    ADD     HL, DE
    LD      (IX+1), L
    LD      (IX+2), H
    RET     
    DB      $30, $BA, $42, $BA, $62, $BA, $7A, $BA
    DB      $8A, $BA, $AC, $BA, $CD, $BA, $E9, $BA
    DB      $0A, $BB, $25, $BB, $38, $BB, $00, $05
    DB      $FF, $00, $01, $02, $18, $01, $02, $02
    DB      $02, $02, $00, $00, $01, $03, $02, $FE
    DB      $02, $84, $01, $FE, $02, $85, $00, $FB
    DB      $FF, $87, $00, $FC, $28, $87, $FF, $FE
    DB      $08, $86, $FF, $FE, $06, $88, $FF, $FE
    DB      $04, $89, $FF, $FE, $04, $8A

SUB_ADBE:
    XOR     A
    LD      ($732E), A                  ; RAM $732E
    JR      LOC_ADF5

SUB_ADC4:
    PUSH    IX
    LD      DE, $7328                   ; RAM $7328
    LD      HL, $AE01
    LD      BC, $000B
    LDIR    
    LD      IX, $7328                   ; RAM $7328
    LD      HL, $7320                   ; RAM $7320
    BIT     5, (HL)
    JR      Z, LOC_ADE0
    SET     5, (IX+6)

LOC_ADE0:
    CALL    SUB_AF0B
    LD      HL, ($731B)                 ; RAM $731B
    LD      (IX+1), L
    LD      (IX+2), H
    LD      A, ($731E)                  ; RAM $731E
    DEC     A
    LD      (IX+4), A
    POP     IX

LOC_ADF5:
    LD      HL, $AE0A
    LD      DE, $7074                   ; RAM $7074
    LD      BC, $0004
    LDIR    
    RET     
    DB      $0B, $FF, $00, $0E, $FF, $00, $01, $FF
    DB      $00, $E0, $80, $E4, $06

SUB_AE0E:                                  ; SUB_AE0E: boss/special enemy logic (spawn, move, fire pattern)
    LD      IX, $7328                   ; RAM $7328
    LD      IY, $7074                   ; RAM $7074
    BIT     0, (IX+6)
    RET     Z
    BIT     2, (IX+6)
    JP      NZ, LOC_AEA9
    LD      A, (IX+8)
    AND     A
    JP      Z, LOC_AED0
    CP      $01
    JP      Z, LOC_AEED
    DEC     (IX+7)
    JR      NZ, LOC_AE4D
    INC     A
    CP      $06
    JR      NC, LOC_AE4D
    LD      (IX+8), A
    CALL    SUB_AF0B

LOC_AE3E:
    LD      A, (IX+8)
    SUB     $02
    LD      B, A
    ADD     A, A
    ADD     A, B
    LD      HL, $AF2F
    RST     $18
    CALL    SUB_AD2A

LOC_AE4D:
    CALL    SUB_AD41
    CALL    LOC_8818
    LD      A, (IY+0)
    CP      $E0
    RET     Z
    CALL    SUB_AE86
    ADD     A, $05
    LD      ($7351), A                  ; RAM $7351
    LD      A, $06
    LD      ($7350), A                  ; RAM $7350
    LD      A, $0B
    LD      ($7352), A                  ; RAM $7352
    LD      A, (IX+4)
    LD      B, A
    ADD     A, $05
    LD      ($7353), A                  ; RAM $7353
    LD      A, B
    CP      $90
    JR      C, LOC_AE80
    CALL    SUB_9B4F
    CALL    SOUND_WRITE_AE94
    RET     

LOC_AE80:
    CALL    SUB_9B0C
    JR      NZ, LOC_AECD
    RET     

SUB_AE86:
    LD      HL, ($7044)                 ; RAM $7044
    LD      E, (IX+1)
    LD      D, (IX+2)
    RST     $20
    LD      A, $FE
    SUB     L
    RET     

SOUND_WRITE_AE94:
    CALL    SOUND_WRITE_8CE5
    SET     2, (IX+6)
    LD      (IX+8), $FF
    LD      (IX+7), $01
    LD      (IY+3), $00
    JR      LOC_AECA

LOC_AEA9:
    DEC     (IX+7)
    JR      NZ, LOC_AEC0
    LD      (IX+7), $06
    LD      A, (IX+8)
    INC     A
    CP      $07
    JR      NC, LOC_AECD
    LD      (IX+8), A
    CALL    SUB_9AD3

LOC_AEC0:
    CALL    SUB_9AB1
    JR      C, LOC_AECD
    JR      Z, LOC_AECD
    LD      (IY+1), A

LOC_AECA:
    JP      LOC_88AA

LOC_AECD:
    JP      LOC_ABC8

LOC_AED0:
    LD      A, ($7322)                  ; RAM $7322
    CP      $05
    JR      Z, LOC_AEDE
    LD      (IX+8), $01
    CALL    SUB_AF0B

LOC_AEDE:
    LD      A, ($7323)                  ; RAM $7323
    LD      (IX+9), A
    LD      A, ($7324)                  ; RAM $7324
    LD      (IX+10), A
    JP      LOC_AE4D

LOC_AEED:
    LD      A, ($7322)                  ; RAM $7322
    CP      $07
    JR      C, LOC_AEDE
    CP      $08
    JR      Z, LOC_AF04
    LD      A, ($7172)                  ; RAM $7172
    CP      $70
    JR      NC, LOC_AF04
    SUB     (IX+4)
    JR      C, LOC_AEDE

LOC_AF04:
    LD      (IX+8), $02
    JP      LOC_AE3E

SUB_AF0B:
    LD      A, (IX+8)
    LD      HL, $AF23
    RST     $10
    LD      A, (HL)
    INC     HL
    LD      H, (HL)
    LD      L, A
    LD      DE, $00E4
    BIT     5, (IX+6)
    JP      NZ, LOC_8517
    JP      SUB_84F7
    DB      $CE, $BB, $DB, $BB, $DB, $BB, $EC, $BB
    DB      $FF, $BB, $12, $BC, $01, $FA, $04, $01
    DB      $FC, $04, $02, $FC, $08, $02, $FC, $FF
    DB      $09, $00, $87, $01, $03, $07, $0F, $1F
    DB      $3F, $7F, $08, $FF, $88, $00, $80, $C0
    DB      $E0, $F0, $F8, $FC, $FE, $04, $00, $04
    DB      $0F, $04, $00, $04, $FF, $04, $00, $04
    DB      $F0, $08, $FF, $04, $0F, $04, $00, $04
    DB      $FF, $04, $00, $04, $F0, $04, $00, $08
    DB      $F0, $08, $0F, $BA, $FF, $FC, $F0, $C0
    DB      $C0, $F0, $FC, $FF, $FF, $3F, $0F, $03
    DB      $03, $0F, $3F, $FF, $00, $18, $3C, $7E
    DB      $7E, $34, $18, $00, $00, $18, $3C, $7E
    DB      $7E, $34, $18, $00, $00, $18, $3C, $7E
    DB      $7E, $34, $18, $00, $03, $0F, $1F, $3E
    DB      $7D, $7A, $FF, $EA, $C0, $F0, $D8, $6C
    DB      $54, $EA, $55, $3A, $00, $40, $0B, $00
    DB      $01, $04, $03, $00, $01, $40, $0B, $00
    DB      $83, $04, $00, $00, $FF, $08, $00, $92
    DB      $F5, $FA, $75, $6F, $35, $1E, $0D, $03
    DB      $5D, $AA, $D0, $AA, $44, $A8, $70, $C0
    DB      $00, $40, $0B, $00, $01, $04, $03, $00
    DB      $01, $40, $0B, $00, $01, $04, $05, $00
    DB      $04, $FF, $01, $00, $04, $FF, $04, $00
    DB      $05, $20, $98, $00, $20, $00, $20, $A8
    DB      $70, $20, $70, $A8, $20, $00, $50, $50
    DB      $F8, $50, $F8, $50, $50, $00, $00, $00
    DB      $F8, $00, $F8, $03, $00, $FF, $08, $00
    DB      $08, $FF, $06, $00, $84, $FF, $FF, $00
    DB      $40, $0B, $00, $01, $04, $03, $00, $01
    DB      $40, $0B, $00, $01, $04, $04, $00, $A6
    DB      $01, $0A, $55, $AA, $FF, $FF, $00, $20
    DB      $50, $A8, $55, $AA, $FF, $FF, $00, $08
    DB      $54, $AA, $55, $AA, $FF, $FF, $00, $20
    DB      $54, $AA, $55, $AA, $FF, $FF, $00, $08
    DB      $15, $2A, $55, $AA, $FF, $FF, $03, $00
    DB      $85, $A0, $54, $AA, $FF, $FF, $04, $00
    DB      $AC, $05, $0A, $FF, $FF, $00, $02, $15
    DB      $AA

; ============================================================
; GAME DATA  ($B054 - $BBFF)
; Animation, sprite, level, and name-table data.
; (Tracer did not reach this area via static flow; kept as DB.)
; ============================================================
GAME_DATA:                                 ; GAME_DATA: RLE-encoded sprite data (level backgrounds, objects)
    DB      $55, $AA, $FF, $FF, $00, $00, $05, $8A
    DB      $55, $AA, $FF, $FF, $00, $82, $45, $AA
    DB      $55, $AA, $FF, $FF, $00, $00, $41, $A2
    DB      $55, $AA, $FF, $FF, $00, $80, $50, $AA
    DB      $55, $AA, $FF, $FF, $04, $00, $84, $40
    DB      $A0, $FF, $FF, $05, $00, $83, $03, $0C
    DB      $33, $03, $00, $85, $3C, $C3, $3C, $C3
    DB      $C3, $05, $00, $83, $C0, $30, $CC, $07
    DB      $00, $01, $03, $03, $00, $85, $03, $0C
    DB      $33, $CC, $3C, $03, $00, $85, $C0, $30
    DB      $CC, $33, $3C, $07, $00, $01, $C0, $8D
    DB      $CF, $3F, $7E, $7D, $7A, $74, $71, $73
    DB      $D3, $03, $43, $01, $5B, $03, $DB, $82
    DB      $F3, $FC, $06, $FE, $82, $0C, $03, $06
    DB      $07, $88, $FD, $F0, $E4, $D0, $A5, $4D
    DB      $1D, $3D, $03, $3F, $01, $1F, $04, $BF
    DB      $82, $30, $C0, $06, $E0, $8C, $CF, $3F
    DB      $7D, $76, $79, $7E, $7C, $7A, $45, $81
    DB      $83, $80, $04, $00, $9C, $CB, $9C, $3E
    DB      $66, $0E, $3E, $0E, $1E, $F4, $F8, $D8
    DB      $68, $90, $E0, $C0, $A0, $5C, $19, $33
    DB      $06, $00, $03, $00, $01, $B0, $C0, $E0
    DB      $60, $04, $E0, $04, $00, $87, $03, $0F
    DB      $3F, $FF, $03, $0F, $3F, $0D, $FF, $83
    DB      $C0, $F0, $FC, $05, $FF, $04, $00, $84
    DB      $C0, $F0, $FC, $FF, $06, $00, $8B, $03
    DB      $0F, $00, $00, $03, $0F, $3F, $FF, $FF
    DB      $FF, $3F, $07, $FF, $01, $FC, $07, $FF
    DB      $85, $00, $00, $C0, $F0, $FC, $03, $FF
    DB      $06, $00, $82, $C0, $F0, $85, $FF, $C0
    DB      $3F, $83, $FC, $03, $FF, $01, $00, $03
    DB      $FF, $01, $00, $04, $FF, $84, $03, $FC
    DB      $C1, $3F, $03, $FF, $84, $FF, $FC, $F3
    DB      $F8, $04, $FF, $8D, $F0, $0F, $FF, $3F
    DB      $C0, $FF, $FF, $FF, $0F, $F0, $FF, $FC
    DB      $03, $04, $FF, $83, $3F, $CF, $1F, $04
    DB      $FF, $85, $FF, $FC, $F0, $C0, $00, $03
    DB      $FF, $05, $00, $03, $FF, $85, $FF, $3F
    DB      $0F, $03, $00, $03, $FF, $03, $FF, $82
    DB      $FC, $F0, $03, $FF, $85, $F0, $C0, $00
    DB      $00, $00, $03, $FF, $82, $0F, $03, $03
    DB      $00, $06, $FF, $82, $3F, $0F, $03, $FF
    DB      $92, $AA, $FF, $C3, $C3, $C3, $D3, $C3
    DB      $C3, $AA, $FF, $1C, $1C, $1C, $FD, $FC
    DB      $FC, $AA, $FF, $03, $38, $03, $3F, $82
    DB      $AA, $FF, $03, $81, $03, $FF, $82, $0A
    DB      $0F, $03, $08, $03, $0F, $82, $AA, $FF
    DB      $03, $18, $03, $FF, $82, $A0, $F0, $03
    DB      $10, $03, $F0, $06, $00, $82, $3F, $FF
    DB      $06, $00, $02, $FF, $01, $07, $05, $04
    DB      $03, $FF, $05, $00, $82, $FC, $FF, $06
    DB      $00, $83, $03, $0F, $7F, $05, $40, $02
    DB      $FF, $01, $F0, $05, $00, $82, $C0, $F0
    DB      $84, $05, $06, $05, $06, $04, $07, $84
    DB      $5F, $BF, $5F, $BF, $04, $FF, $84, $55
    DB      $6B, $55, $6B, $04, $7F, $08, $F0, $90
    DB      $00, $1F, $3F, $7F, $3F, $19, $0F, $06
    DB      $00, $F8, $FC, $FE, $FC, $98, $F0, $60
    DB      $86, $00, $01, $03, $07, $03, $01, $03
    DB      $00, $85, $80, $C0, $E0, $C0, $80, $02
    DB      $00, $A0, $00, $1F, $3F, $7F, $3F, $06
    DB      $0F, $19, $00, $F8, $FC, $FE, $FC, $60
    DB      $F0, $98, $00, $01, $03, $07, $03, $00
    DB      $00, $01, $00, $80, $C0, $E0, $C0, $00
    DB      $00, $80, $98, $0F, $3F, $FF, $FF, $FF
    DB      $99, $FF, $66, $F0, $F8, $FF, $FF, $FF
    DB      $99, $FF, $66, $00, $03, $FF, $FF, $FF
    DB      $99, $FF, $66, $05, $FF, $85, $99, $FF
    DB      $66, $00, $80, $03, $FF, $83, $99, $FF
    DB      $66, $82, $0F, $3F, $03, $FF, $85, $66
    DB      $FF, $99, $F0, $F8, $03, $FF, $83, $66
    DB      $FF, $99, $82, $00, $03, $03, $FF, $83
    DB      $66, $FF, $99, $05, $FF, $85, $66, $FF
    DB      $99, $00, $80, $03, $FF, $83, $66, $FF
    DB      $99, $04, $00, $8C, $7F, $F7, $F7, $F7
    DB      $00, $03, $07, $0E, $F4, $F8, $FC, $FC
    DB      $04, $00, $01, $07, $03, $0F, $04, $00
    DB      $94, $FF, $7F, $7F, $7F, $00, $30, $70
    DB      $E0, $40, $80, $C0, $C0, $00, $C0, $E0
    DB      $70, $2F, $1F, $3F, $3F, $04, $00, $8C
    DB      $FE, $EF, $EF, $EF, $00, $0C, $0E, $07
    DB      $02, $01, $03, $03, $04, $00, $01, $FF
    DB      $03, $FE, $04, $00, $01, $E0, $03, $F0
    DB      $04, $01, $84, $0F, $3F, $37, $37, $04
    DB      $80, $84, $F0, $FC, $EC, $EC, $05, $00
    DB      $03, $03, $04, $18, $84, $FF, $FF, $7E
    DB      $7E, $05, $00, $03, $C0, $90, $18, $18
    DB      $70, $9C, $38, $64, $C4, $80, $01, $01
    DB      $01, $03, $03, $01, $02, $00, $02, $80
    DB      $02, $00, $04, $80, $88, $18, $18, $0E
    DB      $39, $1C, $26, $23, $01, $02, $01, $02
    DB      $00, $04, $01, $03, $80, $02, $C0, $AB
    DB      $80, $40, $00, $C0, $C0, $00, $E0, $D0
    DB      $C0, $20, $20, $2C, $2C, $10, $1E, $0D
    DB      $0C, $12, $12, $02, $02, $01, $01, $00
    DB      $00, $01, $01, $0C, $4C, $20, $1E, $0D
    DB      $0C, $12, $12, $00, $04, $02, $01, $00
    DB      $00, $01, $01, $FF, $81, $71, $83, $C1
    DB      $89, $D6, $83, $D1, $81, $C1, $81, $61
    DB      $82, $E1, $02, $61, $61, $61, $61, $61
    DB      $61, $61, $61, $0C, $E1, $E1, $E1, $E1
    DB      $E1, $E1, $E1, $E1, $FF, $81, $71, $82
    DB      $E1, $84, $E1, $82, $D1, $A8, $F1, $FF
    DB      $81, $71, $82, $51, $84, $E1, $0D, $D1
    DB      $D1, $D1, $D1, $D1, $D1, $51, $51, $87
    DB      $C1, $07, $C1, $C1, $C1, $C1, $C1, $C1
    DB      $C5, $15, $06, $C1, $C1, $C1, $C1, $C1
    DB      $C1, $C5, $15, $8B, $65, $07, $6A, $6A
    DB      $6A, $6A, $6A, $65, $65, $65, $07, $6E
    DB      $6E, $6E, $6E, $6E, $65, $65, $65, $03
    DB      $D0, $D0, $D1, $D1, $D1, $D1, $D1, $D1
    DB      $04, $D0, $D0, $D1, $D1, $D1, $D1, $D5
    DB      $D5, $07, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $E0, $F0, $84, $F0, $08, $15, $95, $65
    DB      $65, $15, $75, $15, $75, $0A, $15, $89
    DB      $65, $65, $15, $75, $15, $75, $0F, $65
    DB      $65, $65, $65, $95, $85, $85, $65, $0B
    DB      $E1, $E1, $E1, $E1, $E1, $E1, $E5, $E5
    DB      $FF, $26, $02, $00, $01, $1D, $00, $03
    DB      $22, $00, $04, $3D, $00, $06, $42, $00
    DB      $0C, $5D, $00, $0B, $62, $00, $08, $7D
    DB      $00, $0A, $F9, $00, $12, $FA, $00, $13
    DB      $19, $01, $01, $1A, $01, $02, $B1, $00
    DB      $15, $C5, $00, $17, $D7, $00, $16, $ED
    DB      $00, $15, $FD, $00, $16, $01, $02, $03
    DB      $07, $02, $04, $0D, $02, $03, $12, $02
    DB      $06, $39, $02, $04, $45, $00, $0D, $46
    DB      $00, $0F, $49, $00, $0E, $4D, $00, $0D
    DB      $4E, $00, $10, $51, $00, $0E, $56, $00
    DB      $0D, $57, $00, $11, $5A, $00, $0E, $07
    DB      $01, $04, $42, $01, $04, $58, $01, $04
    DB      $8F, $01, $03, $A6, $01, $03, $94, $01
    DB      $06, $DB, $01, $05, $89, $01, $46, $09
    DB      $06, $99, $66, $99, $66, $99, $07, $00
    DB      $89, $80, $40, $80, $40, $80, $40, $80
    DB      $40, $80, $07, $00, $89, $06, $01, $06
    DB      $01, $66, $99, $66, $99, $66, $07, $00
    DB      $89, $40, $80, $40, $80, $40, $80, $40
    DB      $80, $40, $07, $00, $8F, $02, $02, $01
    DB      $02, $01, $05, $07, $07, $0A, $03, $0E
    DB      $31, $C2, $00, $08, $03, $00, $8E, $20
    DB      $90, $A0, $60, $D0, $F0, $E0, $80, $30
    DB      $44, $01, $10, $00, $00, $8F, $01, $00
    DB      $02, $03, $05, $03, $05, $0B, $0F, $03
    DB      $0E, $31, $C2, $00, $08, $02, $00, $8D
    DB      $80, $80, $20, $20, $68, $E8, $E0, $D0
    DB      $C0, $30, $44, $01, $10, $0E, $00, $01
    DB      $02, $03, $01, $0C, $00, $01, $40, $03
    DB      $80, $09, $00, $87, $04, $07, $02, $03
    DB      $03, $02, $02, $09, $00, $87, $20, $E0
    DB      $40, $C0, $C0, $40, $40, $87, $18, $1F
    DB      $0F, $06, $06, $07, $07, $03, $06, $06
    DB      $00, $87, $18, $F8, $F0, $60, $60, $E0
    DB      $E0, $03, $60, $06, $00, $88, $38, $3F
    DB      $3F, $1C, $0C, $0C, $0F, $0F, $05, $0C
    DB      $03, $00, $88, $1C, $FC, $FC, $38, $30
    DB      $30, $F0, $F0, $05, $30, $03, $00, $87
    DB      $E0, $FF, $FF, $7F, $3C, $1C, $1C, $03
    DB      $1F, $06, $1C, $87, $07, $FF, $FF, $FE
    DB      $3C, $38, $38, $03, $F8, $06, $38, $02
    DB      $C0, $1E, $00, $88, $58, $58, $20, $3C
    DB      $1A, $18, $24, $24, $18, $00, $88, $18
    DB      $98, $40, $3C, $1A, $18, $24, $24, $18
    DB      $00, $88, $18, $18, $70, $9C, $38, $64
    DB      $C4, $80, $08, $00, $10, $00, $88, $18
    DB      $18, $10, $30, $38, $18, $28, $08, $08
    DB      $00, $10, $00, $FF, $0F, $00, $81, $FF
    DB      $0F, $00, $81, $FE, $04, $00, $8C, $07
    DB      $08, $11, $63, $7F, $1F, $07, $20, $11
    DB      $0F, $00, $00, $90, $05, $03, $1F, $3D
    DB      $FE, $FF, $E4, $E4, $FF, $FF, $FF, $81
    DB      $C3, $FF, $00, $00, $0F, $00, $81, $FF
    DB      $0F, $00, $81, $FE, $90, $40, $80, $C0
    DB      $70, $70, $C0, $FF, $FF, $FF, $F8, $80
    DB      $00, $44, $F8, $00, $00, $88, $01, $06
    DB      $06, $0E, $1E, $FC, $F8, $E0, $08, $00
    DB      $FF, $10, $00, $0F, $00, $81, $FE, $04
    DB      $00, $8C, $07, $08, $11, $63, $7F, $1F
    DB      $07, $20, $11, $0F, $00, $00, $90, $03
    DB      $03, $1F, $3D, $FE, $FF, $E4, $E4, $FF
    DB      $FF, $FF, $81, $C3, $FF, $00, $00, $0F
    DB      $00, $81, $FE, $10, $00, $90, $80, $80
    DB      $C0, $70, $70, $C0, $FF, $FF, $FF, $F8
    DB      $80, $00, $44, $F8, $00, $00, $88, $10
    DB      $0C, $06, $0E, $0F, $FC, $F8, $E0, $08
    DB      $00, $FF, $10, $00, $0F, $00, $81, $03
    DB      $04, $00, $8C, $07, $08, $11, $63, $7F
    DB      $1F, $07, $20, $11, $0F, $00, $00, $90
    DB      $01, $03, $1F, $3D, $FE, $FF, $E4, $E4
    DB      $FF, $FF, $FF, $81, $C3, $FF, $00, $00
    DB      $0F, $00, $81, $80, $10, $00, $90, $00
    DB      $80, $C0, $70, $70, $C0, $FF, $FF, $FF
    DB      $F8, $80, $00, $44, $F8, $00, $00, $88
    DB      $01, $06, $06, $0E, $1E, $FC, $F8, $E0
    DB      $08, $00, $FF, $0F, $00, $81, $FF, $0F
    DB      $00, $81, $FE, $0B, $00, $85, $02, $03
    DB      $01, $00, $00, $90, $05, $03, $0F, $1F
    DB      $23, $41, $80, $B8, $DF, $FF, $77, $29
    DB      $4C, $F7, $00, $00, $0F, $00, $81, $FF
    DB      $0F, $00, $81, $FE, $90, $40, $82, $C3
    DB      $E3, $F7, $6F, $AE, $BC, $F8, $F0, $C0
    DB      $20, $90, $F8, $00, $00, $10, $00, $FF
    DB      $10, $00, $0F, $00, $81, $FE, $0B, $00
    DB      $85, $02, $03, $01, $00, $00, $90, $03
    DB      $03, $0F, $1F, $23, $41, $80, $B8, $DF
    DB      $FF, $77, $29, $4C, $F7, $00, $00, $0F
    DB      $00, $81, $FE, $10, $00, $90, $80, $82
    DB      $C3, $E3, $F7, $6F, $AE, $BC, $F8, $F0
    DB      $C0, $20, $90, $F8, $00, $00, $10, $00
    DB      $FF, $10, $00, $0F, $00, $81, $03, $0B
    DB      $00, $85, $02, $03, $01, $00, $00, $90
    DB      $01, $03, $0F, $1F, $23, $41, $80, $B8
    DB      $DF, $FF, $77, $29, $4C, $F7, $00, $00
    DB      $0F, $00, $81, $80, $10, $00, $90, $00
    DB      $82, $C3, $E3, $F7, $6F, $AE, $BC, $F8
    DB      $F0, $C0, $20, $90, $F8, $00, $00, $10
    DB      $00, $FF, $10, $00, $0E, $00, $82, $03
    DB      $06, $02, $00, $8E, $03, $0C, $30, $C0
    DB      $00, $01, $02, $02, $02, $06, $0F, $07
    DB      $00, $00, $90, $3B, $C7, $07, $0C, $1F
    DB      $1F, $79, $B9, $3F, $3F, $7F, $FE, $F8
    DB      $EE, $0F, $F8, $0A, $00, $86, $03, $0C
    DB      $30, $C0, $00, $80, $08, $00, $88, $30
    DB      $C8, $18, $18, $18, $18, $38, $78, $90
    DB      $A0, $F1, $A7, $FF, $FF, $3E, $3E, $F8
    DB      $F8, $F0, $9B, $3C, $30, $C0, $00, $00
    DB      $84, $F0, $E0, $C0, $80, $04, $00, $82
    DB      $80, $80, $06, $00, $FF, $10, $00, $0E
    DB      $00, $82, $03, $07, $07, $00, $89, $01
    DB      $02, $02, $02, $06, $0F, $07, $00, $00
    DB      $90, $3F, $C7, $07, $0C, $1F, $1F, $79
    DB      $B9, $3F, $3F, $7F, $FE, $F8, $EE, $0F
    DB      $F8, $0C, $00, $84, $30, $C0, $00, $00
    DB      $0A, $00, $86, $10, $78, $18, $18, $38
    DB      $78, $90, $A0, $F1, $A7, $FF, $FF, $3E
    DB      $3E, $F8, $F8, $F0, $9B, $3C, $30, $C0
    DB      $00, $00, $84, $F0, $E0, $C0, $80, $04
    DB      $00, $82, $80, $80, $06, $00, $FF, $10
    DB      $00, $0E, $00, $82, $03, $06, $07, $00
    DB      $89, $01, $02, $02, $02, $06, $0F, $07
    DB      $00, $00, $90, $03, $07, $07, $0C, $1F
    DB      $1F, $79, $B9, $3F, $3F, $7F, $FE, $F8
    DB      $EE, $0F, $F8, $10, $00, $09, $00, $87
    DB      $08, $18, $18, $18, $18, $38, $78, $90
    DB      $A0, $F1, $A7, $FF, $FF, $3E, $3E, $F8
    DB      $F8, $F0, $9B, $3C, $30, $C0, $00, $00
    DB      $84, $F0, $E0, $C0, $80, $04, $00, $82
    DB      $80, $80, $06, $00, $FF, $0A, $00, $82
    DB      $0C, $03, $04, $00, $0C, $00, $84, $C0
    DB      $30, $0C, $03, $8C, $03, $6C, $70, $30
    DB      $3F, $9F, $5F, $47, $62, $1E, $07, $01
    DB      $04, $00, $90, $00, $CD, $7E, $FF, $FE
    DB      $CE, $C9, $F9, $FF, $7F, $1F, $8F, $78
    DB      $1C, $06, $01, $10, $00, $10, $00, $90
    DB      $80, $30, $DC, $E3, $E0, $D0, $B8, $D0
    DB      $E0, $F8, $FF, $FF, $7F, $01, $00, $C0
    DB      $04, $00, $8C, $C0, $30, $0C, $03, $00
    DB      $07, $3C, $FC, $F8, $E0, $00, $00, $FF
    DB      $10, $00, $0D, $00, $83, $30, $0C, $03
    DB      $8C, $03, $6C, $70, $30, $3F, $9F, $5F
    DB      $47, $62, $1E, $07, $01, $04, $00, $90
    DB      $00, $CD, $7E, $FF, $FE, $CE, $C9, $F9
    DB      $FF, $7F, $1F, $8F, $78, $1C, $06, $01
    DB      $10, $00, $10, $00, $90, $80, $B0, $CC
    DB      $E3, $E0, $D0, $B8, $D0, $E0, $F8, $FF
    DB      $FF, $7F, $01, $00, $C0, $07, $00, $89
    DB      $10, $08, $04, $3C, $FC, $F8, $E0, $00
    DB      $00, $FF, $10, $00, $10, $00, $8C, $03
    DB      $6C, $70, $30, $3F, $9F, $5F, $47, $62
    DB      $1E, $07, $01, $04, $00, $90, $00, $CD
    DB      $7E, $FF, $FE, $CE, $C9, $F9, $FF, $7F
    DB      $1F, $8F, $78, $1C, $06, $01, $10, $00
    DB      $10, $00, $90, $C0, $30, $C0, $E0, $E0
    DB      $D0, $B8, $D0, $E0, $F8, $FF, $FF, $7F
    DB      $01, $00, $C0, $09, $00, $87, $07, $3C
    DB      $FC, $F8, $E0, $00, $00, $FF, $0F, $00
    DB      $81, $FF, $0F, $00, $81, $FE, $10, $00
    DB      $8E, $05, $03, $07, $0F, $18, $30, $20
    DB      $23, $3E, $1F, $0F, $10, $20, $70, $11
    DB      $00, $81, $FF, $0F, $00, $81, $FE, $8E
    DB      $40, $80, $C0, $E0, $30, $18, $08, $88
    DB      $F8, $F0, $E0, $10, $08, $1C, $12, $00
    DB      $FF, $1F, $00, $81, $FE, $10, $00, $8E
    DB      $03, $03, $07, $0F, $18, $30, $20, $23
    DB      $3E, $1F, $0F, $10, $20, $70, $11, $00
    DB      $81, $FE, $10, $00, $8E, $80, $80, $C0
    DB      $E0, $30, $18, $08, $88, $F8, $F0, $E0
    DB      $10, $08, $1C, $12, $00, $FF, $1F, $00
    DB      $81, $03, $10, $00, $8E, $01, $03, $07
    DB      $0F, $18, $30, $20, $23, $3E, $1F, $0F
    DB      $10, $20, $70, $11, $00, $81, $80, $11
    DB      $00, $8D, $80, $C0, $E0, $30, $18, $08
    DB      $88, $F8, $F0, $E0, $10, $08, $1C, $12
    DB      $00, $FF, $10, $00, $10, $00, $04, $00
    DB      $84, $03, $0C, $30, $C0, $08, $00, $90
    DB      $02, $0D, $35, $C1, $03, $02, $04, $04
    DB      $04, $04, $07, $03, $00, $05, $03, $00
    DB      $0C, $00, $84, $03, $0C, $30, $C0, $09
    DB      $00, $83, $0C, $30, $C0, $04, $00, $90
    DB      $40, $04, $C6, $FE, $96, $0F, $07, $0E
    DB      $3E, $FE, $BF, $F7, $E1, $F0, $80, $00
    DB      $0B, $00, $82, $80, $C0, $03, $00, $FF
    DB      $10, $00, $10, $00, $10, $00, $90, $02
    DB      $0F, $31, $C1, $03, $02, $04, $04, $04
    DB      $04, $07, $03, $00, $05, $03, $00, $0D
    DB      $00, $83, $0C, $30, $C0, $10, $00, $90
    DB      $80, $04, $C6, $FE, $96, $0F, $07, $0E
    DB      $3E, $FE, $BF, $F7, $E1, $F0, $80, $00
    DB      $0B, $00, $82, $80, $C0, $03, $00, $FF
    DB      $10, $00, $10, $00, $10, $00, $90, $01
    DB      $03, $01, $01, $03, $02, $04, $04, $04
    DB      $04, $07, $03, $00, $05, $03, $00, $10
    DB      $00, $10, $00, $90, $80, $04, $C6, $FE
    DB      $96, $0F, $07, $0E, $3E, $FE, $BF, $F7
    DB      $E1, $F0, $80, $00, $0B, $00, $82, $80
    DB      $C0, $03, $00, $FF, $05, $00, $84, $30
    DB      $3C, $1F, $0F, $07, $00, $06, $00, $83
    DB      $38, $FE, $F0, $07, $00, $FF, $04, $03
    DB      $87, $13, $1B, $1F, $27, $1F, $1B, $13
    DB      $04, $03, $01, $00, $90, $80, $00, $00
    DB      $80, $80, $C0, $FC, $E6, $FC, $C0, $80
    DB      $80, $00, $00, $80, $00, $FF, $05, $00
    DB      $03, $01, $01, $07, $03, $01, $04, $00
    DB      $03, $60, $03, $70, $84, $7E, $F3, $F3
    DB      $FE, $03, $70, $03, $60, $FF, $08, $00
    DB      $01, $03, $07, $00, $06, $20, $84, $70
    DB      $98, $98, $70, $06, $20, $FF, $01, $00
    DB      $04, $01, $87, $0D, $0F, $07, $07, $0F
    DB      $0D, $09, $03, $01, $01, $00, $90, $C0
    DB      $80, $80, $C0, $C0, $C0, $F0, $FC, $FC
    DB      $F0, $C0, $C0, $C0, $80, $80, $C0, $FF
    DB      $90, $00, $07, $07, $07, $87, $C7, $FF
    DB      $7C, $7F, $FF, $C7, $87, $07, $07, $07
    DB      $00, $03, $00, $8A, $80, $80, $C0, $F8
    DB      $3F, $FF, $F8, $C0, $80, $80, $03, $00
    DB      $FF, $02, $00, $8A, $1E, $0F, $CF, $E7
    DB      $3F, $9F, $FC, $67, $03, $03, $04, $00
    DB      $04, $00, $87, $80, $C0, $F8, $FF, $3C
    DB      $C0, $80, $05, $00, $FF, $90, $00, $3F
    DB      $1F, $1F, $8F, $CF, $BF, $BF, $9F, $FC
    DB      $67, $23, $03, $03, $00, $00, $03, $00
    DB      $8A, $80, $C0, $F0, $FE, $FF, $FC, $10
    DB      $F0, $C0, $80, $03, $00, $FF, $02, $00
    DB      $03, $03, $85, $33, $3F, $1E, $3F, $33
    DB      $03, $03, $03, $00, $04, $00, $87, $80
    DB      $C0, $F0, $7C, $F0, $C0, $80, $05, $00
    DB      $FF, $04, $00, $87, $02, $03, $0B, $0F
    DB      $0B, $03, $02, $05, $00, $07, $00, $01
    DB      $C0, $08, $00, $FF, $05, $00, $85, $01
    DB      $05, $03, $05, $01, $06, $00, $07, $00
    DB      $01, $80, $08, $00, $FF, $0B, $01, $08
    DB      $26, $22, $17, $2F, $1B, $28, $00, $0E
    DB      $0B, $01, $08, $26, $22, $17, $2F, $1B
    DB      $28, $00, $0F, $4B, $01, $09, $1D, $17
    DB      $23, $1B, $00, $25, $2C, $1B, $28, $4D
    DB      $01, $07, $2F, $25, $2B, $00, $2D, $1F
    DB      $24, $49, $01, $0D, $1C, $1F, $28, $29
    DB      $2A, $00, $00, $29, $25, $28, $2A, $1F
    DB      $1B, $49, $01, $0D, $29, $1B, $19, $25
    DB      $24, $1A, $00, $29, $25, $28, $2A, $1F
    DB      $1B, $49, $01, $0D, $2A, $1E, $1F, $28
    DB      $1A, $00, $00, $29, $25, $28, $2A, $1F
    DB      $1B, $0D, $01, $05, $26, $28, $1B, $29
    DB      $29, $49, $01, $0E, $0A, $00, $0C, $00
    DB      $29, $17, $23, $1B, $00, $29, $21, $1F
    DB      $22, $22, $69, $01, $0D, $0B, $00, $0C
    DB      $00, $24, $1B, $2D, $00, $29, $21, $1F
    DB      $22, $22, $01, $01, $0E, $00, $01, $01
    DB      $01, $E0, $0E, $00, $01, $E0, $FF, $01
    DB      $00, $01, $07, $0D, $00, $01, $07, $83
    DB      $04, $FC, $04, $0C, $00, $01, $E0, $FF
    DB      $05, $00, $01, $07, $09, $00, $01, $07
    DB      $04, $00, $83, $04, $FC, $04, $08, $00
    DB      $01, $E0, $FF, $09

; ============================================================
; TILE / SPRITE BITMAPS  ($BC00 - $BF6F)
; TMS9918A pattern table -- 8 bytes per tile (one byte per row).
; 110 tiles total.
; ============================================================
TILE_BITMAPS:                              ; TILE_BITMAPS: tile/sprite pattern bitmaps for VDP pattern table
    DB      $00, $01, $07, $05, $00, $01, $07, $08 ; tile 0
    DB      $00, $83, $04, $FC, $04, $04, $00, $01 ; tile 1
    DB      $E0, $FF, $0D, $00, $83, $07, $00, $07 ; tile 2
    DB      $0C, $00, $84, $04, $FC, $04, $E0, $FF ; tile 3
    DB      $0A, $00, $84, $01, $03, $0F, $07, $02 ; tile 4
    DB      $00, $0A, $00, $84, $80, $C0, $F0, $E0 ; tile 5
    DB      $02, $00, $FF, $02, $00, $03, $04, $89 ; tile 6
    DB      $02, $22, $02, $09, $01, $11, $07, $3F ; tile 7
    DB      $0F, $02, $00, $03, $00, $8B, $80, $80 ; tile 8
    DB      $A0, $28, $40, $50, $A4, $C0, $F0, $FC ; tile 9
    DB      $F8, $02, $00, $FF, $02, $00, $02, $08 ; tile 10
    DB      $03, $04, $89, $0A, $06, $0A, $17, $3F ; tile 11
    DB      $17, $0B, $01, $02, $90, $00, $00, $80 ; tile 12
    DB      $88, $88, $C2, $D0, $E0, $B0, $E9, $FA ; tile 13
    DB      $F4, $AC, $50, $A0, $60, $90, $10, $39 ; tile 14
    DB      $15, $00, $00, $00, $80, $00, $00, $15 ; tile 15
    DB      $28, $00, $28, $14, $3E, $05, $83, $80 ; tile 16
    DB      $C0, $44, $05, $00, $88, $48, $14, $04 ; tile 17
    DB      $0A, $50, $AC, $58, $80, $FF, $90, $00 ; tile 18
    DB      $01, $03, $02, $07, $16, $2D, $50, $2B ; tile 19
    DB      $11, $12, $09, $10, $04, $00, $00, $8D ; tile 20
    DB      $00, $80, $40, $A8, $14, $80, $4A, $AD ; tile 21
    DB      $B4, $A8, $A0, $10, $80, $03, $00, $90 ; tile 22
    DB      $01, $02, $08, $15, $18, $29, $D2, $AF ; tile 23
    DB      $54, $EE, $6D, $36, $AF, $1B, $0E, $00 ; tile 24
    DB      $90, $84, $40, $B8, $54, $EA, $7E, $B5 ; tile 25
    DB      $52, $4B, $17, $5E, $EC, $78, $F0, $C0 ; tile 26
    DB      $00, $FF, $90, $00, $01, $06, $09, $13 ; tile 27
    DB      $05, $0A, $0D, $41, $56, $0E, $05, $02 ; tile 28
    DB      $01, $00, $00, $90, $00, $80, $40, $A0 ; tile 29
    DB      $50, $E0, $F4, $AA, $74, $20, $F0, $E8 ; tile 30
    DB      $90, $40, $00, $00, $90, $01, $06, $19 ; tile 31
    DB      $16, $2C, $1A, $35, $72, $BE, $A9, $71 ; tile 32
    DB      $3A, $1D, $1E, $07, $01, $90, $C0, $60 ; tile 33
    DB      $B8, $58, $AC, $1C, $0A, $55, $8B, $DF ; tile 34
    DB      $0F, $16, $6C, $B8, $E0, $80, $FF, $90 ; tile 35
    DB      $01, $01, $48, $24, $00, $C8, $00, $10 ; tile 36
    DB      $33, $64, $42, $95, $2A, $31, $50, $10 ; tile 37
    DB      $90, $00, $28, $00, $44, $08, $01, $02 ; tile 38
    DB      $00, $06, $13, $4E, $73, $E8, $54, $52 ; tile 39
    DB      $10, $FF, $10, $00, $90, $00, $00, $44 ; tile 40
    DB      $20, $11, $03, $07, $CF, $07, $03, $01 ; tile 41
    DB      $20, $02, $80, $04, $04, $8D, $40, $00 ; tile 42
    DB      $00, $01, $06, $C8, $E0, $F1, $E0, $C0 ; tile 43
    DB      $10, $48, $24, $03, $00, $10, $00, $FF ; tile 44
    DB      $90, $00, $00, $07, $0A, $17, $6B, $F7 ; tile 45
    DB      $AF, $D7, $2F, $57, $3A, $11, $0A, $03 ; tile 46
    DB      $00, $83, $15, $EA, $7F, $09, $FF, $84 ; tile 47
    DB      $3F, $99, $47, $2B, $84, $DC, $EB, $F5 ; tile 48
    DB      $FA, $08, $FF, $84, $FE, $FA, $65, $D8 ; tile 49
    DB      $90, $00, $80, $E0, $A8, $50, $AE, $D4 ; tile 50
    DB      $AB, $DD, $CB, $94, $2A, $54, $B0, $40 ; tile 51
    DB      $00, $FF, $8B, $00, $00, $01, $00, $02 ; tile 52
    DB      $05, $03, $15, $2A, $15, $0A, $05, $00 ; tile 53
    DB      $90, $00, $02, $4F, $BD, $E3, $E5, $CE ; tile 54
    DB      $C7, $EB, $7C, $FF, $7F, $2F, $15, $02 ; tile 55
    DB      $00, $90, $00, $00, $88, $D4, $FE, $FF ; tile 56
    DB      $7E, $BF, $EF, $E7, $CF, $1A, $C5, $8A ; tile 57
    DB      $00, $00, $03, $00, $8A, $80, $40, $A0 ; tile 58
    DB      $D0, $A8, $A0, $54, $80, $44, $80, $03 ; tile 59
    DB      $00, $FF, $90, $03, $07, $0E, $3F, $1D ; tile 60
    DB      $BA, $7C, $6A, $55, $6A, $35, $3F, $9F ; tile 61
    DB      $0F, $03, $00, $90, $86, $ED, $B0, $41 ; tile 62
    DB      $1C, $1A, $31, $38, $14, $83, $00, $80 ; tile 63
    DB      $D0, $EA, $FD, $1E, $90, $0E, $DF, $77 ; tile 64
    DB      $2B, $01, $00, $81, $40, $10, $18, $30 ; tile 65
    DB      $E5, $3A, $75, $9F, $06, $90, $00, $84 ; tile 66
    DB      $E8, $70, $BA, $58, $2C, $56, $5C, $AA ; tile 67
    DB      $7C, $BA, $7C, $F8, $F0, $E0, $FF, $8C ; tile 68
    DB      $00, $00, $01, $0A, $01, $05, $0B, $17 ; tile 69
    DB      $05, $2A, $11, $08, $04, $00, $90, $40 ; tile 70
    DB      $86, $4B, $17, $3F, $7F, $BF, $A6, $EF ; tile 71
    DB      $C7, $4B, $A5, $03, $14, $08, $00, $90 ; tile 72
    DB      $00, $06, $5F, $AF, $43, $E3, $D7, $EB ; tile 73
    DB      $FD, $F4, $F8, $D0, $21, $04, $02, $00 ; tile 74
    DB      $8D, $00, $00, $40, $88, $A0, $C0, $F4 ; tile 75
    DB      $EE, $D4, $A8, $40, $90, $20, $03, $00 ; tile 76
    DB      $FF, $90, $01, $87, $0E, $35, $3E, $5A ; tile 77
    DB      $34, $68, $3A, $55, $6E, $37, $1F, $17 ; tile 78
    DB      $03, $00, $90, $A0, $79, $B4, $E8, $C0 ; tile 79
    DB      $80, $40, $51, $10, $38, $94, $5A, $F4 ; tile 80
    DB      $EB, $F7, $3C, $90, $07, $59, $A0, $50 ; tile 81
    DB      $BC, $1C, $28, $14, $02, $0B, $07, $2F ; tile 82
    DB      $DE, $FB, $3D, $07, $90, $81, $E0, $B8 ; tile 83
    DB      $74, $58, $3C, $0A, $11, $2B, $56, $BE ; tile 84
    DB      $6E, $DC, $FC, $F0, $E0, $FF, $02, $00 ; tile 85
    DB      $8B, $04, $08, $14, $1A, $29, $56, $2F ; tile 86
    DB      $0A, $04, $0A, $01, $03, $00, $90, $00 ; tile 87
    DB      $18, $3F, $7F, $BF, $7E, $F9, $BA, $5D ; tile 88
    DB      $36, $0F, $17, $0A, $41, $02, $00, $02 ; tile 89
    DB      $00, $8E, $A4, $D8, $75, $FA, $FC, $75 ; tile 90
    DB      $BE, $7D, $FA, $FD, $F2, $80, $64, $00 ; tile 91
    DB      $8C, $00, $80, $C0, $60, $10, $20, $70 ; tile 92
    DB      $58, $B0, $48, $10, $20, $04, $00, $FF ; tile 93
    DB      $90, $03, $07, $1B, $37, $2B, $65, $56 ; tile 94
    DB      $A9, $50, $35, $3B, $35, $3E, $1F, $0B ; tile 95
    DB      $64, $90, $78, $E6, $C0, $80, $40, $81 ; tile 96
    DB      $06, $45, $A2, $C9, $F0, $E8, $F5, $BE ; tile 97
    DB      $DD, $20, $90, $19, $7F, $5B, $27, $4A ; tile 98
    DB      $05, $03, $8A, $41, $82, $05, $02, $0D ; tile 99
    DB      $7F, $9B, $07, $90, $80, $60, $38, $9C ; tile 100
    DB      $EC, $DE, $8E, $A6, $4E, $B6, $EC, $DA ; tile 101
    DB      $FC, $F8, $F0, $C0, $FF, $90, $00, $20 ; tile 102
    DB      $03, $00, $00, $03, $10, $11, $20, $11 ; tile 103
    DB      $0A, $45, $06, $01, $00, $44, $90, $00 ; tile 104
    DB      $04, $42, $90, $80, $48, $04, $30, $88 ; tile 105
    DB      $40, $10, $24, $24, $59, $00, $00, $90 ; tile 106
    DB      $00, $00, $40, $40, $08, $00, $02, $01 ; tile 107
    DB      $00, $02, $45, $0A, $92, $85, $02, $00 ; tile 108
    DB      $90, $00, $02, $00, $08, $00, $02, $C0 ; tile 109

; ============================================================
; ZERO PADDING  ($BF70 - $BFFF)
; ============================================================
    DB      $A1, $02, $00, $22, $04, $20, $00, $03
    DB      $08, $FF, $90, $05, $02, $08, $31, $14
    DB      $88, $64, $68, $50, $6A, $25, $3A, $19
    DB      $14, $23, $00, $90, $04, $40, $20, $00
    DB      $18, $10, $40, $00, $20, $82, $00, $80
    DB      $40, $80, $70, $1A, $90, $02, $40, $04
    DB      $00, $01, $00, $00, $00, $00, $10, $00
    DB      $24, $08, $50, $89, $02, $90, $00, $81
    DB      $64, $10, $08, $41, $2C, $16, $5C, $8A
    DB      $5D, $B8, $5C, $6A, $90, $60, $FF, $90
    DB      $82, $09, $24, $12, $08, $10, $38, $B0
    DB      $20, $88, $1A, $29, $90, $09, $42, $01
    DB      $83, $04, $24, $80, $07, $00, $86, $08
    DB      $20, $E0, $C8, $C2, $11, $90, $44, $08
    DB      $02, $05, $02, $08, $00, $00, $00, $00
    DB      $04, $00, $23, $08, $44, $04, $90, $02
    DB      $85, $28, $00, $01, $0C, $00, $35, $00
    DB      $02, $40, $90, $41, $C8, $32, $60, $FF
