; COMPILABLE DISASSEMBLY OF FRENZY BY CAPTAIN COZMOS (10 AUGUST 2022) V7.0
; 1ST OF A KIND, STILL NEEDS CLEANUP.
; CREDIT GOES WHERE CREDIT IS DUE.  THIS IS A PAINFUL, TIME CONSUMING EXPERIENCE.
BOOT_UP:           EQU $0000
AMERICA:           EQU $0069
POWER_UP:          EQU $006E
DECLSN:            EQU $0190
DECMSN:            EQU $019B
MSNTOLSN:          EQU $01A6
ADD816:            EQU $01B1
SET_UP_WRITE:      EQU $0623
PUTSEMI:           EQU $06FF
PX_TO_PTRN_POS:    EQU $07E8
GET_BKGRND:        EQU $0898
PUT_FRAME:         EQU $080B
CALC_OFFSET:       EQU $08C0
PUT0SPRITE:        EQU $08DF
PUT1SPRITE:        EQU $0955
PUT_MOBILE:        EQU $0A87
PUTCOMPLEX:        EQU $0EA2
CONT_READ:         EQU $113D
CONTROLLER_INIT:   EQU $1105
JOY_DBNCE:         EQU $12B9
FIRE_DBNCE:        EQU $1289
ARM_DBNCE:         EQU $12E9
KBD_DBNCE:         EQU $1250
DISPLAY_LOGO:      EQU $1319
PLAY_SONGS:        EQU $1F61
ACTIVATEP:         EQU $1F64
REFLECT_VERTICAL:  EQU $1F6A
REFLECT_HORZONTAL: EQU $1F6D
ROTATE_90:         EQU $1F70
ENLARGE:           EQU $1F73
CONTROLLER_SCAN:   EQU $1F76
DECODER:           EQU $1F79
GAME_OPT:          EQU $1F7C
LOAD_ASCII:        EQU $1F7F
FILL_VRAM:         EQU $1F82
MODE_1:            EQU $1F85
UPDATE_SPINNER:    EQU $1F88

INIT_TABLEP:       EQU $1F8B
PUT_VRAMP:         EQU $1F91
INIT_SPR_ORDERP:   EQU $1F94
INIT_TIMERP:       EQU $1F9A
REQUEST_SIGNALP:   EQU $1FA0
TEST_SIGNALP:      EQU $1FA3
WRITE_REGISTERP:   EQU $1FA6
INIT_WRITERP:      EQU $1FAF
SOUND_INITP:       EQU $1FB2
PLAY_ITP:          EQU $1FB5

INIT_TABLE:        EQU $1FB8
GET_VRAM:          EQU $1FBB
PUT_VRAM:          EQU $1FBE
INIT_SPR_NM_TBL:   EQU $1FC1
WR_SPR_NM_TBL:     EQU $1FC4
INIT_TIMER:        EQU $1FC7
FREE_SIGNAL:       EQU $1FCA
REQUEST_SIGNAL:    EQU $1FCD
TEST_SIGNAL:       EQU $1FD0
TIME_MGR:          EQU $1FD3
TURN_OFF_SOUND:    EQU $1FD6
WRITE_REGISTER:    EQU $1FD9
READ_REGISTER:     EQU $1FDC
WRITE_VRAM:        EQU $1FDF
READ_VRAM:         EQU $1FE2
INIT_WRITER:       EQU $1FE5
WRITER:            EQU $1FE8
POLLER:            EQU $1FEB
SOUND_INIT:        EQU $1FEE
PLAY_IT:           EQU $1FF1
SOUND_MAN:         EQU $1FF4
ACTIVATE:          EQU $1FF7
PUTOBJ:            EQU $1FFA
RAND_GEN:          EQU $1FFD

WORK_BUFFER:       EQU $7000
STACKTOP:          EQU $73B9
CONTROLLER_BUFFER: EQU $702B

RAM_AA: EQU $7037
RAM_BB: EQU $705C
RAM_CC: EQU $707C
RAM_DD: EQU $709B
RAM_EE: EQU $70AE
RAM_FF: EQU $70C0
RAM_GG: EQU $70CD
RAM_HH: EQU $7103
RAM_II: EQU $7105
RAM_JJ: EQU $7109
RAM_KK: EQU $710C
RAM_LL: EQU $710F
RAM_MM: EQU $713F
RAM_NN: EQU $7243
RAM_OO: EQU $7244
RAM_PP: EQU $7248
RAM_QQ: EQU $724D
RAM_RR: EQU $7251
RAM_SS: EQU $7299
RAM_TT: EQU $72B4
RAM_UU: EQU $72E6
RAM_VV: EQU $72FC
RAM_WW: EQU $731F
RAM_XX: EQU $7320
RAM_YY: EQU $733E
RAM_ZZ: EQU $73C8
RAM_EXTRA: EQU $73F4

FNAME "FRENZY V7.ROM"
CPU Z80

    ORG     8000H
    DW 		0AA55H ;55AAH
    DW 		0
    DW 		0
	DW 		WORK_BUFFER
    DW 		CONTROLLER_BUFFER
    DW 		START
    JP      PUT_VRAM
    JP      GET_VRAM
    JP      SUB_80D4
    JP      SUB_80E1
	RET 
    NOP
    NOP
	RET 
	RETI
    NOP
    NOP
	RETN
    NOP
    DEC E

	DB  " 1982 STERN ELECTRONICS, INC.","/PRESENTS STERN'S FRENZY",1EH,1FH,"/1983"

START:
    LD      HL, WORK_BUFFER
    LD      DE, WORK_BUFFER+1
    LD      BC, 3BFH
    LD      (HL), 0
    LDIR
    CALL    SUB_A18F

SUB_8070:
    XOR     A
    LD      (RAM_CC+0FH), A
    LD      (RAM_CC+10H), A
    LD      (RAM_DD+0CH), A
    LD      (RAM_FF), A
    LD      (RAM_UU+2), A
    LD      (RAM_SS+0AH), A
    LD      (RAM_UU), A
    LD      (RAM_UU+1), A
    LD      (RAM_UU+3), A
    LD      (RAM_UU+4), A
    LD      (RAM_UU+5), A
    DEC     A
    LD      (RAM_SS+0BH), A
    CALL    SUB_8FD0
    CALL    SUB_A159
    CALL    SUB_8FD0
    CALL    SUB_80EE
    CALL    SUB_C86A
    CALL    SUB_8C70
    CALL    SUB_C37F
    CALL    SUB_C37C

SUB_80AE:
    CALL    SUB_A15C
    CALL    TIME_MGR
    CALL    SUB_8DA5
    CALL    SUB_8546
    CALL    SUB_8299
    CALL    SUB_A174
    CALL    SUB_89E7
    CALL    SUB_B86E
    CALL    SUB_C382
    LD      A, (RAM_VV+8)
    CALL    TEST_SIGNAL
    CALL    NZ, SUB_A183
    JR      SUB_80AE

SUB_80D4:
    SRL     B
    SRL     B
    SRL     B
    SRL     C
    SRL     C
    SRL     C
RET 

SUB_80E1:
    SRL     D
    SRL     D
    SRL     D
    SRL     E
    SRL     E
    SRL     E
RET 

SUB_80EE:
    LD      HL,  RAM_PP+1
    LD      B, 50H

SUB_80F3:
    LD      (HL), 0
    INC     HL
    DJNZ    SUB_80F3
    LD      HL, RAM_PP
    LD      B, 14H

SUB_80FD:
    INC     HL
    INC     HL
    INC     HL
    INC     HL
    LD      (HL), 0FH
    DJNZ    SUB_80FD
    LD      HL,  RAM_PP+1
    LD      DE, 0BH
    LD      IY, 14H
    LD      A, 0
    JP      PUT_VRAM

SUB_8114:
    LD      L, C
    LD      H, 0
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    LD      E, B
    LD      D, 0
    ADD     HL, DE
    EX      DE, HL
RET 

SUB_8122:
    PUSH    HL
    PUSH    BC
    LD      A, B
    CP      0EH
    JP      C, SUB_81EA
    JR      NZ, SUB_813B
    PUSH    AF
    LD      A, 1
    LD      (RAM_FF), A
    INC     A
    LD      (RAM_FF+6), A
    INC     A
    LD      (RAM_FF+5), A
    POP     AF

SUB_813B:
    CP      0F2H
    JP      NC, SUB_81EA
    CP      0F1H
    JR      NZ, SUB_8153
    PUSH    AF
    LD      A, 1
    LD      (RAM_FF), A
    INC     A
    LD      (RAM_FF+5), A
    INC     A
    LD      (RAM_FF+6), A
    POP     AF

SUB_8153:
    PUSH    BC
    RST     18H
    DEC     C
    CALL    SUB_8114
    LD      HL, WORK_BUFFER
    PUSH    HL
    LD      B, 4

SUB_815F:
    PUSH    HL
    PUSH    DE
    PUSH    BC
    LD      IY, 1
    LD      A, 2
    RST     10H
    POP     BC
    POP     DE
    LD      HL, 20H
    ADD     HL, DE
    EX      DE, HL
    POP     HL
    INC     HL
    DJNZ    SUB_815F
    POP     HL
    POP     BC
    LD      A, 7
    AND     C
    OR      A
    JR      Z, SUB_8185
    INC     HL
    CP      4
    JR      C, SUB_8197
    JR      Z, SUB_81BA
    JR      SUB_81D1

SUB_8185:
    LD      A, (HL)
    INC     HL
    CP      17H
    JR      Z, SUB_81DF
    CP      1DH
    JR      Z, SUB_81DF
    CP      16H
    JR      Z, SUB_81DF
    CP      38H
    JR      NC, SUB_81DF

SUB_8197:
    LD      A, (HL)
    CP      17H
    JR      NZ, SUB_81EA
    INC     HL
    LD      A, (HL)
    CP      17H
    JR      NZ, SUB_81EA
    INC     HL
    LD      A, (HL)
    CP      17H
    JR      Z, SUB_81EE
    CP      1CH
    JR      Z, SUB_81EE
    CP      2DH ; '-'
    JR      Z, SUB_81EE
    CP      16H
    JR      Z, SUB_81EE
    CP      38H
    JR      NC, SUB_81EE
    JR      SUB_81EA

SUB_81BA:
    LD      A, (HL)
    CP      17H
    JR      NZ, SUB_81D1
    INC     HL
    LD      A, (HL)
    CP      17H
    JR      NZ, SUB_81EA
    INC     HL
    LD      A, (HL)
    CP      17H
    JR      Z, SUB_81EE
    CP      1CH
    JR      Z, SUB_81EE
    JR      SUB_81EA

SUB_81D1:
    LD      A, (HL)
    INC     HL
    CP      17H
    JR      Z, SUB_81DF
    CP      1DH
    JR      Z, SUB_81DF
    CP      2BH
    JR      NZ, SUB_81EA

SUB_81DF:
    LD      A, (HL)
    CP      17H
    JR      NZ, SUB_81EA
    INC     HL
    LD      A, (HL)
    CP      17H
    JR      Z, SUB_81EE

SUB_81EA:
    POP     BC
    POP     HL
    XOR     A
RET 

SUB_81EE:
    POP     BC
    POP     HL
    LD      A, 1
    OR      A
RET 

SUB_81F4:
    PUSH    HL
    PUSH    BC
    LD      A, C
    CP      11H
    JR      NC, SUB_8209
    PUSH    AF
    LD      A, 1
    LD      (RAM_FF), A
    LD      (RAM_FF+5), A
    XOR     A
    LD      (RAM_FF+6), A
    POP     AF

SUB_8209:
    CP      0B7H
    JR      C, SUB_821B
    PUSH    AF
    LD      A, 1
    LD      (RAM_FF), A
    LD      (RAM_FF+6), A
    XOR     A
    LD      (RAM_FF+5), A
    POP     AF

SUB_821B:
    PUSH    BC
    RST     18H
    CALL    SUB_8114
    LD      HL, WORK_BUFFER
    PUSH    HL
    LD      IY, 3
    LD      A, 2
    RST     10H
    CALL    SUB_8D77
    POP     HL
    POP     BC
    CP      9
    JR      Z, SUB_8249
    CP      0CH
    JR      Z, SUB_8249
    LD      A, 7
    AND     B
    CP      2
    JR      C, SUB_825C
    CP      4
    JR      C, SUB_8265
    CP      6
    JR      C, SUB_8279
    JR      SUB_8283

SUB_8249:
    LD      A, 7
    AND     B
    OR      A
    JR      Z, SUB_825C
    CP      3
    JR      C, SUB_8265
    CP      5
    JR      C, SUB_8279
    CP      7
    JR      C, SUB_8283
    INC     HL

SUB_825C:
    LD      A, (HL)
    INC     HL
    CP      17H
    JP      NZ, SUB_81EA
    JR      SUB_8270

SUB_8265:
    LD      A, (HL)
    INC     HL
    CP      19H
    JR      Z, SUB_8270
    CP      17H
    JP      NZ, SUB_81EA

SUB_8270:
    LD      A, (HL)
    CP      17H
    JP      NZ, SUB_81EA
    JP      SUB_81EE

SUB_8279:
    LD      A, (HL)
    CP      19H
    JR      Z, SUB_8283
    CP      17H
    JP      NZ, SUB_81EA

SUB_8283:
    INC     HL
    LD      A, (HL)
    CP      17H
    JP      NZ, SUB_81EA
    INC     HL
    LD      A, (HL)
    CP      17H
    JP      Z, SUB_81EE
    CP      1AH
    JP      Z, SUB_81EE
    JP      SUB_81EA

SUB_8299:
    LD      HL, RAM_DD
    LD      A, (RAM_SS+0AH)
    OR      A
    JP      Z, SUB_8323
    LD      A, (HL)
    CP      11H
    JR      NC, SUB_82B4
    LD      (HL), 11H
    LD      IX, PO_DATA_9BE2
    CALL    PUTOBJ
    JP      SUB_C8DE

SUB_82B4:
    LD      A, (RAM_DD+7)
    OR      A
	RET      NZ
    LD      A, (RAM_DD+8)
    OR      A
	RET      NZ
    LD      A, (HL)
    INC     A
    CP      15H
    JR      C, SUB_831B
    LD      A, (RAM_SS+0AH)
    CP      5
    JR      NZ, SUB_8315
    LD      A, (RAM_SS+0BH)
    CP      0FFH
    JR      NZ, SUB_8302
    XOR     A
    LD      HL, 78H
    CALL    REQUEST_SIGNAL
    LD      (RAM_SS+0BH), A
    LD      HL, WORK_BUFFER
    PUSH    HL
    PUSH    HL
    LD      DE, 0
    LD      IY, 2
    LD      A, 0
    RST     10H
    POP     IX
    LD      (IX+0), 0C0H
    LD      (IX+4), 0C0H
    POP     HL
    LD      DE, 0
    LD      IY, 2
    LD      A, 0
    JP      PUT_VRAM

SUB_8302:
    CALL    TEST_SIGNAL
	RET      Z
    LD      A, 0FFH
    LD      (RAM_SS+0BH), A
    CALL    SUB_8F4B
    DEC     (HL)
    CALL    SUB_A192
    JP      SUB_8E5A

SUB_8315:
    INC     A
    LD      (RAM_SS+0AH), A
    LD      A, 11H

SUB_831B:
    LD      (HL), A
    LD      IX, PO_DATA_9BE2
    JP      PUTOBJ

SUB_8323:
    PUSH    HL
    INC     HL
    LD      B, (HL)
    INC     HL
    INC     HL
    LD      C, (HL)
    POP     HL
    CALL    SUB_8D77
    JP      NZ, SUB_846F
    OR      A
    JR      NZ, SUB_8368

SUB_8333:
    CALL    SUB_8D77
    LD      HL, RAM_DD
    LD      A, E
    CP      2
    JR      Z, SUB_8346
    CP      3
    JR      Z, SUB_8346
    CP      6
    JR      NZ, SUB_834B

SUB_8346:
    LD      (HL), 4
    JP      SUB_845B

SUB_834B:
    CP      8
    JR      Z, SUB_8357
    CP      9
    JR      Z, SUB_8357
    CP      0CH
    JR      NZ, SUB_835C

SUB_8357:
    LD      (HL), 0DH
    JP      SUB_845B

SUB_835C:
    CP      1
    JR      Z, SUB_8363
    CP      4
	RET      NZ

SUB_8363:
    LD      (HL), 0
    JP      SUB_845B

SUB_8368:
    CP      1
    JR      NZ, SUB_8395
    DEC     C
    CALL    SUB_81F4
    JR      Z, SUB_8333

SUB_8372:
    LD      HL, RAM_DD
    PUSH    HL
    INC     HL
    LD      (HL), B
    INC     HL
    INC     HL
    LD      (HL), C
    POP     HL
    CALL    SUB_8D77
    CP      E
    JR      Z, SUB_8384
    LD      (HL), 0

SUB_8384:
    LD      A, (RAM_DD+8)
    OR      A
	RET      NZ
    LD      A, (HL)
    INC     A
    CP      4
    JR      C, SUB_8391
    LD      A, 1

SUB_8391:
    LD      (HL), A
    JP      SUB_845B

SUB_8395:
    CP      2
    JR      NZ, SUB_83A7
    PUSH    BC
    LD      A, B
    ADD     A, 0EH
    LD      B, A
    CALL    SUB_8122
    POP     BC
    JR      Z, SUB_8333
    INC     B
    JR      SUB_8372

SUB_83A7:
    CP      3
    JR      NZ, SUB_83C1
    DEC     C
    PUSH    BC
    LD      A, B
    ADD     A, 0EH
    LD      B, A
    CALL    SUB_8122
    POP     BC
    JP      Z, SUB_8333
    CALL    SUB_81F4
    JP      Z, SUB_8333
    INC     B
    JR      SUB_8372

SUB_83C1:
    CP      4
    JR      NZ, SUB_83D4
    INC     C
    PUSH    BC
    LD      A, C
    ADD     A, 0FH
    LD      C, A
    CALL    SUB_81F4
    POP     BC
    JP      Z, SUB_8333
    JR      SUB_8372

SUB_83D4:
    CP      6
    JR      NZ, SUB_83F5
    INC     C
    PUSH    BC
    LD      A, B
    ADD     A, 0EH
    LD      B, A
    CALL    SUB_8122
    POP     BC
    JP      Z, SUB_8333
    PUSH    BC
    LD      A, C
    ADD     A, 0FH
    LD      C, A
    CALL    SUB_81F4
    POP     BC
    JP      Z, SUB_8333
    INC     B
    JP      SUB_8372

SUB_83F5:
    CP      8
    JR      NZ, SUB_8426
    DEC     B
    PUSH    BC
    INC     B
    INC     B
    CALL    SUB_8122
    POP     BC
    JP      Z, SUB_8333

SUB_8404:
    LD      HL, RAM_DD
    PUSH    HL
    INC     HL
    LD      (HL), B
    INC     HL
    INC     HL
    LD      (HL), C
    POP     HL
    CALL    SUB_8D77
    CP      E
    JR      Z, SUB_8416
    LD      (HL), 9

SUB_8416:
    LD      A, (RAM_DD+8)
    OR      A
	RET      NZ
    LD      A, (HL)
    INC     A
    CP      0DH
    JR      C, SUB_8423
    LD      A, 0AH

SUB_8423:
    LD      (HL), A
    JR      SUB_845B

SUB_8426:
    CP      9
    JR      NZ, SUB_843E
    DEC     B
    DEC     C
    PUSH    BC
    INC     B
    INC     B
    CALL    SUB_8122
    POP     BC
    JP      Z, SUB_8333
    CALL    SUB_81F4
    JP      Z, SUB_8333
    JR      SUB_8404

SUB_843E:
    CP      0CH
	RET      NZ
    INC     C
    DEC     B
    PUSH    BC
    LD      A, C
    ADD     A, 0FH
    LD      C, A
    CALL    SUB_81F4
    POP     BC
    JP      Z, SUB_8333
    PUSH    BC
    INC     B
    INC     B
    CALL    SUB_8122
    POP     BC
    JP      Z, SUB_8333
    JR      SUB_8404

SUB_845B:
    LD      HL,  RAM_DD+3
    LD      A, (HL)
    DEC     A
    LD      (HL), A
    LD      IX, PO_DATA_9BE2
    CALL    PUTOBJ
    LD      HL,  RAM_DD+3
    LD      A, (HL)
    INC     A
    LD      (HL), A
RET 

SUB_846F:
    OR      A
    JP      Z, SUB_8333
    CP      1
    JR      NZ, SUB_8484
    LD      (HL), 9
    LD      A, B
    ADD     A, 0CH
    LD      B, A
    DEC     C
    DEC     C
    DEC     C
    LD      A, 0D8H
    JR      SUB_84E3

SUB_8484:
    CP      2
    JR      NZ, SUB_8491
    LD      (HL), 5
    INC     B
    INC     B
    INC     C
    LD      A, 0D4H
    JR      SUB_84E3

SUB_8491:
    CP      3
    JR      NZ, SUB_849E
    LD      (HL), 6
    DEC     B
    DEC     B
    DEC     C
    LD      A, 0E4H
    JR      SUB_84E3

SUB_849E:
    CP      4
    JR      NZ, SUB_84AC
    LD      (HL), 8
    LD      A, B
    ADD     A, 0CH
    LD      B, A
    LD      A, 0DCH
    JR      SUB_84E3

SUB_84AC:
    CP      6
    JR      NZ, SUB_84BB
    LD      (HL), 7
    DEC     B
    LD      A, C
    ADD     A, 0F8H
    LD      C, A
    LD      A, 0ECH
    JR      SUB_84E3

SUB_84BB:
    CP      8
    JR      NZ, SUB_84C8
    LD      (HL), 0EH
    DEC     B
    DEC     B
    INC     C
    LD      A, 0D0H
    JR      SUB_84E3

SUB_84C8:
    CP      9
    JR      NZ, SUB_84D5
    LD      (HL), 0FH
    INC     B
    INC     B
    DEC     C
    LD      A, 0E0H
    JR      SUB_84E3

SUB_84D5:
    CP      0CH
    JP      NZ, SUB_8333
    LD      (HL), 10H
    INC     B
    LD      A, C
    ADD     A, 0F8H
    LD      C, A
    LD      A, 0E8H

SUB_84E3:
    PUSH    AF
    PUSH    BC
    LD      B, 0
    LD      A, (RAM_PP+1)
    OR      A
    JR      Z, SUB_84EE
    INC     B

SUB_84EE:
    LD      A, (RAM_QQ)
    OR      A
    JR      Z, SUB_84F5
    INC     B

SUB_84F5:
    LD      A, B
    CP      2
    JR      C, SUB_84FF

SUB_84FA:
    POP     BC
    POP     AF
    JP      SUB_845B

SUB_84FF:
    LD      A, (RAM_SS+6)
    CALL    TEST_SIGNAL
    JR      Z, SUB_84FA
    LD      A, (RAM_SS+6)
    CALL    FREE_SIGNAL
    LD      A, 1
    LD      HL, 1EH
    CALL    REQUEST_SIGNAL
    LD      (RAM_SS+6), A
    POP     BC
    LD      HL,  RAM_PP+1
    LD      DE, 0BH
    LD      A, (HL)
    OR      A
    JR      Z, SUB_8531
    LD      HL, RAM_QQ
    LD      DE, 0CH
    LD      A, (HL)
    OR      A
    JR      Z, SUB_8531
    POP     AF
    JP      SUB_845B

SUB_8531:
    LD      (HL), C
    INC     HL
    LD      (HL), B
    INC     HL
    POP     AF
    LD      (HL), A
    DEC     HL
    DEC     HL
    LD      IY, 1
    LD      A, 0
    RST     8
    CALL    SUB_C89D
    JP      SUB_845B

SUB_8546:
    LD      HL,  RAM_PP+1
    LD      DE, 0BH
    CALL    SUB_8576
    LD      HL, RAM_QQ
    LD      DE, 0CH
    CALL    SUB_8576
    LD      A, (RAM_DD+7)
    OR      A
RET      Z
    LD      HL, RAM_RR
    LD      DE, 0DH
    LD      B, 12H

SUB_8565:
    PUSH    BC
    PUSH    DE
    PUSH    HL
    CALL    SUB_8576
    POP     HL
    LD      DE, 4
    ADD     HL, DE
    POP     DE
    INC     DE
    POP     BC
    DJNZ    SUB_8565
RET 

SUB_8576:
    LD      A, (HL)
    OR      A
	RET      Z
    PUSH    HL
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    INC     HL
    LD      A, (HL)
    POP     HL
    CP      0D0H
    JR      Z, SUB_859E
    CP      0D4H
    JR      Z, SUB_85A8
    CP      0D8H
    JR      Z, SUB_85B6
    CP      0DCH
    JR      Z, SUB_85C0
    CP      0E0H
    JR      Z, SUB_85CE
    CP      0E4H
    JR      Z, SUB_85DA
    CP      0E8H
    JR      Z, SUB_85EA
    JR      SUB_85FA

SUB_859E:
    PUSH    BC
    CALL    SUB_B868
    POP     BC
	RET      Z
    DEC     B
    DEC     B
    JR      SUB_860C

SUB_85A8:
    PUSH    BC
    LD      A, B
    ADD     A, 0FH
    LD      B, A
    CALL    SUB_B868
    POP     BC
	RET      Z
    INC     B
    INC     B
    JR      SUB_860C

SUB_85B6:
    PUSH    BC
    CALL    SUB_B868
    POP     BC
	RET      Z
    DEC     C
    DEC     C
    JR      SUB_860C

SUB_85C0:
    PUSH    BC
    LD      A, C
    ADD     A, 0FH
    LD      C, A
    CALL    SUB_B868
    POP     BC
	RET      Z
    INC     C
    INC     C
    JR      SUB_860C

SUB_85CE:
    PUSH    BC
    CALL    SUB_B868
    POP     BC
	RET      Z
    DEC     B
    DEC     B
    DEC     C
    DEC     C
    JR      SUB_860C

SUB_85DA:
    PUSH    BC
    LD      A, B
    ADD     A, 0FH
    LD      B, A
    CALL    SUB_B868
    POP     BC
	RET      Z
    INC     B
    INC     B
    DEC     C
    DEC     C
    JR      SUB_860C

SUB_85EA:
    PUSH    BC
    LD      A, C
    ADD     A, 0FH
    LD      C, A
    CALL    SUB_B868
    POP     BC
	RET      Z
    DEC     B
    DEC     B
    INC     C
    INC     C
    JR      SUB_860C

SUB_85FA:
    PUSH    BC
    LD      A, B
    ADD     A, 0FH
    LD      B, A
    LD      A, C
    ADD     A, 0FH
    LD      C, A
    CALL    SUB_B868
    POP     BC
	RET      Z
    INC     B
    INC     B
    INC     C
    INC     C

SUB_860C:
    LD      (HL), C
    INC     HL
    LD      (HL), B
    DEC     HL
    PUSH    HL
    PUSH    DE
    PUSH    BC
    LD      IY, 1
    LD      A, 0
    RST     8
    POP     BC
    POP     DE
    POP     HL
RET 

SUB_861E:
    INC     HL
    LD      B, (HL)
    INC     HL
    INC     HL
    LD      C, (HL)
    LD      A, B
    ADD     A, 4
    LD      B, A
    LD      A, C
    ADD     A, 4
    LD      C, A
    RST     18H
RET 

SUB_862D:
    LD      HL,  RAM_DD+1
    LD      D, (HL)
    INC     HL
    INC     HL
    LD      E, (HL)
    RST     20H
RET 

SUB_8636:
    PUSH    IY
    PUSH    BC
    PUSH    HL
    CALL    SUB_8114
    POP     HL
    PUSH    HL
    LD      IY, 1
    LD      A, 2
    RST     10H
    POP     HL
    POP     BC
    LD      A, (HL)
    CP      17H
    POP     IY
RET 

SUB_864E:
    LD      A, (HL)
    CP      27H
    JP      NC, SUB_88D2
    PUSH    HL
    CALL    SUB_861E
    PUSH    BC
    LD      HL, RAM_DD
    CALL    SUB_861E
    PUSH    BC
    POP     DE
    POP     BC
    POP     HL
    PUSH    BC
    PUSH    DE
    PUSH    HL
    LD      A, C
    CP      E
    JP      Z, SUB_87C0
    LD      A, B
    CP      D
    JP      Z, SUB_8846
    LD      A, E
    CP      C
    JR      C, SUB_867B
    LD      A, D
    CP      B
    JR      NC, SUB_8683
    JP      SUB_86CE

SUB_867B:
    LD      A, D
    CP      B
    JP      NC, SUB_8719
    JP      SUB_875F

SUB_8683:
    CALL    SUB_862D
    LD      A, D
    INC     A
    CP      B
    JR      C, SUB_86A1
    ADD     A, 0FCH
    CP      B
    JR      NC, SUB_86A1
    LD      A, E
    INC     A
    CP      C
    JR      C, SUB_86A1
    ADD     A, 0FCH
    CP      C
    JR      NC, SUB_86A1
    LD      A, (RAM_UU+6)
    OR      A
    JP      Z, SUB_87A6

SUB_86A1:
    INC     C
    INC     C
    LD      HL, WORK_BUFFER
    CALL    SUB_8636
    JP      NZ, SUB_87A6
    INC     B
    CALL    SUB_8636
    JP      NZ, SUB_87A6
    INC     B
    CALL    SUB_8636
    JP      NZ, SUB_87A6
    DEC     C
    CALL    SUB_8636
    JP      NZ, SUB_87A6
    DEC     C
    CALL    SUB_8636
    JP      NZ, SUB_87A6
    POP     HL
    POP     DE
    POP     BC
    LD      (HL), 22H
RET 

SUB_86CE:
    CALL    SUB_862D
    LD      A, D
    ADD     A, 3
    CP      B
    JR      C, SUB_86ED
    ADD     A, 0FCH
    CP      B
    JR      NC, SUB_86ED
    LD      A, E
    INC     A
    CP      C
    JR      C, SUB_86ED
    ADD     A, 0FCH
    CP      C
    JR      NC, SUB_86ED
    LD      A, (RAM_UU+6)
    OR      A
    JP      Z, SUB_87A6

SUB_86ED:
    DEC     B
    LD      HL, WORK_BUFFER
    CALL    SUB_8636
    JP      NZ, SUB_87A6
    INC     C
    CALL    SUB_8636
    JP      NZ, SUB_87A6
    INC     C
    CALL    SUB_8636
    JP      NZ, SUB_87A6
    INC     B
    CALL    SUB_8636
    JP      NZ, SUB_87A6
    INC     B
    CALL    SUB_8636
    JP      NZ, SUB_87A6
    POP     HL
    POP     DE
    POP     BC
    LD      (HL), 1AH
RET 

SUB_8719:
    CALL    SUB_862D
    LD      A, D
    INC     A
    CP      B
    JR      C, SUB_8738
    ADD     A, 0FCH
    CP      B
    JR      NC, SUB_8738
    LD      A, E
    ADD     A, 3
    CP      C
    JR      C, SUB_8738
    ADD     A, 0FCH
    CP      C
    JR      NC, SUB_8738
    LD      A, (RAM_UU+6)
    OR      A
    JP      Z, SUB_87A6

SUB_8738:
    DEC     C
    LD      HL, WORK_BUFFER
    CALL    SUB_8636
    JR      NZ, SUB_87A6
    INC     B
    CALL    SUB_8636
    JR      NZ, SUB_87A6
    INC     B
    CALL    SUB_8636
    JR      NZ, SUB_87A6
    INC     C
    CALL    SUB_8636
    JR      NZ, SUB_87A6
    INC     C
    CALL    SUB_8636
    JR      NZ, SUB_87A6
    POP     HL
    POP     DE
    POP     BC
    LD      (HL), 16H
RET 

SUB_875F:
    CALL    SUB_862D
    LD      A, D
    ADD     A, 3
    CP      B
    JR      C, SUB_877E
    ADD     A, 0FCH
    CP      B
    JR      NC, SUB_877E
    LD      A, E
    ADD     A, 3
    CP      C
    JR      C, SUB_877E
    ADD     A, 0FCH
    CP      C
    JR      NC, SUB_877E
    LD      A, (RAM_UU+6)
    OR      A
    JR      Z, SUB_87A6

SUB_877E:
    DEC     B
    INC     C
    LD      HL, WORK_BUFFER
    CALL    SUB_8636
    JR      NZ, SUB_87A6
    DEC     C
    CALL    SUB_8636
    JR      NZ, SUB_87A6
    DEC     C
    CALL    SUB_8636
    JR      NZ, SUB_87A6
    INC     B
    CALL    SUB_8636
    JR      NZ, SUB_87A6
    INC     B
    CALL    SUB_8636
    JR      NZ, SUB_87A6
    POP     HL
    POP     DE
    POP     BC
    LD      (HL), 1EH
RET 

SUB_87A6:
    POP     HL
    POP     DE
    POP     BC
    LD      A, (RAM_UU+6)
    OR      A
    JR      Z, SUB_87BD
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IY
    POP     IX
    CALL    SUB_B87A
    POP     HL
    POP     DE
    POP     BC
RET 

SUB_87BD:
    PUSH    BC
    PUSH    DE
    PUSH    HL

SUB_87C0:
    LD      A, D
    CP      B
    JP      Z, SUB_8846
    JR      NC, SUB_87F9
    CALL    SUB_862D
    LD      A, D
    CP      B
    JR      NC, SUB_87E4
    ADD     A, 3
    CP      B
    JR      C, SUB_87E4
    LD      A, E
    ADD     A, 2
    CP      C
    JR      C, SUB_87E4
    ADD     A, 0FCH
    CP      C
    JR      NC, SUB_87E4
    LD      A, (RAM_UU+6)
    OR      A
    JR      Z, SUB_882C

SUB_87E4:
    DEC     B
    LD      HL, WORK_BUFFER
    CALL    SUB_8636
    JR      NZ, SUB_882C
    INC     C
    CALL    SUB_8636
    JR      NZ, SUB_882C
    POP     HL
    POP     DE
    POP     BC
    LD      (HL), 0AH
RET 

SUB_87F9:
    CALL    SUB_862D
    LD      A, D
    CP      B
    JR      C, SUB_8816
    ADD     A, 0FDH
    CP      B
    JR      NC, SUB_8816
    LD      A, E
    ADD     A, 2
    CP      C
    JR      C, SUB_8816
    ADD     A, 0FCH
    CP      C
    JR      NC, SUB_8816
    LD      A, (RAM_UU+6)
    OR      A
    JR      Z, SUB_882C

SUB_8816:
    INC     B
    INC     B
    LD      HL, WORK_BUFFER
    CALL    SUB_8636
    JR      NZ, SUB_882C
    INC     C
    CALL    SUB_8636
    JR      NZ, SUB_882C
    POP     HL
    POP     DE
    POP     BC
    LD      (HL), 6
RET 

SUB_882C:
    POP     HL
    POP     DE
    POP     BC
    LD      A, (RAM_UU+6)
    OR      A
    JR      Z, SUB_8843
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IY
    POP     IX
    CALL    SUB_B87A
    POP     HL
    POP     DE
    POP     BC
RET 

SUB_8843:
    PUSH    BC
    PUSH    DE
    PUSH    HL

SUB_8846:
    LD      A, E
    CP      C
    JR      Z, SUB_88B4
    JR      NC, SUB_8880
    CALL    SUB_862D
    LD      A, D
    ADD     A, 2
    CP      B
    JR      C, SUB_886B
    ADD     A, 0FCH
    CP      B
    JR      NC, SUB_886B
    LD      A, E
    ADD     A, 3
    CP      C
    JR      C, SUB_886B
    ADD     A, 0FDH
    CP      C
    JR      NC, SUB_886B
    LD      A, (RAM_UU+6)
    OR      A
    JR      Z, SUB_88B4

