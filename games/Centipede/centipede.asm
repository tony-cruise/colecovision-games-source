; Centipede Disassembly by Captain Cozmos
; 26 August 2023
; Labeled as much as I could without going into a deep dive into the code.
; I changed the $6000 ram area to point to $7000.  I have no clue if this makes a difference but in sticking with Colecoision compatability vs ADAM vs anything else.

; Modify, at your hearts content but please give me credit where credit is due.  My eye's are burning hot staring at this code for hours on end.
; I do this so everyone can learn how these old Z80 based binaries were programed and the biggest thing I learned is that the Colecovision was more powerful than you think.
; The early Colecovision Games must have been rushed because this machine is fast and can do a heck of a lot more than what was being sold.


DATA_PORT:     EQU $00BE 
CTRL_PORT:     EQU $00BF 
SOUND_PORT:    EQU $00FF
JOY_PORT:      EQU $00C0
KEYBOARD_PORT: EQU $0080
CONTROLLER_01: EQU $00FC
CONTROLLER_02: EQU $00FF


FNAME "CENTIPEDE.ROM"
CPU Z80

    ORG 8000H
    DW 0AA55H
    DW 0
    DW 0
    DW 0
    DW 0
    DW START

    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP

LOC_801E:
    JP      LOC_801E
    JP      LOC_A033
    DB  'C'
    DB  'E'
    DB  'N'
    DB  'T'
    DB  'I'
    DB  'P'
    DB  'E'
    DB  'D'
    DB  'E'
    DB  0FFH

START:     
    LD      HL, $7000
    LD      B, 3

LOOP_8033:             
    LD      (HL), 0
    INC     HL
    DJNZ    LOOP_8033

LOC_8038:
    LD      SP, $73FF
    CALL    SUB_A101
    CALL    SUB_A15D
    CALL    TITLE_SCREEN
    CALL    SUB_9E64
    LD      BC, 12CH

LOC_804A:
    PUSH    BC
    CALL    SUB_A04A
    CALL    SUB_9D92
    LD      A, ($70A0)
    XOR     2
    LD      ($70A0), A
    CALL    GET_CONTROLLER_02
    CP      79H
    JR      Z, LOC_8075
    LD      A, ($70A0)
    XOR     2
    LD      ($70A0), A
    CALL    GET_CONTROLLER_02
    CP      79H
    JR      Z, LOC_8075
    POP     BC
    DEC     BC
    LD      A, C
    OR      B
    JR      NZ, LOC_804A

LOC_8075:
    LD      SP, $73FF
    CALL    SUB_A101
    CALL    SUB_A15D
    CALL    SUB_9DB2
    LD      BC, 12CH

LOC_8084:
    PUSH    BC
    CALL    SUB_A04A
    POP     BC
    DEC     BC
    LD      A, C
    OR      B
    JR      Z, LOC_8038
    LD      A, ($70A0)
    XOR     2
    LD      ($70A0), A
    CALL    GET_CONTROLLER_02
    CP      7FH
    JR      NZ, LOC_80AC
    LD      A, ($70A0)
    XOR     2
    LD      ($70A0), A
    CALL    GET_CONTROLLER_02
    CP      7FH
    JR      Z, LOC_8084

LOC_80AC:
    LD      B, 10H
    CP      7DH
    JR      Z, LOC_80D0
    LD      B, 20H
    CP      77H
    JR      Z, LOC_80D0
    LD      B, 30H
    CP      7CH
    JR      Z, LOC_80D0
    LD      B, 11H
    CP      72H
    JR      Z, LOC_80D0
    LD      B, 21H
    CP      73H
    JR      Z, LOC_80D0
    LD      B, 31H
    CP      7EH
    JR      NZ, LOC_8084

LOC_80D0:
    LD      A, B
    LD      ($70A0), A
    CALL    SUB_9503
    CALL    SUB_95D1
    LD      A, ($70A0)
    BIT     0, A
    JR      Z, LOC_8102
    SET     1, A
    LD      ($70A0), A
    PUSH    AF
    CALL    SUB_95D1
    POP     AF
    RES     1, A
    LD      ($70A0), A
    CALL    SUB_9E6C
    CALL    SUB_9E8D
    CALL    SUB_963F
    CALL    SUB_9E64
    LD      HL, $714B
    CALL    SUB_9BC9

LOC_8102:
    CALL    SUB_9E6C
    CALL    SUB_9E8D
    CALL    SUB_963F
    CALL    SUB_9E64
    CALL    SUB_9E74
    JR      LOC_8116

LOC_8113:
    CALL    SUB_9A82

LOC_8116:
    CALL    SUB_9CA9
    CALL    SUB_9E6C
    CALL    SUB_9EC2
    CALL    SUB_9577
    CALL    SUB_964A
    CALL    SUB_9652
    CALL    SUB_9E64
    LD      HL, SPRITE_TABLE
    LD      DE, $7020
    LD      BC, 4DH
    LDIR
    CALL    SUB_9617
    CALL    SUB_96BA
    CALL    SUB_9695
    CALL    SUB_9673
    CALL    SUB_9684
    LD      HL, 19A0H
    LD      ($70DC), HL
    CALL    SUB_A063
    CALL    SUB_99A5
    CALL    SUB_99C2
    CALL    SUB_99DA
    LD      A, 0BH
    CALL    SUB_A11C

LOC_815C:
    CALL    SUB_A04A
    CALL    SUB_A063
    CALL    SUB_8B83
    CALL    SUB_8538
    CALL    SUB_8728
    CALL    SUB_88AB
    CALL    SUB_83D2
    CALL    SUB_81C9
    CALL    SUB_995C
    LD      HL, ($7008)
    LD      A, L
    OR      H
    JR      NZ, LOC_8183
    LD      A, 0BH
    CALL    SUB_A11C

LOC_8183:
    CALL    SUB_9E6C
    CALL    GET_CONTROLLER_02
    PUSH    AF
    LD      A, ($70A7)
    LD      B, A
    POP     AF
    LD      ($70A7), A
    CP      B
    JR      NZ, LOC_81A1

LOC_8195:
    LD      A, ($70A0)
    BIT     3, A
    JR      Z, LOC_81C3
    CALL    SUB_99C8
    JR      LOC_8183

LOC_81A1:
    CP      76H
    JR      NZ, LOC_81B5
    LD      A, ($70A0)
    XOR     8
    LD      ($70A0), A
    CALL    SUB_A101
    CALL    SUB_A15D
    JR      LOC_8195

LOC_81B5:
    CP      79H
    JR      NZ, LOC_8195
    LD      A, ($70A0)
    BIT     3, A
    JP      Z, LOC_8075
    JR      LOC_8183

LOC_81C3:
    CALL    SUB_9E64
    JP      LOC_815C

SUB_81C9:
    LD      HL, $70E0
    LD      A, ($70A0)
    BIT     1, A
    JR      Z, LOC_81D4
    INC     HL

LOC_81D4:
    LD      A, (HL)
    CP      1
    JR      C, LOC_8201
    LD      IX, $70D6
    LD      IY, $7034
    BIT     0, (IX+0)
    JR      Z, LOC_8219
    DEC     (IX+2)
RET NZ
    LD      A, (IX+3)
    LD      (IX+2), A
    LD      A, (IX+1)
    CP      4
    JP      Z, LOC_828C
    CP      1
    JP      Z, FLEA_BODY
    JP      LOC_8362

LOC_8201:
    LD      IX, $71C2
    DEC     (IX+0)
RET NZ
    LD      (IX+0), 3CH
    DEC     (IX+1)
RET NZ
    CALL    SUB_95D1
    LD      (IX+1), 3CH
RET

LOC_8219:
    LD      DE, ($70DC)
    LD      HL, 1ABDH
    SUB     A
    SBC     HL, DE
    LD      B, 10H
    JR      C, LOC_823D
    EX      DE, HL

LOOP_8228:
    CALL    OUT_CTRL_IN_DATA_PORT_00
    CP      21H
    JR      C, LOC_8236
    CP      25H
    JR      NC, LOC_8236
    INC     (IX+8)

LOC_8236:
    INC     HL
    DJNZ    LOOP_8228
    LD      ($70DC), HL
RET

LOC_823D:
    LD      A, ($70ED)
    LD      B, (IX+8)
    CP      B
    JR      NC, LOC_8255
    LD      HL, 19A0H
    LD      ($70DC), HL
    LD      (IX+8), 0
    RES     5, (IX+0)
RET

LOC_8255:
    CALL    SUB_9684
    LD      (IX+1), 1
    SET     0, (IX+0)
    SET     5, (IX+0)
    LD      A, ($70EE)
    LD      (IX+5), A
    CALL    SUB_983E

LOC_826D:
    AND     1FH
    CP      1CH
    JR      C, LOC_8277
    RRA
    RRA
    JR      LOC_826D

LOC_8277:
    INC     A
    LD      B, A
    LD      A, 8

LOC_827B:
    ADD     A, 8
    DJNZ    LOC_827B
    CALL    SUB_9C7D
    CALL    SUB_9C8A
    LD      (IY+1), A
    LD      (IY+5), A
RET

LOC_828C:
    LD      A, (IY+0)
    LD      B, (IX+4)
    ADD     A, B
    BIT     3, (IX+0)
    JR      Z, LOC_829A
    ADD     A, B

LOC_829A:
    LD      (IY+0), A
    LD      (IY+4), A
    LD      HL, ($7034)
    LD      DE, ($7020)
    LD      BC, 606H
    INC     D
    PUSH    AF
    CALL    SUB_9E38
    JR      NC, SOUNDS_00
    CALL    SUB_9C7D
    CALL    SUB_9C8A
    JP      LOC_8623

SOUNDS_00:             
    POP     AF
    PUSH    AF
    LD      HL, 220H
    LD      E, A
    LD      D, 0
    SLA     E
    RL      D
    ADD     HL, DE
    LD      A, L
    AND     0FH
    OR      80H
    OUT     (SOUND_PORT), A
    LD      A, L
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    LD      C, A
    LD      A, H
    SLA     A
    SLA     A
    SLA     A
    SLA     A
    ADD     A, C
    OUT     (SOUND_PORT), A
    POP     AF
    CP      0AFH
    JR      C, LOC_82EC
    JP      LOC_837C

LOC_82EC:
    LD      B, 3
    CP      20H
    JR      C, LOC_8300
    LD      B, 8
    CP      40H
    JR      C, LOC_8300
    LD      B, 19H
    CP      60H
    JR      C, LOC_8300
    LD      B, 40H

LOC_8300:
    CALL    SUB_983E
    CP      B
    JR      NC, LOC_8325
    BIT     4, (IX+0)
    JR      NZ, LOC_8325
    LD      DE, ($7034)
    CALL    SUB_9F08
    CP      20H
    JR      NZ, LOC_8325
    LD      A, 21H
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    DEC     (IX+5)
    JR      NZ, LOC_8325
    SET     4, (IX+0)

LOC_8325:
    DEC     (IX+6)
RET NZ
    LD      A, (IX+7)
    LD      (IX+6), A
    LD      A, (IX+9)
    BIT     7, A
    JR      NZ, FLEA_LEGS
    INC     A
    AND     3
    JR      NZ, LOC_8345
    LD      A, 83H
    JR      LOC_8345

FLEA_LEGS:             
    DEC     A
    CP      80H
    JR      NC, LOC_8345
    SUB     A

LOC_8345:
    LD      (IX+9), A
    AND     3
    PUSH    AF
    LD      HL, FLEA_LEG_COLORS
    JR      Z, LOC_8354
    LD      B, A

LOOP_8351:             
    INC     HL
    DJNZ    LOOP_8351

LOC_8354:
    LD      A, (HL)
    LD      (IY+7), A
    POP     AF
    LD      DE, 38C0H
    LD      HL, FLEA_LEGS_PATTERNS
    JP      LOC_9EFB

LOC_8362:
    LD      HL, FLEA_EXPLOSION
    LD      DE, 38A0H
    LD      A, (IX+9)
    INC     A
    AND     7
    LD      (IX+9), A
    PUSH    AF
    LD      BC, 8
    CALL    SUB_9EFE
    POP     AF
    CP      7
RET C

LOC_837C:
    LD      A, 8
    SET     7, A
    CALL    SUB_A11C
    LD      (IX+1), 0
    RES     0, (IX+0)
    LD      (IX+9), 0
    LD      (IX+2), 1
    LD      (IX+8), 0
    LD      HL, 19A0H
    LD      ($70DC), HL
    CALL    SUB_9C8A
    JP      SUB_9C7D

FLEA_BODY:             
    LD      (IX+2), 1
    LD      HL, $70CC
    BIT     0, (HL)
RET NZ
    LD      (IY+3), 0DH
    LD      A, (FLEA_LEG_COLORS)
    LD      (IY+7), A
    LD      (IX+1), 4
    SET     0, (IX+0)
    LD      DE, FLEA_BODY_PATTERNS
    LD      HL, 38A0H
    LD      BC, 8
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    LD      A, 9
    SET     7, A
    JP      SUB_A11C

SUB_83D2:
    LD      A, ($70A0)
    LD      HL, $70E0
    BIT     1, A
    JR      Z, LOC_83DD
    INC     HL

LOC_83DD:
    LD      A, (HL)
    CP      3
RET C
    LD      ($70B9), A
    LD      IX, $70CC
    LD      IY, $7030
    DEC     (IX+2)
RET NZ
    LD      A, (IX+3)
    LD      (IX+2), A
    LD      A, (IX+1)
    CP      4
    JP      Z, LOC_8487
    CP      3
    JP      Z, LOC_84F5
    LD      HL, $70D6
    BIT     0, (HL)
RET NZ
    BIT     5, (HL)
RET NZ
    LD      HL, $70A8
    LD      A, ($70A0)
    BIT     1, A
    JR      Z, LOC_8419
    LD      HL, $70AB

LOC_8419:
    PUSH    HL
    CALL    SUB_9695
    POP     HL
    LD      A, (HL)
    CP      2
    JR      NC, LOC_8427
    LD      B, 5
    JR      LOC_8433

LOC_8427:
    CALL    SUB_983E
    CP      80H
    JR      C, LOC_8433
    DEC     (IX+3)
    LD      B, 0FH

LOC_8433:
    LD      A, ($70B9)
    ADD     A, B
    LD      B, A
    CALL    SUB_983E
    CP      B
RET NC
    CALL    SUB_983E
    LD      B, 2
    LD      C, 0
    CP      40H
    JR      NC, LOC_844C
    LD      B, 8
    LD      C, 0F4H

LOC_844C:
    LD      (IX+8), B
    LD      (IY+1), C
    CALL    SUB_983E
    AND     7
    INC     A
    LD      B, A
    LD      A, 0AH

LOC_845B:
    ADD     A, 8
    DJNZ    LOC_845B
    LD      (IY+0), A
    LD      (IY+3), 9
    SET     0, (IX+0)
    LD      (IX+1), 4
    LD      (IX+2), 1
    LD      (IX+9), 0
    LD      A, 0AH
    SET     7, A
    CALL    SUB_A11C
    BIT     3, (IX+8)
    JR      NZ, LOC_8487
    SET     7, (IY+3)

LOC_8487:
    LD      A, (IX+5)
    BIT     1, (IX+8)
    JR      NZ, LOC_8492
    NEG

LOC_8492:
    LD      B, A
    LD      A, (IY+1)
    ADD     A, B
    LD      (IY+1), A
    LD      A, 0CH
    BIT     3, (IX+8)
    JR      NZ, LOC_84A4
    LD      A, 0E6H

LOC_84A4:
    LD      DE, ($7030)
    ADD     A, D
    LD      D, A
    CP      18H
    JR      C, LOC_84C2
    CP      0E1H
    JR      NC, LOC_84C2
    CALL    SUB_9F08
    CP      21H
    JR      C, LOC_84C2
    CP      25H
    JR      NC, LOC_84C2
    LD      A, 28H
    CALL    OUT_CTRL_OUT_DATA_PORT_01

LOC_84C2:
    LD      A, (IY+1)
    BIT     3, (IX+8)
    JR      Z, LOC_84D4
    CP      4
    JP      NC, SCORPION
    LD      B, 20H
    JR      LOC_84DB

LOC_84D4:
    CP      0FCH
    JP      C, SCORPION
    LD      B, 0E0H

LOC_84DB:
    BIT     1, (IX+0)
    JR      NZ, LOC_8504
    SET     1, (IX+0)
    LD      A, (IY+1)
    ADD     A, B
    LD      (IY+1), A
    LD      A, (IY+3)
    XOR     80H
    LD      (IY+3), A
RET

LOC_84F5:
    LD      HL, SCORPION_EXPLOSION
    LD      DE, 3880H
    CALL    SUB_9EF2
    LD      A, (IX+9)
    CP      7
RET C

LOC_8504:
    LD      A, 8
    SET     7, A
    CALL    SUB_A11C
    CALL    SUB_9C7D
    LD      (IX+0), 0
    LD      (IX+1), 0
    LD      (IX+2), 0
RET

SCORPION:
    DEC     (IX+6)
RET NZ
    LD      A, (IX+7)
    LD      (IX+6), A
    LD      HL, SCORPION_WEST
    LD      DE, 3880H
    BIT     3, (IX+8)
    JP      NZ, SUB_9EF2
    LD      HL, SCORPION_EAST
    JP      SUB_9EF2

SUB_8538:
    LD      HL, ($7020)
    LD      ($70B9), HL
    CALL    CONTROLLER_02_KEY_BOARD
    LD      C, A
    LD      HL, $70A3
    AND     A
    JR      Z, LOC_855B
    AND     0FH
    JR      Z, LOC_855B
    LD      A, (HL)
    CALL    SUB_9C41
    LD      E, B
    LD      (HL), A
    INC     HL
    LD      A, (HL)
    CALL    SUB_9C41
    LD      D, B
    LD      (HL), A
    JR      LOC_8561

LOC_855B:
    LD      (HL), A
    INC     HL
    LD      (HL), A
    JP      LOC_8597

LOC_8561:
    LD      A, C
    LD      HL, $7020
    BIT     0, A
    JR      Z, LOC_8571
    LD      A, (HL)
    CP      78H
    JR      C, LOC_8571
    SUB     D
    JR      LOC_857C

LOC_8571:
    LD      A, C
    BIT     2, A
    JR      Z, LOC_857D
    LD      A, (HL)
    CP      0AEH
    JR      NC, LOC_857D
    ADD     A, D

LOC_857C:
    LD      (HL), A

