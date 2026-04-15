; =============================================================================
; BOULDER DASH  --  ColecoVision  (16 KB ROM, loads at $8000)
; Disassembled by z80cv_disasm.py  |  Annotated with Claude Sonnet 4.6
; Exact byte-match verified vs. boulder-dash-1984.rom
; =============================================================================
;
; LEGEND / CROSS-REFERENCE  --  all line numbers refer to THIS file.
; ROM addresses shown as ($XXXX).
;
; --- HARDWARE / BIOS ----------------------------------------------------------
;   BIOS entry points:       lines 97-146   (EQU block)
;   I/O port definitions:    lines 150-156
;   RAM definitions:         lines 160-163
;     WORK_BUFFER       $7000   general RAM workspace
;     CONTROLLER_BUFFER $702B   score table pointer / digit walk context
;     JOYSTICK_BUFFER   $7057   raw BIOS POLLER output (init $9F)
;     STACKTOP          $73B9   (defined but unused -- game stack at $7020)
;
; --- ROM LAYOUT ---------------------------------------------------------------
;   $8000  cart magic + header                    line  180
;          Embedded tile/sprite data in header ($8024-$90AF, ~4 KB)
;   $8021  CART_ENTRY / JP NMI                    line  180
;   $90B0  START -- boot init                     line  714
;   $A9ED  NMI handler                            line 1718
;   $B054  GAME_DATA  (raw DB, ~2.7 KB)           line 1968
;   $BC00  TILE_BITMAPS (110 tiles, 8 bytes each) line 2349
;
; --- BOOT / INIT SEQUENCE -----------------------------------------------------
;   START ($90B0)             line  714    SP=$7020, VDP/RAM init, VRAM load, enqueue task
;   SUB_90F4 ($90F4)          line  741    VDP register setup + 5x INIT_TABLE calls
;   DELAY_LOOP_9132 ($9132)   line  768    clear JOYSTICK_BUFFER area, set $9F/$0F defaults
;   DELAY_LOOP_9150 ($9150)   line  786    init 2-slot TCB free-list at $7030
;   SUB_92C7 ($92C7)          line  913    load tile patterns to VRAM via PUT_VRAM (7 calls)
;   SUB_93D9 ($93D9)          line  972    VRAM write wrapper: PUSH IX, PUT_VRAM, POP IX
;
; --- TASK SCHEDULER (cooperative multitasker) ---------------------------------
;   Task Control Block (TCB) layout -- 10 bytes per slot at $7030:
;     +0,+1 = next task pointer (linked list)
;     +2,+3 = code pointer (JP target when timer expires)
;     +4    = frame countdown timer
;     +5    = parameter byte
;     +6    = flags (bit 0 = active)
;   $704E = free-task head pointer (head of free list)
;   $7050 = task list head
;   $7052 = task dispatch current pointer
;   $7054 = task frame pointer (IX during execution)
;
;   SUB_91E8 ($91E8)  line  822   enqueue task: set TCB fields, splice into active list
;   LOC_9229 ($9229)  line  851   return carry=1 (no free task slot)
;   LOC_956D ($956D)  line 1031   main loop: wait for frame, score update, dispatch
;   LOC_9584 ($9584)  line 1042   task dispatch init: IX = task list head
;   LOC_958E ($958E)  line 1047   task execution: DEC timer, JP (HL) when zero
;   LOC_95AF ($95AF)  line 1058   task chain: advance to next task, loop or restart
;
; --- SCORE SYSTEM -------------------------------------------------------------
;   $702D = BCD score digit pointer (walks score table $0100-$1100, wraps)
;   $702F = score accumulator (BCD byte)
;   SUB_923F ($923F)  line  858   score update: advance digit ptr, add to accumulator
;   SUB_925E ($925E)  line  875   BCD digit increment (wraps at $11 back to $0100)
;   LOC_9272 ($9272)  line  887   digit wrap: reset $702D to $0100
;   LOC_927A ($927A)  line  892   score adjust: (A + C) mod 7 + 2 -> score column
;
; --- NMI HANDLER ($A9ED) ------------------------------------------------------
;   NMI                line 1718    frame counter $7056 INC each VSYNC
;                                 60-frame timer at $7385 (0-$3B per second)
;                                 POLLER, PLAY_SONGS, SOUND_MAN called each frame
;                                 if $73AF==$02: LDIR sprite attrs $705E to $7059
;   LOC_AA15 ($AA15)   line 1740    decrement per-second timer at $7386
;   LOC_AA1B ($AA1B)   line 1745    store $7385, OUT ($C0), poll + sound, check $73AF
;   LOC_AA3C ($AA3C)   line 1759    restore regs + RETN (end of NMI)
;
; --- KEY RAM VARIABLES --------------------------------------------------------
;   $7020  game stack pointer (SP reset here each main loop + dispatch)
;   $7030  task TCB pool base (2 slots x 10 bytes = 20 bytes)
;   $704E  free-task head pointer
;   $7050  task list head
;   $7052  task dispatch current
;   $7054  task frame pointer
;   $7056  frame counter (INC each NMI, reset each main-loop sync)
;   $7057  JOYSTICK_BUFFER (BIOS POLLER raw output, init $9F)
;   $7058  joystick mirror / prev state (init $9F)
;   $705D  sprite colour attribute (init $0F = white)
;   $705E  sprite attribute source buffer (5 bytes)
;   $7059  sprite attribute destination (LDIR target in NMI)
;   $7062  sprite attribute 2 (init $0F)
;   $7385  NMI timer (0-$3B, 60-frame cycle)
;   $7386  per-second countdown (decremented at $7385 wrap)
;   $7396  timeout countdown (decremented once per second)
;   $739A  frame sync target (main loop waits for $7056 == $739A)
;   $73AF  game state flag ($02 = sprite attribute update pending)
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
JOYSTICK_BUFFER:         EQU $7057
STACKTOP:                EQU $73B9

FNAME "BOULDER-DASH-1984-NEW.ROM"
CPU Z80

    ORG     $8000

    DW      $AA55                    ; cart magic
    DB      $00, $00
    DB      $00, $00
    DB      $00, $00
    DW      JOYSTICK_BUFFER             ; BIOS POLLER writes controller state here
    DW      START                       ; start address
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00

CART_ENTRY:
    JP      NMI

    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $B1, $0C, $A0, $4A, $1A, $48, $52, $08
    DB      $44, $29, $B1, $84, $25, $B6, $60, $46
    DB      $D2, $0B, $92, $41, $AC, $24, $55, $C8
    DB      $13, $88, $6D, $10, $2B, $08, $52, $B9
    DB      $00, $F7, $F7, $F7, $00, $7F, $7F, $7F
    DB      $00, $F7, $F7, $F7, $00, $7F, $7F, $7F
    DB      $00, $F7, $F7, $F7, $00, $7F, $7F, $7F
    DB      $00, $F7, $F7, $F7, $00, $7F, $7F, $7F
    DB      $FF, $83, $FB, $8B, $EB, $EB, $FF, $FF
    DB      $FF, $83, $FB, $8B, $EB, $EB, $FF, $FF
    DB      $FF, $83, $FB, $8B, $EB, $EB, $FF, $FF
    DB      $FF, $83, $FB, $8B, $EB, $EB, $FF, $FF
    DB      $00, $0F, $3D, $37, $7F, $5E, $FF, $FB
    DB      $FF, $FE, $DF, $55, $78, $43, $30, $0F
    DB      $00, $F0, $CC, $E2, $BE, $E9, $D9, $6B
    DB      $E1, $B7, $51, $11, $86, $6C, $18, $E0
    DB      $00, $0C, $0F, $19, $19, $0F, $03, $0F
    DB      $1B, $0B, $0F, $07, $04, $04, $1C, $00
    DB      $00, $30, $F0, $98, $98, $F0, $C0, $F0
    DB      $D8, $D0, $F0, $C0, $60, $20, $20, $38
    DB      $00, $0C, $0F, $19, $19, $0F, $03, $0F
    DB      $1B, $0B, $0F, $03, $06, $04, $04, $1C
    DB      $00, $30, $F0, $98, $98, $F0, $C0, $F0
    DB      $D8, $D0, $F0, $C0, $60, $20, $20, $38
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $7E, $81, $BD, $A1, $A1, $BD, $81, $7E
    DB      $1F, $04, $04, $04, $00, $00, $00, $00
    DB      $44, $6C, $54, $54, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $30, $30, $30, $30, $30, $00, $30, $00
    DB      $50, $50, $50, $00, $00, $00, $00, $00
    DB      $50, $50, $F8, $50, $F8, $50, $50, $00
    DB      $20, $78, $A0, $70, $28, $F0, $20, $00
    DB      $C0, $C8, $10, $20, $40, $98, $18, $00
    DB      $40, $A0, $A0, $40, $A8, $90, $68, $00
    DB      $20, $20, $20, $00, $00, $00, $00, $00
    DB      $FF, $7F, $3F, $1F, $0F, $07, $03, $01
    DB      $01, $03, $07, $0F, $1F, $3F, $7F, $FF
    DB      $80, $C0, $E0, $F0, $F8, $FC, $FE, $FF
    DB      $FF, $FE, $FC, $F8, $F0, $E0, $C0, $80
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $00, $00, $00, $F8, $00, $00, $00, $00
    DB      $10, $38, $7C, $FE, $FE, $7C, $38, $10
    DB      $00, $0C, $18, $30, $60, $C0, $00, $00
    DB      $78, $CC, $DC, $FC, $EC, $CC, $78, $00
    DB      $30, $70, $F0, $30, $30, $FC, $FC, $00
    DB      $78, $FC, $CC, $1C, $70, $FC, $FC, $00
    DB      $78, $FC, $0C, $3C, $0C, $FC, $78, $00
    DB      $1C, $3C, $6C, $CC, $FC, $0C, $0C, $00
    DB      $FC, $C0, $C0, $F8, $0C, $CC, $78, $00
    DB      $38, $60, $C0, $F8, $CC, $CC, $78, $00
    DB      $FC, $CC, $18, $30, $30, $30, $30, $00
    DB      $78, $CC, $CC, $78, $CC, $CC, $78, $00
    DB      $78, $CC, $CC, $7C, $0C, $18, $70, $00
    DB      $00, $00, $30, $00, $30, $00, $00, $00
    DB      $00, $00, $20, $00, $20, $20, $40, $00
    DB      $18, $30, $60, $C0, $60, $30, $18, $00
    DB      $00, $00, $F8, $00, $F8, $00, $00, $00
    DB      $60, $30, $18, $0C, $18, $30, $60, $00
    DB      $78, $CC, $18, $30, $30, $00, $30, $00
    DB      $7C, $82, $BA, $A2, $BA, $82, $7C, $00
    DB      $78, $CC, $CC, $FC, $CC, $CC, $CC, $00
    DB      $F8, $CC, $CC, $F8, $CC, $CC, $F8, $00
    DB      $78, $CC, $C0, $C0, $C0, $CC, $78, $00
    DB      $F0, $D8, $CC, $CC, $CC, $D8, $F0, $00
    DB      $FC, $C0, $C0, $F0, $C0, $C0, $FC, $00
    DB      $FC, $C0, $C0, $F0, $C0, $C0, $C0, $00
    DB      $78, $CC, $C0, $DC, $CC, $CC, $78, $00
    DB      $CC, $CC, $CC, $FC, $CC, $CC, $CC, $00
    DB      $FC, $30, $30, $30, $30, $30, $FC, $00
    DB      $0C, $0C, $0C, $0C, $CC, $CC, $78, $00
    DB      $CC, $D8, $F0, $E0, $F0, $D8, $CC, $00
    DB      $C0, $C0, $C0, $C0, $C0, $C0, $FC, $00
    DB      $CC, $FC, $CC, $CC, $CC, $CC, $CC, $00
    DB      $CC, $CC, $EC, $FC, $DC, $CC, $CC, $00
    DB      $78, $CC, $CC, $CC, $CC, $CC, $78, $00
    DB      $F8, $CC, $CC, $F8, $C0, $C0, $C0, $00
    DB      $78, $CC, $CC, $CC, $D4, $C8, $74, $00
    DB      $F8, $CC, $CC, $F8, $F0, $D8, $CC, $00
    DB      $78, $CC, $C0, $78, $0C, $CC, $78, $00
    DB      $FC, $30, $30, $30, $30, $30, $30, $00
    DB      $CC, $CC, $CC, $CC, $CC, $CC, $78, $00
    DB      $CC, $CC, $CC, $CC, $CC, $78, $30, $00
    DB      $CC, $CC, $CC, $CC, $CC, $FC, $CC, $00
    DB      $CC, $CC, $78, $30, $78, $CC, $CC, $00
    DB      $CC, $CC, $78, $30, $30, $30, $30, $00
    DB      $FC, $0C, $18, $30, $60, $C0, $FC, $00
    DB      $F8, $C0, $C0, $C0, $C0, $C0, $F8, $00
    DB      $01, $03, $07, $0F, $1F, $3F, $7F, $7F
    DB      $7F, $7F, $3F, $1F, $0F, $07, $03, $01
    DB      $80, $C0, $E0, $F0, $F8, $FC, $FE, $FE
    DB      $FE, $FE, $FC, $F8, $F0, $E0, $C0, $80
    DB      $01, $03, $07, $0F, $1F, $3F, $7F, $7F
    DB      $7F, $7F, $3F, $1F, $0F, $07, $03, $01
    DB      $80, $C0, $E0, $F0, $F8, $FC, $FE, $FE
    DB      $FE, $FE, $FC, $F8, $F0, $E0, $C0, $80
    DB      $01, $03, $07, $0F, $1F, $3F, $7F, $7F
    DB      $7F, $7F, $3F, $1F, $0F, $07, $03, $01
    DB      $80, $C0, $E0, $F0, $F8, $FC, $FE, $FE
    DB      $FE, $FE, $FC, $F8, $F0, $E0, $C0, $80
    DB      $01, $03, $07, $0F, $1F, $3F, $7F, $7F
    DB      $7F, $7F, $3F, $1F, $0F, $07, $03, $01
    DB      $80, $C0, $E0, $F0, $F8, $FC, $FE, $FE
    DB      $FE, $FE, $FC, $F8, $F0, $E0, $C0, $80
    DB      $40, $60, $70, $78, $7C, $3E, $01, $03
    DB      $01, $3E, $7C, $78, $70, $60, $60, $40
    DB      $02, $06, $0E, $1E, $3E, $7C, $80, $C0
    DB      $80, $7C, $3E, $1E, $0E, $06, $06, $02
    DB      $10, $18, $18, $1C, $1C, $0E, $01, $03
    DB      $01, $0E, $1C, $1C, $18, $18, $18, $10
    DB      $08, $18, $18, $38, $38, $70, $80, $C0
    DB      $80, $70, $38, $38, $18, $18, $18, $08
    DB      $04, $04, $04, $06, $06, $06, $01, $03
    DB      $01, $06, $06, $06, $06, $06, $04, $04
    DB      $20, $20, $20, $60, $60, $60, $80, $C0
    DB      $80, $60, $60, $60, $60, $60, $20, $20
    DB      $10, $18, $18, $1C, $1C, $0E, $01, $03
    DB      $01, $0E, $1C, $1C, $18, $18, $18, $10
    DB      $08, $18, $18, $38, $38, $70, $80, $C0
    DB      $80, $70, $38, $38, $18, $18, $18, $08
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FC, $FC
    DB      $FC, $FC, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $3F, $3F
    DB      $3F, $3F, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $F0, $F0, $F3, $F3
    DB      $F3, $F3, $F0, $F0, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $0F, $0F, $CF, $CF
    DB      $CF, $CF, $0F, $0F, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $C0, $C0, $CF, $CF, $CF, $CF
    DB      $CF, $CF, $CF, $CF, $C0, $C0, $FF, $FF
    DB      $FF, $FF, $03, $03, $F3, $F3, $F3, $F3
    DB      $F3, $F3, $F3, $F3, $03, $03, $FF, $FF
    DB      $00, $00, $3F, $3F, $3F, $3F, $3F, $3F
    DB      $3F, $3F, $3F, $3F, $3F, $3F, $00, $00
    DB      $00, $00, $FC, $FC, $FC, $FC, $FC, $FC
    DB      $FC, $FC, $FC, $FC, $FC, $FC, $00, $00
    DB      $FE, $FF, $FF, $FF, $FF, $7F, $FF, $FF
    DB      $FF, $FF, $7F, $7F, $3F, $7C, $78, $F0
    DB      $7F, $FF, $FE, $FE, $FC, $FC, $FE, $FE
    DB      $FF, $FF, $FE, $FE, $FF, $FF, $7F, $3F
    DB      $FC, $FE, $FF, $FF, $7F, $7F, $7F, $FF
    DB      $FF, $FF, $FF, $7F, $7F, $7F, $FC, $F8
    DB      $3F, $7F, $FF, $FE, $FE, $FE, $FE, $FF
    DB      $FF, $FE, $FE, $FE, $FE, $FF, $FF, $7F
    DB      $F8, $FC, $FE, $7F, $7F, $3F, $7F, $7F
    DB      $FF, $FF, $FF, $FF, $7F, $FF, $FF, $F8
    DB      $1F, $3F, $7F, $FF, $FF, $FF, $FF, $FF
    DB      $FE, $FE, $FC, $FC, $FE, $FE, $FF, $FF
    DB      $FC, $FE, $FF, $FF, $7F, $7F, $7F, $FF
    DB      $FF, $FF, $FF, $7F, $7F, $7F, $FC, $F8
    DB      $3F, $7F, $FF, $FE, $FE, $FE, $FE, $FF
    DB      $FF, $FE, $FE, $FE, $FE, $FF, $FF, $7F
    DB      $33, $F7, $F7, $FF, $CC, $FF, $7F, $7F
    DB      $33, $F7, $F7, $FF, $CC, $FF, $7F, $7F
    DB      $33, $F7, $F7, $FF, $CC, $FF, $7F, $7F
    DB      $33, $F7, $F7, $FF, $CC, $FF, $7F, $7F
    DB      $66, $F7, $F7, $F7, $66, $7F, $7F, $7F
    DB      $66, $F7, $F7, $F7, $66, $7F, $7F, $7F
    DB      $66, $F7, $F7, $F7, $66, $7F, $7F, $7F
    DB      $66, $F7, $F7, $F7, $66, $7F, $7F, $7F
    DB      $CC, $FF, $F7, $F7, $33, $7F, $7F, $FF
    DB      $CC, $FF, $F7, $F7, $33, $7F, $7F, $FF
    DB      $CC, $FF, $F7, $F7, $33, $7F, $7F, $FF
    DB      $CC, $FF, $F7, $F7, $33, $7F, $7F, $FF
    DB      $99, $FF, $F7, $FF, $99, $FF, $7F, $FF
    DB      $99, $FF, $F7, $FF, $99, $FF, $7F, $FF
    DB      $99, $FF, $F7, $FF, $99, $FF, $7F, $FF
    DB      $99, $FF, $F7, $FF, $99, $FF, $7F, $FF
    DB      $FF, $80, $80, $80, $80, $80, $80, $80
    DB      $80, $80, $80, $80, $80, $80, $80, $FF
    DB      $FF, $01, $01, $01, $01, $01, $01, $01
    DB      $01, $01, $01, $01, $01, $01, $01, $FF
    DB      $FF, $83, $FB, $8B, $EB, $EB, $FF, $FF
    DB      $FF, $83, $FB, $8B, $EB, $EB, $FF, $FF
    DB      $FF, $83, $FB, $8B, $EB, $EB, $FF, $FF
    DB      $FF, $83, $FB, $8B, $EB, $EB, $FF, $FF
    DB      $FF, $80, $80, $80, $80, $80, $80, $80
    DB      $80, $80, $80, $80, $80, $80, $80, $FF
    DB      $FF, $01, $01, $01, $01, $01, $01, $01
    DB      $01, $01, $01, $01, $01, $01, $01, $FF
    DB      $FF, $83, $FB, $8B, $EB, $EB, $FF, $FF
    DB      $FF, $83, $FB, $8B, $EB, $EB, $FF, $FF
    DB      $FF, $83, $FB, $8B, $EB, $EB, $FF, $FF
    DB      $FF, $83, $FB, $8B, $EB, $EB, $FF, $FF
    DB      $00, $0C, $0F, $19, $19, $0F, $03, $0F
    DB      $1B, $33, $33, $03, $06, $04, $04, $1C
    DB      $00, $30, $F0, $98, $98, $F0, $C0, $F0
    DB      $D8, $CC, $CC, $C0, $60, $20, $20, $38
    DB      $00, $0C, $0F, $1F, $19, $0F, $03, $0F
    DB      $1B, $33, $33, $03, $06, $04, $04, $1C
    DB      $00, $30, $F0, $F8, $98, $F0, $C0, $F0
    DB      $D8, $CC, $CC, $C0, $60, $20, $20, $38
    DB      $00, $0C, $0F, $1F, $1F, $0F, $03, $0F
    DB      $1B, $33, $33, $03, $06, $04, $04, $1C
    DB      $00, $30, $F0, $F8, $F8, $F0, $C0, $F0
    DB      $D8, $CC, $CC, $C0, $60, $20, $20, $38
    DB      $00, $0C, $0F, $19, $19, $0F, $03, $0F
    DB      $1B, $33, $33, $03, $06, $04, $04, $1C
    DB      $00, $30, $F0, $98, $98, $F0, $C0, $F0
    DB      $D8, $CC, $CC, $C0, $60, $20, $20, $38
    DB      $00, $03, $07, $07, $07, $03, $03, $03
    DB      $03, $03, $03, $03, $3E, $20, $20, $00
    DB      $00, $80, $E0, $30, $30, $E0, $80, $C0
    DB      $A0, $C0, $80, $E0, $20, $20, $20, $38
    DB      $00, $03, $07, $07, $07, $03, $03, $03
    DB      $03, $03, $03, $03, $1E, $10, $10, $00
    DB      $00, $80, $E0, $30, $30, $E0, $80, $C0
    DB      $A0, $C0, $80, $80, $C0, $40, $40, $70
    DB      $00, $00, $03, $07, $07, $07, $03, $03
    DB      $03, $03, $03, $03, $01, $0F, $08, $08
    DB      $00, $00, $80, $E0, $30, $30, $E0, $80
    DB      $E0, $C0, $80, $80, $80, $80, $80, $E0
    DB      $00, $00, $03, $07, $07, $07, $03, $03
    DB      $03, $03, $03, $03, $01, $07, $05, $05
    DB      $00, $00, $80, $E0, $30, $30, $E0, $80
    DB      $E0, $C0, $80, $80, $00, $00, $00, $C0
    DB      $00, $01, $07, $0C, $0C, $07, $01, $03
    DB      $05, $03, $01, $07, $04, $04, $04, $1C
    DB      $00, $C0, $E0, $E0, $E0, $C0, $C0, $C0
    DB      $C0, $C0, $C0, $C0, $7C, $04, $04, $00
    DB      $00, $01, $07, $0C, $0C, $07, $01, $03
    DB      $05, $03, $01, $01, $03, $02, $02, $0E
    DB      $00, $C0, $E0, $E0, $E0, $C0, $C0, $C0
    DB      $C0, $C0, $C0, $C0, $78, $08, $08, $00
    DB      $00, $00, $01, $07, $0C, $0C, $07, $01
    DB      $07, $03, $01, $01, $01, $01, $01, $07
    DB      $00, $00, $C0, $E0, $E0, $E0, $C0, $80
    DB      $C0, $C0, $C0, $C0, $80, $F0, $10, $10
    DB      $00, $00, $01, $07, $0C, $0C, $07, $01
    DB      $07, $03, $01, $01, $00, $00, $00, $03
    DB      $00, $00, $C0, $E0, $E0, $E0, $C0, $80
    DB      $C0, $C0, $C0, $C0, $80, $E0, $A0, $A0
    DB      $00, $00, $00, $00, $00, $01, $08, $02
    DB      $05, $02, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $40
    DB      $00, $40, $80, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $02, $04, $01, $08, $02
    DB      $05, $0A, $00, $00, $02, $00, $00, $00
    DB      $00, $00, $00, $00, $50, $40, $98, $40
    DB      $00, $50, $80, $00, $20, $00, $00, $00
    DB      $00, $08, $01, $02, $14, $04, $08, $00
    DB      $14, $0A, $00, $28, $02, $00, $00, $00
    DB      $10, $80, $28, $02, $10, $00, $18, $00
    DB      $14, $50, $80, $08, $20, $00, $00, $00
    DB      $20, $08, $00, $02, $90, $00, $00, $00
    DB      $50, $00, $00, $28, $82, $10, $00, $08
    DB      $12, $80, $28, $02, $10, $00, $09, $00
    DB      $04, $10, $00, $09, $20, $00, $90, $04
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $C0, $C0, $C0, $C0, $C0, $C0, $C0, $C0
    DB      $C0, $C0, $C0, $C0, $C0, $C0, $C0, $C0
    DB      $C0, $C0, $C0, $C0, $C0, $C0, $C0, $C0
    DB      $C0, $C0, $C0, $C0, $C0, $C0, $C0, $C0
    DB      $F0, $F0, $F0, $70, $F0, $F0, $F0, $70
    DB      $F0, $F0, $F0, $70, $F0, $F0, $F0, $70
    DB      $F0, $F0, $F0, $70, $F0, $F0, $F0, $70
    DB      $F0, $F0, $F0, $70, $F0, $F0, $F0, $70
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0
    DB      $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0
    DB      $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0
    DB      $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0
    DB      $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0
    DB      $D0, $F0, $A0, $A0, $A0, $A0, $D0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $D0, $F0, $A0, $A0, $A0, $A0, $D0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $D0, $F0, $A0, $A0, $A0, $A0, $D0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $D0, $F0, $A0, $A0, $A0, $A0, $D0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
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
    DB      $80, $80, $80, $80, $80, $80, $80, $80
    DB      $80, $80, $80, $80, $80, $80, $80, $80
    DB      $80, $80, $80, $80, $80, $80, $80, $80
    DB      $80, $80, $80, $80, $80, $80, $80, $80
    DB      $80, $80, $80, $80, $80, $80, $80, $80
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $80, $80, $B0, $B0, $30, $30, $50, $50
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
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $80, $80, $A0, $A0, $20, $20, $40, $40
    DB      $80, $80, $A0, $A0, $20, $20, $40, $40
    DB      $80, $80, $A0, $A0, $20, $20, $40, $40
    DB      $80, $80, $A0, $A0, $20, $20, $40, $40
    DB      $40, $40, $80, $80, $A0, $A0, $20, $20
    DB      $40, $40, $80, $80, $A0, $A0, $20, $20
    DB      $40, $40, $80, $80, $A0, $A0, $20, $20
    DB      $40, $40, $80, $80, $A0, $A0, $20, $20
    DB      $20, $20, $40, $40, $80, $80, $A0, $A0
    DB      $20, $20, $40, $40, $80, $80, $A0, $A0
    DB      $20, $20, $40, $40, $80, $80, $A0, $A0
    DB      $20, $20, $40, $40, $80, $80, $A0, $A0
    DB      $A0, $A0, $20, $20, $40, $40, $80, $80
    DB      $A0, $A0, $20, $20, $40, $40, $80, $80
    DB      $A0, $A0, $20, $20, $40, $40, $80, $80
    DB      $A0, $A0, $20, $20, $40, $40, $80, $80
    DB      $30, $20, $B0, $A0, $80, $50, $A0, $A0
    DB      $A0, $50, $80, $A0, $B0, $20, $20, $30
    DB      $30, $20, $B0, $A0, $80, $50, $A0, $A0
    DB      $A0, $50, $80, $A0, $B0, $20, $20, $30
    DB      $30, $20, $B0, $A0, $80, $50, $A0, $A0
    DB      $A0, $50, $80, $A0, $B0, $20, $20, $30
    DB      $30, $20, $B0, $A0, $80, $50, $A0, $A0
    DB      $A0, $50, $80, $A0, $B0, $20, $20, $30
    DB      $30, $20, $B0, $A0, $80, $50, $A0, $A0
    DB      $A0, $50, $80, $A0, $B0, $20, $20, $30
    DB      $30, $20, $B0, $A0, $80, $50, $A0, $A0
    DB      $A0, $50, $80, $A0, $B0, $20, $20, $30
    DB      $30, $20, $B0, $A0, $80, $50, $A0, $A0
    DB      $A0, $50, $80, $A0, $B0, $20, $20, $30
    DB      $30, $20, $B0, $A0, $80, $50, $A0, $A0
    DB      $A0, $50, $80, $A0, $B0, $20, $20, $30
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $B0, $F0, $F0, $70, $B0, $F0, $F0, $70
    DB      $B0, $F0, $F0, $70, $B0, $F0, $F0, $70
    DB      $B0, $F0, $F0, $70, $B0, $F0, $F0, $70
    DB      $B0, $F0, $F0, $70, $B0, $F0, $F0, $70
    DB      $70, $F0, $F0, $70, $70, $F0, $F0, $70
    DB      $70, $F0, $F0, $70, $70, $F0, $F0, $70
    DB      $70, $F0, $F0, $70, $70, $F0, $F0, $70
    DB      $70, $F0, $F0, $70, $70, $F0, $F0, $70
    DB      $30, $F0, $F0, $70, $30, $F0, $F0, $70
    DB      $30, $F0, $F0, $70, $30, $F0, $F0, $70
    DB      $30, $F0, $F0, $70, $30, $F0, $F0, $70
    DB      $30, $F0, $F0, $70, $30, $F0, $F0, $70
    DB      $F0, $F0, $F0, $70, $F0, $F0, $F0, $70
    DB      $F0, $F0, $F0, $70, $F0, $F0, $F0, $70
    DB      $F0, $F0, $F0, $70, $F0, $F0, $F0, $70
    DB      $F0, $F0, $F0, $70, $F0, $F0, $F0, $70
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0
    DB      $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0
    DB      $D0, $F0, $A0, $A0, $A0, $A0, $D0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $D0, $F0, $A0, $A0, $A0, $A0, $D0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $D0, $F0, $A0, $A0, $A0, $A0, $D0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $D0, $F0, $A0, $A0, $A0, $A0, $D0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $D0, $F0, $A0, $A0, $A0, $A0, $D0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $D0, $F0, $A0, $A0, $A0, $A0, $D0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $D0, $F0, $A0, $A0, $A0, $A0, $D0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $D0, $F0, $A0, $A0, $A0, $A0, $D0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $D0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $D0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $D0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $D0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $D0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $D0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $D0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $D0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
    DB      $A0, $A0, $A0, $A0, $A0, $A0, $A0, $F0
    DB      $F0, $F0, $80, $80, $F0, $F0, $F0, $F0
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
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
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
    DB      $00, $00, $06, $01, $0E, $C2, $CD, $D9
    DB      $1F, $C3, $0E, $42

