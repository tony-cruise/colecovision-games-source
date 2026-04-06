; COMPILABLE DISASSEMBLY OF SQUISH 'EM BY CAPTAIN COZMOS
; CREDIT GOES WHERE CREDIT IS DUE.  THIS IS A PAINFUL, TIME CONSUMING EXPERIENCE.



PLAY_SONGS:         EQU $1F61
CONTROLLER_SCAN:    EQU $1F76
DECODER:            EQU $1F79
LOAD_ASCII:         EQU $1F7F
FILL_VRAM:          EQU $1F82
MODE_1:             EQU $1F85
PUT_VRAM:           EQU $1FBE
TURN_OFF_SOUND:     EQU $1FD6
WRITE_REGISTER:     EQU $1FD9
READ_REGISTER:      EQU $1FDC
WRITE_VRAM:         EQU $1FDF
SOUND_INIT:         EQU $1FEE
PLAY_IT:            EQU $1FF1
SOUND_MAN:          EQU $1FF4


SPRITE_NAME_TABLE:  EQU $0000
SPRITE_ORDER_TABLE: EQU $0000
WORK_BUFFER:        EQU $702B
CONTROLLER_BUFFER:  EQU $712D


FNAME "SQUISH 'EM V1.ROM"
CPU Z80

    ORG $8000

                DW 0AA55H
WORD_8002:      DW 0
                DW 0
                DW 0
                DW 0
                DW START
				RET
                NOP
                NOP
				RET
                NOP
                NOP
				RET
                NOP
                NOP
				RET
                NOP
                NOP
				RET
                NOP
                NOP
				RET
                NOP
                NOP
                NOP
                NOP
                NOP
				JP      NMI

KEYS_USED_TXT:
	DB  4BH, 45H, 59H, 53H, 20H, 55H, 53H, 45H, 44H, 20H, 49H, 4EH, 20H, 47H, 41H, 4DH, 45H

START_GAME_TXT:
	DB  2AH, 20H, 3DH, 20H, 53H, 54H, 41H, 52H, 54H, 20H, 47H, 41H, 4DH, 45H

SELECT_GAME_TXT:
	DB  23H, 20H, 3DH, 20H, 53H, 45H, 4CH, 45H, 43H, 54H, 20H, 47H, 41H, 4DH, 45H, 20H, 4CH, 45H, 56H, 45H, 4CH, 53H

PAUSE_GAME_TXT:
	DB  30H, 20H, 3DH, 20H, 50H, 41H, 55H, 53H, 45H, 20H, 47H, 41H, 4DH, 45H

    DB 084,079,078,089,032,078,071,079,044,032,085,082,073,065,072,032,066,065,082,078,069,084,084,032,038,032,066,069,078,078,089,032
    DB 078,071,079,032,049,050,047,048,049,047,056,050,084,073,084,076,069,032,065,078,068,032,083,080,069,069,067,072,032,065,068,068
    DB 069,068,032,038,032,071,065,077,069,032,073,078,067,082,069,065,083,069,068,032,084,079,032,050,053,032,076,069,086,069,076,083
    DB 032,078,079,082,077,065,078,046,082,046,068,073,067,075,073,078,084,069,082,080,072,065,083,069,032,067,065,078,065,068,065,032
    DB 079,067,084,056,051

LOC_80EC:
    CALL    SUB_81BA
    CALL    SUB_9FC2
    CALL    PLAY_SPEECH
    LD      A, ($717F)
    OR      A
    JR      NZ, LOC_80EC
    CALL    SUB_833F
    CALL    TURN_OFF_SOUND
    CALL    SUB_81BA
    CALL    SUB_8791
    CALL    SUB_87AB
    CALL    SUB_86FF
    LD      BC, 603H
    CALL    WRITE_REGISTER
    LD      HL, $715E
    LD      (HL), 0E0H
    INC     HL
    LD      (HL), 0FFH
    XOR     A
    LD      ($71D5), A
    LD      A, 8
    LD      ($7195), A
    LD      A, 4
    LD      ($7191), A
    LD      HL, UNK_8E93
    LD      DE, $7148
    CALL    SUB_81C5
    LD      HL, UNK_8E9D
    LD      DE, $7149
    CALL    SUB_81C5
    LD      HL, $7192
    LD      A, (HL)
	SUB     10H
    LD      (HL), A
    LD      B, 3
    LD      HL, $71D9
    LD      A, ($7193)
	SUB     8
    LD      C, A
    ADD     A, 10H
    LD      D, A

LOC_8150:
    LD      (HL), C
    INC     HL
    LD      (HL), D
    INC     HL
    DJNZ    LOC_8150
    LD      HL, $71D9
    LD      DE, $7147
    CALL    SUB_81C5
    LD      A, ($7192)
	SUB     20H
    LD      ($71D8), A
    CALL    SUB_819D
    CALL    SUB_87F0

LOC_816D:
    CALL    SUB_81BA
    CALL    SUB_86FF
    CALL    SUB_825E
    CALL    SUB_87CD
    CALL    SUB_819D
    CALL    SUB_87F0
    CALL    PLAY_SPEECH
    JP      LOC_816D

LOC_8185:
    CALL    SUB_81BA
    CALL    SUB_86FF
    CALL    SUB_81D1
    CALL    SUB_87CD
    CALL    SUB_87F0
    CALL    SUB_819D
    CALL    PLAY_SPEECH
    JP      LOC_8185

SUB_819D:
    LD      A, ($71D8)
    LD      IX, $7146
    LD      (IX+0), A
    LD      (IX+4), A
    INC     A
    LD      (IX+10H), A
    LD      (IX+14H), A
    ADD     A, 0FH
    LD      (IX+8), A
    LD      (IX+0CH), A
RET

SUB_81BA:
    LD      HL, $7100

LOC_81BD:
    LD      A, (HL)
    CP      0
    JR      Z, LOC_81BD
    LD      (HL), 0
RET

SUB_81C5:
    LD      B, 6

LOC_81C7:
    LD      A, (HL)
    LD      (DE), A
    INC     HL
    INC     DE
    INC     DE
    INC     DE
    INC     DE
    DJNZ    LOC_81C7
RET

SUB_81D1:
    LD      HL, $7192
    LD      A, (HL)
    CP      0B7H
    JR      NC, LOC_8215
    INC     (HL)
    LD      A, (HL)
    CP      5FH
    JR      NC, LOC_81E6
    PUSH    AF
    INC     (HL)
    LD      HL, $71D8
    INC     (HL)
    POP     AF

LOC_81E6:
    JR      NZ, LOC_8215
    LD      HL, UNK_8E99
    LD      DE, $7149
    CALL    SUB_81C5
    LD      A, ($716F)
    AND     0FH
    LD      C, A
    LD      B, 0
    LD      HL, UNK_9336
    ADD     HL, BC
    LD      A, (HL)
    LD      IX, $7156
    LD      (IX+3), A
    LD      (IX+7), A
    LD      HL, $717A
    LD      (HL), 7
    XOR     A
    LD      ($7191), A
    INC     A
    LD      ($7195), A

LOC_8215:
    LD      HL, $71D8
    LD      A, (HL)
    CP      0B7H
    JR      NZ, LOC_824D
    POP     DE
    CALL    SUB_833F
    CALL    TURN_OFF_SOUND
    CALL    SUB_8791
    LD      BC, 604H
    CALL    WRITE_REGISTER
    XOR     A
    LD      ($7187), A
    LD      ($7183), A
    LD      A, 5
    LD      ($7185), A
    LD      HL, $7184
    LD      A, (HL)
    CP      18H
    JR      NC, LOC_8242
    INC     (HL)

LOC_8242:
    LD      DE, 0

LOC_8245:
    DEC     DE
    LD      A, E
    OR      D
    JR      NZ, LOC_8245
    JP      LOC_9F15

LOC_824D:
    INC     (HL)
    LD      A, (HL)
    LD      HL, $7175
    ADD     A, 38H
    CPL
    SRL     A
    SRL     A
    LD      (HL), A
    INC     HL
    LD      (HL), 40H
RET

SUB_825E:
    LD      HL, $7192
    LD      A, (HL)
    CP      58H
    JR      NZ, LOC_826A
    POP     DE
    JP      LOC_8185

LOC_826A:
    CP      5EH
    DEC     (HL)
    LD      HL, $71D8
    DEC     (HL)
    LD      A, (HL)
    SRL     A
    SRL     A
    LD      HL, $7175
    LD      (HL), A
    INC     HL
    LD      (HL), 40H
RET

LOC_827E:
    CALL    SUB_9DE5

LOC_8281:
    LD      BC, 180H
    CALL    WRITE_REGISTER
    CALL    CONTROLLER_SCAN
    CALL    SUB_9BF7
    CALL    READ_REGISTER
    CALL    TURN_OFF_SOUND
    CALL    SETUP_REGISTERS
    CALL    SUB_9BED
    LD      HL, UNK_8E84
    LD      DE, $7080
    LD      BC, 0FH
    LDIR
    LD      B, 3
    LD      HL, UNK_8E78
    CALL    SOUND_INIT
    LD      B, 3

LOC_82AE:
    PUSH    BC
    CALL    PLAY_IT
    POP     BC
    DJNZ    LOC_82AE
    LD      A, 8
    LD      ($7186), A
    LD      A, R
    OR      1
    LD      ($716F), A
    LD      A, 5
    LD      ($7185), A
    LD      A, 3
    LD      ($717C), A
    CALL    SUB_830B
    CALL    SUB_86EE
    CALL    SUB_85FC
    CALL    SUB_8570
    CALL    SUB_870B
    CALL    SUB_8670
    XOR     A
    LD      ($718C), A
    LD      ($7189), A
    CPL
    LD      ($717D), A
    CALL    SUB_842C
    CALL    SUB_8564
    CALL    SUB_85DE
    LD      HL, $7100
    LD      (HL), 0
    LD      BC, 1E2H
    CALL    WRITE_REGISTER
    JP      LOC_9E69

SUB_82FF:
    LD      B, 4
    LD      E, A
    LD      D, 0

LOC_8304:
    SLA     E
	RL      D
    DJNZ    LOC_8304
RET

SUB_830B:
    LD      B, 6
    LD      HL, $71C2

LOC_8310:
    LD      (HL), 1FH
    INC     HL
    DJNZ    LOC_8310
    CALL    SUB_833F
    CALL    SUB_8791
    LD      A, 0E0H
    LD      ($715E), A
    LD      A, 0FFH
    LD      ($715F), A
    LD      A, 6EH
    LD      ($7192), A
    LD      A, 7CH
    LD      ($7193), A
    LD      A, 8
    LD      ($7195), A
    LD      HL, $7185
    LD      A, (HL)
    CP      35H
RET     C
    LD      A, 34H
    LD      (HL), A
RET

SUB_833F:
    LD      HL, 0F000H
    LD      ($7175), HL
    LD      ($7177), HL
    LD      ($7179), HL
RET

SUB_834C:
    LD      A, ($71D2)
    OR      A
    JR      Z, LOC_8383
    LD      HL, $71D3
    LD      A, (HL)
    OR      A
    JR      Z, LOC_8366
    LD      A, ($7164)
    AND     0FH
    CP      0
    JR      Z, LOC_837F
    RES     7, (HL)
    JR      LOC_837F


LOC_8366:
    LD      A, ($7164)
    AND     0FH
    CP      0
    JR      NZ, LOC_837F
    XOR     A
    LD      ($71D2), A
    LD      ($71C9), A
    SET     7, (HL)
    LD      BC, 1E2H
    CALL    WRITE_REGISTER
RET

LOC_837F:
    POP     DE
    JP      LOC_9F98

LOC_8383:
    LD      HL, $71D3
    LD      A, (HL)
    OR      A
    JR      Z, LOC_8395
    LD      A, ($7164)
    AND     0FH
    CP      0
	RET     Z
    RES     7, (HL)
RET

LOC_8395:
    LD      A, ($7164)
    AND     0FH
    CP      0
	RET     NZ
    SET     7, (HL)
    LD      HL, $71D2
    SET     7, (HL)
RET

LOC_83A5:
    CP      1
    JR      Z, LOC_83E3
    DEC     (HL)
    LD      A, 1
    CP      (HL)
    JP      NZ, LOC_9F98
    LD      HL, $717E
    LD      DE, $717F
    LD      BC, 73H
    LD      (HL), 0
    LDIR
    LD      HL, $717C
    LD      (HL), 3
    LD      A, ($716F)
    AND     0FH
    LD      ($7184), A
    LD      A, 5
    LD      ($7185), A
    LD      A, 8
    LD      ($7186), A
    CALL    SUB_830B
    LD      BC, 1E2H
    CALL    WRITE_REGISTER
    CALL    SUB_833F
    JP      LOC_9F98

LOC_83E3:
    LD      HL, $7163
    LD      (HL), 0FEH
    PUSH    HL
    LD      A, ($7171)
    AND     3FH
    JR      NZ, LOC_8417
    LD      A, ($716F)
    LD      (HL), A
    AND     0FH
    LD      C, A
    LD      B, 0
    LD      IX, UNK_9336
    ADD     IX, BC
    LD      A, (IX+0)
    PUSH    AF
    ADD     A, 2
    RLCA
    RLCA
    RLCA
    RLCA
    AND     0F0H
    LD      C, A
    POP     AF
    OR      C
    LD      HL, 0C00H
    LD      DE, 4
    CALL    FILL_VRAM

LOC_8417:
    POP     HL
    INC     HL
    LD      A, 0F0H
    OR      (HL)
    LD      (HL), A
    CALL    SUB_887E
    CALL    SUB_8D4E
    CALL    SUB_8F63
    CALL    SUB_833F
    JP      LOC_9F98

SUB_842C:
    LD      HL, $7189
    BIT     0, (HL)
    JR      NZ, LOC_8448
    SET     0, (HL)
    LD      A, 5
    LD      ($718A), A
    LD      A, 4
    LD      ($718B), A
    LD      A, ($7185)
    DEC     A
    LD      ($718D), A
    JR      LOC_84C6

LOC_8448:
    LD      A, ($718C)
    CP      8
    JR      NZ, LOC_8460
    BIT     1, (HL)
	RET     NZ
    SET     1, (HL)
    LD      A, 6
    LD      ($718A), A
    LD      A, 1
    LD      ($718B), A
    JR      LOC_84C0

LOC_8460:
    CP      10H
    JR      NZ, LOC_8475
    BIT     2, (HL)
	RET     NZ
    SET     2, (HL)
    LD      A, 6
    LD      ($718A), A
    LD      A, 2
    LD      ($718B), A
    JR      LOC_84C0


LOC_8475:
    CP      18H
	RET     NZ
    BIT     3, (HL)
	RET     NZ
    SET     3, (HL)
    LD      A, 6
    LD      ($718A), A
    LD      A, 3
    LD      ($718B), A
    JR      LOC_84C0

UNK_8489:
	DB  3EH, 38H, 3BH, 36H, 33H, 3DH, 3DH, 3AH, 35H, 32H, 3DH, 3DH, 3AH, 35H, 32H, 3FH, 3CH, 39H, 34H, 31H

UNK_849D:
	DB  3EH, 38H, 38H, 36H, 33H, 42H, 42H, 42H, 2BH, 29H, 41H, 41H, 41H, 41H, 41H

UNK_84AC:
	DB  3DH, 3DH, 3DH, 3DH, 3DH, 3DH, 3DH, 3DH, 3DH, 3DH, 3DH, 3DH, 3DH, 3DH, 3DH, 3DH, 3DH, 3DH, 3DH, 3DH

LOC_84C0:
    LD      A, ($7185)
    LD      ($718D), A

LOC_84C6:
    LD      IY, $71C1
    LD      B, 0
    LD      HL, $718A
    LD      C, (HL)
    ADD     IY, BC
    LD      DE, 464H

LOC_84D5:
    PUSH    DE
    LD      HL, $718B
    LD      A, (HL)
    OR      A
    JR      NZ, LOC_84E8
    DEC     IY
    LD      HL, $718D
    DEC     (HL)
    LD      HL, $718B
    LD      (HL), 4

LOC_84E8:
    LD      B, (HL)
    LD      DE, 5
    LD      A, ($718D)
    CP      36H
    JR      C, LOC_8501
    JR      NZ, LOC_84FB
    LD      IX, UNK_849D
    JR      LOC_8509

LOC_84FB:
    LD      IX, UNK_84AC
    JR      LOC_8509