LOC_857D:
    INC     HL
    LD      A, C
    BIT     3, A
    JR      Z, LOC_858B
    LD      A, (HL)
    CP      8
    JR      C, LOC_858B
    SUB     E
    JR      LOC_8596

LOC_858B:
    LD      A, C
    BIT     1, A
    JR      Z, LOC_8597
    LD      A, (HL)
    CP      0E7H
    JR      NC, LOC_8597
    ADD     A, D

LOC_8596:
    LD      (HL), A

LOC_8597:
    LD      HL, ($7020)
    LD      BC, 504H
    ADD     HL, BC
    EX      DE, HL
    CALL    SUB_9F08
    CP      0E0H
    JR      NC, LOC_85EB
    CP      30H
    JP      NC, LOC_8623
    LD      HL, $70A6
    BIT     3, (HL)
    JR      Z, LOC_85B8
    DEC     D
    DEC     D
    DEC     D
    CALL    SUB_9F08

LOC_85B8:
    CP      21H
    JR      C, LOC_85C2
    LD      HL, ($70B9)
    LD      ($7020), HL

LOC_85C2:
    LD      A, 8
    ADD     A, E
    CP      0C0H
    JR      NC, LOC_85F1
    LD      E, A
    CALL    SUB_9F08
    CP      0E0H
    JR      NC, LOC_85EB
    CP      30H
    JP      NC, LOC_8623
    LD      HL, $70A6
    BIT     0, (HL)
    JR      NZ, LOC_85E1
    BIT     2, (HL)
    JR      Z, LOC_85E7

LOC_85E1:
    DEC     D
    DEC     D
    DEC     D
    CALL    SUB_9F08

LOC_85E7:
    CP      21H
    JR      C, LOC_85F1

LOC_85EB:
    LD      HL, ($70B9)
    LD      ($7020), HL

LOC_85F1:
    LD      A, ($70C3)
    CP      4
    CALL    NC, SUB_8B27
    LD      HL, $70C1
    BIT     0, (HL)
RET NZ
    LD      A, ($70A6)
    BIT     6, A
    JR      Z, SUB_861C
    SET     0, (HL)
    LD      HL, ($7020)
    LD      A, 7
    ADD     A, L
    LD      L, A
    LD      ($7024), HL
    LD      A, 2
    CALL    SUB_A11C
    LD      A, 13H
    JP      SUB_A11C

SUB_861C:
    LD      HL, ($7020)
    LD      ($7024), HL
RET

LOC_8623:
    LD      IX, $71C4
    LD      B, 0CH

LOC_8629:
    BIT     0, (IX+0)
    JR      Z, LOC_867B
    LD      A, (IX+1)
    CP      0
    JR      Z, LOC_8644
    CP      4
    JR      NZ, LOC_867B
    LD      A, 21H
    LD      L, (IX+5)
    LD      H, (IX+4)
    JR      LOC_8678

LOC_8644:
    BIT     6, (IX+0)
    JR      NZ, LOC_867B
    BIT     5, (IX+0)
    JR      NZ, LOC_867B
    LD      A, (IX+7)
    LD      C, A
    ADD     A, 40H
    LD      L, (IX+0AH)
    LD      H, (IX+9)
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    EX      DE, HL
    LD      A, C
    LD      L, (IX+5)
    LD      H, (IX+4)
    AND     A
    PUSH    HL
    SBC     HL, DE
    POP     HL
    JR      NZ, LOC_8678
    LD      A, 50H
    BIT     3, (IX+8)
    JR      NZ, LOC_8678
    LD      A, 58H

LOC_8678:
    CALL    OUT_CTRL_OUT_DATA_PORT_01

LOC_867B:
    LD      DE, 0FH
    ADD     IX, DE
    DJNZ    LOC_8629
    LD      A, 1
    CALL    SUB_A11C
    LD      A, 16H
    CALL    SUB_A11C
    LD      A, 8
    CALL    SUB_A11C
    LD      A, 0FH
    CALL    SUB_A11C
    LD      HL, ($7020)
    LD      A, 0FBH
    ADD     A, H
    LD      H, A
    LD      ($7020), HL
    LD      ($7024), HL
    LD      IX, $70B9
    LD      (IX+0), 3
    LD      (IX+1), 3
    LD      (IX+2), 0FFH

LOC_86B3:
    LD      HL, LOGO_FLASH_COLORS
    LD      B, 0
    LD      C, A
    ADD     HL, BC
    LD      A, (HL)
    RLCA
    RLCA
    RLCA
    RLCA
    LD      ($7027), A
    LD      A, (IX+2)
    INC     A
    AND     7
    LD      (IX+2), A
    LD      DE, 3800H
    LD      HL, BLASTER_EXPLOSION
    LD      BC, 40H
    CALL    SUB_9EFE
    CALL    SUB_A063

LOC_86DA:
    CALL    SUB_A04A
    LD      A, (IX+2)
    CP      7
    JR      NC, BUG_BLASTER
    DEC     (IX+0)
    JR      NZ, LOC_86DA
    LD      A, (IX+1)
    LD      (IX+0), A
    JR      LOC_86B3

BUG_BLASTER:           
    LD      HL, 3800H
    SUB     A
    LD      BC, 40H
    CALL    OUT_CTRL_OUT_DATA_PORT_02

LOC_86FB:
    CALL    SUB_A04A
    LD      HL, ($7014)
    LD      A, L
    OR      H
    JR      NZ, LOC_86FB
    LD      A, 0
    CALL    SUB_A11C
    LD      A, 12H
    CALL    SUB_A11C
    LD      B, 1EH

LOOP_8711:             
    CALL    SUB_A04A
    DJNZ    LOOP_8711
    LD      HL, 3800H
    LD      DE, BUG_BLASTER_PATTERNS
    LD      BC, 40H
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    LD      SP, $73FF
    JP      LOC_8113

SUB_8728:
    LD      IX, $70C1
    BIT     0, (IX+0)
RET Z
    LD      IY, $7024
    LD      A, (IY+0)
    CP      11H
    JR      C, LOC_8750
    SUB     8
    LD      (IY+0), A
    CALL    SUB_8784
    CALL    SUB_8864
    CALL    SUB_880E
    JP      LOC_8757

SUB_874D:
    CALL    SUB_9F2B

LOC_8750:
    RES     0, (IX+0)
    JP      SUB_861C

LOC_8757:
    LD      DE, ($7024)
    INC     D
    INC     D
    INC     D
    INC     D
    CALL    SUB_9F08
    CP      21H
RET C
    CP      2CH
RET NC
    INC     A
    LD      B, A
    CP      25H
    JR      C, LOC_8777
    JR      Z, LOC_8775
    CP      2CH
    JR      C, LOC_8777
RET NZ

LOC_8775:
    LD      B, 20H

LOC_8777:
    LD      A, B
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    CP      20H
    JR      NZ, LOC_8750
    LD      BC, 1
    JR      SUB_874D

SUB_8784:
    LD      A, ($70C3)
    CP      4
RET C
    LD      DE, ($7024)
    LD      HL, ($7028)
    LD      A, ($7028)
    LD      B, A
    LD      A, ($7020)
    SUB     B
    BIT     7, A
RET NZ
    LD      A, ($702B)
    BIT     7, A
    LD      B, 0E4H
    JR      NZ, LOC_87A7
    LD      B, 4

LOC_87A7:
    LD      A, B
    ADD     A, H
    LD      H, A
    LD      A, 0F8H
    ADD     A, L
    LD      L, A
    LD      BC, 608H
    CALL    SUB_9E38
RET NC
    CALL    SUB_8B64
    LD      A, 0FH
    CALL    SUB_A11C
    LD      A, ($7028)
    LD      B, A
    LD      A, ($7020)
    SUB     B
    LD      HL, 3860H
    LD      DE, SPIDER_SCORE_300
    LD      BC, 300H
    CP      50H
    JR      NC, LOC_87E2
    LD      DE, SPIDER_SCORE_600
    LD      BC, 600H
    CP      20H
    JR      NC, LOC_87E2
    LD      DE, SPIDER_SCORE_900
    LD      BC, 900H

LOC_87E2:
    PUSH    BC
    LD      BC, 20H
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    POP     BC
    LD      A, ($702F)
    AND     80H
    LD      ($702F), A
    LD      A, 0FFH
    LD      ($70CB), A
    LD      A, 1
    LD      ($70C4), A
    LD      A, 3
    LD      ($70C5), A
    LD      A, 2
    LD      ($70C3), A
    LD      A, 78H
    LD      ($70C8), A
    JP      SUB_874D

SUB_880E:
    LD      A, ($70D7)
    CP      4
RET NZ
    LD      DE, ($7024)
    LD      HL, ($7034)
    LD      A, E
    ADD     A, 3
    LD      E, A
    LD      BC, 50AH
    CALL    SUB_9E38
RET NC
    LD      IX, $70D6
    SET     3, (IX+0)
    DEC     (IX+8)
    JR      NZ, LOC_885D
    CALL    SUB_8B64
    LD      A, 8
    SET     7, A
    CALL    SUB_A11C
    LD      (IX+1), 3
    LD      (IX+2), 1
    LD      (IX+3), 3
    LD      (IX+9), 0FFH
    LD      HL, 0
    LD      ($7038), HL
    SUB     A
    LD      ($703B), A
    LD      BC, 200H
    CALL    SUB_9F2B

LOC_885D:
    LD      IX, $70C1
    JP      LOC_8750

SUB_8864:
    LD      A, ($70CD)
    CP      4
RET NZ
    LD      DE, ($7024)
    LD      HL, ($7030)
    LD      A, ($7033)
    BIT     7, A
    LD      B, 0E5H
    JR      NZ, LOC_887C
    LD      B, 2

LOC_887C:
    LD      A, B
    ADD     A, H
    LD      H, A
    LD      A, 0FCH
    ADD     A, L
    LD      L, A
    LD      BC, 808H
    CALL    SUB_9E38
RET NC
    LD      BC, 1000H
    CALL    SUB_874D
    CALL    SUB_8B64
    LD      A, 8
    CALL    SUB_A11C
    LD      A, 0FFH
    LD      ($70D5), A
    LD      A, 1
    LD      ($70CE), A
    LD      A, 3
    LD      ($70CD), A
    LD      ($70CF), A
RET

SUB_88AB:
    LD      IX, $70C2
    LD      IY, $7028
    DEC     (IX+2)
    JP      NZ, LOC_8AEC
    LD      A, (IX+3)
    LD      (IX+2), A
    LD      A, (IX+1)
    CP      4
    JP      Z, LOC_891B
    CP      2
    JP      Z, LOC_8B05
    CP      3
    JP      Z, LOC_8A5A
    CP      1
    JP      Z, SPIDER
    CP      5
    JP      Z, LOC_890E
    CALL    SUB_9673
    CALL    SUB_983E
    CP      80H
    LD      B, 6
    LD      C, 0
    JR      NC, LOC_88ED
    LD      B, 0CH
    LD      C, 0F4H

LOC_88ED:
    LD      (IX+8), B
    LD      (IX+2), A
    LD      (IX+1), 1
    LD      (IX+9), 0FFH
    LD      (IY+0), 4EH
    LD      (IY+4), 4EH
    LD      (IY+1), C
    LD      (IY+5), C
    SET     2, (IX+0)
RET

LOC_890E:
    LD      HL, $71C1
    DEC     (HL)
    JP      NZ, LOC_898D
    LD      (IX+1), 4
    JR      LOC_893F

LOC_891B:
    BIT     2, (IX+0)
    JR      NZ, LOC_898D
    BIT     1, (IX+0)
    JR      NZ, LOC_898D
    LD      A, ($70A0)
    LD      HL, $70E0
    BIT     1, A
    JR      Z, LOC_8932
    INC     HL

LOC_8932:
    LD      A, (HL)
    CP      2
    JR      C, LOC_898D
    LD      B, A
    CALL    SUB_983E
    CP      40H
    JR      NC, LOC_898D

LOC_893F:
    LD      B, (IY+1)
    LD      A, ($7020+1)
    BIT     3, (IX+8)
    JR      NZ, LOC_8986
    BIT     1, (IX+8)
    JR      Z, LOC_898D
    SUB     B
    JR      C, LOC_8989

LOC_8954:
    LD      B, (IY+0)
    LD      A, ($7020)
    SUB     B
    JR      NC, LOC_8967
    SET     0, (IX+8)
    RES     2, (IX+8)
    JR      LOC_896F

LOC_8967:
    SET     2, (IX+8)
    RES     0, (IX+8)

LOC_896F:
    LD      (IX+1), 5
    LD      A, ($70A0)
    LD      HL, $70E0
    BIT     1, A
    JR      Z, LOC_897E
    INC     HL

LOC_897E:
    LD      A, (HL)
    ADD     A, 0AH
    LD      ($71C1), A
    JR      LOC_898D

LOC_8986:
    SUB     B
    JR      C, LOC_8954

LOC_8989:
    SET     2, (IX+0)

LOC_898D:
    LD      C, (IX+4)
    LD      B, (IX+5)
    BIT     3, (IX+8)
    JR      Z, LOC_899D
    LD      A, B
    NEG
    LD      B, A

LOC_899D:
    BIT     0, (IX+8)
    JR      Z, LOC_89A7
    LD      A, C
    NEG
    LD      C, A

LOC_89A7:
    LD      A, (IY+0)
    ADD     A, C
    LD      (IY+0), A
    LD      (IY+4), A
    BIT     0, (IX+8)
    JR      Z, LOC_89C5
    CP      4EH
    JR      NC, LOC_8A04
    RES     0, (IX+8)
    SET     2, (IX+8)
    JR      LOC_89D1

LOC_89C5:
    CP      0AEH
    JR      C, LOC_8A04
    RES     2, (IX+8)
    SET     0, (IX+8)

LOC_89D1:
    RES     2, (IX+0)
    CALL    SUB_983E
    AND     3
    INC     A
    LD      (IX+4), A
    LD      A, (IX+1)
    CP      5
    JR      NZ, LOC_89EB
    LD      (IX+5), 1
    JR      LOC_8A04

LOC_89EB:
    CALL    SUB_983E
    AND     3
    LD      (IX+5), A
    LD      A, (IX+3)
    CP      3
    JR      C, LOC_8A04
    CALL    SUB_983E
    CP      0E6H
    JR      NC, LOC_8A04
    INC     (IX+5)

LOC_8A04:
    LD      A, (IY+1)
    ADD     A, B
    LD      (IY+1), A
    LD      (IY+5), A
    PUSH    AF
    CALL    SUB_8B27
    POP     AF
    BIT     3, (IX+8)
    JR      Z, LOC_8A22
    CP      4
    JP      NC, LOC_8A98
    LD      B, 20H
    JR      LOC_8A29

LOC_8A22:
    CP      0FCH
    JP      C, LOC_8A98
    LD      B, 0E0H

LOC_8A29:
    BIT     1, (IX+0)
    JR      NZ, LOC_8A4E
    SET     1, (IX+0)
    LD      A, (IY+1)
    ADD     A, B
    LD      (IY+1), A
    LD      (IY+5), A
    LD      A, (IY+3)
    XOR     80H
    LD      (IY+3), A
    LD      A, (IY+7)
    XOR     80H
    LD      (IY+7), A
RET

LOC_8A4E:
    LD      A, 0FH
    CALL    SUB_A11C
    LD      (IX+1), 0
    JP      LOC_8AEC

LOC_8A5A:
    DEC     (IX+6)
RET NZ
    LD      (IX+1), 0
    JP      SUB_9C8A

SPIDER:    
    LD      A, 10H
    CALL    SUB_A11C
    LD      (IY+2), 8
    LD      (IY+6), 0CH
    LD      (IY+3), 4
    LD      (IY+7), 0EH
    LD      (IX+1), 4
    BIT     3, (IX+8)
    JR      NZ, LOC_8A8C
    SET     7, (IY+3)
    SET     7, (IY+7)

LOC_8A8C:
    LD      HL, 3840H
    LD      DE, SPIDER_BODY_PATTERNS
    LD      BC, 20H
    JP      OUT_CTRL_OUT_DATA_PORT_06

LOC_8A98:
    LD      DE, ($7028)
    LD      A, 8
    ADD     A, E
    LD      E, A
    LD      B, 0AH
    LD      C, 0E5H
    BIT     3, (IX+8)
    JR      NZ, LOC_8AAE
    LD      B, 0E5H
    LD      C, 0AH

LOC_8AAE:
    BIT     1, (IX+0)
    LD      A, B
    JR      Z, LOC_8AB6
    LD      A, C

LOC_8AB6:
    ADD     A, D
    LD      D, A
    BIT     2, (IX+0)
    JR      Z, LOC_8ACE
    BIT     3, (IX+8)
    JR      NZ, LOC_8ACA
    CP      0D8H
    JR      C, LOC_8ACE
    JR      LOC_8AEC

LOC_8ACA:
    CP      10H
    JR      C, LOC_8AEC

LOC_8ACE:
    CALL    SUB_9F08
    CP      21H
    JR      C, LOC_8AEC
    CP      25H
    JR      NC, SPIDER_LEGS
    LD      A, 20H
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    JR      LOC_8AEC

SPIDER_LEGS:           
    CP      30H
    JR      C, LOC_8AEC
    LD      A, (IX+8)
    XOR     5
    LD      (IX+8), A

LOC_8AEC:
    LD      A, (IX+1)
    CP      2
RET Z
    DEC     (IX+6)
RET NZ
    LD      A, (IX+7)
    LD      (IX+6), A
    LD      HL, SPIDER_LEGS_PATTERNS
    LD      DE, 3860H
    JP      SUB_9EF2

LOC_8B05:
    LD      HL, SCORPION_EXPLOSION
    LD      DE, 3840H
    CALL    SUB_9EF2
    LD      A, (IX+9)
    CP      7
RET C
    LD      (IX+1), 3
    LD      (IX+3), 1
    LD      A, (IY+7)
    OR      0EH
    LD      (IY+7), A
    JP      SUB_9C7D

SUB_8B27:
    LD      HL, ($7028)
    LD      DE, ($7020)
    LD      BC, 103H
    ADD     HL, BC
    EX      DE, HL
    LD      BC, 504H
    ADD     HL, BC
    EX      DE, HL
    LD      BC, 606H
    LD      A, ($702B)
    BIT     7, A
    LD      A, 0E8H
    JR      NZ, LOC_8B46
    LD      A, 8