SUB_886B:
    DEC     C
    LD      HL, WORK_BUFFER
    CALL    SUB_8636
    JR      NZ, SUB_88B4
    INC     B
    CALL    SUB_8636
    JR      NZ, SUB_88B4
    POP     HL
    POP     DE
    POP     BC
    LD      (HL), 12H
RET 

SUB_8880:
    CALL    SUB_862D
    LD      A, D
    ADD     A, 2
    CP      B
    JR      C, SUB_889E
    ADD     A, 0FCH
    CP      B
    JP      P, SUB_889E
    LD      A, E
    CP      C
    JR      C, SUB_889E
    ADD     A, 0FDH
    CP      C
    JR      NC, SUB_889E
    LD      A, (RAM_UU+6)
    OR      A
    JR      Z, SUB_88B4

SUB_889E:
    INC     C
    INC     C
    LD      HL, WORK_BUFFER
    CALL    SUB_8636
    JR      NZ, SUB_88B4
    INC     B
    CALL    SUB_8636
    JR      NZ, SUB_88B4
    POP     HL
    POP     DE
    POP     BC
    LD      (HL), 0EH
RET 

SUB_88B4:
    POP     HL
    POP     DE
    POP     BC
    LD      A, (RAM_UU+6)
    OR      A
    JR      Z, SUB_88CB
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IY
    POP     IX
    CALL    SUB_B87A
    POP     HL
    POP     DE
    POP     BC
RET 

SUB_88CB:
    LD      A, (HL)
    CP      6
	RET      C
    LD      (HL), 0
RET 

SUB_88D2:
    PUSH    HL
    CALL    SUB_861E
    PUSH    BC
    LD      HL, RAM_DD
    CALL    SUB_861E
    PUSH    BC
    POP     DE
    POP     BC
    POP     HL
    PUSH    BC
    PUSH    DE
    PUSH    HL
    LD      A, D
    CP      B
    JP      Z, SUB_896C
    JR      NC, SUB_891F
    CALL    SUB_862D
    LD      A, D
    ADD     A, 3
    CP      B
    JR      C, SUB_890A
    ADD     A, 0FDH
    CP      B
    JR      NC, SUB_890A
    LD      A, E
    ADD     A, 2
    CP      C
    JR      C, SUB_890A
    ADD     A, 0FCH
    CP      C
    JR      NC, SUB_890A
    LD      A, (RAM_UU+6)
    OR      A
    JR      Z, SUB_8952

SUB_890A:
    DEC     B
    LD      HL, WORK_BUFFER
    CALL    SUB_8636
    JR      NZ, SUB_8952
    INC     C
    CALL    SUB_8636
    JR      NZ, SUB_8952
    POP     HL
    POP     DE
    POP     BC
    LD      (HL), 33H
RET 

SUB_891F:
    CALL    SUB_862D
    LD      A, D
    INC     A
    CP      B
    JR      C, SUB_893D
    ADD     A, 0FDH
    CP      B
    JR      NC, SUB_893D
    LD      A, E
    ADD     A, 2
    CP      C
    JR      C, SUB_893D
    ADD     A, 0FCH
    CP      C
    JR      NC, SUB_893D
    LD      A, (RAM_UU+6)
    OR      A
    JR      Z, SUB_8952

SUB_893D:
    INC     B
    LD      HL, WORK_BUFFER
    CALL    SUB_8636
    JR      NZ, SUB_8952
    INC     C
    CALL    SUB_8636
    JR      NZ, SUB_8952
    POP     HL
    POP     DE
    POP     BC
    LD      (HL), 2FH
RET 

SUB_8952:
    POP     HL
    POP     DE
    POP     BC
    LD      A, (RAM_UU+6)
    OR      A
    JR      Z, SUB_8969
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IY
    POP     IX
    CALL    SUB_B87A
    POP     HL
    POP     DE
    POP     BC
RET 

SUB_8969:
    PUSH    BC
    PUSH    DE
    PUSH    HL

SUB_896C:
    LD      A, E
    CP      C
    JR      Z, SUB_89CD
    JR      NC, SUB_89A0
    CALL    SUB_862D
    LD      A, D
    ADD     A, 2
    CP      B
    JR      C, SUB_8991
    ADD     A, 0FDH
    CP      B
    JR      NC, SUB_8991
    LD      A, E
    ADD     A, 3
    CP      C
    JR      C, SUB_8991
    ADD     A, 0FDH
    CP      C
    JR      NC, SUB_8991
    LD      A, (RAM_UU+6)
    OR      A
    JR      Z, SUB_89CD

SUB_8991:
    DEC     C
    LD      HL, WORK_BUFFER
    CALL    SUB_8636
    JR      NZ, SUB_89CD
    POP     HL
    POP     DE
    POP     BC
    LD      (HL), 2BH
RET 

SUB_89A0:
    CALL    SUB_862D
    LD      A, D
    ADD     A, 2
    CP      B
    JR      C, SUB_89BD
    ADD     A, 0FDH
    CP      B
    JR      NC, SUB_89BD
    LD      A, E
    CP      C
    JR      C, SUB_89BD
    ADD     A, 0FDH
    CP      C
    JR      NC, SUB_89BD
    LD      A, (RAM_UU+6)
    OR      A
    JR      Z, SUB_89CD

SUB_89BD:
    INC     C
    INC     C
    LD      HL, WORK_BUFFER
    CALL    SUB_8636
    JR      NZ, SUB_89CD
    POP     HL
    POP     DE
    POP     BC
    LD      (HL), 27H
RET 

SUB_89CD:
    POP     HL
    POP     DE
    POP     BC
    LD      A, (RAM_UU+6)
    OR      A
    JR      Z, SUB_89E4
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IY
    POP     IX
    CALL    SUB_B87A
    POP     HL
    POP     DE
    POP     BC
RET 

SUB_89E4:
    LD      (HL), 26H
RET 

SUB_89E7:
    LD      A, (RAM_CC)
    AND     3
    JR      NZ, SUB_8A14
    LD      A, (RAM_SS+9)
    DEC     A
    JR      Z, SUB_8A1A
    LD      A, (RAM_DD+9)
    LD      E, A
    LD      D, 0
    PUSH    DE
    POP     HL
    ADD     HL, HL
    ADD     HL, DE
    ADD     HL, HL
    LD      DE, DATA_9E8C
    ADD     HL, DE
    PUSH    HL
    CALL    SUB_8A42
    POP     HL
    LD      DE, 3CH
    ADD     HL, DE
    JR      SUB_8A42
    SBC     A, B
    SBC     A, (HL)
    ADC     A, H
    SBC     A, (HL)
    SUB     D
    SBC     A, (HL)

SUB_8A14:
    LD      A, (RAM_SS+9)
    DEC     A
    JR      Z, SUB_8A1F

SUB_8A1A:
    LD      A, (RAM_DD+7)
    OR      A
	RET      NZ

SUB_8A1F:
    LD      A, (RAM_DD+8)
    LD      B, 7
    OR      A
    JR      NZ, SUB_8A28
    DEC     B

SUB_8A28:
    LD      E, A
    LD      D, 0
    LD      HL, 8A0EH
    ADD     HL, DE
    ADD     HL, DE
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    EX      DE, HL

SUB_8A34:
    PUSH    BC
    PUSH    HL
    CALL    SUB_8A42
    POP     HL
    LD      DE, 12H
    ADD     HL, DE
    POP     BC
    DJNZ    SUB_8A34
RET 

SUB_8A42:
    PUSH    HL
    PUSH    HL
    POP     IY
    LD      L, (IY+2)
    LD      H, (IY+3)
    PUSH    HL
    LD      A, (HL)
    CP      37H
    JP      P, SUB_8C00
    PUSH    AF
    LD      A, (RAM_UU+5)
    OR      A
    JR      Z, SUB_8A5E
    POP     AF
    POP     HL
    POP     HL
RET 

SUB_8A5E:
    POP     AF
    LD      B, A
    INC     A
    LD      (HL), A
    CP      7
    JR      C, SUB_8A9A
    CP      0AH
    JR      Z, SUB_8A9A
    CP      0EH
    JR      Z, SUB_8A9A
    CP      12H
    JR      Z, SUB_8A9A
    CP      16H
    JR      Z, SUB_8A9A
    CP      1AH
    JR      Z, SUB_8A9A
    CP      1EH
    JR      Z, SUB_8A9A
    CP      22H
    JR      Z, SUB_8A9A
    CP      26H
    JR      Z, SUB_8A9A
    CP      27H
    JR      Z, SUB_8A9A
    CP      2BH
    JR      Z, SUB_8A9A
    CP      2FH
    JR      Z, SUB_8A9A
    CP      33H
    JR      Z, SUB_8A9A
    CP      37H
    JR      NZ, SUB_8AA0

SUB_8A9A:
    PUSH    BC
    CALL    SUB_864E
    POP     BC
    LD      A, (HL)

SUB_8AA0:
    CP      6
    JP      C, SUB_8B5B
    CP      0AH
    JP      C, SUB_8B2B
    CP      0EH
    JP      C, SUB_8B37
    CP      12H
    JP      C, SUB_8B47
    CP      16H
    JP      C, SUB_8B51
    CP      1AH
    JP      C, SUB_8B03
    CP      1EH
    JP      C, SUB_8B17
    CP      22H
    JP      C, SUB_8AE7
    CP      26H
    JP      C, SUB_8AF5
    JP      Z, SUB_8B5B
    CP      2BH
    JP      C, SUB_8BC2
    CP      2FH
    JP      C, SUB_8BD7
    CP      33H
    JP      C, SUB_8BE3
    CP      37H
    JP      C, SUB_8BF6
    JP      SUB_8C00

SUB_8AE7:
    LD      (HL), A
    INC     HL
    CP      1EH
    JR      NZ, SUB_8B41
    LD      A, (HL)
    ADD     A, 0F8H
    LD      (HL), A
    INC     HL
    INC     HL
    JR      SUB_8B3D

SUB_8AF5:
    LD      (HL), A
    INC     HL
    CP      24H
    JR      NZ, SUB_8B41
    LD      A, (HL)
    ADD     A, 8
    LD      (HL), A
    INC     HL
    INC     HL
    JR      SUB_8B31

SUB_8B03:
    LD      (HL), A
    INC     HL
    CP      16H
    JR      NZ, SUB_8B11
    INC     HL
    INC     HL
    LD      A, (HL)
    ADD     A, 0F8H
    LD      (HL), A
    JR      SUB_8B41

SUB_8B11:
    CP      19H
    JR      NZ, SUB_8B41
    JR      SUB_8B31

SUB_8B17:
    LD      (HL), A
    INC     HL
    CP      1CH
    JR      NZ, SUB_8B25
    INC     HL
    INC     HL
    LD      A, (HL)
    ADD     A, 8
    LD      (HL), A
    JR      SUB_8B41

SUB_8B25:
    CP      1AH
    JR      NZ, SUB_8B41
    JR      SUB_8B3D

SUB_8B2B:
    LD      (HL), A
    INC     HL
    CP      9
    JR      NZ, SUB_8B41

SUB_8B31:
    LD      A, (HL)
    ADD     A, 8
    LD      (HL), A
    JR      SUB_8B41

SUB_8B37:
    LD      (HL), A
    INC     HL
    CP      0AH
    JR      NZ, SUB_8B41

SUB_8B3D:
    LD      A, (HL)
    ADD     A, 0F8H
    LD      (HL), A

SUB_8B41:
    POP     HL
    POP     IX
    JP      SUB_8B76

SUB_8B47:
    LD      (HL), A
    INC     HL
    CP      11H
    JR      NZ, SUB_8B41
    INC     HL
    INC     HL
    JR      SUB_8B31

SUB_8B51:
    LD      (HL), A
    INC     HL
    CP      12H
    JR      NZ, SUB_8B41
    INC     HL
    INC     HL
    JR      SUB_8B3D

SUB_8B5B:
    POP     HL
    POP     IX
    CP      26H
    JR      Z, SUB_8B72
    LD      A, (RAM_CC)
    AND     3
    JP      Z, SUB_8B76
    LD      A, (RAM_DD+7)
    OR      A
    JR      Z, SUB_8B76
    DEC     (HL)
RET 

SUB_8B72:
    LD      A, B
    CP      26H
	RET      Z

SUB_8B76:
    PUSH    BC
    PUSH    IX
    PUSH    HL
    CALL    PUTOBJ
    POP     HL
    POP     IX
    POP     BC
    LD      A, (RAM_UU+6)
    OR      A
	RET      Z
    PUSH    BC
    PUSH    IX
    PUSH    HL
    PUSH    HL
    POP     BC
    CALL    SUB_B877
    PUSH    DE
    PUSH    HL
    PUSH    BC
    POP     HL
    LD      A, (HL)
    INC     HL
    LD      D, (HL)
    INC     HL
    INC     HL
    LD      E, (HL)
    CALL    SUB_B874
    PUSH    DE
    PUSH    HL
    CALL    SUB_C385
    POP     HL
    POP     IX
    POP     BC
	RET      Z
    PUSH    BC
    PUSH    IX
    PUSH    HL
    LD      A, (RAM_UU)
    OR      A
    JR      NZ, SUB_8BBA
    LD      A, (RAM_SS+0AH)
    OR      A
    JR      NZ, SUB_8BBA
    INC     A
    LD      (RAM_SS+0AH), A

SUB_8BBA:
    CALL    SUB_B87A
    POP     HL
    POP     IX
    POP     BC
RET 

SUB_8BC2:
    LD      (HL), A
    POP     HL
    POP     IX
    PUSH    HL
    CALL    SUB_8B76
    POP     HL
    LD      A, (HL)
    CP      2AH
	RET      C
    INC     HL
    INC     HL
    INC     HL
    LD      A, (HL)
    ADD     A, 8
    LD      (HL), A
RET 

SUB_8BD7:
    LD      (HL), A
    INC     HL
    CP      2BH
    JP      NZ, SUB_8B41
    INC     HL
    INC     HL
    JP      SUB_8B3D

SUB_8BE3:
    LD      (HL), A
    POP     HL
    POP     IX
    PUSH    HL
    CALL    PUTOBJ
    POP     HL
    LD      A, (HL)
    CP      32H
	RET      C
    INC     HL
    LD      A, (HL)
    ADD     A, 8
    LD      (HL), A
RET 

SUB_8BF6:
    LD      (HL), A
    INC     HL
    CP      33H
    JP      NZ, SUB_8B41
    JP      SUB_8B3D

SUB_8C00:
    LD      A, (HL)
    POP     HL
    POP     IX
    CP      38H
	RET      NZ
    LD      DE, RAM_NN
    LD      IX, PO_DATA_A108
    LD      A, (DE)
    INC     A
    CP      4
    JR      C, SUB_8C17
    LD      (HL), 37H
RET 

SUB_8C17:
    LD      (DE), A
    CP      3
    JR      Z, SUB_8C5C
    INC     HL
    INC     DE
    LD      BC, 4
    LDIR
    CALL    PUTOBJ
    LD      HL, RAM_OO
    LD      D, (HL)
    INC     HL
    INC     HL
    LD      E, (HL)
    LD      HL, 303H
    ADD     HL, DE
    EX      DE, HL
    LD      HL, 909H
    ADD     HL, DE
    PUSH    DE
    PUSH    HL
    CALL    SUB_B86B
    POP     HL
    POP     DE
    LD      A, (RAM_NN)
    OR      A
	RET      NZ
    PUSH    DE
    PUSH    HL
    CALL    SUB_B877
    PUSH    DE
    PUSH    HL
    CALL    SUB_C385
	RET      Z
    LD      A, (RAM_UU)
    OR      A
	RET      NZ
    LD      A, (RAM_SS+0AH)
    OR      A
	RET      NZ
    INC     A
    LD      (RAM_SS+0AH), A
RET 

SUB_8C5C:
    LD      (HL), 37H
    INC     DE
    INC     DE
    INC     DE
    LD      A, 0C0H
    LD      (DE), A
    JP      PUTOBJ

DATA_8C67:
	DB  20H
    DB  48H
    DB  70H
    DB  98H

DATA_8C6B:
	DB  20H
    DB  48H
    DB  78H
    DB 0A8H
    DB 0D0H

SUB_8C70:
    XOR     A
    LD      (RAM_SS+8), A
    LD      (RAM_SS+9), A
    LD      HL, RAM_NN
    LD      (HL), 6
    LD      HL,  RAM_FF+7
    LD      IX, DATA_9E8C
    LD      B, 0

SUB_8C85:
    LD      C, 0

SUB_8C87:
    PUSH    BC
    PUSH    IX
    PUSH    HL
    LD      HL, (RAM_CC+11H)
    XOR     A
    SBC     HL, BC
    LD      A, H
    OR      L
    JP      Z, SUB_8D28
    LD      HL, 102H
    XOR     A
    SBC     HL, BC
    LD      A, H
    OR      L
    JR      NZ, SUB_8CAC
    CALL    SUB_A168
    CP      8
    JR      Z, SUB_8CAC
    CP      2
    JP      NC, SUB_8D28

SUB_8CAC:
    LD      HL, DATA_8C67
    LD      E, B
    LD      D, 0
    ADD     HL, DE
    LD      E, C
    LD      C, (HL)
    LD      HL, DATA_8C6B
    ADD     HL, DE
    LD      B, (HL)
    CALL    SUB_A165
    CP      20H
    JR      NC, SUB_8CC8
    LD      A, 26H
    LD      (RAM_SS), A
    JR      SUB_8CCC

SUB_8CC8:
    XOR     A
    LD      (RAM_SS), A

SUB_8CCC:
    POP     HL
    POP     IX
    PUSH    HL
    PUSH    IX
    POP     HL
    PUSH    HL
    PUSH    BC
    XOR     A
    CALL    ACTIVATE
    LD      A, (RAM_CC)
    AND     3
    JR      Z, SUB_8CED
    DEC     A
    JR      Z, SUB_8CF4
    DEC     A
    JR      Z, SUB_8CFB
    CALL    SUB_A165
    CP      2CH
    JR      SUB_8D00

SUB_8CED:
    CALL    SUB_A165
    CP      20H
    JR      SUB_8D00

SUB_8CF4:
    CALL    SUB_A165
    CP      24H
    JR      SUB_8D00

SUB_8CFB:
    CALL    SUB_A165
    CP      28H

SUB_8D00:
    POP     BC
    POP     IX
    POP     HL
    JR      NC, SUB_8D2B
    LD      A, (RAM_SS)
    LD      (HL), A
    INC     HL
    LD      (HL), B
    INC     HL
    LD      (HL), 0
    INC     HL
    LD      (HL), C
    INC     HL
    LD      (HL), 0
    INC     HL
    INC     HL
    PUSH    HL
    CALL    PUTOBJ
    LD      HL,  RAM_SS+8
    INC     (HL)
    INC     HL
    INC     (HL)
    LD      DE, 6
    POP     HL
    ADD     IX, DE
    JR      SUB_8D33

SUB_8D28:
    POP     HL
    POP     IX

SUB_8D2B:
    LD      (HL), 37H
    LD      DE, 6
    ADD     IX, DE
    ADD     HL, DE

SUB_8D33:
    POP     BC
    INC     C
    LD      A, C
    CP      5
    JP      C, SUB_8C87
    INC     B
    LD      A, B
    CP      4
    JP      C, SUB_8C85
    LD      A, (RAM_SS+8)
    LD      (RAM_VV+7), A
RET 

SUB_8D49:
    LD      A, (RAM_DD+0CH)
    OR      A
    JR      NZ, SUB_8D63
    LD      A, (CONTROLLER_BUFFER+6)
    CP      0FH
	RET      Z

SUB_8D55:
    LD      B, A
    PUSH    BC
    CALL    SUB_A15C
    POP     BC
    LD      A, (CONTROLLER_BUFFER+6)
    CP      B
    LD      A, B
    JR      Z, SUB_8D55
RET 

SUB_8D63:
    LD      A, (CONTROLLER_BUFFER+0BH)
    CP      0FH
	RET      Z

SUB_8D69:
    LD      B, A
    PUSH    BC
    CALL    SUB_A15C
    POP     BC
    LD      A, (CONTROLLER_BUFFER+0BH)
    CP      B
    LD      A, B
    JR      Z, SUB_8D69
RET 

SUB_8D77:
    LD      A, (RAM_DD+0CH)
    OR      A
    JR      NZ, SUB_8D91
    LD      A, (CONTROLLER_BUFFER+2)
    PUSH    BC
    LD      B, A
    LD      A, (CONTROLLER_BUFFER+5)
    OR      B
    POP     BC
    BIT     6, A
    LD      A, (RAM_DD+5)
    LD      E, A
    LD      A, (CONTROLLER_BUFFER+3)
RET 

SUB_8D91:
    LD      A, (CONTROLLER_BUFFER+7)
    PUSH    BC
    LD      B, A
    LD      A, (CONTROLLER_BUFFER+0AH)
    OR      B
    POP     BC
    BIT     6, A
    LD      A, (RAM_DD+6)
    LD      E, A
    LD      A, (CONTROLLER_BUFFER+8)
RET 

SUB_8DA5:
    LD      A, (RAM_DD+0CH)
    OR      A
    LD      A, (CONTROLLER_BUFFER+6)
    JR      Z, SUB_8DB1
    LD      A, (CONTROLLER_BUFFER+0BH)

SUB_8DB1:
    CP      0AH
    JP      Z, SUB_8F71
    LD      A, (RAM_FF)
    OR      A
	RET      Z
    CALL    SUB_9040
    CALL    SUB_80EE
    CALL    SUB_C37F
    CALL    SUB_A15F
    LD      HL, RAM_DD
    LD      (HL), 0
    INC     HL
    LD      A, (RAM_FF+5)
    OR      A
    JR      NZ, SUB_8DD7
    LD      A, 20H
    JR      SUB_8DDD

SUB_8DD7:
    CP      1
    JR      NZ, SUB_8E09
    LD      A, 98H

SUB_8DDD:
    INC     HL
    INC     HL
    LD      (HL), A
    CALL    SUB_A16B
    LD      A, C
    OR      A
    JR      NZ, SUB_8DEB
    LD      A, 20H
    JR      SUB_8E05

SUB_8DEB:
    CP      1
    JR      NZ, SUB_8DF3
    LD      A, 48H
    JR      SUB_8E05

SUB_8DF3:
    CP      2
    JR      NZ, SUB_8DFB
    LD      A, 78H
    JR      SUB_8E05

SUB_8DFB:
    CP      3
    JR      NZ, SUB_8E03
    LD      A, 0A8H
    JR      SUB_8E05

SUB_8E03:
    LD      A, 0D0H

SUB_8E05:
    DEC     HL
    DEC     HL
    JR      SUB_8E31

SUB_8E09:
    CP      2
    JR      NZ, SUB_8E11
    LD      A, 20H
    JR      SUB_8E13

SUB_8E11:
    LD      A, 0D0H

SUB_8E13:
    LD      (HL), A
    CALL    SUB_A16B
    LD      A, B
    OR      A
    JR      NZ, SUB_8E1F
    LD      A, 20H
    JR      SUB_8E31

SUB_8E1F:
    CP      1
    JR      NZ, SUB_8E27
    LD      A, 48H
    JR      SUB_8E31

SUB_8E27:
    CP      2
    JR      NZ, SUB_8E2F
    LD      A, 70H
    JR      SUB_8E31

SUB_8E2F:
    LD      A, 98H

SUB_8E31:
    LD      (HL), A
    CALL    SUB_A16B
    LD      (RAM_CC+11H), BC
    CALL    SUB_9012
    CALL    SUB_A16E
    CALL    SUB_A162
    CALL    SUB_A177
    LD      IX, PO_DATA_9BE2
    CALL    PUTOBJ
    CALL    SUB_8C70
    CALL    SUB_C37C
    XOR     A
    LD      (RAM_DD+6), A
    LD      (RAM_DD+5), A
RET 

SUB_8E5A:
    CALL    SUB_8EB1
    CALL    SUB_8FA2
    CALL    SUB_C7CC
    CALL    SUB_8FBE
    CALL    SUB_A16B
    LD      (RAM_CC+11H), BC
    CALL    SUB_9012
    CALL    SUB_A19E
    CALL    SUB_A16E
    CALL    SUB_A162
    CALL    SUB_A177
    LD      A, 1
    LD      HL, 0AH
    CALL    REQUEST_SIGNAL
    LD      B, 3

SUB_8E86:
    PUSH    BC
    PUSH    AF
    CALL    SUB_8FA2
    LD      A, (RAM_DD+0CH)
    CALL    SUB_A195
    POP     AF
    PUSH    AF
    CALL    SUB_A198
    LD      IX, PO_DATA_9BE2
    CALL    PUTOBJ
    CALL    SUB_A192
    POP     AF
    CALL    SUB_A198
    POP     BC
    DJNZ    SUB_8E86
    CALL    FREE_SIGNAL
    CALL    SUB_8C70
    CALL    SUB_C37C
RET 

SUB_8EB1:
    CALL    SUB_8F4B
    PUSH    AF
    CALL    Z, SUB_9037
    LD      A, (RAM_CC)
    BIT     2, A
    LD      HL,  RAM_CC+0EH
    LD      A, (RAM_CC+0DH)
    JR      Z, SUB_8EC6
    OR      (HL)

SUB_8EC6:
    OR      A
    CALL    Z, SUB_C7E8
    POP     AF
    CALL    Z, SUB_A18C
    LD      A, (RAM_CC)
    BIT     2, A
    JR      Z, SUB_8EDD
    CALL    SUB_8F3F
	RET      NZ
    CALL    SUB_8F3F
	RET      NZ

SUB_8EDD:
    CALL    SUB_8F4B
	RET      NZ
    LD      A, (RAM_CC)
    AND     3
    LD      A, 3
    JR      NZ, SUB_8EEC
    LD      A, 5

SUB_8EEC:
    LD      (RAM_CC+0DH), A
    LD      (RAM_CC+0EH), A
    POP     HL
    POP     HL
    LD      A, 0
    LD      HL, 1C20H
    CALL    REQUEST_SIGNAL
    LD      (RAM_SS), A

SUB_8EFF:
    CALL    SUB_A15C
    CALL    TIME_MGR
    LD      A, (RAM_SS)
    CALL    TEST_SIGNAL
    CALL    NZ, SUB_A17A
    XOR     A
    LD      (RAM_DD+0CH), A
    CALL    SUB_8D49
    CP      0AH
    CALL    Z, SUB_8F5A
    JP      Z, SUB_8070
    CP      0BH
    CALL    Z, SUB_8F5A
    JP      Z, START
    LD      A, 1
    LD      (RAM_DD+0CH), A
    CALL    SUB_8D49
    CP      0AH
    CALL    Z, SUB_8F5A
    JP      Z, SUB_8070
    CP      0BH
    CALL    Z, SUB_8F5A
    JP      Z, START
    JR      SUB_8EFF

SUB_8F3F:
    LD      A, (RAM_DD+0CH)
    OR      A
    LD      A, 1
    JR      Z, SUB_8F48
    XOR     A

SUB_8F48:
    LD      (RAM_DD+0CH), A

SUB_8F4B:
    LD      A, (RAM_DD+0CH)
    LD      HL,  RAM_CC+0DH
    OR      A
    JR      Z, SUB_8F57
    LD      HL,  RAM_CC+0EH

SUB_8F57:
    LD      A, (HL)
    OR      A
RET 

SUB_8F5A:
    PUSH    AF
    CALL    SUB_A17A
    CALL    SUB_C7CC
    POP     AF
RET 

MISSING_SUB_00: ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ NO LINK?
    LD      A, (RAM_UU)
    OR      A
    JR      Z, SUB_8F6C
    XOR     A
    JR      SUB_8F6D

SUB_8F6C:
    INC     A

SUB_8F6D:
    LD      (RAM_UU), A
RET 

SUB_8F71:
    CALL    SUB_A17A
    LD      HL, RAM_XX
    LD      DE, 1000H
    LD      BC, 3DH
    CALL    WRITE_VRAM
    CALL    SUB_C7CC
    CALL    SUB_C7D4
    CALL    SUB_8D49

SUB_8F89:
    CALL    SUB_A15C
    CALL    SUB_8D49
    CP      0AH
    JR      NZ, SUB_8F89
    LD      HL, RAM_XX
    LD      DE, 1000H
    LD      BC, 3DH
    CALL    READ_VRAM
    JP      SUB_A17D

SUB_8FA2:
    LD      HL, RAM_DD
    INC     HL
    INC     HL
    INC     HL
    LD      (HL), 0C0H
    LD      IX, PO_DATA_9BE2
    CALL    PUTOBJ
    LD      HL, RAM_DD
    LD      (HL), 0
    INC     HL
    LD      (HL), 20H
    INC     HL
    INC     HL
    LD      (HL), 70H
RET 

SUB_8FBE:
    LD      IX, PO_DATA_A108
    LD      HL, RAM_NN
    LD      (HL), 6
    INC     HL
    INC     HL
    INC     HL
    LD      (HL), 0C0H
    CALL    PUTOBJ
RET 

SUB_8FD0:
    LD      HL, RAM_AA
    LD      DE, RAM_BB
    CALL    INIT_TIMER
    LD      A, 1
    LD      HL, 1EH
    CALL    REQUEST_SIGNAL
    LD      (RAM_SS+6), A
    LD      A, 1
    LD      HL, 0F0H
    CALL    REQUEST_SIGNAL
    LD      (RAM_VV+8), A
    LD      A, (RAM_VV+5)
    CP      2
    LD      A, 4
    JR      Z, SUB_8FF9
    XOR     A

SUB_8FF9:
    LD      B, A
    LD      A, (RAM_CC)
    AND     3
    ADD     A, B
    LD      E, A
    LD      D, 0
    LD      HL, DATA_9051
    ADD     HL, DE
    LD      L, (HL)
    LD      H, D
    LD      A, 1
    CALL    REQUEST_SIGNAL
    LD      (RAM_SS+7), A
RET 

SUB_9012:
    CALL    SUB_A171
    XOR     A
    LD      (RAM_SS+0AH), A
    LD      (RAM_UU+1), A
    LD      (RAM_UU+3), A
    LD      (RAM_UU+4), A
    LD      (RAM_UU+5), A
    LD      (RAM_UU+6), A
    CALL    SUB_A168
    CP      1
    JR      Z, SUB_9033
    LD      A, 1
    JR      SUB_9034

SUB_9033:
    XOR     A

SUB_9034:
    LD      (RAM_UU+2), A

SUB_9037:
    CALL    SUB_80EE
    CALL    SUB_8FD0
    CALL    SUB_C37F

SUB_9040:
    LD      IX, PO_DATA_A108
    LD      HL, RAM_NN
    LD      (HL), 6
    INC     HL
    INC     HL
    INC     HL
    LD      (HL), 0C0H
    JP      PUTOBJ

DATA_9051:
	DB  1CH
    DB  18H
    DB  14H
    DB  10H
    DB  14H
    DB  12H
    DB  10H
    DB  0EH

DATA_9059:
	DB    0
    DB  1CH
    DB  22H
    DB  28H
    DB  2EH
    DB  34H
    DB  50H
    DB  56H
    DB  5CH
    DB  62H
    DB  68H
    DB  84H
    DB  8AH
    DB  90H
    DB  96H
    DB  9CH
    DB 0B8H
    DB 0BEH
    DB 0C4H
    DB 0CAH
    DB 0D0H
DATA_906E:
	DB    0
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB    1
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB    2
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB    3
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB    4
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB    5

DATA_908A:
	DB  31H
    DB  31H
    DB  31H
    DB 0D1H

DATA_908E:
	DB 0F1H
    DB 0F1H
    DB  51H

DATA_9091:
	DB 0D1H
    DB  71H
    DB 0A1H
    DB    1
    DB 0D1H
    DB  41H
    DB  81H
    DB    0
    DB 0D1H
    DB  41H
    DB  71H
    DB    2
    DB  81H
    DB 0A1H
    DB  31H
    DB    0
    DB  81H
    DB 0A1H
    DB  51H
    DB    3
    DB  81H
    DB 0A1H
    DB 0D1H
    DB    0
    DB  31H
    DB  51H
    DB  71H
    DB    4
    DB  41H
    DB 0A1H
    DB  31H
    DB    0
    DB  71H
    DB  61H
    DB 0D1H
    DB    5
    DB  31H
    DB 0A1H
    DB 0D1H
    DB    0
    DB 0F1H
    DB  41H
    DB  51H
    DB    8
    DB 0F1H
    DB  41H
    DB  51H
    DB    8
    DB 0F1H
    DB  41H
    DB  51H
    DB    8
    DB  71H
    DB  41H
    DB 0A1H
    DB    0

PATTERN_DATA_00:
	DB 136,000,016,056,084,016,040,068
    DB 000,018,000,132,102,255,255,102
    DB 004,000,132,096,240,240,096,004
    DB 000,142,006,015,015,006,000,000
    DB 024,060,060,024,024,060,060,024
    DB 004,000,136,024,060,060,024,024
    DB 060,060,024,004,000,136,000,024
    DB 060,126,126,060,024,000,128,008
    DB 008,024,003,000,002,255,003,000
    DB 003,024,002,248,003,000,003,024
    DB 002,031,006,000,002,248,003,024
    DB 003,000,002,031,006,024,002,255
    DB 006,024,002,255,003,000,003,024
    DB 002,031,003,024,003,000,002,255
    DB 006,024,002,248,007,024,007,000
    DB 002,015,007,000,004,024,003,000
    DB 002,240,003,000,128,008,152,000
    DB 024,060,102,102,060,024,000,126
    DB 102,102,126,126,102,102,126,000
    DB 255,255,153,153,255,255,000,128
    DB 040,138,056,084,108,056,016,124
    DB 146,186,146,186,004,040,155,108
    DB 000,146,184,040,040,104,008,012
    DB 000,000,000,056,084,108,056,016
    DB 124,146,186,146,058,040,040,044
    DB 032,096,011,000,143,056,084,108
    DB 056,016,124,146,186,146,184,040
    DB 040,104,008,012,011,000,154,056
    DB 084,108,056,016,124,146,186,146
    DB 058,040,040,044,032,096,000,000
    DB 000,056,124,124,056,016,124,146
    DB 186,006,000,138,056,124,124,056
    DB 016,124,146,186,146,058,004,000
    DB 150,056,124,124,056,000,000,056
    DB 124,124,056,016,124,056,116,124
    DB 024,016,124,146,186,146,186,004
    DB 040,145,060,000,014,029,031,006
    DB 004,031,036,046,036,046,011,011
    DB 011,011,025,007,000,004,128,004
    DB 000,140,128,000,003,007,007,001
    DB 001,007,009,011,009,011,004,002
    DB 140,003,000,128,064,192,128,000
    DB 192,032,160,032,160,004,128,136
    DB 192,000,000,001,001,000,000,001
    DB 004,002,006,000,138,224,208,240
    DB 096,064,240,072,232,072,232,004
    DB 064,140,096,000,014,023,031,012
    DB 004,031,036,046,036,046,004,004
    DB 132,012,000,128,128,006,000,138
    DB 003,005,007,003,001,007,009,011
    DB 009,011,004,002,140,007,000,128
    DB 192,192,000,000,192,032,160,032
    DB 160,005,128,131,000,002,002,004
    DB 001,140,003,000,224,112,240,192
    DB 064,240,072,232,072,232,004,016
    DB 145,048,000,056,092,124,048,016
    DB 124,146,186,146,186,040,040,040
    DB 040,120,004,000,139,003,007,015
    DB 014,014,006,003,001,015,015,014
    DB 005,000,140,224,240,248,056,184
    DB 048,224,248,192,248,056,056,006
    DB 000,140,003,007,015,014,014,006
    DB 003,015,001,015,014,014,012,000
    DB 140,224,240,248,056,184,048,224
    DB 248,248,192,056,056,014,000,140
    DB 003,007,015,014,014,006,003,015
    DB 015,001,014,014,012,000,140,224
    DB 240,248,056,184,048,224,248,248
    DB 248,000,056,006,000,140,003,007
    DB 015,014,014,006,003,015,015,015
    DB 000,014,004,000,139,224,240,248
    DB 056,184,048,224,192,248,248,056
    DB 007,000,139,003,007,015,015,015
    DB 007,003,001,015,015,014,005,000
    DB 203,224,240,248,248,248,240,224
    DB 248,192,248,056,056,000,000,003
    DB 007,015,015,015,007,003,000,224
    DB 240,248,248,248,240,224,007,015
    DB 015,015,007,003,015,015,240,248
    DB 248,248,240,224,248,248,015,015
    DB 007,003,015,001,015,014,248,248
    DB 240,224,248,248,192,056,000,000
    DB 000,003,007,014,014,014,007,003
    DB 029,015,031,013,005,000,139,224
    DB 240,056,184,056,240,224,220,248
    DB 252,216,004,000,138,001,003,003
    DB 003,001,000,003,007,007,002,005
    DB 000,139,248,252,142,174,142,252
    DB 248,186,255,255,238,010,000,003
    DB 001,014,000,139,062,127,227,235
    DB 227,127,062,119,255,255,238,007
    DB 000,003,128,134,000,000,000,192
    DB 192,064,011,000,139,015,031,056
    DB 058,056,031,015,110,127,063,059
    DB 005,000,139,128,192,224,224,224
    DB 192,128,224,224,240,176,006,000
    DB 138,001,003,003,003,001,000,003
    DB 007,007,002,005,000,151,248,252
    DB 142,174,142,252,248,187,255,255
    DB 238,000,015,031,056,058,056,031
    DB 015,110,127,063,059,005,000,139
    DB 128,192,224,224,224,192,128,224
    DB 224,240,176,007,000,133,224,240
    DB 136,168,136,004,000,138,001,003
    DB 003,003,001,000,003,007,007,002
    DB 005,000,139,248,252,226,234,226
    DB 252,248,186,255,255,238,004,000
    DB 003,001,006,000,139,062,127,248
    DB 250,248,127,062,119,255,255,119
    DB 007,000,003,128,003,000,131,192
    DB 192,064,005,000,139,015,031,062
    DB 062,062,031,015,110,127,063,059
    DB 005,000,139,128,192,032,160,032
    DB 192,128,224,224,240,176,006,000
    DB 188,001,002,002,002,000,000,000
    DB 248,252,062,190,062,000,000,000
    DB 062,127,143,175,143,000,000,000
    DB 015,031,035,043,035,000,000,000
    DB 128,192,224,224,224,000,000,000
    DB 003,007,008,010,008,000,000,000
    DB 224,240,224,232,224,000,000,000
    DB 003,007,003,011,003,000

