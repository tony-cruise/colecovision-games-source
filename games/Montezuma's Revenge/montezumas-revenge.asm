; =============================================================================
; MONTEZUMA'S REVENGE 1984 -- ColecoVision  (12 KB ROM, loads at $8000)
; Disassembled by z80cv_disasm.py  |  Annotated with Claude Sonnet 4.6
; Exact byte-match verified vs. montezuma-s-revenge-1984.rom
; =============================================================================
;
; LEGEND / CROSS-REFERENCE INDEX
; All line numbers refer to THIS file.  ROM addresses shown as ($XXXX).
;
; --- HARDWARE / BIOS --------------------------------------------------------
;   BIOS entry points:        lines  125- 174  (EQU block)
;   I/O port defs:            lines  178- 184
;   RAM defs:                 lines  188- 191
;     WORK_BUFFER $7000  JOYSTICK_BUFFER $7005  CONTROLLER_BUFFER $702B  STACKTOP $73B9
;
; --- ROM LAYOUT (12 KB: $8000-$AFFF) ----------------------------------------
;   $8021  CART_ENTRY: JP NMI             line  217
;   $8025  START -- boot entry            line  236
;   ~$8DA2 LOC_8DA2 -- game state mach.  line  834
;   ~$8EB0 DELAY_LOOP_8EB0 -- frame body line  915
;   ~$AA00 NMI handler                   line 2587
;   ~$AE00 SUB_AE00 -- VRAM data writer  line 3084
;
; --- BOOT / INIT SEQUENCE ($8025) -------------------------------------------
;   START ($8025)             line  236  zero $7000-$73FF, SP=$73C0
;                                         SUB_8413: FILL_VRAM $4000 (clear VRAM)
;                                         MODE_1, LOAD_ASCII, INIT/WR_SPR_NM_TBL
;                                         DELAY_LOOP_827F (x2): sprite bitmaps to RAM
;                                         CALL SUB_AE00 ($01): bulk VRAM init
;   SUB_8413 ($8413)          line  510  FILL_VRAM at $0000, length $4000
;   DELAY_LOOP_827F ($827F)   line  426  copy 16 bitmap pairs (AND $AA55) to RAM
;
; --- NMI HANDLER (~$AA00) ---------------------------------------------------
;   CART_ENTRY ($8021)        line  217  JP NMI (all interrupts -> NMI)
;   NMI (~$AA00)              line 2587  saves ALL registers: AF,BC,DE,HL,IX,IY + alts
;                                         $70B1 bit 7: re-entry guard (SET on entry)
;                                         $70B1 bit 3: CALL NZ, SUB_919A (score update)
;                                         $705F bit 1: skip game logic if set (pause)
;                                         $705F bit 3: CALL NZ, SUB_A60B (room renderer)
;                                         $70B1 bit 4: CALL NZ, DELAY_LOOP_8EB0 (frame)
;                                         INC $7097, INC ($7047), $7011 sound cycle
;                                         DEC $7207, WR_SPR_NM_TBL, SUB_AC6D
;                                         READ_REGISTER, RES 7 ($70B1), RETN
;
; --- FRAME GAME BODY ($8EB0) ------------------------------------------------
;   DELAY_LOOP_8EB0 ($8EB0)   line  915  per-frame body, called from NMI bit 4
;     SUB_8308 ($8308)        line  461  render current room tiles to VRAM
;     SUB_A540 ($93C0)        line 2255  tile collision: ladders/ropes/platforms
;     SUB_908F ($908F)        line 1012  item pickup: CPIR $71B2 table (6 bytes)
;     SUB_AE00 ($04)          line 3084  re-render room tiles if $705F bit 5 clear
;
; --- GAME STATE / ROOM TRANSITIONS ($8DA2) ----------------------------------
;   LOC_8DA2 ($8DA2)          line  834  game state dispatch ($7079)
;     if $7079 != $08: SUB_AC1A ($05), LD $7079=$08, $70A9=$70, $7306=$D4
;   SUB_8DC2 ($8DC2)          line  849  DEC $7049 (life counter)
;   LOC_8DD3 ($8DD3)          line  858  update $7300/$7304 player tile X/Y by B/C
;   LOC_929B ($929B)          line 1183  inner-loop end: JP LOC_8DA2
;
; --- ROOM RENDERER / ENEMY PLACEMENT ($A60B) --------------------------------
;   SUB_A60B ($A60B)          line 2311  room setup called from NMI (bit 3 of $705F)
;                                          RES 3, VDP regs, FILL_VRAM $1800
;                                          $70AC==1: fast path; else 25-enemy loop
;   SUB_919A ($919A)          line 1061  SET bit 0 $7000, clear $707A/$7308 block
;
; --- VRAM DATA WRITER -- SUB_AE00 ($AE00) -----------------------------------
;   SUB_AE00 ($AE00)          line 3084  POP HL trick: return addr becomes data ptr
;                                          block: C=page B=count E=addr-lo IY=stride
;                                          CALL SUB_AE2E for each block
;   SUB_AE2E ($AE2E)          line 3125  set VRAM write addr + CALL PUT_VRAM
;   SUB_AE25 ($AE25)          line 3119  set VRAM write addr + CALL FILL_VRAM
;   SUB_AEA7 ($AEA7)          line 3167  tile write loop (B iterations)
;   SUB_A8B7 ($A8B7)          line 2462  VRAM-lock enter: SET $705F bit 1 + INC $70AF
;   SUB_A8C3 ($A8C3)          line 2471  VRAM-lock exit:  DEC $70AF, RES if zero
;
; --- SOUND SYSTEM -----------------------------------------------------------
;   SOUND_WRITE_A067 ($A067)  line 1661  load channel data: fill $7086/$72C0, init $702C
;   SOUND_WRITE_A405 ($A405)  line 2065  enemy placement: write enemy XY to $7304 slots
;   SUB_AC6D ($AC6D)          line 2955  sound sequencer: OUT $FF SN76489A each frame
;   SUB_A92F ($A92F)          line 2499  SN76489A byte writer (4-frame sub-cycle)
;   SUB_AC1A ($AC1A)          line 2896  sound trigger with priority ($702C/$702D)
;   SOUND_WRITE_A548 ($A548)  line 2264  item sprite loader: walk $71B2 table
;   SUB_AF70 ($AF70)          line 3310  BCD score add (IY=$7017 digits)
;   SUB_AEFE ($AEFE)          line 3235  score row renderer
;
; --- KEY RAM VARIABLES -------------------------------------------------------
;   $7000  WORK_BUFFER flags (bit 0=game active  bit 1=VRAM-busy  bit 2=sprite-write)
;   $7005  JOYSTICK_BUFFER (BIOS POLLER raw output)
;   $7011  NMI sub-frame counter (1-4, drives SN76489A 4-frame sound cycle)
;   $7047  room data cursor (16-bit pointer, INC each NMI)
;   $7049  life counter (DEC by SUB_8DC2 on room transition)
;   $702C  sound channel flags (bit 7=active  bit 5=sequence  bit 6=repeat)
;   $702E  sound data pointer     $7030  note duration     $7032  frame counter
;   $705F  game mode flags (bit 1=VRAM-busy  bit 3=room-setup  bit 5=tile-skip)
;   $7079  game state ($08=normal play  other=room transition)
;   $70AC  room entry mode ($01=fast  else=enemy placement)
;   $70AF  VRAM-lock nesting counter
;   $70B1  NMI flags (bit 7=re-entry  bit 3=score  bit 4=game-body)
;   $7097  frame counter     $71A2  animation frame     $71A6  room difficulty
;   $71A7  player speed      $71B2  item table (6 bytes, CPIR by SUB_908F)
;   $7200  sprite bitmap buffer    $7207  flicker counter
;   $7300  player tile X     $7304  secondary X     $7308  enemy data ($20 bytes)
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
JOYSTICK_BUFFER:         EQU $7005
CONTROLLER_BUFFER:       EQU $702B
STACKTOP:                EQU $73B9

FNAME "output\MONTEZUMA-S-REVENGE-1984-NEW.ROM"
CPU Z80

    ORG     $8000

    DW      $AA55                       ; cart magic
    DB      $00, $73
    DB      $E0, $72
    DB      $10, $72
    DW      JOYSTICK_BUFFER             ; BIOS POLLER writes controller state here
    DW      START                       ; start address
    DB      $C9, $00, $00, $C9, $00, $00, $C9, $00
    DB      $00, $C9, $00, $00, $C9, $00, $00, $C9
    DB      $00, $00, $ED, $4D, $00

; =============================================================================
; NMI ENTRY VECTOR -- CART_ENTRY ($8021)
; Cart header points $8021 as the NMI vector.  The handler here is simply:
;   JP NMI
;   DB $0B  (padding byte)
; The real NMI handler is at label NMI (~$AA00).  On every VSYNC the BIOS
; jumps here, which redirects to NMI where all registers are saved and the
; frame game logic runs.
; =============================================================================
CART_ENTRY:
    JP      NMI                             ; JP NMI  -- all VSYNC interrupts routed here
    DB      $0B

; =============================================================================
; BOOT ENTRY -- START ($8025)
; ColecoVision BIOS jumps here after power-on.
;   LD HL,WORK_BUFFER / LD BC,$03FF / LD (HL),$00 / LDIR
;     -> zero-fills $7000-$73FF (RAM workspace)
;   LD SP,$73C0          set stack pointer
;   LD BC,$0100 / CALL WRITE_REGISTER  VDP register 1 = $00 (display off)
;   CALL SUB_8413        FILL_VRAM $4000 bytes at $0000 (clear VRAM)
;   CALL MODE_1          set TMS9918 mode 1
;   LD BC,$0701 / CALL WRITE_REGISTER  VDP register 7 = $01 (border color)
;   CALL LOAD_ASCII      load BIOS font to VRAM
;   CALL DELAY_LOOP_827F (x2) copy sprite bitmaps from ROM to $7200/$7220
;   CALL SUB_AE00        VRAM data writer (POP HL trick -- inline data follows)
;     -> loads all tile patterns, sprite data, room layout to VRAM
; =============================================================================
START:
    LD      HL, WORK_BUFFER                 ; HL = $7000 (WORK_BUFFER -- start of RAM workspace)
    LD      BC, $03FF                       ; BC = $03FF (1023 bytes to zero-fill)
    LD      (HL), $00                       ; (HL) = $00 (seed byte for LDIR)
    PUSH    HL                              ; PUSH HL
    POP     DE                              ; POP DE  -> DE = $7001 (destination = next byte)
    INC     DE                              ; INC DE (DE now points one past HL)
    LDIR                                    ; LDIR: zero-fill $7000-$73FF (1024 bytes)
    LD      SP, $73C0                       ; SP = $73C0 (game stack pointer)
    LD      BC, $0100                       ; BC = $0100 (VDP reg 1, value $00)
    CALL    WRITE_REGISTER                  ; CALL WRITE_REGISTER: disable VDP display
    CALL    SUB_8413                        ; CALL SUB_8413: FILL_VRAM $4000 bytes at $0000 (clear all VRAM)
    CALL    MODE_1                          ; CALL MODE_1: set TMS9918 graphics mode 1
    LD      BC, $0701                       ; BC = $0701 (VDP reg 7, border colour $01)
    CALL    WRITE_REGISTER                  ; CALL WRITE_REGISTER: set border colour
    CALL    LOAD_ASCII                      ; CALL LOAD_ASCII: load BIOS font to VRAM
    LD      HL, $73C7                   ; RAM $73C7
    LD      (HL), $01
    LD      HL, $88C9
    LD      DE, BOOT_UP
    LD      IY, $0002
    LD      A, $00
    CALL    PUT_VRAM
    LD      HL, $73C7                   ; RAM $73C7
    LD      (HL), $00
    LD      A, $08
    CALL    INIT_SPR_NM_TBL                 ; CALL INIT_SPR_NM_TBL: init 8-slot sprite name table
    LD      A, $08
    CALL    WR_SPR_NM_TBL                   ; CALL WR_SPR_NM_TBL: write sprite name table to VRAM
    LD      DE, $7200                       ; DE = $7200 (sprite bitmap RAM destination, first set)
    LD      HL, $86C8                       ; HL = $86C8 (ROM source: first sprite bitmap block)
    CALL    DELAY_LOOP_827F                 ; CALL DELAY_LOOP_827F: copy 16 pairs AND $AA55 -> $7200
    LD      DE, $7220                       ; DE = $7220 (sprite bitmap RAM destination, second set)
    LD      HL, $86A8                       ; HL = $86A8 (ROM source: second sprite bitmap block)
    CALL    DELAY_LOOP_827F                 ; CALL DELAY_LOOP_827F: copy 16 pairs AND $AA55 -> $7220
    LD      A, $01                          ; A = $01 (block selector for inline VRAM data)
    CALL    SUB_AE00                        ; CALL SUB_AE00 ($01): POP HL trick -- inline data follows (bulk VRAM init)
    XOR     B
    ADD     A, (HL)
    INC     (HL)
    INC     B
    XOR     B
    ADD     A, (HL)
    JR      C, LOC_8090
    XOR     B
    ADD     A, (HL)
    INC     A
    INC     B

LOC_8090:
    XOR     B
    ADD     A, (HL)

LOC_8092:
    LD      C, H
    INC     B
    DJNZ    LOC_801D
    LD      C, L
    LD      BC, $8718
    LD      C, A
    LD      BC, $8740
    LD      D, H
    INC     B
    LD      B, B
    ADD     A, A
    LD      E, H
    INC     B
    ADD     A, B
    ADD     A, A
    LD      E, L
    LD      BC, $8788
    LD      E, A
    LD      BC, $8740
    LD      H, H
    INC     B
    LD      D, D
    ADC     A, B
    LD      L, B
    INC     B
    XOR     B
    ADD     A, (HL)
    LD      L, H
    INC     B
    RET     PE
    ADD     A, (HL)
    LD      L, L
    LD      BC, $86F0
    LD      L, A
    LD      BC, $8872
    LD      A, B
    INC     B
    RET     Z
    ADD     A, (HL)
    SBC     A, B
    INC     B
    RET     Z
    ADD     A, (HL)
    SBC     A, H
    INC     B
    LD      ($9D86), HL
    LD      BC, $86F8
    SBC     A, A
    LD      BC, $86C8
    AND     B
    INC     B
    NOP     
    ADD     A, A
    AND     C
    LD      BC, $8708
    AND     E
    LD      BC, $8720
    OR      B
    INC     B
    LD      H, B
    ADD     A, A
    CP      B
    INC     B
    SUB     B
    ADD     A, A
    RET     NZ
    INC     B
    OR      B
    ADD     A, A
    RET     Z
    INC     B
    RET     PE
    ADD     A, A
    CALL    Z, $E804
    ADD     A, A
    RET     NC
    INC     B
    EX      AF, AF'
    ADC     A, B
    RET     NC
    LD      BC, $8810
    JP      NC, $0001
    LD      (HL), D
    CALL    NC, SUB_9208
    ADC     A, B
    INC     C
    INC     B
    JR      LOC_8092
    DB      $10, $04, $36, $88, $14, $04, $DA, $85
    DB      $2C, $04, $00, $00, $CD, $D6, $1F, $CD
    DB      $7F, $1F, $11, $41, $00, $21, $80, $00
    DB      $01, $1A, $00, $3E, $03, $CD, $73, $1F
    DB      $CD, $08, $83, $3E, $A0, $21, $10, $20
    DB      $11, $0E, $00, $CD, $82, $1F, $3E, $02
    DB      $CD, $00, $AE, $AA, $82, $48, $10, $BA
    DB      $82, $8C, $08, $DE, $82, $C6, $15, $F3
    DB      $82, $E6, $15, $00, $00, $21, $C2, $82
    DB      $11, $2A, $01, $01, $0D, $01, $CD, $A7
    DB      $AE, $21, $D0, $82, $11, $4A, $01, $01
    DB      $0D, $01, $CD, $A7, $AE, $21, $93, $82
    DB      $11, $E5, $01, $01, $17, $01, $CD, $A7
    DB      $AE, $01, $C0, $01, $CD, $D9, $1F, $CD
    DB      $76, $1F, $3A, $F0, $73, $FE, $82, $20
    DB      $04, $3E, $01, $18, $0E, $FE, $88, $20
    DB      $04, $3E, $02, $18, $06, $FE, $83, $20
    DB      $E6, $3E, $03, $32, $A6, $71, $01, $80
    DB      $01, $CD, $D9, $1F, $AF, $21, $00, $04
    DB      $11, $AC, $03, $CD, $82, $1F, $AF, $21
    DB      $00, $18, $11, $00, $03, $CD, $82, $1F
    DB      $CD, $DC, $81, $3E, $02, $32, $73, $70
    DB      $32, $74, $70, $32, $12, $70, $32, $68
    DB      $70, $21, $1A, $83, $CD, $3B, $AE, $CD
    DB      $52, $83, $AF, $32, $2C, $70, $32, $36
    DB      $70, $01, $E2, $01, $CD, $D9, $1F, $C3
    DB      $9D, $A5, $0E, $01, $3E, $08, $CD, $92
    DB      $83, $3E, $03, $CD, $00, $AE, $10, $85
    DB      $D2, $04, $B1, $88, $D0, $01, $D0, $87
    DB      $38, $01, $30, $85, $04, $03, $00, $00
    DB      $CD, $14, $83, $0E, $02, $3E, $10, $CD
    DB      $92, $83, $3E, $03, $CD, $00, $AE, $18
    DB      $85, $D2, $03, $10, $85, $D5, $01, $B9
    DB      $88, $D0, $01, $D8, $87, $38, $01, $46
    DB      $85, $04, $03, $70, $86, $A0, $01, $78
    DB      $86, $A3, $01, $00, $00, $CD, $14, $83
    DB      $0E, $05, $3E, $28, $CD, $92, $83, $3E
    DB      $03, $CD, $00, $AE, $20, $85, $D2, $02
    DB      $10, $85, $D4, $02, $B1, $88, $D0, $01
    DB      $E0, $87, $38, $01, $5E, $85, $04, $03
    DB      $70, $86, $A0, $01, $78, $86, $A3, $01
    DB      $00, $00, $CD, $14, $83, $0E, $00, $AF
    DB      $CD, $92, $83, $CD, $08, $83, $3E, $03
    DB      $CD, $00, $AE, $28, $85, $D2, $01, $10
    DB      $85, $D3, $03, $C1, $88, $D0, $01, $E0
    DB      $87, $38, $01, $74, $85, $04, $03, $00
    DB      $00, $CD, $14, $83, $C9

DELAY_LOOP_827F:
    LD      B, $10                          ; B = 16 (loop 16 pairs)

LOC_8281:
    PUSH    BC                              ; save loop counter B
    LD      BC, $AA55                       ; BC = $AA55 (bitmask pair for sprite demultiplexing)
    LD      A, (HL)                         ; A = byte from ROM source
    AND     B                               ; AND B ($AA): keep odd-column bits
    LD      (DE), A                         ; store masked byte to RAM (first of pair)
    INC     DE
    INC     HL                              ; advance ROM source pointer
    LD      A, (HL)                         ; A = next ROM byte
    AND     C                               ; AND C ($55): keep even-column bits
    LD      (DE), A                         ; store second masked byte to RAM
    INC     DE
    INC     HL                              ; advance ROM source
    POP     BC                              ; restore loop counter B
    DJNZ    LOC_8281                        ; DJNZ LOC_8281: loop 16 times
    RET                                     ; RET
    DB      $53, $45, $4C, $45, $43, $54, $20, $4C ; "SELECT L"
    DB      $45, $56, $45, $4C, $20, $20, $20, $31 ; "EVEL   1"
    DB      $2C, $20, $32, $2C, $20, $33, $2E, $50 ; ", 2, 3.P"
    DB      $41, $52, $4B, $45, $52, $20, $42, $52 ; "ARKER BR"
    DB      $4F, $54, $48, $45, $52, $53, $20, $50 ; "OTHERS P"
    DB      $52, $45, $53, $45, $4E, $54, $53, $C4
    DB      $C6, $90, $92, $D4, $D6, $90, $92, $B4
    DB      $B6, $98, $9A, $90, $92, $C5, $C7, $91
    DB      $93, $D5, $D7, $91, $93, $B5, $B7, $99
    DB      $9B, $91, $93, $B0, $B2, $B8, $BA, $B4
    DB      $B6, $CC, $CE, $90, $92, $E4, $E6, $D0
    DB      $D2, $B0, $B2, $80, $82, $27, $C8, $CA
    DB      $B1, $B3, $B9, $BB, $B5, $B7, $CD, $CF
    DB      $91, $93, $E5, $E7, $D1, $D3, $B1, $B3
    DB      $81, $83, $00, $C9, $CB

SUB_8308:
    LD      A, $04                          ; A = $04 (block selector for room tile data)
    CALL    SUB_AE00                        ; CALL SUB_AE00 ($04): POP HL trick -- write current room tiles to VRAM
    LD      E, $84
    NOP     
    INC     E
    NOP     
    NOP     
    RET     
    DB      $21, $7D, $83, $C3, $3B, $AE, $00, $01
    DB      $10, $19, $11, $18, $12, $1B, $13, $1A
    DB      $0C, $1D, $0D, $1C, $0E, $1F, $0F, $1E
    DB      $FF, $D4, $DE, $D8, $E2, $18, $22, $14
    DB      $26, $10, $2A, $2C, $32, $34, $42, $4C
    DB      $52, $54, $5A, $5C, $62, $98, $A6, $6C
    DB      $7E, $9C, $AA, $A0, $AE, $A0, $AE, $B0
    DB      $B6, $B8, $BE, $C0, $C6, $FF, $21, $2D
    DB      $83, $7E, $FE, $FF, $C8, $16, $00, $01
    DB      $02, $00, $5F, $23, $E5, $7E, $6F, $26
    DB      $00, $3E, $01, $D5, $E5, $C5, $F5, $CD
    DB      $6A, $1F, $F1, $C1, $E1, $D1, $13, $13
    DB      $2B, $2B, $CD, $6A, $1F, $E1, $23, $18
    DB      $D8, $01, $03, $A0, $A4, $A1, $A5, $A2
    DB      $A6, $A3, $A7, $04, $BA, $05, $B9, $06
    DB      $B8, $62, $63, $D0, $D1, $FF, $F5, $06
    DB      $04, $CD, $D9, $1F, $F1, $32, $F9, $73
    DB      $CD, $7F, $1F, $3E, $03, $CD, $00, $AE
    DB      $40, $84, $08, $05, $FA, $85, $90, $08
    DB      $3A, $86, $60, $03, $08, $85, $6F, $01
    DB      $9C, $85, $6C, $02, $2A, $86, $74, $02
    DB      $8C, $85, $98, $04, $02, $86, $68, $04
    DB      $02, $86, $70, $04, $02, $86, $78, $04
    DB      $50, $86, $A0, $04, $3A, $86, $A8, $03
    DB      $80, $86, $C0, $06, $80, $86, $C7, $01
    DB      $80, $86, $95, $01, $80, $86, $B0, $05
    DB      $80, $86, $B7, $01, $80, $86, $BB, $05
    DB      $80, $86, $9C, $01, $AC, $85, $10, $02
    DB      $AC, $85, $88, $02, $68, $84, $18, $0A
    DB      $B8, $84, $28, $0A, $BC, $85, $E0, $01
    DB      $CA, $85, $E8, $01, $00, $00, $C9

SUB_840B:
    LD      (HL), $00                       ; (HL) = $00 (seed first byte)
    PUSH    HL                              ; PUSH HL (save base pointer)
    POP     DE                              ; POP DE (DE = HL -- copy source addr)
    INC     DE                              ; INC DE (DE = HL+1, destination one byte ahead)
    LDIR                                    ; LDIR: fill BC bytes with $00 by propagating the seed
    RET     