LOC_8B46:
    ADD     A, H
    LD      H, A
    LD      A, ($70CA)
    BIT     2, A
    JR      Z, LOC_8B53
    LD      A, 4
    ADD     A, L
    LD      L, A

LOC_8B53:
    CALL    SUB_9E38
RET NC
    LD      IY, $7028
    CALL    SUB_9C7D
    CALL    SUB_9C8A
    JP      LOC_8623

SUB_8B64:
    LD      A, ($70A6)
    BIT     6, A
    JR      Z, LOC_8B75
    LD      A, 4
    CALL    SUB_A11C
    LD      A, 15H
    JP      SUB_A11C

LOC_8B75:
    LD      A, 3
    SET     7, A
    CALL    SUB_A11C
    LD      A, 14H
    SET     7, A
    JP      SUB_A11C

SUB_8B83:
    LD      IX, $71C4
    LD      IY, $703C
    LD      HL, $70E8
    LD      (HL), 0CH

LOC_8B90:
    LD      L, (IX+5)
    LD      H, (IX+4)
    LD      ($70B9), HL
    LD      L, (IX+0AH)
    LD      H, (IX+9)
    LD      ($70BB), HL
    BIT     0, (IX+0)
    JP      Z, LOC_8DBF
    LD      A, (IX+1)
    CP      4
    JP      Z, LOC_8E16
    LD      HL, $70C1
    BIT     0, (HL)
    JP      Z, LOC_8DAA
    LD      DE, ($7024)
    INC     D
    INC     D
    INC     D
    INC     D
    BIT     6, (IX+0)
    JR      NZ, LOC_8BCD
    BIT     5, (IX+0)
    JR      Z, LOC_8C04

LOC_8BCD:
    DEC     D
    LD      L, (IY+0)
    LD      H, (IY+1)
    LD      BC, 50AH
    PUSH    HL
    CALL    SUB_9E38
    POP     DE
    JP      NC, LOC_8DAA
    CALL    SUB_9F08
    LD      (IX+5), L
    LD      (IX+4), H
    LD      ($70B9), HL
    LD      ($70BB), HL
    LD      A, 20H
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    CALL    SUB_9C7D
    RES     6, (IX+0)
    RES     5, (IX+0)
    SET     7, (IX+0)
    JR      LOC_8C47

LOC_8C04:
    CALL    SUB_9F08
    LD      ($70BD), HL
    LD      DE, ($70B9)
    SBC     HL, DE
    JR      Z, LOC_8C26
    LD      A, (IX+1)
    CP      0
    JP      NZ, LOC_8DAA
    LD      HL, ($70BD)
    LD      DE, ($70BB)
    SBC     HL, DE
    JP      NZ, LOC_8DAA

LOC_8C26:
    LD      HL, ($70B9)
    LD      A, 20H
    LD      (IX+5), L
    LD      (IX+4), H
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    LD      A, (IX+1)
    CP      0
    JR      Z, LOC_8C3F
    CP      3
    JR      NZ, LOC_8C47

LOC_8C3F:
    LD      A, 20H
    LD      HL, ($70BB)
    CALL    OUT_CTRL_OUT_DATA_PORT_01

LOC_8C47:
    SUB     A
    LD      ($70C1), A
    CALL    SUB_861C
    LD      BC, 10H
    LD      A, (IX+1)
    CP      2
    JR      NC, LOC_8C5B
    LD      BC, 100H

LOC_8C5B:
    CALL    SUB_9F2B
    CALL    SUB_8B64
    LD      A, (IX+1)
    CP      0
    JP      Z, LOC_8D92
    CP      3
    JP      Z, LOC_8D38
    LD      A, (IX+10H)
    CP      4
    JP      Z, LOC_8D38
    CP      3
    JR      NZ, LOC_8C81
    LD      C, 0
    LD      E, (IX+8)
    JR      LOC_8C98

LOC_8C81:
    LD      A, (IX+1)
    CP      1
    JR      NZ, LOC_8C96
    BIT     2, (IX+0)
    JR      Z, LOC_8C96
    SET     2, (IX+0FH)
    SET     2, (IX+1EH)

LOC_8C96:
    LD      C, 1

LOC_8C98:
    LD      A, (IX+16H)
    LD      B, 0E0H
    CP      70H
    JR      C, LOC_8CED
    CP      0B0H
    JR      C, LOC_8CCB
    SET     3, (IX+0FH)
    SET     4, (IX+0FH)
    LD      B, 98H
    LD      E, 8
    CP      0B8H
    JR      C, LOC_8D19
    LD      B, 90H
    LD      E, 2
    CP      0C0H
    JR      C, LOC_8D19
    LD      B, 80H
    LD      E, 8
    CP      0C8H
    JR      C, LOC_8D19
    LD      B, 78H
    LD      E, 2
    JR      LOC_8D19

LOC_8CCB:
    RES     3, (IX+0FH)
    RES     4, (IX+0FH)
    LD      B, 0A0H
    LD      E, 8
    CP      98H
    JR      C, LOC_8D19
    LD      E, 2
    CP      0A0H
    JR      C, LOC_8D19
    LD      B, 90H
    LD      E, 8
    CP      0A8H
    JR      C, LOC_8D19
    LD      E, 2
    JR      LOC_8D19

LOC_8CED:
    LD      A, C
    CP      0
    LD      A, (IX+16H)
    JR      Z, LOC_8D19
    LD      E, 8
    CP      58H
    JR      C, LOC_8D19
    LD      E, 2
    CP      60H
    JR      C, LOC_8D19
    LD      E, (IX+17H)
    RES     3, (IX+0FH)
    LD      D, A
    LD      A, (IX+10H)
    CP      3
    LD      A, D
    JR      C, LOC_8D19
    SET     3, (IX+1EH)
    SET     4, (IX+1EH)

LOC_8D19:
    LD      (IX+10H), C
    BIT     6, (IX+0FH)
    JR      NZ, LOC_8D38
    BIT     5, (IX+0FH)
    JR      NZ, LOC_8D38
    ADD     A, B
    LD      (IX+16H), A
    LD      (IX+17H), E
    LD      L, (IX+14H)
    LD      H, (IX+13H)
    CALL    OUT_CTRL_OUT_DATA_PORT_01

LOC_8D38:
    BIT     0, (IX-0FH)
    JR      Z, LOC_8D92
    LD      A, (IX-0EH)
    CP      4
    JR      Z, LOC_8D92
    CP      0
    JR      Z, LOC_8D92
    CP      3
    JR      Z, LOC_8D92
    CP      1
    JR      NZ, LOC_8D71
    LD      (IX-0EH), 0
    BIT     6, (IX-0FH)
    JR      NZ, LOC_8D92
    BIT     5, (IX-0FH)
    JR      NZ, LOC_8D92
    LD      L, (IX-5)
    LD      H, (IX-6)
    LD      A, (IX-8)
    ADD     A, 40H
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    JR      LOC_8D92

LOC_8D71:
    LD      (IX-0EH), 3
    BIT     6, (IX-0FH)
    JR      NZ, LOC_8D92
    BIT     5, (IX-0FH)
    JR      NZ, LOC_8D92
    LD      A, 3
    LD      B, (IX-8)
    LD      L, (IX-5)
    LD      H, (IX-6)
    LD      ($70BB), HL
    CALL    SUB_9463

LOC_8D92:
    LD      (IX+1), 4
    LD      (IX+2), 3
    LD      A, 0E0H
    LD      (IX+7), A
    LD      L, (IX+5)
    LD      H, (IX+4)
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    JR      LOC_8DAD

LOC_8DAA:
    CALL    SUB_8E7B

LOC_8DAD:
    LD      DE, 0FH
    ADD     IX, DE
    LD      DE, 4
    ADD     IY, DE
    LD      HL, $70E8
    DEC     (HL)
    JP      NZ, LOC_8B90
RET

LOC_8DBF:
    LD      A, ($70E7)
    AND     A
    JP      NZ, LOC_8DAD
    LD      HL, ($70EB)
    DEC     HL
    LD      ($70EB), HL
    LD      A, L
    OR      H
    JP      NZ, LOC_8DAD
    LD      HL, 3E8H
    LD      ($70EB), HL
    CALL    SUB_983E
    LD      DE, 19C1H
    LD      B, 8
    CP      80H
    JR      C, LOC_8DE9
    LD      DE, 19DDH
    LD      B, 2

LOC_8DE9:
    LD      (IX+8), B
    CALL    SUB_983E
    AND     7
    LD      B, A
    EX      DE, HL
    JR      Z, LOC_8DFB
    LD      DE, 20H

LOOP_8DF8:
    ADD     HL, DE
    DJNZ    LOOP_8DF8

LOC_8DFB:
    LD      (IX+5), L
    LD      (IX+0AH), L
    LD      (IX+4), H
    LD      (IX+9), H
    LD      (IX+0), 85H
    LD      (IX+1), 0
    LD      HL, $70E6
    INC     (HL)
    JP      LOC_8DAD

LOC_8E16:
    DEC     (IX+2)
    JP      NZ, LOC_8DAD
    LD      (IX+2), 2
    INC     (IX+7)
    LD      A, (IX+7)
    PUSH    AF
    SUB     0E0H
    LD      HL, LOGO_FLASH_COLORS
    LD      C, A
    LD      B, 0
    ADD     HL, BC
    LD      C, (HL)
    LD      B, 1
    LD      DE, 1CH
    POP     AF
    EX      AF, AF'
    CALL    OUT_CTRL_OUT_DATA_PORT_03
    EX      AF, AF'
    CP      0E8H
    JR      C, LOC_8E72
    LD      A, 21H
    LD      HL, ($70B9)
    PUSH    HL
    LD      DE, 1ABCH
    SBC     HL, DE
    POP     HL
    JR      C, LOC_8E50
    LD      A, 20H

LOC_8E50:
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    LD      (IX+0), 0E4H
    LD      HL, $70E7
    SUB     A
    CP      (HL)
    JR      Z, LOC_8E5F
    DEC     (HL)

LOC_8E5F:
    LD      HL, $70E6
    DEC     (HL)
    JP      NZ, LOC_8DAD
    CALL    SUB_95D1
    CALL    SUB_9C97
    CALL    SUB_9617
    JP      SUB_96BA

LOC_8E72:
    LD      HL, ($70B9)
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    JP      LOC_8DAD

SUB_8E7B:
    DEC     (IX+2)
    JP      NZ, LOC_93FD
    RES     7, (IX+0)
    LD      A, (IX+3)
    LD      (IX+2), A
    LD      A, (IX+1)
    CP      2
    JP      C, LOC_907E
    BIT     6, (IX+0)
    JP      NZ, LOC_8FDA
    BIT     5, (IX+0)
    JP      NZ, LOC_8FDA
    PUSH    AF
    LD      HL, ($70B9)
    LD      A, 20H
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    POP     AF
    CP      3
    JR      NZ, LOC_8EB7
    LD      HL, ($70BB)
    LD      A, 20H
    CALL    OUT_CTRL_OUT_DATA_PORT_01

LOC_8EB7:
    LD      HL, ($70B9)
    LD      (IX+0AH), L
    LD      (IX+9), H
    LD      L, (IX-5)
    LD      H, (IX-6)
    LD      (IX+5), L
    LD      (IX+4), H
    LD      A, (IX+7)
    LD      B, 7
    BIT     3, (IX+3)
    JR      NZ, LOC_8ED9
    LD      B, 6

LOC_8ED9:
    SUB     B
    LD      (IX+0BH), A
    LD      A, (IX-4)
    BIT     4, (IX+0)
    JR      NZ, LOC_8F19
    BIT     3, (IX+0)
    JR      Z, LOC_8F3C
    BIT     2, (IX+0)
    JR      Z, LOC_8EFE
    LD      B, 0A8H
    BIT     3, (IX-7)
    JR      NZ, LOC_8F3B
    LD      B, 0A0H
    JR      LOC_8F3B

LOC_8EFE:
    LD      B, 98H
    LD      A, (IX-7)
    BIT     6, (IX-0FH)
    JR      NZ, LOC_8F0F
    BIT     5, (IX-0FH)
    JR      Z, LOC_8F11

LOC_8F0F:
    XOR     0AH

LOC_8F11:
    BIT     3, A
    JR      NZ, LOC_8F3B
    LD      B, 90H
    JR      LOC_8F3B

LOC_8F19:
    BIT     3, (IX+0)
    JR      NZ, LOC_8F3C
    BIT     2, (IX+0)
    JR      Z, LOC_8F31
    LD      B, 0C0H
    BIT     3, (IX-7)
    JR      NZ, LOC_8F3B
    LD      B, 0C8H
    JR      LOC_8F3B

LOC_8F31:
    LD      B, 0B0H
    BIT     3, (IX-7)
    JR      NZ, LOC_8F3B
    LD      B, 0B8H

LOC_8F3B:
    LD      A, B

LOC_8F3C:
    LD      (IX+7), A
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    BIT     2, (IX+0)
    JR      Z, LOC_8F5A
    BIT     3, (IX+0)
    JR      NZ, LOC_8F5A
    LD      DE, 1A1DH
    AND     A
    SBC     HL, DE
    JR      NC, LOC_8F5A
    RES     2, (IX+0)

LOC_8F5A:
    LD      B, A
    LD      A, (IX+1)
    CP      3
    JR      NZ, LOC_8F6D
    LD      HL, ($70B9)
    LD      ($70BB), HL
    CALL    SUB_9463
    JR      LOC_8F71

LOC_8F6D:
    RES     7, (IX+0FH)

LOC_8F71:
    BIT     6, (IX-0FH)
    LD      B, 40H
    JR      NZ, LOC_8F80
    BIT     5, (IX-0FH)
    LD      B, 20H
RET Z

LOC_8F80:
    LD      E, (IX+0AH)
    LD      D, (IX+9)
    LD      L, (IX+5)
    LD      H, (IX+4)
    SUB     A
    SBC     HL, DE
RET NZ
    LD      A, (IX+0)
    OR      B
    LD      (IX+0), A
    LD      HL, ($70B9)
    LD      A, 20H
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    LD      A, (IX+1)
    CP      3
    JR      NZ, LOC_8FAE
    LD      HL, ($70BB)
    LD      A, 20H
    CALL    OUT_CTRL_OUT_DATA_PORT_01

LOC_8FAE:
    LD      L, (IX-3)
    LD      H, (IX-2)
    LD      (IY+0), L
    LD      (IY+1), H
    LD      (IX+5), L
    LD      (IX+4), H
    LD      (IY+3), 0CH
    LD      (IY+2), 20H
    LD      (IX+0EH), 20H
    BIT     3, (IX+8)
RET NZ
    LD      (IY+2), 1CH
    LD      (IX+0EH), 1CH
RET

LOC_8FDA:
    LD      L, (IX+5)
    LD      H, (IX+4)
    LD      (IX+0CH), L
    LD      (IX+0DH), H
    LD      L, (IX-3)
    LD      H, (IX-2)
    LD      (IY+0), L
    LD      (IY+1), H
    LD      (IX+5), L
    LD      (IX+4), H
    LD      A, (IY+2)
    LD      (IX+0EH), A
    LD      A, (IX-1)
    LD      (IY+2), A
    LD      (IY+3), 0CH
    LD      A, (IX+8)
    XOR     0AH
    LD      (IX+8), A
    BIT     6, (IX-0FH)
    JR      Z, LOC_901B
    BIT     5, (IX-0FH)
RET NZ

LOC_901B:
    LD      E, (IX+0CH)
    LD      D, (IX+0DH)
    LD      L, (IY+0)
    LD      H, (IY+1)
    SUB     A
    SBC     HL, DE
RET NZ
    CALL    SUB_9F08
    LD      (IX+5), L
    LD      (IX+4), H
    LD      (IX+0AH), L
    LD      (IX+9), H
    SET     7, (IX+0)
    RES     6, (IX+0)
    RES     5, (IX+0)
    CALL    SUB_9C7D
    LD      A, (IX+1)
    CP      3
RET NZ
    LD      DE, 20H
    ADD     HL, DE
    LD      (IX+5), L
    LD      (IX+4), H
    LD      (IX-5), L
    LD      (IX-6), H
    RES     7, (IX+0)
    LD      A, (IX-8)
    CP      38H
    LD      B, 0B0H
    JR      C, LOC_907A
    CP      40H
    LD      B, 0B8H
    JR      C, LOC_907A
    CP      58H
    LD      B, 0B0H
    JR      C, LOC_907A
    LD      B, 0B8H

LOC_907A:
    LD      (IX+7), B
RET

LOC_907E:
    LD      HL, ($70B9)
    BIT     6, (IX+0)
    JP      NZ, LOC_930C
    BIT     5, (IX+0)
    JP      NZ, LOC_92CD
    BIT     2, (IX+0)
    JR      Z, LOC_90A3
    PUSH    HL
    LD      DE, 1A1DH
    SUB     A
    SBC     HL, DE
    POP     HL
    JR      NC, LOC_90A3
    RES     2, (IX+0)

LOC_90A3:
    BIT     3, (IX+8)
    JP      NZ, LOC_910B
    INC     HL
    LD      B, 38H
    CALL    OUT_CTRL_IN_DATA_PORT_00
    CP      20H
    JP      Z, LOC_9361
    CP      0E0H
    JP      NC, LOC_9361
    CP      28H
    JR      C, LOC_90C3
    CP      2CH
    JP      C, LOC_9221

LOC_90C3:
    LD      DE, 20H
    LD      B, 48H
    BIT     2, (IX+0)
    JR      Z, LOC_90D3
    LD      DE, 0FFE0H
    LD      B, 40H

LOC_90D3:
    LD      HL, ($70B9)
    ADD     HL, DE
    CALL    OUT_CTRL_IN_DATA_PORT_00
    CP      20H
    JP      Z, LOC_9329
    CP      0E0H
    JP      NC, LOC_9329
    DEC     HL
    CALL    OUT_CTRL_IN_DATA_PORT_00
    CP      20H
    JR      Z, LOC_9104
    INC     HL
    INC     HL
    CALL    OUT_CTRL_IN_DATA_PORT_00
    CP      20H
    JR      Z, LOC_90FC
    CP      0E0H
    JR      NC, LOC_90FC
    JP      LOC_915A

LOC_90FC:
    LD      A, (IX+8)
    XOR     0AH
    LD      (IX+8), A

LOC_9104:
    LD      HL, ($70B9)
    ADD     HL, DE
    JP      LOC_9329

