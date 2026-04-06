; DISASSEMBLY OF SLITHER BY CAPTAIN COSMOS
; 100 HUNDRED PERCENT ALL LINKS RESOLVED.
; I SPENT A LOT OF TIME WORKING ON THIS AND IT WOULD SUCK 100% IF SOMEONE USED MY WORK TO MAKE MONEY.
; THIS WAS DONE FOR EDUCATIONAL PURPOSES ONLY AND ALL CREDIT GOES TO ME AND ME ONLY.
; STARTED SOMETIME IN OCTOBER 2023
; COMPLETED ON 29 OCTOBER, 2023 (TECHNICALLY NOT COMPLETED...COMPLETED)  THERE CAN ALWAYS BE MORE DONE SUCH AS OPTIMIZE CODE, CHANGE MEMORY LOCATIONS.



; BIOS DEFINITIONS **************************

NUMBER_TABLE:        EQU $006C
PLAY_SONGS:          EQU $1F61
REFLECT_VERTICAL:    EQU $1F6A
REFLECT_HORZONTAL:   EQU $1F6D
GAME_OPT:            EQU $1F7C
FILL_VRAM:           EQU $1F82
MODE_1:              EQU $1F85
UPDATE_SPINNER:      EQU $1F88
INIT_TABLE:          EQU $1FB8
GET_VRAM:            EQU $1FBB
PUT_VRAM:            EQU $1FBE
TURN_OFF_SOUND:      EQU $1FD6
WRITE_REGISTER:      EQU $1FD9
READ_REGISTER:       EQU $1FDC
WRITE_VRAM:          EQU $1FDF
READ_VRAM:           EQU $1FE2
POLLER:              EQU $1FEB
SOUND_INIT:          EQU $1FEE
PLAY_IT:             EQU $1FF1
SOUND_MAN:           EQU $1FF4
RAND_GEN:            EQU $1FFD

SPRITE_NAME_TABLE:   EQU $0000
SPRITE_ORDER_TABLE:  EQU $0000
WORK_BUFFER:         EQU $7243
CONTROLLER_BUFFER:   EQU $7000

; SOUND DEFINITIONS *************************
PTERODACTYL_SND:       EQU $01
START_MELODY_A:        EQU $02
START_MELODY_B:        EQU $03
START_MELODY_C:        EQU $04
PLAYER_DEATH_SND_A:    EQU $05
PLAYER_DEATH_SND_B:    EQU $06
PLAYER_DEATH_SND_C:    EQU $07
END_MELODY_A:          EQU $08
END_MELODY_B:          EQU $09
END_MELODY_C:          EQU $0A
LASER_SND:             EQU $0B
TYRRANOSAUR_SND_A:     EQU $0C
TYRRANOSAUR_SND_B:     EQU $0D
EXTRA_PLAYER_SND:      EQU $0E
PTERODACTYL_HIT_SND_A: EQU $0F
SNAKES_SLITHER_SND_A:  EQU $10
SNAKES_SLITHER_SND_B:  EQU $11
TYRRANOSAUR_HIT_SND_A: EQU $12
TYRRANOSAUR_HIT_SND_B: EQU $13
PTERODACTYL_HIT_SND_B: EQU $14
PAUSE_MELODY_A:        EQU $1B
PAUSE_MELODY_B:        EQU $1C
PAUSE_MELODY_C:        EQU $1D
PAUSE_MELODY_D:        EQU $1E


FNAME "SLITHER V1.ROM"
CPU Z80

    ORG $8000

    DW $AA55
    DW 0
    DW 0
	DW WORK_BUFFER
	DW CONTROLLER_BUFFER ;CONTROLLER_BUFFER
	DW START

	JP      LOC_9683
	JP      SUB_96D6
	JP      SUB_96A7
	JP      0
	JP      0
	JP      0
	JP      UPDATE_ROLLER_CONTROLLER
	JP      NMI

	DB "BY CENTURY II"
	DB "/PRESENTS SLITHER ",1EH,1FH,"/1983"

START:
    LD      ($700C), SP
LOC_804E:
    DI
    IM      1
    LD      SP, ($700C)
    JP      INIT_GET_OPTIONS
INIT_GET_OPTIONS:
    CALL    INIT_SOUNDS_REGISTER_PROTECTED
    CALL    GAME_OPT
    LD      HL, CONTROLLER_BUFFER
    LD      (HL), 90H
    LD      HL, $7001
    LD      (HL), 90H
BLUE_SCREEN:     
    LD      BC, 1E2H
    CALL    WRITE_REGISTER
    LD      BC, 704H
    CALL    WRITE_REGISTER
    LD      HL, 1C20H
    LD      (WORK_BUFFER), HL
BLACK_SCREEN:    
    CALL    RANDOM_TILL_END_OF_TIMER
    LD      HL, (WORK_BUFFER)
    DEC     HL
    LD      (WORK_BUFFER), HL
    LD      A, H
    OR      L
    JR      NZ, LOC_8094
    LD      BC, 1A2H
    CALL    WRITE_REGISTER
    LD      BC, 701H
    CALL    WRITE_REGISTER
LOC_8094:
    CALL    CALL_POLLER_REGISTER_PROTECTED
    LD      IY, CONTROLLER_BUFFER
    LD      A, (IY+6)
    OR      A
    JR      Z, LOC_80AD
    CP      9
    JR      C, LOC_80BF
    CP      0AH
    JR      Z, BLUE_SCREEN
    CP      0BH
    JR      Z, BLUE_SCREEN
LOC_80AD:
    LD      A, (IY+0BH)
    OR      A
    JR      Z, BLACK_SCREEN
    CP      0AH
    JR      Z, BLUE_SCREEN
    CP      0BH
    JR      Z, BLUE_SCREEN
    CP      9
    JR      NC, BLACK_SCREEN
LOC_80BF:
    LD      ($700E), A
LOC_80C2:
    LD      A, ($700E)
    CP      5
    JR      NC, LOC_8110
    LD      IX, $7078
    LD      (IX+0), 4
    LD      (IX+1), 1
    LD      (IX+2), A
    LD      (IX+0EH), 0AH
    CALL    SUB_80EE
    LD      HL, BYTE_BF89
    LD      (IX+3), L
    LD      (IX+4), H
    LD      (IX+0DH), 1
    JR      BLANK_SCREEN_UPDATE

SUB_80EE:
    LD      IY, BYTE_BF7D
    SUB     1
    LD      B, 3
    LD      C, A
    XOR     A
LOC_80F8:
    ADD     A, C
    DJNZ    LOC_80F8
    LD      B, 0
    LD      C, A
    ADD     IY, BC
    PUSH    IY
    POP     HL
    LD      (IX+5), L
    LD      (IX+6), H
    LD      A, (IY+2)
    LD      (IX+0AH), A
RET

LOC_8110:
    LD      IX, $7078
    LD      (IX+0), 0DH
    LD      (IX+1), 1
    SUB     4
    LD      (IX+2), A
    LD      (IX+0EH), 0AH
    PUSH    AF
    CALL    SUB_80EE
    POP     AF
    LD      HL, $7087
    LD      (IX+0BH), L
    LD      (IX+0CH), H
    LD      HL, BYTE_BF89
    LD      (IX+3), L
    LD      (IX+4), H
    LD      (IX+0DH), 1
    LD      IX, $7087
    LD      (IX+0), 0FH
    LD      (IX+1), 1
    LD      (IX+2), A
    LD      (IX+0EH), 0AH
    CALL    SUB_80EE
    LD      HL, $7078
    LD      (IX+0BH), L
    LD      (IX+0CH), H
    LD      HL, BYTE_BF89
    LD      (IX+3), L
    LD      (IX+4), H
    LD      (IX+0DH), 1
BLANK_SCREEN_UPDATE:
    LD      HL, $707F
    LD      (HL), 0
    INC     HL
    LD      (HL), 0
    INC     HL
    LD      (HL), 0
    LD      HL, $708E
    LD      (HL), 0
    INC     HL
    LD      (HL), 0
    INC     HL
    LD      (HL), 0
    LD      IX, $7078
    LD      ($7072), IX
    LD      HL, $7142
    LD      (HL), 0
    CALL    INITIALIZE_VRAM
    CALL    INIT_DAY_TIME
    CALL    INIT_PATTERNS
    LD      BC, 182H
    CALL    WRITE_REGISTER
UPPER_SCREEN_DAYTIME:
    LD      SP, ($700C)
    LD      BC, 182H
    CALL    WRITE_REGISTER
    LD      HL, $7096
    LD      BC, 1ACH
    LD      DE, $7097
    LD      (HL), 0
    LDIR
    LD      A, 2
    LD      ($70C1), A
    LD      A, 1
    LD      ($7141), A
    CALL    INITIALIZE_VRAM
    PUSH    IX
    LD      IX, ($7072)
    LD      A, (IX+3)
    LD      L, A
    LD      A, (IX+4)
    LD      H, A
    PUSH    HL
    POP     IY
    BIT     3, (IY+0DH)
    JP      NZ, LOC_82F2
    XOR     A
    LD      ($70AA), A
    CALL    INIT_DAY_TIME
LOC_81E1:
    CALL    DRAW_MIDDLE_AND_BOTTOM
    LD      BC, 1A2H
    CALL    WRITE_REGISTER
    CALL    INIT_PATTERNS
    CALL    INIT_SPRITES
    LD      HL, SOME_DATA_TO_RAM
    LD      DE, $70C2
    LD      BC, 58H
    LDIR
    PUSH    IX
    LD      IX, ($7072)
    RES     6, (IX+0)
    LD      A, ($70AA)
    CP      0
    JR      Z, INIT_CONTROLLER_FOR_SPINNERS
    LD      A, 1
    LD      ($70E9), A
INIT_CONTROLLER_FOR_SPINNERS:
    POP     IX
    CALL    SUB_9D95
    CALL    CLEAR_SCREEN
    CALL    DRAW_HUD_00
    CALL    SET_TIME_OF_DAY
    CALL    SUB_BE4E
    CALL    SUB_BEAA
    LD      A, 0FH
    LD      ($70A3), A
    CALL    UPDATE_SCORE_C
    LD      HL, CONTROLLER_BUFFER
    LD      (HL), 9DH
    LD      HL, $7001
    LD      (HL), 9DH
    EI
    LD      BC, 1E2H
    CALL    WRITE_REGISTER
    CALL    READ_REGISTER
    CALL    PLAY_START_MELODY
    LD      B, 0B4H
LOOP_8246:       
    PUSH    BC
    CALL    RANDOM_TILL_END_OF_TIMER
    CALL    UPDATE_SOUNDS_REGISTER_PROTECTED
    POP     BC
    DJNZ    LOOP_8246
    CALL    CALL_POLLER_REGISTER_PROTECTED
    CALL    CALL_POLLER_REGISTER_PROTECTED
    CALL    INIT_SOUNDS_REGISTER_PROTECTED
    CALL    PLAY_SNAKES_SLITHER_SOUND
    XOR     A
    LD      ($7004), A
    LD      ($7009), A
MAIN_LOOP:       
    CALL    RANDOM_TILL_END_OF_TIMER
    CALL    CALL_POLLER_REGISTER_PROTECTED
    CALL    ROLLER_CONTROLLER_UPDATE
    CALL    SUB_9D95
    LD      A, ($723E)
    CP      0FFH
    JP      Z, CHECK_COLLISIONS
    CALL    UPDATE_SOUNDS_REGISTER_PROTECTED
    CALL    SUB_8882
    CALL    SUB_8D19
    CALL    SOME_CONTROLLER_CHECK
    CALL    SUB_8EF7
    CALL    SUB_A3A9
    CALL    SUB_A3A9
    CALL    SUB_A3A9
    CALL    SUB_BE4E
    CALL    CHECK_IF_ALL_SNAKES_ARE_DEAD
    CALL    RANDOM_TILL_END_OF_TIMER
    CALL    CALL_POLLER_REGISTER_PROTECTED
    CALL    ROLLER_CONTROLLER_UPDATE
    CALL    SUB_9D95
    LD      A, ($723E)
    CP      0FFH
    JR      Z, CHECK_COLLISIONS
    CALL    UPDATE_SOUNDS_REGISTER_PROTECTED
    CALL    SUB_8882
    CALL    SUB_8D19
    CALL    SOME_CONTROLLER_CHECK
    CALL    SUB_8EF7
    CALL    SUB_A3A9
    CALL    SUB_A3A9
    CALL    SUB_A3A9
    JP      MAIN_LOOP

FLASH_SCREEN_RED:
    PUSH    IX
    LD      IX, ($7072)
    LD      A, (IX+1)
    POP     IX
    CP      3
    JR      Z, FLASH_SCREEN_BLUE
    CP      6
    JR      Z, FLASH_SCREEN_BLUE
    CP      8
    JR      Z, FLASH_SCREEN_BLUE
    LD      BC, 706H
    CALL    WRITE_REGISTER
    LD      A, 4
    LD      ($70E9), A
RET
FLASH_SCREEN_BLUE:  
    LD      BC, 704H
    CALL    WRITE_REGISTER
    LD      A, 1
    LD      ($70E9), A
RET

LOC_82F2:
    LD      A, 1
    LD      ($70AA), A
    CALL    INIT_NIGHT_TIME
    JP      LOC_81E1
CHECK_COLLISIONS:
    CALL    SUB_BE4E
    XOR     A
    LD      ($723E), A
    PUSH    IX
    PUSH    IY
    LD      HL, ($7072)
    BIT     1, (HL)
    JR      Z, CHECK_FOR_COLLISION_00
    LD      IX, (WORD_86B7)
    LD      IY, $7075
    JR      CHECK_FOR_COLLISION_01
CHECK_FOR_COLLISION_00:      
    LD      IX, (WORD_86B5)
    LD      IY, $7074
CHECK_FOR_COLLISION_01:      
    LD      B, 14H
    LD      (IY+0), 0
    LD      DE, 1880H
READ_VRAM_FOR_COLLISION:     
    LD      HL, $71DC
    PUSH    BC
    LD      BC, 20H
    PUSH    IX
    PUSH    IY
    PUSH    HL
    PUSH    DE
    CALL    READ_VRAM
    POP     DE
    POP     HL
    POP     IY
    POP     IX
    LD      B, 20H
CHECK_FOR_COLLISION_02:      
    PUSH    DE
    LD      A, (HL)
    CP      6AH
    JR      Z, WRITE_VRAM_FOR_COLLISIONS
    CP      6BH
    JR      NZ, CHECK_FOR_COLLISION_03
WRITE_VRAM_FOR_COLLISIONS:   
    LD      A, D
    LD      ($7183), A
    LD      A, E
    LD      ($7182), A
    INC     (IY+0)
    PUSH    HL
    PUSH    IX
    LD      HL, $7182
    POP     DE
    PUSH    BC
    PUSH    IX
    PUSH    IY
    LD      BC, 2
    CALL    WRITE_VRAM
    POP     IY
    POP     IX
    POP     BC
    POP     HL
    INC     IX
    INC     IX
CHECK_FOR_COLLISION_03:      
    POP     DE
    INC     DE
    INC     HL
    DJNZ    CHECK_FOR_COLLISION_02
    POP     BC
    DJNZ    READ_VRAM_FOR_COLLISION
    POP     IY
    POP     IX
    CALL    INIT_SOUNDS_REGISTER_PROTECTED
    LD      IX, $710A
    LD      HL, ($70C2)
    LD      ($710A), HL
    LD      ($7116), HL
    LD      ($7122), HL
    LD      ($712E), HL
    LD      (IX+2), 2CH
    LD      (IX+0EH), 30H
    LD      (IX+1AH), 34H
    LD      (IX+26H), 38H
    LD      A, 0BFH
    LD      ($70C2), A
    LD      ($70CE), A
    LD      ($70DA), A
    LD      A, 0DH
    LD      ($70B6), A
    CALL    PLAY_PLAYER_DEATH_SOUND
    LD      A, 0B4H
    LD      ($70C7), A
    LD      IX, $70C2
FINISH_FOR_COLLISIONS_00:    
    LD      A, ($70B6)
    DEC     A
    CP      3
    CALL    Z, FINISH_FOR_COLLISIONS_02
    LD      (IX+6), A
    LD      ($70B6), A
FINISH_FOR_COLLISIONS_01:    
    CALL    RANDOM_TILL_END_OF_TIMER
    CALL    UPDATE_SOUNDS_REGISTER_PROTECTED
    PUSH    IX
    CALL    SUB_A3A9
    CALL    SUB_A3A9
    CALL    SUB_A3A9
    POP     IX
    DEC     (IX+5)
    JR      Z, INITIALIZE_SOMETHING
    DEC     (IX+6)
    JR      NZ, FINISH_FOR_COLLISIONS_01
    CALL    GET_RANDOM_NUMBER
    LD      ($710D), A
    CALL    GET_RANDOM_NUMBER
    LD      ($7119), A
    CALL    GET_RANDOM_NUMBER
    LD      ($7125), A
    CALL    GET_RANDOM_NUMBER
    LD      ($7131), A
    CALL    SUB_9D95
    JP      FINISH_FOR_COLLISIONS_00

FINISH_FOR_COLLISIONS_02:    
    LD      A, 4
    LD      ($70B6), A
RET

GET_RANDOM_NUMBER:  
    CALL    RAND_GEN
    AND     0FH
    CP      2
    CALL    C, FINISH_GET_RANDOM_NUMBER
    CP      0AH
    CALL    Z, FINISH_GET_RANDOM_NUMBER
RET

FINISH_GET_RANDOM_NUMBER:    
    ADD     A, 2
RET

INITIALIZE_SOMETHING:
    CALL    INIT_SOUNDS_REGISTER_PROTECTED
    LD      BC, 1E2H
    CALL    WRITE_REGISTER
    LD      HL, CONTROLLER_BUFFER
    LD      (HL), 90H
    LD      HL, $7001
    LD      (HL), 90H
    LD      A, 0D0H
    LD      DE, 1
    LD      HL, 1F00H
    CALL    FILL_VRAM
    LD      IX, ($7072)
    BIT     0, (IX+0)
    JP      NZ, LOC_845A
    LD      A, (IX+0AH)
    DEC     A
    LD      (IX+0AH), A
    JP      Z, LOC_85C9
    JP      UPPER_SCREEN_DAYTIME
LOC_845A:
    LD      A, (IX+0AH)
    DEC     A
    LD      (IX+0AH), A
    JR      Z, LOC_847F
LOC_8463:
    BIT     3, (IX+0)
    JP      Z, LOC_85C0
    PUSH    IX
    POP     HL
    LD      A, (IX+0BH)
    LD      L, A
    LD      A, (IX+0CH)
    LD      H, A
    PUSH    HL
    POP     IX
    LD      ($7072), IX
    JP      UPPER_SCREEN_DAYTIME
LOC_847F:
    LD      DE, 16CH
    CALL    SUB_860D
    LD      HL, BYTE_8690
    LD      BC, 0AH
    LD      DE, 18CH
    CALL    SUB_8613
    LD      DE, 1ACH
    CALL    SUB_860D
    LD      DE, 1CCH
    CALL    SUB_860D
    LD      IX, ($7072)
    BIT     1, (IX+0)
    JR      NZ, LOC_84AC
    LD      HL, BYTE_86A3
    JR      LOC_84AF
LOC_84AC:
    LD      HL, BYTE_86AC
LOC_84AF:
    LD      DE, 19CCH
    LD      BC, 9
    RST     8
    LD      DE, 1ECH
    CALL    SUB_860D
    RES     2, (IX+0)
    BIT     0, (IX+0)
    JR      Z, LOC_84D8
    PUSH    IX
    POP     HL
    LD      A, (IX+0BH)
    LD      L, A
    LD      A, (IX+0CH)
    LD      H, A
    PUSH    HL
    POP     IY
    RES     3, (IY+0)
LOC_84D8:
    LD      B, 78H
LOC_84DA:
    CALL    RANDOM_TILL_END_OF_TIMER
    DJNZ    LOC_84DA
    JP      LOC_8463
LOC_84E2:
    LD      BC, 1C20H
    EXX
CALL_POLLER_01:  
    LD      IX, ($7072)
    BIT     0, (IX+0)
    JR      Z, CALL_POLLER_02
    LD      D, 78H
    LD      HL, $70BA
    BIT     1, (HL)
    JP      Z, CALL_POLLER_03
    LD      IX, $7087
    LD      ($7072), IX
CALL_POLLER_02:  
    PUSH    DE
    CALL    UPDATE_NAME_TABLE
    PUSH    IX
    CALL    RANDOM_TILL_END_OF_TIMER
    CALL    POLLER
    POP     IX
    LD      IY, CONTROLLER_BUFFER
    POP     DE
    POP     AF
    PUSH    AF
    JR      C, LOC_852C
    LD      A, (IY+6)
    CP      0FH
    JR      NZ, BLACK_SCREEN_01
    LD      A, (IY+0BH)
    CP      0FH
    JR      NZ, BLACK_SCREEN_01
    POP     AF
                SCF
    PUSH    AF
    JR      BLACK_SCREEN_01
LOC_852C:
    LD      A, (IY+6)
    CP      0AH
    JP      Z, LOC_80C2
    CP      0BH
    JP      Z, LOC_804E
    LD      A, (IY+0BH)
    CP      0AH
    JP      Z, LOC_80C2
    CP      0BH
    JP      Z, LOC_804E
BLACK_SCREEN_01: 
    DEC     D
    PUSH    AF
    LD      A, 0
    CP      D
    POP     AF
    JP      Z, BLACK_SCREEN_02
    EXX
    DEC     BC
    LD      A, B
    OR      C
    EXX
    JR      NZ, CALL_POLLER_02
    LD      BC, 1A2H
    CALL    WRITE_REGISTER
    LD      BC, 701H
    CALL    WRITE_REGISTER
    JP      CALL_POLLER_01
BLACK_SCREEN_02: 
    LD      HL, $70BA
    BIT     1, (HL)
    JR      Z, LOC_8585
    RES     1, (HL)
UPDATE_POLLER_00:
    EXX
    DEC     BC
    LD      A, B
    OR      C
    EXX
    JP      NZ, CALL_POLLER_01
    LD      BC, 1A2H
    CALL    WRITE_REGISTER
    LD      BC, 701H
    CALL    WRITE_REGISTER
    JP      CALL_POLLER_01
LOC_8585:
    SET     1, (HL)
    JR      UPDATE_POLLER_00
CALL_POLLER_03:  
    LD      IX, $7078
    LD      ($7072), IX
    JP      CALL_POLLER_02

UPDATE_NAME_TABLE:  
    LD      HL, HUD_01
    LD      DE, 1800H
    LD      BC, 11H
    RST     8
    LD      HL, HUD_02
    LD      DE, 1820H
    LD      BC, 9
    RST     8
    BIT     1, (IX+0)
    JR      Z, LOC_85B9
    LD      A, 68H
    LD      HL, 180AH
    LD      DE, 1
    CALL    FILL_VRAM
LOC_85B9:
    CALL    SUB_BE4E
    CALL    UPDATE_SCORE_C
