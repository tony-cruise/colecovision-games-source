; COMPILABLE DISASSEMBLY OF CARNIVAL BY CAPTAIN COZMOS SEPTEMBER 30, 2023
; 1ST OF A KIND, STILL NEEDS CLEANUP, STILL HAS SLIGHT GRAPHICAL ERRORS BUT PLAYABLE.
; CREDIT GOES WHERE CREDIT IS DUE.  THIS IS A PAINFUL, TIME CONSUMING EXPERIENCE.

; TWO UNRESOLVED LINKS TO FUNCTIONS.  $9B50, $A402


PLAY_SONGS:        EQU $1F61
GAME_OPT:          EQU $1F7C
LOAD_ASCII:        EQU $1F7F
FILL_VRAM:         EQU $1F82
MODE_1:            EQU $1F85


INIT_TABLE:        EQU $1FB8
GET_VRAM:          EQU $1FBB
PUT_VRAM:          EQU $1FBE
INIT_TIMER:        EQU $1FC7

FREE_SIGNAL:       EQU $1FCA
REQUEST_SIGNAL:    EQU $1FCD
TEST_SIGNAL:       EQU $1FD0
TIME_MGR:          EQU $1FD3
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

FNAME "CARNIVAL V1.ROM"
CPU Z80

    ORG $8000

    DW $55AA
    DW $71C5
    DW $71ED
WORD_8006: DW $71F7 ;WORK_BUFFER
WORD_8008: DW $7162 ;CONTROLLER_BUFFER

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
	RETI
    NOP
	RETN
    NOP
	DB "CARNIVAL",1EH,1FH
	DB "/PRESENTS SEGA'S/1982"

START:   
    LD      B, 1
    CALL    SUB_9DC7

LOC_8048:
    LD      A, ($715D)
    CP      1
    JR      NZ, LOC_8059
    CALL    SUB_80B9
    LD      B, 2
    CALL    SUB_9DC7
    JR      LOC_80B6

LOC_8059:
    CP      2
    JR      NZ, LOC_8067
    CALL    SUB_80FF
    LD      B, 3
    CALL    SUB_9DC7
    JR      LOC_80B6

LOC_8067:
    CP      3
    JR      NZ, LOC_8075
    CALL    ANOTHER_VRAM_INIT
    LD      B, 4
    CALL    SUB_9DC7
    JR      LOC_80B6

LOC_8075:
    CP      4
    JR      NZ, LOC_8083
    CALL    SUB_81CE
    LD      B, 5
    CALL    SUB_9DC7
    JR      LOC_80B6

LOC_8083:
    CP      5
    JR      NZ, LOC_8091
    CALL    SUB_8202
    LD      B, 6
    CALL    SUB_9DC7
    JR      LOC_80B6

LOC_8091:
    CP      6
    JR      NZ, LOC_809A
    CALL    TEST_PLAY_AND_PUT
    JR      LOC_80B6

LOC_809A:
    CP      7
    JR      NZ, LOC_80A8
    CALL    OBJECTS_AND_BULLET_BONUS_SOUND
    LD      B, 8
    CALL    SUB_9DC7
    JR      LOC_80B6

LOC_80A8:
    CP      8
    JR      NZ, LOC_80AF
    CALL    PUT_OBJECT_08

LOC_80AF:
    CP      9
    JR      NZ, LOC_80B6
    CALL    SEVERAL_OBJECTS_AT_ONCE

LOC_80B6:
    JP      LOC_8048

SUB_80B9:
    CALL    CLEAR_RAM
    CALL    INITIALIZE_TIMERS
    CALL    INITIALIZE_SOUND
    LD      A, 1
    LD      ($73C6), A
    LD      A, 0FH
    LD      HL, $7235
    CALL    INIT_WRITER
    XOR     A
    LD      ($7233), A
    NOP
    NOP
    NOP
    LD      A, 0
    LD      ($7353), A
    LD      IX, LEFT_BONUS_HUD
    LD      L, (IX+2)
    LD      H, (IX+3)
    INC     HL
    INC     HL
    INC     HL
    LD      A, 20H
    LD      (HL), A
RET

INITIALIZE_TIMERS:   
    LD      HL, $716E
    LD      DE, $719C
    CALL    INIT_TIMER
RET

INITIALIZE_SOUND:
    LD      B, 0DH
    LD      HL, SOUND_TABLE
    CALL    SOUND_INIT
RET

SUB_80FF:
    CALL    MODE_1
    CALL    LOAD_ASCII
    CALL    GAME_OPT
    LD      HL, (WORD_8008)
    LD      A, 90H
    LD      (HL), A
    INC     HL
    LD      (HL), A
    LD      A, 0FH
    LD      ($7168), A
    LD      ($716D), A

LOC_8118:
    CALL    POLLER
    LD      A, ($7168)
    CP      0FH
    JR      NZ, LOC_8129
    LD      A, ($716D)
    CP      0FH
    JR      Z, LOC_8118

LOC_8129:
    DEC     A
    BIT     3, A
    JR      NZ, LOC_8118
    LD      HL, $715F
    BIT     2, A
    JR      NZ, LOC_813A
    LD      B, 0
    LD      (HL), B
    JR      LOC_813D

LOC_813A:
    LD      B, 1
    LD      (HL), B

LOC_813D:
    AND     3
    INC     HL
    LD      (HL), A
RET

ANOTHER_VRAM_INIT:   
    CALL    WRITING_A_REGISTER
    LD      C, 0
    LD      B, 7
    CALL    WRITE_REGISTER
    CALL    INIT_PATTERN_TABLES
    CALL    CLEAR_SCREEN_WITH_FF
    CALL    CLEAR_VRAM_AT_2800_WITH_0
    CALL    SETUP_PATTERNS_IN_VRAM
    LD      HL, UNK_81A3
    CALL    SUB_A456
    CALL    WRITING_A_REGISTER
RET

INIT_PATTERN_TABLES: 
    LD      HL, 0
    LD      A, 3
    CALL    INIT_TABLE
    LD      HL, 2300H
    LD      A, 4
    CALL    INIT_TABLE
    LD      HL, 2000H
    LD      A, 2
    CALL    INIT_TABLE
    LD      HL, 2800H
    LD      A, 0
    CALL    INIT_TABLE
    LD      HL, 3000H
    LD      A, 1
    CALL    INIT_TABLE
RET

CLEAR_SCREEN_WITH_FF:
    LD      HL, 2000H
    LD      DE, 300H
    LD      A, 0FFH
    CALL    FILL_VRAM
RET

CLEAR_VRAM_AT_2800_WITH_0:
    LD      HL, 2800H
    LD      DE, 80H
    LD      A, 0
    CALL    FILL_VRAM
RET

UNK_81A3:
	DB    7   
    DB 0A0H
    DB    1
    DB  40H
    DB  0EH
    DW TARGET_PATS_A
    DB 0A0H
    DB    1
    DB  40H
    DB  16H
    DW TARGET_PATS_B
    DB 0A0H
    DB    1
    DB  40H
    DB  1EH
    DW TARGET_PATS_C
    DB  20H
    DB    0
    DB    0
    DB  23H
    DW MYSTERY_PATTERN_A
    DB  20H
    DB    0
    DB  40H
    DB  23H
    DW MYSTERY_PATTERN_B
    DB  20H
    DB    0
    DB  80H
    DB  23H
    DW MYSTERY_PATTERN_C
    DB  20H
    DB    0
    DB 0C0H
    DB  23H
    DW MYSTERY_PATTERN_D

SUB_81CE:
    LD      B, 2
    LD      IX, $7269

LOC_81D4:
    LD      (IX+0), 3CH
    LD      (IX+1), 0
    LD      (IX+2), 0
    LD      (IX+3), 0
    LD      IX, $726D
    DJNZ    LOC_81D4
    LD      A, 0
    LD      ($7161), A
    LD      A, ($715E)
    CP      3
    JR      NZ, LOCRET_8201
    LD      A, ($73C4)
    XOR     2
    LD      C, A
    LD      B, 1
    CALL    WRITE_REGISTER

LOCRET_8201:     
RET

SUB_8202:
    CALL    INITIALIZE_SOUND
    CALL    INITIALIZE_TIMERS
    XOR     A
    LD      ($7266), A
    LD      HL, GET_READT_TXT
    LD      BC, 12H
    CALL    INIT_SOUND_AND_VRAM
    CALL    ANOTHER_VRAM_INIT
    CALL    SUB_ABD1
    CALL    SUB_AC3F
    CALL    SUB_AC65
    CALL    BONUS_MESSAGE
    CALL    SUB_AD6B
    CALL    PUT_MUSIC_NOTE_SPRITE
    CALL    PUT_GUN_SPRITE
    CALL    SUB_ADC1
    CALL    PUT_OBJECT_10_A
    CALL    SUB_9C54
    XOR     A
    LD      ($7353), A
    LD      HL, 1EH
    CALL    REQUEST_TEST_AND_FREE_SIGNAL
    CALL    SUB_ADD9
    LD      HL, (WORD_8008)
    LD      A, 8BH
    LD      (HL), A
    INC     HL
    LD      (HL), A
    CALL    PLAY_MUSICAL_SCORE
RET

PLAY_MUSICAL_SCORE:  
    LD      B, 1
    CALL    PLAY_IT         ; FIRST PART OF TUNE
    LD      B, 11H
    CALL    PLAY_IT
    LD      B, 12H
    CALL    PLAY_IT
    LD      B, 13H
    CALL    PLAY_IT
    LD      B, 14H
    CALL    PLAY_IT
RET

GET_READT_TXT:
	DB  47H, 45H, 54H, 20H, 52H, 45H, 41H, 44H, 59H, 20H, 50H, 4CH, 41H, 59H, 45H, 52H, 20H, 31H

TEST_PLAY_AND_PUT:   
    LD      A, ($7338)
    BIT     1, A
    JR      Z, LOC_8292
    LD      A, ($733D)
    CALL    TEST_SIGNAL
    JR      Z, LOC_8292
    CALL    PLAY_LETTER_BONUS_SOUND_AND_OBJECT
    LD      HL, $7338
    RES     1, (HL)

LOC_8292:
    CALL    SUB_9480
    CALL    SUB_A479
    CALL    SUB_955D
    CALL    SUB_97FA
    CALL    SUB_A4BE
    CALL    JUMP_FROM_TABLE_03
    CALL    PUT_OBJECT_16
    CALL    SUB_8507
    CALL    SUB_98A3
    LD      HL, $708B
    INC     HL
    INC     HL
    INC     HL
    LD      A, (HL)
    CP      0C0H
    JR      C, MAJOR_SET_OF_ROUTINES
    LD      A, ($7338)
    BIT     1, A
    JR      NZ, MAJOR_SET_OF_ROUTINES
    LD      A, ($7161)
    LD      HL, $7269
    LD      DE, $726D
    OR      A
    JR      Z, LOC_82CC
    EX      DE, HL

LOC_82CC:
    LD      A, (HL)
    OR      A
    JR      NZ, LOC_8307
    LD      A, ($715F)
    OR      A
    JR      Z, LOC_8300
    EX      DE, HL
    LD      A, (HL)
    OR      A
    JR      NZ, LOC_82E2
    LD      B, 9
    CALL    SUB_9DC7
    JR      LOC_82FE

LOC_82E2:
    LD      B, 5
    CALL    SUB_9DC7
    LD      HL, 3CH
    CALL    REQUEST_TEST_AND_FREE_SIGNAL
    LD      HL, GAME_OVER_TEXT
    LD      BC, 12H
    CALL    INIT_SOUND_AND_VRAM
    LD      A, ($7161)
    XOR     1
    LD      ($7161), A

LOC_82FE:
    JR      LOC_8305

LOC_8300:
    LD      B, 9
    CALL    SUB_9DC7

LOC_8305:
    JR      MAJOR_SET_OF_ROUTINES

LOC_8307:
    LD      A, ($7266)
    OR      A
    JR      NZ, MAJOR_SET_OF_ROUTINES
    INC     HL
    INC     HL
    INC     HL
    LD      A, (HL)
    CP      4
    JR      NC, LOC_8317
    INC     A
    LD      (HL), A

LOC_8317:
    LD      B, 7
    CALL    SUB_9DC7

MAJOR_SET_OF_ROUTINES:    
    NOP
LOC_831D:
    CALL    READ_REGISTER
    LD      B, 20H
LOC_8322:
    DJNZ    $
    BIT     5, A
    JR      Z, LOC_832D
    LD      HL, $7234
    SET     5, (HL)
LOC_832D:
    BIT     7, A
    JR      Z, LOC_831D
    LD      A, ($715D)
    CP      6
    JR      NZ, LOC_8341
    LD      A, ($72A9)
    AND     A
    JR      NZ, LOC_8341
    CALL    SIGNAL_STUFF
LOC_8341:
    CALL    WRITER
    CALL    TIME_MGR
    CALL    POLLER
    CALL    PLAY_SONGS
    CALL    SOUND_MAN
RET

GAME_OVER_TEXT:
	DB  47H, 41H, 4DH, 45H, 20H, 4FH, 56H, 45H, 52H, 20H, 50H, 4CH, 41H, 59H, 45H, 52H, 20H, 31H

OBJECTS_AND_BULLET_BONUS_SOUND:        
    CALL    INITIALIZE_SOUND
    LD      HL, $7094
    LD      A, 0FFH
    LD      B, 0AH

LOOP_836D:       
    LD      (HL), A
    INC     HL
    DJNZ    LOOP_836D
    LD      IX, FLYING_DUCK
    CALL    PUTOBJ
    CALL    INIT_PATTERN_TABLES
    LD      HL, MISC_SYMBOLS
    CALL    SUB_A456
    LD      A, 0C5H
    LD      IX, $70BC
    LD      (IX+3), A
    LD      IX, GUN_SPRITE
    CALL    PUTOBJ
    LD      A, 0C5H
    LD      IX, $708B
    LD      (IX+3), A
    LD      IX, BULLET
    CALL    PUTOBJ
    LD      IX, BULLET_COUNT
    CALL    PUTOBJ
    CALL    MAJOR_SET_OF_ROUTINES
    LD      B, 0BH          ; BULLET BONUS SOUND A
    CALL    PLAY_IT
    LD      B, 0CH          ; BULLET BONUS SOUND B
    CALL    PLAY_IT

LOC_83B5:
    LD      A, ($7161)
    LD      HL, $7269
    CP      0
    JR      Z, LOC_83C2
    LD      HL, $726D

LOC_83C2:
    LD      A, (HL)
    CP      1
    JR      C, LOC_83E4
    LD      A, 0FFH
    LD      ($7033), A
    LD      HL, $7034
    SET     0, (HL)
    CALL    SUB_8507
    LD      A, 5
    LD      ($7267), A
    CALL    SUB_A4BE
    LD      HL, 7
    CALL    REQUEST_TEST_AND_FREE_SIGNAL
    JR      LOC_83B5

LOC_83E4:
    CALL    INITIALIZE_SOUND
    LD      HL, 0B4H
    CALL    REQUEST_TEST_AND_FREE_SIGNAL
    LD      HL, $716E
    LD      DE, $719C
    CALL    INIT_TIMER
    LD      A, ($7161)
    LD      HL, $7269
    LD      DE, $726D
    OR      A
    JR      Z, LOC_8403
    EX      DE, HL

LOC_8403:
    LD      A, 30H
    LD      (HL), A
    LD      HL, 2800H
    LD      DE, 80H
    XOR     A
    CALL    FILL_VRAM
    CALL    CLEAR_SCREEN_WITH_FF
RET

MISC_SYMBOLS:
	DB    2   
    DB 0A0H
    DB    0
    DB  80H
    DB    0
    DW MISC_PATTERNS
    DB    3
    DB    0
    DB    2
    DB  23H
    DW UNK_9DC4

SEVERAL_OBJECTS_AT_ONCE:  
    LD      HL, $710E
    INC     HL
    INC     HL
    INC     HL
    LD      A, 0C1H
    LD      (HL), A
    LD      IX, OFF_9296
    CALL    PUTOBJ
    LD      HL, $7114
    INC     HL
    INC     HL
    INC     HL
    LD      A, 0C1H
    LD      (HL), A
    LD      IX, OFF_929B
    CALL    PUTOBJ
    LD      HL, $711A
    INC     HL
    INC     HL
    INC     HL
    LD      A, 0C1H
    LD      (HL), A
    LD      IX, OFF_92A0
    CALL    PUTOBJ
    LD      HL, $70BC
    INC     HL
    INC     HL
    INC     HL
    LD      A, 0C1H
    LD      (HL), A
    LD      IX, GUN_SPRITE
    CALL    PUTOBJ
    CALL    INITIALIZE_SOUND
    LD      HL, 1EH
    LD      A, 1
    CALL    REQUEST_SIGNAL
    LD      ($7030), A
    LD      A, 6
    LD      ($7031), A
    LD      HL, $70F2
    INC     (HL)
    LD      IX, PIPES_MESSAGE
    CALL    PUTOBJ

ANOTHER_TEST_ANOTHER_OBJECT:           
    CALL    MAJOR_SET_OF_ROUTINES
    LD      A, ($7030)
    CALL    TEST_SIGNAL
    OR      A
    JR      Z, LOC_849D
    LD      HL, $70F2
    LD      A, (HL)
    XOR     3
    LD      (HL), A
    LD      IX, PIPES_MESSAGE
    CALL    PUTOBJ
    LD      HL, $7031
    DEC     (HL)

LOC_849D:
    LD      HL, $7031
    LD      A, (HL)
    OR      A
    JR      NZ, ANOTHER_TEST_ANOTHER_OBJECT
    LD      A, ($7030)
    CALL    FREE_SIGNAL
    LD      HL, (WORD_8008)
    LD      A, 90H
    LD      (HL), A
    INC     HL
    LD      (HL), A
    LD      HL, 0E10H
    XOR     A
    CALL    REQUEST_SIGNAL
    LD      ($7030), A
    XOR     A
    LD      ($7032), A

LOC_84C0:
    CALL    MAJOR_SET_OF_ROUTINES
    LD      A, ($7030)
    CALL    TEST_SIGNAL
    OR      A
    JR      Z, LOC_84D4
    CALL    WRITING_A_REGISTER
    LD      A, 1
    LD      ($7032), A

LOC_84D4:
    LD      A, ($7168)
    CP      0AH
    JR      Z, LOC_84EA
    CP      0BH
    JR      Z, LOC_84EA
    LD      A, ($716D)
    CP      0AH
    JR      Z, LOC_84EA
    CP      0BH
    JR      NZ, LOC_84C0

LOC_84EA:
    CP      0AH
    JR      NZ, LOC_84F2
    LD      B, 4
    JR      LOC_84F4

LOC_84F2:
    LD      B, 2

LOC_84F4:
    CALL    SUB_9DC7
    LD      A, ($7032)
    OR      A
    JR      Z, LOC_8500
    CALL    WRITING_A_REGISTER

LOC_8500:
    LD      A, ($7030)
    CALL    FREE_SIGNAL
RET

SUB_8507:
    CALL    SUB_851A
    LD      A, ($7034)
    BIT     0, A
    JP      NZ, DEAL_WITH_HUD_BULLETS
    BIT     7, A
    JP      NZ, LOC_8566
    JP      DEAL_WITH_HUD_BULLETS

SUB_851A:
    LD      A, ($7033)
    OR      A
    JR      Z, LOC_855F
    PUSH    AF
    XOR     A
    LD      ($7033), A
    LD      IX, $7269
    LD      A, ($7161)
    OR      A
    JR      Z, LOC_8533
    LD      IX, $726D

LOC_8533:
    POP     AF
    LD      B, (IX+0)
    ADD     A, B
    PUSH    AF
    CP      0
    JP      M, LOC_8554
    LD      HL, $7034
    RES     7, (HL)
    CP      0BH
    JR      NC, LOC_8549
    SET     7, (HL)

LOC_8549:
    POP     AF
    CP      3DH
    JR      C, LOC_8550
    LD      A, 3CH

LOC_8550:
    LD      (IX+0), A
RET

LOC_8554:
    LD      (IX+0), 0
    LD      HL, $7034
    SET     0, (HL)

LOC_855D:
    POP     AF
RET

LOC_855F:
    LD      HL, $7034
    BIT     7, (HL)
    JR      Z, LOC_855D

LOC_8566:
    LD      HL, $7035
    DEC     (HL)
	RET     P
    LD      HL, $7036
    INC     (HL)
    BIT     0, (HL)
    JR      Z, LOC_8578
    CALL    CLEAR_EVERYTHING_FROM_THE_HUD
    JR      LOC_857B

LOC_8578:
    CALL    DEAL_WITH_HUD_BULLETS

LOC_857B:
    LD      A, 0FH
    LD      ($7035), A
RET

DEAL_WITH_HUD_BULLETS:    
    LD      IX, $7269
    LD      A, ($7161)
    OR      A
    JR      Z, PLACE_BULLETS_INTO_HUD
    LD      IX, $726D

PLACE_BULLETS_INTO_HUD:   
    LD      A, (IX+0)
    CP      0
    JR      Z, CLEAR_EVERYTHING_FROM_THE_HUD
    CP      1
    JR      Z, LOC_85F9
    OR      A
    RR      A
    PUSH    AF
    LD      E, A
    OR      A
    LD      A, 1EH
    SBC     A, E
    LD      D, A
    PUSH    DE
    LD      D, 0
    LD      HL, 22E1H
    LD      A, 0DH          ; BULLET PATTERN
    LD      IX, FILL_VRAM
    CALL    SUB_A439
    POP     DE
    LD      A, D
    CP      1
    JR      Z, LOC_860F

FILL_SOME_VRAM_COLOR_02:  
    LD      A, 1EH
    CP      E
    JR      Z, LOC_855D
    POP     AF
    JR      NC, CLEAR_A_SINGLE_BULLET_FROM_THE_HUD
    PUSH    DE
    LD      HL, 22E1H
    LD      D, 0
    ADD     HL, DE
    LD      DE, 1
    LD      A, 0EH
    LD      IX, FILL_VRAM
    CALL    SUB_A439
    POP     DE
    DEC     D
    INC     E

CLEAR_A_SINGLE_BULLET_FROM_THE_HUD:    
    LD      C, D
    LD      D, 0
    LD      HL, 22E1H
    ADD     HL, DE
    LD      E, C
    LD      A, 0FH          ; CLEARS A SINGLE BULLET FROM THE HUD AFTER FIRING
    LD      IX, FILL_VRAM
    CALL    SUB_A439
RET

CLEAR_EVERYTHING_FROM_THE_HUD:         
    LD      HL, 22E1H
    LD      DE, 1EH
    LD      A, 0FFH         ; CLEARS BULLET MESSEGE AREA COMPLETELY
    LD      IX, FILL_VRAM
    CALL    SUB_A439
RET

LOC_85F9:
    LD      HL, 22E1H
    CALL    CLEARED_BULLET_PATTERN_SPACING
    LD      HL, 22E2H
    LD      DE, 1DH
    LD      A, 0FH
    LD      IX, FILL_VRAM
    CALL    SUB_A439
RET