LOC_8501:
    LD      IX, UNK_8489
    JR      LOC_8509

LOC_8507:
    ADD     IX, DE

LOC_8509:
    DJNZ    LOC_8507
    LD      HL, $71D9
    LD      D, (IX+0)
    LD      E, (IX+1)
    LD      A, (IX+4)
    LD      (HL), A
    LD      A, (IX+3)
    INC     HL
    LD      (HL), A
    INC     HL
    LD      (HL), D
    LD      B, 5
    LD      C, (IY+0)

LOC_8524:
    INC     HL
    LD      (HL), D
    LD      A, E
    SRL     C
    JR      NC, LOC_852E
    LD      A, (IX+2)

LOC_852E:
    INC     HL
    LD      (HL), A
    INC     HL
    LD      (HL), D
    INC     HL
    LD      (HL), D
    DJNZ    LOC_8524
    LD      A, (IX+4)
    INC     HL
    LD      (HL), A
    LD      A, (IX+3)
    INC     HL
    LD      (HL), A
    POP     DE
    PUSH    DE
    PUSH    IY
    LD      BC, 19H
    LD      HL, $71D9
    CALL    WRITE_VRAM
    POP     IY
    LD      HL, $718B
    DEC     (HL)
    POP     DE
    LD      HL, 20H
    ADD     HL, DE
    PUSH    HL
    POP     DE
    OR      A
    LD      BC, 6E4H
	SBC     HL, BC
    JP      NZ, LOC_84D5
RET

SUB_8564:
    LD      A, ($718C)
    AND     7
    LD      C, A
    LD      B, 4
    CALL    WRITE_REGISTER
RET

SUB_8570:
    LD      DE, 0
    LD      ($718D), DE
    LD      BC, 240H
    LD      HL, $718F
    LD      (HL), 8

LOC_857F:
    LD      HL, PATTERNS_06
    PUSH    HL
    PUSH    BC
    PUSH    DE
    CALL    WRITE_VRAM
    POP     HL
    POP     BC
    ADD     HL, BC
    DEC     H
    POP     DE
    EX      DE, HL
    PUSH    BC
    LD      BC, 140H
    ADD     HL, BC
    LD      BC, 100H
    CALL    WRITE_VRAM
    POP     BC
    INC     BC
    LD      HL, 718EH
    LD      A, 8
    ADD     A, (HL)
    LD      (HL), A
    LD      DE, ($718D)
    LD      HL, $718F
    DEC     (HL)
    JR      NZ, LOC_857F
RET

SETUP_REGISTERS:
    LD      BC, 0
    CALL    WRITE_REGISTER
    LD      BC, 201H
    CALL    WRITE_REGISTER
    LD      BC, 330H
    CALL    WRITE_REGISTER
    LD      BC, 400H
    CALL    WRITE_REGISTER
    LD      BC, 528H
    CALL    WRITE_REGISTER
    LD      BC, 605H
    CALL    WRITE_REGISTER
    LD      BC, 700H
    CALL    WRITE_REGISTER
    LD      BC, 180H
    CALL    WRITE_REGISTER
RET

SUB_85DE:
    LD      A, ($717D)
    CP      1
    JR      Z, LOC_85F0
    LD      HL, $7165
    LD      BC, 9
    LD      DE, 0C00H
    JR      LOC_85F9

LOC_85F0:
    LD      HL, $7169
    LD      BC, 5
    LD      DE, 0C04H

LOC_85F9:
    JP      WRITE_VRAM

SUB_85FC:
    LD      HL, BYTE_99A0
    LD      DE, $7165
    LD      BC, 0AH
    LDIR
RET

SUB_8608:
    LD      DE, 1BH
    JP      FILL_VRAM

SUB_860E:
    LD      A, ($717D)
    OR      A
    JR      NZ, LOC_8636
    LD      DE, $71D9
    LD      HL, $7180
    LD      B, 3
    XOR     A

LOC_861D:
	RLD
    LD      (DE), A
    INC     DE
	RLD
    LD      (DE), A
    INC     DE
	RLD
    INC     HL
    DJNZ    LOC_861D
    LD      HL, $71D9
    LD      DE, 437H
    LD      BC, 6
    CALL    WRITE_VRAM

LOC_8636:
    LD      DE, 6E9H
    LD      HL, UNK_8E35
    LD      A, ($717C)
    OR      A
    JP      M, LOC_864A
    CP      0BH
    JR      NC, LOC_864A
    CALL    SUB_8653

LOC_864A:
    LD      DE, 6FBH
    LD      HL, UNK_8E36
    LD      A, ($7184)

SUB_8653:
    LD      C, A
    LD      B, 0
    ADD     HL, BC
    LD      A, (HL)
    LD      HL, $718D
    LD      (HL), A
    LD      BC, $71D9
    XOR     A
                RLD
    LD      (BC), A
    INC     BC
                RLD
    LD      (BC), A
    LD      HL, $71D9
    LD      BC, 2
    JP      WRITE_VRAM

SUB_8670:
    LD      HL, 400H
    LD      DE, 300H
    LD      A, 3DH
    CALL    FILL_VRAM
    LD      HL, 403H
    LD      A, 10H
    CALL    SUB_8608
    LD      HL, 443H
    LD      A, 11H
    CALL    SUB_8608
    LD      HL, 423H
    LD      A, 0AH
    CALL    SUB_8608
    LD      HL, 6E3H
    LD      A, 0AH
    CALL    SUB_8608
    LD      HL, BYTE_9993
    LD      DE, 424H
    LD      BC, 0DH
    CALL    WRITE_VRAM
    LD      HL, UNK_8E30
    LD      DE, 6F5H
    LD      BC, 5
    CALL    WRITE_VRAM
    LD      HL, 6E7H
    LD      DE, 1
    LD      A, 13H
    CALL    FILL_VRAM
    LD      B, 3
    XOR     A
    LD      HL, $7180

LOC_86C4:
    LD      (HL), A
    INC     HL
    DJNZ    LOC_86C4
    CALL    SUB_860E
RET

SUB_86CC:
    LD      HL, $7171
    INC     (HL)
    JR      NZ, LOC_86E0
    LD      IX, $71C9
    INC     (IX+0)
    JP      P, LOC_86E0
    LD      (IX+0), 0FEH

LOC_86E0:
    LD      A, (HL)
    AND     8
	RRA
	RRA
	RRA
    OR      4
    LD      C, A
    LD      B, 6
    JP      WRITE_REGISTER

SUB_86EE:
    LD      HL, UNK_934F
    LD      DE, $7106
    LD      BC, 40H
    LDIR
    LD      A, 0D0H
    LD      ($7162), A
RET

SUB_86FF:
    LD      HL, $7106
    LD      DE, 1400H
    LD      BC, 5DH
    JP      WRITE_VRAM

SUB_870B:
    LD      HL, PATTERNS_04
    LD      DE, 1A40H
    LD      BC, 440H
    CALL    WRITE_VRAM
    LD      HL, BYTE_8EA3
    LD      DE, 1D80H
    LD      BC, 0C0H
    CALL    WRITE_VRAM
    LD      HL, PATTERNS_04
    LD      DE, 2240H
    LD      BC, 6C0H
    CALL    WRITE_VRAM
    LD      HL, PATTERNS_04
    LD      DE, 2A40H
    LD      BC, 440H
    CALL    WRITE_VRAM
    LD      HL, PATTERNS_05
    LD      DE, 2D80H
    LD      ($718D), DE

LOC_8745:
    PUSH    HL
    LD      DE, 10H
    ADD     HL, DE
    LD      IX, $71D9
    CALL    SUB_877D
    POP     HL
    CALL    SUB_877D
    LD      DE, 10H
    ADD     HL, DE
    PUSH    HL
    LD      HL, $71D9
    LD      DE, ($718D)
    LD      BC, 20H
    CALL    WRITE_VRAM
    LD      HL, ($718D)
    LD      DE, 20H
    ADD     HL, DE
    LD      ($718D), HL
    POP     HL
    PUSH    HL
    LD      DE, BYTE_9993
    OR      A
	SBC     HL, DE
    POP     HL
    JR      C, LOC_8745
RET

SUB_877D:
    LD      D, 10H

LOC_877F:
    LD      B, 8
    LD      C, (HL)

LOC_8782:
    SLA     C
	RRA
    DJNZ    LOC_8782
    LD      (IX+0), A
    INC     IX
    INC     HL
    DEC     D
    JR      NZ, LOC_877F
RET

SUB_8791:
    LD      IX, $7198
    LD      A, 50H
    LD      B, 6

LOC_8799:
    LD      (IX+6), 0FFH
    LD      (IX+0), A
    LD      (IX+12H), 0
    INC     IX
	SUB     10H
    DJNZ    LOC_8799
RET

SUB_87AB:
    LD      HL, $7146
    LD      B, 6
    LD      IX, $7198

LOC_87B4:
    LD      A, (IX+0)
    LD      (HL), A
    INC     HL
    LD      A, (IX+6)
    LD      (HL), A
    INC     HL
    LD      A, (IX+0CH)
    LD      (HL), A
    INC     HL
    LD      A, (IX+12H)
    LD      (HL), A
    INC     HL
    INC     IX
    DJNZ    LOC_87B4
RET

SUB_87CD:
    LD      A, ($7192)
    LD      ($7136), A
    INC     A
    LD      ($713A), A
    ADD     A, 10H
    LD      ($713E), A
    DEC     A
    LD      ($7142), A
    LD      A, ($7193)
    LD      ($7137), A
    LD      ($713B), A
    LD      ($713F), A
    LD      ($7143), A
RET

SUB_87F0:
    LD      A, ($7195)
    LD      HL, $7191
    ADD     A, (HL)
    LD      C, A
    LD      HL, $71D4
    CP      8
    JR      NZ, LOC_881F
    INC     (HL)
    LD      A, (HL)
    AND     7FH
    JR      NZ, LOC_8818
    LD      HL, $71D6
    LD      (HL), 9
    LD      A, ($716F)
    AND     3
    ADD     A, 5
    LD      ($71D5), A
    ADD     A, C
    LD      C, A
    JR      LOC_8825

LOC_8818:
    LD      A, ($71D5)
    ADD     A, C
    LD      C, A
    JR      LOC_8825

LOC_881F:
    LD      (HL), 0
    XOR     A
    LD      ($71D5), A

LOC_8825:
    LD      HL, UNK_938F
    LD      B, 0
    ADD     HL, BC
    LD      A, (HL)
    LD      ($7138), A
    LD      C, 11H
    ADD     HL, BC
    LD      A, (HL)
    LD      ($713C), A
    ADD     HL, BC
    LD      A, (HL)
    LD      ($7140), A
    ADD     HL, BC
    LD      A, (HL)
    LD      ($7144), A
RET

SUB_8841:
    LD      HL, 0
    CALL    DECODER
    LD      A, H
    OR      L
    CPL
    PUSH    AF
    LD      HL, 100H
    CALL    DECODER
    LD      A, H
    OR      L
    CPL
    POP     BC
    AND     B
    LD      ($7163), A
    LD      HL, 101H
    CALL    DECODER
    LD      A, H
    XOR     0F0H
    OR      L
    PUSH    AF
    LD      HL, 1
    CALL    DECODER
    LD      A, H
    XOR     0F0H
    OR      L
    POP     HL
    AND     H
    LD      ($7164), A
    LD      A, D
    CP      0CFH
    JR      NZ, LOCRET_887D
    LD      A, 5
    LD      ($717C), A

LOCRET_887D:
RET

SUB_887E:
    LD      A, ($7196)
    BIT     0, A
    JR      Z, LOC_8888
    JP      LOC_8A51

LOC_8888:
    LD      HL, $71CA
    LD      A, (HL)
    OR      A
    JP      P, LOC_8891
    INC     (HL)

LOC_8891:
    LD      A, ($71CF)
    BIT     5, A
    JP      Z, LOC_89B5
    LD      A, ($715E)
    CP      62H
    JR      C, SCORING
    CP      7EH
    JR      NC, SCORING
    LD      HL, $715F
    LD      A, ($7193)
	SUB     0EH
    CP      (HL)
    JR      NC, SCORING
    ADD     A, 1CH
    CP      (HL)
    JR      C, SCORING
    LD      A, 0AH
    LD      ($71CC), A
    CALL    PLAY_SOME_SOUND_01
    JP      LOC_8984

SCORING:
    LD      A, ($7196)
    BIT     4, A
    JP      NZ, LOC_89B5
    LD      A, ($718C)
    OR      A
    JR      Z, LOC_88D5
    LD      DE, 2
    CALL    SUB_899B
    JR      NC, LOC_88DE

LOC_88D5:
    LD      DE, 1
    CALL    SUB_899B
    JP      C, LOC_89B5

LOC_88DE:
    LD      HL, $71B6
    ADD     HL, DE
    LD      A, (HL)
    AND     0FH
    CP      4
    JR      NZ, LOC_892B
    LD      A, ($7185)
    CP      35H
    JR      C, LOC_890A
    CALL    PLAY_SOME_SOUND_05
    LD      A, 88H
    LD      ($717F), A
    LD      HL, $7181
    LD      A, (HL)
    ADD     A, 10H
	DAA
    LD      (HL), A
    DEC     HL
    LD      A, (HL)
	ADC     A, 0
	DAA
    LD      (HL), A
    POP     DE
    JP      LOC_80EC

LOC_890A:
    LD      HL, $719E
    ADD     HL, DE
    LD      A, 0FFH
    LD      (HL), A
    XOR     A
    LD      HL, $71AA
    ADD     HL, DE
    LD      (HL), A
    LD      A, 1FH
    LD      ($717E), A
    LD      HL, $717C
    BIT     7, (HL)
    JR      NZ, LOC_8924
    INC     (HL)

LOC_8924:
    CALL    PLAY_SOME_SOUND_06
    POP     DE
    JP      LOC_9F98

LOC_892B:
    LD      HL, $71B6
    ADD     HL, DE
    BIT     6, (HL)
    JR      NZ, LOC_8981
    BIT     7, (HL)
    JP      NZ, LOC_89B5
    LD      A, ($71CA)
    OR      A
    JP      P, LOC_8981
    SET     7, (HL)
    LD      HL, $71A4
    ADD     HL, DE
    LD      B, (HL)
    LD      A, 0ECH
    LD      (HL), A
    XOR     A
    LD      ($71CA), A
    LD      HL, 71B0H
    ADD     HL, DE
    LD      (HL), B
    LD      A, 10H
    LD      ($71CB), A
    LD      A, 28H
    LD      ($71D7), A
    LD      A, ($7184)
    LD      C, A
    LD      B, 0
    LD      HL, BYTE_92D6
    ADD     HL, BC
    LD      A, (HL)
    ADD     A, 18H
    LD      HL, $71BC
    ADD     HL, DE
    LD      (HL), A
    CALL    PLAY_SOME_SOUND_03
    LD      HL, $7181
    LD      A, (HL)
    ADD     A, 1
	DAA
    LD      (HL), A
    DEC     HL
    LD      A, (HL)
	ADC     A, 0
	DAA
    LD      (HL), A
    JR      LOC_89B5

LOC_8981:
    CALL    PLAY_SOME_SOUND_02

LOC_8984:
    LD      A, 1
    LD      ($7196), A
    LD      A, 9
    LD      ($7195), A
    LD      A, 4
    LD      ($7171), A
    XOR     A
    LD      ($71D0), A
    LD      ($7191), A
RET

SUB_899B:
    LD      HL, $7198
    ADD     HL, DE
    LD      A, (HL)
    CP      62H
	RET     C
    LD      HL, $719E
    ADD     HL, DE
    LD      A, ($7193)
	SUB     0EH
    CP      (HL)
    JR      C, LOC_89B1
	SCF
RET

LOC_89B1:
    ADD     A, 1CH
    CP      (HL)
RET

LOC_89B5:
    LD      A, ($7196)
    BIT     7, A
    JR      Z, LOC_89BF
    JP      LOC_8BDC

LOC_89BF:
    BIT     6, A
    JR      Z, LOC_89C6
    JP      LOC_8B50

LOC_89C6:
    BIT     5, A
    JR      Z, LOC_89CD
    JP      LOC_8AA7

LOC_89CD:
    BIT     4, A
    JR      Z, LOC_89D4
    JP      LOC_8A11

LOC_89D4:
    LD      HL, $7190
    LD      A, ($7164)
    LD      IX, $7163
    AND     (IX+0)
    BIT     7, (HL)
    JR      Z, LOC_89ED
    BIT     6, A
    JR      Z, LOC_8A3A
    RES     7, (HL)
    JR      LOC_8A3A