RET

LOC_85C0:
    BIT     2, (IX+0)
    JR      Z, LOC_85C9
    JP      UPPER_SCREEN_DAYTIME
LOC_85C9:
    LD      DE, 18CH
    CALL    SUB_860D
    LD      HL, BYTE_8690
    LD      BC, 0AH
    LD      DE, 1ACH
    CALL    SUB_8613
    LD      DE, 1CCH
    CALL    SUB_860D
    CALL    PLAY_END_MELODY
    LD      BC, 1A4H
LOC_85E7:
    DEC     BC
    PUSH    BC
    CALL    RANDOM_TILL_END_OF_TIMER
    CALL    UPDATE_SOUNDS_REGISTER_PROTECTED
    POP     BC
    BIT     7, B
    JR      Z, LOC_85E7
    XOR     A
    LD      HL, 1813H
    LD      DE, 0BH
    CALL    FILL_VRAM
    XOR     A
    LD      HL, 1827H
    LD      DE, 4
    CALL    FILL_VRAM
    OR      A
    PUSH    AF
    JP      LOC_84E2

SUB_860D:
    LD      HL, BYTE_8686
    LD      BC, 0AH

SUB_8613:
    PUSH    HL
    LD      HL, 1800H
    ADD     HL, DE
    EX      DE, HL
    POP     HL
    RST     8
RET

DRAW_MIDDLE_AND_BOTTOM:      
    PUSH    HL
    PUSH    DE
    PUSH    BC
    PUSH    IX
    LD      BC, 1E2H
    CALL    WRITE_REGISTER
    CALL    SUB_8660
    LD      HL, 1800H
    LD      DE, 300H
    LD      A, 0B3H
    CALL    FILL_VRAM
    LD      HL, BYTE_869A
    LD      DE, 194CH
    LD      BC, 9
    RST     8
    LD      IX, ($7072)
    BIT     1, (IX+0)
    JR      NZ, LOC_8681
    LD      HL, BYTE_86A3
LOC_864C:
    LD      DE, 198CH
    LD      BC, 9
    RST     8
    LD      B, 0B4H
LOC_8655:
    CALL    RANDOM_TILL_END_OF_TIMER
    DJNZ    LOC_8655
    POP     IX
    POP     BC
    POP     DE
    POP     HL
RET

SUB_8660:
    PUSH    IX
    LD      IX, ($7072)
    LD      A, (IX+1)
    POP     IX
    CP      3
    JP      Z, FLASH_SCREEN_BLUE
    CP      6
    JP      Z, FLASH_SCREEN_BLUE
    CP      8
    JP      Z, FLASH_SCREEN_BLUE
    LD      BC, 70BH
    CALL    WRITE_REGISTER
RET

LOC_8681:
    LD      HL, BYTE_86AC
    JR      LOC_864C

BYTE_8686:      DB 0B3H,0B3H,0B3H,0B3H,0B3H,0B3H,0B3H,0B3H,0B3H,0B3H
BYTE_8690:      DB 0B4H,0B5H,0B6H,0B9H,0B3H,0B8H,0B7H,0B9H,0BAH,0B3H
BYTE_869A:      DB 0B4H,0B9H,0BEH,0B3H,0BAH,0B9H,0B5H,0BBH,0BFH
BYTE_86A3:      DB 0BDH,0BCH,0B5H,0BFH,0B9H,0BAH,0B3H,0B3H,0C0H
BYTE_86AC:      DB 0BDH,0BCH,0B5H,0BFH,0B9H,0BAH,0B3H,0B3H,0C1H
WORD_86B5:      DW 2E68H     
WORD_86B7:      DW 3668H     

INITIALIZE_VRAM: 
    LD      BC, 2
    CALL    WRITE_REGISTER
    LD      BC, 182H
    CALL    WRITE_REGISTER
    LD      BC, 704H
    CALL    WRITE_REGISTER
    LD      HL, 1800H
    CALL    INIT_PATTERN_NAME_TABLE
    LD      HL, 2000H
    CALL    INIT_COLOR_TABLE
    LD      HL, 0
    CALL    INIT_PATTERN_GENERATOR_TABLE
    LD      HL, 1F00H
    CALL    INIT_SPRITE_NAME_TABLE
    LD      HL, 3800H
    CALL    INIT_SPRITE_GENERATOR_TABLE
RET

INIT_PATTERN_NAME_TABLE:     
    LD      A, 2
    JR      INIT_TABLE_WITH_REGISTER_PROTECTION

INIT_COLOR_TABLE:
    LD      A, 4
    JR      INIT_TABLE_WITH_REGISTER_PROTECTION

INIT_PATTERN_GENERATOR_TABLE:
    LD      A, 3
    JR      INIT_TABLE_WITH_REGISTER_PROTECTION

INIT_SPRITE_NAME_TABLE:      
    LD      A, 0
    JR      INIT_TABLE_WITH_REGISTER_PROTECTION

INIT_SPRITE_GENERATOR_TABLE: 
    LD      A, 1
    JR      INIT_TABLE_WITH_REGISTER_PROTECTION
INIT_TABLE_WITH_REGISTER_PROTECTION:   
    PUSH    IX
    PUSH    IY
    CALL    INIT_TABLE
    POP     IY
    POP     IX
RET

SOME_DATA_TO_RAM:
	db 128,128,000,001,000,000,000,000
	db 000,000,000,000,120,128,004,006
	db 000,000,000,000,000,000,000,000
	db 136,128,008,015,000,000,000,000
	db 000,000,000,000,191,000,000,004
	db 015,004,008,044,001,000,000,000
	db 191,000,000,006,015,002,008,240
	db 000,000,000,000,191,000,000,015
	db 000,000,000,000,000,000,000,000
	db 191,000,044,000,191,000,048,000
	db 191,000,052,000,191,000,056,000

ROLLER_CONTROLLER_UPDATE:  
    LD      HL, $7096
    LD      A, 0
    CP      (HL)
    JP      Z, SOME_ROLLER_SUB_00
    DEC     (HL)
TEST_FOR_PAUSE_GAME: 
    LD      IY, CONTROLLER_BUFFER
    LD      A, (IY+6)
    CP      0AH
    JR      Z, PAUSE_GAME
    LD      A, (IY+0BH)
    CP      0AH
    RET     NZ
PAUSE_GAME:      
    DI
    CALL    TURN_OFF_SOUND
    CALL    PLAY_PAUSE_MELODY
    LD      BC, 1A2H
    CALL    WRITE_REGISTER
    LD      BC, 701H
    CALL    WRITE_REGISTER
UPDATE_ROLLER_00:
    CALL    RANDOM_TILL_END_OF_TIMER
    PUSH    IX
    CALL    POLLER
    CALL    UPDATE_SOUNDS_REGISTER_PROTECTED
    POP     IX
    LD      IY, CONTROLLER_BUFFER
    LD      A, (IY+6)
    CP      0AH
    JR      Z, UPDATE_ROLLER_00
    LD      A, (IY+0BH)
    CP      0AH
    JR      Z, UPDATE_ROLLER_00
UPDATE_ROLLER_01:
    CALL    RANDOM_TILL_END_OF_TIMER
    PUSH    IX
    CALL    POLLER
    CALL    UPDATE_SOUNDS_REGISTER_PROTECTED
    POP     IX
    LD      IY, CONTROLLER_BUFFER
    LD      A, (IY+6)
    CP      0AH
    JR      Z, UPDATE_ROLLER_02
    LD      A, (IY+0BH)
    CP      0AH
    JR      NZ, UPDATE_ROLLER_01
UPDATE_ROLLER_02:
    CALL    RANDOM_TILL_END_OF_TIMER
    PUSH    IX
    CALL    POLLER
    CALL    UPDATE_SOUNDS_REGISTER_PROTECTED
    POP     IX
    LD      IY, CONTROLLER_BUFFER
    LD      A, (IY+6)
    CP      0AH
    JR      Z, UPDATE_ROLLER_02
    LD      A, (IY+0BH)
    CP      0AH
    JR      Z, UPDATE_ROLLER_02
    LD      (IY+4), 0
    LD      (IY+9), 0
    CALL    INIT_SOUNDS_REGISTER_PROTECTED
    CALL    PLAY_SNAKES_SLITHER_SOUND
    CALL    FLASH_SCREEN_RED
    LD      BC, 1E2H
    CALL    WRITE_REGISTER
    EI
RET
SOME_ROLLER_SUB_00: 
    LD      A, 0FFH
    LD      ($705D), A
    JP      TEST_FOR_PAUSE_GAME

RANDOM_TILL_END_OF_TIMER:    
    CALL    RAND_GEN
    LD      HL, $70A4
    BIT     0, (HL)
    JR      Z, RANDOM_TILL_END_OF_TIMER
    RES     0, (HL)
    CALL    READ_REGISTER
RET

CALL_POLLER_REGISTER_PROTECTED:        
    PUSH    IX
    DI
    CALL    POLLER
    EI
    POP     IX
RET

NMI:  
    PUSH    AF
    PUSH    HL
    LD      HL, $70A4
    SET     0, (HL)
    POP     HL
    POP     AF
RETN

UPDATE_SCORE_B:  
    PUSH    IX
    LD      IX, ($7072)
    LD      A, (IX+0DH)
    ADD     A, 1
    DAA
    LD      (IX+0DH), A
    POP     IX

UPDATE_SCORE_C:  
    PUSH    IX
    PUSH    IY
    PUSH    HL
    LD      IX, ($7072)
    LD      IY, $7097
    LD      A, (IX+0DH)
    AND     0F0H
    RRCA
    RRCA
    RRCA
    RRCA
    CALL    SUB_887B
    INC     IY
    LD      A, (IX+0DH)
    AND     0FH
    CALL    SUB_887B
    LD      D, 1
    LD      E, 9
    CALL    SUB_A2C6
    LD      BC, 2
    LD      HL, $7097
    RST     8
    POP     HL
    POP     IY
    POP     IX
RET

SUB_887B:
    LD      D, 0C3H
    ADD     A, D
    LD      (IY+0), A
RET

SUB_8882:
    PUSH    IX
    LD      IX, $70F2
    LD      A, (IX+0)
    CP      0BFH
    JP      NZ, LOC_8B4D
    LD      HL, ($70F9)
    LD      A, H
    OR      L
    JR      Z, LOC_88A0
    DEC     HL
    LD      ($70F9), HL
    LD      A, H
    OR      L
    JP      NZ, LOC_8CFA
LOC_88A0:
    PUSH    IX
    LD      IX, ($7072)
    LD      A, (IX+2)
    CP      1
    JP      Z, LOC_8927
    POP     IX
LOC_88B0:
    PUSH    IX
    LD      IX, ($7072)
    LD      A, (IX+3)
    LD      L, A
    LD      A, (IX+4)
    LD      H, A
    PUSH    HL
    POP     IX
    LD      A, (IX+0AH)
    DEC     A
    LD      ($70B7), A
    LD      A, (IX+0BH)
    LD      ($70B8), A
    POP     IX
LOC_88D0:
    CALL    RAND_GEN
    AND     0FH
    LD      B, A
    LD      A, ($70B7)
    CP      B
    JR      NC, LOC_88D0
    LD      A, ($70B8)
    CP      B
    JR      C, LOC_88D0
    LD      A, B
    LD      ($70B9), A
    LD      HL, 0
    LD      B, 3CH
LOC_88EB:
    LD      A, ($70B9)
LOC_88EE:
    INC     HL
    DEC     A
    JR      NZ, LOC_88EE
    DJNZ    LOC_88EB
    LD      ($70F9), HL
    LD      A, R
    BIT     0, A
    JR      Z, LOC_8937
    LD      (IX+6), 2
    LD      IY, UNK_B45B
    LD      A, (IY+0)
    LD      (IX+2), A
    INC     IY
    LD      A, (IY+0)
    LD      (IX+0EH), A
    INC     IY
    LD      ($7076), IY
    LD      (IX+1), 0
    LD      (IX+0DH), 0
    LD      IY, BYTE_8CFD
    JR      LOC_895F
LOC_8927:
    BIT     6, (IX+0)
    JP      NZ, LOC_8CF8
    SET     6, (IX+0)
    POP     IX
    JP      LOC_88B0
LOC_8937:
    LD      (IX+6), 8
    LD      IY, UNK_B468
    LD      A, (IY+0)
    LD      (IX+2), A
    INC     IY
    LD      A, (IY+0)
    LD      (IX+0EH), A
    INC     IY
    LD      ($7076), IY
    LD      (IX+1), 0F8H
    LD      (IX+0DH), 0F8H
    LD      IY, BYTE_8D07
LOC_895F:
    PUSH    IX
    LD      IX, ($7072)
    LD      A, (IX+2)
    CP      4
    POP     IX
    JP      Z, LOC_8A43
LOC_896F:
    CALL    RAND_GEN
    CP      23H
    JR      C, LOC_895F
    CP      0B0H
    JR      NC, LOC_895F
    LD      (IX+0), A
    LD      (IX+0CH), A
LOC_8980:
    LD      A, R
    AND     7
    CP      5
    JP      NC, LOC_8980
    SLA     A
    LD      C, A
    LD      B, 0
    ADD     IY, BC
    LD      HL, $713E
    LD      A, (IY+0)
    LD      (HL), A
    LD      A, (IY+1)
    LD      ($713F), A
LOC_899D:
    LD      HL, $713E
    PUSH    IY
    PUSH    IX
    PUSH    HL
    LD      IX, ($7072)
    LD      A, (IX+5)
    LD      L, A
    LD      A, (IX+6)
    LD      H, A
    PUSH    HL
    POP     IY
    LD      B, (IY+1)
    POP     HL
    POP     IX
    XOR     A
LOC_89BB:
    ADD     A, (HL)
    LD      ($713E), A
    DJNZ    LOC_89BB
    LD      HL, $713F
    LD      B, (IY+1)
    XOR     A
LOC_89C8:
    ADD     A, (HL)
    LD      ($713F), A
    DJNZ    LOC_89C8
    POP     IY
    LD      A, 0
    LD      ($70AF), A
    LD      ($70AE), A
    LD      (IX+4), 0FH
    CALL    RAND_GEN
    AND     3
    SLA     A
    PUSH    AF
    LD      A, ($70A7)
    CP      0
    POP     AF
    JR      Z, LOC_89EE
    LD      A, 4
LOC_89EE:
    LD      ($7143), A
    LD      IY, BYTE_8D11
    LD      C, A
    LD      B, 0
    ADD     IY, BC
    LD      A, (IY+0)
    LD      (IX+5), A
    XOR     A
    LD      ($70A7), A
    LD      A, (IY+1)
    LD      (IX+0AH), A
    LD      (IX+9), A
    CALL    PLAY_TYRRANOSAUR_SOUND
    PUSH    IX
    PUSH    HL
    LD      IX, ($7072)
    LD      A, (IX+3)
    LD      L, A
    LD      A, (IX+4)
    LD      H, A
    PUSH    HL
    POP     IX
    BIT     0, (IX+0DH)
    POP     HL
    POP     IX
    JP      Z, LOC_8B38
    LD      A, ($70B0)
    CP      64H
    JR      NC, LOC_8A40
    CP      0AH
    JP      C, LOC_8C1E
    CALL    RAND_GEN
    CP      0ABH
    JP      C, LOC_8C1E
LOC_8A40:
    JP      LOC_8CFA
LOC_8A43:
    CALL    RAND_GEN
    CP      56H
    JP      NC, LOC_896F
    LD      A, (IX+6)
    CP      2
    JR      NZ, LOC_8A63
    LD      A, ($70C3)
    LD      ($70A8), A
    CALL    SUB_8A7D
    LD      A, 1
    LD      ($70A7), A
    JP      LOC_899D
LOC_8A63:
    LD      A, 0FFH
    SUB     0C3H
    LD      ($70A8), A
    CALL    SUB_8A7D
    LD      A, ($713E)
    NEG
    LD      ($713E), A
    LD      A, 1
    LD      ($70A7), A
    JP      LOC_899D

SUB_8A7D:
    CALL    RAND_GEN
    AND     3
    CP      0
    JP      Z, LOC_8AA2
    CP      1
    JP      Z, LOC_8AD4
    CP      2
    JP      Z, LOC_8B06
LOC_8A91:
    LD      A, ($70C2)
    LD      (IX+0), A
    LD      A, 2
    LD      ($713E), A
    LD      A, 0
    LD      ($713F), A
RET
LOC_8AA2:
    LD      A, ($70A8)
    SLA     A
    LD      B, A
    LD      A, ($70C2)
    ADD     A, B
    JR      C, LOC_8AC0
    CP      0B0H
    JR      NC, LOC_8AC0
    LD      (IX+0), A
    LD      A, 0FEH
    LD      ($713F), A
LOC_8ABA:
    LD      A, 1
    LD      ($713E), A
RET
LOC_8AC0:
    LD      A, ($70C2)
    SUB     B
    JR      C, LOC_8AD4
    CP      24H
    JR      C, LOC_8AD4
    LD      (IX+0), A
    LD      A, 2
    LD      ($713F), A
    JR      LOC_8ABA
LOC_8AD4:
    LD      A, ($70A8)
    SRA     A
    LD      B, A
    LD      A, ($70C2)
    ADD     A, B
    JR      C, LOC_8AF2
    CP      0B0H
    JR      NC, LOC_8AF2
    LD      (IX+0), A
    LD      A, 0FFH
    LD      ($713F), A
LOC_8AEC:
    LD      A, 2
    LD      ($713E), A
RET
LOC_8AF2:
    LD      A, ($70C2)
    SUB     B
    JR      C, LOC_8B06
    CP      24H
    JR      C, LOC_8B06
    LD      (IX+0), A
    LD      A, 1
    LD      ($713F), A
    JR      LOC_8AEC
LOC_8B06:
    LD      A, ($70A8)
    LD      B, A
    LD      A, ($70C2)
    ADD     A, B
    JR      C, LOC_8B22
    CP      0B0H
    JR      NC, LOC_8B22
    LD      (IX+0), A
    LD      A, 0FFH
    LD      ($713F), A
LOC_8B1C:
    LD      A, 1
    LD      ($713E), A
RET
LOC_8B22:
    LD      A, ($70C2)
    SUB     B
    JP      C, LOC_8A91
    CP      24H
    JP      C, LOC_8A91
    LD      (IX+0), A
    LD      A, 1
    LD      ($713F), A
    JR      LOC_8B1C

LOC_8B38:
    LD      A, ($70B0)
    CP      0AH
    LD      A, 8
    LD      ($70B1), A
    LD      A, 10H
    LD      ($70B2), A
    JP      C, LOC_8C43
    JP      LOC_8CFA
LOC_8B4D:
    DEC     (IX+4)
    JR      NZ, LOC_8B91
    LD      (IX+4), 0FH
    LD      IY, ($7076)
    LD      A, (IY+0)
    LD      (IX+2), A
    INC     IY
    LD      A, (IY+0)
    LD      (IX+0EH), A
    INC     IY
    LD      A, 0FFH
    CP      (IY+0)
    JR      Z, LOC_8B78
    LD      ($7076), IY
    JP      LOC_8B91
LOC_8B78:
    LD      A, (IX+6)
    CP      2
    JR      Z, LOC_8B89
    LD      IY, UNK_B468
    LD      ($7076), IY
    JR      LOC_8B91
LOC_8B89:
    LD      IY, UNK_B45B
    LD      ($7076), IY
LOC_8B91:
    DEC     (IX+9)
    JP      NZ, LOC_8BA0
    LD      A, (IX+0AH)
    LD      (IX+9), A
    CALL    PLAY_TYRRANOSAUR_SOUND
LOC_8BA0:
    DEC     (IX+5)
    JP      NZ, LOC_8CFA
    LD      A, ($70AE)
    CP      1
    JP      Z, LOC_8C67
LOC_8BAE:
    LD      A, ($7143)
    LD      IY, BYTE_8D11
    LD      C, A
    LD      B, 0
    ADD     IY, BC
    LD      A, (IY+0)
    LD      (IX+5), A
    LD      A, 0BFH
    CP      (IX+0)
    JP      Z, LOC_8CFA
    LD      A, ($713E)
    ADD     A, (IX+1)
    LD      (IX+1), A
    LD      (IX+0DH), A
    LD      A, ($713F)
    ADD     A, (IX+0)
    LD      (IX+0), A
    LD      (IX+0CH), A
    LD      A, (IX+1)
    CP      0
    JR      C, LOC_8BF9
    CP      0F8H
    JR      NC, LOC_8BF9
    LD      A, (IX+0)
    CP      23H
    JR      C, LOC_8C10
    CP      0B0H
    JR      NC, LOC_8C10
    JP      LOC_8CFA
LOC_8BF9:
    PUSH    IX
    LD      IX, ($7072)
    RES     6, (IX+0)
    POP     IX
    LD      (IX+0), 0BFH
    LD      (IX+0CH), 0BFH
    JP      LOC_8CFA
LOC_8C10:
    LD      A, ($713F)
    NEG
    LD      ($713F), A
    JP      LOC_8CFA

SUB_8C1B:
    ADD     A, 3
RET

LOC_8C1E:
    CALL    RAND_GEN
    AND     0FH
    CP      0AH
    JR      C, LOC_8C29
    SUB     5
LOC_8C29:
    CP      1
    CALL    C, SUB_8C1B
    LD      ($70B1), A
    CALL    RAND_GEN
    AND     4FH
    LD      ($70B2), A
    CP      10H
    JR      NC, LOC_8C49
    LD      B, A
    LD      A, 10H
    LD      ($70B2), A
LOC_8C43:
    LD      A, 1
    LD      ($70AE), A
    LD      A, B
LOC_8C49:
    AND     3
    JR      NZ, LOC_8C4F
    LD      A, 1
LOC_8C4F:
    LD      BC, 0
    LD      ($70B3), BC
    LD      B, A
LOC_8C57:
    LD      A, ($70B3)
    ADD     A, 8
    LD      ($70B3), A
    DJNZ    LOC_8C57
    LD      ($70B4), A
    JP      LOC_8CFA
LOC_8C67:
    LD      A, ($70B2)
    CP      0
    JR      Z, LOC_8C75
    DEC     A
    LD      ($70B2), A
    JP      LOC_8BAE
LOC_8C75:
    LD      A, ($70B1)
    CP      0
    JR      Z, LOC_8CC0
    LD      A, ($70AF)
    CP      1
    JR      Z, LOC_8CEF
    LD      A, (IX+6)
    CP      2
    JR      Z, LOC_8CCB
    LD      A, 0CH
    ADD     A, (IX+1)
    LD      E, A
    LD      A, 0CH
    ADD     A, (IX+0)
    LD      D, A
LOC_8C96:
    CALL    SUB_A2BA
    LD      HL, $70B5
    PUSH    HL
    PUSH    DE
    CALL    SUB_A2D7
    POP     DE
    POP     HL
    LD      A, (HL)
    CP      67H
    JR      Z, LOC_8CE0
    JR      LOC_8CB8