LOC_860F:
    POP     AF
    PUSH    AF
    JR      NC, FILL_SOME_VRAM_COLOR_02
    POP     AF
    LD      HL, 22FEH

CLEARED_BULLET_PATTERN_SPACING:        
    LD      DE, 1
    LD      A, 0EH          ; CLEARED BULLET SPACING
    LD      IX, FILL_VRAM
    CALL    SUB_A439
RET

SIGNAL_STUFF:    
    LD      A, ($7265)
    CALL    TEST_SIGNAL
    CP      1
    JR      NZ, LOC_8649
    CALL    INITIALIZE_PATTERN_TABLE
    LD      A, ($7037)
    CP      0
    CALL    Z, SUB_89BC
    LD      A, ($7265)
    CALL    FREE_SIGNAL
    CALL    SUB_864D
    XOR     A
    CALL    REQUEST_SIGNAL
    LD      ($7265), A

LOC_8649:
    CALL    SUB_8825
RET

SUB_864D:
    LD      A, ($7160)
    LD      HL, UNK_867D
    CP      0
    JR      Z, LOC_8661
    LD      HL, UNK_8682
    CP      1
    JR      Z, LOC_8661
    LD      HL, UNK_8687

LOC_8661:
    LD      A, ($727A)
    CP      0AH
    JR      C, LOC_8678
    INC     HL
    CP      14H
    JR      C, LOC_8678
    INC     HL
    CP      1EH
    JR      C, LOC_8678
    INC     HL
    CP      2DH
    JR      C, LOC_8678
    INC     HL

LOC_8678:
    LD      A, (HL)
    LD      L, A
    XOR     A
    LD      H, A
RET

UNK_867D:
	DB    6   
    DB    6
    DB    6
    DB    6
    DB    6

UNK_8682:
	DB    7   
    DB    6
    DB    5
    DB    5
    DB    5

UNK_8687:
	DB    7   
    DB    6
    DB    5
    DB    4
    DB    3

INITIALIZE_PATTERN_TABLE: 
    CALL    SUB_869D
    CALL    INIT_PATTERN_TABLE
    LD      A, ($7037)
    CP      0
    JR      NZ, LOCRET_869C
    CALL    SUB_86C8

LOCRET_869C:     
RET

SUB_869D:
    LD      A, ($7037)
    INC     A
    CP      4
    JR      NZ, LOC_86A6
    XOR     A

LOC_86A6:
    LD      ($7037), A
RET

INIT_PATTERN_TABLE:  
    LD      A, ($7037)
    RLC     A
    LD      C, A
    LD      B, 0
    LD      HL, UNK_86C0
    ADD     HL, BC
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    EX      DE, HL
    LD      A, 3
    CALL    INIT_TABLE
RET

UNK_86C0:
	DB    0   
    DB    0
    DB    0
    DB    8
    DB    0
    DB  10H
    DB    0
    DB  18H

SUB_86C8:
    LD      IX, LOC_86D0
    CALL    SUB_A439
RET

LOC_86D0:
    LD      DE, 2102H
    LD      HL, $703A
    LD      BC, 1AH
    CALL    READ_VRAM
    LD      A, ($7065)
    LD      ($7058), A
    LD      A, ($7066)
    LD      ($7065), A
    LD      A, ($7053)
    LD      ($7066), A
    LD      A, ($705D)
    LD      ($7039), A
    LD      DE, 2102H
    LD      HL, $7039
    LD      BC, 1AH
    CALL    WRITE_VRAM
    LD      DE, 2122H
    LD      HL, $703A
    LD      BC, 1AH
    CALL    READ_VRAM
    LD      A, ($7063)
    LD      ($7057), A
    LD      A, ($7064)
    LD      ($7063), A
    LD      A, ($7053)
    LD      ($7064), A
    LD      A, ($705B)
    LD      ($7039), A
    LD      DE, 2122H
    LD      HL, $7039
    LD      BC, 1AH
    CALL    WRITE_VRAM
    LD      DE, 2162H
    LD      HL, $7038
    LD      BC, 1AH
    CALL    READ_VRAM
    LD      A, ($7061)
    LD      ($705A), A
    LD      A, ($7062)
    LD      ($7061), A
    LD      A, ($7038)
    LD      ($7062), A
    LD      A, ($7058)
    LD      ($7052), A
    CALL    SUB_8813
    LD      DE, 2162H
    LD      HL, $7039
    LD      BC, 1AH
    CALL    WRITE_VRAM
    LD      DE, 2182H
    LD      HL, $7038
    LD      BC, 1AH
    CALL    READ_VRAM
    LD      A, ($705F)
    LD      ($7059), A
    LD      A, ($7060)
    LD      ($705F), A
    LD      A, ($7038)
    LD      ($7060), A
    LD      A, ($7057)
    LD      ($7052), A
    CALL    SUB_8813
    LD      DE, 2182H
    LD      HL, $7039
    LD      BC, 1AH
    CALL    WRITE_VRAM
    LD      DE, 21C2H
    LD      HL, $703A
    LD      BC, 1AH
    CALL    READ_VRAM
    LD      A, ($705E)
    LD      ($705D), A
    LD      A, ($7053)
    LD      ($705E), A
    LD      A, ($705A)
    LD      ($7039), A
    CALL    SUB_8801
    LD      DE, 21C2H
    LD      HL, $7039
    LD      BC, 1AH
    CALL    WRITE_VRAM
    LD      DE, 21E2H
    LD      HL, $703A
    LD      BC, 1AH
    CALL    READ_VRAM
    LD      A, ($705C)
    LD      ($705B), A
    LD      A, ($7053)
    LD      ($705C), A
    LD      A, ($7059)
    LD      ($7039), A
    CALL    SUB_8801
    LD      DE, 21E2H
    LD      HL, $7039
    LD      BC, 1AH
    CALL    WRITE_VRAM
    LD      HL, $7054
    LD      A, (HL)
    XOR     8
    LD      (HL), A
    JR      NZ, LOCRET_8800
    LD      HL, ($7055)
    INC     HL
    LD      ($7055), HL

LOCRET_8800:     
RET

SUB_8801:
    LD      HL, $7039
    LD      A, (HL)
    CP      0FCH
    JR      NC, LOC_8811
    ADD     A, 0FEH
    CP      0DFH
    JR      NC, LOC_8811
    ADD     A, 0FEH

LOC_8811:
    LD      (HL), A
RET

SUB_8813:
    LD      HL, $7052
    LD      A, (HL)
    CP      0FCH
    JR      NC, LOC_8823
    ADD     A, 2
    CP      0DFH
    JR      NC, LOC_8823
    ADD     A, 2

LOC_8823:
    LD      (HL), A
RET

SUB_8825:
    XOR     A
    LD      ($7083), A
    LD      HL, $7091
    BIT     6, (HL)
    JP      NZ, LOCRET_89B3
    LD      IX, $708B
    CP      (IX+0)
    JP      NZ, LOCRET_89B3
    LD      A, (IX+3)
    ADD     A, 2
    CP      80H
    JP      NC, LOCRET_89B3
    CP      70H
    JR      C, LOC_8853
    LD      DE, 1E0H
    LD      A, 70H
    LD      ($7084), A
    JR      LOC_887D

LOC_8853:
    CP      68H
    JP      NC, LOCRET_89B3
    CP      58H
    JR      C, LOC_886B
    LD      DE, 180H
    LD      A, 0FFH
    LD      ($7083), A
    LD      A, 58H
    LD      ($7084), A
    JR      LOC_887D

LOC_886B:
    CP      50H
    JP      NC, LOCRET_89B3
    CP      40H
    JP      C, LOCRET_89B3
    LD      DE, 120H
    LD      A, 40H
    LD      ($7084), A

LOC_887D:
    LD      HL, 2000H
    ADD     HL, DE
    LD      DE, $7067
    EX      DE, HL
    LD      BC, 1CH
    CALL    READ_VRAM
    LD      A, (IX+1)
    ADD     A, 2
    CP      10H
    JP      C, LOCRET_89B3
    CP      0E0H
    JP      NC, LOCRET_89B3
    LD      C, A
    LD      L, C
    SRL     L
    SRL     L
    SRL     L
    LD      H, 0
    LD      DE, $7067
    ADD     HL, DE
    LD      A, (HL)
    CP      0FCH
    JP      NC, LOCRET_89B3
    LD      B, A
    LD      A, 0F8H
    AND     C
    LD      HL, ($7054)
    LD      D, A
    AND     8
    XOR     L
    LD      A, D
    JR      Z, LOC_88BE
    SUB     8

LOC_88BE:
    LD      D, A
    LD      HL, ($7037)
    SLA     L
    LD      A, ($7083)
    CP      0
    LD      A, L
    JR      Z, LOC_88D0
    NEG
    ADD     A, 8

LOC_88D0:
    ADD     A, D
    LD      L, A
    LD      A, C
    SUB     L
    LD      C, D
    JP      C, LOCRET_89B3
    LD      D, A
    LD      A, B
    CP      0DFH
    LD      A, D
    JR      C, OBJECT_AND_BULLET_DING_01_A
    CP      0
    JP      C, LOCRET_89B3
    CP      7
    JP      NC, LOCRET_89B3
    LD      A, B
    CP      0F4H
    JR      C, LOC_8900
    CP      0F8H
    LD      A, 5
    JR      C, LOC_88F6
    ADD     A, 5

LOC_88F6:
    LD      ($7033), A
    PUSH    BC
    CALL    SUB_8507
    POP     BC
    JR      OBJECT_AND_SOUND_00

LOC_8900:
    LD      A, D
    CP      2
    JP      C, LOCRET_89B3
    CP      5
    JP      NC, LOCRET_89B3

OBJECT_AND_SOUND_00: 
    LD      A, (IX+3)
    AND     0F8H
    CP      40H
    JP      Z, LOCRET_89B3
    CP      58H
    JP      Z, LOCRET_89B3
    CP      70H
    JP      Z, LOCRET_89B3
    JR      OBJECT_AND_BULLET_DING_01_B

OBJECT_AND_BULLET_DING_01_A:           
    CP      7
    JP      NC, LOCRET_89B3

OBJECT_AND_BULLET_DING_01_B:           
    LD      HL, $7091
    SET     6, (HL)
    LD      HL, $7339
    LD      (HL), B
    LD      HL, $733A
    LD      A, ($7084)
    LD      (HL), A
    LD      HL, $7266
    DEC     (HL)
    LD      IY, $7085
    LD      (IY+3), A
    XOR     A
    LD      (IY+0), A
    LD      (IY+1), C
    LD      IX, TARGETS
    CALL    PUTOBJ
    PUSH    BC
    LD      B, 4
    CALL    PLAY_IT         ; BULLET HIT DING (GENERAL HIT)
    LD      B, 5
    CALL    PLAY_IT
    LD      B, 6
    CALL    PLAY_IT
    POP     BC
    LD      A, C
    CP      10H
    JR      NC, LOC_8988
    LD      A, ($7084)
    CP      70H
    JR      NZ, LOC_8974
    LD      DE, $7061
    LD      HL, $705F
    JR      LOC_89AF

LOC_8974:
    CP      58H
    JR      NZ, LOC_8980
    LD      DE, $7062
    LD      HL, $7060
    JR      LOC_89AF

LOC_8980:
    LD      DE, $705D
    LD      HL, $705B
    JR      LOC_89AF

LOC_8988:
    CP      0D8H
    JR      NZ, LOCRET_89B3
    LD      A, ($7084)
    CP      70H
    JR      NZ, LOC_899B
    LD      DE, $705E
    LD      HL, $705C
    JR      LOC_89AF

LOC_899B:
    CP      58H
    JR      NZ, LOC_89A7
    LD      DE, $7065
    LD      HL, $7063
    JR      LOC_89AF

LOC_89A7:
    LD      DE, $7066
    LD      HL, $7064
    JR      LOC_89AF

LOC_89AF:
    LD      A, 0FFH
    LD      (HL), A
    LD      (DE), A

LOCRET_89B3:     
RET

SOME_TABLE:
	DW TABLE_SET_12        
    DW TABLE_SET_10
    DW TABLE_SET_08
    DW TABLE_SET_06

SUB_89BC:
    LD      A, ($7054)
    CP      0
    JP      NZ, LOC_8A78
    LD      A, 0FFH
    LD      HL, $705B
    CP      (HL)
    JP      NZ, LOC_8A78
    LD      HL, $705C
    CP      (HL)
    JP      NZ, LOC_8A78
    LD      A, ($7160)
    SLA     A
    LD      L, A
    LD      H, 0
    LD      DE, SOME_TABLE
    ADD     HL, DE
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    LD      A, ($7161)
    LD      IX, $7269
    CP      0
    JR      Z, LOC_89F2
    LD      IX, $726D

LOC_89F2:
    LD      A, (IX+3)
    EX      DE, HL
    INC     A
    CP      (HL)
    DEC     A
    JR      Z, LOC_89FF
    JR      C, LOC_89FF
    LD      A, (HL)
    DEC     A

LOC_89FF:
    SLA     A
    SLA     A
    INC     HL
    LD      E, A
    LD      D, 0
    ADD     HL, DE
    INC     HL
    INC     HL
    LD      E, (HL)
    INC     HL
    LD      D, (HL)

LOC_8A0D:
    LD      H, D
    LD      L, E
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    LD      HL, ($7055)
    AND     A
    SBC     HL, BC
    JR      C, LOC_8A23
    JR      Z, LOC_8A23
    LD      HL, 6
    ADD     HL, DE
    EX      DE, HL
    JR      LOC_8A0D

LOC_8A23:
    EX      DE, HL
    PUSH    HL
    CALL    RAND_GEN
    POP     HL
    LD      B, 3
    LD      C, A
    LD      A, R
    ADD     A, C
    LD      C, A
    XOR     A
    INC     HL

LOOP_8A32:       
    INC     HL
    ADD     A, (HL)
    CP      C
    JR      Z, LOC_8A3B
    JR      NC, LOC_8A3B
    DJNZ    LOOP_8A32

LOC_8A3B:
    LD      A, B
    CP      3
    JR      Z, LOC_8A78
    CP      1
    JR      Z, LOC_8A52
    CP      0
    JR      Z, LOC_8A5C
    LD      B, 0C8H
    LD      C, 0CAH
    LD      D, 0C9H
    LD      E, 0CBH
    JR      LOC_8A64

LOC_8A52:
    LD      B, 0FFH
    LD      C, 0FFH
    LD      D, 0F8H
    LD      E, 0F9H
    JR      LOC_8A64

LOC_8A5C:
    LD      B, 0FFH
    LD      C, 0FFH
    LD      D, 0F4H
    LD      E, 0F5H

LOC_8A64:
    LD      HL, $705E
    LD      (HL), B
    LD      HL, $705D
    LD      (HL), C
    LD      HL, $705C
    LD      (HL), D
    LD      HL, $705B
    LD      (HL), E
    LD      HL, $7266
    INC     (HL)

LOC_8A78:
    LD      A, ($7060)
    CP      0F6H
    JR      Z, LOC_8A83
    CP      0FAH
    JR      NZ, LOCRET_8A91

LOC_8A83:
    LD      HL, $7060
    LD      A, 0FFH
    LD      (HL), A
    LD      HL, $705F
    LD      (HL), A
    LD      HL, $7266
    DEC     (HL)

LOCRET_8A91:     
RET

TARGET_PATS_A:
	DB 012,030,059,063,031,014,006,047
    DB 063,055,049,031,015,008,008,015
    DB 064,128,000,128,064,000,000,000
    DB 128,128,128,128,000,000,000,000
    DB 048,120,220,252,248,112,096,244
    DB 252,236,140,248,240,016,016,240
    DB 002,001,000,001,002,000,000,000
    DB 001,001,001,001,000,000,000,000
    DB 019,022,012,012,015,013,015,007
    DB 015,031,031,030,030,060,063,015
    DB 000,000,000,000,000,128,192,128
    DB 000,128,192,064,000,000,128,192
    DB 200,104,048,048,240,176,240,224
    DB 240,248,248,120,120,060,252,248
    DB 000,000,000,000,000,001,003,001
    DB 000,001,003,002,000,000,001,003
    DB 032,031,063,050,050,063,029,063
    DB 063,063,063,063,063,047,015,025
    DB 064,128,192,064,064,192,128,192
    DB 192,192,192,192,192,064,000,128
    DB 004,248,252,076,076,252,184,252
    DB 252,252,252,252,252,244,240,152
    DB 002,001,003,002,002,003,001,003
    DB 003,003,003,003,003,002,000,001
    DB 014,009,009,014,009,009,015,000
    DB 000,000,000,000,000,000,000,000
    DB 224,144,144,224,144,144,240,000
    DB 000,000,000,000,000,000,000,000
    DB 015,009,009,009,009,009,015,000
    DB 000,000,000,000,000,000,000,000
    DB 240,144,144,144,144,144,240,000
    DB 000,000,000,000,000,000,000,000
    DB 009,013,013,013,015,011,011,000
    DB 000,000,000,000,000,000,000,000
    DB 144,208,208,208,240,208,208,000
    DB 000,000,000,000,000,000,000,000
    DB 009,009,009,009,009,009,015,000
    DB 000,000,000,000,000,000,000,000
    DB 144,144,144,144,144,144,240,000
    DB 000,000,000,000,000,000,000,000
    DB 015,008,008,015,001,001,015,000
    DB 000,000,000,000,000,000,000,000
    DB 240,128,128,240,016,016,240,000
    DB 000,000,000,000,000,000,000,000
    DB 063,048,055,048,062,062,048,063
    DB 192,192,192,192,192,192,192,192
    DB 252,012,124,012,236,236,012,252
    DB 003,003,003,003,003,003,003,003
    DB 063,052,037,053,053,053,052,063
    DB 192,064,064,064,064,064,064,192
    DB 252,068,084,084,084,084,068,252
    DB 003,003,002,003,003,003,003,003

TARGET_PATS_B:
	DB 003,007,014,015,007,003,001,011
    DB 015,013,012,007,003,002,002,003
    DB 016,160,192,224,208,128,128,192
    DB 224,224,096,224,192,000,000,192
    DB 192,224,112,240,224,192,128,208
    DB 240,176,048,224,192,064,064,192
    DB 008,005,003,007,011,001,001,003
    DB 007,007,006,007,003,000,000,003
    DB 004,005,003,003,003,003,003,001
    DB 003,007,007,007,007,015,015,003
    DB 192,128,000,000,192,096,240,224
    DB 192,224,240,144,128,000,224,240
    DB 032,160,192,192,192,192,192,128
    DB 192,224,224,224,224,240,240,224
    DB 003,001,000,000,003,006,015,007
    DB 003,007,015,009,001,000,007,015
    DB 008,007,015,012,012,015,007,015
    DB 015,015,015,015,015,011,003,006
    DB 016,224,240,144,144,240,096,240
    DB 240,240,240,240,240,208,192,096
    DB 016,224,240,048,048,240,224,240
    DB 240,240,240,240,240,208,192,096
    DB 008,007,015,009,009,015,006,015
    DB 015,015,015,015,015,011,003,006
    DB 003,002,002,003,002,002,003,000
    DB 128,064,064,128,064,064,192,000
    DB 128,064,064,128,064,064,192,000
    DB 003,002,002,003,002,002,003,000
    DB 003,002,002,002,002,002,003,000
    DB 192,064,064,064,064,064,192,000
    DB 192,064,064,064,064,064,192,000
    DB 003,002,002,002,002,002,003,000
    DB 002,003,003,003,003,002,002,000
    DB 064,064,064,064,192,192,192,000
    DB 064,064,064,064,192,192,192,000
    DB 002,003,003,003,003,002,002,000
    DB 002,002,002,002,002,002,003,000
    DB 064,064,064,064,064,064,192,000
    DB 064,064,064,064,064,064,192,000
    DB 002,002,002,002,002,002,003,000
    DB 003,002,002,003,000,000,003,000
    DB 192,000,000,192,064,064,192,000
    DB 192,000,000,192,064,064,192,000
    DB 003,002,002,003,000,000,003,000
    DB 015,012,013,012,015,015,012,015
    DB 240,048,240,048,176,176,048,240
    DB 240,048,240,048,176,176,048,240
    DB 015,012,013,012,015,015,012,015
    DB 015,013,009,013,013,013,013,015
    DB 240,016,080,080,080,080,016,240
    DB 240,016,080,080,080,080,016,240
    DB 015,013,009,013,013,013,013,015

TARGET_PATS_C:
	DB 000,001,003,003,001,000,000,002
    DB 003,003,003,001,000,000,000,000
    DB 196,232,176,248,244,224,096,240
    DB 248,120,024,248,240,128,128,240
    DB 000,128,192,192,128,000,000,064
    DB 192,192,192,128,000,000,000,000
    DB 035,023,013,031,047,007,006,015
    DB 031,030,028,031,015,001,001,015
    DB 001,001,000,000,000,000,000,000
    DB 000,001,001,001,001,003,003,000
    DB 048,096,192,192,240,216,252,120
    DB 240,248,252,228,224,192,248,252
    DB 128,128,000,000,000,000,000,000
    DB 000,128,128,128,128,192,192,128
    DB 012,006,003,003,015,027,063,030
    DB 015,031,063,039,007,003,031,063
    DB 002,001,003,003,003,003,001,003
    DB 003,003,003,003,003,002,000,001
    DB 004,248,252,036,036,252,216,252
    DB 252,252,252,252,252,244,240,152
    DB 064,128,192,192,192,192,128,192
    DB 192,192,192,192,192,064,000,128
    DB 032,031,063,036,036,063,027,063
    DB 063,063,063,063,063,047,015,025
    DB 000,000,000,000,000,000,000,000
    DB 224,144,144,224,144,144,240,000
    DB 000,000,000,000,000,000,000,000
    DB 014,009,009,014,009,009,015,000
    DB 000,000,000,000,000,000,000,000
    DB 240,144,144,144,144,144,240,000
    DB 000,000,000,000,000,000,000,000
    DB 015,009,009,009,009,009,015,000
    DB 000,000,000,000,000,000,000,000
    DB 144,208,208,208,240,208,208,000
    DB 000,000,000,000,000,000,000,000
    DB 009,013,013,013,015,011,011,000
    DB 000,000,000,000,000,000,000,000
    DB 144,144,144,144,144,144,240,000
    DB 000,000,000,000,000,000,000,000
    DB 009,009,009,009,009,009,015,000
    DB 000,000,000,000,000,000,000,000
    DB 240,128,128,240,016,016,240,000
    DB 000,000,000,000,000,000,000,000
    DB 015,008,008,015,001,001,015,000
    DB 003,003,003,003,003,003,003,003
    DB 252,012,124,012,236,236,012,252
    DB 192,192,192,192,192,192,192,192
    DB 063,048,055,048,062,062,048,063
    DB 003,003,002,003,003,003,003,003
    DB 252,068,084,084,084,084,068,252
    DB 192,064,064,064,064,064,064,192
    DB 063,052,037,053,053,053,052,063

