; COMPILABLE DISASSEMBLY OF QBERTS QUBES BY CAPTAIN COZMOS (01 NOVEMBER 2023)
; 1ST OF A KIND, STILL NEEDS CLEANUP, NO CHANGES TO THE CODE, STILL HAS A COUPLE OF NO LINKED DATA
; CREDIT GOES WHERE CREDIT IS DUE.  THIS IS A PAINFUL, TIME CONSUMING EXPERIENCE AND WAS DONE AS A FAVOR.
; AGAIN, THIS IS FOR EDUCATION, PLEASE DO NOT SELL MY WORK








; BIOS DEFINITIONS **************************
PLAY_SONGS:         EQU $1F61
CONTROLLER_SCAN:    EQU $1F76
DECODER:            EQU $1F79
GAME_OPT:           EQU $1F7C
FILL_VRAM:          EQU $1F82
TURN_OFF_SOUND:     EQU $1FD6
WRITE_REGISTER:     EQU $1FD9
READ_REGISTER:      EQU $1FDC
WRITE_VRAM:         EQU $1FDF
READ_VRAM:          EQU $1FE2

; RAM DEFINITIONS ***************************
SCORING_RAM:        EQU $7074 ; 2 BYTES $7074 AND $7075
BONUS_TIME_RAM:     EQU $7089



FNAME "QBERT QUBES.ROM"
CPU Z80


    ORG 8000H

    DW 0AA55H
    DW 0FFFFH
    DW 0FFFFH
    DW 0FFFFH
    DW 0FFFFH
    DW START

    JP      LOC_8E78
    JP      RST_10_WRITE_VRAM
    JP      LOC_ABF9
    JP      LOC_8E2F
    JP      LOC_AB5B
    JP      LOC_AAFE
    JP      LOC_8D91
	RETN

    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH


BYTE_8030:
	DB 001,002,003,004,005,006,007,008,009,010,011,012,013,014,015,016,017,018,019,020
    DB 021,022,023,024,025,001,006,011,016,021,002,007,012,017,022,003,008,013,018,023
    DB 004,009,014,019,024,005,010,015,020,025,001,007,013,019,025,021,017,013,009,005
BYTE_806C:
	DB  00H, 00H, 00H, 00H, 03H, 07H, 0FH, 1FH, 00H, 00H, 00H, 00H,0FFH,0FFH,0FFH,0FFH
BYTE_807C:
	DB 000,000,000,000,224,208,176,112
    DB 000,063,063,063,063,063,063,063
    DB 000,254,254,254,254,254,254,254
    DB 240,240,240,240,240,240,240,240
    DB 063,063,063,063,063,063,000,000
    DB 254,254,254,254,254,254,000,000
    DB 240,240,224,192,128,000,000,000
    DB 000,000,000,000,016,016,016,016
    DB 000,000,000,000,016,016,016,016
BYTE_80C4:
	DB 000,000,000,000,016,016,016,048
    DB 000,032,032,032,032,032,032,032
    DB 000,032,032,032,032,032,032,032
    DB 048,048,048,048,048,048,048,048
    DB 032,032,032,032,032,032,000,000
    DB 032,032,032,032,032,032,000,000
    DB 048,048,048,048,000,000,000,000
    DB 000,000,000,000,000,001,007,001
    DB 000,000,000,016,126,255,255,255
    DB 000,000,000,000,000,192,248,254
    DB 015,015,015,031,031,031,063,063
    DB 063,224,252,255,255,255,254,254
    DB 248,206,062,124,124,124,248,248
    DB 063,127,127,127,015,001,000,000
    DB 254,252,252,252,248,248,056,000
    DB 248,240,240,240,192,000,000,000
    DB 000,000,000,000,000,016,016,016
    DB 000,000,000,016,016,016,016,016
    DB 000,000,000,000,000,016,016,016
    DB 032,032,032,032,032,032,032,032
    DB 016,033,032,035,035,035,035,035
    DB 016,016,048,048,048,048,048,048
    DB 032,032,032,032,032,032,000,000
    DB 035,035,035,035,035,035,032,000
    DB 048,048,048,048,048,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,004,014,031,063,127,127
    DB 000,000,000,000,000,128,192,224
    DB 001,003,007,015,031,063,127,255
    DB 192,224,240,248,252,254,255,255
    DB 240,248,252,248,240,224,192,128
    DB 127,063,031,015,007,003,001,000
    DB 255,254,252,248,240,224,192,128
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,016,016,016,016,016,018
    DB 000,000,000,000,000,016,016,016
    DB 032,032,032,032,032,032,032,032
    DB 033,033,033,033,033,033,033,033
    DB 016,016,016,016,016,016,016,032
    DB 032,032,032,032,032,032,032,000
    DB 032,032,032,032,032,032,032,032
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,007,015
    DB 000,000,000,003,031,254,248,240
    DB 000,000,000,128,128,192,192,192
    DB 031,056,015,127,127,127,063,063
    DB 248,248,248,252,252,252,254,254
    DB 224,224,224,240,240,240,248,248
    DB 063,031,031,031,015,015,014,000
    DB 254,255,255,255,248,192,000,000
    DB 240,096,064,000,000,000,000,000
    DB 000,000,000,000,000,000,016,016
    DB 000,000,000,016,016,019,019,019
    DB 000,000,000,048,048,048,048,048
    DB 016,016,032,032,032,032,032,032
    DB 035,035,035,035,035,035,032,032
    DB 048,048,048,048,048,048,048,048
    DB 032,032,032,032,032,032,032,000
    DB 032,032,032,032,032,032,000,000
    DB 048,048,048,000,000,000,000,000
    DB 000,000,000,000,000,000,031,031
    DB 000,000,000,000,000,000,255,255
    DB 000,000,000,000,000,000,000,096
    DB 031,031,031,031,063,063,063,063
    DB 255,255,255,255,254,254,254,254
    DB 096,120,120,120,248,248,248,248
    DB 063,063,063,000,031,007,007,000
    DB 254,254,254,000,255,255,255,000
    DB 240,240,240,240,048,208,192,000
    DB 000,000,000,000,000,000,016,016
    DB 000,000,000,000,000,000,016,016
    DB 000,000,000,000,000,000,000,048
    DB 016,016,016,016,016,016,016,016
    DB 016,016,016,016,016,016,016,016
    DB 048,048,048,048,048,048,048,048
    DB 016,016,016,000,032,032,032,000
    DB 016,016,016,000,032,032,032,000
    DB 048,048,048,048,048,032,032,000
    DB 000,000,000,000,015,015,015,015
    DB 000,000,000,000,255,255,255,255
    DB 000,000,000,000,128,160,160,176
    DB 031,031,031,031,063,063,063,063
    DB 255,255,255,255,254,254,254,254
    DB 112,120,120,124,252,252,248,248
    DB 000,063,031,031,015,015,007,007
    DB 000,254,255,255,255,255,255,255
    DB 248,248,112,112,176,176,240,192
    DB 000,000,000,000,016,016,016,016
    DB 000,000,000,000,016,016,016,016
    DB 000,000,000,000,016,016,016,016
    DB 016,016,016,016,016,016,016,016
    DB 016,016,016,016,016,016,016,019
    DB 048,048,048,048,048,048,048,048
    DB 000,032,032,032,032,032,032,032
    DB 000,032,032,032,032,032,032,032
    DB 048,048,048,048,032,032,032,032
    DB 000,000,000,007,007,015,015,031
    DB 000,000,000,255,255,255,255,255
    DB 000,000,000,192,192,176,176,112
    DB 031,063,063,000,063,063,063,063
    DB 255,254,254,001,254,254,254,254
    DB 120,248,248,248,252,252,252,252
    DB 031,031,031,031,015,015,015,000
    DB 255,255,255,255,255,255,255,000
    DB 120,120,112,112,160,160,128,000
    DB 000,000,000,016,016,016,016,016
    DB 000,000,000,016,016,016,016,016
    DB 000,000,000,016,016,016,016,048
    DB 016,016,016,000,032,032,032,032
    DB 016,016,016,048,032,032,032,032
    DB 048,048,048,048,048,048,048,048
    DB 032,032,032,032,032,032,032,000
    DB 032,032,032,032,032,032,032,000
    DB 048,048,048,048,032,032,032,000
BYTE_845C:
	DB 0A3H, 18H,0AFH, 18H,0F2H, 18H, 35H, 19H, 78H, 19H,0BBH, 19H,0ECH, 18H, 2FH, 19H, 72H, 19H,0B5H, 19H
    DB 0F8H, 19H, 29H, 19H, 6CH, 19H,0AFH, 19H,0F2H, 19H, 35H, 1AH, 66H, 19H,0A9H, 19H,0ECH, 19H, 2FH, 1AH
    DB  72H, 1AH,0A3H, 19H,0E6H, 19H, 29H, 1AH, 6CH, 1AH,0AFH, 1AH
BYTE_8490:
	DB  00H, 00H, 80H, 08H, 08H, 08H, 80H, 08H, 08H, 08H, 88H, 08H, 08H, 08H, 88H, 10H, 08H, 08H, 88H, 10H, 10H, 08H, 88H, 10H, 10H, 10H, 02H, 02H, 00H, 00H
    DB  01H, 01H, 02H, 02H, 00H, 00H, 01H, 01H, 08H, 08H, 06H, 04H, 07H, 09H, 02H, 02H, 06H, 04H, 01H, 01H, 0BH, 0BH, 09H, 07H, 02H, 0AH, 00H, 0BH, 09H, 07H
    DB  0AH, 0AH, 0AH, 02H, 0BH, 00H, 05H, 01H, 03H, 08H, 00H, 00H, 07H, 09H, 01H, 05H, 08H, 03H, 04H, 06H, 05H, 05H, 03H, 03H, 04H, 06H, 05H, 05H, 02H, 02H
    DB  03H, 03H, 04H, 04H, 04H, 04H, 00H, 00H, 01H, 01H, 05H, 05H, 02H, 02H, 01H, 01H, 00H, 00H, 03H, 03H, 11H, 15H, 05H, 0CH, 17H, 13H, 0DH, 04H, 0EH, 06H
    DB  12H, 14H, 07H, 0FH, 16H, 10H, 14H, 10H, 01H, 08H, 12H, 16H, 09H, 00H, 02H, 0AH, 13H, 15H, 0BH, 03H, 17H, 11H, 15H, 11H, 04H, 0DH, 13H, 17H, 0CH, 05H
    DB  06H, 0EH, 10H, 16H, 0FH, 07H, 14H, 12H, 10H, 14H, 00H, 09H, 16H, 12H, 08H, 01H, 0AH, 02H, 11H, 17H, 03H, 0BH, 15H, 13H, 04H, 0CH, 03H, 0AH, 08H, 00H
    DB  07H, 0EH, 0DH, 05H, 0BH, 02H, 01H, 09H, 0FH, 06H, 0CH, 04H, 02H, 0BH, 00H, 08H, 06H, 0FH, 05H, 0DH, 0AH, 03H, 09H, 01H, 0EH, 07H
BYTE_855E:
	DB  76H, 85H, 7FH, 85H,0A3H, 85H,0B5H, 85H
BYTE_8566:
	DB 0FDH, 85H,0FFH, 85H, 01H, 86H, 04H, 86H
BYTE_856E:
	DB 0AAH, 84H,0B6H, 84H,0E6H, 84H,0FEH, 84H, 50H, 50H,0A0H, 50H,0A0H, 50H,0A0H, 50H, 50H, 50H, 50H,0A0H, 50H,0A0H, 50H,0A0H, 50H, 50H,0A0H,0A0H, 50H,0A0H
    DB  50H,0A0H, 50H,0A0H,0A0H, 50H, 50H,0A0H, 50H,0A0H, 50H,0A0H, 50H, 50H,0A0H,0A0H, 50H,0A0H, 50H,0A0H, 50H,0A0H,0A0H, 50H,0A0H, 20H, 50H, 20H,0A0H,0A0H
    DB  50H, 20H,0A0H, 20H, 50H, 20H, 50H,0A0H, 20H,0A0H, 50H,0F0H, 80H, 50H,0F0H,0D0H, 20H,0F0H, 50H,0D0H,0F0H, 20H, 80H, 80H,0F0H, 20H, 80H,0A0H, 50H, 80H
    DB  50H,0F0H, 80H, 20H,0A0H,0A0H, 80H, 20H,0A0H,0D0H, 50H,0A0H, 50H, 80H,0A0H, 20H,0D0H,0D0H,0F0H, 50H,0D0H,0A0H, 20H,0D0H, 50H,0A0H,0D0H, 20H,0F0H, 50H
    DB 0F0H, 80H, 50H, 80H,0A0H, 50H,0A0H,0D0H, 50H,0D0H,0F0H, 20H,0F0H,0D0H, 20H, 80H,0F0H, 20H,0A0H, 80H, 20H,0D0H,0A0H, 50H,0A0H, 50H,0A0H, 50H,0A0H, 20H
BYTE_8604:
	DB 0F0H, 80H,0A0H,0D0H, 50H, 20H
BYTE_860A:
	DB  12H, 86H, 2DH, 86H, 63H, 86H, 99H, 86H, 87H, 8DH,0B9H, 99H, 9FH,0A3H,0ABH,0B1H,0B5H, 87H, 8DH,0BAH, 97H, 9DH,0A5H,0A9H,0AFH,0B7H, 85H, 8BH,0BBH, 99H
    DB  9FH,0A5H,0ABH,0B1H,0B7H, 87H, 8DH,0B9H, 99H, 9FH,0A3H,0ABH,0B1H,0B5H, 87H, 8DH,0BAH, 97H, 9DH,0A5H,0A9H,0AFH,0B7H, 85H, 8BH,0BBH, 99H, 9FH,0A5H,0ABH
    DB 0B1H,0B7H, 85H, 8BH,0BCH, 97H, 9DH,0A5H,0A9H,0AFH,0B7H, 85H, 8BH,0BDH, 99H, 9FH,0A3H,0ABH,0B1H,0B5H, 87H, 8DH,0BEH, 97H, 9DH,0A3H,0A9H,0AFH,0B5H, 87H
    DB  8DH,0B9H, 97H, 9DH,0A6H,0A9H,0AFH,0B8H, 87H, 8DH,0BAH, 9AH,0A0H,0A3H,0ACH,0B2H,0B5H, 85H, 8BH,0BBH, 99H, 9FH,0A6H,0ABH,0B1H,0B8H, 85H, 8BH,0BCH, 9AH
    DB 0A0H,0A5H,0ACH,0B2H,0B7H, 88H, 8EH,0BDH, 99H, 9FH,0A3H,0ABH,0B1H,0B5H, 88H, 8EH,0BEH, 97H, 9DH,0A5H,0A9H,0AFH,0B7H, 83H, 89H,0B9H, 96H, 9CH,0A5H,0A8H
    DB 0AEH,0B7H, 83H, 89H,0BAH, 98H, 9EH,0A6H,0AAH,0B0H,0B8H, 83H, 89H,0BBH, 99H, 9FH,0A4H,0ABH,0B1H,0B6H, 83H, 89H,0BCH, 9AH,0A0H,0A2H,0ACH,0B2H,0B4H, 84H
    DB  8AH,0BDH, 95H, 9BH,0A6H,0A7H,0ADH,0B8H, 84H, 8AH,0BEH, 97H, 9DH,0A5H,0A9H,0AFH,0B7H, 84H, 8AH,0BFH, 99H, 9FH,0A1H,0ABH,0B1H,0B3H, 84H, 8AH,0C0H, 9AH
    DB 0A0H,0A3H,0ACH,0B2H,0B5H, 85H, 8BH,0C1H, 96H, 9CH,0A6H,0A8H,0AEH,0B8H, 85H, 8BH,0C2H, 98H, 9EH,0A5H,0AAH,0B0H,0B7H, 85H, 8BH,0C3H, 99H, 9FH,0A2H,0ABH
    DB 0B1H,0B4H, 85H, 8BH,0C4H, 9AH,0A0H,0A4H,0ACH,0B2H,0B6H, 86H, 8CH,0C5H, 95H, 9BH,0A5H,0A7H,0ADH,0B7H, 86H, 8CH,0C6H, 97H, 9DH,0A6H,0A9H,0AFH,0B8H, 86H
    DB  8CH,0C7H, 99H, 9FH,0A3H,0ABH,0B1H,0B5H, 86H, 8CH,0C8H, 9AH,0A0H,0A1H,0ACH,0B2H,0B3H, 87H, 8DH,0C9H, 95H, 9BH,0A2H,0A7H,0ADH,0B4H, 87H, 8DH,0CAH, 96H
    DB  9CH,0A3H,0A8H,0AEH,0B5H, 87H, 8DH,0CBH, 97H, 9DH,0A4H,0A9H,0AFH,0B6H, 87H, 8DH,0CCH, 98H, 9EH,0A1H,0AAH,0B0H,0B3H, 88H, 8EH,0CDH, 95H, 9BH,0A4H,0A7H
    DB 0ADH,0B6H, 88H, 8EH,0CEH, 96H, 9CH,0A1H,0A8H,0AEH,0B3H, 88H, 8EH,0CFH, 97H, 9DH,0A2H,0A9H,0AFH,0B4H, 88H, 8EH,0D0H, 98H, 9EH,0A3H,0AAH,0B0H,0B5H