PATTERN_DATA_01:
	DB 138,000,000,001,003,007,015,031
    DB 063,031,127,006,255,130,248,254
    DB 006,255,136,000,000,128,192,224
    DB 240,248,252,005,255,131,127,127
    DB 063,005,255,139,254,254,252,063
    DB 031,015,007,003,001,000,000,006
    DB 255,130,127,031,006,255,138,254
    DB 248,252,248,240,224,192,128,000
    DB 000,005,255,002,000,004,255,237
    DB 127,031,135,224,248,255,255,255
    DB 254,248,225,007,031,255,255,255
    DB 248,224,135,031,127,255,255,255
    DB 031,007,225,248,254,063,126,125
    DB 255,255,252,255,255,007,251,253
    DB 255,255,003,255,255,224,223,191
    DB 255,255,192,255,255,252,126,190
    DB 255,255,063,255,255,063,127,126
    DB 252,255,252,255,255,159,111,199
    DB 187,120,236,186,198,249,246,227
    DB 221,030,055,093,099,252,254,126
    DB 063,255,063,255,255,255,248,240
    DB 224,195,143,031,063,255,031,015
    DB 007,195,241,248,252,000

PATTERN_DATA_02:
	DB 136,060,126,255,255,255,251,118
    DB 060,128,056,136,060,126,255,255
    DB 255,251,118,060,128,056,136,024
    DB 060,024,060,024,060,024,060,128
    DB 056,004,000,132,128,112,013,002
    DB 006,000,134,192,016,192,000,224
    DB 031,006,000,140,008,007,020,104
    DB 128,064,013,002,034,129,001,001
    DB 004,000,166,001,198,056,001,001
    DB 001,000,128,000,128,128,000,000
    DB 000,002,001,000,000,002,005,000
    DB 000,000,160,028,003,116,000,128
    DB 064,007,008,008,224,128,000,000
    DB 000,128,048,178,255,255,000,000
    DB 015,000,000,000,255,255,064,064
    DB 192,064,064,000,255,255,000,012
    DB 003,000,000,000,255,255,128,128
    DB 064,192,032,000,255,255,009,004
    DB 002,001,000,000,255,255,000,128
    DB 064,032,144,000,255,255,006,000
    DB 200,255,255,128,096,088,038,032
    DB 000,255,255,002,002,003,002,002
    DB 000,255,255,000,000,240,000,000
    DB 000,255,255,001,001,002,003,004
    DB 000,255,255,000,016,096,128,000
    DB 000,255,255,000,001,002,004,009
    DB 000,255,255,144,032,064,128,000
    DB 000,255,255,000,001,006,008,000
    DB 000,255,255,032,160,064,064,128
    DB 000,000
PATTERN_DATA_03:
	DB 004,000,131,003,004,003,004,000
    DB 133,255,255,060,255,255,004,000
    DB 131,192,032,192,005,000,131,003
    DB 007,003,004,000,133,127,159,255
    DB 243,248,004,000,132,192,224,192
    DB 000,000

PATTERN_DATA_04:
	DB 132,127,128,128,255,004,000,132
    DB 254,001,001,255,004,000,132,127
    DB 128,143,255,004,000,132,254,001
    DB 241,255,004,000,200,127,128,254
    DB 255,015,003,000,000,254,001,127
    DB 255,240,192,000,000,127,128,254
    DB 254,126,063,015,003,254,001,127
    DB 127,126,252,240,192,127,128,254
    DB 254,062,126,126,254,254,001,127
    DB 127,124,126,126,127,103,031,127
    DB 254,252,240,224,128,230,248,254
    DB 127,063,015,007,001,230,248,238
    DB 119,055,011,007,001,128,024,143
    DB 000,001,001,003,003,007,007,015
    DB 015,031,031,063,063,127,127,009
    DB 255,144,000,128,128,192,192,224
    DB 224,240,240,248,248,252,252,254
    DB 254,255,128,024,168,015,031,000
    DB 219,219,231,219,219,240,248,000
    DB 199,231,231,231,195,015,031,000
    DB 195,223,211,219,195,240,248,000
    DB 195,223,199,251,199,240,248,000
    DB 231,219,219,219,231,128,024,136
    DB 255,127,063,031,015,007,003,001
    DB 003,255,134,255,255,255,255,255
    DB 255,135,254,252,248,240,224,192
    DB 128,128,040,131,063,015,003,005
    DB 000,131,252,240,192,005,000,144
    DB 254,254,126,063,015,003,000,000
    DB 127,127,126,252,240,192,000,000
    DB 004,254,132,126,063,015,003,004
    DB 127,132,126,252,240,192,000

PATTERN_DATA_05:
	DB 136,126,231,219,219,195,219,255
    DB 126,128,056,004,000,164,048,120
    DB 252,252,252,140,180,140,180,140
    DB 252,252,120,048,120,048,048,063
    DB 031,000,000,000,112,255,020,008
    DB 020,255,000,000,000,248,010,030
    DB 010,248,007,000,145,008,000,000
    DB 003,255,008,028,008,255,000,000
    DB 128,248,022,010,022,248,011,000
    DB 141,255,020,008,020,255,000,000
    DB 028,248,010,030,010,248,011,000
    DB 149,255,008,028,008,255,000,000
    DB 000,248,022,010,022,248,000,000
    DB 000,128,064,032,000,000,128,008
    DB 144,015,007,003,001,000,000,000
    DB 001,255,194,244,232,208,208,208
    DB 232,128,048,190,255,192,204,210
    DB 222,210,210,192,255,000,226,151
    DB 245,165,148,000,248,024,152,216
    DB 088,088,088,024,239,239,239,224
    DB 239,255,255,255,251,246,237,219
    DB 183,239,255,255,251,251,130,251
    DB 251,255,255,255,191,207,231,243
    DB 249,254,255,255,248,248,248,255
    DB 249,249,005,248,129,255,005,248
    DB 131,249,249,255,004,248,128,048
    DB 004,000,143,072,120,072,000,000
    DB 000,072,120,072,000,000,000,072
    DB 120,072,005,000,000

PATTERN_DATA_06:
	DB 133,001,001,000,003,007,004,005
    DB 006,001,138,003,128,128,000,192
    DB 224,160,160,160,160,006,128,167
    DB 192,001,001,000,003,007,013,007
    DB 003,001,003,003,030,030,016,000
    DB 000,128,128,000,128,192,192,192
    DB 240,128,192,192,192,096,096,096
    DB 048,001,001,000,003,003,003,004
    DB 001,185,003,003,007,007,003,003
    DB 128,128,000,128,128,128,192,128
    DB 192,224,112,224,128,000,000,128
    DB 001,001,000,003,007,013,005,003
    DB 003,003,006,014,028,056,048,056
    DB 128,128,000,128,192,192,184,128
    DB 128,192,224,112,064,096,016,000
    DB 001,001,000,013,001,132,160,176
    DB 016,240,011,128,129,192,004,000
    DB 188,003,005,011,011,003,001,001
    DB 003,002,002,003,000,000,192,192
    DB 003,254,192,128,128,128,192,096
    DB 096,096,192,192,224,000,001,001
    DB 000,003,005,011,011,003,001,001
    DB 003,002,002,003,000,004,136,152
    DB 048,224,192,128,128,128,192,096
    DB 096,096,192,192,224,004,000,156
    DB 003,005,011,011,003,001,001,003
    DB 002,002,003,000,000,192,192,000
    DB 224,240,216,140,130,192,096,096
    DB 096,192,192,224,004,000,156,003
    DB 004,005,003,003,001,001,003,002
    DB 002,003,000,000,000,024,024,224
    DB 240,240,144,144,216,104,096,096
    DB 192,192,224,004,000,210,001,002
    DB 005,005,003,003,003,006,004,004
    DB 006,000,008,108,100,004,248,224
    DB 192,192,128,192,096,096,096,192
    DB 192,224,001,001,000,001,003,003
    DB 003,015,001,003,003,003,006,006
    DB 006,012,128,128,000,192,224,176
    DB 224,192,128,192,192,248,120,008
    DB 000,000,001,001,000,001,001,001
    DB 003,001,003,007,014,007,001,000
    DB 000,001,128,128,000,192,192,192
    DB 004,128,170,192,224,224,192,192
    DB 192,001,001,000,001,003,003,029
    DB 001,001,003,007,014,004,006,008
    DB 000,128,128,000,192,224,176,160
    DB 192,192,192,096,112,056,028,012
    DB 028,005,013,008,015,011,001,132
    DB 003,128,128,000,013,128,144,000
    DB 003,003,192,127,003,001,001,001
    DB 003,006,006,006,003,003,007,004
    DB 000,188,192,160,208,208,192,128
    DB 128,192,064,064,192,000,032,017
    DB 025,012,007,003,001,001,001,003
    DB 006,006,006,003,003,007,000,128
    DB 128,000,192,160,208,208,192,128
    DB 128,192,064,064,192,000,000,003
    DB 003,000,007,015,027,049,065,003
    DB 006,006,006,003,003,007,004,000
    DB 140,192,160,208,208,192,128,128
    DB 192,064,064,192,000,128,128,128
    DB 128,128,128,128,128,128,032,182
    DB 020,037,047,016,012,008,008,017
    DB 016,036,036,038,042,073,144,096
    DB 192,036,042,116,008,112,128,000
    DB 128,128,128,064,032,144,080,032
    DB 008,024,016,015,003,007,007,014
    DB 015,027,027,025,017,048,096,000
    DB 000,192,196,136,240,128,005,000
    DB 133,128,192,096,032,000,007,000
    DB 002,001,014,000,002,128,012,000
    DB 134,001,003,007,007,003,001,010
    DB 000,134,128,192,224,224,192,128
    DB 008,000,138,003,007,015,031,029
    DB 031,031,014,007,003,006,000,138
    DB 192,224,240,248,184,248,248,112
    DB 224,192,005,000,140,003,015,031
    DB 031,059,063,063,055,027,028,015
    DB 003,004,000,140,192,240,248,248
    DB 220,252,252,236,216,056,240,192
    DB 009,000,135,015,027,063,063,063
    DB 048,015,009,000,135,240,216,252
    DB 252,252,012,240,004,000,140,003
    DB 015,031,031,059,063,063,063,024
    DB 031,015,003,004,000,140,192,240
    DB 248,248,220,252,252,252,024,248
    DB 240,192,004,000,140,003,015,031
    DB 031,059,063,060,059,023,031,015
    DB 003,004,000,140,192,240,248,248
    DB 220,252,060,220,232,248,240,192
    DB 007,000,137,003,015,031,031,059
    DB 063,060,059,023,007,000,137,192
    DB 240,248,248,220,248,060,220,232
    DB 010,000,134,003,015,031,031,059
    DB 063,010,000,134,192,240,248,248
    DB 220,248,013,000,131,003,015,031
    DB 013,000,133,192,240,248,000,000
    DB 128,192,129,254,047,000,129,127
    DB 015,000,007,128,034,000,007,128
    DB 016,000,134,128,064,032,016,008
    DB 004,042,000,134,001,002,004,008
    DB 016,032,020,000,134,004,008,016
    DB 032,064,128,042,000,134,032,016
    DB 008,004,002,001,003,000,138,004
    DB 001,010,036,084,024,004,003,005
    DB 001,005,000,138,128,128,032,132
    DB 080,044,050,064,176,008,004,000
    DB 160,001,003,032,020,064,016,128
    DB 048,000,064,004,168,008,017,004
    DB 000,000,040,016,020,032,005,000
    DB 002,000,002,128,009,068,032,008
    DB 064,006,000,138,016,000,004,032
    DB 000,080,002,080,160,021,005,000
    DB 139,008,000,000,128,018,036,004
    DB 002,140,161,016,000



PO_DATA_9BE2:
	DW UNK_9BE7
    DW RAM_DD
    DB    0
UNK_9BE7:
	DB    3
    DB    0
    DB    0
    DB    0
    DB    0
    DW UNK_9BEE
UNK_9BEE:
	DB    2
    DB    0
    DB    2
    DB    4
    DB    2
    DB    8
    DB    2
    DB  0CH
    DB    2
    DB  10H
    DB    2
    DB  14H
    DB    2
    DB  18H
    DB    2
    DB  1CH
    DB    2
    DB  20H
    DB    2
    DB  24H
    DB    2
    DB  28H
    DB    2
    DB  2CH
    DB    2
    DB  30H
    DB    2
    DB  34H
    DB    2
    DB  38H
    DB    2
    DB  3CH
    DB    2
    DB  40H
    DB  0AH
    DB  88H
    DB    5
    DB  8CH
    DB  0FH
    DB  88H
    DB  0DH
    DB  8CH

PO_EVIL_OTTO_LG:
	DW UNK_9C1E
    DW RAM_DD+0DH
    DB    0
    DB  80H
UNK_9C1E:
	DB    0
    DB 0B8H
    DB    0
    DB    0
    DB    0
    DW UNK_9C2B
    DW UNK_9C3D
    DW UNK_9C4F
    DW UNK_9C61
UNK_9C2B:
	DB    4
    DB    4
    DB 0B8H,0B9H,0BAH,0BBH
    DB 0C7H,0C8H,0C9H,0CAH
    DB 0BCH,0C2H,0C2H,0BDH
    DB 0BEH,0BFH,0C0H,0C1H
UNK_9C3D:
	DB    4
    DB    4
    DB 0B8H,0B9H,0BAH,0BBH
    DB 0C7H,0C8H,0C9H,0CAH
    DB 0BCH,0C3H,0C4H,0BDH
    DB 0BEH,0BFH,0C0H,0C1H
UNK_9C4F:
	DB    4
    DB    4
    DB 0B8H,0B9H,0BAH,0BBH
    DB 0C7H,0C8H,0C9H,0CAH
    DB 0BCH,0C5H,0C6H,0BDH
    DB 0BEH,0BFH,0C0H,0C1H
UNK_9C61:
	DB    4
    DB    4
    DB 0B8H,0B9H,0BAH,0BBH
    DB 0CBH,0CCH,0CDH,0CEH
    DB 0BCH,0CFH,0D0H,0BDH
    DB 0BEH,0BFH,0C0H,0C1H

PO_POWER_PLANT:
	DW UNK_9C79
    DW RAM_DD+0DH
    DB    0
    DB  80H
UNK_9C79:
	DB    0
    DB 0B8H
    DB    0
    DB    0
    DB    0
    DW UNK_9C86
    DW UNK_9C94
    DW UNK_9CA2
    DW UNK_9CB0
UNK_9C86:
	DB    4
    DB    3
    DB 0C0H,17H,17H,17H
    DB 0C8H,17H,17H,0C0H
    DB 0C0H,17H,17H,0C8H
UNK_9C94:
	DB    4
    DB    3
    DB 0B8H,0D0H,0D1H,17H
    DB 0C8H,17H,0D2H,0B8H
    DB 0C0H,17H,17H,0C8H
UNK_9CA2:
	DB    4
    DB    3
    DB 0C0H,17H,17H,17H
    DB 0C8H,17H,0D3H,0B8H
    DB 0B8H,0D4H,17H,0C8H
UNK_9CB0:
	DB    4
    DB    3
    DB 0B8H,0D5H,0D6H,17H
    DB 0C8H,0D7H,0D8H,0B8H
    DB 0B8H,0D9H,17H,0C8H

PO_BRAIN:
	DW UNK_9CC4
    DW RAM_EE
    DB    0
    DB  80H
UNK_9CC4:
	DB    0
    DB 0B8H
    DB    0
    DB    0
    DB    0
    DW UNK_9CD9
    DW UNK_9CE1
    DW UNK_9CE9
    DW UNK_9CF1
    DW UNK_9CF9
    DW UNK_9D01
    DW UNK_9D09
    DW UNK_9D11
UNK_9CD9:
	DB    6
    DB    1
    DB 0E0H,0E1H,0E2H,0E3H,0E4H,0E5H
UNK_9CE1:
	DB    6
    DB    1
    DB 0E2H,0E3H,0E4H,0E5H,0E6H,0E7H
UNK_9CE9:
	DB    6
    DB    1
    DB 0E4H,0E5H,0E6H,0E7H,0E8H,0E9H
UNK_9CF1:
	DB    6
    DB    1
    DB 0E6H,0E7H,0E8H,0E9H,0EAH,0EBH
UNK_9CF9:
	DB    6
    DB    1
    DB 0E8H,0E9H,0EAH,0EBH,0ECH,0EDH
UNK_9D01:
	DB    6
    DB    1
    DB 0EAH,0EBH,0ECH,0EDH,0EEH,0EFH
UNK_9D09:
	DB    6
    DB    1
    DB 0ECH,0EDH,0EEH,0EFH,0E0H,0E1H
UNK_9D11:
	DB    6
    DB    1
    DB 0EEH,0EFH,0E0H,0E1H,0E2H,0E3H
    DW UNK_9D1F
    DW RAM_DD+0DH
    DB    0
    DB  80H
UNK_9D1F:
	DB    0
    DB 0B8H
    DB    0
    DB    0
    DB    0
    DW UNK_9D26
UNK_9D26:
	DB    6
    DB    4
    DB 0B8H,0B9H,0BAH,0B8H,0B9H,0BAH
    DB 0D8H,0D4H,0E0H,0E1H,0D2H,0DBH
    DB 0D9H,0DAH,0D0H,0D1H,0DAH,0DCH
    DB 0E8H,0E9H,0F4H,0F5H,0E9H,0EAH

PO_DATA_9D40:
	DW UNK_9D46
    DW RAM_EE
    DB    0
    DB  80H
UNK_9D46:
	DB    0
    DB 0B8H
    DB    0
    DB    0
    DB    0
    DW UNK_9D57
    DW UNK_9D65
    DW UNK_9D73
    DW UNK_9D81
    DW UNK_9D8F
    DW UNK_9D9D
UNK_9D57:
	DB    6
    DB    2
    DB 0BBH,0BCH,0BDH,0BBH,0BCH,0BDH
    DB 0D8H,0D3H,0E0H,0E1H,0D2H,0DBH
UNK_9D65:
	DB    6
    DB    2
    DB 0C0H,0C1H,0C2H,0C0H,0C1H,0C2H
    DB 0D8H,0D4H,0E2H,0E3H,0D2H,0DBH
UNK_9D73:
	DB    6
    DB    2
    DB 0BBH,0BCH,0BDH,0BBH,0BCH,0BDH
    DB 0D8H,0D3H,0E0H,0E4H,0D2H,0DBH
UNK_9D81:
	DB    6
    DB    2
    DB 0C0H,0C1H,0C2H,0C0H,0C1H,0C2H
    DB 0D8H,0D4H,0E2H,0E1H,0D2H,0DBH
UNK_9D8F:
	DB    6
    DB    2
    DB 0BBH,0BCH,0BDH,0BBH,0BCH,0BDH
    DB 0D8H,0D3H,0E0H,0E3H,0D2H,0DBH
UNK_9D9D:
	DB    6
    DB    2
    DB 0C0H,0C1H,0C2H,0C0H,0C1H,0C2H
    DB 0D8H,0D4H,0E2H,0E4H,0D2H,0DBH
PO_FACTORY:
	DW UNK_9DB1
    DW RAM_EE+6
    DB    0
    DB  80H
UNK_9DB1:
	DB    0
    DB 0B8H
    DB    0
    DB    0
    DB    0
    DW UNK_9DCE
    DW UNK_9DD4
    DW UNK_9DDA
    DW UNK_9DE0
    DW UNK_9DE6
    DW UNK_9DE6
    DW UNK_9DE0
    DW UNK_9DDA
    DW UNK_9DD4
    DW UNK_9DCE
    DW UNK_9DEC
    DW UNK_9DF2
UNK_9DCE:
	DB    2
    DB    2
    DB 0C8H,0C9H
    DB 0E9H,0E9H
UNK_9DD4:
	DB    2
    DB    2
    DB 0CAH,0CBH
    DB 0E9H,0E9H
UNK_9DDA:
	DB    2
    DB    2
    DB 0CCH,0CDH
    DB 0E9H,0E9H
UNK_9DE0:
	DB    2
    DB    2
    DB 0CEH,0CFH
    DB 0E9H,0E9H
UNK_9DE6:
	DB    2
    DB    2
    DB 0D0H,0D1H
    DB 0F0H,0F1H
UNK_9DEC:
	DB    2
    DB    2
    DB 0D0H,0D1H
    DB 0F2H,0F3H
UNK_9DF2:
	DB    2
    DB    2
    DB 0D0H,0D1H
    DB 0F4H,0F5H
    DW BYTE_9DFE
    DW RAM_DD+0DH
    DB    0
    DB  80H
BYTE_9DFE:
	DB 0
    DB 0B8H
    DB    0
    DB    0
    DB    0
    DW UNK_9E05
UNK_9E05:
	DB    6
    DB    4
    DB 0B8H,0C3H,0C4H,0C5H,17H,17H
    DB  17H,0C0H,0D0H,0D1H,17H,17H
    DB  17H,0C1H,0D8H,0D9H,0DAH,17H
    DB  17H,0C2H,0DBH,0DEH,0DFH,0E8H

PO_DATA_9E1F:
	DW UNK_9E25
    DW RAM_EE
    DB    0
    DB  80H
UNK_9E25:
	DB    0
    DB 0B8H
    DB    0
    DB    0
    DB    0
    DW UNK_9E32
    DW UNK_9E37
    DW UNK_9E3C
    DW UNK_9E41
UNK_9E32:
	DB    3
    DB    1
    DB 0C3H
    DB 0C4H
    DB 0C5H
UNK_9E37:
	DB    3
    DB    1
    DB 0C6H
    DB 0C7H
    DB 0C8H
UNK_9E3C:
	DB    3
    DB    1
    DB 0C9H
    DB 0CAH
    DB 0CBH
UNK_9E41:
	DB    3
    DB    1
    DB 0CCH
    DB 0CDH
    DB 0CEH

PO_ROBOTS:
	DW UNK_9E4C
    DW RAM_EE+6
    DB    0
    DB  80H
UNK_9E4C:
	DB    0
    DB 0B8H
    DB    0
    DB    0
    DB    0
    DW UNK_9E59
    DW UNK_9E5D
    DW UNK_9E61
    DW UNK_9E65
UNK_9E59:
	DB    2
    DB    1
    DB 0DBH,0DCH
UNK_9E5D:
	DB    2
    DB    1
    DB 0DCH,0DDH
UNK_9E61:
	DB    2
    DB    1
    DB 0DDH,0DEH
UNK_9E65:
	DB    2
    DB    1
    DB 0DEH,0DBH
PO_DATA_9E69:
	DW UNK_9E6F
    DW RAM_EE+0CH
    DB    0
    DB  80H
UNK_9E6F:
	DB    0
    DB 0B8H
    DB    0
    DB    0
    DB    0
    DW UNK_9E80
    DW UNK_9E80
    DW UNK_9E84
    DW UNK_9E88
    DW UNK_9E88
    DW UNK_9E84
UNK_9E80:
	DB    2
    DB    1
    DB 0DFH,0E8H
UNK_9E84:
	DB    2
    DB    1
    DB 0E0H,0E9H
UNK_9E88:
	DB    2
    DB    1
    DB 0E1H,0EAH

DATA_9E8C:
	DW UNK_9F04
    DW RAM_FF+7
    DW RAM_MM
    DW UNK_9F04
    DW RAM_GG
    DW RAM_MM+0DH
    DW UNK_9F04
    DW RAM_GG+6
    DW RAM_MM+1AH
    DW UNK_9F04
    DW RAM_GG+0CH
    DW RAM_MM+27H
    DW UNK_9F04
    DW RAM_GG+12H
    DW RAM_MM+34H
    DW UNK_9F04
    DW RAM_GG+18H
    DW RAM_MM+41H
    DW UNK_9F04
    DW RAM_GG+1EH
    DW RAM_MM+4EH
    DW UNK_9F04
    DW RAM_GG+24H
    DW RAM_MM+5BH
    DW UNK_9F04
    DW RAM_GG+2AH
    DW RAM_MM+68H
    DW UNK_9F04
    DW RAM_GG+30H
    DW RAM_MM+75H
    DW UNK_9F04
    DW RAM_HH
    DW RAM_MM+82H
    DW UNK_9F04
    DW RAM_JJ
    DW RAM_MM+8FH
    DW UNK_9F04
    DW RAM_LL
    DW RAM_MM+9CH
    DW UNK_9F04
    DW RAM_LL+6
    DW RAM_MM+0A9H
    DW UNK_9F04
    DW RAM_LL+0CH
    DW RAM_MM+0B6H
    DW UNK_9F04
    DW RAM_LL+12H
    DW RAM_MM+0C3H
    DW UNK_9F04
    DW RAM_LL+18H
    DW RAM_MM+0D0H
    DW UNK_9F04
    DW RAM_LL+1EH
    DW RAM_MM+0DDH
    DW UNK_9F04
    DW RAM_LL+24H
    DW RAM_MM+0EAH
    DW UNK_9F04
    DW RAM_LL+2AH
    DW RAM_MM+0F7H
UNK_9F04:
	DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DW UNK_9F79
    DW UNK_9F7F
    DW UNK_9F85
    DW UNK_9F8B
    DW UNK_9F91
    DW UNK_9F97
    DW UNK_9F9D
    DW UNK_9FA5
    DW UNK_9FAD
    DW UNK_9FB5
    DW UNK_9FBB
    DW UNK_9FC3
    DW UNK_9FCB
    DW UNK_9FD3
    DW UNK_9FD9
    DW UNK_9FE1
    DW UNK_9FE9
    DW UNK_9FF1
    DW UNK_9FF7
    DW UNK_9FFF
    DW UNK_A007
    DW UNK_A00F
    DW UNK_A017
    DW UNK_A022
    DW UNK_A02D
    DW UNK_A038
    DW UNK_A03E
    DW UNK_A049
    DW UNK_A054
    DW UNK_A05A
    DW UNK_A060
    DW UNK_A06B
    DW UNK_A076
    DW UNK_A081
    DW UNK_A087
    DW UNK_A092
    DW UNK_A09D
    DW UNK_A0A3
    DW UNK_A0A9
    DW UNK_A0AD
    DW UNK_A0B2
    DW UNK_A0B7
    DW UNK_A0BC
    DW UNK_A0C1
    DW UNK_A0C6
    DW UNK_A0CB
    DW UNK_A0D0
    DW UNK_A0D5
    DW UNK_A0DB
    DW UNK_A0E1
    DW UNK_A0E7
    DW UNK_A0ED
    DW UNK_A0F3
    DW UNK_A0F9
    DW UNK_A0FF
    DW UNK_A105
UNK_9F79:
    DB    2
    DB    2
    DB  81H,83H
    DB  82H,84H
UNK_9F7F:
    DB    2
    DB    2
    DB  77H,9CH
    DB  82H,84H
UNK_9F85:
    DB    2
    DB    2
    DB  77H,0B0H
    DB  82H,84H
UNK_9F8B:
    DB    2
    DB    2
    DB  77H,79H
    DB  82H,84H
UNK_9F91:
    DB    2
    DB    2
    DB 0B1H,79H
    DB  82H,84H
UNK_9F97:
    DB    2
    DB    2
    DB 0AFH,79H
    DB  82H,84H
UNK_9F9D:
    DB    3
    DB    2
    DB  77H,9CH,16H
    DB  82H,84H,16H
UNK_9FA5:
    DB    3
    DB    2
    DB  9DH,9FH,16H
    DB  9EH,0A0H,16H
UNK_9FAD:
    DB    3
    DB    2
    DB  16H,0A2H,0A4H
    DB 0A1H,0A3H,0A5H
UNK_9FB5:
    DB    2
    DB    2
    DB 0A6H,0A8H
    DB 0A7H,0A9H
UNK_9FBB:
    DB    3
    DB    2
    DB  16H,0AFH,79H
    DB  16H,82H,84H
UNK_9FC3:
    DB    3
    DB    2
    DB  16H,0ADH,0AEH
    DB  16H,0A7H,0A9H
UNK_9FCB:
    DB    3
    DB    2
    DB  16H,0ACH,0A4H
    DB 0A1H,0A3H,0A5H
UNK_9FD3:
    DB    2
    DB    2
    DB 0AAH,0ABH
    DB  9EH,0A0H
UNK_9FD9:
    DB    2
    DB    3
    DB  63H,65H
    DB  64H,66H
    DB  16H,16H
UNK_9FE1:
    DB    2
    DB    3
    DB  67H,6AH
    DB  68H,6BH
    DB  69H,6CH
UNK_9FE9:
    DB    2
    DB    3
    DB  6DH,70H
    DB  6EH,71H
    DB  6FH,72H
UNK_9FF1:
    DB    2
    DB    2
    DB  73H,75H
    DB  74H,76H
UNK_9FF7:
    DB    2
    DB    3
    DB  16H,16H
    DB  77H,79H
    DB  78H,7AH
UNK_9FFF:
    DB    2
    DB    3
    DB  16H,16H
    DB  7BH,7CH
    DB  74H,76H
UNK_A007:
    DB    2
    DB    3
    DB  6DH,70H
    DB  7DH,7EH
    DB  6FH,72H
UNK_A00F:
    DB    2
    DB    3
    DB  67H,6AH
    DB  7FH,80H
    DB  69H,6CH
UNK_A017:
    DB    3
    DB    3
    DB  16H,16H,16H
    DB  81H,83H,16H
    DB  82H,84H,16H
UNK_A022:
    DB    3
    DB    3
    DB  16H,16H,16H
    DB  85H,87H,16H
    DB  86H,88H,16H
UNK_A02D:
    DB    3
    DB    3
    DB  16H,8BH,16H
    DB  89H,8CH,8EH
    DB  8AH,8DH,8FH
UNK_A038:
    DB    2
    DB    2
    DB  90H,92H
    DB  91H,93H
UNK_A03E:
    DB    3
    DB    3
    DB  16H,90H,92H
    DB  16H,91H,93H
    DB  16H,16H,16H
UNK_A049:
    DB    3
    DB    3
    DB  16H,8BH,16H
    DB  89H,8CH,8EH
    DB  8AH,8DH,8FH
UNK_A054:
    DB    2
    DB    2
    DB  85H,87H
    DB  86H,88H
UNK_A05A:
    DB    2
    DB    2
    DB  81H,83H
    DB  82H,84H
UNK_A060:
    DB    3
    DB    3
    DB  16H,16H,16H
    DB  16H,81H,83H
    DB  16H,82H,84H
UNK_A06B:
    DB    3
    DB    3
    DB  16H,16H,16H
    DB  16H,98H,9AH
    DB  16H,99H,9BH
UNK_A076:
    DB    3
    DB    3
    DB  16H,8BH,16H
    DB  89H,8CH,8EH
    DB  8AH,8DH,8FH
UNK_A081:
    DB    2
    DB    2
    DB  94H,96H
    DB  95H,97H
UNK_A087:
    DB    3
    DB    3
    DB  94H,96H,16H
    DB  95H,97H,16H
    DB  16H,16H,16H
UNK_A092:
    DB    3
    DB    3
    DB  16H,8BH,16H
    DB  89H,8CH,8EH
    DB  8AH,8DH,8FH
UNK_A09D:
    DB    2
    DB    2
    DB  98H,9AH
    DB  99H,9BH
UNK_A0A3:
    DB    2
    DB    2
    DB  81H,83H
    DB  82H,84H
UNK_A0A9:
    DB    1
    DB    2
    DB  38H
    DB  39H
UNK_A0AD:
    DB    1
    DB    3
    DB  38H
    DB  3AH
    DB  16H
UNK_A0B2:
    DB    1
    DB    3
    DB  3BH
    DB  3CH
    DB  3DH
UNK_A0B7:
    DB    1
    DB    3
    DB  3EH
    DB  3FH
    DB  40H
UNK_A0BC:
    DB    1
    DB    3
    DB  41H
    DB  42H
    DB  43H
UNK_A0C1:
    DB    1
    DB    3
    DB  16H
    DB  44H
    DB  3AH
UNK_A0C6:
    DB    1
    DB    3
    DB  45H
    DB  46H
    DB  43H
UNK_A0CB:
    DB    1
    DB    3
    DB  47H
    DB  3FH
    DB  40H
UNK_A0D0:
    DB    1
    DB    3
    DB  48H
    DB  3CH
    DB  3DH
UNK_A0D5:
    DB    2
    DB    2
    DB  49H,16H
    DB  4AH,16H
UNK_A0DB:
    DB    2
    DB    2
    DB  4BH,4DH
    DB  4CH,4EH
UNK_A0E1:
    DB    2
    DB    2
    DB  4FH,51H
    DB  50H,52H
UNK_A0E7:
    DB    2
    DB    2
    DB  53H,55H
    DB  54H,56H
UNK_A0ED:
    DB    2
    DB    2
    DB  16H,61H
    DB  16H,62H
UNK_A0F3:
    DB    2
    DB    2
    DB  53H,5FH
    DB  5EH,60H
UNK_A0F9:
    DB    2
    DB    2
    DB  5AH,5CH
    DB  5BH,5DH
UNK_A0FF: 
	DB    2
    DB    2
    DB  57H,4DH
    DB  58H,59H
UNK_A105:
	DB    1
    DB    1
    DB  17H

PO_DATA_A108:
	DW UNK_A10D
    DW RAM_NN
    DB    2
UNK_A10D:
	DB    3
    DB    0
    DB    0
    DB    0
    DB    0
    DW UNK_A114