LOC_8CAA:
    LD      A, ($70B4)
    LD      ($70B3), A
    LD      A, 0
    LD      ($70AF), A
    JP      LOC_8BAE
LOC_8CB8:
    LD      A, 1
    LD      ($70AF), A
    JP      LOC_8BAE
LOC_8CC0:
    LD      A, 0
    LD      ($70AE), A
    LD      ($70AF), A
    JP      LOC_8BAE
LOC_8CCB:
    LD      A, (IX+1)
    CP      0F0H
    JR      NC, LOC_8CC0
    LD      A, 5
    ADD     A, (IX+1)
    LD      E, A
    LD      A, 0CH
    ADD     A, (IX+0)
    LD      D, A
    JR      LOC_8C96
LOC_8CE0:
    LD      (HL), 6AH
    CALL    SUB_962E
    LD      HL, $70B1
    DEC     (HL)
    LD      HL, $70B0
    INC     (HL)
    JR      LOC_8CB8
LOC_8CEF:
    LD      HL, $70B3
    DEC     (HL)
    JR      Z, LOC_8CAA
    JP      LOC_8BAE
LOC_8CF8:
    POP     IX
LOC_8CFA:
    POP     IX
RET

BYTE_8CFD:
	db 001,000,001,001,002,001,001,255,002,255
BYTE_8D07:
	db 255,000,255,001,254,001,255,255,254,255
BYTE_8D11:
	db 004,060,003,030,002,020,001,015

SUB_8D19:
    PUSH    IX
    LD      IX, $70E6
    LD      A, (IX+0)
    CP      0BFH
    JP      NZ, LOC_8DE3
    LD      HL, ($70ED)
    LD      A, H
    OR      L
    JR      Z, LOC_8D37
    DEC     HL
    LD      ($70ED), HL
    LD      A, H
    OR      L
    JP      NZ, LOC_8EEA
LOC_8D37:
    PUSH    IX
    LD      IX, ($7072)
    LD      A, (IX+2)
    CP      1
    JP      Z, LOC_8DA5
    POP     IX
LOC_8D47:
    PUSH    IX
    LD      IX, ($7072)
    LD      A, (IX+3)
    LD      L, A
    LD      A, (IX+4)
    LD      H, A
    PUSH    HL
    POP     IX
    LD      A, (IX+0AH)
    DEC     A
    LD      ($70B7), A
    LD      A, (IX+0BH)
    LD      ($70B8), A
LOC_8D65:
    CALL    RAND_GEN
    AND     0FH
    LD      B, A
    LD      A, ($70B7)
    CP      B
    JR      NC, LOC_8D65
    LD      A, ($70B8)
    CP      B
    JR      C, LOC_8D65
    LD      A, B
    LD      ($70B9), A
    LD      HL, 0
    LD      B, 3CH
LOC_8D80:
    LD      A, ($70B9)
LOC_8D83:
    INC     HL
    DEC     A
    JR      NZ, LOC_8D83
    DJNZ    LOC_8D80
    LD      ($70ED), HL
    POP     IX
    CALL    PLAY_PTERODACTYL_SOUND
    LD      A, R
    BIT     0, A
    JR      Z, LOC_8DB5
    LD      (IX+6), 2
    LD      (IX+2), 0CH
    LD      (IX+1), 0
    JR      LOC_8DC1
LOC_8DA5:
    BIT     6, (IX+0)
    JP      NZ, LOC_8EE8
    SET     6, (IX+0)
    POP     IX
    JP      LOC_8D47
LOC_8DB5:
    LD      (IX+6), 8
    LD      (IX+2), 48H
    LD      (IX+1), 0F7H
LOC_8DC1:
    CALL    RAND_GEN
    CP      23H
    JR      C, LOC_8DC1
    CP      0B0H
    JR      NC, LOC_8DC1
    LD      (IX+0), A
    LD      (IX+4), 0FH
    LD      (IX+5), 4
    LD      (IX+9), 0FH
    LD      A, 0
    LD      ($70BB), A
    JP      LOC_8EEA
LOC_8DE3:
    DEC     (IX+4)
    JR      NZ, LOC_8E17
    LD      (IX+4), 0FH
    LD      A, (IX+6)
    CP      2
    JR      Z, LOC_8E06
    LD      A, (IX+2)
    CP      48H
    JR      Z, LOC_8E00
    LD      (IX+2), 48H
    JR      LOC_8E17
LOC_8E00:
    LD      (IX+2), 4CH
    JR      LOC_8E17
LOC_8E06:
    LD      A, (IX+2)
    CP      0CH
    JR      Z, LOC_8E13
    LD      (IX+2), 0CH
    JR      LOC_8E17
LOC_8E13:
    LD      (IX+2), 10H
LOC_8E17:
    DEC     (IX+5)
    JP      NZ, LOC_8EEA
    LD      (IX+5), 4
    LD      A, 0BFH
    CP      (IX+0)
    JP      Z, LOC_8EEA
    LD      A, R
    AND     3
    LD      ($713A), A
    LD      A, (IX+6)
    CP      2
    JP      NZ, LOC_8EC1
LOC_8E38:
    LD      A, R
    AND     0BH
    LD      HL, $713B
    LD      (HL), A
    PUSH    IY
    PUSH    IX
    PUSH    HL
    LD      IX, ($7072)
    LD      A, (IX+5)
    LD      L, A
    LD      A, (IX+6)
    LD      H, A
    PUSH    HL
    POP     IY
    LD      B, (IY+1)
    POP     HL
    POP     IX
    POP     IY
    XOR     A
LOC_8E5D:
    ADD     A, (HL)
    LD      ($713B), A
    DJNZ    LOC_8E5D
    LD      A, ($70BB)
    CP      1
    LD      A, ($713B)
    JR      NZ, LOC_8E6F
    NEG
LOC_8E6F:
    ADD     A, (IX+0)
    CP      23H
    JR      C, LOC_8EA5
    CP      0B0H
    JR      NC, LOC_8EA5
    DEC     (IX+9)
    JR      Z, LOC_8EA5
    LD      A, ($70BB)
    CP      1
    JR      Z, LOC_8EB7
LOC_8E86:
    LD      A, ($713A)
    ADD     A, (IX+1)
    LD      (IX+1), A
    LD      A, ($713B)
    ADD     A, (IX+0)
    LD      (IX+0), A
    LD      A, (IX+1)
    CP      0
    JR      C, KILLED_PTERODACTYL
    CP      0F8H
    JR      NC, KILLED_PTERODACTYL
    JR      LOC_8EEA
LOC_8EA5:
    LD      (IX+9), 0FH
    LD      A, ($70BB)
    CP      1
    JR      Z, LOC_8ECC
    LD      A, 1
    LD      ($70BB), A
    JR      LOC_8EB7
LOC_8EB7:
    LD      A, ($713B)
    NEG
    LD      ($713B), A
    JR      LOC_8E86
LOC_8EC1:
    LD      A, ($713A)
    NEG
    LD      ($713A), A
    JP      LOC_8E38
LOC_8ECC:
    LD      A, 0
    LD      ($70BB), A
    JR      LOC_8E86
KILLED_PTERODACTYL: 
    PUSH    IX
    LD      IX, ($7072)
    RES     6, (IX+0)
    POP     IX
    LD      (IX+0), 0BFH
    CALL    PLAY_PTERODACTYL_HIT_SOUND_B
    JR      LOC_8EEA
LOC_8EE8:
    POP     IX
LOC_8EEA:
    POP     IX
RET

SUB_8EED:
    LD      A, 0
    LD      HL, $7151
    CP      (HL)
    RET     NZ
    LD      (HL), 3DH
RET

SUB_8EF7:
    PUSH    IX
    PUSH    IY
    LD      A, ($7223)
    CP      0
    JR      Z, LOC_8F25
    LD      A, ($717F)
    DEC     A
    JR      Z, LOC_8F2D
    LD      ($717F), A
    LD      A, 0
    LD      HL, $71DB
    CP      (HL)
    JR      Z, LOC_8F28
    LD      IX, $718B
    LD      A, 5
    SUB     (HL)
    LD      B, A
    LD      DE, 10H
LOC_8F1E:
    ADD     IX, DE
    DJNZ    LOC_8F1E
    DEC     (HL)
    JR      LOC_8F3C
LOC_8F25:
    CALL    SUB_8EED
LOC_8F28:
    POP     IY
    POP     IX
RET

LOC_8F2D:
    LD      A, ($7181)
    LD      ($717F), A
    LD      A, 4
    LD      ($71DB), A
    LD      IX, $718B
LOC_8F3C:
    LD      IY, $71DC
    LD      ($7179), IY
    LD      B, 8
    LD      L, (IX+0)
    LD      H, (IX+1)
LOC_8F4C:
    LD      A, 80H
    AND     H
    JR      NZ, LOC_8F63
LOC_8F51:
    LD      DE, 2
    ADD     IX, DE
    LD      L, (IX+0)
    LD      H, (IX+1)
    DJNZ    LOC_8F4C
    POP     IY
    POP     IX
RET

LOC_8F63:
    LD      A, H
    AND     3FH
    LD      H, A
    PUSH    BC
    EX      DE, HL
    LD      HL, $71DC
    LD      BC, 22H
    LD      ($717D), DE
    LD      ($717B), IX
    LD      A, (IX+1)
    LD      ($7178), A
    CALL    READ_VRAM
    CALL    SUB_8FBA
    BIT     5, (IY+0)
    JR      NZ, LOC_8F8F
    CALL    SUB_9381
    CALL    SUB_951A
LOC_8F8F:
    LD      HL, $71DC
    CALL    SUB_BDB0
    POP     BC
    JR      LOC_8F51

LOC_8FB6:
    SET     7, (IY+0)

SUB_8FBA:
    LD      A, 0
    LD      ($7173), A
    LD      ($7174), A
    LD      ($7175), A
    LD      ($7176), A
    LD      A, (IY+0)
    LD      ($715F), A
    LD      A, (IY+1)
    LD      ($7163), A
    LD      ($7160), A
    LD      A, (IY+2)
    LD      ($7164), A
    LD      ($7161), A
    LD      A, (IY+0)
    AND     3
    LD      ($7165), A
    LD      ($7171), A
    XOR     3
    LD      DE, $7173
    LD      H, 0
    LD      L, A
    ADD     HL, DE
    LD      (HL), 1
    LD      B, 0
    LD      A, (IY+1)
    CP      5
    JP      P, LOC_9003
    CALL    SUB_9074
LOC_9003:
    INC     B
    LD      A, (IY+2)
    CP      1EH
    JP      M, LOC_900F
    CALL    SUB_9074
LOC_900F:
    INC     B
    CP      2
    JP      P, LOC_9018
    CALL    SUB_9074
LOC_9018:
    INC     B
    LD      A, (IY+1)
    CP      17H
    JP      M, LOC_9024
    CALL    SUB_9074
LOC_9024:
    CALL    SUB_907E
    BIT     7, (IY+0)
    JP      Z, LOC_8FB6
LOC_902E:
    CALL    SUB_9348
    CALL    SUB_9221
    BIT     6, (IY+0)
    RES     6, (IY+0)
    JP      Z, LOCRET_9044
    CALL    SUB_91FE
    JR      LOC_902E
LOCRET_9044:     
RET

SUB_9045:
    CALL    SUB_9058
RET

SUB_9049:
    CALL    SUB_9058
    INC     (IY+3)

SUB_904F:
    LD      A, (IY+0)
    XOR     4
    LD      (IY+0), A
RET

SUB_9058:
    LD      A, (IY+0)
    AND     3
    LD      B, 0
    LD      C, A
    BIT     6, (IY+15H)
    JR      Z, LOC_906B
    LD      HL, BYTE_965F
    JR      LOC_906E
LOC_906B:
    LD      HL, BYTE_965B
LOC_906E:
    ADD     HL, BC
    LD      A, (HL)
    LD      (IY+3), A
RET

SUB_9074:
    LD      D, 0
    LD      E, B
    LD      HL, $7173
    ADD     HL, DE
    LD      (HL), 1
RET

SUB_907E:
    BIT     2, (IY+0)
    JP      NZ, LOC_9091
    LD      A, (IY+4)
    CP      0
    JP      Z, LOC_90A2
    DEC     A
    LD      (IY+4), A
LOC_9091:
    LD      DE, $7173
    LD      H, 0
    LD      A, ($7171)
    LD      L, A
    ADD     HL, DE
    LD      A, (HL)
    CP      0
    JP      NZ, LOC_90B7

LOCRET_90A1:     
RET

LOC_90A2:
    BIT     5, (IY+0)
    JP      NZ, LOC_90D0
    BIT     3, (IY+0)
    JR      NZ, LOC_90B7
    LD      A, ($7178)
    BIT     6, A
    JP      NZ, LOC_915E
LOC_90B7:
    CALL    SUB_91FE
    BIT     3, (IY+0)
    JR      NZ, LOC_90C7
    LD      A, ($7178)
    BIT     6, A
    JR      NZ, LOCRET_90A1
LOC_90C7:
    LD      A, R
    AND     0FH
    LD      (IY+4), A
    JR      LOCRET_90A1
LOC_90D0:
    LD      A, ($7178)
    BIT     6, A
    JR      Z, LOC_90E1
    LD      HL, ($717B)
    INC     HL
    RES     6, (HL)
    LD      HL, $7177
    DEC     (HL)
LOC_90E1:
    CALL    SUB_9134
    PUSH    IX
    LD      A, 5
    LD      ($7184), A
    LD      A, 1
    LD      ($7185), A
LOC_90F0:
    CALL    SUB_9A87
    CALL    SUB_960A
    LD      A, (IY+0)
    AND     3
    CP      2
    JP      Z, LOC_9102
    DEC     DE
    DEC     DE
LOC_9102:
    LD      HL, $716C
    LD      BC, 5
    CALL    READ_VRAM
    LD      B, 5
    LD      HL, $716C
LOC_9110:
    LD      A, (HL)
    CP      67H
    JP      Z, LOC_9120
    CP      6AH
    JP      Z, LOC_9120
    CP      6BH
    JP      NZ, LOC_912B
LOC_9120:
    DJNZ    LOC_9110
    RES     7, (IY+0)
    POP     IX
    JP      LOCRET_90A1
LOC_912B:
    PUSH    HL
    LD      HL, $7184
    INC     (HL)
    POP     HL
    JP      LOC_90F0

SUB_9134:
    LD      (IY+3), 67H
    PUSH    IX
    LD      IX, ($7179)
    LD      DE, 5
    ADD     IX, DE
    LD      DE, 4
    LD      B, 6
LOC_9148:
    LD      (IX+3), 67H
    ADD     IX, DE
    DJNZ    LOC_9148
    POP     IX
    RES     3, (IY+0)
    CALL    SUB_951A
    SET     3, (IY+0)
RET

LOC_915E:
    LD      A, ($7224)
    SRL     A
    SRL     A
    SRL     A
    INC     A
    LD      ($7228), A
    LD      A, ($7225)
    SRL     A
    SRL     A
    SRL     A
    INC     A
    LD      ($7229), A
    LD      A, (IY+21H)
    LD      (IY+4), A
    LD      A, ($7171)
    CP      0
    JR      Z, LOC_91C2
    CP      3
    JR      Z, LOC_91C2
    LD      A, (IY+2)
    LD      HL, $7228
    CP      (HL)
    JR      Z, LOC_91A5
    PUSH    AF
    PUSH    HL
    LD      A, ($7171)
    CP      1
    JR      NZ, LOC_91B6
    POP     HL
    POP     AF
    CP      (HL)
    JP      C, LOCRET_90A1
    LD      (IY+4), 1
LOC_91A5:
    LD      A, (IY+1)
    LD      HL, $7229
    CP      (HL)
    JR      C, LOC_91B2
    LD      A, 0
    JR      LOC_91F8
LOC_91B2:
    LD      A, 3
    JR      LOC_91F8
LOC_91B6:
    POP     HL
    POP     AF
    CP      (HL)
    JP      NC, LOCRET_90A1
    LD      (IY+4), 1
    JR      LOC_91A5
LOC_91C2:
    LD      A, (IY+2)
    LD      HL, $7228
    CP      (HL)
    JR      Z, LOC_91D5
    JR      C, LOC_91D1
LOC_91CD:
    LD      A, 2
    JR      LOC_91F8
LOC_91D1:
    LD      A, 1
    JR      LOC_91F8
LOC_91D5:
    LD      HL, $7229
    LD      A, ($7171)
    CP      0
    JR      Z, LOC_91E8
    LD      A, (IY+1)
    CP      (HL)
    JP      C, LOCRET_90A1
    JR      LOC_91EF
LOC_91E8:
    LD      A, (IY+1)
    CP      (HL)
    JP      NC, LOCRET_90A1
LOC_91EF:
    LD      A, (IY+2)
    CP      10H
    JR      C, LOC_91D1
    JR      LOC_91CD
LOC_91F8:
    LD      ($7171), A
    JP      LOCRET_90A1

SUB_91FE:
    LD      HL, $7165
LOC_9201:
    PUSH    HL
    CALL    RAND_GEN
    POP     HL
    AND     3
    XOR     3
    CP      (HL)
    JP      Z, LOC_9201
    XOR     3
    LD      H, 0
    LD      L, A
    LD      DE, $7173
    ADD     HL, DE
    LD      ($7171), A
    LD      A, (HL)
    CP      0
    JP      NZ, SUB_91FE
RET

SUB_9221:
    CALL    SUB_960A
    LD      BC, 1
    CALL    READ_VRAM
    LD      A, (IY+3)
    CP      67H
    JP      Z, LOC_930B
    BIT     3, (IY+0)
    JP      Z, LOC_9258
    SET     5, (IY+0)
    RES     6, (IY+0)
    CALL    SUB_924B
    JP      LOCRET_9347

SUB_9247:
    SET     6, (IY+0)

SUB_924B:
    LD      A, ($7160)
    LD      (IY+1), A
    LD      A, ($7161)
    LD      (IY+2), A
RET

LOC_9258:
    LD      A, 0
    LD      ($7172), A
    LD      A, ($7171)
    LD      H, 0
    LD      L, A
    LD      DE, $7173
    ADD     HL, DE
    LD      A, (IY+3)
    LD      (HL), A
    LD      B, 4
LOC_926D:
    LD      A, (DE)
    CP      0
    JP      Z, LOC_932D
    INC     DE
    DJNZ    LOC_926D
    LD      A, 6AH
    LD      HL, $7173
    PUSH    BC
    PUSH    HL
    LD      B, 4
LOC_927F:
    CP      (HL)
    JP      Z, LOC_92F7
    INC     A
    CP      (HL)
    JP      Z, LOC_92F7
    DEC     A
    PUSH    AF
    LD      A, ($7172)
    INC     A
    LD      ($7172), A
    POP     AF
    INC     HL
    DJNZ    LOC_927F
    POP     HL
    LD      B, 4
    LD      A, 0
    LD      ($7172), A
LOC_929D:
    LD      A, (HL)
    CP      6CH
    JP      M, LOC_92C3
    CP      8EH
    JP      P, LOC_92C3
    LD      DE, 9
    PUSH    BC
    LD      B, 4
    LD      IX, ($7179)
LOC_92B2:
    ADD     IX, DE
    LD      A, (IY+1)
    CP      (IX+1)
    JP      Z, LOC_92DD
LOC_92BD:
    LD      DE, 4
    DJNZ    LOC_92B2
    POP     BC
LOC_92C3:
    INC     HL
    PUSH    AF
    LD      A, ($7172)
    INC     A
    LD      ($7172), A
    POP     AF
    DJNZ    LOC_929D
    CALL    SUB_936A
    RES     6, (IY+0)
    POP     BC
    CALL    SUB_924B
    JP      LOCRET_9347
LOC_92DD:
    LD      A, (IY+2)
    CP      (IX+2)
    JP      NZ, LOC_92BD
    POP     BC
    POP     BC
    LD      A, ($7172)
    LD      ($7171), A
    CALL    SUB_924B
    CALL    SUB_9348
    JP      LOC_930B
LOC_92F7:
    POP     BC
    POP     BC
    PUSH    HL
    LD      HL, $70B0
    DEC     (HL)
    POP     HL
    LD      A, ($7172)
    LD      ($7171), A
    CALL    SUB_924B
    CALL    SUB_9348
LOC_930B:
    RES     5, (IY+0)
    LD      A, ($7165)
    LD      H, A
    LD      A, ($7171)
    AND     3
    LD      L, A
    CP      H
    JP      NZ, LOC_933B
    BIT     2, (IY+0)
    JP      NZ, LOC_9333
    CALL    SUB_9049
    CALL    SUB_924B
    JP      LOCRET_9347
LOC_932D:
    CALL    SUB_9247
    JP      LOCRET_9347
LOC_9333:
    CALL    SUB_9045
    CALL    SUB_904F
    JR      LOCRET_9347
LOC_933B:
    LD      A, (IY+0)
    AND     0F8H
    OR      L
    LD      (IY+0), A
    CALL    SUB_9045

LOCRET_9347:     
RET

SUB_9348:
    LD      A, ($7171)
    CP      0
    JP      Z, LOC_935E
    CP      1
    JP      Z, LOC_9362
    CP      2
    JP      Z, LOC_9366
    INC     (IY+1)
RET

LOC_935E:
    DEC     (IY+1)
RET

LOC_9362:
    INC     (IY+2)
RET

LOC_9366:
    DEC     (IY+2)
RET

SUB_936A:
    BIT     5, (IY+0)
    JP      NZ, LOCRET_9380
    SET     5, (IY+0)
    LD      A, ($716B)
    LD      (IY+4), A
    XOR     1
    LD      ($716B), A
LOCRET_9380:
RET

SUB_9381:
    PUSH    AF
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IX
    PUSH    IY
    LD      A, (IY+15H)
    LD      ($7188), A
    LD      A, (IY+0)
    LD      ($7162), A
    LD      ($7165), A
    BIT     2, A
    JP      NZ, LOC_9443
    AND     83H
    LD      ($7162), A
    LD      BC, 5
    JR      LOC_93AA

SUB_93A7:
    LD      BC, 4
LOC_93AA:
    ADD     IY, BC
    BIT     7, (IY+0)
    JP      Z, SUB_93A7
    LD      A, ($7165)
    BIT     3, A
    JP      Z, LOC_93C2
    BIT     4, (IY+0)
    JP      NZ, SUB_9454
LOC_93C2:
    LD      A, (IY+0)
    LD      ($715F), A
    LD      A, (IY+1)
    LD      ($7160), A
    LD      A, (IY+2)
    LD      ($7161), A
    SLA     (IY+0)
    SLA     (IY+0)
    LD      A, ($7162)
    LD      B, (IY+0)
    OR      B
    AND     8FH
    LD      ($7162), A
    LD      HL, $715F
    BIT     4, (HL)
    JP      Z, SUB_93F5
    LD      HL, $7162
    SET     4, (HL)