PATTERNS_03:
	DB 028,062,045,127,254,220,020,054
    DB 008,028,042,073,008,008,008,008
    DB 016,032,064,255,064,032,016,000
    DB 008,008,008,008,073,042,028,008
    DB 000,015,063,121,112,240,249,255
    DB 127,127,063,031,017,051,025,014
    DB 000,000,192,032,000,000,048,252
    DB 254,217,137,006,000,000,128,224
    DB 000,000,000,003,007,004,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,096,240,144,000,000
    DB 000,000,000,000,000,000,000,000
    DB 007,031,057,048,112,121,127,127
    DB 127,063,063,031,017,051,025,014
    DB 000,192,032,000,000,048,252,254
    DB 217,201,134,000,000,000,128,224
    DB 000,000,003,007,004,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,096,240,144,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,007,031,063,062,126,127,127
    DB 127,063,063,031,015,007,014,025
    DB 000,014,223,063,030,028,056,240
    DB 240,240,224,224,192,112,224,128
    DB 000,000,000,001,001,007,003,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,128,128,000,000
    DB 000,000,000,000,000,000,000,000
    DB 007,031,063,062,126,127,127,127
    DB 063,063,031,015,004,007,014,025
    DB 014,223,063,030,028,056,240,240
    DB 240,224,224,192,064,112,224,128
    DB 000,000,001,001,007,003,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,128,128,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,008,028,030
    DB 030,031,015,004,004,007,079,201
    DB 000,000,000,000,000,032,112,240
    DB 240,240,224,000,000,226,251,255
    DB 206,111,055,031,015,015,015,079
    DB 119,051,017,003,006,003,000,000
    DB 124,188,216,224,224,224,226,251
    DB 251,238,204,008,224,176,096,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,003,002,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,192,128,000,000,000
    DB 008,028,030,030,031,015,004,004
    DB 007,015,009,008,044,118,223,207
    DB 032,112,240,240,240,224,000,000
    DB 224,248,252,124,060,088,198,230
    DB 079,015,079,223,119,051,027,001
    DB 001,001,000,000,000,000,000,000
    DB 228,226,251,238,204,152,000,128
    DB 000,128,192,096,032,096,064,000
    DB 000,000,000,000,000,000,003,001
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,192,064
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,008,028,030
    DB 030,031,015,007,015,015,079,207
    DB 000,000,000,000,000,032,112,240
    DB 240,244,238,222,254,252,244,198
    DB 207,111,055,031,015,015,015,079
    DB 119,051,017,003,006,003,000,000
    DB 230,204,216,240,224,224,226,251
    DB 251,238,204,008,224,176,096,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 008,028,030,030,031,015,007,015
    DB 015,015,015,015,039,119,223,207
    DB 032,112,240,240,244,238,158,254
    DB 252,240,128,128,232,220,246,230
    DB 079,015,079,223,119,051,027,001
    DB 001,001,000,000,000,000,000,000
    DB 228,226,251,238,204,152,000,128
    DB 128,224,192,096,032,096,064,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,008,056,124,127,127,127
    DB 063,031,015,127,060,031,015,012
    DB 000,000,000,112,120,252,252,254
    DB 254,254,124,184,248,120,096,000
    DB 000,000,006,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,096,096,192,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 008,056,124,127,127,127,063,031
    DB 015,127,126,056,060,030,030,024
    DB 000,112,120,252,252,254,254,254
    DB 124,184,192,224,240,240,192,000
    DB 006,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 096,096,192,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,001,003,006,000,000,004
    DB 006,003,003,015,015,007,003,001
    DB 000,000,192,224,000,144,144,000
    DB 064,224,192,112,184,220,238,238
    DB 000,000,000,000,015,006,006,015
    DB 013,000,000,000,000,000,000,000
    DB 000,000,000,000,128,240,224,192
    DB 128,000,000,000,000,000,000,000
    DB 001,003,006,000,000,004,006,003
    DB 003,002,002,015,015,007,003,001
    DB 192,224,000,144,144,000,064,224
    DB 192,064,064,112,184,220,238,238
    DB 000,000,015,006,006,015,013,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,128,240,224,192,128,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,001,003,007,006,006,006
    DB 007,003,003,015,015,007,003,001
    DB 000,000,192,224,032,000,000,000
    DB 032,224,192,112,184,220,238,238
    DB 000,000,000,000,011,005,005,005
    DB 011,000,000,000,000,000,000,000
    DB 000,000,000,000,000,128,128,128
    DB 000,000,000,000,000,000,000,000
    DB 001,003,007,006,006,006,007,003
    DB 003,002,002,015,015,007,003,001
    DB 192,224,032,000,000,000,032,224
    DB 192,064,064,112,184,220,238,238
    DB 000,000,011,005,005,005,011,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,128,128,128,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,003,014
    DB 027,055,055,063,063,031,015,003
    DB 000,000,000,000,000,000,224,248
    DB 252,254,254,254,254,252,248,224
    DB 000,000,000,000,000,000,000,001
    DB 004,008,008,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,001,007,013,011
    DB 027,031,031,031,015,015,007,001
    DB 000,000,000,000,192,112,248,248
    DB 252,252,252,252,248,248,240,192
    DB 000,000,000,000,000,000,002,004
    DB 004,000,000,000,000,000,000,000
    DB 000,000,000,000,000,128,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,007,029,055,111,239
    DB 223,223,255,223,127,063,031,007
    DB 000,000,000,224,248,252,254,255
    DB 255,255,255,255,254,252,248,224
    DB 000,000,000,000,002,008,016,016
    DB 032,032,000,032,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,003,014,027,055,055,111,111
    DB 127,111,127,063,063,031,015,003
    DB 000,192,240,248,252,252,254,254
    DB 254,254,254,252,252,248,240,192
    DB 000,000,001,004,008,008,016,016
    DB 000,016,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
PATTERNS_04:
    DB 000,000,003,015,031,063,063,124
    DB 115,231,238,221,219,219,236,103
    DB 031,255,248,247,239,239,247,127
    DB 191,254,125,187,235,109,239,204
    DB 248,255,127,063,159,159,159,159
    DB 063,125,237,237,236,225,141,237
    DB 000,000,192,240,248,252,252,230
    DB 230,231,231,231,103,239,239,238
    DB 115,060,063,031,015,003,000,000
    DB 000,000,000,000,000,000,000,000
    DB 156,127,255,255,255,255,255,031
    DB 000,000,000,000,000,000,000,000
    DB 236,225,141,237,237,239,255,248
    DB 240,224,192,128,000,000,000,000
    DB 126,204,204,248,240,192,000,000
    DB 000,000,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,003
    DB 012,024,017,034,036,036,019,024
    DB 000,000,007,008,016,016,008,128
    DB 064,001,194,036,020,146,016,051
    DB 000,000,128,192,096,096,096,096
    DB 192,130,018,018,019,030,114,018
    DB 000,000,000,000,000,000,000,024
    DB 024,024,024,024,152,016,016,016
    DB 012,003,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 099,128,000,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000
    DB 019,030,114,018,018,016,000,000
    DB 000,000,000,000,000,000,000,000
    DB 128,048,048,000,000,000,000,000
    DB 000,000,000,000,000,000,000,000

LOC_8D91:                              
    LD      HL, $703F
    RST     8
    LD      A, (HL)
    AND     3FH
RET

SUB_8D99:                              
    LD      C, A
    LD      HL, $703F
    ADD     A, L
    LD      L, A
    LD      A, (HL)
    AND     3FH
    LD      B, A
    LD      A, ($701B)
    CP      2
    JR      NZ, LOC_8DB2
    LD      A, B
    CP      6
    JR      C, LOC_8DB2
    SUB     6
    LD      B, A

LOC_8DB2:                              
    LD      A, B
    ADD     A, A
    ADD     A, A
    ADD     A, A
    ADD     A, B
    LD      HL, BYTE_860A
    CALL    SUB_9250
    ADD     A, L
    JR      NC, LOC_8DC1
    INC     H

LOC_8DC1:                              
    LD      L, A
    LD      A, C

LOC_8DC3:                              
    LD      DE, $702B
    LD      BC, 9
    LDIR

SUB_8DCB:                              
    ADD     A, A
    LD      HL, BYTE_845C
    ADD     A, L
    LD      L, A
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    LD      HL, $702B
    LD      BC, 3
    CALL    RST_10_WRITE_VRAM
    CALL    SUB_8DE0

SUB_8DE0:                              
    LD      A, 20H
    ADD     A, E
    JR      NC, LOC_8DE6
    INC     D

LOC_8DE6:                              
    LD      E, A
    LD      BC, 3
    JP      RST_10_WRITE_VRAM

SUB_8DED:                              
    LD      HL, BYTE_9F63
    JR      LOC_8DC3

SUB_8DF2:                              
    PUSH    BC

LOC_8DF3:                              
    LD      C, 0
    LD      A, (HL)
    AND     0F0H
    JR      Z, LOC_8E0C
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    DEC     A
    PUSH    DE
    ADD     A, E
    JR      NC, LOC_8E08
    INC     D

LOC_8E08:                              
    LD      E, A
    LD      A, (DE)
    POP     DE
    LD      C, A

LOC_8E0C:                              
    LD      A, (HL)
    AND     0FH
    JR      Z, LOC_8E24
    DEC     A
    PUSH    DE
    ADD     A, E
    JR      NC, LOC_8E17
    INC     D

LOC_8E17:                              
    LD      E, A
    LD      A, (DE)
    POP     DE
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    OR      C
    LD      C, A

LOC_8E24:                              
    LD      A, C
    LD      (IX+0), A
    INC     IX
    INC     HL
    DJNZ    LOC_8DF3
    POP     BC
RET

LOC_8E2F:                              
    RST     8
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
RET

SUB_8E34:                              
    PUSH    AF
    LD      A, ($701C)
    AND     1
    LD      H, A
    LD      L, 1
    CALL    DECODER
    POP     AF
    CP      L
RET

SUB_8E43:                              
    LD      B, 10H

LOOP_8E45:                             
    CALL    READ_REGISTER
	HALT
    CALL    READ_REGISTER
    LD      A, 0FH
    PUSH    BC
    CALL    SUB_8E34
    POP     BC
    JR      NZ, SUB_8E43
    DJNZ    LOOP_8E45
RET

SUB_8E58:                              
    CALL    READ_REGISTER
	HALT
    PUSH    BC
    PUSH    AF
    SUB     A
    CALL    SUB_8E34
    JR      NZ, LOC_8E73
    CALL    TURN_OFF_SOUND
    CALL    SUB_8E43

LOC_8E6A:                              
    SUB     A
    CALL    SUB_8E34
    JR      NZ, LOC_8E6A
    CALL    SUB_8E43

LOC_8E73:                              
    POP     AF
    POP     BC
    JP      READ_REGISTER

LOC_8E78:                              
    ADD     A, L
    JR      NC, LOC_8E7C
    INC     H
LOC_8E7C:                              
    LD      L, A
RET

RST_10_WRITE_VRAM:                     
    PUSH    DE
    CALL    WRITE_VRAM
    POP     DE
RET

SUB_8E84:                              
    PUSH    BC
    LD      B, C
    LD      C, A
    CALL    WRITE_REGISTER
    POP     BC
RET

SUB_8E8C:                              
    LD      HL, UNK_8EA2
    LD      B, 8
    LD      C, 0
LOC_8E93:                              
    LD      A, (HL)
    CALL    SUB_8E84
    INC     HL
    INC     C
    DJNZ    LOC_8E93
RET

BLANK_THE_SCREEN:                      
    LD      BC, 1A2H
    JP      WRITE_REGISTER

UNK_8EA2:
	DB    2               
    DB 0E2H
    DB    6
    DB  7FH
    DB    7
    DB  3CH
    DB    7
    DB 0F1H

SUB_8EAA:                              
    PUSH    BC
    PUSH    DE
    LD      DE, $7300
    LD      BC, 8
    LDIR
    PUSH    HL
    LD      HL, $7300
    LD      BC, 28H
    LDIR
    POP     HL
    POP     DE
    POP     BC
RET

SUB_8EC1:                              
    LD      BC, 130H
    JR      LOC_8EC6

LOC_8EC6:                              
    PUSH    BC
    LD      B, 0
    LD      HL, $7300
    CALL    SUB_8EF7
    POP     BC
    LD      A, C
    CALL    SUB_8ED7
    DJNZ    LOC_8EC6
RET

SUB_8ED7:                              
    ADD     A, E
    JR      NC, LOC_8EDB
    INC     D

LOC_8EDB:                              
    LD      E, A
RET

SUB_8EDD:                              
    LD      DE, 25C8H
    LD      BC, 1A08H
    JR      LOC_8EC6

; ********************************* NO LINK DEFINED YET
    DB    1
    DB  38H
    DB    7
    DB  18H
    DB 0DCH
    DB    1
    DB  48H
    DB 0AAH
    DB  11H
    DB    0
    DB    0
    DB  18H
    DB 0D4H

SUB_8EF2:                              
    LD      BC, 930H
    JR      LOC_8EC6

SUB_8EF7:                              
    PUSH    DE
    CALL    SUB_8F07
    CALL    SUB_8F03
    CALL    SUB_8F03
    POP     DE
RET

SUB_8F03:                              
    LD      A, 8
    ADD     A, D
    LD      D, A

SUB_8F07:                              
    PUSH    HL
    PUSH    BC
    RST     10H
    POP     BC
    POP     HL
RET

SUB_8F0D:                              
    PUSH    AF
    LD      A, ($7035)
    INC     A
    LD      ($7035), A
    LD      A, ($701A)
    SET     1, A
    LD      ($701A), A
    PUSH    DE
    LD      A, 0EH
    RST     18H
    POP     DE
    POP     AF
RET

SUB_8F24:                              
    LD      A, ($7073)
    LD      DE, (SCORING_RAM)
    LD      HL, $7300
    CALL    SUB_8F49
    LD      A, D
    CALL    SUB_8F49
    LD      A, E
    CALL    SUB_8F49
    LD      B, 5
    CALL    SUB_9616
    LD      HL, $7300
    LD      DE, 1823H
    LD      BC, 6
    RST     10H
RET

SUB_8F49:                              
    LD      B, A
    CALL    SUB_A2E8
    LD      (HL), A
    INC     HL
    LD      A, B
    AND     0FH
    OR      30H
    LD      (HL), A
    INC     HL
RET

SUB_8F57:                              
    LD      A, ($7014)
    AND     A
    JR      Z, LOC_8F62
    CP      5
    JR      NC, LOC_8F62
RET

LOC_8F62:                              
    LD      IY, $7116
    LD      B, 10H

LOC_8F68:                              
    LD      A, (IY+0)
    AND     3FH
    CALL    NZ, SUB_8F8E
    LD      DE, ($71DD)
    LD      A, D
    OR      E
    JR      Z, LOC_8F7F
    DEC     DE
    LD      ($71DD), DE
    JR      LOC_8F83

LOC_8F7F:                              
    INC     IY
    DJNZ    LOC_8F68

LOC_8F83:                              
    LD      HL, $7156
    LD      DE, 1E00H
    LD      BC, 80H
    RST     10H
RET

SUB_8F8E:                              
    PUSH    BC
    PUSH    AF
    LD      A, 10H
    SUB     B
    LD      B, A
    LD      ($71DC), A
    ADD     A, A
    LD      C, A
    ADD     A, A
    LD      HL, $7156
    RST     8
    PUSH    HL
    POP     IX
    LD      A, C
    LD      HL, $7136
    RST     8
    LD      ($71DA), HL
    LD      A, ($7017)
    SUB     3
    LD      B, A
    POP     AF
    CP      B
    JP      NC, LOC_8FC3
    CP      1
    JP      NZ, LOC_9093
    PUSH    BC
    SET     3, (IY-10H)
    RST     28H
    POP     BC
    JP      LOC_9093

LOC_8FC3:                              
    LD      HL, ($71DA)
    LD      A, (HL)
    CP      0E8H
    JR      Z, LOC_8FDA
    CP      78H
    JR      Z, LOC_8FDA
    INC     HL
    LD      A, (HL)
    CP      0F0H
    JR      Z, LOC_8FDA
    CP      50H
    JP      NZ, LOC_9093

LOC_8FDA:                              
    LD      A, (IY-10H)
    AND     7
    DEC     A
    JR      NZ, LOC_8FF2
    LD      A, 8
    PUSH    IX
    PUSH    IY
    RST     18H
    POP     IY
    POP     IX
    LD      A, (IX+4)
    JR      LOC_9004

LOC_8FF2:                              
    CP      0FFH
    JR      NZ, LOC_9001
    LD      A, 9
    PUSH    IX
    PUSH    IY
    RST     18H
    POP     IY
    POP     IX

LOC_9001:                              
    LD      A, (IX+0)

LOC_9004:                              
    CP      0C0H
    JR      NC, LOC_9017
    INC     (IX+0)
    INC     (IX+0)
    INC     (IX+40H)
    INC     (IX+40H)
    JP      LOC_916B

LOC_9017:                              
    LD      A, (IX+2)
    AND     A
    JR      NZ, LOC_9046
    INC     A
    LD      ($7010), A
    LD      A, ($7014)
    CP      5
    JR      Z, LOC_9036
    LD      A, 2
    LD      ($7014), A
    SUB     A
    CALL    SUB_954F
    POP     BC
    POP     AF
    JP      LOC_8F83