LOC_89ED:
    BIT     6, A
    JR      NZ, LOC_8A3A
    SET     7, (HL)
    XOR     A
    LD      ($71C8), A
    LD      ($71C9), A
    LD      ($71D5), A
    LD      HL, $7196
    SET     4, (HL)
    LD      A, 1FH
    LD      ($7197), A
    LD      A, 4
    LD      ($7191), A

LOC_8A0C:
    CALL    SUB_8B35
    JR      LOC_8A3A

LOC_8A11:
    LD      HL, $7197
    DEC     (HL)
    JP      P, LOC_8A0C

LOC_8A18:
    LD      HL, $7196
    RES     4, (HL)
    XOR     A
    LD      ($7191), A
    LD      A, 0FAH
    LD      ($71CA), A
    LD      A, ($71C8)
    OR      A
	RET     Z
    LD      HL, $7181
    LD      A, (HL)
    ADD     A, 2
	DAA
    LD      (HL), A
    DEC     HL
    LD      A, (HL)
	ADC     A, 0
	DAA
    LD      (HL), A
RET

LOC_8A3A:
    LD      A, ($7163)
    BIT     1, A
    JR      NZ, LOC_8A44
    JP      LOC_8B5E

LOC_8A44:
    BIT     3, A
    JR      NZ, LOC_8A4B
    JP      LOC_8AB6

LOC_8A4B:
    BIT     0, A
	RET     NZ
    JP      LOC_8BA3


LOC_8A51:
    LD      HL, $71D0
    LD      A, (HL)
    OR      A
    JR      Z, LOC_8A81
    DEC     (HL)
	RET     NZ
    POP     DE
    LD      HL, $717C
    DEC     (HL)
    JP      P, LOC_8A79
    LD      A, ($717D)
    CP      1
    JR      Z, LOC_8A71
    LD      A, 78H
    LD      ($717E), A
    CALL    SUB_8E10

LOC_8A71:
    LD      A, 0FFH
    LD      ($717D), A
    JP      LOC_9F98

LOC_8A79:
    LD      A, 20H
    LD      ($717F), A
    JP      LOC_9F15

LOC_8A81:
    LD      HL, $7192
    INC     (HL)
    LD      A, (HL)
    CP      0B7H
    JR      C, LOC_8A8F
    LD      A, 80H
    LD      ($71D0), A

LOC_8A8F:
    LD      HL, $7171
    LD      A, (HL)
    AND     8
	RRA
	RRA
    OR      9
    LD      ($7195), A
    LD      A, (HL)
    AND     7FH
    LD      HL, $7175
    LD      (HL), A
    INC     HL
    LD      (HL), 40H
RET

LOC_8AA7:
    LD      HL, $7193
    LD      A, ($7194)
    CP      (HL)
    JR      NZ, LOC_8AB3
    JP      LOC_8ACA


LOC_8AB3:
    DEC     (HL)
    JR      LOC_8AF7

LOC_8AB6:
    XOR     A
    LD      ($71C9), A
    LD      A, ($7193)
    CP      3CH
	RET     Z
    LD      HL, $7196
    SET     5, (HL)
    LD      A, 4
    LD      ($7195), A

LOC_8ACA:
    LD      HL, $7195
    DEC     (HL)
    JP      P, LOC_8ADD
    LD      HL, $7196
    RES     5, (HL)
    LD      A, 8
    LD      ($7195), A
    JR      LOC_8AF7


LOC_8ADD:
    LD      A, ($7193)
	SUB     8
    LD      ($7194), A

LOC_8AE5:
    LD      HL, 934BH
    LD      A, ($7195)
    LD      C, A
    LD      B, 0
    ADD     HL, BC
    LD      A, (HL)
    LD      HL, $7175
    LD      (HL), A
    INC     HL
    LD      (HL), 40H

LOC_8AF7:
    LD      A, ($7196)
    BIT     4, A
    JR      NZ, LOC_8B2E
    LD      HL, $7190
    LD      A, ($7164)
    LD      IX, $7163
    AND     (IX+0)
    BIT     7, (HL)
    JR      Z, LOC_8B15
    BIT     6, A
	RET     Z
    RES     7, (HL)
RET

LOC_8B15:
    BIT     6, A
	RET     NZ
    SET     7, (HL)
    XOR     A
    LD      ($71C8), A
    LD      HL, $7196
    SET     4, (HL)
    LD      A, 1FH
    LD      ($7197), A
    LD      A, 4
    LD      ($7191), A
RET

LOC_8B2E:
    LD      HL, $7197
    DEC     (HL)
    JP      M, LOC_8A18

SUB_8B35:
    LD      A, ($7197)
    ADD     A, 2
    SRL     A
    LD      HL, $7175
    LD      (HL), A
    INC     HL
    LD      (HL), 40H
    LD      A, ($7193)
    LD      HL, $719F
    CP      (HL)
	RET     NZ
    LD      HL, 71C8H
    INC     (HL)
RET

LOC_8B50:
    LD      HL, $7193
    LD      A, ($7194)
    CP      (HL)
    JR      NZ, LOC_8B5B
    JR      LOC_8B72

LOC_8B5B:
    INC     (HL)
    JR      LOC_8AF7

LOC_8B5E:
    XOR     A
    LD      ($71C9), A
    LD      A, ($7193)
    CP      0BCH
	RET     Z
    LD      HL, $7196
    SET     6, (HL)
    LD      A, 4
    LD      ($7195), A

LOC_8B72:
    LD      HL, $7195
    DEC     (HL)
    JP      P, LOC_8B86
    LD      HL, $7196
    RES     6, (HL)
    LD      A, 8
    LD      ($7195), A
    JP      LOC_8AF7

LOC_8B86:
    LD      A, ($7193)
    ADD     A, 8
    LD      ($7194), A
    JP      LOC_8AE5

SUB_8B91:
    LD      HL, $7198
    LD      B, 6

LOC_8B96:
    INC     (HL)
    INC     HL
    DJNZ    LOC_8B96
    LD      HL, $715E
    LD      A, (HL)
    CP      0E0H
	RET     Z
    INC     (HL)
RET

LOC_8BA3:
    XOR     A
    LD      ($71C9), A
    LD      ($71D5), A
    LD      A, ($7193)
    AND     0E0H
    RRA
    RRA
    RRA
    RRA
    RRA
    LD      HL, UNK_9345
    LD      C, A
    LD      B, 0
    ADD     HL, BC
    LD      A, ($71C4)
    AND     (HL)
	RET     Z
    LD      A, 80H
    LD      ($7196), A
    LD      ($7197), A
    LD      HL, $7191
    LD      A, (HL)
    CP      4
    JR      NZ, LOC_8BD5
    LD      A, 0FAH
    LD      ($71CA), A

LOC_8BD5:
    XOR     A
    LD      (HL), A
    LD      A, 8
    LD      ($7195), A

LOC_8BDC:
    CALL    SUB_8B91
    LD      HL, $718C
    INC     (HL)
    LD      A, (HL)
    CP      8
    JR      NZ, LOC_8BF7
    LD      A, 9
    LD      ($7195), A
    LD      B, 8

LOC_8BEF:
    LD      HL, $7175
    LD      (HL), B
    INC     HL
    LD      (HL), 40H
RET

LOC_8BF7:
    CP      10H
    JR      NZ, LOC_8C05
    LD      A, 0AH
    LD      ($7195), A
    LD      B, 18H
    JP      LOC_8BEF

LOC_8C05:
    CP      18H
    JR      NZ, LOC_8C13
    LD      A, 0BH
    LD      ($7195), A
    LD      B, 8
    JP      LOC_8BEF

LOC_8C13:
    CP      20H
	RET     NZ
    XOR     A
    LD      ($7196), A
    LD      ($71C9), A
    LD      ($7189), A
    LD      ($718C), A
    LD      HL, $7199
    LD      DE, $7198
    LD      BC, 30H
    LDIR
    LD      A, ($716F)
    AND     7
    LD      HL, UNK_8D35
    LD      C, A
    LD      B, 0
    ADD     HL, BC
    LD      A, (HL)
    LD      ($71C7), A
    LD      HL, $7185
    INC     (HL)
    LD      A, (HL)
    CP      35H
    JR      C, LOC_8C64
    JR      NZ, LOC_8C50
    LD      A, 14H
    LD      ($71A9), A
    JR      LOC_8CCC

LOC_8C50:
    LD      A, 4
    LD      ($71BB), A
    LD      A, 0FFH
    LD      ($71A3), A
    XOR     A
    LD      ($71C7), A
    LD      ($71AF), A
    JP      LOC_8D0D

LOC_8C64:
    LD      HL, $7183
    INC     (HL)
    LD      A, (HL)
    AND     0FH
    JR      NZ, LOC_8CA9
    LD      HL, $717B
    INC     (HL)
    LD      A, (HL)
    AND     7
    LD      HL, UNK_92EF
    LD      C, A
    LD      B, 0
    ADD     HL, BC
    LD      A, (HL)
    LD      HL, $716A
    LD      (HL), A
    INC     HL
    LD      (HL), A
    LD      HL, UNK_92F7
    ADD     HL, BC
    LD      A, (HL)
    LD      ($716C), A
    LD      A, 70H
    LD      ($71CB), A
    XOR     A
    LD      ($71D7), A
    LD      HL, $7184
    LD      A, (HL)
    CP      18H
    JR      NC, LOC_8CA1
    INC     (HL)
    LD      A, (HL)
    CP      18H
    JR      C, LOC_8CB0

LOC_8CA1:
    LD      A, ($7170)
    AND     0FH
    LD      C, A
    JR      LOC_8CB1

LOC_8CA9:
    LD      A, ($7184)
    CP      18H
    JR      NC, LOC_8CA1

LOC_8CB0:
    LD      C, A

LOC_8CB1:
    LD      A, ($7183)
    CP      20H
    JR      C, LOC_8CDE
    XOR     A
    LD      ($7183), A
    LD      A, ($716F)
    AND     3
    LD      C, A
    LD      B, 0
    LD      HL, UNK_9332
    ADD     HL, BC
    LD      A, (HL)
    LD      ($71A9), A

LOC_8CCC:
    LD      A, ($716F)
    AND     3
    LD      C, A
    LD      HL, UNK_8E74
    ADD     HL, BC
    LD      A, (HL)
    LD      ($71A3), A
    LD      A, 4
    JR      LOC_8CFC

LOC_8CDE:
    LD      B, 0
    LD      HL, UNK_9319
    ADD     HL, BC
    LD      A, (HL)
    LD      ($71A9), A
    LD      A, ($716F)
    OR      1
    LD      ($71B5), A
    AND     97H
    ADD     A, 30H
    LD      ($71A3), A
    LD      HL, BYTE_92FF
    ADD     HL, BC
    LD      A, (HL)

LOC_8CFC:
    LD      ($71BB), A
    LD      A, ($716F)
    AND     0FH
    LD      HL, UNK_9336
    LD      C, A
    ADD     HL, BC
    LD      A, (HL)
    LD      ($71AF), A

LOC_8D0D:
    LD      A, 0FFH
    LD      ($719D), A
    LD      A, 1
    LD      ($71C1), A
    LD      HL, $7182
    LD      A, (HL)
    ADD     A, 10H
	DAA
    LD      (HL), A
    DEC     HL
    LD      A, (HL)
	ADC     A, 0
	DAA
    LD      (HL), A
    DEC     HL
    LD      A, (HL)
	ADC     A, 0
	DAA
    LD      (HL), A
    LD      A, 8
    LD      ($7195), A
    LD      B, 18H
    JP      LOC_8BEF

UNK_8D35:
	DB  15H
    DB  11H
    DB  1BH
    DB  0AH
    DB  0EH
    DB    4
    DB  15H
    DB  0AH

SUB_8D3D:
    LD      HL, $7170
    LD      A, (HL)
    SRL     A
    LD      A, ($716F)
	RRA
    XOR     (HL)
    DEC     HL
    LD      B, (HL)
    LD      (HL), A
    INC     HL
    LD      (HL), B
RET

SUB_8D4E:
    LD      HL, $7186
    DEC     (HL)
	RET     P
    LD      A, ($7184)
    LD      C, A
    LD      B, 0
    LD      HL, BYTE_92D6
    ADD     HL, BC
    LD      A, (HL)
    LD      ($7186), A
    LD      BC, 6

LOC_8D64:
    LD      HL, $71B5
    ADD     HL, BC
    LD      A, (HL)
    OR      A
    JP      P, LOC_8D72
    CALL    SUB_8DE1
    JR      LOC_8D84

LOC_8D72:
    AND     0FH
    SLA     A
    LD      E, A
    LD      D, 0
    LD      HL, BYTE_92CC
    ADD     HL, DE
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    EX      DE, HL
    CALL    SUB_8D88

LOC_8D84:
    DEC     C
    JR      NZ, LOC_8D64
RET

SUB_8D88:
    LD      ($71F2), HL
    JP      (HL)

    DB  21H
    DB 0AFH
    DB  71H
    DB    9
    DB  35H
    DB  7EH
    DB 0E6H
    DB  3FH
    DB  20H
    DB  0DH
    DB  7EH
    DB 0EEH
    DB  80H
    DB  57H
    DB  3AH
    DB  6FH
    DB  71H
    DB 0E6H
    DB  3FH
    DB 0F6H
    DB    1
    DB 0B2H
    DB  77H
    DB  7EH
    DB 0B7H
    DB 0F2H
    DB 0B7H
    DB  8DH
    DB  21H
    DB  9DH
    DB  71H
    DB    9
    DB  35H
    DB  7EH
    DB 0FEH
    DB  30H
    DB 0D0H
    DB  21H
    DB 0AFH
    DB  71H
    DB    9
    DB  18H
    DB 0DFH
    DB  21H
    DB  9DH
    DB  71H
    DB    9
    DB  34H
    DB  7EH
    DB 0FEH
    DB 0C8H
    DB 0D8H
    DB  18H
    DB 0EFH
    DB  21H
    DB 0AFH
    DB  71H
    DB    9
    DB  7EH
    DB 0B7H
    DB 0F2H
    DB 0B7H
    DB  8DH
    DB  18H
    DB 0DBH
    DB  21H
    DB 0BBH
    DB  71H
    DB    9
    DB  35H
    DB 0F0H
    DB  36H
    DB    1
    DB  3AH
    DB  93H
    DB  71H
    DB  21H
    DB  9DH
    DB  71H
    DB    9
    DB 0BEH
    DB  38H
    DB 0C9H
    DB  18H
    DB 0D6H

SUB_8DE1:
    LD      HL, $71BB
    ADD     HL, BC
    DEC     (HL)
	RET     P
    LD      HL, $71AF
    ADD     HL, BC
    LD      A, (HL)
    PUSH    HL
    LD      HL, $71A3
    ADD     HL, BC
    LD      (HL), A
    LD      A, ($716F)
    POP     HL
    LD      (HL), A
    LD      A, 0FH
    LD      HL, $71A9
    ADD     HL, BC
    LD      (HL), A
    LD      HL, $71B5
    ADD     HL, BC
    RES     7, (HL)
    SET     6, (HL)
    LD      A, 0BH
    LD      ($71CB), A
    XOR     A
    LD      ($71D7), A
RET

SUB_8E10:
    CALL    SUB_8791
    LD      HL, 54BH
    CALL    SUB_8E28
    LD      HL, UNK_8E4F
    LD      DE, 56BH
    LD      BC, 0BH
    CALL    WRITE_VRAM
    LD      HL, 58BH

SUB_8E28:
    LD      DE, 0BH
    LD      A, 24H
    JP      FILL_VRAM

UNK_8E30:
	DB  1CH, 1AH, 1DH, 1AH, 1EH

UNK_8E35:
	DB  0AH

UNK_8E36:
	DB  1AH, 2AH, 3AH, 4AH, 5AH, 6AH, 7AH, 8AH, 9AH, 10H, 11H, 12H, 13H, 14H, 15H, 16H, 17H, 18H, 19H, 20H, 21H, 22H, 23H, 24H, 25H

UNK_8E4F:
	DB  24H, 20H, 21H, 22H, 23H, 24H, 25H, 26H, 23H, 27H, 24H

UNK_8E5A:
	DB  0FH, 35H, 10H, 9, 4BH, 7, 14H, 2BH, 8