UNK_A114:
	DB    8
    DB 0F0H
    DB  0AH
    DB 0F4H
    DB  0FH
    DB 0F8H

PO_DATA_A11A:
	DW UNK_A120
    DW RAM_UU+8
    DB 0F4H
    DB  72H
UNK_A120:
	DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DW UNK_A135
    DW UNK_A13B
    DW UNK_A141
    DW UNK_A147
    DW UNK_A14D
    DW UNK_A153
    DW UNK_9FF1
    DW UNK_A105
UNK_A135:
	DB    2
    DB    2
    DB  69H,6CH
    DB  16H,16H
UNK_A13B:
	DB    2
    DB    2
    DB  6FH,72H
    DB  16H,16H
UNK_A141:
	DB    2
    DB    2
    DB  74H,76H
    DB  16H,16H
UNK_A147:
	DB    2
    DB    2
    DB  64H,66H
    DB  16H,16H
UNK_A14D:
	DB    2
    DB    2
    DB  68H,6BH
    DB  69H,6CH
UNK_A153:
	DB    2
    DB    2
    DB  6EH,71H
    DB  6FH,72H


SUB_A159:
    JP      SUB_A1A1
SUB_A15C:
    JP      SUB_A219
SUB_A15F:
    JP      SUB_A4B0
SUB_A162:
    JP      SUB_A7E8
SUB_A165:
    JP      SUB_AAAA
SUB_A168:
    JP      SUB_B034
SUB_A16B:
    JP      SUB_B18C
SUB_A16E:
    JP      SUB_B2EA
SUB_A171:
    JP      SUB_B420
SUB_A174:
    JP      SUB_B49E
SUB_A177:
    JP      SUB_B752
SUB_A17A:
    JP      SUB_A2C7
SUB_A17D:
    JP      SUB_A2D5
SUB_A180:
    JP      SUB_A6F0
SUB_A183:
    JP      SUB_A856
SUB_A186:
    JP      SUB_A865
SUB_A189:
    JP      SUB_A8A2
SUB_A18C:
    JP      SUB_A95B
SUB_A18F:
    JP      SUB_A1EB
SUB_A192:
    JP      SUB_A75C
SUB_A195:
    JP      SUB_A7C3
SUB_A198:
    JP      SUB_A9ED
MISSING_SUB_01:                                     ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ NO LINK?
    JP      SUB_B67E
SUB_A19E:
    JP      SUB_A8F1

SUB_A1A1:
    LD      BC, 200H
    LD      (RAM_CC+11H), BC
    CALL    SUB_A2FA
    LD      HL, DATA_908A
    LD      DE, 0
    LD      IY, 7
    LD      A, 4
    RST     8
    CALL    SUB_A3A5
    LD      HL, PO_DATA_9BE2
    XOR     A
    CALL    ACTIVATE
    CALL    SUB_A8F1
    CALL    SUB_B2EA
    CALL    SUB_A7E8
    LD      HL, RAM_DD
    LD      (HL), 0
    INC     HL
    LD      DE, 20H
    LD      (HL), E
    INC     HL
    LD      (HL), D
    INC     HL
    LD      DE, 70H
    LD      (HL), E
    INC     HL
    LD      (HL), D
    LD      IX, PO_DATA_9BE2
    CALL    PUTOBJ
    LD      A, 2
    LD      (RAM_FF+5), A
RET 

SUB_A1EB:
    CALL    SUB_C7CC
    CALL    INITIALIZE_CONTROLLERS
    LD      HL, RAM_AA
    LD      DE, RAM_BB
    CALL    INIT_TIMER
    JP      SUB_A271

INITIALIZE_CONTROLLERS:
    LD      HL, CONTROLLER_BUFFER
    LD      (HL), 9BH
    INC     HL
    LD      (HL), 9BH
    INC     HL
    LD      DE,  CONTROLLER_BUFFER+3
    LD      BC, 0AH
    LD      (HL), 0
    LDIR
    LD      A, 0FH
    LD      (CONTROLLER_BUFFER+6), A
    LD      (CONTROLLER_BUFFER+0BH), A
RET 

SUB_A219:
    CALL    READ_REGISTER
    BIT     7, A
    JR      Z, SUB_A219
    LD      A, (RAM_DD+7)
    INC     A
    CP      2
    JR      C, SUB_A229
    XOR     A

SUB_A229:
    LD      (RAM_DD+7), A
    LD      A, (RAM_DD+8)
    INC     A
    CP      3
    JR      C, SUB_A235
    XOR     A

SUB_A235:
    LD      (RAM_DD+8), A
    LD      A, (RAM_DD+9)
    INC     A
    CP      0AH
    JR      C, SUB_A241
    XOR     A

SUB_A241:
    LD      (RAM_DD+9), A
    LD      A, (RAM_DD+0BH)
    INC     A
    CP      1EH
    JR      C, SUB_A24D
    XOR     A

SUB_A24D:
    LD      (RAM_DD+0BH), A
    LD      A, (RAM_DD+0AH)
    INC     A
    CP      0FH
    JR      C, SUB_A259
    XOR     A

SUB_A259:
    LD      (RAM_DD+0AH), A
    CALL    RAND_GEN
    LD      A, (CONTROLLER_BUFFER+3)
    LD      (RAM_DD+5), A
    LD      A, (CONTROLLER_BUFFER+8)
    LD      (RAM_DD+6), A
    CALL    POLLER
    JP      SUB_C7C6

SUB_A271:
    CALL    GAME_OPT
    LD      B, 78H
    CALL    SUB_A2DC
    XOR     A
    CALL    REQUEST_SIGNAL
    PUSH    AF
    CALL    SUB_A2D5

SUB_A281:
    CALL    SUB_A219
    CALL    TIME_MGR
    POP     AF
    PUSH    AF
    CALL    TEST_SIGNAL
    CALL    NZ, SUB_A2C7
    CALL    RAND_GEN
    CALL    POLLER
    LD      A, (CONTROLLER_BUFFER+6)
    CP      0FH
    JR      NZ, SUB_A2A3
    LD      A, (CONTROLLER_BUFFER+0BH)
    CP      0FH
    JR      Z, SUB_A281

SUB_A2A3:
    CP      0AH
    JP      Z, 0
    CP      0BH
    JP      Z, 0
    DEC     A
    BIT     3, A
    JR      NZ, SUB_A281
    LD      (RAM_CC), A
    AND     3
    LD      A, 3
    JR      NZ, SUB_A2BD
    LD      A, 5

SUB_A2BD:
    LD      (RAM_CC+0DH), A
    LD      (RAM_CC+0EH), A
    POP     AF
    CALL    FREE_SIGNAL

SUB_A2C7:
    LD      B, 1
    LD      C, 80H
    CALL    WRITE_REGISTER
    LD      B, 7
    LD      C, 1
    JP      WRITE_REGISTER

SUB_A2D5:
    LD      B, 1
    LD      C, 0C2H
    JP      WRITE_REGISTER

SUB_A2DC:
    LD      A, (AMERICA)
    LD      E, A
    LD      HL, 0
    LD      D, H

SUB_A2E4:
    ADD     HL, DE
    DJNZ    SUB_A2E4
RET 

SUB_A2E8:
    LD      IY, 1

SUB_A2EC:
    LD      A, 3
    JP      PUT_VRAM

    DB 0FDH                           ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ NO LINK?
    DB  21H
    DB  1CH
    DB    0

SUB_A2F5:
    LD      A, 2
    JP      PUT_VRAM

SUB_A2FA:
    CALL    SUB_A365
    LD      HL, (RAM_EXTRA+4)
    LD      DE, 0A8H
    ADD     HL, DE
    EX      DE, HL
    LD      HL, PATTERN_DATA_00
    CALL    SUB_A312
    LD      HL, PATTERN_DATA_06
    LD      DE, (RAM_EXTRA)

SUB_A312:
    LD      (RAM_SS), DE
    LD      A, (HL)
    INC     HL
    OR      A
RET      Z
    BIT     7, A
    JR      Z, SUB_A33A
    RES     7, A
    OR      A
    JR      Z, SUB_A35C
    LD      B, 0
    LD      C, A
    LD      (RAM_SS+2), BC
    CALL    WRITE_VRAM
    PUSH    HL
    LD      HL, (RAM_SS)
    LD      BC, (RAM_SS+2)
    ADD     HL, BC
    EX      DE, HL
    POP     HL
    JR      SUB_A312

SUB_A33A:
    LD      B, 0
    LD      C, A

SUB_A33D:
    LD      (RAM_SS+2), BC
    LD      BC, 1
    CALL    WRITE_VRAM
    LD      DE, (RAM_SS)
    INC     DE
    LD      (RAM_SS), DE
    LD      BC, (RAM_SS+2)
    DEC     BC
    LD      A, C
    OR      A
    JR      Z, SUB_A312
    DEC     HL
    JR      SUB_A33D

SUB_A35C:
    LD      B, 0
    LD      C, (HL)
    INC     HL
    EX      DE, HL
    ADD     HL, BC
    EX      DE, HL
    JR      SUB_A312

SUB_A365:
    LD      HL, 0
    LD      DE, 4000H
    XOR     A
    CALL    FILL_VRAM
    LD      HL, (6CH)
    LD      DE, 0
    LD      IY, 0AH
    CALL    SUB_A2EC
    LD      IX, DATA_AA1C
    LD      DE, 9
    LD      B, 0BH

SUB_A385:
    PUSH    DE

SUB_A386:
    LD      L, (IX+0)
    INC     IX
    LD      H, 0
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    LD      DE, (6AH)
    ADD     HL, DE
    POP     DE
    INC     DE
    PUSH    DE
    PUSH    BC
    PUSH    IX
    CALL    SUB_A2E8
    POP     IX
    POP     BC
    DJNZ    SUB_A386
    POP     DE
RET 

SUB_A3A5:
    LD      HL,  RAM_CC+1
    LD      B, 0CH

SUB_A3AA:
    LD      (HL), 0
    INC     HL
    DJNZ    SUB_A3AA
RET 

SUB_A3B0:
    LD      A, B
    ADD     A, 3
    LD      E, A

SUB_A3B4:
    CALL    SUB_AA70
    LD      (HL), D
    INC     B
    LD      A, E
    CP      B
    JR      NC, SUB_A3B4
RET 

SUB_A3BE:
    LD      A, C
    CP      0BH
    JR      Z, SUB_A3C7
    ADD     A, 3
    JR      SUB_A3C9

SUB_A3C7:
    ADD     A, 5

SUB_A3C9:
    LD      E, A

SUB_A3CA:
    CALL    SUB_AA70
    LD      (HL), D
    INC     C
    LD      A, E
    CP      C
    JR      NC, SUB_A3CA
RET 

SUB_A3D4:
    LD      BC, 5
    CALL    SUB_A3F2
    LD      BC, 5
    CALL    SUB_A3F2
    LD      BC, 7
    CALL    SUB_A3F2
    LD      BC, 5
    CALL    SUB_A3F2
    LD      BC, 5
    CALL    SUB_A3F2

SUB_A3F2:
    LD      IY, 1
    PUSH    HL
    PUSH    DE
    PUSH    BC
    LD      BC, 1
    CALL    WRITE_VRAM
    POP     HL
    POP     DE
    ADD     HL, DE
    EX      DE, HL
    POP     HL
    INC     HL
RET 

SUB_A406:
    LD      B, 4

SUB_A408:
    PUSH    HL
    PUSH    DE
    PUSH    BC
    CALL    SUB_A3D4
    POP     BC
    POP     DE
    LD      HL, 20H
    ADD     HL, DE
    EX      (SP), HL
    LD      DE, 6
    ADD     HL, DE
    POP     DE
    DJNZ    SUB_A408
RET 

SUB_A41D:
    LD      BC, 40H
    LD      HL, 15H

SUB_A423:
    PUSH    HL
    LD      HL, WORK_BUFFER
    PUSH    DE
    PUSH    BC
    PUSH    HL
    LD      BC, 20H
    CALL    READ_VRAM
    POP     HL
    POP     DE
    PUSH    DE
    LD      IY, 20H
    LD      A, 2
    RST     8
    POP     DE
    LD      HL, 20H
    ADD     HL, DE
    LD      B, H
    LD      C, L
    POP     DE
    LD      HL, 20H
    ADD     HL, DE
    EX      DE, HL
    POP     HL
    DEC     HL
    LD      A, H
    OR      L
    JR      NZ, SUB_A423
    CALL    SUB_A219
    JP      SUB_A219

SUB_A453:
    CALL    SUB_A489
    LD      HL,  WORK_BUFFER+1
    LD      DE, 0
    LD      IY, 1
    LD      A, 0
    RST     10H
    LD      HL, WORK_BUFFER
    LD      A, (HL)
    SRA     A
    SRA     A
    SRA     A
    SRA     A
    AND     0FH
    LD      B, A
    LD      HL,  WORK_BUFFER+4
    LD      A, (HL)
    AND     0F0H
    OR      B
    LD      (HL), A
    LD      HL,  WORK_BUFFER+1
    LD      DE, 0
    LD      IY, 1
    LD      A, 0
    JP      PUT_VRAM

SUB_A489:
    LD      A, (RAM_DD+0CH)
    OR      A
    LD      A, (RAM_CC+0FH)
    JR      Z, SUB_A495
    LD      A, (RAM_CC+10H)

SUB_A495:
    LD      E, A
    SLA     E
    SLA     E
    LD      D, 0
    LD      HL, DATA_9091
    ADD     HL, DE
    LD      A, (HL)
    LD      HL, WORK_BUFFER
    LD      (HL), A
RET 

SUB_A4A6:
    LD      B, 4

SUB_A4A8:
    PUSH    BC
    CALL    SUB_A219
    POP     BC
    DJNZ    SUB_A4A8
RET 

SUB_A4B0:
    CALL    SUB_A856
    CALL    SUB_C7CC
    CALL    SUB_A489
    LD      DE, 4
    LD      B, 1CH

SUB_A4BE:
    PUSH    BC
    PUSH    DE
    PUSH    HL
    LD      IY, 1
    LD      A, 4
    RST     8
    POP     HL
    POP     DE
    INC     DE
    POP     BC
    DJNZ    SUB_A4BE
    CALL    SUB_B034
    CP      4
    JR      NZ, SUB_A4FE
    LD      A, (HL)
    AND     0F0H
    LD      B, A
    SRA     A
    SRA     A
    SRA     A
    SRA     A
    AND     0FH
    OR      B
    LD      (HL), A
    INC     HL
    LD      (HL), A
    DEC     HL
    LD      DE, 19H
    LD      IY, 2
    LD      A, 4
    PUSH    HL
    RST     8
    POP     HL
    LD      DE, 1EH
    LD      IY, 1
    LD      A, 4
    RST     8

SUB_A4FE:
    LD      A, (RAM_FF+6)
    OR      A
    JP      Z, SUB_A57E
    CP      1
    JR      Z, SUB_A514
    CP      2
    JP      Z, SUB_A5E8
    CP      3
    JP      Z, SUB_A64B
RET 

SUB_A514:
    LD      B, 15H

SUB_A516:
    PUSH    BC
    LD      DE, 60H
    LD      B, 14H
    LD      HL, WORK_BUFFER

SUB_A51F:
    LD      IY, 20H
    LD      A, 2
    PUSH    BC
    PUSH    HL
    PUSH    DE
    RST     10H
    POP     HL
    LD      DE, 20H
    XOR     A
    SBC     HL, DE
    EX      DE, HL
    POP     HL
    LD      IY, 20H
    LD      A, 2
    PUSH    HL
    PUSH    DE
    RST     8
    POP     HL
    LD      DE, 40H
    ADD     HL, DE
    EX      DE, HL
    POP     HL
    POP     BC
    DJNZ    SUB_A51F
    LD      B, 20H

SUB_A547:
    LD      (HL), 17H
    INC     HL
    DJNZ    SUB_A547
    LD      HL, WORK_BUFFER
    LD      DE, 2C0H
    LD      IY, 20H
    LD      A, 2
    RST     8
    LD      HL, RAM_DD
    INC     HL
    INC     HL
    INC     HL
    LD      A, (HL)
    CP      0C0H
    JR      Z, SUB_A56C
    ADD     A, 0F8H
    CP      10H
    JR      NC, SUB_A56C
    LD      A, 0C0H

SUB_A56C:
    LD      (HL), A
    LD      IX, PO_DATA_9BE2
    CALL    PUTOBJ
    CALL    SUB_A453
    CALL    SUB_A4A6
    POP     BC
    DJNZ    SUB_A516
RET 

SUB_A57E:
    LD      B, 15H

SUB_A580:
    PUSH    BC
    LD      DE, 2A0H
    LD      B, 14H
    LD      HL, WORK_BUFFER

SUB_A589:
    LD      IY, 20H
    LD      A, 2
    PUSH    BC
    PUSH    HL
    PUSH    DE
    RST     10H
    POP     HL
    LD      DE, 20H
    ADD     HL, DE
    EX      DE, HL
    POP     HL
    LD      IY, 20H
    LD      A, 2
    PUSH    HL
    PUSH    DE
    RST     8
    POP     HL
    LD      DE, 40H
    XOR     A
    SBC     HL, DE
    EX      DE, HL
    POP     HL
    POP     BC
    DJNZ    SUB_A589
    LD      B, 20H

SUB_A5B1:
    LD      (HL), 17H
    INC     HL
    DJNZ    SUB_A5B1
    LD      HL, WORK_BUFFER
    LD      DE, 40H
    LD      IY, 20H
    LD      A, 2
    RST     8
    LD      HL, RAM_DD
    INC     HL
    INC     HL
    INC     HL
    LD      A, (HL)
    CP      0C0H
    JR      Z, SUB_A5D6
    ADD     A, 8
    CP      0A8H
    JR      C, SUB_A5D6
    LD      A, 0C0H

SUB_A5D6:
    LD      (HL), A
    LD      IX, PO_DATA_9BE2
    CALL    PUTOBJ
    CALL    SUB_A453
    CALL    SUB_A4A6
    POP     BC
    DJNZ    SUB_A580
RET 

SUB_A5E8:
    LD      B, 1CH

SUB_A5EA:
    PUSH    BC
    LD      HL, RAM_DD
    INC     HL
    LD      A, (HL)
    CP      0FFH
    JR      Z, SUB_A5FC
    ADD     A, 8
    CP      0E8H
    JR      C, SUB_A5FC
    LD      A, 0FFH

SUB_A5FC:
    LD      (HL), A
    LD      IX, PO_DATA_9BE2
    CALL    PUTOBJ
    CALL    SUB_A453
    LD      IX, PO_DATA_9BE2
    CALL    PUTOBJ
    CALL    SUB_A453
    LD      IX, PO_DATA_9BE2
    CALL    PUTOBJ
    CALL    SUB_A453
    LD      B, 15H
    LD      DE, 42H

SUB_A620:
    PUSH    BC
    PUSH    DE
    LD      HL, WORK_BUFFER
    LD      (HL), 17H
    INC     HL
    LD      IY, 1BH
    LD      A, 2
    RST     10H
    POP     DE
    PUSH    DE
    LD      HL, WORK_BUFFER
    LD      IY, 1CH
    LD      A, 2
    RST     8
    POP     DE
    LD      HL, 20H
    ADD     HL, DE
    EX      DE, HL
    POP     BC
    DJNZ    SUB_A620
    CALL    SUB_A4A6
    POP     BC
    DJNZ    SUB_A5EA
RET 

SUB_A64B:
    LD      B, 1CH

SUB_A64D:
    PUSH    BC
    LD      HL, RAM_DD
    INC     HL
    LD      A, (HL)
    CP      0FFH
    JR      Z, SUB_A65F
    ADD     A, 0F8H
    CP      10H
    JR      NC, SUB_A65F
    LD      A, 0FFH

SUB_A65F:
    LD      (HL), A
    LD      IX, PO_DATA_9BE2
    CALL    PUTOBJ
    CALL    SUB_A453
    LD      IX, PO_DATA_9BE2
    CALL    PUTOBJ
    CALL    SUB_A453
    LD      IX, PO_DATA_9BE2
    CALL    PUTOBJ
    CALL    SUB_A453
    LD      B, 15H
    LD      DE, 43H

SUB_A683:
    PUSH    BC
    PUSH    DE
    LD      HL, WORK_BUFFER
    LD      IY, 1BH
    LD      A, 2
    RST     10H
    POP     DE
    PUSH    DE
    DEC     DE
    LD      HL,  WORK_BUFFER+1BH
    LD      (HL), 17H
    LD      HL, WORK_BUFFER
    LD      IY, 1CH
    LD      A, 2
    RST     8
    POP     DE
    LD      HL, 20H
    ADD     HL, DE
    EX      DE, HL
    POP     BC
    DJNZ    SUB_A683
    CALL    SUB_A4A6
    POP     BC
    DJNZ    SUB_A64D
RET 

DATA_A6B1:
	DB 000,000,001,000,001,000,000,002,000,000,003,000,000,004,000,000,005,000,000,006,000
	DB 000,007,000,000,008,000,000,009,000,001,000,000,001,001,000,001,002,000,001,003,000
	DB 001,004,000,001,005,000,001,006,000,001,007,000,001,008,000,001,009,000,002,000,000

SUB_A6F0:
    LD      D, 0
    LD      HL, DATA_A6B1
    ADD     HL, DE
    ADD     HL, DE
    ADD     HL, DE
    INC     HL
    INC     HL
    LD      A, (RAM_DD+0CH)
    LD      BC, 300H
    LD      DE,  RAM_CC+6
    OR      A
    JR      Z, SUB_A709
    LD      DE,  RAM_CC+0CH

SUB_A709:
    PUSH    DE
    DEC     DE
    DEC     DE
    DEC     DE
    LD      A, (DE)
    AND     1
    LD      (RAM_VV+6), A
    POP     DE

SUB_A714:
    LD      A, (DE)
    ADD     A, (HL)
    ADD     A, C
    LD      C, 0
    CP      0AH
    JR      C, SUB_A721
    ADD     A, 0F6H
    LD      C, 1

SUB_A721:
    LD      (DE), A
    DEC     DE
    DEC     HL
    DJNZ    SUB_A714
    LD      B, 3

SUB_A728:
    LD      A, (DE)
    ADD     A, C
    LD      C, 0
    CP      0AH
    JR      C, SUB_A734
    ADD     A, 0F6H
    LD      C, 1

SUB_A734:
    LD      (DE), A
    DEC     DE
    DJNZ    SUB_A728
    INC     DE
    INC     DE
    INC     DE
    LD      A, (DE)
    AND     1
    JR      Z, SUB_A75C
    LD      A, (RAM_VV+6)
    OR      A
    JR      NZ, SUB_A75C
    LD      A, (RAM_DD+0CH)
    LD      HL,  RAM_CC+0DH
    OR      A
    JR      Z, SUB_A752
    LD      HL,  RAM_CC+0EH

SUB_A752:
    LD      A, (HL)
    CP      10H
    JR      NC, SUB_A75C
    INC     A
    LD      (HL), A
    CALL    SUB_C858

SUB_A75C:
    LD      HL, DATA_AA30
    LD      DE, 2
    LD      IY, 8
    CALL    SUB_A2F5
    LD      HL,  RAM_CC+1
    LD      DE, 22H
    LD      IY, 6
    CALL    SUB_A2F5
    LD      DE, 29H ; ')'
    LD      A, (RAM_DD+0CH)
    OR      A
    LD      A, (RAM_CC+0DH)
    JR      Z, SUB_A783
    XOR     A

SUB_A783:
    CALL    SUB_AA00
    LD      A, (RAM_CC)
    BIT     2, A
	RET      Z
    LD      HL, DATA_AA30
    LD      DE, 10H
    LD      IY, 6
    CALL    SUB_A2F5
    LD      HL, DATA_AA38
    LD      DE, 17H
    LD      IY, 1
    CALL    SUB_A2F5
    LD      HL,  RAM_CC+7
    LD      DE, 30H
    LD      IY, 6
    CALL    SUB_A2F5
    LD      DE, 37H
    LD      A, (RAM_DD+0CH)
    OR      A
    LD      A, (RAM_CC+0EH)
    JR      NZ, SUB_A7C0
    XOR     A

SUB_A7C0:
    JP      SUB_AA00

SUB_A7C3:
    PUSH    AF
    LD      IY, 8
    LD      DE, 2
    OR      A
    JR      Z, SUB_A7D1
    LD      DE, 10H

SUB_A7D1:
    CALL    SUB_A7E2
    POP     AF

SUB_A7D5:
    LD      IY, 0DH
    LD      DE, 22H
    OR      A
    JR      Z, SUB_A7E2
    LD      DE, 30H

SUB_A7E2:
    LD      HL, DATA_AA59
    JP      SUB_A2F5

SUB_A7E8:
    LD      HL, (RAM_EXTRA+2)
    LD      DE, 300H
    LD      A, 17H
    CALL    FILL_VRAM
    CALL    SUB_B3CB
    CALL    SUB_A75C
    LD      HL, 1000H
    LD      DE, 520H
    LD      A, 17H
    CALL    FILL_VRAM
    LD      A, 4
    LD      BC, 1CH
    LD      HL,  RAM_FF+7
    LD      DE, 1002H

SUB_A80F:
    PUSH    AF
    PUSH    BC
    PUSH    DE
    PUSH    HL
    CALL    WRITE_VRAM
    POP     HL
    LD      DE, 1CH
    ADD     HL, DE
    POP     DE
    PUSH    HL
    LD      HL, 20H
    ADD     HL, DE
    EX      DE, HL
    POP     HL
    PUSH    DE
    PUSH    HL
    CALL    SUB_A406
    POP     HL
    LD      DE, 18H
    ADD     HL, DE
    POP     DE
    PUSH    HL
    LD      HL, 80H
    ADD     HL, DE
    EX      DE, HL
    POP     HL
    POP     BC
    POP     AF
    DEC     A
    JR      NZ, SUB_A80F
    CALL    WRITE_VRAM
    CALL    SUB_A2D5
    LD      DE, 1280H
    LD      B, 0BH

SUB_A845:
    PUSH    BC
    PUSH    DE
    CALL    SUB_A41D
    POP     HL
    LD      DE, 40H
    XOR     A
    SBC     HL, DE
    EX      DE, HL
    POP     BC
    DJNZ    SUB_A845
RET 

SUB_A856:
    LD      HL, (RAM_EXTRA+2)
    LD      DE, 2E0H
    ADD     HL, DE
    LD      DE, 20H
    LD      A, 17H
    JP      FILL_VRAM

SUB_A865:
    LD      HL, WORK_BUFFER
    LD      DE, 2EBH
    LD      IY, 1
    LD      A, 2
    PUSH    HL
    RST     10H
    POP     HL
    LD      A, (HL)
    CP      11H
	RET      Z
    LD      A, (RAM_VV+8)
    CALL    FREE_SIGNAL
    LD      A, 1
    LD      HL, 0F0H
    CALL    REQUEST_SIGNAL
    LD      (RAM_VV+8), A
    LD      IX, DATA_AA24
    LD      DE, 11H
    LD      B, 3
    CALL    SUB_A385
    LD      HL, DATA_AA39
    LD      DE, 2EAH
    LD      IY, 0CH
    JP      SUB_A2F5

SUB_A8A2:
    LD      A, (RAM_VV+8)
    CALL    FREE_SIGNAL
    LD      A, 1
    LD      HL, 12CH
    CALL    REQUEST_SIGNAL
    LD      (RAM_VV+8), A
    LD      IX, DATA_AA27
    LD      DE, 11H
    LD      B, 3
    CALL    SUB_A385
    CALL    SUB_A856
    LD      HL, DATA_AA4E
    LD      DE, 2EBH
    LD      IY, 5
    CALL    SUB_A2F5
    LD      A, (RAM_VV+7)
    LD      E, A
    LD      D, 0
    LD      HL, DATA_A6B1
    ADD     HL, DE
    ADD     HL, DE
    ADD     HL, DE
    LD      DE, 2F2H
    LD      IY, 3
    LD      A, (HL)
    OR      A
    JP      NZ, SUB_A2F5
    INC     HL
    INC     DE
    LD      BC, 0FFFFH
    ADD     IY, BC
    JP      SUB_A2F5

SUB_A8F1:
    LD      A, (RAM_CC)
    BIT     2, A
	RET      Z
    LD      A, 1
    LD      HL, 5AH
    CALL    REQUEST_SIGNAL
    LD      (RAM_VV+8), A
    LD      IX, DATA_AA2D
    LD      DE, 11H
    LD      B, 3
    CALL    SUB_A385
    LD      HL, (RAM_EXTRA+2)
    LD      DE, 300H
    LD      A, 17H
    CALL    FILL_VRAM
    LD      HL, DATA_AA45
    LD      DE, 14CH
    LD      IY, 9
    CALL    SUB_A2F5
    LD      HL, DATA_AA30
    LD      DE, 18CH
    LD      IY, 7
    CALL    SUB_A2F5
    LD      HL, DATA_AA37
    LD      A, (RAM_DD+0CH)
    OR      A
    JR      Z, SUB_A93F
    LD      HL, DATA_AA38

SUB_A93F:
    LD      DE, 194H
    LD      IY, 1
    CALL    SUB_A2F5
    CALL    SUB_A2D5

SUB_A94C:
    CALL    SUB_A219
    CALL    TIME_MGR
    LD      A, (RAM_VV+8)
    CALL    TEST_SIGNAL
    JR      Z, SUB_A94C
RET 

SUB_A95B:
    LD      IX, DATA_AA2A
    LD      DE, 11H
    LD      B, 3
    CALL    SUB_A385
    CALL    SUB_A856
    LD      HL, DATA_AA65
    LD      DE, 10DH
    LD      IY, 6
    CALL    SUB_A2F5
    LD      HL, DATA_AA6A
    LD      DE, 12DH
    LD      IY, 6
    CALL    SUB_A2F5
    LD      HL, DATA_AA30
    LD      DE, 14DH
    LD      IY, 6
    CALL    SUB_A2F5
    LD      HL, DATA_AA59
    LD      DE, 16DH
    LD      IY, 6
    CALL    SUB_A2F5
    LD      A, (RAM_DD+0CH)
    LD      HL, DATA_AA37
    OR      A
    JR      Z, SUB_A9AA
    LD      HL, DATA_AA38

SUB_A9AA:
    LD      DE, 16FH
    LD      IY, 1
    CALL    SUB_A2F5
    LD      A, 1
    LD      HL, 0AH
    CALL    REQUEST_SIGNAL
    LD      B, 9

SUB_A9BE:
    PUSH    BC
    PUSH    AF
    LD      HL,  RAM_CC+0EH
    LD      A, (RAM_CC)
    BIT     2, A
    LD      A, (RAM_CC+0DH)
    JR      Z, SUB_A9CE
    OR      (HL)

SUB_A9CE:
    OR      A
    LD      A, (RAM_DD+0CH)
    JR      NZ, SUB_A9DA
    XOR     A
    CALL    SUB_A7D5
	LD      A, 1

SUB_A9DA:
    CALL    SUB_A7D5
    POP     AF
    PUSH    AF
    CALL    SUB_A9ED
    CALL    SUB_A75C
    POP     AF
    CALL    SUB_A9ED
    POP     BC
    DJNZ    SUB_A9BE
RET 

SUB_A9ED:
    PUSH    AF
    CALL    SUB_A219
    CALL    TIME_MGR
    POP     AF
    PUSH    AF
    CALL    TEST_SIGNAL
    JR      NZ, SUB_A9FE
    POP     AF
    JR      SUB_A9ED

SUB_A9FE:
    POP     AF
RET 

SUB_AA00:
    CP      7
    JR      C, SUB_AA06
    LD      A, 6

SUB_AA06:
    OR      A
    JR      Z, SUB_AA0A
    DEC     A

SUB_AA0A:
    LD      C, A
    LD      B, 0
    LD      HL, DATA_AA59
    XOR     A
    SBC     HL, BC
    LD      IY, 6
    LD      A, 2
    JP      PUT_VRAM

DATA_AA1C:
	DB  0FH
    DB  0BH
    DB    0
    DB  18H
    DB    4
    DB  11H
    DB  0EH
    DB    1

DATA_AA24:
	DB  13H
    DB    2
    DB  0AH

DATA_AA27:
	DB  0DH
    DB  12H
    DB  14H

DATA_AA2A:
	DB    6
    DB  0CH
    DB  15H

DATA_AA2D:
	DB    6
    DB  13H
    DB    3

DATA_AA30:
	DB  0AH
    DB  0BH
    DB  0CH
    DB  0DH
    DB  0EH
    DB  0FH
    DB  17H

DATA_AA37:
	DB    1

DATA_AA38:
	DB    2

DATA_AA39:
	DB  0FH
    DB  10H
    DB  11H
    DB  10H
    DB  12H
    DB  17H
    DB  0CH
    DB  12H
    DB  12H
    DB  0CH
    DB  13H
    DB  14H

DATA_AA45:
	DB  12H
    DB  0EH
    DB  13H
    DB  17H
    DB  0FH
    DB  0EH
    DB  0CH
    DB  14H
    DB  0DH

DATA_AA4E:
	DB  11H
    DB  10H
    DB  12H
    DB  14H
    DB  13H
    DB  15H
    DB  15H
    DB  15H
    DB  15H
    DB  15H
    DB  15H

DATA_AA59:
	DB  17H
    DB  17H
    DB  17H
    DB  17H
    DB  17H
    DB  17H
    DB  17H
    DB  17H
    DB  17H
    DB  17H
    DB  17H
    DB  17H

DATA_AA65:
	DB  17H
    DB  12H
    DB  0CH
    DB  13H
    DB  0EH

DATA_AA6A:
	DB  17H
    DB  10H
    DB  14H
    DB  0EH
    DB  0FH
    DB  17H

SUB_AA70:
    PUSH    DE
    PUSH    BC
    LD      A, B
    LD      B, 5

SUB_AA75:
    OR      A
    JP      M, SUB_AA7E
    JR      Z, SUB_AA89
    SUB     B
    JR      SUB_AA75

SUB_AA7E:
    POP     BC
    LD      E, C
    LD      D, 0
    LD      HL, DATA_906E
    ADD     HL, DE
    LD      E, (HL)
    JR      SUB_AA8D

SUB_AA89:
    POP     BC
    LD      E, C
    LD      D, 0

SUB_AA8D:
    PUSH    DE
    LD      E, B
    LD      HL, DATA_9059
    ADD     HL, DE
    LD      E, (HL)
    POP     HL
    ADD     HL, DE
    LD      DE,  RAM_FF+7
    ADD     HL, DE
    POP     DE
RET 

SUB_AA9C:
    LD      HL,  RAM_FF+7
    LD      DE,  RAM_FF+8
    LD      BC, 0EBH
    LD      (HL), 17H
    LDIR
RET 

SUB_AAAA:
    CALL    RAND_GEN
    CALL    RAND_GEN
    CALL    RAND_GEN
    AND     3FH
RET 

DATA_AAB6:
	DB    5
    DB    1
    DB  0AH
    DB    1
    DB  11H
    DB    1
    DB  16H
    DB    1
    DB    5
    DB    6
    DB  0AH
    DB    6
    DB  11H
    DB    6
    DB  16H
    DB    6
    DB    5
    DB  0BH
    DB  0AH
    DB  0BH
    DB  11H
    DB  0BH
    DB  16H
    DB  0BH
    DB    5
    DB  10H
    DB  0AH
    DB  10H
    DB  11H
    DB  10H
    DB  16H
    DB  10H
DATA_AAD6:
	DB    1
    DB    5
    DB    6
    DB    5
    DB  0BH
    DB    5
    DB  12H
    DB    5
    DB  17H
    DB    5
    DB    1
    DB  0AH
    DB    6
    DB  0AH
    DB  0BH
    DB  0AH
    DB  12H
    DB  0AH
    DB  17H
    DB  0AH
    DB    1
    DB  0FH
    DB    6
    DB  0FH
    DB  0BH
    DB  0FH
    DB  12H
    DB  0FH
    DB  17H
    DB  0FH