LOC_9036:                              
    LD      A, 4
    LD      ($7014), A
    LD      HL, 1
    LD      (BONUS_TIME_RAM), HL
    POP     BC
    POP     AF
    JP      LOC_8F83

LOC_9046:                              
    SUB     A
    LD      (IX+3), A
    LD      (IX+43H), A
    LD      (IX+0), A
    LD      (IX+40H), A
    LD      HL, ($71DA)
    LD      (HL), A
    INC     HL
    LD      (HL), A
    LD      A, (IY-10H)
    AND     7
    SUB     3
    CP      2
    JR      NC, LOC_9077
    LD      HL, $71DF

LOC_9067:                              
    LD      A, (HL)
    CP      2
    JR      NZ, LOC_9074
    LD      A, (IY-10H)
    AND     7
    LD      (HL), A
    JR      LOC_9077

LOC_9074:                              
    INC     HL
    JR      LOC_9067

LOC_9077:                              
    SUB     A
    LD      (IY-20H), A
    LD      (IY+0), A
    LD      A, 1
    LD      (IY+10H), A
    LD      A, (IY-10H)
    AND     7
    DEC     A
    JR      NZ, LOC_9091
    LD      (IX+7), A
    LD      (IX+4), A

LOC_9091:                              
    POP     BC
RET

LOC_9093:                              
    INC     (IY+0)
    LD      A, (IY+0)
    EXX
    LD      B, A
    EXX
    AND     3FH
    PUSH    AF
    LD      A, ($7017)
    LD      L, A
    POP     AF
    CP      L
    JR      NZ, LOC_9101
    LD      HL, BYTE_926F
    LD      A, ($7012)
    AND     7
    RST     8
    LD      A, (HL)
    LD      (IY-20H), A
    RES     3, (IY-10H)
    LD      A, (IY+0)
    AND     0C0H
    LD      (IY+0), A
    RLCA
    RLCA
    LD      DE, BYTE_924C
    CALL    SUB_8ED7
    LD      A, (DE)
    ADD     A, (IY+10H)
    LD      (IY+10H), A
    RST     28H
    LD      A, (IY-10H)
    AND     A
    JP      NZ, LOC_90F3
    LD      A, ($7014)
    AND     A
    JR      Z, LOC_90EA
    CP      6
    JP      Z, LOC_916B
    LD      A, 4
    LD      ($7014), A
    JP      LOC_916B

LOC_90EA:                              
    LD      DE, 5
    CALL    ADD_SOME_SCORE
    JP      LOC_916B

LOC_90F3:                              
    DEC     A
    JP      Z, LOC_916B
    LD      A, 4
    PUSH    IY
    RST     18H
    POP     IY
    JP      LOC_916B

LOC_9101:                              
    DEC     A
    EXX
    BIT     7, B
    PUSH    AF
    CALL    SUB_925C
    POP     AF
    PUSH    HL
    CALL    SUB_925C
    LD      A, B
    AND     0C0H
    LD      B, A
    SRL     B
    SRL     B
    SRL     B
    OR      B
    AND     88H
    LD      C, A
    LD      A, (HL)
    XOR     C
    EXX
    CALL    SUB_918E
    LD      A, (IX+1)
    ADD     A, B
    LD      (IX+1), A
    LD      (IX+41H), A
    EXX
    LD      A, B
    AND     A
    JR      Z, LOC_9135
    CP      18H
    JR      NZ, LOC_913D

LOC_9135:                              
    LD      HL, ($71DA)
    LD      A, (HL)
    EXX
    ADD     A, B
    EXX
    LD      (HL), A

LOC_913D:                              
    POP     HL
    LD      A, (HL)
    XOR     C
    EXX
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    CALL    SUB_918E
    LD      A, (IX+0)
    ADD     A, B
    LD      (IX+0), A
    LD      (IX+40H), A
    EXX
    LD      A, B
    EXX
    AND     A
    JR      Z, LOC_916B
    CP      18H
    JR      Z, LOC_916B
    EXX
    LD      HL, ($71DA)
    INC     HL
    LD      A, (HL)
    EXX
    ADD     A, B
    EXX
    LD      (HL), A
    EXX

LOC_916B:                              
    LD      A, (IY-10H)
    AND     7
    DEC     A
    JR      NZ, LOC_918C
    PUSH    IX
    POP     DE
    LD      HL, 4
    ADD     HL, DE
    EX      DE, HL
    LD      BC, 4
    LDIR
    LD      A, (IX+2)
    ADD     A, 4
    LD      (IX+6), A
    LD      A, (HL)
    ADD     A, 10H
    LD      (HL), A

LOC_918C:                              
    POP     BC
RET

SUB_918E:                              
    AND     0FH
    LD      DE, BYTE_919B
    AND     0FH
    CALL    SUB_8ED7
    LD      A, (DE)
    LD      B, A
RET

BYTE_919B:
	DB  00H, 01H, 02H, 03H, 04H, 05H, 06H, 07H, 00H,0FFH,0FEH,0FDH,0FCH,0FBH,0FAH,0F9H
BYTE_91AB:
	DB 0F8H, 91H, 91H, 91H, 91H, 91H, 91H, 00H, 91H, 00H, 91H, 00H, 01H, 11H, 01H, 10H, 01H, 10H, 01H, 01H, 10H, 01H, 00H, 11H, 00H, 11H, 00H, 10H, 01H, 10H
    DB  01H, 11H, 10H, 10H, 11H, 10H, 10H, 11H, 10H, 10H, 11H, 10H, 10H, 11H, 10H, 10H, 10H, 10H
BYTE_91DB:
	DB  10H, 91H, 91H, 91H, 91H, 91H, 91H, 00H, 91H, 00H, 91H, 00H, 01H, 11H, 01H, 10H, 01H, 10H, 01H, 01H, 10H, 01H, 00H, 11H, 00H, 11H, 00H, 10H, 01H, 20H
    DB  01H, 11H, 10H, 20H, 11H, 10H, 20H, 11H, 20H, 11H, 11H, 20H, 10H
BYTE_9206:
	DB  11H, 92H, 91H, 92H, 91H, 92H, 91H, 00H, 91H, 00H, 91H, 00H, 01H, 11H, 01H, 10H, 01H, 20H, 01H, 01H, 20H, 01H, 00H, 21H, 00H, 21H, 00H, 20H, 01H, 20H
    DB  01H, 21H, 20H, 20H, 21H, 20H, 20H
BYTE_922B:
	DB  11H,0A2H,0A2H, 92H, 92H, 91H, 91H, 00H, 91H, 11H, 11H, 00H, 11H, 11H, 11H, 10H, 11H, 10H, 11H, 11H, 10H, 11H, 10H, 11H, 10H, 11H, 10H, 20H, 21H, 20H
    DB  21H, 21H, 10H
BYTE_924C:
	DB  01H, 05H,0FBH,0FFH

SUB_9250:                              
    PUSH    AF
    PUSH    DE
    LD      A, ($701B)
    AND     7
    RST     20H
    EX      DE, HL
    POP     DE
    POP     AF
RET

SUB_925C:                              
    JR      Z, LOC_926A
    PUSH    AF
    LD      A, ($7017)
    DEC     A
    LD      E, A
    POP     AF
    SUB     E
    JR      NC, LOC_926A
    NEG

LOC_926A:                              
    LD      HL, ($7018)
    RST     8
RET

BYTE_926F:
	DB  28H, 23H, 1EH, 19H, 14H, 0FH, 0AH, 05H
    DB  40H, 91H, 87H, 60H, 91H, 88H, 40H, 11H, 8AH, 40H, 91H, 8AH, 40H, 11H, 8BH, 40H, 91H, 8BH, 40H, 11H, 8CH, 40H, 91H, 88H

SUB_928F:                              
    CALL    BLANK_THE_SCREEN
    CALL    SUB_AAB4
    LD      A, ($7012)
    AND     3
    JR      Z, LOC_929D
    DEC     A

LOC_929D:                              
    ADD     A, 0
    RST     18H
    LD      HL, 0
    LD      ($7010), HL
    CALL    SUB_8E8C

LOC_92A9:                              
    CALL    SUB_8E58
    CALL    SUB_AC51
    LD      A, ($7010)
    INC     A
    LD      ($7010), A
    CP      40H
    JR      NZ, LOC_92C5
    LD      A, ($7011)
    INC     A
    LD      ($7011), A
    SUB     A
    LD      ($7010), A

LOC_92C5:                              
    PUSH    AF
    LD      HL, 9AE1H
    LD      A, ($7011)
    ADD     A, L
    JR      NC, LOC_92D0
    INC     H

LOC_92D0:                              
    LD      L, A
    POP     AF
    AND     (HL)
    JR      Z, LOC_92F6
    CALL    SUB_93E7
    LD      HL, 703FH
    LD      (HL), A
    INC     HL
    LD      C, A
    LD      B, 19H

LOC_92E0:                              
    PUSH    HL
    CALL    SUB_93E7
    CALL    SUB_93FD
    CP      C
    JR      NZ, LOC_92EF
    INC     A
    CP      (HL)
    JR      NZ, LOC_92EF
    SUB     A

LOC_92EF:                              
    POP     HL
    LD      (HL), A
    INC     HL
    DJNZ    LOC_92E0
    JR      LOC_92A9

LOC_92F6:                              
    LD      B, 1AH

LOC_92F8:                              
    PUSH    BC
    LD      A, B
    DEC     A
    CALL    SUB_8D99
    POP     BC
    DJNZ    LOC_92F8
    LD      A, ($7011)
    CP      3
    JP      NZ, LOC_92A9
    LD      A, ($7014)
    CP      4
    JR      C, LOC_9314
    LD      A, 6
    JR      LOC_931B

LOC_9314:                              
    LD      A, ($7034)
    AND     3
    SLA     A

LOC_931B:                              
    LD      HL, 9B7CH
    ADD     A, L
    LD      L, A
    LD      E, (HL)
    INC     HL
    LD      D, (HL)

LOC_9323:                              
    LD      A, (DE)
    AND     A
    JR      Z, LOC_9331
    RST     38H
    LD      A, ($703F)
    OR      0C0H
    LD      (HL), A
    INC     DE
    JR      LOC_9323

LOC_9331:                              
    LD      A, ($7014)
    CP      4
    JP      Z, LOC_9387
    LD      A, ($7034)
    AND     3
    JP      NZ, LOC_9387
    LD      B, 0CH

LOC_9343:                              
    PUSH    BC
    LD      A, 0CH
    SUB     B
    ADD     A, A
    LD      HL, BYTE_95EC
    RST     20H
    SUB     A
    LD      ($7010), A

LOC_9350:                              
    CALL    SUB_8E58
    SUB     A
    LD      HL, $702B
    LD      B, 9

LOC_9359:                              
    LD      (HL), A
    INC     HL
    DJNZ    LOC_9359
    LD      A, ($7010)
    INC     A
    LD      ($7010), A
    LD      C, A
    LD      B, 5
    PUSH    DE

LOC_9368:                              
    LD      A, (DE)
    PUSH    BC
    PUSH    DE
    BIT     2, C
    JR      NZ, LOC_9374
    CALL    SUB_8DCB
    JR      LOC_9377

LOC_9374:                              
    CALL    SUB_8D99

LOC_9377:                              
    POP     DE
    POP     BC
    INC     DE
    DJNZ    LOC_9368
    POP     DE
    LD      A, ($7010)
    CP      1FH
    JR      NZ, LOC_9350
    POP     BC
    DJNZ    LOC_9343

LOC_9387:                              
    LD      A, ($703F)
    LD      C, A
    LD      HL, $7040
    LD      B, 19H

LOC_9390:                              
    LD      A, (HL)
    AND     3FH
    CP      C
    JR      NZ, LOC_93BC
    PUSH    HL
    PUSH    AF
    LD      A, ($7014)
    AND     0FH
    CP      4
    JR      NZ, LOC_93A6
    POP     AF
    OR      0C0H
    JR      LOC_93AB

LOC_93A6:                              
    CALL    SUB_9D76
    POP     AF
    OR      (HL)

LOC_93AB:                              
    POP     HL
    LD      (HL), A
    PUSH    BC
    PUSH    HL
    LD      A, 19H
    SUB     B
    CALL    SUB_A22A
    POP     HL
    POP     BC
    LD      A, 60H
    LD      ($71D6), A

LOC_93BC:                              
    INC     HL
    DJNZ    LOC_9390

LOC_93BF:                              
    CALL    SUB_8E58
    CALL    SUB_9F15
    LD      A, ($71D6)
    AND     A
    JR      NZ, LOC_93BF
RET

SUB_93CC:                              
    PUSH    HL
    LD      A, ($7010)
    LD      L, A
    LD      A, ($7013)
    AND     1FH
    LD      H, A
    LD      A, R
    XOR     (HL)
    XOR     L
    LD      ($7012), A
    LD      L, A
    LD      A, (DE)
    XOR     (HL)
    XOR     L
    LD      ($7013), A
    POP     HL
RET

SUB_93E7:                              
    CALL    SUB_93CC
    LD      HL, BYTE_9B93
    PUSH    AF
    LD      A, ($701B)
    AND     0FH
    RST     8
    POP     AF
    AND     (HL)
    INC     HL
    CP      (HL)
    JR      C, LOCRET_93FC
    SRL     A

LOCRET_93FC:                           
RET

SUB_93FD:                              
    PUSH    HL
    PUSH    AF
    LD      H, A
    LD      A, ($701B)
    AND     0FH
    CP      2
    JR      NZ, LOC_9423
    LD      A, C
    CP      6
    JR      C, LOC_9410
    SUB     6

LOC_9410:                              
    LD      L, A
    LD      A, H
    CP      6
    JR      C, LOC_9418
    SUB     6

LOC_9418:                              
    CP      L
    JR      NZ, LOC_9423
    INC     A
    CP      0CH
    JR      C, LOC_9421
    SUB     A

LOC_9421:                              
    POP     HL
    PUSH    AF

LOC_9423:                              
    POP     AF
    POP     HL
RET

SUB_9426:                              
    LD      A, ($7014)
    AND     A
    RET     NZ
    LD      DE, ($71DD)
    LD      A, E
    OR      D
    RET     NZ
    LD      B, 2

LOC_9434:                              
    LD      HL, $7159
    LD      A, B
    ADD     A, A
    RST     8
    LD      A, (HL)
    AND     A
    JP      Z, LOC_9545
    LD      A, B
    CP      4
    JP      Z, LOC_9545
    CP      2
    JR      NZ, LOC_944C
    LD      A, 4
    RST     8

LOC_944C:                              
    DEC     HL
    DEC     HL
    LD      A, ($7157)
    SUB     2
    LD      C, A
    LD      A, (HL)
    SUB     C
    CP      5
    JP      NC, LOC_9545
    DEC     HL
    LD      A, ($7156)
    SUB     2
    LD      C, A
    LD      A, (HL)
    SUB     C
    CP      5
    JP      NC, LOC_9545
    LD      A, B
    LD      HL, $7136
    RST     8
    LD      A, (HL)
    CP      0E8H
    JP      Z, LOC_9545
    CP      78H
    JP      Z, LOC_9545
    INC     HL
    LD      A, (HL)
    CP      0F0H
    JP      Z, LOC_9545
    CP      50H
    JP      Z, LOC_9545
    LD      A, (HL)
    AND     0FH
    JR      NZ, LOC_9490
    LD      A, ($7137)
    CP      (HL)
    JR      Z, LOC_949E

LOC_9490:                              
    DEC     HL
    LD      A, (HL)
    AND     7
    JP      NZ, LOC_9545
    LD      A, ($7136)
    CP      (HL)
    JP      NZ, LOC_9545

LOC_949E:                              
    LD      A, B
    SRL     A
    LD      HL, $7106
    RST     8
    LD      A, (HL)
    AND     7
    SUB     3
    CP      3
    JP      NC, LOC_9525
    PUSH    BC
    CP      2
    JR      NZ, LOC_94C8
    LD      A, ($7034)
    SRL     A
    AND     7EH
    LD      HL, BYTE_9604
    RST     20H
    LD      ($71DD), DE
    LD      A, 0AH
    RST     18H
    JR      LOC_94EB

LOC_94C8:                              
    EX      DE, HL
    LD      HL, $71DF

LOC_94CC:                              
    LD      A, (HL)
    CP      2
    JR      NZ, LOC_94D7
    LD      A, (DE)
    AND     7
    LD      (HL), A
    JR      LOC_94DA

LOC_94D7:                              
    INC     HL
    JR      LOC_94CC

LOC_94DA:                              
    POP     BC
    PUSH    BC
    LD      A, B
    SRL     A
    SUB     4
    LD      HL, $70E7
    RST     8
    LD      A, (HL)
    LD      B, 1
    CALL    SUB_9D43

LOC_94EB:                              
    LD      DE, 100H
    CALL    ADD_SOME_SCORE
    POP     BC
    LD      A, B
    SRL     A
    LD      HL, $7116
    RST     8
    PUSH    HL
    POP     IY
    SUB     A
    LD      (IY-20H), A
    LD      (IY+0), A
    LD      (IY+10H), A
    LD      A, B
    LD      HL, 7136H
    RST     8
    SUB     A
    LD      (HL), A
    INC     HL
    LD      (HL), A
    LD      A, B
    ADD     A, A
    LD      HL, $7156
    RST     8
    SUB     A
    LD      (HL), A
    INC     HL
    INC     HL
    INC     HL
    LD      (HL), A
    LD      A, 3DH
    RST     8
    SUB     A
    LD      (HL), A
    INC     HL
    INC     HL
    INC     HL
    LD      (HL), A