LOC_910B:
    DEC     HL
    LD      B, 30H
    CALL    OUT_CTRL_IN_DATA_PORT_00
    CP      20H
    JP      Z, LOC_9361
    CP      0E0H
    JP      NC, LOC_9361
    CP      28H
    JR      C, LOC_9124
    CP      2CH
    JP      C, LOC_9221

LOC_9124:
    LD      DE, 20H
    LD      B, 48H
    BIT     2, (IX+0)
    JR      Z, LOC_9134
    LD      DE, 0FFE0H
    LD      B, 40H

LOC_9134:
    LD      HL, ($70B9)
    ADD     HL, DE
    CALL    OUT_CTRL_IN_DATA_PORT_00
    CP      20H
    JP      Z, LOC_9329
    CP      0E0H
    JP      NC, LOC_9329
    INC     HL
    CALL    OUT_CTRL_IN_DATA_PORT_00
    CP      20H
    JR      Z, LOC_9104
    DEC     HL
    DEC     HL
    CALL    OUT_CTRL_IN_DATA_PORT_00
    CP      20H
    JR      Z, LOC_90FC
    CP      0E0H
    JR      NC, LOC_90FC

LOC_915A:
    RES     6, (IX+0)
    SET     5, (IX+0)
    LD      HL, ($70B9)
    LD      DE, 1AA0H
    SUB     A
    SBC     HL, DE
    JP      C, LOC_9229
    RES     5, (IX+0)
    LD      HL, ($70B9)
    LD      DE, 0FFE0H
    LD      B, 40H
    ADD     HL, DE
    SET     2, (IX+0)
    LD      A, (IX+1)
    CP      0
    JP      Z, LOC_9213
    SET     2, (IX+0FH)
    PUSH    IX
    PUSH    IY
    PUSH    HL
    PUSH    BC
    LD      IX, $71C4
    LD      IY, $703C
    LD      B, 0BH

LOOP_919B:
    LD      DE, 0FH
    ADD     IX, DE
    LD      DE, 4
    ADD     IY, DE
    LD      A, (IX+1)
    CP      3
    JR      Z, LOC_91B1
    DJNZ    LOOP_919B
    JP      LOC_920D

LOC_91B1:
    BIT     6, (IX+0)
    JR      NZ, LOC_920D
    BIT     5, (IX+0)
    JR      NZ, LOC_920D
    LD      (IX+1), 0
    LD      A, (IX+8)
    XOR     0AH
    LD      (IX+8), A
    LD      (IX+7), 30H
    BIT     3, A
    JR      NZ, LOC_91D5
    LD      (IX+7), 38H

LOC_91D5:
    LD      B, 3
    LD      A, (IX-0EH)
    CP      2
    JR      Z, LOC_91E0
    LD      B, 0

LOC_91E0:
    LD      (IX-0EH), B
    LD      L, (IX+0AH)
    LD      H, (IX+9)
    PUSH    HL
    LD      L, (IX+5)
    LD      (IX+0AH), L
    LD      H, (IX+4)
    LD      (IX+9), H
    POP     HL
    LD      (IX+5), L
    LD      (IX+4), H
    LD      (IX+2), 4
    LD      (IX+3), 4
    LD      (IX+6), 2
    SET     2, (IX+0)

LOC_920D:
    POP     BC
    POP     HL
    POP     IY
    POP     IX

LOC_9213:
    LD      A, ($70E7)
    AND     A
    JP      Z, LOC_9329
    DEC     A
    LD      ($70E7), A
    JP      LOC_9329

LOC_9221:
    SET     6, (IX+0)
    RES     5, (IX+0)

LOC_9229:
    SET     3, (IX+0)
    LD      A, (IX+1)
    CP      0
    JR      Z, LOC_9238
    SET     3, (IX+0FH)

LOC_9238:
    LD      HL, ($70B9)
    PUSH    HL
    LD      A, 20H
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    LD      A, (IX+1)
    CP      0
    JR      NZ, LOC_9250
    LD      HL, ($70BB)
    LD      A, 20H
    CALL    OUT_CTRL_OUT_DATA_PORT_01

LOC_9250:
    POP     HL
    LD      (IX+0AH), L
    LD      (IX+9), H
    CALL    SUB_9C5A
    LD      (IY+0), L
    LD      (IX+5), L
    LD      (IY+1), H
    LD      (IX+4), H
    LD      (IY+3), 0CH
    LD      (IY+2), 20H
    LD      (IX+0EH), 20H
    BIT     3, (IX+8)
RET NZ
    LD      (IY+2), 1CH
    LD      (IX+0EH), 1CH
RET

SUB_9280:
    LD      (IX+0CH), L
    LD      (IX+0DH), H
    LD      A, (IY+2)
    LD      (IX+0EH), A
    LD      B, 8
    LD      A, L
    CP      0B0H
    JR      C, LOC_929B
    SET     2, (IX+0)
    LD      B, 0F8H
    JR      LOC_92AC

LOC_929B:
    RES     2, (IX+0)
    PUSH    AF
    LD      A, (IX+1)
    CP      0
    JR      Z, LOC_92AB
    RES     2, (IX+0FH)

LOC_92AB:
    POP     AF

LOC_92AC:
    ADD     A, B
    LD      (IY+0), A
    LD      (IX+5), A
    BIT     3, (IX+8)
    LD      C, 20H
    JR      Z, LOC_92BD
    LD      C, 1CH

LOC_92BD:
    LD      (IY+3), 0CH
    LD      (IY+2), C
    LD      A, (IX+8)
    XOR     0AH
    LD      (IX+8), A
RET

LOC_92CD:
    LD      HL, ($70B9)
    CALL    SUB_9280
    LD      E, (IY+0)
    LD      D, (IY+1)

LOC_92D9:
    CALL    SUB_9F08
    CP      20H
RET NZ
    LD      A, (IX+8)
    XOR     0AH
    LD      (IX+8), A
    BIT     3, A
    LD      A, 38H
    JR      Z, LOC_92EF
    LD      A, 30H

LOC_92EF:
    LD      (IX+7), A
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    LD      (IX+5), L
    LD      (IX+0AH), L
    LD      (IX+4), H
    LD      (IX+9), H
    RES     5, (IX+0)
    RES     6, (IX+0)
    JP      SUB_9C7D

LOC_930C:
    LD      HL, ($70B9)
    CALL    SUB_9280
    LD      A, (IY+0)
    CP      0B0H
RET C
    LD      E, (IY+0)
    LD      D, (IY+1)
    RES     6, (IX+0)
    SET     5, (IX+0)
    JP      LOC_92D9

LOC_9329:
    LD      A, (IX+1)
    BIT     3, (IX+0)
    JR      Z, LOC_934B
    LD      A, (IX+8)
    XOR     0AH
    LD      (IX+8), A
    SET     4, (IX+0)
    LD      A, (IX+1)
    CP      0
    JR      Z, LOC_9399
    SET     4, (IX+0FH)
    JR      LOC_9399

LOC_934B:
    SET     3, (IX+0)
    CP      0
    JR      Z, LOC_9357
    SET     3, (IX+0FH)

LOC_9357:
    LD      A, (IX+8)
    XOR     0AH
    LD      (IX+8), A
    JR      LOC_9384

LOC_9361:
    LD      A, (IX+1)
    BIT     3, (IX+0)
    JR      Z, LOC_9384
    RES     3, (IX+0)
    SET     4, (IX+0)
    CP      0
    JR      Z, LOC_9399
    RES     3, (IX+0FH)
    SET     4, (IX+0FH)
    RES     7, (IX+0FH)
    JR      LOC_9399

LOC_9384:
    BIT     4, (IX+0)
    JR      Z, LOC_9399
    RES     4, (IX+0)
    LD      A, (IX+1)
    CP      0
    JR      Z, LOC_9399
    RES     4, (IX+0FH)

LOC_9399:
    PUSH    HL
    LD      HL, ($70B9)
    LD      A, 20H
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    LD      A, (IX+1)
    CP      0
    JR      NZ, LOC_93B3
    PUSH    HL
    LD      HL, ($70BB)
    LD      A, 20H
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    POP     HL

LOC_93B3:
    LD      (IX+0AH), L
    LD      (IX+9), H
    POP     HL
    LD      (IX+5), L
    LD      (IX+4), H
    LD      A, (IX+7)
    LD      C, 19H
    BIT     3, (IX+3)
    JR      NZ, LOC_93CD
    LD      C, 1AH

LOC_93CD:
    ADD     A, C
    LD      (IX+0BH), A
    LD      (IX+7), B
    LD      A, B
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    LD      A, ($70E6)
    CP      1
    JR      NZ, LOC_93EB
    LD      (IX+3), 4
    LD      (IX+2), 4
    LD      (IX+6), 2

LOC_93EB:
    LD      A, (IX+1)
    CP      0
RET NZ
    LD      A, 40H
    ADD     A, B
    LD      L, (IX+0AH)
    LD      H, (IX+9)
    JP      OUT_CTRL_OUT_DATA_PORT_01

LOC_93FD:
    LD      A, (IX+1)
    CP      0
    JR      Z, LOC_942D
    BIT     7, (IX+0)
RET NZ
    BIT     6, (IX+0)
    JP      NZ, LOC_949F
    BIT     5, (IX+0)
    JP      NZ, LOC_949F
    LD      A, (IX+7)
    LD      B, (IX+6)
    ADD     A, B
    LD      HL, ($70B9)
    LD      (IX+7), A
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    LD      B, A
    LD      A, (IX+1)
    JR      SUB_9463

LOC_942D:
    BIT     6, (IX+0)
    JR      NZ, LOC_949F
    BIT     5, (IX+0)
    JR      NZ, LOC_949F
    LD      A, (IX+3)
    LD      B, (IX+2)
    CP      B
RET C
    LD      A, (IX+7)
    LD      B, (IX+6)
    ADD     A, B
    LD      (IX+7), A
    LD      HL, ($70B9)
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    LD      B, A
    LD      DE, ($70BB)
    SUB     A
    SBC     HL, DE
RET Z
    LD      A, 40H

LOC_945C:
    ADD     A, B
    LD      HL, ($70BB)
    JP      OUT_CTRL_OUT_DATA_PORT_01

SUB_9463:
    CP      3
RET NZ
    LD      L, (IX+5)
    LD      H, (IX+4)
    LD      E, (IX+0AH)
    LD      D, (IX+9)
    AND     A
    SBC     HL, DE
RET Z
    LD      A, B
    CP      70H
    LD      B, 20H
    JR      C, LOC_945C
    LD      B, 0E0H
    CP      0A0H
    JR      C, LOC_945C
    LD      B, 0D0H
    CP      0B0H
    JR      C, LOC_945C
    LD      B, 0D8H
    CP      0B8H
    JR      C, LOC_945C
    LD      B, 0D0H
    CP      0C0H
    JR      C, LOC_945C
    LD      B, 0C0H
    CP      0C8H
    JR      C, LOC_945C
    LD      B, 0B8H
    JR      LOC_945C

LOC_949F:
    LD      A, (IY+0)
    LD      B, (IX+6)
    ADD     A, B
    LD      (IY+0), A
    LD      E, (IY+0)
    LD      D, (IY+1)
    LD      HL, ($7020)
    INC     H
    LD      BC, 606H
    CALL    SUB_9E38
RET NC
    JP      LOC_8623

SUB_94BD:
    LD      HL, UNK_B56B
    CALL    SUB_A0AC
    CALL    SUB_9E7C
    CALL    SUB_9E6C
    LD      HL, $7004
    LD      DE, $7005
    LD      BC, 2A1H
    LD      (HL), 0
    LDIR
    LD      HL, 0
    SUB     A
    LD      BC, 5000H
    CALL    OUT_CTRL_OUT_DATA_PORT_02
    LD      HL, 0
    LD      DE, FONTS_AND_MUSHROOM_PATTERNS
    LD      BC, 180H
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    LD      HL, 2000H
    LD      DE, CENT_COLOR_TABLE
    LD      BC, 1EH
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    LD      HL, 1B00H
    LD      A, 0D0H
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    JP      SUB_9E64

SUB_9503:
    LD      A, ($70A0)
    LD      B, 5
    LD      C, 0FFH
    LD      HL, 100H
    CP      10H
    JR      Z, LOC_9529
    CP      11H
    JR      Z, LOC_9529
    DEC     B
    LD      C, 2
    LD      HL, 120H
    CP      20H
    JR      Z, LOC_9529
    CP      21H
    JR      Z, LOC_9529
    DEC     B
    LD      C, 5
    LD      HL, 140H

LOC_9529:
    LD      ($70B7), HL
    LD      ($70B3), HL
    LD      ($70B5), HL
    LD      HL, $70E0
    LD      (HL), C
    INC     HL
    LD      (HL), C
    LD      HL, $70A1
    LD      (HL), B
    INC     HL
    BIT     0, A
    JR      NZ, LOC_9543
    LD      B, 0

LOC_9543:
    LD      (HL), B
    CALL    SUB_9E6C
    LD      DE, BUG_BLASTER_PATTERNS
    LD      HL, 3800H
    LD      BC, 120H
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    CALL    SUB_9863
    CALL    SUB_9E64
    LD      DE, $70F0
    LD      HL, $70EF
    LD      BC, 0D2H
    LD      (HL), 0
    LDIR
    LD      A, ($70A0)
    LD      HL, 1837H
    BIT     0, A
    JR      Z, LOC_9573
    LD      HL, 182DH

LOC_9573:
    LD      ($70B1), HL
RET

SUB_9577:
    LD      HL, 1800H
    LD      A, 20H
    LD      BC, 40H
    CALL    OUT_CTRL_OUT_DATA_PORT_02
    LD      HL, ($70B1)
    LD      DE, 0FFDFH
    ADD     HL, DE
    LD      DE, HI_SCORE_TXT
    LD      BC, 8
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    CALL    SUB_9FE9
    LD      HL, $70A8
    LD      BC, 1822H
    LD      DE, 1802H
    LD      A, 1
    CALL    SUB_95B4
    LD      A, ($70A0)
    BIT     0, A
RET Z
    LD      HL, $70AB
    LD      BC, 1837H
    LD      DE, 1817H
    LD      A, 2

SUB_95B4:
    PUSH    BC
    PUSH    HL
    PUSH    AF
    EX      DE, HL
    LD      DE, PLAYER_ONE_TXT
    LD      BC, 6
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    POP     AF
    OUT     (DATA_PORT), A
    POP     HL
    LD      DE, $70AE
    LD      BC, 3
    LDIR
    POP     BC
    JP      LOC_9F78

SUB_95D1:
    LD      A, 5
    LD      ($70EE), A
    ADD     A, 0AH
    LD      ($70ED), A
    LD      HL, $70E0
    LD      A, ($70A0)
    BIT     1, A
    JR      Z, LOC_95E8
    LD      HL, $70E1

LOC_95E8:
    LD      A, (HL)
    INC     A
    CP      0CH
    JR      C, LOC_95F0
    LD      A, 3

LOC_95F0:
    LD      (HL), A
    LD      HL, BYTE_B795
    ADD     A, A
    LD      B, 0
    LD      C, A
    ADD     HL, BC
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    LD      A, ($70A0)
    BIT     1, A
    JR      NZ, LOC_9609
    LD      ($70E2), DE
    JR      LOC_960D

LOC_9609:
    LD      ($70E4), DE

LOC_960D:
    LD      A, 3CH
    LD      ($71C2), A
    ADD     A, A
    LD      ($71C3), A
RET

SUB_9617:
    SUB     A
    LD      ($70A6), A
    LD      ($70A5), A
    LD      ($70C1), A
    LD      A, ($70A0)
    LD      HL, $70E0
    BIT     1, A
    JR      Z, LOC_962C
    INC     HL

LOC_962C:
    LD      A, (HL)
    AND     0FH
    LD      HL, LOGO_FLASH_COLORS
    LD      B, 0
    LD      C, A
    ADD     HL, BC
    LD      A, (HL)
    RLCA
    RLCA
    RLCA
    RLCA
    LD      ($7023), A
RET

SUB_963F:
    CALL    SUB_964A
    LD      A, ($70A0)
    BIT     0, A
RET Z
    JR      SUB_9652

SUB_964A:
    LD      HL, 1AE3H
    LD      A, ($70A1)
    JR      SUB_9658

SUB_9652:
    LD      HL, 1AFAH
    LD      A, ($70A2)

SUB_9658:
    BIT     7, A
    JR      NZ, LOC_966E
    AND     A
    JR      Z, LOC_966E
    LD      B, 5
    CP      5
    JR      NC, LOC_9666
    LD      B, A

LOC_9666:
    LD      A, 0AH

LOC_9668:
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    INC     HL
    DJNZ    LOC_9668

LOC_966E:
    LD      A, 0BH
    JP      OUT_CTRL_OUT_DATA_PORT_01

SUB_9673:
    PUSH    IY
    LD      IY, $7028
    CALL    SUB_9C8A
    LD      DE, $70C2
    LD      BC, 0
    JR      LOC_96A1

SUB_9684:
    PUSH    IY
    LD      IY, $7034
    CALL    SUB_9C8A
    LD      DE, $70D6
    LD      BC, 0AH
    JR      LOC_96A1

SUB_9695:
    PUSH    IY
    LD      IY, $7030
    LD      DE, $70CC
    LD      BC, 14H

LOC_96A1:
    CALL    SUB_9C7D
    POP     IY
    LD      HL, ($70E2)
    LD      A, ($70A0)
    BIT     1, A
    JR      Z, LOC_96B3
    LD      HL, ($70E4)

LOC_96B3:
    ADD     HL, BC
    LD      BC, 0AH
    LDIR
RET

SUB_96BA:
    LD      A, ($70A0)
    LD      HL, ($70E2)
    BIT     1, A
    JR      Z, LOC_96C7
    LD      HL, ($70E4)

LOC_96C7:
    LD      DE, 1EH
    ADD     HL, DE
    LD      ($70BD), HL
    LD      DE, $71C4
    LD      A, 0CH
    LD      ($70E6), A
    LD      ($70E7), A

LOC_96D9:
    LD      HL, ($70BD)
    LD      BC, 0FH
    LDIR
    DEC     A
    JR      NZ, LOC_96D9
    LD      HL, $70A0
    BIT     0, (HL)
    JR      NZ, LOC_9705
    CALL    SUB_983E
    AND     7
    LD      C, 0BH
    ADD     A, C
    LD      C, A
    CALL    SUB_983E
    CP      80H
    LD      L, 8
    LD      H, 0B0H
    JR      C, LOC_971C
    LD      L, 2
    LD      H, 0B8H
    JR      LOC_971C