SUB_93F5:
    LD      A, ($7162)
    LD      (IY+0), A
    LD      A, ($7163)
    LD      (IY+1), A
    LD      A, ($7164)
    LD      (IY+2), A
    LD      A, ($715F)
    LD      ($7162), A
    LD      A, ($7160)
    LD      ($7163), A
    LD      A, ($7161)
    LD      ($7164), A
    BIT     4, (IY+0)
    JP      NZ, SUB_9454
    CALL    SUB_9426
    JP      SUB_93A7

SUB_9426:
    LD      A, (IY+0)
    AND     0FH
    LD      D, 0
    LD      E, A
    LD      HL, $7188
    BIT     6, (HL)
    JR      Z, LOC_943A
    LD      HL, BYTE_9663
    JR      LOC_943D
LOC_943A:
    LD      HL, BYTE_963B
LOC_943D:
    ADD     HL, DE
    LD      A, (HL)
    LD      (IY+3), A
RET

LOC_9443:
    LD      BC, 1
    ADD     IY, BC
LOC_9448:
    LD      BC, 4
    ADD     IY, BC
    BIT     4, (IY+0)
    JP      Z, LOC_9448

SUB_9454:
    LD      A, (IY+0)
    AND     0FH
    PUSH    AF
    AND     3
    LD      B, A
    POP     AF
    PUSH    AF
    SRA     A
    SRA     A
    SUB     B
    POP     DE
    LD      A, D
    JP      Z, LOC_947A
    LD      HL, $7165
    BIT     2, (HL)
    JP      NZ, LOC_949B
    CALL    SUB_94BC
    LD      (IY+3), 67H
    JR      LOC_949B
LOC_947A:
    LD      HL, $7165
    BIT     2, (HL)
    JP      NZ, LOC_948B
    CALL    SUB_94BC
    INC     D
    LD      (IY+3), D
    JR      LOC_949B
LOC_948B:
    CALL    SUB_94BC
    LD      (IY+3), 67H
    LD      IY, ($7168)
    INC     D
    INC     D
    LD      (IY+3), D
LOC_949B:
    LD      HL, $7188
    BIT     6, (HL)
    JR      Z, LOC_94AC
    LD      (HL), 0
    LD      IX, ($7179)
    SET     6, (IX+15H)
LOC_94AC:
    LD      A, ($7222)
    CP      0
    JR      NZ, LOCRET_94BB
    POP     IY
    POP     IX
    POP     HL
    POP     DE
    POP     BC
    POP     AF
LOCRET_94BB:     
RET

SUB_94BC:
    LD      D, 0
    LD      E, A
    LD      HL, $7188
    BIT     6, (HL)
    JR      Z, LOC_94CB
    LD      HL, BYTE_9673
    JR      LOC_94CE
LOC_94CB:
    LD      HL, BYTE_964B
LOC_94CE:
    ADD     HL, DE
    LD      D, (HL)
    LD      (IY+3), D
    LD      ($7168), IY
    LD      BC, 4
    ADD     IY, BC
    LD      A, ($7165)
    BIT     3, A
    JP      NZ, LOCRET_9519
    BIT     2, A
    JP      NZ, LOCRET_9519
    LD      A, ($7220)
    CP      1
    JR      Z, LOC_9507
    LD      A, (IY+0)
    LD      (IY+4), A
    LD      A, (IY+1)
    LD      (IY+5), A
    LD      A, (IY+2)
    LD      (IY+6), A
    LD      A, 67H
    LD      (IY+7), A
LOC_9507:
    LD      A, ($7162)
    LD      (IY+0), A
    LD      A, ($7163)
    LD      (IY+1), A
    LD      A, ($7164)
    LD      (IY+2), A
LOCRET_9519:     
RET

SUB_951A:
    PUSH    AF
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IX
    PUSH    IY
    LD      IY, ($7179)
    LD      IX, ($7179)
    LD      A, 0
    CP      (IX+21H)
    JR      NZ, LOC_9535
    RES     3, (IX+0)
LOC_9535:
    CALL    SUB_960A
    CALL    SUB_962E
    LD      ($7168), IY
    LD      BC, 1
    ADD     IY, BC
    LD      BC, 4
    JR      LOC_954D
LOC_9549:
    LD      ($7168), IY
LOC_954D:
    ADD     IY, BC
    BIT     7, (IY+0)
    JP      NZ, LOC_95A4
    BIT     3, (IX+0)
    JP      Z, LOC_9549
    BIT     4, (IX+0)
    JP      NZ, LOC_9549
    BIT     2, (IX+0)
    JP      NZ, LOC_9571
    SET     4, (IX+0)
    JR      LOC_9549
LOC_9571:
    DEC     (IX+21H)
    LD      HL, ($7168)
    LD      ($7166), IX
    LD      DE, ($7166)
    LD      A, D
    CP      H
    JP      NZ, LOC_9598
    LD      A, E
    CP      L
    JP      NZ, LOC_9598
    LD      A, (HL)
    AND     83H
    PUSH    AF
    SLA     A
    SLA     A
    POP     HL
    OR      H
    LD      (IY+0), A
    JR      LOC_959E
LOC_9598:
    LD      A, (HL)
    SET     7, A
    LD      (IY+0), A
LOC_959E:
    SET     4, (IX+0)
    JR      LOC_9549
LOC_95A4:
    CALL    SUB_960A
    CALL    SUB_962E
    BIT     4, (IY+0)
    JP      Z, LOC_9549
    ADD     IY, BC
    CALL    SUB_960A
    CALL    SUB_962E
    LD      A, ($7220)
    CP      0
    JR      NZ, LOC_95C7
    BIT     2, (IX+0)
    JP      NZ, LOC_95EB
LOC_95C7:
    ADD     IY, BC
    CP      1
    JR      NZ, LOC_95E5
    PUSH    IX
    LD      IX, ($7189)
    BIT     1, (IX+0DH)
    POP     IX
    JR      Z, LOC_95E5
    LD      (IY+3), 6AH
    PUSH    HL
    LD      HL, $70B0
    INC     (HL)
    POP     HL
LOC_95E5:
    CALL    SUB_960A
    CALL    SUB_962E
LOC_95EB:
    BIT     3, (IX+0)
    JP      Z, LOC_95FD
    BIT     4, (IX+0)
    JP      NZ, LOC_95FD
    RES     3, (IX+0)
LOC_95FD:
    RES     4, (IX+0)
    POP     IY
    POP     IX
    POP     HL
    POP     DE
    POP     BC
    POP     AF
RET

SUB_960A:
    PUSH    BC
    LD      B, 5
    LD      H, 0
    LD      L, (IY+1)
LOC_9612:
    ADD     HL, HL
    DJNZ    LOC_9612
    LD      D, 0
    LD      E, (IY+2)
    ADD     HL, DE
    LD      DE, 1800H
    ADD     HL, DE
    EX      DE, HL
    LD      ($7166), IY
    LD      HL, ($7166)
    LD      B, 0
    LD      C, 3
    ADD     HL, BC
    POP     BC
RET

SUB_962E:
    PUSH    BC
    LD      BC, 1
    BIT     7, D
    JR      Z, LOC_9638
LOC_9636:
    JR      $
LOC_9638:
    RST     8
    POP     BC
RET

BYTE_963B:
	DB 128,130,131,103,133,129,103,131,132,103,129,130,103,132,133,128
BYTE_964B:
	DB 117,120,122,103,126,111,103,123,125,103,108,121,103,124,127,114
BYTE_965B:
	DB 134,136,138,140
BYTE_965F:
	DB 143,145,147,149
BYTE_9663:
	DB 142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142
BYTE_9673:
	DB 151,154,155,103,161,157,103,165,156,103,162,160,103,166,167,168

LOC_9683:
    LD      ($7010), DE
    LD      A, C
    OR      A
    JR      Z, LOC_969F
    PUSH    BC
    LD      B, 0
    PUSH    HL
    LD      L, E
    LD      H, D
    ADD     HL, BC
    LD      ($7010), HL
    POP     HL
    CALL    WRITE_VRAM
    POP     BC
    LD      C, 0
    LD      A, B
    OR      A
    RET     Z
LOC_969F:
    LD      DE, ($7010)
    CALL    WRITE_VRAM
RET

SUB_96A7:
    CALL    SUB_96B1
    PUSH    DE
    LD      DE, 1800H
    ADD     HL, DE
    POP     DE
RET

SUB_96B1:
    PUSH    BC
    PUSH    DE
    EX      DE, HL
    LD      L, D
    LD      H, 0
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    LD      D, 0
    ADD     HL, DE
    POP     DE
    POP     BC
RET

SUB_96C2:
    PUSH    BC
    PUSH    DE
    PUSH    HL
    EX      DE, HL
    LD      HL, $7014
    LD      BC, 1
    CALL    READ_VRAM
    LD      A, ($7014)
    POP     HL
    POP     DE
    POP     BC
RET

SUB_96D6:
    PUSH    BC
    PUSH    DE
    PUSH    HL
    EX      DE, HL
    LD      HL, $7015
    LD      (HL), A
    LD      BC, 1
    RST     8
    POP     HL
    POP     DE
    POP     BC
RET

INIT_DAY_TIME:   
    LD      HL, 0
    LD      DE, 60H
    LD      A, 16H
    CALL    WRITE_TO_COLOR_TABLE
    LD      HL, COLORS_DAY
    LD      BC, 300H
    LD      DE, 60H
    CALL    SETUP_COLOR_TABLE
    LD      HL, 360H
    LD      DE, 1F8H
    LD      A, 1BH
    CALL    WRITE_TO_COLOR_TABLE
    LD      HL, 558H
    LD      DE, 40H
    LD      A, 6BH
    CALL    WRITE_TO_COLOR_TABLE
    LD      HL, 598H
    LD      DE, 78H
    LD      A, 1BH
    CALL    WRITE_TO_COLOR_TABLE
    LD      HL, 610H
    LD      DE, 8
    LD      A, 16H
    CALL    WRITE_TO_COLOR_TABLE
    LD      DE, 0
    LD      HL, 618H
    ADD     HL, DE
    LD      DE, 50H
    LD      A, 16H
    CALL    WRITE_TO_COLOR_TABLE
    LD      BC, 706H
    CALL    WRITE_REGISTER
RET

INIT_NIGHT_TIME: 
    LD      BC, 704H
    CALL    WRITE_REGISTER
    LD      HL, 0
    LD      DE, 60H
    LD      A, 1DH
    CALL    WRITE_TO_COLOR_TABLE
    LD      HL, COLORS_NIGHT
    LD      BC, 300H
    LD      DE, 60H
    CALL    SETUP_COLOR_TABLE
    LD      HL, 360H
    LD      DE, 110H
    LD      A, 74H
    CALL    WRITE_TO_COLOR_TABLE
    LD      HL, 470H
    LD      DE, 0E8H
    LD      A, 0F4H
    CALL    WRITE_TO_COLOR_TABLE
    LD      HL, 558H
    LD      DE, 40H
    LD      A, 0F4H
    CALL    WRITE_TO_COLOR_TABLE
    LD      HL, 598H
    LD      DE, 78H
    LD      A, 0F4H
    CALL    WRITE_TO_COLOR_TABLE
    LD      HL, 610H
    LD      DE, 8
    LD      A, 1DH
    CALL    WRITE_TO_COLOR_TABLE
    LD      DE, 0
    LD      HL, 618H
    ADD     HL, DE
    LD      DE, 50H
    LD      A, 1DH
    CALL    WRITE_TO_COLOR_TABLE
RET

SETUP_COLOR_TABLE:  
    PUSH    BC
    PUSH    DE
    PUSH    HL
    LD      HL, 2000H
    ADD     HL, DE
    EX      DE, HL
    POP     HL
    PUSH    HL
    RST     8
    POP     HL
    POP     DE
    POP     BC
    PUSH    BC
    PUSH    DE
    PUSH    HL
    LD      HL, 2800H
    ADD     HL, DE
    EX      DE, HL
    POP     HL
    PUSH    HL
    RST     8
    POP     HL
    POP     DE
    POP     BC
    PUSH    HL
    LD      HL, 3000H
    ADD     HL, DE
    EX      DE, HL
    POP     HL
    RST     8
RET

WRITE_TO_COLOR_TABLE:
    PUSH    AF
    PUSH    DE
    PUSH    HL
    LD      BC, 2000H
    ADD     HL, BC
    CALL    FILL_VRAM
    POP     HL
    POP     DE
    POP     AF
    PUSH    AF
    PUSH    DE
    PUSH    HL
    LD      BC, 2800H
    ADD     HL, BC
    CALL    FILL_VRAM
    POP     HL
    POP     DE
    POP     AF
    LD      BC, 3000H
    ADD     HL, BC
    CALL    FILL_VRAM
RET

INIT_PATTERNS:   
    LD      HL, GAME_PATTERNS
    LD      BC, 618H
    LD      DE, 0
    CALL    SETUP_PATTERN_TABLE
    LD      DE, 0
    LD      HL, 618H
    ADD     HL, DE
    EX      DE, HL
    LD      BC, 50H
    LD      HL, (NUMBER_TABLE)

SETUP_PATTERN_TABLE:
    PUSH    BC
    PUSH    DE
    PUSH    HL
    LD      HL, 0
    ADD     HL, DE
    EX      DE, HL
    POP     HL
    PUSH    HL
    RST     8
    POP     HL
    POP     DE
    POP     BC
    PUSH    BC
    PUSH    DE
    PUSH    HL
    LD      HL, 800H
    ADD     HL, DE
    EX      DE, HL
    POP     HL
    PUSH    HL
    RST     8
    POP     HL
    POP     DE
    POP     BC
    PUSH    HL
    LD      HL, 1000H
    ADD     HL, DE
    EX      DE, HL
    POP     HL
    RST     8
RET

CLEAR_SCREEN:    
    LD      HL, 1800H
    LD      A, 67H
    LD      DE, 300H
    CALL    FILL_VRAM
RET

INIT_SPRITES:    
    PUSH    IX
    LD      HL, MONSTER_PATTERNS
    LD      DE, 3800H
    LD      BC, 1E0H
    RST     8
    LD      B, 20H
    LD      IY, MONSTER_SPRITE_ATTR
SPRITE_MIRROR_VERTICAL:      
    PUSH    BC
    PUSH    IY
    LD      E, (IY+0)
    LD      D, 0
    LD      L, (IY+1)
    LD      H, 0
    LD      BC, 1
    LD      A, 1
    CALL    REFLECT_VERTICAL
    POP     IY
    INC     IY
    INC     IY
    POP     BC
    DJNZ    SPRITE_MIRROR_VERTICAL
    LD      B, 0CH
    LD      IY, MIRROR_ATTR
SPRITE_MIRROR_HORIZONTAL:    
    PUSH    BC
    PUSH    IY
    LD      E, (IY+0)
    LD      D, 0
    LD      L, (IY+1)
    LD      H, 0
    LD      BC, 1
    LD      A, 1
    CALL    REFLECT_HORZONTAL
    POP     IY
    INC     IY
    INC     IY
    POP     BC
    DJNZ    SPRITE_MIRROR_HORIZONTAL
    POP     IX
RET

MONSTER_SPRITE_ATTR:
	DB  0CH, 4AH, 0DH, 4BH
    DB  0EH, 48H, 0FH, 49H
    DB  10H, 4EH, 11H, 4FH
    DB  12H, 4CH, 13H, 4DH
    DB  14H, 52H, 15H, 53H
    DB  16H, 50H, 17H, 51H
    DB  18H, 56H, 19H, 57H
    DB  1AH, 54H, 1BH, 55H
    DB  1CH, 5AH, 1DH, 5BH
    DB  1EH, 58H, 1FH, 59H
    DB  20H, 5EH, 21H, 5FH
    DB  22H, 5CH, 23H, 5DH
    DB  24H, 62H, 25H, 63H
    DB  26H, 60H, 27H, 61H
    DB  28H, 66H, 29H, 67H
    DB  2AH, 64H, 2BH, 65H
MIRROR_ATTR:
    DB  00H, 3DH, 01H, 3CH 
    DB  02H, 3FH, 03H, 3EH
    DB  04H, 41H, 05H, 40H
    DB  06H, 43H, 07H, 42H
    DB  08H, 45H, 09H, 44H
    DB  0AH, 47H, 0BH, 46H

DISPLAY_TIME_OF_DAY:
    PUSH    AF
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IX
    PUSH    IY
    CALL    UPDATE_SCORE_B
    LD      IX, $718B
    LD      ($717B), IX
    LD      HL, ($7072)
    LD      IX, ($7072)
    LD      A, (IX+1)
    CP      8
    JR      NC, LOC_9940
    INC     (IX+1)
    LD      A, (IX+2)
    LD      ($7099), A
    LD      DE, 3
    ADD     HL, DE
    PUSH    HL
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    EX      DE, HL
    LD      DE, 0EH
    ADD     HL, DE
    LD      ($7189), HL
    LD      IX, ($7189)
    EX      DE, HL
    POP     HL
    LD      (HL), E
    INC     HL
    LD      (HL), D
    XOR     A
    LD      ($70A6), A
    JR      INIT_TIME_OF_DAY_WITH_REGISTER_PROTECTION

INIT_NIGHT_TIME_WITH_REGISTER_PROTECTION:
    PUSH    AF
    PUSH    BC
    PUSH    HL
    PUSH    IX
    PUSH    IY
    CALL    INIT_NIGHT_TIME
    POP     IY
    POP     IX
    POP     HL
    POP     BC
    POP     AF
    JR      LOC_99BE
LOC_9940:
    LD      A, 4
    CP      (IX+2)
    JR      Z, LOC_994A
    INC     (IX+2)
LOC_994A:
    LD      (IX+1), 1
    PUSH    HL
    LD      HL, BYTE_BF89
    LD      (IX+3), L
    LD      (IX+4), H
    LD      L, (IX+5)
    LD      H, (IX+6)
    LD      DE, 3
    ADD     HL, DE
    LD      (IX+5), L
    LD      (IX+6), H
    POP     HL
    JR      LOC_9983

SET_TIME_OF_DAY: 
    PUSH    AF
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IX
    PUSH    IY
    LD      HL, $7187
    LD      (HL), 0FCH
    LD      IX, $718B
    LD      ($717B), IX
    LD      HL, ($7072)
LOC_9983:
    LD      IX, ($7072)
    LD      A, (IX+2)
    LD      ($7099), A
    LD      DE, 3
    ADD     HL, DE
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    LD      ($7189), DE
    INC     HL
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    LD      A, (DE)
    LD      ($7181), A
    LD      IX, ($7189)
INIT_TIME_OF_DAY_WITH_REGISTER_PROTECTION:
    CALL    SUB_BF2D
    BIT     3, (IX+0DH)
    JR      NZ, INIT_NIGHT_TIME_WITH_REGISTER_PROTECTION
    PUSH    AF
    PUSH    HL
    PUSH    BC
    PUSH    IY
    PUSH    IX
    CALL    INIT_DAY_TIME
    POP     IX
    POP     IY
    POP     BC
    POP     HL
    POP     AF
LOC_99BE:
    LD      A, 0AH
    LD      ($716B), A
    LD      A, 5
    LD      ($7185), A
    LD      A, 5
    LD      ($7184), A
    LD      A, 0
    LD      ($7186), A
LOC_99D2:
    LD      A, 0
    LD      HL, $7185
    CP      (HL)
    JP      Z, LOC_9A74
    DEC     (HL)
    LD      IY, $71DC
    LD      ($7179), IY
    LD      A, ($7099)
    CP      1
    JR      Z, LOC_99ED
    INC     IX
LOC_99ED:
    LD      B, (IX+0)
    INC     IX
    JR      NZ, LOC_99F6
    INC     IX
LOC_99F6:
    LD      A, 0
    CP      B
    JR      Z, LOC_99D2
    PUSH    IX
    LD      IX, ($717B)
LOC_9A01:
    LD      A, (IX+1)
    BIT     7, A
    JR      NZ, LOC_9A23
    LD      E, (IX+0)
    AND     3FH
    LD      D, A
    LD      (IX+1), A
    CALL    SUB_9A58
    LD      DE, 2
    ADD     IX, DE
    LD      ($717B), IX
    DJNZ    LOC_9A01
    POP     IX
    JR      LOC_99D2
LOC_9A23:
    LD      DE, 2
    ADD     IX, DE
    LD      ($717B), IX
    JR      LOC_9A01

CHECK_IF_ALL_SNAKES_ARE_DEAD:
    LD      A, ($7151)
    CP      0
    JR      Z, LOC_9A54
    PUSH    BC
    PUSH    AF
    LD      B, 7
    LD      A, ($70A6)
    AND     0FH
    LD      C, A
    INC     A
    LD      ($70A6), A
    CALL    WRITE_REGISTER
    POP     AF
    POP     BC
    LD      HL, $7151
    DEC     (HL)
    RET     NZ
    CALL    DISPLAY_TIME_OF_DAY
    CALL    FLASH_SCREEN_RED
RET

LOC_9A54:
    CALL    GAINED_SOME_SCORE_A
RET

SUB_9A58:
    LD      ($717D), DE
    PUSH    IX
    PUSH    IY
    PUSH    BC
    CALL    SUB_9A87
    LD      HL, $71DC
    CALL    SUB_BDB0
    POP     BC
    POP     IY
    POP     IX
    LD      HL, $7223
    INC     (HL)
RET

LOC_9A74:
    POP     IY
    POP     IX
    POP     HL
    POP     DE
    POP     BC
    POP     AF
    LD      A, 4
    LD      ($717F), A
    LD      A, 2
    LD      ($7180), A
RET

SUB_9A87:
    LD      IX, HUD_RELATED_DATA_B
    LD      IY, $71DC
    LD      A, ($7184)
    CP      0AH
    JR      Z, LOC_9A9E
    CP      0DH
    JR      Z, LOC_9A9E
    CP      0FH
    JR      NZ, LOC_9AAA
LOC_9A9E:
    INC     A
    LD      ($7184), A
    LD      A, ($7186)
    XOR     1
    LD      ($7186), A
LOC_9AAA:
    LD      A, ($7186)
    LD      E, A
    LD      D, 0
    ADD     IX, DE
    LD      A, 1
    XOR     E
    LD      ($7186), A
    LD      A, (IX+0)
    LD      (IY+0), A
    LD      A, ($7184)
    LD      (IY+1), A
    LD      (IY+16H), A
    LD      (IY+1AH), A
    LD      A, (IX+2)
    LD      (IY+2), A
    LD      (IY+17H), A
    LD      A, 0AH
    LD      (IY+4), A
    LD      A, (IX+4)
    LD      (IY+15H), A
    LD      (IY+19H), A
    LD      A, (IX+6)
    LD      (IY+1BH), A
    LD      A, ($7185)
    LD      (IY+21H), A
    PUSH    IY
    PUSH    BC
    PUSH    HL
    LD      HL, $7184
    INC     (HL)
    PUSH    IX
    LD      IX, ($7072)
    LD      A, (IX+2)
    POP     IX
    CP      1
    JR      Z, LOC_9B24
    PUSH    IX
    LD      IX, ($7189)
    BIT     2, (IX+0DH)
    POP     IX
    JR      Z, LOC_9B24
    LD      HL, $7187
    INC     (HL)
    JR      NZ, LOC_9B24
    LD      (HL), 0FCH
    SET     6, (IY+15H)
    LD      HL, ($717B)
    INC     HL
    SET     6, (HL)