RET

LOC_9525:                              
    LD      A, (HL)
    LD      C, 0CH
    AND     7
    CP      6
    JR      NZ, LOC_9530
    LD      C, 0BH

LOC_9530:                              
    LD      A, C
    PUSH    BC
    RST     18H
    POP     BC
    LD      A, 1
    LD      ($7010), A
    LD      A, 2
    LD      ($7014), A
    LD      A, B
    CALL    SUB_954F
    JP      LOC_8F83

LOC_9545:                              
    LD      A, 2
    ADD     A, B
    LD      B, A
    CP      1EH
    JP      C, LOC_9434
RET

SUB_954F:                              
    LD      HL, $7196
    LD      DE, $7300
    LD      BC, 4
    LDIR
    LD      BC, 4
    CP      2
    JR      NZ, LOC_9564
    LD      BC, 8

LOC_9564:                              
    ADD     A, A
    PUSH    AF
    LD      HL, $7156
    RST     8
    PUSH    HL
    LD      DE, $7304
    LDIR
    POP     HL
    LD      A, 40H
    RST     8
    LD      BC, 4
    LDIR
    LD      HL, BYTE_95BF
    LD      DE, $715E
    LD      BC, 2DH
    LDIR
    LD      HL, $7300
    LD      DE, $715A
    LD      BC, 0CH
    POP     AF
    CP      4
    JR      NZ, LOC_9595
    LD      BC, 10H

LOC_9595:                              
    LDIR
    LD      A, ($7156)
    SUB     20H
    LD      E, A
    LD      A, ($7157)
    SUB     8
    LD      D, A
    LD      HL, $716A
    LD      B, 8

LOC_95A8:                              
    LD      A, E
    ADD     A, (HL)
    LD      (HL), A
    INC     HL
    LD      A, D
    ADD     A, (HL)
    LD      (HL), A
    INC     HL
    INC     HL
    INC     HL
    DJNZ    LOC_95A8
    LD      HL, PATTERNS_04
    LD      DE, 3BE0H
    LD      BC, 100H
    RST     10H
RET

BYTE_95BF:
	DB  00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H,0CFH, 00H, 00H, 00H, 00H, 00H, 7CH, 0FH, 00H, 10H, 80H, 0FH, 10H, 00H, 84H, 0FH, 10H, 10H, 88H, 0FH, 00H, 00H
    DB  8CH, 01H, 00H, 10H, 90H, 01H, 10H, 00H, 94H, 01H, 10H, 10H, 98H, 01H,0D0H
BYTE_95EC:
	DB  30H, 80H, 5DH, 80H, 44H, 80H, 49H, 80H, 35H, 80H, 58H, 80H, 3FH, 80H, 53H, 80H, 3AH, 80H, 4EH, 80H, 67H, 80H, 62H, 80H
BYTE_9604:
	DB  2CH, 01H, 2CH, 01H, 68H, 01H, 68H, 01H,0A4H, 01H,0A4H, 01H, 2CH, 01H, 2CH, 01H, 2CH, 01H

SUB_9616:                              
    LD      HL, $7300

LOC_9619:                              
    LD      A, (HL)
    SUB     30H
    RET     NZ
    LD      (HL), A
    INC     HL
    DJNZ    LOC_9619
RET

START:                                 
    LD      SP, $73C0
    CALL    TURN_OFF_SOUND
    SUB     A
    LD      HL, 1800H
    LD      DE, 800H
    CALL    FILL_VRAM

LOC_9632:                              
    SUB     A
    LD      ($700D), A
    CALL    GAME_OPT
    LD      HL, WELCOME_TXT
    LD      DE, 1806H
    LD      BC, 14H
    RST     10H
    LD      HL, PARKER_BROS_TXT
    LD      DE, 1AE5H
    LD      BC, 16H
    RST     10H

LOC_964D:                              
    SUB     A
    LD      ($701C), A
    CALL    SUB_8E34
    JR      Z, LOC_964D
    LD      A, L
    CP      9
    JR      NC, LOC_964D
    DEC     L
    BIT     2, L
    JR      Z, LOC_9665
    LD      A, 0C0H
    LD      ($700D), A

LOC_9665:                              
    LD      A, L
    AND     3
    ADD     A, A
    ADD     A, A
    LD      ($700F), A
    LD      A, 4
    LD      ($700E), A
    CALL    BLANK_THE_SCREEN
    LD      B, 8
    LD      DE, 100H

LOC_967A:                              
    PUSH    BC
    PUSH    DE
    LD      BC, 60H
    LD      HL, $7300
    PUSH    HL
    PUSH    DE
    PUSH    BC
    CALL    READ_VRAM
    POP     BC
    POP     DE
    POP     HL
    SET     5, D
    CALL    SUB_8EF7
    POP     DE
    LD      HL, 60H
    ADD     HL, DE
    EX      DE, HL
    POP     BC
    DJNZ    LOC_967A

INIT_GAME:                             
    CALL    BLANK_THE_SCREEN
    LD      HL, ($700D)
    PUSH    HL
    LD      A, ($700F)
    PUSH    AF
    LD      HL, $7000
    LD      DE, $7001
    LD      BC, 3AFH
    SUB     A
    LD      ($7000), A
    LDIR
    POP     AF
    LD      ($700F), A
    LD      ($7034), A
    LD      ($708B), A
    POP     HL
    LD      ($700D), HL
    LD      A, ($700D)
    LD      ($701C), A
    LD      A, ($700E)
    LD      ($7035), A
    LD      ($708C), A
    LD      HL, $71E8
    LD      ($7022), HL
    LD      DE, 8
    ADD     HL, DE
    LD      ($7024), HL
    ADD     HL, DE
    LD      ($7026), HL
    ADD     HL, DE
    LD      ($7028), HL
    LD      HL, 2000H
    LD      DE, 8
    LD      A, 0
    CALL    SUB_9E43
    LD      DE, 2008H
    LD      HL, PATTERNS_03
    LD      BC, 0D0H
    CALL    SUB_8EF7
    LD      A, 0F0H
    LD      HL, 0
    LD      DE, 400H
    CALL    SUB_9E43
    LD      DE, 2418H
    LD      HL, BYTE_806C
    LD      B, 9

LOC_970F:                              
    PUSH    BC
    CALL    SUB_8EAA
    PUSH    HL
    CALL    SUB_8EC1
    POP     HL
    POP     BC
    DJNZ    LOC_970F
    LD      HL, BYTE_807C
    LD      DE, $7300
    LD      BC, 8
    LDIR
    CALL    SUB_8EDD
    LD      A, 80H
    LD      DE, 8
    LD      HL, 8
    CALL    FILL_VRAM
    LD      HL, $7300
    LD      DE, BYTE_8604
    LD      C, 6

LOC_973C:                              
    LD      B, 8
    LD      A, (DE)

LOC_973F:                              
    LD      (HL), A
    INC     HL
    DJNZ    LOC_973F
    INC     DE
    DEC     C
    JR      NZ, LOC_973C
    LD      DE, 418H
    CALL    SUB_8EF2
    LD      A, 20H
    LD      DE, 48H
    LD      HL, 3D0H
    CALL    SUB_9E43
    LD      HL, BYTE_9DEF
    LD      DE, 23D0H
    LD      BC, 48H
    CALL    SUB_8EF7
    LD      A, R
    LD      ($7012), A
    LD      HL, START
    RST     8
    LD      A, (HL)
    LD      ($7013), A

LOC_9771:                              
    CALL    SUB_A8C8
    LD      A, 3
    RST     18H
    RST     30H
    ADD     A, A
    LD      HL, BYTE_9BC0
    RST     20H
    LD      (BONUS_TIME_RAM), DE

LOC_9781:                              
    SUB     A
    LD      ($7014), A

LOC_9785:                              
    CALL    SUB_AB06
    LD      A, 1
    LD      ($7126), A
    CALL    SUB_9E37
    CALL    SUB_9C54
    CALL    SUB_99C4
    LD      IY, $7116
    LD      IX, $7156
    RST     28H
    CALL    SUB_9BD2
    CALL    SUB_8E8C
    CALL    SUB_928F
    CALL    SUB_AB11
    LD      DE, 1E00H
    LD      HL, $7156
    LD      BC, 80H
    RST     10H
    CALL    SUB_9B9B
    LD      A, 7
    LD      ($701A), A
    LD      HL, BYTE_9B76
    CALL    SUB_9AC7
    CALL    SUB_9AF1
    CALL    SUB_9C62
    CALL    TURN_OFF_SOUND

LEADS_TO_SCORING:                      
    CALL    SUB_8E58
    SUB     A
    LD      ($7209), A
    CALL    SUB_AC51
    CALL    SUB_93CC
    CALL    SUB_9E94
    CALL    SUB_A307
    CALL    SUB_A39B
    CALL    SUB_8F57
    CALL    SUB_9426
    CALL    SUB_9D7D
    JP      NZ, LOC_9891
    CALL    SUB_9DCF
    CALL    SUB_8F24
    LD      HL, $7300
    LD      DE, $7314
    LD      BC, 6
    LDIR
    CALL    SUB_AC5E
    CALL    SUB_9E37
    LD      B, 19H

LOOP_9807:                             
    LD      A, B
    CALL    SUB_A2D7
    JR      NZ, LOC_9813
    PUSH    BC
    LD      A, B
    CALL    SUB_8DED
    POP     BC

LOC_9813:                              
    DJNZ    LOOP_9807
    LD      HL, 100H
    LD      ($70E2), HL
    LD      B, 19H

SOME_SCORING_LOOP:                     
    PUSH    BC
    LD      A, 1AH
    SUB     B
    CALL    SUB_A2D7
    JR      NZ, LOC_9848
    LD      HL, ($70E2)
    CALL    SUB_A25C
    LD      A, 1AH
    SUB     B
    CALL    SUB_A2B7
    CALL    SUB_A28E
    CALL    SUB_8F24
    LD      HL, ($70E2)
    LD      A, 1
    ADD     A, H
    DAA
    LD      H, A
    LD      ($70E2), HL
    LD      B, 1EH
    CALL    SUB_9E85

LOC_9848:                              
    POP     BC
    DJNZ    SOME_SCORING_LOOP
    LD      HL, $7300
    LD      BC, 1A30H

LOOP_9851:                             
    LD      A, (HL)
    OR      C
    LD      (HL), A
    INC     HL
    DJNZ    LOOP_9851
    LD      HL, $7319
    LD      DE, $7305
    LD      B, 6

LOC_985F:                              
    LD      A, (DE)
    SUB     (HL)
    JR      NC, LOC_986A
    ADD     A, 0AH
    EX      DE, HL
    DEC     HL
    DEC     (HL)
    INC     HL
    EX      DE, HL

LOC_986A:                              
    OR      C
    LD      (HL), A
    DEC     HL
    DEC     DE
    DJNZ    LOC_985F
    CALL    SUB_9E71
    LD      HL, $7314
    LD      DE, $7300
    LD      BC, 6
    LDIR
    LD      B, 5
    CALL    SUB_9616
    CALL    SUB_9E57
    LD      B, 0F0H
    CALL    SUB_9E85
    CALL    SUB_99C4
    JP      LOC_9771

LOC_9891:                              
    LD      A, ($701A)
    BIT     2, A
    JR      NZ, LOC_98A2
    BIT     0, A
    JR      NZ, LOC_98A7
    BIT     1, A
    JR      NZ, LOC_98B1
    JR      LOC_98B9

LOC_98A2:                              
    CALL    SUB_9DCF
    JR      LOC_98B9

LOC_98A7:                              
    RES     0, A
    LD      ($701A), A
    CALL    SUB_8F24
    JR      LOC_98B9

LOC_98B1:                              
    RES     1, A
    LD      ($701A), A
    CALL    SUB_9B4B

LOC_98B9:                              
    LD      A, ($7014)
    AND     A
    JP      Z, LEADS_TO_SCORING
    CP      4
    JP      NC, LEADS_TO_SCORING
    CP      3
    JR      NZ, LOC_98DA
    LD      HL, 1
    CALL    DECODER
    LD      A, L
    CP      0AH
    JP      Z, INIT_GAME
    CP      0BH
    JP      Z, LOC_9632

LOC_98DA:                              
    LD      A, ($7010)
    AND     A
    JP      NZ, LEADS_TO_SCORING
    LD      A, ($7014)
    DEC     A
    JP      Z, LOC_9990
    DEC     A
    JR      Z, LOC_98F9
    LD      A, ($701C)
    BIT     7, A
    JP      Z, LEADS_TO_SCORING
    CALL    SUB_9CA0
    JP      LEADS_TO_SCORING

LOC_98F9:                              
    LD      A, ($7156)
    CP      0C0H
    JR      C, LOC_990B
    LD      DE, 0
    LD      BC, 1
    LD      HL, 7B1EH
    JR      LOC_991A

LOC_990B:                              
    LD      HL, ($7156)
    LD      DE, ($7136)
    LD      A, ($7116)
    LD      B, A
    LD      A, ($7126)
    LD      C, A

LOC_991A:                              
    PUSH    HL
    PUSH    DE
    PUSH    BC
    LD      HL, $70F6
    LD      (HL), 0
    LD      DE, $70F7
    LD      BC, 26AH
    LDIR
    CALL    SUB_AB11
    POP     BC
    POP     DE
    POP     HL
    LD      ($7156), HL
    LD      ($7196), HL
    LD      ($7136), DE
    LD      A, B
    LD      ($7116), A
    LD      A, C
    LD      ($7126), A
    CALL    SUB_9D3E
    LD      A, ($701C)
    BIT     7, A
    JP      Z, LOC_995F
    LD      A, ($708C)
    AND     A
    JP      Z, LOC_995F
    CALL    SUB_9CA0
    LD      A, ($701C)
    BIT     6, A
    JP      NZ, LOC_997C

LOC_995F:                              
    LD      A, ($7035)
    AND     A
    JP      Z, LOC_9C28
    DEC     A
    LD      ($7035), A
    LD      A, ($701A)
    OR      3
    LD      ($701A), A
    SUB     A
    LD      ($7014), A
    CALL    SUB_99CC
    JP      LEADS_TO_SCORING

LOC_997C:                              
    RES     6, A
    LD      ($701C), A
    LD      A, ($700E)
    LD      ($7035), A
    LD      A, ($700F)
    LD      ($7034), A
    JP      LOC_9771

LOC_9990:                              
    LD      A, ($7034)
    CP      23H
    JR      NZ, LOC_9999
    SUB     4

LOC_9999:                              
    INC     A
    LD      ($7034), A
    AND     3
    JP      NZ, LOC_99B5
    CALL    SUB_9E71
    CALL    SUB_9E57
    CALL    SUB_9E37
    LD      B, 78H
    CALL    SUB_9E85
    LD      A, 4
    LD      ($7014), A

LOC_99B5:                              
    CALL    SUB_99C4
    LD      A, ($7034)
    AND     3
    JP      NZ, LOC_9781
    SUB     A
    JP      LOC_9785

SUB_99C4:                              
    LD      A, 1
    LD      ($7126), A
    LD      ($70EC), A

SUB_99CC:                              
    LD      A, ($7034)
    LD      HL, BYTE_9A8D
    RST     8
    LD      A, (HL)
    LD      B, 8
    LD      HL, $71DF

LOC_99D9:                              
    LD      (HL), 2
    INC     HL
    DJNZ    LOC_99D9
    LD      HL, $71DF
    BIT     7, A
    JR      Z, LOC_99E8
    LD      B, 5
    LD      (HL), B

LOC_99E8:                              
    INC     HL
    AND     7
    JR      Z, LOC_9A00
    LD      B, A
    LD      A, ($7013)

LOC_99F1:                              
    AND     1
    ADD     A, 3
    LD      (HL), A
    INC     HL
    LD      A, ($7013)
    RRCA
    LD      ($7013), A
    DJNZ    LOC_99F1

LOC_9A00:                              
    LD      A, 5
    LD      ($7088), A
    LD      A, ($7034)
    LD      C, A
    LD      A, ($7014)
    CP      4
    JR      NZ, LOC_9A11
    DEC     C

LOC_9A11:                              
    LD      A, C
    LD      B, 0
    CP      4
    JR      C, LOC_9A26
    LD      B, 2
    CP      6
    JR      C, LOC_9A26
    SLA     B
    CP      8
    JR      C, LOC_9A26
    LD      B, 6

LOC_9A26:                              
    LD      A, B
    LD      ($701B), A
    LD      A, ($7034)
    LD      HL, BYTE_9A69
    RST     8
    LD      A, (HL)
    LD      ($7017), A
    LD      B, 0
    CP      30H
    JR      Z, LOC_9A46
    INC     B
    CP      2BH
    JR      Z, LOC_9A46
    INC     B
    CP      25H
    JR      Z, LOC_9A46
    INC     B

LOC_9A46:                              
    LD      A, B
    ADD     A, A
    LD      HL, OFF_9A61
    RST     20H
    LD      ($7018), DE
    RST     30H
    SLA     A
    LD      HL, BYTE_9AB5
    RST     20H
    LD      ($7015), DE
    LD      A, 0FFH
    LD      ($71D8), A
RET