UNK_8E63:
	DB  0BH, 9, 0BH, 10H, 0F0H, 0BH, 10H, 0BH, 9, 0BH, 10H, 0BH, 6, 0F0H, 1, 0F0H, 4

UNK_8E74:
	DB  4CH, 6CH, 8CH, 0ACH

UNK_8E78:
	DB  80H, 70H, 8FH, 70H, 85H, 70H, 99H, 70H, 8AH, 70H, 0A3H, 70H

UNK_8E84:
	DB  40H, 0, 0F0H, 1, 18H, 80H, 0, 0F0H, 1, 18H, 0, 0, 0F0H, 1, 18H

UNK_8E93:
	DB 0B0H, 0B4H, 0B8H, 0BCH, 0C0H, 0C4H

UNK_8E99:
	DB  0FH, 0FH, 0FH, 0FH

UNK_8E9D:
	DB    0, 0, 0, 0, 0, 0

BYTE_8EA3:
	DB 000,000,000,001,002,004,008,016
    DB 017,032,032,064,065,064,128,158
    DB 007,056,064,128,000,000,000,193
    DB 002,194,035,034,194,000,000,060
    DB 224,028,002,001,000,000,000,132
    DB 070,069,196,068,068,000,000,060
    DB 000,000,000,128,064,032,016,072
    DB 200,068,068,066,066,002,001,121
    DB 161,192,128,064,032,016,008,004
    DB 002,001,000,000,000,000,000,000
    DB 065,128,064,064,032,032,032,016
    DB 016,016,136,072,040,020,012,007
    DB 065,128,129,129,130,130,130,132
    DB 132,132,137,138,140,152,144,240
    DB 069,131,001,002,004,008,016,032
    DB 064,128,000,000,000,000,000,000
    DB 000,000,000,001,003,007,015,031
    DB 031,063,063,127,127,127,255,224
    DB 007,063,127,255,255,255,255,255
    DB 255,255,255,255,255,255,255,128
    DB 224,252,254,255,255,255,255,255
    DB 255,255,255,255,255,255,255,128
    DB 000,000,000,128,192,224,240,248
    DB 248,252,252,254,254,254,255,130

SUB_8F63:
    LD      HL, $7187
    BIT     7, (HL)
	RET     Z
    JP      LOC_8FA1

SUB_8F6C:
    LD      HL, $7187
    BIT     7, (HL)
	RET     NZ
    SET     7, (HL)
    LD      A, ($7184)
    SLA     A
    LD      C, A
    LD      B, 0
    LD      A, 2CH
    LD      ($7160), A
    LD      HL, PATTERNS_02
    ADD     HL, BC
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    EX      DE, HL
    PUSH    HL
    LD      DE, 2160H
    LD      BC, 20H
    CALL    WRITE_VRAM
    POP     HL
    LD      BC, 120H
    ADD     HL, BC
    LD      DE, 2960H
    LD      BC, 20H
    JP      WRITE_VRAM

LOC_8FA1:
    LD      A, ($7184)
    CP      2
	RET     C
    LD      A, ($715E)
    CP      0E0H
    JR      Z, LOC_8FDF
    LD      A, ($71CC)
    OR      A
    JR      Z, LOC_8FC5
    LD      HL, $71CC
    DEC     (HL)
    LD      HL, $715F
    LD      A, ($7193)
    CP      (HL)
    JR      C, LOC_8FC3
    DEC     (HL)
RET

LOC_8FC3:
    INC     (HL)
RET

LOC_8FC5:
    LD      HL, $715E
    INC     (HL)
    LD      HL, $71CE
    LD      A, (HL)
    OR      A
	RET     Z
    LD      A, (HL)
    INC     (HL)
    SRL     A
    SRL     A
    SRL     A
    LD      HL, $7177
    LD      (HL), A
    INC     HL
    LD      (HL), 80H
RET


LOC_8FDF:
    LD      A, ($7185)
    CP      36H
	RET     NC
    LD      HL, $71CD
    DEC     (HL)
	RET     NZ
    PUSH    HL
    LD      A, ($7184)
    LD      HL, UNK_9001
    LD      C, A
    LD      B, 0
    ADD     HL, BC
    LD      A, (HL)
    POP     HL
    LD      (HL), A
    LD      A, ($7196)
    AND     61H
    JR      Z, LOC_901A
    INC     (HL)
RET

UNK_9001:
	DB    0
    DB 0F4H
    DB 0E8H
    DB 0DCH
    DB 0D0H
    DB 0C4H
    DB 0B8H
    DB 0ACH
    DB 0A0H
    DB  94H
    DB  88H
    DB  7CH
    DB  70H
    DB  64H
    DB  58H
    DB  50H
    DB  4AH
    DB  44H
    DB  3EH
    DB  38H
    DB  32H
    DB  2CH
    DB  26H
    DB  20H
    DB  1AH

LOC_901A:
    LD      A, ($7193)
    LD      ($715F), A
    LD      A, 50H
    LD      ($71CE), A
    XOR     A
    LD      ($715E), A
    LD      A, ($7170)
    AND     0FH
    LD      C, A
    LD      B, 0
    LD      HL, UNK_9336
    ADD     HL, BC
    LD      A, (HL)
    LD      ($7161), A
RET

PATTERNS_02:
	DB 108,144,108,144,108,144,140,144
    DB 140,144,140,144,172,144,172,144
    DB 172,144,204,144,204,144,204,144
    DB 236,144,236,144,236,144,108,145
    DB 108,145,108,145,044,145,044,145
    DB 044,145,076,145,076,145,076,145
    DB 012,145,000,000,000,000,000,000
    DB 000,000,000,015,063,000,254,254
    DB 254,254,000,000,000,000,000,000
    DB 000,000,000,192,048,240,240,240
    DB 192,000,000,000,000,030,061,123
    DB 122,244,244,245,247,247,123,122
    DB 061,030,000,000,000,224,208,136
    DB 216,220,124,244,196,100,104,056
    DB 112,224,000,000,000,000,000,000
    DB 024,057,057,014,015,007,003,000
    DB 000,000,000,006,014,030,060,120
    DB 240,224,192,000,000,096,192,000
    DB 000,000,255,064,191,191,176,176
    DB 176,176,176,176,176,191,188,182
    DB 190,127,254,001,255,255,003,003
    DB 099,027,003,003,003,255,075,211
    DB 219,255,127,194,159,159,158,159
    DB 192,255,111,103,063,007,001,063
    DB 055,056,254,067,249,249,121,249
    DB 003,255,254,254,252,224,192,064
    DB 192,000,003,005,005,027,059,015
    DB 031,037,090,090,037,031,015,015
    DB 062,063,192,224,240,248,252,240
    DB 248,244,242,242,244,248,240,240
    DB 012,252,028,026,007,015,031,032
    DB 063,035,049,017,017,024,024,008
    DB 015,015,000,000,000,160,096,224
    DB 224,240,240,248,248,248,248,240
    DB 224,192,064,224,224,113,126,079
    DB 119,203,015,013,007,006,007,003
    DB 001,000,000,000,224,224,240,248
    DB 252,250,239,255,255,241,161,227
    DB 254,248,000,000,018,072,002,036
    DB 000,016,064,001,007,031,111,247
    DB 244,112,000,028,034,129,001,001
    DB 002,004,104,240,240,240,192,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,254,254,254,254,000
    DB 063,015,000,000,000,000,000,000
    DB 000,000,000,000,192,240,240,240
    DB 048,192,000,000,000,030,061,122
    DB 123,247,247,245,244,244,122,123
    DB 061,030,000,000,000,224,048,120
    DB 104,100,196,244,124,220,216,200
    DB 144,208,000,112,120,060,030,015
    DB 007,003,001,000,000,003,003,001
    DB 000,000,000,000,000,000,000,016
    DB 152,136,184,112,112,224,128,128
    DB 000,000,255,064,191,191,176,176
    DB 176,176,176,176,176,191,188,182
    DB 190,127,254,001,255,255,003,003
    DB 027,099,003,003,003,255,075,211
    DB 219,255,127,194,159,159,158,159
    DB 192,255,111,103,063,007,001,063
    DB 055,056,254,067,249,249,121,249
    DB 003,255,254,254,252,224,192,064
    DB 192,000,003,006,014,029,061,015
    DB 015,018,045,045,018,015,015,015
    DB 063,063,192,224,240,248,252,240
    DB 240,248,116,116,248,240,240,240
    DB 012,252,028,026,007,015,031,032
    DB 063,062,063,031,031,031,031,015
    DB 015,015,000,000,000,160,096,160
    DB 032,016,016,024,008,024,056,240
    DB 224,192,032,096,096,097,095,111
    DB 119,059,015,013,007,006,007,003
    DB 001,000,000,000,224,224,240,248
    DB 252,250,239,255,255,255,179,255
    DB 254,248,000,000,000,001,016,000
    DB 000,000,032,001,007,031,111,247
    DB 244,112,000,028,034,001,001,001
    DB 002,004,104,240,240,240,192,000
    DB 000,000

BYTE_92AC:
	DB  0DH, 0DH, 0EH, 0EH, 0FH, 0FH, 10H, 10H, 11H, 11H, 12H, 12H, 13H, 13H, 14H, 14H, 13H, 13H, 12H, 12H, 11H, 11H, 10H, 10H, 0FH, 0FH, 0EH, 0EH, 0DH, 0DH, 0CH, 0CH

BYTE_92CC:
	DB  87H, 8DH,0C2H, 8DH, 8CH, 8DH,0CDH, 8DH, 87H, 8DH

BYTE_92D6:
	DB    8,   7,   7,   6,   6,   5,   5,   4,   4,   3,   3,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2

UNK_92EF:
	DB  6FH
    DB  4FH
    DB 0CFH
    DB 0AFH
    DB  8FH
    DB  5FH
    DB  2FH
    DB  3FH

UNK_92F7:
	DB  90H
    DB  50H
    DB  30H
    DB  80H
    DB  30H
    DB  60H
    DB  40H
    DB  70H
BYTE_92FF:
	DB    1,   1,   1,   2,   2,   2,   2,   3,   3,   2,   3,   2,   2,   3,   3,   2,   3,   2,   3,   2,   3,   2,   3,   2,   3,   2

UNK_9319:
	DB 0B0H
    DB 0B4H
    DB 0B8H
    DB 0BCH
    DB 0C0H
    DB 0C4H
    DB 0C8H
    DB 0CCH
    DB 0D0H
    DB 0D4H
    DB 0D8H
    DB 0DCH
    DB 0E0H
    DB 0E4H
    DB 0E8H
    DB 0DCH
    DB 0DCH
    DB 0DCH
    DB 0DCH
    DB 0DCH
    DB 0DCH
    DB 0DCH
    DB 0DCH
    DB 0DCH
    DB 0DCH

UNK_9332:
	DB 0F0H
    DB 0F4H
    DB 0F8H
    DB 0FCH

UNK_9336:
	DB    2
    DB    3
    DB    4
    DB    5
    DB    6
    DB    7
    DB    8
    DB    9
    DB  0AH
    DB  0BH
    DB  0CH
    DB  0DH
    DB    3
    DB    5
    DB    9

UNK_9345:
	DB  0DH
    DB    1
    DB    2
    DB    4
    DB    8
    DB  10H
    DB  10H
    DB  0AH
    DB  10H
    DB  0DH

UNK_934F:
	DB 0F6H
    DB 0DFH
    DB    0
    DB    0
    DB 0F6H
    DB 0EFH
    DB    0
    DB    0
    DB 0F6H
    DB    0
    DB    0
    DB    0
    DB 0F6H
    DB  10H
    DB    0
    DB    0
    DB    6
    DB 0DFH
    DB    0
    DB    0
    DB    6
    DB 0EFH
    DB    0
    DB    0
    DB    6
    DB    0
    DB    0
    DB    0
    DB    6
    DB  10H
    DB    0
    DB    0
    DB 0B6H
    DB 0DFH
    DB    0
    DB    0
    DB 0B6H
    DB 0EFH
    DB    0
    DB    0
    DB 0B6H
    DB    0
    DB    0
    DB    0
    DB 0B6H
    DB  10H
    DB    0
    DB    0
    DB  6FH
    DB  7CH
    DB  50H
    DB  0BH
    DB  6FH
    DB  7CH
    DB  54H
    DB    4
    DB  7FH
    DB  7CH
    DB  58H
    DB  0EH
    DB  7FH
    DB  7CH
    DB  5CH
    DB    5

UNK_938F:
	DB 0A0H
    DB  90H
    DB 0A0H
    DB  90H
    DB 0A0H
    DB  90H
    DB 0A0H
    DB  90H
    DB  50H
    DB  60H
    DB  70H
    DB  80H
    DB 0A0H
    DB  50H
    DB 0A0H
    DB  50H
    DB  50H
    DB 0A4H
    DB  94H
    DB 0A4H
    DB  94H
    DB 0A4H
    DB  94H
    DB 0A4H
    DB  94H
    DB  54H
    DB  64H
    DB  74H
    DB  84H
    DB 0A4H
    DB  54H
    DB 0A4H
    DB  54H
    DB  54H
    DB 0A8H
    DB  98H
    DB 0A8H
    DB  98H
    DB  48H
    DB  48H
    DB  48H
    DB  48H
    DB  58H
    DB  68H
    DB  78H
    DB  88H
    DB  48H
    DB  68H
    DB 0A8H
    DB  98H
    DB  58H
    DB 0ACH
    DB  9CH
    DB 0ACH
    DB  9CH
    DB  4CH
    DB  4CH
    DB  4CH
    DB  4CH
    DB  5CH
    DB  6CH
    DB  7CH
    DB  8CH
    DB  4CH
    DB  6CH
    DB 0ACH
    DB  9CH
    DB  5CH

PATTERNS_04:
    DB 127,000,000,064,064,032,024,000
    DB 000,000,000,000,000,000,000,000
    DB 254,001,001,003,001,002,012,000
    DB 000,000,000,000,000,000,000,000
    DB 120,124,063,063,059,057,024,000
    DB 000,000,000,000,000,000,000,000
    DB 015,031,254,254,238,206,012,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,003
    DB 003,001,000,000,000,000,000,000
    DB 000,024,016,000,000,000,000,224
    DB 224,192,000,000,000,000,000,000
    DB 000,000,003,007,007,015,000,000
    DB 000,031,063,063,119,119,063,063
    DB 000,012,236,252,254,254,006,006
    DB 014,252,252,248,248,248,248,252
    DB 031,000,000,000,000,000,000,000
    DB 000,000,000,000,000,030,060,000
    DB 252,002,002,002,005,000,000,000
    DB 000,000,000,000,000,060,030,000
    DB 000,000,031,031,015,015,014,014
    DB 014,014,014,014,014,014,000,000
    DB 000,000,252,252,248,120,056,056
    DB 056,056,056,056,056,056,000,000
    DB 000,000,000,000,048,048,000,003
    DB 003,001,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,224
    DB 248,216,000,000,000,000,000,000
    DB 000,000,003,007,007,111,096,224
    DB 224,127,063,015,015,015,015,031
    DB 000,000,224,240,240,248,000,006
    DB 007,255,254,248,248,248,248,252
    DB 031,000,000,000,000,000,000,000
    DB 000,000,000,000,030,060,000,000
    DB 252,002,002,002,005,000,000,000
    DB 000,000,000,000,000,120,060,000
    DB 000,000,031,031,063,062,056,056
    DB 028,028,028,028,014,000,000,000
    DB 000,000,252,252,248,120,056,056
    DB 120,112,112,112,112,112,000,000
    DB 000,024,008,000,000,000,000,007
    DB 007,003,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,192
    DB 192,128,000,000,000,000,000,000
    DB 000,048,055,063,127,127,096,096
    DB 112,063,063,031,031,031,031,063
    DB 000,000,192,224,224,240,000,000
    DB 000,248,248,248,238,238,252,252
    DB 063,000,000,000,000,000,000,000
    DB 000,000,000,000,000,060,120,000
    DB 252,002,002,002,005,000,000,000
    DB 000,000,000,000,000,120,060,000
    DB 000,000,063,063,031,030,028,024
    DB 028,028,028,028,028,028,000,000
    DB 000,000,252,252,248,240,112,112
    DB 112,112,112,112,112,112,000,000
    DB 000,000,000,000,000,000,000,007
    DB 031,027,000,000,000,000,000,000
    DB 000,000,000,000,012,012,000,192
    DB 192,128,000,000,000,000,000,000
    DB 000,000,007,015,015,031,000,096
    DB 224,255,127,031,031,031,031,063
    DB 000,000,192,224,224,246,006,007
    DB 007,254,252,240,240,240,240,248
    DB 063,000,000,000,000,000,000,000
    DB 000,000,000,000,000,030,060,000
    DB 248,004,002,003,002,000,000,000
    DB 000,000,000,000,120,060,000,000
    DB 000,000,063,063,031,030,028,028
    DB 030,014,014,014,014,014,000,000
    DB 000,000,248,248,252,124,028,028
    DB 056,056,056,056,112,000,000,000
    DB 000,012,004,000,000,000,000,003
    DB 003,001,000,000,000,000,000,000
    DB 000,024,016,000,000,000,000,224
    DB 224,192,000,000,000,000,000,000
    DB 000,024,027,031,063,063,048,048
    DB 056,031,031,015,015,015,015,031
    DB 000,012,236,252,254,254,006,006
    DB 014,252,252,248,248,248,248,252
    DB 031,000,000,000,000,000,000,000
    DB 000,000,000,000,015,028,024,000
    DB 252,002,002,002,005,000,000,000
    DB 000,000,000,000,120,028,012,000
    DB 000,000,031,031,015,015,030,028
    DB 030,014,014,007,007,000,000,000
    DB 000,000,252,252,248,120,060,028
    DB 060,056,056,112,112,000,000,000
    DB 000,096,096,000,000,000,000,003
    DB 003,001,000,000,000,000,000,000
    DB 000,003,003,000,000,000,000,224
    DB 224,192,000,000,000,000,000,000
    DB 000,000,099,103,103,127,112,048
    DB 056,063,031,015,015,015,015,031
    DB 000,000,227,243,243,255,007,006
    DB 014,254,252,248,248,248,248,252
    DB 031,000,000,000,000,000,000,000
    DB 000,000,000,000,030,060,000,000
    DB 252,004,003,002,000,000,000,000
    DB 000,000,000,000,060,030,000,000
    DB 000,000,031,031,015,031,062,056
    DB 060,028,028,014,014,000,000,000
    DB 000,000,252,252,248,252,062,014
    DB 030,028,028,056,056,000,000,000