LOC_9B24:
    POP     HL
    LD      DE, 5
    ADD     IY, DE
    LD      DE, 4
    LD      B, 4
LOC_9B2F:
    RES     7, (IY+0)
    ADD     IY, DE
    DJNZ    LOC_9B2F
    POP     BC
    POP     IY
RET

HUD_RELATED_DATA_B:
	DB 137,138,002,029,149,154,001,030
HUD_RELATED_DATA_A:
	DB 000,000,000,000,000,000

DRAW_HUD_00:     
    LD      HL, HUD_01
    LD      DE, 1800H
    LD      BC, 80H
    RST     8
    PUSH    IX
    LD      IX, ($7072)
    BIT     1, (IX+0)
    JR      Z, DRAW_HUD_01
    LD      A, 68H
    LD      HL, 180AH
    LD      DE, 1
    CALL    FILL_VRAM
DRAW_HUD_01:     
    LD      A, (IX+0AH)
    DEC     A
    POP     IX
    LD      B, A
    LD      A, 0DH
    ADD     A, B
    LD      D, 1
    LD      E, A
    CALL    SUB_A2C6
    LD      HL, HUD_RELATED_DATA_A
    LD      BC, 6
    RST     8
    LD      HL, 1880H
    LD      DE, 280H
    LD      A, 67H
    CALL    FILL_VRAM
    LD      HL, BOULDER_01_TOP
    LD      DE, 1934H
    LD      BC, 6
    RST     8
    LD      HL, BOULDER_01_BOTTOM
    LD      DE, 1953H
    LD      BC, 9
    RST     8
    LD      HL, BOULDER_02_TOP
    LD      DE, 19A5H
    LD      BC, 6
    RST     8
    LD      HL, BOULDER_02_MIDDLE
    LD      DE, 19C4H
    LD      BC, 8
    RST     8
    LD      HL, BOULDER_02_BOTTOM
    LD      DE, 19E5H
    LD      BC, 7
    RST     8
    CALL    MORE_HUD_SOMETHING
    CALL    HUD_RAM_SOMETHING
RET

HUD_01:
	DB 000,000,000,001,002,003,004,005,006,000,105,000,104,104,104,104,104,104,000,007,008,009,010,011,000,000,000,000,000,000,000,000
HUD_02:
	DB 000,012,013,014,015,016,001,194,000,000,000,000,000,102,102,102,102,102,102,000,000,000,000,000,000,000,052,055,058,000,000,000
    DB 100,100,100,017,018,019,020,021,022,100,030,032,100,100,100,037,039,100,100,100,044,046,100,100,100,100,053,056,059,100,100,100
    DB 101,101,101,023,024,025,026,027,028,029,031,033,034,035,036,038,040,041,042,043,045,047,048,049,050,051,054,057,060,061,062,063
BOULDER_01_TOP:
	DB 086,088,090,092,094,096
BOULDER_01_BOTTOM:
	DB 085,087,089,091,093,095,097,098,099
BOULDER_02_TOP:
	DB 065,068,071,074,077,080
BOULDER_02_MIDDLE:
	DB 064,066,069,072,075,078,081,083
BOULDER_02_BOTTOM:
	DB 067,070,073,076,079,082,084

MORE_HUD_SOMETHING: 
    PUSH    AF
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IX
    PUSH    IY
    LD      HL, ($7072)
    BIT     7, (HL)
    JR      Z, SOME_HUD_SUB_01
    BIT     1, (HL)
    JR      Z, SOME_HUD_SUB_02
    LD      IX, (WORD_86B7)
    LD      A, ($7075)
    LD      B, A
    JR      SOME_HUD_SUB_03
SOME_HUD_SUB_02: 
    LD      IX, (WORD_86B5)
    LD      A, ($7074)
    LD      B, A
SOME_HUD_SUB_03: 
    LD      ($70B0), A
    CP      0
    JR      Z, SOME_HUD_SUB_05
SOME_HUD_SUB_04: 
    PUSH    IX
    POP     DE
    LD      HL, $7182
    PUSH    BC
    PUSH    IX
    LD      BC, 2
    CALL    READ_VRAM
    POP     IX
    POP     BC
    LD      A, ($7182)
    LD      L, A
    LD      A, ($7183)
    AND     3FH
    LD      H, A
    LD      DE, 1
    LD      A, 6AH
    PUSH    IX
    PUSH    BC
    CALL    FILL_VRAM
    POP     BC
    POP     IX
    INC     IX
    INC     IX
    DJNZ    SOME_HUD_SUB_04
SOME_HUD_SUB_05: 
    POP     IY
    POP     IX
    POP     HL
    POP     DE
    POP     BC
    POP     AF
RET

SOME_HUD_SUB_01: 
    SET     7, (HL)
    LD      A, 14H
    LD      ($70B0), A
    LD      B, 14H
SOME_HUD_SUB_06: 
    PUSH    BC
    LD      A, R
    AND     1FH
    LD      B, A
SOME_HUD_SUB_07: 
    CALL    RAND_GEN
    DJNZ    SOME_HUD_SUB_07
    POP     BC
    CP      4
    JP      M, SOME_HUD_SUB_06
    CP      18H
    JP      P, SOME_HUD_SUB_06
    LD      L, A
    LD      H, 0
    PUSH    BC
    LD      B, 5
SOME_HUD_SUB_08: 
    ADD     HL, HL
    DJNZ    SOME_HUD_SUB_08
    POP     BC
    PUSH    HL
SOME_HUD_SUB_09: 
    CALL    RAND_GEN
    CP      1
    JP      M, SOME_HUD_SUB_09
    CP      1FH
    JP      P, SOME_HUD_SUB_09
    LD      E, A
    LD      D, 0
    POP     HL
    ADD     HL, DE
    LD      DE, 1800H
    ADD     HL, DE
    EX      DE, HL
    PUSH    BC
    PUSH    DE
    LD      BC, 1
    LD      HL, $7153
    PUSH    HL
    CALL    READ_VRAM
    POP     HL
    POP     DE
    POP     BC
    LD      A, (HL)
    LD      C, 67H
    CP      C
    JR      NZ, SOME_HUD_SUB_06
    LD      (HL), 6AH
    PUSH    BC
    LD      BC, 1
    CALL    WRITE_VRAM
    POP     BC
    DJNZ    SOME_HUD_SUB_06
    POP     IY
    POP     IX
    POP     HL
    POP     DE
    POP     BC
    POP     AF
RET

HUD_RAM_SOMETHING:  
    LD      HL, BYTE_9D45
    LD      DE, $718B
    LD      BC, 50H
    LDIR
RET

BYTE_9D45:
	DB 104,006,138,006,172,006,206,006,240,006,018,007,052,007,086,007,120,007,154,007,188,007,104,014,138,014,172,014,206,014,240,014,018,015,052,015,086,015,120,015
    DB 154,015,188,015,104,022,138,022,172,022,206,022,240,022,018,023,052,023,086,023,120,023,154,023,188,023,104,038,138,038,172,038,206,038,240,038,018,039,052,039

SUB_9D95:
    LD      A, 0
    LD      HL, $7142
    CP      (HL)
    JR      Z, LOC_9D9E
    DEC     (HL)
LOC_9D9E:
    LD      HL, $70C2
    LD      DE, WORK_BUFFER
    LD      BC, 4
    LDIR
    LD      HL, $70CE
    LD      BC, 4
    LDIR
    LD      A, ($70C1)
    INC     A
    CP      0AH
    JR      C, LOC_9DBB
    LD      A, 2
LOC_9DBB:
    LD      ($70C1), A
    PUSH    AF
    LD      B, A
    LD      A, 0AH
    SUB     B
    LD      B, A
    LD      A, 8
    SUB     B
    LD      C, A
    POP     AF
    LD      L, A
    LD      H, 0
    ADD     HL, HL
    ADD     HL, HL
    PUSH    HL
    ADD     HL, HL
    POP     DE
    ADD     HL, DE
    LD      DE, $70C2
    ADD     HL, DE
    LD      DE, $724B
LOC_9DD9:
    PUSH    BC
    LD      A, (HL)
    CP      0BFH
    JR      NC, LOC_9DE6
    LD      BC, 4
    LDIR
    JR      LOC_9DEA
LOC_9DE6:
    INC     HL
    INC     HL
    INC     HL
    INC     HL
LOC_9DEA:
    LD      BC, 8
    ADD     HL, BC
    POP     BC
    DJNZ    LOC_9DD9
    LD      A, C
    OR      A
    JR      Z, LOC_9E11
    LD      HL, $70DA
    LD      B, C
LOC_9DF9:
    PUSH    BC
    LD      A, (HL)
    CP      0BFH
    JR      NC, LOC_9E06
    LD      BC, 4
    LDIR
    JR      LOC_9E0A
LOC_9E06:
    INC     HL
    INC     HL
    INC     HL
    INC     HL
LOC_9E0A:
    LD      BC, 8
    ADD     HL, BC
    POP     BC
    DJNZ    LOC_9DF9
LOC_9E11:
    EX      DE, HL
    LD      (HL), 0D0H
    LD      HL, 0AH
    ADD     HL, HL
    ADD     HL, HL
    LD      C, L
    LD      B, H
    INC     BC
    LD      HL, WORK_BUFFER
    LD      DE, 1F00H
    RST     8
RET

UPDATE_ROLLER_CONTROLLER:    
    PUSH    AF
    PUSH    HL
    CALL    UPDATE_SPINNER
    POP     HL
    POP     AF
    EI
RETI

SOME_CONTROLLER_CHECK:       
    PUSH    IX
    PUSH    IY
    LD      IX, $70C2
    LD      IY, CONTROLLER_BUFFER
    LD      A, (IX+1)
    LD      ($7224), A
    LD      A, (IX+0)
    LD      ($7225), A
    LD      A, (IY+4)
    NEG
    BIT     7, A
    JR      NZ, SOME_CONTROLLER_CHECK_SUB_00
    ADD     A, (IX+1)
    JR      C, SOME_CONTROLLER_CHECK_SUB_01
    CP      0EBH
    JR      C, SOME_CONTROLLER_CHECK_SUB_03
SOME_CONTROLLER_CHECK_SUB_01:
    LD      A, 0EBH
    JR      SOME_CONTROLLER_CHECK_SUB_03
SOME_CONTROLLER_CHECK_SUB_00:
    NEG
    LD      B, A
    LD      A, (IX+1)
    CP      B
    JR      C, SOME_CONTROLLER_CHECK_SUB_02
    SUB     B
    CP      5
    JR      NC, SOME_CONTROLLER_CHECK_SUB_03
SOME_CONTROLLER_CHECK_SUB_02:
    LD      A, 5
SOME_CONTROLLER_CHECK_SUB_03:
    LD      (IX+1), A
    LD      A, (IY+9)
    BIT     7, A
    JR      NZ, SOME_CONTROLLER_CHECK_SUB_05
    ADD     A, (IX+0)
    JR      C, SOME_CONTROLLER_CHECK_SUB_04
    CP      0AFH
    JR      C, SOME_CONTROLLER_CHECK_SUB_07
SOME_CONTROLLER_CHECK_SUB_04:
    LD      A, 0AFH
    JR      SOME_CONTROLLER_CHECK_SUB_07
SOME_CONTROLLER_CHECK_SUB_05:
    NEG
    LD      B, A
    LD      A, (IX+0)
    CP      B
    JR      C, SOME_CONTROLLER_CHECK_SUB_06
    SUB     B
    CP      1FH
    JR      NC, SOME_CONTROLLER_CHECK_SUB_07
SOME_CONTROLLER_CHECK_SUB_06:
    LD      A, 1FH
SOME_CONTROLLER_CHECK_SUB_07:
    LD      (IX+0), A
    LD      (IY+4), 0
    LD      (IY+9), 0
    CALL    SUB_9F2D
    LD      A, (IX+1)
    LD      ($70CF), A
    LD      ($70DB), A
    LD      A, (IX+0)
    SUB     8
    LD      ($70CE), A
    ADD     A, 10H
    LD      ($70DA), A
    LD      A, 0
    LD      HL, $7141
    CP      (HL)
    JR      NZ, SOME_CONTROLLER_CHECK_SUB_08
    PUSH    HL
    LD      HL, $7142
    CP      (HL)
    POP     HL
    JR      NZ, SOME_CONTROLLER_CHECK_SUB_10
    LD      (HL), 1
    LD      A, (IY+5)
    OR      (IY+7)
    JR      Z, SOME_CONTROLLER_CHECK_SUB_09
    LD      (IX+2), 3CH
    LD      (IX+0EH), 44H
    LD      (IX+1AH), 40H
    LD      (IX+0FH), 0FH
    LD      (IX+1BH), 6
    LD      (IX+4), 4
    LD      HL, $7144
    BIT     7, (HL)
    JR      NZ, SOME_CONTROLLER_CHECK_SUB_10
    CALL    SUB_A2F1
    CALL    PLAY_FIRE_LASER_SOUND
    JR      SOME_CONTROLLER_CHECK_SUB_10
SOME_CONTROLLER_CHECK_SUB_08:
    DEC     (HL)
    JR      SOME_CONTROLLER_CHECK_SUB_10
SOME_CONTROLLER_CHECK_SUB_09:
    LD      (IX+2), 0
    LD      (IX+0EH), 4
    LD      (IX+1AH), 8
    LD      (IX+0FH), 6
    LD      (IX+1BH), 0FH
    LD      (IX+4), 1
    LD      A, (IY+2)
    OR      (IY+0AH)
    JR      Z, SOME_CONTROLLER_CHECK_SUB_10
    LD      HL, $7144
    BIT     7, (HL)
    JR      NZ, SOME_CONTROLLER_CHECK_SUB_10
    CALL    SOME_CONTROLLER_CHECK_SUB_11
    CALL    PLAY_FIRE_LASER_SOUND
SOME_CONTROLLER_CHECK_SUB_10:
    POP     IY
    POP     IX
RET

SUB_9F2D:
    PUSH    IY
    DI
    LD      A, 0
    LD      ($723E), A
    LD      ($7240), A
    LD      ($7242), A
    JR      LOC_9F5B
LOC_9F3D:
    LD      A, (IX+1)
    LD      HL, $7224
    CP      (HL)
    JR      NZ, LOC_9F4D
    INC     HL
    LD      A, (IX+0)
    CP      (HL)
    JR      Z, LOC_9FB2
LOC_9F4D:
    LD      A, ($7240)
    CP      0
    JP      NZ, LOC_9F58
    CALL    SUB_9FB6
LOC_9F58:
    CALL    SUB_A07E
LOC_9F5B:
    LD      B, 2
    LD      IY, $70F2
LOC_9F61:
    LD      A, (IY+0)
    LD      HL, $7225
    SUB     (HL)
    BIT     7, A
    JR      Z, LOC_9F6E
    NEG
LOC_9F6E:
    CP      8
    JP      P, LOC_9F87
    LD      A, (IY+1)
    LD      HL, $7224
    SUB     (HL)
    BIT     7, A
    JR      Z, LOC_9F80
    NEG
LOC_9F80:
    CP      8
    JP      P, LOC_9F87
    JR      LOC_9FA1
LOC_9F87:
    LD      IY, $70E6
    DJNZ    LOC_9F61
    CALL    SUB_A193
    LD      A, ($7241)
    CP      0FFH
    JR      NZ, LOC_9F3D
    LD      A, 0
    LD      ($722F), A
    LD      ($7241), A
    JR      LOC_9FB2
LOC_9FA1:
    LD      A, ($7224)
    LD      (IX+1), A
    LD      A, ($7225)
    LD      (IX+0), A
    LD      A, 0FFH
    LD      ($723E), A
LOC_9FB2:
    EI
    POP     IY
RET

SUB_9FB6:
    LD      A, 1
    LD      ($7240), A
    LD      A, 0
    LD      ($722F), A
    LD      A, (IX+1)
    LD      HL, $7224
    SUB     (HL)
    LD      ($722A), A
    JR      NC, LOC_9FCE
    NEG
LOC_9FCE:
    LD      ($722C), A
    LD      A, (IX+0)
    LD      HL, $7225
    SUB     (HL)
    LD      ($722B), A
    JR      NC, LOC_9FDF
    NEG
LOC_9FDF:
    LD      ($722D), A
    PUSH    AF
    CP      0
    JR      Z, LOC_A061
    LD      A, ($722C)
    CP      0
    JR      Z, LOC_A06C
    POP     AF
    LD      B, 0
    LD      HL, $722C
    CP      (HL)
    JP      Z, LOC_A013
    JP      P, LOC_A006
    LD      A, 1
    LD      ($722F), A
    LD      HL, $722D
    LD      A, ($722C)
LOC_A006:
    LD      ($723F), A
    SUB     (HL)
    JR      C, LOC_A01D
    PUSH    AF
    INC     B
    POP     AF
    JR      Z, LOC_A027
    JR      LOC_A006
LOC_A013:
    LD      A, 1
    LD      ($7242), A
    LD      A, ($722C)
    JR      LOC_A028
LOC_A01D:
    LD      C, (HL)
    SRA     C
    LD      A, ($723F)
    CP      C
    JR      C, LOC_A027
    INC     B
LOC_A027:
    LD      A, B
LOC_A028:
    LD      ($722E), A
    CP      9
    JR      C, LOC_A046
    LD      B, 0
    PUSH    AF
    SRL     A
    SRL     A
    SRL     A
    LD      B, A
    SLA     A
    SLA     A
    SLA     A
    LD      C, A
    POP     AF
    SUB     C
    JR      Z, LOC_A056
    JR      LOC_A04D
LOC_A046:
    LD      A, 0
    LD      ($7230), A
    JR      LOC_A077
LOC_A04D:
    LD      ($722E), A
    LD      A, B
    LD      ($7230), A
    JR      LOC_A077
LOC_A056:
    LD      A, B
    LD      ($7230), A
    LD      A, 0
    LD      ($722E), A
    JR      LOC_A077
LOC_A061:
    POP     AF
    LD      A, 1
    LD      ($722F), A
    LD      A, ($722C)
    JR      LOC_A028
LOC_A06C:
    POP     AF
    LD      A, 0
    LD      ($722F), A
    LD      A, ($722D)
    JR      LOC_A028
LOC_A077:
    LD      A, ($7230)
    LD      ($7231), A
RET

SUB_A07E:
    PUSH    AF
    PUSH    DE
    PUSH    HL
    PUSH    IX
    PUSH    IY
    LD      A, ($7224)
    LD      ($7226), A
    LD      A, ($7225)
    LD      ($7227), A
    LD      A, ($722F)
    CP      0
    JR      NZ, LOC_A0A9
    LD      HL, $7225
    PUSH    HL
    LD      IX, $722B
    LD      IY, $722A
    LD      HL, $7224
    JR      LOC_A0B8
LOC_A0A9:
    LD      HL, $7224
    PUSH    HL
    LD      HL, $7225
    LD      IX, $722A
    LD      IY, $722B
LOC_A0B8:
    PUSH    HL
    LD      A, 0
    LD      HL, $7230
    CP      (HL)
    JR      Z, LOC_A0CE
    DEC     (HL)
    POP     HL
    LD      A, ($7242)
    CP      0
    JR      NZ, LOC_A128
    LD      B, 8
    JR      LOC_A141
LOC_A0CE:
    POP     HL
    LD      A, (IY+0)
    CP      0
    JR      Z, LOC_A13D
    LD      B, A
    LD      B, 1
    CP      (IY+2)
    JR      Z, LOC_A0E2
    LD      A, B
    NEG
    LD      B, A
LOC_A0E2:
    LD      A, ($7242)
    CP      0
    JR      NZ, LOC_A0F5
    LD      A, ($7231)
    CP      0
    JR      NZ, LOC_A119
LOC_A0F0:
    LD      A, (HL)
    ADD     A, B
    LD      (HL), A
    JR      LOC_A13D
LOC_A0F5:
    LD      A, ($7231)
    CP      0
    JR      NZ, LOC_A115
    LD      A, ($722E)
LOC_A0FF:
    PUSH    AF
    LD      B, A
    LD      A, (IY+0)
    CP      (IY+2)
    JR      Z, LOC_A10E
    POP     AF
    PUSH    AF
    NEG
    LD      B, A
LOC_A10E:
    LD      A, (HL)
    ADD     A, B
    LD      (HL), A
    POP     AF
    LD      B, A
    JR      LOC_A141
LOC_A115:
    LD      A, 8
    JR      LOC_A0FF
LOC_A119:
    LD      A, (IY+0)
    CP      (IY+2)
    LD      A, 1
    JR      Z, LOC_A125
    NEG
LOC_A125:
    LD      B, A
    JR      LOC_A0F0
LOC_A128:
    LD      A, (IY+0)
    CP      (IY+2)
    LD      A, 8
    JR      Z, LOC_A134
    NEG
LOC_A134:
    LD      B, A
    LD      A, (HL)
    ADD     A, B
    LD      (HL), A
    LD      A, 8
    LD      B, A
    JR      LOC_A141
LOC_A13D:
    LD      A, ($722E)
    LD      B, A
LOC_A141:
    LD      A, (IX+0)
    CP      (IX+2)
    JR      Z, LOC_A14D
    LD      A, B
    NEG
    LD      B, A
LOC_A14D:
    POP     HL
    LD      A, (HL)
    ADD     A, B
    LD      (HL), A
    POP     IY
    POP     IX
    LD      A, ($7224)
    CP      0EBH
    JR      C, LOC_A16C
    LD      A, 0EBH
    LD      ($7224), A
    LD      (IX+1), A
    LD      A, ($7225)
    LD      (IX+0), A
    JR      LOC_A18A
LOC_A16C:
    LD      A, (IX+1)
    LD      HL, $7224
    SUB     (HL)
    JR      NC, LOC_A177
    NEG
LOC_A177:
    CP      5
    JR      NC, LOC_A18F
    LD      A, (IX+0)
    LD      HL, $7225
    SUB     (HL)
    JR      NC, LOC_A186
    NEG
LOC_A186:
    CP      5
    JR      NC, LOC_A18F
LOC_A18A:
    LD      A, 0FFH
    LD      ($7241), A
LOC_A18F:
    POP     HL
    POP     DE
    POP     AF
RET