SUB_8413:
    LD      HL, BOOT_UP                     ; HL = $0000 (BOOT_UP = VRAM start address)
    LD      DE, $4000                       ; DE = $4000 (length: entire 16 KB VRAM)
    XOR     A                               ; A = $00 (fill value: blank)
    CALL    FILL_VRAM                       ; CALL FILL_VRAM: clear all VRAM
    RET     
    DB      $90, $A7, $4A, $8B, $B1, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $20, $90, $E0, $40
    DB      $40, $40, $E0, $90, $20, $20, $40, $90
    DB      $E0, $4A, $90, $60, $40, $40, $00, $00
    DB      $00, $00, $FB, $FB, $FB, $00, $7F, $7F
    DB      $7F, $00, $FB, $FB, $FB, $00, $00, $00
    DB      $00, $00, $F0, $F0, $F0, $00, $F0, $F0
    DB      $F0, $00, $0B, $0B, $0B, $00, $0F, $0F
    DB      $0F, $00, $00, $00, $00, $00, $7F, $7F
    DB      $7F, $00, $38, $7C, $FE, $FE, $EE, $C6
    DB      $C6, $C6, $38, $78, $F8, $F8, $F8, $F8
    DB      $38, $38, $38, $7C, $FE, $FE, $EE, $C6
    DB      $C6, $0E, $38, $7C, $FE, $FE, $FE, $C6
    DB      $06, $1C, $1C, $3C, $3C, $7C, $7C, $EC
    DB      $EC, $CC, $FE, $FE, $FE, $FE, $C6, $E0
    DB      $F8, $3E, $38, $7C, $FE, $FE, $EE, $C0
    DB      $F8, $FC, $FE, $FE, $FE, $FE, $FE, $0E
    DB      $0E, $1E, $38, $7C, $FE, $FE, $EE, $C6
    DB      $EE, $7C, $38, $7C, $FE, $FE, $EE, $C6
    DB      $EE, $7E, $EE, $FE, $FE, $FE, $FE, $FE
    DB      $7C, $38, $38, $38, $38, $38, $FE, $FE
    DB      $FE, $FE, $1E, $3C, $78, $70, $FE, $FE
    DB      $FE, $FE, $1C, $06, $C6, $EE, $FE, $FE
    DB      $7C, $38, $CC, $FE, $FE, $FE, $FE, $FE
    DB      $18, $18, $0E, $C6, $C6, $EE, $FE, $FE
    DB      $7C, $38, $EE, $C6, $EE, $FE, $FE, $FE
    DB      $7C, $38, $1E, $1C, $3C, $38, $78, $78
    DB      $70, $70, $EE, $C6, $EE, $FE, $FE, $FE
    DB      $7C, $38, $3E, $06, $C6, $EE, $FE, $FE
    DB      $7C, $38, $00, $00, $3C, $3C, $7E, $7E
    DB      $00, $00, $08, $06, $07, $07, $0F, $1F
    DB      $7F, $FF, $00, $00, $24, $33, $71, $FD
    DB      $FF, $FF, $00, $00, $01, $81, $F1, $F9
    DB      $FB, $FF, $00, $80, $00, $81, $C2, $E6
    DB      $EF, $FF, $C0, $C0, $3F, $3F, $3F, $3F
    DB      $03, $03, $C0, $C0, $FF, $FF, $FF, $FF
    DB      $03, $03, $C0, $C0, $FC, $FC, $FC, $FC
    DB      $03, $03, $3F, $FF, $FF, $3F, $00, $00
    DB      $03, $03, $FF, $FF, $FF, $FF, $C0, $C0
    DB      $00, $00, $FC, $FF, $FF, $FC, $C0, $C0
    DB      $0C, $0C, $3F, $3F, $3F, $3F, $C0, $C0
    DB      $0C, $0C, $FF, $FF, $FF, $FF, $30, $30
    DB      $03, $03, $FC, $FC, $FC, $FC, $30, $30
    DB      $3F, $3F, $3F, $3F, $0C, $0C, $30, $30
    DB      $FF, $FF, $FF, $FF, $0C, $0C, $30, $30
    DB      $FC, $FC, $FC, $FC, $0C, $0C, $00, $7E
    DB      $81, $BD, $BD, $BD, $BD, $BD, $BD, $BD
    DB      $BD, $81, $7E, $00, $00, $00, $03, $03
    DB      $0F, $0F, $03, $03, $03, $00, $80, $80
    DB      $E0, $E0, $80, $80, $80, $00, $30, $30
    DB      $30, $30, $3F, $30, $30, $30, $0C, $0C
    DB      $0C, $0C, $FC, $0C, $0C, $0C, $7C, $6C
    DB      $6C, $6C, $6C, $7C, $10, $10, $7C, $6C
    DB      $6C, $6C, $6C, $7C, $FF, $66, $C3, $66
    DB      $FF, $00, $00, $00, $FF, $66, $18, $66
    DB      $FF, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $08, $14, $23, $09, $17
    DB      $23, $0B, $17, $21, $00, $00, $00, $00
    DB      $00, $10, $28, $44, $90, $A8, $C4, $D0
    DB      $E8, $C4, $C0, $80, $18, $18, $18, $18
    DB      $0C, $0C, $0C, $0C, $07, $0F, $1C, $1C
    DB      $0F, $03, $03, $01, $E0, $F0, $38, $38
    DB      $F0, $C0, $C0, $80, $01, $01, $03, $01
    DB      $03, $01, $00, $00, $80, $80, $80, $80
    DB      $80, $80, $00, $00, $3C, $1C, $00, $00
    DB      $00, $38, $3C, $3C, $02, $03, $03, $03
    DB      $03, $03, $03, $03, $00, $00, $80, $80
    DB      $80, $80, $80, $80, $00, $2D, $3F, $3F
    DB      $2D, $0C, $0C, $0C, $0C, $0C, $0C, $0C
    DB      $0C, $00, $00, $00, $1F, $0F, $03, $03
    DB      $03, $01, $00, $00, $00, $03, $0C, $0F
    DB      $00, $00, $00, $00, $00, $C0, $E0, $F0
    DB      $30, $F0, $07, $1E, $18, $18, $18, $0C
    DB      $06, $03, $C0, $00, $00, $00, $01, $03
    DB      $0E, $FC, $00, $00, $00, $03, $0C, $3F
    DB      $00, $00, $C0, $00, $00, $00, $04, $0C
    DB      $0C, $FC, $7E, $7E, $7E, $7E, $7E, $7E
    DB      $7E, $7E, $00, $07, $0F, $09, $29, $6F
    DB      $E9, $E9, $00, $E0, $E0, $28, $2C, $EE
    DB      $2F, $2F, $EF, $EF, $EF, $EF, $EF, $EF
    DB      $EF, $EF, $FF, $FF, $7E, $7E, $3C, $3C
    DB      $3C, $3C, $07, $07, $1F, $3F, $38, $08
    DB      $00, $1F, $3F, $0F, $07, $03, $33, $3F
    DB      $3C, $38, $C0, $C0, $F8, $F8, $80, $00
    DB      $00, $E0, $C0, $C0, $C0, $C0, $E0, $E0
    DB      $E0, $E0, $00, $07, $07, $07, $00, $00
    DB      $30, $38, $3C, $1C, $00, $00, $00, $38
    DB      $3C, $1C, $00, $60, $E0, $C0, $00, $B0
    DB      $30, $BC, $3C, $80, $00, $00, $00, $E0
    DB      $F0, $F0, $3F, $0F, $07, $03, $33, $3F
    DB      $07, $07, $C0, $C0, $C0, $C0, $E0, $E0
    DB      $00, $00, $3C, $80, $00, $00, $18, $F8
    DB      $E0, $00, $3C, $1C, $00, $00, $00, $07
    DB      $07, $07, $3C, $80, $00, $00, $00, $00
    DB      $80, $80, $07, $0F, $0F, $3F, $3F, $1F
    DB      $0F, $0F, $C0, $C0, $C0, $E0, $E0, $F0
    DB      $70, $70, $00, $07, $07, $27, $70, $78
    DB      $70, $30, $00, $00, $00, $00, $00, $0F
    DB      $0F, $0F, $00, $60, $E0, $C0, $0C, $3C
    DB      $3C, $B8, $00, $86, $0E, $0E, $0C, $00
    DB      $80, $80, $03, $03, $1F, $1F, $0F, $03
    DB      $02, $01, $39, $3F, $3F, $0F, $0F, $0F
    DB      $0F, $0F, $C0, $C0, $F8, $F8, $F0, $C0
    DB      $40, $80, $98, $FC, $FC, $F0, $F0, $F0
    DB      $F0, $F0, $00, $00, $30, $39, $36, $06
    DB      $01, $00, $00, $00, $00, $00, $00, $0E
    DB      $00, $00, $00, $00, $00, $80, $60, $60
    DB      $80, $00, $0C, $0C, $00, $00, $00, $60
    DB      $70, $70, $1A, $1F, $1F, $0F, $0F, $07
    DB      $01, $00, $40, $FC, $FC, $FC, $FC, $FC
    DB      $F0, $F0, $00, $00, $00, $01, $1A, $01
    DB      $00, $00, $00, $00, $00, $06, $03, $03
    DB      $00, $00, $00, $00, $00, $80, $40, $98
    DB      $00, $00, $00, $00, $00, $00, $00, $60
    DB      $E0, $80, $00, $00, $00, $01, $06, $06
    DB      $01, $00, $00, $00, $00, $00, $34, $3E
    DB      $1E, $0C, $00, $00, $00, $80, $60, $60
    DB      $80, $00, $00, $00, $00, $00, $2C, $7C
    DB      $78, $30, $00, $10, $08, $20, $14, $22
    DB      $08, $42, $00, $00, $24, $10, $28, $08
    DB      $10, $2C, $00, $10, $2C, $30, $3C, $2A
    DB      $18, $6E, $00, $0C, $3C, $78, $70, $60
    DB      $60, $7E, $00, $00, $00, $03, $04, $0B
    DB      $10, $1F, $00, $00, $00, $78, $78, $60
    DB      $60, $60, $60, $00, $00, $00, $80, $40
    DB      $20, $F8, $78, $78, $78, $18, $18, $18
    DB      $1E, $06, $00, $00, $00, $00, $1C, $1C
    DB      $7C, $60, $00, $0F, $1F, $3F, $7E, $7E
    DB      $7F, $73, $37, $1F, $0F, $03, $00, $00
    DB      $00, $00, $00, $00, $80, $C0, $60, $E0
    DB      $F0, $F0, $CC, $CC, $3C, $3C, $F8, $F0
    DB      $00, $00, $00, $00, $1E, $3B, $73, $F3
    DB      $FF, $FF, $F3, $73, $3B, $1E, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $B8, $18
    DB      $B8, $B8, $18, $B8, $00, $00, $00, $00
    DB      $00, $0E, $1F, $1F, $3C, $3B, $34, $2F
    DB      $00, $3C, $3F, $07, $00, $00, $00, $00
    DB      $00, $00, $C0, $F8, $F8, $78, $A0, $D8
    DB      $00, $F8, $F8, $E0, $07, $1F, $7F, $FF
    DB      $FF, $7F, $3F, $FF, $FF, $7F, $3E, $3C
    DB      $18, $00, $00, $00, $E0, $F8, $FC, $FF
    DB      $FF, $FE, $FF, $FF, $FE, $64, $30, $30
    DB      $60, $C0, $C0, $60, $00, $03, $07, $0F
    DB      $1F, $19, $11, $1F, $0F, $0F, $05, $00
    DB      $05, $07, $07, $00, $00, $C0, $E0, $F0
    DB      $F8, $98, $88, $F8, $F0, $F0, $A0, $00
    DB      $A0, $E0, $E0, $00, $01, $01, $03, $07
    DB      $0F, $0F, $1F, $00, $00, $00, $03, $07
    DB      $07, $0F, $1F, $00, $04, $03, $07, $07
    DB      $0F, $1F, $1F, $18, $0C, $04, $06, $1B
    DB      $0C, $08, $0B, $CD, $DC, $92, $3A, $AB
    DB      $70, $3D, $F2, $DD, $88, $3E, $03, $32
    DB      $AB, $70, $CD, $A1, $A7, $CD, $1F, $8C
    DB      $3A, $5F, $70, $CB, $57, $28, $0E, $3A
    DB      $01, $73, $FE, $80, $3E, $86, $38, $02
    DB      $3E, $8C, $32, $EE, $73, $CD, $56, $91
    DB      $21, $13, $89, $3A, $79, $70, $CB, $27
    DB      $CD, $40, $A5, $5E, $23, $56, $EB, $CD
    DB      $3A, $AE, $C3, $E8, $8D, $29, $89, $29
    DB      $89, $2F, $8A, $59, $8C, $02, $8D, $83
    DB      $8A, $83, $8A, $C5, $8C, $7F, $8B, $8E
    DB      $8B, $6E, $8B, $3A, $5B, $70, $FE, $08
    DB      $20, $16, $3A, $58, $70, $FE, $08, $20
    DB      $0F, $01, $00, $F8, $3A, $57, $70, $FE
    DB      $00, $28, $02, $06, $08, $C3, $D4, $8D
    DB      $3A, $57, $70, $CD, $3B, $91, $20, $03
    DB      $C3, $91, $8A, $3A, $EE, $73, $E6, $0F
    DB      $CD, $44, $8C, $AF, $32, $77, $70, $01
    DB      $00, $00, $3A, $EE, $73, $E6, $01, $28
    DB      $43, $21, $58, $70, $7E, $23, $FE, $88
    DB      $20, $3A, $7E, $FE, $89, $20, $35, $CD
    DB      $20, $8B, $0E, $FC, $18, $0A, $CD, $20
    DB      $8B, $0E, $02, $3E, $08, $32, $B2, $70
    DB      $3E, $03, $F5, $78, $FE, $00, $28, $03
    DB      $32, $78, $70, $F1, $32, $79, $70, $FE
    DB      $02, $28, $0A, $3A, $AB, $70, $E6, $01
    DB      $FE, $01, $C4, $37, $8F, $21, $76, $70
    DB      $70, $23, $71, $C9, $3A, $EE, $73, $E6
    DB      $04, $28, $1C, $21, $5B, $70, $7E, $23
    DB      $FE, $10, $20, $05, $7E, $FE, $11, $28
    DB      $BD, $FE, $C4, $20, $0A, $CD, $27, $8B
    DB      $CD, $53, $8C, $3E, $04, $18, $26, $3A
    DB      $EE, $73, $E6, $08, $28, $37, $01, $00
    DB      $FE, $CD, $E3, $90, $30, $1A, $3E, $07
    DB      $CD, $1A, $AC, $3A, $00, $73, $32, $7C
    DB      $70, $3E, $12, $32, $72, $70, $21, $AE
    DB      $93, $0E, $FF, $3E, $02, $C3, $88, $89
    DB      $C5, $CD, $1E, $91, $C1, $38, $04, $3E
    DB      $01, $18, $F2, $3A, $00, $73, $32, $7C
    DB      $70, $3E, $06, $18, $F4, $3A, $EE, $73
    DB      $E6, $02, $28, $0A, $01, $00, $02, $CD
    DB      $E3, $90, $38, $C2, $18, $DA, $01, $00
    DB      $00, $CD, $E3, $90, $38, $B8, $C5, $CD
    DB      $1E, $91, $C1, $D2, $2F, $8C, $C3, $01
    DB      $8A, $16, $04, $21, $72, $70, $7E, $FE
    DB      $00, $28, $09, $35, $7E, $21, $AE, $93
    DB      $CD, $40, $A5, $56, $3A, $76, $70, $FE
    DB      $00, $28, $03, $32, $78, $70, $47, $4A
    DB      $3A, $58, $70, $FE, $90, $CA, $0E, $8B
    DB      $FE, $95, $20, $0A, $3A, $5B, $70, $FE
    DB      $08, $28, $03, $C3, $5B, $8B, $3A, $76
    DB      $70, $CB, $7F, $3A, $59, $70, $20, $03
    DB      $3A, $57, $70, $FE, $08, $20, $04, $AF
    DB      $32, $76, $70, $3A, $77, $70, $CB, $7F
    DB      $C2, $39, $8C, $18, $03, $01, $04, $00
    DB      $C5, $CD, $1E, $91, $C1, $38, $79, $FE
    DB      $D2, $20, $09, $3E, $05, $CD, $1A, $AC
    DB      $3E, $0A, $18, $56, $0E, $00, $3A, $00
    DB      $73, $E6, $0F, $FE, $04, $28, $08, $FE
    DB      $0C, $28, $04, $3D, $0D, $18, $F2, $C5
    DB      $3E, $04, $CD, $1A, $AC, $3A, $A8, $71
    DB      $FE, $0A, $20, $0F, $3A, $5F, $70, $CB
    DB      $57, $28, $08, $CB, $97, $32, $5F, $70
    DB      $CD, $7E, $8E, $3A, $7C, $70, $47, $3A
    DB      $00, $73, $B8, $38, $2D, $90, $C1, $FE
    DB      $1C, $38, $28, $3A, $79, $70, $FE, $05
    DB      $28, $21, $3A, $00, $73, $47, $3A, $04
    DB      $73, $32, $00, $73, $78, $32, $04, $73
    DB      $3E, $09, $F5, $CD, $C2, $8D, $3E, $70
    DB      $32, $A9, $70, $F1, $01, $00, $00, $C3
    DB      $88, $89, $C1, $3E, $01, $C3, $92, $89
    DB      $3A, $5B, $70, $FE, $90, $C2, $57, $8B
    DB      $CD, $44, $8B, $C5, $CD, $27, $8B, $C1
    DB      $3A, $5B, $70, $30, $3C, $3E, $04, $C3
    DB      $31, $8C, $E5, $0E, $0F, $1E, $07, $18
    DB      $05, $E5, $0E, $0C, $1E, $04, $21, $01
    DB      $73, $7E, $E6, $0F, $FE, $08, $30, $01
    DB      $4B, $7E, $E6, $F0, $81, $77, $23, $23
    DB      $23, $23, $77, $E1, $37, $C9, $3A, $76
    DB      $70, $FE, $00, $28, $08, $3A, $72, $70
    DB      $FE, $0F, $30, $01, $C9, $F1, $C3, $39
    DB      $8C, $FE, $95, $20, $F9, $CD, $44, $8B
    DB      $CD, $27, $8B, $01, $04, $00, $3E, $06
    DB      $CD, $1A, $AC, $3E, $05, $C3, $3C, $8C
    DB      $21, $00, $73, $35, $23, $23, $36, $78
    DB      $23, $36, $0E, $AF, $32, $07, $73, $18
    DB      $0F, $3A, $A9, $70, $CB, $57, $20, $08
    DB      $E6, $03, $21, $A6, $93, $CD, $05, $93
    DB      $21, $A9, $70, $35, $F2, $36, $8C, $21
    DB      $49, $70, $7E, $FE, $00, $20, $44, $36
    DB      $06, $AF, $32, $03, $73, $32, $07, $73
    DB      $CD, $D6, $1F, $21, $00, $00, $22, $BD
    DB      $70, $22, $BE, $70, $01, $09, $01, $21
    DB      $09, $94, $11, $6C, $01, $CD, $A7, $AE
    DB      $CD, $1F, $8C, $3A, $EE, $73, $FE, $C0
    DB      $20, $F6, $21, $5F, $70, $CB, $46, $20
    DB      $EF, $CB, $C6, $3A, $A6, $71, $FE, $01
    DB      $20, $F9, $21, $00, $00, $22, $17, $70
    DB      $22, $18, $70, $21, $03, $73, $36, $06
    DB      $2E, $07, $36, $0B, $21, $7D, $70, $7E
    DB      $32, $77, $70, $23, $7E, $32, $76, $70 ; "2wp#~2vp"
    DB      $23, $7E, $32, $79, $70, $23, $7E, $32 ; "#~2yp#~2"
    DB      $78, $70, $23, $7E, $32, $75, $70, $11
    DB      $00, $73, $21, $4B, $70, $01, $08, $00
    DB      $ED, $B0, $CD, $56, $91, $E5, $21, $B1
    DB      $70, $CB, $DE, $CB, $5E, $20, $FC, $E1
    DB      $C9, $CD, $76, $1F, $21, $F0, $73, $7E
    DB      $E6, $C0, $2B, $2B, $B6, $32, $EE, $73
    DB      $C9, $3E, $00, $01, $00, $00, $18, $06
    DB      $01, $00, $00, $3A, $79, $70, $C3, $92
    DB      $89, $3A, $EE, $73, $E6, $05, $FE, $00
    DB      $28, $0B, $C5, $CD, $BD, $91, $C1, $21
    DB      $5F, $70, $CB, $B6, $C9, $21, $5F, $70
    DB      $CB, $F6, $C9, $3A, $B2, $70, $47, $E6
    DB      $0F, $FE, $00, $28, $16, $05, $78, $32
    DB      $B2, $70, $CB, $48, $20, $CA, $01, $02
    DB      $00, $CB, $7F, $28, $03, $01, $FE, $00
    DB      $C3, $39, $8C, $CB, $78, $01, $00, $00
    DB      $C2, $01, $8A, $CD, $3F, $8C, $3A, $59
    DB      $70, $3A, $5B, $70, $CD, $22, $91, $D2
    DB      $01, $8A, $3A, $EE, $73, $E6, $04, $28
    DB      $3A, $01, $01, $00, $18, $DA, $3A, $5F
    DB      $70, $CB, $6F, $28, $0A, $3A, $EE, $73
    DB      $E6, $01, $20, $18, $C3, $55, $8D, $3A
    DB      $EE, $73, $E6, $01, $28, $1D, $18, $0F
    DB      $3A, $EE, $73, $E6, $01, $28, $14, $3E
    DB      $84, $32, $B2, $70, $C3, $36, $8C, $01
    DB      $00, $00, $3A, $00, $73, $32, $7C, $70
    DB      $C3, $01, $8A, $3A, $EE, $73, $E6, $01
    DB      $28, $18, $01, $FF, $00, $3A, $79, $70
    DB      $FE, $04, $20, $0B, $3A, $AB, $70, $E6
    DB      $01, $FE, $00, $20, $02, $0E, $00, $C3
    DB      $39, $8C, $3A, $EE, $73, $E6, $04, $01
    DB      $01, $00, $28, $C8, $CD, $1E, $91, $30
    DB      $EE, $C3, $01, $8A, $CD, $3F, $8C, $CD
    DB      $E3, $90, $30, $40, $3A, $EE, $73, $E6
    DB      $08, $28, $21, $01, $00, $FE, $3A, $5F
    DB      $70, $CB, $6F, $28, $14, $3A, $AC, $70
    DB      $FE, $01, $20, $0D, $21, $5F, $70, $CB
    DB      $DE, $CB, $78, $06, $04, $28, $02, $06
    DB      $FC, $C3, $DC, $89, $3A, $EE, $73, $E6
    DB      $02, $28, $11, $01, $00, $02, $18, $D6
    DB      $3A, $EE, $73, $E6, $01, $28, $02, $0E
    DB      $FE, $C3, $39, $8C, $01, $00, $00, $3A
    DB      $58, $70, $FE, $00, $CA, $9C, $8C, $3A
    DB      $5B, $70, $FE, $D8, $28, $09, $FE, $98
    DB      $28, $05, $FE, $00, $C2, $87, $8C, $3A
    DB      $5F, $70, $CB, $6F, $C2, $3E, $8D, $01
    DB      $00, $00, $3E, $A0, $32, $7C, $70, $3A
    DB      $A5, $71, $C2, $01, $8A, $3E, $06, $C3
    DB      $88, $89, $3A, $57, $70, $CB, $78, $20
    DB      $08, $21, $B0, $71, $34, $34, $3A, $59
    DB      $70, $CD, $94, $A8, $28, $35, $3A, $58
    DB      $70, $FE, $E0, $20, $38, $3A, $00, $70
    DB      $CB, $6F, $20, $31