PATTERNS_05:
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,051,207,003
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,192,204,243
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,003,012,063,195,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,192,048,240,204,003
    DB 000,000,000,000,000,000,000,000
    DB 000,015,060,207,240,255,012,048
    DB 000,000,000,000,000,000,000,000
    DB 000,240,252,243,015,255,048,192
    DB 000,000,000,000,000,000,000,000
    DB 048,015,063,255,252,063,012,015
    DB 000,000,000,000,000,000,000,000
    DB 048,240,252,207,015,252,048,060
    DB 000,000,000,000,000,000,000,240
    DB 012,003,015,063,051,243,243,063
    DB 000,000,000,000,000,000,000,012
    DB 051,192,240,204,204,207,255,252
    DB 000,000,000,000,000,000,000,015
    DB 063,243,195,255,063,015,063,204
    DB 000,000,000,000,000,000,000,192
    DB 240,060,012,252,192,000,252,000
    DB 000,000,000,000,000,000,000,000
    DB 000,012,012,003,063,255,195,192
    DB 000,000,000,000,000,000,000,000
    DB 000,048,204,195,255,252,192,000
    DB 000,000,000,000,000,000,000,015
    DB 015,063,012,012,063,255,195,243
    DB 000,000,000,000,000,000,000,192
    DB 048,240,000,000,252,255,012,207
    DB 000,000,000,000,000,000,000,000
    DB 015,063,063,060,015,063,051,195
    DB 000,000,000,000,000,000,000,000
    DB 240,252,060,252,048,252,048,012
    DB 000,000,000,000,000,000,000,003
    DB 012,015,195,255,063,015,015,255
    DB 000,000,000,000,000,000,000,240
    DB 204,252,240,255,243,240,240,192
    DB 000,000,000,000,000,000,000,000
    DB 000,000,015,063,255,255,204,204
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,192,240,255,204,204
    DB 000,000,000,000,000,000,000,000
    DB 000,003,012,012,003,051,207,003
    DB 000,000,000,000,000,000,000,000
    DB 000,192,240,240,192,192,204,243
    DB 000,000,000,000,000,000,000,000
    DB 012,003,003,015,063,204,255,063
    DB 000,000,000,000,000,000,000,000
    DB 000,000,192,048,252,204,255,252
    DB 000,000,000,000,000,000,000,003
    DB 063,207,243,063,003,051,204,000
    DB 000,000,000,000,000,000,000,192
    DB 252,063,207,252,192,192,060,003
    DB 000,000,000,000,000,000,000,003
    DB 060,015,003,003,015,051,195,051
    DB 000,000,000,000,000,000,000,192
    DB 060,048,195,204,240,192,192,048
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,015,240
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,204,252
    DB 000,000,000,000,000,000,000,000
    DB 000,015,015,015,063,060,063,000
    DB 000,000,000,000,000,000,000,000
    DB 000,192,255,243,255,252,252,252
    DB 000,000,000,000,000,000,000,000
    DB 015,063,063,063,015,003,015,063
    DB 000,000,000,000,000,000,000,000
    DB 240,012,012,012,048,192,240,252
    DB 000,000,000,000,000,000,000,000
    DB 000,192,048,003,000,015,060,255
    DB 000,000,000,000,000,000,000,000
    DB 000,192,012,048,000,240,060,255
    DB 000,000,000,000,000,000,000,003
    DB 255,003,063,240,192,195,240,063
    DB 000,000,000,000,000,000,000,255
    DB 192,192,252,015,195,003,015,252

BYTE_9993:
	DB  0BH, 0CH, 0DH, 0EH, 0FH, 18H, 19H, 1AH, 1BH, 0AH, 0BH, 1FH, 1BH

BYTE_99A0:
	DB 0F4H,0F4H, 74H,0F4H,0F1H, 6FH, 6FH, 90H,0F0H

PATTERNS_06:
    DB 000,127,065,065,067,067,067,127
    DB 000,004,004,004,012,012,012,012
    DB 000,127,065,001,127,096,096,127
    DB 000,126,066,002,063,003,067,127
    DB 000,066,066,066,127,006,006,006
    DB 000,127,064,064,127,003,067,127
    DB 000,127,065,064,127,067,067,127
    DB 000,063,001,001,003,003,003,003
    DB 000,062,034,034,127,067,067,127
    DB 000,127,065,065,127,003,003,003
    DB 000,000,000,000,000,000,000,000
    DB 000,120,132,128,120,004,132,120
    DB 000,000,000,120,132,180,204,122
    DB 000,000,000,136,136,136,136,116
    DB 000,000,000,248,032,032,032,248
    DB 000,000,000,120,128,112,008,240
    DB 255,255,000,255,000,000,255,000
    DB 000,255,000,000,255,000,255,255
    DB 000,000,000,000,000,000,000,000
    DB 000,024,024,126,090,060,036,036
    DB 000,003,004,004,007,015,059,041
    DB 108,108,238,238,238,239,238,255
    DB 000,128,064,120,228,228,226,194
    DB 001,033,001,015,113,143,112,128
    DB 000,128,128,128,240,136,136,136
    DB 000,096,112,016,032,000,000,000
    DB 000,000,000,120,132,248,128,124
    DB 000,000,000,168,084,084,084,084
    DB 000,128,128,128,128,128,128,252
    DB 000,000,000,132,132,132,072,048
    DB 000,016,016,016,016,016,016,016
    DB 000,000,000,112,008,056,072,052
    DB 120,128,128,128,156,132,132,120
    DB 000,000,000,120,004,124,132,124
    DB 000,000,000,168,084,084,084,084
    DB 000,000,000,120,132,248,128,124
    DB 000,000,000,000,000,000,000,000
    DB 120,132,132,132,132,132,132,120
    DB 000,000,000,132,132,132,072,048
    DB 000,000,000,152,180,224,192,192
    DB 000,000,000,000,000,000,000,000
    DB 127,127,127,000,254,254,254,000
    DB 000,000,000,000,000,000,000,000
    DB 254,254,254,000,127,127,127,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 255,255,255,255,255,255,255,000
    DB 127,127,127,000,254,254,254,000
    DB 127,127,127,000,254,254,254,000
    DB 255,255,255,255,255,255,255,000
    DB 254,254,254,000,127,127,127,000
    DB 254,254,254,000,127,127,127,000
    DB 255,255,255,255,255,255,255,000
    DB 000,000,000,000,000,000,000,000
    DB 255,193,193,217,217,193,193,255
    DB 000,098,098,098,098,098,098,098
    DB 098,098,098,098,098,098,098,098
    DB 255,193,193,217,217,193,193,255
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,255,255,000,000,000,255,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 255,255,255,255,255,255,255,255
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000

BYTE_9BC9:
	DB    0,   0,   0,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0B0H,0B0H,0D0H, 50H, 30H, 60H

SETUP_SCREEN:
    CALL    SUB_9BED
    CALL    MODE_1
    JP      LOAD_ASCII

SUB_9BED:
    LD      HL, 0
    LD      DE, 4000H
    XOR     A
    JP      FILL_VRAM

SUB_9BF7:
    LD      HL, $7000
    LD      DE, $7001
    LD      BC, 380H
    LD      (HL), 0
    LDIR
RET

SUB_9C05:
    LD      B, 6

LOC_9C07:
    LD      DE, 1000H

LOC_9C0A:
    PUSH    DE
    PUSH    BC
    CALL    SUB_8841
    POP     BC
    POP     DE
    LD      A, ($7164)
    AND     0FH
    CP      0AH
    JR      Z, LOC_9C22
    DEC     DE
    LD      A, D
    OR      E
    JR      NZ, LOC_9C0A
    DJNZ    LOC_9C07
RET

LOC_9C22:
    POP     DE
    JP      LOC_8281

START:
    CALL    TURN_OFF_SOUND
    CALL    SETUP_SCREEN
    LD      A, 50H
    LD      ($7340), A
    LD      IY, 1
    LD      A, 3
    LD      HL, UNK_9DB7
    LD      DE, 80H
    LD      B, 8

LOC_9C3F:
    PUSH    AF
    PUSH    BC
    PUSH    HL
    PUSH    IY
    PUSH    DE
    CALL    PUT_VRAM
    POP     DE
    LD      HL, 8
    ADD     HL, DE
    EX      DE, HL
    POP     IY
    POP     HL
    POP     BC
    POP     AF
    DJNZ    LOC_9C3F
    LD      HL, $7000
    LD      DE, $7001
    LD      BC, 0FH
    LD      (HL), 40H
    LDIR
    LD      HL, $7000
    LD      DE, 0
    LD      IY, 10H
    LD      A, 4
    CALL    PUT_VRAM
    LD      HL, $7000
    LD      DE, $7001
    LD      BC, 2FFH
    LD      (HL), 20H
    LDIR
    LD      IX, $7010
    LD      IY, $700E
    LD      B, 7
    LD      A, 80H

LOC_9C8A:
    DEC     IX
    DEC     IX
    INC     IY
    INC     IY
    CALL    SUB_9D4E
    DJNZ    LOC_9C8A
    LD      B, 0BH
    LD      DE, 40H

LOC_9C9C:
    ADD     IX, DE
    ADD     IY, DE
    CALL    SUB_9D4E
    DJNZ    LOC_9C9C
    LD      B, 6

LOC_9CA7:
    INC     IX
    INC     IX
    DEC     IY
    DEC     IY
    CALL    SUB_9D4E
    DJNZ    LOC_9CA7
    LD      HL, INTERPHASE_TXT
    LD      DE, $7086
    LD      BC, 15H
    LDIR
    LD      HL, PRESENTS_TXT
    LD      DE, $70CC
    LD      BC, 8
    LDIR
    LD      HL, SQUISHEM_TXT
    LD      DE, $7108
    LD      BC, 11H
    LDIR
    LD      HL, SIRIUS_1983_TXT
    LD      DE, $724A
    LD      BC, 0DH
    LDIR
    LD      HL, INTERP_1983_TXT
    LD      DE, $7208
    LD      BC, 11H
    LDIR
    LD      HL, $7000
    LD      DE, 0
    LD      IY, 300H
    CALL    SUB_9E48
    LD      BC, 1C0H
    CALL    WRITE_REGISTER
    LD      BC, 70EH
    CALL    WRITE_REGISTER
    LD      HL, UNK_9DBF
    LD      DE, $7000
    LD      BC, 8
    LDIR

LOC_9D0F:
    LD      HL, $7000
    LD      DE, 10H
    LD      IY, 8
    LD      A, 4
    CALL    PUT_VRAM
    LD      A, ($7007)
    LD      HL, $7006
    LD      DE, $7007
    LD      BC, 7
    LDDR
    LD      ($7000), A
    LD      HL, 2DH
    CALL    $196B
    LD      A, ($7340)
    DEC     A
    LD      ($7340), A
    JP      Z, LOC_9DC7
    CALL    SUB_8841
    LD      A, ($7164)
    AND     0FH
    CP      0AH
    JP      Z, LOC_9DC7
    JR      LOC_9D0F

SUB_9D4E:
    LD      (IX+0), A
    LD      (IY+0), A
    LD      (IX+1), A
    LD      (IY+1), A
    LD      (IX+20H), A
    LD      (IY+20H), A
    LD      (IX+21H), A
    LD      (IY+21H), A
    ADD     A, 8
    AND     0BFH
RET

INTERPHASE_TXT:
	DB  49H, 20H, 4EH, 20H, 54H, 20H, 45H, 20H, 52H, 20H, 50H, 20H, 48H, 20H, 41H, 20H, 53H, 20H, 45H, 1EH, 1FH

PRESENTS_TXT:
	DB  70H, 72H, 65H, 73H, 65H, 6EH, 74H, 73H

SQUISHEM_TXT:
	DB  53H, 51H, 55H, 49H, 53H, 48H, 20H, 27H, 45H, 4DH, 20H, 53H, 41H, 4DH, 21H, 1EH, 1FH

SIRIUS_1983_TXT:
	DB  1DH, 20H, 31H, 39H, 38H, 33H, 20H, 53H, 49H, 52H, 49H, 55H, 53H

INTERP_1983_TXT:
	DB  1DH, 20H, 31H, 39H, 38H, 33H, 20H, 49H, 4EH, 54H, 45H, 52H, 50H, 48H, 41H, 53H, 45H

UNK_9DB7:
	DB 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH

UNK_9DBF:
	DB  10H, 0C0H, 40H, 60H, 30H, 50H, 0A0H, 0F0H

LOC_9DC7:
    LD      BC, 180H
    CALL    WRITE_REGISTER
    CALL    SUB_9BF7
    CALL    SETUP_SCREEN
    LD      HL, BYTE_9BC9
    LD      DE, 0
    LD      IY, 1BH
    LD      A, 4
    CALL    PUT_VRAM
    JP      LOC_827E

SUB_9DE5:
    CALL    SETUP_SCREEN
    LD      HL, KEYS_USED_TXT
    LD      DE, 0A8H
    LD      IY, 11H
    CALL    SUB_9E48
    LD      HL, START_GAME_TXT
    LD      DE, 166H
    LD      IY, 0EH
    CALL    SUB_9E48
    LD      HL, SELECT_GAME_TXT
    LD      DE, 1A6H
    LD      IY, 16H
    CALL    SUB_9E48
    LD      HL, PAUSE_GAME_TXT
    LD      DE, 1E6H
    LD      IY, 0EH
    CALL    SUB_9E48
    LD      HL, $7100
    LD      DE, $7101
    LD      BC, 1FH
    LD      (HL), 0F0H
    LDIR
    LD      HL, $7100
    LD      DE, 0
    LD      IY, 20H
    LD      A, 4
    CALL    PUT_VRAM
    LD      BC, 1C0H
    CALL    WRITE_REGISTER
    CALL    SUB_9C05
    LD      BC, 180H
    CALL    WRITE_REGISTER
RET

SUB_9E48:
    LD      A, 2
    JP      PUT_VRAM

NMI:
    PUSH    AF
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IX
    PUSH    IY
    CALL    READ_REGISTER
    LD      ($71CF), A
    LD      HL, $7100
    INC     (HL)
    POP     IY
    POP     IX
    POP     HL
    POP     DE
    POP     BC
    POP     AF
RETN