SUB_A193:
    LD      A, ($7224)
    PUSH    AF
    ADD     A, 6
    LD      ($7232), A
    POP     AF
    PUSH    AF
    ADD     A, 4
    LD      ($7236), A
    POP     AF
    PUSH    AF
    ADD     A, 9
    LD      ($7234), A
    POP     AF
    ADD     A, 0BH
    LD      ($7238), A
    LD      A, ($7225)
    PUSH    AF
    ADD     A, 7
    LD      ($7233), A
    POP     AF
    PUSH    AF
    ADD     A, 7
    LD      ($7235), A
    POP     AF
    PUSH    AF
    ADD     A, 0CH
    LD      ($7237), A
    POP     AF
    ADD     A, 0CH
    LD      ($7239), A
    LD      DE, ($7232)
    CALL    SUB_A2BA
    LD      HL, $723A
    CALL    SUB_A2D7
    LD      DE, ($7234)
    CALL    SUB_A2BA
    LD      HL, $723B
    CALL    SUB_A2D7
    LD      DE, ($7236)
    CALL    SUB_A2BA
    LD      HL, $723C
    CALL    SUB_A2D7
    LD      DE, ($7238)
    CALL    SUB_A2BA
    LD      HL, $723D
    CALL    SUB_A2D7
    LD      A, ($7240)
    CP      0
    JR      NZ, LOC_A211
    LD      B, 2
    LD      C, 2
    LD      DE, byte_A2DE
    JR      LOC_A242
LOC_A211:
    LD      B, 2
    LD      A, ($722F)
    CP      0
    JR      Z, LOC_A22F
    LD      A, ($722A)
    PUSH    HL
    LD      HL, $722C
    CP      (HL)
    POP     HL
    JR      NZ, LOC_A22A
    LD      DE, byte_A2DF
    JR      LOC_A242
LOC_A22A:
    LD      DE, byte_A2E0
    JR      LOC_A242
LOC_A22F:
    LD      A, ($722B)
    PUSH    HL
    LD      HL, $722D
    CP      (HL)
    POP     HL
    JR      NZ, LOC_A23F
    LD      DE, byte_A2E1
    JR      LOC_A242
LOC_A23F:
    LD      DE, byte_A2DE
LOC_A242:
    LD      A, (DE)
    AND     0FH
LOC_A245:
    PUSH    DE
    LD      D, 0
    LD      E, A
    LD      HL, $723A
    ADD     HL, DE
    POP     DE
    LD      A, 67H
    CP      (HL)
    JR      NZ, LOC_A272
LOC_A253:
    LD      A, (DE)
    SRA     A
    SRA     A
    SRA     A
    SRA     A
    DJNZ    LOC_A245
LOC_A25E:
    LD      A, ($7240)
    CP      0
    JR      NZ, LOCRET_A271
    DEC     C
    BIT     0, C
    JR      Z, LOCRET_A271
    LD      DE, byte_A2E1
    LD      B, 2
    JR      LOC_A242
LOCRET_A271:     
RET

LOC_A272:
    LD      A, (HL)
    CP      86H
    JP      M, LOC_A293
    CP      8EH
    JP      P, LOC_A293
LOC_A27D:
    LD      A, 0FFH
    LD      ($723E), A
    LD      ($7241), A
    LD      A, ($7224)
    LD      (IX+1), A
    LD      A, ($7225)
    LD      (IX+0), A
    JR      LOCRET_A271
LOC_A293:
    CP      8FH
    JR      C, LOC_A29B
    CP      96H
    JR      C, LOC_A27D
LOC_A29B:
    LD      A, ($7240)
    CP      0
    JR      Z, LOC_A2B3
    LD      A, 0FFH
    LD      ($7241), A
    LD      A, ($7226)
    LD      (IX+1), A
    LD      A, ($7227)
    LD      (IX+0), A
LOC_A2B3:
    LD      A, B
    CP      0
    JR      NZ, LOC_A253
    JR      LOC_A25E

SUB_A2BA:
    SRL     E
    SRL     E
    SRL     E
    SRL     D
    SRL     D
    SRL     D

SUB_A2C6:
    LD      H, 0
    LD      L, D
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    LD      D, 0
    ADD     HL, DE
    LD      DE, 1800H
    ADD     HL, DE
    EX      DE, HL
RET

SUB_A2D7:
    LD      BC, 1
    CALL    READ_VRAM
RET

byte_A2DE:
	db 001
byte_A2DF:
	db 019
byte_A2E0:
	db 002
byte_A2E1:
	db 035

SOME_CONTROLLER_CHECK_SUB_11:
    LD      A, ($7142)
    CP      0
    JR      Z, SOME_CONTROLLER_CHECK_SUB_12
RET
SOME_CONTROLLER_CHECK_SUB_12:
    LD      HL, $7144
    SET     6, (HL)
    JR      SOME_CONTROLLER_CHECK_SUB_13

SUB_A2F1:
    LD      A, ($7142)
    CP      0
    JR      Z, LOC_A2F9
RET

LOC_A2F9:
    LD      HL, $7144
    RES     6, (HL)
SOME_CONTROLLER_CHECK_SUB_13:
    LD      A, 0CH
    LD      ($7142), A
    LD      A, ($70C3)
    ADD     A, 7
    PUSH    AF
    AND     7
    ADD     A, 0ABH
    LD      ($7146), A
    POP     AF
    SRL     A
    SRL     A
    SRL     A
    LD      ($7147), A
    LD      A, ($70C2)
    INC     A
    SRL     A
    SRL     A
    SRL     A
    LD      B, A
    LD      HL, $7144
    BIT     6, (HL)
    JR      NZ, SOME_CONTROLLER_CHECK_SUB_14
    INC     B
    INC     B
    LD      A, ($70C2)
    INC     A
    ADD     A, 10H
    AND     7
    CP      6
    JR      NC, SOME_CONTROLLER_CHECK_SUB_15
    DEC     B
    JR      SOME_CONTROLLER_CHECK_SUB_15
SOME_CONTROLLER_CHECK_SUB_14:
    LD      A, ($70C2)
    INC     A
    AND     7
    CP      2
    JR      NC, SOME_CONTROLLER_CHECK_SUB_15
    DEC     B
SOME_CONTROLLER_CHECK_SUB_15:
    LD      A, B
    LD      ($7148), A
    LD      HL, ($7147)
    LD      ($7149), HL
    CALL    KILLED_TYRRANOSAUR_C
    CALL    KILLED_PTERODACTYL_C
    LD      HL, ($7147)
    RST     18H
    CALL    SUB_96C2
    CP      6AH
    JR      NZ, SOME_CONTROLLER_CHECK_SUB_16
    LD      HL, ($7147)
    RST     18H
    LD      A, 6BH
    RST     10H
    LD      HL, SOME_HUD_DATA_00
    CALL    UPDATE_SCORE_A
RET

SOME_CONTROLLER_CHECK_SUB_16:
    CP      6BH
    JR      NZ, LOC_A387
    LD      HL, ($7147)
    RST     18H
    LD      A, 67H
    RST     10H
    LD      HL, $70B0
    DEC     (HL)
    LD      HL, SOME_HUD_DATA_01
    CALL    UPDATE_SCORE_A
RET

LOC_A387:
    CALL    SUB_A634
    CP      67H
    JR      NZ, LOCRET_A3A8
    LD      HL, ($7147)
    RST     18H
    LD      A, ($7146)
    RST     10H
    LD      HL, $7144
    SET     7, (HL)
    SET     5, (HL)
    LD      A, 1
    LD      ($7152), A
    LD      A, 2
    LD      ($7145), A
RET

LOCRET_A3A8:     
RET

SUB_A3A9:
    LD      HL, $7144
    BIT     7, (HL)
    RET     Z
    LD      HL, $7145
    DEC     (HL)
    RET     NZ
    LD      (HL), 2
    LD      HL, $7144
    BIT     6, (HL)
    JP      NZ, LOC_A45D
    BIT     5, (HL)
    JR      NZ, LOC_A3DA
    LD      A, ($7152)
    LD      B, A
    LD      HL, ($7147)
LOC_A3C9:
    PUSH    BC
    PUSH    HL
    RST     18H
    LD      A, 67H
    RST     10H
    POP     HL
    POP     BC
    DEC     H
    DJNZ    LOC_A3C9
    LD      HL, $7144
    RES     7, (HL)
RET

LOC_A3DA:
    LD      HL, ($7147)
    INC     H
    LD      ($7149), HL
    CALL    KILLED_TYRRANOSAUR_A
    OR      A
    JP      Z, LOC_A5E8
    CALL    KILLED_PTERODACTYL_A
    OR      A
    JP      Z, LOC_A5E8
    LD      HL, ($7149)
    LD      A, 0
    LD      ($70A5), A
    RST     18H
    CALL    SUB_96C2
    CP      6AH
    JR      NZ, LOC_A412
    LD      HL, ($7149)
    RST     18H
    LD      A, 6BH
    RST     10H
    LD      HL, SOME_HUD_DATA_00
    CALL    UPDATE_SCORE_A
    LD      HL, $7144
    RES     5, (HL)
RET

LOC_A412:
    CP      6BH
    JR      NZ, LOC_A42D
    LD      HL, ($7149)
    RST     18H
    LD      A, 67H
    RST     10H
    LD      HL, $70B0
    DEC     (HL)
    LD      HL, SOME_HUD_DATA_01
    CALL    UPDATE_SCORE_A
    LD      HL, $7144
    RES     5, (HL)
RET

LOC_A42D:
    CALL    SUB_A634
    CP      67H
    JR      NZ, LOC_A457
    LD      HL, ($7149)
    LD      ($7147), HL
    RST     18H
    LD      A, ($7146)
    RST     10H
    LD      A, ($7152)
    CP      4
    JR      C, LOC_A452
    LD      HL, ($7147)
    LD      A, 0FCH
    ADD     A, H
    LD      H, A
    RST     18H
    LD      A, 67H
    RST     10H
RET

LOC_A452:
    INC     A
    LD      ($7152), A
RET

LOC_A457:
    LD      HL, $7144
    RES     5, (HL)
RET

LOC_A45D:
    BIT     5, (HL)
    JR      NZ, LOC_A479
    LD      A, ($7152)
    LD      B, A
    LD      HL, ($7147)
LOC_A468:
    PUSH    BC
    PUSH    HL
    RST     18H
    LD      A, 67H
    RST     10H
    POP     HL
    POP     BC
    INC     H
    DJNZ    LOC_A468
    LD      HL, $7144
    RES     7, (HL)
RET

LOC_A479:
    LD      HL, ($7147)
    DEC     H
    LD      ($7149), HL
    CALL    KILLED_TYRRANOSAUR_A
    CALL    KILLED_PTERODACTYL_A
    OR      A
    JP      Z, LOC_A5E8
    LD      A, 0
    LD      ($70A5), A
    LD      HL, ($7149)
    RST     18H
    CALL    SUB_96C2
    CP      6AH
    JR      NZ, LOC_A4AD
    LD      HL, ($7149)
    RST     18H
    LD      A, 6BH
    RST     10H
    LD      HL, SOME_HUD_DATA_00
    CALL    UPDATE_SCORE_A
    LD      HL, $7144
    RES     5, (HL)
RET

LOC_A4AD:
    CP      6BH
    JR      NZ, LOC_A4C8
    LD      HL, ($7149)
    RST     18H
    LD      A, 67H
    RST     10H
    LD      HL, $70B0
    DEC     (HL)
    LD      HL, SOME_HUD_DATA_01
    CALL    UPDATE_SCORE_A
    LD      HL, $7144
    RES     5, (HL)
RET

LOC_A4C8:
    CALL    SUB_A634
    CP      67H
    JR      NZ, LOC_A4F2
    LD      HL, ($7149)
    LD      ($7147), HL
    RST     18H
    LD      A, ($7146)
    RST     10H
    LD      A, ($7152)
    CP      4
    JR      C, LOC_A4ED
    LD      HL, ($7147)
    LD      A, 4
    ADD     A, H
    LD      H, A
    RST     18H
    LD      A, 67H
    RST     10H
RET

LOC_A4ED:
    INC     A
    LD      ($7152), A
RET

LOC_A4F2:
    LD      HL, $7144
    RES     5, (HL)
RET

KILLED_TYRRANOSAUR_C:
    LD      IX, $70F2
    CALL    SUB_A50E
    RET     NC
    JP      KILLED_TYRRANOSAUR_B

KILLED_PTERODACTYL_C:
    LD      IX, $70E6
    CALL    SUB_A50E
    RET     NC
    JP      KILLED_PTERODACTYL_B

SUB_A50E:
    LD      A, ($70C3)
    ADD     A, 7
    LD      H, A
    LD      A, ($7148)
    SLA     A
    SLA     A
    SLA     A
    LD      L, A
    LD      A, (IX+1)
    ADD     A, 8
    LD      D, A
    LD      A, (IX+0)
    ADD     A, 8
    LD      E, A
    LD      A, H
    SBC     A, D
    CALL    C, SUB_A53A
    CP      5
    RET     NC
    LD      A, L
    SBC     A, E
    CALL    C, SUB_A53A
    CP      5
RET

SUB_A53A:
    NEG
RET

SUB_A53D:
    LD      HL, ($7149)
    LD      A, H
    SLA     A
    SLA     A
    SLA     A
    LD      ($70AC), A
    LD      A, ($7152)
    SLA     A
    SLA     A
    SLA     A
    LD      ($70AD), A
    LD      A, L
    SLA     A
    SLA     A
    SLA     A
    LD      B, A
    LD      A, ($7146)
    SUB     0ABH
    ADD     A, B
    LD      B, A
    LD      A, (IX+1)
    ADD     A, 8
    LD      ($70AB), A
    LD      HL, $7144
    BIT     6, (HL)
    JP      NZ, LOC_A5DF
    LD      A, (IX+0)
    ADD     A, 3
    LD      E, A
LOC_A57B:
    LD      A, ($70AB)
    SBC     A, B
    CALL    C, SUB_A53A
    CP      5
    RET     NC
    LD      A, E
    LD      HL, $70AC
    LD      D, (HL)
    SBC     A, D
    LD      HL, $7144
    BIT     6, (HL)
    CALL    Z, SUB_A53A
    LD      HL, $70AD
    CP      (HL)
RET

KILLED_TYRRANOSAUR_A:
    LD      IX, $70F2
    CALL    SUB_A53D
    RET     NC
KILLED_TYRRANOSAUR_B:
    LD      (IX+0), 0BFH
    LD      (IX+0CH), 0BFH
    CALL    PLAY_TYRRANOSAUR_HIT_SOUND
    CALL    SUB_A5EE
    PUSH    IX
    LD      IX, ($7072)
    RES     6, (IX+0)
    POP     IX
    XOR     A
RET

KILLED_PTERODACTYL_A:
    LD      IX, $70E6
    CALL    SUB_A53D
    RET     NC
KILLED_PTERODACTYL_B:
    CALL    SUB_A618
    LD      (IX+0), 0BFH
    CALL    PLAY_PTERODACTYL_HIT_SOUND_B
    CALL    PLAY_PTERODACTYL_HIT_SOUND_A
    PUSH    IX
    LD      IX, ($7072)
    RES     6, (IX+0)
    POP     IX
    XOR     A
RET

LOC_A5DF:
    LD      A, (IX+0)
    ADD     A, 0DH
    LD      E, A
    JP      LOC_A57B

LOC_A5E8:
    LD      HL, $7144
    RES     5, (HL)
RET

SUB_A5EE:
    LD      A, ($7143)
    CP      0
    JR      Z, LOC_A604
    CP      2
    JR      Z, LOC_A609
    CP      6
    JR      Z, LOC_A60E
    LD      HL, SOME_HUD_DATA_09
LOC_A600:
    CALL    UPDATE_SCORE_A
RET
LOC_A604:
    LD      HL, SOME_HUD_DATA_06
    JR      LOC_A600
LOC_A609:
    LD      HL, SOME_HUD_DATA_07
    JR      LOC_A600
LOC_A60E:
    LD      HL, SOME_HUD_DATA_08
    JR      LOC_A600

LOC_A613:
    LD      HL, SOME_HUD_DATA_09
    JR      LOC_A600

SUB_A618:
    LD      A, ($70C2)
    LD      B, A
    LD      A, ($70EE)
    SBC     A, B
    CALL    C, SUB_A53A
    CP      11H
    JR      C, LOC_A613
    CP      21H
    JR      C, LOC_A60E
    CP      31H
    JR      C, LOC_A609
    LD      HL, SOME_HUD_DATA_06
    JR      LOC_A600

SUB_A634:
    PUSH    AF
    CP      6CH
    JR      C, LOC_A640
    CP      0AAH
    JR      NC, LOC_A640
    CALL    SUB_B9DB
LOC_A640:
    POP     AF
RET

SOME_HUD_DATA_00:DB 000,000,005        
SOME_HUD_DATA_01:DB 000,000,016        
SOME_HUD_DATA_02:DB 000,000,037        
SOME_HUD_DATA_03:DB 000,000,080        
SOME_HUD_DATA_04:DB 000,000,117        
SOME_HUD_DATA_05:DB 000,001,000
				 DB 000,001,080
SOME_HUD_DATA_06:DB 000,002,080        
SOME_HUD_DATA_07:DB 000,005,000        
SOME_HUD_DATA_08:DB 000,007,080        
SOME_HUD_DATA_09:DB 000,016,000        

GAME_PATTERNS:
	DB 000,000,000,000,000,000,000,000
    DB 240,136,136,240,128,128,128,000
    DB 128,128,128,128,128,128,248,000
    DB 032,080,136,136,248,136,136,000
    DB 136,136,080,032,032,032,032,000
    DB 248,128,128,240,128,128,248,000
    DB 240,136,136,240,160,144,136,000
    DB 240,136,136,240,136,136,240,000
    DB 112,136,136,136,136,136,112,000
    DB 136,136,200,168,152,136,136,000
    DB 136,136,136,136,136,136,112,000
    DB 112,136,128,112,008,136,112,000
    DB 000,000,000,000,000,000,015,000
    DB 000,000,000,000,000,000,240,063
    DB 000,000,000,000,003,007,015,031
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,192,224,240,248
    DB 252,192,192,192,192,192,192,192
    DB 000,000,031,031,248,000,000,000
    DB 007,007,000,003,003,003,003,003
    DB 015,000,225,000,000,000,000,000
    DB 000,000,248,000,000,000,000,000
    DB 000,224,000,000,000,000,000,000
    DB 224,240,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 248,240,000,000,000,000,000,000
    DB 000,252,000,000,000,000,000,000
    DB 254,000,000,000,000,000,000,000
    DB 000,128,000,254,128,240,000,000
    DB 000,252,224,240,254,254,240,192
    DB 000,000,000,254,254,254,158,156
    DB 243,000,199,199,192,000,000,240
    DB 249,249,249,134,135,143,207,207
    DB 223,224,128,000,000,000,000,000
    DB 128,224,224,248,254,240,000,192
    DB 000,000,000,000,000,240,000,000
    DB 240,000,000,000,000,000,128,248
    DB 000,000,000,254,248,224,192,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,128,224,248,252,000
    DB 000,000,000,000,000,000,000,000
    DB 240,000,000,000,000,000,254,224
    DB 000,000,000,000,000,240,000,000
    DB 254,248,248,224,000,248,000,252
    DB 159,159,159,158,225,241,243,243
    DB 251,249,254,000,000,000,000,000
    DB 000,000,000,128,128,128,134,198
    DB 207,241,225,227,252,000,000,240
    DB 000,192,248,227,128,135,240,000
    DB 224,192,000,000,192,240,224,000
    DB 224,240,000,000,252,252,254,254
    DB 252,240,192,128,000,000,000,000
    DB 000,000,252,252,224,224,224,253
    DB 253,251,251,247,247,239,223,223
    DB 000,000,000,192,192,000,128,000
    DB 000,000,254,252,225,221,221,221
    DB 221,221,221,221,221,221,221,218
    DB 182,175,224,192,000,000,000,000
    DB 000,000,192,192,248,252,252,252
    DB 192,224,240,240,240,192,224,240
    DB 252,129,199,223,000,000,000,000
    DB 000,128,192,000,224,000,000,000
    DB 000,000,000,000,224,224,000,000
    DB 000,000,000,000,000,000,252,000
    DB 248,224,240,224,128,128,128,192
    DB 000,000,000,254,252,248,248,000
    DB 000,000,224,240,192,252,252,252
    DB 248,192,000,128,224,192,192,000
    DB 231,192,247,239,207,183,132,253
    DB 000,000,248,252,128,000,252,000
    DB 128,240,252,248,240,248,192,000
    DB 000,240,248,248,248,248,248,248
    DB 240,135,240,000,000,000,000,192
    DB 224,248,000,192,192,128,240,000
    DB 000,000,000,254,252,248,224,193
    DB 128,131,248,000,000,000,000,252
    DB 248,224,254,254,248,000,248,000
    DB 254,240,251,253,254,000,191,196
    DB 231,227,231,239,224,252,192,192
    DB 240,192,240,240,248,000,000,000
    DB 224,248,248,252,192,223,223,207
    DB 243,253,000,192,143,000,000,224
    DB 192,240,192,255,000,000,000,000
    DB 192,240,224,000,240,192,252,000
    DB 192,000,224,192,000,000,000,000
    DB 224,192,192,192,224,254,000,000
    DB 000,000,000,000,000,000,192,000
    DB 000,000,000,192,000,000,128,224
    DB 000,000,000,192,000,192,143,195
    DB 248,252,248,240,240,192,248,128
    DB 252,224,239,223,207,192,128,192
    DB 000,000,224,252,252,192,252,240
    DB 254,000,248,227,199,240,240,240
    DB 252,000,000,000,248,248,240,252
    DB 000,000,224,000,000,000,000,192
    DB 000,199,129,000,224,128,224,192
    DB 000,000,000,224,248,252,252,252
    DB 128,000,224,224,254,254,248,240
    DB 192,240,240,000,129,129,000,000
    DB 000,000,000,192,128,240,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,231,231,231,195,195,129,153
    DB 000,000,000,000,000,000,000,000
    DB 112,136,008,048,064,128,248,000
    DB 223,159,223,223,223,223,143,000
    DB 182,213,211,153,145,231,247,227
    DB 000,000,000,238,145,231,247,227
    DB 001,129,195,230,124,060,024,000
    DB 224,000,000,000,000,000,000,000
    DB 000,128,192,224,096,048,024,015
    DB 128,129,195,103,062,060,024,000
    DB 007,000,000,000,000,000,000,000
    DB 000,001,003,007,006,012,024,240
    DB 006,012,056,112,112,056,028,014
    DB 000,000,000,000,000,001,001,001
    DB 128,128,128,064,096,056,028,014
    DB 014,028,056,112,112,056,012,006
    DB 001,001,001,000,000,000,000,000
    DB 014,028,056,096,064,128,128,128
    DB 000,003,015,031,028,024,012,006
    DB 003,006,012,028,056,056,060,030
    DB 000,192,240,248,060,012,006,002
    DB 000,192,112,056,028,028,030,014
    DB 014,024,049,059,063,030,028,000
    DB 028,056,048,056,024,014,000,000
    DB 014,006,006,014,028,024,048,032
    DB 000,128,192,224,240,120,012,007
    DB 014,028,056,112,112,056,028,014
    DB 000,129,195,231,126,060,024,000
    DB 000,003,015,031,060,056,060,030
    DB 000,192,240,248,124,028,030,014
    DB 028,056,049,059,063,030,028,000
    DB 014,134,198,238,254,124,024,000
    DB 000,000,000,000,028,058,046,062
    DB 056,116,092,124,024,056,028,014
    DB 000,224,208,240,176,224,000,000
    DB 000,128,206,253,127,043,014,000
    DB 000,007,011,015,013,007,000,000
    DB 000,001,115,191,254,212,112,000
    DB 062,046,058,028,000,000,000,000
    DB 014,028,056,024,124,092,116,056
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,006,024,000
    DB 000,012,048,000,000,000,000,000
    DB 000,032,032,064,064,000,000,000
    DB 000,000,000,002,002,004,004,000
    DB 000,004,004,002,002,000,000,000
    DB 000,000,000,064,064,032,032,000
    DB 000,024,006,000,000,000,000,000
    DB 000,000,000,000,000,096,024,000
    DB 000,000,000,000,000,000,000,000
    DB 004,006,002,003,001,000,000,000
    DB 000,000,000,032,096,064,192,128
    DB 000,000,000,000,000,024,012,006
    DB 000,000,000,000,000,012,006,002
    DB 000,000,000,000,024,014,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,003,014,024
    DB 192,112,024,000,000,000,000,000
    DB 003,006,012,000,000,000,000,000
    DB 000,000,000,000,000,024,048,032
    DB 000,000,000,000,000,000,000,000
    DB 024,112,192,000,000,000,000,000
    DB 000,000,000,000,024,014,003,000
    DB 000,192,112,000,000,000,000,000
    DB 000,000,048,056,028,015,007,000
    DB 000,000,012,028,056,240,224,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,128,192,064,096,032
    DB 001,003,002,006,004,000,000,000
    DB 128,128,128,128,128,128,128,128
    DB 064,064,064,064,064,064,064,064
    DB 032,032,032,032,032,032,032,032
    DB 016,016,016,016,016,016,016,016
    DB 008,008,008,008,008,008,008,008
    DB 004,004,004,004,004,004,004,004
    DB 002,002,002,002,002,002,002,002
    DB 001,001,001,001,001,001,001,001
    DB 000,000,000,000,000,000,000,000
    DB 112,136,128,128,152,136,112,000
    DB 032,080,136,136,248,136,136,000
    DB 216,216,168,168,136,136,136,000
    DB 136,136,136,080,080,032,032,000
    DB 112,136,136,136,136,136,112,000
    DB 248,128,128,240,128,128,248,000
    DB 240,136,136,240,160,144,136,000
    DB 240,136,136,136,136,136,240,000
    DB 128,128,128,128,128,128,248,000
    DB 240,136,136,240,128,128,128,000
    DB 248,032,032,032,032,032,032,000
    DB 136,136,080,032,032,032,032,000
    DB 032,096,032,032,032,032,112,000
    DB 112,136,008,048,064,128,248,000
    DB 136,136,136,248,136,136,136,000