DATA_AAF4:
	DB    5
    DB    5
    DB  0AH
    DB    5
    DB  11H
    DB    5
    DB  16H
    DB    5
    DB    5
    DB  0AH
    DB  0AH
    DB  0AH
    DB  11H
    DB  0AH
    DB  16H
    DB  0AH
    DB    5
    DB  0FH
    DB  0AH
    DB  0FH
    DB  11H
    DB  0FH
    DB  16H
    DB  0FH
DATA_AB0C:
	DB 0C7H
    DB  70H
    DB 0CCH
    DB  70H
    DB 0D1H
    DB  70H
    DB 0D8H
    DB  70H
    DB 0DDH
    DB  70H
    DB 0E2H
    DB  70H
    DB 0FBH
    DB  70H
    DB  16H
    DB  71H
    DB  2FH
    DB  71H
    DB  4AH
    DB  71H
    DB  63H
    DB  71H
    DB  7EH
    DB  71H
    DB  97H
    DB  71H
    DB  9CH
    DB  71H
    DB 0A1H
    DB  71H
    DB 0A8H
    DB  71H
    DB 0ADH
    DB  71H
    DB 0B2H
    DB  71H

OBJECT_DATA_AB30:
	DB  17H
    DB  2EH
    DB  2CH
    DB  21H
    DB  2DH
    DB  24H
    DB  25H
    DB  29H
    DB  2BH
    DB  22H
    DB  23H
    DB  27H
    DB  20H
    DB  2AH
    DB  28H
    DB  26H

SUB_AB40:
    LD      B, 10H
    LD      HL, DATA_AAB6

SUB_AB45:
    PUSH    BC
    PUSH    HL
    CALL    SUB_AAAA
    CP      9
    JR      NC, SUB_AB52
    LD      A, 1BH
    JR      SUB_AB5C

SUB_AB52:
    CP      12H
    JR      NC, SUB_AB5A
    LD      A, 20H
    JR      SUB_AB5C

SUB_AB5A:
    LD      A, 17H

SUB_AB5C:
    POP     HL
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    INC     HL
    PUSH    HL
    LD      D, A
    CALL    SUB_A3B0
    POP     HL
    POP     BC
    DJNZ    SUB_AB45
RET 

SUB_AB6B:
    LD      B, 0FH
    LD      HL, DATA_AAD6

SUB_AB70:
    PUSH    BC
    PUSH    HL
    CALL    SUB_AAAA
    CP      0EH
    JR      NC, SUB_AB7D
    LD      A, 18H
    JR      SUB_AB87

SUB_AB7D:
    CP      1CH
    JR      NC, SUB_AB85
    LD      A, 21H
    JR      SUB_AB87

SUB_AB85:
    LD      A, 17H

SUB_AB87:
    POP     HL
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    INC     HL
    PUSH    HL
    LD      D, A
    CALL    SUB_A3BE
    POP     HL
    POP     BC
    DJNZ    SUB_AB70
RET 

SUB_AB96:
    PUSH    HL
    LD      E, 0
    PUSH    BC
    DEC     B
    CALL    SUB_AA70
    LD      A, (HL)
    CP      1BH
    JR      Z, SUB_AC08
    CP      20H
    JR      Z, SUB_ABAA
    XOR     A
    JR      SUB_ABAC

SUB_ABAA:
    LD      A, 1

SUB_ABAC:
    SLA     E
    OR      E
    LD      E, A
    POP     BC
    PUSH    BC
    INC     B
    CALL    SUB_AA70
    LD      A, (HL)
    CP      1BH
    JR      Z, SUB_AC08
    CP      20H
    JR      Z, SUB_ABC2
    XOR     A
    JR      SUB_ABC4

SUB_ABC2:
    LD      A, 1

SUB_ABC4:
    SLA     E
    OR      E
    LD      E, A
    POP     BC
    PUSH    BC
    INC     C
    CALL    SUB_AA70
    LD      A, (HL)
    CP      18H
    JR      Z, SUB_AC08
    CP      21H
    JR      Z, SUB_ABDA
    XOR     A
    JR      SUB_ABDC

SUB_ABDA:
    LD      A, 1

SUB_ABDC:
    SLA     E
    OR      E
    LD      E, A
    POP     BC
    PUSH    BC
    DEC     C
    CALL    SUB_AA70
    LD      A, (HL)
    CP      18H
    JR      Z, SUB_AC08
    CP      21H
    JR      Z, SUB_ABF2
    XOR     A
    JR      SUB_ABF4

SUB_ABF2:
    LD      A, 1

SUB_ABF4:
    SLA     E
    OR      E
    LD      E, A
    LD      D, 0
    LD      HL, OBJECT_DATA_AB30
    ADD     HL, DE
    LD      A, (HL)

SUB_ABFF:
    POP     BC
    PUSH    AF
    CALL    SUB_AA70
    POP     AF
    LD      (HL), A
    POP     HL
RET 

SUB_AC08:
    LD      A, 1EH
    JR      SUB_ABFF

SUB_AC0C:
    LD      B, 0CH
    LD      HL, DATA_AAF4

LOOP_AC11:
    PUSH    BC
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    INC     HL
    CALL    SUB_AB96
    POP     BC
    DJNZ    LOOP_AC11
RET 

SUB_AC1D:
    LD      A, C
    ADD     A, A
    ADD     A, A
    ADD     A, C
    CP      0FH
    JR      C, SUB_AC27
    ADD     A, 2

SUB_AC27:
    LD      C, A
RET 

SUB_AC29:
    LD      A, B
    ADD     A, A
    ADD     A, A
    ADD     A, B
    LD      B, A
RET 

SUB_AC2F:
    INC     C

SUB_AC30:
    PUSH    AF
    CALL    SUB_AC1D
    CALL    SUB_AC29
    INC     B
    JR      SUB_AC49

SUB_AC3A:
    PUSH    AF
    CALL    SUB_AC1D
    JR      SUB_AC45

SUB_AC40:
    PUSH    AF
    CALL    SUB_AC1D
    INC     B

SUB_AC45:
    INC     C
    CALL    SUB_AC29

SUB_AC49:
    CALL    SUB_AA70
    POP     AF
RET 

SUB_AC4E:
    LD      BC, 0

SUB_AC51:
    PUSH    BC
    CALL    SUB_AC2F
    POP     BC
    LD      A, (HL)
    CP      17H
    JR      NZ, SUB_AC71
    INC     C
    LD      A, C
    CP      4
    JR      C, SUB_AC51
    CALL    SUB_AAAA
    AND     3
    LD      C, A
    PUSH    BC
    CALL    SUB_AC2F
    LD      D, 1BH
    CALL    SUB_A3B0
    POP     BC

SUB_AC71:
    LD      C, 0
    INC     B
    LD      A, B
    CP      4
    JR      C, SUB_AC51
    LD      BC, 0

SUB_AC7C:
    PUSH    BC
    CALL    SUB_AC40
    POP     BC
    LD      A, (HL)
    CP      17H
    JR      NZ, SUB_ACAB
    INC     B
    LD      A, B
    CP      3
    JR      C, SUB_AC7C
    CALL    SUB_AAAA
    CP      15H
    JR      NC, SUB_AC96
    XOR     A
    JR      SUB_ACA0

SUB_AC96:
    CP      2AH
    JR      NC, SUB_AC9E
    LD      A, 1
    JR      SUB_ACA0

SUB_AC9E:
    LD      A, 2

SUB_ACA0:
    LD      B, A
    PUSH    BC
    CALL    SUB_AC40
    LD      D, 18H
    CALL    SUB_A3BE
    POP     BC

SUB_ACAB:
    LD      B, 0
    INC     C
    LD      A, C
    CP      5
    JR      C, SUB_AC7C
RET 

SUB_ACB4:
    LD      BC, 0

SUB_ACB7:
    PUSH    BC
    CALL    SUB_AC40
    POP     BC
    LD      A, (HL)
    CP      17H
    JR      Z, SUB_ACDC
    INC     C
    LD      A, C
    CP      5
    JR      C, SUB_ACB7
    CALL    SUB_AAAA
    AND     3
    CP      2
    JR      C, SUB_ACD1
    INC     A

SUB_ACD1:
    LD      C, A
    PUSH    BC
    CALL    SUB_AC40
    LD      D, 17H
    CALL    SUB_A3BE
    POP     BC

SUB_ACDC:
    LD      C, 0
    INC     B
    LD      A, B
    CP      3
    JR      C, SUB_ACB7
    LD      BC, 0

SUB_ACE7:
    PUSH    BC
    CALL    SUB_AC2F
    POP     BC
    LD      A, (HL)
    CP      17H
    JR      Z, SUB_AD0B
    INC     B
    LD      A, B
    CP      4
    JR      C, SUB_ACE7

SUB_ACF7:
    CALL    SUB_AAAA
    AND     3
    CP      1
    JR      Z, SUB_ACF7
    LD      B, A
    PUSH    BC
    CALL    SUB_AC2F
    LD      D, 17H
    CALL    SUB_A3B0
    POP     BC

SUB_AD0B:
    LD      B, 0
    INC     C
    LD      A, C
    CP      4
    JR      C, SUB_ACE7
RET 

SUB_AD14:
    LD      BC, 0

SUB_AD17:
    LD      IX, WORK_BUFFER
    LD      IY, 0

SUB_AD1F:
    PUSH    BC
    LD      A, B
    CP      1
    JR      NZ, SUB_AD44
    CALL    SUB_B034
    CP      8
    JR      Z, SUB_AD44
    CP      2
    JR      C, SUB_AD44
    CALL    SUB_AAAA
    AND     1
    JR      Z, SUB_AD39
    LD      C, 3

SUB_AD39:
    CALL    SUB_AC2F
    LD      D, 17H
    CALL    SUB_A3B0
    JP      SUB_ADCC

SUB_AD44:
    CALL    SUB_AC2F
    POP     BC
    LD      A, (HL)
    CP      17H
    JP      Z, SUB_ADA3
    LD      A, B
    OR      A
    JR      Z, SUB_AD72
    PUSH    BC
    DEC     B
    CALL    SUB_AC2F
    POP     BC
    LD      A, (HL)
    CP      17H
    JR      NZ, SUB_AD72
    PUSH    BC
    CALL    SUB_AC3A
    POP     BC
    LD      A, (HL)
    CP      17H
    JR      NZ, SUB_AD72
    PUSH    BC
    INC     C
    CALL    SUB_AC3A
    POP     BC
    LD      A, (HL)
    CP      17H
    JR      Z, SUB_ADA3

SUB_AD72:
    LD      A, B
    CP      3
    JR      Z, SUB_AD97
    PUSH    BC
    INC     B
    CALL    SUB_AC2F
    POP     BC
    LD      A, (HL)
    CP      17H
    JR      NZ, SUB_AD97
    PUSH    BC
    CALL    SUB_AC40
    POP     BC
    LD      A, (HL)
    CP      17H
    JR      NZ, SUB_AD97
    PUSH    BC
    INC     C
    CALL    SUB_AC40
    POP     BC
    LD      A, (HL)
    CP      17H
    JR      Z, SUB_ADA3

SUB_AD97:
    LD      (IX+0), C
    LD      (IX+1), B
    INC     IX
    INC     IX
    INC     IY

SUB_ADA3:
    INC     C
    LD      A, C
    CP      4
    JP      C, SUB_AD1F
    PUSH    BC
    PUSH    IY
    POP     BC
    LD      A, C
    CP      2
    JR      C, SUB_ADCC
    CALL    SUB_AAAA
    CALL    SUB_AE86
    LD      HL, WORK_BUFFER
    LD      E, A
    LD      D, 0
    ADD     HL, DE
    ADD     HL, DE
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    CALL    SUB_AC2F
    LD      D, 17H
    CALL    SUB_A3B0

SUB_ADCC:
    POP     BC
    LD      C, 0
    INC     B
    LD      A, B
    CP      4
    JP      C, SUB_AD17
    LD      BC, 0

SUB_ADD9:
    LD      IX, WORK_BUFFER
    LD      IY, 0

SUB_ADE1:
    PUSH    BC
    LD      A, C
    CP      2
    JR      NZ, SUB_ADF3
    CALL    SUB_B034
    CP      8
    JR      Z, SUB_ADF3
    CP      2
    JP      NC, SUB_AE7B

SUB_ADF3:
    CALL    SUB_AC40
    POP     BC
    LD      A, (HL)
    CP      17H
    JP      Z, SUB_AE52
    LD      A, C
    OR      A
    JR      Z, SUB_AE21
    PUSH    BC
    DEC     C
    CALL    SUB_AC40
    POP     BC
    LD      A, (HL)
    CP      17H
    JR      NZ, SUB_AE21
    PUSH    BC
    CALL    SUB_AC30
    POP     BC
    LD      A, (HL)
    CP      17H
    JR      NZ, SUB_AE21
    PUSH    BC
    INC     B
    CALL    SUB_AC30
    POP     BC
    LD      A, (HL)
    CP      17H
    JR      Z, SUB_AE52

SUB_AE21:
    LD      A, C
    CP      4
    JR      Z, SUB_AE46
    PUSH    BC
    INC     C
    CALL    SUB_AC40
    POP     BC
    LD      A, (HL)
    CP      17H
    JR      NZ, SUB_AE46
    PUSH    BC
    CALL    SUB_AC2F
    POP     BC
    LD      A, (HL)
    CP      17H
    JR      NZ, SUB_AE46
    PUSH    BC
    INC     B
    CALL    SUB_AC2F
    POP     BC
    LD      A, (HL)
    CP      17H
    JR      Z, SUB_AE52

SUB_AE46:
    LD      (IX+0), C
    LD      (IX+1), B
    INC     IX
    INC     IX
    INC     IY

SUB_AE52:
    INC     B
    LD      A, B
    CP      3
    JP      C, SUB_ADE1
    PUSH    BC
    PUSH    IY
    POP     BC
    LD      A, C
    CP      2
    JR      C, SUB_AE7B
    CALL    SUB_AAAA
    CALL    SUB_AE86
    LD      HL, WORK_BUFFER
    LD      E, A
    LD      D, 0
    ADD     HL, DE
    ADD     HL, DE
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    CALL    SUB_AC40
    LD      D, 17H
    CALL    SUB_A3BE

SUB_AE7B:
    POP     BC
    LD      B, 0
    INC     C
    LD      A, C
    CP      5
    JP      C, SUB_ADD9
RET 

SUB_AE86:
    SUB     C
    JR      NC, SUB_AE86
    ADD     A, C
RET 

SUB_AE8B:
    CALL    SUB_B034
    CP      8
    JR      Z, SUB_AEE8
    LD      BC, (RAM_CC+11H)
    LD      A, B
    OR      A
    JR      NZ, SUB_AEC0
    LD      A, C
    CP      2
    JR      NZ, SUB_AEC0
    PUSH    BC
    CALL    SUB_B034
    POP     BC
    CP      2
    JR      C, SUB_AEC0
    CP      8
    JR      NC, SUB_AEC0
    PUSH    BC
    CALL    SUB_AC30
    LD      D, 17H
    CALL    SUB_A3B0
    POP     BC
    CALL    SUB_AC2F
    LD      D, 17H
    CALL    SUB_A3B0
    JR      SUB_AF14

SUB_AEC0:
    CALL    SUB_AC3A
    LD      A, (HL)
    CP      17H
	RET      Z
    LD      BC, (RAM_CC+11H)
    CALL    SUB_AC40
    LD      A, (HL)
    CP      17H
	RET      Z
    LD      BC, (RAM_CC+11H)
    CALL    SUB_AC30
    LD      A, (HL)
    CP      17H
RET      Z
    LD      BC, (RAM_CC+11H)
    CALL    SUB_AC2F
    LD      A, (HL)
    CP      17H
RET      Z

SUB_AEE8:
    LD      BC, (RAM_CC+11H)
    LD      A, B
    OR      A
    JR      Z, SUB_AEF9
    CP      3
    JR      NZ, SUB_AF03
    CALL    SUB_AC3A
    JR      SUB_AEFC

SUB_AEF9:
    CALL    SUB_AC40

SUB_AEFC:
    LD      D, 17H
    CALL    SUB_A3BE
    JR      SUB_AF14

SUB_AF03:
    LD      A, C
    OR      A
    JR      NZ, SUB_AF0C
    CALL    SUB_AC2F
    JR      SUB_AF0F

SUB_AF0C:
    CALL    SUB_AC30

SUB_AF0F:
    LD      D, 17H
    CALL    SUB_A3B0

SUB_AF14:
    CALL    SUB_B034
    CP      8
	RET      NZ
    LD      BC, (RAM_CC+11H)
    LD      A, B
    OR      A
    JP      Z, SUB_AF59
    CP      3
    JP      Z, SUB_AFA3
    LD      A, C
    OR      A
    JP      Z, SUB_AFED
    DEC     C
    PUSH    BC
    CALL    SUB_AC3A
    POP     BC
    LD      A, (HL)
    CP      17H
	RET      Z
    PUSH    BC
    CALL    SUB_AC30
    POP     BC
    LD      A, (HL)
    CP      17H
	RET      Z
    PUSH    BC
    CALL    SUB_AC40
    POP     BC
    LD      A, (HL)
    CP      17H
	RET      Z
    CALL    SUB_AAAA
    CP      15H
    JP      C, SUB_B024
    CP      2AH
    JP      C, SUB_B01C
    JP      SUB_B02C

SUB_AF59:
    INC     B
    PUSH    BC
    CALL    SUB_AC30
    POP     BC
    LD      A, (HL)
    CP      17H
	RET      Z
    PUSH    BC
    CALL    SUB_AC40
    POP     BC
    LD      A, (HL)
    CP      17H
	RET      Z
    PUSH    BC
    CALL    SUB_AC2F
    POP     BC
    LD      A, (HL)
    CP      17H
	RET      Z
    LD      A, C
    OR      A
    JR      Z, SUB_AF8D
    CP      4
    JR      Z, SUB_AF98
    CALL    SUB_AAAA
    CP      15H
    JP      C, SUB_B01C
    CP      2AH
    JP      C, SUB_B02C
    JP      SUB_B014

SUB_AF8D:
    CALL    SUB_AAAA
    CP      20H
    JP      C, SUB_B02C
    JP      SUB_B014

SUB_AF98:
    CALL    SUB_AAAA
    CP      20H
    JP      C, SUB_B02C
    JP      SUB_B01C

SUB_AFA3:
    DEC     B
    PUSH    BC
    CALL    SUB_AC30
    POP     BC
    LD      A, (HL)
    CP      17H
	RET      Z
    PUSH    BC
    CALL    SUB_AC3A
    POP     BC
    LD      A, (HL)
    CP      17H
	RET      Z
    PUSH    BC
    CALL    SUB_AC2F
    POP     BC
    LD      A, (HL)
    CP      17H
	RET      Z
    LD      A, C
    OR      A
    JR      Z, SUB_AFD7
    CP      4
    JR      Z, SUB_AFE2
    CALL    SUB_AAAA
    CP      15H
    JP      C, SUB_B01C
    CP      2AH
    JP      C, SUB_B024
    JP      SUB_B014

SUB_AFD7:
    CALL    SUB_AAAA
    CP      20H
    JP      C, SUB_B024
    JP      SUB_B014

SUB_AFE2:
    CALL    SUB_AAAA
    CP      20H
    JP      C, SUB_B024
    JP      SUB_B01C

SUB_AFED:
    INC     C
    PUSH    BC
    CALL    SUB_AC3A
    POP     BC
    LD      A, (HL)
    CP      17H
	RET      Z
    PUSH    BC
    CALL    SUB_AC2F
    POP     BC
    LD      A, (HL)
    CP      17H
	RET      Z
    PUSH    BC
    CALL    SUB_AC40
    POP     BC
    LD      A, (HL)
    CP      17H
	RET      Z
    CALL    SUB_AAAA
    CP      15H
    JR      C, SUB_B024
    CP      2AH
    JR      C, SUB_B02C

SUB_B014:
    CALL    SUB_AC2F
    LD      D, 17H
    JP      SUB_A3B0
SUB_B01C:
    CALL    SUB_AC30
    LD      D, 17H
    JP      SUB_A3B0
SUB_B024:
    CALL    SUB_AC3A
    LD      D, 17H
    JP      SUB_A3BE
SUB_B02C:
    CALL    SUB_AC40
    LD      D, 17H
    JP      SUB_A3BE

SUB_B034:
    PUSH    DE
    PUSH    HL
    LD      A, (RAM_DD+0CH)
    LD      HL,  RAM_CC+0FH
    OR      A
    JR      Z, SUB_B042
    LD      HL,  RAM_CC+10H

SUB_B042:
    LD      E, (HL)
    SLA     E
    SLA     E
    INC     E
    INC     E
    INC     E
    LD      D, 0
    LD      HL, DATA_9091
    ADD     HL, DE
    LD      A, (HL)
    POP     HL
    POP     DE
RET 

MISSING_SUB:                           ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ NO LINK?
    LD      DE, 0
    LD      BC, (RAM_CC+11H)
    PUSH    BC
    EXX
    LD      B, 4
    EXX
    LD      C, 0

SUB_B062:
    PUSH    BC
    CALL    SUB_AC2F
    POP     BC
    LD      A, (HL)
    CP      20H
    JR      Z, SUB_B077
    CP      1BH
    JR      NZ, SUB_B078
    CALL    SUB_B034
    CP      8
    JR      NZ, SUB_B078

SUB_B077:
    INC     D

SUB_B078:
    INC     C
    EXX
    DEC     B
    EXX
    JR      NZ, SUB_B062
    POP     BC
    EXX
    LD      B, 3
    EXX
    LD      B, 0

SUB_B085:
    PUSH    BC
    CALL    SUB_AC40
    POP     BC
    LD      A, (HL)
    CP      21H
    JR      Z, SUB_B09A
    CP      18H
    JR      NZ, SUB_B09B
    CALL    SUB_B034
    CP      8
    JR      NZ, SUB_B09B

SUB_B09A:
    INC     E

SUB_B09B:
    INC     B
    EXX
    DEC     B
    EXX
    JR      NZ, SUB_B085
    LD      A, E
    CP      2
	RET      C
    LD      A, D
    CP      2
RET 

SUB_B0A9:
    CALL    SUB_B034
    CP      2
    JR      NZ, SUB_B0CC
    LD      BC, 60AH
    LD      D, 20H
    CALL    SUB_A3B0
    LD      BC, 611H
    CALL    SUB_A3B0
    LD      BC, 50BH
    LD      D, 21H
    CALL    SUB_A3BE
    LD      BC, 0A0BH
    JP      SUB_A3BE

SUB_B0CC:
    CP      3
    JR      Z, SUB_B0D4
    CP      4
    JR      NZ, SUB_B0F0

SUB_B0D4:
    LD      BC, 60AH
    LD      D, 1BH
    CALL    SUB_A3B0
    LD      BC, 611H
    CALL    SUB_A3B0
    LD      BC, 50BH
    LD      D, 18H
    CALL    SUB_A3BE
    LD      BC, 0A0BH
    JP      SUB_A3BE

SUB_B0F0:
    CP      5
	RET      NZ
    LD      BC, 60AH
    LD      D, 20H
    CALL    SUB_A3B0
    LD      BC, 611H
    CALL    SUB_A3B0
    LD      BC, 50BH
    LD      D, 21H
    CALL    SUB_A3BE
    LD      BC, 0A0BH
    CALL    SUB_A3BE
    LD      BC, (RAM_CC+11H)
    LD      A, B
    OR      A
    JR      Z, SUB_B120
    CP      3
    JR      NZ, SUB_B128
    LD      BC, 50BH
    JR      SUB_B123

SUB_B120:
    LD      BC, 0A0BH

SUB_B123:
    LD      D, 18H
    JP      SUB_A3BE

SUB_B128:
    LD      A, C
    OR      A
    JR      NZ, SUB_B131
    LD      BC, 611H
    JR      SUB_B137

SUB_B131:
    CP      4
	RET      NZ
    LD      BC, 60AH

SUB_B137:
    LD      D, 1BH
    JP      SUB_A3B0

SUB_B13C:
    CALL    SUB_B034
    CP      2
	RET      C
    LD      A, (RAM_II)
    CP      22H
	RET      C
    CP      2FH
	RET      NC
    LD      A, (RAM_KK)
    CP      22H
	RET      C
    CP      2FH
	RET      NC
    LD      A, (RAM_LL+2AH)
    CP      22H
	RET      C
    CP      2FH
	RET      NC
    LD      A, (RAM_MM+1)
    CP      22H
	RET      C
    CP      2FH
	RET      NC
    CALL    SUB_AAAA
    AND     3
    OR      A
    JR      Z, SUB_B17A
    DEC     A
    JR      Z, SUB_B180
    DEC     A
    JR      Z, SUB_B186
    LD      A, 1EH
    LD      (RAM_II), A
RET 

SUB_B17A:
    LD      A, 1EH
    LD      (RAM_KK), A
RET 

SUB_B180:
    LD      A, 1EH
    LD      (RAM_LL+2AH), A
RET 

SUB_B186:
    LD      A, 1EH
    LD      (RAM_MM+1), A
RET 

SUB_B18C:
    LD      HL, RAM_DD
    INC     HL
    LD      C, (HL)
    INC     HL
    INC     HL
    LD      B, (HL)
    RST     18H
    LD      A, C
    LD      C, 0
    CP      7
    JR      C, SUB_B1AC
    INC     C
    CP      0CH
    JR      C, SUB_B1AC
    INC     C
    CP      13H
    JR      C, SUB_B1AC
    INC     C
    CP      18H
    JR      C, SUB_B1AC
    INC     C

SUB_B1AC:
    LD      A, B
    LD      B, 0
    CP      7
	RET      C
    INC     B
    CP      0CH
	RET      C
    INC     B
    CP      11H
	RET      C
    INC     B
RET 

SUB_B1BC:
    LD      A, (RAM_FF+5)
    OR      A
    JR      Z, SUB_B1CC
    DEC     A
    JR      Z, SUB_B212
    DEC     A
    JP      Z, SUB_B262
    JP      SUB_B2A1

SUB_B1CC:
    LD      B, 0
    LD      C, 1
    CALL    SUB_AA70
    LD      B, 1AH

SUB_B1D5:
    LD      (HL), 21H
    INC     HL
    DJNZ    SUB_B1D5
    LD      A, (RAM_FF+2)
    LD      (RAM_FF+1), A
    LD      C, A
    LD      B, 0
    LD      D, 32H
    CALL    SUB_A3BE
    LD      A, (RAM_FF+2)
    CP      6
    JR      NZ, SUB_B1F3
    LD      C, 0BH
    JR      SUB_B1FD

SUB_B1F3:
    CP      0BH
    JR      NZ, SUB_B1FB
    LD      C, 12H
    JR      SUB_B1FD

SUB_B1FB:
    LD      C, 6

SUB_B1FD:
    LD      B, 14H
    LD      A, C
    LD      (RAM_FF+2), A
    LD      D, 17H
    CALL    SUB_A3BE
    CALL    SUB_B18C
    LD      B, 3
    CALL    SUB_AC40
    JR      SUB_B256

SUB_B212:
    LD      B, 14H
    LD      C, 1
    CALL    SUB_AA70
    LD      B, 1AH

SUB_B21B:
    LD      (HL), 21H
    INC     HL
    DJNZ    SUB_B21B
    LD      A, (RAM_FF+1)
    LD      (RAM_FF+2), A
    LD      C, A
    LD      B, 14H
    LD      D, 32H
    CALL    SUB_A3BE
    LD      A, (RAM_FF+1)
    CP      6
    JR      NZ, SUB_B239
    LD      C, 12H
    JR      SUB_B243

SUB_B239:
    CP      0BH
    JR      NZ, SUB_B241
    LD      C, 6
    JR      SUB_B243

SUB_B241:
    LD      C, 0BH

SUB_B243:
    LD      B, 0
    LD      A, C
    LD      (RAM_FF+1), A
    LD      D, 17H
    CALL    SUB_A3BE
    CALL    SUB_B18C
    LD      B, 0
    CALL    SUB_AC3A

SUB_B256:
    LD      D, 32H
    LD      A, (HL)
    CP      17H
    JR      Z, SUB_B25F
    LD      D, 21H

SUB_B25F:
    JP      SUB_A3BE

SUB_B262:
    LD      C, 0
    LD      B, 1

SUB_B266:
    CALL    SUB_AA70
    LD      (HL), 20H
    INC     B
    LD      A, 13H
    SUB     B
    JR      NC, SUB_B266
    LD      A, (RAM_FF+4)
    LD      (RAM_FF+3), A
    LD      B, A
    LD      C, 0
    LD      D, 31H
    CALL    SUB_A3B0
    LD      A, (RAM_FF+4)
    CP      10H
    JR      NZ, SUB_B28A
    LD      A, 1
    JR      SUB_B28C

SUB_B28A:
    ADD     A, 5

SUB_B28C:
    LD      B, A
    LD      (RAM_FF+4), A
    LD      C, 1BH
    LD      D, 17H
    CALL    SUB_A3B0
    CALL    SUB_B18C
    LD      C, 4
    CALL    SUB_AC2F
    JR      SUB_B2DE

SUB_B2A1:
    LD      C, 1BH
    LD      B, 1

SUB_B2A5:
    CALL    SUB_AA70
    LD      (HL), 20H
    INC     B
    LD      A, 13H
    SUB     B
    JR      NC, SUB_B2A5
    LD      A, (RAM_FF+3)
    LD      (RAM_FF+4), A
    LD      B, A
    LD      C, 1BH
    LD      D, 31H
    CALL    SUB_A3B0
    LD      A, (RAM_FF+3)
    CP      1
    JR      NZ, SUB_B2C9
    LD      A, 10H
    JR      SUB_B2CB

SUB_B2C9:
    ADD     A, 0FBH

SUB_B2CB:
    LD      B, A
    LD      (RAM_FF+3), A
    LD      C, 0
    LD      D, 17H
    CALL    SUB_A3B0
    CALL    SUB_B18C
    LD      C, 0
    CALL    SUB_AC30

SUB_B2DE:
    LD      D, 31H
    LD      A, (HL)
    CP      17H
    JR      Z, SUB_B2E7
    LD      D, 20H

SUB_B2E7:
    JP      SUB_A3B0

SUB_B2EA:
    CALL    SUB_AA9C
    LD      D, 18H
    LD      C, 1

SUB_B2F1:
    LD      B, 0
    CALL    SUB_AA70
    LD      (HL), D
    LD      B, 14H
    CALL    SUB_AA70
    LD      (HL), D
    INC     C
    LD      A, 1AH
    SUB     C
    JR      NC, SUB_B2F1
    LD      D, 1BH
    LD      B, 1

SUB_B307:
    LD      C, 0
    CALL    SUB_AA70
    LD      (HL), D
    LD      C, 1BH
    CALL    SUB_AA70
    LD      (HL), D
    INC     B
    LD      A, 13H
    SUB     B
    JR      NC, SUB_B307
    LD      A, (RAM_FF)
    OR      A
    JR      Z, SUB_B329
    CALL    SUB_B1BC
    LD      A, (RAM_FF+6)
    CP      2
    JR      C, SUB_B360

SUB_B329:
    LD      HL, (RAM_ZZ)
    LD      A, L
    AND     0FH
    CP      5
    JR      NC, SUB_B339
    LD      C, 6
    LD      D, 12H
    JR      SUB_B347

SUB_B339:
    CP      0BH
    JR      NC, SUB_B343
    LD      C, 0BH
    LD      D, 6
    JR      SUB_B347

SUB_B343:
    LD      C, 12H
    LD      D, 0BH

SUB_B347:
    PUSH    DE
    LD      A, C
    LD      (RAM_FF+2), A
    LD      B, 14H
    LD      D, 17H
    CALL    SUB_A3BE
    POP     DE
    LD      B, 0
    LD      C, D
    LD      A, C
    LD      (RAM_FF+1), A
    LD      D, 17H
    CALL    SUB_A3BE

SUB_B360:
    LD      A, (RAM_FF)
    OR      A
    JR      Z, SUB_B36D
    LD      A, (RAM_FF+6)
    CP      2
    JR      NC, SUB_B39D

SUB_B36D:
    LD      HL, (RAM_ZZ)
    LD      A, H
    AND     3
    LD      E, A
    ADD     A, A
    ADD     A, A
    ADD     A, E
    INC     A
    LD      B, A
    CP      10H
    JR      NZ, SUB_B381
    LD      A, 1
    JR      SUB_B383

SUB_B381:
    ADD     A, 5

SUB_B383:
    LD      D, A
    PUSH    DE
    LD      A, B
    LD      (RAM_FF+3), A
    LD      C, 0
    LD      D, 17H
    CALL    SUB_A3B0
    POP     DE
    LD      B, D
    LD      A, B
    LD      (RAM_FF+4), A
    LD      C, 1BH
    LD      D, 17H
    CALL    SUB_A3B0

SUB_B39D:
    LD      B, 12H
    LD      HL, DATA_AB0C
    LD      A, 30H

SUB_B3A4:
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    INC     HL
    LD      (DE), A
    DJNZ    SUB_B3A4
    CALL    SUB_AB40
    CALL    SUB_AB6B
    CALL    SUB_AC4E
    CALL    SUB_AE8B
    CALL    SUB_B0A9
    CALL    SUB_ACB4
    CALL    SUB_AD14
    CALL    SUB_AC0C
    CALL    SUB_B13C
    XOR     A
    LD      (RAM_FF), A
RET 

SUB_B3CB:
    LD      A, (RAM_DD+0CH)
    OR      A
    LD      A, (RAM_CC+0FH)
    JR      Z, SUB_B3D7
    LD      A, (RAM_CC+10H)

SUB_B3D7:
    SLA     A
    SLA     A
    LD      E, A
    LD      D, 0
    LD      HL, DATA_9091
    ADD     HL, DE
    PUSH    HL
    LD      DE, 3
    LD      IY, 1
    LD      A, 4
    RST     8
    POP     HL
    INC     HL
    PUSH    HL
    LD      DE, 6
    LD      IY, 1
    LD      A, 4
    RST     8
    POP     HL
    INC     HL
    LD      DE, 7
    LD      B, 10H

LOOP_B401:
    PUSH    HL
    PUSH    DE
    PUSH    BC
    LD      IY, 1
    LD      A, 4
    RST     8
    POP     BC
    POP     DE
    POP     HL
    INC     DE
    DJNZ    LOOP_B401
    LD      HL, DATA_908E
    LD      DE, 4
    LD      IY, 2
    LD      A, 4
    JP      PUT_VRAM

SUB_B420:
    LD      A, (RAM_DD+0CH)
    LD      HL,  RAM_CC+0FH
    OR      A
    JR      Z, SUB_B42C
    LD      HL,  RAM_CC+10H

SUB_B42C:
    LD      A, (RAM_SS+0AH)
    OR      A
	RET      NZ
    LD      A, (HL)
    CP      9
    JR      NZ, SUB_B44D
    LD      A, (RAM_CC)
    AND     3
    LD      B, A
    LD      A, (RAM_DD+0CH)
    OR      A
    LD      A, (RAM_VV+4)
    JR      Z, SUB_B448
    LD      A, (RAM_VV+9)

SUB_B448:
    CP      B
    JR      Z, SUB_B487
    JR      SUB_B46E

SUB_B44D:
    CP      0DH
    JR      Z, SUB_B482
    PUSH    HL
    CALL    SUB_B034
    POP     HL
    OR      A
    JR      NZ, SUB_B471
    LD      A, (RAM_CC)
    AND     3
    LD      B, A
    LD      A, (RAM_DD+0CH)
    OR      A
    LD      A, (RAM_VV+4)
    JR      Z, SUB_B46B
    LD      A, (RAM_VV+9)

SUB_B46B:
    CP      B
    JR      Z, SUB_B471

SUB_B46E:
    INC     A
    JR      SUB_B473