LOC_9E69:
    CALL    SUB_81BA
    CALL    SUB_8564
    CALL    SUB_86CC
    CALL    SUB_86FF
    CALL    SUB_85DE
    CALL    SUB_8841
    CALL    SUB_8F6C
    CALL    SUB_8D3D
    LD      HL, $717E
    LD      A, (HL)
    OR      A
    JR      Z, LOC_9EB1
    DEC     (HL)
    LD      HL, $71D1
    LD      A, (HL)
    SLA     A
    SLA     A
    SLA     A
    SLA     A
    LD      ($717A), A
    LD      A, (HL)
    INC     (HL)
    INC     (HL)
    AND     0FH
    LD      C, A
    LD      B, 0
    LD      HL, UNK_9336
    ADD     HL, BC
    LD      A, (HL)
    LD      HL, 0C04H
    LD      DE, 1
    CALL    FILL_VRAM
    JP      LOC_9F98

LOC_9EB1:
    LD      A, ($7164)
    AND     0FH
    CP      0AH
    JR      NZ, LOC_9EE3
    LD      HL, $717C
    LD      DE, $717D
    LD      BC, 75H
    LD      (HL), 0
    LDIR
    LD      A, 60H
    LD      ($717F), A
    LD      A, ($7174)
    LD      ($7184), A
    LD      A, 3
    LD      ($717C), A
    LD      A, 5
    LD      ($7185), A
    LD      A, 8
    LD      ($7186), A
    JR      LOC_9F22

LOC_9EE3:
    LD      HL, $7188
    BIT     7, (HL)
    JR      Z, LOC_9EF7
    LD      A, ($7164)
    AND     0FH
    CP      0BH
    JR      Z, LOC_9F31
    RES     7, (HL)
    JR      LOC_9F31

LOC_9EF7:
    LD      A, ($7164)
    AND     0FH
    CP      0BH
    JR      NZ, LOC_9F31
    SET     7, (HL)
    LD      A, 0FFH
    LD      ($717D), A
    LD      HL, $7174
    INC     (HL)
    LD      A, (HL)
    CP      7
    JR      C, LOC_9F11
    XOR     A

LOC_9F11:
    LD      (HL), A
    LD      ($7184), A

LOC_9F15:
	LD      HL, $7189
	LD      DE, $718A
	LD      BC, 69H
	LD      (HL), 0
	LDIR

LOC_9F22:
    CALL    SUB_830B
    LD      BC, 1E2H
    CALL    WRITE_REGISTER
    CALL    SUB_833F
    JP      LOC_9F98

LOC_9F31:
    CALL    SUB_842C
    LD      HL, $717D
    LD      A, (HL)
    OR      A
    JR      Z, LOC_9F3E
    JP      LOC_83A5

LOC_9F3E:
    CALL    SUB_834C
    LD      A, ($7171)
    AND     1FH
    LD      C, A
    LD      B, 0
    LD      HL, BYTE_92AC
    ADD     HL, BC
    LD      A, (HL)
    LD      HL, $7177
    LD      (HL), A
    INC     HL
    LD      (HL), 0C0H
    CALL    SUB_887E
    CALL    SUB_8D4E
    CALL    SUB_8F63
    LD      HL, $71D6
    LD      A, (HL)
    OR      A
    JR      Z, LOC_9F75
    LD      C, A
    DEC     (HL)
    LD      B, 0
    LD      HL, UNK_8E5A
    ADD     HL, BC
    LD      A, (HL)
    LD      HL, $7175
    LD      (HL), A
    INC     HL
    LD      (HL), 0A0H

LOC_9F75:
    LD      HL, $71CB
    LD      A, (HL)
    OR      A
    JR      Z, LOC_9F95
    LD      A, ($71D7)
    ADD     A, (HL)
    DEC     (HL)
    AND     7FH
    LD      HL, $7177
    LD      (HL), A
    AND     0FH
    SLA     A
    SLA     A
    SLA     A
    SLA     A
    INC     HL
    LD      (HL), A
    JR      LOC_9F98

LOC_9F95:
    CALL    SUB_9FC2

LOC_9F98:
    LD      HL, $71C9
    BIT     7, (HL)
    JR      Z, LOC_9FAA
    LD      BC, 1A2H
    CALL    WRITE_REGISTER
    CALL    TURN_OFF_SOUND
    JR      LOC_9FB3

LOC_9FAA:
    LD      BC, 1E2H
    CALL    WRITE_REGISTER
    CALL    PLAY_SPEECH

LOC_9FB3:
    CALL    SUB_87CD
    CALL    SUB_87F0
    CALL    SUB_87AB
    CALL    SUB_860E
    JP      LOC_9E69

SUB_9FC2:
    LD      HL, $717F
    LD      A, (HL)
    OR      A
	RET     Z
    DEC     (HL)
    SRL     A
    SRL     A
    SRL     A
    LD      C, A
    LD      B, 0
    LD      HL, UNK_8E63
    ADD     HL, BC
    LD      A, (HL)
    LD      HL, $7177
    CP      0F0H
    JR      Z, LOC_9FF5
    LD      (HL), A
    PUSH    HL
    LD      HL, 0C02H
    LD      DE, 1
    LD      A, C
    ADD     A, 2
    RLCA
    RLCA
    RLCA
    RLCA
    OR      4
    CALL    FILL_VRAM
    POP     HL
    LD      A, 40H

LOC_9FF5:
    INC     HL
    LD      (HL), A
RET

PLAY_SPEECH:
    LD      HL, $7175
    LD      IX, $7080
    LD      A, (HL)
    CALL    SUB_82FF
    LD      (IX+1), E
    INC     HL
    LD      A, (HL)
    OR      D
    LD      (IX+2), A
    INC     HL
    LD      A, (HL)
    CALL    SUB_82FF
    LD      (IX+6), E
    INC     HL
    LD      A, (HL)
    OR      D
    LD      (IX+7), A
    INC     HL
    INC     HL
    LD      A, (HL)
    LD      (IX+0CH), A
    CALL    SUB_833F
    CALL    SOUND_MAN
    JP      PLAY_SONGS

PLAY_SOME_SOUND_01:
    CALL    SUB_A07F
    LD      HL, SOUND_DATA_01
    LD      C, 12H
    JP      SUB_A08F

PLAY_SOME_SOUND_02:
    CALL    SUB_A07F
    LD      HL, SOUND_DATA_02
    LD      C, 12H
    JP      SUB_A08F

PLAY_SOME_SOUND_03:
    CALL    SUB_A07F
    LD      A, R
    CP      20H
    JP      NC, PLAY_SOME_SOUND_04
    LD      HL, SOUND_DATA_03
    LD      C, 0CH
    JP      SUB_A08F

PLAY_SOME_SOUND_04:
    LD      HL, SOUND_DATA_06
    LD      C, 0CH
    JP      SUB_A08F

PLAY_SOME_SOUND_05:
    CALL    SUB_A07F
    LD      HL, SOUND_DATA_04
    LD      C, 10H
    CALL    SUB_A08F
    LD      HL, SOUND_DATA_04
    LD      C, 0DH
    CALL    SUB_A08F
    LD      HL, SOUND_DATA_04
    LD      C, 0AH
    JP      SUB_A08F

PLAY_SOME_SOUND_06:
    CALL    SUB_A07F
    LD      HL, SOUND_DATA_05
    LD      C, 0CH
    JP      SUB_A08F

SUB_A07F:
    EX      AF, AF'
    EXX
    POP     DE
    LD      HL, BYTE_A088
    PUSH    HL
    PUSH    DE
RET

BYTE_A088:
	DB 0D9H, 0AFH, 32H, 0, 71H, 8, 0C9H

SUB_A08F:
    LD      A, ($717D)
    CP      0
	RET     NZ
    LD      A, 80H
    OUT     (0FFH), A
    LD      A, 1
    OUT     (0FFH), A
    LD      A, 0A0H
    OUT     (0FFH), A
    LD      A, 1
    OUT     (0FFH), A
    LD      A, 0C0H
    OUT     (0FFH), A
    LD      A, 1
    OUT     (0FFH), A
    LD      A, 0FFH
    OUT     (0FFH), A

LOC_A0B1:
    LD      A, (HL)
    CP      0
    JP      Z, LOC_A0DB
    RRCA
    RRCA
    RRCA
    RRCA
    CALL    SUB_A0C5
    LD      A, (HL)
    CALL    SUB_A0C5
    INC     HL
    JR      LOC_A0B1

SUB_A0C5:
    AND     0FH
    DEC     A
    LD      B, A
    OR      90H
    OUT     (0FFH), A
    LD      A, B
    OR      0B0H
    OUT     (0FFH), A
    LD      A, B
    OR      0D0H
    OUT     (0FFH), A
    LD      B, C

SUB_A0D8:
    DJNZ    $
RET

LOC_A0DB:
    INC     HL
    LD      D, (HL)
    LD      A, D
    CP      0
	RET     Z

LOC_A0E1:
    LD      B, 30H
    CALL    SUB_A0D8
    DEC     D
    JR      NZ, LOC_A0E1
    INC     HL
    JR      LOC_A0B1

SOUND_DATA_01:
	DB 136,000,255,119,120,135,104,171,186,152,102,120,153,151,086,101,091,222,218,099,070,172,170,133,085,104,153,153,136,154,153,153
    DB 119,119,119,119,120,153,171,169,135,119,136,135,102,135,120,154,187,186,135,119,102,103,120,147,078,159,202,131,087,140,172,148
    DB 052,068,079,238,232,116,072,188,166,116,072,100,219,238,187,051,103,221,218,051,071,132,079,174,238,098,055,205,221,114,054,101
    DB 052,234,237,213,035,187,202,215,035,118,051,235,221,202,034,171,220,203,034,119,051,237,221,213,034,157,219,167,034,136,051,233
    DB 238,199,035,107,221,185,035,085,131,062,142,220,083,059,204,188,114,055,115,062,125,218,035,091,205,172,082,104,083,062,157,220
    DB 146,058,219,186,194,043,132,051,231,221,179,035,235,216,216,035,182,035,232,221,198,040,220,199,181,039,149,043,203,221,146,034
    DB 188,199,185,034,166,051,233,237,213,051,189,201,154,035,151,067,205,221,203,034,045,169,187,035,165,051,221,221,202,035,093,167
    DB 155,114,073,147,061,204,220,130,059,215,075,213,039,167,051,221,157,200,035,237,115,220,035,187,051,221,186,204,050,061,147,220
    DB 098,059,196,051,218,205,198,035,204,123,181,035,170,099,051,206,237,146,050,109,237,147,105,067,165,052,254,219,200,067,061,221
    DB 186,132,051,093,163,051,206,221,148,051,061,237,214,050,057,135,105,068,078,238,185,135,051,079,237,131,051,103,155,132,052,175
    DB 238,235,067,052,174,238,218,035,053,202,068,101,070,206,238,182,052,085,190,204,166,051,052,122,168,155,100,069,254,237,165,051
    DB 055,153,189,150,052,102,188,134,123,217,051,073,238,238,166,051,067,104,188,185,101,119,102,139,170,203,185,051,071,238,238,181
    DB 051,051,070,173,221,167,135,085,104,152,153,153,170,152,067,069,190,238,185,133,035,052,056,205,171,166,103,102,123,235,153,153
    DB 119,117,051,072,158,238,202,135,083,052,070,154,168,186,154,169,118,154,168,120,135,137,168,137,135,101,069,158,238,218,152,118
    DB 051,052,103,137,171,187,186,150,102,103,154,187,136,170,117,104,119,136,117,087,153,190,221,203,131,051,068,104,154,188,186,170
    DB 150,121,151,137,168,120,136,103,137,135,119,123,220,170,186,100,085,068,086,120,171,203,203,168,135,118,103,154,168,117,102,120
    DB 171,187,169,135,119,102,102,103,137,171,170,136,137,152,137,152,134,084,104,170,171,170,170,134,085,086,120,137,170,169,153,152
    DB 136,136,119,119,120,136,137,153,136,136,136,152,119,137,136,136,119,119,119,138,170,170,135,119,102,136,136,137,136,153,136,154
    DB 135,120,118,120,135,136,152,153,153,153,152,121,152,119,119,104,153,136,154,153,169,119,119,102,120,136,153,168,153,119,120,152
    DB 136,135,120,152,136,137,136,153,137,136,119,136,119,137,152,152,119,136,136,153,169,136,135,119,137,136,136,120,153,136,136,136
    DB 153,136,000,255,153,106,105,135,152,136,121,135,167,121,122,121,135,167,122,120,135,181,184,107,120,167,153,106,118,150,153,106
    DB 119,166,150,153,106,120,149,185,091,120,151,153,089,134,167,123,119,150,151,137,121,134,168,121,168,120,152,120,152,151,138,105
    DB 135,150,153,122,135,166,169,090,119,151,122,153,121,150,153,122,135,151,122,091,148,186,091,119,165,169,089,122,149,183,120,106
    DB 134,153,119,152,152,137,136,121,150,136,150,123,119,184,106,134,152,151,154,120,135,151,136,152,137,121,135,166,122,150,151,136
    DB 105,135,185,107,060,116,185,090,148,199,122,104,166,154,119,185,088,150,135,155,089,165,184,108,102,183,092,101,197,154,106,134
    DB 199,107,119,153,121,105,118,182,138,090,196,201,075,119,180,170,090,148,171,072,182,139,091,120,196,139,086,138,132,234,060,167
    DB 152,105,118,167,137,154,090,151,152,121,119,137,119,153,121,153,134,169,088,165,137,151,153,135,122,150,122,118,167,121,091,166
    DB 170,119,134,135,107,154,182,153,090,118,152,121,136,167,123,117,183,121,120,166,138,104,166,154,104,150,138,104,150,139,104,152
    DB 152,120,166,138,120,151,151,121,151,137,167,122,133,152,137,137,135,168,106,134,138,118,169,101,185,073,166,121,136,136,149,154
    DB 103,199,120,152,104,152,122,120,152,136,152,137,118,137,119,154,135,154,119,152,104,152,120,136,136,152,152,136,136,135,137,121
    DB 136,152,138,135,136,135,121,119,153,120,169,120,151,121,119,136,136,153,137,168,105,150,137,134,137,136,153,136,153,105,135,136
    DB 136,120,151,138,136,137,150,137,136,153,120,152,121,135,135,136,137,135,153,120,000,255,000,000