LOC_9705:
    CALL    SUB_983E
    CP      80H
    LD      C, 0AH
    LD      A, 15H
    LD      L, 2
    LD      H, 0B8H
    JR      C, LOC_971C
    LD      L, 8
    LD      H, 0B0H
    LD      C, 15H
    LD      A, 0AH

LOC_971C:
    LD      ($70C0), A
    LD      IX, $71C4
    LD      (IX+1), 1
    LD      (IX+7), 48H
    SET     3, (IX+0)
    LD      DE, 0FH
    LD      B, 0CH
    SUB     A
    JR      LOC_9744

LOC_9737:
    ADD     IX, DE
    LD      (IX+7), H
    SET     7, (IX+0)
    LD      (IX+1), 2

LOC_9744:
    ADD     A, (IX+3)
    LD      (IX+2), A
    LD      (IX+5), C
    LD      (IX+0AH), C
    LD      (IX+8), L
    DJNZ    LOC_9737
    LD      (IX+1), 3
    LD      A, ($70A0)
    BIT     1, A
    LD      A, ($70E0)
    JR      Z, LOC_9766
    LD      A, ($70E1)

LOC_9766:
    AND     A
    JP      Z, LOC_982A
    CP      0BH
    JR      C, LOC_9776
    LD      IX, $71C4
    LD      A, 0CH
    JR      LOC_978B

LOC_9776:
    LD      B, A
    LD      DE, 0FFF1H
    LD      IX, $7269

LOC_977E:
    ADD     IX, DE
    DJNZ    LOC_977E
    LD      (IX+1), 3
    LD      DE, 0FH
    ADD     IX, DE

LOC_978B:
    LD      B, A
    LD      HL, $70BD
    LD      A, (IX+3)
    CP      8
    LD      E, 4
    LD      D, 2
    JR      Z, LOC_979E
    LD      E, 8
    LD      D, 1

LOC_979E:
    LD      (HL), E
    INC     HL
    LD      (HL), D
    LD      DE, 0FH
    LD      A, ($70A0)
    BIT     0, A
    JR      NZ, LOC_97F3
    LD      A, B
    LD      C, 8
    LD      HL, 1857H
    EXX
    LD      HL, 1847H
    LD      DE, 0FH
    LD      C, 2
    EXX

LOC_97BB:
    LD      ($70BF), A
    LD      (IX+0AH), L
    LD      (IX+5), L
    LD      (IX+1), 0
    RES     7, (IX+0)
    LD      (IX+7), 48H
    LD      (IX+8), C
    LD      A, ($70BD)
    LD      (IX+3), A
    LD      A, ($70BD+1)
    LD      (IX+6), A
    LD      A, L
    CP      48H
    JR      NC, LOC_97E7
    DEC     HL
    JR      LOC_97E8

LOC_97E7:
    INC     HL

LOC_97E8:
    EXX
    ADD     IX, DE
    LD      A, ($70BF)
    DEC     A
    JR      NZ, LOC_97BB
    JR      LOC_982A

LOC_97F3:
    LD      H, 0
    LD      A, ($70C0)

LOC_97F8:
    LD      (IX+5), A
    LD      (IX+0AH), A
    EX      AF, AF'
    LD      A, ($70BD)
    LD      (IX+3), A
    LD      A, H
    ADD     A, 8
    LD      H, A
    LD      (IX+2), A
    LD      A, ($70BD+1)
    LD      (IX+6), A
    LD      A, C
    XOR     0AH
    LD      C, A
    LD      (IX+8), C
    EX      AF, AF'
    LD      (IX+1), 0
    RES     7, (IX+0)
    LD      (IX+7), 48H
    ADD     IX, DE
    DJNZ    LOC_97F8

LOC_982A:
    LD      HL, $703C
    LD      DE, $703D
    LD      BC, 30H
    LD      (HL), 0
    LDIR
    LD      HL, 3E8H
    LD      ($70EB), HL
RET

SUB_983E:
    PUSH    HL
    PUSH    BC
    LD      B, 0FFH
    LD      HL, ($7006)
    LD      A, H
    RRCA
    RRCA
    XOR     H
    RRCA
    XOR     L
    RRCA
    RRCA
    RRCA
    RRCA
    XOR     L
    RRA
    ADC     HL, HL
    LD      A, R
    ADD     A, L
    LD      L, A
    LD      ($7006), HL

LOC_985A:
    CP      B
    JR      C, LOC_9860
    SUB     B
    JR      LOC_985A

LOC_9860:
    POP     BC
    POP     HL
RET

SUB_9863:
    LD      DE, FLEA_EXPLOSION
    LD      HL, 700H
    LD      BC, 40H
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    LD      DE, $70EF
    LD      HL, CENT_HEAD_WEST
    LD      BC, 40H
    LDIR
    LD      HL, 180H
    CALL    SUB_991B
    LD      HL, 240H
    CALL    SUB_991B
    LD      HL, 1C0H
    CALL    SUB_991B
    LD      HL, 200H
    CALL    SUB_991B
    LD      DE, $70EF
    LD      HL, CENT_SEG_01_WEST
    LD      BC, 40H
    LDIR
    LD      HL, 280H
    CALL    SUB_991B
    LD      HL, 340H
    CALL    SUB_991B
    LD      HL, 2C0H
    CALL    SUB_991B
    LD      HL, 300H
    CALL    SUB_991B
    LD      DE, $70EF
    LD      HL, CENT_SEG_02_WEST
    LD      BC, 40H
    LDIR
    LD      HL, 380H
    CALL    SUB_991B
    LD      HL, 440H
    CALL    SUB_991B
    LD      HL, 3C0H
    CALL    SUB_991B
    LD      HL, 400H
    CALL    SUB_991B
    LD      DE, $70EF
    LD      HL, CENT_SEG_SOUTH_WEST
    LD      BC, 40H
    LDIR
    LD      HL, 480H
    CALL    SUB_991B
    LD      HL, 5C0H
    CALL    SUB_991B
    LD      HL, 540H
    CALL    SUB_991B
    LD      HL, 600H
    CALL    SUB_991B
    LD      DE, $70EF
    LD      HL, CENT_SEG_SOUTH_EAST
    LD      BC, 40H
    LDIR
    LD      HL, 4C0H
    CALL    SUB_991B
    LD      HL, 640H
    CALL    SUB_991B
    LD      HL, 500H
    CALL    SUB_991B
    LD      HL, 580H

SUB_991B:
    LD      DE, $70EF
    LD      BC, 40H
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    LD      HL, $70EF
    LD      B, 8
    LD      A, 1
    INC     A

LOC_992C:
    DEC     A
    JR      Z, LOCRET_995B
    PUSH    AF
    PUSH    BC
    PUSH    HL

LOOP_9932:             
    PUSH    BC
    LD      B, 8
    LD      E, L
    LD      D, H

LOC_9937:
    LD      L, E
    LD      H, D
    PUSH    BC
    LD      B, 8

LOC_993C:
    CP      A
    RR      (HL)
    RLA
    INC     HL
    DJNZ    LOC_993C
    POP     BC
    PUSH    AF
    DJNZ    LOC_9937
    LD      B, 8
    DEC     HL

LOOP_994A:             
    POP     AF
    LD      (HL), A
    DEC     HL
    DJNZ    LOOP_994A
    POP     BC
    LD      DE, 9
    ADD     HL, DE
    DJNZ    LOOP_9932
    POP     HL
    POP     BC
    POP     AF
    JR      LOC_992C

LOCRET_995B:           
RET

SUB_995C:
    LD      A, ($70A0)
    LD      HL, $70A9
    LD      BC, ($70B3)
    EXX
    LD      DE, $70B3
    LD      HL, $70A1
    BIT     1, A
    JR      Z, LOC_997F
    LD      BC, ($70B5)
    LD      HL, $70AC
    EXX
    LD      DE, $70B5
    LD      HL, $70A2

LOC_997F:
    EXX
    SUB     A
    LD      E, (HL)
    DEC     HL
    LD      D, (HL)
    EX      DE, HL
    SBC     HL, BC
RET C
    EXX
    INC     (HL)
    EX      DE, HL
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    EX      DE, HL
    LD      BC, ($70B7)
    ADD     HL, BC
    EX      DE, HL
    LD      (HL), D
    DEC     HL
    LD      (HL), E
    CALL    SUB_99DA
    LD      A, 8
    CALL    SUB_A11C
    LD      A, 0EH
    JP      SUB_A11C

SUB_99A5:
    LD      DE, SPACE_TXT
    LD      A, ($70A0)
    BIT     1, A
    JR      Z, LOC_99B2
    LD      DE, PLAYER_TWO_TXT

LOC_99B2:
    LD      ($70B9), DE
    LD      DE, GET_READY_TXT
    LD      ($70BB), DE
    LD      B, 4
    JP      SUB_9A09

SUB_99C2:
    PUSH    DE
    PUSH    BC
    LD      B, 1EH
    JR      LOOP_99CC

SUB_99C8:
    PUSH    DE
    PUSH    BC
    LD      B, 32H

LOOP_99CC:             
    LD      DE, 5

LOC_99CF:
    DEC     D
    JR      NZ, LOC_99CF
    DEC     E
    JR      NZ, LOC_99CF
    DJNZ    LOOP_99CC
    POP     BC
    POP     DE
RET

SUB_99DA:
    LD      A, ($70A0)
    BIT     0, A
    JR      NZ, LOC_99EB
    LD      A, ($70A1)
    DEC     A
    LD      HL, 1AE3H
    JP      SUB_9658

LOC_99EB:
    BIT     1, A
    JR      NZ, LOC_99FC
    LD      HL, 1AE3H
    LD      A, ($70A1)
    DEC     A
    CALL    SUB_9658
    JP      SUB_9652


LOC_99FC:
    LD      HL, 1AFAH
    LD      A, ($70A2)
    DEC     A
    CALL    SUB_9658
    JP      SUB_964A

SUB_9A09:
    CALL    SUB_9E6C
    PUSH    BC
    LD      B, 0DH
    LD      HL, 198AH
    LD      DE, $71A7

LOC_9A15:
    CALL    OUT_CTRL_IN_DATA_PORT_00
    LD      (DE), A
    INC     DE
    INC     HL
    DJNZ    LOC_9A15
    LD      B, 0DH
    LD      HL, 19AAH

LOC_9A22:
    CALL    OUT_CTRL_IN_DATA_PORT_00
    LD      (DE), A
    INC     DE
    INC     HL
    DJNZ    LOC_9A22
    POP     BC

LOC_9A2B:
    PUSH    BC
    LD      HL, 198AH
    LD      DE, ($70B9)
    LD      BC, 0DH
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    LD      HL, 19AAH
    LD      DE, ($70BB)
    LD      BC, 0DH
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    CALL    SUB_99C8
    LD      HL, 198AH
    LD      DE, BLANK_LINE_TXT
    LD      BC, 0DH
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    LD      HL, 19AAH
    LD      DE, BLANK_LINE_TXT
    LD      BC, 0DH
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    CALL    SUB_99C8
    POP     BC
    DJNZ    LOC_9A2B
    CALL    SUB_9E64
    CALL    SUB_A04A
    LD      HL, 198AH
    LD      DE, $71A7
    LD      BC, 0DH
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    LD      HL, 19AAH
    LD      BC, 0DH
    JP      OUT_CTRL_OUT_DATA_PORT_06

SUB_9A82:
    LD      A, 0
    CALL    SUB_A11C
    LD      A, 8
    CALL    SUB_A11C
    LD      A, 0FH
    CALL    SUB_A11C
    LD      A, 12H
    CALL    SUB_A11C
    LD      B, 1CH
    LD      HL, $7020

LOC_9A9B:
    LD      (HL), 0
    INC     HL
    DJNZ    LOC_9A9B
    CALL    SUB_A063
    LD      A, ($70A0)
    LD      HL, $70EF
    LD      DE, $70A1
    BIT     0, A
    JR      Z, LOC_9ABA
    BIT     1, A
    JR      Z, LOC_9ABA
    LD      HL, $714B
    LD      DE, $70A2

LOC_9ABA:
    PUSH    DE
    PUSH    AF
    CALL    SUB_9BC9
    POP     AF
    POP     HL
    DEC     (HL)
    JR      NZ, LOC_9B00
    PUSH    AF
    CALL    SUB_A101
    CALL    SUB_A15D
    POP     AF
    BIT     0, A
    JP      Z, LOC_9B55
    BIT     1, A
    JR      NZ, LOC_9AE1
    SET     6, A
    BIT     7, A
    JP      NZ, LOC_9B55
    LD      DE, SPACE_TXT
    JR      LOC_9AEB

LOC_9AE1:
    SET     7, A
    BIT     6, A
    JP      NZ, LOC_9B55
    LD      DE, PLAYER_TWO_TXT

LOC_9AEB:
    LD      ($70A0), A
    LD      ($70B9), DE
    LD      B, 4
    LD      DE, GAME_OVER_TXT
    LD      ($70BB), DE
    CALL    SUB_9A09
    JR      LOC_9B0F

LOC_9B00:
    LD      A, ($70A0)
    BIT     0, A
    JR      Z, LOC_9B17
    BIT     6, A
    JR      NZ, LOC_9B17
    BIT     7, A
    JR      NZ, LOC_9B17

LOC_9B0F:
    LD      A, ($70A0)
    XOR     2
    LD      ($70A0), A

LOC_9B17:
    PUSH    AF
    CALL    SUB_A101
    CALL    SUB_A15D
    POP     AF
    LD      DE, $70EF
    BIT     1, A
    JR      Z, LOC_9B29
    LD      DE, $714B

LOC_9B29:
    CALL    SUB_A04A
    LD      HL, 1800H
    PUSH    HL
    PUSH    DE
    CALL    OUT_CTRL_OUT_DATA_PORT_04
    POP     DE
    POP     HL
    CALL    SUB_A04A

LOC_9B39:
    LD      B, 8
    LD      A, (DE)
    LD      C, A

LOC_9B3D:
    RLC     C
    JR      NC, LOC_9B46
    LD      A, 21H
    CALL    OUT_CTRL_OUT_DATA_PORT_01

LOC_9B46:
    INC     HL
    DJNZ    LOC_9B3D
    INC     DE
    PUSH    HL
    LD      BC, 1ADDH
    SBC     HL, BC
    POP     HL
    JP      M, LOC_9B39
RET

LOC_9B55:
    CALL    SUB_A101
    CALL    SUB_A15D
    LD      B, 7
    LD      B, 4
    LD      DE, GAME_OVER_TXT
    LD      ($70B9), DE
    LD      DE, BLANK_LINE_TXT
    LD      ($70BB), DE
    CALL    SUB_9A09
    LD      HL, 198AH
    LD      DE, GAME_OVER_TXT
    LD      BC, 0DH
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    LD      HL, 19AAH
    LD      DE, BLANK_LINE_TXT
    LD      BC, 0DH
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    LD      B, 14H

LOC_9B8A:
    PUSH    BC
    CALL    SUB_99C8

LOC_9B8E:
    CALL    GET_CONTROLLER_02
    PUSH    AF
    LD      A, ($70A7)
    LD      B, A
    POP     AF
    LD      ($70A7), A
    CP      B
    JR      NZ, LOC_9BA7

LOC_9B9D:
    LD      A, ($70A0)
    BIT     3, A
    JP      Z, LOC_9BC3
    JR      LOC_9B8E

LOC_9BA7:
    CP      76H
    JR      NZ, LOC_9BB5
    LD      A, ($70A0)
    XOR     8
    LD      ($70A0), A
    JR      LOC_9B9D

LOC_9BB5:
    CP      79H
    JR      NZ, LOC_9B9D
    LD      A, ($70A0)
    BIT     3, A
    JP      Z, LOC_8075
    JR      LOC_9B8E

LOC_9BC3:
    POP     BC
    DJNZ    LOC_9B8A
    JP      LOC_8075

SUB_9BC9:
    EX      DE, HL
    LD      HL, 1800H

LOC_9BCD:
    LD      B, 8
    LD      C, 0

LOC_9BD1:
    CALL    OUT_CTRL_IN_DATA_PORT_00
    CP      21H
    JR      C, LOC_9C1E
    JR      Z, LOC_9C1C
    CP      2CH
    JR      NC, LOC_9C1E
    PUSH    BC
    LD      A, 0E0H
    LD      ($70B9), HL
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    LD      BC, 5
    CALL    SUB_9F2B
    PUSH    HL
    PUSH    DE
    PUSH    BC
    LD      A, 3
    SET     7, A
    CALL    SUB_A11C
    LD      A, 14H
    SET     7, A
    CALL    SUB_A11C
    CALL    SUB_995C
    LD      A, 0DFH

LOC_9C03:
    CALL    SUB_A04A
    INC     A
    CP      0E8H
    JR      NC, LOC_9C13
    LD      HL, ($70B9)
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    JR      LOC_9C03

LOC_9C13:
    POP     BC
    POP     DE
    POP     HL
    LD      A, 21H
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    POP     BC

LOC_9C1C:
    SET     7, C

LOC_9C1E:
    LD      A, C
    RLCA
    LD      C, A
    INC     HL
    DJNZ    LOC_9BD1
    LD      (DE), A
    INC     DE
    PUSH    HL
    LD      BC, 1ADDH
    SBC     HL, BC
    POP     HL
    JP      M, LOC_9BCD

LOC_9C30:
    CALL    SUB_A04A
    LD      HL, ($700E)
    LD      A, L
    OR      H
    JR      NZ, LOC_9C30
    CALL    SUB_A101
    CALL    SUB_A15D
RET

SUB_9C41:
    LD      B, 5
    CP      35H
RET NC
    INC     A
    LD      B, 1
    CP      4
RET C
    INC     B
    CP      0AH
RET C
    INC     B
    CP      18H
RET C
    INC     B
    CP      34H
RET C
    INC     B
RET

SUB_9C5A:
    LD      A, H
    LD      B, 0
    CP      18H
    JR      Z, LOC_9C69
    LD      B, 40H
    CP      19H
    JR      Z, LOC_9C69
    LD      B, 80H

LOC_9C69:
    LD      A, L
    SLA     A
    SLA     A
    SLA     A
    AND     0F8H
    LD      H, A
    LD      A, L
    SRL     A
    SRL     A
    AND     0F8H
    ADD     A, B
    LD      L, A
RET