SUB_B471:
    INC     (HL)

SUB_B472:
    XOR     A

SUB_B473:
    LD      B, A
    LD      A, (RAM_DD+0CH)
    OR      A
    LD      HL,  RAM_VV+4
    JR      Z, SUB_B480
    LD      HL,  RAM_VV+9

SUB_B480:
    LD      (HL), B
RET 

SUB_B482:
    LD      A, 2
    LD      (HL), A
    JR      SUB_B472

SUB_B487:
    LD      A, (RAM_VV+5)
    CP      2
    JR      NC, SUB_B492
    INC     A
    LD      (RAM_VV+5), A

SUB_B492:
    LD      A, (RAM_CC)
    AND     3
    LD      B, A
    LD      A, 0DH
    SUB     B
    LD      (HL), A
    JR      SUB_B472

SUB_B49E:
    CALL    SUB_B034
    CP      2
	RET      C
    JR      Z, SUB_B4B5
    CP      3
    JR      Z, SUB_B4F4
    CP      4
    JP      Z, SUB_B53C
    CP      5
    JP      Z, SUB_B59F
RET 

SUB_B4B5:
    LD      A, (RAM_UU+3)
    OR      A
    JR      Z, SUB_B4D9
    LD      IX,  RAM_TT+0AH
    LD      A, (IX+2)
    OR      A
	RET      NZ
    LD      B, 4

SUB_B4C6:
    LD      (IX+2), 1
    LD      DE, 0AH
    ADD     IX, DE
    DJNZ    SUB_B4C6
    XOR     A
    LD      (RAM_UU+2), A
    LD      A, 3
    JR      SUB_B4EA

SUB_B4D9:
    LD      A, (RAM_SS+0AH)
    OR      A
    JR      Z, SUB_B4E3
    LD      A, 1
    JR      SUB_B4EA

SUB_B4E3:
    LD      A, (RAM_SS+9)
    OR      A
	RET      NZ
    LD      A, 2

SUB_B4EA:
    LD      (RAM_DD+0DH), A
    LD      IX, PO_EVIL_OTTO_LG
    JP      PUTOBJ

SUB_B4F4:
    LD      A, (RAM_UU+4)
    OR      A
    JR      Z, SUB_B50A
    LD      A, (RAM_DD+0DH)
    OR      A
	RET      Z
    XOR     A
    LD      (RAM_DD+0DH), A
    LD      IX, PO_POWER_PLANT
    JP      PUTOBJ

SUB_B50A:
    LD      A, (RAM_DD+9)
    OR      A
    JR      NZ, SUB_B524
    LD      A, (RAM_DD+0DH)
    INC     A
    CP      4
    JR      C, SUB_B51A
    LD      A, 1

SUB_B51A:
    LD      (RAM_DD+0DH), A
    LD      IX, PO_POWER_PLANT
    CALL    PUTOBJ

SUB_B524:
    LD      A, (RAM_DD+7)
    OR      A
	RET      NZ
    LD      A, (RAM_EE)
    INC     A
    CP      8
    JR      C, SUB_B532
    XOR     A

SUB_B532:
    LD      (RAM_EE), A
    LD      IX, PO_BRAIN
    JP      PUTOBJ

SUB_B53C:
    LD      A, (RAM_DD+0AH)
    OR      A
    JR      NZ, SUB_B55B
    LD      A, (RAM_UU+4)
    OR      A
    JR      NZ, SUB_B55B
    LD      A, (RAM_EE)
    INC     A
    CP      6
    JR      C, SUB_B551
    XOR     A

SUB_B551:
    LD      (RAM_EE), A
    LD      IX, PO_DATA_9D40
    CALL    PUTOBJ

SUB_B55B:
    LD      A, (RAM_DD+8)
    OR      A
	RET      NZ
    LD      A, (RAM_DD+7)
    OR      A
	RET      NZ
    LD      A, (RAM_UU+4)
    OR      A
    LD      A, (RAM_EE+6)
    JR      NZ, SUB_B57E

SUB_B56E:
    INC     A
    CP      0AH
    JR      C, SUB_B574
    XOR     A

SUB_B574:
    LD      (RAM_EE+6), A
    LD      IX, PO_FACTORY
    JP      PUTOBJ

SUB_B57E:
    CP      4
    JR      NZ, SUB_B584
    LD      A, 0AH

SUB_B584:
    CP      0AH
    JR      C, SUB_B56E
    LD      (RAM_EE+6), A
    LD      IX, PO_FACTORY
    CP      0CH
    CALL    C, PUTOBJ
    LD      A, (RAM_EE+6)
    CP      0CH
	RET      NC
    INC     A
    LD      (RAM_EE+6), A
RET 

SUB_B59F:
    LD      A, (RAM_UU+4)
    OR      A
    JR      Z, SUB_B5B3
    LD      A, (RAM_UU+8)
    CP      7
    CALL    NZ, SUB_B67E
    LD      A, (RAM_EE)
    CP      1
RET      Z

SUB_B5B3:
    LD      A, (RAM_DD+0AH)
    OR      A
    JR      NZ, SUB_B5CC
    LD      A, (RAM_EE)
    INC     A
    CP      4
    JR      C, SUB_B5C2
    XOR     A

SUB_B5C2:
    LD      (RAM_EE), A
    LD      IX, PO_DATA_9E1F
    CALL    PUTOBJ

SUB_B5CC:
    LD      A, (RAM_DD+8)
    OR      A
    JR      NZ, SUB_B5EB
    LD      A, (RAM_DD+7)
    OR      A
    JR      NZ, SUB_B5EB
    LD      A, (RAM_EE+6)
    INC     A
    CP      4
    JR      C, SUB_B5E1
    XOR     A

SUB_B5E1:
    LD      (RAM_EE+6), A
    LD      IX, PO_ROBOTS
    CALL    PUTOBJ

SUB_B5EB:
    LD      A, (RAM_DD+9)
    OR      A
    JR      NZ, SUB_B61C
    LD      A, (RAM_EE+0CH)
    INC     A
    CP      6
    JR      C, SUB_B5FA
    XOR     A

SUB_B5FA:
    LD      (RAM_EE+0CH), A
    LD      IX, PO_DATA_9E69
    PUSH    AF
    CALL    PUTOBJ
    POP     AF
    LD      HL, DATA_B72A
    LD      E, A
    LD      D, 0
    ADD     HL, DE
    LD      A, (HL)
    LD      HL, WORK_BUFFER
    LD      (HL), A
    LD      DE, 1DH
    LD      A, 4
    LD      IY, 1
    RST     8

SUB_B61C:
    LD      A, (RAM_UU+7)
    CALL    TEST_SIGNAL
    JP      Z, SUB_B6A3
    LD      IX, DATA_9E8C
    LD      B, 14H

SUB_B62B:
    LD      L, (IX+2)
    LD      H, (IX+3)
    LD      A, (HL)
    CP      37H
    JR      Z, SUB_B63E
    LD      DE, 6
    ADD     IX, DE
    DJNZ    SUB_B62B
RET 

SUB_B63E:
    LD      (RAM_VV), IX
    LD      (RAM_VV+2), HL
    LD      HL, PO_DATA_A11A
    XOR     A
    CALL    ACTIVATE
    LD      HL,  RAM_UU+8
    XOR     A
    LD      (HL), A
    INC     HL
    LD      (HL), 78H
    INC     HL
    LD      (HL), A
    INC     HL
    LD      (HL), 68H
    INC     HL
    LD      (HL), A
    LD      BC, 0F0DH
    LD      HL, WORK_BUFFER
    CALL    SUB_B730
    JR      NZ, SUB_B678
    INC     B
    CALL    SUB_B730
    JR      NZ, SUB_B678
    INC     C
    CALL    SUB_B730
    JR      NZ, SUB_B678
    DEC     B
    CALL    SUB_B730
    JR      Z, SUB_B69C

SUB_B678:
    LD      A, 7
    LD      (RAM_UU+8), A
RET 

SUB_B67E:
    LD      HL, (RAM_VV+2)
    LD      (HL), 38H
    INC     HL
    LD      (HL), 78H
    INC     HL
    LD      (HL), 0
    INC     HL
    LD      (HL), 64H
    INC     HL
    LD      (HL), 0
    LD      HL, RAM_NN
    LD      (HL), 0FFH
    CALL    SUB_C8F5
    LD      HL,  RAM_UU+8
    LD      (HL), 7

SUB_B69C:
    LD      IX, PO_DATA_A11A
    JP      PUTOBJ

SUB_B6A3:
    LD      A, (RAM_CC)
    AND     3
    JR      NZ, SUB_B6B7
    LD      A, (RAM_SS+9)
    OR      A
    JR      Z, SUB_B6BD
    LD      A, (RAM_DD+9)
    OR      A
    JR      Z, SUB_B6C7
RET 

SUB_B6B7:
    LD      A, (RAM_SS+9)
    OR      A
    JR      Z, SUB_B6C2

SUB_B6BD:
    LD      A, (RAM_DD+7)
    OR      A
	RET      NZ

SUB_B6C2:
    LD      A, (RAM_DD+8)
    OR      A
	RET      NZ

SUB_B6C7:
    LD      HL,  RAM_UU+8
    LD      A, (HL)
    INC     A
    CP      8
	RET      NC
    CP      7
    JR      NZ, SUB_B6F9
    LD      (HL), A
    LD      IX, PO_DATA_A11A
    CALL    PUTOBJ
    LD      HL,  RAM_UU+8
    LD      (HL), 0
    LD      DE, (RAM_VV+2)
    LD      BC, 6
    PUSH    HL
    LDIR
    LD      IX, (RAM_VV)
    CALL    PUTOBJ
    POP     HL
    LD      (HL), 7
    LD      HL,  RAM_SS+9
    INC     (HL)
RET 

SUB_B6F9:
    LD      (HL), A
    LD      IX, PO_DATA_A11A
    CALL    PUTOBJ
    LD      A, (RAM_UU+8)
    SLA     A
    LD      DE, 7C68H
    LD      H, 8
    LD      L, A
    ADD     HL, DE
    PUSH    DE
    PUSH    HL
    CALL    SUB_B877
    PUSH    DE
    PUSH    HL
    CALL    SUB_C385
	RET      Z
    CALL    SUB_B67E
    LD      A, (RAM_UU)
    OR      A
	RET      NZ
    LD      A, (RAM_SS+0AH)
    OR      A
	RET      NZ
    INC     A
    LD      (RAM_SS+0AH), A
RET 

DATA_B72A:
	DB  21H
    DB  31H
    DB 0E1H
    DB  31H
    DB  21H
    DB 0C1H

SUB_B730:
    PUSH    BC
    PUSH    HL
    CALL    SUB_B744
    POP     HL
    PUSH    HL
    LD      IY, 1
    LD      A, 2
    RST     10H
    POP     HL
    POP     BC
    LD      A, (HL)
    CP      17H
RET 

SUB_B744:
    LD      L, C
    LD      H, 0
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    LD      E, B
    LD      D, 0
    ADD     HL, DE
    EX      DE, HL
RET 

SUB_B752:
    CALL    SUB_B034
    CP      2
    JP      C, SUB_C811
    JR      NZ, SUB_B76D
    CALL    SUB_C846
    LD      HL, PATTERN_DATA_01
    LD      DE, 5C0H
    CALL    SUB_A312
    LD      HL, DATA_B809
    JR      SUB_B7CD

SUB_B76D:
    CP      3
    JR      NZ, SUB_B782
    CALL    SUB_C87C
    LD      HL, PATTERN_DATA_02
    LD      DE, 5C0H
    CALL    SUB_A312
    LD      HL, DATA_B813
    JR      SUB_B7CD

SUB_B782:
    CP      4
    JR      NZ, SUB_B7A9
    CALL    SUB_C834
    LD      HL, PATTERN_DATA_03
    LD      DE, 5C0H
    CALL    SUB_A312
    LD      HL, PATTERN_DATA_03
    LD      DE, 600H
    CALL    SUB_A312
    LD      HL, PATTERN_DATA_04
    LD      DE, 640H
    CALL    SUB_A312
    LD      HL, DATA_B829
    JR      SUB_B7CD

SUB_B7A9:
    CP      5
    JP      NZ, SUB_C811
    CALL    SUB_C7FF
    LD      A, 1
    LD      HL, 0F0H
    CALL    REQUEST_SIGNAL
    LD      (RAM_UU+7), A
    LD      HL,  RAM_UU+8
    LD      (HL), 7
    LD      HL, PATTERN_DATA_05
    LD      DE, 5C0H
    CALL    SUB_A312
    LD      HL, DATA_B846

SUB_B7CD:
    PUSH    HL
    LD      HL, (RAM_EXTRA+6)
    LD      DE, 17H
    ADD     HL, DE
    EX      DE, HL
    POP     HL
    CALL    SUB_A312
    PUSH    HL

SUB_B7DB:
    POP     HL
    LD      A, (HL)
    OR      A
	RET      Z
    LD      E, A
    INC     HL
    LD      D, (HL)
    INC     HL
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    INC     HL
    PUSH    HL
    LD      L, C
    LD      H, B
    LD      (HL), 0
    INC     HL
    LD      (HL), E
    INC     HL
    LD      (HL), 0
    INC     HL
    LD      (HL), D
    INC     HL
    LD      (HL), 0
    POP     HL
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    INC     HL
    PUSH    HL
    EX      DE, HL
    PUSH    HL
    XOR     A
    CALL    ACTIVATE
    POP     IX
    CALL    PUTOBJ
    JR      SUB_B7DB

DATA_B809:
	DB    4
    DB 0A1H
    DB    0
    DB  70H
    DB  40H
    DB 0A8H
    DB  70H
    DB  18H
    DB  9CH
    DB    0
DATA_B813:
	DB  87H
    DB  81H
    DB 0B1H
    DB  51H
    DB 0D1H
    DB 0D1H
    DB 0F1H
    DB 0F1H
    DB    0
    DB  70H
    DB  40H
    DB 0A8H
    DB  70H
    DB  73H
    DB  9CH
    DB  68H
    DB  58H
    DB 0AEH
    DB  70H
    DB 0BEH
    DB  9CH
    DB    0
DATA_B829:
	DB  88H
    DB 0F1H
    DB 0E1H
    DB  67H
    DB  67H
    DB  71H
    DB  31H
    DB  51H
    DB  65H
    DB    0
    DB  68H
    DB  40H
    DB 0A8H
    DB  70H
    DB  19H
    DB  9DH
    DB  68H
    DB  40H
    DB 0AEH
    DB  70H
    DB  40H
    DB  9DH
    DB  78H
    DB  50H
    DB 0B4H
    DB  70H
    DB 0ABH
    DB  9DH
    DB    0
DATA_B846:
	DB  87H
    DB 0E1H
    DB 0D1H
    DB 0D1H
    DB  61H
    DB  71H
    DB  71H
    DB  21H
    DB    0
    DB  68H
    DB  40H
    DB 0A8H
    DB  70H
    DB 0F8H
    DB  9DH
    DB  70H
    DB  40H
    DB 0AEH
    DB  70H
    DB  1FH
    DB  9EH
    DB  78H
    DB  58H
    DB 0B4H
    DB  70H
    DB  46H
    DB  9EH
    DB  88H
    DB  58H
    DB 0BAH
    DB  70H
    DB  69H
    DB  9EH
    DB    0

SUB_B868:
    JP      SUB_B971
SUB_B86B:
    JP      SUB_BED6
SUB_B86E:
    JP      SUB_C10F
SUB_B871:
    JP      SUB_B909
SUB_B874:
    JP      SUB_BF9D
SUB_B877:
    JP      SUB_BF8C
SUB_B87A:
    JP      SUB_BF2D

SUB_B87D:
    PUSH    HL
    LD      A, (RAM_SS+0AH)
    OR      A
    JR      NZ, SUB_B8AF
    LD      HL,  RAM_DD+1
    LD      D, (HL)
    INC     HL
    INC     HL
    LD      E, (HL)
    LD      HL, 300H
    ADD     HL, DE
    EX      DE, HL
    LD      HL, 0A10H
    ADD     HL, DE
    LD      A, B
    CP      D
    JR      C, SUB_B8AF
    CP      H
    JR      NC, SUB_B8AF
    LD      A, C
    CP      E
    JR      C, SUB_B8AF
    CP      L
    JR      NC, SUB_B8AF
    POP     HL
    LD      A, (RAM_UU)
    OR      A
RET      NZ
    LD      A, 1
    LD      (RAM_SS+0AH), A
    OR      A
RET 

SUB_B8AF:
    POP     HL
    XOR     A
RET 

SUB_B8B2:
    PUSH    HL
    LD      IX,  RAM_SS+11H
    LD      A, 6

SUB_B8B9:
    PUSH    AF
    LD      A, (IX+2)
    OR      A
    JR      Z, SUB_B8FE
    CALL    SUB_B909
    LD      A, B
    CP      D
    JR      C, SUB_B8FE
    CP      H
    JR      NC, SUB_B8FE
    LD      A, C
    CP      E
    JR      C, SUB_B8FE
    CP      L
    JR      NC, SUB_B8FE
    POP     AF
    POP     HL
    LD      A, (IX+4)
    OR      A
	RET      Z
    PUSH    AF
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IX
    CP      4
    JR      Z, SUB_B8E7
    LD      E, 2
    CALL    SUB_A180

SUB_B8E7:
    CALL    SUB_C8F5
    POP     IX
    POP     HL
    POP     DE
    POP     BC
    POP     AF
    DEC     A
    LD      (IX+4), A
    OR      A
RET      NZ
    INC     A
    LD      (RAM_UU+3), A
    LD      A, 1
    OR      A
RET 

SUB_B8FE:
    POP     AF
    LD      DE, 0AH
    ADD     IX, DE
    DEC     A
    JR      NZ, SUB_B8B9
    POP     HL
RET 

SUB_B909:
    LD      A, (IX+1)
    ADD     A, 2
    LD      D, A
    ADD     A, 0CH
    LD      H, A
    LD      A, (IX+0)
    ADD     A, 2
    LD      E, A
    ADD     A, 0CH
    LD      L, A
RET 

SUB_B91C:
    PUSH    HL
    PUSH    DE
    PUSH    BC
    PUSH    IX
    LD      A, E
    CP      0DH
    JR      NC, SUB_B961
    RST     18H
    LD      HL, WORK_BUFFER
    CALL    SUB_BFDB
    CP      0B8H
    JR      C, SUB_B961
    LD      A, (RAM_UU+4)
    OR      A
    JR      NZ, SUB_B941
    CALL    SUB_A168
    CP      2
    LD      E, 0AH
    CALL    NZ, SUB_A180

SUB_B941:
    CALL    SUB_C8CE
    CALL    SUB_A168
    CP      3
    JR      C, SUB_B961
    JR      Z, SUB_B957
    CP      4
    JR      Z, SUB_B967
    CP      5
    JR      Z, SUB_B95C
    JR      SUB_B961

SUB_B957:
    LD      A, 1
    LD      (RAM_UU+5), A

SUB_B95C:
    LD      A, 1

SUB_B95E:
    LD      (RAM_UU+4), A

SUB_B961:
    POP     IX
    POP     BC
    POP     DE
    POP     HL
RET 

SUB_B967:
    XOR     A
    LD      (RAM_UU+2), A
    INC     A
    LD      (RAM_UU+6), A
    JR      SUB_B95E

SUB_B971:
    INC     C
    PUSH    HL
    PUSH    DE
    PUSH    BC
    CALL    SUB_B91C
    CALL    SUB_B87D
    JR      NZ, SUB_B9AE
    CALL    SUB_B8B2
    JR      NZ, SUB_B9AE
    LD      (RAM_SS), HL
    INC     HL
    INC     HL
    LD      A, (HL)
    LD      (RAM_SS+2), A
    LD      A, B
    CP      12H
    JR      C, SUB_B9AE
    CP      0EEH
    JR      NC, SUB_B9AE
    LD      A, C
    CP      12H
    JR      C, SUB_B9AE
    CP      0B6H
    JR      C, SUB_B9C8
    JR      SUB_B9AE

SUB_B99F:
    LD      A, 2
    LD      IY, 1
    RST     8
    LD      E, 0
    CALL    SUB_A180

SUB_B9AB:
    CALL    SUB_C8CE

SUB_B9AE:
    POP     BC
    POP     DE
    POP     HL
    PUSH    HL
    PUSH    DE
    PUSH    BC
    XOR     A
    LD      (HL), A
    INC     HL
    LD      (HL), A
    INC     HL
    LD      (HL), A
    DEC     HL
    DEC     HL
    LD      IY, 1
    LD      A, 0
    RST     8
    POP     BC
    POP     DE
    POP     HL
    XOR     A
RET 

SUB_B9C8:
    RST     18H
    CALL    SUB_BFCD
    LD      HL, WORK_BUFFER
    PUSH    DE
    PUSH    HL
    LD      IY, 1
    LD      A, 2
    RST     10H
    POP     HL
    POP     DE
    LD      A, (HL)
    CP      17H
    JR      Z, SUB_B9E3
    CP      16H
    JR      NZ, SUB_B9EA

SUB_B9E3:
    POP     BC
    POP     DE
    POP     HL
    LD      A, 1
    OR      A
RET 

SUB_B9EA:
    CP      30H
    JR      C, SUB_B9F2
    CP      32H
    JR      C, SUB_B9AB

SUB_B9F2:
    PUSH    AF
    CALL    SUB_A168
    CP      8
    JR      NZ, SUB_B9FD
    POP     AF
    JR      SUB_BA7A

SUB_B9FD:
    POP     AF
    CP      1EH
    JR      NZ, SUB_BA06
    LD      (HL), 17H
    JR      SUB_B99F

SUB_BA06:
    CP      18H
    JR      NZ, SUB_BA1A
    POP     BC
    PUSH    BC
    LD      A, B
    AND     7
    CP      4
    LD      (HL), 1AH
    JR      C, SUB_B99F
    LD      (HL), 19H
    JP      SUB_B99F

SUB_BA1A:
    CP      19H
    JR      NZ, SUB_BA2C
    POP     BC
    PUSH    BC
    LD      A, B
    AND     7
    CP      4
    LD      (HL), 17H
    JP      C, SUB_B99F
    JR      SUB_B9E3

SUB_BA2C:
    CP      1AH
    JR      NZ, SUB_BA3F
    POP     BC
    PUSH    BC
    LD      A, B
    AND     7
    CP      4
    LD      (HL), 17H
    JP      NC, SUB_B99F
    JP      SUB_B9E3

SUB_BA3F:
    CP      1BH
    JR      NZ, SUB_BA54
    POP     BC
    PUSH    BC
    LD      A, C
    AND     7
    CP      4
    LD      (HL), 1CH
    JP      C, SUB_B99F
    LD      (HL), 1DH
    JP      SUB_B99F

SUB_BA54:
    CP      1DH
    JR      NZ, SUB_BA67
    POP     BC
    PUSH    BC
    LD      A, C
    AND     7
    CP      4
    LD      (HL), 17H
    JP      C, SUB_B99F
    JP      SUB_B9E3

SUB_BA67:
    CP      1CH
    JR      NZ, SUB_BA7A
    POP     BC
    PUSH    BC
    LD      A, C
    AND     7
    CP      4
    LD      (HL), 17H
    JP      NC, SUB_B99F
    JP      SUB_B9E3

SUB_BA7A:
    CP      38H
    JR      C, SUB_BA8F
    CP      0B2H
    JR      NC, SUB_BA8F
    POP     DE
    PUSH    DE
    POP     HL
    PUSH    HL
    CALL    SUB_BED6
    JP      Z, SUB_B9AE
    JP      SUB_B9E3

SUB_BA8F:
    CP      18H
    JR      NZ, SUB_BA96
    XOR     A
    JR      SUB_BAB0

SUB_BA96:
    CP      1BH
    JR      NZ, SUB_BA9E
    LD      A, 1
    JR      SUB_BAB0

SUB_BA9E:
    CP      1EH
    JR      NZ, SUB_BAA6
    LD      A, 2
    JR      SUB_BAB0

SUB_BAA6:
    CP      20H
    JR      C, SUB_BAE0
    CP      2FH
    JR      NC, SUB_BAE0
    ADD     A, 0E3H

SUB_BAB0:
    PUSH    HL
    PUSH    DE
    LD      E, A
    SLA     E
    SLA     E
    SLA     E
    LD      A, (RAM_SS+2)
    LD      D, 0D0H
    SUB     D
    SRL     A
    SRL     A
    ADD     A, E
    LD      E, A
    LD      D, 0
    LD      HL, OFF_BFEF
    ADD     HL, DE
    ADD     HL, DE
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    PUSH    DE
    POP     IX
    POP     DE
    POP     HL
    POP     BC
    PUSH    BC
    LD      A, B
    AND     7
    LD      B, A
    LD      A, C
    AND     7
    LD      C, A
    JP      (IX)

SUB_BAE0:
    JP      SUB_B9AE

SUB_BAE3:
    LD      A, B
    CP      4
    JP      NC, SUB_B9E3

SUB_BAE9:
    LD      A, C
    CP      3
    JP      C, SUB_B9E3
    JP      SUB_BDDD

SUB_BAF2:
    LD      A, C
    CP      2
    JP      C, SUB_B9E3
    CP      6
    JP      SUB_BDE5

SUB_BAFD:
    LD      A, C
    CP      2
    JP      C, SUB_B9E3
    CP      6
    JP      SUB_BDF2

SUB_BB08:
    LD      A, B
    CP      4
    JP      C, SUB_B9E3

SUB_BB0E:
    LD      A, C
    CP      3
    JP      C, SUB_B9E3
    JP      SUB_BDEA

SUB_BB17:
    LD      A, B
    CP      4
    JP      C, SUB_B9E3
    JP      SUB_BE08

SUB_BB20:
    LD      A, B
    CP      4
    JP      SUB_BBF1

SUB_BB26:
    LD      A, B
    CP      4
    JP      C, SUB_B9E3
    JP      SUB_BDF7

SUB_BB2F:
    LD      A, B
    CP      4
    JP      SUB_BC0F

SUB_BB35:
    LD      A, B
    CP      5
    JP      NC, SUB_B9E3
    LD      A, C
    CP      5
    JR      NC, SUB_BB4E
    CP      3
    JP      C, SUB_B9E3
    JP      SUB_BE5D

SUB_BB48:
    LD      A, B
    CP      5
    JP      C, SUB_B9E3

SUB_BB4E:
    LD      A, C
    CP      3
    JP      C, SUB_B9E3
    JP      Z, SUB_BE5D
    JP      SUB_BE6E

SUB_BB5A:
    LD      A, B
    CP      5
    JP      C, SUB_B9E3
    LD      A, C
    CP      5
    JR      NC, SUB_BB73
    CP      3
    JP      C, SUB_B9E3
    JP      SUB_BE3B

SUB_BB6D:
    LD      A, B
    CP      5
    JP      NC, SUB_B9E3

SUB_BB73:
    LD      A, C
    CP      3
    JP      C, SUB_B9E3
    JP      Z, SUB_BE3B
    JP      SUB_BE4C

SUB_BB7F:
    LD      A, B
    CP      5
    JP      NC, SUB_B9E3
    LD      A, C
    CP      3
    JR      C, SUB_BB98
    CP      6
    JP      NC, SUB_B9E3
    JP      SUB_BEA1

SUB_BB92:
    LD      A, B
    CP      3
    JP      C, SUB_B9E3

SUB_BB98:
    LD      A, C
    CP      4
    JP      Z, SUB_BEA1
    CP      5
    JP      NC, SUB_B9E3
    JP      SUB_BEB2

SUB_BBA6:
    LD      A, B
    CP      3
    JP      C, SUB_B9E3
    LD      A, C
    CP      3
    JR      C, SUB_BBBC
    CP      5
    JP      SUB_BD3B

SUB_BBB6:
    LD      A, B
    CP      5
    JP      NC, SUB_B9E3

SUB_BBBC:
    LD      A, C
    CP      4
    JP      Z, SUB_BE7F
    CP      5
    JP      SUB_BC8A

SUB_BBC7:
    LD      A, C
    CP      4
    JP      C, SUB_B9E3
    JP      SUB_BE2A

SUB_BBD0:
    LD      A, C
    CP      4
    JP      C, SUB_B9E3
    JP      SUB_BE19

SUB_BBD9:
    LD      A, B
    CP      2
    JP      C, SUB_B9E3
    CP      6
    JR      SUB_BBF1

SUB_BBE3:
    LD      A, C
    CP      5
    JP      NC, SUB_B9E3

SUB_BBE9:
    LD      A, B
    CP      3
    JP      C, SUB_B9E3
    CP      5

SUB_BBF1:
    JP      NC, SUB_B9E3
    JP      SUB_BE08

SUB_BBF7:
    LD      A, B
    CP      2
    JP      C, SUB_B9E3
    CP      6
    JR      SUB_BC0F

SUB_BC01:
    LD      A, C
    CP      4
    JP      C, SUB_B9E3

SUB_BC07:
    LD      A, B
    CP      3
    JP      C, SUB_B9E3
    CP      5

SUB_BC0F:
    JP      NC, SUB_B9E3
    JP      SUB_BDF7

SUB_BC15:
    LD      A, C
    CP      5
    JP      NC, SUB_B9E3
    LD      A, B
    CP      5
    JR      NC, SUB_BC2B
    CP      3
    JP      SUB_BD0D

SUB_BC25:
    LD      A, C
    CP      3
    JP      C, SUB_B9E3

SUB_BC2B:
    LD      A, B
    CP      3
    JP      C, SUB_B9E3
    JP      Z, SUB_BE6E
    JP      SUB_BE5D

SUB_BC37:
    LD      A, C
    CP      5
    JP      NC, SUB_B9E3
    LD      A, B
    CP      3
    JR      C, SUB_BC4D
    CP      5
    JP      SUB_BD32

SUB_BC47:
    LD      A, C
    CP      3
    JP      C, SUB_B9E3

SUB_BC4D:
    LD      A, B
    CP      4
    JP      Z, SUB_BE4C
    CP      5
    JP      NC, SUB_B9E3
    JP      SUB_BE3B

SUB_BC5B:
    LD      A, C
    CP      3
    JP      C, SUB_B9E3
    LD      A, B
    CP      5
    JR      NC, SUB_BC71
    CP      3
    JP      SUB_BD7C

SUB_BC6B:
    LD      A, C
    CP      5
    JP      NC, SUB_B9E3

SUB_BC71:
    LD      A, B
    CP      3
    JP      C, SUB_B9E3
    JP      Z, SUB_BEB2
    JP      SUB_BEA1

SUB_BC7D:
    LD      A, C
    CP      3
    JP      C, SUB_B9E3
    LD      A, B
    CP      3
    JR      C, SUB_BC96
    CP      5

SUB_BC8A:
    JP      NC, SUB_B9E3
    JP      SUB_BE90

SUB_BC90:
    LD      A, C
    CP      5
    JP      NC, SUB_B9E3

SUB_BC96:
    LD      A, B
    CP      4
    JP      Z, SUB_BE90
    CP      5
    JP      SUB_BD3B

SUB_BCA1:
    LD      A, C
    CP      4
    JP      C, SUB_BE5D
    JP      SUB_BE6E

SUB_BCAA:
    LD      A, C
    CP      4
    JP      C, SUB_BE3B
    JP      SUB_BE4C

SUB_BCB3:
    LD      A, C
    CP      4
    JP      C, SUB_BEB2
    JP      SUB_BEA1

SUB_BCBC:
    LD      A, C
    CP      4
    JP      C, SUB_BE90
    JP      SUB_BE7F

SUB_BCC5:
    LD      A, B
    CP      6
    JP      NC, SUB_B9E3
    CP      3
    JP      C, SUB_BCD6
    LD      A, C
    CP      4
    JP      C, SUB_BE5D

SUB_BCD6:
    LD      A, B
    CP      5
    JP      NC, SUB_B9E3
    LD      A, C
    CP      3
    JP      C, SUB_B9E3
    CP      6
    JP      NC, SUB_B9E3
    JP      SUB_BE6E

SUB_BCEA:
    LD      A, B
    CP      5
    JR      SUB_BD32

SUB_BCEF:
    LD      A, C
    CP      5
    JP      NC, SUB_B9E3
    JP      SUB_BEA1

SUB_BCF8:
    LD      A, B
    CP      3
    JP      C, SUB_B9E3
    JP      SUB_BE08

SUB_BD01:
    LD      A, B
    CP      3
    JP      C, SUB_B9E3
    JP      SUB_BDF7

SUB_BD0A:
    LD      A, B
    CP      3

SUB_BD0D:
    JP      C, SUB_B9E3
    JP      SUB_BE6E

SUB_BD13:
    LD      A, B
    CP      2
    JP      C, SUB_B9E3
    CP      5
    JP      NC, SUB_BD24
    LD      A, C
    CP      4
    JP      C, SUB_BE3B

SUB_BD24:
    LD      A, B
    CP      3
    JP      C, SUB_B9E3
    LD      A, C
    CP      3
    JP      C, SUB_B9E3
    CP      6

SUB_BD32:
    JP      NC, SUB_B9E3
    JP      SUB_BE4C

SUB_BD38:
    LD      A, C
    CP      5

SUB_BD3B:
    JP      NC, SUB_B9E3
    JP      SUB_BE7F

SUB_BD41:
    LD      A, C
    CP      3
    JP      NC, SUB_B9E3
    JP      SUB_BE5D

SUB_BD4A:
    LD      A, B
    CP      6
    JP      NC, SUB_B9E3
    CP      3
    JP      C, SUB_BD5B
    LD      A, C
    CP      4
    JP      NC, SUB_BEA1

SUB_BD5B:
    LD      A, B
    CP      5
    JP      NC, SUB_B9E3
    LD      A, C
    CP      5
    JP      NC, SUB_B9E3
    CP      2
    JR      SUB_BD7C

SUB_BD6B:
    LD      A, B
    CP      5
    JR      SUB_BDA1

SUB_BD70:
    LD      A, C
    CP      3
    JP      C, SUB_B9E3
    JP      SUB_BE3B

SUB_BD79:
    LD      A, B
    CP      3

SUB_BD7C:
    JP      C, SUB_B9E3
    JP      SUB_BEB2

SUB_BD82:
    LD      A, B
    CP      2
    JP      C, SUB_B9E3
    CP      5
    JP      NC, SUB_BD93
    LD      A, C
    CP      4
    JP      NC, SUB_BE7F

SUB_BD93:
    LD      A, B
    CP      3
    JP      C, SUB_B9E3
    LD      A, C
    CP      5
    JP      NC, SUB_B9E3
    CP      2

SUB_BDA1:
    JP      C, SUB_B9E3
    JP      SUB_BE90

SUB_BDA7:
    LD      A, C
    CP      3
    JP      C, SUB_B9E3

SUB_BDAD:
    LD      HL, (RAM_SS)
    DEC     (HL)
    DEC     (HL)
    JR      SUB_BE2A

SUB_BDB4:
    LD      A, C
    CP      3
    JP      C, SUB_B9E3

SUB_BDBA:
    LD      HL, (RAM_SS)
    DEC     (HL)
    DEC     (HL)
    JR      SUB_BE19

SUB_BDC1:
    LD      A, B
    CP      5
    JP      NC, SUB_B9E3

SUB_BDC7:
    LD      HL, (RAM_SS)
    INC     HL
    INC     (HL)
    INC     (HL)
    JR      SUB_BE08

SUB_BDCF:
    LD      A, B
    CP      5
    JP      NC, SUB_B9E3

SUB_BDD5:
    LD      HL, (RAM_SS)
    INC     HL
    INC     (HL)
    INC     (HL)
    JR      SUB_BDF7

SUB_BDDD:
    LD      A, C
    CP      5
    JR      SUB_BDE5

SUB_BDE2:
    LD      A, C
    CP      4

SUB_BDE5:
    JP      NC, SUB_B9E3
    JR      SUB_BE2A