SOUND_DATA_02:
	DB 136,000,255,120,120,136,137,152,137,136,136,136,119,136,136,153,135,119,118,103,120,137,170,170,170,152,136,136,120,136,119,136
    DB 135,136,135,120,135,120,135,120,153,153,153,135,119,102,103,136,137,153,152,152,135,136,136,136,136,120,136,136,153,136,136,135
    DB 120,136,137,170,154,152,119,118,102,119,136,153,153,153,152,136,136,135,136,119,120,136,137,152,136,135,119,135,120,153,170,154
    DB 152,119,118,101,102,119,154,170,154,153,136,135,120,135,119,136,136,153,152,136,135,120,119,121,153,153,170,152,135,102,086,102
    DB 120,153,170,170,152,152,119,120,135,120,136,136,152,136,136,119,135,119,137,154,170,169,136,118,085,102,119,153,170,170,169,137
    DB 135,118,119,119,136,136,137,152,137,136,119,119,120,170,169,169,135,102,101,087,120,154,170,170,169,135,119,102,103,119,137,153
    DB 152,153,135,136,136,137,153,153,135,103,102,119,136,136,170,170,154,151,119,102,102,136,136,153,152,120,136,154,187,170,135,084
    DB 068,086,137,170,171,186,170,152,118,101,086,120,136,137,153,154,170,170,152,118,084,068,104,154,188,203,169,134,086,102,120,153
    DB 152,136,136,155,203,187,151,067,068,069,137,188,204,186,119,101,103,136,136,136,137,188,204,186,133,051,067,071,155,205,219,168
    DB 118,085,086,119,137,170,188,203,168,116,051,052,088,172,220,186,117,068,086,119,154,187,205,202,135,083,051,069,138,204,203,152
    DB 101,069,103,137,188,221,220,167,067,051,052,121,188,220,168,100,068,103,138,189,237,204,150,034,051,069,155,221,204,167,085,068
    DB 087,138,189,237,218,116,051,052,071,156,220,186,134,084,086,122,189,221,203,116,035,051,088,205,221,218,099,035,068,105,206,221
    DB 221,166,051,051,053,139,222,221,150,051,051,087,172,222,221,184,051,052,069,156,238,219,133,051,053,120,173,237,221,148,034,068
    DB 071,189,237,219,115,052,069,120,189,221,220,115,035,051,088,189,222,183,050,068,103,155,221,221,200,051,051,052,121,205,237,182
    DB 035,052,104,137,206,237,215,051,051,052,087,206,237,200,051,051,103,138,238,221,184,067,052,068,089,222,237,217,099,068,068,106
    DB 222,220,170,152,100,051,087,154,171,169,136,102,087,136,137,188,202,133,068,087,136,138,187,169,117,068,103,137,155,187,170,135
    DB 102,102,103,153,170,170,153,135,102,103,120,137,170,169,135,118,103,119,138,170,152,000,034,135,118,119,120,138,169,137,136,120
    DB 135,119,153,153,153,136,120,119,104,137,153,153,136,152,000,056,154,153,136,000,255,000,048,120,136,135,137,136,136,136,106,149
    DB 168,139,102,184,091,119,151,120,168,121,121,151,152,149,153,119,151,170,077,120,149,166,183,137,107,090,135,152,167,135,104,137
    DB 122,105,122,122,121,121,121,135,137,135,183,152,135,137,134,151,166,167,137,137,105,103,138,149,149,167,136,151,105,136,122,138
    DB 137,137,120,120,151,137,136,168,136,118,137,120,136,136,136,153,120,168,151,152,122,120,106,104,152,133,167,134,184,166,167,151
    DB 136,153,104,169,089,168,107,137,120,137,135,135,151,138,121,135,136,167,153,137,153,121,119,168,166,168,138,106,136,120,169,106
    DB 120,121,136,119,167,152,182,150,168,118,169,135,137,150,135,150,134,181,149,168,135,121,137,122,106,119,136,165,166,167,151,152
    DB 119,152,136,152,137,137,105,121,104,183,150,138,135,121,135,151,182,166,183,167,121,105,091,152,136,134,133,167,150,152,122,106
    DB 182,149,197,151,167,136,137,121,135,137,138,121,104,152,120,136,134,137,136,152,135,121,136,137,151,118,152,153,089,152,136,136
    DB 119,165,166,167,152,152,169,088,105,118,150,166,184,104,106,107,121,137,119,150,135,166,152,152,122,106,106,088,120,121,151,105
    DB 120,138,137,153,136,135,167,149,167,152,123,121,091,137,136,136,151,120,167,105,153,104,137,136,138,135,138,133,136,136,153,121
    DB 136,154,120,154,119,135,135,136,138,121,120,136,134,151,151,121,153,135,120,137,118,152,136,122,105,121,121,136,135,136,166,152
    DB 136,105,152,136,137,119,136,134,121,136,106,121,121,136,136,151,121,137,136,138,104,136,150,168,136,153,122,106,106,121,136,135
    DB 151,151,134,167,152,106,121,105,167,136,152,135,137,136,137,120,136,151,167,136,136,106,136,151,152,151,136,136,152,136,120,121
    DB 136,136,122,166,137,121,121,134,135,168,135,139,121,088,151,151,167,137,121,135,150,151,152,152,120,136,122,122,120,152,150,183
    DB 167,121,122,106,120,136,152,000,255,000,000

SOUND_DATA_03:
	DB 136,000,255,136,120,166,151,122,104,152,119,152,134,120,136,137,122,120,152,135,151,121,151,166,137,136,136,120,167,167,134,153
    DB 121,106,104,136,135,152,138,119,151,136,119,136,121,167,136,139,105,135,165,183,136,122,107,106,150,197,150,124,073,135,181,136
    DB 152,140,121,106,151,151,150,135,154,104,152,137,152,105,119,183,120,169,119,168,120,150,151,168,152,125,074,155,149,180,135,120
    DB 121,151,121,122,133,167,183,138,075,167,120,181,120,105,117,124,091,072,149,150,156,088,102,182,106,123,105,197,121,122,104,152
    DB 183,155,119,134,165,121,091,105,135,170,165,120,124,092,119,107,073,167,212,168,104,073,106,135,168,136,184,138,120,138,107,196
    DB 182,138,117,180,108,088,155,073,152,122,197,167,120,103,136,222,074,073,213,134,091,105,213,180,171,137,074,168,119,196,140,138
    DB 167,104,151,123,102,185,137,167,135,153,148,140,136,122,137,088,167,168,149,123,141,110,120,069,212,108,091,138,072,182,165,151
    DB 150,183,126,060,072,106,073,213,149,150,092,078,151,212,196,148,103,157,088,168,212,123,139,141,086,071,104,119,136,180,104,153
    DB 151,153,197,164,122,152,137,118,154,137,106,215,151,132,103,156,075,133,149,119,152,143,075,105,120,246,149,231,117,166,089,076
    DB 141,087,179,150,166,167,164,181,180,120,149,122,167,089,200,089,120,119,135,122,134,106,150,136,168,150,124,184,085,121,168,104
    DB 153,087,138,151,106,186,117,135,152,089,170,103,121,168,120,137,135,120,152,122,120,121,167,136,000,188,152,136,134,173,185,083
    DB 071,154,185,137,136,136,136,134,120,154,136,136,134,070,222,217,101,052,090,238,217,052,068,139,221,187,134,088,169,118,087,154
    DB 152,099,071,205,167,053,122,202,135,103,121,169,152,119,120,153,135,119,137,169,152,119,136,153,152,120,136,136,153,135,119,136
    DB 152,136,136,120,136,136,136,136,136,136,136,152,136,135,137,169,120,136,136,137,153,151,119,137,152,118,104,136,136,137,153,136
    DB 119,153,153,153,153,117,068,086,120,169,153,170,170,186,153,135,101,085,102,137,187,203,134,085,086,102,121,190,238,219,167,099
    DB 052,068,140,220,185,119,118,084,068,124,238,236,170,168,083,051,069,156,220,169,136,117,052,070,190,237,221,220,148,035,051,139
    DB 187,169,154,151,067,052,157,222,221,203,132,051,051,120,153,137,153,136,099,053,173,220,188,220,148,051,051,087,171,186,153,151
    DB 083,053,205,219,205,220,114,051,054,118,154,152,136,168,119,052,172,236,157,235,114,051,118,119,155,118,137,168,089,116,156,205
    DB 174,199,051,057,084,119,168,105,169,117,172,084,189,218,126,215,035,090,067,155,149,074,183,087,220,067,222,184,173,212,054,150
    DB 060,165,071,184,072,202,151,072,201,172,220,116,120,083,090,132,072,119,139,185,183,061,216,189,220,084,134,052,154,068,119,089
    DB 187,140,132,126,119,222,230,061,099,106,148,056,084,171,152,173,068,234,093,237,115,166,056,167,100,117,075,150,170,200,078,211
    DB 238,214,122,036,182,119,085,070,149,168,140,068,231,142,236,135,146,057,087,149,100,121,090,150,187,084,234,142,235,119,147,057
    DB 101,118,070,150,139,135,186,068,232,126,217,093,163,122,051,100,068,151,142,166,186,100,079,120,235,155,217,059,131,051,068,091
    DB 124,217,153,134,100,219,158,221,154,182,102,051,051,070,151,189,121,186,121,168,103,156,140,187,168,117,070,068,101,072,106,109
    DB 138,233,182,132,217,102,078,121,233,133,133,071,068,141,094,180,181,212,251,062,092,084,227,231,060,078,131,195,232,123,061,078
    DB 179,227,214,070,061,061,094,163,228,204,091,109,070,234,194,166,071,135,075,077,092,131,213,163,106,057,235,062,115,148,227,230
    DB 059,078,060,051,164,126,109,168,054,235,062,183,217,039,110,058,147,211,231,059,062,094,099,194,215,202,061,046,054,149,153,073
    DB 228,109,051,163,227,213,237,056,100,173,092,072,213,116,053,132,229,233,061,062,051,164,195,233,061,062,051,195,211,202,058,120
    DB 184,164,091,090,106,170,148,183,092,147,132,131,195,232,233,108,068,138,139,105,141,163,181,197,106,060,148,166,218,149,076,103
    DB 099,212,120,187,061,090,122,102,170,119,214,089,093,062,100,227,122,061,110,131,229,060,078,071,212,227,169,059,078,099,179,213
    DB 234,061,077,118,201,058,124,076,163,169,062,115,213,219,062,100,228,108,150,186,110,094,100,211,231,058,078,100,179,214,185,061
    DB 073,132,213,215,078,067,103,104,182,149,165,155,104,117,153,230,071,060,076,115,197,217,139,061,131,228,217,061,078,147,213,074
    DB 062,061,211,231,090,061,105,115,200,077,118,131,180,236,061,100,195,182,062,084,195,212,155,060,116,151,152,151,121,152,169,088
    DB 166,152,150,093,084,228,107,102,108,060,179,186,072,136,133,231,077,089,103,134,168,154,104,167,152,120,120,151,137,092,134,166
    DB 119,121,136,137,121,137,152,121,136,136,121,151,137,119,152,152,136,121,136,135,121,151,136,137,137,152,151,137,121,135,120,134
    DB 152,120,137,120,134,120,137,153,154,153,153,153,169,152,119,119,118,119,120,136,136,135,119,119,119,137,137,170,170,185,152,102
    DB 086,103,136,154,169,152,119,117,103,121,138,204,220,187,118,083,051,104,156,187,170,133,085,102,104,136,137,220,189,185,135,083
    DB 051,087,172,188,168,134,085,087,101,152,168,205,188,201,117,085,051,119,156,220,152,133,086,103,118,153,152,142,185,219,151,070
    DB 083,070,154,206,200,118,085,087,153,103,152,121,235,189,217,085,084,068,121,157,235,134,101,070,137,166,089,150,108,219,205,200
    DB 067,083,068,154,174,234,101,085,071,170,149,153,117,206,203,221,132,037,068,073,203,238,183,067,068,104,187,135,136,101,142,236
    DB 205,181,035,051,069,222,237,202,066,069,102,219,184,102,101,073,237,220,202,067,051,051,159,236,202,099,051,086,139,237,183,052
    DB 053,091,238,221,201,051,051,086,206,236,136,083,054,138,189,219,099,068,084,174,238,204,164,035,069,106,237,217,134,051,055,171
    DB 188,204,165,051,053,124,238,219,167,051,051,089,206,218,099,068,070,155,186,171,184,052,070,136,222,238,168,099,052,071,171,222
    DB 201,083,068,087,172,186,172,183,051,055,153,238,218,134,051,051,108,220,220,166,051,085,104,221,185,137,134,068,089,171,222,220
    DB 116,052,068,073,204,188,184,083,070,119,155,186,152,151,084,104,154,173,237,166,084,085,086,154,170,169,133,070,119,137,170,153
    DB 153,152,118,103,120,137,205,201,118,102,085,121,154,152,118,086,120,137,170,186,152,135,102,103,121,154,187,186,135,102,118,102
    DB 121,169,136,120,119,120,153,154,169,135,120,119,136,153,152,136,119,136,153,169,136,119,102,104,137,153,152,135,119,120,154,170
    DB 152,120,135,120,136,153,153,135,137,153,152,136,118,102,103,153,170,152,120,136,137,154,169,135,102,119,136,154,170,153,135,119
    DB 119,136,119,136,135,119,120,136,136,137,153,136,152,153,136,119,119,136,153,154,170,152,136,119,103,119,120,152,135,120,136,137
    DB 154,153,152,135,120,136,136,137,136,136,119,153,153,153,120,118,103,120,153,152,136,136,136,136,138,169,152,120,136,135,137,152
    DB 136,119,153,153,153,137,135,103,119,136,153,135,136,135,120,138,169,153,136,135,119,119,136,136,136,137,136,136,137,153,135,118
    DB 135,119,120,137,153,136,120,136,137,154,000,255,000,000

SOUND_DATA_04:
	DB 136,000,255,136,135,136,120,136,136,135,136,120,135,120,136,152,137,153,169,153,152,120,119,135,120,135,136,135,135,120,119,120
    DB 137,153,154,169,169,137,135,103,119,135,120,136,152,135,136,136,135,136,137,153,169,153,152,136,119,135,120,119,120,135,135,120
    DB 119,135,119,136,153,153,170,154,152,120,119,120,136,135,137,135,118,103,119,103,139,204,186,152,152,119,103,155,170,118,103,118
    DB 100,069,119,137,171,254,219,100,120,134,085,158,217,083,054,170,118,069,135,104,206,238,166,086,103,101,140,220,115,052,120,153
    DB 151,084,088,170,222,238,164,052,120,117,142,234,083,056,202,119,136,100,072,206,221,185,083,055,154,169,153,116,053,155,167,086
    DB 118,102,156,238,218,099,085,103,171,185,117,085,104,169,135,101,086,155,222,222,148,054,136,137,220,133,051,121,135,119,118,086
    DB 172,237,237,132,051,121,154,187,151,067,104,136,119,102,103,170,190,237,148,053,136,104,237,181,052,121,134,103,134,104,172,254
    DB 218,100,087,119,121,222,165,052,120,118,104,118,119,190,237,151,103,118,103,138,219,115,071,136,101,136,119,123,238,216,086,137
    DB 102,106,205,166,052,070,119,103,152,118,158,254,150,088,151,086,157,221,115,068,086,085,121,134,158,238,165,072,151,103,139,205
    DB 183,052,070,084,071,169,121,254,218,067,153,118,137,204,202,115,052,101,069,120,119,175,237,101,137,101,137,172,219,115,051,134
    DB 069,136,102,158,254,151,137,150,087,171,205,166,051,054,084,105,151,105,239,234,105,168,101,122,204,184,051,053,052,088,152,138
    DB 238,219,136,169,119,103,173,201,099,053,067,069,137,136,222,234,136,153,135,137,154,202,099,053,084,069,119,124,238,200,105,153
    DB 137,170,187,168,067,069,084,068,104,139,254,217,104,152,120,187,188,183,083,052,068,069,103,140,238,167,137,134,154,171,205,182
    DB 035,051,052,070,135,142,238,201,152,135,122,186,188,185,082,036,067,069,120,122,238,217,154,153,103,187,171,168,067,051,068,069
    DB 153,154,222,218,137,169,152,124,185,120,100,051,052,086,122,171,204,170,153,154,153,153,153,135,118,068,068,103,137,154,171,169
    DB 170,171,169,137,152,135,103,118,101,085,102,104,170,186,170,187,170,152,152,136,135,119,101,085,086,101,154,187,186,187,169,153
    DB 137,152,136,119,118,069,084,085,105,171,203,186,186,170,152,152,136,135,103,102,101,085,085,105,171,203,187,186,169,136,136,136
    DB 119,118,085,068,085,086,155,188,187,203,170,152,120,136,136,119,102,100,068,085,088,171,203,188,187,170,152,119,137,135,119,101
    DB 084,069,085,137,171,187,188,186,186,136,119,136,152,119,117,052,084,103,088,187,188,203,204,169,152,118,136,153,118,102,069,085
    DB 086,104,188,188,187,203,170,152,119,120,152,119,102,085,085,102,088,170,203,187,203,153,168,135,138,168,119,067,068,069,103,139
    DB 205,203,187,169,153,136,120,153,153,133,051,067,068,104,139,222,188,202,121,169,136,136,137,152,100,084,068,069,088,157,237,205
    DB 168,137,136,136,135,153,151,102,067,085,069,120,124,237,221,201,136,135,120,134,138,135,135,067,085,069,119,136,221,237,201,136
    DB 135,136,118,152,136,118,085,085,086,103,136,220,238,218,153,118,119,104,120,120,135,101,102,102,118,104,140,206,221,185,119,103
    DB 119,103,136,136,118,118,102,118,103,137,204,222,202,136,102,102,087,104,153,153,118,102,102,119,120,136,188,220,202,137,118,102
    DB 103,120,137,135,118,103,118,119,119,138,188,219,201,152,119,103,102,136,137,151,102,102,118,120,120,138,187,204,186,151,135,103
    DB 118,136,136,135,103,103,119,119,136,155,188,203,170,135,119,118,119,120,152,136,120,118,103,118,136,170,188,188,169,136,103,118
    DB 119,137,136,119,118,119,103,118,136,170,204,188,169,152,103,118,103,120,136,136,119,103,102,119,120,170,204,187,169,136,119,118
    DB 103,135,136,135,119,103,118,119,121,170,188,187,169,153,135,102,118,119,120,135,119,119,119,103,119,170,188,187,170,152,136,118
    DB 102,119,120,135,119,119,119,119,119,170,187,188,170,168,135,102,101,103,120,136,120,135,119,118,119,137,172,188,186,169,136,117
    DB 117,103,136,136,135,135,119,119,119,154,188,173,186,169,120,101,085,102,120,137,151,136,119,119,103,137,172,188,202,170,136,118
    DB 101,102,136,137,136,119,119,119,103,152,188,188,186,169,135,102,085,102,120,137,152,136,119,103,102,121,156,188,203,185,152,102
    DB 100,102,121,153,153,135,135,103,102,137,156,188,187,185,152,102,100,086,119,153,153,152,135,102,102,105,138,187,203,186,153,117
    DB 101,086,104,153,153,152,119,102,102,105,155,188,187,186,153,118,101,086,119,137,153,152,136,118,102,103,138,172,203,203,152,134
    DB 085,085,103,137,153,153,135,118,102,104,155,171,203,186,152,134,085,085,103,137,153,153,152,135,101,103,122,170,219,186,169,135
    DB 100,085,087,121,154,153,152,119,102,103,137,186,187,187,170,135,101,085,086,120,153,169,169,136,102,102,119,170,172,187,186,152
    DB 118,069,085,119,137,169,153,135,119,102,119,154,172,187,186,168,118,069,085,102,136,169,154,152,135,102,119,121,170,203,188,170
    DB 135,101,085,086,104,154,154,152,119,102,103,121,154,188,187,186,152,118,085,086,103,121,153,169,136,134,119,102,136,155,187,187
    DB 170,151,102,084,102,120,153,169,153,135,119,119,136,154,186,187,186,168,119,101,070,102,136,137,153,152,119,119,120,136,170,171
    DB 186,170,152,134,102,086,119,121,153,137,136,136,120,136,137,153,170,170,169,152,119,118,086,102,120,137,152,136,135,152,137,136
    DB 137,137,154,154,153,152,119,118,118,102,119,121,136,153,137,152,136,136,152,153,153,154,152,152,120,102,102,103,119,137,153,169
    DB 153,152,120,119,136,137,170,170,153,135,102,085,102,103,136,153,153,153,137,135,135,120,136,154,170,170,153,135,102,085,086,103
    DB 136,153,154,153,136,135,136,136,137,154,154,169,153,135,119,102,102,103,119,153,153,152,136,136,136,137,136,152,137,152,153,152
    DB 152,120,119,103,118,119,120,136,153,137,152,153,136,136,136,136,153,137,153,153,136,135,103,102,103,119,136,137,153,153,153,152
    DB 136,135,135,136,136,153,152,153,136,118,118,103,119,136,136,153,153,152,153,137,136,120,135,136,136,152,169,153,152,136,118,118
    DB 103,119,120,136,153,153,152,152,136,136,136,135,136,137,152,153,153,152,136,119,118,103,119,120,136,153,153,152,152,136,136,136
    DB 136,136,136,000,000