PIPES_MOVING:
	DB    0   
    DB    0
    DB    0
    DB    0
    DB    0
    DW PIPES_BLANK
    DW PIPE_NE_01
    DW PIPE_NE_02
    DW PIPE_NE_03
    DW PIPE_EAST_01
    DW PIPE_EAST_02
    DW PIPE_EAST_03
    DW PIPE_SE_01
    DW PIPE_SE_02
    DW PIPE_SE_03
    DW PIPE_SOUTH_01
    DW PIPE_SOUTH_02
    DW PIPE_SOUTH_03
    DW PIPE_SW_01
    DW PIPE_SW_02
    DW PIPE_SW_03
    DW PIPE_WEST_01
    DW PIPE_WEST_02
    DW PIPE_WEST_03
    DW PIPE_NW_01
    DW PIPE_NW_02
    DW PIPE_NW_03
    DW PIPE_NORTH_01
    DW PIPE_NORTH_02
    DW PIPE_NORTH_03

PIPES_BLANK:
    DB 001,001
    DB 255
PIPE_NE_01:
	DB 002,002
    DB 120,121
    DB 122,255
PIPE_NE_02:
	DB 003,002
    DB 255,126,127
    DB 128,129,130
PIPE_NE_03:
	DB 003,002
    DB 136,137,138
    DB 142,143,144
PIPE_EAST_01:
	DB 003,001
    DB 099,100,101
PIPE_EAST_02:
	DB 003,002
    DB 091,092,093
    DB 197,094,095
PIPE_EAST_03:
	DB 003,002
    DB 109,110,111
    DB 255,112,113
PIPE_SE_01:
	DB 002,002
    DB 172,173
    DB 174,175
PIPE_SE_02:
	DB 001,002
    DB 178
    DB 179
PIPE_SE_03:
	DB 001,002
    DB 183
    DB 181
PIPE_SOUTH_01:
	DB 002,002
    DB 156,157
    DB 158,159
PIPE_SOUTH_02:
	DB 002,002
    DB 156,157
    DB 162,163
PIPE_SOUTH_03:
	DB 002,002
    DB 147,156
    DB 166,167
PIPE_SW_01:
	DB 002,002
    DB 255,123
    DB 124,125
PIPE_SW_02:
	DB 003,002
    DB 131,132,133
    DB 134,135,255
PIPE_SW_03:
	DB 003,002
    DB 139,140,141
    DB 145,146,147
PIPE_WEST_01:
	DB 003,001
    DB 096,097,098
PIPE_WEST_02:
	DB 003,002
    DB 102,103,187
    DB 088,089,090
PIPE_WEST_03:
	DB 003,002
    DB 104,105,255
    DB 106,107,108
PIPE_NW_01:
	DB 002,002
    DB 168,169
    DB 170,171
PIPE_NW_02:
	DB 001,002
    DB 176
    DB 177
PIPE_NW_03:
	DB 001,002
    DB 180
    DB 182
PIPE_NORTH_01:
	DB 002,002
    DB 152,153
    DB 154,155
PIPE_NORTH_02:
	DB 002,002
    DB 160,161
    DB 154,155
PIPE_NORTH_03:
	DB 002,002
    DB 164,165
    DB 155,136
    DB    3
    DB    0
    DB    0
    DB    0
    DB    0
    DB  48H
    DB  0CH
    DB    0
    DB  0CH
    DB    4
    DB  0CH
    DB    8
    DB  0CH
    DB  0CH
    DB  0CH
    DB  10H
    DB  0CH
    DB  14H
    DB  0CH
    DB  18H
    DB  0CH
    DB  1CH
    DB  0CH
    DB  20H
    DB  0CH
    DB  24H

MYSTERY_PATTERN_A:
	DB 080,080,112,112,208,160,160,160
    DB 192,192,192,096,096,096,096,192
    DB 192,192,192,224,224,080,080,160
    DB 160,160,240,096,080,080,080,080
MYSTERY_PATTERN_B:
	DB 080,080,112,112,208,160,160,160
    DB 192,192,192,192,192,192,192,224
    DB 224,224,224,080,080,096,096,160
    DB 160,160,240,096,080,080,080,080
MYSTERY_PATTERN_C:
	DB 080,080,112,112,208,160,160,160
    DB 192,192,192,224,224,224,224,080
    DB 080,080,080,096,096,192,192,160
    DB 160,160,240,096,080,080,080,080
MYSTERY_PATTERN_D:
	DB 080,080,112,112,208,160,160,160
    DB 192,192,192,080,080,080,080,096
    DB 096,096,096,192,192,224,224,160
    DB 160,160,240,096,080,080,080,080

TARGETS:
	DW TARGETS_OBJ         
    DW $7085
    DB    0
    DB  80H

TARGETS_OBJ:
    DB    0   
    DB    0
    DB    0
    DB    0
    DB    0
    DW TARGET_BLANK
    DW DUCK_RIGHT
    DW RABBIT_RIGHT
    DW OWL_RIGHT
    DW BONUS_B_RIGHT
    DW BONUS_O_RIGHT
    DW BONUS_N_RIGHT
    DW BONUS_U_RIGHT
    DW BONUS_S_RIGHT
    DW BONUS_5_RIGHT
    DW BONUS_10_RIGHT
    DW DUCK_LEFT
    DW RABBIT_LEFT
    DW OWL_LEFT
    DW BONUS_B_LEFT
    DW BONUS_O_LEFT
    DW BONUS_N_LEFT
    DW BONUS_U_LEFT
    DW BONUS_S_LEFT
    DW BONUS_5_LEFT
    DW BONUS_10_LEFT
TARGET_BLANK:
	DB 002,002
    DB 255,255
    DB 255,255
DUCK_RIGHT:
	DB 002,002
    DB 200,202
    DB 201,203
RABBIT_RIGHT:
	DB 002,002
    DB 208,210
    DB 209,211
OWL_RIGHT:
	DB 002,002
    DB 216,218
    DB 217,219
BONUS_B_RIGHT:
	DB 002,002
    DB 255,255
    DB 224,225
BONUS_O_RIGHT:
	DB 002,002
    DB 255,255
    DB 228,229
BONUS_N_RIGHT:
	DB 002,002
    DB 255,255
    DB 232,233
BONUS_U_RIGHT:
	DB 002,002
    DB 255,255
    DB 236,237
BONUS_S_RIGHT:
	DB 002,002
    DB 255,255
    DB 240,241
BONUS_5_RIGHT:
	DB 002,002
    DB 255,255
    DB 244,245
BONUS_10_RIGHT:
	DB 002,002
    DB 255,255
    DB 248,249
DUCK_LEFT:
	DB 002,002
    DB 206,204
    DB 207,205
RABBIT_LEFT:
	DB 002,002
    DB 214,212
    DB 215,213
OWL_LEFT:
	DB 002,002
    DB 222,220
    DB 223,221
BONUS_B_LEFT:
	DB 002,002
    DB 255,255
    DB 227,226
BONUS_O_LEFT:
	DB 002,002
    DB 255,255
    DB 231,230
BONUS_N_LEFT:
	DB 002,002
    DB 255,255
    DB 235,234
BONUS_U_LEFT:
	DB 002,002
    DB 255,255
    DB 239,238
BONUS_S_LEFT:
	DB 002,002
    DB 255,255
    DB 243,242
BONUS_5_LEFT:
	DB 002,002
    DB 255,255
    DB 247,246
BONUS_10_LEFT:
	DB 002,002
    DB 255,255
    DB 251,250

BULLET:
	DW BULLET_FRAME        
    DW $708B
    DB    1
BULLET_FRAME:
	DB    3   
    DB    0
    DB    0
    DB    0
    DB    0
    DW BULLET_SPRITE
BULLET_SPRITE:
	DB  0CH   
    DB    4
    DB    5
    DB  10H
    DB  0AH, 0CH
    DB    6
    DB    8
FLYING_DUCK:
    DW DUCK_FRAME          
    DW $709E
    DB    0
    DB  80H
DUCK_FRAME:
	DB    0   
    DB    0
    DB    0
    DB    0
    DB    0
    DW $7092
DUCK_SPRITE:
    DW DUCK_SPRITE_OBJ     
    DW $70A4
    DB    2
    DW DUCK_SPRITE_OBJ
    DW $70AA
    DB    3
    DW DUCK_SPRITE_OBJ
    DW $70B0
    DB    4
    DW DUCK_SPRITE_OBJ
    DW $70B6
    DB    5
DUCK_SPRITE_OBJ:DB    3   
    DB    0
    DB    0
    DB    0
    DB    0
    DW DUCK_ANIM
DUCK_ANIM:
	DB  0AH, 1CH           
    DB  0AH, 20H
    DB  0AH, 24H
    DB  0AH, 28H
    DB  0AH, 2CH
    DB  0AH, 30H
    DB  0AH, 34H
    DB  0AH, 38H
    DB  0AH, 3CH
    DB  0AH, 40H
    DB  0AH, 44H
    DB  0AH, 48H
    DB  0AH, 4CH
    DB  0AH,0B0H            ; EATING ANIMATION
    DB  0AH,0B4H
GUN_SPRITE:
	DW GUN_OBJ
    DW $70BC
    DB    0
GUN_OBJ:
	DB    3   
    DB    0
    DB    0
    DB    0
    DB    0
    DW GUN_FRAME
GUN_FRAME:
	DB    7   
    DB    0
PIPES_PART_01:
	DW PIPES_MOVING        
    DW $70C2
    DB    0
    DB  80H
PIPES_PART_02:
	DW PIPES_MOVING        
    DW $70C8
    DB    0
    DB  80H
PIPES_PART_03:
	DW PIPES_MOVING        
    DW $70CE
    DB    0
    DB  80H
PIPES_PART_04:
	DW PIPES_MOVING        
    DW $70D4
    DB    0
    DB  80H
PIPES_PART_05:
	DW PIPES_MOVING        
    DW $70DA
    DB    0
    DB  80H
PIPES_PART_06:
	DW PIPES_MOVING        
    DW $70E0
    DB    0
    DB  80H
PIPES_PART_07:
	DW PIPES_MOVING        
    DW $70E6
    DB    0
    DB  80H
PIPES_PART_08:
	DW PIPES_MOVING        
    DW $70EC
    DB    0
    DB  80H
PIPES_MESSAGE:
	DW PIPES_MSG_OBJ       
    DW $70F2
    DB    0
    DB  80H
PIPES_MSG_OBJ:
	DB    0   
    DB    0
    DB    0
    DB    0
    DB    0
    DW PIPES_MSG_FRM_A
    DW PIPES_MSG_FRM_B
    DW PIPES_MSG_FRM_C
PIPES_MSG_FRM_A:
	DB 006,003
    DB 072,073,074,075,076,077
    DB 078,079,080,081,082,083
    DB 084,085,085,085,085,086
PIPES_MSG_FRM_B:
	DB 006,003
    DB 255,053,054,055,056,255
    DB 255,057,058,059,060,255
    DB 255,255,255,255,255,255
PIPES_MSG_FRM_C:
	DB 006,003
    DB 255,255,255,255,255,255
    DB 255,255,255,255,255,255
    DB 255,255,255,255,255,255
OFF_9274:
	DW UNK_927A            
    DW $7108
    DB    0
    DB  80H
UNK_927A:
	DB    0   
    DB    0
    DB    0
    DB    0
    DB    0
    DW $70F8
UNK_9281:
	DB    7   
    DB    2
    DB  30H
    DB  31H
    DB  32H
    DB  33H
    DB  34H
    DB 0FFH
    DB    1
    DB 0FFH
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB 0FFH
    DB    0
    DB  20H
    DB    0
    DB    0
    DB    0
OFF_9296:
	DW UNK_92A5            
    DW $710E
    DB  0CH
OFF_929B:
	DW UNK_92A5            
    DW $7114
    DB  0DH
OFF_92A0:
	DW UNK_92A5            
    DW $711A
    DB  0EH
UNK_92A5:
	DB    3   
    DB  50H
    DB    0
    DB    0
    DB    0
    DW UNK_92AC
UNK_92AC:
	DB  0CH   
    DB    0
    DB  0CH
    DB    4
    DB  0CH
    DB    8
    DB  0CH
    DB  0CH
    DB  0CH
    DB  10H
    DB  0CH
    DB  14H
    DB  0CH
    DB  18H
    DB  0CH
    DB  1CH
    DB  0CH
    DB  20H
    DB  0CH
    DB  24H
OFF_92C0:
	DW UNK_92C6            
    DW $7120
    DB    0
    DB  80H
UNK_92C6:
	DB    0   
    DB    0
    DB    0
    DB    0
    DB    0
    DW UNK_92D5
    DW UNK_92DF
    DW UNK_92E9
    DW UNK_92F3
    DW UNK_92FD
UNK_92D5:
	DB    1   
    DB    8
    DB    5
    DB    0
    DB 0FFH
    DB    3
    DB    0
    DB 0FFH
    DB    1
    DB    0
UNK_92DF:
	DB    1   
    DB    8
    DB    6
    DB    0
    DB 0FFH
    DB    4
    DB    0
    DB 0FFH
    DB    2
    DB    0
UNK_92E9:
	DB    1   
    DB    8
    DB    7
    DB    0
    DB 0FFH
    DB    5
    DB    0
    DB 0FFH
    DB    3
    DB    0
UNK_92F3:
	DB    1   
    DB    8
    DB    8
    DB    0
    DB 0FFH
    DB    6
    DB    0
    DB 0FFH
    DB    4
    DB    0
UNK_92FD:
	DB    1   
    DB    8
    DB    9
    DB    0
    DB 0FFH
    DB    7
    DB    0
    DB 0FFH
    DB    5
    DB    0
PIPES_MAIN:
	DW PIPES_MAIN_OBJ      
    DW $7126
    DB    0
    DB  80H
PIPES_MAIN_OBJ:
	DB    0   
    DB    0
    DB    0
    DB    0
    DB    0
    DW PIPES_MAIN_FRAME
PIPES_MAIN_FRAME:
	DB    8,   5          
    DB 0FFH,0FFH,0FFH,0BAH,0C1H,0FFH,0FFH,0FFH
    DB 0FFH,0FFH,0BBH,0BCH,0C2H,0C3H,0FFH,0FFH
    DB 0FFH,0FFH,0BDH,0B8H,0B9H,0C4H,0FFH,0FFH
    DB 0FFH,0FFH,0BEH,0BFH,0C6H,0C5H,0FFH,0FFH
    DB 0FFH,0FFH,0FFH,0C0H,0C7H,0FFH,0FFH,0FFH
PIPES_PARTS:
    DW PIPES_PARTS_OBJ     
    DW $712B
    DW PIPES_MAIN
    DW PIPES_PART_01
    DW PIPES_PART_02
    DW PIPES_PART_03
    DW PIPES_PART_04
    DW PIPES_PART_05
    DW PIPES_PART_06
    DW PIPES_PART_07
    DW PIPES_PART_08
    DW PIPES_MESSAGE
    DW OFF_9296
    DW OFF_929B
    DW OFF_92A0
PIPES_PARTS_OBJ:
	DB 0D4H   
    DW $7130
    DW $713D
UNK_9361:
	DB    0   
    DB    1
    DB    4,   7
    DB  0AH
    DB  0DH
    DB  10H
    DB  13H
    DB  16H
    DB    0
    DB    5
    DB    0
    DB    0
    DB    0
    DB    0
    DB  28H
    DB    0
    DB  28H
    DB  10H
    DB  28H
    DB  18H
    DB  18H
    DB  18H
    DB    8
    DB  18H
    DB    0
    DB  10H
    DB    8
    DB    0
    DB  18H
    DB    0
    DB    8
    DB  28H
    DB  14H
    DB  32H
    DB  1CH
    DB  32H
    DB  24H
    DB  32H
    DB    0
    DB    1
    DB    1
    DB    2
    DB    2
    DB    0
MUSIC_NOTE_SPRITE:
	DW MUSIC_NOTE_OBJ    
    DW $7157
    DB  0FH
MUSIC_NOTE_OBJ:
	DB    3   
    DB  14H
    DB    0
    DB    0
    DB    0
    DW MUSIC_NOTE_FRAME
MUSIC_NOTE_FRAME:
	DB    7  
    DB    0
    DB    7
    DB    4
TABLE_SET_12:
	DB    6   
    DW UNK_93EA
    DW UNK_9402
    DW UNK_93EE
    DW UNK_9402
    DW UNK_93F2
    DW UNK_942C
    DW UNK_93F6
    DW UNK_942C
    DW UNK_93FA
    DW UNK_9456
    DW UNK_93FE
    DW UNK_9456
TABLE_SET_10:
	DB    5   
    DW UNK_93EE
    DW UNK_9402
    DW UNK_93F2
    DW UNK_942C
    DW UNK_93F6
    DW UNK_942C
    DW UNK_93FA
    DW UNK_9456
    DW UNK_93FE
    DW UNK_9456
TABLE_SET_08:
	DB    4   
    DW UNK_93F2
    DW UNK_9402
    DW UNK_93F6
    DW UNK_942C
    DW UNK_93FA
    DW UNK_9456
    DW UNK_93FE
    DW UNK_9456
TABLE_SET_06:
	DB    3   
    DW UNK_93F6
    DW UNK_9402
    DW UNK_93FA
    DW UNK_942C
    DW UNK_93FE
    DW UNK_9456
UNK_93EA:
	DB  0AH   
    DB    4
    DB  0AH
    DB  0AH
UNK_93EE:
	DB  0AH   
    DB    6
    DB    9
    DB    9
UNK_93F2:
	DB  0BH   
    DB    7
    DB    8
    DB    8
UNK_93F6:
	DB  0BH   
    DB    9
    DB    7
    DB    7
UNK_93FA:
	DB  0CH   
    DB  0AH
    DB    6
    DB    6
UNK_93FE:
	DB  0CH   
    DB  0CH
    DB    5
    DB    5
UNK_9402:
	DB  27H
    DB    0
    DB 0CCH
    DB  19H
    DB  11H
    DB    7
    DB  4EH
    DB    0
    DB 0E0H
    DB  16H
    DB    5
    DB    2
    DB  89H
    DB    0
    DB 0BCH
    DB  38H
    DB    7
    DB    2
    DB 0C3H
    DB    0
    DB 0E2H
    DB  0CH
    DB  0AH
    DB    5
    DB 0EAH
    DB    0
    DB 0AAH
    DB  3AH
    DB  11H
    DB    7
    DB  38H
    DB    1
    DB 0AAH
    DB  54H
    DB    0
    DB    0
    DB 0FFH
    DB 0FFH
    DB    0
    DB 0FFH
    DB    0
    DB    0

UNK_942C:
	DB  27H
    DB    0
    DB 0C1H
    DB  1EH
    DB  0AH
    DB  14H
    DB  4EH
    DB    0
    DB 0D1H
    DB  23H
    DB    2
    DB    7
    DB  89H
    DB    0
    DB 0C1H
    DB  2DH
    DB    5
    DB  0AH
    DB 0C3H
    DB    0
    DB 0D8H
    DB  14H
    DB    5
    DB  0CH
    DB 0EAH
    DB    0
    DB 0AAH
    DB  3FH
    DB    7
    DB  0CH
    DB  38H
    DB    1
    DB 0AAH
    DB  54H
    DB    0
    DB    0
    DB 0FFH
    DB 0FFH
    DB    0
    DB 0FFH
    DB    0
    DB    0

UNK_9456:
	DB  27H
    DB    0
    DB  9EH
    DB  4CH
    DB    5
    DB  0FH
    DB  4EH
    DB    0
    DB 0BCH
    DB  35H
    DB    2
    DB  0AH
    DB  89H
    DB    0
    DB 0A5H
    DB  47H
    DB    2
    DB  0FH
    DB 0C3H
    DB    0
    DB 0C4H
    DB  2DH
    DB    2
    DB  0AH
    DB 0EAH
    DB    0
    DB  89H
    DB  5EH
    DB    5
    DB  11H
    DB  38H
    DB    1
    DB  89H
    DB  75H
    DB    0
    DB    0
    DB 0FFH
    DB 0FFH
    DB    0
    DB 0FFH
    DB    0
    DB    0

SUB_9480:
    LD      HL, ($7271)
    DEC     HL
    LD      ($7271), HL
    LD      A, L
    OR      H
	RET     NZ
    LD      A, ($727C)
    CP      8
    JR      NZ, LOC_94A1
    LD      A, 0FFH
    LD      ($727C), A
    LD      HL, $7152
    LD      B, 3

LOC_949B:
    LD      (HL), 0C2H
    INC     HL
    INC     HL
    DJNZ    LOC_949B

LOC_94A1:
    LD      HL, 0AH
    LD      ($7271), HL
    LD      HL, $7131
    EXX
    LD      DE, $713F
    EXX
    LD      A, ($7274)
    LD      ($7273), A
    CALL    SUB_951C
    LD      ($7274), A
    LD      B, 8

LOOP_94BD:       
    PUSH    BC
    LD      (HL), A
    INC     HL
    PUSH    AF
    EXX
    LD      A, (DE)
    CP      0FFH
    JR      NZ, LOC_94CC
    INC     DE
    INC     DE
    POP     AF
    JR      LOC_94DA

LOC_94CC:
    POP     AF
    LD      HL, UNK_952B
    LD      C, A
    LD      B, 0
    ADD     HL, BC
    ADD     HL, BC
    LD      BC, 2
    LDIR

LOC_94DA:
    EXX
    LD      B, 3

LOOP_94DD:       
    CALL    SUB_951C
    DJNZ    LOOP_94DD
    POP     BC
    DJNZ    LOOP_94BD
    LD      A, ($7276)
    DEC     A
    LD      ($7276), A
    JR      NZ, PUT_OBJECT_09
    LD      A, 3
    LD      ($7276), A
    LD      A, ($7275)
    INC     A
    CP      4
    JR      NZ, INIT_COLOR_TABLE
    XOR     A

INIT_COLOR_TABLE:
    LD      ($7275), A
    LD      IX, UNK_9523
    LD      C, A
    LD      B, 0
    ADD     IX, BC
    ADD     IX, BC
    LD      L, (IX+0)
    LD      H, (IX+1)
    LD      A, 4
    CALL    INIT_TABLE

PUT_OBJECT_09:   
    LD      IX, PIPES_PARTS
    JP      PUTOBJ

SUB_951C:
    INC     A
    CP      19H
	RET     NZ
    LD      A, 1
RET

UNK_9523:
	DB    0   
    DB  23H
    DB  40H
    DB  23H
    DB  80H
    DB  23H
    DB 0C0H
    DB  23H

UNK_952B:
	DB    0   
    DB    0
    DB  28H
    DB    0
    DB  28H
    DB    0
    DB  28H
    DB    8
    DB  28H
    DB  10H
    DB  28H
    DB  10H
    DB  28H
    DB  18H
    DB  28H
    DB  18H
    DB  28H
    DB  18H
    DB  20H
    DB  18H
    DB  18H
    DB  18H
    DB  18H
    DB  18H
    DB  10H
    DB  18H
    DB    8
    DB  18H
    DB    0
    DB  18H
    DB    0
    DB  10H
    DB    0
    DB  10H
    DB    0
    DB    8
    DB    0
    DB    0
    DB    8
    DB    0
    DB  10H
    DB    0
    DB  18H
    DB    0
    DB  18H
    DB    0
    DB  18H
    DB    0
    DB  20H
    DB    0