COLORS_DAY:
	DB 102,102,102,102,102,102,246,102
    DB 102,102,102,102,102,102,246,246
    DB 102,102,102,102,166,166,166,175
    DB 102,102,102,170,170,170,170,170
    DB 102,102,102,102,166,166,166,166
    DB 250,154,154,154,154,154,154,218
    DB 170,170,250,250,250,170,170,170
    DB 154,154,255,154,154,154,154,218
    DB 159,255,249,153,153,153,153,221
    DB 153,255,249,153,153,153,153,221
    DB 153,249,153,153,153,153,153,221
    DB 218,218,017,017,187,187,187,187
    DB 170,170,017,017,187,187,187,187
    DB 173,173,017,017,187,187,187,187
    DB 221,209,017,017,017,187,187,187
    DB 029,017,017,017,017,187,187,187
    DB 221,029,017,026,026,177,187,187
    DB 221,218,026,138,168,024,186,177
    DB 153,153,153,154,154,154,154,218
    DB 173,170,106,166,106,170,170,026
    DB 154,154,154,169,169,169,169,173
    DB 166,106,106,170,170,170,170,170
    DB 173,173,161,097,171,166,170,161
    DB 221,221,017,017,187,107,170,017
    DB 209,017,017,017,187,187,027,027
    DB 153,153,153,145,145,145,145,017
    DB 017,017,017,017,187,187,187,187
    DB 153,153,153,025,025,025,025,017
    DB 017,017,017,017,187,187,187,187
    DB 029,017,017,017,187,187,177,177
    DB 221,221,017,017,187,182,170,017
    DB 218,218,026,022,170,106,170,017
    DB 154,154,154,154,169,169,169,173
    DB 166,166,166,170,170,170,170,170
    DB 153,153,153,169,169,169,169,173
    DB 173,166,106,166,166,170,170,161
    DB 221,173,161,166,106,166,161,017
    DB 209,209,017,017,161,171,027,187
    DB 029,029,017,017,026,186,161,027
    DB 218,218,026,026,170,170,017,187
    DB 102,102,106,106,106,106,106,168
    DB 168,168,168,168,168,168,168,168
    DB 170,170,170,168,138,170,026,017
    DB 102,102,168,168,168,168,168,168
    DB 168,168,168,168,168,168,168,168
    DB 168,168,138,138,170,170,170,017
    DB 102,102,134,134,134,134,134,134
    DB 168,168,168,168,168,168,168,168
    DB 168,138,138,168,170,170,170,017
    DB 221,141,129,136,168,170,170,017
    DB 221,221,017,017,129,168,170,017
    DB 221,221,017,017,017,017,161,017
    DB 185,185,152,152,152,152,177,177
    DB 187,187,187,185,185,185,145,153
    DB 153,153,137,137,129,025,024,024
    DB 185,185,153,025,025,185,177,187
    DB 185,185,145,145,145,145,025,145
    DB 153,153,145,025,025,153,137,136
    DB 152,152,145,145,145,027,027,187
    DB 187,155,155,155,155,155,155,152
    DB 145,145,025,153,153,153,153,137
    DB 137,137,136,024,024,177,177,187
    DB 187,187,187,185,185,185,137,137
    DB 025,145,145,153,153,153,153,152
    DB 152,152,129,129,129,017,027,187
    DB 185,185,145,145,145,153,145,025
    DB 025,025,025,025,145,145,145,129
    DB 025,025,025,024,027,187,187,187
    DB 155,155,155,155,025,145,145,145
    DB 145,145,017,027,027,017,017,027
    DB 145,145,145,017,187,187,187,187
    DB 155,155,027,187,027,027,027,187
    DB 027,017,027,027,187,187,187,187
    DB 185,185,184,184,184,184,187,187
    DB 187,187,187,187,187,187,185,153
    DB 153,153,153,137,136,136,184,177
    DB 187,187,187,185,153,137,152,152
    DB 145,145,145,145,129,129,027,027
    DB 185,185,145,145,145,145,145,025
    DB 153,153,137,137,137,024,024,177
    DB 155,153,145,145,145,025,024,024
    DB 152,153,153,153,145,129,129,027
    DB 187,187,185,153,153,153,153,137
    DB 136,137,025,017,025,025,025,184
    DB 187,187,187,155,155,155,027,027
    DB 025,153,137,024,145,145,145,129
    DB 155,155,139,017,025,024,017,187
    DB 187,187,187,027,027,027,017,187
    DB 153,153,153,153,153,153,153,221
    DB 221,221,017,017,187,187,187,187
    DB 102,097,097,097,111,111,111,111
    DB 187,187,187,187,187,187,187,187
    DB 022,022,022,022,022,022,022,022
    DB 097,097,097,097,097,097,097,102
    DB 188,188,188,203,188,188,188,188
    DB 187,187,187,188,188,188,188,188

COLORS_NIGHT:
	DB 221,221,221,221,221,221,253,221
    DB 221,221,221,221,221,221,253,253
    DB 221,221,221,221,109,109,109,111
    DB 221,221,221,102,102,102,102,102
    DB 221,221,221,221,109,109,109,109
    DB 246,150,150,150,150,150,150,166
    DB 102,102,246,246,246,102,102,102
    DB 150,150,255,150,150,150,150,166
    DB 159,255,249,153,153,153,153,170
    DB 153,255,249,153,153,153,153,170
    DB 153,249,153,153,153,153,153,170
    DB 166,166,017,017,068,068,068,068
    DB 102,102,017,017,068,068,068,068
    DB 106,106,017,017,068,068,068,068
    DB 170,161,017,017,017,068,068,068
    DB 026,017,017,017,017,068,068,068
    DB 170,026,017,021,021,065,068,068
    DB 170,165,021,069,084,020,069,065
    DB 153,153,153,149,149,149,149,165
    DB 090,085,213,093,213,085,085,021
    DB 149,149,149,089,089,089,089,090
    DB 093,213,213,085,085,085,085,085
    DB 090,090,081,209,084,093,085,081
    DB 170,170,017,017,068,212,085,017
    DB 161,017,017,017,068,068,020,020
    DB 153,153,153,145,145,145,145,017
    DB 017,017,017,017,068,068,068,068
    DB 153,153,153,025,025,025,025,017
    DB 017,017,017,017,068,068,068,068
    DB 026,017,017,017,068,068,065,065
    DB 170,170,017,017,068,077,085,017
    DB 165,165,021,029,085,213,085,017
    DB 149,149,149,149,089,089,089,090
    DB 093,093,093,085,085,085,085,085
    DB 153,153,153,089,089,089,089,090
    DB 090,093,213,093,093,085,085,081
    DB 170,090,081,093,213,093,081,017
    DB 161,161,017,017,081,084,020,068
    DB 026,026,017,017,021,069,081,020
    DB 165,165,021,021,085,085,017,068
    DB 221,221,213,213,213,213,213,084
    DB 084,084,084,084,084,084,084,084
    DB 085,085,085,084,069,085,021,017
    DB 221,221,084,084,084,084,084,084
    DB 084,084,084,084,084,084,084,084
    DB 084,084,069,069,085,085,085,017
    DB 221,221,077,077,077,077,077,077
    DB 084,084,084,084,084,084,084,084
    DB 084,069,069,084,085,085,085,017
    DB 170,074,065,068,084,085,085,017
    DB 170,170,017,017,065,084,085,017
    DB 170,170,017,017,017,017,081,017
    DB 076,076,197,197,197,197,065,065
    DB 068,068,068,076,076,076,193,204
    DB 204,204,092,092,081,028,021,021
    DB 076,076,204,028,028,076,065,068
    DB 076,076,193,193,193,193,028,193
    DB 204,204,193,028,028,204,092,085
    DB 197,197,193,193,193,020,020,068
    DB 068,196,196,196,196,196,196,197
    DB 193,193,028,204,204,204,204,092
    DB 092,092,085,021,021,065,065,068
    DB 068,068,068,076,076,076,092,092
    DB 028,193,193,204,204,204,204,197
    DB 197,197,081,081,081,017,020,068
    DB 076,076,193,193,193,204,193,028
    DB 028,028,028,028,193,193,193,081
    DB 028,028,028,021,020,068,068,068
    DB 196,196,196,196,028,193,193,193
    DB 193,193,017,020,020,017,017,020
    DB 193,193,193,017,068,068,068,068
    DB 196,196,020,068,020,020,020,068
    DB 020,017,020,020,068,068,068,068
    DB 076,076,069,069,069,069,068,068
    DB 068,068,068,068,068,068,076,204
    DB 204,204,204,092,085,085,069,065
    DB 068,068,068,076,204,092,197,197
    DB 193,193,193,193,081,081,020,020
    DB 076,076,193,193,193,193,193,028
    DB 204,204,092,092,092,021,021,065
    DB 196,204,193,193,193,028,021,021
    DB 197,204,204,204,193,081,081,020
    DB 068,068,076,204,204,204,204,092
    DB 085,092,028,017,028,028,028,069
    DB 068,068,068,196,196,196,020,020
    DB 028,204,092,021,193,193,193,081
    DB 196,196,084,017,028,021,017,068
    DB 068,068,068,020,020,020,017,068
    DB 153,153,153,153,153,153,153,170
    DB 170,170,017,017,068,068,068,068
    DB 221,209,209,209,223,223,223,223
    DB 068,068,068,068,068,068,068,068
    DB 029,029,029,029,029,029,029,029
    DB 209,209,209,209,209,209,209,221
    DB 078,078,078,228,078,078,078,078
    DB 068,068,068,078,078,078,078,078

MONSTER_PATTERNS:
	DB 000,000,000,000,000,002,006,014
    DB 012,008,000,000,000,000,000,000
    DB 000,000,000,000,000,064,096,112
    DB 048,016,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,001,001,001,001,001,001
    DB 000,000,000,000,000,000,000,000
    DB 000,000,128,128,128,128,128,128
    DB 001,003,007,015,013,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 128,192,224,240,176,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,128,192,112,124,062,063,031
    DB 031,023,015,030,045,072,016,000
    DB 064,096,096,060,052,122,249,156
    DB 194,224,240,252,254,007,000,000
    DB 000,000,000,000,000,015,063,255
    DB 023,015,015,023,036,072,016,000
    DB 064,096,096,048,060,116,250,221
    DB 226,240,112,240,048,056,024,008
    DB 000,000,000,001,001,000,000,012
    DB 015,031,031,063,062,118,103,199
    DB 000,120,244,254,240,220,192,224
    DB 248,236,224,192,192,224,240,128
    DB 000,000,012,030,062,127,127,243
    DB 192,000,000,000,000,000,000,000
    DB 000,000,008,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,002
    DB 007,015,015,031,031,059,119,227
    DB 000,000,060,122,255,127,096,096
    DB 248,252,246,240,224,224,112,248
    DB 000,000,000,006,015,031,063,061
    DB 120,096,000,000,000,000,000,000
    DB 000,000,000,004,000,128,128,128
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,001,001,000,000,012
    DB 015,031,031,063,063,123,103,193
    DB 000,120,244,254,240,220,192,224
    DB 248,236,224,192,128,128,192,224
    DB 000,000,000,001,001,000,000,012
    DB 015,031,031,063,063,123,099,195
    DB 000,120,244,254,240,220,192,224
    DB 248,236,224,192,224,240,128,192
    DB 000,000,000,001,001,006,006,000
    DB 000,025,025,000,000,000,000,000
    DB 000,000,000,128,128,024,024,000
    DB 000,128,128,024,024,000,000,000
    DB 000,000,000,006,006,028,028,001
    DB 001,000,000,006,006,000,000,000
    DB 000,000,000,000,000,096,096,128
    DB 128,024,024,000,000,000,000,000
    DB 000,000,000,000,000,000,000,006
    DB 006,000,000,025,025,000,000,000
    DB 000,000,000,024,024,000,000,024
    DB 024,096,096,128,128,000,000,000
    DB 000,000,000,024,024,000,000,024
    DB 024,006,006,000,000,000,000,000
    DB 000,000,000,096,096,000,000,096
    DB 096,000,000,096,096,000,000,000

UNK_B45B:
	DB 020,024,028,032,036,024,040,024,028,032,036,024,255

UNK_B468:
	DB 080,084,088,092,096,084,100,084,088,092,096,084,255

SOUND_TABLE:
    DW PTERODACTYL_SOUND   
    DW $702B
    DW START_TUNE_A
    DW $702B
    DW START_TUNE_B
    DW $7035
    DW START_TUNE_C
    DW $703F
    DW PLAYER_DEATH_A
    DW $702B
    DW PLAYER_DEATH_B
    DW $7035
    DW PLAYER_DEATH_C
    DW $703F
    DW END_TUNE_A
    DW $702B
    DW END_TUNE_B
    DW $7035
    DW END_TUNE_C
    DW $703F
    DW LASER_SOUND
    DW $7053
    DW TYRRANOSAUR_SOUND_A
    DW $7049
    DW TYRRANOSAUR_SOUND_B
    DW $7053
    DW EXTRA_PLAYER_SOUND
    DW $705D
    DW PTERODACTYL_HIT_SOUND_A
    DW $7067
    DW SNAKES_SLITHER_SOUND_A
    DW $7035
    DW SNAKES_SLITHER_SOUND_B
    DW $703F
    DW TYRRANOSAUR_HIT_A
    DW $7067
    DW TYRRANOSAUR_HIT_B
    DW $7053
    DW PTERODACTYL_HIT_SOUND_B
    DW $702B
    DW PTERODACTYL_HIT_SOUND_B
    DW $7035
    DW PTERODACTYL_HIT_SOUND_B
    DW $703F
    DW PTERODACTYL_HIT_SOUND_B
    DW $7049
    DW PTERODACTYL_HIT_SOUND_B
    DW $7053
    DW PTERODACTYL_HIT_SOUND_B
    DW $705D
    DW PTERODACTYL_HIT_SOUND_B
    DW $7067
    DW PAUSE_TUNE_A
    DW $702B
    DW PAUSE_TUNE_B
    DW $7035
    DW PAUSE_TUNE_C
    DW $703F
    DW PAUSE_TUNE_D
    DW $7049

PTERODACTYL_SOUND:
	DB 065,127,080,005,068,008,065,120,080,003,068,007,065,127,080,004,068,008,065,160,080,004,068,248,065,127,080,005,068,008,065
    DB 120,080,003,068,007,065,127,080,004,068,008,065,160,080,004,068,248,065,127,080,004,068,008,065,143,080,004,068,009,065,160
    DB 080,006,068,248,065,127,080,002,068,008,065,127,080,004,068,008,065,143,080,004,068,009,065,160,080,008,068,248,065,095,080
    DB 005,068,007,065,090,080,003,068,006,065,095,080,004,068,007,065,120,080,004,068,249,065,095,080,005,068,007,065,090,080,003
    DB 068,006,065,095,080,004,068,007,065,120,080,004,068,249,065,095,080,004,068,007,065,107,080,004,068,008,065,120,080,005,068
    DB 249,065,089,080,003,068,007,065,095,080,004,068,007,065,107,080,004,068,008,065,120,096,005,068,249,065,089,112,003,068,007
    DB 064,095,128,003,088
START_TUNE_A:
	DB 064,148,049,006,064,064,049,006,064,046,049,006,064,013,049,024,102,064,148,049,006,064,064,049,006,064,046,049,006,064,013
    DB 049,024,102,064,148,049,006,064,064,049,006,064,046,049,006,064,013,049,006,102,064,064,049,006,102,064,148,049,006,102,064
    DB 064,049,006,102,064,104,049,024,080
START_TUNE_B:
	DB 178,128,039,083,012,128,202,096,006,166,128,202,096,006,178,128,087,083,012,128,202,096,006,166,128,202,096,006,178,128,191
    DB 083,012,128,148,097,006,166,128,039,083,012,128,240,096,006,166,128,087,083,012,128,214,096,006,166,128,214,096,006,144
START_TUNE_C:
	DB 254,192,160,096,006,230,192,160,096,006,254,192,160,096,006,230,192,160,096,006,254,192,160,096,006,242,192,143,096,006,242
    DB 192,135,096,006,230,192,135,096,006,208
PLAYER_DEATH_A:
	DB 064,039,131,050,066,039,131,010,023,017,066,202,130,020,023,026,066,167,130,040,023,031,064,039,131,030,080
PLAYER_DEATH_B:
	DB 128,191,051,050,130,191,051,010,028,017,130,087,051,020,028,026,130,039,051,040,028,031,128,191,051,030,144
PLAYER_DEATH_C:
	DB 193,025,000,020,017,003,193,090,032,020,017,004,193,025,128,020,017,003,193,090,144,020,017,004,193,172,160,040,017,006,208
END_TUNE_A:
	DB 065,025,000,020,017,003,065,088,048,020,017,004,065,172,096,040,017,006,064,046,081,007,064,240,080,007,064,226,080,007,064
    DB 202,080,028,103,064,180,080,004,064,202,080,003,064,240,080,007,064,046,081,007,064,240,080,028,103,064,148,081,007,064,046
    DB 081,007,064,240,080,007,064,013,081,028,103,064,240,080,004,064,013,081,003,064,046,081,007,064,104,081,007,064,046,081,028
    DB 080
END_TUNE_B:
	DB 128,093,242,021,129,025,032,020,017,003,129,090,096,020,017,004,129,172,160,040,017,006,128,093,114,007,128,151,128,005,162
    DB 128,151,128,005,162,128,151,128,005,162,128,151,128,007,181,128,093,114,007,128,151,128,005,162,128,151,128,005,162,128,151
    DB 128,005,162,128,151,128,007,181,128,039,115,007,128,160,128,005,162,128,160,128,005,162,128,160,128,005,162,128,160,128,007
    DB 181,128,093,114,007,128,151,128,005,162,128,151,128,005,162,128,151,128,005,162,128,151,128,007,144
END_TUNE_C:
	DB 192,093,242,108,192,120,128,005,226,192,120,128,005,226,192,120,128,005,226,192,120,128,007,252,192,120,128,005,226,192,120
    DB 128,005,226,192,120,128,005,226,192,120,128,007,252,192,113,128,005,226,192,113,128,005,226,192,113,128,005,226,192,113,128
    DB 007,252,192,120,128,005,226,192,120,128,005,226,192,120,128,005,226,192,120,128,007,208
PTERODACTYL_HIT_SOUND_A:
	DB 193,009,000,006,051,006,208
TYRRANOSAUR_HIT_A:
	DB 067,128,003,018,017,007,037,042
TYRRANOSAUR_SOUND_A:
	DB 099,065,160,003,002,017,057,065,144,067,002,017,057,080
TYRRANOSAUR_HIT_B:
	DB 050,002,006,008,000,000,016
TYRRANOSAUR_SOUND_B:
	DB 002,070,008,037,018,016
EXTRA_PLAYER_SOUND:
	DB 129,050,048,002,051,246,152
LASER_SOUND:
	DB 129,148,048,025,017,005,144
SNAKES_SLITHER_SOUND_A:
	DB 002,151,004,098,017,024
SNAKES_SLITHER_SOUND_B:
	DB 193,081,240,004,017,236,216
PTERODACTYL_HIT_SOUND_B:
	DB 033,016     
PAUSE_TUNE_A:
	DB 002,051,084,028,041,024
PAUSE_TUNE_B:
	DB 192,090,240,028,192,083,113,014,192,046,081,028,192,083,113,014,216
PAUSE_TUNE_C:
	DB 192,136,240,042,128,000,240,042,192,068,240,028,128,000,240,098,192,083,081,042,192,254,064,042,192,202,064,042,130,170,048
    DB 168,027,159,192,068,240,042,128,151,080,028,128,170,080,014,128,202,064,042,128,254,080,042,130,202,048,168,027,159,192,068
    DB 240,042,128,083,081,042,128,254,064,042,128,202,064,042,130,226,048,168,027,159,192,120,240,042,128,202,080,028,128,226,064
    DB 014,128,254,048,042,128,046,065,042,130,254,096,210,026,239,002,051,126,000,000,152
PAUSE_TUNE_D:
	DB 064,000,240,210,002,243,084,000,000,064,000,240,042,192,136,240,042,064,252,081,042,064,148,065,042,064,125,065,042,066,083
    DB 049,168,027,159,192,136,240,042,064,252,081,042,064,148,065,042,064,125,065,042,066,083,049,168,027,159,192,180,240,042,064
    DB 252,081,042,064,148,065,042,064,125,065,042,066,083,049,084,020,255,066,148,065,084,020,255,066,252,049,084,020,255,066,148
    DB 065,084,020,255,066,197,049,042,028,031,193,180,240,041,054,255,088