OFF_9A61:
	DW BYTE_91AB          
    DW BYTE_91DB
    DW BYTE_9206
    DW BYTE_922B

BYTE_9A69:
	DB  30H, 30H, 30H, 30H, 30H, 30H, 30H, 30H, 30H, 30H, 30H, 30H, 2BH, 2BH, 2BH, 2BH, 2BH, 2BH, 25H, 25H, 25H, 25H, 20H, 20H, 20H, 20H, 20H, 20H, 25H, 25H
    DB  20H, 20H, 20H, 20H, 20H, 20H
BYTE_9A8D:
	DB  00H, 00H, 00H, 00H, 80H, 80H, 80H, 81H, 01H, 01H, 82H, 82H, 82H, 02H, 82H, 82H, 80H, 82H, 80H, 82H, 80H, 83H, 80H, 83H, 80H, 80H, 80H, 80H, 84H, 84H
    DB  84H, 84H, 80H, 80H, 80H, 80H, 84H, 84H, 84H, 84H
BYTE_9AB5:
	DB 0EFH, 01H,0D9H, 01H, 73H, 01H, 18H, 01H,0F0H, 00H,0DCH, 00H,0D2H, 00H,0B4H, 00H, 5AH, 00H

SUB_9AC7:                              
    LD      DE, 1884H
    LD      BC, 1
    RST     10H
    LD      DE, 18C6H
    LD      BC, 1
    RST     10H
    LD      DE, 1903H
    LD      BC, 1
    RST     10H
RET

BYTE_9ADD:
	DB  21H, 61H, 41H, 01H, 03H, 03H, 07H, 07H
    DB  0FH, 0FH, 1FH
GAME_OVER_TXT:
	DB 071,065,077,069,032,079,086,069,082

SUB_9AF1:                              
    LD      DE, 1899H
    LD      A, ($7014)
    CP      4
    JR      Z, LOC_9B2D
    LD      DE, $7300
    LD      HL, LEVEL_ROUND_TXT
    LD      BC, 0EH
    LDIR
    LD      A, ($7034)
    AND     3
    ADD     A, 31H
    LD      ($730D), A
    RST     30H
    ADD     A, 31H
    LD      ($7306), A
    LD      HL, $7300
    LD      DE, 18B8H
    LD      BC, 7
    RST     10H
    LD      HL, $7307
    LD      DE, 18D8H
    LD      BC, 7
    RST     10H
    LD      DE, 1A79H

LOC_9B2D:                              
    LD      HL, BONUS_TXT
    LD      BC, 5
    PUSH    DE
    RST     10H
    POP     HL
    LD      DE, 20H
    ADD     HL, DE
    EX      DE, HL
    LD      HL, TIME_TXT
    LD      BC, 4
    RST     10H
    LD      A, ($701A)
    SET     2, A
    LD      ($701A), A
RET

SUB_9B4B:                              
    SUB     A
    LD      DE, 7
    LD      HL, 1843H
    PUSH    HL
    CALL    FILL_VRAM
    POP     HL
    LD      A, ($7035)
    AND     A
    RET     Z
    CP      7
    JR      C, LOC_9B62
    LD      A, 7

LOC_9B62:                              
    LD      E, A
    LD      A, 1
    JP      FILL_VRAM

LEVEL_ROUND_TXT:
	DB 076,069,086,069,076,061,088,082,079,085,078,068,061,088
BYTE_9B76:
	DB  04H, 03H, 02H     
BYTE_9B79:
	DB  00H, 00H, 00H     
    DB  84H, 9BH, 8EH, 9BH, 8DH, 9BH, 8DH, 9BH, 01H, 03H, 05H, 0BH, 0DH, 0FH, 15H, 17H, 19H, 00H, 01H, 05H, 15H, 19H, 00H
BYTE_9B93:
	DB  03H, 03H, 07H, 0CH, 07H, 06H, 1FH, 18H

SUB_9B9B:                              
    LD      DE, 1803H
    LD      HL, PLAYER_TXT
    LD      BC, 6
    RST     10H
    LD      A, ($701C)
    AND     1
    ADD     A, 31H
    LD      HL, 180AH
    LD      DE, 1
    CALL    FILL_VRAM
RET

BLANK_SPACE:
    DB 032                
BONUS_TXT:
	DB 066,079,078,085,083
TIME_TXT:
	DB 084,073,077,069    
BYTE_9BC0:
	DB  50H, 00H, 50H, 00H, 00H, 01H, 60H, 01H, 20H, 02H, 80H, 02H, 40H, 03H, 00H, 04H, 60H, 04H

SUB_9BD2:                              
    LD      HL, BYTE_855E
    CALL    SUB_9250
    EX      DE, HL
    LD      B, 4
    LD      HL, 5C8H

LOC_9BDE:                              
    PUSH    BC
    LD      IX, $7300
    PUSH    HL
    LD      BC, 806H

LOC_9BE7:                              
    LD      HL, BYTE_80C4
    CALL    SUB_8DF2
    LD      A, 3
    CALL    SUB_8ED7
    DEC     C
    JR      NZ, LOC_9BE7
    LD      ($70E2), DE
    POP     DE
    LD      HL, $7300
    LD      BC, 30H
    CALL    SUB_8EF7
    LD      HL, 30H
    ADD     HL, DE
    LD      DE, ($70E2)
    POP     BC
    DJNZ    LOC_9BDE
RET

SUB_9C0F:                              
    LD      HL, $7034
    LD      DE, $708B
    LD      BC, 57H

LOC_9C18:                              
    LD      A, (HL)
    PUSH    AF
    LD      A, (DE)
    LD      (HL), A
    POP     AF
    EX      DE, HL
    LD      (HL), A
    EX      DE, HL
    INC     HL
    INC     DE
    DEC     BC
    LD      A, C
    OR      B
    JR      NZ, LOC_9C18
RET

LOC_9C28:                              
    LD      A, 3
    LD      ($7014), A
    LD      HL, $7196
    LD      DE, $715A
    LD      BC, 4
    LDIR
    LD      A, 0D0H
    LD      ($715E), A
    LD      HL, $7156
    LD      DE, 1E00H
    LD      BC, 9
    RST     10H
    LD      HL, GAME_OVER_TXT
    LD      DE, 182CH
    LD      BC, 9
    RST     10H
    JP      LEADS_TO_SCORING

SUB_9C54:                              
    LD      HL, $70E2
    LD      (HL), 0
    LD      DE, $70E3
    LD      BC, 27EH
    LDIR
RET

SUB_9C62:                              
    LD      B, 5
    LD      A, 0D3H
    LD      HL, $70F1
LOOP_9C69:                             
    LD      (HL), A
    ADD     A, 9
    INC     HL
    DJNZ    LOOP_9C69
RET

PLAYER_TXT:
	DB 080,076,065,089,069,082
WELCOME_TXT:
    DB 087,069,076,067,079,077,069,000,084,079,000,081,042,066,069,082,084,000,073,073
PARKER_BROS_TXT:
	DB 029,000,080,065,082,075,069,082,000,066,082,079,084,072,069,082,083,000,049,057,056,052

SUB_9CA0:                              
    CALL    BLANK_THE_SCREEN
    LD      B, 5
    CALL    SUB_9E85
    LD      HL, 64H
    LD      A, ($701C)
    XOR     1
    LD      ($701C), A
    LD      A, ($7116)
    LD      ($7076), A
    LD      A, ($70CD)
    LD      ($7116), A
    LD      A, ($7126)
    LD      ($7077), A
    LD      A, ($70CE)
    LD      ($7126), A
    LD      HL, ($7136)
    LD      ($7078), HL
    LD      HL, ($70CF)
    LD      ($7136), HL
    LD      HL, ($7156)
    LD      DE, ($70D1)
    LD      ($7156), DE
    LD      ($7196), DE
    LD      ($707A), HL
    CALL    SUB_9C0F
    CALL    SUB_99CC
    LD      IY, $7116
    LD      IX, $7156
    RST     28H
    CALL    SUB_9BD2
    LD      A, ($703F)
    AND     3FH
    LD      C, A
    LD      HL, $7040
    LD      B, 19H

LOC_9D06:                              
    LD      A, (HL)
    AND     3FH
    CP      C
    JR      NZ, LOC_9D15
    LD      A, 8
    LD      ($71D6), A
    LD      A, (HL)
    OR      40H
    LD      (HL), A

LOC_9D15:                              
    INC     HL
    DJNZ    LOC_9D06
    LD      B, 1AH

LOC_9D1A:                              
    LD      A, B
    DEC     A
    PUSH    BC
    CALL    SUB_8D99
    POP     BC
    DJNZ    LOC_9D1A
    CALL    SUB_9B9B
    CALL    SUB_8F24
    LD      HL, BYTE_9B76
    CALL    SUB_9AC7
    CALL    SUB_9AF1
    CALL    SUB_9B4B
    LD      A, ($701C)
    BIT     6, A
    RET     NZ
    JP      SUB_8E8C

SUB_9D3E:                              
    LD      B, 5
    LD      HL, $70E7

SUB_9D43:                              
    LD      A, (HL)
    AND     A
    JR      Z, LOC_9D6D
    LD      (HL), 0
    PUSH    BC
    PUSH    HL
    LD      A, 5
    RST     8
    LD      A, (HL)
    EX      DE, HL
    CALL    SUB_A2D7
    JR      NZ, LOC_9D65
    PUSH    HL
    CALL    SUB_9D76
    POP     HL
    OR      (HL)
    SET     6, A
    LD      (HL), A
    LD      A, (DE)
    DEC     A
    PUSH    DE
    CALL    SUB_A22A
    POP     DE

LOC_9D65:                              
    LD      A, (DE)
    AND     3FH
    CALL    SUB_8D99
    POP     HL
    POP     BC

LOC_9D6D:                              
    INC     HL
    DJNZ    SUB_9D43
    LD      A, 8
    LD      ($71D6), A
RET

SUB_9D76:                              
    LD      HL, LOC_A216
    RST     30H
    RST     8
    LD      A, (HL)
RET

SUB_9D7D:                              
    LD      A, ($7014)
    AND     A
    JR      Z, LOC_9D86
    CP      4
    RET     NZ

LOC_9D86:                              
    LD      A, ($7208)
    INC     A
    LD      ($7208), A
    CP      3CH
    RET     NZ
    SUB     A
    LD      ($7208), A
    LD      A, ($701A)
    SET     2, A
    LD      ($701A), A
    LD      A, ($7014)
    AND     A
    JR      NZ, MORE_SCORING
    RST     30H
    LD      HL, BYTE_9E8B
    RST     8
    LD      E, (HL)
    LD      D, 0
    LD      HL, (BONUS_TIME_RAM)
    AND     A
    SBC     HL, DE
    JR      NZ, MORE_SCORING
    INC     D
RET

MORE_SCORING:                          
    LD      HL, (BONUS_TIME_RAM)
    LD      A, L
    SUB     1
    LD      L, A
    DAA
    CP      99H
    LD      L, A
    JR      NZ, LOC_9DC9
    LD      A, H
    AND     A
    JR      Z, LOC_9DC9
    SUB     1
    DAA
    LD      H, A

LOC_9DC9:                              
    LD      (BONUS_TIME_RAM), HL
    LD      A, L
    OR      H
RET

SUB_9DCF:                              
    RES     2, A
    LD      ($701A), A
    LD      HL, (BONUS_TIME_RAM)
    CALL    SUB_A25C
    LD      HL, $7300
    LD      DE, 18D9H
    LD      A, ($7014)
    CP      4
    JR      NC, LOC_9DEA
    LD      DE, 1AB9H

LOC_9DEA:                              
    LD      BC, 4
    RST     10H
RET

BYTE_9DEF:
	DB  00H, 00H, 00H, 01H, 03H, 06H, 0CH, 18H, 00H, 00H, 00H,0FFH, 00H, 00H, 00H, 01H, 00H, 00H, 00H,0F8H, 38H, 78H,0D8H, 98H, 3FH, 30H, 30H, 30H, 30H, 30H
    DB  30H, 30H,0FFH, 03H, 03H, 03H, 03H, 03H, 03H, 03H, 18H, 18H, 18H, 18H, 18H, 18H, 18H, 18H, 30H, 30H, 30H, 30H, 30H, 3FH, 00H, 00H, 03H, 03H, 03H, 03H
    DB  03H,0FFH, 00H, 00H, 18H, 30H, 60H,0C0H, 80H, 00H, 00H, 00H

SUB_9E37:                              
    LD      HL, 1E00H
    LD      A, 0D0H
    LD      DE, 1
    JP      FILL_VRAM


; ********************************* NO LINK DEFINED YET
    RET

SUB_9E43:                              
    LD      B, 3

LOC_9E45:                              
    PUSH    AF
    CALL    SUB_9E51
    LD      A, 8
    ADD     A, H
    LD      H, A
    POP     AF
    DJNZ    LOC_9E45
RET

SUB_9E51:                              
    PUSH    DE
    CALL    FILL_VRAM
    POP     DE
RET

SUB_9E57:                              
    LD      DE, 1800H

LOC_9E5A:                              
    LD      HL, $7300
    LD      BC, 0CH
    RST     10H
    LD      HL, 0CH
    ADD     HL, DE
    EX      DE, HL
    LD      HL, 1AF4H
    AND     A
    SBC     HL, DE
    JR      NC, LOC_9E5A
    JP      SUB_8E8C

SUB_9E71:                              
    LD      HL, BLANK_SPACE
    LD      DE, $7300
    LD      BC, 6
    PUSH    BC
    PUSH    HL
    LDIR
    POP     HL
    POP     BC
    LDIR
    JP      BLANK_THE_SCREEN

SUB_9E85:                              
    CALL    SUB_8E58
    DJNZ    SUB_9E85
RET

BYTE_9E8B:
	DB  10H, 15H, 20H, 25H, 20H, 25H, 30H, 35H, 30H

SUB_9E94:                              
    LD      HL, $7010
    INC     (HL)
    LD      A, (HL)
    JR      NZ, LOC_9E9D
    INC     L
    INC     (HL)

LOC_9E9D:                              
    INC     A
    AND     7
    JR      NZ, LOC_9EB2
    LD      HL, BYTE_9B76
    LD      A, ($7010)
    BIT     3, A
    JR      NZ, LOC_9EAF
    LD      HL, BYTE_9B79

LOC_9EAF:                              
    CALL    SUB_9AC7

LOC_9EB2:                              
    SUB     A
    LD      ($71D9), A
    LD      HL, BYTE_8030
    LD      DE, $707E
    LD      B, 0AH
    LD      C, 1FH
    LD      A, ($7014)
    CP      6
    JR      NZ, LOC_9EC9
    LD      C, 0EH

LOC_9EC9:                              
    LD      A, (DE)
    CP      C
    CALL    Z, SUB_A1C9
    LD      A, 5
    RST     8
    INC     DE
    DJNZ    LOC_9EC9
    LD      DE, $7082
    LD      B, 5
    LD      C, 10H
    LD      A, ($7014)
    CP      6
    JR      NZ, LOC_9EE7
    DEC     DE
    LD      B, 3
    LD      C, 8

LOC_9EE7:                              
    LD      A, (DE)
    AND     C
    JR      Z, LOC_9EF3
    DEC     DE
    SRL     C
    DJNZ    LOC_9EE7
    CALL    SUB_A1C9

LOC_9EF3:                              
    LD      DE, $707E
    LD      A, 5
    RST     8
    LD      B, 5
    LD      C, 10H
    LD      A, ($7014)
    CP      6
    JR      NZ, LOOP_9F09
    INC     DE
    LD      B, 3
    LD      C, 8

LOOP_9F09:                             
    LD      A, (DE)
    AND     C
    JR      Z, SUB_9F15
    INC     DE
    SRL     C
    DJNZ    LOOP_9F09
    CALL    SUB_A1C9

SUB_9F15:                              
    LD      A, ($71D6)
    AND     A
    JR      Z, LOC_9F79
    DEC     A
    LD      ($71D6), A
    JR      Z, LOC_9F56
    LD      C, A
    AND     7
    SUB     2
    JR      C, LOC_9F79
    INC     A
    LD      HL, $703B
    LD      DE, 5

LOC_9F2F:                              
    ADD     HL, DE
    DEC     A
    JR      NZ, LOC_9F2F
    LD      B, 5

LOOP_9F35:                             
    BIT     6, (HL)
    JR      Z, LOC_9F76
    PUSH    HL
    PUSH    BC
    LD      DE, $703F
    AND     A
    SBC     HL, DE
    LD      A, L
    LD      HL, $702B
    LD      B, 9
    BIT     3, C
    JR      NZ, LOOP_9F6C
    LD      DE, BYTE_9F63
    LD      BC, 9
    EX      DE, HL
    LDIR
    JR      LOC_9F71

LOC_9F56:                              
    LD      HL, $7040
    LD      B, 19H

LOOP_9F5B:                             
    RES     6, (HL)
    INC     HL
    DJNZ    LOOP_9F5B
    JP      LOC_9F79
BYTE_9F63:
	DB  7AH, 7BH, 7CH, 7DH, 7EH, 7FH, 80H, 81H, 82H

LOOP_9F6C:                             
    LD      (HL), 0
    INC     HL
    DJNZ    LOOP_9F6C

LOC_9F71:                              
    CALL    SUB_8DCB
    POP     BC
    POP     HL

LOC_9F76:                              
    INC     HL
    DJNZ    LOOP_9F35