SUB_9C7D:
    LD      (IY+0), 0
    LD      (IY+1), 0
    LD      (IY+3), 0
RET

SUB_9C8A:
    LD      (IY+4), 0
    LD      (IY+5), 0
    LD      (IY+7), 0
RET

SUB_9C97:
    LD      A, ($70A0)
    LD      HL, $70E9
    BIT     1, A
    JR      Z, LOC_9CA2
    INC     HL

LOC_9CA2:
    LD      A, (HL)
    INC     A
    AND     7
    LD      (HL), A
    JR      LOC_9CB4

SUB_9CA9:
    LD      HL, $70E9
    LD      A, ($70A0)
    BIT     1, A
    JR      Z, LOC_9CB4
    INC     HL

LOC_9CB4:
    LD      C, (HL)
    LD      B, 0
    LD      HL, PLAYFIELD_COLORS
    ADD     HL, BC
    LD      C, (HL)
    LD      B, 1
    LD      DE, 4

OUT_CTRL_OUT_DATA_PORT_03:         
    LD      HL, 2000H
    ADD     HL, DE
    LD      A, L
    OUT     (CTRL_PORT), A
    LD      A, H
    OR      40H
    OUT     (CTRL_PORT), A
    LD      A, C

LOOP_OUT_DATA_PORT_00: 
    OUT     (DATA_PORT), A
    DJNZ    LOOP_OUT_DATA_PORT_00
RET

TITLE_SCREEN:          
    CALL    SUB_94BD
    CALL    SUB_9E6C
    LD      HL, 2000H
    LD      DE, LOGO_COLOR_TABLE
    LD      BC, 1BH
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    LD      HL, 1800H
    CALL    OUT_CTRL_OUT_DATA_PORT_04
    LD      HL, 1FFH
    LD      ($70B9), HL
    LD      DE, ATARI_LOGO
    LD      BC, 5C0H
    LD      HL, 100H
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    LD      HL, 180CH
    LD      DE, LOGO_NAME_TABLE
    EXX
    LD      B, 0BH

LOOP_9D06:             
    EXX
    LD      BC, 0AH
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    LD      BC, 20H
    ADD     HL, BC
    EXX
    DJNZ    LOOP_9D06
    LD      HL, 1936H
    LD      DE, COPYRIGHT_PATTERNS
    LD      BC, 2
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    LD      HL, 1956H
    LD      BC, 2
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    LD      HL, 1A0DH
    LD      DE, TITLE_TXT
    LD      BC, 8
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    LD      HL, 1AE7H
    LD      BC, 14H
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    LD      HL, 1A47H
    LD      A, 58H
    CALL    OUT_CTRL_OUT_DATA_PORT_00
    LD      A, 59H
    CALL    OUT_CTRL_OUT_DATA_PORT_00
    LD      A, 5CH
    CALL    OUT_CTRL_OUT_DATA_PORT_00
    LD      A, 5DH
    CALL    OUT_CTRL_OUT_DATA_PORT_00
    LD      A, 0A8H
    LD      HL, 196BH
    CALL    SUB_9D88
    LD      HL, 198BH
    CALL    SUB_9D88
    LD      HL, 19ABH
    CALL    SUB_9D88
    LD      HL, 19CBH
    CALL    SUB_9D88
    JP      SUB_9E74

OUT_CTRL_OUT_DATA_PORT_00:         
    LD      B, 0AH
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    JR      OUT_DATA_PORT_02

OUT_DATA_PORT_01:      
    OUT     (DATA_PORT), A

OUT_DATA_PORT_02:      
    ADD     A, 2
    OUT     (DATA_PORT), A
    ADD     A, 6
    DJNZ    OUT_DATA_PORT_01
    LD      DE, 20H
    ADD     HL, DE
RET

SUB_9D88:
    LD      B, 0CH

LOOP_OUT_CTRL_PORT_01: 
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    INC     A
    INC     HL
    DJNZ    LOOP_OUT_CTRL_PORT_01
RET

SUB_9D92:
    LD      HL,  $70B9+1
    DEC     (HL)
RET NZ
    LD      (HL), 3
    DEC     HL
    LD      A, (HL)
    INC     A
    CP      0BH
    JR      C, LOC_9DA1
    SUB     A

LOC_9DA1:
    LD      (HL), A
    LD      D, 0
    LD      E, A
    LD      HL, LOGO_FLASH_COLORS
    ADD     HL, DE
    LD      B, 4
    LD      C, (HL)
    LD      E, 4
    CALL    OUT_CTRL_OUT_DATA_PORT_03
RET

SUB_9DB2:
    CALL    SUB_94BD
    LD      HL, 1800H
    CALL    OUT_CTRL_OUT_DATA_PORT_04
    CALL    SUB_9E6C
    LD      HL, 1888H
    LD      DE, ONE_PLAYER_TXT
    LD      BC, 0DH
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    INC     HL
    INC     HL
    CALL    SUB_9E30
    LD      DE, LEVELS_TXT
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    LD      A, 1
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    CALL    SUB_9E30
    INC     HL
    INC     HL
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    DEC     HL
    DEC     HL
    LD      A, 2
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    CALL    SUB_9E30
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    LD      A, 3
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    LD      HL, 1988H
    LD      DE, TWO_PLAYER_TXT
    LD      BC, 0DH
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    INC     HL
    INC     HL
    CALL    SUB_9E30
    LD      DE, LEVELS_TXT
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    LD      A, 4
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    CALL    SUB_9E30
    INC     HL
    INC     HL
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    DEC     HL
    DEC     HL
    LD      A, 5
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    CALL    SUB_9E30
    CALL    OUT_CTRL_OUT_DATA_PORT_06
    LD      A, 6
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    CALL    SUB_9E64
    JP      SUB_9E74

SUB_9E30:
    LD      BC, 40H
    ADD     HL, BC
    LD      BC, 0DH
RET

SUB_9E38:
    LD      A, L
    SUB     E
    BIT     7, A
    JR      Z, LOC_9E40
    NEG

LOC_9E40:
    CP      C
RET NC
    LD      A, H
    SUB     D
    BIT     7, A
    JR      Z, LOC_9E4A
    NEG

LOC_9E4A:
    CP      B
RET

OUT_CTRL_OUT_DATA_PORT_04:         
    LD      A, L
    OUT     (CTRL_PORT), A
    LD      A, H
    OR      40H
    OUT     (CTRL_PORT), A
    EX      DE, HL
    LD      HL, 1B00H
    SBC     HL, DE

OUT_DATA_PORT_03:      
    LD      A, 20H
    OUT     (DATA_PORT), A
    DEC     HL
    LD      A, L
    OR      H
    JR      NZ, OUT_DATA_PORT_03
RET

SUB_9E64:
    PUSH    AF
    LD      A, ($7003)
    SET     5, A
    JR      OUT_CTRL_PORT_05

SUB_9E6C:
    PUSH    AF
    LD      A, ($7003)
    RES     5, A
    JR      OUT_CTRL_PORT_05

SUB_9E74:
    PUSH    AF
    LD      A, ($7003)
    SET     6, A
    JR      OUT_CTRL_PORT_05

SUB_9E7C:
    PUSH    AF
    LD      A, ($7003)
    RES     6, A

OUT_CTRL_PORT_05:      
    LD      ($7003), A
    OUT     (CTRL_PORT), A
    LD      A, 81H
    OUT     (CTRL_PORT), A
    POP     AF
RET

SUB_9E8D:
    LD      HL, 1800H
    CALL    OUT_CTRL_OUT_DATA_PORT_04
    LD      HL, 1842H
    LD      B, 3CH

LOC_9E98:
    LD      A, 21H
    CALL    OUT_CTRL_OUT_DATA_PORT_01

LOC_9E9D:
    EXX
    CALL    SUB_983E
    EXX
    AND     0FH
    JR      Z, LOC_9E9D

LOC_9EA6:
    LD      D, 0
    LD      E, A
    ADD     HL, DE
    LD      A, L
    AND     0FH
    CP      2
    JR      NC, LOC_9EB3
    INC     L
    INC     L

LOC_9EB3:
    LD      A, L
    BIT     4, A
    JR      Z, LOC_9EC0
    AND     0FH
    CP      0EH
    LD      A, 3
    JR      NC, LOC_9EA6

LOC_9EC0:
    DJNZ    LOC_9E98

SUB_9EC2:
    LD      HL, 1800H
    LD      DE, 20H
    LD      B, 18H
    LD      A, 0BH
    CALL    SUB_9EEB
    LD      HL, 181EH
    LD      B, 18H
    CALL    SUB_9EEB
    LD      B, 18H
    LD      HL, 181FH
    CALL    SUB_9EEB
    LD      HL, 1AE0H
    LD      B, 20H

LOC_9EE4:
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    INC     HL
    DJNZ    LOC_9EE4
RET

SUB_9EEB:
    CALL    OUT_CTRL_OUT_DATA_PORT_01
    ADD     HL, DE
    DJNZ    SUB_9EEB
RET

SUB_9EF2:
    LD      A, (IX+9)
    INC     A
    AND     7
    LD      (IX+9), A

LOC_9EFB:
    LD      BC, 20H

SUB_9EFE:
    JR      Z, LOC_9F04

LOC_9F00:
    ADD     HL, BC
    DEC     A
    JR      NZ, LOC_9F00

LOC_9F04:
    EX      DE, HL
    JP      OUT_CTRL_OUT_DATA_PORT_06

SUB_9F08:
    LD      HL, 0
    LD      A, E
    AND     0F8H
    LD      L, A
    SLA     L
    RL      H
    SLA     L
    RL      H
    LD      A, D
    AND     0F8H
    SRL     A
    SRL     A
    SRL     A
    ADD     A, L
    LD      L, A
    PUSH    DE
    LD      DE, 1800H
    ADD     HL, DE
    POP     DE
    JP      OUT_CTRL_IN_DATA_PORT_00

SUB_9F2B:
    EXX
    PUSH    BC
    EXX
    PUSH    AF
    PUSH    BC
    PUSH    DE
    PUSH    HL
    LD      HL, $70A0
    BIT     1, (HL)
    JR      NZ, LOC_9F47
    LD      DE, $70AA
    LD      HL, 1822H
    CALL    SUB_9F5E
    LD      HL, $70A8
    JR      LOC_9F53

LOC_9F47:
    LD      DE, $70AD
    LD      HL, 1837H
    CALL    SUB_9F5E
    LD      HL, $70AB

LOC_9F53:
    CALL    SUB_9FBC
    POP     HL
    POP     DE
    POP     BC
    POP     AF
    EXX
    POP     BC
    EXX
RET

SUB_9F5E:
    LD      A, (DE)
    ADD     A, C
    DAA
    LD      (DE), A
    LD      ($70B0), A
    DEC     DE
    LD      A, (DE)
    ADC     A, B
    DAA
    LD      (DE), A
    LD      ($70AF), A
    DEC     DE
    LD      A, (DE)
    ADC     A, 0
    DAA
    LD      (DE), A
    LD      ($70AE), A
    PUSH    HL
    POP     BC

LOC_9F78:
    LD      HL, $70AE
    LD      E, 0
    EXX
    LD      B, 3

LOOP_9F80:             
    EXX
    SUB     A
    RLD
    AND     A
    JR      NZ, LOC_9F93
    BIT     0, E
    JR      NZ, LOC_9F93
    LD      A, 0BH
    CALL    OUT_CTRL_PORT_02
    SUB     A
    JR      LOC_9F98

LOC_9F93:
    SET     0, E
    CALL    OUT_CTRL_PORT_02

LOC_9F98:
    INC     BC
    RLD
    AND     A
    JR      NZ, LOC_9FA9
    BIT     0, E
    JR      NZ, LOC_9FA9
    LD      A, 0BH
    CALL    OUT_CTRL_PORT_02
    JR      LOC_9FAE

LOC_9FA9:
    SET     0, E
    CALL    OUT_CTRL_PORT_02

LOC_9FAE:
    INC     BC
    INC     HL
    EXX
    DJNZ    LOOP_9F80
    EXX
    DEC     BC
    CP      0BH
RET NZ
    SUB     A
    JP      OUT_CTRL_PORT_02

SUB_9FBC:
    LD      A, ($70A0)
    BIT     2, A
RET NZ
    LD      A, ($7000)
    LD      B, A
    LD      A, (HL)
    CP      B
    JR      Z, LOC_9FCD
RET C
    JR      LOC_9FE1

LOC_9FCD:
    INC     HL
    LD      B, (HL)
    INC     HL
    LD      C, (HL)
    EX      DE, HL
    LD      A, ($7001)
    LD      H, A
    LD      A, ($7002)
    LD      L, A
    SUB     A
    SBC     HL, BC
RET NC
    EX      DE, HL
    DEC     HL
    DEC     HL

LOC_9FE1:
    LD      DE, $7000
    LD      BC, 3
    LDIR

SUB_9FE9:
    LD      HL, $7000
    LD      DE, $70AE
    LD      BC, 3
    LDIR
    LD      BC, ($70B1)
    JP      LOC_9F78

OUT_CTRL_OUT_DATA_PORT_06:         
    LD      A, L
    OUT     (CTRL_PORT), A
    LD      A, H
    OR      40H
    OUT     (CTRL_PORT), A

OUT_DATA_PORT_04:      
    LD      A, (DE)
    INC     DE
    OUT     (DATA_PORT), A
    DEC     BC
    LD      A, B
    OR      C
    JR      NZ, OUT_DATA_PORT_04
RET

OUT_CTRL_IN_DATA_PORT_00:          
    LD      A, L
    OUT     (CTRL_PORT), A
    LD      A, H
    OUT     (CTRL_PORT), A
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    IN      A, (DATA_PORT)
RET

OUT_CTRL_OUT_DATA_PORT_01:         
    EX      AF, AF'
    LD      A, L
    OUT     (CTRL_PORT), A
    LD      A, H

LOC_A024:
    OR      40H
    OUT     (CTRL_PORT), A
    EX      AF, AF'
    OUT     (DATA_PORT), A
RET

OUT_CTRL_PORT_02:      
    EX      AF, AF'
    LD      A, C
    OUT     (CTRL_PORT), A
    LD      A, B
    JR      LOC_A024

LOC_A033:
    PUSH    AF
    LD      A, ($7004)
    INC     A
    LD      ($7004), A
    CALL    OUT_CTRL_PORT_03
    POP     AF
RET

OUT_CTRL_PORT_03:      
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    IN      A, (CTRL_PORT)
RET

SUB_A04A:
    PUSH    AF
    PUSH    BC
    PUSH    DE
    PUSH    HL
    LD      A, ($7005)
    LD      B, A

LOC_A052:
    LD      A, ($7004)
    CP      B
    JR      Z, LOC_A052
    LD      ($7005), A
    CALL    SUB_A15D
    POP     HL
    POP     DE
    POP     BC
    POP     AF
RET

SUB_A063:
    LD      HL, 1B00H
    LD      DE, $7020
    LD      BC, 4DH
    JP      OUT_CTRL_OUT_DATA_PORT_06

GET_CONTROLLER_02:     
    LD      A, KEYBOARD_PORT
    OUT     (KEYBOARD_PORT), A
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    LD      A, ($70A0)
    BIT     1, A
    JR      Z, LOC_A086
    IN      A, (CONTROLLER_02)
    JR      LOC_A088

LOC_A086:
    IN      A, (CONTROLLER_01)

LOC_A088:
    LD      ($70A5), A
RET

CONTROLLER_02_KEY_BOARD:   
    LD      A, KEYBOARD_PORT
    OUT     (JOY_PORT), A
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    LD      A, ($70A0)
    BIT     1, A
    JR      Z, LOC_A0A3
    IN      A, (CONTROLLER_02)
    JR      LOC_A0A5

LOC_A0A3:
    IN      A, (CONTROLLER_01)

LOC_A0A5:
    CPL
    AND     4FH        ; JOY DIR 01
    LD      ($70A6), A
RET

SUB_A0AC:
    LD      B, 8
    LD      C, 7FH     ; JOY DIR 02

LOOP_OUT_CTRL_PORT_04: 
    LD      A, (HL)
    OUT     (CTRL_PORT), A
    INC     C
    LD      A, C
    OUT     (CTRL_PORT), A
    INC     HL
    DJNZ    LOOP_OUT_CTRL_PORT_04
    LD      A, (DATA_B56C)
    LD      ($7003), A
RET

OUT_CTRL_OUT_DATA_PORT_02:         
    LD      E, A
    LD      A, L
    OUT     (CTRL_PORT), A
    LD      A, H
    OR      40H
    OUT     (CTRL_PORT), A

LOC_A0CA:
    LD      A, E
    OUT     (DATA_PORT), A
    DEC     BC
    LD      A, B
    OR      C
    JR      NZ, LOC_A0CA
RET

CENTIPEDE_TABLE:
	DW BRANCH_01
	DW BRANCH_02
	DW BRANCH_03
	DW BRANCH_04
	DW BRANCH_05
	DW 0
	DW 0
	DW 0
	DW BRANCH_06
	DW BRANCH_07
	DW BRANCH_08
	DW BRANCH_09
	DW 0
	DW BRANCH_10
	DW BRANCH_11
	DW BRANCH_12
	DW BRANCH_13
	DW 0
	DW BRANCH_14
	DW BRANCH_15
	DW BRANCH_16
	DW BRANCH_17
	DW BRANCH_18

SUB_A101:; SOME TYPE OF TIMER?  ALSO PRESENT IN JUNGLE HUNT AND JOUST.  SAME EXACT ROUTINE ASIDE FROM RAM LOCATION
    LD      A, 9FH
    OUT     (0FFH), A
    LD      A, 0BFH
    OUT     (0FFH), A
    LD      A, 0DFH
    OUT     (0FFH), A
    LD      A, 0FFH
    OUT     (0FFH), A
    LD      B, 18H
    LD      HL, $7008
    SUB     A

LOOP_A117:             
    LD      (HL), A
    INC     HL
    DJNZ    LOOP_A117
RET

SUB_A11C:
    PUSH    AF
    RES     7, A
    ADD     A, A
    LD      E, A
    LD      D, 0
    LD      HL, CENTIPEDE_TABLE
    ADD     HL, DE
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    LD      A, (DE)
    ADD     A, A
    LD      B, A
    ADD     A, A
    ADD     A, B
    LD      C, A
    LD      B, 0
    LD      HL, $7008
    ADD     HL, BC
    LD      C, (HL)
    INC     HL
    POP     AF
    BIT     7, A
    JR      NZ, LOC_A14A
    LD      B, (HL)
    LD      A, B
    OR      C
    JR      Z, LOC_A14A
    PUSH    DE
    EX      DE, HL
    AND     A
    SBC     HL, BC
    EX      DE, HL
    POP     DE