SUB_955D:
    CALL    SUB_9659
    LD      A, ($7091)
    BIT     7, A
    JR      NZ, LOC_9581
    LD      A, ($7279)
    OR      A
	RET     Z
    LD      A, ($727E)
    OR      A
    JR      Z, LOC_9576
    DEC     A
    LD      ($727E), A

LOC_9576:
    XOR     A
    LD      ($7279), A
    INC     A
    LD      ($7278), A
    JP      PLAY_GUN_FIRE_SOUND_AND_OBJECT_05

LOC_9581:
    BIT     5, A
    JR      Z, LOC_95AD
    LD      A, ($7277)
    DEC     A
    LD      ($7277), A
	RET     NZ
    LD      A, 3
    LD      ($7277), A
    LD      A, ($708B)
    CP      3
    JR      NZ, LOC_959F
    CALL    PUT_OBJECT_10_A
    JP      PUT_OBJECT_10

LOC_959F:
    LD      HL, $708B
    INC     (HL)
    INC     HL

LOC_95A4:
    INC     HL
    INC     HL
    LD      A, 0FEH
    ADD     A, (HL)
    LD      (HL), A
    JP      PUT_OBJECT_10

LOC_95AD:
    BIT     6, A
    JR      Z, LOC_95E4
    BIT     4, A
    JR      Z, LOC_95CA
    BIT     3, A
    JR      Z, LOC_95C2
    LD      A, ($7282)
    SLA     A
    SLA     A
    JR      LOC_95C5

LOC_95C2:
    LD      A, ($7282)

LOC_95C5:
    LD      ($7267), A
    JR      LOC_95CF

LOC_95CA:
    LD      A, 80H
    LD      ($727F), A

LOC_95CF:
    LD      A, 0A0H
    LD      ($7091), A
    LD      HL, $708B
    LD      A, 1
    LD      (HL), A
    LD      ($7277), A
    INC     HL
    LD      A, 0FEH
    ADD     A, (HL)
    LD      (HL), A
    JR      LOC_95A4

LOC_95E4:
    LD      A, ($7277)
    DEC     A
    LD      ($7277), A
	RET     NZ
    LD      A, 1
    LD      ($7277), A
    LD      A, ($708E)
    CP      2AH ; '*'
    CALL    C, SOUND_AND_MORE
    LD      A, ($708E)
    ADD     A, 0FDH
    LD      ($708E), A
    CALL    SUB_9686
    CP      1
    JR      NZ, PUT_OBJECT_10
    LD      A, 80H
    LD      ($727F), A
    CALL    PUT_OBJECT_10_A

PUT_OBJECT_10:   
    LD      IX, BULLET
    JP      PUTOBJ

PUT_OBJECT_10_A: 
    XOR     A
    LD      ($7091), A
    LD      HL, UNK_96FC
    LD      DE, $708C
    LD      BC, 4
    LDIR
    CALL    PUT_OBJECT_10
RET

PLAY_GUN_FIRE_SOUND_AND_OBJECT_05:     
    LD      HL, $727A
    INC     (HL)
    LD      B, 8
    CALL    PLAY_IT         ; GUN FIRE
    LD      A, 0FFH
    LD      ($7033), A
    LD      HL, $70BD
    LD      A, (HL)
    LD      HL, $708B
    LD      (HL), 0
    INC     HL
    LD      (HL), A
    INC     HL
    LD      (HL), 0
    INC     HL
    LD      (HL), 0A7H
    INC     HL
    LD      (HL), 0
    LD      A, 80H
    LD      ($7091), A
    LD      A, 1
    LD      ($7277), A
    JP      PUT_OBJECT_10

SUB_9659:
    LD      A, ($7278)
    OR      A
    JR      NZ, LOC_9666
    CALL    SUB_966F
    LD      ($7279), A
RET

LOC_9666:
    CALL    SUB_966F
    OR      A
	RET     NZ
    LD      ($7278), A
RET

SUB_966F:
    LD      HL, (WORD_8008)
    LD      BC, 2
    LD      A, ($7161)
    OR      A
    JR      Z, LOC_967E
    LD      BC, 7

LOC_967E:
    ADD     HL, BC
    LD      B, (HL)
    INC     HL
    INC     HL
    INC     HL
    LD      A, (HL)
    OR      B
RET

SUB_9686:
    LD      B, A
    LD      A, ($715D)
    CP      8
    JR      NZ, LOC_9695
    LD      A, B
    CP      1AH
    JR      C, LOC_96F2
    JR      LOC_96E6

LOC_9695:
    LD      A, B
    CP      0C2H
    JR      NC, LOC_96F2
    CP      40H
    JR      NC, LOC_96E6
    LD      A, ($708C)
    LD      C, A
    CP      0A8H
    JR      NC, LOC_96C2
    CP      68H
    JR      C, LOC_96B0
    CP      94H
    JR      C, LOC_96C9
    JR      LOC_96E6

LOC_96B0:
    CP      56H
    JR      NC, LOC_96E6
    LD      A, ($7344)
    OR      A
    JR      Z, LOC_96C2
    DEC     A
    JR      Z, LEFT_SIDE_BONUS_CHECK
    DEC     A
    JR      Z, LOC_96DC
    JR      LOC_96E6

LOC_96C2:
    LD      A, B
    CP      36H
    JR      C, LOC_96F2
    JR      LOC_96E6

LOC_96C9:
    LD      A, B
    CP      39H
    JR      C, LOC_96F2
    JR      LOC_96E6

LEFT_SIDE_BONUS_CHECK:    
    LD      A, C
    CP      44H
    JR      NC, LOC_96F5
    LD      A, B
    CP      32H
    JR      C, LEFT_SIDE_BONUS_HIT
    JR      LOC_96E6

LOC_96DC:
    LD      A, C
    CP      53H
    JR      NC, LOC_96F5
    LD      A, B
    CP      32H
    JR      C, LEFT_SIDE_BONUS_HIT

LOC_96E6:
    XOR     A
RET

LEFT_SIDE_BONUS_HIT: 
    LD      B, 7
    CALL    PLAY_IT         ; LEFT SIDE BONUS (+/- SCORE OR BULLETS)
    LD      A, 5
    LD      ($7353), A

LOC_96F2:
    LD      A, 1
RET

LOC_96F5:
    LD      A, B
    CP      16H
    JR      C, LOC_96F2
    JR      LOC_96E6

UNK_96FC:
	DB  80H   
    DB    0
    DB 0C1H
    DB    0

SOUND_AND_MORE:  
    LD      A, ($708E)
    CP      2AH
	RET     NC
    LD      B, A
    LD      A, ($708C)
    LD      C, A
    LD      HL, $7131
    XOR     A
    LD      ($727B), A

LOC_9712:
    LD      A, (HL)
    EXX
    LD      HL, UNK_97AF
    LD      C, A
    LD      B, 0
    ADD     HL, BC
    ADD     HL, BC
    ADD     HL, BC
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    INC     HL
    LD      E, (HL)
    CALL    SUB_9791
    LD      A, D
    CP      1
    JR      NZ, LOC_9783
    LD      A, ($727B)
    LD      C, A
    LD      B, 0
    LD      HL, $713F
    ADD     HL, BC
    ADD     HL, BC
    LD      A, (HL)
    CP      0FFH
    JR      Z, LOC_9783
    LD      (HL), 0FFH
    LD      A, ($727D)
    CP      3
    JR      NC, HIT_PIPE
    ADD     A, 4
    JR      HIT_PIPE_A

HIT_PIPE:
    SUB     4

HIT_PIPE_A:      
    LD      C, A
    LD      A, ($727B)
    CP      C
    JR      NZ, HIT_PIPE_B
    LD      A, ($727E)
    DEC     A
    JR      NZ, HIT_PIPE_B
    LD      A, 0D8H
    LD      ($7091), A
    JR      HIT_PIPE_C

HIT_PIPE_B:      
    LD      A, 0D0H
    LD      ($7091), A

HIT_PIPE_C:      
    LD      A, 2
    LD      ($727E), A
    LD      A, ($727B)
    LD      ($727D), A
    LD      A, ($727C)
    INC     A
    LD      ($727C), A
    LD      HL, $7266
    DEC     (HL)
    LD      B, 9
    CALL    PLAY_IT
    LD      B, 0AH
    CALL    PLAY_IT
RET

LOC_9783:
    EXX
    INC     HL
    LD      A, ($727B)
    INC     A
    LD      ($727B), A
    CP      8
    JR      NZ, LOC_9712
RET

SUB_9791:
    LD      D, 0
    EXX
    PUSH    BC
    EXX
    POP     HL
    LD      A, L
    CP      C
    JR      NC, LOC_979C
RET

LOC_979C:
    LD      A, C
    ADD     A, E
    CP      L
    JR      NC, LOC_97A2
RET

LOC_97A2:
    LD      A, H
    CP      B
	RET     C
    LD      A, B
    ADD     A, E
    CP      H
    JR      NC, LOC_97AB
RET

LOC_97AB:
    LD      D, 1
RET
	RET

UNK_97AF:
	DB    0   
    DB    0
    DB    0
    DB  95H
    DB    2
    DB    2
    DB  92H
    DB    4
    DB    6
    DB  93H
    DB  0AH
    DB    6
    DB  92H
    DB  10H
    DB    7
    DB  94H
    DB  15H
    DB    6
    DB  90H
    DB  1CH
    DB    7
    DB  93H
    DB  23H
    DB    3
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB  66H
    DB  24H
    DB    3
    DB  65H
    DB  1DH
    DB    5
    DB  63H
    DB  17H
    DB    6
    DB  62H
    DB  11H
    DB    7
    DB  63H
    DB  0BH
    DB    7
    DB  64H
    DB    4
    DB    8
    DB  66H
    DB    2
    DB    4
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0

SUB_97FA:
    LD      A, ($727F)
    BIT     7, A
	RET     Z
    XOR     A
    LD      ($727F), A
    LD      A, ($7282)
    CP      6
	RET     C
    DEC     A
    LD      ($7282), A
    LD      A, ($7280)
    CALL    SUB_982E
    LD      ($713B), A
    INC     HL
    LD      A, (HL)
    LD      ($7280), A
    CP      2
	RET     NZ
    LD      A, ($7281)
    CALL    SUB_982E
    LD      ($713A), A
    INC     HL
    LD      A, (HL)
    LD      ($7281), A
RET

SUB_982E:
    LD      C, A
    LD      B, 0
    LD      HL, UNK_9838
    ADD     HL, BC
    ADD     HL, BC
    LD      A, (HL)
RET

UNK_9838:
	DB    0   
    DB    1
    DB    9
    DB    2
    DB    8
    DB    3
    DB    7
    DB    4
    DB    6
    DB    5
    DB    5
    DB    6
    DB    4
    DB    7
    DB    3
    DB    8
    DB    2
    DB    9
    DB    1
    DB    0

PUT_OBJECT_16:   
    LD      IX, $708B
    LD      A, 0
    CP      (IX+0)
    JR      NZ, LOCRET_98A2
    LD      A, (IX+1)
    ADD     A, 2
    LD      IY, $7157
    LD      B, (IY+1)
    SUB     B
    JR      C, LOCRET_98A2
    CP      8
    JR      NC, LOCRET_98A2
    LD      A, (IX+3)
    SUB     6
    LD      B, (IY+3)
    SUB     B
    JR      NC, LOCRET_98A2
    LD      HL, $7091
    SET     6, (HL)
    LD      HL, $7157
    LD      A, 1
    XOR     (HL)
    LD      (HL), A
    PUSH    AF
    LD      IX, MUSIC_NOTE_SPRITE
    CALL    PUTOBJ
    POP     AF
    JR      NZ, LOC_9891
    CALL    PLAY_MUSICAL_SCORE
    JR      LOCRET_98A2
	LOC_9891:
    LD      A, 0FFH
    LD      ($72AC), A
    LD      ($72C0), A
    LD      ($72CA), A
    LD      ($72D4), A
    LD      ($72DE), A

LOCRET_98A2:     
RET

SUB_98A3:
    XOR     A
    LD      ($72A4), A
    LD      IX, $7283
LOC_98AB:
    PUSH    IX
    BIT     7, (IX+0)
    JR      NZ, DUCK_STARTS_FLIGHT
    LD      A, ($72A8)
    CP      1
    JP      Z, LOC_9A43
    LD      A, ($72A3)
    LD      B, A
    LD      A, ($7055)
    CP      B
    JP      Z, LOC_9A43
    PUSH    IX
    CALL    READ_SOME_VRAM_A
    POP     IX
    CP      0C8H
    JP      NZ, LOC_9A43
    LD      A, R
    LD      C, A
    CP      7
    JP      C, LOC_9A43
    LD      (IX+0), 0C0H
    LD      (IX+1), 30H
    LD      A, C
    AND     7
    CP      7
    JR      NZ, LOC_98EB
    LD      A, 6
LOC_98EB:
    LD      B, A
    OR      A
    LD      A, 30H
    JR      NZ, LOOP_98F5
    ADD     A, 10H
    JR      LOC_98F9
LOOP_98F5:       
    ADD     A, 10H
    DJNZ    LOOP_98F5
LOC_98F9:
    LD      (IX+2), A
    LD      A, 1
    LD      ($72A8), A
    JP      LOC_9A43
DUCK_STARTS_FLIGHT:  
    BIT     6, (IX+0)
    JR      Z, TEST_SIGNAL_PLAY_BULLET_DING_SOUND_02
    LD      A, ($7055)
    LD      B, A
    LD      A, ($72A3)
    CP      B
    JP      Z, LOC_9A43
    LD      A, 10H
    ADD     A, (IX+1)
    LD      (IX+1), A
    CP      (IX+2)
    JP      NZ, LOC_9A43
    PUSH    IX
    CALL    SUB_9B5F
    POP     IX
    CP      0C8H
    JR      Z, PUT_OBJECT_AND_DUCK_SOUND
    XOR     A
    LD      (IX+0), A
    JP      LOC_9A43
PUT_OBJECT_AND_DUCK_SOUND:
    LD      A, 0A0H
    LD      (IX+0), A
    PUSH    IX
    XOR     A
    LD      ($73C6), A
    CALL    SOMETHING_ABOUT_TARGETS
    LD      A, 1
    LD      ($73C6), A
    POP     IX
    LD      HL, MULTIPLIER_HUD
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    LD      A, R
DO_THE_DUCK_SOUND:   
    CP      D
    JR      C, DO_THE_DUCK_SOUND_A
    SRL     A
    JR      DO_THE_DUCK_SOUND
DO_THE_DUCK_SOUND_A: 
    CP      E
    JR      NC, DO_THE_DUCK_SOUND_B
    LD      A, E
DO_THE_DUCK_SOUND_B: 
    LD      (IX+2), A
    CALL    PLAY_THE_DUCK_SOUND
    CALL    SUB_9C2F
    JP      LOC_9A36
TEST_SIGNAL_PLAY_BULLET_DING_SOUND_02: 
    BIT     5, (IX+0)
    JP      Z, LOC_9A43
    LD      A, (IX+5)
    CALL    TEST_SIGNAL
    CP      1
    JP      NZ, TEST_SIGNAL_14
    SET     6, (IX+0)
    LD      A, ($7091)
    CP      80H
    JR      NZ, LOC_99B3
    CALL    SUB_9A61
    LD      A, B
    CP      1
    JR      NZ, LOC_99B6
    LD      A, 0C0H
    LD      ($7091), A
    LD      (IX+0), 0
    PUSH    IX
    PUSH    IY
    LD      B, 4            ; BULLET HIT DING (GENERAL HIT)
    CALL    PLAY_IT
    LD      B, 5
    CALL    PLAY_IT
    LD      B, 6
    CALL    PLAY_IT
    POP     IY
    POP     IX
    CALL    SUB_9B23
    JR      LOC_99C4
LOC_99B3:
    CALL    SUB_9C00
LOC_99B6:
    LD      A, (IY+3)
    CP      90H
    JR      C, LOC_99D6
    PUSH    IX
    CALL    SUB_9A86
    POP     IX
LOC_99C4:
    LD      (IY+3), 0C1H
    LD      (IX+0), 0
    LD      HL, $7266
    DEC     (HL)
    SET     6, (IX+0)
    JR      LOC_9A36
LOC_99D6:
    LD      A, (IX+1)
    OR      A
    JR      Z, LOC_99E2
    BIT     7, A
    JR      NZ, LOC_99E2
    JR      LOC_9A13

LOC_99E2:
    LD      (IX+4), 1
    CALL    SUB_9C2F
    BIT     3, (IX+0)
    JR      Z, LOC_9A01
    RES     3, (IX+0)
    LD      (IY+0), 9
    LD      (IX+7), 0EH
    LD      (IX+3), 3
    JR      LOC_9A36

LOC_9A01:
    LD      (IY+0), 0CH
    LD      (IX+7), 9
    SET     3, (IX+0)
    LD      (IX+3), 0FDH
    JR      LOC_9A36

LOC_9A13:
    CALL    SUB_9C47
    LD      A, B
    CP      1
    JR      Z, LOC_9A1F
    LD      (IX+4), 0

LOC_9A1F:
    CALL    SUB_9B9B

TEST_SIGNAL_14:  
    LD      A, (IX+6)
    CALL    TEST_SIGNAL
    CP      1
    JR      NZ, LOC_9A36
    CALL    SUB_9C00
    CALL    SUB_9BBC
    SET     6, (IX+0)

LOC_9A36:
    BIT     6, (IX+0)
    JR      Z, LOC_9A43
    RES     6, (IX+0)
    CALL    PUT_OBJECT_14

LOC_9A43:
    POP     IX
    LD      BC, 8
    ADD     IX, BC
    LD      A, ($72A4)
    INC     A
    LD      ($72A4), A
    CP      4
    JP      NZ, LOC_98AB
    LD      A, ($7055)
    LD      ($72A3), A
    XOR     A
    LD      ($72A8), A
RET

SUB_9A61:
    CALL    SUB_9C00
    LD      B, 0
    LD      A, ($708C)
    LD      C, A
    LD      A, (IY+1)
    ADD     A, 0FEH
    CP      C
	RET     NC
    ADD     A, 10H
    CP      C
	RET     C
    LD      A, ($708E)
    LD      C, A
    LD      A, (IY+3)
    SUB     4
    CP      C
	RET     NC
    ADD     A, 14H
    CP      C
	RET     C
    INC     B
RET

SUB_9A86:
    LD      A, 1
    LD      ($72A9), A
    LD      (IX+0), 0
    LD      A, 78H
    LD      ($72A5), A
    LD      A, ($7034)
    OR      1
    LD      ($7034), A
    LD      A, ($7161)
    OR      A
    JR      NZ, LOC_9AA7
    LD      A, ($7269)
    JR      LOC_9AAA

LOC_9AA7:
    LD      A, ($726D)

LOC_9AAA:
    SLA     A
    SLA     A
    LD      (IY+1), A
    LD      (IY+0), 0DH
    LD      (IY+3), 0B8H
    PUSH    IY
    CALL    PUT_OBJECT_14
    CALL    MAJOR_SET_OF_ROUTINES
    POP     IY
    LD      A, 6
    LD      ($72A7), A

LOC_9AC8:
    LD      A, ($72A7)
    DEC     A
    LD      ($72A7), A
    JR      NZ, LOC_9B02
    LD      A, 6
    LD      ($72A7), A
    LD      A, (IY+0)
    CP      0DH
    JR      NZ, LOC_9AF7
    INC     A
    LD      (IY+0), A
    LD      A, (IY+1)
    ADD     A, 0FDH
    LD      (IY+1), A
    PUSH    IY
    LD      A, 0FFH
    LD      ($7033), A
    CALL    SUB_8507
    POP     IY
    JR      LOC_9AFB

LOC_9AF7:
    LD      (IY+0), 0DH

LOC_9AFB:
    PUSH    IY
    CALL    PUT_OBJECT_14
    POP     IY

LOC_9B02:
    PUSH    IY
    CALL    MAJOR_SET_OF_ROUTINES
    POP     IY
    LD      A, ($7161)
    OR      A
    JR      NZ, LOC_9B14
    LD      A, ($7269)
    JR      LOC_9B17

LOC_9B14:
    LD      A, ($726D)

LOC_9B17:
    OR      A
    JR      Z, SUB_9B23
    LD      A, ($72A5)
    DEC     A
    LD      ($72A5), A
    JR      NZ, LOC_9AC8

SUB_9B23:
    LD      HL, $7283
    LD      DE, 8
    LD      BC, 400H

LOOP_9B2C:       
    LD      A, (HL)
    AND     20H
    JR      Z, LOC_9B33
    LD      C, 1

LOC_9B33:
    ADD     HL, DE
    DJNZ    LOOP_9B2C
    LD      A, C
    CP      1
    JR      Z, LOC_9B43
    LD      A, 0FFH
    LD      ($72E8), A
    LD      ($72F2), A

LOC_9B43:
    LD      A, ($7034)
    AND     80H
    LD      ($7034), A
    XOR     A
    LD      ($72A9), A
RET

    LD      B, 8
LOC_9B52:
    LD      HL, 76CH
    LD      DE, 1

LOC_9B58:
    SBC     HL, DE
    JR      NZ, LOC_9B58
    DJNZ    LOC_9B52
RET

SUB_9B5F:
    LD      A, (IX+1)
    SRL     A
    SRL     A
    SRL     A
    LD      C, A
    LD      B, 0
    LD      HL, 21C0H
    ADD     HL, BC
    EX      DE, HL
    LD      HL, $72A6
    JP      READ_SOME_VRAM_B

READ_SOME_VRAM_A:
    LD      HL, $72A6
    LD      DE, 21C6H
READ_SOME_VRAM_B:
    LD      BC, 1
    CALL    READ_VRAM
    LD      A, ($72A6)
RET

SOMETHING_ABOUT_TARGETS:  
    LD      B, (IX+1)
    LD      IX, TARGETS
    LD      HL, $7085
    XOR     A
    LD      (HL), A
    INC     HL
    LD      (HL), B
    INC     HL
    INC     HL
    LD      (HL), 70H
    JP      PUTOBJ

SUB_9B9B:
    LD      A, (IX+3)
    LD      C, A
    ADD     A, (IY+1)
    LD      (IY+1), A
    LD      A, C
    BIT     7, A
    JR      NZ, LOC_9BAC
    NEG

LOC_9BAC:
    ADD     A, (IX+1)
    LD      (IX+1), A
    LD      A, (IX+4)
    ADD     A, (IY+3)
    LD      (IY+3), A
RET

SUB_9BBC:
    LD      C, (IX+7)
    LD      B, 0
    LD      HL, UNK_9CA2
    ADD     HL, BC
    ADD     HL, BC
    LD      A, (HL)
    LD      (IY+0), A
    INC     HL
    LD      A, (HL)
    LD      (IX+7), A
RET

PLAY_THE_DUCK_SOUND: 
    PUSH    IX
    LD      B, 2
    CALL    PLAY_IT
    LD      B, 3
    CALL    PLAY_IT
    POP     IX
    CALL    SUB_9C00
    LD      (IY+0), 9
    LD      (IX+7), 0EH
    LD      (IY+3), 78H
    LD      A, (IX+1)
    LD      (IY+1), A
    SET     6, (IX+0)
    LD      (IX+3), 3
    LD      (IX+4), 1