LOC_9F79:                              
    LD      A, ($7014)
    AND     A
    JR      Z, LOC_9F99
    CP      4
	RET     C
    LD      HL, $707E
    LD      A, 1FH
    LD      B, 0AH

LOOP_9F89:                             
    CP      (HL)
    JP      NZ, LOC_9FFB
    INC     HL
    DJNZ    LOOP_9F89
    LD      HL, 1
    LD      (BONUS_TIME_RAM), HL
    JP      LOC_9FFB

LOC_9F99:                              
    LD      A, ($7034)
    SRL     A
    SRL     A
    LD      HL, BYTE_A20C
    RST     8
    LD      A, ($71D9)
    CP      (HL)
    JP      C, LOC_9FFB
    CALL    SUB_9E37
    LD      HL, 200H
    LD      ($70E2), HL
    LD      A, ($7034)
    CP      4
    JR      C, LOC_9FC4
    SUB     3
    LD      B, A
    LD      DE, 25H
    CALL    MORE_SCORING_02

LOC_9FC4:                              
    CALL    SUB_A25C
    CALL    BLANK_THE_SCREEN
    LD      B, 19H

LOOP_9FCC:                             
    LD      A, B
    CALL    SUB_A2D7
    JR      NZ, LOC_9FD9
    LD      A, B
    CALL    SUB_A2B7
    CALL    SUB_A28E

LOC_9FD9:                              
    DJNZ    LOOP_9FCC
    CALL    SUB_8E8C
    LD      A, ($701A)
    SET     2, A
    SET     0, A
    SET     1, A
    LD      ($701A), A
    LD      A, 87H
    LD      ($7010), A
    LD      A, 1
    LD      ($7014), A
    CALL    SUB_8F24
    LD      A, 0DH
    RST     18H
RET

LOC_9FFB:                              
    LD      B, 5
    LD      IY, $70E7

LOC_A001:                              
    PUSH    BC
    LD      A, (IY+0)
    LD      ($70E4), A
    LD      A, (IY+5)
    LD      ($70E5), A
    LD      A, (IY+0AH)
    LD      ($70E6), A
    CALL    SUB_A034
    LD      A, ($70E4)
    LD      (IY+0), A
    LD      A, ($70E5)
    LD      (IY+5), A
    POP     BC
    INC     IY
    DJNZ    LOC_A001
RET

LOC_A029:                              
    LD      A, ($70E4)
    ADD     A, 20H
    LD      ($70E4), A
    JP      LOC_A0AC

SUB_A034:                              
    LD      A, ($70E4)
    AND     A
    RET     Z
    INC     A
    LD      ($70E4), A
    AND     7
    CP      6
    RET     NZ
    LD      A, ($70E5)
    LD      HL, $703F
    RST     8
    LD      A, (HL)
    SLA     A
    JR      C, LOC_A029
    LD      A, ($70E4)
    ADD     A, 2
    LD      ($70E4), A
    AND     1FH
    JP      NZ, LOC_A0C6
    LD      A, ($70E4)
    AND     60H
    JR      NZ, LOC_A06F
    LD      A, 60H
    LD      ($70E4), A
    CALL    SUB_A197
    LD      A, 0
    LD      ($70E4), A

LOC_A06F:                              
    LD      A, ($70E5)
    CALL    SUB_8D99
    LD      A, ($703F)
    LD      B, A
    LD      A, ($70E5)
    CALL    SUB_A2D7
    JR      NZ, LOC_A0AC
    PUSH    HL
    PUSH    AF
    LD      HL, LOC_A216
    LD      A, ($7014)
    CP      4
    JR      Z, LOC_A090
    CALL    SUB_9D76

LOC_A090:                              
    POP     AF
    OR      (HL)
    POP     HL
    LD      (HL), A
    LD      A, 30H
    LD      ($71D6), A
    LD      A, ($70E5)
    DEC     A
    CALL    SUB_A22A
    LD      A, ($7014)
    AND     A
    JR      NZ, LOC_A0AC
    LD      DE, 100H
    CALL    ADD_SOME_SCORE

LOC_A0AC:                              
    LD      A, ($70E4)
    RLCA
    RLCA
    RLCA
    AND     3
    LD      HL, BYTE_A16D
    RST     8
    LD      A, ($70E5)
    ADD     A, (HL)
    LD      (IY+5), A
    SUB     A
    LD      (IY+0), A
    POP     AF
    POP     BC
RET

LOC_A0C6:                              
    LD      A, ($70E4)
    LD      B, A
    AND     60H
    RLCA
    RLCA
    RLCA
    LD      HL, BYTE_A193
    RST     8
    LD      C, (HL)
    LD      A, B
    AND     18H
    CP      C
    CALL    Z, SUB_A197
    LD      A, ($70E5)
    CALL    SUB_A200
    PUSH    HL
    LD      A, ($70E4)
    AND     78H
    SRL     A
    SRL     A
    LD      HL, BYTE_A171
    RST     20H
    EX      DE, HL
    PUSH    HL
    LD      A, ($70E6)
    LD      D, 0
    LD      E, A
    SLA     E
    RL      D
    SLA     E
    RL      D
    SLA     E
    RL      D
    LD      ($70E2), DE
    LD      A, 20H
    ADD     A, D
    LD      D, A
    CALL    SUB_A147
    POP     HL
    LD      A, 48H
    RST     8
    POP     DE
    LD      IX, $7300
    LD      B, 48H
    CALL    SUB_8DF2
    LD      DE, ($70E2)
    LD      HL, $7300
    CALL    SUB_A147
    POP     AF
    POP     BC
    LD      A, ($70E5)
    LD      (IY+5), A
    LD      A, ($70E4)
    LD      (IY+0), A
    LD      A, ($70E6)
    LD      HL, $702B
    LD      B, 9

LOC_A13C:                              
    LD      (HL), A
    INC     HL
    INC     A
    DJNZ    LOC_A13C
    LD      A, ($70E5)
    JP      SUB_8DCB

SUB_A147:                              
    PUSH    HL
    LD      A, ($70E5)
    LD      HL, BYTE_8490
    RST     8
    LD      A, (HL)
    POP     HL
    PUSH    AF
    AND     7FH
    ADD     A, D
    LD      D, A
    LD      BC, 18H
    RST     10H
    LD      A, 18H
    CALL    SUB_8ED7
    LD      BC, 30H
    POP     AF
    SLA     A
    JR      NC, LOC_A16B
    LD      A, 8
    ADD     A, D
    LD      D, A

LOC_A16B:                              
    RST     10H
RET

BYTE_A16D:
	DB    5,0FFH,   1,0FBH
BYTE_A171:
	DB  6CH, 80H, 1CH, 82H, 8CH, 81H,0FCH, 80H, 6CH, 80H,0FCH, 80H, 8CH, 81H, 1CH, 82H, 6CH, 80H,0ACH, 82H, 3CH, 83H,0CCH, 83H, 6CH, 80H,0CCH, 83H, 3CH, 83H
    DB 0ACH, 82H, 6CH, 80H
BYTE_A193:
	DB  10H, 18H, 08H, 00H

SUB_A197:                              
    LD      A, ($70E5)
    RST     38H
    PUSH    HL
    ADD     A, A
    ADD     A, A
    LD      HL, BYTE_856E
    CALL    SUB_9250
    RST     8
    LD      A, ($70E4)
    AND     60H
    RLCA
    RLCA
    RLCA
    RST     8
    LD      A, (HL)
    POP     HL
    LD      (HL), A
RET

SUB_A1B2:                              
    LD      B, 0

LOC_A1B4:                              
    INC     B
    SUB     5
    JR      NC, LOC_A1B4
    DEC     B
    ADD     A, 5
    LD      C, A
    LD      HL, BYTE_A1F6
    RST     8
    LD      E, (HL)
    LD      HL, BYTE_A1F6
    LD      A, B
    RST     8
    LD      D, (HL)
RET

SUB_A1C9:                              
    PUSH    BC
    PUSH    DE
    PUSH    HL
    LD      A, ($71D9)
    INC     A
    LD      ($71D9), A
    LD      B, 5
    LD      A, ($7014)
    CP      6
    JR      NZ, LOC_A1DF
    INC     HL
    LD      B, 3

LOC_A1DF:                              
    EX      DE, HL

LOC_A1E0:                              
    LD      A, (DE)
    INC     DE
    RST     38H
    SET     6, (HL)
    DJNZ    LOC_A1E0
    LD      A, ($71D6)
    AND     A
    JR      NZ, LOC_A1F2
    LD      A, 11H
    LD      ($71D6), A

LOC_A1F2:                              
    POP     HL
    POP     DE
    POP     BC
RET

BYTE_A1F6:
	DB  01H, 02H, 04H, 08H, 10H, 01H, 02H, 04H, 08H, 10H

SUB_A200:                              
    RST     38H
    LD      B, A
    ADD     A, A
    ADD     A, B
    LD      HL, BYTE_855E
    CALL    SUB_9250
    RST     8
RET

BYTE_A20C:
	DB  01H, 01H, 02H, 03H, 01H, 02H, 03H, 04H, 04H, 05H

LOC_A216:                              
    RET     NZ
    RET     NZ
    RET     NZ
    RET     NZ
    LD      B, B
    LD      B, B
    LD      B, B
    RET     NZ
    RET     NZ
    SUB     A

LOC_A220:                              
    AND     A
    SBC     HL, DE
    JR      C, LOC_A228
    INC     A
    JR      LOC_A220

LOC_A228:                              
    ADD     HL, DE
RET

SUB_A22A:                              
    CALL    SUB_A1B2
    LD      HL, $707E
    LD      A, B
    RST     8
    LD      A, (HL)
    OR      E
    LD      (HL), A
    LD      HL, $7083
    LD      A, C
    RST     8
    LD      A, (HL)
    OR      D
    LD      (HL), A
RET

; ********************************* NO LINK DEFINED YET
    DB    7
    DB  0DH
    DB  13H
    DB    9
    DB  0DH
    DB  11H
    DB    6
    DB    3
    DB  1AH
    DB 0FFH
    DB 0C0H
    DB  10H
    DB 0FBH
    DB 0C3H
    DB 0C9H
    DB 0A1H

MORE_SCORING_02:                       
    LD      A, L
    ADD     A, E
    DAA
    LD      L, A
    LD      A, H
    ADC     A, D
    DAA
    LD      H, A
    DJNZ    MORE_SCORING_02
    LD      ($70E2), HL
RET

SUB_A25C:                              
    PUSH    HL
    LD      IX, $7300
    LD      A, H
    CALL    SUB_A2E8
    LD      (IX+0), A
    INC     IX
    LD      A, H
    AND     0FH
    OR      30H
    LD      (IX+0), A
    INC     IX
    LD      A, L
    CALL    SUB_A2E8
    LD      (IX+0), A
    INC     IX
    LD      A, L
    AND     0FH
    OR      30H
    LD      (IX+0), A
    PUSH    BC
    LD      B, 3
    CALL    SUB_9616
    POP     BC
    POP     HL
RET

SUB_A28E:                              
    LD      DE, ($70E2)

ADD_SOME_SCORE:                        
    PUSH    BC
    LD      HL, (SCORING_RAM)
    LD      A, E
    ADD     A, L
    DAA
    LD      L, A
    LD      A, D
    ADC     A, H
    DAA
    LD      H, A
    LD      (SCORING_RAM), HL
    CALL    C, SUB_8F0D
    LD      A, ($7073)
    ADC     A, 0
    DAA
    LD      ($7073), A
    LD      A, ($701A)
    SET     0, A
    LD      ($701A), A
    POP     BC
RET

SUB_A2B7:                              
    PUSH    BC
    ADD     A, A
    LD      HL, BYTE_845C
    RST     20H
    EX      DE, HL
    LD      DE, 21H
    AND     A
    SBC     HL, DE
    EX      DE, HL
    LD      HL, $7300
    LD      BC, 4
    LD      A, (HL)
    AND     A
    JR      NZ, LOC_A2D2
    INC     DE
    INC     HL
    DEC     BC

LOC_A2D2:                              
    CALL    RST_10_WRITE_VRAM
    POP     BC
RET

SUB_A2D7:                              
    PUSH    BC
    RST     38H
    CALL    SUB_A2F3
    LD      B, A
    LD      A, ($703F)
    AND     3FH
    CALL    SUB_A2F3
    CP      B
    POP     BC
RET

SUB_A2E8:                              
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    OR      30H
RET

SUB_A2F3:                              
    PUSH    BC
    LD      C, A
    LD      A, ($701B)
    AND     7
    CP      2
    JR      NZ, LOC_A304
    LD      A, C
    SUB     6
    JR      C, LOC_A304
    LD      C, A

LOC_A304:                              
    LD      A, C
    POP     BC
RET

SUB_A307:                              
    LD      A, ($7014)
    AND     A
    JR      Z, LOC_A318
    CP      4
	RET     C
    LD      A, ($7014)
    CP      5
	NOP
	NOP
	NOP

LOC_A318:                              
    LD      A, ($7116)
    AND     3FH
    RET     NZ
    CALL    CONTROLLER_SCAN
    LD      HL, $73EE
    LD      A, ($701C)
    AND     1
    RST     8
    LD      B, 0
    BIT     1, (HL)
    JR      NZ, LOC_A33E
    INC     B
    BIT     2, (HL)
    JR      NZ, LOC_A33E
    INC     B
    BIT     0, (HL)
    JR      NZ, LOC_A33E
    BIT     3, (HL)
    RET     Z
    INC     B

LOC_A33E:                              
    LD      A, ($7014)
    AND     A
    JR      Z, LOC_A349
    CP      4
    JP      Z, LOC_A375

LOC_A349:                              
    LD      A, B
    RRCA
    RRCA
    INC     A
    LD      ($7116), A
    PUSH    BC
    LD      A, 5
    RST     18H
    POP     BC

LOC_A355:                              
    LD      A, B
    LD      HL, BYTE_9ADD
    RST     8
    LD      A, (HL)
    LD      ($70E7), A
    LD      A, ($7126)
    LD      ($70EC), A
    LD      A, ($7014)
    AND     A
    RET     NZ
    CALL    SUB_9D76
    BIT     7, A
    RET     NZ
    LD      A, ($7126)
    JP      SUB_A843

LOC_A375:                              
    LD      A, ($7126)
    RST     38H
    BIT     7, (HL)
    JR      NZ, LOC_A38D
    LD      A, ($70E7)
    AND     A
    RET     NZ
    PUSH    BC
    CALL    SUB_AC5E
    LD      A, 0EH
    RST     18H
    POP     BC
    JP      LOC_A355

LOC_A38D:                              
    LD      A, 5
    LD      ($7014), A
    LD      A, ($7116)
    AND     0C0H
    LD      ($7116), A
RET

SUB_A39B:                              
    LD      DE, ($71DD)
    LD      A, D
    OR      E
    RET     NZ
    LD      A, ($7014)
    AND     A
    RET     NZ
    RST     30H
    LD      HL, BYTE_A83A
    RST     20H
    LD      D, 0
    LD      HL, ($7015)
    LD      A, L
    OR      H
    JR      Z, LOC_A3C1
    DEC     HL
    LD      ($7015), HL
    AND     A
    PUSH    HL
    SBC     HL, DE
    POP     HL
    JP      NC, LOC_A552

LOC_A3C1:                              
    LD      A, ($7209)
    AND     A
    JP      NZ, LOC_A552
    ADD     HL, DE
    LD      ($7015), HL
    LD      A, ($71D7)
    DEC     A
    JR      NZ, LOC_A3DC
    LD      A, ($7169)
    AND     A
    JR      NZ, LOC_A3DC
    LD      A, 6
    JR      LOC_A3EC

LOC_A3DC:                              
    LD      HL, $71DF
    LD      A, ($7012)
    AND     7
    RST     8
    LD      A, (HL)
    CP      5
    JR      NZ, LOC_A3EC
    LD      (HL), 2

LOC_A3EC:                              
    CP      3
    JR      Z, LOC_A3F4
    CP      4
    JR      NZ, LOC_A3F6

LOC_A3F4:                              
    LD      (HL), 2

LOC_A3F6:                              
    LD      HL, JUMP_TABLE
    SUB     2
    ADD     A, A
    RST     8
    LD      A, (HL)
    INC     HL
    LD      H, (HL)
    LD      L, A
    JP      (HL)

JUMP_TABLE:                            
    DW LOC_A4A0
    DW LOC_A4A7
    DW LOC_A49B
    DW LOC_A48D
    DW LOC_A494

LOC_A40C:                              
    LD      HL, $7166
    LD      DE, $715A
    LD      BC, 4
    LDIR
    LD      HL, $715A
    LD      DE, $715E
    LD      BC, 4
    LDIR
    LD      HL, $715A
    LD      DE, $719A
    LD      BC, 4
    LDIR
    SUB     A
    LD      ($7166), A
    LD      ($71A6), A
    LD      ($7169), A
    LD      ($71A9), A
    LD      ($711A), A
    LD      ($70FA), A
    LD      HL, ($713E)
    LD      ($7138), HL
    LD      A, ($712A)
    LD      ($7127), A
    LD      A, 1
    LD      ($7107), A
    LD      ($70F7), A
    LD      HL, 0
    LD      ($713E), HL
    LD      A, 6
    LD      ($710A), A
    LD      IX, $715A
    LD      B, 4
    LD      A, 8
    LD      (IX+2), A
    ADD     A, B
    LD      (IX+6), A
    ADD     A, B
    LD      (IX+42H), A
    LD      A, 0FH
    LD      (IX+43H), A
    LD      A, (IX+0)
    SUB     10H
    LD      (IX+0), A
    LD      (IX+40H), A
    LD      IY, $7117
    CALL    SUB_A7EE
    RST     28H
    JP      LOC_A6F6