RET NC

LOC_A14A:
    INC     DE
    LD      A, (DE)
    INC     DE
    LD      (HL), D
    DEC     HL
    LD      (HL), E
    INC     HL
    INC     HL
    LD      (HL), A
    INC     HL
    LD      (HL), 1
    INC     HL
    LD      (HL), 0
    INC     HL
    LD      (HL), 0
RET

SUB_A15D:
    LD      HL, $7008
    CALL    SUB_A172
    LD      HL, $700E
    CALL    SUB_A172
    LD      HL, $7014
    CALL    SUB_A172
    LD      HL, $701A

SUB_A172:
    PUSH    HL
    POP     BC
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    LD      A, D
    OR      E
RET Z
    INC     HL
    LD      A, (HL)
    INC     HL
    DEC     (HL)
RET NZ
    LD      (HL), A
    LD      A, (DE)
    BIT     7, A
    JR      Z, LOC_A1B4
    INC     DE
    CP      0E8H
    JR      NZ, PLAY_SOUND_00
    SUB     A
    LD      (BC), A
    INC     BC
    LD      (BC), A
RET

PLAY_SOUND_00:         
    OUT     (SOUND_PORT), A
    AND     70H
    JR      Z, PLAY_SOUND_01
    CP      20H
    JR      Z, PLAY_SOUND_01
    CP      40H
    JR      NZ, SUB_A1AE

PLAY_SOUND_01:         
    LD      A, (DE)
    BIT     6, A
    RES     6, A
    OUT     (SOUND_PORT), A
    INC     DE
    JR      Z, SUB_A1AE
    CALL    SUB_A1AE
    LD      (HL), 1
    JR      LOC_A1C4

SUB_A1AE:
    LD      A, E
    LD      (BC), A
    INC     BC
    LD      A, D
    LD      (BC), A
RET

LOC_A1B4:
    BIT     6, A
    JR      NZ, LOC_A1E3
    AND     A
    JR      NZ, LOC_A1C9

LOC_A1BB:
    INC     DE
    LD      A, (DE)
    LD      (BC), A
    INC     DE
    INC     BC
    LD      A, (DE)
    LD      (BC), A

LOC_A1C2:
    LD      (HL), 1

LOC_A1C4:
    DEC     BC
    PUSH    BC
    POP     HL
    JR      SUB_A172

LOC_A1C9:
    INC     HL
    EX      AF, AF'
    LD      A, (HL)
    AND     A
    JR      NZ, LOC_A1D4
    EX      AF, AF'
    LD      (HL), A
    DEC     HL
    JR      LOC_A1BB

LOC_A1D4:
    DEC     A
    LD      (HL), A
    DEC     HL
    JR      NZ, LOC_A1BB
    INC     DE
    INC     DE

LOC_A1DB:
    INC     DE
    LD      A, E
    LD      (BC), A
    INC     BC
    LD      A, D
    LD      (BC), A
    JR      LOC_A1C2

LOC_A1E3:
    INC     HL
    INC     HL
    EX      AF, AF'
    LD      A, (HL)
    AND     A
    JR      NZ, LOC_A1EF
    EX      AF, AF'
    AND     1FH
    LD      (HL), A
RET

LOC_A1EF:
    DEC     A
    LD      (HL), A
RET NZ
    DEC     HL
    DEC     HL
    JR      LOC_A1DB

BRANCH_01:
	DB 003,001,224,255,232
BRANCH_02:
	DB 003,002,231,240,000,254,161,255,232
BRANCH_05:
	DB 003,001,230,241,241,241,241,244,247,250,253,255,231,240,241,242,243,244,245,246,247,255,232
BRANCH_03:
	DB 003,001,231,244,243,242,241,240,241,242,243,244,245,246,247,255,232
BRANCH_04:
	DB 003,001,230,241,241,241,241,241,244,247,250,253,255,232
BRANCH_06:
	DB 000,001,159,232
BRANCH_07:
	DB 000,001,147,000,064,162,232
BRANCH_08:
	DB 000,001,148,128,021,128,021,128,021,149,140,033,140,033,148,128,021,128,021,128,021,128,021,132
	DB 025,132,025,132,025,150,134,010,134,010,134,010,148,132,025,132,025,132,025,159,000,071,162,232
BRANCH_09:
	DB 000,002,132,120,149,065,159,065,138,124,153,065,159,065,000,119,162,232
BRANCH_10:
	DB 001,001,191,232
BRANCH_11:
	DB 001,008,172,106,178,162,032,168,025,166,021,166,021,168,025,166,021,166,021,166,021
	DB 166,021,161,016,171,012,171,010,171,010,171,012,171,010,171,010,171,010,191,232
BRANCH_12:
	DB 001,001,191,232
BRANCH_13:
	DB 001,002,164,065,185,191,166,072,183,191,173,074,181,191,160,077,179,191,173,074,181,191,166
	DB 072,183,191,164,065,185,191,166,072,183,191,173,074,181,191,160,077,183,191,000,186,162,232
BRANCH_14:
	DB 002,001,223,232
BRANCH_18:
	DB 002,001,198,085,223,192,017,196,014,198,011,198,011,192,012,192,012,203,012,203,012,199,013,199,013,196,014,196,014,194,015,194,015,194,015,193
	DB 016,193,016,193,016,192,017,192,017,192,017,192,018,192,018,192,018,193,019,193,019,193,019,193,019,195,020,195,020,195,020,195,020,223,232
BRANCH_17:
	DB 002,001,223,204,024,192,021,192,021,192,021,192,021,192,021,192,021,192,021,223,192,080,208
	DB 192,082,209,192,084,211,192,022,192,024,192,090,210,192,028,192,030,192,096,211,223,232
BRANCH_15:
	DB 002,001,223,192,082,218,192,080,215,213,212,192,018,192,084,211,192,022,192,024,192,090,210,192,028,192,030,192,096,211,223,232
BRANCH_16:
	DB 002,001,223,204,024,192,021,192,021,192,021,192,021,192,021,192,021,192,021,192,021,223,232

BUG_BLASTER_PATTERNS:
	DB 000,000,000,012,030,063,127,109
    DB 109,127,063,030,030,030,000,000
    DB 000,000,000,000,000,000,128,128
    DB 128,128,000,000,000,000,000,000
    DB 012,012,012,012,012,012,012,012
    DB 012,012,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
SPIDER_BODY_PATTERNS:
	DB 000,000,000,000,001,003,015,027
    DB 025,015,001,000,000,000,000,000
    DB 000,000,000,000,128,192,240,216
    DB 152,240,128,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
FLEA_BODY_PATTERNS:
	DB 160,070,239,191,255,127,030,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 120,252,252,252,255,121,008,012
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 030,063,063,063,255,158,016,048
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
FLEA_LEGS_PATTERNS:
	DB 000,000,002,003,009,109,204,153
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,128,128,128,128
    DB 000,000,000,000,000,000,000,000
    DB 000,000,003,001,012,038,034,070
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,128,192,064,192,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,003,001,012,038,018,034
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,128,192,064,064,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,001,000,006,051,017,025
    DB 000,000,000,000,000,000,000,000
    DB 000,000,128,192,096,048,000,128
    DB 000,000,000,000,000,000,000,000
SPIDER_LEGS_PATTERNS:
	DB 112,144,012,006,050,088,068,064
    DB 032,004,008,024,016,024,012,000
    DB 000,015,056,096,064,030,050,002
    DB 002,036,048,024,008,048,000,000
    DB 224,056,012,006,002,060,204,128
    DB 128,196,008,024,016,016,024,000
    DB 000,014,059,096,070,026,050,002
    DB 002,032,048,016,016,112,000,000
    DB 096,048,024,012,006,000,062,098
    DB 096,068,072,024,016,048,032,000
    DB 000,000,056,102,077,021,033,001
    DB 000,032,048,144,112,000,000,000
    DB 112,152,012,004,006,024,060,096
    DB 096,052,008,024,016,016,008,000
    DB 000,006,013,120,084,020,052,004
    DB 004,032,048,016,048,192,000,000
    DB 000,112,152,012,006,000,060,068
    DB 064,004,008,016,016,012,000,000
    DB 000,000,054,089,077,020,052,000
    DB 000,032,048,016,016,144,096,000
    DB 000,000,000,028,038,240,044,036
    DB 000,004,008,008,006,000,000,000
    DB 000,028,050,065,077,018,050,002
    DB 000,032,048,016,008,008,016,032
    DB 000,000,000,014,241,028,020,020
    DB 000,004,008,014,000,000,000,000
    DB 000,014,017,032,064,094,050,001
    DB 001,033,048,024,012,004,000,000
    DB 000,000,028,038,065,120,204,132
    DB 064,004,008,008,004,004,000,000
    DB 014,016,032,032,076,082,050,002
    DB 004,032,016,016,016,016,000,000
SCORPION_WEST:
	DB 216,080,113,248,170,219,113,059
    DB 030,014,239,063,179,225,000,000
    DB 000,000,128,150,222,206,130,003
    DB 113,251,254,244,224,192,000,000
    DB 216,080,112,249,168,218,115,049
    DB 027,014,239,063,179,225,000,000
    DB 000,000,022,158,142,194,195,129
    DB 059,126,244,240,224,192,000,000
    DB 216,080,112,251,169,218,115,049
    DB 025,015,239,063,179,225,000,000
    DB 000,022,030,014,130,131,129,131
    DB 030,060,248,240,224,192,000,000
    DB 216,080,112,248,171,219,115,049
    DB 025,015,239,063,179,225,000,000
    DB 044,060,028,004,006,130,130,134
    DB 012,060,248,240,224,192,000,000
    DB 217,081,112,248,171,217,115,113
    DB 025,015,239,063,177,224,000,000
    DB 096,224,240,024,014,131,129,131
    DB 006,028,252,248,240,224,000,000
    DB 216,080,112,251,169,219,113,050
    DB 030,110,039,183,255,003,000,000
    DB 088,120,056,012,134,130,002,002
    DB 014,060,252,248,240,192,000,000
    DB 216,080,113,248,170,219,113,059
    DB 030,014,103,247,127,003,000,000
    DB 022,030,142,131,193,193,131,006
    DB 028,124,248,240,224,192,000,000
    DB 216,080,113,248,170,219,113,059
    DB 030,014,231,127,243,001,000,000
    DB 000,022,158,142,194,195,129,001
    DB 051,126,252,240,224,192,000,000
SCORPION_EAST:
	DB 000,000,001,105,123,115,065,192
    DB 142,223,127,047,007,003,000,000
    DB 027,010,142,031,085,219,142,220
    DB 120,112,247,252,205,135,000,000
    DB 000,000,104,121,113,067,195,129
    DB 220,126,047,015,007,003,000,000
    DB 027,010,014,159,021,091,206,140
    DB 216,112,247,252,205,135,000,000
    DB 000,104,120,112,065,193,129,193
    DB 120,060,031,015,007,003,000,000
    DB 027,010,014,223,149,091,206,140
    DB 152,240,247,252,205,007,000,000
    DB 052,060,056,032,096,065,065,097
    DB 048,060,031,015,007,003,000,000
    DB 027,010,014,031,021,219,206,140
    DB 152,240,247,252,205,135,000,000
    DB 006,007,015,024,112,193,129,193
    DB 096,056,063,031,015,007,000,000
    DB 155,138,014,031,213,155,206,142
    DB 152,240,247,254,141,007,000,000
    DB 026,030,028,048,097,065,064,064
    DB 112,060,063,031,015,003,000,000
    DB 027,010,014,223,149,219,142,076
    DB 120,118,228,237,255,192,000,000
    DB 104,120,113,193,131,131,193,096
    DB 056,062,031,015,007,003,000,000
    DB 027,010,142,031,085,219,142,220
    DB 120,112,230,239,254,192,000,000
    DB 000,104,121,113,067,195,129,128
    DB 204,126,063,015,007,003,000,000
    DB 027,010,142,031,085,219,142,220
    DB 120,112,231,254,207,128,000,000
SPIDER_SCORE_300:
	DB 000,000,000,000,113,010,010,050
    DB 010,010,113,000,000,000,000,000
    DB 000,000,000,000,140,082,082,082
    DB 082,082,140,000,000,000,000,000
SPIDER_SCORE_600:
	DB 000,000,000,000,049,066,114,074
    DB 074,074,049,000,000,000,000,000
    DB 000,000,000,000,140,082,082,082
    DB 082,082,140,000,000,000,000,000
SPIDER_SCORE_900:
	DB 000,000,000,000,049,074,074,058
    DB 010,018,033,000,000,000,000,000
    DB 000,000,000,000,140,082,082,082
    DB 082,082,140,000,000,000,000,000
SCORPION_EXPLOSION:
	DB 000,000,000,000,000,000,005,001
    DB 001,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,032,128
    DB 064,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,005,000
    DB 001,004,000,000,000,000,000,000
    DB 000,000,000,000,000,064,032,128
    DB 064,016,128,000,000,000,000,000
    DB 000,000,000,008,002,016,005,042
    DB 001,020,002,000,000,000,000,000
    DB 000,000,000,064,000,080,002,016
    DB 072,016,128,000,000,000,000,000
    DB 000,000,000,072,002,020,137,035
    DB 001,080,002,008,000,000,000,000
    DB 000,000,000,080,128,016,146,008
    DB 064,020,128,032,000,000,000,000
    DB 000,000,000,008,002,016,005,042
    DB 001,020,002,000,000,000,000,000
    DB 000,000,000,064,000,080,002,016
    DB 072,016,128,000,000,000,000,000
    DB 000,000,000,000,000,000,005,000
    DB 001,004,000,000,000,000,000,000
    DB 000,000,000,000,000,064,032,128
    DB 064,016,128,000,000,000,000,000
    DB 000,000,000,000,000,000,005,001
    DB 001,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,032,128
    DB 064,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
BLASTER_EXPLOSION:
	DB 000,000,000,000,000,001,002,005
    DB 001,002,000,000,000,000,000,000
    DB 000,000,000,000,000,000,192,000
    DB 096,128,000,000,000,000,000,000
    DB 000,000,000,000,000,000,002,001
    DB 003,001,000,000,000,000,000,000
    DB 000,000,000,000,000,000,128,192
    DB 096,128,128,000,000,000,000,000
    DB 000,000,000,000,000,013,006,006
    DB 013,006,003,005,000,000,000,000
    DB 000,000,000,000,064,128,224,192
    DB 096,160,128,064,000,000,000,000
    DB 000,000,000,000,000,001,002,001
    DB 007,003,002,001,000,000,000,000
    DB 000,000,000,000,000,096,160,208
    DB 096,208,160,064,000,000,000,000
    DB 000,000,002,003,003,029,014,006
    DB 013,014,027,005,012,000,000,000
    DB 000,000,000,064,192,152,240,192
    DB 096,176,080,064,096,000,000,000
    DB 000,000,000,000,004,007,002,005
    DB 015,003,004,007,001,000,000,000
    DB 000,000,000,000,160,080,160,240
    DB 056,144,160,112,032,000,000,000
    DB 000,000,000,000,000,004,006,103
    DB 051,029,014,008,024,046,059,101
    DB 012,020,008,000,000,000,048,096
    DB 204,088,176,080,112,184,044,196
    DB 192,096,032,000,005,007,002,012
    DB 006,002,013,007,003,001,000,000
    DB 000,000,000,144,184,088,160,240
    DB 040,176,216,112,168,000,000,000
    DB 006,006,067,115,057,027,076,008
    DB 056,236,122,023,013,020,024,048
    DB 008,024,056,114,006,092,184,072
    DB 048,152,028,110,195,096,048,016
    DB 000,000,000,000,004,007,002,005
    DB 015,003,004,007,001,000,000,000
    DB 000,000,000,000,160,080,160,240
    DB 056,144,160,112,032,000,000,000
    DB 000,000,000,000,004,006,067,112
    DB 057,019,076,000,048,204,082,023
    DB 008,020,024,048,008,024,040,082
    DB 006,084,184,064,048,136,020,108
    DB 195,096,000,016,000,000,000,000
    DB 000,001,002,001,007,003,002,001
    DB 000,000,000,000,000,000,000,000
    DB 000,096,160,208,096,208,160,064
    DB 000,000,000,000,004,000,067,032
    DB 024,018,076,000,032,136,066,021
    DB 000,020,008,032,008,016,008,066
    DB 006,084,040,000,032,128,020,072
    DB 129,066,000,016,000,000,000,000
    DB 000,000,002,001,003,001,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,128,192,096,128,128,000
    DB 000,000,000,000,004,000,002,032
    DB 008,018,008,000,032,000,064,016
    DB 000,020,008,000,008,016,008,002
    DB 000,020,008,000,000,000,020,008
    DB 001,064,000,016,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000
FLEA_EXPLOSION:
	DB 000,000,004,016,008,020,000,000
    DB 000,000,040,016,072,016,000,000
    DB 000,004,032,074,032,020,064,020
    DB 072,009,128,034,128,001,072,034
    DB 145,002,008,069,016,066,000,084
    DB 040,002,128,018,000,128,009,032
    DB 000,004,032,074,000,020,064,000
    DB 000,008,000,040,000,036,000,000