RET

SUB_9C00:
    LD      IY, $70A4
    LD      A, ($72A4)
    SLA     A
    LD      C, A
    LD      B, 0
    ADD     IY, BC
    ADD     IY, BC
    ADD     IY, BC
RET

PUT_OBJECT_14:   
    PUSH    IX
    LD      IX, DUCK_SPRITE
    LD      A, ($72A4)
    LD      C, A
    LD      B, 0
    ADD     IX, BC
    ADD     IX, BC
    ADD     IX, BC
    ADD     IX, BC
    ADD     IX, BC
    CALL    PUTOBJ
    POP     IX
RET

SUB_9C2F:
    LD      A, ($72AB)
    LD      B, A
    LD      C, (IX+2)
    LD      A, R

LOC_9C38:
    CP      C
    JR      C, LOC_9C3F
    SRL     A
    JR      LOC_9C38

LOC_9C3F:
    CP      B
    JR      NC, LOC_9C43
    LD      A, B

LOC_9C43:
    LD      (IX+1), A
RET

SUB_9C47:
    LD      B, 0
    LD      A, (IY+0)
    CP      8
	RET     C
    CP      0DH
	RET     NC
    INC     B
RET

SUB_9C54:
    LD      HL, MULTIPLIER_HUD
    LD      A, ($7160)
    LD      C, A
    LD      B, 0
    ADD     HL, BC
    ADD     HL, BC
    LD      A, (HL)
    LD      ($72AB), A
    INC     HL
    LD      A, (HL)
    LD      ($72AA), A
    LD      HL, $7283
    LD      (HL), 0
    LD      DE, $7284
    LD      BC, 25H
    LDIR
    LD      B, 4
    LD      HL, $7288

LOOP_9C7A_REQUEST_SIGNAL: 
    PUSH    BC
    PUSH    HL
    LD      HL, 6
    LD      A, 1
    CALL    REQUEST_SIGNAL
    POP     HL
    LD      (HL), A
    INC     HL
    PUSH    HL
    LD      A, 1
    LD      HL, 6
    CALL    REQUEST_SIGNAL
    POP     HL
    LD      (HL), A
    LD      BC, 7
    ADD     HL, BC
    POP     BC
    DJNZ    LOOP_9C7A_REQUEST_SIGNAL
RET

MULTIPLIER_HUD:
	DB  18H   
    DB  38H
    DB  14H                ; HUD TO DISPLAY BEAR = 50 AND BULLETS LEFT BONUS
    DB  30H
    DB  10H
    DB  30H
    DB  10H
    DB  24H

UNK_9CA2:
	DB    0   
    DB    1
    DB    1
    DB    2
    DB    2
    DB    3
    DB    1
    DB    4
    DB    0
    DB    5
    DB    1
    DB    6
    DB    3
    DB    7
    DB    1
    DB    0
    DB  0CH
    DB    9
    DB  0BH
    DB  0AH
    DB  0AH
    DB  0BH
    DB  0AH
    DB  0CH
    DB    9
    DB    0
    DB    9
    DB  0EH
    DB    8
    DB  0FH
    DB  0AH
    DB  10H
    DB  0AH
    DB  11H
    DB  0BH
    DB  12H
    DB    4
    DB  13H
    DB    5
    DB  14H
    DB    6
    DB  15H
    DB    5
    DB  16H
    DB    4
    DB  17H
    DB    5
    DB  18H
    DB    7
    DB  19H
    DB    5
    DB  12H

BULLET_COUNT:
	DW BULLET_COUNT_OBJ    
    DW UNK_9CF7
    DB    0
    DB  80H

BULLET_COUNT_OBJ:
	DB    0  
    DB    0
    DB    0
    DB    0
    DB    0
    DW BULLET_COUNT_FRAME

BULLET_COUNT_FRAME:
	DB 006,003          
    DB 016,017,017,017,017,018
    DB 019,034,024,032,033,020
    DB 021,022,022,022,022,023

UNK_9CF7:
	DB    0   
    DB  68H
    DB    0
    DB 0A0H
    DB    0
    DB    0

BEAR_EQUALS_50:
	DW BEAR_EQUALS_OBJ     
    DW UNK_9D1E
    DB    0
    DB  80H

BEAR_EQUALS_OBJ:
	DB    0   
    DB    0
    DB    0
    DB    0
    DB    0
    DW BEAR_EQUALS_FRAME

BEAR_EQUALS_FRAME:
	DB 006,003           
    DB 016,017,017,017,017,018
    DB 019,035,024,032,033,020
    DB 021,022,022,022,022,023
UNK_9D1E:
	DB    0   
    DB  68H
    DB    0
    DB    0
    DB    0
    DB    0

MISC_PATTERNS:
	DB 000,000,000,000,000,007,007,006
    DB 000,000,000,000,000,255,255,000
    DB 000,000,000,000,000,224,224,096
    DB 006,006,006,006,006,006,006,006
    DB 096,096,096,096,096,096,096,096
    DB 006,007,007,000,000,000,000,000
    DB 000,255,255,000,000,000,000,000
    DB 096,224,224,000,000,000,000,000
    DB 000,000,124,000,000,124,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 127,096,126,063,003,003,126,000
    DB 028,054,099,099,099,054,028,000
    DB 000,000,016,016,056,056,000,000
    DB 102,231,255,090,126,102,060,024

UNK_9DC4:
	DB 0A0H   
    DB 0A0H
    DB  70H

SUB_9DC7:
    LD      HL, $715D
    LD      A, (HL)
    INC     HL
    LD      (HL), A
    DEC     HL
    LD      (HL), B
RET

WRITING_A_REGISTER:  
    LD      A, ($73C4)
    XOR     40H
    LD      C, A
    LD      B, 1
    CALL    WRITE_REGISTER
RET

NMI:     
    PUSH    AF
    PUSH    HL
    PUSH    DE
    PUSH    BC
    PUSH    IX
    PUSH    IY
    EX      AF, AF'
    PUSH    AF
    EXX
    PUSH    HL
    PUSH    DE
    PUSH    BC
    LD      A, ($7233)
    BIT     0, A
    JR      Z, COMPLETE_NMI_A
    SET     7, A
    LD      ($7233), A
    JR      COMPLETE_NMI_B

COMPLETE_NMI_A:  
    CALL    WRITER
    CALL    TIME_MGR
    CALL    READ_REGISTER
    LD      ($7234), A

COMPLETE_NMI_B:  
    POP     BC
    POP     DE
    POP     HL
    EXX
    POP     AF
    EX      AF, AF'
    POP     IY
    POP     IX
    POP     BC
    POP     DE
    POP     HL
    POP     AF
RETN

WRITE_SOME_VRAM: 
    LD      A, C
    OR      A
    JR      Z, LOC_9E2A
    PUSH    BC
    LD      B, 0
    PUSH    HL
    PUSH    DE
    PUSH    BC
    CALL    WRITE_VRAM
    POP     BC
    POP     HL
    ADD     HL, BC
    EX      DE, HL
    POP     HL
    ADD     HL, BC
    POP     BC
    LD      C, 0

LOC_9E2A:
    LD      A, B
    OR      A
    JR      Z, LOCRET_9E31
    CALL    WRITE_VRAM

LOCRET_9E31:     
RET

SOUND_TABLE:
    DW MAIN_TUNE_MUSIC     
    DW $72AC
    DW DUCK_SOUND_A
    DW $72E8
    DW DUCK_SOUND_B
    DW $72F2
    DW BULLET_HIT_DING_A
    DW $7306
    DW BULLET_HIT_DING_B
    DW $7310
    DW BULLET_HIT_DING_C
    DW $731A
    DW LEFT_SIDE_BONUS_HIT_SOUND
    DW $72FC
    DW GUN_FIRE_SOUND
    DW $7324
    DW PIPE_HIT_SOUND_A
    DW $7310
    DW PIPE_HIT_SOUND_B
    DW $731A
    DW BULLET_BONUS_SOUND_A
    DW $72E8
    DW BULLET_BONUS_SOUND_B
    DW $72F2
    DW BEAR_HIT_SOUND_A
    DW $7306
    DW BEAR_HIT_SOUND_B
    DW $7310
    DW BEAR_HIT_SOUND_C
    DW $731A
    DW LETTER_BONUS_SOUND
    DW $72FC
    DW TUNE_SILENCE_A
    DW $72C0
    DW REPEAT_HIGH_TUNE
    DW $72CA
    DW TUNE_SILENCE_B
    DW $72D4
    DW REPEAT_LOW_TUNE
    DW $72DE
    DW SOUND_15
    DW $72CA
    DW SOUND_16
    DW $72CA
    DW SOUND_17
    DW $72DE
    DW SOUND_18
    DW $72DE
    DW SOUND_19
    DW $72DE
    DW SOUND_20
    DW $72DE
    DW SOUND_21
    DW $72DE
DUCK_SOUND_A:
	DB 002,035,004,000,000,038,024,016
DUCK_SOUND_B:
	DB 193,119,160,004,017,240,038,024
MAIN_TUNE_MUSIC:
	DB 066,254,128,054,021,175,064,013,129,018,064,254,128,018,064,215,128,018,066,160,128,072,022,175,064,170,128,018,064,160,128,018
    DB 064,143,128,018,064,160,128,018,064,170,128,018,064,160,128,018,064,254,128,018,064,215,128,018,066,170,128,090,022,191,114,066
    DB 240,128,054,021,175,064,254,128,018,064,240,128,018,064,215,128,018,066,170,128,072,022,175,064,180,128,018,064,170,128,018,064
    DB 160,128,018,064,170,128,018,064,180,128,018,064,170,128,018,064,240,128,018,064,170,128,018,066,254,128,090,022,191,114,066,254
    DB 128,054,021,175,064,013,129,018,064,254,128,018,064,215,128,018,066,160,128,072,022,175,064,170,128,018,064,160,128,018,064,143
    DB 128,018,064,160,128,018,064,170,128,018,064,160,128,018,064,254,128,018,064,215,128,018,066,190,128,090,022,255,114,066,190,128
    DB 054,021,175,064,029,129,018,064,240,128,018,064,190,128,018,066,214,128,072,022,175,064,240,128,018,064,254,128,018,064,029,129
    DB 018,064,064,129,018,064,083,129,018,064,125,129,018,064,083,129,018,064,029,129,018,066,064,129,108,023,143,088
TUNE_SILENCE_A:
	DB 196,218,162,018,022,021,012,018,004,022,001,255,016
REPEAT_HIGH_TUNE:
	DB 242,194,172,161,018,020,058,194,172,161,018,020,058,024
TUNE_SILENCE_B:
	DB 132,218,162,020,003,023,004,020,004,024,001,025,001,024,001,026,001,020,001,023,001,027,001,255,016
REPEAT_LOW_TUNE:
	DB 130,129,146,018,020,058,130,252,161,018,020,058,130,252,161,018,020,058,130,087,147,018,020,058,130,252,161,018,020,058,130,252,161,018,020,058,024
SOUND_15:
	DB 194,224,161,018,020,058,024
SOUND_16:
	DB 192,214,128,009,192,190,128,009,194,226,128,018,020,058,194,214,128,018,020,058,194,160,112,054,025,060,024
SOUND_17:
	DB 130,167,146,018,020,058,130,224,161,018,020,058,130,224,161,018,020,058,130,087,147,018,020,058,130,224,161,018,020,058,130,224,161,018,020,058,024
SOUND_18:
	DB 130,191,163,018,020,058,130,250,162,018,020,058,130,129,162,018,020,058,024
SOUND_19:
	DB 178,130,129,162,018,020,058,130,250,162,018,020,058,024
SOUND_20:
	DB 178,130,059,162,018,020,058,130,167,162,018,020,058,024
SOUND_21:
	DB 130,129,162,018,020,058,130,252,161,018,020,058,130,172,177,018,020,058,130,064,193,054,020,058,024
BULLET_HIT_DING_A:
	DB 194,127,000,038,031,038,208
BULLET_HIT_DING_B:
	DB 130,180,001,011,026,018,144
BULLET_HIT_DING_C:
	DB 066,051,000,010,024,019,080
LEFT_SIDE_BONUS_HIT_SOUND:
	DB 192,107,080,005,227,192,107,112,005,227,192,107,144,005,227,192,107,176,005,227,192,107,208,005,227,208
GUN_FIRE_SOUND:
	DB 002,244,010,026,017,016
PIPE_HIT_SOUND_A:
	DB 194,016,240,005,063,017,208
PIPE_HIT_SOUND_B:
	DB 002,007,005,058,017,016
BULLET_BONUS_SOUND_A:
	DB 130,039,115,006,026,017,130,250,114,006,026,017,130,202,114,006,026,017,130,167,114,006,026,017,130,129,114,006,026,017,130,093,114,006,026,017,130,059,114,006
    DB 026,017,130,027,114,006,026,017,130,252,113,006,026,017,130,224,113,006,026,017,130,197,113,006,026,017,130,172,113,006,026,017,130,148,113,006,026,017,130,125
    DB 113,006,026,017,130,104,113,006,026,017,130,083,113,006,026,017,130,064,113,006,026,017,130,046,113,006,026,017,130,029,113,006,026,017,130,013,113,006,026,017
    DB 130,254,112,006,026,017,130,240,112,006,026,017,130,226,112,006,026,017,130,214,112,006,026,017,130,202,112,006,026,017,152
BULLET_BONUS_SOUND_B:
	DB 194,248,115,006,026,017,194,191,115,006,026,017,194,137,115,006,026,017,194,087,115,006,026,017,194,039,115,006,026,017,194,250,114,006,026,017,194,202,114,006
    DB 026,017,194,167,114,006,026,017,194,129,114,006,026,017,194,093,114,006,026,017,194,059,114,006,026,017,194,027,114,006,026,017,194,252,113,006,026,017,194,224
    DB 113,006,026,017,194,197,113,006,026,017,194,172,113,006,026,017,194,148,113,006,026,017,194,125,113,006,026,017,194,104,113,006,026,017,194,083,113,006,026,017
    DB 194,064,113,006,026,017,194,046,113,006,026,017,194,029,113,006,026,017,194,013,113,006,026,017,194,254,112,006,026,017,216
BEAR_HIT_SOUND_A:
	DB 066,108,000,010,025,018,002,150,010,250,017,002,006,020,029,024,016
BEAR_HIT_SOUND_B:
	DB 130,151,000,010,026,018,131,133,051,013,017,240,244,065,131,119,002,018,017,021,026,025,016
BEAR_HIT_SOUND_C:
	DB 194,048,000,010,025,018,194,255,083,013,246,017,194,255,003,018,031,020,016
LETTER_BONUS_SOUND:
	DB 192,143,048,004,192,042,096,004,192,143,048,004,192,042,096,004,192,143,048,004,192,042,096,004,192,143,048,004,192,042,096,004,192,143,048,004,192,042,096,004
    DB 192,143,048,004,192,042,096,004,192,143,048,004,192,042,096,004,192,143,048,004,192,042,096,004,192,143,048,004,192,042,096,004,192,143,048,004,192,042,096,004
    DB 192,143,048,004,192,042,096,004,192,143,048,004,192,042,096,004,192,143,064,004,192,042,112,004,192,143,080,004,192,042,128,004,192,143,096,004,192,042,144,004
    DB 192,143,112,004,192,042,176,004,192,143,144,004,192,042,192,004,192,143,160,004,192,042,208,004,192,143,176,004,192,042,224,004,192,143,192,004,016,221,119,005
    DB 205,058,163,201,221,203,005,126,032,021,221,203,005,254,205,071,163,126,221,119,009,035,126,221,119,008,035,205,064,163,201,221,126,015,254,001,192,221,110,011
    DB 221,102,012,126,203,111,192,203,095,200,221,053,008,192,205,071,163,126,254,000,040,061,254,255,204,078,163,221,119,009,035,126,221,119,008,035,205,064,163,221
    DB 126,010,230,192,071,221,126,009,176,221,119,010,201,221,117,003,221,116,004,221,117,006,221,116,007,201,221,110,006,221,102,007,201,221,110,003,221,102,004,126
    DB 195,064,163,062,255,221,119,010,035,235,205,071,163,235,205,213,001,195,238,002

SUB_A369:
    LD      B, 10H
    LD      A, (IX+1)
    CP      0D0H
    JR      Z, LOC_A378
    ADD     A, B
    LD      (IX+1), A
    JR      LOCRET_A38E
LOC_A378:
    LD      A, ($7232)
    XOR     1
    LD      ($7232), A
    LD      A, 10H
    LD      (IX+1), A
    LD      B, 18H
    LD      A, (IX+3)
    ADD     A, B
    LD      (IX+3), A

LOCRET_A38E:     
RET

GET_RANDOM_NUMBER:   
    CALL    RAND_GEN
    AND     0FH
    LD      ($732F), A
    CP      9
    JR      NC, GET_RANDOM_NUMBER
    CALL    SUB_A3B6
    OR      A
    JR      Z, GET_RANDOM_NUMBER
    LD      HL, $732F
    LD      A, (HL)
    OR      A
    JR      Z, LOC_A3B4
    LD      A, ($7232)
    CP      1
    JR      NZ, LOC_A3B4
    LD      A, 0AH
    ADD     A, (HL)
    JR      LOCRET_A3B5

LOC_A3B4:
    LD      A, (HL)

LOCRET_A3B5:     
RET

SUB_A3B6:
    LD      HL, $7262
    CP      (HL)
    JR      Z, LOC_A3C5
    LD      (HL), A
    LD      HL, $7263
    LD      B, 0
    LD      (HL), B
    JR      LOC_A3C9

LOC_A3C5:
    LD      HL, $7263
    INC     (HL)

LOC_A3C9:
    LD      HL, $7229
    INC     A
    DEC     A
    JR      Z, LOC_A3ED
    INC     HL
    DEC     A
    JR      Z, LOC_A3ED
    INC     HL
    DEC     A
    JR      Z, LOC_A3ED
    INC     HL
    DEC     A
    JR      Z, LOC_A3ED
    INC     HL
    DEC     A
    JR      Z, LOC_A3ED
    INC     HL
    DEC     A
    JR      Z, LOC_A3ED
    INC     HL
    DEC     A
    JR      Z, LOC_A3ED
    INC     HL
    DEC     A
    JR      Z, LOC_A3ED
    INC     HL

LOC_A3ED:
    LD      A, (HL)
    OR      A
    JR      Z, LOC_A400
    PUSH    HL
    LD      HL, $7263
    LD      A, (HL)
    CP      3
    POP     HL
    JR      Z, LOC_A400
    LD      A, 1
    DEC     (HL)
    JR      LOCRET_A401

LOC_A400:
    XOR     A

LOCRET_A401:     
RET

    LD      A, ($73C4)
    XOR     20H
    LD      C, A
    LD      B, 1
    CALL    WRITE_REGISTER
RET

CLEAR_RAM:       
    LD      HL, 8FFFH
    ADD     HL, SP
    LD      C, L
    LD      B, H
    LD      HL, 7000H
    LD      DE, 7001H
    XOR     A
    LD      (HL), A
    LDIR
RET

REQUEST_TEST_AND_FREE_SIGNAL:          
    XOR     A
    CALL    REQUEST_SIGNAL
    LD      ($7330), A

TEST_AND_FREE_SIGNAL:
    CALL    MAJOR_SET_OF_ROUTINES
    LD      A, ($7330)
    CALL    TEST_SIGNAL
    OR      A
    JR      Z, TEST_AND_FREE_SIGNAL
    LD      A, ($7330)
    CALL    FREE_SIGNAL
RET

SUB_A439:
    PUSH    AF
    LD      A, 1
    LD      ($7233), A
    POP     AF
    PUSH    HL
    LD      HL, LOC_A447
    EX      (SP), HL
    JP      (IX)

LOC_A447:
    PUSH    HL
    LD      HL, $7233
    RES     0, (HL)
    BIT     7, (HL)
    LD      (HL), 0
    POP     HL
    CALL    NZ, NMI
RET

SUB_A456:
    LD      A, (HL)
    INC     HL

LOC_A458:
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    INC     HL
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    INC     HL
    PUSH    HL
    POP     IX
    LD      L, (IX+0)
    INC     IX
    LD      H, (IX+0)
    INC     IX
    PUSH    IX
    PUSH    AF
    CALL    WRITE_SOME_VRAM
    POP     AF
    POP     HL
    DEC     A
    JR      NZ, LOC_A458
RET

SUB_A479:
    CALL    SUB_A4A9
    LD      ($7332), A
    OR      A
	RET     Z
    LD      A, 80H
    LD      ($7331), A
    JR      LOC_A488

LOC_A488:
    LD      A, ($7332)
    LD      HL, $70BD
    BIT     1, A
    LD      A, (HL)
    JR      Z, LOC_A49B
    CP      0ECH
    JR      NC, PUT_OBJECT_15
    INC     (HL)
    INC     (HL)
    JR      PUT_OBJECT_15

LOC_A49B:
    CP      10H
    JR      C, PUT_OBJECT_15
    DEC     (HL)
    DEC     (HL)

PUT_OBJECT_15:   
    LD      IX, GUN_SPRITE
    CALL    PUTOBJ
RET

SUB_A4A9:
    LD      A, ($7161)
    LD      HL, (WORD_8008)
    OR      A
    JR      NZ, LOC_A4B6
    LD      A, 3
    JR      LOC_A4B8

LOC_A4B6:
    LD      A, 8

LOC_A4B8:
    ADD     A, L
    LD      L, A
    LD      A, (HL)
    AND     0AH
RET

SUB_A4BE:
    LD      HL, ($7267)
    LD      A, H
    OR      A
    JR      NZ, LOC_A4D6
    LD      A, L
    OR      A
    JR      NZ, LOC_A4D6
    CALL    SUB_A4DD
    CALL    SUB_A646
    CALL    PUT_OBJECT_05
    JP      PUT_OBJECT_04
RET

LOC_A4D6:
    CALL    SUB_A646
    JP      PUT_OBJECT_05
	RET

SUB_A4DD:
    LD      A, ($7339)
    OR      A
    JP      Z, LOC_A5CF
    CP      0F4H
    JP      NC, SUB_A5C7
    LD      HL, $7338
    CP      0E0H
    JP      C, SUB_A57C
    BIT     7, (HL)
    JP      NZ, SUB_A57C
    CP      0E4H
    JR      C, PUT_OBJECT_03_D
    BIT     6, (HL)
    JR      Z, PUT_OBJECT_02
    CP      0E8H
    JR      C, PUT_OBJECT_03_C
    BIT     5, (HL)
    JR      Z, PUT_OBJECT_02
    CP      0ECH
    JR      C, PUT_OBJECT_03_B
    BIT     4, (HL)
    JR      Z, PUT_OBJECT_02
    CP      0F0H
    JR      C, PUT_OBJECT_03_A
    BIT     3, (HL)
    JR      Z, PUT_OBJECT_02
    PUSH    HL
    SET     1, (HL)
    CALL    SUB_A57C
    LD      HL, ($7267)
    LD      DE, ($733B)
    ADD     HL, DE
    LD      ($7267), HL
    LD      HL, 28H
    XOR     A
    CALL    REQUEST_SIGNAL
    LD      ($733D), A
    CALL    SUB_A646
    CALL    PUT_OBJECT_05
    CALL    SUB_A5C7
    POP     HL
    SET     7, (HL)
    JP      LOC_A5CF