UPDATE_SOUNDS_REGISTER_PROTECTED:      
    PUSH    IX
    PUSH    IY
    CALL    PLAY_SONGS
    CALL    SOUND_MAN
    POP     IY
    POP     IX
RET

INIT_SOUNDS_REGISTER_PROTECTED:        
    PUSH    IX
    PUSH    IY
    LD      HL, SOUND_TABLE
    LD      B, 7
    CALL    SOUND_INIT
    POP     IY
    POP     IX
RET

PLAY_IT_REGISTER_PROTECTED:  
    PUSH    IX
    PUSH    IY
    CALL    PLAY_IT
    POP     IY
    POP     IX
RET

PLAY_PTERODACTYL_SOUND:      
    LD      B, PTERODACTYL_SND
    JP      PLAY_IT_REGISTER_PROTECTED

PLAY_PLAYER_DEATH_SOUND:     
    LD      B, PLAYER_DEATH_SND_A
    CALL    PLAY_IT_REGISTER_PROTECTED
    LD      B, PLAYER_DEATH_SND_B
    CALL    PLAY_IT_REGISTER_PROTECTED
    LD      B, PLAYER_DEATH_SND_C
    JP      PLAY_IT_REGISTER_PROTECTED

PLAY_END_MELODY: 
    LD      B, END_MELODY_A
    CALL    PLAY_IT_REGISTER_PROTECTED
    LD      B, END_MELODY_B
    CALL    PLAY_IT_REGISTER_PROTECTED
    LD      B, END_MELODY_C
    JP      PLAY_IT_REGISTER_PROTECTED

PLAY_START_MELODY:  
    LD      B, START_MELODY_A
    CALL    PLAY_IT_REGISTER_PROTECTED
    LD      B, START_MELODY_B
    CALL    PLAY_IT_REGISTER_PROTECTED
    LD      B, START_MELODY_C
    JP      PLAY_IT_REGISTER_PROTECTED

PLAY_FIRE_LASER_SOUND:       
    LD      A, 0FFH
    LD      ($7053), A
    LD      B, LASER_SND
    JP      PLAY_IT_REGISTER_PROTECTED

PLAY_EXTRA_PLAYER_SOUND:     
    LD      B, EXTRA_PLAYER_SND
    JP      PLAY_IT_REGISTER_PROTECTED

PLAY_TYRRANOSAUR_SOUND:      
    LD      B, TYRRANOSAUR_SND_A
    CALL    PLAY_IT_REGISTER_PROTECTED
    LD      B, TYRRANOSAUR_SND_B
    JP      PLAY_IT_REGISTER_PROTECTED

PLAY_PTERODACTYL_HIT_SOUND_A:
    LD      B, PTERODACTYL_HIT_SND_A
    JP      PLAY_IT_REGISTER_PROTECTED

PLAY_SNAKES_SLITHER_SOUND:   
    LD      B, SNAKES_SLITHER_SND_A
    CALL    PLAY_IT_REGISTER_PROTECTED
    LD      B, SNAKES_SLITHER_SND_B
    JP      PLAY_IT_REGISTER_PROTECTED

PLAY_TYRRANOSAUR_HIT_SOUND:  
    LD      B, TYRRANOSAUR_HIT_SND_A
    CALL    PLAY_IT_REGISTER_PROTECTED
    LD      B, TYRRANOSAUR_HIT_SND_B
    JP      PLAY_IT_REGISTER_PROTECTED

PLAY_PTERODACTYL_HIT_SOUND_B:
    LD      B, PTERODACTYL_HIT_SND_B
    JP      PLAY_IT_REGISTER_PROTECTED

PLAY_PAUSE_MELODY:  
    LD      B, PAUSE_MELODY_A
    CALL    PLAY_IT_REGISTER_PROTECTED
    LD      B, PAUSE_MELODY_B
    CALL    PLAY_IT_REGISTER_PROTECTED
    LD      B, PAUSE_MELODY_C
    CALL    PLAY_IT_REGISTER_PROTECTED
    LD      B, PAUSE_MELODY_D
    JP      PLAY_IT_REGISTER_PROTECTED

SUB_B9DB:
    LD      ($7222), A
    LD      A, 0
    LD      ($7188), A
    CALL    SUB_BC8C
    LD      IX, $71DC
    BIT     3, (IX+0)
    JR      Z, LOC_B9F6
    LD      A, 0
    LD      ($7222), A
RET

LOC_B9F6:
    BIT     6, (IX+15H)
    JR      Z, LOC_BA10
    LD      A, (IX+15H)
    LD      ($7188), A
    LD      A, ($7220)
    CP      1
    JR      NZ, LOC_BA10
    RES     6, (IX+15H)
    JP      LOC_BA93
LOC_BA10:
    CALL    SUB_BC67
    CALL    SUB_BD87
    LD      A, ($7220)
    CP      2
    JP      Z, LOC_BB9F
    LD      HL, $7221
    LD      A, 0
    CP      (HL)
    JP      Z, LOC_BAFB
    PUSH    IX
    LD      A, ($7220)
    CP      1
    JP      NZ, LOC_BAE8
    PUSH    HL
    LD      HL, SOME_HUD_DATA_04
    CALL    UPDATE_SCORE_AND_EXTRA_PLAYER
    POP     HL
    LD      (IX+4), 0
    LD      DE, 1
    ADD     IX, DE
    LD      B, 4
    LD      DE, 4
LOC_BA47:
    ADD     IX, DE
    BIT     7, (IX+0)
    JR      NZ, LOC_BA51
    DJNZ    LOC_BA47
LOC_BA51:
    RES     7, (IX+0)
    LD      ($7166), IX
    POP     IX
    LD      A, ($7220)
    CP      1
    JR      NZ, LOC_BAA2
    LD      A, (IX+0)
    AND     0FCH
    LD      (IX+0), A
    LD      HL, ($7166)
    LD      A, (HL)
    SRL     A
    SRL     A
    AND     3
    OR      (IX+0)
    LD      (IX+0), A
    LD      A, (IX+1)
    LD      (IX+1EH), A
    INC     HL
    LD      A, (HL)
    LD      (IX+1), A
    LD      A, (IX+2)
    LD      (IX+1FH), A
    INC     HL
    LD      A, (HL)
    LD      (IX+2), A
    CALL    SUB_BB5C
LOC_BA93:
    LD      HL, $71DC
    CALL    SUB_BDB0
    LD      A, 0
    LD      ($7222), A
    LD      ($7220), A
RET

LOC_BAA2:
    LD      A, (IY+0)
    LD      ($715F), A
    AND     0F0H
    LD      (IY+0), A
    LD      A, (IY+1)
    LD      ($7160), A
    LD      A, (IY+2)
    LD      ($7161), A
    LD      HL, ($7166)
    LD      A, (HL)
    AND     0FH
    OR      (IY+0)
    LD      ($7162), A
    INC     HL
    LD      A, (HL)
    LD      ($7163), A
    INC     HL
    LD      A, (HL)
    LD      ($7164), A
    LD      ($7179), IX
    LD      A, (IX+0)
    RES     2, A
    LD      ($7165), A
    CALL    SUB_93F5
    CALL    SUB_BB93
    LD      HL, $71DC
    CALL    SUB_BDB0
RET

LOC_BAE8:
    PUSH    HL
    LD      HL, SOME_HUD_DATA_03
    CALL    UPDATE_SCORE_AND_EXTRA_PLAYER
    POP     HL
    LD      DE, 15H
    ADD     IX, DE
    LD      DE, 0FFFCH
    JP      LOC_BA47
LOC_BAFB:
    PUSH    HL
    LD      HL, SOME_HUD_DATA_05
    CALL    UPDATE_SCORE_AND_EXTRA_PLAYER
    POP     HL
    LD      HL, $7223
    DEC     (HL)
    RES     7, (IX+0)
    LD      HL, ($717B)
    INC     HL
    BIT     6, (HL)
    JR      Z, LOC_BB19
    RES     6, (HL)
    LD      HL, $7177
    DEC     (HL)
LOC_BB19:
    LD      ($7179), IX
    LD      (IX+3), 67H
    PUSH    IY
    LD      IY, ($7189)
    BIT     1, (IY+0DH)
    POP     IY
    JR      Z, LOC_BB39
    LD      (IX+3), 6AH
    PUSH    HL
    LD      HL, $70B0
    INC     (HL)
    POP     HL
LOC_BB39:
    LD      DE, 1
    ADD     IX, DE
    LD      DE, 4
    LD      B, 6
    LD      A, 4
    LD      ($7220), A
LOC_BB48:
    ADD     IX, DE
    LD      (IX+3), 67H
    DJNZ    LOC_BB48
    CALL    SUB_BB93
    LD      IX, ($717B)
    RES     7, (IX+1)
RET

SUB_BB5C:
    LD      ($7179), IX
    LD      IY, ($7179)
    CALL    SUB_9058
    LD      A, ($7220)
    CP      1
    JR      Z, SUB_BB93
    LD      DE, 1
    ADD     IY, DE
    LD      B, 4
LOC_BB75:
    LD      DE, 4
    ADD     IY, DE
    BIT     7, (IY+0)
    JR      Z, LOC_BB83
    CALL    SUB_9426
LOC_BB83:
    DJNZ    LOC_BB75
    LD      A, (IX+0)
    LD      ($7165), A
    LD      DE, 4
    ADD     IY, DE
    CALL    SUB_9454
SUB_BB93:
    CALL    SUB_951A
    LD      A, 0
    LD      ($7222), A
    LD      ($7220), A
RET

LOC_BB9F:
    PUSH    HL
    LD      HL, SOME_HUD_DATA_02
    CALL    UPDATE_SCORE_AND_EXTRA_PLAYER
    POP     HL
    LD      ($7179), IX
    LD      A, (IY+0)
    LD      ($7162), A
    LD      A, (IY+1)
    LD      ($7163), A
    LD      A, (IY+2)
    LD      ($7164), A
    RES     7, (IY+0)
    LD      A, (IX+0)
    RES     2, A
    LD      ($7165), A
    CALL    SUB_93A7
    CALL    SUB_951A
    LD      HL, ($7179)
    CALL    SUB_BDB0
    LD      IX, $718B
    LD      B, 28H
LOC_BBDB:
    LD      D, (IX+1)
    LD      E, (IX+0)
    LD      A, 80H
    AND     D
    JR      Z, LOC_BBF6
    LD      DE, 2
    ADD     IX, DE
    DJNZ    LOC_BBDB
    LD      A, 0
    LD      ($7222), A
    LD      ($7220), A
RET

LOC_BBF6:
    LD      HL, $7223
    INC     (HL)
    LD      ($717D), DE
    LD      ($717B), IX
    LD      IX, $71DC
    LD      IY, $71FE
    LD      ($7179), IY
    LD      A, (IX+0)
    LD      (IY+0), A
    LD      A, (IX+1)
    LD      (IY+1), A
    LD      A, (IX+2)
    LD      (IY+2), A
    LD      A, (IX+3)
    LD      (IY+3), A
    LD      DE, 5
    LD      B, 7
LOC_BC2B:
    ADD     IX, DE
    ADD     IY, DE
    LD      A, (IX+0)
    LD      (IY+0), A
    LD      A, (IX+1)
    LD      (IY+1), A
    LD      A, (IX+2)
    LD      (IY+2), A
    LD      A, (IX+3)
    LD      (IY+3), A
    LD      DE, 4
    DJNZ    LOC_BC2B
    PUSH    IX
    LD      IX, $71FE
    RES     6, (IX+15H)
    POP     IX
    LD      A, 0
    LD      ($7188), A
    CALL    SUB_BB93
    LD      HL, $71FE
    CALL    SUB_BDB0
RET

SUB_BC67:
    PUSH    IX
    LD      HL, $7221
    LD      (HL), 0
    LD      DE, 1
    ADD     IX, DE
    LD      B, 4
    LD      DE, 4
LOC_BC78:
    ADD     IX, DE
    BIT     7, (IX+0)
    JR      Z, LOC_BC81
    INC     (HL)
LOC_BC81:
    DJNZ    LOC_BC78
    POP     IX
    LD      A, (HL)
    ADD     A, 1
    LD      (IX+21H), A
RET

SUB_BC8C:
    LD      A, ($7222)
    CP      86H
    JR      C, LOC_BC9F
    CP      8EH
    JR      C, LOC_BCB6
    CP      8FH
    JR      C, LOC_BC9F
    CP      97H
    JR      C, LOC_BCB6
LOC_BC9F:
    CP      6CH
    JR      C, LOC_BCA7
    CP      80H
    JR      C, LOC_BCBD
LOC_BCA7:
    CP      97H
    JR      C, LOC_BCAF
    CP      0A8H
    JR      C, LOC_BCBD
LOC_BCAF:
    LD      A, 2
    LD      ($7220), A
    JR      LOC_BCC2
LOC_BCB6:
    LD      A, 1
    LD      ($7220), A
    JR      LOC_BCC2
LOC_BCBD:
    LD      A, 3
    LD      ($7220), A
LOC_BCC2:
    LD      B, 28H
    LD      IX, $718B
LOC_BCC8:
    LD      D, (IX+1)
    LD      E, (IX+0)
    LD      A, 80H
    AND     D
    JR      NZ, LOC_BCF3
LOC_BCD3:
    LD      DE, 2
    ADD     IX, DE
    DJNZ    LOC_BCC8
    LD      DE, ($7149)
    CALL    SUB_A2C6
    LD      HL, $723A
    LD      (HL), 67H
    CALL    SUB_962E
    LD      A, 0
    LD      ($7222), A
    LD      ($7220), A
    POP     AF
RET

LOC_BCF3:
    LD      HL, $71DC
    CALL    SUB_BD6E
    LD      IY, $71DC
    LD      A, ($7220)
    CP      2
    JR      Z, LOC_BD1E
    CP      3
    JR      NZ, LOC_BD0D
    LD      DE, 15H
    ADD     IY, DE
LOC_BD0D:
    LD      A, ($714A)
    CP      (IY+1)
    JR      NZ, LOC_BD48
    LD      A, ($7149)
    CP      (IY+2)
    JR      NZ, LOC_BD48
RET

LOC_BD1E:
    PUSH    BC
    LD      B, 4
    LD      DE, 1
    ADD     IY, DE
LOC_BD26:
    LD      DE, 4
    ADD     IY, DE
    BIT     7, (IY+0)
    JR      NZ, LOC_BD36
LOC_BD31:
    DJNZ    LOC_BD26
    POP     BC
    JR      LOC_BCD3
LOC_BD36:
    LD      A, ($714A)
    CP      (IY+1)
    JR      NZ, LOC_BD31
    LD      A, ($7149)
    CP      (IY+2)
    JR      NZ, LOC_BD31
    JR      LOC_BD6C
LOC_BD48:
    LD      A, ($7220)
    CP      3
    JR      NZ, LOC_BCD3
    LD      DE, 4
    ADD     IY, DE
    LD      A, ($714A)
    CP      (IY+1)
    JP      NZ, LOC_BCD3
    LD      A, ($7149)
    CP      (IY+2)
    JP      NZ, LOC_BCD3
    LD      DE, 0FFFCH
    ADD     IY, DE
RET

LOC_BD6C:
    POP     BC
RET

SUB_BD6E:
    LD      A, D
    AND     3FH
    LD      D, A
    LD      ($717D), DE
    LD      ($717B), IX
    PUSH    BC
    PUSH    IX
    LD      BC, 22H
    CALL    READ_VRAM
    POP     IX
    POP     BC
RET

SUB_BD87:
    PUSH    IX
    LD      IX, ($717B)
    BIT     6, (IX+1)
    JR      NZ, LOC_BDAD
    LD      A, ($7223)
    SRA     A
    LD      HL, $7177
    CP      (HL)
    JR      C, LOC_BDAD
    SET     6, (IX+1)
    POP     IX
    LD      A, (IX+21H)
    LD      (IX+4), A
    INC     (HL)
    JR      LOCRET_BDAF
LOC_BDAD:
    POP     IX

LOCRET_BDAF:     
RET

SUB_BDB0:
    LD      DE, ($717D)
    LD      BC, 22H
    LD      IX, ($717B)
    SET     7, (IX+1)
    RST     8
RET

UPDATE_SCORE_AND_EXTRA_PLAYER:         
    PUSH    AF
    PUSH    BC
    PUSH    DE
    PUSH    IX
    PUSH    IY
    CALL    UPDATE_SCORE_A
    POP     IY
    POP     IX
    POP     DE
    POP     BC
    POP     AF
RET

UPDATE_SCORE_A:  
    PUSH    IX
    LD      IX, ($7072)
    INC     HL
    INC     HL
    LD      A, (HL)
    ADD     A, (IX+9)
    DAA
    LD      (IX+9), A
    DEC     HL
    LD      A, (HL)
    ADC     A, (IX+8)
    DAA
    LD      (IX+8), A
    DEC     HL
    LD      A, (HL)
    ADC     A, (IX+7)
    DAA
    LD      (IX+7), A
    CP      1
    JR      Z, HUD_STUFF_00
CHECK_SCORE_FOR_EXTRA_PLAYER:
    CP      (IX+0EH)
    JR      C, LOC_BE0B
    LD      B, 0AH
    LD      A, (IX+0EH)
    ADD     A, B
    DAA
    LD      (IX+0EH), A
    JP      GAINED_EXTRA_PLAYER
LOC_BE0B:
    POP     IX
RET

HUD_STUFF_00:    
    BIT     5, (IX+0)
    JR      NZ, CHECK_SCORE_FOR_EXTRA_PLAYER
    SET     5, (IX+0)
GAINED_EXTRA_PLAYER:
    CALL    PLAY_EXTRA_PLAYER_SOUND
    LD      HL, $7096
    LD      (HL), 3CH
    PUSH    HL
    PUSH    DE
    PUSH    BC
    LD      HL, HUD_02
    LD      DE, 1820H
    LD      BC, 20H
    RST     8
    POP     BC
    POP     DE
    POP     HL
    LD      A, (IX+0AH)
    INC     A
    LD      (IX+0AH), A
    DEC     A
    LD      B, A
    LD      A, 0DH
    ADD     A, B
    LD      D, 1
    LD      E, A
    CALL    SUB_A2C6
    LD      HL, HUD_RELATED_DATA_A
    LD      BC, 6
    RST     8
    CALL    UPDATE_SCORE_C
    JR      LOC_BE0B

SUB_BE4E:
    PUSH    HL
    PUSH    IX
    PUSH    IY
    LD      IX, ($7072)
    LD      IY, $714B
    RES     4, (IX+0)
    LD      B, 3
LOC_BE61:
    LD      A, (IX+7)
    AND     0F0H
    RRCA
    RRCA
    RRCA
    RRCA
    CALL    SUB_BE91
    INC     IY
    LD      A, (IX+7)
    AND     0FH
    CALL    SUB_BE91
    INC     IX
    INC     IY
    DJNZ    LOC_BE61
    LD      D, 0
    LD      E, 0CH
    CALL    SUB_A2C6
    LD      BC, 6
    LD      HL, $714B
    RST     8
    POP     IY
    POP     IX
    POP     HL
RET

SUB_BE91:
    LD      HL, ($7072)
    OR      A
    JR      NZ, LOC_BEA1
    BIT     4, (HL)
    JR      NZ, LOC_BEA1
    LD      (IY+0), 0
    JR      LOCRET_BEA9
LOC_BEA1:
    SET     4, (HL)
    LD      D, 0C3H
    ADD     A, D
    LD      (IY+0), A
LOCRET_BEA9:     
RET

SUB_BEAA:
    PUSH    IX
    PUSH    HL
    PUSH    BC
    LD      IX, ($7072)
    LD      A, (IX+3)
    LD      L, A
    LD      A, (IX+4)
    LD      H, A
    PUSH    HL
    POP     IX
    LD      A, (IX+0CH)
    LD      HL, BYTE_BF65
    LD      E, A
    LD      B, 3
    XOR     A
LOC_BEC7:
    ADD     A, E
    DJNZ    LOC_BEC7
    LD      E, A
    LD      D, 0
    ADD     HL, DE
    LD      A, (HL)
    LD      ($709A), A
    INC     HL
    LD      A, (HL)
    LD      ($709B), A
    INC     HL
    LD      A, (HL)
    LD      ($709C), A
    CALL    SUB_BEE5
    POP     IY
    POP     HL
    POP     IX
RET

SUB_BEE5:
    PUSH    HL
    PUSH    IX
    PUSH    IY
    LD      IY, $709D
    LD      IX, $709A
    LD      B, 3
LOC_BEF4:
    LD      A, (IX+0)
    AND     0F0H
    RRCA
    RRCA
    RRCA
    RRCA
    CALL    SUB_BF26
    INC     IY
    LD      A, (IX+0)
    AND     0FH
    CALL    SUB_BF26
    INC     IY
    INC     IX
    DJNZ    LOC_BEF4
    LD      D, 0
    LD      E, 19H
    CALL    SUB_A2C6
    LD      BC, 4
    LD      HL, $709D
    INC     HL
    INC     HL
    RST     8
    POP     IY
    POP     IX
    POP     HL
RET

SUB_BF26:
    LD      D, 0C3H
    ADD     A, D
    LD      (IY+0), A
RET

SUB_BF2D:
    PUSH    HL
    LD      HL, $709A
    CALL    UPDATE_SCORE_A
    CALL    SUB_BEAA
    LD      A, 0FH
    LD      ($70A3), A
    POP     HL
RET

GAINED_SOME_SCORE_A:
    LD      A, ($70A3)
    OR      A
    CALL    Z, GAINED_SOME_SCORE_B
    DEC     A
    LD      ($70A3), A
RET

GAINED_SOME_SCORE_B:
    LD      A, ($709B)
    OR      A
    JR      Z, LOC_BF61
    SUB     1
    DAA
    LD      ($709B), A
    LD      A, 0FH
    LD      ($70A3), A
    PUSH    AF
    CALL    SUB_BEE5
    POP     AF
RET
LOC_BF61:
    CALL    SUB_8EED
RET

BYTE_BF65:
	DB 000,080,000,000,096,000,000,101,000,000,112,000,000,117,000,000,128,000,000,133,000,000,144,000
BYTE_BF7D:
	DB 010,001,005,008,001,003,006,002,003,005,002,003
BYTE_BF89:
	DB 001,001,001,001,001,001,000,000,000,000,004,008,000,000,002,002,001,001,001,001,000,000,000,000,004,008,001,000,002,002
	DB 001,001,001,001,001,001,000,000,004,008,002,009,003,003,002,002,001,001,000,001,000,001,004,008,003,007,003,004,001,002
	DB 001,001,001,001,001,002,002,004,004,007,004,005,001,002,001,002,001,001,001,002,002,004,005,015,004,006,002,003,001,002
	DB 001,001,001,002,002,004,006,007,003,006,002,003,002,003,001,002,002,002,002,004,007,015,000,000,000,000,000,000,000