LOC_A48D:                              
    LD      HL, $7165
    LD      B, 1
    JR      LOC_A4AC

LOC_A494:                              
    LD      HL, $7169
    LD      B, 1
    JR      LOC_A4AC

LOC_A49B:                              
    LD      HL, $7175
    JR      LOC_A4AA

LOC_A4A0:                              
    LD      HL, $717D
    LD      B, 7
    JR      LOC_A4AC

LOC_A4A7:                              
    LD      HL, $716D

LOC_A4AA:                              
    LD      B, 2

LOC_A4AC:                              
    LD      A, (HL)
    AND     A
    JR      Z, LOC_A4B8
    LD      A, 4
    RST     8
    DJNZ    LOC_A4AC
    JP      LOC_A552

LOC_A4B8:                              
    LD      DE, $7159
    AND     A
    SBC     HL, DE
    LD      A, L
    LD      DE, $7156
    ADD     HL, DE
    PUSH    HL
    POP     IX
    LD      HL, $7116
    SRL     A
    SRL     A
    LD      B, A
    RST     8
    PUSH    HL
    POP     IY
    LD      HL, BYTE_A7BE
    LD      A, B
    ADD     A, A
    PUSH    AF
    ADD     A, B
    RST     8
    LD      A, (HL)
    LD      (IY-10H), A
    INC     HL
    LD      A, (HL)
    LD      (IX+3), A
    INC     HL
    LD      A, (HL)
    LD      (IX+43H), A
    SUB     A
    LD      (IX+0), A
    LD      (IX+40H), A
    LD      A, ($7017)
    SUB     3
    AND     3FH
    LD      E, A
    LD      BC, 9302H
    LD      HL, $7012
    BIT     6, (HL)
    JR      NZ, LOC_A506
    SET     6, E
    LD      BC, 6306H

LOC_A506:                              
    LD      A, 7BH
    LD      (IX+1), B
    LD      (IX+41H), B
    LD      (IY+0), E
    LD      (IY+10H), C
    POP     AF
    LD      HL, $7136
    RST     8
    LD      A, 0E8H
    LD      (HL), A
    INC     HL
    LD      (HL), 0
    LD      A, (IY-10H)
    CP      2
    JR      NZ, LOC_A54D
    LD      HL, BYTE_A7B2
    LD      A, ($701B)
    SRL     A
    AND     7
    RST     8
    LD      B, 0
    LD      A, ($7012)

LOC_A536:                              
    SUB     (HL)
    JR      C, LOC_A53C
    INC     B
    JR      LOC_A536

LOC_A53C:                              
    LD      A, B
    LD      HL, BYTE_8566
    CALL    SUB_9250
    RST     8
    LD      A, (HL)
    CALL    SUB_A2E8
    AND     0FH
    LD      (IX+3), A

LOC_A54D:                              
    SET     3, (IY-10H)
    RST     28H

LOC_A552:                              
    LD      IY, $7117

LOC_A556:                              
    LD      A, (IY+0)
    AND     3FH
    JP      Z, LOC_A5CD
    PUSH    IY
    POP     HL
    LD      DE, $7116
    AND     A
    SBC     HL, DE
    LD      A, L
    CP      1
    JP      Z, LOC_A6F6
    ADD     A, A
    LD      B, A
    LD      HL, $7136
    RST     8
    LD      A, 0E8H
    CP      (HL)
    JP      NZ, LOC_A6F6
    SUB     A
    INC     HL
    CP      (HL)
    JP      NZ, LOC_A6F6
    DEC     HL
    EX      DE, HL
    LD      A, B
    ADD     A, A
    LD      HL, $7156
    RST     8
    PUSH    HL
    POP     IX
    LD      A, (IX+0)
    CP      2EH
    JP      C, LOC_A6F6
    SUB     A
    EX      DE, HL
    LD      A, (IY+0)
    AND     0C0H
    LD      (IY+0), A
    LD      BC, 10H
    LD      D, 6
    LD      A, (IX+1)
    CP      63H
    JR      Z, LOC_A5AD
    LD      BC, 1800H
    LD      D, 2

LOC_A5AD:                              
    LD      (HL), B
    INC     HL
    LD      (HL), C
    LD      (IY+10H), D
    LD      HL, BYTE_926F
    LD      A, ($7034)
    RST     8
    LD      A, (HL)
    LD      (IY-20H), A
    RES     3, (IY-10H)
    RST     28H
    LD      A, 4
    PUSH    IY
    RST     18H
    POP     IY
    JP      LOC_A6F6

LOC_A5CD:                              
    LD      DE, $7116
    PUSH    IY
    POP     HL
    AND     A
    SBC     HL, DE
    LD      A, L
    ADD     A, A
    ADD     A, A
    LD      HL, $7156
    RST     8
    PUSH    HL
    POP     IX
    LD      A, (IY-10H)
    BIT     7, A
    JR      NZ, LOC_A607
    LD      A, (IY-10H)
    AND     0FH
    CP      2
    JP      NZ, LOC_A67A
    LD      A, (IY+10H)
    CALL    SUB_A200
    LD      A, (HL)
    CALL    SUB_A2E8
    AND     0FH
    CP      (IX+3)
    JP      NZ, LOC_A67A
    SET     7, (IY-10H)

LOC_A607:                              
    PUSH    IY
    POP     HL
    LD      DE, $7116
    AND     A
    SBC     HL, DE
    LD      A, L
    ADD     A, A
    LD      B, A
    LD      HL, $7136
    RST     8
    INC     HL
    LD      A, (HL)
    AND     0FH
    CP      0CH
    JR      C, LOC_A638
    SUB     A
    LD      (HL), A
    DEC     HL
    LD      (HL), A
    LD      (IX+0), A
    LD      (IX+40H), A
    LD      (IY+0), A
    LD      (IY-20H), A
    LD      (IX+3), A
    LD      (IX+43H), A
    JP      LOC_A6F6

LOC_A638:                              
    LD      A, ($7010)
    AND     1
    JP      NZ, LOC_A6F6
    INC     (IX+0)
    INC     (IX+40H)
    INC     (HL)
    LD      A, (HL)
    NEG
    AND     0FH
    LD      E, (IX+2)
    LD      D, 7
    SLA     E
    RL      D
    SLA     E
    RL      D
    SLA     E
    RL      D
    LD      HL, BYTE_806C
    LD      BC, 1
    ADD     A, E
    JR      NC, LOC_A667
    INC     D

LOC_A667:                              
    LD      E, A
    RST     10H
    LD      A, 10H
    ADD     A, E
    JR      NC, LOC_A66F
    INC     D

LOC_A66F:                              
    LD      E, A
    LD      BC, 1
    LD      HL, BYTE_806C
    RST     10H
    JP      LOC_A6F6

LOC_A67A:                              
    LD      A, (IY-20H)
    AND     A
    JP      Z, LOC_A6F6
    DEC     A
    LD      (IY-20H), A
    JP      NZ, LOC_A6F6
    LD      A, ($7209)
    AND     A
    JR      Z, LOC_A694
    INC     (IY-20H)
    JP      LOC_A6F6

LOC_A694:                              
    LD      A, (IY-10H)
    CP      1
    JR      NZ, LOC_A6A1
    CALL    SUB_A7EE
    JP      LOC_A6F6

LOC_A6A1:                              
    LD      A, ($7012)
    AND     40H
    LD      B, A
    INC     A
    LD      (IY+0), A
    LD      A, (IY-10H)
    CP      6
    JR      NZ, LOC_A6C5
    LD      HL, $713E
    LD      B, 60H
    LD      A, ($711A)
    DEC     A
    JR      Z, LOC_A6C0
    INC     HL
    LD      B, 40H

LOC_A6C0:                              
    LD      A, (HL)
    CP      B
    JP      Z, LOC_A40C

LOC_A6C5:                              
    LD      A, (IY-10H)
    SUB     3
    CP      2
    JR      NC, LOC_A6F6
    LD      A, B
    RLCA
    RLCA
    LD      HL, BYTE_9ADD
    RST     8
    LD      B, (HL)
    PUSH    IY
    POP     HL
    LD      DE, $711A
    AND     A
    SBC     HL, DE
    LD      A, L
    LD      HL, $70E7
    RST     8
    LD      (HL), B
    LD      A, 5
    RST     8
    LD      A, (IY+10H)
    LD      (HL), A
    CALL    SUB_A843
    PUSH    IY
    LD      A, 6
    RST     18H
    POP     IY

LOC_A6F6:                              
    INC     IY
    PUSH    IY
    POP     HL
    LD      DE, $7126
    AND     A
    SBC     HL, DE
    JP      NZ, LOC_A556
    LD      A, ($71D7)
    AND     A
    JR      Z, LOC_A715
    DEC     A
    JR      Z, LOC_A723
    DEC     A
    JR      Z, LOC_A72E
    DEC     A
    JP      Z, LOC_A799
RET

LOC_A715:                              
    LD      A, ($71D8)
    DEC     A
    LD      ($71D8), A
    RET     NZ
    LD      A, 1
    LD      ($71D7), A
RET

LOC_A723:                              
    LD      A, ($715D)
    AND     A
    RET     Z
    LD      A, 2
    LD      ($71D7), A
RET

LOC_A72E:                              
    LD      A, ($715D)
    AND     A
    JR      Z, LOC_A79E
    LD      A, ($7017)
    SUB     4
    LD      B, A
    LD      A, ($7117)
    AND     3FH
    JR      Z, LOC_A756
    CP      B
	RET     C
    LD      A, ($7127)
    LD      B, A
    LD      A, ($7117)
    RLCA
    RLCA
    AND     3
    LD      HL, BYTE_924C
    RST     8
    LD      A, (HL)
    ADD     A, B
    JR      LOC_A759

LOC_A756:                              
    LD      A, ($7127)

LOC_A759:                              
    LD      HL, $7126
    CP      (HL)
    RET     NZ
    AND     3FH
    RST     38H
    LD      A, (HL)
    AND     0C0H
    RET     NZ
    LD      A, ($70E7)
    AND     A
    RET     Z
    SUB     A
    LD      ($7139), A
    LD      A, 78H
    LD      ($7138), A
    LD      A, ($7017)
    SUB     3
    LD      B, A
    LD      A, ($7117)
    OR      B
    LD      ($7117), A
    LD      A, 3
    LD      ($71D7), A
    LD      A, ($7088)
    PUSH    AF
    LD      HL, BYTE_A7A6
    ADD     A, A
    RST     20H
    CALL    ADD_SOME_SCORE
    POP     AF
    AND     A
    RET     Z
    DEC     A
    LD      ($7088), A
RET

LOC_A799:                              
    LD      A, ($715D)
    AND     A
    RET     NZ

LOC_A79E:                              
    SUB     A
    LD      ($71D8), A
    LD      ($71D7), A
RET

BYTE_A7A6:
	DB  05H, 00H, 00H, 01H, 00H, 02H, 00H, 03H, 00H, 04H, 00H, 05H
BYTE_A7B2:
	DB  80H, 80H, 56H, 2BH, 03H, 02H, 03H, 02H, 03H, 03H, 07H, 06H
BYTE_A7BE:
	DB  00H, 08H, 0FH, 01H, 0DH, 0FH, 00H, 00H, 00H, 05H, 03H, 0FH, 06H, 0DH, 0FH, 03H, 03H, 01H, 03H, 03H, 01H, 04H, 03H, 0FH, 04H, 03H, 0FH, 02H, 00H, 0FH
    DB  02H, 00H, 0FH, 02H, 00H, 0FH, 02H, 00H, 0FH, 02H, 00H, 0FH, 02H, 00H, 0FH, 02H, 00H, 0FH

SUB_A7EE:                              
    LD      HL, $7136
    LD      A, (HL)
    ADD     A, 18H
    LD      B, A
    LD      A, ($7138)
    ADD     A, 18H
    SUB     B
    LD      ($70E2), A
    JR      NC, LOC_A802
    NEG

LOC_A802:                              
    LD      B, A
    INC     HL
    LD      A, (HL)
    ADD     A, 10H
    LD      C, A
    LD      A, ($7139)
    ADD     A, 10H
    SUB     C
    LD      ($70E3), A
    JR      NC, LOC_A815
    NEG

LOC_A815:                              
    LD      HL, $70E3
    LD      DE, 4181H
    LD      C, A
    SUB     B
    JR      NC, LOC_A823
    DEC     HL
    LD      DE, 1C1H

LOC_A823:                              
    LD      B, D
    LD      A, (HL)
    BIT     7, A
    JR      NZ, LOC_A82A
    LD      B, E

LOC_A82A:                              
    LD      A, B
    LD      ($7117), A
    PUSH    IY
    PUSH    IX
    LD      A, 7
    RST     18H
    POP     IX
    POP     IY
RET

BYTE_A83A:
	DB 0FFH,0DFH,0BFH,0A0H, 78H, 64H, 5AH, 3CH, 1EH

SUB_A843:                              
    LD      B, A
    RST     38H
    LD      (HL), A
    LD      A, B
    DEC     A
    CALL    SUB_A1B2
    LD      HL, $707E
    LD      A, D
    XOR     0FFH
    LD      D, A
    LD      A, E
    XOR     0FFH
    LD      E, A
    LD      A, B
    RST     8
    LD      A, (HL)
    AND     E
    LD      (HL), A
    LD      HL, $7083
    LD      A, C
    RST     8
    LD      A, (HL)
    AND     D
    LD      (HL), A
RET

UNK_A864:
	DB  00H               
BYTE_A865:
	DB  07H, 08H, 09H, 0CH, 0DH, 0EH, 11H, 12H, 13H
BYTE_A86E:
	DB  02H, 01H, 00H, 01H, 01H, 00H, 01H, 00H, 00H, 02H, 02H, 01H, 03H, 04H, 05H, 06H, 07H, 09H, 0AH, 02H, 03H, 16H, 08H, 09H, 07H, 07H, 10H, 00H, 12H, 03H
    DB  06H, 13H, 06H, 06H, 02H, 02H, 13H, 11H, 12H, 06H, 09H, 00H, 08H, 09H, 13H, 09H, 17H, 11H, 04H, 10H, 0CH, 00H, 15H, 10H, 10H, 0CH, 14H, 11H, 12H, 0CH
    DB  0FH, 15H, 08H, 0FH, 03H, 0FH, 0BH, 11H, 12H, 0FH, 12H, 0BH, 05H, 05H, 0BH, 0DH, 02H, 0DH, 0DH, 02H, 15H, 06H, 08H, 08H, 06H, 05H, 0FH, 00H, 00H, 0FH

SUB_A8C8:                              
    CALL    BLANK_THE_SCREEN
    CALL    SUB_AB06
    LD      ($71E7), A
    LD      ($71D6), A
    LD      HL, $703F
    LD      B, 1AH

LOC_A8D9:                              
    LD      (HL), A
    INC     HL
    DJNZ    LOC_A8D9
    CALL    SUB_AAB4
    LD      A, 6
    LD      ($7014), A
    CALL    SUB_9C54
    CALL    SUB_9C62
    CALL    SUB_99C4
    CALL    SUB_9BD2
    LD      DE, UNK_A864
    LD      HL, BYTE_A86E
    LD      A, ($7034)
    AND     0FCH
    LD      B, A
    SRL     B
    ADD     A, A
    ADD     A, B
    RST     8
    PUSH    HL
    EX      DE, HL
    LD      B, 0AH

LOC_A906:                              
    LD      A, (HL)
    PUSH    HL
    RST     38H
    LD      A, (DE)
    LD      (HL), A
    POP     HL
    INC     HL
    INC     DE
    DJNZ    LOC_A906
    LD      B, 9
    POP     HL
    LD      C, (HL)
    INC     HL
    LD      DE, BYTE_A865

LOC_A918:                              
    LD      A, (HL)
    CP      C
    JR      NZ, LOC_A927
    LD      A, (DE)
    DEC     A
    PUSH    DE
    PUSH    HL
    PUSH    BC
    CALL    SUB_A22A
    POP     BC
    POP     HL
    POP     DE

LOC_A927:                              
    INC     DE
    INC     HL
    DJNZ    LOC_A918
    LD      B, 0AH
    LD      HL, UNK_A864
LOC_A930:                              
    LD      A, (HL)
    PUSH    HL
    PUSH    BC
    CALL    SUB_8D99
    POP     BC
    POP     HL
    INC     HL
    DJNZ    LOC_A930
    LD      HL, BYTE_9B76
    CALL    SUB_9AC7
    LD      IY, $7116
    LD      HL, 0
    LD      ($7136), HL
    SUB     A
    LD      (IY+0), A
    LD      (IY-10H), A
    LD      A, 7
    LD      ($7126), A
    LD      A, 78H
    LD      (IY-20H), A
    LD      IX, $7156
    CALL    SUB_AB11
    LD      A, 3EH
    LD      (IX+0), A
    LD      (IX+40H), A
    SUB     A
    LD      (IY+0), A
    RST     28H
    LD      HL, LEVEL_ROUND_TXT
    LD      DE, 186DH
    LD      BC, 5
    RST     10H
    LD      HL, $7300
    RST     30H
    ADD     A, 31H
    LD      HL, 1874H
    LD      DE, 1
    CALL    FILL_VRAM
    LD      HL, TO_WIN_YOU_TXT
    LD      DE, 1AA9H
    LD      BC, 0FH
    RST     10H
    LD      HL, TIC_TAC_TOE_TXT
    LD      DE, 1ACCH
    LD      BC, 0CH
    LD      A, ($7034)
    CP      8
    JR      NC, LOC_A9A4
    DEC     BC