SOUND_DATA_05:
	DB 136,000,255,136,136,136,136,136,136,136,137,153,136,137,136,135,136,153,153,153,135,103,102,102,104,137,153,154,153,152,153,136
    DB 137,152,135,120,136,119,120,137,170,171,169,134,101,069,085,120,137,154,170,169,153,152,119,119,119,120,153,153,136,136,135,119
    DB 119,118,103,137,171,221,202,134,084,068,069,103,137,171,186,169,153,152,135,136,136,136,153,136,137,136,135,120,135,119,119,119
    DB 120,187,204,187,152,101,068,069,086,121,170,170,170,169,153,152,135,120,136,119,121,136,136,136,136,119,136,136,120,136,119,103
    DB 154,171,171,169,135,118,101,085,102,103,138,185,187,183,171,119,071,168,087,136,150,153,152,136,137,136,136,120,118,103,120,153
    DB 171,169,152,136,135,118,103,118,103,137,154,153,153,152,137,135,136,136,136,137,119,137,151,104,136,119,153,136,120,135,102,124
    DB 219,169,153,118,085,085,103,120,170,169,153,153,152,120,136,119,137,136,120,137,152,136,152,136,136,135,119,120,136,136,136,135
    DB 120,154,170,170,152,118,086,102,120,153,153,152,152,136,136,136,136,120,136,119,120,136,135,136,136,136,153,137,152,153,136,119
    DB 137,171,187,185,134,068,052,070,138,187,170,169,135,103,119,137,137,136,135,119,136,153,169,152,136,136,136,136,100,087,174,238
    DB 220,150,051,051,070,173,238,236,150,051,068,069,140,238,219,168,100,069,137,188,202,168,099,052,069,238,222,216,034,052,068,157
    DB 238,221,199,051,052,123,205,204,168,083,051,089,188,185,134,083,051,158,237,218,051,051,059,238,199,051,072,221,220,150,103,188
    DB 202,116,051,057,222,199,051,068,074,237,237,130,052,078,237,147,051,158,222,163,051,110,237,214,051,051,206,235,114,052,075,237
    DB 221,083,051,222,195,052,078,235,083,089,186,153,170,167,083,053,221,165,051,174,237,162,035,190,213,035,174,213,051,190,215,051
    DB 173,218,083,055,151,102,093,238,232,051,078,232,051,238,213,052,158,197,052,222,217,102,067,054,235,070,237,230,051,110,195,055
    DB 222,131,051,221,115,220,133,104,133,068,201,206,237,035,059,199,055,221,165,051,104,170,135,121,169,102,102,102,158,237,099,059
    DB 197,055,238,115,087,085,238,148,074,201,136,084,071,238,231,051,236,067,237,163,092,100,076,234,052,188,168,118,084,094,238,083
    DB 057,100,190,198,093,163,062,231,052,220,117,186,068,174,219,051,197,052,238,099,222,051,062,212,055,202,139,214,052,238,210,062
    DB 179,062,220,125,162,051,232,038,217,084,152,051,237,211,062,179,076,235,125,195,051,185,069,204,151,087,119,222,163,157,163,061
    DB 217,069,148,052,136,189,182,168,051,254,179,061,131,078,180,238,179,061,196,058,148,142,196,052,078,237,068,234,052,238,136,218
    DB 051,106,087,220,100,172,147,062,228,062,195,055,233,110,212,051,151,106,168,138,134,051,254,211,062,179,056,151,190,163,053,167
    DB 138,152,138,134,068,238,213,077,083,122,153,218,068,135,087,201,104,168,121,071,238,163,077,116,108,167,205,083,088,135,171,134
    DB 153,150,052,238,083,188,084,184,125,164,055,135,155,151,122,134,052,254,164,061,149,120,119,173,131,106,168,137,118,154,052,254
    DB 147,076,117,185,118,203,100,120,154,135,121,135,117,238,131,091,134,153,118,187,100,155,151,120,117,075,238,134,151,053,187,136
    DB 185,085,119,154,185,085,137,068,238,164,168,072,201,104,200,068,138,136,168,087,151,074,238,117,151,087,202,121,184,085,104,152
    DB 136,136,119,068,238,165,090,133,155,151,201,068,139,151,152,101,151,077,252,100,153,105,202,104,168,101,121,169,134,102,152,077
    DB 237,116,136,104,186,121,184,084,104,153,135,137,099,143,233,071,117,108,184,156,149,052,154,136,136,118,116,095,235,085,135,106
    DB 202,122,167,067,137,153,134,121,132,079,236,072,134,123,200,139,149,053,169,119,135,105,148,079,234,053,168,089,202,105,167,068
    DB 153,136,135,103,166,123,254,099,154,102,187,138,166,054,169,119,120,136,132,062,237,103,170,101,172,151,169,084,123,150,121,135
    DB 136,084,206,230,073,183,072,218,120,150,069,169,104,152,136,133,076,237,118,169,085,155,152,153,117,088,136,137,152,120,116,094
    DB 236,101,169,084,172,168,137,099,074,167,105,168,120,068,238,230,074,165,055,220,136,134,068,155,135,154,135,137,084,190,217,104
    DB 150,054,204,167,119,085,121,152,137,135,153,132,076,234,102,136,068,172,184,119,100,088,169,120,152,136,152,068,222,216,103,134
    DB 087,188,168,135,084,105,169,136,137,136,152,068,174,230,071,134,072,220,151,103,101,122,169,119,136,154,152,083,110,237,116,088
    DB 133,107,219,118,102,103,169,135,121,169,153,152,083,126,232,052,137,101,156,184,102,135,120,152,136,154,152,153,135,086,073,238
    DB 215,051,136,102,156,183,086,136,119,153,151,138,186,135,121,117,072,238,231,051,137,118,156,201,101,103,136,153,136,137,186,135
    DB 120,135,120,102,189,234,083,089,151,121,170,118,119,119,137,135,137,170,135,103,154,151,084,091,238,198,052,120,119,137,169,119
    DB 103,120,136,137,153,169,135,103,153,153,117,084,158,237,131,071,135,121,186,151,086,120,136,138,169,153,169,135,119,154,152,119
    DB 101,088,238,232,051,073,152,120,171,151,068,121,170,152,153,152,137,135,119,154,150,103,135,086,205,237,083,053,171,134,122,202
    DB 099,056,203,151,105,170,135,120,136,135,153,151,103,154,133,054,238,181,051,122,151,102,155,169,117,104,154,152,119,138,152,135
    DB 136,136,153,152,119,137,151,083,109,238,181,052,106,184,101,122,185,085,105,187,151,119,154,152,119,137,152,135,136,136,136,170
    DB 151,068,089,237,217,067,053,172,168,102,154,168,101,121,186,135,121,169,119,136,152,136,153,151,135,120,170,151,102,087,155,237
    DB 184,067,054,172,185,118,120,136,136,136,136,154,169,135,103,120,154,153,119,121,152,135,120,152,135,120,136,119,157,236,149,051
    DB 072,188,184,084,088,170,152,119,136,137,169,152,119,136,153,153,135,119,136,136,135,120,152,136,135,102,155,237,183,068,070,138
    DB 170,151,101,104,154,169,120,119,136,170,169,135,103,137,170,151,102,104,153,136,119,120,137,136,136,137,154,170,152,101,087,136
    DB 136,136,136,136,137,153,152,136,136,136,152,136,137,136,136,137,135,119,120,153,136,135,119,120,136,136,154,170,152,134,085,103
    DB 153,152,120,136,136,137,153,152,153,136,136,152,136,120,136,136,136,136,136,136,119,120,136,136,136,136,136,138,187,169,134,085
    DB 086,137,153,137,136,136,137,152,152,153,152,136,136,135,120,137,136,120,136,119,121,153,136,136,135,120,136,136,154,170,169,135
    DB 085,085,120,136,137,153,136,136,136,136,152,136,136,152,136,120,136,120,137,152,119,136,136,120,153,152,136,135,136,154,186,152
    DB 135,101,085,119,136,154,169,152,136,136,136,136,136,136,153,136,135,136,136,120,136,136,136,136,136,136,136,136,136,136,137,170
    DB 169,136,119,102,119,120,136,153,153,137,136,136,120,136,136,153,152,135,136,136,120,136,136,137,136,135,136,136,135,136,136,137
    DB 153,153,154,153,135,118,102,103,136,136,137,153,152,137,136,136,136,136,136,000,255,000,000

SOUND_DATA_06:
	DB 136,000,255,153,150,151,170,151,138,136,168,073,107,218,138,083,166,154,108,183,199,136,137,121,119,150,154,152,120,136,152,166
    DB 153,073,135,148,167,170,155,166,120,117,137,152,154,154,181,169,088,118,168,137,121,150,183,120,138,138,106,135,139,104,136,106
    DB 135,152,152,170,073,135,150,167,154,133,167,183,121,137,117,151,170,169,122,132,150,199,138,106,134,151,110,093,132,179,091,087
    DB 167,121,155,152,090,118,165,170,121,119,198,171,089,136,136,125,135,120,138,101,149,185,106,124,136,136,153,135,116,151,121,233
    DB 169,120,103,137,105,137,135,092,134,119,183,169,105,135,121,121,119,151,152,170,132,153,121,152,215,062,131,179,154,094,151,198
    DB 151,094,131,179,139,062,104,180,188,060,059,148,199,169,120,153,134,183,183,075,118,181,202,090,134,167,105,092,136,166,184,135
    DB 154,104,119,134,166,171,092,123,118,181,164,217,077,102,229,058,075,151,172,115,232,058,094,195,062,214,059,116,238,183,078,213
    DB 052,234,051,078,233,052,238,051,222,051,222,083,237,131,062,212,068,237,084,078,218,036,221,050,078,210,205,099,115,055,238,051
    DB 238,115,238,083,136,185,085,062,234,052,238,051,237,052,205,179,141,083,222,118,067,204,180,061,164,069,173,187,083,158,115,109
    DB 195,061,139,115,109,172,067,199,089,137,137,119,056,185,221,067,185,119,123,202,115,137,118,091,203,100,172,119,152,135,153,086
    DB 202,106,119,110,179,075,138,155,100,185,118,201,123,103,186,084,189,115,140,117,155,183,075,138,115,153,168,137,170,084,202,150
    DB 091,167,120,136,059,165,153,152,172,102,169,134,092,165,058,201,106,219,085,120,117,140,151,106,169,133,154,118,155,167,102,138
    DB 169,135,168,104,169,105,136,172,131,074,168,152,153,135,138,136,202,117,087,119,154,155,153,137,150,138,151,135,122,152,137,167
    DB 103,137,119,186,136,119,137,121,185,086,136,119,203,104,168,102,154,169,135,138,151,121,120,171,131,072,171,105,219,117,151,230
    DB 118,151,088,186,103,188,133,091,168,103,221,163,054,237,067,057,221,141,210,035,237,211,067,051,110,230,099,222,058,051,238,163
    DB 055,237,083,220,131,061,217,163,221,115,051,213,164,083,073,092,180,216,171,235,056,054,186,154,103,184,118,120,137,136,121,152
    DB 119,106,152,118,154,136,134,151,154,122,153,117,169,136,120,169,119,122,151,152,170,085,155,183,088,139,151,167,119,138,135,088
    DB 185,152,121,153,102,155,152,119,170,134,105,186,102,138,167,136,153,151,105,152,135,187,135,116,078,236,052,237,146,068,203,206
    DB 165,131,135,119,068,157,164,092,235,150,088,200,070,172,121,087,135,185,169,053,152,117,156,185,169,118,107,051,237,229,053,156
    DB 170,216,067,106,071,117,123,217,198,168,135,071,169,136,187,106,184,116,120,122,107,153,150,137,135,136,118,122,120,138,184,136
    DB 153,119,103,171,151,104,120,153,167,137,141,133,058,201,135,104,170,103,137,119,153,152,167,139,167,070,153,119,170,117,140,169
    DB 117,122,152,120,169,121,169,152,103,121,134,137,153,152,153,168,134,121,152,120,168,120,000,104,137,118,153,168,119,121,152,187
    DB 036,237,131,078,231,054,220,152,086,169,135,106,172,131,062,195,055,232,052,204,102,174,147,104,148,078,214,068,134,238,136,179
    DB 062,196,051,230,102,157,126,197,184,135,109,115,093,211,051,221,163,061,220,051,237,099,237,194,051,235,053,142,173,217,051,093
    DB 099,217,057,093,083,215,091,141,117,120,166,104,104,203,153,086,106,119,088,221,140,181,054,131,187,061,217,099,061,147,199,199
    DB 236,051,216,089,132,123,169,152,185,103,188,151,120,135,157,179,055,205,134,164,125,154,106,215,061,214,044,100,155,121,137,151
    DB 139,200,117,123,167,104,120,153,136,138,134,104,168,136,000,008,135,121,169,136,119,120,152,136,120,153,135,198,104,151,151,121
    DB 152,136,184,119,138,135,168,135,152,153,152,135,153,135,152,136,152,126,131,215,074,150,136,136,151,155,104,135,169,119,153,135
    DB 136,137,152,136,137,136,122,135,137,137,183,062,071,185,089,120,137,152,134,153,136,152,121,136,136,120,135,168,137,151,121,137
    DB 120,137,103,169,119,153,120,151,152,137,119,137,152,151,152,136,136,137,151,137,136,137,136,136,120,138,119,136,152,168,105,136
    DB 136,168,135,137,151,119,152,153,121,151,135,153,135,136,153,136,137,136,137,150,122,120,152,163,171,118,183,135,151,136,152,137
    DB 136,152,136,105,152,000,255