PUT_OBJECT_02:   
    PUSH    HL
    LD      A, 0A8H
    LD      ($733F), A
    LD      A, 20H
    LD      ($7341), A
    CALL    CLEAR_BONUS
    POP     HL
    SET     7, (HL)
    JP      SUB_A5C7

PUT_OBJECT_03_A: 
    SET     3, (HL)
    LD      BC, 3
    JR      PUT_OBJECT_03

PUT_OBJECT_03_B: 
    SET     4, (HL)
    LD      BC, 2
    JR      PUT_OBJECT_03

PUT_OBJECT_03_C: 
    SET     5, (HL)
    LD      BC, 1
    JR      PUT_OBJECT_03

PUT_OBJECT_03_D: 
    SET     6, (HL)
    LD      BC, 0
    JR      PUT_OBJECT_03

PUT_OBJECT_03:   
    LD      HL, $7094
    ADD     HL, BC
    INC     (HL)
    LD      IX, FLYING_DUCK
    CALL    PUTOBJ

SUB_A57C:
    LD      B, 20H
    LD      IX, $7269
    LD      A, ($7161)
    OR      A
    JR      Z, LOC_A58E
    LD      IX, $726D
    LD      B, 0A8H

LOC_A58E:
    INC     A
    LD      ($7100), A
    LD      A, B
    LD      ($7109), A
    LD      A, (IX+3)
    INC     A
    CP      5
    JR      C, LOC_A5A0
    LD      A, 5

LOC_A5A0:
    LD      C, A
    LD      A, ($733A)
    CP      6FH
    JR      NC, LOC_A5B0
    INC     C
    INC     C
    CP      57H
    JR      NC, LOC_A5B0
    INC     C
    INC     C

LOC_A5B0:
    LD      B, 0
    LD      HL, ($7267)
    ADD     HL, BC
    LD      ($7267), HL
    LD      HL, $7338
    BIT     6, (HL)
    JR      NZ, SUB_A5C7
    LD      HL, ($733B)
    ADD     HL, BC
    LD      ($733B), HL

SUB_A5C7:
    LD      HL, $7339
    XOR     A
    LD      (HL), A
    INC     HL
    LD      (HL), A
RET

LOC_A5CF:
    POP     HL
RET

PLAY_LETTER_BONUS_SOUND_AND_OBJECT:    
    CALL    SUB_A81C
    XOR     A
    LD      ($73C6), A
    LD      A, 0A8H
    LD      ($733F), A
    LD      A, 20H
    LD      ($7341), A
    LD      A, 8
    LD      ($7337), A
    CALL    INITIALIZE_SOUND
    LD      B, 10H
    CALL    PLAY_IT
    CALL    CLEAR_BONUS

LOOP_TO_FLASH:   
    CALL    SUB_A615
    CALL    DISPLAY_BONUS
    CALL    SUB_A615
    CALL    CLEAR_BONUS
    LD      A, ($7337)
    DEC     A
    LD      ($7337), A
    JR      NZ, LOOP_TO_FLASH
    LD      A, 1
    LD      ($73C6), A
    LD      A, ($7157)
    OR      A
	RET     NZ

JUMP_TO_MUSICAL_SCORE:
    JP      PLAY_MUSICAL_SCORE
	RET

SUB_A615:
    LD      B, 8

LOOP_A617:       
    LD      HL, 76CH
    LD      DE, 1

LOC_A61D:
    SBC     HL, DE
    JR      NZ, LOC_A61D
    PUSH    BC
    CALL    PLAY_SONGS
    CALL    SOUND_MAN
    POP     BC
    DJNZ    LOOP_A617
RET

DISPLAY_BONUS:   
    LD      HL, $733E
    LD      (HL), 0
    LD      IX, BONUS
    JP      PUTOBJ
	RET

CLEAR_BONUS:     
    LD      HL, $733E
    LD      (HL), 1
    LD      IX, BONUS
    JP      PUTOBJ
	RET

SUB_A646:
    LD      IX, $7269
    LD      A, ($7161)
    OR      A
    JR      Z, LOC_A654
    LD      IX, $726D

LOC_A654:
    LD      BC, ($7267)
    LD      H, (IX+1)
    LD      L, (IX+2)
    ADD     HL, BC
    LD      A, H
    BIT     7, A
    JR      Z, LOC_A667
    LD      HL, 0

LOC_A667:
    LD      DE, 2710H
    OR      A
    SBC     HL, DE
    JR      NC, LOC_A670
    ADD     HL, DE

LOC_A670:
    LD      (IX+1), H
    LD      (IX+2), L
    XOR     A
    LD      ($7267), A
    LD      ($7268), A
RET

PUT_OBJECT_05:   
    CALL    SUB_A6D8
    LD      B, 20H
    LD      IX, $7269
    LD      A, ($7161)
    OR      A
    JR      Z, PUT_OBJECT_05_A
    LD      IX, $726D
    LD      B, 0A8H

PUT_OBJECT_05_A: 
    INC     A
    LD      ($7100), A
    LD      A, B
    LD      ($7109), A
    LD      A, (IX+3)
    LD      DE, $7102
    LD      HL, $7334
    LD      BC, 4
    LDIR
    LD      IX, OFF_9274
    JP      PUTOBJ
	RET

PUT_OBJECT_04:   
    LD      A, ($7338)
    BIT     7, A
    JR      Z, PUT_OBJECT_04_A
	RET     NZ

PUT_OBJECT_04_A: 
    LD      HL, ($733B)
    CALL    SUB_A6D8
    LD      HL, $7335
    LD      A, (HL)
    OR      A
    JR      NZ, PUT_OBJECT_04_B
    LD      (HL), 0FFH

PUT_OBJECT_04_B: 
    LD      DE, $7099
    LD      BC, 3
    LDIR
    LD      IX, FLYING_DUCK
    JP      PUTOBJ
	RET

SUB_A6D8:
    PUSH    HL
    LD      DE, $7335
    LD      HL, $7334
    PUSH    HL
    POP     IX
    LD      (HL), 0
    LD      BC, 3
    LDIR
    POP     HL
    PUSH    HL
    POP     DE
    LD      A, 27H
    CP      H
	RET     C
    JR      NZ, LOC_A6F6
    LD      A, 0FH
    CP      L
	RET     C

LOC_A6F6:
    LD      BC, 3E8H
    OR      A
    SBC     HL, BC
    JP      P, LOC_A719
    PUSH    DE
    POP     HL
    LD      BC, 64H
    OR      A
    SBC     HL, BC
    JP      P, LOC_A72B
    PUSH    DE
    POP     HL
    LD      BC, 0AH
    OR      A
    SBC     HL, BC
    JP      P, LOC_A73D
    PUSH    DE
    POP     HL
    JR      LOC_A74C

LOC_A719:
    PUSH    DE
    POP     HL
    JR      LOC_A722

LOC_A71D:
    PUSH    HL
    POP     DE
    INC     (IX+0)

LOC_A722:
    OR      A
    SBC     HL, BC
    JP      P, LOC_A71D
    LD      BC, 64H

LOC_A72B:
    PUSH    DE
    POP     HL
    JR      LOC_A734

LOC_A72F:
    PUSH    HL
    POP     DE
    INC     (IX+1)

LOC_A734:
    OR      A
    SBC     HL, BC
    JP      P, LOC_A72F
    LD      BC, 0AH

LOC_A73D:
    PUSH    DE
    POP     HL
    JR      LOC_A746

LOC_A741:
    PUSH    HL
    POP     DE
    INC     (IX+2)

LOC_A746:
    OR      A
    SBC     HL, BC
    JP      P, LOC_A741

LOC_A74C:
    LD      A, E
    ADD     A, (IX+3)
    LD      (IX+3), A
RET

BONUS:
	DW BONUS_OBJ           
    DW $733E
    DB    0
    DB  80H
BONUS_OBJ:
	DB    0   
    DB    0
    DB    0
    DB    0
    DB    0
    DW BONUS_FRAME
    DW BONUS_CLEAR
BONUS_FRAME:
	DB 007,003
    DB 255,018,021,024,026,255,255
    DB 016,019,022,025,027,029,031
    DB 017,020,023,255,028,030,032
BONUS_CLEAR:
    DB 007,003
    DB 255,255,255,255,255,255,255
    DB 255,255,255,255,255,255,255
    DB 255,255,255,255,255,255,255
BONUS_PATTERNS:
	DB 000,000,000,001,003,015,028,024
    DB 025,015,006,007,003,001,000,000
    DB 000,000,000,000,000,000,001,007
    DB 030,024,012,204,198,102,099,243
    DB 221,141,012,012,184,240,224,000
    DB 000,000,000,000,000,096,224,176
    DB 048,024,024,012,012,006,030,120
    DB 224,128,000,000,000,000,000,000
    DB 000,000,000,000,195,227,227,243
    DB 211,219,219,207,207,199,195,000
    DB 000,000,000,000,000,006,006,012
    DB 012,024,024,048,048,096,120,030
    DB 007,001,000,000,000,000,000,000
    DB 024,024,048,051,099,102,206,199
    DB 131,161,048,048,029,015,007,000
    DB 000,000,000,128,192,240,056,024
    DB 128,224,096,224,192,128,000,000

UNK_A819:
	DB 0D0H   
    DB 0D0H
    DB 0D0H

SUB_A81C:
    LD      HL, UNK_A823
    CALL    SUB_A456
RET

UNK_A823:       DB    8   
    DB  88H
    DB    0
    DB  80H
    DB    0
    DW BONUS_PATTERNS
    DB  88H
    DB    0
    DB  80H
    DB    8
    DW BONUS_PATTERNS
    DB  88H
    DB    0
    DB  80H
    DB  10H
    DW BONUS_PATTERNS
    DB  88H
    DB    0
    DB  80H
    DB  18H
    DW BONUS_PATTERNS
    DB    3
    DB    0
    DB    2
    DB  23H
    DW UNK_A819
    DB    3
    DB    0
    DB  42H ; B
    DB  23H
    DW UNK_A819
    DB    3
    DB    0
    DB  82H
    DB  23H
    DW UNK_A819
    DB    3
    DB    0
    DB 0C2H
    DB  23H
    DW UNK_A819
LEFT_BONUS_HUD: DW LEFT_BONUS_OBJ       ; ...
                DW $7344
                DB    0
                DB  80H
LEFT_BONUS_OBJ: DB    0                 ; ...
                DB    0
                DB    0
                DB    0
                DB    0
                DW LFT_BONUS_FRM_A
                DW LFT_BONUS_FRM_B
                DW LFT_BONUS_FRM_C
LFT_BONUS_FRM_A:DB  11,  4              ; ...
                DB 255,255,255,255,255,255,255,255,255,255,255
                DB 255,255,255,255,255,255,255,255,255,255,255
                DB 255,255,255,255,255,255,255,255,255,255,255
                DB 010,010,010,010,010,010,010,010,010,010,010
LFT_BONUS_FRM_B:DB 011,004              ; ...
                DB 255,255,040,041,041,041,041,041,042,255,255
                DB 255,255,043,255,255,255,255,255,044,255,255
                DB 255,255,045,046,046,046,046,046,047,255,255
                DB 255,255,255,255,255,255,255,255,255,255,255
LFT_BONUS_FRM_C:DB 011,004              ; ...
                DB 255,255,040,041,041,041,041,041,041,041,042
                DB 255,255,043,255,255,255,255,255,255,255,044
                DB 255,255,045,046,046,046,046,046,046,046,047
                DB 255,255,255,255,255,255,255,255,255,255,255
OFF_A8EF:
	DW UNK_A8F5            
    DW UNK_A8FC
    DB    0
    DB  80H
UNK_A8F5:
	DB    0   
    DB    0
    DB    0
    DB    0
    DB    0
    DW $734A
UNK_A8FC:
	DB    0   
    DB  18H
    DB    0
    DB  28H
    DB    0
    DB    0

JUMP_FROM_TABLE_03:  
    CALL    SUB_AB6F
    LD      A, ($7353)
    PUSH    DE
    LD      HL, OFF_A91A
    LD      D, 0
    LD      E, A
    ADD     HL, DE
    ADD     HL, DE
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    LD      HL, LOCRET_AA39
    EX      (SP), HL
    EX      DE, HL
    JP      (HL)

OFF_A91A:
	DW REQUEST_SIGNAL_PUT_OBJECT_22
    DW TEST_SIGNAL_25
    DW TEST_SIGNAL_24
    DW TEST_SIGNAL_23
    DW TEST_SIGNAL_22
    DW PUT_OBJECT_23_A
    DW FREE_AND_REQUEST_SIGNAL_22
    DW LOC_AA0E

REQUEST_SIGNAL_PUT_OBJECT_22:          
    LD      A, R
    AND     3FH
    LD      E, A
    LD      D, 0
    LD      HL, 103H
    JP      PO, REQUEST_SIGNAL_PUT_OBJECT_22_A
    ADD     HL, DE
    JR      REQUEST_SIGNAL_PUT_OBJECT_22_B

REQUEST_SIGNAL_PUT_OBJECT_22_A:        
    SBC     HL, DE

REQUEST_SIGNAL_PUT_OBJECT_22_B:        
    LD      A, 0
    CALL    REQUEST_SIGNAL
    LD      ($7357), A
    LD      A, 0
    LD      ($7358), A
    CALL    PUT_OBJECT_23
    LD      A, 7
    LD      ($7353), A
RET

TEST_SIGNAL_25:  
    LD      A, ($7357)
    CALL    TEST_SIGNAL
    CP      1
    JR      NZ, LOCRET_A972
    LD      A, ($7356)
    CP      5
    JR      Z, LOC_A96F
    JR      C, LOC_A96F
    SUB     5
    LD      ($7356), A
    CALL    SUB_AAD8
    JR      LOCRET_A972

LOC_A96F:
    CALL    SUB_AB63

LOCRET_A972:     
RET

TEST_SIGNAL_24:  
    LD      A, ($7357)
    CALL    TEST_SIGNAL
    CP      1
    JR      NZ, LOCRET_A980
    CALL    SUB_AB63

LOCRET_A980:     
RET

TEST_SIGNAL_23:  
    LD      A, ($7357)
    CALL    TEST_SIGNAL
    CP      1
    JR      NZ, LOCRET_A99C
    LD      HL, $7355
    LD      A, (HL)
    CP      1
    JR      Z, LOC_A999
    DEC     (HL)
    CALL    SUB_AB19
    JR      LOCRET_A99C

LOC_A999:
    CALL    SUB_AB63

LOCRET_A99C:     
RET

TEST_SIGNAL_22:  
    LD      A, ($7357)
    CALL    TEST_SIGNAL
    CP      1
    JR      NZ, LOCRET_A9AA
    CALL    SUB_AB63

LOCRET_A9AA:     
RET

PUT_OBJECT_23_A: 
    LD      A, 0
    CALL    PUT_OBJECT_23
    LD      A, ($7356)
    LD      ($7267), A
    BIT     7, A
    JR      Z, LOC_A9BF
    LD      A, 0FFH
    LD      ($7268), A

LOC_A9BF:
    LD      A, ($7355)
    LD      ($7033), A
    LD      A, 6
    LD      ($7353), A
RET

FREE_AND_REQUEST_SIGNAL_22:            
    LD      HL, $7358
    LD      A, (HL)
    OR      A
    JR      NZ, LOC_A9E6
    INC     (HL)
    LD      A, ($7357)
    CALL    FREE_SIGNAL
    LD      HL, 29H ; ')'
    LD      A, 1
    CALL    REQUEST_SIGNAL
    LD      ($7357), A
    JR      LOCRET_AA0D

LOC_A9E6:
    LD      A, ($7357)
    CALL    TEST_SIGNAL
    OR      A
    JR      Z, LOCRET_AA0D
    LD      HL, $7358
    INC     (HL)
    BIT     0, (HL)
    JR      Z, LOC_AA06
    LD      A, (HL)
    CP      7
    JR      NZ, LOC_A9FF
    CALL    SUB_AB63

LOC_A9FF:
    LD      A, 0
    CALL    PUT_OBJECT_23
    JR      LOCRET_AA0D

LOC_AA06:
    LD      IX, OFF_A8EF
    CALL    PUTOBJ

LOCRET_AA0D:     
RET

LOC_AA0E:
    LD      A, ($7357)
    CALL    TEST_SIGNAL
    CP      1
    JR      NZ, LOCRET_AA38
    LD      A, 0
    LD      ($7356), A
    LD      ($7355), A
    LD      A, R
    AND     3
    INC     A
    LD      ($7353), A
    CP      3
    JR      NC, LOC_AA30
    LD      A, 1
    JR      LOC_AA32
LOC_AA30:
    LD      A, 2

LOC_AA32:
    CALL    PUT_OBJECT_23
    CALL    SUB_AA3A

LOCRET_AA38:     
RET

LOCRET_AA39:     
RET

SUB_AA3A:
    LD      A, ($7353)
    PUSH    DE
    LD      HL, OFF_AA4F
    LD      D, 0
    LD      E, A
    ADD     HL, DE
    ADD     HL, DE
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    LD      HL, LOCRET_AAC8
    EX      (SP), HL
    EX      DE, HL
    JP      (HL)

OFF_AA4F:
	DW LOCRET_AA59         
    DW LOC_AA5A
    DW LOC_AA77
    DW LOC_AA94
    DW LOC_AAAD

LOCRET_AA59:     
RET

LOC_AA5A:
    CALL    SUB_AB53
    LD      B, A
    LD      C, 5
    LD      A, 0

LOC_AA62:
    ADD     A, C
    DJNZ    LOC_AA62
    LD      ($7356), A
    CALL    SUB_AAD8
    LD      HL, 1FH
    LD      A, 1
    CALL    REQUEST_SIGNAL
    LD      ($7357), A
RET

LOC_AA77:
    CALL    SUB_AB53
    LD      B, A
    LD      C, 5
    LD      A, 0ABH

LOC_AA7F:
    ADD     A, C
    DJNZ    LOC_AA7F
    LD      ($7356), A
    CALL    SUB_AAD8
    LD      HL, 0FFH
    LD      A, 1
    CALL    REQUEST_SIGNAL
    LD      ($7357), A
RET

LOC_AA94:
    CALL    SUB_AB53
	SRA     A
    ADD     A, 4
    LD      ($7355), A
    CALL    SUB_AB19
    LD      HL, 1FH
    LD      A, 1
    CALL    REQUEST_SIGNAL
    LD      ($7357), A
RET

LOC_AAAD:
    CALL    SUB_AB53
	SRA     A
    LD      B, A
    LD      A, 0F4H
    ADD     A, B
    LD      ($7355), A
    CALL    SUB_AB19
    LD      HL, 0FFH
    LD      A, 0
    CALL    REQUEST_SIGNAL
    LD      ($7357), A
RET

LOCRET_AAC8:     
RET

PUT_OBJECT_23:   
    LD      IX, LEFT_BONUS_HUD
    LD      L, (IX+2)
    LD      H, (IX+3)
    LD      (HL), A
    CALL    PUTOBJ
RET

SUB_AAD8:
    LD      IX, (OFF_A8EF)
    LD      L, (IX+5)
    LD      H, (IX+6)
    LD      (HL), 5
    INC     HL
    LD      (HL), 1
    INC     HL
    LD      (HL), 0BH
    LD      A, ($7356)
    OR      A
    JP      P, LOC_AAF5
    LD      (HL), 3DH
    NEG

LOC_AAF5:
    INC     HL
    LD      (HL), 0FFH
    INC     HL
    LD      B, 0

LOC_AAFB:
    CP      0AH
    JR      C, LOC_AB04
    SUB     0AH
    INC     B
    JR      LOC_AAFB

LOC_AB04:
    LD      C, A
    LD      A, B
    LD      (HL), 0FFH
    OR      A
    JR      Z, LOC_AB0C
    LD      (HL), B

LOC_AB0C:
    INC     HL
    LD      (HL), C
    INC     HL
    LD      (HL), 0
    LD      IX, OFF_A8EF
    CALL    PUTOBJ
RET

SUB_AB19:
    LD      IX, (OFF_A8EF)
    LD      L, (IX+5)
    LD      H, (IX+6)
    LD      (HL), 7
    INC     HL
    LD      (HL), 1
    INC     HL
    LD      (HL), 0BH
    LD      A, ($7355)
    OR      A
    JP      P, LOC_AB36
    LD      (HL), 3DH
    NEG

LOC_AB36:
    INC     HL
    LD      B, 6

LOC_AB39:
    LD      (HL), 0FFH
    OR      A
    JR      Z, LOC_AB48
    LD      (HL), 41H
    CP      1
    JR      Z, LOC_AB47
    LD      (HL), 40H
    DEC     A

LOC_AB47:
    DEC     A

LOC_AB48:
    INC     HL
    DJNZ    LOC_AB39
    LD      IX, OFF_A8EF
    CALL    PUTOBJ
RET

SUB_AB53:
    LD      A, R
    ADD     A, A
    LD      HL, UNK_ABC1
    LD      B, 10H

LOC_AB5B:
    CP      (HL)
    JR      C, LOC_AB61
    INC     HL
    DJNZ    LOC_AB5B

LOC_AB61:
    LD      A, B
RET

SUB_AB63:
    LD      A, 0
    LD      ($7353), A
    LD      A, ($7357)
    CALL    FREE_SIGNAL
RET

SUB_AB6F:
    LD      A, ($7359)
    OR      A
    JR      NZ, LOCRET_ABB6
    LD      A, ($7160)
    CP      3
    JR      NZ, LOCRET_ABB6
    LD      A, ($7338)
    BIT     7, A
    JR      Z, LOCRET_ABB6
    LD      HL, $7269
    LD      A, ($7161)
    OR      A
    JR      Z, PUT_OBJECT_22
    LD      HL, $726D

PUT_OBJECT_22:   
    INC     HL
    INC     HL
    INC     HL
    LD      A, (HL)
    CP      2
    JR      NZ, LOCRET_ABB6
    LD      HL, $7157
    LD      A, (HL)
    CP      1
    JR      NZ, LOCRET_ABB6
    LD      BC, 0AH
    LD      DE, $7094
    LD      HL, UNK_ABB7
    LDIR
    LD      IX, FLYING_DUCK
    CALL    PUTOBJ
    LD      A, 0FFH
    LD      ($7359), A

LOCRET_ABB6:     
RET

UNK_ABB7:
	DB 0FFH   
    DB  3CH
    DB  3BH
    DB  35H
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH

UNK_ABC1:
	DB  10H   
    DB  20H
    DB  30H
    DB  40H
    DB  50H
    DB  60H
    DB  70H
    DB  80H
    DB  90H
    DB 0A0H
    DB 0B0H
    DB 0C0H
    DB 0D0H
    DB 0E0H
    DB 0F0H
    DB 0FFH