START:
    LD      SP, $7020                       ; SP = $7020 (game stack base)
    CALL    SUB_90F4                        ; VDP register init
    CALL    DELAY_LOOP_9132                 ; clear JOYSTICK_BUFFER area, set defaults
    CALL    DELAY_LOOP_9150                 ; init free-task linked list at $7030
    LD      B, $03                          ; B = 3 (sound init parameter)
    LD      HL, $AAC8                       ; HL -> sound data at $AAC8
    CALL    SOUND_INIT                      ; initialise SN76489A sound engine
    CALL    SUB_92C7                        ; load tile pattern data into VRAM
    LD      HL, BOOT_UP                     ; HL = BOOT_UP ($0000)  -- null task sentinel
    LD      ($7050), HL                     ; $7050 = BOOT_UP (task list head = null)
    LD      HL, $7050                       ; HL = $7050 (addr of task list head)
    LD      ($7052), HL                     ; $7052 = $7050 (dispatch ptr = task list head)
    LD      HL, $95C9                       ; HL = $95C9 (first task entry point)
    LD      A, $03                          ; A = 3 (task parameter)
    CALL    SUB_91E8                        ; enqueue task at $95C9 with param=3
    XOR     A                               ; A = 0
    LD      ($7056), A                      ; $7056 = 0 (reset frame counter)
    LD      A, $01                          ; A = 1
    LD      ($739A), A                      ; $739A = 1 (frame sync target = 1 frame ahead)
    LD      HL, $0033                       ; HL = $0033 (score table initial value)
    LD      (CONTROLLER_BUFFER), HL         ; CONTROLLER_BUFFER ($702B) = $0033
    LD      B, $01                          ; B = 1 (VDP register number)
    LD      C, $E2                          ; C = $E2 (enable display, 16KB VRAM, sprites 8x8)
    CALL    WRITE_REGISTER                  ; write VDP register 1 = $E2 (enable display)
    JP      LOC_956D                        ; enter main game loop

SUB_90F4:
    LD      B, $00                          ; B = 0 (VDP reg 0)
    LD      C, $02                          ; C = $02 (mode 2 graphics)
    CALL    WRITE_REGISTER                  ; VDP reg 0 = $02 (graphics mode II)
    LD      B, $01                          ; B = 1 (VDP reg 1)
    LD      C, $C2                          ; C = $C2 (display off, 16KB, 8x8 sprites)
    CALL    WRITE_REGISTER                  ; VDP reg 1 = $C2 (display disabled during init)
    LD      B, $07                          ; B = 7 (VDP reg 7  -- border/text colour)
    LD      C, $01                          ; C = $01 (black border)
    CALL    WRITE_REGISTER                  ; VDP reg 7 = $01 (black border colour)
    LD      A, $00                          ; A = 0 (INIT_TABLE slot 0)
    LD      HL, $1C00                       ; HL = $1C00 (colour table VRAM base)
    CALL    INIT_TABLE                      ; init colour table at $1C00
    LD      A, $01                          ; A = 1 (INIT_TABLE slot 1)
    LD      HL, $3800                       ; HL = $3800 (sprite pattern table)
    CALL    INIT_TABLE                      ; init sprite pattern table at $3800
    LD      A, $02                          ; A = 2 (INIT_TABLE slot 2)
    LD      HL, $1800                       ; HL = $1800 (name table base)
    CALL    INIT_TABLE                      ; init name table at $1800
    LD      A, $03                          ; A = 3 (INIT_TABLE slot 3)
    LD      HL, BOOT_UP                     ; HL = BOOT_UP ($0000)  -- null pointer
    CALL    INIT_TABLE                      ; init sprite attribute table
    LD      A, $04                          ; A = 4 (INIT_TABLE slot 4)
    LD      HL, $2000                       ; HL = $2000 (pattern generator table)
    CALL    INIT_TABLE                      ; init pattern generator at $2000
    RET                                     ; return

DELAY_LOOP_9132:
    LD      HL, JOYSTICK_BUFFER             ; HL -> JOYSTICK_BUFFER ($7057)
    LD      A, $00                          ; A = $00 (fill value)
    LD      B, $0C                          ; B = 12 (byte count)

LOC_9139:
    LD      (HL), A                         ; (HL) = 0 (clear one byte)
    INC     HL                              ; HL++ (advance pointer)
    DJNZ    LOC_9139                        ; loop 12 times (clear 12 bytes at $7057+)
    LD      A, $9F                          ; A = $9F (all buttons released)
    LD      (JOYSTICK_BUFFER), A            ; JOYSTICK_BUFFER = $9F (BIOS default)
    LD      A, $9F                          ; A = $9F
    LD      ($7058), A                      ; $7058 = $9F (joystick mirror = released)
    LD      A, $0F                          ; A = $0F (sprite colour: white)
    LD      ($705D), A                      ; $705D = $0F (sprite colour attribute)
    LD      ($7062), A                      ; $7062 = $0F (sprite colour attribute 2)
    RET                                     ; return

DELAY_LOOP_9150:
    LD      DE, $000A                       ; DE = 10 (TCB slot size in bytes)
    LD      IX, $7030                       ; IX = $7030 (first TCB slot)
    LD      HL, $7030                       ; HL = $7030 (start of TCB pool)
    LD      ($704E), HL                     ; $704E = $7030 (free-list head = first slot)
    LD      B, $02                          ; B = 2 (number of TCB slots)

LOC_915F:
    ADD     HL, DE                          ; HL += 10 (HL -> next slot)
    LD      (IX+0), L                       ; (IX+0) = L (next-ptr low byte)
    LD      (IX+1), H                       ; (IX+1) = H (next-ptr high byte)
    ADD     IX, DE                          ; IX += 10 (IX -> next slot)
    DJNZ    LOC_915F                        ; loop for all 2 slots
    LD      (IX+0), $00                     ; (IX+0) = 0 (null-terminate last slot)
    LD      (IX+1), $00                     ; (IX+1) = 0
    RET                                     ; return
    DB      $79, $D3, $BF, $78, $C6, $80, $D3, $BF
    DB      $C9, $DD, $2A, $52, $70, $FD, $2A, $54
    DB      $70, $DD, $7E, $00, $FD, $77, $00, $DD
    DB      $7E, $01, $FD, $77, $01, $2A, $4E, $70
    DB      $DD, $22, $4E, $70, $DD, $75, $00, $DD
    DB      $74, $01, $DD, $2A, $54, $70, $C3, $AF
    DB      $95, $ED, $5B, $52, $70, $DD, $21, $50
    DB      $70, $DD, $6E, $00, $DD, $66, $01, $7C
    DB      $B5, $C8, $E5, $FD, $E1, $7C, $BA, $20
    DB      $04, $7D, $BB, $28, $22, $FD, $7E, $05
    DB      $FE, $01, $28, $1B, $FD, $7E, $00, $DD
    DB      $77, $00, $FD, $7E, $01, $DD, $77, $01
    DB      $2A, $4E, $70, $FD, $22, $4E, $70, $FD
    DB      $75, $00, $FD, $74, $01, $18, $CA, $FD
    DB      $E5, $DD, $E1, $18, $C4