SUB_BDEA:
    LD      A, C
    CP      5
    JR      SUB_BDF2

SUB_BDEF:
    LD      A, C
    CP      4

SUB_BDF2:
    JP      NC, SUB_B9E3
    JR      SUB_BE19

SUB_BDF7:
    LD      HL, (RAM_SS)
    LD      A, (HL)
    ADD     A, 9
    LD      (HL), A
    INC     HL
    INC     (HL)
    INC     (HL)
    INC     (HL)
    INC     HL
    LD      (HL), 0D8H
    JP      SUB_BEC1

SUB_BE08:
    LD      HL, (RAM_SS)
    LD      A, (HL)
    ADD     A, 0F7H
    LD      (HL), A
    INC     HL
    INC     (HL)
    INC     (HL)
    INC     (HL)
    INC     HL
    LD      (HL), 0DCH
    JP      SUB_BEC1

SUB_BE19:
    LD      HL, (RAM_SS)
    DEC     (HL)
    DEC     (HL)
    DEC     (HL)
    INC     HL
    LD      A, (HL)
    ADD     A, 9
    LD      (HL), A
    INC     HL
    LD      (HL), 0D0H
    JP      SUB_BEC1

SUB_BE2A:
    LD      HL, (RAM_SS)
    DEC     (HL)
    DEC     (HL)
    DEC     (HL)
    INC     HL
    LD      A, (HL)
    ADD     A, 0F7H
    LD      (HL), A
    INC     HL
    LD      (HL), 0D4H
    JP      SUB_BEC1

SUB_BE3B:
    LD      HL, (RAM_SS)
    LD      A, (HL)
    ADD     A, 0FBH
    LD      (HL), A
    INC     HL
    LD      A, (HL)
    ADD     A, 0AH
    LD      (HL), A
    INC     HL
    LD      (HL), 0E0H
    JR      SUB_BEC1

SUB_BE4C:
    LD      HL, (RAM_SS)
    LD      A, (HL)
    ADD     A, 0F6H
    LD      (HL), A
    INC     HL
    LD      A, (HL)
    ADD     A, 5
    LD      (HL), A
    INC     HL
    LD      (HL), 0ECH
    JR      SUB_BEC1

SUB_BE5D:
    LD      HL, (RAM_SS)
    LD      A, (HL)
    ADD     A, 0FBH
    LD      (HL), A
    INC     HL
    LD      A, (HL)
    ADD     A, 0F6H
    LD      (HL), A
    INC     HL
    LD      (HL), 0E4H
    JR      SUB_BEC1

SUB_BE6E:
    LD      HL, (RAM_SS)
    LD      A, (HL)
    ADD     A, 0F6H
    LD      (HL), A
    INC     HL
    LD      A, (HL)
    ADD     A, 0FBH
    LD      (HL), A
    INC     HL
    LD      (HL), 0E8H
    JR      SUB_BEC1

SUB_BE7F:
    LD      HL, (RAM_SS)
    LD      A, (HL)
    ADD     A, 5
    LD      (HL), A
    INC     HL
    LD      A, (HL)
    ADD     A, 0AH
    LD      (HL), A
    INC     HL
    LD      (HL), 0E8H
    JR      SUB_BEC1

SUB_BE90:
    LD      HL, (RAM_SS)
    LD      A, (HL)
    ADD     A, 0AH
    LD      (HL), A
    INC     HL
    LD      A, (HL)
    ADD     A, 5
    LD      (HL), A
    INC     HL
    LD      (HL), 0E4H
    JR      SUB_BEC1

SUB_BEA1:
    LD      HL, (RAM_SS)
    LD      A, (HL)
    ADD     A, 5
    LD      (HL), A
    INC     HL
    LD      A, (HL)
    ADD     A, 0F6H
    LD      (HL), A
    INC     HL
    LD      (HL), 0ECH
    JR      SUB_BEC1

SUB_BEB2:
    LD      HL, (RAM_SS)
    LD      A, (HL)
    ADD     A, 0AH
    LD      (HL), A
    INC     HL
    LD      A, (HL)
    ADD     A, 0FBH
    LD      (HL), A
    INC     HL
    LD      (HL), 0E0H

SUB_BEC1:
    CALL    SUB_C85D
    DW SOUND_DATA+8AEH
    POP     HL
    PUSH    HL
    PUSH    DE
    PUSH    BC
    LD      IY, 1
    LD      A, 0
    RST     8
    POP     BC
    POP     DE
    POP     HL
    XOR     A
RET 

SUB_BED6:
    LD      A, 14H
    LD      IY, DATA_9E8C

SUB_BEDC:
    PUSH    AF
    PUSH    DE
    PUSH    HL
    PUSH    DE
    PUSH    HL
    LD      L, (IY+2)
    LD      H, (IY+3)
    LD      A, (HL)
    CP      0FFH
    JR      Z, SUB_BEF5
    CP      37H
    JR      C, SUB_BEF5
    POP     HL
    POP     DE
    JP      SUB_BF1D

SUB_BEF5:
    LD      (RAM_EXTRA+0AH), HL
    INC     HL
    LD      D, (HL)
    INC     HL
    INC     HL
    LD      E, (HL)
    PUSH    IY
    POP     HL
    CALL    SUB_BF9D
    PUSH    DE
    PUSH    HL
    CALL    SUB_C385
    JR      Z, SUB_BF1D
    LD      HL, (RAM_EXTRA+0AH)
    LD      A, (HL)
    LD      (RAM_SS+4), A
    PUSH    IY
    POP     IX
    CALL    SUB_BF2D
    POP     HL
    POP     DE
    POP     AF
    XOR     A
RET 

SUB_BF1D:
    LD      DE, 6
    ADD     IY, DE
    POP     HL
    POP     DE
    POP     AF
    DEC     A
    JP      NZ, SUB_BEDC
    LD      A, 1
    OR      A
RET 

SUB_BF2D:
    LD      A, (HL)
    LD      (RAM_SS+4), A
    LD      (HL), 37H
    INC     HL
    INC     HL
    INC     HL
    LD      A, (HL)
    LD      (RAM_SS), HL
    LD      (RAM_SS+2), A
    LD      (HL), 0C0H
    CALL    PUTOBJ
    LD      HL, (RAM_SS)
    LD      A, (RAM_SS+2)
    LD      (HL), A
    DEC     HL
    DEC     HL
    LD      A, (RAM_SS+4)
    CP      26H
    JR      C, SUB_BF5A
    CP      0FFH
    JR      Z, SUB_BF5A
    LD      A, (HL)
    ADD     A, 0FCH
    LD      (HL), A

SUB_BF5A:
    DEC     HL
    LD      (HL), 38H
    LD      HL, RAM_NN
    LD      (HL), 0FFH
    PUSH    BC
    CALL    SUB_C8F5
    LD      HL,  RAM_SS+9
    DEC     (HL)
    LD      E, 5
    CALL    SUB_A180
    LD      HL,  RAM_SS+8
    LD      A, (HL)
    OR      A
    JP      M, SUB_BF8A
    DEC     (HL)
    JR      NZ, SUB_BF8A
    CALL    SUB_C905
    LD      A, (RAM_VV+7)
    CALL    SUB_A189
    LD      A, (RAM_VV+7)
    LD      E, A
    CALL    SUB_A180

SUB_BF8A:
    POP     BC
RET 

SUB_BF8C:
    LD      HL,  RAM_DD+1
    LD      D, (HL)
    INC     HL
    INC     HL
    LD      E, (HL)
    LD      HL, 300H
    ADD     HL, DE
    EX      DE, HL
    LD      HL, 0A10H
    ADD     HL, DE
RET 

SUB_BF9D:
    PUSH    DE
    CP      0FFH
    JR      NZ, SUB_BFA3
    XOR     A

SUB_BFA3:
    LD      E, A
    LD      D, 0
    LD      HL, DATA_C30E
    ADD     HL, DE
    ADD     HL, DE
    LD      D, (HL)
    INC     HL
    LD      E, (HL)
    EX      DE, HL
    LD      DE, 404H
    CP      26H
    JR      C, SUB_BFB9
    LD      DE, 301H

SUB_BFB9:
    PUSH    AF
    XOR     A
    SBC     HL, DE
    POP     AF
    POP     DE
    ADD     HL, DE
    EX      DE, HL
    LD      HL, 80BH
    CP      26H
    JR      C, SUB_BFCB
    LD      HL, 60EH

SUB_BFCB:
    ADD     HL, DE
RET 

SUB_BFCD:
    LD      L, C
    LD      H, 0
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    LD      E, B
    LD      D, 0
    ADD     HL, DE
    EX      DE, HL
RET 

SUB_BFDB:
    PUSH    BC
    PUSH    HL
    CALL    SUB_BFCD
    POP     HL
    PUSH    HL
    LD      IY, 1
    LD      A, 2
    RST     10H
    POP     HL
    POP     BC
    LD      A, (HL)
    CP      17H
RET 

OFF_BFEF:
	DW SUB_BAF2
    DW SUB_BAFD
    DW SUB_BE08
    DW SUB_BDF7
    DW SUB_BB4E
    DW SUB_BB73
    DW SUB_BB98
    DW SUB_BBBC
    DW SUB_BE2A
    DW SUB_BE19
    DW SUB_BBD9
    DW SUB_BBF7
    DW SUB_BC2B
    DW SUB_BC4D
    DW SUB_BC71
    DW SUB_BC96
    DW SUB_BE2A
    DW SUB_BE19
    DW SUB_BE08
    DW SUB_BDF7
    DW SUB_BCA1
    DW SUB_BCAA
    DW SUB_BCB3
    DW SUB_BCBC
    DW SUB_BE2A
    DW SUB_BE19
    DW SUB_BBE9
    DW SUB_BC07
    DW SUB_BC2B
    DW SUB_BC4D
    DW SUB_BC71
    DW SUB_BC96
    DW SUB_BAE9
    DW SUB_BB0E
    DW SUB_BE08
    DW SUB_BDF7
    DW SUB_BB4E
    DW SUB_BB73
    DW SUB_BB98
    DW SUB_BBBC
    DW SUB_BDDD
    DW SUB_BDEA
    DW SUB_BDC1
    DW SUB_BDCF
    DW SUB_BCC5
    DW SUB_BCEA
    DW SUB_BCEF
    DW SUB_BE90
    DW SUB_BDDD
    DW SUB_BDEA
    DW SUB_BCF8
    DW SUB_BD01
    DW SUB_BD0A
    DW SUB_BD13
    DW SUB_BEB2
    DW SUB_BD38
    DW SUB_BDA7
    DW SUB_BDB4
    DW SUB_BDC1
    DW SUB_BDCF
    DW SUB_BD41
    DW SUB_BE4C
    DW SUB_BD4A
    DW SUB_BD6B
    DW SUB_BDA7
    DW SUB_BDB4
    DW SUB_BCF8
    DW SUB_BD01
    DW SUB_BE6E
    DW SUB_BD70
    DW SUB_BD79
    DW SUB_BD82
    DW SUB_BDAD
    DW SUB_BDBA
    DW SUB_BDC7
    DW SUB_BDD5
    DW SUB_BCA1
    DW SUB_BCAA
    DW SUB_BCB3
    DW SUB_BCBC
    DW SUB_BDDD
    DW SUB_BDEA
    DW SUB_BE08
    DW SUB_BDD5
    DW SUB_BE6E
    DW SUB_BE4C
    DW SUB_BEB2
    DW SUB_BE90
    DW SUB_BDAD
    DW SUB_BE19
    DW SUB_BCF8
    DW SUB_BD01
    DW SUB_BE5D
    DW SUB_BE3B
    DW SUB_BEA1
    DW SUB_BE7F
    DW SUB_BDA7
    DW SUB_BDB4
    DW SUB_BDC7
    DW SUB_BDF7
    DW SUB_BE6E
    DW SUB_BE4C
    DW SUB_BEB2
    DW SUB_BE90
    DW SUB_BE2A
    DW SUB_BDBA
    DW SUB_BDC1
    DW SUB_BDCF
    DW SUB_BE6E
    DW SUB_BE4C
    DW SUB_BEB2
    DW SUB_BE90
    DW SUB_BDE2
    DW SUB_BDEF
    DW SUB_BBE3
    DW SUB_B9E3
    DW SUB_BC15
    DW SUB_BC37
    DW SUB_BC6B
    DW SUB_BC90
    DW SUB_B9E3
    DW SUB_BB08
    DW SUB_BB17
    DW SUB_BB26
    DW SUB_BB48
    DW SUB_BB5A
    DW SUB_BB92
    DW SUB_BBA6
    DW SUB_BBC7
    DW SUB_BBD0
    DW SUB_B9E3
    DW SUB_BC01
    DW SUB_BC25
    DW SUB_BC47
    DW SUB_BC5B
    DW SUB_BC7D
    DW SUB_BAE3
    DW SUB_B9E3
    DW SUB_BB20
    DW SUB_BB2F
    DW SUB_BB35
    DW SUB_BB6D
    DW SUB_BB7F
    DW SUB_BBB6

SUB_C10F:
    LD      A, (RAM_UU+2)
    OR      A
	RET      Z
    LD      A, (RAM_SS+7)
    CALL    TEST_SIGNAL
	RET      Z
    LD      A, (RAM_UU+1)
    CP      3
    JR      NC, SUB_C127
    INC     A
    LD      (RAM_UU+1), A
RET 

SUB_C127:
    CALL    SUB_A165
    LD      C, A
    LD      A, (RAM_SS+9)
    OR      A
	RET      Z
    LD      B, A
    LD      A, C

SUB_C132:
    SUB     B
    JR      NC, SUB_C132
    ADD     A, B
    LD      HL,  RAM_FF+7
    LD      B, A
    INC     B

SUB_C13B:
    LD      A, (HL)
    CP      0FFH
    JR      NZ, SUB_C143
    XOR     A
    JR      SUB_C148

SUB_C143:
    CP      37H
    JR      C, SUB_C148
    INC     B

SUB_C148:
    LD      DE, 6
    ADD     HL, DE
    DJNZ    SUB_C13B
    LD      DE, 0FFFBH
    ADD     HL, DE
    LD      B, (HL)
    INC     HL
    INC     HL
    LD      C, (HL)
    LD      E, A
    LD      D, 0
    LD      HL, DATA_C30E
    ADD     HL, DE
    ADD     HL, DE
    LD      D, (HL)
    INC     HL
    LD      E, (HL)
    EX      DE, HL
    ADD     HL, BC
    LD      B, H
    LD      C, L
    LD      (RAM_SS+2), A
    LD      (RAM_SS), BC
    LD      HL, RAM_RR
    LD      B, 12H
    LD      C, 0DH

LOOP_C173:
    LD      A, (HL)
    OR      A
    JR      Z, SUB_C17F
    LD      DE, 4
    ADD     HL, DE
    INC     C
    DJNZ    LOOP_C173
RET 

SUB_C17F:
    PUSH    HL
    LD      B, 0
    LD      (RAM_SS+4), BC
    LD      BC, (RAM_SS)
    LD      HL,  RAM_DD+1
    LD      D, (HL)
    INC     HL
    INC     HL
    LD      E, (HL)
    LD      HL, 400H
    ADD     HL, DE
    EX      DE, HL
    LD      HL, 810H
    ADD     HL, DE
    LD      A, C
    CP      E
    JR      C, SUB_C1A2
    CP      L
    JP      C, SUB_C210

SUB_C1A2:
    LD      A, (RAM_SS+2)
    CP      26H
    JR      C, SUB_C1AC
    INC     B
    INC     B
    INC     B

SUB_C1AC:
    LD      A, B
    CP      D
    JR      C, SUB_C1B4
    CP      H
    JP      C, SUB_C259

SUB_C1B4:
    LD      A, (RAM_SS+2)
    CP      26H
    JR      C, SUB_C1BE
    DEC     B
    DEC     B
    DEC     B

SUB_C1BE:
    PUSH    DE
    LD      A, B
    CP      D
    JR      C, SUB_C1E9
    LD      A, C
    CP      E
    JR      C, SUB_C1D8

SUB_C1C7:
    LD      A, C
    SUB     B
    ADD     A, D
    CP      E
    JR      C, SUB_C1D1
    CP      L
    JP      C, SUB_C295

SUB_C1D1:
    INC     D
    LD      A, D
    CP      H
    JR      C, SUB_C1C7
    JR      SUB_C20D

SUB_C1D8:
    LD      A, C
    ADD     A, B
    SUB     D
    CP      E
    JR      C, SUB_C1E2
    CP      L
    JP      C, SUB_C2EF

SUB_C1E2:
    INC     D
    LD      A, D
    CP      H
    JR      C, SUB_C1D8
    JR      SUB_C20D

SUB_C1E9:
    LD      A, C
    CP      E
    JR      C, SUB_C1FE

SUB_C1ED:
    LD      A, C
    SUB     D
    ADD     A, B
    CP      E
    JR      C, SUB_C1F7
    CP      L
    JP      C, SUB_C2D1

SUB_C1F7:
    INC     D
    LD      A, D
    CP      H
    JR      C, SUB_C1ED
    JR      SUB_C20D

SUB_C1FE:
    LD      A, C
    SUB     B
    ADD     A, D
    CP      E
    JR      C, SUB_C208
    CP      L
    JP      C, SUB_C2B3

SUB_C208:
    INC     D
    LD      A, D
    CP      H
    JR      C, SUB_C1FE

SUB_C20D:
    POP     DE
    POP     HL
RET 

SUB_C210:
    PUSH    BC
    PUSH    HL
    LD      HL, RAM_RR
    LD      B, 12H
    LD      C, 0

SUB_C219:
    LD      A, (HL)
    INC     HL
    INC     HL
    INC     HL
    OR      A
    JR      Z, SUB_C226
    LD      A, (HL)
    CP      0D5H
    JR      NC, SUB_C226
    INC     C

SUB_C226:
    INC     HL
    DJNZ    SUB_C219
    LD      A, C
    POP     HL
    POP     BC
    CP      2
    POP     HL
RET      NC
    PUSH    HL
    LD      A, B
    CP      D
    JR      C, SUB_C247
    LD      A, (RAM_SS+2)
    CP      26H
    LD      A, B
    JR      NC, SUB_C23F
    ADD     A, 0FBH

SUB_C23F:
    ADD     A, 0FAH
    LD      B, A
    POP     HL
    LD      D, 0D0H
    JR      SUB_C27F

SUB_C247:
    LD      A, (RAM_SS+2)
    CP      26H
    LD      A, B
    JR      NC, SUB_C251
    ADD     A, 1

SUB_C251:
    ADD     A, 0FAH
    LD      B, A
    POP     HL
    LD      D, 0D4H
    JR      SUB_C27F

SUB_C259:
    LD      A, C
    CP      E
    JR      C, SUB_C26F
    LD      A, (RAM_SS+2)
    CP      26H
    LD      A, C
    JR      NC, SUB_C267
    ADD     A, 0FBH

SUB_C267:
    ADD     A, 0FCH
    LD      C, A
    POP     HL
    LD      D, 0D8H
    JR      SUB_C27F

SUB_C26F:
    LD      A, (RAM_SS+2)
    CP      26H
    LD      A, C
    JR      NC, SUB_C279
    ADD     A, 0FBH

SUB_C279:
    ADD     A, 3
    LD      C, A
    POP     HL
    LD      D, 0DCH

SUB_C27F:
    DEC     C
    LD      (HL), C
    INC     HL
    LD      (HL), B
    INC     HL
    LD      (HL), D
    DEC     HL
    DEC     HL
    LD      DE, (RAM_SS+4)
    LD      IY, 1
    LD      A, 0
    RST     8
    JP      SUB_C8BE

SUB_C295:
    POP     DE
    LD      A, (RAM_SS+2)
    CP      26H
    JR      NC, SUB_C2A6
    LD      A, B
    ADD     A, 0F7H
    LD      B, A
    LD      A, C
    ADD     A, 0F7H
    JR      SUB_C2AD

SUB_C2A6:
    LD      A, B
    ADD     A, 0FBH
    LD      B, A
    LD      A, C
    ADD     A, 0FBH

SUB_C2AD:
    LD      C, A
    POP     HL
    LD      D, 0E0H
    JR      SUB_C27F

SUB_C2B3:
    POP     DE
    LD      A, (RAM_SS+2)
    CP      26H
    JR      NC, SUB_C2C4
    LD      A, B
    ADD     A, 0FBH
    LD      B, A
    LD      A, C
    ADD     A, 0FBH
    JR      SUB_C2CB

SUB_C2C4:
    LD      A, B
    ADD     A, 0F8H
    LD      B, A
    LD      A, C
    ADD     A, 0F8H

SUB_C2CB:
    LD      C, A
    POP     HL
    LD      D, 0ECH
    JR      SUB_C27F

SUB_C2D1:
    POP     DE
    LD      A, (RAM_SS+2)
    CP      26H
    JR      NC, SUB_C2E2
    LD      A, B
    ADD     A, 0FAH
    LD      B, A
    LD      A, C
    ADD     A, 0F7H
    JR      SUB_C2E9

SUB_C2E2:
    LD      A, B
    ADD     A, 0F6H
    LD      B, A
    LD      A, C
    ADD     A, 0FBH

SUB_C2E9:
    LD      C, A
    POP     HL
    LD      D, 0E4H
    JR      SUB_C27F

SUB_C2EF:
    POP     DE
    LD      A, (RAM_SS+2)
    CP      26H
    JR      NC, SUB_C300
    LD      A, B
    ADD     A, 0F5H
    LD      B, A
    LD      A, C
    ADD     A, 0FCH
    JR      SUB_C307

SUB_C300:
    LD      A, B
    ADD     A, 0FAH
    LD      B, A
    LD      A, C
    ADD     A, 0F7H

SUB_C307:
    LD      C, A
    POP     HL
    LD      D, 0E8H
    JP      SUB_C27F

DATA_C30E:
	DB    8
    DB    6
    DB    8
    DB    6
    DB    8
    DB    6
    DB    8
    DB    6
    DB    8
    DB    6
    DB    8
    DB    6
    DB    8
    DB    6
    DB  0AH
    DB    6
    DB  0CH
    DB    6
    DB    6
    DB    6
    DB  10H
    DB    6
    DB  0EH
    DB    6
    DB  0CH
    DB    6
    DB  0AH
    DB    6
    DB    8
    DB    6
    DB    8
    DB    8
    DB    8
    DB  0AH
    DB    8
    DB    4
    DB    8
    DB  0EH
    DB    8
    DB  0CH
    DB    8
    DB  0AH
    DB    8
    DB    8
    DB    8
    DB  0EH
    DB  0AH
    DB  0CH
    DB  0CH
    DB  0AH
    DB    6
    DB    8
    DB  0EH
    DB    8
    DB  0CH
    DB  0AH
    DB  0AH
    DB    4
    DB    8
    DB    6
    DB  10H
    DB  0EH
    DB  0EH
    DB  0CH
    DB  0CH
    DB  0AH
    DB  0AH
    DB    8
    DB  0AH
    DB    8
    DB  0CH
    DB  0AH
    DB    6
    DB    4
    DB    8
    DB    6
    DB    3
    DB    1
    DB    3
    DB    1
    DB    3
    DB    3
    DB    3
    DB    5
    DB    3
    DB    0
    DB    3
    DB    9
    DB    3
    DB    7
    DB    3
    DB    5
    DB    3
    DB    3
    DB    3
    DB    1
    DB    5
    DB    1
    DB    7
    DB    1
    DB    1
    DB    1
    DB  0BH
    DB    1
    DB    9
    DB    1
    DB    7
    DB    1
    DB    5
    DB    1

SUB_C37C:
    JP      SUB_C388
SUB_C37F:
    JP      SUB_C436
SUB_C382:
    JP      SUB_C494
SUB_C385:
    JP      SUB_C78E

SUB_C388:
    LD      A, (RAM_CC)
    AND     3
    LD      E, A
    LD      D, 0
    LD      HL, DATA_C70A
    ADD     HL, DE
    LD      D, (HL)
    LD      A, (RAM_SS+9)
    ADD     A, D
    LD      B, A
    CALL    SUB_C6E4
    PUSH    HL
    LD      A, 0
    CALL    REQUEST_SIGNAL
    LD      (RAM_SS+0CH), A
    POP     HL
    LD      DE, 708H
    ADD     HL, DE
    LD      A, 0
    CALL    REQUEST_SIGNAL
    LD      (RAM_SS+0DH), A
    LD      HL,  RAM_DD+1
    LD      B, (HL)
    INC     HL
    INC     HL
    LD      C, (HL)
    LD      A, B
    CP      38H
    JR      NC, SUB_C3C3
    LD      B, 0
    JR      SUB_C3D6

SUB_C3C3:
    CP      0C0H
    JR      C, SUB_C3CB
    LD      B, 0F0H
    JR      SUB_C3D6

SUB_C3CB:
    LD      A, C
    CP      38H
    JR      NC, SUB_C3D4
    LD      C, 18H
    JR      SUB_C3D6

SUB_C3D4:
    LD      C, 0A0H

SUB_C3D6:
    DEC     C
    LD      IX,  RAM_SS+11H
    LD      (IX+1), B
    LD      (IX+0), C
    LD      (RAM_SS+0EH), BC
    LD      IX, RAM_TT
    LD      (IX+1), 78H
    LD      (IX+0), 5CH
    LD      (IX+8), 3
    LD      IX,  RAM_TT+0AH
    LD      (IX+1), 5CH
    LD      (IX+0), 48H
    LD      (IX+8), 3
    LD      IX,  RAM_TT+14H
    LD      (IX+1), 94H
    LD      (IX+0), 48H
    LD      (IX+8), 3
    LD      IX,  RAM_TT+1EH
    LD      (IX+1), 78H
    LD      (IX+0), 34H
    LD      (IX+8), 3
    LD      IX,  RAM_TT+28H
    LD      (IX+1), 78H
    LD      (IX+0), 5CH
    LD      (IX+8), 3
RET 

SUB_C436:
    LD      HL,  RAM_SS+11H
    LD      B, 3CH

SUB_C43B:
    LD      (HL), 0
    INC     HL
    DJNZ    SUB_C43B
    LD      IX,  RAM_SS+11H
    LD      B, 6
    LD      C, 3

SUB_C448:
    LD      (IX+0), 0C0H
    LD      (IX+3), 0AH
    LD      (IX+9), C
    INC     C
    LD      DE, 0AH
    ADD     IX, DE
    DJNZ    SUB_C448
    LD      B, 6
    LD      HL,  RAM_SS+11H
    LD      DE, 3

SUB_C463:
    LD      IY, 1
    LD      A, 0
    PUSH    BC
    PUSH    DE
    PUSH    HL
    RST     8
    POP     HL
    LD      DE, 0AH
    ADD     HL, DE
    POP     DE
    INC     DE
    POP     BC
    DJNZ    SUB_C463
    LD      HL, WORK_BUFFER
    LD      (HL), 0
    INC     HL
    LD      (HL), 0
    INC     HL
    LD      (HL), 0
    INC     HL
    LD      (HL), 1
    LD      HL, WORK_BUFFER
    LD      DE, 9
    LD      IY, 1
    LD      A, 0
    JP      PUT_VRAM

SUB_C494:
    LD      IX,  RAM_SS+11H
    CALL    SUB_C4DA
    LD      IX, RAM_TT
    LD      A, (IX+2)
    OR      A
    JR      Z, SUB_C4AA
    CALL    SUB_C4DA
    JR      SUB_C4B3

SUB_C4AA:
    LD      A, (RAM_SS+0DH)
    CALL    TEST_SIGNAL
    CALL    NZ, SUB_C50C

SUB_C4B3:
    LD      B, 4
    LD      IX,  RAM_TT+0AH

SUB_C4B9:
    LD      A, (IX+2)
    OR      A
    JR      Z, SUB_C4D2
    PUSH    BC
    PUSH    IX
    CP      1
    PUSH    AF
    LD      HL, 14H
    CALL    Z, SUB_C50F
    POP     AF
    CALL    NZ, SUB_C4DA
    POP     IX
    POP     BC

SUB_C4D2:
    LD      DE, 0AH
    ADD     IX, DE
    DJNZ    SUB_C4B9
RET 

SUB_C4DA:
    LD      A, (IX+2)
    CP      0ACH
    JR      C, SUB_C501
    JR      NZ, SUB_C521
    LD      A, (IX+5)
    CALL    FREE_SIGNAL
    LD      HL, 0CH
    LD      A, 1
    CALL    REQUEST_SIGNAL
    LD      (IX+5), A
    PUSH    IX
    CALL    SUB_C88E
    CALL    SUB_A186
    POP     IX
    JP      SUB_C58F

SUB_C501:
    OR      A
    JP      NZ, SUB_C5B2
    LD      A, (RAM_SS+0CH)
    CALL    TEST_SIGNAL
	RET      Z

SUB_C50C:
    LD      HL, 3CH

SUB_C50F:
    LD      (IX+2), 0B8H
    LD      A, 1
    CALL    REQUEST_SIGNAL
    LD      (IX+5), A
    CALL    SUB_C88E
    JP      SUB_A186

SUB_C521:
    LD      A, (IX+5)
    CALL    TEST_SIGNAL
	RET      Z
    LD      A, (IX+2)
    CP      0B8H
    JR      NZ, SUB_C58F
    LD      (IX+2), 90H
    LD      A, (IX+5)
    CALL    FREE_SIGNAL
    LD      A, 1
    LD      HL, 0FH
    CALL    REQUEST_SIGNAL
    LD      (IX+5), A

SUB_C544:
    LD      E, (IX+9)
    LD      D, 0
    LD      IY, 1
    PUSH    IX
    POP     HL
    PUSH    HL
    LD      A, 0
    RST     8
    POP     IX
    PUSH    IX
    CALL    SUB_B871
    INC     E
    DEC     H
    PUSH    DE
    PUSH    HL
    CALL    SUB_B86B
    LD      A, (RAM_SS+0AH)
    OR      A
    JR      Z, SUB_C56D
    POP     HL
    POP     DE
    POP     IX
RET 

SUB_C56D:
    LD      HL,  RAM_DD+1
    LD      D, (HL)
    INC     HL
    INC     HL
    LD      E, (HL)
    LD      HL, 400H
    ADD     HL, DE
    EX      DE, HL
    LD      HL, 810H
    ADD     HL, DE
    PUSH    DE
    PUSH    HL
    CALL    SUB_C78E
    POP     IX
	RET      Z
    LD      A, (RAM_UU)
    OR      A
	RET      NZ
    INC     A
    LD      (RAM_SS+0AH), A
RET 

SUB_C58F:
    CALL    SUB_C544
    LD      A, (IX+2)
    ADD     A, 4
    LD      (IX+2), A
    CP      0B8H
	RET      NZ
    LD      BC, (RAM_SS+0EH)
    LD      (IX+1), B
    LD      (IX+0), C
    LD      A, (IX+8)
    INC     A
    CP      4
	RET      NC
    LD      (IX+8), A
RET 

SUB_C5B2:
    CP      9CH
    JR      NC, SUB_C605
    LD      A, (IX+5)
    CALL    TEST_SIGNAL
	RET      Z
    LD      A, (IX+2)
    ADD     A, 4
    LD      (IX+2), A
    CALL    SUB_C544
    LD      A, (IX+2)
    CP      9CH
	RET      NZ
    LD      A, (IX+5)
    CALL    FREE_SIGNAL
    LD      A, (RAM_CC)
    AND     3
    SLA     A
    SLA     A
    ADD     A, (IX+8)
    LD      E, A
    LD      D, 0
    LD      HL, DATA_H02
    ADD     HL, DE
    LD      L, (HL)
    LD      H, D
    LD      A, 1
    CALL    REQUEST_SIGNAL
    LD      (IX+5), A
    LD      (IX+7), 6
    LD      (IX+4), 3
    LD      A, (RAM_CC)
    AND     3
    CP      3
	RET      NZ
    INC     (IX+4)
RET 

SUB_C605:
    LD      A, (IX+5)
    CALL    TEST_SIGNAL
	RET      Z
    LD      A, (IX+7)
    CP      7
    JR      NZ, SUB_C61D
    LD      (IX+7), 0
    LD      (IX+2), 0A0H
    JR      SUB_C642

SUB_C61D:
    LD      A, (IX+4)
    CP      3
    JR      C, SUB_C62A
    LD      (IX+2), 9CH
    JR      SUB_C642

SUB_C62A:
    CP      2
    JR      NZ, SUB_C634
    LD      (IX+2), 0A4H
    JR      SUB_C642

SUB_C634:
    CP      1
    JR      NZ, SUB_C63E
    LD      (IX+2), 0A8H
    JR      SUB_C642

SUB_C63E:
    LD      (IX+2), 0ACH

SUB_C642:
    CALL    SUB_C693
    LD      L, (IX+7)
    LD      H, 0
    LD      D, H
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    LD      E, (IX+6)
    ADD     HL, DE
    ADD     HL, HL
    LD      DE, DATA_I02
    ADD     HL, DE
    PUSH    HL
    POP     IY
    LD      A, (IX+8)
    INC     A
    LD      B, (IY+0)
    CALL    SUB_C6F0
    LD      A, (IX+1)
    ADD     A, L
    LD      (IX+1), A
    LD      A, (IX+6)
    CP      2
    JR      Z, SUB_C676
    CP      3
    JR      NZ, SUB_C684

SUB_C676:
    LD      A, (IX+8)
    CP      2
    JR      C, SUB_C684
    LD      A, (IY+1)
    SLA     A
    JR      SUB_C687

SUB_C684:
    LD      A, (IY+1)

SUB_C687:
    ADD     A, (IX+0)
    LD      (IX+0), A
    INC     (IX+7)
    JP      SUB_C544

SUB_C693:
    LD      HL,  RAM_DD+1
    LD      B, (HL)
    INC     HL
    INC     HL
    LD      C, (HL)
    LD      D, (IX+1)
    LD      E, (IX+0)
    RST     18H
    RST     20H
    LD      A, B
    CP      D
    JR      Z, SUB_C6C8
    LD      A, C
    CP      E
    JR      Z, SUB_C6D6
    JR      C, SUB_C6BA
    LD      A, B
    CP      D
    JR      C, SUB_C6B5
    LD      (IX+6), 6
RET 

SUB_C6B5:
    LD      (IX+6), 7
RET 

SUB_C6BA:
    LD      A, B
    CP      D
    JR      C, SUB_C6C3
    LD      (IX+6), 4
RET 

SUB_C6C3:
    LD      (IX+6), 5
RET 

SUB_C6C8:
    LD      A, C
    CP      E
    JR      C, SUB_C6D1
    LD      (IX+6), 3
RET 

SUB_C6D1:
    LD      (IX+6), 2
RET 

SUB_C6D6:
    LD      A, B
    CP      D
    JR      C, SUB_C6DF
    LD      (IX+6), 0
RET 

SUB_C6DF:
    LD      (IX+6), 1
RET 

SUB_C6E4:
    LD      A, (AMERICA)
    LD      E, A
    LD      HL, 0
    LD      D, H

SUB_C6EC:
    ADD     HL, DE
    DJNZ    SUB_C6EC
RET 

SUB_C6F0:
    PUSH    DE
    PUSH    BC
    PUSH    AF
    LD      HL, 0
    LD      E, B
    LD      D, H

SUB_C6F8:
    OR      A
    JR      Z, SUB_C706
    SRL     A
    JR      NC, SUB_C700
    ADD     HL, DE

SUB_C700:
    SLA     E
    RL      D
    JR      SUB_C6F8

SUB_C706:
    POP     AF
    POP     BC
    POP     DE
RET 

DATA_C70A:
	DB    8
    DB    4
    DB    0
    DB 0FCH
DATA_H02:
	DB    8
    DB    6
    DB    4
    DB    1
    DB    7
    DB    5
    DB    3
    DB    1
    DB    5
    DB    4
    DB    2
    DB    1
    DB    4
    DB    3
    DB    2
    DB    1