; =============================================================================
; GAME STATE / ROOM TRANSITION -- LOC_8DA2 ($8DA2)
; Central state handler called at end of each action frame.  Dispatches based
; on $7079 (game state):
;   $7079 != $08: CALL SUB_AC1A (state $05) -- trigger room transition
;                 LD $7079=$08, $70A9=$70, $7306=$D4
;                 CALL SUB_8DC2 (decrement $7049 life counter)
; Continues to LOC_8DD3 which updates $7300/$7304 (player tile X/Y positions)
; by adding carry values from C/B registers.
; Also handles: door open/close, key pickup, skull/enemy collision decrement.
; LOC_929B (line 1018) -> JP LOC_8DA2 is the inner loop re-entry point.
; =============================================================================
LOC_8DA2:
    LD      A, ($7079)                      ; A = ($7079) game state ($08 = normal play)
    CP      $08                             ; CP $08: check normal play state
    JR      Z, LOC_8DD3                     ; JR Z, LOC_8DD3: normal play -- skip room-transition logic
    LD      A, $05                          ; A = $05 (sound effect: room-exit chime)
    CALL    SUB_AC1A                        ; CALL SUB_AC1A: trigger sound effect $05
    LD      A, $08                          ; A = $08
    LD      ($7079), A                      ; ($7079) = $08: set state back to normal play
    LD      A, $70                          ; A = $70
    LD      ($70A9), A                      ; ($70A9) = $70: reset scroll position
    LD      A, $D4                          ; A = $D4
    LD      ($7306), A                      ; ($7306) = $D4: set room-transition column marker
    CALL    SUB_8DC2                        ; CALL SUB_8DC2: DEC life counter ($7049)
    JR      LOC_8DD3                        ; JR LOC_8DD3: fall through to player position update

SUB_8DC2:
    PUSH    HL                              ; PUSH HL
    LD      HL, $7049                       ; HL = $7049 (life counter)
    DEC     (HL)                            ; DEC (HL): player loses one life
    POP     HL                              ; POP HL
    RET                                     ; RET
    DB      $CB, $79, $20, $04, $AF, $32, $76, $70
    DB      $1E, $00

LOC_8DD3:
    LD      B, E                            ; B = E (secondary delta)
    LD      HL, $7300                       ; HL = $7300 (player tile X lo)
    LD      A, (HL)                         ; A = ($7300) current X
    ADD     A, C                            ; ADD A, C: X += C (delta)
    LD      (HL), A                         ; ($7300) = A: store new X
    INC     HL                              ; INC HL -> $7301
    LD      A, (HL)                         ; A = ($7301) X hi byte
    ADD     A, B                            ; ADD A, B: X hi += B
    LD      (HL), A                         ; ($7301) = A: store new X hi
    LD      L, $04                          ; LD L,$04 -> HL = $7304 (secondary X)
    LD      A, (HL)                         ; A = ($7304) secondary X
    ADD     A, C                            ; ADD A, C: += C
    LD      (HL), A                         ; ($7304) = A: store new secondary X
    INC     HL                              ; INC HL -> $7305
    LD      A, (HL)                         ; A = ($7305)
    ADD     A, B                            ; ADD A, B
    LD      (HL), A                         ; ($7305) = A: store new secondary X hi
    RET                                     ; RET
    DB      $21, $76, $70, $5E, $23, $4E, $CD, $80
    DB      $8D, $FE, $04, $38, $05, $FE, $F0, $DA
    DB      $23, $8F, $21, $A8, $71, $34, $CB, $78
    DB      $28, $07, $35, $35, $01, $00, $EC, $18
    DB      $03, $01, $00, $16, $F5, $3A, $A7, $71
    DB      $FE, $09, $38, $63, $3E, $01, $CD, $1A
    DB      $AC, $3A, $79, $70, $FE, $05, $20, $3B
    DB      $AF, $32, $A7, $71, $3E, $08, $32, $A8
    DB      $71, $3A, $5F, $70, $CB, $9F, $CB, $AF
    DB      $CB, $D7, $32, $5F, $70, $C5, $E5, $D5
    DB      $21, $A6, $71, $7E, $FE, $09, $30, $01
    DB      $34, $21, $C0, $70, $01, $C6, $00, $CD
    DB      $0B, $84, $CD, $B7, $A8, $01, $00, $07
    DB      $CD, $D9, $1F, $CD, $C3, $A8, $D1, $E1
    DB      $C1, $18, $1C, $3A, $5F, $70, $CB, $6F
    DB      $CB, $DF, $CB, $EF, $32, $5F, $70, $20
    DB      $08, $3E, $F0, $32, $AC, $70, $CD, $06
    DB      $AC, $F1, $CD, $D4, $8D, $18, $07, $F1
    DB      $CD, $D4, $8D, $CD, $13, $8C, $21, $7D
    DB      $70, $3A, $77, $70, $77, $23, $3A, $76 ; "p:wpw#:v"
    DB      $70, $77, $23, $3A, $79, $70, $77, $23 ; "pw#:ypw#"
    DB      $3A, $78, $70, $77, $3A, $75, $70, $23 ; ":xpw:up#"
    DB      $77, $21, $00, $73, $7E, $32, $7C, $70
    DB      $11, $4B, $70, $01, $08, $00, $ED, $B0
    DB      $E5, $21, $B1, $70, $CB, $E6, $E1, $C9

; =============================================================================
; FRAME GAME BODY -- DELAY_LOOP_8EB0 ($8EB0)
; Called from NMI each frame (when $70B1 bit 4 is set).  Runs all per-frame
; game subsystems:
;   CALL SUB_8308        render current room tiles to VRAM (calls SUB_AE00 $04)
;   load $71A7 (player speed) -> compute animation frame count (B=6..8 x speed)
;   CALL SUB_A540 ($93C0) tile collision update: ladders, ropes, platforms
;   LD DE,$0001 / LD IY,$0007 / CALL SUB_AE2E  write sprite attribute block
;   $71A6 (room difficulty) -> B: cap player max speed
;   $71A7 (current speed) vs B: CALL SUB_908F ($53) -- item pickup check
;   if bit 5 of $705F clear: CALL SUB_AE00 $04 (re-render room tiles)
; =============================================================================
DELAY_LOOP_8EB0:
    CALL    SUB_8308                        ; CALL SUB_8308: render current room tiles to VRAM
    LD      A, ($71A7)                      ; A = ($71A7) player speed (0-8)
    CP      $08                             ; CP $08: is speed at maximum?
    JR      C, LOC_8EBC                     ; JR C, LOC_8EBC: if below max, skip clamp
    LD      A, $08                          ; A = $08 (clamp speed to 8)

LOC_8EBC:
    LD      B, $06                          ; B = $06 (6 animation frames per speed unit)
    LD      C, A                            ; C = A (save clamped speed)

LOC_8EBF:
    ADD     A, C                            ; ADD A, C: accumulate speed -> animation frame count
    DJNZ    LOC_8EBF                        ; DJNZ LOC_8EBF: sum speed * 6 times
    LD      HL, $93C0                       ; HL = $93C0 (tile collision lookup table)
    CALL    SUB_A540                        ; CALL SUB_A540: tile collision update (ladders/ropes/platforms)
    LD      DE, $0001                       ; DE = $0001 (sprite attribute write flag)
    LD      IY, $0007                       ; IY = $0007 (sprite stride / attribute selector)
    LD      A, $04                          ; A = $04 (VRAM block selector)
    CALL    SUB_AE2E                        ; CALL SUB_AE2E: write sprite attribute block to VRAM
    LD      A, ($71A6)                      ; A = ($71A6) room difficulty (0-5)
    NEG                                     ; NEG: negate difficulty
    ADD     A, $09                          ; ADD A,$09: max speed = 9 - difficulty
    LD      B, A                            ; B = A (player speed cap for this room)
    LD      A, ($71A7)                      ; A = ($71A7) current speed
    CP      B                               ; CP B: speed vs cap
    JR      C, LOC_8F03                     ; JR C, LOC_8F03: below cap -- no item-pickup check
    LD      A, $53                          ; A = $53 (item type code)
    CALL    SUB_908F                        ; CALL SUB_908F: CPIR item pickup table $71B2 (6 bytes)
    JR      C, LOC_8F03                     ; JR C, LOC_8F03: no pickup found
    LD      A, ($705F)                      ; A = ($705F) game mode flags
    BIT     5, A                            ; BIT 5, A: tile-skip flag
    JR      NZ, LOC_8F03                    ; JR NZ, LOC_8F03: tile-skip set -- skip re-render
    LD      A, $04                          ; A = $04
    CALL    SUB_AE00                        ; CALL SUB_AE00 ($04): re-render room tiles after pickup
    CALL    $00AB
    INC     BC
    CALL    $10AB
    INC     B
    CALL    $15AB
    INC     B
    NOP     
    NOP     

LOC_8F03:
    RET     
    DB      $21, $A7, $71, $3A, $5F, $70, $CB, $6F
    DB      $C2, $0C, $8E, $35, $C3, $0C, $8E, $21
    DB      $A7, $71, $3A, $5F, $70, $CB, $57, $28
    DB      $02, $23, $34, $34, $C3, $0C, $8E, $01
    DB      $00, $00, $2B, $7E, $FE, $08, $30, $04
    DB      $0E, $A4, $18, $D4, $FE, $AC, $D8, $0E
    DB      $5C, $18, $DC, $3A, $79, $70, $FE, $08
    DB      $D0, $3A, $5B, $70, $E5, $D5, $C5, $21
    DB      $12, $94, $01, $07, $00, $ED, $B1, $20
    DB      $0E, $79, $1E, $01, $FE, $04, $38, $02
    DB      $1E, $FF, $C1, $78, $83, $47, $C5, $C1
    DB      $D1, $E1, $C9, $3A, $79, $70, $FE, $09
    DB      $C8, $21, $11, $70, $7E, $EE, $80, $77
    DB      $CD, $56, $91, $3A, $57, $70, $21, $78
    DB      $70, $CB, $7E, $20, $08, $21, $B0, $71
    DB      $34, $34, $3A, $59, $70, $FE, $9C, $20
    DB      $06, $16, $70, $3E, $5D, $18, $12, $FE
    DB      $B7, $20, $06, $16, $69, $3E, $58, $18
    DB      $08, $FE, $C7, $20, $34, $3E, $62, $16
    DB      $77, $21, $84, $70, $72, $CD, $8F, $90
    DB      $20, $27, $CD, $9C, $90, $2A, $B0, $71
    DB      $01, $60, $00, $37, $3F, $ED, $42, $22
    DB      $B0, $71, $CD, $C8, $90, $3A, $84, $70
    DB      $CD, $F1, $A3, $F5, $3E, $08, $CD, $1A
    DB      $AC, $F1, $21, $00, $03, $CD, $87, $A5
    DB      $C9, $CD, $56, $91, $21, $B0, $71, $34
    DB      $3A, $58, $70, $01, $08, $00, $21, $28
    DB      $94, $ED, $B1, $20, $19, $3A, $4A, $70
    DB      $FE, $00, $C0, $21, $00, $70, $CB, $DE
    DB      $E5, $CD, $A5, $90, $E1, $CB, $9E, $0E
    DB      $00, $1E, $00, $C3, $A2, $8D, $01, $0C
    DB      $00, $21, $30, $94, $ED, $B1, $20, $3E
    DB      $CD, $67, $90, $2B, $7E, $E6, $F8, $FE
    DB      $78, $20, $04, $3E, $58, $18, $08, $FE
    DB      $68, $3E, $62, $20, $02, $3E, $5D, $C5
    DB      $4F, $CD, $6C, $A5, $38, $1E, $F5, $3E
    DB      $02, $CD, $1A, $AC, $F1, $CD, $B7, $A8
    DB      $C1, $C5, $CD, $A5, $90, $3E, $0B, $ED
    DB      $5B, $B0, $71, $CD, $78, $A3, $CD, $A8
    DB      $8E, $CD, $C3, $A8, $C1, $C9, $01, $10
    DB      $00, $21, $18, $94, $ED, $B1, $C0, $79
    DB      $FE, $04, $30, $0C, $CD, $6D, $90, $3E
    DB      $A0, $32, $4A, $70, $3E, $8C, $18, $30
    DB      $FE, $08, $30, $1C, $3E, $44, $CD, $67
    DB      $90, $18, $25, $E5, $21, $50, $00, $18
    DB      $0A, $E5, $21, $00, $01, $18, $04, $E5
    DB      $21, $00, $30, $22, $BD, $70, $E1, $C9
    DB      $FE, $0C, $30, $07, $CD, $73, $90, $3E
    DB      $53, $18, $05, $3E, $91, $CD, $67, $90
    DB      $C3, $1B, $90

SUB_908F:
    LD      HL, $71B2                       ; HL = $71B2 (item pickup table, 6 entries)
    LD      BC, $0006                       ; BC = $0006 (scan 6 bytes)
    CPIR                                    ; CPIR: search for A in [$71B2..$71B7]
    SCF                                     ; SCF: set carry (found)
    RET     Z                               ; RET Z: return carry set if match found
    SCF                                     ; SCF
    CCF                                     ; CCF: clear carry (not found)
    RET                                     ; RET

SUB_909C:
    PUSH    HL                              ; PUSH HL
    POP     DE                              ; POP DE (DE = HL -- source address)
    DEC     DE                              ; DEC DE (DE = HL-1 -- dest one slot before source)
    LDIR                                    ; LDIR: shift item table left by one slot (remove collected item)
    CALL    SOUND_WRITE_A548                ; CALL SOUND_WRITE_A548: update item sprite after pickup
    RET     
    DB      $79, $C6, $04, $D6, $04, $FE, $04, $30
    DB      $FA, $5F, $AF, $47, $CB, $43, $28, $02
    DB      $C6, $01, $CB, $4B, $28, $02, $C6, $20
    DB      $2A, $B0, $71, $4F, $37, $3F, $ED, $42
    DB      $22, $B0, $71, $11, $F2, $72, $21, $B0
    DB      $71, $06, $18, $1B, $1B, $1A, $BE, $20
    DB      $0B, $23, $13, $1A, $BE, $20, $F5, $D5
    DB      $E1, $C3, $A2, $92, $10, $ED, $3A, $57
    DB      $70, $FE, $08, $28, $07, $3A, $59, $70
    DB      $FE, $08, $20, $0E, $3A, $79, $70, $FE
    DB      $04, $28, $07, $3A, $5F, $70, $CB, $57
    DB      $20, $16, $3A, $EE, $73, $E6, $C0, $F5
    DB      $FE, $C0, $20, $0E, $3A, $75, $70, $FE
    DB      $80, $20, $07, $F1, $AF, $32, $75, $70
    DB      $37, $C9, $F1, $32, $75, $70, $37, $3F
    DB      $C9, $21, $5B, $70, $7E, $E5, $C5, $21
    DB      $FF, $93, $01, $0A, $00, $ED, $B1, $C1
    DB      $E1, $28, $1F, $FE, $E8, $28, $14, $CD
    DB      $3B, $91, $28, $19, $37, $C9, $E5, $C5
    DB      $21, $0E, $A0, $01, $05, $00, $ED, $B1
    DB      $C1, $E1, $C9, $3A, $00, $70, $CB, $77
    DB      $37, $C0, $37, $3F, $C9, $3E, $D2, $18
    DB      $F9, $21, $04, $73, $7E, $32, $84, $70
    DB      $23, $7E, $32, $85, $70, $01, $02, $12
    DB      $21, $57, $70, $CD, $6C, $91, $C9, $E5
    DB      $3A, $84, $70, $80, $47, $3A, $85, $70
    DB      $C6, $FF, $81, $CD, $E3, $AF, $01, $DF
    DB      $FF, $09, $EB, $ED, $53, $B0, $71, $21
    DB      $00, $70, $CB, $E6, $CB, $D6, $E1, $01
    DB      $03, $02, $CD, $A7, $AE, $21, $00, $70
    DB      $CB, $A6, $CB, $96, $C9

SUB_919A:
    LD      HL, WORK_BUFFER                 ; HL = WORK_BUFFER ($7000)
    SET     0, (HL)                         ; SET 0, (HL): set bit 0 = game active
    XOR     A                               ; A = $00
    LD      ($707A), A                      ; ($707A) = $00: clear scroll offset
    LD      HL, $7308                       ; HL = $7308 (enemy entity data block)
    LD      BC, $0020                       ; BC = $0020 (32 bytes)
    CALL    SUB_840B                        ; CALL SUB_840B: zero-fill $7308 enemy data ($20 bytes)
    CALL    SOUND_WRITE_A067                ; CALL SOUND_WRITE_A067: load new sound channel data
    RET     

SUB_91B0:
    LD      A, ($7096)                      ; A = ($7096) direction/state counter
    DEC     A                               ; DEC A
    JP      P, LOC_91B9                     ; JP P, LOC_91B9: if still >= 0, keep value
    LD      A, $03                          ; A = $03 (wrap back to 3)

LOC_91B9:                                   ; LOC_91B9:
    LD      ($7096), A                      ; ($7096) = A: store wrapped counter
    RET     
    DB      $21, $AD, $70, $35, $C0, $36, $02, $3A
    DB      $AA, $70, $3D, $F2, $CD, $91, $3E, $07
    DB      $32, $AA, $70, $C9

SUB_91D1:
    SUB     (HL)                            ; SUB (HL): A -= (HL) (compute signed delta)
    JP      P, LOC_91D7                     ; JP P, LOC_91D7: if positive, skip NEG
    NEG                                     ; NEG: make positive (absolute value)

LOC_91D7:                                   ; LOC_91D7:
    CP      B                               ; CP B: |delta| vs threshold B
    RET                                     ; RET (flags: C if within threshold)
    DB      $F5, $F1, $21, $14, $20, $11, $01, $00
    DB      $CD, $25, $AE, $C9, $3A, $AC, $70, $3D
    DB      $FE, $00, $20, $02, $3E, $01, $32, $AC
    DB      $70, $3A, $79, $70, $FE, $08, $D0, $21
    DB      $4A, $70, $7E, $FE, $00, $28, $15, $35
    DB      $FE, $01, $28, $07, $3E, $E0, $CD