SUB_ABD1:
    LD      HL, UNK_9281
    LD      DE, $70F8
    LD      BC, 15H
    LDIR
    LD      A, 1
    LD      ($7268), A
    CALL    SUB_A4BE
    CALL    MAJOR_SET_OF_ROUTINES
    LD      A, 0FFH
    LD      ($7268), A
    CALL    SUB_A4BE
    CALL    MAJOR_SET_OF_ROUTINES
    LD      A, ($715F)
    CP      0
    JR      Z, LOC_AC28
    LD      A, ($7161)
    XOR     1
    LD      ($7161), A
    LD      A, 1
    LD      ($7268), A
    CALL    SUB_A4BE
    CALL    MAJOR_SET_OF_ROUTINES
    LD      A, 0FFH
    LD      ($7268), A
    CALL    SUB_A4BE
    CALL    MAJOR_SET_OF_ROUTINES
    LD      A, ($7161)
    XOR     1
    LD      ($7161), A
    LD      HL, 2057H
    LD      A, ($7270)
    CALL    SUB_AC2E

LOC_AC28:
    LD      HL, 2046H
    LD      A, ($726C)

SUB_AC2E:
    LD      E, A
    OR      A
	RET     Z
    BIT     2, A
    JR      Z, LOC_AC37
    LD      E, 3

LOC_AC37:
    LD      D, 0
    LD      A, 3FH
    JP      FILL_VRAM
    DB 0C9H

SUB_AC3F:
    LD      HL, 2060H
    CALL    SUB_AC58
    LD      HL, 2075H
    CALL    SUB_AC58
    LD      HL, 20E0H
    CALL    SUB_AC58
    LD      HL, 20F5H
    CALL    SUB_AC58
RET

SUB_AC58:
    LD      DE, 0BH
    LD      A, 0AH
    LD      IX, FILL_VRAM
    CALL    SUB_A439
RET

SUB_AC65:
    LD      HL, UNK_9361
    LD      DE, $7130
    LD      BC, 27H
    LDIR
    XOR     A
    LD      ($727F), A
    LD      A, 1
    LD      ($7280), A
    LD      A, ($7161)
    LD      HL, $7269
    LD      DE, $726D
    OR      A
    JR      Z, LOC_AC86
    EX      DE, HL

LOC_AC86:
    INC     HL
    INC     HL
    INC     HL
    LD      A, (HL)
    PUSH    AF
    LD      B, 5
    ADD     A, B
    LD      HL, $713A
    LD      (HL), A
    POP     AF
    INC     A
    LD      BC, 3206H
    DEC     A
    JR      Z, PUT_OBJECT_21
    LD      BC, 3C05H
    DEC     A
    JR      Z, PUT_OBJECT_21
    LD      BC, 4604H
    DEC     A
    JR      Z, PUT_OBJECT_21
    LD      BC, 5003H
    DEC     A
    JR      Z, PUT_OBJECT_21
    LD      BC, 5A02H

PUT_OBJECT_21:   
    LD      A, B
    LD      ($7282), A
    LD      A, C
    LD      ($7281), A
    LD      HL, 1
    LD      ($7271), HL
    LD      A, L
    LD      ($7274), A
    XOR     A
    LD      ($7275), A
    LD      ($727C), A
    LD      A, 3
    LD      ($7276), A
    LD      HL, $712B
    PUSH    HL
    POP     IX
    XOR     A
    LD      (IX+0), A
    LD      (IX+2), A
    LD      (IX+3), A
    LD      (IX+4), A
    LD      A, 60H
    LD      (IX+1), A
    LD      IX, PIPES_PARTS
    CALL    PUTOBJ
    LD      B, 8
    LD      HL, $7266
    LD      A, (HL)
    ADD     A, B
    LD      (HL), A
    LD      A, 0FFH
    LD      ($727E), A
    LD      ($727D), A
RET

BONUS_MESSAGE:   
    LD      IX, FLYING_DUCK
    LD      L, (IX+0)
    LD      H, (IX+1)
    LD      BC, 5
    ADD     HL, BC
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    LD      HL, BONUS_200_OBJ
    LD      BC, 12H
    LDIR
    LD      A, ($7161)
    LD      HL, $7269
    LD      DE, $726D
    OR      A
    JR      Z, LOC_AD23
    EX      DE, HL

LOC_AD23:
    INC     HL
    INC     HL
    INC     HL
    LD      A, (HL)
    PUSH    AF
    LD      B, 2
    ADD     A, B
    LD      HL, $709A
    LD      (HL), A
    POP     AF
    INC     A
    LD      BC, 14H
    DEC     A
    JR      Z, PUT_OBJECT_20
    LD      BC, 1EH
    DEC     A
    JR      Z, PUT_OBJECT_20
    LD      BC, 28H
    DEC     A
    JR      Z, PUT_OBJECT_20
    LD      BC, 32H
    DEC     A
    JR      Z, PUT_OBJECT_20
    LD      BC, 3CH
PUT_OBJECT_20:   
    LD      ($733B), BC
    LD      HL, $7338
    XOR     A
    LD      (HL), A
    CALL    PUTOBJ
RET

BONUS_200_OBJ:
	DB 005,002
    DB 016,018,020,022,024
    DB 255,002,000,000,255
    DB    0
    DB 0B0H
    DB    0
    DB  28H
    DB    0
    DB    0

SUB_AD6B:
    LD      A, ($7161)
    LD      HL, $7269
    LD      DE, $726D
    OR      A
    JR      Z, PUT_OBJECT_18
    EX      DE, HL

PUT_OBJECT_18:   
    INC     HL
    INC     HL
    INC     HL
    LD      A, (HL)
    LD      IX, OFF_92C0
    LD      HL, $7120
    LD      (HL), A
    INC     HL
    LD      (HL), 0E8H
    INC     HL
    INC     HL
    LD      (HL), 40H
    CALL    PUTOBJ
RET

PUT_MUSIC_NOTE_SPRITE:    
    LD      IX, MUSIC_NOTE_SPRITE
    LD      HL, $7157
    XOR     A
    LD      (HL), A
    INC     HL
    LD      (HL), 0E8H
    INC     HL
    INC     HL
    LD      (HL), 80H
    CALL    PUTOBJ
RET

PUT_GUN_SPRITE:  
    XOR     A
    LD      ($7278), A
    LD      HL, $7331
    LD      (HL), A
    INC     HL
    LD      (HL), A
    INC     HL
    LD      (HL), A
    LD      IX, GUN_SPRITE
    LD      HL, $70BC
    INC     HL
    LD      (HL), 7EH
    INC     HL
    INC     HL
    LD      (HL), 0B0H
    CALL    PUTOBJ
RET

SUB_ADC1:
    LD      A, 0FFH
    LD      ($7033), A
    CALL    SUB_8507
    LD      A, 1
    LD      ($7033), A
    CALL    SUB_8507
    XOR     A
    LD      ($7034), A
    LD      ($727A), A
RET

SUB_ADD9:
    XOR     A
    LD      ($7232), A
    LD      A, ($7160)
    INC     A
    LD      HL, TABLE_SET_12
    DEC     A
    JR      Z, LOC_ADF6
    LD      HL, TABLE_SET_10
    DEC     A
    JR      Z, LOC_ADF6
    LD      HL, TABLE_SET_08
    DEC     A
    JR      Z, LOC_ADF6
    LD      HL, TABLE_SET_06
LOC_ADF6:
    INC     HL
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    EX      DE, HL
    LD      DE, $7229
    LD      BC, 4
    LDIR
    LD      A, 1
    LD      (DE), A
    INC     DE
    LD      (DE), A
    INC     DE
    LD      (DE), A
    INC     DE
    LD      (DE), A
    INC     DE
    LD      (DE), A
    LD      HL, $7085
    PUSH    HL
    POP     IX
    LD      B, 0
    LD      C, 10H
    LD      (IX+1), C
    LD      (IX+2), B
    LD      C, 40H
    LD      (IX+3), C
    LD      (IX+4), B
    LD      A, 0FFH
    LD      ($7262), A
    LD      HL, $705B
    LD      DE, $705C
    LD      BC, 0BH
    LD      A, 0FFH
    LD      (HL), A
    LDIR

LOC_AE39:
    CALL    GET_RANDOM_NUMBER
    OR      A
    JR      Z, PUT_OBJECT_27
    LD      HL, $7266
    INC     (HL)

PUT_OBJECT_27:   
    LD      (IX+0), A
    PUSH    IX
    LD      IX, TARGETS
    CALL    PUTOBJ
    LD      HL, 2
    CALL    REQUEST_TEST_AND_FREE_SIGNAL
    POP     IX
    CALL    SUB_A369
    LD      A, (IX+3)
    CP      88H
    JR      NZ, LOC_AE39
    LD      HL, 6
    XOR     A
    CALL    REQUEST_SIGNAL
    LD      ($7265), A
    LD      HL, $7054
    XOR     A
    LD      (HL), A
    LD      HL, $7055
    LD      (HL), A
    INC     HL
    LD      (HL), A
    LD      HL, $7037
    LD      (HL), A
RET

PUT_OBJECT_08:   
    LD      HL, 2800H
    LD      DE, 24H ; '$'
    LD      A, 0D0H
    CALL    FILL_VRAM
    LD      IX, BEAR_EQUALS_50
    CALL    PUTOBJ
    CALL    SUB_ABD1
    LD      DE, 80H
    LD      A, 0AH
    CALL    FILLING_SOME_VRAM
    LD      DE, 2E0H
    LD      A, 0FH
    CALL    FILLING_SOME_VRAM
    CALL    PUT_GUN_SPRITE
    CALL    PUT_OBJECT_10_A
    LD      DE, 1A0H
    LD      A, 3EH ; '>'
    CALL    FILLING_SOME_VRAM
    LD      IX, OFF_B380
    LD      IY, $735A
    LD      (IY+3), 58H
    LD      (IY+4), 0
    LD      (IY+8), 58H
    LD      (IY+9), 0
    LD      C, 0
    CALL    SUB_B22A
    LD      A, 1
    LD      ($7365), A
    XOR     A
    LD      ($7374), A
    LD      ($7383), A
    LD      A, 0
    LD      ($7364), A
    LD      ($7373), A
    LD      ($7382), A
    LD      IY, $735A
    LD      IX, BEAR_SPRITE
    LD      B, 3

REQUEST_SOME_SIGNAL: 
    PUSH    BC
    LD      H, 0
    LD      L, (IX+0)
    LD      A, 1
    CALL    REQUEST_SIGNAL
    LD      (IY+0CH), A
    LD      H, 0
    LD      L, (IX+1)
    LD      A, 1
    CALL    REQUEST_SIGNAL
    LD      (IY+0DH), A
    LD      DE, 0FH
    ADD     IY, DE
    POP     BC
    DJNZ    REQUEST_SOME_SIGNAL
    LD      A, ($7161)
    LD      HL, $726C
    CP      1
    JR      NZ, LOC_AF1C
    LD      HL, $7270

LOC_AF1C:
    LD      A, (HL)
    DEC     A
    CP      1
    JR      C, LOC_AF4E
    PUSH    HL
    LD      DE, 100H
    LD      A, 42H ; 'B'
    CALL    FILLING_SOME_VRAM
    LD      A, 1
    LD      ($7374), A
    LD      IX, OFF_B38A
    LD      IY, $7369
    LD      (IY+3), 30H
    LD      (IY+4), 0
    LD      (IY+8), 30H
    LD      (IY+9), 0
    LD      C, 20H
    CALL    SUB_B22A
    POP     HL

LOC_AF4E:
    LD      A, (HL)
    DEC     A
    CP      2
    JR      C, LOC_AF7E
    LD      DE, 240H
    LD      A, 42H ; 'B'
    CALL    FILLING_SOME_VRAM
    LD      A, 1
    LD      ($7383), A
    LD      IX, OFF_B394
    LD      IY, $7378
    LD      (IY+3), 80H
    LD      (IY+4), 0
    LD      (IY+8), 80H
    LD      (IY+9), 0
    LD      C, 2
    CALL    SUB_B22A

LOC_AF7E:
    CALL    SUB_A4BE

LOC_AF81:
    CALL    MAJOR_SET_OF_ROUTINES
    LD      A, ($7365)
    LD      B, A
    LD      A, ($7374)
    LD      C, A
    LD      A, ($7383)
    OR      B
    OR      C
    JP      Z, FREE_SOME_SIGNAL_A
    CALL    SUB_A479
    CALL    SUB_955D
    CALL    SUB_B1F1
    LD      B, 3
    LD      IY, $735A
    LD      IX, OFF_B380

PLAY_BEAR_HIT:   
    PUSH    BC
    LD      A, (IY+0BH)
    OR      A
    JP      Z, LOC_B186
    LD      A, (IY+0EH)
    CP      1
    JR      NZ, TEST_SIGNAL_ROUTINE
    LD      (IY+0EH), 0
    PUSH    IX
    PUSH    IY
    LD      B, 0DH
    CALL    PLAY_IT
    LD      B, 0EH
    CALL    PLAY_IT
    LD      B, 0FH
    CALL    PLAY_IT
    POP     IY
    POP     IX
    LD      A, (IY+0CH)
    CALL    FREE_SIGNAL
    LD      D, 0
    LD      E, (IY+0BH)
    LD      A, E
    CP      7
    JR      NC, LOC_AFE6
    LD      A, E
    INC     A
    LD      (IY+0BH), A

LOC_AFE6:
    LD      HL, LOCRET_B36A
    ADD     HL, DE
    ADD     HL, DE
    ADD     HL, DE
    LD      A, (HL)
    LD      L, A
    LD      H, 0
    LD      A, 1
    CALL    REQUEST_SIGNAL
    LD      (IY+0CH), A
    LD      E, (IY+0AH)
    LD      D, 0
    LD      HL, UNK_B1D8
    ADD     HL, DE
    LD      A, (HL)
    LD      (IY+0AH), A

TEST_SIGNAL_ROUTINE: 
    LD      A, (IY+0AH)
    PUSH    DE
    LD      HL, TEST_SIGNAL_TABLE
    LD      D, 0
    LD      E, A
    ADD     HL, DE
    ADD     HL, DE
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    LD      HL, LOC_B186
    EX      (SP), HL
    EX      DE, HL
    JP      (HL)

TEST_SIGNAL_TABLE:   
    DW TEST_SOME_SIGNAL_00
    DW TEST_SOME_SIGNAL_02
    DW LOC_B06A
    DW TEST_SOME_SIGNAL_04
    DW TEST_SOME_SIGNAL_05
    DW TEST_AND_FREE_SIGNAL_01
    DW LOC_B0F8
    DW TEST_SOME_SIGNAL_06
    DW TEST_SOME_SIGNAL_07
    DW TEST_AND_FREE_SIGNAL_02

TEST_SOME_SIGNAL_00: 
    LD      A, (IY+0CH)
    CALL    TEST_SIGNAL
    CP      1
    JR      NZ, TEST_SOME_SIGNAL_01
    CALL    SUB_B28F

TEST_SOME_SIGNAL_01: 
    LD      A, (IY+0DH)
    CALL    TEST_SIGNAL
    CP      1
    JR      NZ, LOC_B048
    CALL    SUB_B28F

LOC_B048:
    CALL    SUB_B353
RET

TEST_SOME_SIGNAL_02: 
    LD      A, (IY+0CH)
    CALL    TEST_SIGNAL
    CP      1
    JR      NZ, TEST_SOME_SIGNAL_03
    CALL    SUB_B2B0

TEST_SOME_SIGNAL_03: 
    LD      A, (IY+0DH)
    CALL    TEST_SIGNAL
    CP      1
    JR      NZ, LOC_B066
    CALL    SUB_B2B0

LOC_B066:
    CALL    SUB_B353
RET

LOC_B06A:
    LD      A, (IY+0)
    AND     22H ; '"'
    OR      10H
    LD      C, A
    CALL    LOC_B247
    LD      (IY+0AH), 3
RET

TEST_SOME_SIGNAL_04: 
    LD      A, (IY+0CH)
    CALL    TEST_SIGNAL
    CP      1
    JR      NZ, LOCRET_B093
    LD      A, (IY+0)
    AND     22H ; '"'
    OR      18H
    LD      C, A
    CALL    LOC_B247
    LD      (IY+0AH), 4

LOCRET_B093:     
RET

TEST_SOME_SIGNAL_05: 
    LD      A, (IY+0CH)
    CALL    TEST_SIGNAL
    CP      1
    JR      NZ, LOCRET_B0AD
    LD      A, (IY+0)
    AND     22H ; '"'
    OR      14H
    LD      C, A
    CALL    LOC_B247
    LD      (IY+0AH), 5

LOCRET_B0AD:     
RET

TEST_AND_FREE_SIGNAL_01:  
    LD      A, (IY+0CH)
    CALL    TEST_SIGNAL
    CP      1
    JR      NZ, LOCRET_B0F7
    LD      (IY+0AH), 1
    LD      A, (IY+0)
    AND     22H ; '"'
    OR      8
    LD      C, A
    CALL    LOC_B247
    LD      A, (IY+0CH)
    CALL    FREE_SIGNAL
    LD      A, (IY+0DH)
    CALL    FREE_SIGNAL
    LD      HL, LOC_B368
    LD      E, (IY+0BH)
    LD      D, 0
    ADD     HL, DE
    ADD     HL, DE
    ADD     HL, DE
    PUSH    HL
    LD      L, (HL)
    LD      H, 0
    LD      A, 1
    CALL    REQUEST_SIGNAL
    LD      (IY+0CH), A
    POP     HL
    INC     HL
    LD      L, (HL)
    LD      H, 0
    LD      A, 1
    CALL    REQUEST_SIGNAL
    LD      (IY+0DH), A

LOCRET_B0F7:     
RET

LOC_B0F8:
    LD      A, (IY+0)
    AND     22H ; '"'
    OR      14H
    LD      C, A
    CALL    LOC_B247
    LD      (IY+0AH), 7
RET

TEST_SOME_SIGNAL_06: 
    LD      A, (IY+0CH)
    CALL    TEST_SIGNAL
    CP      1
    JR      NZ, LOCRET_B121
    LD      A, (IY+0)
    AND     22H ; '"'
    OR      18H
    LD      C, A
    CALL    LOC_B247
    LD      (IY+0AH), 8

LOCRET_B121:     
RET

TEST_SOME_SIGNAL_07: 
    LD      A, (IY+0CH)
    CALL    TEST_SIGNAL
    CP      1
    JR      NZ, LOCRET_B13B
    LD      A, (IY+0)
    AND     22H ; '"'
    OR      10H
    LD      C, A
    CALL    LOC_B247
    LD      (IY+0AH), 9

LOCRET_B13B:     
RET

TEST_AND_FREE_SIGNAL_02:  
    LD      A, (IY+0CH)
    CALL    TEST_SIGNAL
    CP      1
    JR      NZ, LOCRET_B185
    LD      (IY+0AH), 0
    LD      A, (IY+0)
    AND     22H ; '"'
    OR      0
    LD      C, A
    CALL    LOC_B247
    LD      A, (IY+0CH)
    CALL    FREE_SIGNAL
    LD      A, (IY+0DH)
    CALL    FREE_SIGNAL
    LD      HL, 0B368H
    LD      E, (IY+0BH)
    LD      D, 0
    ADD     HL, DE
    ADD     HL, DE
    ADD     HL, DE
    PUSH    HL
    LD      L, (HL)
    LD      H, 0
    LD      A, 1
    CALL    REQUEST_SIGNAL
    LD      (IY+0CH), A
    POP     HL
    INC     HL
    LD      L, (HL)
    LD      H, 0
    LD      A, 1
    CALL    REQUEST_SIGNAL
    LD      (IY+0DH), A

LOCRET_B185:     
RET

LOC_B186:
    LD      DE, 0AH
    ADD     IX, DE
    LD      DE, 0FH
    ADD     IY, DE
    POP     BC
    DEC     B
    JP      NZ, PLAY_BEAR_HIT
    JP      LOC_AF81

FREE_SOME_SIGNAL_A:  
    LD      IY, $735A
    LD      B, 3

LOOP_B19E:       
    PUSH    BC
    LD      A, (IY+0CH)
    CALL    FREE_SIGNAL
    LD      A, (IY+0DH)
    CALL    FREE_SIGNAL
    LD      DE, 0FH
    ADD     IY, DE
    POP     BC
    DJNZ    LOOP_B19E
    LD      B, 5
    CALL    SUB_9DC7
    LD      A, ($715F)
    CP      0
    JR      Z, LOCRET_B1D7
    LD      HL, $7269
    LD      A, ($7161)
    CP      1
    JR      Z, LOC_B1CC
    LD      HL, $726D

LOC_B1CC:
    LD      A, (HL)
    OR      A
    JR      Z, LOCRET_B1D7
    LD      HL, $7161
    LD      A, 1
    XOR     (HL)
    LD      (HL), A

LOCRET_B1D7:     
RET

UNK_B1D8:
	DB    2   
    DB    6
    DB    2
    DB    9
    DB    8
    DB    7
    DB    6
    DB    5
    DB    4
    DB    3

FILLING_SOME_VRAM:   
    LD      HL, 2000H
    ADD     HL, DE
    LD      DE, 20H
    LD      IX, FILL_VRAM
    CALL    SUB_A439
RET

SUB_B1F1:
    LD      HL, $7234
    BIT     5, (HL)
    JR      Z, LOCRET_B229
    RES     5, (HL)
    LD      HL, $7368
    LD      BC, $708E
    LD      A, (BC)
    CP      0A0H
	RET     NC
    CP      40H
    JR      NC, LOC_B20B
    LD      HL, $7377

LOC_B20B:
    CP      68H
    JR      Z, LOC_B214
    JR      C, LOC_B214
    LD      HL, $7386

LOC_B214:
    LD      (HL), 1
    LD      A, 5
    LD      ($7267), A
    PUSH    IX
    PUSH    IY
    CALL    SUB_A4BE
    CALL    PUT_OBJECT_10_A
    POP     IY
    POP     IX

LOCRET_B229:     
RET

SUB_B22A:
    LD      (IY+1), 10H
    LD      (IY+2), 0
    LD      (IY+6), 20H
    LD      (IY+7), 0
    LD      A, C
    LD      (IY+0), A
    XOR     1
    LD      (IY+5), A
    CALL    SUB_B353
RET

LOC_B247:
    LD      B, (IY+0)
    RES     5, B
    LD      (IY+0), C
    INC     C
    LD      (IY+5), C
    RES     5, C
    LD      A, B
    CP      10H
    JR      C, LOC_B276
    LD      A, C
    CP      10H
    JR      NC, LOC_B274
    LD      A, C
    CP      8
    JR      C, LOC_B26D
    CALL    SUB_B305
	RET     M
    EX      AF, AF'
    EX      AF, AF'
	RET     M
    JR      LOC_B274

LOC_B26D:
    CALL    SUB_B305
    NOP
    EX      AF, AF'
    DB  10H
    DB 0F8H

LOC_B274:
    JR      LOC_B28B