DATA_I02:
	DB    1
    DB    4
    DB 0FFH
    DB    4
    DB    0
    DB    3
    DB    0
    DB    4
    DB    1
    DB    3
    DB 0FFH
    DB    3
    DB    0
    DB    4
    DB    0
    DB    4
    DB    1
    DB 0FCH
    DB 0FFH
    DB 0FCH
    DB    0
    DB 0FCH
    DB    0
    DB 0FDH
    DB    0
    DB 0FCH
    DB    0
    DB 0FCH
    DB    1
    DB 0FDH
    DB 0FFH
    DB 0FDH
    DB    2
    DB 0FCH
    DB 0FEH
    DB 0FCH
    DB    0
    DB 0FCH
    DB    0
    DB 0FEH
    DB    1
    DB 0FCH
    DB 0FFH
    DB 0FCH
    DB    2
    DB 0FEH
    DB 0FEH
    DB 0FEH
    DB    2
    DB 0FEH
    DB 0FEH
    DB 0FEH
    DB    0
    DB 0FDH
    DB    0
    DB    0
    DB    2
    DB 0FDH
    DB 0FEH
    DB 0FDH
    DB    2
    DB    0
    DB 0FEH
    DB    0
    DB    2
    DB    0
    DB 0FEH
    DB    0
    DB    0
    DB 0FEH
    DB    0
    DB    2
    DB    2
    DB 0FEH
    DB 0FEH
    DB 0FEH
    DB    2
    DB    2
    DB 0FEH
    DB    2
    DB    2
    DB    2
    DB 0FEH
    DB    2
    DB    0
    DB    0
    DB    0
    DB    3
    DB    2
    DB    0
    DB 0FEH
    DB    0
    DB    2
    DB    3
    DB 0FEH
    DB    3
    DB    2
    DB    4
    DB 0FEH
    DB    4
    DB    0
    DB    2
    DB    0
    DB    4
    DB    2
    DB    2
    DB 0FEH
    DB    2
    DB    1
    DB    4
    DB 0FFH
    DB    4

SUB_C78E:
    LD      IX, 2
    ADD     IX, SP
    LD      A, (IX+4)
    CP      (IX+2)
    JR      C, SUB_C7B9
    LD      A, (IX+0)
    CP      (IX+6)
    JR      C, SUB_C7B9
    LD      A, (IX+5)
    CP      (IX+3)
    JR      C, SUB_C7B9
    LD      A, (IX+1)
    CP      (IX+7)
    JR      C, SUB_C7B9
    LD      A, 1
    OR      A
    JR      SUB_C7BA

SUB_C7B9:
    XOR     A

SUB_C7BA:
    POP     IX
    EX      (SP), HL
    POP     HL
    EX      (SP), HL
    POP     HL
    EX      (SP), HL
    POP     HL
    EX      (SP), HL
    POP     HL
    JP      (IX)

SUB_C7C6:
    CALL    SOUND_MAN
    JP      PLAY_SONGS

SUB_C7CC:
    LD      HL, SOUND_DATA
    LD      B, 7
    JP      SOUND_INIT

SUB_C7D4:
    LD      B, 23H
    CALL    PLAY_IT
    LD      B, 24H
    CALL    PLAY_IT
    LD      B, 25H
    CALL    PLAY_IT
    LD      B, 26H
    JP      PLAY_IT

SUB_C7E8:
    CALL    SUB_C7CC
    LD      B, 13H
    CALL    PLAY_IT
    LD      B, 12H
    CALL    PLAY_IT
    LD      B, 11H
    CALL    PLAY_IT
    LD      B, 10H
    JP      PLAY_IT

SUB_C7FF:
    CALL    SUB_C7CC
    LD      B, 0BH
    CALL    PLAY_IT
    LD      B, 0CH
    CALL    PLAY_IT

SUB_C80C:
    LD      B, 0AH
    JP      PLAY_IT

SUB_C811:
    CALL    SUB_C7CC
    LD      A, (RAM_WW)
    OR      A
    JR      Z, SUB_C81E
    CP      6
    JR      C, SUB_C823

SUB_C81E:
    LD      A, 6
    LD      (RAM_WW), A

SUB_C823:
    DEC     A
    LD      (RAM_WW), A
    CP      5
    JR      Z, SUB_C80C
    CP      3
    JR      Z, SUB_C83C
    CP      1
    JR      Z, SUB_C853
RET 

SUB_C834:
    CALL    SUB_C7CC
    LD      B, 0BH
    CALL    PLAY_IT

SUB_C83C:
    LD      B, 6
    CALL    PLAY_IT
    LD      B, 7
    JP      PLAY_IT

SUB_C846:
    CALL    SUB_C7CC
    LD      B, 4
    CALL    PLAY_IT
    LD      B, 5
    CALL    PLAY_IT

SUB_C853:
    LD      B, 1
    JP      PLAY_IT

SUB_C858:
    LD      B, 22H
    JP      PLAY_IT

SUB_C85D:
    CALL    SUB_C8B6
    LD      A, 0FFH
    LD      (RAM_YY+0AH), A
    LD      B, 18H
    JP      PLAY_IT

SUB_C86A:
    CALL    SUB_C7CC
    LD      B, 1
    CALL    PLAY_IT
    LD      B, 2
    CALL    PLAY_IT
    LD      B, 3
    JP      PLAY_IT

SUB_C87C:
    CALL    SUB_C7CC
    LD      B, 1
    CALL    PLAY_IT
    LD      B, 8
    CALL    PLAY_IT
    LD      B, 9
    JP      PLAY_IT

SUB_C88E:
    LD      B, 0DH
    CALL    PLAY_IT
    LD      B, 0EH
    CALL    PLAY_IT
    LD      B, 0FH
    JP      PLAY_IT

SUB_C89D:
    CALL    SUB_C8B6
    CALL    SUB_C8AD
    LD      B, 14H
    CALL    PLAY_IT
    LD      B, 15H
    JP      PLAY_IT

SUB_C8AD:
    LD      A, 0FFH
    LD      (RAM_YY), A
    LD      (RAM_YY+0AH), A
RET 

SUB_C8B6:
    LD      A, (RAM_YY+0AH)
    CP      0CEH
	RET      NZ
    POP     HL
RET 

SUB_C8BE:
    CALL    SUB_C8B6
    CALL    SUB_C8AD
    LD      B, 16H
    CALL    PLAY_IT
    LD      B, 17H
    JP      PLAY_IT

SUB_C8CE:
    CALL    SUB_C8B6
    CALL    SUB_C8AD
    LD      B, 20H
    CALL    PLAY_IT
    LD      B, 21H
    JP      PLAY_IT

SUB_C8DE:
    CALL    SUB_C7CC
    LD      B, 19H
    CALL    PLAY_IT
    LD      B, 1AH
    CALL    PLAY_IT
    LD      B, 1BH
    CALL    PLAY_IT
    LD      B, 1CH
    JP      PLAY_IT

SUB_C8F5:
    CALL    SUB_C8B6
    CALL    SUB_C90A
    LD      B, 1DH
    CALL    PLAY_IT
    LD      B, 1EH
    JP      PLAY_IT

SUB_C905:
    LD      B, 1FH
    JP      PLAY_IT

SUB_C90A:
    LD      A, 0FFH
    LD      (RAM_YY+14H), A
    LD      (RAM_YY+1EH), A
RET 


SOUND_DATA:
	DB 171,201,032,115,140,206,042,115,181,206,052,115,037,202,042,115,084,202,052,115,086,203,032,115,092,203,042,115,053,206
    DB 042,115,102,206,052,115,166,202,032,115,232,202,052,115,031,203,042,115,131,202,062,115,144,202,072,115,155,202,082,115
    DB 149,203,032,115,249,203,042,115,083,204,052,115,156,204,062,115,222,206,062,115,228,206,072,115,252,206,062,115,002,207
    DB 072,115,011,207,072,115,020,207,032,115,029,207,042,115,035,207,052,115,044,207,062,115,053,207,082,115,060,207,092,115
    DB 066,207,092,115,237,206,062,115,243,206,072,115,196,201,092,115,202,204,032,115,127,205,042,115,163,205,052,115,236,205
    DB 062,115,066,039,083,016,082,020,066,191,083,016,082,020,066,202,082,016,082,020,066,191,083,016,082,020,088,130,064,049
    DB 008,082,020,130,013,049,008,082,020,130,202,048,008,082,020,130,160,048,008,082,020,130,135,048,008,082,020,130,160,048
    DB 008,082,020,130,202,064,008,066,020,130,013,081,008,066,020,130,064,097,008,050,020,130,013,113,008,050,020,130,202,128
    DB 008,034,020,130,160,144,008,034,020,130,135,160,008,018,020,130,160,176,008,018,020,130,202,192,008,017,020,130,013,209
    DB 008,017,020,144,176,176,131,255,243,032,017,248,255,034,130,250,002,013,083,020,130,250,002,013,083,020,130,039,003,013
    DB 083,020,130,039,003,013,083,020,130,087,003,013,083,020,130,087,051,008,082,020,144,112,112,067,255,243,032,017,227,255
    DB 051,066,095,016,013,068,020,066,095,016,013,068,020,066,101,032,013,068,020,066,101,032,013,068,020,066,107,048,013,068
    DB 020,066,107,048,008,082,020,080,129,224,065,003,255,231,130,148,065,068,028,136,144,193,128,224,003,255,249,192,108,240
    DB 068,208,002,051,045,000,000,002,051,068,028,102,016,065,029,081,007,026,022,064,172,097,006,098,065,029,081,007,026,022
    DB 064,172,097,006,098,065,029,081,007,026,022,066,172,097,016,026,024,064,029,097,006,098,064,172,097,006,098,064,029,081
    DB 006,098,064,172,081,006,098,064,029,081,006,098,066,172,081,024,022,031,088,130,167,002,024,026,031,130,172,001,072,026
    DB 255,130,093,002,024,026,031,130,172,001,072,026,255,130,167,050,024,026,031,130,172,065,072,026,255,130,093,082,024,026
    DB 031,130,172,097,072,026,255,130,167,130,024,024,031,144,194,170,016,024,026,031,194,107,016,072,026,255,194,151,016,024
    DB 026,031,194,107,016,072,026,255,194,170,064,024,026,031,194,107,080,072,026,255,194,151,096,024,026,031,194,107,112,072
    DB 026,255,194,170,128,024,024,031,208,064,172,065,002,100,088,064,027,082,024,194,027,082,048,026,255,066,059,082,024,026
    DB 031,064,027,082,024,194,027,082,048,026,255,066,093,082,024,026,031,066,027,082,024,026,031,066,224,081,024,026,031,066
    DB 125,081,024,026,031,066,224,081,024,026,031,088,064,249,035,007,065,091,032,004,033,248,064,036,032,007,103,064,249,035
    DB 007,103,065,076,032,003,119,010,103,064,249,035,007,065,091,032,004,033,248,064,036,032,007,103,064,249,035,007,103,065
    DB 076,032,003,119,010,103,064,249,115,007,103,064,143,096,007,103,064,249,099,007,103,064,143,080,007,103,064,249,083,007
    DB 103,064,143,064,007,103,064,249,067,007,103,064,143,048,007,103,064,249,051,007,103,088,128,249,035,007,167,128,101,032
    DB 007,167,128,249,035,007,167,129,151,032,003,119,020,167,128,249,035,007,167,128,101,032,007,167,128,249,035,007,167,129
    DB 151,032,003,119,020,167,128,249,115,007,167,128,029,097,007,167,128,249,099,007,167,128,029,081,007,167,128,249,083,007
    DB 167,128,029,065,007,167,128,249,067,007,167,128,029,049,007,167,128,249,051,007,167,152,192,136,240,014,192,202,032,007
    DB 192,136,240,021,193,041,033,003,119,042,192,136,240,021,192,202,032,007,192,136,240,021,193,041,033,003,119,042,192,136
    DB 240,021,192,202,112,007,192,136,240,021,192,202,096,007,192,136,240,021,192,202,080,007,192,136,240,021,192,202,064,007
    DB 192,180,240,021,216,002,035,028,098,025,002,035,042,098,025,002,035,028,098,025,002,035,042,098,025,002,115,028,066,025
    DB 002,099,028,082,025,002,083,028,082,025,002,067,028,098,025,002,051,014,098,025,024,192,014,240,119,193,015,240,002,052
    DB 255,193,015,240,002,171,004,193,022,240,002,137,249,192,017,240,020,192,014,240,022,193,015,240,002,052,255,193,015,240
    DB 002,171,004,193,022,240,002,137,249,192,017,240,018,192,014,240,018,193,015,240,002,052,255,192,015,240,018,192,017,240
    DB 018,192,013,240,018,192,019,240,003,192,017,240,020,192,014,240,022,193,015,240,002,052,255,193,015,240,002,188,004,193
    DB 022,240,002,202,249,192,017,240,144,192,014,240,027,192,014,240,110,193,015,240,002,052,255,192,015,240,022,192,019,240
    DB 020,192,015,240,018,192,014,240,003,192,016,240,027,192,017,240,072,192,046,049,126,192,104,049,018,192,046,065,003,192
    DB 083,065,018,192,148,081,018,192,083,081,003,192,125,097,018,194,197,113,132,025,255,216,002,147,126,246,255,002,051,168
    DB 000,000,002,051,145,018,255,002,083,150,026,255,002,099,252,243,255,002,051,138,028,255,002,243,252,000,000,024,064,000
    DB 240,251,064,013,145,045,064,254,128,148,066,013,145,174,023,255,064,148,113,144,064,172,113,072,064,197,113,063,064,224
    DB 113,072,064,252,113,018,064,027,114,018,064,059,114,018,064,093,114,021,064,129,114,018,064,167,114,021,064,202,114,018
    DB 064,250,114,018,066,039,115,112,025,255,088,128,000,240,251,128,027,114,045,128,252,097,148,130,027,114,174,025,255,128
    DB 013,113,144,128,029,113,072,128,046,113,063,128,064,113,072,128,083,113,018,128,104,113,018,128,125,113,018,128,148,113
    DB 021,128,172,113,018,128,197,113,021,128,224,113,018,128,252,113,018,130,027,114,112,025,255,152,131,041,128,007,017,255
    DB 248,017,128,030,048,007,175,131,073,160,003,034,032,243,017,128,170,048,007,174,129,214,048,002,079,202,129,214,064,002
    DB 068,040,129,064,081,002,068,108,128,129,098,008,144,231,194,101,080,014,066,020,194,120,080,014,066,020,194,180,080,014
    DB 066,020,194,240,080,014,066,020,194,202,082,014,066,020,194,224,081,014,066,020,208,130,202,032,032,114,040,130,151,032
    DB 032,114,040,128,101,016,006,130,113,032,090,029,255,129,101,032,002,137,034,129,113,032,002,120,038,130,202,032,128,029
    DB 111,144,254,254,192,226,080,088,192,240,080,019,192,226,064,003,192,254,080,022,192,013,081,019,192,226,064,003,192,254
    DB 080,022,192,013,081,022,194,064,097,064,026,136,208,002,007,015,039,023,016,195,000,048,015,017,030,052,023,208,002,055
    DB 010,038,021,016,195,032,016,010,017,010,052,039,208,002,007,020,031,042,016,195,032,048,020,017,005,038,042,208,131,020
    DB 048,020,017,002,038,034,144,131,032,048,060,017,127,028,159,144,002,053,060,028,143,016,067,148,049,060,017,254,028,079
    DB 080,195,255,051,060,017,253,028,111,208,193,000,224,060,017,004,208,002,055,060,028,143,016,193,000,048,142,017,093,208
    DB 000,000,000,000,000,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
    DB 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
    DB 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
    DB 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
    DB 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
    DB 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
    DB 255,255,255,190,025,190,217,187,247,187,043,188,077,188,113,188,150,188,042,190,025,190,008,190,247,189,161,188,170,188
    DB 179,188,188,188,042,190,025,190,233,187,007,188,043,188,077,188,113,188,150,188,233,186,014,187,008,190,247,189,078,187
    DB 115,187,152,187,188,187,221,189,234,189,193,189,207,189,197,188,234,188,239,188,144,190,221,189,234,189,248,188,001,189
    DB 010,189,019,189,178,190,056,189,167,189,180,189,193,189,207,189,065,189,076,190,074,189,107,189,167,189,180,189,248,188
    DB 001,189,110,190,112,189,121,189,130,189,173,189,186,189,199,189,213,189,161,188,170,188,179,188,188,188,221,189,234,189
    DB 008,190,213,189,110,190,076,190,178,190,144,190,173,189,025,190,248,188,001,189,093,190,059,190,161,190,127,190,167,189
    DB 180,189,199,189,247,189,110,190,076,190,178,190,144,190,042,190,186,189,193,189,207,189,110,190,076,190,178,190,144,190
    DB 226,189,239,189,227,187,227,185,021,188,055,188,107,188,144,188,227,185,008,187,023,187,038,187,072,187,090,187,146,187
    DB 166,187,199,187,208,187,227,185,001,188,037,188,071,188,091,188,125,188,227,186,227,185,032,187,047,187,053,187,109,187
    DB 127,187,182,187,058,232,114,183,200,058,160,114,205,208,031,200,058,231,114,254,003,048,005,060,050,231,114,201,205,101
    DB 161,079,058,162,114,183,200,071,121,144,048,253,128,033,199,112,071,004,126,254,255,032,003,175,024,005,254,055,056,001
    DB 004,017,006,000,025,016,237,017,251,255,025,070,035,035,078,095,022,000,033,014,195,025,025,086,035,094,235,009,068,077
    DB 050,155,114,237,067,153,114,033,081,114,006,018,014,013,126,183,040,008,017,004,000,025,012,016,245,201,229,006,000,237
    DB 067,157,114,237,075,153,114,033,156,112,086,035,035,094,033,000,004,025,235,033,016,008,025,121,187,056,004,189,218,016
    DB 194,058,155,114,254,038,056,003,004,004,004,120,186,056,004,188,218,089,194,058,155,114,254,038,056,003,005,005,005,213
    DB 120,186,056,038,121,187,056,017,121,144,130,187,056,004,189,218,149,194,020,122,188,056,241,024,053,121,128,146,187,056
    DB 004,189,218,239,194,020,122,188,056,241,024,036,121,187,056,017,121,146,128,187,056,004,189,218,209,194,020,122,188,056
    DB 241,024,015,121,144,130,187,056,004,189,218,179,194,020,122,188,056,241,209,225,201,197,229,033,081,114,006,018,014,000
    DB 126,035,035,035,183,040,006,126,254,213,048,001,012,035,016,240,121,225,193,254,002,225,208,229,120,186,056,018,058,155
    DB 114,254,038,120,048,002,198,251,198,250,071,225,022,208,024,056,058,155,114,254,038,120,048,002,198,001,198,250,071,225
    DB 022,212,024,038,121,187,056,018,058,155,114,254,038,121,048,002,198,251,198,252,079,225,022,216,024,016,058,155,114,254
    DB 038,121,048,002,198,251,198,003,079,225,022,220,013,113,035,112,035,114,043,043,237,091,157,114,253,033,001,000,062,000
    DB 207,195,190,200,209,058,155,114,254,038,048,009,120,198,247,071,121,198,247,024,007,120,198,251,071,121,198,251,079,225
    DB 022,224,024,204,209,058,155,114,254,038,048,009,120,198,251,071,121,198,251,024,007,120,198,248,071,121,198,248,079,225
    DB 022,236,024,174,209,058,155,114,254,038,048,009,120,198,250,071,121,198,247,024,007,120,198,246,071,121,198,251,079,225
    DB 022,228,024,144,209,058,155,114,254,038,048,009,120,198,245,071,121,198,252,024,007,120,198,250,071,121,198,247,079,225
    DB 022,232,195,127,194,008,006,008,006,008,006,008,006,008,006,008,006,008,006,010,006,012,006,006,006,016,006,014,006,012
    DB 006,010,006,008,006,008,008,008,010,008,004,008,014,008,012,008,010,008,008,008,014,010,012,012,010,006,008,014,008,012
    DB 010,010,004,008,006,016,014,014,012,012,010,010,008,010,008,012,010,006,004,008,006,003,001,003,001,003,003,003,005,003
    DB 000,003,009,003,007,003,005,003,003,003,001,005,001,007,001,001,001,011,001,009,001,007,001,005,001,195,136,195,195,054
    DB 196,195,148,196,195,142,199,058,124,112,230,003,095,022,000,033,010,199,025,086,058,162,114,130,071,205,228,198,229,062
    DB 000,205,205,031,050,165,114,225,017,008,007,025,062,000,205,205,031,050,166,114,033,156,112,070,035,035,078,120,254,056
    DB 048,004,006,000,024,019,254,192,056,004,006,240,024,011,121,254,056,048,004,014,024,024,002,014,160,013,221,033,170,114
    DB 221,112,001,221,113,000,237,067,167,114,221,033,180,114,221,054,001,120,221,054,000,092,221,054,008,003,221,033,190,114
    DB 221,054,001,092,221,054,000,072,221,054,008,003,221,033,200,114,221,054,001,148,221,054,000,072,221,054,008,003,221,033
    DB 210,114,221,054,001,120,221,054,000,052,221,054,008,003,221,033,220,114,221,054,001,120,221,054,000,092,221,054,008,003
    DB 201,033,170,114,006,060,054,000,035,016,251,221,033,170,114,006,006,014,003,221,054,000,192,221,054,003,010,221,113,009
    DB 012,017,010,000,221,025,016,237,006,006,033,170,114,017,003,000,253,033,001,000,062,000,197,213,229,207,225,017,010,000
    DB 025,209,019,193,016,236,033,000,112,054,000,035,054,000,035,054,000,035,054,001,033,000,112,017,009,000,253,033,001,000
    DB 062,000,195,190,031,221,033,170,114,205,218,196,221,033,180,114,221,126,002,183,040,005,205,218,196,024,009,058,166,114
    DB 205,208,031,196,012,197,006,004,221,033,190,114,221,126,002,183,040,019,197,221,229,254,001,245,033,020,000,204,015,197
    DB 241,196,218,196,221,225,193,017,010,000,221,025,016,224,201,221,126,002,254,172,056,032,032,062,221,126,005,205,202,031
    DB 033,012,000,062,001,205,205,031,221,119,005,221,229,205,142,200,205,134,161,221,225,195,143,197,183,194,178,197,058,165
    DB 114,205,208,031,200,033,060,000,221,054,002,184,062,001,205,205,031,221,119,005,205,142,200,195,134,161,221,126,005,205
    DB 208,031,200,221,126,002,254,184,032,096,221,054,002,144,221,126,005,205,202,031,062,001,033,015,000,205,205,031,221,119
    DB 005,221,094,009,022,000,253,033,001,000,221,229,225,229,062,000,207,221,225,221,229,205,113,184,028,037,213,229,205,107
    DB 184,058,163,114,183,040,005,225,209,221,225,201,033,156,112,086,035,035,094,033,000,004,025,235,033,016,008,025,213,229
    DB 205,142,199,221,225,200,058,230,114,183,192,060,050,163,114,201,205,068,197,221,126,002,198,004,221,119,002,254,184,192
    DB 237,075,167,114,221,112,001,221,113,000,221,126,008,060,254,004,208,221,119,008,201,254,156,048,079,221,126,005,205,208
    DB 031,200,221,126,002,198,004,221,119,002,205,068,197,221,126,002,254,156,192,221,126,005,205,202,031,058,124,112,230,003
    DB 203,039,203,039,221,134,008,095,022,000,033,014,199,025,110,098,062,001,205,205,031,221,119,005,221,054,007,006,221,054
    DB 004,003,058,124,112,230,003,254,003,192,221,052,004,201,221,126,005,205,208,031,200,221,126,007,254,007,032,010,221,054
    DB 007,000,221,054,002,160,024,037,221,126,004,254,003,056,006,221,054,002,156,024,024,254,002,032,006,221,054,002,164,024
    DB 014,254,001,032,006,221,054,002,168,024,004,221,054,002,172,205,147,198,221,110,007,038,000,084,041,041,041,221,094,006
    DB 025,041,017,030,199,025,229,253,225,221,126,008,060,253,070,000,205,240,198,221,126,001,133,221,119,001,221,126,006,254
    DB 002,040,004,254,003,032,014,221,126,008,254,002,056,007,253,126,001,203,039,024,003,253,126,001,221,134,000,221,119,000
    DB 221,052,007,195,068,197,033,156,112,070,035,035,078,221,086,001,221,094,000,223,231,120,186,040,034,121,187,040,044,056
    DB 014,120,186,056,005,221,054,006,006,201,221,054,006,007,201,120,186,056,005,221,054,006,004,201,221,054,006,005,201,121
    DB 187,056,005,221,054,006,003,201,221,054,006,002,201,120,186,056,005,221,054,006,000,201,221,054,006,001,201,058,105,000
    DB 095,033,000,000,084,025,016,253,201,213,197,245,033,000,000,088,084,183,040,011,203,063,048,001,025,203,035,203,018,024
    DB 242,241,193,209,201,008,004,000,252,008,006,004,001,007,005,003,001,005,004,002,001,004,003,002,001,001,004,255,004,000
    DB 003,000,004,001,003,255,003,000,004,000,004,001,252,255,252,000,252,000,253,000,252,000,252,001,253,255,253,002,252,254
    DB 252,000,252,000,254,001,252,255,252,002,254,254,254,002,254,254,254,000,253,000,000,002,253,254,253,002,000,254,000,002
    DB 000,254,000,000,254,000,002,002,254,254,254,002,002,254,002,002,002,254,002,000,000,000,003,002,000,254,000,002,003,254
    DB 003,002,004,254,004,000,002,000,004,002,002,254,002,001,004,255,004,221,033,002,000,221,057,221,126,004,221,190,002,056
    DB 029,221,126,000,221,190,006,056,021,221,126,005,221,190,003,056,013,221,126,001,221,190,007,056,005,062,001,183,024,001
    DB 175,221,225,227,225,227,225,227,225,227,225,221,233,205,244,031,195,097,031,033,019,201,006,007,195,238,031,006,035,205
    DB 241,031,006,036,205,241,031,006,037,205,241,031,006,038,195,241,031,205,204,199,006,019,205,241,031,006,018,205,241,031
    DB 006,017,205,241,031,006,016,195,241,031,205,204,199,006,011,205,241,031,006,012,205,241,031,006,010,195,241,031,205,204
    DB 199,058,031,115,183,040,004,254,006,056,005,062,006,050,031,115,061,050,031,115,254,005,040,225,254,003,040,013,254,001
    DB 040,032,201,205,204,199,006,011,205,241,031,006,006,205,241,031,006,007,195,241,031,205,204,199,006,004,205,241,031,006
    DB 005,205,241,031,006,001,195,241,031,006,034,195,241,031,205,182,200,062,255,050,072,115,006,024,195,241,031,205,204,199
    DB 006,001,205,241,031,006,002,205,241,031,006,003,195,241,031,205,204,199,006,001,205,241,031,006,008,205,241,031,006,009
    DB 195,241,031,006,013,205,241,031,006,014,205,241,031,006,015,195,241,031,205,182,200,205,173,200,006,020,205,241,031,006
    DB 021,195,241,031,062,255,050,062,115,050,072,115,201,058,072,115,254,206,192,225,201,205,182,200,205,173,200,006,022,205
    DB 241,031,006,023,195,241,031,205,182,200,205,173,200,006,032,205,241,031,006,033,195,241,031,205,204,199,006,025,205,241
    DB 031,006,026,205,241,031,006,027,205,241,031,006,028,195,241,031,205,182,200,205,010,201,006,029,205,241,031,006,030,195
    DB 241,031,006,031,195,241,031,062,255,050,082,115,050,092,115,201,171,201,032,115,140,206,042,115,181,206,052,115,037,202
    DB 042,115,084,202,052,115,086,203,032,115,092,203,042,115,053,206,042,115,102,206,052,115,166,202,032,115,232,202,052,115
    DB 031,203,042,115,131,202,062,115,144,202,072,115,155,202,082,115,149,203,032,115,249,203,042,115,083,204,052,115,156,204
    DB 062,115,222,206,062,115,228,206,072,115,252,206,062,115,002,207,072,115,011,207,072,115,020,207,032,115,029,207,042,115
    DB 035,207,052,115,044,207,062,115,053,207,082,115,060,207,092,115,066,207,092,115,237,206,062,115,243,206,072,115,196,201
    DB 092,115,202,204,032,115,127,205,042,115,163,205,052,115,236,205,062,115,066,039,083,016,082,020,066,191,083,016,082,020
    DB 066,202,082,016,082,020,066,191,083,016,082,020,088,130,064,049,008,082,020,130,013,049,008,082,020,130,202,048,008,082
    DB 020,130,160,048,008,082,020,130,135,048,008,082,020,130,160,048,008,082,020,130,202,064,008,066,020,130,013,081,008,066
    DB 020,130,064,097,008,050,020,130,013,113,008,050,020,130,202,128,008,034,020,130,160,144,008,034,020,130,135,160,008,018
    DB 020,130,160,176,008,018,020,130,202,192,008,017,020,130,013,209,008,017,020,144,176,176,131,255,243,032,017,248,255,034
    DB 130,250,002,013,083,020,130,250,002,013,083,020,130,039,003,013,083,020,130,039,003,013,083,020,130,087,003,013,083,020
    DB 130,087,051,008,082,020,144,112,112,067,255,243,032,017,227,255,051,066,095,016,013,068,020,066,095,016,013,068,020,066
    DB 101,032,013,068,020,066,101,032,013,068,020,066,107,048,013,068,020,066,107,048,008,082,020,080,129,224,065,003,255,231
    DB 130,148,065,068,028,136,144,193,128,224,003,255,249,192,108,240,068,208,002,051,045,000,000,002,051,068,028,102,016,065
    DB 029,081,007,026,022,064,172,097,006,098,065,029,081,007,026,022,064,172,097,006,098,065,029,081,007,026,022,066,172,097
    DB 016,026,024,064,029,097,006,098,064,172,097,006,098,064,029,081,006,098,064,172,081,006,098,064,029,081,006,098,066,172
    DB 081,024,022,031,088,130,167,002,024,026,031,130,172,001,072,026,255,130,093,002,024,026,031,130,172,001,072,026,255,130
    DB 167,050,024,026,031,130,172,065,072,026,255,130,093,082,024,026,031,130,172,097,072,026,255,130,167,130,024,024,031,144
    DB 194,170,016,024,026,031,194,107,016,072,026,255,194,151,016,024,026,031,194,107,016,072,026,255,194,170,064,024,026,031
    DB 194,107,080,072,026,255,194,151,096,024,026,031,194,107,112,072,026,255,194,170,128,024,024,031,208,064,172,065,002,100
    DB 088,064,027,082,024,194,027,082,048,026,255,066,059,082,024,026,031,064,027,082,024,194,027,082,048,026,255,066,093,082
    DB 024,026,031,066,027,082,024,026,031,066,224,081,024,026,031,066,125,081,024,026,031,066,224,081,024,026,031,088,064,249
    DB 035,007,065,091,032,004,033,248,064,036,032,007,103,064,249,035,007,103,065,076,032,003,119,010,103,064,249,035,007,065
    DB 091,032,004,033,248,064,036,032,007,103,064,249,035,007,103,065,076,032,003,119,010,103,064,249,115,007,103,064,143,096
    DB 007,103,064,249,099,007,103,064,143,080,007,103,064,249,083,007,103,064,143,064,007,103,064,249,067,007,103,064,143,048
    DB 007,103,064,249,051,007,103,088,128,249,035,007,167,128,101,032,007,167,128,249,035,007,167,129,151,032,003,119,020,167
    DB 128,249,035,007,167,128,101,032,007,167,128,249,035,007,167,129,151,032,003,119,020,167,128,249,115,007,167,128,029,097
    DB 007,167,128,249,099,007,167,128,029,081,007,167,128,249,083,007,167,128,029,065,007,167,128,249,067,007,167,128,029,049
    DB 007,167,128,249,051,007,167,152,192,136,240,014,192,202,032,007,192,136,240,021,193,041,033,003,119,042,192,136,240,021
    DB 192,202,032,007,192,136,240,021,193,041,033,003,119,042,192,136,240,021,192,202,112,007,192,136,240,021,192,202,096,007
    DB 192,136,240,021,192,202,080,007,192,136,240,021,192,202,064,007,192,180,240,021,216,002,035,028,098,025,002,035,042,098
    DB 025,002,035,028,098,025,002,035,042,098,025,002,115,028,066,025,002,099,028,082,025,002,083,028,082,025,002,067,028,098
    DB 025,002,051,014,098,025,024,192,014,240,119,193,015,240,002,052,255,193,015,240,002,171,004,193,022,240,002,137,249,192
    DB 017,240,020,192,014,240,022,193,015,240,002,052,255,193,015,240,002,171,004,193,022,240,002,137,249,192,017,240,018,192
    DB 014,240,018,193,015,240,002,052,255,192,015,240,018,192,017,240,018,192,013,240,018,192,019,240,003,192,017,240,020,192
    DB 014,240,022,193,015,240,002,052,255,193,015,240,002,188,004,193,022,240,002,202,249,192,017,240,144,192,014,240,027,192
    DB 014,240,110,193,015,240,002,052,255,192,015,240,022,192,019,240,020,192,015,240,018,192,014,240,003,192,016,240,027,192
    DB 017,240,072,192,046,049,126,192,104,049,018,192,046,065,003,192,083,065,018,192,148,081,018,192,083,081,003,192,125,097
    DB 018,194,197,113,132,025,255,216,002,147,126,246,255,002,051,168,000,000,002,051,145,018,255,002,083,150,026,255,002,099
    DB 252,243,255,002,051,138,028,255,002,243,252,000,000,024,064,000,240,251,064,013,145,045,064,254,128,148,066,013,145,174
    DB 023,255,064,148,113,144,064,172,113,072,064,197,113,063,064,224,113,072,064,252,113,018,064,027,114,018,064,059,114,018
    DB 064,093,114,021,064,129,114,018,064,167,114,021,064,202,114,018,064,250,114,018,066,039,115,112,025,255,088,128,000,240
    DB 251,128,027,114,045,128,252,097,148,130,027,114,174,025,255,128,013,113,144,128,029,113,072,128,046,113,063,128,064,113
    DB 072,128,083,113,018,128,104,113,018,128,125,113,018,128,148,113,021,128,172,113,018,128,197,113,021,128,224,113,018,128
    DB 252,113,018,130,027,114,112,025,255,152,131,041,128,007,017,255,248,017,128,030,048,007,175,131,073,160,003,034,032,243
    DB 017,128,170,048,007,174,129,214,048,002,079,202,129,214,064,002,068,040,129,064,081,002,068,108,128,129,098,008,144,231
    DB 194,101,080,014,066,020,194,120,080,014,066,020,194,180,080,014,066,020,194,240,080,014,066,020,194,202,082,014,066,020
    DB 194,224,081,014,066,020,208,130,202,032,032,114,040,130,151,032,032,114,040,128,101,016,006,130,113,032,090,029,255,129
    DB 101,032,002,137,034,129,113,032,002,120,038,130,202,032,128,029,111,144,254,254,192,226,080,088,192,240,080,019,192,226
    DB 064,003,192,254,080,022,192,013,081,019,192,226,064,003,192,254,080,022,192,013,081,022,194,064,097,064,026,136,208,002
    DB 007,015,039,023,016,195,000,048,015,017,030,052,023,208,002,055,010,038,021,016,195,032,016,010,017,010,052,039,208,002
    DB 007,020,031,042,016,195,032,048,020,017,005,038,042,208,131,020,048,020,017,002,038,034,144,131,032,048,060,017,127,028
    DB 159,144,002,053,060,028,143,016,067,148,049,060,017,254,028,079,080,195,255,051,060,017,253,028,111,208,193,000,224,060
    DB 017,004,208,002,055,060,028,143,016,193,000,048,142,017,093,208,000,000,000,000,000,000,000

PADD: DS 176, 255