LOC_A9A4:                              
    RST     10H
    RST     30H
    LD      HL, BYTE_A20C
    RST     8
    LD      A, (HL)
    OR      30H
    LD      HL, 1ACAH
    LD      DE, 1
    CALL    FILL_VRAM
    LD      HL, MATCH_TXT
    LD      DE, 1922H
    LD      BC, 5
    RST     10H
    LD      HL, ALL_3_TXT
    LD      DE, 1942H
    LD      BC, 5
    RST     10H
    LD      HL, SIDES_TXT
    LD      DE, 1962H
    LD      BC, 5
    RST     10H
    LD      HL, BYTE_A865
    LD      B, 9

LOC_A9D9:                              
    LD      A, (HL)
    PUSH    HL
    CALL    SUB_A2D7
    JR      NZ, LOC_A9E8
    POP     HL
    PUSH    HL
    PUSH    BC
    LD      A, (HL)
    CALL    SUB_8DED
    POP     BC

LOC_A9E8:                              
    POP     HL
    INC     HL
    DJNZ    LOC_A9D9
    CALL    SUB_8E8C

LOC_A9EF:                              
    CALL    SUB_8E58
    CALL    SUB_AC51
    CALL    SUB_9E94
    CALL    SUB_8F57
    RST     30H
    LD      HL, BYTE_A20C
    RST     8
    LD      A, (HL)
    LD      B, A
    LD      A, ($71D9)
    CP      B
    JP      NC, LOC_AA62
    LD      A, ($7116)
    AND     3FH
    JR      NZ, LOC_A9EF
    LD      IY, $7116
    LD      A, (IY-20H)
    AND     A
    JR      Z, LOC_AA1F
    DEC     (IY-20H)
    JR      LOC_A9EF

LOC_AA1F:                              
    LD      A, ($71E7)
    LD      HL, BYTE_AA85
    RST     30H
    ADD     A, A
    RST     20H
    EX      DE, HL
    LD      A, ($71E7)
    RST     8
    LD      A, (HL)
    AND     A
    JP      Z, LOC_AA62
    LD      (IY+0), A
    RLCA
    RLCA
    AND     3
    LD      HL, BYTE_9ADD
    RST     8
    LD      A, (HL)
    LD      ($70E7), A
    LD      A, ($7126)
    LD      ($70EC), A
    LD      A, ($71E7)
    INC     A
    LD      ($71E7), A
    LD      A, 5
    RST     18H
    CALL    SUB_9D76
    BIT     7, A
    JP      NZ, LOC_A9EF
    LD      A, ($7126)
    CALL    SUB_A843
    JP      LOC_A9EF

LOC_AA62:                              
    LD      A, 0DH
    RST     18H
    SUB     A
    LD      ($7010), A

LOC_AA69:                              
    CALL    SUB_8E58
    CALL    SUB_AC51
    CALL    SUB_9E94
    LD      A, ($7001)
    AND     1
    JR      NZ, LOC_AA69
    CALL    BLANK_THE_SCREEN
    CALL    SUB_AAB4
    CALL    SUB_8E8C
    JP      SUB_99C4

BYTE_AA85:
	DB  97H,0AAH, 97H,0AAH, 9BH,0AAH,0A0H,0AAH,0A5H,0AAH,0A5H,0AAH,0A5H,0AAH,0ABH,0AAH,0ABH,0AAH, 41H, 01H, 01H, 00H, 41H, 01H, 01H, 81H, 00H, 41H, 01H, 01H
    DB  41H, 00H, 41H, 01H, 01H,0C1H,0C1H, 00H, 41H, 41H, 01H, 01H, 81H, 81H,0C1H,0C1H, 00H

SUB_AAB4:                              
    LD      HL, $7300
    LD      B, 40H

LOC_AAB9:                              
    LD      (HL), 0
    INC     HL
    DJNZ    LOC_AAB9
    LD      DE, 1800H
    LD      B, 0CH

LOC_AAC3:                              
    PUSH    BC
    LD      BC, 40H
    LD      HL, $7300
    RST     10H
    EX      DE, HL
    LD      A, 40H
    RST     8
    EX      DE, HL
    POP     BC
    DJNZ    LOC_AAC3
RET

TO_WIN_YOU_TXT:
	DB 084,079,032,087,073,078,032,089,079,085,032,078,069,069,068
TIC_TAC_TOE_TXT:
	DB 084,073,067,045,084,065,067,045,084,079,069,083
MATCH_TXT:
	DB 077,065,084,067,072
ALL_3_TXT:
	DB 065,076,076,032,051
SIDES_TXT:
	DB 083,073,068,069,083

LOC_AAFE:                              
    LD      A, ($7034)
    SRL     A
    SRL     A
RET

SUB_AB06:                              
    SUB     A
    LD      B, 0AH
    LD      HL, $707E

LOC_AB0C:                              
    LD      (HL), A
    INC     HL
    DJNZ    LOC_AB0C
RET

SUB_AB11:                              
    LD      A, 0FCH
    LD      HL, $7156
    CALL    SUB_AB49
    SUB     A
    CALL    SUB_AB49
    LD      HL, BYTE_AB31
    LD      DE, $7156
    LD      BC, 0CH
    LDIR
    LD      DE, $7196
    LD      BC, 0CH
    LDIR
RET

BYTE_AB31:
	DB  1EH, 7BH, 00H, 08H, 00H, 7BH, 08H, 00H, 00H, 7BH, 0CH, 00H, 1EH, 7BH, 04H, 0FH, 00H, 7BH, 10H, 00H,0B0H, 00H, 00H, 00H

SUB_AB49:                              
    LD      DE, 8
    LD      BC, 107BH

LOOP_AB4F:                             
    LD      (HL), D
    INC     HL
    LD      (HL), C
    INC     HL
    LD      (HL), A
    INC     HL
    LD      (HL), D
    INC     HL
    ADD     A, E
    DJNZ    LOOP_AB4F
RET

LOC_AB5B:                              
    SUB     A
    LD      E, A
    LD      B, A
    LD      A, (IY-10H)
    BIT     3, A
    JR      Z, LOC_AB66
    INC     E

LOC_AB66:                              
    AND     7
    LD      C, A
    ADD     A, A
    ADD     A, C
    LD      HL, 9277H
    RST     8
    LD      C, (HL)
    INC     HL
    LD      A, (HL)
    INC     HL
    LD      H, (HL)
    LD      L, A
    LD      A, (IY+0)
    RLCA
    RLCA
    AND     2
    ADD     A, E
    JR      Z, LOC_AB83

LOC_AB7F:                              
    ADD     HL, BC
    DEC     A
    JR      NZ, LOC_AB7F

LOC_AB83:                              
    LD      DE, 7300H
    PUSH    BC
    LDIR
    LD      A, (IY-10H)
    AND     7
    CP      5
    JR      NC, LOC_ABDD
    POP     DE
    PUSH    DE
    LD      HL, 7300H
    LD      A, (IY+0)
    SRL     E
    SRL     E
    LD      B, E
    BIT     6, A
    JR      NZ, LOC_ABA8
    LD      A, E
    ADD     A, 10H
    LD      E, A
    ADD     HL, DE

LOC_ABA8:                              
    PUSH    IX
    PUSH    HL
    POP     IX

LOC_ABAD:                              
    LD      E, (IX+0)
    LD      D, (IX+10H)
    LD      C, 8

LOC_ABB5:                              
    SRL     E
    RL      H
    SRL     D
    RL      L
    DEC     C
    JR      NZ, LOC_ABB5
    LD      (IX+0), L
    LD      (IX+10H), H
    INC     IX
    PUSH    IX
    POP     HL
    DEC     B
    JR      Z, LOC_ABDB
    BIT     4, L
    JR      Z, LOC_ABAD
    LD      DE, 10H
    ADD     HL, DE
    PUSH    HL
    POP     IX
    JR      LOC_ABAD

LOC_ABDB:                              
    POP     IX

LOC_ABDD:                              
    POP     BC
    LD      E, (IX+2)
    LD      D, 7
    SLA     E
    RL      D
    SLA     E
    RL      D
    SLA     E
    RL      D
    LD      HL, 7300H
    RST     10H
    LD      A, 0FFH
    LD      ($7209), A
RET

LOC_ABF9:                              
    LD      B, A
    LD      A, ($7001)
    AND     1
    JR      NZ, LOC_AC4A

LOC_AC01:                              
    LD      A, B
    LD      ($7002), A
    SUB     A
    LD      ($700A), A
    LD      ($7000), A
    INC     A
    LD      ($7001), A
    LD      ($7006), A
    LD      A, B
    ADD     A, A
    LD      HL, 0AD56H
    LD      E, A
    LD      D, 0
    ADD     HL, DE
    LD      A, (HL)
    LD      ($7003), A
    INC     HL
    LD      A, (HL)
    LD      ($7004), A
    LD      HL, ($7003)
    LD      A, (HL)
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    LD      ($7005), A
    DEC     A
    LD      ($7008), A
    LD      A, (HL)
    LD      ($700C), A
    AND     3
    LD      ($7007), A
    INC     HL
    LD      ($7003), HL
    SUB     A
    LD      ($7009), A
RET

LOC_AC4A:                              
    LD      A, ($7002)
    CP      B
    RET     NC
    JR      LOC_AC01

SUB_AC51:                              
    LD      A, ($7001)
    AND     1
    RET     Z
    LD      A, ($700A)
    AND     1
    JR      Z, LOC_AC6C
SUB_AC5E:                              
    CALL    TURN_OFF_SOUND
    SUB     A
    LD      ($700A), A
    LD      ($7001), A
    LD      ($7000), A
RET

LOC_AC6C:                              
    LD      HL, $7008
    INC     (HL)
    LD      A, (HL)
    LD      HL, $7005
    CP      (HL)
    RET     NZ
    SUB     A
    LD      ($7008), A
    LD      A, ($7006)
    AND     1
    JR      NZ, LOC_AC93
    LD      HL, ($7003)
    LD      A, (HL)
    INC     A
    JR      NZ, LOC_ACF1
    INC     HL
    LD      A, (HL)
    LD      ($7005), A
    INC     HL
    LD      ($7003), HL
    JR      LOC_ACF1

LOC_AC93:                              
    SUB     A
    LD      ($7006), A
    LD      HL, ($7003)
    LD      A, (HL)
    SLA     A
    SLA     A
    SLA     A
    SLA     A
    LD      B, A
    LD      A, ($7204)
    AND     0FH
    OR      B
    LD      ($7204), A
    LD      A, (HL)
    AND     0F0H
    LD      B, A
    LD      A, ($71EC)
    AND     0FH
    OR      B
    LD      ($71EC), A
    INC     HL
    LD      A, (HL)
    SLA     A
    SLA     A
    SLA     A
    SLA     A
    LD      B, A
    LD      A, ($71F4)
    AND     0FH
    OR      B
    LD      ($71F4), A
    LD      A, (HL)
    AND     0F0H
    LD      B, A
    LD      A, ($71FC)
    AND     0FH
    OR      B
    LD      ($71FC), A
    INC     HL
    LD      ($7003), HL
    LD      A, 0E3H
    LD      HL, $700C
    OR      (HL)
    AND     0FH
    LD      B, A
    LD      A, ($71EC)
    AND     0F0H
    OR      B
    LD      ($71EC), A

LOC_ACF1:                              
    LD      A, ($7009)
    LD      HL, $7007
    CP      (HL)
    JR      Z, LOC_AD4F
    LD      HL, BYTE_AFEB
    ADD     A, A
    RST     20H
    PUSH    DE
    POP     IY
    LD      HL, $7009
    INC     (HL)
    LD      HL, ($7003)
    LD      A, (HL)
    AND     A
    JP      Z, SUB_AC5E
    AND     0FCH
    RRCA
    RRCA
    LD      B, A
    SLA     A
    SLA     A
    SLA     A
    SLA     A
    LD      C, A
    LD      A, (IY+3)
    AND     0FH
    OR      C
    LD      (IY+3), A
    LD      A, B
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    LD      B, A
    LD      A, (IY+4)
    AND     0F0H
    OR      B
    LD      (IY+4), A
    LD      A, (HL)
    AND     3
    SLA     A
    SLA     A
    LD      B, A
    INC     HL
    LD      ($7003), HL
    LD      A, (IY+3)
    AND     0F0H
    OR      B
    LD      (IY+3), A
    JR      LOC_ACF1

LOC_AD4F:                              
    SUB     A
    LD      ($7009), A
    JP      PLAY_SONGS

POSSIBLE_SOUND_TABLE:DW BYTE_ADB3
    DW BYTE_ADF1
    DW BYTE_ADF1
    DW BYTE_AD74
    DW BYTE_AEA8
    DW BYTE_AE72
    DW BYTE_AE5F
    DW BYTE_AE8C
    DW BYTE_AF32
    DW BYTE_AEBA
    DW BYTE_AFB6
    DW BYTE_AEB2
    DW BYTE_AF70
    DW BYTE_AE31
    DW BYTE_AEFC
BYTE_AD74:
	DB 131,241,017,215,107,054,171,085,043,144,072,036,107,054,027,171,085,043,144,072,036
    DB 107,054,027,161,068,048,161,068,048,161,068,054,161,068,048,255,004,215,072,043,215
    DB 072,085,215,072,043,215,036,043,215,072,043,215,036,043,215,043,027,215,043,027,000
BYTE_ADB3:
	DB 082,241,031,128,064,128,085,128,064,128,054,128,057,128,085,135,057,135,048,128,054,171,085,128,043,107,054,114,068,171,085
    DB 114,043,096,048,107,064,161,081,128,064,054,027,135,057,161,081,171,057,048,024,128,054,171,085,128,064,107,054,128,032,000
BYTE_ADF1:
	DB 067,241,017,144,096,057,255,016,144,085,054,255,004,144,096,057,076,076,038,085,085,043,096,096,048,102,102,051,096,096,048,191
    DB 107,076,128,128,085,114,114,057,096,096,048,107,107,054,128,128,064,144,144,072,036,057,072,144,144,072,255,040,144,057,036,000
BYTE_AE31:
	DB 066,241,031,085,043,096,048,085,043,096,048,096,048,096,048,102,051,096,048,076,038,085,043
    DB 076,038,085,043,085,043,085,043,091,045,085,043,072,036,085,043,072,036,255,016,057,029,000
BYTE_AE5F:
	DB 083,241,019,034,033,035,033,032,034,032,031,033,029,027,028,030,028,029,000
BYTE_AE72:
	DB 018,242,079,121,231,105,041,135,045,231,254,210,075,193,254,085,121,056,254,043,254,044,035,043,254,000
BYTE_AE8C:
	DB 018,242,063,115,037,036,021,021,035,020,034,024,019,023,045,022,044,021,043,020,041,018,024,008,023,007,021,000
BYTE_AEA8:
	DB 018,242,063,136,041,231,043,129,043,000
BYTE_AEB2:
	DB 018,242,095,037,019,039,165,000
BYTE_AEBA:
	DB 050,241,031,040,020,041,020,041,021,042,021,042,021,042,021,043,021,043,022,044,022,044,022,045,022,045,023,046,023,046,023,047,023
    DB 046,023,047,023,047,024,048,024,049,024,049,025,050,025,050,025,051,026,052,026,052,026,053,027,054,027,054,027,055,028,056,028,000
BYTE_AEFC:
	DB 034,242,079,149,049,149,050,149,050,144,044,254,043,254,044,144,049,149,050,149,050,144,049,011,025,006,005,038,019,037
    DB 013,037,008,037,008,019,006,019,006,007,005,009,005,009,005,009,005,005,006,005,006,005,008,000
BYTE_AF32:
	DB 050,241,031,040,080,041,081,041,082,042,083,042,084,042,085,043,086,043,087,044,087,044,089,045,089,045,091,046,091,046,093
    DB 047,094,047,095,048,096,049,097,049,098,050,100,050,101,051,102,052,103,052,105,053,106,054,107,054,109,055,110,056,112,000
BYTE_AF70:
	DB 022,015,127,002,029,003,010,004,005,003,005,002,016,001,036,003,003,002,031,002,004,001,033,021,001,037,035,053,005,160
    DB 031,160,005,160,001,160,001,003,001,005,001,006,032,007,001,006,001,007,002,006,063,160,030,160,057,160,031,160,063,002
    DB 018,003,002,001,010,002,050,003,011,000
BYTE_AFB6:
	DB 161,241,255,036,045,030,040,027,034,255,007,051,036,045,030,255,006,040,027,034,051,255,005,036,045,030,040
    DB 027,255,004,034,051,045,030,255,003,036,023,038,024,040,025,043,027,045,029,048,030,051,032,054,034,000
BYTE_AFEB:
	DB 000,114,248,113,240,113,232,113




    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH
    DB 0FFH