LOC_B276:
    LD      A, B
    CP      8
    JR      C, LOC_B284
    CALL    SUB_B305
    EX      AF, AF'
	RET     M
	RET     M
    EX      AF, AF'
    JR      LOC_B28B

LOC_B284:
    CALL    SUB_B305
    NOP
	RET     M
	RET     P
    EX      AF, AF'

LOC_B28B:
    CALL    SUB_B353
RET

SUB_B28F:
    LD      A, (IY+1)
    ADD     A, 1
    LD      (IY+1), A
    JR      NC, LOC_B29C
    INC     (IY+2)

LOC_B29C:
    LD      A, (IY+6)
    ADD     A, 1
    LD      (IY+6), A
    JR      NC, LOC_B2A9
    INC     (IY+7)

LOC_B2A9:
    CALL    SUB_B2D1
    CALL    SUB_B2E9
RET

SUB_B2B0:
    LD      A, (IY+1)
    ADD     A, 0FFH
    LD      (IY+1), A
    JR      C, LOC_B2BD
    DEC     (IY+2)

LOC_B2BD:
    LD      A, (IY+6)
    ADD     A, 0FFH
    LD      (IY+6), A
    JR      C, LOC_B2CA
    DEC     (IY+7)

LOC_B2CA:
    CALL    SUB_B2D1
    CALL    SUB_B2E9
RET

SUB_B2D1:
    BIT     1, (IY+1)
    JR      NZ, LOC_B2E0
    RES     2, (IY+0)
    RES     2, (IY+5)
RET

LOC_B2E0:
    SET     2, (IY+0)
    SET     2, (IY+5)
RET

SUB_B2E9:
    LD      B, (IY+2)
    LD      C, (IY+1)
    BIT     7, B
    JR      NZ, LOC_B2FC
    LD      HL, 100H
    OR      A
    SBC     HL, BC
	RET     NC
    JR      LOC_B300

LOC_B2FC:
    LD      A, C
    CP      0E0H
	RET     NC

LOC_B300:
    LD      (IY+0BH), 0
RET

SUB_B305:
    POP     DE
    LD      L, (IY+1)
    LD      H, (IY+2)
    CALL    SUB_B348
    LD      (IY+1), L
    LD      (IY+2), H
    INC     DE
    LD      L, (IY+3)
    LD      H, (IY+4)
    CALL    SUB_B348
    LD      (IY+3), L
    LD      (IY+4), H
    INC     DE
    LD      L, (IY+6)
    LD      H, (IY+7)
    CALL    SUB_B348
    LD      (IY+6), L
    LD      (IY+7), H
    INC     DE
    LD      L, (IY+8)
    LD      H, (IY+9)
    CALL    SUB_B348
    LD      (IY+8), L
    LD      (IY+9), H
    INC     DE
    EX      DE, HL
    JP      (HL)

SUB_B348:
    LD      A, (DE)
    LD      C, A
    LD      B, 0
    ADD     A, A
    JR      NC, LOC_B351
    LD      B, 0FFH

LOC_B351:
    ADD     HL, BC
RET

SUB_B353:
    PUSH    IY
    PUSH    IX
    PUSH    IX
    CALL    PUTOBJ
    POP     IX
    LD      DE, 5
    ADD     IX, DE
    CALL    PUTOBJ
    POP     IX

LOC_B368:
    POP     IY

LOCRET_B36A:     
RET

BEAR_SPRITE:
    DB    3   
    DB  1EH
    DB  10H
    DB    3
    DB  50H
    DB  0CH
    DB    2
    DB  0FH
    DB    8
    DB    2
    DB    6
    DB    6
    DB    2
    DB    3
    DB    5
    DB    1
    DB    3
    DB    3
    DB    1
    DB    1
    DB    1

OFF_B380:
	DW OFF_B39E            
    DW $735A
    DB    3
    DW OFF_B39E
    DW $735F
    DB    2

OFF_B38A:
	DW OFF_B39E            
    DW $7369
    DB    5
    DW OFF_B39E
    DW $736E
    DB    4

OFF_B394:
	DW OFF_B39E            
    DW $7378
    DB    7
    DW OFF_B39E
    DW $737D
    DB    6

OFF_B39E:
	DW $7803  
    DB    0
    DB    0
    DB    0
    DW UNK_B3A5

UNK_B3A5:
	DB  0FH   
    DB  10H
    DB  0FH
    DB  14H
    DB  0BH
    DB  10H
    DB  0BH
    DB  14H
    DB  0FH
    DB  18H
    DB  0FH
    DB  1CH
    DB  0BH
    DB  18H
    DB  0BH
    DB  1CH
    DB  0FH
    DB  28H
    DB  0FH
    DB  2CH
    DB  0BH
    DB  28H
    DB  0BH
    DB  2CH
    DB  0FH
    DB  30H
    DB  0FH
    DB  34H
    DB  0BH
    DB  30H
    DB  0BH
    DB  34H
    DB  0FH
    DB    0
    DB  0FH
    DB    4
    DB  0BH
    DB    0
    DB  0BH
    DB    4
    DB  0FH
    DB  20H
    DB  0FH
    DB  24H
    DB  0BH
    DB  20H
    DB  0BH
    DB  24H
    DB  0FH
    DB    8
    DB  0FH
    DB  0CH
    DB  0BH
    DB    8
    DB  0BH
    DB  0CH
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    0
    DB    7
    DB  10H
    DB    7
    DB  14H
    DB  0BH
    DB  10H
    DB  0BH
    DB  14H
    DB    7
    DB  18H
    DB    7
    DB  1CH
    DB  0BH
    DB  18H
    DB  0BH
    DB  1CH
    DB    7
    DB  28H
    DB    7
    DB  2CH
    DB  0BH
    DB  28H
    DB  0BH
    DB  2CH
    DB    7
    DB  30H
    DB    7
    DB  34H
    DB  0BH
    DB  30H
    DB  0BH
    DB  34H
    DB    7
    DB    0
    DB    7
    DB    4
    DB  0BH
    DB    0
    DB  0BH
    DB    4
    DB    7
    DB  20H
    DB    7
    DB  24H
    DB  0BH
    DB  20H
    DB  0BH
    DB  24H
    DB    7
    DB    8
    DB    7
    DB  0CH
    DB  0BH
    DB    8
    DB  0BH
    DB  0CH

INIT_SOUND_AND_VRAM: 
    PUSH    BC
    PUSH    HL
    CALL    INITIALIZE_SOUND
    CALL    WRITER
    CALL    INIT_PATTERN_TABLES
    CALL    LOAD_ASCII
    CALL    CLEAR_SCREEN_WITH_FF
    CALL    CLEAR_VRAM_AT_2800_WITH_0
    LD      HL, 2300H
    LD      DE, 20H
    LD      A, 0F0H
    CALL    FILL_VRAM
    POP     HL
    POP     BC
    PUSH    BC
    LD      DE, 2167H
    CALL    WRITE_VRAM
    POP     BC
    LD      A, ($7161)
    CP      0
    JR      Z, LOC_B45D
    LD      HL, 2167H
    ADD     HL, BC
    DEC     HL
    LD      D, H
    LD      E, L
    LD      HL, UNK_B464
    LD      BC, 1
    CALL    WRITE_VRAM

LOC_B45D:
    LD      HL, 0B4H
    CALL    REQUEST_TEST_AND_FREE_SIGNAL
RET

UNK_B464:
	DB  32H

SETUP_PATTERNS_IN_VRAM:   
    LD      B, 3
    LD      IX, COLORS_A    ; COLORS ENCODED FOR SPACE
    LD      IY, SPRITE_PATS_A
    LD      HL, 0
    CALL    PATTERNS_TO_VRAM
    LD      IX, COLORS_A
    LD      IY, SPRITE_PATS_A
    LD      HL, 800H
    CALL    PATTERNS_TO_VRAM
    LD      IX, COLORS_A
    LD      IY, SPRITE_PATS_A
    LD      HL, 1000H
    CALL    PATTERNS_TO_VRAM
    LD      IX, COLORS_A
    LD      IY, SPRITE_PATS_A
    LD      HL, 1800H
    CALL    PATTERNS_TO_VRAM
    LD      IX, COLORS_B
    LD      IY, SPRITE_PATS_B
    LD      HL, 3000H
    CALL    PATTERNS_TO_VRAM
RET

SPRITE_PATS_A:
	DB 112,136,152,168,200,136,112,000
    DB 032,096,032,112,000,112,136,008
    DB 048,064,128,248,000,248,008,016
    DB 048,008,136,112,000,016,048,080
    DB 144,248,016,016,000,248,128,240
    DB 008,008,136,112,000,056,064,128
    DB 240,136,136,112,000,248,008,016
    DB 032,064,000,112,136,136,112,136
    DB 136,112,000,112,136,136,120,008
    DB 016,224,000,000,255,255,000,024
    DB 024,126,126,024,024,000,000,255
    DB 255,000,255,000,034,034,119,119
    DB 000,000,255,000,032,032,112,112
    DB 000,000,255,000,112,072,112,072
    DB 072,120,000,000,252,198,198,252
    DB 198,198,252,000,120,072,120,000
    DB 000,124,198,124,000,072,104,104
    DB 120,088,072,000,000,198,230,246
    DB 254,222,206,198,000,072,120,000
    DB 000,198,124,056,000,120,064,120
    DB 008,008,120,000,063,063,048,000
    DB 000,255,255,000,252,252,012,048
    DB 012,048,063,063,000,255,255,000
    DB 000,012,252,252,000,000,062,096
    DB 126,063,003,099,062,000,030,051
    DB 096,051,030,000,062,099,062,000
    DB 126,099,126,108,102,000,127,096
    DB 096,124,096,096,127,000,000,030
    DB 051,096,103,099,051,031,000,028
    DB 054,099,099,127,099,099,000,099
    DB 119,127,107,099,000,127,096,096
    DB 124,096,096,127,000,062,099,062
    DB 000,099,054,028,008,000,127,096
    DB 096,124,096,096,127,000,126,099
    DB 126,108,103,000,126,126,000,255
    DB 255,000,102,231,255,090,126,102
    DB 060,024,000,034,034,119,119,000
    DB 032,032,112,112,000,000,255,255
    DB 000,063,063,048,055,054,055,255
    DB 255,000,231,049,225,255,255,000
    DB 239,140,143,255,255,000,207,108
    DB 108,111,204,255,255,000,231,014
    DB 015,135,000,252,252,012,204,012
    DB 204,236,108,054,054,048,001,007
    DB 000,140,236,000,012,015,000,012
    DB 231,000,108,204,012,048,063,063
    DB 000,255,255,000,000,012,252,252
    DB 000,007,003,000,252,255,015,000
    DB 048,240,224,096,112,048,012,014
    DB 006,007,015,012,000,240,255,063
    DB 000,192,224,001,001,003,000,224
    DB 192,000,015,000,255,255,048,048
    DB 096,240,176,013,015,006,012,012
    DB 255,255,000,240,000,003,007,000
    DB 192,128,128,000,001,001,000,192
    DB 240,003,000,224,192,240,254,031
    DB 003,000,000,003,003,006,014,140
    DB 204,248,120,030,031,051,049,112
    DB 096,192,192,000,000,192,248,127
    DB 015,003,007,000,192,015,003,000
    DB 128,128,000,001,003,007,014,028
    DB 056,112,224,252,252,126,062,028
    DB 008,000,000,192,192,096,096,048
    DB 048,024,012,012,006,006,003,003
    DB 000,000,016,056,124,126,063,000
    DB 007,014,028,056,112,224,192,000
    DB 004,030,063,255,000,128,195,207
    DB 126,120,048,048,024,024,239,135
    DB 003,000,128,128,000,001,001,000
    DB 192,225,247,024,024,012,012,030
    DB 126,243,195,001,000,255,252,120
    DB 032,000,192,192,096,096,048,049
    DB 031,031,000,000,003,015,063,251
    DB 225,001,000,000,192,192,224,000
    DB 003,000,128,048,112,096,112,048
    DB 012,014,006,014,012,001,000,192
    DB 000,007,003,003,000,000,128,135
    DB 223,252,240,192,000,000,248,248
    DB 140,012,006,006,003,003,000,003
    DB 031,127,096,000,252,254,006,192
    DB 192,000,003,003,000,192,192,000
    DB 003,003,096,127,031,000,006,254
    DB 248,192,000,031,127,096,003,007
    DB 007,006,006,254,254,006,096,127
    DB 127,096,096,224,224,000,006,254
    DB 248,000,248,254,007,000,028,024
    DB 056,112,096,224,192,003,007,006
    DB 014,028,024,056,000,224,127,031
    DB 000,015,063,126,124,124,062,015
    DB 007,128,000,128,003,000,195,227
    DB 118,062,028,012,024,048,056,124
    DB 110,199,195,000,192,001,000,224
    DB 240,124,062,062,126,252,000,096
    DB 112,056,024,028,012,014,006,007
    DB 003,006,014,012,012,024,048,048
    DB 112,096,192,224,096,112,048,056
    DB 024,028,014,000,192,224,224,096
    DB 096,127,127,096,006,254,254,006
    DB 006,007,007,000,192,192,000,003
    DB 012,003,003,192,192,048,192,192
    DB 000,031,127,096,003,003,006,014
    DB 012,012,024,024,192,192,000,048
    DB 112,096,112,048,024,024,012,012
    DB 014,006,003,003,000,192,192,096
    DB 127,031,000,248,254,006,003,003
    DB 000,192,192,096,112,048,048,024
    DB 024,012,014,006,014,012,024,024
    DB 048,048,112,096,192,192,000,003
    DB 003,006,254,248,000,049,122,236
    DB 254,125,056,024,188,254,222,198
    DB 126,060,032,032,060,000,140,094
    DB 055,127,190,028,024,061,127,123
    DB 099,126,060,004,004,060,000,076
    DB 088,048,048,060,054,063,030,060
    DB 126,127,121,120,240,254,063,000
    DB 050,026,012,012,060,108,252,120
    DB 060,126,254,158,030,015,127,254
    DB 000,129,126,255,201,201,255,118
    DB 255,189,060,102,000,129,126,255
    DB 147,147,255,110,255,189,060,102
    DB 000,056,036,036,056,036,036,060
    DB 000,056,036,036,056,036,036,060
    DB 000,060,036,060,000,060,036,060
    DB 000,036,052,060,044,044,000,036
    DB 052,060,044,044,000,036,060,000
    DB 036,060,000,060,032,032,060,004
    DB 004,060,000,060,032,032,060,004
    DB 004,060,000,255,195,223,195,251
    DB 251,195,255,000,255,195,223,195
    DB 251,251,195,255,000,255,209,149
    DB 213,209,255,000,255,209,149,213
    DB 209,255,000

COLORS_A:
	DB 010,132,046,131,020,134,010,134,017,134,017,132,004,133,018,133,003,133,009,252,002,132,004,134,002,132,136,136,132,002,134,004
    DB 132,014,131,004,133,003,131,033,131,010,133,002,132,013,131,003,131,002,132,002,133,008,131,004,132,008,173,004,131,005,131,005
    DB 131,027,134,002,134,002,134,002,134,002,134,002,134,132,002,134,004,132,002,138,002,134,003,133,003,131,004,131,003,133,003,134
    DB 004,131,131,132,001,132,135,134,004,132,004,132,004,134,135,131,001,133,131,131,002,134,002,132,001,131,131,133,032,133,131,131
    DB 001,132,002,182,022,132,021,133,004,135,012,133,002,140,002,133,012,135,004,132,020,132,135,001,135,003,132,004,132,003,135,001
    DB 135,132,020,160,133,003,133,005,134,002,140,002,134,005,133,003,132,134,022,138,022,133,009,134,002,135,006,132,006,135,002,135
    DB 022,132,032,140,132,132,004,132,002,133,013,134,002,132,010,134,005,138,005,134,010,132,010,134,005,133,016,144,016,144,016,144
    DB 016,144,007,134,003,144,007,134,003,144,007,137,007,137,001,133,001,137,001,133,001,137,001,131,003,137,001,131,003,137,134,001
    DB 137,134,001,137,007,137,007,137,008,136,008,136,003,131,002,136,003,131,002,168,000

SPRITE_PATS_B:
	DB 032,048,056,063,095,000,032,000
    DB 145,077,042,020,092,141,026,036
    DB 000,068,042,004,028,012,018,032
    DB 000,004,002,020,012,000,018,000
    DB 255,231,235,237,239,143,159,255
    DB 000,255,255,195,255,255,000,012
    DB 022,126,029,015,031,014,006,003
    DB 000,243,255,254,252,216,048,224
    DB 000,044,054,030,061,047,031,014
    DB 006,003,001,000,243,255,254,252
    DB 216,048,224,000,024,044,252,060
    DB 015,031,015,007,003,001,000,003
    DB 255,254,220,216,240,224,224,112
    DB 000,024,044,252,061,015,031,015
    DB 007,003,001,000,014,028,056,120
    DB 240,243,247,238,252,248,240,224
    DB 000,207,255,127,055,027,012,007
    DB 000,040,104,126,184,244,248,112
    DB 096,192,128,000,207,255,127,055
    DB 027,012,007,000,052,108,120,188
    DB 244,248,112,096,192,128,000,192
    DB 191,127,059,027,015,007,007,014
    DB 000,024,052,063,060,240,248,240
    DB 224,192,128,000,112,056,028,030
    DB 015,207,239,119,063,031,015,007
    DB 000,024,052,063,188,240,248,240
    DB 224,192,128,000,019,021,015,023
    DB 019,015,031,063,059,049,037,056
    DB 000,002,006,142,158,060,250,246
    DB 238,254,252,252,248,224,000,192
    DB 225,115,063,061,030,014,015,007
    DB 003,001,001,000,001,003,142,222
    DB 092,252,248,247,239,238,254,252
    DB 252,120,120,112,192,224,185,191
    DB 030,031,015,007,007,003,001,003
    DB 003,135,205,253,184,120,112,224
    DB 224,192,128,192,000,000,064,096
    DB 113,121,060,095,111,119,127,063
    DB 063,031,007,000,200,168,240,232
    DB 200,240,248,252,220,140,164,028
    DB 000,128,192,113,123,058,063,031
    DB 239,247,119,127,063,063,030,030
    DB 014,003,135,206,252,188,120,112
    DB 240,224,192,128,128,000,124,198
    DB 124,000,048,112,112,048,252,000
    DB 124,134,014,060,112,224,254,000
    DB 254,012,024,060,006,198,124,000
    DB 028,060,108,204,254,012,012,000
    DB 254,192,252,126,006,006,252,000
    DB 062,096,192,252,198,198,124,000
    DB 254,198,012,024,048,096,096,000
    DB 124,198,198,124,198,198,124,000
    DB 124,198,198,126,012,024,112,000
    DB 001,001,003,003,007,007,015,012
    DB 027,023,044,044,247,251,216,248
    DB 240,235,252,188,216,128,224,245
    DB 110,191,220,210,176,096,124,063
    DB 031,028,030,031,000,192,128,000
    DB 004,167,117,231,103,123,125,062
    DB 063,060,027,023,054,054,055,059
    DB 032,229,174,231,230,222,190,124
    DB 252,060,216,232,108,108,236,220
    DB 060,063,031,014,030,000,060,252
    DB 248,112,120,000,001,007,015,030
    DB 125,253,253,125,126,063,063,029
    DB 028,028,030,031,252,255,015,247
    DB 251,155,155,251,247,015,255,247
    DB 007,108,248,212,252,254,246,252
    DB 248,192,128,128,000,128,192,000
    DB 001,007,015,030,061,125,253,253
    DB 126,031,031,063,126,119,051,026
    DB 252,255,015,247,251,155,155,251
    DB 247,015,254,255,031,187,059,029
    DB 108,248,212,252,254,246,252,248
    DB 128,000,192,128,000,027,031,015
    DB 023,063,061,027,001,007,175,118
    DB 253,203,075,013,006,000,000,128
    DB 128,192,192,224,224,240,048,216
    DB 232,052,052,238,222,003,001,000
    DB 062,252,240,048,112,240,000,054
    DB 031,043,063,127,111,063,031,003
    DB 001,001,000,001,003,063,255,240
    DB 239,223,217,217,223,239,240,255
    DB 239,224,128,224,240,120,190,191
    DB 191,190,126,252,252,184,056,056
    DB 120,248,000,054,031,043,063,127
    DB 111,063,031,001,000,003,001,000
    DB 063,255,240,239,223,217,217,223
    DB 239,240,127,255,248,221,220,184
    DB 128,224,240,120,188,190,191,191
    DB 126,248,248,252,126,238,204,088
    DB 000,076,094,119,055,127,094,076
    DB 000,012,030,055,247,255,030,012
    DB 000

COLORS_B:
	DB 001,132,003,154,134,152,008,153,007,153,006,153,008,152,002,132,002,156,009,138,007,134,010,137,007,134,010,137,009,132,010,132
    DB 012,137,007,134,010,137,007,134,010,137,009,132,010,132,012,134,010,133,012,131,026,132,025,133,011,133,017,132,041,132,001,133
    DB 001,153,003,131,001,153,007,153,007,153,007,153,007,153,007,153,007,153,007,153,007,155,033,131,002,136,002,142,035,132,001,136
    DB 003,132,001,136,028,132,011,131,002,144,041,132,002,145,034,142,003,131,002,136,011,131,014,132,016,144,009,132,035,144,007,153
    DB 007,153,000

PATTERNS_TO_VRAM:
    LD      ($7387), IX
    LD      ($7389), IY
    LD      ($738B), HL

LOOP_TILL_ZERO:  
    LD      IX, ($7387)
    LD      A, (IX+0)
    CP      0
    JP      Z, LOCRET_BDD0
    LD      A, (IX+0)
    AND     80H
    JP      Z, LOC_BD88
    LD      A, (IX+0)
    AND     7FH
    LD      E, A
    LD      D, 0
    LD      IY, ($7389)
    LD      A, (IY+0)
    LD      HL, ($738B)
    CALL    FILL_VRAM
    LD      HL, ($7389)
    INC     HL
    LD      ($7389), HL
    JP      LOC_BDB2

LOC_BD88:
    LD      A, (IX+0)
    AND     7FH
    LD      C, A
    LD      B, 0
    LD      HL, ($7389)
    LD      DE, ($738B)
    CALL    WRITE_VRAM
    LD      HL, ($7389)
    LD      IX, ($7387)
    LD      A, (IX+0)
    AND     7FH
    ADD     A, L
    LD      L, A
    LD      A, 0
    ADC     A, H
    LD      H, A
    LD      ($7389), HL
    JP      LOC_BDB2

LOC_BDB2:
    LD      IX, ($7387)
    LD      HL, ($738B)
    LD      A, (IX+0)
    AND     7FH
    ADD     A, L
    LD      L, A
    LD      A, 0
    ADC     A, H
    LD      H, A
    LD      ($738B), HL
    INC     IX
    LD      ($7387), IX
    JP      LOOP_TILL_ZERO

LOCRET_BDD0:     
RET



PADDING:
	DB 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
    DB 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
    DB 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
    DB 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
    DB 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
    DB 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
    DB 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
    DB 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
    DB 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
    DB 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
    DB 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
    DB 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
    DB 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
    DB 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255