SUB_9208:
    EXX                                     ; EXX: swap to alternate BC'/DE'/HL' register set
    SUB     C                               ; SUB C: A -= C (apply delta from alternate C')
    JR      LOC_921F                        ; JR LOC_921F: jump to main collision loop
    DB      $3E, $C0, $CD, $D9, $91, $AF, $32, $4A
    DB      $70, $3E, $8C, $CD, $8F, $90, $20, $03
    DB      $CD, $9C, $90

LOC_921F:
    CALL    SUB_92D1                        ; CALL SUB_92D1: toggle $7098 flip-flag (XOR $80), CALL SUB_91B0 if zero
    LD      A, ($704A)                      ; A = ($704A) collision state flag
    CP      $00                             ; CP $00
    RET     NZ                              ; RET NZ: non-zero collision state -- exit loop
    LD      HL, $7300                       ; HL = $7300 (player tile X)
    LD      A, (HL)                         ; A = ($7300) player X lo
    LD      ($7084), A                      ; ($7084) = A: cache player X lo
    INC     HL                              ; INC HL -> $7301
    LD      A, (HL)                         ; A = ($7301) player X hi
    LD      ($7085), A                      ; ($7085) = A: cache player X hi
    LD      HL, $72C1                       ; HL = $72C1 (room tile/collision data start)
    PUSH    HL                              ; PUSH HL: save scan pointer for LOC_9238 loop

LOC_9238:
    POP     HL                              ; POP HL: restore scan pointer

LOC_9239:                                   ; LOC_9239: -- tile scan loop body
    INC     HL                              ; INC HL: advance to next tile entry (skip type byte)
    LD      C, (HL)                         ; C = (HL): read tile column
    INC     HL                              ; INC HL
    LD      A, (HL)                         ; A = (HL): read tile row
    CP      $FE                             ; CP $FE: end-of-data sentinel?
    RET     Z                               ; RET Z: done -- no collision found
    CP      $FF                             ; CP $FF: enemy entry separator?
    JR      NZ, LOC_9239                    ; JR NZ, LOC_9239: not separator -- keep scanning
    PUSH    HL                              ; PUSH HL: save pointer for this entry
    LD      HL, $7304                       ; HL = $7304 (player secondary X)
    LD      B, $00                          ; B = $00
    ADD     HL, BC                          ; ADD HL, BC: index to player's tile column slot
    LD      A, ($7084)                      ; A = ($7084) player X lo
    LD      B, $0D                          ; B = $0D (half-tile threshold = 13 pixels)
    CALL    SUB_91D1                        ; CALL SUB_91D1: |player X - tile X| vs 13
    JR      NC, LOC_9238                    ; JR NC, LOC_9238: outside X range -- skip this entry
    INC     HL                              ; INC HL: advance to row comparison
    LD      A, ($7085)                      ; A = ($7085) player X hi
    LD      B, $08                          ; B = $08 (row threshold = 8)
    CALL    SUB_91D1                        ; CALL SUB_91D1: |player row - tile row| vs 8
    JR      NC, LOC_9238                    ; JR NC, LOC_9238: outside Y range -- skip
    INC     HL                              ; INC HL
    INC     HL                              ; INC HL: skip to tile type byte
    LD      A, (HL)                         ; A = (HL): read tile action type
    CP      $00                             ; CP $00: empty?
    JR      Z, LOC_9238                     ; JR Z, LOC_9238: empty tile -- skip
    PUSH    HL                              ; PUSH HL: save tile type pointer
    LD      A, $91                          ; A = $91
    CALL    SUB_908F                        ; CALL SUB_908F: CPIR $91 in item table
    JR      NZ, LOC_928F                    ; JR NZ, LOC_928F: not $91 -- try enemy collision
    CALL    SUB_909C                        ; CALL SUB_909C: shift item table (collect item)
    PUSH    AF                              ; PUSH AF
    LD      A, $03                          ; A = $03
    CALL    SUB_AC1A                        ; CALL SUB_AC1A: trigger sound effect $03 (pickup chime)
    POP     AF                              ; POP AF
    POP     HL                              ; POP HL: restore tile type pointer
    LD      A, (HL)                         ; A = (HL): re-read tile type
    LD      (HL), $00                       ; (HL) = $00: clear tile (remove from room)
    LD      HL, $2000                       ; HL = $2000 (score delta: medium gem)
    CP      $0F                             ; CP $0F: check tile type for gem variant
    JR      Z, LOC_9287                     ; JR Z, LOC_9287: type $0F -> medium gem ($2000)
    LD      HL, $3000                       ; HL = $3000 (score delta: large gem)

LOC_9287:
    CALL    SUB_A587                        ; CALL SUB_A587: add score (calls SUB_AF70 + SUB_AEFE)
    POP     HL                              ; POP HL: restore scan pointer
    CALL    SUB_92A2                        ; CALL SUB_92A2: enemy distance check / collision reaction
    RET                                     ; RET

LOC_928F:
    POP     HL                              ; POP HL: discard tile pointer
    POP     HL                              ; POP HL: discard scan pointer
    LD      A, ($71A6)                      ; A = ($71A6) room difficulty
    CP      $05                             ; CP $05
    JR      NC, LOC_929B                    ; JR NC, LOC_929B: difficulty >= 5 -> no reaction
    CALL    SUB_92A2                        ; CALL SUB_92A2: process enemy distance reaction

LOC_929B:
    LD      C, $00                          ; C = $00
    LD      E, $00                          ; E = $00 (clear collision deltas)
    JP      LOC_8DA2                        ; JP LOC_8DA2: back to game state dispatch

SUB_92A2:
    LD      A, ($71A6)                      ; A = ($71A6) room difficulty
    CP      $04                             ; CP $04
    JR      C, LOC_92AF                     ; JR C, LOC_92AF: difficulty < 4 -- always react
    LD      A, (WORK_BUFFER)                ; A = (WORK_BUFFER) check bit 3 (enemy-present flag)
    BIT     3, A                            ; BIT 3, A
    RET     NZ                              ; RET NZ: enemy present -- no reaction (suppress double-hit)

LOC_92AF:
    LD      A, $C0                          ; A = $C0
    DEC     HL                              ; DEC HL: point at tile entry
    SUB     L                               ; SUB L: A = $C0 - L (distance from centre)
    NEG                                     ; NEG: make positive
    SRA     A                               ; SRA A: halve the distance
    CALL    SUB_92BE                        ; CALL SUB_92BE: compute reaction velocity and apply
    LD      C, $00
    LD      E, C
    RET     

SUB_92BE:
    DEC     A                               ; DEC A
    LD      ($71A2), A                      ; ($71A2) = A: store animation frame index
    CALL    SUB_A4B5                        ; CALL SUB_A4B5: speed table lookup -> A
    SLA     A                               ; SLA A: double speed value
    LD      ($71A1), A                      ; ($71A1) = A: store player velocity
    CALL    SUB_A514                        ; CALL SUB_A514: collision flag test
    LD      A, (HL)                         ; A = (HL)
    XOR     D                               ; XOR D: toggle direction bit
    LD      (HL), A                         ; (HL) = A: write updated direction
    RET     

SUB_92D1:
    LD      HL, $7098                       ; HL = $7098 (movement flip-flag)
    LD      A, $80                          ; A = $80
    XOR     (HL)                            ; XOR (HL): toggle bit 7
    LD      (HL), A                         ; (HL) = A: store new flag
    CALL    Z, SUB_91B0                     ; CALL Z, SUB_91B0: if result=0, DEC+wrap $7096 direction counter
    RET     
    DB      $3A, $79, $70, $FE, $01, $20, $32, $3A
    DB      $AA, $70, $CB, $2F, $21, $80, $93, $F5
    DB      $FE, $00, $28, $05, $3E, $09, $CD, $1A
    DB      $AC, $F1, $CD, $69, $93, $30, $0A, $21
    DB      $78, $93, $18, $05, $3A, $AA, $70, $CB
    DB      $2F, $CB, $27, $CD, $40, $A5, $11, $02
    DB      $73, $12, $11, $06, $73, $23, $7E, $12
    DB      $C9, $FE, $02, $20, $0E, $21, $88, $93
    DB      $CD, $69, $93, $38, $03, $21, $8A, $93
    DB      $AF, $18, $DE, $FE, $03, $20, $0F, $21
    DB      $5F, $70, $CB, $76, $28, $03, $CB, $B6
    DB      $C9, $21, $8E, $93, $18, $C6, $FE, $04
    DB      $20, $05, $21, $96, $93, $18, $BD, $FE
    DB      $05, $20, $06, $21, $8C, $93, $AF, $18
    DB      $B8, $FE, $09, $20, $08, $21, $9E, $93
    DB      $3A, $96, $70, $18, $AC, $FE, $08, $C8
    DB      $FE, $0A, $C8, $AF, $C3, $E8, $92, $F5
    DB      $3A, $76, $70, $18, $04, $F5, $3A, $78
    DB      $70, $CB, $7F, $20, $03, $F1, $37, $C9
    DB      $F1, $37, $3F, $C9, $34, $98, $6C, $A0
    DB      $34, $98, $34, $9C, $40, $A4, $7C, $AC
    DB      $40, $A4, $40, $A8, $4C, $B0, $50, $B4
    DB      $64, $C8, $54, $B8, $58, $BC, $54, $B8
    DB      $58, $BC, $5C, $C0, $60, $C4, $5C, $C0
    DB      $60, $C4, $68, $CC, $68, $D0, $68, $CC
    DB      $68, $D0, $D8, $D4, $D8, $D4, $E0, $DC
    DB      $E0, $DC, $04, $03, $03, $01, $01, $01
    DB      $01, $00, $00, $00, $00, $00, $FF, $FF
    DB      $FF, $FF, $FB, $FB, $F8, $4F, $F0, $F0
    DB      $80, $80, $F9, $AF, $4A, $A0, $A0, $F0
    DB      $F0, $A9, $B5, $4B, $B0, $B0, $50, $50
    DB      $B9, $BC, $4B, $B0, $B0, $C0, $C0, $B9
    DB      $BD, $4B, $B0, $B0, $E0, $E0, $B9, $EC
    DB      $4E, $E0, $E0, $C0, $C0, $E9, $ED, $4E
    DB      $E0, $E0, $D0, $D0, $E9, $A7, $4A, $A0
    DB      $A0, $70, $70, $A9, $E7, $4E, $E0, $E0
    DB      $70, $70, $E9, $08, $10, $11, $05, $04
    DB      $06, $B9, $B8, $BA, $C4, $47, $41, $4D
    DB      $45, $00, $4F, $56, $45, $52, $04, $05
    DB      $06, $B9, $B8, $BA, $9B, $9A, $97, $96
    DB      $63, $62, $D1, $D0, $D9, $99, $D8, $98
    DB      $AF, $A9, $AE, $A8, $A3, $A2, $A1, $A0
    DB      $A6, $A7, $A4, $A5, $6B, $6A, $69, $68
    DB      $7B, $7A, $79, $78, $73, $72, $71, $70 ; "{zyxsrqp"
    DB      $08, $B0, $BB, $C0, $B7, $9C, $C7, $0B
    DB      $00, $00, $02, $02, $02, $00, $00, $02
    DB      $06, $10, $13, $15, $0B, $1B, $17, $FF
    DB      $FF, $FF, $FF, $FF, $02, $00, $00, $02
    DB      $06, $10, $FF, $FF, $1F, $21, $24, $42
    DB      $44, $49, $4E, $53, $58, $5D, $62, $7C ; "DINSX]b|"
    DB      $81, $67, $6E, $75, $FF, $FF, $FF, $FF
    DB      $86, $8A, $88, $41, $95, $6A, $95, $7B
    DB      $95, $DA, $95, $EA, $95, $F8, $95, $94
    DB      $96, $AC, $96, $FF, $96, $09, $97, $3B
    DB      $97, $4B, $97, $57, $97, $C1, $97, $DD
    DB      $97, $16, $98, $22, $98, $AC, $98, $BF
    DB      $98, $C3, $98, $17, $99, $26, $99, $B4
    DB      $99, $27, $9A, $6C, $9A, $75, $9A, $87
    DB      $9A, $95, $9A, $1B, $9B, $23, $9B, $33
    DB      $9B, $49, $9B, $5E, $9B, $6E, $9B, $77
    DB      $9B, $BD, $9B, $BF, $9B, $C7, $9B, $F0
    DB      $9B, $FB, $9B, $08, $9C, $0E, $9C, $14
    DB      $9C, $23, $9C, $31, $9C, $3A, $9C, $7C
    DB      $9C, $92, $9C, $A7, $9C, $B2, $9C, $BF
    DB      $9C, $D4, $9C, $DF, $9C, $E8, $9C, $F5
    DB      $9C, $F9, $9C, $02, $9D, $11, $9D, $15
    DB      $9D, $19, $9D, $25, $9D, $3F, $9D, $51
    DB      $9D, $5B, $9D, $66, $9D, $78, $9D, $88
    DB      $9D, $96, $9D, $B1, $9D, $BC, $9D, $C9
    DB      $9D, $D3, $9D, $DF, $9D, $09, $9E, $1F
    DB      $9E, $25, $9E, $2E, $9E, $3D, $9E, $4F
    DB      $9E, $55, $9E, $5C, $9E, $5E, $9E, $72
    DB      $9E, $78, $9E, $8C, $9E, $92, $9E, $9B
    DB      $9E, $A2, $9E, $CB, $9E, $D4, $9E, $E4
    DB      $9E, $3C, $9F, $7F, $9F, $86, $9F, $91
    DB      $9F, $96, $9F, $9C, $9F, $A0, $9F, $B0
    DB      $9F, $C0, $9F, $D1, $9F, $01, $00, $20
    DB      $0F, $96, $49, $03, $95, $54, $03, $82
    DB      $4C, $86, $03, $00, $01, $18, $83, $E0
    DB      $20, $01, $0A, $02, $17, $0A, $1D, $17
    DB      $03, $1F, $01, $18, $03, $00, $01, $18
    DB      $80, $6F, $35, $99, $50, $06, $02, $A0
    DB      $D4, $43, $20, $20, $0F, $58, $2F, $0F
    DB      $21, $B9, $27, $F5, $90, $31, $70, $04
    DB      $2C, $04, $07, $31, $04, $09, $10, $05
    DB      $2B, $A3, $2B, $BC, $42, $20, $C1, $42
    DB      $40, $B8, $40, $61, $64, $85, $00, $03
    DB      $58, $E3, $08, $44, $A7, $05, $82, $40
    DB      $36, $82, $E3, $71, $86, $88, $03, $82
    DB      $AB, $11, $82, $98, $84, $87, $96, $04
    DB      $83, $8B, $0E, $01, $42, $3D, $3B, $42
    DB      $34, $91, $42, $56, $21, $42, $77, $16
    DB      $42, $2E, $41, $9E, $CE, $09, $9E, $ED
    DB      $0B, $9F, $EE, $09, $58, $2F, $08, $58
    DB      $3A, $0B, $8E, $2C, $08, $66, $65, $31
    DB      $67, $90, $31, $20, $31, $D0, $3F, $0E
    DB      $60, $56, $60, $4B, $60, $4E, $28, $EA
    DB      $02, $0F, $25, $00, $AF, $24, $43, $20
    DB      $20, $0F, $02, $AA, $14, $20, $B7, $58
    DB      $2F, $0F, $30, $80, $08, $0F, $09, $8D
    DB      $4B, $0D, $42, $20, $BA, $40, $A1, $31
    DB      $40, $45, $29, $40, $48, $27, $82, $60
    DB      $24, $42, $8B, $37, $42, $AE, $91, $42
    DB      $8E, $81, $82, $4E, $21, $42, $2E, $31
    DB      $42, $39, $71, $42, $5F, $1D, $83, $E0
    DB      $20, $01, $5C, $41, $03, $5C, $61, $03
    DB      $5C, $81, $03, $5C, $C1, $03, $5C, $E1
    DB      $03, $9C, $01, $03, $9C, $21, $03, $9C
    DB      $62, $02, $9C, $82, $02, $9C, $A2, $02
    DB      $9C, $C2, $02, $5C, $25, $02, $5C, $28
    DB      $02, $5E, $4C, $04, $5E, $53, $02, $5E
    DB      $6B, $0B, $5E, $96, $01, $5F, $6C, $04
    DB      $5F, $73, $02, $5F, $90, $03, $5F, $95
    DB      $01, $5F, $E8, $02, $9F, $08, $02, $5E
    DB      $C8, $02, $9E, $C5, $02, $42, $DC, $31
    DB      $A0, $6A, $A0, $6E, $62, $A5, $62, $CE
    DB      $64, $D0, $65, $D2, $69, $D5, $8B, $6C
    DB      $59, $3A, $0B, $A7, $BD, $31, $95, $31
    DB      $F2, $31, $39, $90, $28, $FC, $0B, $A4
    DB      $02, $BD, $14, $43, $20, $20, $0F, $58
    DB      $2F, $0F, $27, $E6, $27, $F7, $10, $25
    DB      $BB, $00, $BD, $14, $11, $02, $BD, $14
    DB      $08, $0F, $0B, $42, $20, $4F, $55, $24
    DB      $07, $56, $35, $07, $42, $3C, $4F, $57
    DB      $29, $04, $42, $CD, $63, $54, $33, $04
    DB      $02, $BE, $14, $83, $E0, $1E, $01, $9E
    DB      $CB, $0A, $9F, $EB, $0A, $82, $AE, $43
    DB      $5E, $AD, $06, $5F, $CD, $06, $42, $6F
    DB      $25, $80, $59, $44, $58, $3C, $0D, $A5
    DB      $59, $A6, $2F, $10, $80, $59, $22, $98
    DB      $AF, $03, $A6, $59, $20, $A4, $00, $BE
    DB      $14, $02, $A2, $14, $50, $00, $A2, $14
    DB      $90, $0B, $BB, $3E, $06, $30, $20, $30
    DB      $D0, $10, $02, $BD, $14, $43, $27, $19
    DB      $09, $47, $47, $08, $82, $32, $E6, $83
    DB      $C0, $20, $02, $03, $80, $01, $12, $59
    DB      $23, $0C, $26, $AC, $2A, $A9, $2A, $B1
    DB      $29, $B8, $29, $BB, $82, $CE, $41, $98
    DB      $CF, $02, $10, $00, $AC, $22, $26, $A6
    DB      $82, $CF, $22, $50, $98, $CF, $02, $08
    DB      $0F, $09, $43, $20, $20, $0F, $0B, $B7
    DB      $22, $B1, $71, $30, $90, $0B, $A7, $43
    DB      $20, $20, $0F, $28, $F5, $20, $B9, $20
    DB      $A6, $32, $30, $8D, $E6, $14, $4E, $95
    DB      $04, $8D, $33, $04, $4D, $DA, $06, $4E
    DB      $F1, $07, $8E, $75, $04, $00, $4C, $84
    DB      $08, $0F, $06, $44, $20, $05, $42, $A0
    DB      $1B, $82, $E1, $61, $82, $F9, $61, $07
    DB      $FC, $04, $03, $CD, $13, $01, $02, $ED
    DB      $16, $42, $6E, $51, $42, $90, $17, $82
    DB      $4D, $31, $42, $FB, $41, $02, $A9, $1C
    DB      $82, $06, $32, $82, $25, $41, $02, $B4
    DB      $C2, $4A, $62, $0C, $0A, $A7, $0B, $58
    DB      $6E, $07, $98, $7C, $04, $59, $0B, $09
    DB      $0B, $F2, $8B, $1B, $82, $7B, $41, $42
    DB      $5F, $1E, $24, $4D, $64, $15, $71, $34
    DB      $71, $29, $90, $31, $93, $08, $0F, $09
    DB      $02, $A0, $55, $02, $BB, $55, $04, $A5
    DB      $03, $07, $B8, $03, $43, $20, $20, $0F
    DB      $58, $2F, $0F, $20, $A9, $20, $B6, $71
    DB      $60, $02, $A0, $71, $02, $C0, $41, $02
    DB      $E0, $2A, $45, $82, $02, $43, $C0, $19
    DB      $01, $44, $E2, $02, $82, $01, $11, $82
    DB      $20, $13, $83, $80, $20, $04, $43, $2A
    DB      $16, $01, $47, $5B, $02, $42, $5D, $39
    DB      $82, $7C, $41, $58, $2C, $05, $58, $D6
    DB      $06, $98, $8F, $04, $08, $0F, $09, $90
    DB      $30, $42, $3E, $0B, $02, $BE, $14, $58
    DB      $2F, $0F, $30, $20, $30, $30, $04, $A0
    DB      $05, $42, $20, $1D, $42, $C1, $21, $83
    DB      $C0, $20, $02, $82, $77, $13, $82, $9A
    DB      $12, $82, $9D, $32, $42, $3F, $1B, $44
    DB      $4A, $02, $46, $68, $02, $42, $8C, $36
    DB      $42, $C1, $21, $45, $C3, $02, $87, $04
    DB      $02, $82, $26, $81, $42, $4E, $14, $42
    DB      $4A, $22, $42, $CF, $81, $47, $3C, $03
    DB      $4E, $35, $08, $42, $2B, $B1, $58, $32
    DB      $05, $58, $C1, $06, $5E, $8C, $02, $5E
    DB      $AB, $01, $5E, $C4, $07, $5F, $AC, $02
    DB      $5F, $CB, $03, $5F, $E5, $08, $9F, $06
    DB      $06, $98, $CF, $02, $8D, $91, $03, $9F
    DB      $D5, $02, $9F, $D8, $02, $9F, $BB, $02
    DB      $9E, $B5, $02, $9E, $B8, $02, $9E, $9B
    DB      $02, $9C, $98, $02, $59, $FB, $03, $59
    DB      $B9, $03, $31, $80, $31, $82, $31, $28
    DB      $60, $59, $60, $9B, $90, $02, $AE, $14
    DB      $3E, $07, $A0, $2F, $A0, $59, $00, $BE
    DB      $14, $00, $A2, $14, $10, $82, $AF, $23
    DB      $90, $0B, $BB, $3E, $0B, $71, $80, $5F
    DB      $A0, $60, $9F, $00, $C0, $42, $20, $61
    DB      $42, $40, $36, $82, $00, $52, $82, $40
    DB      $81, $82, $60, $B1, $82, $80, $D1, $82
    DB      $A0, $F1, $82, $B1, $F1, $82, $93, $D1
    DB      $82, $75, $B1, $82, $58, $81, $82, $1B
    DB      $52, $42, $5D, $36, $42, $3A, $61, $83
    DB      $C0, $20, $02, $42, $CF, $51, $42, $F1
    DB      $11, $82, $0C, $31, $82, $13, $21, $82
    DB      $4D, $31, $82, $51, $21, $82, $8F, $11
    DB      $5E, $83, $1A, $5C, $26, $14, $27, $E4
    DB      $90, $28, $FA, $3E, $0F, $31, $A0, $24
    DB      $A5, $21, $A7, $0B, $AB, $20, $B0, $58
    DB      $2F, $0F, $08, $0F, $09, $03, $A0, $01
    DB      $13, $42, $21, $21, $42, $C1, $21, $82
    DB      $61, $21, $82, $81, $14, $82, $C2, $22
    DB      $83, $E4, $1C, $01, $82, $DC, $41, $82
    DB      $9E, $22, $82, $7D, $31, $02, $BF, $1E
    DB      $00, $BF, $14, $42, $3D, $21, $42, $DD
    DB      $21, $4E, $23, $05, $4E, $C3, $05, $8E
    DB      $63, $05, $4D, $2A, $05, $4D, $CA, $05
    DB      $8D, $6A, $05, $4E, $31, $05, $4E, $D1
    DB      $05, $8E, $71, $05, $4D, $38, $05, $4D
    DB      $D8, $05, $8D, $78, $05, $5C, $68, $02
    DB      $5C, $88, $02, $9C, $08, $02, $9C, $28
    DB      $02, $5C, $76, $02, $5C, $96, $02, $9C
    DB      $16, $02, $9C, $36, $02, $5C, $2F, $02
    DB      $5C, $CF, $02, $9C, $6F, $02, $9E, $83
    DB      $1A, $9E, $A2, $1C, $9F, $A3, $1A, $9F
    DB      $C4, $18, $A5, $05, $60, $6C, $60, $73
    DB      $A4, $19, $50, $71, $50, $90, $31, $E0
    DB      $04, $4C, $03, $07, $51, $03, $08, $0F
    DB      $09, $42, $27, $B1, $44, $20, $04, $42
    DB      $60, $1C, $83, $E0, $20, $01, $98, $4F
    DB      $06, $82, $43, $35, $42, $CD, $2A, $82
    DB      $2A, $26, $42, $AA, $B1, $82, $51, $51
    DB      $82, $71, $24, $42, $5F, $1D, $42, $39
    DB      $71, $9E, $61, $02, $9F, $81, $02, $9F
    DB      $A1, $02, $9F, $C1, $02, $9E, $4B, $02
    DB      $9F, $6B, $02, $9F, $8B, $02, $9F, $AB
    DB      $02, $9F, $CB, $02, $9F, $D3, $0C, $9E
    DB      $B3, $0C, $69, $D4, $6A, $D1, $5C, $E7
    DB      $02, $22, $A1, $62, $DB, $60, $4B, $60
    DB      $4E, $59, $3A, $0A, $59, $3D, $09, $0A
    DB      $A4, $0D, $31, $71, $71, $70, $30, $95
    DB      $90, $30, $E0, $08, $0F, $09, $42, $20
    DB      $11, $43, $3F, $02, $0F, $83, $E0, $20
    DB      $01, $83, $61, $1E, $01, $43, $21, $1E
    DB      $01, $42, $C1, $91, $42, $D2, $D1, $85
    DB      $A1, $02, $86, $8C, $03, $85, $91, $03
    DB      $86, $BD, $02, $9F, $C3, $09, $9F, $D4
    DB      $09, $9E, $A2, $0B, $9E, $B3, $0B, $58
    DB      $25, $05, $58, $39, $05, $98, $6F, $05
    DB      $59, $6E, $07, $70, $66, $90, $70, $60
    DB      $3E, $03, $67, $90, $A7, $4B, $90, $30
    DB      $A2, $03, $80, $20, $14, $00, $AD, $64
    DB      $58, $2F, $0F, $22, $AD, $22, $AF, $22
    DB      $B1, $31, $80, $3E, $0B, $08, $0F, $09
    DB      $58, $2F, $0F, $02, $AA, $15, $02, $B5
    DB      $15, $9F, $A0, $20, $9F, $C0, $20, $9E
    DB      $80, $20, $42, $2F, $21, $03, $A0, $01
    DB      $12, $83, $E0, $20, $01, $82, $61, $24
    DB      $85, $A3, $02, $82, $85, $13, $82, $88
    DB      $13, $82, $8B, $13, $86, $AC, $02, $82
    DB      $6E, $44, $82, $D2, $31, $82, $75, $14
    DB      $82, $78, $24, $82, $BA, $11, $82, $DA
    DB      $31, $82, $7D, $24, $42, $3F, $1E, $42
    DB      $21, $31, $42, $44, $11, $82, $41, $11
    DB      $82, $3B, $21, $42, $BD, $11, $42, $84
    DB      $11, $42, $C5, $21, $82, $02, $21, $42
    DB      $89, $21, $42, $CB, $11, $82, $2A, $11
    DB      $42, $EE, $11, $42, $72, $21, $42, $D4
    DB      $21, $42, $56, $21, $42, $99, $11, $82
    DB      $19, $11, $42, $FB, $21, $42, $3C, $31
    DB      $98, $6F, $05, $9F, $A4, $01, $9F, $AC
    DB      $01, $23, $A2, $D1, $0C, $A2, $02, $3E
    DB      $13, $0B, $B9, $21, $BB, $31, $70, $3E
    DB      $0B, $0B, $A8, $0B, $AF, $0B, $B6, $20
    DB      $B1, $20, $AD, $32, $20, $32, $30, $3F
    DB      $16, $62, $C3, $60, $4F, $60, $51, $69
    DB      $CB, $5C, $27, $07, $30, $65, $31, $61
    DB      $90, $71, $10, $30, $10, $3E, $0B, $58
    DB      $2F, $0F, $02, $8A, $15, $02, $95, $15
    DB      $23, $AF, $11, $00, $AA, $14, $11, $0C
    DB      $AF, $02, $3E, $1B, $08, $0F, $09, $20
    DB      $A2, $20, $A5, $22, $BB, $22, $BD, $02
    DB      $BF, $14, $3E, $0E, $08, $0F, $09, $30
    DB      $90, $31, $52, $08, $0F, $09, $4E, $EB
    DB      $0A, $43, $20, $20, $01, $42, $40, $1A
    DB      $82, $80, $33, $82, $A3, $22, $83, $E0
    DB      $20, $01, $83, $47, $12, $01, $82, $9D
    DB      $33, $82, $BB, $22, $42, $5F, $1A, $42
    DB      $E9, $31, $42, $F4, $31, $A9, $6A, $A9
    DB      $75, $64, $6D, $64, $71, $9C, $41, $05
    DB      $9C, $5A, $05, $58, $29, $06, $58, $35
    DB      $06, $58, $EF, $03, $98, $EF, $01, $31
    DB      $50, $3E, $0F, $3E, $19, $20, $AE, $20
    DB      $B1, $30, $80, $03, $A0, $20, $13, $01
    DB      $A4, $18, $04, $41, $41, $1E, $04, $41
    DB      $E1, $1E, $04, $08, $0F, $09, $58, $26
    DB      $05, $58, $D5, $05, $98, $6F, $05, $60
    DB      $4C, $27, $EB, $67, $89, $A7, $33, $90
    DB      $0B, $AD, $0B, $B2, $3E, $17, $02, $9F
    DB      $25, $32, $80, $32, $86, $32, $D6, $3E
    DB      $17, $02, $A0, $14, $71, $80, $71, $86
    DB      $71, $12, $71, $D2, $3E, $13, $30, $20
    DB      $30, $C0, $3E, $0B, $32, $10, $32, $80
    DB      $3F, $10, $18, $0F, $09, $60, $84, $60
    DB      $46, $31, $70, $30, $72, $30, $88, $43
    DB      $20, $20, $0F, $02, $A0, $14, $08, $0F
    DB      $09, $31, $50, $32, $D0, $3F, $2B, $08
    DB      $0F, $09, $31, $10, $27, $E5, $04, $4C
    DB      $03, $07, $51, $03, $03, $94, $0C, $14
    DB      $42, $13, $15, $42, $2D, $61, $42, $AA
    DB      $A1, $42, $D1, $3A, $82, $49, $61, $82
    DB      $6D, $45, $82, $E1, $C1, $02, $80, $C1
    DB      $42, $21, $61, $03, $A0, $01, $12, $08
    DB      $0F, $09, $98, $4F, $06, $59, $23, $0A
    DB      $59, $25, $0B, $9E, $A1, $0C, $9F, $C1
    DB      $0C, $30, $10, $31, $65, $90, $31, $51
    DB      $3E, $22, $02, $A0, $84, $29, $AB, $29
    DB      $B4, $A9, $6C, $A9, $73, $65, $6D, $65
    DB      $71, $71, $53, $98, $EF, $01, $3E, $22
    DB      $2A, $AB, $2A, $B4, $AA, $6C, $AA, $73
    DB      $64, $6D, $64, $71, $98, $EF, $01, $31
    DB      $20, $31, $79, $3E, $0B, $02, $94, $C5
    DB      $22, $AD, $20, $B0, $71, $20, $3E, $0B
    DB      $02, $A0, $14, $2A, $B9, $58, $2F, $0F
    DB      $90, $30, $40, $43, $20, $20, $0F, $40
    DB      $4A, $B5, $08, $0F, $09, $70, $50, $58
    DB      $2A, $06, $58, $34, $06, $58, $EF, $09
    DB      $3E, $22, $66, $6F, $31, $75, $71, $73 ; ">"fo1uqs"
    DB      $90, $30, $49, $3F, $16, $03, $B2, $0E
    DB      $12, $90, $30, $10, $3E, $10, $18, $0F
    DB      $09, $60, $50, $31, $70, $31, $92, $31
    DB      $18, $3E, $13, $30, $30, $3E, $0B, $58
    DB      $2F, $10, $31, $80, $31, $70, $3E, $0B
    DB      $08, $0F, $09, $00, $BF, $14, $02, $B8
    DB      $14, $30, $40, $70, $80, $3E, $31, $70
    DB      $40, $3E, $0B, $30, $40, $3E, $22, $A9
    DB      $67, $A9, $77, $64, $6D, $64, $71, $31
    DB      $49, $3E, $22, $29, $AB, $29, $B4, $25
    DB      $AD, $25, $B1, $A5, $6D, $A5, $71, $65
    DB      $6C, $65, $72, $31, $99, $31, $83, $31
    DB      $85, $31, $C0, $3E, $22, $2A, $AB, $2A
    DB      $B4, $AA, $67, $AA, $78, $64, $6C, $64
    DB      $72, $71, $83, $31, $49, $3E, $32, $27
    DB      $F6, $02, $0F, $29, $90, $30, $20, $3E
    DB      $23, $90, $27, $E7, $0B, $A6, $0B, $A9
    DB      $30, $90, $3E, $13, $02, $A0, $24, $23
    DB      $A3, $21, $BB, $21, $A5, $31, $90, $32
    DB      $90, $51, $23, $A3, $3E, $27, $00, $A0
    DB      $14, $02, $BF, $14, $71, $30, $71, $12
    DB      $71, $B2, $71, $36, $3E, $16, $62, $DB
    DB      $60, $4A, $60, $4E, $71, $70, $31, $71 ; "`J`Nqp1q"
    DB      $30, $85, $3E, $05, $80, $6C, $14, $82
    DB      $53, $31, $8B, $73, $8B, $74, $8B, $75
    DB      $65, $CE, $A0, $77, $31, $F2, $31, $10
    DB      $30, $99, $90, $30, $D0, $3E, $17, $71
    DB      $10, $90, $31, $32, $31, $D2, $71, $A6
    DB      $3E, $0B, $08, $0F, $09, $0B, $A8, $0B
    DB      $AC, $30, $20, $30, $30, $3E, $37, $72
    DB      $20, $32, $30, $90, $02, $A0, $14, $3E
    DB      $02, $18, $0F, $06, $66, $62, $30, $20
    DB      $90, $30, $A0, $3E, $0B, $31, $50, $70
    DB      $30, $02, $BE, $24, $20, $B2, $20, $B6
    DB      $20, $BA, $10, $23, $AF, $00, $B2, $E4
    DB      $02, $A0, $24, $20, $A4, $20, $A8, $20
    DB      $AC, $50, $00, $A3, $A4, $11, $0C, $AF
    DB      $02, $91, $00, $A0, $34, $3E, $13, $43
    DB      $E2, $1D, $08, $5C, $23, $1A, $42, $2E
    DB      $46, $08, $0F, $09, $5F, $D2, $02, $31
    DB      $30, $31, $A0, $3E, $0B, $32, $30, $32
    DB      $A0, $3E, $0B, $08, $0F, $09, $27, $EC
    DB      $27, $F1, $3E, $22, $29, $AB, $29, $B4
    DB      $66, $6C, $64, $72, $82, $EF, $21, $71
    DB      $43, $3E, $22, $29, $AB, $29, $B4, $AA
    DB      $67, $AA, $77, $64, $6C, $65, $72, $31
    DB      $20, $71, $43, $3E, $45, $30, $40, $30 ; " qC>E0@0"
    DB      $20, $3E, $32, $70, $40, $90, $0B, $A9
    DB      $3E, $0F, $3E, $0B, $02, $A0, $24, $20
    DB      $A3, $20, $A5, $20, $A7, $31, $20, $90
    DB      $0B, $A7, $0B, $A9, $0B, $AB, $3E, $0B
    DB      $30, $70, $27, $F5, $3E, $2A, $08, $0F
    DB      $09, $00, $B1, $14, $A0, $52, $A2, $55
    DB      $82, $CF, $22, $30, $98, $90, $30, $62
    DB      $3E, $2B, $31, $20, $31, $30, $3E, $13
    DB      $27, $F8, $90, $0B, $AF, $27, $E5, $3E
    DB      $0B, $08, $0F, $09, $71, $30, $0B, $A4
    DB      $0B, $A5, $0B, $A6, $0B, $A7, $0B, $AB
    DB      $0B, $AC, $0B, $AD, $0B, $AE, $0B, $AF
    DB      $0B, $B0, $0B, $B1, $0B, $B2, $0B, $B3
    DB      $0B, $B7, $0B, $B8, $0B, $B9, $0B, $BA
    DB      $43, $20, $20, $0F, $90, $31, $50, $3E
    DB      $13, $08, $0F, $09, $2B, $AC, $2B, $B4
    DB      $3F, $5B, $66, $F5, $2B, $BB, $6B, $5B
    DB      $50, $31, $10, $31, $36, $90, $30, $A2
    DB      $07, $A9, $07, $04, $B0, $06, $42, $20
    DB      $41, $42, $C0, $71, $82, $60, $91, $42
    DB      $3B, $51, $42, $D8, $81, $82, $76, $A1
    DB      $9E, $80, $09, $9E, $A9, $01, $9E, $CA
    DB      $01, $9E, $EB, $01, $9E, $96, $0A, $9E
    DB      $B5, $01, $9E, $D4, $01, $9E, $F3, $01
    DB      $9F, $A0, $09, $9F, $C0, $0A, $9F, $E0
    DB      $0B, $9F, $B6, $0B, $9F, $D5, $0C, $9F
    DB      $F4, $0D, $60, $8F, $60, $CF, $A0, $0F
    DB      $A0, $4F, $A0, $8F, $60, $CB, $60, $D3
    DB      $A0, $0C, $A0, $12, $A0, $4D, $A0, $51
    DB      $66, $E9, $2B, $A3, $2A, $B6, $29, $BA
    DB      $6B, $43, $4B, $F1, $42, $E0, $34, $43
    DB      $20, $20, $01, $43, $C0, $20, $01, $83
    DB      $60, $20, $01, $83, $E0, $20, $01, $47
    DB      $5B, $02, $42, $5D, $34, $47, $FA, $02
    DB      $42, $FC, $44, $87, $98, $03, $82, $9B
    DB      $54, $9F, $C0, $1B, $9E, $A0, $1A, $58
    DB      $26, $05, $58, $D6, $05, $9C, $65, $0C
    DB      $50, $30, $50, $3E, $13, $27, $F0, $90
    DB      $70, $30, $3E, $13, $27, $EF, $20, $AE
    DB      $20, $B0, $90, $30, $A0, $3E, $57, $90
    DB      $30, $50, $3E, $0A, $2B, $AB, $2B, $B3
    DB      $3E, $13, $31, $40, $3E, $13, $08, $0F
    DB      $09, $03, $B3, $0D, $13, $31, $60, $31
    DB      $40, $90, $0B, $AA, $3E, $13, $08, $0F
    DB      $09, $03, $A0, $0D, $13, $30, $80, $30
    DB      $A0, $90, $0B, $B4, $3E, $0B, $02, $BF
    DB      $14, $22, $B1, $22, $B3, $22, $B5, $20
    DB      $B7, $20, $B9, $20, $BB, $01, $00, $01
    DB      $08, $01, $00, $02, $88, $89, $10, $11
    DB      $02, $00, $00, $00, $00, $01, $90, $C4
    DB      $01, $95, $01, $E0, $01, $06, $05, $04
    DB      $01, $BA, $B9, $B8, $01, $E8, $02, $08
    DB      $08, $FF, $D2, $D3, $D4, $D5, $D2, $D3
    DB      $D4, $D5, $D2, $D3, $D4, $D5, $D2, $D3
    DB      $D4, $D5, $D2, $D3, $D4, $D5, $D2, $D3
    DB      $D4, $D5, $D2, $D3, $D4, $D5, $38, $01
    DB      $38, $02, $98, $D8, $99, $D9, $02, $A8
    DB      $AE, $A9, $AF, $02, $96, $97, $9A, $9B
    DB      $02, $D0, $D1, $62, $63, $02, $78, $79
    DB      $7A, $7B, $02, $68, $69, $6A, $6B, $02
    DB      $70, $71, $72, $73, $02, $B0, $B7, $B1
    DB      $B2, $B3, $B3, $02, $BB, $9C, $BC, $BD
    DB      $BE, $BE, $02, $C0, $C7, $C1, $C2, $C3
    DB      $C3, $02, $A0, $A1, $A2, $A3, $02, $A5
    DB      $A4, $A7, $A6, $0C, $2C, $0F, $0C, $0F
    DB      $0C, $02, $60, $AE, $61, $AF, $02, $74
    DB      $75, $6C, $6D               ; "ulm"

SOUND_WRITE_A067:
    CALL    SUB_AE77                        ; CALL SUB_AE77: blank VDP display (INC $70B3)
    CALL    TURN_OFF_SOUND                  ; CALL TURN_OFF_SOUND: silence all SN76489A channels
    LD      HL, $7086                       ; HL = $7086 (sound channel 1 data slot)
    PUSH    HL                              ; PUSH HL
    POP     DE                              ; POP DE (DE = $7086)
    LD      BC, $000E                       ; BC = $000E (14 bytes: 7 sound channel slots x 2)
    LD      (HL), $FF                       ; (HL) = $FF (seed: mark all slots free)
    INC     DE                              ; INC DE
    LDIR                                    ; LDIR: fill $7086..$7093 with $FF (clear channel data)
    LD      BC, $001E                       ; BC = $001E (30 bytes)
    LD      HL, $72C0                       ; HL = $72C0 (room tile/collision data buffer)
    PUSH    HL                              ; PUSH HL
    POP     DE                              ; POP DE
    LD      (HL), $00                       ; (HL) = $00
    INC     DE                              ; INC DE
    LDIR                                    ; LDIR: zero-fill $72C0..$72DD (clear tile-collision buffer)
    LD      A, $FE                          ; A = $FE (end-of-table sentinel)
    LD      (DE), A                         ; (DE) = $FE: write sentinel at end
    DEC     DE                              ; DEC DE
    LD      (DE), A                         ; (DE) = $FE: write second sentinel (two-byte guard)
    CALL    SUB_A1DF                        ; CALL SUB_A1DF: fill VRAM tile-name table ($18A0 + $260 bytes)
    CALL    SUB_A4B5                        ; CALL SUB_A4B5: speed table lookup -> A
    LD      ($7015), A                      ; ($7015) = A: store current speed in RAM
    CALL    SUB_A4CE                        ; CALL SUB_A4CE: copy 4-byte speed-record to $7190
    XOR     A                               ; A = $00
    LD      ($71A2), A                      ; ($71A2) = $00: clear animation frame index
    LD      A, ($71A5)                      ; A = ($71A5) (tile difficulty level)
    SLA     A                               ; SLA A: double level
    LD      ($71A1), A                      ; ($71A1) = A: store doubled level as initial velocity

LOC_A0A4:
    LD      A, ($7190)                      ; A = ($7190) lo byte of speed record pointer
    LD      HL, $7192                       ; HL = $7192
    CP      (HL)                            ; CP (HL): compare lo vs current pointer
    JR      Z, LOC_A0AF                     ; JR Z, LOC_A0AF: lo bytes match -> check hi
    JR      C, LOC_A115                     ; JR C, LOC_A115: lo < current -> process note

LOC_A0AF:
    LD      A, ($7191)                      ; A = ($7191) hi byte
    INC     HL                              ; INC HL -> $7193
    CP      (HL)                            ; CP (HL): compare hi bytes
    JR      NZ, LOC_A115                    ; JR NZ, LOC_A115: hi differs -> process note

LOC_A0B6:
    LD      A, ($7194)                      ; A = ($7194) note duration countdown
    CP      $00                             ; CP $00: done?
    JR      Z, LOC_A0E7                     ; JR Z, LOC_A0E7: duration expired -> check end-condition
    DEC     A                               ; DEC A
    LD      ($7194), A                      ; ($7194) = A: tick duration counter
    LD      A, ($7195)                      ; A = ($7195)
    CP      $00                             ; CP $00
    JR      Z, LOC_A0CB                     ; JR Z, LOC_A0CB: zero -> skip pending note
    CALL    SUB_AB29                        ; CALL SUB_AB29: send pending note byte to SN76489A

LOC_A0CB:
    POP     AF
    LD      ($7195), A                  ; RAM $7195
    LD      B, $04
    LD      HL, $7193                   ; RAM $7193

LOC_A0D4:
    POP     AF
    LD      (HL), A
    DEC     HL
    DJNZ    LOC_A0D4

LOC_A0D9:
    LD      A, $02

LOC_A0DB:
    LD      C, A
    LD      B, $00
    LD      HL, ($7190)                 ; RAM $7190
    ADD     HL, BC
    LD      ($7190), HL                 ; RAM $7190
    JR      LOC_A0A4

LOC_A0E7:
    LD      A, ($705F)                      ; A = ($705F) game mode flags
    BIT     2, A                            ; BIT 2, A: tile-data-ready flag
    JR      Z, LOC_A0F5                     ; JR Z, LOC_A0F5: not set -> advance to next item sprite
    LD      A, ($71A8)                      ; A = ($71A8)
    CP      $0A                             ; CP $0A
    JR      NZ, LOC_A0F8                    ; JR NZ, LOC_A0F8: not $0A -> skip SOUND_WRITE_A548

LOC_A0F5:
    CALL    SOUND_WRITE_A548                ; CALL SOUND_WRITE_A548: item sprite update (end-of-sequence)

LOC_A0F8:
    LD      A, ($707A)                  ; RAM $707A
    SLA     A
    SLA     A
    LD      C, A
    LD      A, $80
    SUB     C
    LD      H, $00
    LD      L, A
    LD      B, $00
    DB      $EB
    LD      HL, $1B08
    ADD     HL, BC
    XOR     A
    CALL    FILL_VRAM
    CALL    SUB_AE83
    RET     

LOC_A115:
    LD      HL, ($7190)                 ; RAM $7190
    LD      A, (HL)
    LD      ($7196), A                  ; RAM $7196
    AND     $3E
    CP      $3E
    JR      Z, LOC_A191
    LD      BC, $0003
    INC     HL
    LD      DE, $7197                   ; RAM $7197
    LDIR    
    CALL    SUB_A4F8
    LD      A, ($7196)                  ; RAM $7196
    AND     $3F
    LD      B, $02
    CP      $10
    JP      Z, LOC_A1BE
    CP      $11
    JP      Z, LOC_A1BC
    CP      $0B
    JP      Z, LOC_A2E3
    CP      $20
    JR      C, LOC_A175
    CP      $29
    JR      C, LOC_A15D
    CP      $30
    JR      C, LOC_A169
    LD      A, ($7194)                  ; RAM $7194
    CP      $00
    JR      NZ, LOC_A0D9
    CALL    SOUND_WRITE_A405

LOC_A15A:
    JP      LOC_A0D9

LOC_A15D:
    LD      A, ($7194)                  ; RAM $7194
    CP      $00
    JR      NZ, LOC_A15A
    CALL    SUB_A36A
    JR      LOC_A15A

LOC_A169:
    LD      A, ($7194)                  ; RAM $7194
    CP      $00
    JR      NZ, LOC_A15A
    CALL    SUB_A3AB
    JR      LOC_A15A

LOC_A175:
    LD      HL, $A20A
    LD      A, ($7196)                  ; RAM $7196
    SRL     A
    SRL     A
    AND     $07
    SLA     A
    LD      B, $00
    LD      C, A
    ADD     HL, BC
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    DB      $EB
    CALL    SUB_AE3A
    JP      LOC_A0DB

LOC_A191:
    LD      B, $04
    LD      HL, $7190                   ; RAM $7190

LOC_A196:
    LD      A, (HL)
    INC     HL
    PUSH    AF
    DJNZ    LOC_A196
    LD      A, ($7195)                  ; RAM $7195
    PUSH    AF
    LD      HL, ($7190)                 ; RAM $7190
    LD      B, $00
    LD      C, A
    ADD     HL, BC
    INC     HL
    LD      A, (HL)
    PUSH    AF
    LD      A, ($7196)                  ; RAM $7196
    AND     $01
    LD      ($7195), A                  ; RAM $7195
    LD      HL, $7194                   ; RAM $7194
    INC     (HL)
    POP     AF
    CALL    SUB_A4CE
    JP      LOC_A0A4

LOC_A1BC:
    LD      B, $06

LOC_A1BE:
    LD      A, ($7196)                  ; RAM $7196
    AND     $C0
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    ADD     A, B
    LD      B, A
    LD      A, ($71A6)                  ; RAM $71A6
    CP      B
    JR      C, LOC_A1DC
    LD      A, $01
    JP      LOC_A0DB

LOC_A1DC:
    JP      LOC_A0B6

SUB_A1DF:
    LD      B, $03
    LD      DE, $0003
    LD      HL, $18A0
    LD      DE, $0260
    XOR     A
    CALL    FILL_VRAM
    LD      A, ($705F)                  ; RAM $705F
    BIT     2, A
    JR      Z, LOC_A1FB
    LD      A, ($71A8)                  ; RAM $71A8
    CP      $0A
    RET     NZ

LOC_A1FB:
    LD      HL, $1800
    LD      DE, $00A0
    LD      A, $08
    CALL    FILL_VRAM
    CALL    SUB_AA5D
    RET     
    DB      $1A, $A2, $7C, $A2, $F0, $A2, $18, $A3
    DB      $1A, $A2, $7C, $A2, $0E, $A3, $40, $A3
    DB      $CD, $E3, $A4, $3A, $9A, $71, $21, $D2
    DB      $9F, $06, $00, $4F, $09, $7E, $32, $9B
    DB      $71, $3A, $96, $71, $E6, $01, $FE, $00
    DB      $28, $0D, $21, $98, $71, $56, $23, $5E
    DB      $3E, $04, $32, $A0, $71, $18, $16, $3A
    DB      $98, $71, $5F, $CB, $3F, $CB, $3F, $CB
    DB      $3F, $CB, $3F, $57, $7B, $E6, $0F, $5F
    DB      $3E, $03, $32, $A0, $71, $21, $9D, $71
    DB      $72, $23, $73, $3A, $9E, $71, $47, $C5
    DB      $3A, $9D, $71, $47, $0E, $01, $ED, $5B
    DB      $B0, $71, $21, $9B, $71, $CD, $A7, $AE
    DB      $CD, $09, $A5, $C1, $3A, $A0, $71, $10
    DB      $E6, $C9, $CD, $E3, $A4, $3A, $9A, $71
    DB      $21, $D4, $9F, $06, $00, $4F, $09, $7E
    DB      $32, $9B, $71, $3A, $98, $71, $57, $5F
    DB      $3A, $96, $71, $E6, $10, $FE, $00, $28
    DB      $02, $CB, $23, $CD, $57, $A2, $CD, $E3
    DB      $A4, $3A, $9A, $71, $21, $D2, $9F, $06
    DB      $00, $4F, $09, $7E, $32, $9B, $71, $CD
    DB      $D5, $A2, $21, $98, $71, $35, $28, $18
    DB      $56, $3A, $96, $71, $E6, $10, $CB, $3F
    DB      $CB, $3F, $CB, $3F, $CB, $3F, $3C, $5F
    DB      $CD, $57, $A2, $CD, $D5, $A2, $18, $E2
    DB      $3E, $03, $C9, $3A, $96, $71, $E6, $01
    DB      $C8, $2A, $B0, $71, $23, $22, $B0, $71
    DB      $C9

LOC_A2E3:
    LD      A, $04
    LD      ($7198), A                  ; RAM $7198
    CALL    SUB_A2F0
    LD      A, $02
    JP      LOC_A0DB

SUB_A2F0:
    CALL    SUB_A4E3
    LD      A, ($719A)                  ; RAM $719A
    LD      HL, $9FD1
    LD      B, $00
    LD      C, A
    ADD     HL, BC
    LD      A, (HL)
    LD      C, A
    INC     HL
    LD      A, ($7198)                  ; RAM $7198
    LD      B, A

SUB_A304:
    LD      DE, ($71B0)                 ; RAM $71B0

SUB_A308:
    CALL    SUB_AA96
    LD      A, $03
    RET     
    DB      $CD, $F0, $A2, $06, $00, $09, $06, $01
    DB      $18, $F0, $CD, $E3, $A4, $3A, $9A, $71
    DB      $21, $D2, $9F, $06, $00, $4F, $09, $ED
    DB      $5B, $B0, $71, $0E, $01, $3A, $98, $71
    DB      $47, $CD, $A7, $AE, $23, $05, $CD, $A7
    DB      $AE, $23, $06, $01, $CD, $A7, $AE, $3E
    DB      $03, $C9, $CD, $E3, $A4, $3A, $9A, $71
    DB      $21, $D1, $9F, $06, $00, $4F, $09, $7E
    DB      $FE, $FF, $20, $08, $3A, $98, $71, $4F
    DB      $06, $01, $18, $05, $4F, $3A, $98, $71
    DB      $47, $23, $ED, $5B, $B0, $71, $CD, $A7
    DB      $AE, $3E, $03, $C9

SUB_A36A:
    CALL    SUB_A514
    JR      C, LOC_A391
    CALL    SUB_A4E3
    CALL    SUB_A3A0
    LD      A, ($719A)                  ; RAM $719A

SUB_A378:
    LD      HL, $9FD2
    CALL    SUB_A540
    LD      BC, $0102
    CALL    SUB_AEA7
    INC     HL
    INC     HL
    PUSH    BC
    LD      BC, $0020
    DB      $EB
    ADD     HL, BC
    DB      $EB
    POP     BC
    CALL    SUB_AEA7

LOC_A391:
    LD      A, $02
    RET     

SUB_A394:
    LD      A, ($71A2)                  ; RAM $71A2
    SLA     A
    LD      HL, $72C0                   ; RAM $72C0
    CALL    SUB_A540
    RET     

SUB_A3A0:
    CALL    SUB_A394
    LD      DE, ($71B0)                 ; RAM $71B0
    LD      (HL), E
    INC     HL
    LD      (HL), D
    RET     

SUB_A3AB:
    CALL    SUB_A514
    JR      C, LOC_A3E9
    CALL    SUB_A4E3
    CALL    SUB_A3A0
    LD      A, ($719A)                  ; RAM $719A
    LD      HL, $9FD2
    LD      B, $00
    LD      C, A
    ADD     HL, BC
    LD      BC, $0301
    CALL    SUB_A304
    INC     HL
    LD      BC, $0060
    DB      $EB
    ADD     HL, BC
    DB      $EB
    LD      BC, $0101
    CALL    SUB_AEA7
    JR      LOC_A3E6

SUB_A3D5:
    LD      HL, $9FD2
    LD      B, $00
    LD      C, A
    ADD     HL, BC
    LD      BC, $0102
    LD      DE, ($71B0)                 ; RAM $71B0
    CALL    SUB_AEA7

LOC_A3E6:
    JP      LOC_A391

LOC_A3E9:
    CALL    SUB_A4E3
    LD      A, ($719A)                  ; RAM $719A
    ADD     A, $02
    CALL    SUB_A3D5
    INC     HL
    INC     HL
    PUSH    BC
    LD      BC, $0020
    DB      $EB
    ADD     HL, BC
    DB      $EB
    POP     BC
    LD      B, $03
    CALL    SUB_A308
    JR      LOC_A3E6

SOUND_WRITE_A405:
    CALL    SUB_A514                        ; CALL SUB_A514: collision flag test (returns C if occupied)
    JR      C, LOC_A3E6                     ; JR C, LOC_A3E6: occupied -> abort
    LD      HL, $707A                       ; HL = $707A (scroll offset / enemy placement counter)
    INC     (HL)                            ; INC (HL): advance placement counter
    LD      A, (HL)                         ; A = (HL) new counter value
    SLA     A                               ; SLA A
    SLA     A                               ; SLA A: * 4 (4 bytes per enemy slot)
    LD      B, $00                          ; B = $00
    LD      C, A                            ; C = A
    CALL    SUB_A394                        ; CALL SUB_A394: load enemy slot address
    LD      (HL), C                         ; (HL) = C: store lo byte of slot address
    INC     HL                              ; INC HL
    LD      (HL), $FF                       ; (HL) = $FF: mark slot active ($FF = in use)
    LD      HL, $7304                       ; HL = $7304 (player secondary X)
    ADD     HL, BC                          ; ADD HL, BC: index into player secondary X array
    PUSH    HL                              ; PUSH HL
    LD      A, ($7197)                      ; A = ($7197) tile type byte lo nibble
    AND     $0F                             ; AND $0F
    LD      HL, $A496                       ; HL = $A496 (X-position lookup table)
    LD      B, $00                          ; B = $00
    LD      C, A                            ; C = A
    ADD     HL, BC                          ; ADD HL, BC
    LD      A, (HL)                         ; A = (HL): look up X position
    POP     HL                              ; POP HL
    LD      (HL), A                         ; (HL) = A: store enemy X position
    INC     HL                              ; INC HL
    PUSH    HL                              ; PUSH HL
    LD      A, ($7197)                      ; A = ($7197)
    SRL     A                               ; SRL A
    SRL     A                               ; SRL A
    SRL     A                               ; SRL A
    SRL     A                               ; SRL A: shift hi nibble to lo
    AND     $0F                             ; AND $0F
    LD      HL, $A4A5                       ; HL = $A4A5 (Y-position lookup table)
    LD      B, $00                          ; B = $00
    LD      C, A                            ; C = A
    ADD     HL, BC                          ; ADD HL, BC
    LD      A, (HL)                         ; A = (HL): look up Y position
    POP     HL                              ; POP HL
    LD      (HL), A                         ; (HL) = A: store enemy Y position
    INC     HL
    PUSH    HL
    LD      A, ($719A)                  ; RAM $719A
    LD      E, $48
    CP      $86
    JR      NZ, LOC_A45D
    DEC     HL
    DEC     HL
    DEC     (HL)
    DEC     (HL)
    INC     HL
    INC     HL
    JR      LOC_A465

LOC_A45D:
    LD      E, $10
    CP      $88
    JR      Z, LOC_A465
    LD      E, $08

LOC_A465:
    LD      HL, $7086                   ; RAM $7086

LOC_A468:
    LD      A, (HL)
    CP      $FF
    JR      Z, LOC_A471
    INC     HL
    INC     HL
    JR      LOC_A468

LOC_A471:
    LD      A, ($707A)                  ; RAM $707A
    INC     A
    ADD     A, E
    LD      (HL), A
    INC     HL
    LD      A, ($7196)                  ; RAM $7196
    BIT     6, A
    LD      A, $00
    JR      Z, LOC_A483
    LD      A, $80

LOC_A483:
    LD      (HL), A
    LD      A, ($719A)                  ; RAM $719A
    LD      B, $00
    LD      HL, $9FD1
    LD      C, A
    ADD     HL, BC
    LD      D, (HL)
    INC     HL
    LD      A, (HL)
    POP     HL
    LD      (HL), A
    INC     HL
    LD      (HL), D
    RET     
    DB      $39, $59, $61, $69, $71, $81, $89, $91
    DB      $A1, $A9, $B1, $00, $00, $00, $00, $00
    DB      $10, $20, $30, $40, $50, $60, $70, $80
    DB      $90, $A0, $B0, $C0, $D0, $D0, $F0

SUB_A4B5:
    LD      A, ($71A7)                      ; A = ($71A7) player current speed
    LD      HL, $A4C5                       ; HL = $A4C5 (speed modifier table)
    LD      B, $00                          ; B = $00
    LD      C, A                            ; C = A (use speed as index)
    ADD     HL, BC                          ; ADD HL, BC
    LD      C, (HL)                         ; C = (HL): load speed modifier
    LD      A, ($71A8)                      ; A = ($71A8) base speed
    ADD     A, C                            ; ADD A, C: add modifier
    RET                                     ; RET (A = adjusted speed)
    DB      $F8, $FC, $02, $0A, $14, $20, $2E, $3E
    DB      $50

SUB_A4CE:
    LD      ($71A5), A                      ; ($71A5) = A: save speed level
    SLA     A                               ; SLA A: * 2 (2 bytes per record)
    LD      HL, $9477                       ; HL = $9477 (speed record table)
    LD      B, $00                          ; B = $00
    LD      C, A                            ; C = A (index)
    ADD     HL, BC                          ; ADD HL, BC
    LD      BC, $0004                       ; BC = $0004 (4 bytes per record)
    LD      DE, $7190                       ; DE = $7190 (destination: speed record buffer)
    LDIR                                    ; LDIR: copy 4-byte speed record to RAM
    RET     

SUB_A4E3:
    LD      A, ($7196)                      ; A = ($7196) raw tile byte
    RL      A                               ; RL A
    RL      A                               ; RL A
    RL      A                               ; RL A: rotate bits 7:6 to bits 1:0
    AND     $03                             ; AND $03: isolate type field (2 bits)
    LD      HL, $71B1                       ; HL = $71B1 (tile type nibble store)
    LD      (HL), A                         ; (HL) = A: store type
    DEC     HL                              ; DEC HL -> $71B0
    LD      A, ($7197)                      ; A = ($7197) second tile byte
    LD      (HL), A                         ; (HL) = A: store second tile data byte
    RET     

SUB_A4F8:
    LD      A, ($7196)                      ; A = ($7196) raw tile byte
    AND     $3F                             ; AND $3F: mask off action bits
    LD      HL, $9444                       ; HL = $9444 (tile action table)
    LD      B, $00                          ; B = $00
    LD      C, A                            ; C = A (tile index)
    ADD     HL, BC                          ; ADD HL, BC
    LD      A, (HL)                         ; A = (HL): look up action code
    LD      ($719A), A                      ; ($719A) = A: store action code
    RET     
    DB      $01, $20, $00, $2A, $B0, $71, $09, $22
    DB      $B0, $71, $C9

SUB_A514:
    LD      A, ($71A1)                      ; A = ($71A1) player velocity / frame index
    LD      C, A                            ; C = A
    LD      A, ($71A2)                      ; A = ($71A2) animation frame counter
    LD      D, $01                          ; D = $01 (bitmask accumulator seed)
    SCF                                     ; SCF
    CCF                                     ; CCF: clear carry

LOC_A51F:                                   ; LOC_A51F:
    DEC     A                               ; DEC A: count down frame index
    JP      M, LOC_A52C                     ; JP M, LOC_A52C: went negative -> done counting
    RL      D                               ; RL D: shift mask bit left
    JR      NC, LOC_A51F                    ; JR NC, LOC_A51F: no carry -> continue
    INC     C                               ; INC C: wrap C (column counter)
    RL      D                               ; RL D
    JR      NC, LOC_A51F                    ; JR NC, LOC_A51F

LOC_A52C:                                   ; LOC_A52C:
    LD      HL, $71A2                       ; HL = $71A2
    INC     (HL)                            ; INC (HL): advance frame counter
    SCF                                     ; SCF
    LD      HL, $70C0                       ; HL = $70C0 (collision grid base)
    LD      B, $00                          ; B = $00
    ADD     HL, BC                          ; ADD HL, BC: index collision grid by column
    LD      A, D                            ; A = D: bitmask to test
    AND     (HL)                            ; AND (HL): test collision bit
    JR      NZ, LOC_A53E                    ; JR NZ, LOC_A53E: bit set -> collision detected
    SCF                                     ; SCF
    CCF                                     ; CCF: clear carry (no collision)
    RET                                     ; RET

LOC_A53E:                                   ; LOC_A53E:
    SCF                                     ; SCF (set carry = collision detected)
    RET                                     ; RET

SUB_A540:
    PUSH    BC                              ; PUSH BC
    LD      B, $00                          ; B = $00
    LD      C, A                            ; C = A (index into table at HL)
    ADD     HL, BC                          ; ADD HL, BC: HL + index
    LD      A, (HL)                         ; A = (HL): fetch byte from table
    POP     BC                              ; POP BC
    RET                                     ; RET

SOUND_WRITE_A548:
    CALL    SUB_AEFE                        ; CALL SUB_AEFE: VDP address setup (score row rendering helper)
    LD      DE, $0021                       ; DE = $0021 (item sprite stride / offset)
    LD      HL, $85D7                       ; HL = $85D7 (item sprite ROM table base)
    LD      BC, $030A                       ; BC = $030A (B=3 blocks, C=$0A stride)
    CALL    SUB_A308                        ; CALL SUB_A308: write sprite attribute block
    LD      HL, $71B2                       ; HL = $71B2 (item pickup table start)

LOC_A55A:                                   ; LOC_A55A:
    LD      A, (HL)                         ; A = (HL): read item table entry
    CP      $FF                             ; CP $FF: end-of-table sentinel?
    JP      Z, LOC_AABB                     ; JP Z, LOC_AABB: done -> update lives/score display
    PUSH    HL                              ; PUSH HL (save table pointer)
    PUSH    DE                              ; PUSH DE (save stride)
    CALL    SUB_A378                        ; CALL SUB_A378: render item sprite tile pair
    POP     DE                              ; POP DE
    INC     DE                              ; INC DE: advance stride by 2
    INC     DE                              ; INC DE
    POP     HL                              ; POP HL
    INC     HL                              ; INC HL: next table entry
    JR      LOC_A55A                        ; JR LOC_A55A: loop until sentinel
    DB      $21, $B1, $71, $23, $7E, $FE, $FF, $20
    DB      $FA, $7D, $FE, $B7, $37, $C8, $79, $FE
    DB      $44, $20, $0F, $21, $00, $10, $22, $BD
    DB      $70, $18, $08

SUB_A587:
    CALL    SUB_AF70                        ; CALL SUB_AF70: BCD score add (IY=$7017 -> $7015/$7016/$7017)
    CALL    SUB_AEFE                        ; CALL SUB_AEFE: refresh score row on VRAM
    RET     
    DB      $71, $CD, $48, $A5, $E5, $2A, $BD, $70
    DB      $CD, $87, $A5, $E1, $37, $3F, $C9, $3E
    DB      $06, $32, $49, $70, $21, $5F, $70, $CB
    DB      $D6, $CD, $06, $AC, $3E, $FF, $32, $A9
    DB      $70, $3E, $01, $32, $AD, $70, $21, $01
    DB      $00, $22, $E0, $72, $3E, $08, $32, $A8
    DB      $71, $CD, $67, $A0, $CD, $7E, $8E, $3E
    DB      $05, $32, $79, $70, $3A, $07, $72, $CB
    DB      $7F, $28, $F9, $AF, $32, $07, $72, $21
    DB      $A1, $A8, $5E, $3A, $5F, $70, $CB, $5F
    DB      $20, $F8, $23, $56, $7A, $FE, $FF, $28
    DB      $E3, $23, $4E, $23, $46, $E5, $C5, $E1
    DB      $1A, $FE, $FE, $28, $0D, $FE, $01, $20
    DB      $07, $D5, $E5, $CD, $3A, $AE, $E1, $D1
    DB      $1A, $3D, $E1, $23, $FE, $00, $20, $01
    DB      $7E, $12, $23, $18, $CD

SUB_A60B:
    LD      HL, $705F                       ; HL = $705F (game mode flags)
    RES     3, (HL)                         ; RES 3, (HL): clear bit 3 = room-setup-needed
    LD      BC, $0182                       ; BC = $0182 (VDP reg 1, value $82 -- display enable)
    CALL    WRITE_REGISTER                  ; CALL WRITE_REGISTER: enable VDP display
    LD      BC, $0705                       ; BC = $0705 (VDP reg 7, value $05 -- border/palette)
    CALL    WRITE_REGISTER                  ; CALL WRITE_REGISTER: set border colour
    XOR     A                               ; A = $00 (fill value)
    LD      DE, $0300                       ; DE = $0300 (length: one name table row block)
    LD      HL, $1800                       ; HL = $1800 (VRAM name table base)
    CALL    FILL_VRAM                       ; CALL FILL_VRAM: blank $0300 bytes of name table
    LD      A, ($70AC)                      ; A = ($70AC) room entry mode
    CP      $01                             ; CP $01
    JR      Z, LOC_A678                     ; JR Z, LOC_A678: mode $01 = fast path (no enemy placement)
    LD      HL, ($7047)                     ; HL = ($7047) room data cursor pointer
    LD      B, $19                          ; B = $19 (25 enemy entries to process)
    LD      A, H                            ; A = H
    AND     $AE                             ; AND $AE: mask to enemy-data bank
    SET     7, A                            ; SET 7, A: set high bit (enemy data at $8000+)
    LD      H, A                            ; H = A (HL now points into enemy data bank)

LOC_A638:                                   ; LOC_A638: enemy placement loop
    PUSH    BC                              ; PUSH BC (save loop counter)
    LD      A, (HL)                         ; A = (HL): read enemy type byte
    AND     $07                             ; AND $07: isolate 3-bit type
    SET     1, A                            ; SET 1, A: set 'used' flag
    LD      B, A                            ; B = A (tile number)
    LD      C, $01                          ; C = $01 (attribute flag)
    INC     HL                              ; INC HL
    LD      D, $01                          ; D = $01
    INC     HL                              ; INC HL
    LD      E, (HL)                         ; E = (HL): load enemy Y position
    INC     HL                              ; INC HL
    PUSH    HL                              ; PUSH HL (save room data pointer)
    PUSH    BC                              ; PUSH BC / POP BC (reload BC = tile/attr)
    POP     BC                              ; POP BC
    LD      HL, $A9AD                       ; HL = $A9AD (enemy sprite tile table)
    CALL    SUB_AA96                        ; CALL SUB_AA96: SET bit 2 WORK_BUFFER -> write enemy sprite to VRAM
    POP     HL                              ; POP HL (restore room data pointer)
    POP     BC                              ; POP BC (restore loop counter)
    DJNZ    LOC_A638                        ; DJNZ LOC_A638: process all 25 enemy entries
    LD      A, ($71A6)                      ; A = ($71A6) room difficulty
    SRA     A                               ; SRA A: difficulty / 2
    ADD     A, $08                          ; ADD A, $08: base count = 8 + difficulty/2
    LD      B, A                            ; B = A (number of item entries to place)
    LD      A, ($7047)                      ; A = ($7047) room data ptr lo
    AND     $1F                             ; AND $1F: item index (5 bits)
    LD      D, $01                          ; D = $01
    LD      E, A                            ; E = A (item data)

LOC_A664:                                   ; LOC_A664: item placement loop
    PUSH    BC                              ; PUSH BC (save loop counter)
    LD      ($71B0), DE                     ; ($71B0) = DE: store current item data
    LD      A, $44                          ; A = $44 (item tile number)
    PUSH    DE                              ; PUSH DE
    CALL    SUB_A378                        ; CALL SUB_A378: render item sprite tile pair
    POP     HL                              ; POP HL
    LD      BC, $0027                       ; BC = $0027 (39 bytes per item slot)
    ADD     HL, BC                          ; ADD HL, BC: advance item pointer
    DB      $EB                             ; DB $EB: EX DE,HL
    POP     BC                              ; POP BC (restore loop counter)
    DJNZ    LOC_A664                        ; DJNZ LOC_A664: place all items

LOC_A678:
    LD      A, ($71A8)                      ; A = ($71A8) room type
    CP      $0A                             ; CP $0A: outdoor room?
    JR      Z, LOC_A695                     ; JR Z, LOC_A695: outdoor -> skip door sprites
    LD      DE, BOOT_UP                     ; DE = BOOT_UP ($0000 -- door tile offset base)
    LD      HL, $A9AE                       ; HL = $A9AE (door sprite tile table)
    CP      $0B                             ; CP $0B: check for special room type $0B
    JR      NZ, LOC_A68F                    ; JR NZ, LOC_A68F: not $0B -> use default door table
    LD      HL, $A9B0                       ; HL = $A9B0 (special door tile table)
    LD      DE, $001D                       ; DE = $001D (door stride)

LOC_A68F:                                   ; LOC_A68F:
    LD      BC, $1803                       ; BC = $1803 (VRAM name table addr $1803)
    CALL    SUB_AA96                        ; CALL SUB_AA96: write door sprites to VRAM name table

LOC_A695:                                   ; LOC_A695:
    CALL    SUB_AEFE                        ; CALL SUB_AEFE: VDP address setup (flush score row)
    LD      BC, $01E2                       ; BC = $01E2 (VDP reg 1, value $E2 -- enable display + sprites)
    CALL    WRITE_REGISTER                  ; CALL WRITE_REGISTER: enable VDP display with sprites
    RET     
    DB      $E5, $21, $97, $70, $34, $E1, $3A, $97
    DB      $70, $E6, $11, $FE, $00, $20, $02, $37
    DB      $C9, $37, $3F, $C9, $D1, $D5, $13, $1A
    DB      $E6, $80, $47, $1A, $E6, $7F, $3D, $F2
    DB      $C3, $A6, $3E, $05, $80, $12, $E6, $7F
    DB      $FE, $00, $20, $1D, $D1, $E1, $E5, $D5
    DB      $23, $23, $23, $7E, $FE, $00, $28, $0C
    DB      $3A, $4A, $70, $FE, $00, $3E, $0C, $28
    DB      $02, $3E, $0E, $77, $2B, $7E, $EE, $1C
    DB      $77, $21, $5A, $70, $7E, $23, $FE, $10
    DB      $20, $71, $7E, $FE, $11, $20, $6C, $E1
    DB      $7E, $CB, $6F, $20, $1E, $CD, $9F, $A6
    DB      $E5, $38, $60, $3A, $AB, $70, $FE, $02
    DB      $20, $59, $E1, $CD, $ED, $AB, $E3, $7E
    DB      $C6, $02, $77, $E1, $CB, $EE, $CB, $FE
    DB      $C3, $8F, $A8, $CB, $7F, $20, $1C, $CB
    DB      $AE, $CD, $9F, $A6, $3E, $08, $38, $06
    DB      $7E, $EE, $80, $77, $3E, $FE, $E3, $23
    DB      $86, $77, $2B, $7E, $C6, $F9, $77, $E1
    DB      $C3, $8F, $A8, $0E, $FF, $3A, $5B, $70
    DB      $FE, $E8, $28, $04, $FE, $08, $20, $15
    DB      $CD, $9F, $A6, $38, $06, $CB, $FE, $06
    DB      $FE, $18, $04, $CB, $BE, $06, $08, $0E
    DB      $00, $CB, $AE, $18, $02, $06, $00, $E3
    DB      $C3, $7F, $A8, $21, $57, $70, $7E, $23
    DB      $FE, $88, $20, $2B, $7E, $FE, $89, $20
    DB      $26, $3A, $AB, $70, $FE, $02, $20, $1F
    DB      $E1, $CB, $6E, $20, $12, $CD, $9F, $A6
    DB      $E5, $38, $14, $E1, $CD, $ED, $AB, $CB
    DB      $BE, $CB, $EE, $3E, $00, $18, $9F, $CB
    DB      $7E, $20, $A8, $0E, $01, $18, $C6, $E1
    DB      $01, $00, $00, $CB, $6E, $20, $F0, $C3
    DB      $2F, $A8, $21, $86, $70, $7E, $FE, $FF
    DB      $C8, $E5, $E6, $07, $CB, $27, $CB, $27
    DB      $21, $00, $73, $CD, $40, $A5, $E5, $CD
    DB      $59, $91, $E1, $7E, $E3, $FE, $15, $38
    DB      $04, $FE, $B8, $38, $04, $7E, $EE, $80
    DB      $77, $7E, $CB, $77, $E5, $C2, $B3, $A6
    DB      $E1, $D1, $D5, $F5, $13, $13, $13, $EB
    DB      $7E, $FE, $00, $28, $0C, $3A, $4A, $70
    DB      $FE, $00, $3E, $0F, $28, $02, $3E, $0E
    DB      $77, $EB, $F1, $CB, $5F, $28, $2F, $23
    DB      $7E, $3C, $77, $2B, $E6, $0F, $FE, $04
    DB      $20, $24, $23, $7E, $E6, $80, $77, $2B
    DB      $7E, $CB, $7F, $0E, $FC, $28, $02, $0E
    DB      $04, $E3, $E5, $23, $23, $7E, $81, $FE
    DB      $2C, $20, $02, $3E, $0C, $FE, $08, $20
    DB      $02, $3E, $28, $77, $E1, $E3, $7E, $CB
    DB      $67, $28, $0D, $3A, $85, $70, $FE, $08
    DB      $38, $1D, $FE, $F5, $30, $19, $18, $1B
    DB      $3A, $5B, $70, $FE, $00, $28, $10, $7E
    DB      $CB, $7F, $3A, $57, $70, $20, $03, $3A
    DB      $59, $70, $CD, $94, $A8, $20, $04, $7E
    DB      $EE, $80, $77, $7E, $CB, $5F, $0E, $00
    DB      $20, $18, $E5, $23, $7E, $E6, $80, $47
    DB      $7E, $E6, $7F, $3D, $F2, $60, $A8, $3E
    DB      $39, $77, $21, $B3, $AB, $CD, $40, $A5
    DB      $4E, $E1, $7E, $E3, $06, $01, $CB, $7F
    DB      $28, $02, $06, $FF, $E3, $23, $7E, $2B
    DB      $E3, $CB, $7F, $28, $03, $78, $80, $47
    DB      $7E, $91, $77, $23, $7E, $80, $77, $E1
    DB      $FE, $08, $30, $04, $7E, $EE, $80, $77
    DB      $23, $23, $C3, $A4, $A7, $E5, $C5, $21
    DB      $3C, $94, $01, $08, $00, $ED, $B1, $C1
    DB      $E1, $C9, $73, $70, $E5, $91, $02, $12
    DB      $70, $5F, $8F, $04, $68, $70, $D1, $88
    DB      $01, $74, $70, $D6, $A8, $01, $FF, $FF

SUB_A8B7:
    PUSH    HL                              ; PUSH HL
    LD      HL, $705F                       ; HL = $705F (game mode flags)
    SET     1, (HL)                         ; SET 1, (HL): set bit 1 = VRAM-write-in-progress (pause game logic)
    LD      HL, $70AF                       ; HL = $70AF (VRAM nesting counter)
    INC     (HL)                            ; INC (HL): increment VRAM nesting counter
    POP     HL                              ; POP HL
    RET     

SUB_A8C3:
    PUSH    HL                              ; PUSH HL
    PUSH    AF                              ; PUSH AF
    LD      HL, $70AF                       ; HL = $70AF (VRAM nesting counter)
    DEC     (HL)                            ; DEC (HL): decrement nesting counter
    LD      A, (HL)                         ; A = (HL)
    CP      $00                             ; CP $00: fully exited?
    JR      NZ, LOC_A8D3                    ; JR NZ, LOC_A8D3: still nested -> keep game paused
    LD      HL, $705F                       ; HL = $705F
    RES     1, (HL)                         ; RES 1, (HL): clear bit 1 = game logic can resume

LOC_A8D3:
    POP     AF
    POP     HL
    RET     
    DB      $3A, $A8, $70, $3D, $20, $02, $3E, $60
    DB      $32, $A8, $70, $FE, $60, $20, $2E, $21
    DB      $00, $70, $CB, $F6, $21, $CD, $AB, $11
    DB      $1D, $00, $CD, $05, $A9, $3A, $A8, $70
    DB      $FE, $60, $20, $27, $21, $00, $70, $CB
    DB      $EE, $21, $CD, $AB, $11, $1C, $00, $D5
    DB      $E5, $E1, $D1, $FD, $21, $01, $00, $3E
    DB      $04, $CD, $2E, $AE, $C9, $FE, $48, $20
    DB      $DC, $21, $00, $70, $CB, $B6, $21, $2E
    DB      $A9, $18, $CC, $FE, $30, $C0, $21, $00
    DB      $70, $CB, $AE, $21, $2E, $A9, $18, $D4
    DB      $40

SUB_A92F:
    CALL    SUB_A8B7                        ; CALL SUB_A8B7: VRAM-lock enter
    LD      A, ($73F9)                      ; A = ($73F9) SN76489A frequency byte to write
    LD      ($7085), A                      ; ($7085) = A: cache frequency byte
    LD      C, $00                          ; C = $00 (frame 0)
    XOR     A                               ; A = $00 (offset 0)
    CALL    SUB_A97A                        ; CALL SUB_A97A: write SN76489A frame 0 ($73F9=$00)
    LD      C, $01                          ; C = $01 (frame 1)
    LD      A, $08                          ; A = $08
    CALL    SUB_A97A                        ; CALL SUB_A97A: write SN76489A frame 1 ($73F9=$08)
    LD      C, $02                          ; C = $02 (frame 2)
    LD      A, $10                          ; A = $10
    CALL    SUB_A97A                        ; CALL SUB_A97A: write SN76489A frame 2 ($73F9=$10)
    LD      C, $05                          ; C = $05 (frame 3)
    LD      A, $28                          ; A = $28
    CALL    SUB_A97A                        ; CALL SUB_A97A: write SN76489A frame 3 ($73F9=$28)
    LD      A, ($7085)                      ; A = ($7085) cached frequency byte
    CP      $00                             ; CP $00
    JR      NZ, LOC_A95C                    ; JR NZ, LOC_A95C: nonzero -> check frame 1
    LD      C, $00                          ; C = $00: frame selector = 0

LOC_A95C:                                   ; LOC_A95C:
    CP      $08                             ; CP $08
    JR      NZ, LOC_A962                    ; JR NZ, LOC_A962
    LD      C, $01                          ; C = $01: frame selector = 1

LOC_A962:                                   ; LOC_A962:
    CP      $10                             ; CP $10
    JR      NZ, LOC_A968                    ; JR NZ, LOC_A968
    LD      C, $02                          ; C = $02: frame selector = 2

LOC_A968:                                   ; LOC_A968:
    CP      $28                             ; CP $28
    JR      NZ, LOC_A96E                    ; JR NZ, LOC_A96E
    LD      C, $05                          ; C = $05: frame selector = 3

LOC_A96E:                                   ; LOC_A96E:
    LD      ($73F9), A                      ; ($73F9) = A: store final frequency byte
    LD      B, $04                          ; B = $04 (VDP register 4)
    CALL    WRITE_REGISTER                  ; CALL WRITE_REGISTER: write VDP register 4 with C value
    CALL    SUB_A8C3                        ; CALL SUB_A8C3: VRAM-lock exit
    RET     

SUB_A97A:
    LD      ($73F9), A                  ; RAM $73F9
    LD      B, $04
    CALL    WRITE_REGISTER
    LD      A, ($7096)                  ; RAM $7096
    PUSH    AF
    SLA     A
    LD      HL, $85BC
    LD      DE, $00E0
    CALL    SUB_A9A0
    LD      HL, $85CA
    LD      DE, $00E8
    POP     AF
    AND     $01
    SLA     A
    SLA     A
    SLA     A

SUB_A9A0:
    CALL    SUB_A540
    LD      IY, $0001
    LD      A, $03
    CALL    SUB_AE2E
    RET     
    DB      $90, $08, $00, $95, $00, $08

; =============================================================================
; NMI HANDLER -- NMI (~$AA00)
; Reached via CART_ENTRY JP.  Saves every register (AF, BC, DE, HL, IX, IY
; and all alternates) before any game work.
;   $70B1 bit 7: re-entry guard (SET on entry, RES on exit)
;   $70B1 bit 3: CALL NZ, SUB_919A -- score / game-bit update
;   $705F bit 1: skip game logic (pause / attract mode)
;   $705F bit 3: CALL NZ, SUB_A60B -- room renderer + enemy placement
;   $70B1 bit 4: CALL NZ, DELAY_LOOP_8EB0 -- full per-frame game body
;   INC ($7097)    frame counter
;   INC ($7047)    pointer advance (room data cursor)
;   $7011 (sub-frame counter 1-4): cycle through 4 SN76489A sound frames
;     via SUB_A92F (write next sound byte to SOUND_PORT)
;   DEC ($7207)    sprite flicker counter
;   CALL WR_SPR_NM_TBL  flush sprite name table ($08 sprites)
;   CALL SUB_AC6D  sound channel sequencer (drives $702C/$702E music data)
;   LOC_AA45: CALL READ_REGISTER (read VDP status, clear interrupt flag)
;   RES 7, ($70B1) / RETN
; =============================================================================
NMI:
    PUSH    AF                              ; PUSH AF: save main register set
    PUSH    BC                              ; PUSH BC
    PUSH    DE                              ; PUSH DE
    PUSH    HL                              ; PUSH HL
    PUSH    IX                              ; PUSH IX
    PUSH    IY                              ; PUSH IY
    EX      AF, AF'                         ; EX AF, AF': swap to alternate A/F
    EXX                                     ; EXX: swap to alternate BC/DE/HL
    PUSH    AF                              ; PUSH AF: save alternate AF
    PUSH    BC                              ; PUSH BC: save alternate BC
    PUSH    DE                              ; PUSH DE: save alternate DE
    PUSH    HL                              ; PUSH HL: save alternate HL
    LD      HL, $70B1                       ; HL = $70B1 (NMI flag byte)
    BIT     7, (HL)                         ; BIT 7, (HL): re-entry guard
    JP      NZ, LOC_AA4D                    ; JP NZ, LOC_AA4D: already in NMI -> skip to exit (prevents re-entry)
    SET     7, (HL)                         ; SET 7, (HL): mark NMI in-progress
    BIT     3, (HL)                         ; BIT 3, (HL): score-update pending?
    RES     3, (HL)                         ; RES 3, (HL): clear score-update flag
    CALL    NZ, SUB_919A                    ; CALL NZ, SUB_919A: score update (SET WORK_BUFFER bit 0, clear room data)
    LD      A, ($705F)                      ; A = ($705F) game mode flags
    BIT     1, A                            ; BIT 1, A: pause flag
    JR      NZ, LOC_AA45                    ; JR NZ, LOC_AA45: paused -> skip all game logic
    BIT     3, A                            ; BIT 3, A: room-setup needed?
    CALL    NZ, SUB_A60B                    ; CALL NZ, SUB_A60B: yes -> room renderer + enemy placement
    LD      HL, $70B1                       ; HL = $70B1
    BIT     4, (HL)                         ; BIT 4, (HL): frame-body pending?
    RES     4, (HL)                         ; RES 4, (HL): clear frame-body flag
    CALL    NZ, DELAY_LOOP_8EB0             ; CALL NZ, DELAY_LOOP_8EB0: run full per-frame game body
    LD      HL, $7097                       ; HL = $7097 (frame counter)
    INC     (HL)                            ; INC (HL): increment frame counter each NMI
    LD      HL, ($7047)                     ; HL = ($7047) room data cursor
    INC     HL                              ; INC HL: advance room data cursor
    LD      ($7047), HL                     ; ($7047) = HL: store updated cursor
    LD      A, ($7011)                      ; A = ($7011) sub-frame counter (1-4)
    INC     A                               ; INC A
    BIT     7, A                            ; BIT 7, A: wrapped past 4?
    JR      NZ, LOC_AA39                    ; JR NZ, LOC_AA39: counter wrapped -> reset + final sound frame
    LD      ($7011), A                      ; ($7011) = A: store incremented sub-frame counter
    CP      $01                             ; CP $01
    JR      NZ, LOC_AA08                    ; JR NZ, LOC_AA08: not frame 1
    LD      BC, $0400                       ; BC = $0400 (sound frame 0 params)
    XOR     A                               ; A = $00 (sound frequency sub-byte 0)
    JR      LOC_AA2C                        ; JR LOC_AA2C

LOC_AA08:                                   ; LOC_AA08:
    CP      $02                             ; CP $02
    JR      NZ, LOC_AA13                    ; JR NZ, LOC_AA13: not frame 2
    LD      BC, $0401                       ; BC = $0401 (sound frame 1)
    LD      A, $08                          ; A = $08
    JR      LOC_AA2C                        ; JR LOC_AA2C

LOC_AA13:                                   ; LOC_AA13:
    CP      $03                             ; CP $03
    JR      NZ, LOC_AA1E                    ; JR NZ, LOC_AA1E: not frame 3
    LD      BC, $0402                       ; BC = $0402 (sound frame 2)
    LD      A, $10                          ; A = $10
    JR      LOC_AA2C                        ; JR LOC_AA2C

LOC_AA1E:                                   ; LOC_AA1E:
    CP      $04                             ; CP $04
    JR      NZ, LOC_AA39                    ; JR NZ, LOC_AA39: not frame 4 -> skip
    LD      HL, $7011                       ; HL = $7011
    LD      (HL), $00                       ; (HL) = $00: reset sub-frame counter
    LD      BC, $0405                       ; BC = $0405 (sound frame 3 params)
    LD      A, $28                          ; A = $28 (sound frequency sub-byte 3)

LOC_AA2C:                                   ; LOC_AA2C:
    LD      ($73F9), A                      ; ($73F9) = A: store SN76489A frequency byte
    CALL    SUB_A92F                        ; CALL SUB_A92F: write SN76489A sound frame (4-frame cycle)
    LD      HL, $7011                       ; HL = $7011
    LD      A, (HL)                         ; A = (HL) sub-frame counter
    XOR     $80                             ; XOR $80: toggle bit 7 (mark frame written)
    LD      (HL), A                         ; (HL) = A

LOC_AA39:                                   ; LOC_AA39:
    LD      HL, $7207                       ; HL = $7207 (sprite flicker counter)
    DEC     (HL)                            ; DEC (HL): decrement flicker counter
    LD      A, $08                          ; A = $08 (8 sprites)
    CALL    WR_SPR_NM_TBL                   ; CALL WR_SPR_NM_TBL: write sprite name table to VRAM
    CALL    SUB_AC6D                        ; CALL SUB_AC6D: sound channel sequencer

LOC_AA45:                                   ; LOC_AA45:
    CALL    READ_REGISTER                   ; CALL READ_REGISTER: read VDP status (clears interrupt latch)
    LD      HL, $70B1                       ; HL = $70B1
    RES     7, (HL)                         ; RES 7, (HL): clear re-entry guard (NMI done)

LOC_AA4D:                                   ; LOC_AA4D:
    POP     HL                              ; POP HL: restore alternate HL
    POP     DE                              ; POP DE
    POP     BC                              ; POP BC
    POP     AF                              ; POP AF: restore alternate register set
    EX      AF, AF'                         ; EX AF, AF': restore main AF
    EXX                                     ; EXX: restore main BC/DE/HL
    POP     IY                              ; POP IY
    POP     IX                              ; POP IX
    POP     HL                              ; POP HL
    POP     DE                              ; POP DE
    POP     BC                              ; POP BC
    POP     AF                              ; POP AF: all registers restored
    RETN                                    ; RETN: return from NMI

SUB_AA5D:
    LD      DE, $0001                       ; DE = $0001 (sprite attribute stride)
    LD      BC, $0A01                       ; BC = $0A01 (B=10 rows, C=$01 tile attribute)
    CALL    SUB_AAA8                        ; CALL SUB_AAA8: render 10 enemy sprite rows
    LD      BC, $0801                       ; BC = $0801 (B=8 rows, C=$01)
    LD      DE, $0017                       ; DE = $0017 (second sprite block offset)
    CALL    SUB_AAA8                        ; CALL SUB_AAA8: render 8 more enemy sprite rows
    LD      HL, $AA88                       ; HL = $AA88 (sprite tile table)
    LD      BC, $030C                       ; BC = $030C (B=3, C=$0C stride)
    LD      DE, $0020                       ; DE = $0020 (sprite attribute offset)
    CALL    SUB_AA96                        ; CALL SUB_AA96: SET WORK_BUFFER bit 2 + call SUB_AEA7
    LD      DE, $0036                       ; DE = $0036 (next sprite block offset)
    LD      HL, $AA89                       ; HL = $AA89
    LD      BC, $030A                       ; BC = $030A
    CALL    SUB_AA96                        ; CALL SUB_AA96: render second set
    RET     
    DB      $0A, $0A, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $0B, $0B, $09, $0C

SUB_AA96:
    PUSH    HL                              ; PUSH HL
    LD      HL, WORK_BUFFER                 ; HL = WORK_BUFFER ($7000)
    SET     2, (HL)                         ; SET 2, (HL): set bit 2 = VRAM-write-in-progress
    POP     HL                              ; POP HL
    CALL    SUB_AEA7                        ; CALL SUB_AEA7: inner VRAM tile write loop
    PUSH    HL                              ; PUSH HL
    LD      HL, WORK_BUFFER                 ; HL = WORK_BUFFER
    RES     2, (HL)                         ; RES 2, (HL): clear VRAM-write flag
    POP     HL                              ; POP HL
    RET                                     ; RET

SUB_AAA8:
    LD      HL, $AA94                       ; HL = $AA94 (sprite tile data)
    CALL    SUB_AEA7                        ; CALL SUB_AEA7: write first block to VRAM
    DB      $EB                             ; DB $EB: EX DE,HL
    LD      DE, $0080                       ; DE = $0080 (half-tile stride offset)
    ADD     HL, DE                          ; ADD HL, DE: advance DE by $80
    DB      $EB                             ; DB $EB: EX DE,HL (restore)
    LD      HL, $AA95                       ; HL = $AA95 (second sprite tile data)
    CALL    SUB_AEA7                        ; CALL SUB_AEA7: write second block to VRAM (offset by $80)
    RET     

LOC_AABB:
    LD      A, ($705F)                      ; A = ($705F) game mode flags
    BIT     5, A                            ; BIT 5, A: tile-skip flag
    RET     NZ                              ; RET NZ: tile-skip set -> suppress lives display
    CALL    SUB_A8B7                        ; CALL SUB_A8B7: INC $70AF + SET bit 1 $705F (VRAM-lock enter)
    LD      HL, $1861                       ; HL = $1861 (VRAM lives display area)
    LD      DE, $0008                       ; DE = $0008 (clear 8 tiles)
    XOR     A                               ; A = $00 (fill with blank tile $00)
    CALL    SUB_AE25                        ; CALL SUB_AE25: clear lives area in VRAM
    LD      HL, $1877                       ; HL = $1877 (VRAM score display area)
    LD      DE, $0008                       ; DE = $0008
    XOR     A                               ; A = $00
    CALL    SUB_AE25                        ; CALL SUB_AE25: clear score area in VRAM
    LD      A, ($7049)                      ; A = ($7049) life counter
    PUSH    AF
    CP      $01                             ; CP $01: only 1 life?
    JR      Z, LOC_AB07                     ; JR Z, LOC_AB07: 1 life -> skip icon rendering
    DEC     A                               ; DEC A: lives-1 = number of extra life icons
    LD      HL, $1861                       ; HL = $1861 (lives display row)
    LD      E, A                            ; E = A (number of icons)
    CP      $0B                             ; CP $0B: > 11 icons?
    JR      C, LOC_AB00                     ; JR C, LOC_AB00: fits in first row
    LD      DE, $000A                       ; DE = $000A (cap at 10 first-row icons)
    LD      A, $6F                          ; A = $6F (life-icon tile number)
    CALL    SUB_AE25                        ; CALL SUB_AE25: fill 10 life-icon tiles in row 1
    POP     AF                              ; POP AF
    DEC     A                               ; DEC A
    PUSH    AF                              ; PUSH AF
    SUB     $0A                             ; SUB $0A: remainder for row 2
    LD      HL, $1877                       ; HL = $1877 (second lives row)
    LD      E, $08                          ; E = $08 (cap at 8 for row 2)
    CP      $09                             ; CP $09
    JR      NC, LOC_AB00                    ; JR NC, LOC_AB00: overflow -> use cap
    LD      E, A                            ; E = A (actual remainder count)

LOC_AB00:                                   ; LOC_AB00:
    LD      D, $00                          ; D = $00
    LD      A, $6F                          ; A = $6F (life-icon tile)
    CALL    SUB_AE25                        ; CALL SUB_AE25: render life icons in second row

LOC_AB07:                                   ; LOC_AB07:
    POP     AF                              ; POP AF
    CALL    SUB_A8C3                        ; CALL SUB_A8C3: DEC $70AF, RES bit 1 $705F if zero (VRAM-lock exit)
    RET     
    DB      $10, $11, $11, $10, $88, $89, $89, $88
    DB      $04, $BA, $06, $B8, $B8, $06, $BA, $04
    DB      $05, $B9, $B9, $05, $FF

LOC_AB21:
    PUSH    AF
    INC     HL
    LD      A, (HL)
    LD      (DE), A
    POP     AF
    DEC     HL
    JR      LOC_AB6B

SUB_AB29:
    PUSH    HL
    PUSH    DE
    PUSH    BC
    PUSH    AF
    CALL    SUB_A8B7
    LD      A, $13
    LD      ($7002), A                  ; RAM $7002
    LD      HL, $7200                   ; RAM $7200
    LD      DE, $00A0
    LD      IY, $0020
    LD      A, $02

LOC_AB41:
    PUSH    HL
    PUSH    IY
    PUSH    AF
    PUSH    DE
    CALL    GET_VRAM
    POP     DE
    PUSH    DE
    PUSH    HL
    PUSH    DE
    PUSH    BC
    LD      DE, $7200                   ; RAM $7200
    LD      B, $20

LOC_AB53:
    LD      HL, $AB0C

LOC_AB56:
    LD      A, (HL)
    CP      $FF
    JR      Z, LOC_AB6B
    LD      A, (DE)
    CP      $08
    JR      Z, LOC_AB6B
    CP      $00
    JR      Z, LOC_AB6B
    CP      (HL)
    JR      Z, LOC_AB21
    INC     HL
    INC     HL
    JR      LOC_AB56

LOC_AB6B:
    INC     DE
    DJNZ    LOC_AB53
    POP     BC
    POP     DE
    POP     HL
    LD      A, ($7002)                  ; RAM $7002
    DEC     A
    LD      ($7002), A                  ; RAM $7002
    CP      $00
    JR      Z, LOC_ABA6
    LD      BC, $2001
    LD      HL, $7200                   ; RAM $7200
    PUSH    DE
    LD      B, $20
    DB      $EB
    LD      HL, $729F                   ; RAM $729F

LOC_AB89:
    LD      A, (DE)
    LD      (HL), A
    DEC     HL
    INC     DE
    DJNZ    LOC_AB89
    POP     DE
    LD      BC, $0120
    LD      HL, $7280                   ; RAM $7280
    CALL    SUB_AEA7
    POP     HL
    LD      BC, $0020
    ADD     HL, BC
    PUSH    HL
    POP     DE
    POP     AF
    POP     IY
    POP     HL
    JR      LOC_AB41

LOC_ABA6:
    POP     DE
    POP     AF
    POP     IY
    POP     HL
    POP     AF
    POP     BC
    POP     DE
    POP     HL
    CALL    SUB_A8C3
    RET     
    DB      $FD, $FE, $FE, $FE, $FE, $FE, $FE, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $00, $FF
    DB      $00, $FF, $00, $FF, $00, $FF, $00, $FF
    DB      $00, $FF, $00, $00, $00, $00, $00, $00
    DB      $01, $00, $01, $00, $01, $00, $01, $00
    DB      $01, $00, $01, $00, $01, $01, $01, $01
    DB      $01, $01, $01, $02, $02, $02, $02, $02
    DB      $02, $03, $0E, $08, $DD, $E1, $E3, $23
    DB      $7E, $E6, $0F, $FE, $08, $30, $02, $0E
    DB      $00, $7E, $E6, $F0, $81, $77, $2B, $E3
    DB      $DD, $E5, $C9, $E5, $D5, $C5, $21, $B2
    DB      $71, $E5, $D1, $13, $36, $FF, $01, $06
    DB      $00, $ED, $B0, $C1, $D1, $E1, $C9

SUB_AC1A:
    PUSH    AF                              ; PUSH AF
    PUSH    HL                              ; PUSH HL
    PUSH    DE                              ; PUSH DE
    PUSH    BC                              ; PUSH BC
    LD      B, A                            ; B = A (save requested sound ID)
    LD      HL, $702C                       ; HL = $702C (sound channel flags)
    BIT     7, (HL)                         ; BIT 7, (HL): is channel active?
    JR      NZ, LOC_AC5A                    ; JR NZ, LOC_AC5A: active -> priority check before override

LOC_AC26:                                   ; LOC_AC26:
    LD      ($702D), A                      ; ($702D) = A: store sound ID
    SET     7, (HL)                         ; SET 7, (HL): mark channel active (bit 7)
    SET     5, (HL)                         ; SET 5, (HL): mark sequence-in-progress (bit 5)
    RES     6, (HL)                         ; RES 6, (HL): clear repeat flag (bit 6)
    ADD     A, A                            ; ADD A, A: * 2 (2 bytes per sound table entry)
    LD      HL, $AD0B                       ; HL = $AD0B (sound sequence table)
    LD      E, A                            ; E = A (index lo)
    LD      D, $00                          ; D = $00
    ADD     HL, DE                          ; ADD HL, DE: point to sound sequence entry
    LD      E, (HL)                         ; E = (HL): load lo byte of sequence pointer
    INC     HL                              ; INC HL
    LD      D, (HL)                         ; D = (HL): load hi byte (DE = sequence data pointer)
    DB      $EB                             ; DB $EB: EX DE,HL (HL = sequence data pointer)
    LD      A, (HL)                         ; A = (HL): read sequence header: note duration
    LD      ($7030), A                      ; ($7030) = A: store note duration
    DEC     A                               ; DEC A
    LD      ($7032), A                      ; ($7032) = A: store frame-counter target (duration - 1)
    INC     HL                              ; INC HL
    LD      A, (HL)                         ; A = (HL): read loop/speed byte
    LD      ($7035), A                      ; ($7035) = A: store loop control byte
    AND     $03                             ; AND $03: isolate channel count
    LD      ($7031), A                      ; ($7031) = A: store channel count
    INC     HL                              ; INC HL
    LD      ($702E), HL                     ; ($702E) = HL: store pointer to start of note data
    XOR     A                               ; A = $00
    LD      ($7033), A                      ; ($7033) = $00: clear note index

LOC_AC55:
    POP     BC
    POP     DE
    POP     HL
    POP     AF
    RET     

LOC_AC5A:
    LD      A, ($702D)                      ; A = ($702D) currently playing sound ID
    CP      B                               ; CP B: is requested ID > current?
    JR      C, LOC_AC55                     ; JR C, LOC_AC55: requested < current -> lower priority, ignore
    JR      NZ, LOC_AC6A                    ; JR NZ, LOC_AC6A: different ID -> override
    CP      $09                             ; CP $09: ID == 9 (special: non-interruptible)?
    JR      Z, LOC_AC55                     ; JR Z, LOC_AC55: ID 9 -> don't interrupt
    CP      $01                             ; CP $01: ID == 1?
    JR      Z, LOC_AC55                     ; JR Z, LOC_AC55: ID 1 -> don't interrupt

LOC_AC6A:                                   ; LOC_AC6A:
    LD      A, B                            ; A = B (use new sound ID)
    JR      LOC_AC26                        ; JR LOC_AC26: override with new sound

SUB_AC6D:
    LD      HL, $702C                       ; HL = $702C (sound channel flags)
    BIT     7, (HL)                         ; BIT 7, (HL): channel active?
    RET     Z                               ; RET Z: inactive -> nothing to do
    BIT     6, (HL)                         ; BIT 6, (HL): repeat/stop flag
    JR      Z, LOC_AC82                     ; JR Z, LOC_AC82: not stopping -> advance sequence

LOC_AC77:                                   ; LOC_AC77:
    LD      HL, $702C                       ; HL = $702C
    RES     6, (HL)                         ; RES 6, (HL): clear repeat flag
    RES     7, (HL)                         ; RES 7, (HL): clear active flag (stop channel)
    CALL    TURN_OFF_SOUND                  ; CALL TURN_OFF_SOUND: silence SN76489A
    RET                                     ; RET

LOC_AC82:                                   ; LOC_AC82:
    LD      HL, $7032                       ; HL = $7032 (frame counter)
    INC     (HL)                            ; INC (HL): tick frame counter
    LD      A, (HL)                         ; A = (HL)
    LD      HL, $7030                       ; HL = $7030 (note duration)
    CP      (HL)                            ; CP (HL): frame count reached duration?
    RET     NZ                              ; RET NZ: not yet -> wait
    XOR     A                               ; A = $00
    LD      ($7032), A                      ; ($7032) = $00: reset frame counter
    LD      HL, $702C                       ; HL = $702C
    BIT     5, (HL)                         ; BIT 5, (HL): sequence-in-progress?
    JR      Z, LOC_ACCD                     ; JR Z, LOC_ACCD: bit 5 clear -> advance note index only
    RES     5, (HL)                         ; RES 5, (HL): clear sequence flag
    LD      HL, ($702E)                     ; HL = ($702E) (note data pointer)
    LD      A, (HL)                         ; A = (HL): read channel 1 lo nibble
    AND     $0F                             ; AND $0F
    OR      $D0                             ; OR $D0: SN76489A channel 1 tone latch command
    OUT     ($FF), A                        ; OUT ($FF), A: write tone latch to SOUND_PORT
    LD      A, (HL)                         ; A = (HL): re-read byte
    AND     $F0                             ; AND $F0
    RRCA                                    ; RRCA
    RRCA                                    ; RRCA
    RRCA                                    ; RRCA
    RRCA                                    ; RRCA: shift hi nibble to lo
    OR      $F0                             ; OR $F0: SN76489A channel 1 attenuation command
    OUT     ($FF), A                        ; OUT ($FF), A: write attenuation to SOUND_PORT
    INC     HL                              ; INC HL
    LD      A, (HL)                         ; A = (HL): read channel 2 byte
    AND     $0F                             ; AND $0F
    OR      $90                             ; OR $90: SN76489A channel 2 tone latch command
    OUT     ($FF), A                        ; OUT ($FF), A: write channel 2 tone to SOUND_PORT
    LD      A, (HL)                         ; A = (HL)
    AND     $F0                             ; AND $F0
    RRCA                                    ; RRCA
    RRCA                                    ; RRCA
    RRCA                                    ; RRCA
    RRCA                                    ; RRCA: shift hi nibble
    OR      $B0                             ; OR $B0: SN76489A channel 2 attenuation command
    OUT     ($FF), A                        ; OUT ($FF), A: write channel 2 attenuation to SOUND_PORT
    INC     HL                              ; INC HL
    LD      ($702E), HL                     ; ($702E) = HL: advance note data pointer by 2 bytes
    LD      A, $E3                          ; A = $E3: SN76489A noise channel mute command
    LD      HL, $7035                       ; HL = $7035 (loop/speed control byte)
    OR      (HL)                            ; OR (HL): merge loop byte
    OUT     ($FF), A                        ; OUT ($FF), A: write noise control to SOUND_PORT

LOC_ACCD:                                   ; LOC_ACCD:
    LD      A, ($7033)                      ; A = ($7033) note index
    LD      HL, $7031                       ; HL = $7031 (channel count)
    CP      (HL)                            ; CP (HL): reached last channel?
    JR      Z, LOC_AD06                     ; JR Z, LOC_AD06: yes -> clear note index
    LD      HL, $7033                       ; HL = $7033
    INC     (HL)                            ; INC (HL): advance note index
    LD      HL, ($702E)                     ; HL = ($702E): load next note data address
    LD      A, (HL)                         ; A = (HL)
    CP      $00                             ; CP $00
    JR      Z, LOC_AC77                     ; JR Z, LOC_AC77: zero = sequence end -> stop channel
    AND     $FC                             ; AND $FC
    RRCA                                    ; RRCA
    RRCA                                    ; RRCA: hi 6 bits = note duration value
    LD      ($7034), A                      ; ($7034) = A: store note duration
    LD      A, (HL)                         ; A = (HL): re-read byte
    AND     $03                             ; AND $03: lo 2 bits = channel flags
    RLCA                                    ; RLCA
    RLCA                                    ; RLCA: shift flags to bits 3:2
    LD      B, A                            ; B = A (flags)
    LD      A, ($7033)                      ; A = ($7033) note index
    XOR     $07                             ; XOR $07: toggle 3-bit counter
    RRCA                                    ; RRCA
    RRCA                                    ; RRCA
    RRCA                                    ; RRCA: rotate to get note nibble position
    OR      B                               ; OR B: merge flags
    INC     HL                              ; INC HL
    LD      ($702E), HL                     ; ($702E) = HL: advance note pointer
    OUT     ($FF), A                        ; OUT ($FF), A: write note command to SOUND_PORT
    LD      A, ($7034)                      ; A = ($7034) note duration
    OUT     ($FF), A                        ; OUT ($FF), A: write duration to SOUND_PORT
    JP      LOC_ACCD                        ; JP LOC_ACCD: loop to next note

LOC_AD06:
    XOR     A                               ; A = $00
    LD      ($7033), A                      ; ($7033) = $00: clear note index (sequence complete)
    RET                                     ; RET
    DB      $6D, $AD, $3A, $AD, $1F, $AD, $8C, $AD
    DB      $E0, $AD, $C5, $AD, $9C, $AD, $D2, $AD
    DB      $EB, $AD, $BD, $AD, $04, $02, $F1, $1F
    DB      $3C, $60, $01, $01, $3C, $60, $01, $01
    DB      $3C, $60, $01, $01, $2D, $48, $01, $01
    DB      $01, $01, $01, $01, $24, $3C, $00, $08
    DB      $02, $F0, $0F, $04, $AB, $2B, $72, $02
    DB      $55, $39, $87, $22, $55, $1D, $44, $33
    DB      $AB, $2B, $72, $22, $55, $39, $87, $22
    DB      $55, $1D, $44, $2B, $72, $1D, $55, $15
    DB      $39, $39, $87, $22, $55, $2D, $44, $2B
    DB      $72, $1D, $55, $1A, $39, $18, $40, $15
    DB      $44, $00, $05, $02, $F1, $1F, $30, $39
    DB      $30, $39, $2B, $36, $30, $39, $30, $39 ; "09+60909"
    DB      $2B, $36, $30, $39, $01, $01, $01, $01
    DB      $1D, $24, $01, $01, $01, $01, $24, $39
    DB      $00, $01, $01, $F1, $FF, $9F, $3C, $42
    DB      $4F, $53, $56, $5F, $67, $71, $78, $86
    DB      $00, $01, $01, $F2, $FF, $5A, $5D, $5E
    DB      $5F, $61, $63, $65, $67, $68, $69, $6B ; "_aceghik"
    DB      $6D, $6F, $72, $74, $75, $77, $7A, $7B ; "mortuwz{"
    DB      $7D, $80, $82, $84, $86, $88, $8A, $8B
    DB      $8D, $00, $01, $05, $2F, $FF, $C0, $FE
    DB      $01, $00, $03, $05, $0F, $FF, $87, $F8
    DB      $89, $94, $84, $75, $10, $80, $00, $01
    DB      $01, $F2, $FF, $73, $6E, $69, $64, $5F
    DB      $5A, $55, $50, $4B, $00, $01, $05, $0F
    DB      $FF, $C0, $C0, $01, $C0, $C0, $01, $00
    DB      $01, $01, $F1, $FF, $9F, $01, $01, $01
    DB      $10, $10, $C0, $10, $10, $01, $01, $01
    DB      $01, $01, $01, $10, $00

SUB_AE00:
    POP     HL                              ; POP HL: return address -> HL (inline data pointer)

LOC_AE01:                                   ; LOC_AE01: -- data block processing loop
    PUSH    AF                              ; PUSH AF: save block selector
    LD      C, (HL)                         ; C = (HL): read bank/page selector
    INC     HL                              ; INC HL
    LD      A, (HL)                         ; A = (HL): read block count
    CP      $00                             ; CP $00: end-of-list?
    JR      Z, LOC_AE21                     ; JR Z, LOC_AE21: count=0 -> done, return past inline data
    LD      B, A                            ; B = A (block count)
    POP     AF                              ; POP AF: restore block selector
    PUSH    BC                              ; PUSH BC: save count/bank
    INC     HL                              ; INC HL
    LD      E, (HL)                         ; E = (HL): read VRAM address lo
    LD      D, $00                          ; D = $00
    LD      B, $00                          ; B = $00
    INC     HL                              ; INC HL
    LD      C, (HL)                         ; C = (HL): read stride (IY = stride)
    PUSH    BC                              ; PUSH BC / POP IY: IY = stride value
    POP     IY                              ; POP IY
    DB      $E3                             ; DB $E3: EX (SP),HL -- swap HL with stacked data ptr (save/restore)
    PUSH    AF                              ; PUSH AF: re-save block selector
    CALL    SUB_AE2E                        ; CALL SUB_AE2E: set VRAM addr + PUT_VRAM for this block
    POP     AF                              ; POP AF
    POP     HL                              ; POP HL: restore inline data pointer
    INC     HL                              ; INC HL: skip to next block entry
    JR      LOC_AE01                        ; JR LOC_AE01: process next block

LOC_AE21:
    POP     AF                              ; POP AF
    INC     HL                              ; INC HL: skip past end-of-list byte
    PUSH    HL                              ; PUSH HL: push return address (past inline data)
    RET                                     ; RET: jump to instruction after inline data block

SUB_AE25:
    CALL    SUB_A8B7                        ; CALL SUB_A8B7: SET bit 1 $705F + INC $70AF (VRAM-lock enter)
    CALL    FILL_VRAM                       ; CALL FILL_VRAM: fill DE bytes at VRAM address HL with A
    JR      LOC_AE34                        ; JR LOC_AE34
    DB      $C9

SUB_AE2E:
    CALL    SUB_A8B7                        ; CALL SUB_A8B7: SET bit 1 $705F + INC $70AF (VRAM-lock enter)
    CALL    PUT_VRAM                        ; CALL PUT_VRAM: copy IY bytes from HL to VRAM at DE
                                            ; LOC_AE34:
LOC_AE34:
    CALL    SUB_A8C3
    RET     
    DB      $DD, $E9

SUB_AE3A:
    JP      (HL)
    DB      $7E, $32, $13, $70, $23, $7E, $F5, $23; JP (HL): indirect jump via HL
    DB      $E5, $DD, $E1, $26, $00, $DD, $6E, $01
    DB      $54, $DD, $5E, $00, $7B, $FE, $FF, $28
    DB      $21, $01, $01, $00, $F1, $F5, $08, $DD
    DB      $E5, $3A, $13, $70, $FE, $00, $20, $06
    DB      $08, $CD, $6D, $1F, $18, $04, $08, $CD
    DB      $6A, $1F, $DD, $E1, $DD, $23, $DD, $23
    DB      $18, $D1, $F1, $C9

SUB_AE77:
    CALL    SUB_A8B7                        ; CALL SUB_A8B7: VRAM-lock enter
    LD      HL, $70B3                       ; INC ($70B3): increment blank-display nesting counter
    INC     (HL)                            ; CALL WRITE_REGISTER ($0182): disable VDP display
    LD      BC, $0182
    JR      LOC_AE91

SUB_AE83:
    CALL    SUB_A8C3                        ; CALL SUB_A8C3: VRAM-lock exit (DEC $70AF)
    LD      HL, $70B3                       ; DEC ($70B3): decrement blank-display nesting counter
    DEC     (HL)                            ; JR NZ: still nested -> keep display off
    LD      A, (HL)                         ; CALL WRITE_REGISTER ($01E2): re-enable VDP display + sprites
    CP      $00
    RET     NZ
    LD      BC, $01E2

LOC_AE91:
    JP      WRITE_REGISTER
    DB      $C5, $D5, $F5, $06, $FF, $11, $FF, $00
    DB      $1B, $7A, $B3, $20, $FB, $10, $F6, $F1
    DB      $D1, $C1, $C9

SUB_AEA7:
    PUSH    IX                              ; PUSH IX
    PUSH    BC                              ; PUSH BC
    PUSH    HL                              ; PUSH HL
    PUSH    DE                              ; PUSH DE
    PUSH    BC                              ; PUSH BC
    CALL    SUB_A8B7                        ; CALL SUB_A8B7: VRAM-lock enter
    LD      B, $00                          ; LD IY from BC: IY = stride (via register rename)
    PUSH    BC                              ; LOC_AEB8: -- tile write loop
    POP     IY
    POP     BC
    LD      C, $00

LOC_AEB8:
    LD      A, $02
    PUSH    BC
    PUSH    HL
    PUSH    DE
    PUSH    IY
    PUSH    AF
    LD      A, (WORK_BUFFER)            ; WORK_BUFFER
    BIT     4, A
    JR      Z, LOC_AECD                     ; JR Z, LOC_AECD: bit 4 of WORK_BUFFER clear -> write mode
    POP     AF
    CALL    GET_VRAM                        ; CALL GET_VRAM: read tile from VRAM (read mode)
    JR      LOC_AED1

LOC_AECD:                                   ; LOC_AECD:
    POP     AF
    CALL    SUB_AE2E                        ; CALL SUB_AE2E: write tile block to VRAM (write mode)

LOC_AED1:
    POP     BC
    POP     DE
    PUSH    BC
    LD      A, (WORK_BUFFER)            ; WORK_BUFFER
    BIT     2, A                            ; BIT 2, A: stride-double flag (WORK_BUFFER bit 2)?
    JR      Z, LOC_AEDE                     ; JR Z, LOC_AEDE: single stride
    LD      BC, $0020                       ; BC = $0020 (double stride = 32 bytes)

LOC_AEDE:
    DB      $EB
    ADD     HL, BC                          ; ADD HL, BC: advance HL by stride
    DB      $EB
    POP     IY
    BIT     4, A
    JR      Z, LOC_AEEA
    POP     BC
    JR      LOC_AEF2

LOC_AEEA:
    POP     HL
    BIT     3, A
    JR      Z, LOC_AEF2
    INC     HL
    DEC     DE
    DEC     DE

LOC_AEF2:
    POP     BC
    DJNZ    LOC_AEB8                        ; DJNZ LOC_AEB8: loop B times
    POP     DE
    POP     HL                              ; POP HL
    POP     BC                              ; POP BC
    POP     IX                              ; POP IX
    CALL    SUB_A8C3                        ; CALL SUB_A8C3: VRAM-lock exit
    RET     

SUB_AEFE:
    PUSH    HL                              ; PUSH HL
    PUSH    BC                              ; PUSH BC
    PUSH    DE                              ; PUSH DE
    PUSH    AF                              ; PUSH AF
    CALL    SUB_A8B7                        ; CALL SUB_A8B7: VRAM-lock enter
    LD      HL, $1838                       ; HL = $1838 (VRAM score row 1 address)
    LD      C, $18                          ; C = $18 (write length)
    CALL    DELAY_LOOP_AF32                 ; CALL DELAY_LOOP_AF32: render score row 1
    LD      HL, $1858                       ; HL = $1858 (VRAM score row 2 address)
    LD      C, $28                          ; C = $28 (write length)
    CALL    DELAY_LOOP_AF32                 ; CALL DELAY_LOOP_AF32: render score row 2
    LD      HL, $1834                       ; HL = $1834 (score digit area base)
    LD      A, ($71A6)                      ; A = ($71A6) room difficulty
    PUSH    AF                              ; PUSH AF
    ADD     A, $18                          ; ADD A, $18: offset into score digit table
    CALL    SUB_AF66                        ; CALL SUB_AF66: write score digit block
    POP     AF                              ; POP AF
    LD      HL, $1854                       ; HL = $1854 (second score digit area)
    ADD     A, $28                          ; ADD A, $28
    CALL    SUB_AF66                        ; CALL SUB_AF66: write second score digit block
    CALL    SUB_A8C3                        ; CALL SUB_A8C3: VRAM-lock exit
    POP     AF
    POP     DE
    POP     BC
    POP     HL
    RET     

DELAY_LOOP_AF32:
    LD      B, $03                          ; B = $03 (3 BCD bytes per row)
    LD      DE, $7017                       ; DE = $7017 (BCD score data buffer at $7015-$7017)

LOC_AF37:                                   ; LOC_AF37: -- BCD digit render loop
    PUSH    BC                              ; PUSH BC: save outer counter
    LD      A, (DE)                         ; A = (DE): read BCD byte
    SRA     A                               ; SRA A
    SRA     A                               ; SRA A
    SRA     A                               ; SRA A
    SRA     A                               ; SRA A: shift hi nibble to lo (upper digit)
    PUSH    BC                              ; PUSH BC
    CALL    SUB_AF54                        ; CALL SUB_AF54: render upper BCD digit tile
    POP     BC                              ; POP BC
    LD      A, (DE)                         ; A = (DE): re-read same BCD byte
    CALL    SUB_AF54                        ; CALL SUB_AF54: render lower BCD digit tile (lo nibble)
    INC     DE                              ; INC DE: advance to next BCD byte
    POP     BC                              ; POP BC
    DJNZ    LOC_AF37                        ; DJNZ LOC_AF37: loop 3 times (all BCD digits)
    LD      HL, $70B1                       ; HL = $70B1 (NMI flags)
    RES     0, (HL)                         ; RES 0, (HL): clear bit 0 (score-render done)
    RET                                     ; RET

SUB_AF54:
    PUSH    HL                              ; PUSH HL
    LD      HL, $70B1                       ; HL = $70B1 (NMI flags)
    AND     $0F                             ; AND $0F: isolate lo nibble (BCD digit 0-9)
    CP      $00                             ; CP $00: zero digit?
    JR      NZ, LOC_AF62                    ; JR NZ, LOC_AF62: nonzero -> render digit
    BIT     0, (HL)                         ; BIT 0, (HL): leading-zero suppress flag
    JR      Z, LOC_AF65                     ; JR Z, LOC_AF65: suppress -> skip (blank tile)
                                            ; LOC_AF62:
LOC_AF62:                                   ; ADD A, C: digit + base tile offset
    ADD     A, C                            ; SET 0, (HL): clear leading-zero flag (digit rendered)
    SET     0, (HL)

LOC_AF65:
    POP     HL

SUB_AF66:
    PUSH    DE                              ; PUSH DE
    LD      DE, $0001                       ; DE = $0001 (one tile per write)
    CALL    SUB_AE25                        ; CALL SUB_AE25: write one score tile to VRAM
    INC     HL                              ; INC HL: advance VRAM address
    POP     DE                              ; POP DE
    RET     

SUB_AF70:
    PUSH    IX                              ; PUSH IX
    PUSH    IY                              ; PUSH IY
    PUSH    AF                              ; PUSH AF
    PUSH    HL                              ; PUSH HL
    LD      IY, $7017                       ; IY = $7017 (BCD score digits lo -> $7015/$7016/$7017)
    LD      A, L                            ; A = L (lo byte of score increment)
    CALL    SUB_AF89                        ; CALL SUB_AF89: add A to $7017 (BCD units)
    LD      A, H                            ; A = H (hi byte of score increment)
    CALL    SUB_AF96                        ; CALL SUB_AF96: add H to $7016 (BCD tens/hundreds)
    POP     HL
    POP     AF
    POP     IY
    POP     IX
    RET     

SUB_AF89:
    SCF                                     ; SCF
    CCF                                     ; CCF: clear carry for clean ADC
    ADC     A, (IY+2)                       ; ADC A, (IY+2): BCD add to score digit [IY+2] (units)
    DAA                                     ; DAA: decimal-adjust result
    LD      (IY+2), A                       ; (IY+2) = A: store adjusted units
    JR      NC, LOC_AFC7                    ; JR NC, LOC_AFC7: no carry -> done
    LD      A, $01                          ; A = $01 (carry into tens)

SUB_AF96:
    SCF                                     ; SCF
    CCF                                     ; CCF: clear carry
    ADC     A, (IY+1)                       ; ADC A, (IY+1): BCD add to score digit [IY+1] (tens)
    DAA                                     ; DAA: decimal-adjust
    LD      (IY+1), A                       ; (IY+1) = A: store adjusted tens
    JR      NC, LOC_AFC7                    ; JR NC, LOC_AFC7: no carry -> done
    PUSH    HL                              ; PUSH HL
    PUSH    AF                              ; PUSH AF
    BIT     0, A                            ; BIT 0, A: odd carry?
    JR      Z, LOC_AFAE                     ; JR Z, LOC_AFAE: even -> INC life counter
    LD      A, ($71A6)                      ; A = ($71A6) room difficulty
    CP      $05                             ; CP $05
    JR      NC, LOC_AFB2                    ; JR NC, LOC_AFB2: difficulty >= 5 -> skip extra life

LOC_AFAE:                                   ; LOC_AFAE:
    LD      HL, $7049                       ; HL = $7049 (life counter)
    INC     (HL)                            ; INC (HL): award extra life (score rollover bonus)

LOC_AFB2:                                   ; LOC_AFB2:
    POP     AF                              ; POP AF
    POP     HL                              ; POP HL
    LD      A, $01                          ; A = $01 (carry into hundreds)
    SCF                                     ; SCF
    CCF                                     ; CCF
    ADC     A, (IY+0)                       ; ADC A, (IY+0): BCD add to score digit [IY+0] (hundreds)
    DAA                                     ; DAA
    LD      (IY+0), A                       ; (IY+0) = A: store adjusted hundreds
    CALL    LOC_AABB                        ; CALL LOC_AABB: refresh lives/score display
    LD      A, $00                          ; A = $00
    CALL    SUB_AC1A                        ; CALL SUB_AC1A: trigger score-chime sound ($00)

LOC_AFC7:
    RET     
    DB      $CB, $0F, $CB, $8C, $30, $02, $CB, $CC
    DB      $CB, $0F, $30, $02, $CB, $CC, $CB, $0F
    DB      $30, $02, $CB, $CC, $E6, $1F, $CB, $4C
    DB      $C8, $3C, $C9, $CD, $C8, $AF, $4F, $78
    DB      $CD, $C8, $AF, $E6, $1F, $06, $00, $21
    DB      $00, $00, $11, $20, $00, $3D, $FE, $00
    DB      $28, $03, $19, $18, $F8, $09, $C9, $FB

; ---- mid-instruction label aliases (EQU) ----
LOC_801D:        EQU $801D