ATARI_LOGO:
	DB 000,000,000,000,000,000,000,000
    DB 255,255,255,255,255,255,255,255
    DB 015,015,015,015,015,015,015,015
    DB 240,240,240,240,240,240,240,240
    DB 000,000,000,000,000,001,001,001
    DB 000,000,000,000,000,128,128,128
    DB 003,003,007,007,015,015,031,031
    DB 255,254,254,254,252,252,252,248
    DB 255,127,127,127,063,063,063,031
    DB 192,192,224,224,240,240,248,248
    DB 000,000,000,001,003,007,015,031
    DB 063,127,255,255,255,255,255,255
    DB 248,240,240,224,224,192,192,128
    DB 031,015,015,007,007,003,003,001
    DB 252,254,255,255,255,255,255,255
    DB 000,000,000,128,192,224,240,248
    DB 000,000,003,015,063,255,255,255
    DB 127,255,255,255,255,255,255,255
    DB 255,254,254,252,248,240,224,192
    DB 255,127,127,063,031,015,007,003
    DB 254,255,255,255,255,255,255,255
    DB 000,000,192,240,252,255,255,255
    DB 255,255,255,255,255,255,248,192
    DB 255,254,252,240,192,000,000,000
    DB 255,127,063,015,003,000,000,000
    DB 255,255,255,255,255,255,031,003
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 007,024,032,079,072,136,136,136
    DB 143,136,136,072,072,032,024,007
    DB 224,024,004,242,010,009,009,009
    DB 241,065,033,018,010,004,024,224
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 001,027,063,061,024,048,120,120
    DB 048,096,240,240,096,096,240,240
    DB 152,253,255,155,001,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 096,096,240,240,096,048,120,120
    DB 048,024,061,063,027,001,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,128,217,255,191,025,000
    DB 000,128,192,192,128,000,001,027
    DB 063,061,024,048,123,127,055,051
    DB 000,000,000,000,000,000,152,253
    DB 255,155,003,001,057,255,255,057
    DB 120,120,048,024,061,063,027,001
    DB 000,000,024,188,252,216,128,000
    DB 000,000,000,001,155,255,253,152
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,006,143
    DB 207,198,198,143,143,207,198,134
    DB 000,000,000,000,000,000,012,031
    DB 127,252,240,096,000,000,000,000
    DB 015,015,015,134,198,207,143,006
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,192,224
    DB 248,252,060,024,024,060,060,024
    DB 000,000,000,000,000,102,255,255
    DB 102,000,000,000,000,000,000,000
    DB 024,060,060,024,024,060,060,024
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 096,240,240,096,096,246,255,111
    DB 096,240,240,096,096,240,240,096
    DB 000,001,003,003,097,240,241,099
    DB 003,001,001,003,003,003,001,001
    DB 096,240,240,096,096,240,240,096
    DB 000,000,000,000,000,000,000,000
    DB 003,003,003,001,001,003,003,001
    DB 000,000,000,000,000,000,000,000
    DB 000,128,192,192,128,000,134,207
    DB 207,134,134,207,207,207,134,134
    DB 000,000,000,000,000,000,012,031
    DB 127,252,240,096,000,000,000,000
    DB 207,207,207,134,134,207,207,134
    DB 006,015,015,006,006,015,015,006
    DB 000,000,000,000,102,255,255,102
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,192,224
    DB 248,252,060,024,024,060,060,024
    DB 000,000,000,000,000,000,003,055
    DB 127,123,048,096,246,255,111,102
    DB 024,060,060,120,240,240,096,000
    DB 000,000,000,000,000,000,000,000
    DB 240,240,096,048,123,127,055,003
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,048,251
    DB 255,055,007,003,051,255,255,051
    DB 000,000,000,000,000,000,000,000
    DB 128,131,135,007,015,158,158,012
    DB 000,000,000,003,055,255,251,048
    DB 000,000,000,000,000,000,000,000
    DB 012,030,030,015,135,135,003,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 051,127,255,179,000,000,000,000
    DB 048,120,120,120,048,048,120,120
    DB 121,177,176,120,121,121,048,048
    DB 000,000,000,000,179,255,127,051
    DB 000,000,000,000,000,000,000,000
    DB 049,121,120,048,048,248,248,048
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,012,223
    DB 255,236,192,192,236,255,223,204
    DB 000,000,000,000,000,000,192,236
    DB 254,222,030,012,204,254,254,204
    DB 224,224,192,096,246,255,111,006
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,006,111,255,246,096
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 007,015,015,031,031,031,063,063
    DB 128,192,192,224,224,224,240,240
    DB 255,255,255,255,255,255,003,003
    DB 255,255,255,255,255,255,240,240
    DB 192,192,192,193,193,193,003,003
    DB 120,252,252,254,254,254,255,255
    DB 000,000,000,000,000,000,000,000
    DB 255,255,255,255,255,255,252,252
    DB 248,254,255,255,255,255,031,015
    DB 003,003,003,131,195,195,227,227
    DB 240,240,240,240,240,240,240,240
    DB 000,000,000,000,000,000,000,000
    DB 063,063,124,124,124,252,248,248
    DB 240,240,248,248,248,252,124,124
    DB 003,003,003,003,003,003,003,003
    DB 240,240,240,240,240,240,240,240
    DB 003,003,007,007,007,015,015,015
    DB 255,255,207,207,207,207,135,135
    DB 000,000,128,128,128,192,192,192
    DB 252,252,252,252,252,252,252,252
    DB 007,007,007,015,015,031,063,127
    DB 227,227,227,195,195,131,131,003
    DB 240,240,240,240,240,240,240,240
    DB 000,001,001,001,001,003,003,003
    DB 248,248,255,255,255,255,255,224
    DB 124,126,254,254,254,255,255,031
    DB 003,003,003,003,003,003,003,003
    DB 240,240,240,240,240,240,240,240
    DB 015,031,031,031,031,063,063,062
    DB 135,135,255,255,255,255,255,001
    DB 192,224,224,224,224,240,240,240
    DB 252,253,253,252,252,252,252,252
    DB 254,252,252,252,254,126,127,063
    DB 003,003,003,003,003,003,003,003
    DB 240,240,240,240,240,240,240,240
    DB 003,007,007,007,007,015,015,000
    DB 224,224,224,192,192,192,192,000
    DB 031,031,031,015,015,015,015,000
    DB 003,131,131,131,131,195,195,000
    DB 240,240,240,240,240,240,240,000
    DB 062,126,126,124,124,252,252,000
    DB 001,001,001,000,000,000,000,000
    DB 240,248,248,248,248,252,252,000
    DB 252,252,252,252,252,252,252,000
    DB 063,031,031,015,015,007,007,000
    DB 131,131,195,195,227,227,243,000
    DB 240,240,240,240,240,240,240,000
LOGO_NAME_TABLE:
	DB 032,032,032,033,034,035,033,032
    DB 032,032,032,032,032,033,034,035
    DB 033,032,032,032,032,032,032,033
    DB 034,035,033,032,032,032,032,032
    DB 032,033,034,035,033,032,032,032
    DB 032,032,032,033,034,035,033,032
    DB 032,032,032,032,036,033,034,035
    DB 033,037,032,032,032,032,038,039
    DB 034,035,040,041,032,032,032,042
    DB 043,044,034,035,045,046,047,032
    DB 048,049,050,032,034,035,032,051
    DB 052,053,054,055,032,032,034,035
    DB 032,032,056,057,032,032,032,032
    DB 032,032,032,032,032,032
COPYRIGHT_PATTERNS:
	DB  080,082,081,083
FONTS_AND_MUSHROOM_PATTERNS:
	DB 000,060,102,102,102,102,102,060
    DB 000,024,056,024,024,024,024,060
    DB 000,060,102,006,060,096,096,126
    DB 000,060,102,006,028,006,102,060
    DB 000,030,054,102,127,006,006,006
    DB 000,126,096,096,124,006,102,060
    DB 000,060,102,096,124,102,102,060
    DB 000,126,070,004,012,008,024,024
    DB 000,060,102,102,060,102,102,060
    DB 000,060,102,102,062,006,102,060
    DB 008,008,028,062,062,062,028,028
    DB 000,000,000,000,000,000,000,000
    DB 028,062,127,127,093,028,028,000
    DB 000,000,000,000,000,000,000,000
    DB 000,060,118,098,096,098,118,060
    DB 000,126,024,024,024,024,024,126
    DB 000,124,102,102,124,096,096,096
    DB 000,096,096,096,096,096,096,126
    DB 000,060,102,102,126,102,102,102
    DB 000,066,102,060,024,024,024,024
    DB 000,126,096,096,120,096,096,126
    DB 000,124,102,102,124,120,108,102
    DB 000,060,102,096,060,006,102,060
    DB 000,060,102,102,102,102,102,060
    DB 000,102,118,126,110,102,102,102
    DB 000,126,024,024,024,024,024,024
    DB 000,198,198,198,198,214,124,040
    DB 000,124,102,098,098,098,102,124
    DB 000,102,102,102,126,102,102,102
    DB 000,060,118,096,110,098,118,060
    DB 000,098,118,126,106,098,098,098
    DB 000,102,102,102,036,036,056,024
    DB 000,000,000,000,000,000,000,000
    DB 028,062,127,127,093,028,028,000
    DB 028,054,119,119,085,020,020,000
    DB 028,062,087,087,021,004,004,000
    DB 028,062,084,084,016,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 028,062,127,127,093,028,028,000
    DB 028,054,119,119,085,020,020,000
    DB 028,062,087,087,021,004,004,000
    DB 028,062,084,084,016,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
CENT_HEAD_WEST:
	DB 000,000,000,003,003,000,000,000
    DB 000,000,006,001,001,006,000,000
    DB 000,008,007,001,001,007,008,000
    DB 000,025,007,003,003,007,025,003
    DB 016,019,015,007,007,015,019,022
    DB 048,047,031,031,031,031,047,052
    DB 100,079,063,031,031,063,079,097
    DB 048,159,191,127,127,191,159,001
CENT_SEG_01_WEST:
	DB 224,062,127,255,255,127,062,007
    DB 032,124,254,254,254,254,124,008
    DB 016,248,253,253,253,253,248,064
    DB 024,241,251,251,251,251,241,003
    DB 056,227,247,247,247,247,227,014
    DB 128,199,239,239,239,239,199,002
    DB 004,143,223,223,223,223,143,001
    DB 048,031,191,191,191,191,031,129
CENT_SEG_02_WEST:
	DB 224,062,127,127,127,127,062,007
    DB 032,124,254,254,254,254,124,008
    DB 016,248,252,252,252,252,248,064
    DB 024,240,248,248,248,248,240,000
    DB 056,224,240,240,240,240,224,000
    DB 128,192,224,224,224,224,192,000
    DB 000,128,192,192,192,192,128,000
    DB 000,000,128,128,128,128,000,128
CENT_SEG_SOUTH_WEST:
	DB 000,030,063,063,063,063,127,158
    DB 000,001,060,126,126,126,126,254
    DB 000,007,003,057,124,126,126,254
    DB 000,015,031,003,057,124,126,254
    DB 000,015,031,063,003,057,124,254
    DB 000,015,031,063,063,003,057,124
    DB 000,031,063,063,127,127,003,056
    DB 000,030,063,063,063,063,063,000
CENT_SEG_SOUTH_EAST:
	DB 000,120,252,252,252,252,254,121
    DB 000,128,060,126,126,126,126,127
    DB 000,224,192,156,062,126,126,126
    DB 000,240,248,192,156,062,126,127
    DB 000,240,248,252,192,156,062,126
    DB 000,240,248,252,252,192,156,062
    DB 000,240,248,248,252,252,192,028
    DB 000,120,252,252,252,252,252,000
CENT_COLOR_TABLE:
	DB 080,080,080,080,160,208,192,192
    DB 192,192,192,192,192,192,192,192
    DB 192,192,192,192,192,192,192,192
    DB 192,192,000,000,096,000
LOGO_COLOR_TABLE:
	DB 080,080,080,080,096,096,096,096
    DB 000,000,224,192,192,192,192,192
    DB 192,192,192,192,192,096,096,096
    DB 096,096,096
LOGO_FLASH_COLORS:
	DB 096,128,144,160,176,048,032,192,064,080,208,112,224,240
PLAYFIELD_COLORS:
	DB 176,112,160,080,144,048,128,064
FLEA_LEG_COLORS:
	DB 005,007,014,015
SPRITE_TABLE:
	DB 174,120,000,006,174,120,004,004
    DB 000,000,008,000,000,000,012,000
    DB 000,000,016,000,000,000,020,000
    DB 000,000,024,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,208
UNK_B56B:
	DB    0   
DATA_B56C:; INITIALIZATION DATA
	DB 226,006,128,000,054,007,112,000
    DB 000,001,004,003,002,001,003,000
    DB 000,000,000,001,001,002,000,001
    DB 001,002,000,000,000,001,002,000
    DB 002,001,001,000,000,001,002,008
    DB 008,024,016,001,080,008,024,016
    DB 080,000,000,001,004,003,002,001
    DB 003,000,000,000,000,001,001,002
    DB 000,001,001,002,000,000,000,001
    DB 002,000,002,001,001,000,000,001
    DB 002,004,004,024,016,002,080,008
    DB 024,016,080,000,000,001,003,003
    DB 001,001,003,000,000,000,000,001
    DB 001,003,000,001,001,002,000,000
    DB 000,001,002,000,002,001,001,000
    DB 000,001,002,008,008,024,016,001
    DB 080,008,024,016,080,000,000,001
    DB 003,003,002,001,003,000,000,000
    DB 000,001,001,002,000,001,001,002
    DB 000,000,000,001,002,000,002,001
    DB 001,000,000,001,002,004,004,024
    DB 016,002,080,008,024,016,080,000
    DB 000,001,003,003,001,001,003,000
    DB 000,000,000,001,001,004,000,001
    DB 001,002,000,000,000,001,002,000
    DB 002,001,001,000,000,001,002,008
    DB 008,024,016,001,080,008,024,016
    DB 080,000,000,001,002,003,002,001
    DB 003,000,000,000,000,001,001,002
    DB 000,001,001,002,000,000,000,001
    DB 002,000,002,001,001,000,000,001
    DB 002,004,004,024,016,002,080,008
    DB 024,016,080,000,000,001,002,003
    DB 001,001,003,000,000,000,000,001
    DB 001,003,000,001,001,002,000,000
    DB 000,001,002,000,002,001,001,000
    DB 000,001,002,008,008,024,016,001
    DB 080,008,024,016,080,000,000,001
    DB 002,004,002,001,003,000,000,000
    DB 000,001,001,002,000,001,001,002
    DB 000,000,000,001,002,000,002,001
    DB 001,000,000,001,002,004,004,024
    DB 016,002,080,008,024,016,080,000
    DB 000,001,002,003,001,001,003,000
    DB 000,000,000,001,001,003,000,001
    DB 001,002,000,000,000,001,002,000
    DB 002,001,001,000,000,001,002,008
    DB 008,024,016,001,080,008,024,016
    DB 080,000,000,001,001,003,002,001
    DB 003,000,000,000,000,001,001,002
    DB 000,001,001,002,000,000,000,001
    DB 002,000,002,001,001,000,000,001
    DB 002,004,004,024,016,002,080,008
    DB 024,016,080,000,000,001,001,003
    DB 002,001,003,000,000,000,000,001
    DB 001,004,000,001,001,002,000,000
    DB 000,001,002,000,002,001,001,000
    DB 000,001,002,008,008,024,016,001
    DB 080,008,024,016,080,000,000,001
    DB 002,002,002,001,003,000,000,000
    DB 000,001,001,003,000,001,001,002
    DB 000,000,000,001,002,000,002,001
    DB 001,000,000,001,002,004,004,024
    DB 016,002,080,008,024,016,080,000
    DB 000,001,003,003,001,001,003,000
    DB 000,000,000,001,001,002,000,001
    DB 001,002,000,000,000,001,002,000
    DB 002,001,001,000,000,001,002,004
    DB 004,024,016,002,080,008,024,016
    DB 080
BYTE_B795:
	DB 115,181,157,181,199,181,241,181,027,182,069,182,111
    DB 182,153,182,195,182,237,182,023,183,065,183,107,183
ONE_PLAYER_TXT:
	DB 032,023,024,020,032,016,017,018,019,020,021,032,032
TWO_PLAYER_TXT:
	DB 032,025,026,023,032,016,017,018,019,020,021,022,032
LEVELS_TXT:
	DB 032,032,020,018,022,019,032,016,017,018,019,032,032,022,025,018,024,027,018,021
    DB 027,032,016,017,018,019,032,032,028,018,021,027,032,016,017,018,019,032,032
SPACE_TXT:
	DB 032
PLAYER_ONE_TXT:
	DB 016,017,018,019,020,021,032,032,023,024,020,032
PLAYER_TWO_TXT:
	DB 032,016,017,018,019,020,021,032,032,025,026,023,032
GAME_OVER_TXT:
	DB 032,032,029,018,030,020,032,023,031,020,021,032,032
GET_READY_TXT:
	DB 032,032,029,020,025,032,021,020,018,027,019,032,032
BLANK_LINE_TXT:
	DB 032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032
HI_SCORE_TXT:
	DB 028,015,011,022,014,023,021,020
TITLE_TXT:
	DB 016,021,020,022,020,024,025,022,014,023,016,019,021,015,029,028,025,032,001,009,008,003,032,018,025,018,021,015

LARRY_CLAGUE_MESSAGE:
    DB 032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032
    DB 032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032
    DB 073,070,032,089,079,085,032,065,082,069,032,082,069,065,068,073,078,071,032,084,072,073,083,044,032,065,078,068,032,089,079,085
    DB 032,087,079,082,075,032,065,084,032,067,079,076,069,067,079,044,032,032,032,032,032,032,032,032,084,072,069,078,032,080,076,069
    DB 065,083,069,032,084,069,076,076,032,071,069,079,082,071,069,032,075,073,083,083,032,073,032,083,065,073,068,032,072,069,076,076
    DB 079,046,032,032,084,072,065,078,075,083,046,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,083
    DB 073,078,067,069,082,069,076,089,044,032,076,065,082,082,089,032,067,076,065,071,085,069,032,032,032,032,032,032,032,032,032,032
    DB 032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032
    DB 032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032
    DB 032,032,032,032,032,032,080,082,079,071,082,065,077,077,069,068,032,066,089,058,032,032,032,032,032,032,032,032,032,032,032,032
    DB 032,032,076,032,067,076,065,071,085,069,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032
    DB 071,082,065,080,072,073,067,083,032,065,078,068,032,065,078,073,077,065,084,073,079,078,032,066,089,058,032,032,076,032,067,076
    DB 065,071,085,069,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,083,079,085,078,068,032
    DB 068,065,084,065,032,083,085,080,080,076,073,069,068,032,066,089,058,032,032,032,032,032,065,032,070,085,067,072,083,032,032,032
    DB 032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,083,084,065,082,084,032,068,065,084,069,058,032
    DB 032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,048,052,047,050,048,047,056,051,032,032,032,032,032,032,032,032
    DB 032,032,032,032,032,032,032,032,032,032,032,032,032,032,067,079,077,080,076,069,084,073,079,078,032,068,065,084,069,058,032,032
    DB 032,032,032,032,032,032,032,032,032,032,048,056,047,050,051,047,056,051,032,032,032,032,032,032,032,032,032,032,032,032,032,032
    DB 032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032
    DB 032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032,032

PADDING_TO_REACH_16K:
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh