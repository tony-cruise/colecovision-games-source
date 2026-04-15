; =============================================================================
; NOVA BLAST  1983  --  ColecoVision  (12 KB ROM, loads at $8000)
; Disassembled by z80cv_disasm.py  |  Annotated with Claude Sonnet 4.6
; Exact byte-match verified vs. nova-blast-1983.rom
; =============================================================================
;
; LEGEND / CROSS-REFERENCE INDEX
; All line numbers refer to THIS file.  ROM addresses shown as ($XXXX).
;
; --- HARDWARE / BIOS --------------------------------------------------------
;   BIOS EQU block:  lines  114- 163    I/O:  167- 173    RAM:  177- 180
;     WORK_BUFFER $7000  JOYSTICK_BUFFER $7057  STACKTOP $73B9
;
; --- ROM LAYOUT (12 KB: $8000-$AFFF) ----------------------------------------
;   $8021  CART_ENTRY: JP NMI  line  197    $8025  START  line  204
;   $8107  LOC_8107 game loop  line  285    $82AB  LOC_82AB NMI body  line  474
;   $8AF1  LOC_8AF1 wave init  line 1391    $9177  LOC_9177 wave SM   line 2053
;   ~$AA00 NMI handler         line  430
;
; --- BOOT / INIT ($8025) ----------------------------------------------------
;   START ($8025)  line  204  SP=STACKTOP, MODE_1, SOUND_INIT
;                              zero $705D..$7264 (520 B); $7264=$97 (NMI gate)
;                              init $7250-$7256=$3C (dead); SUB_9A0A level data
;                              LOC_8AF1: wave/difficulty init
;
; --- NMI HANDLER (~$AA00) ---------------------------------------------------
;   NMI (~$AA00)     line  430  gate: $7264==$97; save all regs (AF,HL,BC,DE,alts,IY,IX)
;   LOC_826B         line  438  wave-timer dispatch:
;                              $725C==0 -> LOC_922B  $77 -> banner  else -> LOC_9177
;   LOC_82AB         line  474  main NMI frame body (10 subsystem calls)
;   LOC_82D3         line  490  NMI exit: PLAY_SONGS, SOUND_MAN, RETN
;
; --- VDP WRITE PRIMITIVES ---------------------------------------------------
;   VDP_WRITE_82EE  line  509  set VRAM addr (HL), write 3 bytes from B
;   VDP_WRITE_830C  line  531  set VRAM addr (DE), write single byte B
;   VDP_WRITE_831B  line  542  read one VRAM byte at (HL+$1800)
;   VDP_WRITE_832D  line  555  LDIR BC bytes from HL to VRAM at DE
;   VDP_WRITE_8342  line  573  fill A for DE bytes at VRAM addr HL
;
; --- NMI FRAME BODY SUBSYSTEMS ----------------------------------------------
;   SUB_8E7E  line 1713  animation timers (kill-anim $7228, wave $7258)
;   SUB_835F  line  599  scroll ticker (advance starfield parallax)
;   SUB_9B8E  line 3153  score + lives row renderer
;   SUB_9B68  line 3132  VRAM row read for parallax background
;   SUB_8C00  line 1475  sprite renderer: 4 active projectile objects
;   SUB_96F9  line 2628  boss AI: laser trajectory + movement
;   SUB_8FCE  line 1877  joystick-action dispatcher (9-entry jump table)
;   SUB_84F3  line  856  copy enemy records to sprite attribute buffer
;   SUB_8461  line  759  cannon rotation animation + position update
;
; --- JOYSTICK + CANNON -------------------------------------------------------
;   SUB_838E  line  624  joystick handler: POLLER + decode $72E0 bits
;   SUB_83C6  line  658  left:  $7267=$10, $706C -= 3
;   SUB_83E6  line  677  right: $7267=$18, $706C += 3
;   SUB_8406  line  696  up:    $7265 -= 2 (cannon Y up)
;   SUB_841C  line  710  down:  $7265 += 2 (cannon Y down)
;
; --- WAVE / BOSS STATE MACHINE ----------------------------------------------
;   LOC_9177  line 2053  wave intro: per-frame tile/colour animation
;   LOC_922B  line 2133  new wave setup: VDP + sound + score
;   LOC_8AF1  line 1391  clear enemy RAM, load difficulty tables
;   SUB_9A0A  line 3069  load level layout data from ROM table
;
; --- ENEMY / SPAWN ----------------------------------------------------------
;   SUB_9907  line 2914  spawn up to 3 enemies from difficulty table
;   SUB_880E  line 1218  find free slot in $7250 table (returns C)
;   SUB_858E  line  949  enemy movement: approach cannon or fly-over
;   SUB_95FC  line 2482  per-enemy hit test (laser vs. bounding box)
;
; --- SCORE / SOUND ----------------------------------------------------------
;   SUB_92AC  line 2224  BCD add A to score $705A  |  SUB_92BD  line 2237  render score
;   SOUND_WRITE_9371  line 2269  configure SN76489A from $7246 bits
;
; --- KEY RAM VARIABLES -------------------------------------------------------
;   $705A/$705B  BCD score (lo/hi)    $705C  game state ($72=intro $73=game)
;   $705E  life countdown (JP START when 0)   $706C  cannon horizontal angle
;   $706D  cannon pos 16-bit fractional        $706F  frame counter 16-bit
;   $7246  sound config (bits 7-5=vol, 4-2=enemy type)
;   $7250  enemy spawn table (4x2 B; $3C=dead $6C=hit)
;   $7258  wave timer ($B4=deploy $00=over)    $7264  NMI gate ($97=active)
;   $7265  cannon Y ($02..$60)  $7266  angle acc ($40=left $C0=right)
;   $725C  wave-transition timer  $73C5  VDP status  $73C8  random seed
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
JOYSTICK_BUFFER:         EQU $72DD
STACKTOP:                EQU $73B9

FNAME "output\NOVA-BLAST-1983-NEW.ROM"
CPU Z80

    ORG     $8000

    DW      $55AA                           ; cart magic $55AA identifies ColecoVision ROM
    DB      $00, $00
    DB      $00, $00
    DB      $00, $00
    DW      JOYSTICK_BUFFER                 ; BIOS POLLER writes controller state here
    DW      START                           ; start address jumped to by BIOS
    DB      $C9, $00, $00, $C9, $00, $00, $C9, $00
    DB      $00, $C9, $00, $00, $C9, $00, $00, $C9
    DB      $00, $00, $ED, $4D, $00

CART_ENTRY:
    JP      NMI                             ; all maskable + NMI interrupts vectored through NMI handler
    DB      $1D, $20, $31, $39, $38, $33, $20, $49
    DB      $4D, $41, $47, $49, $43, $2F, $4E, $4F ; "MAGIC/NO"
    DB      $56, $41, $20, $42, $4C, $41, $53, $54 ; "VA BLAST"
    DB      $1E, $1F, $2F, $31, $39, $38, $33

START:
    LD      SP, STACKTOP                    ; init stack at STACKTOP
    CALL    MODE_1                          ; set VDP Mode 1 (text/sprite mode)
    CALL    READ_REGISTER                   ; read VDP status register (clears interrupt flag)
    CALL    SUB_8221
    LD      B, $04
    LD      HL, $ADAB
    CALL    SOUND_INIT                      ; initialise SN76489A sound engine, $B=4 channels, HL=sound table
    LD      D, $00
    LD      HL, $705D                       ; HL = $705D -- start of game RAM to zero
    LD      BC, $0208                       ; BC = $0208 = 520 bytes to zero ($705D..$7264)

LOC_805F:
    LD      (HL), D
    INC     HL
    DEC     BC
    LD      A, C
    OR      B
    JR      NZ, LOC_805F
    LD      A, $97                          ; A = $97 = NMI gate active value
    LD      ($7264), A                      ; enable NMI: $7264==$97 allows NMI body to run
    LD      A, $80
    LD      ($7221), A                      ; init fire-anim timer $7221 = $80
    LD      ($7225), A                      ; init fire-anim timer $7225 = $80
    LD      A, $50
    LD      ($7246), A                      ; initial sound config byte for $7246
    LD      A, $3C                          ; LD A, $3C -- 'dead' slot marker for enemy table
    LD      ($7250), A                      ; enemy slot 0 ($7250): $3C = dead
    LD      ($7252), A                      ; enemy slot 1 ($7252): $3C = dead
    LD      ($7254), A                      ; enemy slot 2 ($7254): $3C = dead
    LD      ($7256), A                      ; enemy slot 3 ($7256): $3C = dead
    LD      A, $90
    LD      (JOYSTICK_BUFFER), A            ; JOYSTICK_BUFFER = $90: default BIOS controller state
    LD      A, $33
    LD      ($73C8), A                      ; seed random number generator at $73C8
    CALL    SUB_9549                        ; zero $716E sprite attribute buffer (128 bytes)
    CALL    SUB_9559                        ; init enemy slot/colour buffer ($7250 table)
    CALL    SUB_9425                        ; load BIOS font patterns to VRAM $0000
    CALL    SUB_8254                        ; copy angle->sprite tables from ROM to $7265 area
    CALL    SUB_81AA                        ; load cannon sprite bitmaps and initial screen graphics
    CALL    SUB_9A0A                        ; SUB_9A0A: load level layout data from ROM table
    LD      HL, $A62A
    LD      DE, $0300
    LD      BC, $00D0
    CALL    VDP_WRITE_832D                  ; LDIR title-screen tile row to VRAM $0300
    LD      HL, $815E
    LD      DE, $18F0
    CALL    SUB_9297                        ; SUB_9297: write IMAGIC string to VRAM name table
    LD      HL, $81A4
    LD      DE, $18EA
    LD      BC, $0006
    CALL    VDP_WRITE_832D                  ; LDIR 'NOVA BLAST' title string to VRAM
    LD      HL, $8166
    LD      DE, $188C
    CALL    SUB_9297                        ; SUB_9297: write sub-title string
    LD      A, ($705C)                      ; check game state: $705C=$73 means resume (game was running)
    CP      $73
    JR      Z, LOC_80DE                     ; if resuming game, skip score reset
    LD      HL, BOOT_UP
    LD      ($705A), HL                     ; init score pointer $705A = BOOT_UP ($0000)
    LD      A, $00
    LD      ($7059), A                      ; clear score-overflow byte $7059

LOC_80DE:
    CALL    SUB_92BD                        ; SUB_92BD: render BCD score digits to VRAM
    LD      HL, BOOT_UP
    LD      ($705A), HL                     ; reset score display pointer to BOOT_UP
    XOR     A
    LD      ($705C), A                      ; zero game state $705C
    LD      C, $C2
    LD      B, $01
    CALL    WRITE_REGISTER                  ; WRITE_REGISTER: VDP reg 1 = $C2 (enable display, disable sprites)
    CALL    SUB_811D
    CALL    LOC_8AF1                        ; LOC_8AF1: init wave/difficulty parameters and clear enemy RAM
    LD      A, $78
    LD      ($725C), A                      ; wave transition timer $725C = $78 = 120 frames
    CALL    SUB_8117
    LD      C, $E2                          ; VDP reg 1 = $E2 (enable display + sprites)
    LD      B, $01
    CALL    WRITE_REGISTER                  ; WRITE_REGISTER: activate VDP with sprites enabled

LOC_8107:                                   ; LOC_8107: main game loop -- spins waiting for NMI tick
    CALL    SUB_838E                        ; SUB_838E: poll joystick and update cannon direction
    CALL    SUB_9907                        ; SUB_9907: spawn up to 3 enemies from ROM tables
    LD      HL, $706F                       ; HL -> $706F (16-bit NMI frame counter)
    LD      C, (HL)                         ; C = current frame count snapshot

LOC_8111:
    LD      A, (HL)                         ; spin: re-read $706F until it increments (wait for NMI)
    CP      C
    JR      Z, LOC_8111                     ; still same frame -- spin
    JR      LOC_8107                        ; new frame ready -- restart loop

SUB_8117:
    LD      A, $9B
    LD      (JOYSTICK_BUFFER), A            ; reset BIOS controller poll state ($9B)
    RET     

SUB_811D:
    CALL    POLLER                          ; POLLER: read controller buttons
    LD      DE, $18E9
    LD      A, ($72E3)                  ; RAM $72E3
    CP      $0A                             ; CP $0A: $0A = 'select complete' signal from BIOS
    RET     Z
    CP      $04
    CALL    Z, SUB_813A                     ; button 1 (keypad 1): select CADET difficulty
    CP      $05
    CALL    Z, SUB_8146                     ; button 2 (keypad 4): select CAPTAIN difficulty
    CP      $06
    CALL    Z, SUB_8152                     ; button 3 (keypad 5): select ADMIRAL difficulty
    JR      SUB_811D

SUB_813A:
    LD      HL, $8171
    CALL    SUB_9297
    LD      A, $00
    LD      ($7059), A                      ; set difficulty byte $7059 = 0 (CADET)
    RET     

SUB_8146:
    LD      HL, $8182
    CALL    SUB_9297
    LD      A, $02
    LD      ($7059), A                      ; set difficulty byte $7059 = 2 (CAPTAIN)
    RET     

SUB_8152:
    LD      HL, $8193
    CALL    SUB_9297
    LD      A, $04
    LD      ($7059), A                      ; set difficulty byte $7059 = 4 (ADMIRAL)
    RET     
    DB      $20, $49, $4D, $41, $47, $49, $43, $00
    DB      $4E, $4F, $56, $41, $20, $42, $4C, $41 ; "NOVA BLA"
    DB      $53, $54, $00, $20, $20, $20, $20, $20
    DB      $20, $43, $41, $44, $45, $54, $20, $20 ; " CADET  "
    DB      $20, $20, $20, $00, $20, $20, $20, $20
    DB      $20, $43, $41, $50, $54, $41, $49, $4E ; " CAPTAIN"
    DB      $20, $20, $20, $20, $00, $20, $20, $20
    DB      $20, $20, $41, $44, $4D, $49, $52, $41 ; "  ADMIRA"
    DB      $4C, $20, $20, $20, $20, $00, $8D, $5A
    DB      $49, $51, $50, $4B          ; "IQPK"

SUB_81AA:                                   ; SUB_81AA: load cannon + starfield bitmaps to VRAM
    LD      HL, $A252
    LD      DE, $00A8
    LD      BC, $03D8
    CALL    VDP_WRITE_832D
    CALL    SUB_81E1
    LD      HL, $7265                   ; RAM $7265
    LD      DE, $1B00
    LD      BC, $0078
    CALL    VDP_WRITE_832D
    LD      HL, $A240
    LD      DE, $2000
    LD      BC, $0012
    CALL    VDP_WRITE_832D
    CALL    DELAY_LOOP_8205
    LD      HL, $A76B
    LD      DE, $3880
    LD      BC, $0640
    CALL    VDP_WRITE_832D
    RET     

SUB_81E1:
    LD      HL, $A000                       ; SUB_81E1: write background tile patterns to VRAM
    LD      DE, $1800
    LD      BC, $01E0
    CALL    VDP_WRITE_832D
    LD      HL, $A1E0
    LD      DE, $1AA0
    LD      BC, $0060
    CALL    VDP_WRITE_832D
    LD      A, $10
    LD      HL, $19E0
    LD      DE, $00C0
    CALL    VDP_WRITE_8342
    RET     

DELAY_LOOP_8205:                            ; DELAY_LOOP_8205: write 4x sprite-bitmap blocks to VRAM $3800
    LD      B, $04
    LD      IX, $3800
    LD      HL, $A74B

LOC_820E:
    PUSH    BC
    LD      BC, $0008
    PUSH    IX
    POP     DE
    CALL    VDP_WRITE_832D
    LD      BC, $0020
    ADD     IX, BC
    POP     BC
    DJNZ    LOC_820E
    RET     

SUB_8221:                                   ; SUB_8221: zero VRAM regions ($1B00, $3800, $0000, $2000, $1800)
    XOR     A
    LD      HL, $1B00
    LD      DE, $0080
    CALL    VDP_WRITE_8342
    XOR     A
    LD      HL, $3800
    LD      DE, $0800
    CALL    VDP_WRITE_8342
    XOR     A
    LD      HL, BOOT_UP
    LD      DE, $0800
    CALL    VDP_WRITE_8342
    XOR     A
    LD      HL, $2000
    LD      DE, $0020
    CALL    VDP_WRITE_8342
    LD      HL, $1800
    LD      DE, $0300
    XOR     A
    CALL    VDP_WRITE_8342
    RET     

SUB_8254:                                   ; SUB_8254: LDIR 73 bytes from $A702 to $7265 (angle tables)
    LD      HL, $A702
    LD      DE, $7265                   ; RAM $7265
    LD      BC, $0049
    LDIR    
    RET     

NMI:                                        ; NMI: entry point for all interrupts (CART_ENTRY JP NMI)
    PUSH    AF
    LD      A, ($7264)                      ; load NMI gate value from $7264
    CP      $97                             ; gate must equal $97 to run NMI body
    JR      Z, LOC_826B                     ; if gate = $97: proceed to NMI body (LOC_826B)
    POP     AF                              ; gate failed -- pop saved AF
    RETN                                    ; RETN: return without running NMI body

LOC_826B:                                   ; LOC_826B: NMI body -- save all registers (AF,HL,BC,DE,alts,IY,IX)
    EX      AF, AF'                         ; swap AF with AF' to save
    PUSH    AF
    PUSH    HL
    PUSH    BC
    PUSH    DE
    EXX     
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IY
    PUSH    IX
    LD      A, ($705E)                      ; load $705E (life countdown timer)
    OR      A                               ; zero?
    JP      NZ, LOC_89C4                    ; non-zero: decrement life timer (LOC_89C4)
    LD      A, ($725C)                      ; load wave timer $725C
    OR      A
    JR      Z, LOC_82AB                     ; decrement wave timer
    DEC     A
    LD      ($725C), A                      ; store updated wave timer
    LD      A, ($705C)                      ; load game state $705C
    CP      $72                             ; $72: intro/title screen
    JR      Z, LOC_82AB                     ; if game state == $72: skip wave logic, run frame body
    CP      $73                             ; $73: in-game (normal play state)
    JR      Z, LOC_82AB                     ; if game state == $73: also run frame body
    LD      A, ($725C)                      ; reload wave timer (after decrement)
    OR      A
    JP      Z, LOC_922B                     ; wave timer = 0: wave complete -- new wave intro (LOC_922B)
    CP      $77                             ; wave timer = $77 (119): show wave banner (LOC_91C7)
    JP      Z, LOC_91C7                     ; goto wave display subroutine
    CP      $B4
    JR      NC, LOC_82AB                    ; timer >= $B4 (180): skip early-wave frames (stay in LOC_82D3 path)
    CP      $78
    JR      C, LOC_82D3                     ; timer < $78 (120): wave still decrementing -- skip game body
    JP      LOC_9177                        ; LOC_9177: wave transition state machine

LOC_82AB:                                   ; LOC_82AB: main NMI frame body
    LD      HL, ($706F)                     ; HL = 16-bit frame counter at $706F
    INC     HL                              ; INC HL (frame counter++)
    LD      ($706F), HL                     ; store incremented frame counter
    CALL    SUB_8E7E                        ; SUB_8E7E: animation timers (kill anim $7228, wave timer $7258)
    CALL    SUB_835F                        ; SUB_835F: scroll ticker -- advance starfield parallax
    CALL    SUB_9B8E                        ; SUB_9B8E: render score + lives digits to VRAM
    CALL    SUB_9B68                        ; SUB_9B68: read VRAM row for parallax background scroll
    CALL    SUB_8C00                        ; SUB_8C00: sprite renderer -- draw 4 active projectile objects
    CALL    DELAY_LOOP_8E64                 ; DELAY_LOOP_8E64: advance projectile animation frames
    CALL    SUB_96F9                        ; SUB_96F9: boss AI / laser trajectory update
    CALL    SUB_8FCE                        ; SUB_8FCE: joystick-action dispatcher (9-entry table)
    CALL    SUB_84F3                        ; SUB_84F3: copy enemy data to sprite attribute buffer
    CALL    SUB_9577                        ; SUB_9577: check VDP status register (sprite overflow/collision)
    CALL    SUB_8461                        ; SUB_8461: cannon rotation animation + position update

LOC_82D3:                                   ; LOC_82D3: NMI exit path (all branches converge here)
    CALL    PLAY_SONGS                      ; CALL PLAY_SONGS: advance music sequencer
    CALL    SOUND_MAN                       ; CALL SOUND_MAN: fire pending sound effects to SN76489A
    POP     IX                              ; restore IX
    POP     IY                              ; restore IY
    POP     HL                              ; restore HL'
    POP     DE                              ; restore DE'
    POP     BC                              ; restore BC'
    EXX     
    POP     DE                              ; restore DE
    POP     BC                              ; restore BC
    POP     HL                              ; restore HL
    POP     AF                              ; restore AF
    EX      AF, AF'
    IN      A, ($BF)                        ; IN A, ($BF): read VDP status (clears collision/overflow flags)
    LD      ($73C5), A                      ; save VDP status -- bit 5 = sprite overflow used by SUB_9577
    POP     AF
    RETN                                    ; RETN: return from non-maskable interrupt

VDP_WRITE_82EE:                             ; VDP_WRITE_82EE: set VRAM write addr (HL), write 3 bytes from B
    LD      A, L                            ; send low byte of VRAM address to VDP ctrl port
    OUT     ($BF), A                        ; OUT CTRL_PORT: low byte of VRAM address
    LD      A, H                            ; high byte OR $40 = write-mode VRAM address command
    OR      $40                             ; OR $40: set write flag in VRAM address command
    OUT     ($BF), A                        ; OUT CTRL_PORT: high byte with write flag
    LD      A, B
    CALL    SUB_8309
    OUT     ($BE), A                        ; OUT DATA_PORT: write byte B to VRAM
    INC     A
    CALL    SUB_8309
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    INC     A
    CALL    SUB_8309
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    RET     

SUB_8309:                                   ; SUB_8309: 2-cycle I/O delay (PUSH/POP AF for timing)
    PUSH    AF
    POP     AF
    RET     

VDP_WRITE_830C:                             ; VDP_WRITE_830C: set VRAM write addr (DE), write single byte B
    LD      A, E                            ; send E (low) to VDP ctrl port
    OUT     ($BF), A                        ; OUT CTRL_PORT: address low byte
    LD      A, D                            ; D OR $40 = write-mode command
    OR      $40
    OUT     ($BF), A                        ; OUT CTRL_PORT: address high byte + write flag
    CALL    SUB_8309
    LD      A, B
    OUT     ($BE), A                        ; OUT DATA_PORT: write B to VRAM
    RET     

VDP_WRITE_831B:                             ; VDP_WRITE_831B: read one VRAM byte at HL+$1800 (name table offset)
    PUSH    HL                              ; save HL
    LD      DE, $1800                       ; add $1800 name-table base offset
    ADD     HL, DE
    LD      A, L
    OUT     ($BF), A                        ; OUT CTRL_PORT: address low
    LD      A, H
    OUT     ($BF), A                        ; OUT CTRL_PORT: address high (read-mode: no $40 flag)
    CALL    SUB_8309
    IN      A, ($BE)                        ; IN A, DATA_PORT: read one VRAM byte
    POP     HL                              ; restore HL
    RET     

VDP_WRITE_832D:                             ; VDP_WRITE_832D: LDIR BC bytes from HL to VRAM at addr DE
    LD      A, E                            ; send E (low) to CTRL_PORT
    OUT     ($BF), A                        ; OUT CTRL_PORT: address low
    LD      A, D                            ; D OR $40 = write-mode command
    OR      $40
    OUT     ($BF), A                        ; OUT CTRL_PORT: address high + write flag
    CALL    SUB_8309

LOC_8338:
    LD      A, (HL)                         ; read next source byte
    OUT     ($BE), A                        ; OUT DATA_PORT: write byte to VRAM
    INC     HL                              ; advance source pointer
    DEC     BC                              ; decrement byte count
    LD      A, B
    OR      C
    JR      NZ, LOC_8338                    ; loop until BC == 0
    RET     

VDP_WRITE_8342:                             ; VDP_WRITE_8342: fill A for DE bytes at VRAM addr HL
    LD      C, A                            ; save fill byte in C
    LD      A, L                            ; send L (low) to CTRL_PORT
    OUT     ($BF), A                        ; OUT CTRL_PORT: address low
    LD      A, H                            ; H OR $40 = write-mode command
    OR      $40
    OUT     ($BF), A                        ; OUT CTRL_PORT: address high + write flag

LOC_834B:
    LD      A, C                            ; OUT DATA_PORT: write fill byte
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    DEC     DE                              ; DEC DE (byte count)
    LD      A, E
    OR      D
    JR      NZ, LOC_834B                    ; loop until DE == 0
    RET     

SUB_8354:                                   ; SUB_8354: write single byte B at VRAM name-table (HL+$1800)
    PUSH    HL
    LD      DE, $1800
    ADD     HL, DE
    DB      $EB
    CALL    VDP_WRITE_830C
    POP     HL
    RET     

SUB_835F:                                   ; SUB_835F: starfield parallax scroll ticker
    LD      A, ($7257)                      ; load scroll countdown $7257
    OR      A
    JR      Z, LOC_836F                     ; zero: no scroll update this frame
    CALL    SUB_957F                        ; SUB_957F: advance cannon jitter/drift (updates $7266/$7265)
    CALL    LOC_836F
    CALL    SUB_95CF                        ; LOC_836F: write enemy sprite data to VRAM sprite attr table
    RET     

LOC_836F:
    LD      HL, $72AD                       ; HL = $72AD: enemy sprite data source
    LD      DE, $1B48                       ; DE = $1B48: VDP sprite attribute table write address
    LD      A, ($7091)                      ; sprite count from $7091
    ADD     A, A
    ADD     A, A
    INC     A
    LD      C, A
    LD      B, $00
    CALL    VDP_WRITE_832D
    LD      HL, $7265                   ; RAM $7265
    LD      DE, $1B00
    LD      BC, $0048
    CALL    VDP_WRITE_832D
    RET     

SUB_838E:                                   ; SUB_838E: main joystick handler
    LD      A, ($725C)                      ; load wave timer $725C
    OR      A
    RET     NZ                              ; if wave active (non-zero): skip joystick input
    CALL    POLLER                          ; POLLER: read controller via BIOS
    CALL    SUB_843F                        ; SUB_843F: update random seed XOR from $706C/$706F
    XOR     A
    LD      ($7068), A                      ; zero $7068 (joystick delta flag)
    LD      A, ($72E0)                      ; load $72E0 joystick direction bits (from POLLER)
    LD      B, A
    BIT     0, B                            ; bit 0: joystick UP
    CALL    NZ, SUB_8406                    ; if up: call SUB_8406 (move cannon up)
    BIT     1, B                            ; bit 1: joystick LEFT
    CALL    NZ, SUB_83C6                    ; if left: call SUB_83C6 (rotate cannon left)
    BIT     2, B                            ; bit 2: joystick DOWN
    CALL    NZ, SUB_841C                    ; if down: call SUB_841C (move cannon down)
    BIT     3, B                            ; bit 3: joystick RIGHT
    CALL    NZ, SUB_83E6                    ; if right: call SUB_83E6 (rotate cannon right)
    LD      HL, $706C                   ; RAM $706C
    LD      A, (HL)
    SLA     A
    JR      C, LOC_83C2
    RET     Z
    RRA     
    DEC     A
    LD      (HL), A
    RET     

LOC_83C2:
    RRA     
    INC     A
    LD      (HL), A
    RET     

SUB_83C6:                                   ; SUB_83C6: joystick left -- set direction=$10, speed=$14, dec $706C
    LD      A, $10                          ; direction code $10 = LEFT
    LD      ($7267), A                      ; LD $7267=$10 (left direction)
    ADD     A, $04
    LD      ($726B), A                      ; LD $726B=$14 (left speed)
    LD      A, $00
    LD      ($72AB), A                      ; zero $72AB (cannon trail flag)
    LD      HL, $706C                   ; RAM $706C
    LD      A, (HL)
    SUB     $03                             ; subtract 3 from cannon horizontal $706C
    CP      $7F                             ; CP $7F: left stop sentinel (already at leftmost)
    RET     Z
    CP      $7E
    RET     Z                               ; CP $7E: also stop
    CP      $7D
    RET     Z                               ; CP $7D: also stop
    LD      (HL), A                         ; update $706C
    RET     

SUB_83E6:                                   ; SUB_83E6: joystick right -- set direction=$18, speed=$1C, inc $706C
    LD      A, $18                          ; direction code $18 = RIGHT
    LD      ($7267), A                      ; LD $7267=$18 (right direction)
    ADD     A, $04
    LD      ($726B), A                      ; LD $726B=$1C (right speed)
    LD      A, $04
    LD      ($72AB), A                      ; LD $72AB=$04 (cannon trail: right-side)
    LD      HL, $706C                   ; RAM $706C
    LD      A, (HL)
    ADD     A, $03                          ; add 3 to $706C (cannon horizontal)
    CP      $80                             ; CP $80: right stop sentinel
    RET     Z
    CP      $81
    RET     Z                               ; CP $81: also stop
    CP      $82
    RET     Z                               ; CP $82: also stop
    LD      (HL), A                         ; update $706C
    RET     

SUB_8406:                                   ; SUB_8406: joystick up -- decrement cannon Y by 2
    LD      HL, $7265                       ; HL = $7265 (cannon Y position)
    LD      A, (HL)
    CP      $02                             ; CP $02: at top limit
    RET     Z
    DEC     A                               ; DEC A (cannon Y by 2: two decrements ahead)
    DEC     A                               ; DEC A
    LD      (HL), A                         ; store updated cannon Y
    LD      ($7269), A                      ; mirror to $7269
    CALL    SUB_8435                        ; SUB_8435: convert Y to VDP row address offset ($726F)
    LD      A, $FE
    LD      ($7068), A                      ; set $7068 = $FE (upward motion flag)
    RET     

SUB_841C:                                   ; SUB_841C: joystick down -- increment cannon Y by 2
    LD      HL, $7265                       ; HL = $7265 (cannon Y position)
    LD      A, (HL)
    CP      $60                             ; CP $60: at bottom limit ($60)
    RET     Z                               ; CP $5F: also at limit
    CP      $5F
    RET     Z
    INC     A                               ; INC A (cannon Y up 2)
    INC     A                               ; INC A
    LD      (HL), A                         ; store updated cannon Y
    LD      ($7269), A                      ; mirror to $7269
    CALL    SUB_8435
    LD      A, $02                          ; set $7068 = $02 (downward motion flag)
    LD      ($7068), A                  ; RAM $7068
    RET     

SUB_8435:                                   ; SUB_8435: pack Y into VDP column addr offset ($726F = (Y&$F8)>>2 + $20)
    AND     $F8
    RRCA    
    RRCA    
    ADD     A, $20
    LD      ($726F), A                  ; RAM $726F
    RET     

SUB_843F:                                   ; SUB_843F: update random seed $73C8 XOR from $706C/$706F
    LD      A, ($706F)                  ; RAM $706F
    LD      B, A
    LD      A, ($706C)                  ; RAM $706C
    SRL     A
    RRCA    
    XOR     B
    LD      HL, $73C8                   ; RAM $73C8
    XOR     (HL)
    LD      (HL), A
    RET     

SUB_8450:                                   ; SUB_8450: compute cannon speed vector from $706C: A=(A>>1)*3/2
    LD      A, ($706C)                  ; RAM $706C
    SRA     A
    LD      B, A
    SRA     A
    ADD     A, B
    LD      E, A
    BIT     7, A
    LD      D, $00
    RET     Z
    DEC     D
    RET     

SUB_8461:
    CALL    SUB_8450                        ; SUB_8461: cannon angle animation -- update $706D position
    LD      HL, ($706D)                     ; call SUB_8450 to get speed vector DE
    ADD     HL, DE                          ; load cannon position $706D
    LD      ($706D), HL                     ; add delta to cannon position
    LD      A, ($7267)                      ; save updated cannon position
    CP      $18                             ; load joystick direction $7267
    LD      HL, $7266                       ; CP $18: right?
    LD      A, (HL)
    JR      Z, LOC_848B                     ; not right: cannon rotating left
    CP      $40                             ; CP $40: angle already at left max ($40)?
    RET     Z
    DEC     (HL)                            ; DEC $7266 (decrease angle counter)
    LD      A, (HL)
    LD      ($726A), A                      ; mirror to $726A
    LD      ($726E), A                      ; mirror to $726E
    CALL    SUB_84C4
    CALL    SUB_84A0
    CALL    SUB_84B0
    RET     

LOC_848B:                                   ; LOC_848B: cannon rotating right
    CP      $C0                             ; CP $C0: angle at right max ($C0)?
    RET     Z
    INC     (HL)                            ; INC $7266 (increase angle counter)
    LD      A, (HL)
    LD      ($726A), A                      ; mirror to $726A
    LD      ($726E), A                      ; mirror to $726E
    CALL    SUB_84CA
    CALL    SUB_84A8
    CALL    SUB_84BA
    RET     

SUB_84A0:
    CALL    SUB_84D0
    DEC     HL
    CALL    SUB_84E4
    RET     

SUB_84A8:
    CALL    SUB_84D0
    INC     HL
    CALL    SUB_84E4
    RET     

SUB_84B0:
    LD      HL, $721E                   ; RAM $721E
    DEC     (HL)
    LD      BC, $0004
    ADD     HL, BC
    DEC     (HL)
    RET     

SUB_84BA:
    LD      HL, $721E                   ; RAM $721E
    INC     (HL)
    LD      BC, $0004
    ADD     HL, BC
    INC     (HL)
    RET     

SUB_84C4:
    LD      HL, $7060                   ; RAM $7060
    INC     (HL)
    INC     (HL)
    RET     

SUB_84CA:
    LD      HL, $7060                   ; RAM $7060
    DEC     (HL)
    DEC     (HL)
    RET     

SUB_84D0:                                   ; SUB_84D0: convert $706D to tile coords (HL = $706D >> 4)
    LD      HL, ($706D)                 ; RAM $706D
    SRL     H
    RR      L
    SRL     H
    RR      L
    SRL     H
    RR      L
    SRL     H
    RR      L
    RET     

SUB_84E4:                                   ; SUB_84E4: merge $706D fractional bits back (HL bits 0-3 = $706D & $0F)
    LD      A, ($706D)                  ; RAM $706D
    AND     $0F
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    OR      L
    LD      L, A
    LD      ($706D), HL                 ; RAM $706D
    RET     

SUB_84F3:                                   ; SUB_84F3: copy active enemy records to sprite attribute buffer $7126
    LD      IX, $70A8                       ; IX = $70A8: enemy record table base (18 records x 7 bytes)
    LD      IY, $72AD                       ; IY = $72AD: sprite attribute output buffer
    LD      A, $12                          ; A = $12 = 18 enemy slots to process

LOC_84FD:
    EX      AF, AF'
    LD      A, (IX+5)                       ; load (IX+5): enemy active flag
    OR      A
    JR      Z, LOC_850A                     ; zero: slot empty -- skip
    CALL    SUB_858E                        ; SUB_858E: compute enemy screen position
    CALL    SUB_8518                        ; SUB_8518: convert world pos to sprite Y,X and output to IY

LOC_850A:
    LD      BC, $0007
    ADD     IX, BC
    EX      AF, AF'
    DEC     A
    JR      NZ, LOC_84FD
    LD      (IY+0), $D0
    RET     

SUB_8518:
    LD      E, (IX+0)
    LD      D, (IX+1)
    LD      HL, ($706D)                 ; RAM $706D
    DB      $EB
    SBC     HL, DE
    ADD     HL, HL
    RET     C
    ADD     HL, HL
    RET     C
    ADD     HL, HL
    RET     C
    ADD     HL, HL
    RET     C
    LD      A, H
    NEG     
    RET     Z
    LD      (IY+1), A
    LD      C, (IX+2)
    LD      (IY+0), C
    CALL    SUB_8578
    LD      A, (IX+6)
    AND     $0F
    LD      (IY+3), A
    LD      A, (IX+5)
    LD      (IY+2), A
    LD      BC, $0004
    ADD     IY, BC
    RET     

SUB_8550:                                   ; SUB_8550: advance enemy animation frame (IX+6 upper nibble)
    LD      A, ($706F)                  ; RAM $706F
    LD      B, A
    LD      A, (IX+6)
    AND     $F0
    RRCA    
    RRCA    
    RRCA    
    RRCA    
    ADD     A, B
    AND     $38
    RRCA    
    RRCA    
    RRCA    
    LD      E, A
    LD      D, $00
    LD      HL, $8570
    ADD     HL, DE
    LD      A, C
    ADD     A, (HL)
    LD      (IX+2), A
    RET     
    DB      $00, $01, $02, $01, $00, $FF, $FE, $FF

SUB_8578:                                   ; SUB_8578: write one sprite record (tile,Y,X,ptr) to $7092 output list
    LD      HL, ($7092)                 ; RAM $7092
    LD      (HL), C
    INC     HL
    LD      (HL), A
    INC     HL
    PUSH    IX
    POP     DE
    LD      (HL), E
    INC     HL
    LD      (HL), D
    INC     HL
    LD      ($7092), HL                 ; RAM $7092
    LD      HL, $7091                   ; RAM $7091
    INC     (HL)
    RET     

SUB_858E:                                   ; SUB_858E: compute enemy movement: approach cannon or fly-over
    LD      C, (IX+2)
    LD      E, (IX+0)
    LD      D, (IX+1)
    BIT     0, (IX+3)
    JR      NZ, LOC_8601                    ; bit 0 of (IX+3): 1 = enemy is in fly-over phase
    LD      A, (IX+4)
    AND     $F0                             ; load (IX+4) upper nibble: enemy Y speed/height
    LD      H, A
    LD      L, $00
    SBC     HL, DE
    LD      A, H
    DEC     A
    OR      A
    JR      NZ, LOC_85B1
    LD      A, L
    AND     $C0
    JR      Z, LOC_85CB

LOC_85B1:
    LD      A, ($7263)                  ; RAM $7263
    LD      H, $00
    BIT     1, (IX+3)                       ; bit 1 of (IX+3): direction flip flag
    JR      Z, LOC_85BF
    DEC     H
    NEG     

LOC_85BF:
    LD      L, A
    ADD     HL, DE
    LD      (IX+1), H
    LD      (IX+0), L
    CALL    SUB_8550
    RET     

LOC_85CB:
    CALL    SUB_8842
    JP      Z, LOC_882C
    SET     0, (IX+3)
    LD      A, (IX+6)
    AND     $0F
    LD      (IX+6), A

LOC_85DD:
    INC     C

LOC_85DE:
    INC     C
    LD      A, $80
    LD      (IX+2), C
    SUB     C
    RET     NC
    ADD     A, $0A
    RET     NC
    CALL    SUB_8774
    LD      A, (IX+3)
    AND     $0C
    LD      B, A
    RRCA    
    RRCA    
    DEC     A
    AND     $03
    RLCA    
    CALL    SUB_8784
    LD      HL, $705D                   ; RAM $705D
    SET     2, (HL)
    RET     

LOC_8601:
    LD      HL, $705D                   ; RAM $705D
    SET     0, (HL)
    LD      A, ($706F)                  ; RAM $706F
    PUSH    DE
    SRL     A
    CALL    SUB_8738
    CALL    SUB_8745
    LD      A, C
    ADD     A, (HL)
    LD      C, A
    INC     HL
    LD      L, (HL)
    LD      H, $00
    BIT     7, L
    JR      Z, LOC_861E
    DEC     H

LOC_861E:
    POP     DE
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, DE
    LD      (IX+0), L
    LD      (IX+1), H
    LD      A, ($708A)                  ; RAM $708A
    CP      $08
    JR      NC, LOC_85DD
    LD      A, ($706F)                  ; RAM $706F
    SRL     A
    JR      C, LOC_85DE
    JR      LOC_85DD
    DB      $02, $00, $02, $00, $FF, $E0, $FF, $E0
    DB      $02, $00, $02, $00, $FF, $20, $FF, $20
    DB      $FF, $20, $FF, $20, $02, $00, $02, $00
    DB      $FF, $E0, $FF, $E0, $02, $00, $02, $00
    DB      $04, $F0, $00, $E0, $FC, $F0, $F8, $00
    DB      $FC, $10, $00, $20, $04, $10, $08, $00
    DB      $04, $F0, $00, $E0, $FC, $F0, $F8, $00
    DB      $FC, $10, $00, $20, $04, $10, $08, $00
    DB      $01, $00, $FE, $10, $FF, $F0, $FF, $F0
    DB      $01, $10, $01, $00, $FD, $20, $FF, $E0
    DB      $FF, $E0, $02, $20, $FC, $30, $FF, $D0
    DB      $FF, $D0, $02, $20, $01, $10, $00, $00
    DB      $FF, $E0, $00, $E0, $01, $E0, $01, $F0
    DB      $FF, $00, $FF, $30, $00, $30, $01, $30
    DB      $02, $30, $02, $20, $FF, $00, $FF, $E0
    DB      $00, $E0, $01, $E0, $01, $F0, $FF, $00
    DB      $04, $F0, $00, $E0, $FC, $F0, $F8, $00
    DB      $FC, $10, $00, $20, $04, $10, $08, $00
    DB      $04, $10, $00, $20, $FC, $10, $F8, $00
    DB      $FC, $F0, $00, $E0, $04, $F0, $08, $00
    DB      $FF, $F0, $00, $00, $FF, $20, $FD, $00
    DB      $FF, $D0, $02, $00, $FF, $40, $FB, $00
    DB      $FF, $B0, $04, $00, $FF, $60, $F9, $00
    DB      $FF, $90, $06, $00, $FF, $40, $02, $00
    DB      $02, $00, $02, $10, $02, $20, $01, $20
    DB      $01, $E0, $02, $E0, $02, $F0, $02, $00
    DB      $FE, $F0, $FE, $E0, $FF, $E0, $00, $E0
    DB      $00, $20, $FF, $20, $FE, $20, $FE, $10
    DB      $02, $00, $02, $00, $02, $00, $02, $00
    DB      $02, $00, $02, $00, $02, $00, $02, $00
    DB      $02, $00, $02, $00, $02, $00, $02, $00
    DB      $02, $00, $02, $00, $02, $00, $02, $00

SUB_8738:
    LD      A, (IX+6)
    RET     C
    ADD     A, $10
    LD      (IX+6), A
    CALL    C, SUB_875E
    RET     

SUB_8745:
    AND     $F0
    LD      E, A
    LD      A, (IX+4)
    SRL     A
    RR      E
    SRL     A
    RR      E
    SRL     A
    RR      E
    LD      D, $00
    LD      HL, $8638
    ADD     HL, DE
    RET     

SUB_875E:
    LD      A, (IX+2)
    CP      $5A
    RET     C
    LD      A, (IX+4)
    AND     $F0
    ADD     A, $07
    LD      (IX+4), A
    RET     

SUB_876F:
    XOR     A
    CP      (IX+5)
    RET     Z

SUB_8774:
    XOR     A
    LD      (IX+5), A
    LD      HL, $708C                   ; RAM $708C
    INC     (HL)
    LD      HL, $708D                   ; RAM $708D
    DEC     (HL)
    CALL    Z, SUB_87BB
    RET     

SUB_8784:
    LD      HL, $724F                   ; RAM $724F
    LD      E, A
    LD      D, $00
    ADD     HL, DE
    LD      A, (HL)
    CP      $37
    RET     NC
    ADD     A, $08
    LD      (HL), A
    CP      $37
    JR      NC, LOC_87A2
    LD      A, ($7258)                  ; RAM $7258
    ADD     A, $02
    LD      ($7258), A                  ; RAM $7258
    LD      D, $01
    OR      A
    RET     

LOC_87A2:
    LD      A, $48
    INC     HL
    LD      (HL), A
    LD      A, $29
    LD      ($7258), A                  ; RAM $7258
    CALL    SUB_87CF
    LD      D, $01
    LD      HL, $705D                   ; RAM $705D
    SET     1, (HL)
    RET     

SUB_87B6:
    LD      A, ($708D)                  ; RAM $708D
    OR      A
    RET     NZ

SUB_87BB:                                   ; SUB_87BB: check wave-advance conditions (enemy count vs threshold)
    LD      A, ($708E)                      ; load enemy count cap $708E
    LD      HL, $708B                   ; RAM $708B
    SUB     (HL)                            ; SUB (HL): compare against $708B (current enemy count)
    RET     C                               ; if count already exceeded cap: return (no wave advance)
    LD      A, ($7231)                      ; load kill count $7231
    DEC     A
    LD      HL, $7226                       ; HL = $7226: kills needed for wave
    SUB     (HL)
    JP      C, LOC_8AF1                     ; if kills-needed not yet reached: advance to next wave (LOC_8AF1)
    RET     

SUB_87CF:                                   ; SUB_87CF: reassign wave tile to all enemies of matching type
    PUSH    IX                              ; save IX
    LD      IX, $70A8                       ; IX = $70A8: enemy table base
    LD      DE, $0007
    CALL    SUB_880E                        ; SUB_880E: find free enemy slot, return index in C
    LD      A, C
    RLCA    
    RLCA    
    RLCA    
    RLCA    
    LD      H, A
    LD      A, $12

LOC_87E3:
    PUSH    AF
    LD      A, (IX+3)
    AND     $0C
    CP      B
    JR      NZ, LOC_8804
    LD      A, $68
    CP      (IX+2)
    CALL    C, SUB_876F
    LD      (IX+3), C
    LD      A, (IX+4)
    AND     $0F
    XOR     H
    LD      (IX+4), A
    LD      A, $02
    XOR     C
    LD      C, A

LOC_8804:
    ADD     IX, DE
    POP     AF
    DEC     A
    JR      NZ, LOC_87E3
    POP     IX
    SCF     
    RET     

SUB_880E:                                   ; SUB_880E: scan $7250 table for $3C (dead) slot; return slot offset in C
    LD      HL, $7250                       ; HL = $7250: enemy spawn table
    LD      C, $04                          ; C = $04: slot 0 offset
    LD      A, $3C                          ; test value $3C (dead marker)
    CP      (HL)                            ; is slot 0 dead?
    RET     Z                               ; yes: return with C=$04 (slot 0 free)
    INC     HL                              ; advance to slot 1
    INC     HL
    LD      C, $08                          ; C = $08: slot 1 offset
    CP      (HL)                            ; is slot 1 dead?
    RET     Z                               ; yes: return C=$08
    INC     HL
    INC     HL                              ; advance to slot 2
    LD      C, $0C                          ; C = $0C: slot 2 offset
    CP      (HL)                            ; is slot 2 dead?
    RET     Z                               ; yes: return C=$0C
    INC     HL
    INC     HL                              ; advance to slot 3
    LD      C, $00                          ; C = $00: slot 3 offset (also special code)
    CP      (HL)                            ; is slot 3 dead?
    RET     Z                               ; yes: return C=$00
    JP      SUB_897E                        ; all slots full: call SUB_897E (player state init / game over path)

LOC_882C:
    CALL    SUB_880E
    LD      (IX+3), C
    LD      A, C
    RLCA    
    RLCA    
    RLCA    
    RLCA    
    LD      C, A
    LD      A, (IX+4)
    AND     $0F
    XOR     C
    LD      (IX+4), A
    RET     

SUB_8842:                                   ; SUB_8842: collision test: check enemy slot (IX+3) for $6C (hit marker)
    LD      A, (IX+3)                       ; load enemy slot index (IX+3)
    SUB     $04                             ; subtract 4 to get zero-based slot
    AND     $0C                             ; isolate slot number (bits 2-3)
    RRCA                                    ; RRCA: convert to byte offset
    LD      E, A
    LD      D, $00
    LD      HL, $7250                       ; HL = $7250: enemy spawn table
    ADD     HL, DE
    LD      A, (HL)                         ; load slot value
    CP      $6C                             ; CP $6C: $6C = collision/hit marker
    RET     
    DB      $06, $08, $21, $7E, $88, $FD, $21, $C0
    DB      $3E, $C5, $E5, $3A, $6F, $70, $E6, $0C
    DB      $07, $5F, $16, $00, $19, $FD, $E5, $D1
    DB      $01, $08, $00, $CD, $2D, $83, $E1, $C1
    DB      $11, $20, $00, $19, $FD, $19, $10, $E1
    DB      $C9, $18, $24, $5A, $AB, $3C, $42, $81
    DB      $81, $18, $3C, $5A, $D5, $3C, $24, $24
    DB      $24, $18, $24, $5A, $AB, $3C, $18, $18
    DB      $18, $18, $3C, $5A, $D5, $3C, $18, $10
    DB      $00, $00, $00, $00, $EF, $F7, $00, $00
    DB      $00, $00, $00, $18, $76, $6E, $18, $00
    DB      $00, $00, $18, $18, $2C, $34, $18, $18
    DB      $00, $18, $18, $18, $10, $08, $18, $18
    DB      $18, $18, $28, $48, $90, $90, $48, $28
    DB      $18, $08, $18, $28, $58, $58, $28, $18
    DB      $08, $10, $18, $14, $0A, $0A, $14, $18
    DB      $10, $18, $14, $12, $19, $19, $12, $14
    DB      $18, $00, $02, $E2, $3E, $24, $7C, $47
    DB      $40, $00, $00, $0C, $7C, $66, $3E, $30
    DB      $00, $00, $10, $18, $3F, $66, $FC, $18
    DB      $08, $00, $00, $10, $3E, $24, $7C, $08
    DB      $00, $18, $3C, $7E, $77, $77, $7E, $3C
    DB      $18, $18, $3C, $FF, $EE, $EE, $FF, $3C
    DB      $18, $18, $3C, $FF, $DD, $DD, $FF, $3C
    DB      $18, $18, $3C, $FF, $BB, $BB, $FF, $3C
    DB      $18, $00, $AA, $54, $28, $10, $28, $54
    DB      $AA, $00, $FE, $54, $38, $10, $38, $54
    DB      $FE, $00, $00, $00, $FE, $D6, $FE, $00
    DB      $00, $00, $EE, $C6, $82, $54, $82, $C6
    DB      $EE, $05, $00, $11, $02, $40, $88, $00
    DB      $A0, $02, $09, $00, $20, $04, $00, $90
    DB      $40, $A0, $00, $84, $40, $02, $21, $00
    DB      $09, $40, $90, $00, $04, $20, $00, $09
    DB      $02, $00, $18, $5A, $BD, $5A, $BD, $5A
    DB      $5A, $00, $5A, $F7, $F7, $B5, $F7, $F7
    DB      $18, $00, $18, $EF, $EF, $EF, $AD, $EF
    DB      $5A, $00, $5A, $BD, $5A, $BD, $5A, $BD
    DB      $18

SUB_897E:                                   ; SUB_897E: player state init (reset after wave/death)
    XOR     A                               ; XOR A: A = 0
    LD      (JOYSTICK_BUFFER), A            ; clear JOYSTICK_BUFFER
    LD      ($706C), A                      ; clear $706C (cannon horizontal)
    LD      A, $B4                          ; A = $B4 = 180 frames
    LD      ($7258), A                      ; set wave timer $7258 = $B4 (180 frames for cannon deploy)
    LD      A, $72                          ; A = $72 = intro/title state
    LD      ($705C), A                      ; set game state $705C = $72 (intro)
    RET     

LOC_8990:                                   ; LOC_8990: game screen setup -- load level tiles and init display
    LD      HL, $A62A                       ; HL = $A62A: tile pattern data
    LD      DE, $0300                       ; DE = $0300: VRAM pattern table
    LD      BC, $00D0                       ; BC = $D0: 208 bytes
    CALL    VDP_WRITE_832D                  ; LDIR tile patterns to VRAM $0300
    LD      HL, $A000
    LD      DE, $1800
    LD      BC, $01A0
    CALL    VDP_WRITE_832D                  ; write full name table from $A000 ($01A0 bytes to $1800)
    LD      HL, $18E9
    LD      DE, $18EC
    LD      HL, $89FE
    CALL    SUB_9297
    CALL    SUB_9B8E
    LD      A, $73
    LD      ($705C), A                  ; RAM $705C
    LD      A, $C8
    LD      ($705E), A                  ; RAM $705E
    JP      LOC_82D3

LOC_89C4:                                   ; LOC_89C4: life countdown timer -- DEC $705E, jump to START if zero
    DEC     A                               ; DEC A: decrement life timer
    LD      ($705E), A                      ; store decremented life timer
    JP      Z, START                        ; JP Z, START: lives = 0 -> game over (full restart)
    LD      B, $00                          ; B = $00: tile 0 (blank) for status row
    LD      DE, $2003
    CALL    VDP_WRITE_830C                  ; write blank tile to sprite row position
    LD      B, $D0                          ; B = $D0: 'D' tile for 'DEAD' indicator
    LD      DE, $1B38
    CALL    VDP_WRITE_830C                  ; write 'D' indicator to score line
    LD      B, $C8                          ; B = $C8: life count tile
    LD      DE, $1B00
    CALL    VDP_WRITE_830C                  ; display remaining lives digit
    LD      DE, $1B10                       ; more life display tiles...
    CALL    VDP_WRITE_830C
    LD      DE, $1B04
    CALL    VDP_WRITE_830C
    LD      DE, $1B08
    CALL    VDP_WRITE_830C
    LD      DE, $1B0C
    CALL    VDP_WRITE_830C
    JP      LOC_82D3                        ; JP LOC_82D3: exit NMI after death display
    DB      $47, $41, $4D, $45, $20, $4F, $56, $45 ; "GAME OVE"
    DB      $52, $00, $2A, $2E, $72, $EB, $21, $00
    DB      $00, $ED, $52, $22, $2E, $72, $C9, $3E
    DB      $01, $32, $8F, $70, $C9, $CD, $FD, $1F
    DB      $FE, $04, $DC, $08, $8A, $3A, $5C, $72
    DB      $B7, $C0, $3A, $8B, $70, $21, $8E, $70
    DB      $96, $28, $E4, $E6, $01, $20, $01, $3C
    DB      $47, $3A, $8D, $70, $80, $FE, $12, $D0
    DB      $32, $8D, $70, $78, $86, $77, $C5, $CD
    DB      $55, $8A, $CD, $65, $8A, $CD, $85, $8A
    DB      $CD, $C2, $8A, $C1, $10, $F0, $C9, $DD
    DB      $21, $A8, $70, $11, $07, $00, $AF, $DD
    DB      $BE, $05, $C8, $DD, $19, $18, $F8, $2A
    DB      $6D, $70, $11, $00, $80, $19, $78, $07
    DB      $07, $07, $5F, $16, $00, $19, $DD, $75
    DB      $00, $DD, $74, $01, $CD, $FD, $1F, $E6
    DB      $38, $C6, $08, $DD, $77, $02, $C9, $CD
    DB      $FD, $1F, $E6, $0E, $DD, $77, $03, $CB
    DB      $8F, $07, $07, $07, $07, $4F, $C5, $CD
    DB      $A7, $8A, $C1, $A9, $DD, $77, $04, $07
    DB      $07, $E6, $1C, $C6, $D8, $DD, $77, $05
    DB      $C9, $3A, $8A, $70, $CD, $F9, $8F, $3D
    DB      $FE, $08, $D8, $D6, $08, $E6, $07, $3C
    DB      $47, $21, $90, $70, $7E, $3C, $34, $B8
    DB      $C0, $AF, $77, $C9, $CD, $FD, $1F, $DD
    DB      $77, $06, $E6, $0F, $28, $F6, $FE, $01
    DB      $28, $F2, $C9, $0F, $14, $19, $1E, $23
    DB      $28, $2D, $32, $08, $10, $10, $18, $20
    DB      $28, $30, $48, $02, $04, $06, $08, $0A
    DB      $0C, $0E, $10, $FF, $FF, $7F, $7F, $7F
    DB      $3F, $3F, $1F

LOC_8AF1:                                   ; LOC_8AF1: clear enemy RAM and load difficulty tables for new wave
    LD      D, $00                          ; D = 0: fill value
    LD      HL, $70A8                       ; HL = $70A8: enemy record table
    LD      B, $7E                          ; B = $7E: 126 bytes to zero (18 enemies x 7 bytes)

LOC_8AF8:
    LD      (HL), D                         ; zero enemy record byte
    INC     HL
    DJNZ    LOC_8AF8                        ; loop: zero all 126 enemy bytes
    LD      HL, $7232                       ; HL = $7232: kill-record table
    LD      B, $10                          ; B = $10: 16 bytes to zero

LOC_8B01:
    LD      (HL), D                         ; zero kill-record byte
    INC     HL
    DJNZ    LOC_8B01                        ; loop: zero 16 kill-record bytes
    LD      A, ($708A)                      ; load wave index $708A
    CALL    SUB_8FF9                        ; SUB_8FF9: convert BCD wave index to binary (A = BCD_to_bin(A))
    SRL     A                               ; SRL A: divide by 2 (cap to 4-level difficulty table)
    LD      B, A                            ; B = difficulty index
    LD      A, ($7059)                      ; load selected difficulty $7059 (0=CADET, 2=CAPTAIN, 4=ADMIRAL)
    ADD     A, B                            ; ADD A, B: combine wave level + difficulty
    CP      $08                             ; cap at 8 max entries
    JR      C, LOC_8B18
    LD      A, $07                          ; cap: use index 7

LOC_8B18:
    LD      E, A                            ; E = combined difficulty index
    LD      D, $00
    LD      HL, $8AD1                       ; HL = $8AD1: difficulty parameter table base
    ADD     HL, DE
    LD      A, (HL)                         ; load from table
    LD      ($708B), A                      ; LD $708B: enemy count limit for this wave
    LD      DE, $0008
    ADD     HL, DE                          ; advance 8 bytes to next sub-table
    LD      A, (HL)
    LD      ($7263), A                      ; LD $7263: enemy approach speed parameter
    SRA     A
    LD      ($722E), A                      ; SRA A: half-speed for laser approach
    XOR     A                               ; LD $722E: laser approach speed
    LD      ($722F), A                      ; zero upper byte $722F
    LD      DE, $0008
    ADD     HL, DE
    LD      A, (HL)
    LD      ($7231), A                      ; LD $7231: kill count needed to end wave
    LD      DE, $0008
    ADD     HL, DE
    LD      A, (HL)
    LD      ($7245), A                      ; LD $7245: frame-phase mask for enemy fire rate
    XOR     A
    LD      ($7226), A                      ; zero kill count accumulator $7226
    LD      ($708C), A                      ; zero enemy counter $708C
    LD      ($7230), A                      ; zero $7230 (wave kill cache)
    LD      ($7227), A                      ; zero $7227
    LD      ($708F), A                  ; RAM $708F
    LD      ($708D), A                      ; zero $708F
    LD      ($708E), A                      ; zero $708D
    XOR     A                               ; zero $708E
    LD      ($706B), A                      ; zero player-state $706B
    CALL    LOC_95B7                        ; LOC_95B7: init cannon sprite timing ($7268=$04, $726C=$08)
    LD      HL, $708A                   ; RAM $708A
    CALL    SUB_9291                        ; SUB_9291: BCD increment wave index $708A
    CALL    SUB_9007                        ; SUB_9007: load enemy type table for this wave
    RET     
    DB      $3A, $5C, $72, $B7, $C0, $3A, $E2, $72
    DB      $FE, $40, $C0, $3A, $71, $70, $FE, $04
    DB      $C8, $3C, $32, $71, $70, $CD, $8C, $8B
    DB      $CD, $9D, $8B, $06, $05, $CD, $F1, $1F
    DB      $C9, $DD, $21, $72, $70, $3E, $00, $01
    DB      $07, $00, $DD, $BE, $00, $C8, $DD, $09
    DB      $18, $F8, $CD, $BA, $8B, $CD, $CB, $8B
    DB      $CD, $D8, $8B, $CD, $E0, $8B, $5F, $CD
    DB      $F5, $8B, $7D, $AB, $DD, $77, $01, $DD
    DB      $74, $02, $DD, $36, $06, $2F, $C9, $3A
    DB      $67, $72, $FE, $10, $20, $05, $DD, $36
    DB      $00, $02, $C9, $DD, $36, $00, $FF, $C9
    DB      $3A, $65, $72, $21, $68, $70, $86, $C6
    DB      $05, $DD, $77, $04, $C9, $E6, $07, $C6
    DB      $18, $DD, $77, $03, $C9, $3A, $66, $72
    DB      $DD, $77, $05, $CB, $3F, $CB, $3F, $CB
    DB      $3F, $DD, $86, $00, $7F, $DD, $CB, $00
    DB      $2E, $C9, $DD, $7E, $04, $E6, $F8, $6F
    DB      $26, $00, $29, $29, $C9

SUB_8C00:                                   ; SUB_8C00: sprite renderer -- draw 4 active projectile/cannon objects
    LD      IX, $7072                       ; IX = $7072: sprite object table (4 slots x 7 bytes)
    LD      DE, $0007                       ; DE = $0007: stride between slots
    LD      B, $04                          ; B = 4: 4 active objects

LOC_8C09:
    LD      A, (IX+0)                       ; load slot active flag (IX+0): 0=inactive, 1=moving left, 2=moving right
    CP      $00                             ; CP $00: inactive?
    JR      Z, LOC_8C38                     ; inactive: skip slot
    EXX     
    LD      L, (IX+1)
    LD      H, (IX+2)                       ; HL = (IX+2:1): current VRAM tile pointer
    LD      A, (IX+0)                       ; load direction flag again
    DEC     A                               ; DEC A: was it 1 (left)?
    JR      Z, LOC_8C47                     ; yes: jump to left-move handler
    INC     HL                              ; INC HL: advance right
    CALL    SUB_8C80                        ; SUB_8C80: check column boundary
    DEC     HL
    LD      A, L                            ; A = L AND $1F: check if at right edge of row ($1F)
    AND     $1F                             ; at edge? go handle wrap
    JR      Z, LOC_8C63
    CALL    VDP_WRITE_831B                  ; VDP_WRITE_831B: read tile from VRAM at HL+$1800 (read old tile)
    LD      (IX+6), A                       ; save old tile value in (IX+6)
    LD      B, (IX+3)
    CALL    SUB_8354                        ; SUB_8354: write saved tile back (erase old sprite position)
    DEC     HL
    CALL    SUB_8C6D                        ; SUB_8C6D: update IX+1/2 and commit new VRAM write address

LOC_8C37:
    EXX     

LOC_8C38:
    ADD     IX, DE
    DJNZ    LOC_8C09
    LD      HL, $7126                       ; HL = $7126: sprite output buffer base address
    LD      ($7092), HL                     ; reset sprite output pointer $7092 to buffer start
    XOR     A
    LD      ($7091), A                      ; zero sprite count $7091
    RET     

LOC_8C47:
    DEC     HL
    CALL    SUB_8C80
    INC     HL
    LD      A, L
    AND     $1F
    JR      Z, LOC_8C63
    CALL    VDP_WRITE_831B
    LD      (IX+6), A
    LD      B, (IX+3)
    CALL    SUB_8354
    INC     HL
    CALL    SUB_8C6D
    JR      LOC_8C37

LOC_8C63:
    LD      HL, $7071                   ; RAM $7071
    DEC     (HL)
    XOR     A
    LD      (IX+0), A
    JR      LOC_8C37

SUB_8C6D:
    LD      (IX+1), L
    LD      (IX+2), H
    LD      A, L
    AND     $1F
    RLCA    
    RLCA    
    RLCA    
    LD      (IX+5), A
    CALL    SUB_8C8A
    RET     

SUB_8C80:
    LD      A, (IX+6)
    LD      B, A
    CP      $2F
    CALL    NZ, SUB_8354
    RET     

SUB_8C8A:
    LD      HL, $7126                   ; RAM $7126
    LD      A, ($7091)                  ; RAM $7091
    OR      A
    RET     Z
    LD      B, A

LOC_8C93:
    LD      A, (HL)
    SUB     (IX+4)
    JR      NC, LOC_8CD8
    ADD     A, $08
    JR      NC, LOC_8CD8
    INC     HL
    LD      C, (HL)
    DEC     HL
    LD      D, (IX+5)
    LD      A, $07
    ADD     A, D
    CP      C
    JR      C, LOC_8CD8
    LD      A, C
    ADD     A, $07
    CP      D
    JR      C, LOC_8CD8
    CALL    LOC_8CC0
    LD      A, $01
    CALL    SUB_92AC
    CALL    SUB_8E33
    LD      HL, $705D                   ; RAM $705D
    SET     3, (HL)
    RET     

LOC_8CC0:
    INC     HL
    INC     HL
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    PUSH    DE
    POP     IY
    LD      (IY+5), $00
    LD      HL, $708C                   ; RAM $708C
    INC     (HL)
    LD      HL, $708D                   ; RAM $708D
    DEC     (HL)
    CALL    Z, SUB_87BB
    RET     

LOC_8CD8:
    INC     HL
    INC     HL
    INC     HL
    INC     HL
    DJNZ    LOC_8C93
    XOR     A
    RET     
    DB      $3A, $5C, $72, $B7, $C2, $CE, $92, $3A
    DB      $DF, $72, $FE, $40, $C2, $CE, $92, $CD
    DB      $D7, $92, $3A, $6F, $70, $E6, $0F, $C0
    DB      $CD, $0D, $8D, $CD, $22, $8D, $CD, $2B
    DB      $8D, $CD, $34, $8D, $CD, $3B, $8D, $21
    DB      $5D, $70, $CB, $F6, $C9, $DD, $21, $1E
    DB      $72, $3E, $80, $01, $04, $00, $DD, $BE
    DB      $03, $C8, $DD, $09, $DD, $BE, $03, $C8
    DB      $E1, $C9, $3A, $66, $72, $C6, $04, $DD
    DB      $77, $00, $C9, $3A, $65, $72, $C6, $05
    DB      $DD, $77, $01, $C9, $3A, $6C, $70, $DD
    DB      $77, $03, $C9, $DD, $36, $02, $03, $C9
    DB      $DD, $21, $1E, $72, $DD, $7E, $03, $FE
    DB      $80, $28, $0E, $D9, $CD, $71, $8D, $CD
    DB      $86, $8D, $CD, $8F, $8D, $CD, $1C, $8E
    DB      $D9, $11, $04, $00, $DD, $19, $DD, $7E
    DB      $03, $FE, $80, $C8, $CD, $71, $8D, $CD
    DB      $86, $8D, $CD, $8F, $8D, $CD, $22, $8E
    DB      $C9, $3A, $6C, $70, $DD, $96, $03, $CB
    DB      $2F, $CB, $2F, $CB, $2F, $CB, $2F, $DD
    DB      $86, $00, $DD, $77, $00, $C9, $DD, $7E
    DB      $02, $C6, $01, $DD, $77, $02, $C9, $DD
    DB      $46, $01, $80, $DD, $77, $01, $FE, $8F
    DB      $D8, $DD, $36, $03, $80, $DD, $36, $01
    DB      $C8, $CD, $A8, $8D, $CD, $C9, $8D, $C9
    DB      $DD, $7E, $00, $E6, $F8, $0F, $0F, $0F
    DB      $16, $00, $5F, $21, $40, $1A, $19, $CD
    DB      $42, $8E, $FD, $75, $00, $FD, $74, $01
    DB      $FD, $36, $03, $04, $FD, $36, $02, $15
    DB      $C9, $3A, $77, $72, $FE, $BC, $D8, $21
    DB      $32, $72, $3A, $2B, $72, $5F, $16, $00
    DB      $19, $3E, $01, $BE, $C0, $DD, $7E, $00
    DB      $3C, $47, $3A, $76, $72, $B8, $D0, $C6
    DB      $12, $B8, $D8, $3E, $11, $32, $28, $72
    DB      $22, $29, $72, $3E, $10, $CD, $AC, $92
    DB      $21, $5D, $70, $CB, $E6, $3E, $A8, $32
    DB      $77, $72, $C9

SUB_8E03:                                   ; SUB_8E03: kill-animation done -- advance kill count, trigger next wave
    LD      A, $C8
    LD      ($7275), A                      ; reset kill-animation counter $7275 = $C8
    LD      ($7271), A                      ; reset kill-animation alt counter $7271 = $C8
    LD      A, $00
    LD      HL, ($7229)                     ; load kill-animation target pointer $7229
    LD      (HL), A
    LD      A, ($7226)                      ; load kill count $7226
    INC     A                               ; INC A: count this kill
    LD      ($7226), A                      ; store updated kill count
    CALL    SUB_87B6                        ; SUB_87B6: check if wave-advance conditions now met
    RET     
    DB      $FD, $21, $9D, $72, $18, $04, $FD, $21
    DB      $A1, $72, $DD, $7E, $01, $FD, $77, $00
    DB      $DD, $7E, $00, $FD, $77, $01, $C9

SUB_8E33:
    CALL    DELAY_LOOP_8E42
    CALL    SUB_8E57
    LD      (IY+2), $60
    LD      (IY+3), $06
    RET     

DELAY_LOOP_8E42:                            ; DELAY_LOOP_8E42: find next free projectile slot in $7094 table
    LD      IY, $7094                       ; IY = $7094: projectile table (5 slots x 4 bytes)
    LD      A, $00
    LD      DE, $0004                       ; DE = $0004: slot stride
    LD      B, $05                          ; B = $05: 5 slots to check

LOC_8E4D:
    CP      (IY+3)                          ; CP (IY+3): is slot type = 0 (free)?
    RET     Z                               ; yes: return with IY pointing to free slot
    ADD     IY, DE
    DJNZ    LOC_8E4D                        ; DJNZ: check next slot
    POP     HL                              ; POP HL (= return address = caller's next instruction)
    RET                                     ; RET: skip the caller's next instruction (no free slot -- bail)

SUB_8E57:
    LD      L, (IX+1)
    LD      (IY+0), L
    LD      H, (IX+2)
    LD      (IY+1), H
    RET     

DELAY_LOOP_8E64:                            ; DELAY_LOOP_8E64: advance active projectile slots each frame
    LD      B, $05                          ; B = 5: 5 projectile slots
    LD      IY, $7094                       ; IY = $7094: projectile table
    LD      DE, $0004                       ; DE = $0004: slot stride

LOC_8E6D:
    LD      A, (IY+3)                       ; load slot type (IY+3)
    CP      $00                             ; CP $00: inactive slot?
    JR      Z, LOC_8E79                     ; yes: skip update
    EXX                                     ; EXX: swap to alternate registers for animation step
    CALL    SUB_8F07                        ; SUB_8F07: advance projectile one step toward screen edge
    EXX     

LOC_8E79:
    ADD     IY, DE
    DJNZ    LOC_8E6D
    RET     

SUB_8E7E:                                   ; SUB_8E7E: animation master timer
    CALL    DELAY_LOOP_99EE                 ; DELAY_LOOP_99EE: age enemy spawn table slots ($7250 each 16 frames)
    LD      A, ($7228)                      ; load kill-animation counter $7228
    OR      A
    JR      Z, LOC_8E8E                     ; zero: no kill animation active
    DEC     A                               ; DEC A: count down kill animation
    LD      ($7228), A                      ; store
    CALL    Z, SUB_8E03                     ; if hit zero: call SUB_8E03 (kill-animation complete)

LOC_8E8E:
    LD      A, ($7258)                      ; load wave timer $7258
    OR      A
    RET     Z                               ; zero: wave deploy complete -- nothing to do
    DEC     A                               ; DEC A: decrement wave timer
    LD      ($7258), A                      ; store
    AND     $01                             ; AND $01: odd frame?
    JR      Z, LOC_8EF7                     ; even frame: run alternate cannon deploy sequence
    LD      IX, $8EFD                       ; IX = $8EFD: cannon-right deploy bitmap data

LOC_8E9F:
    LD      A, (IX+3)
    LD      HL, $200C
    LD      DE, $0006
    CALL    VDP_WRITE_8342
    LD      B, (IX+0)
    LD      DE, $2003
    CALL    VDP_WRITE_830C
    LD      DE, $2006
    LD      B, (IX+1)
    CALL    VDP_WRITE_830C
    INC     DE
    LD      B, (IX+2)
    CALL    VDP_WRITE_830C
    INC     DE
    LD      B, (IX+3)
    CALL    VDP_WRITE_830C
    LD      A, (IX+4)
    LD      DE, $0008
    LD      HL, $2012
    CALL    VDP_WRITE_8342
    LD      A, ($705C)                  ; RAM $705C
    CP      $72
    RET     NZ
    LD      A, ($7258)                  ; RAM $7258
    OR      A
    POP     HL
    JP      Z, LOC_8990
    CALL    SUB_9907
    LD      HL, $7279                   ; RAM $7279
    LD      DE, $1B14
    LD      BC, $000C
    CALL    VDP_WRITE_832D
    JP      LOC_82D3

LOC_8EF7:
    LD      IX, $8F02
    JR      LOC_8E9F
    DB      $1F, $1F, $7F, $9F, $F0, $71, $71, $31
    DB      $B1, $0D

SUB_8F07:                                   ; SUB_8F07: advance one projectile step (called every 4 frames)
    LD      L, (IY+0)                       ; L = (IY+0), H = (IY+1): current tile position
    LD      H, (IY+1)
    LD      A, (IY+2)                       ; A = (IY+2): projectile type
    CP      $15                             ; CP $15: type $15 = 'eraser' (clear tile only)
    JR      Z, LOC_8F8B
    LD      A, ($706F)                      ; load frame counter $706F
    AND     $03                             ; AND $03: only run on every 4th frame
    RET     NZ                              ; skip if not 4th frame
    DEC     (IY+3)                          ; DEC (IY+3): countdown timer for this step
    JR      NZ, LOC_8F62
    PUSH    IX
    PUSH    HL
    LD      DE, $A000
    ADD     HL, DE
    LD      DE, $0020
    SCF     
    SBC     HL, DE
    PUSH    HL
    POP     IX
    POP     HL
    LD      DE, $1800
    ADD     HL, DE
    LD      DE, $0020
    SCF     
    SBC     HL, DE
    LD      C, $03
    PUSH    IY

LOC_8F3E:
    PUSH    HL
    PUSH    DE
    DB      $EB
    LD      B, (IX+0)
    CALL    VDP_WRITE_830C
    INC     DE
    LD      B, (IX+1)
    CALL    VDP_WRITE_830C
    INC     DE
    LD      B, (IX+2)
    CALL    VDP_WRITE_830C
    POP     DE
    POP     HL
    ADD     HL, DE
    ADD     IX, DE
    DEC     C
    JR      NZ, LOC_8F3E
    POP     IY
    POP     IX
    RET     

LOC_8F62:
    LD      A, (IY+3)
    DEC     A
    LD      B, A
    ADD     A, A
    ADD     A, A
    ADD     A, A
    ADD     A, B
    ADD     A, (IY+2)
    LD      B, A
    LD      DE, $1800
    ADD     HL, DE
    LD      DE, $0020
    SCF     
    SBC     HL, DE
    CALL    VDP_WRITE_82EE
    INC     B
    INC     B
    INC     B
    ADD     HL, DE
    CALL    VDP_WRITE_82EE
    INC     B
    INC     B
    INC     B
    ADD     HL, DE
    CALL    VDP_WRITE_82EE
    RET     

LOC_8F8B:                                   ; LOC_8F8B: eraser-type projectile update (erase a tile)
    LD      A, ($706F)                      ; load frame counter $706F
    AND     $03
    RET     NZ                              ; only run on 4th frame
    DEC     (IY+3)                          ; DEC (IY+3): decrement erase step counter
    JR      NZ, LOC_8F9D                    ; not done: go write partial erase tile
    LD      B, $10
    DB      $EB                             ; B = $10: blank tile
    CALL    VDP_WRITE_830C                  ; VDP_WRITE_830C: write blank tile to VRAM (complete erase)
    RET     

LOC_8F9D:
    LD      A, (IY+2)
    ADD     A, (IY+3)
    DEC     A
    LD      B, A
    DB      $EB
    CALL    VDP_WRITE_830C
    RET     
    DB      $6B, $8B, $07, $02, $32, $94, $01, $00
    DB      $55, $88, $03, $00, $6D, $AE, $07, $01
    DB      $E0, $8C, $01, $00, $40, $8D, $01, $01
    DB      $F0, $93, $7F, $07, $1B, $8A, $3F, $06
    DB      $B2, $96, $3F, $05

SUB_8FCE:                                   ; SUB_8FCE: joystick-action dispatcher -- 9-entry jump table at $8FAA
    LD      A, $09                          ; A = 9: 9 table entries
    LD      IX, $8FAA                       ; IX = $8FAA: jump table base (each entry: address 2B + mask 1B + phase 1B)

LOC_8FD4:
    PUSH    IX
    PUSH    AF
    LD      A, ($706F)                      ; load frame counter $706F
    AND     (IX+2)                          ; AND (IX+2): apply frame-phase mask
    CP      (IX+3)                          ; CP (IX+3): does frame match trigger phase?
    JR      NZ, LOC_8FED                    ; no match: skip this entry
    LD      L, (IX+0)                       ; L = (IX+0), H = (IX+1): function address
    LD      H, (IX+1)
    LD      DE, LOC_8FED                    ; push return address (LOC_8FED)
    PUSH    DE
    JP      (HL)                            ; JP (HL): dispatch to function

LOC_8FED:                                   ; LOC_8FED: post-dispatch: advance to next table entry
    POP     AF
    POP     IX
    LD      DE, $0004
    ADD     IX, DE
    DEC     A                               ; DEC A: entries remaining
    JR      NZ, LOC_8FD4                    ; loop
    RET     

SUB_8FF9:
    LD      B, A
    AND     $0F
    LD      C, A
    LD      A, B
    AND     $F0
    RRCA    
    LD      B, A
    RRCA    
    RRCA    
    ADD     A, B
    ADD     A, C
    RET     

SUB_9007:
    LD      A, ($708A)                  ; RAM $708A
    CALL    SUB_8FF9
    DEC     A
    AND     $07
    RLCA    
    RLCA    
    RLCA    
    RLCA    
    LD      E, A
    LD      D, $00
    LD      HL, $903A
    ADD     HL, DE
    LD      ($725A), HL                 ; RAM $725A
    LD      A, $F0
    LD      ($725C), A                  ; RAM $725C
    LD      A, $1E
    LD      ($725F), A                  ; RAM $725F
    LD      HL, $724D                   ; RAM $724D
    LD      ($7260), HL                 ; RAM $7260
    LD      A, $05
    LD      ($7262), A                  ; RAM $7262
    LD      HL, $1A3B
    LD      ($725D), HL                 ; RAM $725D
    RET     
    DB      $20, $4F, $52, $49, $4F, $4E, $20, $46 ; " ORION F"
    DB      $49, $47, $48, $54, $45, $52, $53, $00
    DB      $20, $20, $20, $47, $52, $41, $56, $49 ; "   GRAVI"
    DB      $54, $49, $4E, $45, $53, $20, $20, $00
    DB      $20, $20, $41, $53, $54, $52, $4F, $20 ; "  ASTRO "
    DB      $53, $41, $49, $4C, $4F, $52, $53, $00
    DB      $20, $20, $20, $20, $20, $51, $55, $45 ; "     QUE"
    DB      $4D, $45, $4E, $53, $20, $20, $20, $00
    DB      $20, $20, $44, $49, $56, $49, $4E, $47 ; "  DIVING"
    DB      $20, $44, $52, $4F, $4E, $45, $53, $00
    DB      $20, $20, $20, $20, $20, $53, $4F, $4E ; "     SON"
    DB      $41, $44, $53, $20, $20, $20, $20, $00
    DB      $20, $20, $20, $20, $20, $57, $49, $4E ; "     WIN"
    DB      $54, $4F, $4B, $53, $20, $20, $20, $00
    DB      $20, $20, $20, $20, $20, $54, $52, $4F ; "     TRO"
    DB      $45, $4B, $53, $20, $20, $20, $20, $00

SUB_90BA:
    LD      A, (HL)
    CP      $37
    RET     NC
    AND     $38
    RRCA    
    RRCA    
    RRCA    
    NEG     
    ADD     A, $09
    PUSH    AF
    CALL    SUB_92AC
    POP     AF
    LD      HL, ($725D)                 ; RAM $725D
    LD      BC, $0008
    ADD     HL, BC
    LD      ($725D), HL                 ; RAM $725D
    DB      $EB
    CALL    SUB_9279
    XOR     A
    CALL    SUB_9279
    XOR     A
    CALL    SUB_9279
    CALL    SUB_90E6
    RET     

SUB_90E6:
    OR      A
    DB      $EB
    LD      DE, $0065
    SBC     HL, DE
    DB      $EB
    LD      HL, $0020
    ADD     HL, DE
    LD      C, $06
    LD      B, $7A

LOC_90F6:
    CALL    VDP_WRITE_830C
    INC     DE
    DB      $EB
    INC     B
    CALL    VDP_WRITE_830C
    INC     DE
    DB      $EB
    INC     B
    DEC     C
    JR      NZ, LOC_90F6
    LD      B, $11
    CALL    PLAY_IT
    LD      B, $0C
    CALL    PLAY_IT
    RET     

SUB_9110:
    LD      HL, $A62A
    LD      DE, $0300
    LD      BC, $00D0
    CALL    VDP_WRITE_832D
    LD      HL, $A000
    LD      DE, $1800
    LD      BC, $01E0
    CALL    VDP_WRITE_832D
    LD      HL, $A8CB
    LD      DE, $03D0
    LD      BC, $0060
    CALL    VDP_WRITE_832D
    LD      B, $41
    LD      DE, $2009
    CALL    VDP_WRITE_830C
    INC     DE
    CALL    VDP_WRITE_830C
    XOR     A
    LD      ($706C), A                  ; RAM $706C
    LD      B, $D0
    LD      DE, $1B00
    CALL    VDP_WRITE_830C
    LD      HL, $1980
    LD      DE, $0120
    LD      A, $30
    CALL    VDP_WRITE_8342
    LD      HL, $1AA0
    LD      DE, $0020
    LD      A, $1F
    CALL    VDP_WRITE_8342
    LD      HL, $1980
    LD      DE, $0020
    LD      A, $18
    CALL    VDP_WRITE_8342
    LD      HL, $9225
    LD      DE, $18EE
    CALL    SUB_9297
    RET     

LOC_9177:                                   ; LOC_9177: wave/boss transition state machine
    LD      A, ($705C)                      ; load game state $705C
    CP      $72                             ; CP $72: intro screen?
    JP      Z, LOC_82D3                     ; if intro: skip wave sequence (NMI exit)
    CP      $73                             ; CP $73: in-game?
    JP      Z, LOC_82D3                     ; if in-game: skip (NMI exit)
    LD      B, $80                          ; B = $80: VDP register data
    LD      C, $01                          ; C = $01: VDP register number
    CALL    WRITE_REGISTER                  ; WRITE_REGISTER: disable display briefly
    LD      A, ($7262)                      ; load wave step counter $7262
    CP      $05                             ; CP $05: at first step?
    JR      NZ, LOC_919C
    LD      A, ($725F)                      ; load step timer $725F
    CP      $1E                             ; CP $1E: 30 frames elapsed?
    JR      NZ, LOC_919C
    CALL    SUB_9110                        ; call SUB_9110: draw new wave intro screen (starfield + enemy name)

LOC_919C:                                   ; LOC_919C: per-frame wave intro update
    LD      A, ($725F)                      ; load step timer $725F
    OR      A
    JR      Z, LOC_920E                     ; zero: step complete
    LD      HL, $725C                       ; HL = $725C: wave tile/colour animation counter
    INC     (HL)                            ; INC (HL): advance animation
    DEC     A                               ; DEC A (step timer)
    LD      ($725F), A                      ; store updated step timer
    JR      NZ, LOC_920E
    LD      A, ($7262)                  ; RAM $7262
    DEC     A
    LD      ($7262), A                  ; RAM $7262
    JR      Z, LOC_920E                     ; load remaining step count $7262
    LD      HL, ($7260)                     ; load enemy name data pointer $7260
    INC     HL
    INC     HL                              ; advance to next enemy name
    LD      ($7260), HL                 ; RAM $7260
    CALL    SUB_90BA                        ; SUB_90BA: render next enemy name row
    LD      A, $1E                          ; A = $1E: reset step timer = 30 frames
    LD      ($725F), A                  ; RAM $725F
    JR      LOC_920E                        ; continue

LOC_91C7:
    LD      B, $80
    LD      C, $01
    CALL    WRITE_REGISTER
    LD      B, $D0
    LD      DE, $1B00
    CALL    VDP_WRITE_830C
    LD      B, $B1
    LD      DE, $2009
    CALL    VDP_WRITE_830C
    INC     DE
    CALL    VDP_WRITE_830C
    LD      HL, $1800
    LD      DE, $0300
    LD      A, $30
    CALL    VDP_WRITE_8342
    LD      HL, ($725A)                 ; RAM $725A
    LD      DE, $1948
    CALL    SUB_9297
    LD      HL, $9218
    LD      DE, $18E9
    CALL    SUB_9297
    LD      HL, $708A                   ; RAM $708A
    LD      DE, $18F1
    LD      A, (HL)
    CP      $0A
    JR      C, LOC_920B
    INC     DE

LOC_920B:
    CALL    SUB_925C

LOC_920E:
    LD      B, $E2
    LD      C, $01
    CALL    WRITE_REGISTER
    JP      LOC_82D3
    DB      $20, $20, $20, $20, $57, $41, $56, $45 ; "    WAVE"
    DB      $20, $20, $20, $20, $00, $42, $4F, $4E
    DB      $55, $53, $00

LOC_922B:                                   ; LOC_922B: new wave screen setup -- VDP + sprite + sound init
    LD      B, $80                          ; VDP reg 1 = $80 (disable display)
    LD      C, $01
    CALL    WRITE_REGISTER                  ; WRITE_REGISTER: blank screen during wave setup
    LD      HL, $A4AA                       ; HL = $A4AA: wave-transition tile data
    LD      DE, $0300
    LD      BC, $0130
    CALL    VDP_WRITE_832D
    CALL    SUB_81E1                        ; SUB_81E1: reload background tiles to VRAM
    LD      A, $5A                          ; A = $5A: cannon Y center
    LD      ($7265), A                      ; LD $7265 = $5A: cannon centered vertically
    LD      ($7269), A                      ; LD $7269 = $5A: mirror
    CALL    LOC_95B7                        ; LOC_95B7: init cannon sprite timing
    CALL    SOUND_WRITE_9371                ; SOUND_WRITE_9371: configure sound channels for new wave
    CALL    SUB_92BD                        ; SUB_92BD: render score to VRAM
    LD      B, $E2                          ; VDP reg 1 = $E2: re-enable display with sprites
    LD      C, $01
    CALL    WRITE_REGISTER                  ; WRITE_REGISTER
    JP      LOC_82D3

SUB_925C:                                   ; SUB_925C: write BCD digit pair from (HL) to VRAM at DE
    LD      A, (HL)
    AND     $F0
    JR      Z, LOC_926D

LOC_9261:
    RRCA    
    RRCA    
    RRCA    
    RRCA    
    CALL    SUB_9279
    LD      A, (HL)
    AND     $0F
    JR      SUB_9279

LOC_926D:
    INC     DE
    LD      A, (HL)
    AND     $0F
    RET     Z
    JR      SUB_9279

LOC_9274:
    LD      A, (HL)
    AND     $F0
    JR      LOC_9261

SUB_9279:                                   ; SUB_9279: write single digit tile (A+$48) to VRAM at DE
    ADD     A, $48
    LD      B, A
    CALL    VDP_WRITE_830C
    INC     DE
    RET     

SUB_9281:                                   ; SUB_9281: write ASCII character to VRAM (space -> tile $30)
    CP      $20
    JR      Z, LOC_928D
    ADD     A, $1F
    LD      B, A

LOC_9288:
    CALL    VDP_WRITE_830C
    INC     DE
    RET     

LOC_928D:
    LD      B, $30
    JR      LOC_9288

SUB_9291:                                   ; SUB_9291: BCD increment: ADD A,$01 + DAA
    LD      A, (HL)
    ADD     A, $01
    DAA     
    LD      (HL), A
    RET     

SUB_9297:                                   ; SUB_9297: write null-terminated digit string to VRAM
    LD      A, (HL)
    OR      A
    RET     Z
    CALL    SUB_9281
    INC     HL
    JR      SUB_9297

SUB_92A0:                                   ; SUB_92A0: fill $1AD8 with $5A ('Z') for score overflow indicator
    LD      HL, $1AD8
    LD      DE, $0004
    LD      A, $5A
    CALL    VDP_WRITE_8342
    RET     

SUB_92AC:                                   ; SUB_92AC: BCD add A to score at $705A (2-byte BCD)
    LD      HL, $705A                       ; HL = $705A: score low byte
    ADD     A, (HL)                         ; ADD A, (HL): BCD add to score
    DAA                                     ; DAA: decimal adjust
    LD      (HL), A                         ; store low byte
    JR      NC, SUB_92BD                    ; if no carry: render score (SUB_92BD)
    LD      A, $01                          ; A = $01: carry into high byte
    INC     HL
    ADD     A, (HL)                         ; ADD score high byte
    DAA                                     ; DAA
    LD      (HL), A                         ; store high byte
    CALL    C, SUB_92A0                     ; if overflow: call SUB_92A0 (show overflow indicator)

SUB_92BD:                                   ; SUB_92BD: render score digits to VRAM name table
    LD      HL, $705B                       ; HL = $705B: score high byte
    LD      DE, $1AD8                       ; DE = $1AD8: VRAM score display position
    CALL    SUB_925C
    EX      AF, AF'
    DEC     HL
    EX      AF, AF'
    JR      NZ, LOC_9274
    INC     DE
    JR      SUB_925C
    DB      $3E, $C8, $32, $95, $72, $32, $99, $72
    DB      $C9, $3A, $65, $72, $FE, $5E, $38, $F0
    DB      $3A, $66, $72, $6F, $26, $00, $29, $29
    DB      $29, $29, $EB, $2A, $6D, $70, $ED, $52
    DB      $24, $44, $AF, $CB, $24, $17, $CB, $24
    DB      $17, $07, $5F, $16, $00, $CB, $7C, $20
    DB      $22, $CB, $74, $28, $CB, $7C, $E6, $3C
    DB      $20, $C6, $21, $47, $72, $19, $7E, $FE
    DB      $3F, $28, $BD, $47, $3A, $46, $72, $FE
    DB      $FF, $28, $B5, $3C, $32, $46, $72, $04
    DB      $70, $18, $26, $CB, $25, $3E, $00, $88
    DB      $E6, $3F, $FE, $30, $20, $A2, $21, $46
    DB      $72, $7E, $B7, $28, $9B, $21, $50, $72
    DB      $19, $3E, $3C, $BE, $20, $92, $2B, $7E
    DB      $B7, $28, $8D, $3D, $77, $21, $46, $72
    DB      $35, $E1, $3A, $66, $72, $C6, $06, $32
    DB      $96, $72, $32, $9A, $72, $3A, $65, $72
    DB      $C6, $06, $32, $95, $72, $C6, $10, $32
    DB      $99, $72, $3A, $98, $72, $3C, $E6, $0F
    DB      $32, $98, $72, $32, $9C, $72, $21, $5D
    DB      $70, $CB, $FE

SOUND_WRITE_9371:                           ; SOUND_WRITE_9371: configure SN76489A sound from $7246 bits
    LD      HL, $1AC2                       ; HL = $1AC2: VRAM sound display position
    LD      DE, $0008
    LD      A, $5A                          ; A = $5A: clear tile fill value
    CALL    VDP_WRITE_8342                  ; fill VRAM row at $1AC2 with $5A (erase old sound display)
    LD      A, ($7246)                      ; load sound config $7246
    AND     $E0                             ; AND $E0: extract volume/channel bits (bits 7-5)
    RRCA    
    RRCA                                    ; RRCA x3: shift down to bits 2-0
    RRCA    
    NEG                                     ; NEG: invert for lookup (volume 0..7)
    LD      B, $58                          ; B = $58: default tone tile
    LD      DE, $1AC2                       ; DE = $1AC2: VRAM sound display row
    JR      Z, LOC_93B4                     ; if volume = 0: jump to write default
    LD      E, A
    LD      D, $FF
    LD      HL, LOC_93B4
    ADD     HL, DE
    LD      DE, $1AC2
    JP      (HL)
    DB      $CD, $0C, $83, $13, $CD, $0C, $83, $13
    DB      $CD, $0C, $83, $13, $CD, $0C, $83, $13
    DB      $CD, $0C, $83, $13, $CD, $0C, $83, $13
    DB      $CD, $0C, $83, $13

LOC_93B4:                                   ; LOC_93B4: write sound display tile to VRAM
    LD      B, $59                          ; B = $59: alternate tone tile
    CALL    VDP_WRITE_830C
    LD      A, ($7246)                      ; reload $7246
    AND     $1C                             ; AND $1C: extract enemy-type bits (bits 4-2)
    RRCA                                    ; RRCA x2: shift to bits 2-0
    RRCA    
    LD      E, A
    LD      D, $00
    LD      HL, $93E8
    ADD     HL, DE
    LD      A, (HL)
    LD      HL, $02CA
    LD      DE, $0004
    CALL    VDP_WRITE_8342
    LD      B, $00
    LD      DE, $02C8
    CALL    VDP_WRITE_830C
    INC     DE
    CALL    VDP_WRITE_830C
    LD      DE, $02CE
    CALL    VDP_WRITE_830C
    INC     DE
    CALL    VDP_WRITE_830C
    RET     
    DB      $00, $80, $C0, $E0, $F0, $F8, $FC, $FE
    DB      $3A, $27, $72, $FE, $01, $CC, $D1, $98
    DB      $3A, $8F, $70, $FE, $01, $CC, $E9, $98
    DB      $3A, $5C, $72, $B7, $C0, $06, $04, $21
    DB      $47, $72, $7E, $B7, $28, $05, $FE, $3F
    DB      $28, $01, $35, $23, $23, $10, $F3, $21
    DB      $46, $72, $AF, $BE, $C8, $35, $CA, $71
    DB      $93, $35, $C3, $71, $93

SUB_9425:
    LD      HL, $716E                   ; RAM $716E
    LD      DE, BOOT_UP
    LD      BC, $0080
    CALL    VDP_WRITE_832D
    RET     
    DB      $3A, $6F, $70, $E6, $0F, $28, $EC, $CB
    DB      $3F, $3D, $20, $0D, $CD, $49, $95, $CD
    DB      $59, $95, $CD, $0B, $95, $CD, $DF, $94
    DB      $C9, $3D, $47, $07, $07, $4F, $07, $07
    DB      $80, $81, $6F, $26, $00, $11, $A8, $70
    DB      $19, $E5, $DD, $E1, $3E, $03, $08, $DD
    DB      $7E, $05, $B7, $28, $19, $DD, $56, $01
    DB      $DD, $5E, $00, $DD, $4E, $02, $21, $00
    DB      $00, $ED, $52, $EB, $3E, $7F, $B9, $30
    DB      $02, $0E, $7F, $CD, $8A, $94, $01, $07
    DB      $00, $DD, $09, $08, $3D, $20, $D7, $C9
    DB      $CD, $96, $94, $11, $6E, $71, $19, $CD
    DB      $B2, $94, $FD, $E9, $D5, $CB, $3A, $CB
    DB      $3A, $7A, $C6, $08, $E6, $38, $57, $79
    DB      $E6, $40, $47, $79, $E6, $38, $0F, $0F
    DB      $0F, $80, $82, $6F, $26, $00, $C1, $C9
    DB      $78, $E6, $1C, $06, $00, $4F, $FD, $21
    DB      $BF, $94, $FD, $09, $C9, $CB, $FE, $C9
    DB      $00, $CB, $F6, $C9, $00, $CB, $EE, $C9
    DB      $00, $CB, $E6, $C9, $00, $CB, $DE, $C9
    DB      $00, $CB, $D6, $C9, $00, $CB, $CE, $C9
    DB      $00, $CB, $C6, $C9, $00, $2A, $2C, $72
    DB      $EB, $21, $00, $F0, $ED, $52, $EB, $0E
    DB      $7F, $21, $41, $72, $06, $10, $7E, $FE
    DB      $01, $E5, $CC, $03, $95, $EB, $11, $00
    DB      $10, $ED, $52, $EB, $E1, $2B, $10, $EE
    DB      $C9, $C5, $D5, $CD, $8A, $94, $D1, $C1
    DB      $C9, $2A, $6D, $70, $3A, $66, $72, $ED
    DB      $44, $57, $CB, $3A, $CB, $1B, $CB, $3A
    DB      $CB, $1B, $CB, $3A, $CB, $1B, $CB, $3A
    DB      $CB, $1B, $19, $EB, $21, $00, $20, $ED
    DB      $52, $CB, $3C, $CB, $3C, $3E, $68, $84
    DB      $32, $AA, $72, $3A, $65, $72, $E6, $78
    DB      $0F, $0F, $0F, $C6, $B0, $32, $A9, $72
    DB      $C9, $3E, $00, $32, $AC, $72, $C9

SUB_9549:                                   ; SUB_9549: zero $716E sprite attribute buffer (128 bytes)
    LD      HL, $716E                       ; HL = $716E
    LD      D, $00
    LD      BC, $0080                       ; BC = $80 = 128 bytes

LOC_9551:
    LD      (HL), D
    INC     HL
    DEC     BC
    LD      A, B
    OR      C
    JR      NZ, LOC_9551
    RET     

SUB_9559:                                   ; SUB_9559: init enemy slot colour buffer based on $7250 state
    LD      DE, $7250                       ; DE = $7250: enemy spawn table
    LD      HL, $71ED                       ; HL = $71ED: colour buffer
    LD      BC, $0010                       ; BC = $0010: 16 bytes
    LD      A, $04                          ; A = 4: 4 slots to process

LOC_9564:
    EX      AF, AF'
    LD      A, (DE)                         ; load slot value
    CP      $6C                             ; CP $6C: hit/dead marker?
    JR      Z, LOC_956D
    LD      A, $E0                          ; A = $E0: 'live' colour ($E0 = bright)
    LD      (HL), A                         ; store colour for this slot

LOC_956D:
    INC     DE
    INC     DE
    OR      A
    SBC     HL, BC
    EX      AF, AF'
    DEC     A
    JR      NZ, LOC_9564
    RET     

SUB_9577:                                   ; SUB_9577: check VDP status (bit 5 = sprite overflow)
    LD      A, ($73C5)                      ; load VDP status $73C5 (saved in NMI exit)
    BIT     5, A                            ; BIT 5, A: sprite overflow flag
    JR      NZ, LOC_95E2                    ; non-zero: process overflow (LOC_95E2)
    RET     

SUB_957F:                                   ; SUB_957F: cannon jitter/drift update
    LD      A, ($7257)                      ; load cannon drift counter $7257
    DEC     A                               ; DEC A
    LD      ($7257), A                      ; store
    JR      Z, LOC_95B7                     ; zero: reset to center (LOC_95B7)
    LD      A, ($706F)                      ; load frame counter $706F
    BIT     0, A                            ; BIT 0, A: alternating frame?
    RET     Z                               ; even frame: skip jitter
    CALL    RAND_GEN                        ; RAND_GEN: get random byte
    AND     $07                             ; AND $07: 3-bit jitter offset
    XOR     $04                             ; XOR $04, SUB $04: center at zero (-4..+3)
    SUB     $04
    LD      B, A                            ; B = jitter delta
    LD      A, ($7266)                      ; load cannon angle $7266
    ADD     A, B                            ; ADD jitter: apply angle jitter
    LD      ($7266), A                      ; store new cannon angle
    LD      ($726A), A                      ; mirror to $726A
    CALL    RAND_GEN
    AND     $07
    XOR     $04
    SUB     $04
    LD      B, A
    LD      A, ($7265)                      ; load cannon Y $7265
    ADD     A, B                            ; ADD vertical jitter
    LD      ($7265), A                      ; store
    LD      ($7269), A                      ; mirror to $7269
    RET     

LOC_95B7:                                   ; LOC_95B7: reset cannon timing ($7268=$04, $726C=$08)
    LD      A, $04                          ; A = $04: cannon timing period
    LD      ($7268), A                      ; LD $7268 = $04
    LD      A, $08
    LD      ($726C), A                      ; LD $726C = $08
    RET     

SUB_95C2:                                   ; SUB_95C2: copy cannon target pos from working regs to actual pos
    LD      A, ($7266)                  ; RAM $7266
    LD      ($7069), A                  ; RAM $7069
    LD      A, ($7265)                  ; RAM $7265
    LD      ($706A), A                  ; RAM $706A
    RET     

SUB_95CF:                                   ; SUB_95CF: restore cannon to last-stable position (snap back)
    LD      A, ($7069)                  ; RAM $7069
    LD      ($7266), A                  ; RAM $7266
    LD      ($726A), A                  ; RAM $726A
    LD      A, ($706A)                  ; RAM $706A
    LD      ($7265), A                  ; RAM $7265
    LD      ($7269), A                  ; RAM $7269
    RET     

LOC_95E2:                                   ; LOC_95E2: sprite overflow handler -- scan $72AD for live enemies
    LD      IX, $72AD                       ; IX = $72AD: enemy sprite data buffer
    LD      A, $12                          ; A = $12 = 18 enemies

LOC_95E8:                                   ; EX AF,AF': save counter
    EX      AF, AF'
    LD      A, (IX+0)                       ; load (IX+0): enemy tile type
    CP      $D0                             ; CP $D0: $D0 = dead/inactive marker
    RET     Z                               ; reached end: return
    CALL    SUB_95FC                        ; SUB_95FC: test this enemy for laser hit
    LD      BC, $0004
    ADD     IX, BC
    EX      AF, AF'
    DEC     A
    JR      NZ, LOC_95E8
    RET     

SUB_95FC:                                   ; SUB_95FC: per-enemy hit test and resolution
    CALL    SUB_968E                        ; SUB_968E: load enemy bounding box into B,C,D,E
    CALL    SUB_967A                        ; SUB_967A: compute cannon centre coords in B,C
    CALL    SUB_9693                        ; SUB_9693: expand bounding box by 7 pixels
    CALL    SUB_96A8                        ; SUB_96A8: test if cannon is inside bounding box
    JR      C, LOC_9612

LOC_960A:
    CALL    SUB_961B
    CALL    DELAY_LOOP_965C
    POP     HL
    RET     

LOC_9612:
    CALL    SUB_9685
    CALL    SUB_96A8
    RET     C
    JR      LOC_960A

SUB_961B:
    LD      A, ($706B)                  ; RAM $706B
    INC     A
    LD      ($706B), A                  ; RAM $706B
    CP      $08
    CALL    NC, SUB_897E
    LD      A, ($706B)                  ; RAM $706B
    DEC     A
    LD      HL, $1ACB
    RRCA    
    JR      C, LOC_9635
    LD      DE, $000B
    ADD     HL, DE

LOC_9635:
    RRCA    
    JR      C, LOC_9658
    LD      B, $2D

LOC_963A:
    RRCA    
    JR      NC, LOC_9641
    LD      DE, $0020
    ADD     HL, DE

LOC_9641:
    DB      $EB
    CALL    VDP_WRITE_830C
    LD      A, $1F
    LD      ($7257), A                  ; RAM $7257
    LD      A, $0F
    LD      ($7268), A                  ; RAM $7268
    CALL    SUB_95C2
    LD      HL, $705D                   ; RAM $705D
    SET     5, (HL)
    RET     

LOC_9658:
    LD      B, $27
    JR      LOC_963A

DELAY_LOOP_965C:
    LD      A, ($7091)                  ; RAM $7091
    LD      HL, $7126                   ; RAM $7126
    LD      B, A
    LD      C, (IX+0)
    LD      DE, $0004

LOC_9669:
    LD      A, (HL)
    CP      C
    JR      NZ, LOC_9676
    INC     HL
    LD      A, (HL)
    CP      (IX+1)
    DEC     HL
    JP      Z, LOC_8CC0

LOC_9676:
    ADD     HL, DE
    DJNZ    LOC_9669
    RET     

SUB_967A:
    LD      A, ($7266)                  ; RAM $7266
    LD      B, A
    LD      A, ($7265)                  ; RAM $7265
    ADD     A, $03
    LD      C, A
    RET     

SUB_9685:
    LD      A, $0D
    ADD     A, B
    LD      B, A
    LD      A, C
    ADD     A, $04
    LD      C, A
    RET     

SUB_968E:
    LD      E, A
    LD      D, (IX+1)
    RET     

SUB_9693:
    LD      A, $07
    ADD     A, D
    LD      H, A
    LD      A, $07
    ADD     A, E
    LD      L, A
    RET     

SUB_969C:
    LD      A, B
    CP      D
    RET     C
    LD      A, C
    CP      E
    RET     

SUB_96A2:
    LD      A, D
    CP      B
    RET     C
    LD      A, E
    CP      C
    RET     

SUB_96A8:
    CALL    SUB_969C
    RET     C
    DB      $EB
    CALL    SUB_96A2
    DB      $EB
    RET     
    DB      $3A, $5C, $72, $B7, $C0, $3A, $31, $72
    DB      $21, $30, $72, $96, $28, $0E, $CD, $D4
    DB      $96, $3E, $0B, $32, $78, $72, $3E, $07
    DB      $32, $74, $72, $C9, $3E, $01, $32, $27
    DB      $72, $C9, $3A, $2B, $72, $47, $CD, $FD
    DB      $1F, $E6, $0F, $B8, $C8, $5F, $16, $00
    DB      $21, $32, $72, $19, $EB, $2A, $29, $72
    DB      $B7, $ED, $52, $C8, $EB, $3E, $01, $BE
    DB      $C8, $77, $21, $30, $72, $34, $C9

SUB_96F9:                                   ; SUB_96F9: boss laser trajectory and movement AI
    CALL    SUB_97DB                        ; SUB_97DB: advance boss movement (interpolate $72A5/$72A6 position)
    LD      A, ($725C)                      ; load boss wave flag $725C
    OR      A
    RET     NZ                              ; non-zero: boss still deploying -- return
    LD      A, $C8                          ; A = $C8
    LD      ($7275), A                      ; LD $7275 = $C8: boss position centre X
    LD      ($7271), A                      ; LD $7271 = $C8: boss position centre Y
    CALL    SUB_97CF                        ; SUB_97CF: add boss velocity to position $722C
    CALL    SUB_977A                        ; SUB_977A: scan kill-record table, fire beam at matching positions
    LD      HL, ($706D)                     ; HL = $706D: cannon position (fractional 16-bit)
    DB      $EB
    LD      HL, ($722C)                     ; HL = $722C: boss position
    SBC     HL, DE                          ; SBC HL, DE: distance boss-to-cannon
    XOR     A
    ADD     HL, HL                          ; shift left 4 times (scale distance to column offset)
    RLA     
    ADD     HL, HL
    RLA     
    ADD     HL, HL
    RLA     
    ADD     HL, HL
    RLA     
    LD      B, H                            ; B = H: column index after scaling
    LD      ($722B), A                      ; LD $722B: store column index
    LD      E, A
    LD      D, $00
    LD      HL, $7232                   ; RAM $7232
    ADD     HL, DE
    LD      A, (HL)
    CP      $01                             ; CP $01: is entry = 'hit marker'?
    RET     NZ                              ; no: return without firing
    LD      A, $88                          ; A = $88: boss fire tile
    LD      ($7275), A                      ; LD $7275 = $88
    ADD     A, $10
    LD      ($7271), A                      ; LD $7271 = $98
    LD      A, B
    NEG                                     ; NEG A: invert velocity (aim toward cannon)
    LD      ($7276), A                      ; LD $7276 = A: X velocity for laser
    LD      ($7272), A                  ; RAM $7272
    CALL    SUB_9752                        ; SUB_9752: advance laser beam 4 pixels every 4th frame
    LD      A, ($706F)                      ; load frame counter $706F
    LD      B, A
    LD      A, ($7245)                      ; load phase mask $7245
    AND     B                               ; AND B: apply frame-phase mask
    CALL    Z, SUB_9848                     ; if phase match: call SUB_9848 (spawn laser projectile)
    RET     

SUB_9752:
    LD      A, ($706F)                  ; RAM $706F
    AND     $03
    RET     NZ
    LD      A, ($7277)                  ; RAM $7277
    ADD     A, $04
    LD      ($7277), A                  ; RAM $7277
    CP      $C8
    JR      NZ, LOC_9769
    LD      A, $BC
    LD      ($7277), A                  ; RAM $7277

LOC_9769:
    LD      A, ($7273)                  ; RAM $7273
    ADD     A, $04
    LD      ($7273), A                  ; RAM $7273
    CP      $D4
    RET     NZ
    LD      A, $C8
    LD      ($7273), A                  ; RAM $7273
    RET     

SUB_977A:
    LD      HL, ($722C)                 ; RAM $722C
    XOR     A
    ADD     HL, HL
    RLA     
    ADD     HL, HL
    RLA     
    ADD     HL, HL
    RLA     
    ADD     HL, HL
    RLA     
    NEG     
    DEC     A
    AND     $0F
    LD      C, A
    LD      A, H
    NEG     
    CP      $10
    RET     C
    CP      $18
    RET     NC
    LD      A, C
    LD      B, $10
    LD      HL, $7232                   ; RAM $7232

LOC_979B:
    LD      A, (HL)
    CP      $01
    JR      NZ, LOC_97A3
    CALL    SUB_97A8

LOC_97A3:
    INC     C
    INC     HL
    DJNZ    LOC_979B
    RET     

SUB_97A8:
    LD      A, C
    AND     $03
    RET     NZ
    LD      A, C
    AND     $0C
    RRCA    
    RRCA    
    INC     A
    NEG     
    AND     $03
    RLCA    
    PUSH    BC
    PUSH    HL
    CALL    SUB_8784
    LD      A, D
    CP      $01
    JR      Z, LOC_97C4
    POP     HL
    POP     BC
    RET     

LOC_97C4:
    POP     HL
    PUSH    HL
    LD      ($7229), HL                 ; RAM $7229
    CALL    SUB_8E03
    POP     HL
    POP     BC
    RET     

SUB_97CF:
    LD      HL, ($722E)                 ; RAM $722E
    DB      $EB
    LD      HL, ($722C)                 ; RAM $722C
    ADD     HL, DE
    LD      ($722C), HL                 ; RAM $722C
    RET     

SUB_97DB:
    LD      A, ($7242)                  ; RAM $7242
    OR      A
    RET     Z
    DEC     A
    LD      ($7242), A                  ; RAM $7242
    JR      Z, LOC_97FD
    LD      A, ($72A6)                  ; RAM $72A6
    LD      B, A
    LD      A, ($7243)                  ; RAM $7243
    ADD     A, B
    LD      ($72A6), A                  ; RAM $72A6
    LD      A, ($72A5)                  ; RAM $72A5
    LD      B, A
    LD      A, ($7244)                  ; RAM $7244
    ADD     A, B
    LD      ($72A5), A                  ; RAM $72A5
    RET     

LOC_97FD:
    LD      HL, $72A5                   ; RAM $72A5
    CALL    SUB_98B3
    PUSH    DE
    CALL    DELAY_LOOP_8E42
    POP     DE
    LD      (IY+0), E
    LD      (IY+1), D
    LD      (IY+3), $06
    LD      (IY+2), $60
    CALL    SUB_9836
    LD      A, $C8
    LD      ($72A5), A                  ; RAM $72A5
    CALL    SUB_967A
    CALL    SUB_983F
    CALL    SUB_96A8
    JR      C, LOC_982C
    JP      SUB_961B

LOC_982C:
    CALL    SUB_9685
    CALL    SUB_96A8
    RET     C
    JP      SUB_961B

SUB_9836:
    LD      A, ($72A6)                  ; RAM $72A6
    LD      D, A
    LD      A, ($72A5)                  ; RAM $72A5
    LD      E, A
    RET     

SUB_983F:
    LD      A, D
    ADD     A, $08
    LD      H, A
    LD      A, E
    ADD     A, $08
    LD      L, A
    RET     

SUB_9848:
    LD      A, ($7242)                  ; RAM $7242
    OR      A
    RET     NZ
    LD      A, ($7276)                  ; RAM $7276
    OR      A
    RET     Z
    ADD     A, $08
    RET     C
    CALL    SUB_985F
    CALL    SUB_9873
    CALL    SUB_9888
    RET     

SUB_985F:
    LD      ($72A6), A                  ; RAM $72A6
    SRL     A
    LD      B, A
    LD      A, ($7266)                  ; RAM $7266
    SRL     A
    SUB     B
    SRA     A
    SRA     A
    LD      ($7243), A                  ; RAM $7243
    RET     

SUB_9873:
    LD      A, ($7265)                  ; RAM $7265
    SUB     $7F
    SRA     A
    SRA     A
    SRA     A
    DEC     A
    LD      ($7244), A                  ; RAM $7244
    LD      A, $88
    LD      ($72A5), A                  ; RAM $72A5
    RET     

SUB_9888:
    LD      A, $09
    LD      ($7242), A                  ; RAM $7242
    RET     
    DB      $3A, $66, $72, $84, $CB, $7F, $28, $02
    DB      $ED, $44, $CB, $2F, $CB, $2F, $47, $3A
    DB      $65, $72, $D6, $7F, $ED, $44, $CB, $2F
    DB      $CB, $2F, $4F, $B8, $38, $03, $87, $80
    DB      $C9, $CB, $20, $80, $C9

SUB_98B3:
    LD      A, (HL)
    AND     $07
    LD      C, A
    LD      A, (HL)
    SUB     C
    LD      D, $00
    LD      E, A
    SLA     E
    RL      D
    SLA     E
    RL      D
    INC     HL
    LD      A, (HL)
    AND     $07
    LD      B, A
    LD      A, (HL)
    SUB     B
    RRCA    
    RRCA    
    RRCA    
    ADD     A, E
    LD      E, A
    RET     
    DB      $3A, $31, $72, $47, $3A, $26, $72, $90
    DB      $C8, $21, $32, $72, $06, $10, $7E, $23
    DB      $FE, $01, $C8, $10, $F9, $C3, $F1, $8A
    DB      $3A, $8B, $70, $47, $3A, $8C, $70, $90
    DB      $C8, $DD, $21, $A8, $70, $11, $07, $00
    DB      $06, $12, $AF, $DD, $BE, $05, $C0, $DD
    DB      $19, $10, $F8, $C3, $F1, $8A

SUB_9907:                                   ; SUB_9907: spawn up to 3 enemy types from ROM difficulty table
    LD      IX, $7279                       ; IX = $7279: sprite position table for spawned enemies
    LD      BC, $0004                       ; BC = $0004: stride between sprite entries
    LD      A, $C8                          ; A = $C8 = 'dead' marker
    LD      ($7279), A                      ; init spawn slot 0 ($7279) = $C8
    LD      ($727D), A                      ; init spawn slot 1 ($727D) = $C8
    LD      ($7281), A                      ; init spawn slot 2 ($7281) = $C8
    CALL    SUB_84D0                        ; SUB_84D0: convert cannon pos $706D to tile X coord in HL
    BIT     0, H
    JR      NZ, LOC_992F                    ; BIT 0, H: cannon on odd tile column?
    INC     H
    LD      A, L
    ADD     IX, BC                          ; ADD IX, BC: advance to slot 1
    ADD     A, $10                          ; ADD A,$10: shift spawn X right by $10
    JR      C, LOC_9935                     ; overflow: only 1 enemy fits -- spawn slot 0 only
    ADD     IX, BC                          ; ADD IX, BC: advance to slot 2
    ADD     A, $10                          ; ADD A,$10: shift spawn X further right
    JR      C, LOC_993A                     ; overflow: 2 enemies fit
    RET                                     ; 3 enemies fit -- fall through to spawn all 3

LOC_992F:
    LD      A, L
    CALL    SUB_9985
    JR      C, LOC_993D

LOC_9935:
    CALL    SUB_9985
    JR      C, LOC_993D

LOC_993A:
    CALL    SUB_9985

LOC_993D:
    BIT     1, H
    JR      Z, LOC_997B
    LD      A, ($706F)                  ; RAM $706F
    BIT     0, A
    JR      Z, LOC_9995
    LD      DE, $7250                   ; RAM $7250
    CALL    SUB_99D9

LOC_994E:
    CP      $6C
    JR      Z, LOC_9960
    LD      ($727B), A                  ; RAM $727B
    ADD     A, $04
    LD      ($727F), A                  ; RAM $727F
    ADD     A, $04
    LD      ($7283), A                  ; RAM $7283
    RET     

LOC_9960:
    LD      A, $6C
    LD      ($727B), A                  ; RAM $727B
    ADD     A, $04
    LD      ($727F), A                  ; RAM $727F
    ADD     A, $04
    LD      ($7283), A                  ; RAM $7283
    LD      A, $01
    LD      ($727C), A                  ; RAM $727C
    LD      ($7280), A                  ; RAM $7280
    LD      ($7284), A                  ; RAM $7284
    RET     

LOC_997B:
    LD      A, $C8
    LD      ($7281), A                  ; RAM $7281
    CALL    SUB_99BC
    JR      LOC_994E

SUB_9985:                                   ; SUB_9985: initialise one spawn slot: tile=$88, timer=9
    LD      (IX+1), A                       ; LD (IX+1) = A: spawn X position
    LD      (IX+0), $88                     ; LD (IX+0) = $88: spawn tile
    LD      (IX+3), $09                     ; LD (IX+3) = $09: 9-frame deploy timer
    ADD     IX, BC
    ADD     A, $10                          ; ADD IX, BC: advance to next slot
    RET                                     ; ADD A,$10: next X position

LOC_9995:
    PUSH    HL
    LD      DE, $724F                   ; RAM $724F
    CALL    SUB_99D9
    LD      HL, $A6FA
    CALL    SUB_99E3
    POP     HL
    CP      $0E
    JR      Z, LOC_9960
    LD      ($727C), A                  ; RAM $727C
    LD      ($7280), A                  ; RAM $7280
    LD      ($7284), A                  ; RAM $7284
    LD      A, $9C
    JR      LOC_994E
    DB      $01, $02, $04, $08, $10, $20, $40, $80

SUB_99BC:
    LD      DE, $7247                   ; RAM $7247
    CALL    SUB_99D9
    CP      $3F
    JR      Z, LOC_99D6
    LD      HL, $99B4
    CALL    SUB_99E3
    LD      B, A
    LD      A, ($706F)                  ; RAM $706F
    AND     B
    JR      Z, LOC_99D6
    LD      A, $90
    RET     

LOC_99D6:
    LD      A, $88
    RET     

SUB_99D9:
    LD      A, H
    AND     $0C
    RRCA    
    LD      L, A
    LD      H, $00
    ADD     HL, DE
    LD      A, (HL)
    RET     

SUB_99E3:
    AND     $38
    RRCA    
    RRCA    
    RRCA    
    LD      E, A
    LD      D, $00
    ADD     HL, DE
    LD      A, (HL)
    RET     

DELAY_LOOP_99EE:
    LD      A, ($706F)                  ; RAM $706F
    AND     $0F
    RET     NZ
    LD      B, $04
    LD      HL, $7250                   ; RAM $7250

LOC_99F9:
    LD      A, (HL)
    CP      $3C
    JR      Z, LOC_9A05
    CP      $6C
    JR      Z, LOC_9A05
    ADD     A, $0C
    LD      (HL), A

LOC_9A05:
    INC     HL
    INC     HL
    DJNZ    LOC_99F9
    RET     

SUB_9A0A:                                   ; SUB_9A0A: load level layout data from ROM table (IY=$9B47)
    LD      IY, $9B47                       ; IY = $9B47: level descriptor table base
    LD      L, (IY+0)                       ; HL = (IY+0:1): source address of level tile data
    LD      H, (IY+1)
    LD      DE, $71EE                       ; DE = $71EE: RAM destination for tile data
    LD      B, $00
    LD      C, (IY+4)                       ; C = (IY+4): byte count for LDIR
    LDIR                                    ; LDIR: copy level tile data to RAM
    LD      L, (IY+2)                       ; HL = (IY+2:3): game state dispatch function pointer
    LD      H, (IY+3)
    LD      ($7061), HL                     ; LD ($7061), HL: save dispatch pointer
    LD      B, (IY+5)                       ; B = (IY+5): VRAM write count
    PUSH    BC
    LD      HL, ($7061)                 ; RAM $7061
    DB      $EB
    LD      HL, $71EE                       ; HL = $71EE: RAM tile data source
    LD      B, $00
    LD      C, (IY+4)
    CALL    VDP_WRITE_832D                  ; VDP_WRITE_832D: copy tile data from RAM to VRAM
    LD      B, $08
    LD      HL, $9A4B                       ; HL = $9A4B: tile init function pointer table
    PUSH    HL
    LD      IX, $71EE                       ; IX = $71EE: tile RAM buffer base
    LD      L, (IY+6)                       ; HL = (IY+6:7): tile init function pointer
    LD      H, (IY+7)
    JP      (HL)                            ; JP (HL): dispatch to level-specific tile init function
    DB      $06, $00, $FD, $4E, $04, $2A, $61, $70
    DB      $09, $22, $61, $70, $C1, $10, $D0, $01
    DB      $08, $00, $FD, $09, $FD, $7E, $00, $B7
    DB      $20, $A9, $CD, $68, $9B, $CD, $8E, $9B
    DB      $C9, $DD, $CB, $00, $26, $DD, $CB, $18
    DB      $16, $DD, $CB, $10, $16, $DD, $CB, $08
    DB      $16, $08, $DD, $CB, $00, $3E, $08, $DD
    DB      $CB, $00, $16, $DD, $23, $10, $E2, $C9
    DB      $37, $DD, $CB, $00, $1E, $DD, $CB, $08
    DB      $1E, $DD, $CB, $10, $1E, $DD, $CB, $18
    DB      $1E, $DD, $CB, $20, $1E, $DD, $CB, $28
    DB      $1E, $DD, $23, $10, $E3, $C9, $37, $DD
    DB      $CB, $00, $1E, $DD, $CB, $08, $1E, $DD
    DB      $23, $10, $F3, $C9, $04, $0D, $1B, $3F
    DB      $7F, $DB, $9D, $00, $00, $00, $C0, $61
    DB      $F3, $FE, $BF, $00, $00, $00, $00, $81
    DB      $83, $CD, $FF, $00, $00, $18, $1C, $3E
    DB      $FB, $E7, $F1, $00, $FF, $F8, $F0, $F8
    DB      $E6, $E0, $8A, $11, $00, $00, $00, $18
    DB      $04, $26, $41, $A6, $00, $08, $54, $83
    DB      $05, $02, $1C, $E0, $00, $00, $00, $18
    DB      $04, $26, $41, $A6, $FF, $FF, $FF, $7F
    DB      $3F, $47, $7B, $93, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $00, $F0, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $00, $00, $0F, $FF
    DB      $FF, $FF, $FF, $FF, $01, $3F, $F0, $CF
    DB      $FF, $FF, $FF, $FF, $00, $80, $DF, $FA
    DB      $FF, $FF, $FF, $FF, $00, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FB, $E3
    DB      $E1, $E0, $84, $88, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $B7, $9A, $20, $20
    DB      $20, $20, $6C, $9A, $D7, $9A, $80, $04
    DB      $30, $08, $8B, $9A, $37, $9B, $00, $06
    DB      $10, $08, $A9, $9A, $07, $9B, $80, $06
    DB      $30, $08, $8B, $9A, $00

SUB_9B68:                                   ; SUB_9B68: read VRAM starfield row for parallax scroll
    LD      A, ($706D)                      ; A = $706D (cannon pos low): compute source row offset
    NEG                                     ; NEG: negate
    AND     $F8                             ; AND $F8: align to 8-pixel row
    LD      L, A                            ; HL = offset
    LD      H, $00
    ADD     HL, HL
    ADD     HL, HL
    LD      DE, $2020                       ; add $2020 to map into VRAM pattern table
    ADD     HL, DE
    DB      $EB
    LD      HL, $71EE                       ; HL = $71EE: RAM buffer destination
    PUSH    HL
    LD      BC, $0020                       ; BC = $0020: 32 bytes (one tile row)
    CALL    READ_VRAM                       ; READ_VRAM: copy VRAM tile row to RAM
    POP     HL
    LD      DE, $0088                       ; DE = $0088: destination in VRAM sprite plane
    LD      BC, $0020
    CALL    VDP_WRITE_832D                  ; VDP_WRITE_832D: write tile row to sprite plane for parallax effect
    RET     

SUB_9B8E:                                   ; SUB_9B8E: score/lives row renderer
    LD      HL, ($706D)                     ; HL = $706D: cannon position
    LD      A, ($725C)                      ; load wave timer $725C
    OR      A
    JR      Z, LOC_9B9A                     ; if zero (deploy complete): skip
    CP      $78                             ; CP $78: if > $78 frames remain: skip update
    RET     C

LOC_9B9A:
    LD      B, $30                          ; B = $30: space tile
    LD      DE, $19A0                       ; DE = $19A0: VRAM score row
    CALL    VDP_WRITE_830C                  ; write space (clear) to 3 cells
    INC     DE
    CALL    VDP_WRITE_830C
    INC     DE
    CALL    VDP_WRITE_830C
    LD      A, $00                          ; zero $7290, $7294, $7288, $728C
    LD      ($7290), A                  ; RAM $7290
    LD      ($7294), A                  ; RAM $7294
    LD      ($7288), A                  ; RAM $7288
    LD      ($728C), A                  ; RAM $728C
    LD      A, $C8                          ; A = $C8: 'full' indicator
    LD      ($728D), A                      ; set $728D = $C8
    LD      ($7291), A                  ; RAM $7291
    LD      HL, ($706D)                     ; reload cannon position $706D
    LD      DE, $2000
    ADD     HL, DE
    LD      A, H
    AND     $C0
    RRCA    
    LD      B, A
    RRCA    
    ADD     A, B
    LD      ($7065), A                  ; RAM $7065
    LD      A, ($7258)                  ; RAM $7258
    OR      A
    JR      NZ, LOC_9C10
    LD      DE, BOOT_UP
    ADD     HL, HL
    RL      E
    ADD     HL, HL
    RL      E
    LD      A, E
    RLCA    
    ADD     A, E
    LD      E, A
    LD      HL, $9E1B
    ADD     HL, DE
    PUSH    HL
    POP     IX
    LD      ($7063), HL                 ; RAM $7063
    LD      A, (HL)
    LD      HL, $2012
    LD      DE, $0006
    CALL    VDP_WRITE_8342
    LD      A, (IX+1)
    LD      HL, $2018
    LD      DE, $0002
    CALL    VDP_WRITE_8342
    LD      A, (IX+2)
    LD      HL, $201A
    LD      DE, $0006
    CALL    VDP_WRITE_8342

LOC_9C10:
    LD      HL, ($706D)                 ; RAM $706D
    LD      DE, BOOT_UP
    DB      $EB
    SBC     HL, DE
    LD      A, L
    CPL     
    AND     $E0
    RRCA    
    RRCA    
    RRCA    
    LD      B, A
    RRCA    
    LD      ($7067), A                  ; RAM $7067
    ADD     A, B
    LD      C, A
    SRL     A
    SRL     A
    SRL     A
    LD      ($7259), A                  ; RAM $7259
    LD      A, H
    BIT     5, H
    JP      Z, LOC_9D33
    AND     $1F
    RET     Z
    LD      HL, $19C0
    LD      B, A
    NEG     
    ADD     A, $20
    LD      E, A
    LD      D, $00
    ADD     HL, DE
    PUSH    HL
    LD      DE, $0020
    ADD     HL, DE
    POP     DE
    EXX     
    LD      HL, ($7065)                 ; RAM $7065
    LD      DE, $9D5B
    ADD     HL, DE
    PUSH    HL
    POP     IX
    LD      DE, $0018
    ADD     HL, DE
    PUSH    HL
    POP     IY
    EXX     
    LD      A, $18
    CP      B
    JR      NC, LOC_9C65
    LD      B, $18

LOC_9C65:
    PUSH    BC
    LD      A, (IX+0)
    CP      $30
    JR      Z, LOC_9C78
    CP      $5A
    CALL    Z, SUB_9D0A
    CP      $15
    CALL    C, SUB_9CA2
    ADD     A, C

LOC_9C78:
    LD      B, A
    CALL    VDP_WRITE_830C
    POP     BC
    PUSH    BC
    LD      A, (IY+0)
    CP      $10
    JR      Z, LOC_9C86
    ADD     A, C

LOC_9C86:
    LD      B, A
    DB      $EB
    CALL    VDP_WRITE_830C
    DB      $EB
    INC     HL
    INC     DE
    INC     IX
    INC     IY
    POP     BC
    DJNZ    LOC_9C65
    LD      HL, $7285                   ; RAM $7285
    LD      DE, $1B20
    LD      BC, $0030
    CALL    VDP_WRITE_832D
    RET     

SUB_9CA2:                                   ; SUB_9CA2: tile state dispatch on $7063 value ($11-$14=boss; else=normal)
    PUSH    IX                              ; save IX, HL
    PUSH    HL
    LD      HL, ($7063)                     ; load state dispatch value $7063
    CP      $11                             ; CP $11: boss state $11?
    JR      Z, LOC_9CEE                     ; yes: handle boss-enter state
    CP      $12                             ; CP $12: boss state $12?
    JR      Z, LOC_9CFC                     ; yes: handle boss-alt state
    CP      $13                             ; CP $13: boss state $13?
    JR      Z, LOC_9CDA                     ; yes: normal state $13
    CP      $14                             ; CP $14: boss state $14?
    JR      Z, LOC_9CE4                     ; yes: normal state $14
    LD      IX, $7289                       ; IX = $7289: normal sprite data area
    LD      A, $30                          ; A = $30 - C: compute tile offset from column
    SUB     C
    LD      B, A                            ; B = A

LOC_9CC0:
    PUSH    DE
    LD      A, E
    AND     $1F
    RLCA    
    RLCA    
    RLCA    
    LD      E, A
    LD      A, ($7067)                  ; RAM $7067
    RRCA    
    ADD     A, E
    LD      (IX+1), A
    LD      A, (HL)
    LD      (IX+3), A
    LD      A, B
    POP     DE
    POP     HL
    POP     IX
    RET     

LOC_9CDA:                                   ; LOC_9CDA: boss state $13 -- use $7285 sprite data
    LD      IX, $7285                   ; RAM $7285
    LD      A, $30
    SUB     C
    LD      B, A
    JR      LOC_9CC0

LOC_9CE4:                                   ; LOC_9CE4: boss state $14 -- use $7289 sprite data
    LD      IX, $7289                   ; RAM $7289
    LD      A, $30
    SUB     C
    LD      B, A
    JR      LOC_9CC0

LOC_9CEE:                                   ; LOC_9CEE: boss state $11 -- set $728D tile to $68, use $728D data
    LD      A, $68
    LD      ($728D), A                  ; RAM $728D
    LD      IX, $728D                   ; RAM $728D
    LD      B, $92
    INC     HL
    JR      LOC_9CC0

LOC_9CFC:                                   ; LOC_9CFC: boss state $12 -- set $7291 tile to $68, use $7291 data
    LD      A, $68
    LD      ($7291), A                  ; RAM $7291
    LD      IX, $7291                   ; RAM $7291
    LD      B, $92
    INC     HL
    JR      LOC_9CC0

SUB_9D0A:
    PUSH    DE
    EXX     
    POP     HL
    LD      C, A
    LD      DE, $0021
    OR      A
    SBC     HL, DE
    DB      $EB
    LD      B, $30
    CALL    VDP_WRITE_830C
    LD      A, ($7067)                  ; RAM $7067
    ADD     A, $C0
    LD      B, A
    INC     DE
    CALL    VDP_WRITE_830C
    INC     DE
    INC     B
    CALL    VDP_WRITE_830C
    INC     DE
    LD      B, $30
    CALL    VDP_WRITE_830C
    EXX     
    LD      A, $91
    RET     

LOC_9D33:
    AND     $1F
    CP      $18
    RET     NC
    LD      E, A
    LD      D, $00
    LD      HL, ($7065)                 ; RAM $7065
    ADD     HL, DE
    LD      DE, $9D5B
    ADD     HL, DE
    PUSH    HL
    POP     IX
    LD      DE, $0018
    ADD     HL, DE
    PUSH    HL
    POP     IY
    LD      DE, $19C0
    LD      HL, $19E0
    NEG     
    ADD     A, $18
    LD      B, A
    JP      LOC_9C65
    DB      $30, $90, $5A, $11, $93, $94, $95, $30
    DB      $30, $30, $30, $90, $91, $12, $93, $94
    DB      $95, $13, $30, $14, $30, $30, $30, $30
    DB      $10, $D0, $D1, $D2, $D3, $D4, $D5, $10
    DB      $10, $10, $10, $D0, $D1, $D2, $D3, $D4
    DB      $D5, $D0, $D1, $D2, $D3, $D4, $D5, $10
    DB      $30, $90, $91, $12, $93, $94, $95, $30
    DB      $30, $30, $13, $14, $30, $30, $30, $30
    DB      $30, $90, $5A, $11, $93, $94, $95, $30
    DB      $10, $D0, $D1, $D2, $D3, $D4, $D5, $10
    DB      $10, $10, $D0, $D1, $D2, $D3, $D4, $D5
    DB      $10, $D0, $D1, $D2, $D3, $D4, $D5, $10
    DB      $30, $90, $91, $12, $93, $94, $95, $30
    DB      $30, $90, $5A, $11, $93, $94, $95, $30
    DB      $30, $30, $14, $13, $30, $30, $30, $30
    DB      $10, $D0, $D1, $D2, $D3, $D4, $D5, $10
    DB      $10, $D0, $D1, $D2, $D3, $D4, $D5, $10
    DB      $10, $D0, $D1, $D2, $D3, $D4, $D5, $10
    DB      $30, $90, $5A, $11, $93, $94, $95, $30
    DB      $14, $30, $13, $30, $30, $30, $30, $30
    DB      $30, $90, $91, $12, $93, $94, $95, $30
    DB      $10, $D0, $D1, $D2, $D3, $D4, $D5, $D0
    DB      $D1, $D2, $D3, $D4, $D5, $10, $10, $10
    DB      $10, $D0, $D1, $D2, $D3, $D4, $D5, $10
    DB      $0C, $0F, $4B, $0E, $0F, $47, $06, $09
    DB      $41, $02, $03, $4B, $00, $00, $00, $00
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
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $30, $32, $37
    DB      $30, $37, $30, $30, $30, $34, $36, $32 ; "07000462"
    DB      $33, $36, $32, $30, $36, $37, $37, $30 ; "36206770"
    DB      $30, $3B, $37, $30, $40, $41, $42, $37 ; "0;70@AB7"
    DB      $36, $37, $32, $30, $36, $30, $33, $37 ; "67206037"
    DB      $30, $33, $35, $36, $33, $32, $33, $32 ; "03563232"
    DB      $37, $33, $30, $30, $37, $30, $30, $37 ; "73007007"
    DB      $37, $30, $30, $3E, $43, $3F, $44, $3D ; "700>C?D="
    DB      $37, $30, $37, $30, $30, $30, $30, $30 ; "70700000"
    DB      $30, $33, $36, $32, $36, $33, $30, $35 ; "03626305"
    DB      $30, $30, $37, $30, $30, $30, $30, $30 ; "00700000"
    DB      $30, $30, $30, $33, $45, $46, $47, $30 ; "0003EFG0"
    DB      $30, $35, $36, $30, $32, $30, $37, $30 ; "05602070"
    DB      $35, $32, $37, $37, $36, $30, $33, $30 ; "52776030"
    DB      $30, $37, $30, $30, $30, $30, $37, $30 ; "07000070"
    DB      $30, $30, $37, $30, $30, $37, $30, $30 ; "00700700"
    DB      $30, $30, $30, $30, $37, $30, $30, $33 ; "00007003"
    DB      $36, $31, $34, $37, $37, $30, $30, $30 ; "61477000"
    DB      $30, $30, $30, $30, $30, $30, $30, $30 ; "00000000"
    DB      $30, $30, $30, $33, $37, $30, $30, $35 ; "00037005"
    DB      $30, $38, $30, $30, $30, $30, $32, $36 ; "08000026"
    DB      $31, $33, $33, $30, $30, $30, $30, $37 ; "13300007"
    DB      $30, $30, $30, $37, $30, $30, $30, $30 ; "00070000"
    DB      $30, $30, $37, $30, $36, $31, $34, $30 ; "00706140"
    DB      $30, $3A, $30, $30, $32, $30, $30, $32 ; "0:002002"
    DB      $33, $30, $30, $37, $33, $30, $30, $30 ; "30073000"
    DB      $30, $30, $30, $30, $37, $30, $30, $37 ; "00007007"
    DB      $30, $30, $30, $30, $33, $30, $30, $32 ; "00003002"
    DB      $30, $30, $35, $30, $30, $30, $32, $30 ; "00500020"
    DB      $30, $30, $30, $30, $30, $30, $30, $30 ; "00000000"
    DB      $30, $30, $30, $30, $30, $30, $30, $30 ; "00000000"
    DB      $30, $30, $30, $37, $30, $31, $30, $30 ; "00070100"
    DB      $30, $36, $30, $37, $30, $30, $37, $30 ; "06070070"
    DB      $30, $30, $30, $30, $30, $30, $30, $37 ; "00000007"
    DB      $30, $30, $30, $30, $30, $30, $30, $30 ; "00000000"
    DB      $30, $30, $30, $30, $30, $30, $30, $30 ; "00000000"
    DB      $30, $30, $30, $30, $30, $30, $30, $30 ; "00000000"
    DB      $30, $30, $30, $30, $30, $30, $30, $30 ; "00000000"
    DB      $30, $30, $30, $30, $30, $30, $30, $30 ; "00000000"
    DB      $30, $30, $30, $30, $30, $30, $30, $37 ; "00000007"
    DB      $30, $37, $30, $30, $30, $30, $30, $37 ; "07000007"
    DB      $30, $30, $30, $37, $30, $30, $30, $30 ; "00070000"
    DB      $30, $30, $37, $30, $30, $30, $30, $30 ; "00700000"
    DB      $30, $30, $30, $30, $37, $30, $30, $30 ; "00007000"
    DB      $30, $30, $30, $30, $30, $30, $30, $30 ; "00000000"
    DB      $30, $30, $30, $30, $30, $30, $30, $30 ; "00000000"
    DB      $30, $30, $30, $30, $30, $30, $30, $30 ; "00000000"
    DB      $30, $30, $30, $30, $30, $30, $30, $30 ; "00000000"
    DB      $37, $30, $30, $30, $30, $30, $30, $30 ; "70000000"
    DB      $30, $30, $30, $30, $30, $30, $30, $30 ; "00000000"
    DB      $30, $30, $30, $30, $30, $30, $30, $30 ; "00000000"
    DB      $30, $30, $30, $30, $30, $30, $30, $30 ; "00000000"
    DB      $30, $30, $30, $30, $30, $30, $30, $30 ; "00000000"
    DB      $30, $30, $30, $30, $30, $30, $30, $30 ; "00000000"
    DB      $30, $30, $30, $30, $30, $30, $30, $30 ; "00000000"
    DB      $30, $30, $30, $30, $30, $30, $30, $30 ; "00000000"
    DB      $30, $30, $30, $30, $30, $30, $30, $30 ; "00000000"
    DB      $30, $30, $30, $30, $30, $30, $30, $30 ; "00000000"
    DB      $30, $30, $30, $30, $30, $30, $30, $30 ; "00000000"
    DB      $30, $30, $30, $30, $30, $30, $30, $30 ; "00000000"
    DB      $30, $30, $30, $30, $30, $11, $12, $13
    DB      $14, $11, $12, $13, $14, $11, $12, $13
    DB      $14, $11, $12, $13, $14, $11, $12, $13
    DB      $14, $11, $12, $13, $14, $11, $12, $13
    DB      $14, $11, $12, $13, $14, $27, $2E, $5A
    DB      $5A, $5A, $5A, $5A, $5A, $5A, $5A, $2F ; "ZZZZZZZ/"
    DB      $2C, $22, $00, $01, $02, $03, $04, $05
    DB      $06, $07, $23, $2C, $24, $5A, $5A, $5A
    DB      $5A, $48, $48, $25, $27, $27, $27, $27 ; "ZHH%''''"
    DB      $27, $28, $29, $2A, $2B, $27, $27, $27 ; "'()*+'''"
    DB      $2C, $22, $08, $09, $0A, $0B, $0C, $0D
    DB      $0E, $0F, $23, $2C, $20, $26, $26, $26
    DB      $26, $26, $26, $21, $27, $F1, $F1, $B4
    DB      $71, $DE, $4E, $71, $31, $B1, $B1, $B1
    DB      $91, $B1, $B1, $B1, $B1, $B1, $B1, $04
    DB      $20, $02, $91, $00, $02, $20, $00, $08
    DB      $21, $1A, $95, $6E, $7C, $1C, $18, $00
    DB      $00, $00, $00, $00, $14, $38, $18, $FF
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $FF, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $FF, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $FF, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $FF, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $FF, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $FF, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $FF, $18
    DB      $18, $1C, $0F, $07, $00, $00, $00, $18
    DB      $18, $38, $F0, $E0, $00, $00, $00, $16
    DB      $16, $16, $16, $16, $16, $16, $16, $68
    DB      $68, $68, $68, $68, $68, $68, $68, $19
    DB      $19, $19, $19, $19, $19, $19, $19, $98
    DB      $98, $98, $98, $98, $98, $98, $98, $FF
    DB      $00, $00, $FF, $FF, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $1D, $11, $19, $11, $1D, $00, $00, $00
    DB      $AE, $A8, $6C, $68, $2E, $00, $00, $00
    DB      $F3, $94, $E4, $B5, $93, $00, $00, $00
    DB      $A8, $A8, $38, $90, $10, $00, $00, $00
    DB      $1C, $1C, $00, $00, $1C, $1C, $00, $00
    DB      $00, $00, $00, $00, $1C, $1C, $00, $00
    DB      $0A, $3A, $7A, $7A, $3A, $0A, $00, $00
    DB      $50, $5C, $5E, $5E, $5C, $50, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $08
    DB      $00, $01, $20, $00, $00, $81, $00, $08
    DB      $00, $04, $00, $00, $20, $80, $00, $00
    DB      $00, $20, $00, $40, $00, $02, $00, $10
    DB      $10, $54, $38, $EE, $38, $54, $10, $42
    DB      $E0, $40, $04, $04, $1F, $04, $04, $10
    DB      $00, $00, $00, $80, $00, $04, $00, $00
    DB      $00, $00, $08, $00, $00, $00, $00, $00
    DB      $00, $0E, $38, $70, $70, $E0, $E0, $80
    DB      $80, $40, $E0, $50, $A8, $7F, $F9, $E0
    DB      $E0, $70, $70, $38, $0E, $00, $00, $1C
    DB      $30, $60, $60, $60, $60, $30, $1C, $87
    DB      $81, $C1, $E3, $5E, $AC, $57, $29, $80
    DB      $F8, $3E, $0F, $1F, $7C, $E0, $00, $01
    DB      $1F, $7C, $F0, $F8, $3E, $07, $00, $00
    DB      $00, $00, $00, $00, $00, $D4, $00, $00
    DB      $00, $00, $00, $03, $06, $0D, $1E, $00
    DB      $00, $3C, $FF, $E0, $70, $88, $10, $00
    DB      $00, $00, $00, $80, $40, $00, $08, $FA
    DB      $EC, $36, $35, $2C, $3C, $FF, $E0, $0F
    DB      $07, $00, $00, $00, $00, $07, $00, $1F
    DB      $0D, $06, $03, $00, $00, $00, $00, $28
    DB      $94, $E4, $F9, $FF, $3C, $00, $00, $00
    DB      $10, $20, $C0, $00, $00, $00, $00, $00
    DB      $7E, $42, $42, $46, $46, $7E, $00, $00
    DB      $08, $08, $08, $18, $18, $18, $00, $00
    DB      $7E, $02, $7E, $60, $60, $7E, $00, $00
    DB      $7C, $44, $1E, $46, $46, $7E, $00, $00
    DB      $40, $44, $44, $7F, $0C, $0C, $00, $00
    DB      $7E, $40, $7C, $06, $46, $7E, $00, $00
    DB      $40, $40, $7C, $46, $46, $7E, $00, $00
    DB      $7E, $02, $02, $06, $06, $06, $00, $00
    DB      $3E, $22, $7E, $46, $46, $7E, $00, $00
    DB      $7E, $42, $7E, $06, $06, $06, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $FE, $FE, $FE, $FE, $01, $01, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $20
    DB      $26, $85, $20, $48, $30, $60, $A1, $83
    DB      $69, $20, $00, $00, $00, $00, $00, $80
    DB      $C2, $11, $02, $07, $02, $00, $22, $80
    DB      $00, $00, $00, $00, $00, $00, $80, $80
    DB      $00, $21, $12, $12, $21, $00, $80, $41
    DB      $02, $00, $00, $00, $00, $02, $41, $A1
    DB      $60, $30, $48, $20, $85, $26, $20, $00
    DB      $00, $00, $00, $00, $20, $69, $83, $22
    DB      $00, $02, $07, $02, $11, $C2, $80, $00
    DB      $02, $04, $20, $0E, $3C, $5A, $38, $00
    DB      $08, $B0, $1E, $4E, $14, $40, $00, $00
    DB      $90, $40, $08, $9E, $2C, $34, $A6, $10
    DB      $40, $E0, $50, $50, $E0, $40, $10, $00
    DB      $42, $24, $00, $00, $24, $42, $00, $00
    DB      $0A, $1E, $04, $04, $1E, $0A, $00, $38
    DB      $5A, $3C, $0E, $20, $04, $02, $00, $00
    DB      $40, $14, $4E, $1E, $B0, $08, $00, $A6
    DB      $34, $2C, $9E, $08, $40, $90, $00, $00
    DB      $0D, $10, $20, $40, $40, $44, $8E, $3C
    DB      $81, $00, $00, $48, $1C, $1B, $88, $00
    DB      $B0, $08, $04, $02, $82, $22, $31, $46
    DB      $41, $8A, $04, $04, $8A, $41, $46, $C4
    DB      $00, $00, $0C, $0C, $00, $00, $C4, $42
    DB      $12, $B9, $10, $10, $B9, $12, $42, $8E
    DB      $44, $40, $40, $20, $10, $0D, $00, $88
    DB      $1B, $1C, $48, $00, $00, $81, $3C, $31
    DB      $22, $82, $02, $04, $08, $B0, $00, $00
    DB      $00, $00, $00, $00, $00, $01, $04, $00
    DB      $00, $00, $08, $77, $80, $00, $00, $00
    DB      $00, $00, $00, $00, $80, $40, $10, $04
    DB      $04, $04, $08, $08, $04, $04, $04, $41
    DB      $14, $41, $00, $00, $41, $14, $41, $10
    DB      $10, $10, $08, $08, $10, $10, $10, $04
    DB      $01, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $80, $77, $08, $00, $00, $00, $10
    DB      $40, $80, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $08, $14, $14, $08, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $3C
    DB      $42, $99, $91, $91, $99, $42, $3C, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $7C
    DB      $44, $44, $44, $FE, $C2, $C2, $C2, $FC
    DB      $84, $84, $84, $FE, $C2, $C2, $FE, $FE
    DB      $82, $80, $80, $C0, $C0, $C2, $FE, $FC
    DB      $86, $82, $82, $C2, $C2, $C6, $FC, $FE
    DB      $80, $80, $80, $FE, $C0, $C0, $FE, $FE
    DB      $80, $80, $80, $FE, $C0, $C0, $C0, $FE
    DB      $82, $80, $80, $CE, $C2, $C2, $FE, $82
    DB      $82, $82, $82, $FE, $C2, $C2, $C2, $10
    DB      $10, $10, $10, $18, $18, $18, $18, $04
    DB      $04, $04, $04, $06, $86, $86, $FE, $84
    DB      $84, $8C, $88, $FE, $C2, $C2, $C2, $80
    DB      $80, $80, $80, $C0, $C0, $C0, $FE, $FE
    DB      $92, $92, $92, $D2, $D2, $D2, $D2, $FE
    DB      $82, $82, $82, $C2, $C2, $C2, $C2, $FE
    DB      $86, $82, $82, $82, $82, $82, $FE, $FE
    DB      $82, $82, $FE, $C0, $C0, $C0, $C0, $FE
    DB      $82, $82, $82, $82, $82, $9E, $FE, $FC
    DB      $84, $84, $84, $FE, $C2, $C2, $C2, $FE
    DB      $82, $80, $FE, $06, $86, $86, $FE, $FE
    DB      $10, $10, $10, $18, $18, $18, $18, $82
    DB      $82, $82, $82, $C2, $C2, $C2, $FE, $C2
    DB      $C2, $C2, $C6, $44, $44, $44, $7C, $92
    DB      $92, $92, $92, $D2, $D2, $D2, $FE, $82
    DB      $82, $82, $FE, $44, $C2, $C2, $C2, $82
    DB      $82, $82, $82, $FE, $18, $18, $18, $FE
    DB      $82, $02, $7E, $C0, $C0, $C2, $FE, $0F
    DB      $0B, $03, $09, $0D, $01, $00, $0E, $32
    DB      $40, $10, $04, $32, $40, $14, $08, $98
    DB      $40, $2C, $01, $98, $40, $C8, $00, $88
    DB      $C8, $BC, $00, $88, $20, $3C, $09, $88
    DB      $30, $40, $09, $88, $40, $44, $09, $70
    DB      $90, $80, $0C, $70, $A0, $84, $0C, $68
    DB      $20, $78, $0F, $68, $70, $7C, $0F, $C8
    DB      $00, $98, $0F, $C8, $20, $98, $0F, $C8
    DB      $40, $08, $0F, $C8, $80, $08, $0F, $C8
    DB      $90, $0C, $0F, $B6, $68, $00, $0F, $D0
    DB      $80, $C0, $E0, $00, $00, $00, $00, $00
    DB      $20, $60, $E0, $00, $00, $00, $00, $00
    DB      $A0, $E0, $40, $40, $00, $00, $00, $00
    DB      $C0, $C0, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $1E, $27, $FF, $00, $18, $3F
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $80, $FF, $00, $C0, $80
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $4F, $E0, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $FC, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $01, $FF, $00, $03, $01
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $78, $E4, $FF, $00, $18, $FC
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $3F, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $F2, $07, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $01, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $80, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $03, $03, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $C0, $C0, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $07, $0F, $07, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $E0, $F0, $E0, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $01, $07, $1F, $07, $01, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $80, $E0, $F8, $E0, $80, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $03, $1F, $7F, $1F, $03, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $C0, $F8, $FE, $F8, $C0, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $07, $3F, $FF, $3F, $07, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $E0, $FC, $FF, $FC, $E0, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $01, $03, $1F, $FF, $FF
    DB      $00, $00, $00, $01, $21, $71, $71, $71
    DB      $71, $79, $7B, $FF, $FF, $FF, $FF, $FF
    DB      $00, $00, $00, $C0, $E0, $B1, $D9, $AD
    DB      $D5, $AD, $D5, $FF, $FF, $FF, $FF, $FF
    DB      $0E, $0A, $1E, $1A, $1E, $3A, $3E, $3B
    DB      $7F, $FB, $7F, $FB, $FF, $FF, $FF, $FF
    DB      $00, $00, $00, $00, $00, $08, $08, $18
    DB      $38, $38, $7B, $7B, $FF, $FF, $FF, $FF
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $90, $F0, $FF, $FF
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $01, $00, $01, $07, $0D, $7F, $FF
    DB      $00, $00, $00, $00, $08, $00, $15, $81
    DB      $69, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $00, $00, $00, $00, $0A, $02, $E2, $B7
    DB      $DD, $AF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $00, $00, $00, $0E, $0A, $2E, $4B, $AE
    DB      $6E, $FE, $7D, $FF, $FF, $FF, $FF, $FF
    DB      $00, $00, $00, $00, $00, $A0, $00, $00
    DB      $A0, $C8, $70, $BC, $EF, $FE, $FF, $FF
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $80, $C0, $F0, $FF
    DB      $00, $00, $00, $20, $14, $0C, $0A, $22
    DB      $0F, $07, $00, $00, $00, $00, $0F, $FF
    DB      $40, $30, $3C, $8C, $0E, $6B, $3E, $8B
    DB      $31, $48, $F6, $FF, $1F, $03, $FF, $FF
    DB      $41, $34, $1B, $8F, $2B, $5E, $9D, $4F
    DB      $EF, $7E, $BF, $FF, $FF, $FF, $FF, $FF
    DB      $20, $80, $04, $60, $D4, $DE, $E7, $EB
    DB      $FE, $F7, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $40, $00, $08, $30, $A8, $E0, $CA, $D5
    DB      $9F, $DE, $EF, $7E, $F8, $D0, $FF, $FF
    DB      $00, $00, $00, $00, $08, $50, $64, $C0
    DB      $88, $00, $80, $00, $00, $00, $F0, $FF
    DB      $00, $00, $00, $00, $02, $00, $00, $20
    DB      $30, $1C, $0F, $07, $20, $07, $1F, $FF
    DB      $00, $00, $00, $00, $10, $B0, $F0, $38
    DB      $1C, $4D, $DF, $F5, $FF, $FF, $FF, $FF
    DB      $00, $02, $12, $36, $0E, $05, $8F, $99
    DB      $36, $7B, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $00, $00, $00, $00, $80, $20, $60, $C8
    DB      $51, $F2, $B6, $F6, $FF, $FF, $FF, $FF
    DB      $00, $00, $00, $00, $28, $40, $C0, $E0
    DB      $C9, $DF, $BE, $76, $F8, $FF, $FF, $FF
    DB      $00, $00, $00, $00, $00, $00, $00, $60
    DB      $C0, $80, $40, $00, $00, $00, $F8, $FF
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $09, $19, $7F, $80, $77, $0C, $00
    DB      $00, $00, $00, $01, $01, $41, $C1, $43
    DB      $E1, $EF, $4B, $FF, $06, $C1, $FF, $03
    DB      $00, $00, $00, $00, $00, $80, $01, $91
    DB      $3F, $FF, $C0, $FF, $00, $8F, $FF, $FF
    DB      $00, $00, $00, $00, $00, $02, $03, $83
    DB      $4E, $FA, $3F, $FF, $0F, $C0, $FF, $FE
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $80, $BC, $CD, $FF, $F0, $0F, $FC, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $80
    DB      $C0, $80, $D0, $FC, $07, $FE, $00, $00
    DB      $00, $08, $2C, $7C, $FA, $FD, $E3, $1F
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $80, $C0, $B8, $84, $6C
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $07, $0F, $07, $19, $1F, $75, $EE
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $80, $C0, $B8, $84, $6C
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $04, $1C, $1E, $1F, $7B, $77
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $80, $C0, $B8, $84, $6C
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $07, $0F, $07, $19, $1F, $75, $EE
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $80, $C0, $B8, $84, $6C
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $01, $03, $03, $01, $01, $01, $01, $01
    DB      $01, $01, $01, $07, $0D, $1F, $20, $3F
    DB      $80, $00, $7F, $00, $80, $80, $80, $80
    DB      $80, $80, $B8, $B4, $AC, $D8, $30, $E0
    DB      $00, $00, $FF, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $03, $06, $0F, $10, $1F
    DB      $C0, $60, $60, $40, $C0, $C0, $C0, $C0
    DB      $C0, $C0, $DC, $DA, $D6, $EC, $08, $F0
    DB      $01, $03, $03, $01, $01, $01, $01, $01
    DB      $01, $01, $01, $07, $0D, $1F, $20, $3F
    DB      $D1, $2A, $44, $2A, $D1, $80, $80, $80
    DB      $80, $80, $B8, $B4, $AC, $D8, $30, $E0
    DB      $11, $AA, $45, $AA, $11, $00, $00, $00
    DB      $00, $00, $00, $03, $06, $0F, $10, $1F
    DB      $C0, $60, $60, $40, $C0, $C0, $C0, $C0
    DB      $C0, $C0, $DC, $DA, $D6, $EC, $08, $F0
    DB      $80, $80, $80, $80, $80, $80, $80, $80
    DB      $80, $80, $80, $80, $80, $80, $80, $80
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $01, $03
    DB      $07, $0F, $1F, $3F, $7F, $FF, $FF, $FF
    DB      $00, $00, $03, $0F, $3F, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $07, $3F, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $E0, $FC, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $00, $00, $C0, $F0, $FC, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $00, $00, $00, $00, $00, $00, $80, $C0
    DB      $E0, $F0, $F8, $FC, $FE, $FF, $FF, $FF
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $05, $02, $09
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $A0, $40, $90
    DB      $00, $00, $00, $00, $00, $00, $09, $42
    DB      $49, $22, $05, $09, $28, $00, $20, $00
    DB      $00, $00, $00, $00, $00, $00, $90, $A2
    DB      $52, $44, $60, $10, $14, $00, $02, $00
    DB      $01, $09, $02, $14, $94, $DD, $4B, $22
    DB      $28, $80, $C0, $40, $04, $12, $00, $01
    DB      $00, $40, $A0, $A8, $60, $C4, $D8, $AA
    DB      $56, $04, $01, $03, $20, $48, $00, $80
    DB      $0A, $90, $96, $44, $D9, $30, $20, $80
    DB      $00, $00, $00, $00, $10, $01, $40, $00
    DB      $A2, $46, $B4, $AC, $31, $05, $0E, $02
    DB      $00, $01, $00, $00, $10, $80, $02, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $C0, $E0, $70, $38, $3E, $12
    DB      $12, $FF, $FF, $7F, $3F, $10, $B0, $FC
    DB      $02, $06, $0C, $1C, $38, $68, $08, $1C
    DB      $3E, $23, $FF, $FF, $FE, $08, $48, $7E
    DB      $00, $00, $00, $60, $70, $38, $3E, $1E
    DB      $12, $FF, $FF, $7F, $3F, $10, $B0, $FC
    DB      $1C, $3E, $3E, $3E, $3E, $1C, $08, $1C
    DB      $3E, $23, $FF, $FF, $FE, $08, $48, $7E
    DB      $00, $00, $C0, $E0, $70, $38, $3E, $12
    DB      $12, $FF, $FF, $7F, $3F, $10, $B0, $FC
    DB      $20, $30, $38, $1C, $1E, $0B, $08, $1C
    DB      $3E, $23, $FF, $FF, $FE, $08, $48, $7E
    DB      $AD, $52, $19, $6C, $06, $02, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $AA, $01, $8D, $B0, $16, $C0, $40, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $52, $A9, $A6, $68, $05, $01, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $55, $68, $35, $D0, $08, $80, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $52, $02, $99, $12, $08, $02, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $54, $95, $4A, $28, $A0, $40, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $24, $AE, $30, $70, $06, $AE, $30, $70
    DB      $33, $AE, $30, $70, $5A, $AE, $30, $70
    DB      $F6, $AD, $3A, $70, $1B, $AE, $3A, $70
    DB      $48, $AE, $3A, $70, $EF, $AD, $44, $70
    DB      $FF, $AD, $44, $70, $39, $AE, $44, $70
    DB      $51, $AE, $44, $70, $67, $AE, $44, $70
    DB      $15, $AE, $4E, $70, $2D, $AE, $4E, $70
    DB      $0F, $AE, $4E, $70, $42, $AE, $4E, $70
    DB      $60, $AE, $4E, $70, $C1, $20, $80, $30
    DB      $11, $01, $D0, $83, $00, $80, $08, $11
    DB      $40, $1F, $14, $90, $C2, $20, $B0, $10
    DB      $80, $11, $D0, $43, $20, $00, $20, $14
    DB      $20, $10, $00, $50, $02, $07, $20, $1C
    DB      $34, $10, $02, $06, $20, $70, $14, $10
    DB      $83, $C0, $20, $20, $17, $40, $7E, $1C
    DB      $90, $43, $C0, $40, $10, $24, $F2, $81
    DB      $11, $50, $02, $80, $20, $80, $01, $10
    DB      $02, $07, $40, $10, $20, $10, $C3, $00
    DB      $02, $20, $11, $DD, $10, $22, $D0, $02
    DB      $34, $20, $10, $33, $D0, $43, $80, $00
    DB      $60, $11, $76, $10, $89, $50, $C3, $80
    DB      $00, $60, $11, $80, $10, $89, $D0, $02
    DB      $07, $60, $10, $80, $D0, $C1, $00, $02
    DB      $10, $11, $DD, $D0, $02, $37, $10, $00
    DB      $00, $D0, $3A, $5D, $70, $06, $08, $21
    DB      $97, $AE, $C5, $0F, $F5, $CD, $84, $AE
    DB      $F1, $C1, $10, $F6, $AF, $32, $5D, $70
    DB      $C9, $30, $0C, $23, $AF, $BE, $C8, $E5
    DB      $46, $CD, $F1, $1F, $E1, $18, $F4, $23
    DB      $AF, $BE, $C8, $18, $FA, $01, $0E, $00
    DB      $07, $0B, $04, $00, $02, $02, $00, $06
    DB      $0D, $00, $0A, $10, $00, $03, $00, $08
    DB      $00, $09, $00, $00, $00, $00, $00, $00
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
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00