; ---- TASK SCHEDULER ----
; SUB_91E8 -- enqueue task into cooperative scheduler.
; On entry: IY=TCB slot, HL=code ptr, A=param. Links slot into $7030 list.
; TCB layout: +0,+1=next ptr  +2,+3=code ptr  +4=timer  +5=param  +6=flags
SUB_91E8:
    EX      AF, AF'                         ; swap to alt AF (save task param A)
    LD      DE, ($704E)                     ; DE = $704E contents (free-list head ptr)
    LD      A, D                            ; A = D
    OR      E                               ; A |= E (test if DE == 0)
    JR      Z, LOC_9229                     ; jump if no free slot (Z=1 -> DE was null)
    PUSH    DE                              ; PUSH DE (save free-slot address)
    POP     IY                              ; POP IY (IY = free TCB slot ptr)
    XOR     A                               ; A = 0
    SET     0, A                            ; set bit 0 of A (active flag = 1)
    LD      (IY+6), A                       ; (IY+6) = A (mark TCB slot as active)
    LD      (IY+2), L                       ; (IY+2) = L (code ptr low byte)
    LD      (IY+3), H                       ; (IY+3) = H (code ptr high byte)
    LD      (IY+4), $01                     ; (IY+4) = 1 (timer = 1, expires next frame)
    LD      L, (IY+0)                       ; L = (IY+0) (next free-slot ptr low)
    LD      H, (IY+1)                       ; H = (IY+1) (next free-slot ptr high)
    LD      ($704E), HL                     ; $704E = HL (advance free-list head)
    LD      IX, ($7052)                     ; IX = $7052 (task dispatch current ptr)
    LD      A, (IX+0)                       ; A = (IX+0) (save IX next-ptr low)
    LD      (IX+0), E                       ; (IX+0) = E (splice IY into list  -- low byte)
    LD      (IY+0), A                       ; (IY+0) = A (IY's next = old IX next  -- low)
    LD      A, (IX+1)                       ; A = (IX+1) (save IX next-ptr high)
    LD      (IX+1), D                       ; (IX+1) = D (splice IY into list  -- high byte)
    LD      (IY+1), A                       ; (IY+1) = A (IY's next = old IX next  -- high)
    EX      AF, AF'                         ; EX AF,AF' (restore task param into A)
    LD      (IY+5), A                       ; (IY+5) = A (store param in TCB)
    OR      A                               ; OR A (test A, clear carry)
    RET                                     ; return (carry=0 = success)

LOC_9229:
    SCF                                     ; set carry flag (error: no free slot)
    RET                                     ; return (carry=1 = failure)
    DB      $F5, $CD, $3F, $92, $6F, $26, $00, $D1
    DB      $06, $08, $29, $7C, $92, $38, $01, $67
    DB      $10, $F8, $7C, $C9

SUB_923F:
    CALL    SUB_925E                        ; advance digit ptr, get next BCD byte -> A
    LD      H, A                            ; H = A (digit byte)
    LD      A, ($702F)                      ; A = $702F (score accumulator)
    ADD     A, H                            ; A += H (add digit to accumulator)
    LD      ($702F), A                      ; $702F = A (update score accumulator)
    LD      HL, (CONTROLLER_BUFFER)         ; HL = CONTROLLER_BUFFER ($702B) contents
    DEC     HL                              ; HL-- (walk back one entry in score table)
    LD      (CONTROLLER_BUFFER), HL         ; CONTROLLER_BUFFER = HL
    LD      A, H                            ; A = H
    CP      $01                             ; compare H to 1 (table exhausted?)
    JR      C, LOC_927A                     ; jump to score-modulo adjust if H < 1
    LD      A, ($702F)                      ; A = $702F (accumulator)
    ADD     A, (HL)                         ; A += (HL) (add table value at current ptr)
    LD      ($702F), A                      ; $702F = A
    RET                                     ; return

SUB_925E:
    LD      HL, ($702D)                     ; HL = $702D (score digit pointer)
    INC     HL                              ; HL++ (advance digit pointer)
    LD      ($702D), HL                     ; $702D = HL (store updated pointer)
    LD      A, H                            ; A = H (high byte of pointer)
    CP      $11                             ; compare H to $11 (past end of table?)
    JR      NC, LOC_9272                    ; jump to wrap if H >= $11
    LD      A, ($702F)                      ; A = $702F (score accumulator)
    ADD     A, (HL)                         ; A += (HL) (add digit value at new ptr)
    LD      ($702F), A                      ; $702F = A
    RET                                     ; return

LOC_9272:
    LD      HL, $0100                       ; HL = $0100 (table start address)
    LD      ($702D), HL                     ; $702D = $0100 (reset digit pointer to start)
    JR      SUB_925E                        ; restart digit increment from beginning

LOC_927A:
    LD      A, ($7385)                      ; A = $7385 (NMI 60-frame timer)
    ADD     A, C                            ; A += C (add C to timer byte)

LOC_927E:
    SUB     $07                             ; A -= 7
    CP      $07                             ; compare A to 7
    JR      NC, LOC_927E                    ; loop while A >= 7 (A = A mod 7)
    ADD     A, $02                          ; A += 2 (bias: minimum column = 2)
    LD      H, A                            ; H = A (new score-table column index)
    LD      (CONTROLLER_BUFFER), HL         ; CONTROLLER_BUFFER = HL (store adjusted column)
    JR      SUB_923F                        ; restart score update with new pointer
    DB      $DB, $BF, $3A, $56, $70, $47, $7B, $D3
    DB      $BF, $7A, $C6, $40, $D3, $BF, $3A, $56
    DB      $70, $B8, $20, $EC, $06, $08, $7E, $23
    DB      $D3, $BE, $10, $FA, $C9, $DB, $BF, $3A
    DB      $56, $70, $4F, $7B, $D3, $BF, $7A, $C6
    DB      $40, $D3, $BF, $3A, $56, $70, $B9, $20
    DB      $EC, $0E, $BE, $ED, $A3, $00, $00, $C2
    DB      $BF, $92, $C9

SUB_92C7:
    LD      A, $03                          ; A = 3 (PUT_VRAM type: ROM->VRAM block copy)
    LD      DE, BOOT_UP                     ; DE = BOOT_UP ($0000)  -- VRAM destination offset 0
    LD      HL, $8024                       ; HL = $8024 (source: ROM tile data in header)
    LD      IY, $0100                       ; IY = $0100 (256 bytes to copy)
    CALL    SUB_93D9                        ; copy 256 bytes from $8024 -> VRAM bank 0
    LD      A, $03                          ; A = 3
    LD      DE, $0041                       ; DE = $0041 (VRAM offset $41)
    LD      HL, $9331                       ; HL = $9331 (source: ASCII-like tile data)
    LD      IY, $0014                       ; IY = $0014 (20 bytes)
    CALL    SUB_93D9                        ; copy 20 bytes from $9331 -> VRAM $0041
    LD      A, $03                          ; A = 3
    LD      DE, $0100                       ; DE = $0100 (VRAM page 1 base)
    LD      HL, $8024                       ; HL = $8024 (same ROM source)
    LD      IY, $0100                       ; IY = $0100 (256 bytes)
    CALL    SUB_93D9                        ; copy 256 bytes to VRAM page 1
    LD      A, $03                          ; A = 3
    LD      DE, $0200                       ; DE = $0200 (VRAM page 2 base)
    LD      HL, $8024                       ; HL = $8024
    LD      IY, $0100                       ; IY = $0100
    CALL    SUB_93D9                        ; copy 256 bytes to VRAM page 2
    LD      A, $04                          ; A = 4 (colour table write)
    LD      DE, BOOT_UP                     ; DE = BOOT_UP ($0000)  -- colour table offset 0
    LD      HL, $8824                       ; HL = $8824 (ROM colour data)
    LD      IY, $0100                       ; IY = $0100
    CALL    SUB_93D9                        ; copy 256 colour bytes from $8824 -> VRAM
    LD      A, $04                          ; A = 4
    LD      DE, $0100                       ; DE = $0100
    LD      HL, $8824                       ; HL = $8824
    LD      IY, $0100                       ; IY = $0100
    CALL    SUB_93D9                        ; copy 256 colour bytes to colour page 1
    LD      A, $04                          ; A = 4
    LD      DE, $0200                       ; DE = $0200
    LD      HL, $8824                       ; HL = $8824
    LD      IY, $0100                       ; IY = $0100
    CALL    SUB_93D9                        ; copy 256 colour bytes to colour page 2
    RET                                     ; return
    DB      $00, $00, $00, $00, $00, $3D, $FF, $C7
    DB      $C7, $E7, $F7, $F7, $62, $00, $00, $00
    DB      $00, $00, $01, $00, $00, $F0, $F9, $19
    DB      $19, $39, $79, $79, $30, $00, $00, $00
    DB      $00, $80, $C0, $80, $00, $87, $CC, $CC
    DB      $CC, $CC, $CC, $CC, $87, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $C3, $E7, $47
    DB      $07, $07, $47, $E7, $C2, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $C1, $23, $73
    DB      $63, $03, $03, $03, $01, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $F0, $98, $98
    DB      $98, $98, $98, $98, $F0, $00, $00, $00
    DB      $1C, $3E, $67, $62, $60, $7C, $70, $70
    DB      $70, $70, $70, $70, $20, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $42, $E7, $E7
    DB      $E7, $E3, $E3, $F6, $7C, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $1F, $31, $33
    DB      $3B, $3B, $3B, $3B, $11, $00, $00, $00
    DB      $00, $00, $00, $75, $27, $25, $25, $80
    DB      $80, $80, $80, $80, $00, $00, $00, $00
    DB      $DD, $E5, $CD, $BB, $1F, $DD, $E1, $C9

SUB_93D9:
    PUSH    IX                              ; save IX (caller's IX register)
    CALL    PUT_VRAM                        ; PUT_VRAM (write ROM data to VRAM via BIOS)
    POP     IX                              ; restore IX
    RET                                     ; return
    DB      $47, $FE, $C8, $38, $0A, $D6, $C8, $47
    DB      $3E, $32, $CD, $45, $94, $18, $13, $FE
    DB      $64, $38, $0A, $D6, $64, $47, $3E, $31
    DB      $CD, $45, $94, $18, $05, $3E, $30, $CD
    DB      $45, $94, $48, $06, $00, $E5, $21, $09
    DB      $95, $09, $7E, $E1, $F5, $CB, $3F, $CB
    DB      $3F, $CB, $3F, $CB, $3F, $C6, $30, $CD
    DB      $45, $94, $F1, $E6, $0F, $C6, $30, $CD
    DB      $45, $94, $C9, $4F, $06, $00, $E5, $21
    DB      $09, $95, $09, $7E, $E1, $F5, $CB, $3F
    DB      $CB, $3F, $CB, $3F, $CB, $3F, $C6, $30
    DB      $CD, $45, $94, $F1, $E6, $0F, $C6, $30
    DB      $CD, $45, $94, $C9, $4F, $3A, $56, $70
    DB      $57, $DB, $BF, $00, $00, $00, $00, $7D
    DB      $D3, $BF, $7C, $F6, $40, $00, $00, $D3
    DB      $BF, $3A, $56, $70, $BA, $20, $E6, $79
    DB      $D3, $BE, $23, $C9, $CD, $A8, $94, $21
    DB      $8C, $73, $7E, $23, $6E, $67, $EB, $2A
    DB      $89, $73, $7A, $BC, $D8, $7B, $BD, $D8
    DB      $3A, $8B, $73, $FE, $09, $CA, $8C, $94
    DB      $C6, $01, $27, $32, $8B, $73, $3E, $0F
    DB      $32, $99, $73, $2A, $89, $73, $1E, $05
    DB      $16, $00, $7D, $83, $27, $6F, $7C, $8A
    DB      $27, $67, $22, $89, $73, $3A, $8B, $73
    DB      $21, $16, $18, $CD, $24, $94, $C9, $1E
    DB      $04, $21, $8F, $73, $CB, $38, $08, $04
    DB      $2B, $1D, $10, $FC, $08, $30, $08, $CB
    DB      $21, $CB, $21, $CB, $21, $CB, $21, $79
    DB      $86, $27, $77, $D0, $2B, $1D, $C8, $0E
    DB      $01, $18, $F4, $21, $0F, $18, $3A, $56
    DB      $70, $57, $DB, $BF, $7D, $D3, $BF, $7C
    DB      $F6, $40, $00, $00, $D3, $BF, $3A, $56
    DB      $70, $BA, $20, $EA, $3A, $8C, $73, $CD
    DB      $F4, $94, $3A, $8D, $73, $CD, $F4, $94
    DB      $3A, $8E, $73, $F5, $CB, $3F, $CB, $3F
    DB      $CB, $3F, $CB, $3F, $C6, $30, $D3, $BE
    DB      $F1, $E6, $0F, $C6, $30, $D3, $BE, $C9
    DB      $00, $01, $02, $03, $04, $05, $06, $07
    DB      $08, $09, $10, $11, $12, $13, $14, $15
    DB      $16, $17, $18, $19, $20, $21, $22, $23
    DB      $24, $25, $26, $27, $28, $29, $30, $31 ; "$%&'()01"
    DB      $32, $33, $34, $35, $36, $37, $38, $39 ; "23456789"
    DB      $40, $41, $42, $43, $44, $45, $46, $47 ; "@ABCDEFG"
    DB      $48, $49, $50, $51, $52, $53, $54, $55 ; "HIPQRSTU"
    DB      $56, $57, $58, $59, $60, $61, $62, $63 ; "VWXY`abc"
    DB      $64, $65, $66, $67, $68, $69, $70, $71 ; "defghipq"
    DB      $72, $73, $74, $75, $76, $77, $78, $79 ; "rstuvwxy"
    DB      $80, $81, $82, $83, $84, $85, $86, $87
    DB      $88, $89, $90, $91, $92, $93, $94, $95
    DB      $96, $97, $98, $99

; ---- MAIN GAME LOOP ----
; Wait until frame counter $7056 reaches sync target $739A.
; Then update score and walk task list, executing expired timers.
LOC_956D:
    LD      SP, $7020                       ; reset stack pointer to $7020 (top of game stack)
    LD      HL, $739A                       ; HL = $739A (frame sync target address)
    LD      A, ($7056)                      ; A = frame counter ($7056)
    CP      (HL)                            ; compare frame counter to sync target
    JR      C, LOC_956D                     ; wait here until frame counter >= sync target
    LD      A, $00                          ; A = 0
    LD      ($7056), A                      ; $7056 = 0 (clear frame counter after sync)
    CALL    SUB_923F                        ; score update (advance digit ptr, accumulate)
    JP      LOC_9584                        ; start task dispatch

LOC_9584:
    LD      IX, $7050                       ; IX = $7050 (task list head)
    LD      ($7052), IX                     ; $7052 = IX (save as dispatch current ptr)
    JR      LOC_95AF                        ; begin task execution loop

LOC_958E:
    LD      ($7052), IX                     ; $7052 = IX (record current task ptr)
    BIT     0, (IX+6)                       ; test bit 0 of (IX+6) (active flag)
    DEC     (IX+4)                          ; DEC (IX+4) (decrement task timer)
    JR      NZ, LOC_95AF                    ; skip execution if timer not yet zero
    LD      L, (IX+2)                       ; L = (IX+2) (load task code ptr low byte)
    LD      H, (IX+3)                       ; H = (IX+3) (load task code ptr high byte)
    JP      (HL)                            ; JP (HL) (dispatch to task handler)
    DB      $DD, $2A, $52, $70, $DD, $77, $04, $DD
    DB      $75, $02, $DD, $74, $03

LOC_95AF:
    LD      ($7054), IX                     ; $7054 = IX (save current task frame ptr)
    LD      L, (IX+0)                       ; L = (IX+0) (next task ptr low)
    LD      H, (IX+1)                       ; H = (IX+1) (next task ptr high)
    LD      SP, $7020                       ; SP = $7020 (reset stack for task execution)
    PUSH    HL                              ; PUSH HL (move HL -> stack for POP IX)
    POP     IX                              ; POP IX (IX = next task TCB ptr)
    LD      A, H                            ; A = H
    OR      L                               ; A |= L (test if next ptr is null)
    JR      NZ, LOC_958E                    ; if not null, execute next task
    JP      LOC_956D                        ; all tasks done  -- restart main loop
    DB      $E1, $18, $D9, $3E, $01, $32, $AF, $73
    DB      $06, $02, $C5, $3E, $00, $32, $8C, $73
    DB      $32, $8D, $73, $32, $8E, $73, $32, $8F
    DB      $73, $32, $90, $73, $32, $91, $73, $CD
    DB      $88, $A2, $C1, $10, $E5, $CD, $58, $9F
    DB      $11, $41, $1A, $21, $F8, $95, $06, $16
    DB      $18, $16, $20, $20, $20, $20, $20, $20
    DB      $20, $20, $20, $4C, $49, $43, $45, $4E ; "   LICEN"
    DB      $53, $45, $44, $20, $42, $59, $20, $20 ; "SED BY  "
    DB      $CD, $A9, $92, $11, $A1, $1A, $21, $BA
    DB      $9F, $06, $1E, $C3, $35, $96, $37, $20
    DB      $46, $49, $52, $53, $54, $20, $53, $54 ; "FIRST ST"
    DB      $41, $52, $20, $53, $4F, $46, $54, $57 ; "AR SOFTW"
    DB      $41, $52, $45, $20, $49, $4E, $43, $CD
    DB      $A9, $92, $11, $61, $1A, $21, $42, $96
    DB      $06, $17, $18, $17, $20, $20, $20, $20
    DB      $20, $20, $20, $20, $54, $45, $4C, $45 ; "    TELE"
    DB      $47, $41, $4D, $45, $53, $20, $55, $53 ; "GAMES US"
    DB      $41, $20, $20, $CD, $A9, $92, $11, $E1
    DB      $1A, $21, $66, $96, $06, $17, $18, $17
    DB      $20, $20, $20, $20, $20, $20, $20, $50 ; "       P"
    DB      $52, $45, $53, $53, $20, $23, $20, $54 ; "RESS # T"
    DB      $4F, $20, $53, $54, $41, $52, $54, $CD
    DB      $A9, $92, $3A, $5D, $70, $FE, $0B, $CA
    DB      $0B, $97, $21, $EF, $A2, $11, $70, $21
    DB      $CD, $8C, $92, $21, $EF, $A2, $11, $70
    DB      $29, $CD, $8C, $92, $21, $EF, $A2, $11
    DB      $70, $31, $CD, $8C, $92, $3E, $01, $CD
    DB      $C6, $95, $21, $F7, $A2, $11, $70, $21
    DB      $CD, $8C, $92, $21, $F7, $A2, $11, $70
    DB      $29, $CD, $8C, $92, $21, $F7, $A2, $11
    DB      $70, $31, $CD, $8C, $92, $3E, $01, $CD
    DB      $C6, $95, $21, $FF, $A2, $11, $70, $21
    DB      $CD, $8C, $92, $21, $FF, $A2, $11, $70
    DB      $29, $CD, $8C, $92, $21, $FF, $A2, $11
    DB      $70, $31, $CD, $8C, $92, $3E, $01, $CD
    DB      $C6, $95, $21, $07, $A3, $11, $70, $21
    DB      $CD, $8C, $92, $21, $07, $A3, $11, $70
    DB      $29, $CD, $8C, $92, $21, $07, $A3, $11
    DB      $70, $31, $CD, $8C, $92, $3E, $01, $21
    DB      $80, $96, $C3, $A2, $95, $CD, $58, $9F
    DB      $3E, $01, $32, $AF, $73, $11, $21, $1A
    DB      $21, $1D, $97, $06, $1B, $18, $1B, $20
    DB      $20, $20, $20, $50, $52, $4F, $47, $52 ; "   PROGR"
    DB      $41, $4D, $20, $42, $59, $20, $43, $48 ; "AM BY CH"
    DB      $52, $49, $53, $20, $4F, $42, $45, $52 ; "RIS OBER"
    DB      $54, $48, $CD, $A9, $92, $11, $41, $1A
    DB      $21, $45, $97, $06, $1D, $18, $1D, $20
    DB      $50, $4C, $41, $59, $45, $52, $20, $31 ; "PLAYER 1"
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $50, $4C, $41, $59 ; "    PLAY"
    DB      $45, $52, $20, $32, $CD, $A9, $92, $11
    DB      $61, $1A, $21, $6F, $97, $06, $1C, $18
    DB      $1C, $20, $20, $30, $30, $30, $30, $30
    DB      $30, $20, $20, $4C, $41, $53, $54, $20 ; "0  LAST "
    DB      $53, $43, $4F, $52, $45, $20, $20, $30 ; "SCORE  0"
    DB      $30, $30, $30, $30, $30, $CD, $A9, $92
    DB      $11, $81, $1A, $21, $98, $97, $06, $1C
    DB      $18, $1C, $20, $20, $30, $30, $30, $30
    DB      $30, $30, $20, $20, $48, $49, $47, $48 ; "00  HIGH"
    DB      $20, $53, $43, $4F, $52, $45, $20, $20 ; " SCORE  "
    DB      $30, $30, $30, $30, $30, $30, $CD, $A9
    DB      $92, $21, $63, $1A, $CD, $CF, $94, $21
    DB      $83, $1A, $3A, $8F, $73, $32, $8C, $73
    DB      $ED, $4B, $90, $73, $ED, $43, $8D, $73
    DB      $CD, $CF, $94, $CD, $88, $A2, $21, $77
    DB      $1A, $CD, $CF, $94, $21, $97, $1A, $3A
    DB      $8F, $73, $32, $8C, $73, $ED, $4B, $90
    DB      $73, $ED, $43, $8D, $73, $CD, $CF, $94
    DB      $CD, $88, $A2, $11, $A1, $1A, $21, $FB
    DB      $97, $06, $1E, $18, $1E, $20, $42, $59
    DB      $20, $50, $45, $54, $45, $52, $20, $4C ; " PETER L"
    DB      $49, $45, $50, $41, $20, $41, $4E, $44 ; "IEPA AND"
    DB      $20, $43, $48, $52, $49, $53, $20, $47 ; " CHRIS G"
    DB      $52, $41, $59, $CD, $A9, $92, $11, $C1
    DB      $1A, $21, $26, $98, $06, $1A, $18, $1A
    DB      $20, $20, $20, $20, $20, $50, $52, $45 ; "     PRE"
    DB      $53, $53, $20, $31, $20, $4F, $52, $20 ; "SS 1 OR "
    DB      $32, $20, $54, $4F, $20, $53, $54, $41 ; "2 TO STA"
    DB      $52, $54, $CD, $A9, $92, $11, $E1, $1A
    DB      $21, $4D, $98, $06, $16, $18, $16, $20
    DB      $20, $20, $20, $20, $20, $43, $41, $56 ; "     CAV"
    DB      $45, $3A, $20, $20, $20, $20, $20, $4C ; "E:     L"
    DB      $45, $56, $45, $4C, $3A, $CD, $A9, $92
    DB      $3E, $01, $32, $87, $73, $32, $88, $73
    DB      $21, $5A, $70, $CB, $5E, $CA, $8B, $98
    DB      $3A, $87, $73, $FE, $01, $CA, $8B, $98
    DB      $D6, $05, $32, $87, $73, $3E, $14, $CD
    DB      $48, $AA, $C3, $E6, $98, $CB, $4E, $CA
    DB      $AD, $98, $3A, $88, $73, $FE, $04, $D2
    DB      $AD, $98, $3A, $87, $73, $FE, $10, $CA
    DB      $AD, $98, $C6, $05, $32, $87, $73, $3E
    DB      $14, $CD, $48, $AA, $C3, $E6, $98, $CB
    DB      $56, $CA, $C6, $98, $3A, $88, $73, $FE
    DB      $01, $CA, $C6, $98, $3D, $32, $88, $73
    DB      $3E, $14, $CD, $48, $AA, $C3, $E6, $98
    DB      $CB, $46, $CA, $E6, $98, $3A, $88, $73
    DB      $FE, $05, $CA, $E6, $98, $3C, $32, $88
    DB      $73, $FE, $04, $DA, $E1, $98, $3E, $01
    DB      $32, $87, $73, $3E, $14, $CD, $48, $AA
    DB      $3A, $87, $73, $21, $EC, $1A, $CD, $24
    DB      $94, $3A, $88, $73, $21, $F7, $1A, $CD
    DB      $24, $94, $3A, $5D, $70, $FE, $01, $CA
    DB      $88, $99, $FE, $02, $CA, $88, $99, $21
    DB      $EF, $A2, $11, $70, $21, $CD, $8C, $92
    DB      $21, $EF, $A2, $11, $70, $29, $CD, $8C
    DB      $92, $21, $EF, $A2, $11, $70, $31, $CD
    DB      $8C, $92, $3E, $01, $CD, $C6, $95, $21
    DB      $F7, $A2, $11, $70, $21, $CD, $8C, $92
    DB      $21, $F7, $A2, $11, $70, $29, $CD, $8C
    DB      $92, $21, $F7, $A2, $11, $70, $31, $CD
    DB      $8C, $92, $3E, $01, $CD, $C6, $95, $21
    DB      $FF, $A2, $11, $70, $21, $CD, $8C, $92
    DB      $21, $FF, $A2, $11, $70, $29, $CD, $8C
    DB      $92, $21, $FF, $A2, $11, $70, $31, $CD
    DB      $8C, $92, $3E, $01, $CD, $C6, $95, $21
    DB      $07, $A3, $11, $70, $21, $CD, $8C, $92
    DB      $21, $07, $A3, $11, $70, $29, $CD, $8C
    DB      $92, $21, $07, $A3, $11, $70, $31, $CD
    DB      $8C, $92, $3E, $01, $21, $6E, $98, $C3
    DB      $A2, $95, $FE, $02, $3E, $01, $C2, $A3
    DB      $99, $3A, $87, $73, $32, $9B, $73, $3A
    DB      $88, $73, $32, $9C, $73, $CD, $88, $A2
    DB      $3E, $02, $32, $AF, $73, $32, $AE, $73
    DB      $3E, $00, $32, $63, $70, $32, $64, $70
    DB      $CD, $48, $AA, $06, $02, $C5, $3E, $00
    DB      $32, $8C, $73, $32, $8D, $73, $32, $8E
    DB      $73, $3E, $03, $32, $8B, $73, $21, $05
    DB      $00, $22, $89, $73, $CD, $88, $A2, $C1
    DB      $10, $E3, $11, $00, $00, $CD, $81, $B2
    DB      $11, $00, $08, $CD, $81, $B2, $11, $00
    DB      $10, $CD, $81, $B2, $3A, $AE, $73, $FE
    DB      $01, $CA, $68, $9A, $3A, $AF, $73, $3C
    DB      $FE, $03, $C2, $F5, $99, $3E, $01, $32
    DB      $AF, $73, $CD, $88, $A2, $3A, $8B, $73
    DB      $FE, $00, $C2, $1E, $9A, $3A, $9F, $73
    DB      $FE, $00, $C2, $D0, $99, $3A, $AF, $73
    DB      $FE, $01, $CA, $9A, $A2, $3E, $01, $32
    DB      $AF, $73, $CD, $88, $A2, $C3, $9A, $A2
    DB      $06, $01, $0E, $C2, $CD, $D9, $1F, $3E
    DB      $20, $11, $00, $03, $21, $00, $18, $CD
    DB      $82, $1F, $06, $01, $0E, $E2, $CD, $D9
    DB      $1F, $11, $68, $19, $21, $41, $9A, $06
    DB      $11, $18, $11, $3E, $3E, $3E, $20, $50
    DB      $4C, $41, $59, $45, $52, $20, $20, $20 ; "LAYER   "
    DB      $20, $3C, $3C, $3C, $CD, $A9, $92, $3A
    DB      $AF, $73, $21, $73, $19, $CD, $24, $94
    DB      $3E, $08, $32, $9A, $73, $3E, $0B, $CD
    DB      $C6, $95, $3A, $8B, $73, $FE, $00, $CA
    DB      $9A, $A2, $CD, $0E, $B3, $06, $01, $0E
    DB      $C2, $CD, $D9, $1F, $3E, $20, $11, $00
    DB      $03, $21, $00, $18, $CD, $82, $1F, $06
    DB      $01, $0E, $E2, $CD, $D9, $1F, $FD, $2A
    DB      $A6, $73, $3A, $24, $88, $FD, $86, $13
    DB      $21, $00, $20, $CD, $45, $94, $21, $25
    DB      $88, $01, $FF, $07, $CD, $C7, $A2, $C2
    DB      $A2, $9A, $21, $24, $88, $01, $00, $08
    DB      $CD, $C7, $A2, $C2, $AE, $9A, $21, $24
    DB      $88, $01, $00, $08, $CD, $C7, $A2, $C2
    DB      $BA, $9A, $11, $00, $18, $21, $CA, $9A
    DB      $06, $20, $18, $20, $20, $20, $20, $20
    DB      $2E, $20, $20, $20, $20, $20, $20, $20 ; ".       "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $CD, $A9, $92, $3A
    DB      $93, $73, $21, $02, $18, $CD, $24, $94
    DB      $3A, $94, $73, $21, $05, $18, $CD, $24
    DB      $94, $3E, $00, $32, $92, $73, $21, $08
    DB      $18, $CD, $24, $94, $FD, $2A, $A6, $73
    DB      $3A, $88, $73, $3D, $4F, $06, $00, $FD
    DB      $09, $FD, $7E, $0E, $21, $0B, $18, $CD
    DB      $E1, $93, $CD, $CC, $94, $3A, $8B, $73
    DB      $21, $16, $18, $CD, $24, $94, $3A, $87
    DB      $73, $21, $19, $18, $CD, $24, $94, $3A
    DB      $88, $73, $21, $1C, $18, $CD, $24, $94
    DB      $3E, $FF, $32, $96, $73, $32, $99, $73
    DB      $21, $C0, $B0, $3E, $03, $CD, $E8, $91
    DB      $3E, $05, $32, $9A, $73, $21, $8B, $70
    DB      $01, $F7, $02, $CB, $E6, $23, $0B, $78
    DB      $B1, $C2, $59, $9B, $DD, $36, $07, $1E
    DB      $DD, $36, $08, $37, $CD, $3F, $92, $E6
    DB      $03, $FE, $03, $CA, $6A, $9B, $47, $FE
    DB      $02, $CA, $80, $9B, $CD, $3F, $92, $C3
    DB      $8A, $9B, $CD, $3F, $92, $FE, $F7, $28
    DB      $03, $D2, $80, $9B, $4F, $21, $8B, $70
    DB      $09, $CB, $A6, $DD, $35, $08, $C2, $6A
    DB      $9B, $DD, $35, $07, $CA, $AF, $9B, $CD
    DB      $3F, $92, $E6, $07, $C6, $08, $CD, $48
    DB      $AA, $3E, $01, $21, $66, $9B, $C3, $A2
    DB      $95, $21, $8B, $70, $01, $F7, $02, $CB
    DB      $A6, $23, $0B, $78, $B1, $C2, $B5, $9B
    DB      $3E, $0A, $21, $88, $73, $96, $32, $9A
    DB      $73, $21, $E3, $B8, $3E, $03, $CD, $E8
    DB      $91, $3E, $12, $CD, $C6, $95, $3E, $01
    DB      $CD, $48, $AA, $2A, $AA, $73, $36, $2C
    DB      $3E, $04, $CD, $C6, $95, $2A, $AA, $73
    DB      $36, $2B, $3E, $00, $32, $85, $73, $FD
    DB      $2A, $A6, $73, $3A, $88, $73, $3D, $4F
    DB      $06, $00, $FD, $09, $FD, $7E, $0E, $32
    DB      $86, $73, $DD, $36, $09, $00, $3E, $0F
    DB      $32, $5D, $70, $3A, $5D, $70, $FE, $0A
    DB      $CA, $58, $9E, $FE, $0B, $CA, $3F, $9E
    DB      $FE, $00, $CC, $63, $9C, $3A, $86, $73
    DB      $DD, $BE, $09, $C4, $3F, $9C, $CD, $CC
    DB      $94, $3A, $9A, $73, $FE, $01, $CA, $50
    DB      $9D, $3A, $86, $73, $FE, $00, $CA, $DE
    DB      $9C, $3E, $01, $21, $09, $9C, $C3, $A2
    DB      $95, $21, $0B, $18, $CD, $E1, $93, $3A
    DB      $86, $73, $DD, $77, $09, $FE, $09, $28
    DB      $01, $D0, $D6, $02, $FE, $0A, $DA, $59
    DB      $9C, $3E, $00, $47, $3E, $07, $90, $C6
    DB      $08, $CD, $48, $AA, $C9, $11, $C0, $1A
    DB      $21, $6D, $9C, $06, $20, $18, $20, $20
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $CD
    DB      $A9, $92, $11, $E0, $1A, $21, $9A, $9C
    DB      $06, $20, $18, $20, $20, $20, $20, $20
    DB      $3E, $3E, $3E, $20, $50, $52, $45, $53 ; ">>> PRES"
    DB      $53, $20, $38, $20, $54, $4F, $20, $52 ; "S 8 TO R"
    DB      $45, $53, $55, $4D, $45, $20, $3C, $3C ; "ESUME <<"
    DB      $3C, $20, $20, $20, $CD, $A9, $92, $3A
    DB      $96, $73, $47, $3A, $85, $73, $4F, $3A
    DB      $86, $73, $67, $3A, $5D, $70, $FE, $08
    DB      $C2, $C9, $9C, $78, $32, $96, $73, $79
    DB      $32, $85, $73, $7C, $32, $86, $73, $C9
    DB      $CD, $A4, $91, $11, $C0, $1A, $21, $EB
    DB      $9C, $06, $20, $18, $20, $20, $20, $20
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $CD, $A9, $92
    DB      $11, $E0, $1A, $21, $18, $9D, $06, $20
    DB      $18, $20, $20, $20, $20, $20, $20, $20
    DB      $3E, $3E, $3E, $20, $4F, $55, $54, $20 ; ">>> OUT "
    DB      $4F, $46, $20, $54, $49, $4D, $45, $20 ; "OF TIME "
    DB      $3C, $3C, $3C, $20, $20, $20, $20, $20 ; "<<<     "
    DB      $20, $20, $CD, $A9, $92, $3E, $00, $CD
    DB      $48, $AA, $3A, $5D, $70, $FE, $0A, $CA
    DB      $5B, $9E, $3E, $01, $21, $40, $9D, $C3
    DB      $A2, $95, $3E, $02, $32, $9A, $73, $3E
    DB      $00, $CD, $48, $AA, $3A, $86, $73, $FE
    DB      $00, $CA, $91, $9D, $32, $89, $70, $3E
    DB      $13, $CD, $48, $AA, $06, $00, $3A, $88
    DB      $73, $4F, $CD, $65, $94, $CD, $CC, $94
    DB      $3A, $89, $70, $3D, $21, $0B, $18, $CD
    DB      $E1, $93, $3E, $01, $CD, $C6, $95, $21
    DB      $89, $70, $35, $C2, $6A, $9D, $3E, $00
    DB      $CD, $48, $AA, $2A, $A6, $73, $2B, $7E
    DB      $FE, $01, $C2, $0F, $9E, $3A, $8B, $73
    DB      $FE, $09, $CA, $0F, $9E, $3C, $32, $8B
    DB      $73, $CD, $A4, $91, $11, $C0, $1A, $21
    DB      $B4, $9D, $06, $20, $18, $20, $20, $20
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $CD, $A9
    DB      $92, $11, $E0, $1A, $21, $E1, $9D, $06
    DB      $20, $18, $20, $20, $20, $20, $20, $20
    DB      $20, $20, $3E, $3E, $3E, $20, $42, $4F ; "  >>> BO"
    DB      $4E, $55, $53, $20, $4C, $49, $46, $45 ; "NUS LIFE"
    DB      $20, $3C, $3C, $3C, $20, $20, $20, $20 ; " <<<    "
    DB      $20, $20, $20, $CD, $A9, $92, $3E, $3C
    DB      $CD, $C6, $95, $CD, $E3, $9E, $C3, $1A
    DB      $9E, $3E, $14, $CD, $C6, $95, $CD, $A4
    DB      $91, $CD, $E3, $9E, $3A, $87, $73, $3C
    DB      $32, $87, $73, $FE, $15, $C2, $3C, $9E
    DB      $3E, $01, $32, $87, $73, $3A, $88, $73
    DB      $3C, $32, $88, $73, $FE, $06, $C2, $3C
    DB      $9E, $3E, $05, $32, $88, $73, $C3, $D0
    DB      $99, $CD, $A4, $91, $CD, $E3, $9E, $3A
    DB      $AF, $73, $FE, $01, $CA, $0B, $97, $3E
    DB      $01, $32, $AF, $73, $CD, $88, $A2, $C3
    DB      $0B, $97, $CD, $A4, $91, $CD, $E3, $9E
    DB      $2A, $A6, $73, $2B, $7E, $FE, $01, $CA
    DB      $1A, $9E, $21, $8B, $73, $35, $C2, $D0
    DB      $99, $11, $C0, $1A, $21, $79, $9E, $06
    DB      $20, $18, $20, $20, $20, $20, $20, $20
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $CD, $A9, $92, $11, $E0
    DB      $1A, $21, $A6, $9E, $06, $20, $18, $20
    DB      $20, $20, $20, $20, $20, $20, $20, $3E ; "       >"
    DB      $3E, $3E, $20, $47, $41, $4D, $45, $20 ; ">> GAME "
    DB      $4F, $56, $45, $52, $20, $3C, $3C, $3C ; "OVER <<<"
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $CD, $A9, $92, $3E, $0D, $CD, $C6, $95
    DB      $3A, $5D, $70, $FE, $0A, $CA, $D0, $99
    DB      $FE, $0B, $CA, $D0, $99, $3E, $01, $21
    DB      $CE, $9E, $C3, $A2, $95, $FD, $E1, $FD
    DB      $22, $83, $73, $3E, $02, $32, $9A, $73
    DB      $3E, $00, $CD, $48, $AA, $DD, $36, $07
    DB      $2D, $DD, $36, $08, $32, $CD, $3F, $92
    DB      $E6, $03, $FE, $03, $CA, $FB, $9E, $47
    DB      $FE, $02, $C2, $15, $9F, $3E, $DE, $CD
    DB      $2B, $92, $06, $02, $C3, $18, $9F, $CD
    DB      $3F, $92, $4F, $21, $20, $18, $09, $3E
    DB      $0C, $CD, $45, $94, $DD, $35, $08, $C2
    DB      $FB, $9E, $CD, $3F, $92, $E6, $07, $C6
    DB      $08, $CD, $48, $AA, $3E, $01, $CD, $C6
    DB      $95, $DD, $35, $07, $C2, $F7, $9E, $21
    DB      $20, $18, $3E, $0C, $CD, $45, $94, $01
    DB      $DD, $02, $3E, $0C, $D3, $BE, $0B, $78
    DB      $B1, $C2, $48, $9F, $FD, $2A, $83, $73
    DB      $FD, $E9, $3E, $12, $CD, $48, $AA, $3E
    DB      $06, $32, $9A, $73, $06, $01, $0E, $C2
    DB      $CD, $D9, $1F, $3E, $20, $11, $00, $03
    DB      $21, $00, $18, $CD, $82, $1F, $06, $01
    DB      $0E, $E2, $CD, $D9, $1F, $FD, $2A, $A6
    DB      $73, $3A, $24, $88, $FD, $86, $13, $21
    DB      $00, $20, $CD, $45, $94, $21, $25, $88
    DB      $01, $FF, $07, $CD, $E7, $A2, $C2, $91
    DB      $9F, $21, $24, $88, $01, $00, $08, $CD
    DB      $E7, $A2, $C2, $9D, $9F, $21, $24, $88
    DB      $01, $00, $08, $CD, $E7, $A2, $C2, $A9
    DB      $9F, $11, $01, $18, $21, $B9, $9F, $06
    DB      $15, $C3, $F3, $9F, $20, $40, $31, $39
    DB      $38, $37, $20, $46, $49, $52, $53, $54 ; "87 FIRST"
    DB      $20, $53, $54, $41, $52, $20, $53, $4F ; " STAR SO"
    DB      $46, $54, $57, $41, $52, $45, $20, $49 ; "FTWARE I"
    DB      $4E, $43, $15, $18, $15, $20, $20, $20
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $42, $44, $46, $48, $4A, $4C, $4E, $50 ; "BDFHJLNP"
    DB      $52, $54, $00, $00, $00, $11, $41, $18
    DB      $21, $FD, $9F, $06, $1F, $18, $1F, $2E
    DB      $2E, $2E, $2E, $2E, $2E, $2E, $2E, $2E ; "........"
    DB      $2E, $2E, $2E, $2E, $2E, $2E, $2E, $2E ; "........"
    DB      $2E, $2E, $2E, $2E, $2E, $2E, $2E, $2E ; "........"
    DB      $2E, $2E, $2E, $2E, $2E, $2E, $CD, $A9
    DB      $92, $11, $61, $18, $21, $29, $A0, $06
    DB      $1F, $18, $1F, $2E, $20, $20, $20, $20
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $2E, $CD, $A9, $92, $11, $81, $18
    DB      $21, $55, $A0, $06, $1F, $18, $1F, $2E
    DB      $20, $2C, $2C, $2A, $20, $29, $2C, $2A ; " ,,* ),*"
    DB      $20, $2C, $20, $2C, $20, $2C, $20, $20 ; " , , ,  "
    DB      $20, $2C, $2C, $2A, $20, $2C, $2C, $2C ; " ,,* ,,,"
    DB      $20, $2C, $2C, $2A, $20, $2E, $CD, $A9
    DB      $92, $11, $A1, $18, $21, $81, $A0, $06
    DB      $1F, $18, $1F, $2E, $20, $2C, $20, $2C
    DB      $20, $2C, $20, $2C, $20, $2C, $20, $2C ; " , , , ,"
    DB      $20, $2C, $20, $20, $20, $2C, $20, $2C ; " ,   , ,"
    DB      $20, $2C, $20, $20, $20, $2C, $20, $2C ; " ,   , ,"
    DB      $20, $2E, $CD, $A9, $92, $11, $C1, $18
    DB      $21, $AD, $A0, $06, $1F, $18, $1F, $2E
    DB      $20, $2C, $2C, $20, $20, $2C, $20, $2C ; " ,,  , ,"
    DB      $20, $2C, $20, $2C, $20, $2C, $20, $20 ; " , , ,  "
    DB      $20, $2C, $20, $2C, $20, $2C, $2C, $20 ; " , , ,, "
    DB      $20, $2C, $2C, $2B, $20, $2E, $CD, $A9
    DB      $92, $11, $E1, $18, $21, $D9, $A0, $06
    DB      $1F, $18, $1F, $2E, $20, $2C, $20, $2C
    DB      $20, $2C, $20, $2C, $20, $2C, $20, $2C ; " , , , ,"
    DB      $20, $2C, $20, $20, $20, $2C, $20, $2C ; " ,   , ,"
    DB      $20, $2C, $20, $20, $20, $2C, $2A, $20 ; " ,   ,* "
    DB      $20, $2E, $CD, $A9, $92, $11, $01, $19
    DB      $21, $05, $A1, $06, $1F, $18, $1F, $2E
    DB      $20, $2C, $2C, $2B, $20, $28, $2C, $2B ; " ,,+ (,+"
    DB      $20, $28, $2C, $2B, $20, $2C, $2C, $2C ; " (,+ ,,,"
    DB      $20, $2C, $2C, $2B, $20, $2C, $2C, $2C ; " ,,+ ,,,"
    DB      $20, $2C, $28, $2A, $20, $2E, $CD, $A9
    DB      $92, $11, $21, $19, $21, $31, $A1, $06
    DB      $1F, $18, $1F, $2E, $20, $20, $20, $20
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $2E, $CD, $A9, $92, $11, $41, $19
    DB      $21, $5D, $A1, $06, $1F, $18, $1F, $2E
    DB      $20, $20, $20, $20, $20, $20, $20, $2C ; "       ,"
    DB      $2C, $2A, $20, $29, $2C, $2A, $20, $29 ; ",* ),* )"
    DB      $2C, $2C, $20, $2C, $20, $2C, $20, $54 ; ",, , , T"
    DB      $4D, $20, $20, $20, $20, $2E, $CD, $A9
    DB      $92, $11, $61, $19, $21, $89, $A1, $06
    DB      $1F, $18, $1F, $2E, $20, $20, $20, $20
    DB      $20, $20, $20, $2C, $20, $2C, $20, $2C ; "   , , ,"
    DB      $20, $2C, $20, $2C, $20, $20, $20, $2C ; " , ,   ,"
    DB      $20, $2C, $20, $20, $20, $20, $20, $20 ; " ,      "
    DB      $20, $2E, $CD, $A9, $92, $11, $81, $19
    DB      $21, $B5, $A1, $06, $1F, $18, $1F, $2E
    DB      $20, $20, $20, $20, $20, $20, $20, $2C ; "       ,"
    DB      $20, $2C, $20, $2C, $2C, $2C, $20, $28 ; " , ,,, ("
    DB      $2C, $2A, $20, $2C, $2C, $2C, $20, $20 ; ",* ,,,  "
    DB      $20, $20, $20, $20, $20, $2E, $CD, $A9
    DB      $92, $11, $A1, $19, $21, $E1, $A1, $06
    DB      $1F, $18, $1F, $2E, $20, $20, $20, $20
    DB      $20, $20, $20, $2C, $20, $2C, $20, $2C ; "   , , ,"
    DB      $20, $2C, $20, $20, $20, $2C, $20, $2C ; " ,   , ,"
    DB      $20, $2C, $20, $20, $20, $20, $20, $20 ; " ,      "
    DB      $20, $2E, $CD, $A9, $92, $11, $C1, $19
    DB      $21, $0D, $A2, $06, $1F, $18, $1F, $2E
    DB      $20, $20, $20, $20, $20, $20, $20, $2C ; "       ,"
    DB      $2C, $2B, $20, $2C, $20, $2C, $20, $2C ; ",+ , , ,"
    DB      $2C, $2B, $20, $2C, $20, $2C, $20, $20 ; ",+ , ,  "
    DB      $20, $20, $20, $20, $20, $2E, $CD, $A9
    DB      $92, $11, $E1, $19, $21, $39, $A2, $06
    DB      $1F, $18, $1F, $2E, $20, $20, $20, $20
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $20, $20, $20, $20, $20, $20, $20 ; "        "
    DB      $20, $2E, $CD, $A9, $92, $11, $01, $1A
    DB      $21, $65, $A2, $06, $1F, $18, $1F, $2E
    DB      $2E, $2E, $2E, $2E, $2E, $2E, $2E, $2E ; "........"
    DB      $2E, $2E, $2E, $2E, $2E, $2E, $2E, $2E ; "........"
    DB      $2E, $2E, $2E, $2E, $2E, $2E, $2E, $2E ; "........"
    DB      $2E, $2E, $2E, $2E, $2E, $2E, $CD, $A9
    DB      $92, $C9, $21, $87, $73, $11, $9B, $73
    DB      $06, $0B, $4E, $1A, $EB, $71, $12, $13
    DB      $23, $10, $F7, $C9, $CD, $A9, $A2, $CD
    DB      $88, $A2, $CD, $A9, $A2, $CD, $88, $A2
    DB      $C3, $0B, $97, $06, $03, $21, $8C, $73
    DB      $11, $8F, $73, $1A, $BE, $28, $01, $D0
    DB      $13, $23, $10, $F7, $3A, $8C, $73, $2A
    DB      $8D, $73, $32, $8F, $73, $22, $90, $73
    DB      $C9, $7E, $E6, $F0, $7E, $CA, $E0, $A2
    DB      $FD, $86, $13, $57, $E6, $F0, $7A, $CA
    DB      $CE, $A2, $E6, $F0, $FE, $10, $7A, $CA
    DB      $CE, $A2, $D3, $BE, $23, $0B, $78, $B1
    DB      $C9, $7E, $D3, $BE, $23, $0B, $78, $B1
    DB      $C9, $80, $80, $B0, $B0, $30, $30, $50
    DB      $50, $50, $50, $80, $80, $B0, $B0, $30
    DB      $30, $30, $30, $50, $50, $80, $80, $B0
    DB      $B0, $B0, $B0, $30, $30, $50, $50, $80
    DB      $80, $38, $A3, $6A, $A3, $C4, $A3, $EC
    DB      $A3, $A5, $A8, $38, $A4, $C0, $A4, $52
    DB      $A5, $9B, $A5, $EC, $A8, $F3, $A5, $37
    DB      $A6, $9D, $A6, $04, $A7, $4D, $A9, $6F
    DB      $A7, $AE, $A7, $09, $A8, $45, $A8, $96
    DB      $A9, $00, $01, $14, $0A, $0F, $0A, $0B
    DB      $0C, $0D, $0E, $0C, $0C, $0C, $0C, $0C
    DB      $96, $6E, $46, $28, $1E, $00, $10, $20
    DB      $30, $40, $00, $10, $14, $00, $3C, $32
    DB      $09, $00, $42, $01, $09, $1E, $02, $42
    DB      $09, $10, $1E, $02, $25, $03, $04, $04
    DB      $26, $12, $FF, $00, $02, $14, $14, $32
    DB      $03, $00, $01, $57, $58, $0A, $0C, $09
    DB      $0D, $0A, $96, $6E, $46, $46, $46, $10
    DB      $60, $70, $80, $90, $00, $10, $14, $08
    DB      $3C, $32, $09, $02, $42, $01, $08, $26
    DB      $02, $42, $01, $0F, $26, $02, $42, $08
    DB      $03, $14, $04, $42, $10, $03, $14, $04
    DB      $42, $18, $03, $14, $04, $42, $20, $03
    DB      $14, $04, $40, $01, $05, $26, $02, $40
    DB      $01, $0B, $26, $02, $40, $01, $12, $26
    DB      $02, $40, $14, $03, $14, $04, $25, $12
    DB      $15, $04, $12, $16, $FF, $00, $03, $00
    DB      $0F, $00, $00, $32, $36, $34, $37, $18
    DB      $17, $18, $17, $15, $96, $64, $5A, $50
    DB      $46, $40, $B0, $C0, $D0, $E0, $02, $10
    DB      $14, $00, $64, $32, $09, $00, $25, $03
    DB      $04, $04, $26, $14, $FF, $00, $04, $14
    DB      $05, $14, $00, $6E, $70, $73, $77, $24
    DB      $24, $24, $24, $24, $78, $64, $50, $3C ; "$$$$xdP<"
    DB      $32, $50, $08, $09, $00, $00, $10, $00
    DB      $00, $00, $14, $00, $00, $00, $25, $01
    DB      $03, $04, $26, $16, $81, $08, $0A, $04
    DB      $04, $00, $30, $0A, $0B, $81, $10, $0A
    DB      $04, $04, $00, $30, $12, $0B, $81, $18
    DB      $0A, $04, $04, $00, $30, $1A, $0B, $81
    DB      $20, $0A, $04, $04, $00, $30, $22, $0B
    DB      $FF, $00, $05, $14, $32, $5A, $00, $00
    DB      $00, $00, $00, $04, $05, $06, $07, $08
    DB      $96, $78, $5A, $3C, $1E, $80, $0A, $09
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $25, $01, $03, $04, $26, $16
    DB      $80, $08, $0A, $03, $03, $00, $80, $10
    DB      $0A, $03, $03, $00, $80, $18, $0A, $03
    DB      $03, $00, $80, $20, $0A, $03, $03, $00
    DB      $14, $09, $0C, $08, $0A, $0A, $14, $11
    DB      $0C, $08, $12, $0A, $14, $19, $0C, $08
    DB      $1A, $0A, $14, $21, $0C, $08, $22, $0A
    DB      $80, $08, $10, $03, $03, $00, $80, $10
    DB      $10, $03, $03, $00, $80, $18, $10, $03
    DB      $03, $00, $80, $20, $10, $03, $03, $00
    DB      $14, $09, $12, $08, $0A, $10, $14, $11
    DB      $12, $08, $12, $10, $14, $19, $12, $08
    DB      $1A, $10, $14, $21, $12, $08, $22, $10
    DB      $FF, $00, $06, $14, $28, $3C, $00, $14
    DB      $15, $16, $17, $04, $06, $07, $08, $08
    DB      $96, $78, $64, $5A, $50, $90, $0A, $09
    DB      $00, $00, $10, $00, $00, $00, $32, $00
    DB      $00, $00, $82, $01, $03, $0A, $04, $00
    DB      $82, $01, $06, $0A, $04, $00, $82, $01
    DB      $09, $0A, $04, $00, $82, $01, $0C, $0A
    DB      $04, $00, $41, $0A, $03, $0D, $04, $14
    DB      $03, $05, $08, $04, $05, $14, $03, $08
    DB      $08, $04, $08, $14, $03, $0B, $08, $04
    DB      $0B, $14, $03, $0E, $08, $04, $0E, $82
    DB      $1D, $03, $0A, $04, $00, $82, $1D, $06
    DB      $0A, $04, $00, $82, $1D, $09, $0A, $04
    DB      $00, $82, $1D, $0C, $0A, $04, $00, $41
    DB      $1D, $03, $0D, $04, $14, $24, $05, $08
    DB      $23, $05, $14, $24, $08, $08, $23, $08
    DB      $14, $24, $0B, $08, $23, $0B, $14, $24
    DB      $0E, $08, $23, $0E, $25, $03, $14, $04
    DB      $26, $14, $FF, $00, $07, $4B, $0A, $14
    DB      $02, $07, $08, $0A, $09, $0F, $14, $19
    DB      $19, $19, $78, $78, $78, $78, $78, $00
    DB      $0A, $0D, $00, $00, $00, $10, $08, $00
    DB      $64, $28, $02, $00, $42, $01, $07, $0C
    DB      $02, $42, $1C, $05, $0B, $02, $7A, $13
    DB      $15, $02, $02, $14, $04, $06, $14, $04
    DB      $0E, $14, $04, $16, $14, $22, $04, $14
    DB      $22, $0C, $14, $22, $16, $25, $14, $03
    DB      $04, $26, $07, $FF, $00, $08, $14, $0A
    DB      $14, $01, $03, $04, $05, $06, $0A, $0F
    DB      $14, $14, $14, $78, $6E, $64, $5A, $50
    DB      $E0, $0E, $09, $00, $00, $00, $10, $08
    DB      $00, $5A, $32, $02, $00, $14, $04, $06
    DB      $14, $22, $04, $14, $22, $0C, $04, $01
    DB      $05, $25, $14, $03, $42, $01, $07, $0C
    DB      $02, $42, $01, $0F, $0C, $02, $42, $1C
    DB      $05, $0B, $02, $42, $1C, $0D, $0B, $02
    DB      $43, $0E, $11, $08, $02, $14, $0C, $10
    DB      $00, $0E, $12, $14, $13, $12, $41, $0E
    DB      $0F, $08, $02, $FF, $00, $09, $14, $05
    DB      $0A, $64, $89, $8C, $FB, $33, $4B, $4B
    DB      $50, $55, $5A, $96, $96, $82, $82, $78
    DB      $00, $04, $09, $00, $00, $10, $14, $00
    DB      $00, $F0, $78, $00, $00, $82, $05, $0A
    DB      $0D, $0D, $00, $01, $0C, $0A, $82, $19
    DB      $0A, $0D, $0D, $00, $01, $1F, $0A, $42
    DB      $11, $12, $09, $02, $40, $11, $13, $09
    DB      $02, $25, $07, $0C, $04, $08, $0C, $FF
    DB      $00, $0A, $14, $19, $3C, $00, $00, $00
    DB      $00, $00, $0C, $0C, $0C, $0C, $0C, $96
    DB      $82, $78, $6E, $64, $10, $08, $09, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $25, $0D, $03, $04, $26, $16, $54
    DB      $05, $04, $11, $03, $54, $15, $04, $11
    DB      $05, $80, $05, $0B, $11, $03, $08, $C2
    DB      $01, $04, $15, $11, $00, $0D, $04, $C2
    DB      $07, $06, $0D, $0D, $00, $0D, $06, $C2
    DB      $09, $08, $09, $09, $00, $0D, $08, $C2
    DB      $0B, $0A, $05, $05, $00, $0D, $0A, $82
    DB      $03, $06, $03, $0F, $08, $00, $04, $06
    DB      $54, $04, $10, $04, $04, $FF, $00, $0B
    DB      $14, $32, $00, $00, $04, $66, $97, $64
    DB      $06, $06, $06, $06, $06, $78, $78, $96
    DB      $96, $F0, $40, $08, $09, $00, $00, $00
    DB      $10, $08, $00, $64, $50, $02, $00, $42
    DB      $0A, $03, $09, $04, $42, $14, $03, $09
    DB      $04, $42, $1E, $03, $09, $04, $42, $09
    DB      $16, $09, $00, $42, $0C, $0F, $11, $02
    DB      $42, $05, $0B, $09, $02, $42, $0F, $0B
    DB      $09, $02, $42, $19, $0B, $09, $02, $42
    DB      $1C, $13, $0B, $01, $14, $04, $03, $14
    DB      $0E, $03, $14, $18, $03, $14, $22, $03
    DB      $14, $04, $16, $14, $23, $15, $25, $14
    DB      $14, $04, $26, $11, $FF, $00, $0C, $14
    DB      $14, $00, $00, $3C, $02, $3B, $66, $13
    DB      $13, $0E, $10, $15, $B4, $AA, $A0, $A0
    DB      $A0, $50, $0A, $09, $00, $00, $00, $10
    DB      $14, $00, $3C, $32, $09, $00, $42, $0A
    DB      $05, $12, $04, $42, $0E, $05, $12, $04
    DB      $42, $12, $05, $12, $04, $42, $16, $05
    DB      $12, $04, $42, $02, $06, $0B, $02, $42
    DB      $02, $0A, $0B, $02, $42, $02, $0E, $0F
    DB      $02, $42, $02, $12, $0B, $02, $81, $1E
    DB      $04, $04, $04, $00, $08, $20, $05, $81
    DB      $1E, $09, $04, $04, $00, $08, $20, $0A
    DB      $81, $1E, $0E, $04, $04, $00, $08, $20
    DB      $0F, $25, $03, $14, $04, $26, $16, $FF
    DB      $00, $0D, $8C, $05, $08, $00, $01, $02
    DB      $03, $04, $32, $37, $3C, $46, $50, $A0
    DB      $9B, $96, $91, $8C, $00, $08, $0D, $00
    DB      $00, $10, $00, $00, $00, $28, $00, $00
    DB      $00, $25, $12, $03, $04, $0A, $03, $3A
    DB      $14, $03, $42, $05, $12, $1E, $02, $70
    DB      $05, $13, $1E, $02, $50, $05, $14, $1E
    DB      $02, $C1, $05, $15, $1E, $02, $FF, $00
    DB      $0E, $14, $0A, $14, $00, $00, $00, $00
    DB      $00, $1E, $23, $28, $2A, $2D, $96, $91
    DB      $8C, $87, $82, $90, $08, $09, $00, $00
    DB      $10, $00, $00, $00, $00, $00, $00, $00
    DB      $81, $0A, $0A, $0D, $0D, $00, $70, $0B
    DB      $0B, $0C, $03, $C1, $0C, $0A, $03, $0D
    DB      $C1, $10, $0A, $03, $0D, $C1, $14, $0A
    DB      $03, $0D, $50, $16, $08, $0C, $02, $48
    DB      $16, $07, $0C, $02, $C1, $17, $06, $03
    DB      $04, $C1, $1B, $06, $03, $04, $C1, $1F
    DB      $06, $03, $04, $25, $03, $03, $04, $26
    DB      $14, $FF, $00, $0F, $08, $0A, $14, $01
    DB      $1D, $1E, $1F, $20, $0F, $14, $14, $19
    DB      $1E, $78, $78, $78, $78, $8C, $B0, $0E
    DB      $09, $00, $00, $00, $10, $08, $00, $64
    DB      $50, $02, $00, $42, $02, $04, $0A, $03
    DB      $42, $0F, $0D, $0A, $01, $41, $0C, $0E
    DB      $03, $02, $43, $0C, $0F, $03, $02, $04
    DB      $14, $16, $25, $14, $03, $FF, $00, $10
    DB      $14, $0A, $14, $01, $78, $81, $7E, $7B
    DB      $0C, $0F, $0F, $0F, $0C, $96, $96, $96
    DB      $96, $96, $E0, $0A, $09, $00, $00, $10
    DB      $00, $00, $00, $32, $00, $00, $00, $25
    DB      $01, $03, $04, $26, $04, $81, $08, $13
    DB      $04, $04, $00, $08, $0A, $14, $C2, $07
    DB      $0A, $06, $08, $43, $07, $0A, $06, $02
    DB      $81, $10, $13, $04, $04, $00, $08, $12
    DB      $14, $C2, $0F, $0A, $06, $08, $43, $0F
    DB      $0A, $06, $02, $81, $18, $13, $04, $04
    DB      $00, $08, $1A, $14, $81, $20, $13, $04
    DB      $04, $00, $08, $22, $14, $FF, $01, $11
    DB      $14, $1E, $00, $0A, $0B, $0C, $0D, $0E
    DB      $06, $06, $06, $06, $06, $0A, $0A, $0A
    DB      $0A, $0A, $00, $02, $09, $00, $00, $00
    DB      $14, $00, $00, $FF, $09, $00, $00, $87
    DB      $01, $03, $26, $14, $07, $80, $01, $03
    DB      $13, $0B, $00, $47, $01, $0D, $13, $02
    DB      $47, $13, $03, $0B, $04, $32, $0A, $0C
    DB      $10, $0A, $04, $01, $0A, $05, $25, $03
    DB      $05, $04, $12, $0C, $FF, $01, $12, $14
    DB      $0A, $00, $0A, $0B, $0C, $0D, $0E, $10
    DB      $10, $10, $10, $10, $0F, $0F, $0F, $0F
    DB      $0F, $10, $0F, $09, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $87, $01
    DB      $03, $26, $14, $07, $81, $01, $03, $13
    DB      $0B, $01, $47, $01, $0D, $13, $02, $47
    DB      $13, $03, $0B, $04, $50, $01, $03, $09
    DB      $03, $48, $02, $03, $08, $03, $54, $01
    DB      $05, $08, $03, $50, $01, $06, $07, $03
    DB      $50, $12, $03, $09, $05, $54, $12, $05
    DB      $08, $05, $50, $12, $06, $07, $05, $25
    DB      $01, $04, $04, $12, $04, $FF, $01, $13
    DB      $04, $0A, $00, $0A, $0B, $0C, $0D, $0E
    DB      $0E, $0E, $0E, $0E, $0E, $14, $14, $14
    DB      $14, $14, $40, $08, $09, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $87
    DB      $01, $03, $26, $14, $07, $80, $01, $03
    DB      $13, $0B, $00, $47, $01, $0D, $13, $02
    DB      $47, $13, $03, $0B, $04, $54, $01, $0C
    DB      $12, $02, $88, $0F, $09, $04, $04, $08
    DB      $25, $08, $03, $04, $12, $07, $FF, $01
    DB      $14, $03, $1E, $00, $00, $00, $00, $00
    DB      $00, $06, $06, $06, $06, $06, $14, $14
    DB      $14, $14, $14, $50, $08, $09, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $87, $01, $03, $26, $14, $07, $81, $01
    DB      $03, $13, $0B, $01, $47, $01, $0D, $13
    DB      $02, $47, $13, $03, $0B, $04, $D0, $0B
    DB      $03, $03, $02, $80, $0B, $07, $03, $06
    DB      $00, $43, $0B, $06, $03, $02, $43, $0B
    DB      $0A, $03, $02, $50, $08, $07, $03, $03
    DB      $25, $03, $03, $04, $09, $0A, $FF

; ---- NMI HANDLER ($A9ED) ----
; Fires each VSYNC. Increments frame counter $7056.
; Drives 60-frame timer ($7385). Calls POLLER, PLAY_SONGS, SOUND_MAN.
NMI:
    PUSH    AF                              ; save AF
    PUSH    BC                              ; save BC
    PUSH    DE                              ; save DE
    PUSH    HL                              ; save HL
    PUSH    IX                              ; save IX
    PUSH    IY                              ; save IY
    LD      A, ($7056)                      ; A = frame counter ($7056)
    INC     A                               ; A++ (increment frame counter)
    LD      ($7056), A                      ; $7056 = A (store updated frame counter)
    LD      A, ($7385)                      ; A = $7385 (60-frame cycle timer)
    INC     A                               ; A++ (increment 60-frame timer)
    CP      $3C                             ; compare to $3C (60 decimal)
    JR      C, LOC_AA1B                     ; skip second-tick logic if < 60 frames
    LD      A, ($7396)                      ; A = $7396 (timeout countdown)
    CP      $00                             ; compare to 0 (already timed out?)
    JP      Z, LOC_AA15                     ; jump to LOC_AA15 if already 0
    CP      $FF                             ; compare to $FF (disabled/infinite?)
    JP      Z, LOC_AA15                     ; jump to LOC_AA15 if $FF (inactive)
    DEC     A                               ; A-- (decrement per-second timeout)
    LD      ($7396), A                      ; $7396 = A (store updated timeout)

LOC_AA15:
    LD      HL, $7386                       ; HL = $7386 (per-second countdown address)
    DEC     (HL)                            ; (HL)-- (decrement per-second timer)
    LD      A, $00                          ; A = 0 (reset 60-frame timer to 0)

LOC_AA1B:
    LD      ($7385), A                      ; $7385 = A (store 60-frame timer value)
    OUT     ($C0), A                        ; OUT ($C0), A (JOY_PORT: set joystick mux mode)
    CALL    POLLER                          ; BIOS POLLER  -- reads joystick into JOYSTICK_BUFFER
    CALL    PLAY_SONGS                      ; BIOS PLAY_SONGS  -- advance music sequencer
    CALL    SOUND_MAN                       ; BIOS SOUND_MAN  -- drive SN76489A output
    LD      A, ($73AF)                      ; A = $73AF (game state flag)
    CP      $02                             ; compare to $02 (sprite update requested?)
    JP      NZ, LOC_AA3C                    ; skip LDIR if $73AF != $02
    LD      HL, $705E                       ; HL = $705E (sprite attr source buffer)
    LD      DE, $7059                       ; DE = $7059 (sprite attr destination)
    LD      BC, $0005                       ; BC = 5 (5 bytes to copy)
    LDIR                                    ; LDIR: copy 5 sprite attr bytes $705E -> $7059

LOC_AA3C:
    POP     IY                              ; restore IY
    POP     IX                              ; restore IX
    POP     HL                              ; restore HL
    POP     DE                              ; restore DE
    POP     BC                              ; restore BC
    IN      A, ($BF)                        ; IN A, ($BF): read VDP status to clear interrupt
    POP     AF                              ; restore AF
    RETN                                    ; RETN (return from non-maskable interrupt)
    DB      $FE, $00, $CA, $70, $AA, $DD, $E5, $3D
    DB      $CB, $27, $CB, $27, $21, $78, $AA, $4F
    DB      $06, $00, $09, $06, $04, $7E, $FE, $00
    DB      $28, $0B, $C5, $E5, $47, $CD, $F1, $1F
    DB      $E1, $C1, $23, $10, $F0, $DD, $E1, $C9
    DB      $06, $03, $21, $C8, $AA, $C3, $EE, $1F
    DB      $01, $00, $00, $00, $02, $00, $00, $00
    DB      $03, $00, $00, $00, $04, $00, $00, $00
    DB      $05, $00, $00, $00, $06, $07, $00, $00
    DB      $08, $00, $00, $00, $09, $00, $00, $00
    DB      $0A, $00, $00, $00, $0B, $00, $00, $00
    DB      $0C, $00, $00, $00, $0D, $00, $00, $00
    DB      $0E, $00, $00, $00, $0F, $00, $00, $00
    DB      $10, $00, $00, $00, $11, $00, $00, $00
    DB      $12, $00, $00, $00, $13, $14, $00, $00
    DB      $15, $16, $00, $00, $17, $00, $00, $00
    DB      $24, $AB, $65, $70, $2A, $AB, $65, $70
    DB      $30, $AB, $65, $70, $35, $AB, $65, $70
    DB      $3A, $AB, $65, $70, $41, $AB, $65, $70
    DB      $48, $AB, $6F, $70, $4F, $AB, $65, $70
    DB      $55, $AB, $65, $70, $5C, $AB, $65, $70
    DB      $63, $AB, $65, $70, $6A, $AB, $65, $70
    DB      $71, $AB, $65, $70, $78, $AB, $65, $70
    DB      $7F, $AB, $65, $70, $86, $AB, $65, $70
    DB      $8D, $AB, $79, $70, $92, $AB, $65, $70
    DB      $BE, $AB, $6F, $70, $3F, $AE, $79, $70
    DB      $A3, $AB, $65, $70, $AA, $AB, $6F, $70
    DB      $B1, $AB, $65, $70, $02, $05, $28, $1F
    DB      $41, $10, $02, $06, $28, $1F, $41, $10
    DB      $00, $00, $46, $07, $10, $00, $00, $76
    DB      $06, $10, $42, $3C, $00, $28, $1F, $41
    DB      $10, $42, $60, $01, $1E, $1F, $31, $10
    DB      $82, $61, $01, $1E, $1F, $31, $10, $02
    DB      $06, $87, $1F, $91, $10, $42, $47, $00
    DB      $28, $1F, $41, $10, $42, $3F, $00, $28
    DB      $1F, $41, $10, $42, $3C, $00, $28, $1F
    DB      $41, $10, $42, $35, $00, $28, $1F, $41
    DB      $10, $42, $2F, $00, $28, $1F, $41, $10
    DB      $42, $2D, $00, $28, $1F, $41, $10, $42
    DB      $28, $00, $28, $1F, $41, $10, $42, $24
    DB      $00, $28, $1F, $41, $10, $C0, $FA, $51
    DB      $01, $18, $00, $00, $7A, $02, $00, $00
    DB      $5A, $02, $00, $00, $3A, $02, $00, $00
    DB      $1A, $02, $10, $41, $1E, $00, $70, $41
    DB      $04, $18, $81, $20, $00, $70, $41, $04
    DB      $18, $40, $3C, $00, $0A, $10, $C5, $CD
    DB      $C1, $01, $C1, $C3, $6A, $02, $C0, $7E
    DB      $32, $07, $21, $C0, $A5, $31, $07, $21
    DB      $C0, $3F, $31, $07, $21, $C0, $0C, $31
    DB      $07, $21, $C0, $CC, $32, $07, $21, $C0
    DB      $7B, $31, $07, $21, $C0, $66, $31, $07
    DB      $21, $C0, $EF, $30, $07, $21, $C0, $24
    DB      $33, $07, $21, $C0, $24, $33, $07, $21
    DB      $C0, $92, $31, $07, $21, $C0, $24, $33
    DB      $07, $21, $C0, $66, $31, $07, $21, $C0
    DB      $77, $30, $07, $21, $C0, $52, $31, $07
    DB      $21, $C0, $86, $30, $07, $21, $C0, $7E
    DB      $32, $07, $21, $C0, $7E, $32, $07, $21
    DB      $C0, $7E, $32, $07, $21, $C0, $7E, $32
    DB      $07, $21, $C0, $CC, $32, $07, $21, $C0
    DB      $CC, $32, $07, $21, $C0, $CC, $32, $07
    DB      $21, $C0, $CC, $32, $07, $21, $C0, $7E
    DB      $32, $07, $21, $C0, $7E, $32, $07, $21
    DB      $C0, $7E, $32, $07, $21, $C0, $7E, $32
    DB      $07, $21, $C0, $92, $31, $07, $21, $C0
    DB      $92, $31, $07, $21, $C0, $92, $31, $07
    DB      $21, $C0, $92, $31, $07, $21, $C0, $CC
    DB      $32, $07, $21, $C0, $CC, $32, $07, $21
    DB      $C0, $CC, $32, $07, $21, $C0, $CC, $32
    DB      $07, $21, $C0, $C3, $31, $07, $21, $C0
    DB      $C3, $31, $07, $21, $C0, $C3, $31, $07
    DB      $21, $C0, $C3, $31, $07, $21, $C0, $53
    DB      $33, $07, $21, $C0, $D5, $30, $07, $21
    DB      $C0, $53, $33, $07, $21, $C0, $D5, $30
    DB      $07, $21, $C0, $BC, $33, $07, $21, $C0
    DB      $BC, $33, $07, $21, $C0, $7E, $32, $07
    DB      $21, $C0, $7E, $32, $07, $21, $C0, $7E
    DB      $32, $07, $21, $C0, $7E, $32, $07, $21
    DB      $C0, $7E, $32, $07, $21, $C0, $7E, $32
    DB      $07, $21, $C0, $3F, $31, $07, $21, $C0
    DB      $3F, $31, $07, $21, $C0, $7E, $32, $07
    DB      $21, $C0, $7E, $32, $07, $21, $C0, $CC
    DB      $32, $07, $21, $C0, $CC, $32, $07, $21
    DB      $C0, $CC, $32, $07, $21, $C0, $CC, $32
    DB      $07, $21, $C0, $66, $31, $07, $21, $C0
    DB      $66, $31, $07, $21, $C0, $CC, $32, $07
    DB      $21, $C0, $CC, $32, $07, $21, $C0, $7E
    DB      $32, $07, $21, $C0, $7F, $30, $07, $21
    DB      $C0, $7E, $32, $07, $21, $C0, $77, $30
    DB      $07, $21, $C0, $3F, $31, $07, $21, $C0
    DB      $7F, $30, $07, $21, $C0, $7E, $32, $07
    DB      $21, $C0, $77, $30, $07, $21, $C0, $CC
    DB      $32, $07, $21, $C0, $7F, $30, $07, $21
    DB      $C0, $CC, $32, $07, $21, $C0, $77, $30
    DB      $07, $21, $C0, $66, $31, $07, $21, $C0
    DB      $8E, $30, $07, $21, $C0, $CC, $32, $07
    DB      $21, $C0, $86, $30, $07, $21, $C0, $7E
    DB      $32, $07, $21, $C0, $7E, $32, $07, $21
    DB      $C0, $7E, $32, $07, $21, $C0, $6A, $30
    DB      $07, $21, $C0, $3F, $31, $07, $21, $C0
    DB      $3F, $31, $07, $21, $C0, $7E, $32, $07
    DB      $21, $C0, $86, $30, $07, $21, $C0, $CC
    DB      $32, $07, $21, $C0, $CC, $32, $07, $21
    DB      $C0, $CC, $32, $07, $21, $C0, $CC, $32
    DB      $07, $21, $C0, $66, $31, $07, $21, $C0
    DB      $66, $31, $07, $21, $C0, $CC, $32, $07
    DB      $21, $C0, $CC, $32, $07, $21, $C0, $7E
    DB      $32, $07, $21, $C0, $7F, $30, $07, $21
    DB      $C0, $7E, $32, $07, $21, $C0, $77, $30
    DB      $07, $21, $C0, $3F, $31, $07, $21, $C0
    DB      $7F, $30, $07, $21, $C0, $7E, $32, $07
    DB      $21, $C0, $77, $30, $07, $21, $C0, $CC
    DB      $32, $07, $21, $C0, $7F, $30, $07, $21
    DB      $C0, $CC, $32, $07, $21, $C0, $77, $30
    DB      $07, $21, $C0, $66, $31, $07, $21, $C0
    DB      $8E, $30, $07, $21, $C0, $CC, $32, $07
    DB      $21, $C0, $86, $30, $07, $21, $C0, $9F
    DB      $30, $07, $21, $C0, $D5, $30, $07, $21
    DB      $C0, $FD, $30, $07, $21, $C0, $3F, $31
    DB      $07, $21, $C0, $B3, $30, $07, $21, $C0
    DB      $EF, $30, $07, $21, $C0, $1C, $31, $07
    DB      $21, $C0, $CC, $32, $07, $21, $C0, $6A
    DB      $30, $07, $21, $C0, $7F, $30, $07, $21
    DB      $C0, $9F, $30, $07, $21, $C0, $D5, $30
    DB      $07, $21, $C0, $EF, $30, $07, $21, $C0
    DB      $1C, $31, $07, $21, $C0, $66, $31, $07
    DB      $21, $C0, $CC, $32, $07, $21, $18, $80
    DB      $3F, $31, $07, $21, $80, $FD, $30, $07
    DB      $21, $80, $D5, $30, $07, $21, $80, $9F
    DB      $30, $07, $21, $80, $1C, $31, $07, $21
    DB      $80, $EF, $30, $07, $21, $80, $D5, $30
    DB      $07, $21, $80, $8E, $30, $07, $21, $80
    DB      $C9, $30, $07, $21, $80, $B3, $30, $07
    DB      $21, $80, $9F, $30, $07, $21, $80, $86
    DB      $30, $07, $21, $80, $B3, $30, $07, $21
    DB      $80, $5F, $30, $07, $21, $80, $A9, $30
    DB      $07, $21, $80, $6A, $30, $07, $21, $80
    DB      $3F, $31, $07, $21, $80, $9F, $30, $07
    DB      $21, $80, $A5, $31, $07, $21, $80, $1C
    DB      $31, $07, $21, $80, $66, $31, $07, $21
    DB      $80, $8E, $30, $07, $21, $80, $1C, $31
    DB      $07, $21, $80, $66, $31, $07, $21, $80
    DB      $3F, $31, $07, $21, $80, $9F, $30, $07
    DB      $21, $80, $A5, $31, $07, $21, $80, $1C
    DB      $31, $07, $21, $80, $C9, $30, $07, $21
    DB      $80, $50, $30, $07, $21, $80, $9F, $30
    DB      $07, $21, $80, $C9, $30, $07, $21, $80
    DB      $66, $31, $07, $21, $80, $B3, $30, $07
    DB      $21, $80, $DE, $31, $07, $21, $80, $3F
    DB      $31, $07, $21, $80, $E1, $30, $07, $21
    DB      $80, $59, $30, $07, $21, $80, $B3, $30
    DB      $07, $21, $80, $E1, $30, $07, $21, $80
    DB      $A5, $31, $07, $21, $80, $A9, $30, $07
    DB      $21, $80, $7B, $31, $07, $21, $80, $9F
    DB      $30, $07, $21, $80, $EF, $30, $07, $21
    DB      $80, $EF, $30, $07, $21, $80, $77, $30
    DB      $07, $21, $80, $EF, $30, $07, $21, $80
    DB      $9F, $30, $07, $21, $80, $9F, $30, $07
    DB      $21, $80, $9F, $30, $07, $21, $80, $9F
    DB      $30, $07, $21, $80, $9F, $30, $07, $21
    DB      $80, $9F, $30, $07, $21, $80, $9F, $30
    DB      $07, $21, $80, $9F, $30, $07, $21, $80
    DB      $9F, $30, $07, $21, $80, $9F, $30, $07
    DB      $21, $80, $9F, $30, $07, $21, $80, $9F
    DB      $30, $07, $21, $80, $9F, $30, $07, $21
    DB      $80, $9F, $30, $07, $21, $80, $9F, $30
    DB      $07, $21, $80, $9F, $30, $07, $21, $80
    DB      $9F, $30, $07, $21, $80, $9F, $30, $07
    DB      $21, $80, $9F, $30, $07, $21, $80, $9F
    DB      $30, $07, $21, $80, $9F, $30, $07, $21
    DB      $80, $9F, $30, $07, $21, $80, $9F, $30
    DB      $07, $21, $80, $9F, $30, $07, $21, $80
    DB      $9F, $30, $07, $21, $80, $9F, $30, $07
    DB      $21, $80, $9F, $30, $07, $21, $80, $9F
    DB      $30, $07, $21, $80, $B3, $30, $07, $21
    DB      $80, $B3, $30, $07, $21, $80, $B3, $30
    DB      $07, $21, $80, $B3, $30, $07, $21, $80
    DB      $9F, $30, $07, $21, $80, $50, $30, $07
    DB      $21, $80, $9F, $30, $07, $21, $80, $59
    DB      $30, $07, $21, $80, $9F, $30, $07, $21
    DB      $80, $5F, $30, $07, $21, $80, $9F, $30
    DB      $07, $21, $80, $6A, $30, $07, $21, $80
    DB      $B3, $30, $07, $21, $80, $59, $30, $07
    DB      $21, $80, $B3, $30, $07, $21, $80, $59
    DB      $30, $07, $21, $80, $B3, $30, $07, $21
    DB      $80, $77, $30, $07, $21, $80, $B3, $30
    DB      $07, $21, $80, $59, $30, $07, $21, $80
    DB      $9F, $30, $07, $21, $80, $9F, $30, $07
    DB      $21, $80, $9F, $30, $07, $21, $80, $9F
    DB      $30, $07, $21, $80, $9F, $30, $07, $21
    DB      $80, $9F, $30, $07, $21, $80, $9F, $30
    DB      $07, $21, $80, $9F, $30, $07, $21, $80
    DB      $9F, $30, $07, $21, $80, $9F, $30, $07
    DB      $21, $80, $9F, $30

; ============================================================
; GAME DATA  ($B054 - $BBFF)
; Animation, sprite, level, and name-table data.
; (Tracer did not reach this area via static flow; kept as DB.)
; ============================================================
GAME_DATA:
    DB      $07, $21, $80, $9F, $30, $07, $21, $80
    DB      $B3, $30, $07, $21, $80, $B3, $30, $07
    DB      $21, $80, $B3, $30, $07, $21, $80, $B3
    DB      $30, $07, $21, $80, $7F, $30, $07, $21
    DB      $80, $9F, $30, $07, $21, $80, $D5, $30
    DB      $07, $21, $80, $FD, $30, $07, $21, $80
    DB      $8E, $30, $07, $21, $80, $B3, $30, $07
    DB      $21, $80, $EF, $30, $07, $21, $80, $66
    DB      $31, $07, $21, $80, $7F, $30, $07, $21
    DB      $80, $9F, $30, $07, $21, $80, $D5, $30
    DB      $07, $21, $80, $FD, $30, $07, $21, $80
    DB      $8E, $30, $07, $21, $80, $B3, $30, $07
    DB      $21, $80, $EF, $30, $07, $21, $80, $66
    DB      $31, $07, $21, $18, $DD, $36, $07, $0C
    DB      $3E, $BC, $32, $86, $70, $DD, $36, $08
    DB      $00, $DD, $36, $09, $00, $3A, $84, $70
    DB      $CB, $27, $6F, $3A, $85, $70, $CB, $27
    DB      $4F, $3A, $63, $70, $C6, $04, $BD, $DA
    DB      $F6, $B0, $CA, $08, $B1, $D6, $10, $F2
    DB      $F0, $B0, $3E, $00, $DD, $77, $08, $C3
    DB      $08, $B1, $C6, $12, $BD, $D2, $08, $B1
    DB      $D6, $0A, $FE, $30, $DA, $05, $B1, $3E
    DB      $30, $DD, $77, $08, $3A, $64, $70, $C6
    DB      $04, $B9, $DA, $21, $B1, $CA, $33, $B1
    DB      $D6, $0C, $F2, $1B, $B1, $3E, $00, $DD
    DB      $77, $09, $C3, $33, $B1, $C6, $0A, $B9
    DB      $D2, $33, $B1, $D6, $06, $FE, $14, $DA
    DB      $30, $B1, $3E, $14, $DD, $77, $09, $3A
    DB      $63, $70, $DD, $BE, $08, $CA, $4B, $B1
    DB      $28, $03, $D2, $46, $B1, $C6, $02, $C3
    DB      $48, $B1, $D6, $02, $32, $63, $70, $3A
    DB      $64, $70, $DD, $BE, $09, $CA, $63, $B1
    DB      $28, $03, $D2, $5E, $B1, $C6, $02, $C3
    DB      $60, $B1, $D6, $02, $32, $64, $70, $CD
    DB      $87, $B1, $3E, $01, $21, $D1, $B0, $C3
    DB      $A2, $95, $3D, $32, $99, $73, $11, $00
    DB      $00, $CD, $81, $B2, $11, $00, $08, $CD
    DB      $81, $B2, $11, $00, $10, $CD, $81, $B2
    DB      $C3, $AA, $B1, $3A, $99, $73, $FE, $00
    DB      $CA, $6E, $B1, $FE, $FF, $CA, $AA, $B1
    DB      $3D, $32, $99, $73, $11, $00, $00, $CD
    DB      $50, $B2, $11, $00, $08, $CD, $50, $B2
    DB      $11, $00, $10, $CD, $50, $B2, $DD, $7E
    DB      $07, $C6, $04, $DD, $77, $07, $FE, $1C
    DB      $C2, $BB, $B1, $DD, $36, $07, $0C, $3A
    DB      $56, $70, $47, $DB, $BF, $00, $00, $11
    DB      $20, $18, $7B, $D3, $BF, $7A, $C6, $40
    DB      $00, $00, $00, $D3, $BF, $3A, $56, $70
    DB      $B8, $20, $E4, $21, $65, $70, $3A, $64
    DB      $70, $4F, $CB, $3F, $C2, $E4, $B1, $3C
    DB      $11, $26, $00, $47, $19, $10, $FD, $3A
    DB      $63, $70, $CB, $3F, $CA, $F8, $B1, $3D
    DB      $5F, $16, $00, $19, $3E, $17, $32, $83
    DB      $73, $06, $20, $3A, $63, $70, $57, $E5
    DB      $1E, $0C, $7A, $FE, $02, $DA, $2E, $B2
    DB      $FE, $4E, $D2, $2E, $B2, $79, $FE, $02
    DB      $DA, $2E, $B2, $FE, $2A, $CA, $2E, $B2
    DB      $CD, $9F, $B2, $5F, $CB, $42, $CA, $28
    DB      $B2, $1C, $1C, $23, $CB, $41, $CA, $2E
    DB      $B2, $1C, $7B, $D3, $BE, $14, $10, $D0
    DB      $E1, $0C, $CB, $41, $C2, $45, $B2, $79
    DB      $FE, $02, $CA, $45, $B2, $11, $26, $00
    DB      $19, $3A, $83, $73, $3D, $32, $83, $73
    DB      $C2, $FD, $B1, $C9, $DB, $BF, $3A, $56
    DB      $70, $47, $7B, $D3, $BF, $7A, $C6, $40
    DB      $D3, $BF, $3A, $56, $70, $B8, $C2, $50
    DB      $B2, $06, $08, $3E, $00, $D3, $BE, $C6
    DB      $00, $C6, $00, $00, $D3, $BE, $CD, $3F
    DB      $92, $D3, $BE, $3E, $00, $C6, $00, $00
    DB      $D3, $BE, $10, $E7, $C9, $DB, $BF, $3A
    DB      $56, $70, $47, $7B, $D3, $BF, $7A, $C6
    DB      $40, $D3, $BF, $3A, $56, $70, $B8, $C2
    DB      $81, $B2, $06, $20, $3E, $00, $D3, $BE
    DB      $10, $FA, $C9, $7E, $CB, $67, $C2, $CD
    DB      $B2, $E6, $0F, $FE, $05, $DA, $E2, $B2
    DB      $FE, $0B, $DA, $E7, $B2, $FE, $0B, $C2
    DB      $D0, $B2, $3A, $86, $70, $FE, $DC, $C2
    DB      $C4, $B2, $3E, $D0, $DD, $86, $07, $C9
    DB      $FE, $CC, $C0, $3E, $C0, $DD, $86, $07
    DB      $C9, $3E, $0C, $C9, $7E, $E6, $C0, $CB
    DB      $17, $CB, $17, $CB, $17, $CB, $97, $CB
    DB      $27, $CB, $27, $C6, $EC, $C9, $CB, $27
    DB      $CB, $27, $C9, $FE, $09, $CA, $F8, $B2
    DB      $CB, $27, $CB, $27, $CB, $27, $CB, $27
    DB      $DD, $86, $07, $C9, $3A, $96, $73, $FE
    DB      $FF, $CA, $0B, $B3, $FE, $00, $CA, $0B
    DB      $B3, $3E, $90, $DD, $86, $07, $C9, $3E
    DB      $08, $C9, $3A, $87, $73, $3D, $87, $4F
    DB      $06, $00, $21, $0F, $A3, $09, $ED, $5F
    DB      $77, $7E, $32, $A6, $73, $23, $7E, $32
    DB      $A7, $73, $FD, $2A, $A6, $73, $FD, $7E
    DB      $01, $32, $95, $73, $FD, $7E, $02, $32
    DB      $94, $73, $3A, $88, $73, $3D, $4F, $06
    DB      $00, $FD, $09, $FD, $7E, $04, $32, $A8
    DB      $73, $3E, $00, $32, $A9, $73, $FD, $7E
    DB      $09, $32, $93, $73, $FD, $7E, $0E, $32
    DB      $86, $73, $3E, $00, $32, $88, $70, $21
    DB      $8B, $70, $3E, $00, $32, $87, $70, $CD
    DB      $3C, $B5, $CD, $C7, $B4, $23, $3A, $87
    DB      $70, $3C, $32, $87, $70, $FE, $26, $C2
    DB      $66, $B3, $CD, $3C, $B5, $3A, $88, $70
    DB      $3C, $32, $88, $70, $FE, $14, $C2, $5E
    DB      $B3, $2A, $A6, $73, $01, $20, $00, $09
    DB      $22, $89, $70, $2A, $89, $70, $7E, $FE
    DB      $FF, $C8, $E6, $3F, $4F, $FE, $25, $C2
    DB      $AD, $B3, $23, $7E, $3D, $32, $84, $70
    DB      $23, $7E, $D6, $03, $32, $85, $70, $2B
    DB      $2B, $CD, $E4, $B4, $7E, $23, $E6, $C0
    DB      $C2, $BD, $B3, $CD, $F9, $B3, $C3, $8F
    DB      $B3, $FE, $40, $C2, $C8, $B3, $CD, $14
    DB      $B4, $C3, $8F, $B3, $FE, $80, $C2, $D3
    DB      $B3, $CD, $39, $B4, $C3, $8F, $B3, $FE
    DB      $C0, $C2, $8F, $B3, $CD, $8A, $B4, $C3
    DB      $8F, $B3, $FD, $21, $8B, $70, $5E, $1D
    DB      $16, $00, $FD, $19, $23, $7E, $D6, $03
    DB      $23, $FE, $00, $C8, $47, $11, $26, $00
    DB      $FD, $19, $10, $FC, $C9, $CD, $DE, $B3
    DB      $22, $89, $70, $FD, $71, $00, $79, $FE
    DB      $0A, $C2, $0C, $B4, $FD, $22, $AA, $73
    DB      $FE, $03, $C0, $FD, $22, $AC, $73, $C9
    DB      $CD, $DE, $B3, $23, $5E, $22, $83, $73
    DB      $CB, $23, $16, $00, $21, $2C, $B5, $19
    DB      $5E, $23, $56, $2A, $83, $73, $2B, $46
    DB      $23, $23, $22, $89, $70, $FD, $71, $00
    DB      $FD, $19, $10, $F9, $C9, $CD, $DE, $B3
    DB      $FD, $22, $83, $73, $11, $26, $00, $23
    DB      $7E, $2B, $FD, $E5, $46, $FD, $71, $00
    DB      $FD, $23, $10, $F9, $FD, $E1, $FD, $19
    DB      $3D, $C2, $46, $B4, $23, $23, $4E, $CD
    DB      $E4, $B4, $FD, $2A, $83, $73, $11, $27
    DB      $00, $FD, $19, $11, $26, $00, $2B, $7E
    DB      $D6, $02, $2B, $FD, $E5, $46, $05, $05
    DB      $FD, $71, $00, $FD, $23, $10, $F9, $FD
    DB      $E1, $FD, $19, $3D, $C2, $6F, $B4, $23
    DB      $23, $23, $22, $89, $70, $C9, $CD, $DE
    DB      $B3, $46, $FD, $71, $00, $FD, $23, $10
    DB      $F9, $FD, $2B, $23, $46, $11, $26, $00
    DB      $FD, $71, $00, $FD, $22, $83, $73, $FD
    DB      $19, $10, $F5, $FD, $2A, $83, $73, $2B
    DB      $46, $FD, $71, $00, $FD, $2B, $10, $F9
    DB      $FD, $23, $23, $46, $11, $DA, $FF, $FD
    DB      $71, $00, $FD, $19, $10, $F9, $23, $22
    DB      $89, $70, $C9, $CD, $3C, $B5, $FD, $2A
    DB      $A6, $73, $0E, $01, $06, $04, $FD, $BE
    DB      $1C, $D2, $DB, $B4, $FD, $4E, $18, $FD
    DB      $23, $10, $F3, $CD, $E4, $B4, $71, $C9
    DB      $FD, $21, $F0, $B4, $06, $00, $FD, $09
    DB      $FD, $4E, $00, $C9, $00, $01, $02, $09
    DB      $03, $0A, $00, $03, $C7, $07, $47, $87
    DB      $C7, $07, $47, $87, $04, $04, $04, $04
    DB      $05, $05, $05, $05, $00, $00, $00, $0C
    DB      $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C
    DB      $0C, $0A, $0C, $0C, $0C, $00, $00, $00
    DB      $00, $00, $00, $00, $86, $46, $06, $C6
    DB      $86, $46, $06, $C6, $0B, $0B, $08, $08
    DB      $DA, $FF, $DB, $FF, $01, $00, $27, $00
    DB      $26, $00, $25, $00, $FF, $FF, $D9, $FF
    DB      $3A, $A9, $73, $CB, $1F, $CB, $1F, $E6
    DB      $80, $57, $3A, $A8, $73, $CB, $1F, $E6
    DB      $7F, $5F, $3A, $A8, $73, $4F, $CB, $1F
    DB      $CB, $1F, $E6, $80, $81, $CE, $13, $32
    DB      $A8, $73, $3A, $A9, $73, $8A, $8B, $32
    DB      $A9, $73, $C9, $DD, $7E, $08, $3C, $E6
    DB      $1F, $DD, $77, $08, $22, $83, $73, $21
    DB      $87, $70, $3E, $26, $96, $32, $84, $70
    DB      $23, $3E, $14, $96, $32, $85, $70, $2A
    DB      $83, $73, $3A, $5A, $70, $CB, $5F, $C2
    DB      $47, $B8, $CB, $4F, $C2, $80, $B8, $CB
    DB      $47, $C2, $54, $B7, $CB, $57, $C2, $48
    DB      $B7, $06, $00, $DD, $4E, $08, $21, $C3
    DB      $B8, $09, $7E, $32, $86, $70, $C3, $8C
    DB      $B9, $22, $83, $73, $CD, $CD, $BA, $FE
    DB      $0B, $CA, $F3, $B5, $FE, $08, $CA, $F3
    DB      $B5, $2A, $83, $73, $CD, $E0, $BA, $FE
    DB      $0B, $CA, $F3, $B5, $FE, $08, $CA, $F3
    DB      $B5, $2A, $83, $73, $CD, $F5, $BA, $FE
    DB      $0B, $CA, $F3, $B5, $FE, $08, $CA, $F3
    DB      $B5, $2A, $83, $73, $CD, $05, $BB, $FE
    DB      $0B, $CA, $F3, $B5, $FE, $08, $CA, $F3
    DB      $B5, $2A, $83, $73, $37, $3F, $C9, $2A
    DB      $83, $73, $37, $C9, $2A, $83, $73, $3A
    DB      $87, $70, $47, $3A, $88, $70, $4F, $C5
    DB      $36, $0C, $CD, $CD, $BA, $FE, $03, $CA
    DB      $10, $B6, $36, $0C, $2A, $83, $73, $CD
    DB      $F5, $BA, $FE, $03, $CA, $1D, $B6, $36
    DB      $0C, $2A, $83, $73, $CD, $E0, $BA, $FE
    DB      $03, $CA, $2A, $B6, $36, $2C, $2A, $83
    DB      $73, $CD, $05, $BB, $FE, $03, $CA, $37
    DB      $B6, $36, $2C, $21, $87, $70, $34, $2A
    DB      $83, $73, $2B, $22, $83, $73, $3A, $87
    DB      $70, $FE, $26, $28, $03, $D2, $63, $B6
    DB      $CD, $CD, $BA, $FE, $03, $CA, $56, $B6
    DB      $36, $0C, $2A, $83, $73, $CD, $E0, $BA
    DB      $FE, $03, $CA, $63, $B6, $36, $2C, $21
    DB      $87, $70, $35, $35, $2A, $83, $73, $23
    DB      $23, $22, $83, $73, $3A, $87, $70, $FE
    DB      $01, $DA, $8F, $B6, $CD, $CD, $BA, $FE
    DB      $03, $CA, $82, $B6, $36, $0C, $2A, $83
    DB      $73, $CD, $E0, $BA, $FE, $03, $CA, $8F
    DB      $B6, $36, $2C, $C1, $78, $32, $87, $70
    DB      $79, $32, $88, $70, $3E, $07, $CD, $48
    DB      $AA, $C3, $8C, $B9, $2A, $83, $73, $3A
    DB      $87, $70, $47, $3A, $88, $70, $4F, $C5
    DB      $36, $0D, $CD, $CD, $BA, $FE, $03, $CA
    DB      $B8, $B6, $36, $0D, $2A, $83, $73, $CD
    DB      $F5, $BA, $FE, $03, $CA, $C5, $B6, $36
    DB      $0D, $2A, $83, $73, $CD, $E0, $BA, $FE
    DB      $03, $CA, $D2, $B6, $36, $2D, $2A, $83
    DB      $73, $CD, $05, $BB, $FE, $03, $CA, $DF
    DB      $B6, $36, $2D, $21, $87, $70, $34, $2A
    DB      $83, $73, $2B, $22, $83, $73, $3A, $87
    DB      $70, $FE, $26, $28, $03, $D2, $0B, $B7
    DB      $CD, $CD, $BA, $FE, $03, $CA, $FE, $B6
    DB      $36, $0D, $2A, $83, $73, $CD, $E0, $BA
    DB      $FE, $03, $CA, $0B, $B7, $36, $2D, $21
    DB      $87, $70, $35, $35, $2A, $83, $73, $23
    DB      $23, $22, $83, $73, $3A, $87, $70, $FE
    DB      $01, $DA, $37, $B7, $CD, $CD, $BA, $FE
    DB      $03, $CA, $2A, $B7, $36, $0D, $2A, $83
    DB      $73, $CD, $E0, $BA, $FE, $03, $CA, $37
    DB      $B7, $36, $2D, $C1, $78, $32, $87, $70
    DB      $79, $32, $88, $70, $3E, $07, $CD, $48
    DB      $AA, $C3, $8C, $B9, $3E, $CC, $32, $86
    DB      $70, $CD, $E0, $BA, $06, $2B, $18, $0A
    DB      $3E, $DC, $32, $86, $70, $CD, $CD, $BA
    DB      $06, $0B, $FE, $00, $CA, $77, $B7, $FE
    DB      $01, $CA, $77, $B7, $FE, $0A, $CA, $77
    DB      $B7, $FE, $05, $C2, $8C, $B9, $CB, $7E
    DB      $C2, $8C, $B9, $4F, $3A, $59, $70, $CB
    DB      $77, $79, $20, $0C, $3A, $5C, $70, $CB
    DB      $77, $79, $20, $04, $70, $2A, $83, $73
    DB      $36, $00, $06, $04, $FE, $00, $CA, $BC
    DB      $B8, $06, $03, $FE, $01, $CA, $BC, $B8
    DB      $FE, $05, $CA, $AE, $B7, $FE, $0A, $C2
    DB      $8C, $B9, $3E, $01, $32, $9A, $73, $C3
    DB      $7C, $91, $3E, $06, $CD, $48, $AA, $3A
    DB      $94, $73, $0E, $FF, $D6, $0A, $0C, $D2
    DB      $B8, $B7, $C6, $0A, $F5, $06, $01, $CD
    DB      $65, $94, $F1, $4F, $06, $00, $CD, $65
    DB      $94, $3A, $92, $73, $3C, $32, $92, $73
    DB      $21, $08, $18, $CD, $24, $94, $3A, $92
    DB      $73, $21, $93, $73, $BE, $C2, $8C, $B9
    DB      $FD, $2A, $A6, $73, $FD, $7E, $03, $32
    DB      $94, $73, $21, $05, $18, $CD, $24, $94
    DB      $2A, $AC, $73, $36, $0A, $3A, $56, $70
    DB      $4F, $DB, $BF, $3E, $0F, $D3, $BF, $3E
    DB      $87, $00, $00, $00, $D3, $BF, $3A, $56
    DB      $70, $B9, $C2, $F9, $B7, $3E, $01, $CD
    DB      $48, $AA, $3E, $01, $CD, $C6, $95, $3A
    DB      $56, $70, $4F, $DB, $BF, $3E, $00, $D3
    DB      $BF, $3E, $87, $00, $00, $00, $D3, $BF
    DB      $3A, $56, $70, $B9, $C2, $1B, $B8, $11
    DB      $00, $18, $21, $3D, $B8, $06, $04, $18
    DB      $04, $20, $20, $2E, $2E, $CD, $A9, $92
    DB      $C3, $8C, $B9, $3E, $DC, $32, $86, $70
    DB      $CD, $F5, $BA, $06, $0B, $FE, $04, $C2
    DB      $5E, $B7, $DD, $34, $07, $DD, $7E, $07
    DB      $FE, $06, $DA, $8C, $B9, $DD, $36, $07
    DB      $00, $2B, $3A, $87, $70, $FE, $25, $D2
    DB      $8C, $B9, $7E, $E6, $1F, $FE, $00, $C2
    DB      $8C, $B9, $36, $04, $23, $36, $00, $06
    DB      $0B, $C3, $5E, $B7, $3E, $CC, $32, $86
    DB      $70, $CD, $05, $BB, $06, $2B, $FE, $04
    DB      $C2, $5E, $B7, $DD, $34, $07, $DD, $7E
    DB      $07, $FE, $06, $DA, $8C, $B9, $DD, $36
    DB      $07, $00, $23, $3A, $87, $70, $FE, $02
    DB      $DA, $8C, $B9, $CA, $8C, $B9, $7E, $E6
    DB      $1F, $FE, $00, $C2, $8C, $B9, $36, $24
    DB      $2B, $36, $00, $06, $2B, $C3, $5E, $B7
    DB      $78, $CD, $48, $AA, $C3, $8C, $B9, $BC
    DB      $BC, $BC, $BC, $BC, $C0, $C4, $BC, $14
    DB      $18, $14, $18, $14, $18, $14, $18, $BC
    DB      $BC, $BC, $BC, $BC, $C0, $C4, $BC, $BC
    DB      $C0, $C4, $BC, $14, $18, $14, $18, $3E
    DB      $02, $CD, $C6, $95, $DD, $36, $06, $1C
    DB      $3E, $00, $32, $97, $73, $3E, $01, $32
    DB      $98, $73, $3E, $7F, $32, $97, $73, $DD
    DB      $CB, $06, $56, $CA, $57, $B9, $3A, $98
    DB      $73, $FE, $00, $CA, $26, $B9, $FE, $C8
    DB      $DA, $16, $B9, $DD, $CB, $06, $CE, $C3
    DB      $26, $B9, $3E, $00, $32, $98, $73, $DD
    DB      $CB, $06, $5E, $C2, $32, $B9, $DD, $CB
    DB      $06, $C6, $DD, $CB, $06, $96, $3E, $00
    DB      $CD, $48, $AA, $C3, $57, $B9, $DD, $CB
    DB      $06, $9E, $FD, $2A, $A6, $73, $3A, $88
    DB      $73, $3D, $4F, $06, $00, $FD, $09, $FD
    DB      $7E, $0E, $21, $86, $73, $96, $2A, $A6
    DB      $73, $23, $BE, $C2, $57, $B9, $3E, $0F
    DB      $32, $97, $73, $3E, $26, $32, $87, $70
    DB      $3E, $14, $32, $88, $70, $21, $8B, $70
    DB      $22, $89, $70, $2A, $89, $70, $CB, $6E
    DB      $CB, $AE, $C2, $8C, $B9, $7E, $E6, $1F
    DB      $FE, $04, $DA, $8C, $B9, $FD, $21, $02
    DB      $BA, $CB, $27, $06, $00, $4F, $FD, $09
    DB      $FD, $4E, $00, $FD, $46, $01, $C5, $C9
    DB      $2A, $89, $70, $23, $22, $89, $70, $3A
    DB      $87, $70, $3D, $32, $87, $70, $C2, $67
    DB      $B9, $DD, $CB, $06, $56, $CA, $D4, $B9
    DB      $DD, $CB, $06, $66, $CA, $BC, $B9, $3A
    DB      $98, $73, $FE, $00, $CA, $D4, $B9, $DD
    DB      $CB, $06, $A6, $3E, $10, $CD, $48, $AA
    DB      $CD, $3F, $92, $32, $7C, $70, $E6, $03
    DB      $FE, $03, $C2, $CA, $B9, $3D, $47, $3A
    DB      $7D, $70, $E6, $FC, $B0, $32, $7D, $70
    DB      $3A, $96, $73, $FE, $FF, $CA, $EB, $B9
    DB      $FE, $00, $CA, $EB, $B9, $CD, $3F, $92
    DB      $E6, $07, $C6, $08, $CD, $48, $AA, $3E
    DB      $26, $32, $87, $70, $3A, $88, $70, $3D
    DB      $32, $88, $70, $C2, $67, $B9, $3E, $01
    DB      $21, $FB, $B8, $C3, $A2, $95, $8C, $B9
    DB      $8C, $B9, $8C, $B9, $8C, $B9, $17, $BB
    DB      $17, $BB, $AF, $BD, $C6, $BD, $28, $BA
    DB      $8C, $B9, $8C, $B9, $67, $B5, $91, $BD
    DB      $A0, $BD, $36, $05, $C3, $8C, $B9, $36
    DB      $04, $C3, $8C, $B9, $DD, $CB, $06, $46
    DB      $C2, $1E, $BA, $DD, $CB, $06, $4E, $C2
    DB      $23, $BA, $3A, $98, $73, $3C, $32, $98
    DB      $73, $DD, $CB, $06, $5E, $C2, $77, $BA
    DB      $CD, $CD, $BA, $FE, $02, $DA, $70, $BA
    DB      $2A, $89, $70, $CD, $E0, $BA, $FE, $02
    DB      $DA, $70, $BA, $2A, $89, $70, $CD, $F5
    DB      $BA, $FE, $02, $DA, $70, $BA, $2A, $89
    DB      $70, $CD, $05, $BB, $FE, $02, $DA, $70
    DB      $BA, $C3, $8C, $B9, $DD, $CB, $06, $DE
    DB      $2A, $89, $70, $EB, $3A, $97, $73, $47
    DB      $CD, $3F, $92, $EB, $A0, $FE, $03, $28
    DB      $03, $D2, $8C, $B9, $FE, $00, $CA, $A2
    DB      $BA, $FE, $01, $CA, $AD, $BA, $FE, $02
    DB      $CA, $B8, $BA, $CD, $F5, $BA, $FE, $02
    DB      $DA, $C3, $BA, $C3, $8C, $B9, $CD, $CD
    DB      $BA, $FE, $02, $DA, $C3, $BA, $C3, $8C
    DB      $B9, $CD, $05, $BB, $FE, $02, $DA, $C3
    DB      $BA, $C3, $8C, $B9, $CD, $E0, $BA, $FE
    DB      $02, $DA, $C3, $BA, $C3, $8C, $B9, $36
    DB      $08, $3E, $11, $CD, $48, $AA, $C3, $8C
    DB      $B9, $01, $DA, $FF, $09, $3A, $88, $70
    DB      $FE, $14, $DA, $DC, $BA, $3E, $03, $C9
    DB      $7E, $E6, $1F, $C9, $01, $26, $00, $09
    DB      $3A, $88, $70, $FE, $01, $28, $03, $D2
    DB      $F1, $BA, $3E, $03, $C9, $7E, $E6, $1F
    DB      $C9, $2B, $3A, $87, $70, $FE, $26, $DA
    DB      $01, $BB, $3E, $03, $C9, $7E, $E6, $1F
    DB      $C9, $23, $3A, $87, $70, $FE, $01, $28
    DB      $03, $D2, $13, $BB, $3E, $03, $C9, $7E
    DB      $E6, $1F, $C9, $CB, $7E, $C2, $7E, $BB
    DB      $54, $5D, $CD, $E0, $BA, $FE, $01, $CA
    DB      $8C, $B9, $FE, $00, $CA, $68, $BB, $FE
    DB      $05, $28, $03, $D2, $8C, $B9, $FE, $03
    DB      $CA, $8C, $B9, $62, $6B, $CD, $F5, $BA
    DB      $FE, $00, $C2, $4E, $BB, $CD, $E0, $BA
    DB      $FE, $00, $F5, $CD, $CD, $BA, $F1, $CA
    DB      $74, $BB, $62, $6B, $CD, $05, $BB, $FE
    DB      $00, $C2, $8C, $B9, $CD, $E0, $BA, $FE
    DB      $00, $F5, $CD, $CD, $BA, $F1, $CA, $68
    DB      $BB, $C3, $8C, $B9, $1A, $CB, $EF, $CB
    DB      $FF, $77, $3E, $00, $12, $C3, $8C, $B9
    DB      $1A, $CB, $FF, $77, $3E, $00, $12, $C3
    DB      $8C, $B9, $CB, $BE, $54, $5D, $CD, $E0
    DB      $BA, $FE, $00, $CA, $68, $BB, $47, $1A
    DB      $D9, $E6, $0F, $FE, $04, $CA, $A1, $BB
    DB      $CD, $3F, $92, $E6, $07, $C6, $08, $CD
    DB      $48, $AA, $C3, $A6, $BB, $3E, $02, $CD
    DB      $48, $AA, $D9, $78, $FE, $01, $CA, $8C
    DB      $B9, $FE, $03, $CA, $8C, $B9, $FE, $06
    DB      $DA, $CE, $BB, $FE, $06, $CA, $E5, $BC
    DB      $FE, $07, $CA, $39, $BC, $FE, $0B, $CA
    DB      $39, $BC, $FE, $09, $CA, $03, $BC, $C3
    DB      $8C, $B9, $CB, $7E, $C2, $8C, $B9, $62
    DB      $6B, $CD, $F5, $BA, $FE, $00, $C2, $EB
    DB      $BB, $CD, $E0, $BA, $FE, $00, $C2, $EB
    DB      $BB, $CD, $CD, $BA, $C3, $74, $BB, $62
    DB      $6B, $CD, $05, $BB, $FE, $00, $C2, $8C
    DB      $B9, $CD, $E0, $BA, $FE, $00, $C2, $8C
    DB      $B9, $CD, $CD, $BA

; ============================================================
; TILE / SPRITE BITMAPS  ($BC00 - $BF6F)
; TMS9918A pattern table -- 8 bytes per tile (one byte per row).
; 110 tiles total.
; ============================================================
TILE_BITMAPS:
    DB      $C3, $68, $BB, $3A, $96, $73, $FE, $00 ; tile 0
    DB      $C2, $0F, $BC, $12, $C3, $8C, $B9, $FE ; tile 1
    DB      $FF, $C2, $1A, $BC, $3A, $95, $73, $32 ; tile 2
    DB      $96, $73, $01, $26, $00, $09, $7E, $FE ; tile 3
    DB      $00, $3E, $00, $C2, $0B, $BC, $1A, $FE ; tile 4
    DB      $04, $3E, $00, $12, $CA, $34, $BC, $36 ; tile 5
    DB      $24, $C3, $8C, $B9, $36, $25, $C3, $8C ; tile 6
    DB      $B9, $3A, $87, $70, $47, $3A, $88, $70 ; tile 7
    DB      $4F, $C5, $3D, $32, $88, $70, $22, $83 ; tile 8
    DB      $73, $36, $2C, $CD, $CD, $BA, $FE, $03 ; tile 9
    DB      $CA, $55, $BC, $36, $0C, $2A, $83, $73 ; tile 10
    DB      $CD, $F5, $BA, $FE, $03, $CA, $62, $BC ; tile 11
    DB      $36, $2C, $2A, $83, $73, $CD, $E0, $BA ; tile 12
    DB      $FE, $03, $CA, $6F, $BC, $36, $2C, $2A ; tile 13
    DB      $83, $73, $CD, $05, $BB, $FE, $03, $CA ; tile 14
    DB      $7C, $BC, $36, $2C, $21, $87, $70, $34 ; tile 15
    DB      $2A, $83, $73, $2B, $22, $83, $73, $3A ; tile 16
    DB      $87, $70, $FE, $26, $28, $03, $D2, $A8 ; tile 17
    DB      $BC, $CD, $CD, $BA, $FE, $03, $CA, $9B ; tile 18
    DB      $BC, $36, $0C, $2A, $83, $73, $CD, $E0 ; tile 19
    DB      $BA, $FE, $03, $CA, $A8, $BC, $36, $2C ; tile 20
    DB      $21, $87, $70, $35, $35, $2A, $83, $73 ; tile 21
    DB      $23, $23, $22, $83, $73, $3A, $87, $70 ; tile 22
    DB      $FE, $01, $DA, $D4, $BC, $CD, $CD, $BA ; tile 23
    DB      $FE, $03, $CA, $C7, $BC, $36, $2C, $2A ; tile 24
    DB      $83, $73, $CD, $E0, $BA, $FE, $03, $CA ; tile 25
    DB      $D4, $BC, $36, $2C, $C1, $78, $32, $87 ; tile 26
    DB      $70, $79, $32, $88, $70, $3E, $07, $CD ; tile 27
    DB      $48, $AA, $C3, $8C, $B9, $3A, $87, $70 ; tile 28
    DB      $47, $3A, $88, $70, $4F, $C5, $3D, $32 ; tile 29
    DB      $88, $70, $22, $83, $73, $36, $2D, $CD ; tile 30
    DB      $CD, $BA, $FE, $03, $CA, $01, $BD, $36 ; tile 31
    DB      $0D, $2A, $83, $73, $CD, $F5, $BA, $FE ; tile 32
    DB      $03, $CA, $0E, $BD, $36, $2D, $2A, $83 ; tile 33
    DB      $73, $CD, $E0, $BA, $FE, $03, $CA, $1B ; tile 34
    DB      $BD, $36, $2D, $2A, $83, $73, $CD, $05 ; tile 35
    DB      $BB, $FE, $03, $CA, $28, $BD, $36, $2D ; tile 36
    DB      $21, $87, $70, $34, $2A, $83, $73, $2B ; tile 37
    DB      $22, $83, $73, $3A, $87, $70, $FE, $26 ; tile 38
    DB      $28, $03, $D2, $54, $BD, $CD, $CD, $BA ; tile 39
    DB      $FE, $03, $CA, $47, $BD, $36, $0D, $2A ; tile 40
    DB      $83, $73, $CD, $E0, $BA, $FE, $03, $CA ; tile 41
    DB      $54, $BD, $36, $2D, $21, $87, $70, $35 ; tile 42
    DB      $35, $2A, $83, $73, $23, $23, $22, $83 ; tile 43
    DB      $73, $3A, $87, $70, $FE, $01, $DA, $80 ; tile 44
    DB      $BD, $CD, $CD, $BA, $FE, $03, $CA, $73 ; tile 45
    DB      $BD, $36, $2D, $2A, $83, $73, $CD, $E0 ; tile 46
    DB      $BA, $FE, $03, $CA, $80, $BD, $36, $2D ; tile 47
    DB      $C1, $78, $32, $87, $70, $79, $32, $88 ; tile 48
    DB      $70, $3E, $07, $CD, $48, $AA, $C3, $8C ; tile 49
    DB      $B9, $7E, $C6, $40, $D2, $9C, $BD, $36 ; tile 50
    DB      $00, $C3, $8C, $B9, $77, $C3, $8C, $B9 ; tile 51
    DB      $7E, $C6, $40, $D2, $AB, $BD, $36, $05 ; tile 52
    DB      $C3, $8C, $B9, $77, $C3, $8C, $B9, $CD ; tile 53
    DB      $AD, $B5, $DA, $A0, $B6, $7E, $C6, $40 ; tile 54
    DB      $CD, $DD, $BD, $D6, $40, $CD, $DD, $BD ; tile 55
    DB      $D6, $40, $77, $C3, $8C, $B9, $CD, $AD ; tile 56
    DB      $B5, $DA, $F8, $B5, $7E, $D6, $40, $CD ; tile 57
    DB      $DD, $BD, $C6, $40, $CD, $DD, $BD, $C6 ; tile 58
    DB      $40, $77, $C3, $8C, $B9, $22, $83, $73 ; tile 59
    DB      $57, $E6, $C0, $01, $FB, $BD, $C5, $FE ; tile 60
    DB      $C0, $CA, $F5, $BA, $FE, $00, $CA, $CD ; tile 61
    DB      $BA, $CB, $EA, $FE, $40, $CA, $05, $BB ; tile 62
    DB      $C3, $E0, $BA, $FE, $00, $CA, $07, $BE ; tile 63
    DB      $7A, $CB, $AF, $2A, $83, $73, $C9, $C1 ; tile 64
    DB      $72, $2A, $83, $73, $36, $00, $C3, $8C ; tile 65
    DB      $B9, $7E, $C6, $40, $D2, $9C, $BD, $36 ; tile 66
    DB      $00, $C3, $8C, $B9, $77, $C3, $8C, $B9 ; tile 67
    DB      $7E, $C6, $40, $D2, $AB, $BD, $36, $05 ; tile 68
    DB      $C3, $8C, $B9, $77, $C3, $8C, $B9, $CD ; tile 69
    DB      $AD, $B5, $DA, $A0, $B6, $7E, $C6, $40 ; tile 70
    DB      $CD, $DD, $BD, $D6, $40, $CD, $DD, $BD ; tile 71
    DB      $D6, $40, $77, $C3, $8C, $B9, $CD, $AD ; tile 72
    DB      $B5, $DA, $F8, $B5, $7E, $D6, $40, $CD ; tile 73
    DB      $DD, $BD, $C6, $40, $CD, $DD, $BD, $C6 ; tile 74
    DB      $40, $77, $C3, $8C, $B9, $22, $83, $73 ; tile 75
    DB      $57, $E6, $C0, $01, $FB, $BD, $C5, $FE ; tile 76
    DB      $C0, $CA, $F5, $BA, $FE, $00, $CA, $CD ; tile 77
    DB      $BA, $CB, $EA, $FE, $40, $CA, $05, $BB ; tile 78
    DB      $C3, $E0, $BA, $FE, $00, $CA, $07, $BE ; tile 79
    DB      $DD, $BD, $C6, $40, $77, $C3, $8C, $B9 ; tile 80
    DB      $22, $83, $73, $57, $E6, $C0, $01, $FB ; tile 81
    DB      $BD, $C5, $FE, $C0, $CA, $F5, $BA, $FE ; tile 82
    DB      $00, $CA, $CD, $BA, $CB, $EA, $FE, $40 ; tile 83
    DB      $CA, $05, $BB, $C3, $E0, $BA, $FE, $00 ; tile 84
    DB      $CA, $07, $BE, $FF, $FF, $FF, $FF, $FF ; tile 85
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
    DB      $19, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 96
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 97
    DB      $5A, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 98
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 99
    DB      $98, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 100
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 101
    DB      $76, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 102
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 103
    DB      $9D, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 104
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 105
    DB      $48, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 106
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 107
    DB      $92, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 108
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; tile 109

; ============================================================
; ZERO PADDING  ($BF70 - $BFFF)
; ============================================================
    DB      $92, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
